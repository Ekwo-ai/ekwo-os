/**
 * `financial_analysis()` — the aggregates of a company, read from what its
 * pack says its accounts mean.
 *
 * Every pack that carries `analysis.json` is held to the same books: a sale
 * and a purchase through the bank, the year closed, a sale in the next one.
 * Nothing is expected of a country. What is asserted is what the function
 * owes any pack: one row per aggregate the pack defines, in the order of the
 * closed list; the movements of the period and not of the year before; the
 * result nobody has closed counted in equity, once, before the close and
 * after it; and, with the books balanced, total assets equal to equity plus
 * everything else the company owes, to the cent. The figures each pack
 * produces on its own scenario are in its golden, `golden/analysis.json`.
 *
 * A company whose pack says nothing is read through the framework pack's
 * section instead, by account type, and the rows say so in `source`.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newUser, type Fixture } from './helpers/factory.js';
import { allPacks, packsWhere, readSchemaEnum, roleOf } from './helpers/packs.js';
import { readFrameworkPack, type Pack } from '../packages/cli/src/index.js';

let db: PGlite;

beforeAll(async () => {
  db = await freshDatabase();
}, 120_000);

afterAll(async () => {
  await db.close();
});

interface Part {
  code: string | null;
  name: string | null;
  amount: number;
}

interface Aggregate {
  aggregate: string;
  amount: number;
  accounts: Part[];
  source: string;
}

async function analysis(company: string, from: string, to: string): Promise<Aggregate[]> {
  const found = await rows<{ aggregate: string; amount: string; accounts: Part[]; source: string }>(
    db,
    `select aggregate, amount::text, accounts, source from financial_analysis($1, $2::date, $3::date)`,
    [company, from, to],
  );
  return found.map((row) => ({
    aggregate: row.aggregate,
    amount: Number(row.amount),
    accounts: row.accounts,
    source: row.source,
  }));
}

function figure(found: Aggregate[], code: string): Aggregate {
  const row = found.find((r) => r.aggregate === code);
  if (row === undefined) throw new Error(`financial_analysis() returned no ${code}`);
  return row;
}

/** Debit minus credit over every income and expense account, cumulative to a day. */
async function unclosedResult(company: string, to: string): Promise<number> {
  const row = await one<{ balance: string }>(
    db,
    `select coalesce(sum(t.closing_balance), 0)::text as balance
       from trial_balance($1, $2::date, $2::date) t
       join accounts a on a.id = t.account_id
      where not a.carries_forward`,
    [company, to],
  );
  return Number(row.balance);
}

/**
 * What the balance sheet holds besides the assets and the equity the analysis
 * names: every account that carries forward and is in neither list, read as a
 * credit. With the books balanced, assets are equity plus this.
 */
async function everythingElse(company: string, to: string, found: Aggregate[]): Promise<number> {
  const named = new Set(
    [...figure(found, 'total_assets').accounts, ...figure(found, 'equity').accounts].map((p) => p.code),
  );
  const balances = await rows<{ code: string; closing: string }>(
    db,
    `select t.account_code as code, t.closing_balance::text as closing
       from trial_balance($1, $2::date, $2::date) t
       join accounts a on a.id = t.account_id
      where a.carries_forward and t.closing_balance <> 0`,
    [company, to],
  );
  return -balances.filter((b) => !named.has(b.code)).reduce((sum, b) => sum + Number(b.closing), 0);
}

async function book(fx: Fixture, pack: Pack, date: string, lines: [string, number, number][]): Promise<void> {
  const journal = await one<{ id: string }>(
    db,
    `select id from journals where company_id = $1 and journal_type = 'general' order by code limit 1`,
    [fx.companyId],
  );
  await asUser(db, fx.ownerId, async () => {
    const entry = await one<{ id: string }>(
      db,
      `insert into entries (company_id, journal_id, entry_date, description, state)
       values ($1, $2, $3::date, 'Analysis', 'draft') returning id`,
      [fx.companyId, journal.id, date],
    );
    for (const [index, [role, debit, credit]] of lines.entries()) {
      await db.query(
        `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit)
         values ($1, $2, account_id_by_code($2, $3), $4, 'Analysis', $5, $6)`,
        [entry.id, fx.companyId, roleOf(pack, role), (index + 1) * 10, debit, credit],
      );
    }
    await db.query(`select post_entry($1)`, [entry.id]);
  });
}

const aggregateOrder = async (): Promise<string[]> =>
  (await rows<{ code: string }>(db, `select code from analysis_aggregates order by sequence`)).map((r) => r.code);

describe('the closed list', () => {
  it('is the one the pack schema publishes, in the same words', async () => {
    const published = readSchemaEnum('analysis_aggregate', 'code');
    expect([...(await aggregateOrder())].sort()).toEqual([...published].sort());
  });
});

for (const pack of packsWhere('that says what its accounts mean to an analysis', (p) => p.analysis !== null)) {
  describe(`the ${pack.slug} pack`, () => {
    let fx: Fixture;
    let defined: string[];

    beforeAll(async () => {
      fx = await newCompany(db, { country: pack.manifest.country, name: `Analysis ${pack.slug}` });
      await db.query(
        `insert into fiscal_years (company_id, name, start_date, end_date)
         values ($1, 'Second year', date '2027-01-01', date '2027-12-31')`,
        [fx.companyId],
      );
      // 1 000 earned and 400 spent through the bank in the first year.
      await book(fx, pack, '2026-03-15', [
        ['bank', 1000, 0],
        ['sales', 0, 1000],
      ]);
      await book(fx, pack, '2026-04-20', [
        ['purchase', 400, 0],
        ['bank', 0, 400],
      ]);
      const order = await aggregateOrder();
      defined = order.filter((code) => pack.analysis!.aggregates.some((a) => a.code === code));
    }, 120_000);

    it('returns one row per aggregate the pack defines, in the order of the list', async () => {
      const found = await analysis(fx.companyId, '2026-01-01', '2026-06-30');
      expect(found.map((r) => r.aggregate)).toEqual(defined);
      expect(new Set(found.map((r) => r.source))).toEqual(new Set(['pack']));
    });

    it('says which accounts make each figure, and they add up to it', async () => {
      const found = await analysis(fx.companyId, '2026-01-01', '2026-06-30');
      for (const row of found) {
        const sum = row.accounts.reduce((total, part) => total + Number(part.amount), 0);
        expect(sum, row.aggregate).toBeCloseTo(row.amount, 6);
        expect(row.accounts.every((part) => Number(part.amount) !== 0), row.aggregate).toBe(true);
      }
      const revenue = figure(found, 'revenue');
      expect(revenue.amount).toBe(1000);
      expect(revenue.accounts.map((p) => p.code)).toEqual([roleOf(pack, 'sales')]);
    });

    it('reads the result of the period as a profit, and puts it in equity before any close', async () => {
      const found = await analysis(fx.companyId, '2026-01-01', '2026-06-30');
      const result = await unclosedResult(fx.companyId, '2026-06-30');
      expect(result).toBe(-600);
      expect(figure(found, 'net_result').amount).toBe(600);
      expect(figure(found, 'equity').amount).toBe(600);
      // On the account the close would leave it on, and nowhere else.
      const onto = await one<{ code: string }>(
        db,
        `select a.code from accounts a where a.id = year_result_account($1, $2)`,
        [fx.companyId, result],
      );
      expect(figure(found, 'equity').accounts).toEqual([
        expect.objectContaining({ code: onto.code, amount: 600 }),
      ]);
    });

    it('balances: total assets are equity and everything else the company owes', async () => {
      const found = await analysis(fx.companyId, '2026-01-01', '2026-06-30');
      expect(figure(found, 'total_assets').amount).toBe(600);
      expect(figure(found, 'total_assets').amount).toBeCloseTo(
        figure(found, 'equity').amount + (await everythingElse(fx.companyId, '2026-06-30', found)),
        6,
      );
    });

    describe('once the year is closed', () => {
      beforeAll(async () => {
        const year = await one<{ id: string }>(
          db,
          `select id from fiscal_years where company_id = $1 and start_date = date '2026-01-01'`,
          [fx.companyId],
        );
        await asUser(db, fx.ownerId, () => db.query(`select close_fiscal_year($1)`, [year.id]));
        await book(fx, pack, '2027-02-01', [
          ['bank', 400, 0],
          ['sales', 0, 400],
        ]);
      }, 120_000);

      it('still reads what the closed year earned, without its closing entry', async () => {
        const found = await analysis(fx.companyId, '2026-01-01', '2026-12-31');
        expect(figure(found, 'revenue').amount).toBe(1000);
        expect(figure(found, 'net_result').amount).toBe(600);
        expect(figure(found, 'equity').amount).toBe(600);
        expect(await unclosedResult(fx.companyId, '2026-12-31')).toBe(0);
        expect(figure(found, 'total_assets').amount).toBeCloseTo(
          figure(found, 'equity').amount + (await everythingElse(fx.companyId, '2026-12-31', found)),
          6,
        );
      });

      it('reads the movements of the next period alone, and adds its result to what the close carried', async () => {
        const found = await analysis(fx.companyId, '2027-01-01', '2027-03-31');
        expect(figure(found, 'revenue').amount).toBe(400);
        expect(figure(found, 'net_result').amount).toBe(400);
        expect(figure(found, 'equity').amount).toBe(1000);
        expect(figure(found, 'total_assets').amount).toBe(1000);
        expect(figure(found, 'total_assets').amount).toBeCloseTo(
          figure(found, 'equity').amount + (await everythingElse(fx.companyId, '2027-03-31', found)),
          6,
        );
      });
    });
  });
}

describe('a company whose pack says nothing about an analysis', () => {
  // The aggregates no account type tells apart: the framework leaves them out.
  const unread = ['staff_costs', 'financial_result', 'income_tax'];
  const silent = packsWhere('without an analysis section', (p) => p.analysis === null);
  let fx: Fixture;
  let found: Aggregate[];

  beforeAll(async () => {
    const pack = silent[0]!;
    fx = await newCompany(db, { country: pack.manifest.country, name: `Silent ${pack.slug}` });
    await book(fx, pack, '2026-03-15', [
      ['bank', 1000, 0],
      ['sales', 0, 1000],
    ]);
    await book(fx, pack, '2026-04-20', [
      ['purchase', 400, 0],
      ['bank', 0, 400],
    ]);
    found = await analysis(fx.companyId, '2026-01-01', '2026-12-31');
  }, 120_000);

  it('gets the framework\'s reading by account type, and is told so', async () => {
    const framework = await readFrameworkPack();
    const order = await aggregateOrder();
    const read = order.filter((code) => framework.analysis!.aggregates.some((a) => a.code === code));
    expect(read).toHaveLength(13);
    expect(found.map((r) => r.aggregate)).toEqual(read);
    expect(new Set(found.map((r) => r.source))).toEqual(new Set(['framework']));
  });

  it('gets no row for what no account type tells apart, rather than a zero', () => {
    for (const code of unread) expect(found.map((r) => r.aggregate)).not.toContain(code);
  });

  it('reads the period through the account types', () => {
    expect(figure(found, 'revenue').amount).toBe(1000);
    expect(figure(found, 'net_result').amount).toBe(600);
    expect(figure(found, 'equity').amount).toBe(600);
    expect(figure(found, 'cash').amount).toBe(600);
  });

  it('balances: total assets are equity, current liabilities and long-term debt', () => {
    expect(figure(found, 'total_assets').amount).toBe(600);
    expect(figure(found, 'total_assets').amount).toBeCloseTo(
      figure(found, 'equity').amount +
        figure(found, 'current_liabilities').amount +
        figure(found, 'long_term_debt').amount,
      6,
    );
  });

  it('is read through the framework its chart declares, before any other', async () => {
    // A second framework, with one statement and one aggregate, and a chart
    // that names that statement. Written inside a transaction that is rolled
    // back: the reference data of the other tests stays what the seeds wrote.
    const pack = silent[1] ?? silent[0]!;
    const own = 'TEST-FRAMEWORK';
    await db.query('begin');
    try {
      await db.query(
        `insert into statement_templates (code, country, chart_code, name, kind, framework)
         values ($1 || '-BS', null, null, 'Balance sheet of a test framework', 'balance_sheet', $1)`,
        [own],
      );
      await db.query(
        `insert into analysis_templates (framework, aggregate, legal_reference) values ($1, 'revenue', 'A test framework')`,
        [own],
      );
      await db.query(
        `insert into analysis_rules (framework, aggregate, sequence, rule_kind, account_type)
         values ($1, 'revenue', 10, 'account_type', 'income')`,
        [own],
      );
      const other = await newCompany(db, { country: pack.manifest.country, name: `Own framework ${pack.slug}` });
      await book(other, pack, '2026-03-15', [
        ['bank', 250, 0],
        ['sales', 0, 250],
      ]);

      // Not declared yet: the framework the installation carries first by code.
      const before = await analysis(other.companyId, '2026-01-01', '2026-12-31');
      const framework = await readFrameworkPack();
      const first = [framework.manifest.code, own].sort()[0];
      expect(before.length).toBe(first === own ? 1 : framework.analysis!.aggregates.length);

      await db.query(
        `update chart_templates ch
            set statements = ch.statements || array[$1 || '-BS']
          where ch.country = $2
            and ch.code = (select coalesce(
                  (select p.chart_code from company_packs p where p.company_id = $3 and p.country = $2),
                  (select d.code from chart_templates d where d.country = $2 and d.is_default)))`,
        [own, pack.manifest.country, other.companyId],
      );
      const after = await analysis(other.companyId, '2026-01-01', '2026-12-31');
      expect(after).toEqual([
        expect.objectContaining({ aggregate: 'revenue', amount: 250, source: 'framework' }),
      ]);
    } finally {
      await db.query('rollback');
    }
  });
});

describe('who may read it', () => {
  const pack = allPacks.find((p) => p.analysis !== null)!;
  let fx: Fixture;

  beforeAll(async () => {
    fx = await newCompany(db, { country: pack.manifest.country, name: 'Guarded' });
  }, 60_000);

  it('refuses a company that does not exist, by name', async () => {
    const message = await expectError(db, `select * from financial_analysis($1, date '2026-01-01', date '2026-12-31')`, [
      crypto.randomUUID(),
    ]);
    expect(message).toMatch(/^unknown_company:/);
  });

  it('does not tell a stranger the company exists', async () => {
    const stranger = await newUser(db);
    const message = await asUser(db, stranger, () =>
      expectError(db, `select * from financial_analysis($1, date '2026-01-01', date '2026-12-31')`, [fx.companyId]),
    );
    expect(message).toMatch(/^unknown_company:/);
  });

  it('asks a member for entries.read', async () => {
    const member = await newUser(db);
    await db.query(
      `insert into company_members (company_id, user_id, role, capabilities_revoked)
       values ($1, $2, 'viewer', array['entries.read'])`,
      [fx.companyId, member],
    );
    const message = await asUser(db, member, () =>
      expectError(db, `select * from financial_analysis($1, date '2026-01-01', date '2026-12-31')`, [fx.companyId]),
    );
    expect(message).toMatch(/^not_allowed: .*entries\.read/);
  });

  it('answers the owner', async () => {
    const found = await asUser(db, fx.ownerId, () =>
      rows(db, `select * from financial_analysis($1, date '2026-01-01', date '2026-12-31')`, [fx.companyId]),
    );
    expect(found.length).toBe(pack.analysis!.aggregates.length);
  });

  it('refuses a period that ends before it starts', async () => {
    const message = await expectError(db, `select * from financial_analysis($1, date '2026-12-31', date '2026-01-01')`, [
      fx.companyId,
    ]);
    expect(message).toMatch(/^invalid_period:/);
  });
});
