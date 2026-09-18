import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { generatePeppolUbl } from '../src/index.js';
import { CASES } from './fixtures/cases.js';

/**
 * The files, pinned.
 *
 * Each case of `fixtures/cases.ts` has its output committed beside it, and this
 * test refuses a generator that no longer writes those bytes. That is not a
 * snapshot for its own sake: the committed files are the ones the published
 * Schematron was played against (`fixtures/verdicts.json`, and the README for
 * how), so a verdict recorded there is a verdict on what this package writes
 * only for as long as the two are the same file.
 *
 * `UPDATE_FIXTURES=1 npx vitest run` rewrites them — after which the verdicts
 * are stale and `scripts/play-schematron.mjs` has to be run again.
 */

const here = join(dirname(fileURLToPath(import.meta.url)), 'fixtures');
const update = process.env['UPDATE_FIXTURES'] === '1';

describe('the committed files are what the generator writes', () => {
  for (const each of CASES) {
    it(each.name, () => {
      const { file } = generatePeppolUbl(each.input, each.options);
      const path = join(here, `${each.name}.xml`);
      if (update || !existsSync(path)) writeFileSync(path, file);
      expect(file).toBe(readFileSync(path, 'utf8'));
    });
  }

  it('has a case for every file, and a file for every case', () => {
    expect(new Set(CASES.map((each) => each.name)).size).toBe(CASES.length);
  });
});
