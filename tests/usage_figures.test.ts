/**
 * A company is counted, never read.
 *
 * `20261029040000` adds `usage_figures()`: for each company the caller is on,
 * one row per figure — a name, a number of rows, and when the most recent was
 * created. It counts what people make and leaves out what the country pack
 * lays down; it returns nothing but those four columns; it answers a member
 * and the holder of a key of the company, and nobody else. Modules are
 * counted by the same loop, without the socle naming one.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, newUser } from './helpers/factory.js';
import { packWhere, roleOf } from './helpers/packs.js';

interface Figure {
  company_id: string;
  figure: string;
  count: string;
  last_created_at: Date | null;
}

let db: PGlite;
let companyId: string;
let ownerId: string;
let otherCompanyId: string;
let otherOwnerId: string;
let saleAccount: string;

const figuresAs = (userId: string): Promise<Figure[]> =>
  asUser(db, userId, () => rows<Figure>(db, `select * from usage_figures()`));

const countOf = (figures: Figure[], company: string, name: string): number | undefined => {
  const found = figures.find((f) => f.company_id === company && f.figure === name);
  return found === undefined ? undefined : Number(found.count);
};

beforeAll(async () => {
  const pack = packWhere('has a sales account', (p) => typeof p.manifest.defaults.roles['sales'] === 'string');
  saleAccount = roleOf(pack, 'sales');
  db = await freshDatabase();
  ({ companyId, ownerId } = await newCompany(db, { country: pack.manifest.country, name: 'Counted' }));
  ({ companyId: otherCompanyId, ownerId: otherOwnerId } = await newCompany(db, {
    country: pack.manifest.country,
    name: 'Elsewhere',
  }));

  const customer = await newContact(db, companyId, { type: 'customer', country: pack.manifest.country });
  await newContact(db, companyId, { type: 'customer', country: pack.manifest.country });
  for (const number of ['DRAFT-1', 'DRAFT-2']) {
    await newDocument(db, companyId, {
      docType: 'sale_invoice',
      number,
      contactId: customer,
      lines: [{ name: 'Consulting', unitPrice: 1234.56, accountCode: saleAccount, taxCode: null }],
    });
  }
  await asUser(db, ownerId, () => db.query(`select enable_module($1, 'crm')`, [companyId]));
}, 180_000);

afterAll(async () => {
  await db.close();
});

describe('usage_figures()', () => {
  it('counts what people made in the company', async () => {
    const figures = await figuresAs(ownerId);
    expect(countOf(figures, companyId, 'contacts')).toBe(2);
    expect(countOf(figures, companyId, 'documents.sale_invoice.draft')).toBe(2);
    expect(countOf(figures, companyId, 'members')).toBe(1);
    expect(countOf(figures, companyId, 'fiscal_years')).toBe(1);
    expect(countOf(figures, companyId, 'bank_statements')).toBe(0);
    expect(countOf(figures, companyId, 'vat_schemes')).toBe(0);
    expect(countOf(figures, companyId, 'declaration_instalments')).toBe(0);
    const contacts = figures.find((f) => f.company_id === companyId && f.figure === 'contacts');
    expect(contacts?.last_created_at).toBeInstanceOf(Date);
  });

  it('leaves out what the country pack laid down', async () => {
    const names = (await figuresAs(ownerId)).map((f) => f.figure);
    for (const laidDown of ['accounts', 'taxes', 'tax_postings', 'journals']) {
      expect(names.filter((n) => n === laidDown || n.startsWith(`${laidDown}.`))).toEqual([]);
    }
  });

  it('returns a name, a count and a moment, and nothing of the books', async () => {
    const figures = await figuresAs(ownerId);
    for (const f of figures) expect(Object.keys(f).sort()).toEqual(['company_id', 'count', 'figure', 'last_created_at']);
    const text = JSON.stringify(figures);
    expect(text).not.toContain('Counted');
    expect(text).not.toContain('DRAFT-1');
    expect(text).not.toContain('1234.56');
    expect(text).not.toContain('Consulting');
  });

  it('counts an enabled module and every table of its schema that names a company', async () => {
    const figures = await figuresAs(ownerId);
    expect(countOf(figures, companyId, 'modules.crm')).toBe(1);
    const tables = await rows<{ relname: string }>(
      db,
      `select c.relname
         from pg_class c
         join pg_namespace n on n.oid = c.relnamespace
         join modules m on m.schema_name = n.nspname and m.code = 'crm'
        where c.relkind in ('r', 'p')
          and exists (select 1 from pg_attribute a where a.attrelid = c.oid and a.attname = 'company_id' and not a.attisdropped)
        order by 1`,
    );
    expect(tables.length).toBeGreaterThan(0);
    const counted = figures
      .filter((f) => f.company_id === companyId && f.figure.startsWith('crm.'))
      .map((f) => f.figure.slice('crm.'.length))
      .sort();
    expect(counted).toEqual(tables.map((t) => t.relname).sort());
    // A module nobody enabled is not counted.
    expect(figures.filter((f) => f.figure.startsWith('modules.') && f.figure !== 'modules.crm')).toEqual([]);
  });

  it('answers a member for the companies they are on, and nobody else', async () => {
    const mine = await figuresAs(ownerId);
    expect(new Set(mine.map((f) => f.company_id))).toEqual(new Set([companyId]));
    const theirs = await figuresAs(otherOwnerId);
    expect(new Set(theirs.map((f) => f.company_id))).toEqual(new Set([otherCompanyId]));
    const stranger = await newUser(db, 'stranger@counted.test');
    expect(await figuresAs(stranger)).toEqual([]);
  });

  it('answers the holder of a key of the company, whatever the key may read', async () => {
    const key = await asUser(db, ownerId, () =>
      one<{ secret: string }>(db, `select * from create_api_key($1, 'Host', '["documents.read"]'::jsonb, null)`, [
        companyId,
      ]),
    );
    await db.exec(`set role authenticated;`);
    await db.query(`begin`);
    let figures: Figure[];
    try {
      await db.query(`select * from use_api_key($1)`, [key.secret]);
      figures = await rows<Figure>(db, `select * from usage_figures()`);
    } finally {
      await db.query(`commit`);
      await db.exec(`reset role;`);
    }
    expect(new Set(figures.map((f) => f.company_id))).toEqual(new Set([companyId]));
    expect(countOf(figures, companyId, 'contacts')).toBe(2);
  });

  it('is refused to a caller who is not signed in', async () => {
    await db.exec(`set role anon;`);
    try {
      await expect(db.query(`select * from usage_figures()`)).rejects.toThrow(/permission denied/);
    } finally {
      await db.exec(`reset role;`);
    }
  });
});
