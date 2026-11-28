import type { PGlite } from '@electric-sql/pglite';
import { cp, mkdtemp, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { freshDatabase, one, rows } from './helpers/db.js';
import { newCompany } from './helpers/factory.js';
import { compilePack, describePack, packsDir, readPack, type Pack } from '../packages/cli/src/index.js';
import { allPacks, packWhere } from './helpers/packs.js';

/**
 * A form names the territory it is filed in (`20261128070000`).
 *
 * A country with no national return files one per state. A form of
 * `tax_report.json` may say which territory inside its country it is filed in,
 * and is then the periodic return of a company established there, and of
 * nobody else. What is proved:
 *
 *   1. a pack whose forms name none compiles a seed that does not mention the
 *      column, so it still loads on an older schema;
 *   2. a pack whose form names one is read, described and compiled with it;
 *   3. `ekwo pack check` takes one periodic return per territory, and refuses
 *      two in one territory, one of the whole country beside one of a
 *      territory, a territory outside the country, and a posting that names a
 *      form the pack does not carry;
 *   4. `periodic_return_code()`, `vat_return()` with no form named and
 *      `upcoming_filings()` give a company the periodic return of its own
 *      territory, none of another's, and each territory its own when the
 *      installation carries one per territory.
 */

const territorial = packWhere('files a periodic return that names the territory it is filed in', (p) =>
  p.reports.some((r) => r.role === 'periodic' && r.territory !== null),
);
const form = territorial.reports.find((r) => r.role === 'periodic' && r.territory !== null)!;
const country = territorial.manifest.country;
const home = form.territory!;

/** Another territory of the same country, one a tax of the pack names. */
const elsewhere = territorial.taxes
  .flatMap((t) => [t.applies_supply_territory, t.applies_buyer_territory, t.applies_seller_territory])
  .find((code): code is string => code !== null && code !== home && code !== country)!;

/** A country another pack is keyed on, which no form of this one can be filed in. */
const foreign = allPacks.find((p) => p.manifest.country !== country)!.manifest.country;

const WINDOW: [string, string] = ['2026-01-01', '2026-12-31'];

let db: PGlite;
let homeId: string;
let elsewhereId: string;

async function copyWith(pack: Pack, change: (forms: Record<string, unknown>[], dir: string) => Promise<void> | void): Promise<string> {
  const dir = await mkdtemp(join(tmpdir(), 'ekwo-form-territory-'));
  await cp(join(packsDir(), 'schema'), join(dir, 'schema'), { recursive: true });
  await cp(join(packsDir(), pack.slug), join(dir, pack.slug), { recursive: true });
  const file = join(dir, pack.slug, 'tax_report.json');
  const raw = JSON.parse(await readFile(file, 'utf8')) as Record<string, unknown> | Record<string, unknown>[];
  const forms = Array.isArray(raw) ? raw : [raw];
  await change(forms, join(dir, pack.slug));
  await writeFile(file, JSON.stringify(forms), 'utf8');
  return dir;
}

/** The pack's own form, and a second periodic one beside it, as `change` leaves it. */
function withSecond(change: (second: Record<string, unknown>) => void) {
  return (forms: Record<string, unknown>[]) => {
    const second = structuredClone(forms.find((f) => f['code'] === form.code)!);
    second['code'] = `${form.code}-2`;
    second['territory'] = elsewhere;
    change(second);
    forms.push(second);
  };
}

async function companyIn(territory: string, name: string): Promise<string> {
  const { companyId } = await newCompany(db, { country, name });
  await db.query(`update companies set territory_code = $2 where id = $1`, [companyId, territory]);
  return companyId;
}

async function periodicReturn(companyId: string): Promise<string | null> {
  return (await one<{ code: string | null }>(db, `select periodic_return_code($1) as code`, [companyId])).code;
}

async function upcomingForms(companyId: string): Promise<string[]> {
  const listed = await rows<{ report_code: string | null }>(
    db,
    `select distinct report_code from upcoming_filings($1, $2::date, $3::date) where report_code is not null`,
    [companyId, ...WINDOW],
  );
  return listed.map((r) => r.report_code!);
}

beforeAll(async () => {
  db = await freshDatabase();
  homeId = await companyIn(home, 'Files At Home Works');
  elsewhereId = await companyIn(elsewhere, 'Files Elsewhere Works');
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('the territory of a form, in the pack', () => {
  it('is not mentioned by the seed of a pack whose forms name none', () => {
    const silent = allPacks.filter((p) => p.reports.every((r) => r.territory === null));
    expect(silent.length).toBeGreaterThan(0);
    for (const pack of silent) expect(compilePack(pack)).not.toMatch(/territory_code\s+= excluded/);
  });

  it('is a territory inside the country, read, described and compiled where the pack names one', () => {
    expect(home).not.toBe(country);
    const described = describePack(territorial).declarations.find((d) => d.code === form.code)!;
    expect(described.territory).toBe(home);
    expect(compilePack(territorial)).toMatch(/territory_code\s+= excluded\.territory_code/);
  });

  it('lets a pack carry one periodic return for each territory', async () => {
    const two = await copyWith(territorial, withSecond(() => {}));
    const read = await readPack(territorial.slug, two);
    expect(read.reports.filter((r) => r.role === 'periodic').map((r) => r.territory)).toEqual([home, elsewhere]);
    // The postings that name no form are for the first periodic one.
    const named = read.taxes.flatMap((t) => Object.values(t.postings).flat()).filter((p) => p.boxes.length > 0);
    expect(named.length).toBeGreaterThan(0);
    for (const posting of named) expect(posting.report).toBe(form.code);
  });

  it('refuses two periodic returns of one territory, and one of the whole country beside one of a territory', async () => {
    const twice = await copyWith(territorial, withSecond((second) => (second['territory'] = home)));
    await expect(readPack(territorial.slug, twice)).rejects.toThrow(/each declared periodic in/);

    const whole = await copyWith(territorial, withSecond((second) => delete second['territory']));
    await expect(readPack(territorial.slug, whole)).rejects.toThrow(/one periodic return for the whole country/);
  });

  it('refuses a territory outside the country, and the country itself', async () => {
    for (const code of [foreign, country]) {
      const outside = await copyWith(territorial, (forms) => {
        forms.find((f) => f['code'] === form.code)!['territory'] = code;
      });
      await expect(readPack(territorial.slug, outside)).rejects.toThrow(/is not a territory inside/);
    }
  });

  it('refuses a posting that names a form the pack does not carry', async () => {
    const stray = await copyWith(territorial, async (_forms, dir) => {
      const file = join(dir, 'taxes.json');
      const raw = JSON.parse(await readFile(file, 'utf8')) as Record<string, unknown>;
      const taxes = (Array.isArray(raw) ? raw : raw['taxes']) as Record<string, unknown>[];
      const tax = taxes.find((t) =>
        Object.values(t['postings'] as Record<string, Record<string, unknown>[]>)
          .flat()
          .some((p) => p['box'] !== undefined),
      )!;
      const posting = Object.values(tax['postings'] as Record<string, Record<string, unknown>[]>)
        .flat()
        .find((p) => p['box'] !== undefined)!;
      posting['report'] = 'NO-SUCH-FORM';
      await writeFile(file, JSON.stringify(raw), 'utf8');
    });
    await expect(readPack(territorial.slug, stray)).rejects.toThrow(/report names NO-SUCH-FORM/);
  });
});

describe('the territory of a form, in the database', () => {
  it('is written on the form by the seed', async () => {
    const row = await one<{ territory_code: string | null }>(
      db,
      `select territory_code from tax_report_templates where country = $1 and code = $2`,
      [country, form.code],
    );
    expect(row.territory_code).toBe(home);
  });

  it('makes the form the periodic return of a company established there, and of nobody else', async () => {
    expect(await periodicReturn(homeId)).toBe(form.code);
    expect(await periodicReturn(elsewhereId)).toBeNull();

    expect(await upcomingForms(homeId)).toContain(form.code);
    expect(await upcomingForms(elsewhereId)).not.toContain(form.code);
  });

  it('is filed by a company of another territory where it records a cadence for it', async () => {
    await db.query(
      `insert into company_filing_periods (company_id, report_code, period) values ($1, $2, $3::declaration_period)`,
      [elsewhereId, form.code, form.periods[0]],
    );
    try {
      expect(await upcomingForms(elsewhereId)).toContain(form.code);
      // The column mirrors the periodic return of where the company is, and
      // this is not it.
      expect(await periodicReturn(elsewhereId)).toBeNull();
    } finally {
      await db.query(`delete from company_filing_periods where company_id = $1 and report_code = $2`, [
        elsewhereId,
        form.code,
      ]);
    }
  });

  it('gives each territory its own periodic return when the installation carries one per territory', async () => {
    const second = `${form.code}-2`;
    await db.query(
      `insert into tax_report_templates (country, code, name, periods, period_default, valid_from, legal_reference,
                                         is_periodic_return, territory_code)
       select country, $3, name, periods, period_default, valid_from, legal_reference, true, $4
         from tax_report_templates where country = $1 and code = $2`,
      [country, form.code, second, elsewhere],
    );
    try {
      expect(await periodicReturn(homeId)).toBe(form.code);
      expect(await periodicReturn(elsewhereId)).toBe(second);
      expect(await upcomingForms(elsewhereId)).toEqual([second]);
      // Two periodic forms of one country, and no form named: each company is
      // given its own territory's and nobody is asked.
      for (const id of [homeId, elsewhereId]) {
        await expect(db.query(`select * from vat_return($1, $2::date, $3::date)`, [id, ...WINDOW])).resolves.toBeDefined();
      }

      // A company that has recorded no territory is held to every periodic
      // form of its country, as before the column: two, so it is asked.
      const { companyId: nowhere } = await newCompany(db, { country, name: 'Says Nowhere Works' });
      expect(await periodicReturn(nowhere)).toBeNull();
      await expect(db.query(`select * from vat_return($1, $2::date, $3::date)`, [nowhere, ...WINDOW])).rejects.toThrow(
        /ambiguous_tax_report/,
      );
    } finally {
      await db.query(`delete from tax_report_templates where country = $1 and code = $2`, [country, second]);
    }
  });
});
