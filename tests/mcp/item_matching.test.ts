/**
 * Open items that settle each other, through the tools (decision 0072), and a
 * line left without a contact on purpose (decision 0073).
 *
 * Each tool is a thin call on the schema: the proposals come back as the
 * search found them, a matching answers with its letter and what it booked,
 * and a refusal is the database's own sentence with the hint that says what
 * to do.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { explain, readTools, writeTools, type Backend } from '../../packages/mcp/src/index.js';
import { freshDatabase, one } from '../helpers/db.js';
import { newCompany, newContact, type Fixture } from '../helpers/factory.js';
import { roleOf, somePack } from '../helpers/packs.js';
import { backendFor, list, record } from './helpers.js';

const pack = somePack;
const SALES = roleOf(pack, 'sales');

let db: PGlite;
let fx: Fixture;
let backend: Backend;
let customer: string;
let receivable: string;
let day: string;

/** A posted entry keyed by hand: `amount` on the receivable account, on the side given, against sales. */
async function item(amount: number, side: 'debit' | 'credit', contact: string | null): Promise<string> {
  const entry = await one<{ id: string }>(
    db,
    `insert into entries (company_id, journal_id, entry_date, state, currency_code)
     select c.id, c.miscellaneous_journal_id, $2::date, 'draft', c.currency_code from companies c where c.id = $1
     returning id`,
    [fx.companyId, day],
  );
  const [debit, credit] = side === 'debit' ? [amount, 0] : [0, amount];
  const line = await one<{ id: string }>(
    db,
    `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit, contact_id)
     values ($1, $2, $3, 10, 'Item', $4, $5, $6) returning id`,
    [entry.id, fx.companyId, receivable, debit, credit, contact],
  );
  await db.query(
    `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit)
     values ($1, $2, account_id_by_code($2, $3), 20, 'Item', $4, $5)`,
    [entry.id, fx.companyId, SALES, credit, debit],
  );
  await db.query(`select post_entry($1)`, [entry.id]);
  return line.id;
}

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db, { country: pack.manifest.country, name: 'Matching tools' });
  backend = backendFor(db, fx.ownerId);
  customer = await newContact(db, fx.companyId, { country: pack.manifest.country, name: 'Contoso Partners' });
  day = (await one<{ d: string }>(db, `select min(start_date)::text as d from fiscal_years where company_id = $1`, [fx.companyId])).d;
  receivable = (
    await one<{ id: string }>(
      db,
      `select id from accounts where company_id = $1 and account_type = 'asset_receivable' and reconcilable order by code limit 1`,
      [fx.companyId],
    )
  ).id;
}, 180_000);

afterAll(async () => {
  await db.close();
});

describe('suggest_item_combinations, reconcile_many and reconcile_with_difference', () => {
  it('proposes the invoices a payment settles, then matches them in one call', async () => {
    const a = await item(40, 'debit', customer);
    const b = await item(60, 'debit', customer);
    const payment = await item(100, 'credit', customer);

    const answer = record(await readTools.suggestItemCombinations(backend, { company_id: fx.companyId, contact_id: customer }));
    const [proposal] = list(answer['proposals']).filter((p) => p['line_id'] === payment);
    expect(proposal).toMatchObject({ kind: 'combination', total: '100.00', difference: '0.00' });
    expect([...(proposal?.['line_ids'] as string[])].sort()).toEqual([a, b].sort());

    const done = record(await writeTools.reconcileMany(backend, { line_ids: [payment, a, b] }));
    expect(record(done['matching'])).toMatchObject({ amount: '100.00', difference: '0.00', adjustment_entry_id: null });
  });

  it('gives the reasons and the tolerance, and books a difference with one of them', async () => {
    const options = record(await readTools.matchingDifferenceOptions(backend, { company_id: fx.companyId }));
    expect(record(options['tolerance'])['units']).toBe(500);
    const reasons = list(options['reasons']);
    expect(reasons.map((r) => r['reason'])).toContain('rounding');

    const invoice = await item(100, 'debit', customer);
    const payment = await item(99, 'credit', customer);
    const done = record(await writeTools.reconcileWithDifference(backend, { line_ids: [invoice, payment], reason: 'rounding' }));
    expect(record(done['matching'])).toMatchObject({ difference: '1.00' });
    expect(record(done['matching'])['adjustment_entry_id']).toEqual(expect.any(String));
  });

  it('answers an unbalanced set with the refusal and its hint', async () => {
    const invoice = await item(100, 'debit', customer);
    const payment = await item(90, 'credit', customer);
    const refusal = await writeTools.reconcileMany(backend, { line_ids: [invoice, payment] }).then(
      () => undefined,
      (error: Error) => explain(error.message),
    );
    expect(refusal?.message).toMatch(/^reconcile_unbalanced\b/);
    expect(refusal?.hint).toMatch(/reconcile_with_difference/);
  });
});

describe('leave_line_unnamed and undo_leave_line_unnamed', () => {
  it('leaves a line out of the suggestions, then takes it back', async () => {
    const line = await item(25, 'debit', null);
    const left = record(await writeTools.leaveLineUnnamed(backend, { line_id: line, reason: 'Cash difference' }));
    expect(record(left['left_unnamed'])).toMatchObject({ line_id: line, reason: 'Cash difference' });
    const refusal = await writeTools.leaveLineUnnamed(backend, { line_id: line, reason: 'Again' }).then(
      () => undefined,
      (error: Error) => explain(error.message),
    );
    expect(refusal?.message).toMatch(/^line_left_unnamed\b/);
    const undone = record(await writeTools.undoLeaveLineUnnamed(backend, { line_id: line }));
    expect(record(undone['removed'])).toMatchObject({ line_id: line });
  });
});
