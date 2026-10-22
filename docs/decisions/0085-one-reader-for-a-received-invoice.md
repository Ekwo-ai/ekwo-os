# One reader for a received invoice, and the model's part is data

> Status: accepted

## Context

A purchase reaches the books in two ways. A structured e-invoice — CII,
UBL, a PDF carrying its Factur-X XML — is read exactly by the readers of
`@ekwo-ai/factur-x` and `@ekwo-ai/peppol-ubl`, into the EN 16931
`ReceivedInvoice` (decision 0050). Everything else — a photograph of a till
receipt, a PDF that is only a picture of an invoice — is read by a vision
model.

The model path lived in each product. One web application held its schema,
its prompt and the check of the model's answer, and returned "the taxes by
rate" in a shape of its own; an older application had a reader of its own
again. A third consumer, an energy layer that needs the kWh, the meter and
the period of each line, would have needed a third reader, or would have
read the PDF a second time. Three readers disagree about what a field means,
and none of them was the `ReceivedInvoice` that the exact path returns.

## Decision

**One package reads a received invoice, both ways:
`@ekwo-ai/document-reading`, MIT, no database, no network.** It composes the
two e-invoicing bricks, which is why it is not one of them: a format library
imports no other library (decision 0048), and this one exists to choose
between them.

**The exact path is `readStructured()`.** It tells a PDF from XML by the
first bytes, CII from UBL by the root, and returns what the bricks return.
What holds no e-invoice is `undefined`, so the caller turns to the model.

**The model path is data, not a call.** The package publishes the JSON
schema a structured output is held to (`readingSchema()`), the words that go
with it (`readingPrompt()`, versioned by `READING_VERSION`) and the check of
the answer (`readingOf()`). The product makes the call: it holds the key,
chooses the model, sets the timeout and meters the tokens. A package that
called a model would carry a provider, a secret and a bill into every
installation that only wanted to read XML.

**The answer becomes the same `ReceivedInvoice`.** `syntax` gains `'model'`,
in both copies of `received.ts`. Lines carry quantity, unit code, net price,
VAT category and rate, and their period; the document carries its invoicing
period, its three totals and what is payable, the supplier's VAT and legal
identifiers, and its currency as printed. One invoice shape is checked by one
set of rules (BR-CO-10 to BR-CO-17, `checkReceived()`), and turned into a
purchase by one function, whichever way it was read.

**Copy, never compute; leave empty rather than guess.** The prompt says it,
and `readingOf()` holds the answer to it: a field not of its shape is
emptied and named in `rejected`; a field EN 16931 requires and the page did
not print is `''` and named in `missing`. No currency is assumed — not the
company's, not the country's. The arithmetic is checked only when every
figure it reads was read, since on a partial reading it would only measure
the gaps. The model rates each field (`confidence`), so a screen can point at
what to look at first.

**A caller extends the schema and gets its fields back untouched.** An energy
layer passes the meter, the bands and the contract type as JSON schema
properties; they are read in the same call, under `extension`, and returned
as the model answered them. The layer checks its own fields and never reads
the PDF again.

**The purchase draft keeps what the core has a column for, and says where
the rest goes.** `purchaseDraftOf()` writes the fields of `documents` and
`document_lines`: the unit code in `unit_code`, the references, the due date,
the tax point, the payee's IBAN. A line's quantity and price are kept where
they make its amount at the decimals of its currency, as `amount_untaxed` is
computed; otherwise the line is one unit at its amount and the invoice's own
figures are kept in `attributes`. The period of a line (BG-26) has no
column: it goes in `attributes` as `period_start` and `period_end`, which is
what that column is for. The period of the invoice (BG-14) has no column
either: each line without a period of its own takes it, which is what
EN 16931 means by it, and the draft returns it beside the lines. No
migration was added: a period column on `documents` and `document_lines`,
read and written by the e-invoicing bricks, is a change of the core of its
own, to be made when an invoice issued from the books needs to carry one.

## Consequences

- A product keeps the model call, its metering and the writes; it drops its
  schema, its prompt and its check.
- The supplier, the account and the tax are chosen from the draft by the
  product, in the company's books and pack: the package knows no chart and
  no rate.
- `ReceivedInvoice` with `syntax: 'model'` may carry `''` where the type
  says a text is required. A consumer that sorts or totals received invoices
  reads `missing` first.

## See also

- [`packages/document-reading/README.md`](../../packages/document-reading/README.md) — how a product chains the reader
- [0048](0048-format-libraries-are-mit-one-package-per-format.md) — Format libraries are MIT, one package per format
- [0050](0050-an-invoice-is-written-from-the-books.md) — An invoice file is written from the books
