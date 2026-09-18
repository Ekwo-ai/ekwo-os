import { describe, expect, it } from 'vitest';
import { PeppolUblError, generatePeppolUbl, type PeppolUblInput } from '../src/index.js';
import { add, formatDecimal, multiply, parseDecimal, roundXPath, significantScale } from '../src/decimal.js';
import { CASES } from './fixtures/cases.js';

const named = (name: string) => CASES.find((each) => each.name === name)!;
const standard = named('invoice-standard');
const withHeader = (header: Partial<PeppolUblInput['header']>): PeppolUblInput => ({
  ...standard.input,
  header: { ...standard.input.header, ...header },
});

describe('what is refused outright', () => {
  it('is what would not be an invoice at all', () => {
    const refuse = (input: PeppolUblInput, message: RegExp) =>
      expect(() => generatePeppolUbl(input, standard.options)).toThrow(message);

    refuse(withHeader({ doc_type: 'purchase_invoice' }), /purchase_invoice is not a document this format carries/);
    refuse(withHeader({ doc_type: 'sale_quote' }), /sale_quote/);
    refuse(withHeader({ number: null }), /never issued/);
    refuse(withHeader({ number: '  ' }), /never issued/);
    refuse(withHeader({ currency_code: '' }), /no currency, and there is no default/);
    refuse(withHeader({ document_date: '02/03/2026' }), /not a date/);
    refuse(withHeader({ due_date: '2026-02-30' }), /the due date is not a date/);
    refuse(withHeader({ amount_total: '1.717,00' }), /the total with VAT is not an amount/);
    refuse(withHeader({ amount_total: '1e3' }), /not an amount/);
    refuse({ ...standard.input, lines: [] }, /no line/);
    refuse({ ...standard.input, lines: standard.input.lines.filter((line) => line.line_type === 'section') }, /no line/);
  });

  it('throws an error of its own', () => {
    expect(() => generatePeppolUbl(withHeader({ number: null }))).toThrow(PeppolUblError);
  });
});

describe('the figures', () => {
  it('are the figures it was given, and none it worked out', () => {
    // Totals that are wrong in three places. Every one is written as given and
    // reported, and nothing is quietly made to agree with anything else.
    const { file, violations } = generatePeppolUbl(
      withHeader({ amount_untaxed: '1000.00', amount_tax: '1.00', amount_total: '5.00', amount_residual: '7.00' }),
      standard.options,
    );
    expect(file).toContain('<cbc:TaxExclusiveAmount currencyID="EUR">1000.00</cbc:TaxExclusiveAmount>');
    expect(file).toContain('<cbc:TaxAmount currencyID="EUR">1.00</cbc:TaxAmount>');
    expect(file).toContain('<cbc:TaxInclusiveAmount currencyID="EUR">5.00</cbc:TaxInclusiveAmount>');
    expect(file).toContain('<cbc:PayableAmount currencyID="EUR">7.00</cbc:PayableAmount>');
    expect(violations.map((v) => v.code)).toEqual(['BR-CO-10', 'BR-CO-14', 'BR-CO-15', 'BR-CO-16']);
  });

  it('keep every digit of a number no double can hold', () => {
    const big = '90071992547409.93';
    const { file, violations } = generatePeppolUbl(
      {
        header: { ...standard.input.header, amount_untaxed: big, amount_tax: '0.00', amount_total: big, amount_residual: big },
        lines: [{ item_name: 'Large', quantity: '1', unit_code: 'C62', unit_price: big, amount_untaxed: big, vat_category: 'Z', vat_rate: '0' }],
        taxes: [{ vat_category: 'Z', tax_rate: '0', base_amount: big, tax_charged: '0' }],
      },
      standard.options,
    );
    expect(file).toContain(`<cbc:PayableAmount currencyID="EUR">${big}</cbc:PayableAmount>`);
    expect(violations).toEqual([]);
  });

  it('are read from a number as from a string', () => {
    const minimal = named('invoice-minimal');
    const { file, violations } = generatePeppolUbl(minimal.input, minimal.options);
    expect(violations).toEqual([]);
    expect(file).toContain('<cbc:PayableAmount currencyID="EUR">121.00</cbc:PayableAmount>');
    expect(file).toContain('<cbc:PriceAmount currencyID="EUR">100</cbc:PriceAmount>');
  });

  it('take what is due from the total and what was paid, where the books do not say it', () => {
    const { file, violations } = generatePeppolUbl(withHeader({ amount_paid: '717.00', amount_residual: null }), standard.options);
    expect(file).toContain('<cbc:PrepaidAmount currencyID="EUR">717.00</cbc:PrepaidAmount>');
    expect(file).toContain('<cbc:PayableAmount currencyID="EUR">1000.00</cbc:PayableAmount>');
    expect(violations).toEqual([]);
  });

  it('say nothing of a payment of nothing', () => {
    expect(generatePeppolUbl(standard.input, standard.options).file).not.toContain('PrepaidAmount');
  });
});

describe('from the books to the standard', () => {
  it('a discount is a price discount, exact to the last digit', () => {
    const { file } = generatePeppolUbl(standard.input, standard.options);
    // 27.7778 less 10 %: 2.77778 off, 25.00002 net. Nothing is rounded.
    expect(file).toContain('<cbc:BaseAmount currencyID="EUR">27.7778</cbc:BaseAmount>');
    expect(file).toContain('<cbc:Amount currencyID="EUR">2.77778</cbc:Amount>');
    expect(file).toContain('<cbc:PriceAmount currencyID="EUR">25.00002</cbc:PriceAmount>');
  });

  it('a line that is layout is not a line', () => {
    const { file } = generatePeppolUbl(standard.input, standard.options);
    expect(file.match(/<cac:InvoiceLine>/g)).toHaveLength(2);
    expect(file).not.toContain('Books');
  });

  it('two taxes of the books at one rate are one group of the standard', () => {
    const each = named('invoice-two-taxes-one-rate');
    const { file, violations } = generatePeppolUbl(each.input, each.options);
    expect(violations).toEqual([]);
    expect(file.match(/<cac:TaxSubtotal>/g)).toHaveLength(1);
    expect(file).toContain('<cbc:TaxableAmount currencyID="EUR">1450.00</cbc:TaxableAmount>');
    expect(file).toContain('<cbc:TaxAmount currencyID="EUR">304.50</cbc:TaxAmount>');
  });

  it('the exemption code of the lines goes up to their group, unless the group has its own', () => {
    const k = named('invoice-intra-community');
    expect(generatePeppolUbl(k.input, k.options).file).toContain('<cbc:TaxExemptionReasonCode>VATEX-EU-IC</cbc:TaxExemptionReasonCode>');
    const own = { ...k.input, taxes: k.input.taxes.map((tax) => ({ ...tax, exemption_code: 'VATEX-EU-IC' })), lines: k.input.lines.map((line) => ({ ...line, tax_exemption_code: 'VATEX-EU-G' })) };
    expect(generatePeppolUbl(own, k.options).violations).toEqual([]);
  });

  it('two exemption codes for one group are none, and said so', () => {
    const e = named('invoice-exempt');
    const two = {
      header: { ...e.input.header, amount_untaxed: '1000.00', amount_total: '1000.00', amount_residual: '1000.00' },
      lines: [e.input.lines[0]!, { ...e.input.lines[0]!, sequence: 2, tax_exemption_code: 'VATEX-EU-132-1J' }],
      taxes: [{ ...e.input.taxes[0]!, base_amount: '1000.00', exemption_reason: null }],
    };
    const { file, violations } = generatePeppolUbl(two, e.options);
    expect(file).not.toContain('TaxExemptionReasonCode');
    expect(violations.map((v) => v.code)).toEqual(['BR-E-10', 'exemption-reason-ambiguous']);
  });

  it('outside the scope of VAT there is no rate, not a rate of zero', () => {
    const o = named('invoice-outside-scope');
    expect(generatePeppolUbl(o.input, o.options).file).not.toContain('<cbc:Percent>');
  });

  it('a credit note keeps its due date where its schema has room for one', () => {
    const credit = named('credit-note');
    const { file } = generatePeppolUbl(credit.input, credit.options);
    expect(file).not.toContain('<cbc:DueDate>');
    expect(file).toContain('<cbc:PaymentDueDate>2026-04-19</cbc:PaymentDueDate>');
    expect(file).toContain('<cbc:CreditNoteTypeCode>381</cbc:CreditNoteTypeCode>');
    expect(file).toContain('<cbc:CreditedQuantity unitCode="DAY">1</cbc:CreditedQuantity>');
    expect(file).toContain('<cbc:DocumentTypeCode>50</cbc:DocumentTypeCode>');
    expect(file).toMatch(/<cac:InvoiceDocumentReference>\s*<cbc:ID>INV-2026-0001<\/cbc:ID>\s*<cbc:IssueDate>2026-03-02</);
  });

  it('identifiers lose their spaces and dots, and nothing else', () => {
    const { file } = generatePeppolUbl(standard.input, standard.options);
    expect(file).toContain('<cbc:CompanyID schemeID="0208">0999999922</cbc:CompanyID>');
    expect(file).toContain('<cbc:ID>BE68539007547034</cbc:ID>');
  });

  it('a registration number has the scheme it is given, and none otherwise', () => {
    const { file } = generatePeppolUbl(standard.input, standard.options);
    expect(file.match(/schemeID="0208"/g)).toHaveLength(2); // the seller's endpoint and its registration
    expect(file).toContain('<cbc:CompanyID>99999999</cbc:CompanyID>');
    const bare = generatePeppolUbl(standard.input, { ...standard.options, sellerRegistrationScheme: undefined });
    expect(bare.file).toContain('<cbc:CompanyID>0999999922</cbc:CompanyID>');
    expect(bare.violations).toEqual([]);
  });
});

describe('the electronic addresses', () => {
  const onFile = {
    seller_peppol_scheme: '0088',
    seller_peppol_identifier: '5412345000013',
    buyer_peppol_scheme: '0088',
    buyer_peppol_identifier: '5412345000020',
  };

  it('are read from the header, which is where the books keep them', () => {
    const { sellerEndpoint: _s, buyerEndpoint: _b, ...options } = standard.options;
    const { file, violations } = generatePeppolUbl(withHeader(onFile), options);
    expect(file).toContain('<cbc:EndpointID schemeID="0088">5412345000013</cbc:EndpointID>');
    expect(file).toContain('<cbc:EndpointID schemeID="0088">5412345000020</cbc:EndpointID>');
    expect(violations).toEqual([]);
  });

  it('are the caller\'s where the caller gives them', () => {
    const given = generatePeppolUbl(withHeader(onFile), standard.options);
    expect(given.file).toBe(generatePeppolUbl(standard.input, standard.options).file);
  });

  it('are never worked out from another identifier', () => {
    const { sellerEndpoint: _s, buyerEndpoint: _b, ...options } = standard.options;
    const codes = generatePeppolUbl(standard.input, options).violations.map((violation) => violation.code);
    expect(codes).toEqual(expect.arrayContaining(['PEPPOL-EN16931-R010', 'PEPPOL-EN16931-R020']));
  });

  it('a line that does not say its category has none: it is not looked up', () => {
    const silent: PeppolUblInput = {
      ...standard.input,
      lines: standard.input.lines.map((row) => ({ ...row, vat_category: null, vat_rate: null })),
    };
    const codes = generatePeppolUbl(silent, standard.options).violations.map((violation) => violation.code);
    expect(codes).toContain('BR-CO-04');
  });
});

describe('nothing is made up', () => {
  const bare: PeppolUblInput = {
    header: {
      doc_type: 'sale_invoice',
      number: 'A/1',
      document_date: '2026-03-02',
      currency_code: 'JPY',
      amount_untaxed: '1000',
      amount_tax: '100',
      amount_total: '1100',
      seller_name: null,
      buyer_name: null,
      payee_iban: 'BE68539007547034',
    },
    lines: [{ item_name: null, quantity: null, amount_untaxed: '1000' }],
    taxes: [],
  };

  it('no unit, no payment means, no country, no scheme, no reason', () => {
    const { file } = generatePeppolUbl(bare);
    for (const invented of ['C62', '<cbc:PaymentMeansCode>', 'IdentificationCode', 'schemeID', 'EUR', 'TaxExemptionReason', 'BuyerReference']) {
      expect(file, invented).not.toContain(invented);
    }
    expect(file).toContain('currencyID="JPY"');
  });

  it('an account with no code to file it under is not written, and that is said', () => {
    const { file, violations } = generatePeppolUbl(bare);
    expect(file).not.toContain('BE68539007547034');
    expect(violations.map((v) => v.code)).toContain('payment-means-missing');
  });

  it('no element is written empty', () => {
    for (const each of CASES) {
      const { file } = generatePeppolUbl(each.input, each.options);
      expect(file, each.name).not.toMatch(/<[^/>]+>\s*<\/[^>]+>/);
      expect(file, each.name).not.toMatch(/<[^>]+\/>/);
    }
  });

  it('what is wrong on a line says which line', () => {
    const each = named('broken-line-arithmetic');
    expect(generatePeppolUbl(each.input, each.options).violations).toEqual([
      { code: 'PEPPOL-EN16931-R120', message: expect.stringContaining('1198'), line: '10' },
    ]);
  });
});

describe('the file', () => {
  it('escapes what XML would read as markup', () => {
    const { file } = generatePeppolUbl(withHeader({ note: 'A < B & "C" > D', buyer_name: 'O\'Neil & <Sons>' }), standard.options);
    expect(file).toContain('<cbc:Note>A &lt; B &amp; &quot;C&quot; &gt; D</cbc:Note>');
    expect(file).toContain("<cbc:RegistrationName>O'Neil &amp; &lt;Sons&gt;</cbc:RegistrationName>");
  });

  it('is named after the document, whatever the document is numbered with', () => {
    expect(generatePeppolUbl(standard.input, standard.options).filename).toBe('invoice-INV-2026-0001.xml');
    expect(generatePeppolUbl(withHeader({ number: 'FA 2026/0042' }), standard.options).filename).toBe('invoice-FA-2026-0042.xml');
    const credit = named('credit-note');
    expect(generatePeppolUbl(credit.input, credit.options).filename).toBe('credit-note-CN-2026-0001.xml');
  });

  it('declares the profile it is written in', () => {
    const { file } = generatePeppolUbl(standard.input, standard.options);
    expect(file).toContain('<cbc:CustomizationID>urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0</cbc:CustomizationID>');
    expect(file).toContain('<cbc:ProfileID>urn:fdc:peppol.eu:2017:poacc:billing:01:1.0</cbc:ProfileID>');
  });
});

describe('decimals', () => {
  const d = (text: string) => parseDecimal(text)!;

  it('are exact where a double is not', () => {
    expect(formatDecimal(add(d('0.1'), d('0.2')))).toBe('0.3');
    expect(formatDecimal(multiply(d('1.15'), d('100')))).toBe('115');
    expect(formatDecimal(multiply(d('27.7778'), d('0.9')))).toBe('25.00002');
  });

  it('round the way XPath does: half towards positive infinity', () => {
    expect(formatDecimal(roundXPath(d('2.675'), 2))).toBe('2.68');
    expect(formatDecimal(roundXPath(d('1.005'), 2))).toBe('1.01');
    expect(formatDecimal(roundXPath(d('-2.5'), 0))).toBe('-2');
    expect(formatDecimal(roundXPath(d('-2.51'), 0))).toBe('-3');
    expect(formatDecimal(roundXPath(d('2.5'), 0))).toBe('3');
  });

  it('refuse what xs:decimal refuses', () => {
    for (const text of ['1e3', '1,5', '1 000', '', 'abc', '1.', '--1', 'NaN', 'Infinity']) {
      expect(parseDecimal(text), text).toBeNull();
    }
    expect(parseDecimal(Number.NaN)).toBeNull();
    expect(formatDecimal(d('+.5'))).toBe('0.5');
    expect(formatDecimal(d('-0.00'), 2)).toBe('0.00');
  });

  it('write two decimals at least, and drop only zeros', () => {
    expect(formatDecimal(d('10'), 2)).toBe('10.00');
    expect(formatDecimal(d('10.500'), 2)).toBe('10.50');
    expect(formatDecimal(d('10.505'), 2)).toBe('10.505');
    expect(formatDecimal(d('21.0000'))).toBe('21');
    expect(significantScale(d('10.500'))).toBe(1);
  });
});
