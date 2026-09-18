-- Ekwo OS — when a declaration is due.
--
-- The schema knows how *often* a company files — `company_filing_periods`,
-- one cadence per form — and has never known **when**. A cadence without a
-- deadline answers "every quarter" to the question "what do I owe this week",
-- which is not an answer.
--
-- The date is not a fact about the ledger, so it is not in the core: it is a
-- rule of the country, and it goes where every other country rule goes — into
-- the pack, in a closed vocabulary, with the text that sets it.
--
--   day_of_month_after_period       the twentieth of the month that follows
--   last_day_of_month_after_period  the last day of that month
--
-- Either may add `plus_days`, which exists because the United Kingdom grants
-- seven of them to a return filed online while the regulation still says the
-- last day of the month.
--
-- **What the vocabulary deliberately cannot say** is a schedule that depends on
-- *who* is filing rather than on *what period*: France staggers its dates by
-- the taxpayer's identification number and legal form, so `packs/fr/` declares
-- no deadline at all and `filing_deadline()` answers null for it. A null that
-- means "this pack does not know" is worth more than a date that is wrong for
-- most filers, and it is written up in docs/international.md.

create type filing_deadline_rule as enum (
  'day_of_month_after_period', 'last_day_of_month_after_period'
);

comment on type filing_deadline_rule is
  'How a filing date is worked out from the end of a period. Two values, closed: a fixed day of the month that follows, or the last day of it. A third needs a migration, and the first country that needs one will say so in a gap rather than in a regular expression.';

alter table tax_report_templates
  add column if not exists deadline_rule       filing_deadline_rule,
  add column if not exists deadline_day        smallint,
  add column if not exists deadline_plus_days  smallint,
  add column if not exists deadline_reference  text,
  add column if not exists deadline_source_key text;

comment on column tax_report_templates.deadline_rule is
  'How the filing date follows the end of the period. Null where the pack says nothing, which is the honest answer for a country whose schedule depends on the taxpayer.';
comment on column tax_report_templates.deadline_day is
  'Day of the month that follows the period. Filled exactly when the rule is day_of_month_after_period.';
comment on column tax_report_templates.deadline_plus_days is
  'Days added to the date the rule produces — the seven the United Kingdom grants for filing online, while the regulation still says the last day of the month.';
comment on column tax_report_templates.deadline_reference is
  'The text that sets the date, and the conditions on it: an extension that does not reach every filer is said here.';
comment on column tax_report_templates.deadline_source_key is
  'Key of the register entry that reference is in.';

alter table tax_report_templates
  add constraint tax_report_templates_deadline_shape check (
    case deadline_rule
      when 'day_of_month_after_period'      then deadline_day between 1 and 31
      when 'last_day_of_month_after_period' then deadline_day is null
      else deadline_day is null and deadline_plus_days is null
           and deadline_reference is null and deadline_source_key is null
    end
  );

-- ---------------------------------------------------------------------------
-- filing_deadline
--
-- The end of a period in, the day it is due out. Null where the pack says
-- nothing — a caller that wants a date has to face a country that does not
-- publish one as a rule.
-- ---------------------------------------------------------------------------

create or replace function filing_deadline(
  p_company_id  uuid,
  p_report_code text,
  p_period_end  date
)
returns date
language sql
stable
security invoker
as $$
  select case t.deadline_rule
           when 'day_of_month_after_period' then
             -- The day the pack names, in the month that follows. A day the
             -- month does not have lands on its last: `make_date` would raise,
             -- and the thirty-first of a thirty-day month is a date the
             -- administration reads as the end of it.
             least(
               (date_trunc('month', p_period_end + interval '1 month')
                + make_interval(days => t.deadline_day - 1))::date,
               (date_trunc('month', p_period_end + interval '2 month') - interval '1 day')::date
             )
           when 'last_day_of_month_after_period' then
             (date_trunc('month', p_period_end + interval '2 month') - interval '1 day')::date
           else null
         end
         + coalesce(t.deadline_plus_days, 0)
  from tax_report_templates t
  join companies c on c.id = p_company_id
  where t.code = p_report_code
    and t.country in (c.country, c.fiscal_country)
    and t.deadline_rule is not null
  limit 1;
$$;

comment on function filing_deadline(uuid, text, date) is
  'When a period closed on this date has to be declared, under the rule the pack carries. Null where the pack declares none — which is a country whose schedule depends on the filer, not a country without deadlines.';

revoke execute on function filing_deadline(uuid, text, date) from public, anon;
grant execute on function filing_deadline(uuid, text, date) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- upcoming_filings
--
-- What is due between two dates, for every declaration this company files,
-- with what has already been prepared or sent against it. The periods are
-- generated from the cadence the company recorded — the whole point of
-- `company_filing_periods` — so a company that files monthly and files a
-- recapitulative statement quarterly gets both, on their own rhythms.
-- ---------------------------------------------------------------------------

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
    select p.report_code, p.period::text as cadence
      from company_filing_periods p
     where p.company_id = p_company_id
    union
    select periodic_return_code(p_company_id),
           coalesce(
             (select p.period::text from company_filing_periods p
               where p.company_id = p_company_id
                 and p.report_code = periodic_return_code(p_company_id)),
             (select t.period_default::text from tax_report_templates t
               join companies c on c.id = p_company_id
              where t.code = periodic_return_code(p_company_id)
                and t.country in (c.country, c.fiscal_country)))
     where periodic_return_code(p_company_id) is not null
  ),
  periods as (
    select f.report_code,
           g.start::date as period_start,
           (g.start + case f.cadence
                        when 'month'   then interval '1 month'
                        when 'quarter' then interval '3 month'
                        else interval '1 year'
                      end - interval '1 day')::date as period_end
    from forms f
    cross join lateral generate_series(
      date_trunc(case f.cadence when 'month' then 'month'
                                when 'quarter' then 'quarter'
                                else 'year' end, p_from::timestamp),
      p_to::timestamp,
      case f.cadence when 'month' then interval '1 month'
                     when 'quarter' then interval '3 month'
                     else interval '1 year' end
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
  'What this company has to file between two dates: the periods its cadences produce, the day each is due where the pack says, and the declaration already prepared or sent against it. Read-only; sending the reminder is somebody else''s job, because a reminder needs a channel and somebody to operate it.';

revoke execute on function upcoming_filings(uuid, date, date) from public, anon;
grant execute on function upcoming_filings(uuid, date, date) to authenticated, service_role;
