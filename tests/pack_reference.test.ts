/**
 * A country brings its own currency and territories.
 *
 * `supabase/seed/00_currencies.sql` and `00_territories.sql` used to take a row
 * per new country, and countries written in parallel met there. A pack now
 * carries those rows under `reference` of its `pack.json`, its own seed writes
 * them first, and the two files are closed at the number of rows they hold.
 * This file holds the three halves of that: what the seed writes, what
 * `ekwo pack check` refuses across packs, and what it refuses inside one.
 */

import { cp, mkdir, mkdtemp, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { describe, expect, it } from 'vitest';
import {
  compilePack,
  parseSeedRows,
  readPack,
  referenceIssues,
  type Pack,
  type PackReference,
} from '../packages/cli/src/index.js';
import { freshDatabase, repoRoot } from './helpers/db.js';
import { allPacks, packWhere, packsRoot } from './helpers/packs.js';

const seedDir = join(repoRoot, 'supabase', 'seed');
const currencyRows = parseSeedRows(await readFile(join(seedDir, '00_currencies.sql'), 'utf8'), 'currencies');
const territoryRows = parseSeedRows(await readFile(join(seedDir, '00_territories.sql'), 'utf8'), 'territories');

/** How many packs keep their books in each currency. */
const users = new Map<string, number>();
for (const pack of allPacks) {
  users.set(pack.manifest.defaults.currency, (users.get(pack.manifest.defaults.currency) ?? 0) + 1);
}

// A pack whose rows could have been its own: a currency nobody else keeps
// books in, a country with nothing inside it, and taxes that name no territory.
const alone = packWhere('keeps its books in a currency of its own and names no territory', (pack) => {
  const country = pack.manifest.country;
  return (
    users.get(pack.manifest.defaults.currency) === 1 &&
    pack.sources.length > 0 &&
    !territoryRows.some((row) => row['parent_code'] === country) &&
    pack.taxes.every(
      (tax) =>
        tax.applies_seller_territory === null &&
        tax.applies_buyer_territory === null &&
        tax.applies_supply_territory === null &&
        tax.jurisdiction === null,
    )
  );
});

/** Its currency and its territory, as the seed files write them today, in the form of `reference`. */
function referenceOf(pack: Pack): Required<PackReference> {
  const currency = currencyRows.find((row) => row['code'] === pack.manifest.defaults.currency)!;
  const territory = territoryRows.find((row) => row['code'] === pack.manifest.country)!;
  return {
    currency: {
      code: String(currency['code']),
      name: String(currency['name']),
      symbol: String(currency['symbol']),
      decimal_places: Number(currency['decimal_places']),
      source: pack.sources[0]!.key,
    },
    territories: [
      {
        code: String(territory['code']),
        code_source: String(territory['code_source']),
        name: String(territory['name']),
        parent_code: null,
        legal_reference: String(territory['legal_reference']),
      },
    ],
  };
}

describe('a pack seed that writes its own currency and territories', () => {
  it('writes nothing more for a pack whose rows are in the seed files', () => {
    expect(compilePack(alone)).not.toMatch(/insert into (currencies|territories)/);
  });

  it('loads on a database where nothing else wrote them, twice, and writes what the seed files would have', async () => {
    const reference = referenceOf(alone);
    const pack: Pack = { ...alone, manifest: { ...alone.manifest, reference } };
    const sql = compilePack(pack);
    expect(sql.indexOf('insert into currencies')).toBeGreaterThan(-1);
    expect(sql.indexOf('insert into territories')).toBeLessThan(sql.indexOf('insert into tax_templates'));

    const db = await freshDatabase({ seed: false, modules: false });
    try {
      await db.exec(await readFile(join(seedDir, '05_framework_generic.sql'), 'utf8'));
      await db.exec(sql);
      await db.exec(sql); // a seed is applied again on every upgrade
      const currency = await db.query<{ code: string; decimal_places: number }>(
        'select code, decimal_places from currencies',
      );
      expect(currency.rows).toEqual([
        { code: reference.currency.code, decimal_places: reference.currency.decimal_places },
      ]);
      const territory = await db.query<{ code: string; eu_vat_scope: string; legal_reference: string }>(
        'select code, eu_vat_scope::text as eu_vat_scope, legal_reference from territories',
      );
      expect(territory.rows).toEqual([
        {
          code: alone.manifest.country,
          eu_vat_scope: 'none',
          legal_reference: reference.territories[0]!.legal_reference,
        },
      ]);
    } finally {
      await db.close();
    }
  }, 120_000);
});

describe('what `ekwo pack check` refuses across the packs', () => {
  it('accepts this repository as it is', async () => {
    expect(await referenceIssues(repoRoot)).toEqual([]);
  });

  /** A checkout with the two seed files, edited, and one bare manifest per entry. */
  async function checkout(
    manifests: { country: string; currency: string; reference?: PackReference }[],
    editSeed?: (file: string, sql: string) => string,
  ): Promise<string[]> {
    const root = await mkdtemp(join(tmpdir(), 'ekwo-reference-'));
    await mkdir(join(root, 'supabase', 'seed'), { recursive: true });
    await mkdir(join(root, 'packs'), { recursive: true });
    for (const file of ['00_currencies.sql', '00_territories.sql']) {
      const sql = await readFile(join(seedDir, file), 'utf8');
      await writeFile(join(root, 'supabase', 'seed', file), editSeed ? editSeed(file, sql) : sql, 'utf8');
    }
    for (const { country, currency, reference } of manifests) {
      const dir = join(root, 'packs', country.toLowerCase());
      await mkdir(dir, { recursive: true });
      await writeFile(join(dir, 'pack.json'), JSON.stringify({ country, defaults: { currency }, reference }), 'utf8');
    }
    return referenceIssues(root);
  }

  // Codes no seed file holds, found rather than written, so that none ever is by accident.
  const freeCountry = ['Q', 'X', 'Z']
    .flatMap((first) => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').map((second) => first + second))
    .find((code) => !territoryRows.some((row) => row['code'] === code))!;
  const freeCurrency = ['XQA', 'XQB', 'XQC'].find((code) => !currencyRows.some((row) => row['code'] === code))!;
  const ownReference = (): PackReference => ({
    currency: { code: freeCurrency, name: 'A currency', symbol: 'Q', decimal_places: 2, source: 'register' },
    territories: [
      { code: freeCountry, code_source: 'iso_3166_1', name: 'A country', parent_code: null, legal_reference: 'A text' },
    ],
  });

  it('accepts a new country that carries its own rows', async () => {
    expect(await checkout([{ country: freeCountry, currency: freeCurrency, reference: ownReference() }])).toEqual([]);
  });

  it('refuses a row added to a seed file with its closing number left as it was', async () => {
    const issues = await checkout([], (file, sql) =>
      file === '00_currencies.sql'
        ? `${sql}\ninsert into currencies (code, name, symbol, decimal_places) values ('${freeCurrency}', 'A currency', 'Q', 2)\non conflict (code) do nothing;\n`
        : sql,
    );
    expect(issues).toEqual([
      expect.stringMatching(/00_currencies\.sql holds \d+ rows and is closed at \d+: a new country's rows go under `reference`/),
    ]);
  });

  it('refuses a seed file that lost its closing line', async () => {
    const issues = await checkout([], (file, sql) =>
      file === '00_territories.sql' ? sql.replace(/-- Closed at \d+ rows\./, '') : sql,
    );
    expect(issues).toEqual([expect.stringMatching(/00_territories\.sql has lost its last line/)]);
  });

  it('refuses a currency or a territory written in two places', async () => {
    const shared = String(currencyRows[0]!['code']);
    const known = String(territoryRows[0]!['code']);
    const reference = ownReference();
    reference.currency = { ...reference.currency!, code: shared };
    reference.territories = [{ ...reference.territories![0]!, code: known }];
    const issues = await checkout([{ country: freeCountry, currency: shared, reference }]);
    expect(issues).toEqual([
      expect.stringContaining(`reference.territories ${known} is also a row of supabase/seed/00_territories.sql`),
      expect.stringContaining(`reference.currency ${shared} is also a row of supabase/seed/00_currencies.sql`),
    ]);
  });

  it('refuses a currency a pack carries that another pack keeps its books in', async () => {
    const other = String(territoryRows[0]!['code']);
    const issues = await checkout([
      { country: freeCountry, currency: freeCurrency, reference: ownReference() },
      { country: other, currency: freeCurrency },
    ]);
    // Both are said: the carrier, that the row is shared, and the other pack,
    // whose seed may be applied before the one that writes it.
    expect(issues).toEqual([
      expect.stringContaining(`packs/${other.toLowerCase()}/pack.json keeps its books in ${freeCurrency}, which neither`),
      expect.stringMatching(/is also the currency of .*: a currency several packs share is a row of supabase\/seed\/00_currencies\.sql/),
    ]);
  });

  it('refuses a pack whose currency nobody writes', async () => {
    const issues = await checkout([{ country: freeCountry, currency: freeCurrency }]);
    expect(issues).toEqual([expect.stringContaining(`keeps its books in ${freeCurrency}, which neither`)]);
  });
});

describe('what `ekwo pack check` refuses inside one pack', () => {
  /** A copy of the pack in a temporary directory, its manifest given a `reference`. */
  async function packWith(reference: PackReference): Promise<Pack> {
    const dir = await mkdtemp(join(tmpdir(), 'ekwo-reference-'));
    await cp(join(packsRoot, 'schema'), join(dir, 'schema'), { recursive: true });
    await cp(join(packsRoot, alone.slug), join(dir, alone.slug), { recursive: true });
    const manifest = JSON.parse(await readFile(join(packsRoot, alone.slug, 'pack.json'), 'utf8')) as Record<
      string,
      unknown
    >;
    manifest['reference'] = reference;
    await writeFile(join(dir, alone.slug, 'pack.json'), JSON.stringify(manifest), 'utf8');
    return readPack(alone.slug, dir);
  }

  it('accepts its own currency and its own territory', async () => {
    const pack = await packWith(referenceOf(alone));
    expect(pack.manifest.reference?.currency?.code).toBe(alone.manifest.defaults.currency);
  });

  it('refuses a currency that is not the one it keeps its books in', async () => {
    const reference = referenceOf(alone);
    const other = ['XQA', 'XQB'].find((code) => code !== reference.currency.code)!;
    reference.currency.code = other;
    await expect(packWith(reference)).rejects.toThrow(
      new RegExp(`reference\\.currency: writes ${other}, and the pack keeps its books in`),
    );
  });

  it('refuses a territory listed before its parent', async () => {
    const reference = referenceOf(alone);
    const country = alone.manifest.country;
    const inside = { code: `${country}-AA`, code_source: 'iso_3166_2', name: 'Inside', legal_reference: 'A text' };
    reference.territories = [{ ...inside, parent_code: `${country}-BB` }, ...reference.territories];
    await expect(packWith(reference)).rejects.toThrow(
      new RegExp(`reference\\.territories ${country}-AA: is not ${country} itself`),
    );
  });
});
