-- Ekwo OS, module tax 1.1.0 — the provision entry, and the plan of prepayments.
--
-- Version 1.0.0 estimated the tax and kept the estimate. This one takes the
-- two steps the pack already declared figures for, and that nothing read:
--
--   * **the provision**, `tax.book_provision(computation)`: one entry, through
--     `public.post_module_entry()`, that brings the tax charge of the year on
--     the pack's expense account to what a recorded computation says, against
--     the pack's payable account. It books the difference with what that
--     account already carries for the year, so a charge somebody booked by
--     hand is not booked twice, and a later computation books only what moved.
--     The entry is named by the computation, so a second call returns the
--     first entry instead of writing another.
--   * **the prepayments**, `tax.prepayment_plan(company, fiscal_year, at)`:
--     when each instalment of the year falls, what it is worth, what was paid
--     towards it, and — where nothing is compulsory and a surcharge falls on
--     what was not paid in advance — how much to pay at each instalment still
--     to come so that no surcharge is left.
--   * **what was paid**, `tax.prepayments`: each payment the company made in
--     advance, on the day it made it, written with tax.write like every other
--     declaration. The plan reads it; the provision does not.
--
-- The engine still knows no country. The accounts are the pack's
-- (`tax.country_rules`), the instalments, their days, their shares, their
-- credits, the surcharge and the exemption are the pack's
-- (`tax.prepayment_templates`). Nothing below names an account, a rate or a
-- day of the year.
--
-- **The provision does not move the estimate.** A pack starts the computation
-- from a result before income tax, or adds the tax charge back by a rule on
-- its accounts; either way a provision booked on the expense account leaves
-- the taxable base where it was. The golden tests hold every pack that
-- carries the section to that, on every company of its worked examples.
--
-- Rounding: every amount at the decimals of the company's currency, by
-- `public.round_amount()`, except the equal amount the plan proposes for each
-- instalment still to come, which is rounded up to the next unit of the
-- currency: rounded down, it would leave a cent of surcharge.

do $$
begin
  if to_regprocedure('public.post_module_entry(uuid, text, text, date, text, jsonb, uuid)') is null then
    raise exception 'socle_too_old: the tax module needs post_module_entry(). Run ekwo migrate first.';
  end if;
end;
$$;

-- ---------------------------------------------------------------------------
-- What was paid in advance
-- ---------------------------------------------------------------------------

create table tax.prepayments (
  id             uuid primary key default gen_random_uuid(),
  company_id     uuid not null references public.companies(id) on delete cascade,
  fiscal_year_id uuid not null references public.fiscal_years(id),
  paid_on        date not null,
  amount         numeric not null,
  entry_id       uuid references public.entries(id),
  note           text,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  constraint tax_prepayments_amount_positive check (amount > 0)
);

comment on table tax.prepayments is
  'One payment a company made in advance on the corporate income tax of a financial year, on the day it made it. Declared with tax.write; read by tax.prepayment_plan(), which counts it towards the first instalment due on or after that day.';
comment on column tax.prepayments.entry_id is
  'The entry of the ledger that carried the payment, where the company points at it: its bank entry. Optional, and never read for the amount: the amount is the one declared here.';

create index tax_prepayments_company_year_idx on tax.prepayments (company_id, fiscal_year_id);
create index tax_prepayments_fiscal_year_idx on tax.prepayments (fiscal_year_id);
create index tax_prepayments_entry_idx on tax.prepayments (entry_id);

create trigger tax_prepayments_set_updated_at
  before update on tax.prepayments
  for each row execute function public.set_updated_at();

-- A payment is written at the decimals of the company's currency, as every
-- other amount a company declares here.
create or replace function tax.round_prepayment()
returns trigger
language plpgsql
as $$
begin
  new.amount := public.round_amount(new.amount, public.rounding_of(new.company_id));
  if new.amount <= 0 then
    raise exception 'prepayment_not_positive: a payment in advance is an amount above zero at the decimals of the currency'
      using errcode = '23514';
  end if;
  return new;
end;
$$;

comment on function tax.round_prepayment() is
  'Writes a payment in advance at the decimals of the company currency, and refuses one that rounds to nothing.';

create trigger tax_prepayments_round
  before insert or update of amount, company_id on tax.prepayments
  for each row execute function tax.round_prepayment();

alter table tax.prepayments enable row level security;

create policy tax_prepayments_select on tax.prepayments
  for select using (
    public.module_enabled(company_id, 'tax')
    and public.has_capability(company_id, 'tax.read')
  );
create policy tax_prepayments_write on tax.prepayments
  for all using (
    public.module_enabled(company_id, 'tax')
    and public.has_capability(company_id, 'tax.write')
  )
  with check (
    public.module_enabled(company_id, 'tax')
    and public.has_capability(company_id, 'tax.write')
  );

grant select, insert, update, delete on table tax.prepayments to authenticated, service_role;

-- The year and the entry a payment names are of its own company, by one key
-- each, like every other reference of this schema (decision 0065).
do $$
begin
  perform public.scope_references_to_company('tax');
end;
$$;

-- ---------------------------------------------------------------------------
-- The provision
-- ---------------------------------------------------------------------------

create or replace function tax.book_provision(p_computation_id uuid)
returns uuid
language plpgsql
as $$
declare
  v_row     tax.computations%rowtype;
  v_year    public.fiscal_years%rowtype;
  v_company public.companies%rowtype;
  v_rules   tax.country_rules%rowtype;
  v_ref     text;
  v_entry   uuid;
  v_booked  numeric;
  v_delta   numeric;
  v_label   text;
  v_lines   jsonb;
begin
  -- A computation the caller cannot read does not exist for them: row level
  -- security answers that, with tax.read.
  select * into v_row from tax.computations c where c.id = p_computation_id;
  if not found then
    raise exception 'unknown_computation: %', p_computation_id;
  end if;
  if not public.module_is_enabled(v_row.company_id, 'tax') then
    raise exception 'module_not_enabled: the corporate income tax module (tax) is not enabled on this company'
      using errcode = '42501';
  end if;
  if not public.is_installer() and not public.has_capability(v_row.company_id, 'tax.write') then
    raise exception 'not_allowed: booking the provision of the tax needs tax.write'
      using errcode = '42501';
  end if;

  perform pg_advisory_xact_lock(hashtextextended('tax:' || v_row.company_id::text || ':' || v_row.fiscal_year_id::text, 0));

  -- Named by the computation: the same computation books one entry, once.
  v_ref := 'provision:' || v_row.id::text;
  select e.id into v_entry from public.entries e
   where e.company_id = v_row.company_id and e.module_code = 'tax' and e.module_ref = v_ref;
  if found then
    return v_entry;
  end if;

  select * into v_row from tax.computations c where c.id = p_computation_id;
  if v_row.status = 'superseded' then
    raise exception 'computation_superseded: version % was withdrawn, and the provision follows the computation that replaced it', v_row.version
      using errcode = '55006';
  end if;
  if exists (
    select 1 from tax.computations c
     where c.company_id = v_row.company_id and c.fiscal_year_id = v_row.fiscal_year_id
       and c.version > v_row.version
  ) then
    raise exception 'computation_not_latest: a later computation of the year was recorded after version %, and the provision follows the latest', v_row.version
      using errcode = '55006';
  end if;

  select * into v_year from public.fiscal_years f where f.id = v_row.fiscal_year_id;
  select * into v_company from public.companies c where c.id = v_row.company_id;
  select * into v_rules from tax.country_rules t
   where t.country = coalesce(v_company.fiscal_country, v_company.country);
  if not found then
    raise exception 'no_corporate_tax_rules: the country pack of % carries no corporate_tax section, so it names no account to book the tax on',
      coalesce(v_company.fiscal_country, v_company.country)
      using errcode = '55006';
  end if;

  -- What the expense account already carries for the year up to the day of
  -- the computation, read the way the income statement reads it: the entry
  -- that closes a year is not a charge of that year.
  select coalesce(sum(m.balance), 0) into v_booked
    from public.statement_account_matches(v_row.company_id, v_rules.result_statement_code,
                                          v_year.start_date, v_row.computed_at) m
   where m.account_code = v_rules.expense_account_code;

  v_delta := public.round_amount(v_row.tax, public.rounding_of(v_row.company_id)) - v_booked;
  if v_delta = 0 then
    return null;
  end if;

  v_label := format('%s — %s, provision (version %s)', v_rules.name, v_year.name, v_row.version);
  if v_delta > 0 then
    v_lines := jsonb_build_array(
      jsonb_build_object('account_code', v_rules.expense_account_code, 'debit', v_delta),
      jsonb_build_object('account_code', v_rules.payable_account_code, 'credit', v_delta));
  else
    v_lines := jsonb_build_array(
      jsonb_build_object('account_code', v_rules.payable_account_code, 'debit', -v_delta),
      jsonb_build_object('account_code', v_rules.expense_account_code, 'credit', -v_delta));
  end if;

  return public.post_module_entry(v_row.company_id, 'tax', v_ref, v_row.computed_at, v_label, v_lines);
end;
$$;

comment on function tax.book_provision(uuid) is
  'Books the tax of a recorded computation as a charge of its year: the difference between what the computation says and what the expense account of the pack already carries for the year up to the day of the computation, against the payable account of the pack, through post_module_entry(), dated on that day. Returns the entry, or null when there was nothing to book. The latest computation of a year, estimate or final; one entry per computation, so a second call returns the first. Needs tax.write, and the right to post entries.';

-- ---------------------------------------------------------------------------
-- The plan of prepayments
-- ---------------------------------------------------------------------------

create or replace function tax.instalment_date(
  p_month_basis text,
  p_month       integer,
  p_day         integer,
  p_start       date,
  p_end         date
)
returns date
language sql
immutable
as $$
  -- The first day of the month the instalment falls in: the n-th month of the
  -- year, or the first month of that name on or after the year opens.
  with month as (
    select case p_month_basis
             when 'fiscal' then (date_trunc('month', p_start) + make_interval(months => p_month - 1))::date
             else case when make_date(extract(year from p_start)::integer, p_month, 1) < date_trunc('month', p_start)::date
                       then make_date(extract(year from p_start)::integer + 1, p_month, 1)
                       else make_date(extract(year from p_start)::integer, p_month, 1)
                  end
           end as first_day
  ),
  -- A day the month does not have is its last.
  day as (
    select (m.first_day + (least(p_day, extract(day from (m.first_day + interval '1 month - 1 day'))::integer) - 1))::date as due
      from month m
  )
  select case when d.due between p_start and p_end then d.due end from day d;
$$;

comment on function tax.instalment_date(text, integer, integer, date, date) is
  'The day an instalment falls on in a financial year: the given day of the n-th month of the year (fiscal), or of the first month of that name on or after the year opens (calendar); the last day of the month where the month is shorter. Null when that day is outside the year.';

create or replace function tax.plan_instalments(p_instalments jsonb)
returns table (seq integer, due date, share numeric, credit numeric, paid numeric)
language sql
immutable
as $$
  select (x.o ->> 'seq')::integer, (x.o ->> 'due')::date, (x.o ->> 'share')::numeric,
         (x.o ->> 'credit')::numeric, (x.o ->> 'paid')::numeric
    from jsonb_array_elements(p_instalments) with ordinality as x(o, ordinality)
   order by x.ordinality;
$$;

comment on function tax.plan_instalments(jsonb) is
  'The instalments tax.prepayment_plan() gathers, as rows, in the order it gathered them.';

create or replace function tax.prepayment_plan(
  p_company_id     uuid,
  p_fiscal_year_id uuid,
  p_at             date default null,
  p_tax            numeric default null
)
returns table (
  sequence        integer,
  kind            text,
  code            text,
  due_date        date,
  base            numeric,
  rate            numeric,
  amount          numeric,
  paid            numeric,
  legal_reference text,
  source_key      text
)
language plpgsql
stable
as $$
#variable_conflict use_column
declare
  v_company   public.companies%rowtype;
  v_year      public.fiscal_years%rowtype;
  v_previous  public.fiscal_years%rowtype;
  v_country   char(2);
  v_rule      tax.prepayment_templates%rowtype;
  v_round     public.money_rounding;
  v_unit      numeric;
  v_from      date;
  v_tax       numeric;
  v_code      text;
  v_surcharge numeric;
  v_earned    numeric;
  v_left      numeric;
  v_open      numeric;
  v_open_n    integer;
  v_paid      numeric;
  v_each      numeric;
  v_planned   numeric := 0;
  v_count     integer;
  v_rows      jsonb := '[]'::jsonb;
  v_exempt    boolean := false;
  v_inst      jsonb;
  v_index     integer;
  v_late      jsonb := '[]'::jsonb;
  r           record;
begin
  -- 1. Who is asking, and about what.

  if not public.is_installer() then
    if not public.module_enabled(p_company_id, 'tax') then
      raise exception 'module_not_enabled: the corporate income tax module (tax) is not enabled on this company, or the caller is not a member of it'
        using errcode = '42501';
    end if;
    if not public.has_capability(p_company_id, 'tax.read') then
      raise exception 'not_allowed: planning the prepayments of this company needs tax.read'
        using errcode = '42501';
    end if;
  end if;

  select * into v_company from public.companies c where c.id = p_company_id;
  if not found then
    raise exception 'unknown_company: %', p_company_id;
  end if;
  select * into v_year from public.fiscal_years f
   where f.id = p_fiscal_year_id and f.company_id = p_company_id;
  if not found then
    raise exception 'unknown_fiscal_year: % is not a financial year of this company', p_fiscal_year_id;
  end if;
  if p_tax is not null and p_tax < 0 then
    raise exception 'negative_tax: the tax a plan is made for is zero or more'
      using errcode = '22023';
  end if;

  v_country := coalesce(v_company.fiscal_country, v_company.country);
  if not exists (select 1 from tax.country_rules t where t.country = v_country) then
    raise exception 'no_corporate_tax_rules: the country pack of % carries no corporate_tax section, so there is no rule to plan a prepayment from. A pack says it in packs/<cc>/corporate_tax.json.',
      v_country
      using errcode = '55006';
  end if;

  select count(*) into v_count from tax.prepayment_templates t
   where t.country = v_country
     and tax.in_force(t.valid_from, t.valid_to, t.valid_on, v_year.start_date, v_year.end_date);
  if v_count > 1 then
    raise exception 'rule_versions_overlap: the corporate tax rules of % hold two versions of the prepayments in force for %. Close the earlier one with a valid_to.',
      v_country, v_year.name
      using errcode = '55006';
  end if;
  select * into v_rule from tax.prepayment_templates t
   where t.country = v_country
     and tax.in_force(t.valid_from, t.valid_to, t.valid_on, v_year.start_date, v_year.end_date);
  if not found then
    raise exception 'no_prepayment_rules: the country pack of % carries no prepayment in force for %, so there is no plan to make',
      v_country, v_year.name
      using errcode = '55006';
  end if;

  v_round := public.rounding_of(p_company_id);
  v_unit  := power(10::numeric, -(v_round).decimals);
  -- The instalments still to come are the ones due on or after this day.
  v_from  := greatest(coalesce(p_at, v_year.start_date), v_year.start_date);

  -- 2. The instalments of the year, and what was paid towards each: a payment
  --    counts for the first instalment due on or after the day it was made.

  -- One object per instalment of the year, in the order they fall due. An
  -- instalment whose day is outside the year is not one of its instalments.
  select coalesce(jsonb_agg(x.o order by x.due, x.seq), '[]'::jsonb) into v_inst
    from (
      select d.due, d.seq,
             jsonb_build_object('seq', d.seq, 'due', d.due, 'share', d.share, 'credit', d.credit, 'paid', 0) as o
        from (
          select (i ->> 'sequence')::integer as seq,
                 tax.instalment_date(v_rule.month_basis, (i ->> 'month')::integer, (i ->> 'day')::integer,
                                     v_year.start_date, v_year.end_date) as due,
                 (i ->> 'share_percent')::numeric as share,
                 (i ->> 'credit_percent')::numeric as credit
            from jsonb_array_elements(v_rule.instalments) i
        ) d
       where d.due is not null
    ) x;

  for r in
    select p.paid_on, p.amount from tax.prepayments p
     where p.company_id = p_company_id and p.fiscal_year_id = p_fiscal_year_id
     order by p.paid_on, p.created_at
  loop
    select x.ordinality - 1 into v_index
      from jsonb_array_elements(v_inst) with ordinality as x(o, ordinality)
     where (x.o ->> 'due')::date >= r.paid_on
     order by x.ordinality
     limit 1;
    if found then
      v_inst := jsonb_set(v_inst, array[v_index::text, 'paid'],
                          to_jsonb((v_inst -> v_index::integer ->> 'paid')::numeric + r.amount));
    else
      -- Paid after the last instalment: towards the tax, and towards none of them.
      v_late := v_late || jsonb_build_array(jsonb_build_object(
        'kind', 'paid_late', 'due_date', r.paid_on, 'paid', r.amount));
    end if;
  end loop;

  select coalesce(sum((x.o ->> 'paid')::numeric), 0) into v_paid
    from jsonb_array_elements(v_inst) x(o);

  -- 3. What each instalment is worth.

  if v_rule.method = 'share_of_reference_tax' then
    -- The reference is the tax of the year before, as a final computation
    -- says it, unless the company states one.
    if p_tax is not null then
      v_tax  := public.round_amount(p_tax, v_round);
      v_code := 'stated';
    else
      select * into v_previous from public.fiscal_years f
       where f.company_id = p_company_id and f.end_date < v_year.start_date
       order by f.end_date desc limit 1;
      select c.tax into v_tax from tax.computations c
       where c.company_id = p_company_id and c.fiscal_year_id = v_previous.id and c.status = 'final';
      if v_tax is null then
        raise exception 'no_reference_tax: no year before % has a final computation of its tax, and its instalments are shares of that tax. Call the year before final, or state the reference tax.',
          v_year.name
          using errcode = '55006';
      end if;
      v_tax  := greatest(v_tax, 0);
      v_code := v_previous.name;
    end if;
    v_rows := v_rows || tax.line('reference_tax', v_code, null, null, null, v_tax,
                                 v_rule.legal_reference, v_rule.source_key);

    if v_rule.exempt_up_to is not null and v_tax <= v_rule.exempt_up_to then
      v_exempt := true;
      v_rows := v_rows || tax.line('exempt', null, null, v_tax, null, v_rule.exempt_up_to,
                                   v_rule.legal_reference, v_rule.source_key);
    end if;

    for r in select * from tax.plan_instalments(v_inst) loop
      v_each := case when v_exempt then 0 else public.round_amount(v_tax * r.share / 100, v_round) end;
      v_rows := v_rows || (tax.line('instalment', r.seq::text, null, v_tax, r.share, v_each,
                                    v_rule.legal_reference, v_rule.source_key) -> 0
                           || jsonb_build_object('due_date', r.due, 'paid', r.paid));
      v_planned := v_planned + v_each;
    end loop;

    v_rows := v_rows || (tax.line('total', null, null, null, null, v_planned) -> 0
                         || jsonb_build_object('paid', v_paid));
  else
    -- surcharge_on_shortfall. The tax of the year is the latest computation
    -- recorded for it, unless the company states the one it expects.
    if p_tax is not null then
      v_tax  := public.round_amount(p_tax, v_round);
      v_code := 'stated';
    else
      select c.tax, 'version ' || c.version into v_tax, v_code from tax.computations c
       where c.company_id = p_company_id and c.fiscal_year_id = p_fiscal_year_id and c.status <> 'superseded'
       order by c.version desc limit 1;
      if not found then
        raise exception 'no_computation: % has no computation of its tax to plan from. Record one with tax.record_computation(), or state the tax the year is expected to come to.',
          v_year.name
          using errcode = '55006';
      end if;
      v_tax := greatest(v_tax, 0);
    end if;
    v_rows := v_rows || tax.line('tax', v_code, null, null, null, v_tax);

    v_surcharge := public.round_amount(v_tax * v_rule.surcharge_percent / 100, v_round);
    v_rows := v_rows || tax.line('surcharge', null, null, v_tax, v_rule.surcharge_percent, v_surcharge,
                                 v_rule.legal_reference, v_rule.source_key);

    -- What the payments already made earn, instalment by instalment, summed
    -- before it is rounded once.
    select coalesce(sum(t.paid * t.credit / 100), 0)
      into v_earned from tax.plan_instalments(v_inst) t;
    v_left := greatest(v_surcharge - v_earned, 0);

    -- The same amount at every instalment still to come, enough for what they
    -- earn together to cover what is left of the surcharge — and never more,
    -- all together, than what is left of the tax.
    select coalesce(sum(t.credit), 0), count(*) into v_open, v_open_n
      from tax.plan_instalments(v_inst) t where t.due >= v_from;
    if v_left = 0 or v_open_n = 0 or v_open = 0 then
      v_each := 0;
    else
      v_each := ceil(v_left * 100 / v_open / v_unit) * v_unit;
      v_each := least(v_each, floor(greatest(v_tax - v_paid, 0) / v_open_n / v_unit) * v_unit);
    end if;

    for r in select * from tax.plan_instalments(v_inst) loop
      v_rows := v_rows || (tax.line('instalment', r.seq::text, null, null, r.credit,
                                    case when r.due >= v_from then v_each else 0 end,
                                    v_rule.legal_reference, v_rule.source_key) -> 0
                           || jsonb_build_object('due_date', r.due, 'paid', r.paid));
      if r.due >= v_from then
        v_planned := v_planned + v_each;
        v_earned  := v_earned + v_each * r.credit / 100;
      end if;
    end loop;

    v_rows := v_rows || (tax.line('total', null, null, null, null, v_planned) -> 0
                         || jsonb_build_object('paid', v_paid));
    v_rows := v_rows || tax.line('surcharge_left', null, null, null, null, greatest(v_surcharge - public.round_amount(v_earned, v_round), 0),
                                 v_rule.legal_reference, v_rule.source_key);
  end if;

  v_rows := v_rows || v_late;

  return query
    select (x.ordinality)::integer, x.line ->> 'kind', x.line ->> 'code', (x.line ->> 'due_date')::date,
           (x.line ->> 'base')::numeric, (x.line ->> 'rate')::numeric, (x.line ->> 'amount')::numeric,
           (x.line ->> 'paid')::numeric, x.line ->> 'legal_reference', x.line ->> 'source_key'
      from jsonb_array_elements(v_rows) with ordinality as x(line, ordinality);
end;
$$;

comment on function tax.prepayment_plan(uuid, uuid, date, numeric) is
  'The prepayments of a financial year under the rule of its country pack, line by line: each instalment with its day, its percentage, what it is worth and what was paid towards it. share_of_reference_tax: each instalment is its share of the final tax of the year before, or of a reference the company states, and nothing where that tax is within the exemption. surcharge_on_shortfall: the surcharge on the tax of the latest computation of the year, or of a tax the company states, what the payments made already earn against it, and the same amount at each instalment due on or after p_at that leaves no surcharge — never more, together, than the tax still unpaid. Reads and writes nothing else.';

-- ---------------------------------------------------------------------------
-- What the earlier version said was not read yet
-- ---------------------------------------------------------------------------

comment on column tax.country_rules.expense_account_code is
  'The account the tax charge of the year is booked on, by tax.book_provision().';
comment on column tax.country_rules.payable_account_code is
  'The account the estimated tax debt is carried on, against the charge tax.book_provision() books.';
comment on column tax.country_rules.receivable_account_code is
  'The account a prepayment or a refund to come is carried on, where the chart keeps one apart. **Declared, no reader yet**: the company books its payments itself, and tax.prepayments says what they were.';
comment on table tax.prepayment_templates is
  'When a company of this country pays its tax in advance, and what each payment is worth. Read by tax.prepayment_plan().';

-- ---------------------------------------------------------------------------
-- The conventions the socle looks a module up by
-- ---------------------------------------------------------------------------

create or replace function tax.archive_tables()
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
    ('company_parameters'::text, 'exported'::text, null::text, null::text, null::text, 1),
    ('adjustments',              'exported',       null,       null,       null,       2),
    ('credits',                  'exported',       null,       null,       null,       3),
    ('computations',             'exported',       null,       null,       null,       4),
    ('computation_lines',        'exported',       null,       null,       null,       5),
    ('losses',                   'exported',       null,       null,       null,       6),
    ('loss_uses',                'exported',       null,       null,       null,       7),
    ('prepayments',              'exported',       null,       null,       null,       8);
$$;

comment on function tax.archive_tables() is
  'What an archive of one company does with each table of this module: all eight travel. The seven reference tables belong to the installation and to no company. Read by `public.company_archive_tables()`.';

-- ---------------------------------------------------------------------------
-- Privileges, by name
-- ---------------------------------------------------------------------------

revoke execute on function tax.round_prepayment() from public, anon, authenticated, service_role;

revoke execute on function tax.book_provision(uuid) from public, anon;
revoke execute on function tax.instalment_date(text, integer, integer, date, date) from public, anon;
revoke execute on function tax.plan_instalments(jsonb) from public, anon;
revoke execute on function tax.prepayment_plan(uuid, uuid, date, numeric) from public, anon;
revoke execute on function tax.archive_tables() from public, anon;

grant execute on function tax.book_provision(uuid) to authenticated, service_role;
grant execute on function tax.instalment_date(text, integer, integer, date, date) to authenticated, service_role;
grant execute on function tax.plan_instalments(jsonb) to authenticated, service_role;
grant execute on function tax.prepayment_plan(uuid, uuid, date, numeric) to authenticated, service_role;
grant execute on function tax.archive_tables() to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- The registry row
-- ---------------------------------------------------------------------------

comment on schema tax is
  'Ekwo module `tax`: corporate income tax estimated from the books. Country rules are pack data, company parameters are declared; the provision reaches the ledger only through public.post_module_entry().';

update public.modules
   set version     = '1.1.0',
       description = 'Corporate income tax estimated from the books: the accounting result, the adjustments, the losses, the rates and their conditions of a country are pack data, and what a company declares about itself is its own. Books the provision of a computation through post_module_entry(), and plans the prepayments of a year.'
 where code = 'tax';
