-- Ekwo OS — the schema this release defines is 0.24.0.
--
-- `ekwo_schema_version()` is the one place the number lives, and a migration
-- is the only thing that moves it. A database then answers for the files it
-- has actually run rather than for what somebody believed it had run: the
-- column default and `init_instance()` both call this function, so a fresh
-- install records the new number without a second edit, and `ekwo migrate`
-- reads it back onto `instance.schema_version` for a database that was
-- installed at an older one.
--
-- Between 0.23.0 and here a document sent from a phone became a draft
-- purchase (`20261028152338_a_purchase_arrives_from_the_phone`, decision
-- 0091): one function, one draft-only nullable column and, where Storage is
-- present, a bucket and its policies — all additive.
--
-- The floor of `ekwo-os`, `@ekwo-ai/core` and `@ekwo-ai/mcp` stays at 0.19.0:
-- the packages read and call nothing the release added.

create or replace function ekwo_schema_version()
returns text
language sql
immutable
as $$
  select '0.24.0'::text;
$$;

comment on function ekwo_schema_version() is
  'Schema version of the installed release. Bumped by a migration, never by hand.';

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every file of this directory ends with.
revoke execute on all functions in schema ekwo from public;
grant execute on function ekwo_schema_version() to authenticated, service_role;
