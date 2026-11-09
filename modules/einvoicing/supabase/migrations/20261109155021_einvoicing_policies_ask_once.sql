-- Ekwo — the `einvoicing` module: its policies ask once per statement, not once
-- per row.
--
-- Every policy of the module that guards a table of a company read
--
--     using (public.module_enabled(company_id, 'einvoicing')
--            and public.has_capability(company_id, 'einvoicing.…'))
--
-- With a column as its argument each function runs for every row a scan
-- visits, and neither is inlined: `has_capability()` is security definer, and
-- `module_enabled()` carries a search_path since the socle moved to its own
-- schema. On a company with many rows here, nearly all the time of a read is
-- the policy. `scripts/inventory-policies.mjs` found it on its six tables, `issues`, `transmissions`, `transmission_events`, `clearances`, `fiscal_chain` and `fiscal_events`.
--
-- The `crm` module measured it and changed its own policies in
-- `20261109120000_crm_reads_hold_at_volume.sql`; the socle did the same for
-- its tables in `20260918141627_a_policy_asks_once.sql`. This file is that
-- change, made here: the policy compares `company_id` with the companies
-- where the answer is yes, worked out in a sub-select that depends on no
-- column — an InitPlan, run once per statement:
--
--     company_id = any ((select array(
--       select x from unnest(public.companies_with_capability('einvoicing.read')) x
--        where public.module_enabled(x, 'einvoicing')))::uuid[])
--
-- **The same question, asked the other way round.** `companies_with_capability()`
-- lists the companies where `has_capability()` answers yes — a test of the
-- socle compares the two over every preset and a machine key — and
-- `module_enabled()` is then asked about each of those, by name, so the
-- policy still routes through it as `tests/modules.test.ts` requires. A row
-- passes exactly when it passed before. A condition a policy adds to the two
-- (`and computation_id is null`) is carried over as Postgres wrote it.
-- `with check` is left as it was: it is evaluated once per row written, which
-- is what a check is for.
--
-- **Read from the catalogue.** The policies are found by their shape in
-- `pg_policies` rather than listed, so the capability each one names is
-- carried over and cannot be mistyped here. The block refuses to finish if it
-- found none — it ran twice, or the policies changed shape and this file has
-- to be read again — or if a policy of the schema still asks either function
-- about `company_id` row by row.
--
-- **Older files, older socle.** Names of the socle are written `public.`, as
-- the module's first migrations wrote them; the installer reads the file for
-- the socle's schema of the day, `ekwo.` since 20261028040000.

do $$
declare
  v_schema  constant text := 'einvoicing';
  v_module  constant text := 'einvoicing';
  v_shape   constant text :=
    '^\((?:[a-z_]+\.)?module_enabled\(company_id, ''' || v_module || '''::text\) AND '
    '(?:[a-z_]+\.)?has_capability\(company_id, ''([a-z_.]+)''::text\)( AND .+)?\)$';
  r         record;
  v_changed integer := 0;
  v_left    integer;
begin
  for r in
    select p.tablename, p.policyname, m[1] as capability, coalesce(m[2], '') as rest
      from pg_policies p
     cross join lateral regexp_match(p.qual, v_shape) as m
     where p.schemaname = v_schema
     order by p.tablename, p.policyname
  loop
    execute format(
      'alter policy %I on %I.%I using (company_id = any ((select array('
      'select x from unnest(public.companies_with_capability(%L)) as x where public.module_enabled(x, %L)'
      '))::uuid[])%s)',
      r.policyname, v_schema, r.tablename, r.capability, v_module, r.rest);
    v_changed := v_changed + 1;
  end loop;

  if v_changed = 0 then
    raise exception 'no policy of % has the shape module_enabled(company_id, …) and has_capability(company_id, …): either this ran twice, or the policies changed shape and this migration has to be read again', v_schema;
  end if;

  select count(*) into v_left
    from pg_policies p
   where p.schemaname = v_schema
     and p.qual ~ '(module_enabled|has_capability)\(company_id,';
  if v_left > 0 then
    raise exception '% policies of % still ask module_enabled() or has_capability() once per row', v_left, v_schema;
  end if;
end;
$$;
