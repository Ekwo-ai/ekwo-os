-- Ekwo OS — the schema this release defines is 0.12.2.
--
-- `ekwo_schema_version()` is the one place the number lives, and a migration
-- is the only thing that moves it. A database then answers for the files it
-- has actually run rather than for what somebody believed it had run: the
-- column default and `init_instance()` both call this function, so a fresh
-- install records the new number without a second edit, and `ekwo migrate`
-- reads it back onto `instance.schema_version` for a database that was
-- installed at an older one.
--
-- Between 0.12.1 and here the balance sheet of each pack says whether the
-- line that receives the result of the year in progress holds it alone or
-- combined with other balances (`statement_templates.result_in_progress`,
-- `result_in_progress_name`, `result_in_progress_name_i18n`), and
-- `financial_statement_of_kind()` prints a combined line's result in progress
-- as a sub-line of its own, through `statement_figures()`. A bank line is
-- settled only by the function that settles it, a matching settles the items
-- of one counterparty, a ledger line names only a declaration box its tax
-- posting writes, and it keeps the boxes it was posted in
-- (`entry_lines.declaration_boxes`), which the periodic return reads.
--
-- The floor of `ekwo-os`, `@ekwo-ai/core` and `@ekwo-ai/mcp` rises to 0.12.2:
-- every pack `ekwo-os` carries writes the three new columns when it is
-- installed or upgraded, which a 0.12.1 database does not have.

create or replace function ekwo_schema_version()
returns text
language sql
immutable
as $$
  select '0.12.2'::text;
$$;

comment on function ekwo_schema_version() is
  'Schema version of the installed release. Bumped by a migration, never by hand.';

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every migration of this directory ends with: a function that
-- comes out with the built-in default is published by Supabase as an
-- anonymous RPC endpoint.
revoke execute on all functions in schema public from public;
grant execute on function ekwo_schema_version() to authenticated, service_role;
