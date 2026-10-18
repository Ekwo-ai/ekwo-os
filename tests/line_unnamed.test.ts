import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, newUser, type Fixture } from './helpers/factory.js';
import { newMember, refusalAs } from './helpers/integrity.js';

// Decision 0072: a line a person decided to leave without a contact is no
// longer proposed one, and stays an open item; a text whose words reach
// several contacts by name names none of them with confidence.

let db: PGlite;
let fx: Fixture;
let accountant: string;
let viewer: string;
let receivable: string;
let payable: string;
let income: string;
let expense: string;
let otherReconcilable: string;

interface Suggestion {
  line_id: string;
  contact_id: string;
  name: string;
  score: string;
  method: string;
  because: string;
  alternatives: number;
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

/** A posted entry keyed by hand: 50 on `account`, labelled `name`, naming `contact` or nobody. */
async function line(options: {
  name: string;
  account?: string;
  other?: string;
  side?: 'debit' | 'credit';
  contact?: string | null;
  state?: 'draft' | 'posted';
  companyId?: string;
}): Promise<string> {
  const companyId = options.companyId ?? fx.companyId;
  const entry = await one<{ id: string }>(
    db,
    `insert into entries (company_id, journal_id, entry_date, state, currency_code)
     select c.id, c.miscellaneous_journal_id, '2026-04-02', 'draft', c.currency_code from companies c where c.id = $1
     returning id`,
    [companyId],
  );
  const [debit, credit] = (options.side ?? 'debit') === 'debit' ? [50, 0] : [0, 50];
  const created = await one<{ id: string }>(
    db,
    `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit, contact_id)
     values ($1, $2, $3, 10, $4, $5, $6, $7) returning id`,
    [entry.id, companyId, options.account ?? receivable, options.name, debit, credit, options.contact ?? null],
  );
  await db.query(
    `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit)
     values ($1, $2, $3, 20, $4, $5, $6)`,
    [entry.id, companyId, options.other ?? income, options.name, credit, debit],
  );
  if ((options.state ?? 'posted') === 'posted') await db.query(`select post_entry($1)`, [entry.id]);
  return created.id;
}

async function suggestionsFor(lineId: string): Promise<Suggestion[]> {
  return rows<Suggestion>(db, `select * from suggest_line_contacts($1, $2)`, [fx.companyId, [lineId]]);
}

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db);
  accountant = await newMember(db, fx.companyId, 'accountant');
  viewer = await newMember(db, fx.companyId, 'viewer');
  receivable = await accountOfType(fx.companyId, `account_type = 'asset_receivable' and reconcilable`);
  payable = await accountOfType(fx.companyId, `account_type = 'liability_payable' and reconcilable`);
  income = await accountOfType(fx.companyId, `account_type = 'income' and not reconcilable`);
  expense = await accountOfType(fx.companyId, `account_type = 'expense' and not reconcilable`);
  otherReconcilable = await accountOfType(
    fx.companyId,
    `reconcilable and account_type not in ('asset_receivable', 'liability_payable')`,
  );
  await newContact(db, fx.companyId, { name: 'Harbour Traders' });
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('leave_line_unnamed()', () => {
  it('stops the suggestions for the line, keeps it an open item, and is written to the trail', async () => {
    const lineId = await line({ name: 'Harbour Traders cash difference' });
    expect((await suggestionsFor(lineId)).length).toBeGreaterThan(0);

    const left = await asUser(db, accountant, () =>
      one<{ line_id: string; company_id: string; reason: string; created_by: string }>(
        db,
        `select * from leave_line_unnamed($1, '  A cash difference, nobody to name  ')`,
        [lineId],
      ),
    );
    expect(left).toMatchObject({ line_id: lineId, company_id: fx.companyId, reason: 'A cash difference, nobody to name' });
    expect(left.created_by).toBe(accountant);

    expect(await suggestionsFor(lineId)).toEqual([]);
    const all = await rows<Suggestion>(db, `select * from suggest_line_contacts($1)`, [fx.companyId]);
    expect(all.map((s) => s.line_id)).not.toContain(lineId);
    const open = await rows(db, `select * from open_items($1, null, null, true) where line_id = $2`, [fx.companyId, lineId]);
    expect(open).toHaveLength(1);

    const trail = await one<{ action: string; operation: string }>(
      db,
      `select action, operation::text from audit_log where table_name = 'lines_left_unnamed' and record_key = $1`,
      [lineId],
    );
    expect(trail).toEqual({ action: 'line_left_unnamed', operation: 'insert' });

    // The undo: proposed again.
    const undone = await asUser(db, accountant, () =>
      one<{ line_id: string }>(db, `select * from undo_leave_line_unnamed($1)`, [lineId]),
    );
    expect(undone.line_id).toBe(lineId);
    expect((await suggestionsFor(lineId)).length).toBeGreaterThan(0);
    const back = await rows<{ action: string }>(
      db,
      `select action from audit_log where table_name = 'lines_left_unnamed' and record_key = $1 order by occurred_at, sequence`,
      [lineId],
    );
    expect(back.map((r) => r.action)).toEqual(['line_left_unnamed', 'line_left_unnamed_undone']);
  });

  it('leaves the line free to be matched', async () => {
    const debit = await line({ name: 'Unknown deposit' });
    const credit = await line({ name: 'Unknown deposit back', side: 'credit' });
    await db.query(`select leave_line_unnamed($1, 'one-off')`, [debit]);
    await db.query(`select * from reconcile_many($1)`, [[debit, credit]]);
    const matched = await one<{ open: string }>(
      db,
      `select abs(balance) - matched_amount as open from entry_lines where id = $1`,
      [debit],
    );
    expect(Number(matched.open)).toBe(0);
  });

  describe('refuses, by name', () => {
    it('a line nobody can read', async () => {
      expect(await expectError(db, `select leave_line_unnamed($1, 'why')`, [NOWHERE])).toMatch(/^unknown_line:/);
      expect(await expectError(db, `select undo_leave_line_unnamed($1)`, [NOWHERE])).toMatch(/^unknown_line:/);
    });

    it('a member who may not match', async () => {
      const lineId = await line({ name: 'Refused to a viewer' });
      expect(await refusalAs(db, viewer, `select leave_line_unnamed($1, 'why')`, [lineId])).toMatch(
        /^not_allowed: .*reconcile\.write/,
      );
      await db.query(`select leave_line_unnamed($1, 'why')`, [lineId]);
      expect(await refusalAs(db, viewer, `select undo_leave_line_unnamed($1)`, [lineId])).toMatch(
        /^not_allowed: .*reconcile\.write/,
      );
    });

    it('no reason, or one too long', async () => {
      const lineId = await line({ name: 'No reason given' });
      expect(await expectError(db, `select leave_line_unnamed($1, null)`, [lineId])).toMatch(/^reason_required:/);
      expect(await expectError(db, `select leave_line_unnamed($1, '   ')`, [lineId])).toMatch(/^reason_required:/);
      expect(await expectError(db, `select leave_line_unnamed($1, repeat('x', 501))`, [lineId])).toMatch(
        /^reason_too_long:/,
      );
    });

    it('a draft, a line that names somebody, a line that is not a third party', async () => {
      const draft = await line({ name: 'Draft line', state: 'draft' });
      expect(await expectError(db, `select leave_line_unnamed($1, 'why')`, [draft])).toMatch(/^line_not_posted:/);
      const named = await line({ name: 'Named line', contact: await newContact(db, fx.companyId, { name: 'Named Party' }) });
      expect(await expectError(db, `select leave_line_unnamed($1, 'why')`, [named])).toMatch(/^line_has_contact:/);
      const bank = await line({ name: 'Bank side', account: otherReconcilable });
      expect(await expectError(db, `select leave_line_unnamed($1, 'why')`, [bank])).toMatch(/^line_not_third_party:/);
    });

    it('twice, and an undo of nothing', async () => {
      const lineId = await line({ name: 'Twice left' });
      await db.query(`select leave_line_unnamed($1, 'why')`, [lineId]);
      expect(await expectError(db, `select leave_line_unnamed($1, 'again')`, [lineId])).toMatch(/^line_left_unnamed:/);
      const other = await line({ name: 'Never left' });
      expect(await expectError(db, `select undo_leave_line_unnamed($1)`, [other])).toMatch(/^line_not_left_unnamed:/);
    });

    it('a row written by hand on a line of another company', async () => {
      const theirs = await newCompany(db, { name: 'Theirs' });
      const theirReceivable = await accountOfType(theirs.companyId, `account_type = 'asset_receivable' and reconcilable`);
      const theirIncome = await accountOfType(theirs.companyId, `account_type = 'income' and not reconcilable`);
      const theirLine = await line({ name: 'Theirs', companyId: theirs.companyId, account: theirReceivable, other: theirIncome });
      // The composite key keeps a row on the line's own company.
      expect(
        await expectError(db, `insert into lines_left_unnamed (line_id, company_id, reason) values ($1, $2, 'planted')`, [
          theirLine,
          fx.companyId,
        ]),
      ).toMatch(/foreign key/);
    });
  });

  it('answers a stranger about a line of this company as about a line that does not exist', async () => {
    const stranger = await newUser(db);
    await newCompany(db, { name: 'Stranger Co', ownerId: stranger });
    const lineId = await line({ name: 'Secret line' });
    await db.query(`select leave_line_unnamed($1, 'kept to ourselves')`, [lineId]);
    for (const sql of [`select leave_line_unnamed($1, 'probe')`, `select undo_leave_line_unnamed($1)`]) {
      const theirs = await refusalAs(db, stranger, sql, [lineId]);
      const nobodys = await refusalAs(db, stranger, sql, [NOWHERE]);
      expect(theirs.replace(UUID, '<id>')).toBe(nobodys.replace(UUID, '<id>'));
    }
    const seen = await asUser(db, stranger, () => rows(db, `select * from lines_left_unnamed`));
    expect(seen).toEqual([]);
  });
});

describe('a text that names several contacts', () => {
  let pedro: string;
  let microsoft: string;
  let cleverbridge: string;

  beforeAll(async () => {
    pedro = await newContact(db, fx.companyId, { name: 'Pedro Alvarez', type: 'supplier' });
    microsoft = await newContact(db, fx.companyId, { name: 'Microsoft', type: 'supplier' });
    cleverbridge = await newContact(db, fx.companyId, { name: 'Cleverbridge', type: 'supplier' });
  });

  it('"Remb Pedro Microsoft/Cleverbridge" on a payable credit: no name is confident, and each says how many', async () => {
    const lineId = await line({
      name: 'Remb Pedro Microsoft/Cleverbridge',
      account: payable,
      other: expense,
      side: 'credit',
    });
    const found = await suggestionsFor(lineId);
    const byName = found.filter((s) => s.method === 'name');
    expect(byName.map((s) => s.contact_id).sort()).toEqual([pedro, microsoft, cleverbridge].sort());
    expect(byName.every((s) => Number(s.score) <= 0.6)).toBe(true);
    expect(byName.every((s) => s.alternatives === 3)).toBe(true);
    expect(byName.every((s) => /reaches 3 contacts by name/.test(s.because))).toBe(true);
    // Microsoft is not put ahead of Pedro, whose debt it is.
    const score = (id: string) => Number(byName.find((s) => s.contact_id === id)!.score);
    expect(score(microsoft)).toBeLessThanOrEqual(score(pedro));
  });

  it('keeps a document quoted in the same text first', async () => {
    const documentId = await newDocument(db, fx.companyId, {
      docType: 'purchase_invoice',
      contactId: pedro,
      date: '2026-03-15',
      lines: [
        {
          unitPrice: 50,
          accountCode: (await one<{ code: string }>(db, `select code from accounts where id = $1`, [expense])).code,
        },
      ],
    });
    await db.query(`update documents set supplier_reference = 'PA-2026-0042' where id = $1`, [documentId]);
    const lineId = await line({
      name: 'Remb Pedro Microsoft/Cleverbridge PA-2026-0042',
      account: payable,
      other: expense,
      side: 'credit',
    });
    const found = await suggestionsFor(lineId);
    expect(found[0]!.contact_id).toBe(pedro);
    expect(found[0]!.method).toBe('document');
    expect(Number(found[0]!.score)).toBeGreaterThan(0.9);
  });

  it('leaves one name alone, and a label that is a whole name, confident', async () => {
    const alone = await line({ name: 'Licence Cleverbridge', account: payable, other: expense, side: 'credit' });
    const one_ = (await suggestionsFor(alone)).filter((s) => s.method === 'name');
    expect(one_).toHaveLength(1);
    expect(Number(one_[0]!.score)).toBeGreaterThanOrEqual(0.9);

    await newContact(db, fx.companyId, { name: 'Microsoft Ireland Operations', type: 'supplier' });
    const whole = await line({ name: 'Microsoft', account: payable, other: expense, side: 'credit' });
    const named = (await suggestionsFor(whole)).filter((s) => s.method === 'name');
    expect(named.length).toBe(2);
    const exact = named.find((s) => s.contact_id === microsoft)!;
    expect(Number(exact.score)).toBe(0.95);
    expect(named.filter((s) => s.contact_id !== microsoft).every((s) => Number(s.score) <= 0.6)).toBe(true);
  });

  it('is answered the same way for a statement line, through the one scoring', async () => {
    const account = await one<{ id: string }>(
      db,
      `insert into bank_accounts (company_id, name, currency_code)
       select $1, 'Current', currency_code from companies where id = $1 returning id`,
      [fx.companyId],
    );
    const tx = await one<{ id: string }>(
      db,
      `insert into bank_transactions
         (company_id, bank_account_id, sequence, transaction_date, amount, currency_code, counterpart_name, state)
       select $1, $2, 1, '2026-04-02'::date, -50, currency_code, 'Remb Pedro Microsoft/Cleverbridge', 'pending'
         from companies where id = $1
       returning id`,
      [fx.companyId, account.id],
    );
    const byName = (await rows<Suggestion>(db, `select * from suggest_contacts($1)`, [tx.id])).filter(
      (s) => s.method === 'name',
    );
    expect(byName.length).toBeGreaterThan(1);
    expect(byName.every((s) => Number(s.score) <= 0.6 && s.alternatives > 1)).toBe(true);
  });
});
