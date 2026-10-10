# `modules/` — one Postgres schema each, beside the socle

The socle is `public`: companies, accounts, taxes, entries, documents, the
reports. What is built beside it lives here, one folder and one schema per
module.

| Module code | Folder | Schema | Posts to the ledger | Country data |
|---|---|---|---|---|
| `assets` | [`fixed-assets`](fixed-assets/) | `fixed_assets` | yes, through `post_module_entry()` | `packs/<cc>/fixed_assets.json` |
| `budgets` | [`budgets`](budgets/) | `budgets` | no | none |
| `tax` | [`corporate-tax`](corporate-tax/) | `tax` | not yet: this version estimates and keeps, the provision entry is a later one | `packs/<cc>/corporate_tax.json` |
| `einvoicing` | [`einvoicing`](einvoicing/) | `einvoicing` | no: it issues the electronic file of a posted sale and records every sending | the profile the pack declares |

`schema/module.1.json` is the published shape of a `module.json`, and
`ekwo module list` refuses one that does not match it.

## The rules, in one screen

1. **One schema, and the socle is not it.** A module depends on `public` by
   foreign key; the socle has no hook, no callback and no idea it exists.
2. **The ledger only through `post_module_entry()`.** The words `entries` and
   `entry_lines` never appear in a write statement here, and a test over every
   file of this folder refuses one that does. Reading the ledger is allowed.
3. **Row level security on every table**, through `module_enabled()` where the
   table carries a `company_id`.
4. **A module does its own grants.** `public` gets them from Supabase; a schema
   a migration created gets nothing.
5. **A country is data.** No module names one. What Belgium decides is in
   `packs/be/<section>.json` and compiles into `supabase/seed/modules/<section>/`.
6. **The registry is a table.** The last statement of a module's first
   migration writes its row into `public.modules`.

Migrations live in `<folder>/supabase/migrations/`, share the socle's history
with the module in the recorded `name`, and their timestamps sort after the
socle migration the manifest declares it needs, `requires_socle_min`. Tests live in `<folder>/tests/` and the root `npm test` runs
them. The folder is named after what the module is and need not be its code:
the code is written on every entry a module posts and never changes, a folder
and a schema may be renamed — `fixed-assets` and `fixed_assets` were both
`assets` until version 2.0.0 of that module.

The full version, and how to write a module in a day, is
[`docs/modules.md`](../docs/modules.md). Why it is shaped this way is in
[decision 0051](../docs/decisions/0051-a-module-has-its-own-schema.md).

## Planned modules

Three modules are decided and not written yet. They follow the rules above: a
schema of their own, and the ledger reached only through `post_module_entry()`.
No date is attached to them.

- **`carbon` — sustainability accounting on the same ledger.** Emissions
  accounted for as strictly as money: spend-based from the entries already
  there, activity-based from physical quantities recorded against the same
  documents, the GHG Protocol's three scopes, emission factors loaded as
  versioned data with their source, and reporting aligned on what a small
  company is actually asked for (VSME, ESRS E1). Every tonne points at the
  entry and the document that justify it.
- **`crypto` — digital assets.** Wallets and venues, acquisition lots, fair
  value at the close, and realised gains by the method the country allows —
  pack data, not a setting. The exports of platforms are read by format
  libraries, so a new venue is a package and not a fork.
- **`sign` — electronic signature, in the open.** A document, its signatories
  and where each stands, with the trail of proof written at the moment
  somebody signs. Which level of signature a deed requires is a rule of a
  country, and therefore pack data; a qualified trust provider, where one is
  needed, is chosen behind one interface.
