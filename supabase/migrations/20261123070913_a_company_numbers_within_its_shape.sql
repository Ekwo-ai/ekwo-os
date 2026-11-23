-- Ekwo OS — a company's own numbering is held to the shape its pack gives a
-- document number.
--
-- `20261123070912` gave the pack its say, `country_defaults.number_shape`, and
-- the one reading of it, `number_shape_refusal()`. This file asks it at the
-- two moments a company's numbers change shape: when the company changes its
-- pattern (`companies.number_format`), for every journal it has; when a
-- journal changes its prefix or its code (`journals.number_prefix`), under the
-- pattern the company numbers with. Refused with `number_shape_refused`, the
-- journal and the country named.
--
-- Both are updates. A company and its journals are inserted by the installer,
-- by `create_company()` from the pack — whose own pattern `ekwo pack check`
-- has already held to its shape — and by an archive being restored, which
-- brings back what was valid when it was written and is not refused for a
-- rule that came after.

-- ---------------------------------------------------------------------------
-- 1. A company's pattern, for every journal it has
--
-- Definer, like `companies_number_format_carries()`: it reads the journals of
-- the company whose update the policy of `companies` has already let through.
-- ---------------------------------------------------------------------------

create or replace function ekwo.companies_number_format_fits_its_country()
returns trigger
language plpgsql
security definer
set search_path = ekwo, pg_temp
as $$
declare
  v_country char(2) := coalesce(new.fiscal_country, new.country);
  v_shape   jsonb := number_shape_of(new.id);
  v_format  text;
  v_journal record;
  v_refusal text;
begin
  if v_shape is null then
    return new;
  end if;
  v_format := coalesce(new.number_format, (select r.pack_number_format from numbering_rules(new.id) r));

  for v_journal in
    select j.code, coalesce(j.number_prefix, j.code) as printed
      from journals j
     where j.company_id = new.id
     order by j.code
  loop
    v_refusal := number_shape_refusal(v_shape, v_format, v_journal.printed);
    if v_refusal is not null then
      raise exception 'number_shape_refused: journal %: %, under the law of %',
        v_journal.code, v_refusal, v_country
        using errcode = '23514';
    end if;
  end loop;
  return new;
end;
$$;

comment on function ekwo.companies_number_format_fits_its_country() is
  'Refuses a change of companies.number_format whose numbers, printed with the prefix of any journal of the company, do not fit the shape the country pack gives a document number (country_defaults.number_shape).';

revoke execute on function ekwo.companies_number_format_fits_its_country() from public, anon, authenticated, service_role;

drop trigger if exists companies_number_format_fits_its_country on ekwo.companies;
create trigger companies_number_format_fits_its_country
  before update of number_format on ekwo.companies
  for each row
  when (old.number_format is distinct from new.number_format)
  execute function ekwo.companies_number_format_fits_its_country();

-- ---------------------------------------------------------------------------
-- 2. A journal's prefix, under the pattern the company numbers with
-- ---------------------------------------------------------------------------

create or replace function ekwo.journals_number_prefix_fits_its_country()
returns trigger
language plpgsql
security definer
set search_path = ekwo, pg_temp
as $$
declare
  v_country char(2);
  v_shape   jsonb := number_shape_of(new.company_id);
  v_format  text;
  v_refusal text;
begin
  if v_shape is null then
    return new;
  end if;
  select r.number_format into v_format from numbering_rules(new.company_id) r;
  select coalesce(c.fiscal_country, c.country) into v_country from companies c where c.id = new.company_id;

  v_refusal := number_shape_refusal(v_shape, v_format, coalesce(new.number_prefix, new.code));
  if v_refusal is not null then
    raise exception 'number_shape_refused: journal %: %, under the law of %',
      new.code, v_refusal, v_country
      using errcode = '23514';
  end if;
  return new;
end;
$$;

comment on function ekwo.journals_number_prefix_fits_its_country() is
  'Refuses a change of a journal''s number_prefix or code whose numbers, under the pattern the company numbers with, do not fit the shape the country pack gives a document number (country_defaults.number_shape).';

revoke execute on function ekwo.journals_number_prefix_fits_its_country() from public, anon, authenticated, service_role;

drop trigger if exists journals_number_prefix_fits_its_country on ekwo.journals;
create trigger journals_number_prefix_fits_its_country
  before update of number_prefix, code on ekwo.journals
  for each row
  when (old.number_prefix is distinct from new.number_prefix or old.code is distinct from new.code)
  execute function ekwo.journals_number_prefix_fits_its_country();
