-- Ekwo OS — the schema this release defines is 0.6.0.
--
-- `ekwo_schema_version()` is the one place the number lives, and a migration
-- is the only thing that moves it. A database then answers for the files it
-- has actually run rather than for what somebody believed it had run: the
-- column default and `init_instance()` both call this function, so a fresh
-- install records the new number without a second edit, and `ekwo migrate`
-- reads it back onto `instance.schema_version` for a database that was
-- installed at an older one.
--
-- Between 0.5.0 and here the schema learnt to take over books kept elsewhere:
-- `import_books()`, which opens the fiscal years asked for through
-- `import_fiscal_year_for()`, finds or creates the parties, posts every entry
-- through `post_entry()` and a balance through `opening_balance()` in one
-- transaction, and `book_imports`, which records each import and refuses the
-- same files twice. `ekwo import` and the `import_books` tool of the MCP
-- server call it, and a 0.5.0 database has none of it. So the packages
-- declare 0.6.0 as their floor and refuse an older database by name, rather
-- than improvising over a function that is not there.

create or replace function ekwo_schema_version()
returns text
language sql
immutable
as $$
  select '0.6.0'::text;
$$;

comment on function ekwo_schema_version() is
  'Schema version of the installed release. Bumped by a migration, never by hand.';

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every migration of this directory ends with: a function that
-- comes out with the built-in default is published by Supabase as an
-- anonymous RPC endpoint.
revoke execute on all functions in schema public from public;
grant execute on function ekwo_schema_version() to authenticated, service_role;
