-- Ekwo OS — a machine key that reaches the API, and not only a connection.
--
-- Decision 0006 wrote the limit down rather than hiding it: "because PostgREST
-- runs each request in its own transaction, a key is for a client holding a
-- connection". `use_api_key()` puts the key's fingerprint in `ekwo.api_key`
-- transaction-locally, and two REST calls are two transactions, so the key was
-- never presented when the work ran. Anything operated for somebody else — a
-- backup, a scheduled report, a script on a host with no psql — had to hold a
-- password of theirs or their `service_role` key. Both are worse than the key
-- the schema already mints.
--
-- The same decision left one question open, in as many words: "Deciding what
-- of `companies` a key may read is an open question, recorded rather than
-- patched per function." This answers it.
--
-- ---------------------------------------------------------------------------
-- 1. The key travels in a header, and the transaction reads it
-- ---------------------------------------------------------------------------
--
-- PostgREST calls one function of our choosing at the start of every request's
-- transaction — `pgrst.db_pre_request` — which is exactly the place
-- `use_api_key()` was missing. `ekwo_pre_request()` reads
-- `X-Ekwo-Api-Key` off `request.headers` and presents the key. No header, no
-- effect: a request that carries none is the request it was before this
-- migration, down to the role it runs as.
--
-- The name of the header is ours and not `Authorization`: PostgREST reads the
-- role out of that one, and a value it cannot parse as a JWT fails the request
-- before any function of ours runs. Two doors, two names.
--
-- ---------------------------------------------------------------------------
-- 2. The role, which is the part that is not obvious
-- ---------------------------------------------------------------------------
--
-- A request carrying only the publishable key runs as `anon`, and `anon` holds
-- no privilege on any table of this schema — decision 0003, and
-- `tests/grants.test.ts` asserts it. Row level security never gets a chance to
-- decide: the grant refuses first. So presenting a key has to move the request
-- off `anon`, and `ekwo_pre_request()` does that, *after* the key has been
-- checked and never before:
--
--     set_config('role', 'authenticated', true)
--
-- Three things make that sound rather than clever.
--
-- **It is not a definer function.** PostgreSQL refuses `set role` inside
-- SECURITY DEFINER — "cannot set parameter role within security-definer
-- function" — so `ekwo_pre_request()` runs as its caller, and the privilege
-- check is the ordinary one: the session user is `authenticator`, which is a
-- member of `authenticated`, and that is what makes the switch legal. A role
-- that is a member of nothing is refused by the server, not by us.
--
-- **Nothing is reached before the key is proven.** `present_api_key()` raises
-- on a key that is unknown, withdrawn or expired, and a raise inside the
-- pre-request fails the whole request. The switch is on the line after it.
--
-- **`authenticated` is not a person.** `auth.uid()` stays null — a key is not
-- a session, which is the sentence decision 0006 opens with — so every policy
-- that asks for a signed-in user still answers no, and what the caller may do
-- is decided by `has_capability()`, which has answered for a key since the
-- keys landed. The role is the door; the capabilities are the rooms.
--
-- ---------------------------------------------------------------------------
-- 3. What a key is on: its own company
-- ---------------------------------------------------------------------------
--
-- Past the grants, five policies still refused, and they are the ones that ask
-- `is_company_member()` rather than a capability: the company row itself, its
-- members, which modules it has on, how often it files, its matching settings,
-- its audit trail. They are structural — a caller that cannot read
-- `companies` cannot export the company, cannot round at its currency and
-- cannot find its financial year — and none of them has a capability of its
-- own, by decision 0004: "no capability without something that can refuse on
-- it".
--
-- So the answer is written once, where the question is asked:
--
--     a key of a company is on that company.
--
-- `is_company_member()` says true for the company the presented key belongs
-- to, and every policy that asks it follows without being rewritten —
-- including `module_enabled()`, which is the same question for a module's
-- tables. A key is still narrower than the member who issued it: every
-- capability on it was one the issuer held, and every table that has a
-- capability keeps asking for it. What it gains is the handful of rows that
-- describe the company it was minted for, which is the company it can already
-- read the ledger of.
--
-- Widened deliberately and stated so a reviewer can object: whatever its
-- capabilities, a key reads its company's row, its members, its modules, its
-- filing periods, its matching settings and its audit trail — exactly what the
-- narrowest member of that company reads. It reads nothing of any other
-- company, because `api_keys.company_id` is one company and there is no second
-- one to name.
--
-- The reference tables of the installation — currencies, charts, statement
-- schemes, the capability list — ask a different question again,
-- `auth.uid() is not null`, and they are the subject of the migration that
-- follows this one: they are not a company's rows, and what they were reaching
-- for was never a session but a caller this installation knows.

-- ---------------------------------------------------------------------------
-- The company of the key presented in this transaction
-- ---------------------------------------------------------------------------

create or replace function api_key_company()
returns uuid
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select k.company_id
    from api_keys k
   where k.key_hash = nullif(current_setting('ekwo.api_key', true), '')
     and k.revoked_at is null
     and (k.expires_at is null or k.expires_at > now());
$$;

comment on function api_key_company() is
  'The company of the machine key presented in this transaction, or nothing. What `is_company_member()` asks so that a key is on the company it was minted for, and the only thing of a key the policy helpers read.';

-- ---------------------------------------------------------------------------
-- A member, or a key of this company
--
-- The body is the only place the rule lives. `company_role()` still answers
-- about `auth.uid()` alone, and stays the answer to "which preset is this
-- person on" — a key is on no preset, holds a list, and must not be made to
-- look like a role.
-- ---------------------------------------------------------------------------

create or replace function is_company_member(p_company_id uuid)
returns boolean
language sql
stable
as $$
  -- `coalesce`, and decision 0005 is why: `p_company_id = api_key_company()`
  -- is NULL when no key is presented, `false or NULL` is NULL, and a guard
  -- written as `if not is_company_member(...)` would not fire for a stranger.
  -- A helper a guard is written on answers true or false and never NULL.
  select company_role(p_company_id) is not null
      or coalesce(p_company_id = api_key_company(), false);
$$;

comment on function is_company_member(uuid) is
  'Whether the caller is on a company: a member of it, or the holder of a machine key minted on it. False, never NULL, for a stranger.';

create or replace function is_any_company_member()
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (select 1 from company_members m where m.user_id = auth.uid())
      or api_key_company() is not null;
$$;

comment on function is_any_company_member() is
  'Whether the caller belongs to at least one company of this installation, as a member or as the holder of a machine key.';

-- ---------------------------------------------------------------------------
-- Presenting a key without reading one
--
-- `use_api_key()` returns the row, which is what a client holding a connection
-- wants and what a pre-request must not hand back: the pre-request is called
-- by `anon`, so whatever it can call, an anonymous caller can call. This
-- returns nothing at all, and the row — `key_hash` included — stays behind the
-- grant it has always been behind.
-- ---------------------------------------------------------------------------

create or replace function present_api_key(p_secret text)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform use_api_key(p_secret);
end;
$$;

comment on function present_api_key(text) is
  'Presents a machine key for the current transaction and answers nothing. What `ekwo_pre_request()` calls, and the only form of the question an anonymous caller may ask: the refusals of use_api_key() word for word, and no row.';

-- ---------------------------------------------------------------------------
-- The pre-request
--
-- Invoker, deliberately: PostgreSQL refuses `set role` inside a definer
-- function, and the privilege that makes the switch legal is the session's —
-- `authenticator` is a member of `authenticated` — not ours to lend.
--
-- `request.headers` is set by PostgREST and absent everywhere else, so the
-- function is a no-op on a direct connection, which is what the command line
-- and the MCP server use.
-- ---------------------------------------------------------------------------

create or replace function ekwo_pre_request()
returns void
language plpgsql
set search_path = public, pg_temp
as $$
declare
  v_headers json := nullif(current_setting('request.headers', true), '')::json;
  v_secret  text := nullif(v_headers ->> 'x-ekwo-api-key', '');
begin
  if v_secret is null then
    return;
  end if;

  -- Raises on a key that is unknown, withdrawn or expired, and the raise fails
  -- the request. Nothing below this line runs for a key that is not one.
  perform present_api_key(v_secret);

  -- Off `anon`, which holds no privilege on any table, and onto the role whose
  -- grants row level security is written against. `auth.uid()` stays null.
  perform set_config('role', 'authenticated', true);
end;
$$;

comment on function ekwo_pre_request() is
  'Called by PostgREST at the start of every request (pgrst.db_pre_request). Presents the key in X-Ekwo-Api-Key when there is one, then moves the request off `anon` so that row level security decides instead of the grants. No header, no effect.';

-- ---------------------------------------------------------------------------
-- Telling PostgREST to call it
--
-- The setting lives on the `authenticator` role, which is the login PostgREST
-- connects with. It is configuration of the API and not of the schema, so a
-- database that has no such role — PGlite under the tests, a plain Postgres
-- behind the command line — skips it and loses nothing.
--
-- Where the role exists and the migration is not allowed to write its
-- settings, the schema is still correct and the header is simply not read yet.
-- That is a state somebody has to be told about rather than left to discover,
-- so it is a notice here and a check in `ekwo doctor`, which names the exact
-- statement to run.
-- ---------------------------------------------------------------------------

do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'authenticator') then
    return;
  end if;
  begin
    execute 'alter role authenticator set pgrst.db_pre_request = ''public.ekwo_pre_request''';
    notify pgrst, 'reload config';
  exception when insufficient_privilege then
    raise notice 'ekwo: could not set pgrst.db_pre_request on the authenticator role. Machine keys will not be read from X-Ekwo-Api-Key until somebody with the privilege runs: alter role authenticator set pgrst.db_pre_request = ''public.ekwo_pre_request''; notify pgrst, ''reload config''; — `ekwo doctor` reports this.';
  end;
end
$$;

revoke execute on all functions in schema public from public;

-- `anon` gains two functions, and the decision record says why. `api_key_company()`
-- is read by `is_company_member()`, which `anon` already executes on behalf of
-- a policy; `present_api_key()` and `ekwo_pre_request()` are the door itself,
-- and both answer `void`.
revoke execute on function api_key_company()    from public;
revoke execute on function present_api_key(text) from public;
revoke execute on function ekwo_pre_request()   from public;

grant execute on function api_key_company()      to anon, authenticated, service_role;
grant execute on function present_api_key(text)  to anon, authenticated, service_role;
grant execute on function ekwo_pre_request()     to anon, authenticated, service_role;
