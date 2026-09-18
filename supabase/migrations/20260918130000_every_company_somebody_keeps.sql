-- Ekwo OS — every company somebody keeps, read at once.
--
-- `upcoming_filings()` and `filings_touched_since()` take a company. Several
-- companies inside one instance is the normal case — a firm with its clients —
-- and a firm that keeps forty of them does not ask "what is due" forty times.
-- It asks once: *all the companies I keep, what falls due in the fortnight,
-- and what moved after it went.*
--
-- **There is no firm in this file, and no list of clients.** The portfolio is
-- not an object: it is what the caller may read. Both functions walk the
-- companies on which the caller holds `filings.read`, and that one sentence is
-- the whole model — an accountant of forty companies gets forty, the person
-- who runs one of them gets one, and a group that keeps three of its own gets
-- three without anybody having been called a firm.
--
-- **Both are `security invoker`.** They read nothing a caller could not have
-- read by asking company by company: row level security on `tax_filings`, on
-- `company_filing_periods` and on the ledger does the sorting, as it does for
-- the two functions these are built on. The one thing the policies do not
-- settle is *which companies to walk* — `companies` is readable by a member
-- who has had `filings.read` taken away, and by the administrator of the
-- instance, who creates companies and keeps none of their books. Walking those
-- would list a calendar with every state empty, which reads as "nothing has
-- been prepared" and means "you may not know". So the list is filtered on the
-- capability, in the open, and the test takes the capability away to see the
-- company leave.
--
-- **Silence is not an output.** A reading that leaves a company out when it
-- has nothing to say cannot be told from a reading that never looked at it, and
-- over forty companies that is the difference that matters. So every company
-- of the portfolio is in every answer, and a row with no date says why:
--
--   no_deadline_rule  the pack names no day for this form — a country whose
--                     schedule depends on who is filing — and the period is
--                     listed without one rather than dropped
--   nothing_due       the company files, and nothing of it falls in the window
--   no_form           no cadence recorded and no periodic return the
--                     installation could name for its fiscal country
--
-- **The window is on the day a return is due**, which is the question a
-- portfolio is asked, and not on the period as `upcoming_filings()` reads it.
-- A period whose pack names no day has no date to test, so it is listed while
-- the month that follows it overlaps the window — the only place either rule
-- of the closed vocabulary ever puts a date.

-- ---------------------------------------------------------------------------
-- portfolio_upcoming_filings
-- ---------------------------------------------------------------------------

create or replace function portfolio_upcoming_filings(
  p_from date,
  p_to   date
)
returns table (
  company_id   uuid,
  company_name text,
  report_code  text,
  period_start date,
  period_end   date,
  due_date     date,
  state        tax_filing_state,
  filing_id    uuid,
  reason       text
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
         end
    from portfolio p
    left join listed l on l.company_id = p.id
   order by l.due_date nulls last, l.period_end nulls last, p.name, p.id, l.report_code;
$$;

comment on function portfolio_upcoming_filings(date, date) is
  'What falls due between two dates in every company the caller holds filings.read on, and in no other: the periods upcoming_filings() produces, kept when the day they are due is in the window. Every company of the portfolio is in the answer at least once, and a row without a date says why in `reason` — no_deadline_rule where the pack names no day for the form, nothing_due where nothing of the company falls in the window, no_form where the installation carries no return for it. Invoker: it reads what the caller could have read company by company.';

revoke execute on function portfolio_upcoming_filings(date, date) from public, anon;
grant execute on function portfolio_upcoming_filings(date, date) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- portfolio_filings_touched_since
--
-- `filed` is how many declarations of the company had gone and were looked
-- at, so that a company with no row of disturbance still says what was
-- examined: six returns and none moved is not the same news as no return.
-- ---------------------------------------------------------------------------

create or replace function portfolio_filings_touched_since(
  p_from date default null,
  p_to   date default null
)
returns table (
  company_id    uuid,
  company_name  text,
  filed         integer,
  filing_id     uuid,
  report_code   text,
  period_start  date,
  period_end    date,
  state         tax_filing_state,
  filed_at      timestamptz,
  entries       integer,
  last_entry_at timestamptz,
  boxes_moved   integer
)
language sql
stable
security invoker
as $$
  with portfolio as (
    select c.id, c.name
      from companies c
     where has_capability(c.id, 'filings.read')
  )
  select p.id,
         p.name,
         (select count(*)::integer
            from tax_filings f
           where f.company_id = p.id
             and f.filed_at is not null
             and f.state <> 'superseded'
             and (p_from is null or f.period_end >= p_from)
             and (p_to is null or f.period_start <= p_to)),
         t.filing_id, t.report_code, t.period_start, t.period_end, t.state,
         t.filed_at, t.entries, t.last_entry_at, t.boxes_moved
    from portfolio p
    left join lateral filings_touched_since(p.id, p_from, p_to) t on true
   order by t.last_entry_at desc nulls last, p.name, p.id, t.period_start, t.report_code;
$$;

comment on function portfolio_filings_touched_since(date, date) is
  'Declarations that have gone and whose period the ledger moved afterwards, in every company the caller holds filings.read on, and in no other — filings_touched_since() with the company named, the latest disturbance first. Every company of the portfolio is in the answer at least once: one that was not disturbed is a row with no filing, and `filed` says how many of its declarations were looked at. Invoker: it reads what the caller could have read company by company.';

revoke execute on function portfolio_filings_touched_since(date, date) from public, anon;
grant execute on function portfolio_filings_touched_since(date, date) to authenticated, service_role;
