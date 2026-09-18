/**
 * Profiles: which instance, as whom, for which company — kept between commands.
 *
 * `ekwo.json` is the file of an installation and it is safe to commit, which
 * is why it may never hold a token. What is kept here is the file of a
 * person: it lives in their own configuration directory, outside any
 * repository, and the CLI refuses to write it anywhere else.
 *
 * Two files, because they are not the same kind of thing. `profiles.json`
 * says where each profile points — the instance URL, its publishable key, the
 * address that signed in, the company in use — and holds nothing a dashboard
 * does not already show. `credentials.json` holds the session: an access
 * token that lasts an hour and the refresh token that renews it. Both are
 * written `0600` in a `0700` directory. The password is never written at all:
 * it is sent once, to the instance, and forgotten.
 *
 * The environment is not read here. A CI job sets its variables and never
 * touches this directory; see `identity.ts` for the order.
 */

import { chmod, mkdir, readFile, rename, stat, writeFile } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { homedir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { UsageError } from './args.js';

export const ENV_CONFIG_DIR = 'EKWO_CONFIG_DIR';
export const ENV_PROFILE = 'EKWO_PROFILE';

/** The name a first `ekwo login` gives its profile when none is asked for. */
export const FIRST_PROFILE = 'default';

const PROFILES_FILE = 'profiles.json';
const CREDENTIALS_FILE = 'credentials.json';

export interface CompanyRef {
  id: string;
  name: string;
}

export interface Profile {
  supabase_url: string;
  anon_key: string;
  email?: string;
  user_id?: string;
  /** The company commands run on, until `ekwo use` names another. */
  company?: CompanyRef;
}

export interface ProfilesFile {
  /** The profile a command uses when neither `--profile` nor `EKWO_PROFILE` names one. */
  current?: string;
  profiles: Record<string, Profile>;
}

export interface StoredSession {
  access_token: string;
  refresh_token: string;
  /** Seconds since the epoch, as the instance gave it. */
  expires_at: number;
}

/** `EKWO_CONFIG_DIR`, else `$XDG_CONFIG_HOME/ekwo`, else `~/.config/ekwo`. */
export function configDir(env: NodeJS.ProcessEnv = process.env): string {
  const given = env[ENV_CONFIG_DIR];
  if (given !== undefined && given.trim().length > 0) return resolve(given.trim());
  const xdg = env['XDG_CONFIG_HOME'];
  if (xdg !== undefined && xdg.trim().length > 0) return join(resolve(xdg.trim()), 'ekwo');
  return join(homedir(), '.config', 'ekwo');
}

export function assertProfileName(name: string): string {
  if (!/^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$/.test(name)) {
    throw new UsageError(
      `bad_profile_name: "${name}" is not a profile name. Letters, digits, dot, dash and underscore, starting with a letter or a digit.`,
    );
  }
  return name;
}

/**
 * Refuses a directory that sits inside a repository.
 *
 * A token in a working tree is one `git add .` away from being published,
 * and nothing about a file called `credentials.json` would stop it. The check
 * is the plain one — a `.git` in the directory or above it — and the way out
 * is named in the refusal.
 */
export function assertOutsideRepository(dir: string): void {
  let current = resolve(dir);
  for (;;) {
    if (existsSync(join(current, '.git'))) {
      throw new UsageError(
        `config_dir_in_repository: ${dir} is inside the repository at ${current}, and a session token is never written where a commit could pick it up. Set ${ENV_CONFIG_DIR} to a directory outside any repository.`,
      );
    }
    const parent = dirname(current);
    if (parent === current) return;
    current = parent;
  }
}

async function readJson(path: string): Promise<unknown> {
  try {
    return JSON.parse(await readFile(path, 'utf8')) as unknown;
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === 'ENOENT') return undefined;
    throw new Error(`unreadable_configuration: ${path} could not be read: ${(error as Error).message}`);
  }
}

/** Written beside the file and moved over it: a rotated refresh token is never half there. */
async function writePrivate(dir: string, file: string, value: unknown): Promise<void> {
  assertOutsideRepository(dir);
  await mkdir(dir, { recursive: true, mode: 0o700 });
  const path = join(dir, file);
  const temporary = `${path}.${process.pid}.tmp`;
  await writeFile(temporary, `${JSON.stringify(value, null, 2)}\n`, { encoding: 'utf8', mode: 0o600 });
  await chmod(temporary, 0o600);
  await rename(temporary, path);
}

function text(value: unknown): string | undefined {
  return typeof value === 'string' && value.length > 0 ? value : undefined;
}

function asProfile(raw: unknown): Profile | undefined {
  if (typeof raw !== 'object' || raw === null) return undefined;
  const record = raw as Record<string, unknown>;
  const supabaseUrl = text(record['supabase_url']);
  const anonKey = text(record['anon_key']);
  if (supabaseUrl === undefined || anonKey === undefined) return undefined;
  const company = record['company'] as Record<string, unknown> | undefined;
  const companyId = text(company?.['id']);
  const companyName = text(company?.['name']);
  const email = text(record['email']);
  const userId = text(record['user_id']);
  return {
    supabase_url: supabaseUrl,
    anon_key: anonKey,
    ...(email === undefined ? {} : { email }),
    ...(userId === undefined ? {} : { user_id: userId }),
    ...(companyId === undefined || companyName === undefined
      ? {}
      : { company: { id: companyId, name: companyName } }),
  };
}

export async function readProfiles(dir: string): Promise<ProfilesFile> {
  const raw = (await readJson(join(dir, PROFILES_FILE))) as Record<string, unknown> | undefined;
  const profiles: Record<string, Profile> = {};
  const listed = raw?.['profiles'];
  if (typeof listed === 'object' && listed !== null) {
    for (const [name, value] of Object.entries(listed)) {
      const profile = asProfile(value);
      if (profile !== undefined) profiles[name] = profile;
    }
  }
  const current = text(raw?.['current']);
  return { ...(current === undefined ? {} : { current }), profiles };
}

export async function writeProfiles(dir: string, file: ProfilesFile): Promise<void> {
  await writePrivate(dir, PROFILES_FILE, {
    $comment:
      'Where each profile of the ekwo command line points. No token lives here; the session is in credentials.json, beside this file.',
    ...(file.current === undefined ? {} : { current: file.current }),
    profiles: file.profiles,
  });
}

function asSession(raw: unknown): StoredSession | undefined {
  if (typeof raw !== 'object' || raw === null) return undefined;
  const record = raw as Record<string, unknown>;
  const accessToken = text(record['access_token']);
  const refreshToken = text(record['refresh_token']);
  const expiresAt = record['expires_at'];
  if (accessToken === undefined || refreshToken === undefined || typeof expiresAt !== 'number') {
    return undefined;
  }
  return { access_token: accessToken, refresh_token: refreshToken, expires_at: expiresAt };
}

async function readCredentials(dir: string): Promise<Record<string, StoredSession>> {
  const raw = await readJson(join(dir, CREDENTIALS_FILE));
  const sessions: Record<string, StoredSession> = {};
  if (typeof raw === 'object' && raw !== null) {
    for (const [name, value] of Object.entries(raw)) {
      const session = asSession(value);
      if (session !== undefined) sessions[name] = session;
    }
  }
  return sessions;
}

export async function readSession(dir: string, profile: string): Promise<StoredSession | undefined> {
  return (await readCredentials(dir))[profile];
}

export async function writeSession(dir: string, profile: string, session: StoredSession): Promise<void> {
  const sessions = await readCredentials(dir);
  sessions[profile] = session;
  await writePrivate(dir, CREDENTIALS_FILE, sessions);
}

/** True when there was a session to forget. */
export async function forgetSession(dir: string, profile: string): Promise<boolean> {
  const sessions = await readCredentials(dir);
  if (sessions[profile] === undefined) return false;
  delete sessions[profile];
  await writePrivate(dir, CREDENTIALS_FILE, sessions);
  return true;
}

/** True when somebody other than the owner can read the session file. */
export async function credentialsAreExposed(dir: string): Promise<boolean> {
  if (process.platform === 'win32') return false;
  try {
    const info = await stat(join(dir, CREDENTIALS_FILE));
    return (info.mode & 0o077) !== 0;
  } catch {
    return false;
  }
}
