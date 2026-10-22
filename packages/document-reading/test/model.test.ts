import { describe, expect, it } from 'vitest';
import {
  CONFIDENCE_FIELDS,
  LINE_ATTRIBUTES,
  READING_PROMPT,
  makesAmount,
  purchaseDraftOf,
  readingOf,
  readingPrompt,
  readingSchema,
  type ReadingExtension,
} from '../src/index.js';

/** Every object of a schema closed and every property required, as a strict structured output wants. */
function strict(schema: unknown, path = '$'): string[] {
  if (schema === null || typeof schema !== 'object') return [];
  const node = schema as Record<string, unknown>;
  const problems: string[] = [];
  if (node['type'] === 'object') {
    const properties = Object.keys((node['properties'] ?? {}) as object);
    if (node['additionalProperties'] !== false) problems.push(`${path} is open`);
    const required = (node['required'] ?? []) as string[];
    for (const name of properties) if (!required.includes(name)) problems.push(`${path}.${name} is not required`);
    for (const [name, child] of Object.entries((node['properties'] ?? {}) as object)) problems.push(...strict(child, `${path}.${name}`));
  }
  if (node['type'] === 'array') problems.push(...strict(node['items'], `${path}[]`));
  return problems;
}

/** An invented answer of a model, as the schema shapes it: everything empty but what each test fills in. */
function answer(overrides: Record<string, unknown> = {}): Record<string, unknown> {
  const party = { name: '', trade_name: '', vat_id: '', legal_id: '', tax_registration_id: '', address: { lines: [], city: '', postal_code: '', country: '' } };
  return {
    document: 'invoice',
    number: '',
    issue_date: '',
    due_date: '',
    tax_point_date: '',
    currency: '',
    seller: party,
    buyer: party,
    buyer_reference: '',
    order_reference: '',
    contract_reference: '',
    preceding_invoice: '',
    invoicing_period: { start: '', end: '' },
    payment: { iban: '', bic: '', reference: '', terms: '' },
    lines: [],
    taxes: [],
    totals: { line_total: '', tax_exclusive: '', tax_total: '', tax_inclusive: '', prepaid: '', payable: '' },
    confidence: Object.fromEntries(CONFIDENCE_FIELDS.map((field) => [field, 'high'])),
    ...overrides,
  };
}

const line = (overrides: Record<string, unknown>): Record<string, unknown> => ({
  name: '',
  description: '',
  quantity: '',
  unit: '',
  unit_code: '',
  net_price: '',
  net_amount: '',
  vat_category: '',
  vat_rate: '',
  period: { start: '', end: '' },
  confidence: 'high',
  ...overrides,
});

/** An invented supplier of office goods, its invoice complete and adding up. */
const complete = answer({
  number: 'INV-0001',
  issue_date: '2026-09-30',
  due_date: '2026-10-30',
  currency: 'EUR',
  seller: {
    name: 'Fournitures Imaginaires SA',
    trade_name: '',
    vat_id: 'XX 123 456 789',
    legal_id: '0123.456.789',
    tax_registration_id: '',
    address: { lines: ['1 Rue Inventée'], city: 'Nulle-Part', postal_code: '9999', country: 'xx' },
  },
  payment: { iban: 'BE53 9990 0000 0099', bic: 'TESTXXBB', reference: '+++000/0000/00097+++', terms: '30 days' },
  lines: [
    line({ name: 'Paper', quantity: '10', unit: 'pcs', unit_code: 'H87', net_price: '4.50', net_amount: '45.00', vat_category: 'S', vat_rate: '21' }),
    line({ name: 'Delivery', quantity: '1', unit_code: 'C62', net_price: '5', net_amount: '5.00', vat_category: 'S', vat_rate: '21' }),
  ],
  taxes: [{ category: 'S', rate: '21', base: '50.00', tax: '10.50', amount_including_tax: '60.50', exemption_reason: '' }],
  totals: { line_total: '50.00', tax_exclusive: '50.00', tax_total: '10.50', tax_inclusive: '60.50', prepaid: '', payable: '60.50' },
});

describe('readingSchema', () => {
  it('is strict: every object closed, every property required', () => {
    expect(strict(readingSchema())).toEqual([]);
  });

  it('asks a confidence for each field it names, and for each line', () => {
    const schema = readingSchema() as { properties: Record<string, { properties?: Record<string, unknown>; items?: { properties: Record<string, unknown> } }> };
    expect(Object.keys(schema.properties['confidence']?.properties ?? {})).toEqual([...CONFIDENCE_FIELDS]);
    expect(schema.properties['lines']?.items?.properties['confidence']).toBeDefined();
  });

  it('adds an extension under its own key, still strict', () => {
    const extension: ReadingExtension = {
      properties: { meter: { type: 'string', description: 'The meter number.' } },
      instructions: 'The meter is printed near the address of supply.',
    };
    const schema = readingSchema(extension) as { properties: Record<string, unknown> };
    expect(schema.properties['extension']).toEqual({
      type: 'object',
      additionalProperties: false,
      required: ['meter'],
      properties: extension.properties,
    });
    expect(strict(schema)).toEqual([]);
    expect(readingPrompt(extension)).toContain(READING_PROMPT);
    expect(readingPrompt(extension)).toContain('near the address of supply');
    expect(readingPrompt()).toBe(READING_PROMPT);
  });
});

describe('readingOf', () => {
  it('holds a complete answer to the ReceivedInvoice the exact readers return', () => {
    const reading = readingOf(complete);
    expect(reading?.document).toBe('invoice');
    const invoice = reading!.invoice;
    expect(invoice.syntax).toBe('model');
    expect(invoice.number).toBe('INV-0001');
    expect(invoice.currency).toBe('EUR');
    expect(invoice.seller.vatId).toBe('XX123456789');
    expect(invoice.seller.legalId).toEqual({ value: '0123.456.789', scheme: null });
    expect(invoice.seller.address?.country).toBe('XX');
    expect(invoice.lines.map((one) => [one.id, one.quantity, one.unitCode, one.netPrice, one.netAmount, one.vatCategory, one.vatRate])).toEqual([
      ['1', '10', 'H87', '4.50', '45.00', 'S', '21'],
      ['2', '1', 'C62', '5', '5.00', 'S', '21'],
    ]);
    expect(invoice.paymentMeans[0]?.account).toEqual({ kind: 'iban', value: 'BE53999000000099' });
    expect(invoice.totals).toMatchObject({ taxExclusive: '50.00', taxTotal: '10.50', taxInclusive: '60.50', payable: '60.50' });
    expect(reading?.taxInclusiveByGroup).toEqual(['60.50']);
    expect(reading?.missing).toEqual([]);
    expect(reading?.rejected).toEqual([]);
    expect(reading?.violations).toEqual([]);
    expect(reading?.confidence['number']).toBe('high');
    expect(reading?.confidence['lines[1]']).toBe('high');
    expect(reading?.extension).toBeNull();
  });

  it('reports the arithmetic the printed figures break, and keeps the figures', () => {
    const wrong = { ...complete, totals: { ...(complete['totals'] as object), tax_inclusive: '61.50', payable: '61.50' } };
    const reading = readingOf(wrong);
    expect(reading?.invoice.totals.taxInclusive).toBe('61.50');
    expect(reading?.violations.map((one) => one.code)).toContain('BR-CO-15');
  });

  it('leaves empty what the page did not print, names what EN 16931 requires, and computes nothing', () => {
    const receipt = answer({
      document: 'receipt',
      issue_date: '2026-10-01',
      seller: { ...(complete['seller'] as object), vat_id: '' },
      taxes: [{ category: '', rate: '6', base: '', tax: '0.34', amount_including_tax: '6.00', exemption_reason: '' }],
      totals: { line_total: '', tax_exclusive: '', tax_total: '0.34', tax_inclusive: '6.00', prepaid: '', payable: '' },
    });
    const reading = readingOf(receipt);
    expect(reading?.document).toBe('receipt');
    expect(reading?.invoice.kind).toBe('invoice');
    expect(reading?.invoice.currency).toBe('');
    expect(reading?.invoice.number).toBe('');
    expect(reading?.invoice.seller.vatId).toBeNull();
    expect(reading?.invoice.taxes[0]).toMatchObject({ rate: '6', base: '', tax: '0.34', category: null });
    expect(reading?.invoice.totals.taxExclusive).toBe('');
    expect(reading?.missing).toEqual(['taxes[0].base', 'number', 'currency', 'totals.tax_exclusive', 'totals.payable']);
    // Partial figures are not held to the arithmetic: it would only measure what is missing.
    expect(reading?.violations).toEqual([]);
  });

  it('rejects what is not of its shape, by path, and keeps it empty', () => {
    const malformed = answer({
      number: 42,
      issue_date: '30/09/2026',
      due_date: '2026-02-30',
      currency: 'euros',
      seller: { name: ['not', 'a', 'name'], vat_id: null },
      lines: [line({ name: 'Paper', quantity: 'ten', net_amount: '1,234.50', vat_category: 'X', vat_rate: '21 %', unit_code: 'kilowatt hour' }), 'a line'],
      taxes: 'none',
      totals: { tax_exclusive: '45,00', tax_inclusive: 45, payable: '' },
      confidence: { number: 'certain' },
    });
    const reading = readingOf(malformed);
    expect(reading?.rejected).toEqual([
      'lines[0].unit_code',
      'lines[0].quantity',
      'lines[0].net_amount',
      'lines[0].vat_category',
      'lines[0].vat_rate',
      'issue_date',
      'due_date',
      'currency',
    ]);
    // A lone comma is a decimal separator; a comma beside a point is grouping, and rejected above.
    expect(reading?.invoice.totals.taxExclusive).toBe('45.00');
    expect(reading?.invoice.lines).toHaveLength(2);
    expect(reading?.invoice.lines[0]).toMatchObject({ quantity: null, netAmount: '', vatCategory: null, vatRate: null, unitCode: null });
    expect(reading?.invoice.lines[1]).toMatchObject({ name: null, netAmount: '' });
    expect(reading?.invoice.taxes).toEqual([]);
    expect(reading?.invoice.seller.name).toBeNull();
    expect(reading?.missing).toContain('seller.name');
    expect(reading?.missing).toContain('totals.tax_inclusive');
    expect(reading?.confidence['number']).toBeNull();
  });

  it('reads nothing from what is not an answer, or a page that is not a purchase document', () => {
    for (const nothing of [null, undefined, 'text', 12, [], {}, { document: 'menu' }, answer({ document: 'other' })]) {
      expect(readingOf(nothing)).toBeUndefined();
    }
  });

  it('makes a credit note a credit note, with the invoice it corrects', () => {
    const reading = readingOf({ ...complete, document: 'credit_note', preceding_invoice: 'INV-0000' });
    expect(reading?.invoice.kind).toBe('credit_note');
    expect(reading?.invoice.precedingInvoices).toEqual([{ number: 'INV-0000', issueDate: null }]);
    expect(purchaseDraftOf(reading!.invoice).doc_type).toBe('purchase_credit_note');
  });

  it('keeps an account that fails its check digits as an account, not an IBAN', () => {
    const reading = readingOf({ ...complete, payment: { iban: 'BE00 9990 0000 0099', bic: '', reference: '', terms: '' } });
    expect(reading?.invoice.paymentMeans[0]?.account).toEqual({ kind: 'other', value: 'BE00999000000099' });
  });
});

describe('an energy invoice, read with an extension', () => {
  const extension: ReadingExtension = {
    properties: {
      meter: { type: 'string', description: 'The meter number, as printed.' },
      contract_type: { type: 'string', description: 'The contract type, as printed.' },
      bands: {
        type: 'array',
        items: {
          type: 'object',
          additionalProperties: false,
          required: ['band', 'kwh'],
          properties: { band: { type: 'string' }, kwh: { type: 'string' } },
        },
      },
    },
  };
  const printed = answer({
    number: 'EN-2026-09',
    issue_date: '2026-10-05',
    currency: 'EUR',
    seller: { ...(complete['seller'] as object), name: 'Énergie Imaginaire SA' },
    contract_reference: 'CTR-000123',
    invoicing_period: { start: '2026-09-01', end: '2026-09-30' },
    lines: [
      line({ name: 'Energy, peak hours', quantity: '1234', unit: 'kWh', net_price: '0.1834', net_amount: '226.32', vat_category: 'S', vat_rate: '6', period: { start: '2026-09-01', end: '2026-09-30' } }),
      line({ name: 'Energy, off-peak hours', quantity: '987.5', unit: 'kWh', unit_code: 'KWH', net_price: '0.1421', net_amount: '140.32', vat_category: 'S', vat_rate: '6' }),
      line({ name: 'Standing charge', quantity: '30', unit: 'days', net_price: '0.35', net_amount: '10.60', vat_category: 'S', vat_rate: '6' }),
    ],
    taxes: [{ category: 'S', rate: '6', base: '377.24', tax: '22.63', amount_including_tax: '', exemption_reason: '' }],
    totals: { line_total: '377.24', tax_exclusive: '377.24', tax_total: '22.63', tax_inclusive: '399.87', prepaid: '350.00', payable: '49.87' },
    extension: { meter: 'M-0001', contract_type: 'variable', bands: [{ band: 'peak', kwh: '1234' }, { band: 'off-peak', kwh: '987.5' }] },
  });

  it('reads the kWh lines with their unit code and period, and returns the extension untouched', () => {
    const reading = readingOf<{ meter: string; bands: unknown[] }>(printed);
    expect(reading?.invoice.lines.map((one) => one.unitCode)).toEqual(['KWH', 'KWH', 'DAY']);
    expect(reading?.invoice.lines[0]?.period).toEqual({ start: '2026-09-01', end: '2026-09-30' });
    expect(reading?.invoice.lines[1]?.period).toBeNull();
    expect(reading?.invoice.invoicingPeriod).toEqual({ start: '2026-09-01', end: '2026-09-30' });
    expect(reading?.invoice.contractReference).toBe('CTR-000123');
    expect(reading?.invoice.totals.prepaid).toBe('350.00');
    expect(reading?.extension).toBe(printed['extension']);
    expect(reading?.violations).toEqual([]);
  });

  it('keeps the unit code and the periods in the purchase draft', () => {
    const draft = purchaseDraftOf(readingOf(printed)!.invoice);
    expect(draft.invoicing_period).toEqual({ start: '2026-09-01', end: '2026-09-30' });
    expect(draft.contract_reference).toBe('CTR-000123');
    expect(draft.payable).toBe('49.87');
    // 1234 × 0.1834 = 226.3156, which the line's amount rounds at two decimals: the kWh stay.
    expect(draft.lines[0]).toMatchObject({ quantity: '1234', unit_code: 'KWH', unit_price: '0.1834' });
    expect(draft.lines[0]?.attributes).toEqual({ [LINE_ATTRIBUTES.periodStart]: '2026-09-01', [LINE_ATTRIBUTES.periodEnd]: '2026-09-30' });
    // A line without a period of its own takes the invoice's.
    expect(draft.lines[1]?.attributes[LINE_ATTRIBUTES.periodStart]).toBe('2026-09-01');
    // 30 × 0.35 = 10.50, not the 10.60 printed: one unit at the amount, the invoice's figures kept beside it.
    expect(draft.lines[2]).toMatchObject({ quantity: '1', unit_code: 'C62', unit_price: '10.60' });
    expect(draft.lines[2]?.attributes).toMatchObject({
      [LINE_ATTRIBUTES.invoicedQuantity]: '30',
      [LINE_ATTRIBUTES.invoicedUnitCode]: 'DAY',
      [LINE_ATTRIBUTES.invoicedNetPrice]: '0.35',
    });
  });
});

describe('an invoice in a currency without decimals', () => {
  const printed = answer({
    number: 'JP-77',
    issue_date: '2026-10-10',
    currency: 'jpy',
    lines: [line({ name: 'Cables', quantity: '3', unit_code: 'H87', net_price: '1333.4', net_amount: '4000', vat_category: 'S', vat_rate: '10' })],
    taxes: [{ category: 'S', rate: '10', base: '4000', tax: '400', amount_including_tax: '4400', exemption_reason: '' }],
    totals: { line_total: '4000', tax_exclusive: '4000', tax_total: '400', tax_inclusive: '4400', prepaid: '', payable: '4400' },
  });

  it('keeps the currency printed, and compares a line at its decimals', () => {
    const reading = readingOf(printed);
    expect(reading?.invoice.currency).toBe('JPY');
    const draft = purchaseDraftOf(reading!.invoice);
    expect(draft.currency_code).toBe('JPY');
    expect(draft.lines[0]).toMatchObject({ quantity: '3', unit_code: 'H87', unit_price: '1333.4' });
  });

  it('never assumes a currency that was not printed', () => {
    const lines = [{ ...(printed['lines'] as Record<string, unknown>[])[0], net_amount: '4000.00' }];
    const draft = purchaseDraftOf(readingOf({ ...printed, currency: '', lines })!.invoice);
    expect(draft.currency_code).toBeNull();
    // Without a currency the amount is compared at the decimals it is written with: 4000.20 is not 4000.00.
    expect(draft.lines[0]).toMatchObject({ quantity: '1', unit_code: 'C62', unit_price: '4000.00' });
  });
});

describe('makesAmount', () => {
  it('rounds half up on the absolute value, at the decimals given', () => {
    expect(makesAmount('3', '0.335', '1.01', 2)).toBe(true);
    expect(makesAmount('-3', '0.335', '-1.01', 2)).toBe(true);
    expect(makesAmount('3', '0.335', '1.00', 2)).toBe(false);
    expect(makesAmount('3', '1333.4', '4000', 0)).toBe(true);
    expect(makesAmount('3', '1333.4', '4000.00', 0)).toBe(true);
    expect(makesAmount('3', '1333.4', '4000.20', 0)).toBe(false);
    expect(makesAmount('ten', '1', '10', 2)).toBe(false);
  });
});
