# An invoice file is written from the books

> Status: accepted

## Context

Packs declare Peppol BIS 3 as their e-invoicing profile. An invoice file must
say exactly what the ledger holds, and a posted sale must be sendable from what
the core publishes, without options patched in by the caller.

## Decision

**`@ekwo-ai/peppol-ubl` writes the UBL syntax of EN 16931.** Invoicing itself
is `documents` and `post_document()` in the core; transmission through an
access point stays in `ee/`.

**It reads the rows the views publish** — `document_header`,
`document_line_items`, `document_tax_summary` — and writes the figures as
posted. It does not share the input type of the older Factur-X brick, which
computes totals and defaults a currency, unit and payment means; that brick is
the one to move to this contract.

**No figure is a `number`.** Amounts are compared as `bigint` decimals and
leave as the digits they arrived with; the brick rounds nothing it writes.

**A violation is named by its rule** (`BR-CO-15`), which is what an access
point answers. The re-reading is checked: the OASIS UBL schemas are fixtures;
code lists are generated from the Schematron and compared; the Schematron
itself, which needs an XSLT 2.0 processor the repository does not take as a
dependency, was run out of tree against a set of committed files, and the suite
pins those files and the recorded verdicts. Agreement on a finite set is not
agreement on all documents, and the README says so. Schematron without a
licence is not vendored.

**The core publishes what a sendable invoice needs.** A line keeps its category
and rate ([0015](0015-a-posted-document-is-frozen.md)); the breakdown reads the
lines; a company has an electronic address
([0041](0041-a-company-has-a-profile-and-a-first-year.md)); `document_header`
carries the tax point, delivery columns and both electronic addresses. What the
schema does not know (a deliver-to party, a location identifier) is absent, not
approximated.

**BT-120 is the sentence a customer reads, not the pack's argument.**
`document_tax_summary.exemption_reason` is the legal mention of the tax's
treatment, in the document's language, valid on its date — the text a country
already wants at the foot of the invoice. `legal_reference` is written for a
reviewer and is published beside it under its own name.
`legal_mention_treatments()` is read by both views.

**An exemption code is set only where the code list applies.** A country
outside the list it describes does not borrow its codes; each rule asks for a
code *or* a text, and the text satisfies it.

## Consequences

- A posted sale of every golden year comes out with no rule broken from three
  views and no option.
- Open: the net unit price of a price-inclusive line, a category for supplies
  outside the scope of the tax, allowances and charges.

## See also

- `packages/formats/peppol-ubl/`
- `tests/peppol_ubl.test.ts`, `tests/sendable_invoice.test.ts`
- [0033 What a country requires on a document is data](0033-what-a-country-requires-on-a-document-is-data.md)
