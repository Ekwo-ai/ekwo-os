export { generateCiiXml, escapeXml, GUIDELINES, DOCUMENT_TYPE_CODES } from './cii.js';
export { computeTotals, lineNetAmount, lineVatCategory, round2 } from './totals.js';
export {
  defaultVatCategory,
  isEuCountry,
  EU_COUNTRIES,
  EXEMPT_CATEGORIES,
  EXEMPTION_REASON_CODES,
  DEFAULT_EXEMPTION_REASONS,
} from './vat.js';
export { toUnitCode, UNIT_CODES } from './units.js';
export { buildXmpMetadata, CONFORMANCE_LEVELS } from './xmp.js';
export type { XmpOptions } from './xmp.js';
export type {
  CurrencyCode,
  DocumentType,
  GenerateOptions,
  Invoice,
  InvoiceLine,
  InvoiceTotals,
  IsoDate,
  LegalIdentifier,
  Party,
  PaymentInstructions,
  PostalAddress,
  Profile,
  VatBreakdown,
  VatCategory,
} from './types.js';

// --- reading ---------------------------------------------------------------

export { profileOf, readCii, type ReceivedCiiFile } from './cii-read.js';
export { InvoiceFileError, type InvoiceFileErrorCode } from './errors.js';
export { CREDIT_NOTE_TYPE_CODES, checkReceived, isValidIban } from './received-checks.js';
export type {
  DateText,
  DecimalText,
  ReadOptions,
  ReceivedAccount,
  ReceivedAddress,
  ReceivedAllowanceCharge,
  ReceivedAttachment,
  ReceivedContact,
  ReceivedIdentifier,
  ReceivedInvoice,
  ReceivedInvoiceFile,
  ReceivedLine,
  ReceivedParty,
  ReceivedPaymentMeans,
  ReceivedTax,
  ReceivedTotals,
  ReceivedViolation,
} from './received.js';
