/**
 * `ekwo close` and `ekwo reopen`: a month locked and unlocked, a financial
 * year closed, reopened and closed for good.
 *
 * Each command runs as a signed-in person, under --json, against a real
 * Postgres behind the instance's two HTTP surfaces, and every expectation is
 * read back from the database. The first claim is that nothing closes the
 * books by ricochet: with nobody at a terminal to ask, a verb that is not
 * given --yes refuses and changes nothing.
 */

import { mkdtemp, readFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { EXIT_REFUSED, EXIT_USAGE, run, validate, type OutputDocument } from '../../packages/cli/src/index.js';
import { monthBounds } from '../../packages/cli/src/commands/close.js';
import { freshDatabase, one, repoRoot } from '../helpers/db.js';
import { newCompany, newUser } from '../helpers/factory.js';
import { somePack } from '../helpers/packs.js';
import { ANON_KEY, FAKE_URL, fakeSupabase, type FakeSupabase } from './fake-supabase.js';

const HOME = somePack.manifest.country;
const PASSWORD = 'correct horse battery staple';
const YEAR = 'Year 2026';

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

/** Runs a command as one of the two people, under --json, and holds the answer to the schema. */
async function ekwo(argv: string[], as: 'owner' | 'viewer' = 'owner'): Promise<OutputDocument> {
  const env = { EKWO_CONFIG_DIR: join(root, as) };
  const captured = await capture(() => run([...argv, '--json'], { fetchImpl: instance.fetchImpl, env }));
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

const lockDate = async (): Promise<string | null> =>
  (await one<{ d: string | null }>(pg, `select lock_date::text as d from companies where id = $1`, [companyId])).d;

const year = async (): Promise<{ is_closed: boolean; final: boolean }> =>
  one(pg, `select is_closed, finally_closed_at is not null as final from fiscal_years where company_id = $1`, [companyId]);

beforeAll(async () => {
  schema = JSON.parse(await readFile(join(repoRoot, 'packages', 'cli', 'schema', 'output.1.json'), 'utf8')) as Row;
  pg = await freshDatabase();
  const owner = await newUser(pg, 'owner@example.test');
  const viewer = await newUser(pg, 'viewer@example.test');
  companyId = (
    await newCompany(pg, { country: HOME, name: 'Example One', ownerId: owner, fiscalYear: { name: YEAR, start: '2026-01-01', end: '2026-12-31' } })
  ).companyId;
  await pg.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'viewer')`, [companyId, viewer]);

  root = await mkdtemp(join(tmpdir(), 'ekwo-close-'));
  instance = fakeSupabase(pg);
  instance.addUser(owner, 'owner@example.test', PASSWORD);
  instance.addUser(viewer, 'viewer@example.test', PASSWORD);
  for (const who of ['owner', 'viewer'] as const) {
    const signedIn = await ekwo(
      ['login', '--supabase-url', FAKE_URL, '--anon-key', ANON_KEY, '--email', `${who}@example.test`, '--password', PASSWORD],
      who,
    );
    expect(signedIn.exitCode).toBe(0);
    expect((await ekwo(['use', 'Example One'], who)).exitCode).toBe(0);
  }
});

afterAll(async () => {
  await pg.close();
  await rm(root, { recursive: true, force: true });
});

describe('the bounds of a month', () => {
  it('are the calendar\'s, in a leap year and across a new year', () => {
    expect(monthBounds('2028-02', '')).toEqual({ month: '2028-02', lastDay: '2028-02-29', dayBefore: '2028-01-31' });
    expect(monthBounds('2026-01', '')).toEqual({ month: '2026-01', lastDay: '2026-01-31', dayBefore: '2025-12-31' });
    expect(monthBounds('2026-12', '')).toMatchObject({ lastDay: '2026-12-31', dayBefore: '2026-11-30' });
  });

  it('refuse anything that is not YYYY-MM', () => {
    for (const bad of ['2026-13', '2026-3', '2026-03-31', 'March', undefined]) {
      expect(() => monthBounds(bad, '')).toThrow(/^bad_month:/);
    }
  });
});

describe('a month', () => {
  it('is never closed without a yes: with nobody to ask, the command refuses and changes nothing', async () => {
    const asked = await ekwo(['close', 'month', '2026-03']);
    expect(asked.exitCode).toBe(EXIT_USAGE);
    expect(asked.error?.name).toBe('confirmation_required');
    expect(await lockDate()).toBeNull();
  });

  it('closes on its last day, and moves the lock forward only', async () => {
    const closed = await ekwo(['close', 'month', '2026-03', '--yes']);
    expect(closed.exitCode).toBe(0);
    expect(closed.command).toBe('close month');
    expect(closed.data).toMatchObject({ company: { lock_date: '2026-03-31' }, previous_lock_date: null });
    expect(await lockDate()).toBe('2026-03-31');

    // An earlier month is already covered: moving the lock back is a reopening.
    const earlier = await ekwo(['close', 'month', '2026-02', '--yes']);
    expect(earlier.exitCode).toBe(EXIT_USAGE);
    expect(earlier.error?.name).toBe('already_closed');
    expect(await lockDate()).toBe('2026-03-31');

    const next = await ekwo(['close', 'month', '2026-04', '--yes']);
    expect(next.data).toMatchObject({ company: { lock_date: '2026-04-30' }, previous_lock_date: '2026-03-31' });
  });

  it('is closed by an owner only', async () => {
    const refused = await ekwo(['close', 'month', '2026-05', '--yes'], 'viewer');
    expect(refused.error?.name).toBe('not_owner');
    expect(await lockDate()).toBe('2026-04-30');
  });

  it('reopens with every month after it, back to the day before', async () => {
    const reopened = await ekwo(['reopen', 'month', '2026-04', '--yes']);
    expect(reopened.exitCode).toBe(0);
    expect(reopened.command).toBe('reopen month');
    expect(reopened.data).toMatchObject({ company: { lock_date: '2026-03-31' }, previous_lock_date: '2026-04-30' });

    const open = await ekwo(['reopen', 'month', '2026-04', '--yes']);
    expect(open.error?.name).toBe('not_closed');

    expect((await ekwo(['reopen', 'month', '2026-01', '--yes'])).data).toMatchObject({ company: { lock_date: '2025-12-31' } });
    await pg.query(`update companies set lock_date = null where id = $1`, [companyId]);
  });
});

describe('a financial year', () => {
  it('is named as the company names it, and an unknown one says which exist', async () => {
    const unknown = await ekwo(['close', 'year', '1999', '--yes']);
    expect(unknown.exitCode).toBe(EXIT_USAGE);
    expect(unknown.error?.name).toBe('no_fiscal_year');
    expect(unknown.error?.message).toContain(YEAR);
    expect((await ekwo(['close', 'year', YEAR])).error?.name).toBe('confirmation_required');
    expect(await year()).toEqual({ is_closed: false, final: false });
  });

  it('closes through close_fiscal_year(), and reopens', async () => {
    const closed = await ekwo(['close', 'year', YEAR, '--yes']);
    expect(closed.exitCode).toBe(0);
    expect(closed.command).toBe('close year');
    expect(closed.data).toMatchObject({ close: { result: expect.any(String) }, final_close: { is_closed: true } });
    expect(await year()).toEqual({ is_closed: true, final: false });

    const reopened = await ekwo(['reopen', 'year', YEAR, '--yes']);
    expect(reopened.exitCode).toBe(0);
    expect(await year()).toEqual({ is_closed: false, final: false });
  });

  it('closes for good with --final, after which the database refuses to reopen it', async () => {
    expect((await ekwo(['close', 'year', YEAR, '--yes'])).exitCode).toBe(0);
    const final = await ekwo(['close', 'year', YEAR, '--final', '--yes']);
    expect(final.exitCode).toBe(0);
    expect(final.data).toMatchObject({ final_close: { finally_closed_at: expect.any(String) } });
    expect(await year()).toEqual({ is_closed: true, final: true });

    const refused = await ekwo(['reopen', 'year', YEAR, '--yes']);
    expect(refused.exitCode).toBe(EXIT_REFUSED);
    expect(refused.error?.name).toBe('fiscal_year_finally_closed');
  });
});
