-- Ekwo OS — the schema this release defines is 0.25.0.
--
-- `ekwo_schema_version()` is the one place the number lives, and a migration
-- is the only thing that moves it. A database then answers for the files it
-- has actually run rather than for what somebody believed it had run: the
-- column default and `init_instance()` both call this function, so a fresh
-- install records the new number without a second edit, and `ekwo migrate`
-- reads it back onto `instance.schema_version` for a database that was
-- installed at an older one.
--
-- Between 0.24.0 and here, all additive, each a feature of `SCHEMA_FEATURES`
-- since this version because the packages read or call it:
--
-- - `20261029010000_a_pack_names_the_words_of_its_invoices`: the words of an
--   invoice a pack names, `country_defaults.invoice_labels`
--   (`invoice_labels_by_pack`);
-- - `20261029010100_a_late_payment_mention_is_the_companys_choice`, decision
--   0092: one column on the company and the view of the legal mentions
--   replaced (`late_payment_mention`);
-- - `20261029010200_a_company_is_counted_never_read`, decision 0093:
--   `usage_figures()`, which no package calls, so it is no feature;
-- - `20261029010300_a_contact_has_a_statement`: `contact_statement()`
--   (`contact_statement`);
-- - `20261029010400_a_bank_account_is_created_by_its_function`:
--   `create_bank_account()` (`create_bank_account`);
-- - `20261029010500_an_archive_is_read_in_pages`, decision 0094:
--   `export_company_outline()` and `export_company_page()`
--   (`archive_in_pages`).
--
-- The floor of `ekwo-os`, `@ekwo-ai/core` and `@ekwo-ai/mcp` stays at 0.19.0:
-- below this version a read leaves out what it adds.

create or replace function ekwo_schema_version()
returns text
language sql
immutable
as $$
  select '0.25.0'::text;
$$;

comment on function ekwo_schema_version() is
  'Schema version of the installed release. Bumped by a migration, never by hand.';

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every file of this directory ends with.
revoke execute on all functions in schema ekwo from public;
grant execute on function ekwo_schema_version() to authenticated, service_role;
