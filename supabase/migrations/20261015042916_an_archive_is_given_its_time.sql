-- ---------------------------------------------------------------------------
-- An archive is given the time it takes
-- ---------------------------------------------------------------------------
-- `20261007190000` gave a request carrying a key the clock of `authenticated`
-- — eight seconds on a hosted project — and made an export read each table
-- once. That holds for a young company. It stops holding as the books grow:
-- measured on a real 0.13.0 installation on 15 October 2026, a company
-- of two years (3 603 entries, 8 035 lines, 4 598 rows of trail,
-- about 17 000 rows in all) exports 12.5 MB in 11.5 seconds, and its nightly
-- copy fails every night with `canceling statement due to statement timeout`.
-- A company of the same size signed in as a member fails the same way when it
-- downloads its own archive. No speed-up keeps a whole company under a clock
-- made for one screen: an archive is all of a company's rows, and they grow.
--
-- So the pre-request gives the calls that carry a whole company — the
-- export, whole or in half, and the import that takes it back — a clock of
-- their own, `archive_statement_timeout()`. It is only ever raised: a
-- database configured with no clock at all (`0`) keeps none, and one already
-- longer keeps its own. It is raised only for a caller who is somebody — a
-- key presented by this same hook, or a signed-in session — so an anonymous
-- request is not handed a longer clock than it had.
--
-- The path is what PostgREST names the call by (`request.path`); a request
-- that reaches the functions another way — the command line, `psql` — sets
-- its own clock, as it always did.
-- ---------------------------------------------------------------------------

create or replace function archive_statement_timeout()
returns text
language sql
immutable
set search_path = public, pg_temp
as $$
  -- Five minutes: twenty-five times the company measured above, and less than
  -- what the callers that ask for an archive give it on their side.
  select '5min'::text;
$$;

comment on function archive_statement_timeout() is
  'The statement_timeout a request is given when it carries a whole company: export_company(), its manifest and tables, and import_company(). Applied by ekwo_pre_request(), only ever upwards.';

create or replace function is_archive_request(p_path text)
returns boolean
language sql
immutable
set search_path = public, pg_temp
as $$
  select coalesce(p_path, '') in (
    '/rpc/export_company',
    '/rpc/export_company_manifest',
    '/rpc/export_company_tables',
    '/rpc/export_company_table',
    '/rpc/import_company'
  );
$$;

comment on function is_archive_request(text) is
  'Whether a PostgREST path names a call that carries a whole company, and is given archive_statement_timeout().';

create or replace function ekwo_pre_request()
returns void
language plpgsql
set search_path = public, pg_temp
as $$
declare
  v_headers json := nullif(current_setting('request.headers', true), '')::json;
  v_secret  text := nullif(v_headers ->> 'x-ekwo-api-key', '');
  v_claims  json := nullif(current_setting('request.jwt.claims', true), '')::json;
  v_timeout text;
begin
  if v_secret is not null then
    -- Raises on a key that is unknown, withdrawn or expired, and the raise
    -- fails the request. Nothing below this line runs for a key that is not one.
    perform present_api_key(v_secret);

    -- Off `anon`, which holds no privilege on any table, and onto the role
    -- whose grants row level security is written against. `auth.uid()` stays null.
    perform set_config('role', 'authenticated', true);

    -- And onto its clock. PostgREST armed the one of the role it started the
    -- request as; the work that follows is the work of `authenticated`, and
    -- is given its time.
    v_timeout := authenticated_statement_timeout();
    if v_timeout is not null then
      perform set_config('statement_timeout', v_timeout, true);
    end if;
  end if;

  -- A whole company is given the time it takes, by a caller who is somebody:
  -- asked in that order, so an anonymous request never reaches the helpers,
  -- which are not `anon`'s to execute.
  if v_secret is not null or v_claims ->> 'role' = 'authenticated' then
    if is_archive_request(current_setting('request.path', true))
       and current_setting('statement_timeout') <> '0'
       -- Only upwards: a clock already longer than the archive's is kept.
       and extract(epoch from current_setting('statement_timeout')::interval)
             < extract(epoch from archive_statement_timeout()::interval)
    then
      perform set_config('statement_timeout', archive_statement_timeout(), true);
    end if;
  end if;
end;
$$;

comment on function ekwo_pre_request() is
  'Called by PostgREST at the start of every request (pgrst.db_pre_request). Presents the key in X-Ekwo-Api-Key when there is one, then moves the request off `anon` so that row level security decides instead of the grants, and gives it the statement_timeout configured for `authenticated`, when one is. A call that carries a whole company (is_archive_request) by a key or a signed-in session is given archive_statement_timeout(), only ever upwards. No header and no archive, no effect.';

-- Reached from the pre-request once the caller is somebody, so never `anon`'s;
-- the doctrine of 20260914151207.
revoke execute on function archive_statement_timeout() from public, anon;
revoke execute on function is_archive_request(text) from public, anon;
grant execute on function archive_statement_timeout() to authenticated, service_role;
grant execute on function is_archive_request(text) to authenticated, service_role;
