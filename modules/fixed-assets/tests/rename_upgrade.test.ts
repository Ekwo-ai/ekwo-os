import { readFile, readdir } from 'node:fs/promises';
import { join } from 'node:path';
import { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import {
  asUser,
  freshDatabase,
  migrationFiles,
  moduleMigrationFiles,
  moduleSeedFiles,
  one,
  repoRoot,
  rows,
  seedFiles,
  shimPath,
} from '../../../tests/helpers/db.js';
import { newCompany, newInstanceAdmin } from '../../../tests/helpers/factory.js';

// The schema of this module was `assets` until version 2.0.0 and is
// `fixed_assets` since. An installation that already carries the module gets
// there through one migration, which renames in place; a fresh one applies the
// same migration after the others. This file installs the module as it was,
// books on it, applies the rename — twice — and holds the result to three
// things: every row and every figure is the one it was, to the cent; the
// catalogue is exactly what a fresh installation builds; and an archive the
// old installation wrote is taken in by a new one.

const RENAME = '20260929151742';
/** The socle migration that reads an old archive under the names of today. */
const ARCHIVE_NAMES = '20260929151700';

const socleDir = join(repoRoot, 'supabase', 'migrations');
const seedDir = join(repoRoot, 'supabase', 'seed');

/** The module's seed as it was compiled before the rename: the same rows, into `assets.*`. */
const beforeTheRename = (sql: string): string => sql.replace(/\bfixed_assets\./g, 'assets.');

/**
 * An installation of the release before: every migration but the two of the
 * rename, and none of the module's written after it — those were published
 * with or after the rename, and an upgrade applies them after it.
 */
async function installedBefore(): Promise<PGlite> {
  const db = new PGlite();
  await db.waitReady;
  await db.exec(await readFile(shimPath, 'utf8'));
  for (const file of await migrationFiles()) {
    if (file.startsWith(ARCHIVE_NAMES)) continue;
    await db.exec(await readFile(join(socleDir, file), 'utf8'));
  }
  for (const migration of await moduleMigrationFiles()) {
    if (migration.code === 'assets' && migration.version >= RENAME) continue;
    await db.exec(await readFile(migration.path, 'utf8'));
  }
  for (const file of await seedFiles()) await db.exec(await readFile(join(seedDir, file), 'utf8'));
  for (const seed of await moduleSeedFiles()) {
    await db.exec(beforeTheRename(await readFile(seed.path, 'utf8')));
  }
  await db.exec(`select set_config('ekwo.installing', 'on', false);`);
  return db;
}

async function applyTheRename(db: PGlite): Promise<void> {
  const socle = (await readdir(socleDir)).find((f) => f.startsWith(ARCHIVE_NAMES)) as string;
  await db.exec(await readFile(join(socleDir, socle), 'utf8'));
  // The rename, then what the module published after it, in the order of
  // their versions — as `ekwo migrate` applies them.
  for (const migration of await moduleMigrationFiles()) {
    if (migration.code !== 'assets' || migration.version < RENAME) continue;
    await db.exec(await readFile(migration.path, 'utf8'));
  }
}

/** Every row the module holds, and every entry it posted, as text. */
async function holdings(db: PGlite, schema: string, table: string): Promise<Record<string, unknown>> {
  const q = (sql: string) => rows(db, sql);
  return {
    register: await q(
      `select code, name, acquisition_date::text, cost::text, method::text, duration_months,
              state::text, residual_value::text from ${schema}.${table} order by code`,
    ),
    schedule: await q(
      `select a.code, l.sequence, l.period_start::text, l.period_end::text, l.amount::text,
              l.accumulated::text, l.net_book_value::text, l.entry_id::text, l.posted_at is not null as posted
         from ${schema}.depreciation_lines l join ${schema}.${table} a on a.id = l.asset_id
        order by a.code, l.sequence`,
    ),
    disposals: await q(
      `select a.code, d.disposal_date::text, d.proceeds::text, d.entry_id::text
         from ${schema}.disposals d join ${schema}.${table} a on a.id = d.asset_id order by a.code`,
    ),
    ledger: await q(
      `select e.module_code, e.module_ref, e.number, e.state::text, x.code, l.debit::text, l.credit::text
         from entries e join entry_lines l on l.entry_id = e.id join accounts x on x.id = l.account_id
        where e.module_code is not null order by e.module_ref, l.sequence`,
    ),
  };
}

/** What the module's schema is made of, by name and by definition. */
async function catalogue(db: PGlite): Promise<Record<string, unknown>> {
  const q = (sql: string) => rows(db, sql);
  return {
    relations: await q(
      `select relname, relkind::text, relacl::text from pg_class
        where relnamespace = 'fixed_assets'::regnamespace order by relname`,
    ),
    columns: await q(
      `select c.relname, a.attname, format_type(a.atttypid, a.atttypmod) as type, a.attnotnull,
              pg_get_expr(d.adbin, d.adrelid) as def
         from pg_attribute a join pg_class c on c.oid = a.attrelid
         left join pg_attrdef d on d.adrelid = a.attrelid and d.adnum = a.attnum
        where c.relnamespace = 'fixed_assets'::regnamespace and a.attnum > 0 and not a.attisdropped
        order by 1, 2`,
    ),
    functions: await q(
      `select p.proname, pg_get_function_identity_arguments(p.oid) as args, pg_get_functiondef(p.oid) as def,
              p.proacl::text, obj_description(p.oid, 'pg_proc') as comment
         from pg_proc p where p.pronamespace = 'fixed_assets'::regnamespace order by 1, 2`,
    ),
    constraints: await q(
      `select conrelid::regclass::text as rel, conname, pg_get_constraintdef(oid) as def
         from pg_constraint where connamespace = 'fixed_assets'::regnamespace order by 1, 2`,
    ),
    indexes: await q(`select indexname, indexdef from pg_indexes where schemaname = 'fixed_assets' order by 1`),
    policies: await q(
      `select tablename, policyname, cmd, roles::text, qual, with_check
         from pg_policies where schemaname = 'fixed_assets' order by 1, 2`,
    ),
    triggers: await q(
      `select tgname, pg_get_triggerdef(t.oid) as def from pg_trigger t join pg_class c on c.oid = t.tgrelid
        where c.relnamespace = 'fixed_assets'::regnamespace and not t.tgisinternal order by 1`,
    ),
    types: await q(
      `select typname, typtype::text from pg_type where typnamespace = 'fixed_assets'::regnamespace order by 1`,
    ),
    defaults: await q(
      `select defaclobjtype::text, defaclacl::text from pg_default_acl
        where defaclnamespace = 'fixed_assets'::regnamespace order by 1`,
    ),
    comments: await q(
      `select c.relname, obj_description(c.oid, 'pg_class') as comment from pg_class c
        where c.relnamespace = 'fixed_assets'::regnamespace and c.relkind = 'r' order by 1`,
    ),
    registry: await q(
      `select code, name, description, schema_name, version, status::text, requires_socle_min
         from modules order by code`,
    ),
    capabilities: await q(`select code, area, description from capabilities where area = 'assets' order by code`),
  };
}

let before: PGlite;
let fresh: PGlite;
let company = { companyId: '', ownerId: '' };
let booked: Record<string, unknown>;
let archive: string;

beforeAll(async () => {
  before = await installedBefore();
  fresh = await freshDatabase();

  // country-literal: the worked examples of the module's README are Belgian
  company = await newCompany(before, { country: 'BE', name: 'Avant le renommage SRL' });
  for (const year of [2027, 2028]) {
    await before.query(
      `insert into fiscal_years (company_id, name, start_date, end_date)
       values ($1, $2, make_date($3, 1, 1), make_date($3, 12, 31))`,
      [company.companyId, `Exercice ${year}`, year],
    );
  }
  await asUser(before, company.ownerId, async () => {
    await before.query(`select enable_module($1, 'assets')`, [company.companyId]);
    await before.query(
      `select assets.create_asset($1, 'IT-01', 'Portable', date '2026-07-01', 3000,
              '241000', '241900', '630200', 'it-equipment')`,
      [company.companyId],
    );
    const van = await one<{ id: string }>(
      before,
      `select assets.create_asset($1, 'VAN-01', 'Camionnette', date '2026-01-01', 20000,
              '241000', '241900', '630200', null, 60) as id`,
      [company.companyId],
    );
    await before.query(`select assets.run_depreciation($1, date '2026-12-31')`, [company.companyId]);
    await before.query(`select assets.dispose_asset($1, date '2027-01-15', 15000, '400000')`, [van.id]);
    archive = (
      await one<{ archive: string }>(before, `select export_company($1)::text as archive`, [company.companyId])
    ).archive;
  });
  booked = await holdings(before, 'assets', 'assets');
}, 120_000);

afterAll(async () => {
  await before.close();
  await fresh.close();
});

describe('an installation that carries the module before 2.0.0', () => {
  it('had booked what this test depends on', () => {
    expect((booked['ledger'] as unknown[]).length).toBeGreaterThan(0);
    expect((booked['disposals'] as unknown[]).length).toBe(1);
    expect(JSON.parse(archive).manifest.tables.map((t: { name: string }) => t.name)).toContain('assets.assets');
  });

  it('keeps every row and every figure, to the cent, through the rename', async () => {
    await applyTheRename(before);
    expect(await one(before, `select to_regnamespace('assets') is null as gone`)).toEqual({ gone: true });
    expect(await holdings(before, 'fixed_assets', 'fixed_assets')).toEqual(booked);
  });

  it('keeps the module code on the entries it posted, and every right a member held', async () => {
    const tags = await rows<{ module_code: string }>(
      before,
      `select distinct module_code from entries where module_code is not null`,
    );
    expect(tags).toEqual([{ module_code: 'assets' }]);
    const enabled = await rows(before, `select module_code from company_modules where company_id = $1`, [
      company.companyId,
    ]);
    expect(enabled).toEqual([{ module_code: 'assets' }]);
  });

  it('changes nothing when it runs a second time', async () => {
    const once = await catalogue(before);
    await applyTheRename(before);
    expect(await catalogue(before)).toEqual(once);
    expect(await holdings(before, 'fixed_assets', 'fixed_assets')).toEqual(booked);
  });

  it('arrives at exactly the catalogue a fresh installation builds', async () => {
    const upgraded = await catalogue(before);
    const built = await catalogue(fresh);
    for (const key of Object.keys(built)) expect(upgraded[key], key).toEqual(built[key]);
  });

  it('goes on depreciating under the new names', async () => {
    const run = await asUser(before, company.ownerId, async () =>
      one<{ result: { entries: { amount: string }[] } }>(
        before,
        `select fixed_assets.run_depreciation($1, date '2027-12-31') as result`,
        [company.companyId],
      ),
    );
    expect(run.result.entries.map((e) => e.amount)).toEqual(['1000.00']);
    const ref = await rows(
      before,
      `select module_code, module_ref from entries where module_ref = 'depreciation:2027-12-31'`,
    );
    expect(ref).toEqual([{ module_code: 'assets', module_ref: 'depreciation:2027-12-31' }]);
  });
});

describe('an archive written before 2.0.0', () => {
  it('is taken in by an installation of today, under the names of today', async () => {
    const admin = await newInstanceAdmin(fresh);
    await asUser(fresh, admin, async () => {
      await one(fresh, `select import_company($1::jsonb, $2) as result`, [archive, company.ownerId]);
    });
    expect(await holdings(fresh, 'fixed_assets', 'fixed_assets')).toEqual(booked);
  });

  it('is refused when it carries one table under both its names', async () => {
    const parsed = JSON.parse(archive) as { tables: Record<string, unknown[]> };
    parsed.tables['fixed_assets.fixed_assets'] = parsed.tables['assets.assets'] as unknown[];
    await expect(
      fresh.query(`select archive_under_current_names($1::jsonb)`, [JSON.stringify(parsed)]),
    ).rejects.toThrow(/archive_corrupt: the archive carries both assets\.assets and fixed_assets\.fixed_assets/);
  });
});
