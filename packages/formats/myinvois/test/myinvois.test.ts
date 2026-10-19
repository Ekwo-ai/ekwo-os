import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { MYINVOIS, MyInvoisError, type MyInvoisInput, type Row } from '../src/index.js';
import { INVOICE, LINES, PURCHASE, SALES_TAX, V1_UUID, creditNote, invoice, selfBilled } from './fixtures.js';

const fixtures = join(dirname(fileURLToPath(import.meta.url)), 'fixtures');

/** The document of a JSON file: the one `Invoice` under the namespaces. */
function documentOf(input: MyInvoisInput): Record<string, any> {
  return JSON.parse(MYINVOIS.write(input).content).Invoice[0];
}

/** The `_` of the first value at a path of JSON names. */
function at(node: any, ...path: string[]): unknown {
  let current = node;
  for (const name of path) current = current?.[name]?.[0];
  return current?._;
}

describe('an invoice of the Malaysian golden year', () => {
  it('is written as the books hold it, and breaks no rule', () => {
    const written = MYINVOIS.write(invoice());
    expect(written.violations).toEqual([]);
    expect(written.content).toBe(readFileSync(join(fixtures, 'invoice.json'), 'utf8'));
    expect(written).toMatchObject({
      filename: 'myinvois-01-INV-2026-0001.json',
      mediaType: 'application/json',
      syntax: 'json',
      typeCode: '01',
      version: '1.0',
      requiresSignature: false,
    });
  });

  it('is the same document in XML', () => {
    const written = MYINVOIS.write(invoice(), 'xml');
    expect(written.violations).toEqual([]);
    expect(written.content).toBe(readFileSync(join(fixtures, 'invoice.xml'), 'utf8'));
    expect(written.filename).toBe('myinvois-01-INV-2026-0001.xml');
    expect(written.mediaType).toBe('application/xml');
  });

  it('writes every amount as its digits, never through a float', () => {
    const content = MYINVOIS.write(
      invoice({
        header: { ...INVOICE, amount_untaxed: '0.10', amount_tax: '0.01', amount_total: '0.11' },
        lines: [{ ...(LINES[1] as Row), quantity: '1', unit_price: '0.10', amount_untaxed: '0.10' }],
        taxes: [{ tax_code: 'MY-S-STD', vat_category: 'S', tax_rate: '10', base_amount: '0.10', tax_charged: '0.01', myinvois_tax_type: '01' }],
      }),
    ).content;
    expect(content).toContain('{ "_": 0.11, "currencyID": "MYR" }');
    expect(content).toContain('{ "_": 0.01, "currencyID": "MYR" }');
  });

  it('issues it at a moment in UTC, which is not always the day of the books in Malaysia', () => {
    const early = documentOf(invoice({ issuedAt: '2026-01-15T07:00:00+08:00' }));
    expect(at(early, 'IssueDate')).toBe('2026-01-14');
    expect(at(early, 'IssueTime')).toBe('23:00:00Z');
  });

  it('declares the version it is given, and a 1.1 document waits for its signature', () => {
    const written = MYINVOIS.write(invoice({ version: '1.1' }));
    expect(written.requiresSignature).toBe(true);
    expect(JSON.parse(written.content).Invoice[0].InvoiceTypeCode[0]).toEqual({ _: '01', listVersionID: '1.1' });
    expect(written.content).not.toContain('Signature');
    expect(written.content).not.toContain('UBLExtensions');
  });

  it('writes version 1.1 when no version is asked for', () => {
    const { version: _, ...unstated } = invoice();
    const written = MYINVOIS.write(unstated);
    expect(written.version).toBe('1.1');
    expect(written.requiresSignature).toBe(true);
    expect(JSON.parse(written.content).Invoice[0].InvoiceTypeCode[0]).toEqual({ _: '01', listVersionID: '1.1' });
  });

  it('reads a state by its name in LHDNM list, and keeps a code as it is', () => {
    const document = documentOf(invoice());
    expect(at(document.AccountingSupplierParty[0].Party[0], 'PostalAddress', 'CountrySubentityCode')).toBe('14');
    expect(at(document.AccountingCustomerParty[0].Party[0], 'PostalAddress', 'CountrySubentityCode')).toBe('10');
  });

  it('writes the buyer SST number as NA where none is given, and never a tourism tax number for the buyer', () => {
    const buyer = documentOf(invoice()).AccountingCustomerParty[0].Party[0];
    expect(buyer.PartyIdentification.map((each: any) => each.ID[0])).toEqual([
      { _: 'C20000000020', schemeID: 'TIN' },
      { _: '202601000002', schemeID: 'BRN' },
      { _: 'NA', schemeID: 'SST' },
    ]);
  });

  it('writes a foreign buyer with its three-letter country and state 17 where it names none', () => {
    const header = { ...INVOICE, buyer_country: 'SG', buyer_region: null, buyer_postal_code: '018989', buyer_city: 'Singapore' };
    const written = MYINVOIS.write(invoice({ header }));
    expect(written.violations).toEqual([]);
    const address = JSON.parse(written.content).Invoice[0].AccountingCustomerParty[0].Party[0].PostalAddress[0];
    expect(at(address, 'Country', 'IdentificationCode')).toBe('SGP');
    expect(at(address, 'CountrySubentityCode')).toBe('17');
  });

  it('writes a discount as its rate and the amount between the subtotal and the net', () => {
    const line = { ...(LINES[1] as Row), discount_percent: '15.00', amount_untaxed: '1700.00' };
    const written = MYINVOIS.write(
      invoice({
        header: { ...INVOICE, amount_untaxed: '1700.00', amount_tax: '170.00', amount_total: '1870.00' },
        lines: [line],
        taxes: [{ tax_code: 'MY-S-STD', vat_category: 'S', tax_rate: '10.0000', base_amount: '1700.00', tax_charged: '170.00', myinvois_tax_type: '01' }],
      }),
    );
    expect(written.violations).toEqual([]);
    const written_line = JSON.parse(written.content).Invoice[0].InvoiceLine[0];
    expect(written_line.AllowanceCharge[0]).toEqual({
      ChargeIndicator: [{ _: false }],
      MultiplierFactorNumeric: [{ _: 0.15 }],
      Amount: [{ _: 300, currencyID: 'MYR' }],
    });
    expect(at(written_line, 'ItemPriceExtension', 'Amount')).toBe(2000);
    expect(at(written_line, 'LineExtensionAmount')).toBe(1700);
  });

  it('writes the exchange rate of a document in another currency, every amount in that currency', () => {
    const written = MYINVOIS.write(invoice({ header: { ...INVOICE, currency_code: 'USD' }, exchangeRate: '4.72' }));
    expect(written.violations).toEqual([]);
    const document = JSON.parse(written.content).Invoice[0];
    expect(document.TaxExchangeRate[0]).toEqual({
      SourceCurrencyCode: [{ _: 'USD' }],
      TargetCurrencyCode: [{ _: 'MYR' }],
      CalculationRate: [{ _: 4.72 }],
    });
    expect(document.TaxCurrencyCode).toBeUndefined();
    expect(written.content).not.toContain('"currencyID": "MYR"');
  });

  it('writes the tax of a document in another currency in ringgit where the books give it, as the foreign currency sample does', () => {
    const taxes = [{ ...SALES_TAX, base_amount: '2000.00', tax_charged: '200.00', tax_charged_in_tax_currency: '944.00' }];
    const written = MYINVOIS.write(
      invoice({ header: { ...INVOICE, currency_code: 'USD' }, exchangeRate: '4.72', taxCurrency: 'MYR', taxes }),
    );
    expect(written.violations).toEqual([]);
    const document = JSON.parse(written.content).Invoice[0];
    expect(document.DocumentCurrencyCode).toEqual([{ _: 'USD' }]);
    expect(document.TaxCurrencyCode).toEqual([{ _: 'MYR' }]);
    expect(document.TaxTotal[0].TaxAmount).toEqual([{ _: 944, currencyID: 'MYR' }]);
    expect(document.TaxTotal[0].TaxSubtotal[0].TaxableAmount).toEqual([{ _: 2000, currencyID: 'USD' }]);
    expect(document.TaxTotal[0].TaxSubtotal[0].TaxAmount).toEqual([{ _: 944, currencyID: 'MYR' }]);
    const line = document.InvoiceLine[0];
    expect(line.TaxTotal[0].TaxAmount).toEqual([{ _: 944, currencyID: 'MYR' }]);
    expect(line.LineExtensionAmount).toEqual([{ _: 2000, currencyID: 'USD' }]);
    expect(document.LegalMonetaryTotal[0].PayableAmount).toEqual([{ _: 2200, currencyID: 'USD' }]);
  });

  it('writes the tax in the document currency, and says why, where the books hold none in ringgit or a line shares its tax', () => {
    const header = { ...INVOICE, currency_code: 'USD' };
    const missing = MYINVOIS.write(invoice({ header, exchangeRate: '4.72', taxCurrency: 'MYR' }));
    expect(missing.violations.map((each) => each.code)).toEqual(['input:tax_in_tax_currency']);
    expect(JSON.parse(missing.content).Invoice[0].TaxCurrencyCode).toBeUndefined();

    const other = MYINVOIS.write(invoice({ header, exchangeRate: '4.72', taxCurrency: 'EUR' }));
    expect(other.violations.map((each) => each.code)).toEqual(['input:tax_currency']);

    const shared = [
      { ...(LINES[1] as Row), sequence: 2, amount_untaxed: '1000.00', quantity: '10.0000' },
      { ...(LINES[1] as Row), sequence: 3, amount_untaxed: '1000.00', quantity: '10.0000' },
    ];
    const split = MYINVOIS.write(
      invoice({ header, lines: shared, exchangeRate: '4.72', taxCurrency: 'MYR', taxes: [{ ...SALES_TAX, tax_charged_in_tax_currency: '944.00' }] }),
    );
    expect(split.violations.map((each) => each.code)).toEqual(['input:line_tax_in_tax_currency', 'input:line_tax_in_tax_currency']);
  });

  it('writes a payment mode with the account to pay into', () => {
    const document = documentOf(invoice({ header: { ...INVOICE, payee_iban: '1234567890123' }, paymentMode: '03' }));
    expect(document.PaymentMeans[0]).toEqual({
      PaymentMeansCode: [{ _: '03' }],
      PayeeFinancialAccount: [{ ID: [{ _: '1234567890123' }] }],
    });
  });
});

describe('the eight documents of LHDNM', () => {
  it('writes a credit note as 02, naming the invoice it adjusts by its number and UUID', () => {
    const written = MYINVOIS.write(creditNote());
    expect(written.violations).toEqual([]);
    expect(written.typeCode).toBe('02');
    const document = JSON.parse(written.content).Invoice[0];
    expect(document.BillingReference).toEqual([
      { InvoiceDocumentReference: [{ ID: [{ _: 'INV-2026-0001' }], UUID: [{ _: V1_UUID }] }] },
    ]);
    // The figures of a credit note are positive, as the books hold them.
    expect(at(document, 'LegalMonetaryTotal', 'PayableAmount')).toBe(220);
  });

  it.each([
    ['sale_invoice', 'invoice', '01'],
    ['sale_invoice', 'debit-note', '03'],
    ['sale_credit_note', 'credit-note', '02'],
    ['sale_credit_note', 'refund-note', '04'],
    ['purchase_invoice', 'invoice', '11'],
    ['purchase_invoice', 'debit-note', '13'],
    ['purchase_credit_note', 'credit-note', '12'],
    ['purchase_credit_note', 'refund-note', '14'],
  ] as const)('writes a %s as a %s, %s', (docType, kind, code) => {
    const base = docType.startsWith('purchase') ? selfBilled() : invoice();
    const written = MYINVOIS.write({
      ...base,
      header: { ...base.header, doc_type: docType },
      kind,
      adjusts: kind === 'invoice' ? [] : [{ number: 'X-1', uuid: V1_UUID }],
    });
    expect(written.typeCode).toBe(code);
    expect(written.violations).toEqual([]);
    expect(at(JSON.parse(written.content).Invoice[0], 'InvoiceTypeCode')).toBe(code);
  });

  it('refuses a kind the books cannot be', () => {
    expect(() => MYINVOIS.write(invoice({ kind: 'credit-note' }))).toThrow(MyInvoisError);
    expect(() => MYINVOIS.write(creditNote({ kind: 'debit-note' }))).toThrow(/sale_credit_note cannot be written as a debit-note/);
  });

  it('puts the company of a self-billed purchase in the buyer place, and its supplier in the supplier place', () => {
    const written = MYINVOIS.write(selfBilled());
    expect(written.violations).toEqual([]);
    expect(written.typeCode).toBe('11');
    const document = JSON.parse(written.content).Invoice[0];
    const supplier = document.AccountingSupplierParty[0].Party[0];
    const buyer = document.AccountingCustomerParty[0].Party[0];
    expect(at(supplier, 'PartyLegalEntity', 'RegistrationName')).toBe(PURCHASE['buyer_name']);
    expect(supplier.IndustryClassificationCode[0]).toEqual({ _: '16230', name: 'Manufacture of wooden containers' });
    expect(supplier.PartyIdentification.map((each: any) => each.ID[0].schemeID)).toEqual(['TIN', 'NRIC', 'SST', 'TTX']);
    expect(at(supplier, 'PostalAddress', 'CountrySubentityCode')).toBe('01');
    expect(at(buyer, 'PartyLegalEntity', 'RegistrationName')).toBe(PURCHASE['seller_legal_name']);
    expect(at(buyer, 'Contact', 'Telephone')).toBe(PURCHASE['seller_phone']);
    expect(buyer.IndustryClassificationCode).toBeUndefined();
  });
});

describe('what makes a document absurd', () => {
  it('throws, rather than writes', () => {
    expect(() => MYINVOIS.write(invoice({ header: { ...INVOICE, doc_type: 'sale_quote' } }))).toThrow(/sale_quote is not a document MyInvois carries/);
    expect(() => MYINVOIS.write(invoice({ header: { ...INVOICE, number: null } }))).toThrow(/never issued/);
    expect(() => MYINVOIS.write(invoice({ header: { ...INVOICE, currency_code: '' } }))).toThrow(/no currency/);
    expect(() => MYINVOIS.write(invoice({ header: { ...INVOICE, amount_total: '2,200.00' } }))).toThrow(/not an amount/);
    expect(() => MYINVOIS.write(invoice({ lines: [LINES[0] as Row] }))).toThrow(/no line/);
    expect(() => MYINVOIS.write(invoice({ issuedAt: '2026-01-15 10:30' }))).toThrow(/ISO 8601 with an offset/);
    expect(() => MYINVOIS.write(invoice({ issuedAt: '2026-02-30T10:30:00Z' }))).toThrow(/not a day/);
    expect(() => MYINVOIS.write(invoice({ version: '2.0' as '1.0' }))).toThrow(/1.0 or 1.1/);
    expect(() => MYINVOIS.write(invoice(), 'csv' as 'json')).toThrow(MyInvoisError);
  });
});
