import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { expectError, freshDatabase, one, rows } from './helpers/db.js';
import { ledgerOf, newCompany, newContact, type Fixture } from './helpers/factory.js';

/**
 * A document keeps the tax its source states, within a rounding (decision 0099).
 *
 * A billing system that rounds the tax line by line states, for three lines of
 * 0.25 at 6 %, a tax of 0.02 + 0.02 + 0.02 = 0.06, where the group rounded once
 * gives round(0.75 x 6 %) = 0.05. What is proved here, to the cent:
 *
 *   1. a document that states nothing computes exactly as before;
 *   2. a stated tax within one unit per line is what the totals, the tax line
 *      of the entry, its declaration box and the breakdown carry, and the
 *      difference is booked nowhere else;
 *   3. beyond the tolerance, a group stated on some lines only, and a price
 *      that holds its tax are refused at posting, by name;
 *   4. a credit note cancelling such an invoice gives back the tax it charged;
 *   5. `create_document()` takes the stated tax as one more optional field;
 *   6. the tolerance is one unit of the currency per line, whatever the
 *      currency's decimals.
 *
 * The taxes are invented — `ZZ-` codes, rates chosen for their arithmetic —
 * on a company of whichever pack writes its currency with two decimals and
 * rounds half up. No country's tax is under test.
 */

let db: PGlite;
let company: Fixture;
let customer: string;
let income: string;
let liability: string;

async function inventTax(code: string, rate: number, priceInclude = false): Promise<void> {
  const tax = await one<{ id: string }>(
    db,
    `insert into taxes (company_id, code, name, amount_type, amount, applies_to, valid_from, price_include)
     values ($1, $2, $2, 'percent', $3, 'sale', '2000-01-01', $4) returning id`,
    [company.companyId, code, rate, priceInclude],
  );
  for (const [kind, factor] of [
    ['invoice', 100],
    ['credit_note', -100],
  ] as const) {
    await db.query(
      `insert into tax_postings (tax_id, company_id, document_kind, posting_type, account_id,
                                 declaration_box, box_factor_percent, sequence)
       values ($1, $2, $3, 'base', null, 'ZB', $4, 10),
              ($1, $2, $3, 'tax', account_id_by_code($2, $5), 'ZT', $4, 20)`,
      [tax.id, company.companyId, kind, factor, liability],
    );
  }
}

interface Line {
  unitPrice: number;
  taxCode: string;
  stated?: number | null;
}

let number = 0;
async function draft(lines: Line[]): Promise<string> {
  number += 1;
  const document = await one<{ id: string }>(
    db,
    `insert into documents (company_id, doc_type, number, contact_id, document_date)
     values ($1, 'sale_invoice', $2, $3, '2026-06-15') returning id`,
    [company.companyId, `ZZ-ST-${number}`, customer],
  );
  let sequence = 0;
  for (const line of lines) {
    sequence += 10;
    await db.query(
      `insert into document_lines (document_id, company_id, sequence, name, quantity, unit_price,
                                   tax_id, account_id, stated_tax_amount)
       values ($1, $2, $3, 'Line', 1, $4,
               (select id from taxes where company_id = $2 and code = $5),
               account_id_by_code($2, $6), $7)`,
      [document.id, company.companyId, sequence, line.unitPrice, line.taxCode, income, line.stated ?? null],
    );
  }
  return document.id;
}

async function book(lines: Line[]): Promise<string> {
  const document = await draft(lines);
  await db.query(`select post_document($1)`, [document]);
  return document;
}

async function totals(document: string): Promise<{ untaxed: string; tax: string; total: string }> {
  return one(
    db,
    `select amount_untaxed::text as untaxed, amount_tax::text as tax, amount_total::text as total
       from documents where id = $1`,
    [document],
  );
}

beforeAll(async () => {
  db = await freshDatabase();
  const pack = await one<{ country: string }>(
    db,
    `select d.country from country_defaults d join currencies c on c.code = d.currency_code
      where c.decimal_places = 2 and d.rounding_method = 'half_up' order by d.country limit 1`,
  );
  company = await newCompany(db, { country: pack.country, name: 'Stated Tax Fixture' });
  customer = await newContact(db, company.companyId, { country: pack.country });
  income = (
    await one<{ code: string }>(
      db,
      `select code from accounts where company_id = $1 and account_type = 'income' order by code limit 1`,
      [company.companyId],
    )
  ).code;
  liability = (
    await one<{ code: string }>(
      db,
      `select code from accounts where company_id = $1 and account_type = 'liability_current' order by code limit 1`,
      [company.companyId],
    )
  ).code;
  await inventTax('ZZ-6', 6);
  await inventTax('ZZ-21', 21);
  await inventTax('ZZ-6-PI', 6, true);
}, 180_000);

afterAll(async () => {
  await db.close();
});

const threeQuarters = (stated: number | null): Line[] => [
  { unitPrice: 0.25, taxCode: 'ZZ-6', stated },
  { unitPrice: 0.25, taxCode: 'ZZ-6', stated },
  { unitPrice: 0.25, taxCode: 'ZZ-6', stated },
];

describe('a document that states nothing', () => {
  it('rounds the group once, as before: 0.75 at 6 % carries 0.05', async () => {
    const document = await book(threeQuarters(null));
    expect(await totals(document)).toEqual({ untaxed: '0.75', tax: '0.05', total: '0.80' });
    expect(
      await one(
        db,
        `select tax_amount::text as tax, tax_amount_computed::text as computed,
                stated_tax_amount::text as stated, line_count
           from document_tax_summary where document_id = $1`,
        [document],
      ),
    ).toEqual({ tax: '0.05', computed: '0.05', stated: null, line_count: 3 });
  });
});

describe('a stated tax within one unit per line', () => {
  it('is what the totals, the entry, the box and the breakdown carry', async () => {
    const document = await book(threeQuarters(0.02));
    expect(await totals(document)).toEqual({ untaxed: '0.75', tax: '0.06', total: '0.81' });
    expect(
      await one(
        db,
        `select base_amount::text as base, tax_amount::text as tax, tax_charged::text as charged,
                tax_amount_computed::text as computed, stated_tax_amount::text as stated, line_count
           from document_tax_summary where document_id = $1`,
        [document],
      ),
    ).toEqual({ base: '0.75', tax: '0.06', charged: '0.06', computed: '0.05', stated: '0.06', line_count: 3 });

    const ledger = await ledgerOf(db, document);
    // The base, the tax and the receivable: nothing else, so the cent of
    // difference is booked on no other account.
    expect(ledger).toHaveLength(3);
    expect(ledger.find((l) => l.code === income)).toMatchObject({ credit: '0.75', box: 'ZB', box_amount: '0.75' });
    expect(ledger.find((l) => l.tax_line)).toMatchObject({ code: liability, credit: '0.06', box: 'ZT', box_amount: '0.06' });
    expect(ledger.find((l) => Number(l.debit) > 0)).toMatchObject({ debit: '0.81' });
  });

  it('accepts one cent on one line, and publishes the stated tax of each line', async () => {
    const document = await book([{ unitPrice: 10, taxCode: 'ZZ-6', stated: 0.61 }]);
    expect(await totals(document)).toEqual({ untaxed: '10.00', tax: '0.61', total: '10.61' });
    expect(
      await rows(db, `select stated_tax_amount::text as stated from document_line_items where document_id = $1`, [document]),
    ).toEqual([{ stated: '0.61' }]);
  });

  it('keeps each group to itself: a stated group beside one Ekwo computes', async () => {
    const document = await book([
      { unitPrice: 0.25, taxCode: 'ZZ-6', stated: 0.02 },
      { unitPrice: 0.25, taxCode: 'ZZ-6', stated: 0.02 },
      { unitPrice: 10, taxCode: 'ZZ-21' },
    ]);
    expect(
      await rows(
        db,
        `select tax_code as code, tax_amount::text as tax from document_tax_summary
          where document_id = $1 order by tax_code`,
        [document],
      ),
    ).toEqual([
      { code: 'ZZ-21', tax: '2.10' },
      { code: 'ZZ-6', tax: '0.04' },
    ]);
    expect(await totals(document)).toEqual({ untaxed: '10.50', tax: '2.14', total: '12.64' });
  });
});

describe('the refusals, at posting', () => {
  it('refuses a stated tax two cents from the one line it taxes', async () => {
    const document = await draft([{ unitPrice: 10, taxCode: 'ZZ-6', stated: 0.62 }]);
    const message = await expectError(db, `select post_document($1)`, [document]);
    expect(message).toMatch(/^stated_tax_out_of_tolerance: tax ZZ-6 .* stated at 0\.62 .* give 0\.60, a difference above 0\.01/);
    expect(message).toMatch(/leave the stated tax out/);
    expect((await one<{ state: string }>(db, `select state::text from documents where id = $1`, [document])).state).toBe(
      'draft',
    );
  });

  it('refuses a group that states its tax on some lines only', async () => {
    const document = await draft([
      { unitPrice: 0.25, taxCode: 'ZZ-6', stated: 0.02 },
      { unitPrice: 0.25, taxCode: 'ZZ-6', stated: null },
    ]);
    expect(await expectError(db, `select post_document($1)`, [document])).toMatch(
      /^stated_tax_partial: tax ZZ-6 .* on 1 of its 2 lines/,
    );
  });

  it('refuses a stated tax on a price that holds its tax', async () => {
    const document = await draft([{ unitPrice: 10.6, taxCode: 'ZZ-6-PI', stated: 0.6 }]);
    expect(await expectError(db, `select post_document($1)`, [document])).toMatch(/^stated_tax_on_inclusive_price: tax ZZ-6-PI/);
  });

  it('refuses a stated tax on a line without a tax', async () => {
    const document = await draft([]);
    expect(
      await expectError(
        db,
        `insert into document_lines (document_id, company_id, sequence, name, quantity, unit_price, account_id, stated_tax_amount)
         values ($1, $2, 10, 'Line', 1, 10, account_id_by_code($2, $3), 0.6)`,
        [document, company.companyId, income],
      ),
    ).toMatch(/document_lines_stated_tax_needs_a_tax/);
  });
});

describe('the writers carry it', () => {
  it('a credit note cancelling the invoice gives back the tax it charged', async () => {
    const invoice = await book(threeQuarters(0.02));
    const credit = await one<{ id: string }>(db, `select (cancel_document($1)).id`, [invoice]);
    expect(await totals(credit.id)).toEqual({ untaxed: '0.75', tax: '0.06', total: '0.81' });
    const ledger = await ledgerOf(db, credit.id);
    expect(ledger.find((l) => l.tax_line)).toMatchObject({ debit: '0.06', box: 'ZT', box_amount: '-0.06' });
  });

  it('create_document() takes the stated tax of a line as an optional field', async () => {
    const tax = await one<{ id: string }>(db, `select id from taxes where company_id = $1 and code = 'ZZ-6'`, [
      company.companyId,
    ]);
    const created = await one<{ id: string }>(
      db,
      `select create_document($1::jsonb, $2::jsonb) as id`,
      [
        JSON.stringify({ company_id: company.companyId, doc_type: 'sale_invoice', contact_id: customer, document_date: '2026-06-15' }),
        JSON.stringify([
          { name: 'Stated', unit_price: '0.25', tax_id: tax.id, account_id: null, stated_tax_amount: '0.02' },
          { name: 'Stated', unit_price: '0.25', tax_id: tax.id, stated_tax_amount: '0.02' },
          { name: 'Stated', unit_price: '0.25', tax_id: tax.id, stated_tax_amount: '0.02' },
        ]),
      ],
    );
    expect(await totals(created.id)).toEqual({ untaxed: '0.75', tax: '0.06', total: '0.81' });
    await db.query(`select post_document($1)`, [created.id]);
  });
});

describe('the tolerance', () => {
  it('is one unit of the currency per line, at the decimals of the currency', async () => {
    const home = await one<{ tolerance: string }>(
      db,
      `select stated_tax_tolerance($1, c.currency_code, 3)::text as tolerance from companies c where c.id = $1`,
      [company.companyId],
    );
    expect(home.tolerance).toBe('0.03');
    const [whole] = await rows<{ code: string }>(
      db,
      `select code from currencies where decimal_places = 0 order by code limit 1`,
    );
    if (whole !== undefined) {
      const tolerance = await one<{ tolerance: string }>(db, `select stated_tax_tolerance($1, $2, 2)::text as tolerance`, [
        company.companyId,
        whole.code,
      ]);
      expect(Number(tolerance.tolerance)).toBe(2);
    }
  });
});
