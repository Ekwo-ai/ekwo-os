/**
 * Undoing what is posted, through the tools.
 *
 * `cancel_document` and `reverse_entry` are a thin call on the schema: what a
 * model gets back is what the database wrote, read afterwards, and a refusal
 * is the database's own sentence with the hint that says what to do about it.
 * `cancel_document` chooses between two functions — `unpost_document()` where
 * `unpost_refusal()` finds nothing against it, `cancel_document()` otherwise —
 * and says which it took, and why the draft was ruled out.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { explain, writeTools, type Backend } from '../../packages/mcp/src/index.js';
import { freshDatabase, one } from '../helpers/db.js';
import { newCompany, newContact, newDocument, type Fixture } from '../helpers/factory.js';
import { roleOf, somePack } from '../helpers/packs.js';
import { backendFor, record } from './helpers.js';

const pack = somePack;
const SALES = roleOf(pack, 'sales');
const RECEIVABLE = roleOf(pack, 'receivable');

let db: PGlite;
let fx: Fixture;
let backend: Backend;
let customer: string;
let yearStart: string;

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db, { country: pack.manifest.country, name: 'Undo tools' });
  backend = backendFor(db, fx.ownerId);
  customer = await newContact(db, fx.companyId, { country: pack.manifest.country });
  yearStart = (await one<{ d: string }>(db, `select min(start_date)::text as d from fiscal_years where company_id = $1`, [fx.companyId])).d;
}, 180_000);

afterAll(async () => {
  await db.close();
});

async function postedInvoice(): Promise<string> {
  const id = await newDocument(db, fx.companyId, {
    docType: 'sale_invoice',
    contactId: customer,
    date: yearStart,
    lines: [{ unitPrice: 250, taxCode: null, accountCode: SALES }],
  });
  await writeTools.postDocument(backend, { document_id: id });
  return id;
}

describe('cancel_document', () => {
  it('answers with the credit note it posted, and the invoice cancelled', async () => {
    const invoiceId = await postedInvoice();
    const answer = record(await writeTools.undoDocument(backend, { document_id: invoiceId }));

    expect(answer['undone_by']).toBe('credit_note');
    expect(answer['why']).toMatch(/^posted_edit_reversal_only\b/);
    expect(record(answer['cancelled'])).toMatchObject({
      id: invoiceId,
      state: 'cancelled',
      payment_state: 'reversed',
      amount_residual: '0.00',
    });
    expect(record(answer['credit_note'])).toMatchObject({
      doc_type: 'sale_credit_note',
      state: 'posted',
      reversed_document_id: invoiceId,
      amount_total: '250.00',
    });
    expect(record(answer['entry'])['state']).toBe('posted');
    expect(answer['entry_lines']).toHaveLength(2);
  });

  it('hands the refusal back with what to do about it', async () => {
    const invoiceId = await postedInvoice();
    await writeTools.undoDocument(backend, { document_id: invoiceId });
    const refusal = await writeTools.undoDocument(backend, { document_id: invoiceId }).then(
      () => null,
      (error: Error) => explain(error.message),
    );
    expect(refusal?.message).toMatch(/^document_already_cancelled\b/);
    expect(refusal?.hint).toMatch(/already cancelled/);
  });
});

describe('cancel_document, where the country lets a posted document go back to draft', () => {
  // Stated here, for this database: the test is about the choice.
  const allow = (policy: string | null) =>
    db.query(`update country_defaults set posted_edit_policy = $2 where country = $1`, [pack.manifest.country, policy]);

  it('puts an untouched invoice back to draft, and says it did', async () => {
    const before = await one<{ policy: string | null }>(db, `select posted_edit_policy as policy from country_defaults where country = $1`, [pack.manifest.country]);
    await allow('unpost_if_untouched');
    try {
      const invoiceId = await postedInvoice();
      const posted = await one<{ number: string; entry_id: string }>(db, `select number, entry_id from documents where id = $1`, [invoiceId]);
      const answer = record(await writeTools.undoDocument(backend, { document_id: invoiceId }));
      expect(answer['undone_by']).toBe('draft');
      expect(answer['why']).toBeNull();
      expect(record(answer['draft'])).toMatchObject({ id: invoiceId, state: 'draft', number: null, entry_id: null });
      expect(record(answer['unposting'])).toMatchObject({ entry_id: posted.entry_id, entry_number: posted.number, number_returned: true });
      expect(answer['note']).toMatch(/draft again/);
    } finally {
      await allow(before.policy);
    }
  });

  it('issues the credit note of one that was sent, and says why', async () => {
    const before = await one<{ policy: string | null }>(db, `select posted_edit_policy as policy from country_defaults where country = $1`, [pack.manifest.country]);
    await allow('unpost_if_untouched');
    try {
      const invoiceId = await postedInvoice();
      await db.query(`update documents set sent_at = now() where id = $1`, [invoiceId]);
      const answer = record(await writeTools.undoDocument(backend, { document_id: invoiceId }));
      expect(answer['undone_by']).toBe('credit_note');
      expect(answer['why']).toMatch(/^document_sent\b/);
      expect(record(answer['cancelled'])).toMatchObject({ id: invoiceId, state: 'cancelled' });

      // And asked for, it is the credit note even where the draft was possible.
      const other = await postedInvoice();
      const asked = record(await writeTools.undoDocument(backend, { document_id: other, credit_note: true }));
      expect(asked).toMatchObject({ undone_by: 'credit_note', why: 'A credit note was asked for.' });
    } finally {
      await allow(before.policy);
    }
  });
});

describe('reverse_entry', () => {
  it('answers with the reversal it posted, matched against what it undoes', async () => {
    const entryId = (
      await one<{ id: string }>(
        db,
        `insert into entries (company_id, journal_id, entry_date, description)
         select id, miscellaneous_journal_id, $2, 'By hand' from companies where id = $1 returning id`,
        [fx.companyId, yearStart],
      )
    ).id;
    await db.query(
      `insert into entry_lines (entry_id, company_id, account_id, sequence, debit, credit)
       values ($1, $2, account_id_by_code($2, $3), 10, 80, 0), ($1, $2, account_id_by_code($2, $4), 20, 0, 80)`,
      [entryId, fx.companyId, RECEIVABLE, SALES],
    );
    await db.query(`select post_entry($1)`, [entryId]);

    const answer = record(await writeTools.reverseEntry(backend, { entry_id: entryId }));
    const entry = record(answer['entry']);
    expect(entry).toMatchObject({ state: 'posted', reversed_entry_id: entryId, total_debit: '80.00' });
    const lines = answer['entry_lines'] as Record<string, unknown>[];
    expect(lines.map((line) => [record(line['account'])['code'], line['debit'], line['credit']])).toEqual([
      [RECEIVABLE, '0.00', '80.00'],
      [SALES, '80.00', '0.00'],
    ]);
    expect(lines[0]?.['matched_amount']).toBe('80.00');
  });

  it('refuses the entry of a document, and says to cancel the document', async () => {
    const invoiceId = await postedInvoice();
    const entryId = (await one<{ entry_id: string }>(db, `select entry_id from documents where id = $1`, [invoiceId])).entry_id;
    const refusal = await writeTools.reverseEntry(backend, { entry_id: entryId }).then(
      () => null,
      (error: Error) => explain(error.message),
    );
    expect(refusal?.message).toMatch(/^entry_of_a_document\b/);
    expect(refusal?.hint).toMatch(/cancel_document/);
  });
});
