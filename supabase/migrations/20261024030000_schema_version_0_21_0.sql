-- Ekwo OS — the schema this release defines is 0.21.0.
--
-- `ekwo_schema_version()` is the one place the number lives, and a migration
-- is the only thing that moves it. A database then answers for the files it
-- has actually run rather than for what somebody believed it had run: the
-- column default and `init_instance()` both call this function, so a fresh
-- install records the new number without a second edit, and `ekwo migrate`
-- reads it back onto `instance.schema_version` for a database that was
-- installed at an older one.
--
-- Between 0.20.0 and here a draft changes its lines in one statement
-- (`replace_document_lines()`, `create_document()`), an agent posts in the
-- mode its company chose (`companies.agent_posting`, `agent_posting_mode()`,
-- `approve_document()`, `api_keys.posting_mode`), and a monthly depreciation
-- schedule runs while the asset is in service (module `assets`).
--
-- The floor of `ekwo-os`, `@ekwo-ai/core` and `@ekwo-ai/mcp` rises to 0.21.0:
-- `@ekwo-ai/core` calls `replace_document_lines()`, `create_document()` and
-- `approve_document()`, which a 0.20.0 database does not have, and the three
-- packages declare one floor.

create or replace function ekwo_schema_version()
returns text
language sql
immutable
as $$
  select '0.21.0'::text;
$$;

comment on function ekwo_schema_version() is
  'Schema version of the installed release. Bumped by a migration, never by hand.';

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every migration of this directory ends with: a function that
-- comes out with the built-in default is published by Supabase as an
-- anonymous RPC endpoint.
revoke execute on all functions in schema public from public;
grant execute on function ekwo_schema_version() to authenticated, service_role;
