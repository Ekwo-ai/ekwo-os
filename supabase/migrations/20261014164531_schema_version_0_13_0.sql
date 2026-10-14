-- Ekwo OS — the schema this release defines is 0.13.0.
--
-- `ekwo_schema_version()` is the one place the number lives, and a migration
-- is the only thing that moves it. A database then answers for the files it
-- has actually run rather than for what somebody believed it had run: the
-- column default and `init_instance()` both call this function, so a fresh
-- install records the new number without a second edit, and `ekwo migrate`
-- reads it back onto `instance.schema_version` for a database that was
-- installed at an older one.
--
-- Between 0.12.2 and here `pack_certification` gains `proven` and
-- `country_packs.evidence` holds what a proven pack was proven on;
-- `settle_from_statement()` takes per-item amounts and extra lines, so a bank
-- line settles what it pays net of its fees; `opening_balance()` takes an
-- opening date inside the year and the open items of the previous system as
-- documents; and a pack may say which of its accounts make each aggregate of
-- an analysis (`analysis_aggregates`, `analysis_templates`, `analysis_rules`),
-- which `financial_analysis()` reads.
--
-- The floor of `ekwo-os`, `@ekwo-ai/core` and `@ekwo-ai/mcp` rises to 0.13.0:
-- `@ekwo-ai/core` and `@ekwo-ai/mcp` call `financial_analysis()`, and the
-- Belgian and French packs `ekwo-os` carries write `analysis_templates` and
-- `analysis_rules` when they are installed or upgraded, none of which a
-- 0.12.2 database has.

create or replace function ekwo_schema_version()
returns text
language sql
immutable
as $$
  select '0.13.0'::text;
$$;

comment on function ekwo_schema_version() is
  'Schema version of the installed release. Bumped by a migration, never by hand.';

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every migration of this directory ends with: a function that
-- comes out with the built-in default is published by Supabase as an
-- anonymous RPC endpoint.
revoke execute on all functions in schema public from public;
grant execute on function ekwo_schema_version() to authenticated, service_role;
