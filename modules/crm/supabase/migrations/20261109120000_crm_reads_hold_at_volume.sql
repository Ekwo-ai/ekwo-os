-- Ekwo — the `crm` module: its reads hold on a company the size of an
-- imported address book.
--
-- `crm.search_cards()` was seen ending in a statement timeout on a company of
-- about 33 000 contacts, 10 500 cards, 213 segments, 226 deals and 21 500
-- activities — an ordinary size once an address book has been imported. The
-- module's test `search_at_volume.test.ts` builds a company of that order and
-- reads the plans as a member; what it found is below, cause by cause.
--
-- ---------------------------------------------------------------------------
-- 1. A policy of the module asks once per statement, not once per row
--
-- Every table of the module carried, for reading and for writing,
--
--     using (public.module_enabled(company_id, 'crm')
--            and public.has_capability(company_id, 'crm.read'))
--
-- With a column as its argument each function runs for every row a scan
-- visits, and neither is inlined: `has_capability()` is security definer, and
-- `module_enabled()` carries a search_path since the socle moved to its own
-- schema. Each card read cost five nested function calls before any filter of
-- the search was looked at. Of the 1.3 s the default search took on PGlite,
-- 1.28 s was the scan of `crm.cards` evaluating its policy 10 500 times; the
-- contacts it joins, whose policy already asks once, cost nothing.
--
-- This is the change the socle made to its own tables in
-- `20260918141627_a_policy_asks_once.sql`, which left the modules aside: the
-- policy compares `company_id` with the companies where the answer is yes,
-- worked out in a sub-select that depends on no column — an InitPlan, run
-- once per statement:
--
--     company_id = any ((select array(
--       select x from unnest(public.companies_with_capability('crm.read')) x
--        where public.module_enabled(x, 'crm')))::uuid[])
--
-- **The same question, asked the other way round.** `companies_with_capability()`
-- lists the companies where `has_capability()` answers yes — a test of the
-- socle compares the two over every preset and a machine key — and
-- `module_enabled()` is then asked about each of those, by name, so the
-- policy still routes through it as `tests/modules.test.ts` requires. A row
-- passes exactly when it passed before. `with check` is left as it was: it is
-- evaluated once per row written, which is what a check is for.
--
-- **Older files, older socle.** Names of the socle are written `public.`, as
-- the module's first migrations wrote them, so this file applies on every
-- socle the module accepts (`requires_socle_min`); the installer reads it for
-- the socle's schema of the day, `ekwo.` since 20261028040000.
-- ---------------------------------------------------------------------------

do $$
declare
  v_table text;
begin
  foreach v_table in array array['cards', 'segments', 'segment_members', 'pipelines', 'stages', 'deals', 'activities'] loop
    execute format(
      'alter policy %I on crm.%I using (company_id = any ((select array('
      'select x from unnest(public.companies_with_capability(%L)) as x where public.module_enabled(x, %L)'
      '))::uuid[]))',
      'crm_' || v_table || '_select', v_table, 'crm.read', 'crm');
    execute format(
      'alter policy %I on crm.%I using (company_id = any ((select array('
      'select x from unnest(public.companies_with_capability(%L)) as x where public.module_enabled(x, %L)'
      '))::uuid[]))',
      'crm_' || v_table || '_write', v_table, 'crm.write', 'crm');
  end loop;
end;
$$;
