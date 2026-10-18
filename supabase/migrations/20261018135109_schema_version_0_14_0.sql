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
-- Between 0.13.0 and here an archive request is given five minutes;
-- `analysis_templates` and `analysis_rules` hold a framework's rows and
-- `financial_analysis()` falls back on them; `product_report()` reads what
-- each product brought in and cost; `country_defaults.einvoice_fiscalisation`
-- holds the chained or reported record a country requires; a piece goes on
-- its document (`attachments_guard_document`); and a closed year can be
-- reopened while a final close cannot (`fiscal_years.finally_closed_at`,
-- `close_fiscal_year_finally()`, `fiscal_year_final_close()` and the
-- `final_close_*` columns of `country_defaults`).
--
-- The floor of `ekwo-os`, `@ekwo-ai/core` and `@ekwo-ai/mcp` rises to 0.14.0:
-- `@ekwo-ai/mcp` calls `close_fiscal_year_finally()` and
-- `fiscal_year_final_close()` and reads
-- `country_defaults.einvoice_fiscalisation`, `@ekwo-ai/core` reads the
-- fiscalisation of a country, and the packs `ekwo-os` carries write
-- `einvoice_fiscalisation`, `final_close_due` and the `framework` of their
-- statements when they are installed or upgraded, none of which a 0.13.0
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
