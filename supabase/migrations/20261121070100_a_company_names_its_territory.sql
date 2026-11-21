-- Ekwo OS — a company names the territory it is established in, and a pack
-- can require it.
--
-- `companies.territory_code` arrived with `20260916125000` so that a tax could
-- follow the territory of the parties: a Californian sales tax applies to a
-- seller in US-CA, and `post_document()` refuses it to anybody else. The
-- column could be read and never written by any route a person takes — not
-- by `create_company()`, not by `ekwo init`, not by the profile of the
-- company — so a company of a country whose taxes are levied below the
-- country could keep books and never post a sale under them. Only the golden
-- scenarios, which write the column with SQL, ever had one.
--
-- Two things change, and nothing else.
--
-- **A pack can say the question has to be answered.** In the United States
-- there is no national sales tax: every tax the pack carries is a state's, and
-- which of them reaches a sale starts with the state the seller is in. No
-- territory is the right default there, so the pack says
-- `defaults.territory_required` and `country_defaults.territory_required`
-- carries it. Where a pack says nothing the column is false and a company is
-- created exactly as before — the country is the answer, which is every
-- country of the common system of VAT.
--
-- **`create_company()` takes the territory.** One argument more, at the end
-- and with a default, so a caller that named the others by position or by
-- name calls it as before. A territory that does not lie within the company's
-- country is refused (`territory_outside_country`), and so is no territory
-- where the pack requires one (`territory_required`), before anything is
-- written. The function is dropped and created again because its arguments
-- change; its body is the one of `20261007113412` but for the territory, its
-- comment is completed and its grants are the same.
--
-- A trigger holds the same two rules for every other route — the profile of
-- the company, `update companies` by a person or a key: a territory outside
-- the country is refused, and a territory a required pack has once been
-- answered with cannot be taken back to nothing. It does not require one on
-- insert: the installer and an import write companies of their own, and the
-- question is asked where a person creates one.

-- ---------------------------------------------------------------------------
-- 1. The pack's answer
-- ---------------------------------------------------------------------------

alter table ekwo.country_defaults
  add column if not exists territory_required boolean not null default false;

comment on column ekwo.country_defaults.territory_required is
  'True where a company of this country has to name the territory it is established in, among the territories within the country: the taxes of the pack are levied below the country, and none of them can be told to apply without it. From `defaults.territory_required` of the pack; false, the country being the answer, everywhere else.';

-- ---------------------------------------------------------------------------
-- 2. The rule on the column, for every route
-- ---------------------------------------------------------------------------

create or replace function ekwo.companies_territory_within_country()
returns trigger
language plpgsql
set search_path = ekwo, pg_temp
as $$
declare
  v_country char(2) := coalesce(new.fiscal_country, new.country);
begin
  if new.territory_code is not null
     and not territory_within(new.territory_code, v_country) then
    raise exception 'territory_outside_country: % is not a territory of %', new.territory_code, v_country
      using errcode = '22023';
  end if;
  if tg_op = 'UPDATE'
     and new.territory_code is null
     and old.territory_code is not null
     and coalesce((select d.territory_required from country_defaults d where d.country = v_country), false) then
    raise exception 'territory_required: a company of % names the territory it is established in; name another one rather than none', v_country
      using errcode = '22023';
  end if;
  return new;
end;
$$;

comment on function ekwo.companies_territory_within_country() is
  'Refuses a companies.territory_code that does not lie within the company''s fiscal country, and taking it back to null where the country pack requires one. Required on creation by create_company() and ekwo init, not here: the installer and an import write companies of their own.';

drop trigger if exists companies_territory_within_country on ekwo.companies;
create trigger companies_territory_within_country
  before insert or update of territory_code, country, fiscal_country on ekwo.companies
  for each row execute function ekwo.companies_territory_within_country();

-- ---------------------------------------------------------------------------
-- 3. create_company() takes the territory
-- ---------------------------------------------------------------------------

drop function if exists ekwo.create_company(text, char, char, char, text, integer, date, uuid);

create function ekwo.create_company(
  p_name              text,
  p_country           char(2),
  p_currency_code     char(3) default null,
  p_language          char(2) default null,
  p_chart_code        text    default null,
  p_fiscal_year       integer default null,
  p_fiscal_year_start date    default null,
  p_owner_user_id     uuid    default null,
  p_territory_code    text    default null
)
returns ekwo.companies
language plpgsql
security definer
set search_path = ekwo, pg_temp
as $$
declare
  v_defaults  country_defaults%rowtype;
  v_currency  char(3);
  v_language  char(2);
  v_territory text := nullif(upper(btrim(p_territory_code)), '');
  v_owner     uuid := coalesce(p_owner_user_id, auth.uid());
  v_year      integer := coalesce(p_fiscal_year, extract(year from coalesce(p_fiscal_year_start, current_date))::integer);
  v_bounds    record;
  v_company   companies%rowtype;
  v_sharing   record;
  v_owned     integer;
begin
  if not is_installer() and not is_instance_admin() then
    select * into v_sharing from instance_sharing();
    if not v_sharing.shared then
      raise exception 'not_instance_admin: creating a company is an instance-level act'
        using errcode = '42501';
    end if;
    -- A person, in their own session. A key does not choose who owns a company.
    if auth.uid() is null or nullif(current_setting('ekwo.api_key', true), '') is not null then
      raise exception 'not_allowed: a company of one''s own is created by a signed-in person, in their own session'
        using errcode = '42501';
    end if;
    if p_owner_user_id is not null and p_owner_user_id is distinct from auth.uid() then
      raise exception 'not_allowed: a company of one''s own is owned by whoever creates it'
        using errcode = '42501';
    end if;
    v_owner := auth.uid();
    -- What the person created, whoever owns it now: handing a company to a
    -- second account does not give the allowance back.
    perform pg_advisory_xact_lock(hashtextextended('ekwo.create_company:' || v_owner::text, 0));
    select count(*) into v_owned
      from companies c
     where c.created_by = v_owner;
    if v_owned >= v_sharing.companies_per_person then
      raise exception 'company_limit: this installation lets one person create % compan%, and you have created %',
        v_sharing.companies_per_person,
        case when v_sharing.companies_per_person = 1 then 'y' else 'ies' end,
        v_owned
        using errcode = '42501';
    end if;
  end if;

  select * into v_defaults from country_defaults where country = p_country;

  -- The currency and the language have to be settled before the insert: both
  -- columns are not null with a default, so there is no later moment at which
  -- they are empty and the pack could fill them. The pack answers, or the
  -- caller does, and there is no third answer written here.
  v_currency := upper(coalesce(p_currency_code, v_defaults.currency_code));
  if v_currency is null then
    raise exception 'no_currency: the % pack names no currency; name one', p_country;
  end if;
  v_language := lower(coalesce(p_language, v_defaults.language_default));
  if v_language is null then
    raise exception 'no_language: the % pack names no language for its labels; name one', p_country;
  end if;

  -- The territory is the caller's to name, and nobody else's: a pack that
  -- requires one proposes none, because any one of them would be a state
  -- somebody did not choose.
  if v_territory is null and coalesce(v_defaults.territory_required, false) then
    raise exception 'territory_required: a company of % names the territory it is established in (%)',
      p_country,
      coalesce((select string_agg(t.code, ', ' order by t.code)
                  from territories t
                 where t.parent_code = upper(p_country)), 'none is known')
      using errcode = '22023';
  end if;
  if v_territory is not null and not territory_within(v_territory, p_country) then
    raise exception 'territory_outside_country: % is not a territory of %', v_territory, p_country
      using errcode = '22023';
  end if;

  select * into v_bounds from fiscal_year_bounds(p_country, v_year, p_fiscal_year_start);

  insert into companies (name, country, fiscal_country, currency_code, language, territory_code)
  values (p_name, p_country, p_country, v_currency, v_language, v_territory)
  returning * into v_company;

  if v_owner is not null then
    insert into company_members (company_id, user_id, role)
    values (v_company.id, v_owner, 'owner')
    on conflict (company_id, user_id) do nothing;
  end if;

  perform install_country_template(v_company.id, p_country, v_language, p_chart_code);

  insert into fiscal_years (company_id, name, start_date, end_date)
  values (v_company.id, 'FY' || v_year::text, v_bounds.start_date, v_bounds.end_date);

  select * into v_company from companies where id = v_company.id;
  return v_company;
end;
$$;

comment on function ekwo.create_company(text, char, char, char, text, integer, date, uuid, text) is
  'Creates a company, makes its owner the first member, copies the country pack into it and opens its first financial year on the month that pack declares. The territory it is established in is the caller''s to name, within the country, and required where the pack says so (territory_required). An instance-level act; on a shared installation, also a signed-in person''s for a company of their own, up to companies_per_person counted on what they created (decision 0065).';

revoke execute on function ekwo.create_company(text, char, char, char, text, integer, date, uuid, text) from public, anon;
grant execute on function ekwo.create_company(text, char, char, char, text, integer, date, uuid, text) to authenticated, service_role;

-- The revoke every file of this directory ends with, and the Data API told
-- the function has a new argument.
revoke execute on all functions in schema ekwo from public;

notify pgrst, 'reload schema';
