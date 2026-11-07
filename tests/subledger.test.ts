/**
 * `subledger()` — a control account read contact by contact — and
 * `general_ledger(…, p_contact_ids)`, the lines of one row of it.
 *
 * Companies of several packs, their accounts taken by their role: customers
 * invoiced before the period and in it, a payment matched, a line on the
 * receivable account that names nobody, a draft and a line after the period
 * that count nowhere, and a supplier. What is asserted is what the function
 * owes any pack: per account, the rows add up to `trial_balance()` to the
 * cent; the balance brought forward is the one before the period; the lines
 * naming nobody are a row of their own; a contact's lines from
 * `general_ledger()` close on its row; and the refusals by name.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newUser, type Fixture } from './helpers/factory.js';
import type { Pack } from '../packages/cli/src/index.js';
import { packsWhere, roleOf } from './helpers/packs.js';

interface Books {
  pack: Pack;
  fx: Fixture;
  customer: string;
  other: string;
  supplier: string;
}

interface SubledgerRow {
  account_id: string;
  account_code: string;
  account_type: string;
  contact_id: string | null;
  contact_name: string | null;
  opening_balance: string;
  debit: string;
  credit: string;
  closing_balance: string;
  line_count: number;
  open_items: number;
}

const ROLES = ['receivable', 'payable', 'sales', 'purchase', 'bank'];

/** Three packs carrying every role the scenario books on: the first, one in the middle, the last. */
const packs: Pack[] = (() => {
  const found = packsWhere('naming receivable, payable, sales, purchase and bank accounts', (pack) =>
    ROLES.every((role) => typeof pack.manifest.defaults.roles[role] === 'string' && pack.manifest.defaults.roles[role] !== ''),
  );
  return [...new Set([found[0]!, found[Math.floor(found.length / 2)]!, found[found.length - 1]!])];
})();

let db: PGlite;
const books: Books[] = [];

/** A posted entry keyed by hand; each line is [role, debit, credit, contact]. Returns the line ids. */
async function book(
  b: Books,
  date: string,
  lines: [string, number, number, string | null][],
  state = 'posted',
): Promise<string[]> {
  const entry = await one<{ id: string }>(
    db,
    `insert into entries (company_id, journal_id, entry_date, description, state, currency_code)
     select c.id, c.miscellaneous_journal_id, $2::date, 'Subledger', 'draft', c.currency_code
       from companies c where c.id = $1
     returning id`,
    [b.fx.companyId, date],
  );
  const ids: string[] = [];
  for (const [index, [role, debit, credit, contact]] of lines.entries()) {
    const line = await one<{ id: string }>(
      db,
      `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit, contact_id)
       values ($1, $2, account_id_by_code($2, $3), $4, 'Subledger', $5, $6, $7) returning id`,
      [entry.id, b.fx.companyId, roleOf(b.pack, role), (index + 1) * 10, debit, credit, contact],
    );
    ids.push(line.id);
  }
  if (state === 'posted') await db.query(`select post_entry($1)`, [entry.id]);
  return ids;
}

async function subledger(b: Books, from: string, to: string, accounts: string[] | null = null): Promise<SubledgerRow[]> {
  return rows<SubledgerRow>(
    db,
    `select account_id, account_code, account_type::text, contact_id, contact_name,
            opening_balance::text, debit::text, credit::text, closing_balance::text, line_count, open_items
       from subledger($1, $2::date, $3::date, $4::uuid[])`,
    [b.fx.companyId, from, to, accounts],
  );
}

/** Decimal texts added exactly: the sums of the test are not allowed a float either. */
function add(values: string[]): string {
  const scale = Math.max(0, ...values.map((value) => (value.split('.')[1] ?? '').length));
  const total = values.reduce((sum, value) => {
    const negative = value.startsWith('-');
    const [whole = '0', fraction = ''] = value.replace(/^-/, '').split('.');
    const units = BigInt(`${whole}${fraction.padEnd(scale, '0')}`);
    return sum + (negative ? -units : units);
  }, 0n);
  return (Number(total) / 10 ** scale).toFixed(scale);
}

const same = (value: string): string => Number(value).toFixed(6);

beforeAll(async () => {
  db = await freshDatabase();
  for (const pack of packs) {
    const country = pack.manifest.country;
    const fx = await newCompany(db, { country, name: `Subledger Company ${pack.slug}` });
    const b: Books = {
      pack,
      fx,
      customer: await newContact(db, fx.companyId, { name: 'Customer One', country }),
      other: await newContact(db, fx.companyId, { name: 'Customer Two', country }),
      supplier: await newContact(db, fx.companyId, { name: 'Supplier One', type: 'supplier', country }),
    };
    books.push(b);

    // Before the period: 100 owed by the first customer, 80 owed to the supplier.
    const [early] = await book(b, '2026-01-10', [
      ['receivable', 100, 0, b.customer],
      ['sales', 0, 100, b.customer],
    ]);
    await book(b, '2026-01-20', [
      ['purchase', 80, 0, b.supplier],
      ['payable', 0, 80, b.supplier],
    ]);
    // In it: the first customer invoiced 250 and paying the first 100,
    // matched; the second invoiced 40; and 15 on the receivable account that
    // names nobody, as books imported line by line carry them.
    await book(b, '2026-03-01', [
      ['receivable', 250, 0, b.customer],
      ['sales', 0, 250, b.customer],
    ]);
    const [, paid] = await book(b, '2026-03-20', [
      ['bank', 100, 0, b.customer],
      ['receivable', 0, 100, b.customer],
    ]);
    await db.query(`select reconcile($1, $2, null)`, [early, paid]);
    await book(b, '2026-03-25', [
      ['receivable', 40, 0, b.other],
      ['sales', 0, 40, b.other],
    ]);
    await book(b, '2026-03-27', [
      ['receivable', 15, 0, null],
      ['sales', 0, 15, null],
    ]);
    // Counted nowhere: a draft, and a line after the period.
    await book(b, '2026-03-26', [
      ['receivable', 999, 0, b.customer],
      ['sales', 0, 999, b.customer],
    ], 'draft');
    await book(b, '2026-04-15', [
      ['receivable', 30, 0, b.customer],
      ['sales', 0, 30, b.customer],
    ]);
  }
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe.each(packs.map((pack, index) => [pack.slug, index] as const))('subledger() — %s', (_slug, index) => {
  const b = (): Books => books[index]!;

  it('adds up to the trial balance on every account, to the cent', async () => {
    const found = await subledger(b(), '2026-02-01', '2026-03-31');
    const trial = await rows<{ account_id: string; opening_balance: string; debit: string; credit: string; closing_balance: string }>(
      db,
      `select account_id, opening_balance::text, debit::text, credit::text, closing_balance::text
         from trial_balance($1, '2026-02-01', '2026-03-31')
        where account_type in ('asset_receivable', 'liability_payable')`,
      [b().fx.companyId],
    );
    expect(found.length).toBeGreaterThan(0);
    for (const account of trial) {
      const mine = found.filter((row) => row.account_id === account.account_id);
      for (const key of ['opening_balance', 'debit', 'credit', 'closing_balance'] as const) {
        expect(same(add(mine.map((row) => row[key]))), `${key} of ${account.account_id}`).toBe(same(account[key]));
      }
    }
    // Every row is one of those accounts: nothing else is read by default.
    const accounts = new Set(trial.map((account) => account.account_id));
    expect(found.every((row) => accounts.has(row.account_id))).toBe(true);
    expect(new Set(found.map((row) => row.account_type))).toEqual(new Set(['asset_receivable', 'liability_payable']));
  });

  it('brings forward what stood before the period, and moves with the period', async () => {
    const found = await subledger(b(), '2026-02-01', '2026-03-31');
    const receivable = roleOf(b().pack, 'receivable');
    const customer = found.find((row) => row.contact_id === b().customer && row.account_code === receivable)!;
    expect(customer).toMatchObject({ line_count: 2, open_items: 1 });
    expect(same(customer.opening_balance)).toBe(same('100'));
    expect(same(customer.debit)).toBe(same('250'));
    expect(same(customer.credit)).toBe(same('100'));
    expect(same(customer.closing_balance)).toBe(same('250'));

    const other = found.find((row) => row.contact_id === b().other)!;
    expect(same(other.opening_balance)).toBe(same('0'));
    expect(same(other.closing_balance)).toBe(same('40'));

    const supplier = found.find((row) => row.contact_id === b().supplier)!;
    expect(supplier).toMatchObject({ account_code: roleOf(b().pack, 'payable'), line_count: 0, open_items: 1 });
    expect(same(supplier.opening_balance)).toBe(same('-80'));
    expect(same(supplier.closing_balance)).toBe(same('-80'));

    // The period boundary moves the line of 1 March from the period to the
    // balance brought forward, and leaves the draft and April out.
    const later = await subledger(b(), '2026-03-02', '2026-03-31');
    const after = later.find((row) => row.contact_id === b().customer && row.account_code === receivable)!;
    expect(same(after.opening_balance)).toBe(same('350'));
    expect(same(after.debit)).toBe(same('0'));
    expect(same(after.closing_balance)).toBe(same('250'));
    expect(after.line_count).toBe(1);
  });

  it('counts the lines that name nobody apart, last of their account', async () => {
    const found = await subledger(b(), '2026-02-01', '2026-03-31');
    const receivable = roleOf(b().pack, 'receivable');
    const ofAccount = found.filter((row) => row.account_code === receivable);
    const nobody = ofAccount.at(-1)!;
    expect(nobody.contact_id).toBeNull();
    expect(nobody.contact_name).toBeNull();
    expect(same(nobody.closing_balance)).toBe(same('15'));
    expect(nobody.line_count).toBe(1);
    expect(ofAccount.filter((row) => row.contact_id === null)).toHaveLength(1);
  });

  it('reads the accounts it is given, whatever their type', async () => {
    const sales = await one<{ id: string }>(db, `select account_id_by_code($1, $2) as id`, [b().fx.companyId, roleOf(b().pack, 'sales')]);
    const found = await subledger(b(), '2026-01-01', '2026-12-31', [sales.id]);
    expect(new Set(found.map((row) => row.account_id))).toEqual(new Set([sales.id]));
    const trial = await one<{ closing_balance: string }>(
      db,
      `select closing_balance::text from trial_balance($1, '2026-01-01', '2026-12-31') where account_id = $2`,
      [b().fx.companyId, sales.id],
    );
    expect(same(add(found.map((row) => row.closing_balance)))).toBe(same(trial.closing_balance));
  });

  it('leaves out a contact with nothing brought forward, nothing moving and nothing open', async () => {
    // After April, with the first customer's 250 and 30 still open, every
    // contact has something; before January, nobody has anything.
    expect(await subledger(b(), '2025-01-01', '2025-12-31')).toEqual([]);
  });

  it('gives the lines of one contact from general_ledger(), closing on its row', async () => {
    const receivable = roleOf(b().pack, 'receivable');
    const account = await one<{ id: string }>(db, `select account_id_by_code($1, $2) as id`, [b().fx.companyId, receivable]);
    const lines = await rows<{ contact_id: string; debit: string; credit: string; running_balance: string }>(
      db,
      `select contact_id, debit::text, credit::text, running_balance::text
         from general_ledger($1, '2026-02-01', '2026-03-31', $2::uuid[], $3::uuid[])`,
      [b().fx.companyId, [account.id], [b().customer]],
    );
    expect(lines.map((line) => line.contact_id)).toEqual([b().customer, b().customer]);
    expect(same(lines[0]!.running_balance)).toBe(same('350'));
    expect(same(lines.at(-1)!.running_balance)).toBe(same('250'));

    // Two contacts: each runs its own balance.
    const both = await rows<{ contact_id: string; running_balance: string }>(
      db,
      `select contact_id, running_balance::text
         from general_ledger($1, '2026-02-01', '2026-03-31', $2::uuid[], $3::uuid[])`,
      [b().fx.companyId, [account.id], [b().customer, b().other]],
    );
    const last = (contact: string): string => both.filter((line) => line.contact_id === contact).at(-1)!.running_balance;
    expect(same(last(b().customer))).toBe(same('250'));
    expect(same(last(b().other))).toBe(same('40'));
  });
});

describe('general_ledger() without contacts', () => {
  it('answers a call of four arguments, and of three, as before', async () => {
    const b = books[0]!;
    const receivable = roleOf(b.pack, 'receivable');
    const account = await one<{ id: string }>(db, `select account_id_by_code($1, $2) as id`, [b.fx.companyId, receivable]);
    const four = await rows<{ entry_date: string; running_balance: string }>(
      db,
      `select entry_date::text, running_balance::text from general_ledger($1, '2026-02-01', '2026-03-31', $2::uuid[])`,
      [b.fx.companyId, [account.id]],
    );
    // Every contact, in the order of the ledger, one running balance for the account.
    expect(four.map((line) => line.entry_date)).toEqual(['2026-03-01', '2026-03-20', '2026-03-25', '2026-03-27']);
    expect(same(four[0]!.running_balance)).toBe(same('350'));
    expect(same(four.at(-1)!.running_balance)).toBe(same('305'));
    const three = await one<{ n: number }>(db, `select count(*)::int as n from general_ledger($1, '2026-02-01', '2026-03-31')`, [
      b.fx.companyId,
    ]);
    expect(three.n).toBeGreaterThanOrEqual(four.length);
  });
});

describe('subledger() refuses by name', () => {
  it('is read by a member under its own rights, and by nobody else', async () => {
    const b = books[0]!;
    const found = await asUser(db, b.fx.ownerId, () =>
      rows(db, `select * from subledger($1, '2026-01-01', '2026-12-31')`, [b.fx.companyId]),
    );
    expect(found.length).toBeGreaterThan(0);

    // A member of another company sees neither the books nor that the company exists.
    const stranger = await newUser(db);
    expect(
      await asUser(db, stranger, () => expectError(db, `select * from subledger($1, '2026-01-01', '2026-12-31')`, [b.fx.companyId])),
    ).toMatch(/^unknown_company:/);
    const elsewhere = books[books.length - 1]!;
    if (elsewhere !== b) {
      expect(
        await asUser(db, elsewhere.fx.ownerId, () =>
          expectError(db, `select * from subledger($1, '2026-01-01', '2026-12-31')`, [b.fx.companyId]),
        ),
      ).toMatch(/^unknown_company:/);
    }

    const member = await newUser(db);
    await db.query(
      `insert into company_members (company_id, user_id, role, capabilities_revoked)
       values ($1, $2, 'viewer', array['entries.read'])`,
      [b.fx.companyId, member],
    );
    expect(
      await asUser(db, member, () => expectError(db, `select * from subledger($1, '2026-01-01', '2026-12-31')`, [b.fx.companyId])),
    ).toMatch(/^not_allowed: .*entries\.read/);
  });

  it('refuses a period that is not one, an account of another company and a company that does not exist', async () => {
    const b = books[0]!;
    expect(await expectError(db, `select * from subledger($1, '2026-12-31', '2026-01-01')`, [b.fx.companyId])).toMatch(
      /^invalid_period:/,
    );
    const theirs = await one<{ id: string }>(db, `select id from accounts where company_id <> $1 limit 1`, [b.fx.companyId]);
    expect(
      await expectError(db, `select * from subledger($1, '2026-01-01', '2026-12-31', $2::uuid[])`, [b.fx.companyId, [theirs.id]]),
    ).toMatch(/^unknown_account:/);
    expect(await expectError(db, `select * from subledger($1, '2026-01-01', '2026-12-31')`, [crypto.randomUUID()])).toMatch(
      /^unknown_company:/,
    );
  });
});
