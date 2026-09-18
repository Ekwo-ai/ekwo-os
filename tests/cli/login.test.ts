/**
 * Signing in, the profiles, the company in use, and `whoami`.
 *
 * Every test runs the command itself — flags in, exit code and one JSON
 * document out — against an instance that is a real Postgres behind the two
 * HTTP surfaces the CLI speaks (`fake-supabase.ts`). So what `whoami` lists is
 * what row level security lets that person see, and not what a mock was told
 * to answer.
 *
 * The two proofs the card asks for are named as such below: a session that
 * loses its token and renews it, and a `service_role` key refused.
 */

import { execFileSync } from 'node:child_process';
import { mkdir, mkdtemp, readFile, readdir, rm, stat, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import type { PGlite } from '@electric-sql/pglite';
import { serviceRoleRefusal } from '@ekwo-ai/core';
import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import {
  EXIT_ERROR,
  EXIT_REFUSED,
  EXIT_USAGE,
  UserClient,
  execute,
  parseArgs,
  run,
  validate,
  type OutputDocument,
} from '../../packages/cli/src/index.js';
import { asUser, freshDatabase, one, repoRoot, rows } from '../helpers/db.js';
import { newCompany, newUser } from '../helpers/factory.js';
import { somePack } from '../helpers/packs.js';
import { ANON_KEY, FAKE_URL, fakeSupabase, keyWithRole, type FakeSupabase } from './fake-supabase.js';

const HOME = somePack.manifest.country;
const PASSWORD = 'correct horse battery staple';

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
  process.stdout.write = ((chunk: string | Uint8Array) => ((stdout += String(chunk)), true)) as typeof process.stdout.write;
  process.stderr.write = ((chunk: string | Uint8Array) => ((stderr += String(chunk)), true)) as typeof process.stderr.write;
  try {
    return { exitCode: await fn(), stdout, stderr };
  } finally {
    process.stdout.write = out;
    process.stderr.write = err;
  }
}

let pg: PGlite;
let schema: Record<string, unknown>;
let instance: FakeSupabase;
let root: string;
let configDir: string;
let cwd: string;

// Two people, three companies. Ada owns two; Grace owns the third and is a
// guest on none of Ada's — so each has a company the other must never see.
let ada: string;
let grace: string;
let first: string;
let second: string;
let hidden: string;

function env(extra: Record<string, string> = {}): NodeJS.ProcessEnv {
  return { EKWO_CONFIG_DIR: configDir, ...extra };
}

async function ekwo(argv: string[], variables: NodeJS.ProcessEnv = env()): Promise<OutputDocument & { captured: Captured }> {
  const captured = await capture(() =>
    run([...argv, '--json'], { fetchImpl: instance.fetchImpl, env: variables, cwd }),
  );
  const document = JSON.parse(captured.stdout) as OutputDocument;
  expect(validate(document, schema)).toEqual([]);
  expect(document.exitCode).toBe(captured.exitCode);
  if (document.error === undefined) {
    const shape = ((schema['$defs'] as Record<string, Record<string, unknown>>)['data'] ?? {})[document.command];
    expect(shape, `output.1.json describes no data for "${document.command}"`).toBeDefined();
    expect(validate(document.data, shape as Record<string, unknown>, schema)).toEqual([]);
  }
  return { ...document, captured };
}

const login = (email: string, extra: string[] = [], variables?: NodeJS.ProcessEnv) =>
  ekwo(['login', '--supabase-url', FAKE_URL, '--anon-key', ANON_KEY, '--email', email, '--password', PASSWORD, ...extra], variables);

async function stored(file: string): Promise<string> {
  return readFile(join(configDir, file), 'utf8');
}

beforeAll(async () => {
  schema = JSON.parse(await readFile(join(repoRoot, 'packages', 'cli', 'schema', 'output.1.json'), 'utf8')) as Record<string, unknown>;
  pg = await freshDatabase();
  ada = await newUser(pg, 'ada@example.test');
  grace = await newUser(pg, 'grace@example.test');
  first = (await newCompany(pg, { country: HOME, name: 'Example One', ownerId: ada })).companyId;
  second = (await newCompany(pg, { country: HOME, name: 'Example Two', ownerId: ada })).companyId;
  hidden = (await newCompany(pg, { country: HOME, name: 'Somebody Else', ownerId: grace })).companyId;
  root = await mkdtemp(join(tmpdir(), 'ekwo-login-'));
});

afterAll(async () => {
  await pg.close();
  await rm(root, { recursive: true, force: true });
});

beforeEach(async () => {
  instance = fakeSupabase(pg);
  instance.addUser(ada, 'ada@example.test', PASSWORD);
  instance.addUser(grace, 'grace@example.test', PASSWORD);
  const home = await mkdtemp(join(root, 'home-'));
  configDir = join(home, '.config', 'ekwo');
  cwd = join(home, 'work');
  await mkdir(cwd, { recursive: true });
});

describe('ekwo login', () => {
  it('keeps the session in the configuration directory, for its owner alone, and the password nowhere', async () => {
    const answer = await login('ada@example.test');
    expect(answer.exitCode).toBe(0);
    expect(answer.data).toMatchObject({ profile: 'default', user: { id: ada, email: 'ada@example.test' }, company: null });
    expect(answer.context).toEqual({ profile: 'default', instance: FAKE_URL, company: null });

    expect((await readdir(configDir)).sort()).toEqual(['credentials.json', 'profiles.json']);
    if (process.platform !== 'win32') {
      expect((await stat(configDir)).mode & 0o777).toBe(0o700);
      expect((await stat(join(configDir, 'credentials.json'))).mode & 0o777).toBe(0o600);
      expect((await stat(join(configDir, 'profiles.json'))).mode & 0o777).toBe(0o600);
    }
    const session = (JSON.parse(await stored('credentials.json')) as Record<string, Record<string, string>>)['default'];
    expect(session?.['access_token']).toBeTruthy();
    expect(session?.['refresh_token']).toBeTruthy();

    // No token where the pointers are, no password anywhere, and neither of
    // them in what was printed.
    const everything = (await stored('profiles.json')) + (await stored('credentials.json'));
    expect(await stored('profiles.json')).not.toContain(session?.['access_token'] as string);
    expect(everything).not.toContain(PASSWORD);
    const printed = answer.captured.stdout + answer.captured.stderr;
    expect(printed).not.toContain(session?.['access_token'] as string);
    expect(printed).not.toContain(session?.['refresh_token'] as string);
    expect(printed).not.toContain(PASSWORD);
    // Nothing was left in the working directory.
    expect(await readdir(cwd)).toEqual([]);
  });

  it('refuses to keep a session inside a repository, before anything is sent', async () => {
    const repository = await mkdtemp(join(root, 'repo-'));
    execFileSync('git', ['init', '--quiet', repository]);
    const inside = join(repository, '.ekwo');
    const answer = await login('ada@example.test', [], { EKWO_CONFIG_DIR: inside });
    expect(answer.exitCode).toBe(EXIT_USAGE);
    expect(answer.error).toMatchObject({ kind: 'usage', name: 'config_dir_in_repository' });
    expect(instance.calls).toEqual([]);
    await expect(stat(inside)).rejects.toThrow();
  });

  it('answers a wrong password with code 1, names it, and keeps nothing', async () => {
    const answer = await ekwo(['login', '--supabase-url', FAKE_URL, '--anon-key', ANON_KEY, '--email', 'ada@example.test', '--password', 'wrong']);
    expect(answer.exitCode).toBe(EXIT_ERROR);
    expect(answer.error).toMatchObject({ kind: 'technical', name: 'sign_in_failed', message: 'sign_in_failed: Invalid login credentials' });
    await expect(stat(configDir)).rejects.toThrow();
  });

  it('answers an instance that does not answer with code 1, and says which', async () => {
    const answer = await ekwo(['login', '--supabase-url', 'https://elsewhere.example.test', '--anon-key', ANON_KEY, '--email', 'ada@example.test', '--password', PASSWORD]);
    expect(answer.exitCode).toBe(EXIT_ERROR);
    expect(answer.error).toMatchObject({ kind: 'technical', name: 'instance_unreachable' });
    expect(answer.error?.message).toContain('https://elsewhere.example.test');
    await expect(stat(configDir)).rejects.toThrow();
  });

  it('never asks: with no terminal, what is missing is a wrong call', async () => {
    const answer = await ekwo(['login', '--supabase-url', FAKE_URL, '--anon-key', ANON_KEY, '--email', 'ada@example.test']);
    expect(answer.exitCode).toBe(EXIT_USAGE);
    expect(answer.error).toMatchObject({ kind: 'usage', name: 'missing_input' });
    expect(instance.calls).toEqual([]);
  });

  it('reads the instance from ekwo.json, and from the profile the second time', async () => {
    await writeFile(join(cwd, 'ekwo.json'), JSON.stringify({ project_url: FAKE_URL }));
    const firstTime = await ekwo(['login', '--anon-key', ANON_KEY, '--email', 'ada@example.test', '--password', PASSWORD]);
    expect(firstTime.exitCode).toBe(0);
    await rm(join(cwd, 'ekwo.json'));
    // A session that ended: `ekwo login` and a password, nothing else.
    const again = await ekwo(['login'], env({ EKWO_PASSWORD: PASSWORD }));
    expect(again.exitCode).toBe(0);
    expect(again.data).toMatchObject({ instance: { url: FAKE_URL }, user: { id: ada } });
  });
});

describe('a service_role key is refused, as the MCP server refuses it', () => {
  const SERVICE = keyWithRole('service_role');

  it('in the publishable-key slot, in the words the core holds, before anything is sent', async () => {
    const answer = await ekwo(['login', '--supabase-url', FAKE_URL, '--anon-key', SERVICE, '--email', 'ada@example.test', '--password', PASSWORD]);
    expect(answer.exitCode).toBe(EXIT_USAGE);
    expect(answer.error).toMatchObject({ kind: 'usage', name: 'service_role_refused' });
    expect(answer.error?.message).toBe(serviceRoleRefusal('--anon-key', 'apikey', 'this command line', 'run `ekwo login`'));
    expect(instance.calls).toEqual([]);
    await expect(stat(configDir)).rejects.toThrow();
  });

  it('in the newer shape too', async () => {
    const answer = await ekwo(['login', '--supabase-url', FAKE_URL, '--anon-key', 'sb_secret_abcdef', '--email', 'ada@example.test', '--password', PASSWORD]);
    expect(answer.error?.name).toBe('service_role_refused');
    expect(instance.calls).toEqual([]);
  });

  it('in the token slot of the environment, the quiet door', async () => {
    const answer = await ekwo(['whoami'], env({ SUPABASE_URL: FAKE_URL, SUPABASE_ANON_KEY: ANON_KEY, EKWO_ACCESS_TOKEN: SERVICE }));
    expect(answer.exitCode).toBe(EXIT_USAGE);
    expect(answer.error?.name).toBe('service_role_refused');
    expect(answer.error?.message).toContain('Authorization header');
    expect(instance.calls).toEqual([]);
  });

  it('in a session file somebody edited', async () => {
    await login('ada@example.test');
    const sessions = JSON.parse(await stored('credentials.json')) as Record<string, Record<string, unknown>>;
    (sessions['default'] as Record<string, unknown>)['access_token'] = SERVICE;
    await writeFile(join(configDir, 'credentials.json'), JSON.stringify(sessions), { mode: 0o600 });
    instance.calls.length = 0;
    const answer = await ekwo(['whoami']);
    expect(answer.error?.name).toBe('service_role_refused');
    expect(instance.calls).toEqual([]);
  });

  it('and as the flag `ekwo init` takes, typed on a command that keeps books', async () => {
    for (const command of [['whoami'], ['use', 'Example One'], ['login']]) {
      const answer = await ekwo([...command, '--service-role-key', SERVICE]);
      expect(answer.exitCode).toBe(EXIT_USAGE);
      expect(answer.error?.name).toBe('service_role_refused');
    }
    expect(instance.calls).toEqual([]);
  });
});

describe('ekwo whoami', () => {
  it('says who, on which instance and schema, and lists the companies row level security lets through', async () => {
    await login('ada@example.test');
    const answer = await ekwo(['whoami']);
    expect(answer.exitCode).toBe(0);
    const installed = await one<{ v: string }>(pg, 'select ekwo_schema_version() as v');
    expect(answer.data).toMatchObject({
      source: 'profile',
      profile: 'default',
      profiles: ['default'],
      instance: { url: FAKE_URL, schemaVersion: installed.v },
      user: { id: ada, email: 'ada@example.test' },
      company: null,
      capabilities: null,
    });
    const companies = (answer.data as { companies: { id: string; name: string }[] }).companies;
    expect(companies.map((c) => c.id).sort()).toEqual([first, second].sort());
    expect(JSON.stringify(answer)).not.toContain('Somebody Else');
    // No company in use, and the document says so where a caller looks first.
    expect(answer.context).toEqual({ profile: 'default', instance: FAKE_URL, company: null });
  });

  it('answers the capabilities the database answers, and works none out', async () => {
    await login('grace@example.test');
    // Grace becomes a guest of Ada's first company, on the least of the presets.
    const presets = await rows<{ role: string; held: number }>(
      pg,
      `select role, count(*)::int as held from role_capabilities group by role order by held, role`,
    );
    const least = presets[0]?.role as string;
    await pg.query(`insert into company_members (company_id, user_id, role) values ($1, $2, $3)`, [first, grace, least]);
    try {
      const asked = await asUser(pg, grace, () => rows<{ code: string }>(pg, 'select member_capabilities($1) as code', [first]));
      const answer = await ekwo(['whoami', '--company', first]);
      expect((answer.data as { capabilities: string[] }).capabilities).toEqual(asked.map((r) => r.code));
      const owner = await asUser(pg, ada, () => rows<{ code: string }>(pg, 'select member_capabilities($1) as code', [first]));
      expect(asked.length).toBeLessThan(owner.length);
    } finally {
      await pg.query(`delete from company_members where company_id = $1 and user_id = $2`, [first, grace]);
    }
  });

  it('prints a table for a person, and no JSON', async () => {
    await login('ada@example.test');
    const printed = await capture(() => run(['whoami'], { fetchImpl: instance.fetchImpl, env: env() }));
    expect(printed.exitCode).toBe(0);
    expect(printed.stdout).toMatch(/name\s+country\s+currency\s+id/);
    expect(printed.stdout).toContain('ada@example.test');
    expect(printed.stdout).not.toContain('"ok"');
  });

  it('answers nobody signed in with code 2, and an unknown profile by name', async () => {
    const nobody = await ekwo(['whoami']);
    expect(nobody.exitCode).toBe(EXIT_USAGE);
    expect(nobody.error).toMatchObject({ kind: 'usage', name: 'not_signed_in' });
    await login('ada@example.test');
    const unknown = await ekwo(['whoami', '--profile', 'production']);
    expect(unknown.exitCode).toBe(EXIT_USAGE);
    expect(unknown.error?.name).toBe('unknown_profile');
  });
});

describe('a session that loses its token', () => {
  it('renews it, makes the call again, and keeps the rotated session', async () => {
    await login('ada@example.test');
    const before = JSON.parse(await stored('credentials.json')) as Record<string, Record<string, string>>;
    instance.expireAccessTokens();
    instance.calls.length = 0;

    const answer = await ekwo(['whoami']);
    expect(answer.exitCode).toBe(0);
    expect((answer.data as { user: { id: string } }).user.id).toBe(ada);
    // Refused once, renewed once, asked again — and never a second renewal.
    expect(instance.calls.slice(0, 3)).toEqual([
      'GET /auth/v1/user',
      'POST /auth/v1/token?grant_type=refresh_token',
      'GET /auth/v1/user',
    ]);
    expect(instance.calls.filter((call) => call.includes('grant_type'))).toHaveLength(1);

    const after = JSON.parse(await stored('credentials.json')) as Record<string, Record<string, string>>;
    expect(after['default']?.['access_token']).not.toBe(before['default']?.['access_token']);
    expect(after['default']?.['refresh_token']).not.toBe(before['default']?.['refresh_token']);
    // The instance rotated the refresh token: the old one is dead, the kept one is not.
    expect(instance.refreshTokenIsLive(before['default']?.['refresh_token'] as string)).toBe(false);
    expect(instance.refreshTokenIsLive(after['default']?.['refresh_token'] as string)).toBe(true);
    if (process.platform !== 'win32') {
      expect((await stat(join(configDir, 'credentials.json'))).mode & 0o777).toBe(0o600);
    }
    // And the next command needs no renewal at all.
    instance.calls.length = 0;
    expect((await ekwo(['whoami'])).exitCode).toBe(0);
    expect(instance.calls.some((call) => call.includes('grant_type'))).toBe(false);
  });

  it('renews ahead of time a token it knows has lapsed, without being refused first', async () => {
    await login('ada@example.test');
    const sessions = JSON.parse(await stored('credentials.json')) as Record<string, Record<string, unknown>>;
    (sessions['default'] as Record<string, unknown>)['expires_at'] = Math.floor(Date.now() / 1000) - 10;
    await writeFile(join(configDir, 'credentials.json'), JSON.stringify(sessions), { mode: 0o600 });
    instance.calls.length = 0;
    expect((await ekwo(['whoami'])).exitCode).toBe(0);
    expect(instance.calls[0]).toBe('POST /auth/v1/token?grant_type=refresh_token');
  });

  it('says the session is over when it cannot be renewed, with code 2 and no loop', async () => {
    await login('ada@example.test');
    instance.revokeEverything();
    instance.calls.length = 0;
    const answer = await ekwo(['whoami']);
    expect(answer.exitCode).toBe(EXIT_USAGE);
    expect(answer.error).toMatchObject({ kind: 'usage', name: 'session_expired' });
    expect(answer.error?.message).toContain('ekwo login');
    expect(instance.calls).toEqual(['GET /auth/v1/user', 'POST /auth/v1/token?grant_type=refresh_token']);
  });
});

describe('ekwo use', () => {
  it('records the company, and every answer afterwards names it', async () => {
    await login('ada@example.test');
    const used = await ekwo(['use', 'example two']);
    expect(used.exitCode).toBe(0);
    expect(used.data).toMatchObject({ profile: 'default', company: { id: second, name: 'Example Two', country: HOME } });
    expect(used.context?.company).toEqual({ id: second, name: 'Example Two' });

    const who = await ekwo(['whoami']);
    expect(who.context?.company).toEqual({ id: second, name: 'Example Two' });
    expect((who.data as { company: { id: string } }).company.id).toBe(second);
    expect((who.data as { capabilities: string[] }).capabilities.length).toBeGreaterThan(0);
    expect((who.data as { companies: { id: string; inUse: boolean }[] }).companies.filter((c) => c.inUse).map((c) => c.id)).toEqual([second]);
  });

  it('is overridden by --company for one command, and not rewritten by it', async () => {
    await login('ada@example.test');
    await ekwo(['use', second]);
    const once = await ekwo(['whoami', '--company', 'Example One']);
    expect(once.context?.company).toEqual({ id: first, name: 'Example One' });
    expect((await ekwo(['whoami'])).context?.company?.id).toBe(second);
  });

  it('does not know a company its user cannot see, and does not name it either', async () => {
    await login('ada@example.test');
    for (const wanted of ['Somebody Else', hidden]) {
      const answer = await ekwo(['use', wanted]);
      expect(answer.exitCode).toBe(EXIT_USAGE);
      expect(answer.error?.name).toBe('unknown_company');
      expect(answer.error?.message).toContain('Example One, Example Two');
    }
    expect((await ekwo(['whoami'])).context?.company).toBeNull();
  });

  it('says when the company in use stopped being visible, rather than answering for it', async () => {
    await login('grace@example.test');
    await pg.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'owner')`, [first, grace]);
    await ekwo(['use', first]);
    await pg.query(`delete from company_members where company_id = $1 and user_id = $2`, [first, grace]);
    const answer = await ekwo(['whoami']);
    expect(answer.exitCode).toBe(0);
    expect(answer.context?.company).toBeNull();
    expect(answer.warnings.join(' ')).toContain('no longer visible');
  });

  it('forgets the company when somebody else signs in to the profile', async () => {
    await login('ada@example.test');
    await ekwo(['use', first]);
    const other = await login('grace@example.test');
    expect(other.context?.company).toBeNull();
    // The same person signing in again keeps it.
    await ekwo(['use', hidden]);
    expect((await login('grace@example.test')).context?.company?.id).toBe(hidden);
  });
});

describe('profiles', () => {
  it('hold one instance and one person each, chosen by --profile or EKWO_PROFILE', async () => {
    await login('ada@example.test');
    await login('grace@example.test', ['--profile', 'client']);
    // The last one signed in to is the one in use.
    expect((await ekwo(['whoami'])).data).toMatchObject({ profile: 'client', user: { id: grace }, profiles: ['client', 'default'] });
    expect((await ekwo(['whoami', '--profile', 'default'])).data).toMatchObject({ user: { id: ada } });
    expect((await ekwo(['whoami'], env({ EKWO_PROFILE: 'default' }))).data).toMatchObject({ user: { id: ada } });
    // The flag is nearer than the variable.
    expect((await ekwo(['whoami', '--profile', 'client'], env({ EKWO_PROFILE: 'default' }))).data).toMatchObject({ user: { id: grace } });

    await ekwo(['use', 'Example One', '--profile', 'default']);
    expect((await ekwo(['whoami', '--profile', 'default'])).context?.company?.id).toBe(first);
    expect((await ekwo(['whoami', '--profile', 'client'])).context?.company).toBeNull();
  });

  it('refuse a name that would be a path', async () => {
    const answer = await login('ada@example.test', ['--profile', '../elsewhere']);
    expect(answer.exitCode).toBe(EXIT_USAGE);
    expect(answer.error?.name).toBe('bad_profile_name');
  });
});

describe('the environment comes first, and touches no file', () => {
  it('signs in for one command and leaves the disk as it was', async () => {
    await login('ada@example.test');
    const before = (await stored('credentials.json')) + (await stored('profiles.json'));
    const ci = env({ SUPABASE_URL: FAKE_URL, SUPABASE_ANON_KEY: ANON_KEY, EKWO_EMAIL: 'grace@example.test', EKWO_PASSWORD: PASSWORD });

    const answer = await ekwo(['whoami', '--company', 'Somebody Else'], ci);
    expect(answer.exitCode).toBe(0);
    expect(answer.data).toMatchObject({ source: 'environment', profile: null, profiles: [], user: { id: grace } });
    expect(answer.context).toEqual({ profile: null, instance: FAKE_URL, company: { id: hidden, name: 'Somebody Else' } });
    expect((await stored('credentials.json')) + (await stored('profiles.json'))).toBe(before);
  });

  it('works with a token in hand and no configuration directory at all', async () => {
    await login('ada@example.test');
    const token = (JSON.parse(await stored('credentials.json')) as Record<string, Record<string, string>>)['default']?.['access_token'] as string;
    const empty = join(root, 'never-created');
    const ci = { EKWO_CONFIG_DIR: empty, SUPABASE_URL: FAKE_URL, SUPABASE_ANON_KEY: ANON_KEY, EKWO_ACCESS_TOKEN: token };
    expect((await ekwo(['whoami'], ci)).data).toMatchObject({ source: 'environment', user: { id: ada } });
    await expect(stat(empty)).rejects.toThrow();

    // A token in hand cannot be renewed: when it lapses, that is the answer.
    instance.expireAccessTokens();
    const lapsed = await ekwo(['whoami'], ci);
    expect(lapsed.exitCode).toBe(EXIT_USAGE);
    expect(lapsed.error?.name).toBe('session_expired');
    expect(instance.calls.some((call) => call.includes('grant_type=refresh_token'))).toBe(false);
  });

  it('is taken whole: a user with no instance beside it is a wrong call, not a fallback on a profile', async () => {
    await login('ada@example.test');
    instance.calls.length = 0;
    const answer = await ekwo(['whoami'], env({ EKWO_ACCESS_TOKEN: 'a-token-for-somewhere' }));
    expect(answer.exitCode).toBe(EXIT_USAGE);
    expect(answer.error?.name).toBe('missing_configuration');
    expect(instance.calls).toEqual([]);
  });

  it('has nowhere to keep a company, and says to pass --company', async () => {
    const ci = env({ SUPABASE_URL: FAKE_URL, SUPABASE_ANON_KEY: ANON_KEY, EKWO_EMAIL: 'ada@example.test', EKWO_PASSWORD: PASSWORD });
    const answer = await ekwo(['use', 'Example One'], ci);
    expect(answer.exitCode).toBe(EXIT_USAGE);
    expect(answer.error?.name).toBe('no_profile');
    await expect(stat(configDir)).rejects.toThrow();
  });
});

describe('ekwo logout', () => {
  it('forgets the session here and ends it on the instance', async () => {
    await login('ada@example.test');
    await ekwo(['use', 'Example One']);
    const kept = (JSON.parse(await stored('credentials.json')) as Record<string, Record<string, string>>)['default']?.['refresh_token'] as string;

    const out = await ekwo(['logout']);
    expect(out.data).toEqual({ profile: 'default', signedOut: true, revoked: true });
    expect(JSON.parse(await stored('credentials.json'))).toEqual({});
    expect(instance.refreshTokenIsLive(kept)).toBe(false);

    const after = await ekwo(['whoami']);
    expect(after.exitCode).toBe(EXIT_USAGE);
    expect(after.error?.name).toBe('not_signed_in');
    // Signing out twice is not an error, and the profile still knows where it pointed.
    expect((await ekwo(['logout'])).data).toEqual({ profile: 'default', signedOut: false, revoked: false });
    expect((await ekwo(['login'], env({ EKWO_PASSWORD: PASSWORD }))).context?.company?.id).toBe(first);
  });
});

describe('a refusal that arrives over PostgREST', () => {
  it('is exit code 3, with its name and its SQLSTATE, word for word', async () => {
    await login('grace@example.test');
    const session = (JSON.parse(await stored('credentials.json')) as Record<string, Record<string, string>>)['default'];
    const client = new UserClient({
      instance: { supabaseUrl: FAKE_URL, anonKey: ANON_KEY },
      fetchImpl: instance.fetchImpl,
      accessToken: session?.['access_token'] as string,
      signInAgain: '',
    });
    // Grace asks what Ada may do on a company Grace does not manage.
    const sql = 'select member_capabilities($1, $2)';
    const said = await asUser(pg, grace, () => pg.query(sql, [first, ada]).then(
      () => undefined,
      (error: Error) => error.message,
    ));
    expect(said).toMatch(/^not_allowed:/);

    const refused = await capture(() =>
      execute(parseArgs(['whoami', '--json']), true, async () => {
        await client.rpc('member_capabilities', { p_company_id: first, p_user_id: ada });
        return 0;
      }),
    );
    expect(refused.exitCode).toBe(EXIT_REFUSED);
    const document = JSON.parse(refused.stdout) as OutputDocument;
    expect(validate(document, schema)).toEqual([]);
    expect(document.error).toEqual({ kind: 'refusal', name: 'not_allowed', message: said, sqlstate: '42501' });
  });

  it('leaves an error of the gateway itself a failure', async () => {
    const client = new UserClient({
      instance: { supabaseUrl: FAKE_URL, anonKey: ANON_KEY },
      fetchImpl: (async () => new Response(JSON.stringify({ code: 'PGRST202', message: 'Could not find the function' }), { status: 404 })) as typeof globalThis.fetch,
      accessToken: 'anything',
      signInAgain: '',
    });
    const failed = await capture(() =>
      execute(parseArgs(['whoami', '--json']), true, async () => {
        await client.rpc('no_such_function');
        return 0;
      }),
    );
    expect(failed.exitCode).toBe(EXIT_ERROR);
    expect((JSON.parse(failed.stdout) as OutputDocument).error).toMatchObject({ kind: 'technical', message: 'Could not find the function' });
  });
});
