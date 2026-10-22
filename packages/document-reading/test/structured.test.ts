import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { readCii } from '@ekwo-ai/factur-x';
import { embedFacturX } from '@ekwo-ai/factur-x/pdf';
import { readUbl } from '@ekwo-ai/peppol-ubl';
import { PDFDocument } from 'pdf-lib';
import { describe, expect, it } from 'vitest';
import { fileKind, purchaseDraftOf, readStructured } from '../src/index.js';

const here = dirname(fileURLToPath(import.meta.url));
const formats = join(here, '..', '..', 'formats');
const cii = (name: string): Uint8Array => readFileSync(join(formats, 'factur-x', 'test', 'fixtures', 'received', name));
const ubl = (name: string): Uint8Array => readFileSync(join(formats, 'peppol-ubl', 'test', 'fixtures', 'received', name));

async function facturXPdf(): Promise<Uint8Array> {
  const doc = await PDFDocument.create();
  doc.addPage([595, 842]);
  const xml = new TextDecoder().decode(cii('invoice-with-pdf.xml'));
  return embedFacturX(await doc.save(), xml, { date: new Date('2026-03-31T10:00:00Z') });
}

describe('readStructured', () => {
  it('reads a CII file as readCii does', async () => {
    const bytes = cii('invoice-with-pdf.xml');
    expect(fileKind(bytes)).toBe('xml');
    expect(await readStructured(bytes)).toEqual(readCii(bytes));
  });

  it('reads a UBL file as readUbl does', async () => {
    const bytes = ubl('invoice-with-pdf.xml');
    const read = await readStructured(bytes);
    expect(read).toEqual(readUbl(bytes));
    expect(read?.invoice.syntax).toBe('ubl');
  });

  it('reads a UBL credit note into a credit note', async () => {
    const read = await readStructured(ubl('credit-note.xml'));
    expect(read?.invoice.kind).toBe('credit_note');
  });

  it('reads the XML a Factur-X PDF carries', async () => {
    const pdf = await facturXPdf();
    expect(fileKind(pdf)).toBe('pdf');
    const read = await readStructured(pdf);
    expect(read?.invoice).toEqual(readCii(cii('invoice-with-pdf.xml')).invoice);
  });

  it('takes an ArrayBuffer as well as bytes', async () => {
    const bytes = cii('invoice-minimum.xml');
    const buffer = new Uint8Array(bytes).buffer;
    expect((await readStructured(buffer))?.invoice.number).toBe(readCii(bytes).invoice.number);
  });

  it('answers undefined for what holds no e-invoice, so that a model reads it', async () => {
    const plainPdf = await (await PDFDocument.create()).save();
    expect(await readStructured(plainPdf)).toBeUndefined();
    expect(await readStructured(new TextEncoder().encode('<note>not an invoice</note>'))).toBeUndefined();
    const jpeg = new Uint8Array([0xff, 0xd8, 0xff, 0xe0, 0, 16, 74, 70, 73, 70]);
    expect(fileKind(jpeg)).toBe('other');
    expect(await readStructured(jpeg)).toBeUndefined();
  });

  it('answers undefined for a file over the limits it is given', async () => {
    expect(await readStructured(cii('invoice-with-pdf.xml'), { maxBytes: 100 })).toBeUndefined();
  });
});

describe('purchaseDraftOf a structured invoice', () => {
  it('writes one line per line and per document allowance or charge, the unit code kept', () => {
    const { invoice } = readCii(cii('invoice-with-pdf.xml'));
    const draft = purchaseDraftOf(invoice);
    expect(draft.doc_type).toBe('purchase_invoice');
    expect(draft.supplier_reference).toBe(invoice.number);
    expect(draft.currency_code).toBe(invoice.currency);
    expect(draft.lines).toHaveLength(invoice.lines.length + invoice.allowances.length);
    invoice.lines.forEach((line, index) => {
      const written = draft.lines[index];
      if (written?.quantity === line.quantity) expect(written?.unit_code).toBe(line.unitCode ?? 'C62');
      expect(written?.vat_category).toBe(line.vatCategory);
    });
    invoice.allowances.forEach((one, index) => {
      const written = draft.lines[invoice.lines.length + index];
      expect(written?.unit_price.startsWith('-')).toBe(!one.charge);
    });
  });

  it('makes a credit note a purchase credit note', async () => {
    const read = await readStructured(ubl('credit-note.xml'));
    expect(read && purchaseDraftOf(read.invoice).doc_type).toBe('purchase_credit_note');
  });

  it('keeps the payee IBAN and the references in their columns', () => {
    const { invoice } = readUbl(ubl('invoice-with-pdf.xml'));
    const draft = purchaseDraftOf(invoice);
    expect(draft.buyer_reference).toBe(invoice.buyerReference);
    expect(draft.order_reference).toBe(invoice.orderReference);
    const iban = invoice.paymentMeans.find((one) => one.account?.kind === 'iban')?.account?.value ?? null;
    expect(draft.payee_iban).toBe(iban);
  });
});
