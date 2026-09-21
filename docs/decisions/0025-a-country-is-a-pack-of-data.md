# A country is a pack of data, compiled into SQL

> Status: accepted

## Context

An international accounting core either carries countries in code — a
`case` on a country code in every function that meets one — or describes
them as data it reads. The taxonomy that describes a country is the one part
that cannot be redone once packs exist.

## Decision

**The truth of a country lives in `packs/<cc>/`.** JSON with a published JSON
Schema (`packs/schema/pack.1.json`) for everything structured, `accounts.csv`
for the chart, `i18n/` for labels, `golden/` for expected results. No YAML, no
TOML, no package per country. `ekwo pack build` compiles a pack into a seed
SQL file that is committed; `ekwo pack check --all`, run by the CI, refuses a
seed that is not the exact output of its pack. `supabase db push` and
`psql -f` remain enough to install without the CLI. The CLI's validator walks
the subset of JSON Schema the format uses rather than adding a dependency.

**Generated seeds upsert on template tables only**, so an installed instance
receives pack changes for companies created afterwards; a company copies the
templates at install time (`install_country_template`), and
`country_packs` / `company_packs` record what the instance holds and what
each company copied, with a sha256 of the pack.

**Three rules make the taxonomy.**

1. **A pack is data and cannot execute.** No expression language, no hook: a
   formula is a list to add and a list to subtract (plus a rate of a box), a
   condition is a value from a closed list.
2. **Nothing in the core carries a country, a currency or a language of its
   own, and nothing falls back on one.** A reader that needs a value a pack did
   not give names it. `ekwo init` preselects no country, chart or language.
3. **Nothing is ever deleted from a pack.** An account is deprecated, a tax
   gets a `valid_to`, a form version gets a new code — because a past period's
   return must keep giving the same answer. Once published, an account code
   and its type, a tax code and its meaning, and a box in a form version are
   immutable.

**What a pack carries.** Beyond a chart, taxes and postings: declaration
forms and their totals; financial statements and a country-less generic
framework; several charts per country; what the country requires on a
document; labels in every declared language; filing cadences, deadlines and
rounding units; bank and e-invoicing formats; module rules (e.g. fixed-asset
conventions); and a golden year. Each was added by writing another country and
noticing what still lived in a function.

**What is deliberately not in a pack.** Rates that change monthly across tens
of thousands of jurisdictions (a feed, not reviewed data; the form still
belongs in the pack), payroll, inventory, analytics and the translation of the
application itself. Revaluation of open items, cash accounting as a ledger,
several taxes stacked on one line, and the cash-flow statement are accepted by
the format and implemented by nobody until a country needs them.

**A section validated before it is compiled is named.** The compiler lists
every section it skipped, in its output and in each seed header, so nothing is
dropped silently.

## Consequences

- Adding a country needs no migration, no function and no change to the test
  runner; gaps a pack meets are written in `international.md` with the
  workaround used.
- A pack whose country has no legal chart is valid; the chart is whatever the
  pack's sources support.
- Published migrations are never edited; comments in them that became inexact
  are corrected in documentation, not in the file.

## See also

- [`packs.md`](../packs.md) — the format file by file, every rule of
  `ekwo pack check`, and a walkthrough for adding a country
- [0026 Certification names a reviewer](0026-certification-names-a-reviewer.md)
- [0029 A golden year is the contract of a pack](0029-a-golden-year-is-the-contract-of-a-pack.md)
- `tests/packs.test.ts`, `tests/seeds.test.ts`
