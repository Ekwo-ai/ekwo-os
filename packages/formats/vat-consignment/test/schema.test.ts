import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { validateXML } from 'xmllint-wasm';
import {
  GRIDS,
  ISSUERS,
  generateVatConsignment,
  generateVatConsignments,
  type FiledBox,
  type Representative,
} from '../src/index.js';

/**
 * The published schema, and what it says of the files this package writes.
 *
 * The five files under `xsd/` are the ones the SPF Finances publishes — see
 * `xsd/README.md` for where each came from and when. They are read here and
 * nowhere else: the package itself ships none of them and depends on nothing.
 *
 * This is the test the first version of this brick did not have, and its
 * README said so. It found four things the day it was written: `Data` and
 * `ClientListingNihil` are required, every amount is a positive one, and the
 * grids are a closed list.
 */

const here = join(dirname(fileURLToPath(import.meta.url)), 'xsd');
const read = (name: string): Buffer => readFileSync(join(here, name));

const MAIN = 'NewTVA-in_v0_9.xsd';
const IMPORTED = [
  'IntervatInputCommon_v0_9.xsd',
  'IntervatIsoTypes_v0_9.xsd',
  'commontypes_v1.xsd',
  'isotypes_v1.xsd',
];

async function validate(xml: string): Promise<{ valid: boolean; errors: string[] }> {
  const result = await validateXML({
    xml: [{ fileName: 'return.xml', contents: xml }],
    schema: [{ fileName: MAIN, contents: read(MAIN) }],
    preload: IMPORTED.map((fileName) => ({ fileName, contents: read(fileName) })),
  });
  return { valid: result.valid, errors: result.errors.map((error) => error.message) };
}

const declarant = {
  vatNumber: '0999999999',
  name: 'Société de démonstration',
  street: 'Rue Inventée 1',
  postCode: '1000',
  city: 'Bruxelles',
  countryCode: 'BE',
  emailAddress: 'demo@example.test',
  phone: '+32 2 000 00 00',
};

const boxes: FiledBox[] = [
  { box: '03', kind: 'base', amount: '10000.00' },
  { box: '54', kind: 'tax', amount: '2100.00' },
  { box: '59', kind: 'tax', amount: '400.00' },
  { box: '71', kind: 'total', amount: '1700.00' },
];

describe('against the schema the administration publishes', () => {
  it('a full quarterly return is valid', async () => {
    const { file } = generateVatConsignment(boxes, {
      declarant,
      period: { year: 2026, quarter: 4 },
      declarantReference: '2026Q4',
      ask: { restitution: true },
      clientListingNihil: true,
      comment: 'Régularisation & solde',
    });
    expect(await validate(file)).toEqual({ valid: true, errors: [] });
  });

  it('a monthly return with nothing but a number and figures is valid', async () => {
    const { file } = generateVatConsignment(boxes, {
      declarant: { vatNumber: '0999999999' },
      period: { year: 2026, month: 3 },
    });
    expect(await validate(file)).toEqual({ valid: true, errors: [] });
  });

  it('a nil return is valid', async () => {
    const { file } = generateVatConsignment([], {
      declarant: { vatNumber: '0999999999' },
      period: { year: 2026, quarter: 1 },
    });
    expect(await validate(file)).toEqual({ valid: true, errors: [] });
  });

  it('a corrective that names what it replaces is valid', async () => {
    const { file } = generateVatConsignment(boxes, {
      declarant,
      period: { year: 2026, quarter: 4 },
      replacedDeclaration: '123456-0999999999-000001',
    });
    expect(await validate(file)).toEqual({ valid: true, errors: [] });
  });

  it('every grid of the form at once is valid', async () => {
    const all = GRIDS.filter((grid) => grid !== '72').map((grid) => ({
      box: grid,
      kind: 'tax',
      amount: '1.00',
    }));
    const { file, violations } = generateVatConsignment(all, {
      declarant,
      period: { year: 2026, month: 12 },
    });
    expect(violations).toEqual([]);
    expect(await validate(file)).toEqual({ valid: true, errors: [] });
  });

  it('what comes back as a violation is what the schema would have refused', async () => {
    // Left in the file, each of these fails validation: that is what makes them
    // violations of this format and not opinions of this package.
    const { file } = generateVatConsignment(boxes, { declarant, period: { year: 2026, quarter: 4 } });
    const negative = file.replace('>2100.00<', '>-2100.00<');
    const unknown = file.replace('GridNumber="54"', 'GridNumber="91"');
    expect((await validate(negative)).valid).toBe(false);
    expect((await validate(unknown)).valid).toBe(false);
  });
});

/** A firm that files for its clients. Invented, like everything else here. */
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

describe('a consignment filed by a representative, against the schema', () => {
  it('one return under a representative is valid', async () => {
    const { file } = generateVatConsignments(
      [{ boxes, options: { declarant, period: { year: 2026, quarter: 4 } } }],
      { representative, representativeReference: 'LOT-2026Q4' },
    );
    expect(await validate(file)).toEqual({ valid: true, errors: [] });
  });

  it('the returns of several declarants in one file are valid, a nil one among them', async () => {
    const { file, violations } = generateVatConsignments(
      [
        { boxes, options: { declarant, period: { year: 2026, quarter: 4 } } },
        { boxes: [], options: { declarant: { vatNumber: '0777777777' }, period: { year: 2026, quarter: 4 } } },
        { boxes, options: { declarant: { vatNumber: '0666666666' }, period: { year: 2026, month: 12 } } },
      ],
      { representative },
    );
    expect(violations).toEqual([]);
    expect(file).toContain('VATDeclarationsNbr="3"');
    expect(await validate(file)).toEqual({ valid: true, errors: [] });
  });

  it('an identifier that is neither a VAT number nor a TIN says what it is, and is valid', async () => {
    const { file } = generateVatConsignments(
      [{ boxes, options: { declarant, period: { year: 2026, quarter: 4 } } }],
      {
        representative: {
          ...representative,
          id: 'REG-0001',
          issuedBy: 'EL',
          identificationType: 'other',
          otherQualifier: 'professional register',
        },
      },
    );
    expect(file).toContain('otherQlf="professional register"');
    expect(await validate(file)).toEqual({ valid: true, errors: [] });
  });

  it('a representative named by halves is what the schema would have refused', async () => {
    // Which is why the package refuses it by exception rather than writing
    // what it was given: the block is optional, and nothing inside it is.
    const { file } = generateVatConsignments(
      [{ boxes, options: { declarant, period: { year: 2026, quarter: 4 } } }],
      { representative },
    );
    for (const tag of ['Name', 'Street', 'PostCode', 'City', 'CountryCode', 'EmailAddress', 'Phone']) {
      const without = file.replace(new RegExp(`    <${tag}>[^<]*</${tag}>\\n`), '');
      expect(without).not.toEqual(file);
      expect((await validate(without)).valid, tag).toBe(false);
    }
    const foreign = file.replace('issuedBy="BE"', 'issuedBy="GR"');
    expect((await validate(foreign)).valid).toBe(false);
  });
});

describe('the states that issue a representative\'s identifier', () => {
  it('are the union the schema draws, code for code', () => {
    const schema = read('IntervatIsoTypes_v0_9.xsd').toString('latin1');
    const codesOf = (name: string): string[] => {
      const from = schema.slice(schema.indexOf(`<xs:simpleType name="${name}">`));
      return [...from.slice(0, from.indexOf('</xs:simpleType>')).matchAll(/enumeration value="([A-Z]+)"/g)].map(
        (match) => match[1] as string,
      );
    };
    // <xs:union memberTypes="MSCountryCodeExclBE BECountryCode"/>
    expect(schema).toMatch(
      /<xs:simpleType name="MSCountryCode">\s*<xs:union memberTypes="MSCountryCodeExclBE BECountryCode"\/>/,
    );
    expect([...ISSUERS]).toEqual([...codesOf('MSCountryCodeExclBE'), ...codesOf('BECountryCode')]);
  });
});

describe('the list of grids', () => {
  it('is the enumeration of the schema, number for number', () => {
    const schema = read(MAIN).toString('latin1');
    const enumeration = schema.slice(schema.indexOf('name="GridNumberCode"'));
    const listed = [...enumeration.slice(0, enumeration.indexOf('</xs:simpleType>')).matchAll(
      /enumeration value="([0-9]+)"/g,
    )].map((match) => (match[1] as string).padStart(2, '0'));
    expect([...GRIDS]).toEqual(listed);
  });
});
