-- Ekwo OS — the schema this release defines is 0.15.0.
--
-- `ekwo_schema_version()` is the one place the number lives, and a migration
-- is the only thing that moves it. A database then answers for the files it
-- has actually run rather than for what somebody believed it had run: the
-- column default and `init_instance()` both call this function, so a fresh
-- install records the new number without a second edit, and `ekwo migrate`
-- reads it back onto `instance.schema_version` for a database that was
-- installed at an older one.
--
-- Between 0.14.0 and here a ledger line that names nobody is suggested its
-- contact, named once or left unnamed; several open items settle together,
-- with a small difference booked; the pairs that leave no doubt are matched
-- in one gesture; two contacts of one company are merged
-- (`merge_contacts()`, `contact_merges`), and the contacts that are probably
-- one party are proposed; an analytic value is entered on the line and the
-- result is read by activity; a company and a contact name their
-- identifiers by scheme (`companies.identifiers`, `contacts.identifiers`),
-- which `document_header` publishes; and the `einvoicing` module, at 1.2.0,
-- keeps the clearance of an invoice the authority validates before it is
-- issued (`einvoicing.clearances`).
--
-- The floor of `ekwo-os`, `@ekwo-ai/core` and `@ekwo-ai/mcp` rises to 0.15.0:
-- `@ekwo-ai/core` reads the identifiers `document_header` publishes and
-- `einvoicing.clearances`, and `@ekwo-ai/mcp` calls
-- `record_clearance_submission()`, `record_clearance_answer()` and
-- `merge_contacts()`, none of which a 0.14.0 database has.

create or replace function ekwo_schema_version()
returns text
language sql
immutable
as $$
  select '0.15.0'::text;
$$;

comment on function ekwo_schema_version() is
  'Schema version of the installed release. Bumped by a migration, never by hand.';

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every migration of this directory ends with: a function that
-- comes out with the built-in default is published by Supabase as an
-- anonymous RPC endpoint.
revoke execute on all functions in schema public from public;
grant execute on function ekwo_schema_version() to authenticated, service_role;
