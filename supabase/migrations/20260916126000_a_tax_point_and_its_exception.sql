-- Ekwo OS — a tax point the law can be written in, and an engine that reads it.
--
-- `country_defaults.tax_point_rule` has been a single word since
-- `20260912111751` — `invoice_date`, `delivery_date`, `payment_date` — and two
-- things were true of it. No function read it: `docs/decisions.md` recorded
-- the column as "declared, no reader", and `post_document()` dated a tax by
-- the day the entry was booked on, which is a different question. And two
-- packs could not say their own law in one word, which their own citations
-- already admitted.
--
-- **Luxembourg.** Art. 21 of the modified law of 12 February 1979: "Le fait
-- générateur de la taxe intervient et la taxe devient exigible au moment où la
-- livraison de biens ou la prestation de services est effectuée." The invoice
-- is art. 24, par. 1er: "Par dérogation aux articles 21, 22 et 23, lorsqu'il y
-- a obligation d'émettre une facture, la taxe devient exigible : a) lors de
-- l'émission de la facture si elle est émise dans le délai visé à l'article
-- 63, paragraphe 5 ; b) le jour où expire le délai visé au point a) en
-- l'absence d'émission de la facture dans ce délai." The pack declared
-- `invoice_date`, which is the derogation given as if it were the principle.
--
-- **Belgium is the same shape**, and nobody had looked. Art. 16, § 1er and
-- art. 22, § 1er put the fait générateur and the exigibility at the moment of
-- the supply; art. 17, § 1er and art. 22bis, § 1er derogate — "au moment de
-- l'émission de la facture, à concurrence du montant facturé, peu importe que
-- l'émission de cette facture ait lieu avant ou après le moment où la
-- livraison est effectuée", with the fifteenth day of the following month
-- where no invoice was issued before it. The pack's citation said all of this
-- and the word said `invoice_date`.
--
-- **Estonia.** KMS § 11 lg 1, in the official English translation: "The time
-- of supply or the time of receipt of services is deemed to be the date on
-- which the **first** of one of the following acts is performed: 1) the goods
-- are dispatched or made available to the purchaser, or the services are
-- provided; 2) full or partial payment is received for the goods or services
-- […]". Two branches, and the pack declared the first one. The invoice is
-- **not** a branch of lg 1 — it belongs to lg 2, which is the separate rule
-- for intra-Community supply — so the rule Estonia keeps is the earliest of a
-- supply and a payment, and nothing else.
--
-- **France was read and is right as it stands.** CGI art. 269, 1, a puts the
-- fait générateur at the supply and art. 269, 2, a makes the tax chargeable
-- then, an acompte advancing it to the amount received; services are art. 269,
-- 2, c, chargeable on collection unless the taxpayer opts for the débits, and
-- that half is `taxes.cash_basis` on the service taxes by a decision this
-- repository already wrote down. `delivery_date` is France's principle.
--
-- ---------------------------------------------------------------------------
-- What this migration does
-- ---------------------------------------------------------------------------
--
-- **Two words, and the vocabulary stays closed.** `invoice_if_issued` is the
-- Luxembourg and Belgian shape: the supply is the principle, an invoice
-- displaces it where the country requires one and one was issued.
-- `earliest_of_delivery_or_payment` is the Estonian shape: whichever of the
-- two happened first. Both say what they mean in their own name, which is the
-- rule `applies_when` set for a closed vocabulary — an accountant reads the
-- value and knows what it is — and neither is an expression a pack could
-- write a condition in.
--
-- **One reader, named.** `tax_point_of()` is the only function that reads
-- `country_defaults.tax_point_rule`, the way `numbering_rules()` is the only
-- one that reads `number_format`. The vocabulary is a `case` inside it and
-- nowhere else; `post_document()` calls it and knows no country.
--
-- **Two columns, because a tax point is not an accounting date.** A December
-- invoice booked in January is one entry on one date and a tax due in
-- December, and the ledger has to be able to say both. `documents.tax_point_date`
-- is EN 16931's BT-7, which the table lacked and which an e-invoice carries;
-- where it is filled it is the answer, because a rule is a default and a
-- stated fact is not. `entry_lines.tax_point_date` is what the declaration
-- reads, beside the `declaration_box` and the `box_amount` already there.
--
-- **Null is the reading of every ledger written before today.** No backfill
-- and no default: a line with no tax point is declared on its entry's date,
-- which is what `vat_return()` did for every line until this file. So the
-- goldens of the six packs do not move — none of their documents carries a
-- delivery date or an accounting date apart from its own — and the change is
-- visible only where a document says something the engine could not read
-- before.
--
-- **Where the payment branch stops.** `post_document()` passes no payment
-- date, and it is not an omission: matching is recorded against the entry
-- this function is writing, so at posting time no payment of this document
-- exists. A rule whose earliest branch is a payment therefore falls back on
-- the branch it can see, and the payment half is honoured only where the tax
-- itself says `cash_basis` — `settle_cash_basis_tax()`, which now writes the
-- collection date onto both legs of its transfer instead of leaving the
-- entry's date to speak for it. A prepayment that is not a cash-basis tax is a
-- document Ekwo does not have; `docs/international.md` says so under its own
-- heading rather than this file inventing one.
--
-- ---------------------------------------------------------------------------
-- The other half of ST31: a source that reaches the database
-- ---------------------------------------------------------------------------
--
-- `20260915161842` turned `certification.sources` into a register and gave
-- `tax_templates` and `tax_report_box_templates` a `source_key`. Three places
-- were left: a chart, a statement and a statement line each name a `source` in
-- the pack and had nowhere to put it, so `legal_reference` reached the
-- database with no way to open the text behind it. Three nullable columns,
-- filled by the compiled seed like the two before them, no backfill and no
-- foreign key — `ekwo pack check` is where an unknown key is refused, because
-- the register lives in a jsonb column of another table.

-- ---------------------------------------------------------------------------
-- The vocabulary widens
-- ---------------------------------------------------------------------------
--
-- Dropped and re-added rather than edited: the constraint of `20260912111751`
-- is published, and this is the migration that changes it.

alter table country_defaults
  drop constraint if exists country_defaults_tax_point_rule_known;

alter table country_defaults
  add constraint country_defaults_tax_point_rule_known
    check (tax_point_rule is null or tax_point_rule in (
      'invoice_date',
      'delivery_date',
      'payment_date',
      'invoice_if_issued',
      'earliest_of_delivery_or_payment'
    ));

comment on column country_defaults.tax_point_rule is
  'When the tax becomes chargeable under this country''s general rule, in a closed vocabulary: invoice_date (the invoice fixes it), delivery_date (the supply fixes it), payment_date (collection fixes it), invoice_if_issued (the supply is the principle and an invoice displaces it where the country requires one — Belgium art. 17 and 22bis, Luxembourg art. 24), earliest_of_delivery_or_payment (whichever came first — Estonia KMS § 11 lg 1). A tax that departs from the country rule says so itself, with cash_basis. tax_point_of() is the only function that reads this column.';

-- ---------------------------------------------------------------------------
-- Where a tax point is written down
-- ---------------------------------------------------------------------------

alter table documents
  add column if not exists tax_point_date date;                 -- BT-7

comment on column documents.tax_point_date is
  'EN 16931 BT-7: the day the tax on this document falls due, which is not the day the entry is booked on. Given on the document it is kept — an e-invoice states its own tax point and a stated fact outranks a rule — and left null it is worked out by post_document() from the country rule and written back here.';

alter table entry_lines
  add column if not exists tax_point_date date;

comment on column entry_lines.tax_point_date is
  'The day the tax of this line fell due, from the document''s tax point or, on the transfer that makes a cash-basis tax due, from the collection. It is the date vat_return() puts the figure in a period by. Null on a line no tax posting wrote and on every line written before this column existed: the entry''s own date then answers, which is the reading the declaration always had.';

-- ---------------------------------------------------------------------------
-- The one reader of the country rule
-- ---------------------------------------------------------------------------
--
-- Deliberately not `immutable`: it reads two tables. `stable` is what
-- `numbering_rules()` is, for the same reason.
--
-- The dates it is given are the document's own. `p_document_date` is the
-- invoice date and is never null on a document; `p_delivery_date` is BT-72 and
-- usually is; `p_payment_date` is the day the price was received where that is
-- already known, and null where it is not.
--
-- A country that declares no rule gets null, not a borrowed one. That is
-- invariant 2 of `CONTRIBUTING.md`: there is no fallback country, and a reader
-- that needs a value a pack did not give says so rather than answering with
-- another country's law. Null here means "the entry's date", which is what the
-- declaration read before any of this existed, so a pack that says nothing
-- loses nothing.

create or replace function tax_point_of(
  p_company_id    uuid,
  p_document_date date,
  p_delivery_date date default null,
  p_payment_date  date default null
)
returns date
language sql
stable
as $$
  select case d.tax_point_rule
           -- The invoice fixes it, full stop.
           when 'invoice_date'  then p_document_date
           -- The supply fixes it. A document that does not say when it was
           -- delivered is one where the invoice is all there is to go on.
           when 'delivery_date' then coalesce(p_delivery_date, p_document_date)
           -- Collection fixes it, and until there is one there is no answer.
           when 'payment_date'  then p_payment_date
           -- The supply is the principle and the invoice is the derogation.
           -- A document being booked here is an invoice and carries its date,
           -- so the derogation applies; the delivery is what is left when it
           -- does not.
           when 'invoice_if_issued' then coalesce(p_document_date, p_delivery_date)
           -- Whichever of the two came first. `least` ignores a null, which is
           -- exactly right: a branch nobody can date is a branch that has not
           -- happened.
           when 'earliest_of_delivery_or_payment'
             then least(coalesce(p_delivery_date, p_document_date), p_payment_date)
           else null
         end
    from companies c
    left join country_defaults d on d.country = c.fiscal_country
   where c.id = p_company_id;
$$;

comment on function tax_point_of(uuid, date, date, date) is
  'The day the tax on a document falls due, under the rule its company''s country declares. The only function that reads country_defaults.tax_point_rule, and the only place the vocabulary of that column is written out. Null where the country declares no rule or where the rule names a date the caller does not have, and null means the entry''s own date to every reader of it.';

revoke execute on function tax_point_of(uuid, date, date, date) from public, anon;
grant  execute on function tax_point_of(uuid, date, date, date) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Three columns so that a compiled reference can be opened
-- ---------------------------------------------------------------------------

alter table chart_templates
  add column if not exists source_key text;

comment on column chart_templates.source_key is
  'Key of the entry in country_packs.sources where this chart''s legal_reference can be read. Null where the pack names none.';

alter table statement_templates
  add column if not exists source_key text;

comment on column statement_templates.source_key is
  'Key of the entry in country_packs.sources where this statement''s legal_reference can be read. Null where the pack names none.';

alter table statement_line_templates
  add column if not exists source_key text;

comment on column statement_line_templates.source_key is
  'Key of the entry in country_packs.sources where this line''s legal_reference can be read. Null where the pack names none.';

-- No table, view or sequence is created above: a column added to a table is
-- reachable by whoever could already select it, under the policies it already
-- has. The one object created is `tax_point_of()`, and it carries its own
-- revoke and grant.

-- ---------------------------------------------------------------------------
-- post_document() reads the country rule
-- ---------------------------------------------------------------------------
--
-- Replaced whole, because a function is replaced whole in PostgreSQL.
-- Everything but the tax point is `20260916103000` unchanged.

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
  -- The day the tax falls due, which is not the day the entry is booked on.
  v_tax_point  date;
  v_postings   integer;
  -- Where the three parties of this document are, resolved once and only when
  -- a tax on it asks. `document_territory()` is the ladder.
  v_terr_seller text;
  v_terr_buyer  text;
  v_terr_supply text;
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

  -- Every tax that names a territory must find the parties where it says they
  -- are. This is the one thing the core may do with a territory condition: it
  -- refuses a tax that cannot apply, and it never chooses, substitutes or
  -- suggests one — the core picks no tax for anybody, in any country.
  --
  -- The resolution is skipped entirely where nothing asks, which is every
  -- document of every pack written before this migration.
  if exists (
    select 1
      from document_lines l
      join taxes t on t.id = l.tax_id
     where l.document_id = p_document_id
       and (t.applies_seller_territory is not null
         or t.applies_buyer_territory  is not null
         or t.applies_supply_territory is not null)
  ) then
    v_terr_seller := document_territory(p_document_id, 'seller');
    v_terr_buyer  := document_territory(p_document_id, 'buyer');
    v_terr_supply := document_territory(p_document_id, 'supply');

    for r in
      select distinct t.code,
             t.applies_seller_territory as seller,
             t.applies_buyer_territory  as buyer,
             t.applies_supply_territory as supply
        from document_lines l
        join taxes t on t.id = l.tax_id
       where l.document_id = p_document_id
         and (t.applies_seller_territory is not null
           or t.applies_buyer_territory  is not null
           or t.applies_supply_territory is not null)
       order by 1
    loop
      for p in
        select v.party, v.wanted, v.actual, v.hint
          from (values
            ('seller', r.seller, v_terr_seller,
             'territory_code on the party that sells, or the country beside it'),
            ('buyer',  r.buyer,  v_terr_buyer,
             'territory_code on the party that buys, or the country beside it'),
            ('supply', r.supply, v_terr_supply,
             'supply_territory_code or delivery_country on the document')
          ) as v (party, wanted, actual, hint)
         where v.wanted is not null
         order by v.party
      loop
        if p.actual is null then
          raise exception 'no_party_territory: tax % applies where the % is in %, and nothing on this document says where the % is; set %',
            r.code, p.party, p.wanted, p.party, p.hint;
        end if;
        if not territory_within(p.actual, p.wanted) then
          raise exception 'tax_territory_mismatch: tax % applies where the % is in %; on this document the % is in %',
            r.code, p.party, p.wanted, p.party, p.actual;
        end if;
      end loop;
    end loop;
  end if;

  -- Totals are derived; make sure they reflect the lines as they stand now.
  perform documents_refresh_totals(p_document_id);
  select * into v_doc from documents where id = p_document_id;

  select c.currency_code into v_home from companies c where c.id = v_doc.company_id;
  v_rate    := v_doc.exchange_rate;
  v_foreign := v_doc.currency_code <> v_home;
  v_round      := rounding_of(v_doc.company_id, v_doc.currency_code);
  v_book_round := rounding_of(v_doc.company_id);

  -- When the tax on this document falls due, under the rule its country
  -- declares. A document that carries BT-7 has been told and nobody overrides
  -- it; otherwise `tax_point_of()` reads the country's word. The payment
  -- argument is null here and says so: matching needs the entry this function
  -- is writing, so at posting time no payment of this document has been
  -- recorded, and a rule whose earliest branch is a payment falls back on the
  -- branch it can see. Null comes back where the rule is `payment_date` or the
  -- country declared none, and null on a line means "the entry's own date",
  -- which is the reading every ledger written before this one had.
  v_tax_point := coalesce(
    v_doc.tax_point_date,
    tax_point_of(v_doc.company_id, v_doc.document_date, v_doc.delivery_date, null));

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
                             declaration_box, box_amount, tax_point_date,
                             currency_code, amount_currency)
    values (v_entry.id, v_doc.company_id, r.account_id, v_seq, left(r.label, 200),
            case when v_base_credit then 0 else v_book end,
            case when v_base_credit then v_book else 0 end,
            r.tax_id, false, p.posting_type,
            case when coalesce(p.cash_basis, false) then null else p.declaration_box end,
            case when p.declaration_box is null then null
                 else round_amount(r.base_amount * coalesce(p.box_factor_percent, 100) / 100 / v_rate,
                                   v_book_round) end,
            v_tax_point,
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
                                 declaration_box, box_amount, tax_point_date,
                                 currency_code, amount_currency)
        values (v_entry.id, v_doc.company_id,
                case when v_cash then v_transition else p.account_id end,
                v_seq, r.tax_name,
                case when v_side_credit then 0 else v_book end,
                case when v_side_credit then v_book else 0 end,
                r.tax_id, true, p.posting_type,
                case when v_cash then null else p.declaration_box end,
                v_box_amount, v_tax_point, v_doc.currency_code,
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
                                 declaration_box, box_amount, tax_point_date,
                                 currency_code, amount_currency)
        values (v_entry.id, v_doc.company_id, g.account_id, v_seq, r.tax_name,
                case when v_side_credit then 0 else v_share_book end,
                case when v_side_credit then v_share_book else 0 end,
                r.tax_id, false, p.posting_type,
                p.declaration_box, v_share_box, v_tax_point, v_doc.currency_code,
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
         accounting_date = v_date,
         tax_point_date  = v_tax_point
   where id = p_document_id;

  return v_entry;
end;
$$;


-- ---------------------------------------------------------------------------
-- The transfer that makes a cash-basis tax due says so on its lines
-- ---------------------------------------------------------------------------
--
-- Replaced whole for the same reason. Both legs carry the collection date:
-- the one that lands on the account and the box it is declared in, and the one
-- that empties the transition account the amount waited on. They are one
-- posting falling due, so they carry one tax point. Everything else is
-- `20260916103000` unchanged.

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
                             declaration_box, box_amount, tax_point_date, currency_code)
    values (v_entry.id, v_doc.company_id, v_target, v_seq, w.name,
            case when v_credit then 0 else abs(v_delta) end,
            case when v_credit then abs(v_delta) else 0 end,
            w.tax_id, w.tax_line, v_type,
            v_box, v_box_delta,
            -- A tax that waits falls due on the day it is collected, and that
            -- is the date this transfer carries. Saying it on the line rather
            -- than leaving the entry's date to speak for it is what lets the
            -- declaration read one column for every tax point there is.
            p_date,
            v_company.currency_code);

    if v_delta <> 0 then
      v_seq := v_seq + 10;
      insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                               debit, credit, tax_id, tax_line, posting_type,
                               tax_point_date, currency_code)
      values (v_entry.id, v_doc.company_id, w.account_id, v_seq, w.name,
              case when v_credit then abs(v_delta) else 0 end,
              case when v_credit then 0 else abs(v_delta) end,
              w.tax_id, true, v_type, p_date, v_company.currency_code);
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
-- The declaration reads the day the tax fell due
-- ---------------------------------------------------------------------------
--
-- Replaced whole for the same reason. One filter moves: a figure belongs to
-- the period its tax fell due in, and the entry's date answers only where the
-- line has nothing to say. Everything else is `20260916094500` unchanged,
-- cadence guard included.
--
-- `ec_sales_list()` is deliberately **not** changed with it. The recapitulative
-- statement declares an intra-Community supply, and the moment that arises is
-- its own article in both countries read here — KMS § 11 lg 2 in Estonia, art.
-- 17, § 2 in Belgium — neither of which is the rule `tax_point_rule` carries.
-- Moving the statement onto a date computed from the general rule would make
-- it wrong in a new way. `docs/international.md` records it as a gap.

create or replace function vat_return(
  p_company_id  uuid,
  p_from        date,
  p_to          date,
  p_report_code text default null
)
returns table (
  box            text,
  kind           text,
  amount         numeric,
  computed       boolean,
  name           text,
  sequence       integer,
  print_sequence integer,
  hidden         boolean,
  report_code    text
)
language plpgsql
stable
as $$
declare
  -- 'box|kind' -> amount, for every box summed from the ledger, then the
  -- totals `evaluate_totals()` derives from them. The key carries the kind
  -- because the French CA3 puts a base and a tax on line 08 and a formula has
  -- to be able to name one of them.
  v_values   jsonb := '{}'::jsonb;
  v_formulas jsonb := '[]'::jsonb;
  v_totals   jsonb := '{}'::jsonb;
  v_rows     jsonb := '[]'::jsonb;
  v_country  char(2);
  v_report   text;
  v_in       char(2);
  v_count    integer;
  v_codes    text;
  -- How often this company files, what the form accepts, and what the two
  -- dates asked for actually are.
  v_files    declaration_period;
  v_accepts  declaration_period[];
  v_asked    declaration_period;
  -- A declaration figure is not a ledger figure, but it is written in the
  -- same currency and with the same decimals.
  v_round    money_rounding;
  r          record;
begin
  select c.fiscal_country into v_country
    from companies c where c.id = p_company_id;
  if not found then
    raise exception 'unknown_company: %', p_company_id;
  end if;
  v_round := rounding_of(p_company_id);

  -- Which form. The caller names one, or the country files exactly one on
  -- that date. Two and no name is a question only the caller can answer — a
  -- Canadian company files the federal return and the Québec one at once — so
  -- this asks instead of guessing.
  if p_report_code is not null then
    select t.country, t.code into v_in, v_report
      from tax_report_templates t
     where t.code = p_report_code
       and t.valid_from <= p_to
       and (t.valid_to is null or t.valid_to >= p_to)
     order by t.country
     limit 1;
    if v_report is null then
      raise exception 'unknown_tax_report: % is not a declaration form in force on %',
        p_report_code, p_to;
    end if;
  else
    select count(*), min(t.code), string_agg(t.code, ', ' order by t.code)
      into v_count, v_report, v_codes
      from tax_report_templates t
     where t.country = v_country
       and t.is_periodic_return
       and t.valid_from <= p_to
       and (t.valid_to is null or t.valid_to >= p_to);
    if v_count > 1 then
      raise exception 'ambiguous_tax_report: % files several declarations on % (%); name one',
        v_country, p_to, v_codes;
    end if;
    v_in := v_country;
    if v_count = 0 then
      v_report := null;  -- no pack for this country: the ledger boxes, and no total.
    end if;
  end if;

  -- The period asked for against the one this company files **this form** on.
  -- Four things have to hold before this refuses, and the fourth is what keeps
  -- it out of everybody's way: the company has recorded a cadence for this
  -- declaration, the form is filed on that cadence, the dates are themselves a
  -- whole cadence of that form, and the two are not the same. A fortnight, a
  -- half-year, a form the company has recorded nothing about — none of those is
  -- a filing on the wrong cadence, and none of them is refused.
  if v_report is not null then
    v_files := filing_period(p_company_id, v_report);
    if v_files is not null then
      select t.periods into v_accepts
        from tax_report_templates t
       where t.country = v_in and t.code = v_report;
      v_asked := declaration_period_of(p_from, p_to);
      if v_asked is not null
         and v_files = any(v_accepts)
         and v_asked = any(v_accepts)
         and v_asked <> v_files then
        raise exception
          'wrong_declaration_period: this company files % returns on %; % to % is a %',
          v_files, v_report, p_from, p_to, v_asked;
      end if;
    end if;
  end if;

  -- 1. What the tax postings wrote on the ledger, in every box each of them
  --    names. A line carries the box it is known by; the posting behind it
  --    carries the whole list, which is one box for all but the handful of
  --    forms that print a figure twice. No country rule here either: the
  --    expansion is `unnest`, and which boxes there are is the pack's answer.
  for r in
    with lines as (
      select l.declaration_box as lbox,
             case when l.tax_line then 'tax' else 'base' end as lkind,
             l.tax_id as ltax,
             l.box_amount as lamount
        from entry_lines l
        join entries e on e.id = l.entry_id
       where l.company_id = p_company_id
         and e.state = 'posted'
         -- The period a figure belongs to is the day its tax fell due, and
         -- that is the line's own `tax_point_date` where one was worked out.
         -- Null is every line written before the column existed and every line
         -- of a country that declares no rule: the entry's date, exactly as
         -- before.
         and coalesce(l.tax_point_date, e.entry_date) between p_from and p_to
         and l.declaration_box is not null
    ),
    -- The posting that wrote the line: which form it is on, and every box it
    -- prints in. A line with no posting behind it — an entry keyed by hand,
    -- a tax a company wrote itself — is on this form and in the one box it
    -- names, which is what the left join leaves.
    sourced as (
      select ln.lbox, ln.lkind, ln.lamount,
             coalesce(p.boxes, array[ln.lbox]) as lboxes
        from lines ln
        left join lateral (
          select min(tp.report_code) as report_code,
                 array_agg(distinct b.box) as boxes
            from tax_postings tp
            cross join lateral unnest(tp.declaration_boxes) as b(box)
           where tp.tax_id = ln.ltax
             and tp.declaration_box = ln.lbox
             and tp.posting_type = ln.lkind::tax_posting_type
        ) p on true
       -- A box number belongs to one form. A line whose posting names
       -- another form is not on this declaration; one that names none is
       -- the single-return case every European company is in.
       where v_report is null or coalesce(p.report_code, v_report) = v_report
    ),
    ledger as (
      select x.box as lbox, s.lkind,
             round_amount(sum(s.lamount), v_round) as lamount
        from sourced s
        cross join lateral unnest(s.lboxes) as x(box)
       group by 1, 2
      having round_amount(sum(s.lamount), v_round) <> 0
    )
    select g.lbox, g.lkind, g.lamount, b.name as lname,
           b.sequence as lsequence,
           coalesce(b.print_sequence, b.sequence) as lprint,
           coalesce(b.hidden, false) as lhidden
      from ledger g
      left join tax_report_box_templates b
        on b.country = v_in and b.report_code = v_report
       and b.box = g.lbox and b.kind = g.lkind
     order by coalesce(b.sequence, 2147483647), g.lbox, g.lkind
  loop
    v_values := v_values || jsonb_build_object(r.lbox || '|' || r.lkind, r.lamount);
    v_rows := v_rows || jsonb_build_array(jsonb_build_object(
      'box', r.lbox, 'kind', r.lkind, 'amount', r.lamount, 'computed', false,
      'name', r.lname, 'sequence', r.lsequence, 'print_sequence', r.lprint,
      'hidden', r.lhidden, 'report_code', v_report));
  end loop;

  -- 2. The totals of the form, through the evaluator the statements use. A
  --    return prints what it has, so a nil total is left out of the answer —
  --    and kept in the working set, so a later total that names it reads a
  --    zero rather than a gap.
  if v_report is not null then
    select coalesce(jsonb_agg(jsonb_build_object(
             'key', b.box || '|total', 'plus', to_jsonb(b.plus_boxes),
             'minus', to_jsonb(b.minus_boxes), 'floor_zero', b.floor_zero,
             'rate', b.rate, 'rate_of', b.rate_of_box,
             'sequence', b.sequence
           ) order by b.sequence, b.box), '[]'::jsonb)
      into v_formulas
      from tax_report_box_templates b
     where b.country = v_in
       and b.report_code = v_report
       and b.kind = 'total'
       and (b.valid_from is null or b.valid_from <= p_to)
       and (b.valid_to is null or b.valid_to >= p_to);

    v_totals := evaluate_totals(v_values, v_formulas, v_round, false);

    for r in
      select b.box as tbox, b.name as tname, b.sequence as tsequence,
             coalesce(b.print_sequence, b.sequence) as tprint, b.hidden as thidden
        from tax_report_box_templates b
       where b.country = v_in
         and b.report_code = v_report
         and b.kind = 'total'
         and (b.valid_from is null or b.valid_from <= p_to)
         and (b.valid_to is null or b.valid_to >= p_to)
         and v_totals ? (b.box || '|total')
       order by b.sequence, b.box
    loop
      v_rows := v_rows || jsonb_build_array(jsonb_build_object(
        'box', r.tbox, 'kind', 'total',
        'amount', (v_totals ->> (r.tbox || '|total'))::numeric, 'computed', true,
        'name', r.tname, 'sequence', r.tsequence, 'print_sequence', r.tprint,
        'hidden', r.thidden, 'report_code', v_report));
    end loop;
  end if;

  return query
  select (x ->> 'box')::text,
         (x ->> 'kind')::text,
         (x ->> 'amount')::numeric,
         (x ->> 'computed')::boolean,
         (x ->> 'name')::text,
         (x ->> 'sequence')::integer,
         (x ->> 'print_sequence')::integer,
         (x ->> 'hidden')::boolean,
         (x ->> 'report_code')::text
    from jsonb_array_elements(v_rows) as x;
end;
$$;

comment on function vat_return(uuid, date, date, text) is
  'Declaration boxes for a period: summed from the ledger by the day each figure''s tax fell due — `entry_lines.tax_point_date`, the entry''s own date where the line carries none — then the totals of the country''s form worked out by evaluate_totals(), the same evaluator financial_statement() uses. Refuses a period the company does not file **this form** on, when it has recorded one for it. No country rule lives in this function.';

revoke execute on function vat_return(uuid, date, date, text) from public, anon;
grant execute on function vat_return(uuid, date, date, text) to authenticated, service_role;
