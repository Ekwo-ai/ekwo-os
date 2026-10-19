import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, type Fixture } from './helpers/factory.js';
import { newMember, plainSale } from './helpers/integrity.js';

// Decision 0075: the pairs of contacts that are probably one party are found,
// with their evidence, and the contact more rows name is proposed to keep.
// Nothing is merged: merge_contacts() does that once a person has chosen.

let db: PGlite;
let fx: Fixture;
let other: Fixture;
let accountant: string;
let stranger: string;
let sale: { taxCode: string; accountCode: string };

interface Pair {
  keep_id: string;
  keep_name: string;
  absorb_id: string;
  absorb_name: string;
  score: string;
  method: string;
  because: string;
  evidence: string[];
  keep_rows: number;
  absorb_rows: number;
}

async function pairs(companyId = fx.companyId, who = accountant): Promise<Pair[]> {
  return asUser(db, who, () => rows<Pair>(db, `select * from suggest_contact_duplicates($1)`, [companyId]));
}

/** The pair of these two contacts, in whichever order it was proposed. */
async function pairOf(a: string, b: string, companyId = fx.companyId, who = accountant): Promise<Pair | undefined> {
  return (await pairs(companyId, who)).find(
    (p) => (p.keep_id === a && p.absorb_id === b) || (p.keep_id === b && p.absorb_id === a),
  );
}

async function contactWith(fields: { name: string; vat?: string; registration?: string; iban?: string }, companyId = fx.companyId): Promise<string> {
  const id = await newContact(db, companyId, { name: fields.name, vat: fields.vat ?? null });
  await db.query(`update contacts set registration_number = $2, iban = $3 where id = $1`, [
    id,
    fields.registration ?? null,
    fields.iban ?? null,
  ]);
  return id;
}

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db);
  other = await newCompany(db, { name: 'Another Company' });
  accountant = await newMember(db, fx.companyId, 'accountant');
  stranger = await newMember(db, other.companyId, 'accountant');
  sale = await plainSale(db, fx.companyId);
}, 180_000);

afterAll(async () => {
  await db.close();
});

describe('suggest_contact_duplicates', () => {
  it('finds the same words in another order, once per pair', async () => {
    const first = await contactWith({ name: 'Marlow Jane' });
    const second = await contactWith({ name: 'Jane Marlow' });

    const found = (await pairs()).filter((p) => [first, second].includes(p.keep_id));
    expect(found).toHaveLength(1);
    expect(found[0]).toMatchObject({ score: '0.900', method: 'name', evidence: ['name'] });
    expect(found[0]?.because).toMatch(/same words in another order/);
  });

  it('finds the same name, letter for letter, above a name inside another', async () => {
    const first = await contactWith({ name: 'Quillon Studio' });
    const second = await contactWith({ name: 'quillon studio ' });
    const longer = await contactWith({ name: 'Quillon Studio Holdings' });

    expect(await pairOf(first, second)).toMatchObject({ score: '0.950', method: 'name' });
    expect((await pairOf(first, longer))?.because).toMatch(/every word of Quillon Studio is in Quillon Studio Holdings/);
    expect(await pairOf(first, longer)).toMatchObject({ score: '0.900' });
  });

  it('finds an identifier both carry, whatever their names, and says every kind of evidence', async () => {
    const byVat = await contactWith({ name: 'Northwind Trading', vat: 'TEST-VAT-0101' });
    const byVatToo = await contactWith({ name: 'NW Commerce', vat: 'test vat 0101' });
    const byRegistration = await contactWith({ name: 'Brightwater Mills', registration: 'REG-7781' });
    const byRegistrationToo = await contactWith({ name: 'Mills of Brightwater', registration: 'reg 7781' });
    const byAccount = await contactWith({ name: 'Copperfield Supplies', iban: 'XX00 TEST 0000 0042' });
    const byAccountToo = await contactWith({ name: 'C. Supplies', iban: 'xx00test00000042' });

    expect(await pairOf(byVat, byVatToo)).toMatchObject({ score: '1.000', method: 'vat_number', evidence: ['vat_number'] });
    // Two names of the same words and one number: the number speaks first.
    expect(await pairOf(byRegistration, byRegistrationToo)).toMatchObject({
      score: '1.000',
      method: 'registration_number',
      evidence: ['registration_number', 'name'],
    });
    expect(await pairOf(byAccount, byAccountToo)).toMatchObject({ score: '1.000', method: 'account' });
  });

  it('does not propose two numbers, which are two parties, nor a word in common', async () => {
    const one_ = await contactWith({ name: 'Harbor Freight Partners', vat: 'TEST-VAT-0201' });
    const two = await contactWith({ name: 'Harbor Freight Partners', vat: 'TEST-VAT-0202' });
    const three = await contactWith({ name: 'Harbor Bakery' });
    const four = await contactWith({ name: 'Elmstead Registry', registration: 'REG-1' });
    const five = await contactWith({ name: 'Elmstead Registry', registration: 'REG-2' });

    expect(await pairOf(one_, two)).toBeUndefined();
    expect(await pairOf(one_, three)).toBeUndefined();
    expect(await pairOf(two, three)).toBeUndefined();
    expect(await pairOf(four, five)).toBeUndefined();
  });

  it('proposes to keep the contact more rows name, and the older one on a tie', async () => {
    const older = await contactWith({ name: 'Delacroix Paints' });
    const named = await contactWith({ name: 'Paints Delacroix' });
    expect(await pairOf(older, named)).toMatchObject({ keep_id: older, absorb_id: named, keep_rows: 0, absorb_rows: 0 });

    const invoice = await newDocument(db, fx.companyId, {
      docType: 'sale_invoice',
      contactId: named,
      lines: [{ unitPrice: 100, taxCode: sale.taxCode, accountCode: sale.accountCode }],
    });
    await db.query(`select post_document($1)`, [invoice]);

    const pair = await pairOf(older, named);
    expect(pair).toMatchObject({ keep_id: named, keep_name: 'Paints Delacroix', absorb_id: older, absorb_rows: 0 });
    // The document and its line on the receivable account.
    expect(pair?.keep_rows).toBeGreaterThanOrEqual(2);
  });

  it('no longer proposes a pair once it is merged, nor an inactive contact', async () => {
    const keep = await contactWith({ name: 'Ashgrove Dental' });
    const absorb = await contactWith({ name: 'Dental Ashgrove' });
    const retired = await contactWith({ name: 'Ashgrove Dental' });
    await db.query(`update contacts set active = false where id = $1`, [retired]);
    expect(await pairOf(keep, absorb)).toBeDefined();
    expect(await pairOf(keep, retired)).toBeUndefined();

    await asUser(db, accountant, () => db.query(`select merge_contacts($1, $2)`, [keep, absorb]));
    expect(await pairOf(keep, absorb)).toBeUndefined();
  });

  it('stays inside one company, and answers nothing to somebody outside it', async () => {
    const here = await contactWith({ name: 'Wexford Tiles' });
    const there = await contactWith({ name: 'Wexford Tiles' }, other.companyId);
    const all = [...(await pairs()), ...(await pairs(other.companyId, stranger))];
    expect(all.some((p) => [p.keep_id, p.absorb_id].includes(here) && [p.keep_id, p.absorb_id].includes(there))).toBe(false);

    await contactWith({ name: 'Tiles Wexford' });
    expect((await pairs()).length).toBeGreaterThan(0);
    expect(await pairs(fx.companyId, stranger)).toEqual([]);
  });

  it('writes nothing', async () => {
    const before = await one<{ n: string }>(db, `select count(*) as n from contacts where company_id = $1 and active`, [fx.companyId]);
    await pairs();
    const after = await one<{ n: string }>(db, `select count(*) as n from contacts where company_id = $1 and active`, [fx.companyId]);
    expect(after.n).toBe(before.n);
  });
});
