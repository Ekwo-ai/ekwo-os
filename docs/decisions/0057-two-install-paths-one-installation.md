# Two install paths make one installation

> Status: accepted

## Context

`npx ekwo init` and `supabase db push` followed by `psql -f` are documented as
interchangeable. That is a claim about the state of a database, and a claim
nothing checks drifts.

## Decision

**Build one of each and compare.** `tests/e2e/install_parity.test.ts`
compares migration history, the columns of every table, the body of every
function and every seeded row, rendered as sorted JSON. The by-hand path
imports nothing from `packages/cli`. The list of seeded tables is read from the
seeds. Surrogate ids, clock columns and uuid foreign keys between templates are
left out by name — the dump demands a natural key rather than compare two
random numbers.

**The README is tested.** Every seed file the installer applies must be named
in the by-hand instructions; a missing one silently yields an installation
without, for example, the generic statements.

**The year is played out.** `tests/e2e/lifecycle.test.ts` starts from the
first published seeds, migrates to the current release, upgrades the pack,
then does a year — opening balance, a sale, a purchase, the return, both
statements, the close, the reopening, the close again — once per country the
seeds carry, naming none.

**Every figure is compared to one the test works out itself.**
`tests/e2e/expected.ts` starts from `sum(debit) − sum(credit)` and the pack's
rows and rebuilds the answer in TypeScript. It follows the same rules, because
the rules are the specification; it cannot share a bug with the SQL. Rounding
is the one shared piece.

**What only a real project proves is run by hand.** PGlite is not the published
binary over a pooler, not PostgREST, not GoTrue and not a hosted project's
roles. `scripts/e2e-supabase.mjs` covers those against a real, disposable
project before a release is tagged; it costs money and never runs in the CI.
It refuses a non-empty database, deletes nothing on its own, and its `--reset`
is deliberately not an `ekwo` command.

## Consequences

- A drift between the two install paths, or in the README, fails the build.
- Behaviour only a hosted project shows is checked before each release, by hand.

## See also

- `tests/e2e/`, `scripts/e2e-supabase.mjs`
- [0052 The installer](0052-the-installer-needs-only-node-and-a-customer-project.md)
- [0003 The schema grants its own rights](0003-the-schema-grants-its-own-rights.md)
