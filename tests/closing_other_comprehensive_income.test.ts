/**
 * Other comprehensive income at the year end.
 *
 * Some frameworks present a few income and expense accounts below the result
 * and accumulate them in a component of equity of their own, never in
 * retained earnings. A pack says which under
 * `defaults.other_comprehensive_income`; `close_fiscal_year()` leaves them out
 * of the result and books them on the account they close to, and a balance
 * sheet drawn before the close puts them in the same place.
 *
 * Nothing here names a country: the pack is the one that declares the notion,
 * and every code comes from its manifest and its chart.
 */

import { readFile, writeFile, mkdir, rm, cp } from 'node:fs/promises';
import { join } from 'node:path';
import { tmpdir } from 'node:os';
import type { PGlite } from '@electric-sql/pglite';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { readPack } from '../packages/cli/src/index.js';
import { asUser, freshDatabase, one, repoRoot, rows } from './helpers/db.js';
import { defaultChartOf, packWhere, roleOf } from './helpers/packs.js';
import { amountSql, newCompany, type Fixture } from './helpers/factory.js';

interface Declared {
  accounts: string[];
  closes_to: string;
  legal_reference: string;
}

const pack = packWhere(
  'declares other comprehensive income',
  (p) => typeof p.manifest.defaults['other_comprehensive_income'] === 'object',
);
const declared = pack.manifest.defaults['other_comprehensive_income'] as Declared;
const chart = defaultChartOf(pack);
/** The first account of the chart a head of the declaration catches. */
const ociCode = chart.accounts
  .map((a) => a.code)
  .sort()
  .find((code) => declared.accounts.some((head) => code.startsWith(head)))!;
const balanceSheet = pack.statements.find(
  (s) => s.kind === 'balance_sheet' && (s.chart_code === null || s.chart_code === chart.code),
)!;

let db: PGlite;

beforeEach(async () => {
  db = await freshDatabase();
});

afterEach(async () => {
  await db.close();
});

/** A posted entry no document wrote: `amount` from the bank to `account`, a credit when positive. */
async function handEntry(fx: Fixture, account: string, amount: number): Promise<void> {
  const entry = await one<{ id: string }>(
    db,
    `insert into entries (company_id, journal_id, entry_date, description)
     select $1, miscellaneous_journal_id, date '2026-06-30', 'By hand' from companies where id = $1
     returning id`,
    [fx.companyId],
  );
  const debit = amount > 0 ? amount : 0;
  const credit = amount > 0 ? 0 : -amount;
  await db.query(
    `insert into entry_lines (entry_id, company_id, account_id, sequence, debit, credit)
     values ($1, $2, account_id_by_code($2, $3), 10, $5, $6),
            ($1, $2, account_id_by_code($2, $4), 20, $6, $5)`,
    [entry.id, fx.companyId, roleOf(pack, 'bank'), account, debit, credit],
  );
  await asUser(db, fx.ownerId, () => db.query(`select post_entry($1)`, [entry.id]));
}

/** A year with a profit on the sales account and other comprehensive income beside it. */
async function yearWith(sale: number, oci: number): Promise<Fixture> {
  const fx = await newCompany(db, { country: pack.manifest.country, name: 'Comprehensive' });
  await db.query(
    `insert into fiscal_years (company_id, name, start_date, end_date)
     values ($1, 'FY 2027', date '2027-01-01', date '2027-12-31')`,
    [fx.companyId],
  );
  await handEntry(fx, roleOf(pack, 'sales'), sale);
  await handEntry(fx, ociCode, oci);
  return fx;
}

async function close(fx: Fixture): Promise<Record<string, unknown>> {
  const year = await one<{ id: string }>(
    db,
    `select id from fiscal_years where company_id = $1 and start_date = date '2026-01-01'`,
    [fx.companyId],
  );
  return asUser(db, fx.ownerId, async () =>
    (
      await one<{ close_fiscal_year: Record<string, unknown> }>(db, `select close_fiscal_year($1)`, [year.id])
    ).close_fiscal_year,
  );
}

/** Debit minus credit of each account at the end of the year, the closing entry included. */
async function balances(fx: Fixture): Promise<Record<string, string>> {
  const found = await rows<{ code: string; balance: string }>(
    db,
    `select account_code as code, ${amountSql('closing_balance', '$1::uuid')} as balance
       from trial_balance($1, date '2026-01-01', date '2026-12-31')
      where closing_balance <> 0`,
    [fx.companyId],
  );
  return Object.fromEntries(found.map((r) => [r.code, r.balance]));
}

/** What each account stands at on the pack's balance sheet at the end of the year. */
async function onBalanceSheet(fx: Fixture): Promise<Record<string, string>> {
  const found = await rows<{ code: string; balance: string }>(
    db,
    `select account_code as code, balance::text as balance
       from statement_account_matches($1, $2, date '2026-01-01', date '2026-12-31')
      where balance <> 0`,
    [fx.companyId, balanceSheet.code],
  );
  return Object.fromEntries(found.map((r) => [r.code, r.balance]));
}

describe('a pack that declares other comprehensive income', () => {
  it('closes it to its own account, and the result without it', async () => {
    const fx = await yearWith(1000, 300);
    const closed = await close(fx);

    expect(closed['result']).toBe('1000.00');
    expect(closed['result_kind']).toBe('profit');
    expect(closed['other_comprehensive_income']).toBe('300.00');

    const after = await balances(fx);
    expect(after[roleOf(pack, 'sales')]).toBeUndefined();
    expect(after[ociCode]).toBeUndefined();
    expect(after[roleOf(pack, 'retained_earnings')]).toBe('-1000.00');
    expect(after[declared.closes_to]).toBe('-300.00');
  });

  it('closes a loss on it as a debit, beside a profit', async () => {
    const fx = await yearWith(1000, -300);
    const closed = await close(fx);

    expect(closed['result']).toBe('1000.00');
    expect(closed['other_comprehensive_income']).toBe('-300.00');
    const after = await balances(fx);
    expect(after[roleOf(pack, 'retained_earnings')]).toBe('-1000.00');
    expect(after[declared.closes_to]).toBe('300.00');
  });

  it('stands on the same accounts of the balance sheet before the close as after it', async () => {
    const fx = await yearWith(1000, 300);
    const before = await onBalanceSheet(fx);
    await close(fx);
    const after = await onBalanceSheet(fx);

    expect(before).toEqual(after);
    expect(after[declared.closes_to]).toBe('-300.00');
    expect(after[roleOf(pack, 'retained_earnings')]).toBe('-1000.00');
  });

  it('is undone with the close', async () => {
    const fx = await yearWith(1000, 300);
    const before = await balances(fx);
    await close(fx);
    const year = await one<{ id: string }>(
      db,
      `select id from fiscal_years where company_id = $1 and start_date = date '2026-01-01'`,
      [fx.companyId],
    );
    await asUser(db, fx.ownerId, () => db.query(`select reopen_fiscal_year($1)`, [year.id]));
    expect(await balances(fx)).toEqual(before);
  });

  it('is written into the country model with its article', async () => {
    const row = await one<{ heads: string[]; closes_to: string; reference: string }>(
      db,
      `select other_comprehensive_income_heads as heads,
              other_comprehensive_income_closes_to as closes_to,
              other_comprehensive_income_legal_reference as reference
         from country_defaults where country = $1`,
      [pack.manifest.country],
    );
    expect(row).toEqual({
      heads: declared.accounts,
      closes_to: declared.closes_to,
      reference: declared.legal_reference,
    });
  });
});

describe('ekwo pack check on other comprehensive income', () => {
  /** A copy of `packs/` with the declaration patched, so nothing here edits the real one. */
  async function packsWith(patch: (rule: Declared) => void): Promise<string> {
    const dir = join(tmpdir(), `ekwo-packs-${crypto.randomUUID()}`);
    await mkdir(dir, { recursive: true });
    await cp(join(repoRoot, 'packs'), dir, { recursive: true });
    const file = join(dir, pack.slug, 'pack.json');
    const manifest = JSON.parse(await readFile(file, 'utf8')) as { defaults: Record<string, unknown> };
    patch(manifest.defaults['other_comprehensive_income'] as Declared);
    await writeFile(file, JSON.stringify(manifest, null, 2));
    return dir;
  }

  async function refused(patch: (rule: Declared) => void, reason: RegExp): Promise<void> {
    const dir = await packsWith(patch);
    try {
      await expect(readPack(pack.slug, dir)).rejects.toThrow(reason);
    } finally {
      await rm(dir, { recursive: true, force: true });
    }
  }

  it('refuses a head that catches no account', async () => {
    await refused((rule) => {
      rule.accounts = ['no-such-head'];
    }, /is the head of no account/);
  });

  it('refuses a head that catches a balance-sheet account', async () => {
    await refused((rule) => {
      rule.accounts = [rule.closes_to];
    }, /other comprehensive income is an income or expense account/);
  });

  it('refuses an account to close to that is not on the balance sheet', async () => {
    await refused((rule) => {
      rule.closes_to = roleOf(pack, 'sales');
    }, /closes to an account on the balance sheet/);
  });
});
