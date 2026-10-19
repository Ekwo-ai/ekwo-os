-- Ekwo OS — a line names what was sold, by the classification of its country.
--
-- An invoice of goods often has to say what the goods are, by a code of a
-- nomenclature: the Harmonized System of the World Customs Organization at
-- six digits, a national extension of it at eight or ten — the Combined
-- Nomenclature of an Intrastat return, the Mercosur Common Nomenclature on a
-- Brazilian electronic invoice — or the classification list of an
-- authority's own e-invoicing format. EN 16931 carries it as BT-158, the item
-- classification identifier, with its scheme in BT-158-1.
--
-- The books held none of it. `products` names the seller's own code (BT-155),
-- and the `line_attributes` of a fiscalisation regime give *every* line of a
-- country one constant value — a default, not a fact about the line.
--
-- So the classification is written the way the identifiers of a party were
-- (`20261019150000`): by the code of its scheme, in one column, and nothing
-- named after a country or a format.
--
--   * `classification_schemes` is reference data compiled from the pack: the
--     schemes a country uses, each with its name, the pattern of its codes and
--     the article that prescribes it. A pack that declares none has none.
--   * `products.classifications` and `document_lines.classifications` hold
--     `{"<scheme>": "<code>"}`. A line takes its product's on insert, when it
--     names a product and says nothing of its own; after that it is the
--     line's, and frozen with the document like every other column of it.
--   * A code is refused by name where its scheme is not one the pack of the
--     company's country declares, `classification_scheme_unknown`, and where
--     it does not match the scheme's pattern, `classification_code_invalid`.
--   * `document_line_items` publishes the column, so an e-invoicing format
--     reads the code beside the line it describes.
--
-- Additive: one table, two columns, one function, two triggers, one view
-- replaced with a column appended. Decision 0078 records the choice.

-- ---------------------------------------------------------------------------
-- 1. The schemes a country uses
-- ---------------------------------------------------------------------------

create table if not exists classification_schemes (
  country         char(2) not null,
  -- The code the scheme is known by in the format that carries it, upper
  -- case: what BT-158-1 says, or the list identifier of a national format.
  scheme          text    not null,
  name            text    not null,
  -- An anchored regular expression every code of the scheme matches, in the
  -- dialect Postgres and the pack compiler share (classes and quantifiers).
  pattern         text    not null,
  legal_reference text    not null,
  source_key      text,
  sequence        integer not null default 10,
  primary key (country, scheme),
  constraint classification_schemes_country_format check (country ~ '^[A-Z]{2}$'),
  constraint classification_schemes_scheme_format check (scheme ~ '^[A-Z0-9][A-Z0-9_-]{0,15}$'),
  constraint classification_schemes_pattern_anchored check (pattern ~ '^\^.*\$$')
);

comment on table classification_schemes is
  'The classifications of goods and services a country uses on its documents, compiled from its pack: the scheme code (BT-158-1, or the list identifier of a national format), its name, the anchored pattern of its codes and the article that prescribes it. A line or a product carries a code only of a scheme its company''s country declares here (decision 0078).';

alter table classification_schemes enable row level security;

create policy classification_schemes_select on classification_schemes
  for select using (is_known_caller());

grant select on table classification_schemes to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 2. What a product and a line carry
-- ---------------------------------------------------------------------------

alter table products
  add column if not exists classifications jsonb not null default '{}'::jsonb;

alter table document_lines
  add column if not exists classifications jsonb not null default '{}'::jsonb;

-- An object of non-blank texts under non-blank keys, as the identifiers of a
-- party: a scheme without a code is no classification, and a code is written
-- as its nomenclature writes it, leading zeros included.
alter table products
  add constraint products_classifications_shape check (
    jsonb_typeof(classifications) = 'object'
    and not (classifications ? '')
    and not jsonb_path_exists(classifications, '$.* ? (@.type() != "string" || @ like_regex "^\\s*$")')
  );

alter table document_lines
  add constraint document_lines_classifications_shape check (
    jsonb_typeof(classifications) = 'object'
    and not (classifications ? '')
    and not jsonb_path_exists(classifications, '$.* ? (@.type() != "string" || @ like_regex "^\\s*$")')
  );

comment on column products.classifications is
  'What the product is, by the code of each classification its company''s country declares in classification_schemes: {"<scheme>": "<code>"}. Copied onto a document line that names the product and says nothing of its own. Empty, not null, where there is none.';

comment on column document_lines.classifications is
  'EN 16931 BT-158 by its scheme BT-158-1: {"<scheme>": "<code>"}, each scheme one the pack of the company''s country declares in classification_schemes and each code matching its pattern. Taken from the product on insert when the line names one and says nothing of its own; frozen with the document once it is posted. Empty, not null, where there is none.';

-- ---------------------------------------------------------------------------
-- 3. The one check, and where it is asked
-- ---------------------------------------------------------------------------

create or replace function assert_classifications(p_company_id uuid, p_classifications jsonb, p_what text)
returns void
language plpgsql
stable
set search_path = public, pg_temp
as $$
declare
  v_country char(2);
  v_scheme  record;
  r         record;
begin
  if p_classifications is null or p_classifications = '{}'::jsonb then
    return;
  end if;
  select coalesce(c.fiscal_country, c.country) into v_country
    from companies c where c.id = p_company_id;

  for r in select key, value from jsonb_each_text(p_classifications) order by key
  loop
    select s.scheme, s.pattern into v_scheme
      from classification_schemes s
     where s.country = v_country and s.scheme = r.key;
    if not found then
      raise exception 'classification_scheme_unknown: % names the classification %, which the pack of % does not declare; it declares %',
        p_what, r.key, coalesce(v_country, 'its country'),
        coalesce((select string_agg(s.scheme, ', ' order by s.sequence, s.scheme)
                    from classification_schemes s where s.country = v_country), 'none')
        using errcode = '23514';
    end if;
    if r.value !~ v_scheme.pattern then
      raise exception 'classification_code_invalid: % gives % as a code of %, which takes codes of the pattern %',
        p_what, r.value, r.key, v_scheme.pattern
        using errcode = '23514';
    end if;
  end loop;
end;
$$;

comment on function assert_classifications(uuid, jsonb, text) is
  'Refuses classification_scheme_unknown when a classification names a scheme the pack of the company''s country does not declare in classification_schemes, and classification_code_invalid when a code does not match its scheme''s pattern. The one check of products.classifications and document_lines.classifications.';

revoke execute on function assert_classifications(uuid, jsonb, text) from public, anon;
grant execute on function assert_classifications(uuid, jsonb, text) to authenticated, service_role;

create or replace function products_check_classifications()
returns trigger
language plpgsql
as $$
begin
  perform assert_classifications(new.company_id, new.classifications, 'product ' || new.code);
  return new;
end;
$$;

comment on function products_check_classifications() is
  'Asks assert_classifications() of a product whose classifications are written.';

create trigger products_check_classifications
  before insert or update of classifications on products
  for each row execute function products_check_classifications();

revoke execute on function products_check_classifications() from public, anon, authenticated, service_role;

-- A line that names a product and says nothing of its own takes the
-- product's, once, on insert: the same moment `resolve_line_account()` gives
-- it the product's account. What it holds after that is the line's own.
create or replace function document_lines_check_classifications()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'INSERT' and new.product_id is not null
     and new.classifications = '{}'::jsonb then
    select p.classifications into new.classifications
      from products p where p.id = new.product_id;
    new.classifications := coalesce(new.classifications, '{}'::jsonb);
  end if;
  perform assert_classifications(new.company_id, new.classifications,
                                 'line ' || coalesce(new.sequence::text, '?'));
  return new;
end;
$$;

comment on function document_lines_check_classifications() is
  'Gives a line that names a product and no classification of its own the product''s, on insert, and asks assert_classifications() of what the line carries.';

create trigger document_lines_check_classifications
  before insert or update of classifications on document_lines
  for each row execute function document_lines_check_classifications();

revoke execute on function document_lines_check_classifications() from public, anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 4. The line items publish it
--
-- `20260915195000` as it was, with the column appended.
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
         -- BT-158 with its scheme BT-158-1: what was sold, by the code of
         -- each classification the country's pack declares.
         l.classifications
    from document_lines l
    left join products p on p.id = l.product_id
    left join taxes t    on t.id = l.tax_id;

comment on view document_line_items is
  'Document lines with the EN 16931 item terms — BT-153 name, BT-154 description, BT-155 the seller identifier — what decides a legal mention on the line, and, where the price was quoted with the tax in it, the gross it was quoted at. unit_price is the price as keyed, which is that gross: BT-146 is the net price and this view does not publish it yet. classifications is BT-158 by its scheme BT-158-1: {"<scheme>": "<code>"}, each scheme one the pack of the company''s country declares (decision 0078).';

grant select on table document_line_items to authenticated, service_role;
