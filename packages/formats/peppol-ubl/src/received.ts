/**
 * A received invoice, as the file says it.
 *
 * This is the shape both e-invoicing bricks of this repository return when
 * they read: `@ekwo-ai/peppol-ubl` from UBL 2.1, `@ekwo-ai/factur-x` from CII
 * D16B. The two syntaxes carry one semantic model, EN 16931, and each field
 * below names the business term (BT-n, BG-n) it holds, so that whoever turns
 * the result into a purchase does it once for both. Neither brick imports the
 * other: this file is copied, byte for byte, and a test compares the copies.
 *
 * What it is not: a purchase. Nothing here is matched to a supplier, an
 * account or a tax code of anybody's books, nothing is recomputed and nothing
 * is defaulted. A figure is the text the file wrote, digits and point, never a
 * `number`; an absent element is `null` or an empty list, never a guess. Where
 * the figures do not add up, the rule they break is in `violations` and the
 * figures are still the file's.
 */

/** A decimal as the file wrote it — `1450.00`, `-3.5`, `21` — checked to be one. */
export type DecimalText = string;

/** ISO-8601 calendar date, `YYYY-MM-DD`. */
export type DateText = string;

/** An identifier and the scheme it is written in, where the file names one. */
export interface ReceivedIdentifier {
  value: string;
  /** ISO 6523 ICD, EAS or another list, as written. Null where the file names none. */
  scheme: string | null;
}

export interface ReceivedAddress {
  /** BT-35, BT-36, BT-162 (and their buyer and delivery counterparts), in order, the empty ones left out. */
  lines: string[];
  city: string | null;
  postalCode: string | null;
  /** Country subdivision. */
  region: string | null;
  /** ISO 3166-1 alpha-2, as written. */
  country: string | null;
}

export interface ReceivedContact {
  name: string | null;
  phone: string | null;
  email: string | null;
}

/** BG-4 (the seller) or BG-7 (the buyer). */
export interface ReceivedParty {
  /** BT-27 / BT-44: the legal name. */
  name: string | null;
  /** BT-28 / BT-45: the name it trades under, where the file gives one beside the legal one. */
  tradeName: string | null;
  /** BT-29 / BT-46: other identifiers of the party. */
  identifiers: ReceivedIdentifier[];
  /** BT-30 / BT-47: the legal registration identifier. */
  legalId: ReceivedIdentifier | null;
  /** BT-31 / BT-48: the VAT identifier, with its country prefix as written. */
  vatId: string | null;
  /** BT-32: the seller's tax registration identifier other than VAT. Always null for a buyer. */
  taxRegistrationId: string | null;
  /** BT-33: additional legal information. */
  legalForm: string | null;
  /** BT-34 / BT-49: where the network delivers to this party. */
  electronicAddress: ReceivedIdentifier | null;
  /** BG-5 / BG-8. */
  address: ReceivedAddress | null;
  /** BG-6 / BG-9. */
  contact: ReceivedContact | null;
}

/** BG-20 and BG-21 on the document, BG-27 and BG-28 on a line. */
export interface ReceivedAllowanceCharge {
  /** True for a charge, false for an allowance. */
  charge: boolean;
  /** BT-92 / BT-99 / BT-136 / BT-141. */
  amount: DecimalText;
  /** BT-93 / BT-100 / BT-137 / BT-142. */
  baseAmount: DecimalText | null;
  /** BT-94 / BT-101 / BT-138 / BT-143. */
  percent: DecimalText | null;
  /** BT-97 / BT-104 / BT-139 / BT-144. */
  reason: string | null;
  /** BT-98 / BT-105 / BT-140 / BT-145. */
  reasonCode: string | null;
  /** BT-95 / BT-102. Null on a line, whose allowances take the line's category. */
  vatCategory: string | null;
  /** BT-96 / BT-103. */
  vatRate: DecimalText | null;
}

/** BG-25: one line of the invoice. */
export interface ReceivedLine {
  /** BT-126. */
  id: string;
  /** BT-127. */
  note: string | null;
  /** BT-129. Null only where the profile carries no quantity. */
  quantity: DecimalText | null;
  /** BT-130, UN/ECE Recommendation 20. */
  unitCode: string | null;
  /** BT-131: net of the line's own allowances and charges, as the file says. */
  netAmount: DecimalText;
  /** BT-132. */
  orderLineReference: string | null;
  /** BG-26: BT-134 and BT-135. */
  period: { start: DateText | null; end: DateText | null } | null;
  /** BG-27 and BG-28. */
  allowances: ReceivedAllowanceCharge[];
  /** BT-146. */
  netPrice: DecimalText | null;
  /** BT-147. */
  priceDiscount: DecimalText | null;
  /** BT-148. */
  grossPrice: DecimalText | null;
  /** BT-149. */
  priceBaseQuantity: DecimalText | null;
  /** BT-150. */
  priceBaseUnitCode: string | null;
  /** BT-151. */
  vatCategory: string | null;
  /** BT-152. */
  vatRate: DecimalText | null;
  /** BT-153. */
  name: string | null;
  /** BT-154. */
  description: string | null;
  /** BT-155. */
  sellerItemId: string | null;
  /** BT-156. */
  buyerItemId: string | null;
  /** BT-157, with its scheme (BT-157-1). */
  standardItemId: ReceivedIdentifier | null;
}

/** BG-23: one group of the VAT breakdown. */
export interface ReceivedTax {
  /** BT-118. */
  category: string | null;
  /** BT-119. */
  rate: DecimalText | null;
  /** BT-116. */
  base: DecimalText;
  /** BT-117. */
  tax: DecimalText;
  /** BT-121. */
  exemptionReasonCode: string | null;
  /** BT-120. */
  exemptionReason: string | null;
}

/** BG-22. */
export interface ReceivedTotals {
  /** BT-106. Null only where the profile carries none. */
  lineTotal: DecimalText | null;
  /** BT-107. */
  allowanceTotal: DecimalText | null;
  /** BT-108. */
  chargeTotal: DecimalText | null;
  /** BT-109. */
  taxExclusive: DecimalText;
  /** BT-110, in the currency of the invoice. */
  taxTotal: DecimalText | null;
  /** BT-111, in the tax currency (BT-6) where the file has one. */
  taxTotalInTaxCurrency: DecimalText | null;
  /** BT-112. */
  taxInclusive: DecimalText;
  /** BT-113. */
  prepaid: DecimalText | null;
  /** BT-114. */
  rounding: DecimalText | null;
  /** BT-115. */
  payable: DecimalText;
}

/**
 * BT-84 and BT-91. An account is not an IBAN: where the syntax says which it
 * is (CII has an element for each), that is what is returned; where it does
 * not (UBL has one element for both), it is an IBAN only if its check digits
 * pass.
 */
export type ReceivedAccount = { kind: 'iban'; value: string } | { kind: 'other'; value: string };

/** BG-16: one way of paying. */
export interface ReceivedPaymentMeans {
  /** BT-81, UNTDID 4461. */
  code: string | null;
  /** BT-82. */
  text: string | null;
  /** BT-83: what the payer must quote. */
  reference: string | null;
  /** BT-84: the account the seller is paid to. */
  account: ReceivedAccount | null;
  /** BT-85. */
  accountName: string | null;
  /** BT-86. */
  bic: string | null;
  /** BT-87: the last digits of a card, as the file gives them. */
  cardNumber: string | null;
  /** BT-89: the mandate of a direct debit. */
  mandateReference: string | null;
  /** BT-91: the account that is debited. */
  debitedAccount: ReceivedAccount | null;
}

/** BG-24: a document that travels with the invoice. */
export interface ReceivedAttachment {
  /** BT-122. */
  id: string | null;
  /** BT-123. */
  description: string | null;
  /** BT-125-2. */
  filename: string | null;
  /** BT-125-1, as written. */
  mimeType: string | null;
  /** BT-125, decoded from base64. Null where nothing is embedded, or where what is embedded is not base64 (a violation says so). */
  content: Uint8Array | null;
  /** BT-124: where the document is, rather than the document. */
  uri: string | null;
}

export interface ReceivedInvoice {
  /** Which syntax the file was written in. */
  syntax: 'ubl' | 'cii';
  /** BT-24: what the file claims to conform to. */
  customizationId: string | null;
  /** BT-23: the business process. */
  profileId: string | null;
  /**
   * Whether the document asks to be paid or gives money back. UBL says it by
   * its root element; CII by the type code (BT-3) alone. The figures of a
   * credit note are positive, as the file writes them: the sign is this field.
   */
  kind: 'invoice' | 'credit_note';
  /** BT-3, UNTDID 1001. */
  typeCode: string | null;
  /** BT-1. */
  number: string;
  /** BT-2. */
  issueDate: DateText;
  /** BT-9. */
  dueDate: DateText | null;
  /** BT-7. */
  taxPointDate: DateText | null;
  /** BT-5. */
  currency: string;
  /** BT-6. */
  taxCurrency: string | null;
  /** BT-10. */
  buyerReference: string | null;
  /** BT-13. */
  orderReference: string | null;
  /** BT-14. */
  salesOrderReference: string | null;
  /** BT-12. */
  contractReference: string | null;
  /** BT-11. */
  projectReference: string | null;
  /** BT-19. */
  accountingCost: string | null;
  /** BG-3: the invoices this one corrects or credits. */
  precedingInvoices: { number: string; issueDate: DateText | null }[];
  /** BT-22, every note, in order. */
  notes: string[];
  seller: ReceivedParty;
  buyer: ReceivedParty;
  /** BT-72. */
  deliveryDate: DateText | null;
  /** BG-15. */
  deliveryAddress: ReceivedAddress | null;
  /** BG-14: BT-73 and BT-74. */
  invoicingPeriod: { start: DateText | null; end: DateText | null } | null;
  /** BT-20. */
  paymentTerms: string | null;
  /** BG-16. */
  paymentMeans: ReceivedPaymentMeans[];
  /** BG-20 and BG-21. */
  allowances: ReceivedAllowanceCharge[];
  /** BG-23. */
  taxes: ReceivedTax[];
  /** BG-22. */
  totals: ReceivedTotals;
  /** BG-25. Empty only where the profile carries no line. */
  lines: ReceivedLine[];
  /** BG-24. */
  attachments: ReceivedAttachment[];
}

/** A rule of EN 16931 the received file breaks, or something the reader could not take as written. */
export interface ReceivedViolation {
  /**
   * The identifier the rule is published under — `BR-CO-15` — where there is
   * one; otherwise one of this reader's own: `invalid_iban`,
   * `invalid_attachment`, `unknown_type_code`.
   */
  code: string;
  /** What is wrong, in a sentence. */
  message: string;
  /** The line the trouble is on, by its identifier (BT-126), where there is one. */
  line?: string;
}

/** What a reader returns. */
export interface ReceivedInvoiceFile {
  invoice: ReceivedInvoice;
  /** Empty when everything that is checked adds up. Never a reason the invoice was not returned. */
  violations: ReceivedViolation[];
}

/** Bounds on what a reader takes, because a received file is hostile until read. */
export interface ReadOptions {
  /** Defaults to 64 MiB: an invoice is small, the documents it carries are not always. */
  maxBytes?: number;
  /** Defaults to 64. */
  maxDepth?: number;
  /** Defaults to 500 000. */
  maxElements?: number;
}
