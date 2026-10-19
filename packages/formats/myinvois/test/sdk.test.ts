import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { MYINVOIS, NAMESPACES, type MyInvoisInput } from '../src/index.js';
import { V1_UUID, creditNote, invoice, selfBilled } from './fixtures.js';

/**
 * The documents this package writes, against LHDNM's own samples.
 *
 * The samples under `fixtures/sdk/` are the JSON files the SDK publishes for
 * each document type, kept as published (`fixtures/sdk/README.md`). LHDNM
 * says of them that they are guidance and not to be relied on — their
 * figures do not add up, and every optional field is filled with something —
 * so they are not compared value for value. What is compared is the shape:
 * every element and attribute this package writes is one the sample of the
 * same type writes, at the same path, with a value of the same JSON type.
 * A name misspelt, a level missing, a decimal written as a string: each fails
 * here.
 */

const samples = join(dirname(fileURLToPath(import.meta.url)), 'fixtures', 'sdk');
const sample = (file: string) => JSON.parse(readFileSync(join(samples, file), 'utf8'));

/** Every path of a UBL JSON document, with the JSON type of what is there. */
function shape(node: unknown, path = '', out = new Map<string, string>()): Map<string, string> {
  if (Array.isArray(node)) {
    for (const item of node) shape(item, path, out);
  } else if (node !== null && typeof node === 'object') {
    for (const [key, value] of Object.entries(node)) {
      if (key === '_') out.set(path, typeof value);
      else if (typeof value === 'string' && !Array.isArray(value)) out.set(`${path}@${key}`, 'string');
      else shape(value, `${path}/${key}`, out);
    }
  }
  return out;
}

const adjusting = { adjusts: [{ number: 'INV-2026-0001', uuid: V1_UUID }] };

const CASES: [string, string, MyInvoisInput][] = [
  ['an invoice', '1.1-Invoice-Sample.json', invoice({ version: '1.1', paymentMode: '03', header: { ...invoice().header, payee_iban: '1234567890123', payment_reference: 'BILL-1' } })],
  ['an invoice in version 1.0', '1.0-Invoice-Sample.json', invoice()],
  ['a credit note', '1.1-Credit-Note-Sample.json', creditNote({ version: '1.1' })],
  ['a debit note', '1.1-Debit-Note-Sample.json', invoice({ version: '1.1', kind: 'debit-note', ...adjusting })],
  ['a refund note', '1.1-Refund-Note-Sample.json', creditNote({ version: '1.1', kind: 'refund-note' })],
  ['a self-billed invoice', '1.1-Self-Billed-Invoice-Sample.json', selfBilled({ version: '1.1' })],
  ['a self-billed credit note', '1.1-Self-Billed-Credit-Sample.json', selfBilled({ version: '1.1', header: { ...selfBilled().header, doc_type: 'purchase_credit_note' }, ...adjusting })],
];

describe("the shape of LHDNM's samples", () => {
  for (const [name, file, input] of CASES) {
    it(`${name} writes only what ${file} writes`, () => {
      const published = sample(file);
      const written = MYINVOIS.write(input);
      expect(written.violations).toEqual([]);
      const ours = JSON.parse(written.content);
      expect([ours._D, ours._A, ours._B]).toEqual([published._D, published._A, published._B]);
      expect([NAMESPACES.Invoice, NAMESPACES.cac, NAMESPACES.cbc]).toEqual([published._D, published._A, published._B]);
      expect(ours.Invoice[0].InvoiceTypeCode).toEqual([{ _: written.typeCode, listVersionID: input.version }]);
      expect(published.Invoice[0].InvoiceTypeCode[0]._).toBe(written.typeCode);

      const theirs = shape(published);
      const unknown = [...shape(ours)].filter(([path, type]) => theirs.get(path) !== type).map(([path, type]) => `${path}: ${type} (sample: ${theirs.get(path) ?? 'absent'})`);
      expect(unknown).toEqual([]);
    });
  }
});
