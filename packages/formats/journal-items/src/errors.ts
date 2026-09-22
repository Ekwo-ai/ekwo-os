/**
 * What makes a file unreadable, as opposed to books that read and do not add
 * up. The second comes back in `violations`; the first is thrown, because a
 * file with no header the reader recognises has no row to hang a violation on.
 */
export type BooksFileErrorCode =
  /** Larger than `maxBytes`. Refused before a single character is read. */
  | 'too_large'
  /** Bytes that are not the encoding announced. */
  | 'unsupported_encoding'
  /** Nothing in the file, or a header and nothing under it. */
  | 'empty_file'
  /** A header that lacks a column the format needs, or names one twice. */
  | 'missing_column'
  /** A quote that is never closed. */
  | 'malformed_csv'
  /** A value the format does not allow where it is: a date, an amount. */
  | 'invalid_value';

export class BooksFileError extends Error {
  readonly code: BooksFileErrorCode;
  /** The row the reader stopped on, from 1, when there is one. */
  readonly row: number | null;

  constructor(code: BooksFileErrorCode, message: string, row: number | null = null) {
    super(row === null ? message : `row ${row}: ${message}`);
    this.name = 'BooksFileError';
    this.code = code;
    this.row = row;
  }
}
