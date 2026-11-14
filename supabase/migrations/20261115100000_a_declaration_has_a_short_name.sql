-- Ekwo OS — a declaration has a short name, and the calendar says it.
--
-- A form of `tax_report_templates` has a code (`BE-VAT-PERIODIC`) and its
-- official name in the language of the country ("Déclaration périodique à la
-- TVA", "Déclaration de TVA 3310-CA3"). The code is for machines and the
-- official name is long: a screen that lists forty companies' deadlines
-- shows one or the other, and neither is how an accountant of the country
-- says the declaration out loud. `short_name` is that: a few words, in the
-- language of the country, declared by the pack where it knows them — read on
-- the portal or the notice of the administration, never made up.
--
-- **Optional, and null is the ordinary answer.** A pack that names no short
-- name compiles a seed that does not mention the column, so it still loads
-- on a schema from before this file, and a screen shows the official name
-- where the short one is null.
--
-- **The calendar says both.** `upcoming_filings()` and
-- `portfolio_upcoming_filings()` answer with two columns more, `report_name`
-- and `report_short_name`, read from the form of the company's fiscal
-- country (its other country where only that one carries the code, as the
-- forms of `upcoming_filings()` are found). They are added at the end of the
-- row, so a caller that read the columns by name or by position reads the
-- same values as before; the functions are dropped and created again
-- because the shape of their answer changes, with the same arguments, the
-- same body otherwise, the same comments completed, the same grants.

alter table ekwo.tax_report_templates
  add column if not exists short_name text;

alter table ekwo.tax_report_templates
  drop constraint if exists tax_report_templates_short_name_length;
alter table ekwo.tax_report_templates
  add constraint tax_report_templates_short_name_length
  check (short_name is null or char_length(btrim(short_name)) between 1 and 40);

comment on column ekwo.tax_report_templates.short_name is
  'How the accountants of the country name this declaration in a few words, in its language — what a calendar or a list of deadlines shows. Declared by the pack where it knows it, read on the portal or the notice of the administration; null where it does not, and a screen then shows `name`, the official one.';

-- ---------------------------------------------------------------------------
-- The two readers, dropped together: the portfolio reads the company's.
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
  report_short_name text
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
  ),
  returns as (
    select p.report_code,
           p.period_start,
           p.period_end,
           filing_deadline(p_company_id, p.report_code, p.period_end) as due_date,
           f.state,
           f.id as filing_id,
           null::smallint as instalment
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
           i.sequence as instalment
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
         n.short_name
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
  'What this company has to file and pay on account between two dates: the periods its cadences produce — any whole number of months, anchored on 1 January — the day each is due where the pack says, and the declaration already prepared or sent against it; and the instalments its scheme asks for, one row each with instalment set to its sequence and the month it falls due in as its period. report_name is the official name of the form and report_short_name how the accountants of the country name it, null where the pack does not say. The periodic return is left out of the periods a regime of turnover_tax_regimes that replaces VAT covers entirely, and a form is left out of the periods the company''s VAT scheme does not file it in. Read-only; sending the reminder is somebody else''s job, because a reminder needs a channel and somebody to operate it.';

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
  report_short_name text
)
language sql
stable
security invoker
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
         l.report_short_name
    from portfolio p
    left join listed l on l.company_id = p.id
   order by l.due_date nulls last, l.period_end nulls last, p.name, p.id, l.report_code, l.instalment nulls first;
$$;

comment on function ekwo.portfolio_upcoming_filings(date, date) is
  'What falls due between two dates in every company the caller holds filings.read on, and in no other: the periods and the instalments upcoming_filings() produces, kept when the day they are due is in the window, with the official and the short name of each form. Every company of the portfolio is in the answer at least once, and a row without a date says why in `reason` — no_deadline_rule where the pack names no day for the form, nothing_due where nothing of the company falls in the window, no_form where the installation carries no return for it. instalment is set on a payment on account and null on a return. Invoker: it reads what the caller could have read company by company.';

revoke execute on function ekwo.portfolio_upcoming_filings(date, date) from public, anon;
grant execute on function ekwo.portfolio_upcoming_filings(date, date) to authenticated, service_role;

-- The revoke every file of this directory ends with, and the Data API told
-- the functions are there.
revoke execute on all functions in schema ekwo from public;

notify pgrst, 'reload schema';
