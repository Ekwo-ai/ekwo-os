import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newDocument, type Fixture } from './helpers/factory.js';
import { newMember, plainSale } from './helpers/integrity.js';

// Decision 0075: the contacts of a company that are probably one party are
// proposed, with which one to keep, the score and the evidence. Nothing is
// written; merge_contacts() is the act.

let db: PGlite;
let fx: Fixture;
let other: Fixture;
let accountant: string;
let stranger: string;
let sale: { taxCode: string; accountCode: string };

interface Pair {
  keep_id: string;
  absorb_id: string;
  score: string;
  evidence: string;
  because: string;
}

interface ContactOptions {
  vat?: string;
  registration?: string;
  iban?: string;
  active?: boolean;
  companyId?: string;
}

async function contact(name: string, options: ContactOptions = {}): Promise<string> {
  return (
    await one<{ id: string }>(
      db,
      `insert into contacts (company_id, name, vat_number, registration_number, iban, active)
       values ($1, $2, $3, $4, $5, $6) returning id`,
      [
        options.companyId ?? fx.companyId,
        name,
        options.vat ?? null,
        options.registration ?? null,
        options.iban ?? null,
        options.active ?? true,
      ],
    )
  ).id;
}

async function suggestions(companyId = fx.companyId, who = accountant): Promise<Pair[]> {
  return asUser(db, who, () => rows<Pair>(db, `select * from suggest_duplicate_contacts($1)`, [companyId]));
}

/** The pair that joins `a` and `b`, whichever is kept, or undefined. */
async function pairOf(a: string, b: string, companyId = fx.companyId): Promise<Pair | undefined> {
  return (await suggestions(companyId)).find(
    (p) => (p.keep_id === a && p.absorb_id === b) || (p.keep_id === b && p.absorb_id === a),
  );
}

/** Every pair that names one of `ids`. */
async function pairsNaming(...ids: string[]): Promise<Pair[]> {
  return (await suggestions()).filter((p) => ids.includes(p.keep_id) || ids.includes(p.absorb_id));
}

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db);
  other = await newCompany(db, { name: 'Another Company' });
  accountant = await newMember(db, fx.companyId, 'accountant');
  stranger = await newMember(db, other.companyId, 'accountant');
  sale = await plainSale(db, fx.companyId);
}, 300_000);

afterAll(async () => {
  await db?.close();
});

// ---------------------------------------------------------------------------
// Each piece of evidence
// ---------------------------------------------------------------------------

describe('suggest_duplicate_contacts() proposes a pair', () => {
  it('on the same VAT number, written two ways', async () => {
    const a = await contact('Alderbrook Widgets', { vat: 'TEST-VAT-0001' });
    const b = await contact('Zenthor Trading', { vat: 'test vat 0001' });
    expect(await pairOf(a, b)).toMatchObject({ score: '1.000', evidence: 'vat_number' });
    expect((await pairOf(a, b))?.because).toMatch(/carry the VAT number TESTVAT0001/);
  });

  it('on the same registration number', async () => {
    const a = await contact('Ostrava Instruments', { registration: 'REG 77.12.34' });
    const b = await contact('Pellucid Optics', { registration: 'reg-771234' });
    expect(await pairOf(a, b)).toMatchObject({ score: '1.000', evidence: 'registration_number' });
  });

  it('on the same bank account, on the contact or in a learned motif', async () => {
    const a = await contact('Quintessa Tools', { iban: 'XX00 1111 2222 3333' });
    const b = await contact('Rhombic Supplies', { iban: 'xx0011112222 3333' });
    expect(await pairOf(a, b)).toMatchObject({ score: '1.000', evidence: 'account' });

    const c = await contact('Sorrelwick Freight');
    await db.query(
      `insert into contact_patterns (company_id, contact_id, kind, value, source)
       values ($1, $2, 'counterparty_account', 'XX00 1111 2222 3333', 'learned')`,
      [fx.companyId, c],
    );
    expect(await pairOf(a, c)).toMatchObject({ score: '1.000', evidence: 'account' });
    expect(await pairOf(b, c)).toMatchObject({ score: '1.000', evidence: 'account' });
  });

  it('on the same significant words of the name, in any order, scored as a name is scored', async () => {
    const a = await contact('Marlowe Janessa');
    const b = await contact('JANESSA, Marlowe');
    expect(await pairOf(a, b)).toMatchObject({ score: '0.900', evidence: 'name' });
    expect((await pairOf(a, b))?.because).toMatch(/carry the same words: janessa, marlowe/);

    const c = await contact('Thistlecombe Bakery');
    const d = await contact('thistlecombe bakery ');
    expect(await pairOf(c, d)).toMatchObject({ score: '0.950', evidence: 'name' });

    // The score is the one contact_candidates() gives a name, from one function.
    const scored = await one<{ score: string }>(
      db,
      `select name_agreement(a.name, significant_words(a.name, 4), b.name, significant_words(b.name, 4)) as score
         from contacts a, contacts b where a.id = $1 and b.id = $2`,
      [a, b],
    );
    expect(scored.score).toBe('0.900');
  });

  it('when every word of one name is in the other, and doubts it when the words reach several', async () => {
    const short = await contact('Quillfeather');
    const long = await contact('Quillfeather Holdings');
    expect(await pairOf(short, long)).toMatchObject({ score: '0.900', evidence: 'name' });
    expect((await pairOf(short, long))?.because).toMatch(/every word of Quillfeather is in Quillfeather Holdings/);

    const crowded = await contact('Brindlewood');
    const farms = await contact('Brindlewood Farms');
    const garage = await contact('Brindlewood Garage');
    expect(await pairOf(crowded, farms)).toMatchObject({ score: '0.600' });
    expect(await pairOf(crowded, garage)).toMatchObject({ score: '0.600' });
    expect((await pairOf(crowded, farms))?.because).toMatch(/in the names of 2 contacts/);
    // Two names that merely share a word are two parties.
    expect(await pairOf(farms, garage)).toBeUndefined();
  });

  it('never on a shared word alone, however common', async () => {
    const ids = [];
    for (const word of ['Copperfield', 'Dunmore', 'Everleigh', 'Foxhollow']) ids.push(await contact(`${word} Partnership`));
    expect(await pairsNaming(...ids)).toEqual([]);
  });

  it('says every kind of evidence, strongest first, once each', async () => {
    const a = await contact('Glimmerstone Labs', { vat: 'TEST-VAT-0099', iban: 'XX99 0000' });
    const b = await contact('Labs Glimmerstone', { vat: 'TESTVAT0099', iban: 'XX990000' });
    const pair = await pairOf(a, b);
    expect(pair).toMatchObject({ score: '1.000', evidence: 'vat_number,account,name' });
    expect(pair?.because.split('; ')).toHaveLength(3);
  });

  it('answers the strongest pairs first', async () => {
    const all = await suggestions();
    const scores = all.map((p) => Number(p.score));
    expect(scores).toEqual([...scores].sort((x, y) => y - x));
    expect(all.length).toBeGreaterThan(0);
  });
});

// ---------------------------------------------------------------------------
// Which one to keep
// ---------------------------------------------------------------------------

describe('the contact to keep', () => {
  it('is the one more ledger lines and documents name', async () => {
    const quiet = await contact('Harrowgate Mills');
    const busy = await contact('Mills Harrowgate');
    // The busy one is the newer: what the books name it by weighs first.
    await db.query(`update contacts set created_at = now() - interval '1 day' where id = $1`, [quiet]);
    await newDocument(db, fx.companyId, {
      docType: 'sale_invoice',
      contactId: busy,
      lines: [{ unitPrice: 40, taxCode: sale.taxCode, accountCode: sale.accountCode }],
    });
    expect(await pairOf(quiet, busy)).toMatchObject({ keep_id: busy, absorb_id: quiet });
  });

  it('is the older when the books name both alike', async () => {
    const newer = await contact('Inglenook Ceramics');
    const older = await contact('Ceramics Inglenook');
    await db.query(`update contacts set created_at = now() - interval '2 days' where id = $1`, [older]);
    expect(await pairOf(newer, older)).toMatchObject({ keep_id: older, absorb_id: newer });
  });
});

// ---------------------------------------------------------------------------
// What is never proposed
// ---------------------------------------------------------------------------

describe('what is never proposed', () => {
  it('an inactive contact', async () => {
    const a = await contact('Juniperhall Events');
    const b = await contact('Events Juniperhall', { active: false });
    expect(await pairsNaming(a, b)).toEqual([]);
  });

  it('two contacts with different VAT or registration numbers, which merge_contacts() would refuse', async () => {
    const a = await contact('Kestrelmoor Logistics', { vat: 'TEST-VAT-0201' });
    const b = await contact('Kestrelmoor Logistics', { vat: 'TEST-VAT-0202' });
    const c = await contact('Larkspur Interiors', { registration: 'R-1' });
    const d = await contact('Interiors Larkspur', { registration: 'R-2' });
    expect(await pairsNaming(a, b, c, d)).toEqual([]);
  });

  it('a contact and its own parent', async () => {
    const parent = await contact('Mirabelle Optics');
    const branch = await contact('Mirabelle Optics');
    await db.query(`update contacts set parent_id = $1 where id = $2`, [parent, branch]);
    expect(await pairsNaming(parent, branch)).toEqual([]);
  });

  it('a pair across two companies, and a company the caller is not in', async () => {
    const mine = await contact('Nettlebank Studio', { vat: 'TEST-VAT-0301' });
    const theirs = await contact('Nettlebank Studio', { vat: 'TEST-VAT-0301', companyId: other.companyId });
    const theirTwin = await contact('Studio Nettlebank', { companyId: other.companyId });
    expect(await pairsNaming(mine, theirs)).toEqual([]);

    // The other company sees its own pair, and nothing of this one.
    const theirPairs = await suggestions(other.companyId, stranger);
    expect(theirPairs.map((p) => [p.keep_id, p.absorb_id].sort())).toEqual([[theirs, theirTwin].sort()]);
    expect(await suggestions(fx.companyId, stranger)).toEqual([]);
    expect(await asUser(db, accountant, () => rows(db, `select * from suggest_duplicate_contacts($1)`, [other.companyId]))).toEqual([]);
  });

  it('a pair once it is merged, while the kept contact still pairs with a third', async () => {
    const a = await contact('Oakhurst Joinery');
    const b = await contact('Joinery Oakhurst');
    const c = await contact('Oakhurst Joinery Ltd', { vat: 'TEST-VAT-0401' });
    expect(await pairOf(a, b)).toBeDefined();
    const pair = await pairOf(a, b);
    await asUser(db, accountant, () => db.query(`select merge_contacts($1, $2)`, [pair?.keep_id, pair?.absorb_id]));

    expect(await pairOf(a, b)).toBeUndefined();
    expect(await pairsNaming(pair?.absorb_id ?? '')).toEqual([]);
    expect(await pairOf(pair?.keep_id ?? '', c)).toMatchObject({ evidence: 'name' });
  });
});

// ---------------------------------------------------------------------------
// Bounded
// ---------------------------------------------------------------------------

describe('at two thousand contacts', () => {
  it('answers well under eight seconds', async () => {
    const big = await newCompany(db, { name: 'Many Contacts' });
    // Names built the way imported books look: a distinctive word, often a
    // word shared by hundreds (a trade, a legal form), and some twins.
    await db.query(
      `insert into contacts (company_id, name, vat_number, iban)
       select $1::uuid,
              format('%s %s %s', 'party' || g, (array['trading', 'services', 'holdings', 'group'])[1 + g % 4],
                     case when g % 3 = 0 then 'limited' else '' end),
              case when g % 50 = 0 then 'TEST-VAT-' || g end,
              case when g % 70 = 0 then 'XX00' || g end
         from generate_series(1, 1900) g
       union all
       select $1::uuid, format('%s %s', (array['trading', 'services', 'holdings', 'group'])[1 + g % 4], 'party' || g), null, null
         from generate_series(1, 100) g`,
      [big.companyId],
    );
    expect(await one(db, `select count(*)::int as n from contacts where company_id = $1`, [big.companyId])).toEqual({ n: 2000 });

    const started = performance.now();
    const found = await rows<Pair>(db, `select * from suggest_duplicate_contacts($1)`, [big.companyId]);
    const elapsed = performance.now() - started;
    console.info(`suggest_duplicate_contacts: 2 000 contacts, ${found.length} pairs, ${Math.round(elapsed)} ms`);

    // Each of the hundred reversed names is the twin of one of the first.
    expect(found.filter((p) => p.evidence === 'name').length).toBeGreaterThanOrEqual(100);
    expect(elapsed).toBeLessThan(8000);
  }, 120_000);
});
