# A golden year is the contract of a pack

> Status: accepted

## Context

A tax that posts to the wrong grid and a grid that expects the wrong postings
agree with each other: the seed compiles, `ekwo pack check` is silent, unit
tests pass, and the return is wrong. And a test suite that lists countries by
hand never looks at a new pack.

## Decision

**A pack carries a year of books and the figures they produce.**
`golden/scenario.json` holds at least ten documents and payments, declarative
like the rest of the pack. Beside it, generated and never hand-written:
`vat_return.json`, `statements.json` and `trial_balance.json`, to the cent.
`UPDATE_GOLDEN=1` rewrites those three and never the scenario.

**One runner, no country in it.** `tests/golden.test.ts` installs a company on
each pack from its own scenario, replays it through `post_document`,
`post_payment` and `reconcile`, and compares. What it demands of a scenario it
demands of the pack (a tax due on collection is required of a scenario whose
pack has one).

**A pack with no golden is refused**, unless its manifest states why in a
sentence the commands print (the generic framework has no chart, journal, tax
or currency to install a company on).

**Expectations are outside the pack checksum; the scenario is inside.** A
scenario is a decision about a country's books; its expectations are a build
artefact of the engine.

**A golden proves coherence, not legal truth.** A box expected wrongly and a
posting written wrongly pass together. Required legal references, the
certification status and CODEOWNERS carry the rest. A golden adjusted until it
passes records a bug: a figure the golden shows to be wrong is reported to the
pack's reviewers, not silently corrected.

**A test may book in a country; it may not expect one.** Setting up may name a
country — a scenario has to book somewhere. What a test asserts about the core
comes from the packs. `tests/helpers/packs.ts` offers `allPacks`,
`packWhere(property, …)` (which throws, naming the property, when no pack has
it) and `somePack`. A claim only one pack can make lives in that pack's
`golden/expectations.json`, not in a per-country test file. A CI guard
(`check:no-country-literals`) refuses a country code inside `expect(…)`, a
list of country codes, or a pack named where `listPacks()` would find it.

**How far a pack got is the assertion.** `filingReadiness()` reads from the
pack whether it can freeze a return, write its file and settle it; the filing
test walks each pack as far as it can, prints what it reached, and refuses a
checkout where no pack does all three.

## Consequences

- Adding a pack adds it to every generic test without editing a test file.
- A golden figure that looks wrong is a question for the pack's reviewer, not a number to adjust.

## See also

- `tests/golden.test.ts`, `tests/filing_golden.test.ts`,
  `tests/helpers/packs.ts`, `scripts/check-no-country-literals-in-tests.mjs`
- [0026 Certification names a reviewer](0026-certification-names-a-reviewer.md)
