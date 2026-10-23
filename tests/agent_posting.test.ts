/**
 * An agent posts in the mode its company chose, or its session chose.
 *
 * `companies.agent_posting` is a setting of the company: in `review`, the
 * default, a document an agent proposes is posted only once a person approved
 * that draft as it stands, unless the person started the agent's session in
 * autopilot; in `autopilot` the agent posts directly; in `review_only` no
 * session may opt into autopilot. The rule is the database's, so the MCP
 * server — which marks its transactions as an agent's, with its session's
 * choice — and a machine key on the API meet the same answer, and a person
 * signed in posts as before.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import {
  postingSummary,
  readTools,
  sessionPostingFlag,
  sessionPostingFrom,
  writeTools,
  type Backend,
} from '../packages/mcp/src/index.js';
import { approveDocument, setAgentPosting, type AgentPosting } from '../packages/core/src/index.js';
import { asUser, freshDatabase, one } from './helpers/db.js';
import { newCompany, newUser, type Fixture } from './helpers/factory.js';
import { backendFor, record } from './mcp/helpers.js';

let db: PGlite;
let fx: Fixture;
let person: Backend;
let agent: Backend;
let autopilotSession: Backend;
let reviewSession: Backend;
let accountant: Backend;
let keySecret: string;
let keyId: string;
let customerId: string;

const line = (name: string, price = '100.00') => ({
  name,
  unit_price: price,
  account_code: '704000',
  tax_code: 'BE-S-21',
});

async function draft(name: string): Promise<string> {
  const created = record(
    await writeTools.createDocument(person, {
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

/** What the trail says an agent's posting of this document was, and with which key. */
async function postedByAgent(
  documentId: string,
): Promise<{ new_values: Record<string, unknown>; api_key_id: string | null } | undefined> {
  const result = await db.query<{ new_values: Record<string, unknown>; api_key_id: string | null }>(
    `select new_values, api_key_id from audit_log
      where table_name = 'documents' and record_id = $1 and action = 'document_posted_by_agent'`,
    [documentId],
  );
  return result.rows[0];
}

/** The setting, as the owner sets it in their settings. */
async function setting(value: AgentPosting): Promise<void> {
  await setAgentPosting(person, { company_id: fx.companyId, agent_posting: value });
}

/**
 * A statement as a machine key on the API: no person, the key presented, and
 * the mark X-Ekwo-Agent carries when the program holding it chose a mode.
 */
async function withKey(sql: string, params: unknown[], mark?: 'autopilot' | 'review'): Promise<string | null> {
  try {
    await db.transaction(async (tx) => {
      await tx.query(`select set_config('ekwo.installing', '', true)`);
      if (mark !== undefined) await tx.query(`select set_config('ekwo.agent', $1, true)`, [mark]);
      await tx.exec('set local role authenticated');
      await tx.query(`select * from use_api_key($1)`, [keySecret]);
      await tx.query(sql, params);
    });
    return null;
  } catch (error) {
    return (error as Error).message;
  }
}

const postWithKey = (documentId: string, mark?: 'autopilot' | 'review') =>
  withKey(`select post_document($1)`, [documentId], mark);

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db, { country: 'BE', name: 'Mode SRL' });
  person = backendFor(db, fx.ownerId);
  agent = backendFor(db, fx.ownerId, { agent: { id: 'session-default' } });
  autopilotSession = backendFor(db, fx.ownerId, { agent: { posting: 'autopilot', id: 'session-autopilot' } });
  reviewSession = backendFor(db, fx.ownerId, { agent: { posting: 'review', id: 'session-review' } });

  const accountantId = await newUser(db);
  await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'accountant')`, [
    fx.companyId,
    accountantId,
  ]);
  accountant = backendFor(db, accountantId);

  const key = await asUser(db, fx.ownerId, () =>
    one<{ secret: string; api_key_id: string }>(db, `select * from create_api_key($1, 'Agent', $2::jsonb)`, [
      fx.companyId,
      JSON.stringify(['documents.read', 'documents.write', 'documents.post', 'entries.read', 'entries.write', 'entries.post', 'contacts.read', 'settings.read', 'company.write']),
    ]),
  );
  keySecret = key.secret;
  keyId = key.api_key_id;

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

describe('the setting', () => {
  it('is review for a new company, and read with the rest of the company', async () => {
    const company = record(record(await readTools.getCompany(agent, { company_id: fx.companyId }))['company']);
    expect(company['agent_posting']).toBe('review');
  });

  it('is changed by whoever may write the company, and the change is on the trail', async () => {
    await setting('autopilot');
    const change = await one<{ actor_id: string; new_values: Record<string, unknown> }>(
      db,
      `select actor_id, new_values from audit_log
        where table_name = 'companies' and record_id = $1 and new_values ->> 'agent_posting' = 'autopilot'
        order by id desc limit 1`,
      [fx.companyId],
    );
    expect(change.actor_id).toBe(fx.ownerId);
    await setting('review');
  });

  it('is refused to a member without company.write, and stays as it was', async () => {
    await expect(
      setAgentPosting(accountant, { company_id: fx.companyId, agent_posting: 'autopilot' }),
    ).rejects.toThrow(/company\.write/);
    const company = await one<{ agent_posting: string }>(db, `select agent_posting from companies where id = $1`, [fx.companyId]);
    expect(company.agent_posting).toBe('review');
  });

  it('is made stricter by an agent when asked, never looser', async () => {
    await writeTools.updateCompanyProfile(agent, { company_id: fx.companyId, agent_posting: 'review_only' });
    await expect(
      writeTools.updateCompanyProfile(agent, { company_id: fx.companyId, agent_posting: 'review' }),
    ).rejects.toThrow(/agent_posting_by_a_person/);
    await expect(
      withKey(`update companies set agent_posting = 'autopilot' where id = $1`, [fx.companyId]),
    ).resolves.toMatch(/agent_posting_by_a_person/);
    await setting('review');
  });
});

describe('in review, the default', () => {
  beforeEach(async () => {
    await setting('review');
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

  it('posts what a person approved, and the trail names the approval and the session', async () => {
    const id = await draft('Approved');
    const approval = record(await approveDocument(person, { document_id: id }));
    await writeTools.postDocument(agent, { document_id: id });
    expect(await stateOf(id)).toBe('posted');
    expect((await postedByAgent(id))?.new_values).toMatchObject({
      posting_mode: 'review',
      agent_posting: 'review',
      session: 'session-default',
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
    expect(await postedByAgent(id)).toMatchObject({ new_values: { posting_mode: 'review' }, api_key_id: keyId });
  });

  it('lets a person signed in post without an approval, as before', async () => {
    const id = await draft('By hand');
    await writeTools.postDocument(person, { document_id: id });
    expect(await stateOf(id)).toBe('posted');
    expect(await postedByAgent(id)).toBeUndefined();
  });

  it('refuses an agent the approval', async () => {
    const id = await draft('Self-approved');
    await expect(approveDocument(agent, { document_id: id })).rejects.toThrow(/approval_by_a_person/);
  });

  it('lets a session the person started in autopilot post directly, and the trail says so', async () => {
    const id = await draft('Session autopilot');
    await writeTools.postDocument(autopilotSession, { document_id: id });
    expect(await stateOf(id)).toBe('posted');
    const trail = await postedByAgent(id);
    expect(trail?.new_values).toMatchObject({
      posting_mode: 'autopilot',
      agent_posting: 'review',
      session: 'session-autopilot',
    });
    expect(trail?.new_values['approved_by']).toBeUndefined();
  });

  it('lets a key whose program chose autopilot post directly, with the key on the trail', async () => {
    const id = await draft('Key autopilot');
    expect(await postWithKey(id, 'autopilot')).toBeNull();
    expect(await postedByAgent(id)).toMatchObject({ new_values: { posting_mode: 'autopilot' }, api_key_id: keyId });
  });
});

describe('in autopilot', () => {
  beforeEach(async () => {
    await setting('autopilot');
  });

  it('lets the agent post directly, and records that it did so in autopilot', async () => {
    const id = await draft('Autopilot');
    await writeTools.postDocument(agent, { document_id: id });
    expect(await stateOf(id)).toBe('posted');
    expect((await postedByAgent(id))?.new_values).toMatchObject({ posting_mode: 'autopilot', agent_posting: 'autopilot' });
  });

  it('lets a machine key post directly too', async () => {
    const id = await draft('Autopilot by key');
    expect(await postWithKey(id)).toBeNull();
    expect(await postedByAgent(id)).toMatchObject({ new_values: { posting_mode: 'autopilot' }, api_key_id: keyId });
  });

  it('still holds a session the person started in review to an approval', async () => {
    const id = await draft('Session review');
    await expect(writeTools.postDocument(reviewSession, { document_id: id })).rejects.toThrow(/approval_required/);
  });
});

describe('in review only', () => {
  beforeEach(async () => {
    await setting('review_only');
  });

  it('refuses a session in autopilot by name, approved or not', async () => {
    const id = await draft('Forbidden');
    await expect(writeTools.postDocument(autopilotSession, { document_id: id })).rejects.toThrow(/autopilot_forbidden/);
    await approveDocument(person, { document_id: id });
    await expect(writeTools.postDocument(autopilotSession, { document_id: id })).rejects.toThrow(/autopilot_forbidden/);
    expect(await postWithKey(id, 'autopilot')).toMatch(/autopilot_forbidden/);
    expect(await stateOf(id)).toBe('draft');
  });

  it('posts what a person approved, for a session that did not ask for autopilot', async () => {
    const id = await draft('Review only');
    await expect(writeTools.postDocument(agent, { document_id: id })).rejects.toThrow(/approval_required/);
    await approveDocument(person, { document_id: id });
    await writeTools.postDocument(agent, { document_id: id });
    expect((await postedByAgent(id))?.new_values).toMatchObject({ posting_mode: 'review', agent_posting: 'review_only' });
  });
});

describe('what the session says of itself', () => {
  it('says in status how the session posts, and what that means in each company', async () => {
    await setting('review_only');
    const status = record(await readTools.status(autopilotSession));
    expect(record(status['posting'])).toMatchObject({ mode: 'autopilot', session_id: 'session-autopilot' });
    const companies = status['companies'] as Record<string, unknown>[];
    expect(companies.find((company) => company['id'] === fx.companyId)).toMatchObject({
      agent_posting: 'review_only',
      posting_mode: 'autopilot_forbidden',
    });

    await setting('review');
    const byCompany = record(await readTools.status(agent));
    expect(record(byCompany['posting'])['mode']).toBeNull();
    expect((byCompany['companies'] as Record<string, unknown>[])[0]).toMatchObject({ posting_mode: 'review' });
  });

  it('says it at start-up, naming the companies that refuse autopilot', async () => {
    await setting('review_only');
    expect(await postingSummary(autopilotSession)).toMatch(/AUTOPILOT.*refused in Mode SRL/);
    expect(await postingSummary(reviewSession)).toMatch(/in review in this session/);
    expect(await postingSummary(agent)).toMatch(/each company's agent_posting/);
    await setting('review');
  });

  it('is chosen by --autopilot or --review, or by EKWO_AGENT_POSTING', () => {
    expect(sessionPostingFlag(['--autopilot'])).toBe('autopilot');
    expect(sessionPostingFlag(['--review'])).toBe('review');
    expect(sessionPostingFlag([])).toBeUndefined();
    expect(() => sessionPostingFlag(['--autopilot', '--review'])).toThrow(/conflicting_arguments/);
    expect(sessionPostingFrom({ EKWO_AGENT_POSTING: 'autopilot' })).toBe('autopilot');
    expect(sessionPostingFrom({})).toBeUndefined();
    expect(() => sessionPostingFrom({ EKWO_AGENT_POSTING: 'yolo' })).toThrow(/bad_agent_posting/);
  });
});
