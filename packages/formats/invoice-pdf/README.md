# @ekwo-ai/invoice-pdf

The visual PDF of a sale invoice or credit note, in TypeScript, from the rows a
set of books publishes.

- **One sober layout**, A4 or Letter: the seller (its logo and its name), the
  title, number, dates and references; the buyer and, where the goods went
  elsewhere, the delivery address, on shaded panels; the lines, with the
  column headings repeated on every page they run onto; the tax summary, one
  row per tax, with the sentence that says why a group charges nothing; the
  totals ending on what is still due, and beside them how to pay (terms, due
  date, IBAN, BIC, reference) in a frame; the note; the legal mentions; and on
  every page the seller's identity and the page number.
- **A small theme**: an accent colour, a typeface (Noto Sans or the caller's),
  the logo on the left or the right — see [Theme](#theme).
- **Nothing country-specific in the layout.** The words it prints of its own
  are labels, English by default and the caller's in any other language; the
  sentences a country requires come in as rows; amounts, dates, rates and
  country names are written by `Intl` in the document's language, with the
  currency's own minor units.
- **Any script Noto Sans has**, embedded: Latin, Greek, Cyrillic, Thai; and
  any other through a font the caller adds. Right to left is refused by name,
  never drawn reversed.
- **PDF/A-3b, measured.** veraPDF finds no failed rule of PDF/A-3b in the
  PDF it renders, nor in the Factur-X that `embedFacturX` of
  [`@ekwo-ai/factur-x`](../factur-x/README.md) makes of it — see
  [PDF/A-3](#pdfa-3) and [Factur-X](#factur-x).
- Pure TypeScript. Runs in Node, Deno and a browser. Reads no database, fetches
  nothing, writes no file: rows and bytes in, bytes out.

Open [`examples/invoice-english.pdf`](examples/invoice-english.pdf),
[`examples/invoice-greek.pdf`](examples/invoice-greek.pdf) and
[`examples/invoice-english-factur-x.pdf`](examples/invoice-english-factur-x.pdf)
to see it; every name and number in them is invented. The Greek one passes only some of the
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
    theme: { accent: '#7A1F2B', logoPosition: 'right' },              // or nothing: DEFAULT_THEME
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
| `logo` | — | The bytes of the logo, PNG or JPEG. A PNG's transparency is flattened on white. `document_header.seller_logo_url` is never fetched here: the caller fetches it, or not. |

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

## Theme

```ts
import { DEFAULT_THEME, renderInvoicePdf } from '@ekwo-ai/invoice-pdf';

await renderInvoicePdf(input, { theme: { accent: '#7A1F2B', font: { regular, bold }, logoPosition: 'right' } });
// DEFAULT_THEME: { accent: '#1F3A5F', font: 'Noto Sans', logoPosition: 'left' }
```

Three fields, all optional, and nothing else, on purpose: they are what a
customer's own invoice sets — its colour, its typeface, which side its logo is
on — and the hook for a theme read from one later.

| Field | What it changes |
|---|---|
| `accent` | `#rrggbb`. The title, the rule under the heading, the band of the column headings and of the amount due. The text on a band is white, or ink where the colour is light — whichever contrasts more. |
| `font` | `'Noto Sans'`, or the caller's TrueType or OpenType bytes, `{ regular, bold? }`, drawn first, with the embedded fonts for any character they lack. Embedded as a subset like the others. |
| `logoPosition` | `left`: the logo above the seller's address. `right`: above the title, the seller's name on the left. |

A colour that is not `#rrggbb` or a side that is neither is refused,
`invalid_value`. Nothing in the theme changes what is printed, only how.

## The layout

The order of the page, top to bottom: the seller and the document's title,
number, dates and references side by side; a rule; the buyer and the delivery
address; the lines; the tax summary; the totals with, on their left, how to
pay; the note; the legal mentions; the foot.

### What the layout keeps from earlier renderers

Two invoice renderers already in production elsewhere were read, section by
section, before this layout was settled. Both draw with the standard PDF
fonts without embedding them, which PDF/A forbids: neither is a strict
PDF/A-3. What was clearly better in them is kept; nothing of their code is.

| Section | An earlier renderer did | Here |
|---|---|---|
| Header | Put the logo top left, scaled within a box, the document's title, number and dates on the right; one offered the logo on the left, the right or the centre. | Kept: logo within 170 × 60 points, on the left or the right (`theme.logoPosition`); the centre was left out, as it collides with the title. |
| Header | Drew a separator line between the header and the customer. | Kept, in the accent colour. |
| Customer | Set the customer apart in a filled or bordered box (both renderers). | Kept: the buyer, and the delivery address beside it, on shaded panels. |
| Lines | Headed the table with a band of the theme's colour, in white. | Kept, with ink instead of white on a light colour. |
| Totals | Showed what was already paid right under the total, then what remains due, "so that it cannot be missed". | Already so here; the amount due is now a band of the accent colour. |
| Payment | Gathered the bank details — bank, holder, IBAN, BIC — in a framed box. | Kept, framed, beside the totals; the views carry no bank name or holder yet (see [EN 16931](#en-16931-on-the-page)). |
| Credit note | Ended a negative balance on "in your favour" rather than "to pay". | Already so here: a credit note ends on `amountCredited` and gives no payment instructions. |
| Theme | Several fixed themes, and one derived from the analysis of a customer's own invoice (colours, font style, title size, logo position, box styles). | Reduced to the three fields of [Theme](#theme); no gallery. |
| Lines | Added subtotals per section, zebra rows, a "paid" watermark. | Not kept: a subtotal would be computed here, and nothing printed is; zebra rows and a watermark add ink, not information. |

## PDF/A-3

The PDF it renders declares itself PDF/A-3b, and is one by veraPDF's measure:

- every font embedded, as a subset, the theme's included;
- colours in DeviceRGB under an sRGB output intent;
- nothing transparent: a PNG logo's alpha channel is flattened on white
  before it is embedded, and a CMYK JPEG is refused;
- an XMP packet that says what the document information dictionary says —
  title, author, subject, creator, producer, creation and modification dates;
- the language in the catalogue, and an identifier in the trailer.

[veraPDF](https://verapdf.org) 1.30.3, profile PDF/A-3b (ISO 19005-3), on the
files of `examples/`, as rendered by `npm run examples`:

| File | Rules passed | Rules failed |
|---|---|---|
| `invoice-english.pdf` | 146 | 0 |
| `invoice-greek.pdf` | 146 | 0 |
| `invoice-english-factur-x.pdf` (with `embedFacturX`) | 146 | 0 |

Before this was measured, the two plain PDFs failed one rule (6.6.2.1: no XMP
metadata stream) and the Factur-X one passed with an XMP that did not mirror
the dictionary; a credit note rendered as Factur-X, run as a further case,
failed 6.1.6 on an identifier written with a minus sign. All three are fixed
and tested. Also run, and with no failed rule: a 120-line invoice on six
Letter pages, a Thai invoice, a logo with an alpha channel on the right with a
light accent colour, a caller's TrueType font as the theme's typeface.

veraPDF is Java and is not a dependency: install it, then

```sh
VERAPDF=/path/to/verapdf npm run verapdf                 # the examples, PDF/A-3b
VERAPDF=/path/to/verapdf npm run verapdf -- --flavour 3b a.pdf b.pdf
```

which prints the rules passed and failed for each file and exits 1 when one
fails. No test runs it, and a PDF made with caller fonts or logos this table
does not cover is the caller's to validate.

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

The rendered PDF is already a PDF/A-3b; `embedFacturX` adds the XML and
replaces the XMP packet with its own, which declares the Factur-X extension
schema and is written from the same document information dictionary. veraPDF
finds no failed rule of PDF/A-3b in the result ([PDF/A-3](#pdfa-3)). The test
suite reads it back with `readFacturX` and gets the invoice, its profile and
no violation, and checks that the totals, the tax per rate and the amount due
printed on the page — read out of the PDF — are the figures of the CII inside
it, on an invoice under two rates and on a credit note.

## What it refuses

An `InvoicePdfError` with a `code`, before anything is drawn wrong:

| Code | When |
|---|---|
| `not_a_sale_document` | A purchase, a quote, an order: this package renders what a seller issues. |
| `missing_field` | No currency, no date, no total, a tax group without its base or its tax. |
| `invalid_value` | A figure that is not a decimal, a currency that is not ISO 4217, a date that is not `YYYY-MM-DD`; a theme colour that is not `#rrggbb`, a logo position that is neither `left` nor `right`. |
| `invalid_language` | A language tag `Intl` does not accept. |
| `glyph_not_covered` | A character no font has. |
| `right_to_left_text` | A string written right to left. |
| `unsupported_logo`, `unsupported_font` | A logo that is not a PNG or a JPEG, or a CMYK JPEG; a font that cannot be read. |

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
- Right-to-left layouts, vertical text, other templates than this one: the
  theme changes its colour, typeface and logo side, not its layout.
- Print what the views do not carry yet — see
  [EN 16931 on the page](#en-16931-on-the-page).

## EN 16931 on the page

Every business term of EN 16931 the rows hold is printed, and
[`test/en16931.test.ts`](test/en16931.test.ts) reads each one out of the PDF.
The terms the standard makes mandatory:

| Term | Printed as |
|---|---|
| BT-1, BT-2, BT-3 | The number, the date, the title (`Invoice`, `Credit note`). |
| BT-5 | The currency, in every amount, as `Intl` writes it (`€2,601.50`). |
| BT-27, BT-40 | The seller's name and country (with its legal name, address, VAT and registration numbers when the rows hold them). |
| BT-44, BT-55 | The buyer's name and country (with its address, VAT and registration numbers, e-mail, electronic address). |
| BT-109, BT-112, BT-115 | Total excluding tax, total, amount due — and BT-110, BT-113 when given. |
| BT-116, BT-117 | Each tax group's base and tax, with its rate (BT-119) and the reason it charges nothing (BT-120). |
| BT-129, BT-130, BT-131, BT-146, BT-153 | Each line's quantity and unit, net amount, price and name. The price is the one keyed: before the discount, printed beside it, and with the tax in it where it is marked `*`. |

Not printed, because they are codes written for a machine, which the CII of a
Factur-X carries and a reader of the page does not need: BT-24 (the
specification identifier), BT-81 (the payment means code — the IBAN says
transfer), BT-118 and BT-151 (the VAT category code — the tax's name says it),
BT-126 (the line identifier — the lines are printed in its order). BT-106, the
sum of the line amounts, is BT-109 as long as the views carry no allowance or
charge on the document, which they do not.

What the views do not carry yet, and the page therefore cannot print:

- **BT-25, BT-26**: the invoice a credit note credits, and its date (only
  `documents.reversed_document_id` has it);
- **BT-45, BT-56, BT-57**: the buyer's trading name beside its legal name,
  its contact person and its phone;
- **BT-76, BT-79, BT-70**: a second line and a region for the delivery
  address, and the name of the party delivered to;
- **BT-85**: the holder of the payee's account — and its bank's name, for
  which EN 16931 has no term; and an account that is not an IBAN (BT-84 is
  read from `payee_iban` alone);
- the words of the layout in the document's language, which no pack holds.

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
npm run verapdf      # needs veraPDF, see PDF/A-3
```

## License

[MIT](LICENSE) © Ekwo AI. The fonts and the colour profile it embeds keep
their own licences, in [`licenses/`](licenses).
