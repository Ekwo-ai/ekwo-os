/**
 * The piece behind a document, recorded and read back through the tools.
 *
 * `attach_document_file` writes a row of `attachments` on the document — once
 * for the same file, recognised by its SHA-256 or, without one, by where it is
 * stored — and `list_document_files` reads the rows back. No byte goes through
 * the server. Row level security decides who records one: a viewer reads and
 * is refused the write, a stranger sees no document at all. That a piece goes
 * on the document rather than on the entry it posted is the database's, held
 * by `tests/attachment_on_document.test.ts`.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { readTools, writeTools, type Backend } from '../../packages/mcp/src/index.js';
import { freshDatabase } from '../helpers/db.js';
import { newCompany, newContact, newDocument, type Fixture } from '../helpers/factory.js';
import { roleOf, somePack } from '../helpers/packs.js';
import { backendFor, record } from './helpers.js';

const pack = somePack;
const SHA = 'a'.repeat(64);

let db: PGlite;
let fx: Fixture;
let owner: Backend;
let viewer: Backend;
let stranger: Backend;
let bill: string;

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db, { country: pack.manifest.country, name: 'Pieces SRL' });
  const supplier = await newContact(db, fx.companyId, { country: pack.manifest.country, name: 'Example Supplier' });
  bill = await newDocument(db, fx.companyId, {
    docType: 'purchase_invoice',
    contactId: supplier,
    lines: [{ name: 'Paper', unitPrice: 40, taxCode: null, accountCode: roleOf(pack, 'sales') }],
  });
  const viewerId = crypto.randomUUID();
  await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'viewer')`, [fx.companyId, viewerId]);
  owner = backendFor(db, fx.ownerId);
  viewer = backendFor(db, viewerId);
  stranger = backendFor(db, crypto.randomUUID());
}, 180_000);

afterAll(async () => {
  await db.close();
});

describe('attach_document_file and list_document_files', () => {
  it('records a file on its document once, recognised by its checksum, and lists it', async () => {
    const args = {
      document_id: bill,
      storage_path: `${fx.companyId}/bills/example-0001.pdf`,
      file_name: 'example-0001.pdf',
      mime_type: 'application/pdf',
      byte_size: 1234,
      checksum: SHA,
    };
    const first = record(await writeTools.attachDocumentFile(owner, args));
    expect(first['replayed']).toBeUndefined();
    expect(first['attachment']).toMatchObject({
      entity_type: 'document',
      entity_id: bill,
      file_name: 'example-0001.pdf',
      mime_type: 'application/pdf',
      byte_size: '1234',
      checksum: SHA,
      uploaded_by: fx.ownerId,
    });

    // The same file, moved elsewhere in the storage: the same piece.
    const again = record(await writeTools.attachDocumentFile(owner, { ...args, storage_path: 'elsewhere/example-0001.pdf' }));
    expect(again['replayed']).toBe(true);
    expect(record(again['attachment'])['id']).toBe(record(first['attachment'])['id']);

    const listed = record(await readTools.listDocumentFiles(viewer, { document_id: bill }));
    expect(listed).toMatchObject({ document_id: bill, count: 1 });
    expect((listed['attachments'] as unknown[])[0]).toMatchObject({ storage_path: args.storage_path });
  });

  it('without a checksum, recognises the same file by where it is stored', async () => {
    const args = { document_id: bill, storage_path: `${fx.companyId}/bills/scan.jpg`, file_name: 'scan.jpg' };
    const first = record(await writeTools.attachDocumentFile(owner, args));
    const again = record(await writeTools.attachDocumentFile(owner, args));
    expect(again['replayed']).toBe(true);
    expect(record(again['attachment'])['id']).toBe(record(first['attachment'])['id']);
    const listed = record(await readTools.listDocumentFiles(owner, { document_id: bill }));
    expect(listed['count']).toBe(2);
    expect((listed['attachments'] as Record<string, unknown>[]).map((a) => a['file_name'])).toEqual(['example-0001.pdf', 'scan.jpg']);
  });

  it('refuses a viewer the write, and shows a stranger no document', async () => {
    await expect(
      writeTools.attachDocumentFile(viewer, { document_id: bill, storage_path: 'x/viewer.pdf', file_name: 'viewer.pdf' }),
    ).rejects.toThrow();
    await expect(
      writeTools.attachDocumentFile(stranger, { document_id: bill, storage_path: 'x/stranger.pdf', file_name: 'stranger.pdf' }),
    ).rejects.toThrow(/not_found/);
    await expect(readTools.listDocumentFiles(stranger, { document_id: bill })).rejects.toThrow(/not_found/);
    const rows = await db.query<{ n: number }>(`select count(*)::int as n from attachments where entity_id = $1`, [bill]);
    expect(rows.rows[0]?.n).toBe(2);
  });

  it('refuses a size that is not a whole number of bytes', async () => {
    await expect(
      writeTools.attachDocumentFile(owner, { document_id: bill, storage_path: 'x/half.pdf', file_name: 'half.pdf', byte_size: 1.5 }),
    ).rejects.toThrow(/bad_value/);
  });
});
