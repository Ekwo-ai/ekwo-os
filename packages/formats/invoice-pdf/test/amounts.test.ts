/**
 * What the page says and what the XML inside it says are the same figures.
 *
 * Each document is rendered as Factur-X with the real `embedFacturX`; its CII
 * is read back out of the file by the Factur-X reader, and its totals, its tax
 * per rate and its amount due are looked for on the page — in the text read
 * out of the PDF, beside the label that names them.
 */

import { generateCiiXml } from '@ekwo-ai/factur-x';
import { embedFacturX, readFacturX } from '@ekwo-ai/factur-x/pdf';
import { describe, expect, it } from 'vitest';
import { ENGLISH_LABELS, renderFacturXPdf, type InvoicePdfInput } from '../src/index.js';
import { creditNote, twoRateInvoice } from './fixtures.js';
import { pdfText } from './pdf-text.js';

const money = (value: string): string => new Intl.NumberFormat('en', { style: 'currency', currency: 'EUR' }).format(value as unknown as number);
const rate = (value: string): string => new Intl.NumberFormat('en', { style: 'percent', maximumFractionDigits: 4 }).format(Number(value) / 100);

/** The string shown right after `label` on the page: the figure printed beside it. */
function beside(page: string[], label: string): string | undefined {
  const at = page.indexOf(label);
  expect(at, `"${label}" is on the page`).toBeGreaterThan(-1);
  expect(page.indexOf(label, at + 1), `"${label}" is on the page once`).toBe(-1);
  return page[at + 1];
}

async function check(input: InvoicePdfInput, cii: Parameters<typeof generateCiiXml>[0], due: string): Promise<void> {
  const xml = generateCiiXml(cii, { profile: 'en16931' });
  const rendered = await renderFacturXPdf(input, { xml, embed: embedFacturX, date: new Date('2026-03-31T12:00:00Z') });
  const { invoice, violations } = await readFacturX(rendered.file);
  expect(violations).toEqual([]);
  const [page] = await pdfText(rendered.file);
  if (page === undefined) throw new Error('no page');

  // The totals.
  expect(beside(page, ENGLISH_LABELS.totalUntaxed)).toBe(money(invoice.totals.taxExclusive));
  expect(beside(page, ENGLISH_LABELS.totalTax)).toBe(money(invoice.totals.taxTotal as string));
  expect(beside(page, ENGLISH_LABELS.total)).toBe(money(invoice.totals.taxInclusive));
  const prepaid = invoice.totals.prepaid;
  if (prepaid !== null && Number(prepaid) !== 0) expect(beside(page, ENGLISH_LABELS.amountPaid)).toBe(money(prepaid));
  // What is still due.
  expect(beside(page, due)).toBe(money(invoice.totals.payable));

  // The tax, one row per rate: the rate, the base and the tax, in this order, under the heading of the summary.
  const summary = page.slice(page.indexOf(ENGLISH_LABELS.taxSummary));
  expect(invoice.taxes.length).toBe(input.taxes.length);
  for (const tax of invoice.taxes) {
    const row = [rate(tax.rate as string), money(tax.base), money(tax.tax)];
    const at = summary.findIndex((_, i) => row.every((cell, j) => summary[i + j] === cell));
    expect(at, `the row ${row.join(' | ')} is in the tax summary`).toBeGreaterThan(-1);
  }
}

describe('the figures of the page are the figures of the CII', () => {
  it('on an invoice under two tax rates, partly paid', async () => {
    const { input, cii } = twoRateInvoice();
    await check(input, cii, ENGLISH_LABELS.amountDue);
  });

  it('on a credit note', async () => {
    const { input, cii } = creditNote();
    await check(input, cii, ENGLISH_LABELS.amountCredited);
  });

  it('and the reader of the page sees what the renderer says it drew', async () => {
    const { input } = twoRateInvoice();
    const rendered = await renderFacturXPdf(input, { xml: '<x/>', embed: async (pdf) => pdf });
    const extracted = (await pdfText(rendered.file)).flat();
    for (const drawn of rendered.text.flat()) expect(extracted).toContain(drawn);
  });
});
