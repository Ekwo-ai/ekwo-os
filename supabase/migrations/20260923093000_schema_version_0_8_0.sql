-- Ekwo OS — the schema this release defines is 0.8.0.
--
-- `ekwo_schema_version()` is the one place the number lives, and a migration
-- is the only thing that moves it. A database then answers for the files it
-- has actually run rather than for what somebody believed it had run: the
-- column default and `init_instance()` both call this function, so a fresh
-- install records the new number without a second edit, and `ekwo migrate`
-- reads it back onto `instance.schema_version` for a database that was
-- installed at an older one.
--
-- Between 0.7.0 and here the schema gained the way a key reaches the API.
-- `ekwo_pre_request()` is called by PostgREST at the start of every request,
-- named in `pgrst.db_pre_request`, and presents the secret sent in
-- `X-Ekwo-Api-Key` before the request leaves `anon`; `present_api_key()` does
-- the presenting, `is_known_caller()` answers for a signed-in user or the
-- holder of a live key, and `is_company_member()` says true for the company a
-- key was minted on. It also gained `installed_schema_version()`, which
-- answers a caller this installation knows and nobody else, and
-- `default_statement_code()` with `financial_statement_of_kind()`, which give
-- a balance sheet to a client that does not know the country pack. A 0.7.0
-- database has none of them, and the packages of this release call them: the
-- floor of `ekwo-os`, `@ekwo-ai/core` and `@ekwo-ai/mcp` rises to 0.8.0 and
-- refuses an older database by name, as every release has, rather than
-- answering for one they were never run against.

create or replace function ekwo_schema_version()
returns text
language sql
immutable
as $$
  select '0.8.0'::text;
$$;

comment on function ekwo_schema_version() is
  'Schema version of the installed release. Bumped by a migration, never by hand.';

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every migration of this directory ends with: a function that
-- comes out with the built-in default is published by Supabase as an
-- anonymous RPC endpoint.
revoke execute on all functions in schema public from public;
grant execute on function ekwo_schema_version() to authenticated, service_role;
