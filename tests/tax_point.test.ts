import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, newUser, type Fixture } from './helpers/factory.js';
import { allPacks, packWhere, taxPointRules } from './helpers/packs.js';
import type { Pack } from '../packages/cli/src/index.js';

/**
 * When the tax on a document falls due, and the engine reading the word a
 * country wrote.
 *
 * `country_defaults.tax_point_rule` held one of three words and no function
 * read any of them: a tax was dated by the day its entry was booked on, which
 * is a different question, and a pack could declare anything without a single
 * figure moving. Two things are proved here.
 *
 *   1. **The vocabulary is one vocabulary.** What `packs/schema/pack.1.json`
 *      lets a pack write, what the check constraint lets the database hold and
 *      what `tax_point_of()` knows how to answer are the same list. A word in
 *      one and not in the others is how a rule becomes a comment.
 *   2. **The declaration reads it.** An invoice for goods delivered in the
 *      period before it is declared in the period of the delivery where the
 *      country dates a tax by the supply, and in the period of the invoice
 *      where the country's invoice displaces the supply — the same document,
 *      the same ledger, two answers, each one its country's.
 *
 * Both packs under test are chosen by the rule they declare, never by name.
 */

/** The pack whose tax point follows the supply, and the one whose invoice displaces it. */
const supplyDated = packWhere(
  'dates a tax by the supply',
  (p) =>
    p.documents.tax_point_rule === 'delivery_date' ||
    p.documents.tax_point_rule === 'earliest_of_delivery_or_payment',
);
const invoiceDated = packWhere(
  'lets an invoice displace the supply',
  (p) => p.documents.tax_point_rule === 'invoice_if_issued',
);

/**
 * A domestic sale the pack's own golden books, with the account it books it
 * on. Read there rather than picked, so this test stays true of the pack and
 * not of a chart somebody remembered.
 */
function domesticSale(pack: Pack): { taxCode: string; accountCode: string } {
  const domestic = new Set(
    pack.taxes.filter((tax) => tax.treatment === 'domestic' && !tax.cash_basis).map((tax) => tax.code),
  );
  for (const document of pack.golden?.documents ?? []) {
    if (document.type !== 'sale_invoice') continue;
    for (const line of document.lines) {
      if (line.tax !== null && domestic.has(line.tax)) {
        return { taxCode: line.tax, accountCode: line.account };
      }
    }
  }
  throw new Error(`${pack.slug} books no domestic sale in its golden scenario`);
}

/** Two whole quarters of one year, so no cadence guard has anything to say. */
const FIRST = { from: '2026-01-01', to: '2026-03-31' };
const SECOND = { from: '2026-04-01', to: '2026-06-30' };
/** Delivered in the first quarter, invoiced in the second. */
const DELIVERED = '2026-03-25';
const INVOICED = '2026-04-02';

let db: PGlite;

beforeAll(async () => {
  db = await freshDatabase();
}, 180_000);

afterAll(async () => {
  await db.close();
});

/** A company of a pack, with nothing recorded about how often it files. */
async function companyOf(pack: Pack): Promise<{ fixture: Fixture; customer: string }> {
  const owner = await newUser(db, `${pack.slug}-tax-point@example.test`);
  // country-literal: a company has to be installed somewhere to book anything,
  // and the somewhere is whichever pack declares the rule under test.
  const fixture = await newCompany(db, {
    country: pack.manifest.country,
    name: `${pack.slug} tax point`,
    ownerId: owner,
    fiscalYear: { name: 'Tax point year', start: '2026-01-01', end: '2026-12-31' },
  });
  // The cadence is not what this file is about, and a company that has
  // recorded one refuses a period it does not file on. Forget it, and both
  // quarters are simply two pairs of dates.
  await db.query(`delete from company_filing_periods where company_id = $1`, [fixture.companyId]);
  const customer = await newContact(db, fixture.companyId, { country: pack.manifest.country });
  return { fixture, customer };
}

/** What a period's declaration carries, ledger boxes only, summed. */
async function declared(companyId: string, period: { from: string; to: string }): Promise<number> {
  const row = await one<{ total: string }>(
    db,
    `select coalesce(sum(amount), 0)::text as total
       from vat_return($1, $2::date, $3::date)
      where not computed`,
    [companyId, period.from, period.to],
  );
  return Number(row.total);
}

describe('one vocabulary, in three places', () => {
  it('the schema, the constraint and the function know the same words', async () => {
    const constraint = await one<{ definition: string }>(
      db,
      `select pg_get_constraintdef(c.oid) as definition
         from pg_constraint c
        where c.conname = 'country_defaults_tax_point_rule_known'`,
    );
    for (const rule of taxPointRules) {
      expect(constraint.definition, rule).toContain(`'${rule}'`);
    }
    // And nothing the database holds that the schema never published: the
    // constraint names exactly as many literals as the vocabulary has words.
    const quoted = constraint.definition.match(/'[a-z_]+'::text/g) ?? [];
    expect(new Set(quoted).size).toBe(taxPointRules.length);
  });

  it('tax_point_of answers for every word, and for no word answers nothing', async () => {
    const country = supplyDated.manifest.country;
    const original = await one<{ rule: string | null }>(
      db,
      `select tax_point_rule as rule from country_defaults where country = $1`,
      [country],
    );
    const { fixture } = await companyOf(supplyDated);
    try {
      for (const rule of taxPointRules) {
        await db.query(`update country_defaults set tax_point_rule = $2 where country = $1`, [
          country,
          rule,
        ]);
        const answer = await one<{ point: string | null }>(
          db,
          `select tax_point_of($1, $2::date, $3::date, $4::date)::text as point`,
          [fixture.companyId, INVOICED, DELIVERED, '2026-02-10'],
        );
        expect(answer.point, `${rule} answers a date when it is given all three`).not.toBeNull();
      }
      // A country that declares nothing borrows nobody's law.
      await db.query(`update country_defaults set tax_point_rule = null where country = $1`, [country]);
      const silent = await one<{ point: string | null }>(
        db,
        `select tax_point_of($1, $2::date, $3::date, null)::text as point`,
        [fixture.companyId, INVOICED, DELIVERED],
      );
      expect(silent.point).toBeNull();
    } finally {
      await db.query(`update country_defaults set tax_point_rule = $2 where country = $1`, [
        country,
        original.rule,
      ]);
    }
  });

  it('every pack declares a word the vocabulary carries', () => {
    for (const pack of allPacks) {
      const rule = pack.documents.tax_point_rule;
      if (rule === null) continue;
      expect(taxPointRules, pack.slug).toContain(rule);
    }
  });
});

describe('the declaration files a figure by the day its tax fell due', () => {
  it('puts a supply-dated invoice in the period of the delivery', async () => {
    const { fixture, customer } = await companyOf(supplyDated);
    const { taxCode, accountCode } = domesticSale(supplyDated);
    const document = await newDocument(db, fixture.companyId, {
      docType: 'sale_invoice',
      contactId: customer,
      date: INVOICED,
      lines: [{ name: 'Goods', unitPrice: 1000, taxCode, accountCode }],
    });
    await db.query(`update documents set delivery_date = $2 where id = $1`, [document, DELIVERED]);
    await db.query(`select post_document($1)`, [document]);

    const stored = await one<{ point: string | null; booked: string }>(
      db,
      `select d.tax_point_date::text as point, e.entry_date::text as booked
         from documents d join entries e on e.id = d.entry_id where d.id = $1`,
      [document],
    );
    expect(stored.point).toBe(DELIVERED);
    expect(stored.booked).toBe(INVOICED);

    // The ledger is booked in the second quarter and declared in the first.
    expect(await declared(fixture.companyId, SECOND)).toBe(0);
    expect(await declared(fixture.companyId, FIRST)).toBeGreaterThan(0);
  });

  it('puts an invoice-dated one in the period of the invoice, delivery or not', async () => {
    const { fixture, customer } = await companyOf(invoiceDated);
    const { taxCode, accountCode } = domesticSale(invoiceDated);
    const document = await newDocument(db, fixture.companyId, {
      docType: 'sale_invoice',
      contactId: customer,
      date: INVOICED,
      lines: [{ name: 'Goods', unitPrice: 1000, taxCode, accountCode }],
    });
    await db.query(`update documents set delivery_date = $2 where id = $1`, [document, DELIVERED]);
    await db.query(`select post_document($1)`, [document]);

    const stored = await one<{ point: string | null }>(
      db,
      `select tax_point_date::text as point from documents where id = $1`,
      [document],
    );
    expect(stored.point).toBe(INVOICED);
    expect(await declared(fixture.companyId, FIRST)).toBe(0);
    expect(await declared(fixture.companyId, SECOND)).toBeGreaterThan(0);
  });

  it('keeps a tax point the document states for itself, whatever the rule says', async () => {
    const { fixture, customer } = await companyOf(supplyDated);
    const { taxCode, accountCode } = domesticSale(supplyDated);
    const document = await newDocument(db, fixture.companyId, {
      docType: 'sale_invoice',
      contactId: customer,
      date: INVOICED,
      lines: [{ name: 'Goods', unitPrice: 1000, taxCode, accountCode }],
    });
    // BT-7 on the document and BT-72 disagreeing with it: a stated fact
    // outranks a rule, so the rule does not get to overwrite it.
    await db.query(`update documents set delivery_date = $2, tax_point_date = $3 where id = $1`, [
      document,
      DELIVERED,
      INVOICED,
    ]);
    await db.query(`select post_document($1)`, [document]);

    const lines = await rows<{ point: string | null }>(
      db,
      `select l.tax_point_date::text as point
         from entry_lines l join entries e on e.id = l.entry_id
        where e.document_id = $1 and l.tax_id is not null`,
      [document],
    );
    expect(lines.length).toBeGreaterThan(0);
    for (const line of lines) expect(line.point).toBe(INVOICED);
    expect(await declared(fixture.companyId, SECOND)).toBeGreaterThan(0);
  });

  it('leaves a line with no tax point to the date of its entry', async () => {
    const { fixture, customer } = await companyOf(supplyDated);
    const { taxCode, accountCode } = domesticSale(supplyDated);
    const document = await newDocument(db, fixture.companyId, {
      docType: 'sale_invoice',
      contactId: customer,
      date: INVOICED,
      lines: [{ name: 'Goods', unitPrice: 1000, taxCode, accountCode }],
    });
    await db.query(`select post_document($1)`, [document]);
    // Nothing said when it was delivered, so the supply rule falls back on the
    // invoice, and the counterpart — written by no tax posting — says nothing
    // at all.
    const counterpart = await one<{ point: string | null }>(
      db,
      `select l.tax_point_date::text as point
         from entry_lines l join entries e on e.id = l.entry_id
        where e.document_id = $1 and l.tax_id is null`,
      [document],
    );
    expect(counterpart.point).toBeNull();
    expect(await declared(fixture.companyId, SECOND)).toBeGreaterThan(0);
  });
});
