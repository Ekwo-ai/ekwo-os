-- Ekwo OS — the schema this release defines is 0.9.0.
--
-- `ekwo_schema_version()` is the one place the number lives, and a migration
-- is the only thing that moves it. A database then answers for the files it
-- has actually run rather than for what somebody believed it had run: the
-- column default and `init_instance()` both call this function, so a fresh
-- install records the new number without a second edit, and `ekwo migrate`
-- reads it back onto `instance.schema_version` for a database that was
-- installed at an older one.
--
-- Between 0.8.0 and here the schema gained `canonical_json()` and put it under
-- `export_company_manifest()` and `import_company()`, so that an archive
-- survives an honest reader printing it again: anything that stores or streams
-- the rows parses the JSON and writes it back, which drops the trailing zeros
-- PostgreSQL keeps inside a `jsonb` column and made a sound archive answer
-- `archive_corrupt`.
--
-- The floor of `ekwo-os`, `@ekwo-ai/core` and `@ekwo-ai/mcp` rises to 0.9.0
-- with it, as it has at every release: a 0.8.0 database is refused by name,
-- and told to run `ekwo migrate`, rather than answered for by packages that
-- were never run against it. Here that refusal is worth the trouble — an
-- archive taken from a 0.8.0 installation and read back by these packages
-- would be judged on text the older `export_company_manifest()` wrote
-- differently, and report a sound archive as corrupt.

create or replace function ekwo_schema_version()
returns text
language sql
immutable
as $$
  select '0.9.0'::text;
$$;

comment on function ekwo_schema_version() is
  'Schema version of the installed release. Bumped by a migration, never by hand.';

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every migration of this directory ends with: a function that
-- comes out with the built-in default is published by Supabase as an
-- anonymous RPC endpoint.
revoke execute on all functions in schema public from public;
grant execute on function ekwo_schema_version() to authenticated, service_role;
