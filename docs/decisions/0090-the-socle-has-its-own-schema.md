# The socle has its own schema

> Status: proposed

## Context

The socle — the companies, the ledger, the documents, the taxes, the reports
and every function that guards them — was created in `public`, and
[0051](0051-a-module-has-its-own-schema.md) kept it there while each module
got a schema of its own.

`public` is the schema every Postgres database starts with, and on Supabase
the one every extension, tool and application writes into when it names no
other. Its name says nothing about whom a table belongs to. A database that
carries Ekwo OS beside another application — a second core, a customer
portal, the tables of a product built on top — holds two `companies`, two
`contacts` or two `documents` in one namespace, or has to rename one of them.
Every module already points at the socle by name (`public.companies`,
`public.round_amount()`), and every new module and integration adds to the
names that would have to change later. The schema is easiest to give the socle
before the promises of 1.0 freeze the names it is reached by.

`alter … set schema` moves a table, a view, a type or a function and keeps its
identity: foreign keys, indexes, policies, triggers, privileges, defaults and
the views over it stay valid. What it does not rewrite is text: the
`search_path` of each function, the `public.x` written in function bodies and
in strings, the `pgrst.db_pre_request` setting, the privileges of the schema
itself and the list of schemas the Data API exposes, which is a setting of the
project and not of the database.

## Decision

**The socle lives in the schema `ekwo`.** Each module keeps its own schema;
the registry, `post_module_entry()` and everything else 0051 decides stay as
they are. `public` is left to whoever else shares the database.

**Clients find the socle by its marker, never by assumption.** The function
that carries the schema's version, `ekwo_schema_version()`, is looked for in
`ekwo`; present, the socle is there, absent, it is in `public`. No other schema
is tried. `@ekwo-ai/core` resolves it once per connection
(`socleSchemaResolver()`), and every backend — PostgREST and direct SQL, in
the MCP server and in the command line — names the resolved schema on every
call: `Accept-Profile` / `Content-Profile` over PostgREST, a qualified name
over SQL. No call rests on whichever schema a project lists first.

**The SQL the command line runs as the owner follows the socle.** Its
connection puts the socle's schema first on `search_path`, asked again after
the migrations, so the seeds and the unqualified statements land in the socle
in either layout.

**The move is two releases.** The first is additive: the empty schema `ekwo`
with the usage grants and the closed default privileges `public` carries, and
clients that read either layout. An installation exposes `ekwo` to the Data
API while it is still empty. The second moves the objects, by the exact list
of the generated inventory — never "everything in `public`", which on a shared
database holds other things — rewrites the function settings and bodies that
name `public`, and recreates the functions of the modules that do.

**Archives keep their former names readable.** An archive written before the
move names its tables `public.<table>`; `import_company()` reads them under
the names of the release that imports them, so the archives already kept
remain importable.

## Consequences

- The Data API has to serve `ekwo` before the release that moves the socle:
  Project Settings → Data API → Exposed schemas, or `schemas` under `[api]` in
  `supabase/config.toml` for a local stack. No migration can do it.
  `ekwo migrate` prints the line; `ekwo doctor` reports `socle_schema` and
  `ekwo_exposed`, reading `pgrst.db_schemas` where the database carries it.
- SQL written by hand against an installation names `ekwo.<table>` after the
  move. Unqualified SQL keeps working through the role's `search_path` for one
  release at least.
- A client older than the release that moves the socle reads `public` and finds
  nothing there. `@latest` is the rule for the command line and the MCP server.
- When the move ships, 0051 is superseded in part — its sentence on the socle
  only — and this record becomes `accepted`.

## See also

- [0051](0051-a-module-has-its-own-schema.md) — A module has its own schema and posts through a function
- [0003](0003-the-schema-grants-its-own-rights.md) — The schema grants its own rights
- [0058](0058-doctor-compares-against-a-generated-inventory.md) — `ekwo doctor` compares against a generated inventory
