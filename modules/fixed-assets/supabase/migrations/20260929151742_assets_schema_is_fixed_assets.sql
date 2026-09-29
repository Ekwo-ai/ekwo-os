-- Ekwo module `assets` — its schema is called `fixed_assets`.
--
-- In accounting English, *assets* is the whole left side of the balance sheet:
-- cash, receivables, stock, and the fixed assets among them. This module keeps
-- only the last of those — a register, its depreciation schedules and its
-- disposals — and the next module beside it is a stock register, which is an
-- asset as well. So the schema, its main table and the two functions whose
-- name said "asset" say which assets they mean.
--
-- What moves, in place and with every row kept:
--
--   schema      assets                      → fixed_assets
--   table       assets.assets               → fixed_assets.fixed_assets
--   functions   assets.create_asset(…)      → fixed_assets.create_fixed_asset(…)
--               assets.dispose_asset(…)     → fixed_assets.dispose_fixed_asset(…)
--   names       every constraint, index, policy and trigger of the schema
--               that began with `assets_` begins with `fixed_assets_`
--   registry    public.modules.schema_name  → 'fixed_assets', version 2.0.0
--
-- `ALTER SCHEMA … RENAME` and `ALTER TABLE … RENAME` keep the objects
-- themselves: the rows, the foreign keys, the row level security, the
-- privileges and the default privileges are attached to them and not to their
-- names. What does not follow is **text**. A function body is stored as the
-- text it was written in, so every function of the module that said
-- `assets.depreciation_lines` would say it after the rename and fail. Each one
-- is therefore written again below, as the latest migration that defined it
-- wrote it, with the new names and nothing else changed — the arithmetic, the
-- rounding and the refusals are the ones the golden figures of the module were
-- pinned on. `create or replace` keeps the function itself, so its grants stay
-- where they were.
--
-- **What does not move: the module code, `assets`.** It is the key of
-- `public.modules`, and it is written on every entry this module has posted —
-- `entries.module_code`, the tag that makes a second depreciation of the same
-- period impossible. A posted entry does not move, for anybody, since
-- `20260918161538`, and the manifest of a module says its code is immutable
-- once published for exactly this reason. So `enable_module(company,
-- 'assets')`, `module_enabled(company_id, 'assets')` and the capabilities
-- `assets.read`, `assets.write` and `assets.post` — whose area is the module
-- code — are unchanged, and so is every right a member or a key holds today.
--
-- **Idempotent.** Run twice, by the migration runner and again by hand, it
-- changes nothing the second time: each rename looks for the old name first.
-- A fresh installation applies the migrations of 13 September and this one
-- after them, so it arrives at exactly the state an upgraded one does — the
-- module's tests and the golden figures run on that state.
--
-- **One thing no migration can do.** PostgREST serves the schemas the project
-- lists, and that list still says `assets`. Replace it with `fixed_assets` —
-- Supabase dashboard → Project Settings → API → Exposed schemas, or
-- `[api] schemas` in `supabase/config.toml` — right after this has run.

do $$
begin
  if to_regnamespace('assets') is not null and to_regnamespace('fixed_assets') is not null then
    raise exception 'fixed_assets_rename_ambiguous: both an `assets` and a `fixed_assets` schema exist here, and only one of them can be this module. Say which one by dropping the other.'
      using errcode = '55006';
  end if;
  if to_regnamespace('assets') is not null then
    alter schema assets rename to fixed_assets;
  end if;
  if to_regnamespace('fixed_assets') is null then
    raise exception 'fixed_assets_missing: neither an `assets` nor a `fixed_assets` schema exists. Apply the module''s earlier migrations first.'
      using errcode = '55006';
  end if;
  if to_regclass('fixed_assets.assets') is not null then
    alter table fixed_assets.assets rename to fixed_assets;
  end if;
end;
$$;

-- The names that said `assets_`, all of them, read from the catalogue rather
-- than listed: a list written by hand would miss the one somebody added last.
-- A constraint first, because renaming a primary or a unique key renames the
-- index behind it; then the indexes left, the policies and the triggers.
do $$
declare
  v record;
begin
  for v in
    select c.conrelid::regclass as rel, c.conname as name
      from pg_constraint c
     where c.connamespace = 'fixed_assets'::regnamespace and c.conname like 'assets\_%'
     order by c.conname
  loop
    execute format('alter table %s rename constraint %I to %I', v.rel, v.name, 'fixed_' || v.name);
  end loop;

  for v in
    select i.indexname as name
      from pg_indexes i
     where i.schemaname = 'fixed_assets' and i.indexname like 'assets\_%'
     order by i.indexname
  loop
    execute format('alter index fixed_assets.%I rename to %I', v.name, 'fixed_' || v.name);
  end loop;

  for v in
    select p.tablename as tbl, p.policyname as name
      from pg_policies p
     where p.schemaname = 'fixed_assets' and p.policyname like 'assets\_%'
     order by p.policyname
  loop
    execute format('alter policy %I on fixed_assets.%I rename to %I', v.name, v.tbl, 'fixed_' || v.name);
  end loop;

  for v in
    select t.tgrelid::regclass as rel, t.tgname as name
      from pg_trigger t
      join pg_class c on c.oid = t.tgrelid
     where c.relnamespace = 'fixed_assets'::regnamespace and not t.tgisinternal
       and t.tgname like 'assets\_%'
     order by t.tgname
  loop
    execute format('alter trigger %I on %s rename to %I', v.name, v.rel, 'fixed_' || v.name);
  end loop;
end;
$$;

-- The two functions whose name said "asset" take the qualifier too. Renamed
-- rather than dropped and created, so the function keeps its privileges; the
-- `create or replace` below then gives it its new body.
do $$
begin
  if to_regprocedure('fixed_assets.create_asset(uuid, text, text, date, numeric, text, text, text, text, integer, fixed_assets.depreciation_method, numeric, numeric, date, uuid, uuid, text)') is not null then
    alter function fixed_assets.create_asset(uuid, text, text, date, numeric, text, text, text, text, integer, fixed_assets.depreciation_method, numeric, numeric, date, uuid, uuid, text)
      rename to create_fixed_asset;
  end if;
  if to_regprocedure('fixed_assets.dispose_asset(uuid, date, numeric, text, uuid)') is not null then
    alter function fixed_assets.dispose_asset(uuid, date, numeric, text, uuid)
      rename to dispose_fixed_asset;
  end if;
end;
$$;

comment on schema fixed_assets is
  'Ekwo module `assets`: fixed assets, depreciation schedules and disposals. Posts to the ledger only through public.post_module_entry(). The schema was called `assets` until version 2.0.0 of the module; the module code, written on every entry it posted, is still `assets`.';

comment on table fixed_assets.fixed_assets is
  'One fixed asset: what it cost, how it is depreciated, and the three accounts that carry it. The schedule is fixed_assets.depreciation_lines. Called assets.assets until version 2.0.0 of the module.';

comment on table fixed_assets.disposals is
  'What leaving the books cost or earned: one row per fixed asset, written by fixed_assets.dispose_fixed_asset(). There is no undo, for the reason there is no unpost.';

-- The pack section it is compiled from was renamed with the schema.
comment on table fixed_assets.country_rules is
  'How one country depreciates and derecognises. Filled by `ekwo pack build` from packs/<cc>/fixed_assets.json, read where it stands, never copied into a company.';

-- ---------------------------------------------------------------------------
-- Every function of the module, written again with the names of today
-- ---------------------------------------------------------------------------

create or replace function fixed_assets.days360(p_from date, p_to date)
returns integer
language sql
immutable
as $$
  select ((extract(year from p_to)::int - extract(year from p_from)::int) * 360)
       + ((extract(month from p_to)::int - extract(month from p_from)::int) * 30)
       + (least(extract(day from p_to)::int, 30) - least(extract(day from p_from)::int, 30));
$$;

comment on function fixed_assets.days360(date, date) is
  'Days between two dates on a year of 360 days and months of 30, the day capped at the 30th. Half-open: days360(1 January, 1 January of the next year) is 360.';

/**
 * Whole months from the month of `p_from` to the month of `p_to`, inclusive.
 * January to January is one month, January to December is twelve.
 */
create or replace function fixed_assets.months_inclusive(p_from date, p_to date)
returns integer
language sql
immutable
as $$
  select greatest(
    0,
    (extract(year from p_to)::int - extract(year from p_from)::int) * 12
      + (extract(month from p_to)::int - extract(month from p_from)::int) + 1
  );
$$;

-- NO COMMENT

/**
 * The share of a period an asset is depreciated over.
 *
 * One for every period after the first, and for an asset whose country takes
 * no prorata at all. The date it counts from is the later of the day the asset
 * entered service and the first day of the period, so a full period is a full
 * annuity without the caller having to know which period it is on.
 */
create or replace function fixed_assets.prorata_fraction(
  p_rule         fixed_assets.prorata_rule,
  p_day_count    fixed_assets.day_count,
  p_start        date,
  p_period_start date,
  p_period_end   date
)
returns numeric
language plpgsql
immutable
as $$
declare
  v_from date := greatest(p_start, p_period_start);
begin
  if p_rule = 'none' or v_from <= p_period_start then
    return 1;
  end if;
  if v_from > p_period_end then
    return 0;
  end if;

  if p_rule = 'months' then
    return fixed_assets.months_inclusive(v_from, p_period_end)::numeric
         / nullif(fixed_assets.months_inclusive(p_period_start, p_period_end), 0);
  end if;

  if p_day_count = 'thirty_360' then
    return fixed_assets.days360(v_from, p_period_end + 1)::numeric
         / nullif(fixed_assets.days360(p_period_start, p_period_end + 1), 0);
  end if;

  return ((p_period_end - v_from) + 1)::numeric / nullif((p_period_end - p_period_start) + 1, 0);
end;
$$;

comment on function fixed_assets.prorata_fraction(fixed_assets.prorata_rule, fixed_assets.day_count, date, date, date) is
  'The share of a period that runs from the day an asset entered service. A prorata in days counts the day of entry into service itself, which is the convention that makes a full year come to exactly one.';

create or replace function fixed_assets.rules(p_company_id uuid)
returns fixed_assets.country_rules
language plpgsql
stable
as $$
declare
  v_rules fixed_assets.country_rules%rowtype;
begin
  select r.* into v_rules
    from public.companies c
    join fixed_assets.country_rules r on r.country = c.country
   where c.id = p_company_id;
  return v_rules;
end;
$$;

comment on function fixed_assets.rules(uuid) is
  'The depreciation rules of this company''s country, or an empty row when its pack says nothing. The callers name what is missing rather than borrowing another country''s answer.';

/**
 * Monthly or yearly, from the settings the company keeps for this module.
 *
 * The default is yearly, and that is a mechanism and not a country: every rule
 * a country writes about depreciation is expressed as an annuity, and a
 * monthly schedule is that annuity split. A company that wants the split asks
 * for it with `{"period": "monthly"}`.
 */
create or replace function fixed_assets.period_is_monthly(p_company_id uuid)
returns boolean
language sql
stable
as $$
  select coalesce(public.module_settings(p_company_id, 'assets') ->> 'period', 'yearly') = 'monthly';
$$;

-- NO COMMENT

/**
 * The twelve-month period an asset's schedule is cut into, from the financial
 * year that covers the day it entered service.
 *
 * Where the company has declared the financial year a period falls in, that
 * year's own end date is used, so a schedule follows the books. Beyond the
 * declared years it rolls twelve months at a time from the same anchor, which
 * is the only thing it can do: a building bought this year is depreciated over
 * twenty, and nineteen of those years have not been declared yet.
 */
create or replace function fixed_assets.period_end_for(p_company_id uuid, p_period_start date)
returns date
language sql
stable
as $$
  select coalesce(
    (select f.end_date
       from public.fiscal_years f
      where f.company_id = p_company_id
        and f.start_date = p_period_start
      limit 1),
    (p_period_start + interval '1 year' - interval '1 day')::date
  );
$$;

-- NO COMMENT

create or replace function fixed_assets.create_fixed_asset(
  p_company_id       uuid,
  p_code             text,
  p_name             text,
  p_acquisition_date date,
  p_cost             numeric,
  p_asset_account    text,
  p_depreciation_account text,
  p_expense_account  text,
  p_category_code    text default null,
  p_duration_months  integer default null,
  p_method           fixed_assets.depreciation_method default null,
  p_coefficient      numeric default null,
  p_residual_value   numeric default 0,
  p_in_service_date  date default null,
  p_document_line_id uuid default null,
  p_contact_id       uuid default null,
  p_description      text default null
)
returns uuid
language plpgsql
as $$
declare
  v_country  char(2);
  v_category fixed_assets.category_templates%rowtype;
  v_method   fixed_assets.depreciation_method;
  v_duration integer;
  v_coef     numeric(7, 3);
  v_id       uuid;
  v_asset    uuid;
  v_deprec   uuid;
  v_round    public.money_rounding;
  v_expense  uuid;
begin
  if not public.module_is_enabled(p_company_id, 'assets') then
    raise exception 'module_not_enabled: the fixed assets module (assets) is not enabled on this company'
      using errcode = '55006';
  end if;

  select country into v_country from public.companies where id = p_company_id;
  if v_country is null then
    raise exception 'unknown_company: %', p_company_id;
  end if;

  if p_category_code is not null then
    select * into v_category
      from fixed_assets.category_templates
     where country = v_country and code = p_category_code;
    if not found then
      raise exception 'unknown_asset_category: % is not a category of the % pack', p_category_code, v_country;
    end if;
  end if;

  -- The category is a suggestion, so anything the caller gave wins over it.
  -- Same rule as a product pre-filling a document line.
  v_method   := coalesce(p_method, v_category.method, 'straight_line');
  v_duration := coalesce(p_duration_months, v_category.duration_months);
  v_coef     := coalesce(p_coefficient, v_category.coefficient);

  if v_duration is null then
    raise exception 'no_duration: name a duration in months, or a category of the % pack that carries one', v_country;
  end if;

  v_round   := public.rounding_of(p_company_id);
  v_asset   := public.account_id_by_code(p_company_id, p_asset_account);
  v_deprec  := public.account_id_by_code(p_company_id, p_depreciation_account);
  v_expense := public.account_id_by_code(p_company_id, p_expense_account);
  if v_asset is null then
    raise exception 'unknown_account: % is not an account of this company', p_asset_account;
  end if;
  if v_deprec is null then
    raise exception 'unknown_account: % is not an account of this company', p_depreciation_account;
  end if;
  if v_expense is null then
    raise exception 'unknown_account: % is not an account of this company', p_expense_account;
  end if;

  insert into fixed_assets.fixed_assets (
    company_id, code, name, description, category_code, document_line_id, contact_id,
    acquisition_date, in_service_date, cost, residual_value, method, duration_months,
    coefficient, prorata, asset_account_id, depreciation_account_id, expense_account_id, state
  )
  values (
    p_company_id, p_code, p_name, p_description, p_category_code, p_document_line_id, p_contact_id,
    p_acquisition_date, p_in_service_date,
    public.round_amount(p_cost, v_round),
    public.round_amount(coalesce(p_residual_value, 0), v_round),
    v_method, v_duration, v_coef, v_category.prorata, v_asset, v_deprec, v_expense, 'active'
  )
  returning id into v_id;

  perform fixed_assets.generate_schedule(v_id);
  return v_id;
end;
$$;

comment on function fixed_assets.create_fixed_asset(uuid, text, text, date, numeric, text, text, text, text, integer, fixed_assets.depreciation_method, numeric, numeric, date, uuid, uuid, text) is
  'Creates an asset and its schedule in one call. A category of the country pack fills in the method, the duration and the coefficient; anything the caller passes wins over it.';

create or replace function fixed_assets.generate_schedule(p_asset_id uuid)
returns integer
language plpgsql
as $$
declare
  v_asset    fixed_assets.fixed_assets%rowtype;
  v_rules    fixed_assets.country_rules%rowtype;
  v_prorata  fixed_assets.prorata_rule;
  v_start    date;
  v_year     public.fiscal_years%rowtype;
  v_base     numeric;
  v_rate     numeric;
  v_period_start date;
  v_period_end   date;
  v_fraction numeric;
  v_amount   numeric;
  v_linear   numeric;
  v_cap      numeric;
  v_accum    numeric := 0;
  -- A schedule is a ledger figure, so each annuity is written at the decimals
  -- of the currency the company keeps its books in.
  v_round    public.money_rounding;
  v_sequence integer := 0;
  v_periods  integer;
  v_left     integer;
  v_guard    integer := 0;
begin
  select * into v_asset from fixed_assets.fixed_assets where id = p_asset_id;
  if not found then
    raise exception 'unknown_asset: %', p_asset_id;
  end if;
  if v_asset.state = 'disposed' then
    raise exception 'asset_disposed: % has left the books', v_asset.code;
  end if;
  if v_asset.method = 'units_of_production' then
    raise exception 'units_of_production_unsupported: a schedule by output needs the units of each period, which this module does not record. Name a duration and a straight line, or keep the schedule outside Ekwo.';
  end if;

  -- A schedule is generated once. Once a line has been booked, the schedule is
  -- what the ledger says happened, and regenerating it would leave the two
  -- disagreeing without anything looking wrong — which is the failure the
  -- column `posted_at` exists to make visible.
  if exists (select 1 from fixed_assets.depreciation_lines l
              where l.asset_id = p_asset_id and l.posted_at is not null) then
    raise exception 'schedule_already_posted: % has depreciation already booked; a schedule is not rewritten under the ledger', v_asset.code
      using errcode = '55006';
  end if;
  delete from fixed_assets.depreciation_lines where asset_id = p_asset_id;

  v_round := public.rounding_of(v_asset.company_id);
  v_start := coalesce(v_asset.in_service_date, v_asset.acquisition_date);
  v_base  := v_asset.cost - v_asset.residual_value;

  v_rules := fixed_assets.rules(v_asset.company_id);
  v_prorata := coalesce(
    v_asset.prorata,
    case when v_asset.method = 'declining_balance' then v_rules.prorata_declining
         else v_rules.prorata_straight_line end);
  if v_prorata is null then
    raise exception 'no_fixed_assets_country_rules: the pack of this company''s country says nothing about how a first period is prorated. Add a fixed_assets section to the pack, or set fixed_assets.prorata on this asset.'
      using errcode = '55006';
  end if;

  select * into v_year
    from public.fiscal_years f
   where f.company_id = v_asset.company_id
     and v_start between f.start_date and f.end_date
   limit 1;
  if not found then
    raise exception 'no_fiscal_year: % entered service on %, which falls in no financial year of this company', v_asset.code, v_start;
  end if;

  v_period_start := v_year.start_date;
  v_rate := 12::numeric / v_asset.duration_months;
  -- How many annuities the duration is worth. A declining balance measures
  -- what is left to run in periods and not in days, because that is what the
  -- rule it comes from says: at the start of the second year of a five-year
  -- asset, four annuities remain, whatever day of the first year it was
  -- bought on.
  v_periods := ceil(v_asset.duration_months / 12.0)::integer;
  if v_rules.declining_cap_percent is not null then
    v_cap := public.round_amount(v_asset.cost * v_rules.declining_cap_percent / 100, v_round);
  end if;

  while v_accum < v_base loop
    v_guard := v_guard + 1;
    if v_guard > 1200 then
      raise exception 'schedule_runaway: % produced more than 1200 periods; check its duration and its coefficient', v_asset.code;
    end if;

    v_period_end := fixed_assets.period_end_for(v_asset.company_id, v_period_start);
    v_fraction := fixed_assets.prorata_fraction(v_prorata, v_rules.day_count, v_start, v_period_start, v_period_end);

    if v_asset.method = 'declining_balance' then
      v_amount := public.round_amount(
        (v_base - v_accum) * v_rate * v_asset.coefficient * v_fraction, v_round);
      if v_cap is not null then
        v_amount := least(v_amount, public.round_amount(v_cap * v_fraction, v_round));
      end if;
      -- The straight line over what is left to run. A declining balance is a
      -- front-loaded schedule that never reaches zero on its own, and the
      -- switch is what makes it end on the last period rather than never.
      -- The last period is `v_left = 1`, where the straight line is the whole
      -- remaining value.
      v_left := greatest(1, v_periods - v_sequence);
      if coalesce(v_rules.declining_switch_to_linear, true) then
        v_linear := public.round_amount((v_base - v_accum) / v_left * v_fraction, v_round);
        v_amount := greatest(v_amount, v_linear);
      end if;
    else
      v_amount := public.round_amount(v_base * v_rate * v_fraction, v_round);
    end if;

    if v_amount <= 0 then
      v_amount := v_base - v_accum;
    end if;
    -- The last period takes the remainder, whatever the rounding did on the
    -- way. This is the line that makes the schedule sum to the cent.
    if v_accum + v_amount > v_base then
      v_amount := v_base - v_accum;
    end if;

    v_accum := v_accum + v_amount;
    v_sequence := v_sequence + 1;

    insert into fixed_assets.depreciation_lines
      (asset_id, company_id, sequence, period_start, period_end, amount, accumulated, net_book_value)
    values (p_asset_id, v_asset.company_id, v_sequence, v_period_start, v_period_end,
            v_amount, v_accum, v_asset.cost - v_accum);

    v_period_start := v_period_end + 1;
  end loop;

  if fixed_assets.period_is_monthly(v_asset.company_id) then
    perform fixed_assets.split_into_months(p_asset_id);
  end if;

  update fixed_assets.fixed_assets
     set state = case when state = 'draft' then 'active' else state end
   where id = p_asset_id;

  return (select count(*)::integer from fixed_assets.depreciation_lines where asset_id = p_asset_id);
end;
$$;

comment on function fixed_assets.generate_schedule(uuid) is
  'Writes the depreciation schedule of an asset, period by period, rounded at the decimals of the company''s currency with the last line taking the remainder. Refuses to rewrite a schedule whose lines are already booked.';

create or replace function fixed_assets.split_into_months(p_asset_id uuid)
returns integer
language plpgsql
as $$
declare
  v_line     fixed_assets.depreciation_lines%rowtype;
  v_asset    fixed_assets.fixed_assets%rowtype;
  v_months   integer;
  v_start    date;
  v_end      date;
  v_share    numeric;
  v_done     numeric;
  v_accum    numeric := 0;
  v_round    public.money_rounding;
  v_sequence integer := 0;
  v_index    integer;
  v_new      jsonb := '[]'::jsonb;
begin
  select * into v_asset from fixed_assets.fixed_assets where id = p_asset_id;
  v_round := public.rounding_of(v_asset.company_id);

  for v_line in
    select * from fixed_assets.depreciation_lines where asset_id = p_asset_id order by sequence
  loop
    v_months := fixed_assets.months_inclusive(v_line.period_start, v_line.period_end);
    v_done := 0;
    for v_index in 1 .. v_months loop
      v_start := (date_trunc('month', v_line.period_start) + make_interval(months => v_index - 1))::date;
      v_end := (date_trunc('month', v_start) + interval '1 month' - interval '1 day')::date;
      if v_index = 1 then v_start := v_line.period_start; end if;
      if v_index = v_months then v_end := v_line.period_end; end if;

      v_share := case when v_index = v_months
                      then v_line.amount - v_done
                      else public.round_amount(v_line.amount / v_months, v_round) end;
      v_done := v_done + v_share;
      if v_share = 0 then continue; end if;

      v_accum := v_accum + v_share;
      v_sequence := v_sequence + 1;
      v_new := v_new || jsonb_build_object(
        'sequence', v_sequence, 'period_start', v_start, 'period_end', v_end,
        'amount', v_share, 'accumulated', v_accum,
        'net_book_value', v_asset.cost - v_accum);
    end loop;
  end loop;

  delete from fixed_assets.depreciation_lines where asset_id = p_asset_id;
  insert into fixed_assets.depreciation_lines
    (asset_id, company_id, sequence, period_start, period_end, amount, accumulated, net_book_value)
  select p_asset_id, v_asset.company_id,
         (row ->> 'sequence')::integer, (row ->> 'period_start')::date, (row ->> 'period_end')::date,
         (row ->> 'amount')::numeric, (row ->> 'accumulated')::numeric, (row ->> 'net_book_value')::numeric
    from jsonb_array_elements(v_new) as row;

  return v_sequence;
end;
$$;

-- NO COMMENT

create or replace function fixed_assets.run_depreciation(p_company_id uuid, p_period_end date)
returns jsonb
language plpgsql
as $$
declare
  v_period   date;
  v_lines    jsonb;
  v_entry    uuid;
  v_total    numeric(16, 2);
  v_posted   jsonb := '[]'::jsonb;
begin
  if not public.module_is_enabled(p_company_id, 'assets') then
    raise exception 'module_not_enabled: the fixed assets module (assets) is not enabled on this company'
      using errcode = '55006';
  end if;

  for v_period in
    select distinct l.period_end
      from fixed_assets.depreciation_lines l
      join fixed_assets.fixed_assets a on a.id = l.asset_id
     where l.company_id = p_company_id
       and l.posted_at is null
       and l.period_end <= p_period_end
       and a.state <> 'disposed'
       and l.amount > 0
     order by l.period_end
  loop
    -- One debit and one credit per asset, named by the asset. An entry that
    -- aggregates by account is shorter and tells whoever reads the ledger in
    -- three years nothing about which asset moved.
    select jsonb_agg(line order by line_order), sum(amount)
      into v_lines, v_total
      from (
        select jsonb_build_object(
                 'account_id', a.expense_account_id,
                 'label', a.code || ' — ' || a.name,
                 'debit', l.amount) as line,
               (a.code || ':1') as line_order, l.amount
          from fixed_assets.depreciation_lines l
          join fixed_assets.fixed_assets a on a.id = l.asset_id
         where l.company_id = p_company_id and l.period_end = v_period
           and l.posted_at is null and a.state <> 'disposed' and l.amount > 0
        union all
        select jsonb_build_object(
                 'account_id', a.depreciation_account_id,
                 'label', a.code || ' — ' || a.name,
                 'credit', l.amount),
               (a.code || ':2'), 0
          from fixed_assets.depreciation_lines l
          join fixed_assets.fixed_assets a on a.id = l.asset_id
         where l.company_id = p_company_id and l.period_end = v_period
           and l.posted_at is null and a.state <> 'disposed' and l.amount > 0
      ) parts;

    if v_lines is null then
      continue;
    end if;

    v_entry := public.post_module_entry(
      p_company_id, 'assets', 'depreciation:' || v_period::text, v_period,
      'Depreciation ' || v_period::text, v_lines);

    update fixed_assets.depreciation_lines l
       set entry_id = v_entry, posted_at = now()
      from fixed_assets.fixed_assets a
     where a.id = l.asset_id
       and l.company_id = p_company_id
       and l.period_end = v_period
       and l.posted_at is null
       and a.state <> 'disposed'
       and l.amount > 0;

    v_posted := v_posted || jsonb_build_object(
      'period_end', v_period,
      'entry_id', v_entry,
      'amount', to_char(v_total, 'FM9999999999999990.00'));
  end loop;

  -- An asset whose whole schedule is booked says so, so a register does not
  -- have to work it out from the lines every time it is read.
  update fixed_assets.fixed_assets a
     set state = 'fully_depreciated'
   where a.company_id = p_company_id
     and a.state = 'active'
     and not exists (select 1 from fixed_assets.depreciation_lines l
                      where l.asset_id = a.id and l.posted_at is null);

  return jsonb_build_object('company_id', p_company_id, 'entries', v_posted);
end;
$$;

comment on function fixed_assets.run_depreciation(uuid, date) is
  'Books every planned period that ends on or before a date, one entry per period, through post_module_entry(). Idempotent: a period already booked is skipped, and the unique tag on the entry refuses a second one anyway. A closed financial year refuses the posting, because post_entry() asserts the period is open.';

create or replace function fixed_assets.dispose_fixed_asset(
  p_asset_id     uuid,
  p_date         date,
  p_proceeds     numeric default 0,
  p_counterpart_account text default null,
  p_contact_id   uuid default null
)
returns uuid
language plpgsql
as $$
declare
  v_asset     fixed_assets.fixed_assets%rowtype;
  v_rules     fixed_assets.country_rules%rowtype;
  v_defaults  public.country_defaults%rowtype;
  v_country   char(2);
  v_accum     numeric;
  v_nbv       numeric;
  v_result    numeric;
  v_round     public.money_rounding;
  v_proceeds  numeric;
  v_counter   uuid;
  v_account   uuid;
  v_lines     jsonb := '[]'::jsonb;
  v_entry     uuid;
begin
  select * into v_asset from fixed_assets.fixed_assets where id = p_asset_id for update;
  if not found then
    raise exception 'unknown_asset: %', p_asset_id;
  end if;
  if v_asset.state = 'disposed' then
    raise exception 'asset_disposed: % has already left the books', v_asset.code;
  end if;
  if p_date < coalesce(v_asset.in_service_date, v_asset.acquisition_date) then
    raise exception 'disposal_before_service: % cannot leave the books before it entered them', v_asset.code;
  end if;

  -- Everything the schedule planned for a period that has already ended has to
  -- be booked before the asset goes: a disposal reads the accumulated
  -- depreciation off the ledger, and a period left unbooked would make it read
  -- a figure the accounts do not carry.
  if exists (select 1 from fixed_assets.depreciation_lines l
              where l.asset_id = p_asset_id and l.posted_at is null and l.period_end < p_date) then
    raise exception 'depreciation_pending: run fixed_assets.run_depreciation(company, %) before disposing of %',
      p_date, v_asset.code
      using errcode = '55006';
  end if;

  select country into v_country from public.companies where id = v_asset.company_id;
  v_round    := public.rounding_of(v_asset.company_id);
  v_proceeds := public.round_amount(coalesce(p_proceeds, 0), v_round);
  v_rules := fixed_assets.rules(v_asset.company_id);
  if v_rules.disposal_style is null then
    raise exception 'no_disposal_style: the pack of % says nothing about how an asset leaves the books. Set fixed_assets.disposal, and the roles it needs, in the pack.', v_country
      using errcode = '55006';
  end if;
  select * into v_defaults from public.country_defaults where country = v_country;

  select coalesce(sum(l.amount), 0) into v_accum
    from fixed_assets.depreciation_lines l
   where l.asset_id = p_asset_id and l.posted_at is not null;
  v_nbv := v_asset.cost - v_accum;
  v_result := v_proceeds - v_nbv;

  -- What the schedule still planned never happened. Deleting only the unposted
  -- lines keeps everything the ledger knows about.
  delete from fixed_assets.depreciation_lines
   where asset_id = p_asset_id and posted_at is null;

  -- 1. The asset leaves, and its accumulated depreciation with it.
  if v_accum > 0 then
    v_lines := v_lines || jsonb_build_object(
      'account_id', v_asset.depreciation_account_id,
      'label', v_asset.code || ' — accumulated depreciation', 'debit', v_accum);
  end if;
  v_lines := v_lines || jsonb_build_object(
    'account_id', v_asset.asset_account_id,
    'label', v_asset.code || ' — ' || v_asset.name, 'credit', v_asset.cost);

  -- 2. What the buyer owes, if anything.
  if v_proceeds > 0 then
    v_counter := case
      when p_counterpart_account is not null
        then public.account_id_by_code(v_asset.company_id, p_counterpart_account)
      else (select receivable_account_id from public.companies where id = v_asset.company_id)
    end;
    if v_counter is null then
      raise exception 'no_counterpart_account: name the account the proceeds of % land on', v_asset.code;
    end if;
    v_lines := v_lines || jsonb_build_object(
      'account_id', v_counter, 'label', v_asset.code || ' — proceeds',
      'debit', v_proceeds, 'contact_id', p_contact_id);
  end if;

  -- 3. The result, the way the country presents it.
  if v_rules.disposal_style = 'gross' then
    -- The net book value is a charge and the proceeds an income, both in full.
    -- The two lines above already cleared the asset and its depreciation, so
    -- what is left to write is the charge; the proceeds line of the income
    -- account replaces nothing, it is the other half of the same presentation.
    v_account := public.account_id_by_code(v_asset.company_id, v_defaults.asset_disposal_value_code);
    if v_account is null then
      raise exception 'no_asset_disposal_value_account: % files a gross disposal and its pack names no account for the value of what was sold', v_country;
    end if;
    if v_nbv > 0 then
      v_lines := v_lines || jsonb_build_object(
        'account_id', v_account, 'label', v_asset.code || ' — net book value sold',
        'debit', v_nbv);
    end if;
    if v_proceeds > 0 then
      v_account := public.account_id_by_code(v_asset.company_id, v_defaults.asset_disposal_proceeds_code);
      if v_account is null then
        raise exception 'no_asset_disposal_proceeds_account: % files a gross disposal and its pack names no account for the proceeds', v_country;
      end if;
      v_lines := v_lines || jsonb_build_object(
        'account_id', v_account, 'label', v_asset.code || ' — proceeds of disposal',
        'credit', v_proceeds);
    end if;
    -- The two proceeds lines are the two halves of one movement and not a
    -- double count: the buyer is debited above, the income account is credited
    -- here. What the gross style adds to the net-result one is the charge, and
    -- an income statement that prints both is what France asks for.
  elsif v_result <> 0 then
    v_account := public.account_id_by_code(
      v_asset.company_id,
      case when v_result > 0 then v_defaults.asset_disposal_gain_code
           else coalesce(v_defaults.asset_disposal_loss_code, v_defaults.asset_disposal_gain_code) end);
    if v_account is null then
      raise exception 'no_asset_disposal_account: the pack of % names no account for a % on the disposal of a fixed asset',
        v_country, case when v_result > 0 then 'gain' else 'loss' end;
    end if;
    v_lines := v_lines || jsonb_build_object(
      'account_id', v_account,
      'label', v_asset.code || ' — ' || case when v_result > 0 then 'gain' else 'loss' end || ' on disposal',
      'debit', case when v_result < 0 then -v_result else 0 end,
      'credit', case when v_result > 0 then v_result else 0 end);
  end if;

  v_entry := public.post_module_entry(
    v_asset.company_id, 'assets', 'disposal:' || v_asset.code, p_date,
    'Disposal of ' || v_asset.code || ' — ' || v_asset.name, v_lines);

  insert into fixed_assets.disposals
    (asset_id, company_id, disposal_date, proceeds, counterpart_account_id, contact_id,
     cost, accumulated, net_book_value, result, entry_id)
  values (p_asset_id, v_asset.company_id, p_date, v_proceeds, v_counter, p_contact_id,
          v_asset.cost, v_accum, v_nbv, v_result, v_entry);

  update fixed_assets.fixed_assets set state = 'disposed' where id = p_asset_id;
  return v_entry;
end;
$$;

comment on function fixed_assets.dispose_fixed_asset(uuid, date, numeric, text, uuid) is
  'Takes an asset off the books on a date: clears its cost and its accumulated depreciation, books the proceeds, and presents the result the way the country''s pack says — one gain or loss line, or the value and the proceeds in full.';

create or replace function fixed_assets.can_disable(p_company_id uuid)
returns text
language sql
stable
as $$
  select case
    when exists (
      select 1 from fixed_assets.depreciation_lines l
       where l.company_id = p_company_id and l.posted_at is not null
    ) then 'depreciation has been booked from it; the entries stay whatever happens to the module, but the register that explains them would be gone'
    when exists (select 1 from fixed_assets.disposals d where d.company_id = p_company_id)
      then 'an asset has been disposed of through it'
    when exists (select 1 from fixed_assets.fixed_assets a where a.company_id = p_company_id)
      then 'it still holds fixed assets; delete them first if they were a mistake'
  end;
$$;

comment on function fixed_assets.can_disable(uuid) is
  'Why this company cannot disable the fixed assets module, or null when it can. The convention disable_module() reads.';

create or replace function fixed_assets.register(p_company_id uuid, p_at date)
returns table (
  code            text,
  name            text,
  category_code   text,
  acquisition_date date,
  cost            numeric,
  accumulated     numeric,
  net_book_value  numeric,
  state           text
)
language sql
stable
as $$
  select a.code,
         a.name,
         a.category_code,
         a.acquisition_date,
         a.cost,
         public.round_amount(coalesce(d.accumulated, 0), public.rounding_of(p_company_id)),
         public.round_amount(a.cost - coalesce(d.accumulated, 0), public.rounding_of(p_company_id)),
         a.state::text
    from fixed_assets.fixed_assets a
    left join lateral (
      select coalesce(sum(l.amount), 0) as accumulated
        from fixed_assets.depreciation_lines l
       where l.asset_id = a.id and l.posted_at is not null and l.period_end <= p_at
    ) d on true
   where a.company_id = p_company_id
     and a.acquisition_date <= p_at
     and not exists (
       select 1 from fixed_assets.disposals x
        where x.asset_id = a.id and x.disposal_date <= p_at
     )
   order by a.code;
$$;

comment on function fixed_assets.register(uuid, date) is
  'The table of fixed assets at a date: what each one cost, what has been written off it, and what is left. Reads what has been booked, so it ties to the ledger.';

create or replace function fixed_assets.movements(p_company_id uuid, p_from date, p_to date)
returns table (
  code                text,
  name                text,
  opening_cost        numeric,
  additions           numeric,
  disposals_cost      numeric,
  closing_cost        numeric,
  opening_accumulated numeric,
  depreciation        numeric,
  disposals_accumulated numeric,
  closing_accumulated numeric,
  net_book_value      numeric
)
language sql
stable
as $$
  with movement as (
    select a.id, a.code, a.name, a.cost,
           a.acquisition_date < p_from as held_before,
           a.acquisition_date between p_from and p_to as added,
           x.disposal_date, x.accumulated as disposed_accumulated,
           coalesce((select sum(l.amount) from fixed_assets.depreciation_lines l
                      where l.asset_id = a.id and l.posted_at is not null
                        and l.period_end < p_from), 0) as accum_before,
           coalesce((select sum(l.amount) from fixed_assets.depreciation_lines l
                      where l.asset_id = a.id and l.posted_at is not null
                        and l.period_end between p_from and p_to), 0) as accum_period
      from fixed_assets.fixed_assets a
      left join fixed_assets.disposals x on x.asset_id = a.id
     where a.company_id = p_company_id
       and a.acquisition_date <= p_to
  )
  select m.code, m.name,
         public.round_amount(case when m.held_before then m.cost else 0 end, r.rounding),
         public.round_amount(case when m.added then m.cost else 0 end, r.rounding),
         public.round_amount(case when m.disposal_date between p_from and p_to
                                  then m.cost else 0 end, r.rounding),
         public.round_amount(case when m.disposal_date is not null and m.disposal_date <= p_to
                                  then 0 else m.cost end, r.rounding),
         public.round_amount(m.accum_before, r.rounding),
         public.round_amount(m.accum_period, r.rounding),
         public.round_amount(case when m.disposal_date between p_from and p_to
                                  then coalesce(m.disposed_accumulated, 0) else 0 end, r.rounding),
         public.round_amount(case when m.disposal_date is not null and m.disposal_date <= p_to
                                  then 0 else m.accum_before + m.accum_period end, r.rounding),
         public.round_amount(case when m.disposal_date is not null and m.disposal_date <= p_to
                                  then 0 else m.cost - m.accum_before - m.accum_period end, r.rounding)
    from movement m
    cross join (select public.rounding_of(p_company_id) as rounding) r
   order by m.code;
$$;

comment on function fixed_assets.movements(uuid, date, date) is
  'What came in, what was written off and what went out between two dates, per asset — the movement table an annual account asks for beside the register.';

create or replace function fixed_assets.assert_may_post()
returns trigger
language plpgsql
as $$
begin
  if not public.is_installer() and not public.has_capability(new.company_id, 'assets.post') then
    raise exception 'not_allowed: booking this to the ledger needs fixed_assets.post'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

-- NO COMMENT

create or replace function fixed_assets.accounts_in_use(p_company_id uuid)
returns setof uuid
language sql
stable
as $$
  select unnest(array[a.asset_account_id, a.depreciation_account_id, a.expense_account_id])
    from fixed_assets.fixed_assets a
   where a.company_id = p_company_id
  union
  select d.counterpart_account_id
    from fixed_assets.disposals d
   where d.company_id = p_company_id and d.counterpart_account_id is not null;
$$;

comment on function fixed_assets.accounts_in_use(uuid) is
  'The accounts this module points at for one company: what its fixed assets are booked, depreciated and charged on, and what a disposal was settled against. Read by public.accounts_in_use() through the module convention.';

create or replace function fixed_assets.archive_tables()
returns table (
  table_name  text,
  disposition text,
  reason      text,
  via_column  text,
  via_table   text,
  load_order  integer
)
language sql
immutable
as $$
  values
    ('fixed_assets'::text, 'exported'::text, null::text, null::text, null::text, 1),
    ('depreciation_lines', 'exported',       null,       null,       null,       2),
    ('disposals',          'exported',       null,       null,       null,       3);
$$;

comment on function fixed_assets.archive_tables() is
  'What an archive of one company does with each table of this module. Read by `public.company_archive_tables()`.';


-- ---------------------------------------------------------------------------
-- An archive written before the rename
--
-- A company archive names its tables `<schema>.<table>`, and one written by
-- version 1 of this module carries `assets.assets`,
-- `assets.depreciation_lines` and `assets.disposals`. The rows have not
-- changed, only the names they are filed under, so `import_company()` asks
-- each module for the names its tables were once exported under — the same
-- kind of convention as `archive_tables()` — and reads such an archive under
-- the names of today. Nothing in the socle names this module.
-- ---------------------------------------------------------------------------

create or replace function fixed_assets.archive_former_names()
returns table (former_name text, current_name text)
language sql
immutable
as $$
  values ('assets.assets'::text,             'fixed_assets.fixed_assets'::text),
         ('assets.depreciation_lines',       'fixed_assets.depreciation_lines'),
         ('assets.disposals',                'fixed_assets.disposals');
$$;

comment on function fixed_assets.archive_former_names() is
  'The names an archive of version 1 of this module filed its tables under, with the name each has today. Read by `public.archive_under_current_names()` before an import.';

revoke execute on function fixed_assets.archive_former_names() from public, anon;
grant execute on function fixed_assets.archive_former_names() to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Privileges, by name
--
-- `create or replace` keeps the privileges of a function that already exists,
-- and a rename keeps them too, so nothing above changed who may call what.
-- The two renamed functions are named here all the same, because a migration
-- that gives an object a name says who may reach it under that name.
-- ---------------------------------------------------------------------------

revoke execute on function fixed_assets.create_fixed_asset(uuid, text, text, date, numeric, text, text, text, text, integer, fixed_assets.depreciation_method, numeric, numeric, date, uuid, uuid, text) from public, anon;
grant execute on function fixed_assets.create_fixed_asset(uuid, text, text, date, numeric, text, text, text, text, integer, fixed_assets.depreciation_method, numeric, numeric, date, uuid, uuid, text) to authenticated, service_role;

revoke execute on function fixed_assets.dispose_fixed_asset(uuid, date, numeric, text, uuid) from public, anon;
grant execute on function fixed_assets.dispose_fixed_asset(uuid, date, numeric, text, uuid) to authenticated, service_role;

-- The trigger body stays callable by nobody, as `20260914151530` left it.
revoke execute on function fixed_assets.assert_may_post() from public, anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- The registry row
--
-- The schema the socle looks in for `can_disable()`, `accounts_in_use()` and
-- `archive_tables()`. A major version, because a project has something to do:
-- expose `fixed_assets` instead of `assets`, and call the functions by their
-- new names.
-- ---------------------------------------------------------------------------

update public.modules
   set schema_name = 'fixed_assets',
       version     = '2.0.0',
       description = 'Fixed assets, their depreciation schedule and their disposal. Durations, declining coefficients and the prorata convention are country pack data.'
 where code = 'assets'
   and (schema_name, version) is distinct from ('fixed_assets', '2.0.0');
