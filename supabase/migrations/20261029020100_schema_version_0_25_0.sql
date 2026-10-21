-- Ekwo OS — the schema this release defines is 0.25.0.
--
-- `ekwo_schema_version()` is the one place the number lives, and a migration
-- is the only thing that moves it. A database then answers for the files it
-- has actually run rather than for what somebody believed it had run: the
-- column default and `init_instance()` both call this function, so a fresh
-- install records the new number without a second edit, and `ekwo migrate`
-- reads it back onto `instance.schema_version` for a database that was
-- installed at an older one.
--
-- Between 0.24.0 and here a late payment mention became the company's choice
-- (`20261029020000_a_late_payment_mention_is_the_companys_choice`, decision
-- 0092): one column on the company and the view of the legal mentions
-- replaced, all additive. The packages read and write the column, so it is a
-- feature of `SCHEMA_FEATURES` since this version.
--
-- The floor of `ekwo-os`, `@ekwo-ai/core` and `@ekwo-ai/mcp` stays at 0.19.0:
-- below this version a read leaves the column out.

create or replace function ekwo_schema_version()
returns text
language sql
immutable
as $$
  select '0.25.0'::text;
$$;

comment on function ekwo_schema_version() is
  'Schema version of the installed release. Bumped by a migration, never by hand.';

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every file of this directory ends with.
revoke execute on all functions in schema ekwo from public;
grant execute on function ekwo_schema_version() to authenticated, service_role;
