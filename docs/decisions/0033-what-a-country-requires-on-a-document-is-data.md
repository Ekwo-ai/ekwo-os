# What a country requires on a document is data

> Status: accepted

## Context

An invoice is where a country speaks loudest: the numbering, the legal payment
term, the tax point, the e-invoicing profile, bank formats and the sentences
the law requires. If none of it is in the pack, a renderer prints
"Autoliquidation" from its own source, or nothing.

## Decision

**Country columns and a table of sentences, read by views; nothing
executable.** `country_defaults` gains the document rules; `legal_mention_templates`
holds the sentences; `document_legal_mentions` and the enriched document views
read them. A test asserts that no function body branches on these columns
beyond their designated readers.

**`numbering_gapless` and `number_format` are two questions**: whether a
number may skip is law; what it looks like is a pattern (see
[0012](0012-a-number-follows-the-pattern-of-its-country.md)).

**The tax point rule is the country's general rule; the exception is on the
tax.** `tax_point_rule` takes `invoice_date`, `delivery_date`, `payment_date`,
`invoice_if_issued`, `earliest_of_delivery_or_payment`. `tax_point_of()` is
its only reader; `post_document()` dates a tax by it and `vat_return()` files
by it. A service rule that differs is `taxes.cash_basis`, not a second country
column.

**`party_scheme` and `vat_scheme` are different identifiers**, four-digit
codes of the EAS list (which contains ISO 6523 and more). They are defaults an
application may propose, not anybody's address.

**`applies_when` of a mention is a closed vocabulary, never an expression.**
Most values are resolved from the treatment of the taxes on the document's
lines, so nothing new is recorded on a document for its mentions to be right.
`late_payment` depends on direction (only on what a seller issues). A new value
is a discussion about the core.

**`small_business` is data the view never selects**, and a test says so: a
franchise regime is a property of the seller the core does not record.

**Mentions are not copied into a company**, and the view joins on the
document's own date, so a reprint carries the wording of its year.

**The country of a document is the company's `fiscal_country`**, not its
address.

**The generated seed writes these columns with an `update`** of the row it
created, so the compiler's blocks stay independent.

**What a pack may declare is checked before a seed exists**: closed
vocabularies in the JSON Schema; duplicate codes, backward validities,
mentions without a legal reference, unknown number tokens, and an obligation
date with no profile in the reader.

**What a pack does not assert.** A seller's commercial choices (early-payment
discount wording), obligations that depend on company size the core does not
hold (the date in the column is the one that binds everybody), and sentences
the law does not prescribe are left out: a sentence written by the project is
not data.

## Consequences

- A renderer and the e-invoice bricks read one set of views and never hold country sentences.
- A reprint of an old invoice carries the wording of its own date.

## See also

- `tests/document_rules.test.ts`, `tests/tax_point.test.ts`
- [0050 An invoice is written from the books](0050-an-invoice-is-written-from-the-books.md)
- [`international.md`](../international.md)
