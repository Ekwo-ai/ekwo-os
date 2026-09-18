import { describe, expect, it } from 'vitest';
import {
  GRIDS,
  NIL_GRID,
  formatAmount,
  formatGrid,
  generateVatConsignment,
  generateVatConsignments,
  vatConsignmentFileName,
  VatConsignmentError,
  type FiledBox,
  type Representative,
} from '../src/index.js';

/**
 * Every figure below is invented. A VAT return is one of the few files where a
 * fixture taken from real books would be a disclosure, and none is needed: what
 * is under test is the shape of the document and the refusals, not arithmetic
 * this package does not do.
 */

const declarant = {
  vatNumber: '0999999999',
  name: 'Société de démonstration',
  street: 'Rue Inventée 1',
  postCode: '1000',
  city: 'Bruxelles',
  countryCode: 'BE',
};

const quarter = { year: 2026, quarter: 4 };

/** A plain return: sales at one rate, the tax on them, the total due. */
const boxes: FiledBox[] = [
  { box: '03', kind: 'base', amount: '10000.00' },
  { box: '54', kind: 'tax', amount: '2100.00' },
  { box: '59', kind: 'tax', amount: '400.00' },
  { box: '71', kind: 'total', amount: '1700.00' },
];

describe('the document', () => {
  it('is one consignment holding one declaration, in the two namespaces the schema uses', () => {
    const { file } = generateVatConsignment(boxes, { declarant, period: quarter });
    expect(file).toContain('<?xml version="1.0" encoding="UTF-8"?>');
    expect(file).toContain('xmlns:ns2="http://www.minfin.fgov.be/VATConsignment"');
    expect(file).toContain('xmlns="http://www.minfin.fgov.be/InputCommon"');
    expect(file).toContain('VATDeclarationsNbr="1"');
    expect(file).toContain('<ns2:VATDeclaration SequenceNumber="1">');
    expect(file.trimEnd().endsWith('</ns2:VATConsignment>')).toBe(true);
  });

  it('carries the declarant without its country prefix, and only the fields it was given', () => {
    const { file } = generateVatConsignment(boxes, {
      declarant: { vatNumber: 'BE 0999.999.999', name: 'Demo' },
      period: quarter,
    });
    expect(file).toContain('<VATNumber>0999999999</VATNumber>');
    expect(file).toContain('<Name>Demo</Name>');
    // Nothing was given for these, so nothing is written: an invented phone
    // number reaches an administration as a phone number.
    expect(file).not.toContain('<Phone>');
    expect(file).not.toContain('<City>');
  });

  it('writes the period as the one element the cadence calls for', () => {
    const quarterly = generateVatConsignment(boxes, { declarant, period: quarter });
    expect(quarterly.file).toContain('<ns2:Quarter>4</ns2:Quarter>');
    expect(quarterly.file).not.toContain('<ns2:Month>');

    const monthly = generateVatConsignment(boxes, {
      declarant,
      period: { year: 2026, month: 3 },
    });
    expect(monthly.file).toContain('<ns2:Month>03</ns2:Month>');
    expect(monthly.file).not.toContain('<ns2:Quarter>');
  });

  it('numbers grids with two digits and writes them in order', () => {
    const { file } = generateVatConsignment(
      [
        { box: '71', kind: 'total', amount: 1700 },
        { box: '3', kind: 'base', amount: 10000 },
        { box: '54', kind: 'tax', amount: 2100 },
      ],
      { declarant, period: quarter },
    );
    const grids = [...file.matchAll(/GridNumber="([0-9]{2})"/g)].map((m) => m[1]);
    expect(grids).toEqual(['03', '54', '71']);
  });

  it('leaves a grid at zero out of the file', () => {
    const { file } = generateVatConsignment(
      [...boxes, { box: '49', kind: 'base', amount: '0.00' }],
      { declarant, period: quarter },
    );
    expect(file).not.toContain('GridNumber="49"');
  });

  it('writes amounts with a point and two decimals', () => {
    const { file } = generateVatConsignment([{ box: '03', kind: 'base', amount: 1234.5 }], {
      declarant,
      period: quarter,
    });
    expect(file).toContain('<ns2:Amount GridNumber="03">1234.50</ns2:Amount>');
    expect(file).not.toContain(',');
  });

  it('asks for nothing unless it is told to, and claims nothing about the customer listing', () => {
    const silent = generateVatConsignment(boxes, { declarant, period: quarter });
    expect(silent.file).toContain('<ns2:Ask Restitution="NO" Payment="NO"/>');
    // The schema requires the element on every return, and NO is the absence
    // of a claim rather than a claim that there will be a listing.
    expect(silent.file).toContain('<ns2:ClientListingNihil>NO</ns2:ClientListingNihil>');

    const asked = generateVatConsignment(boxes, {
      declarant,
      period: quarter,
      ask: { restitution: true },
      clientListingNihil: true,
      comment: 'Régularisation & solde',
      declarantReference: '2026Q4',
    });
    expect(asked.file).toContain('<ns2:Ask Restitution="YES" Payment="NO"/>');
    expect(asked.file).toContain('<ns2:ClientListingNihil>YES</ns2:ClientListingNihil>');
    expect(asked.file).toContain('<ns2:Comment>Régularisation &amp; solde</ns2:Comment>');
    expect(asked.file).toContain('DeclarantReference="2026Q4"');
  });

  it('writes a nil return as a return: nothing is owed, said on the grid that carries what is owed', () => {
    const { file, violations } = generateVatConsignment([], { declarant, period: quarter });
    expect(violations).toEqual([]);
    // The schema requires Data and one Amount in it, and does not say which.
    expect(file).toContain(`<ns2:Amount GridNumber="${NIL_GRID}">0.00</ns2:Amount>`);
    expect(file).toContain('<VATNumber>0999999999</VATNumber>');
    expect(file).toContain('<ns2:Quarter>4</ns2:Quarter>');
  });

  it('names the declaration it replaces, first, when it is a corrective', () => {
    const { file } = generateVatConsignment(boxes, {
      declarant,
      period: quarter,
      replacedDeclaration: '123456-0999999999-000001',
    });
    const replaced = file.indexOf('<ns2:ReplacedVATDeclaration>123456-0999999999-000001');
    expect(replaced).toBeGreaterThan(0);
    expect(replaced).toBeLessThan(file.indexOf('<ns2:Declarant>'));
  });
});

describe('what it refuses', () => {
  it('a grid this form does not number, and keeps the rest of the return', () => {
    const { file, violations } = generateVatConsignment(
      [...boxes, { box: '8A', kind: 'base', amount: 100 }],
      { declarant, period: quarter },
    );
    expect(violations).toHaveLength(1);
    expect(violations[0]!.code).toBe('unknown_grid');
    expect(violations[0]!.box).toBe('8A');
    expect(file).toContain('GridNumber="03"');
  });

  it('the same grid twice, which is the one thing this format cannot hold', () => {
    const { file, violations } = generateVatConsignment(
      [
        { box: '03', kind: 'base', amount: 10000 },
        { box: '03', kind: 'tax', amount: 2000 },
      ],
      { declarant, period: quarter },
    );
    expect(violations).toHaveLength(1);
    expect(violations[0]!.code).toBe('grid_twice');
    expect(violations[0]!.message).toContain('base');
    expect(violations[0]!.message).toContain('tax');
    // The first figure is still in the file; the second is not.
    expect(file).toContain('<ns2:Amount GridNumber="03">10000.00</ns2:Amount>');
    expect(file).not.toContain('2000.00');
  });

  it('a number that looks like a grid and is not one of this form', () => {
    const { violations } = generateVatConsignment([{ box: '91', kind: 'tax', amount: 100 }], {
      declarant,
      period: quarter,
    });
    expect(violations.map((v) => v.code)).toEqual(['unknown_grid']);
  });

  it('a negative amount, because no grid of this form goes below zero', () => {
    const { file, violations } = generateVatConsignment(
      [...boxes, { box: '81', kind: 'base', amount: '-250.00' }],
      { declarant, period: quarter },
    );
    expect(violations).toHaveLength(1);
    expect(violations[0]!.code).toBe('negative_amount');
    expect(file).not.toContain('GridNumber="81"');
    expect(file).not.toContain('-250');
  });

  it('a reference or a telephone number the schema cannot hold, by leaving it out and saying so', () => {
    const { file, violations } = generateVatConsignment(boxes, {
      declarant: { ...declarant, phone: '+32 2 000 00 00 000 000 000 000 000' },
      period: quarter,
      declarantReference: 'a-reference-far-too-long',
    });
    expect(violations.map((v) => v.code).sort()).toEqual(['invalid_phone', 'reference_too_long']);
    expect(file).not.toContain('DeclarantReference=');
    expect(file).not.toContain('<Phone>');
  });

  it('a corrective that does not name what it replaces the way Intervat names it, by exception', () => {
    expect(() =>
      generateVatConsignment(boxes, { declarant, period: quarter, replacedDeclaration: 'DEP-1' }),
    ).toThrow(/being replaced/);
  });

  it('an amount that is not one', () => {
    const { violations } = generateVatConsignment([{ box: '03', kind: 'base', amount: 'n/a' }], {
      declarant,
      period: quarter,
    });
    expect(violations).toHaveLength(1);
    expect(violations[0]!.code).toBe('invalid_amount');
  });

  it('a period that is neither a month nor a quarter, by exception', () => {
    expect(() => generateVatConsignment(boxes, { declarant, period: { year: 2026 } })).toThrow(
      VatConsignmentError,
    );
    expect(() =>
      generateVatConsignment(boxes, { declarant, period: { year: 2026, month: 3, quarter: 1 } }),
    ).toThrow(/exactly one/);
    expect(() =>
      generateVatConsignment(boxes, { declarant, period: { year: 2026, quarter: 5 } }),
    ).toThrow(/quarter out of range/);
  });

  it('a declarant number the schema cannot hold, by exception', () => {
    expect(() =>
      generateVatConsignment(boxes, {
        declarant: { vatNumber: '12345' },
        period: quarter,
      }),
    ).toThrow(/ten digits/);
  });
});

describe('the small pieces', () => {
  it('pads a grid and formats an amount the way the schema reads them', () => {
    expect(formatGrid('3')).toBe('03');
    expect(formatGrid('54')).toBe('54');
    expect(formatAmount('1234.5')).toBe('1234.50');
    expect(formatAmount(-12)).toBe('-12.00');
    expect(() => formatAmount('n/a')).toThrow(VatConsignmentError);
  });

  it('names the file after the declarant and the period', () => {
    expect(vatConsignmentFileName('BE 0999.999.999', quarter)).toBe(
      'VATConsignment-0999999999-2026Q4.xml',
    );
    expect(vatConsignmentFileName('0999999999', { year: 2026, month: 3 })).toBe(
      'VATConsignment-0999999999-2026M03.xml',
    );
  });
});

const representative: Representative = {
  id: '0888888888',
  issuedBy: 'BE',
  identificationType: 'NVAT',
  name: 'Fiduciaire de démonstration',
  street: 'Rue Inventée 2',
  postCode: '1000',
  city: 'Bruxelles',
  countryCode: 'BE',
  emailAddress: 'firm@example.test',
  phone: '+32 2 000 00 01',
};

const other = { vatNumber: '0777777777' };

describe('a consignment of several returns', () => {
  it('counts them, numbers them by position, and writes the representative before any of them', () => {
    const { file } = generateVatConsignments(
      [
        { boxes, options: { declarant, period: quarter } },
        { boxes, options: { declarant: other, period: quarter } },
      ],
      { representative, representativeReference: 'LOT-1' },
    );
    expect(file).toContain('VATDeclarationsNbr="2"');
    expect(file).toContain(
      '<RepresentativeID issuedBy="BE" identificationType="NVAT">0888888888</RepresentativeID>',
    );
    expect(file).toContain('<Phone>3220000001</Phone>');
    const order = [
      '<ns2:Representative>',
      '<ns2:RepresentativeReference>LOT-1</ns2:RepresentativeReference>',
      '<ns2:VATDeclaration SequenceNumber="1">',
      '<ns2:VATDeclaration SequenceNumber="2">',
    ].map((mark) => file.indexOf(mark));
    expect(order.every((at) => at >= 0)).toBe(true);
    expect([...order].sort((a, b) => a - b)).toEqual(order);
  });

  it('is the same file as before when it holds one return and no representative', () => {
    const one = generateVatConsignment(boxes, { declarant, period: quarter });
    const many = generateVatConsignments([{ boxes, options: { declarant, period: quarter } }]);
    expect(many).toEqual(one);
  });

  it('says which return a violation is in, and only when there are several', () => {
    const bad: FiledBox[] = [{ box: '54', kind: 'tax', amount: '-1.00' }];
    const { violations } = generateVatConsignments([
      { boxes, options: { declarant, period: quarter } },
      { boxes: bad, options: { declarant: other, period: quarter, sequenceNumber: 7 } },
    ]);
    expect(violations).toEqual([
      expect.objectContaining({ code: 'negative_amount', box: '54', declaration: 7 }),
    ]);
    const alone = generateVatConsignment(bad, { declarant, period: quarter });
    expect(alone.violations[0]).not.toHaveProperty('declaration');
  });

  it('refuses two returns under one sequence number, and a consignment of none', () => {
    expect(() =>
      generateVatConsignments([
        { boxes, options: { declarant, period: quarter, sequenceNumber: 2 } },
        { boxes, options: { declarant: other, period: quarter } },
      ]),
    ).toThrow(/sequence number 2/);
    expect(() => generateVatConsignments([])).toThrow(VatConsignmentError);
  });

  it('refuses a representative named by halves, and names what is lacking', () => {
    const { phone: _phone, street: _street, ...partial } = representative;
    expect(() =>
      generateVatConsignments([{ boxes, options: { declarant, period: quarter } }], {
        representative: partial as Representative,
      }),
    ).toThrow(/lacks: street, phone/);
  });

  it('refuses an issuing state the schema does not list — Greece is EL there', () => {
    expect(() =>
      generateVatConsignments([{ boxes, options: { declarant, period: quarter } }], {
        representative: { ...representative, issuedBy: 'GR' },
      }),
    ).toThrow(/GR is not one/);
  });

  it('leaves out a reference of the representative that does not fit, and says so', () => {
    const { file, violations } = generateVatConsignments(
      [{ boxes, options: { declarant, period: quarter } }],
      { representative, representativeReference: 'A-REFERENCE-TOO-LONG' },
    );
    expect(file).not.toContain('RepresentativeReference');
    expect(violations).toEqual([expect.objectContaining({ code: 'reference_too_long' })]);
  });

  it('is named after the representative, the period when they share one, and how many it holds', () => {
    const shared = generateVatConsignments(
      [
        { boxes, options: { declarant, period: quarter } },
        { boxes, options: { declarant: other, period: quarter } },
      ],
      { representative },
    );
    expect(shared.filename).toBe('VATConsignment-0888888888-2026Q4-x2.xml');
    const mixed = generateVatConsignments(
      [
        { boxes, options: { declarant, period: quarter } },
        { boxes, options: { declarant: other, period: { year: 2026, month: 12 } } },
      ],
      { representative },
    );
    expect(mixed.filename).toBe('VATConsignment-0888888888-x2.xml');
  });
});
