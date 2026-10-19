/**
 * The shapes this package reads and returns.
 *
 * A MyInvois document is written from one posted document as the books hold
 * it: one row of `document_header`, the rows of `document_line_items` and the
 * rows of `document_tax_summary` in [Ekwo OS](https://github.com/Ekwo-ai/ekwo-os),
 * plus what the books do not hold and MyInvois requires — the LHDNM
 * identifiers of both parties, the supplier's MSIC code, the moment of
 * issuance, and, for a note, the Unique Identifier Number LHDNM gave the
 * invoice it adjusts.
 *
 * The rows arrive as `Row`, a record of columns, because that is what a
 * database read returns; the interfaces below say which columns are read and
 * what each becomes in the document. A row that carries more is accepted as
 * it is, and nothing is ever filled in for a column that is absent: what the
 * document needs and the row does not say is named in `violations`.
 */

/** A row as a database read returns it: columns by name. */
export type Row = Readonly<Record<string, unknown>>;

/** A `numeric` as it is read from the database. A string keeps every digit. */
export type Numeric = string | number;

/** ISO-8601 calendar date, `YYYY-MM-DD`. */
export type IsoDate = string;

/**
 * The columns of `document_header` a document reads.
 *
 * `seller_*` is always the company that keeps the books and `buyer_*` always
 * its contact, whatever the document. On a sale the company is the
 * supplier; on a purchase it is the buyer, and the document it issues is
 * self-billed — so the two sides change places in the file, never in the row.
 */
export interface DocumentHeaderRow {
  /**
   * `sale_invoice`, `sale_credit_note`: issued by the company as supplier.
   * `purchase_invoice`, `purchase_credit_note`: issued by the company as
   * buyer, self-billed. Anything else is refused.
   */
  doc_type: string;
  /** `cbc:ID`, the e-Invoice code or number. A document without one was never issued, and is refused. */
  number: string | null;
  /** `cbc:DocumentCurrencyCode`. */
  currency_code: string;
  /** `cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount` and `cbc:LineExtensionAmount`. */
  amount_untaxed: Numeric;
  /** `cac:TaxTotal/cbc:TaxAmount`. */
  amount_tax: Numeric;
  /** `cbc:TaxInclusiveAmount` and `cbc:PayableAmount`. */
  amount_total: Numeric;
  /** `cac:PaymentTerms/cbc:Note`. */
  payment_terms?: string | null;
  /** `cac:BillingReference/cac:AdditionalDocumentReference/cbc:ID`, the bill reference number. */
  payment_reference?: string | null;
  /** `cac:PayeeFinancialAccount/cbc:ID`, written where a payment mode is given. */
  payee_iban?: string | null;

  seller_name: string | null;
  /** `cac:PartyLegalEntity/cbc:RegistrationName`, before `seller_name`. */
  seller_legal_name?: string | null;
  /** The BRN where no identification is given: the SSM number, ISO 6523 scheme 0230. */
  seller_registration_number?: string | null;
  seller_address_line1?: string | null;
  seller_address_line2?: string | null;
  seller_postal_code?: string | null;
  seller_city?: string | null;
  /** ISO 3166-1 alpha-2, written as alpha-3. */
  seller_country?: string | null;
  /** A state code, or the name of a state of the published list; a foreign region as it is. */
  seller_region?: string | null;
  seller_email?: string | null;
  seller_phone?: string | null;

  buyer_name: string | null;
  buyer_registration_number?: string | null;
  buyer_address_line1?: string | null;
  buyer_address_line2?: string | null;
  buyer_postal_code?: string | null;
  buyer_city?: string | null;
  buyer_country?: string | null;
  buyer_region?: string | null;
  buyer_email?: string | null;
}

/** The columns of `document_line_items` a document reads: one `cac:InvoiceLine` per `product` line. */
export interface DocumentLineRow {
  /** `cbc:ID`. */
  sequence?: number | string | null;
  /** `product` lines are what was sold; a section or a note is layout and is skipped. */
  line_type?: string | null;
  /** `cac:Item/cbc:Description`. */
  item_name: string | null;
  /** `cac:Item/cbc:Description` where the line has no name. */
  item_description?: string | null;
  /** `cbc:InvoicedQuantity`. */
  quantity?: Numeric | null;
  /** `cbc:InvoicedQuantity/@unitCode`, UN/ECE Recommendation 20. */
  unit_code?: string | null;
  /** `cac:Price/cbc:PriceAmount`, as keyed. */
  unit_price?: Numeric | null;
  /** A discount on the line: `cac:AllowanceCharge` with its rate and its amount. */
  discount_percent?: Numeric | null;
  /** The keyed price holds the tax: the price without it is read from `net_unit_price`. */
  unit_price_includes_tax?: boolean | null;
  /** Not in the view today. The price without its tax, where the keyed one holds it. */
  net_unit_price?: Numeric | null;
  /** `cbc:LineExtensionAmount`, the books' net amount of the line. */
  amount_untaxed: Numeric;
  /** With `vat_rate`, finds the tax row the line was booked under. */
  vat_category?: string | null;
  /** `cac:TaxSubtotal/cbc:Percent`. */
  vat_rate?: Numeric | null;

  // Not in the view today: what the line must carry for the document to be
  // complete, and the pack or the caller can pass.

  /** The tax row of the line, by code: wins over the category and the rate. */
  tax_code?: string | null;
  /** `cac:InvoiceLine/cac:TaxTotal/cbc:TaxAmount`, where the books hold the tax of the line itself. */
  tax_amount?: Numeric | null;
  /** The LHDNM tax type of the line, where its tax row does not say it. */
  myinvois_tax_type?: string | null;
  /**
   * `cac:CommodityClassification/cbc:ItemClassificationCode[@listID="CLASS"]`:
   * one code of LHDNM's list, or several. A fact of what was sold that the
   * books do not record; absent, it is reported.
   */
  myinvois_classification?: string | readonly string[] | null;
}

/** The columns of `document_tax_summary` a document reads: the taxes of the document, one row per tax. */
export interface DocumentTaxRow {
  tax_code?: string | null;
  vat_category?: string | null;
  tax_rate?: Numeric | null;
  /** `cac:TaxSubtotal/cbc:TaxableAmount`, added up per tax type. */
  base_amount: Numeric;
  /** `cac:TaxSubtotal/cbc:TaxAmount`, added up per tax type. */
  tax_charged: Numeric;
  /** `cac:TaxCategory/cbc:TaxExemptionReason`, required where the tax type is `E`. */
  exemption_reason?: string | null;
  /**
   * Not in the view today. The LHDNM tax type of this tax — `01` Sales Tax,
   * `02` Service Tax, `06` Not Applicable, `E` exemption — which the pack can
   * carry beside each tax. Nothing in the books decides it: a category `S`
   * at 10 % is Sales Tax in one pack and could be another tax in the next.
   */
  myinvois_tax_type?: string | null;
}

/** How LHDNM identifies a party besides its TIN. */
export type RegistrationScheme = 'BRN' | 'NRIC' | 'PASSPORT' | 'ARMY';

/** What MyInvois asks of a party and the books do not hold. */
export interface PartyIdentifiers {
  /** `cbc:ID[@schemeID="TIN"]`: the Tax Identification Number LHDNM assigned. Required. */
  tin?: string | null;
  /**
   * `cbc:ID[@schemeID="BRN" | "NRIC" | "PASSPORT" | "ARMY"]`. Absent, the
   * party's registration number in the header is written as its BRN.
   */
  registration?: { scheme: RegistrationScheme; id: string } | null;
  /**
   * `cbc:ID[@schemeID="SST"]`: one or two SST registration numbers separated
   * by `;`, or `NA`. Required of the supplier, who alone knows whether it is
   * registered; absent for the buyer, `NA` is written, as the SDK says the
   * supplier does when the buyer's number is not provided.
   */
  sst?: string | null;
  /** `cbc:ID[@schemeID="TTX"]`, the supplier's tourism tax registration number, or `NA`. Required of the supplier. */
  tourismTax?: string | null;
  /** `cac:Contact/cbc:Telephone`, E.164. Wins over the header; required, and the header holds no buyer's phone. */
  phone?: string | null;
  /** `cbc:CountrySubentityCode`, where the header's region does not give it. */
  state?: string | null;
}

/** The supplier's activity: `cbc:IndustryClassificationCode` and its `@name`. */
export interface SupplierActivity {
  /** Five digits, a code of LHDNM's MSIC list. */
  msic: string;
  /** The supplier's own description of its business activity. */
  description: string;
}

/** The document a note adjusts: `cac:BillingReference/cac:InvoiceDocumentReference`. */
export interface AdjustedDocument {
  /** `cbc:ID`: the e-Invoice number of that document. */
  number: string;
  /** `cbc:UUID`: the Unique Identifier Number LHDNM returned when it validated that document. */
  uuid: string;
}

/** Which of LHDNM's documents is written. The self-billed ones follow from a purchase. */
export type DocumentKind = 'invoice' | 'credit-note' | 'debit-note' | 'refund-note';

/** One document to write. */
export interface MyInvoisInput {
  header: Row;
  lines: readonly Row[];
  taxes: readonly Row[];
  /**
   * `cbc:InvoiceTypeCode/@listVersionID`. `1.1` is signed and `1.0` is not;
   * this package signs nothing, so a `1.1` document is complete only once the
   * host has added its signature. Stated, never assumed.
   */
  version: '1.0' | '1.1';
  /**
   * An invoice is `invoice` and a credit note `credit-note` without being
   * told. A debit note is booked as an invoice and a refund note as a credit
   * note, so the two are asked for by name.
   */
  kind?: DocumentKind;
  /**
   * `cbc:IssueDate` and `cbc:IssueTime`: the moment the document is issued,
   * ISO 8601 with its offset (`2026-01-15T10:30:00+08:00`) or `Z`. Written
   * in UTC, as the SDK asks. The date of the books is the accounting date
   * and is not this moment, which is why it is given and never read from a
   * clock here.
   */
  issuedAt: string;
  /** The MyInvois supplier — the company on a sale, its contact on a self-billed purchase. */
  supplier: PartyIdentifiers & { activity?: SupplierActivity | null };
  /** The MyInvois buyer — the contact on a sale, the company on a self-billed purchase. */
  buyer: PartyIdentifiers;
  /** Required of a credit, debit or refund note: the documents it adjusts. */
  adjusts?: readonly AdjustedDocument[];
  /** `cac:TaxExchangeRate/cbc:CalculationRate`: ringgit per unit of the document's currency, where it is not MYR. */
  exchangeRate?: Numeric | null;
  /** `cac:PaymentMeans/cbc:PaymentMeansCode`, a code of LHDNM's list of payment modes. */
  paymentMode?: string | null;
}

/**
 * A rule the document breaks, or something it needs and the rows do not carry.
 * The same shape as `EinvoiceViolation` in the core, so a host can keep it
 * beside the file.
 */
export interface Violation {
  /**
   * LHDNM's own error code where the SDK publishes one for the rule —
   * `CF405`, `CV316`, `CV302` — which is what MyInvois answers with. Else:
   * `required:<element>` for a field the SDK marks mandatory and the document
   * does not hold, `length:<element>` for a value longer than the SDK allows,
   * `format:<element>` for a value not shaped as the SDK describes it,
   * `math:<element>` for a total that is not what the SDK's mathematical
   * mappings make of the figures beside it, and `input:<what>` for what the
   * books do not hold and the caller must give.
   */
  code: string;
  message: string;
  /** The `cbc:ID` of the line, where the rule is a line's. */
  line?: string;
}

/** The two syntaxes MyInvois accepts. */
export type Syntax = 'json' | 'xml';

/** A written document. */
export interface WrittenDocument {
  /** UTF-8 text: UBL 2.1 in its JSON or XML syntax. */
  content: string;
  filename: string;
  mediaType: 'application/json' | 'application/xml';
  syntax: Syntax;
  /** `cbc:InvoiceTypeCode`: `01` to `04`, `11` to `14`. */
  typeCode: string;
  version: '1.0' | '1.1';
  /** True for `1.1`: the host signs it before it is submitted. */
  requiresSignature: boolean;
  /** Empty is the only state to submit in. */
  violations: Violation[];
}

/** The brick, as a host registers it beside the other e-invoicing formats. */
export interface MyInvoisFormat {
  format: 'myinvois';
  brick: '@ekwo-ai/myinvois';
  syntax: 'UBL 2.1';
  specification: string;
  write(input: MyInvoisInput, syntax?: Syntax): WrittenDocument;
}
