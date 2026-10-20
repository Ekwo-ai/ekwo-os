/**
 * A tax lands by its code, not on a line.
 *
 * `20261020210000` refuses a document line on an account that a tax of the
 * company lands on (`tax_postings`, posting_type = tax): the tax of a line is
 * its `tax_id`, and the posting writes the tax there. The caller is told which
 * taxes land on that account. A line with its tax on an expense account is
 * taken as it always was, and the posting still writes the tax on the tax
 * account. A document posted before the guard with such a line is still
 * undone by `cancel_document()`: its credit note copies the line.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, freshDatabase, one } from './helpers/db.js';
import { newCompany, newContact, newDocument, newUser } from './helpers/factory.js';
import { packWhere, roleOf } from './helpers/packs.js';

let db: PGlite;
let companyId: string;
let accountant: string;
let supplier: string;
let purchaseAccount: string;
let taxAccount: string;
let taxCode: string;

beforeAll(async () => {
  const pack = packWhere(
    'has a purchase account and a purchase tax that lands on an account',
    (p) => typeof p.manifest.defaults.roles['purchase'] === 'string' && p.taxes.some((t) => t.scope === 'purchase' && !t.cash_basis),
  );
  db = await freshDatabase();
  ({ companyId } = await newCompany(db, { country: pack.manifest.country, name: 'Taxed' }));
  accountant = await newUser(db, 'accountant@taxed.test');
  await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'accountant')`, [companyId, accountant]);
  supplier = await newContact(db, companyId, { type: 'supplier', country: pack.manifest.country });
  purchaseAccount = roleOf(pack, 'purchase');

  // A tax of a purchase invoice, and the account its posting lands on.
  const landing = await one<{ code: string; account: string }>(
    db,
    `select t.code, a.code as account
       from tax_postings p
       join taxes t on t.id = p.tax_id
       join accounts a on a.id = p.account_id
      where p.company_id = $1
        and p.posting_type = 'tax'
        and p.document_kind = 'invoice'
        and t.applies_to in ('purchase', 'both')
        and p.factor_percent > 0
      order by t.code
      limit 1`,
    [companyId],
  );
  taxCode = landing.code;
  taxAccount = landing.account;
}, 180_000);

afterAll(async () => {
  await db.close();
});

const refusalOf = async (work: () => Promise<unknown>): Promise<string> => {
  try {
    await work();
    return '';
  } catch (error) {
    return (error as Error).message;
  }
};

describe('a document line on a tax account', () => {
  it('is refused, and the taxes that land there are named', async () => {
    const refusal = await refusalOf(() =>
      newDocument(db, companyId, {
        docType: 'purchase_invoice',
        number: 'SUP-TAX-1',
        contactId: supplier,
        lines: [
          { name: 'Hosting', unitPrice: 100, accountCode: purchaseAccount, taxCode: null },
          { name: 'VAT on hosting', unitPrice: 21, accountCode: taxAccount, taxCode: null },
        ],
      }),
    );
    expect(refusal).toMatch(/^tax_account_on_a_line\b/);
    expect(refusal).toContain(taxAccount);
    expect(refusal).toContain(taxCode);
  });

  it('is refused when a line is moved there afterwards', async () => {
    const documentId = await newDocument(db, companyId, {
      docType: 'purchase_invoice',
      number: 'SUP-TAX-2',
      contactId: supplier,
      lines: [{ name: 'Hosting', unitPrice: 100, accountCode: purchaseAccount, taxCode }],
    });
    const refusal = await refusalOf(() =>
      db.query(
        `update document_lines set account_id = account_id_by_code($1, $2) where document_id = $3`,
        [companyId, taxAccount, documentId],
      ),
    );
    expect(refusal).toMatch(/^tax_account_on_a_line\b/);
  });
});

describe('a line with its tax on an expense account', () => {
  it('is taken, and the posting writes the tax on the tax account', async () => {
    const documentId = await newDocument(db, companyId, {
      docType: 'purchase_invoice',
      number: 'SUP-TAX-3',
      contactId: supplier,
      lines: [{ name: 'Hosting', unitPrice: 100, accountCode: purchaseAccount, taxCode }],
    });
    await asUser(db, accountant, () => db.query(`select post_document($1)`, [documentId]));
    const taxLine = await one<{ n: string }>(
      db,
      `select count(*)::text as n
         from documents d
         join entry_lines l on l.entry_id = d.entry_id
         join accounts a on a.id = l.account_id
        where d.id = $1 and a.code = $2`,
      [documentId, taxAccount],
    );
    expect(Number(taxLine.n)).toBeGreaterThan(0);
  });
});

describe('a document posted before the guard with such a line', () => {
  it('is still undone by cancel_document(), whose credit note copies the line', async () => {
    await db.exec(`alter table document_lines disable trigger document_lines_guard_tax_account`);
    let documentId: string;
    try {
      documentId = await newDocument(db, companyId, {
        docType: 'purchase_invoice',
        number: 'SUP-TAX-OLD',
        contactId: supplier,
        lines: [
          { name: 'Hosting', unitPrice: 100, accountCode: purchaseAccount, taxCode: null },
          { name: 'VAT on hosting', unitPrice: 21, accountCode: taxAccount, taxCode: null },
        ],
      });
    } finally {
      await db.exec(`alter table document_lines enable trigger document_lines_guard_tax_account`);
    }
    await asUser(db, accountant, () => db.query(`select post_document($1)`, [documentId]));

    const credited = await asUser(db, accountant, () =>
      one<{ id: string }>(db, `select id from cancel_document($1)`, [documentId]),
    );
    const copied = await one<{ n: string }>(
      db,
      `select count(*)::text as n
         from document_lines l
         join accounts a on a.id = l.account_id
        where l.document_id = $1 and a.code = $2`,
      [credited.id, taxAccount],
    );
    expect(Number(copied.n)).toBe(1);

    const cancelled = await one<{ state: string }>(db, `select state from documents where id = $1`, [documentId]);
    expect(cancelled.state).toBe('cancelled');
  });
});
