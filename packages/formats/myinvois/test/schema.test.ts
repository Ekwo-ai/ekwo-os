import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { validateXML } from 'xmllint-wasm';
import { MYINVOIS, type MyInvoisInput } from '../src/index.js';
import { creditNote, invoice, selfBilled } from './fixtures.js';

/**
 * The published schema, and what it says of the XML this package writes.
 *
 * The UBL 2.1 schemas OASIS publishes are kept once in this repository, by
 * the Peppol brick, under `packages/formats/peppol-ubl/test/xsd/` — see the
 * README there for where they came from and when. They are read from there,
 * not copied: the package ships none of them, and outside the repository this
 * test has nothing to read and is skipped.
 *
 * MyInvois writes every document under the root `Invoice`, a credit note as
 * much as an invoice, so only the Invoice schema is used.
 */

const xsd = join(dirname(fileURLToPath(import.meta.url)), '..', '..', 'peppol-ubl', 'test', 'xsd');
const inRepository = existsSync(join(xsd, 'maindoc', 'UBL-Invoice-2.1.xsd'));

async function validate(xml: string): Promise<{ valid: boolean; errors: string[] }> {
  const common = readdirSync(join(xsd, 'common'))
    .filter((name) => name.endsWith('.xsd'))
    .map((name) => ({ fileName: `common/${name}`, contents: readFileSync(join(xsd, 'common', name), 'utf8') }));
  const result = await validateXML({
    xml: [{ fileName: 'document.xml', contents: xml }],
    schema: [{ fileName: 'maindoc/UBL-Invoice-2.1.xsd', contents: readFileSync(join(xsd, 'maindoc', 'UBL-Invoice-2.1.xsd'), 'utf8') }],
    preload: common,
  });
  return { valid: result.valid, errors: result.errors.map((error) => error.message) };
}

const CASES: [string, MyInvoisInput][] = [
  ['an invoice', invoice({ paymentMode: '03', header: { ...invoice().header, payee_iban: '1234567890123', payment_reference: 'BILL-1' } })],
  ['an invoice in another currency', invoice({ header: { ...invoice().header, currency_code: 'USD' }, exchangeRate: '4.72' })],
  ['a credit note', creditNote()],
  ['a self-billed invoice', selfBilled()],
  ['a line with a discount', invoice({
    header: { ...invoice().header, amount_untaxed: '1700.00', amount_tax: '170.00', amount_total: '1870.00' },
    lines: [{ ...(invoice().lines[1] as object), discount_percent: '15', amount_untaxed: '1700.00' }],
    taxes: [{ ...(invoice().taxes[0] as object), base_amount: '1700.00', tax_charged: '170.00' }],
  })],
];

describe.runIf(inRepository)('against the UBL 2.1 schema OASIS publishes', () => {
  it("holds LHDNM's own XML sample, signature and all: the schema is the one MyInvois reads", async () => {
    const published = readFileSync(join(dirname(fileURLToPath(import.meta.url)), 'fixtures', 'sdk', '1.1-Invoice-Sample.xml'), 'utf8');
    expect(await validate(published)).toEqual({ valid: true, errors: [] });
  });

  for (const [name, input] of CASES) {
    it(`${name} is a UBL document`, async () => {
      const written = MYINVOIS.write(input, 'xml');
      expect(written.violations).toEqual([]);
      expect(await validate(written.content)).toEqual({ valid: true, errors: [] });
    });
  }

  it('is a validator that refuses an element out of order', async () => {
    // Without this, every test above could pass against a validator that
    // resolves no import and checks nothing.
    const { content } = MYINVOIS.write(invoice(), 'xml');
    const swapped = content.replace(
      /(<cbc:IssueDate>[^<]*<\/cbc:IssueDate>)\s*(<cbc:IssueTime>[^<]*<\/cbc:IssueTime>)/,
      '$2$1',
    );
    expect(swapped).not.toBe(content);
    expect((await validate(swapped)).valid).toBe(false);
  });
});
