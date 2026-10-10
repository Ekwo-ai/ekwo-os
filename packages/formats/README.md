# Format libraries

One npm package per file format, organised **by format and never by country**.
Factur-X is French and German, UBL is universal, camt.053 is European: a format
is not a country. Which formats a country uses is said by its pack — its
e-invoicing profile, its bank statement formats, its declaration — never by the
shape of this directory.

Each package here:

- is **MIT**, with its own `LICENSE` file, so it can be used anywhere,
  including inside other software;
- **imports nothing from the core** — not `@ekwo-ai/core`, not the schema, not
  another library;
- declares the **flat row shapes** it reads or returns in its own types, so any
  book-keeping system that can produce those columns can use it;
- returns what does not add up in `violations[]`, and never corrects it.

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

**Bank statements, read.** They return statements and lines under the same
field names, which is what `import_bank_statement()` takes:

| Package | Format |
|---|---|
| [`camt053`](camt053/) | ISO 20022 camt.053 |
| [`coda`](coda/) | CODA |
| [`cfonb120`](cfonb120/) | CFONB 120 |

**Books kept elsewhere, read.** They return accounts, parties, entries and an
opening balance under the same names, which is what `import_books()` takes once
the codes are translated into a company's chart. They are named after the file,
never after the software that writes it:

| Package | Format |
|---|---|
| [`trial-balance`](trial-balance/) | A trial balance as CSV |
| [`journal-items`](journal-items/) | The lines of every entry, exported as CSV from a ledger kept as a table of lines |
| [`journal-report`](journal-report/) | A journal report or general ledger detail saved as CSV |
| [`transaction-journal`](transaction-journal/) | A transaction journal saved as CSV |
| [`xaf`](xaf/) | XML Audit File Financial, versions 3.2 and 4.0 |
| [`fec`](fec/) | The FEC, read back with `readFec()` |

A file that comes from outside is treated as untrusted until read: the XML
readers refuse DTDs and external entities and bound size and depth, and the
fixed-width and CSV readers take the encoding they are told and never guess it.

## Why no shared abstraction

There is no `Filing` interface, no plugin registry and no common `xml`
package. Two formats that look alike are two formats: the four recapitulative
statements read the same rows and still disagree on lines, columns, number
formats and how a VAT number is written. Each package says, in its README,
which official pages the format was read from.

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
