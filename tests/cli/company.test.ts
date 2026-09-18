/**
 * `ekwo company export` and `ekwo company import`, as a caller with a shell
 * sees them: flags in, a directory and an exit code out.
 *
 * The journey itself — the figures to the cent, the locks, the numbering, the
 * archives that lie — is `tests/company_archive.test.ts`, against the
 * functions. What is proved here is what the CLI adds: that the export really
 * runs as a member under row level security although the connection belongs to
 * the owner of the database, that the files are the bytes the manifest hashed
 * so that `shasum` checks an archive without Ekwo, that a file damaged on the
 * way is caught before the database is asked anything, and that the two
 * commands answer under the output contract.
 */

import { createHash } from 'node:crypto';
import { mkdtemp, readFile, readdir, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import {
  EXIT_ERROR,
  EXIT_REFUSED,
  EXIT_USAGE,
  run,
  validate,
  type ArchiveManifest,
  type OutputDocument,
  type SqlClient,
} from '../../packages/cli/src/index.js';
import { freshDatabase, one, repoRoot, rows } from '../helpers/db.js';
import { newCompany, newInstanceAdmin, newUser } from '../helpers/factory.js';
import { replayScenario } from '../helpers/golden-scenario.js';
import { allPacks } from '../helpers/packs.js';
import { adapt, type Queryable } from './helpers.js';

const DB_URL = 'postgresql://postgres:secret@localhost:5432/postgres';

const pack = allPacks.find((p) => p.golden !== null && p.report !== null)!;
const golden = pack.golden!;

let a: PGlite;
let b: PGlite;
let cwd: string;
let schema: Record<string, unknown>;
let companyId: string;
let ownerId: string;
let accountantId: string;

const connectTo = (pg: PGlite) => async (): Promise<SqlClient> => ({
  ...adapt(pg as unknown as Queryable, pg),
  close: async () => {},
});

async function ekwo(pg: PGlite, argv: string[]): Promise<OutputDocument> {
  const out = process.stdout.write.bind(process.stdout);
  const err = process.stderr.write.bind(process.stderr);
  let stdout = '';
  process.stdout.write = ((chunk: string | Uint8Array) => {
    stdout += String(chunk);
    return true;
  }) as typeof process.stdout.write;
  process.stderr.write = (() => true) as typeof process.stderr.write;
  let exitCode: number;
  try {
    exitCode = await run([...argv, '--json', '--db-url', DB_URL], { connect: connectTo(pg) });
  } finally {
    process.stdout.write = out;
    process.stderr.write = err;
  }
  const document = JSON.parse(stdout) as OutputDocument;
  expect(validate(document, schema)).toEqual([]);
  expect(document.exitCode).toBe(exitCode);
  if (document.error === undefined) {
    const shapes = (schema['$defs'] as Record<string, Record<string, unknown>>)['data'] ?? {};
    expect(validate(document.data, shapes[document.command] as Record<string, unknown>, schema)).toEqual([]);
  }
  return document;
}

const balance = (pg: PGlite) =>
  rows(pg, `select to_jsonb(t)::text as row from trial_balance($1, $2::date, $3::date) t`, [
    companyId, golden.fiscalYear.start, golden.fiscalYear.end,
  ]);

beforeAll(async () => {
  schema = JSON.parse(
    await readFile(join(repoRoot, 'packages', 'cli', 'schema', 'output.1.json'), 'utf8'),
  ) as Record<string, unknown>;
  a = await freshDatabase();
  b = await freshDatabase();
  cwd = await mkdtemp(join(tmpdir(), 'ekwo-company-'));

  ownerId = await newUser(a);
  // country-literal: the first pack that carries a year of books and a form;
  // the country is the pack's own.
  ({ companyId } = await newCompany(a, {
    country: pack.manifest.country,
    name: 'Travelling Example',
    ownerId,
    chart: golden.chart,
    language: golden.language,
    fiscalYear: golden.fiscalYear,
  }));
  await replayScenario(a, companyId, golden);
  // A jsonb column holding a decimal a JSON parser would rewrite.
  await a.query(
    `insert into bank_accounts (company_id, name, journal_id)
     select $1, 'Current account', id from journals where company_id = $1 and journal_type = 'bank' limit 1`,
    [companyId],
  );
  await a.query(
    `insert into bank_transactions (company_id, bank_account_id, sequence, transaction_date, amount, raw)
     select $1, id, 1, $2::date, 10.50, '{"fee": 1.50, "rate": 1.10000}'::jsonb from bank_accounts where company_id = $1`,
    [companyId, golden.fiscalYear.end],
  );
  accountantId = await newUser(a);
  await a.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'accountant')`, [
    companyId, accountantId,
  ]);
}, 300_000);

afterAll(async () => {
  await a?.close();
  await b?.close();
  await rm(cwd, { recursive: true, force: true });
});

describe('ekwo company export', () => {
  it('writes a directory anybody can read, and check with shasum', async () => {
    const out = join(cwd, 'archive');
    const document = await ekwo(a, ['company', 'export', 'Travelling Example', '--out', out]);
    expect(document.error).toBeUndefined();
    expect(document.data).toMatchObject({ company: { id: companyId }, actingAs: ownerId, out });

    const manifest = JSON.parse(await readFile(join(out, 'manifest.json'), 'utf8')) as ArchiveManifest;
    expect(manifest.format).toBe('ekwo.company-archive');
    expect((await readdir(join(out, 'data'))).sort()).toEqual(manifest.tables.map((t) => `${t.name}.jsonl`).sort());
    for (const table of manifest.tables) {
      const body = await readFile(join(out, table.file), 'utf8');
      expect(createHash('sha256').update(body).digest('hex'), table.name).toBe(table.sha256);
      const lines = body.split('\n').filter((l) => l.length > 0);
      expect(lines.length, table.name).toBe(table.rows);
      for (const lineText of lines) expect(() => JSON.parse(lineText) as unknown).not.toThrow();
    }
    // Written as the database wrote it: the trailing zeros are still there.
    expect(await readFile(join(out, 'data', 'public.bank_transactions.jsonl'), 'utf8')).toContain('"fee": 1.50');
  });

  it('ran as the member it names, under row level security, and left the connection as it found it', async () => {
    const noted = await rows<{ actor_id: string }>(
      a,
      `select actor_id from audit_log where company_id = $1 and action = 'company_exported'`,
      [companyId],
    );
    expect(noted).toEqual([{ actor_id: ownerId }]);
    const after = await one<{ role: string; claims: string; installing: string }>(
      a,
      `select current_user::text as role, coalesce(current_setting('request.jwt.claims', true), '') as claims,
              coalesce(current_setting('ekwo.installing', true), '') as installing`,
    );
    expect(after.role).not.toBe('authenticated');
    expect(after.claims).toBe('');
    expect(after.installing).toBe('on');
  });

  it('is refused, code 3, for a member who does not hold company.export', async () => {
    const document = await ekwo(a, [
      'company', 'export', companyId, '--out', join(cwd, 'refused'), '--as-user', accountantId,
    ]);
    expect(document.exitCode).toBe(EXIT_REFUSED);
    expect(document.error).toMatchObject({ kind: 'refusal', name: 'not_allowed', sqlstate: '42501' });
    expect(await readdir(join(cwd, 'refused', 'data'))).toEqual([]);
  });

  it('is a wrong call without --out, or into a directory that holds something', async () => {
    expect((await ekwo(a, ['company', 'export', companyId])).exitCode).toBe(EXIT_USAGE);
    const again = await ekwo(a, ['company', 'export', companyId, '--out', join(cwd, 'archive')]);
    expect(again.exitCode).toBe(EXIT_USAGE);
    expect(again.error?.name).toBe('directory_not_empty');
  });
});

describe('ekwo company import', () => {
  it('catches a file damaged on the way before the database is asked anything', async () => {
    const damaged = join(cwd, 'damaged');
    const exported = await ekwo(a, ['company', 'export', companyId, '--out', damaged]);
    expect(exported.exitCode).toBe(0);
    const file = join(damaged, 'data', 'public.contacts.jsonl');
    await writeFile(file, (await readFile(file, 'utf8')).replace(/"name": "[^"]+"/, '"name": "Somebody else"'), 'utf8');

    const document = await ekwo(b, ['company', 'import', damaged]);
    // The CLI's own finding, not a refusal of the books: they were never asked.
    expect(document.exitCode).toBe(EXIT_ERROR);
    expect(document.error).toMatchObject({ kind: 'technical', name: 'archive_corrupt' });
    expect((await one<{ n: number }>(b, `select count(*)::int as n from companies where id = $1`, [companyId])).n).toBe(0);
  });

  it('takes the archive in, and the balance is the one that left', async () => {
    const admin = await newInstanceAdmin(b);
    const owner = await newUser(b);
    const document = await ekwo(b, ['company', 'import', join(cwd, 'archive'), '--as-user', admin, '--owner', owner]);
    expect(document.error).toBeUndefined();
    expect(document.data).toMatchObject({ company: { id: companyId, name: 'Travelling Example' }, owner });

    expect(await balance(b)).toEqual(await balance(a));
    expect((await balance(b)).length).toBeGreaterThan(0);
    const raw = await one<{ raw: string }>(b, `select raw::text from bank_transactions where company_id = $1`, [companyId]);
    expect(raw.raw).toContain('1.50');
  });

  it('is refused, code 3, the second time and for somebody who does not administer the installation', async () => {
    const again = await ekwo(b, ['company', 'import', join(cwd, 'archive')]);
    expect(again.exitCode).toBe(EXIT_REFUSED);
    expect(again.error?.name).toBe('company_already_here');

    const c = await freshDatabase();
    try {
      const nobody = await newUser(c);
      const refused = await ekwo(c, ['company', 'import', join(cwd, 'archive'), '--as-user', nobody]);
      expect(refused.exitCode).toBe(EXIT_REFUSED);
      expect(refused.error).toMatchObject({ name: 'not_instance_admin', sqlstate: '42501' });

      // And with nobody named it arrives by the installer's hand, owned by nobody yet.
      const bare = await ekwo(c, ['company', 'import', join(cwd, 'archive')]);
      expect(bare.exitCode).toBe(0);
      expect(bare.data).toMatchObject({ owner: null });
      expect(bare.warnings.join(' ')).toContain('No owner was named');
    } finally {
      await c.close();
    }
  }, 120_000);

  it('is a wrong call on a directory that is not an archive', async () => {
    const document = await ekwo(b, ['company', 'import', cwd]);
    expect(document.exitCode).toBe(EXIT_USAGE);
    expect(document.error?.name).toBe('not_an_archive');
  });
});
