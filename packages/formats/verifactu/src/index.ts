/**
 * Spain's VERI*FACTU: the invoicing record (*registro de facturación*) an
 * invoicing system keeps for every invoice it issues — *de alta* when the
 * invoice is issued, *de anulación* when its record is cancelled — with the
 * SHA-256 fingerprint that chains it to the record before, and the URL the QR
 * code of the invoice carries.
 *
 * Give it a posted document as the books hold it, the system that generates
 * the record and the record before it, and it writes the XML of the AEAT
 * schema, its fingerprint, and every rule of the AEAT the record breaks, by
 * the AEAT's own error code.
 *
 * It keeps no chain, reads no database and sends nothing: which record came
 * before is the caller's to say, and the sending — a certificate, a SOAP
 * envelope, the AEAT's flow control — is the host's. Sources are in the
 * README. It depends on nothing.
 */

import { SPECIFICATION } from './codes.js';
import { fingerprint, fingerprintInput } from './hash.js';
import { qrUrl } from './qr.js';
import { type AltaModel, buildRecord, filenameOf } from './record.js';
import type { FiscalisationFormat } from './types.js';
import { writeRecord } from './xml.js';

export { AEAT_ERRORS, ID_VERSION, NAMESPACE, SPECIFICATION, TIPO_HUELLA, type AeatErrorCode } from './codes.js';
export { VerifactuError } from './record.js';
export { VERIFICATION_SERVICES, javaUrlEncode } from './qr.js';
export type {
  AeatEnvironment,
  DocumentHeaderRow,
  DocumentLineRow,
  DocumentTaxRow,
  FiscalisationFormat,
  FiscalRecordInput,
  InvoicingSystem,
  IsoDate,
  Numeric,
  PreviousRecord,
  Row,
  SubmissionMode,
  Violation,
  WrittenRecord,
} from './types.js';

/**
 * The VERI*FACTU format.
 *
 * Each method throws a {@link VerifactuError} for what would make a record
 * absurd — no document, a document that is not a sale, that was never
 * numbered or dated, an amount that is not a number. Everything else comes
 * back from `write` as a violation, beside a record that says what it was
 * given.
 */
export const VERIFACTU: FiscalisationFormat = {
  format: 'verifactu',
  brick: '@ekwo-ai/verifactu',
  specification: SPECIFICATION,

  hashInput(input) {
    return fingerprintInput(buildRecord(input).model);
  },

  hash(input) {
    return fingerprint(fingerprintInput(buildRecord(input).model));
  },

  write(input) {
    const { model, violations } = buildRecord(input);
    const content = writeRecord(model, fingerprint(fingerprintInput(model)));
    return { content, filename: filenameOf(model), mediaType: 'application/xml', violations };
  },

  verificationUrl(input, mode, environment = 'production') {
    return qrUrl(buildRecord({ ...input, kind: 'alta' }).model as AltaModel, mode, environment);
  },
};
