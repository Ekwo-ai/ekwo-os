/**
 * An agent posts in the mode its company chose.
 *
 * In `review`, the default, a document an agent proposes is posted only once a
 * person approved that draft as it stands; in `autopilot` the agent posts
 * directly, and the trail says so. The rule is the database's, so the MCP
 * server — which marks its transactions as an agent's — and a machine key on
 * the API meet the same answer, and a person signed in posts as before.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { writeTools, readTools, type Backend } from '../packages/mcp/src/index.js';
import { approveDocument, setPostingMode } from '../packages/core/src/index.js';
import { asUser, freshDatabase, one } from './helpers/db.js';
import { newCompany, type Fixture } from './helpers/factory.js';
import { backendFor, record } from './mcp/helpers.js';

let db: PGlite;
let fx: Fixture;
let person: Backend;
let agent: Backend;
let keySecret: string;
let customerId: string;

const line = (name: string, price = '100.00') => ({
  name,
  unit_price: price,
  account_code: '704000',
  tax_code: 'BE-S-21',
});

async function draft(name: string): Promise<string> {
  const created = record(
    await writeTools.createDocument(agent, {
      company_id: fx.companyId,
      doc_type: 'sale_invoice',
      contact_id: customerId,
      document_date: '2026-06-15',
      lines: [line(name)],
    }),
  );
  return String(record(created['document'])['id']);
}

async function stateOf(documentId: string): Promise<string> {
  return (await one<{ state: string }>(db, `select state::text from documents where id = $1`, [documentId])).state;
}

/** What the trail says an agent's posting of this document was. */
async function postedByAgent(documentId: string): Promise<Record<string, unknown> | undefined> {
  const result = await db.query<{ new_values: Record<string, unknown> }>(
    `select new_values from audit_log
      where table_name = 'documents' and record_id = $1 and action = 'document_posted_by_agent'`,
    [documentId],
  );
  return result.rows[0]?.new_values;
}

/** post_document as a machine key on the API: no person, the key presented. */
async function postWithKey(documentId: string): Promise<string | null> {
  try {
    await db.transaction(async (tx) => {
      await tx.query(`select set_config('ekwo.installing', '', true)`);
      await tx.exec('set local role authenticated');
      await tx.query(`select * from use_api_key($1)`, [keySecret]);
      await tx.query(`select post_document($1)`, [documentId]);
    });
    return null;
  } catch (error) {
    return (error as Error).message;
  }
}

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db, { country: 'BE', name: 'Mode SRL' });
  person = backendFor(db, fx.ownerId);
  agent = backendFor(db, fx.ownerId, { agent: true });
  keySecret = (
    await asUser(db, fx.ownerId, () =>
      one<{ secret: string }>(db, `select * from create_api_key($1, 'Agent', $2::jsonb)`, [
        fx.companyId,
        JSON.stringify(['documents.read', 'documents.write', 'documents.post', 'entries.read', 'entries.write', 'entries.post', 'contacts.read', 'settings.read', 'company.write']),
      ]),
    )
  ).secret;
  const created = record(
    await writeTools.createContact(person, {
      company_id: fx.companyId,
      name: 'Client Mode',
      contact_type: 'customer',
      country: 'BE',
    }),
  );
  customerId = String(record(created['contact'])['id']);
});

afterAll(async () => {
  await db.close();
});

describe('in review, the default', () => {
  it('is the mode of a new company', async () => {
    const company = record(record(await readTools.getCompany(agent, { company_id: fx.companyId }))['company']);
    expect(company['posting_mode']).toBe('review');
  });

  it('refuses an agent a draft nobody approved, and leaves it a draft', async () => {
    const id = await draft('Unapproved');
    await expect(writeTools.postDocument(agent, { document_id: id })).rejects.toThrow(/approval_required/);
    expect(await stateOf(id)).toBe('draft');
  });

  it('lets an agent rehearse the posting, to show the entry before the approval', async () => {
    const id = await draft('Rehearsed');
    const rehearsed = record(await writeTools.postDocument(agent, { document_id: id, dry_run: true }));
    expect(rehearsed['dry_run']).toBe(true);
    expect(await stateOf(id)).toBe('draft');
  });

  it('posts what a person approved, and the trail names the approval', async () => {
    const id = await draft('Approved');
    const approval = record(await approveDocument(person, { document_id: id }));
    await writeTools.postDocument(agent, { document_id: id });
    expect(await stateOf(id)).toBe('posted');
    expect(await postedByAgent(id)).toMatchObject({
      posting_mode: 'review',
      version: approval['version'],
      approved_by: fx.ownerId,
    });
  });

  it('refuses a draft changed after its approval, until it is approved again', async () => {
    const id = await draft('Changed');
    await approveDocument(person, { document_id: id });
    await writeTools.updateDocumentLines(agent, { document_id: id, lines: [line('Changed', '900.00')] });
    await expect(writeTools.postDocument(agent, { document_id: id })).rejects.toThrow(/approval_required/);
    expect(await stateOf(id)).toBe('draft');

    await approveDocument(person, { document_id: id });
    await writeTools.postDocument(agent, { document_id: id });
    expect(await stateOf(id)).toBe('posted');
  });

  it('holds a machine key on the API to the same rule', async () => {
    const id = await draft('By key');
    expect(await postWithKey(id)).toMatch(/approval_required/);
    await approveDocument(person, { document_id: id });
    expect(await postWithKey(id)).toBeNull();
    expect(await postedByAgent(id)).toMatchObject({ posting_mode: 'review' });
  });

  it('lets a person signed in post without an approval, as before', async () => {
    const id = await draft('By hand');
    await writeTools.postDocument(person, { document_id: id });
    expect(await stateOf(id)).toBe('posted');
    expect(await postedByAgent(id)).toBeUndefined();
  });

  it('refuses an agent the approval, and the choice of the mode', async () => {
    const id = await draft('Self-approved');
    await expect(approveDocument(agent, { document_id: id })).rejects.toThrow(/approval_by_a_person/);
    await expect(
      setPostingMode(agent, { company_id: fx.companyId, posting_mode: 'autopilot' }),
    ).rejects.toThrow(/posting_mode_by_a_person/);
    const message = await (async () => {
      try {
        await db.transaction(async (tx) => {
          await tx.query(`select set_config('ekwo.installing', '', true)`);
          await tx.exec('set local role authenticated');
          await tx.query(`select * from use_api_key($1)`, [keySecret]);
          await tx.query(`update companies set posting_mode = 'autopilot' where id = $1`, [fx.companyId]);
        });
        return null;
      } catch (error) {
        return (error as Error).message;
      }
    })();
    expect(message).toMatch(/posting_mode_by_a_person/);
  });
});

describe('in autopilot', () => {
  beforeAll(async () => {
    await setPostingMode(person, { company_id: fx.companyId, posting_mode: 'autopilot' });
  });

  it('lets the agent post directly, and records that it did so in autopilot', async () => {
    const id = await draft('Autopilot');
    await writeTools.postDocument(agent, { document_id: id });
    expect(await stateOf(id)).toBe('posted');
    const trail = await postedByAgent(id);
    expect(trail).toMatchObject({ posting_mode: 'autopilot' });
    expect(trail?.['approved_by']).toBeUndefined();
  });

  it('lets a machine key post directly too', async () => {
    const id = await draft('Autopilot by key');
    expect(await postWithKey(id)).toBeNull();
    expect(await postedByAgent(id)).toMatchObject({ posting_mode: 'autopilot' });
  });

  it('records the choice of the mode on the trail', async () => {
    const change = await one<{ actor_id: string; new_values: Record<string, unknown> }>(
      db,
      `select actor_id, new_values from audit_log
        where table_name = 'companies' and record_id = $1 and new_values ? 'posting_mode'
          and new_values ->> 'posting_mode' = 'autopilot'
        order by id desc limit 1`,
      [fx.companyId],
    );
    expect(change.actor_id).toBe(fx.ownerId);
  });
});
