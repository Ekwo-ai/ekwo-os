import type { PGlite } from '@electric-sql/pglite';
import { cp, mkdtemp, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, rows } from './helpers/db.js';
import { newCompany, newUser } from './helpers/factory.js';
import { compilePack, describePack, packsDir, readPack } from '../packages/cli/src/index.js';
import { allPacks, packWhere } from './helpers/packs.js';

/**
 * A declaration has a short name (`20261114070000`).
 *
 * The official name of a form is long and its code is for machines; the
 * short name is how the accountants of the country say it, declared by the
 * pack where it knows it. What is proved:
 *
 *   1. a pack that names none compiles the seed it compiled before — the
 *      column is not mentioned, so the seed still loads on an older schema;
 *   2. a pack that names one is read, described, compiled, and reaches the
 *      form a company files;
 *   3. `upcoming_filings()` and `portfolio_upcoming_filings()` say the
 *      official name of each form and its short name, null where the pack
 *      says nothing;
 *   4. the schema of a pack and the column both refuse a short name that is
 *      empty or longer than forty characters.
 */

const source = packWhere(
  'files a periodic return on a default cadence',
  (p) => p.report !== null && p.report.period_default !== null,
);
const form = source.report!;
const SHORT = 'Short form';

const WINDOW: [string, string] = ['2026-01-01', '2026-12-31'];

interface Upcoming {
  report_code: string | null;
  report_name: string | null;
  report_short_name: string | null;
  instalment: number | null;
}

let db: PGlite;
let companyId: string;
let accountantId: string;

async function copyWith(change: (report: Record<string, unknown>) => void): Promise<string> {
  const dir = await mkdtemp(join(tmpdir(), 'ekwo-short-name-'));
  await cp(join(packsDir(), 'schema'), join(dir, 'schema'), { recursive: true });
  await cp(join(packsDir(), source.slug), join(dir, source.slug), { recursive: true });
  const file = join(dir, source.slug, 'tax_report.json');
  const raw = JSON.parse(await readFile(file, 'utf8')) as Record<string, unknown> | Record<string, unknown>[];
  const forms = Array.isArray(raw) ? raw : [raw];
  change(forms.find((f) => f['code'] === form.code)!);
  await writeFile(file, JSON.stringify(raw), 'utf8');
  return dir;
}

async function upcoming(): Promise<Upcoming[]> {
  return rows<Upcoming>(db, `select * from upcoming_filings($1, $2::date, $3::date)`, [companyId, ...WINDOW]);
}

async function portfolio(): Promise<(Upcoming & { company_id: string })[]> {
  return asUser(db, accountantId, () =>
    rows<Upcoming & { company_id: string }>(
      db,
      `select * from portfolio_upcoming_filings($1::date, $2::date)`,
      WINDOW,
    ),
  );
}

beforeAll(async () => {
  db = await freshDatabase();
  companyId = (await newCompany(db, { country: source.manifest.country, name: 'Short Name Works' })).companyId;
  accountantId = await newUser(db);
  await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'accountant')`, [
    companyId,
    accountantId,
  ]);
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('the short name of a declaration', () => {
  it('is not mentioned by the seed of a pack that names none', () => {
    const silent = allPacks.filter((p) => p.reports.every((r) => r.short_name === null));
    expect(silent.length).toBeGreaterThan(0);
    for (const pack of silent) expect(compilePack(pack)).not.toMatch(/short_name/);
  });

  it('is read, described and compiled where the pack names one', async () => {
    const pack = await readPack(source.slug, await copyWith((r) => (r['short_name'] = SHORT)));
    expect(pack.reports.find((r) => r.code === form.code)!.short_name).toBe(SHORT);
    expect(describePack(pack).declarations.find((d) => d.code === form.code)!.shortName).toBe(SHORT);
    expect(compilePack(pack)).toMatch(/short_name\s+= excluded\.short_name/);
  });

  it('is refused by the schema of a pack when empty or longer than forty characters', async () => {
    for (const bad of ['', ' padded', 'x'.repeat(41)]) {
      await expect(readPack(source.slug, await copyWith((r) => (r['short_name'] = bad)))).rejects.toThrow(
        /pack_invalid/,
      );
    }
  });

  it('is refused by the column when empty or longer than forty characters', async () => {
    for (const bad of ['  ', 'x'.repeat(41)]) {
      const message = await expectError(
        db,
        `update tax_report_templates set short_name = $1 where country = $2 and code = $3`,
        [bad, source.manifest.country, form.code],
      );
      expect(message).toMatch(/tax_report_templates_short_name_length/);
    }
  });
});

describe('the calendar names each form', () => {
  it('by its official name, and by no short name where the pack says none', async () => {
    const due = (await upcoming()).filter((r) => r.report_code === form.code && r.instalment === null);
    expect(due.length).toBeGreaterThan(0);
    for (const row of due) {
      expect(row.report_name).toBe(form.name);
      expect(row.report_short_name).toBe(form.short_name);
    }
  });

  it('by the short name the pack declares, for the company and across the portfolio', async () => {
    const pack = await readPack(source.slug, await copyWith((r) => (r['short_name'] = SHORT)));
    await db.exec(compilePack(pack));

    const due = (await upcoming()).filter((r) => r.report_code === form.code);
    expect(due.length).toBeGreaterThan(0);
    for (const row of due) {
      expect(row.report_name).toBe(form.name);
      expect(row.report_short_name).toBe(SHORT);
    }

    const listed = (await portfolio()).filter((r) => r.company_id === companyId && r.report_code === form.code);
    expect(listed.length).toBeGreaterThan(0);
    for (const row of listed) {
      expect(row.report_name).toBe(form.name);
      expect(row.report_short_name).toBe(SHORT);
    }
  });
});
