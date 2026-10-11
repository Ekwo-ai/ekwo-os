import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, freshDatabase, one } from './helpers/db.js';
import { accountId, newCompany, newContact, newDocument, type Fixture } from './helpers/factory.js';
import { newMember, plainSale, refusalAs } from './helpers/integrity.js';

// Issue #89: `reconcile()` never read `contact_id`, so the payment of one
// customer settled the invoice of another; and `reconciliations` was writable
// by hand under `reconcile.write`, past every check `reconcile()` makes.

let db: PGlite;
let fx: Fixture;
let accountant: string;
let sale: { taxCode: string; accountCode: string };
let receivable: string;
let income: string;
let cash: string;
let alpha: string;
let alphaBranch: string;
let beta: string;
let number = 0;

/** The receivable line of a posted invoice of 100 plus tax to `contact`. */
async function invoiceLine(contact: string): Promise<string> {
  number += 1;
  const documentId = await newDocument(db, fx.companyId, {
    docType: 'sale_invoice',
    number: `INV-89-${number}`,
    contactId: contact,
    date: '2026-04-01',
    lines: [{ unitPrice: 100, taxCode: sale.taxCode, accountCode: sale.accountCode }],
  });
  await db.query(`select post_document($1)`, [documentId]);
  const item = await one<{ line_id: string }>(db, `select line_id from open_items($1) where document_id = $2`, [
    fx.companyId,
    documentId,
  ]);
  return item.line_id;
}

/**
 * A posted entry keyed by hand, 50 on the receivable account against the
 * account named; the receivable line names `contact`, or nobody. Returns the
 * receivable line.
 */
async function receivableLine(contact: string | null, side: 'debit' | 'credit', other: string): Promise<string> {
  const entry = await one<{ id: string }>(
    db,
    `insert into entries (company_id, journal_id, entry_date, state, currency_code)
     select c.id, c.miscellaneous_journal_id, '2026-04-02', 'draft', c.currency_code from companies c where c.id = $1
     returning id`,
    [fx.companyId],
  );
  const [debit, credit] = side === 'debit' ? [50, 0] : [0, 50];
  const line = await one<{ id: string }>(
    db,
    `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit, contact_id)
     values ($1, $2, $3, 10, 'By hand', $4, $5, $6) returning id`,
    [entry.id, fx.companyId, receivable, debit, credit, contact],
  );
  await db.query(
    `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit)
     values ($1, $2, $3, 20, 'By hand', $4, $5)`,
    [entry.id, fx.companyId, other, credit, debit],
  );
  await db.query(`select post_entry($1)`, [entry.id]);
  return line.id;
}

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db);
  accountant = await newMember(db, fx.companyId, 'accountant');
  sale = await plainSale(db, fx.companyId);
  alpha = await newContact(db, fx.companyId, { name: 'Alpha' });
  beta = await newContact(db, fx.companyId, { name: 'Beta' });
  alphaBranch = await newContact(db, fx.companyId, { name: 'Alpha, branch' });
  await db.query(`update contacts set parent_id = $2 where id = $1`, [alphaBranch, alpha]);
  const first = await invoiceLine(alpha);
  receivable = (await one<{ account_id: string }>(db, `select account_id from entry_lines where id = $1`, [first]))
    .account_id;
  income = await accountId(db, fx.companyId, sale.accountCode);
  cash = (
    await one<{ id: string }>(
      db,
      `select id from accounts where company_id = $1 and account_type = 'asset_cash' order by code limit 1`,
      [fx.companyId],
    )
  ).id;
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('reconcile() matches the items of one counterparty', () => {
  it('refuses the money of one customer against the invoice of another', async () => {
    const invoice = await invoiceLine(alpha);
    const payment = await receivableLine(beta, 'credit', cash);
    expect(await refusalAs(db, accountant, `select reconcile($1, $2)`, [payment, invoice])).toMatch(
      /^reconcile_contact_mismatch\b.*two different counterparties/,
    );
  });

  it('matches a line naming nobody, which the matching attributes', async () => {
    const invoice = await invoiceLine(alpha);
    const anonymous = await receivableLine(null, 'credit', cash);
    expect(await refusalAs(db, accountant, `select reconcile($1, $2)`, [invoice, anonymous])).toBe('accepted');
  });

  it('matches a customer’s own money, and a branch with its parent', async () => {
    const invoice = await invoiceLine(alpha);
    const own = await receivableLine(alpha, 'credit', cash);
    const branch = await receivableLine(alphaBranch, 'credit', cash);
    await asUser(db, accountant, async () => {
      await db.query(`select reconcile($1, $2)`, [own, invoice]);
      await db.query(`select reconcile($1, $2)`, [branch, invoice]);
    });
    const matched = await one<{ n: number }>(
      db,
      `select count(*)::int as n from reconciliations where debit_line_id = $1`,
      [invoice],
    );
    expect(matched.n).toBe(2);
  });

  it('matches two lines that both name nobody, as before', async () => {
    const charge = await receivableLine(null, 'debit', income);
    const settled = await receivableLine(null, 'credit', cash);
    expect(await refusalAs(db, accountant, `select reconcile($1, $2)`, [charge, settled])).toBe('accepted');
  });
});

describe('a matching is written by reconcile() and undone by unreconcile()', () => {
  it('refuses a row inserted, changed or deleted by hand, and leaves the two functions working', async () => {
    const invoice = await invoiceLine(alpha);
    const payment = await receivableLine(beta, 'credit', cash);
    expect(
      await refusalAs(
        db,
        accountant,
        `insert into reconciliations (company_id, debit_line_id, credit_line_id, amount, matching_number)
         values ($1, $2, $3, 50, 'X89')`,
        [fx.companyId, invoice, payment],
      ),
    ).toMatch(/^reconciliation_by_reconcile\b/);

    const own = await receivableLine(alpha, 'credit', cash);
    const matching = await asUser(db, accountant, () =>
      one<{ id: string }>(db, `select id from reconcile($1, $2)`, [own, invoice]),
    );
    expect(
      await refusalAs(db, accountant, `update reconciliations set amount = 1 where id = $1`, [matching.id]),
    ).toMatch(/^reconciliation_by_reconcile\b/);
    expect(await refusalAs(db, accountant, `delete from reconciliations where id = $1`, [matching.id])).toMatch(
      /^reconciliation_by_reconcile\b/,
    );
    expect(await refusalAs(db, accountant, `select unreconcile($1)`, [matching.id])).toBe('accepted');
  });

  it('honours the setting raised by hand only for a member who may match', async () => {
    const invoice = await invoiceLine(alpha);
    const own = await receivableLine(alpha, 'credit', cash);
    const clerk = await newMember(db, fx.companyId, 'accountant');
    await db.query(
      `update company_members set capabilities_revoked = array['reconcile.write'] where company_id = $1 and user_id = $2`,
      [fx.companyId, clerk],
    );
    expect(
      await refusalAs(
        db,
        clerk,
        `insert into reconciliations (company_id, debit_line_id, credit_line_id, amount, matching_number)
         values ($1, $2, $3, 50, 'X89')`,
        [fx.companyId, invoice, own],
        `select set_config('ekwo.reconciling', 'on', true)`,
      ),
    ).toMatch(/^not_allowed\b.*reconcile\.write/);
  });
});
