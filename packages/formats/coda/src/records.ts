import { StatementFileError } from './errors.js';

export type Encoding = 'utf-8' | 'iso-8859-1';

const BYTE_ORDER_MARK = 0xfeff;
const END_OF_FILE_MARK = 0x1a;
const REPLACEMENT = 0xfffd;

/** A control character other than the two that end a line, or the replacement character. */
function unreadable(code: number): boolean {
  if (code === 0x0a || code === 0x0d) return false;
  return code < 0x20 || (code >= 0x7f && code <= 0x9f) || code === REPLACEMENT;
}

/**
 * Bytes to text, fatally: a byte that is not the encoding announced is an
 * error and not a replacement character in somebody's name. ISO-8859-1 maps
 * every byte, so it is never guessed — the caller says so, or the bytes are
 * UTF-8 (of which ASCII, which is what the standard writes, is a subset).
 */
export function decode(input: string | Uint8Array, encoding: Encoding, maxBytes: number): string {
  let text: string;
  if (typeof input === 'string') {
    if (input.length > maxBytes) {
      throw new StatementFileError('too_large', `the file is longer than ${maxBytes} bytes`);
    }
    text = input;
  } else {
    if (input.byteLength > maxBytes) {
      throw new StatementFileError(
        'too_large',
        `the file is ${input.byteLength} bytes, over the limit of ${maxBytes}`,
      );
    }
    if (encoding === 'iso-8859-1') {
      const parts: string[] = [];
      for (let i = 0; i < input.length; i += 8192) {
        parts.push(String.fromCharCode(...input.subarray(i, i + 8192)));
      }
      text = parts.join('');
    } else {
      try {
        text = new TextDecoder('utf-8', { fatal: true }).decode(input);
      } catch {
        throw new StatementFileError(
          'unsupported_encoding',
          "the bytes are not UTF-8; if the bank writes ISO-8859-1, say so with { encoding: 'iso-8859-1' } — it is not guessed, because every sequence of bytes is valid ISO-8859-1",
        );
      }
    }
  }
  if (text.charCodeAt(0) === BYTE_ORDER_MARK) text = text.slice(1);
  // The DOS end-of-file mark some transfers leave behind.
  let end = text.length;
  while (end > 0 && text.charCodeAt(end - 1) === END_OF_FILE_MARK) end -= 1;
  text = text.slice(0, end);
  for (let i = 0; i < text.length; i += 1) {
    const code = text.charCodeAt(i);
    if (unreadable(code)) {
      throw new StatementFileError(
        'unsupported_encoding',
        `the file holds the character U+${code.toString(16).toUpperCase().padStart(4, '0')} at offset ${i}: a control or replacement character, which is a file decoded with the wrong encoding, or not a text file`,
      );
    }
  }
  return text;
}

/**
 * The records of the file: its lines, or — when the file has no line break at
 * all, as some transfers deliver it — consecutive slices of the record length.
 * Every record is exactly `length` characters, or the file is refused: nothing
 * is padded and nothing is trimmed, because the last position of a record
 * means something.
 */
export function splitRecords(text: string, length: number): string[] {
  let records: string[];
  if (!/[\r\n]/.test(text) && text.length > length) {
    if (text.length % length !== 0) {
      throw new StatementFileError(
        'invalid_record_length',
        `the file has no line break and its ${text.length} characters are not a whole number of ${length}-character records`,
      );
    }
    records = [];
    for (let i = 0; i < text.length; i += length) records.push(text.slice(i, i + length));
  } else {
    records = text.split(/\r\n|\n|\r/);
    while (records.length > 0 && records[records.length - 1] === '') records.pop();
  }
  if (records.length === 0) throw new StatementFileError('empty_file', 'the file holds no record');
  records.forEach((record, index) => {
    if (record.length !== length) {
      throw new StatementFileError(
        'invalid_record_length',
        `${record.length} characters where the format has ${length}`,
        index + 1,
      );
    }
  });
  return records;
}
