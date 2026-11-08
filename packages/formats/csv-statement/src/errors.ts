/**
 * What makes a file unreadable, as opposed to a statement that reads and does
 * not add up. The second comes back in `violations`; the first is thrown,
 * because a file whose columns are not the ones the profile describes has no
 * line to hang a violation on — and neither has a profile that describes
 * nothing a reader could follow.
 */
export type StatementFileErrorCode =
  /** Larger than `maxBytes`. Refused before a single character is read. */
  | 'too_large'
  /** Bytes that are not the encoding the profile names, a replacement or a control character. */
  | 'unsupported_encoding'
  /** Nothing in the file, or a header and no row under it. */
  | 'empty_file'
  /** A quote that is never closed. */
  | 'malformed_csv'
  /** The profile itself: no date column, no amount and no debit or credit, a date format without a day, a separator used twice… */
  | 'invalid_profile'
  /** The header lacks a column the profile names, or holds it twice. */
  | 'missing_column';

export class StatementFileError extends Error {
  readonly code: StatementFileErrorCode;
  /** The row of the file the reader stopped on, from 1, when there is one. */
  readonly row: number | null;

  constructor(code: StatementFileErrorCode, message: string, row: number | null = null) {
    super(row === null ? message : `row ${row}: ${message}`);
    this.name = 'StatementFileError';
    this.code = code;
    this.row = row;
  }
}
