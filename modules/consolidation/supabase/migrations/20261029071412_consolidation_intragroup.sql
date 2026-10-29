-- Ekwo — the `consolidation` module: what the companies of a group sold to each
-- other, and whether both sides say the same.
--
-- An elimination starts from a pair: the invoice one member issued to another,
-- and the same invoice in the other's purchases. This file finds the pairs and
-- lists what does not pair. It computes no elimination and writes nothing:
-- the amounts to eliminate, and the adjustments of the module's own schema,
-- come after and read this.
--
-- **A party is a company of the group when its identifiers say so.** A contact
-- of one company of the perimeter is the other company when its VAT number is
-- that company's, or its registration number in the same country — both
-- compared as `ekwo.party_identifier()` compares them, the comparison
-- `merge_contacts()` and `suggest_duplicate_contacts()` already make. A name
-- is never enough: two companies may share one, and a group's figures are not
-- built on a guess.
--
-- **A sale pairs with a purchase by its number.** The seller's number is the
-- buyer's `supplier_reference`, compared the same way; an invoice with an
-- invoice, a credit note with a credit note. A sale whose purchase cannot be
-- found, and a purchase whose sale cannot, come out as such — never forced
-- onto the nearest document of the same amount.
--
-- **A difference is listed, never settled.** The currency or an amount that
-- differs, one side booked outside the period: each is a status of its row,
-- for a person to correct in the books of the company that is wrong.
--
-- **Read as the caller.** `require_readable()` first, so that no list comes out
-- short of a member somebody could not see; then the documents and contacts
-- of each company under their own row level security.

create or replace function consolidation.intragroup_parties(
  p_company_id uuid,
  p_group_id   uuid,
  p_from       date,
  p_to         date
)
returns table (
  company_id             uuid,
  contact_id             uuid,
  contact_name           text,
  counterpart_company_id uuid,
  recognised_by          text
)
language plpgsql
stable
set search_path = consolidation, ekwo, pg_temp
as $$
begin
  perform consolidation.require(p_company_id, 'consolidation.read', 'reading what the companies of a group trade with each other');
  if not exists (select 1 from consolidation.groups g where g.id = p_group_id and g.company_id = p_company_id) then
    raise exception 'consolidation_group_not_found: no group % in company %', p_group_id, p_company_id
      using errcode = 'P0002';
  end if;
  perform consolidation.require_readable(p_company_id, p_group_id, p_from, p_to);

  return query
    with companies_in as (
      select p_company_id as id
      union
      select m.member_company_id
        from consolidation.members m
       where m.group_id = p_group_id
         and m.company_id = p_company_id
         and m.entered_on <= p_to
         and (m.left_on is null or m.left_on >= p_from)
    )
    select k.company_id,
           k.id,
           k.name,
           o.id,
           case
             when ekwo.party_identifier(k.vat_number) = ekwo.party_identifier(o.vat_number) then 'vat_number'
             else 'registration_number'
           end
      from companies_in c
      join ekwo.contacts k on k.company_id = c.id and k.merged_into is null
      join companies_in oc on oc.id <> c.id
      join ekwo.companies o on o.id = oc.id
     where ekwo.party_identifier(k.vat_number) = ekwo.party_identifier(o.vat_number)
        or (k.country = o.country
            and ekwo.party_identifier(k.registration_number) = ekwo.party_identifier(o.registration_number))
     order by 1, 4, 3, 2;
end;
$$;

comment on function consolidation.intragroup_parties(uuid, uuid, date, date) is
  'The contacts of each company of a group between two dates that are another company of the same group: its VAT number is that company''s, or its registration number in the same country, as party_identifier() compares them. recognised_by says which. A contact named like a company of the group and carrying neither number is not one of them. Read as the caller, after require_readable().';

create or replace function consolidation.intragroup_documents(
  p_company_id uuid,
  p_group_id   uuid,
  p_from       date,
  p_to         date
)
returns table (
  seller_company_id       uuid,
  buyer_company_id        uuid,
  kind                    text,
  reference               text,
  sale_document_id        uuid,
  sale_date               date,
  sale_currency_code      char(3),
  sale_amount_untaxed     numeric,
  sale_amount_total       numeric,
  purchase_document_id    uuid,
  purchase_date           date,
  purchase_currency_code  char(3),
  purchase_amount_untaxed numeric,
  purchase_amount_total   numeric,
  status                  text
)
language plpgsql
stable
set search_path = consolidation, ekwo, pg_temp
as $$
begin
  if p_from is null or p_to is null or p_from > p_to then
    raise exception 'consolidation_invalid_period: a period runs from a first day to a last day, not from % to %', p_from, p_to
      using errcode = '22023';
  end if;

  return query
    with parties as (
      select * from consolidation.intragroup_parties(p_company_id, p_group_id, p_from, p_to)
    ),
    sales as (
      select d.company_id as seller,
             p.counterpart_company_id as buyer,
             case d.doc_type when 'sale_invoice' then 'invoice' else 'credit_note' end as kind,
             d.id,
             d.number as reference,
             ekwo.party_identifier(d.number) as key,
             coalesce(d.accounting_date, d.document_date) as on_date,
             d.currency_code,
             d.amount_untaxed,
             d.amount_total
        from ekwo.documents d
        join parties p on p.company_id = d.company_id and p.contact_id = d.contact_id
       where d.state = 'posted'
         and d.doc_type in ('sale_invoice', 'sale_credit_note')
    ),
    purchases as (
      select p.counterpart_company_id as seller,
             d.company_id as buyer,
             case d.doc_type when 'purchase_invoice' then 'invoice' else 'credit_note' end as kind,
             d.id,
             d.supplier_reference as reference,
             ekwo.party_identifier(d.supplier_reference) as key,
             coalesce(d.accounting_date, d.document_date) as on_date,
             d.currency_code,
             d.amount_untaxed,
             d.amount_total
        from ekwo.documents d
        join parties p on p.company_id = d.company_id and p.contact_id = d.contact_id
       where d.state = 'posted'
         and d.doc_type in ('purchase_invoice', 'purchase_credit_note')
    ),
    -- Who is in the group on which day: the parent always, a member while
    -- one of its periods holds the day.
    periods as (
      select p_company_id as company, date '-infinity' as entered_on, date 'infinity' as left_on
      union all
      select m.member_company_id, m.entered_on, coalesce(m.left_on, date 'infinity')
        from consolidation.members m
       where m.group_id = p_group_id
         and m.company_id = p_company_id
    ),
    pairs as (
      select coalesce(s.seller, b.seller) as seller,
             coalesce(s.buyer, b.buyer) as buyer,
             coalesce(s.kind, b.kind) as kind,
             coalesce(s.reference, b.reference) as reference,
             s.id as sale_id, s.on_date as sale_on, s.currency_code as sale_currency,
             s.amount_untaxed as sale_untaxed, s.amount_total as sale_total,
             b.id as purchase_id, b.on_date as purchase_on, b.currency_code as purchase_currency,
             b.amount_untaxed as purchase_untaxed, b.amount_total as purchase_total
        from sales s
        full join purchases b
          on b.seller = s.seller
         and b.buyer = s.buyer
         and b.kind = s.kind
         and b.key = s.key
    ),
    -- A side counts when it falls in the period and both companies are in
    -- the group on its date.
    counted as (
      select x.*,
             x.sale_id is not null and x.sale_on between p_from and p_to
               and exists (select 1 from periods g where g.company = x.seller and x.sale_on between g.entered_on and g.left_on)
               and exists (select 1 from periods g where g.company = x.buyer and x.sale_on between g.entered_on and g.left_on)
               as sale_in,
             x.purchase_id is not null and x.purchase_on between p_from and p_to
               and exists (select 1 from periods g where g.company = x.seller and x.purchase_on between g.entered_on and g.left_on)
               and exists (select 1 from periods g where g.company = x.buyer and x.purchase_on between g.entered_on and g.left_on)
               as purchase_in
        from pairs x
    )
    select x.seller,
           x.buyer,
           x.kind,
           x.reference,
           x.sale_id, x.sale_on, x.sale_currency, x.sale_untaxed, x.sale_total,
           x.purchase_id, x.purchase_on, x.purchase_currency, x.purchase_untaxed, x.purchase_total,
           case
             when x.sale_id is null then 'sale_missing'
             when x.purchase_id is null then 'purchase_missing'
             when x.sale_currency <> x.purchase_currency
               or x.sale_untaxed <> x.purchase_untaxed
               or x.sale_total <> x.purchase_total then 'amount_differs'
             when not (x.sale_in and x.purchase_in) then 'period_differs'
             else 'matched'
           end
      from counted x
     where x.sale_in or x.purchase_in
     order by x.seller, x.buyer, coalesce(x.sale_on, x.purchase_on), x.reference, x.kind;
end;
$$;

comment on function consolidation.intragroup_documents(uuid, uuid, date, date) is
  'What the companies of a group invoiced each other between two dates, one row per pair of documents: the posted sale of one company to a contact that is another company of the group (intragroup_parties()), and the posted purchase of that company from the first whose supplier_reference is the sale''s number, as party_identifier() compares them — an invoice with an invoice, a credit note with a credit note. A side counts when its date falls in the period and both companies are in the group on that date. status: matched (same currency, untaxed and total amounts, both sides in the period); amount_differs; period_differs (one side booked outside the period); purchase_missing (no purchase carries the sale''s number); sale_missing (no sale carries the purchase''s reference). Amounts in the currency of each document, as booked. Lists, writes nothing, forces no pair.';

-- ---------------------------------------------------------------------------
-- Privileges, by name
-- ---------------------------------------------------------------------------

revoke execute on function consolidation.intragroup_parties(uuid, uuid, date, date) from public, anon;
revoke execute on function consolidation.intragroup_documents(uuid, uuid, date, date) from public, anon;

grant execute on function consolidation.intragroup_parties(uuid, uuid, date, date) to authenticated, service_role;
grant execute on function consolidation.intragroup_documents(uuid, uuid, date, date) to authenticated, service_role;
