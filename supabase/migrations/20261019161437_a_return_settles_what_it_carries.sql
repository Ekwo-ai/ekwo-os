-- Ekwo OS — a return settles what it carries, and knows the day it is due.
--
-- Found by loading a company that buys a service from abroad and declares
-- it on a second form (19 October 2026). Two things, both generic.
--
-- **1. A settlement clears the tax of its own form.** `filing_tax_movements()`
-- — what `settle_filing()` clears and what `lock_filed_period()` waits for —
-- summed every tax line of the period, whatever form it belonged to and
-- whether or not it belonged to any. A tax a pack books on a liability of its
-- own, declared on another return — a self-assessed tax on an imported
-- service, a withholding, a provincial tax beside a federal one — was carried
-- into the debt of the periodic return, which then owed more than its boxes
-- said. A tax on a blocked input booked to an expense account was moved off
-- the expense. And a tax due on collection, still waiting on its transition
-- account, was settled in the period of the invoice.
--
-- The rule now: a tax line of the period is on the filing's form when
--
--   (a) it names a box, and the form it was frozen with
--       (`entry_lines.report_code`, or `declaration_boxes_of()` on a line
--       restored from an archive older than the freeze) is the filing's — or
--       names none, which is the single return of a country that files one,
--       the reading `vat_return()` already makes; or
--   (b) it names no box, its tax writes a box of the filing's form through
--       another posting — the form prints the base and computes the tax from
--       it, as a rate of the base box — and it is not on the account the tax
--       waits on before it falls due.
--
-- A tax line that answers neither stays where it was posted, for the return
-- that declares it or for an entry somebody writes; the settlement leaves it
-- alone and so does the lock. No figure of any return moves: `vat_return()`
-- is not touched.
--
-- **2. A filing carries its due date.** `filing_deadline()` has computed the
-- day from the pack's rule since `20260917170000`, and `upcoming_filings()`
-- read it, but `prepare_filing()` never wrote it on the filing — so
-- `tax_filings.due_date` stayed empty, and with it the maturity of the debt a
-- settlement posts. `prepare_filing()` now writes it when it creates a filing
-- and fills it on a draft it refreshes, keeping a date somebody already set.
-- The filings already written get it once, below. A pack that names no rule,
-- or `depends_on_taxpayer`, leaves it empty, as `filing_deadline()` does.

-- ---------------------------------------------------------------------------
-- 1. filing_tax_movements — `20261005160900`, the tax lines of its own form
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
      cross join lateral declared_lines(f.company_id, f.period_start, f.period_end) l
      join entries e     on e.id = l.entry_id
      left join taxes t  on t.id = l.tax_id
     where e.state = 'posted'
       and l.tax_line
       and case
             -- (a) A line that names a box is on the form it was frozen with.
             when l.declaration_box is not null then
               coalesce(
                 case when l.declaration_boxes is not null then l.report_code
                      else (select d.report_code
                              from declaration_boxes_of(l.tax_id, l.declaration_box, l.tax_line) d)
                 end,
                 f.report_code) = f.report_code
             -- (b) A line that names none is on the form its tax reaches, off
             -- the account the tax waits on before it falls due.
             else l.account_id is distinct from t.cash_basis_transition_account_id
                  and exists (
                    select 1 from tax_postings tp
                     where tp.tax_id = l.tax_id
                       and tp.declaration_box is not null
                       and coalesce(tp.report_code, f.report_code) = f.report_code)
           end
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
  'The tax accounts a declared period moved on the filing''s own form and by how much, on the same window and the same tax-point rule the return read, net of what an earlier settlement of the same period already carried. A tax line is on the form when the box it names is on it (the form frozen on the line; none named is the single return), or when it names no box, its tax writes a box of the form through another posting, and it is not on the tax''s cash-basis transition account. A tax booked on a liability no box of the form carries stays for its own return. What settle_filing() clears — the whole period the first time, the difference on a corrective — what lock_filed_period() waits for, and what anybody can read before it does.';

revoke execute on function filing_tax_movements(uuid) from public, anon;
grant execute on function filing_tax_movements(uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 2. prepare_filing — `20260921145412`, with the due date of the period
-- ---------------------------------------------------------------------------

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

  -- The day the period is due, under the pack's rule: written with the
  -- filing, and filled on a draft that has none. A date already there stays,
  -- whoever set it.
  if not found then
    insert into tax_filings (company_id, report_code, period_start, period_end, due_date)
    values (p_company_id, v_code, p_from, p_to, filing_deadline(p_company_id, v_code, p_to))
    returning * into v_filing;
  else
    update tax_filings
       set state = 'draft',
           due_date = coalesce(due_date, filing_deadline(p_company_id, v_code, p_to))
     where id = v_filing.id
    returning * into v_filing;
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
  'Computes the declaration and keeps the answer, box by box and kind by kind, each figure at the unit the form is filed in (filing_rounding()), with the day it is due under the pack''s rule (filing_deadline()) — written when the filing is created, filled on a draft that has none, never overwritten. Called again on a draft it refreshes; on a declaration that has gone it refuses and says the word for what is needed instead — a corrective.';

revoke execute on function prepare_filing(uuid, date, date, text) from public, anon;
grant execute on function prepare_filing(uuid, date, date, text) to authenticated, service_role;

comment on column tax_filings.due_date is
  'The day the declaration of this period is due: filing_deadline() of its form and its last day, written by prepare_filing() and copied by supersede_filing(). Null where the pack names no rule for the form, or names depends_on_taxpayer. The maturity of the debt settle_filing() posts.';

-- ---------------------------------------------------------------------------
-- 3. The filings already written
--
-- Every filing with no date gets the one its pack's rule gives, whatever its
-- state: a declaration that has gone was due on that day all the same. The
-- `updated_at` trigger is lifted for the statement, so no filing is dated as
-- edited by a column it should always have had.
-- ---------------------------------------------------------------------------

alter table tax_filings disable trigger tax_filings_set_updated_at;

update tax_filings f
   set due_date = filing_deadline(f.company_id, f.report_code, f.period_end)
 where f.due_date is null
   and filing_deadline(f.company_id, f.report_code, f.period_end) is not null;

alter table tax_filings enable trigger tax_filings_set_updated_at;

-- Rule 6 of supabase/migrations/README.md.
revoke execute on all functions in schema public from public;
