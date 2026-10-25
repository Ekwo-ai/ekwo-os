-- Ekwo OS — the socle gets a schema of its own, empty for now.
--
-- The socle has lived in `public` since the first migration. `public` is the
-- schema every Postgres database starts with, and the one every extension,
-- tool and application on a shared database writes into by default: its name
-- says nothing about whom a table belongs to. The socle moves to `ekwo` in the
-- next release (decision 0090), and this file is the half of that move that
-- can ship first without changing anything that exists.
--
-- It creates the schema and gives it the rights `public` has today, and
-- nothing else: no object is created or moved here. That order is deliberate.
-- A schema has to exist before an installation can list it among the
-- schemas the Data API exposes, and the clients of this release — the command
-- line, the MCP server, `@ekwo-ai/core` — already find the socle wherever its
-- marker `ekwo_schema_version()` is: in `ekwo` once it is there, in `public`
-- until then. So an installation exposes `ekwo` now, while it is empty, and
-- the release that fills it finds every client ready for it.
--
-- Idempotent: an installation that created the schema by hand, ahead of this
-- file, ends in the same state.

create schema if not exists ekwo;

comment on schema ekwo is
  'The socle of Ekwo OS. Empty until the release that moves the socle out of public (decision 0090).';

-- ---------------------------------------------------------------------------
-- 1. Who may reach into the schema
--
-- The same three roles that reach `public` (20260914151207). `usage` is the
-- right to look a name up in the schema, not a right on what it holds: every
-- table and function still carries its own grants, by name.
-- ---------------------------------------------------------------------------

grant usage on schema ekwo to anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 2. What an object created in the schema starts with
--
-- The default privileges `public` carries today (20260911210131 and
-- 20260914151207): closed. A table, a sequence or a function created in
-- `ekwo` starts with no right for any of the three roles, and is granted in
-- its own migration or reachable by nobody. A new schema has no default
-- privilege of the project's to take back, so these lines change nothing on
-- the day they run; they say what `public` says, so that the next table
-- created in `ekwo` by any route cannot borrow a right `public` would refuse
-- it.
-- ---------------------------------------------------------------------------

alter default privileges in schema ekwo revoke all on tables    from anon, authenticated, service_role;
alter default privileges in schema ekwo revoke all on sequences from anon, authenticated, service_role;
alter default privileges in schema ekwo revoke execute on functions from public, anon, authenticated, service_role;
