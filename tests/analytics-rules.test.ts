/**
 * The rules of the analytic split decided on 19/10/2026 (decision 0076,
 * `supabase/migrations/20261019130000_an_analytic_value_is_entered_on_the_line.sql`
 * and `20261019130500_analytic_report.sql`).
 *
 * What is guarded: the split of a posted ledger line follows the lock date
 * and the closed fiscal years; a contact with no default takes its parent's,
 * one level up and no further; a retired value takes no new share, and the
 * shares that name it stay, are posted and are credited; `analytic_report()`
 * gives a parent the subtotal of the values below it and a total row; an
 * axis may be required on the expense, the income or the whole result, and a
 * document or an entry that leaves part of it off is refused at posting,
 * while a mirror and a credit note are not; a fixed-asset account carries a
 * split and the report reads its movement apart from the result; the share
 * of a tax nobody gets back lands on the expense with the split of its lines;
 * and `merge_contacts()` hands the kept contact the absorbed one's default.
 *
 * No country is named: the pack is any one that names the accounts the test
 * books on, a fixed-asset and a tax account are found by their type, and the
 * partly recoverable tax is built here.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument } from './helpers/factory.js';
import { packWhere, roleOf } from './helpers/packs.js';

let db: PGlite;
let companyId: string;
let ownerId: string;
let country: string;
let customer: string;
let sales: string;
let purchase: string;
let bank: string;
let fixedAsset: string;
let taxAccount: string;
let project: string;
const v = { top: '', child1: '', child2: '', other: '', grandchild: '', old: '' };

interface Share {
  code: string;
  percentage: string;
  amount: string;
}

interface ReportRow {
  row_kind: 'value' | 'unassigned' | 'total';
  code: string | null;
  level: number | null;
  income: string;
  expense: string;
  result: string;
  fixed_assets: string;
  direct_income: string;
  direct_expense: string;
  direct_result: string;
  direct_fixed_assets: string;
}

const idOf = async (sql: string, params: unknown[]): Promise<string> => (await one<{ id: string }>(db, sql, params)).id;

const newValue = (axis: string, code: string, parent: string | null = null): Promise<string> =>
  idOf(`insert into analytic_values (company_id, axis_id, code, name, parent_id) values ($1, $2, $3, $3, $4) returning id`, [
    companyId,
    axis,
    code,
    parent,
  ]);

const newAxis = (code: string): Promise<string> =>
  idOf(`insert into analytic_axes (company_id, code, name) values ($1, $2, $2) returning id`, [companyId, code]);

const lineOf = (documentId: string, name: string): Promise<string> =>
  idOf(`select id from document_lines where document_id = $1 and name = $2`, [documentId, name]);

const splitOfDocumentLine = (lineId: string): Promise<Share[]> =>
  rows<Share>(
    db,
    `select v.code, x.percentage::text, x.amount::text
       from document_line_analytics x join analytic_values v on v.id = x.analytic_value_id
      where x.document_line_id = $1 order by v.code`,
    [lineId],
  );

const splitOfEntryLine = (lineId: string): Promise<Share[]> =>
  rows<Share>(
    db,
    `select v.code, x.percentage::text, x.amount::text
       from entry_line_analytics x join analytic_values v on v.id = x.analytic_value_id
      where x.entry_line_id = $1 order by v.code`,
    [lineId],
  );

async function splitLine(lineId: string, shares: [string, number][]): Promise<void> {
  for (const [value, percentage] of shares) {
    await db.query(
      `insert into document_line_analytics (company_id, document_line_id, analytic_value_id, percentage)
       values ($1, $2, $3, $4)`,
      [companyId, lineId, value, percentage],
    );
  }
}

async function splitEntryLine(lineId: string, shares: [string, number][]): Promise<void> {
  for (const [value, percentage] of shares) {
    await db.query(
      `insert into entry_line_analytics (company_id, entry_line_id, analytic_value_id, percentage)
       values ($1, $2, $3, $4)`,
      [companyId, lineId, value, percentage],
    );
  }
}

/** A draft entry no document wrote: a debit on one account against the bank. Returns the entry and its debit line. */
async function handEntry(date: string, amount: number, account = purchase): Promise<{ entry: string; line: string }> {
  const entry = await idOf(
    `insert into entries (company_id, journal_id, entry_date, description)
     select $1, miscellaneous_journal_id, $2::date, 'By hand' from companies where id = $1 returning id`,
    [companyId, date],
  );
  await db.query(
    `insert into entry_lines (entry_id, company_id, account_id, sequence, debit, credit)
     values ($1, $2, account_id_by_code($2, $3), 10, $5, 0),
            ($1, $2, account_id_by_code($2, $4), 20, 0, $5)`,
    [entry, companyId, account, bank, amount],
  );
  return { entry, line: await idOf(`select id from entry_lines where entry_id = $1 and sequence = 10`, [entry]) };
}

const report = (axis: string, from = '2026-01-01', to = '2026-12-31'): Promise<ReportRow[]> =>
  rows<ReportRow>(db, `select * from analytic_report($1, $2, $3::date, $4::date)`, [companyId, axis, from, to]);

beforeAll(async () => {
  const pack = packWhere('names a sales, a purchase, a bank and a receivable account, and has a fixed-asset account', (p) => {
    const roles = p.manifest.defaults.roles;
    return ['sales', 'purchase', 'bank', 'receivable'].every((role) => typeof roles[role] === 'string');
  });
  country = pack.manifest.country;
  db = await freshDatabase();
  ({ companyId, ownerId } = await newCompany(db, {
    country,
    name: 'Analytic rules',
    fiscalYear: { name: '2025', start: '2025-01-01', end: '2025-12-31' },
  }));
  await db.query(`insert into fiscal_years (company_id, name, start_date, end_date) values ($1, '2026', '2026-01-01', '2026-12-31')`, [
    companyId,
  ]);
  await db.query(`insert into auth.users (id, email) values ($1, 'owner@analytic-rules.test') on conflict do nothing`, [ownerId]);
  customer = await newContact(db, companyId, { country });
  sales = roleOf(pack, 'sales');
  purchase = roleOf(pack, 'purchase');
  bank = roleOf(pack, 'bank');
  // Found by what they are, never by their number.
  fixedAsset = (
    await one<{ code: string }>(
      db,
      `select code from accounts where company_id = $1 and account_type = 'asset_fixed' order by code limit 1`,
      [companyId],
    )
  ).code;
  taxAccount = (
    await one<{ code: string }>(
      db,
      `select a.code from tax_postings p join accounts a on a.id = p.account_id
        where p.company_id = $1 and p.posting_type = 'tax' order by a.code limit 1`,
      [companyId],
    )
  ).code;

  project = await newAxis('PROJECT');
  v.top = await newValue(project, 'P');
  v.child1 = await newValue(project, 'P1', v.top);
  v.child2 = await newValue(project, 'P2', v.top);
  v.grandchild = await newValue(project, 'P21', v.child2);
  v.other = await newValue(project, 'Q');
  v.old = await newValue(project, 'Z');
}, 180_000);

afterAll(async () => {
  await db.close();
});

describe('the split of a posted ledger line', () => {
  it('is refused in a closed fiscal year, by name', async () => {
    const { entry, line } = await handEntry('2025-06-30', 80);
    await splitEntryLine(line, [[v.child1, 100]]);
    await db.query(`select post_entry($1)`, [entry]);
    const year = await idOf(`select id from fiscal_years where company_id = $1 and name = '2025'`, [companyId]);
    await asUser(db, ownerId, () => db.query(`select close_fiscal_year($1)`, [year]));

    const share = await idOf(`select id from entry_line_analytics where entry_line_id = $1`, [line]);
    expect(await expectError(db, `update entry_line_analytics set analytic_value_id = $2 where id = $1`, [share, v.other])).toMatch(
      /fiscal_year_closed/,
    );
    expect(await expectError(db, `delete from entry_line_analytics where id = $1`, [share])).toMatch(/fiscal_year_closed/);
    expect(await splitOfEntryLine(line)).toEqual([{ code: 'P1', percentage: '100.000', amount: '80.00' }]);
  });

  it('is refused on or before the lock date, and moves after it', async () => {
    const before = await handEntry('2026-02-10', 40);
    await db.query(`select post_entry($1)`, [before.entry]);
    const after = await handEntry('2026-03-10', 60);
    await db.query(`select post_entry($1)`, [after.entry]);
    await db.query(`update companies set lock_date = date '2026-02-28' where id = $1`, [companyId]);
    try {
      expect(
        await expectError(
          db,
          `insert into entry_line_analytics (company_id, entry_line_id, analytic_value_id) values ($1, $2, $3)`,
          [companyId, before.line, v.other],
        ),
      ).toMatch(/period_locked/);

      // After the lock date the posted line is split, changed and unsplit.
      await splitEntryLine(after.line, [[v.other, 100]]);
      await db.query(`update entry_line_analytics set percentage = 50 where entry_line_id = $1`, [after.line]);
      expect(await splitOfEntryLine(after.line)).toEqual([{ code: 'Q', percentage: '50.000', amount: '30.00' }]);

      // A share does not leave a locked line for an open one either.
      await db.query(`update companies set lock_date = null where id = $1`, [companyId]);
      await splitEntryLine(before.line, [[v.other, 100]]);
      await db.query(`update companies set lock_date = date '2026-02-28' where id = $1`, [companyId]);
      expect(
        await expectError(db, `update entry_line_analytics set entry_line_id = $2, percentage = 50 where entry_line_id = $1`, [
          before.line,
          after.line,
        ]),
      ).toMatch(/period_locked/);
      await db.query(`delete from entry_line_analytics where entry_line_id = $1`, [after.line]);
    } finally {
      await db.query(`update companies set lock_date = null where id = $1`, [companyId]);
    }
  });
});

describe('the default of a contact', () => {
  it('falls back to the contact it belongs to, one level up and no further', async () => {
    const parent = await newContact(db, companyId, { name: 'Group', type: 'supplier', country });
    await db.query(`update contacts set analytic_value_id = $2 where id = $1`, [parent, v.child1]);
    const branch = await newContact(db, companyId, { name: 'Branch', type: 'supplier', country });
    await db.query(`update contacts set parent_id = $2 where id = $1`, [branch, parent]);
    const office = await newContact(db, companyId, { name: 'Office of the branch', type: 'supplier', country });
    await db.query(`update contacts set parent_id = $2 where id = $1`, [office, branch]);
    const own = await newContact(db, companyId, { name: 'Branch with its own', type: 'supplier', country });
    await db.query(`update contacts set parent_id = $2, analytic_value_id = $3 where id = $1`, [own, parent, v.child2]);

    const firstLine = async (contactId: string): Promise<Share[]> => {
      const doc = await newDocument(db, companyId, {
        docType: 'purchase_invoice',
        contactId,
        lines: [{ name: 'Bought', unitPrice: 10, accountCode: purchase, taxCode: null }],
      });
      const split = await splitOfDocumentLine(await lineOf(doc, 'Bought'));
      await db.query(`delete from documents where id = $1`, [doc]);
      return split;
    };
    expect((await firstLine(branch)).map((s) => s.code)).toEqual(['P1']);
    expect((await firstLine(own)).map((s) => s.code)).toEqual(['P2']);
    expect(await firstLine(office)).toEqual([]);
  });
});

describe('a retired value', () => {
  let invoice: string;
  let line: string;

  beforeAll(async () => {
    invoice = await newDocument(db, companyId, {
      docType: 'sale_invoice',
      contactId: customer,
      date: '2026-04-01',
      lines: [{ name: 'Old activity', unitPrice: 70, accountCode: sales, taxCode: null }],
    });
    line = await lineOf(invoice, 'Old activity');
    await splitLine(line, [[v.old, 100]]);
    await db.query(`update analytic_values set active = false where id = $1`, [v.old]);
  });

  it('takes no new share, on a document line or on a ledger line, by name', async () => {
    const other = await newDocument(db, companyId, {
      docType: 'sale_invoice',
      contactId: customer,
      lines: [{ name: 'New', unitPrice: 10, accountCode: sales, taxCode: null }],
    });
    expect(
      await expectError(
        db,
        `insert into document_line_analytics (company_id, document_line_id, analytic_value_id) values ($1, $2, $3)`,
        [companyId, await lineOf(other, 'New'), v.old],
      ),
    ).toMatch(/analytic_value_retired/);
    await db.query(`delete from documents where id = $1`, [other]);

    const { entry, line: cost } = await handEntry('2026-04-02', 10);
    expect(
      await expectError(db, `insert into entry_line_analytics (company_id, entry_line_id, analytic_value_id) values ($1, $2, $3)`, [
        companyId,
        cost,
        v.old,
      ]),
    ).toMatch(/analytic_value_retired/);
    await db.query(`delete from entries where id = $1`, [entry]);
  });

  it('is not pre-filled by a product that still names it', async () => {
    const product = await idOf(
      `insert into products (company_id, code, name, analytic_value_id) values ($1, 'RETIRED', 'Retired offer', $2) returning id`,
      [companyId, v.old],
    );
    const doc = await newDocument(db, companyId, {
      docType: 'sale_invoice',
      contactId: customer,
      lines: [{ name: 'Offer', unitPrice: 10, accountCode: sales, taxCode: null }],
    });
    const offer = await lineOf(doc, 'Offer');
    await db.query(`update document_lines set product_id = $2 where id = $1`, [offer, product]);
    expect(await splitOfDocumentLine(offer)).toEqual([]);
    await db.query(`delete from documents where id = $1`, [doc]);
  });

  it('stays on the shares that name it, which are posted and credited with it', async () => {
    expect(await splitOfDocumentLine(line)).toEqual([{ code: 'Z', percentage: '100.000', amount: '70.00' }]);
    // A change that leaves the value where it is is not a new share.
    await db.query(`update document_line_analytics set percentage = 90 where document_line_id = $1`, [line]);
    await db.query(`select post_document($1)`, [invoice]);
    const onLedger = await rows<Share>(
      db,
      `select v.code, x.percentage::text, x.amount::text from entry_line_analytics x
         join analytic_values v on v.id = x.analytic_value_id
         join entry_lines l on l.id = x.entry_line_id
         join documents d on d.entry_id = l.entry_id
        where d.id = $1`,
      [invoice],
    );
    expect(onLedger).toEqual([{ code: 'Z', percentage: '90.000', amount: '-63.00' }]);

    await asUser(db, ownerId, () => db.query(`select cancel_document($1)`, [invoice]));
    const credit = await idOf(`select id from documents where reversed_document_id = $1`, [invoice]);
    expect(await splitOfDocumentLine(await lineOf(credit, 'Old activity'))).toEqual([
      { code: 'Z', percentage: '90.000', amount: '63.00' },
    ]);
    // The exemption was for that credit note, and is gone with it.
    expect(await one<{ s: string }>(db, `select coalesce(current_setting('ekwo.crediting_document', true), '') as s`)).toEqual({
      s: '',
    });
  });
});

describe('analytic_report over a tree of values', () => {
  beforeAll(async () => {
    // P books 10 of its own, P1 100, P2 50, P21 (under P2) 20, Q 30; and 5 of
    // a line goes to no value of the axis.
    for (const [date, amount, shares] of [
      ['2026-07-01', 10, [[v.top, 100]]],
      ['2026-07-02', 100, [[v.child1, 100]]],
      ['2026-07-03', 50, [[v.child2, 100]]],
      ['2026-07-04', 20, [[v.grandchild, 100]]],
      ['2026-07-05', 35, [[v.other, 30 / 0.35]]],
    ] as [string, number, [string, number][]][]) {
      const { entry, line } = await handEntry(date, amount);
      await splitEntryLine(line, shares);
      await db.query(`select post_entry($1)`, [entry]);
    }
  });

  it('gives each parent the subtotal of the values below it, its own amount in the direct columns', async () => {
    const july = await report(project, '2026-07-01', '2026-07-31');
    expect(july.map((r) => [r.row_kind, r.code, r.level, Number(r.expense), Number(r.direct_expense)])).toEqual([
      ['value', 'P', 0, 180, 10],
      ['value', 'P1', 1, 100, 100],
      ['value', 'P2', 1, 70, 50],
      ['value', 'P21', 2, 20, 20],
      ['value', 'Q', 0, 30, 30],
      ['unassigned', null, null, 5, 5],
      ['total', null, null, 215, 215],
    ]);
  });

  it('adds up: the direct amounts and the unassigned row, or the top values and the unassigned row, give the total, which is the income statement', async () => {
    const year = await report(project);
    const total = year.find((r) => r.row_kind === 'total')!;
    const unassigned = year.find((r) => r.row_kind === 'unassigned')!;
    const values = year.filter((r) => r.row_kind === 'value');
    const sum = (list: ReportRow[], key: keyof ReportRow): number => list.reduce((s, r) => s + Number(r[key]), 0);
    expect(sum(values, 'direct_result') + Number(unassigned.result)).toBeCloseTo(Number(total.result), 10);
    expect(sum(values.filter((r) => r.level === 0), 'result') + Number(unassigned.result)).toBeCloseTo(Number(total.result), 10);
    const income = await one<{ result: string }>(
      db,
      `select coalesce(-sum(t.debit - t.credit), 0)::text as result
         from trial_balance($1, '2026-01-01'::date, '2026-12-31'::date) t
        where t.internal_group in ('income', 'expense')`,
      [companyId],
    );
    expect(Number(total.result)).toBeCloseTo(Number(income.result), 10);
  });
});

describe('a required axis', () => {
  let cost: string;
  let centre: string;
  let beforeRequired: string;
  let entryBeforeRequired: string;

  beforeAll(async () => {
    cost = await newAxis('COST');
    centre = await newValue(cost, 'C1');
    // Posted while nothing was required: undone later, under the requirement.
    beforeRequired = await newDocument(db, companyId, {
      docType: 'purchase_invoice',
      contactId: customer,
      date: '2026-08-01',
      lines: [{ name: 'Before', unitPrice: 15, accountCode: purchase, taxCode: null }],
    });
    await db.query(`select post_document($1)`, [beforeRequired]);
    const hand = await handEntry('2026-08-01', 12);
    await db.query(`select post_entry($1)`, [hand.entry]);
    entryBeforeRequired = hand.entry;
  });

  afterAll(async () => {
    await db.query(`update analytic_axes set required_on = 'none' where id = $1`, [cost]);
  });

  it('is off by default, and takes none, expense, income or result only', async () => {
    expect(await one(db, `select required_on from analytic_axes where id = $1`, [cost])).toEqual({ required_on: 'none' });
    expect(await expectError(db, `update analytic_axes set required_on = 'assets' where id = $1`, [cost])).toMatch(
      /analytic_axes_required_on/,
    );
  });

  it('refuses a document whose expense line leaves part of it off, by name, and books it whole', async () => {
    await db.query(`update analytic_axes set required_on = 'expense' where id = $1`, [cost]);
    const bill = await newDocument(db, companyId, {
      docType: 'purchase_invoice',
      contactId: customer,
      date: '2026-08-10',
      lines: [{ name: 'Rent', unitPrice: 100, accountCode: purchase, taxCode: null }],
    });
    const rent = await lineOf(bill, 'Rent');
    expect(await expectError(db, `select post_document($1)`, [bill])).toMatch(/analytic_axis_required: line 10 .* 0 % of analytic axis COST/);
    await splitLine(rent, [[centre, 50]]);
    expect(await expectError(db, `select post_document($1)`, [bill])).toMatch(/analytic_axis_required: .* 50\.000 % of analytic axis COST/);
    await db.query(`update document_line_analytics set percentage = 100 where document_line_id = $1`, [rent]);
    await db.query(`select post_document($1)`, [bill]);
    expect(await one(db, `select state from documents where id = $1`, [bill])).toEqual({ state: 'posted' });

    // An income line is not asked while the axis is required on expense.
    const sale = await newDocument(db, companyId, {
      docType: 'sale_invoice',
      contactId: customer,
      date: '2026-08-10',
      lines: [{ name: 'Sold', unitPrice: 40, accountCode: sales, taxCode: null }],
    });
    await db.query(`select post_document($1)`, [sale]);
  });

  it('on the result, asks the income line too', async () => {
    await db.query(`update analytic_axes set required_on = 'result' where id = $1`, [cost]);
    const sale = await newDocument(db, companyId, {
      docType: 'sale_invoice',
      contactId: customer,
      date: '2026-08-11',
      lines: [{ name: 'Sold again', unitPrice: 40, accountCode: sales, taxCode: null }],
    });
    expect(await expectError(db, `select post_document($1)`, [sale])).toMatch(/analytic_axis_required/);
    await db.query(`delete from documents where id = $1`, [sale]);
  });

  it('refuses an entry keyed by hand that leaves it off, at posting', async () => {
    const { entry, line } = await handEntry('2026-08-12', 25);
    expect(await expectError(db, `select post_entry($1)`, [entry])).toMatch(/analytic_axis_required: line 10 of entry/);
    await splitEntryLine(line, [[centre, 100]]);
    await db.query(`select post_entry($1)`, [entry]);
  });

  it('does not ask what undoes an entry or a document posted before it', async () => {
    await asUser(db, ownerId, () => db.query(`select reverse_entry($1)`, [entryBeforeRequired]));
    await asUser(db, ownerId, () => db.query(`select cancel_document($1)`, [beforeRequired]));
    expect(await one(db, `select state from documents where id = $1`, [beforeRequired])).toEqual({ state: 'cancelled' });
  });

  it('is not asked of a retired axis', async () => {
    await db.query(`update analytic_axes set active = false where id = $1`, [cost]);
    const { entry } = await handEntry('2026-08-13', 5);
    await db.query(`select post_entry($1)`, [entry]);
    await db.query(`update analytic_axes set active = true where id = $1`, [cost]);
  });
});

describe('a fixed-asset account', () => {
  it('carries a split, from the document line to the ledger line, read apart from the result', async () => {
    const capex = await newAxis('CAPEX');
    const site = await newValue(capex, 'SITE1');
    const product = await idOf(
      `insert into products (company_id, code, name, analytic_value_id) values ($1, 'MACHINE', 'A machine', $2) returning id`,
      [companyId, site],
    );
    const bill = await newDocument(db, companyId, {
      docType: 'purchase_invoice',
      contactId: customer,
      date: '2026-09-01',
      lines: [{ name: 'Machine', unitPrice: 1200, accountCode: fixedAsset, taxCode: null }],
    });
    const machine = await lineOf(bill, 'Machine');
    // The product's default pre-fills it, as on an expense.
    await db.query(`update document_lines set product_id = $2 where id = $1`, [machine, product]);
    expect(await splitOfDocumentLine(machine)).toEqual([{ code: 'SITE1', percentage: '100.000', amount: '1200.00' }]);
    await db.query(`select post_document($1)`, [bill]);

    const rowsOf = await report(capex, '2026-09-01', '2026-09-30');
    const value = rowsOf.find((r) => r.code === 'SITE1')!;
    expect([Number(value.fixed_assets), Number(value.result)]).toEqual([1200, 0]);
    const total = rowsOf.find((r) => r.row_kind === 'total')!;
    expect(Number(total.fixed_assets)).toBe(1200);
  });

  it('while a tax account and a bank account stay refused, by name', async () => {
    const { entry } = await handEntry('2026-09-02', 10, taxAccount);
    const taxLine = await idOf(`select id from entry_lines where entry_id = $1 and sequence = 10`, [entry]);
    const bankLine = await idOf(`select id from entry_lines where entry_id = $1 and sequence = 20`, [entry]);
    for (const line of [taxLine, bankLine]) {
      expect(
        await expectError(db, `insert into entry_line_analytics (company_id, entry_line_id, analytic_value_id) values ($1, $2, $3)`, [
          companyId,
          line,
          v.other,
        ]),
      ).toMatch(/analytic_not_on_this_account/);
    }
    await db.query(`delete from entries where id = $1`, [entry]);
  });
});

describe('a tax nobody gets back in full', () => {
  it('lands on the expense lines it taxes, each share with the split of its lines', async () => {
    // Built here: 20 %, half of it recoverable on a tax account of the pack,
    // half a cost on the accounts of the lines (`tax_on_base`).
    const tax = await idOf(
      `insert into taxes (company_id, code, name, amount_type, amount, applies_to)
       values ($1, 'TEST-PARTIAL', 'Partly recoverable', 'percent', 20, 'purchase') returning id`,
      [companyId],
    );
    await db.query(
      `insert into tax_postings (tax_id, company_id, document_kind, posting_type, factor_percent, account_id, sequence)
       values ($1, $2, 'invoice', 'base', 100, null, 10),
              ($1, $2, 'invoice', 'tax', 50, account_id_by_code($2, $3), 20),
              ($1, $2, 'invoice', 'tax_on_base', 50, null, 30)`,
      [tax, companyId, taxAccount],
    );
    const bill = await newDocument(db, companyId, {
      docType: 'purchase_invoice',
      contactId: customer,
      date: '2026-10-01',
      lines: [
        { name: 'For P1', unitPrice: 600, accountCode: purchase, taxCode: 'TEST-PARTIAL' },
        { name: 'For Q', unitPrice: 400, accountCode: purchase, taxCode: 'TEST-PARTIAL' },
      ],
    });
    await splitLine(await lineOf(bill, 'For P1'), [[v.child1, 100]]);
    await splitLine(await lineOf(bill, 'For Q'), [[v.other, 100]]);
    await db.query(`select post_document($1)`, [bill]);

    const ledger = await rows<{ name: string; debit: string; posting_type: string; split: string | null }>(
      db,
      `select l.name, l.debit::text, l.posting_type::text,
              (select string_agg(v.code || '=' || x.amount, ',') from entry_line_analytics x
                 join analytic_values v on v.id = x.analytic_value_id
                where x.entry_line_id = l.id) as split
         from entry_lines l join documents d on d.entry_id = l.entry_id
        where d.id = $1 and l.debit > 0 order by l.sequence`,
      [bill],
    );
    expect(ledger.map((l) => [l.posting_type, Number(l.debit), l.split])).toEqual([
      ['base', 600, 'P1=600.00'],
      ['base', 400, 'Q=400.00'],
      ['tax', 100, null],
      ['tax_on_base', 60, 'P1=60.00'],
      ['tax_on_base', 40, 'Q=40.00'],
    ]);

    const october = await report(project, '2026-10-01', '2026-10-31');
    expect(october.filter((r) => r.row_kind === 'value').map((r) => [r.code, Number(r.expense)])).toEqual([
      ['P', 660],
      ['P1', 660],
      ['Q', 440],
    ]);
  });
});

describe('merge_contacts', () => {
  it('gives the kept contact the default of the absorbed one when it has none, and keeps its own otherwise', async () => {
    const keep = await newContact(db, companyId, { name: 'Kept', type: 'supplier', country });
    const absorb = await newContact(db, companyId, { name: 'Absorbed', type: 'supplier', country });
    await db.query(`update contacts set analytic_value_id = $2 where id = $1`, [absorb, v.child2]);
    const merged = await asUser(db, ownerId, () =>
      one<{ filled: string[] }>(db, `select (merge_contacts($1, $2)).filled`, [keep, absorb]),
    );
    expect(merged.filled).toContain('analytic_value_id');
    expect(await one(db, `select analytic_value_id from contacts where id = $1`, [keep])).toEqual({ analytic_value_id: v.child2 });

    const ownDefault = await newContact(db, companyId, { name: 'Kept with its own', type: 'supplier', country });
    await db.query(`update contacts set analytic_value_id = $2 where id = $1`, [ownDefault, v.child1]);
    const another = await newContact(db, companyId, { name: 'Absorbed too', type: 'supplier', country });
    await db.query(`update contacts set analytic_value_id = $2 where id = $1`, [another, v.other]);
    await asUser(db, ownerId, () => db.query(`select merge_contacts($1, $2)`, [ownDefault, another]));
    expect(await one(db, `select analytic_value_id from contacts where id = $1`, [ownDefault])).toEqual({
      analytic_value_id: v.child1,
    });
  });
});
