/**
 * What makes a file unreadable, as opposed to a statement that reads and does
 * not add up. The second comes back in `violations`; the first is thrown,
 * because a format of fixed positions that is off by one character is off for
 * every field after it, and there is no statement to hang a violation on.
 */
export type StatementFileErrorCode =
  /** Larger than `maxBytes`. Refused before a single character is read. */
  | 'too_large'
  /** Bytes that are not the encoding announced — EBCDIC among them —, a replacement or a control character. */
  | 'unsupported_encoding'
  /** Nothing in the file. */
  | 'empty_file'
  /** A record that is not 120 characters long. */
  | 'invalid_record_length'
  /** A record whose code is none of 01, 04, 05, 07. */
  | 'unknown_record'
  /** A known record where the format does not allow it: a movement before an old balance, a complement without its movement. */
  | 'unexpected_record'
  /** A record that is of another bank, branch, currency, number of decimals or account than the old balance of its statement. */
  | 'inconsistent_record'
  /** The file stops before the new balance of a statement it began, or an old balance names no account. */
  | 'incomplete_statement';

export class StatementFileError extends Error {
  readonly code: StatementFileErrorCode;
  /** The record the reader stopped on, from 1, when there is one. */
  readonly record: number | null;

  constructor(code: StatementFileErrorCode, message: string, record: number | null = null) {
    super(record === null ? message : `record ${record}: ${message}`);
    this.name = 'StatementFileError';
    this.code = code;
    this.record = record;
  }
}
