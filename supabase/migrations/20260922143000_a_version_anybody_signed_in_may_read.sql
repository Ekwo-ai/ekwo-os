-- Ekwo OS — the version of the schema, for somebody who is on no company yet.
--
-- A client of this schema has one question to ask before it draws anything:
-- is this installation new enough for the code I ship? The answer is
-- `instance.schema_version`, and the policy on that table admits members of
-- at least one company and instance administrators — for the reason written
-- in `20260911140000`: self sign-up is on by default on a Supabase project,
-- so a signed-in stranger is ordinary and the organisation's name, its country
-- and the day it was installed are not theirs to read.
--
-- A freshly created account is exactly that stranger. It signs in, reads no
-- row, and the client cannot tell an instance behind its schema from one
-- whose row it was never allowed to see. Both are silence, and the two call
-- for opposite behaviour: print `ekwo migrate`, or say nothing and carry on.
-- A web application meets this on its first screen, with an account whose
-- invitation has not arrived yet.
--
-- So the version leaves the table and becomes a question of its own.
-- `installed_schema_version()` is definer — it reads the singleton row past a
-- policy that was written about the rest of it — and it returns two fields
-- and no others: the version the migrations wrote, and the edition, which is
-- `community` or `cloud` and gates nothing anywhere in this repository.
-- Whoever the caller is, what they learn is what release this software is at.
-- Nothing about the customer comes with it.
--
-- **`anon` does not get it**, and the exception is not worth making. Decision
-- 0002 keeps the anonymous surface closed, and the list of what `anon` may
-- execute is the policy helpers, which answer about `auth.uid()` and therefore
-- say nothing, plus `shared_document()`, which somebody was handed a link to.
-- The version is not in that shape: nobody asks it before signing in — the
-- client asks it *after*, which is the moment the old answer went missing —
-- and granting it would hand an unauthenticated scanner the exact release an
-- installation runs, for a convenience nothing needs. A reader who needs it
-- signs in first.

create or replace function installed_schema_version()
returns table (schema_version text, edition text)
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select i.schema_version, i.edition::text from instance i where i.id = 1;
$$;

comment on function installed_schema_version() is
  'The schema version this installation runs, and its edition. Definer, so a signed-in account that is on no company yet can still tell an instance behind its schema from one it may not read the row of — which is the same silence otherwise. Nothing else of the instance row comes with it.';

revoke execute on all functions in schema public from public;

revoke execute on function installed_schema_version() from public, anon;
grant execute on function installed_schema_version() to authenticated, service_role;
