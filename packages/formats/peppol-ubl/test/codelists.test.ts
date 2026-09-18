import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import * as brick from '../src/index.js';

/**
 * The code lists, against the file they were read from.
 *
 * `src/codelists.ts` is generated, and a generated file that nobody compares
 * with its source is a copy like any other. The source is parsed again here,
 * by other code than the generator's, and every list is compared with it code
 * for code and in order.
 */

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const schematron = readFileSync(join(root, 'test', 'codelist', 'CEN-EN16931-UBL.sch'), 'utf8');

/** The first quoted list in the test of one assertion. */
function published(rule: string): string[] {
  const start = schematron.indexOf(`<assert id="${rule}"`);
  expect(start, rule).toBeGreaterThan(-1);
  const assertion = schematron.slice(start, schematron.indexOf('>', start));
  const quoted = /contains\(\s*'([^']*)'/.exec(assertion);
  expect(quoted, rule).not.toBeNull();
  return (quoted as RegExpExecArray)[1]!.trim().split(/\s+/);
}

const LISTS: [name: keyof typeof brick, rule: string][] = [
  ['CURRENCY_CODES', 'BR-CL-04'],
  ['COUNTRY_CODES', 'BR-CL-14'],
  ['VAT_IDENTIFIER_PREFIXES', 'BR-CO-09'],
  ['PAYMENT_MEANS_CODES', 'BR-CL-16'],
  ['VAT_CATEGORY_CODES', 'BR-CL-18'],
  ['EXEMPTION_REASON_CODES', 'BR-CL-22'],
  ['UNIT_CODES', 'BR-CL-23'],
  ['ELECTRONIC_ADDRESS_SCHEMES', 'BR-CL-25'],
  ['IDENTIFIER_SCHEMES', 'BR-CL-11'],
];

describe('the code lists', () => {
  for (const [name, rule] of LISTS) {
    it(`${name} is the list of ${rule}, code for code`, () => {
      const list = brick[name] as ReadonlySet<string>;
      const source = published(rule);
      expect(source.length).toBeGreaterThan(5);
      // A set keeps insertion order, so this compares the order too; and a
      // duplicate in the source shows as a difference in length.
      expect([...list]).toEqual([...new Set(source)]);
    });
  }

  it('are what the generator writes today', () => {
    // Throws, with the generator's own message, if src/codelists.ts is stale.
    execFileSync(process.execPath, [join(root, 'scripts', 'build-codelists.mjs'), '--check'], { stdio: 'pipe' });
  });

  it('use one list for the two rules that share it', () => {
    // Currencies are checked where they are declared and where they are used,
    // categories on a line and on a group. One list each here; two in the file.
    expect(published('BR-CL-03')).toEqual(published('BR-CL-04'));
    expect(published('BR-CL-17')).toEqual(published('BR-CL-18'));
  });

  it('take nothing Peppol refuses out of a list that does not have it', () => {
    for (const scheme of brick.SCHEMES_NOT_ON_PEPPOL) {
      expect(brick.ELECTRONIC_ADDRESS_SCHEMES.has(scheme), scheme).toBe(true);
    }
  });
});
