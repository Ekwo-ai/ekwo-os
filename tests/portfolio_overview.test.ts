import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, newInstanceAdmin, newUser } from './helpers/factory.js';
import type { Pack } from '../packages/cli/src/index.js';
import { allPacks } from './helpers/packs.js';

/**
 * What customers and suppliers owe past their date, across the portfolio.
 *
 * `portfolio_overview(on)` is `aged_balance()` asked of every company the
 * caller may read the ledger of, for both groups, one row per company. What
 * is proved, as the people concerned and under row level security:
 *
 *   1. the portfolio is the companies the caller holds `entries.read` on, and
 *      nothing else — the accountant of two gets two, the client of one gets
 *      one, the stranger and the administrator of the instance get none;
 *   2. it is `entries.read` that decides, not membership;
 *   3. its figures are the ageing's, summed: open is the total, overdue the
 *      buckets after the due date, over ninety days the last bucket, and a
 *      party is late once however many invoices it owes;
 *   4. a company with nothing open is a row of zeros, never left out;
 *   5. each row carries its company's currency.
 */

interface Line {
  tax: string;
  account: string;
}

/** The first line of a golden document of this type that names a tax and an account. */
function lineOf(pack: Pack, type: string): Line | null {
  for (const document of pack.golden?.documents ?? []) {
    if (document.type !== type) continue;
    for (const line of document.lines) {
      if (line.tax && line.account) return { tax: line.tax, account: line.account };
    }
  }
  return null;
}

/** A pack whose golden books a sale and a purchase, so both sides can be owed. */
const both = allPacks.filter((p) => lineOf(p, 'sale_invoice') !== null && lineOf(p, 'purchase_invoice') !== null);
const main = both[0]!;
// A second pack, in another currency where the packs allow it.
const other = both.find((p) => p.slug !== main.slug && p.manifest.currency !== main.manifest.currency)
  ?? both.find((p) => p.slug !== main.slug)!;

const ON = '2026-09-30';

interface Overview {
  company_id: string;
  company_name: string;
  currency_code: string;
  customers_open: string;
  customers_overdue: string;
  customers_overdue_over_90: string;
  customers_late: number;
  suppliers_open: string;
  suppliers_overdue: string;
  suppliers_overdue_over_90: string;
  suppliers_late: number;
}

interface Aged {
  contact_id: string | null;
  not_due: string | null;
  days_1_30: string | null;
  days_31_60: string | null;
  days_61_90: string | null;
  days_over_90: string | null;
  total: string | null;
}

const n = (value: string | null | undefined): number => Number(value ?? 0);

let db: PGlite;
let accountantId: string;
let clientId: string;
let strangerId: string;
let adminId: string;
let busyCo: string;
let quietCo: string;
let unkeptCo: string;

const NAMES = { busy: 'Atelier Halvard', quiet: 'Comptoir Merrin', unkept: 'Forge Oswin' };

async function overviewAs(userId: string, on = ON): Promise<Overview[]> {
  return asUser(db, userId, () => rows<Overview>(db, `select * from portfolio_overview($1::date)`, [on]));
}

async function book(
  companyId: string,
  pack: Pack,
  type: 'sale_invoice' | 'purchase_invoice',
  contactId: string,
  date: string,
  dueDate: string,
): Promise<void> {
  const line = lineOf(pack, type)!;
  const documentId = await newDocument(db, companyId, {
    docType: type,
    contactId,
    date,
    dueDate,
    lines: [{ unitPrice: 1_000, taxCode: line.tax, accountCode: line.account }],
  });
  await db.query(`select post_document($1)`, [documentId]);
}

beforeAll(async () => {
  db = await freshDatabase();
  accountantId = await newUser(db);
  clientId = await newUser(db);
  strangerId = await newUser(db);
  adminId = await newInstanceAdmin(db);

  // country-literal: two packs picked by what their golden books, the second
  // in another currency where one exists.
  busyCo = (await newCompany(db, { country: main.manifest.country, name: NAMES.busy, chart: main.golden?.chart ?? null })).companyId;
  quietCo = (await newCompany(db, { country: other.manifest.country, name: NAMES.quiet, chart: other.golden?.chart ?? null })).companyId;
  unkeptCo = (await newCompany(db, { country: main.manifest.country, name: NAMES.unkept, chart: main.golden?.chart ?? null })).companyId;

  for (const companyId of [busyCo, quietCo]) {
    await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'accountant')`, [
      companyId,
      accountantId,
    ]);
  }
  await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'client')`, [
    busyCo,
    clientId,
  ]);

  const country = main.manifest.country;
  const early = await newContact(db, busyCo, { name: 'Early Customer', country });
  const late = await newContact(db, busyCo, { name: 'Late Customer', country });
  const supplier = await newContact(db, busyCo, { name: 'Late Supplier', type: 'supplier', country });

  // Late Customer owes two invoices past their date — one by ten days, one
  // by more than ninety — and Early Customer one that is not due yet.
  await book(busyCo, main, 'sale_invoice', late, '2026-08-01', '2026-09-20');
  await book(busyCo, main, 'sale_invoice', late, '2026-05-01', '2026-06-01');
  await book(busyCo, main, 'sale_invoice', early, '2026-09-15', '2026-10-15');
  // The company owes one supplier, by forty days.
  await book(busyCo, main, 'purchase_invoice', supplier, '2026-07-01', '2026-08-21');
  // The company nobody here keeps owes too: it must not leak.
  const elsewhere = await newContact(db, unkeptCo, { name: 'Elsewhere', country });
  await book(unkeptCo, main, 'sale_invoice', elsewhere, '2026-05-01', '2026-06-01');
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('the portfolio of the overview', () => {
  it('gives the accountant of two companies exactly those two, once each', async () => {
    const overview = await overviewAs(accountantId);
    expect(overview.map((o) => o.company_id).sort()).toEqual([busyCo, quietCo].sort());
    expect(overview.map((o) => o.company_name)).not.toContain(NAMES.unkept);
  });

  it('gives the client of one company that company', async () => {
    const overview = await overviewAs(clientId);
    expect(overview.map((o) => o.company_id)).toEqual([busyCo]);
  });

  it('gives nobody else anything, the administrator of the instance included', async () => {
    expect(await overviewAs(strangerId)).toEqual([]);
    expect(await overviewAs(adminId)).toEqual([]);
  });

  it('follows entries.read, not membership', async () => {
    await db.query(
      `update company_members set capabilities_revoked = array['entries.read']
        where company_id = $1 and user_id = $2`,
      [quietCo, accountantId],
    );
    try {
      expect((await overviewAs(accountantId)).map((o) => o.company_id)).toEqual([busyCo]);
    } finally {
      await db.query(
        `update company_members set capabilities_revoked = '{}'
          where company_id = $1 and user_id = $2`,
        [quietCo, accountantId],
      );
    }
  });

  it('refuses a missing day by name', async () => {
    await expect(
      asUser(db, accountantId, () => db.query(`select * from portfolio_overview(null)`)),
    ).rejects.toThrow(/invalid_date/);
  });
});

describe('the figures of the overview', () => {
  it('are the ageing of each company, summed, for both sides', async () => {
    const overview = await overviewAs(accountantId);
    for (const row of overview) {
      for (const [group, prefix] of [
        ['receivable', 'customers'],
        ['payable', 'suppliers'],
      ] as const) {
        const aged = await asUser(db, accountantId, () =>
          rows<Aged>(db, `select * from aged_balance($1, $2::date, $3)`, [row.company_id, ON, group]),
        );
        const overdue = (a: Aged) => n(a.days_1_30) + n(a.days_31_60) + n(a.days_61_90) + n(a.days_over_90);
        const sum = (f: (a: Aged) => number) => aged.reduce((s, a) => s + f(a), 0);
        expect(n(row[`${prefix}_open`]), `${row.company_name} ${group} open`).toBeCloseTo(sum((a) => n(a.total)), 6);
        expect(n(row[`${prefix}_overdue`]), `${row.company_name} ${group} overdue`).toBeCloseTo(sum(overdue), 6);
        expect(n(row[`${prefix}_overdue_over_90`]), `${row.company_name} ${group} over 90`).toBeCloseTo(
          sum((a) => n(a.days_over_90)),
          6,
        );
        const late = new Set(aged.filter((a) => overdue(a) > 0).map((a) => a.contact_id ?? 'nobody'));
        expect(row[`${prefix}_late`], `${row.company_name} ${group} late`).toBe(late.size);
      }
    }
  });

  it('counts a customer late once, however many invoices it owes', async () => {
    const busy = (await overviewAs(accountantId)).find((o) => o.company_id === busyCo)!;
    expect(busy.customers_late).toBe(1);
    expect(n(busy.customers_overdue)).toBeGreaterThan(0);
    expect(n(busy.customers_overdue_over_90)).toBeGreaterThan(0);
    expect(n(busy.customers_overdue_over_90)).toBeLessThan(n(busy.customers_overdue));
    // The invoice not yet due is open, and not overdue.
    expect(n(busy.customers_open)).toBeGreaterThan(n(busy.customers_overdue));
    expect(busy.suppliers_late).toBe(1);
    expect(n(busy.suppliers_overdue)).toBeGreaterThan(0);
    expect(n(busy.suppliers_overdue_over_90)).toBe(0);
    expect(n(busy.suppliers_open)).toBeCloseTo(n(busy.suppliers_overdue), 6);
  });

  it('reads the day it is given: before the first due date, nothing is overdue', async () => {
    const busy = (await overviewAs(accountantId, '2026-05-31')).find((o) => o.company_id === busyCo)!;
    expect(n(busy.customers_open)).toBeGreaterThan(0);
    expect(n(busy.customers_overdue)).toBe(0);
    expect(busy.customers_late).toBe(0);
    expect(n(busy.suppliers_open)).toBe(0);
  });

  it('lists a company with nothing open as a row of zeros', async () => {
    const quiet = (await overviewAs(accountantId)).find((o) => o.company_id === quietCo)!;
    expect(quiet).toBeDefined();
    for (const column of [
      'customers_open',
      'customers_overdue',
      'customers_overdue_over_90',
      'suppliers_open',
      'suppliers_overdue',
      'suppliers_overdue_over_90',
    ] as const) {
      expect(n(quiet[column]), column).toBe(0);
    }
    expect(quiet.customers_late).toBe(0);
    expect(quiet.suppliers_late).toBe(0);
  });

  it('carries the currency each company keeps its books in', async () => {
    const overview = await overviewAs(accountantId);
    for (const row of overview) {
      const company = await one<{ currency_code: string }>(db, `select currency_code from companies where id = $1`, [
        row.company_id,
      ]);
      expect(row.currency_code).toBe(company.currency_code);
    }
  });
});
