-- Ekwo OS — the version answers a key too, and a stranger not at all.
--
-- `installed_schema_version()` was granted to `authenticated` alone, because
-- the client that asks it asks after signing in. A machine key now reaches the
-- API (`20260922160000`), and it asks the same question first and for the same
-- reason: a backup that does not know whether the instance is ahead of the
-- code reading it writes an archive nobody can check.
--
-- Two ways to give it that answer. Granting `anon` the function as it stands
-- would hand an unauthenticated scanner the exact release an installation
-- runs, which is what the first migration declined to do. Granting it and
-- letting the *body* decide gives nothing away: the function returns a row to
-- a caller this installation knows — a signed-in user, or the holder of a live
-- key — and no rows at all to anybody else. `anon` may call it; calling it
-- anonymously is a way of learning nothing.
--
-- The grant is the one exception worth the sentence: a key presented through
-- the pre-request arrives as `authenticated` and does not need it. It is the
-- call made *before* the key is presented — the screen that checks a pasted
-- key against an instance — that arrives as `anon`, and the shape of the
-- answer is the same for both: zero rows unless somebody is there.

create or replace function installed_schema_version()
returns table (schema_version text, edition text)
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select i.schema_version, i.edition::text
    from instance i
   where i.id = 1
     and (auth.uid() is not null or api_key_company() is not null);
$$;

comment on function installed_schema_version() is
  'The schema version this installation runs, and its edition, for a caller it knows: a signed-in account that is on no company yet, or the holder of a machine key. No rows for anybody else, so an anonymous call learns nothing. Nothing else of the instance row comes with it.';

revoke execute on all functions in schema public from public;

revoke execute on function installed_schema_version() from public;
grant execute on function installed_schema_version() to anon, authenticated, service_role;
