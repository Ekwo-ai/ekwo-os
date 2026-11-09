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
--
-- ---------------------------------------------------------------------------
-- 2. What the plans showed besides, and why nothing else changes
--
-- With the policies asking once, a search reads every card of the company
-- once — 10 500 at that size, in about 30 ms on PGlite — joins each to its
-- contact and its organisation by primary key, and keeps the 50 latest with
-- a top-N sort in a few kilobytes. Read and left as they are:
--
-- - **The segments of each row** are computed for the rows returned only:
--   Postgres moves the sub-select past the sort, 50 loops, not 10 500.
-- - **The organisation's fallback** for country and language is one probe of
--   the primary key per card, under a microsecond each.
-- - **The ordering by last activity** is a top-N heap sort; an index on it
--   would not be used, for the reason below.
-- - **The text match** runs on the rows already joined; at ten times the
--   size it is a tenth of the 0.3 s the whole search then takes on PGlite.
--
-- `search_cards()` is a SQL function with a search_path of its own, so
-- Postgres does not inline it and plans its query once for any arguments:
-- every `p_… is null or …` stays in the plan, and no index serving one
-- filter — trigram, partial or ordered — can be chosen for it. Giving each
-- filter its index means building the query per call, a larger change than
-- the size asks for: the search answers in under 0.4 s at ten times the
-- size on PGlite, against a statement timeout counted in seconds.
-- `segment_tree()`, `board()` and `timeline()` asked per row the same way,
-- the tree most of all (2.7 s, 30 000 memberships counted), and need nothing
-- more than this.
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
