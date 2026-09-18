/**
 * What makes a file unreadable, as opposed to a statement that reads and does
 * not add up. The second comes back in `violations`; the first is thrown,
 * because a format of fixed positions that is off by one character is off for
 * every field after it, and there is no statement to hang a violation on.
 */
export type StatementFileErrorCode =
  /** Larger than `maxBytes`. Refused before a single character is read. */
  | 'too_large'
  /** Bytes that are not the encoding announced, a replacement or a control character. */
  | 'unsupported_encoding'
  /** Nothing in the file. */
  | 'empty_file'
  /** A record that is not 128 characters long. */
  | 'invalid_record_length'
  /** A record whose identification is none of 0, 1, 2, 3, 4, 8, 9 — or an article that is none of 1, 2, 3. */
  | 'unknown_record'
  /** A known record where the format does not allow it: a 2.2 without its 2.1, a line before the old balance. */
  | 'unexpected_record'
  /** A header whose version code is not 2: version 1 is another lay-out under the same name. */
  | 'unsupported_version'
  /** Two records of one statement that disagree on the account it is the statement of. */
  | 'inconsistent_record'
  /** The file stops before the trailer record of a statement it began. */
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
