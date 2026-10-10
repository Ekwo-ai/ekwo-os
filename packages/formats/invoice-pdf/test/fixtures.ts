/**
 * Documents as the four views would return them, for a fictional seller and
 * fictional customers. Every name, number and address here is invented.
 */

import { deflateSync } from 'node:zlib';
import type { Invoice } from '@ekwo-ai/factur-x';
import type {
  DocumentHeaderRow,
  DocumentLegalMentionRow,
  DocumentLineRow,
  DocumentTaxRow,
  InvoicePdfInput,
} from '../src/index.js';

export function englishHeader(overrides: Partial<DocumentHeaderRow> = {}): DocumentHeaderRow {
  return {
    document_id: '00000000-0000-4000-8000-000000000001',
    doc_type: 'sale_invoice',
    state: 'posted',
    payment_state: 'not_paid',
    number: 'INV-2026-0042',
    document_date: '2026-03-31',
    due_date: '2026-04-30',
    delivery_date: '2026-03-28',
    currency_code: 'EUR',
    amount_untaxed: '2150.00',
    amount_tax: '451.50',
    amount_total: '2601.50',
    amount_paid: '0.00',
    amount_residual: '2601.50',
    payment_terms: 'Thirty days from the date of the invoice.',
    payment_means_code: '58',
    payment_reference: 'RF18 5390 0754 7034',
    buyer_reference: 'PO-7731',
    order_reference: 'ORD-55',
    note: 'Thank you for your business.',
    payee_iban: 'IE29AIBK93115212345678',
    payee_bic: 'AIBKIE2D',
    seller_name: 'Example Consulting',
    seller_legal_name: 'Example Consulting Limited',
    seller_legal_form: 'Ltd',
    seller_vat_number: 'IE1234567T',
    seller_registration_number: '654321',
    seller_address_line1: '1 Example Street',
    seller_postal_code: 'D02 X285',
    seller_city: 'Dublin',
    seller_country: 'IE',
    seller_email: 'billing@example.invalid',
    seller_phone: '+353 1 000 0000',
    seller_website: 'example.invalid',
    seller_logo_url: null,
    seller_share_capital: '100.00',
    seller_share_capital_currency: 'EUR',
    buyer_name: 'Fictional Customer GmbH',
    buyer_vat_number: 'DE123456789',
    buyer_address_line1: 'Teststraße 10',
    buyer_postal_code: '10115',
    buyer_city: 'Berlin',
    buyer_country: 'DE',
    buyer_email: 'accounts@customer.invalid',
    buyer_peppol_scheme: '9930',
    buyer_peppol_identifier: 'DE123456789',
    language: 'en',
    country: 'IE',
    ...overrides,
  };
}

export function englishLines(): DocumentLineRow[] {
  return [
    { sequence: 1, line_type: 'section', item_name: 'Advisory work, March' },
    {
      sequence: 2,
      line_type: 'product',
      item_name: 'Consulting days',
      item_description: 'Review of the closing procedure and of the reporting calendar.',
      seller_item_identifier: 'CONS-DAY',
      quantity: '2',
      unit_code: 'DAY',
      unit_price: '950.00',
      amount_untaxed: '1900.00',
      vat_category: 'S',
      vat_rate: '21.0000',
    },
    {
      sequence: 3,
      line_type: 'product',
      item_name: 'Travel',
      quantity: '1',
      unit_code: 'C62',
      unit_price: '250.00',
      amount_untaxed: '250.00',
      vat_category: 'S',
      vat_rate: '21.0000',
    },
  ];
}

export function englishTaxes(): DocumentTaxRow[] {
  return [
    {
      tax_code: 'VAT21',
      tax_name: 'VAT 21%',
      vat_category: 'S',
      tax_rate: '21.0000',
      base_amount: '2150.00',
      tax_amount: '451.50',
      tax_charged: '451.50',
      exemption_reason: null,
    },
  ];
}

export function englishMentions(): DocumentLegalMentionRow[] {
  return [
    { code: 'late', sequence: 2, text: 'Late payment interest is charged at the statutory rate.' },
    { code: 'always', sequence: 1, text: 'A mention the country requires on every invoice.' },
  ];
}

export function englishInvoice(overrides: Partial<InvoicePdfInput> = {}): InvoicePdfInput {
  return { header: englishHeader(), lines: englishLines(), taxes: englishTaxes(), mentions: englishMentions(), ...overrides };
}

/** {@link englishInvoice} as the Factur-X brick takes it, to write its CII. */
export function englishCii(): Invoice {
  return {
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
    payment: { meansCode: '58', iban: 'IE29AIBK93115212345678', bic: 'AIBKIE2D', reference: 'RF18 5390 0754 7034', terms: 'Thirty days from the date of the invoice.' },
  };
}

/**
 * An invoice under two tax rates, partly paid, and its CII: the figures of
 * one are the figures of the other, as the books would give them to both.
 */
export function twoRateInvoice(): { input: InvoicePdfInput; cii: Invoice } {
  const input = englishInvoice({
    header: englishHeader({
      number: 'INV-2026-0051',
      amount_untaxed: '2020.00',
      amount_tax: '409.80',
      amount_total: '2429.80',
      amount_paid: '429.80',
      amount_residual: '2000.00',
    }),
    lines: [
      { ...englishLines()[1]! },
      {
        sequence: 3,
        line_type: 'product',
        item_name: 'Printed handbooks',
        quantity: '3',
        unit_code: 'C62',
        unit_price: '40.00',
        amount_untaxed: '120.00',
        vat_category: 'S',
        vat_rate: '9.0000',
      },
    ],
    taxes: [
      { tax_code: 'VAT21', tax_name: 'VAT 21%', vat_category: 'S', tax_rate: '21.0000', base_amount: '1900.00', tax_amount: '399.00', tax_charged: '399.00' },
      { tax_code: 'VAT9', tax_name: 'VAT 9%', vat_category: 'S', tax_rate: '9.0000', base_amount: '120.00', tax_amount: '10.80', tax_charged: '10.80' },
    ],
  });
  const cii: Invoice = {
    ...englishCii(),
    number: 'INV-2026-0051',
    lines: [
      { id: '2', name: 'Consulting days', quantity: 2, unitCode: 'DAY', unitPrice: 950, vatRate: 21, vatCategory: 'S' },
      { id: '3', name: 'Printed handbooks', quantity: 3, unitPrice: 40, vatRate: 9, vatCategory: 'S' },
    ],
    prepaidAmount: 429.8,
  };
  return { input, cii };
}

/** A credit note for part of {@link englishInvoice}, and its CII. */
export function creditNote(): { input: InvoicePdfInput; cii: Invoice } {
  const input = englishInvoice({
    header: englishHeader({
      doc_type: 'sale_credit_note',
      number: 'CN-2026-0003',
      due_date: null,
      amount_untaxed: '250.00',
      amount_tax: '52.50',
      amount_total: '302.50',
      amount_paid: '0.00',
      amount_residual: '302.50',
    }),
    lines: [{ ...englishLines()[2]! }],
    taxes: [{ tax_code: 'VAT21', tax_name: 'VAT 21%', vat_category: 'S', tax_rate: '21.0000', base_amount: '250.00', tax_amount: '52.50', tax_charged: '52.50' }],
  });
  const { dueDate: _due, payment: _payment, ...rest } = englishCii();
  const cii: Invoice = {
    ...rest,
    number: 'CN-2026-0003',
    type: 'credit-note',
    precedingInvoice: { number: 'INV-2026-0042', issueDate: '2026-03-31' },
    lines: [{ id: '3', name: 'Travel', quantity: 1, unitPrice: 250, vatRate: 21, vatCategory: 'S' }],
  };
  return { input, cii };
}

/** A Greek invoice: Greek script for the parties, the lines and the words of the layout. */
export function greekInvoice(): InvoicePdfInput {
  return {
    header: englishHeader({
      number: 'ΤΙΜ-2026-7',
      language: 'el',
      seller_name: 'Παράδειγμα Συμβουλευτική',
      seller_legal_name: 'Παράδειγμα Συμβουλευτική Μονοπρόσωπη Ι.Κ.Ε.',
      seller_legal_form: null,
      seller_address_line1: 'Οδός Παραδείγματος 1',
      seller_postal_code: '105 57',
      seller_city: 'Αθήνα',
      seller_country: 'GR',
      seller_vat_number: 'EL123456789',
      buyer_name: 'Φανταστικός Πελάτης Α.Ε.',
      buyer_address_line1: 'Λεωφόρος Δοκιμής 10',
      buyer_postal_code: '546 21',
      buyer_city: 'Θεσσαλονίκη',
      buyer_country: 'GR',
      buyer_vat_number: 'EL987654321',
      buyer_peppol_scheme: null,
      buyer_peppol_identifier: null,
      payment_terms: 'Πληρωμή εντός τριάντα ημερών.',
      note: 'Σας ευχαριστούμε για τη συνεργασία.',
      amount_untaxed: '2150.00',
      amount_tax: '516.00',
      amount_total: '2666.00',
      amount_residual: '2666.00',
    }),
    lines: [
      {
        sequence: 1,
        item_name: 'Ημέρες συμβουλευτικής',
        item_description: 'Επισκόπηση της διαδικασίας κλεισίματος.',
        quantity: '2',
        unit_code: 'DAY',
        unit_price: '950.00',
        amount_untaxed: '1900.00',
        vat_category: 'S',
        vat_rate: '24.0000',
      },
      {
        sequence: 2,
        item_name: 'Έξοδα μετακίνησης',
        quantity: '1',
        unit_price: '250.00',
        amount_untaxed: '250.00',
        vat_category: 'S',
        vat_rate: '24.0000',
      },
    ],
    taxes: [{ tax_name: 'ΦΠΑ 24%', vat_category: 'S', tax_rate: '24.0000', base_amount: '2150.00', tax_charged: '516.00' }],
    mentions: [{ code: 'always', sequence: 1, text: 'Μια φράση που απαιτεί η χώρα σε κάθε τιμολόγιο.' }],
  };
}

/** The words of the layout in Greek, as a caller would pass them. Only some: the rest stays English. */
export const GREEK_LABELS = {
  invoice: 'Τιμολόγιο',
  creditNote: 'Πιστωτικό τιμολόγιο',
  number: 'Αριθμός',
  date: 'Ημερομηνία',
  dueDate: 'Λήξη',
  billTo: 'Πελάτης',
  description: 'Περιγραφή',
  quantity: 'Ποσότητα',
  unitPrice: 'Τιμή μονάδας',
  taxRate: 'ΦΠΑ',
  amount: 'Ποσό',
  total: 'Σύνολο',
  amountDue: 'Πληρωτέο',
  page: 'Σελίδα {page} από {pages}',
  units: { DAY: 'ημέρες' },
};

/** A Thai invoice: the second embedded font, and a script written without spaces between words. */
export function thaiInvoice(): InvoicePdfInput {
  const base = englishInvoice();
  return {
    ...base,
    header: englishHeader({ language: 'th', currency_code: 'THB', buyer_name: 'บริษัท ลูกค้าสมมติ จำกัด', buyer_city: 'กรุงเทพมหานคร', buyer_country: 'TH' }),
    lines: [{ ...englishLines()[1]!, item_name: 'ค่าที่ปรึกษาด้านบัญชีและการปิดงบการเงินประจำเดือน', item_description: 'ทบทวนขั้นตอนการปิดบัญชี' }],
  };
}

/** `n` product lines whose amounts add up to the totals of {@link englishHeader}'s shape. */
export function longInvoice(n: number): InvoicePdfInput {
  const lines: DocumentLineRow[] = [];
  for (let i = 1; i <= n; i++) {
    lines.push({
      sequence: i,
      line_type: 'product',
      item_name: `Item ${i}`,
      item_description: i % 10 === 0 ? 'A longer description that wraps onto a second line of the table, to see that the rows keep their height. '.repeat(2) : null,
      quantity: '1',
      unit_price: '10.00',
      amount_untaxed: '10.00',
      vat_category: 'S',
      vat_rate: '21.0000',
    });
  }
  const untaxed = `${n * 10}.00`;
  const tax = (n * 2.1).toFixed(2);
  const total = (n * 12.1).toFixed(2);
  return {
    header: englishHeader({ amount_untaxed: untaxed, amount_tax: tax, amount_total: total, amount_residual: total }),
    lines,
    taxes: [{ tax_name: 'VAT 21%', vat_category: 'S', tax_rate: '21.0000', base_amount: untaxed, tax_charged: tax }],
    mentions: englishMentions(),
  };
}

const CRC_TABLE = Array.from({ length: 256 }, (_, n) => {
  let c = n;
  for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
  return c >>> 0;
});

function crc32(bytes: Uint8Array): number {
  let c = 0xffffffff;
  for (const b of bytes) c = (CRC_TABLE[(c ^ b) & 0xff] as number) ^ (c >>> 8);
  return (c ^ 0xffffffff) >>> 0;
}

function chunk(type: string, data: Uint8Array): Buffer {
  const head = Buffer.alloc(8);
  head.writeUInt32BE(data.length, 0);
  head.write(type, 4, 'latin1');
  const body = Buffer.concat([head.subarray(4), Buffer.from(data)]);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(body), 0);
  return Buffer.concat([head.subarray(0, 4), body, crc]);
}

/** A small opaque RGB PNG: a dark square with a lighter band, as a logo would be. */
export function pngLogo(width = 120, height = 40): Uint8Array {
  return png(width, height, false);
}

/**
 * The same logo with an alpha channel: the band is half transparent and the
 * left quarter fully so, as a logo cut out of its background is.
 */
export function pngLogoWithAlpha(width = 120, height = 40): Uint8Array {
  return png(width, height, true);
}

function png(width: number, height: number, alpha: boolean): Uint8Array {
  const channels = alpha ? 4 : 3;
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8; // bit depth
  ihdr[9] = alpha ? 6 : 2; // RGBA or RGB
  const stride = width * channels + 1;
  const raw = Buffer.alloc(stride * height);
  for (let y = 0; y < height; y++) {
    const row = y * stride;
    for (let x = 0; x < width; x++) {
      const band = y > height / 3 && y < (2 * height) / 3;
      const at = row + 1 + x * channels;
      raw[at] = band ? 0x4a : 0x1f;
      raw[at + 1] = band ? 0x90 : 0x3a;
      raw[at + 2] = band ? 0xe2 : 0x5f;
      if (alpha) raw[at + 3] = x < width / 4 ? 0 : band ? 0x80 : 0xff;
    }
  }
  return new Uint8Array(
    Buffer.concat([
      Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
      chunk('IHDR', ihdr),
      chunk('IDAT', deflateSync(raw)),
      chunk('IEND', new Uint8Array(0)),
    ]),
  );
}
