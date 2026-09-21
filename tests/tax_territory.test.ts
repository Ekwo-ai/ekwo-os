import { cp, mkdtemp, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import {
  packsDir,
  readPack,
  readTerritories,
  territoryWithin,
  territoryWithinForTax,
  type Pack,
  type PackTax,
  type Territory,
} from '../packages/cli/src/index.js';
import { expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument } from './helpers/factory.js';
import { allPacks, packWhere, packsRoot } from './helpers/packs.js';

/**
 * A tax follows the territory of the parties.
 *
 * Two packs stopped at the same wall from opposite sides and
 * `docs/international.md` records both: a pack keyed on a country cannot carry
 * the taxes of a territory inside it without offering them to everybody, and a
 * pack of a country whose states each levy their own tax offers every company
 * every state's codes, because `jurisdiction` is a label nothing reads. What
 * closes both is one thing — a tax names a territory, a party records the one
 * it is in, and the engine compares them.
 *
 * Five groups:
 *
 *   1. `territory_within()` and the reader that has no database answer the same
 *      thing about every pair of rows in the table;
 *   2. `document_territory()` climbs the ladder it documents — the column, then
 *      the delivery address of EN 16931, then the buyer — and knows that a
 *      purchase invoice is somebody else's sale;
 *   3. `post_document()` refuses a tax the document contradicts, by name, and
 *      books the same document unchanged where it does not;
 *   4. every territory any pack names is a row of the reference table;
 *   5. a territory the common system reaches for goods alone is expressible:
 *      a tax applying there is inside the system for a supply of goods and
 *      outside it for a supply of services, which is the Protocol on
 *      Ireland/Northern Ireland written as a check rather than as a README.
 *
 * Almost nothing below names a country. The pack under test is the one that
 * carries the property — `packWhere` — and the codes come out of it; the one
 * territory named in full is read out of the reference table by the property
 * that makes it the case at all.
 */

/**
 * The pack that conditions its sales on two different places of supply — one
 * territory's tax and another's. A pack whose sales all name the same place
 * proves the refusal and not the acceptance beside it.
 */
const territorial: Pack = packWhere('sales conditioned on two territories of supply', (pack) =>
  new Set(
    pack.taxes
      .filter((tax) => tax.scope === 'sale' && tax.applies_supply_territory !== null)
      .map((tax) => tax.applies_supply_territory),
  ).size >= 2,
);

/** A taxed sale that has to be delivered in one territory. */
const homeSale: PackTax = territorial.taxes.find(
  (tax) => tax.scope === 'sale' && tax.rate > 0 && tax.applies_supply_territory !== null,
) as PackTax;

/** A sale of the same pack that has to be delivered in a different one. */
const awaySale: PackTax = territorial.taxes.find(
  (tax) =>
    tax.scope === 'sale' &&
    tax.applies_supply_territory !== null &&
    tax.applies_supply_territory !== homeSale.applies_supply_territory,
) as PackTax;

const home = homeSale.applies_supply_territory as string;
const away = awaySale.applies_supply_territory as string;

/** An account of the pack's own chart, and a date its own year is open on. */
const account = territorial.golden?.documents[0]?.lines[0]?.account as string;
const day = territorial.golden?.documents[0]?.date as string;
const year = territorial.golden?.fiscalYear as { name: string; start: string; end: string };

describe('a territory lies inside another', () => {
  let db: PGlite;
  let territories: Territory[];

  beforeAll(async () => {
    db = await freshDatabase({ modules: false });
    territories = await readTerritories(repoRootOfPacks());
  }, 300_000);

  afterAll(async () => {
    await db.close();
  });

  // The transcription held against the function, over the whole table — what
  // `tests/vat_codes.test.ts` already does for `eu_vat_scope_of()`, and for the
  // same reason: two readings of one rule drift the moment nobody compares them.
  it('answers the same in SQL and in the reader that has no database', async () => {
    const pairs = await rows<{ inside: string; outside: string }>(
      db,
      `select a.code as inside, b.code as outside
         from territories a cross join territories b
        where territory_within(a.code, b.code)
        order by 1, 2`,
    );
    const transcribed: string[] = [];
    for (const a of territories) {
      for (const b of territories) {
        if (territoryWithin(a.code, b.code, territories)) transcribed.push(`${a.code} ${b.code}`);
      }
    }
    expect(pairs.map((pair) => `${pair.inside} ${pair.outside}`)).toEqual(transcribed.sort());
  });

  // The same comparison for the reading a tax uses, which stops where the
  // parent's tax does.
  it('answers the same in SQL and in the reader that has no database, for a tax', async () => {
    const pairs = await rows<{ inside: string; outside: string }>(
      db,
      `select a.code as inside, b.code as outside
         from territories a cross join territories b
        where territory_within_for_tax(a.code, b.code)
        order by 1, 2`,
    );
    const transcribed: string[] = [];
    for (const a of territories) {
      for (const b of territories) {
        if (territoryWithinForTax(a.code, b.code, territories)) transcribed.push(`${a.code} ${b.code}`);
      }
    }
    expect(pairs.map((pair) => `${pair.inside} ${pair.outside}`)).toEqual(transcribed.sort());
  });

  it('holds a territory outside its parent for the tax, and inside it for everything else', async () => {
    const outside = territories.filter((territory) => territory.outside_parent_tax);
    expect(outside.length).toBeGreaterThan(0);
    for (const territory of outside) {
      const row = await one<{ geography: boolean; tax: boolean; itself: boolean }>(
        db,
        `select territory_within($1, $2)         as geography,
                territory_within_for_tax($1, $2) as tax,
                territory_within_for_tax($1, $1) as itself`,
        [territory.code, territory.parent_code],
      );
      expect(row).toEqual({ geography: true, tax: false, itself: true });
    }
  });

  it('refuses a territory outside its parent that has no parent', async () => {
    const orphan = territories.find((territory) => territory.parent_code === null) as Territory;
    const message = await expectError(
      db,
      `update territories set outside_parent_tax = true where code = $1`,
      [orphan.code],
    );
    expect(message).toContain('territories_outside_parent_tax_has_parent');
  });

  it('holds every territory inside itself and inside its parent, and never the other way round', async () => {
    for (const territory of territories) {
      const self = await one<{ within: boolean }>(db, `select territory_within($1, $1) as within`, [
        territory.code,
      ]);
      expect(self.within).toBe(true);
      if (territory.parent_code === null) continue;
      const row = await one<{ up: boolean; down: boolean }>(
        db,
        `select territory_within($1, $2) as up, territory_within($2, $1) as down`,
        [territory.code, territory.parent_code],
      );
      expect(row.up).toBe(true);
      expect(row.down).toBe(false);
    }
  });

  it('holds nothing inside a territory the table does not carry', async () => {
    // Two letters ISO 3166 never assigns, so nothing real is shadowed.
    const row = await one<{ a: boolean; b: boolean }>(
      db,
      `select territory_within('ZZ', $1) as a, territory_within($1, 'ZZ') as b`,
      [home],
    );
    expect(row.a).toBe(false);
    expect(row.b).toBe(false);
  });
});

describe('where the parties of a document are', () => {
  let db: PGlite;
  let companyId: string;
  let customer: string;
  let supplier: string;

  beforeAll(async () => {
    db = await freshDatabase({ modules: false });
    const fixture = await newCompany(db, { country: territorial.manifest.country, fiscalYear: year });
    companyId = fixture.companyId;
    await db.query(`update companies set territory_code = $2 where id = $1`, [companyId, home]);
    customer = await newContact(db, companyId, {
      type: 'customer',
      country: territorial.manifest.country,
      territory: away,
    });
    supplier = await newContact(db, companyId, {
      type: 'supplier',
      country: territorial.manifest.country,
      territory: away,
    });
  }, 300_000);

  afterAll(async () => {
    await db.close();
  });

  /** One draft document, and the three territories the engine reads off it. */
  async function partiesOf(
    docType: 'sale_invoice' | 'purchase_invoice',
    contactId: string,
    extra: { supplyTerritory?: string | null; deliveryCountry?: string | null } = {},
  ): Promise<{ seller: string | null; buyer: string | null; supply: string | null }> {
    const id = await newDocument(db, companyId, {
      docType,
      contactId,
      date: day,
      lines: [{ unitPrice: 100, accountCode: account }],
      ...extra,
    });
    return one(
      db,
      `select document_territory($1, 'seller') as seller,
              document_territory($1, 'buyer')  as buyer,
              document_territory($1, 'supply') as supply`,
      [id],
    );
  }

  it('puts the company on the selling side of a sale and on the buying side of a purchase', async () => {
    const sale = await partiesOf('sale_invoice', customer);
    expect(sale.seller).toBe(home);
    expect(sale.buyer).toBe(away);

    const purchase = await partiesOf('purchase_invoice', supplier);
    expect(purchase.seller).toBe(away);
    expect(purchase.buyer).toBe(home);
  });

  it('delivers to the buyer when the document says nothing else', async () => {
    const sale = await partiesOf('sale_invoice', customer);
    expect(sale.supply).toBe(away);
  });

  it('reads the delivery address of EN 16931 before the buyer', async () => {
    const sale = await partiesOf('sale_invoice', customer, {
      deliveryCountry: territorial.manifest.country,
    });
    expect(sale.supply).toBe(territorial.manifest.country);
  });

  it('reads the territory the document names before either of them', async () => {
    const sale = await partiesOf('sale_invoice', customer, {
      supplyTerritory: home,
      deliveryCountry: territorial.manifest.country,
    });
    expect(sale.supply).toBe(home);
  });

  it('refuses a party that is not one of the three', async () => {
    const id = await newDocument(db, companyId, {
      docType: 'sale_invoice',
      contactId: customer,
      date: day,
      lines: [{ unitPrice: 100, accountCode: account }],
    });
    const message = await expectError(db, `select document_territory($1, 'carrier')`, [id]);
    expect(message).toContain('unknown_party');
  });
});

describe('a tax the document contradicts is refused', () => {
  let db: PGlite;
  let companyId: string;
  let here: string;
  let there: string;

  beforeAll(async () => {
    db = await freshDatabase({ modules: false });
    const fixture = await newCompany(db, { country: territorial.manifest.country, fiscalYear: year });
    companyId = fixture.companyId;
    await db.query(`update companies set territory_code = $2 where id = $1`, [companyId, home]);
    here = await newContact(db, companyId, {
      type: 'customer',
      country: territorial.manifest.country,
      territory: home,
    });
    there = await newContact(db, companyId, {
      type: 'customer',
      country: territorial.manifest.country,
      territory: away,
    });
  }, 300_000);

  afterAll(async () => {
    await db.close();
  });

  async function invoice(contactId: string, taxCode: string): Promise<string> {
    return newDocument(db, companyId, {
      docType: 'sale_invoice',
      contactId,
      date: day,
      lines: [{ unitPrice: 1000, taxCode, accountCode: account }],
    });
  }

  // The case the American note asks for in as many words: the tax of one state
  // on a delivery to another. Before this it booked, and the return of the
  // first state quietly carried a sale made in the second.
  it('refuses the tax of one territory on a supply delivered in another', async () => {
    const id = await invoice(there, homeSale.code);
    const message = await expectError(db, `select post_document($1)`, [id]);
    expect(message).toContain('tax_territory_mismatch');
    expect(message).toContain(homeSale.code);
    expect(message).toContain(home);
    expect(message).toContain(away);
  });

  it('books the same invoice when the supply is where the tax says', async () => {
    const id = await invoice(here, homeSale.code);
    await db.query(`select post_document($1)`, [id]);
    const row = await one<{ state: string }>(db, `select state from documents where id = $1`, [id]);
    expect(row.state).toBe('posted');
  });

  it("accepts the other territory's tax exactly where the other territory is", async () => {
    const id = await invoice(there, awaySale.code);
    await db.query(`select post_document($1)`, [id]);
    const row = await one<{ state: string }>(db, `select state from documents where id = $1`, [id]);
    expect(row.state).toBe('posted');
  });

  it('names what would answer when nothing says where a party is', async () => {
    const nowhere = await newContact(db, companyId, { type: 'customer', country: null });
    const id = await invoice(nowhere, homeSale.code);
    const message = await expectError(db, `select post_document($1)`, [id]);
    expect(message).toContain('no_party_territory');
    expect(message).toContain(homeSale.code);
  });

  // The other half of the promise, and the one a reader should be able to check
  // quickly: a tax that names no territory is every tax of every pack written
  // before this change, and none of them gained a condition.
  it('leaves a tax that names no territory alone', async () => {
    const free = territorial.taxes.find(
      (tax) =>
        tax.scope === 'sale' &&
        tax.applies_seller_territory === null &&
        tax.applies_buyer_territory === null &&
        tax.applies_supply_territory === null,
    );
    const anywhere = free ?? otherPackTax();
    if (anywhere === null) return;
    const id = await invoice(there, anywhere.code);
    await db.query(`select post_document($1)`, [id]);
    const row = await one<{ state: string }>(db, `select state from documents where id = $1`, [id]);
    expect(row.state).toBe('posted');
  });

  /** A taxed sale of this pack with no condition on it, or nothing. */
  function otherPackTax(): PackTax | null {
    return (
      territorial.taxes.find(
        (tax) =>
          tax.scope === 'sale' &&
          tax.applies_seller_territory === null &&
          tax.applies_supply_territory === null,
      ) ?? null
    );
  }
});

describe('every territory a pack names is a row of the reference table', () => {
  it('holds for every pack of this repository', async () => {
    const territories = await readTerritories(repoRootOfPacks());
    const known = new Set(territories.map((territory) => territory.code));
    const unknown: string[] = [];
    for (const pack of allPacks) {
      for (const tax of pack.taxes) {
        for (const code of [
          tax.applies_seller_territory,
          tax.applies_buyer_territory,
          tax.applies_supply_territory,
          tax.jurisdiction,
        ]) {
          if (code !== null && !known.has(code)) unknown.push(`${pack.slug} ${tax.code} ${code}`);
        }
      }
      for (const contact of pack.golden?.contacts ?? []) {
        if (contact.territory !== null && !known.has(contact.territory)) {
          unknown.push(`${pack.slug} ${contact.ref} ${contact.territory}`);
        }
      }
      for (const document of pack.golden?.documents ?? []) {
        if (document.supply_territory !== null && !known.has(document.supply_territory)) {
          unknown.push(`${pack.slug} ${document.ref} ${document.supply_territory}`);
        }
      }
    }
    expect(unknown).toEqual([]);
  });
});

/**
 * A territory the common system reaches for goods alone.
 *
 * This is Northern Ireland and there is nothing else it could be: the
 * Withdrawal Agreement invented the middle value of `eu_vat_scope` and nothing
 * in European law has needed a second one. The test still finds it by that
 * property rather than by its name, because the claim being proved is about
 * the value and not about the place — the day a second such territory exists,
 * this reads it too.
 *
 * No pack of this repository declares such a tax, and the same is true of a
 * triangular one, for the same reason: writing an invented tax into `packs/<cc>/`
 * is writing a rule nobody can review. So the path is proved on a copy of the
 * real pack of the parent country, with one tax changed.
 */
describe('a tax of a territory the common system reaches for goods alone', () => {
  let goods: Territory;
  let parent: Pack;
  let dir: string;
  let slug: string;
  let zeroRated: PackTax;

  beforeAll(async () => {
    const territories = await readTerritories(repoRootOfPacks());
    goods = territories.find((territory) => territory.eu_vat_scope === 'goods') as Territory;
    parent = packWhere(
      'the country a territory of limited scope hangs off',
      (pack) => pack.manifest.country === goods.parent_code,
    );
    zeroRated = parent.taxes.find(
      (tax) => tax.scope === 'sale' && tax.rate === 0 && tax.postings.invoice.length === 1,
    ) as PackTax;

    slug = parent.slug;
    dir = await mkdtemp(join(tmpdir(), 'ekwo-territory-'));
    await cp(join(packsRoot, 'schema'), join(dir, 'schema'), { recursive: true });
    await cp(join(packsRoot, slug), join(dir, slug), { recursive: true });
  }, 300_000);

  /** The pack with one extra tax, read the way `ekwo pack check` reads it. */
  async function withTax(extra: Record<string, unknown>): Promise<Pack> {
    const path = join(dir, slug, 'taxes.json');
    const taxes = JSON.parse(await readFile(path, 'utf8')) as Record<string, unknown>[];
    const template = taxes.find((tax) => tax['code'] === zeroRated.code) as Record<string, unknown>;
    const added = { ...template, ...extra };
    await writeFile(path, JSON.stringify([...taxes, added]), 'utf8');
    try {
      return await readPack(slug, dir);
    } finally {
      await writeFile(path, JSON.stringify(taxes), 'utf8');
    }
  }

  /** What an intra-Community supply of goods says on the invoice. */
  const supply = {
    code: 'XX-ICG',
    name: 'Intra-Community supply of goods from the territory of limited scope',
    treatment: 'intracom_goods',
    vat_category: 'K',
    exemption_code: 'VATEX-EU-IC',
    rate: 0,
  };

  it('is accepted where the treatment is a supply of goods', async () => {
    const pack = await withTax({ ...supply, applies_when: { seller_in: goods.code } });
    const added = pack.taxes.find((tax) => tax.code === supply.code) as PackTax;
    expect(added.applies_seller_territory).toBe(goods.code);
  });

  // The pack's own country left the common system, so the same tax with no
  // territory on it is a pack claiming an operation of a system it is not in.
  // That refusal is what made the case unsayable, and naming the territory is
  // what answers it.
  it('is refused where the tax names no territory', async () => {
    await expect(withTax(supply)).rejects.toThrow(/common system of VAT/);
  });

  it('is refused where the treatment is a supply of services', async () => {
    await expect(
      withTax({
        ...supply,
        treatment: 'intracom_services',
        applies_when: { seller_in: goods.code },
      }),
    ).rejects.toThrow(/common system of VAT/);
  });

  it('is refused where the territory is one the reference table does not carry', async () => {
    await expect(
      withTax({ ...supply, applies_when: { seller_in: 'ZZ' } }),
    ).rejects.toThrow(/pack_invalid/);
  });

  it('is refused where the seller is outside the country of the pack', async () => {
    const elsewhere = (await readTerritories(repoRootOfPacks())).find(
      (territory) => territory.parent_code === null && territory.code !== parent.manifest.country,
    ) as Territory;
    await expect(
      withTax({ ...supply, applies_when: { seller_in: elsewhere.code } }),
    ).rejects.toThrow(/pack_invalid/);
  });
});

/**
 * A country's tax stops at a territory its own law takes out.
 *
 * The pack is the one whose country is the parent of a territory the reference
 * table marks `outside_parent_tax`, and that conditions a taxed sale on a supply
 * in that country; the territory and both taxes come out of the data. Before
 * `outside_parent_tax`, the country's rate booked on a delivery there, because
 * the tree of `territories` is geography and the territory is inside the
 * country — and the only way out was a negation the format refuses.
 */
describe('a supply to a territory outside its parent country\'s tax', () => {
  let db: PGlite;
  let companyId: string;
  let buyer: string;
  let pack: Pack;
  let excluded: Territory;
  let rated: PackTax;
  let exported: PackTax;

  beforeAll(async () => {
    const territories = await readTerritories(repoRootOfPacks());
    pack = packWhere('a country whose rates stop at a territory of its own', (candidate) =>
      territories.some(
        (territory) =>
          territory.outside_parent_tax &&
          territory.parent_code === candidate.manifest.country &&
          candidate.taxes.some(
            (tax) =>
              tax.scope === 'sale' &&
              tax.rate > 0 &&
              tax.applies_supply_territory === candidate.manifest.country,
          ),
      ),
    );
    excluded = territories.find(
      (territory) => territory.outside_parent_tax && territory.parent_code === pack.manifest.country,
    ) as Territory;
    rated = pack.taxes.find(
      (tax) =>
        tax.scope === 'sale' && tax.rate > 0 && tax.applies_supply_territory === pack.manifest.country,
    ) as PackTax;
    exported = pack.taxes.find(
      (tax) =>
        tax.scope === 'sale' &&
        tax.treatment === 'export' &&
        tax.applies_seller_territory === null &&
        tax.applies_supply_territory === null,
    ) as PackTax;

    db = await freshDatabase({ modules: false });
    const fixture = await newCompany(db, {
      country: pack.manifest.country,
      fiscalYear: pack.golden?.fiscalYear as { name: string; start: string; end: string },
    });
    companyId = fixture.companyId;
    buyer = await newContact(db, companyId, {
      type: 'customer',
      country: pack.manifest.country,
      territory: excluded.code,
    });
  }, 300_000);

  afterAll(async () => {
    await db.close();
  });

  async function sale(contactId: string, taxCode: string): Promise<string> {
    return newDocument(db, companyId, {
      docType: 'sale_invoice',
      contactId,
      date: pack.golden?.documents[0]?.date as string,
      lines: [{ unitPrice: 1000, taxCode, accountCode: pack.golden?.documents[0]?.lines[0]?.account as string }],
    });
  }

  it("refuses the country's rate on a supply delivered there", async () => {
    const id = await sale(buyer, rated.code);
    const message = await expectError(db, `select post_document($1)`, [id]);
    expect(message).toContain('tax_territory_mismatch');
    expect(message).toContain(rated.code);
    expect(message).toContain(excluded.code);
  });

  it('books the same sale as an export, and keeps where it went', async () => {
    const id = await sale(buyer, exported.code);
    await db.query(`select post_document($1)`, [id]);
    const row = await one<{ state: string; seller: string; buyer: string; supply: string }>(
      db,
      `select state, seller_territory_code as seller, buyer_territory_code as buyer,
              supply_territory_resolved as supply
         from documents where id = $1`,
      [id],
    );
    expect(row).toEqual({
      state: 'posted',
      seller: pack.manifest.country,
      buyer: excluded.code,
      supply: excluded.code,
    });
  });

  it("still books the country's rate on a supply inside the country", async () => {
    const home = await newContact(db, companyId, { type: 'customer', country: pack.manifest.country });
    const id = await sale(home, rated.code);
    await db.query(`select post_document($1)`, [id]);
    const row = await one<{ supply: string }>(
      db,
      `select supply_territory_resolved as supply from documents where id = $1`,
      [id],
    );
    expect(row.supply).toBe(pack.manifest.country);
  });

  // What was believed stays believed. The contact moves; the posted document
  // does not, and nobody writes the frozen answer by hand.
  it('keeps the territories it was judged against once posted', async () => {
    const id = await sale(buyer, exported.code);
    await db.query(`select post_document($1)`, [id]);
    await db.query(`update contacts set territory_code = null where id = $1`, [buyer]);
    try {
      const row = await one<{ supply: string }>(
        db,
        `select supply_territory_resolved as supply from documents where id = $1`,
        [id],
      );
      expect(row.supply).toBe(excluded.code);
      const message = await expectError(
        db,
        `update documents set supply_territory_resolved = $2 where id = $1`,
        [id, pack.manifest.country],
      );
      expect(message).toContain('document_posted');
    } finally {
      await db.query(`update contacts set territory_code = $2 where id = $1`, [buyer, excluded.code]);
    }
  });
});

/**
 * The place of supply measured against the seller.
 *
 * The pack is the one that declares the relation; the relation's tax, the
 * seller's territory and a second territory inside the same country come out
 * of the pack and the reference table. The opposite value is proved on the
 * company's copy of the same tax, which is a fixture: no tax is invented in
 * `packs/`.
 */
describe('a supply measured against the territory of its seller', () => {
  let db: PGlite;
  let companyId: string;
  let pack: Pack;
  let relational: PackTax;
  let sellerTerritory: string;
  let elsewhere: string;

  beforeAll(async () => {
    const territories = await readTerritories(repoRootOfPacks());
    pack = packWhere('a tax measured against the seller', (candidate) =>
      candidate.taxes.some(
        (tax) => tax.scope === 'sale' && tax.applies_supply_vs_seller !== null && tax.applies_seller_territory !== null,
      ),
    );
    relational = pack.taxes.find(
      (tax) => tax.scope === 'sale' && tax.applies_supply_vs_seller !== null && tax.applies_seller_territory !== null,
    ) as PackTax;
    sellerTerritory = relational.applies_seller_territory as string;
    elsewhere = (
      territories.find(
        (territory) =>
          territory.code !== sellerTerritory &&
          !territory.outside_parent_tax &&
          territory.parent_code === pack.manifest.country,
      ) as Territory
    ).code;

    db = await freshDatabase({ modules: false });
    const fixture = await newCompany(db, {
      country: pack.manifest.country,
      fiscalYear: pack.golden?.fiscalYear as { name: string; start: string; end: string },
    });
    companyId = fixture.companyId;
    await db.query(`update companies set territory_code = $2 where id = $1`, [companyId, sellerTerritory]);
  }, 300_000);

  afterAll(async () => {
    await db.close();
  });

  async function sale(territory: string): Promise<string> {
    const contact = await newContact(db, companyId, {
      type: 'customer',
      country: pack.manifest.country,
      territory,
    });
    return newDocument(db, companyId, {
      docType: 'sale_invoice',
      contactId: contact,
      date: pack.golden?.documents[0]?.date as string,
      lines: [
        {
          unitPrice: 1000,
          taxCode: relational.code,
          accountCode: pack.golden?.documents[0]?.lines[0]?.account as string,
        },
      ],
    });
  }

  /** Post a sale delivered in one territory, and say how it ended. */
  async function outcome(territory: string): Promise<string> {
    const id = await sale(territory);
    try {
      await db.query(`select post_document($1)`, [id]);
      return 'posted';
    } catch (error) {
      return (error as Error).message.split(':')[0] as string;
    }
  }

  it('accepts and refuses according to where the supply lies against the seller', async () => {
    const inside = relational.applies_supply_vs_seller === 'same';
    expect(await outcome(sellerTerritory)).toBe(inside ? 'posted' : 'tax_territory_mismatch');
    expect(await outcome(elsewhere)).toBe(inside ? 'tax_territory_mismatch' : 'posted');
  });

  it('reads the opposite relation the opposite way', async () => {
    const opposite = relational.applies_supply_vs_seller === 'same' ? 'other' : 'same';
    await db.query(
      `update taxes set applies_supply_vs_seller = $3 where company_id = $1 and code = $2`,
      [companyId, relational.code, opposite],
    );
    try {
      const inside = opposite === 'same';
      expect(await outcome(sellerTerritory)).toBe(inside ? 'posted' : 'tax_territory_mismatch');
      expect(await outcome(elsewhere)).toBe(inside ? 'tax_territory_mismatch' : 'posted');
    } finally {
      await db.query(
        `update taxes set applies_supply_vs_seller = $3 where company_id = $1 and code = $2`,
        [companyId, relational.code, relational.applies_supply_vs_seller],
      );
    }
  });

  // A seller known only by its country has no level to be compared at. The
  // seller condition of the pack's own tax is lifted on the company's copy, so
  // that what is refused is the relation and not the territory.
  it('refuses a seller known only by the country, by name', async () => {
    await db.query(`update companies set territory_code = null where id = $1`, [companyId]);
    await db.query(
      `update taxes set applies_seller_territory = null where company_id = $1 and code = $2`,
      [companyId, relational.code],
    );
    try {
      const id = await sale(elsewhere);
      const message = await expectError(db, `select post_document($1)`, [id]);
      expect(message).toContain('no_party_territory');
      expect(message).toContain(relational.code);
    } finally {
      await db.query(`update companies set territory_code = $2 where id = $1`, [companyId, sellerTerritory]);
      await db.query(
        `update taxes set applies_seller_territory = $3 where company_id = $1 and code = $2`,
        [companyId, relational.code, sellerTerritory],
      );
    }
  });
});

describe('ekwo pack check on a relation to the seller', () => {
  let dir: string;
  let pack: Pack;

  beforeAll(async () => {
    const territories = await readTerritories(repoRootOfPacks());
    // A pack whose country has nothing inside it in the reference table.
    pack = packWhere('a country with no territory inside it', (candidate) =>
      !territories.some((territory) => territory.parent_code === candidate.manifest.country),
    );
    dir = await mkdtemp(join(tmpdir(), 'ekwo-relation-'));
    await cp(join(packsRoot, 'schema'), join(dir, 'schema'), { recursive: true });
    await cp(join(packsRoot, pack.slug), join(dir, pack.slug), { recursive: true });
  }, 300_000);

  async function withRelation(value: string): Promise<Pack> {
    const path = join(dir, pack.slug, 'taxes.json');
    const taxes = JSON.parse(await readFile(path, 'utf8')) as Record<string, unknown>[];
    const first = taxes.findIndex((tax) => tax['scope'] === 'sale');
    const changed = taxes.map((tax, index) =>
      index === first ? { ...tax, applies_when: { supply_vs_seller: value } } : tax,
    );
    await writeFile(path, JSON.stringify(changed), 'utf8');
    try {
      return await readPack(pack.slug, dir);
    } finally {
      await writeFile(path, JSON.stringify(taxes), 'utf8');
    }
  }

  it('is refused where the country has no territory to read the seller at', async () => {
    await expect(withRelation('same')).rejects.toThrow(/supply_vs_seller/);
  });

  it('is refused by the schema for a value that is not a relation', async () => {
    await expect(withRelation('elsewhere')).rejects.toThrow(/pack_invalid/);
  });
});

/** The checkout the seeds are read from: the folder that holds `packs/`. */
function repoRootOfPacks(): string {
  return join(packsDir(), '..');
}
