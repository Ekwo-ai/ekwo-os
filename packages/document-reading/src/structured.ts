/**
 * The exact path: a file that carries its invoice as data.
 *
 * Three files do — a CII D16B `CrossIndustryInvoice`, a UBL 2.1 invoice or
 * credit note, and a PDF with its Factur-X or ZUGFeRD XML attached — and the
 * e-invoicing bricks of this repository read each of them into one shape,
 * EN 16931's `ReceivedInvoice`: `readCii()` and `readFacturX()` of
 * `@ekwo-ai/factur-x`, `readUbl()` of `@ekwo-ai/peppol-ubl`. This file only
 * says which of them a file is for. No model is called: what the file says is
 * what is returned.
 *
 * The readers are imported when a file needs them, so a page that never reads
 * a PDF never downloads the PDF library.
 */

import type { ReadOptions, ReceivedInvoiceFile } from '@ekwo-ai/factur-x';

/** What a file is, as far as reading it goes: by its first bytes, never by its name. */
export type FileKind = 'pdf' | 'xml' | 'other';

/** The kind of a file, from its first kilobyte: `%PDF-` makes a PDF, a `<` after the byte-order mark and blanks makes XML. */
export function fileKind(bytes: Uint8Array): FileKind {
  const head = new TextDecoder('latin1').decode(bytes.subarray(0, 1024));
  if (head.includes('%PDF-')) return 'pdf';
  return /^(ï»¿)?\s*</.test(head) ? 'xml' : 'other';
}

/**
 * The e-invoice a file holds, read exactly; `undefined` where it holds none —
 * a photograph, a PDF with no XML inside, an XML that is not an invoice, a
 * file over the readers' limits — so that the caller reads it another way,
 * with a model (`readingSchema()`, `readingOf()`).
 *
 * CII and UBL are told apart by the root the first four kilobytes name.
 */
export async function readStructured(
  file: Uint8Array | ArrayBuffer,
  options: ReadOptions = {},
): Promise<ReceivedInvoiceFile | undefined> {
  const bytes = file instanceof Uint8Array ? file : new Uint8Array(file);
  try {
    switch (fileKind(bytes)) {
      case 'pdf':
        return await (await import('@ekwo-ai/factur-x/pdf')).readFacturX(bytes, options);
      case 'xml': {
        const head = new TextDecoder().decode(bytes.subarray(0, 4096));
        if (/CrossIndustryInvoice/.test(head)) return (await import('@ekwo-ai/factur-x')).readCii(bytes, options);
        return (await import('@ekwo-ai/peppol-ubl')).readUbl(bytes, options);
      }
      default:
        return undefined;
    }
  } catch {
    // Not an e-invoice the readers take: it is read as a picture of one.
    return undefined;
  }
}
