import type { PGlite } from '@electric-sql/pglite';
import { cp, mkdtemp, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { compilePack, packsDir, readPack } from '../packages/cli/src/index.js';
import { expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, type Fixture } from './helpers/factory.js';
import { allPacks, somePack } from './helpers/packs.js';

/**
 * A line names what was sold, by the classification of its country
 * (decision 0078).
 *
 * The code is an attribute of the line (`document_lines.attributes`,
 * pre-filled from `products.attributes`); the pack declares which attributes
 * are classifications and the pattern of their codes. What is proved here:
 *
 *   1. a line keeps its code among its attributes, and takes its product's;
 *   2. a code off its pattern is refused by name, on the line, on the product
 *      and on a line that takes it from its product;
 *   3. an attribute the pack does not declare passes, as before;
 *   4. a posted line keeps the code it was issued with;
 *   5. the key of a pack: read, refused by `ekwo pack check` where it cannot
 *      hold, compiled into a seed that leaves every other pack's unchanged.
 *
 * The classifications are invented — `zz_eight` and `zz_six` — and declared
 * for the country of whichever pack the company is installed with. No
 * country's nomenclature is under test.
 */

let db: PGlite;
let company: Fixture;
let country: string;
let customer: string;
let income: string;

let number = 0;
async function draft(attributes: unknown, productId: string | null = null): Promise<string> {
  number += 1;
  const document = await newDocument(db, company.companyId, {
    docType: 'sale_invoice',
    number: `ZZ-C-${number}`,
    contactId: customer,
    lines: [],
  });
  await db.query(
    `insert into document_lines (document_id, company_id, sequence, name, quantity, unit_price,
                                 account_id, product_id, attributes)
     values ($1, $2, 10, 'Goods', 1, 100, account_id_by_code($2, $3), $4, $5)`,
    [document, company.companyId, income, productId, attributes],
  );
  return document;
}

const published = async (document: string): Promise<unknown> =>
  (await one<{ attributes: unknown }>(db, `select attributes from document_line_items where document_id = $1`, [document]))
    .attributes;

async function product(code: string, attributes: unknown): Promise<string> {
  return (
    await one<{ id: string }>(
      db,
      `insert into products (company_id, code, name, kind, currency_code, attributes)
       select $1, $2, 'Invented goods', 'goods', c.currency_code, $3 from companies c where c.id = $1
       returning id`,
      [company.companyId, code, attributes],
    )
  ).id;
}

beforeAll(async () => {
  db = await freshDatabase();
  country = (await one<{ country: string }>(db, `select country from country_defaults order by country limit 1`)).country;
  company = await newCompany(db, { country, name: 'Classification Fixture' });
  customer = await newContact(db, company.companyId, { country });
  income = (
    await one<{ code: string }>(
      db,
      `select code from accounts where company_id = $1 and account_type = 'income' order by code limit 1`,
      [company.companyId],
    )
  ).code;
  await db.query(
    `insert into classification_schemes (country, attribute, name, pattern, legal_reference, sequence)
     values ($1, 'zz_eight', 'Invented nomenclature, eight digits', '^[0-9]{8}$', 'Invented for the test', 10),
            ($1, 'zz_six', 'Invented heading, six digits', '^[0-9]{6}$', 'Invented for the test', 20)`,
    [country],
  );
}, 180_000);

afterAll(async () => {
  await db.close();
});

describe('a line carries its code among its attributes', () => {
  it('keeps it, and the line items publish it', async () => {
    const document = await draft({ zz_eight: '01234567', zz_six: '012345' });
    expect(await published(document)).toEqual({ zz_eight: '01234567', zz_six: '012345' });
  });

  it('takes the code of the product it names, and its own wins', async () => {
    const goods = await product('ZZ-GOODS', { zz_eight: '11112222' });
    expect(await published(await draft({}, goods))).toEqual({ zz_eight: '11112222' });
    expect(await published(await draft({ zz_eight: '33334444' }, goods))).toEqual({ zz_eight: '33334444' });
  });

  it('lets an attribute no classification declares pass, as before', async () => {
    const document = await draft({ zz_free_text: 'anything at all' });
    expect(await published(document)).toEqual({ zz_free_text: 'anything at all' });
  });
});

describe('the refusals', () => {
  it('refuses a code off the pattern of its classification', async () => {
    const document = await draft({});
    const refused = await expectError(
      db,
      `update document_lines set attributes = '{"zz_eight": "1234"}' where document_id = $1`,
      [document],
    );
    expect(refused).toMatch(/^classification_code_invalid: .*1234.*zz_eight/);
  });

  it('refuses a product off the pattern', async () => {
    expect(
      await expectError(
        db,
        `insert into products (company_id, code, name, currency_code, attributes)
         select $1, 'ZZ-BAD', 'Bad', c.currency_code, '{"zz_six": "12"}' from companies c where c.id = $1`,
        [company.companyId],
      ),
    ).toMatch(/^classification_code_invalid/);
  });

  it('checks the code a line takes from its product as the line\'s own', async () => {
    const goods = await product('ZZ-LATER', {});
    // The product is changed behind the check's back — a pattern declared
    // after the product was written — and the line that takes it is refused.
    await db.query(`alter table products disable trigger products_check_classifications`);
    await db.query(`update products set attributes = '{"zz_six": "99"}' where id = $1`, [goods]);
    await db.query(`alter table products enable trigger products_check_classifications`);
    await expect(draft({}, goods)).rejects.toThrow(/^classification_code_invalid/);
  });

  it('keeps the code of a posted line', async () => {
    const document = await draft({ zz_eight: '01234567' });
    await db.query(`update document_lines set tax_id = null where document_id = $1`, [document]);
    await db.query(`select post_document($1)`, [document]);
    expect(
      await expectError(db, `update document_lines set attributes = '{"zz_eight": "76543210"}' where document_id = $1`, [document]),
    ).toMatch(/^document_posted/);
    expect(await published(document)).toEqual({ zz_eight: '01234567' });
  });
});

describe('the key in a pack', () => {
  const declared = [
    { attribute: 'zz_eight', name: 'Invented nomenclature', pattern: '^[0-9]{8}$', legal_reference: 'Invented for the test' },
  ];

  async function copyWith(classifications: unknown): Promise<string> {
    const dir = await mkdtemp(join(tmpdir(), 'ekwo-classifications-'));
    await cp(join(packsDir(), 'schema'), join(dir, 'schema'), { recursive: true });
    await cp(join(packsDir(), somePack.slug), join(dir, somePack.slug), { recursive: true });
    const file = join(dir, somePack.slug, 'pack.json');
    const manifest = JSON.parse(await readFile(file, 'utf8')) as Record<string, unknown>;
    await writeFile(file, JSON.stringify({ ...manifest, classifications }), 'utf8');
    return dir;
  }

  it('is declared by no pack of this checkout, so every seed is what it was', () => {
    expect(allPacks.filter((p) => p.classifications.length > 0).map((p) => p.slug)).toEqual([]);
    expect(compilePack(somePack)).not.toMatch(/classification_schemes/);
  });

  it('is read and compiled, and a classification the pack stops declaring is removed', async () => {
    const pack = await readPack(somePack.slug, await copyWith(declared));
    expect(pack.classifications.map((c) => c.attribute)).toEqual(['zz_eight']);
    await db.exec(compilePack(pack));
    const attributes = async () =>
      (await rows<{ attribute: string }>(db, `select attribute from classification_schemes where country = $1 order by attribute`, [
        somePack.manifest.country,
      ])).map((s) => s.attribute);
    expect(await attributes()).toContain('zz_eight');

    await db.exec(compilePack(await readPack(somePack.slug, await copyWith([]))));
    expect(await attributes()).not.toContain('zz_eight');
  });

  it('is refused by the check where an attribute or its pattern cannot hold', async () => {
    const unanchored = await copyWith([{ ...declared[0], pattern: '[0-9]{8}' }]);
    await expect(readPack(somePack.slug, unanchored)).rejects.toThrow(/not an anchored regular expression/);
    const twice = await copyWith([declared[0], declared[0]]);
    await expect(readPack(somePack.slug, twice)).rejects.toThrow(/declared twice/);
    const upper = await copyWith([{ ...declared[0], attribute: 'ZZ8' }]);
    await expect(readPack(somePack.slug, upper)).rejects.toThrow(/pack_invalid/);
  });
});
