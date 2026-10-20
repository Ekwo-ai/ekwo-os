import type { PGlite } from '@electric-sql/pglite';
import { cp, mkdtemp, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { compilePack, packsDir, readPack } from '../packages/cli/src/index.js';
import { expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument } from './helpers/factory.js';
import { allPacks, somePack } from './helpers/packs.js';

/**
 * A regime where one tax on turnover replaces VAT (decision 0080).
 *
 * The regime, its form and its brackets are invented — `ZZ-TT`, graded on a
 * trailing window of twelve months and annualised for a company active for
 * fewer — and declared for the country of whichever pack the companies are
 * installed with. The brackets:
 *
 *   up to 180 000.00   4 %     deduction      0.00
 *   up to 360 000.00   7.3 %   deduction  5 940.00
 *   above              9.5 %   deduction 13 860.00
 *
 * and the tax of a period is its turnover x (base x rate / 100 - deduction) /
 * base. Every figure below is worked out by hand to the cent:
 *
 *   1. a base exactly on a threshold takes the lower bracket;
 *   2. one cent of turnover more moves the window into the next;
 *   3. a credit note lowers the turnover of its own period;
 *   4. a new company's window is annualised, and its first period is its own;
 *   5. a change of regime in the middle of a year is refused, and so are two
 *      regimes on one day and a VAT line under the regime;
 *   6. the tax is posted once, its declaration is prepared and listed by
 *      upcoming_filings(), which no longer lists the periodic VAT return;
 *   7. the pack file: read, refused where it cannot hold, compiled into a seed
 *      that leaves every other pack's unchanged.
 *
 * No country's regime is under test.
 */

let db: PGlite;
let country: string;
let expenseCode: string;
let incomeCode: string;

const REGIME = 'ZZ-TT';
const FORM = 'ZZ-TT-RETURN';

let number = 0;
async function sale(
  companyId: string,
  contactId: string,
  date: string,
  amount: string,
  docType: 'sale_invoice' | 'sale_credit_note' = 'sale_invoice',
): Promise<string> {
  number += 1;
  const document = await newDocument(db, companyId, {
    docType,
    number: `ZZ-TT-${number}`,
    contactId,
    date,
    lines: [{ unitPrice: Number(amount), accountCode: incomeCode, taxCode: null }],
  });
  await db.query(`update document_lines set tax_id = null where document_id = $1`, [document]);
  await db.query(`select post_document($1)`, [document]);
  return document;
}

async function company(name: string, start: string, years: { start: string; end: string }[]): Promise<{ id: string; customer: string }> {
  const fixture = await newCompany(db, {
    country,
    name,
    fiscalYear: { name: `FY ${start}`, start, end: years[0]?.end ?? start },
  });
  for (const year of years.slice(1)) {
    await db.query(`insert into fiscal_years (company_id, name, start_date, end_date) values ($1, $2, $3, $4)`, [
      fixture.companyId,
      `FY ${year.start}`,
      year.start,
      year.end,
    ]);
  }
  return { id: fixture.companyId, customer: await newContact(db, fixture.companyId, { country }) };
}

const tax = async (companyId: string, from: string, to: string): Promise<Record<string, string>> =>
  one<Record<string, string>>(
    db,
    `select turnover::text, window_turnover::text, window_months_counted::text, round(base, 2)::text as base,
            bracket_sequence::text, round(effective_rate, 10)::text as effective_rate, tax::text
       from turnover_tax_return($1, $2, $3)`,
    [companyId, from, to],
  );

beforeAll(async () => {
  db = await freshDatabase();
  // A country whose pack books what a declaration owes and keeps a periodic
  // return, so that both the debt and the return left out are visible.
  country = (
    await one<{ country: string }>(
      db,
      `select d.country from country_defaults d
        where d.tax_payable_code is not null and d.misc_journal_code is not null
          and exists (select 1 from tax_report_templates t where t.country = d.country and t.is_periodic_return)
        order by d.country limit 1`,
    )
  ).country;
  const probe = await newCompany(db, { country, name: 'Probe' });
  incomeCode = (
    await one<{ code: string }>(
      db,
      `select code from accounts where company_id = $1 and account_type = 'income' order by code limit 1`,
      [probe.companyId],
    )
  ).code;
  expenseCode = (
    await one<{ code: string }>(
      db,
      `select code from accounts where company_id = $1 and account_type = 'expense' order by code limit 1`,
      [probe.companyId],
    )
  ).code;

  await db.query(
    `insert into tax_report_templates (country, code, name, periods, period_default, valid_from, legal_reference,
                                       is_periodic_return, deadline_rule, deadline_day, deadline_reference)
     values ($1, $2, 'Invented turnover tax return', array['month']::declaration_period[], 'month', '2020-01-01',
             'Invented for the test', false, 'day_of_month_after_period', 20, 'Invented for the test')`,
    [country, FORM],
  );
  await db.query(
    `insert into turnover_tax_regimes (country, code, name, replaces, report_code, window_months, short_window,
                                       expense_account_code, legal_reference)
     values ($1, $2, 'Invented turnover tax', array['vat']::tax_kind[], $3, 12, 'annualise', $4, 'Invented for the test')`,
    [country, REGIME, FORM, expenseCode],
  );
  await db.query(
    `insert into turnover_tax_brackets (country, regime_code, valid_from, sequence, up_to, nominal_rate, deduction, legal_reference)
     values ($1, $2, '2020-01-01', 10, 180000.00, 4.0, 0, 'Invented for the test'),
            ($1, $2, '2020-01-01', 20, 360000.00, 7.3, 5940.00, 'Invented for the test'),
            ($1, $2, '2020-01-01', 30, null, 9.5, 13860.00, 'Invented for the test')`,
    [country, REGIME],
  );
}, 180_000);

afterAll(async () => {
  await db.close();
});

describe('an established company, graded on its trailing year', () => {
  let co: { id: string; customer: string };

  beforeAll(async () => {
    co = await company('Established', '2025-01-01', [
      { start: '2025-01-01', end: '2025-12-31' },
      { start: '2026-01-01', end: '2026-12-31' },
    ]);
    await db.query(`insert into company_tax_regimes (company_id, regime_code, valid_from) values ($1, $2, '2025-01-01')`, [
      co.id,
      REGIME,
    ]);
    await sale(co.id, co.customer, '2025-06-15', '180000.00');
    await sale(co.id, co.customer, '2026-01-10', '10000.00');
    await sale(co.id, co.customer, '2026-02-10', '5000.00');
    await sale(co.id, co.customer, '2026-03-05', '3000.00');
    await sale(co.id, co.customer, '2026-03-20', '1000.00', 'sale_credit_note');
  }, 180_000);

  it('takes the lower bracket for a base exactly on its threshold', async () => {
    // Window 2025-01 to 2025-12: 180 000.00, the threshold itself: 4 %.
    expect(await tax(co.id, '2026-01-01', '2026-01-31')).toEqual({
      turnover: '10000.00',
      window_turnover: '180000.00',
      window_months_counted: '12',
      base: '180000.00',
      bracket_sequence: '10',
      effective_rate: '0.0400000000',
      tax: '400.00',
    });
  });

  it('moves into the next bracket once the window passes the threshold', async () => {
    // Window 2025-02 to 2026-01: 190 000.00.
    // (190 000 x 7.3 % - 5 940) / 190 000 = 7 930 / 190 000 = 0.0417368421…
    // 5 000.00 x that = 208.684… → 208.68.
    const row = await tax(co.id, '2026-02-01', '2026-02-28');
    expect(row).toMatchObject({ window_turnover: '190000.00', bracket_sequence: '20', effective_rate: '0.0417368421' });
    expect(row.tax).toBe('208.68');
  });

  it('lowers the turnover of a period by its credit note', async () => {
    // 3 000.00 - 1 000.00 = 2 000.00; window 2025-03 to 2026-02: 195 000.00.
    // (195 000 x 7.3 % - 5 940) / 195 000 = 8 295 / 195 000 = 0.0425384615…
    // 2 000.00 x that = 85.0769… → 85.08.
    const row = await tax(co.id, '2026-03-01', '2026-03-31');
    expect(row).toMatchObject({ turnover: '2000.00', window_turnover: '195000.00', effective_rate: '0.0425384615' });
    expect(row.tax).toBe('85.08');
  });

  it('posts the tax once, on the expense and the debt, and prepares its declaration', async () => {
    const posted = await one<{ tax: string; entry_id: string; filing_id: string }>(
      db,
      `select tax::text, entry_id, filing_id from post_turnover_tax($1, '2026-01-01', '2026-01-31')`,
      [co.id],
    );
    expect(posted.tax).toBe('400.00');
    const lines = await rows<{ code: string; debit: string; credit: string }>(
      db,
      `select a.code, l.debit::text, l.credit::text
         from entry_lines l join accounts a on a.id = l.account_id
        where l.entry_id = $1 order by l.sequence`,
      [posted.entry_id],
    );
    const payable = (
      await one<{ code: string }>(
        db,
        `select d.tax_payable_code as code from country_defaults d where d.country = $1`,
        [country],
      )
    ).code;
    expect(lines).toEqual([
      { code: expenseCode, debit: '400.00', credit: '0.00' },
      { code: payable, debit: '0.00', credit: '400.00' },
    ]);
    expect(
      (await one<{ state: string }>(db, `select state from entries where id = $1`, [posted.entry_id])).state,
    ).toBe('posted');
    expect(
      await expectError(db, `select post_turnover_tax($1, '2026-01-01', '2026-01-31')`, [co.id]),
    ).toMatch(/^turnover_tax_already_posted/);
  });

  it('is listed by upcoming_filings(), and the periodic VAT return is not', async () => {
    const listed = await rows<{ report_code: string; period_start: string; state: string | null; due_date: string }>(
      db,
      `select report_code, period_start::text, state::text, due_date::text
         from upcoming_filings($1, '2026-01-01', '2026-02-28')`,
      [co.id],
    );
    expect(listed).toEqual([
      { report_code: FORM, period_start: '2026-01-01', state: 'ready', due_date: '2026-02-20' },
      { report_code: FORM, period_start: '2026-02-01', state: null, due_date: '2026-03-20' },
    ]);
  });
});

describe('a new company, whose window is shorter than its months', () => {
  let co: { id: string; customer: string };

  beforeAll(async () => {
    co = await company('New', '2026-04-01', [{ start: '2026-04-01', end: '2026-12-31' }]);
    await db.query(`insert into company_tax_regimes (company_id, regime_code, valid_from) values ($1, $2, '2026-04-01')`, [
      co.id,
      REGIME,
    ]);
    await sale(co.id, co.customer, '2026-04-10', '20000.00');
    await sale(co.id, co.customer, '2026-05-10', '10000.00');
    await sale(co.id, co.customer, '2026-06-10', '1000.00');
  }, 180_000);

  it('annualises its first period on its own turnover', async () => {
    // No month before: 20 000.00 x 12 = 240 000.00.
    // (240 000 x 7.3 % - 5 940) / 240 000 = 11 580 / 240 000 = 0.04825 → 965.00.
    expect(await tax(co.id, '2026-04-01', '2026-04-30')).toMatchObject({
      window_months_counted: '0',
      base: '240000.00',
      bracket_sequence: '20',
      effective_rate: '0.0482500000',
      tax: '965.00',
    });
  });

  it('annualises the months it has', async () => {
    // One month before, April: 20 000.00 x 12 / 1 = 240 000.00 → 10 000.00 x 0.04825 = 482.50.
    expect(await tax(co.id, '2026-05-01', '2026-05-31')).toMatchObject({
      window_months_counted: '1',
      tax: '482.50',
    });
    // Two months, 30 000.00 x 12 / 2 = 180 000.00, on the threshold: 4 % of 1 000.00.
    expect(await tax(co.id, '2026-06-01', '2026-06-30')).toMatchObject({
      window_months_counted: '2',
      base: '180000.00',
      bracket_sequence: '10',
      tax: '40.00',
    });
  });
});

describe('the refusals', () => {
  let co: { id: string; customer: string };

  beforeAll(async () => {
    co = await company('Refusals', '2026-01-01', [{ start: '2026-01-01', end: '2026-12-31' }]);
  }, 180_000);

  it('refuses a change of regime in the middle of a financial year', async () => {
    expect(
      await expectError(db, `insert into company_tax_regimes (company_id, regime_code, valid_from) values ($1, $2, '2026-07-01')`, [
        co.id,
        REGIME,
      ]),
    ).toMatch(/^regime_change_mid_year/);
    expect(
      await expectError(
        db,
        `insert into company_tax_regimes (company_id, regime_code, valid_from, valid_to) values ($1, $2, '2026-01-01', '2026-06-30')`,
        [co.id, REGIME],
      ),
    ).toMatch(/^regime_change_mid_year/);
  });

  it('refuses a regime its pack does not carry, and two on one day', async () => {
    expect(
      await expectError(db, `insert into company_tax_regimes (company_id, regime_code, valid_from) values ($1, 'ZZ-NONE', '2026-01-01')`, [
        co.id,
      ]),
    ).toMatch(/^unknown_turnover_regime/);
    await db.query(`insert into company_tax_regimes (company_id, regime_code, valid_from) values ($1, $2, '2026-01-01')`, [co.id, REGIME]);
    await db.query(`insert into fiscal_years (company_id, name, start_date, end_date) values ($1, 'FY 2027', '2027-01-01', '2027-12-31')`, [
      co.id,
    ]);
    expect(
      await expectError(db, `insert into company_tax_regimes (company_id, regime_code, valid_from) values ($1, $2, '2027-01-01')`, [
        co.id,
        REGIME,
      ]),
    ).toMatch(/^regime_overlap/);
  });

  it('refuses to post a VAT line under the regime', async () => {
    const vat = await one<{ id: string; code: string }>(
      db,
      `select id, code from taxes where company_id = $1 and tax_kind = 'vat' and applies_to = 'sale' order by code limit 1`,
      [co.id],
    );
    const document = await newDocument(db, co.id, {
      docType: 'sale_invoice',
      number: 'ZZ-TT-VAT',
      contactId: co.customer,
      date: '2026-05-10',
      lines: [{ unitPrice: 100, accountCode: incomeCode, taxCode: vat.code }],
    });
    expect(await expectError(db, `select post_document($1)`, [document])).toMatch(/^tax_replaced_by_regime: .*ZZ-TT/);
  });

  it('refuses a return for a company under no regime', async () => {
    const plain = await company('Plain', '2026-01-01', [{ start: '2026-01-01', end: '2026-12-31' }]);
    expect(await expectError(db, `select * from turnover_tax_return($1, '2026-01-01', '2026-01-31')`, [plain.id])).toMatch(
      /^no_turnover_regime/,
    );
  });
});

describe('the file in a pack', () => {
  const file = (brackets: unknown[]): Record<string, unknown> => ({
    regimes: [
      {
        code: 'ZZ-TT',
        name: 'Invented turnover tax',
        replaces: ['vat'],
        window: { months: 12 },
        expense_account: '__EXPENSE__',
        legal_reference: 'Invented for the test',
        report: {
          code: 'ZZ-TT-RETURN',
          name: 'Invented return',
          periods: ['month'],
          period_default: 'month',
          valid_from: '2020-01-01',
          legal_reference: 'Invented for the test',
          deadline: { rule: 'day_of_month_after_period', day: 20, legal_reference: 'Invented for the test' },
        },
        brackets,
      },
    ],
  });
  const rising = [
    { valid_from: '2020-01-01', up_to: '180000.00', rate: '4', legal_reference: 'Invented' },
    { valid_from: '2020-01-01', rate: '7.3', deduction: '5940.00', legal_reference: 'Invented' },
  ];

  async function copyWith(content: Record<string, unknown>): Promise<string> {
    const dir = await mkdtemp(join(tmpdir(), 'ekwo-turnover-'));
    await cp(join(packsDir(), 'schema'), join(dir, 'schema'), { recursive: true });
    await cp(join(packsDir(), somePack.slug), join(dir, somePack.slug), { recursive: true });
    // An expense account every chart of the pack carries.
    const expense =
      somePack.charts[0]?.accounts
        .filter((a) => a.type === 'expense')
        .map((a) => a.code)
        .find((code) => somePack.charts.every((chart) => chart.accounts.some((a) => a.code === code))) ?? '';
    const text = JSON.stringify(content).replace('__EXPENSE__', expense);
    await writeFile(join(dir, somePack.slug, 'turnover_tax.json'), text, 'utf8');
    return dir;
  }

  it('is compiled for the packs that carry it, and for no other', () => {
    for (const pack of allPacks) {
      if (pack.turnoverTax === null) expect(compilePack(pack), pack.slug).not.toMatch(/turnover_tax/);
      else expect(compilePack(pack), pack.slug).toMatch(/turnover_tax_regimes/);
    }
    expect(somePack.turnoverTax, 'the pack the fixtures copy carries no regime of its own').toBeNull();
  });

  it('is read and compiled into the regime, its form and its brackets', async () => {
    const pack = await readPack(somePack.slug, await copyWith(file(rising)));
    expect(pack.turnoverTax?.regimes.map((r) => r.code)).toEqual(['ZZ-TT']);
    await db.exec(compilePack(pack));
    expect(
      await rows<{ up_to: string | null; nominal_rate: string; deduction: string }>(
        db,
        `select up_to::text, nominal_rate::text, deduction::text from turnover_tax_brackets
          where country = $1 and regime_code = 'ZZ-TT' order by sequence`,
        [somePack.manifest.country],
      ),
    ).toEqual([
      { up_to: '180000.00', nominal_rate: '4.0000', deduction: '0.00' },
      { up_to: null, nominal_rate: '7.3000', deduction: '5940.00' },
    ]);
    expect(
      (await one<{ periodic: boolean }>(
        db,
        `select is_periodic_return as periodic from tax_report_templates where country = $1 and code = 'ZZ-TT-RETURN'`,
        [somePack.manifest.country],
      )).periodic,
    ).toBe(false);
  });

  it('is refused where its brackets do not rise or do not end open', async () => {
    const falling = [
      { valid_from: '2020-01-01', up_to: '360000.00', rate: '4', legal_reference: 'Invented' },
      { valid_from: '2020-01-01', up_to: '180000.00', rate: '5', legal_reference: 'Invented' },
      { valid_from: '2020-01-01', rate: '7.3', legal_reference: 'Invented' },
    ];
    await expect(readPack(somePack.slug, await copyWith(file(falling)))).rejects.toThrow(/rise from one bracket to the next/);
    const closed = [{ valid_from: '2020-01-01', up_to: '180000.00', rate: '4', legal_reference: 'Invented' }];
    await expect(readPack(somePack.slug, await copyWith(file(closed)))).rejects.toThrow(/exactly one bracket without up_to/);
    const formula = [{ valid_from: '2020-01-01', rate: 'base * 0.04', legal_reference: 'Invented' }];
    await expect(readPack(somePack.slug, await copyWith(file(formula)))).rejects.toThrow(/pack_invalid/);
  });
});
