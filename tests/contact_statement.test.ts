/**
 * `contact_statement()` — the statement of account of a contact.
 *
 * One company of any pack, its accounts taken by their role: a customer
 * invoiced before the period and paid in it, invoiced again in it, and a
 * second customer and a supplier beside it. What is asserted is what the
 * function owes any pack: the balance carried forward as its first row, the
 * posted lines of the contact's receivable and payable accounts and nothing
 * else, the running balance to the cent, the matching of each line as it
 * stands, the closing balance equal to what `aged_balance()` says the
 * contact owes, and the refusals by name.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, newUser, type Fixture } from './helpers/factory.js';
import { plainSale } from './helpers/integrity.js';
import { roleOf, somePack } from './helpers/packs.js';

let db: PGlite;
let fx: Fixture;
let customer: string;
let other: string;
let supplier: string;
let invoiced: number;

interface StatementRow {
  row_kind: string;
  entry_date: string;
  entry_number: string | null;
  entry_line_id: string | null;
  document_number: string | null;
  doc_type: string | null;
  account_code: string | null;
  debit: number;
  credit: number;
  running_balance: number;
  matched_amount: number | null;
  open_amount: number | null;
  matching_state: string | null;
}

async function statement(contact: string, from: string, to: string): Promise<StatementRow[]> {
  const found = await rows<Record<string, unknown>>(
    db,
    `select row_kind, entry_date::text, entry_number, entry_line_id, document_number, doc_type::text,
            account_code, debit::text, credit::text, running_balance::text,
            matched_amount::text, open_amount::text, matching_state
       from contact_statement($1, $2, $3::date, $4::date)`,
    [fx.companyId, contact, from, to],
  );
  const amount = (value: unknown): number | null => (value === null ? null : Number(value));
  return found.map((row) => ({
    ...(row as unknown as StatementRow),
    debit: Number(row['debit']),
    credit: Number(row['credit']),
    running_balance: Number(row['running_balance']),
    matched_amount: amount(row['matched_amount']),
    open_amount: amount(row['open_amount']),
  }));
}

/** A posted entry keyed by hand; each line is [role, debit, credit, contact]. Returns the line ids. */
async function book(date: string, lines: [string, number, number, string | null][], state = 'posted'): Promise<string[]> {
  const entry = await one<{ id: string }>(
    db,
    `insert into entries (company_id, journal_id, entry_date, description, state, currency_code)
     select c.id, c.miscellaneous_journal_id, $2::date, 'Statement', 'draft', c.currency_code
       from companies c where c.id = $1
     returning id`,
    [fx.companyId, date],
  );
  const ids: string[] = [];
  for (const [index, [role, debit, credit, contact]] of lines.entries()) {
    const line = await one<{ id: string }>(
      db,
      `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit, contact_id)
       values ($1, $2, account_id_by_code($2, $3), $4, 'Statement', $5, $6, $7) returning id`,
      [entry.id, fx.companyId, roleOf(somePack, role), (index + 1) * 10, debit, credit, contact],
    );
    ids.push(line.id);
  }
  if (state === 'posted') await db.query(`select post_entry($1)`, [entry.id]);
  return ids;
}

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db, { country: somePack.manifest.country, name: 'Statement Company' });
  const country = somePack.manifest.country;
  customer = await newContact(db, fx.companyId, { name: 'Customer One', country });
  other = await newContact(db, fx.companyId, { name: 'Customer Two', country });
  supplier = await newContact(db, fx.companyId, { name: 'Supplier One', type: 'supplier', country });

  // Before the period: 100 owed by the customer.
  const [early] = await book('2026-01-10', [
    ['receivable', 100, 0, customer],
    ['sales', 0, 100, customer],
  ]);
  // In it: an invoice of the customer, posted as a document, and the payment
  // of the first 100, matched against it.
  const sale = await plainSale(db, fx.companyId);
  const documentId = await newDocument(db, fx.companyId, {
    docType: 'sale_invoice',
    number: 'ST-1',
    contactId: customer,
    date: '2026-03-01',
    lines: [{ unitPrice: 200, taxCode: sale.taxCode, accountCode: sale.accountCode }],
  });
  await db.query(`select post_document($1)`, [documentId]);
  invoiced = Number(
    (await one<{ amount: string }>(db, `select amount_residual::text as amount from documents where id = $1`, [documentId]))
      .amount,
  );
  const [, paid] = await book('2026-03-20', [
    ['bank', 100, 0, customer],
    ['receivable', 0, 100, customer],
  ]);
  await db.query(`select reconcile($1, $2, null)`, [early, paid]);
  // Not the customer's: another customer, a draft, and a line after the period.
  await book('2026-03-25', [
    ['receivable', 40, 0, other],
    ['sales', 0, 40, other],
  ]);
  await book('2026-03-26', [
    ['receivable', 999, 0, customer],
    ['sales', 0, 999, customer],
  ], 'draft');
  await book('2026-04-15', [
    ['receivable', 30, 0, customer],
    ['sales', 0, 30, customer],
  ]);
  // A supplier: 80 owed to them before the period.
  await book('2026-01-20', [
    ['purchase', 80, 0, supplier],
    ['payable', 0, 80, supplier],
  ]);
}, 120_000);

afterAll(async () => {
  await db.close();
});

describe('contact_statement()', () => {
  it('opens on the balance carried forward, then runs through the lines of the period', async () => {
    const found = await statement(customer, '2026-02-01', '2026-03-31');

    expect(found.map((row) => row.row_kind)).toEqual(['opening', 'line', 'line']);
    expect(found[0]).toMatchObject({ entry_date: '2026-02-01', debit: 100, credit: 0, running_balance: 100 });
    expect(found[0]!.entry_line_id).toBeNull();

    const [, invoice, payment] = found;
    expect(invoice).toMatchObject({
      entry_date: '2026-03-01',
      document_number: 'ST-1',
      doc_type: 'sale_invoice',
      account_code: roleOf(somePack, 'receivable'),
      debit: invoiced,
      running_balance: 100 + invoiced,
      matching_state: 'open',
      matched_amount: 0,
      open_amount: invoiced,
    });
    expect(payment).toMatchObject({
      entry_date: '2026-03-20',
      document_number: null,
      credit: 100,
      running_balance: invoiced,
      matching_state: 'matched',
      open_amount: 0,
    });
    expect(payment!.entry_number).not.toBeNull();
  });

  it('leaves out the other side of each entry, the drafts and the other contacts', async () => {
    const found = await statement(customer, '2026-01-01', '2026-12-31');
    const receivable = roleOf(somePack, 'receivable');

    expect(found.filter((row) => row.row_kind === 'line').every((row) => row.account_code === receivable)).toBe(true);
    expect(found.some((row) => row.debit === 999 || row.debit === 40)).toBe(false);
    expect(found.at(-1)!.running_balance).toBeCloseTo(invoiced + 30, 2);
  });

  it('closes on what the aged balance says the contact owes', async () => {
    const found = await statement(customer, '2026-01-01', '2026-12-31');
    const aged = await one<{ total: string }>(
      db,
      `select total::text from aged_balance($1, '2026-12-31'::date, 'receivable') where contact_id = $2`,
      [fx.companyId, customer],
    );
    expect(found.at(-1)!.running_balance).toBeCloseTo(Number(aged.total), 2);
  });

  it('answers a period without a line with the balance carried forward alone', async () => {
    const found = await statement(customer, '2026-03-21', '2026-03-31');
    expect(found).toHaveLength(1);
    expect(found[0]).toMatchObject({ row_kind: 'opening', running_balance: invoiced });
  });

  it('reads what is owed to a supplier as a credit', async () => {
    const found = await statement(supplier, '2026-02-01', '2026-12-31');
    expect(found).toHaveLength(1);
    expect(found[0]).toMatchObject({ debit: 0, credit: 80, running_balance: -80 });
  });

  it('is read by a member of the company under its own rights', async () => {
    const found = await asUser(db, fx.ownerId, () =>
      rows<{ row_kind: string }>(db, `select row_kind from contact_statement($1, $2, '2026-01-01', '2026-12-31')`, [
        fx.companyId,
        customer,
      ]),
    );
    expect(found.length).toBeGreaterThan(1);
  });

  it('refuses by name', async () => {
    // Somebody outside the company does not see it; a member without the
    // right to read the ledger is told which right.
    const stranger = await newUser(db);
    expect(
      await asUser(db, stranger, () =>
        expectError(db, `select * from contact_statement($1, $2, '2026-01-01', '2026-12-31')`, [fx.companyId, customer]),
      ),
    ).toMatch(/^unknown_company:/);
    const member = await newUser(db);
    await db.query(
      `insert into company_members (company_id, user_id, role, capabilities_revoked)
       values ($1, $2, 'viewer', array['entries.read'])`,
      [fx.companyId, member],
    );
    expect(
      await asUser(db, member, () =>
        expectError(db, `select * from contact_statement($1, $2, '2026-01-01', '2026-12-31')`, [fx.companyId, customer]),
      ),
    ).toMatch(/^not_allowed: .*entries\.read/);

    const elsewhere = await newCompany(db, { country: somePack.manifest.country, name: 'Elsewhere' });
    const theirs = await newContact(db, elsewhere.companyId, { country: somePack.manifest.country });
    expect(
      await expectError(db, `select * from contact_statement($1, $2, '2026-01-01', '2026-12-31')`, [fx.companyId, theirs]),
    ).toMatch(/^unknown_contact:/);
    expect(
      await expectError(db, `select * from contact_statement($1, $2, '2026-12-31', '2026-01-01')`, [fx.companyId, customer]),
    ).toMatch(/^invalid_period:/);
    expect(
      await expectError(db, `select * from contact_statement($1, $2, '2026-01-01', '2026-12-31')`, [
        crypto.randomUUID(),
        customer,
      ]),
    ).toMatch(/^unknown_company:/);
  });
});
