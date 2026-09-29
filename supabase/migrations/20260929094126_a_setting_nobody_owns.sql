-- ---------------------------------------------------------------------------
-- A setting nobody owns is not a credential
-- ---------------------------------------------------------------------------
-- Found by an outside reader of these migrations, on 29 September 2026.
--
-- A custom setting — `ekwo.installing`, `ekwo.year_end_entry`,
-- `ekwo.closing_fiscal_year` — is what PostgreSQL calls a placeholder, and a
-- placeholder carries no privileges: any session may set it. PostgREST gives a
-- client no way to issue a `SET`, so nothing in this file concerns a request
-- through the API. It concerns a direct connection, which is how Ekwo OS runs
-- on a Postgres of one's own — and on such a database an operator creates a
-- second login sooner or later: a reporting user, a BI tool, a bookkeeper
-- given fewer rights than the owner.
--
-- That login has `auth.uid()` null and no `ekwo.api_key`. Until this file,
-- `is_installer()` (20260918140000) asked nothing else, so one
-- `set ekwo.installing = 'on'` made it the installer, and every guard written
-- `if not is_installer() and not has_capability(…)` stood aside for it. The
-- test that shows it — tests/settings_nobody_owns.test.ts — has such a login,
-- a member of `authenticated` and nothing more, issue itself a machine key
-- carrying every capability of a company through `create_api_key()`, which
-- is definer and runs past row level security.
--
-- **The installer is now also a question of who connected.** The runner, the
-- seeds and `ekwo init` connect as the role that owns the tables of this
-- schema, and that role could already set every guard here aside: the owner
-- of a table may disable its triggers. So `is_installer()` asks, beside the
-- setting, whether `session_user` is a member of the owner of `companies` —
-- which lends the exemption to nobody who did not hold more than it already.
-- A superuser is a member of every role, which keeps a local Postgres and the
-- test harness installing as before.
--
-- `session_user`, not `current_user`: inside a `security definer` function
-- `current_user` *is* the owner, whoever called it, and half the functions
-- that ask `is_installer()` are definer. `session_user` is the login that
-- opened the connection, and `set role` does not move it.
--
-- The reader offered a role of our own, `ekwo_installer`, and membership in
-- it. Ownership was chosen instead because it needs nothing configured: a
-- role is created once per cluster, has to be granted to whoever runs the
-- migrations, and on a hosted Postgres the migrating login is not always
-- allowed to grant itself one. The owner of the tables exists on every
-- installation already, and is the one role the exemption cannot widen.
--
-- **The two year-end settings now stand in for one rule only.**
-- `ekwo.year_end_entry` lets `opening_balance()`, `close_fiscal_year()` and
-- `reopen_fiscal_year()` write an entry whose `kind` is not `normal`;
-- `ekwo.closing_fiscal_year` lets the last two move `is_closed` and
-- `closed_at`. The guards that read them cannot tell who set them — the three
-- functions are invoker, so the setting is raised in the caller's own
-- transaction — and a person on a direct connection could raise either by
-- hand: label an entry a closing entry, which takes its amounts out of the
-- income statement, or move the date a year was closed on, with no right to
-- close a year.
--
-- The guards now honour the setting only for a caller the function itself
-- would have let through: the installer, or somebody holding the capability
-- the act needs — `year_end.close` to close, re-open and write the entries
-- that do it, `entries.post` for an opening balance, which is what posting
-- the entry `opening_balance()` wrote already requires. Refused, the caller
-- reads the sentence the capability guard of the act would have given them.
--
-- The reader offered a second way: make the three functions
-- `security definer`, and have the guards require `current_user` to be the
-- owner, which only a definer function can be. It closes one thing more — a
-- person who *does* hold `year_end.close` could no longer write a closing
-- entry by hand instead of through `close_fiscal_year()` — and it costs row
-- level security on three functions that read and write a whole year of a
-- company: their own checks would become the only gate between a caller and
-- every company of the installation. That is not taken here. What it would
-- close is reachable only from a direct connection, where the caller also
-- chooses its own `request.jwt.claims`, and so its own `auth.uid()`: on that
-- path a connection is trusted with the identity it declares, and no guard of
-- this schema can do better than the capability of that identity.
-- ---------------------------------------------------------------------------

create or replace function is_installer()
returns boolean
language sql
stable
as $$
  select auth.uid() is null
     and nullif(current_setting('ekwo.api_key', true), '') is null
     and coalesce(current_setting('ekwo.installing', true) = 'on', false)
     and pg_has_role(session_user,
                     (select c.relowner from pg_class c where c.oid = 'public.companies'::regclass),
                     'MEMBER');
$$;

comment on function is_installer() is
  'Whether the caller is the installation itself — the migration runner, the seeds, the CLI — rather than a person or a machine key. True only when there is no session and no key, ekwo.installing is on, and the login that opened the connection is a member of the role that owns the tables: a setting any session may write is not enough on its own. False, never NULL, because the guards negate it.';

create or replace function entries_guard_kind()
returns trigger
language plpgsql
as $$
declare
  v_needs text;
begin
  if tg_op = 'INSERT' and new.kind = 'normal' then
    return new;
  end if;
  if tg_op = 'UPDATE' and new.kind is not distinct from old.kind then
    return new;
  end if;

  if coalesce(current_setting('ekwo.year_end_entry', true), '') = 'on' then
    v_needs := case when new.kind = 'opening' then 'entries.post' else 'year_end.close' end;
    if is_installer() or has_capability(new.company_id, v_needs) then
      return new;
    end if;
    -- The words of the capability guard the act would have met, so the
    -- refusal is the same whichever way the caller came.
    if v_needs = 'entries.post' then
      raise exception 'not_allowed: posting an entry in this company needs entries.post'
        using errcode = '42501';
    end if;
    raise exception 'not_allowed: closing or re-opening a financial year needs year_end.close'
      using errcode = '42501';
  end if;

  if tg_op = 'INSERT' then
    raise exception 'entry_kind_not_a_column: an opening or closing entry is written by opening_balance() and close_fiscal_year(), not by hand'
      using errcode = '55006';
  end if;
  raise exception 'entry_kind_not_a_column: kind is written by opening_balance() and close_fiscal_year(), not by hand'
    using errcode = '55006';
end;
$$;

comment on function entries_guard_kind() is
  'Keeps entries.kind on `normal` outside the three functions that open and close a year. The setting they raise while they write is honoured only for the installer or a caller holding the capability of the act — year_end.close, or entries.post for an opening — because any session may set it. A label any client may set is a label a statement cannot be built on.';

create or replace function fiscal_years_guard_closed()
returns trigger
language plpgsql
as $$
begin
  if new.is_closed is not distinct from old.is_closed
     and new.closed_at is not distinct from old.closed_at then
    return new;
  end if;

  if coalesce(current_setting('ekwo.closing_fiscal_year', true), '') = 'on' then
    if is_installer() or has_capability(new.company_id, 'year_end.close') then
      return new;
    end if;
    raise exception 'not_allowed: closing or re-opening a financial year needs year_end.close'
      using errcode = '42501';
  end if;

  raise exception 'fiscal_year_close_not_a_column: is_closed is set by close_fiscal_year() and cleared by reopen_fiscal_year()'
    using errcode = '55006';
end;
$$;

comment on function fiscal_years_guard_closed() is
  'Refuses a hand-written change to is_closed or closed_at. The setting close_fiscal_year() and reopen_fiscal_year() raise is honoured only for the installer or a caller holding year_end.close, because any session may set it. A column any client may flip is not a lock.';

-- ---------------------------------------------------------------------------
-- Grants
--
-- Nothing new is created: three functions are replaced, which keeps their
-- privileges. The rule of `supabase/migrations/README.md` is kept all the same.
-- ---------------------------------------------------------------------------

revoke execute on all functions in schema public from public;
