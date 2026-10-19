-- Ekwo OS — a line carries what its format asks of it, and a product says it once.
--
-- An electronic invoice that a tax authority clears before it is issued asks
-- of every line more than the books held: which entry of the authority's own
-- list of goods and services it is, and — where the line is exempted from a
-- tax — the reason, in words, often with the number of the buyer's exemption
-- certificate. The country pack gives what holds for every line
-- (`einvoicing.fiscalisation.line_attributes`) and for every line of a tax
-- (`tax_attributes`); what differs from one line to the next is a fact of
-- that line, or of the product it sells, and had no column.
--
-- So nothing here is named after a country or a format:
--
--   * `products.attributes` and `document_lines.attributes` hold, by name,
--     what a format asks of a line that no other column says:
--     `{"<name>": "<value>"}`. The name is the one the format's brick reads,
--     and the country pack says which ones (docs/packs.md, "Fiscalisation");
--     a line's attribute wins over the pack's for that line.
--   * A line filled in from a product takes the product's attributes it does
--     not carry itself, when it is written or its product changes: the
--     product pre-fills the line and never overrides it, as its price and its
--     account do. A credit note takes the attributes of the lines it undoes,
--     as they were issued.
--   * `document_line_items` publishes the line's attributes, appended.
--
-- A line is frozen with its document once posted, its attributes with it:
-- the guard of posted lines covers every column.
--
-- Additive: one column on each table, one trigger, `cancel_document()`
-- republished whole with one column more in the lines it copies, and one view
-- replaced with one column appended. The tables keep their policies and their
-- grants, which are by table; the view keeps its grant, given again below as
-- the rule asks.

alter table products
  add column if not exists attributes jsonb not null default '{}'::jsonb;

alter table document_lines
  add column if not exists attributes jsonb not null default '{}'::jsonb;

-- An object of non-blank texts under non-blank names, as `identifiers`: an
-- attribute without a value is no attribute.
alter table products
  add constraint products_attributes_shape check (
    jsonb_typeof(attributes) = 'object'
    and not (attributes ? '')
    and not jsonb_path_exists(attributes, '$.* ? (@.type() != "string" || @ like_regex "^\\s*$")')
  );

alter table document_lines
  add constraint document_lines_attributes_shape check (
    jsonb_typeof(attributes) = 'object'
    and not (attributes ? '')
    and not jsonb_path_exists(attributes, '$.* ? (@.type() != "string" || @ like_regex "^\\s*$")')
  );

comment on column products.attributes is
  'What an electronic invoice format asks of a line selling this product that no other column says, by the name the format''s brick reads: {"<name>": "<value>"} — the entry of a tax authority''s list of goods and services, the reason of an exemption. The country pack says which names its format reads. A line filled in from the product takes the ones it does not carry. Empty, not null, where there is none.';

comment on column document_lines.attributes is
  'What an electronic invoice format asks of this line that no other column says, by the name the format''s brick reads: {"<name>": "<value>"}, as products.attributes. Wins over the country pack''s line_attributes and tax_attributes for this line. Pre-filled from the product with the names the line does not carry; frozen with the document once posted. Empty, not null, where there is none.';

-- ---------------------------------------------------------------------------
-- 1. The product pre-fills the line
-- ---------------------------------------------------------------------------

create or replace function document_lines_attributes_from_product()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
begin
  -- A credit note copies the lines it undoes as they were issued, attributes
  -- included: what the product says today is not what the invoice said.
  if new.product_id is null
     or current_setting('ekwo.crediting_document', true) = new.document_id::text then
    return new;
  end if;
  select coalesce(p.attributes, '{}'::jsonb) || coalesce(new.attributes, '{}'::jsonb)
    into new.attributes
    from products p
   where p.id = new.product_id;
  new.attributes := coalesce(new.attributes, '{}'::jsonb);
  return new;
end;
$$;

comment on function document_lines_attributes_from_product() is
  'Pre-fills the attributes of a document line from those of its product, for every name the line does not carry, when the line is written or its product changes. Never replaces what the line carries, and leaves alone the lines a credit note copies from the invoice it undoes.';

revoke execute on function document_lines_attributes_from_product() from public, anon, authenticated, service_role;

drop trigger if exists document_lines_attributes_from_product on document_lines;
create trigger document_lines_attributes_from_product
  before insert or update of product_id on document_lines
  for each row execute function document_lines_attributes_from_product();

-- ---------------------------------------------------------------------------
-- 2. The lines view publishes them
--
-- `20260915195000` to the letter, with `attributes` appended.
-- ---------------------------------------------------------------------------

create or replace view document_line_items
  with (security_invoker = true) as
  select l.id                          as document_line_id,
         l.document_id,
         l.company_id,
         l.sequence,
         l.line_type,
         l.name                        as item_name,               -- BT-153
         l.description                 as item_description,        -- BT-154
         p.code                        as seller_item_identifier,  -- BT-155
         l.product_id,
         p.kind                        as product_kind,
         l.quantity,                                               -- BT-129
         l.unit_code,                                              -- BT-130
         l.unit_price,                   -- as keyed; gross where the tax is in it
         l.discount_percent,
         l.amount_untaxed,                                         -- BT-131
         l.tax_id,
         l.vat_category,                                           -- BT-151
         l.vat_rate,                                               -- BT-152
         l.account_id,
         t.treatment                   as tax_treatment,
         t.exemption_code              as tax_exemption_code,      -- BT-121
         t.cash_basis                  as tax_cash_basis,
         l.unit_price_includes_tax,
         l.amount_incl_tax,
         l.attributes
    from document_lines l
    left join products p on p.id = l.product_id
    left join taxes t    on t.id = l.tax_id;

comment on view document_line_items is
  'Document lines with the EN 16931 item terms — BT-153 name, BT-154 description, BT-155 the seller identifier — what decides a legal mention on the line, and, where the price was quoted with the tax in it, the gross it was quoted at. unit_price is the price as keyed, which is that gross: BT-146 is the net price and this view does not publish it yet. attributes is what an electronic invoice format asks of the line that no other column says, by name.';

grant select on table document_line_items to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 3. cancel_document, which copies the attributes too
--
-- `20261019130000` as it is, with `attributes` among the columns of each line
-- the credit note copies.
-- ---------------------------------------------------------------------------

create or replace function cancel_document(p_document_id uuid, p_date date default null)
returns documents
language plpgsql
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
  -- which the guard lets through for this credit note alone.
  perform set_config('ekwo.crediting_document', v_credit.id::text, true);
  for r in
    select l.* from document_lines l
     where l.document_id = v_doc.id
     order by l.sequence, l.id
  loop
    insert into document_lines (document_id, company_id, sequence, line_type, name, description,
                                quantity, unit_code, unit_price, discount_percent,
                                tax_id, account_id, product_id, attributes)
    values (v_credit.id, r.company_id, r.sequence, r.line_type, r.name, r.description,
            r.quantity, r.unit_code, r.unit_price, r.discount_percent,
            r.tax_id, r.account_id, r.product_id, r.attributes)
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

comment on function cancel_document(uuid, date) is
  'Undoes a posted invoice: writes its credit note — the same lines, taxes, accounts, attributes, contact, currency, rate and analytic split — naming it in reversed_document_id, posts it through post_document(), matches the two entries and marks the invoice cancelled. Returns the credit note. Dated on the invoice''s booking day while that period is open, and otherwise refused until a date is given (reversal_date_needed). Refused for a document that is not a posted invoice, is already cancelled or credited, or is settled in part or in full (unreconcile() first).';
