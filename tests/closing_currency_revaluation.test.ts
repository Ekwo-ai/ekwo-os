/**
 * What is still open in a foreign currency, at the closing rate.
 *
 * `close_fiscal_year()` states every receivable and payable still open in a
 * currency that is not the company's, and every bank account kept in one, at
 * the closing rate of the last day of the year (the company's own row of `currency_rates`), books the
 * difference on the accounts the pack names, and reverses it the next day.
 * `reopen_fiscal_year()` takes both back. A pack that names no account for
 * an unrealised difference still closes a year with nothing open in a
 * foreign currency, and refuses by name one that has something to revalue.
 *
 * Nothing here names a country: the packs are chosen by what they declare,
 * and every code comes from their manifest.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { asUser, freshDatabase, one, rows } from './helpers/db.js';
import { packWhere, roleOf } from './helpers/packs.js';
import { newCompany, newContact, type Fixture } from './helpers/factory.js';
import type { Pack } from '../packages/cli/src/index.js';

const named = (pack: Pack, role: string): boolean => typeof pack.manifest.defaults.roles[role] === 'string';

const withRoles = packWhere(
  'that names the accounts of an unrealised exchange difference',
  (p) => named(p, 'fx_unrealised_gain') && named(p, 'fx_unrealised_loss') && named(p, 'fx_gain'),
);
const withoutRoles = packWhere(
  'that names realised exchange accounts and no unrealised ones',
  (p) =>
    !named(p, 'fx_unrealised_gain') &&
    named(p, 'fx_gain') &&
    typeof p.manifest.defaults['closing_style'] === 'string' &&
    p.manifest.defaults.currency !== withRoles.manifest.defaults.currency,
);

/** A currency that is not the pack's own. */
function foreignOf(pack: Pack): string {
  return pack.manifest.defaults.currency === 'USD' ? 'EUR' : 'USD';
}

let db: PGlite;

/** The message a refused call raises. */
async function refusal(call: Promise<unknown>): Promise<string> {
  try {
    await call;
  } catch (error) {
    return (error as Error).message;
  }
  throw new Error('expected a refusal');
}

beforeEach(async () => {
  db = await freshDatabase();
});

afterEach(async () => {
  await db.close();
});

interface Line {
  code: string;
  debit?: number;
  credit?: number;
  contactId?: string | null;
  /** The amount in the foreign currency, when the line is stated in one. */
  foreign?: number;
}

/** A posted entry of the miscellaneous journal, and the ids of its lines in order. */
async function book(fx: Fixture, pack: Pack, date: string, lines: Line[]): Promise<string[]> {
  const entry = await one<{ id: string }>(
    db,
    `insert into entries (company_id, journal_id, entry_date, description)
     select $1, miscellaneous_journal_id, $2::date, 'By hand' from companies where id = $1
     returning id`,
    [fx.companyId, date],
  );
  const ids: string[] = [];
  let sequence = 0;
  for (const line of lines) {
    sequence += 10;
    const row = await one<{ id: string }>(
      db,
      `insert into entry_lines (entry_id, company_id, account_id, sequence, debit, credit, contact_id,
                                currency_code, amount_currency)
       values ($1, $2, account_id_by_code($2, $3), $4, $5, $6, $7, $8, $9)
       returning id`,
      [
        entry.id,
        fx.companyId,
        line.code,
        sequence,
        line.debit ?? 0,
        line.credit ?? 0,
        line.contactId ?? null,
        line.foreign === undefined ? null : foreignOf(pack),
        line.foreign ?? null,
      ],
    );
    ids.push(row.id);
  }
  await asUser(db, fx.ownerId, () => db.query(`select post_entry($1)`, [entry.id]));
  return ids;
}

async function company(pack: Pack, name: string): Promise<Fixture> {
  const fx = await newCompany(db, { country: pack.manifest.country, name });
  await db.query(
    `insert into fiscal_years (company_id, name, start_date, end_date)
     values ($1, 'FY 2027', date '2027-01-01', date '2027-12-31')`,
    [fx.companyId],
  );
  return fx;
}

/** A sale of `foreign` units of the foreign currency booked at `ledger`, open on the customer. */
async function sale(fx: Fixture, pack: Pack, customer: string, date: string, foreign: number, ledger: number): Promise<string> {
  const [receivable] = await book(fx, pack, date, [
    { code: roleOf(pack, 'receivable'), debit: ledger, contactId: customer, foreign },
    { code: roleOf(pack, 'sales'), credit: ledger, foreign },
  ]);
  return receivable!;
}

async function closingRate(fx: Fixture, pack: Pack, date: string, rate: number): Promise<void> {
  await asUser(db, fx.ownerId, () =>
    db.query(
      `insert into currency_rates (company_id, currency_code, rate_date, rate, source)
       values ($1, $2, $3::date, $4, 'Test series')`,
      [fx.companyId, foreignOf(pack), date, rate],
    ),
  );
}

async function yearId(fx: Fixture, start: string): Promise<string> {
  const row = await one<{ id: string }>(
    db,
    `select id from fiscal_years where company_id = $1 and start_date = $2::date`,
    [fx.companyId, start],
  );
  return row.id;
}

async function close(fx: Fixture): Promise<Record<string, unknown>> {
  const id = await yearId(fx, '2026-01-01');
  return asUser(db, fx.ownerId, async () =>
    (await one<{ close_fiscal_year: Record<string, unknown> }>(db, `select close_fiscal_year($1)`, [id]))
      .close_fiscal_year,
  );
}

/**
 * Debit minus credit of an account, over every posted entry up to a day but
 * the entries of a close: an exchange account may be an income or expense
 * account, which the closing entry brings back to nil.
 */
async function balanceAt(fx: Fixture, code: string, at: string): Promise<number> {
  const row = await one<{ balance: number }>(
    db,
    `select coalesce(sum(l.debit - l.credit), 0)::float8 as balance
       from entry_lines l join entries e on e.id = l.entry_id
      where l.company_id = $1 and l.account_id = account_id_by_code($1, $2)
        and e.state = 'posted' and e.entry_date <= $3::date and e.kind = 'normal'`,
    [fx.companyId, code, at],
  );
  return row.balance;
}

describe('a receivable still open in a foreign currency at the close', () => {
  it('is stated at the closing rate on the last day, and back at its own rate the next', async () => {
    const pack = withRoles;
    const fx = await company(pack, 'Exporter');
    const customer = await newContact(db, fx.companyId, { name: 'Overseas', country: null });
    await sale(fx, pack, customer, '2026-03-01', 1000, 900);
    await closingRate(fx, pack, '2026-12-31', 1.25);

    const preview = await asUser(db, fx.ownerId, () =>
      rows<{ amount_currency: number; carrying_amount: number; revalued_amount: number; difference: number; position_kind: string }>(
        db,
        `select amount_currency::float8 as amount_currency, carrying_amount::float8 as carrying_amount,
                revalued_amount::float8 as revalued_amount, difference::float8 as difference, position_kind
           from currency_revaluation($1, date '2026-12-31')`,
        [fx.companyId],
      ),
    );
    expect(preview).toEqual([
      { amount_currency: 1000, carrying_amount: 900, revalued_amount: 800, difference: -100, position_kind: 'third_party' },
    ]);

    const closed = await close(fx);
    expect(Number(closed['unrealised_exchange_difference'])).toBe(-100);
    expect(closed['revaluation_entry_id']).not.toBeNull();
    expect(closed['revaluation_reversal_entry_id']).not.toBeNull();

    // On the last day: the receivable at the closing rate, the loss on the
    // account the pack names for it.
    expect(await balanceAt(fx, roleOf(pack, 'receivable'), '2026-12-31')).toBe(800);
    expect(await balanceAt(fx, roleOf(pack, 'fx_unrealised_loss'), '2026-12-31')).toBe(100);

    // The next day, back at the rate it was booked at.
    expect(await balanceAt(fx, roleOf(pack, 'receivable'), '2027-01-01')).toBe(900);
    expect(await balanceAt(fx, roleOf(pack, 'fx_unrealised_loss'), '2027-01-01')).toBe(0);

    // The revaluation and its mirror settle each other: no new open item.
    const open = await rows<{ id: string }>(
      db,
      `select l.id from entry_lines l
        where l.company_id = $1 and l.account_id = account_id_by_code($1, $2)
          and abs(l.balance) - l.matched_amount > 0`,
      [fx.companyId, roleOf(pack, 'receivable')],
    );
    expect(open).toHaveLength(1);

    const reversal = await one<{ entry_date: string; reversed_entry_id: string; fiscal_year_id: string }>(
      db,
      `select entry_date::text, reversed_entry_id, fiscal_year_id from entries where id = $1`,
      [closed['revaluation_reversal_entry_id']],
    );
    expect(reversal.entry_date).toBe('2027-01-01');
    expect(reversal.reversed_entry_id).toBe(closed['revaluation_entry_id']);
    expect(reversal.fiscal_year_id).toBe(await yearId(fx, '2027-01-01'));
  });

  it('is revalued for the part no matching of the year settled', async () => {
    const pack = withRoles;
    const fx = await company(pack, 'Partly paid');
    const customer = await newContact(db, fx.companyId, { name: 'Overseas', country: null });
    const invoice = await sale(fx, pack, customer, '2026-03-01', 1000, 900);
    // 400 collected in the year at 1, and the rest collected after it: the
    // second matching does not settle anything on the last day.
    const [, early] = await book(fx, pack, '2026-06-01', [
      { code: roleOf(pack, 'bank'), debit: 400, foreign: 400 },
      { code: roleOf(pack, 'receivable'), credit: 400, contactId: customer, foreign: 400 },
    ]);
    const [, late] = await book(fx, pack, '2027-02-01', [
      { code: roleOf(pack, 'bank'), debit: 500, foreign: 600 },
      { code: roleOf(pack, 'receivable'), credit: 500, contactId: customer, foreign: 600 },
    ]);
    await asUser(db, fx.ownerId, async () => {
      await db.query(`select reconcile($1, $2, null)`, [invoice, early]);
      await db.query(`select reconcile($1, $2, null)`, [invoice, late]);
    });

    const preview = await asUser(db, fx.ownerId, () =>
      rows<{ amount_currency: number; carrying_amount: number; position_kind: string }>(
        db,
        `select amount_currency::float8 as amount_currency, carrying_amount::float8 as carrying_amount, position_kind
           from currency_revaluation($1, date '2026-12-31')
          where position_kind = 'third_party'`,
        [fx.companyId],
      ),
    );
    // 600 of 1 000 open, at 900 for the whole.
    expect(preview).toEqual([{ amount_currency: 600, carrying_amount: 540, position_kind: 'third_party' }]);
  });

  it('refuses the close, by name, while the currency has no closing rate', async () => {
    const pack = withRoles;
    const fx = await company(pack, 'No rate');
    const customer = await newContact(db, fx.companyId, { name: 'Overseas', country: null });
    await sale(fx, pack, customer, '2026-03-01', 1000, 900);
    // A rate of another day is not the closing rate.
    await closingRate(fx, pack, '2026-12-30', 1.25);

    expect(await refusal(close(fx))).toMatch(/^fx_closing_rate_missing: /);
  });
});

describe('a payable still open in a foreign currency', () => {
  it('books an unrealised gain when the currency fell', async () => {
    const pack = withRoles;
    const fx = await company(pack, 'Importer');
    const supplier = await newContact(db, fx.companyId, { name: 'Overseas supplier', type: 'supplier', country: null });
    await book(fx, pack, '2026-04-01', [
      { code: roleOf(pack, 'purchase'), debit: 1000, foreign: 1000 },
      { code: roleOf(pack, 'payable'), credit: 1000, contactId: supplier, foreign: 1000 },
    ]);
    await closingRate(fx, pack, '2026-12-31', 1.25);

    const closed = await close(fx);
    expect(Number(closed['unrealised_exchange_difference'])).toBe(200);
    expect(await balanceAt(fx, roleOf(pack, 'payable'), '2026-12-31')).toBe(-800);
    expect(await balanceAt(fx, roleOf(pack, 'fx_unrealised_gain'), '2026-12-31')).toBe(-200);
    expect(await balanceAt(fx, roleOf(pack, 'payable'), '2027-01-01')).toBe(-1000);
  });
});

describe('a bank account kept in a foreign currency', () => {
  it('is stated at the closing rate, its difference on the exchange accounts', async () => {
    const pack = withRoles;
    const fx = await company(pack, 'Holder');
    await db.query(
      `insert into bank_accounts (company_id, name, currency_code, account_id)
       values ($1, 'Foreign account', $2, account_id_by_code($1, $3))`,
      [fx.companyId, foreignOf(pack), roleOf(pack, 'bank')],
    );
    await book(fx, pack, '2026-05-01', [
      { code: roleOf(pack, 'bank'), debit: 500, foreign: 500 },
      { code: roleOf(pack, 'sales'), credit: 500, foreign: 500 },
    ]);
    await closingRate(fx, pack, '2026-12-31', 1.25);

    const closed = await close(fx);
    expect(Number(closed['unrealised_exchange_difference'])).toBe(-100);
    expect(await balanceAt(fx, roleOf(pack, 'bank'), '2026-12-31')).toBe(400);
    expect(await balanceAt(fx, roleOf(pack, 'fx_loss'), '2026-12-31')).toBe(100);
    expect(await balanceAt(fx, roleOf(pack, 'bank'), '2027-01-01')).toBe(500);
  });
});

describe('reopening a year that revalued', () => {
  it('takes the revaluation and its mirror back, and closes again the same', async () => {
    const pack = withRoles;
    const fx = await company(pack, 'Reopened');
    const customer = await newContact(db, fx.companyId, { name: 'Overseas', country: null });
    await sale(fx, pack, customer, '2026-03-01', 1000, 900);
    await closingRate(fx, pack, '2026-12-31', 1.25);
    await close(fx);

    const id = await yearId(fx, '2026-01-01');
    const reopened = await asUser(db, fx.ownerId, async () =>
      (await one<{ reopen_fiscal_year: { reversal_entry_ids: string[] } }>(db, `select reopen_fiscal_year($1)`, [id]))
        .reopen_fiscal_year,
    );
    expect(reopened.reversal_entry_ids.length).toBeGreaterThanOrEqual(3);
    expect(await balanceAt(fx, roleOf(pack, 'receivable'), '2026-12-31')).toBe(900);
    expect(await balanceAt(fx, roleOf(pack, 'fx_unrealised_loss'), '2026-12-31')).toBe(0);
    expect(await balanceAt(fx, roleOf(pack, 'receivable'), '2027-01-01')).toBe(900);
    expect(await one(db, `select count(*)::int as n from currency_revaluations where fiscal_year_id = $1`, [id])).toEqual({ n: 0 });

    const again = await close(fx);
    expect(Number(again['unrealised_exchange_difference'])).toBe(-100);
    expect(await balanceAt(fx, roleOf(pack, 'receivable'), '2026-12-31')).toBe(800);
  });
});

describe('a pack that names no account for an unrealised difference', () => {
  it('closes a year with nothing open in a foreign currency, as before', async () => {
    const pack = withoutRoles;
    const fx = await company(pack, 'Domestic');
    await book(fx, pack, '2026-03-01', [
      { code: roleOf(pack, 'bank'), debit: 100 },
      { code: roleOf(pack, 'sales'), credit: 100 },
    ]);
    const closed = await close(fx);
    expect(closed['revaluation_entry_id']).toBeNull();
    expect(Number(closed['unrealised_exchange_difference'])).toBe(0);
  });

  it('refuses, by name, a year whose open items the closing rate moves', async () => {
    const pack = withoutRoles;
    const fx = await company(pack, 'Exposed');
    const customer = await newContact(db, fx.companyId, { name: 'Overseas', country: null });
    await sale(fx, pack, customer, '2026-03-01', 1000, 1000);
    await closingRate(fx, pack, '2026-12-31', 1.25);

    expect(await refusal(close(fx))).toMatch(/^no_fx_revaluation_accounts: /);
  });

  it('closes when the closing rate moves nothing', async () => {
    const pack = withoutRoles;
    const fx = await company(pack, 'Unmoved');
    const customer = await newContact(db, fx.companyId, { name: 'Overseas', country: null });
    await sale(fx, pack, customer, '2026-03-01', 1000, 800);
    await closingRate(fx, pack, '2026-12-31', 1.25);

    const closed = await close(fx);
    expect(closed['revaluation_entry_id']).toBeNull();
  });
});

describe('the revaluation is the close’s', () => {
  it('is refused outside close_fiscal_year(), and its record written by nobody else', async () => {
    const pack = withRoles;
    const fx = await company(pack, 'Direct');
    const id = await yearId(fx, '2026-01-01');
    const message = await asUser(db, fx.ownerId, () =>
      refusal(db.query(`select revalue_currency_positions($1)`, [id])),
    );
    expect(message).toMatch(/^currency_revaluation_by_close: /);
  });
});
