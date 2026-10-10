# @ekwo-ai/invoice-pdf

The visual PDF of a sale invoice or credit note, in TypeScript, from the rows a
set of books publishes.

- **One sober layout**, A4 or Letter: the seller (its logo, or its name), the
  title, number, dates and references; the buyer and, where the goods went
  elsewhere, the delivery address; the lines, with the column headings repeated
  on every page they run onto; the tax summary, one row per tax, with the
  sentence that says why a group charges nothing; the totals and what is still
  due; how to pay (terms, due date, IBAN, BIC, reference); the note; the legal
  mentions; and on every page the seller's identity and the page number.
- **Nothing country-specific in the layout.** The words it prints of its own
  are labels, English by default and the caller's in any other language; the
  sentences a country requires come in as rows; amounts, dates, rates and
  country names are written by `Intl` in the document's language, with the
  currency's own minor units.
- **Any script Noto Sans has**, embedded: Latin, Greek, Cyrillic, Thai; and
  any other through a font the caller adds. Right to left is refused by name,
  never drawn reversed.
- **Ready for Factur-X.** The PDF it renders is acceptable to `embedFacturX`
  of [`@ekwo-ai/factur-x`](../factur-x/README.md), which turns it into a
  PDF/A-3 carrying its CII — see [Factur-X](#factur-x).
- Pure TypeScript. Runs in Node, Deno and a browser. Reads no database, fetches
  nothing, writes no file: rows and bytes in, bytes out.

Open [`examples/invoice-english.pdf`](examples/invoice-english.pdf) and
[`examples/invoice-greek.pdf`](examples/invoice-greek.pdf) to see it; every
name and number in them is invented. The Greek one passes only some of the
words in Greek, on purpose: the rest falls back to English, which is what a
caller who passes an incomplete set gets.

## Install

```sh
npm install @ekwo-ai/invoice-pdf
```

## Usage

```ts
import { renderInvoicePdf } from '@ekwo-ai/invoice-pdf';

const { file, filename, pageCount } = await renderInvoicePdf(
  {
    header,               // one row of document_header
    lines,                // the rows of document_line_items, in their order
    taxes,                // the rows of document_tax_summary
    mentions,             // the rows of document_legal_mentions
    logo: logoBytes,      // PNG or JPEG bytes, or nothing
  },
  {
    pageSize: 'A4',       // or 'Letter'
    labels: { invoice: 'Factura', amountDue: 'Importe pendiente' },  // the rest stays English
  },
);
// file: Uint8Array of a PDF; filename: 'invoice-INV-2026-0042.pdf'
```

## The input

What the books already publish, and nothing else: one field per column of
four views of [Ekwo OS](https://github.com/Ekwo-ai/ekwo-os), declared in
[`src/types.ts`](src/types.ts) so that nothing is imported from it. Any
invoicing system that produces the same rows can use this package. A column
that is null is not printed; nothing is filled in for it.

| Field | View | What is printed from it |
|---|---|---|
| `header` | `document_header` | The seller (`seller_*`: name, legal name and form, address, VAT and registration numbers, e-mail, phone, website, electronic address, share capital), the buyer (`buyer_*`), the delivery address (`delivery_*`), the number, the dates (`document_date`, `due_date`, `delivery_date`, `tax_point_date`), the references, the totals (`amount_untaxed`, `amount_tax`, `amount_total`, `amount_paid`), what is still due (`amount_residual`), the payment (`payment_terms`, `payee_iban`, `payee_bic`, `payment_reference`), the `note`, the `currency_code` and the `language`. `doc_type` and `state` choose the title. |
| `lines` | `document_line_items` | `item_name`, `seller_item_identifier`, `item_description`, `quantity` and `unit_code`, `unit_price` (marked `*` where `unit_price_includes_tax`), `discount_percent`, `vat_rate`, `amount_untaxed`. A `section` line is a heading across the table, a `note` line a sentence across it. |
| `taxes` | `document_tax_summary` | `tax_name`, `tax_rate`, `base_amount`, `tax_charged` — what the customer pays — and `exemption_reason` under its group. Not `legal_reference`, written for whoever reviews a pack and not for a customer. |
| `mentions` | `document_legal_mentions` | `text`, already in the document's language and valid on its date, in the order of `sequence`. |
| `logo` | — | The bytes of the logo. `document_header.seller_logo_url` is never fetched here: the caller fetches it, or not. |

Figures arrive as the decimal text the database holds and are handed to
`Intl.NumberFormat` as text, which writes them digit for digit — never through
a JavaScript number. Nothing is computed: every total printed is a column.

## Words and languages

`ENGLISH_LABELS` holds every word the layout prints of its own — "Invoice",
"Credit note", "Due date", "Amount due", "Page {page} of {pages}"… — and
`units` maps UN/ECE Recommendation 20 codes to what is printed after a
quantity (`DAY` → `days`, `C62` → nothing). English is the only language this
package carries. A document in another language gets its words from the
caller, `options.labels`, whole or in part; what is left out is English. A
country's own words — what its tax is called, what the law wants printed —
are not labels: they are `tax_name` and the mentions, which the books give in
the document's language.

The language amounts, dates and country names are written in is
`options.locale`, else the document's `language`, else `en`. A tag `Intl`
does not accept is refused (`invalid_language`).

## Fonts

| Font | Covers | Licence |
|---|---|---|
| Noto Sans, Regular and Bold | Latin (with its extensions and Vietnamese), Greek, Cyrillic | SIL Open Font License 1.1 — [`licenses/OFL-NotoSans.txt`](licenses/OFL-NotoSans.txt) |
| Noto Sans Thai, Regular and Bold | Thai | SIL Open Font License 1.1 — [`licenses/OFL-NotoSansThai.txt`](licenses/OFL-NotoSansThai.txt) |

They are the hinted TrueType builds of the [Noto project](https://github.com/notofonts),
embedded in the package as base64 modules by
[`scripts/embed-fonts.mjs`](scripts/embed-fonts.mjs), which checks each file's
SHA-256. The OFL allows them to be bundled and embedded in documents; their
names are reserved, and they are not modified. In a PDF, each is embedded as
a subset holding only the glyphs drawn, and only when one of its characters is
drawn: a one-page invoice weighs about 30 kB.

Noto Sans was chosen because it is one design across the scripts a
customer's name is most often written in, and because the family extends to
nearly every other one — **Noto Sans CJK**, Devanagari, Hangul… — which a
caller adds through `options.fonts` (`{ regular, bold? }`, TrueType or
OpenType bytes) without the package growing by megabytes for everybody.

Each character is drawn by the first font that has it, embedded ones first, so
a line may mix scripts. A character no font has is refused,
`glyph_not_covered`, with its code point: an empty box where a name should be
is worse than no PDF.

**Right to left.** Hebrew, Arabic, Syriac, Thaana, N'Ko and the other scripts
of the right-to-left blocks of Unicode need the bidirectional algorithm and a
mirrored layout, which this package does not have. A string holding one —
in the rows or in the labels — is refused, `right_to_left_text`, naming the
field. It is never drawn in the wrong order.

The colour profile declared as the output intent is the compact sRGB profile
of [Compact-ICC-Profiles](https://github.com/saucecontrol/Compact-ICC-Profiles),
CC0 ([`licenses/CC0-sRGB-profile.txt`](licenses/CC0-sRGB-profile.txt)).

## Factur-X

```ts
import { renderFacturXPdf } from '@ekwo-ai/invoice-pdf';
import { embedFacturX } from '@ekwo-ai/factur-x/pdf';

const { file } = await renderFacturXPdf(input, { xml: ciiXml, profile: 'en16931', embed: embedFacturX });
```

`renderFacturXPdf` renders the PDF and hands it, unchanged, with the CII XML
of the same document, to the `embed` function — `embedFacturX`, or anything of
its shape. This package does not import `@ekwo-ai/factur-x`: a brick depends
on no other brick.

What makes the rendered PDF acceptable to it: every font is embedded, nothing
is drawn with transparency except the alpha channel of a PNG logo, the
colours are DeviceRGB under an sRGB output intent, the catalogue states the
language, and the trailer carries an identifier. `embedFacturX` adds the XML,
the PDF/A-3 declaration and its XMP packet. The test suite reads the result
back with `readFacturX` and gets the invoice, its profile and no violation.
No PDF/A validator is run in this repository: check the first files with the
validator of your platform before you rely on them.

## What it refuses

An `InvoicePdfError` with a `code`, before anything is drawn wrong:

| Code | When |
|---|---|
| `not_a_sale_document` | A purchase, a quote, an order: this package renders what a seller issues. |
| `missing_field` | No currency, no date, no total, a tax group without its base or its tax. |
| `invalid_value` | A figure that is not a decimal, a currency that is not ISO 4217, a date that is not `YYYY-MM-DD`. |
| `invalid_language` | A language tag `Intl` does not accept. |
| `glyph_not_covered` | A character no font has. |
| `right_to_left_text` | A string written right to left. |
| `unsupported_logo`, `unsupported_font` | A logo that is not a PNG or a JPEG; a font that cannot be read. |

A draft is rendered, titled as a draft and without a number; a cancelled
document says so under its title.

## What it does not do

- **Keep the copy that was sent.** A posted document is reproducible from the
  books ([decision 0015](../../../docs/decisions/0015-a-posted-document-is-frozen.md)),
  but the copy a customer received is the one that counts, and it should be
  kept as it was — an attachment of the document, with its checksum. Next.
- **Send it by e-mail.** Next, beside it.
- **The button in the hosted web application.** Next; it calls the same
  function the command line and the MCP server call.
- **Read a supplier's PDF.** Receiving purchase invoices as PDF is another
  brick; the Factur-X reader already reads the XML inside one.
- Right-to-left layouts, vertical text, other templates than this one.

What the views do not carry yet, and the layout therefore cannot print: the
invoice a credit note credits (only `documents.reversed_document_id` has it);
the buyer's phone, legal name beside a trade name, and contact person; a
second line and a region for the delivery address, and a named delivery
party; the account holder and bank name of the payee, and an account that is
not an IBAN; the words of the layout in the document's language, which no pack
holds.

## In Ekwo OS

`ekwo doc pdf <document> [--factur-x] [--out <file>]` and the MCP tool
`render_invoice_pdf` read the four views as the person signed in, fetch the
logo the company names by URL (from a public http(s) address only), and call
this package — through `renderDocumentPdf()` of `@ekwo-ai/core`, which writes
the CII with the adapter of the `einvoicing` formats when Factur-X is asked
for.

## Development

```sh
npm install
npm run typecheck
npm test
npm run build
npm run examples     # rewrites examples/*.pdf
```

## License

[MIT](LICENSE) © Ekwo AI. The fonts and the colour profile it embeds keep
their own licences, in [`licenses/`](licenses).
