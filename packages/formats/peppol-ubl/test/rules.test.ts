import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';

/**
 * The rules this package names, against the rules that are published.
 *
 * A violation is named by the identifier of the rule it re-reads. That is only
 * worth something if the identifier exists, is a fatal rule and not a warning,
 * and if the re-reading was ever compared with the original. The three are
 * checked here, from the source of `src/rules.ts` itself: a rule added there
 * and never played against the Schematron fails this file.
 */

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const source = readFileSync(join(root, 'src', 'rules.ts'), 'utf8');
const schematron = readFileSync(join(root, 'test', 'codelist', 'CEN-EN16931-UBL.sch'), 'utf8');
const recorded = JSON.parse(readFileSync(join(root, 'test', 'fixtures', 'verdicts.json'), 'utf8')) as {
  verdicts: Record<string, { fatal: string[] }>;
};

/** Every published identifier `src/rules.ts` can report. */
function named(): string[] {
  const out = new Set<string>();
  for (const match of source.matchAll(/'((?:BR|UBL|PEPPOL)-[A-Z0-9-]+)'/g)) out.add(match[1] as string);
  // The numbered families: `BR-${family}-08` stands for one rule per category.
  const families = [...source.matchAll(/^\s+([A-Z]+): '([A-Z]+)',$/gm)].map((match) => match[2] as string);
  expect(families).toEqual(['S', 'Z', 'E', 'AE', 'IC', 'G', 'O']);
  for (const match of source.matchAll(/`BR-\$\{family\}-(\d+)`/g)) {
    for (const family of families) out.add(`BR-${family}-${match[1]}`);
  }
  return [...out].sort();
}

const published = new Map(
  [...schematron.matchAll(/<assert id="([^"]+)" flag="([^"]+)"/g)].map((match) => [match[1] as string, match[2] as string]),
);

describe('the rules that are named', () => {
  it('are as many as the README says, on as many files as it says', () => {
    // A number in prose is the first thing to go stale.
    const readme = readFileSync(join(root, 'README.md'), 'utf8');
    expect(readme).toContain(`The rules re-read here, ${named().length} of them:`);
    expect(readme).toContain(`every one of the ${named().length} rules`);
    expect(readme).toContain(`against the ${Object.keys(recorded.verdicts).length} files`);
  });

  it('are many enough to be worth the word', () => {
    expect(named().length).toBeGreaterThan(100);
  });

  it('exist in the Schematron of EN 16931, as fatal rules, where that is where they are from', () => {
    const wrong = named()
      .filter((code) => !code.startsWith('PEPPOL-'))
      .filter((code) => published.get(code) !== 'fatal');
    expect(wrong).toEqual([]);
  });

  it('were each reported by the published Schematron on at least one committed file', () => {
    // This is what covers the Peppol rules, whose Schematron is not in this
    // repository: an identifier that does not exist is never in a verdict.
    const reported = new Set(Object.values(recorded.verdicts).flatMap((verdict) => verdict.fatal));
    expect(named().filter((code) => !reported.has(code))).toEqual([]);
  });

  it('are the only rules the Schematron ever reported on those files', () => {
    const reported = new Set(Object.values(recorded.verdicts).flatMap((verdict) => verdict.fatal));
    const known = new Set(named());
    expect([...reported].filter((code) => !known.has(code))).toEqual([]);
  });
});
