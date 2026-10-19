import { inflateSync } from 'node:zlib';
import jsQRModule from 'jsqr';
import { PDFDocument, PDFName, PDFRawStream } from 'pdf-lib';
import { describe, expect, it } from 'vitest';
import { ENGLISH_LABELS, InvoicePdfError, renderInvoicePdf, type InvoiceVerification } from '../src/index.js';
import { englishInvoice } from './fixtures.js';

type Decoder = (data: Uint8ClampedArray, width: number, height: number) => { data: string } | null;
const jsQR: Decoder = ((jsQRModule as unknown as { default?: Decoder }).default ?? jsQRModule) as unknown as Decoder;

const DATE = new Date('2026-04-01T00:00:00Z');
const all = (text: string[][]): string => text.flat().join('\n');

/** The content streams of a page, as text. */
async function contentOf(file: Uint8Array, index: number): Promise<string> {
  const doc = await PDFDocument.load(file);
  const page = doc.getPage(index);
  const contents = page.node.get(PDFName.of('Contents'));
  const refs = 'asArray' in (contents as object) ? (contents as unknown as { asArray(): unknown[] }).asArray() : [contents];
  let out = '';
  for (const ref of refs) {
    const stream = doc.context.lookup(ref as never) as PDFRawStream;
    const filter = stream.dict.get(PDFName.of('Filter'));
    const bytes = filter === PDFName.of('FlateDecode') ? inflateSync(stream.contents) : stream.contents;
    out += Buffer.from(bytes).toString('latin1');
  }
  return out;
}

/** The QR code drawn on the PDF, read back by a decoder, page by page. */
async function qrOf(file: Uint8Array): Promise<string | null> {
  const pages = (await PDFDocument.load(file)).getPageCount();
  for (let index = 0; index < pages; index++) {
    const found = qrOfPage(await contentOf(file, index));
    if (found !== null) return found;
  }
  return null;
}

/** Every filled rectangle the size of the smallest one, painted on a bitmap eight pixels a module. */
function qrOfPage(content: string): string | null {
  const rects: { x: number; y: number; w: number; h: number }[] = [];
  const shape = /1 0 0 1 ([\d.-]+) ([\d.-]+) cm\s+(?:[^\n]*\n)*?0 0 m\s+0 ([\d.-]+) l\s+([\d.-]+) [\d.-]+ l/g;
  for (const match of content.matchAll(shape)) {
    rects.push({ x: Number(match[1]), y: Number(match[2]), h: Number(match[3]), w: Number(match[4]) });
  }
  const module = Math.min(...rects.map((r) => r.h));
  const modules = rects.filter((r) => Math.abs(r.h - module) < 1e-6);
  const minX = Math.min(...modules.map((r) => r.x));
  const maxY = Math.max(...modules.map((r) => r.y + r.h));
  const scale = 8 / module;
  const margin = 32;
  const side = Math.ceil((Math.max(...modules.map((r) => r.x + r.w)) - minX) * scale) + 2 * margin;
  const pixels = new Uint8ClampedArray(side * side * 4).fill(255);
  for (const r of modules) {
    const x0 = Math.round((r.x - minX) * scale) + margin;
    const y0 = Math.round((maxY - r.y - r.h) * scale) + margin;
    for (let y = y0; y < y0 + Math.round(r.h * scale); y++) {
      for (let x = x0; x < x0 + Math.round(r.w * scale); x++) {
        const at = (y * side + x) * 4;
        pixels[at] = pixels[at + 1] = pixels[at + 2] = 0;
      }
    }
  }
  return jsQR(pixels, side, side)?.data ?? null;
}

const LINK = 'https://verify.invalid/ABCDEFGHIJKLMNOPQRSTUVWXYZ/share/0123456789abcdefghijklmnopqrstuvwxyz';

const cleared = (overrides: Partial<InvoiceVerification> = {}): InvoiceVerification => ({
  url: LINK,
  heading: 'clearanceVerification',
  fields: [
    { label: 'clearanceIdentifier', value: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' },
    { label: 'clearanceValidatedAt', value: '2026-03-31 02:31:00+00', kind: 'datetime' },
  ],
  ...overrides,
});

describe('the verification of an invoice by a tax authority', () => {
  it('draws the QR code of the link, which a decoder reads back, and prints the identifier and the moment beside it', async () => {
    const rendered = await renderInvoicePdf(englishInvoice({ verification: cleared() }), { date: DATE });
    expect(await qrOf(rendered.file)).toBe(LINK);
    const text = all(rendered.text);
    expect(text).toContain(ENGLISH_LABELS.clearanceVerification);
    expect(text).toContain(`${ENGLISH_LABELS.clearanceIdentifier}: ABCDEFGHIJKLMNOPQRSTUVWXYZ`);
    const moment = new Intl.DateTimeFormat('en', {
      year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit',
      timeZone: 'UTC', timeZoneName: 'short',
    }).format(new Date('2026-03-31T02:31:00Z'));
    expect(text).toContain(`${ENGLISH_LABELS.clearanceValidatedAt}: ${moment}`);
  });

  it('prints the words of the caller for a label key, and a heading the country prescribes as it is', async () => {
    const rendered = await renderInvoicePdf(
      englishInvoice({ verification: cleared({ heading: 'Words a country prescribes:', notes: ['A sentence beside the code.'] }) }),
      { date: DATE, labels: { clearanceIdentifier: 'Caller words' } },
    );
    const text = all(rendered.text);
    expect(text).toContain('Words a country prescribes:');
    expect(text).toContain('Caller words: ABCDEFGHIJKLMNOPQRSTUVWXYZ');
    expect(text).toContain('A sentence beside the code.');
  });

  it('draws the code at the size asked, and changes nothing when there is no verification', async () => {
    const plain = await renderInvoicePdf(englishInvoice(), { date: DATE });
    const none = await renderInvoicePdf(englishInvoice({ verification: null }), { date: DATE });
    expect(Buffer.from(none.file).equals(Buffer.from(plain.file))).toBe(true);
    expect(await qrOf(plain.file)).toBeNull();

    const big = await renderInvoicePdf(englishInvoice({ verification: cleared({ sizeMm: 40, errorCorrection: 'H' }) }), { date: DATE });
    expect(await qrOf(big.file)).toBe(LINK);
  });

  it('refuses a verification without a link, and a moment that is not one', async () => {
    await expect(renderInvoicePdf(englishInvoice({ verification: cleared({ url: ' ' }) }))).rejects.toBeInstanceOf(InvoicePdfError);
    await expect(
      renderInvoicePdf(englishInvoice({ verification: cleared({ fields: [{ label: 'clearanceValidatedAt', value: 'yesterday', kind: 'datetime' }] }) })),
    ).rejects.toThrow(/not an ISO 8601/);
  });
});
