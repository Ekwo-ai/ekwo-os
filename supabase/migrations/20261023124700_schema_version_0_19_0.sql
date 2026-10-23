-- Ekwo OS — the schema this release defines is 0.19.0.
--
-- `ekwo_schema_version()` is the one place the number lives, and a migration
-- is the only thing that moves it. A database then answers for the files it
-- has actually run rather than for what somebody believed it had run: the
-- column default and `init_instance()` both call this function, so a fresh
-- install records the new number without a second edit, and `ekwo migrate`
-- reads it back onto `instance.schema_version` for a database that was
-- installed at an older one.
--
-- 0.18.0 kept the schema at 0.17.0. Between 0.17.0 and here a tax lands by its
-- code and not on a line, a company files under a VAT scheme and pays on
-- account (`vat_schemes`, `company_vat_schemes`, `declaration_instalments`,
-- `instalment_plan()`, the column `instalment` of `upcoming_filings()`), and a
-- declaration names its files and the administration it is paid to
-- (`record_filing_files()`, `tax_payee()`, `country_defaults.tax_payee_name`).
--
-- The floor of `ekwo-os`, `@ekwo-ai/core` and `@ekwo-ai/mcp` rises to 0.19.0:
-- `ekwo-os` compiles packs into `vat_schemes` and
-- `country_defaults.tax_payee_name`, and `@ekwo-ai/mcp` calls
-- `instalment_plan()`, none of which a 0.17.0 database has.

create or replace function ekwo_schema_version()
returns text
language sql
immutable
as $$
  select '0.19.0'::text;
$$;

comment on function ekwo_schema_version() is
  'Schema version of the installed release. Bumped by a migration, never by hand.';

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every migration of this directory ends with: a function that
-- comes out with the built-in default is published by Supabase as an
-- anonymous RPC endpoint.
revoke execute on all functions in schema public from public;
grant execute on function ekwo_schema_version() to authenticated, service_role;
