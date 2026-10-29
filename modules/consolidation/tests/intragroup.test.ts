import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from '../../../tests/helpers/db.js';
import { newCompany, newContact, newDocument } from '../../../tests/helpers/factory.js';
import { packWhere, roleOf } from '../../../tests/helpers/packs.js';

// What the companies of a group invoiced each other: a sale of one member to
// a contact that is another member, paired with the purchase that carries its
// number in the other's books. The pairs, and what does not pair, are listed;
// nothing is written and nothing is forced.

let db: PGlite;
let ownerId: string;
let parentId: string;
let subsidiaryId: string;
let lateId: string;
let groupId: string;
let sales: string;
let purchase: string;

/** A contact of `companyId` that is the company `of`, by its VAT number as given. */
let subsidiaryAsCustomer: string;
let parentAsSupplier: string;
let lateAsCustomer: string;
let parentAsSupplierOfLate: string;
let namesake: string;

interface Pair {
  seller_company_id: string;
  buyer_company_id: string;
  kind: string;
  reference: string;
  sale_document_id: string | null;
  sale_amount_total: string | null;
  purchase_document_id: string | null;
  purchase_amount_total: string | null;
  status: string;
}

const intragroup = (from: string, to: string): Promise<Pair[]> =>
  rows<Pair>(db, `select * from consolidation.intragroup_documents($1, $2, $3::date, $4::date)`, [
    parentId,
    groupId,
    from,
    to,
  ]);

/** A posted sale, and its number. */
async function sell(company: string, contact: string, amount: number, date: string): Promise<{ id: string; number: string }> {
  const id = await newDocument(db, company, {
    docType: 'sale_invoice',
    contactId: contact,
    date,
    lines: [{ name: 'Services', unitPrice: amount, accountCode: sales, taxCode: null }],
  });
  await db.query(`select post_document($1)`, [id]);
  return one<{ id: string; number: string }>(db, `select id, number from documents where id = $1`, [id]);
}

/** A posted purchase, carrying the seller's number as its supplier reference. */
async function buy(company: string, contact: string, amount: number, date: string, reference: string): Promise<string> {
  const id = await newDocument(db, company, {
    docType: 'purchase_invoice',
    contactId: contact,
    date,
    lines: [{ name: 'Services', unitPrice: amount, accountCode: purchase, taxCode: null }],
  });
  await db.query(`update documents set supplier_reference = $2 where id = $1`, [id, reference]);
  await db.query(`select post_document($1)`, [id]);
  return id;
}

beforeAll(async () => {
  const pack = packWhere('names a sales and a purchase account', (p) => {
    const roles = p.manifest.defaults.roles;
    return ['sales', 'purchase'].every((role) => typeof roles[role] === 'string');
  });
  const country = pack.manifest.country;
  sales = roleOf(pack, 'sales');
  purchase = roleOf(pack, 'purchase');

  db = await freshDatabase();
  ({ companyId: parentId, ownerId } = await newCompany(db, { country, name: 'Holding' }));
  ({ companyId: subsidiaryId } = await newCompany(db, { country, name: 'Subsidiary', ownerId }));
  ({ companyId: lateId } = await newCompany(db, { country, name: 'Late', ownerId }));

  // Fictitious numbers: what matters is that each company has its own.
  await db.query(`update companies set vat_number = $2, registration_number = $3 where id = $1`, [
    parentId,
    `${country}0100000001`,
    'REG-100',
  ]);
  await db.query(`update companies set vat_number = $2 where id = $1`, [subsidiaryId, `${country}0200000002`]);
  await db.query(`update companies set vat_number = $2 where id = $1`, [lateId, `${country}0300000003`]);

  // Written the way a person types it: spaces and dots are not the number.
  subsidiaryAsCustomer = await newContact(db, parentId, { name: 'Our subsidiary', country, vat: `${country} 0200.000.002` });
  parentAsSupplier = await newContact(db, subsidiaryId, { type: 'supplier', name: 'Our holding', country, vat: `${country}0100000001` });
  lateAsCustomer = await newContact(db, parentId, { name: 'Late company', country, vat: `${country}0300000003` });
  // Known by its registration number alone, in the same country.
  parentAsSupplierOfLate = await newContact(db, lateId, { type: 'supplier', name: 'The holding', country });
  await db.query(`update contacts set registration_number = 'reg 100' where id = $1`, [parentAsSupplierOfLate]);
  // The name of a company of the group, and neither of its numbers.
  namesake = await newContact(db, parentId, { name: 'Subsidiary', country });

  await asUser(db, ownerId, async () => {
    await db.query(`select enable_module($1, 'consolidation')`, [parentId]);
    groupId = (await one<{ id: string }>(db, `select id from consolidation.create_group($1, 'main', 'Main group')`, [parentId])).id;
    await db.query(`select consolidation.add_member($1, $2, $3, 'full', 100, date '2026-01-01')`, [
      parentId,
      groupId,
      subsidiaryId,
    ]);
    await db.query(`select consolidation.add_member($1, $2, $3, 'full', 60, date '2026-07-01')`, [
      parentId,
      groupId,
      lateId,
    ]);
  });
}, 180_000);

afterAll(async () => {
  await db.close();
});

describe('the parties of a group', () => {
  it('are the contacts whose VAT or registration number is another company of the group, never a name', async () => {
    await asUser(db, ownerId, async () => {
      const parties = await rows<{ contact_id: string; counterpart_company_id: string; recognised_by: string }>(
        db,
        `select contact_id, counterpart_company_id, recognised_by
           from consolidation.intragroup_parties($1, $2, date '2026-01-01', date '2026-12-31')`,
        [parentId, groupId],
      );
      const byContact = new Map(parties.map((p) => [p.contact_id, p]));
      expect(byContact.get(subsidiaryAsCustomer)).toMatchObject({ counterpart_company_id: subsidiaryId, recognised_by: 'vat_number' });
      expect(byContact.get(parentAsSupplier)).toMatchObject({ counterpart_company_id: parentId, recognised_by: 'vat_number' });
      expect(byContact.get(lateAsCustomer)).toMatchObject({ counterpart_company_id: lateId });
      expect(byContact.get(parentAsSupplierOfLate)).toMatchObject({
        counterpart_company_id: parentId,
        recognised_by: 'registration_number',
      });
      expect(byContact.has(namesake)).toBe(false);
      expect(parties).toHaveLength(4);
    });
  });

  it('leave out a company that is in the group only outside the period', async () => {
    await asUser(db, ownerId, async () => {
      const first = await rows<{ counterpart_company_id: string; company_id: string }>(
        db,
        `select company_id, counterpart_company_id
           from consolidation.intragroup_parties($1, $2, date '2026-01-01', date '2026-06-30')`,
        [parentId, groupId],
      );
      expect(first.some((p) => p.company_id === lateId || p.counterpart_company_id === lateId)).toBe(false);
    });
  });
});

describe('the documents between companies of a group', () => {
  let matched: { id: string; number: string };
  let differs: { id: string; number: string };
  let unanswered: { id: string; number: string };
  let straddles: { id: string; number: string };
  let beforeEntry: { id: string; number: string };
  let afterEntry: { id: string; number: string };
  let orphan: string;

  beforeAll(async () => {
    matched = await sell(parentId, subsidiaryAsCustomer, 1000, '2026-03-10');
    await buy(subsidiaryId, parentAsSupplier, 1000, '2026-03-12', matched.number);

    differs = await sell(parentId, subsidiaryAsCustomer, 500, '2026-04-10');
    await buy(subsidiaryId, parentAsSupplier, 450, '2026-04-11', differs.number);

    unanswered = await sell(parentId, subsidiaryAsCustomer, 300, '2026-05-10');

    // Booked by the buyer with the reference it was given, which no sale carries.
    orphan = await buy(subsidiaryId, parentAsSupplier, 200, '2026-05-20', 'NO-SUCH-NUMBER');

    straddles = await sell(parentId, subsidiaryAsCustomer, 700, '2026-06-29');
    // Lower case and without its separators: the same number all the same.
    await buy(subsidiaryId, parentAsSupplier, 700, '2026-07-02', straddles.number.toLowerCase().replace(/[^a-z0-9]/g, ''));

    // To a company before it entered the group, then after.
    beforeEntry = await sell(parentId, lateAsCustomer, 900, '2026-03-15');
    afterEntry = await sell(parentId, lateAsCustomer, 800, '2026-08-15');
    await buy(lateId, parentAsSupplierOfLate, 800, '2026-08-16', afterEntry.number);

    // To the namesake, which is nobody of the group.
    await sell(parentId, namesake, 650, '2026-03-20');
  }, 120_000);

  it('pair a sale with the purchase that carries its number, and say what does not pair', async () => {
    await asUser(db, ownerId, async () => {
      const year = await intragroup('2026-01-01', '2026-12-31');
      const of = (sale: string): Pair | undefined => year.find((p) => p.sale_document_id === sale);

      expect(of(matched.id)).toMatchObject({
        seller_company_id: parentId,
        buyer_company_id: subsidiaryId,
        kind: 'invoice',
        status: 'matched',
        sale_amount_total: '1000.00',
        purchase_amount_total: '1000.00',
      });
      expect(of(differs.id)).toMatchObject({ status: 'amount_differs', purchase_amount_total: '450.00' });
      expect(of(unanswered.id)).toMatchObject({ status: 'purchase_missing', purchase_document_id: null });
      expect(year.find((p) => p.purchase_document_id === orphan)).toMatchObject({
        status: 'sale_missing',
        sale_document_id: null,
        seller_company_id: parentId,
        buyer_company_id: subsidiaryId,
        reference: 'NO-SUCH-NUMBER',
      });
      expect(of(straddles.id)).toMatchObject({ status: 'matched' });
      expect(of(afterEntry.id)).toMatchObject({ buyer_company_id: lateId, status: 'matched' });
    });
  });

  it('leave out a document dated before the buyer entered the group, and one to a namesake', async () => {
    await asUser(db, ownerId, async () => {
      const year = await intragroup('2026-01-01', '2026-12-31');
      expect(year.some((p) => p.sale_document_id === beforeEntry.id)).toBe(false);
      expect(year.every((p) => p.sale_amount_total !== '650.00')).toBe(true);
      expect(year).toHaveLength(6);
    });
  });

  it('say when the two sides fall in different periods', async () => {
    await asUser(db, ownerId, async () => {
      const half = await intragroup('2026-01-01', '2026-06-30');
      expect(half.find((p) => p.sale_document_id === straddles.id)).toMatchObject({ status: 'period_differs' });
      expect(half.some((p) => p.buyer_company_id === lateId)).toBe(false);
      const second = await intragroup('2026-07-01', '2026-12-31');
      expect(second.find((p) => p.sale_document_id === straddles.id)).toMatchObject({ status: 'period_differs' });
    });
  });

  it('refuse a period that ends before it starts', async () => {
    await asUser(db, ownerId, async () => {
      expect(
        await expectError(db, `select * from consolidation.intragroup_documents($1, $2, date '2026-12-31', date '2026-01-01')`, [
          parentId,
          groupId,
        ]),
      ).toMatch(/^consolidation_invalid_period:/);
    });
  });
});

describe('who reads the documents of a group', () => {
  it('is refused, by name, when one company of the period is out of reach', async () => {
    const reader = crypto.randomUUID();
    await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'accountant')`, [
      parentId,
      reader,
    ]);
    await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'viewer')`, [
      subsidiaryId,
      reader,
    ]);
    await asUser(db, reader, async () => {
      const refused = await expectError(
        db,
        `select * from consolidation.intragroup_documents($1, $2, date '2026-01-01', date '2026-12-31')`,
        [parentId, groupId],
      );
      expect(refused).toMatch(/^consolidation_member_unreadable:/);
      expect(refused).toContain(lateId);
      // The first half, before the late company entered, is within reach.
      expect((await intragroup('2026-01-01', '2026-06-30')).length).toBeGreaterThan(0);
    });
  });

  it('is refused a group that is not the company’s', async () => {
    await asUser(db, ownerId, async () => {
      expect(
        await expectError(db, `select * from consolidation.intragroup_documents($1, $2, date '2026-01-01', date '2026-12-31')`, [
          parentId,
          crypto.randomUUID(),
        ]),
      ).toMatch(/^consolidation_group_not_found:/);
    });
  });
});
