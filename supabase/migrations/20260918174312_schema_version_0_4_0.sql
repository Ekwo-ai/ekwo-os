-- Ekwo OS — the schema this release defines is 0.4.0.
--
-- `ekwo_schema_version()` is the one place the number lives, and a migration
-- is the only thing that moves it. A database then answers for the files it
-- has actually run rather than for what somebody believed it had run: the
-- column default and `init_instance()` both call this function, so a fresh
-- install records the new number without a second edit, and `ekwo migrate`
-- reads it back onto `instance.schema_version` for a database that was
-- installed at an older one.
--
-- Between 0.3.0 and here the schema gained the whole life of a declaration,
-- a firm that keeps the books of its clients, a statement a bank sent, and a
-- posted row that does not move. The packages of this release read all of it,
-- and a 0.3.0 database has none of it: `tax_filings` with `tax_filing_boxes`
-- and `tax_filing_deposits`, and `file_filing()`, `record_filing_outcome()`,
-- `reopen_filing()`, `upcoming_filings()` and `filing_drift()` around them;
-- the `client` preset with `documents.deposit`, `company.export`, and
-- `portfolio_upcoming_filings()` and `portfolio_filings_touched_since()`;
-- `export_company()` and `import_company()` with `company_archive_registry`;
-- `import_bank_statement()` with `bank_statement_lines` and
-- `bank_transactions.import_key`; `document_lines.vat_category` and
-- `vat_rate`, there since the first schema and written at last, then frozen
-- at posting, and `companies.peppol_scheme` and
-- `peppol_identifier`, which the invoice written for the network is read
-- from; `documents.client_ref` and `rehearse_post_document()`, which the
-- command line keeps books through; `companies_with_capability()`, which
-- every policy of a company's table now asks once per statement; and
-- `document_amount_paid()` with the four guards that refuse, by name, a change
-- to a posted document, to a posted entry, and a posting that did not go
-- through `post_entry()` — `document_posted`, `entry_posted`,
-- `document_born_posted`, `entry_born_posted`, `entry_posted_by_hand`,
-- `document_posted_by_hand` — which the command line and the MCP server
-- explain rather than report as a failure. So the packages declare 0.4.0 as
-- their floor and refuse an older database by name, rather than improvising
-- over a column that is not there.

create or replace function ekwo_schema_version()
returns text
language sql
immutable
as $$
  select '0.4.0'::text;
$$;

comment on function ekwo_schema_version() is
  'Schema version of the installed release. Bumped by a migration, never by hand.';

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every migration of this directory ends with: a function that
-- comes out with the built-in default is published by Supabase as an
-- anonymous RPC endpoint.
revoke execute on all functions in schema public from public;
grant execute on function ekwo_schema_version() to authenticated, service_role;
