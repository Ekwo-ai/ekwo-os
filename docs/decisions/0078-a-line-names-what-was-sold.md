# A line names what was sold, by the classification its country declares

> Status: accepted

## Context

An invoice of goods often has to say what the goods are, by the code of a
nomenclature. The Harmonized System of the World Customs Organization gives
six digits; national extensions add two or four — the Combined Nomenclature
an Intrastat return asks for, the Mercosur Common Nomenclature (NCM, eight
digits) that a Brazilian electronic invoice carries on every item; an
authority's own e-invoicing format may keep a list of its own, as MyInvois
does with its classification codes. EN 16931 carries any of them as BT-158,
the item classification identifier, with its scheme in BT-158-1 (UNTDID
7143).

The books held none of it. `products` names the seller's own code (BT-155,
decision 0044). The `line_attributes` of a fiscalisation regime give every
line of a country one constant value: a default for a format, not a fact about
what a line sold. The identifiers of a party (`companies.identifiers`,
`contacts.identifiers`) had already settled the same question for parties: a
fact the formats of several countries ask for under different names is kept
by the code of its scheme, in one column, and the pack says which schemes its
country reads.

## Decision

**A pack declares the classifications its country uses, and a line carries
its codes by scheme.**

- `pack.json` `classifications` lists the schemes: the code a format knows it
  by, its name, the anchored pattern every code matches, the text that
  prescribes it and its source. It compiles into `classification_schemes`,
  reference data keyed by country and scheme.
- `products.classifications` and `document_lines.classifications` hold
  `{"<scheme>": "<code>"}`, an object of non-blank texts — a code is written as
  its nomenclature writes it, leading zeros included. A line that names a
  product and no code of its own takes the product's on insert; after that the
  codes are the line's, and a posted line keeps them like every other column.
- `assert_classifications()` is the one check, asked by a trigger on each
  table: a scheme the pack of the company's country does not declare is
  refused, `classification_scheme_unknown`, naming the ones it does; a code off
  its pattern is refused, `classification_code_invalid`.
- `document_line_items.classifications` publishes the codes beside the line
  they describe, and the e-invoicing source reads them. A format writes the
  scheme it knows: the MyInvois writer writes a line's `CLASS` code over the
  default of its regime's `line_attributes`.

Nothing in the schema names a country, a nomenclature or a format: the scheme
codes are the pack's, and the patterns with them.

## Consequences

- One column serves the customs nomenclatures, their national extensions and
  the lists of national formats, several on one line where a country asks for
  more than one.
- No pack of this repository declares a classification, and the compiler
  writes `classification_schemes` only for a pack that declares the key, so
  every seed is byte for byte what it was. A pack that declares the key says
  the whole list, and a scheme it stops declaring is removed.
- A code is checked against its pattern, never against the nomenclature
  itself: the tables of the Harmonized System and of its extensions change
  every few years and are thousands of rows, and a short list in the database
  would refuse legitimate codes. The pattern catches the typing error; the
  code's meaning is the seller's to answer for.
- The Peppol and Factur-X writers do not write BT-158 yet: the column is there
  for them to read when a pack that issues in them declares a classification.

## See also

- `supabase/migrations/20261019195512_a_line_names_what_was_sold.sql`
- `tests/line_classifications.test.ts`, `tests/clearance_issue.test.ts`
- [0044](0044-a-product-is-a-catalogue-entry-in-the-core.md) — A product is a catalogue entry in the core, not stock
- [0025](0025-a-country-is-a-pack-of-data.md) — A country is a pack of data
- [`docs/packs.md`](../packs.md#what-was-sold-by-the-classification-of-the-country-classifications)
