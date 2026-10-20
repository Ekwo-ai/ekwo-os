-- Ekwo OS — the schema this release defines is 0.17.0.
--
-- `ekwo_schema_version()` is the one place the number lives, and a migration
-- is the only thing that moves it. A database then answers for the files it
-- has actually run rather than for what somebody believed it had run: the
-- column default and `init_instance()` both call this function, so a fresh
-- install records the new number without a second edit, and `ekwo migrate`
-- reads it back onto `instance.schema_version` for a database that was
-- installed at an older one.
--
-- Between 0.16.0 and here a journal reads as a book, a ledger line names its
-- contact, a tax can be computed inside its own base, a tax on turnover can
-- stand in for VAT, a company is archived before it leaves, a company numbers
-- its documents its own way (`companies.number_format`,
-- `journals.number_prefix`), and its invoice wears its typeface
-- (`companies.invoice_typeface`).
--
-- The floor of `ekwo-os`, `@ekwo-ai/core` and `@ekwo-ai/mcp` rises to 0.17.0:
-- `@ekwo-ai/core` reads `companies.number_format` and
-- `companies.invoice_typeface` with every company it lists, and `@ekwo-ai/mcp`
-- writes `journals.number_prefix`, none of which a 0.16.0 database has.

create or replace function ekwo_schema_version()
returns text
language sql
immutable
as $$
  select '0.17.0'::text;
$$;

comment on function ekwo_schema_version() is
  'Schema version of the installed release. Bumped by a migration, never by hand.';

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every migration of this directory ends with: a function that
-- comes out with the built-in default is published by Supabase as an
-- anonymous RPC endpoint.
revoke execute on all functions in schema public from public;
grant execute on function ekwo_schema_version() to authenticated, service_role;
