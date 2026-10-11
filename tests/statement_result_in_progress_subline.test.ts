/**
 * The result of the year in progress, as a sub-line of the line that carries
 * it.
 *
 * Before the close, a balance sheet carries the result nobody has closed yet
 * on the line the close would leave it on. Where that line also takes other
 * balances — the result brought forward, retained earnings — the pack says
 * `combined`, and `financial_statement_of_kind()` shows the result in
 * progress as a row of its own under that line; where the line is the result
 * alone, the pack says `alone` and the line is shown as it is. These tests
 * hold that on a Belgian company in the middle of its year, with a profit and
 * with a loss; on a French one, whose line is the result alone; on a closed
 * year, where nothing is in progress; and on `ekwo pack check`, which refuses
 * a balance sheet that has not decided or decides against its own model.
 */

import type { PGlite } from '@electric-sql/pglite';
import { cp, mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { readPack } from '../packages/cli/src/index.js';
import { asUser, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, type Fixture } from './helpers/factory.js';
import { packOfCountry, packsRoot, packWhere } from './helpers/packs.js';

let db: PGlite;

beforeAll(async () => {
  db = await freshDatabase();
}, 120_000);

afterAll(async () => {
  await db.close();
});

interface Row {
  statement_code: string;
  line_code: string;
  parent_code: string | null;
  name: string;
  is_total: boolean;
  amount: string;
}

const SUFFIX = ':result_in_progress';

async function balanceSheet(company: string, from: string, to: string): Promise<Row[]> {
  return rows<Row>(
    db,
    `select statement_code, line_code, parent_code, name, is_total, amount::text
       from financial_statement_of_kind($1, 'balance_sheet', $2::date, $3::date)`,
    [company, from, to],
  );
}

const amountOf = (lines: Row[], code: string): number => Number(lines.find((l) => l.line_code === code)?.amount);
const subLines = (lines: Row[]): Row[] => lines.filter((l) => l.line_code.endsWith(SUFFIX));

/** The label the company's pack gives the sub-line of its balance sheet. */
function labelOf(country: string, code: string): string | null {
  return packOfCountry(country).statements.find((s) => s.code === code)?.result_in_progress_name ?? null;
}

async function sale(fx: Fixture, date: string, amount: number, taxCode: string, accountCode: string, country: string) {
  const customer = await newContact(db, fx.companyId, { type: 'customer', country });
  const invoice = await newDocument(db, fx.companyId, {
    docType: 'sale_invoice',
    contactId: customer,
    date,
    lines: [{ unitPrice: amount, taxCode, accountCode }],
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
  // One sale of 2 500,00 at 21 %: 3 025,00 owed by the customer, 525,00 of
  // VAT owed to the State, and 2 500,00 of result on rubric 14, which also
  // takes the result brought forward.
  let fx: Fixture;
  let lines: Row[];

  beforeAll(async () => {
    fx = await newCompany(db, { country: 'BE', name: 'Sous-ligne SRL' });
    await sale(fx, '2026-03-15', 2500, 'BE-S-21', '700000', 'BE');
    lines = await balanceSheet(fx.companyId, '2026-01-01', '2026-06-30');
  }, 60_000);

  it('shows the 2 500,00 in progress as a sub-line under rubric 14, with the pack label', () => {
    const [row] = subLines(lines);
    expect(subLines(lines)).toHaveLength(1);
    expect(row?.line_code).toBe(`14${SUFFIX}`);
    expect(row?.parent_code).toBe('14');
    expect(row?.is_total).toBe(false);
    expect(Number(row?.amount)).toBe(2500);
    expect(row?.name).toBe(labelOf('BE', row?.statement_code ?? ''));
    expect(row?.name).toBeTruthy();
  });

  it('places it right under its line', () => {
    const at = lines.findIndex((l) => l.line_code === '14');
    expect(lines[at + 1]?.line_code).toBe(`14${SUFFIX}`);
  });

  it('changes no figure: totals 3 025,00 = 3 025,00, and every line of the scheme as financial_statement() gives it', async () => {
    expect(amountOf(lines, '20/58')).toBe(3025);
    expect(amountOf(lines, '10/49')).toBe(3025);
    expect(amountOf(lines, '14')).toBe(2500);

    const statutory = await rows<{ line_code: string; amount: string }>(
      db,
      `select line_code, amount::text from financial_statement($1, $2, date '2026-01-01', date '2026-06-30')`,
      [fx.companyId, lines[0]?.statement_code],
    );
    expect(lines.filter((l) => !l.line_code.endsWith(SUFFIX)).map((l) => [l.line_code, l.amount])).toEqual(
      statutory.map((l) => [l.line_code, l.amount]),
    );
  });
});

describe('a Belgian company with a loss in progress', () => {
  it('shows the loss as a negative sub-line under rubric 14', async () => {
    const fx = await newCompany(db, { country: 'BE', name: 'Perte en cours bis SRL' });
    await purchase(fx, '2026-02-10', 1000);
    const lines = await balanceSheet(fx.companyId, '2026-01-01', '2026-06-30');
    expect(subLines(lines).map((l) => [l.line_code, Number(l.amount)])).toEqual([[`14${SUFFIX}`, -1000]]);
    expect(amountOf(lines, '20/58')).toBe(amountOf(lines, '10/49'));
  });
});

describe('a French company in the middle of its year', () => {
  it('shows DI as it is: the line is the result alone, and no sub-line is drawn', async () => {
    const fx = await newCompany(db, { country: 'FR', name: 'Sans sous-ligne SAS' });
    await sale(fx, '2026-03-15', 2500, 'FR-S-20', '706000', 'FR');
    const lines = await balanceSheet(fx.companyId, '2026-01-01', '2026-06-30');
    expect(subLines(lines)).toEqual([]);
    expect(amountOf(lines, 'DI')).toBe(2500);
  });
});

describe('a year that has been closed', () => {
  let fx: Fixture;

  beforeAll(async () => {
    fx = await newCompany(db, { country: 'BE', name: 'Clôturée bis SRL' });
    await db.query(
      `insert into fiscal_years (company_id, name, start_date, end_date)
       values ($1, 'Exercice 2027', date '2027-01-01', date '2027-12-31')`,
      [fx.companyId],
    );
    await sale(fx, '2026-03-15', 2500, 'BE-S-21', '700000', 'BE');
    await purchase(fx, '2026-09-10', 1000);
    const year = await one<{ id: string }>(
      db,
      `select id from fiscal_years where company_id = $1 and start_date = date '2026-01-01'`,
      [fx.companyId],
    );
    await asUser(db, fx.ownerId, () => db.query(`select close_fiscal_year($1)`, [year.id]));
    await sale(fx, '2027-02-01', 400, 'BE-S-21', '700000', 'BE');
  }, 60_000);

  it('has nothing in progress at its end: rubric 14 holds the closed 1 500,00, with no sub-line', async () => {
    const lines = await balanceSheet(fx.companyId, '2026-01-01', '2026-12-31');
    expect(subLines(lines)).toEqual([]);
    expect(amountOf(lines, '14')).toBe(1500);
    expect(amountOf(lines, '20/58')).toBe(amountOf(lines, '10/49'));
  });

  it('shows the result to date on a period that stops before the close', async () => {
    const lines = await balanceSheet(fx.companyId, '2026-01-01', '2026-06-30');
    expect(subLines(lines).map((l) => Number(l.amount))).toEqual([2500]);
  });

  it('shows only the next year in progress beside what the close carried', async () => {
    const lines = await balanceSheet(fx.companyId, '2027-01-01', '2027-03-31');
    expect(amountOf(lines, '14')).toBe(1500 + 400);
    expect(subLines(lines).map((l) => Number(l.amount))).toEqual([400]);
  });
});

// ---------------------------------------------------------------------------
// ekwo pack check
// ---------------------------------------------------------------------------

describe('ekwo pack check', () => {
  const balanceSheetOf = (pack: ReturnType<typeof packOfCountry>, value: 'combined' | 'alone') =>
    pack.statements.find((s) => s.kind === 'balance_sheet' && s.result_in_progress === value);
  const combined = packWhere('a balance sheet that combines the result in progress', (p) => !!balanceSheetOf(p, 'combined'));
  const alone = packWhere('a balance sheet that holds the result alone', (p) => !!balanceSheetOf(p, 'alone'));

  /** A copy of a pack whose balance sheet `edit` rewrote, read back: the message it is refused with. */
  async function refusal(
    pack: ReturnType<typeof packOfCountry>,
    code: string,
    edit: (statement: Record<string, unknown>) => void,
  ): Promise<string> {
    const dir = await mkdtemp(join(tmpdir(), 'ekwo-result-in-progress-'));
    try {
      await cp(join(packsRoot, 'schema'), join(dir, 'schema'), { recursive: true });
      await cp(join(packsRoot, pack.slug), join(dir, pack.slug), { recursive: true });
      const path = join(dir, pack.slug, 'statements.json');
      const file = JSON.parse(await readFile(path, 'utf8')) as { statements: Record<string, unknown>[] };
      edit(file.statements.find((s) => s['code'] === code)!);
      await writeFile(path, JSON.stringify(file), 'utf8');
      return await readPack(pack.slug, dir).then(
        () => '',
        (e: Error) => e.message,
      );
    } finally {
      await rm(dir, { recursive: true, force: true });
    }
  }

  it('refuses a balance sheet that has not decided, and says what its model decides', async () => {
    const code = balanceSheetOf(combined, 'combined')!.code;
    const message = await refusal(combined, code, (s) => {
      delete s['result_in_progress'];
      delete s['result_in_progress_name'];
    });
    expect(message).toContain(`statements.json ${code}: says nothing of the result of the year in progress`);
    expect(message).toContain('Add "result_in_progress": "combined"');
  });

  it('refuses a value the scheme and the chart contradict', async () => {
    const code = balanceSheetOf(alone, 'alone')!.code;
    const message = await refusal(alone, code, (s) => {
      s['result_in_progress'] = 'combined';
      s['result_in_progress_name'] = 'Result in progress';
    });
    expect(message).toContain(`statements.json ${code} result_in_progress: is combined, and the scheme says alone`);
  });

  it('refuses a combined balance sheet with no label for its sub-line', async () => {
    const code = balanceSheetOf(combined, 'combined')!.code;
    const message = await refusal(combined, code, (s) => {
      delete s['result_in_progress_name'];
    });
    expect(message).toContain(`statements.json ${code} result_in_progress_name: is missing`);
  });

  it('accepts every pack of this checkout as it stands', async () => {
    await expect(readPack(combined.slug, packsRoot)).resolves.toBeTruthy();
    await expect(readPack(alone.slug, packsRoot)).resolves.toBeTruthy();
  });
});
