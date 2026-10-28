# The socle has its own schema

> Status: accepted
>
> The socle moved on 28 October 2026, migration `20261028040000`.

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

## Outcome

The second release is `20261028040000_the_socle_moves_to_its_schema.sql`
(0.23.0). It moves the objects by the inventory's list — 81 tables and the
one sequence no table owns, 6 views, 45 types, 355 function names — with
`alter … set schema`, then reads every function of the socle and of the
installed modules that names `public` back from the catalogue and writes it
again with `ekwo`: `public.<name>` becomes `ekwo.<name>` and the string
`'public'` becomes `'ekwo'`, in a `search_path` setting as in the archive
functions that compare a schema by name. The archive registry is moved and
`archive_under_current_names()` reads a `public.<table>` of the socle as
`ekwo.<table>`, so the archives written before keep importing.
`pgrst.db_pre_request` names `ekwo.ekwo_pre_request`. The connection that ran
the file goes on with `ekwo` first on its path, and the owner's role gets the
same default.

A module's published files still say `public.`; whoever applies one reads it
for the socle's schema of the day (`socleNamed()`, in `@ekwo-ai/core`), so a
fresh installation runs them after the move unchanged on disk. A module
function that carried no path got one — its schema, then `ekwo` — because a
request served under a module's profile has the module on its path and the
socle no longer; the socle's own functions got the same, `ekwo` first — the plpgsql
ones, and the SQL helpers a policy folds in, because a policy of a module
folds `module_enabled()` into its query and that helper then looked for
`is_company_member()` on the path of the request. The planner calls those
helpers per row where it used to inline them; the SQL readers a report folds
into one plan keep no path and stay inlined, and `tests/load` holds the
planner to its indexes. The command line and the MCP
server still put the socle first on their connection, and the owner's role
carries it by default, for the SQL a person types. The floor of
the packages stayed at 0.19.0: a database before the move is read exactly as
before.

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
