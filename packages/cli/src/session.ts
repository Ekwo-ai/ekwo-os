/**
 * Signing in, and staying signed in — over `fetch`, by hand.
 *
 * The MCP server uses `@supabase/supabase-js` for this and says why: a library
 * known to work beats code of ours that is merely untested. The command line
 * answers the other way, for the reason `args.ts` gives: it is handed a
 * password, and every package it loads is a package that could read it. The
 * whole exchange is three requests to the instance's auth endpoint — a
 * password grant, a refresh grant, and "who is this token" — so it is written
 * out here, and `tests/cli/login.test.ts` runs each of them, the refresh of a
 * lost token included.
 */

import type { StoredSession } from './profiles.js';

export type FetchLike = (url: string, init?: RequestInit) => Promise<Response>;

export interface Instance {
  supabaseUrl: string;
  anonKey: string;
}

export interface SessionUser {
  id: string;
  email: string | undefined;
}

export interface SignedIn {
  session: StoredSession;
  user: SessionUser;
}

/** The instance's auth service said no. `status` is what it answered with. */
export class AuthError extends Error {
  constructor(
    message: string,
    readonly status: number,
  ) {
    super(message);
  }
}

export function baseUrl(supabaseUrl: string): string {
  return supabaseUrl.replace(/\/+$/, '');
}

function said(body: unknown, fallback: string): string {
  if (typeof body !== 'object' || body === null) return fallback;
  const record = body as Record<string, unknown>;
  for (const key of ['msg', 'error_description', 'message', 'error']) {
    const value = record[key];
    if (typeof value === 'string' && value.length > 0) return value;
  }
  return fallback;
}

async function bodyOf(response: Response): Promise<unknown> {
  try {
    return (await response.json()) as unknown;
  } catch {
    return undefined;
  }
}

function signedIn(body: unknown, now: number): SignedIn {
  const record = (body ?? {}) as Record<string, unknown>;
  const access = record['access_token'];
  const refresh = record['refresh_token'];
  const user = (record['user'] ?? {}) as Record<string, unknown>;
  if (typeof access !== 'string' || typeof refresh !== 'string' || typeof user['id'] !== 'string') {
    throw new AuthError('sign_in_failed: the instance answered without a session', 502);
  }
  const expiresAt =
    typeof record['expires_at'] === 'number'
      ? record['expires_at']
      : now + (typeof record['expires_in'] === 'number' ? record['expires_in'] : 0);
  return {
    session: { access_token: access, refresh_token: refresh, expires_at: expiresAt },
    user: { id: user['id'], email: typeof user['email'] === 'string' ? user['email'] : undefined },
  };
}

async function grant(
  fetchImpl: FetchLike,
  instance: Instance,
  type: 'password' | 'refresh_token',
  body: Record<string, string>,
  failure: string,
): Promise<SignedIn> {
  const response = await fetchImpl(`${baseUrl(instance.supabaseUrl)}/auth/v1/token?grant_type=${type}`, {
    method: 'POST',
    headers: { apikey: instance.anonKey, 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  const answer = await bodyOf(response);
  if (!response.ok) {
    throw new AuthError(`${failure}: ${said(answer, `the instance answered ${response.status}`)}`, response.status);
  }
  return signedIn(answer, Math.floor(Date.now() / 1000));
}

/** The password goes to the instance once and is kept nowhere. */
export function signIn(
  fetchImpl: FetchLike,
  instance: Instance,
  email: string,
  password: string,
): Promise<SignedIn> {
  return grant(fetchImpl, instance, 'password', { email, password }, 'sign_in_failed');
}

/** The instance rotates the refresh token: what comes back replaces what was sent. */
export function refreshSession(
  fetchImpl: FetchLike,
  instance: Instance,
  refreshToken: string,
): Promise<SignedIn> {
  return grant(fetchImpl, instance, 'refresh_token', { refresh_token: refreshToken }, 'refresh_failed');
}

/** Tells the instance the session is over. Best effort: the local copy goes either way. */
export async function signOut(fetchImpl: FetchLike, instance: Instance, accessToken: string): Promise<boolean> {
  try {
    const response = await fetchImpl(`${baseUrl(instance.supabaseUrl)}/auth/v1/logout?scope=local`, {
      method: 'POST',
      headers: { apikey: instance.anonKey, Authorization: `Bearer ${accessToken}` },
    });
    return response.ok;
  } catch {
    return false;
  }
}
