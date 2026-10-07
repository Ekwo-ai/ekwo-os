-- Ekwo OS, module tax — a key writes as the person who issued it.
--
-- The socle migration `20261007041207` records the author of a write with
-- `acting_user()` — the signed-in user, or the person who issued the machine
-- key presented — instead of `auth.uid()`, which is null for a key. This file
-- does the same for the three functions of this module that name an author,
-- and for the default of `company_parameters.declared_by`. Decision 0064.
--
-- It attributes and never authorises: the guards below still ask
-- `has_capability()` for `tax.write` and `tax.finalize`, exactly as before.
--
-- `requires_socle_min` names the socle this module was first built on, and
-- every migration of a module must sort after it, so it cannot move to the
-- socle file above. `ekwo migrate` applies the socle before the modules, so
-- `acting_user()` exists by the time this runs; a database that somehow lacks
-- it is told so by name rather than left with a function that fails at its
-- first call.

do $$
begin
  if to_regprocedure('public.acting_user()') is null then
    raise exception 'socle_too_old: the tax module needs socle migration 20261007041207 (acting_user). Run ekwo migrate first.';
  end if;
end;
$$;

create or replace function tax.record_computation(p_company_id uuid, p_fiscal_year_id uuid, p_at date default NULL::date)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  v_year    public.fiscal_years%rowtype;
  v_id      uuid;
  v_version integer;
  v_to      date;
begin
  if not public.module_is_enabled(p_company_id, 'tax') then
    raise exception 'module_not_enabled: the corporate income tax module (tax) is not enabled on this company'
      using errcode = '42501';
  end if;
  if not public.is_installer() and not public.has_capability(p_company_id, 'tax.write') then
    raise exception 'not_allowed: recording a computation of the tax needs tax.write'
      using errcode = '42501';
  end if;

  select * into v_year from public.fiscal_years f
   where f.id = p_fiscal_year_id and f.company_id = p_company_id;
  if not found then
    raise exception 'unknown_fiscal_year: % is not a financial year of this company', p_fiscal_year_id;
  end if;

  -- One writer per year at a time: two recordings cannot take the same
  -- number, and a recording cannot slip in beside a finalisation.
  perform pg_advisory_xact_lock(hashtextextended('tax:' || p_company_id::text || ':' || p_fiscal_year_id::text, 0));

  if exists (
    select 1 from tax.computations c
     where c.company_id = p_company_id and c.fiscal_year_id = p_fiscal_year_id and c.status = 'final'
  ) then
    raise exception 'fiscal_year_has_final_computation: the tax of % has a final computation. Withdraw it with tax.withdraw_computation() before recording another.',
      v_year.name
      using errcode = '55006';
  end if;

  v_to := least(coalesce(p_at, v_year.end_date), v_year.end_date);

  select coalesce(max(c.version), 0) + 1 into v_version
    from tax.computations c
   where c.company_id = p_company_id and c.fiscal_year_id = p_fiscal_year_id;

  v_id := gen_random_uuid();

  with lines as (
    select * from tax.estimate(p_company_id, p_fiscal_year_id, v_to)
  ),
  header as (
    insert into tax.computations
      (id, company_id, fiscal_year_id, version, status, computed_at, tax_code, currency_code,
       accounting_result, taxable_base, loss_of_period, tax, recorded_by)
    select v_id, p_company_id, p_fiscal_year_id, v_version, 'estimate', v_to,
           (select l.code from lines l where l.kind = 'estimated_tax'),
           (select c.currency_code from public.companies c where c.id = p_company_id),
           (select l.amount from lines l where l.kind = 'accounting_result'),
           (select l.amount from lines l where l.kind = 'taxable_base'),
           coalesce((select l.amount from lines l where l.kind = 'loss_of_period'), 0),
           (select l.amount from lines l where l.kind = 'estimated_tax'),
           public.acting_user()
    returning id
  )
  insert into tax.computation_lines
    (computation_id, company_id, sequence, kind, code, name, base, rate, amount, legal_reference, source_key)
  select h.id, p_company_id, l.sequence, l.kind, l.code, l.name, l.base, l.rate, l.amount,
         l.legal_reference, l.source_key
    from lines l cross join header h;

  return v_id;
end;
$function$;

create or replace function tax.finalise_computation(p_computation_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  v_row  tax.computations%rowtype;
  v_year public.fiscal_years%rowtype;
begin
  -- Who is asking comes before anything is locked or said: a computation of a
  -- company the caller is not on does not exist for them.
  select * into v_row from tax.computations c where c.id = p_computation_id;
  if not found or not (public.is_installer() or public.is_company_member(v_row.company_id)) then
    raise exception 'unknown_computation: %', p_computation_id;
  end if;
  if not public.module_is_enabled(v_row.company_id, 'tax') then
    raise exception 'module_not_enabled: the corporate income tax module (tax) is not enabled on this company'
      using errcode = '42501';
  end if;
  if not public.is_installer() and not public.has_capability(v_row.company_id, 'tax.finalize') then
    raise exception 'not_allowed: calling a computation of the tax final needs tax.finalize'
      using errcode = '42501';
  end if;

  perform pg_advisory_xact_lock(hashtextextended('tax:' || v_row.company_id::text || ':' || v_row.fiscal_year_id::text, 0));
  select * into v_row from tax.computations c where c.id = p_computation_id for update;
  if v_row.status <> 'estimate' then
    raise exception 'computation_not_an_estimate: version % is %, and only an estimate is finalised', v_row.version, v_row.status
      using errcode = '55006';
  end if;

  select * into v_year from public.fiscal_years f where f.id = v_row.fiscal_year_id;
  if v_row.computed_at <> v_year.end_date then
    raise exception 'computation_not_whole_year: version % reads the ledger up to %, and % ends on %. Record the whole year first.',
      v_row.version, v_row.computed_at, v_year.name, v_year.end_date
      using errcode = '55006';
  end if;
  if exists (
    select 1 from tax.computations c
     where c.company_id = v_row.company_id and c.fiscal_year_id = v_row.fiscal_year_id
       and c.version > v_row.version
  ) then
    raise exception 'computation_not_latest: a later computation of % was recorded after version %', v_year.name, v_row.version
      using errcode = '55006';
  end if;

  -- The years are called final in their order. A later year that is already
  -- final read the loss stock as it stood without this one, and would go on
  -- saying so: it is withdrawn first.
  if exists (
    select 1 from tax.computations c
      join public.fiscal_years f on f.id = c.fiscal_year_id
     where c.company_id = v_row.company_id and c.status = 'final'
       and f.start_date > v_year.start_date
  ) then
    raise exception 'later_year_final: a financial year after % has a final computation. Withdraw it first: the losses are used in the order of the years.',
      v_year.name
      using errcode = '55006';
  end if;
  if v_row.loss_of_period > 0 and exists (
    select 1 from tax.losses s
     where s.company_id = v_row.company_id and s.origin_period_end = v_year.end_date
  ) then
    raise exception 'loss_already_declared: a loss is already recorded for the year ending %. A loss the company declared for a year these books compute is removed before that year is called final.',
      v_year.end_date
      using errcode = '55006';
  end if;

  -- What is called final is what the books say today. A ledger that moved
  -- since the computation was recorded gives a different estimate, and then
  -- the recorded one is history rather than the tax of the year.
  if exists (
    (select l.sequence, l.kind, l.code, l.base, l.rate, l.amount
       from tax.computation_lines l where l.computation_id = v_row.id
     except
     select e.sequence, e.kind, e.code, e.base, e.rate, e.amount
       from tax.estimate(v_row.company_id, v_row.fiscal_year_id, v_row.computed_at) e)
    union all
    (select e.sequence, e.kind, e.code, e.base, e.rate, e.amount
       from tax.estimate(v_row.company_id, v_row.fiscal_year_id, v_row.computed_at) e
     except
     select l.sequence, l.kind, l.code, l.base, l.rate, l.amount
       from tax.computation_lines l where l.computation_id = v_row.id)
  ) then
    raise exception 'computation_stale: the books, the declarations or the rules moved since version % was recorded, and it no longer says what an estimate says today. Record the year again and finalise that.',
      v_row.version
      using errcode = '55006';
  end if;

  update tax.computations
     set status = 'final', finalised_by = public.acting_user(), finalised_at = now()
   where id = v_row.id;

  update tax.computation_lines
     set kind = 'tax_due'
   where computation_id = v_row.id and kind = 'estimated_tax';

  -- The stock moves with the final computation and with nothing else: what it
  -- used of each earlier loss, and the loss it leaves behind if it made one.
  insert into tax.loss_uses (company_id, loss_id, computation_id, amount)
  select v_row.company_id, s.id, v_row.id, -l.amount
    from tax.computation_lines l
    join tax.losses s
      on s.company_id = v_row.company_id and s.origin_period_end = l.code::date
   where l.computation_id = v_row.id and l.kind = 'loss_used';

  -- Never more than a loss was. The order of the years makes this
  -- unreachable; it is asserted because a stock below zero would quietly eat
  -- the other losses.
  if exists (select 1 from tax.loss_stock(v_row.company_id) s where s.remaining < 0) then
    raise exception 'loss_overused: a loss would be used for more than it is'
      using errcode = '55006';
  end if;

  if v_row.loss_of_period > 0 then
    insert into tax.losses (company_id, origin_period_end, amount, computation_id)
    values (v_row.company_id, v_year.end_date, v_row.loss_of_period, v_row.id);
  end if;

  return v_row.id;
end;
$function$;

create or replace function tax.withdraw_computation(p_computation_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  v_row tax.computations%rowtype;
begin
  select * into v_row from tax.computations c where c.id = p_computation_id;
  if not found or not (public.is_installer() or public.is_company_member(v_row.company_id)) then
    raise exception 'unknown_computation: %', p_computation_id;
  end if;
  if not public.module_is_enabled(v_row.company_id, 'tax') then
    raise exception 'module_not_enabled: the corporate income tax module (tax) is not enabled on this company'
      using errcode = '42501';
  end if;
  if not public.is_installer() and not public.has_capability(v_row.company_id, 'tax.finalize') then
    raise exception 'not_allowed: withdrawing a final computation of the tax needs tax.finalize'
      using errcode = '42501';
  end if;

  perform pg_advisory_xact_lock(hashtextextended('tax:' || v_row.company_id::text || ':' || v_row.fiscal_year_id::text, 0));
  select * into v_row from tax.computations c where c.id = p_computation_id for update;
  if v_row.status <> 'final' then
    raise exception 'computation_not_final: version % is %, and only a final computation is withdrawn', v_row.version, v_row.status
      using errcode = '55006';
  end if;

  -- A loss this computation left behind, and a later final computation
  -- already drew on: that one goes first.
  if exists (
    select 1 from tax.loss_uses u
      join tax.losses s on s.id = u.loss_id
     where s.computation_id = v_row.id and u.computation_id <> v_row.id
  ) then
    raise exception 'loss_already_used: a later final computation used the loss this one recorded. Withdraw that one first.'
      using errcode = '55006';
  end if;

  -- And the years are taken back in the reverse of their order, for the
  -- reason they are called final in it.
  if exists (
    select 1 from tax.computations c
      join public.fiscal_years f on f.id = c.fiscal_year_id
      join public.fiscal_years mine on mine.id = v_row.fiscal_year_id
     where c.company_id = v_row.company_id and c.status = 'final'
       and f.start_date > mine.start_date
  ) then
    raise exception 'later_year_final: a later financial year has a final computation. Withdraw that one first.'
      using errcode = '55006';
  end if;

  delete from tax.loss_uses where computation_id = v_row.id;
  delete from tax.losses where computation_id = v_row.id;

  update tax.computations
     set status = 'superseded', superseded_by = public.acting_user(), superseded_at = now()
   where id = v_row.id;

  update tax.computation_lines
     set kind = 'estimated_tax'
   where computation_id = v_row.id and kind = 'tax_due';

  return v_row.id;
end;
$function$;

alter table tax.company_parameters alter column declared_by set default public.acting_user();
