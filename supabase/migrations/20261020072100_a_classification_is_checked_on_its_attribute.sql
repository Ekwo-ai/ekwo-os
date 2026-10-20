-- Ekwo OS — a classification is an attribute of the line, checked against the
-- pattern its country declares.
--
-- An invoice of goods often has to say what the goods are, by a code of a
-- nomenclature: the Harmonized System of the World Customs Organization at
-- six digits, a national extension of it at eight or ten — the Combined
-- Nomenclature of an Intrastat return, the Mercosur Common Nomenclature of a
-- South American electronic invoice — or the list of an authority's own
-- e-invoicing format. EN 16931 carries it as BT-158, the item classification
-- identifier, with its scheme in BT-158-1.
--
-- `20261019170000` already gave the line and the product the place to hold
-- such a code: `attributes`, `{"<name>": "<value>"}`, under the name the
-- brick of the format reads, pre-filled from the product and frozen once the
-- document is posted. One fact keeps that one place. What it lacked is the
-- check: nothing said that the code of a nomenclature has a shape, and a
-- typing error reached the authority.
--
-- So the pack declares, for the attributes that are classifications, the
-- pattern their codes match and the text that prescribes them, and the
-- database refuses a code off its pattern by name:
--
--   * `classification_schemes` is reference data compiled from the pack, by
--     country and attribute name: what the classification is called, the
--     anchored pattern of its codes, the article that asks for it. A pack that
--     declares none has none, and its attributes are checked by nothing more
--     than their shape, as before.
--   * `assert_classifications()` is the one check, asked by a trigger on
--     `products` and on `document_lines`: an attribute whose name is a
--     classification of the company's country must match its pattern,
--     `classification_code_invalid`. An attribute of any other name is the
--     format's own business and passes.
--   * The trigger of the line fires after `document_lines_attributes_from_product`
--     (triggers of one event fire by name), so a code the line takes from
--     its product is checked as the line's own.
--
-- Additive: one table, one function, two triggers and their functions.
-- Decision 0078 records the choice.

-- ---------------------------------------------------------------------------
-- 1. The classifications a country declares
-- ---------------------------------------------------------------------------

create table if not exists classification_schemes (
  country         char(2) not null,
  -- The name of the attribute that holds the code, as the brick of the format
  -- reads it in `document_lines.attributes` and `products.attributes`.
  attribute       text    not null,
  name            text    not null,
  -- An anchored regular expression every code matches, in the dialect
  -- Postgres and the pack compiler share (classes, ranges and quantifiers).
  pattern         text    not null,
  legal_reference text    not null,
  source_key      text,
  sequence        integer not null default 10,
  primary key (country, attribute),
  constraint classification_schemes_country_format check (country ~ '^[A-Z]{2}$'),
  constraint classification_schemes_attribute_format check (attribute ~ '^[a-z][a-z0-9_]{0,39}$'),
  constraint classification_schemes_pattern_anchored check (pattern ~ '^\^.*\$$')
);

comment on table classification_schemes is
  'The classifications of goods and services a country uses on its documents, compiled from its pack: the attribute of a line or a product that holds the code, the name of the classification, the anchored pattern of its codes and the article that prescribes it. A code held under one of these names in document_lines.attributes or products.attributes must match the pattern (decision 0078).';

alter table classification_schemes enable row level security;

create policy classification_schemes_select on classification_schemes
  for select using (is_known_caller());

grant select on table classification_schemes to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 2. The one check, and where it is asked
-- ---------------------------------------------------------------------------

create or replace function assert_classifications(p_company_id uuid, p_attributes jsonb, p_what text)
returns void
language plpgsql
stable
set search_path = public, pg_temp
as $$
declare
  r record;
begin
  if p_attributes is null or p_attributes = '{}'::jsonb then
    return;
  end if;
  for r in
    select a.key, a.value, s.pattern
      from companies c
      join classification_schemes s on s.country = c.fiscal_country
      join lateral jsonb_each_text(p_attributes) a on a.key = s.attribute
     where c.id = p_company_id
     order by s.sequence, a.key
  loop
    if r.value !~ r.pattern then
      raise exception 'classification_code_invalid: % gives % as its %, which takes codes of the pattern %',
        p_what, r.value, r.key, r.pattern
        using errcode = '23514';
    end if;
  end loop;
end;
$$;

comment on function assert_classifications(uuid, jsonb, text) is
  'Refuses classification_code_invalid when an attribute whose name is a classification of the company''s fiscal country, in classification_schemes, holds a code off its pattern. Attributes of any other name pass. The one check of the classifications held in products.attributes and document_lines.attributes.';

revoke execute on function assert_classifications(uuid, jsonb, text) from public, anon;
grant execute on function assert_classifications(uuid, jsonb, text) to authenticated, service_role;

create or replace function products_check_classifications()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
begin
  perform assert_classifications(new.company_id, new.attributes, 'product ' || new.code);
  return new;
end;
$$;

comment on function products_check_classifications() is
  'Asks assert_classifications() of a product whose attributes are written.';

revoke execute on function products_check_classifications() from public, anon, authenticated, service_role;

drop trigger if exists products_check_classifications on products;
create trigger products_check_classifications
  before insert or update of attributes on products
  for each row execute function products_check_classifications();

create or replace function document_lines_check_classifications()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
begin
  perform assert_classifications(new.company_id, new.attributes,
                                 'line ' || coalesce(new.sequence::text, '?'));
  return new;
end;
$$;

comment on function document_lines_check_classifications() is
  'Asks assert_classifications() of a document line whose attributes or product are written, after the product has pre-filled them.';

revoke execute on function document_lines_check_classifications() from public, anon, authenticated, service_role;

drop trigger if exists document_lines_check_classifications on document_lines;
create trigger document_lines_check_classifications
  before insert or update of attributes, product_id on document_lines
  for each row execute function document_lines_check_classifications();
