import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { validateXML } from 'xmllint-wasm';
import { XAF_NAMESPACES, readXaf, type XafVersion } from '../src/index.js';

/**
 * The published schemas, and what they say of the files this package is
 * tested on. A reader tested on files its author imagined proves it can read
 * its author's imagination: every fixture is held against the schema of its
 * version before anything is read out of it. `xsd/README.md` says where each
 * schema came from.
 */

const here = dirname(fileURLToPath(import.meta.url));
const fixture = (name: string): string => readFileSync(join(here, 'fixtures', name), 'utf8');

const FIXTURES: Record<XafVersion, string> = { '3.2': 'books.v32.xaf', '4.0': 'books.v4.xaf' };

async function validate(xml: string, version: XafVersion): Promise<string[]> {
  const fileName = `XmlAuditfileFinancieel${version}.xsd`;
  const result = await validateXML({
    xml: [{ fileName: 'books.xaf', contents: xml }],
    schema: [{ fileName, contents: readFileSync(join(here, 'xsd', fileName)) }],
  });
  return result.errors.map((error) => error.message);
}

describe('against the schemas the tax administration publishes', () => {
  it.each(Object.keys(XAF_NAMESPACES) as XafVersion[])('the fixture of version %s is valid', async (version) => {
    expect(await validate(fixture(FIXTURES[version]), version)).toEqual([]);
  });

  it('does not notice a file whose totals disagree with its lines — which is why the reader has to', async () => {
    const wrong = fixture(FIXTURES['4.0']).replace('<totalDebit>2512.00</totalDebit>', '<totalDebit>2511.00</totalDebit>');
    expect(await validate(wrong, '4.0')).toEqual([]);
    expect(readXaf(wrong).violations.map((violation) => violation.rule)).toEqual(['total_debit']);
  });
});
