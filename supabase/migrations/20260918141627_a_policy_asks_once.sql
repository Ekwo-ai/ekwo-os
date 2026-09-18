-- Ekwo OS — a policy asks once per statement, not once per row.
--
-- Found by `tests/load/`, the first test of this repository that reads books
-- of more than fifteen documents, and reads them as a signed-in member rather
-- than as the owner of the database.
--
-- Every table of a company carried the policy
--
--     using (has_capability(company_id, 'entries.read'))
--
-- and `has_capability()` is `stable`. It was read here — and written down on
-- the roadmap — as "evaluated once per query". That is not what `stable`
-- means. It promises Postgres that the function gives the same answer for the
-- same arguments within one statement; it does not make Postgres remember
-- the answer. With a column as its argument the function is called for every
-- row the scan visits, and being SECURITY DEFINER it cannot be inlined: each
-- call is a function entry and one or two index probes of its own.
--
-- Measured on PGlite, five companies of 10 000 documents, one of them read:
--
--                     as the owner   as a member   calls of has_capability()
--   general_ledger          15 ms        133 ms               about  11 700
--   trial_balance           72 ms      3 266 ms               about 359 000
--   aged_balance            25 ms        233 ms               about  20 100
--   vat_return              44 ms        460 ms               about  40 000
--
-- The plans were the same on both sides — the same indexes, no sequential
-- scan — so nothing about the shape of a plan would ever have shown it. The
-- whole difference is the policy, and it is nine to forty-five times the cost
-- of the query it guards.
--
-- ---------------------------------------------------------------------------
-- What changes
--
-- `companies_with_capability(capability)` answers the same question the other
-- way round: not "may the caller do this in that company" but "in which
-- companies may the caller do this", as an array. A policy then reads
--
--     using (company_id = any ((select companies_with_capability('entries.read'))::uuid[]))
--
-- and the sub-select, which depends on no column, is an InitPlan: Postgres
-- runs it once per statement and compares every row against the result. As a
-- bonus the comparison is an ordinary `=` on an indexed column, which the
-- planner may use to reach the rows, where a function call could only ever
-- filter them.
--
-- **One definition of who may do what.** The new function does not restate
-- the rules of `has_capability()` — revoked beats granted, a key is consulted
-- only where there is no member answer. It lists the only companies where the
-- answer can be yes — those the caller is a member of, and the one a presented
-- key belongs to — and asks `has_capability()` about each. A change to the
-- rules changes both, and `tests/capabilities.test.ts` compares the two over
-- every preset, every capability and a machine key.
--
-- **Which policies.** Those whose expression is exactly
-- `has_capability(company_id, '<capability>')`, in `public`: fifty-two of
-- them, a select and a write policy on twenty-six tables. They are rewritten
-- by reading the catalogue rather than by fifty-two statements, so that the
-- capability each policy names is carried over and cannot be mistyped here.
-- The block refuses to finish if it found none, or if one of that shape is
-- left.
--
-- `with check` is left as it was. It is evaluated once per row *written*,
-- which is what a check is for, and a statement that writes ten thousand rows
-- is an import, not a report.
--
-- Left alone, and said so: the policies that combine the test with another
-- (`attachments`, `api_keys`, `company_members`), the ones that reach the
-- company through a parent row (`journal_sequences`, `tax_filing_boxes`,
-- `tax_filing_deposits`), and the modules, whose policies also ask
-- `module_enabled()`. None of them guards a table a report walks.
-- `docs/decisions.md` records them.

create or replace function companies_with_capability(p_capability text)
returns uuid[]
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select coalesce(array_agg(x.company_id), '{}'::uuid[])
    from (
      select m.company_id
        from company_members m
       where m.user_id = auth.uid()
      union
      select k.company_id
        from api_keys k
       where k.key_hash = nullif(current_setting('ekwo.api_key', true), '')
    ) x
   where has_capability(x.company_id, p_capability);
$$;

comment on function companies_with_capability(text) is
  'The companies in which the current caller may do one named thing — the question has_capability() answers, asked once for all of them. It is what a row level security policy compares company_id against, inside a sub-select, so that the answer is worked out once per statement instead of once per row.';

revoke execute on function companies_with_capability(text) from public, anon;
grant execute on function companies_with_capability(text) to authenticated, service_role;

do $$
declare
  r         record;
  v_shape   constant text := '^has_capability\(company_id, (''[a-z_.]+'')::text\)$';
  v_changed integer := 0;
  v_left    integer;
begin
  for r in
    select p.schemaname, p.tablename, p.policyname,
           (regexp_match(p.qual, v_shape))[1] as capability
      from pg_policies p
     where p.schemaname = 'public'
       and p.qual ~ v_shape
     order by p.tablename, p.policyname
  loop
    execute format(
      'alter policy %I on %I.%I using (company_id = any ((select companies_with_capability(%s))::uuid[]))',
      r.policyname, r.schemaname, r.tablename, r.capability);
    v_changed := v_changed + 1;
  end loop;

  if v_changed = 0 then
    raise exception 'no policy of the shape has_capability(company_id, …) was found: either this ran twice, or the policies changed shape and this migration has to be read again';
  end if;

  select count(*) into v_left
    from pg_policies p
   where p.schemaname = 'public' and p.qual ~ v_shape;
  if v_left > 0 then
    raise exception '% policies still call has_capability() once per row', v_left;
  end if;
end;
$$;
