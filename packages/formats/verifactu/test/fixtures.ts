import type { FiscalRecordInput, InvoicingSystem, Row } from '../src/index.js';

/**
 * A Spanish company and its books, as the three views publish them.
 *
 * `89890001K` is the NIF the AEAT uses in every example of its documents —
 * the fingerprint and the QR code alike — so the golden vectors and the
 * scenarios below read the same issuer.
 */

export const SYSTEM: InvoicingSystem = {
  name: 'Ekwo OS',
  id: 'EK',
  version: '0.13.0',
  installation: 'test-installation-1',
  producerName: 'EKWO OÜ',
  producerTaxId: 'EE102000000',
  verifactuOnly: true,
  multipleTaxpayers: true,
  multipleTaxpayersNow: false,
};

export const SELLER: Row = {
  seller_name: 'Ejemplo',
  seller_legal_name: 'Empresa Ejemplo SL',
  seller_vat_number: 'ES89890001K',
};

/** A sale of 1,000.00 at 21 %, to a Spanish company. */
export const INVOICE: Row = {
  ...SELLER,
  doc_type: 'sale_invoice',
  number: 'F2026-0001',
  document_date: '2026-03-02',
  tax_point_date: null,
  delivery_date: null,
  currency_code: 'EUR',
  amount_untaxed: '1000.00',
  amount_tax: '210.00',
  amount_total: '1210.00',
  note: null,
  buyer_name: 'Cliente Ejemplo SA',
  buyer_vat_number: 'B12345678',
  buyer_country: 'ES',
};

export const LINES: Row[] = [
  { sequence: 1, line_type: 'section', item_name: 'Services' },
  { sequence: 2, line_type: 'product', item_name: 'Consulting, March' },
];

export const STANDARD: Row = {
  tax_code: 'ES-S-21',
  vat_category: 'S',
  tax_rate: '21.0000',
  base_amount: '1000.00',
  tax_charged: '210.00',
  exemption_code: null,
  exemption_reason: null,
};

export function alta(overrides: Partial<FiscalRecordInput> = {}): FiscalRecordInput {
  return {
    header: INVOICE,
    lines: LINES,
    taxes: [STANDARD],
    kind: 'alta',
    generatedAt: '2026-03-02T10:15:00+01:00',
    system: SYSTEM,
    previous: null,
    ...overrides,
  };
}

/** One tax, its base and its tax, with the header's totals made to match. */
export function withTax(tax: Row, header: Row = INVOICE): FiscalRecordInput {
  const base = String(tax['base_amount']);
  const charged = String(tax['tax_charged']);
  const total = (Number(base) + Number(charged)).toFixed(2);
  return alta({
    header: { ...header, amount_untaxed: base, amount_tax: charged, amount_total: total },
    taxes: [tax],
  });
}

export const CREDIT_NOTE: Row = {
  ...INVOICE,
  doc_type: 'sale_credit_note',
  number: 'AB2026-0001',
  document_date: '2026-03-20',
  amount_untaxed: '200.00',
  amount_tax: '42.00',
  amount_total: '242.00',
  rectification_type: 'R1',
  rectified_number: 'F2026-0001',
  rectified_date: '2026-03-02',
};
