-- Ekwo OS — the schema this release defines is 0.23.0.
--
-- `ekwo_schema_version()` is the one place the number lives, and a migration
-- is the only thing that moves it. A database then answers for the files it
-- has actually run rather than for what somebody believed it had run: the
-- column default and `init_instance()` both call this function, so a fresh
-- install records the new number without a second edit, and `ekwo migrate`
-- reads it back onto `instance.schema_version` for a database that was
-- installed at an older one.
--
-- Between 0.22.0 and here the socle moved out of `public` into its own
-- schema, `ekwo` (`20261028040000_the_socle_moves_to_its_schema`, decision
-- 0090): the function below is written unqualified on purpose, and lands in
-- the socle's schema through the path of the connection that runs the file —
-- `ekwo` once the move has run, as every file after it.
--
-- The floor of `ekwo-os`, `@ekwo-ai/core` and `@ekwo-ai/mcp` stays at 0.19.0:
-- a client finds the socle by its marker in either layout, and a database
-- before the move is read exactly as before.

create or replace function ekwo_schema_version()
returns text
language sql
immutable
as $$
  select '0.23.0'::text;
$$;

comment on function ekwo_schema_version() is
  'Schema version of the installed release. Bumped by a migration, never by hand.';

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every file of this directory ends with.
revoke execute on all functions in schema ekwo from public;
grant execute on function ekwo_schema_version() to authenticated, service_role;
