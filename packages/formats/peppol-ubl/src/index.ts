/**
 * A sales invoice or credit note as Peppol carries it: UBL 2.1, in the profile
 * Peppol BIS Billing 3.0 of the European standard EN 16931.
 *
 * Give it a posted document as the books hold it — the header, the lines and
 * the VAT breakdown — and it writes the file, a name for it, and every
 * published rule the file breaks.
 *
 * The figures are the books' figures. Nothing is recomputed: a total, a base
 * and a tax are written as they were posted, and where they do not add up the
 * rule they break is named rather than the figure corrected. An invoice is an
 * accounting document before it is an XML one, and a file that disagrees with
 * the ledger it came from by a cent is worse than a file that is refused.
 *
 * Sending the file is another matter: that takes a certified access point, and
 * this package has none. Sources are in the README. It depends on nothing,
 * reads no database and knows no accounting.
 */

import { PeppolUblError, buildModel } from './model.js';
import { check } from './rules.js';
import type { PeppolUbl, PeppolUblInput, PeppolUblOptions } from './types.js';
import { writeUbl } from './ubl.js';

export { PeppolUblError } from './model.js';
export { CUSTOMIZATION_ID, PROFILE_ID } from './ubl.js';
export { SCHEMES_NOT_ON_PEPPOL } from './rules.js';
export {
  COUNTRY_CODES,
  CURRENCY_CODES,
  ELECTRONIC_ADDRESS_SCHEMES,
  EXEMPTION_REASON_CODES,
  IDENTIFIER_SCHEMES,
  PAYMENT_MEANS_CODES,
  UNIT_CODES,
  VAT_CATEGORY_CODES,
  VAT_IDENTIFIER_PREFIXES,
} from './codelists.js';
export type {
  DocumentHeaderRow,
  DocumentLineRow,
  DocumentTaxRow,
  ElectronicAddress,
  IsoDate,
  Numeric,
  PeppolUbl,
  PeppolUblInput,
  PeppolUblOptions,
  Violation,
} from './types.js';

/**
 * A name for the file. The network imposes none — a document travels inside an
 * envelope that names it — so this is the document's own number, with whatever
 * a file system would object to replaced.
 */
function filenameOf(number: string, kind: 'Invoice' | 'CreditNote'): string {
  const safe = number.replace(/[^A-Za-z0-9._-]+/g, '-').replace(/^-+|-+$/g, '');
  return `${kind === 'Invoice' ? 'invoice' : 'credit-note'}-${safe === '' ? 'document' : safe}.xml`;
}

/**
 * Writes the document.
 *
 * Throws a {@link PeppolUblError} for what would make the file absurd: a
 * document that is not a sale, that was never numbered, that has no currency
 * or no line, an amount or a date that is not one. Everything else comes back
 * as a violation, beside a file that says what it was given.
 */
export function generatePeppolUbl(input: PeppolUblInput, options: PeppolUblOptions = {}): PeppolUbl {
  if (!input || !input.header) throw new PeppolUblError('no document was given');
  const model = buildModel(input, options);
  return {
    file: writeUbl(model),
    filename: filenameOf(model.number, model.kind),
    violations: check(model),
  };
}
