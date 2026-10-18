import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newUser, type Fixture } from './helpers/factory.js';
import { newMember, refusalAs } from './helpers/integrity.js';

// Decision 0071: several open lines of one counterparty on one account settle
// each other in one gesture, the proposals come from the one search a
// statement line uses, and a small difference is booked on the account the
// pack gives for its reason, then matched.

let db: PGlite;
let fx: Fixture;
let accountant: string;
let viewer: string;
let receivable: string;
let payable: string;
let income: string;
let otherReconcilable: string;
let home: string;
let unit: number;
let names = 0;

interface Proposal {
  proposal_id: string;
  ordinal: number;
  contact_id: string;
  account_id: string;
  line_id: string;
  side: string;
  amount: string;
  kind: string;
  line_ids: string[];
  total: string;
  difference: string;
  because: string;
  alternatives: number;
}

interface Matched {
  matching_number: string;
  amount: string;
  difference: string;
  adjustment_entry_id: string | null;
  reconciliation_ids: string[];
}

const NOWHERE = '7d0f0b4e-0000-4000-8000-00000000abcd';
const UUID = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/g;

async function accountOfType(companyId: string, where: string): Promise<string> {
  return (
    await one<{ id: string }>(db, `select id from accounts where company_id = $1 and ${where} order by code limit 1`, [
      companyId,
    ])
  ).id;
}

/**
 * A posted entry keyed by hand: `amount` on `account`, on the side given, for
 * `contact`, against `other`. Returns the line on `account`.
 */
async function line(options: {
  amount: number;
  side: 'debit' | 'credit';
  contact?: string | null;
  account?: string;
  other?: string;
  date?: string;
  companyId?: string;
  state?: 'draft' | 'posted';
  name?: string;
}): Promise<string> {
  const companyId = options.companyId ?? fx.companyId;
  const entry = await one<{ id: string }>(
    db,
    `insert into entries (company_id, journal_id, entry_date, state, currency_code, description)
     select c.id, c.miscellaneous_journal_id, $2::date, 'draft', c.currency_code, $3 from companies c where c.id = $1
     returning id`,
    [companyId, options.date ?? '2026-04-02', options.name ?? 'Item'],
  );
  const [debit, credit] = options.side === 'debit' ? [options.amount, 0] : [0, options.amount];
  const created = await one<{ id: string }>(
    db,
    `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit, contact_id)
     values ($1, $2, $3, 10, $4, $5, $6, $7) returning id`,
    [entry.id, companyId, options.account ?? receivable, options.name ?? 'Item', debit, credit, options.contact ?? null],
  );
  await db.query(
    `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit)
     values ($1, $2, $3, 20, $4, $5, $6)`,
    [entry.id, companyId, options.other ?? income, options.name ?? 'Item', credit, debit],
  );
  if ((options.state ?? 'posted') === 'posted') await db.query(`select post_entry($1)`, [entry.id]);
  return created.id;
}

async function customer(): Promise<string> {
  return newContact(db, fx.companyId, { name: `Customer ${(names += 1).toString().padStart(3, '0')} Ltd` });
}

async function proposals(contact: string | null, companyId = fx.companyId): Promise<Proposal[]> {
  return rows<Proposal>(db, `select * from suggest_item_combinations($1, $2)`, [companyId, contact]);
}

async function openOf(lineId: string): Promise<number> {
  return Number(
    (await one<{ open: string }>(db, `select abs(balance) - matched_amount as open from entry_lines where id = $1`, [lineId]))
      .open,
  );
}

const sorted = (ids: string[]): string[] => [...ids].sort();

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db);
  accountant = await newMember(db, fx.companyId, 'accountant');
  viewer = await newMember(db, fx.companyId, 'viewer');
  receivable = await accountOfType(fx.companyId, `account_type = 'asset_receivable' and reconcilable`);
  payable = await accountOfType(fx.companyId, `account_type = 'liability_payable' and reconcilable`);
  income = await accountOfType(fx.companyId, `account_type = 'income' and not reconcilable`);
  otherReconcilable = await accountOfType(
    fx.companyId,
    `reconcilable and account_type not in ('asset_receivable', 'liability_payable')`,
  );
  home = (await one<{ currency_code: string }>(db, `select currency_code from companies where id = $1`, [fx.companyId]))
    .currency_code;
  unit = Number((await one<{ unit: string }>(db, `select currency_unit(rounding_of($1)) as unit`, [fx.companyId])).unit);
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('combination_subsets(), the one search', () => {
  it('meets first the subset an oldest-first greedy walk finds', async () => {
    // Greedy over 40, 30, 20, 10 for 70: takes 40, takes 30, done.
    const found = await rows<{ s: number[] }>(db, `select s from combination_subsets(array[40,30,20,10]::numeric[], 70, 0, 2, 5) s`);
    expect(found[0]!.s).toEqual([1, 2]);
    // And it goes on to what the greedy walk stepped over.
    expect(found.map((r) => r.s)).toContainEqual([1, 3, 4]);
  });

  it('finds what a greedy walk misses', async () => {
    // Greedy for 50 over 30, 25, 25 takes 30, cannot take 25, stops short.
    const found = await rows<{ s: number[] }>(db, `select s from combination_subsets(array[30,25,25]::numeric[], 50, 0, 2, 1) s`);
    expect(found.map((r) => r.s)).toEqual([[2, 3]]);
  });

  it('holds the tolerance, the minimum of lines and the number of answers', async () => {
    const withTolerance = await rows<{ s: number[] }>(
      db,
      `select s from combination_subsets(array[10.00, 20.01]::numeric[], 30, 0.01, 2, 3) s`,
    );
    expect(withTolerance.map((r) => r.s)).toEqual([[1, 2]]);
    const exact = await rows(db, `select s from combination_subsets(array[10.00, 20.01]::numeric[], 30, 0, 2, 3) s`);
    expect(exact).toHaveLength(0);
    // A single item that reaches is not a combination.
    const single = await rows(db, `select s from combination_subsets(array[30]::numeric[], 30, 0, 2, 3) s`);
    expect(single).toHaveLength(0);
    const capped = await rows(db, `select s from combination_subsets(array[1,1,1,1]::numeric[], 2, 0, 2, 2) s`);
    expect(capped).toHaveLength(2);
  });

  it('stays inside its bounds, written in one place', async () => {
    const bounds = await one<{ max_candidates: number; max_lines: number; max_steps: number; max_proposals: number }>(
      db,
      `select * from matching_search_bounds()`,
    );
    expect(bounds).toEqual({ max_candidates: 40, max_lines: 10, max_steps: 20000, max_proposals: 3 });
    // Twelve items of 1 for 12: a subset of twelve lines is longer than the bound.
    const tooLong = await rows(db, `select s from combination_subsets(array_fill(1::numeric, array[12]), 12, 0, 2, 1) s`);
    expect(tooLong).toHaveLength(0);
  });

  it('refuses an amount that is not positive', async () => {
    expect(await expectError(db, `select * from combination_subsets(array[10, -5]::numeric[], 5)`)).toMatch(
      /^combination_amount_not_positive:/,
    );
  });
});

describe('suggest_item_combinations()', () => {
  it('proposes the invoices one payment settles, to the cent', async () => {
    const who = await customer();
    const a = await line({ amount: 100, side: 'debit', contact: who, date: '2026-03-01' });
    const b = await line({ amount: 120.5, side: 'debit', contact: who, date: '2026-03-05' });
    const c = await line({ amount: 79.5, side: 'debit', contact: who, date: '2026-03-09' });
    const payment = await line({ amount: 300, side: 'credit', contact: who, date: '2026-04-01' });

    const found = (await proposals(who)).filter((p) => p.line_id === payment);
    expect(found).toHaveLength(1);
    const [proposal] = found;
    expect(proposal!.kind).toBe('combination');
    expect(sorted(proposal!.line_ids)).toEqual(sorted([a, b, c]));
    expect(Number(proposal!.total)).toBe(300);
    expect(Number(proposal!.difference)).toBe(0);
    expect(proposal!.side).toBe('credit');
    expect(proposal!.account_id).toBe(receivable);
    expect(proposal!.contact_id).toBe(who);
    expect(proposal!.ordinal).toBe(1);
    expect(proposal!.alternatives).toBe(1);
    expect(proposal!.because).toMatch(/3 open items of .* add up to 300/);
  });

  it('proposes the reverse: one invoice paid in instalments', async () => {
    const who = await customer();
    const invoice = await line({ amount: 300, side: 'debit', contact: who, date: '2026-02-01' });
    const instalments = [
      await line({ amount: 100, side: 'credit', contact: who, date: '2026-03-01' }),
      await line({ amount: 100, side: 'credit', contact: who, date: '2026-04-01' }),
      await line({ amount: 100, side: 'credit', contact: who, date: '2026-05-01' }),
    ];
    const found = (await proposals(who)).filter((p) => p.line_id === invoice);
    expect(found.map((p) => sorted(p.line_ids))).toContainEqual(sorted(instalments));
  });

  it('says an exact pair once, from the debit', async () => {
    const who = await customer();
    const invoice = await line({ amount: 55, side: 'debit', contact: who });
    const payment = await line({ amount: 55, side: 'credit', contact: who });
    const found = await proposals(who);
    expect(found).toHaveLength(1);
    expect(found[0]!.line_id).toBe(invoice);
    expect(found[0]!.line_ids).toEqual([payment]);
    expect(found[0]!.kind).toBe('pair');
  });

  it('gives the same id to the same proposal, call after call', async () => {
    const who = await customer();
    await line({ amount: 40, side: 'debit', contact: who });
    await line({ amount: 60, side: 'debit', contact: who });
    await line({ amount: 100, side: 'credit', contact: who });
    const first = (await proposals(who)).map((p) => p.proposal_id);
    const second = (await proposals(who)).map((p) => p.proposal_id);
    expect(first.length).toBeGreaterThan(0);
    expect(second).toEqual(first);
  });

  it('keeps to one counterparty and one account, a branch counted with its parent', async () => {
    const parent = await customer();
    const branch = await customer();
    await db.query(`update contacts set parent_id = $2 where id = $1`, [branch, parent]);
    const stranger = await customer();
    const a = await line({ amount: 70, side: 'debit', contact: parent });
    const b = await line({ amount: 30, side: 'debit', contact: branch });
    // The same amounts for somebody else, and on another account.
    await line({ amount: 30, side: 'debit', contact: stranger });
    await line({ amount: 30, side: 'debit', contact: parent, account: otherReconcilable });
    const payment = await line({ amount: 100, side: 'credit', contact: parent });

    const found = (await proposals(branch)).filter((p) => p.line_id === payment);
    expect(found).toHaveLength(1);
    expect(sorted(found[0]!.line_ids)).toEqual(sorted([a, b]));
    expect(found[0]!.contact_id).toBe(parent);
    // Asked for the company, the stranger's line is in no proposal of the parent.
    const all = (await proposals(null)).filter((p) => p.contact_id === parent);
    expect(all.flatMap((p) => p.line_ids)).not.toContain(stranger);
  });

  it('offers a pair a little apart only when nothing is exact, with the difference signed', async () => {
    const who = await customer();
    const invoice = await line({ amount: 100, side: 'debit', contact: who });
    const payment = await line({ amount: 97, side: 'credit', contact: who });
    const found = await proposals(who);
    expect(found).toHaveLength(1);
    expect(found[0]!.line_id).toBe(invoice);
    expect(found[0]!.line_ids).toEqual([payment]);
    expect(Number(found[0]!.difference)).toBe(3);
    expect(found[0]!.because).toMatch(/a difference to book/);

    // An exact payment arrives: the difference is no longer proposed.
    const exact = await line({ amount: 100, side: 'credit', contact: who });
    const now = await proposals(who);
    expect(now.filter((p) => p.line_id === invoice).map((p) => p.line_ids)).toEqual([[exact]]);
  });

  it('offers nothing beyond the company tolerance', async () => {
    const who = await customer();
    await line({ amount: 100, side: 'debit', contact: who });
    // 500 units by default: more than that apart is not a difference to book.
    await line({ amount: 100 - 501 * unit, side: 'credit', contact: who });
    expect(await proposals(who)).toHaveLength(0);
  });

  it('leaves out lines that name nobody, and lines in another currency', async () => {
    const who = await customer();
    await line({ amount: 80, side: 'debit', contact: null });
    await line({ amount: 80, side: 'credit', contact: who });
    expect(await proposals(who)).toHaveLength(0);
  });

  it('answers a stranger about a company as about one that does not exist', async () => {
    const stranger = await newUser(db);
    const theirs = await asUser(db, stranger, () => proposals(null, fx.companyId));
    const nobodys = await asUser(db, stranger, () => proposals(null, NOWHERE));
    expect(theirs).toEqual([]);
    expect(nobodys).toEqual([]);
  });
});

describe('reconcile_many()', () => {
  it('settles one payment against three invoices under one letter', async () => {
    const who = await customer();
    const invoices = [
      await line({ amount: 100, side: 'debit', contact: who, date: '2026-03-01' }),
      await line({ amount: 120.5, side: 'debit', contact: who, date: '2026-03-05' }),
      await line({ amount: 79.5, side: 'debit', contact: who, date: '2026-03-09' }),
    ];
    const payment = await line({ amount: 300, side: 'credit', contact: who, date: '2026-04-01' });

    const done = await asUser(db, accountant, () =>
      one<Matched>(db, `select * from reconcile_many($1)`, [[payment, ...invoices]]),
    );
    expect(Number(done.amount)).toBe(300);
    expect(Number(done.difference)).toBe(0);
    expect(done.adjustment_entry_id).toBeNull();
    expect(done.reconciliation_ids).toHaveLength(3);

    for (const id of [payment, ...invoices]) expect(await openOf(id)).toBe(0);
    const letters = await rows<{ matching_number: string }>(
      db,
      `select distinct matching_number from entry_lines where id = any($1)`,
      [[payment, ...invoices]],
    );
    expect(letters).toEqual([{ matching_number: done.matching_number }]);
    expect(await rows(db, `select * from open_items($1, $2)`, [fx.companyId, who])).toHaveLength(0);
  });

  it('settles three instalments against a payment that names nobody, which the matching attributes', async () => {
    const who = await customer();
    const invoice = await line({ amount: 90, side: 'debit', contact: who });
    const a = await line({ amount: 30, side: 'credit', contact: who });
    const b = await line({ amount: 30, side: 'credit', contact: who });
    const nobody = await line({ amount: 30, side: 'credit', contact: null });
    const done = await one<Matched>(db, `select * from reconcile_many($1)`, [[invoice, a, b, nobody]]);
    expect(done.reconciliation_ids).toHaveLength(3);
    expect(await openOf(invoice)).toBe(0);
  });

  describe('refuses, by name', () => {
    it('fewer than two lines, a line twice', async () => {
      const who = await customer();
      const a = await line({ amount: 10, side: 'debit', contact: who });
      expect(await expectError(db, `select * from reconcile_many($1)`, [[a]])).toMatch(/^no_lines_named:/);
      expect(await expectError(db, `select * from reconcile_many(null)`)).toMatch(/^no_lines_named:/);
      expect(await expectError(db, `select * from reconcile_many($1)`, [[a, a]])).toMatch(/^duplicate_line:/);
    });

    it('a line nobody can read', async () => {
      const who = await customer();
      const a = await line({ amount: 10, side: 'debit', contact: who });
      expect(await expectError(db, `select * from reconcile_many($1)`, [[a, NOWHERE]])).toMatch(/^unknown_line:/);
    });

    it('lines of two companies', async () => {
      const other = await newCompany(db, { name: 'Other Books' });
      const theirReceivable = await accountOfType(other.companyId, `account_type = 'asset_receivable' and reconcilable`);
      const theirIncome = await accountOfType(other.companyId, `account_type = 'income' and not reconcilable`);
      const mine = await line({ amount: 10, side: 'debit', contact: null });
      const theirs = await line({
        amount: 10,
        side: 'credit',
        contact: null,
        companyId: other.companyId,
        account: theirReceivable,
        other: theirIncome,
      });
      expect(await expectError(db, `select * from reconcile_many($1)`, [[mine, theirs]])).toMatch(
        /^reconcile_company_mismatch:/,
      );
    });

    it('a member who may not match', async () => {
      const who = await customer();
      const a = await line({ amount: 10, side: 'debit', contact: who });
      const b = await line({ amount: 10, side: 'credit', contact: who });
      expect(await refusalAs(db, viewer, `select * from reconcile_many($1)`, [[a, b]])).toMatch(
        /^not_allowed: .*reconcile\.write/,
      );
    });

    it('a draft', async () => {
      const who = await customer();
      const a = await line({ amount: 10, side: 'debit', contact: who });
      const b = await line({ amount: 10, side: 'credit', contact: who, state: 'draft' });
      expect(await expectError(db, `select * from reconcile_many($1)`, [[a, b]])).toMatch(/^line_not_posted:/);
    });

    it('two accounts, an account that is not reconcilable', async () => {
      const who = await customer();
      const a = await line({ amount: 10, side: 'debit', contact: who });
      const b = await line({ amount: 10, side: 'credit', contact: who, account: otherReconcilable });
      expect(await expectError(db, `select * from reconcile_many($1)`, [[a, b]])).toMatch(/^reconcile_account_mismatch:/);
      const expense = await accountOfType(fx.companyId, `account_type = 'expense' and not reconcilable`);
      const c = await line({ amount: 10, side: 'debit', account: expense });
      const d = await line({ amount: 10, side: 'credit', account: expense });
      expect(await expectError(db, `select * from reconcile_many($1)`, [[c, d]])).toMatch(/^account_not_reconcilable:/);
    });

    it('two counterparties', async () => {
      const a = await line({ amount: 10, side: 'debit', contact: await customer() });
      const b = await line({ amount: 10, side: 'credit', contact: await customer() });
      expect(await expectError(db, `select * from reconcile_many($1)`, [[a, b]])).toMatch(/^reconcile_contact_mismatch:/);
    });

    it('a line stated in another currency', async () => {
      const who = await customer();
      const foreign = (
        await one<{ code: string }>(db, `select code from currencies where code <> $1 order by code limit 1`, [home])
      ).code;
      const a = await line({ amount: 10, side: 'debit', contact: who });
      const b = await line({ amount: 10, side: 'credit', contact: who, state: 'draft' });
      await db.query(`update entry_lines set currency_code = $2, amount_currency = -12 where id = $1`, [b, foreign]);
      await db.query(`select post_entry(entry_id) from entry_lines where id = $1`, [b]);
      expect(await expectError(db, `select * from reconcile_many($1)`, [[a, b]])).toMatch(/^reconcile_foreign_currency:/);
    });

    it('a line with nothing left open', async () => {
      const who = await customer();
      const a = await line({ amount: 10, side: 'debit', contact: who });
      const b = await line({ amount: 10, side: 'credit', contact: who });
      const c = await line({ amount: 10, side: 'credit', contact: who });
      await db.query(`select * from reconcile_many($1)`, [[a, b]]);
      expect(await expectError(db, `select * from reconcile_many($1)`, [[a, c]])).toMatch(/^line_not_open:/);
    });

    it('two debits', async () => {
      const who = await customer();
      const a = await line({ amount: 10, side: 'debit', contact: who });
      const b = await line({ amount: 10, side: 'debit', contact: who });
      expect(await expectError(db, `select * from reconcile_many($1)`, [[a, b]])).toMatch(/^reconcile_same_side:/);
    });

    it('totals a cent apart, and leaves both lines open', async () => {
      const who = await customer();
      const a = await line({ amount: 10, side: 'debit', contact: who });
      const b = await line({ amount: 10 - unit, side: 'credit', contact: who });
      expect(await expectError(db, `select * from reconcile_many($1)`, [[a, b]])).toMatch(
        /^reconcile_unbalanced: .*reconcile_with_difference/,
      );
      expect(await openOf(a)).toBe(10);
    });
  });

  it('answers a stranger about a line of this company as about a line that does not exist', async () => {
    const stranger = await newUser(db);
    const strangers = await newCompany(db, { name: 'Stranger Books', ownerId: stranger });
    const theirReceivable = await accountOfType(strangers.companyId, `account_type = 'asset_receivable' and reconcilable`);
    const theirIncome = await accountOfType(strangers.companyId, `account_type = 'income' and not reconcilable`);
    const own = await line({
      amount: 10,
      side: 'debit',
      companyId: strangers.companyId,
      account: theirReceivable,
      other: theirIncome,
    });
    const who = await customer();
    const mine = await line({ amount: 10, side: 'credit', contact: who });
    const theirs = await refusalAs(db, stranger, `select * from reconcile_many($1)`, [[own, mine]]);
    const nobodys = await refusalAs(db, stranger, `select * from reconcile_many($1)`, [[own, NOWHERE]]);
    expect(theirs.replace(UUID, '<id>')).toBe(nobodys.replace(UUID, '<id>'));
    expect(theirs).toMatch(/^unknown_line:/);
  });
});

describe('reconcile_with_difference()', () => {
  it('exposes the tolerance, in units and as an amount, and follows the company setting', async () => {
    const tolerance = await one<{ tolerance_units: number; tolerance: string; currency_code: string }>(
      db,
      `select * from matching_difference_tolerance($1)`,
      [fx.companyId],
    );
    expect(tolerance.tolerance_units).toBe(500);
    expect(Number(tolerance.tolerance)).toBeCloseTo(500 * unit, 10);
    expect(tolerance.currency_code).toBe(home);

    const strict = await newCompany(db, { name: 'Strict Differences' });
    await db.query(`insert into matching_settings (company_id, difference_tolerance_units) values ($1, 100)`, [
      strict.companyId,
    ]);
    const policy = await one<{ difference_tolerance_units: number; amount_tolerance_units: number }>(
      db,
      `select * from matching_policy_of($1)`,
      [strict.companyId],
    );
    expect(policy.difference_tolerance_units).toBe(100);
    // The tolerance of what is applied without anybody does not move with it.
    expect(policy.amount_tolerance_units).toBe(1);
  });

  it('exposes the reasons with the accounts the pack gives', async () => {
    const reasons = await rows<{ reason: string; side: string; account_id: string | null; available: boolean }>(
      db,
      `select * from matching_difference_reasons($1)`,
      [fx.companyId],
    );
    expect(reasons.map((r) => `${r.reason}/${r.side}`)).toEqual([
      'rounding/either',
      'exchange_difference/charge',
      'exchange_difference/income',
    ]);
    const rounding = await one<{ rounding_account_id: string }>(
      db,
      `select rounding_account_id from companies where id = $1`,
      [fx.companyId],
    );
    expect(reasons[0]!.account_id).toBe(rounding.rounding_account_id);
    const fxAccounts = await one<{ loss: string | null; gain: string | null }>(
      db,
      `select account_id_by_code(c.id, d.fx_loss_code) as loss, account_id_by_code(c.id, d.fx_gain_code) as gain
         from companies c join country_defaults d on d.country = c.country where c.id = $1`,
      [fx.companyId],
    );
    expect(reasons[1]!.account_id).toBe(fxAccounts.loss);
    expect(reasons[2]!.account_id).toBe(fxAccounts.gain);
  });

  it('books a short payment on the rounding account of the pack, and matches everything', async () => {
    const who = await customer();
    const invoice = await line({ amount: 100, side: 'debit', contact: who, date: '2026-03-01' });
    const payment = await line({ amount: 97, side: 'credit', contact: who, date: '2026-03-20' });

    const done = await asUser(db, accountant, () =>
      one<Matched>(db, `select * from reconcile_with_difference($1, 'rounding')`, [[invoice, payment]]),
    );
    expect(Number(done.difference)).toBe(3);
    expect(Number(done.amount)).toBe(100);
    expect(done.adjustment_entry_id).not.toBeNull();

    const entry = await one<{ state: string; entry_date: string; journal_id: string; misc: string }>(
      db,
      `select e.state, e.entry_date::text, e.journal_id, c.miscellaneous_journal_id as misc
         from entries e join companies c on c.id = e.company_id where e.id = $1`,
      [done.adjustment_entry_id],
    );
    expect(entry.state).toBe('posted');
    expect(entry.entry_date).toBe('2026-03-20');
    expect(entry.journal_id).toBe(entry.misc);

    const booked = await rows<{ account_id: string; debit: string; credit: string; contact_id: string | null }>(
      db,
      `select account_id, debit, credit, contact_id from entry_lines where entry_id = $1 order by sequence`,
      [done.adjustment_entry_id],
    );
    const rounding = (
      await one<{ id: string }>(db, `select rounding_account_id as id from companies where id = $1`, [fx.companyId])
    ).id;
    expect(booked).toEqual([
      { account_id: receivable, debit: '0.00', credit: '3.00', contact_id: who },
      { account_id: rounding, debit: '3.00', credit: '0.00', contact_id: null },
    ]);
    for (const id of [invoice, payment]) expect(await openOf(id)).toBe(0);
    const letters = await rows(
      db,
      `select distinct l.matching_number from entry_lines l
        where l.id = any($1) or (l.entry_id = $2 and l.account_id = $3)`,
      [[invoice, payment], done.adjustment_entry_id, receivable],
    );
    expect(letters).toHaveLength(1);
    const marked = await rows(db, `select id from reconciliations where adjustment_entry_id = $1`, [
      done.adjustment_entry_id,
    ]);
    expect(marked).toHaveLength(1);
  });

  it('books an overpayment as an exchange gain, a short one as a loss, on the pack accounts', async () => {
    const reasons = await rows<{ side: string; account_id: string; available: boolean }>(
      db,
      `select side, account_id, available from matching_difference_reasons($1) where reason = 'exchange_difference'`,
      [fx.companyId],
    );
    expect(reasons.every((r) => r.available)).toBe(true);
    const gain = reasons.find((r) => r.side === 'income')!.account_id;
    const loss = reasons.find((r) => r.side === 'charge')!.account_id;

    const who = await customer();
    const invoice = await line({ amount: 100, side: 'debit', contact: who });
    const payment = await line({ amount: 102, side: 'credit', contact: who });
    const done = await one<Matched>(db, `select * from reconcile_with_difference($1, 'exchange_difference')`, [
      [invoice, payment],
    ]);
    expect(Number(done.difference)).toBe(-2);
    const onGain = await one<{ credit: string }>(
      db,
      `select credit from entry_lines where entry_id = $1 and account_id = $2`,
      [done.adjustment_entry_id, gain],
    );
    expect(onGain.credit).toBe('2.00');

    const short = await line({ amount: 50, side: 'debit', contact: who });
    const shortPaid = await line({ amount: 49, side: 'credit', contact: who });
    const lost = await one<Matched>(db, `select * from reconcile_with_difference($1, 'exchange_difference')`, [
      [short, shortPaid],
    ]);
    const onLoss = await one<{ debit: string }>(
      db,
      `select debit from entry_lines where entry_id = $1 and account_id = $2`,
      [lost.adjustment_entry_id, loss],
    );
    expect(onLoss.debit).toBe('1.00');
  });

  it('closes a combination a little apart: three invoices paid net of a charge', async () => {
    const who = await customer();
    const invoices = [
      await line({ amount: 100, side: 'debit', contact: who }),
      await line({ amount: 100, side: 'debit', contact: who }),
      await line({ amount: 100, side: 'debit', contact: who }),
    ];
    const payment = await line({ amount: 296.5, side: 'credit', contact: who });
    const proposed = (await proposals(who)).find((p) => p.line_id === payment);
    expect(proposed?.kind).toBe('combination');
    expect(Number(proposed?.difference)).toBe(-3.5);

    const done = await one<Matched>(db, `select * from reconcile_with_difference($1, 'rounding')`, [
      [payment, ...proposed!.line_ids],
    ]);
    expect(Number(done.difference)).toBe(3.5);
    for (const id of [payment, ...invoices]) expect(await openOf(id)).toBe(0);
  });

  describe('refuses, by name', () => {
    it('a reason it does not know, or none', async () => {
      const who = await customer();
      const a = await line({ amount: 10, side: 'debit', contact: who });
      const b = await line({ amount: 9, side: 'credit', contact: who });
      expect(await expectError(db, `select * from reconcile_with_difference($1, 'bank_charges')`, [[a, b]])).toMatch(
        /^unknown_difference_reason:/,
      );
      expect(await expectError(db, `select * from reconcile_with_difference($1, null)`, [[a, b]])).toMatch(
        /^unknown_difference_reason:/,
      );
    });

    it('no difference', async () => {
      const who = await customer();
      const a = await line({ amount: 10, side: 'debit', contact: who });
      const b = await line({ amount: 10, side: 'credit', contact: who });
      expect(await expectError(db, `select * from reconcile_with_difference($1, 'rounding')`, [[a, b]])).toMatch(
        /^no_difference: .*reconcile_many/,
      );
    });

    it('a difference above the company tolerance, which moves with its setting', async () => {
      const who = await customer();
      const a = await line({ amount: 10, side: 'debit', contact: who });
      const b = await line({ amount: 7, side: 'credit', contact: who });
      await db.query(
        `insert into matching_settings (company_id, difference_tolerance_units) values ($1, 100)
         on conflict (company_id) do update set difference_tolerance_units = 100`,
        [fx.companyId],
      );
      try {
        expect(await expectError(db, `select * from reconcile_with_difference($1, 'rounding')`, [[a, b]])).toMatch(
          /^difference_above_tolerance: the lines are 3\.00 apart/,
        );
        expect(await openOf(a)).toBe(10);
      } finally {
        await db.query(`update matching_settings set difference_tolerance_units = null where company_id = $1`, [
          fx.companyId,
        ]);
      }
      // Back to the shipped answer, the same difference is booked.
      const done = await one<Matched>(db, `select * from reconcile_with_difference($1, 'rounding')`, [[a, b]]);
      expect(Number(done.difference)).toBe(3);
    });

    it('two counterparties, two accounts: never on another account or contact', async () => {
      const a = await line({ amount: 10, side: 'debit', contact: await customer() });
      const b = await line({ amount: 9, side: 'credit', contact: await customer() });
      expect(await expectError(db, `select * from reconcile_with_difference($1, 'rounding')`, [[a, b]])).toMatch(
        /^reconcile_contact_mismatch:/,
      );
      const who = await customer();
      const c = await line({ amount: 10, side: 'debit', contact: who });
      const d = await line({ amount: 9, side: 'credit', contact: who, account: otherReconcilable });
      expect(await expectError(db, `select * from reconcile_with_difference($1, 'rounding')`, [[c, d]])).toMatch(
        /^reconcile_account_mismatch:/,
      );
    });

    it('a reason the company has no account for, or an account that takes no entry', async () => {
      const bare = await newCompany(db, { name: 'No Rounding Account' });
      const theirReceivable = await accountOfType(bare.companyId, `account_type = 'asset_receivable' and reconcilable`);
      const theirIncome = await accountOfType(bare.companyId, `account_type = 'income' and not reconcilable`);
      const a = await line({ amount: 10, side: 'debit', companyId: bare.companyId, account: theirReceivable, other: theirIncome });
      const b = await line({ amount: 9, side: 'credit', companyId: bare.companyId, account: theirReceivable, other: theirIncome });

      await db.query(`update companies set rounding_account_id = null where id = $1`, [bare.companyId]);
      const reasons = await rows<{ reason: string; available: boolean; because: string }>(
        db,
        `select * from matching_difference_reasons($1) where reason = 'rounding'`,
        [bare.companyId],
      );
      expect(reasons[0]!.available).toBe(false);
      expect(await expectError(db, `select * from reconcile_with_difference($1, 'rounding')`, [[a, b]])).toMatch(
        /^no_account_for_reason:/,
      );

      const reconcilable = await accountOfType(bare.companyId, `reconcilable and account_type not in ('asset_receivable', 'liability_payable')`);
      await db.query(`update companies set rounding_account_id = $2 where id = $1`, [bare.companyId, reconcilable]);
      expect(await expectError(db, `select * from reconcile_with_difference($1, 'rounding')`, [[a, b]])).toMatch(
        /^account_takes_no_entries:/,
      );
    });

    it('a member who may not match', async () => {
      const who = await customer();
      const a = await line({ amount: 10, side: 'debit', contact: who });
      const b = await line({ amount: 9, side: 'credit', contact: who });
      expect(await refusalAs(db, viewer, `select * from reconcile_with_difference($1, 'rounding')`, [[a, b]])).toMatch(
        /^not_allowed: .*reconcile\.write/,
      );
    });
  });

  it('is undone by unreconcile(), which takes the difference back with its mirror', async () => {
    const who = await customer();
    const invoice = await line({ amount: 100, side: 'debit', contact: who, date: '2026-03-01' });
    const payment = await line({ amount: 98, side: 'credit', contact: who, date: '2026-03-02' });
    const done = await one<Matched>(db, `select * from reconcile_with_difference($1, 'rounding')`, [[invoice, payment]]);
    const marked = await one<{ id: string }>(db, `select id from reconciliations where adjustment_entry_id = $1`, [
      done.adjustment_entry_id,
    ]);

    // The entry of the difference is matched, so it is not reversed by hand.
    expect(await expectError(db, `select reverse_entry($1)`, [done.adjustment_entry_id])).toMatch(/^entry_/);

    await asUser(db, accountant, () => db.query(`select unreconcile($1)`, [marked.id]));

    const mirror = await one<{ id: string; state: string }>(
      db,
      `select id, state from entries where reversed_entry_id = $1`,
      [done.adjustment_entry_id],
    );
    expect(mirror.state).toBe('posted');
    const thirdParty = await rows<{ open: string }>(
      db,
      `select abs(balance) - matched_amount as open from entry_lines
        where entry_id in ($1, $2) and account_id = $3`,
      [done.adjustment_entry_id, mirror.id, receivable],
    );
    expect(thirdParty.map((r) => Number(r.open))).toEqual([0, 0]);
    // The invoice has its difference open again; the payment stays matched.
    expect(await openOf(invoice)).toBe(2);
    expect(await openOf(payment)).toBe(0);
    const rounding = (
      await one<{ id: string }>(db, `select rounding_account_id as id from companies where id = $1`, [fx.companyId])
    ).id;
    const net = await one<{ net: string }>(
      db,
      `select coalesce(sum(debit - credit), 0) as net from entry_lines where entry_id in ($1, $2) and account_id = $3`,
      [done.adjustment_entry_id, mirror.id, rounding],
    );
    expect(Number(net.net)).toBe(0);
  });
});

describe('payable lines', () => {
  it('match the same way: a supplier paid in one transfer for two invoices', async () => {
    const supplier = await newContact(db, fx.companyId, { name: 'Supplier Combination Works', type: 'supplier' });
    const expense = await accountOfType(fx.companyId, `account_type = 'expense' and not reconcilable`);
    const a = await line({ amount: 40, side: 'credit', contact: supplier, account: payable, other: expense });
    const b = await line({ amount: 60, side: 'credit', contact: supplier, account: payable, other: expense });
    const paid = await line({ amount: 100, side: 'debit', contact: supplier, account: payable, other: expense });
    const found = (await proposals(supplier)).find((p) => p.line_id === paid);
    expect(sorted(found!.line_ids)).toEqual(sorted([a, b]));
    const done = await one<Matched>(db, `select * from reconcile_many($1)`, [[paid, a, b]]);
    expect(done.reconciliation_ids).toHaveLength(2);
  });
});
