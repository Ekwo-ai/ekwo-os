-- Ekwo OS — the schema this release defines is 0.26.0.
--
-- `ekwo_schema_version()` is the one place the number lives, and a migration
-- is the only thing that moves it. A database then answers for the files it
-- has actually run rather than for what somebody believed it had run: the
-- column default and `init_instance()` both call this function, so a fresh
-- install records the new number without a second edit, and `ekwo migrate`
-- reads it back onto `instance.schema_version` for a database that was
-- installed at an older one.
--
-- Between 0.25.0 and here, all additive; those the packages read or call are
-- features of `SCHEMA_FEATURES` since this version:
--
-- - `20261107100000_a_control_account_reads_contact_by_contact`:
--   `subledger()` and the contacts of `general_ledger()` (`subledger`,
--   `ledger_by_contact`);
-- - `20261108120000_an_electronic_invoice_arrives_by_the_same_door`: an XML
--   page through `receive_purchase_document()`;
-- - `20261108152128_a_bank_account_keeps_the_profile_of_its_csv_statements`:
--   `bank_accounts.statement_profile` (`statement_profile`);
-- - `20261110124117_the_socle_policies_ask_once`: fifteen policies of the
--   socle asked once per statement, and `companies_of_caller()`;
-- - `20261115070000_a_financial_year_opens_on_any_month`: the twelve months
--   of `fiscal_year_default`;
-- - `20261115080000_the_portfolio_reads_what_is_overdue`:
--   `portfolio_overview()` (`portfolio_overview`);
-- - `20261115100000_a_declaration_has_a_short_name`:
--   `tax_report_templates.short_name` (`filing_short_name`);
-- - `20261118144012_a_quote_carries_its_answer`, decision 0098: the answer
--   of a quote and `quote_status()` (`quote_answer`).
--
-- The floor of `ekwo-os`, `@ekwo-ai/core` and `@ekwo-ai/mcp` stays at 0.19.0:
-- below this version a read leaves out what it adds.

create or replace function ekwo_schema_version()
returns text
language sql
immutable
as $$
  select '0.26.0'::text;
$$;

comment on function ekwo_schema_version() is
  'Schema version of the installed release. Bumped by a migration, never by hand.';

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every file of this directory ends with.
revoke execute on all functions in schema ekwo from public;
grant execute on function ekwo_schema_version() to authenticated, service_role;
