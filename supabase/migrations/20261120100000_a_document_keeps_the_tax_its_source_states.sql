-- Ekwo OS — a document keeps the tax its source states, within a rounding.
--
-- The tax of a document is computed per tax group and rounded once on the
-- group (decision 0010, EN 16931 BR-CO-14): round(sum of the bases x rate).
-- A supplier or a billing system that rounds the tax line by line — which
-- EN 16931 allows, and which its own rule BR-CO-17 tolerates within one unit —
-- states a tax that differs from that figure by a cent or two. Such a document
-- could not be reproduced: its totals were Ekwo's and not the ones printed on
-- the invoice the customer received, so it was refused or held.
--
-- **The stated tax is a fact of the line.** `document_lines.stated_tax_amount`
-- is the tax the source states for that line, in the document's currency.
-- Optional: a line without it computes as it always did. A tax group is
-- stated when every product line of the group states its tax, and its tax is
-- then the sum of what they state. The line is where a source that rounds
-- line by line has the figure, and it is the place the document's writers —
-- `create_document()`, `replace_document_lines()`, an insert of a connector —
-- already write; no second table, no second path.
--
-- **Within a rounding, or refused.** The stated tax of a group may differ from
-- Ekwo's computation by at most one unit of the currency per line of the group
-- (`stated_tax_tolerance()`; 0.01 per line in a currency with cents, decision
-- 0011). Beyond it the document is refused at posting by name,
-- `stated_tax_out_of_tolerance`, with what to do. A group that states its tax
-- on some lines and not on others is refused too, `stated_tax_partial`, and so
-- is a stated tax on a price quoted with the tax in it,
-- `stated_tax_on_inclusive_price`: there the base is the gross less the tax,
-- and a second figure for the tax would make the base and the gross disagree.
-- The refusals come at posting and not at each write of a draft, because a
-- draft is written one line at a time by some callers and its groups are whole
-- only when it is posted.
--
-- **One figure, read everywhere.** `document_tax_summary` is the breakdown
-- every reader asks: the totals of the document, the tax lines of the entry
-- and the declaration boxes they carry, the PDF and the electronic invoice. Its
-- `tax_amount` is the stated tax where the group states one, and Ekwo's
-- otherwise; `tax_charged` follows from it as before. The difference between
-- the two is never booked anywhere: the base stays the base, the tax is the
-- source's, and the total is their sum. The view appends what a screen needs to
-- show the gap: `tax_amount_computed`, `stated_tax_amount` and `line_count`.
--
-- **Nothing moves for a document that states nothing.** Every expression of
-- the view is the one it had; the stated tax only replaces the computed one
-- where a whole group carries it. Decision 0099 records the choice.

-- ---------------------------------------------------------------------------
-- 1. The fact, on the line
-- ---------------------------------------------------------------------------

alter table ekwo.document_lines
  add column if not exists stated_tax_amount numeric(16, 2);

alter table ekwo.document_lines
  drop constraint if exists document_lines_stated_tax_needs_a_tax;
alter table ekwo.document_lines
  add constraint document_lines_stated_tax_needs_a_tax
  check (stated_tax_amount is null or (line_type = 'product' and tax_id is not null));

comment on column ekwo.document_lines.stated_tax_amount is
  'The tax the source of the document states for this line, in the document''s currency — a supplier or a billing system that rounds the tax line by line. Optional; null computes the tax as always. When every product line of a tax group states it, the group''s tax is the sum, accepted within one unit of the currency per line of Ekwo''s computation (stated_tax_tolerance) and refused at posting beyond it. Decision 0099.';

-- ---------------------------------------------------------------------------
-- 2. The tolerance
-- ---------------------------------------------------------------------------

create or replace function ekwo.stated_tax_tolerance(
  p_company_id    uuid,
  p_currency_code text,
  p_lines         integer
)
returns numeric
language sql
stable
set search_path = ekwo, pg_temp
as $$
  select greatest(coalesce(p_lines, 0), 1) * currency_unit(rounding_of(p_company_id, p_currency_code));
$$;

comment on function ekwo.stated_tax_tolerance(uuid, text, integer) is
  'How far a stated tax may be from Ekwo''s computation of its group: one unit of the currency (0.01 where it has cents) per line of the group, the drift a tax rounded line by line can have (EN 16931). The one place the tolerance is written; posting and any connector that chooses a tax for a stated amount ask it.';

-- ---------------------------------------------------------------------------
-- 3. The breakdown reads it
--
-- `20261020072000` as it was, wrapped: the inner query is the old view with
-- its tax kept under the name `computed_tax`, and the outer one takes the
-- stated tax where the whole group states one. Three columns appended.
-- ---------------------------------------------------------------------------

create or replace view ekwo.document_tax_summary
  with (security_invoker = true) as
  select g.document_id,
         g.company_id,
         g.doc_type,
         g.tax_id,
         g.tax_code,
         g.tax_name,
         g.vat_category,
         g.tax_rate,
         g.base_amount,
         -- Gross tax: what the VAT return reports. The source's where the
         -- whole group states it.
         coalesce(g.stated_tax, g.computed_tax) as tax_amount,
         -- Charged tax: what the other party actually pays. Zero when the tax
         -- postings net out, which is exactly what self-assessment means.
         case when g.stated_tax is null then g.computed_charged
              else round_amount(g.stated_tax * g.charge_factor / 100, g.rounding)
         end as tax_charged,
         g.exemption_code,
         g.exemption_reason,
         g.legal_reference,
         g.base_includes_tax,
         g.base_amount
           + case when g.base_includes_tax then coalesce(g.stated_tax, g.computed_tax)
                  else 0 end as taxable_amount,
         -- What Ekwo computes for the group, whatever the source states.
         g.computed_tax as tax_amount_computed,
         -- What the source states for the group: the sum of its lines' stated
         -- tax when every line states one, null otherwise.
         g.stated_tax   as stated_tax_amount,
         g.line_count
    from (
      select l.document_id,
             l.company_id,
             d.doc_type,
             l.tax_id,
             t.code    as tax_code,
             t.name    as tax_name,
             l.vat_category,
             l.vat_rate::numeric(12, 4) as tax_rate,
             sum(l.amount_untaxed) as base_amount,
             round_amount(
               tax_amount_of(
                 case when bool_and(l.unit_price_includes_tax)
                      then sum(l.amount_incl_tax) else sum(l.amount_untaxed) end,
                 l.vat_rate, bool_and(l.unit_price_includes_tax), bool_and(l.base_includes_tax)),
               rounding_of(l.company_id, d.currency_code)) as computed_tax,
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
               rounding_of(l.company_id, d.currency_code)) as computed_charged,
             coalesce((
               select sum(tp.factor_percent)
                 from tax_postings tp
                where tp.tax_id = t.id
                  and tp.posting_type in ('tax', 'tax_on_base')
                  and tp.document_kind = case
                        when d.doc_type in ('sale_credit_note', 'purchase_credit_note')
                          then 'credit_note'::tax_document_kind
                        else 'invoice'::tax_document_kind
                      end
             ), 100) as charge_factor,
             rounding_of(l.company_id, d.currency_code) as rounding,
             t.exemption_code,                                          -- BT-121
             -- BT-120: the sentence the country puts on an invoice for the
             -- treatment of this tax, in the language of the document.
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
             bool_and(l.base_includes_tax) as base_includes_tax,
             case when count(l.stated_tax_amount) = count(*)
                  then sum(l.stated_tax_amount) end as stated_tax,
             count(*)::integer             as line_count
        from document_lines l
        join documents d on d.id = l.document_id
        left join taxes t on t.id = l.tax_id
       where l.line_type = 'product'
       group by l.document_id, l.company_id, d.id, l.tax_id, t.id, l.vat_category, l.vat_rate
    ) g;

comment on view ekwo.document_tax_summary is
  'VAT breakdown of a document, one row per tax, rounded once on the group (EN 16931 BR-CO-14) — on the group''s base, or on the gross it was quoted at where the price includes the tax — unless the source of the document states the tax of the group: then tax_amount is the stated one (the sum of stated_tax_amount on every line of the group), accepted at posting within stated_tax_tolerance() of tax_amount_computed, which is Ekwo''s figure (decision 0099). The category and the rate are the ones the lines carry: the tax of today for a draft, the tax as it stood for a document that was posted. Where the tax charges nothing it says why: exemption_code is BT-121 as the pack codes it, exemption_reason is BT-120 — the sentence the country puts on an invoice for that treatment, in the language of the document, null where the pack has none. legal_reference is the article the tax rests on, written for whoever reviews the pack and not for a customer. base_includes_tax says the tax was computed inside its own base, and taxable_amount is the base the rate was applied to: base_amount plus the tax where it was, base_amount where it was not (decision 0077). line_count is the number of lines of the group.';

grant select on table ekwo.document_tax_summary to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 4. The lines publish it
--
-- `20261019170000` as it was, one column appended.
-- ---------------------------------------------------------------------------

create or replace view ekwo.document_line_items
  with (security_invoker = true) as
  select l.id                          as document_line_id,
         l.document_id,
         l.company_id,
         l.sequence,
         l.line_type,
         l.name                        as item_name,
         l.description                 as item_description,
         p.code                        as seller_item_identifier,
         l.product_id,
         p.kind                        as product_kind,
         l.quantity,
         l.unit_code,
         l.unit_price,
         l.discount_percent,
         l.amount_untaxed,
         l.tax_id,
         l.vat_category,
         l.vat_rate,
         l.account_id,
         t.treatment                   as tax_treatment,
         t.exemption_code              as tax_exemption_code,
         t.cash_basis                  as tax_cash_basis,
         l.unit_price_includes_tax,
         l.amount_incl_tax,
         l.attributes,
         l.stated_tax_amount
    from document_lines l
    left join products p on p.id = l.product_id
    left join taxes t on t.id = l.tax_id;

comment on view ekwo.document_line_items is
  'Document lines with the EN 16931 item terms — BT-153 name, BT-154 description, BT-155 the seller identifier — what decides a legal mention on the line, and, where the price was quoted with the tax in it, the gross it was quoted at. unit_price is the price as keyed, which is that gross: BT-146 is the net price and this view does not publish it yet. attributes is what an electronic invoice format asks of the line that no other column says, by name. stated_tax_amount is the tax the source of the document states for the line, where it states one (decision 0099).';

grant select on table ekwo.document_line_items to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 5. The refusals, at posting
-- ---------------------------------------------------------------------------

create or replace function ekwo.assert_stated_taxes(p_document_id uuid)
returns void
language plpgsql
stable
set search_path = ekwo, pg_temp
as $$
declare
  v_doc       documents%rowtype;
  v_tolerance numeric;
  r           record;
begin
  -- The ordinary case, and the one this has to cost nothing in.
  if not exists (select 1 from document_lines l
                  where l.document_id = p_document_id and l.stated_tax_amount is not null) then
    return;
  end if;
  select * into v_doc from documents where id = p_document_id;

  for r in
    select coalesce(max(t.code), '(no tax)')          as tax_code,
           count(*)                                    as lines,
           count(l.stated_tax_amount)                  as stated,
           bool_or(l.unit_price_includes_tax)          as inclusive
      from document_lines l
      left join taxes t on t.id = l.tax_id
     where l.document_id = p_document_id
       and l.line_type = 'product'
     group by l.tax_id, l.vat_category, l.vat_rate
    having count(l.stated_tax_amount) > 0
     order by 1
  loop
    if r.stated < r.lines then
      raise exception 'stated_tax_partial: tax % of document % states its amount on % of its % lines; state the tax of the source on every line of the group, or on none of them to let Ekwo compute it',
        r.tax_code, coalesce(v_doc.number, p_document_id::text), r.stated, r.lines
        using errcode = '23514';
    end if;
    if r.inclusive then
      raise exception 'stated_tax_on_inclusive_price: tax % of document % is quoted with the tax in the price, where the tax is taken out of the gross; leave the stated tax out of those lines',
        r.tax_code, coalesce(v_doc.number, p_document_id::text)
        using errcode = '23514';
    end if;
  end loop;

  for r in
    select s.tax_code, s.stated_tax_amount, s.tax_amount_computed, s.line_count
      from document_tax_summary s
     where s.document_id = p_document_id
       and s.stated_tax_amount is not null
     order by s.tax_code
  loop
    v_tolerance := stated_tax_tolerance(v_doc.company_id, v_doc.currency_code, r.line_count);
    if abs(r.stated_tax_amount - r.tax_amount_computed) > v_tolerance then
      raise exception 'stated_tax_out_of_tolerance: tax % of document % is stated at % and its % line(s) give %, a difference above % (one unit of the currency per line); check the stated tax against the source and the tax of each line, or leave the stated tax out to let Ekwo compute it',
        r.tax_code, coalesce(v_doc.number, p_document_id::text), r.stated_tax_amount,
        r.line_count, r.tax_amount_computed, v_tolerance
        using errcode = '23514';
    end if;
  end loop;
end;
$$;

comment on function ekwo.assert_stated_taxes(uuid) is
  'Refuses, by name, a document whose stated tax cannot be accepted: a group stated on some lines only (stated_tax_partial), a stated tax on a price that includes the tax (stated_tax_on_inclusive_price), a stated tax further from Ekwo''s computation than stated_tax_tolerance() (stated_tax_out_of_tolerance). Silent for a document that states nothing. Run when a document is posted (decision 0099).';

create or replace function ekwo.documents_refuse_stated_tax()
returns trigger
language plpgsql
set search_path = ekwo, pg_temp
as $$
begin
  perform assert_stated_taxes(new.id);
  return new;
end;
$$;

comment on function ekwo.documents_refuse_stated_tax() is
  'Posting a document checks the tax its source states (assert_stated_taxes, decision 0099).';

drop trigger if exists documents_refuse_stated_tax on ekwo.documents;
create trigger documents_refuse_stated_tax
  before update of state on ekwo.documents
  for each row when (new.state = 'posted' and old.state is distinct from 'posted')
  execute function ekwo.documents_refuse_stated_tax();

-- ---------------------------------------------------------------------------
-- 6. The writers carry it
--
-- `replace_document_lines()` (`20261023160600`) and `cancel_document()`
-- (`20261019170000`) as they were, the stated tax written beside the tax: by
-- a caller that gives it, and from the invoice a credit note cancels, so the
-- credit note gives back the tax the invoice charged to the cent.
-- ---------------------------------------------------------------------------

create or replace function ekwo.replace_document_lines(p_document_id uuid, p_lines jsonb)
returns integer
language plpgsql
set search_path = ekwo, pg_temp
as $$
declare
  v_document documents%rowtype;
  v_count    integer;
begin
  if p_lines is null or jsonb_typeof(p_lines) <> 'array' then
    raise exception 'lines_not_an_array: the lines of a document are a JSON array'
      using errcode = '22023';
  end if;

  select * into v_document from documents where id = p_document_id for update;
  if not found then
    raise exception 'unknown_document: no document % in the companies you can see', p_document_id
      using errcode = 'P0002';
  end if;
  if v_document.state <> 'draft' then
    raise exception 'document_not_draft: document % is %. A posted document is not edited; correct it with a credit note.',
      p_document_id, v_document.state
      using errcode = '55006';
  end if;

  delete from document_lines where document_id = p_document_id;

  insert into document_lines (
    document_id, company_id, sequence, line_type, product_id, name, description,
    unit_code, unit_price, quantity, discount_percent, account_id, tax_id, attributes,
    stated_tax_amount
  )
  select p_document_id, v_document.company_id, (l.ordinality * 10)::integer,
         coalesce((l.line ->> 'line_type')::document_line_type, 'product'),
         (l.line ->> 'product_id')::uuid,
         l.line ->> 'name',
         l.line ->> 'description',
         coalesce(l.line ->> 'unit_code', 'C62'),
         coalesce((l.line ->> 'unit_price')::numeric, 0),
         coalesce((l.line ->> 'quantity')::numeric, 1),
         coalesce((l.line ->> 'discount_percent')::numeric, 0),
         (l.line ->> 'account_id')::uuid,
         (l.line ->> 'tax_id')::uuid,
         coalesce(l.line -> 'attributes', '{}'::jsonb),
         (l.line ->> 'stated_tax_amount')::numeric
    from jsonb_array_elements(p_lines) with ordinality as l(line, ordinality);

  get diagnostics v_count = row_count;
  return v_count;
end;
$$;

create or replace function ekwo.cancel_document(p_document_id uuid, p_date date default null)
returns ekwo.documents
language plpgsql
set search_path = ekwo, pg_temp
as $$
declare
  v_doc    documents%rowtype;
  v_credit documents%rowtype;
  v_date   date;
  v_type   doc_type;
  v_other  text;
  v_line   uuid;
  r        record;
begin
  select * into v_doc from documents where id = p_document_id for update;
  if not found then
    raise exception 'unknown_document: document % does not exist', p_document_id;
  end if;

  if v_doc.doc_type in ('sale_credit_note', 'purchase_credit_note') then
    raise exception 'document_is_a_credit_note: % % undoes another document. A credit note is not cancelled by another; issue the invoice again.',
      v_doc.doc_type, coalesce(v_doc.number, v_doc.id::text);
  end if;

  if v_doc.state = 'cancelled' then
    raise exception 'document_already_cancelled: % % is already cancelled',
      v_doc.doc_type, coalesce(v_doc.number, v_doc.id::text);
  end if;

  if v_doc.state <> 'posted' then
    raise exception 'document_not_posted: % % is a %, which is changed or deleted, not cancelled by a credit note',
      v_doc.doc_type, coalesce(v_doc.number, v_doc.id::text), v_doc.state;
  end if;

  v_type := case v_doc.doc_type
              when 'sale_invoice' then 'sale_credit_note'
              when 'purchase_invoice' then 'purchase_credit_note'
            end::doc_type;
  if v_type is null then
    raise exception 'document_not_accountable: a % is not cancelled by a credit note', v_doc.doc_type;
  end if;

  select coalesce(c.number, c.id::text) into v_other
    from documents c
   where c.reversed_document_id = v_doc.id and c.state = 'posted'
   limit 1;
  if found then
    raise exception 'document_already_credited: % % is already credited by %. Cancelling it would credit it twice.',
      v_doc.doc_type, v_doc.number, v_other;
  end if;

  if v_doc.amount_paid <> 0
     or exists (select 1 from entry_lines l where l.entry_id = v_doc.entry_id and l.matched_amount > 0) then
    raise exception 'document_paid: % % is settled by % already. Undo that matching first with unreconcile() — the money it records came in and stays — then cancel the document.',
      v_doc.doc_type, v_doc.number, v_doc.amount_paid;
  end if;

  -- The matching is part of the gesture; see reverse_entry().
  if not is_installer() and not has_capability(v_doc.company_id, 'reconcile.write') then
    raise exception 'not_allowed: cancelling % matches it with its credit note, which needs reconcile.write',
      v_doc.number
      using errcode = '42501';
  end if;

  v_date := p_date;
  if v_date is null then
    begin
      perform assert_period_open(v_doc.company_id, coalesce(v_doc.accounting_date, v_doc.document_date), true);
    exception when sqlstate '55006' then
      raise exception 'reversal_date_needed: % % is booked on %, which is no longer open (%). Pass the date of an open period to issue the credit note on.',
        v_doc.doc_type, v_doc.number, coalesce(v_doc.accounting_date, v_doc.document_date), sqlerrm
        using errcode = '55006';
    end;
    v_date := coalesce(v_doc.accounting_date, v_doc.document_date);
  elsif v_date < coalesce(v_doc.accounting_date, v_doc.document_date) then
    raise exception 'reversal_before_original: % % is booked on %, and is not cancelled on % — before it was issued.',
      v_doc.doc_type, v_doc.number, coalesce(v_doc.accounting_date, v_doc.document_date), v_date;
  end if;

  insert into documents (company_id, doc_type, contact_id, journal_id, document_date,
                         accounting_date, due_date, currency_code, exchange_rate,
                         supplier_reference, buyer_reference, project_reference,
                         contract_reference, order_reference,
                         delivery_address_line1, delivery_postal_code, delivery_city,
                         delivery_country, supply_territory_code, payment_means_code,
                         payee_iban, currency_code_tax, reversed_document_id, note)
  values (v_doc.company_id, v_type, v_doc.contact_id, v_doc.journal_id, v_date,
          v_date, v_date, v_doc.currency_code, v_doc.exchange_rate,
          v_doc.supplier_reference, v_doc.buyer_reference, v_doc.project_reference,
          v_doc.contract_reference, v_doc.order_reference,
          v_doc.delivery_address_line1, v_doc.delivery_postal_code, v_doc.delivery_city,
          v_doc.delivery_country, v_doc.supply_territory_code, v_doc.payment_means_code,
          v_doc.payee_iban, v_doc.currency_code_tax, v_doc.id,
          'Cancels ' || v_doc.number)
  returning * into v_credit;

  -- Line by line, so each line of the credit note knows the line it undoes:
  -- it takes that line's analytic split as it was issued, over whatever a
  -- product or a contact pre-filled since — a value retired since included,
  -- which the guard lets through for this credit note alone. The tax a source
  -- stated is given back as it was charged.
  perform set_config('ekwo.crediting_document', v_credit.id::text, true);
  for r in
    select l.* from document_lines l
     where l.document_id = v_doc.id
     order by l.sequence, l.id
  loop
    insert into document_lines (document_id, company_id, sequence, line_type, name, description,
                                quantity, unit_code, unit_price, discount_percent,
                                tax_id, account_id, product_id, attributes, stated_tax_amount)
    values (v_credit.id, r.company_id, r.sequence, r.line_type, r.name, r.description,
            r.quantity, r.unit_code, r.unit_price, r.discount_percent,
            r.tax_id, r.account_id, r.product_id, r.attributes, r.stated_tax_amount)
    returning id into v_line;

    delete from document_line_analytics x where x.document_line_id = v_line;
    insert into document_line_analytics (company_id, document_line_id, analytic_value_id, percentage)
    select x.company_id, v_line, x.analytic_value_id, x.percentage
      from document_line_analytics x
     where x.document_line_id = r.id;
  end loop;
  perform set_config('ekwo.crediting_document', '', true);

  select * into v_credit from documents where id = v_credit.id;
  if (v_credit.amount_untaxed, v_credit.amount_tax, v_credit.amount_total)
     is distinct from (v_doc.amount_untaxed, v_doc.amount_tax, v_doc.amount_total) then
    raise exception 'credit_note_differs: the lines of % give % today, and it was issued at %. A tax or a rounding it was posted with has changed since; credit it by hand, line by line.',
      v_doc.number, v_credit.amount_total, v_doc.amount_total;
  end if;

  perform post_document(v_credit.id);
  select * into v_credit from documents where id = v_credit.id;
  perform match_reversal(v_doc.entry_id, v_credit.entry_id);

  update documents set state = 'cancelled' where id = v_doc.id;

  select * into v_credit from documents where id = v_credit.id;
  return v_credit;
end;
$$;

-- ---------------------------------------------------------------------------
-- 7. Privileges, by name
-- ---------------------------------------------------------------------------

revoke execute on function ekwo.stated_tax_tolerance(uuid, text, integer) from public, anon;
revoke execute on function ekwo.assert_stated_taxes(uuid) from public, anon;
grant execute on function ekwo.stated_tax_tolerance(uuid, text, integer) to authenticated, service_role;
grant execute on function ekwo.assert_stated_taxes(uuid) to authenticated, service_role;

-- The revoke every file of this directory ends with, and the Data API told
-- the functions are there.
revoke execute on all functions in schema ekwo from public;

notify pgrst, 'reload schema';
