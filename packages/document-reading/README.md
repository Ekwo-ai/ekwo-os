# @ekwo-ai/document-reading

One reader for received invoices. A structured e-invoice — CII, UBL, a PDF
carrying its Factur-X or ZUGFeRD XML — is read exactly. A photograph or a
plain PDF is read by a vision model **you** call, with the JSON schema and
the prompt this package publishes, and its answer is checked here. Both
arrive as the same EN 16931 `ReceivedInvoice`, and become the same purchase
draft.

MIT. No database, no network, no model call: the package reads bytes and
JSON, and returns objects.

```sh
npm install @ekwo-ai/document-reading
```

## How a product chains it

```ts
import {
  READING_VERSION,
  purchaseDraftOf,
  readStructured,
  readingOf,
  readingPrompt,
  readingSchema,
} from '@ekwo-ai/document-reading';

// 1. A structured e-invoice is read exactly, and no model is called.
const structured = await readStructured(bytes);
let invoice = structured?.invoice;

// 2. Anything else is read by a vision model: one call, one schema.
if (invoice === undefined) {
  const answer = await yourModel({
    system: readingPrompt(),
    file: bytes, // the image or the PDF, as your provider takes it
    format: { type: 'json_schema', schema: readingSchema() },
  });
  const reading = readingOf(JSON.parse(answer.text));
  // reading is undefined when the page is not a purchase document.
  invoice = reading?.invoice;
  log({ reading: READING_VERSION, missing: reading?.missing, rejected: reading?.rejected });
}

// 3. The draft of a purchase, in the columns of Ekwo OS.
if (invoice !== undefined) {
  const draft = purchaseDraftOf(invoice);
  // Choose the supplier, the account and the tax in your books, then create_document.
}
```

**The model call, its key, its timeout and its metering stay in the
product.** This package names no provider and holds no secret; the schema is
a plain JSON schema with every object closed and every property required, as
the structured outputs of the main providers take it.

## The exact path: `readStructured(bytes, options?)`

Tells a PDF from XML by the first bytes and CII from UBL by the root, and
reads with `readFacturX()` / `readCii()` of
[`@ekwo-ai/factur-x`](../formats/factur-x/) or `readUbl()` of
[`@ekwo-ai/peppol-ubl`](../formats/peppol-ubl/). Returns their
`{ invoice, violations }`, or `undefined` for a file that holds no
e-invoice — a photograph, a PDF without XML, an XML that is not an invoice,
a file over the limits — so the caller reads it the other way. The readers
are imported when a file needs them.

## The model path: `readingSchema()`, `readingPrompt()`, `readingOf()`

The model is told to **copy, never compute**, and to **leave empty rather
than guess**. It returns, as printed:

- what the page is: `invoice`, `credit_note`, `receipt` (already paid), or
  `other` (read as nothing);
- the number, the issue, due and tax-point dates, and the currency **as
  printed** — empty where the page prints none, never the currency of a
  country;
- the supplier and the customer: legal and trade name, VAT identifier,
  registration number, address;
- the references (customer, order, contract, the invoice a credit note
  corrects), the invoicing period, the IBAN, BIC, payment reference and terms;
- each line: name, description, quantity, the unit as printed and its UN/ECE
  Recommendation 20 code, net price, net amount, VAT category (UNTDID 5305)
  and rate, and its own period;
- each VAT group of the summary: category, rate, base, tax, the amount
  including tax where printed;
- the totals: lines, without VAT, VAT, with VAT, prepaid, payable;
- a confidence (`high`, `medium`, `low`) for each field of
  `CONFIDENCE_FIELDS`, and for each line.

`readingOf(answer)` checks it into a `ReceivedInvoice` with
`syntax: 'model'`, and returns beside it:

| Field | What it holds |
|---|---|
| `missing` | The fields EN 16931 requires that the page did not print, by path (`number`, `totals.payable`, `lines[2].net_amount`). Each is `''` in the invoice. |
| `rejected` | The fields the model filled with something not of their shape — a date that is no day, a rate in words. Each is emptied. |
| `violations` | The arithmetic of EN 16931 the printed figures break, checked only when every figure it reads was read. |
| `confidence` | By field and by line (`lines[n]`), `null` where the model said nothing usable. |
| `taxInclusiveByGroup` | Per VAT group, the amount including tax the page prints, which EN 16931 does not carry. |
| `extension` | The caller's own fields, untouched. |

Nothing is computed, defaulted or corrected: a total that is not printed
stays empty, a lone comma is read as a decimal separator and anything else
that is not a decimal is rejected.

## Extending the schema

A caller that needs more than an invoice adds its own properties, read in
the same call:

```ts
const extension = {
  properties: {
    meter: { type: 'string', description: 'The meter number, as printed.' },
    contract_type: { type: 'string', description: 'The contract type, as printed.' },
  },
  instructions: 'The meter number is printed near the address of supply.',
};
const schema = readingSchema(extension); // adds a closed `extension` object
const prompt = readingPrompt(extension); // adds the instructions after the package's words
const reading = readingOf<{ meter: string; contract_type: string }>(answer);
reading?.extension; // as the model answered it: check your own fields
```

The invoice is read once; the extension's fields come back beside it, and
the PDF is never read a second time.

## The purchase draft: `purchaseDraftOf(invoice)`

The fields of `documents` and `document_lines` of Ekwo OS, from either path:

- `doc_type` (`purchase_invoice` or `purchase_credit_note`), the dates, the
  supplier's number as `supplier_reference`, `currency_code` (null where it
  was not read), the references, `payment_reference`, `payee_iban`;
- the supplier as the invoice names it, to be found among the contacts or
  added;
- one line per line, then one per allowance (negative) or charge of the
  whole document, each with its `unit_code`, its VAT category and rate.

A line keeps its quantity, unit code and price where they make its amount
at the decimals of its currency, as `amount_untaxed` is computed —
`1234 kWh × 0.1834 = 226.3156`, which rounds to the `226.32` printed.
Otherwise it is one unit (`C62`) at its amount, and the invoice's own
figures go in `attributes` (`invoiced_quantity`, `invoiced_unit_code`,
`invoiced_net_price`). The period of a line goes in `attributes` as
`period_start` and `period_end`; the period of the invoice goes on each line
without its own, and is returned as `invoicing_period`.

The supplier, the account and the tax are chosen by the caller, in its own
books and country pack: this package knows no chart and no rate.

## Licence

MIT. See [`LICENSE`](LICENSE).
