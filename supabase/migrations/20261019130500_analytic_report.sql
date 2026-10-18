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
-- For each value of the axis that a posted ledger line of the period reaches:
-- what it brought in on the income accounts, what it cost on the expense
-- accounts, and the difference, in the company's currency. One more row, with
-- no value, holds the part of the income statement no share of this axis
-- reaches — a line with no split, or the rest of a split under 100 %. So the
-- rows add up, to the cent, to the result of the period: the same posted
-- entries the income statement reads, with the closing entry left out as it
-- leaves it out. It reads the ledger and nothing else, as `trial_balance()`
-- does; the document split is not read here.
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
  analytic_value_id uuid,
  code              text,
  name              text,
  parent_id         uuid,
  active            boolean,
  income            numeric,
  expense           numeric,
  result            numeric
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
  with lines as (
    select l.id, a.internal_group as grp, l.balance
      from entry_lines l
      join entries e on e.id = l.entry_id
      join accounts a on a.id = l.account_id
     where l.company_id = p_company_id
       and e.state = 'posted'
       and e.kind <> 'closing'
       and e.entry_date between p_from and p_to
       and a.internal_group in ('income', 'expense')
  ),
  shares as (
    select x.analytic_value_id as value, ln.grp, x.amount
      from lines ln
      join entry_line_analytics x on x.entry_line_id = ln.id
      join analytic_values v on v.id = x.analytic_value_id
     where v.axis_id = p_axis_id
  ),
  per_value as (
    -- A balance is debit minus credit: income is its opposite, expense itself.
    select s.value,
           coalesce(-sum(s.amount) filter (where s.grp = 'income'), 0)  as income,
           coalesce(sum(s.amount)  filter (where s.grp = 'expense'), 0) as expense
      from shares s
     group by s.value
  ),
  whole as (
    select coalesce(-sum(ln.balance) filter (where ln.grp = 'income'), 0)  as income,
           coalesce(sum(ln.balance)  filter (where ln.grp = 'expense'), 0) as expense
      from lines ln
  )
  select v.id, v.code, v.name, v.parent_id, v.active,
         pv.income, pv.expense, pv.income - pv.expense
    from per_value pv
    join analytic_values v on v.id = pv.value
  union all
  select null::uuid, null::text, null::text, null::uuid, null::boolean,
         w.income - coalesce((select sum(pv.income) from per_value pv), 0),
         w.expense - coalesce((select sum(pv.expense) from per_value pv), 0),
         (w.income - w.expense)
           - coalesce((select sum(pv.income - pv.expense) from per_value pv), 0)
    from whole w
   order by 2 nulls last;
end;
$$;

comment on function analytic_report(uuid, uuid, date, date) is
  'The result of each value of an analytic axis over a period, read from the posted ledger: income, expense and result per value a share of the axis reaches, in the company''s currency, and one row with no value for the part of the income statement no share of the axis reaches. The rows add up to the result of the period, closing entry left out. Refuses unknown_company, not_allowed (entries.read and settings.read), invalid_period and unknown_analytic_axis.';

revoke execute on function analytic_report(uuid, uuid, date, date) from public, anon;
grant execute on function analytic_report(uuid, uuid, date, date) to authenticated, service_role;
