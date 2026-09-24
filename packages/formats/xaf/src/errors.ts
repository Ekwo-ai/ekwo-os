/**
 * What makes a file unreadable, as opposed to books that read and do not add
 * up. The second comes back in `violations`; the first is thrown, because a
 * file that is not an audit file has no line to hang a violation on.
 */
export type BooksFileErrorCode =
  /** Larger than `maxBytes`. Refused before a single character is read. */
  | 'too_large'
  /** Bytes that are not the encoding the declaration names, or a caller who names another one. */
  | 'unsupported_encoding'
  /** A `<!DOCTYPE`. No audit file needs one, and every entity attack does. */
  | 'doctype_forbidden'
  /** An entity other than the five XML predefines and character references. */
  | 'undefined_entity'
  /** Elements nested deeper than an audit file ever nests them. */
  | 'too_deep'
  /** More elements than `maxElements`. */
  | 'too_many_elements'
  /** Not well-formed XML, in the subset this reader takes. */
  | 'malformed_xml'
  /** Well-formed, and not an audit file: another root, another namespace. */
  | 'not_an_auditfile'
  /** An audit file of a version this reader was not written against. */
  | 'unsupported_version'
  /** An element the schema requires, missing. */
  | 'missing_element'
  /** A value the schema does not allow where it is: a date, an amount, a side. */
  | 'invalid_value';

export class BooksFileError extends Error {
  readonly code: BooksFileErrorCode;
  /** Kept for the shape the other readers share; an XML file has no rows. */
  readonly row: number | null;

  constructor(code: BooksFileErrorCode, message: string) {
    super(message);
    this.name = 'BooksFileError';
    this.code = code;
    this.row = null;
  }
}
