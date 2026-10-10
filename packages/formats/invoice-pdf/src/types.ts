/**
 * The shapes this package reads and returns.
 *
 * The four row types are the columns of the views `document_header`,
 * `document_line_items`, `document_tax_summary` and `document_legal_mentions`
 * of [Ekwo OS](https://github.com/Ekwo-ai/ekwo-os), one field per column,
 * declared here so that nothing is imported from it. Any invoicing system that
 * can produce the same rows can use this package; it reads no database, fetches
 * nothing and knows no country.
 *
 * Every column is declared, including the ones the layout does not print
 * today, so that a row read with `select *` is accepted as it is. A field that
 * is absent or null is not printed; nothing is ever filled in for it.
 */

/** A `numeric` as it is read from the database. A string keeps every digit. */
export type Numeric = string | number;

/** ISO-8601 calendar date, `YYYY-MM-DD`. */
export type IsoDate = string;

/** One row of `document_header`: everything printed above the lines. */
export interface DocumentHeaderRow {
  document_id?: string | null;
  company_id?: string | null;
  /** `sale_invoice` or `sale_credit_note`. Anything else is refused: this package renders what a seller issues. */
  doc_type: string;
  /** `draft`, `posted` or `cancelled`. A draft is titled as one; a cancelled document says so under its title. */
  state?: string | null;
  payment_state?: string | null;
  /** Null on a draft: no number is printed and the title says draft. */
  number?: string | null;
  supplier_reference?: string | null;
  document_date: IsoDate;
  accounting_date?: IsoDate | null;
  due_date?: IsoDate | null;
  delivery_date?: IsoDate | null;
  /** ISO 4217. There is no default: a document without a currency is refused. */
  currency_code: string;
  amount_untaxed: Numeric;
  amount_tax: Numeric;
  amount_total: Numeric;
  amount_paid?: Numeric | null;
  /** What is still due. Printed as the last line of the totals. */
  amount_residual?: Numeric | null;
  payment_terms?: string | null;
  /** UNTDID 4461. Not printed: it is a code for a machine. */
  payment_means_code?: string | null;
  payment_reference?: string | null;
  buyer_reference?: string | null;
  order_reference?: string | null;
  contract_reference?: string | null;
  project_reference?: string | null;
  note?: string | null;
  payee_iban?: string | null;
  payee_bic?: string | null;

  seller_name: string | null;
  seller_legal_name?: string | null;
  seller_legal_form?: string | null;
  seller_vat_number?: string | null;
  seller_registration_number?: string | null;
  seller_address_line1?: string | null;
  seller_address_line2?: string | null;
  seller_postal_code?: string | null;
  seller_city?: string | null;
  /** ISO 3166-1 alpha-2. Printed as its name in the language of the document, through `Intl.DisplayNames`. */
  seller_country?: string | null;
  seller_region?: string | null;
  seller_email?: string | null;
  seller_phone?: string | null;
  seller_website?: string | null;
  /** Never fetched here: the caller passes the bytes as `logo`. */
  seller_logo_url?: string | null;
  seller_share_capital?: Numeric | null;
  seller_share_capital_currency?: string | null;
  seller_activity_code?: string | null;
  seller_activity_scheme?: string | null;
  document_template?: string | null;

  buyer_id?: string | null;
  buyer_name: string | null;
  buyer_vat_number?: string | null;
  buyer_registration_number?: string | null;
  buyer_address_line1?: string | null;
  buyer_address_line2?: string | null;
  buyer_postal_code?: string | null;
  buyer_city?: string | null;
  buyer_country?: string | null;
  buyer_region?: string | null;
  buyer_email?: string | null;

  /** The company's fiscal country. Not printed: what it requires arrives as mentions. */
  country?: string | null;
  number_format?: string | null;
  numbering_gapless?: boolean | null;
  legal_payment_days?: number | null;
  late_payment_reference?: string | null;
  tax_point_rule?: string | null;
  einvoice_profile?: string | null;
  einvoice_mandatory_from?: IsoDate | null;
  party_scheme?: string | null;
  vat_scheme?: string | null;

  /** BCP 47. The language amounts, dates and country names are written in. */
  language?: string | null;
  tax_point_date?: IsoDate | null;
  delivery_address_line1?: string | null;
  delivery_postal_code?: string | null;
  delivery_city?: string | null;
  delivery_country?: string | null;

  seller_peppol_scheme?: string | null;
  seller_peppol_identifier?: string | null;
  buyer_peppol_scheme?: string | null;
  buyer_peppol_identifier?: string | null;
}

/** One row of `document_line_items`. */
export interface DocumentLineRow {
  document_line_id?: string | null;
  document_id?: string | null;
  company_id?: string | null;
  sequence?: number | string | null;
  /** `product` is a line of the table; `section` a heading across it; `note` a sentence across it. */
  line_type?: string | null;
  item_name: string | null;
  item_description?: string | null;
  seller_item_identifier?: string | null;
  product_id?: string | null;
  product_kind?: string | null;
  quantity?: Numeric | null;
  /** UN/ECE Recommendation 20. Printed through `labels.units`, or as it is. */
  unit_code?: string | null;
  /** As keyed: before the discount, and with the tax in it where `unit_price_includes_tax`. */
  unit_price?: Numeric | null;
  discount_percent?: Numeric | null;
  amount_untaxed?: Numeric | null;
  tax_id?: string | null;
  vat_category?: string | null;
  vat_rate?: Numeric | null;
  account_id?: string | null;
  tax_treatment?: string | null;
  tax_exemption_code?: string | null;
  tax_cash_basis?: boolean | null;
  unit_price_includes_tax?: boolean | null;
  amount_incl_tax?: Numeric | null;
}

/** One row of `document_tax_summary`: one tax of the document. */
export interface DocumentTaxRow {
  document_id?: string | null;
  company_id?: string | null;
  doc_type?: string | null;
  tax_id?: string | null;
  tax_code?: string | null;
  /** Printed as the name of the group, in the language the books hold it in. */
  tax_name?: string | null;
  vat_category?: string | null;
  tax_rate?: Numeric | null;
  base_amount: Numeric;
  /** What the return reports. Not printed: the customer pays `tax_charged`. */
  tax_amount?: Numeric | null;
  tax_charged: Numeric;
  exemption_code?: string | null;
  /** Why the group charges nothing, in a sentence the country wrote. Printed under the group. */
  exemption_reason?: string | null;
  /** Written for whoever reviews the pack, not for a customer: not printed. */
  legal_reference?: string | null;
}

/** One row of `document_legal_mentions`: a sentence the country requires on this document. */
export interface DocumentLegalMentionRow {
  document_id?: string | null;
  company_id?: string | null;
  country?: string | null;
  code?: string | null;
  applies_when?: string | null;
  language?: string | null;
  /** Already in the language of the document. */
  text: string | null;
  text_i18n?: unknown;
  sequence?: number | string | null;
  legal_reference?: string | null;
}

/**
 * Every word the layout prints of its own. The English set is
 * {@link ENGLISH_LABELS}; a caller writing in another language passes its own,
 * whole or in part — what it leaves out is taken from the English set.
 */
export interface InvoiceLabels {
  invoice: string;
  creditNote: string;
  draftInvoice: string;
  draftCreditNote: string;
  cancelled: string;
  number: string;
  date: string;
  dueDate: string;
  deliveryDate: string;
  taxPointDate: string;
  buyerReference: string;
  orderReference: string;
  contractReference: string;
  projectReference: string;
  supplierReference: string;
  billTo: string;
  deliverTo: string;
  vatNumber: string;
  registrationNumber: string;
  electronicAddress: string;
  email: string;
  phone: string;
  website: string;
  shareCapital: string;
  description: string;
  quantity: string;
  unitPrice: string;
  discount: string;
  taxRate: string;
  amount: string;
  /** The footnote of a line whose price was keyed with its tax in it; the line is marked `*`. */
  priceIncludesTax: string;
  taxSummary: string;
  taxBase: string;
  taxCharged: string;
  totalUntaxed: string;
  totalTax: string;
  total: string;
  amountPaid: string;
  amountDue: string;
  /** The last line of the totals on a credit note, instead of {@link amountDue}. */
  amountCredited: string;
  payment: string;
  paymentTerms: string;
  paymentReference: string;
  iban: string;
  bic: string;
  note: string;
  /** `{page}` and `{pages}` are replaced. */
  page: string;
  /** UN/ECE Recommendation 20 code → what is printed after a quantity. An empty string prints nothing. */
  units: Readonly<Record<string, string>>;
}

export type PageSize = 'A4' | 'Letter';

/** A font the caller adds, for a script the embedded Noto Sans does not cover. TrueType or OpenType bytes. */
export interface ExtraFont {
  regular: Uint8Array | ArrayBuffer;
  bold?: Uint8Array | ArrayBuffer;
}

/** What {@link renderInvoicePdf} reads: the four views of one document, and the bytes of a logo. */
export interface InvoicePdfInput {
  header: DocumentHeaderRow;
  lines: readonly DocumentLineRow[];
  taxes: readonly DocumentTaxRow[];
  mentions?: readonly DocumentLegalMentionRow[];
  /** PNG or JPEG bytes. Never a URL: this package fetches nothing. */
  logo?: Uint8Array | ArrayBuffer | null;
}

export interface InvoicePdfOptions {
  /** `A4` (default) or `Letter`. */
  pageSize?: PageSize;
  /** The words of the layout, in the language of the document. What is left out is English. */
  labels?: Partial<InvoiceLabels>;
  /** BCP 47 tag for amounts, dates and country names. Defaults to the document's `language`, then `en`. */
  locale?: string;
  /** Fonts tried after the embedded ones, in order, for a character those do not have. */
  fonts?: readonly ExtraFont[];
  /** The date the PDF says it was made. Defaults to now. */
  date?: Date;
  /** Written in the PDF's metadata. Defaults to `@ekwo-ai/invoice-pdf`. */
  producer?: string;
}

/** What {@link renderInvoicePdf} returns. */
export interface RenderedInvoicePdf {
  file: Uint8Array;
  /** `invoice-<number>.pdf`, `credit-note-<number>.pdf`, or `draft-…` without a number. */
  filename: string;
  /** The title printed and written in the metadata: `Invoice INV-1`. */
  title: string;
  pageCount: number;
  /** Every string drawn, page by page, in the order drawn — what a reader of the PDF would extract. */
  text: string[][];
}
