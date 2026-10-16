/**
 * `product_report()`: what each product brought in and cost, read from the
 * documents (`supabase/migrations/20261016145816_product_report.sql`).
 *
 * What is guarded: a product named on the lines of posted invoices is
 * reported on each side with its documents counted, its quantity and its
 * untaxed amount in the company's currency; a credit note counts against
 * its invoice; a draft, a document outside the period and a line naming no
 * product say nothing; a retired product keeps reporting and says so; a
 * period that runs backwards is refused by name; and a stranger to the
 * company is told it does not exist for them rather than shown its lines.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, newUser } from './helpers/factory.js';
import { packWhere, roleOf } from './helpers/packs.js';

let db: PGlite;
let companyId: string;
let ownerId: string;
let customer: string;
let supplier: string;
const products = { hours: '', widgets: '' };

interface Line {
  product_id: string;
  code: string;
  name: string;
  kind: string;
  active: boolean;
  side: string;
  document_count: number;
  quantity: string;
  amount: string;
}

const report = (from = '2026-01-01', to = '2026-12-31', as?: string): Promise<Line[]> => {
  const read = (): Promise<Line[]> =>
    rows<Line>(db, `select * from product_report($1, $2::date, $3::date)`, [companyId, from, to]);
  return as === undefined ? read() : asUser(db, as, read);
};

/** Names a product on every line of a document. */
async function named(documentId: string, productId: string): Promise<void> {
  await db.query(`update document_lines set product_id = $2 where document_id = $1`, [documentId, productId]);
}

beforeAll(async () => {
  const pack = packWhere('names a sales and a purchase account', (p) => {
    const roles = p.manifest.defaults.roles;
    return typeof roles['sales'] === 'string' && typeof roles['purchase'] === 'string';
  });
  const sales = roleOf(pack, 'sales');
  const purchase = roleOf(pack, 'purchase');
  db = await freshDatabase();
  ({ companyId, ownerId } = await newCompany(db, { country: pack.manifest.country, name: 'Lines of service' }));
  await db.query(`insert into auth.users (id, email) values ($1, 'owner@products.test') on conflict do nothing`, [ownerId]);
  customer = await newContact(db, companyId, { country: pack.manifest.country });
  supplier = await newContact(db, companyId, { type: 'supplier', name: 'A supplier', country: pack.manifest.country });
  products.hours = (await one<{ id: string }>(db, `insert into products (company_id, code, name, kind) values ($1, 'HOURS', 'Consulting hours', 'service') returning id`, [companyId])).id;
  products.widgets = (await one<{ id: string }>(db, `insert into products (company_id, code, name, kind) values ($1, 'WIDGET', 'Widgets', 'goods') returning id`, [companyId])).id;

  // Sold: 10 hours at 100 and 4 widgets at 25 on one invoice, 5 hours at 100 on another.
  const first = await newDocument(db, companyId, {
    docType: 'sale_invoice',
    contactId: customer,
    date: '2026-03-10',
    lines: [
      { name: 'Hours', quantity: 10, unitPrice: 100, accountCode: sales },
      { name: 'Widgets', quantity: 4, unitPrice: 25, accountCode: sales },
      { name: 'Free text, no product', quantity: 1, unitPrice: 999, accountCode: sales },
    ],
  });
  await db.query(`update document_lines set product_id = $2 where document_id = $1 and name = 'Hours'`, [first, products.hours]);
  await db.query(`update document_lines set product_id = $2 where document_id = $1 and name = 'Widgets'`, [first, products.widgets]);
  const second = await newDocument(db, companyId, {
    docType: 'sale_invoice',
    contactId: customer,
    date: '2026-05-02',
    lines: [{ name: 'Hours', quantity: 5, unitPrice: 100, accountCode: sales }],
  });
  await named(second, products.hours);
  // Two hours given back on a credit note.
  const credit = await newDocument(db, companyId, {
    docType: 'sale_credit_note',
    contactId: customer,
    date: '2026-05-20',
    lines: [{ name: 'Hours', quantity: 2, unitPrice: 100, accountCode: sales }],
  });
  await named(credit, products.hours);
  // Bought: 20 widgets at 10.
  const bought = await newDocument(db, companyId, {
    docType: 'purchase_invoice',
    contactId: supplier,
    date: '2026-02-01',
    lines: [{ name: 'Widgets', quantity: 20, unitPrice: 10, accountCode: purchase }],
  });
  await named(bought, products.widgets);
  // A draft, and an invoice of the year before: neither is reported in 2026.
  const draft = await newDocument(db, companyId, {
    docType: 'sale_invoice',
    contactId: customer,
    date: '2026-06-01',
    lines: [{ name: 'Hours', quantity: 100, unitPrice: 100, accountCode: sales }],
  });
  await named(draft, products.hours);
  const before = await newDocument(db, companyId, {
    docType: 'sale_invoice',
    contactId: customer,
    date: '2025-12-15',
    lines: [{ name: 'Hours', quantity: 7, unitPrice: 100, accountCode: sales }],
  });
  await named(before, products.hours);
  await db.query(`insert into fiscal_years (company_id, name, start_date, end_date) values ($1, 'Before', '2025-01-01', '2025-12-31')`, [companyId]);
  for (const id of [first, second, credit, bought, before]) await db.query(`select post_document($1)`, [id]);
}, 180_000);

afterAll(async () => {
  await db.close();
});

describe('product_report', () => {
  it('reports each product on each side: documents, quantity and the untaxed amount, a credit note against its invoice', async () => {
    const lines = await report();
    expect(lines.map((line) => [line.side, line.code, line.document_count, Number(line.quantity), Number(line.amount)])).toEqual([
      ['purchase', 'WIDGET', 1, 20, 200],
      // 10 + 5 − 2 hours at 100.
      ['sale', 'HOURS', 3, 13, 1300],
      ['sale', 'WIDGET', 1, 4, 100],
    ]);
    const hours = lines.find((line) => line.code === 'HOURS');
    expect(hours?.name).toBe('Consulting hours');
    expect(hours?.kind).toBe('service');
    expect(hours?.active).toBe(true);
    expect(hours?.product_id).toBe(products.hours);
  });

  it('reads the period as asked: the year before holds its own invoice, a month holds its own lines', async () => {
    expect((await report('2025-01-01', '2025-12-31')).map((line) => [line.code, Number(line.quantity)])).toEqual([['HOURS', 7]]);
    expect((await report('2026-05-01', '2026-05-31')).map((line) => [line.code, Number(line.quantity), Number(line.amount)])).toEqual([['HOURS', 3, 300]]);
    expect(await report('2026-07-01', '2026-07-31')).toEqual([]);
  });

  it('keeps reporting a retired product, and says it is retired', async () => {
    await db.query(`update products set active = false where id = $1`, [products.widgets]);
    const widgets = (await report()).filter((line) => line.code === 'WIDGET');
    expect(widgets.map((line) => [line.side, line.active])).toEqual([
      ['purchase', false],
      ['sale', false],
    ]);
    await db.query(`update products set active = true where id = $1`, [products.widgets]);
  });

  it('refuses a period that runs backwards, by name', async () => {
    const message = await expectError(db, `select * from product_report($1, $2::date, $3::date)`, [companyId, '2026-12-31', '2026-01-01']);
    expect(message).toMatch(/invalid_period/);
  });

  it('answers the owner, and tells a stranger the company is not theirs to read', async () => {
    expect((await report('2026-01-01', '2026-12-31', ownerId)).length).toBe(3);
    const stranger = await newUser(db, 'stranger@products.test');
    // `rounding_of()` reads the company first, and a company the caller may not read does not exist for them.
    const message = await asUser(db, stranger, () =>
      expectError(db, `select * from product_report($1, $2::date, $3::date)`, [companyId, '2026-01-01', '2026-12-31']),
    );
    expect(message).toMatch(/unknown_company/);
  });
});
