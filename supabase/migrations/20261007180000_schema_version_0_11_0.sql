-- Ekwo OS — the schema this release defines is 0.11.0.
--
-- `ekwo_schema_version()` is the one place the number lives, and a migration
-- is the only thing that moves it. A database then answers for the files it
-- has actually run rather than for what somebody believed it had run: the
-- column default and `init_instance()` both call this function, so a fresh
-- install records the new number without a second edit, and `ekwo migrate`
-- reads it back onto `instance.schema_version` for a database that was
-- installed at an older one.
--
-- Between 0.10.0 and here the schema gained the day a line is declared on
-- (`entry_lines.declared_on`, `declared_on_of()`, `declared_lines()`) and the
-- index the period of a tax return is read through; the rule that a machine
-- key writes as the person who issued it (`acting_user()`); the shared
-- instance (`instance.shared`, `instance.companies_per_person`,
-- `share_instance()`, `unshare_instance()`, `instance_sharing()`,
-- `may_know_of_company()`), whose tenants measure nothing of one another; the
-- order of the audit trail within one instant (`audit_log.sequence`); the
-- creator of a company (`companies.created_by`); and the guards that keep a
-- reference inside its own company and let a person join a company only of
-- their own accord. One guard a machine key walked past was closed in the
-- same stretch.
--
-- The floor of `ekwo-os`, `@ekwo-ai/core` and `@ekwo-ai/mcp` rises to 0.11.0
-- with it: a 0.10.0 database is refused by name, and told to run
-- `ekwo migrate`, rather than answered for by packages that were never run
-- against it. Here the packages read what only this schema has — the audit
-- trail of `@ekwo-ai/core` and the MCP tool `read_audit_log` select and order
-- by `audit_log.sequence`, which a 0.10.0 database does not have.

create or replace function ekwo_schema_version()
returns text
language sql
immutable
as $$
  select '0.11.0'::text;
$$;

comment on function ekwo_schema_version() is
  'Schema version of the installed release. Bumped by a migration, never by hand.';

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every migration of this directory ends with: a function that
-- comes out with the built-in default is published by Supabase as an
-- anonymous RPC endpoint.
revoke execute on all functions in schema public from public;
grant execute on function ekwo_schema_version() to authenticated, service_role;
