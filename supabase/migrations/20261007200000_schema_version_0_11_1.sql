-- Ekwo OS — the schema this release defines is 0.11.1.
--
-- `ekwo_schema_version()` is the one place the number lives, and a migration
-- is the only thing that moves it. A database then answers for the files it
-- has actually run rather than for what somebody believed it had run: the
-- column default and `init_instance()` both call this function, so a fresh
-- install records the new number without a second edit, and `ekwo migrate`
-- reads it back onto `instance.schema_version` for a database that was
-- installed at an older one.
--
-- Between 0.11.0 and here a request made with a machine key runs on the
-- statement_timeout of `authenticated` rather than on the one of `anon`
-- (`authenticated_statement_timeout()`), and an export reads each table of a
-- company once (`export_company_archive()`, `company_archive_row_counts()`,
-- `company_archive_rows_query()`, `company_archive_predicate_via()`), writing
-- the same bytes as before. The trail asks who reads it once per statement
-- (`caller_companies()`).
--
-- The floor of `ekwo-os`, `@ekwo-ai/core` and `@ekwo-ai/mcp` stays at 0.11.0:
-- no package of this release reads anything a 0.11.0 database does not have.

create or replace function ekwo_schema_version()
returns text
language sql
immutable
as $$
  select '0.11.1'::text;
$$;

comment on function ekwo_schema_version() is
  'Schema version of the installed release. Bumped by a migration, never by hand.';

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every migration of this directory ends with: a function that
-- comes out with the built-in default is published by Supabase as an
-- anonymous RPC endpoint.
revoke execute on all functions in schema public from public;
grant execute on function ekwo_schema_version() to authenticated, service_role;
