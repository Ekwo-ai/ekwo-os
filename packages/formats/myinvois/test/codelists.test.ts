import { execFileSync } from 'node:child_process';
import { existsSync, readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import * as brick from '../src/index.js';

/**
 * The code lists, against the files they were read from.
 *
 * `src/codelists.ts` is generated, and a generated file nobody compares with
 * its source is a copy like any other. The files are read again here, by other
 * code than the generator's, and every list is compared with them code for code.
 */

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const published = (file: string): Record<string, string>[] => JSON.parse(readFileSync(join(root, 'test', 'codelist', file), 'utf8'));

describe('the code tables of the MyInvois SDK', () => {
  it.each([
    ['EINVOICE_TYPES', 'EInvoiceTypes.json', 'Description'],
    ['TAX_TYPES', 'TaxTypes.json', 'Description'],
    ['CLASSIFICATION_CODES', 'ClassificationCodes.json', 'Description'],
    ['STATE_CODES', 'StateCodes.json', 'State'],
    ['PAYMENT_MODES', 'PaymentMethods.json', 'Payment Method'],
  ] as const)('%s is %s, code for code and label for label', (name, file, label) => {
    expect(brick[name]).toEqual(Object.fromEntries(published(file).map((row) => [row['Code'], String(row[label]).trim()])));
  });

  it.each([
    ['COUNTRY_CODES', 'CountryCodes.json'],
    ['CURRENCY_CODES', 'CurrencyCodes.json'],
    ['UNIT_CODES', 'UnitTypes.json'],
    ['MSIC_CODES', 'MSICSubCategoryCodes.json'],
  ] as const)('%s is %s, code for code', (name, file) => {
    // As a set: the MSIC file lists 16211 twice, the same row both times.
    expect(brick[name]).toEqual(new Set(published(file).map((row) => String(row['Code']).trim())));
  });

  it('holds the eight document types and the seven tax types the SDK pages list', () => {
    expect(Object.keys(brick.EINVOICE_TYPES).sort()).toEqual(['01', '02', '03', '04', '11', '12', '13', '14']);
    expect(Object.keys(brick.TAX_TYPES).sort()).toEqual(['01', '02', '03', '04', '05', '06', 'E']);
    expect(Object.keys(brick.CLASSIFICATION_CODES)).toHaveLength(45);
  });

  it('maps a two-letter country to a three-letter one of LHDNM list only', () => {
    expect(brick.ALPHA3['MY']).toBe('MYS');
    expect(brick.ALPHA3['SG']).toBe('SGP');
    for (const alpha3 of Object.values(brick.ALPHA3)) expect(brick.COUNTRY_CODES.has(alpha3)).toBe(true);
    const pairs = readFileSync(join(root, 'test', 'codelist', 'm49-iso-alpha.csv'), 'utf8').trim().split('\n').slice(1);
    for (const pair of pairs) {
      const [alpha2, alpha3] = pair.split(',') as [string, string];
      expect(brick.ALPHA3[alpha2]).toBe(brick.COUNTRY_CODES.has(alpha3) ? alpha3 : undefined);
    }
  });

  it('is what the generator writes today', () => {
    expect(() => execFileSync(process.execPath, [join(root, 'scripts', 'build-codelists.mjs'), '--check'])).not.toThrow();
  });
});

// --- the copy ----------------------------------------------------------------

const peppol = join(root, '..', 'peppol-ubl');

describe.runIf(existsSync(join(peppol, 'src', 'decimal.ts')))('the file this brick shares with the Peppol brick', () => {
  it('decimal.ts is the same, byte for byte', () => {
    expect(readFileSync(join(root, 'src', 'decimal.ts'), 'utf8')).toBe(readFileSync(join(peppol, 'src', 'decimal.ts'), 'utf8'));
  });
});
