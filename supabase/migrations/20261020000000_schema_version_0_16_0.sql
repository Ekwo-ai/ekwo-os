-- Ekwo OS — the schema this release defines is 0.16.0.
--
-- `ekwo_schema_version()` is the one place the number lives, and a migration
-- is the only thing that moves it. A database then answers for the files it
-- has actually run rather than for what somebody believed it had run: the
-- column default and `init_instance()` both call this function, so a fresh
-- install records the new number without a second edit, and `ekwo migrate`
-- reads it back onto `instance.schema_version` for a database that was
-- installed at an older one.
--
-- Between 0.15.1 and here a product and a document line carry the attributes
-- their electronic invoice format asks for (`products.attributes`,
-- `document_lines.attributes`), inherited from the product, copied by a credit
-- note and frozen once the document is posted; and the `crm` module arrives —
-- cards, segments, pipelines, deals and activities kept on the socle's
-- contacts, enabled by each company on its own.
--
-- The floor of `ekwo-os`, `@ekwo-ai/core` and `@ekwo-ai/mcp` rises to 0.16.0:
-- `@ekwo-ai/core` reads `document_lines.attributes` and `products.attributes`
-- to write an electronic invoice, and `@ekwo-ai/mcp` writes them, neither of
-- which a 0.15.0 database has.

create or replace function ekwo_schema_version()
returns text
language sql
immutable
as $$
  select '0.16.0'::text;
$$;

comment on function ekwo_schema_version() is
  'Schema version of the installed release. Bumped by a migration, never by hand.';

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every migration of this directory ends with: a function that
-- comes out with the built-in default is published by Supabase as an
-- anonymous RPC endpoint.
revoke execute on all functions in schema public from public;
grant execute on function ekwo_schema_version() to authenticated, service_role;
