-- Ekwo OS — the schema this release defines is 0.22.0.
--
-- `ekwo_schema_version()` is the one place the number lives, and a migration
-- is the only thing that moves it. A database then answers for the files it
-- has actually run rather than for what somebody believed it had run: the
-- column default and `init_instance()` both call this function, so a fresh
-- install records the new number without a second edit, and `ekwo migrate`
-- reads it back onto `instance.schema_version` for a database that was
-- installed at an older one.
--
-- Between 0.21.0 and here `suggest_duplicate_contacts()` proposes the
-- contacts of one party together — one contact kept for the whole group, one
-- row per other contact — and answers with one more column, `proposed_name`,
-- the simplest name the group carries
-- (`20261027190000_the_contacts_of_one_party_are_proposed_together`).
--
-- The floor of `ekwo-os`, `@ekwo-ai/core` and `@ekwo-ai/mcp` stays at 0.19.0:
-- the migration only adds. The function keeps its name and its arguments, the
-- columns it answered with keep theirs, and a reader on an older schema takes
-- the name of the kept contact where `proposed_name` is not answered.

create or replace function ekwo_schema_version()
returns text
language sql
immutable
as $$
  select '0.22.0'::text;
$$;

comment on function ekwo_schema_version() is
  'Schema version of the installed release. Bumped by a migration, never by hand.';

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every migration of this directory ends with: a function that
-- comes out with the built-in default is published by Supabase as an
-- anonymous RPC endpoint.
revoke execute on all functions in schema public from public;
grant execute on function ekwo_schema_version() to authenticated, service_role;
