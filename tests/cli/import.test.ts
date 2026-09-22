/**
 * `ekwo import`: books and statements from elsewhere, from files on the disk,
 * as a signed-in person, against a real Postgres behind the instance's two
 * HTTP surfaces — the way `books.test.ts` runs the other verbs.
 *
 * What the command line owns is small and is what is tested here: the files
 * read from the disk, the correspondence written with --save-mapping and read
 * back with --mapping, the output document, the exit codes. Every rule is the
 * core's and the schema's, and `tests/import_books.test.ts` proves those.
 */

import { copyFile, mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { BOOK_SOURCES } from '@ekwo-ai/core';
import { EXIT_USAGE, run, validate, type OutputDocument } from '../../packages/cli/src/index.js';
import { stripColour } from '../../packages/cli/src/ui.js';
import { NAMED_SOURCES } from '../../packages/cli/src/commands/import.js';
import { ImportBooksInput, NAMED_SOURCES as MCP_NAMED_SOURCES, sourceOf } from '../../packages/mcp/src/tools/import-books.js';
import { freshDatabase, one, repoRoot } from '../helpers/db.js';
import { newCompany, newUser } from '../helpers/factory.js';
import { roleOf, somePack } from '../helpers/packs.js';
import { ANON_KEY, FAKE_URL, fakeSupabase, type FakeSupabase } from './fake-supabase.js';

const HOME = somePack.manifest.country;
const PASSWORD = 'correct horse battery staple';
const journalRoles = somePack.manifest.defaults.journal_roles as Record<string, string>;

type Row = Record<string, unknown>;

let pg: PGlite;
let schema: Row;
let instance: FakeSupabase;
let root: string;
let companyId: string;

async function capture(fn: () => Promise<number>): Promise<{ exitCode: number; stdout: string }> {
  const out = process.stdout.write.bind(process.stdout);
  const err = process.stderr.write.bind(process.stderr);
  let stdout = '';
  process.stdout.write = ((chunk: string | Uint8Array) => ((stdout += String(chunk)), true)) as typeof process.stdout.write;
  process.stderr.write = (() => true) as typeof process.stderr.write;
  try {
    return { exitCode: await fn(), stdout };
  } finally {
    process.stdout.write = out;
    process.stderr.write = err;
  }
}

/** Runs a command under --json and holds the answer to the published schema. */
async function ekwo(argv: string[], as: 'owner' | 'viewer' = 'owner'): Promise<OutputDocument> {
  const captured = await capture(() => run([...argv, '--json'], { fetchImpl: instance.fetchImpl, env: { EKWO_CONFIG_DIR: join(root, as) } }));
  const document = JSON.parse(captured.stdout) as OutputDocument;
  expect(validate(document, schema)).toEqual([]);
  expect(document.exitCode).toBe(captured.exitCode);
  if (document.error === undefined) {
    const shape = ((schema['$defs'] as Record<string, Row>)['data'] ?? {})[document.command];
    expect(shape, `output.1.json describes no data for "${document.command}"`).toBeDefined();
    expect(validate(document.data, shape as Row, schema)).toEqual([]);
  }
  return document;
}

const fixture = (brick: string, name: string): string => join(repoRoot, 'packages', 'formats', brick, 'test', 'fixtures', name);
const count = async (table: string): Promise<number> =>
  (await one<{ n: number }>(pg, `select count(*)::int as n from ${table} where company_id = $1`, [companyId])).n;

beforeAll(async () => {
  schema = JSON.parse(await readFile(join(repoRoot, 'packages', 'cli', 'schema', 'output.1.json'), 'utf8')) as Row;
  pg = await freshDatabase();
  const owner = await newUser(pg, 'owner@example.test');
  const viewer = await newUser(pg, 'viewer@example.test');
  companyId = (await newCompany(pg, { country: HOME, name: 'Import Example', ownerId: owner })).companyId;
  await pg.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'viewer')`, [companyId, viewer]);

  root = await mkdtemp(join(tmpdir(), 'ekwo-import-'));
  instance = fakeSupabase(pg);
  instance.addUser(owner, 'owner@example.test', PASSWORD);
  instance.addUser(viewer, 'viewer@example.test', PASSWORD);
  for (const who of ['owner', 'viewer'] as const) {
    const signedIn = await ekwo(['login', '--supabase-url', FAKE_URL, '--anon-key', ANON_KEY, '--email', `${who}@example.test`, '--password', PASSWORD], who);
    expect(signedIn.exitCode).toBe(0);
    expect((await ekwo(['use', 'Import Example'], who)).exitCode).toBe(0);
  }
  await copyFile(fixture('fec', 'sample.fec.txt'), join(root, 'sample.fec.txt'));
});

afterAll(async () => {
  await pg.close();
  await rm(root, { recursive: true, force: true });
});

describe('ekwo import, called wrong', () => {
  it('lists the sources when none is named, and refuses one it does not know', async () => {
    const bare = await ekwo(['import']);
    expect(bare.exitCode).toBe(EXIT_USAGE);
    expect(bare.error?.message).toContain('fec');
    expect((await ekwo(['import', 'spreadsheet', 'x.csv'])).error?.message).toContain('unknown_source');
  });

  it('refuses a flag of a statement on books, and of books on a statement', async () => {
    expect((await ekwo(['import', 'fec', join(root, 'sample.fec.txt'), '--iban-country', 'XX'])).exitCode).toBe(EXIT_USAGE);
    expect((await ekwo(['import', 'camt.053', join(root, 'sample.fec.txt'), '--open-years'])).exitCode).toBe(EXIT_USAGE);
  });
});

describe('a FEC, from the rehearsal to the books', () => {
  const mapPath = (): string => join(root, 'mapping.json');

  it('rehearses, and saves the correspondence it proposes for every account and journal', async () => {
    const answer = await ekwo(['import', 'fec', join(root, 'sample.fec.txt'), '--dry-run', '--open-years', '--save-mapping', mapPath()]);
    const data = answer.data as Row;
    expect(data['dry_run']).toBe(true);
    expect(data['mapping_saved_to']).toBe(mapPath());
    const saved = JSON.parse(await readFile(mapPath(), 'utf8')) as { version: number; accounts: Record<string, string | null>; journals: Record<string, string | null> };
    expect(saved.version).toBe(1);
    expect(Object.keys(saved.accounts)).toHaveLength(8);
    expect(Object.keys(saved.journals).sort()).toEqual(['AC', 'AN', 'BQ', 'VE']);
    expect(await count('entries')).toBe(0);
  });

  it('imports with the correspondence the user completed, whole', async () => {
    const saved = JSON.parse(await readFile(mapPath(), 'utf8')) as Row;
    saved['accounts'] = {
      '512000': roleOf(somePack, 'bank'),
      '101000': roleOf(somePack, 'retained_earnings'),
      '411000': roleOf(somePack, 'receivable'),
      '706000': roleOf(somePack, 'sales'),
      '445710': roleOf(somePack, 'tax_payable'),
      '606100': roleOf(somePack, 'purchase'),
      '445660': roleOf(somePack, 'tax_receivable'),
      '401000': roleOf(somePack, 'payable'),
    };
    saved['journals'] = { AN: '@opening', VE: journalRoles['sales'], AC: journalRoles['purchase'], BQ: journalRoles['miscellaneous'] };
    await writeFile(mapPath(), JSON.stringify(saved));

    const answer = await ekwo(['import', 'fec', join(root, 'sample.fec.txt'), '--mapping', mapPath(), '--open-years']);
    expect(answer.exitCode).toBe(0);
    const result = (answer.data as Row)['result'] as Row;
    expect(result['entries']).toBe(4);
    expect(await count('entries')).toBe(5);
  });

  it('refuses the same file a second time, and says so', async () => {
    const again = await ekwo(['import', 'fec', join(root, 'sample.fec.txt'), '--mapping', mapPath(), '--open-years']);
    expect(again.exitCode).not.toBe(0);
    expect(again.error?.message).toContain('import_already_done');
    expect(await count('entries')).toBe(5);
  });

  it('is refused to a member who may only read', async () => {
    const refused = await ekwo(['import', 'fec', join(root, 'sample.fec.txt'), '--mapping', mapPath(), '--open-years', '--dry-run'], 'viewer');
    expect(refused.exitCode).not.toBe(0);
    expect(refused.error?.message).toContain('not_allowed');
  });

  it('refuses a correspondence file that is not one', async () => {
    await writeFile(join(root, 'broken.json'), '{"accounts": ["411000"]}');
    const broken = await ekwo(['import', 'fec', join(root, 'sample.fec.txt'), '--mapping', join(root, 'broken.json')]);
    expect(broken.exitCode).toBe(EXIT_USAGE);
    expect(broken.error?.message).toContain('bad_mapping');
  });
});

describe('the correspondence, printed for a person', () => {
  it('shows the lines to read first, each with its reason, and posts nothing while one waits', async () => {
    const bank = somePack.accounts.find((account) => account.code === roleOf(somePack, 'bank'))!;
    const path = join(root, 'doubtful.csv');
    await writeFile(path, `account,name,debit,credit\n${bank.code},${bank.name},75.00,\nZZ9,Somewhere else,,75.00\n`);
    const printed = await capture(() =>
      run(['import', 'trial-balance', path, '--opening-date', '2026-01-01', '--dry-run'], { fetchImpl: instance.fetchImpl, env: { EKWO_CONFIG_DIR: join(root, 'owner') } }),
    );
    expect(printed.exitCode).toBe(1);
    const rows = printed.stdout.split('\n').map(stripColour);
    const unknown = rows.findIndex((row) => /^\s+\?\s+ZZ9\s/.test(row));
    const exact = rows.findIndex((row) => row.includes(` ${bank.code} `) && row.includes('exact'));
    expect(unknown).toBeGreaterThan(-1);
    expect(exact).toBeGreaterThan(unknown);

    const answer = await ekwo(['import', 'trial-balance', path, '--opening-date', '2026-01-01', '--accept-suggestions']);
    expect(answer.exitCode).not.toBe(0);
    expect(answer.error?.message).toContain('import_unmapped_accounts: no account of the chart answers for ZZ9');
  });
});

describe('a source named by the software its export comes from', () => {
  // The names are read from the list that declares them, never written here:
  // this file is not one of those allowed to name another product.
  const names = Object.keys(NAMED_SOURCES) as (keyof typeof NAMED_SOURCES)[];

  it('is the same list on the command line and in the MCP tool, each pointing at a reader that exists', () => {
    expect(Object.fromEntries(names.map((n) => [n, NAMED_SOURCES[n].reader]))).toEqual(
      Object.fromEntries(Object.entries(MCP_NAMED_SOURCES).map(([n, v]) => [n, v.reader])),
    );
    for (const name of names) {
      expect(BOOK_SOURCES).toContain(NAMED_SOURCES[name].reader);
      // The tool takes the name, and hands the core the reader it stands for.
      expect(ImportBooksInput.shape.source.safeParse(name).success).toBe(true);
      expect(sourceOf(name)).toBe(NAMED_SOURCES[name].reader);
    }
  });

  it('is on the compatibility page, as available, with its command', async () => {
    const page = await readFile(join(repoRoot, 'docs', 'compatibility.md'), 'utf8');
    for (const name of names) {
      const row = page.split('\n').find((line) => line.includes(`\`ekwo import ${name}\``));
      expect(row, name).toBeDefined();
      expect(row).toContain(`\`${NAMED_SOURCES[name].reader}\``);
      expect(row).toMatch(/\| available \|$/);
    }
  });

  it('is listed by ekwo import --help, with what it reads', async () => {
    const help = await ekwo(['import', '--help']);
    expect(help.exitCode).toBe(0);
    const usage = (help.data as { usage: string }).usage;
    for (const name of names) {
      expect(usage).toContain(`${name} (= ${NAMED_SOURCES[name].reader})`);
      expect(usage).toContain(`${name}: reads ${NAMED_SOURCES[name].export}`);
    }
  });

  it('reads the files with the reader it names', async () => {
    const byReport = names.find((n) => NAMED_SOURCES[n].reader === 'journal-report')!;
    const answer = await ekwo([
      'import', byReport, fixture('journal-report', 'journal-report.csv'), fixture('journal-report', 'chart.csv'),
      '--date-order', 'dmy', '--dry-run', '--open-years',
    ]);
    expect(answer.error).toBeUndefined();
    const data = answer.data as Row;
    expect(data['source']).toBe('journal-report');
    expect((data['read'] as Row)['entries']).toBe(3);
  });
});

describe('a bank statement, by the same command', () => {
  const statement = fixture('camt053', 'golden.camt.053.001.08.xml');

  beforeAll(async () => {
    // The fixture is the statement of an account that exists nowhere; the
    // company is given it, as an operator would before a first import.
    await pg.query(
      `insert into bank_accounts (company_id, name, currency_code, iban, account_id, journal_id)
       select $1, 'Bank', 'EUR', 'BE96999000000101',
              (select id from accounts where company_id = $1 and account_type = 'asset_cash' order by code limit 1),
              (select id from journals where company_id = $1 and journal_type = 'bank' order by code limit 1)`,
      [companyId],
    );
  });

  it('reads it under --dry-run without asking the database anything', async () => {
    const answer = await ekwo(['import', 'camt.053', statement, '--dry-run']);
    expect(answer.exitCode).toBe(0);
    const file = ((answer.data as Row)['files'] as Row[])[0]!;
    expect(file['statements']).toBe(1);
    expect(file['accounts']).toEqual(['BE96999000000101']);
    expect(await count('bank_transactions')).toBe(0);
  });

  it('imports its lines as pending, ready for ekwo match', async () => {
    const answer = await ekwo(['import', 'camt.053', statement]);
    expect(answer.exitCode).toBe(0);
    const pending = await one<{ n: number }>(pg, `select count(*)::int as n from bank_transactions where company_id = $1 and state = 'pending'`, [companyId]);
    expect(pending.n).toBeGreaterThan(0);
    expect(await count('entries')).toBe(5);
  });
});
