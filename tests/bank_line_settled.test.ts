import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, freshDatabase, one } from './helpers/db.js';
import { newCompany, newContact, newDocument, type Fixture } from './helpers/factory.js';
import { newMember, plainSale, refusalAs } from './helpers/integrity.js';

// Issue #91: `entry_id` and `state` of a statement line were plain columns
// under `bank.write`. Setting `entry_id` back to null let the same money settle
// twice; writing `reconciled` hid a line nothing had settled; and the amount
// of a line booked as a payment could still move.

let db: PGlite;
let fx: Fixture;
let accountant: string;
let customer: string;
let bankAccountId: string;
let sale: { taxCode: string; accountCode: string };
let sequence = 0;

/** A posted invoice, and the open item it leaves. */
async function openItem(number: string): Promise<string> {
  const documentId = await newDocument(db, fx.companyId, {
    docType: 'sale_invoice',
    number,
    contactId: customer,
    date: '2026-03-02',
    lines: [{ unitPrice: 100, taxCode: sale.taxCode, accountCode: sale.accountCode }],
  });
  await db.query(`select post_document($1)`, [documentId]);
  const item = await one<{ line_id: string }>(db, `select line_id from open_items($1) where document_id = $2`, [
    fx.companyId,
    documentId,
  ]);
  return item.line_id;
}

/** A pending statement line, written by the accountant the way an import writes it. */
async function statementLine(amount: number): Promise<string> {
  sequence += 1;
  return asUser(db, accountant, async () => {
    const row = await one<{ id: string }>(
      db,
      `insert into bank_transactions (company_id, bank_account_id, sequence, transaction_date, amount, contact_id)
       values ($1, $2, $3, '2026-03-05', $4, $5) returning id`,
      [fx.companyId, bankAccountId, sequence, amount, customer],
    );
    return row.id;
  });
}

/** A statement line settled the one way there is, by the accountant. */
async function settledLine(number: string): Promise<{ id: string; entry_id: string }> {
  const line = await openItem(number);
  const open = await one<{ amount_open: string }>(db, `select amount_open from open_items($1) where line_id = $2`, [
    fx.companyId,
    line,
  ]);
  const tx = await statementLine(Number(open.amount_open));
  return asUser(db, accountant, () =>
    one<{ id: string; entry_id: string }>(db, `select id, entry_id from settle_from_statement($1, $2)`, [tx, [line]]),
  );
}

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db);
  accountant = await newMember(db, fx.companyId, 'accountant');
  customer = await newContact(db, fx.companyId, { name: 'Customer' });
  sale = await plainSale(db, fx.companyId);
  const account = await one<{ id: string }>(
    db,
    `insert into bank_accounts (company_id, name, currency_code, journal_id)
     select c.id, 'Current account', c.currency_code,
            (select j.id from journals j where j.company_id = c.id and j.journal_type = 'bank' order by j.code limit 1)
       from companies c where c.id = $1
     returning id`,
    [fx.companyId],
  );
  bankAccountId = account.id;
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('a statement line is settled by settle_from_statement()', () => {
  it('books it, points it at its entry and calls it reconciled, for a member who may match', async () => {
    const settled = await settledLine('INV-91-1');
    expect(settled.entry_id).not.toBeNull();
    expect(await one(db, `select state from bank_transactions where id = $1`, [settled.id])).toEqual({
      state: 'reconciled',
    });
  });

  it('refuses entry_id written back to null, so the same money is not settled twice', async () => {
    const settled = await settledLine('INV-91-2');
    expect(
      await refusalAs(db, accountant, `update bank_transactions set entry_id = null where id = $1`, [settled.id]),
    ).toMatch(/^bank_transaction_settled_by_rpc\b/);
    expect(
      await refusalAs(db, accountant, `update bank_transactions set entry_id = null, state = 'pending' where id = $1`, [
        settled.id,
      ]),
    ).toMatch(/^bank_transaction_settled_by_rpc\b/);
    const another = await openItem('INV-91-3');
    expect(
      await refusalAs(db, accountant, `select settle_from_statement($1, $2)`, [settled.id, [another]]),
    ).toMatch(/^statement_line_already_settled\b/);
  });

  it('refuses another entry written by hand on a settled line', async () => {
    const first = await settledLine('INV-91-4');
    const second = await settledLine('INV-91-5');
    expect(
      await refusalAs(db, accountant, `update bank_transactions set entry_id = $2 where id = $1`, [
        first.id,
        second.entry_id,
      ]),
    ).toMatch(/^bank_transaction_settled_by_rpc\b/);
  });

  it('keeps the amount, the day, the currency and the account of a settled line, and lets its words move', async () => {
    const settled = await settledLine('INV-91-6');
    for (const change of [
      `amount = amount + 1`,
      `transaction_date = transaction_date + 1`,
      `bank_account_id = gen_random_uuid()`,
    ]) {
      expect(
        await refusalAs(db, accountant, `update bank_transactions set ${change} where id = $1`, [settled.id]),
      ).toMatch(/^bank_transaction_settled\b/);
    }
    expect(
      await refusalAs(db, accountant, `update bank_transactions set description = 'Read again' where id = $1`, [
        settled.id,
      ]),
    ).toBe('accepted');
  });
});

describe('a line nothing settled', () => {
  it('is not called reconciled by hand', async () => {
    const tx = await statementLine(50);
    expect(
      await refusalAs(db, accountant, `update bank_transactions set state = 'reconciled' where id = $1`, [tx]),
    ).toMatch(/^bank_transaction_settled_by_rpc\b/);
  });

  it('moves between pending and ignored, which is the user’s call', async () => {
    const tx = await statementLine(60);
    await asUser(db, accountant, async () => {
      await db.query(`update bank_transactions set state = 'ignored' where id = $1`, [tx]);
      await db.query(`update bank_transactions set state = 'pending' where id = $1`, [tx]);
    });
    expect(await one(db, `select state, entry_id from bank_transactions where id = $1`, [tx])).toEqual({
      state: 'pending',
      entry_id: null,
    });
  });

  it('does not arrive settled', async () => {
    const entry = (await settledLine('INV-91-7')).entry_id;
    for (const [columns, values, params] of [
      ['state', `'reconciled'`, []],
      ['entry_id', '$4', [entry]],
    ] as const) {
      expect(
        await refusalAs(
          db,
          accountant,
          `insert into bank_transactions (company_id, bank_account_id, sequence, transaction_date, amount, ${columns})
           values ($1, $2, $3, '2026-03-06', 10, ${values})`,
          [fx.companyId, bankAccountId, 900, ...params],
        ),
      ).toMatch(/^bank_transaction_settled_by_rpc\b/);
    }
  });

  it('is not settled by a member who raises the setting by hand without the right to match', async () => {
    const tx = await statementLine(70);
    const clerk = await newMember(db, fx.companyId, 'accountant');
    await db.query(
      `update company_members set capabilities_revoked = array['reconcile.write'] where company_id = $1 and user_id = $2`,
      [fx.companyId, clerk],
    );
    expect(
      await refusalAs(
        db,
        clerk,
        `update bank_transactions set state = 'reconciled' where id = $1`,
        [tx],
        `select set_config('ekwo.settling_statement', 'on', true)`,
      ),
    ).toMatch(/^not_allowed\b.*reconcile\.write/);
  });
});
