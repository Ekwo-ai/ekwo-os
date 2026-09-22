-- Ekwo OS — the schema this release defines is 0.7.0.
--
-- `ekwo_schema_version()` is the one place the number lives, and a migration
-- is the only thing that moves it. A database then answers for the files it
-- has actually run rather than for what somebody believed it had run: the
-- column default and `init_instance()` both call this function, so a fresh
-- install records the new number without a second edit, and `ekwo migrate`
-- reads it back onto `instance.schema_version` for a database that was
-- installed at an older one.
--
-- Between 0.6.0 and here the schema gained two things. `instance.country` is
-- nullable, because `ekwo init --no-company` installs without a company and
-- so without a country to write down; `ekwo company new` then creates each
-- company in its own country through `create_company()`. And `import_books()`
-- says, when it refuses files it has already imported, which files, read as
-- which source, when, and what that import wrote. A 0.6.0 database has
-- neither. The packages of this release call no function a 0.6.0 database
-- lacks, but they are built and tested against the installation these two
-- migrations leave, and `ekwo migrate` brings a 0.6.0 one there in a second:
-- so the packages declare 0.7.0 as their floor and refuse an older database by
-- name, as every release has, rather than answering for one they were never
-- run against.

create or replace function ekwo_schema_version()
returns text
language sql
immutable
as $$
  select '0.7.0'::text;
$$;

comment on function ekwo_schema_version() is
  'Schema version of the installed release. Bumped by a migration, never by hand.';

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every migration of this directory ends with: a function that
-- comes out with the built-in default is published by Supabase as an
-- anonymous RPC endpoint.
revoke execute on all functions in schema public from public;
grant execute on function ekwo_schema_version() to authenticated, service_role;
