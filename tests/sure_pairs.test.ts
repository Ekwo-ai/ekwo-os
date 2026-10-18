import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, freshDatabase, one, rows, withoutTrigger } from './helpers/db.js';
import { newCompany, newContact, newDocument, newUser, type Fixture } from './helpers/factory.js';
import { newMember, plainSale, refusalAs } from './helpers/integrity.js';

// Decision 0075: the pairs that leave nothing to choose are said by one
// function and matched in one gesture, undone as one; and what undoes an
// entry — a reversal, a credit note naming its invoice — is matched with it
// as it is posted.

let db: PGlite;
let fx: Fixture;
let accountant: string;
let viewer: string;
let receivable: string;
let payable: string;
let income: string;
let names = 0;

interface Pair {
  debit_line_id: string;
  credit_line_id: string;
  contact_id: string;
  account_id: string;
  amount: string;
  evidence: string;
}

interface Batch {
  id: string;
  company_id: string;
  pair_count: number;
  amount: string;
  created_by: string | null;
  undone_at: string | null;
  undone_by: string | null;
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
 * `contact`, against `other`. Returns the line on `account` and its entry.
 */
async function item(options: {
  amount: number;
  side: 'debit' | 'credit';
  contact?: string | null;
  account?: string;
  other?: string;
  date?: string;
  reference?: string;
  reverses?: string;
  companyId?: string;
  post?: boolean;
}): Promise<{ line: string; entry: string }> {
  const companyId = options.companyId ?? fx.companyId;
  const entry = await one<{ id: string }>(
    db,
    `insert into entries (company_id, journal_id, entry_date, state, currency_code, description, reference, reversed_entry_id)
     select c.id, c.miscellaneous_journal_id, $2::date, 'draft', c.currency_code, 'Item', $3, $4 from companies c where c.id = $1
     returning id`,
    [companyId, options.date ?? '2026-04-02', options.reference ?? null, options.reverses ?? null],
  );
  const [debit, credit] = options.side === 'debit' ? [options.amount, 0] : [0, options.amount];
  const created = await one<{ id: string }>(
    db,
    `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit, contact_id)
     values ($1, $2, $3, 10, 'Item', $4, $5, $6) returning id`,
    [entry.id, companyId, options.account ?? receivable, debit, credit, options.contact ?? null],
  );
  await db.query(
    `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit)
     values ($1, $2, $3, 20, 'Item', $4, $5)`,
    [entry.id, companyId, options.other ?? income, credit, debit],
  );
  if (options.post ?? true) await db.query(`select post_entry($1)`, [entry.id]);
  return { line: created.id, entry: entry.id };
}

async function line(options: Parameters<typeof item>[0]): Promise<string> {
  return (await item(options)).line;
}

async function customer(): Promise<string> {
  return newContact(db, fx.companyId, { name: `Party ${(names += 1).toString().padStart(3, '0')} Ltd` });
}

async function sure(contact: string | null, companyId = fx.companyId): Promise<Pair[]> {
  return rows<Pair>(db, `select * from suggest_sure_pairs($1, $2)`, [companyId, contact]);
}

const pairOf = (p: Pair): [string, string] => [p.debit_line_id, p.credit_line_id];

async function openOf(lineId: string): Promise<number> {
  return Number(
    (await one<{ open: string }>(db, `select abs(balance) - matched_amount as open from entry_lines where id = $1`, [lineId]))
      .open,
  );
}

async function batchOf(pairs: unknown, who = accountant): Promise<Batch> {
  return asUser(db, who, () => one<Batch>(db, `select * from reconcile_batch($1::jsonb)`, [JSON.stringify(pairs)]));
}

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db);
  accountant = await newMember(db, fx.companyId, 'accountant');
  viewer = await newMember(db, fx.companyId, 'viewer');
  receivable = await accountOfType(fx.companyId, `account_type = 'asset_receivable' and reconcilable`);
  payable = await accountOfType(fx.companyId, `account_type = 'liability_payable' and reconcilable`);
  income = await accountOfType(fx.companyId, `account_type = 'income' and not reconcilable`);
}, 300_000);

afterAll(async () => {
  await db?.close();
});

// ---------------------------------------------------------------------------
// The rules
// ---------------------------------------------------------------------------

describe('suggest_sure_pairs()', () => {
  it('pairs the one open debit and the one open credit of an amount', async () => {
    const who = await customer();
    const invoice = await line({ amount: 1200, side: 'debit', contact: who, date: '2026-03-01' });
    const payment = await line({ amount: 1200, side: 'credit', contact: who, date: '2026-03-20' });
    // Another amount of the same party is no pair of anything.
    await line({ amount: 80, side: 'debit', contact: who });

    const found = await sure(who);
    expect(found).toHaveLength(1);
    expect(found[0]).toMatchObject({
      debit_line_id: invoice,
      credit_line_id: payment,
      contact_id: who,
      account_id: receivable,
      evidence: 'unique_amount',
    });
    expect(Number(found[0]!.amount)).toBe(1200);
  });

  it('says nothing of an amount a cent apart, of two parties or of two accounts', async () => {
    const who = await customer();
    await line({ amount: 100, side: 'debit', contact: who });
    await line({ amount: 100.01, side: 'credit', contact: who });
    expect(await sure(who)).toEqual([]);

    const one_ = await customer();
    const other = await customer();
    await line({ amount: 77, side: 'debit', contact: one_ });
    await line({ amount: 77, side: 'credit', contact: other });
    expect(await sure(one_)).toEqual([]);
    expect(await sure(other)).toEqual([]);

    const both = await customer();
    await line({ amount: 66, side: 'debit', contact: both, account: receivable });
    await line({ amount: 66, side: 'credit', contact: both, account: payable });
    expect(await sure(both)).toEqual([]);

    // Asked for the whole company, none of them either.
    const all = await sure(null);
    expect(all.filter((p) => [who, one_, other, both].includes(p.contact_id))).toEqual([]);
  });

  it('pairs a recurring amount in date order, each invoice with the first settlement on or after it', async () => {
    const who = await customer();
    // A settlement before every invoice: nobody's pair under this rule.
    const early = await line({ amount: 49, side: 'credit', contact: who, date: '2025-12-20' });
    const march = await line({ amount: 49, side: 'debit', contact: who, date: '2026-03-01' });
    const january = await line({ amount: 49, side: 'debit', contact: who, date: '2026-01-01' });
    const february = await line({ amount: 49, side: 'debit', contact: who, date: '2026-02-01' });
    const paidFebruary = await line({ amount: 49, side: 'credit', contact: who, date: '2026-02-05' });
    const paidJanuary = await line({ amount: 49, side: 'credit', contact: who, date: '2026-01-01' });
    const paidMarch = await line({ amount: 49, side: 'credit', contact: who, date: '2026-03-07' });

    const found = await sure(who);
    expect(found.map((p) => p.evidence)).toEqual(Array(3).fill('recurring_in_date_order'));
    expect(found.map(pairOf)).toEqual([
      [january, paidJanuary],
      [february, paidFebruary],
      [march, paidMarch],
    ]);
    expect(found.flatMap(pairOf)).not.toContain(early);
  });

  it('never pairs a recurring invoice with a settlement dated before it', async () => {
    const who = await customer();
    const before = await line({ amount: 30, side: 'credit', contact: who, date: '2026-02-01' });
    const first = await line({ amount: 30, side: 'debit', contact: who, date: '2026-03-01' });
    const after = await line({ amount: 30, side: 'credit', contact: who, date: '2026-03-10' });
    const second = await line({ amount: 30, side: 'debit', contact: who, date: '2026-04-01' });

    const found = await sure(who);
    expect(found.map(pairOf)).toEqual([[first, after]]);
    expect(found.flatMap(pairOf)).not.toContain(before);
    expect(found.flatMap(pairOf)).not.toContain(second);
  });

  it('reads the invoice of a payable on the credit side', async () => {
    const who = await customer();
    const january = await line({ amount: 15, side: 'credit', contact: who, account: payable, date: '2026-01-10' });
    const february = await line({ amount: 15, side: 'credit', contact: who, account: payable, date: '2026-02-10' });
    const paidFebruary = await line({ amount: 15, side: 'debit', contact: who, account: payable, date: '2026-02-12' });
    const paidJanuary = await line({ amount: 15, side: 'debit', contact: who, account: payable, date: '2026-01-12' });
    // A payment before both invoices pays neither.
    await line({ amount: 15, side: 'debit', contact: who, account: payable, date: '2025-12-01' });

    const found = await sure(who);
    expect(found.map((p) => [p.credit_line_id, p.debit_line_id])).toEqual([
      [january, paidJanuary],
      [february, paidFebruary],
    ]);
    expect(found.every((p) => p.account_id === payable && p.evidence === 'recurring_in_date_order')).toBe(true);
  });

  it('pairs a unique amount whichever is older: the rule of dates is the recurring one', async () => {
    const who = await customer();
    const prepaid = await line({ amount: 250, side: 'credit', contact: who, date: '2026-01-05' });
    const invoice = await line({ amount: 250, side: 'debit', contact: who, date: '2026-02-01' });
    expect((await sure(who)).map(pairOf)).toEqual([[invoice, prepaid]]);
  });

  it('pairs an entry with the entry that undoes it before reading the amounts', async () => {
    const who = await customer();
    const original = await item({ amount: 40, side: 'debit', contact: who, date: '2026-03-01' });
    // A payment of the same amount dated after: by the amounts alone, the
    // invoice's pair would be read in date order.
    const payment = await line({ amount: 40, side: 'credit', contact: who, date: '2026-03-02' });
    // A reversal posted without its matching — by somebody the posting does
    // not match for, or before decision 0075.
    const reversal = await withoutTrigger(db, 'entries', 'entries_match_reversal_on_posting', () =>
      item({ amount: 40, side: 'credit', contact: who, date: '2026-03-05', reverses: original.entry }),
    );
    expect(await openOf(reversal.line)).toBe(40);

    const found = await sure(who);
    expect(found).toEqual([
      expect.objectContaining({ debit_line_id: original.line, credit_line_id: reversal.line, evidence: 'reversal' }),
    ]);
    expect(found.flatMap(pairOf)).not.toContain(payment);
  });

  it('pairs a document with the settlement that carries its number, before reading the amounts', async () => {
    const who = await customer();
    const sale = await plainSale(db, fx.companyId);
    const doc = await newDocument(db, fx.companyId, {
      docType: 'sale_invoice',
      number: `SURE-${names}`,
      contactId: who,
      date: '2026-05-04',
      lines: [{ unitPrice: 300, taxCode: sale.taxCode, accountCode: sale.accountCode }],
    });
    await db.query(`select post_document($1)`, [doc]);
    const third = await one<{ id: string; account_id: string; total: string }>(
      db,
      `select l.id, l.account_id, (l.debit - l.credit)::text as total
         from entry_lines l join documents d on d.entry_id = l.entry_id join accounts a on a.id = l.account_id
        where d.id = $1 and a.reconcilable`,
      [doc],
    );
    const total = Number(third.total);
    // Two settlements of the total: the one that names the document is its
    // pair, wherever it falls in time.
    const other = await line({ amount: total, side: 'credit', contact: who, account: third.account_id, date: '2026-05-05' });
    const named = await line({
      amount: total,
      side: 'credit',
      contact: who,
      account: third.account_id,
      date: '2026-06-30',
      reference: ` sure-${names} `,
    });

    const found = await sure(who);
    expect(found).toEqual([
      expect.objectContaining({ debit_line_id: third.id, credit_line_id: named, evidence: 'same_document' }),
    ]);
    expect(found.flatMap(pairOf)).not.toContain(other);
  });

  it('keeps one party when asked, and a branch and its parent are one', async () => {
    const parent = await customer();
    const branch = await newContact(db, fx.companyId, { name: `Branch ${names} Ltd` });
    await db.query(`update contacts set parent_id = $2 where id = $1`, [branch, parent]);
    const invoice = await line({ amount: 333, side: 'debit', contact: parent });
    const payment = await line({ amount: 333, side: 'credit', contact: branch });
    const found = await sure(branch);
    expect(found.map(pairOf)).toEqual([[invoice, payment]]);
    expect(found[0]!.contact_id).toBe(parent);
  });

  it('answers a stranger about a company as about one that does not exist', async () => {
    const stranger = await newUser(db);
    expect(await asUser(db, stranger, () => sure(null, fx.companyId))).toEqual([]);
    expect(await asUser(db, stranger, () => sure(null, NOWHERE))).toEqual([]);
    expect(await asUser(db, viewer, () => sure(null, fx.companyId))).not.toEqual([]);
  });
});

// ---------------------------------------------------------------------------
// One gesture, undone as one
// ---------------------------------------------------------------------------

describe('reconcile_batch() and unreconcile_batch()', () => {
  it('matches every sure pair of a party in one gesture, and undoes it as one', async () => {
    const who = await customer();
    for (const day of ['01', '02', '03']) {
      await line({ amount: 20, side: 'debit', contact: who, date: `2026-07-${day}` });
      await line({ amount: 20, side: 'credit', contact: who, date: `2026-07-${day}` });
    }
    await line({ amount: 75, side: 'debit', contact: who });
    await line({ amount: 75, side: 'credit', contact: who });

    const pairs = await sure(who);
    expect(pairs).toHaveLength(4);
    const lines = pairs.flatMap(pairOf);

    const batch = await batchOf(pairs.map((p) => ({ debit_line_id: p.debit_line_id, credit_line_id: p.credit_line_id })));
    expect(batch).toMatchObject({ company_id: fx.companyId, pair_count: 4, created_by: accountant, undone_at: null });
    expect(Number(batch.amount)).toBe(135);
    for (const id of lines) expect(await openOf(id)).toBe(0);
    expect(await sure(who)).toEqual([]);

    const named = await rows<{ id: string }>(db, `select id from reconciliations where batch_id = $1`, [batch.id]);
    expect(named).toHaveLength(4);
    const trail = await rows<{ action: string }>(
      db,
      `select action from audit_log where table_name = 'reconciliation_batches' and record_key = $1`,
      [batch.id],
    );
    expect(trail.map((t) => t.action)).toContain('matching_batch_made');

    const undone = await asUser(db, accountant, () =>
      one<Batch>(db, `select * from unreconcile_batch($1)`, [batch.id]),
    );
    expect(undone.undone_by).toBe(accountant);
    expect(undone.undone_at).not.toBeNull();
    for (const id of lines) expect(await openOf(id)).toBeGreaterThan(0);
    expect(await rows(db, `select id from reconciliations where batch_id = $1`, [batch.id])).toEqual([]);
    expect((await sure(who)).map(pairOf)).toEqual(pairs.map(pairOf));

    expect(await refusalAs(db, accountant, `select unreconcile_batch($1)`, [batch.id])).toMatch(/^batch_already_undone:/);
  });

  it('takes pairs as arrays too, and undoes what is still standing of a batch', async () => {
    const who = await customer();
    const a = await line({ amount: 11, side: 'debit', contact: who });
    const b = await line({ amount: 11, side: 'credit', contact: who });
    const c = await line({ amount: 12, side: 'debit', contact: who });
    const d = await line({ amount: 12, side: 'credit', contact: who });
    const batch = await batchOf([
      [b, a],
      [c, d],
    ]);
    expect(batch.pair_count).toBe(2);

    // One matching of the batch undone by hand: the batch undoes the other.
    const first = await one<{ id: string }>(db, `select id from reconciliations where debit_line_id = $1`, [a]);
    await asUser(db, accountant, () => db.query(`select unreconcile($1)`, [first.id]));
    await asUser(db, accountant, () => db.query(`select unreconcile_batch($1)`, [batch.id]));
    for (const id of [a, b, c, d]) expect(await openOf(id)).toBeGreaterThan(0);
  });

  it('refuses the whole batch on one refusal, and says which pair', async () => {
    const who = await customer();
    const a = await line({ amount: 10, side: 'debit', contact: who });
    const b = await line({ amount: 10, side: 'credit', contact: who });
    const c = await line({ amount: 10, side: 'debit', contact: who });
    const d = await line({ amount: 9, side: 'credit', contact: who });
    const before = await one<{ n: number }>(db, `select count(*)::int as n from reconciliation_batches`);

    const refused = await refusalAs(db, accountant, `select reconcile_batch($1::jsonb)`, [
      JSON.stringify([
        { debit_line_id: a, credit_line_id: b },
        { debit_line_id: c, credit_line_id: d },
      ]),
    ]);
    expect(refused).toMatch(/^reconcile_unbalanced: .*\(pair 2 of 2\)$/);

    // Outside the rolled-back transaction of refusalAs, as a caller would
    // see it: the first pair was not matched either.
    await expect(
      asUser(db, accountant, () =>
        db.query(`select reconcile_batch($1::jsonb)`, [JSON.stringify([[a, b], [c, d]])]),
      ),
    ).rejects.toThrow(/reconcile_unbalanced/);
    expect(await openOf(a)).toBe(10);
    expect(await openOf(b)).toBe(10);
    expect((await one<{ n: number }>(db, `select count(*)::int as n from reconciliation_batches`)).n).toBe(before.n);
  });

  describe('refuses, by name', () => {
    it('no pair, a pair it cannot read, a line twice', async () => {
      const who = await customer();
      const a = await line({ amount: 5, side: 'debit', contact: who });
      const b = await line({ amount: 5, side: 'credit', contact: who });
      const as = (pairs: unknown) => refusalAs(db, accountant, `select reconcile_batch($1::jsonb)`, [JSON.stringify(pairs)]);
      expect(await as([])).toMatch(/^no_pairs_named:/);
      expect(await refusalAs(db, accountant, `select reconcile_batch(null)`)).toMatch(/^no_pairs_named:/);
      expect(await as({ debit_line_id: a, credit_line_id: b })).toMatch(/^no_pairs_named:/);
      expect(await as([[a]])).toMatch(/^pair_malformed: pair 1 /);
      expect(await as([[a, b], { debit_line_id: a }])).toMatch(/^pair_malformed: pair 2 /);
      expect(await as([[a, 'not a line']])).toMatch(/^pair_malformed:/);
      expect(await as([[a, a]])).toMatch(/^duplicate_line:/);
      expect(await as([[a, b], [b, a]])).toMatch(/^duplicate_line:/);
      expect(await as([[a, NOWHERE]])).toMatch(/^unknown_line:/);
    });

    it('a member who may not match, and each refusal of a matching', async () => {
      const who = await customer();
      const a = await line({ amount: 5, side: 'debit', contact: who });
      const b = await line({ amount: 5, side: 'credit', contact: who });
      expect(await refusalAs(db, viewer, `select reconcile_batch($1::jsonb)`, [JSON.stringify([[a, b]])])).toMatch(
        /^not_allowed:/,
      );

      const draft = await line({ amount: 5, side: 'credit', contact: who, post: false });
      expect(await refusalAs(db, accountant, `select reconcile_batch($1::jsonb)`, [JSON.stringify([[a, draft]])])).toMatch(
        /^line_not_posted: .*\(pair 1 of 1\)$/,
      );
      const stranger = await line({ amount: 5, side: 'credit', contact: await customer() });
      expect(await refusalAs(db, accountant, `select reconcile_batch($1::jsonb)`, [JSON.stringify([[a, stranger]])])).toMatch(
        /^reconcile_contact_mismatch: .*\(pair 1 of 1\)$/,
      );
      const twin = await line({ amount: 5, side: 'debit', contact: who });
      expect(await refusalAs(db, accountant, `select reconcile_batch($1::jsonb)`, [JSON.stringify([[a, twin]])])).toMatch(
        /^reconcile_same_side: .*\(pair 1 of 1\)$/,
      );
      expect(await openOf(a)).toBe(5);
      expect(await openOf(b)).toBe(5);
    });

    it('a batch written or undone by hand', async () => {
      expect(
        await refusalAs(db, accountant, `insert into reconciliation_batches (company_id, pair_count, amount) values ($1, 1, 1)`, [
          fx.companyId,
        ]),
      ).toMatch(/^batch_by_reconcile_batch:/);

      const who = await customer();
      const a = await line({ amount: 6, side: 'debit', contact: who });
      const b = await line({ amount: 6, side: 'credit', contact: who });
      const batch = await batchOf([[a, b]]);
      expect(
        await refusalAs(
          db,
          accountant,
          `update reconciliation_batches set undone_at = now(), undone_by = $2 where id = $1`,
          [batch.id, accountant],
        ),
      ).toMatch(/^batch_by_reconcile_batch:/);
      expect(await refusalAs(db, accountant, `delete from reconciliation_batches where id = $1`, [batch.id])).toMatch(
        /permission denied/,
      );
      expect(await refusalAs(db, viewer, `select unreconcile_batch($1)`, [batch.id])).toMatch(/^not_allowed:/);
      expect(await refusalAs(db, accountant, `select unreconcile_batch($1)`, [NOWHERE])).toMatch(/^unknown_batch:/);
    });
  });

  it('answers a stranger about a line or a batch of this company as about nothing', async () => {
    const stranger = await newUser(db);
    const strangers = await newCompany(db, { name: 'Stranger Batches', ownerId: stranger });
    const theirReceivable = await accountOfType(strangers.companyId, `account_type = 'asset_receivable' and reconcilable`);
    const theirIncome = await accountOfType(strangers.companyId, `account_type = 'income' and not reconcilable`);
    const theirContact = await newContact(db, strangers.companyId, { name: 'Their Customer Ltd' });
    const own = await line({
      amount: 8,
      side: 'debit',
      contact: theirContact,
      companyId: strangers.companyId,
      account: theirReceivable,
      other: theirIncome,
    });

    const who = await customer();
    const a = await line({ amount: 8, side: 'debit', contact: who });
    const b = await line({ amount: 8, side: 'credit', contact: who });
    const batch = await batchOf([[a, b]]);

    const theirs = await refusalAs(db, stranger, `select reconcile_batch($1::jsonb)`, [JSON.stringify([[own, b]])]);
    const nobodys = await refusalAs(db, stranger, `select reconcile_batch($1::jsonb)`, [JSON.stringify([[own, NOWHERE]])]);
    expect(theirs).toMatch(/^unknown_line:/);
    expect(theirs.replace(UUID, '<id>')).toBe(nobodys.replace(UUID, '<id>'));

    const undoTheirs = await refusalAs(db, stranger, `select unreconcile_batch($1)`, [batch.id]);
    const undoNobodys = await refusalAs(db, stranger, `select unreconcile_batch($1)`, [NOWHERE]);
    expect(undoTheirs).toMatch(/^unknown_batch:/);
    expect(undoTheirs.replace(UUID, '<id>')).toBe(undoNobodys.replace(UUID, '<id>'));

    expect(await asUser(db, stranger, () => rows(db, `select id from reconciliation_batches`))).toEqual([]);
    expect(await asUser(db, viewer, () => rows(db, `select id from reconciliation_batches where id = $1`, [batch.id]))).toHaveLength(1);
    expect(await openOf(b)).toBe(0);
  });
});

// ---------------------------------------------------------------------------
// Matched as it is posted
// ---------------------------------------------------------------------------

describe('what undoes an entry is matched with it as it is posted', () => {
  it('a reversal keyed by hand and posted', async () => {
    const who = await customer();
    const original = await item({ amount: 90, side: 'debit', contact: who, date: '2026-08-01' });
    const reversal = await asUser(db, accountant, () =>
      item({ amount: 90, side: 'credit', contact: who, date: '2026-08-02', reverses: original.entry }),
    );
    expect(await openOf(original.line)).toBe(0);
    expect(await openOf(reversal.line)).toBe(0);
    const matched = await one<{ debit_line_id: string; credit_line_id: string; batch_id: string | null }>(
      db,
      `select debit_line_id, credit_line_id, batch_id from reconciliations where debit_line_id = $1`,
      [original.line],
    );
    expect(matched).toEqual({ debit_line_id: original.line, credit_line_id: reversal.line, batch_id: null });

    // Undone by a person like any matching.
    await asUser(db, accountant, async () => {
      const { id } = await one<{ id: string }>(db, `select id from reconciliations where debit_line_id = $1`, [original.line]);
      await db.query(`select unreconcile($1)`, [id]);
    });
    expect(await openOf(original.line)).toBe(90);
    expect(await openOf(reversal.line)).toBe(90);
  });

  it('a reversal by reverse_entry(), matched once', async () => {
    const who = await customer();
    const original = await item({ amount: 91, side: 'debit', contact: who, date: '2026-08-01' });
    await asUser(db, accountant, () => db.query(`select reverse_entry($1)`, [original.entry]));
    expect(await openOf(original.line)).toBe(0);
    const count = await one<{ n: number }>(
      db,
      `select count(*)::int as n from reconciliations where debit_line_id = $1 or credit_line_id = $1`,
      [original.line],
    );
    expect(count.n).toBe(1);
  });

  it('is left open for a member who may not match, and proposed as a sure pair', async () => {
    const who = await customer();
    const original = await item({ amount: 92, side: 'debit', contact: who, date: '2026-08-01' });
    const poster = await newMember(db, fx.companyId, 'accountant');
    await db.query(
      `update company_members set capabilities_revoked = array['reconcile.write'] where company_id = $1 and user_id = $2`,
      [fx.companyId, poster],
    );
    const reversal = await asUser(db, poster, () =>
      item({ amount: 92, side: 'credit', contact: who, date: '2026-08-03', reverses: original.entry }),
    );
    expect(await openOf(original.line)).toBe(92);
    expect(await openOf(reversal.line)).toBe(92);
    expect(await sure(who)).toEqual([
      expect.objectContaining({ debit_line_id: original.line, credit_line_id: reversal.line, evidence: 'reversal' }),
    ]);
  });

  describe('a credit note that names its invoice', () => {
    async function invoiceOf(who: string, price: number): Promise<{ doc: string; line: string }> {
      const sale = await plainSale(db, fx.companyId);
      const doc = await newDocument(db, fx.companyId, {
        docType: 'sale_invoice',
        contactId: who,
        date: '2026-09-01',
        lines: [{ unitPrice: price, taxCode: sale.taxCode, accountCode: sale.accountCode }],
      });
      await db.query(`select post_document($1)`, [doc]);
      return { doc, line: await thirdPartyOf(doc) };
    }

    async function thirdPartyOf(doc: string): Promise<string> {
      return (
        await one<{ id: string }>(
          db,
          `select l.id from entry_lines l join documents d on d.entry_id = l.entry_id join accounts a on a.id = l.account_id
            where d.id = $1 and a.reconcilable`,
          [doc],
        )
      ).id;
    }

    async function creditNote(who: string, invoice: string, price: number): Promise<{ doc: string; line: string }> {
      const sale = await plainSale(db, fx.companyId);
      const doc = await newDocument(db, fx.companyId, {
        docType: 'sale_credit_note',
        contactId: who,
        date: '2026-09-10',
        lines: [{ unitPrice: price, taxCode: sale.taxCode, accountCode: sale.accountCode }],
      });
      await asUser(db, accountant, async () => {
        await db.query(`update documents set reversed_document_id = $2 where id = $1`, [doc, invoice]);
        await db.query(`select post_document($1)`, [doc]);
      });
      return { doc, line: await thirdPartyOf(doc) };
    }

    it('settles the part it credits', async () => {
      const who = await customer();
      const invoice = await invoiceOf(who, 1000);
      const before = await openOf(invoice.line);
      const credit = await creditNote(who, invoice.doc, 400);
      const credited = Number(
        (await one<{ t: string }>(db, `select abs(balance)::text as t from entry_lines where id = $1`, [credit.line])).t,
      );
      expect(await openOf(credit.line)).toBe(0);
      expect(await openOf(invoice.line)).toBeCloseTo(before - credited, 2);
      // The invoice is still posted, and paid in part.
      expect(await one(db, `select state from documents where id = $1`, [invoice.doc])).toEqual({ state: 'posted' });
    });

    it('is not matched with the invoice of another party', async () => {
      const who = await customer();
      const invoice = await invoiceOf(who, 500);
      const credit = await creditNote(await customer(), invoice.doc, 500);
      expect(await openOf(credit.line)).toBeGreaterThan(0);
      expect(await openOf(invoice.line)).toBeGreaterThan(0);
    });

    it('leaves cancel_document() as it was: one matching, the invoice cancelled', async () => {
      const who = await customer();
      const invoice = await invoiceOf(who, 700);
      await asUser(db, accountant, () => db.query(`select cancel_document($1)`, [invoice.doc]));
      expect(await openOf(invoice.line)).toBe(0);
      expect(await one(db, `select state, payment_state from documents where id = $1`, [invoice.doc])).toEqual({
        state: 'cancelled',
        payment_state: 'reversed',
      });
    });
  });

  it('matches the mirror of a difference taken back, once', async () => {
    const who = await customer();
    const a = await line({ amount: 100, side: 'debit', contact: who });
    const b = await line({ amount: 99, side: 'credit', contact: who });
    const done = await asUser(db, accountant, () =>
      one<{ adjustment_entry_id: string; reconciliation_ids: string[] }>(
        db,
        `select * from reconcile_with_difference($1, 'rounding')`,
        [[a, b]],
      ),
    );
    const withDifference = await one<{ id: string }>(
      db,
      `select id from reconciliations where id = any($1::uuid[]) and adjustment_entry_id is not null`,
      [done.reconciliation_ids],
    );
    await asUser(db, accountant, () => db.query(`select unreconcile($1)`, [withDifference.id]));
    const leftOpen = await rows(
      db,
      `select l.id from entry_lines l join entries e on e.id = l.entry_id join accounts a on a.id = l.account_id
        where (e.id = $1 or e.reversed_entry_id = $1) and a.reconcilable and abs(l.balance) > l.matched_amount`,
      [done.adjustment_entry_id],
    );
    expect(leftOpen).toEqual([]);
  });
});
