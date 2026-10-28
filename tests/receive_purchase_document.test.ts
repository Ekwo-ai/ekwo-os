/**
 * A purchase document sent from a phone arrives as a draft purchase.
 *
 * `20261028152338` gives the phone one call, `receive_purchase_document()`:
 * one draft purchase with no contact and no line, its pages as attachments
 * of the document, every path under `<company>/inbox/<reference>/`, images
 * and PDF only, `documents.write` asked first, and the reference the key that
 * makes a second call return the same draft. A draft may wait for its
 * contact; a document that leaves draft names one.
 *
 * Where the installation has Supabase Storage the same file creates the
 * bucket `attachments` and who may write there. PGlite has no Storage, so the
 * last part builds the two tables Storage reads, runs the migration again on
 * them — which is also the proof that it can run twice — and writes as a
 * member and as a stranger.
 */

import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, freshDatabase, one, repoRoot } from './helpers/db.js';
import { newCompany, newContact, newUser } from './helpers/factory.js';
import { packWhere, roleOf } from './helpers/packs.js';

const MIGRATION = join(repoRoot, 'supabase', 'migrations', '20261028152338_a_purchase_arrives_from_the_phone.sql');

let db: PGlite;
let companyId: string;
let otherCompanyId: string;
let owner: string;
let viewer: string;
let stranger: string;
let purchaseAccount: string;
let country: string;

interface Page {
  storage_path: string;
  file_name?: string;
  mime_type?: string;
  byte_size?: number | null;
}

const pages = (reference: string, company = companyId, names = ['ekwo-p1of2.jpg', 'ekwo-p2of2.jpg']): Page[] =>
  names.map((name) => ({
    storage_path: `${company}/inbox/${reference}/${name}`,
    file_name: name,
    mime_type: name.endsWith('.pdf') ? 'application/pdf' : 'image/jpeg',
    byte_size: 1234,
  }));

const receive = (user: string, reference: string, files: unknown, company = companyId, takenAt = '2026-10-28T14:30:05Z') =>
  asUser(db, user, async () =>
    (
      await one<{ id: string }>(
        db,
        `select receive_purchase_document($1, $2, $3::timestamptz, $4::jsonb) as id`,
        [company, reference, takenAt, JSON.stringify(files)],
      )
    ).id,
  );

const refusal = async (promise: Promise<unknown>): Promise<{ code: string; message: string }> => {
  try {
    await promise;
  } catch (error: unknown) {
    const e = error as { code?: string; message?: string };
    return { code: e.code ?? '', message: e.message ?? '' };
  }
  throw new Error('expected a refusal');
};

beforeAll(async () => {
  const pack = packWhere('has a purchase account', (p) => typeof p.manifest.defaults.roles['purchase'] === 'string');
  country = pack.manifest.country;
  purchaseAccount = roleOf(pack, 'purchase');
  db = await freshDatabase();
  owner = await newUser(db, 'owner@inbox.test');
  viewer = await newUser(db, 'viewer@inbox.test');
  stranger = await newUser(db, 'stranger@inbox.test');
  ({ companyId } = await newCompany(db, { country, name: 'Inbox', ownerId: owner }));
  ({ companyId: otherCompanyId } = await newCompany(db, { country, name: 'Elsewhere', ownerId: stranger }));
  await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'viewer')`, [companyId, viewer]);
}, 180_000);

afterAll(async () => {
  await db.close();
});

describe('receive_purchase_document()', () => {
  it('writes one draft purchase with no contact and no amount, and its pages in the order sent', async () => {
    const id = await receive(owner, 'phone-1', pages('phone-1'));
    const document = await one<Record<string, unknown>>(
      db,
      `select d.doc_type, d.state, d.contact_id, d.client_ref, d.document_date::text as day,
              d.currency_code = c.currency_code as company_currency, d.amount_total::text as total,
              (select count(*)::int from document_lines l where l.document_id = d.id) as lines
         from documents d join companies c on c.id = d.company_id where d.id = $1`,
      [id],
    );
    expect(document).toEqual({
      doc_type: 'purchase_invoice',
      state: 'draft',
      contact_id: null,
      client_ref: 'phone-1',
      day: '2026-10-28',
      company_currency: true,
      total: '0.00',
      lines: 0,
    });
    const files = await db.query<{ file_name: string; mime_type: string; byte_size: number; uploaded_by: string }>(
      `select file_name, mime_type, byte_size::int as byte_size, uploaded_by::text from attachments
        where entity_type = 'document' and entity_id = $1 order by created_at, id`,
      [id],
    );
    expect(files.rows).toEqual([
      { file_name: 'ekwo-p1of2.jpg', mime_type: 'image/jpeg', byte_size: 1234, uploaded_by: owner },
      { file_name: 'ekwo-p2of2.jpg', mime_type: 'image/jpeg', byte_size: 1234, uploaded_by: owner },
    ]);
  });

  it('dates the draft in the time zone the person set', async () => {
    await db.query(`insert into user_preferences (user_id, timezone) values ($1, 'Pacific/Auckland')
                    on conflict (user_id) do update set timezone = excluded.timezone`, [owner]);
    // 12:00 UTC on the 28th is already the 29th in Auckland.
    const id = await receive(owner, 'phone-tz', pages('phone-tz', companyId, ['a.pdf']), companyId, '2026-10-28T12:00:00Z');
    expect((await one<{ day: string }>(db, `select document_date::text as day from documents where id = $1`, [id])).day).toBe('2026-10-29');
    await db.query(`delete from user_preferences where user_id = $1`, [owner]);
  });

  it('returns the same draft a second time, and adds only the pages it did not hold', async () => {
    const first = await receive(owner, 'phone-2', pages('phone-2', companyId, ['p1.jpg']));
    const again = await receive(owner, 'phone-2', pages('phone-2', companyId, ['p1.jpg', 'p2.png']));
    expect(again).toBe(first);
    const held = await db.query<{ file_name: string }>(
      `select file_name from attachments where entity_id = $1 order by created_at, id`,
      [first],
    );
    expect(held.rows.map((row) => row.file_name)).toEqual(['p1.jpg', 'p2.png']);
    expect(
      (await one<{ n: number }>(db, `select count(*)::int as n from documents where company_id = $1 and client_ref = 'phone-2'`, [companyId])).n,
    ).toBe(1);
  });

  it('refuses a path outside the inbox of the reference, by name, and writes nothing', async () => {
    const outside = [
      `${companyId}/inbox/another/p1.jpg`,
      `${otherCompanyId}/inbox/phone-3/p1.jpg`,
      `${companyId}/document/phone-3/p1.jpg`,
      `${companyId}/inbox/phone-3/`,
      `${companyId}/inbox/phone-3/../phone-1/p1.jpg`,
    ];
    for (const path of outside) {
      const { code, message } = await refusal(receive(owner, 'phone-3', [{ storage_path: path, file_name: 'p1.jpg', mime_type: 'image/jpeg' }]));
      expect(code).toBe('22023');
      expect(message).toMatch(/^inbox_path_outside: /);
    }
    expect(
      (await one<{ n: number }>(db, `select count(*)::int as n from documents where client_ref = 'phone-3'`)).n,
    ).toBe(0);
  });

  it('takes images and PDF only', async () => {
    const { code, message } = await refusal(
      receive(owner, 'phone-4', [{ storage_path: `${companyId}/inbox/phone-4/notes.txt`, file_name: 'notes.txt', mime_type: 'text/plain' }]),
    );
    expect(code).toBe('22023');
    expect(message).toMatch(/^inbox_file_type: page 1 is text\/plain/);
  });

  it('refuses an empty list of pages and a reference with a slash', async () => {
    expect((await refusal(receive(owner, 'phone-5', []))).message).toMatch(/^inbox_no_files: /);
    expect((await refusal(receive(owner, 'a/b', pages('a/b')))).message).toMatch(/^inbox_reference_invalid: /);
  });

  it('refuses 42501 to a member who may not write a draft, and to a stranger', async () => {
    const asViewer = await refusal(receive(viewer, 'phone-6', pages('phone-6')));
    expect(asViewer.code).toBe('42501');
    expect(asViewer.message).toMatch(/^not_allowed: /);
    const asStranger = await refusal(receive(stranger, 'phone-6', pages('phone-6')));
    expect(['42501', 'P0002']).toContain(asStranger.code);
  });

  it('refuses a reference another kind of document carries', async () => {
    const customer = await newContact(db, companyId, { type: 'customer', country });
    await db.query(
      `insert into documents (company_id, doc_type, contact_id, document_date, currency_code, client_ref)
       select $1, 'sale_invoice', $2, current_date, currency_code, 'phone-7' from companies where id = $1`,
      [companyId, customer],
    );
    expect((await refusal(receive(owner, 'phone-7', pages('phone-7')))).message).toMatch(/^inbox_reference_taken: /);
  });
});

describe('a draft may wait for its contact, and nothing after it does', () => {
  it('refuses to post a draft that names no contact, by name', async () => {
    const id = await receive(owner, 'phone-8', pages('phone-8'));
    const { message } = await refusal(
      asUser(db, owner, async () => {
        await db.query(
          `select replace_document_lines($1, jsonb_build_array(jsonb_build_object(
             'name', 'Taxi', 'quantity', 1, 'unit_price', 20,
             'account_id', (select id from accounts where company_id = $2 and code = $3))))`,
          [id, companyId, purchaseAccount],
        );
        await db.query(`select post_document($1)`, [id]);
      }),
    );
    expect(message).toMatch(/^document_without_contact: phone-8 names no contact yet/);
    await expect(db.query(`update documents set state = 'posted', number = 'X-1' where id = $1`, [id])).rejects.toThrow(
      /^document_without_contact: /,
    );
  });

  it('becomes an ordinary purchase once read: a supplier, a line, posted', async () => {
    const id = await receive(owner, 'phone-9', pages('phone-9'));
    const supplier = await newContact(db, companyId, { type: 'supplier', country });
    await asUser(db, owner, async () => {
      await db.query(`update documents set contact_id = $2, supplier_reference = 'R-9' where id = $1`, [id, supplier]);
      await db.query(
        `select replace_document_lines($1, jsonb_build_array(jsonb_build_object(
           'name', 'Taxi', 'quantity', 1, 'unit_price', 20,
           'account_id', (select id from accounts where company_id = $2 and code = $3))))`,
        [id, companyId, purchaseAccount],
      );
      await db.query(`select post_document($1)`, [id]);
    });
    const posted = await one<{ state: string; pages: number }>(
      db,
      `select state::text, (select count(*)::int from attachments where entity_id = d.id) as pages from documents d where id = $1`,
      [id],
    );
    expect(posted).toEqual({ state: 'posted', pages: 2 });
  });
});

describe('the bucket attachments, where the installation has Storage', () => {
  beforeAll(async () => {
    await db.exec(`
      create schema storage;
      create table storage.buckets (id text primary key, name text not null, public boolean not null default false);
      create table storage.objects (
        id uuid primary key default gen_random_uuid(),
        bucket_id text references storage.buckets(id),
        name text not null,
        owner uuid default auth.uid(),
        unique (bucket_id, name)
      );
      alter table storage.objects enable row level security;
      grant usage on schema storage to authenticated;
      grant select, insert, delete on storage.objects to authenticated;
    `);
    await db.exec(await readFile(MIGRATION, 'utf8'));
  });

  const upload = (user: string, name: string) =>
    asUser(db, user, () => db.query(`insert into storage.objects (bucket_id, name) values ('attachments', $1)`, [name]));

  it('creates the private bucket once, whatever the number of runs', async () => {
    await db.exec(await readFile(MIGRATION, 'utf8'));
    expect((await db.query(`select id, public from storage.buckets`)).rows).toEqual([{ id: 'attachments', public: false }]);
  });

  it('lets a member who writes drafts upload under the inbox of the company, and nobody else', async () => {
    await expect(upload(owner, `${companyId}/inbox/phone-10/p1.jpg`)).resolves.toBeDefined();
    await expect(upload(viewer, `${companyId}/inbox/phone-10/p2.jpg`)).rejects.toThrow(/row-level security/);
    await expect(upload(stranger, `${companyId}/inbox/phone-10/p3.jpg`)).rejects.toThrow(/row-level security/);
    await expect(upload(owner, `not-a-company/inbox/phone-10/p4.jpg`)).rejects.toThrow(/row-level security/);
    await expect(upload(owner, `${otherCompanyId}/inbox/phone-10/p5.jpg`)).rejects.toThrow(/row-level security/);
  });

  it('lets the members of the company read the file, and not a stranger', async () => {
    const seen = (user: string) =>
      asUser(db, user, async () => (await db.query(`select name from storage.objects where bucket_id = 'attachments'`)).rows.length);
    expect(await seen(viewer)).toBe(1);
    expect(await seen(stranger)).toBe(0);
  });

  it('asks that every page announced is in the bucket', async () => {
    const id = await receive(owner, 'phone-10', [
      { storage_path: `${companyId}/inbox/phone-10/p1.jpg`, file_name: 'p1.jpg', mime_type: 'image/jpeg' },
    ]);
    expect(id).toMatch(/^[0-9a-f-]{36}$/);
    const { message } = await refusal(
      receive(owner, 'phone-10', [{ storage_path: `${companyId}/inbox/phone-10/never.jpg`, file_name: 'never.jpg', mime_type: 'image/jpeg' }]),
    );
    expect(message).toMatch(/^inbox_file_missing: page 1 /);
  });
});
