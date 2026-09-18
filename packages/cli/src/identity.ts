/**
 * Who a bookkeeping command acts as, on which instance, for which company.
 *
 * Three places can say, and the order is the card's: **the environment first**
 * — a CI job sets `SUPABASE_URL`, `SUPABASE_ANON_KEY` and either
 * `EKWO_ACCESS_TOKEN` or `EKWO_EMAIL` with `EKWO_PASSWORD`, the variables the
 * MCP server reads, and then nothing is read from or written to the disk —
 * and otherwise **a profile**: `--profile`, else `EKWO_PROFILE`, else the one
 * the last `ekwo login` made current.
 *
 * The environment is taken whole or not at all. Credentials in the
 * environment with the instance in a profile would send a token to a host
 * nobody named next to it, so that is a wrong call and not a fallback.
 *
 * A `service_role` key is refused at every door it can arrive by: the
 * publishable-key slot, the token slot, a session file somebody edited, and
 * the `--service-role-key` flag that `ekwo init` takes — typed out of habit
 * on a command that keeps books. `init` and `migrate` remain the exception,
 * and say so when they connect.
 */

import { IDENTITY_ENV, isServiceRoleKey, serviceRoleRefusal, type KeySlot } from '@ekwo-ai/core';
import { UsageError, stringFlag, type ParsedArgs } from './args.js';
import {
  ENV_PROFILE,
  assertProfileName,
  configDir,
  credentialsAreExposed,
  readProfiles,
  readSession,
  writeSession,
  type CompanyRef,
} from './profiles.js';
import { UserClient } from './rest.js';
import { signIn, type FetchLike, type Instance } from './session.js';
import { warn } from './ui.js';

/** The flags every command that acts as a person accepts. */
export const IDENTITY_FLAGS = ['profile', 'company', 'supabase-url', 'anon-key'] as const;

const SURFACE = 'this command line';
const SIGN_IN = 'run `ekwo login`';

export interface UserDeps {
  fetchImpl?: FetchLike | undefined;
  env?: NodeJS.ProcessEnv | undefined;
}

export interface Acting {
  client: UserClient;
  /** Absent when the environment said who: no profile was read. */
  profile: string | undefined;
  source: 'environment' | 'profile';
  /** The company the profile holds. `--company` is resolved by the caller, against the instance. */
  storedCompany: CompanyRef | undefined;
  configDir: string;
}

export function refuseServiceRole(key: string | undefined, where: string, slot: KeySlot): void {
  if (key !== undefined && isServiceRoleKey(key)) {
    throw new UsageError(serviceRoleRefusal(where, slot, SURFACE, SIGN_IN));
  }
}

/** `--service-role-key` on a command that keeps books: refused by name, not as an unknown option. */
export function refuseInstallerKey(args: ParsedArgs): void {
  if (args.flags.has('service-role-key')) {
    throw new UsageError(
      `service_role_refused: --service-role-key is for \`ekwo init\`, which installs. A command that keeps books acts as a person, under row level security, and never takes that key. Run \`ekwo login\` instead.`,
    );
  }
}

function trimmed(env: NodeJS.ProcessEnv, name: string): string | undefined {
  const value = env[name]?.trim();
  return value === undefined || value.length === 0 ? undefined : value;
}

export function profileName(args: ParsedArgs, env: NodeJS.ProcessEnv): string | undefined {
  const named = stringFlag(args, 'profile') ?? trimmed(env, ENV_PROFILE);
  return named === undefined ? undefined : assertProfileName(named);
}

/**
 * `fetch`, saying where it could not get to.
 *
 * Node's own failure is "fetch failed" and the reason is in `cause`; a caller
 * with a shell deserves the host and the reason in the one line it reads.
 */
export function fetchOf(deps: UserDeps): FetchLike {
  const fetchImpl = deps.fetchImpl ?? ((url, init) => globalThis.fetch(url, init));
  return async (url, init) => {
    try {
      return await fetchImpl(url, init);
    } catch (error) {
      const cause = (error as { cause?: { code?: string; message?: string } }).cause;
      const why = cause?.code ?? cause?.message ?? (error as Error).message;
      throw new Error(`instance_unreachable: ${new URL(url).origin} did not answer (${why})`);
    }
  };
}

/** Opens the instance as whoever the environment or the profile says. */
export async function actAsUser(args: ParsedArgs, deps: UserDeps = {}): Promise<Acting> {
  refuseInstallerKey(args);
  const env = deps.env ?? process.env;
  const fetchImpl = fetchOf(deps);
  const dir = configDir(env);

  const accessToken = trimmed(env, IDENTITY_ENV.accessToken);
  const email = trimmed(env, IDENTITY_ENV.email);
  const password = trimmed(env, IDENTITY_ENV.password);

  if (accessToken !== undefined || (email !== undefined && password !== undefined)) {
    const supabaseUrl = stringFlag(args, 'supabase-url') ?? trimmed(env, IDENTITY_ENV.supabaseUrl);
    const anonKey = stringFlag(args, 'anon-key') ?? trimmed(env, IDENTITY_ENV.anonKey);
    if (supabaseUrl === undefined || anonKey === undefined) {
      throw new UsageError(
        `missing_configuration: the environment names a user and not the instance. Set ${IDENTITY_ENV.supabaseUrl} and ${IDENTITY_ENV.anonKey} beside it, or unset ${IDENTITY_ENV.accessToken}, ${IDENTITY_ENV.email} and ${IDENTITY_ENV.password} to use a profile.`,
      );
    }
    refuseServiceRole(anonKey, IDENTITY_ENV.anonKey, 'apikey');
    refuseServiceRole(accessToken, IDENTITY_ENV.accessToken, 'authorization');
    const instance: Instance = { supabaseUrl, anonKey };
    const signInAgain = `Set a fresh ${IDENTITY_ENV.accessToken}.`;

    if (accessToken !== undefined) {
      const client = new UserClient({ instance, fetchImpl, accessToken, signInAgain });
      return { client, profile: undefined, source: 'environment', storedCompany: undefined, configDir: dir };
    }
    // Signed in for this one command, in memory. Nothing is written.
    const { session } = await signIn(fetchImpl, instance, email as string, password as string);
    const client = new UserClient({
      instance,
      fetchImpl,
      accessToken: session.access_token,
      refreshToken: session.refresh_token,
      expiresAt: session.expires_at,
      signInAgain,
    });
    return { client, profile: undefined, source: 'environment', storedCompany: undefined, configDir: dir };
  }

  const file = await readProfiles(dir);
  const name = profileName(args, env) ?? file.current;
  const profile = name === undefined ? undefined : file.profiles[name];
  if (name === undefined || profile === undefined) {
    throw new UsageError(
      name === undefined
        ? 'not_signed_in: nobody is signed in. Run `ekwo login`, or set the environment variables `ekwo --help` lists under "Acting as a person".'
        : `unknown_profile: there is no profile called ${name}. Run \`ekwo login --profile ${name}\`. Known: ${Object.keys(file.profiles).sort().join(', ') || 'none'}.`,
    );
  }
  const session = await readSession(dir, name);
  if (session === undefined) {
    throw new UsageError(`not_signed_in: the profile ${name} holds no session. Run \`ekwo login --profile ${name}\`.`);
  }
  refuseServiceRole(profile.anon_key, `the profile ${name}`, 'apikey');
  refuseServiceRole(session.access_token, `the session of the profile ${name}`, 'authorization');
  if (await credentialsAreExposed(dir)) {
    warn(`the session file in ${dir} can be read by other users of this machine. \`chmod 600\` it.`);
  }

  const client = new UserClient({
    instance: { supabaseUrl: profile.supabase_url, anonKey: profile.anon_key },
    fetchImpl,
    accessToken: session.access_token,
    refreshToken: session.refresh_token,
    expiresAt: session.expires_at,
    onRenewed: (renewed) => writeSession(dir, name, renewed),
    signInAgain: `Run \`ekwo login --profile ${name}\`.`,
  });
  return { client, profile: name, source: 'profile', storedCompany: profile.company, configDir: dir };
}
