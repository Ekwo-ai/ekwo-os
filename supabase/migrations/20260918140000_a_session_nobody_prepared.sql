-- ---------------------------------------------------------------------------
-- A session nobody prepared is not the installer
-- ---------------------------------------------------------------------------
-- `is_installer()` ended on `current_setting('ekwo.installing', true) = 'on'`.
-- A setting that was set and emptied answers '', and '' = 'on' is false. A
-- setting that was NEVER set answers NULL, and NULL = 'on' is NULL — so on a
-- new connection the function answered NULL, and every guard written
--
--     if not is_installer() and not has_capability(…) then raise …
--
-- evaluated `NULL and true`, which is NULL, which `if` does not take. The
-- guard was skipped. A person always carries a `sub` and is answered by
-- `has_capability()`; the caller with neither a session nor a key — the
-- `service_role` through PostgREST, a direct connection — walked through
-- create_company(), the counters, the API keys and the module switches.
--
-- The migration that introduced the function was the one about guards that
-- could answer NULL, and its tests never saw this one: the harness always set
-- the variable, to 'on' for the owner and to '' for a person. A test now
-- reloads the database into an instance where nothing was ever set
-- (tests/fresh_session.test.ts) and asks every argument-less boolean helper
-- the same question.
--
-- `service_role` bypasses row level security on Supabase, by design of the
-- platform. It does not bypass a function that raises — which is why the
-- functions are where an installation's rules are, and why this mattered.
-- ---------------------------------------------------------------------------

create or replace function is_installer()
returns boolean
language sql
stable
as $$
  select auth.uid() is null
     and nullif(current_setting('ekwo.api_key', true), '') is null
     and coalesce(current_setting('ekwo.installing', true) = 'on', false);
$$;

comment on function is_installer() is
  'Whether the caller is the installation itself — the migration runner, the seeds, the CLI — rather than a person or a machine key. Set by the runner on its own connection; a session or a key can never be it, and neither can a connection where the setting was never made: the answer is false there, never NULL, because the guards negate it.';
