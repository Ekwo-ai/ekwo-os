/**
 * A quote carries its answer as dated facts, and its status is derived.
 *
 * `accepted_at`, `accepted_by` and `declined_at` are facts written by one
 * function each; `quote_status()` reads the status from them and from
 * `sent_at`, `due_date` and the state, and is the one source every reader
 * asks. An agent records an answer in the mode its company chose, on the
 * posting's own rule.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import {
  QUOTE_STATUSES,
  QUOTE_STATUS_LABEL_KEYS,
  SCHEMA_FEATURES,
  acceptDocument,
  getDocument,
  listDocuments,
  quoteStatusLabel,
  undoDocumentAnswer,
} from '../packages/core/src/index.js';
import { INVOICE_LABELS } from '../packages/formats/invoice-pdf/src/index.js';
import { asUser, expectError, freshDatabase, one, rows } from './helpers/db.js';
import { backendFor, record } from './mcp/helpers.js';
import { newCompany, newContact, newDocument, type Fixture } from './helpers/factory.js';
import { somePack } from './helpers/packs.js';

let db: PGlite;
let fx: Fixture;
let customerId: string;

async function quote(options: { dueDate?: string | null; docType?: 'sale_quote' | 'purchase_order' | 'sale_invoice' } = {}): Promise<string> {
  return newDocument(db, fx.companyId, {
    docType: options.docType ?? 'sale_quote',
    contactId: customerId,
    dueDate: options.dueDate ?? null,
    lines: [],
  });
}

const statusOf = async (id: string): Promise<string | null> =>
  (await one<{ status: string | null }>(db, `select quote_status(d) as status from documents d where d.id = $1`, [id])).status;

/** A statement in a transaction marked as an agent's, as the MCP server marks it. */
async function asAgent(sql: string, params: unknown[], mark = 'yes'): Promise<string | null> {
  try {
    await db.transaction(async (tx) => {
      await tx.query(`select set_config('request.jwt.claims', $1, true)`, [
        JSON.stringify({ sub: fx.ownerId, role: 'authenticated' }),
      ]);
      await tx.query(`select set_config('ekwo.installing', '', true)`);
      await tx.query(`select set_config('ekwo.agent', $1, true)`, [mark]);
      await tx.exec('set local role authenticated');
      await tx.query(sql, params);
    });
    return null;
  } catch (error) {
    return (error as Error).message;
  }
}

beforeAll(async () => {
  db = await freshDatabase();
  const pack = somePack;
  fx = await newCompany(db, { country: pack.manifest.country });
  customerId = await newContact(db, fx.companyId, { country: pack.manifest.country });
});

afterAll(async () => {
  await db.close();
});

describe('the status of a quote, derived from its facts', () => {
  it('goes draft, sent, accepted — and declined, expired, cancelled — read by one function', async () => {
    const id = await quote();
    expect(await statusOf(id)).toBe('draft');

    await db.query(`update documents set sent_at = now() where id = $1`, [id]);
    expect(await statusOf(id)).toBe('sent');

    await asUser(db, fx.ownerId, () => db.query(`select accept_document($1, 'The buyer')`, [id]));
    expect(await statusOf(id)).toBe('accepted');
    expect(await one(db, `select accepted_by, declined_at from documents where id = $1`, [id])).toEqual({
      accepted_by: 'The buyer',
      declined_at: null,
    });

    const declined = await quote();
    await asUser(db, fx.ownerId, () => db.query(`select decline_document($1)`, [declined]));
    expect(await statusOf(declined)).toBe('declined');

    const expired = await quote({ dueDate: '2020-01-31' });
    expect(await statusOf(expired)).toBe('expired');
    await db.query(`update documents set sent_at = now() where id = $1`, [expired]);
    expect(await statusOf(expired)).toBe('expired');
    // An answer outranks the date it was valid until.
    await asUser(db, fx.ownerId, () => db.query(`select accept_document($1)`, [expired]));
    expect(await statusOf(expired)).toBe('accepted');
  });

  it('is null on a document no answer is given to', async () => {
    const invoice = await quote({ docType: 'sale_invoice' });
    expect(await statusOf(invoice)).toBeNull();
  });

  it('is the same for a list, through quote_statuses()', async () => {
    const one_ = await quote();
    const invoice = await quote({ docType: 'sale_invoice' });
    const order = await quote({ docType: 'purchase_order' });
    await asUser(db, fx.ownerId, () => db.query(`select decline_document($1)`, [order]));
    const listed = await asUser(db, fx.ownerId, () =>
      rows<{ document_id: string; quote_status: string }>(
        db,
        `select * from quote_statuses($1::uuid[]) order by quote_status`,
        [[one_, invoice, order]],
      ),
    );
    expect(listed).toEqual([
      { document_id: order, quote_status: 'declined' },
      { document_id: one_, quote_status: 'draft' },
    ]);
  });
});

describe('the facts, one function each', () => {
  it('never carries both answers, and undoing gives the quote back unanswered', async () => {
    const id = await quote();
    await asUser(db, fx.ownerId, async () => {
      await db.query(`select accept_document($1)`, [id]);
      // The same answer twice records it once.
      await db.query(`select accept_document($1)`, [id]);
      expect(await expectError(db, `select decline_document($1)`, [id])).toMatch(/^document_already_answered: /);
      await db.query(`select undo_document_answer($1)`, [id]);
      expect(await expectError(db, `select undo_document_answer($1)`, [id])).toMatch(/^document_not_answered: /);
      await db.query(`select decline_document($1)`, [id]);
    });
    expect(await statusOf(id)).toBe('declined');
    const trail = await rows<{ action: string }>(
      db,
      `select action from audit_log where table_name = 'documents' and record_id = $1
          and action like 'document\\_%' and action <> 'document_draft' order by id`,
      [id],
    );
    expect(trail.map((row) => row.action)).toEqual(['document_accepted', 'document_answer_undone', 'document_declined']);
  });

  it('is refused by name on an invoice, in the future, and by the table itself', async () => {
    const invoice = await quote({ docType: 'sale_invoice' });
    const id = await quote();
    await asUser(db, fx.ownerId, async () => {
      expect(await expectError(db, `select accept_document($1)`, [invoice])).toMatch(/^document_not_answerable: /);
      expect(await expectError(db, `select decline_document($1, now() + interval '2 days')`, [id])).toMatch(
        /^answer_in_the_future: /,
      );
      expect(await expectError(db, `select accept_document($1)`, [crypto.randomUUID()])).toMatch(/^unknown_document: /);
    });
    expect(await expectError(db, `update documents set accepted_at = now(), declined_at = now() where id = $1`, [id])).toMatch(
      /documents_answered_once/,
    );
    expect(await expectError(db, `update documents set accepted_at = now() where id = $1`, [invoice])).toMatch(
      /documents_answer_of_an_offer/,
    );
  });

  it('asks documents.write', async () => {
    const id = await quote();
    const viewer = crypto.randomUUID();
    await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'viewer')`, [fx.companyId, viewer]);
    await asUser(db, viewer, async () => {
      expect(await expectError(db, `select accept_document($1)`, [id])).toMatch(/^not_allowed: /);
    });
  });
});

describe('an agent answers in the mode its company chose', () => {
  it('in review, only a quote a person approved as it stands', async () => {
    const id = await quote();
    expect(await asAgent(`select accept_document($1)`, [id])).toMatch(/^approval_required: .*record an answer/);
    expect(await statusOf(id)).toBe('draft');

    await asUser(db, fx.ownerId, () => db.query(`select approve_document($1)`, [id]));
    expect(await asAgent(`select accept_document($1)`, [id])).toBeNull();
    expect(await statusOf(id)).toBe('accepted');
    const recorded = await one<{ new_values: Record<string, unknown> }>(
      db,
      `select new_values from audit_log where record_id = $1 and action = 'document_answered_by_agent'`,
      [id],
    );
    expect(recorded.new_values).toMatchObject({ posting_mode: 'review' });

    // The acceptance changed the quote: undoing it needs another approval.
    expect(await asAgent(`select undo_document_answer($1)`, [id])).toMatch(/^approval_required: /);
  });

  it('in autopilot, directly', async () => {
    const id = await quote();
    expect(await asAgent(`select decline_document($1)`, [id], 'autopilot')).toBeNull();
    expect(await statusOf(id)).toBe('declined');
  });
});

describe('through @ekwo-ai/core, as the MCP server and the command line call it', () => {
  // The client asks for the answer only on a schema that says it has it
  // (`SCHEMA_FEATURES.quote_answer`). Until the release that brings it
  // redefines `ekwo_schema_version()`, this database says the version it will
  // be for these tests, and says its own again after them.
  let definition: string;
  beforeAll(async () => {
    definition = (
      await one<{ definition: string }>(db, `select pg_get_functiondef('ekwo.ekwo_schema_version()'::regprocedure) as definition`)
    ).definition;
    await db.query(
      `create or replace function ekwo.ekwo_schema_version() returns text language sql immutable as $$ select '${SCHEMA_FEATURES.quote_answer.since}'::text $$`,
    );
  });
  afterAll(async () => {
    await db.query(definition);
  });

  it('records the answer and reads it back with the status the database derived', async () => {
    const backend = backendFor(db, fx.ownerId);
    const id = await quote();
    const accepted = record(await acceptDocument(backend, { document_id: id, accepted_by: 'The buyer' }));
    expect(record(accepted['document'])).toMatchObject({ id, quote_status: 'accepted', accepted_by: 'The buyer' });
    expect(String(accepted['note'])).toMatch(/nothing is booked/);

    const read = record(await getDocument(backend, { document_id: id }));
    expect(record(read['document'])['quote_status']).toBe('accepted');

    await undoDocumentAnswer(backend, { document_id: id });
    const listed = record(await listDocuments(backend, { company_id: fx.companyId, limit: 500 }));
    const byId = new Map((listed['documents'] as Record<string, unknown>[]).map((d) => [d['id'], d]));
    expect(byId.get(id)).toMatchObject({ quote_status: 'draft', accepted_at: null, accepted_by: null, declined_at: null });
    // A document no answer is given to says so with null, not with a guess.
    const invoice = await quote({ docType: 'sale_invoice' });
    expect(record(record(await getDocument(backend, { document_id: invoice }))['document'])['quote_status']).toBeNull();
  });

  it('names every status the database derives, in the words of each language', async () => {
    const derived = await rows<{ status: string }>(db, `select distinct quote_status(d) as status from documents d where quote_status(d) is not null`);
    for (const { status } of derived) expect(QUOTE_STATUSES).toContain(status);
    for (const [language, labels] of Object.entries(INVOICE_LABELS)) {
      for (const status of QUOTE_STATUSES) {
        expect(quoteStatusLabel(status, language), `${language} ${status}`).toBe(labels[QUOTE_STATUS_LABEL_KEYS[status]]);
      }
    }
  });
});
