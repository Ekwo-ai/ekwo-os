import { readFileSync, readdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { validateXML } from 'xmllint-wasm';
import { VERIFIED_VERSIONS, readCamt053 } from '../src/index.js';

/**
 * The published schemas, and what they say of the files this package is
 * tested on.
 *
 * A brick that writes proves its output against the schema. A brick that reads
 * has to prove its **input**: a reader tested on files its author imagined
 * proves it can read its author's imagination. So every fixture here is held
 * against the schema ISO publishes for its version before anything is read out
 * of it — and the schemas under `xsd/` are the published files, unmodified
 * (`xsd/README.md` says where each came from, and when).
 */

const here = dirname(fileURLToPath(import.meta.url));
const fixture = (name: string): string => readFileSync(join(here, 'fixtures', name), 'utf8');

export async function validate(xml: string, version: string): Promise<string[]> {
  const fileName = `camt.053.001.${version}.xsd`;
  const result = await validateXML({
    xml: [{ fileName: 'statement.xml', contents: xml }],
    schema: [{ fileName, contents: readFileSync(join(here, 'xsd', fileName)) }],
  });
  return result.errors.map((error) => error.message);
}

describe('against the schemas ISO 20022 publishes', () => {
  it('has a schema for every version it calls verified, and no other', () => {
    const published = readdirSync(join(here, 'xsd'))
      .filter((name) => name.endsWith('.xsd'))
      .map((name) => /^camt\.053\.001\.([0-9]{2})\.xsd$/.exec(name)?.[1])
      .sort();
    expect(published).toEqual([...VERIFIED_VERSIONS].sort());
  });

  it.each(VERIFIED_VERSIONS)('the golden statement is a valid camt.053.001.%s', async (version) => {
    expect(await validate(fixture(`golden.camt.053.001.${version}.xml`), version)).toEqual([]);
  });

  it.each(['other-account.camt.053.001.08.xml', 'two-statements.camt.053.001.02.xml'])(
    '%s is valid',
    async (name) => {
      const version = /001\.([0-9]{2})\.xml$/.exec(name)?.[1] as string;
      expect(await validate(fixture(name), version)).toEqual([]);
    },
  );

  it('does not notice a statement that does not add up — which is why the reader has to', async () => {
    const wrong = fixture('golden.camt.053.001.08.xml').replace('1562.36', '1562.35');
    expect(await validate(wrong, '08')).toEqual([]);
    const { statements, violations } = readCamt053(wrong);
    expect(statements[0]?.balanced).toBe(false);
    expect(violations.map((violation) => violation.code)).toEqual(['balance_mismatch']);
  });

  it('refuses what the reader reports: each violation is put back in a file and the schema agrees', async () => {
    const golden = fixture('golden.camt.053.001.08.xml');
    const broken: Array<[string, string, string]> = [
      ['invalid_direction', '<CdtDbtInd>DBIT</CdtDbtInd>\n        <Sts><Cd>BOOK</Cd></Sts>\n        <BookgDt><Dt>2026-03-10', '<CdtDbtInd>OUT</CdtDbtInd>\n        <Sts><Cd>BOOK</Cd></Sts>\n        <BookgDt><Dt>2026-03-10'],
      ['invalid_amount', '<Amt Ccy="EUR">12.40</Amt>', '<Amt Ccy="EUR">12,40</Amt>'],
      ['invalid_date', '<BookgDt><Dt>2026-03-10</Dt>', '<BookgDt><Dt>2026-02-30</Dt>'],
    ];
    for (const [code, from, to] of broken) {
      const file = golden.replace(from, to);
      expect(file, code).not.toBe(golden);
      expect(await validate(file, '08'), code).not.toEqual([]);
      expect(readCamt053(file).violations.map((violation) => violation.code), code).toContain(code);
    }
  });
});
