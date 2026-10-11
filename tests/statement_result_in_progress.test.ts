/**
 * A balance sheet drawn before the close carries the result of the year in
 * progress.
 *
 * Until a year is closed its result is still spread over the income and
 * expense accounts, and a national scheme catches none of them on its balance
 * sheet. `statement_account_matches()` moves their balance, as one figure,
 * onto the account the close would have left it on — `year_result_account()`
 * — and the pack's own rules carry it to its line. These tests hold that to
 * the cent: a Belgian company in the middle of its year, with a profit and
 * with a loss; a closed year, where nothing may be counted twice; and every
 * pack of this checkout that carries a balance sheet, on books with income and
 * expense, where assets have to equal liabilities and equity.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, type Fixture } from './helpers/factory.js';
import { allPacks, roleOf } from './helpers/packs.js';

let db: PGlite;

beforeAll(async () => {
  db = await freshDatabase();
}, 120_000);

afterAll(async () => {
  await db.close();
});

interface Line {
  line_code: string;
  parent_code: string | null;
  is_total: boolean;
  amount: string;
}

/** The balance sheet a client without the pack's codes asks for. */
async function balanceSheet(company: string, from: string, to: string): Promise<Record<string, number>> {
  const lines = await rows<Line>(
    db,
    `select line_code, amount::text from financial_statement_of_kind($1, 'balance_sheet', $2::date, $3::date)`,
    [company, from, to],
  );
  return Object.fromEntries(lines.map((l) => [l.line_code, Number(l.amount)]));
}

/** Debit minus credit over every income and expense account, from the trial balance. */
async function ledgerResult(company: string, from: string, to: string): Promise<number> {
  const row = await one<{ balance: string }>(
    db,
    `select coalesce(sum(t.closing_balance), 0)::text as balance
       from trial_balance($1, $2::date, $3::date) t
      where t.internal_group in ('income', 'expense')`,
    [company, from, to],
  );
  return Number(row.balance);
}

async function sale(fx: Fixture, date: string, amount: number): Promise<void> {
  const customer = await newContact(db, fx.companyId, { type: 'customer', country: 'BE' });
  const invoice = await newDocument(db, fx.companyId, {
    docType: 'sale_invoice',
    contactId: customer,
    date,
    lines: [{ unitPrice: amount, taxCode: 'BE-S-21', accountCode: '700000' }],
  });
  await asUser(db, fx.ownerId, () => db.query(`select post_document($1)`, [invoice]));
}

async function purchase(fx: Fixture, date: string, amount: number): Promise<void> {
  const supplier = await newContact(db, fx.companyId, { type: 'supplier', country: 'BE' });
  const bill = await newDocument(db, fx.companyId, {
    docType: 'purchase_invoice',
    contactId: supplier,
    date,
    lines: [{ unitPrice: amount, taxCode: 'BE-P-21-S', accountCode: '610000' }],
  });
  await asUser(db, fx.ownerId, () => db.query(`select post_document($1)`, [bill]));
}

describe('a Belgian company in the middle of its year', () => {
  // The books of the defect: one sale of 2 500,00 at 21 %, so 3 025,00 owed
  // by the customer, 525,00 of VAT owed to the State, and a result of
  // 2 500,00 that no close has moved into equity yet.
  let fx: Fixture;

  beforeAll(async () => {
    fx = await newCompany(db, { country: 'BE', name: 'Ekwo Test SRL' });
    await sale(fx, '2026-03-15', 2500);
  }, 60_000);

  it('balances: 3 025,00 of assets against 525,00 of debts and 2 500,00 of result', async () => {
    const bs = await balanceSheet(fx.companyId, '2026-01-01', '2026-06-30');
    expect(bs['20/58']).toBe(3025);
    expect(bs['10/49']).toBe(3025);
    expect(bs['17/49']).toBe(525);
  });

  it('carries the result on the line the close would have put it on', async () => {
    // Belgium appropriates through 693, which is part of the income
    // statement; the balance sheet shows the result where it ends up, on 140
    // and rubric 14.
    const bs = await balanceSheet(fx.companyId, '2026-01-01', '2026-06-30');
    expect(bs['14']).toBe(2500);
    expect(bs['10/15']).toBe(2500);
    expect(await ledgerResult(fx.companyId, '2026-01-01', '2026-06-30')).toBe(-2500);

    const on = await rows<{ account_code: string; balance: string }>(
      db,
      `select account_code, balance::text from statement_account_matches($1, 'BE-BNB-ABBR-BS', date '2026-01-01', date '2026-06-30')
        where line_code = '14'`,
      [fx.companyId],
    );
    expect(on).toEqual([{ account_code: '140000', balance: '-2500.00' }]);
  });

  it('leaves the income statement and the unmapped accounts as they were', async () => {
    const is = await rows<Line>(
      db,
      `select line_code, amount::text from financial_statement_of_kind($1, 'income_statement', date '2026-01-01', date '2026-06-30')`,
      [fx.companyId],
    );
    expect(Number(is.find((l) => l.line_code === '9905')?.amount)).toBe(2500);

    const left = await rows(db, `select * from unmapped_accounts($1, 'BE-BNB-ABBR-BS', date '2026-01-01', date '2026-06-30')`, [
      fx.companyId,
    ]);
    expect(left).toEqual([]);
  });

  it('matches the generic framework, which always derived the result on its own', async () => {
    const be = await balanceSheet(fx.companyId, '2026-01-01', '2026-06-30');
    const generic = await rows<{ line_code: string; amount: string }>(
      db,
      `select line_code, amount::text from financial_statement($1, 'IFRS-SME-BS', date '2026-01-01', date '2026-06-30')`,
      [fx.companyId],
    );
    const g = Object.fromEntries(generic.map((l) => [l.line_code, Number(l.amount)]));
    expect(g['A-TOT']).toBe(be['20/58']);
    expect(g['EL-TOT']).toBe(be['10/49']);
    // The generic scheme catches income and expense by account type, so
    // nothing is moved there and the result stays on its own line.
    expect(g['E-RESULT']).toBe(2500);
  });
});

describe('a Belgian company with a loss in progress', () => {
  let fx: Fixture;

  beforeAll(async () => {
    fx = await newCompany(db, { country: 'BE', name: 'Perte en cours SRL' });
    await purchase(fx, '2026-02-10', 1000);
  }, 60_000);

  it('shows the loss on equity, on the account the pack names for one', async () => {
    const bs = await balanceSheet(fx.companyId, '2026-01-01', '2026-06-30');
    // 210,00 of VAT to recover, 1 210,00 owed to the supplier, a loss of
    // 1 000,00 that brings equity below nil.
    expect(bs['20/58']).toBe(210);
    expect(bs['10/49']).toBe(210);
    expect(bs['14']).toBe(-1000);
    expect(bs['17/49']).toBe(1210);

    const on = await rows<{ account_code: string; balance: string }>(
      db,
      `select account_code, balance::text from statement_account_matches($1, 'BE-BNB-ABBR-BS', date '2026-01-01', date '2026-06-30')
        where line_code = '14'`,
      [fx.companyId],
    );
    expect(on).toEqual([{ account_code: '141000', balance: '1000.00' }]);
  });
});

describe('a year that has been closed', () => {
  let fx: Fixture;

  beforeAll(async () => {
    fx = await newCompany(db, { country: 'BE', name: 'Clôturée SRL' });
    await db.query(
      `insert into fiscal_years (company_id, name, start_date, end_date)
       values ($1, 'Exercice 2027', date '2027-01-01', date '2027-12-31')`,
      [fx.companyId],
    );
    await sale(fx, '2026-03-15', 2500);
    await purchase(fx, '2026-09-10', 1000);
    const year = await one<{ id: string }>(
      db,
      `select id from fiscal_years where company_id = $1 and start_date = date '2026-01-01'`,
      [fx.companyId],
    );
    await asUser(db, fx.ownerId, () => db.query(`select close_fiscal_year($1)`, [year.id]));
    await sale(fx, '2027-02-01', 400);
  }, 60_000);

  it('shows the result once, where the close put it, at the end of the year', async () => {
    const bs = await balanceSheet(fx.companyId, '2026-01-01', '2026-12-31');
    expect(bs['14']).toBe(1500);
    expect(bs['20/58']).toBe(bs['10/49']);
    // The close has emptied the income and expense accounts: nothing is left
    // for the balance sheet to move.
    expect(await ledgerResult(fx.companyId, '2026-01-01', '2026-12-31')).toBe(0);
  });

  it('shows the result to date on a period that stops inside the closed year', async () => {
    // The closing entry is dated the last day, so an interim balance sheet
    // of June reads the year as it stood in June.
    const bs = await balanceSheet(fx.companyId, '2026-01-01', '2026-06-30');
    expect(bs['14']).toBe(2500);
    expect(bs['20/58']).toBe(bs['10/49']);
  });

  it('adds the result of the next year to what the close carried, and nothing more', async () => {
    const bs = await balanceSheet(fx.companyId, '2027-01-01', '2027-03-31');
    expect(bs['14']).toBe(1500 + 400);
    expect(bs['20/58']).toBe(bs['10/49']);
  });
});

describe('a French company, whose pack keeps the result on an account of its own', () => {
  it('prints it on the line of the result of the year', async () => {
    const fx = await newCompany(db, { country: 'FR', name: 'Résultat en cours SAS' });
    const customer = await newContact(db, fx.companyId, { type: 'customer', country: 'FR' });
    const invoice = await newDocument(db, fx.companyId, {
      docType: 'sale_invoice',
      contactId: customer,
      date: '2026-03-15',
      lines: [{ unitPrice: 2500, taxCode: 'FR-S-20', accountCode: '706000' }],
    });
    await asUser(db, fx.ownerId, () => db.query(`select post_document($1)`, [invoice]));

    const on = await rows<{ account_code: string; balance: string }>(
      db,
      `select m.account_code, m.balance::text
         from statement_account_matches($1, default_statement_code($1, 'balance_sheet'), date '2026-01-01', date '2026-06-30') m
        where m.account_code = '120000'`,
      [fx.companyId],
    );
    expect(on).toHaveLength(1);
    expect(on[0]?.balance).toBe('-2500.00');
  });
});

// ---------------------------------------------------------------------------
// Every pack that carries a balance sheet
// ---------------------------------------------------------------------------

/**
 * The totals no other total of the scheme adds up: the grand totals a reader
 * ties out — TOTAL DE L'ACTIF and TOTAL DU PASSIF, or total assets and
 * equity, or net assets and equity. Read from the scheme, not named here.
 */
async function grandTotals(company: string, code: string, to: string): Promise<Record<string, number>> {
  const lines = await rows<{ line_code: string; amount: string }>(
    db,
    `select f.line_code, f.amount::text
       from financial_statement($1, $2, date '2026-01-01', $3::date) f
       join statement_line_templates l on l.statement_code = $2 and l.code = f.line_code
      where l.is_total
        and not exists (
          select 1 from statement_line_templates o
           where o.statement_code = $2
             and (l.code = any (o.plus_lines) or l.code = any (o.minus_lines)))`,
    [company, code, to],
  );
  return Object.fromEntries(lines.map((l) => [l.line_code, Number(l.amount)]));
}

describe('every pack that carries a balance sheet', () => {
  const carriers = allPacks.filter((pack) => pack.statements.some((s) => s.kind === 'balance_sheet'));

  it('is more than a handful, or this proves nothing', () => {
    expect(carriers.length).toBeGreaterThan(100);
  });

  for (const pack of carriers) {
    describe(`the ${pack.slug} pack`, () => {
      let company: string;
      let result: string;
      let unclosed: number;

      beforeAll(async () => {
        const fx = await newCompany(db, { country: pack.manifest.country, name: `Result ${pack.slug}` });
        company = fx.companyId;
        const journal = await one<{ id: string }>(
          db,
          `select id from journals where company_id = $1 and journal_type = 'general' order by code limit 1`,
          [company],
        );
        const account = async (role: string): Promise<string> =>
          (await one<{ id: string }>(db, `select account_id_by_code($1, $2) as id`, [company, roleOf(pack, role)])).id;
        const [bank, sales, purchases] = [await account('bank'), await account('sales'), await account('purchase')];

        // 1 000 earned, 400 spent, both through the bank: a result that no
        // year has closed.
        await asUser(db, fx.ownerId, async () => {
          const entry = await one<{ id: string }>(
            db,
            `insert into entries (company_id, journal_id, entry_date, description, state)
             values ($1, $2, date '2026-03-15', 'Income and expense', 'draft') returning id`,
            [company, journal.id],
          );
          await db.query(
            `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit)
             values ($1, $2, $3, 10, 'Sale', 1000, 0), ($1, $2, $4, 20, 'Sale', 0, 1000),
                    ($1, $2, $5, 30, 'Purchase', 400, 0), ($1, $2, $3, 40, 'Purchase', 0, 400)`,
            [entry.id, company, bank, sales, purchases],
          );
          await db.query(`select post_entry($1)`, [entry.id]);
        });
        // Some packs name an inventory account for purchases, so the result
        // is read from the ledger rather than assumed.
        unclosed = await ledgerResult(company, '2026-01-01', '2026-06-30');
        result = (await one<{ id: string }>(db, `select year_result_account($1, $2) as id`, [company, unclosed])).id;
      }, 120_000);

      for (const statement of pack.statements.filter((s) => s.kind === 'balance_sheet')) {
        it(`${statement.code}: assets equal liabilities and equity, to the cent`, async () => {
          // A scheme ties out either as two totals that are equal — assets
          // against liabilities and equity, net assets against equity — or
          // as one total of assets against the liabilities and the equity
          // it prints apart. Either way one grand total is the sum of the
          // others.
          const totals = await grandTotals(company, statement.code, '2026-06-30');
          const amounts = Object.values(totals);
          const whole = amounts.reduce((sum, amount) => sum + amount, 0);
          expect(amounts.length, JSON.stringify(totals)).toBeGreaterThanOrEqual(2);
          expect(
            amounts.some((amount) => amount !== 0 && Math.abs(2 * amount - whole) < 1e-9),
            JSON.stringify(totals),
          ).toBe(true);
        });

        it(`${statement.code}: reads every balance, the result on the line the pack names for it`, async () => {
          const matches = await rows<{ account_id: string; balance: string; line_code: string | null }>(
            db,
            `select account_id, balance::text, line_code
               from statement_account_matches($1, $2, date '2026-01-01', date '2026-06-30')`,
            [company, statement.code],
          );
          expect(matches.filter((m) => m.line_code === null && Number(m.balance) !== 0)).toEqual([]);
          expect(matches.reduce((sum, m) => sum + Number(m.balance), 0)).toBeCloseTo(0, 6);

          // Either the scheme catches income and expense on a line of its
          // own, and the result account holds nothing, or the whole result
          // stands on the account the close would use.
          expect(unclosed).not.toBe(0);
          const onResult = matches.find((m) => m.account_id === result);
          expect(onResult === undefined || Number(onResult.balance) === unclosed).toBe(true);
        });
      }

      it('shows the result in progress as a sub-line exactly where its balance sheet combines it', async () => {
        // The statement an application draws: the company's own balance
        // sheet, with the sub-lines the pack asks for.
        const lines = await rows<{ statement_code: string; line_code: string; parent_code: string; amount: string }>(
          db,
          `select statement_code, line_code, parent_code, amount::text
             from financial_statement_of_kind($1, 'balance_sheet', date '2026-01-01', date '2026-06-30')`,
          [company],
        );
        const statement = pack.statements.find((s) => s.code === lines[0]?.statement_code);
        const subLines = lines.filter((l) => l.line_code.endsWith(':result_in_progress'));
        if (statement?.result_in_progress !== 'combined') {
          expect(subLines).toEqual([]);
          return;
        }
        // Read back with the sign of the line it stands under, the sub-lines
        // add up to the whole result nobody has closed.
        const signs = await rows<{ code: string; sign: number }>(
          db,
          `select code, sign from statement_line_templates where statement_code = $1`,
          [statement.code],
        );
        const signOf = new Map(signs.map((s) => [s.code, Number(s.sign)]));
        expect(subLines.length).toBeGreaterThan(0);
        expect(subLines.reduce((sum, l) => sum + Number(l.amount) * (signOf.get(l.parent_code) ?? 0), 0)).toBeCloseTo(
          unclosed,
          6,
        );
      });
    });
  }
});
