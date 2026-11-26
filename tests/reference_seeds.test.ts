/**
 * The seeds of `currencies` and `territories` are written from the packs.
 *
 * Every country declares its currency and its territories in
 * `packs/<cc>/reference.json`, and `ekwo pack build` writes
 * `supabase/seed/00_currencies.sql` and `supabase/seed/00_territories.sql`
 * from them — see `packages/cli/src/pack/reference.ts`. This file holds the
 * repository to that, pins the rule of who declares which row in a checkout
 * made up for the purpose, and holds the generated seeds to the ones written
 * by hand until release 0.27.0, frozen in `tests/fixtures/seeds-0.27.0/`: an
 * installation seeded by those reaches, by re-applying today's, the same rows
 * a new installation gets.
 */

import { cp, mkdir, mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import type { PGlite } from '@electric-sql/pglite';
import { afterEach, describe, expect, it } from 'vitest';
import { PackError } from '../packages/cli/src/pack/read.js';
import { readReference, referenceSeeds, territoriesOf } from '../packages/cli/src/pack/reference.js';
import { parseTerritorySeed, readTerritories } from '../packages/cli/src/pack/territories.js';
import { freshDatabase, repoRoot } from './helpers/db.js';

const frozen = join(repoRoot, 'tests', 'fixtures', 'seeds-0.27.0');
const seedDir = join(repoRoot, 'supabase', 'seed');

describe('the reference seeds of this repository', () => {
  it('are the output of packs/*/reference.json', async () => {
    const seeds = await referenceSeeds(false, repoRoot);
    expect(seeds.map((s) => s.file)).toEqual(['00_currencies.sql', '00_territories.sql']);
    for (const seed of seeds) {
      expect(seed.state, `${seed.file} — run \`ekwo pack build --all\``).toBe('unchanged');
    }
  });

  it('give every pack its own country and its own currency', async () => {
    const data = await readReference(join(repoRoot, 'packs'));
    const territories = new Set(territoriesOf(data).map((t) => t.code));
    for (const pack of data.packs) {
      if (pack.country !== null) expect(territories.has(pack.country), pack.slug).toBe(true);
    }
  });

  it('are what `pack check` reads for a territory, whether from the packs or from the seed', async () => {
    const fromPacks = await readTerritories(repoRoot);
    const fromSeed = parseTerritorySeed(await readFile(join(seedDir, '00_territories.sql'), 'utf8'));
    expect(fromSeed).toEqual(fromPacks);
  });
});

describe('a seed written by hand, read by this release', () => {
  it('parses into the same territories as the generated one, whatever the order', async () => {
    const byCode = (a: { code: string }, b: { code: string }) => (a.code < b.code ? -1 : a.code > b.code ? 1 : 0);
    const old = parseTerritorySeed(await readFile(join(frozen, '00_territories.sql'), 'utf8'));
    const now = await readTerritories(repoRoot);
    // Every territory 0.27.0 carried is still carried; a pack may add one.
    const current = new Map(now.map((t) => [t.code, t]));
    for (const territory of old.sort(byCode)) expect(current.has(territory.code), territory.code).toBe(true);
  });

  it('leaves an installation that applied it converging on the generated rows', async () => {
    async function rows(db: PGlite): Promise<string> {
      const currencies = await db.query(`select code, name, symbol, decimal_places from currencies order by code`);
      const territories = await db.query(
        `select code, code_source::text, name, parent_code, eu_vat_scope::text, eu_vat_from::text,
                eu_vat_to::text, vat_prefix, outside_parent_tax, legal_reference
           from territories order by code`,
      );
      return JSON.stringify({ currencies: currencies.rows, territories: territories.rows });
    }
    const currencySeed = await readFile(join(seedDir, '00_currencies.sql'), 'utf8');
    const territorySeed = await readFile(join(seedDir, '00_territories.sql'), 'utf8');

    // An installation seeded at 0.27.0, then given this release's seeds.
    const upgraded = await freshDatabase({ seed: false });
    await upgraded.exec(await readFile(join(frozen, '00_currencies.sql'), 'utf8'));
    await upgraded.exec(await readFile(join(frozen, '00_territories.sql'), 'utf8'));
    await upgraded.exec(currencySeed);
    await upgraded.exec(territorySeed);

    // A new installation, given this release's seeds alone — twice, since a
    // seed is re-applied on every upgrade.
    const fresh = await freshDatabase({ seed: false });
    await fresh.exec(currencySeed);
    await fresh.exec(territorySeed);
    await fresh.exec(territorySeed);

    try {
      expect(await rows(upgraded)).toBe(await rows(fresh));
    } finally {
      await upgraded.close();
      await fresh.close();
    }
  });
});

describe('the generator, in a checkout of two packs', () => {
  let root: string;

  afterEach(async () => {
    await rm(root, { recursive: true, force: true });
  });

  const territory = (code: string, parent: string | null = null) => ({
    code,
    code_source: parent === null ? 'iso_3166_1' : 'named',
    name: `Place ${code}`,
    parent_code: parent,
    eu_vat_scope: 'none',
    eu_vat_from: null,
    eu_vat_to: null,
    vat_prefix: null,
    outside_parent_tax: parent !== null,
    legal_reference: `A made-up text for ${code}`,
  });
  const currency = (code: string) => ({ code, name: `Unit ${code}`, symbol: '¤', decimal_places: 2 });

  /** Packs `aa` (country XA) and `zz` (country XZ), each with its own reference file; generic holds a shared unit. */
  async function checkout(files: Record<string, unknown> = {}): Promise<void> {
    root = await mkdtemp(join(tmpdir(), 'ekwo-reference-'));
    await mkdir(join(root, 'packs', 'schema'), { recursive: true });
    await cp(join(repoRoot, 'packs', 'schema', 'pack.1.json'), join(root, 'packs', 'schema', 'pack.1.json'));
    await mkdir(join(root, 'supabase', 'seed'), { recursive: true });
    const references: Record<string, unknown> = {
      generic: { currencies: [currency('XQQ')] },
      aa: { currencies: [currency('XAA')], territories: [territory('XA'), territory('XA-ISLE', 'XA')] },
      zz: { territories: [territory('XZ')] },
      ...files,
    };
    const manifests: Record<string, Record<string, unknown>> = {
      aa: { country: 'XA', defaults: { currency: 'XAA' } },
      zz: { country: 'XZ', defaults: { currency: 'XQQ' } },
    };
    for (const slug of ['generic', 'aa', 'zz']) {
      await mkdir(join(root, 'packs', slug), { recursive: true });
      if (manifests[slug] !== undefined) {
        await writeFile(join(root, 'packs', slug, 'pack.json'), JSON.stringify(manifests[slug]));
      }
      if (references[slug] !== undefined) {
        await writeFile(join(root, 'packs', slug, 'reference.json'), JSON.stringify(references[slug]));
      }
    }
  }

  async function refusal(): Promise<string> {
    try {
      await referenceSeeds(false, root);
    } catch (error) {
      expect(error).toBeInstanceOf(PackError);
      return (error as Error).message;
    }
    throw new Error('the generator accepted what it should have refused');
  }

  it('writes both seeds, then finds them unchanged, then refuses a hand edit', async () => {
    await checkout();
    expect((await referenceSeeds(false, root)).map((s) => s.state)).toEqual(['stale', 'stale']);
    expect((await referenceSeeds(true, root)).map((s) => s.state)).toEqual(['written', 'written']);
    expect((await referenceSeeds(false, root)).map((s) => s.state)).toEqual(['unchanged', 'unchanged']);

    const territories = await readFile(join(root, 'supabase', 'seed', '00_territories.sql'), 'utf8');
    expect(territories).toContain('-- packs/aa/reference.json');
    expect(territories).toContain("('XA-ISLE', 'named', 'Place XA-ISLE', 'XA', 'none', null, null, null, true,");
    const currencies = await readFile(join(root, 'supabase', 'seed', '00_currencies.sql'), 'utf8');
    expect(currencies.indexOf("('XQQ'")).toBeLessThan(currencies.indexOf("('XAA'"));
    expect(currencies).toContain('on conflict (code) do nothing;');

    // A country pull request that appends its row to the seed by hand.
    await writeFile(
      join(root, 'supabase', 'seed', '00_currencies.sql'),
      `${currencies}insert into currencies (code, name, symbol, decimal_places) values ('XBB', 'B', 'b', 2);\n`,
    );
    expect((await referenceSeeds(false, root)).map((s) => s.state)).toEqual(['stale', 'unchanged']);
  });

  it('refuses a code two packs declare', async () => {
    await checkout({ zz: { territories: [territory('XZ'), territory('XA-ISLE', 'XA')] } });
    expect(await refusal()).toContain('territory XA-ISLE is declared by packs/aa and packs/zz');
  });

  it('refuses a currency outside the pack of the country its code begins with', async () => {
    await checkout({ zz: { currencies: [currency('XAB')], territories: [territory('XZ')] } });
    expect(await refusal()).toContain('currency XAB is declared by packs/zz; it belongs to packs/aa');
  });

  it('refuses a territory outside the pack of the country it lies in', async () => {
    await checkout({ zz: { territories: [territory('XZ'), territory('XA-NORTH', 'XA')] } });
    expect(await refusal()).toContain('territory XA-NORTH is declared by packs/zz; it belongs to packs/aa');
  });

  it('refuses a pack whose country or currency has no row', async () => {
    await checkout({ zz: {}, generic: {} });
    const message = await refusal();
    expect(message).toContain('packs/zz: its country XZ has no row in territories');
    expect(message).toContain('packs/zz: defaults.currency XQQ has no row in currencies — declare it in packs/generic/reference.json');
  });

  it('refuses a parent nobody declares', async () => {
    await checkout({ zz: { territories: [territory('XZ'), territory('XZ-EAST', 'XY')] } });
    expect(await refusal()).toContain('territory XZ-EAST (packs/zz) names the parent XY, which no pack declares');
  });

  it('refuses a file the schema does not accept, and names the pack', async () => {
    await checkout({ zz: { territories: [territory('XZ')], rates: [] } });
    expect(await refusal()).toMatch(/packs\/zz\/reference\.json.*rates/);
  });
});
