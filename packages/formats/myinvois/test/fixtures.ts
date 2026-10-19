import type { MyInvoisInput, PartyIdentifiers, Row, SupplierActivity } from '../src/index.js';

/**
 * A Malaysian company and its books, as the three views publish them.
 *
 * The documents are the first of the golden year of the Malaysian pack
 * (`packs/my/golden/scenario.json`): V1, steel fittings at the 10 % Sales
 * Tax (`MY-S-STD`), and V3, consultancy at the 8 % Service Tax
 * (`MY-SVT-STD`). Every name, number and identifier is fictional.
 *
 * Two columns are not in the views and are given here as the pack would
 * give them: `myinvois_tax_type` on each tax — `01` Sales Tax for a Sales
 * Tax code of the pack, `02` Service Tax for a Service Tax code, which is
 * what the name of each tax says — and `myinvois_classification` on each
 * line, `022` (Others) from LHDNM's list.
 */

export const COMPANY: Row = {
  seller_name: 'Syarikat Contoh',
  seller_legal_name: 'Syarikat Contoh Sdn. Bhd.',
  seller_registration_number: '202601000001',
  seller_address_line1: 'Lot 1, Jalan Contoh',
  seller_address_line2: 'Taman Contoh',
  seller_postal_code: '50480',
  seller_city: 'Kuala Lumpur',
  seller_country: 'MY',
  seller_region: 'Wilayah Persekutuan Kuala Lumpur',
  seller_email: 'accounts@contoh.example',
  seller_phone: '+60300000001',
};

export const CUSTOMER: Row = {
  buyer_name: 'Menara Bintang Trading Sdn. Bhd.',
  buyer_registration_number: '202601000002',
  buyer_address_line1: 'No. 2, Jalan Bintang',
  buyer_postal_code: '40000',
  buyer_city: 'Shah Alam',
  buyer_country: 'MY',
  buyer_region: '10',
  buyer_email: 'finance@bintang.example',
};

export const ACTIVITY: SupplierActivity = { msic: '46510', description: 'Wholesale of computer hardware, software and peripherals' };

export const SUPPLIER: PartyIdentifiers & { activity: SupplierActivity } = {
  tin: 'C10000000010',
  sst: 'W10-0000-00000001',
  tourismTax: 'NA',
  activity: ACTIVITY,
};

export const BUYER: PartyIdentifiers = { tin: 'C20000000020', phone: '+60300000002' };

/** V1: twenty steel fittings at 100.00, Sales Tax at 10 %. */
export const INVOICE: Row = {
  ...COMPANY,
  ...CUSTOMER,
  doc_type: 'sale_invoice',
  number: 'INV-2026-0001',
  currency_code: 'MYR',
  amount_untaxed: '2000.00',
  amount_tax: '200.00',
  amount_total: '2200.00',
  payment_terms: 'Thirty days from the date of the invoice',
};

export const LINES: Row[] = [
  { sequence: 1, line_type: 'section', item_name: 'Goods' },
  {
    sequence: 2,
    line_type: 'product',
    item_name: 'Steel fittings',
    quantity: '20.0000',
    unit_code: 'C62',
    unit_price: '100.0000',
    discount_percent: '0',
    unit_price_includes_tax: false,
    amount_untaxed: '2000.00',
    vat_category: 'S',
    vat_rate: '10.0000',
    myinvois_classification: '022',
  },
];

export const SALES_TAX: Row = {
  tax_code: 'MY-S-STD',
  vat_category: 'S',
  tax_rate: '10.0000',
  base_amount: '2000.00',
  tax_charged: '200.00',
  exemption_reason: null,
  myinvois_tax_type: '01',
};

export const SERVICE_TAX: Row = {
  tax_code: 'MY-SVT-STD',
  vat_category: 'S',
  tax_rate: '8.0000',
  base_amount: '5000.00',
  tax_charged: '400.00',
  exemption_reason: null,
  myinvois_tax_type: '02',
};

export function invoice(overrides: Partial<MyInvoisInput> = {}): MyInvoisInput {
  return {
    header: INVOICE,
    lines: LINES,
    taxes: [SALES_TAX],
    version: '1.0',
    issuedAt: '2026-01-15T10:30:00+08:00',
    supplier: SUPPLIER,
    buyer: BUYER,
    ...overrides,
  };
}

/** A credit note of 200.00 on V1: two fittings returned. */
export const CREDIT_NOTE: Row = {
  ...INVOICE,
  doc_type: 'sale_credit_note',
  number: 'CN-2026-0001',
  amount_untaxed: '200.00',
  amount_tax: '20.00',
  amount_total: '220.00',
};

export const CREDIT_LINES: Row[] = [{ ...(LINES[1] as Row), quantity: '2.0000', amount_untaxed: '200.00' }];

export const CREDIT_TAX: Row = { ...SALES_TAX, base_amount: '200.00', tax_charged: '20.00' };

/** The Unique Identifier Number of V1, as LHDNM would have returned it: 26 characters. */
export const V1_UUID = 'F9D425P6DS7D8IU9EZ0FTK1A10';

export function creditNote(overrides: Partial<MyInvoisInput> = {}): MyInvoisInput {
  return invoice({
    header: CREDIT_NOTE,
    lines: CREDIT_LINES,
    taxes: [CREDIT_TAX],
    issuedAt: '2026-02-03T09:00:00+08:00',
    adjusts: [{ number: 'INV-2026-0001', uuid: V1_UUID }],
    ...overrides,
  });
}

/**
 * A purchase from a supplier that does not issue e-invoices, which the
 * company bills itself: the company is `seller_*` in the row and the buyer
 * in the document.
 */
export const PURCHASE: Row = {
  ...COMPANY,
  doc_type: 'purchase_invoice',
  number: 'SB-2026-0001',
  currency_code: 'MYR',
  amount_untaxed: '750.00',
  amount_tax: '0.00',
  amount_total: '750.00',
  buyer_name: 'Pembekal Kecil Enterprise',
  buyer_registration_number: '202601000003',
  buyer_address_line1: 'No. 3, Lorong Kecil',
  buyer_postal_code: '80000',
  buyer_city: 'Johor Bahru',
  buyer_country: 'MY',
  buyer_region: 'Johor',
};

export const PURCHASE_LINES: Row[] = [
  {
    sequence: 1,
    line_type: 'product',
    item_name: 'Hand-made crates',
    quantity: '15',
    unit_code: 'C62',
    unit_price: '50.00',
    amount_untaxed: '750.00',
    vat_category: 'O',
    vat_rate: '0',
    myinvois_classification: '022',
  },
];

export const NOT_APPLICABLE: Row = {
  tax_code: 'MY-P-EXEMPT',
  vat_category: 'O',
  tax_rate: '0',
  base_amount: '750.00',
  tax_charged: '0.00',
  myinvois_tax_type: '06',
};

export function selfBilled(overrides: Partial<MyInvoisInput> = {}): MyInvoisInput {
  return {
    header: PURCHASE,
    lines: PURCHASE_LINES,
    taxes: [NOT_APPLICABLE],
    version: '1.0',
    issuedAt: '2026-03-01T08:00:00+08:00',
    supplier: { tin: 'IG30000000030', registration: { scheme: 'NRIC', id: '800101010001' }, sst: 'NA', tourismTax: 'NA', phone: '+60700000003', activity: { msic: '16230', description: 'Manufacture of wooden containers' } },
    buyer: { tin: 'C10000000010', sst: 'W10-0000-00000001' },
    ...overrides,
  };
}
