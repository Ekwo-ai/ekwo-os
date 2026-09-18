/**
 * What makes a file unreadable, as opposed to a statement that reads and does
 * not add up. The second comes back in `violations`; the first is thrown,
 * because there is no statement to hang a violation on.
 */
export type StatementFileErrorCode =
  /** Larger than `maxBytes`. Refused before a single character is read. */
  | 'too_large'
  /** Bytes that are not UTF-8, or a declaration that names another encoding. */
  | 'unsupported_encoding'
  /** A `<!DOCTYPE`. No statement needs one, and every entity attack does. */
  | 'doctype_forbidden'
  /** An entity other than the five XML predefines and character references. */
  | 'undefined_entity'
  /** Elements nested deeper than `maxDepth`. */
  | 'too_deep'
  /** More elements than `maxElements`. */
  | 'too_many_elements'
  /** Not well-formed XML, in the subset this reader takes. */
  | 'malformed_xml'
  /** Well-formed, and not a camt.053: another root, another namespace. */
  | 'not_a_statement'
  /** camt.053.001.01, the 2007 message: same name, another shape. */
  | 'unsupported_version'
  /** A camt.053 without the parts that make it one: no statement, no account. */
  | 'incomplete_statement';

export class StatementFileError extends Error {
  readonly code: StatementFileErrorCode;

  constructor(code: StatementFileErrorCode, message: string) {
    super(message);
    this.name = 'StatementFileError';
    this.code = code;
  }
}
