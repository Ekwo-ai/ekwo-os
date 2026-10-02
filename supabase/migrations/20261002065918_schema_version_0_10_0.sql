-- Ekwo OS — the schema this release defines is 0.10.0.
--
-- `ekwo_schema_version()` is the one place the number lives, and a migration
-- is the only thing that moves it. A database then answers for the files it
-- has actually run rather than for what somebody believed it had run: the
-- column default and `init_instance()` both call this function, so a fresh
-- install records the new number without a second edit, and `ekwo migrate`
-- reads it back onto `instance.schema_version` for a database that was
-- installed at an older one.
--
-- Between 0.9.0 and here the schema gained the way out of a company
-- (`remove_member()`, `set_member_role()`, `company_members_list()`), the
-- scheme a country's banks identify an account in
-- (`bank_accounts.account_scheme`, `account_identifier`,
-- `country_defaults.bank_account_scheme`), the reading of an archive under the
-- names of today (`archive_under_current_names()`), and the rule that a
-- machine key holds only what its issuer still holds (`member_holds()`,
-- `key_holds()`, `api_key_on_company()`, the view `api_key_reach`), with
-- `api_key_company()` removed. The guards of the audit trail and of the
-- installer were restated in the same stretch.
--
-- The floor of `ekwo-os`, `@ekwo-ai/core` and `@ekwo-ai/mcp` rises to 0.10.0
-- with it, as it has at every release: a 0.9.0 database is refused by name,
-- and told to run `ekwo migrate`, rather than answered for by packages that
-- were never run against it. Here the packages read what only this schema
-- has — `ekwo doctor` reads `api_key_reach`, the MCP server calls
-- `remove_member()` and `set_member_role()`, and the installer writes a bank
-- account in the scheme of its country.

create or replace function ekwo_schema_version()
returns text
language sql
immutable
as $$
  select '0.10.0'::text;
$$;

comment on function ekwo_schema_version() is
  'Schema version of the installed release. Bumped by a migration, never by hand.';

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every migration of this directory ends with: a function that
-- comes out with the built-in default is published by Supabase as an
-- anonymous RPC endpoint.
revoke execute on all functions in schema public from public;
grant execute on function ekwo_schema_version() to authenticated, service_role;
