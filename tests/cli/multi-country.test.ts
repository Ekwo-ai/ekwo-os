/**
 * One installation, companies in several countries.
 *
 * `ekwo init --no-company` installs the schema, every pack and the first
 * administrator, and no company; `ekwo company new` then creates each company
 * in its own country, through `create_company()` — the function the MCP
 * server's `create_company` tool calls — with the refusals `ekwo init` has for
 * its first company. These tests run the commands themselves, flags in and
 * exit code out, against a real Postgres, and hold every answer to the
 * published output contract.
 *
 * And the other half of the promise: `ekwo init` without `--no-company` still
 * does what it did — the first company, in the country it was given — except
 * that `ekwo.json` no longer names a country.
 *
 * No country is written in this file. The two companies are made on two packs
 * this repository carries, read from the packs themselves.
 */

import { mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import {
  EXIT_REFUSED,
  EXIT_USAGE,
  readConfig,
  run,
  schemaIsInstalled,
  validate,
  type OutputDocument,
  type SqlClient,
} from '../../packages/cli/src/index.js';
import type { Pack } from '../../packages/cli/src/pack/read.js';
import { repoRoot } from '../helpers/db.js';
import { allPacks, packsWhere, somePack } from '../helpers/packs.js';
import { emptyDatabase, makeAuthUser } from './helpers.js';

// Never dialled: the connector below answers instead of the network driver.
const DB_URL = 'postgresql://postgres:secret@localhost:5432/postgres';

let schema: Record<string, unknown>;

beforeAll(async () => {
  schema = JSON.parse(
    await readFile(join(repoRoot, 'packages', 'cli', 'schema', 'output.1.json'), 'utf8'),
  ) as Record<string, unknown>;
});

/** Runs a command with `--json` on this database, and checks the document against the contract. */
async function json(db: SqlClient, cwd: string, argv: string[]): Promise<OutputDocument> {
  const connect = async (): Promise<SqlClient> => ({ ...db, close: async () => {} });
  const write = process.stdout.write.bind(process.stdout);
  const writeErr = process.stderr.write.bind(process.stderr);
  let stdout = '';
  process.stdout.write = ((chunk: string | Uint8Array) => {
    stdout += String(chunk);
    return true;
  }) as typeof process.stdout.write;
  process.stderr.write = (() => true) as typeof process.stderr.write;
  let exitCode: number;
  try {
    exitCode = await run([...argv, '--json', '--db-url', DB_URL], { connect, cwd });
  } finally {
    process.stdout.write = write;
    process.stderr.write = writeErr;
  }
  const document = JSON.parse(stdout) as OutputDocument;
  expect(validate(document, schema)).toEqual([]);
  expect(document.exitCode).toBe(exitCode);
  if (document.error === undefined) {
    const shapes = (schema['$defs'] as Record<string, Record<string, unknown>>)['data'] ?? {};
    const shape = shapes[document.command] as Record<string, unknown> | undefined;
    expect(shape, `output.1.json describes no data for "${document.command}"`).toBeDefined();
    expect(validate(document.data, shape ?? {}, schema)).toEqual([]);
  }
  return document;
}

/**
 * Every answer a pack leaves open, given as a flag — the chart, the language,
 * and the first day of the year where the pack names no month — so a run with
 * nobody to ask goes through on any pack.
 */
function companyFlags(pack: Pack): string[] {
  const chart = pack.charts.find((c) => c.is_default) ?? pack.charts[0]!;
  return [
    '--chart',
    chart.code,
    '--language',
    pack.languages[0] as string,
    '--fiscal-year',
    '2026',
    ...(pack.documents.fiscal_year_default === null ? ['--fiscal-year-start', '2026-01-01'] : []),
  ];
}

/** The same, for `init`: the periodic return's cadence where the form offers several. */
function initFlags(pack: Pack): string[] {
  const period = pack.report?.periods[0];
  return [...companyFlags(pack), ...(period === undefined ? [] : ['--vat-period', period])];
}

/** Two packs of two different countries, both loaded as seeds by every installation. */
function twoCountries(loaded: string[]): [Pack, Pack] {
  const candidates = allPacks.filter((pack) => loaded.includes(pack.manifest.country));
  const first = candidates[0];
  const second = candidates.find((pack) => pack.manifest.country !== first?.manifest.country);
  if (first === undefined || second === undefined) {
    throw new Error('this test needs two packs of two countries loaded in the installation');
  }
  return [first, second];
}

describe('ekwo init --no-company, then ekwo company new in two countries', () => {
  let db: SqlClient;
  let cwd: string;
  let adminUserId: string;
  let first: Pack;
  let second: Pack;

  beforeAll(async () => {
    ({ db } = await emptyDatabase());
    adminUserId = await makeAuthUser(db, 'first@example.test');
    cwd = await mkdtemp(join(tmpdir(), 'ekwo-multi-'));
  });

  afterAll(async () => {
    await db.close().catch(() => {});
    await rm(cwd, { recursive: true, force: true });
  });

  it('refuses a flag that only describes a company, before touching the database', async () => {
    const refused = await json(db, cwd, [
      'init', '--no-company', '--yes', '--org', 'Example Group', '--admin-user-id', adminUserId,
      '--country', somePack.manifest.country,
    ]);
    expect(refused.exitCode).toBe(EXIT_USAGE);
    expect(refused.error).toMatchObject({ kind: 'usage', name: 'company_flags_without_company' });
    expect(refused.error?.message).toContain('--country');
    expect(await schemaIsInstalled(db)).toBe(false);
  });

  it('installs the schema, every pack and the administrator, and no company', async () => {
    const installed = await json(db, cwd, [
      'init', '--no-company', '--yes', '--org', 'Example Group', '--admin-user-id', adminUserId,
    ]);
    expect(installed.exitCode).toBe(0);
    expect(installed.data).toMatchObject({
      organization: 'Example Group',
      adminUserId,
      company: null,
      fiscalYear: null,
      bankAccountId: null,
    });

    expect(await db.query('select id from companies')).toEqual([]);
    const instance = await db.query<{ country: string | null }>('select country from instance');
    expect(instance).toEqual([{ country: null }]);
    const admins = await db.query<{ user_id: string }>('select user_id from instance_admins');
    expect(admins).toEqual([{ user_id: adminUserId }]);

    // The installation, and no country in it.
    const written = JSON.parse(await readFile(join(cwd, 'ekwo.json'), 'utf8')) as Record<string, unknown>;
    expect(Object.keys(written)).not.toContain('country');
    expect(written['schema_version']).toBeDefined();

    // Nothing pending and nothing behind: it is a finished installation.
    const status = await json(db, cwd, ['status']);
    expect(status.exitCode).toBe(0);
    expect((status.data as { companies: unknown[] }).companies).toEqual([]);

    const loaded = await db.query<{ country: string }>('select country from country_packs');
    [first, second] = twoCountries(loaded.map((row) => row.country));
  });

  it('is safe to run twice', async () => {
    const again = await json(db, cwd, [
      'init', '--no-company', '--yes', '--org', 'Example Group', '--admin-user-id', adminUserId,
    ]);
    expect(again.exitCode).toBe(0);
    const steps = (again.data as { steps: { name: string; outcome: string }[] }).steps;
    expect(steps.map((s) => s.outcome)).toEqual(['already', 'already']);
  });

  it('creates two companies of two countries in the same installation', async () => {
    const one = await json(db, cwd, [
      'company', 'new', 'Example North', '--country', first.manifest.country, ...companyFlags(first),
    ]);
    expect(one.exitCode).toBe(0);
    const two = await json(db, cwd, [
      'company', 'new', 'Example South', '--country', second.manifest.country, ...companyFlags(second),
    ]);
    expect(two.exitCode).toBe(0);

    for (const [document, pack] of [[one, first], [two, second]] as const) {
      const data = document.data as {
        company: { id: string; country: string; currency: string; language: string; chart: string | null };
        fiscalYear: { name: string } | null;
        owner: string;
      };
      expect(data.company.country).toBe(pack.manifest.country);
      expect(data.company.language).toBe(pack.languages[0]);
      expect(data.company.chart).toBe((pack.charts.find((c) => c.is_default) ?? pack.charts[0]!).code);
      expect(data.fiscalYear?.name).toBe('FY2026');
      // The administrator it was created as is its owner, as with the MCP tool.
      expect(data.owner).toBe(adminUserId);
      const owner = await db.query<{ role: string }>(
        'select role::text from company_members where company_id = $1 and user_id = $2',
        [data.company.id, adminUserId],
      );
      expect(owner).toEqual([{ role: 'owner' }]);
      // Its own chart of accounts, copied from its own pack.
      const accounts = await db.query<{ n: number }>(
        'select count(*)::int as n from accounts where company_id = $1',
        [data.company.id],
      );
      expect(accounts[0]?.n).toBeGreaterThan(0);
    }

    const list = await json(db, cwd, ['company', 'list']);
    const companies = (list.data as { companies: { name: string; country: string; members: number }[] }).companies;
    expect(companies.map((c) => [c.name, c.country])).toEqual([
      ['Example North', first.manifest.country],
      ['Example South', second.manifest.country],
    ]);
    expect(companies.every((c) => c.members === 1)).toBe(true);
  });

  it('refuses what init refuses, when there is a choice and nobody to make it', async () => {
    const noCountry = await json(db, cwd, ['company', 'new', 'Example Three', '--yes']);
    expect(noCountry.exitCode).toBe(EXIT_USAGE);
    expect(noCountry.error).toMatchObject({ name: 'missing_input' });
    expect(noCountry.error?.message).toContain(first.manifest.country);

    const [severalCharts] = packsWhere('with several charts', (pack) => pack.charts.length > 1);
    const noChart = await json(db, cwd, [
      'company', 'new', 'Example Three', '--yes', '--country', severalCharts!.manifest.country,
      '--language', severalCharts!.languages[0] as string, '--fiscal-year-start', '2026-01-01',
    ]);
    expect(noChart.exitCode).toBe(EXIT_USAGE);
    expect(noChart.error?.message).toContain('Pass --chart');

    const unknownChart = await json(db, cwd, [
      'company', 'new', 'Example Three', '--country', first.manifest.country, '--chart', 'not-a-chart',
    ]);
    expect(unknownChart.exitCode).toBe(EXIT_USAGE);
    expect(unknownChart.error).toMatchObject({ name: 'unknown_chart' });

    const [severalLanguages] = packsWhere('with several languages', (pack) => pack.languages.length > 1);
    const noLanguage = await json(db, cwd, [
      'company', 'new', 'Example Three', '--yes', '--country', severalLanguages!.manifest.country,
      '--chart', severalLanguages!.charts[0]!.code, '--fiscal-year-start', '2026-01-01',
    ]);
    expect(noLanguage.exitCode).toBe(EXIT_USAGE);
    expect(noLanguage.error?.message).toContain('--language');

    const noName = await json(db, cwd, ['company', 'new']);
    expect(noName.exitCode).toBe(EXIT_USAGE);

    expect(await db.query('select id from companies where name = $1', ['Example Three'])).toEqual([]);
  });

  it('is refused by the database for somebody who is not an administrator', async () => {
    const stranger = await makeAuthUser(db, 'stranger@example.test');
    const refused = await json(db, cwd, [
      'company', 'new', 'Example Three', '--as-user', stranger,
      '--country', first.manifest.country, ...companyFlags(first),
    ]);
    expect(refused.exitCode).toBe(EXIT_REFUSED);
    expect(refused.error).toMatchObject({ kind: 'refusal', name: 'not_instance_admin', sqlstate: '42501' });
    expect(await db.query('select id from companies where name = $1', ['Example Three'])).toEqual([]);
  });
});

describe('ekwo init without --no-company does what it did', () => {
  let db: SqlClient;
  let cwd: string;

  beforeAll(async () => {
    ({ db } = await emptyDatabase());
    cwd = await mkdtemp(join(tmpdir(), 'ekwo-init-'));
  });

  afterAll(async () => {
    await db.close().catch(() => {});
    await rm(cwd, { recursive: true, force: true });
  });

  it('creates the first company in the country it is given, and writes ekwo.json without one', async () => {
    const adminUserId = await makeAuthUser(db, 'first@example.test');
    const home = somePack.manifest.country;
    const document = await json(db, cwd, [
      'init', '--yes', '--country', home, '--org', 'Example Group', '--company', 'Example One',
      '--admin-user-id', adminUserId, ...initFlags(somePack),
    ]);
    expect(document.exitCode).toBe(0);
    expect(document.data).toMatchObject({
      organization: 'Example Group',
      company: { name: 'Example One', country: home },
      fiscalYear: { name: 'FY2026' },
    });
    // The instance still records the country of its first company.
    expect(await db.query('select country from instance')).toEqual([{ country: home }]);

    const written = JSON.parse(await readFile(join(cwd, 'ekwo.json'), 'utf8')) as Record<string, unknown>;
    expect(Object.keys(written).sort()).toEqual(['$comment', 'schema_version']);

    // And a second company, in another country, beside the first one.
    const other = allPacks.find((pack) => pack.manifest.country !== home)!;
    const more = await json(db, cwd, [
      'company', 'new', 'Example Two', '--country', other.manifest.country, ...companyFlags(other),
    ]);
    expect(more.exitCode).toBe(0);
    const list = await json(db, cwd, ['company', 'list']);
    expect((list.data as { companies: { country: string }[] }).companies.map((c) => c.country).sort()).toEqual(
      [home, other.manifest.country].sort(),
    );
  });

  it('reads an ekwo.json written by an older release, country and all', async () => {
    await writeFile(
      join(cwd, 'ekwo.json'),
      JSON.stringify({
        project_url: 'https://abcdefghijklmnopqrst.supabase.co',
        country: somePack.manifest.country,
        schema_version: '0.6.0',
      }),
    );
    expect(await readConfig(cwd)).toEqual({
      project_url: 'https://abcdefghijklmnopqrst.supabase.co',
      schema_version: '0.6.0',
    });
  });
});
