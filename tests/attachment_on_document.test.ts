/**
 * An invoice or a receipt is the piece of its document.
 *
 * `20261018102431` refuses a file on an entry that a document posted: the
 * entry is the ledger side of the document, and the same piece kept on both
 * is two copies in two places. The caller is told which document to attach
 * to. An entry that no document posted keeps its own pieces, and a document
 * takes its file as it always has.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, freshDatabase, one } from './helpers/db.js';
import { newCompany, newContact, newDocument, newUser } from './helpers/factory.js';
import { packWhere, roleOf } from './helpers/packs.js';

let db: PGlite;
let companyId: string;
let accountant: string;
let documentId: string;
let postedEntry: string;
let manualEntry: string;

beforeAll(async () => {
  const pack = packWhere('has a purchase account', (p) => typeof p.manifest.defaults.roles['purchase'] === 'string');
  db = await freshDatabase();
  ({ companyId } = await newCompany(db, { country: pack.manifest.country, name: 'Pieces' }));
  accountant = await newUser(db, 'accountant@pieces.test');
  await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'accountant')`, [companyId, accountant]);
  const supplier = await newContact(db, companyId, { type: 'supplier', country: pack.manifest.country });

  documentId = await newDocument(db, companyId, {
    docType: 'purchase_invoice',
    number: 'SUP-1',
    contactId: supplier,
    lines: [{ name: 'Hosting', unitPrice: 100, accountCode: roleOf(pack, 'purchase') }],
  });
  await asUser(db, accountant, () => db.query(`select post_document($1)`, [documentId]));
  postedEntry = (await one<{ entry_id: string }>(db, `select entry_id from documents where id = $1`, [documentId])).entry_id;

  manualEntry = (await one<{ id: string }>(
    db,
    `insert into entries (company_id, journal_id, entry_date, description, state)
     select $1, journal_id, entry_date, 'Keyed by hand', 'draft' from entries where id = $2 returning id`,
    [companyId, postedEntry],
  )).id;
}, 180_000);

afterAll(async () => {
  await db.close();
});

const attach = (entityType: string, entityId: string) =>
  asUser(db, accountant, () =>
    db.query(
      `insert into attachments (company_id, entity_type, entity_id, file_name, storage_path)
       values ($1, $2, $3, 'receipt.pdf', 'pieces/receipt.pdf')`,
      [companyId, entityType, entityId],
    ),
  );

describe('a piece goes on its document', () => {
  it('a document takes its receipt', async () => {
    await expect(attach('document', documentId)).resolves.toBeDefined();
  });

  it('the entry a document posted refuses it, and names the document', async () => {
    await expect(attach('entry', postedEntry)).rejects.toThrow(
      new RegExp(`^attachment_belongs_on_document: entry ${postedEntry} was posted by document ${documentId}`),
    );
  });

  it('a file cannot be moved onto that entry either', async () => {
    const row = await one<{ id: string }>(
      db,
      `select id from attachments where entity_type = 'document' and entity_id = $1 limit 1`,
      [documentId],
    );
    await expect(
      asUser(db, accountant, () =>
        db.query(`update attachments set entity_type = 'entry', entity_id = $2 where id = $1`, [row.id, postedEntry]),
      ),
    ).rejects.toThrow(/^attachment_belongs_on_document/);
  });

  it('an entry no document posted keeps its own piece', async () => {
    await expect(attach('entry', manualEntry)).resolves.toBeDefined();
  });
});
