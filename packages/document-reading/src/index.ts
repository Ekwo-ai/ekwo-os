/**
 * `@ekwo-ai/document-reading` — one reader for received invoices.
 *
 * - `readStructured()`: a CII, UBL or Factur-X file, read exactly.
 * - `readingSchema()`, `readingPrompt()`, `readingOf()`: a photograph or a
 *   plain PDF, read by a vision model the caller calls, into the same shape.
 * - `purchaseDraftOf()`: either, as the draft of a purchase document.
 *
 * The shape is `ReceivedInvoice` of `@ekwo-ai/factur-x` (EN 16931), re-exported
 * here so a caller needs this package alone.
 */

export { fileKind, readStructured, type FileKind } from './structured.js';
export {
  CONFIDENCE_FIELDS,
  CONFIDENCES,
  READING_PROMPT,
  READING_VERSION,
  VAT_CATEGORIES,
  readingOf,
  readingPrompt,
  readingSchema,
  type Confidence,
  type ConfidenceField,
  type DocumentKind,
  type ModelReading,
  type ReadingExtension,
} from './model.js';
export {
  LINE_ATTRIBUTES,
  currencyDigits,
  makesAmount,
  purchaseDraftOf,
  type Period,
  type PurchaseDraft,
  type PurchaseDraftLine,
} from './purchase.js';
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
} from '@ekwo-ai/factur-x';
