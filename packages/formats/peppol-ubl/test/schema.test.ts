import { readFileSync, readdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { validateXML } from 'xmllint-wasm';
import { generatePeppolUbl } from '../src/index.js';
import { CASES } from './fixtures/cases.js';

/**
 * The published schema, and what it says of the files this package writes.
 *
 * The files under `xsd/` are the UBL 2.1 schemas OASIS publishes, unmodified —
 * see `xsd/README.md` for where they came from and when. They are read here and
 * nowhere else: the package ships none of them and depends on nothing.
 *
 * Every case is validated, the wrong ones too. A document that breaks a
 * business rule is still a UBL document: the rule it breaks is in `violations`
 * and the file beside it is one a validator can open and say the same of. What
 * would not be UBL at all is refused before a file exists.
 */

const here = join(dirname(fileURLToPath(import.meta.url)), 'xsd');
const common = readdirSync(join(here, 'common'))
  .filter((name) => name.endsWith('.xsd'))
  .map((name) => ({ fileName: `common/${name}`, contents: readFileSync(join(here, 'common', name), 'utf8') }));

async function validate(xml: string): Promise<{ valid: boolean; errors: string[] }> {
  const main = xml.includes('<CreditNote ') ? 'UBL-CreditNote-2.1.xsd' : 'UBL-Invoice-2.1.xsd';
  const result = await validateXML({
    xml: [{ fileName: 'document.xml', contents: xml }],
    // The schemas import each other by relative path, so they are laid out as
    // OASIS lays them out: `maindoc/` beside `common/`.
    schema: [{ fileName: `maindoc/${main}`, contents: readFileSync(join(here, 'maindoc', main), 'utf8') }],
    preload: common,
  });
  return { valid: result.valid, errors: result.errors.map((error) => error.message) };
}

describe('against the UBL 2.1 schema OASIS publishes', () => {
  for (const each of CASES) {
    it(`${each.name} is a UBL document`, async () => {
      const { file } = generatePeppolUbl(each.input, each.options);
      expect(await validate(file)).toEqual({ valid: true, errors: [] });
    });
  }

  it('covers both schemas', () => {
    const roots = new Set(CASES.map((each) => each.input.header.doc_type));
    expect(roots).toEqual(new Set(['sale_invoice', 'sale_credit_note']));
  });

  it('is a validator that refuses: an element out of order, an amount without a currency, a date that is not one', async () => {
    // Without this, every test above could pass against a validator that
    // resolves no import and checks nothing.
    const { file } = generatePeppolUbl(CASES[0]!.input, CASES[0]!.options);
    const swapped = file.replace(
      /(<cbc:IssueDate>[^<]*<\/cbc:IssueDate>)\s*(<cbc:DueDate>[^<]*<\/cbc:DueDate>)/,
      '$2$1',
    );
    expect(swapped).not.toBe(file);
    expect((await validate(swapped)).valid).toBe(false);
    expect((await validate(file.replace(' currencyID="EUR"', ''))).valid).toBe(false);
    expect((await validate(file.replace('>2026-03-02<', '>2 March 2026<'))).valid).toBe(false);
  });

  it('refuses, in a credit note, the order of an invoice', async () => {
    // The two schemas are not one schema with a word replaced: a credit note
    // puts its tax point date before its type code and its note after.
    const credit = CASES.find((each) => each.name === 'credit-note')!;
    const { file } = generatePeppolUbl(credit.input, credit.options);
    const asInvoice = file.replace(
      /(<cbc:TaxPointDate>[^<]*<\/cbc:TaxPointDate>)\s*(<cbc:CreditNoteTypeCode>[^<]*<\/cbc:CreditNoteTypeCode>)/,
      '$2$1',
    );
    expect(asInvoice).not.toBe(file);
    expect((await validate(asInvoice)).valid).toBe(false);
  });
});
