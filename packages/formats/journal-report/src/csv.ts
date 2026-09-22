/**
 * The comma-separated values a spreadsheet saves, as RFC 4180 describes them:
 * fields between double quotes may hold the separator, a line break and a
 * doubled quote. Nothing else about the file is assumed.
 *
 * The separator is **read from the header**, which this format requires: the
 * first of `,`, `;` and a tab that the header row contains outside quotes. A
 * spreadsheet saves with a comma or a semicolon depending on the language of
 * the machine, and the header is the one row whose content is known, so this
 * is reading the file rather than guessing at it.
 */

import { BooksFileError } from './errors.js';
import type { Encoding } from './types.js';

const BYTE_ORDER_MARK = 0xfeff;

export type Separator = ',' | ';' | '\t';

/** Bytes to text, in the encoding the caller said, refusing what is not that. */
export function decode(input: string | Uint8Array, encoding: Encoding, maxBytes: number): string {
  let text: string;
  if (typeof input === 'string') {
    if (input.length > maxBytes) throw new BooksFileError('too_large', `the file is longer than ${maxBytes} bytes`);
    text = input;
  } else {
    if (input.byteLength > maxBytes) {
      throw new BooksFileError('too_large', `the file is ${input.byteLength} bytes, over the limit of ${maxBytes}`);
    }
    if (encoding === 'iso-8859-1') {
      const parts: string[] = [];
      for (let i = 0; i < input.length; i += 8192) parts.push(String.fromCharCode(...input.subarray(i, i + 8192)));
      text = parts.join('');
    } else {
      try {
        text = new TextDecoder('utf-8', { fatal: true }).decode(input);
      } catch {
        throw new BooksFileError(
          'unsupported_encoding',
          "the bytes are not UTF-8; if the file was saved in Latin-1, say so with { encoding: 'iso-8859-1' } — it is not guessed, because every sequence of bytes is valid Latin-1",
        );
      }
    }
  }
  if (text.charCodeAt(0) === BYTE_ORDER_MARK) text = text.slice(1);
  return text;
}

/** The separator of a header line: the first of the three found outside quotes. */
export function separatorOf(headerLine: string): Separator {
  let quoted = false;
  for (const char of headerLine) {
    if (char === '"') quoted = !quoted;
    else if (!quoted && (char === ',' || char === ';' || char === '\t')) return char;
  }
  // A header of one column has no separator; any will do, and a comma is it.
  return ',';
}

/** Every row of the file, each an array of fields, with the row number it starts on. */
export function parseCsv(text: string, separator: Separator): { row: number; fields: string[] }[] {
  const rows: { row: number; fields: string[] }[] = [];
  let fields: string[] = [];
  let field = '';
  let quoted = false;
  let line = 1;
  let startedOn = 1;
  let fieldStarted = false;

  const endRow = (): void => {
    fields.push(field);
    // A blank line is no row; a row of empty fields is kept and read.
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
  if (quoted) throw new BooksFileError('malformed_csv', 'a quoted field is never closed', startedOn);
  if (field !== '' || fields.length > 0) endRow();
  return rows;
}

/** A header cell as it is compared: trimmed, lower case, without the `*` some exports put on a required column. */
export function headerKey(cell: string): string {
  return cell.trim().replace(/^\*/, '').trim().toLowerCase();
}
