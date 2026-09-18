import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { SCHEMES_NOT_ON_PEPPOL, generatePeppolUbl } from '../src/index.js';
import { CASES } from './fixtures/cases.js';

/**
 * What this package says of a document, against what the network would say.
 *
 * `fixtures/verdicts.json` is the output of the published Schematron — the
 * EN 16931 rules and the Peppol BIS Billing 3.0 rules — played against each
 * committed file by `scripts/play-schematron.mjs`. It is not played here: that
 * takes an XSLT 2.0 processor, which this repository does not depend on. It is
 * *held to* here: for every case, the rules this package reports are exactly
 * the fatal rules the Schematron reported, no more and no fewer.
 *
 * A rule identifier is upper case; a code in lower case is this package's own —
 * something it could not write, which no validator reports because it never
 * sees it — and is left out of the comparison.
 */

const here = join(dirname(fileURLToPath(import.meta.url)), 'fixtures');
const recorded = JSON.parse(readFileSync(join(here, 'verdicts.json'), 'utf8')) as {
  lists: Record<string, string[]>;
  verdicts: Record<string, { fatal: string[]; warning: string[] }>;
};

const published = (code: string): boolean => /^[A-Z]/.test(code);

describe('the verdict of the published Schematron', () => {
  it('was recorded for every case, and for nothing else', () => {
    expect(Object.keys(recorded.verdicts).sort()).toEqual(CASES.map((each) => each.name).sort());
  });

  it('found the two Schematrons to disagree on electronic address schemes, and on nothing else they share', () => {
    // A currency that is wrong is wrong under both rule sets. An address
    // scheme can be right for EN 16931 and wrong for Peppol, and the list of
    // those is the one the rules carry — scheme for scheme.
    expect([...SCHEMES_NOT_ON_PEPPOL].sort()).toEqual(recorded.lists['eas_in_en16931_not_in_peppol']);
    expect(recorded.lists['eas_in_peppol_not_in_en16931']).toEqual([]);
    expect(recorded.lists['currencies_in_en16931_not_in_peppol']).toEqual([]);
    expect(recorded.lists['currencies_in_peppol_not_in_en16931']).toEqual([]);
  });

  for (const each of CASES) {
    it(`${each.name}: ${each.why}`, () => {
      const { violations } = generatePeppolUbl(each.input, each.options);
      const mine = [...new Set(violations.map((v) => v.code).filter(published))].sort();
      expect(mine).toEqual(recorded.verdicts[each.name]?.fatal);
    });
  }

  it('calls right what the Schematron calls right, without a warning', () => {
    const right = CASES.filter((each) => !each.name.startsWith('broken-'));
    expect(right.length).toBeGreaterThanOrEqual(10);
    expect(right.length).toBeGreaterThan(0);
    for (const each of right) {
      expect(recorded.verdicts[each.name]).toEqual({ fatal: [], warning: [] });
      expect(generatePeppolUbl(each.input, each.options).violations).toEqual([]);
    }
  });

  it('is wrong in the way it set out to be, for every case that is wrong', () => {
    for (const each of CASES.filter((c) => c.name.startsWith('broken-'))) {
      expect(recorded.verdicts[each.name]?.fatal.length, each.name).toBeGreaterThan(0);
    }
  });
});
