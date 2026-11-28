# Format libraries

Write and read the files your administration, your bank and your customers
expect, from any book-keeping system. You get one npm package per file format,
organised **by format and never by country**. Factur-X is French and German,
UBL is universal, camt.053 is European, so each format stands on its own. A
country's pack says which formats it uses — its e-invoicing profile, its bank
statement formats, its declaration.

Each package here:

- is **MIT**, with its own `LICENSE` file, so you can use it anywhere,
  including inside other software;
- **stands alone**: it imports nothing from the core — not `@ekwo-ai/core`,
  not the schema, not another library;
- declares the **flat row shapes** it reads or returns in its own types, so any
  book-keeping system that can produce those columns can use it;
- reports what does not add up in `violations[]`, and leaves the correction to
  you.

## What is here

**Written from the ledger.** They read the rows the core's reports return —
`financial_statement()`, `vat_return()`, `ec_sales_list()`, `fec_lines()`, the
`document_*` views — and produce the bytes and the file name an administration
expects:

| Package | Format |
|---|---|
| [`fec`](fec/) | The French *fichier des écritures comptables* |
| [`xbrl-cbso`](xbrl-cbso/) | XBRL annual accounts, NBB / CBSO taxonomy |
| [`vat-consignment`](vat-consignment/) | A periodic VAT return, written from the figures it was filed with |
| [`intra-consignment`](intra-consignment/), [`des`](des/), [`ecdf`](ecdf/), [`vd`](vd/) | Four recapitulative statements of European Union supplies, from the same rows of `ec_sales_list()` |

**Electronic invoices, written and read.** Each writes the file of a posted
invoice and lists every published rule it breaks by its identifier; each also
reads a received invoice into the same `ReceivedInvoice` shape — parties,
dates, lines, VAT breakdown, totals as exact decimal text, attachments — so a
received invoice becomes a purchase draft the same way whichever syntax carried
it.

| Package | Format |
|---|---|
| [`peppol-ubl`](peppol-ubl/) | Peppol BIS Billing 3.0 (UBL 2.1), with participant identifiers checked offline |
| [`factur-x`](factur-x/) | Factur-X and ZUGFeRD: EN 16931 CII XML, embedded in and extracted from a PDF/A-3 |

**Electronic invoices cleared before they are issued.** An administration that
validates every invoice before it is the taxpayer's gets the document from the
same rows; signing it, submitting it and keeping the identifier the
administration returns belong to the host:

| Package | Format |
|---|---|
| [`myinvois`](myinvois/) | The Malaysian MyInvois e-Invoice of LHDNM (UBL 2.1, JSON or XML): invoices, credit, debit and refund notes, the supplier's or self-billed |

**Invoicing records, written.** An administration that wants every invoice
recorded as it is issued, chained to the one before, gets the record from the
same rows; keeping the chain and sending the record belong to the host:

| Package | Format |
|---|---|
| [`verifactu`](verifactu/) | The Spanish VERI\*FACTU *registro de facturación*, with its chained SHA-256 fingerprint and the URL of its QR code |

**Bank statements, read.** They return statements and lines under the same
field names, which is what `import_bank_statement()` takes:

| Package | Format |
|---|---|
| [`camt053`](camt053/) | ISO 20022 camt.053 |
| [`coda`](coda/) | CODA |
| [`cfonb120`](cfonb120/) | CFONB 120 |
| [`csv-statement`](csv-statement/) | CSV, described by a column profile the caller gives: a bank, a payment service, a card |

**Books kept elsewhere, read.** They return accounts, parties, entries and an
opening balance under the same names, which is what `import_books()` takes once
the codes are translated into a company's chart. They are named after the file,
never after the software that writes it:

| Package | Format |
|---|---|
| [`trial-balance`](trial-balance/) | A trial balance as CSV, and the open items beside it |
| [`journal-items`](journal-items/) | The lines of every entry, exported as CSV from a ledger kept as a table of lines |
| [`journal-report`](journal-report/) | A journal report or general ledger detail saved as CSV |
| [`transaction-journal`](transaction-journal/) | A transaction journal saved as CSV |
| [`xaf`](xaf/) | XML Audit File Financial, versions 3.2 and 4.0 |
| [`fec`](fec/) | The FEC, read back with `readFec()` |

Every file from outside is read safely: the XML readers refuse DTDs and
external entities and bound size and depth, and the fixed-width and CSV readers
use the encoding they are told and never guess it.

## Why no shared abstraction

Each format gets its own package, written to its own specification, with no
`Filing` interface, plugin registry or common `xml` package between them. Two
formats that look alike still differ: the four recapitulative statements read
the same rows and disagree on lines, columns, number formats and how a VAT
number is written. Each package says, in its README, which official pages the
format was read from.

**Invoices, drawn.** It renders the visual PDF of a sale invoice or credit note
from the rows of the `document_*` views, PDF/A-3b, with no country in its
layout. A Factur-X PDF is made by handing it `embedFacturX`:

| Package | Format |
|---|---|
| [`invoice-pdf`](invoice-pdf/) | The PDF of an invoice or credit note, PDF/A-3b, fonts embedded |

`tests/formats.test.ts` enforces the licence, the isolation and the
dependencies of every package in this directory, and `tests/` carries an
end-to-end test per package, from a country pack's year of books through the
real engine into the file.
