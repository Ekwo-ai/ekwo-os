import { describe, expect, it } from 'vitest';
import { MYINVOIS, type MyInvoisInput, type Row } from '../src/index.js';
import { BUYER, INVOICE, LINES, SALES_TAX, SERVICE_TAX, SUPPLIER, creditNote, invoice } from './fixtures.js';

const codes = (input: MyInvoisInput): string[] => MYINVOIS.write(input).violations.map((each) => each.code);

/** Two lines of goods and one of services, as V1 and V3 of the golden year would be on one invoice. */
function mixed(lines: Row[], taxes: Row[], header: Row = {}): MyInvoisInput {
  return invoice({ header: { ...INVOICE, ...header }, lines, taxes });
}

const goods = (sequence: number, net: string, extra: Row = {}): Row => ({
  ...(LINES[1] as Row),
  sequence,
  quantity: '1',
  unit_price: net,
  amount_untaxed: net,
  ...extra,
});

describe('what the books do not hold, and the caller gives', () => {
  it('names each identifier MyInvois requires of the parties', () => {
    expect(codes(invoice({ supplier: {}, buyer: {} }))).toEqual([
      'input:supplier_tin',
      'input:supplier_sst',
      'input:supplier_tourism_tax',
      'input:supplier_msic',
      'input:buyer_tin',
      'required:AccountingCustomerParty/Telephone',
    ]);
  });

  it('names a line with no LHDNM tax type and no classification', () => {
    const line = { ...(LINES[1] as Row), myinvois_classification: null };
    const tax = { ...SALES_TAX, myinvois_tax_type: null };
    const violations = MYINVOIS.write(invoice({ lines: [line], taxes: [tax] })).violations;
    expect(violations.map((each) => [each.code, each.line])).toEqual([
      ['input:tax_type', '2'],
      ['input:classification', '2'],
    ]);
    expect(violations[0]?.message).toContain('MY-S-STD');
  });

  it('takes the tax type of the line where its tax row does not carry one', () => {
    const line = { ...(LINES[1] as Row), myinvois_tax_type: '01' };
    const tax = { ...SALES_TAX, myinvois_tax_type: null };
    expect(codes(invoice({ lines: [line], taxes: [tax] }))).toEqual([]);
  });

  it('names a note that does not say which document it adjusts', () => {
    expect(codes(creditNote({ adjusts: [] }))).toEqual(['input:adjusts']);
    expect(codes(creditNote({ adjusts: [{ number: 'INV-2026-0001', uuid: '' }] }))).toEqual(['required:InvoiceDocumentReference/UUID']);
  });

  it('names a document in another currency without its rate to the ringgit', () => {
    expect(codes(invoice({ header: { ...INVOICE, currency_code: 'USD' } }))).toEqual(['input:exchange_rate']);
  });

  it('writes no account without a payment mode, and says so', () => {
    const written = MYINVOIS.write(invoice({ header: { ...INVOICE, payee_iban: '1234567890123' } }));
    expect(written.violations.map((each) => each.code)).toEqual(['input:payment_mode']);
    expect(written.content).not.toContain('1234567890123');
  });

  it('names a price keyed with its tax that the books give no net price for', () => {
    const line = { ...(LINES[1] as Row), unit_price_includes_tax: true, unit_price: '110.00' };
    expect(codes(invoice({ lines: [line] }))).toEqual([
      'input:net_unit_price',
      'required:Price/PriceAmount',
      'required:ItemPriceExtension/Amount',
    ]);
    expect(codes(invoice({ lines: [{ ...line, net_unit_price: '100.00' }] }))).toEqual([]);
  });

  it('names a country with no three-letter code in LHDNM list', () => {
    expect(codes(invoice({ header: { ...INVOICE, buyer_country: 'TW', buyer_region: 'Taipei' } }))).toEqual([
      'input:buyer_country',
      'required:AccountingCustomerParty/Country',
    ]);
  });
});

describe('the tax of a line', () => {
  it('is the tax of its row where the line is alone under it', () => {
    const lines = [goods(1, '2000.00'), goods(2, '5000.00', { vat_rate: '8.0000' })];
    const taxes = [SALES_TAX, SERVICE_TAX];
    const header = { amount_untaxed: '7000.00', amount_tax: '600.00', amount_total: '7600.00' };
    const written = MYINVOIS.write(mixed(lines, taxes, header));
    expect(written.violations).toEqual([]);
    const document = JSON.parse(written.content).Invoice[0];
    expect(document.InvoiceLine.map((line: any) => line.TaxTotal[0].TaxAmount[0]._)).toEqual([200, 400]);
    expect(document.TaxTotal[0].TaxSubtotal.map((each: any) => [each.TaxCategory[0].ID[0]._, each.TaxAmount[0]._])).toEqual([
      ['01', 200],
      ['02', 400],
    ]);
  });

  it('is base times rate where that is exact for every line of the row and adds up to it', () => {
    const lines = [goods(1, '1234.50'), goods(2, '765.50')];
    const tax = { ...SALES_TAX, base_amount: '2000.00', tax_charged: '200.00' };
    const written = MYINVOIS.write(mixed(lines, [tax]));
    expect(written.violations).toEqual([]);
    expect(JSON.parse(written.content).Invoice[0].InvoiceLine.map((line: any) => line.TaxTotal[0].TaxAmount[0]._)).toEqual([123.45, 76.55]);
  });

  it('is not invented where the row rounded the tax of several lines once', () => {
    const lines = [goods(1, '0.05'), goods(2, '0.05')];
    const tax = { ...SALES_TAX, base_amount: '0.10', tax_charged: '0.01' };
    const header = { amount_untaxed: '0.10', amount_tax: '0.01', amount_total: '0.11' };
    const violations = MYINVOIS.write(mixed(lines, [tax], header)).violations;
    expect(violations.map((each) => [each.code, each.line])).toEqual([
      ['input:line_tax_amount', '1'],
      ['input:line_tax_amount', '2'],
    ]);
  });

  it('is read from the line where the row gives it', () => {
    const lines = [goods(1, '0.05', { tax_amount: '0.01' }), goods(2, '0.05', { tax_amount: '0.00' })];
    const tax = { ...SALES_TAX, base_amount: '0.10', tax_charged: '0.01' };
    const header = { amount_untaxed: '0.10', amount_tax: '0.01', amount_total: '0.11' };
    expect(codes(mixed(lines, [tax], header))).toEqual([]);
  });

  it('finds its row by code before category and rate', () => {
    const other = { ...SALES_TAX, tax_code: 'MY-S-OTHER', myinvois_tax_type: '05' };
    const line = { ...(LINES[1] as Row), tax_code: 'MY-S-STD' };
    // Two rows at 10 % in category S: only the code tells them apart.
    const lines = [line];
    const violations = MYINVOIS.write(mixed(lines, [SALES_TAX, { ...other, base_amount: '0.00', tax_charged: '0.00' }])).violations;
    expect(violations.map((each) => each.code)).toEqual([]);
  });
});

describe('the mathematical mappings', () => {
  it('names a total including tax that is not the total excluding tax plus the tax', () => {
    expect(codes(invoice({ header: { ...INVOICE, amount_total: '2200.01' } }))).toEqual(['math:TaxInclusiveAmount']);
  });

  it('names a total tax that is not the sum of the tax types', () => {
    expect(codes(invoice({ header: { ...INVOICE, amount_tax: '199.99', amount_total: '2199.99' } }))).toEqual(['math:TaxTotal/TaxAmount']);
  });

  it('names a line whose net is not its price times its quantity', () => {
    const line = { ...(LINES[1] as Row), unit_price: '99.99' };
    const violations = MYINVOIS.write(invoice({ lines: [line] })).violations;
    expect(violations.map((each) => [each.code, each.line])).toEqual([['math:InvoiceLine/LineExtensionAmount', '2']]);
    expect(violations[0]?.message).toBe('Total Excluding Tax of the line is 2000.00, and the figures it is the sum of make 1999.80.');
  });

  it('names a tax type whose base is not the sum of its lines', () => {
    expect(codes(invoice({ taxes: [{ ...SALES_TAX, base_amount: '1999.00' }] }))).toEqual(['math:TaxSubtotal/TaxableAmount']);
  });
});

describe('the codes and the fields of the SDK', () => {
  it('names a code outside its list by CV302', () => {
    const line = { ...(LINES[1] as Row), myinvois_classification: ['022', '099'], unit_code: 'QQQ' };
    const violations = MYINVOIS.write(invoice({ lines: [line], paymentMode: '09', supplier: { ...SUPPLIER, activity: { msic: '99999', description: 'Nothing' } } })).violations;
    expect(violations.map((each) => each.message)).toEqual([
      'ItemCode 09 does not exist in CodeType PaymentMethods.',
      'ItemCode 99999 does not exist in CodeType MSIC.',
      'ItemCode 099 does not exist in CodeType ClassificationCodes.',
      'ItemCode QQQ does not exist in CodeType UnitTypes.',
    ]);
    expect(new Set(violations.map((each) => each.code))).toEqual(new Set(['CV302']));
  });

  it('names a tax exemption without its reason', () => {
    const tax = { ...SALES_TAX, tax_charged: '0.00', myinvois_tax_type: 'E', exemption_reason: null };
    const header = { ...INVOICE, amount_tax: '0.00', amount_total: '2000.00' };
    const lines = [{ ...(LINES[1] as Row), tax_amount: '0.00' }];
    expect(codes(invoice({ header, lines, taxes: [tax] }))).toEqual([
      'required:TaxSubtotal/TaxExemptionReason',
      'required:InvoiceLine/TaxExemptionReason',
    ]);
    const exempted = MYINVOIS.write(invoice({ header, lines, taxes: [{ ...tax, exemption_reason: 'Exempt under the Sales Tax (Goods Exempted from Tax) Order' }] }));
    expect(exempted.violations).toEqual([]);
    expect(exempted.content).toContain('"TaxExemptionReason"');
  });

  it('names a state of Malaysia outside Malaysia, and 17 inside it', () => {
    expect(codes(invoice({ header: { ...INVOICE, buyer_country: 'SG', buyer_region: '10' } }))).toEqual(['CV316']);
    expect(codes(invoice({ header: { ...INVOICE, buyer_region: '17' } }))).toEqual(['CV317']);
    expect(codes(invoice({ header: { ...INVOICE, buyer_region: 'Somewhere' } }))).toEqual(['required:AccountingCustomerParty/CountrySubentityCode']);
  });

  it('names a postcode, a phone, an e-mail and SST and TTX numbers LHDNM refuses, by its codes', () => {
    expect(codes(invoice({ header: { ...INVOICE, buyer_postal_code: '400001' } }))).toEqual(['CF405']);
    expect(codes(invoice({ buyer: { ...BUYER, phone: '03-1234 5678' } }))).toEqual(['CF410']);
    expect(codes(invoice({ buyer: { ...BUYER, phone: '+6012' } }))).toEqual(['CF408']);
    expect(codes(invoice({ buyer: { ...BUYER, phone: `+6${'0'.repeat(20)}` } }))).toEqual(['CF409']);
    expect(codes(invoice({ header: { ...INVOICE, buyer_email: 'finance-at-bintang' } }))).toEqual(['CF401']);
    expect(codes(invoice({ supplier: { ...SUPPLIER, sst: 'W10-0000;W10-0001;W10-0002' } }))).toEqual(['CF406']);
    expect(codes(invoice({ supplier: { ...SUPPLIER, sst: 'W10/0000' } }))).toEqual(['CF406']);
    expect(codes(invoice({ supplier: { ...SUPPLIER, sst: 'W10-0000-00000001;W10-0000-00000002' } }))).toEqual([]);
    expect(codes(invoice({ supplier: { ...SUPPLIER, tourismTax: '123/4567' } }))).toEqual(['CF407']);
    expect(codes(invoice({ supplier: { ...SUPPLIER, tourismTax: '123-4567-890123456789' } }))).toEqual(['CF412']);
  });

  it('names an address line, a city and a name longer than the SDK allows', () => {
    const header = { ...INVOICE, seller_address_line1: 'x'.repeat(151), buyer_address_line1: 'y'.repeat(151), buyer_city: 'z'.repeat(51), buyer_name: 'n'.repeat(301) };
    expect(codes(invoice({ header }))).toEqual(['CF345', 'length:AccountingCustomerParty/RegistrationName', 'CF346', 'CF404']);
  });

  it('names the identifiers longer than the SDK allows', () => {
    expect(
      codes(invoice({ supplier: { ...SUPPLIER, tin: 'C123456789012340', registration: { scheme: 'NRIC', id: '8001010100011' } } })),
    ).toEqual(['length:AccountingSupplierParty/TIN', 'length:AccountingSupplierParty/NRIC']);
  });

  it('names a TIN that is not shaped as the FAQ describes', () => {
    for (const tin of ['C01234567890', 'C123456789', 'X1234567890', 'IG12A']) {
      expect(codes(invoice({ buyer: { ...BUYER, tin } })), tin).toEqual(['format:AccountingCustomerParty/TIN']);
    }
    for (const tin of ['C1234567890', 'CS1234567890', 'IG123456789', 'LE1234567890', 'EI00000000010']) {
      expect(codes(invoice({ buyer: { ...BUYER, tin } })), tin).toEqual([]);
    }
  });
});
