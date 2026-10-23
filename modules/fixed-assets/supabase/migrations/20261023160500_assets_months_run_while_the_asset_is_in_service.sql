-- Ekwo OS, module assets — a monthly schedule runs while the asset is in
-- service, and a late addition books its own entry (issue #143).
--
-- `generate_schedule()` cuts a schedule into annuities that follow the
-- financial years, and prorates the first one from the day the asset entered
-- service. `split_into_months()` then spread each annuity evenly over every
-- month of its period — including the months of the first year before the
-- asset existed, and the months of the last year after its life had ended.
-- An asset bought on 1 June over twelve months was depreciated from January,
-- in twenty-four periods instead of twelve.
--
-- Two corrections:
--
-- 1. **Each annuity is spread over the months the asset is in service in.**
--    A month is eligible from the month the asset entered service (the
--    first sub-period starts on that day) to the month its life ends, which
--    is the day before the date of entry into service plus its duration. The
--    annuity itself is unchanged — its proration stays the one the country's
--    rule computed on the financial year — only its spread moves, and the
--    last eligible month takes the rounding remainder. The end of life bounds
--    a straight line only: a declining balance ends where its own rule ends
--    it, and an annuity that would fall entirely outside the interval keeps
--    the months of its whole period rather than disappear.
--
-- 2. **A period already booked is supplemented, not booked twice.** An asset
--    added after a period was booked for the others (bought in January,
--    entered in March) carries an unbooked line for that period.
--    `run_depreciation()` tagged every entry `depreciation:<period end>`, and
--    the unique tag of a module entry refused the second one (SQLSTATE 23505).
--    The first entry of a period keeps that tag; a later one for the same
--    period is tagged `depreciation:<period end>:<n>`, its rank among the
--    entries of that period. A second run still books nothing, because the
--    lines it booked are marked.
--
-- Schedules already generated are not rewritten: a line that is booked is
-- what the ledger says happened. A schedule with nothing booked is regenerated
-- by `generate_schedule()` with the corrected spread.

create or replace function fixed_assets.split_into_months(p_asset_id uuid)
returns integer
language plpgsql
as $$
declare
  v_line     fixed_assets.depreciation_lines%rowtype;
  v_asset    fixed_assets.fixed_assets%rowtype;
  -- The interval the asset is depreciated over: from the day it entered
  -- service to the last day of its life.
  v_first    date;
  v_last     date;
  v_from     date;
  v_to       date;
  v_months   integer;
  v_start    date;
  v_end      date;
  v_share    numeric;
  v_done     numeric;
  v_accum    numeric := 0;
  v_round    public.money_rounding;
  v_sequence integer := 0;
  v_index    integer;
  v_new      jsonb := '[]'::jsonb;
begin
  select * into v_asset from fixed_assets.fixed_assets where id = p_asset_id;
  v_round := public.rounding_of(v_asset.company_id);
  v_first := coalesce(v_asset.in_service_date, v_asset.acquisition_date);
  v_last  := (v_first + make_interval(months => v_asset.duration_months) - interval '1 day')::date;

  for v_line in
    select * from fixed_assets.depreciation_lines where asset_id = p_asset_id order by sequence
  loop
    v_from := greatest(v_line.period_start, v_first);
    v_to := v_line.period_end;
    if v_asset.method = 'straight_line' then
      v_to := least(v_to, v_last);
    end if;
    if v_from > v_to then
      v_from := v_line.period_start;
      v_to := v_line.period_end;
    end if;

    v_months := fixed_assets.months_inclusive(v_from, v_to);
    v_done := 0;
    for v_index in 1 .. v_months loop
      v_start := (date_trunc('month', v_from) + make_interval(months => v_index - 1))::date;
      -- A month ends at its end, so the depreciation of every asset for one
      -- month is one entry; only the end of the annuity's own period bounds it.
      v_end := least((v_start + interval '1 month' - interval '1 day')::date, v_line.period_end);
      if v_index = 1 then v_start := v_from; end if;

      v_share := case when v_index = v_months
                      then v_line.amount - v_done
                      else public.round_amount(v_line.amount / v_months, v_round) end;
      v_done := v_done + v_share;
      if v_share = 0 then continue; end if;

      v_accum := v_accum + v_share;
      v_sequence := v_sequence + 1;
      v_new := v_new || jsonb_build_object(
        'sequence', v_sequence, 'period_start', v_start, 'period_end', v_end,
        'amount', v_share, 'accumulated', v_accum,
        'net_book_value', v_asset.cost - v_accum);
    end loop;
  end loop;

  delete from fixed_assets.depreciation_lines where asset_id = p_asset_id;
  insert into fixed_assets.depreciation_lines
    (asset_id, company_id, sequence, period_start, period_end, amount, accumulated, net_book_value)
  select p_asset_id, v_asset.company_id,
         (row ->> 'sequence')::integer, (row ->> 'period_start')::date, (row ->> 'period_end')::date,
         (row ->> 'amount')::numeric, (row ->> 'accumulated')::numeric, (row ->> 'net_book_value')::numeric
    from jsonb_array_elements(v_new) as row;

  return v_sequence;
end;
$$;

comment on function fixed_assets.split_into_months(uuid) is
  'Splits each annuity of a schedule into months, over the months the asset is in service in: from the month it entered service and, for a straight line, to the month its life ends. The last eligible month of each annuity takes the rounding remainder.';

create or replace function fixed_assets.run_depreciation(p_company_id uuid, p_period_end date)
returns jsonb
language plpgsql
as $$
declare
  v_period   date;
  v_lines    jsonb;
  v_entry    uuid;
  v_ref      text;
  v_booked   integer;
  v_total    numeric(16, 2);
  v_posted   jsonb := '[]'::jsonb;
begin
  if not public.module_is_enabled(p_company_id, 'assets') then
    raise exception 'module_not_enabled: the fixed assets module (assets) is not enabled on this company'
      using errcode = '55006';
  end if;

  for v_period in
    select distinct l.period_end
      from fixed_assets.depreciation_lines l
      join fixed_assets.fixed_assets a on a.id = l.asset_id
     where l.company_id = p_company_id
       and l.posted_at is null
       and l.period_end <= p_period_end
       and a.state <> 'disposed'
       and l.amount > 0
     order by l.period_end
  loop
    -- One debit and one credit per asset, named by the asset. An entry that
    -- aggregates by account is shorter and tells whoever reads the ledger in
    -- three years nothing about which asset moved.
    select jsonb_agg(line order by line_order), sum(amount)
      into v_lines, v_total
      from (
        select jsonb_build_object(
                 'account_id', a.expense_account_id,
                 'label', a.code || ' — ' || a.name,
                 'debit', l.amount) as line,
               (a.code || ':1') as line_order, l.amount
          from fixed_assets.depreciation_lines l
          join fixed_assets.fixed_assets a on a.id = l.asset_id
         where l.company_id = p_company_id and l.period_end = v_period
           and l.posted_at is null and a.state <> 'disposed' and l.amount > 0
        union all
        select jsonb_build_object(
                 'account_id', a.depreciation_account_id,
                 'label', a.code || ' — ' || a.name,
                 'credit', l.amount),
               (a.code || ':2'), 0
          from fixed_assets.depreciation_lines l
          join fixed_assets.fixed_assets a on a.id = l.asset_id
         where l.company_id = p_company_id and l.period_end = v_period
           and l.posted_at is null and a.state <> 'disposed' and l.amount > 0
      ) parts;

    if v_lines is null then
      continue;
    end if;

    -- The first entry of a period is `depreciation:<period end>`. An asset
    -- added after that period was booked supplements it with an entry of its
    -- own, ranked after the ones the period already has.
    v_ref := 'depreciation:' || v_period::text;
    select count(*)::integer into v_booked
      from public.entries e
     where e.company_id = p_company_id
       and e.module_code = 'assets'
       and (e.module_ref = v_ref or e.module_ref like v_ref || ':%');
    if v_booked > 0 then
      v_ref := v_ref || ':' || (v_booked + 1)::text;
    end if;

    v_entry := public.post_module_entry(
      p_company_id, 'assets', v_ref, v_period,
      'Depreciation ' || v_period::text, v_lines);

    update fixed_assets.depreciation_lines l
       set entry_id = v_entry, posted_at = now()
      from fixed_assets.fixed_assets a
     where a.id = l.asset_id
       and l.company_id = p_company_id
       and l.period_end = v_period
       and l.posted_at is null
       and a.state <> 'disposed'
       and l.amount > 0;

    v_posted := v_posted || jsonb_build_object(
      'period_end', v_period,
      'entry_id', v_entry,
      'amount', to_char(v_total, 'FM9999999999999990.00'));
  end loop;

  -- An asset whose whole schedule is booked says so, so a register does not
  -- have to work it out from the lines every time it is read.
  update fixed_assets.fixed_assets a
     set state = 'fully_depreciated'
   where a.company_id = p_company_id
     and a.state = 'active'
     and not exists (select 1 from fixed_assets.depreciation_lines l
                      where l.asset_id = a.id and l.posted_at is null);

  return jsonb_build_object('company_id', p_company_id, 'entries', v_posted);
end;
$$;

comment on function fixed_assets.run_depreciation(uuid, date) is
  'Books every planned period that ends on or before a date, one entry per period, through post_module_entry(). Idempotent: a period already booked is skipped. An asset added after its period was booked supplements it with an entry tagged depreciation:<period end>:<n>. A closed financial year refuses the posting, because post_entry() asserts the period is open.';
