-- Ekwo OS — a declaration says when its tax is paid, where that is another day.
--
-- `tax_report_templates.deadline_*` (20260917170000) is the day a form is
-- filed. In most countries the tax of the period is paid on that same day, and
-- one date is the whole answer. In some it is not: Zimbabwe's return is due on
-- the 10th of the month after the period and its payment on the 15th
-- (Statutory Instrument 81 of 2025); North Macedonia's return 25 days after the
-- period and its payment five days later (Закон за ДДВ, articles 41 and 43).
-- A form that holds one day holds the wrong one for half of that question, and
-- six packs wrote the gap down.
--
-- **The payment day is a second rule of the same vocabulary.** Three columns,
-- `payment_rule`, `payment_day` and `payment_plus_days`, mirror the three of
-- the filing day and take the same closed `filing_deadline_rule`:
-- `day_of_month_after_period` with a day, or `last_day_of_month_after_period`,
-- either with days added. `depends_on_taxpayer` is refused here, and so is a
-- payment day on a form with no filing day of its own: a payment rule says
-- what differs from a filing date the pack knows. The text that sets the day
-- is the filing day's own `deadline_reference`, which cites both. Null is the
-- ordinary answer, and means the pack names one day for both.
--
-- **One computation.** `deadline_after_period()` is the case expression
-- `filing_deadline()` has carried since 20260917170000, moved out so that
-- `payment_deadline()` reads the same rules the same way. `filing_deadline()`
-- keeps its signature and its answer.
--
-- **The calendar says it.** `upcoming_filings()` and
-- `portfolio_upcoming_filings()` answer with `payment_due_date` at the end of
-- each row, null on an instalment, whose `due_date` is already a payment. The
-- functions are dropped and created again because the shape of their answer
-- changes, with the same arguments, the same body otherwise, the comments
-- completed and the same grants. A row of the portfolio is in the window by
-- the day it is filed, as before.
--
-- **A seed that names no payment day does not mention the columns**, so every
-- pack that declares none still loads on a schema from before this file.

alter table ekwo.tax_report_templates
  add column if not exists payment_rule      ekwo.filing_deadline_rule,
  add column if not exists payment_day       smallint,
  add column if not exists payment_plus_days smallint;

comment on column ekwo.tax_report_templates.payment_rule is
  'How the day the tax of a period is paid follows the end of the period, where it is not the day the form is filed. Null where the pack names one day for both, which is the ordinary case.';
comment on column ekwo.tax_report_templates.payment_day is
  'Day of the month that follows the period on which the tax is paid. Filled exactly when payment_rule is day_of_month_after_period.';
comment on column ekwo.tax_report_templates.payment_plus_days is
  'Days added to the payment date the rule produces — North Macedonia''s five days after its twenty-fifth.';

alter table ekwo.tax_report_templates
  drop constraint if exists tax_report_templates_payment_shape;
alter table ekwo.tax_report_templates
  add constraint tax_report_templates_payment_shape check (coalesce(
    case payment_rule
      when 'day_of_month_after_period' then
        payment_day between 1 and 31
        and coalesce(payment_plus_days, 0) >= 0
        and deadline_rule in ('day_of_month_after_period', 'last_day_of_month_after_period')
      when 'last_day_of_month_after_period' then
        payment_day is null
        and coalesce(payment_plus_days, 0) >= 0
        and deadline_rule in ('day_of_month_after_period', 'last_day_of_month_after_period')
      when 'depends_on_taxpayer' then false
      else payment_day is null and payment_plus_days is null
    end,
    -- A day the rule needs and is not given is a null comparison, which a
    -- check would otherwise let through.
    false)
  );

-- ---------------------------------------------------------------------------
-- deadline_after_period
--
-- A rule of `filing_deadline_rule`, its day and its extension, and the end of
-- a period in; the day it produces out. Null for `depends_on_taxpayer` and for
-- no rule.
-- ---------------------------------------------------------------------------

create or replace function ekwo.deadline_after_period(
  p_rule       ekwo.filing_deadline_rule,
  p_day        smallint,
  p_plus_days  smallint,
  p_period_end date
)
returns date
language sql
immutable
set search_path = ekwo, pg_temp
as $$
  select case p_rule
           when 'day_of_month_after_period' then
             -- The day the rule names, in the month that follows. A day the
             -- month does not have lands on its last: `make_date` would raise,
             -- and the thirty-first of a thirty-day month is a date the
             -- administration reads as the end of it.
             least(
               (date_trunc('month', p_period_end + interval '1 month')
                + make_interval(days => p_day - 1))::date,
               (date_trunc('month', p_period_end + interval '2 month') - interval '1 day')::date
             )
           when 'last_day_of_month_after_period' then
             (date_trunc('month', p_period_end + interval '2 month') - interval '1 day')::date
           else null
         end
         + coalesce(p_plus_days, 0);
$$;

comment on function ekwo.deadline_after_period(ekwo.filing_deadline_rule, smallint, smallint, date) is
  'The day a rule of filing_deadline_rule produces for a period ending on a date: the day it names in the month that follows (its last day where the month is shorter), or the last day of that month, plus the days it adds. Null for depends_on_taxpayer, which assigns the day per filer, and for no rule. The one computation filing_deadline() and payment_deadline() share.';

create or replace function ekwo.filing_deadline(
  p_company_id  uuid,
  p_report_code text,
  p_period_end  date
)
returns date
language sql
stable
security invoker
set search_path = ekwo, pg_temp
as $$
  select deadline_after_period(t.deadline_rule, t.deadline_day, t.deadline_plus_days, p_period_end)
  from tax_report_templates t
  join companies c on c.id = p_company_id
  where t.code = p_report_code
    and t.country in (c.country, c.fiscal_country)
    and t.deadline_rule is not null
  limit 1;
$$;

-- ---------------------------------------------------------------------------
-- payment_deadline
--
-- The end of a period in, the day its tax is paid out — where the pack names
-- one apart from the day the form is filed. Null where it does not: the form
-- then names one day, and `filing_deadline()` is it.
-- ---------------------------------------------------------------------------

create or replace function ekwo.payment_deadline(
  p_company_id  uuid,
  p_report_code text,
  p_period_end  date
)
returns date
language sql
stable
security invoker
set search_path = ekwo, pg_temp
as $$
  select deadline_after_period(t.payment_rule, t.payment_day, t.payment_plus_days, p_period_end)
  from tax_report_templates t
  join companies c on c.id = p_company_id
  where t.code = p_report_code
    and t.country in (c.country, c.fiscal_country)
    and t.payment_rule is not null
  limit 1;
$$;

comment on function ekwo.payment_deadline(uuid, text, date) is
  'When the tax of a period closed on this date has to be paid, where the pack names a day apart from the day the form is filed — Zimbabwe''s 15th beside a return due on the 10th. Null where the pack names none: the form then has one day, the one filing_deadline() answers.';

revoke execute on function ekwo.deadline_after_period(ekwo.filing_deadline_rule, smallint, smallint, date) from public, anon;
grant execute on function ekwo.deadline_after_period(ekwo.filing_deadline_rule, smallint, smallint, date) to authenticated, service_role;
revoke execute on function ekwo.payment_deadline(uuid, text, date) from public, anon;
grant execute on function ekwo.payment_deadline(uuid, text, date) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- The two readers of the calendar, dropped together: the portfolio reads the
-- company's.
-- ---------------------------------------------------------------------------

drop function if exists ekwo.portfolio_upcoming_filings(date, date);
drop function if exists ekwo.upcoming_filings(uuid, date, date);

create function ekwo.upcoming_filings(
  p_company_id uuid,
  p_from       date,
  p_to         date
)
returns table (
  report_code       text,
  period_start      date,
  period_end        date,
  due_date          date,
  state             tax_filing_state,
  filing_id         uuid,
  instalment        smallint,
  report_name       text,
  report_short_name text,
  payment_due_date  date
)
language sql
stable
security invoker
set search_path = ekwo, pg_temp
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
  ),
  returns as (
    select p.report_code,
           p.period_start,
           p.period_end,
           filing_deadline(p_company_id, p.report_code, p.period_end) as due_date,
           f.state,
           f.id as filing_id,
           null::smallint as instalment,
           payment_deadline(p_company_id, p.report_code, p.period_end) as payment_due_date
    from periods p
    left join tax_filings f
      on f.company_id = p_company_id
     and f.report_code = p.report_code
     and f.period_start = p.period_start
     and f.period_end = p.period_end
     and f.state <> 'superseded'
    -- A company under a regime that replaces VAT for the whole period does not
    -- file the periodic VAT return of that period.
    where not (p.report_code is not distinct from periodic_return_code(p_company_id)
               and coalesce('vat'::tax_kind = any ((turnover_tax_regime_at(p_company_id, p.period_start)).replaces), false)
               and coalesce('vat'::tax_kind = any ((turnover_tax_regime_at(p_company_id, p.period_end)).replaces), false))
      -- Nor a form its scheme does not file.
      and vat_scheme_files(p_company_id, p.report_code, p.period_end)
  ),
  -- The instalments of every year the window touches, from the scheme the
  -- company is on at the end of that year.
  years as (
    select g.y::date as year_start, (g.y + interval '1 year' - interval '1 day')::date as year_end
      from generate_series(date_trunc('year', p_from), p_to::timestamp, interval '1 year') as g(y)
  ),
  instalments as (
    select i.report_code,
           i.due_month as period_start,
           (i.due_month + interval '1 month' - interval '1 day')::date as period_end,
           i.due_date,
           null::tax_filing_state as state,
           null::uuid as filing_id,
           i.sequence as instalment,
           null::date as payment_due_date
      from years y
      cross join lateral instalment_plan(p_company_id, y.year_start, y.year_end) i
     where (i.due_month + interval '1 month' - interval '1 day')::date >= p_from
       and i.due_month <= p_to
       and coalesce(i.reason, '') <> 'below_minimum'
  ),
  listed as (
    select * from returns
    union all
    select * from instalments
  )
  -- The names of the form, from the company's fiscal country first.
  select l.report_code,
         l.period_start,
         l.period_end,
         l.due_date,
         l.state,
         l.filing_id,
         l.instalment,
         n.name,
         n.short_name,
         l.payment_due_date
    from listed l
    left join lateral (
      select t.name, t.short_name
        from tax_report_templates t
        join companies c on c.id = p_company_id
       where t.code = l.report_code
         and t.country in (c.fiscal_country, c.country)
       order by (t.country = c.fiscal_country) desc
       limit 1
    ) n on true
   order by 3, 1, 7 nulls first;
$$;

comment on function ekwo.upcoming_filings(uuid, date, date) is
  'What this company has to file and pay on account between two dates: the periods its cadences produce — any whole number of months, anchored on 1 January — the day each is due where the pack says, and the declaration already prepared or sent against it; and the instalments its scheme asks for, one row each with instalment set to its sequence and the month it falls due in as its period. report_name is the official name of the form and report_short_name how the accountants of the country name it, null where the pack does not say. payment_due_date is the day the tax of the period is paid where the pack names one apart from the day the form is filed, and null where it names none — the form then names one day, due_date — and on an instalment, whose due_date is already a payment. The periodic return is left out of the periods a regime of turnover_tax_regimes that replaces VAT covers entirely, and a form is left out of the periods the company''s VAT scheme does not file it in. Read-only; sending the reminder is somebody else''s job, because a reminder needs a channel and somebody to operate it.';

revoke execute on function ekwo.upcoming_filings(uuid, date, date) from public, anon;
grant execute on function ekwo.upcoming_filings(uuid, date, date) to authenticated, service_role;

create function ekwo.portfolio_upcoming_filings(
  p_from date,
  p_to   date
)
returns table (
  company_id        uuid,
  company_name      text,
  report_code       text,
  period_start      date,
  period_end        date,
  due_date          date,
  state             tax_filing_state,
  filing_id         uuid,
  reason            text,
  instalment        smallint,
  report_name       text,
  report_short_name text,
  payment_due_date  date
)
language sql
stable
security invoker
set search_path = ekwo, pg_temp
as $$
  with portfolio as (
    select c.id, c.name
      from companies c
     where has_capability(c.id, 'filings.read')
  ),
  -- A return is due in the month that follows its period, plus the days an
  -- administration grants. So the periods that can fall due from `p_from` on
  -- ended at most two months and that many days before it, and the calendar
  -- of a company is asked for once, from there.
  reach as (
    select (p_from - interval '2 month'
            - make_interval(days => coalesce(max(t.deadline_plus_days), 0)))::date as start
      from tax_report_templates t
  ),
  listed as (
    select p.id as company_id, u.*
      from portfolio p
      cross join reach r
      cross join lateral upcoming_filings(p.id, r.start, p_to) u
     where case
             when u.due_date is not null then u.due_date between p_from and p_to
             else u.period_end < p_to
                  and (date_trunc('month', u.period_end + interval '2 month')
                       - interval '1 day')::date >= p_from
           end
  )
  select p.id,
         p.name,
         l.report_code,
         l.period_start,
         l.period_end,
         l.due_date,
         l.state,
         l.filing_id,
         case
           when l.company_id is not null and l.due_date is null then 'no_deadline_rule'
           when l.company_id is not null then null
           when periodic_return_code(p.id) is null
                and not exists (select 1 from company_filing_periods f
                                 where f.company_id = p.id) then 'no_form'
           else 'nothing_due'
         end,
         l.instalment,
         l.report_name,
         l.report_short_name,
         l.payment_due_date
    from portfolio p
    left join listed l on l.company_id = p.id
   order by l.due_date nulls last, l.period_end nulls last, p.name, p.id, l.report_code, l.instalment nulls first;
$$;

comment on function ekwo.portfolio_upcoming_filings(date, date) is
  'What falls due between two dates in every company the caller holds filings.read on, and in no other: the periods and the instalments upcoming_filings() produces, kept when the day they are due is in the window, with the official and the short name of each form and, where the pack names one apart, the day the tax of the period is paid (payment_due_date; a row is in the window by the day it is filed). Every company of the portfolio is in the answer at least once, and a row without a date says why in `reason` — no_deadline_rule where the pack names no day for the form, nothing_due where nothing of the company falls in the window, no_form where the installation carries no return for it. instalment is set on a payment on account and null on a return. Invoker: it reads what the caller could have read company by company.';

revoke execute on function ekwo.portfolio_upcoming_filings(date, date) from public, anon;
grant execute on function ekwo.portfolio_upcoming_filings(date, date) to authenticated, service_role;

-- The revoke every file of this directory ends with, and the Data API told
-- the functions are there.
revoke execute on all functions in schema ekwo from public;

notify pgrst, 'reload schema';
