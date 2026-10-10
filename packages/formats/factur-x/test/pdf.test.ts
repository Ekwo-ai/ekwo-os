import { PDFDocument, PDFName, PDFRawStream, StandardFonts, decodePDFRawStream } from 'pdf-lib';
import { describe, expect, it } from 'vitest';
import { generateCiiXml } from '../src/index.js';
import { embedFacturX, extractFacturX } from '../src/pdf.js';
import { exampleInvoice } from './fixtures/example-invoice.js';

async function blankInvoicePdf(): Promise<Uint8Array> {
  const doc = await PDFDocument.create();
  const page = doc.addPage([595, 842]);
  const font = await doc.embedFont(StandardFonts.Helvetica);
  page.drawText('Invoice INV-2026-0042', { x: 50, y: 780, size: 18, font });
  return doc.save();
}

describe('embedFacturX / extractFacturX', () => {
  it('round-trips the XML through a PDF', async () => {
    const xml = generateCiiXml(exampleInvoice);
    const pdf = await embedFacturX(await blankInvoicePdf(), xml, { date: new Date('2026-03-31T10:00:00Z'), title: 'Invoice INV-2026-0042' });
    const text = new TextDecoder('latin1').decode(pdf);

    expect(text).toContain('/AFRelationship /Alternative');
    expect(text).toContain('factur-x.xml');
    expect(text).toContain('<fx:ConformanceLevel>BASIC</fx:ConformanceLevel>');
    expect(text).toContain('<pdfaid:part>3</pdfaid:part>');
    expect(text).toContain('urn:factur-x:pdfa:CrossIndustryDocument:invoice:1p0#');

    const extracted = await extractFacturX(pdf);
    expect(extracted?.filename).toBe('factur-x.xml');
    expect(extracted?.xml).toBe(xml);
  });

  it('writes the conformance level of the requested profile', async () => {
    const pdf = await embedFacturX(await blankInvoicePdf(), '<x/>', { profile: 'en16931' });
    expect(new TextDecoder('latin1').decode(pdf)).toContain('<fx:ConformanceLevel>EN 16931</fx:ConformanceLevel>');
  });

  it('writes an XMP packet that says what the information dictionary says', async () => {
    const source = await PDFDocument.create();
    source.addPage([595, 842]);
    source.setTitle('Invoice INV-2026-0042');
    source.setAuthor('Example Consulting Limited');
    source.setSubject('Invoice INV-2026-0042 & its CII');
    source.setKeywords(['invoice', 'INV-2026-0042']);
    source.setCreator('an invoicing tool');
    source.setCreationDate(new Date('2026-03-30T08:00:00Z'));
    const date = new Date('2026-03-31T10:00:00Z');
    const pdf = await embedFacturX(await source.save(), '<x/>', { date, producer: 'a producer' });

    const doc = await PDFDocument.load(pdf, { updateMetadata: false });
    const metadata = doc.catalog.lookup(PDFName.of('Metadata'));
    expect(metadata).toBeInstanceOf(PDFRawStream);
    const xmp = new TextDecoder().decode(decodePDFRawStream(metadata as PDFRawStream).decode());

    // Each entry of the information dictionary, and the same value in the XMP.
    expect(doc.getTitle()).toBe('Invoice INV-2026-0042');
    expect(xmp).toContain('<dc:title><rdf:Alt><rdf:li xml:lang="x-default">Invoice INV-2026-0042</rdf:li></rdf:Alt></dc:title>');
    expect(doc.getAuthor()).toBe('Example Consulting Limited');
    expect(xmp).toContain('<dc:creator><rdf:Seq><rdf:li>Example Consulting Limited</rdf:li></rdf:Seq></dc:creator>');
    expect(doc.getSubject()).toBe('Invoice INV-2026-0042 & its CII');
    expect(xmp).toContain('<rdf:li xml:lang="x-default">Invoice INV-2026-0042 &amp; its CII</rdf:li>');
    expect(doc.getKeywords()).toBe('invoice INV-2026-0042');
    expect(xmp).toContain('<pdf:Keywords>invoice INV-2026-0042</pdf:Keywords>');
    expect(doc.getCreator()).toBe('an invoicing tool');
    expect(xmp).toContain('<xmp:CreatorTool>an invoicing tool</xmp:CreatorTool>');
    expect(doc.getProducer()).toBe('a producer');
    expect(xmp).toContain('<pdf:Producer>a producer</pdf:Producer>');
    // The document was created when it was, and modified when the XML went in.
    expect(doc.getCreationDate()?.toISOString()).toBe('2026-03-30T08:00:00.000Z');
    expect(xmp).toContain('<xmp:CreateDate>2026-03-30T08:00:00.000Z</xmp:CreateDate>');
    expect(doc.getModificationDate()?.toISOString()).toBe(date.toISOString());
    expect(xmp).toContain(`<xmp:ModifyDate>${date.toISOString()}</xmp:ModifyDate>`);
  });

  it('gives the title and the creator it is asked for to both', async () => {
    const pdf = await embedFacturX(await blankInvoicePdf(), '<x/>', { title: 'Credit note CN-1', creator: 'a tool' });
    const doc = await PDFDocument.load(pdf, { updateMetadata: false });
    expect(doc.getTitle()).toBe('Credit note CN-1');
    expect(doc.getCreator()).toBe('a tool');
    const text = new TextDecoder('latin1').decode(pdf);
    expect(text).toContain('<rdf:li xml:lang="x-default">Credit note CN-1</rdf:li>');
    expect(text).toContain('<xmp:CreatorTool>a tool</xmp:CreatorTool>');
  });

  it('returns null for a PDF without invoice data', async () => {
    expect(await extractFacturX(await blankInvoicePdf())).toBeNull();
  });
});
