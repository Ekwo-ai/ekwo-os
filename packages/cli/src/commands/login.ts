/**
 * `ekwo login` and `ekwo logout`.
 *
 * Signing in is what turns "every command takes a connection string" into
 * something a person can use twenty times a day. It asks the instance for a
 * session with an address and a password, keeps the session in the person's
 * own configuration directory, and keeps the password nowhere.
 *
 * What it needs comes from a flag, then the environment, then a profile that
 * already exists — so signing in again after a session ended is `ekwo login`
 * and a password — then `ekwo.json` for the instance URL, and a question last,
 * when there is somebody to ask.
 */

import { IDENTITY_ENV } from '@ekwo-ai/core';
import { boolFlag, rejectUnknownFlags, stringFlag, type ParsedArgs } from '../args.js';
import { readConfig } from '../config.js';
import { fetchOf, profileName, refuseInstallerKey, refuseServiceRole, type UserDeps } from '../identity.js';
import { setContext, setResult } from '../output.js';
import {
  FIRST_PROFILE,
  assertOutsideRepository,
  configDir,
  forgetSession,
  readProfiles,
  readSession,
  writeProfiles,
  writeSession,
} from '../profiles.js';
import { NotInteractiveError, askRequired, askSecret, isInteractive } from '../prompt.js';
import { signIn, signOut } from '../session.js';
import { dim, heading, note, pairs, skipped, step } from '../ui.js';

export const LOGIN_FLAGS = ['profile', 'supabase-url', 'anon-key', 'email', 'password', 'yes'] as const;
export const LOGOUT_FLAGS = ['profile'] as const;

export interface LoginDeps extends UserDeps {
  /** Where `ekwo.json` is looked for. The working directory, unless a test says otherwise. */
  cwd?: string | undefined;
}

export async function loginCommand(args: ParsedArgs, deps: LoginDeps = {}): Promise<number> {
  refuseInstallerKey(args);
  rejectUnknownFlags(args, LOGIN_FLAGS);
  const env = deps.env ?? process.env;
  const interactive = !boolFlag(args, 'yes') && isInteractive();
  const dir = configDir(env);
  // Before anything is asked: a password typed for a session that cannot be
  // kept is a password typed for nothing.
  assertOutsideRepository(dir);

  const file = await readProfiles(dir);
  const name = profileName(args, env) ?? file.current ?? FIRST_PROFILE;
  const known = file.profiles[name];
  const installation = await readConfig(deps.cwd);

  const value = (flag: string, variable: string, remembered: string | undefined): string | undefined =>
    stringFlag(args, flag) ?? (env[variable]?.trim() || undefined) ?? remembered;

  const supabaseUrl =
    value('supabase-url', IDENTITY_ENV.supabaseUrl, known?.supabase_url ?? installation?.project_url) ??
    (interactive ? await askRequired('URL of the instance (https://<ref>.supabase.co)?') : undefined);
  if (supabaseUrl === undefined) throw new NotInteractiveError('the URL of the instance', '--supabase-url');

  const anonKey =
    value('anon-key', IDENTITY_ENV.anonKey, known?.supabase_url === supabaseUrl ? known.anon_key : undefined) ??
    (interactive ? await askRequired('Publishable (anon) key of the instance (Project Settings → API)?') : undefined);
  if (anonKey === undefined) throw new NotInteractiveError('the publishable (anon) key', '--anon-key');
  refuseServiceRole(anonKey, stringFlag(args, 'anon-key') !== undefined ? '--anon-key' : IDENTITY_ENV.anonKey, 'apikey');

  const email =
    value('email', IDENTITY_ENV.email, known?.email) ??
    (interactive ? await askRequired('E-mail address?') : undefined);
  if (email === undefined) throw new NotInteractiveError('the e-mail address', '--email');

  const password =
    stringFlag(args, 'password') ??
    (env[IDENTITY_ENV.password] || undefined) ??
    (interactive ? await askSecret(`Password for ${email}. It is sent to the instance and never written to disk:`) : undefined);
  if (password === undefined || password.length === 0) {
    throw new NotInteractiveError('the password', `--password, or ${IDENTITY_ENV.password}`);
  }

  heading('Signing in');
  const instance = { supabaseUrl, anonKey };
  const { session, user } = await signIn(fetchOf(deps), instance, email, password);
  step(`signed in to ${supabaseUrl} as ${user.email ?? email}`);

  // The company in use belongs to an instance and to a person. Signing in as
  // somebody else, or somewhere else, is not a reason to keep it.
  const sameBooks = known !== undefined && known.supabase_url === supabaseUrl && known.user_id === user.id;
  const company = sameBooks ? known.company : undefined;

  await writeSession(dir, name, session);
  await writeProfiles(dir, {
    current: name,
    profiles: {
      ...file.profiles,
      [name]: {
        supabase_url: supabaseUrl,
        anon_key: anonKey,
        email: user.email ?? email,
        user_id: user.id,
        ...(company === undefined ? {} : { company }),
      },
    },
  });
  step(`kept the session under the profile ${name}, in ${dir}`);
  if (company === undefined) note(dim('No company in use yet: `ekwo whoami` lists them, `ekwo use <company>` picks one.'));

  setContext({ profile: name, instance: supabaseUrl, company: company ?? null });
  setResult({
    profile: name,
    instance: { url: supabaseUrl },
    user: { id: user.id, email: user.email ?? email },
    company: company ?? null,
    expiresAt: new Date(session.expires_at * 1000).toISOString(),
    configDir: dir,
  });
  pairs([
    ['profile', name],
    ['user', user.email ?? email],
    ['company', company?.name ?? dim('none in use')],
  ]);
  return 0;
}

export async function logoutCommand(args: ParsedArgs, deps: UserDeps = {}): Promise<number> {
  rejectUnknownFlags(args, LOGOUT_FLAGS);
  const env = deps.env ?? process.env;
  const dir = configDir(env);
  const file = await readProfiles(dir);
  const name = profileName(args, env) ?? file.current;
  const profile = name === undefined ? undefined : file.profiles[name];

  heading('Signing out');
  if (name === undefined || profile === undefined) {
    skipped('nobody was signed in');
    setResult({ profile: name ?? null, signedOut: false, revoked: false });
    return 0;
  }

  const session = await readSession(dir, name);
  // The instance is told, so the refresh token stops working there too; the
  // local copy goes whether or not the instance could be reached.
  const revoked =
    session === undefined
      ? false
      : await signOut(fetchOf(deps), { supabaseUrl: profile.supabase_url, anonKey: profile.anon_key }, session.access_token);
  const signedOut = await forgetSession(dir, name);
  if (signedOut) step(`forgot the session of the profile ${name}`);
  else skipped(`the profile ${name} held no session`);
  if (signedOut && !revoked) note(dim('The instance could not be told; the session there ends on its own.'));

  setResult({ profile: name, signedOut, revoked });
  return 0;
}
