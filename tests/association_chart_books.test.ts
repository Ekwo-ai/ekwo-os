import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany } from './helpers/factory.js';
import { packWhere, roleOf } from './helpers/packs.js';

// The books of an association, kept on a chart of its own. The French pack
// carries the chart of règlement ANC 2018-06 — the general chart less what an
// entity without capital never holds, plus the accounts of its article 320-2 —
// and this is what a year on it looks like: a gift, a transfer to a dedicated
// fund, the volunteering the association records beside its accounts, and the
// close.
//
// country-literal: the scenario books the gifts and the dedicated funds of a French association, on the codes of its regulation
const pack = packWhere('a French association chart', (p) => p.manifest.country === 'FR' && p.charts.some((c) => c.code === 'association'));
const chart = pack.charts.find((c) => c.code === 'association')!;

const BANK = roleOf(pack, 'bank');
const GIFTS = '754110'; // Dons manuels
const TO_DEDICATED = '689400'; // Reports en fonds dédiés sur subventions d'exploitation
const DEDICATED = '194000'; // Fonds dédiés sur subventions d'exploitation
const VOLUNTEER_STAFF = '864000'; // Personnel bénévole
const VOLUNTEERING = '875000'; // Bénévolat

const from = '2026-01-01';
const to = '2026-12-31';

let db: PGlite;
let companyId: string;
let ownerId: string;

const n = (value: string | null | undefined): number => Number(value ?? 0);

async function entry(date: string, debit: string, credit: string, amount: number, label: string): Promise<void> {
  const row = await one<{ id: string }>(
    db,
    `insert into entries (company_id, journal_id, entry_date, description)
     select $1, miscellaneous_journal_id, $2::date, $3 from companies where id = $1 returning id`,
    [companyId, date, label],
  );
  await db.query(
    `insert into entry_lines (entry_id, company_id, account_id, sequence, debit, credit)
     values ($1, $2, account_id_by_code($2, $3), 10, $5, 0),
            ($1, $2, account_id_by_code($2, $4), 20, 0, $5)`,
    [row.id, companyId, debit, credit, amount],
  );
  await db.query('select post_entry($1)', [row.id]);
}

async function amounts(code: string): Promise<Record<string, number>> {
  const lines = await rows<{ line_code: string; amount: string }>(
    db,
    'select line_code, amount from financial_statement($1, $2, $3, $4)',
    [companyId, code, from, to],
  );
  return Object.fromEntries(lines.map((l) => [l.line_code, n(l.amount)]));
}

async function balanceOf(code: string): Promise<number> {
  const row = await one<{ balance: string | null }>(
    db,
    `select sum(l.debit - l.credit)::text as balance
       from entry_lines l join entries e on e.id = l.entry_id
      where e.company_id = $1 and e.state = 'posted' and l.account_id = account_id_by_code($1, $2)`,
    [companyId, code],
  );
  return n(row.balance);
}

beforeAll(async () => {
  db = await freshDatabase();
  ({ companyId, ownerId } = await newCompany(db, { country: pack.manifest.country, chart: chart.code, name: 'Association' }));
}, 120_000);

afterAll(async () => {
  await db.close();
});

describe('a company installed on a chart for associations', () => {
  it('keeps every account of that chart, and only those', async () => {
    const installed = await rows<{ code: string }>(db, 'select code from accounts where company_id = $1 order by code', [
      companyId,
    ]);
    expect(installed.map((a) => a.code)).toEqual(chart.accounts.map((a) => a.code).sort());
    expect(chart.audience).toBe('nonprofits');
  });

  it('reports a gift less what it dedicates as its result, and leaves volunteering out of it', async () => {
    await entry('2026-03-15', BANK, GIFTS, 1000, 'Dons de la campagne de printemps');
    await entry('2026-12-31', TO_DEDICATED, DEDICATED, 200, 'Part de la subvention non utilisée');
    await entry('2026-12-31', VOLUNTEER_STAFF, VOLUNTEERING, 300, 'Heures de bénévolat valorisées');

    // The chart names no scheme of its own yet, so it reports on the generic
    // framework, which every account of it reaches.
    const offered = await rows<{ code: string }>(db, 'select code from available_statements($1)', [companyId]);
    for (const { code } of offered) {
      expect(await rows(db, 'select * from unmapped_accounts($1, $2, $3, $4)', [companyId, code, from, to])).toEqual([]);
    }

    const is = await amounts('IFRS-SME-IS');
    const bs = await amounts('IFRS-SME-BS');
    expect(is['PROFIT']).toBeCloseTo(800, 2);
    expect(bs['E-RESULT']).toBeCloseTo(800, 2);
    expect(bs['A-TOT']).toBeCloseTo(1000, 2);
    expect(bs['A-TOT']).toBeCloseTo(bs['EL-TOT']!, 2);
  });

  it('closes the year on the result accounts of the pack, the contributions in kind left as they are', async () => {
    const year = await one<{ id: string }>(db, 'select id from fiscal_years where company_id = $1', [companyId]);
    const closed = await asUser(db, ownerId, () =>
      one<{ close_fiscal_year: { result: string; result_kind: string } }>(db, 'select close_fiscal_year($1)', [year.id]),
    );
    expect(n(closed.close_fiscal_year.result)).toBeCloseTo(800, 2);
    expect(closed.close_fiscal_year.result_kind).toBe('profit');
    expect(await balanceOf(roleOf(pack, 'current_year_result_profit'))).toBeCloseTo(-800, 2);
    expect(await balanceOf(GIFTS)).toBeCloseTo(0, 2);
    expect(await balanceOf(VOLUNTEER_STAFF)).toBeCloseTo(300, 2);
    expect(await balanceOf(VOLUNTEERING)).toBeCloseTo(-300, 2);
  });
});
