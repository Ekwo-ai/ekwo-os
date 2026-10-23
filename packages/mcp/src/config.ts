/**
 * Where the server gets its connection, and what it refuses.
 *
 * Two modes, and the order matters. **PostgREST with the user's own session**
 * is the recommended one: `SUPABASE_URL` and `SUPABASE_ANON_KEY` with either a
 * password or an access token, and row level security decides everything from
 * there. **A direct Postgres connection** is the fallback for a self-hosted
 * installation; it demands `EKWO_ACT_AS_USER_ID` precisely because a database
 * connection is nobody, and a server acting as nobody would be acting as the
 * owner.
 *
 * The one thing this file exists to refuse is a `service_role` key. It would
 * work — that is the problem. Every policy in the schema would be bypassed,
 * and an agent that can read every company of an installation is not the
 * thing anybody asked for. It is refused wherever it can arrive, and there are
 * two doors, not one: `SUPABASE_ANON_KEY` is the obvious paste, and
 * `EKWO_ACCESS_TOKEN` is the quiet one — it goes into the `Authorization`
 * header, which is what PostgREST reads for the role, so a service_role key
 * put there overrides a perfectly good anon key sitting next to it.
 */

import { randomUUID } from 'node:crypto';
import { IDENTITY_ENV, SESSION_POSTING, isServiceRoleKey, serviceRoleRefusal } from '@ekwo-ai/core';
import { EkwoMcpError, type AgentSession, type Backend, type SessionPosting } from './backend.js';
import { postgrestBackend } from './postgrest.js';
import { connect, sqlBackend } from './sql.js';

export interface Config {
  mode: 'postgrest' | 'sql';
  supabaseUrl?: string;
  anonKey?: string;
  email?: string;
  password?: string;
  accessToken?: string;
  dbUrl?: string;
  actAsUserId?: string;
  /** The mark every transaction carries: this session's choice, and its name. */
  agent: AgentSession;
}

export const ENV = {
  ...IDENTITY_ENV,
  dbUrl: 'EKWO_DB_URL',
  actAsUserId: 'EKWO_ACT_AS_USER_ID',
  einvoiceDirectory: 'EKWO_EINVOICE_DIRECTORY',
  agentPosting: 'EKWO_AGENT_POSTING',
} as const;

const SURFACE = 'this server';
const SIGN_IN = `sign in, or set ${IDENTITY_ENV.email} and ${IDENTITY_ENV.password} and let this server sign in for you`;

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

// The test and the sentence moved to the core, where the command line reads
// them too: which key is refused cannot be decided twice. Still exported from
// here, as it always was.
export { isServiceRoleKey };

function trimmed(env: NodeJS.ProcessEnv, name: string): string | undefined {
  const value = env[name];
  if (value === undefined) return undefined;
  const text = value.trim();
  return text.length === 0 ? undefined : text;
}

/**
 * The session's choice of how it posts, from `EKWO_AGENT_POSTING` — which
 * `--autopilot` and `--review` set. Unset, each company's `agent_posting`
 * decides. A value that is neither is refused rather than read as one.
 */
export function sessionPostingFrom(env: NodeJS.ProcessEnv): SessionPosting | undefined {
  const value = trimmed(env, ENV.agentPosting);
  if (value === undefined) return undefined;
  if (!(SESSION_POSTING as readonly string[]).includes(value)) {
    throw new EkwoMcpError(
      `bad_agent_posting: ${ENV.agentPosting} is ${SESSION_POSTING.join(' or ')}, got "${value}". Left unset, each company's agent_posting decides.`,
    );
  }
  return value as SessionPosting;
}

/** `--autopilot` or `--review` among the arguments of the server, at most one of them. */
export function sessionPostingFlag(argv: readonly string[]): SessionPosting | undefined {
  if (argv.includes('--autopilot') && argv.includes('--review')) {
    throw new EkwoMcpError('conflicting_arguments: --autopilot and --review, choose one.');
  }
  if (argv.includes('--autopilot')) return 'autopilot';
  if (argv.includes('--review')) return 'review';
  return undefined;
}

/** Reads the environment, and says what is missing rather than failing later. */
export function readConfig(env: NodeJS.ProcessEnv = process.env): Config {
  const agent: AgentSession = { posting: sessionPostingFrom(env), id: randomUUID() };
  const dbUrl = trimmed(env, ENV.dbUrl);

  if (dbUrl !== undefined) {
    const actAsUserId = trimmed(env, ENV.actAsUserId);
    if (actAsUserId === undefined) {
      throw new EkwoMcpError(
        `missing_act_as_user: ${ENV.dbUrl} needs ${ENV.actAsUserId}. A database connection is nobody — auth.uid() is null and row level security is bypassed rather than satisfied — so this server refuses to run without the user it acts for.`,
      );
    }
    if (!UUID.test(actAsUserId)) {
      throw new EkwoMcpError(
        `bad_act_as_user: ${ENV.actAsUserId} must be the auth.users id of a real user, as a uuid.`,
      );
    }
    return { mode: 'sql', dbUrl, actAsUserId, agent };
  }

  const supabaseUrl = trimmed(env, ENV.supabaseUrl);
  const anonKey = trimmed(env, ENV.anonKey);
  if (supabaseUrl === undefined || anonKey === undefined) {
    throw new EkwoMcpError(
      `missing_configuration: set ${ENV.supabaseUrl} and ${ENV.anonKey}, plus either ${ENV.email} and ${ENV.password} or ${ENV.accessToken}. For a self-hosted database, set ${ENV.dbUrl} and ${ENV.actAsUserId} instead.`,
    );
  }
  if (isServiceRoleKey(anonKey)) {
    throw new EkwoMcpError(
      serviceRoleRefusal(ENV.anonKey, 'apikey', SURFACE, SIGN_IN),
    );
  }

  const accessToken = trimmed(env, ENV.accessToken);
  // The second door. `postgrestBackend` puts this straight into
  // `Authorization: Bearer`, and PostgREST takes the role from that header and
  // not from `apikey` — so a service_role token here bypasses every policy
  // exactly as it would in the slot above, while the anon key next to it makes
  // the configuration look right.
  if (accessToken !== undefined && isServiceRoleKey(accessToken)) {
    throw new EkwoMcpError(
      serviceRoleRefusal(ENV.accessToken, 'authorization', SURFACE, SIGN_IN),
    );
  }

  const email = trimmed(env, ENV.email);
  const password = trimmed(env, ENV.password);
  if (accessToken === undefined && (email === undefined || password === undefined)) {
    throw new EkwoMcpError(
      `missing_credentials: set ${ENV.email} and ${ENV.password}, or ${ENV.accessToken}. This server has no identity of its own; it acts as the person using it.`,
    );
  }

  return {
    mode: 'postgrest',
    supabaseUrl,
    anonKey,
    agent,
    ...(accessToken !== undefined ? { accessToken } : {}),
    ...(email !== undefined ? { email } : {}),
    ...(password !== undefined ? { password } : {}),
  };
}

/** Opens the backend the configuration describes. The caller closes it. */
export async function openBackend(config: Config): Promise<Backend> {
  if (config.mode === 'sql') {
    const db = await connect(config.dbUrl as string);
    return sqlBackend(db, { userId: config.actAsUserId as string, agent: config.agent });
  }
  return postgrestBackend({
    supabaseUrl: config.supabaseUrl as string,
    anonKey: config.anonKey as string,
    accessToken: config.accessToken,
    email: config.email,
    password: config.password,
    agent: config.agent,
  });
}
