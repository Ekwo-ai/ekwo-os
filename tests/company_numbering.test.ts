/**
 * A company numbers its documents its own way: its pattern before the pack's,
 * a prefix per journal before the journal's code, and one series that goes on
 * across a change of either.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, numberFormatOf } from './helpers/factory.js';

let db: PGlite;

beforeAll(async () => {
  db = await freshDatabase();
});

afterAll(async () => {
  await db.close();
});

async function company(name: string): Promise<{ companyId: string; contactId: string }> {
  const { companyId } = await newCompany(db, { name });
  const contactId = await newContact(db, companyId, { name: 'Client' });
  return { companyId, contactId };
}

/** Posts a sale invoice and answers the number its entry drew. */
async function postSale(companyId: string, contactId: string, date = '2026-06-15'): Promise<string> {
  const doc = await newDocument(db, companyId, {
    docType: 'sale_invoice',
    contactId,
    date,
    lines: [{ unitPrice: 100, taxCode: 'BE-S-21', accountCode: '704000' }],
  });
  await db.query(`select post_document($1)`, [doc]);
  const entry = await one<{ number: string }>(db, `select number from entries where document_id = $1`, [doc]);
  return entry.number;
}

async function salesJournal(companyId: string): Promise<string> {
  const row = await one<{ id: string }>(db, `select id from journals where company_id = $1 and code = 'SAL'`, [
    companyId,
  ]);
  return row.id;
}

describe('the company pattern and the journal prefix', () => {
  it('number a document where they are set, and the pack where they are not', async () => {
    const { companyId, contactId } = await company('Facturation SRL');
    const pack = await numberFormatOf(db, companyId);

    await db.query(`update companies set number_format = '{CODE}-{YYYY}-{NNNNNN}' where id = $1`, [companyId]);
    await db.query(`update journals set number_prefix = 'FAC' where company_id = $1 and code = 'SAL'`, [companyId]);
    expect(await postSale(companyId, contactId)).toBe('FAC-2026-000001');

    // The code of the journal is untouched: the pack and the exports still know it.
    const journal = await one<{ code: string }>(db, `select code from journals where id = $1`, [
      await salesJournal(companyId),
    ]);
    expect(journal.code).toBe('SAL');

    await db.query(`update companies set number_format = null where id = $1`, [companyId]);
    expect(await numberFormatOf(db, companyId)).toBe(pack);
  });

  it('refuses a pattern without the journal in it', async () => {
    const { companyId } = await company('Sans code SRL');
    const message = await expectError(db, `update companies set number_format = 'F-{YYYY}-{NNNN}' where id = $1`, [
      companyId,
    ]);
    expect(message).toMatch(/number_format_without_code/);
  });

  it('refuses a pattern that cannot number, by the name format_number() gives it', async () => {
    const { companyId } = await company('Sans compteur SRL');
    expect(
      await expectError(db, `update companies set number_format = '{CODE}-{YYYY}' where id = $1`, [companyId]),
    ).toMatch(/number_format_without_counter/);
    expect(
      await expectError(db, `update companies set number_format = '{CODE}-{QUARTER}-{NNNN}' where id = $1`, [
        companyId,
      ]),
    ).toMatch(/unknown_number_token/);
    expect(await expectError(db, `update companies set number_format = '  ' where id = $1`, [companyId])).toMatch(
      /companies_number_format_not_blank/,
    );
  });

  it('refuses a prefix another journal already prints, its prefix or its code', async () => {
    const { companyId } = await company('Prefixes SRL');
    expect(
      await expectError(db, `update journals set number_prefix = 'PUR' where company_id = $1 and code = 'SAL'`, [
        companyId,
      ]),
    ).toMatch(/number_prefix_taken: journal PUR/);

    await db.query(`update journals set number_prefix = 'FAC' where company_id = $1 and code = 'SAL'`, [companyId]);
    expect(
      await expectError(db, `update journals set number_prefix = 'FAC' where company_id = $1 and code = 'PUR'`, [
        companyId,
      ]),
    ).toMatch(/number_prefix_taken: journal SAL/);
  });

  it('refuses a prefix with braces, blanks around it, or longer than twenty characters', async () => {
    const { companyId } = await company('Forme SRL');
    for (const prefix of ['{X}', ' FAC', 'F'.repeat(21), '']) {
      expect(
        await expectError(db, `update journals set number_prefix = $2 where company_id = $1 and code = 'SAL'`, [
          companyId,
          prefix,
        ]),
      ).toMatch(/journals_number_prefix_shape/);
    }
  });
});

describe('a change on the way', () => {
  it('keeps one series across a prefix, a width, a year dropped and a year taken back', async () => {
    const { companyId, contactId } = await company('En cours de route SRL');
    await db.query(`update companies set number_format = '{CODE}/{YYYY}/{NNNN}' where id = $1`, [companyId]);
    expect(await postSale(companyId, contactId)).toBe('SAL/2026/0001');
    expect(await postSale(companyId, contactId)).toBe('SAL/2026/0002');

    // A new prefix and a wider counter: the same counter goes on.
    await db.query(`update journals set number_prefix = 'FAC' where company_id = $1 and code = 'SAL'`, [companyId]);
    await db.query(`update companies set number_format = '{CODE}/{YYYY}/{NNNNNN}' where id = $1`, [companyId]);
    expect(await postSale(companyId, contactId)).toBe('FAC/2026/000003');

    // The year dropped: one series, from the last number of the year.
    await db.query(`update companies set number_format = '{CODE}-{NNNNNN}' where id = $1`, [companyId]);
    expect(await postSale(companyId, contactId)).toBe('FAC-000004');

    // The year taken back: this year goes on from the single series.
    await db.query(`update companies set number_format = '{CODE}-{YYYY}-{NNNN}' where id = $1`, [companyId]);
    expect(await postSale(companyId, contactId)).toBe('FAC-2026-0005');

    const numbers = await rows<{ number: string }>(
      db,
      `select e.number from entries e join journals j on j.id = e.journal_id
        where e.company_id = $1 and j.code = 'SAL' order by e.number`,
      [companyId],
    );
    expect(new Set(numbers.map((row) => row.number)).size).toBe(5);
  });

  it('starts the years after the change at 1, the year in the number keeping them apart', async () => {
    const { companyId, contactId } = await company('Annee suivante SRL');
    await db.query(`update companies set number_format = '{CODE}-{NNNN}' where id = $1`, [companyId]);
    expect(await postSale(companyId, contactId)).toBe('SAL-0001');
    expect(await postSale(companyId, contactId)).toBe('SAL-0002');

    await db.query(`update companies set number_format = '{CODE}-{YYYY}-{NNNN}' where id = $1`, [companyId]);
    expect(await postSale(companyId, contactId)).toBe('SAL-2026-0003');

    await db.query(
      `insert into fiscal_years (company_id, name, start_date, end_date)
       values ($1, 'Exercice 2027', date '2027-01-01', date '2027-12-31')`,
      [companyId],
    );
    expect(await postSale(companyId, contactId, '2027-01-15')).toBe('SAL-2027-0001');
  });

  it('gives the last number back when its document returns to draft, under the new prefix', async () => {
    const { companyId, contactId } = await company('Retour brouillon SRL');
    await db.query(`update journals set number_prefix = 'FAC' where company_id = $1 and code = 'SAL'`, [companyId]);
    const doc = await newDocument(db, companyId, {
      docType: 'sale_invoice',
      contactId,
      date: '2026-06-15',
      lines: [{ unitPrice: 100, taxCode: 'BE-S-21', accountCode: '704000' }],
    });
    await db.query(`select post_document($1)`, [doc]);
    // The country's word, given in this database only: the test states the policy.
    const policy = await one<{ posted_edit_policy: string | null }>(
      db,
      `select posted_edit_policy from country_defaults where country = (select fiscal_country from companies where id = $1)`,
      [companyId],
    );
    await db.query(
      `update country_defaults set posted_edit_policy = 'unpost_if_untouched'
        where country = (select fiscal_country from companies where id = $1)`,
      [companyId],
    );
    try {
      await db.query(`select unpost_document($1)`, [doc]);
    } finally {
      await db.query(
        `update country_defaults set posted_edit_policy = $2
          where country = (select fiscal_country from companies where id = $1)`,
        [companyId, policy.posted_edit_policy],
      );
    }

    const unposting = await one<{ number_returned: boolean }>(
      db,
      `select number_returned from document_unpostings where document_id = $1`,
      [doc],
    );
    expect(unposting.number_returned).toBe(true);
    await db.query(`select post_document($1)`, [doc]);
    const entry = await one<{ number: string }>(db, `select number from entries where document_id = $1`, [doc]);
    expect(entry.number).toMatch(/^FAC.*0*1$/);
  });
});
