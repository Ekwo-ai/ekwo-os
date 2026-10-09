# @ekwo-ai/factur-x

Factur-X / ZUGFeRD electronic invoices in TypeScript.

- **CII XML from a plain invoice object.** EN 16931 semantic model, UN/CEFACT CII D16B
  syntax, element order of the schema, VAT breakdown rules (`BR-S`, `BR-Z`, `BR-E`, `BR-AE`,
  `BR-IC`, `BR-G`, `BR-O`). Profiles MINIMUM, BASIC WL, BASIC (default), EN 16931, EXTENDED.
- **PDF/A-3 embedding.** Attaches the XML as `factur-x.xml` with `AFRelationship /Alternative`
  and writes the XMP packet with the Factur-X extension schema.
- **Extraction.** Reads `factur-x.xml`, `zugferd-invoice.xml` or `xrechnung.xml` back from any PDF.
- **Reading a received invoice.** `readCii` and `readFacturX` turn the CII of any profile
  into the same plain result `@ekwo-ai/peppol-ubl` returns from UBL — see [Reading](#reading).
- **Totals you can trust.** One VAT group per category and rate, VAT computed on the rounded
  basis, prepayments, credit notes referencing the original invoice.
- Zero dependencies for the XML part; `pdf-lib` only for the PDF part (separate entry point).

## Install

```sh
npm install @ekwo-ai/factur-x
```

## Usage

```ts
import { generateCiiXml, computeTotals } from '@ekwo-ai/factur-x';
import { embedFacturX, extractFacturX } from '@ekwo-ai/factur-x/pdf';

const invoice = {
  number: 'INV-2026-0042',
  issueDate: '2026-03-31',
  dueDate: '2026-04-30',
  seller: {
    name: 'Exemple Conseil SA',
    vatId: 'BE0123456749',
    legalId: { scheme: '0208', value: '0123456749' },   // Belgian enterprise number
    address: { line1: "Rue de l'Exemple 1", postalCode: '1000', city: 'Bruxelles', country: 'BE' },
  },
  buyer: {
    name: 'Société Fictive SAS',
    vatId: 'FR12345678901',
    legalId: { scheme: '0002', value: '345678901' },    // SIREN
    address: { line1: '10 avenue des Tests', postalCode: '75001', city: 'Paris', country: 'FR' },
  },
  buyerReference: 'SERVICE-EXEC-42',
  lines: [
    { name: 'Consulting days', quantity: 3, unitCode: 'day', unitPrice: 950, vatRate: 0 },
    { name: 'Software licence', quantity: 1, unitPrice: 1200, vatRate: 0 },
  ],
  payment: { iban: 'BE71 0961 2345 6769' },
};

const xml = generateCiiXml(invoice);                       // BASIC profile
const totals = computeTotals(invoice);                     // { lineTotal, taxTotal, grandTotal, duePayable, breakdown }

const pdf = await embedFacturX(visualPdfBytes, xml, { title: 'Invoice INV-2026-0042' });
const back = await extractFacturX(pdf);                    // { filename: 'factur-x.xml', xml }
```

`npm run example` runs [`examples/basic.ts`](examples/basic.ts) end to end.

### VAT categories

Each line carries a `vatRate`. The category (BT-151) is derived when you do not state it:
positive rate → `S`; zero rate at home → `Z`; zero rate to a business in another Member State of the European Union with a VAT id → `K`
(supply between Member States); to a buyer there without one → `E`; outside the European Union → `G`. Set `vatCategory`
on the line to override (`AE` reverse charge, `O` not subject to VAT…). Exempt groups get a
reason text (BT-120, override with `invoice.exemptionReasons`) and the VATEX code where one
exists.

### Identifiers

| Field | Example | XML |
|---|---|---|
| `vatId` | `BE0123456749`, `FR12345678901` | `SpecifiedTaxRegistration/ID[@schemeID="VA"]` |
| `legalId` | `{ scheme: '0208', value: '0123456749' }` (BE), `{ scheme: '0002', value: '345678901' }` (FR SIREN) | `SpecifiedLegalOrganization/ID[@schemeID]` |
| `buyerReference` | French « service exécutant » code | `BuyerReference` (BT-10) |
| `orderReference` | purchase order | `BuyerOrderReferencedDocument` (BT-13) |

### Units

`unitCode` accepts a UN/ECE Recommendation 20 code (`HUR`, `DAY`, `KWH`…) or an everyday
word in French, Dutch, English or German (`heures`, `dagen`, `m²`, `Stück`). Unknown values fall
back to `C62` (unit). See `UNIT_CODES` and `toUnitCode`.

## API

| Export | Description |
|---|---|
| `generateCiiXml(invoice, { profile?, businessProcess? })` | CII XML string. |
| `computeTotals(invoice)` | VAT breakdown and document totals (BT-106 … BT-117). |
| `defaultVatCategory`, `EXEMPTION_REASON_CODES`, `DEFAULT_EXEMPTION_REASONS` | VAT helpers. |
| `toUnitCode`, `UNIT_CODES` | Unit helpers. |
| `buildXmpMetadata`, `CONFORMANCE_LEVELS`, `GUIDELINES`, `DOCUMENT_TYPE_CODES` | Constants of the specification. |
| `embedFacturX(pdf, xml, { profile?, title?, creator?, producer?, date? })` *(`/pdf`)* | Returns a new PDF with the XML attached and the PDF/A-3 XMP packet. |
| `extractFacturX(pdf)` *(`/pdf`)* | `{ filename, xml }` or `null`. |
| `readCii(xml, { maxBytes?, maxDepth?, maxElements? })` | `{ invoice, violations, profile }`, see [Reading](#reading). |
| `readFacturX(pdf, options?)` *(`/pdf`)* | The same, read out of the PDF, with the `filename` of the attachment. |
| `InvoiceFileError`, `profileOf`, `checkReceived`, `isValidIban`, `CREDIT_NOTE_TYPE_CODES` | What reading refuses, and the helpers it uses. |

## Scope and limitations

- Allowances and charges (BG-20, BG-21, BG-27, BG-28), gross prices with discounts and
  multiple deliveries are not modelled yet.
- The PDF part embeds the data and declares PDF/A-3; it does not convert the visual PDF to
  PDF/A (fonts, colour profiles, output intent). Validate the result with the tool of your
  platform before going live.
- No XSD or Schematron validation is performed. Test against a validator such as the FNFE
  Factur-X validator or the Mustang project.

## Reading

The invoice a supplier sends you as Factur-X or ZUGFeRD, turned into a plain object a
purchase draft can be made from.

```ts
import { readCii, InvoiceFileError } from '@ekwo-ai/factur-x';
import { readFacturX } from '@ekwo-ai/factur-x/pdf';

const { invoice, violations, profile, filename } = await readFacturX(pdfBytes);
profile;                 // 'minimum' | 'basic-wl' | 'basic' | 'en16931' | 'extended' | null
invoice.kind;            // 'invoice' | 'credit_note', from the type code
invoice.totals.payable;  // '648.40', a decimal as text, never a number

const same = readCii(xmlBytesOrText);   // the XML alone, without pdf-lib
```

- `readCii(input: string | Uint8Array, options?: ReadOptions): ReceivedCiiFile` reads a
  CII D16B `CrossIndustryInvoice` — Factur-X 1.0, ZUGFeRD 2.x, an XRechnung in CII — and
  returns `{ invoice, violations, profile }`.
- `readFacturX(pdf: Uint8Array | ArrayBuffer, options?: ReadOptions): Promise<ReceivedFacturX>`
  *(`/pdf`)* finds the XML attached to the PDF and reads it with `readCii`; the result
  adds the `filename` it was attached under.
- `profileOf(guideline)` is the profile a guideline identifier (BT-24) declares. An
  EN 16931 CIUS (`urn:cen.eu:en16931:2017#compliant#…`, XRechnung for one) reads as
  `en16931`; an identifier this package does not know is `null`, and
  `invoice.customizationId` keeps what the file wrote.

**The shape is the UBL reader's.** `invoice` is a `ReceivedInvoice`, the type
`readUbl` of `@ekwo-ai/peppol-ubl` returns: each field names the EN 16931 business term it
holds, and a business term is in the same field whichever syntax carried it — the test
suite reads one invoice written in both syntaxes and gets the same object from both. The
two bricks do not depend on each other; they hold byte-for-byte copies of the files that
define the shape, the checks, the XML reader and the decimals, and a test keeps them
identical. `syntax` says which one was read.

**Nothing is recomputed, nothing is defaulted.** A figure is the text the file wrote,
checked to be a decimal; an absent element is `null` — a MINIMUM or BASIC WL file has no
line and no line total, and comes back so. The arithmetic of EN 16931 (BR-CO-10 to
BR-CO-17) is checked on exact decimals and reported in `violations`. CII-specific
findings are there too: `invalid_iban` (an `IBANID` whose check digits fail, still
returned as written), `invalid_attachment`, `unsupported_date_format` (a date in a
format other than 102, returned as `null`). Where CII writes something once for the
document that UBL writes per means of payment — the payment reference (BT-83) and the
direct debit mandate (BT-89) — it is returned on every means of payment.

**What is not an invoice throws an `InvoiceFileError`** with a `code`: the codes of the
UBL reader (`malformed_xml`, `unsupported_encoding`, `doctype_forbidden`,
`undefined_entity`, `too_large`, `too_deep`, `too_many_elements`, `not_an_invoice`,
`missing_element`, `invalid_value`), plus `not_a_pdf` and `no_embedded_invoice` from
`readFacturX`. A line is required except in the MINIMUM and BASIC WL profiles. No raw
error of the XML parser or of `pdf-lib` escapes. The XML is read by a strict reader of
the package's own: no DOCTYPE and so no entity expansion, UTF-8 only, size, depth and
element limits.

**Limits.**

- The PDF is opened with `pdf-lib`, already the dependency of the `/pdf` entry point:
  the attachment is found in the `EmbeddedFiles` name tree of the catalogue, under one
  of the three names above. An attachment reachable only from a page annotation, an
  encrypted PDF, and a stream in a filter `pdf-lib` does not decode are not read: they
  are refused with one of the codes above, never read wrongly. The XMP metadata is not read: the profile
  comes from the XML.
- ZUGFeRD 1.0 (`CrossIndustryDocument`, another namespace) is refused as
  `not_an_invoice`.
- Elements of EXTENDED beyond EN 16931 (several deliveries, line sub-structures…) are not
  read. Nothing is validated against the CII schema or a Schematron.

## Development

```sh
npm install
npm run typecheck
npm test
npm run build
```

## License

[MIT](LICENSE) © Ekwo AI
