/**
 * A key writes as the person who issued it.
 *
 * A machine key is not a session: `auth.uid()` is null for it, so every write
 * that took its author from `auth.uid()` used to record nobody. Since
 * `20261007041207` the author is `acting_user()` — the signed-in user, or the
 * person who issued the key presented — and decision 0064 says why.
 *
 * Three claims, one group each. A write through a key is recorded against
 * the person who issued it, with the key beside them. A key withdrawn writes
 * nothing, whatever its issuer may still do. And the attribution never widens
 * the key: a key without `documents.write` cannot create a document, even
 * when the person behind it could.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newUser } from './helpers/factory.js';

let db: PGlite;
let companyId: string;
let issuerId: string;
let incomeAccount: string;

interface IssuedKey {
  api_key_id: string;
  secret: string;
}

/**
 * What a key needs to write a contact and an invoice and to post it. Posting a
 * document writes its entry and draws its number as the caller, so it asks
 * for `entries.write` and `entries.post` beside `documents.post` — of a key
 * exactly as of a person.
 */
const WRITER = [
  'contacts.read',
  'contacts.write',
  'documents.read',
  'documents.write',
  'documents.post',
  'entries.write',
  'entries.post',
];

async function issue(as: string | null, name: string, capabilities: string[]): Promise<IssuedKey> {
  const sql = `select * from create_api_key($1, $2, $3::jsonb, null)`;
  const params = [companyId, name, JSON.stringify(capabilities)];
  // `null` is the installation itself: this connection is the installer.
  if (as === null) return one<IssuedKey>(db, sql, params);
  return asUser(db, as, () => one<IssuedKey>(db, sql, params));
}

/** What a machine holding a key does, inside one transaction. */
async function withKey<T>(secret: string, fn: () => Promise<T>): Promise<T> {
  await db.exec(`set role authenticated;`);
  await db.query(`begin`);
  try {
    await db.query(`select * from use_api_key($1)`, [secret]);
    const result = await fn();
    await db.query(`commit`);
    return result;
  } catch (error) {
    await db.query(`rollback`);
    throw error;
  } finally {
    await db.exec(`reset role;`);
  }
}

/** A draft invoice of one line, written by whoever the connection is. */
async function draftInvoice(contactId: string): Promise<string> {
  const doc = await one<{ id: string }>(
    db,
    `insert into documents (company_id, doc_type, contact_id, document_date)
     values ($1, 'sale_invoice', $2, '2026-06-15') returning id`,
    [companyId, contactId],
  );
  await db.query(
    `insert into document_lines (document_id, company_id, sequence, name, quantity, unit_price, account_id)
     values ($1, $2, 10, 'Advice', 1, 1000, account_id_by_code($2, $3))`,
    [doc.id, companyId, incomeAccount],
  );
  return doc.id;
}

async function count(table: string): Promise<number> {
  const row = await one<{ n: number }>(db, `select count(*)::int as n from ${table} where company_id = $1`, [
    companyId,
  ]);
  return row.n;
}

beforeAll(async () => {
  db = await freshDatabase();
  ({ companyId } = await newCompany(db, { name: 'Delegation Ltd' }));

  // Not the owner: an accountant who may issue keys. The key is theirs.
  issuerId = await newUser(db);
  await db.query(
    `insert into company_members (company_id, user_id, role, capabilities_granted)
     values ($1, $2, 'accountant', array['members.manage'])`,
    [companyId, issuerId],
  );

  // An income account of whatever chart the pack installed: the test books
  // somewhere, and the core decides nothing by which account it is.
  incomeAccount = (
    await one<{ code: string }>(
      db,
      `select code from accounts where company_id = $1 and account_type = 'income' order by code limit 1`,
      [companyId],
    )
  ).code;
});

afterAll(async () => {
  await db.close();
});

describe('a write through a key', () => {
  it('is recorded against the person who issued the key, with the key beside them', async () => {
    const key = await issue(issuerId, 'Assistant', WRITER);

    const documentId = await withKey(key.secret, async () => {
      // A key is still not a session: the attribution is not a sign-in.
      const who = await one<{ uid: string | null; acting: string | null }>(
        db,
        `select auth.uid() as uid, acting_user() as acting`,
      );
      expect(who).toEqual({ uid: null, acting: issuerId });

      const contactId = await one<{ id: string }>(
        db,
        `insert into contacts (company_id, name, contact_type) values ($1, 'Written by a key', 'customer')
         returning id`,
        [companyId],
      );
      const id = await draftInvoice(contactId.id);
      await db.query(`select post_document($1)`, [id]);
      return id;
    });

    const posted = await one<{ actor_id: string | null; api_key_id: string | null }>(
      db,
      `select actor_id, api_key_id from audit_log
        where company_id = $1 and action = 'document_posted' and record_id = $2`,
      [companyId, documentId],
    );
    expect(posted).toEqual({ actor_id: issuerId, api_key_id: key.api_key_id });
  });

  it('fills the columns that name an author by default', async () => {
    const key = await issue(issuerId, 'Assistant with a file', WRITER);
    const contactId = await newContact(db, companyId);
    const documentId = await draftInvoice(contactId);

    const uploadedBy = await withKey(key.secret, async () =>
      one<{ uploaded_by: string | null }>(
        db,
        `insert into attachments (company_id, entity_type, entity_id, file_name, storage_path)
         values ($1, 'document', $2, 'invoice.pdf', 'files/invoice.pdf') returning uploaded_by`,
        [companyId, documentId],
      ),
    );
    expect(uploadedBy.uploaded_by).toBe(issuerId);
  });

  it('is recorded against nobody for a key the installation issued itself, as before', async () => {
    const key = await issue(null, 'Installation', WRITER);
    const acting = await withKey(key.secret, async () =>
      one<{ acting: string | null }>(db, `select acting_user() as acting`),
    );
    expect(acting.acting).toBeNull();
  });

  it('leaves a signed-in person recorded as themselves', async () => {
    const acting = await asUser(db, issuerId, async () =>
      one<{ acting: string | null }>(db, `select acting_user() as acting`),
    );
    expect(acting.acting).toBe(issuerId);
  });
});

describe('a key withdrawn', () => {
  it('writes nothing, though the person behind it still may', async () => {
    const key = await issue(issuerId, 'Withdrawn', WRITER);
    await asUser(db, issuerId, () => db.query(`select revoke_api_key($1)`, [key.api_key_id]));
    const before = await count('contacts');

    // The way a key is presented: refused before any work is done.
    const message = await expectError(db, `select * from use_api_key($1)`, [key.secret]);
    expect(message).toMatch(/api_key_revoked/);

    // And past the door, should the hash be on the transaction anyway: the
    // key holds nothing, is recorded against nobody, and the row is refused.
    const hash = (
      await one<{ key_hash: string }>(db, `select key_hash from api_keys where id = $1`, [key.api_key_id])
    ).key_hash;
    await db.exec(`set role authenticated;`);
    await db.query(`begin`);
    try {
      await db.query(`select set_config('ekwo.api_key', $1, true)`, [hash]);
      const seen = await one<{ write: boolean; acting: string | null }>(
        db,
        `select has_capability($1, 'contacts.write') as write, acting_user() as acting`,
        [companyId],
      );
      expect(seen).toEqual({ write: false, acting: null });
      const refused = await expectError(
        db,
        `insert into contacts (company_id, name, contact_type) values ($1, 'After the withdrawal', 'customer')`,
        [companyId],
      );
      expect(refused).toMatch(/row-level security|permission denied/);
    } finally {
      await db.query(`rollback`);
      await db.exec(`reset role;`);
    }

    expect(await count('contacts')).toBe(before);
  });
});

describe('the attribution', () => {
  it('never widens a key: without documents.write it creates no document, though its issuer could', async () => {
    const issuerMay = await asUser(db, issuerId, async () =>
      one<{ write: boolean }>(db, `select has_capability($1, 'documents.write') as write`, [companyId]),
    );
    expect(issuerMay.write).toBe(true);

    const key = await issue(issuerId, 'Contacts only', ['contacts.read', 'contacts.write', 'documents.read']);
    const contactId = await newContact(db, companyId);
    const before = await count('documents');

    await withKey(key.secret, async () => {
      const seen = await one<{ write: boolean; acting: string | null }>(
        db,
        `select has_capability($1, 'documents.write') as write, acting_user() as acting`,
        [companyId],
      );
      // Recorded against the issuer, and still holding only its own list.
      expect(seen).toEqual({ write: false, acting: issuerId });
    });

    await expect(withKey(key.secret, () => draftInvoice(contactId))).rejects.toThrow(
      /row-level security|permission denied|not_allowed/,
    );
    expect(await count('documents')).toBe(before);
  });

  it('never outlives what the issuer holds: a capability withdrawn from them is withdrawn from the key', async () => {
    const key = await issue(issuerId, 'Narrowed', WRITER);
    await db.query(
      `update company_members set capabilities_revoked = array['documents.write']
        where company_id = $1 and user_id = $2`,
      [companyId, issuerId],
    );
    try {
      const seen = await withKey(key.secret, async () =>
        one<{ write: boolean; acting: string | null }>(
          db,
          `select has_capability($1, 'documents.write') as write, acting_user() as acting`,
          [companyId],
        ),
      );
      expect(seen).toEqual({ write: false, acting: issuerId });
    } finally {
      await db.query(
        `update company_members set capabilities_revoked = '{}' where company_id = $1 and user_id = $2`,
        [companyId, issuerId],
      );
    }
  });
});

describe('one rule', () => {
  it('is the only place a write names its author', async () => {
    // Every function that recorded `auth.uid()` as the author of a write now
    // asks acting_user(). What may still read auth.uid() directly decides who
    // is asking, never who wrote — and one function, which demands a session.
    const SESSION_ONLY: Record<string, string> = {
      'accept_invitation(text)':
        'raises without a signed-in user: the person who accepts is the one the invitation was sent to',
    };
    const authors = await rows<{ fn: string }>(
      db,
      `select p.oid::regprocedure::text as fn
         from pg_proc p join pg_namespace n on n.oid = p.pronamespace
        where n.nspname not in ('pg_catalog', 'information_schema', 'auth')
          and p.prosrc ~ '(_by|actor_id)[^;]*auth\\.uid\\(\\)'
        order by 1`,
    );
    expect(authors.map((a) => a.fn)).toEqual(Object.keys(SESSION_ONLY).sort());

    const defaults = await rows<{ col: string }>(
      db,
      `select table_schema || '.' || table_name || '.' || column_name as col
         from information_schema.columns
        where column_default like '%auth.uid()%'`,
    );
    expect(defaults).toEqual([]);
  });
});
