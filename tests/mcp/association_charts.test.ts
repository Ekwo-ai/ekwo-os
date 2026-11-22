/**
 * An association, from the question to its annual accounts, through the
 * server alone: `describe_pack` says the country has a chart for associations
 * and foundations, `create_company` installs it, and once a year has been kept
 * on it `list_statements` and `financial_statement` give back its own balance
 * sheet and income statement — balancing, tying out, and saying the same
 * result as the generic framework offered beside them.
 *
 * No country is written here: every chart a pack declares for the audience
 * `nonprofits`, with statements of its own, is walked the same way, so the
 * next one a pack adds is covered by this file the day it lands.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { readTools, writeTools, type Backend } from '../../packages/mcp/src/index.js';
import { freshDatabase, one } from '../helpers/db.js';
import { newInstanceAdmin } from '../helpers/factory.js';
import { packsWhere } from '../helpers/packs.js';
import { backendFor, list, record } from './helpers.js';

const NONPROFITS = 'nonprofits';

const associations = packsWhere('with a chart for associations that reports on statements of its own', (pack) =>
  pack.charts.some((chart) => chart.audience === NONPROFITS && chart.statements.length > 0),
).flatMap((pack) =>
  pack.charts
    .filter((chart) => chart.audience === NONPROFITS && chart.statements.length > 0)
    .map((chart) => ({ pack, chart })),
);

const year = 2026;
const from = `${year}-01-01`;
const to = `${year}-12-31`;

/** What the association earns and spends in the year, and so its result. */
const EARNED = 1200;
const SPENT = 450;
const RESULT = EARNED - SPENT;

let db: PGlite;
let admin: Backend;

beforeAll(async () => {
  db = await freshDatabase();
  admin = backendFor(db, await newInstanceAdmin(db));
}, 120_000);

afterAll(async () => {
  await db.close();
});

/** The lowest code of the company's chart with that account type. */
async function firstAccountOf(companyId: string, type: string): Promise<string> {
  const row = await one<{ code: string }>(
    db,
    `select code from accounts
      where company_id = $1 and account_type = $2::account_type and not deprecated
      order by code limit 1`,
    [companyId, type],
  );
  return row.code;
}

/** One posted entry of two lines on the miscellaneous journal. */
async function book(companyId: string, date: string, debit: string, credit: string, amount: number): Promise<void> {
  const entry = await one<{ id: string }>(
    db,
    `insert into entries (company_id, journal_id, entry_date, description)
     select $1, miscellaneous_journal_id, $2::date, 'Entry of the year' from companies where id = $1 returning id`,
    [companyId, date],
  );
  await db.query(
    `insert into entry_lines (entry_id, company_id, account_id, sequence, debit, credit)
     values ($1, $2, account_id_by_code($2, $3), 10, $5, 0),
            ($1, $2, account_id_by_code($2, $4), 20, 0, $5)`,
    [entry.id, companyId, debit, credit, amount],
  );
  await db.query('select post_entry($1)', [entry.id]);
}

/** A statement through the tool, as line code → amount, and what it left out. */
async function statementOf(
  companyId: string,
  code: string,
): Promise<{ amounts: Record<string, number>; unmapped: unknown[] }> {
  const answer = record(
    await readTools.financialStatement(admin, { company_id: companyId, statement_code: code, from, to }),
  );
  const amounts = Object.fromEntries(
    list(answer['lines']).map((line) => [String(line['line_code']), Number(line['amount'] ?? 0)]),
  );
  return { amounts, unmapped: list(answer['unmapped_accounts']) };
}

describe.each(associations.map(({ pack, chart }) => [`${pack.slug}/${chart.code}`, pack, chart] as const))(
  'an association on %s, through the server',
  (_label, pack, chart) => {
    const country = pack.manifest.country;
    let companyId: string;

    it('is told by describe_pack that the country has a chart for it, with its statements', async () => {
      const answer = record(await readTools.describePack(admin, { country }));
      const charts = list(list(answer['packs'])[0]!['charts']);
      const offered = charts.find((candidate) => candidate['code'] === chart.code);
      expect(offered, chart.code).toBeDefined();
      expect(offered!['audience']).toBe(NONPROFITS);
      expect([...(offered!['statements'] as string[])].sort()).toEqual([...chart.statements].sort());
    });

    it('is created on that chart by create_company, and keeps its accounts', async () => {
      const created = record(
        await writeTools.createCompany(admin, {
          name: `Association ${chart.code}`,
          country,
          chart_code: chart.code,
          fiscal_year: year,
          fiscal_year_start: from,
        }),
      );
      companyId = String(record(created['company'])['id']);

      const accounts = record(await readTools.listAccounts(admin, { company_id: companyId, include_all: true, limit: 5000 }));
      const codes = list(accounts['accounts']).map((account) => String(account['code']));
      const declared = chart.accounts.map((account) => account.code);
      expect(codes.length, chart.code).toBeGreaterThan(0);
      expect(codes.every((code) => declared.includes(code)), chart.code).toBe(true);
    });

    it('is offered the statements of its chart as its own, and the generic ones beside them', async () => {
      const answer = record(await readTools.listStatements(admin, { company_id: companyId, at: to }));
      const offered = list(answer['statements']);
      const own = offered.filter((statement) => statement['is_default'] === true).map((statement) => statement['code']);
      expect([...own].sort()).toEqual([...chart.statements].sort());
      expect(offered.some((statement) => statement['country'] === null), 'the generic framework').toBe(true);
    });

    it('draws a kept year on its own balance sheet and income statement, which agree with the generic ones', async () => {
      const cash = await firstAccountOf(companyId, 'asset_cash');
      const income = await firstAccountOf(companyId, 'income');
      const expense = await firstAccountOf(companyId, 'expense');
      await book(companyId, `${year}-03-15`, cash, income, EARNED);
      await book(companyId, `${year}-06-30`, expense, cash, SPENT);

      const generic = {
        bs: await statementOf(companyId, 'IFRS-SME-BS'),
        is: await statementOf(companyId, 'IFRS-SME-IS'),
      };
      expect(generic.is.amounts['PROFIT']).toBeCloseTo(RESULT, 2);
      expect(generic.bs.amounts['A-TOT']).toBeCloseTo(generic.bs.amounts['EL-TOT']!, 2);

      const schemes = pack.statements.filter((statement) => chart.statements.includes(statement.code));
      const sheets = schemes.filter((statement) => statement.kind === 'balance_sheet');
      const results = schemes.filter((statement) => statement.kind === 'income_statement');
      expect(sheets.length, `${chart.code}: a balance sheet of its own`).toBeGreaterThan(0);
      expect(results.length, `${chart.code}: an income statement of its own`).toBeGreaterThan(0);

      for (const scheme of [...sheets, ...results]) {
        const { amounts, unmapped } = await statementOf(companyId, scheme.code);
        expect(unmapped, `${scheme.code}: every account with a balance reaches a line`).toEqual([]);
        const roots = scheme.lines.filter((line) => line.parent === null && line.is_total).map((line) => line.code);

        if (scheme.kind === 'balance_sheet') {
          // The two sides, each a total at the top of the scheme.
          expect(roots, `${scheme.code}: two sides`).toHaveLength(2);
          const [assets, liabilities] = roots.map((code) => amounts[code]!);
          expect(assets, `${scheme.code}: the two sides agree`).toBeCloseTo(liabilities!, 2);
          expect(assets, `${scheme.code}: the generic balance sheet says the same`).toBeCloseTo(
            generic.bs.amounts['A-TOT']!,
            2,
          );
        } else {
          // The result of the year is the last total at the top of the scheme.
          const result = roots.at(-1)!;
          expect(amounts[result], `${scheme.code}: the result of the year, ${result}`).toBeCloseTo(RESULT, 2);
        }
      }
    });
  },
);
