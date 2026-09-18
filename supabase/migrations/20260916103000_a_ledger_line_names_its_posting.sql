-- Ekwo OS — a ledger line says which posting wrote it.
--
-- `entry_lines` carries `tax_id` and `tax_line`, and between them they cannot
-- tell a `base` line from a `tax_on_base` line. Both belong to the same tax,
-- both are booked on a base account, and both have `tax_line = false` — which
-- is right, because a non-deductible share of tax is a cost and belongs on the
-- base side of the declaration, and it is exactly why the Belgian grids 82 and
-- 83 report it together with the base. What it cost is that anything reading
-- the ledger *by tax* rather than *by box* had to know that one of the two
-- could not occur.
--
-- `ec_sales_list()` is the reader that found it. It takes the lines of a tax
-- that are not tax lines, which is exact today because an intra-Community
-- supply is exempt and has no tax to capitalise — and would stop being exact
-- the day a pack said otherwise, silently, by adding a supply's `tax_on_base`
-- amount to what the statement declares. `docs/international.md` recorded it
-- under *A ledger line does not say which posting wrote it*, and proposed
-- exactly what is here: the posting's own type, copied onto the line beside the
-- `declaration_box` that is already copied there.
--
-- **The vocabulary is `tax_postings`'s own.** `tax_posting_type` — `base`,
-- `tax`, `tax_on_base` — because the column answers *which posting wrote this
-- line*, and a posting's type is the only correct answer. A second enum
-- spelling the same three words would be the same fact written twice.
--
-- **A line that is no posting is null, not a fourth word.** The counterpart of
-- an invoice, the two legs of a payment, the lines of a closing entry: none of
-- them was written by a tax posting, and null is what a column says about a
-- question that does not apply to the row. Adding a `none` to
-- `tax_posting_type` would put a value meaning *not a posting* inside the
-- vocabulary of what a posting is, and `tax_postings.posting_type` would then
-- have to refuse it — a constraint existing only to undo an enum value. A
-- check constraint says the useful half instead: a line with a posting type
-- has a tax, so the two are never read apart.
--
-- Null therefore carries two readings, and `tax_id` separates them: null with
-- no tax is *not a tax posting*, and null with a tax is *written before this
-- migration and not identified*. Which brings us to the backfill.
--
-- **The backfill only writes what is certain.** A ledger is not rewritten by
-- deduction. A line is filled when its tax and its declaration box name one
-- posting type and no other: `tax_postings` is asked which types write a line
-- of that tax into that box on that side of `tax_line`, and the line is filled
-- only where the answer is a single word. Everything else — a line whose
-- posting names no box, the cash-basis lines that wait with their box held back
-- until settlement, a box two posting types both write to — stays null, and the
-- `tax_id` beside it says that null means unknown there rather than
-- inapplicable. Nothing guesses, and nothing that reads this column afterwards
-- can mistake a guess for a fact.
--
-- **Who fills it from now on.** `post_document()`, on all three of the lines a
-- tax produces, from the posting row it is already reading; and
-- `settle_cash_basis_tax()`, on both legs of the transfer that makes a
-- cash-basis tax due — the leg that carries the box and the leg that empties
-- the account the amount waited on are one posting falling due, so they carry
-- one posting type. Both functions are replaced whole, because a function is
-- replaced whole in PostgreSQL, and nothing else in either of them moves.
--
-- Nothing else writes a tax line. `post_payment()` books money against a
-- third-party account, `close_fiscal_year()` and `reopen_fiscal_year()` move
-- results between accounts the pack names, and `post_module_entry()` takes the
-- lines a module hands it and knows no tax at all.

-- ---------------------------------------------------------------------------
-- The column
-- ---------------------------------------------------------------------------

alter table entry_lines
  add column if not exists posting_type tax_posting_type;

comment on column entry_lines.posting_type is
  'Which tax posting wrote this line: base, tax, or tax_on_base, from tax_postings.posting_type. Null on a line no tax posting wrote — a counterpart, a payment, a closing line — and null on a line written before this column existed whose posting could not be identified beyond doubt; tax_id tells the two apart. It is what makes a base line and a tax_on_base line of the same tax on the same account distinguishable, which tax_id and tax_line together cannot do.';

alter table entry_lines
  add constraint entry_lines_posting_type_has_a_tax check (
    posting_type is null or tax_id is not null
  );

-- ---------------------------------------------------------------------------
-- What the existing ledger can be told for certain
-- ---------------------------------------------------------------------------
--
-- One posting type, or nothing. `writes_tax_line` is derived from the type
-- rather than stored, because it is: a `tax` posting is the only one that books
-- a tax line, and `base` and `tax_on_base` both book a line that is not one.
-- Two postings of the same tax writing the same box on the same side is an
-- ambiguity nothing on the line can settle, so those lines stay null.

with candidate as (
  select distinct
         tp.tax_id,
         tp.declaration_box,
         (tp.posting_type = 'tax'::tax_posting_type) as writes_tax_line,
         tp.posting_type
    from tax_postings tp
   where tp.declaration_box is not null
),
unambiguous as (
  select c.tax_id, c.declaration_box, c.writes_tax_line, min(c.posting_type) as posting_type
    from candidate c
   group by c.tax_id, c.declaration_box, c.writes_tax_line
  having count(*) = 1
)
update entry_lines l
   set posting_type = u.posting_type
  from unambiguous u
 where l.tax_id = u.tax_id
   and l.declaration_box = u.declaration_box
   and l.tax_line = u.writes_tax_line
   and l.posting_type is null;

-- ---------------------------------------------------------------------------
-- Everything that writes a tax line, writing it
-- ---------------------------------------------------------------------------

create or replace function post_document(p_document_id uuid)
returns entries
language plpgsql
as $$
declare
  v_doc        documents%rowtype;
  v_entry      entries%rowtype;
  v_journal    uuid;
  v_date       date;
  v_is_sale    boolean;
  v_is_credit  boolean;
  v_kind       tax_document_kind;
  v_base_credit boolean;
  v_seq        integer := 0;
  v_contact    uuid;
  v_maturity   date;
  v_terms      smallint;
  v_counterpart uuid;
  -- Plain `numeric`, not `numeric(16, 2)`: a local that carries a scale is a
  -- second rounding rule hiding in a declaration, and it is not the currency's.
  -- The only thing that rounds here is `round_amount`.
  v_diff       numeric;
  v_diff_cur   numeric;
  v_amount     numeric;
  v_book       numeric;
  v_box_amount numeric;
  v_share      numeric;
  v_share_book numeric;
  v_share_box  numeric;
  v_left       numeric;
  v_left_box   numeric;
  v_side_left     numeric;
  v_side_left_neg numeric;
  v_side_credit boolean;
  v_label      text;
  v_rate       numeric(18, 8);
  v_home       char(3);
  v_foreign    boolean;
  v_total_cur  numeric;
  -- Two currencies, one method: the document is stated in its own and the
  -- ledger keeps the company's, and a yen invoice paid in euros rounds each
  -- side at the decimals that side has.
  v_round      money_rounding;
  v_book_round money_rounding;
  v_cash       boolean;
  v_transition uuid;
  v_postings   integer;
  r            record;
  p            record;
  g            record;
begin
  select * into v_doc from documents where id = p_document_id for update;
  if not found then
    raise exception 'unknown_document: document % does not exist', p_document_id;
  end if;
  if v_doc.state = 'posted' then
    raise exception 'document_already_posted: document % is already posted', p_document_id;
  end if;
  if v_doc.state = 'cancelled' then
    raise exception 'document_cancelled: document % cannot be posted', p_document_id;
  end if;
  if v_doc.entry_id is not null then
    raise exception 'document_already_booked: document % already points at entry %',
      p_document_id, v_doc.entry_id;
  end if;

  if v_doc.doc_type in ('sale_quote', 'purchase_order') then
    raise exception 'document_not_accountable: a % is not booked', v_doc.doc_type;
  end if;

  v_is_sale   := v_doc.doc_type in ('sale_invoice', 'sale_credit_note');
  v_is_credit := v_doc.doc_type in ('sale_credit_note', 'purchase_credit_note');
  v_kind      := case when v_is_credit then 'credit_note' else 'invoice' end::tax_document_kind;
  -- Sale invoice and purchase credit note credit the base; the other two debit it.
  v_base_credit := (v_is_sale <> v_is_credit);

  v_date := coalesce(v_doc.accounting_date, v_doc.document_date);

  if not exists (
    select 1 from document_lines
     where document_id = p_document_id and line_type = 'product' and amount_untaxed <> 0
  ) then
    raise exception 'document_empty: document % has no billable line', p_document_id;
  end if;

  -- A fixed-amount tax has no basis to spread over lines; refuse rather than
  -- guess.
  if exists (
    select 1 from document_lines l join taxes t on t.id = l.tax_id
     where l.document_id = p_document_id and t.amount_type <> 'percent'
  ) then
    raise exception 'unsupported_tax_amount_type: only percentage taxes can be posted';
  end if;

  -- Every tax used must be in force on the accounting date.
  for r in
    select distinct t.id, t.code, t.valid_from, t.valid_to
      from document_lines l join taxes t on t.id = l.tax_id
     where l.document_id = p_document_id
  loop
    if v_date < r.valid_from or (r.valid_to is not null and v_date > r.valid_to) then
      raise exception 'tax_not_in_force: tax % is not applicable on %', r.code, v_date;
    end if;
  end loop;

  -- Totals are derived; make sure they reflect the lines as they stand now.
  perform documents_refresh_totals(p_document_id);
  select * into v_doc from documents where id = p_document_id;

  select c.currency_code into v_home from companies c where c.id = v_doc.company_id;
  v_rate    := v_doc.exchange_rate;
  v_foreign := v_doc.currency_code <> v_home;
  v_round      := rounding_of(v_doc.company_id, v_doc.currency_code);
  v_book_round := rounding_of(v_doc.company_id);

  v_journal := coalesce(
    v_doc.journal_id,
    case when v_is_sale
      then (select sales_journal_id from companies where id = v_doc.company_id)
      else (select purchase_journal_id from companies where id = v_doc.company_id)
    end
  );
  if v_journal is null then
    raise exception 'no_journal: set journal_id on the document or a default journal on the company';
  end if;

  perform assert_period_open(v_doc.company_id, v_date, true);

  v_label := coalesce(v_doc.number, v_doc.supplier_reference, 'document');

  insert into entries (company_id, journal_id, fiscal_year_id, entry_date, reference,
                       description, state, document_id, currency_code)
  values (v_doc.company_id, v_journal, fiscal_year_at(v_doc.company_id, v_date), v_date,
          coalesce(v_doc.number, v_doc.supplier_reference),
          v_label || case when v_doc.supplier_reference is not null and v_doc.number is not null
                          then ' / ' || v_doc.supplier_reference else '' end,
          'draft', p_document_id, v_doc.currency_code)
  returning * into v_entry;

  -- ------------------------------------------------------------------ bases
  for r in
    select l.account_id,
           l.tax_id,
           sum(l.amount_untaxed) as base_amount,
           min(l.sequence)       as seq,
           string_agg(distinct l.name, ', ') as label
      from document_lines l
     where l.document_id = p_document_id
       and l.line_type = 'product'
     group by l.account_id, l.tax_id
    having sum(l.amount_untaxed) <> 0
     order by 4
  loop
    select tp.posting_type, tp.declaration_box, tp.factor_percent, tp.box_factor_percent,
           coalesce(t.cash_basis, false) as cash_basis
      into p
      from tax_postings tp
      join taxes t on t.id = tp.tax_id
     where tp.tax_id = r.tax_id
       and tp.document_kind = v_kind
       and tp.posting_type = 'base'
     limit 1;

    v_amount := round_amount(r.base_amount * coalesce(p.factor_percent, 100) / 100, v_round);
    v_book   := round_amount(v_amount / v_rate, v_book_round);
    v_seq := v_seq + 10;

    insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                             debit, credit, tax_id, tax_line, posting_type,
                             declaration_box, box_amount, currency_code, amount_currency)
    values (v_entry.id, v_doc.company_id, r.account_id, v_seq, left(r.label, 200),
            case when v_base_credit then 0 else v_book end,
            case when v_base_credit then v_book else 0 end,
            r.tax_id, false, p.posting_type,
            case when coalesce(p.cash_basis, false) then null else p.declaration_box end,
            case when p.declaration_box is null then null
                 else round_amount(r.base_amount * coalesce(p.box_factor_percent, 100) / 100 / v_rate,
                                   v_book_round) end,
            v_doc.currency_code,
            case when v_foreign then v_amount end);
  end loop;

  -- ------------------------------------------------------------------ taxes
  for r in
    select s.tax_id, s.tax_code, s.tax_name, s.tax_amount
      from document_tax_summary s
     where s.document_id = p_document_id
       and s.tax_id is not null
       and s.tax_amount <> 0
     order by s.tax_code
  loop
    select t.cash_basis, t.cash_basis_transition_account_id
      into v_cash, v_transition
      from taxes t where t.id = r.tax_id;

    if v_cash then
      -- A tax that waits needs somewhere to wait. Refuse by name rather than
      -- book it on the account it is due on, which would make it due.
      if v_transition is null then
        raise exception 'no_cash_basis_account: tax % falls due on collection and names no transition account',
          r.tax_code;
      end if;
      -- One posting per side, or the transition lines of a document cannot be
      -- told apart when the matching sends each of them on. A tax whose
      -- postings net out has nothing waiting to collect anyway.
      select count(*) into v_postings
        from tax_postings tp
       where tp.tax_id = r.tax_id and tp.document_kind = v_kind
         and tp.posting_type = 'tax';
      if v_postings > 1 then
        raise exception 'cash_basis_split_tax: tax % falls due on collection and has % tax postings; it takes one',
          r.tax_code, v_postings;
      end if;
      if exists (select 1 from tax_postings tp
                  where tp.tax_id = r.tax_id and tp.document_kind = v_kind
                    and tp.posting_type = 'tax_on_base') then
        raise exception 'cash_basis_tax_on_base: tax % falls due on collection and carries a non-deductible share; a cost is not deferred',
          r.tax_code;
      end if;
      -- And it needs a box to fall due *into*. `settle_cash_basis_tax()` only
      -- ever looks at lines that carry a `box_amount`, and a posting with no
      -- `declaration_box` produces none — so the amount would sit on the
      -- transition account for ever, settled by nothing and reported by
      -- nothing, with no error anywhere. Refuse it here, where the pack can
      -- still be corrected, rather than discover it in a balance years later.
      if not exists (select 1 from tax_postings tp
                      where tp.tax_id = r.tax_id and tp.document_kind = v_kind
                        and tp.posting_type = 'tax'
                        and tp.declaration_box is not null) then
        raise exception 'no_cash_basis_box: tax % falls due on collection and its posting names no declaration box; the amount would wait on the transition account and never settle',
          r.tax_code;
      end if;
    end if;

    -- The postings of one side share out the tax of the group; the last of
    -- each side takes what is left. Until `tax_on_base` there was never more
    -- than one posting per side, so this changes no existing tax by a cent —
    -- and it is what keeps a 50/50 split honest: 0.63 becomes 0.32 and 0.31,
    -- where rounding each half on its own would book 0.64 against a document
    -- that totals 0.63.
    v_side_left     := null;
    v_side_left_neg := null;

    for p in
      select tp.posting_type, tp.factor_percent, tp.account_id,
             tp.declaration_box, tp.box_factor_percent,
             case when tp.factor_percent >= 0 then 1 else -1 end as side,
             sum(abs(tp.factor_percent))
               over (partition by case when tp.factor_percent >= 0 then 1 else -1 end)
               as side_factor,
             row_number() over (
               partition by case when tp.factor_percent >= 0 then 1 else -1 end
               order by tp.sequence, tp.id)
             = count(*) over (
               partition by case when tp.factor_percent >= 0 then 1 else -1 end)
               as is_last_of_side
        from tax_postings tp
       where tp.tax_id = r.tax_id
         and tp.document_kind = v_kind
         and tp.posting_type in ('tax', 'tax_on_base')
       order by tp.sequence, tp.id
    loop
      -- The tax of the group was rounded once, in the view. Every posting is
      -- a share of that one figure, never of a re-derived one.
      if p.side >= 0 then
        if v_side_left is null then
          v_side_left := round_amount(r.tax_amount * p.side_factor / 100, v_round);
        end if;
        if p.is_last_of_side then
          v_amount := v_side_left;
        else
          v_amount    := round_amount(r.tax_amount * abs(p.factor_percent) / 100, v_round);
          v_side_left := v_side_left - v_amount;
        end if;
      else
        if v_side_left_neg is null then
          v_side_left_neg := round_amount(r.tax_amount * p.side_factor / 100, v_round);
        end if;
        if p.is_last_of_side then
          v_amount := v_side_left_neg;
        else
          v_amount        := round_amount(r.tax_amount * abs(p.factor_percent) / 100, v_round);
          v_side_left_neg := v_side_left_neg - v_amount;
        end if;
      end if;

      if v_amount = 0 then
        continue;
      end if;
      -- A positive factor keeps the side of the base, a negative one flips it.
      v_side_credit := case when p.factor_percent >= 0 then v_base_credit else not v_base_credit end;
      -- The box keeps its own rounding: `box_factor_percent` was always
      -- independent from `factor_percent`, because a declaration figure is
      -- not a ledger figure and only the ledger has to balance.
      v_box_amount := case when p.declaration_box is null then null
                           else round_amount(r.tax_amount * p.box_factor_percent / 100 / v_rate,
                                             v_book_round) end;
      v_book := round_amount(v_amount / v_rate, v_book_round);

      if p.posting_type = 'tax' then
        v_seq := v_seq + 10;

        insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                                 debit, credit, tax_id, tax_line, posting_type,
                                 declaration_box, box_amount, currency_code, amount_currency)
        values (v_entry.id, v_doc.company_id,
                case when v_cash then v_transition else p.account_id end,
                v_seq, r.tax_name,
                case when v_side_credit then 0 else v_book end,
                case when v_side_credit then v_book else 0 end,
                r.tax_id, true, p.posting_type,
                case when v_cash then null else p.declaration_box end,
                v_box_amount, v_doc.currency_code,
                case when v_foreign then v_amount end);
        continue;
      end if;

      -- `tax_on_base`: the tax is a cost, so it lands on the accounts of the
      -- lines it taxes, split in proportion to their base. The last share
      -- takes whatever is left, so the shares add up to the amount that was
      -- rounded once on the group and the entry still balances to the cent.
      v_left     := v_amount;
      v_left_box := v_box_amount;

      for g in
        select account_id,
               base_amount,
               seq,
               sum(base_amount) over ()                                   as total_base,
               row_number() over (order by seq) = count(*) over ()         as is_last
          from (
            select l.account_id,
                   sum(l.amount_untaxed) as base_amount,
                   min(l.sequence)       as seq
              from document_lines l
             where l.document_id = p_document_id
               and l.line_type = 'product'
               and l.tax_id = r.tax_id
             group by l.account_id
            having sum(l.amount_untaxed) <> 0
          ) as groups
         order by seq
      loop
        if g.is_last then
          v_share     := v_left;
          v_share_box := v_left_box;
        else
          v_share     := round_amount(v_amount * g.base_amount / g.total_base, v_round);
          v_share_box := case when v_box_amount is null then null
                              else round_amount(v_box_amount * g.base_amount / g.total_base,
                                                v_book_round) end;
          v_left      := v_left - v_share;
          v_left_box  := v_left_box - v_share_box;
        end if;

        if v_share = 0 then
          continue;
        end if;

        v_seq := v_seq + 10;
        v_share_book := round_amount(v_share / v_rate, v_book_round);

        -- `tax_line` stays false: the amount is on a base account and belongs
        -- to the base side of the declaration, which is why the Belgian grids
        -- 82 and 83 report it together with the base.
        insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                                 debit, credit, tax_id, tax_line, posting_type,
                                 declaration_box, box_amount, currency_code, amount_currency)
        values (v_entry.id, v_doc.company_id, g.account_id, v_seq, r.tax_name,
                case when v_side_credit then 0 else v_share_book end,
                case when v_side_credit then v_share_book else 0 end,
                r.tax_id, false, p.posting_type,
                p.declaration_box, v_share_box, v_doc.currency_code,
                case when v_foreign then v_share end);
      end loop;
    end loop;
  end loop;

  -- ------------------------------------------------------------ counterpart
  select total_debit - total_credit into v_diff from entries where id = v_entry.id;
  select coalesce(sum(case when l.debit > 0 then l.amount_currency else -l.amount_currency end), 0)
    into v_diff_cur
    from entry_lines l where l.entry_id = v_entry.id;

  if v_diff = 0 then
    raise exception 'document_counterpart_zero: document % produced a nil counterpart', p_document_id;
  end if;

  v_contact := commercial_entity(v_doc.contact_id);
  v_counterpart := resolve_counterpart_account(v_doc.company_id, v_contact, v_is_sale);

  select payment_terms_days into v_terms from contacts where id = v_contact;
  v_maturity := coalesce(v_doc.due_date, v_doc.document_date + coalesce(v_terms, 30));

  v_amount := abs(v_diff);
  -- The counterpart balances the entry in both currencies. The total it is
  -- checked against is the document's own, which is the currency
  -- `amount_total` is stated in.
  v_total_cur := case when v_foreign then abs(v_diff_cur) else v_amount end;
  v_seq := v_seq + 10;

  insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                           debit, credit, contact_id, date_maturity, currency_code,
                           amount_currency)
  values (v_entry.id, v_doc.company_id, v_counterpart, v_seq, v_label,
          case when v_diff > 0 then 0 else v_amount end,
          case when v_diff > 0 then v_amount else 0 end,
          v_contact, v_maturity, v_doc.currency_code,
          case when v_foreign then v_total_cur end);

  -- The ledger is right by construction. If the header disagrees, the header
  -- is what is wrong, and we say so instead of quietly patching a line.
  -- Half a unit of the document's own currency, which is what `0.005` used to
  -- mean when every currency was assumed to have cents.
  if abs(v_total_cur - abs(v_doc.amount_total)) > currency_unit(v_round) / 2 then
    raise exception 'document_total_mismatch: document % totals % but its lines book %',
      p_document_id, v_doc.amount_total, v_total_cur;
  end if;

  -- --------------------------------------------------------------- posting
  v_entry := post_entry(v_entry.id);

  update documents
     set state  = 'posted',
         number = coalesce(number, v_entry.number),
         entry_id = v_entry.id,
         accounting_date = v_date
   where id = p_document_id;

  return v_entry;
end;
$$;

-- The transfer that makes a cash-basis tax due. Both legs carry the posting
-- that falls due: the one that lands on the account and the box it is declared
-- on, and the one that empties the transition account it waited on.

create or replace function settle_cash_basis_tax(
  p_document_id uuid,
  p_date        date
)
returns uuid
language plpgsql
as $$
declare
  v_doc       documents%rowtype;
  v_company   companies%rowtype;
  v_entry     entries%rowtype;
  v_kind      tax_document_kind;
  v_total     numeric;
  v_paid      numeric;
  v_ratio     numeric;
  v_seq       integer := 0;
  v_final     uuid;
  v_box       text;
  v_target    uuid;
  v_due       numeric;
  v_done      numeric;
  v_delta     numeric;
  v_box_due   numeric;
  v_box_done  numeric;
  v_box_delta numeric;
  -- The transfer is written in the ledger's currency on both sides, which is
  -- the company's own: the entry it produces says so.
  v_round     money_rounding;
  v_credit    boolean;
  v_type      tax_posting_type;
  w           record;
begin
  select * into v_doc from documents where id = p_document_id;
  if not found or v_doc.entry_id is null then
    return null;
  end if;

  -- Nothing is waiting on this document: the answer for every tax that falls
  -- due when it is invoiced, which is most of them.
  if not exists (
    select 1
      from entry_lines q join taxes t on t.id = q.tax_id
     where q.entry_id = v_doc.entry_id
       and t.cash_basis
       and q.declaration_box is null
       and q.box_amount is not null
  ) then
    return null;
  end if;

  select * into v_company from companies where id = v_doc.company_id;
  v_round := rounding_of(v_doc.company_id);
  if v_company.miscellaneous_journal_id is null then
    raise exception 'no_miscellaneous_journal: company % has no journal for the transfer of a cash-basis tax',
      v_doc.company_id;
  end if;

  v_kind := case when v_doc.doc_type in ('sale_credit_note', 'purchase_credit_note')
                 then 'credit_note' else 'invoice' end::tax_document_kind;

  -- What share of this document has been settled, read on its own third-party
  -- lines and in the ledger's currency on both sides of the division.
  select coalesce(sum(abs(tl.debit - tl.credit)), 0), coalesce(sum(tl.matched_amount), 0)
    into v_total, v_paid
    from entry_lines tl join accounts a on a.id = tl.account_id
   where tl.entry_id = v_doc.entry_id
     and a.reconcilable
     and a.account_type in ('asset_receivable', 'liability_payable');

  if v_total = 0 then
    return null;
  end if;
  -- An overpayment settles the document, and no more: a tax is due on what
  -- was invoiced.
  v_ratio := least(1, greatest(0, v_paid / v_total));

  for w in
    select l2.id, l2.account_id, l2.tax_id, l2.tax_line, l2.box_amount,
           l2.debit, l2.credit, l2.name, l2.sequence
      from entry_lines l2 join taxes t on t.id = l2.tax_id
     where l2.entry_id = v_doc.entry_id
       and t.cash_basis
       and l2.declaration_box is null
       and l2.box_amount is not null
     order by l2.sequence
  loop
    select tp.account_id, tp.declaration_box, tp.posting_type
      into v_final, v_box, v_type
      from tax_postings tp
     where tp.tax_id = w.tax_id
       and tp.document_kind = v_kind
       and tp.posting_type = (case when w.tax_line then 'tax' else 'base' end)::tax_posting_type
     limit 1;

    -- The account the transfer of this line lands on, which is also how an
    -- earlier transfer of the same line is recognised.
    v_target := case when w.tax_line then v_final else w.account_id end;
    if v_target is null then
      raise exception 'no_cash_basis_target: the tax of line % names no account to fall due on', w.id;
    end if;
    -- A line only waits because a box was worked out for it, and that box came
    -- from this very posting. If it has none, the amount would wait for ever.
    if v_box is null then
      raise exception 'no_cash_basis_box: the tax of line % holds an amount for a box the posting does not name', w.id;
    end if;

    if w.tax_line then
      v_due := round_amount((w.debit + w.credit) * v_ratio, v_round);
      select coalesce(sum(case when w.credit > 0 then x.credit - x.debit
                               else x.debit - x.credit end), 0)
        into v_done
        from entry_lines x join entries e on e.id = x.entry_id
       where e.document_id = p_document_id
         and e.id <> v_doc.entry_id
         and x.tax_id = w.tax_id
         and x.tax_line
         and x.account_id = v_target;
    else
      v_due  := 0;
      v_done := 0;
    end if;
    v_delta := v_due - v_done;

    v_box_due := round_amount(w.box_amount * v_ratio, v_round);
    select coalesce(sum(x.box_amount), 0)
      into v_box_done
      from entry_lines x join entries e on e.id = x.entry_id
     where e.document_id = p_document_id
       and e.id <> v_doc.entry_id
       and x.tax_id = w.tax_id
       and x.tax_line = w.tax_line
       and x.account_id = v_target;
    v_box_delta := v_box_due - v_box_done;

    if v_delta = 0 and v_box_delta = 0 then
      continue;
    end if;

    if v_entry.id is null then
      insert into entries (company_id, journal_id, fiscal_year_id, entry_date, reference,
                           description, state, document_id, currency_code)
      values (v_doc.company_id, v_company.miscellaneous_journal_id,
              fiscal_year_at(v_doc.company_id, p_date), p_date,
              v_doc.number,
              coalesce(v_doc.number, 'document') || ' — tax due on settlement',
              'draft', p_document_id, v_company.currency_code)
      returning * into v_entry;
    end if;

    -- The side the document put the tax on, kept when the share grows and
    -- flipped when it shrinks.
    v_credit := (w.credit > 0) = (v_delta > 0);

    v_seq := v_seq + 10;
    insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                             debit, credit, tax_id, tax_line, posting_type,
                             declaration_box, box_amount, currency_code)
    values (v_entry.id, v_doc.company_id, v_target, v_seq, w.name,
            case when v_credit then 0 else abs(v_delta) end,
            case when v_credit then abs(v_delta) else 0 end,
            w.tax_id, w.tax_line, v_type,
            v_box, v_box_delta,
            v_company.currency_code);

    if v_delta <> 0 then
      v_seq := v_seq + 10;
      insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                               debit, credit, tax_id, tax_line, posting_type, currency_code)
      values (v_entry.id, v_doc.company_id, w.account_id, v_seq, w.name,
              case when v_credit then abs(v_delta) else 0 end,
              case when v_credit then 0 else abs(v_delta) end,
              w.tax_id, true, v_type, v_company.currency_code);
    end if;
  end loop;

  if v_entry.id is null then
    return null;
  end if;

  v_entry := post_entry(v_entry.id);
  return v_entry.id;
end;
$$;

-- ---------------------------------------------------------------------------
-- The reader that asked for the column
-- ---------------------------------------------------------------------------
--
-- `ec_sales_list()` took every line of an intra-Community tax that is not a tax
-- line, and a `tax_on_base` line is one of those. It is exact on every pack of
-- this repository — an exempt supply has no tax to capitalise — and it was
-- exact by luck. Now it says what it means, and it says it in a way that is
-- also right about a ledger written before the column existed: a line is
-- excluded when it is **known** to be a `tax_on_base` line, and a null keeps
-- the reading it had, which is the one the backfill above refused to improve
-- on. The rest of the function is `20260916094500` unchanged, period guard
-- included.

create or replace function ec_sales_list(
  p_company_id  uuid,
  p_from        date,
  p_to          date,
  p_report_code text default null
)
returns table (
  vat_country   char(2),
  vat_number    text,
  nature        text,
  amount        numeric,
  currency_code char(3),
  documents     integer,
  contact_ids   uuid[],
  contact_names text[],
  issue         text
)
language plpgsql
stable
as $$
declare
  v_country  char(2);
  v_prefix   char(2);
  v_currency char(3);
  v_round    money_rounding;
  v_files    declaration_period;
  v_accepts  declaration_period[];
  v_asked    declaration_period;
begin
  select c.fiscal_country, c.currency_code into v_country, v_currency
    from companies c where c.id = p_company_id;
  if not found then
    raise exception 'unknown_company: %', p_company_id;
  end if;
  if not exists (select 1 from territories) then
    raise exception 'no_territories: apply supabase/seed/00_territories.sql';
  end if;

  -- Which period this is, when the caller said which statement they are
  -- filing. Five things have to hold: a form was named, it exists, the company
  -- has recorded a cadence for it, the dates are themselves a whole cadence the
  -- form is filed on, and the two differ. A monthly statement from a quarterly
  -- filer is the ordinary case in three of the four countries read while this
  -- was written, and nothing here touches it: the cadence read is the
  -- statement's own.
  if p_report_code is not null then
    select t.periods into v_accepts
      from tax_report_templates t
     where t.code = p_report_code
       and t.valid_from <= p_to
       and (t.valid_to is null or t.valid_to >= p_to)
     order by t.country
     limit 1;
    if v_accepts is null then
      raise exception 'unknown_tax_report: % is not a declaration form in force on %',
        p_report_code, p_to;
    end if;
    v_files := filing_period(p_company_id, p_report_code);
    v_asked := declaration_period_of(p_from, p_to);
    if v_files is not null
       and v_asked is not null
       and v_files = any(v_accepts)
       and v_asked = any(v_accepts)
       and v_asked <> v_files then
      raise exception
        'wrong_declaration_period: this company files % on %; % to % is a %',
        v_files, p_report_code, p_from, p_to, v_asked;
    end if;
  end if;

  v_prefix := vat_prefix_of(v_country);
  v_round  := rounding_of(p_company_id);

  return query
  with supply as (
    select d.contact_id,
           ct.name                                              as contact_name,
           regexp_replace(t.treatment::text, '^intracom_', '')   as nature,
           upper(regexp_replace(coalesce(ct.vat_number, ''), '[^A-Za-z0-9]', '', 'g')) as vat_raw,
           ct.country                                           as contact_country,
           e.entry_date,
           e.document_id,
           l.credit - l.debit                                   as amount
      from entry_lines l
      join entries  e  on e.id = l.entry_id
      join taxes    t  on t.id = l.tax_id
      left join documents d on d.id = e.document_id
      left join contacts  ct on ct.id = d.contact_id
     where l.company_id = p_company_id
       and e.state = 'posted'
       and e.entry_date between p_from and p_to
       and not l.tax_line
       -- A line known to have been written by a `tax_on_base` posting is a
       -- cost and not a supply. Null is left in, because a ledger written
       -- before `posting_type` existed reads exactly as it did.
       and l.posting_type is distinct from 'tax_on_base'::tax_posting_type
       and t.treatment::text like 'intracom!_%' escape '!'
       and t.treatment::text not like 'intracom!_acquisition!_%' escape '!'
  ),
  keyed as (
    select s.*,
           vat_prefix_of(
             case when s.vat_raw ~ '^[A-Z]{2}' then substring(s.vat_raw from 1 for 2)
                  when s.vat_raw = ''          then null
                  else s.contact_country
             end
           ) as vat_country,
           case when s.vat_raw = ''          then null
                when s.vat_raw ~ '^[A-Z]{2}' then substring(s.vat_raw from 3)
                else s.vat_raw
           end as vat_number
      from supply s
  ),
  scoped as (
    select k.*, eu_vat_scope_of(k.vat_country, k.entry_date) as scope
      from keyed k
  ),
  judged as (
    select s.*,
           case
             when s.contact_id is null                        then 'no_customer'
             when s.vat_number is null or s.vat_number = ''   then 'no_vat_number'
             when s.vat_country is null                       then 'no_vat_country'
             when s.vat_country = v_prefix                    then 'vat_country_is_the_company_country'
             when s.scope = 'none'                            then 'vat_country_outside_the_union'
             when s.scope <> 'full' and s.nature = 'services'
                                                              then 'vat_country_outside_the_union_for_this_supply'
           end as issue
      from scoped s
  )
  select j.vat_country::char(2),
         j.vat_number,
         j.nature,
         round_amount(sum(j.amount), v_round),
         v_currency,
         count(distinct j.document_id)::integer,
         array_agg(distinct j.contact_id)   filter (where j.contact_id is not null),
         array_agg(distinct j.contact_name) filter (where j.contact_name is not null),
         j.issue
    from judged j
   group by j.vat_country, j.vat_number, j.nature, j.issue,
            case when j.issue is not null then j.contact_id end
  having round_amount(sum(j.amount), v_round) <> 0
   order by (j.issue is not null), j.vat_country, j.vat_number, j.nature;
end;
$$;

comment on function ec_sales_list(uuid, date, date, text) is
  'The recapitulative statement of intra-Community supplies for a period: one line per customer VAT identification number and per nature — goods, services, and whatever the treatment vocabulary gains next — summed from the posted ledger in the company''s currency, credit notes deducted. The country of a line is the prefix the customer''s numbers carry, read from `territories`, so a Greek customer is listed under EL. A supply that cannot be declared comes back with the reason in `issue` rather than being left out. Name the form in p_report_code to have the period checked against the cadence this company files **that statement** on, which is not the cadence of its periodic return in any country read so far; name none and nothing is refused. A supply is a base line of the tax: a line a `tax_on_base` posting wrote is a cost and is left out. No country rule lives in this function.';

revoke execute on function ec_sales_list(uuid, date, date, text) from public, anon;
grant  execute on function ec_sales_list(uuid, date, date, text) to authenticated, service_role;
