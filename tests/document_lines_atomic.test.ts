/**
 * The lines of a draft change in one statement.
 *
 * Replacing them was a delete, then an insert: when the database refused the
 * insert, the draft was left with no line at all. Creating a document was the
 * header, then the lines: a refused line left an empty draft behind. Both are
 * one function of the schema now, and a refusal changes nothing.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { writeTools, type Backend } from '../packages/mcp/src/index.js';
import { freshDatabase } from './helpers/db.js';
import { newCompany, type Fixture } from './helpers/factory.js';
import { backendFor, list, record } from './mcp/helpers.js';

let db: PGlite;
let fx: Fixture;
let backend: Backend;
let customerId: string;

const line = (name: string, discount = '0') => ({
  name,
  unit_price: '100.00',
  discount_percent: discount,
  account_code: '704000',
  tax_code: 'BE-S-21',
});

async function linesOf(documentId: string): Promise<{ name: string; sequence: number }[]> {
  const result = await db.query<{ name: string; sequence: number }>(
    `select name, sequence from document_lines where document_id = $1 order by sequence`,
    [documentId],
  );
  return result.rows;
}

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db, { country: 'BE', name: 'Lignes SRL' });
  backend = backendFor(db, fx.ownerId);
  const created = record(
    await writeTools.createContact(backend, {
      company_id: fx.companyId,
      name: 'Client Lignes',
      contact_type: 'customer',
      country: 'BE',
    }),
  );
  customerId = String(record(created['contact'])['id']);
});

afterAll(async () => {
  await db.close();
});

describe('replacing the lines of a draft', () => {
  let documentId: string;

  beforeAll(async () => {
    const created = record(
      await writeTools.createDocument(backend, {
        company_id: fx.companyId,
        doc_type: 'sale_invoice',
        contact_id: customerId,
        document_date: '2026-06-15',
        lines: [line('First'), line('Second')],
      }),
    );
    documentId = String(record(created['document'])['id']);
  });

  it('replaces every line, numbered in the order given', async () => {
    const updated = record(
      await writeTools.updateDocumentLines(backend, {
        document_id: documentId,
        lines: [line('One'), line('Two'), line('Three')],
      }),
    );
    expect(list(updated['lines'])).toHaveLength(3);
    expect(await linesOf(documentId)).toEqual([
      { name: 'One', sequence: 10 },
      { name: 'Two', sequence: 20 },
      { name: 'Three', sequence: 30 },
    ]);
  });

  it('leaves the lines it had when the database refuses one of the new ones', async () => {
    const before = await linesOf(documentId);
    await expect(
      writeTools.updateDocumentLines(backend, {
        document_id: documentId,
        lines: [line('Fine'), line('Free', '100')],
      }),
    ).rejects.toThrow(/document_lines_discount_range/);
    expect(await linesOf(documentId)).toEqual(before);
    expect(before).toHaveLength(3);
  });

  it('refuses a document that is no longer a draft', async () => {
    const created = record(
      await writeTools.createDocument(backend, {
        company_id: fx.companyId,
        doc_type: 'sale_invoice',
        contact_id: customerId,
        document_date: '2026-06-15',
        lines: [line('Posted')],
      }),
    );
    const postedId = String(record(created['document'])['id']);
    await writeTools.postDocument(backend, { document_id: postedId });
    await expect(
      writeTools.updateDocumentLines(backend, {
        document_id: postedId,
        lines: [line('Late')],
      }),
    ).rejects.toThrow(/document_not_draft/);
    expect(await linesOf(postedId)).toEqual([{ name: 'Posted', sequence: 10 }]);
  });
});

describe('creating a document', () => {
  it('creates nothing when the database refuses one of its lines', async () => {
    const count = async () =>
      (
        await db.query<{ n: number }>(`select count(*)::int as n from documents where company_id = $1`, [
          fx.companyId,
        ])
      ).rows[0]?.n;
    const before = await count();
    await expect(
      writeTools.createDocument(backend, {
        company_id: fx.companyId,
        doc_type: 'sale_invoice',
        contact_id: customerId,
        document_date: '2026-06-15',
        client_ref: 'refused-line',
        lines: [line('Fine'), line('Free', '100')],
      }),
    ).rejects.toThrow(/document_lines_discount_range/);
    expect(await count()).toBe(before);
  });
});
