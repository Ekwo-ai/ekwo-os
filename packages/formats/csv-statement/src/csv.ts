/**
 * The comma-separated values a spreadsheet or a bank saves, as RFC 4180
 * describes them: fields between double quotes may hold the separator, a line
 * break and a doubled quote. The separator is the one the profile names — a
 * comma, a semicolon, a tab — and nothing else about the file is assumed.
 *
 * The tokenizer is the one of `@ekwo-ai/journal-report`, with the separator
 * given rather than read from a header: a statement export may have no header,
 * or lines of title above it.
 */

import { StatementFileError } from './errors.js';
import type { Encoding } from './types.js';

const BYTE_ORDER_MARK = 0xfeff;
const REPLACEMENT = 0xfffd;

/** Bytes to text, in the encoding the profile names, refusing what is not that. */
export function decode(input: string | Uint8Array, encoding: Encoding, maxBytes: number): string {
  let text: string;
  if (typeof input === 'string') {
    if (input.length > maxBytes) throw new StatementFileError('too_large', `the file is longer than ${maxBytes} bytes`);
    text = input;
  } else {
    if (input.byteLength > maxBytes) {
      throw new StatementFileError('too_large', `the file is ${input.byteLength} bytes, over the limit of ${maxBytes}`);
    }
    if (encoding === 'iso-8859-1') {
      const parts: string[] = [];
      for (let i = 0; i < input.length; i += 8192) parts.push(String.fromCharCode(...input.subarray(i, i + 8192)));
      text = parts.join('');
    } else {
      try {
        text = new TextDecoder(encoding, { fatal: true }).decode(input);
      } catch {
        throw new StatementFileError(
          'unsupported_encoding',
          `the bytes are not ${encoding}; name the encoding the file was saved in (utf-8, iso-8859-1, windows-1252) in the profile — it is not guessed`,
        );
      }
    }
  }
  if (text.charCodeAt(0) === BYTE_ORDER_MARK) text = text.slice(1);
  const replaced = text.indexOf(String.fromCharCode(REPLACEMENT));
  if (replaced >= 0) {
    throw new StatementFileError(
      'unsupported_encoding',
      'the text holds a replacement character (U+FFFD): it was decoded in the wrong encoding before it got here, and what was written there is lost',
    );
  }
  if (text.indexOf('\u0000') >= 0) {
    throw new StatementFileError('unsupported_encoding', 'the file holds a NUL character: it is not text — a spreadsheet saved in its own format, or UTF-16');
  }
  return text;
}

/** One row of the file: its fields, and the line of the file it starts on, from 1. */
export interface CsvRow {
  row: number;
  fields: string[];
}

/**
 * Every row of the text, each an array of fields, with the line it starts on.
 * A blank line is no row; a row of empty fields is kept.
 */
export function parseCsv(text: string, separator: string): CsvRow[] {
  const rows: CsvRow[] = [];
  let fields: string[] = [];
  let field = '';
  let quoted = false;
  let line = 1;
  let startedOn = 1;
  let fieldStarted = false;

  const endRow = (): void => {
    fields.push(field);
    if (!(fields.length === 1 && fields[0] === '')) rows.push({ row: startedOn, fields });
    fields = [];
    field = '';
    fieldStarted = false;
  };

  for (let i = 0; i < text.length; i += 1) {
    const char = text[i] as string;
    if (quoted) {
      if (char === '"') {
        if (text[i + 1] === '"') {
          field += '"';
          i += 1;
        } else quoted = false;
      } else {
        if (char === '\n') line += 1;
        field += char;
      }
      continue;
    }
    if (char === '"' && !fieldStarted) {
      quoted = true;
      fieldStarted = true;
    } else if (char === separator) {
      fields.push(field);
      field = '';
      fieldStarted = false;
    } else if (char === '\r' && text[i + 1] === '\n') {
      // The \n that follows ends the row.
    } else if (char === '\n' || char === '\r') {
      endRow();
      line += 1;
      startedOn = line;
    } else {
      field += char;
      fieldStarted = true;
    }
  }
  if (quoted) throw new StatementFileError('malformed_csv', 'a quoted field is never closed', startedOn);
  if (field !== '' || fields.length > 0) endRow();
  return rows;
}

/** A header cell as it is compared: without the blanks around it, lower case. */
export function headerKey(cell: string): string {
  return cell.trim().toLowerCase();
}
