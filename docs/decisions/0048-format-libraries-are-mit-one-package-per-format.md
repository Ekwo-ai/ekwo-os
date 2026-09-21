# Format libraries are MIT, one package per format

> Status: accepted

## Context

A country is data; a file format is code, and a format is not a country:
Factur-X spans countries, UBL is universal, camt.053 is European.

## Decision

**Organised by format under `packages/formats/`, never by country.** The pack
says which formats a country uses (`einvoice_profile`, bank format lists,
`file_format` on a form).

**In this repository**, because a taxonomy change is then one pull request and
the golden test that proves a pack and a brick agree can only run where both
are.

**Each package keeps its own MIT `LICENSE`, imports nothing from the core or
another brick, and declares the row shapes it reads (or returns) in its own
types.** A test enforces all three. A shared rule (rounding) is therefore a
byte-identical copy, compared by a test.

**The truth of a mapping stays in the pack.** A brick carries only the
official taxonomy, generated from the published package, and `ekwo pack check`
resolves every key against it.

**A brick declares no `schema_min`.** The contract is the shape of the rows,
and the end-to-end test breaks when it moves.

**A brick reads the flat rows the views publish and writes the figures as
posted.** It computes no total and defaults no currency, unit or payment
means: a file that recomputes can disagree with the ledger, and a default is a
value nobody chose. No figure is a JavaScript `number`.

**Zero runtime dependencies.** Validators, schemas and reference files are
test fixtures or development dependencies, never shipped.

**The `formats` topic of the site lists each directory**, so a brick added
there is documented with nothing else edited.

## Consequences

- A format can be used outside Ekwo without the core or its licence.
- Duplicated helpers are pinned by tests instead of shared as code.

## See also

- [`packages/formats/README.md`](../../packages/formats/README.md)
- [0061 Licensing and the open-core line](0061-licensing-and-the-open-core-line.md)
- `tests/formats.test.ts`
