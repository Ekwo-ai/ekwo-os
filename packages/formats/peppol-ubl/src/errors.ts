/**
 * What makes a received file unreadable, as opposed to an invoice that reads
 * and does not add up. The second comes back in `violations`; the first is
 * thrown, because a file that is not an invoice has nothing to hang a
 * violation on.
 */
export type InvoiceFileErrorCode =
  /** Larger than `maxBytes`. Refused before a single character is read. */
  | 'too_large'
  /** Bytes that are not UTF-8, or a declaration that names another encoding. */
  | 'unsupported_encoding'
  /** A `<!DOCTYPE`. No invoice needs one, and every entity attack does. */
  | 'doctype_forbidden'
  /** An entity other than the five XML predefines and character references. */
  | 'undefined_entity'
  /** Elements nested deeper than `maxDepth`. */
  | 'too_deep'
  /** More elements than `maxElements`. */
  | 'too_many_elements'
  /** Not well-formed XML, in the subset this reader takes. */
  | 'malformed_xml'
  /** Well-formed, and not a UBL 2.1 `Invoice` or `CreditNote`: another root, another namespace. */
  | 'not_an_invoice'
  /** An element without which there is no invoice to book: its number, its date, its currency, its totals, a line. */
  | 'missing_element'
  /** A value that is not what its element holds: a date that is not a date, an amount that is not a number. */
  | 'invalid_value';

export class InvoiceFileError extends Error {
  readonly code: InvoiceFileErrorCode;

  constructor(code: InvoiceFileErrorCode, message: string) {
    super(message);
    this.name = 'InvoiceFileError';
    this.code = code;
  }
}
