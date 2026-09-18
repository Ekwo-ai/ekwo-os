/**
 * A reference of the caller's own, and a rehearsal of posting.
 *
 * Both are claims about what the database does on its own, so both are
 * tested here against the schema and then through the functions of the core
 * that the MCP server and the command line share.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { readTools, writeTools, type Backend } from '../packages/mcp/src/index.js';
import { asUser, expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, newUser } from './helpers/factory.js';
import { roleOf, somePack } from './helpers/packs.js';
import { backendFor } from './mcp/helpers.js';

const HOME = somePack.manifest.country;
const SALES = roleOf(somePack, 'sales');

type Row = Record<string, unknown>;

let pg: PGlite;
let owner: string;
let companyId: string;
let otherCompanyId: string;
let contactId: string;
let backend: Backend;

/** Everything a posting touches, counted: what a rehearsal must leave as it found it. */
async function footprint(): Promise<Row> {
  return one<Row>(
    pg,
    `select (select count(*)::int from entries where company_id = $1) as entries,
            (select count(*)::int from entry_lines where company_id = $1) as lines,
            (select count(*)::int from audit_log where company_id = $1) as audited,
            (select coalesce(jsonb_agg(to_jsonb(s) order by s.journal_id, s.year), '[]'::jsonb)::text
               from journal_sequences s join journals j on j.id = s.journal_id where j.company_id = $1) as counters,
            (select jsonb_agg(jsonb_build_object('id', id, 'state', state, 'number', number, 'entry', entry_id) order by id)::text
               from documents where company_id = $1) as documents`,
    [companyId],
  );
}

beforeAll(async () => {
  pg = await freshDatabase();
  owner = await newUser(pg);
  companyId = (await newCompany(pg, { country: HOME, ownerId: owner })).companyId;
  otherCompanyId = (await newCompany(pg, { country: HOME, name: 'Another', ownerId: owner })).companyId;
  contactId = await newContact(pg, companyId, { name: 'Client Example' });
  backend = backendFor(pg, owner);
});

afterAll(async () => {
  await pg.close();
});

describe('client_ref', () => {
  it('is unique per company where it is given, and absent everywhere else', async () => {
    await pg.query(`insert into contacts (company_id, name, client_ref) values ($1, 'A', 'ref-1')`, [companyId]);
    const said = await expectError(pg, `insert into contacts (company_id, name, client_ref) values ($1, 'B', 'ref-1')`, [companyId]);
    expect(said).toContain('contacts_client_ref_key');
    // Another company may use the same reference, and any number of rows may give none.
    await pg.query(`insert into contacts (company_id, name, client_ref) values ($1, 'A', 'ref-1')`, [otherCompanyId]);
    await pg.query(`insert into contacts (company_id, name) values ($1, 'C'), ($1, 'D')`, [companyId]);
  });

  it('is refused blank or padded, so two spellings cannot be one reference', async () => {
    for (const bad of ['', ' ref', 'ref ']) {
      expect(await expectError(pg, `insert into contacts (company_id, name, client_ref) values ($1, 'E', $2)`, [companyId, bad])).toContain(
        'contacts_client_ref_not_blank',
      );
    }
  });

  it('makes a creation through the shared functions happen once — for the MCP server as for the command line', async () => {
    const args = {
      company_id: companyId,
      doc_type: 'sale_invoice' as const,
      contact_id: contactId,
      document_date: '2026-06-15',
      client_ref: 'order-1',
      lines: [{ name: 'Work', unit_price: '100.00', account_code: SALES }],
    };
    const first = (await writeTools.createDocument(backend, args)) as Row;
    const second = (await writeTools.createDocument(backend, args)) as Row;
    expect(first['replayed']).toBeUndefined();
    expect(second['replayed']).toBe(true);
    expect((second['document'] as Row)['id']).toBe((first['document'] as Row)['id']);
    expect((await one<{ n: number }>(pg, `select count(*)::int as n from documents where client_ref = 'order-1'`)).n).toBe(1);
    expect((await one<{ n: number }>(pg, `select count(*)::int as n from document_lines where document_id = $1`, [(first['document'] as Row)['id']])).n).toBe(1);
  });

  it('is guaranteed by the index and not by the lookup: a race loses to a constraint', async () => {
    // What the slower of two simultaneous callers meets: the lookup found
    // nothing for either, and the second insert is the one refused.
    const said = await asUser(pg, owner, () =>
      expectError(
        pg,
        `insert into documents (company_id, doc_type, contact_id, document_date, currency_code, client_ref)
         select $1, 'sale_invoice', $2, date '2026-06-15', currency_code, 'order-1' from companies where id = $1`,
        [companyId, contactId],
      ),
    );
    expect(said).toContain('documents_client_ref_key');
  });
});

describe('rehearse_post_document()', () => {
  let documentId: string;

  beforeAll(async () => {
    documentId = await newDocument(pg, companyId, {
      docType: 'sale_invoice',
      number: null as unknown as string,
      contactId,
      date: '2026-06-20',
      lines: [{ unitPrice: 250, accountCode: SALES, taxCode: null }],
    });
  });

  it('answers what posting would write and leaves no trace: no entry, no number burnt, no audit row', async () => {
    const before = await footprint();
    const rehearsed = (await asUser(pg, owner, () => one<{ r: Row }>(pg, `select rehearse_post_document($1) as r`, [documentId]))).r;
    expect(await footprint()).toEqual(before);

    const lines = rehearsed['entry_lines'] as Row[];
    expect(lines.length).toBeGreaterThanOrEqual(2);
    // Amounts are text, so no client ever meets them as a float.
    for (const line of lines) {
      expect(typeof line['debit']).toBe('string');
      expect(typeof line['credit']).toBe('string');
    }

    // Then the real thing writes exactly that, under exactly that number.
    const posted = (await writeTools.postDocument(backend, { document_id: documentId })) as { entry: Row };
    const written = await rows<Row>(
      pg,
      `select a.code as account_code, l.debit::text as debit, l.credit::text as credit
         from entry_lines l join accounts a on a.id = l.account_id where l.entry_id = $1 order by l.sequence`,
      [posted.entry['id']],
    );
    expect(lines.map((l) => ({ account_code: l['account_code'], debit: l['debit'], credit: l['credit'] }))).toEqual(written);
    expect((rehearsed['entry'] as Row)['number']).toBe(posted.entry['number']);
  });

  it('refuses what posting refuses, in the same words', async () => {
    const locked = await newDocument(pg, companyId, {
      docType: 'sale_invoice',
      number: null as unknown as string,
      contactId,
      date: '2026-03-15',
      lines: [{ unitPrice: 100, accountCode: SALES, taxCode: null }],
    });
    await pg.query(`update companies set lock_date = date '2026-03-31' where id = $1`, [companyId]);
    try {
      const real = await expectError(pg, 'select post_document($1)', [locked]);
      const rehearsal = await expectError(pg, 'select rehearse_post_document($1)', [locked]);
      expect(real).toMatch(/^period_locked:/);
      expect(rehearsal).toBe(real);
      await expect(writeTools.postDocument(backend, { document_id: locked, dry_run: true })).rejects.toThrow(/period_locked/);
    } finally {
      await pg.query(`update companies set lock_date = null where id = $1`, [companyId]);
    }
    // An already posted document is refused too, rather than rehearsed twice.
    expect(await expectError(pg, 'select rehearse_post_document($1)', [documentId])).toMatch(/^document_already_/);
  });

  it('gives nobody a way past a policy: a stranger rehearses nothing', async () => {
    const stranger = await newUser(pg);
    const draft = await newDocument(pg, companyId, {
      docType: 'sale_invoice',
      number: null as unknown as string,
      contactId,
      date: '2026-06-21',
      lines: [{ unitPrice: 10, accountCode: SALES, taxCode: null }],
    });
    const said = await asUser(pg, stranger, () => expectError(pg, 'select rehearse_post_document($1)', [draft]));
    expect(said).not.toMatch(/^$/);
    const listed = (await readTools.listDocuments(backendFor(pg, stranger), { company_id: companyId })) as { count: number };
    expect(listed.count).toBe(0);
  });
});
