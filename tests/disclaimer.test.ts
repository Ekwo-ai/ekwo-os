/**
 * `DISCLAIMER.md` says what the project is not, and what the user stays
 * responsible for.
 *
 * In some countries keeping the books of others or giving tax advice is a
 * regulated profession, so the text that says Ekwo is software and not an
 * accounting service has to keep every one of its parts. This reads the file
 * and refuses one that lost a section or its dated version.
 */

import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { describe, expect, it } from 'vitest';
import { repoRoot } from './helpers/db.js';

const text = readFileSync(join(repoRoot, 'DISCLAIMER.md'), 'utf8');

describe('the disclaimer', () => {
  it('says what the project is not, and what the user stays responsible for', () => {
    expect(text).toMatch(/open source data infrastructure/);
    expect(text).toMatch(/not an accounting firm/);
    for (const heading of [
      'What Ekwo does not provide',
      'Your books, your filings, your deadlines',
      'Software you can change',
      'No warranty, no liability',
      'European Union',
      'United Kingdom',
      'United States',
      'OHADA member States',
      'Names and trademarks',
    ]) {
      expect(text, `DISCLAIMER.md has no section "${heading}"`).toContain(heading);
    }
    // The dated version is what tells a reader which text applied when.
    expect(text).toMatch(/Version \d+\.\d+ — \d{1,2} [A-Z][a-z]+ \d{4}/);
  });
});
