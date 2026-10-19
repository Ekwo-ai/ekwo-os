/**
 * Malaysia's MyInvois e-Invoice: the UBL 2.1 document LHDNM validates before
 * an invoice, a credit note, a debit note or a refund note — the supplier's
 * or self-billed — is the taxpayer's, in its JSON or its XML syntax.
 *
 * Give it a posted document as the books hold it — the header, the lines and
 * the taxes — with what MyInvois asks and the books do not hold: the LHDNM
 * identifiers of both parties, the supplier's MSIC code, the moment of
 * issuance. It writes the document, a name for it, and every rule of the SDK
 * the document breaks, by LHDNM's own error code where it publishes one.
 *
 * The figures are the books' figures. Nothing is recomputed: a total, a base
 * and a tax are written as they were posted, and where they do not add up the
 * mapping they break is named rather than the figure corrected.
 *
 * It signs nothing, submits nothing and reads no clock: the signature of
 * version 1.1, the login, the submission and LHDNM's answer belong to the
 * host. Sources are in the README. It depends on nothing.
 */

import { documentOf } from './document.js';
import { type DocumentModel, MyInvoisError, buildModel } from './model.js';
import { check } from './rules.js';
import { toJson, toXml } from './tree.js';
import type { MyInvoisFormat, MyInvoisInput, Syntax, WrittenDocument } from './types.js';

export { MyInvoisError, RINGGIT } from './model.js';
export { NAMESPACES } from './tree.js';
export {
  ALPHA3,
  CLASSIFICATION_CODES,
  COUNTRY_CODES,
  CURRENCY_CODES,
  EINVOICE_TYPES,
  MSIC_CODES,
  PAYMENT_MODES,
  STATE_CODES,
  TAX_TYPES,
  UNIT_CODES,
} from './codelists.js';
export type {
  AdjustedDocument,
  DocumentHeaderRow,
  DocumentKind,
  DocumentLineRow,
  DocumentTaxRow,
  IsoDate,
  MyInvoisFormat,
  MyInvoisInput,
  Numeric,
  PartyIdentifiers,
  RegistrationScheme,
  Row,
  SupplierActivity,
  Syntax,
  Violation,
  WrittenDocument,
} from './types.js';

/** What the document declares it follows. */
export const SPECIFICATION = 'MyInvois SDK, e-Invoice document types v1.0 and v1.1 (UBL 2.1)';

/**
 * A name for the file. MyInvois imposes none — a document is submitted inside
 * a request that carries its code number — so this is the type and the number,
 * with whatever a file system would object to replaced.
 */
function filenameOf(model: DocumentModel, syntax: Syntax): string {
  const safe = model.number.replace(/[^A-Za-z0-9._-]+/g, '-').replace(/^-+|-+$/g, '');
  return `myinvois-${model.typeCode}-${safe === '' ? 'document' : safe}.${syntax}`;
}

/**
 * The MyInvois format.
 *
 * `write` throws a {@link MyInvoisError} for what would make the document
 * absurd — no document, a quote, a document never numbered, an amount or a
 * moment of issuance that is not one. Everything else comes back as a
 * violation, beside a document that says what it was given.
 */
export const MYINVOIS: MyInvoisFormat = {
  format: 'myinvois',
  brick: '@ekwo-ai/myinvois',
  syntax: 'UBL 2.1',
  specification: SPECIFICATION,

  write(input: MyInvoisInput, syntax: Syntax = 'json'): WrittenDocument {
    if (syntax !== 'json' && syntax !== 'xml') throw new MyInvoisError(`MyInvois accepts JSON and XML, not ${String(syntax)}`);
    const { model, violations } = buildModel(input);
    const tree = documentOf(model);
    return {
      content: syntax === 'json' ? toJson(tree) : toXml(tree),
      filename: filenameOf(model, syntax),
      mediaType: syntax === 'json' ? 'application/json' : 'application/xml',
      syntax,
      typeCode: model.typeCode,
      version: model.version,
      requiresSignature: model.version === '1.1',
      violations: [...violations, ...check(model)],
    };
  },
};
