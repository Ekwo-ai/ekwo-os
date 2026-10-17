import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { validateXML } from 'xmllint-wasm';
import { VERIFACTU, type FiscalRecordInput } from '../src/index.js';
import { CREDIT_NOTE, INVOICE, STANDARD, alta, withTax } from './fixtures.js';

/**
 * The published schema, and what it says of the records this package writes.
 *
 * The files under `xsd/` are the AEAT's `SuministroInformacion.xsd` and
 * `SuministroLR.xsd`, and the W3C's `xmldsig-core-schema.xsd` they import,
 * unmodified — see `xsd/README.md` for where they came from and when. The
 * AEAT's schema imports the W3C's by its URL; the one change is made here, in
 * memory, to point that import at the copy beside it, so the test runs
 * without a network. A record is a global element of `SuministroInformacion.xsd`
 * and is validated against it alone.
 *
 * A record that breaks no rule is valid. A record whose violations name a
 * value the books do not hold leaves that value out, and the schema refuses it
 * too: the last test says so, so that nobody takes the violations for
 * warnings.
 */

const here = join(dirname(fileURLToPath(import.meta.url)), 'xsd');
const DSIG_URL = 'http://www.w3.org/TR/xmldsig-core/xmldsig-core-schema.xsd';
const schema = readFileSync(join(here, 'SuministroInformacion.xsd'), 'utf8').replace(
  `schemaLocation="${DSIG_URL}"`,
  'schemaLocation="xmldsig-core-schema.xsd"',
);
const dsig = readFileSync(join(here, 'xmldsig-core-schema.xsd'), 'utf8');

async function validate(xml: string): Promise<{ valid: boolean; errors: string[] }> {
  const result = await validateXML({
    xml: [{ fileName: 'record.xml', contents: xml }],
    schema: [{ fileName: 'SuministroInformacion.xsd', contents: schema }],
    preload: [{ fileName: 'xmldsig-core-schema.xsd', contents: dsig }],
  });
  return { valid: result.valid, errors: result.errors.map((error) => error.message) };
}

const PREVIOUS = { taxId: '89890001K', series: '', number: 'F2026-0000', issuedOn: '2026-03-01', hash: 'A'.repeat(64) };
const tax = (fields: Record<string, string | null>) => withTax({ tax_code: 'T', tax_rate: '0', base_amount: '100.00', tax_charged: '0.00', ...fields });

const CASES: Array<[string, FiscalRecordInput]> = [
  ['a first record', alta()],
  ['a chained record', alta({ previous: PREVIOUS })],
  ['a cancellation', alta({ kind: 'anulacion', previous: PREVIOUS })],
  ['a first cancellation', alta({ kind: 'anulacion' })],
  ['a credit note', alta({ header: CREDIT_NOTE, generatedAt: '2026-03-20T16:00:00+01:00', taxes: [{ ...STANDARD, base_amount: '200.00', tax_charged: '42.00' }] })],
  ['a simplified invoice', alta({ header: { ...INVOICE, buyer_vat_number: null } })],
  ['a buyer of another Member State', alta({ header: { ...INVOICE, buyer_vat_number: 'DE123456789', buyer_country: 'DE' } })],
  ['a date of operation', alta({ header: { ...INVOICE, tax_point_date: '2026-02-27' } })],
  ['a zero rate', tax({ vat_category: 'Z' })],
  ['a reverse charge', tax({ vat_category: 'AE', exemption_code: 'VATEX-EU-AE' })],
  ['an exemption', tax({ vat_category: 'E', exemption_code: 'VATEX-EU-132' })],
  ['an export', tax({ vat_category: 'G', exemption_code: 'VATEX-EU-G' })],
  ['a supply to another Member State', tax({ vat_category: 'K', exemption_code: 'VATEX-EU-IC', aeat_qualification: 'E5' })],
  ['an operation outside the scope', tax({ vat_category: 'O', exemption_code: 'VATEX-EU-O', aeat_qualification: 'N2' })],
  ['a hundred million', withTax({ ...STANDARD, base_amount: '90000000.00', tax_charged: '18900000.00' })],
  ['a text to escape', alta({ header: { ...INVOICE, seller_legal_name: 'Ejemplo & Hijos <SL>', note: 'Precio "cerrado"' } })],
];

describe('against SuministroInformacion.xsd, as the AEAT publishes it', () => {
  it.each(CASES)('%s is a record, and breaks no rule', async (_, input) => {
    const written = VERIFACTU.write(input);
    expect(written.violations).toEqual([]);
    expect(await validate(written.content)).toEqual({ valid: true, errors: [] });
  });

  it('refuses, like the violations, a record missing what the books do not hold', async () => {
    const written = VERIFACTU.write(alta({ header: { ...CREDIT_NOTE, rectification_type: null }, generatedAt: '2026-03-20T16:00:00+01:00' }));
    expect(written.violations.map((each) => each.code)).toContain('input:rectification_type');
    expect((await validate(written.content)).valid).toBe(false);
  });
});
