/**
 * What PDF/A-3b asks of the file, as far as a test can see it without a
 * validator: the XMP packet and the information dictionary saying the same
 * things, a logo drawn without transparency, no CMYK under the sRGB intent.
 * The validator itself, veraPDF, is run by `npm run verapdf` (see the README).
 */

import { PDFArray, PDFDict, PDFDocument, PDFName, PDFRawStream, decodePDFRawStream, type PDFStream } from 'pdf-lib';
import { describe, expect, it } from 'vitest';
import { DEFAULT_THEME, InvoicePdfError, renderInvoicePdf } from '../src/index.js';
import NOTO_SANS_BOLD from '../src/fonts/noto-sans-bold.js';
import { decodeBase64 } from '../src/text.js';
import { englishHeader, englishInvoice, pngLogo, pngLogoWithAlpha } from './fixtures.js';

const date = new Date('2026-03-31T12:00:00Z');

async function xmpOf(file: Uint8Array): Promise<{ doc: PDFDocument; xmp: string }> {
  const doc = await PDFDocument.load(file, { updateMetadata: false });
  const metadata = doc.catalog.lookup(PDFName.of('Metadata'));
  expect(metadata).toBeInstanceOf(PDFRawStream);
  return { doc, xmp: new TextDecoder().decode(decodePDFRawStream(metadata as PDFRawStream).decode()) };
}

function images(doc: PDFDocument): PDFRawStream[] {
  const out: PDFRawStream[] = [];
  for (const [, object] of doc.context.enumerateIndirectObjects()) {
    if (object instanceof PDFRawStream && object.dict.get(PDFName.of('Subtype')) === PDFName.of('Image')) out.push(object);
  }
  return out;
}

async function contentOf(file: Uint8Array): Promise<string> {
  const doc = await PDFDocument.load(file);
  const contents = doc.getPage(0).node.Contents();
  const streams: PDFStream[] = contents instanceof PDFArray ? Array.from({ length: contents.size() }, (_, i) => contents.lookup(i) as PDFStream) : [contents as PDFStream];
  return streams.map((s) => new TextDecoder('latin1').decode(s instanceof PDFRawStream ? decodePDFRawStream(s).decode() : s.getContents())).join('\n');
}

async function fontNames(file: Uint8Array): Promise<string[]> {
  const doc = await PDFDocument.load(file);
  const out: string[] = [];
  for (const [, object] of doc.context.enumerateIndirectObjects()) {
    if (object instanceof PDFDict && object.get(PDFName.of('Type')) === PDFName.of('FontDescriptor')) out.push(String(object.get(PDFName.of('FontName'))));
  }
  return out;
}

async function refusal(run: () => Promise<unknown>): Promise<InvoicePdfError> {
  try {
    await run();
  } catch (error) {
    expect(error).toBeInstanceOf(InvoicePdfError);
    return error as InvoicePdfError;
  }
  throw new Error('expected a refusal');
}

describe('the metadata', () => {
  it('declares PDF/A-3b in an XMP packet that says what the information dictionary says', async () => {
    const rendered = await renderInvoicePdf(englishInvoice(), { date, producer: 'a producer' });
    const { doc, xmp } = await xmpOf(rendered.file);
    expect(xmp).toContain('<pdfaid:part>3</pdfaid:part>');
    expect(xmp).toContain('<pdfaid:conformance>B</pdfaid:conformance>');
    expect(doc.getTitle()).toBe('Invoice INV-2026-0042');
    expect(xmp).toContain('<dc:title><rdf:Alt><rdf:li xml:lang="x-default">Invoice INV-2026-0042</rdf:li></rdf:Alt></dc:title>');
    expect(doc.getAuthor()).toBe('Example Consulting Limited');
    expect(xmp).toContain('<dc:creator><rdf:Seq><rdf:li>Example Consulting Limited</rdf:li></rdf:Seq></dc:creator>');
    expect(doc.getSubject()).toBe('Invoice INV-2026-0042');
    expect(xmp).toContain('<dc:description><rdf:Alt><rdf:li xml:lang="x-default">Invoice INV-2026-0042</rdf:li></rdf:Alt></dc:description>');
    expect(doc.getCreator()).toBe('@ekwo-ai/invoice-pdf');
    expect(xmp).toContain('<xmp:CreatorTool>@ekwo-ai/invoice-pdf</xmp:CreatorTool>');
    expect(doc.getProducer()).toBe('a producer');
    expect(xmp).toContain('<pdf:Producer>a producer</pdf:Producer>');
    expect(doc.getCreationDate()?.toISOString()).toBe(date.toISOString());
    expect(doc.getModificationDate()?.toISOString()).toBe(date.toISOString());
    expect(xmp).toContain(`<xmp:CreateDate>${date.toISOString()}</xmp:CreateDate>`);
    expect(xmp).toContain(`<xmp:ModifyDate>${date.toISOString()}</xmp:ModifyDate>`);
  });

  it('writes no author where the document names no seller, and escapes what XML would misread', async () => {
    const header = englishHeader({ seller_name: null, seller_legal_name: null, number: 'A&B<1>' });
    const { doc, xmp } = await xmpOf((await renderInvoicePdf(englishInvoice({ header }), { date })).file);
    expect(doc.getAuthor()).toBeUndefined();
    expect(xmp).not.toContain('<dc:creator>');
    expect(xmp).toContain('Invoice A&amp;B&lt;1&gt;');
  });

  it('gives every document an identifier written in hexadecimal digits', async () => {
    // Seeds whose two halves differ in their top bit once gave a negative number, written with a minus sign.
    for (const number of ['CN-2026-0003', 'INV-2026-0042', 'X', 'ΤΙΜ-2026-7', 'INV-1', 'INV-2', 'INV-3', 'INV-4']) {
      const doc = await PDFDocument.load((await renderInvoicePdf(englishInvoice({ header: englishHeader({ number }) }), { date })).file);
      const id = doc.context.trailerInfo.ID?.toString() ?? '';
      expect(id, number).toMatch(/^\[ <[0-9a-f]{32}> <[0-9a-f]{32}> \]$/);
    }
  });
});

describe('the logo', () => {
  it('flattens the alpha channel of a PNG on white, and keeps no soft mask', async () => {
    const rendered = await renderInvoicePdf(englishInvoice({ logo: pngLogoWithAlpha() }), { date });
    const doc = await PDFDocument.load(rendered.file);
    const [image, ...others] = images(doc);
    expect(others).toEqual([]);
    expect(image?.dict.get(PDFName.of('SMask'))).toBeUndefined();
    expect(image?.dict.get(PDFName.of('ColorSpace'))).toBe(PDFName.of('DeviceRGB'));
    const pixels = decodePDFRawStream(image as PDFRawStream).decode();
    const at = (x: number, y: number): number[] => Array.from(pixels.slice((y * 120 + x) * 3, (y * 120 + x) * 3 + 3));
    expect(at(0, 0)).toEqual([255, 255, 255]); // transparent: the paper
    expect(at(60, 0)).toEqual([0x1f, 0x3a, 0x5f]); // opaque: the colour itself
    // Half transparent: halfway to white.
    const half = (c: number): number => Math.round((c * 0x80 + 255 * (255 - 0x80)) / 255);
    expect(at(60, 20)).toEqual([half(0x4a), half(0x90), half(0xe2)]);
  });

  it('leaves an opaque PNG as it is', async () => {
    const doc = await PDFDocument.load((await renderInvoicePdf(englishInvoice({ logo: pngLogo() }), { date })).file);
    const [image] = images(doc);
    expect(image?.dict.get(PDFName.of('SMask'))).toBeUndefined();
    expect(Array.from(decodePDFRawStream(image as PDFRawStream).decode().slice(0, 3))).toEqual([0x1f, 0x3a, 0x5f]);
  });

  it('refuses a CMYK JPEG, whose colours the sRGB output intent does not describe', async () => {
    // The start of a JPEG, and its frame header: 8 bits, 1 × 1, four components.
    const cmyk = new Uint8Array([0xff, 0xd8, 0xff, 0xc0, 0x00, 0x14, 0x08, 0x00, 0x01, 0x00, 0x01, 0x04, 1, 0x11, 0, 2, 0x11, 0, 3, 0x11, 0, 4, 0x11, 0, 0xff, 0xd9]);
    const error = await refusal(() => renderInvoicePdf(englishInvoice({ logo: cmyk })));
    expect(error.code).toBe('unsupported_logo');
    expect(error.message).toContain('CMYK');
  });
});

describe('the theme', () => {
  it('is sober by default', () => {
    expect(DEFAULT_THEME).toEqual({ accent: '#1F3A5F', font: 'Noto Sans', logoPosition: 'left' });
  });

  it('draws the bands in the accent colour, with white text on a dark one and ink on a light one', async () => {
    const dark = await contentOf((await renderInvoicePdf(englishInvoice(), { date })).file);
    expect(dark).toContain(`${0x1f / 255} ${0x3a / 255} ${0x5f / 255} rg`);
    expect(dark).toContain('1 1 1 rg');
    const light = await contentOf((await renderInvoicePdf(englishInvoice(), { date, theme: { accent: '#f2c94c' } })).file);
    expect(light).toContain(`${0xf2 / 255} ${0xc9 / 255} ${0x4c / 255} rg`);
    expect(light).not.toContain('1 1 1 rg');
  });

  it('puts the logo on the right when asked, and on the left otherwise', async () => {
    const left = await contentOf((await renderInvoicePdf(englishInvoice({ logo: pngLogo() }), { date })).file);
    const right = await contentOf((await renderInvoicePdf(englishInvoice({ logo: pngLogo() }), { date, theme: { logoPosition: 'right' } })).file);
    // The image is placed by the first translation of its group: 120 points wide, against the left or the right margin.
    expect(left).toMatch(/q\n1 0 0 1 48 [\d.]+ cm\n[^Q]*\/Image/);
    expect(right).toMatch(new RegExp(`q\\n1 0 0 1 ${595.28 - 48 - 120} [\\d.]+ cm\\n[^Q]*\\/Image`));
  });

  it('draws with the caller’s typeface, Noto Sans only where it lacks a character', async () => {
    // Noto Sans Bold, handed over as a caller's font: every word is then drawn in it.
    const font = { regular: decodeBase64(NOTO_SANS_BOLD) };
    const names = await fontNames((await renderInvoicePdf(englishInvoice(), { date, theme: { font } })).file);
    expect(names.length).toBeGreaterThan(0);
    for (const name of names) expect(name).toMatch(/^\/NotoSans-Bold-/);
  });

  it('refuses a colour it cannot read, and a side that is not one', async () => {
    expect((await refusal(() => renderInvoicePdf(englishInvoice(), { theme: { accent: 'navy' } }))).code).toBe('invalid_value');
    const side = { logoPosition: 'top' } as unknown as { logoPosition: 'left' };
    expect((await refusal(() => renderInvoicePdf(englishInvoice(), { theme: side }))).code).toBe('invalid_value');
  });
});
