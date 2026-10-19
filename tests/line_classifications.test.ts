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
 * The pack declares the schemes its documents use — a customs nomenclature at
 * eight digits, its six-digit heading — and a document line or a product
 * carries `{"<scheme>": "<code>"}`. What is proved here:
 *
 *   1. a line keeps its codes, and `document_line_items` publishes them;
 *   2. a line that names a product takes the product's, and its own wins;
 *   3. a scheme the pack does not declare, a code off its pattern and a code
 *      that is not a text are each refused by name;
 *   4. a posted line keeps the codes it was issued with;
 *   5. the key of a pack: read, refused by `ekwo pack check` where it cannot
 *      hold, compiled into a seed that leaves every other pack's unchanged.
 *
 * The schemes are invented — `ZZ8` and `ZZ6` — and declared for the country of
 * whichever pack the company is installed with. No country's nomenclature is
 * under test.
 */

let db: PGlite;
let company: Fixture;
let country: string;
let customer: string;
let income: string;

let number = 0;
async function draft(classifications: unknown, productId: string | null = null): Promise<string> {
  number += 1;
  const document = await newDocument(db, company.companyId, {
    docType: 'sale_invoice',
    number: `ZZ-C-${number}`,
    contactId: customer,
    lines: [],
  });
  await db.query(
    `insert into document_lines (document_id, company_id, sequence, name, quantity, unit_price,
                                 account_id, product_id, classifications)
     values ($1, $2, 10, 'Goods', 1, 100, account_id_by_code($2, $3), $4, $5)`,
    [document, company.companyId, income, productId, classifications],
  );
  return document;
}

const published = async (document: string): Promise<unknown> =>
  (await one<{ classifications: unknown }>(db, `select classifications from document_line_items where document_id = $1`, [document]))
    .classifications;

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
    `insert into classification_schemes (country, scheme, name, pattern, legal_reference, sequence)
     values ($1, 'ZZ8', 'Invented nomenclature, eight digits', '^[0-9]{8}$', 'Invented for the test', 10),
            ($1, 'ZZ6', 'Invented heading, six digits', '^[0-9]{6}$', 'Invented for the test', 20)`,
    [country],
  );
}, 180_000);

afterAll(async () => {
  await db.close();
});

describe('a line carries its codes', () => {
  it('keeps them, and the line items publish them', async () => {
    const document = await draft({ ZZ8: '01234567', ZZ6: '012345' });
    expect(await published(document)).toEqual({ ZZ8: '01234567', ZZ6: '012345' });
  });

  it('carries none by default, as an empty object', async () => {
    const document = await draft({});
    expect(await published(document)).toEqual({});
  });

  it('takes the codes of the product it names, and its own win', async () => {
    const product = await one<{ id: string }>(
      db,
      `insert into products (company_id, code, name, kind, currency_code, classifications)
       select $1, 'ZZ-GOODS', 'Invented goods', 'goods', c.currency_code, $2 from companies c where c.id = $1
       returning id`,
      [company.companyId, { ZZ8: '11112222' }],
    );
    expect(await published(await draft({}, product.id))).toEqual({ ZZ8: '11112222' });
    expect(await published(await draft({ ZZ8: '33334444' }, product.id))).toEqual({ ZZ8: '33334444' });
  });
});

describe('the refusals', () => {
  it('refuses a scheme the pack does not declare, and names the ones it does', async () => {
    const document = await draft({ ZZ8: '01234567' });
    const refused = await expectError(
      db,
      `update document_lines set classifications = '{"ZZX": "1"}' where document_id = $1`,
      [document],
    );
    expect(refused).toMatch(/^classification_scheme_unknown: .*ZZX.* it declares ZZ8, ZZ6/);
  });

  it('refuses a code off the pattern of its scheme', async () => {
    const document = await draft({});
    const refused = await expectError(
      db,
      `update document_lines set classifications = '{"ZZ8": "1234"}' where document_id = $1`,
      [document],
    );
    expect(refused).toMatch(/^classification_code_invalid: .*1234.*ZZ8/);
  });

  it('refuses a code that is not a text, and a product off the pattern', async () => {
    const document = await draft({});
    expect(
      await expectError(db, `update document_lines set classifications = '{"ZZ8": 12345678}' where document_id = $1`, [document]),
    ).toMatch(/document_lines_classifications_shape/);
    expect(
      await expectError(
        db,
        `insert into products (company_id, code, name, currency_code, classifications)
         select $1, 'ZZ-BAD', 'Bad', c.currency_code, '{"ZZ6": "12"}' from companies c where c.id = $1`,
        [company.companyId],
      ),
    ).toMatch(/^classification_code_invalid/);
  });

  it('keeps the codes of a posted line', async () => {
    const document = await draft({ ZZ8: '01234567' });
    await db.query(`update document_lines set tax_id = null where document_id = $1`, [document]);
    await db.query(`select post_document($1)`, [document]);
    expect(
      await expectError(db, `update document_lines set classifications = '{"ZZ8": "76543210"}' where document_id = $1`, [document]),
    ).toMatch(/^document_posted/);
    expect(await published(document)).toEqual({ ZZ8: '01234567' });
  });
});

describe('the key in a pack', () => {
  const declared = [
    { scheme: 'ZZ8', name: 'Invented nomenclature', pattern: '^[0-9]{8}$', legal_reference: 'Invented for the test' },
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

  it('is read and compiled, and a scheme the pack stops declaring is removed', async () => {
    const pack = await readPack(somePack.slug, await copyWith(declared));
    expect(pack.classifications.map((c) => c.scheme)).toEqual(['ZZ8']);
    await db.exec(compilePack(pack));
    const schemes = async () =>
      (await rows<{ scheme: string }>(db, `select scheme from classification_schemes where country = $1 order by scheme`, [
        somePack.manifest.country,
      ])).map((s) => s.scheme);
    expect(await schemes()).toContain('ZZ8');

    await db.exec(compilePack(await readPack(somePack.slug, await copyWith([]))));
    expect(await schemes()).not.toContain('ZZ8');
  });

  it('is refused by the check where a scheme or its pattern cannot hold', async () => {
    const unanchored = await copyWith([{ ...declared[0], pattern: '[0-9]{8}' }]);
    await expect(readPack(somePack.slug, unanchored)).rejects.toThrow(/not an anchored regular expression/);
    const twice = await copyWith([declared[0], declared[0]]);
    await expect(readPack(somePack.slug, twice)).rejects.toThrow(/declared twice/);
    const lower = await copyWith([{ ...declared[0], scheme: 'zz8' }]);
    await expect(readPack(somePack.slug, lower)).rejects.toThrow(/pack_invalid/);
  });
});
