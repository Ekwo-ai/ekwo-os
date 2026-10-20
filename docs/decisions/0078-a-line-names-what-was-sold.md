# A line names what was sold, by the classification its country declares

> Status: accepted

## Context

An invoice of goods often has to say what the goods are, by the code of a
nomenclature. The Harmonized System of the World Customs Organization gives
six digits; national extensions add two or four — the Combined Nomenclature
an Intrastat return asks for, the Mercosur Common Nomenclature (eight digits)
that the electronic invoices of its member states carry on every item; an
authority's own e-invoicing format may keep a list of its own, as MyInvois
does with its classification codes. EN 16931 carries any of them as BT-158,
the item classification identifier, with its scheme in BT-158-1 (UNTDID
7143).

The line already has the place for such a code. Migration `20261019170000`
gave `products.attributes` and `document_lines.attributes`,
`{"<name>": "<value>"}`: what an electronic invoice format asks of a line that
no other column says, under the name the brick of the format reads,
pre-filled from the product, copied by a credit note and frozen once the
document is posted. The MyInvois classification of a line is one of them.

A first draft of this decision added a second place —
`products.classifications` and `document_lines.classifications`, by scheme —
for the same fact. Two columns that can each hold the code of a line are two
answers to one question, and one day they disagree. What `attributes` lacked
was narrower: nothing said a code of a nomenclature has a shape, so a typing
error went out on the invoice and came back as a rejection of the authority.

## Decision

**A classification is an attribute of the line, and the pack declares the
pattern of its codes.**

- `pack.json` `classifications` lists, for the attributes that hold the code
  of a classification, the attribute's name, the name of the classification,
  the anchored pattern every code matches, the text that prescribes it and its
  source. It compiles into `classification_schemes`, reference data keyed by
  country and attribute.
- The code itself stays where the line keeps everything its format asks:
  `document_lines.attributes`, pre-filled from `products.attributes`. Nothing
  else holds it.
- `assert_classifications()` is the one check, asked by a trigger on each
  table, after the product has pre-filled the line: a code held under the name
  of a classification of the company's fiscal country and off its pattern is
  refused, `classification_code_invalid`. An attribute of any other name is the
  format's own business and passes, as before.

Nothing in the schema names a country, a nomenclature or a format: the names
of the attributes are the pack's, and the patterns with them.

## Consequences

- One column holds every fact a format asks of a line, classification codes
  included; one table says which of them have a shape to check.
- No pack of this repository declares a classification, and the compiler
  writes `classification_schemes` only for a pack that declares the key, so
  every seed is byte for byte what it was. A pack that declares the key says
  the whole list, and a classification it stops declaring is removed.
- A code is checked against its pattern, never against the nomenclature
  itself: the tables of the Harmonized System and of its extensions change
  every few years and are thousands of rows, and a short list in the database
  would refuse legitimate codes. The pattern catches the typing error; the
  code's meaning is the seller's to answer for.
- An attribute name the pack does not declare is not refused: attributes also
  hold the reason of an exemption and other free texts of a format, which have
  no pattern.
- The Peppol and Factur-X writers do not write BT-158 yet: the attribute is
  there for them to read when a pack that issues in them declares a
  classification.

## See also

- `supabase/migrations/20261019170000_a_line_carries_what_its_format_asks.sql`
- `supabase/migrations/20261020072100_a_classification_is_checked_on_its_attribute.sql`
- `tests/line_classifications.test.ts`
- [0044](0044-a-product-is-a-catalogue-entry-in-the-core.md) — A product is a catalogue entry in the core, not stock
- [0025](0025-a-country-is-a-pack-of-data.md) — A country is a pack of data
- [`docs/packs.md`](../packs.md#what-was-sold-by-the-classification-of-the-country-classifications)
