/**
 * The rendered PDF, handed to the Factur-X brick, and read back by it.
 *
 * `@ekwo-ai/factur-x` is a development dependency only: the package itself
 * never imports it, and the caller passes `embedFacturX` in.
 */

import { generateCiiXml, type Invoice } from '@ekwo-ai/factur-x';
import { embedFacturX, extractFacturX, readFacturX } from '@ekwo-ai/factur-x/pdf';
import { PDFDocument, PDFName, PDFRawStream, decodePDFRawStream } from 'pdf-lib';
import { describe, expect, it } from 'vitest';
import { renderFacturXPdf, renderInvoicePdf } from '../src/index.js';
import { englishInvoice, pngLogo } from './fixtures.js';

/** The same invoice as the fixture, as the Factur-X brick takes it. */
const cii: Invoice = {
  number: 'INV-2026-0042',
  issueDate: '2026-03-31',
  dueDate: '2026-04-30',
  deliveryDate: '2026-03-28',
  currency: 'EUR',
  seller: {
    name: 'Example Consulting Limited',
    vatId: 'IE1234567T',
    address: { line1: '1 Example Street', postalCode: 'D02 X285', city: 'Dublin', country: 'IE' },
  },
  buyer: {
    name: 'Fictional Customer GmbH',
    vatId: 'DE123456789',
    address: { line1: 'Teststraße 10', postalCode: '10115', city: 'Berlin', country: 'DE' },
  },
  lines: [
    { id: '2', name: 'Consulting days', quantity: 2, unitCode: 'DAY', unitPrice: 950, vatRate: 21, vatCategory: 'S' },
    { id: '3', name: 'Travel', quantity: 1, unitPrice: 250, vatRate: 21, vatCategory: 'S' },
  ],
  payment: { meansCode: '58', iban: 'IE29AIBK93115212345678' },
};

describe('the Factur-X chain', () => {
  it('renders the PDF, embeds the CII, and the Factur-X reader reads the same invoice back', async () => {
    const xml = generateCiiXml(cii, { profile: 'en16931' });
    const date = new Date('2026-03-31T12:00:00Z');
    const rendered = await renderFacturXPdf(englishInvoice({ logo: pngLogo() }), { xml, profile: 'en16931', embed: embedFacturX, date });

    expect((await extractFacturX(rendered.file))?.xml).toBe(xml);
    const back = await readFacturX(rendered.file);
    expect(back.filename).toBe('factur-x.xml');
    expect(back.profile).toBe('en16931');
    expect(back.violations).toEqual([]);
    expect(back.invoice.number).toBe('INV-2026-0042');
    expect(back.invoice.kind).toBe('invoice');
    expect(back.invoice.totals.payable).toBe('2601.50');

    // Still the visual invoice: the same pages, the same title, with the PDF/A-3 declaration beside it.
    const doc = await PDFDocument.load(rendered.file);
    expect(doc.getPageCount()).toBe(rendered.pageCount);
    expect(doc.getTitle()).toBe('Invoice INV-2026-0042');
    const metadata = doc.catalog.lookup(PDFName.of('Metadata'));
    expect(metadata).toBeInstanceOf(PDFRawStream);
    const xmp = new TextDecoder().decode(decodePDFRawStream(metadata as PDFRawStream).decode());
    expect(xmp).toContain('<pdfaid:part>3</pdfaid:part>');
    expect(xmp).toContain('factur-x.xml');
    expect(doc.catalog.get(PDFName.of('OutputIntents'))).toBeDefined();
    expect(doc.context.trailerInfo.ID).toBeDefined();
  });

  it('hands the embedding the exact PDF it rendered', async () => {
    const seen: Uint8Array[] = [];
    const date = new Date('2026-03-31T12:00:00Z');
    const rendered = await renderFacturXPdf(englishInvoice(), {
      xml: '<x/>',
      date,
      embed: async (pdf, xml, options) => {
        seen.push(pdf);
        expect(xml).toBe('<x/>');
        expect(options).toMatchObject({ profile: 'en16931', title: 'Invoice INV-2026-0042', date });
        return pdf;
      },
    });
    const alone = await renderInvoicePdf(englishInvoice(), { date });
    expect(seen).toHaveLength(1);
    expect(rendered.pageCount).toBe(alone.pageCount);
    expect(rendered.text).toEqual(alone.text);
  });
});
