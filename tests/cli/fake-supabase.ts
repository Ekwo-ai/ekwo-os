/**
 * An instance to sign in to, without a network: GoTrue and PostgREST as far as
 * the command line uses them, in front of a real Postgres.
 *
 * What matters is what is *not* faked. A request under `/rest/v1` runs against
 * PGlite with the role and the claims PostgREST would set for that token, so
 * the companies a test sees are the ones the policies let through and a
 * refusal is the one the schema raised, SQLSTATE included — answered in the
 * JSON PostgREST answers with. The auth half is a table of users and tokens:
 * it rotates a refresh token on use, as the real one does, and a test can end
 * every access token early, which is what "losing one's token" looks like
 * from the outside.
 */

import { randomUUID } from 'node:crypto';
import type { PGlite } from '@electric-sql/pglite';
import { asUser } from '../helpers/db.js';

export const FAKE_URL = 'https://instance.example.test';

/** An unsigned JWT with a role, which is all `isServiceRoleKey` reads. */
export function keyWithRole(role: string): string {
  const part = (value: unknown): string => Buffer.from(JSON.stringify(value)).toString('base64url');
  return `${part({ alg: 'HS256', typ: 'JWT' })}.${part({ role, iss: 'supabase' })}.signature`;
}

export const ANON_KEY = keyWithRole('anon');

interface Account {
  id: string;
  email: string;
  password: string;
}

export interface FakeSupabase {
  fetchImpl: typeof globalThis.fetch;
  /** Every request, in order: `POST /auth/v1/token?grant_type=password`. */
  calls: string[];
  addUser(id: string, email: string, password: string): void;
  /** Ends every access token now. The refresh tokens still work. */
  expireAccessTokens(): void;
  /** Ends every refresh token too: the session cannot be renewed. */
  revokeEverything(): void;
  refreshTokenIsLive(token: string): boolean;
}

function json(status: number, body: unknown): Response {
  return new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json' } });
}

export function fakeSupabase(pg: PGlite): FakeSupabase {
  const accounts: Account[] = [];
  const access = new Map<string, string>();
  const refresh = new Map<string, string>();
  const calls: string[] = [];

  const session = (account: Account): Response => {
    const accessToken = keyWithRole('authenticated') + randomUUID();
    const refreshToken = randomUUID();
    access.set(accessToken, account.id);
    refresh.set(refreshToken, account.id);
    return json(200, {
      access_token: accessToken,
      refresh_token: refreshToken,
      token_type: 'bearer',
      expires_in: 3600,
      expires_at: Math.floor(Date.now() / 1000) + 3600,
      user: { id: account.id, email: account.email },
    });
  };

  const bearer = (init: RequestInit | undefined): string | undefined => {
    const headers = (init?.headers ?? {}) as Record<string, string>;
    if (headers['apikey'] !== ANON_KEY) return undefined;
    const token = headers['Authorization']?.replace(/^Bearer /, '');
    return token === undefined ? undefined : access.get(token);
  };

  const databaseError = (error: unknown): Response => {
    const e = error as { code?: string; message?: string; detail?: string; hint?: string };
    return json(e.code === '42501' ? 403 : 400, {
      code: e.code ?? 'XX000',
      message: e.message ?? 'error',
      details: e.detail ?? null,
      hint: e.hint ?? null,
    });
  };

  const rest = async (userId: string, url: URL, init: RequestInit | undefined): Promise<Response> => {
    const path = url.pathname.replace('/rest/v1/', '');
    try {
      if (path.startsWith('rpc/')) {
        const fn = path.slice(4);
        const args = JSON.parse(typeof init?.body === 'string' ? init.body : '{}') as Record<string, unknown>;
        const names = Object.keys(args);
        const call = `select * from ${fn}(${names.map((name, i) => `${name} => $${i + 1}`).join(', ')})`;
        const { rows } = await asUser(pg, userId, () =>
          pg.query<Record<string, unknown>>(call, names.map((name) => args[name])),
        );
        const shape = await pg.query<{ proretset: boolean }>('select proretset from pg_proc where proname = $1', [fn]);
        // PostgREST answers a scalar function with the scalar, and a set of
        // scalars with a list of them.
        const scalars = rows.map((row) => (Object.keys(row).length === 1 && fn in row ? row[fn] : row));
        return json(200, shape.rows[0]?.proretset === true ? scalars : scalars[0] ?? null);
      }
      // A table. The query string is PostgREST's: `select`, `order`, `limit`,
      // and one `column=op.value` per filter — turned into the SQL it means
      // and run as the user, so the policies answer and not this file.
      const RESERVED = new Set(['select', 'order', 'limit']);
      const values: unknown[] = [];
      const conditions: string[] = [];
      for (const [column, raw] of url.searchParams) {
        if (RESERVED.has(column)) continue;
        const dot = raw.indexOf('.');
        const op = raw.slice(0, dot);
        const value = raw.slice(dot + 1);
        if (op === 'is') conditions.push(`${column} is null`);
        else if (op === 'in') {
          const items = [...value.slice(1, -1).matchAll(/"((?:[^"\\]|\\.)*)"/g)].map((m) => (m[1] as string).replace(/\\(.)/g, '$1'));
          values.push(items);
          conditions.push(`${column}::text = any($${values.length}::text[])`);
        } else {
          const sql = { eq: '=', neq: '<>', gt: '>', gte: '>=', lt: '<', lte: '<=', ilike: 'ilike' }[op];
          if (sql === undefined) return json(400, { code: 'PGRST100', message: `unknown operator ${op}` });
          values.push(value);
          conditions.push(`${column}::text ${sql} $${values.length}`);
        }
      }
      const where = conditions.length === 0 ? '' : ` where ${conditions.join(' and ')}`;
      const columns = url.searchParams.get('select') ?? '*';
      const method = init?.method ?? 'GET';
      const run = (sql: string, params: unknown[]) => asUser(pg, userId, () => pg.query<Record<string, unknown>>(sql, params));

      if (method === 'GET') {
        const order = url.searchParams.get('order');
        const by = order === null ? '' : ` order by ${order.split(',').map((o) => o.replace('.', ' ')).join(', ')}`;
        const limit = url.searchParams.get('limit');
        const { rows } = await run(`select ${columns} from ${path}${where}${by}${limit === null ? '' : ` limit ${Number(limit)}`}`, values);
        return json(200, rows);
      }
      if (method === 'POST') {
        const records = JSON.parse(String(init?.body)) as Record<string, unknown>[];
        const out: Record<string, unknown>[] = [];
        // One statement per call, as PostgREST does it: all the rows or none.
        const keys = [...new Set(records.flatMap((record) => Object.keys(record)))];
        const params: unknown[] = [];
        const tuples = records.map(
          (record) => `(${keys.map((key) => (params.push(record[key] ?? null), `$${params.length}`)).join(', ')})`,
        );
        const { rows } = await run(
          `insert into ${path} (${keys.join(', ')}) values ${tuples.join(', ')} returning ${columns}`,
          params,
        );
        out.push(...rows);
        return json(201, out);
      }
      if (method === 'PATCH') {
        const patch = JSON.parse(String(init?.body)) as Record<string, unknown>;
        const sets = Object.keys(patch).map((key) => (values.push(patch[key]), `${key} = $${values.length}`));
        const { rows } = await run(`update ${path} set ${sets.join(', ')}${where} returning ${columns}`, values);
        return json(200, rows);
      }
      if (method === 'DELETE') {
        await run(`delete from ${path}${where}`, values);
        return new Response(null, { status: 204 });
      }
      return json(405, { message: 'method not allowed' });
    } catch (error) {
      return databaseError(error);
    }
  };

  const fetchImpl = async (input: string | URL | Request, init?: RequestInit): Promise<Response> => {
    const url = new URL(String(input));
    calls.push(`${init?.method ?? 'GET'} ${url.pathname}${url.search}`);
    if (url.origin !== FAKE_URL) throw new Error(`fetch failed: nothing serves ${url.origin}`);

    if (url.pathname === '/auth/v1/token') {
      const body = JSON.parse(String(init?.body)) as Record<string, string>;
      if (url.searchParams.get('grant_type') === 'password') {
        const account = accounts.find((a) => a.email === body['email'] && a.password === body['password']);
        return account === undefined
          ? json(400, { code: 400, error_code: 'invalid_credentials', msg: 'Invalid login credentials' })
          : session(account);
      }
      const owner = refresh.get(body['refresh_token'] ?? '');
      const account = accounts.find((a) => a.id === owner);
      if (account === undefined) {
        return json(400, { code: 400, error_code: 'refresh_token_not_found', msg: 'Invalid Refresh Token: Refresh Token Not Found' });
      }
      refresh.delete(body['refresh_token'] as string);
      return session(account);
    }

    const userId = bearer(init);
    if (url.pathname === '/auth/v1/user') {
      const account = accounts.find((a) => a.id === userId);
      return account === undefined
        ? json(401, { code: 401, error_code: 'bad_jwt', msg: 'invalid JWT: token is expired' })
        : json(200, { id: account.id, email: account.email });
    }
    if (url.pathname === '/auth/v1/logout') {
      if (userId === undefined) return json(401, { msg: 'invalid JWT' });
      for (const [token, owner] of [...refresh]) if (owner === userId) refresh.delete(token);
      for (const [token, owner] of [...access]) if (owner === userId) access.delete(token);
      return new Response(null, { status: 204 });
    }
    if (url.pathname.startsWith('/rest/v1/')) {
      if (userId === undefined) return json(401, { code: 'PGRST301', message: 'JWT expired', details: null, hint: null });
      return rest(userId, url, init);
    }
    return json(404, { message: 'not found' });
  };

  return {
    fetchImpl: fetchImpl as typeof globalThis.fetch,
    calls,
    addUser: (id, email, password) => void accounts.push({ id, email, password }),
    expireAccessTokens: () => access.clear(),
    revokeEverything: () => {
      access.clear();
      refresh.clear();
    },
    refreshTokenIsLive: (token) => refresh.has(token),
  };
}
