-- Ekwo OS — the schema this release defines is 0.5.0.
--
-- `ekwo_schema_version()` is the one place the number lives, and a migration
-- is the only thing that moves it. A database then answers for the files it
-- has actually run rather than for what somebody believed it had run: the
-- column default and `init_instance()` both call this function, so a fresh
-- install records the new number without a second edit, and `ekwo migrate`
-- reads it back onto `instance.schema_version` for a database that was
-- installed at an older one.
--
-- Between 0.4.0 and here the schema learnt to undo what is posted and to say
-- what a country pack used to leave unsaid. The packages of this release read
-- it, and a 0.4.0 database has none of it: `cancel_document()` and
-- `reverse_entry()`, which the command line and the MCP server offer as
-- `cancel` and `reverse`; `unpost_document()`, `unpost_refusal()` and
-- `document_unpostings`, with `country_defaults.posted_edit_policy` that says
-- where a posted document may go back to draft; the `depends_on_taxpayer`
-- deadline rule and `country_defaults.einvoice_obligation`; the `bimonth`,
-- `four_month` and `half_year` cadences with `declaration_period_months()`,
-- and a box frozen at the unit of its form; and a supply measured against its
-- seller, with the territories a posted document was judged on kept on it. So
-- the packages declare 0.5.0 as their floor and refuse an older database by
-- name, rather than improvising over a function that is not there.

create or replace function ekwo_schema_version()
returns text
language sql
immutable
as $$
  select '0.5.0'::text;
$$;

comment on function ekwo_schema_version() is
  'Schema version of the installed release. Bumped by a migration, never by hand.';

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every migration of this directory ends with: a function that
-- comes out with the built-in default is published by Supabase as an
-- anonymous RPC endpoint.
revoke execute on all functions in schema public from public;
grant execute on function ekwo_schema_version() to authenticated, service_role;
