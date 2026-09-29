# A module code outlives its names

> Status: accepted

## Context

The first module was called `assets`: its code, its schema, its main table,
the prefix of its MCP tools and the section of a country pack. It keeps fixed
assets only. In accounting English *assets* is the whole left side of the
balance sheet — cash, receivables, stock — and a stock register is the next
module to be written, which holds assets as well. The name was wrong the day a
second kind of asset had to be named beside it.

A module's names are not all of the same kind. Its code is the key of
`public.modules`, of `company_modules`, of the capabilities it declares, and it
is written on every entry it posts, in `entries.module_code`. A posted entry
does not move, for anybody ([decision 0014](0014-a-posted-entry-is-immutable.md)
and the guard of `20260918161538`). Its schema, its tables and its functions are
names an API client calls.

## Decision

**The code is permanent; every other name may be made more precise.** The
schema, the tables, the functions, the constraints, the policies, the MCP
prefix, the pack section and the folder of the module are renamed by a
migration and a release. The code is not: renaming it would mean rewriting the
tag of posted entries, in closed years and filed periods, which is exactly what
the ledger refuses.

**A rename happens in place, in one idempotent migration.** `alter schema …
rename` and `alter table … rename` keep the rows, the keys, the policies and
the privileges. Every function is written again, because a function body is
text and keeps the old names otherwise. Each step looks for the old name first,
so running it twice changes nothing, and a fresh installation — which applies
it after the migrations that created the old names — reaches the catalogue an
upgraded one does. A test holds the two to each other and the figures to the
cent.

**What was published under the old name keeps working for one release.** MCP
tools are registered under their former prefix too, with a description that
says they are deprecated and when they go. A company archive written under the
old table names is read under the new ones, through a convention the module
answers — `<schema>.archive_former_names()` — so the socle names no module.

**The folder is named after what a module is, not after its code.**
`modules/fixed-assets/` carries the module whose code is `assets`; the
manifest says which, and the command line finds a module by either.

## Consequences

- `ekwo module enable assets` and the capabilities `assets.read`,
  `assets.write` and `assets.post` keep their names, and so does every right a
  member or a key holds. The code reads less precisely than the rest; it is the
  one name that cannot be corrected, and the manifest says so.
- An operator has one thing to do by hand after the migration: expose the new
  schema to the API. `ekwo migrate` says so when it has renamed one.
- A pack section is renamed with the module, so a pack outside this repository
  renames its file; `ekwo pack check` names the old one rather than ignoring it.

## See also

- [0051 A module has its own schema](0051-a-module-has-its-own-schema.md)
- [`modules.md`](../modules.md), "Renaming what a module owns"
- `modules/fixed-assets/tests/rename_upgrade.test.ts`
