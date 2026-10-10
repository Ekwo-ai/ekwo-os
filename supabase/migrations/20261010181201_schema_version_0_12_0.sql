-- Ekwo OS — the schema this release defines is 0.12.0.
--
-- `ekwo_schema_version()` is the one place the number lives, and a migration
-- is the only thing that moves it. A database then answers for the files it
-- has actually run rather than for what somebody believed it had run: the
-- column default and `init_instance()` both call this function, so a fresh
-- install records the new number without a second edit, and `ekwo migrate`
-- reads it back onto `instance.schema_version` for a database that was
-- installed at an older one.
--
-- Between 0.11.1 and here the schema gained the proof of a filing by its hash
-- on a public ledger (`filing_proofs`, `record_filing_proof()`,
-- `upgrade_filing_proof()`, `tax_filing_values_sha256()`, and the public door
-- `filing_proof()`). The `einvoicing` module and the country packs added in
-- the same stretch arrive as a module and as seeds, not as migrations of the
-- core schema.
--
-- The floor of `ekwo-os`, `@ekwo-ai/core` and `@ekwo-ai/mcp` rises to 0.12.0
-- with it: `@ekwo-ai/core` and `ekwo proof` call `record_filing_proof()` and
-- `upgrade_filing_proof()`, which a 0.11.1 database does not have, so such a
-- database is refused by name and told to run `ekwo migrate` rather than
-- failing later in a call nobody can place.

create or replace function ekwo_schema_version()
returns text
language sql
immutable
as $$
  select '0.12.0'::text;
$$;

comment on function ekwo_schema_version() is
  'Schema version of the installed release. Bumped by a migration, never by hand.';

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every migration of this directory ends with: a function that
-- comes out with the built-in default is published by Supabase as an
-- anonymous RPC endpoint.
revoke execute on all functions in schema public from public;
grant execute on function ekwo_schema_version() to authenticated, service_role;
