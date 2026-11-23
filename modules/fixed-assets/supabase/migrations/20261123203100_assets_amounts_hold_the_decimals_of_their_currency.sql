-- Ekwo — the `assets` module: its amounts hold the decimals of their
-- currency.
--
-- The socle made its money columns bare `numeric` in
-- `20261123203000_an_amount_holds_the_decimals_of_its_currency.sql`: the
-- decimals of an amount are decided by `ekwo.round_amount()`, which this module
-- already calls for every figure it computes
-- (`20260914122100_assets_round_at_the_currency.sql`), and no longer cut to two
-- by the column. The module's own columns follow, for the same reason: a
-- schedule in a three-decimal currency was rounded to the thousandth by the
-- engine, then to the hundredth by `numeric(16, 2)`.
--
-- No view, trigger or generated column reads these columns, so the change is
-- the type alone, and rewrites nothing on disk.
--
-- `run_depreciation()` held its total in a `numeric(16, 2)` local and wrote it
-- with a two-decimal mask; it now holds a bare `numeric` and writes the total
-- with `ekwo.amount_text_format()`, the mask of the company's currency. The
-- function is otherwise unchanged, and `create or replace` keeps its grants and
-- its comment.

alter table fixed_assets.fixed_assets
  alter column cost           type numeric,
  alter column residual_value type numeric;

alter table fixed_assets.depreciation_lines
  alter column amount         type numeric,
  alter column accumulated    type numeric,
  alter column net_book_value type numeric;

alter table fixed_assets.disposals
  alter column cost           type numeric,
  alter column accumulated    type numeric,
  alter column net_book_value type numeric,
  alter column proceeds       type numeric,
  alter column result         type numeric;

create or replace function fixed_assets.run_depreciation(p_company_id uuid, p_period_end date)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'fixed_assets', 'ekwo', 'pg_temp'
AS $function$
declare
  v_period   date;
  v_lines    jsonb;
  v_entry    uuid;
  v_ref      text;
  v_booked   integer;
  v_total    numeric;
  v_posted   jsonb := '[]'::jsonb;
begin
  if not ekwo.module_is_enabled(p_company_id, 'assets') then
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
      from ekwo.entries e
     where e.company_id = p_company_id
       and e.module_code = 'assets'
       and (e.module_ref = v_ref or e.module_ref like v_ref || ':%');
    if v_booked > 0 then
      v_ref := v_ref || ':' || (v_booked + 1)::text;
    end if;

    v_entry := ekwo.post_module_entry(
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
      'amount', to_char(v_total, ekwo.amount_text_format(ekwo.rounding_of(p_company_id))));
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
$function$;
