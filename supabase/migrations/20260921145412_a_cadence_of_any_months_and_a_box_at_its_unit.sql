-- Ekwo OS — a cadence of any whole number of months, and a box frozen at the
-- unit of its form.
--
-- Two gaps the packs outside the first four countries wrote down, each small
-- and each in the part of the schema that files a declaration.
--
-- **Cadences.** `20260921145411` added `bimonth`, `four_month` and `half_year`.
-- The functions that read a cadence knew three by name, and one of them failed
-- silently on a fourth: `upcoming_filings()` turned any cadence that was not a
-- month or a quarter into a year. So a cadence is now what it always was — a
-- number of months, anchored on 1 January — and the three functions that work a
-- period out read that number instead of a list of names:
--
--   declaration_period_months(cadence)   1, 2, 3, 4, 6 or 12
--   declaration_period_start(cadence, d) the first day of the period d is in
--   declaration_period_of(from, to)      which cadence two dates are a whole
--                                        one of, as before, for six of them
--
-- Anchoring is the calendar year's, and it is the law's where the law says it:
-- section 2 of the Irish Value-Added Tax Consolidation Act 2010 makes a taxable
-- period two months "beginning on 1 January, 1 March, 1 May…". Nothing here
-- names the country; it is the only anchoring the three shorter cadences ever
-- had, applied to the three longer ones.
--
-- What the guard of `vat_return()` does is unchanged, and it is not replaced:
-- it calls `declaration_period_of()`, which now recognises a bimonth. It still
-- refuses only when the company recorded a cadence, the form offers it, the
-- dates are a whole cadence the form also offers, and the two differ. A
-- half-year asked of a form that is not filed half-yearly is still an analysis.
--
-- **Decimals.** `tax_filing_boxes.amount` was `numeric(16, 2)`: a return in a
-- currency without decimals froze `1000000.00` where `vat_return()` answered
-- `1000000`, and one in a currency with three would have been cut. The column
-- has no scale now, and the figure is what `round_amount()` makes of it. Lifting
-- a precision constraint on a numeric does not rewrite the table and changes no
-- stored value: what was frozen at two decimals reads as it did.
--
-- **The unit of a form.** A form may be filed in coarser units than its
-- currency — California's CDTFA-401 asks for whole dollars, over a ledger kept in
-- cents. That is a property of the form, not of the country, so it sits on
-- `tax_report_templates.rounding_unit`, a power of ten, with the text that sets
-- it. Null is the currency. `vat_return()` keeps answering the exact figures,
-- because it is also the analysis and the drift; what is rounded to the form's
-- unit is what is **frozen** — `prepare_filing()` and `supersede_filing()` — and
-- what the freeze is compared with — `filing_drift()`. `filing_rounding()` is
-- the one place that unit is read, and it hands `round_amount()` a
-- `money_rounding` like every other amount of the schema. Each box is rounded on
-- its own, from its exact figure: a total is the exact total rounded, never the
-- sum of rounded lines.

-- ---------------------------------------------------------------------------
-- A cadence is a number of months
-- ---------------------------------------------------------------------------

create or replace function declaration_period_months(p_period declaration_period)
returns integer
language sql
immutable
as $$
  select case p_period
           when 'month'      then 1
           when 'bimonth'    then 2
           when 'quarter'    then 3
           when 'four_month' then 4
           when 'half_year'  then 6
           when 'year'       then 12
         end;
$$;

comment on function declaration_period_months(declaration_period) is
  'How many months a cadence lasts: 1, 2, 3, 4, 6 or 12. Every function that works out a period reads this number rather than a list of names, so a cadence added to the type is a line here and nowhere else.';

create or replace function declaration_period_start(p_period declaration_period, p_day date)
returns date
language sql
immutable
as $$
  select make_date(
           extract(year from p_day)::integer,
           ((extract(month from p_day)::integer - 1) / declaration_period_months(p_period))
             * declaration_period_months(p_period) + 1,
           1);
$$;

comment on function declaration_period_start(declaration_period, date) is
  'The first day of the period of this cadence a day falls in, anchored on 1 January: a bimonth starts in January, March, May, July, September or November, a four-month period in January, May or September, a half-year in January or July.';

create or replace function declaration_period_of(p_from date, p_to date)
returns declaration_period
language sql
immutable
as $$
  select c.period
    from (values ('month'::declaration_period), ('bimonth'), ('quarter'),
                 ('four_month'), ('half_year'), ('year')) as c(period)
   where p_from = declaration_period_start(c.period, p_from)
     and p_to = (p_from + make_interval(months => declaration_period_months(c.period))
                 - interval '1 day')::date
   order by declaration_period_months(c.period)
   limit 1;
$$;

comment on function declaration_period_of(date, date) is
  'The cadence a pair of dates is a whole one of — month, bimonth, quarter, four_month, half_year, year, each anchored on 1 January — or null when the two dates are not a filing period at all.';

-- ---------------------------------------------------------------------------
-- upcoming_filings, on every cadence
-- ---------------------------------------------------------------------------
--
-- Replaced whole. The forms it lists are the ones `20260917170000` listed; the
-- periods are generated from the length of the cadence and its anchor, where
-- they were a case on three names that sent everything else to a year.

create or replace function upcoming_filings(
  p_company_id uuid,
  p_from       date,
  p_to         date
)
returns table (
  report_code  text,
  period_start date,
  period_end   date,
  due_date     date,
  state        tax_filing_state,
  filing_id    uuid
)
language sql
stable
security invoker
as $$
  with forms as (
    -- Every form this company has a cadence for, and the periodic return it
    -- files even when nobody has written a cadence down for it.
    select p.report_code, p.period as cadence
      from company_filing_periods p
     where p.company_id = p_company_id
    union
    select periodic_return_code(p_company_id),
           coalesce(
             (select p.period from company_filing_periods p
               where p.company_id = p_company_id
                 and p.report_code = periodic_return_code(p_company_id)),
             (select t.period_default from tax_report_templates t
               join companies c on c.id = p_company_id
              where t.code = periodic_return_code(p_company_id)
                and t.country in (c.country, c.fiscal_country)))
     where periodic_return_code(p_company_id) is not null
  ),
  periods as (
    select f.report_code,
           g.start::date as period_start,
           (g.start + make_interval(months => declaration_period_months(f.cadence))
            - interval '1 day')::date as period_end
    from forms f
    cross join lateral generate_series(
      declaration_period_start(f.cadence, p_from)::timestamp,
      p_to::timestamp,
      make_interval(months => declaration_period_months(f.cadence))
    ) as g(start)
    where f.cadence is not null
  )
  select p.report_code,
         p.period_start,
         p.period_end,
         filing_deadline(p_company_id, p.report_code, p.period_end),
         f.state,
         f.id
  from periods p
  left join tax_filings f
    on f.company_id = p_company_id
   and f.report_code = p.report_code
   and f.period_start = p.period_start
   and f.period_end = p.period_end
   and f.state <> 'superseded'
  order by p.period_end, p.report_code;
$$;

comment on function upcoming_filings(uuid, date, date) is
  'What this company has to file between two dates: the periods its cadences produce — any whole number of months, anchored on 1 January — the day each is due where the pack says, and the declaration already prepared or sent against it. Read-only; sending the reminder is somebody else''s job, because a reminder needs a channel and somebody to operate it.';

-- ---------------------------------------------------------------------------
-- A frozen box at the decimals of its currency
-- ---------------------------------------------------------------------------

alter table tax_filing_boxes alter column amount type numeric;

comment on column tax_filing_boxes.amount is
  'The figure as it was filed, at the decimals of the company''s currency or at the unit of the form where the form names a coarser one (tax_report_templates.rounding_unit). No scale on the column: a return in a currency without decimals freezes 1000000, not 1000000.00.';

-- ---------------------------------------------------------------------------
-- The unit a form is filed in
-- ---------------------------------------------------------------------------

alter table tax_report_templates
  add column if not exists rounding_unit       numeric,
  add column if not exists rounding_reference  text,
  add column if not exists rounding_source_key text;

comment on column tax_report_templates.rounding_unit is
  'The unit the figures of this form are filed in, where it is coarser than the currency: 1 for a form filed in whole dollars over a ledger kept in cents. A power of ten. Null is the currency''s own decimals, which is every form that says nothing. Read by filing_rounding() when a declaration is frozen; never by vat_return(), which answers the exact figures.';
comment on column tax_report_templates.rounding_reference is
  'The text that sets the unit — the instruction printed on the form, or the rule behind it. Filled exactly when rounding_unit is.';
comment on column tax_report_templates.rounding_source_key is
  'Key of the register entry that reference is in.';

alter table tax_report_templates
  add constraint tax_report_templates_rounding_unit_is_a_power_of_ten check (
    rounding_unit is null
    or (rounding_unit > 0
        and rounding_unit = power(10::numeric, round(log(rounding_unit))))
  );

alter table tax_report_templates
  add constraint tax_report_templates_rounding_unit_has_its_text check (
    (rounding_unit is null) = (rounding_reference is null)
    and (rounding_source_key is null or rounding_reference is not null)
  );

create or replace function filing_rounding(p_company_id uuid, p_report_code text)
returns money_rounding
language plpgsql
stable
security invoker
as $$
declare
  v_out  money_rounding;
  v_unit numeric;
begin
  v_out := rounding_of(p_company_id);

  -- The form of that code the company may file: its own country's first, as
  -- `filing_deadline()` reads it. A unit finer than the currency is not a unit
  -- the currency has, so the currency's decimals are a floor as well as the
  -- default.
  select t.rounding_unit into v_unit
    from tax_report_templates t
    join companies c on c.id = p_company_id
   where t.code = p_report_code
     and t.country in (c.country, c.fiscal_country)
     and t.rounding_unit is not null
   order by (t.country = c.fiscal_country) desc
   limit 1;

  if v_unit is not null then
    v_out.decimals := least(v_out.decimals, (-round(log(v_unit)))::smallint);
  end if;
  return v_out;
end;
$$;

comment on function filing_rounding(uuid, text) is
  'How a figure of this form is written when it is frozen for this company: the currency''s decimals and the country''s method, coarsened to the unit of the form where the form names one. The only reader of tax_report_templates.rounding_unit.';

-- ---------------------------------------------------------------------------
-- The three functions that freeze a declaration or compare with it
-- ---------------------------------------------------------------------------
--
-- Each is `20260917180000` with the figure passed through `filing_rounding()`,
-- and nothing else changed. For a form that names no unit, `round_amount()` at
-- the currency is what `vat_return()` has already done, so the frozen figures
-- of every pack of this repository are the ones they were.

create or replace function prepare_filing(
  p_company_id  uuid,
  p_from        date,
  p_to          date,
  p_report_code text default null
)
returns tax_filings
language plpgsql
volatile
security invoker
as $$
declare
  v_code   text;
  v_filing tax_filings;
  v_round  money_rounding;
begin
  v_code := coalesce(p_report_code, periodic_return_code(p_company_id));
  if v_code is null then
    raise exception 'no_report_code: the pack of this company names no periodic return, so say which form this is';
  end if;

  select * into v_filing
  from tax_filings f
  where f.company_id = p_company_id
    and f.report_code = v_code
    and f.period_start = p_from
    and f.period_end = p_to
    and f.state <> 'superseded';

  if found and v_filing.state not in ('draft', 'ready') then
    raise exception 'filing_already_% : % for % to % has gone; a change to it is a corrective',
      v_filing.state, v_code, p_from, p_to;
  end if;

  if not found then
    insert into tax_filings (company_id, report_code, period_start, period_end)
    values (p_company_id, v_code, p_from, p_to)
    returning * into v_filing;
  else
    update tax_filings set state = 'draft' where id = v_filing.id returning * into v_filing;
    delete from tax_filing_boxes where filing_id = v_filing.id;
  end if;

  v_round := filing_rounding(p_company_id, v_code);

  insert into tax_filing_boxes (filing_id, box, kind, amount)
  select v_filing.id, r.box, r.kind, round_amount(r.amount, v_round)
  from vat_return(p_company_id, p_from, p_to, v_code) r
  where not r.hidden;

  update tax_filings set prepared_at = now() where id = v_filing.id
  returning * into v_filing;

  return v_filing;
end;
$$;

comment on function prepare_filing(uuid, date, date, text) is
  'Computes the declaration and keeps the answer, box by box and kind by kind, each figure at the unit the form is filed in (filing_rounding()). Called again on a draft it refreshes; on a declaration that has gone it refuses and says the word for what is needed instead — a corrective.';

create or replace function supersede_filing(p_filing_id uuid)
returns tax_filings
language plpgsql
volatile
security invoker
as $$
declare
  v_old   tax_filings;
  v_new   tax_filings;
  v_round money_rounding;
begin
  select * into v_old from tax_filings f where f.id = p_filing_id;
  if not found then
    raise exception 'not_found: filing %', p_filing_id using errcode = 'no_data_found';
  end if;
  if v_old.state in ('draft', 'ready') then
    raise exception 'filing_not_sent: a declaration that has not gone is corrected by preparing it again';
  end if;
  if v_old.state = 'superseded' then
    raise exception 'filing_already_superseded: % was already replaced', p_filing_id;
  end if;

  update tax_filings set state = 'superseded' where id = p_filing_id;

  insert into tax_filings (company_id, report_code, period_start, period_end,
                           due_date, supersedes_id)
  values (v_old.company_id, v_old.report_code, v_old.period_start, v_old.period_end,
          v_old.due_date, v_old.id)
  returning * into v_new;

  v_round := filing_rounding(v_old.company_id, v_old.report_code);

  insert into tax_filing_boxes (filing_id, box, kind, amount)
  select v_new.id, r.box, r.kind, round_amount(r.amount, v_round)
  from vat_return(v_old.company_id, v_old.period_start, v_old.period_end, v_old.report_code) r
  where not r.hidden;

  update tax_filings set prepared_at = now() where id = v_new.id returning * into v_new;

  return v_new;
end;
$$;

comment on function supersede_filing(uuid) is
  'Opens a corrective: the declaration that went becomes superseded and a new draft is prepared from today''s ledger, at the unit the form is filed in, pointing at it. What was sent stays as it was sent.';

create or replace function filing_drift(p_filing_id uuid)
returns table (
  box        text,
  kind       text,
  filed      numeric,
  ledger     numeric,
  difference numeric
)
language plpgsql
stable
security invoker
as $$
declare
  v_filing tax_filings;
  v_round  money_rounding;
begin
  select * into v_filing from tax_filings f where f.id = p_filing_id;
  if not found then
    raise exception 'not_found: filing %', p_filing_id using errcode = 'no_data_found';
  end if;
  -- The ledger is read at the unit the figures were frozen at: a form filed
  -- in whole dollars has not drifted because the ledger holds the cents.
  v_round := filing_rounding(v_filing.company_id, v_filing.report_code);

  return query
  with today as (
    select r.box, r.kind, round_amount(r.amount, v_round) as amount
    from vat_return(v_filing.company_id, v_filing.period_start, v_filing.period_end,
                    v_filing.report_code) r
    where not r.hidden
  ),
  filed as (
    select b.box, b.kind, b.amount from tax_filing_boxes b where b.filing_id = p_filing_id
  )
  select coalesce(f.box, t.box),
         coalesce(f.kind, t.kind),
         coalesce(f.amount, 0),
         coalesce(t.amount, 0),
         coalesce(t.amount, 0) - coalesce(f.amount, 0)
  from filed f
  full outer join today t on t.box = f.box and t.kind = f.kind
  where coalesce(t.amount, 0) <> coalesce(f.amount, 0)
  order by 1, 2;
end;
$$;

comment on function filing_drift(uuid) is
  'Box by box and kind by kind, what the ledger says now — at the unit the form is filed in — against what was filed, for the figures where the two disagree. Empty is the answer everybody wants; anything else is either a corrective to file or an entry in the wrong period.';

-- ---------------------------------------------------------------------------
-- Grants
-- ---------------------------------------------------------------------------

revoke execute on all functions in schema public from public;

revoke execute on function declaration_period_months(declaration_period) from anon;
revoke execute on function declaration_period_start(declaration_period, date) from anon;
revoke execute on function declaration_period_of(date, date) from anon;
revoke execute on function upcoming_filings(uuid, date, date) from anon;
revoke execute on function filing_rounding(uuid, text) from anon;
revoke execute on function prepare_filing(uuid, date, date, text) from anon;
revoke execute on function supersede_filing(uuid) from anon;
revoke execute on function filing_drift(uuid) from anon;

grant execute on function declaration_period_months(declaration_period) to authenticated, service_role;
grant execute on function declaration_period_start(declaration_period, date) to authenticated, service_role;
grant execute on function declaration_period_of(date, date) to authenticated, service_role;
grant execute on function upcoming_filings(uuid, date, date) to authenticated, service_role;
grant execute on function filing_rounding(uuid, text) to authenticated, service_role;
grant execute on function prepare_filing(uuid, date, date, text) to authenticated, service_role;
grant execute on function supersede_filing(uuid) to authenticated, service_role;
grant execute on function filing_drift(uuid) to authenticated, service_role;
