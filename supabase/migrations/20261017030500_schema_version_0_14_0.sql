-- Ekwo OS — the schema this release defines is 0.14.0.
--
-- `ekwo_schema_version()` is the one place the number lives, and a migration
-- is the only thing that moves it. A database then answers for the files it
-- has actually run rather than for what somebody believed it had run: the
-- column default and `init_instance()` both call this function, so a fresh
-- install records the new number without a second edit, and `ekwo migrate`
-- reads it back onto `instance.schema_version` for a database that was
-- installed at an older one.
--
-- Between 0.13.0 and here an export or an import through the REST interface
-- is given the time it takes (`archive_statement_timeout()`); the rows of an
-- analysis belong either to a country's chart or to a framework
-- (`analysis_templates.framework`, `analysis_rules.framework`), and
-- `financial_analysis()` reads the framework's rows for a company whose pack
-- carries no analysis and says which it read in a new column, `source`; and
-- `product_report()` reads what each product brought in and cost.
--
-- The floor of `ekwo-os`, `@ekwo-ai/core` and `@ekwo-ai/mcp` rises to 0.14.0:
-- the framework pack `ekwo-os` carries writes `analysis_templates.framework`
-- and `analysis_rules.framework`, and `@ekwo-ai/core` and `@ekwo-ai/mcp` read
-- the `source` column of `financial_analysis()`, none of which a 0.13.0
-- database has.

create or replace function ekwo_schema_version()
returns text
language sql
immutable
as $$
  select '0.14.0'::text;
$$;

comment on function ekwo_schema_version() is
  'Schema version of the installed release. Bumped by a migration, never by hand.';

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every migration of this directory ends with: a function that
-- comes out with the built-in default is published by Supabase as an
-- anonymous RPC endpoint.
revoke execute on all functions in schema public from public;
grant execute on function ekwo_schema_version() to authenticated, service_role;
