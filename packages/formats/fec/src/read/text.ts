/**
 * The bytes of a file as text, in the encoding the caller said. A FEC may be
 * written in UTF-8 or in ISO 8859-15, and nothing in the file says which:
 * the caller does, and bytes that are not UTF-8 are refused rather than read
 * as Latin, where every sequence of bytes would pass.
 */

import { BooksFileError } from './errors.js';
import type { Encoding } from './types.js';

const BYTE_ORDER_MARK = 0xfeff;

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
    if (encoding === 'iso-8859-15') {
      text = new TextDecoder('iso-8859-15').decode(input);
    } else {
      try {
        text = new TextDecoder('utf-8', { fatal: true }).decode(input);
      } catch {
        throw new BooksFileError(
          'unsupported_encoding',
          "the bytes are not UTF-8; if the file is written in ISO 8859-15, say so with { encoding: 'iso-8859-15' } — it is not guessed, because every sequence of bytes is valid ISO 8859-15",
        );
      }
    }
  }
  if (text.charCodeAt(0) === BYTE_ORDER_MARK) text = text.slice(1);
  return text;
}
