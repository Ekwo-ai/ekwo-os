/**
 * The business terms of EN 16931 the rows hold are on the page.
 *
 * One term per row of the table: its identifier, and what a reader of the PDF
 * finds for it — read out of the file. The terms EN 16931 makes mandatory come
 * first; the codes written for a machine (BT-24, BT-81, BT-118, BT-126,
 * BT-151) are not printed, and the README says why. The terms the views do not
 * carry are listed there too.
 */

import { describe, expect, it } from 'vitest';
import { renderInvoicePdf } from '../src/index.js';
import { englishHeader, englishInvoice } from './fixtures.js';
import { pdfText } from './pdf-text.js';

const money = (value: string): string => new Intl.NumberFormat('en', { style: 'currency', currency: 'EUR' }).format(value as unknown as number);
const day = (iso: string): string => new Intl.DateTimeFormat('en', { dateStyle: 'medium', timeZone: 'UTC' }).format(new Date(`${iso}T00:00:00Z`));
const country = (code: string): string => new Intl.DisplayNames(['en'], { type: 'region' }).of(code) as string;

const input = englishInvoice({
  header: englishHeader({
    tax_point_date: '2026-03-30',
    contract_reference: 'CT-9',
    project_reference: 'PRJ-3',
    amount_paid: '601.50',
    amount_residual: '2000.00',
    delivery_address_line1: 'Lagerweg 4',
    delivery_postal_code: '20095',
    delivery_city: 'Hamburg',
    delivery_country: 'DE',
  }),
  taxes: [
    { tax_name: 'VAT 21%', vat_category: 'S', tax_rate: '21.0000', base_amount: '1900.00', tax_charged: '399.00' },
    { tax_name: 'Exempt', vat_category: 'E', tax_rate: '0', base_amount: '250.00', tax_charged: '0.00', exemption_reason: 'Exempt: an education service.' },
  ],
});

/** [term, its name, a string the page shows for it]. */
const MANDATORY: [string, string, string][] = [
  ['BT-1', 'Invoice number', 'INV-2026-0042'],
  ['BT-2', 'Invoice issue date', day('2026-03-31')],
  ['BT-3', 'Invoice type code', 'Invoice'],
  ['BT-5', 'Invoice currency code', money('2601.50')],
  ['BT-27', 'Seller name', 'Example Consulting'],
  ['BT-40', 'Seller country code', country('IE')],
  ['BT-44', 'Buyer name', 'Fictional Customer GmbH'],
  ['BT-55', 'Buyer country code', country('DE')],
  ['BT-109', 'Invoice total amount without VAT', money('2150.00')],
  ['BT-112', 'Invoice total amount with VAT', money('2601.50')],
  ['BT-115', 'Amount due for payment', money('2000.00')],
  ['BT-116', 'VAT category taxable amount', money('1900.00')],
  ['BT-117', 'VAT category tax amount', money('399.00')],
  ['BT-129', 'Invoiced quantity', '2 days'],
  ['BT-130', 'Invoiced quantity unit of measure', '2 days'],
  ['BT-131', 'Invoice line net amount', money('1900.00')],
  ['BT-146', 'Item net price', money('950.00')],
  ['BT-153', 'Item name', 'Consulting days'],
];

const OPTIONAL: [string, string, string][] = [
  ['BT-7', 'Value added tax point date', day('2026-03-30')],
  ['BT-9', 'Payment due date', day('2026-04-30')],
  ['BT-10', 'Buyer reference', 'PO-7731'],
  ['BT-11', 'Project reference', 'PRJ-3'],
  ['BT-12', 'Contract reference', 'CT-9'],
  ['BT-13', 'Purchase order reference', 'ORD-55'],
  ['BT-20', 'Payment terms', 'Terms: Thirty days from the date of the invoice.'],
  ['BT-22', 'Invoice note', 'Thank you for your business.'],
  ['BT-28', 'Seller trading name', 'Example Consulting'],
  ['BT-29/30', 'Seller identifier', 'Registration number: 654321'],
  ['BT-31', 'Seller VAT identifier', 'VAT number: IE1234567T'],
  ['BT-33', 'Seller additional legal information', 'Share capital €100.00'],
  ['BT-35', 'Seller address line 1', '1 Example Street'],
  ['BT-37/38', 'Seller city, post code', 'D02 X285 Dublin'],
  ['BT-41/42/43', 'Seller contact phone, e-mail', 'Phone: +353 1 000 0000'],
  ['BT-48', 'Buyer VAT identifier', 'VAT number: DE123456789'],
  ['BT-49', 'Buyer electronic address', 'Electronic address: 9930:DE123456789'],
  ['BT-50', 'Buyer address line 1', 'Teststraße 10'],
  ['BT-52/53', 'Buyer city, post code', '10115 Berlin'],
  ['BT-72', 'Actual delivery date', day('2026-03-28')],
  ['BT-75', 'Deliver to address line 1', 'Lagerweg 4'],
  ['BT-77/78', 'Deliver to city, post code', '20095 Hamburg'],
  ['BT-83', 'Remittance information', 'Reference: RF18 5390 0754 7034'],
  ['BT-84', 'Payment account identifier', 'IBAN: IE29 AIBK 9311 5212 3456 78'],
  ['BT-86', 'Payment service provider identifier', 'BIC: AIBKIE2D'],
  ['BT-110', 'Invoice total VAT amount', money('451.50')],
  ['BT-113', 'Paid amount', money('601.50')],
  ['BT-119', 'VAT category rate', '21%'],
  ['BT-120', 'VAT exemption reason text', 'Exempt: an education service.'],
  ['BT-154', 'Item description', 'CONS-DAY · Review of the closing procedure and of the'],
  ['BT-155', 'Item seller identifier', 'CONS-DAY · Review of the closing procedure and of the'],
];

describe('the business terms of EN 16931 on the page', async () => {
  const page = (await pdfText((await renderInvoicePdf(input)).file)).flat();
  const shows = (expected: string): boolean => page.some((s) => s === expected || s.includes(expected));

  it.each(MANDATORY)('%s, %s: mandatory, and printed', (_term, _name, expected) => {
    expect(shows(expected), expected).toBe(true);
  });

  it.each(OPTIONAL)('%s, %s: printed when the rows hold it', (_term, _name, expected) => {
    expect(shows(expected), expected).toBe(true);
  });

  it('BT-3: a credit note is titled as one', async () => {
    const credit = (await pdfText((await renderInvoicePdf(englishInvoice({ header: englishHeader({ doc_type: 'sale_credit_note' }) }))).file)).flat();
    expect(credit).toContain('Credit note');
  });
});
