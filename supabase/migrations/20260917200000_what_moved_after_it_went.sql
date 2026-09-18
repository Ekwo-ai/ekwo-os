-- Ekwo OS — what moved after it went.
--
-- A declaration leaves, and the period it covers stays open. That is not a
-- defect: a supplier invoice arrives late, an accountant adjusts an entry, a
-- correction lands. Every one of those is legitimate, and refusing them would
-- be refusing bookkeeping. **What is not legitimate is that nobody is told.**
--
-- D1 froze the figures and gave `filing_drift()` — box by box, what the ledger
-- says now against what was sent. This file adds the two things that were
-- missing around it:
--
--   filings_touched_since()  which declarations the ledger disturbed after
--                            they went, how many entries, and how many of
--                            their figures moved
--   lock_filed_period()      a company that wants the period shut says so
--                            once, after the books for it are clear
--
-- and it makes the corrective settle **the difference**, which is the part D4
-- left named and undone.
--
-- On the lock: the database does not propose anything, it answers. The
-- proposal belongs to whatever is at the keyboard — the CLI, an agent, a
-- person — and what the schema owes it is a way of saying yes that cannot be
-- got wrong. So the lock is its own function, it moves forward only, and it
-- refuses while the period still has books to clear. A company that never
-- calls it keeps an open period and a reading that says what fell into it.
--
-- What is deliberately not here: **what a country does with a correction.**
-- Some want a full replacement return, some an adjustment carried on the next
-- period, most with a threshold below which nothing is filed at all. That is
-- pack data, nobody has read the texts yet, and a mechanism invented now would
-- be one country's habit given to five others. `supersede_filing()` does the
-- one thing that is true everywhere: what was sent stays sent, and the new
-- declaration points at it.

-- ---------------------------------------------------------------------------
-- filing_tax_movements, net of what an earlier settlement already carried
--
-- A corrective covers the same period as the declaration it replaces, and that
-- period's tax accounts were already cleared once. Left as it was, this would
-- hand `settle_filing()` the whole period again and book the debt twice.
--
-- So the movements of the window are netted against the settlement entries of
-- the declarations that came before it on the same period — restricted to the
-- accounts the window itself moved, which is what leaves out their
-- counterpart line on the debt account. What comes back is exactly what has
-- not been settled yet: nothing at all when nothing moved, and the difference
-- when something did.
-- ---------------------------------------------------------------------------

create or replace function filing_tax_movements(p_filing_id uuid)
returns table (account_id uuid, balance numeric)
language sql
stable
security invoker
as $$
  with f as (
    select * from tax_filings where id = p_filing_id
  ),
  moved as (
    select l.account_id, sum(l.balance) as balance
      from f
      join entry_lines l on l.company_id = f.company_id
      join entries e     on e.id = l.entry_id
     where e.state = 'posted'
       and l.tax_line
       and coalesce(l.tax_point_date, e.entry_date) between f.period_start and f.period_end
     group by l.account_id
  ),
  already as (
    select l.account_id, sum(l.balance) as balance
      from f
      join tax_filings p
        on p.company_id = f.company_id
       and p.report_code = f.report_code
       and p.period_start = f.period_start
       and p.period_end = f.period_end
       and p.id <> f.id
       and p.settlement_entry_id is not null
      join entry_lines l on l.entry_id = p.settlement_entry_id
      join moved m       on m.account_id = l.account_id
     group by l.account_id
  )
  select m.account_id,
         round_amount(m.balance + coalesce(a.balance, 0), rounding_of(f.company_id))
    from f, moved m
    left join already a on a.account_id = m.account_id
   where round_amount(m.balance + coalesce(a.balance, 0), rounding_of(f.company_id)) <> 0;
$$;

comment on function filing_tax_movements(uuid) is
  'The tax accounts a declared period moved and by how much, on the same window and the same tax-point rule the return read, net of what an earlier settlement of the same period already carried. What settle_filing() clears — the whole period the first time, the difference on a corrective — and what anybody can read before it does.';

revoke execute on function filing_tax_movements(uuid) from public, anon;
grant execute on function filing_tax_movements(uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- filings_touched_since
--
-- The reading the whole freeze was for. A declaration is listed when the
-- ledger moved inside its period **after** it was filed — not when the figures
-- happen to differ, which is `filing_drift()`'s question, because an entry
-- that nets to nothing in every box is still an entry somebody posted into a
-- period that had gone.
--
-- What counts as moving it is a line that names a box, which is the same test
-- the tax lock uses to decide what it protects. Two readings of "an entry
-- that concerns the declaration" would eventually disagree, and a payroll
-- entry landing in a declared quarter is not news. It also leaves out the
-- settlement of the declaration itself, which is posted at the end of the
-- period and after the filing, and is the opposite of a disturbance.
--
-- Read-only, and it names nothing to do: whether a change is a corrective to
-- file, an entry in the wrong period, or a legitimate movement that changes no
-- figure, is a judgement, and the database's job is to stop it being invisible.
-- ---------------------------------------------------------------------------

create or replace function filings_touched_since(
  p_company_id uuid,
  p_from       date default null,
  p_to         date default null
)
returns table (
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
  select f.id, f.report_code, f.period_start, f.period_end, f.state, f.filed_at,
         t.entries::integer, t.last_entry_at,
         (select count(*) from filing_drift(f.id))::integer
    from tax_filings f
    cross join lateral (
      select count(distinct e.id) as entries, max(e.posted_at) as last_entry_at
        from entry_lines l
        join entries e on e.id = l.entry_id
       where l.company_id = f.company_id
         and e.state = 'posted'
         and e.posted_at > f.filed_at
         and l.declaration_box is not null
         and coalesce(l.tax_point_date, e.entry_date) between f.period_start and f.period_end
    ) t
   where f.company_id = p_company_id
     and f.filed_at is not null
     and f.state <> 'superseded'
     and (p_from is null or f.period_end >= p_from)
     and (p_to is null or f.period_start <= p_to)
     and t.entries > 0
   order by f.period_start, f.report_code;
$$;

comment on function filings_touched_since(uuid, date, date) is
  'Declarations that have gone and whose period the ledger moved afterwards: how many entries carrying a declaration box landed in it, when the last one did, and how many of the filed figures now disagree. An entry that changes no figure is still listed — it was posted into a period that had been declared, and that is the fact being reported.';

revoke execute on function filings_touched_since(uuid, date, date) from public, anon;
grant execute on function filings_touched_since(uuid, date, date) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- lock_filed_period
--
-- The other half of "signalled, not refused": a company that does want the
-- period shut says so, once, and the schema makes saying it safe.
--
-- It is a function of its own and not a flag on `file_filing()`, and the test
-- is what settled that. The tax lock is checked by `post_entry()` for every
-- entry it posts, whatever the entry names — so locking at the moment of
-- filing locks the declaration's own settlement out of its period, and the
-- books can never be cleared. The order that works is the order the work
-- actually has: file, hear back, settle, then shut.
--
-- So this refuses to shut a period whose settlement is still possible and not
-- done, and says which. It moves the lock forward only: a company filing an
-- old period late did not ask to reopen everything it had already closed.
-- ---------------------------------------------------------------------------

create or replace function lock_filed_period(p_filing_id uuid)
returns date
language plpgsql
volatile
security invoker
as $$
declare
  v_filing tax_filings;
  v_lock   date;
begin
  select * into v_filing from tax_filings f where f.id = p_filing_id;
  if not found then
    raise exception 'not_found: filing %', p_filing_id using errcode = 'no_data_found';
  end if;
  if v_filing.state in ('draft', 'ready') then
    raise exception 'filing_not_sent: a period is shut behind a declaration that has gone, and this one is %',
      v_filing.state;
  end if;
  if v_filing.state = 'superseded' then
    raise exception 'filing_superseded: % was replaced, and it is the declaration that replaced it that shuts the period',
      p_filing_id;
  end if;

  if v_filing.settlement_entry_id is null
     and exists (select 1 from filing_tax_movements(p_filing_id)) then
    raise exception 'settle_first: this period still has tax accounts to clear, and the lock would refuse the entry that clears them';
  end if;

  update companies
     set tax_lock_date = v_filing.period_end
   where id = v_filing.company_id
     and (tax_lock_date is null or tax_lock_date < v_filing.period_end);

  select c.tax_lock_date into v_lock from companies c where c.id = v_filing.company_id;
  return v_lock;
end;
$$;

comment on function lock_filed_period(uuid) is
  'Carries the tax lock to the end of the period a declaration covers, so nothing more falls into it. Forward only, refused on a declaration that has not gone, and refused while the period still has tax accounts to clear — because the lock would then refuse the very entry that clears them. Returns the lock date the company ends up with. Nobody is obliged to call it: a period left open is a period filings_touched_since() reports on.';

revoke execute on function lock_filed_period(uuid) from public, anon;
grant execute on function lock_filed_period(uuid) to authenticated, service_role;
