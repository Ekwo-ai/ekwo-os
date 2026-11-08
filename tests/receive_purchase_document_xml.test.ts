/**
 * An electronic invoice received arrives by the same door as a page sent
 * from a phone.
 *
 * `20261108120000` lets `receive_purchase_document()` take an XML page — the
 * file of an electronic invoice an access point received — beside images and
 * PDF, and nothing else: the same draft with no contact and no line, the
 * same idempotency on the reference, the same refusal of any other type,
 * now saying « images, PDF and XML ». The server that brings such a file
 * holds a machine key of the company with `documents.write`, presented to
 * PostgREST in `x-ekwo-api-key`, so the door is also walked through with one.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, freshDatabase, one } from './helpers/db.js';
import { newCompany, newUser } from './helpers/factory.js';

let db: PGlite;
let companyId: string;
let owner: string;

const xmlPage = (reference: string, mimeType = 'application/xml') => [
  {
    storage_path: `${companyId}/inbox/${reference}/${reference}.xml`,
    file_name: `${reference}.xml`,
    mime_type: mimeType,
    byte_size: 4096,
  },
];

const call = (reference: string, files: unknown) =>
  one<{ id: string }>(db, `select receive_purchase_document($1, $2, $3::timestamptz, $4::jsonb) as id`, [
    companyId,
    reference,
    '2026-11-08T09:15:00Z',
    JSON.stringify(files),
  ]);

const refusal = async (promise: Promise<unknown>): Promise<{ code: string; message: string }> => {
  try {
    await promise;
  } catch (error: unknown) {
    const e = error as { code?: string; message?: string };
    return { code: e.code ?? '', message: e.message ?? '' };
  }
  throw new Error('expected a refusal');
};

/** One request as PostgREST makes it for a machine key: `anon`, the key in its header, `ekwo_pre_request()` first. */
async function withKey<T>(secret: string, fn: () => Promise<T>): Promise<T> {
  await db.exec(`
    select set_config('request.jwt.claims', '', false);
    select set_config('ekwo.installing', '', false);
  `);
  await db.query('begin');
  await db.exec(`set local role anon;`);
  await db.query(`select set_config('request.headers', $1, true)`, [JSON.stringify({ 'x-ekwo-api-key': secret })]);
  try {
    await db.query(`select ekwo_pre_request()`);
    return await fn();
  } finally {
    await db.query('commit');
    await db.exec(`
      reset role;
      select set_config('request.headers', '', false);
      select set_config('ekwo.installing', 'on', false);
    `);
  }
}

beforeAll(async () => {
  db = await freshDatabase();
  owner = await newUser(db, 'owner@einvoice-inbox.test');
  ({ companyId } = await newCompany(db, { name: 'Einvoice inbox', ownerId: owner }));
}, 180_000);

afterAll(async () => {
  await db.close();
});

describe('receive_purchase_document() takes the XML file of an electronic invoice', () => {
  it('writes one draft purchase with no contact, its XML page attached', async () => {
    const { id } = await asUser(db, owner, () => call('einv-1', xmlPage('einv-1')));
    const document = await one<Record<string, unknown>>(
      db,
      `select doc_type, state::text, contact_id, client_ref from documents where id = $1`,
      [id],
    );
    expect(document).toEqual({ doc_type: 'purchase_invoice', state: 'draft', contact_id: null, client_ref: 'einv-1' });
    const pages = await db.query<{ file_name: string; mime_type: string; storage_path: string }>(
      `select file_name, mime_type, storage_path from attachments where entity_type = 'document' and entity_id = $1`,
      [id],
    );
    expect(pages.rows).toEqual([
      { file_name: 'einv-1.xml', mime_type: 'application/xml', storage_path: `${companyId}/inbox/einv-1/einv-1.xml` },
    ]);
  });

  it('takes text/xml as well, the other name of the same type', async () => {
    const { id } = await asUser(db, owner, () => call('einv-2', xmlPage('einv-2', 'text/xml')));
    expect(id).toMatch(/^[0-9a-f-]{36}$/);
  });

  it('is the same draft the second time, and the page is not held twice', async () => {
    const first = await asUser(db, owner, () => call('einv-3', xmlPage('einv-3')));
    const again = await asUser(db, owner, () => call('einv-3', xmlPage('einv-3')));
    expect(again.id).toBe(first.id);
    const held = await one<{ n: number }>(db, `select count(*)::int as n from attachments where entity_id = $1`, [first.id]);
    expect(held.n).toBe(1);
  });

  it('still refuses any other type, saying what it takes', async () => {
    const { code, message } = await refusal(
      asUser(db, owner, () =>
        call('einv-4', [{ storage_path: `${companyId}/inbox/einv-4/notes.json`, file_name: 'notes.json', mime_type: 'application/json' }]),
      ),
    );
    expect(code).toBe('22023');
    expect(message).toBe('inbox_file_type: page 1 is application/json, and the inbox takes images, PDF and XML');
  });

  it('opens to a machine key of the company that holds documents.write', async () => {
    const { secret } = await asUser(db, owner, () =>
      one<{ secret: string }>(db, `select * from create_api_key($1, $2, $3::jsonb, null)`, [
        companyId,
        'Electronic invoices received',
        JSON.stringify(['documents.read', 'documents.write']),
      ]),
    );
    const { id } = await withKey(secret, () => call('einv-5', xmlPage('einv-5')));
    const again = await withKey(secret, () => call('einv-5', xmlPage('einv-5')));
    expect(again.id).toBe(id);
    expect((await one<{ n: number }>(db, `select count(*)::int as n from documents where client_ref = 'einv-5'`)).n).toBe(1);
  });

  it('stays shut to a machine key that only reads', async () => {
    const { secret } = await asUser(db, owner, () =>
      one<{ secret: string }>(db, `select * from create_api_key($1, $2, $3::jsonb, null)`, [
        companyId,
        'Reads only',
        JSON.stringify(['documents.read']),
      ]),
    );
    const { code, message } = await refusal(withKey(secret, () => call('einv-6', xmlPage('einv-6'))));
    expect(code).toBe('42501');
    expect(message).toMatch(/^not_allowed: /);
  });
});
