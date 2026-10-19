-- Ekwo OS — the result of each analytic value, read from the ledger.
--
-- `20261019130000` puts the analytic split on the ledger line, copied there
-- from the document line at posting or keyed on a line no document wrote
-- (decision 0075). This is the reading of it. `product_report()` answers
-- "what did this offer bring in and cost", from the invoice lines that name
-- a product; `analytic_report(company, axis, from, to)` answers "what did this
-- activity make", from the whole income statement — salaries, rent and
-- depreciation included, which name no product and never will.

-- ---------------------------------------------------------------------------
-- analytic_report: the result of each value of an axis, from the ledger
--
-- One row per value of the axis that a posted ledger line of the period
-- reaches, itself or through a value below it (`row_kind` = `value`): what it
-- brought in on the income accounts, what it cost on the expense accounts,
-- and the difference, in the company's currency. A value that has others
-- below it (`parent_id`) holds the subtotal of all of them plus its own
-- amount; its own amount alone is in the `direct_` columns, which are the
-- figures that add up. `level` is the depth under the top of the axis, 0 for
-- a value with no parent.
--
-- One row with no value (`unassigned`) holds the part of the income
-- statement no share of this axis reaches — a line with no split, or the rest
-- of a split under 100 %. One more (`total`) holds the whole income statement
-- of the period. So the `direct_` columns of the values and the unassigned
-- row add up, to the cent, to the total, and so do the values with no parent
-- and the unassigned row: the same posted entries the income statement reads,
-- with the closing entry left out as it leaves it out.
--
-- `fixed_assets` is the same reading of the fixed-asset accounts (account
-- type `asset_fixed`), whose lines may carry a split too: their net movement
-- over the period, debit less credit — what was acquired, less what was
-- depreciated or disposed of on those accounts — from the ordinary entries
-- alone, since an opening or a closing moves no asset. It is beside the
-- result, never in it.
--
-- It reads the ledger and nothing else, as `trial_balance()` does; the
-- document split is not read here.
--
-- Security invoker: the caller reads the lines `entries.read` lets them read
-- and the values `settings.read` lets them read. Both are asked for by name
-- first, because a value the caller may not see would otherwise move its
-- share into the unassigned row without a word.
-- ---------------------------------------------------------------------------

create or replace function analytic_report(
  p_company_id uuid,
  p_axis_id    uuid,
  p_from       date,
  p_to         date
)
returns table (
  row_kind            text,
  analytic_value_id   uuid,
  code                text,
  name                text,
  parent_id           uuid,
  level               integer,
  active              boolean,
  income              numeric,
  expense             numeric,
  result              numeric,
  fixed_assets        numeric,
  direct_income       numeric,
  direct_expense      numeric,
  direct_result       numeric,
  direct_fixed_assets numeric
)
language plpgsql
stable
security invoker
as $$
#variable_conflict use_column
begin
  if not exists (select 1 from companies c where c.id = p_company_id) then
    raise exception 'unknown_company: %', p_company_id;
  end if;

  if not is_installer()
     and not (coalesce(has_capability(p_company_id, 'entries.read'), false)
              and coalesce(has_capability(p_company_id, 'settings.read'), false)) then
    raise exception 'not_allowed: reading the result by analytic value needs entries.read and settings.read'
      using errcode = '42501';
  end if;

  if p_from is null or p_to is null or p_from > p_to then
    raise exception 'invalid_period: a period runs from a day to a later one, not from % to %',
      coalesce(p_from::text, 'null'), coalesce(p_to::text, 'null')
      using errcode = '22023';
  end if;

  if not exists (select 1 from analytic_axes x where x.id = p_axis_id and x.company_id = p_company_id) then
    raise exception 'unknown_analytic_axis: company % has no analytic axis %', p_company_id, p_axis_id
      using errcode = '22023';
  end if;

  return query
  with recursive lines as (
    select l.id,
           case when a.internal_group in ('income', 'expense') then a.internal_group else 'fixed_assets' end as grp,
           l.balance
      from entry_lines l
      join entries e on e.id = l.entry_id
      join accounts a on a.id = l.account_id
     where l.company_id = p_company_id
       and e.state = 'posted'
       and e.entry_date between p_from and p_to
       and ((a.internal_group in ('income', 'expense') and e.kind <> 'closing')
            or (a.account_type = 'asset_fixed' and e.kind = 'normal'))
  ),
  shares as (
    select x.analytic_value_id as value, ln.grp, x.amount
      from lines ln
      join entry_line_analytics x on x.entry_line_id = ln.id
      join analytic_values v on v.id = x.analytic_value_id
     where v.axis_id = p_axis_id
  ),
  direct as (
    -- A balance is debit minus credit: income is its opposite, expense and a
    -- fixed asset are themselves.
    select s.value,
           coalesce(-sum(s.amount) filter (where s.grp = 'income'), 0)      as income,
           coalesce(sum(s.amount)  filter (where s.grp = 'expense'), 0)     as expense,
           coalesce(sum(s.amount)  filter (where s.grp = 'fixed_assets'), 0) as fixed_assets
      from shares s
     group by s.value
  ),
  -- Every value of the axis, with the path of codes from the top of the axis
  -- that orders it, and its depth.
  tree as (
    select v.id, v.parent_id, 0 as level, array[v.code] as path
      from analytic_values v
     where v.axis_id = p_axis_id and v.company_id = p_company_id and v.parent_id is null
    union all
    select v.id, v.parent_id, t.level + 1, t.path || v.code
      from analytic_values v
      join tree t on t.id = v.parent_id
     where v.axis_id = p_axis_id and v.company_id = p_company_id
       and t.level < 32
  ),
  -- Each value, and every value below it, itself included.
  below as (
    select t.id as top, t.id as value from tree t
    union all
    select b.top, v.id
      from below b
      join analytic_values v on v.parent_id = b.value
     where v.axis_id = p_axis_id and v.company_id = p_company_id
  ),
  subtotal as (
    select b.top as value,
           sum(d.income) as income, sum(d.expense) as expense, sum(d.fixed_assets) as fixed_assets
      from below b
      join direct d on d.value = b.value
     group by b.top
  ),
  whole as (
    select coalesce(-sum(ln.balance) filter (where ln.grp = 'income'), 0)      as income,
           coalesce(sum(ln.balance)  filter (where ln.grp = 'expense'), 0)     as expense,
           coalesce(sum(ln.balance)  filter (where ln.grp = 'fixed_assets'), 0) as fixed_assets
      from lines ln
  ),
  assigned as (
    select coalesce(sum(d.income), 0) as income, coalesce(sum(d.expense), 0) as expense,
           coalesce(sum(d.fixed_assets), 0) as fixed_assets
      from direct d
  ),
  report_rows as (
    select 'value'::text as row_kind, v.id, v.code, v.name, v.parent_id, t.level, v.active,
           st.income, st.expense, st.income - st.expense as result, st.fixed_assets,
           coalesce(d.income, 0) as d_income, coalesce(d.expense, 0) as d_expense,
           coalesce(d.income, 0) - coalesce(d.expense, 0) as d_result, coalesce(d.fixed_assets, 0) as d_fixed,
           1 as rank, t.path
      from subtotal st
      join analytic_values v on v.id = st.value
      join tree t on t.id = v.id
      left join direct d on d.value = v.id
    union all
    select 'unassigned', null, null, null, null, null, null,
           w.income - a.income, w.expense - a.expense,
           (w.income - w.expense) - (a.income - a.expense), w.fixed_assets - a.fixed_assets,
           w.income - a.income, w.expense - a.expense,
           (w.income - w.expense) - (a.income - a.expense), w.fixed_assets - a.fixed_assets,
           2, null
      from whole w, assigned a
    union all
    select 'total', null, null, null, null, null, null,
           w.income, w.expense, w.income - w.expense, w.fixed_assets,
           w.income, w.expense, w.income - w.expense, w.fixed_assets,
           3, null
      from whole w
  )
  select r.row_kind, r.id, r.code, r.name, r.parent_id, r.level, r.active,
         r.income, r.expense, r.result, r.fixed_assets,
         r.d_income, r.d_expense, r.d_result, r.d_fixed
    from report_rows r
   order by r.rank, r.path;
end;
$$;

comment on function analytic_report(uuid, uuid, date, date) is
  'The result of each value of an analytic axis over a period, read from the posted ledger, in the company''s currency. One row per value a share of the axis reaches, itself or below it (row_kind value), in the order of the tree, with level its depth: income, expense, result and fixed_assets (the net movement of the fixed-asset accounts, ordinary entries only) of the value and every value below it; the direct_ columns hold its own amount alone. Then row_kind unassigned, the part no share of the axis reaches, and total, the whole income statement of the period and the whole movement of the fixed assets. The direct_ columns of the values and the unassigned row add up to the total, closing entry left out. Refuses unknown_company, not_allowed (entries.read and settings.read), invalid_period and unknown_analytic_axis.';

revoke execute on function analytic_report(uuid, uuid, date, date) from public, anon;
grant execute on function analytic_report(uuid, uuid, date, date) to authenticated, service_role;
