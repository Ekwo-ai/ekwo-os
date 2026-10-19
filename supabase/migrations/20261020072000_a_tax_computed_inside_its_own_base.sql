-- Ekwo OS — a tax computed inside its own base.
--
-- Some taxes are levied on a base that already contains them. The legal rate
-- is applied to the price *with* the tax in it, so on a net amount N at a
-- rate r the tax is N x r / (1 - r), and on a price P that holds it the tax is
-- simply P x r. Two engines of this schema came close and neither says it:
--
--   * `price_include` takes a tax *out* of a gross price at the rate over one
--     hundred plus the rate (VAT Notice 700, one sixth at 20 per cent). A pack
--     can reproduce P x r with it only by declaring an effective rate of
--     r / (1 - r) — 13/87 is 14,942528… — rounded to the four decimals the
--     column keeps. The answer then drifts by a cent once the amounts are
--     large enough, the rate printed on the invoice is not the rate of the
--     law, and the base reported is the net, where the law asks for the base
--     the rate was applied to.
--   * a plain tax adds r x N on top, which is not the same figure at all.
--
-- So the schema gets one closed, named fact about a tax:
--
--   `base_includes_tax` — the taxable base of this tax contains the tax
--   itself. The rate stays the rate of the law.
--
-- **The rule.** One function says how much tax a group carries, unrounded,
-- and every reader asks it — the breakdown, the allocator of a price that
-- holds its tax, the provisional net of a single line:
--
--                         price excludes the tax     price includes the tax
--   ordinary tax          N x r / 100                P - P / (1 + r / 100)
--   base includes tax     N x r / (100 - r)          P x r / 100
--
-- The two ordinary cells are the expressions the view and the allocator have
-- always evaluated, written the same way, so no figure of any pack moves by a
-- cent: a tax that does not declare the key goes through exactly the
-- arithmetic it went through before. The two new cells are exact in numeric:
-- the division in the first one is the only one, and `round_amount()` rounds
-- the quotient once at the currency, on the group (EN 16931 BR-CO-14).
--
-- **What the declaration reads.** The base posting of such a tax reports, in
-- its box, the base the rate was applied to: the net of the ledger line plus
-- its share of the group's tax. The shares are cumulated in the order the
-- lines are booked and rounded on the cumulated figure, the technique the
-- analytic split uses, so the boxes of one tax add up to the base plus the tax
-- of the group exactly. The ledger keeps the net on the account of the line:
-- what the account is credited with is still the line's own amount.
--
-- **A snapshot on the line**, like `unit_price_includes_tax` and BT-152:
-- `document_lines.base_includes_tax` is derived from the tax while the
-- document is a draft and kept when it is posted, so a pack upgrade that
-- turns the key on cannot rewrite an invoice that was sent. A tax group whose
-- lines disagree is refused by name, `mixed_base_includes_tax`, at posting.
--
-- **Two refusals on the tax.** Only a percentage may be computed inside its
-- base, and only below one hundred per cent, where N / (1 - r) has a meaning.
--
-- **What it does not do.** It does not put a second tax on the same line —
-- the core takes one tax per line, and the reserved `group` of a pack is still
-- refused — and it says nothing about which country levies such a tax: the
-- pack says so, with its source. Decision 0077 records the choice.

-- ---------------------------------------------------------------------------
-- 1. The key, on the tax, its template and the line
-- ---------------------------------------------------------------------------

alter table taxes
  add column if not exists base_includes_tax boolean not null default false;

alter table tax_templates
  add column if not exists base_includes_tax boolean not null default false;

alter table document_lines
  add column if not exists base_includes_tax boolean not null default false;

alter table taxes
  add constraint taxes_base_includes_tax_needs_a_rate
  check (not base_includes_tax or (amount_type = 'percent' and amount < 100));

alter table tax_templates
  add constraint tax_templates_base_includes_tax_needs_a_rate
  check (not base_includes_tax or (amount_type = 'percent' and amount < 100));

alter table document_lines
  add constraint document_lines_base_includes_tax_needs_a_tax
  check (not base_includes_tax or tax_id is not null);

comment on column taxes.base_includes_tax is
  'The taxable base of this tax contains the tax itself: on a net amount N at rate r the tax is N x r / (100 - r), and on a price that holds it the tax is the price x r / 100. The rate is the rate of the law. Only a percentage below 100 may say so. Decision 0077.';

comment on column tax_templates.base_includes_tax is
  'The taxable base of this tax contains the tax itself. Compiled from the pack and copied onto the tax a company installs. Decision 0077.';

comment on column document_lines.base_includes_tax is
  'The tax of this line is computed inside its own base. Derived from the tax while the document is a draft and kept when it is posted, like unit_price_includes_tax, so a later change to the tax cannot rewrite an invoice that has been sent.';

-- ---------------------------------------------------------------------------
-- 2. How much tax a group carries
--
-- Unrounded: the caller rounds once, at the currency, on the group. The
-- amount is the gross where the price includes the tax and the net where it
-- does not, which is what each caller already holds.
-- ---------------------------------------------------------------------------

create or replace function tax_amount_of(
  p_amount            numeric,
  p_rate              numeric,
  p_price_include     boolean,
  p_base_includes_tax boolean
)
returns numeric
language plpgsql
immutable
set search_path = public, pg_temp
as $$
begin
  if p_base_includes_tax then
    if coalesce(p_rate, 0) >= 100 then
      raise exception 'unsupported_inside_rate: a tax computed inside its own base cannot be % per cent', p_rate;
    end if;
    if p_price_include then
      return p_amount * coalesce(p_rate, 0) / 100;
    end if;
    return p_amount * coalesce(p_rate, 0) / (100 - coalesce(p_rate, 0));
  end if;
  if p_price_include then
    return p_amount - p_amount / (1 + coalesce(p_rate, 0) / 100);
  end if;
  return p_amount * coalesce(p_rate, 0) / 100;
end;
$$;

comment on function tax_amount_of(numeric, numeric, boolean, boolean) is
  'The tax of a group, unrounded: on the net at the rate, or taken out of the gross where the price includes the tax, and in both cases computed inside its own base where the tax says base_includes_tax (decision 0077). The one place the arithmetic is written; the breakdown, the allocator and the line all ask it.';

revoke execute on function tax_amount_of(numeric, numeric, boolean, boolean) from public, anon;
grant execute on function tax_amount_of(numeric, numeric, boolean, boolean) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 3. The line derives its own amounts
--
-- `20260915195000` as it was, with the second snapshot beside the first and
-- the provisional net of a line quoted with its tax in it asked of
-- `tax_amount_of()`.
-- ---------------------------------------------------------------------------

create or replace function document_lines_amount_untaxed()
returns trigger
language plpgsql
as $$
declare
  v_company  uuid;
  v_currency char(3);
  v_state    doc_state;
  v_round    money_rounding;
  v_gross    numeric;
  v_rate     numeric;
begin
  if new.line_type <> 'product' then
    new.amount_untaxed          := 0;
    new.amount_incl_tax         := null;
    new.unit_price_includes_tax := false;
    new.base_includes_tax       := false;
    return new;
  end if;

  -- Read in two steps: `select f(x) into a_composite` would assign the whole
  -- row to the first field of the target, which is a trap plpgsql lays for
  -- every function that returns a composite.
  select d.company_id, d.currency_code, d.state
    into v_company, v_currency, v_state
    from documents d where d.id = new.document_id;
  v_round := rounding_of(v_company, v_currency);

  -- The snapshot. Taken from the tax for as long as the document is a draft,
  -- and left alone from the moment it is posted.
  if tg_op = 'INSERT' or v_state = 'draft' then
    new.unit_price_includes_tax :=
      coalesce((select t.price_include from taxes t where t.id = new.tax_id), false);
    new.base_includes_tax :=
      coalesce((select t.base_includes_tax from taxes t where t.id = new.tax_id), false);
  end if;

  v_gross := round_amount(
    new.quantity * new.unit_price * (1 - new.discount_percent / 100), v_round);

  if not new.unit_price_includes_tax then
    new.amount_incl_tax := null;
    new.amount_untaxed  := v_gross;
    return new;
  end if;

  new.amount_incl_tax := v_gross;
  if tg_op = 'INSERT'
     or not old.unit_price_includes_tax
     or old.amount_incl_tax is distinct from v_gross then
    select t.amount into v_rate from taxes t where t.id = new.tax_id;
    if coalesce(v_rate, 0) <= -100 then
      raise exception 'unsupported_included_rate: a price cannot include a tax of % per cent', v_rate;
    end if;
    new.amount_untaxed :=
      v_gross - round_amount(
        tax_amount_of(v_gross, v_rate, true, new.base_includes_tax), v_round);
  end if;
  return new;
end;
$$;

comment on function document_lines_amount_untaxed() is
  'Derives a line''s amounts from its quantity, price and discount, rounded once at the decimals of the document''s currency: the net, the gross where the price includes the tax, and the snapshots of whether it does and of whether its tax is computed inside its own base (decision 0077).';

-- ---------------------------------------------------------------------------
-- 4. The group is the unit of the rounding
--
-- `20260915195000` as it was, the tax of the group asked of `tax_amount_of()`.
-- A group whose lines disagree on the key is refused at posting, where the
-- refusal of a half-inclusive group already stands beside it.
-- ---------------------------------------------------------------------------

create or replace function documents_allocate_included_tax(p_document_id uuid)
returns void
language plpgsql
as $$
declare
  v_company  uuid;
  v_currency char(3);
  v_round    money_rounding;
  v_gross    numeric;
  v_tax      numeric;
  v_base     numeric;
  v_left     numeric;
  v_share    numeric;
  v_group    record;
  v_line     record;
begin
  -- The ordinary case, and the one this has to cost nothing in: a document
  -- with no line quoted with its tax in it.
  if not exists (
    select 1 from document_lines dl
     where dl.document_id = p_document_id
       and dl.line_type = 'product'
       and dl.unit_price_includes_tax
  ) then
    return;
  end if;

  select d.company_id, d.currency_code into v_company, v_currency
    from documents d where d.id = p_document_id;
  if not found then
    return;
  end if;
  v_round := rounding_of(v_company, v_currency);

  for v_group in
    select dl.tax_id,
           max(t.code)                          as tax_code,
           max(t.amount)                        as rate,
           bool_and(dl.unit_price_includes_tax) as all_inclusive,
           bool_and(dl.base_includes_tax)       as inside,
           coalesce(sum(dl.amount_incl_tax), 0) as gross
      from document_lines dl
      join taxes t on t.id = dl.tax_id
     where dl.document_id = p_document_id
       and dl.line_type = 'product'
     group by dl.tax_id
    having bool_or(dl.unit_price_includes_tax)
     order by 1
  loop
    -- Half a group is not a group. The only way to build one is to change the
    -- tax between two line writes of the same draft, and adding a gross line
    -- to a net one would produce a base nobody can explain.
    if not v_group.all_inclusive then
      raise exception 'mixed_price_include: tax % prices some lines of document % with the tax in them and others without',
        v_group.tax_code, p_document_id;
    end if;
    if coalesce(v_group.rate, 0) <= -100 then
      raise exception 'unsupported_included_rate: a price cannot include a tax of % per cent', v_group.rate;
    end if;

    v_gross := v_group.gross;
    v_tax   := round_amount(tax_amount_of(v_gross, v_group.rate, true, v_group.inside), v_round);
    v_base  := v_gross - v_tax;
    v_left  := v_base;

    for v_line in
      select dl.id,
             coalesce(dl.amount_incl_tax, 0)                 as gross,
             row_number() over (order by dl.sequence, dl.id)
               = count(*) over ()                            as is_last
        from document_lines dl
       where dl.document_id = p_document_id
         and dl.line_type = 'product'
         and dl.tax_id = v_group.tax_id
       order by dl.sequence, dl.id
    loop
      if v_line.is_last then
        v_share := v_left;
      else
        v_share := case when v_gross = 0 then 0
                        else round_amount(v_base * v_line.gross / v_gross, v_round) end;
        v_left  := v_left - v_share;
      end if;

      update document_lines
         set amount_untaxed = v_share
       where id = v_line.id
         and amount_untaxed is distinct from v_share;
    end loop;
  end loop;
end;
$$;

comment on function documents_allocate_included_tax(uuid) is
  'Turns the gross of every tax group quoted with the tax in it into a base: the tax rounded once on the group (BR-CO-14), as tax_amount_of() computes it, the base the gross less that tax, shared over the lines in proportion to their gross with the remainder on the last. Refuses a group that is half inclusive, by name.';

-- ---------------------------------------------------------------------------
-- 5. The breakdown asks the same function
--
-- `20260918141605` as it was, the two tax expressions asked of
-- `tax_amount_of()` and two columns appended: whether the group is computed
-- inside its own base, and the base the rate was applied to.
-- ---------------------------------------------------------------------------

create or replace view document_tax_summary
  with (security_invoker = true) as
  select l.document_id,
         l.company_id,
         d.doc_type,
         l.tax_id,
         t.code    as tax_code,
         t.name    as tax_name,
         l.vat_category,
         l.vat_rate::numeric(12, 4) as tax_rate,
         sum(l.amount_untaxed) as base_amount,
         -- Gross tax: what the VAT return reports.
         round_amount(
           tax_amount_of(
             case when bool_and(l.unit_price_includes_tax)
                  then sum(l.amount_incl_tax) else sum(l.amount_untaxed) end,
             l.vat_rate, bool_and(l.unit_price_includes_tax), bool_and(l.base_includes_tax)),
           rounding_of(l.company_id, d.currency_code)) as tax_amount,
         -- Charged tax: what the other party actually pays. Zero when the tax
         -- postings net out, which is exactly what self-assessment means.
         round_amount(
           tax_amount_of(
             case when bool_and(l.unit_price_includes_tax)
                  then sum(l.amount_incl_tax) else sum(l.amount_untaxed) end,
             l.vat_rate, bool_and(l.unit_price_includes_tax), bool_and(l.base_includes_tax))
           * coalesce((
               select sum(tp.factor_percent)
                 from tax_postings tp
                where tp.tax_id = t.id
                  and tp.posting_type in ('tax', 'tax_on_base')
                  and tp.document_kind = case
                        when d.doc_type in ('sale_credit_note', 'purchase_credit_note')
                          then 'credit_note'::tax_document_kind
                        else 'invoice'::tax_document_kind
                      end
             ), 100) / 100,
           rounding_of(l.company_id, d.currency_code)) as tax_charged,
         t.exemption_code,                                          -- BT-121
         -- BT-120: the sentence the country puts on an invoice for the
         -- treatment of this tax, in the language of the document. Several
         -- sentences for one treatment are several sentences, in their order.
         (select string_agg(
                   label_for(m.text, m.text_i18n, preferred_languages(d.language, d.company_id)),
                   ' ' order by m.sequence, m.code)
            from legal_mention_templates m
            join companies c on c.id = d.company_id
           where m.country = c.fiscal_country
             and m.valid_from <= d.document_date
             and (m.valid_to is null or m.valid_to >= d.document_date)
             and t.treatment::text = any (legal_mention_treatments(m.applies_when))
         )                             as exemption_reason,
         t.legal_reference,
         -- Whether the tax of this group is computed inside its own base, and
         -- the base the rate was applied to: the net plus the tax where it is,
         -- the net where it is not (decision 0077).
         bool_and(l.base_includes_tax) as base_includes_tax,
         sum(l.amount_untaxed)
           + case when bool_and(l.base_includes_tax)
                  then round_amount(
           tax_amount_of(
                      case when bool_and(l.unit_price_includes_tax)
                           then sum(l.amount_incl_tax) else sum(l.amount_untaxed) end,
                      l.vat_rate, bool_and(l.unit_price_includes_tax), bool_and(l.base_includes_tax)),
                    rounding_of(l.company_id, d.currency_code))
                  else 0 end   as taxable_amount
    from document_lines l
    join documents d on d.id = l.document_id
    left join taxes t on t.id = l.tax_id
   where l.line_type = 'product'
   group by l.document_id, l.company_id, d.id, l.tax_id, t.id, l.vat_category, l.vat_rate;

comment on view document_tax_summary is
  'VAT breakdown of a document, one row per tax, rounded once on the group (EN 16931 BR-CO-14) — on the group''s base, or on the gross it was quoted at where the price includes the tax. The category and the rate are the ones the lines carry: the tax of today for a draft, the tax as it stood for a document that was posted. Where the tax charges nothing it says why: exemption_code is BT-121 as the pack codes it, exemption_reason is BT-120 — the sentence the country puts on an invoice for that treatment, in the language of the document, null where the pack has none. legal_reference is the article the tax rests on, written for whoever reviews the pack and not for a customer. base_includes_tax says the tax was computed inside its own base, and taxable_amount is the base the rate was applied to: base_amount plus the tax where it was, base_amount where it was not (decision 0077).';

grant select on table document_tax_summary to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 6. post_document, whose base box reports the base the rate was applied to
--
-- `20261019130000` as it was, with the box of a base posting reading the
-- group's tax where the tax is computed inside its own base, and the refusal
-- of a group whose lines disagree on it.
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
  -- The ledger line just written, which takes the analytic split of the
  -- document lines it groups.
  v_line       uuid;
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
  -- The tax of the group a base posting belongs to, for a tax computed inside
  -- its own base: the box of the base reports the base plus its share of it.
  v_inside_tax numeric;
  -- Where the three parties of this document are, resolved once and kept on
  -- the document. `document_territory()` is the ladder.
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

  -- An axis the company requires is carried whole by the lines it is
  -- required on, or nothing is booked (decision 0076).
  perform assert_document_analytic_axes(p_document_id);

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

  -- Where the three parties of this document are. Resolved on every document
  -- now and not only where a tax asks, because the answer is kept: it is
  -- written on the document beside its entry, at the end of this function,
  -- and a posted document does not change it afterwards.
  v_terr_seller := document_territory(p_document_id, 'seller');
  v_terr_buyer  := document_territory(p_document_id, 'buyer');
  v_terr_supply := document_territory(p_document_id, 'supply');

  -- Every tax that names a territory must find the parties where it says they
  -- are. This is the one thing the core may do with a territory condition: it
  -- refuses a tax that cannot apply, and it never chooses, substitutes or
  -- suggests one — the core picks no tax for anybody, in any country.
  --
  -- "Inside" is `territory_within_for_tax()`: the tree of `territories`, cut
  -- at every territory the reference data takes out of its parent's tax. A
  -- supply to such a territory does not satisfy a condition naming the
  -- parent, which is how a country's rates stop at the territories its own
  -- law excludes without a pack writing a negation.
  --
  -- The loop is skipped entirely where nothing asks, which is every document
  -- of every pack that names no territory.
  for r in
    select distinct t.code,
           t.applies_seller_territory as seller,
           t.applies_buyer_territory  as buyer,
           t.applies_supply_territory as supply,
           t.applies_supply_vs_seller as relation
      from document_lines l
      join taxes t on t.id = l.tax_id
     where l.document_id = p_document_id
       and (t.applies_seller_territory is not null
         or t.applies_buyer_territory  is not null
         or t.applies_supply_territory is not null
         or t.applies_supply_vs_seller is not null)
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
      if not territory_within_for_tax(p.actual, p.wanted) then
        raise exception 'tax_territory_mismatch: tax % applies where the % is in %; on this document the % is in %',
          r.code, p.party, p.wanted, p.party, p.actual;
      end if;
    end loop;

    -- The relation between two facts the document already carries: is the
    -- supply inside the seller's territory, or not. It is read at the level of
    -- the seller — a seller in US-CA shipping to US-AZ is `other`, and one in
    -- US-CA delivering in US-CA is `same` — so a seller known only by a whole
    -- country has no level to read it at. That is refused rather than
    -- answered: a country is where no tax that asks this question is levied,
    -- and "same" against a country would hold for every domestic supply of
    -- every state at once.
    if r.relation is not null then
      if v_terr_seller is null then
        raise exception 'no_party_territory: tax % compares the place of supply with the territory of the seller, and nothing on this document says where the seller is; set territory_code on the party that sells, or the country beside it',
          r.code;
      end if;
      if v_terr_supply is null then
        raise exception 'no_party_territory: tax % compares the place of supply with the territory of the seller, and nothing on this document says where the supply is; set supply_territory_code or delivery_country on the document',
          r.code;
      end if;
      if not exists (select 1 from territories t
                      where t.code = upper(btrim(v_terr_seller)) and t.parent_code is not null) then
        raise exception 'no_party_territory: tax % compares the place of supply with the territory of the seller, and the seller is in %, which is not a territory inside a country; set territory_code on the party that sells to the territory that levies this tax',
          r.code, v_terr_seller;
      end if;
      if territory_within_for_tax(v_terr_supply, v_terr_seller) <> (r.relation = 'same') then
        raise exception 'tax_territory_mismatch: tax % applies where the supply is % the territory of the seller (%); on this document the supply is in %',
          r.code,
          case when r.relation = 'same' then 'inside' else 'outside' end,
          v_terr_seller, v_terr_supply;
      end if;
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

  -- A tax computed inside its own base on some lines of a group and not on
  -- others is a group nobody can report: the snapshot moved between two
  -- writes of the same draft. Refused by name, like a half-inclusive group.
  for r in
    select t.code
      from document_lines l join taxes t on t.id = l.tax_id
     where l.document_id = p_document_id and l.line_type = 'product'
     group by t.code
    having bool_and(l.base_includes_tax) <> bool_or(l.base_includes_tax)
  loop
    raise exception 'mixed_base_includes_tax: tax % is computed inside its own base on some lines of document % and not on others',
      r.code, p_document_id;
  end loop;

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
           string_agg(distinct l.name, ', ') as label,
           (array_agg(l.id order by l.sequence))[1] as first_line,
           bool_and(l.base_includes_tax) as inside,
           -- The bases of the tax up to and including this ledger line, and
           -- all of them: what the share of a tax computed inside its own
           -- base is cumulated on.
           sum(sum(l.amount_untaxed)) over (
             partition by l.tax_id
             order by min(l.sequence), (array_agg(l.id order by l.sequence))[1]
             rows between unbounded preceding and current row) as cum_base,
           sum(sum(l.amount_untaxed)) over (partition by l.tax_id) as tax_base
      from document_lines l
     where l.document_id = p_document_id
       and l.line_type = 'product'
     -- The split is part of the key: lines that go to different analytic
     -- values are different ledger lines (decision 0076).
     group by l.account_id, l.tax_id, document_line_split_key(l.id)
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

    -- What the box of the base reports. For a tax computed inside its own
    -- base it is the base the rate was applied to — the net plus this line's
    -- share of the group's tax, cumulated in booking order and rounded on the
    -- cumulated figure, so the shares add up to the tax of the group exactly.
    v_inside_tax := 0;
    if r.inside and r.tax_base <> 0 then
      select s.tax_amount into v_inside_tax
        from document_tax_summary s
       where s.document_id = p_document_id and s.tax_id = r.tax_id;
      v_inside_tax := round_amount(coalesce(v_inside_tax, 0) * r.cum_base / r.tax_base, v_round)
                    - round_amount(coalesce(v_inside_tax, 0) * (r.cum_base - r.base_amount) / r.tax_base, v_round);
    end if;

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
                 else round_amount((r.base_amount + v_inside_tax)
                                     * coalesce(p.box_factor_percent, 100) / 100 / v_rate,
                                   v_book_round) end,
            v_tax_point,
            v_doc.currency_code,
            case when v_foreign then v_amount end)
    returning id into v_line;

    -- Every line of the group carries the same split; the first one says it.
    insert into entry_line_analytics (company_id, entry_line_id, analytic_value_id, percentage)
    select v_doc.company_id, v_line, x.analytic_value_id, x.percentage
      from document_line_analytics x
     where x.document_line_id = r.first_line;
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
               first_line,
               sum(base_amount) over ()                                   as total_base,
               row_number() over (order by seq) = count(*) over ()         as is_last
          from (
            select l.account_id,
                   sum(l.amount_untaxed) as base_amount,
                   min(l.sequence)       as seq,
                   (array_agg(l.id order by l.sequence))[1] as first_line
              from document_lines l
             where l.document_id = p_document_id
               and l.line_type = 'product'
               and l.tax_id = r.tax_id
             -- A cost lands where its lines do, analytic split included.
             group by l.account_id, document_line_split_key(l.id)
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
                case when v_foreign then v_share end)
        returning id into v_line;

        insert into entry_line_analytics (company_id, entry_line_id, analytic_value_id, percentage)
        select v_doc.company_id, v_line, x.analytic_value_id, x.percentage
          from document_line_analytics x
         where x.document_line_id = g.first_line;
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
         tax_point_date  = v_tax_point,
         seller_territory_code     = v_terr_seller,
         buyer_territory_code      = v_terr_buyer,
         supply_territory_resolved = v_terr_supply
   where id = p_document_id;

  return v_entry;
end;
$$;

comment on function post_document(uuid) is
  'Books a document: one entry, the bases on the accounts of the lines, the tax of each group rounded once and shared over the postings of the tax, each ledger line naming the posting type that wrote it. Refuses a tax whose applies_*_territory the document contradicts — read with territory_within_for_tax(), so a territory outside its parent''s tax does not satisfy a condition naming the parent — or whose applies_supply_vs_seller it contradicts, by name, before anything reaches the ledger; chooses no tax for anybody. Writes the three territories it resolved on the document (seller_territory_code, buyer_territory_code, supply_territory_resolved). Groups the lines by account, tax and analytic split, and copies the split of each group onto the ledger line it writes; refuses analytic_axis_required, before anything is written, when a line leaves part of a required axis off (decision 0076). For a tax computed inside its own base the box of the base reports the base plus its cumulated share of the group''s tax, and a group whose lines disagree on it is refused, mixed_base_includes_tax (decision 0077).';

-- ---------------------------------------------------------------------------
-- 7. The copy of a tax carries the key
--
-- `20260921145425` as it was, with `base_includes_tax` carried from the
-- template to the tax a company installs. A column missing on one side of a
-- copy is the defect `price_include` was for a whole release.
-- ---------------------------------------------------------------------------

create or replace function install_country_template(
  p_company_id uuid,
  p_country    char(2),
  p_language   char(2) default null,
  p_chart_code text default null
)
returns void
language plpgsql
as $$
declare
  v_defaults country_defaults%rowtype;
  r          record;
  v_tax_id   uuid;
  v_language char(2);
  v_version  text;
  v_chart    text;
  v_charts   text;
begin
  if not exists (select 1 from companies where id = p_company_id) then
    raise exception 'unknown_company: %', p_company_id;
  end if;

  -- Which chart. The caller names one, or the pack's default stands. A named
  -- chart that does not exist is an error that lists what does: guessing here
  -- would install the wrong plan of accounts and nobody would notice for a
  -- year.
  if p_chart_code is null then
    select c.code into v_chart
      from chart_templates c
     where c.country = p_country and c.is_default;
    if v_chart is null then
      -- No pack for this country, or a pack that names no default chart.
      raise exception 'unknown_country_template: no chart of accounts seeded for %', p_country;
    end if;
  else
    select c.code into v_chart
      from chart_templates c
     where c.country = p_country and c.code = p_chart_code;
    if v_chart is null then
      select string_agg(c.code, ', ' order by c.code) into v_charts
        from chart_templates c where c.country = p_country;
      raise exception 'unknown_chart: % has no chart %. It has: %',
        p_country, p_chart_code, coalesce(v_charts, 'none');
    end if;
  end if;

  if not exists (
    select 1 from account_templates
     where country = p_country and chart_code = v_chart
  ) then
    raise exception 'unknown_country_template: chart % of % holds no account', v_chart, p_country;
  end if;

  -- The language of the copy: what the caller asked for, else what the
  -- company keeps its books in.
  select coalesce(p_language, c.language) into v_language
    from companies c where c.id = p_company_id;

  -- 1. Accounts, without the hierarchy.
  insert into accounts (company_id, code, name, name_i18n, statement_hint,
                        account_type, reconcilable)
  select p_company_id, t.code,
         label_for(t.name, t.name_i18n, array[v_language]),
         t.name_i18n, t.statement_hint, t.account_type, t.reconcilable
    from account_templates t
   where t.country = p_country
     and t.chart_code = v_chart
  on conflict (company_id, code) do nothing;

  -- 2. Hierarchy, now that every code exists.
  update accounts a
     set parent_id = p.id
    from account_templates t
    join accounts p on p.company_id = p_company_id and p.code = t.parent_code
   where a.company_id = p_company_id
     and a.code = t.code
     and t.country = p_country
     and t.chart_code = v_chart
     and t.parent_code is not null
     and a.parent_id is null;

  -- 3. Journals. Common to every chart of the country.
  insert into journals (company_id, code, name, name_i18n, journal_type)
  select p_company_id, t.code,
         label_for(t.name, t.name_i18n, array[v_language]),
         t.name_i18n, t.journal_type
    from journal_templates t
   where t.country = p_country
  on conflict (company_id, code) do nothing;

  -- 4. Taxes and their postings. Also common: a chart changes how a company
  --    presents itself, not what it owes.
  for r in
    select * from tax_templates where country = p_country order by sequence, code
  loop
    v_tax_id := null;
    insert into taxes (company_id, code, name, name_i18n, description, amount_type, amount,
                       applies_to, treatment, country, valid_from, valid_to,
                       legal_reference, vat_category, exemption_code, sequence,
                       tax_kind, recoverable, jurisdiction, price_include,
                       cash_basis, cash_basis_transition_account_id,
                       applies_seller_territory, applies_buyer_territory,
                       applies_supply_territory, applies_supply_vs_seller,
                       base_includes_tax)
    values (p_company_id, r.code,
            label_for(r.name, r.name_i18n, array[v_language]),
            r.name_i18n, r.description, r.amount_type, r.amount,
            r.applies_to, r.treatment, p_country, r.valid_from, r.valid_to,
            r.legal_reference, r.vat_category, r.exemption_code, r.sequence,
            r.tax_kind, r.recoverable, r.jurisdiction, r.price_include,
            r.cash_basis, account_id_by_code(p_company_id, r.cash_basis_transition_account_code),
            r.applies_seller_territory, r.applies_buyer_territory,
            r.applies_supply_territory, r.applies_supply_vs_seller,
            r.base_includes_tax)
    on conflict (company_id, code) do nothing
    returning id into v_tax_id;

    if v_tax_id is null then
      continue;
    end if;

    insert into tax_postings (tax_id, company_id, document_kind, posting_type,
                              factor_percent, account_id, declaration_box,
                              declaration_boxes, box_factor_percent, report_code,
                              sequence)
    select v_tax_id, p_company_id, tp.document_kind, tp.posting_type,
           tp.factor_percent, account_id_by_code(p_company_id, tp.account_code),
           tp.declaration_box, tp.declaration_boxes, tp.box_factor_percent,
           tp.report_code, tp.sequence
      from tax_posting_templates tp
     where tp.tax_template_id = r.id
     order by tp.sequence;
  end loop;

  -- 5. Roles.
  select * into v_defaults from country_defaults where country = p_country;
  if found then
    update companies c
       set receivable_account_id       = coalesce(c.receivable_account_id, account_id_by_code(p_company_id, v_defaults.receivable_code)),
           payable_account_id          = coalesce(c.payable_account_id, account_id_by_code(p_company_id, v_defaults.payable_code)),
           suspense_account_id         = coalesce(c.suspense_account_id, account_id_by_code(p_company_id, v_defaults.suspense_code)),
           rounding_account_id         = coalesce(c.rounding_account_id, account_id_by_code(p_company_id, v_defaults.rounding_code)),
           retained_earnings_account_id = coalesce(c.retained_earnings_account_id, account_id_by_code(p_company_id, v_defaults.retained_earnings_code)),
           default_sales_account_id    = coalesce(c.default_sales_account_id, account_id_by_code(p_company_id, v_defaults.sales_account_code)),
           default_purchase_account_id = coalesce(c.default_purchase_account_id, account_id_by_code(p_company_id, v_defaults.purchase_account_code)),
           sales_journal_id            = coalesce(c.sales_journal_id, (select id from journals where company_id = p_company_id and code = v_defaults.sales_journal_code)),
           purchase_journal_id         = coalesce(c.purchase_journal_id, (select id from journals where company_id = p_company_id and code = v_defaults.purchase_journal_code)),
           miscellaneous_journal_id    = coalesce(c.miscellaneous_journal_id, (select id from journals where company_id = p_company_id and code = v_defaults.misc_journal_code))
     where c.id = p_company_id;

    -- 6. The financial journals point at their account.
    update journals j
       set default_account_id = account_id_by_code(p_company_id, v_defaults.bank_account_code)
     where j.company_id = p_company_id
       and j.journal_type = 'bank'
       and j.default_account_id is null
       and v_defaults.bank_account_code is not null;

    update journals j
       set default_account_id = account_id_by_code(p_company_id, v_defaults.cash_account_code)
     where j.company_id = p_company_id
       and j.journal_type = 'cash'
       and j.default_account_id is null
       and v_defaults.cash_account_code is not null;
  end if;

  -- 7. What was copied, from which version, and on which chart.
  v_version := coalesce((select version from country_packs where country = p_country), '1.0.0');

  insert into company_packs (company_id, country, version, chart_code)
  values (p_company_id, p_country, v_version, v_chart)
  on conflict (company_id, country) do update
     set version = excluded.version,
         chart_code = excluded.chart_code,
         upgraded_at = now()
   where company_packs.version is distinct from excluded.version
      or company_packs.chart_code is distinct from excluded.chart_code;

  -- 8. The working chart. Everything wired above is pinned, so a company opens
  --    on the accounts its country model actually points at rather than on the
  --    whole transcription.
  perform pin_referenced_accounts(p_company_id);
end;
$$;

