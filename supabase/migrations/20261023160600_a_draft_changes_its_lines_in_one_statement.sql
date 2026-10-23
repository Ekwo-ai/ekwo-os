-- Ekwo OS — a draft changes its lines in one statement.
--
-- Replacing the lines of a draft was two calls from the client: delete every
-- line, then insert the new ones. When the database refused the insert — a
-- discount of 100 % fails `document_lines_discount_range`, an account of
-- another company fails its foreign key — the delete had already happened,
-- and the draft was left with no line at all. Creating a document had the
-- same shape: the header, then its lines, so a refused line left an empty
-- draft behind.
--
-- Two functions make each of those one statement, and so one transaction:
-- either every line is written, or nothing changed.
--
--   replace_document_lines(document, lines)  the lines of a draft, replaced
--   create_document(document, lines)         a draft and its lines, created
--
-- Both are `security invoker`: the caller writes as themselves, and row level
-- security and the guards of the tables decide exactly as they did for the
-- two calls. A line is given as the client already wrote it — `name`,
-- `description`, `product_id`, `unit_code`, `unit_price`, `quantity`,
-- `discount_percent`, `account_id`, `tax_id`, `attributes` — and is numbered
-- 10, 20, 30… in the order given. What a line leaves out takes the default of
-- its column, and a null account is resolved by the trigger that always
-- resolved it.

create or replace function replace_document_lines(p_document_id uuid, p_lines jsonb)
returns integer
language plpgsql
security invoker
set search_path = public, pg_temp
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
    unit_code, unit_price, quantity, discount_percent, account_id, tax_id, attributes
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
         coalesce(l.line -> 'attributes', '{}'::jsonb)
    from jsonb_array_elements(p_lines) with ordinality as l(line, ordinality);

  get diagnostics v_count = row_count;
  return v_count;
end;
$$;

comment on function replace_document_lines(uuid, jsonb) is
  'Replaces every line of a draft with the lines given, in one statement: when the database refuses one of them, the draft keeps the lines it had. Security invoker, so row level security and the guards of document_lines decide as for a direct write.';

revoke execute on function replace_document_lines(uuid, jsonb) from public, anon;
grant execute on function replace_document_lines(uuid, jsonb) to authenticated, service_role;

create or replace function create_document(p_document jsonb, p_lines jsonb)
returns uuid
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
  v_id uuid;
begin
  if p_document is null or jsonb_typeof(p_document) <> 'object' then
    raise exception 'document_not_an_object: the header of a document is a JSON object'
      using errcode = '22023';
  end if;

  insert into documents (
    company_id, doc_type, contact_id, document_date, due_date, accounting_date, number,
    supplier_reference, currency_code, journal_id, payment_reference, client_ref
  )
  values (
    (p_document ->> 'company_id')::uuid,
    (p_document ->> 'doc_type')::doc_type,
    (p_document ->> 'contact_id')::uuid,
    (p_document ->> 'document_date')::date,
    (p_document ->> 'due_date')::date,
    (p_document ->> 'accounting_date')::date,
    p_document ->> 'number',
    p_document ->> 'supplier_reference',
    p_document ->> 'currency_code',
    (p_document ->> 'journal_id')::uuid,
    p_document ->> 'payment_reference',
    p_document ->> 'client_ref'
  )
  returning id into v_id;

  perform replace_document_lines(v_id, p_lines);
  return v_id;
end;
$$;

comment on function create_document(jsonb, jsonb) is
  'Creates a draft and its lines in one statement: a refused line creates nothing, rather than an empty draft. The header names company_id, doc_type, contact_id, document_date and currency_code, and optionally due_date, accounting_date, number, supplier_reference, journal_id, payment_reference and client_ref. Security invoker.';

revoke execute on function create_document(jsonb, jsonb) from public, anon;
grant execute on function create_document(jsonb, jsonb) to authenticated, service_role;
