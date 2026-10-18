/**
 * Naming the contact of a line that names nobody, through the tools.
 *
 * `suggest_line_contacts` and `set_line_contact` are a thin call on the schema
 * (decision 0070): the candidates come back under each line with its label,
 * side and amount, the naming answers with the line as it now stands, and a
 * refusal is the database's own sentence with the hint that says what to do.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { explain, readTools, writeTools, type Backend } from '../../packages/mcp/src/index.js';
import { freshDatabase, one } from '../helpers/db.js';
import { newCompany, newContact, newDocument, type Fixture } from '../helpers/factory.js';
import { roleOf, somePack } from '../helpers/packs.js';
import { backendFor, list, record } from './helpers.js';

const pack = somePack;
const SALES = roleOf(pack, 'sales');

let db: PGlite;
let fx: Fixture;
let backend: Backend;
let customer: string;
let yearStart: string;
let receivable: string;

/** A posted entry keyed by hand: 40 on the receivable account against sales, the receivable line naming nobody. */
async function anonymousLine(label: string): Promise<string> {
  const entry = await one<{ id: string }>(
    db,
    `insert into entries (company_id, journal_id, entry_date, state, currency_code)
     select c.id, c.miscellaneous_journal_id, $2::date, 'draft', c.currency_code from companies c where c.id = $1
     returning id`,
    [fx.companyId, yearStart],
  );
  const line = await one<{ id: string }>(
    db,
    `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit)
     values ($1, $2, $3, 10, $4, 40, 0) returning id`,
    [entry.id, fx.companyId, receivable, label],
  );
  await db.query(
    `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit)
     values ($1, $2, account_id_by_code($2, $3), 20, $4, 0, 40)`,
    [entry.id, fx.companyId, SALES, label],
  );
  await db.query(`select post_entry($1)`, [entry.id]);
  return line.id;
}

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db, { country: pack.manifest.country, name: 'Line tools' });
  backend = backendFor(db, fx.ownerId);
  customer = await newContact(db, fx.companyId, { country: pack.manifest.country, name: 'Northwind Traders' });
  yearStart = (await one<{ d: string }>(db, `select min(start_date)::text as d from fiscal_years where company_id = $1`, [fx.companyId])).d;
  const invoice = await newDocument(db, fx.companyId, {
    docType: 'sale_invoice',
    number: 'TOOLS-0001',
    contactId: customer,
    date: yearStart,
    lines: [{ unitPrice: 40, taxCode: null, accountCode: SALES }],
  });
  await writeTools.postDocument(backend, { document_id: invoice });
  receivable = (
    await one<{ account_id: string }>(
      db,
      `select l.account_id from entry_lines l join documents d on d.entry_id = l.entry_id
        where d.id = $1 and l.debit > 0 limit 1`,
      [invoice],
    )
  ).account_id;
}, 180_000);

afterAll(async () => {
  await db.close();
});

describe('suggest_line_contacts and set_line_contact', () => {
  it('lists the candidates under the line, then names it', async () => {
    const line = await anonymousLine('Invoice TOOLS-0001, imported');
    const answer = record(await readTools.suggestLineContacts(backend, { company_id: fx.companyId, line_ids: [line] }));
    expect(answer['count']).toBe(1);
    const [found] = list(answer['lines']);
    expect(found).toMatchObject({ line_id: line, label: 'Invoice TOOLS-0001, imported', side: 'debit', amount: '40.00' });
    const [best] = list(found?.['candidates']);
    expect(best).toMatchObject({ contact_id: customer, name: 'Northwind Traders', method: 'document', alternatives: 1 });

    const named = record(await writeTools.setLineContact(backend, { line_id: line, contact_id: customer }));
    expect(record(named['entry_line'])).toMatchObject({ id: line, contact_id: customer, debit: '40.00' });
  });

  it('answers a second naming with the refusal and its hint', async () => {
    const line = await anonymousLine('Northwind Traders, March');
    await writeTools.setLineContact(backend, { line_id: line, contact_id: customer });
    const refusal = await writeTools.setLineContact(backend, { line_id: line, contact_id: customer }).then(
      () => undefined,
      (error: Error) => explain(error.message),
    );
    expect(refusal?.message).toMatch(/^line_has_contact\b/);
    expect(refusal?.hint).toMatch(/reversing the entry/);
  });
});
