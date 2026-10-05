/**
 * The invitation to register, as the command line gives it.
 *
 * At the end of an `init` nobody was asked during, and in `ekwo status`, an
 * installation that is not registered is told once what registering gives and
 * the one command that does it. Nothing waits on it, it is a field under
 * `--json` rather than prose on the standard output, it disappears once the
 * installation is registered, and `EKWO_NO_REGISTER_INVITE` hides it.
 */

import { mkdtemp, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import { REGISTER_INVITE_ENV, REGISTRATION_INVITATION } from '../../packages/core/src/index.js';
import { run, type OutputDocument, type SqlClient } from '../../packages/cli/src/index.js';
import { somePack } from '../helpers/packs.js';
import { emptyDatabase, fakeFetch, makeAuthUser } from './helpers.js';

const HOME = somePack.manifest.country;
const DB_URL = 'postgresql://postgres:secret@localhost:5432/postgres';
const COMMAND = REGISTRATION_INVITATION.command;

interface Captured {
  exitCode: number;
  stdout: string;
  stderr: string;
}

async function capture(fn: () => Promise<number>): Promise<Captured> {
  const out = process.stdout.write.bind(process.stdout);
  const err = process.stderr.write.bind(process.stderr);
  let stdout = '';
  let stderr = '';
  process.stdout.write = ((chunk: string | Uint8Array) => {
    stdout += String(chunk);
    return true;
  }) as typeof process.stdout.write;
  process.stderr.write = ((chunk: string | Uint8Array) => {
    stderr += String(chunk);
    return true;
  }) as typeof process.stderr.write;
  try {
    return { exitCode: await fn(), stdout, stderr };
  } finally {
    process.stdout.write = out;
    process.stderr.write = err;
  }
}

function occurrences(text: string, needle: string): number {
  return text.split(needle).length - 1;
}

let db: SqlClient;
let cwd: string;
let adminUserId: string;
let initDocument: OutputDocument;
let initStderr: string;

const connect = async (): Promise<SqlClient> => ({ ...db, close: async () => {} });
const cli = (argv: string[]): Promise<Captured> =>
  capture(() => run([...argv, '--db-url', DB_URL], { connect, cwd }));

beforeAll(async () => {
  ({ db } = await emptyDatabase());
  adminUserId = await makeAuthUser(db, 'first@example.test');
  cwd = await mkdtemp(join(tmpdir(), 'ekwo-invitation-'));
  delete process.env[REGISTER_INVITE_ENV];
  const installed = await cli([
    'init',
    '--yes',
    '--json',
    '--country',
    HOME,
    '--org',
    'Example Group',
    '--company',
    'Example One',
    '--admin-user-id',
    adminUserId,
    '--fiscal-year',
    '2026',
    '--fiscal-year-start',
    '2026-01-01',
    '--language',
    somePack.languages[0] as string,
    '--chart',
    (somePack.charts.find((chart) => chart.is_default) ?? somePack.charts[0]!).code,
    ...(somePack.report?.periods[0] === undefined ? [] : ['--vat-period', somePack.report.periods[0]]),
  ]);
  expect(installed.exitCode).toBe(0);
  initDocument = JSON.parse(installed.stdout) as OutputDocument;
  initStderr = installed.stderr;
});

afterEach(() => {
  delete process.env[REGISTER_INVITE_ENV];
});

afterAll(async () => {
  await db.close().catch(() => {});
  await rm(cwd, { recursive: true, force: true });
});

describe('at the end of an init nobody was asked during', () => {
  it('is a field of the document', () => {
    expect((initDocument.data as { registration: unknown }).registration).toEqual({
      registered: false,
      invitation: REGISTRATION_INVITATION,
    });
  });

  it('is said once, after everything else, and asks nothing', () => {
    expect(occurrences(initStderr, COMMAND)).toBe(1);
    expect(initStderr.indexOf(COMMAND)).toBeGreaterThan(initStderr.indexOf('Four things on your project'));
    expect(initStderr).toContain(REGISTRATION_INVITATION.silence);
  });
});

describe('ekwo status', () => {
  it('says it once to a person, on an installation that is not registered', async () => {
    const printed = await cli(['status']);
    expect(printed.exitCode).toBe(0);
    expect(occurrences(printed.stdout, COMMAND)).toBe(1);
    for (const benefit of REGISTRATION_INVITATION.gives) expect(printed.stdout).toContain(benefit);
  });

  it('puts it in a field under --json, and the standard output stays one document', async () => {
    const printed = await cli(['status', '--json']);
    const document = JSON.parse(printed.stdout) as OutputDocument;
    expect((document.data as { registration: unknown }).registration).toEqual({
      registered: false,
      invitation: REGISTRATION_INVITATION,
    });
  });

  it('is quiet when the environment says so', async () => {
    process.env[REGISTER_INVITE_ENV] = '1';
    const printed = await cli(['status']);
    expect(printed.stdout).not.toContain(COMMAND);
    const document = JSON.parse((await cli(['status', '--json'])).stdout) as OutputDocument;
    expect((document.data as { registration: unknown }).registration).toEqual({
      registered: false,
      invitation: null,
    });
  });

  it('is gone once the installation is registered, and back once it is not', async () => {
    const registry = fakeFetch(() => ({ status: 200, body: {} }));
    const registered = await capture(() =>
      run(
        ['register', '--yes', '--email', 'ops@example.test', '--registry-url', 'https://registry.example.test', '--db-url', DB_URL],
        { connect, cwd, fetchImpl: registry.fetchImpl as typeof globalThis.fetch },
      ),
    );
    expect(registered.exitCode).toBe(0);

    const after = await cli(['status']);
    expect(after.stdout).not.toContain(COMMAND);
    const document = JSON.parse((await cli(['status', '--json'])).stdout) as OutputDocument;
    expect((document.data as { registration: unknown }).registration).toEqual({
      registered: true,
      invitation: null,
    });

    expect((await cli(['unregister', '--yes'])).exitCode).toBe(0);
    expect(occurrences((await cli(['status'])).stdout, COMMAND)).toBe(1);
  });
});

describe('ekwo --help', () => {
  it('gives a first session and documents how to hide the invitation', async () => {
    const printed = await capture(() => run(['--help']));
    expect(printed.stdout).toContain('A first session');
    expect(printed.stdout).toContain(REGISTER_INVITE_ENV);
    for (const step of ['ekwo login', 'ekwo whoami', 'ekwo doc list', '--dry-run', 'ekwo cancel']) {
      expect(printed.stdout).toContain(step);
    }
  });
});
