-- Ekwo OS — the schema this release defines is 0.20.0.
--
-- `ekwo_schema_version()` is the one place the number lives, and a migration
-- is the only thing that moves it. A database then answers for the files it
-- has actually run rather than for what somebody believed it had run: the
-- column default and `init_instance()` both call this function, so a fresh
-- install records the new number without a second edit, and `ekwo migrate`
-- reads it back onto `instance.schema_version` for a database that was
-- installed at an older one.
--
-- Between 0.19.0 and here a declaration whose debt was matched before
-- matching said so is recorded paid, a deposit is written by the core's
-- functions only (`write_filing_outcome()`, the policy
-- `tax_filing_deposits_write` and the direct writes gone), and the
-- administration a declaration is paid to is named in the company's language
-- (`country_defaults.tax_payee_name_i18n`, read by `tax_payee()`).
--
-- The floor of `ekwo-os`, `@ekwo-ai/core` and `@ekwo-ai/mcp` rises to 0.20.0:
-- `ekwo-os` compiles packs into `country_defaults.tax_payee_name_i18n`, which
-- a 0.19.0 database does not have, and the three packages declare one floor.

create or replace function ekwo_schema_version()
returns text
language sql
immutable
as $$
  select '0.20.0'::text;
$$;

comment on function ekwo_schema_version() is
  'Schema version of the installed release. Bumped by a migration, never by hand.';

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every migration of this directory ends with: a function that
-- comes out with the built-in default is published by Supabase as an
-- anonymous RPC endpoint.
revoke execute on all functions in schema public from public;
grant execute on function ekwo_schema_version() to authenticated, service_role;
