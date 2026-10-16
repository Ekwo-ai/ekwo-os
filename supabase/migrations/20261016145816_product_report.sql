-- Ekwo OS — what each product brought in, and cost, read from the documents.
--
-- A product fills a line in and the ledger never knows it: `post_document()`
-- books the line to its account, and `document_lines.product_id` is the one
-- place that remembers which product it was. So "what did this line of
-- service bring in this year" has had no answer but a query somebody writes
-- by hand — and every hand writes the sign of a credit note, the state of a
-- draft and the currency of the document a little differently.
--
-- `product_report(company, from, to)` is that answer, once. For each product
-- named on a line of a posted invoice or credit note dated in the period, on
-- each side — what was sold, what was bought — it gives how many documents
-- named it, the quantity, and the untaxed amount in the company's currency,
-- a credit note counting against its invoice. A draft says nothing, a quote
-- and an order say nothing, a line with no product is not reported, and
-- nothing is written: it is a reading of the documents, as `trial_balance()`
-- is a reading of the ledger. A retired product keeps reporting what it did
-- while it was offered, and says it is retired.
--
-- The amount is the line's untaxed amount brought to the company's currency
-- at the document's rate, the way `post_document()` books it, and rounded at
-- the currency's decimals (`round_amount`, `rounding_of`). Security invoker:
-- the caller reads the lines the row level security of `document_lines` and
-- `documents` lets them read, which is `documents.read`, and nothing more.

create or replace function product_report(
  p_company_id uuid,
  p_from       date,
  p_to         date
)
returns table (
  product_id     uuid,
  code           text,
  name           text,
  kind           product_kind,
  active         boolean,
  side           text,
  document_count integer,
  quantity       numeric,
  amount         numeric
)
language plpgsql
stable
security invoker
as $$
declare
  v_round money_rounding;
begin
  if p_from is null or p_to is null or p_from > p_to then
    raise exception 'invalid_period: a period runs from a day to a later one, not from % to %',
      coalesce(p_from::text, 'null'), coalesce(p_to::text, 'null');
  end if;
  v_round := rounding_of(p_company_id);

  return query
  with named as (
    select l.product_id as product,
           case when d.doc_type in ('sale_invoice', 'sale_credit_note') then 'sale' else 'purchase' end as on_side,
           case when d.doc_type in ('sale_credit_note', 'purchase_credit_note') then -1 else 1 end as sign,
           d.id as document,
           l.quantity as units,
           l.amount_untaxed / d.exchange_rate as untaxed
      from document_lines l
      join documents d on d.id = l.document_id
     where l.company_id = p_company_id
       and l.product_id is not null
       and l.line_type = 'product'
       and d.state = 'posted'
       and d.doc_type in ('sale_invoice', 'sale_credit_note', 'purchase_invoice', 'purchase_credit_note')
       and d.document_date between p_from and p_to
  )
  select p.id,
         p.code,
         p.name,
         p.kind,
         p.active,
         n.on_side,
         count(distinct n.document)::integer,
         sum(n.sign * n.units),
         round_amount(sum(n.sign * n.untaxed), v_round)
    from named n
    join products p on p.id = n.product
   group by p.id, p.code, p.name, p.kind, p.active, n.on_side
   order by n.on_side, p.code;
end;
$$;

comment on function product_report(uuid, date, date) is
  'What each product brought in and cost over a period, read from the posted invoices and credit notes dated in it: for each product named on a line, on each side (sale, purchase), the documents that named it, the quantity and the untaxed amount in the company''s currency, a credit note counting against its invoice. Drafts, quotes, orders and lines naming no product say nothing. A retired product keeps reporting, with active false. Security invoker: documents.read, through the row level security of the lines.';

revoke execute on function product_report(uuid, date, date) from public, anon;
grant execute on function product_report(uuid, date, date) to authenticated, service_role;
