-- Ekwo OS — the schema this release defines is 0.12.1.
--
-- `ekwo_schema_version()` is the one place the number lives, and a migration
-- is the only thing that moves it. A database then answers for the files it
-- has actually run rather than for what somebody believed it had run: the
-- column default and `init_instance()` both call this function, so a fresh
-- install records the new number without a second edit, and `ekwo migrate`
-- reads it back onto `instance.schema_version` for a database that was
-- installed at an older one.
--
-- Between 0.12.0 and here a balance sheet drawn before the close carries the
-- result of the year in progress on its equity side
-- (`statement_account_matches()`, on the new `year_result_account()` and
-- `statement_rule_catches()`), and `fec_lines()` reads the same account for
-- the result of a year nobody closed.
--
-- The floor of `ekwo-os`, `@ekwo-ai/core` and `@ekwo-ai/mcp` stays at 0.12.0:
-- no package of this release calls anything a 0.12.0 database does not have.
-- A 0.12.0 database answers every call; its balance sheet is the one that
-- leaves the result of an open year out.

create or replace function ekwo_schema_version()
returns text
language sql
immutable
as $$
  select '0.12.1'::text;
$$;

comment on function ekwo_schema_version() is
  'Schema version of the installed release. Bumped by a migration, never by hand.';

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every migration of this directory ends with: a function that
-- comes out with the built-in default is published by Supabase as an
-- anonymous RPC endpoint.
revoke execute on all functions in schema public from public;
grant execute on function ekwo_schema_version() to authenticated, service_role;
