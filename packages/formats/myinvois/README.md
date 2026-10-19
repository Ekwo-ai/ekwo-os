# `@ekwo-ai/myinvois`

Malaysia's **MyInvois e-Invoice** — the UBL 2.1 document the Inland Revenue
Board of Malaysia (Lembaga Hasil Dalam Negeri Malaysia, LHDNM) validates
before an invoice is the taxpayer's — in TypeScript, with no dependencies.
It writes the eight document types of the MyInvois SDK: the invoice, the
credit note, the debit note and the refund note, each as the supplier issues
it or **self-billed** by the buyer, in the JSON syntax or the XML one.

Give it a posted document as the books hold it, with what MyInvois asks and
the books do not hold — the LHDNM identifiers of both parties, the supplier's
MSIC code, the moment of issuance — and it gives you the document, a name for
it, and every rule of the SDK the document breaks, named by LHDNM's own error
code where it publishes one.

```ts
import { MYINVOIS } from '@ekwo-ai/myinvois';

const input = {
  header, lines, taxes,                  // the three views of a posted document
  version: '1.1',                        // the default: to be signed by the host; 1.0 unsigned
  issuedAt: '2026-01-15T10:30:00+08:00', // written in UTC: 2026-01-15, 02:30:00Z
  supplier: { tin, sst: 'NA', tourismTax: 'NA', activity: { msic: '46510', description } },
  buyer: { tin, phone: '+60123456789' },
};

const { content, filename, typeCode, violations } = MYINVOIS.write(input);         // JSON
const xml = MYINVOIS.write(input, 'xml').content;                                   // XML
```

`header`, `lines` and `taxes` are one row of `document_header`, the rows of
`document_line_items` and the rows of `document_tax_summary` in
[Ekwo OS](https://github.com/Ekwo-ai/ekwo-os) — the same three reads
`@ekwo-ai/peppol-ubl` and `@ekwo-ai/verifactu` take. They are declared in
this package's own types, so any invoicing system that can produce the same
rows can use it.

Writing the document is all it does. **It signs nothing**: version 1.1 of
every document type is the same structure as 1.0 with the signature
validated, and the signature — an XAdES enveloped signature in
`UBLExtensions` and `cac:Signature`, with a certificate issued by a
certification authority licensed by the MCMC — is added by the host after
this package and before the submission. **It submits nothing**: the login,
the `documentHash` and the Base64 encoding of the submission, the API call,
LHDNM's validation, the Unique Identifier Number and the QR code it returns,
the 72-hour window in which a document may be rejected or cancelled — all of
it belongs to a transport. In Ekwo, the signature and the transport are for
Ekwo Cloud. **It reads no clock and no network**: the moment of issuance is
given, and every code list is in the package.

## The interface

```ts
interface MyInvoisInput {
  header: Row; lines: Row[]; taxes: Row[];
  version?: '1.0' | '1.1';               // 1.1 when left out
  kind?: 'invoice' | 'credit-note' | 'debit-note' | 'refund-note';
  issuedAt: string;                       // ISO 8601 with its offset
  supplier: PartyIdentifiers & { activity?: { msic: string; description: string } };
  buyer: PartyIdentifiers;
  adjusts?: { number: string; uuid: string }[];   // what a note adjusts
  exchangeRate?: Numeric;                 // ringgit per unit, where the currency is not MYR
  taxCurrency?: string;                   // 'MYR': the tax written in ringgit, from tax_charged_in_tax_currency
  paymentMode?: string;                   // a code of LHDNM's payment modes
}

interface PartyIdentifiers {
  tin?: string;                           // the TIN LHDNM assigned
  registration?: { scheme: 'BRN' | 'NRIC' | 'PASSPORT' | 'ARMY'; id: string };
  sst?: string;                           // one or two numbers, or 'NA'
  tourismTax?: string;                    // the supplier's, or 'NA'
  phone?: string;                         // E.164
  state?: string;                         // a state code, where the header's region does not give it
}

MYINVOIS.write(input, syntax = 'json'): {
  content; filename; mediaType; syntax;
  typeCode;                               // 01–04, 11–14
  version; requiresSignature;             // true for 1.1
  violations;                             // { code, message, line? }
}
```

- **Which document.** A `sale_invoice` is an invoice (`01`) and a
  `sale_credit_note` a credit note (`02`) without being told. The books keep
  no separate type for a debit note or a refund note — a debit note is booked
  as an invoice that adds to an earlier one, a refund note as a credit note
  whose money went back — so `kind: 'debit-note'` (`03`) and
  `kind: 'refund-note'` (`04`) are asked for by name, and refused on a
  document of the other side.
- **Self-billed.** A `purchase_invoice` or `purchase_credit_note` is a
  document the company issues as the buyer: `11` to `14`. In the views
  `seller_*` is always the company and `buyer_*` its contact, so on a
  purchase the two change places — the contact is written as
  `AccountingSupplierParty`, the company as `AccountingCustomerParty` — and
  `supplier` and `buyer` in the input always mean the parties of the
  document, as the SDK names them.
- **The version is 1.1 unless 1.0 is asked for.** LHDNM recommends 1.1
  (FAQ) and accepts version 1.0 without a signature "until such time as
  \[it\] issues an official notice concerning the retirement of version 1.0".
  A 1.1 document written here is complete once signed, and
  `requiresSignature` says so.
- **The moment of issuance** is written in UTC, which is what the SDK asks
  for `IssueDate` and `IssueTime`. It is not the date of the document in the
  books: a document issued at 07:00 in Kuala Lumpur is issued the day before
  in UTC.

`write` throws a `MyInvoisError` for what makes a document absurd: no
document, a quote or an order, a document never numbered, no currency, no
line, an amount that is not a number, a moment that is not ISO 8601 with an
offset, a kind the document cannot be. Everything else comes back in
`violations`, beside a document that says what it was given.

## The figures are the books' figures

Nothing is recomputed. Totals, bases and taxes are written as they were
posted, and where they do not add up the mathematical mapping of the SDK they
break is named rather than the figure corrected. No figure passes through a
`number`: amounts arrive as the text Postgres prints a `numeric` as, are
compared as exact decimals on `bigint` — `src/decimal.ts` is the file of
`@ekwo-ai/peppol-ubl`, byte for byte, and a test compares the two — and are
written in the JSON as the same digits, unquoted: a JSON number is a decimal
in text.

Three figures are derived, each without rounding:

- **The subtotal of a line** (`ItemPriceExtension`) is its price times its
  quantity, exactly, and **its discount** the subtotal less the net amount
  the books posted, with the rate (`MultiplierFactorNumeric`) the keyed
  percentage over a hundred.
- **The tax of a line.** The books round the tax of all the lines under one
  tax once, so the tax of a line is a figure they hold only where the line is
  alone under its tax, or where the row carries it (`tax_amount`). Otherwise
  it is base times rate, written only where that is exact to the cent for
  every line of the tax and adds up to what was posted; anywhere else it is
  reported, `input:line_tax_amount`.
- **The amount payable** is the total including tax. A payment received
  after the document was issued is a payment, not the prepayment
  `PrepaidPayment` records, and the books do not say when it was received.

A credit note's figures are positive, as the books hold them and as LHDNM's
samples write them: its type code says what it is.

## Violations

Each violation is `{ code, message, line? }`, the shape of
`EinvoiceViolation` in the core:

| Code | What it is |
|---|---|
| `CF…`, `CV…` | **LHDNM's own error code**, where the SDK publishes one for the rule, with LHDNM's own sentence |
| `required:<element>` | A field the SDK's data structure marks mandatory, and the document does not hold |
| `length:<element>` | A value longer than the SDK's "Number of Chars" allows |
| `format:<element>` | A value not shaped as the SDK describes it, where it publishes no code for it |
| `math:<element>` | A total that is not what the SDK's mathematical mappings make of the figures beside it |
| `input:<what>` | What the books do not hold and the caller gives: `input:supplier_tin`, `input:tax_type`, `input:classification`… |

**Empty `violations` is the only state to submit in.** A document that breaks
a rule leaves out what it does not know, and the schema may refuse it too.

| Code | What is checked |
|---|---|
| CF345, CF346 | An address line of the supplier, of the buyer, longer than 150 characters |
| CF404 | A city longer than 50 characters |
| CF405 | A postcode of more than five digits in Malaysia, or longer than 50 characters elsewhere |
| CF406 | An SST registration number: letters, digits and dashes, at most two separated by `;`, at most 35 characters, or `NA` |
| CF407, CF412 | A tourism tax registration number: letters, digits and dashes, at most 17 characters, or `NA` |
| CF408, CF409, CF410 | A telephone: digits and a leading `+`, between 8 and 20 characters |
| CF400, CF401, CF411 | An e-mail address: its shape, and at most 320 characters |
| CV302 | A code outside its list: currency, payment mode, MSIC, classification, unit, tax type, state, country |
| CV316 | A state code 01–16 on an address outside Malaysia |
| CV317 | State code 17 on an address in Malaysia (it is for a foreign address, and for a consolidated e-Invoice, which this package does not write) |
| `required:` | The names of both parties, their registration or identification number, address line, city, state, country and telephone; the supplier's business activity description; each line's description, unit price and subtotal; the reason of a tax exemption (`E`); the number and UUID of an adjusted document |
| `length:` | The document number (50), the names (300), the TIN (14), a BRN (20), an NRIC, passport or army number (12), the MSIC code (five digits), the activity description (300), the bank account (150), the payment terms (300), the bill reference (150), a line's description (300), a reason of exemption (300), a UUID (26) |
| `format:` | A TIN: `IG` and digits for an individual; for a non-individual one of the prefixes `C`, `CS`, `D`, `F`, `FA`, `PT`, `TA`, `TC`, `TN`, `TR`, `TP`, `J`, `LE`, then digits that start with no zero and end with one (FAQ); a general TIN, `EI…`, is not checked |
| `math:` | The total including tax against the total excluding tax plus the tax; the total tax against its tax types; the net total against the lines; per tax type, the tax against the taxes of its lines and the base against their net amounts (except for an exemption, `E`); per line, the net against the subtotal less the discount |
| `input:` | The TIN of each party; the supplier's SST and tourism tax numbers (the supplier alone knows whether it is registered); its MSIC code; the buyer's telephone, which the views do not publish; the tax type of each tax; the classification of each line; the tax of a line the books did not keep; the net price of a line keyed with its tax; the exchange rate of a foreign currency; the payment mode of an account to pay into; the adjusted document of a note; a country with no three-letter code in LHDNM's list |

What only LHDNM can check is not checked here: that a TIN exists and goes
with the identification beside it (the taxpayer validator, `ERR…`), that a
referenced UUID is a valid document of the same supplier and buyer (`DR…`),
that a document is not a duplicate, and the signature.

## From the rows to the document

### `document_header`

| Column | Becomes |
|---|---|
| `number` | `cbc:ID`, the e-Invoice code or number |
| `doc_type` | `cbc:InvoiceTypeCode`, with `kind`: see above |
| `currency_code` | `cbc:DocumentCurrencyCode`, and `cac:TaxExchangeRate` from it to MYR where it is not MYR |
| `amount_untaxed` | `LineExtensionAmount` and `TaxExclusiveAmount` |
| `amount_tax` | `cac:TaxTotal/cbc:TaxAmount` |
| `amount_total` | `TaxInclusiveAmount` and `PayableAmount` |
| `payment_terms` | `cac:PaymentTerms/cbc:Note` |
| `payment_reference` | `cac:BillingReference/cac:AdditionalDocumentReference/cbc:ID`, the bill reference number |
| `payee_iban` | `cac:PayeeFinancialAccount/cbc:ID`, written with a `paymentMode` |
| `{side}_legal_name`, else `{side}_name` | `cac:PartyLegalEntity/cbc:RegistrationName` |
| `{side}_registration_number` | The BRN, where no `registration` is given: the SSM number, ISO 6523 scheme `0230` in the Malaysian pack |
| `{side}_address_line1`, `_line2` | `cac:AddressLine/cbc:Line` |
| `{side}_city`, `_postal_code` | `cbc:CityName`, `cbc:PostalZone` |
| `{side}_region` | `cbc:CountrySubentityCode`: a state code as it is, the name of a state of LHDNM's list as its code, a foreign region as it is, `17` for a foreign address with none |
| `{side}_country` | `cac:Country/cbc:IdentificationCode`, ISO 3166-1 alpha-3 |
| `seller_phone`, `{side}_email` | `cac:Contact` |

### `document_line_items`: one `cac:InvoiceLine` per `product` line

| Column | Becomes |
|---|---|
| `sequence` | `cbc:ID` |
| `quantity`, `unit_code` | `cbc:InvoicedQuantity` and its `@unitCode` |
| `amount_untaxed` | `cbc:LineExtensionAmount`, and the base of its tax |
| `unit_price` (or `net_unit_price` where the price holds its tax) | `cac:Price/cbc:PriceAmount` |
| `discount_percent` | `cac:AllowanceCharge`, with `ChargeIndicator` false |
| `item_name`, else `item_description` | `cac:Item/cbc:Description` |
| `vat_rate` | `cac:TaxSubtotal/cbc:Percent` |
| `tax_code`, else `vat_category` and `vat_rate` | Which tax of the breakdown the line was booked under |
| `myinvois_classification` | `cac:CommodityClassification/cbc:ItemClassificationCode[@listID="CLASS"]`, one code or several separated by commas, each checked against LHDNM's list |
| `exemption_reason` | The `TaxExemptionReason` of this line, over the one of its tax |

### `document_tax_summary`: the taxes, one `cac:TaxSubtotal` per tax type

`base_amount` and `tax_charged` of every row of one LHDNM tax type are added
into one `TaxableAmount` and one `TaxAmount`; `exemption_reason` is the
`TaxExemptionReason` of an exemption (`E`) — in the breakdown, the reasons
of its lines, each the line's own or its tax's — and `TaxableAmount` the
amount exempted. Where `taxCurrency` is given for a document in another
currency, as LHDNM's foreign currency sample does, `cbc:TaxCurrencyCode` is
written, and every `TaxAmount` — of the document, of each subtotal, of each
line — is in it, from `tax_charged_in_tax_currency` of each row: the tax as
the books posted it in ringgit. The taxable amounts and the totals stay in
the document's currency. A line that shares its tax with others has no tax
of its own in ringgit, which the books posted once for the group, and is
reported (`input:line_tax_in_tax_currency`). `cac:TaxScheme/cbc:ID` is `OTH`
in the scheme `UN/ECE 5153`, agency `6`, as every sample of the SDK writes
it: Malaysia's taxes are not a value added tax.

### What the rows must carry for the document to be complete

None of it is in the three views alone. In Ekwo OS the core gives it, from
the country pack and from the books (`EINVOICE_FORMATS` in `@ekwo-ai/core`,
profile `myinvois`): the pack's fiscalisation regime gives each tax its
`myinvois_tax_type` and every line its `myinvois_classification`, and
`companies.identifiers` and `contacts.identifiers` give each party its TIN,
its SST and tourism tax registrations by scheme. Any other caller gives it:

- **`myinvois_tax_type`** on each row of `document_tax_summary` (or on a
  line): `01` Sales Tax, `02` Service Tax, `03` Tourism Tax, `04` High-Value
  Goods Tax, `05` Sales Tax on Low Value Goods, `06` Not Applicable, `E` Tax
  exemption. Nothing in the books decides it: a category `S` at 10 % is the
  Sales Tax in the Malaysian pack and could be any tax in another, and
  whether an export or a sale outside the scope of the tax is `06` or `E` is
  a reading of the law this package does not make.
- **`myinvois_classification`** on each line: one code of LHDNM's 45, or
  several. It describes what was sold for LHDNM's purposes — a computer, a
  donation, a disbursement, `022` Others — which the books do not record.
- **`tax_amount`** on a line that shares its tax with others, where base
  times rate is not exact to the cent.
- **`tax_code`** on a line, where two taxes of the document share a category
  and a rate.

## Named gaps

What this package does not write, because it could not be sourced, because
the books do not hold it, or because it is not a document's to do:

- **The signature, the submission, the UIN and the QR code**, as said above.
- **The consolidated e-Invoice** (classification `004`, the general TIN
  `EI00000000010`, state `17`) and every **general TIN** for a buyer or a
  supplier that has none — foreign buyers, foreign suppliers of a self-billed
  invoice, individuals. The taxpayer validator's codes name them (`010`,
  `020`, `030`, `040`), but the SDK pages read for this package publish
  neither the full numbers nor the rules of their use beyond the consolidated
  sample, and none is invented here: a TIN is always given.
- **Fixed-rate taxes**: `PerUnitAmount` and `BaseUnitMeasure`, the way the
  tourism tax is charged per room per night. The books hold a tax as a rate.
- **Invoice-level allowances and charges**, `PrepaidPayment`,
  `PayableRoundingAmount`, `InvoicePeriod` (frequency and period of billing),
  the shipping recipient (`cac:Delivery`), the customs forms No. 1, 2 and 9,
  the Incoterms, the free trade agreement, the certified exporter's
  authorisation, the product tariff code (`PTC`) and the country of origin:
  the views carry none of them.
- **The special characters of a reason of exemption.** The SDK limits the
  text to letters, digits and `. - , ( )`, and its own example, "Reference
  No: ABC.TAX(S)012-3/4/56(7)", holds a colon and slashes. The rule is not
  checked until the two agree.
- **Five countries of LHDNM's list** have no pair in the UN table this
  package maps two-letter codes from — `ANT`, `CRM`, `SCT`, `TWN`, `XKX` — and
  a document to or from them is reported (`input:<role>_country`).
- **The shape of a BRN, an NRIC, a passport or an army number**: the SDK
  publishes their lengths and not their form, and only the lengths are
  checked. A TIN is checked against the shape the FAQ describes, and whether
  it exists is LHDNM's to say.
- **SVDP 1.2 and 1.3**, the document versions of the Special Voluntary
  Disclosure Programme, which allow a backdated moment of issuance during
  the programme only.

## Sources

Read on 19 October 2026 on the MyInvois SDK of LHDNM,
<https://sdk.myinvois.hasil.gov.my/>, last updated 25 September 2026
(release notes, SDK 1.0):

- **The document types**, each with its data structure — field, UBL path,
  mandatory or not, number of characters, cardinality: Invoice
  (<https://sdk.myinvois.hasil.gov.my/documents/invoice-v1-1/>, and
  `invoice-v1-0`), Credit Note (`credit-v1-1`), Debit Note (`debit-v1-1`),
  Refund Note (`refund-v1-1`), and the self-billed four
  (`self-billed-invoice-v1-1`, `self-billed-credit-v1-1`,
  `self-billed-debit-v1-1`, `self-billed-refund-v1-1`), under
  `https://sdk.myinvois.hasil.gov.my/documents/`.
- **The samples** of each document type, in JSON and XML,
  `https://sdk.myinvois.hasil.gov.my/files/sdksamples/`; the JSON ones are
  kept under `test/fixtures/sdk/`, with their checksums.
- **The mathematical mappings**,
  <https://sdk.myinvois.hasil.gov.my/mathematical-mappings/>.
- **The validators and their error codes**,
  <https://sdk.myinvois.hasil.gov.my/document-validation-rules/>, and the
  pages of the core fields (`CF…`), code (`CV…`), currency (`DC…`),
  referenced documents (`DR…`) and taxpayer (`ERR…`) validators under
  `https://sdk.myinvois.hasil.gov.my/documentvalidationrules/`.
- **The FAQ**, <https://sdk.myinvois.hasil.gov.my/faq/> — the shape of a
  TIN, versions 1.0 and 1.1, the signature, the size of a submission.
- **The signature**, <https://sdk.myinvois.hasil.gov.my/signature/>, which
  this package leaves to the host.

**The code tables**, each from its page and the JSON file LHDNM publishes
beside it, kept unmodified under `test/codelist/` and compiled into
`src/codelists.ts` by `scripts/build-codelists.mjs`:

| Table | Page | File | Exported as |
|---|---|---|---|
| e-Invoice types (8) | <https://sdk.myinvois.hasil.gov.my/codes/e-invoice-types/> | `EInvoiceTypes.json` | `EINVOICE_TYPES` |
| Tax types (7) | <https://sdk.myinvois.hasil.gov.my/codes/tax-types/> | `TaxTypes.json` | `TAX_TYPES` |
| Classification codes (45) | <https://sdk.myinvois.hasil.gov.my/codes/classification-codes/> | `ClassificationCodes.json` | `CLASSIFICATION_CODES` |
| MSIC codes (1,175 rows, 1,174 codes: `16211` is listed twice) | <https://sdk.myinvois.hasil.gov.my/codes/msic-codes/> | `MSICSubCategoryCodes.json` | `MSIC_CODES` |
| State codes (17) | <https://sdk.myinvois.hasil.gov.my/codes/state-codes/> | `StateCodes.json` | `STATE_CODES` |
| Country codes (253, ISO 3166-1 alpha-3) | <https://sdk.myinvois.hasil.gov.my/codes/countries/> | `CountryCodes.json` | `COUNTRY_CODES` |
| Currency codes (180, ISO 4217) | <https://sdk.myinvois.hasil.gov.my/codes/currencies/> | `CurrencyCodes.json` | `CURRENCY_CODES` |
| Unit types (2,162, UN/ECE Recommendation 20) | <https://sdk.myinvois.hasil.gov.my/codes/unit-types/> | `UnitTypes.json` | `UNIT_CODES` |
| Payment modes (8) | <https://sdk.myinvois.hasil.gov.my/codes/payment-methods/> | `PaymentMethods.json` | `PAYMENT_MODES` |

**ISO 3166-1, two letters to three.** The books hold a country as its
two-letter code and MyInvois wants the three-letter one; the pairs are the
columns "ISO-alpha2 Code" and "ISO-alpha3 Code" of the M49 table of the
United Nations Statistics Division, *Standard country or area codes for
statistical use (M49)*, <https://unstats.un.org/unsd/methodology/m49/overview/>,
read on 19 October 2026 and kept as `test/codelist/m49-iso-alpha.csv`. A
pair is kept where its three-letter code is in LHDNM's list (`ALPHA3`, 248
pairs).

**The schema.** OASIS UBL 2.1, the schemas `@ekwo-ai/peppol-ubl` keeps under
its `test/xsd/`: `test/schema.test.ts` validates every XML document against
them from there.

**The law.** Income Tax Act 1967, section 82C, and the Income Tax (Issuance
of Electronic Invoice) Rules 2024 \[P.U. (A) 265/2024\], as the Malaysian
pack of Ekwo OS cites them (`packs/my/pack.json`).

## Licence

MIT. The files under `test/codelist/` and `test/fixtures/sdk/` are LHDNM's
and the United Nations', kept as published, are fixtures of the tests, and
are not part of the published package.
