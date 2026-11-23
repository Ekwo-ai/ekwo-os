/**
 * A pack gives a document number the shape its law prescribes, and a
 * company's own numbering is held to it.
 *
 * Nothing here expects a country. The packs that give a shape are found by
 * what they declare; the refusals are made on the country of the test
 * company, given a shape of invented values for the duration of a test, and
 * the reading of a shape is the same on both sides — the database's
 * `number_shape_refusal()` and the `numberShapeRefusal()` of `ekwo pack check`.
 */

import { cp, mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import { numberShapeRefusal, readPack, type PackNumberShape } from '../packages/cli/src/index.js';
import { expectError, freshDatabase, one } from './helpers/db.js';
import { newCompany } from './helpers/factory.js';
import { packsRoot, packsWhere, somePack } from './helpers/packs.js';

let db: PGlite;
let companyId: string;
let country: string;

beforeAll(async () => {
  db = await freshDatabase();
  ({ companyId } = await newCompany(db, { name: 'Numérotation SRL' }));
  ({ country } = await one<{ country: string }>(db, `select fiscal_country as country from companies where id = $1`, [
    companyId,
  ]));
});

afterAll(async () => {
  await db.close();
});

afterEach(async () => {
  await db.query(`update country_defaults set number_shape = null where country = $1`, [country]);
  await db.query(`update journals set number_prefix = null where company_id = $1`, [companyId]);
});

async function giveShape(shape: PackNumberShape): Promise<void> {
  // Straight to the column: the update of companies below must meet a shape
  // that was there before it, as a pack seed leaves it.
  await db.query(`update country_defaults set number_shape = $2::jsonb where country = $1`, [
    country,
    JSON.stringify(shape),
  ]);
}

async function refusal(sql: string, params: unknown[]): Promise<string> {
  return expectError(db, sql, params);
}

describe('the packs that give a document number a shape', () => {
  const shaped = packsWhere('that gives a document number a shape', (pack) => pack.documents.number_shape !== null);

  it('cite the law they read it in, and their own pattern fits it with every journal they carry', () => {
    for (const pack of shaped) {
      expect(pack.documents.numbering_reference.legal_reference?.length ?? 0).toBeGreaterThan(0);
      for (const journal of pack.manifest.journals) {
        expect(numberShapeRefusal(pack.documents.number_shape!, pack.documents.number_format!, journal.code)).toBeNull();
      }
    }
  });

  it('reach the country model, and a company of the country can take the pack pattern as its own', async () => {
    for (const pack of shaped) {
      const row = await one<{ number_shape: PackNumberShape }>(
        db,
        `select number_shape from country_defaults where country = $1`,
        [pack.manifest.country],
      );
      expect(row.number_shape).toEqual(pack.documents.number_shape);

      const { companyId: other } = await newCompany(db, { country: pack.manifest.country, name: `Shaped ${pack.slug}` });
      await db.query(`update companies set number_format = $2 where id = $1`, [other, pack.documents.number_format]);
    }
  });
});

describe('a company of a country that gives a number a shape', () => {
  it('is refused a pattern that prints a number longer than the law allows, the journal named', async () => {
    await giveShape({ max_length: 12 });
    const message = await refusal(`update companies set number_format = '{CODE}-{YYYY}-{NNNNNN}' where id = $1`, [
      companyId,
    ]);
    expect(message).toMatch(/number_shape_refused: journal \S+: .* characters long, and a document number is at most 12/);
    await db.query(`update companies set number_format = '{CODE}{NNNNNN}' where id = $1`, [companyId]);
  });

  it('is refused a pattern written with a character the law does not allow', async () => {
    await giveShape({ characters: ['letters', 'digits', '-'] });
    expect(
      await refusal(`update companies set number_format = '{CODE}/{YYYY}/{NNNN}' where id = $1`, [companyId]),
    ).toMatch(/number_shape_refused: .* is written with "\/"/);
    await db.query(`update companies set number_format = '{CODE}-{YYYY}-{NNNN}' where id = $1`, [companyId]);
  });

  it('is refused the year in a series the law runs on from one year to the next', async () => {
    await db.query(`update companies set number_format = null where id = $1`, [companyId]);
    await giveShape({ never_restarts: true });
    expect(
      await refusal(`update companies set number_format = '{CODE}-{YY}-{NNNN}' where id = $1`, [companyId]),
    ).toMatch(/number_shape_refused: .* carries the year/);
    await db.query(`update companies set number_format = '{CODE}-{NNNNNN}' where id = $1`, [companyId]);
  });

  it('is refused a journal prefix that would print what the pattern may not', async () => {
    await db.query(`update companies set number_format = '{CODE}-{NNNN}' where id = $1`, [companyId]);
    await giveShape({ max_length: 10, characters: ['letters', 'digits', '-'] });
    const journal = await one<{ code: string }>(
      db,
      `select code from journals where company_id = $1 order by code limit 1`,
      [companyId],
    );
    expect(
      await refusal(`update journals set number_prefix = 'INVOICES' where company_id = $1 and code = $2`, [
        companyId,
        journal.code,
      ]),
    ).toMatch(new RegExp(`number_shape_refused: journal ${journal.code}: INVOICES-0000 is 13 characters long`));
    expect(
      await refusal(`update journals set number_prefix = 'F.' where company_id = $1 and code = $2`, [
        companyId,
        journal.code,
      ]),
    ).toMatch(/is written with "\."/);
    await db.query(`update journals set number_prefix = 'F' where company_id = $1 and code = $2`, [
      companyId,
      journal.code,
    ]);
  });

  it('numbers as it likes where its country gives no shape', async () => {
    await db.query(`update companies set number_format = '{CODE}/{YYYY}/{MM}/{NNNNNNNNNN}' where id = $1`, [
      companyId,
    ]);
    await db.query(`update journals set number_prefix = 'A.LONG.PREFIX' where company_id = $1 and code = (
      select min(code) from journals where company_id = $1)`, [companyId]);
  });
});

describe('the reading of a shape', () => {
  const cases: { shape: PackNumberShape; format: string; code: string }[] = [
    { shape: { max_length: 8 }, format: '{CODE}-{NNNN}', code: 'SAL' },
    { shape: { max_length: 7 }, format: '{CODE}-{NNNN}', code: 'SAL' },
    { shape: { max_length: 16 }, format: '{CODE}/{YYYY}/{MM}/{NNNNNN}', code: 'SAL' },
    { shape: { characters: ['digits'] }, format: '{CODE}{NNNN}', code: '1' },
    { shape: { characters: ['digits'] }, format: '{CODE}{NNNN}', code: 'S' },
    { shape: { characters: ['letters', 'digits', '/'] }, format: '{CODE}/{YY}/{NNNN}', code: 'Fé' },
    { shape: { characters: ['letters', 'digits'] }, format: '{CODE} {NNNN}', code: 'F' },
    { shape: { never_restarts: true }, format: '{CODE}{YYYY}{NNNN}', code: 'F' },
    { shape: { never_restarts: true }, format: '{CODE}{MM}{NNNN}', code: 'F' },
    { shape: { never_restarts: false }, format: '{CODE}{YYYY}{NNNN}', code: 'F' },
  ];

  it('is the same in the database and in ekwo pack check', async () => {
    for (const { shape, format, code } of cases) {
      const row = await one<{ refusal: string | null }>(
        db,
        `select number_shape_refusal($1::jsonb, $2, $3) as refusal`,
        [JSON.stringify(shape), format, code],
      );
      expect(row.refusal, `${JSON.stringify(shape)} ${format} ${code}`).toBe(numberShapeRefusal(shape, format, code));
    }
    // Both ways of the answer are exercised, or the comparison proves little.
    const answers = cases.map(({ shape, format, code }) => numberShapeRefusal(shape, format, code));
    expect(answers.filter((answer) => answer === null).length).toBeGreaterThan(0);
    expect(answers.filter((answer) => answer !== null).length).toBeGreaterThan(0);
  });
});

describe('ekwo pack check, on a pack that gives a number a shape', () => {
  let dir: string;
  let manifestFile: string;
  let manifest: Record<string, unknown>;

  beforeAll(async () => {
    dir = await mkdtemp(join(tmpdir(), 'ekwo-number-shape-'));
    await cp(join(packsRoot, 'schema'), join(dir, 'schema'), { recursive: true });
    await cp(join(packsRoot, somePack.slug), join(dir, somePack.slug), { recursive: true });
    manifestFile = join(dir, somePack.slug, 'pack.json');
    manifest = JSON.parse(await readFile(manifestFile, 'utf8')) as Record<string, unknown>;
  });

  afterAll(async () => {
    await rm(dir, { recursive: true, force: true });
  });

  async function check(shape: unknown, format = somePack.documents.number_format): Promise<string> {
    const documents = { ...(manifest['documents'] as Record<string, unknown>), number_format: format, number_shape: shape };
    await writeFile(manifestFile, JSON.stringify({ ...manifest, documents }), 'utf8');
    return readPack(somePack.slug, dir).then(
      () => 'accepted',
      (error: Error) => error.message,
    );
  }

  it('accepts a shape its own pattern fits', async () => {
    expect(await check({ max_length: 64 })).toBe('accepted');
  });

  it('refuses a shape its own pattern does not fit, journal by journal', async () => {
    const message = await check({ characters: ['digits'] }, '{CODE}{NNNN}');
    for (const journal of somePack.manifest.journals) {
      if (/[^0-9]/.test(journal.code)) expect(message).toContain(`journal ${journal.code}:`);
    }
    expect(await check({ never_restarts: true }, '{CODE}/{YYYY}/{NNNN}')).toMatch(/carries the year/);
  });

  it('refuses a shape that says nothing, names a character twice or a word it does not know', async () => {
    expect(await check({})).toMatch(/says nothing/);
    expect(await check({ characters: ['digits', 'digits'] })).toMatch(/names a character twice/);
    expect(await check({ characters: ['symbols'] })).toMatch(/does not match/);
    expect(await check({ max_length: 0 })).toMatch(/below 1/);
  });
});
