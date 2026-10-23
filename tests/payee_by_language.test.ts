import { cp, mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { readPack } from '../packages/cli/src/index.js';
import { freshDatabase, one, rows } from './helpers/db.js';
import { newCompany } from './helpers/factory.js';
import { allPacks, packWhere, packsRoot } from './helpers/packs.js';

/**
 * The administration, named in the company's language (`20261023160200`).
 *
 * A language file of a pack may carry `tax_payee` — the name the
 * administration publishes in that language and the register entry it is
 * read in — compiled into `country_defaults.tax_payee_name_i18n`.
 * `tax_payee()` creates the contact under the company's language, and falls
 * back to the pack's own name where that language gives none.
 *
 * The pack under test is whichever one translates its administration; every
 * name and language comes from its own files.
 */

interface Payee {
  name: string;
  source: string;
}

const pack = packWhere(
  'names its administration in a language other than its own',
  (p) =>
    p.manifest.defaults['tax_payee'] !== undefined &&
    typeof p.manifest.defaults.roles['tax_payable'] === 'string' &&
    Object.keys(p.labels.tax_payee).length > 0,
);

const OWN = pack.manifest.defaults['tax_payee'] as Payee;
const [LANGUAGE, TRANSLATED] = Object.entries(pack.labels.tax_payee)[0]!;
const PAYABLE = pack.manifest.defaults.roles['tax_payable'] as string;

let db: PGlite;

async function payees(companyId: string): Promise<{ id: string; name: string }[]> {
  return rows<{ id: string; name: string }>(
    db,
    `select k.id, k.name from contacts k
      where k.company_id = $1 and k.active
        and k.payable_account_id = (select id from accounts where company_id = $1 and code = $2)
      order by k.created_at`,
    [companyId, PAYABLE],
  );
}

beforeAll(async () => {
  db = await freshDatabase();
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('the name of the administration in a language of the pack', () => {
  it('is read from the register entry the language file names', () => {
    const keys = new Set(
      (pack.manifest.certification?.sources ?? []).map((s) => (typeof s === 'string' ? s : s.key)),
    );
    for (const translated of Object.values(pack.labels.tax_payee)) {
      expect(keys.has(translated.source)).toBe(true);
      expect(translated.name.length).toBeGreaterThan(0);
    }
  });

  it('reaches country_defaults by language, beside the pack’s own', async () => {
    const row = await one<{ name: string; names: Record<string, string> }>(
      db,
      `select tax_payee_name as name, tax_payee_name_i18n as names from country_defaults where country = $1`,
      [pack.manifest.country],
    );
    expect(row.name).toBe(OWN.name);
    expect(row.names[LANGUAGE]).toBe(TRANSLATED.name);
  });

  it('is empty for a pack that translates nothing', async () => {
    const silent = allPacks.find(
      (p) => p.manifest.defaults['tax_payee'] !== undefined && Object.keys(p.labels.tax_payee).length === 0,
    );
    if (silent === undefined) return;
    const row = await one<{ names: Record<string, string> }>(
      db,
      `select tax_payee_name_i18n as names from country_defaults where country = $1`,
      [silent.manifest.country],
    );
    expect(row.names).toEqual({});
  });
});

describe('the administration of a company', () => {
  it('is created under the name of the company’s language', async () => {
    // country-literal: the company is installed in the pack under test, which
    // is whichever one translates its administration.
    const fx = await newCompany(db, { country: pack.manifest.country, language: LANGUAGE, name: 'Translated' });
    // The factory installs the labels in that language; the company's own
    // column is what create_company() writes from the same choice.
    await db.query(`update companies set language = $2 where id = $1`, [fx.companyId, LANGUAGE]);
    const payee = await one<{ name: string }>(db, `select name from tax_payee($1)`, [fx.companyId]);
    expect(payee.name).toBe(TRANSLATED.name);
  });

  it('falls back to the pack’s own name in a language the pack does not translate it into', async () => {
    // country-literal: as above, installed in the pack's own language.
    const fx = await newCompany(db, { country: pack.manifest.country, name: 'Own Language' });
    const payee = await one<{ name: string }>(db, `select name from tax_payee($1)`, [fx.companyId]);
    expect(payee.name).toBe(OWN.name);
  });

  it('is recognised among several by a name of any language of the pack', async () => {
    // country-literal: as above.
    const fx = await newCompany(db, { country: pack.manifest.country, name: 'Several' });
    for (const name of ['Somebody else on the account', TRANSLATED.name]) {
      await db.query(
        `insert into contacts (company_id, name, contact_type, is_company, payable_account_id)
         values ($1, $2, 'supplier', true, (select id from accounts where company_id = $1 and code = $3))`,
        [fx.companyId, name, PAYABLE],
      );
    }
    const payee = await one<{ name: string }>(db, `select name from tax_payee($1)`, [fx.companyId]);
    // The company keeps its books in the pack's own language, and the contact
    // under the translated name is still its administration.
    expect(payee.name).toBe(TRANSLATED.name);
    expect(await payees(fx.companyId)).toHaveLength(2);
  });
});

describe('a language file that names the administration', () => {
  let dir: string;
  let file: string;
  let original: Record<string, unknown>;

  beforeAll(async () => {
    dir = await mkdtemp(join(tmpdir(), 'ekwo-payee-i18n-'));
    await cp(join(packsRoot, 'schema'), join(dir, 'schema'), { recursive: true });
    await cp(join(packsRoot, pack.slug), join(dir, pack.slug), { recursive: true });
    file = join(dir, pack.slug, 'i18n', `${LANGUAGE}.json`);
    original = JSON.parse(await readFile(file, 'utf8')) as Record<string, unknown>;
  });

  afterAll(async () => {
    await rm(dir, { recursive: true, force: true });
  });

  const refusal = async (): Promise<string> =>
    readPack(pack.slug, dir).then(
      () => 'accepted',
      (error: Error) => error.message,
    );

  it('is refused with a source the register does not hold', async () => {
    await writeFile(file, JSON.stringify({ ...original, tax_payee: { name: TRANSLATED.name, source: 'no-such-entry' } }));
    const said = await refusal();
    expect(said).toContain(`i18n/${LANGUAGE}.json tax_payee`);
    expect(said).toContain('no-such-entry');
  });

  it('is refused without a source', async () => {
    await writeFile(file, JSON.stringify({ ...original, tax_payee: { name: TRANSLATED.name } }));
    expect(await refusal()).toContain('source');
  });

  it('is refused where the manifest names no administration to translate', async () => {
    await writeFile(file, JSON.stringify(original));
    const manifestFile = join(dir, pack.slug, 'pack.json');
    const manifest = JSON.parse(await readFile(manifestFile, 'utf8')) as {
      defaults: Record<string, unknown>;
    };
    const { tax_payee: _dropped, ...defaults } = manifest.defaults;
    await writeFile(manifestFile, JSON.stringify({ ...manifest, defaults }));
    expect(await refusal()).toContain('names no administration');
  });
});
