import type { PGlite } from '@electric-sql/pglite';
import { cp, mkdtemp, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { expectError, freshDatabase, one, rows, withoutTrigger } from './helpers/db.js';
import { ledgerOf, newCompany, newContact, newDocument, type Fixture } from './helpers/factory.js';
import { compilePack, packsDir, readPack } from '../packages/cli/src/index.js';
import { allPacks, packWhere } from './helpers/packs.js';

/**
 * A tax computed inside its own base (decision 0077).
 *
 * Some taxes are levied on a base that already contains them: the legal rate
 * applies to the price with the tax in it, so on a net amount N at a rate r
 * the tax is N x r / (1 - r), and on a price P that holds it the tax is
 * P x r. What is proved here, to the cent:
 *
 *   1. a single tax on a net amount, grossed up exactly — where the effective
 *      rate a pack could otherwise declare, rounded to four decimals, drifts;
 *   2. the box of the base reports the base the rate was applied to, the net
 *      plus the tax, shared over the ledger lines so that it adds up;
 *   3. a price that holds such a tax: the tax is the price times the rate;
 *   4. a credit note, the invoice with its signs flipped;
 *   5. beside an ordinary tax added on top, on another line of the document;
 *   6. a half-way figure rounds as the currency says, because the arithmetic
 *      is exact;
 *   7. the refusals: a fixed amount, a rate of one hundred, a group whose
 *      lines disagree;
 *   8. the key of a pack: read, refused by `ekwo pack check` where it cannot
 *      hold, compiled into a seed that leaves every other pack's unchanged,
 *      and copied onto the tax a company installs.
 *
 * The taxes are invented — `ZZ-` codes, rates chosen for their arithmetic —
 * and installed on a company of whichever pack writes its currency with two
 * decimals and rounds half up. No country's tax is under test.
 */

let db: PGlite;
let company: Fixture;
let customer: string;
/** Three income accounts and one liability account of the company's chart. */
let income: string[];
let liability: string;

/** An invented tax and its postings: base and tax to boxes `ZB` and `ZT`. */
async function inventTax(
  code: string,
  rate: number,
  options: { inside?: boolean; priceInclude?: boolean } = {},
): Promise<void> {
  const tax = await one<{ id: string }>(
    db,
    `insert into taxes (company_id, code, name, amount_type, amount, applies_to, valid_from,
                        price_include, base_includes_tax)
     values ($1, $2, $2, 'percent', $3, 'sale', '2000-01-01', $4, $5) returning id`,
    [company.companyId, code, rate, options.priceInclude ?? false, options.inside ?? false],
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

let number = 0;
async function book(
  lines: { unitPrice: number; taxCode: string | null; accountCode?: string }[],
  docType: 'sale_invoice' | 'sale_credit_note' = 'sale_invoice',
): Promise<string> {
  number += 1;
  const document = await newDocument(db, company.companyId, {
    docType,
    number: `ZZ-${number}`,
    contactId: customer,
    lines: lines.map((line) => ({ ...line, accountCode: line.accountCode ?? income[0]! })),
  });
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

async function summary(document: string): Promise<{ code: string; base: string; tax: string; taxable: string; inside: boolean }[]> {
  return rows(
    db,
    `select tax_code as code, base_amount::text as base, tax_amount::text as tax,
            taxable_amount::text as taxable, base_includes_tax as inside
       from document_tax_summary where document_id = $1 order by tax_code`,
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
  company = await newCompany(db, { country: pack.country, name: 'Inside Base Fixture' });
  customer = await newContact(db, company.companyId, { country: pack.country });
  income = (
    await rows<{ code: string }>(
      db,
      `select code from accounts where company_id = $1 and account_type = 'income' order by code limit 3`,
      [company.companyId],
    )
  ).map((a) => a.code);
  liability = (
    await one<{ code: string }>(
      db,
      `select code from accounts where company_id = $1 and account_type = 'liability_current' order by code limit 1`,
      [company.companyId],
    )
  ).code;
  expect(income).toHaveLength(3);

  await inventTax('ZZ-IN-18', 18, { inside: true });
  await inventTax('ZZ-IN-18-PI', 18, { inside: true, priceInclude: true });
  await inventTax('ZZ-IN-20', 20, { inside: true });
  await inventTax('ZZ-ON-10', 10);
  // What a pack can say without the key: the effective rate 18/82, rounded to
  // the four decimals of the column, added on top.
  await inventTax('ZZ-EFF-18', 21.9512);
  // And on a price that holds it, the Bolivian way of saying it.
  await inventTax('ZZ-EFF-18-PI', 21.9512, { priceInclude: true });
}, 180_000);

afterAll(async () => {
  await db.close();
});

describe('a single tax on a net amount', () => {
  it('grosses up the net: 1 000.00 at 18 % carries 219.51, on a base of 1 219.51', async () => {
    const document = await book([{ unitPrice: 1000, taxCode: 'ZZ-IN-18' }]);
    expect(await totals(document)).toEqual({ untaxed: '1000.00', tax: '219.51', total: '1219.51' });
    expect(await summary(document)).toEqual([
      { code: 'ZZ-IN-18', base: '1000.00', tax: '219.51', taxable: '1219.51', inside: true },
    ]);

    const ledger = await ledgerOf(db, document);
    const receivable = ledger.find((l) => !l.tax_line && l.box === null && Number(l.debit) > 0)!;
    expect(receivable.debit).toBe('1219.51');
    expect(ledger.find((l) => l.code === income[0])).toMatchObject({ credit: '1000.00', box: 'ZB', box_amount: '1219.51' });
    expect(ledger.find((l) => l.code === liability)).toMatchObject({ credit: '219.51', box: 'ZT', box_amount: '219.51' });
  });

  it('stays exact where the rounded effective rate drifts', async () => {
    const exact = await book([{ unitPrice: 1_000_000, taxCode: 'ZZ-IN-18' }]);
    const effective = await book([{ unitPrice: 1_000_000, taxCode: 'ZZ-EFF-18' }]);
    // 1 000 000 x 18 / 82 = 219 512.195…; 21.9512 % of it is 219 512.00.
    expect((await totals(exact)).tax).toBe('219512.20');
    expect((await totals(effective)).tax).toBe('219512.00');
  });

  it('a draft with no tax computed inside its base reports its net as its taxable amount', async () => {
    const document = await book([{ unitPrice: 500, taxCode: 'ZZ-ON-10' }]);
    expect(await summary(document)).toEqual([
      { code: 'ZZ-ON-10', base: '500.00', tax: '50.00', taxable: '500.00', inside: false },
    ]);
  });
});

describe('the box of the base', () => {
  it('shares the tax over the ledger lines so the boxes add up to the base plus the tax', async () => {
    // Three lines of 10.01 on three accounts. Each alone would carry
    // 10.01 x 18 / 82 = 2.197… = 2.20, three times 6.60; the group carries
    // 30.03 x 18 / 82 = 6.591… = 6.59, and the boxes share those 6.59.
    const document = await book(income.map((accountCode) => ({ unitPrice: 10.01, taxCode: 'ZZ-IN-18', accountCode })));
    expect(await summary(document)).toEqual([
      { code: 'ZZ-IN-18', base: '30.03', tax: '6.59', taxable: '36.62', inside: true },
    ]);
    const bases = (await ledgerOf(db, document)).filter((l) => l.box === 'ZB').map((l) => l.box_amount);
    expect(bases).toEqual(['12.21', '12.20', '12.21']);
  });
});

describe('a price that holds a tax computed inside its base', () => {
  it('takes the price times the rate: 100.00 holds 18.00 on a net of 82.00', async () => {
    const document = await book([{ unitPrice: 100, taxCode: 'ZZ-IN-18-PI' }]);
    expect(await totals(document)).toEqual({ untaxed: '82.00', tax: '18.00', total: '100.00' });
    expect(await summary(document)).toEqual([
      { code: 'ZZ-IN-18-PI', base: '82.00', tax: '18.00', taxable: '100.00', inside: true },
    ]);
    expect((await ledgerOf(db, document)).find((l) => l.box === 'ZB')!.box_amount).toBe('100.00');
  });

  it('rounds the half-way figure the effective rate misses: 0.25 at 18 % holds 0.05', async () => {
    // 0.25 x 18 % is exactly 0.045, half up 0.05. Taken out at 21.9512 % it is
    // 0.04499996…, which rounds to 0.04.
    const exact = await book([{ unitPrice: 0.25, taxCode: 'ZZ-IN-18-PI' }]);
    const effective = await book([{ unitPrice: 0.25, taxCode: 'ZZ-EFF-18-PI' }]);
    expect(await totals(exact)).toEqual({ untaxed: '0.20', tax: '0.05', total: '0.25' });
    expect((await totals(effective)).tax).toBe('0.04');
  });

  it('shares the base of a group over its lines and keeps the price that was quoted', async () => {
    const document = await book([
      { unitPrice: 33.33, taxCode: 'ZZ-IN-18-PI' },
      { unitPrice: 33.33, taxCode: 'ZZ-IN-18-PI' },
      { unitPrice: 33.34, taxCode: 'ZZ-IN-18-PI' },
    ]);
    expect(await totals(document)).toEqual({ untaxed: '82.00', tax: '18.00', total: '100.00' });
  });
});

describe('rounding', () => {
  it('rounds a net figure that falls half way as the currency says', async () => {
    // 0.02 x 20 / 80 is exactly 0.005, and the company rounds half up.
    const document = await book([{ unitPrice: 0.02, taxCode: 'ZZ-IN-20' }]);
    expect(await totals(document)).toEqual({ untaxed: '0.02', tax: '0.01', total: '0.03' });
  });
});

describe('a credit note', () => {
  it('is the invoice with its signs flipped, to the cent', async () => {
    const invoice = await book([{ unitPrice: 1000, taxCode: 'ZZ-IN-18' }]);
    const credit = await book([{ unitPrice: 1000, taxCode: 'ZZ-IN-18' }], 'sale_credit_note');
    expect(await totals(credit)).toEqual(await totals(invoice));
    const ledger = await ledgerOf(db, credit);
    expect(ledger.find((l) => l.code === income[0])).toMatchObject({ debit: '1000.00', box: 'ZB', box_amount: '-1219.51' });
    expect(ledger.find((l) => l.code === liability)).toMatchObject({ debit: '219.51', box: 'ZT', box_amount: '-219.51' });
  });
});

describe('beside a tax added on top', () => {
  it('computes each group on its own and the document totals both', async () => {
    const document = await book([
      { unitPrice: 1000, taxCode: 'ZZ-IN-18' },
      { unitPrice: 500, taxCode: 'ZZ-ON-10' },
    ]);
    expect(await summary(document)).toEqual([
      { code: 'ZZ-IN-18', base: '1000.00', tax: '219.51', taxable: '1219.51', inside: true },
      { code: 'ZZ-ON-10', base: '500.00', tax: '50.00', taxable: '500.00', inside: false },
    ]);
    expect(await totals(document)).toEqual({ untaxed: '1500.00', tax: '269.51', total: '1769.51' });
  });
});

describe('the refusals', () => {
  it('refuses a fixed amount computed inside its base', async () => {
    const message = await expectError(
      db,
      `insert into taxes (company_id, code, name, amount_type, amount, base_includes_tax)
       values ($1, 'ZZ-FIXED', 'fixed', 'fixed', 5, true)`,
      [company.companyId],
    );
    expect(message).toMatch(/taxes_base_includes_tax_needs_a_rate/);
  });

  it('refuses a rate of one hundred per cent or more', async () => {
    const message = await expectError(
      db,
      `insert into taxes (company_id, code, name, amount_type, amount, base_includes_tax)
       values ($1, 'ZZ-100', 'whole', 'percent', 100, true)`,
      [company.companyId],
    );
    expect(message).toMatch(/taxes_base_includes_tax_needs_a_rate/);
  });

  it('refuses a group whose lines disagree, by name', async () => {
    number += 1;
    const document = await newDocument(db, company.companyId, {
      docType: 'sale_invoice',
      number: `ZZ-${number}`,
      contactId: customer,
      lines: [
        { unitPrice: 10, taxCode: 'ZZ-ON-10', accountCode: income[0]! },
        { unitPrice: 10, taxCode: 'ZZ-ON-10', accountCode: income[0]! },
      ],
    });
    // The only way to build one: the snapshot of a single line moved, which
    // the line's own trigger would put back; it is switched off to get there.
    await withoutTrigger(db, 'document_lines', 'document_lines_amount_untaxed', () =>
      db.query(
        `update document_lines set base_includes_tax = true
          where id = (select id from document_lines where document_id = $1 order by sequence limit 1)`,
        [document],
      ),
    );
    const message = await expectError(db, `select post_document($1)`, [document]);
    expect(message).toMatch(/mixed_base_includes_tax/);
  });

  it('snapshots the key on the line and keeps it once the document is posted', async () => {
    const document = await book([{ unitPrice: 1000, taxCode: 'ZZ-IN-18' }]);
    await db.query(`update taxes set base_includes_tax = false where company_id = $1 and code = 'ZZ-IN-18'`, [
      company.companyId,
    ]);
    try {
      expect(await summary(document)).toEqual([
        { code: 'ZZ-IN-18', base: '1000.00', tax: '219.51', taxable: '1219.51', inside: true },
      ]);
    } finally {
      await db.query(`update taxes set base_includes_tax = true where company_id = $1 and code = 'ZZ-IN-18'`, [
        company.companyId,
      ]);
    }
  });
});

describe('the key in a pack', () => {
  /** A pack with a percentage tax below 100, copied to a directory of its own. */
  const source = packWhere('has a percentage tax below one hundred', (p) =>
    p.taxes.some((t) => t.amount_type === 'percent' && t.rate > 0 && t.rate < 100),
  );
  const target = source.taxes.find((t) => t.amount_type === 'percent' && t.rate > 0 && t.rate < 100)!;

  async function copyWith(change: (tax: Record<string, unknown>) => void): Promise<string> {
    const dir = await mkdtemp(join(tmpdir(), 'ekwo-inside-base-'));
    await cp(join(packsDir(), 'schema'), join(dir, 'schema'), { recursive: true });
    await cp(join(packsDir(), source.slug), join(dir, source.slug), { recursive: true });
    const file = join(dir, source.slug, 'taxes.json');
    const taxes = JSON.parse(await readFile(file, 'utf8')) as Record<string, unknown>[];
    change(taxes.find((t) => t['code'] === target.code)!);
    await writeFile(file, JSON.stringify(taxes), 'utf8');
    return dir;
  }

  it('is declared by no pack of this checkout, so every seed is what it was', () => {
    expect(allPacks.filter((p) => p.taxes.some((t) => t.base_includes_tax)).map((p) => p.slug)).toEqual([]);
    expect(compilePack(source)).not.toMatch(/base_includes_tax/);
  });

  it('is read, compiled into one statement, and reaches the tax a company installs', async () => {
    const pack = await readPack(source.slug, await copyWith((t) => (t['base_includes_tax'] = true)));
    expect(pack.taxes.find((t) => t.code === target.code)!.base_includes_tax).toBe(true);
    const seed = compilePack(pack);
    expect(seed).toMatch(/update tax_templates\s+set base_includes_tax = code = any/);

    await db.exec(seed);
    const installed = await newCompany(db, { country: source.manifest.country, name: 'Inside Base Install' });
    const flagged = await rows<{ code: string }>(
      db,
      `select code from taxes where company_id = $1 and base_includes_tax order by code`,
      [installed.companyId],
    );
    expect(flagged.map((t) => t.code)).toEqual([target.code]);
    // Retired by saying false on it, which writes the statement again with
    // nothing in it.
    const retired = await readPack(source.slug, await copyWith((x) => (x['base_includes_tax'] = false)));
    await db.exec(compilePack(retired));
    const left = await rows(
      db,
      `select code from tax_templates where country = $1 and base_includes_tax`,
      [source.manifest.country],
    );
    expect(left).toEqual([]);
  });

  it('is refused by the check on a fixed amount and on a rate of one hundred', async () => {
    const fixed = await copyWith((t) => {
      t['base_includes_tax'] = true;
      t['amount_type'] = 'fixed';
    });
    await expect(readPack(source.slug, fixed)).rejects.toThrow(/a tax computed inside its own base needs a percentage below 100/);
    const whole = await copyWith((t) => {
      t['base_includes_tax'] = true;
      t['rate'] = 100;
    });
    await expect(readPack(source.slug, whole)).rejects.toThrow(/a tax computed inside its own base needs a percentage below 100/);
  });
});
