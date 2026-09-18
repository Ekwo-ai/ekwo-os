/**
 * The shapes this package reads and returns.
 *
 * The three row types are the columns of `document_header`,
 * `document_line_items` and `document_tax_summary` in
 * [Ekwo OS](https://github.com/Ekwo-ai/ekwo-os), declared here so that nothing
 * is imported from it: a posted document, its lines and its VAT breakdown as
 * the books hold them. Any invoicing system that can produce the same three
 * things can use this package; it reads no database and knows no accounting.
 *
 * Only the columns this format has a place for are declared, and a row that
 * carries more is accepted as it is. One field is marked *not in the view
 * today*: the net price of a line keyed with its tax in it, which the books
 * have not decided how to round. Nothing is ever filled in for a field that
 * is absent.
 */

/** A `numeric` as it is read from the database. A string keeps every digit. */
export type Numeric = string | number;

/** ISO-8601 calendar date, `YYYY-MM-DD`. */
export type IsoDate = string;

/** One row of `document_header`: everything printed above the lines. */
export interface DocumentHeaderRow {
  /**
   * `sale_invoice` or `sale_credit_note`. Anything else is refused outright: a
   * purchase is somebody else's invoice and a quote is not an invoice at all.
   */
  doc_type: string;
  /** BT-1. A document without a number was never issued, and is refused. */
  number: string | null;
  /** BT-2. */
  document_date: IsoDate;
  /** BT-9. */
  due_date?: IsoDate | null;
  /** BT-72. */
  delivery_date?: IsoDate | null;
  /** BT-7. */
  tax_point_date?: IsoDate | null;
  /** BT-5. There is no default: a document without a currency is refused. */
  currency_code: string;

  /** BT-109. Also written as BT-106: this model has no document-level allowance or charge. */
  amount_untaxed: Numeric;
  /** BT-110. */
  amount_tax: Numeric;
  /** BT-112. */
  amount_total: Numeric;
  /** BT-113. Left out of the file when it is zero or absent. */
  amount_paid?: Numeric | null;
  /** BT-115. Where it is absent, the total less what was paid — which is its definition (BR-CO-16). */
  amount_residual?: Numeric | null;

  /** BT-20. */
  payment_terms?: string | null;
  /** BT-81, UNTDID 4461. Without it no payment instruction is written, IBAN or not. */
  payment_means_code?: string | null;
  /** BT-83. */
  payment_reference?: string | null;
  /** BT-84. */
  payee_iban?: string | null;
  /** BT-86. */
  payee_bic?: string | null;

  /** BT-10. */
  buyer_reference?: string | null;
  /** BT-13. */
  order_reference?: string | null;
  /** BT-12. */
  contract_reference?: string | null;
  /** BT-11. */
  project_reference?: string | null;
  /** BT-22. */
  note?: string | null;

  /** BT-28 where a legal name is given beside it, BT-27 otherwise. */
  seller_name: string | null;
  /** BT-27. */
  seller_legal_name?: string | null;
  /** BT-33. */
  seller_legal_form?: string | null;
  /** BT-31, with its country prefix. */
  seller_vat_number?: string | null;
  /** BT-30. */
  seller_registration_number?: string | null;
  seller_address_line1?: string | null;
  seller_address_line2?: string | null;
  seller_postal_code?: string | null;
  seller_city?: string | null;
  /** BT-40, ISO 3166-1 alpha-2. */
  seller_country?: string | null;
  seller_region?: string | null;
  /** BT-43. */
  seller_email?: string | null;
  /** BT-42. */
  seller_phone?: string | null;

  /** BT-44. */
  buyer_name: string | null;
  /** BT-48. */
  buyer_vat_number?: string | null;
  /** BT-47. */
  buyer_registration_number?: string | null;
  buyer_address_line1?: string | null;
  buyer_address_line2?: string | null;
  buyer_postal_code?: string | null;
  buyer_city?: string | null;
  /** BT-55. */
  buyer_country?: string | null;
  buyer_region?: string | null;
  /** BT-58. */
  buyer_email?: string | null;

  /**
   * BT-34 and BT-49, the electronic addresses: a scheme of the EAS list and a
   * value, as the seller and the buyer are registered. `options.sellerEndpoint`
   * and `options.buyerEndpoint` take precedence where they are given.
   */
  seller_peppol_scheme?: string | null;
  seller_peppol_identifier?: string | null;
  buyer_peppol_scheme?: string | null;
  buyer_peppol_identifier?: string | null;

  /** BG-15, the deliver-to address. */
  delivery_address_line1?: string | null;
  delivery_postal_code?: string | null;
  delivery_city?: string | null;
  /** BT-80. */
  delivery_country?: string | null;
}

/** One row of `document_line_items`. */
export interface DocumentLineRow {
  /** `product` lines are invoice lines. Anything else — a section, a note — is layout and is skipped. */
  line_type?: string | null;
  /** BT-126. Where it is absent the line is numbered by its position. */
  sequence?: number | string | null;
  /** BT-153. */
  item_name: string | null;
  /** BT-154. */
  item_description?: string | null;
  /** BT-155. */
  seller_item_identifier?: string | null;
  /** BT-129. */
  quantity: Numeric | null;
  /** BT-130, UN/ECE Recommendation 20. */
  unit_code?: string | null;
  /** The price as it was keyed: before the discount, and with the tax in it where `unit_price_includes_tax`. */
  unit_price?: Numeric | null;
  discount_percent?: Numeric | null;
  unit_price_includes_tax?: boolean | null;
  /**
   * BT-146, for a line whose price was keyed with the tax in it. Not in the
   * view today, and not worked out here: the net price of such a line is its
   * base divided by its quantity, which is a rounding decision and therefore
   * the books' to make.
   */
  net_unit_price?: Numeric | null;
  /** BT-131. */
  amount_untaxed: Numeric;
  /** BT-151, as the line was posted. A line that does not say is a line without a category (BR-CO-04). */
  vat_category?: string | null;
  /** BT-152, as the line was posted. */
  vat_rate?: Numeric | null;
  /** BT-121 of the tax on this line, carried up to the breakdown it belongs to. */
  tax_exemption_code?: string | null;
}

/** One row of `document_tax_summary`: one tax of the document, rounded once on its group. */
export interface DocumentTaxRow {
  /** BT-118. */
  vat_category: string | null;
  /** BT-119. */
  tax_rate?: Numeric | null;
  /** BT-116. */
  base_amount: Numeric;
  /** BT-117: what the buyer is charged, which is nothing where the tax is self-assessed. */
  tax_charged: Numeric;
  /** BT-121. Where it is absent the code of the lines of the group is used. */
  exemption_code?: string | null;
  /** BT-120: why the group charges nothing, in a sentence a customer can read. */
  exemption_reason?: string | null;
}

/** An electronic address (BT-34, BT-49): where the network delivers. */
export interface ElectronicAddress {
  /** The EAS scheme, e.g. `0088` for a GLN. There is no default. */
  scheme: string;
  id: string;
}

export interface PeppolUblOptions {
  /**
   * BT-34 and BT-49, for a caller whose header does not carry them, or to
   * send under another address than the one on file. Both are mandatory on the
   * network and neither is derived from anything: which identifier a
   * participant is registered under is a fact of the registration, not of its
   * VAT number.
   */
  sellerEndpoint?: ElectronicAddress;
  buyerEndpoint?: ElectronicAddress;
  /**
   * BT-30-1 and BT-47-1: the ISO 6523 scheme a registration number is written
   * in, e.g. `0208` for a Belgian enterprise number. Left out, the number
   * travels without one, which the standard allows. It is not read from the
   * books: what Ekwo OS calls `party_scheme` is the scheme a party is
   * *addressed* by, which is an electronic address scheme and, in more than one
   * country, not a scheme a registration number can be written in at all.
   */
  sellerRegistrationScheme?: string;
  buyerRegistrationScheme?: string;
  /** BG-3: the invoice a credit note credits, or a corrected invoice corrects. */
  precedingInvoice?: { number: string; issueDate?: IsoDate };
}

/** A posted sales document, as three reads of the books. */
export interface PeppolUblInput {
  header: DocumentHeaderRow;
  lines: readonly DocumentLineRow[];
  taxes: readonly DocumentTaxRow[];
}

/** A rule of the format this document breaks. */
export interface Violation {
  /**
   * The identifier the rule is published under — `BR-CO-15`,
   * `PEPPOL-EN16931-R003` — which is what a validator on the network will
   * report, and the only name worth branching on.
   */
  code: string;
  /** What is wrong, in a sentence. */
  message: string;
  /** The line the trouble is on, by its identifier (BT-126), where there is one. */
  line?: string;
}

export interface PeppolUbl {
  /** The XML, as text. */
  file: string;
  /** A name for it. The network imposes none. */
  filename: string;
  /** Every published rule the file breaks. Empty is the only state to send in. */
  violations: Violation[];
}
