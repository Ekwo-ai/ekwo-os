/**
 * The analytic split, from the line of a document to the result of an
 * activity (`supabase/migrations/20261019130000_an_analytic_value_is_entered_on_the_line.sql`,
 * decision 0075).
 *
 * What is guarded: a product and a contact pre-fill the split of a line at
 * 100 % on an axis the line leaves free, only on an account that carries a
 * split, and the person replaces what they pre-filled; the shares of one axis
 * stay within 100; a split on a receivable or a bank account is refused by
 * name, on a document line, on a ledger line, and when a line moves there; the amounts are the
 * database's, adding up to their line to the cent; `post_document()` writes a
 * ledger line per split and copies the split onto it, and nothing onto the
 * tax and the counterpart; an entry with no document is split on its own
 * lines; the split of a posted document is frozen; the credit note of a
 * cancelled invoice carries its split; and `analytic_report()` gives the
 * result of each value and of the unassigned part, which add up to the
 * income statement of the period, with its refusals by name. The answers of
 * 19/10/2026 — locks, the contact's parent, retired values, subtotals, a
 * required axis, fixed assets, a non-deductible tax — are in
 * `analytics-rules.test.ts`.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from './helpers/db.js';
import { accountId, newCompany, newContact, newDocument, newUser } from './helpers/factory.js';
import { packWhere, roleOf } from './helpers/packs.js';

let db: PGlite;
let companyId: string;
let ownerId: string;
let customer: string;
let supplier: string;
let sales: string;
let purchase: string;
let bank: string;
let receivable: string;
let saleTax: string | null;
let project: string;
let site: string;
const values = { alpha: '', beta: '', gamma: '', north: '' };
let hours: string;

interface Share {
  code: string;
  percentage: string;
  amount: string;
}

interface Row {
  row_kind: 'value' | 'unassigned' | 'total';
  analytic_value_id: string | null;
  code: string | null;
  name: string | null;
  income: string;
  expense: string;
  result: string;
}

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

const lineOf = async (documentId: string, name: string): Promise<string> =>
  (await one<{ id: string }>(db, `select id from document_lines where document_id = $1 and name = $2`, [documentId, name])).id;

async function split(lineId: string, shares: [string, number][]): Promise<void> {
  for (const [value, percentage] of shares) {
    await db.query(
      `insert into document_line_analytics (company_id, document_line_id, analytic_value_id, percentage)
       values ($1, $2, $3, $4)`,
      [companyId, lineId, value, percentage],
    );
  }
}

const report = (axis: string, from = '2026-01-01', to = '2026-12-31'): Promise<Row[]> =>
  rows<Row>(db, `select * from analytic_report($1, $2, $3::date, $4::date)`, [companyId, axis, from, to]);

/** The result of the period as the ledger gives it: income less expense, posted, closing left out. */
async function resultOfPeriod(from = '2026-01-01', to = '2026-12-31'): Promise<number> {
  const row = await one<{ result: string }>(
    db,
    `select coalesce(-sum(t.debit - t.credit), 0)::text as result
       from trial_balance($1, $2::date, $3::date) t
      where t.internal_group in ('income', 'expense')`,
    [companyId, from, to],
  );
  return Number(row.result);
}

beforeAll(async () => {
  const pack = packWhere('names a sales, a purchase, a bank and a receivable account', (p) => {
    const roles = p.manifest.defaults.roles;
    return ['sales', 'purchase', 'bank', 'receivable'].every((role) => typeof roles[role] === 'string');
  });
  db = await freshDatabase();
  ({ companyId, ownerId } = await newCompany(db, { country: pack.manifest.country, name: 'By activity' }));
  await db.query(`insert into auth.users (id, email) values ($1, 'owner@analytics.test') on conflict do nothing`, [ownerId]);
  customer = await newContact(db, companyId, { country: pack.manifest.country });
  supplier = await newContact(db, companyId, { type: 'supplier', name: 'A supplier', country: pack.manifest.country });
  sales = roleOf(pack, 'sales');
  purchase = roleOf(pack, 'purchase');
  bank = roleOf(pack, 'bank');
  receivable = roleOf(pack, 'receivable');
  // Any tax of the pack on sales, at a positive rate: which one is not the subject.
  saleTax =
    (
      await rows<{ code: string }>(
        db,
        `select t.code from taxes t
          where t.company_id = $1 and t.applies_to in ('sale', 'both') and t.amount_type = 'percent'
            and t.amount > 0 and t.active and t.valid_from <= '2026-01-01'
            and (t.valid_to is null or t.valid_to >= '2026-12-31')
            and t.applies_seller_territory is null and t.applies_buyer_territory is null
            and t.applies_supply_territory is null and t.applies_supply_vs_seller is null
            and not coalesce(t.cash_basis, false)
            and exists (select 1 from tax_postings p where p.tax_id = t.id and p.posting_type = 'tax')
            and not exists (select 1 from tax_postings p where p.tax_id = t.id and p.posting_type = 'tax_on_base')
          order by t.sequence, t.code limit 1`,
        [companyId],
      )
    )[0]?.code ?? null;

  project = (await one<{ id: string }>(db, `insert into analytic_axes (company_id, code, name) values ($1, 'PROJECT', 'Project') returning id`, [companyId])).id;
  site = (await one<{ id: string }>(db, `insert into analytic_axes (company_id, code, name) values ($1, 'SITE', 'Site') returning id`, [companyId])).id;
  for (const [key, axis, code] of [
    ['alpha', project, 'ALPHA'],
    ['beta', project, 'BETA'],
    ['gamma', project, 'GAMMA'],
    ['north', site, 'NORTH'],
  ] as const) {
    values[key] = (
      await one<{ id: string }>(
        db,
        `insert into analytic_values (company_id, axis_id, code, name) values ($1, $2, $3, $3) returning id`,
        [companyId, axis, code],
      )
    ).id;
  }
  hours = (
    await one<{ id: string }>(
      db,
      `insert into products (company_id, code, name, analytic_value_id) values ($1, 'HOURS', 'Consulting hours', $2) returning id`,
      [companyId, values.alpha],
    )
  ).id;
  await db.query(`update contacts set analytic_value_id = $2 where id = $1`, [supplier, values.north]);
}, 180_000);

afterAll(async () => {
  await db.close();
});

describe('the defaults of a line', () => {
  it('pre-fill the split from the product and the contact, at 100 % on each free axis', async () => {
    const bought = await newDocument(db, companyId, {
      docType: 'purchase_invoice',
      contactId: supplier,
      lines: [{ name: 'Hours bought', unitPrice: 100, accountCode: purchase, taxCode: null }],
    });
    const line = await lineOf(bought, 'Hours bought');
    await db.query(`update document_lines set product_id = $2 where id = $1`, [line, hours]);
    expect(await splitOfDocumentLine(line)).toEqual([
      { code: 'ALPHA', percentage: '100.000', amount: '100.00' },
      { code: 'NORTH', percentage: '100.000', amount: '100.00' },
    ]);
    await db.query(`delete from documents where id = $1`, [bought]);
  });

  it('never constrain the line: the person replaces what was pre-filled, and a second 100 % on the axis is refused', async () => {
    const sold = await newDocument(db, companyId, {
      docType: 'sale_invoice',
      contactId: customer,
      lines: [{ name: 'Hours sold', unitPrice: 200, accountCode: sales, taxCode: null }],
    });
    const line = await lineOf(sold, 'Hours sold');
    await db.query(`update document_lines set product_id = $2 where id = $1`, [line, hours]);
    expect((await splitOfDocumentLine(line)).map((s) => s.code)).toEqual(['ALPHA']);

    const message = await expectError(
      db,
      `insert into document_line_analytics (company_id, document_line_id, analytic_value_id) values ($1, $2, $3)`,
      [companyId, line, values.beta],
    );
    expect(message).toMatch(/analytic_split_over_100/);

    await db.query(`update document_line_analytics set percentage = 25 where document_line_id = $1`, [line]);
    await split(line, [[values.beta, 75]]);
    expect(await splitOfDocumentLine(line)).toEqual([
      { code: 'ALPHA', percentage: '25.000', amount: '50.00' },
      { code: 'BETA', percentage: '75.000', amount: '150.00' },
    ]);
    await db.query(`delete from documents where id = $1`, [sold]);
  });

  it('do not apply to a line on a balance-sheet account, and say nothing', async () => {
    const odd = await newDocument(db, companyId, {
      docType: 'purchase_invoice',
      contactId: supplier,
      lines: [{ name: 'Not a cost', unitPrice: 100, accountCode: bank, taxCode: null }],
    });
    const line = await lineOf(odd, 'Not a cost');
    await db.query(`update document_lines set product_id = $2 where id = $1`, [line, hours]);
    expect(await splitOfDocumentLine(line)).toEqual([]);
    await db.query(`delete from documents where id = $1`, [odd]);
  });
});

describe('a split on a third-party or a bank account', () => {
  it('is refused on a document line, by name', async () => {
    const odd = await newDocument(db, companyId, {
      docType: 'purchase_invoice',
      contactId: supplier,
      lines: [{ name: 'On the bank', unitPrice: 100, accountCode: bank, taxCode: null }],
    });
    const message = await expectError(
      db,
      `insert into document_line_analytics (company_id, document_line_id, analytic_value_id) values ($1, $2, $3)`,
      [companyId, await lineOf(odd, 'On the bank'), values.alpha],
    );
    expect(message).toMatch(/analytic_not_on_this_account/);
    await db.query(`delete from documents where id = $1`, [odd]);
  });

  it('is refused when a split line moves to such an account', async () => {
    const moving = await newDocument(db, companyId, {
      docType: 'purchase_invoice',
      contactId: customer,
      lines: [{ name: 'Moving', unitPrice: 100, accountCode: purchase, taxCode: null }],
    });
    const line = await lineOf(moving, 'Moving');
    await split(line, [[values.alpha, 100]]);
    const message = await expectError(db, `update document_lines set account_id = account_id_by_code($1, $2) where id = $3`, [
      companyId,
      bank,
      line,
    ]);
    expect(message).toMatch(/analytic_not_on_this_account/);
    await db.query(`delete from documents where id = $1`, [moving]);
  });

  it('is refused on a ledger line, by name', async () => {
    const entry = await handEntry('2026-02-01', 50);
    const counterpart = (
      await one<{ id: string }>(db, `select id from entry_lines where entry_id = $1 and credit > 0`, [entry])
    ).id;
    const message = await expectError(
      db,
      `insert into entry_line_analytics (company_id, entry_line_id, analytic_value_id) values ($1, $2, $3)`,
      [companyId, counterpart, values.alpha],
    );
    expect(message).toMatch(/analytic_not_on_this_account/);
    await db.query(`delete from entries where id = $1`, [entry]);
  });
});

/** A draft entry no document wrote: an expense against the bank, as a payroll or a rent would be. */
async function handEntry(date: string, amount: number): Promise<string> {
  const entry = await one<{ id: string }>(
    db,
    `insert into entries (company_id, journal_id, entry_date, description)
     select $1, miscellaneous_journal_id, $2::date, 'Salaries' from companies where id = $1 returning id`,
    [companyId, date],
  );
  await db.query(
    `insert into entry_lines (entry_id, company_id, account_id, sequence, debit, credit)
     values ($1, $2, account_id_by_code($2, $3), 10, $5, 0),
            ($1, $2, account_id_by_code($2, $4), 20, 0, $5)`,
    [entry.id, companyId, purchase, bank, amount],
  );
  return entry.id;
}

describe('posting', () => {
  let invoice: string;

  beforeAll(async () => {
    // Three lines on one account and one tax: split 60/40, all on one value,
    // and none. They were one ledger line; they are three.
    invoice = await newDocument(db, companyId, {
      docType: 'sale_invoice',
      contactId: customer,
      date: '2026-03-10',
      lines: [
        { name: 'Shared', unitPrice: 1000, accountCode: sales, taxCode: saleTax },
        { name: 'Beta only', unitPrice: 500, accountCode: sales, taxCode: saleTax },
        { name: 'Nobody', unitPrice: 300, accountCode: sales, taxCode: saleTax },
      ],
    });
    await split(await lineOf(invoice, 'Shared'), [
      [values.alpha, 60],
      [values.beta, 40],
    ]);
    await split(await lineOf(invoice, 'Beta only'), [[values.beta, 100]]);
    await db.query(`select post_document($1)`, [invoice]);
  });

  it('writes one ledger line per split and copies the split onto it', async () => {
    const lines = await rows<{ id: string; name: string; credit: string }>(
      db,
      `select l.id, l.name, l.credit::text from entry_lines l
         join documents d on d.entry_id = l.entry_id
         join accounts a on a.id = l.account_id
        where d.id = $1 and a.internal_group = 'income' order by l.sequence`,
      [invoice],
    );
    expect(lines.map((l) => [l.name, Number(l.credit)])).toEqual([
      ['Shared', 1000],
      ['Beta only', 500],
      ['Nobody', 300],
    ]);
    // A balance is debit minus credit: a share of a sale is negative.
    expect(await splitOfEntryLine(lines[0]!.id)).toEqual([
      { code: 'ALPHA', percentage: '60.000', amount: '-600.00' },
      { code: 'BETA', percentage: '40.000', amount: '-400.00' },
    ]);
    expect(await splitOfEntryLine(lines[1]!.id)).toEqual([{ code: 'BETA', percentage: '100.000', amount: '-500.00' }]);
    expect(await splitOfEntryLine(lines[2]!.id)).toEqual([]);
  });

  it('copies nothing onto the tax and the counterpart', async () => {
    const shared = await one<{ n: number }>(
      db,
      `select count(*)::int as n from entry_line_analytics x
         join entry_lines l on l.id = x.entry_line_id
         join documents d on d.entry_id = l.entry_id
         join accounts a on a.id = l.account_id
        where d.id = $1 and a.internal_group not in ('income', 'expense')`,
      [invoice],
    );
    expect(shared.n).toBe(0);
    const receivables = await one<{ n: number }>(
      db,
      `select count(*)::int as n from entry_lines l join documents d on d.entry_id = l.entry_id
        where d.id = $1 and l.account_id = account_id_by_code($2, $3)`,
      [invoice, companyId, receivable],
    );
    expect(receivables.n).toBeGreaterThan(0);
  });

  it('freezes the split of the posted document', async () => {
    const message = await expectError(db, `update document_line_analytics set percentage = 50 where document_line_id = $1`, [
      await lineOf(invoice, 'Beta only'),
    ]);
    expect(message).toMatch(/document_posted/);
  });

  it('splits an entry no document wrote on its own lines, the amounts adding up to the cent', async () => {
    const entry = await handEntry('2026-04-30', 100);
    const cost = (await one<{ id: string }>(db, `select id from entry_lines where entry_id = $1 and debit > 0`, [entry])).id;
    for (const [value, percentage] of [
      [values.alpha, 33.333],
      [values.beta, 33.333],
      [values.gamma, 33.334],
    ] as const) {
      // An amount given by the caller is not the one kept.
      await db.query(
        `insert into entry_line_analytics (company_id, entry_line_id, analytic_value_id, percentage, amount)
         values ($1, $2, $3, $4, 999)`,
        [companyId, cost, value, percentage],
      );
    }
    await db.query(`select post_entry($1)`, [entry]);
    const shares = await splitOfEntryLine(cost);
    expect(shares.map((s) => s.amount)).toEqual(['33.33', '33.34', '33.33']);
    expect(shares.reduce((sum, s) => sum + Number(s.amount), 0)).toBeCloseTo(100, 10);
  });

  it('gives the credit note of a cancelled invoice the split of the invoice', async () => {
    const cancelled = await newDocument(db, companyId, {
      docType: 'sale_invoice',
      contactId: customer,
      date: '2026-05-05',
      lines: [{ name: 'Cancelled', unitPrice: 250, accountCode: sales, taxCode: null }],
    });
    await split(await lineOf(cancelled, 'Cancelled'), [[values.gamma, 100]]);
    await db.query(`select post_document($1)`, [cancelled]);
    await asUser(db, ownerId, () => db.query(`select cancel_document($1)`, [cancelled]));
    const credit = (await one<{ id: string }>(db, `select id from documents where reversed_document_id = $1`, [cancelled])).id;
    expect(await splitOfDocumentLine(await lineOf(credit, 'Cancelled'))).toEqual([
      { code: 'GAMMA', percentage: '100.000', amount: '250.00' },
    ]);
    const onLedger = await rows<Share>(
      db,
      `select v.code, x.percentage::text, x.amount::text from entry_line_analytics x
         join analytic_values v on v.id = x.analytic_value_id
         join entry_lines l on l.id = x.entry_line_id
         join documents d on d.entry_id = l.entry_id
        where d.id = $1`,
      [credit],
    );
    expect(onLedger).toEqual([{ code: 'GAMMA', percentage: '100.000', amount: '250.00' }]);
  });
});

describe('analytic_report', () => {
  it('gives the result of each value, and the unassigned part, adding up to the income statement', async () => {
    const all = await report(project);
    const lines = all.filter((l) => l.row_kind !== 'total');
    const byCode = Object.fromEntries(lines.map((l) => [l.code ?? '(none)', [Number(l.income), Number(l.expense), Number(l.result)]]));
    expect(byCode).toEqual({
      ALPHA: [600, 33.33, 566.67],
      BETA: [900, 33.34, 866.66],
      // Sold for 250 and cancelled: nothing left.
      GAMMA: [0, 33.33, -33.33],
      '(none)': [300, 0, 300],
    });
    expect(lines.at(-1)?.row_kind).toBe('unassigned');
    expect(all.at(-1)?.row_kind).toBe('total');
    const total = lines.reduce((sum, l) => sum + Number(l.result), 0);
    expect(total).toBeCloseTo(await resultOfPeriod(), 10);
    expect(Number(all.at(-1)!.result)).toBeCloseTo(await resultOfPeriod(), 10);
  });

  it('reads every axis on its own: what one axis does not reach is unassigned on it', async () => {
    const lines = await report(site);
    expect(lines.map((l) => l.row_kind)).toEqual(['unassigned', 'total']);
    expect(Number(lines[0]!.result)).toBeCloseTo(await resultOfPeriod(), 10);
  });

  it('reads the period as asked', async () => {
    const march = await report(project, '2026-03-01', '2026-03-31');
    expect(march.map((l) => [l.row_kind, l.code, Number(l.result)])).toEqual([
      ['value', 'ALPHA', 600],
      ['value', 'BETA', 900],
      ['unassigned', null, 300],
      ['total', null, 1800],
    ]);
  });

  it('refuses a period that runs backwards, an axis of nobody, and a stranger, by name', async () => {
    expect(await expectError(db, `select * from analytic_report($1, $2, '2026-12-31', '2026-01-01')`, [companyId, project])).toMatch(
      /invalid_period/,
    );
    expect(
      await expectError(db, `select * from analytic_report($1, $2, '2026-01-01', '2026-12-31')`, [companyId, crypto.randomUUID()]),
    ).toMatch(/unknown_analytic_axis/);
    const stranger = await newUser(db, 'stranger@analytics.test');
    const message = await asUser(db, stranger, () =>
      expectError(db, `select * from analytic_report($1, $2, '2026-01-01', '2026-12-31')`, [companyId, project]),
    );
    expect(message).toMatch(/unknown_company/);
  });

  it('answers the owner as it answers the database', async () => {
    const asOwner = await asUser(db, ownerId, () => report(project));
    expect(asOwner).toEqual(await report(project));
  });
});
