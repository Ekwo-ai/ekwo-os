/**
 * Talking to an instance as a person: PostgREST, with that person's token.
 *
 * Everything a bookkeeping command does goes through here, and nothing here
 * holds a privilege: the `apikey` is the publishable one, the bearer is the
 * session of whoever signed in, and row level security decides the rest —
 * exactly as it does for the MCP server, which calls the same functions.
 *
 * **A refusal keeps its SQLSTATE over this route.** PostgREST answers an error
 * of the database with the fields Postgres gave it — `code`, `message`,
 * `details`, `hint` — so the error thrown here carries `code`, `detail` and
 * `hint` the way both SQL drivers do, and `output.ts` reads a locked period
 * off it as exit code 3 without knowing which route it came over. An error of
 * PostgREST's own is `PGRST…`, which is not an SQLSTATE and stays a failure.
 *
 * **A token that stopped working is renewed once, and the call is made
 * again.** An access token lasts an hour and a terminal stays open for a day.
 * It is renewed ahead of time when it is about to lapse, and after the fact
 * when the instance answers 401 anyway — a clock that drifted, a session the
 * instance ended early. The renewed session is handed to whoever keeps it;
 * a session that cannot be renewed is `session_expired`, never a retry loop.
 */

import type { Backend, Filter, Row, SelectQuery, Value } from '@ekwo-ai/core';
import { UsageError } from './args.js';
import type { StoredSession } from './profiles.js';
import { AuthError, baseUrl, refreshSession, type FetchLike, type Instance, type SessionUser } from './session.js';

/** Renew when this close to the end, in seconds. */
const RENEW_BEFORE = 60;

export interface UserClientOptions {
  instance: Instance;
  fetchImpl: FetchLike;
  accessToken: string;
  /** Absent when the token was handed over by the environment: nothing to renew it with. */
  refreshToken?: string | undefined;
  expiresAt?: number | undefined;
  /** Called with the rotated session, before the call that needed it is retried. */
  onRenewed?: ((session: StoredSession) => Promise<void>) | undefined;
  /** What to tell somebody whose session is over. */
  signInAgain: string;
  now?: (() => number) | undefined;
}

export interface SelectOptions {
  columns: readonly string[];
  order?: string;
}

/** What the database, or PostgREST in front of it, answered. Shaped like a driver error. */
export class RestError extends Error {
  code: string | undefined;
  detail: string | undefined;
  hint: string | undefined;
  constructor(message: string, fields: { code?: string | undefined; detail?: string | undefined; hint?: string | undefined }) {
    super(message);
    this.code = fields.code;
    this.detail = fields.detail;
    this.hint = fields.hint;
  }
}

function text(value: unknown): string | undefined {
  return typeof value === 'string' && value.length > 0 ? value : undefined;
}

export class UserClient {
  private accessToken: string;
  private refreshToken: string | undefined;
  private expiresAt: number | undefined;

  constructor(private readonly options: UserClientOptions) {
    this.accessToken = options.accessToken;
    this.refreshToken = options.refreshToken;
    this.expiresAt = options.expiresAt;
  }

  get instance(): Instance {
    return this.options.instance;
  }

  private now(): number {
    return this.options.now?.() ?? Math.floor(Date.now() / 1000);
  }

  private expired(): UsageError {
    return new UsageError(`session_expired: the session is over and could not be renewed. ${this.options.signInAgain}`);
  }

  private async renew(): Promise<void> {
    if (this.refreshToken === undefined) throw this.expired();
    let renewed;
    try {
      renewed = await refreshSession(this.options.fetchImpl, this.options.instance, this.refreshToken);
    } catch (error) {
      // The instance declined the refresh token: revoked, used twice, too old.
      // Anything else — no network — is a failure and says so itself.
      if (error instanceof AuthError && error.status >= 400 && error.status < 500) throw this.expired();
      throw error;
    }
    this.accessToken = renewed.session.access_token;
    this.refreshToken = renewed.session.refresh_token;
    this.expiresAt = renewed.session.expires_at;
    await this.options.onRenewed?.(renewed.session);
  }

  /** One request as the user; renewed and made again, once, on a 401. */
  private async request(path: string, init: RequestInit): Promise<Response> {
    if (
      this.refreshToken !== undefined &&
      this.expiresAt !== undefined &&
      this.expiresAt - this.now() <= RENEW_BEFORE
    ) {
      await this.renew();
    }
    const send = (): Promise<Response> =>
      this.options.fetchImpl(`${baseUrl(this.options.instance.supabaseUrl)}${path}`, {
        ...init,
        headers: {
          ...(init.headers as Record<string, string> | undefined),
          apikey: this.options.instance.anonKey,
          Authorization: `Bearer ${this.accessToken}`,
        },
      });
    const first = await send();
    if (first.status !== 401) return first;
    await this.renew();
    const second = await send();
    if (second.status === 401) throw this.expired();
    return second;
  }

  private async answer<T>(response: Response, what: string): Promise<T> {
    let body: unknown;
    try {
      body = (await response.json()) as unknown;
    } catch {
      body = undefined;
    }
    if (response.ok) return body as T;
    const record = (typeof body === 'object' && body !== null ? body : {}) as Record<string, unknown>;
    throw new RestError(text(record['message']) ?? `${what}: the instance answered ${response.status}`, {
      code: text(record['code']),
      detail: text(record['details']),
      hint: text(record['hint']),
    });
  }

  /** Calls a function of the schema. Rows, whatever the function returns. */
  async rpc<T>(fn: string, args: Record<string, unknown> = {}): Promise<T[]> {
    const response = await this.request(`/rest/v1/rpc/${encodeURIComponent(fn)}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(args),
    });
    const data = await this.answer<unknown>(response, fn);
    return (Array.isArray(data) ? data : [data]) as T[];
  }

  /** Reads what the policies let this person see of a table. */
  async select<T>(table: string, options: SelectOptions): Promise<T[]> {
    const query = new URLSearchParams({ select: options.columns.join(',') });
    if (options.order !== undefined) query.set('order', options.order);
    const response = await this.request(`/rest/v1/${encodeURIComponent(table)}?${query.toString()}`, {
      method: 'GET',
    });
    return this.answer<T[]>(response, `select from ${table}`);
  }

  /** Who the instance says this token is. Also the cheapest way to learn it stopped working. */
  async user(): Promise<SessionUser> {
    const response = await this.request('/auth/v1/user', { method: 'GET' });
    const body = await this.answer<Record<string, unknown>>(response, 'reading the user');
    const id = text(body['id']);
    if (id === undefined) throw new Error('unknown_user: the instance answered without a user');
    return { id, email: text(body['email']) };
  }

  token(): string {
    return this.accessToken;
  }

  /**
   * This client as the `Backend` the bookkeeping functions of the core are
   * written against — the interface the MCP server implements over
   * `@supabase/supabase-js`. Same five operations, same functions on top.
   */
  backend(actingAs: string | undefined): Backend {
    const profile = (schema: string | undefined, write: boolean): Record<string, string> =>
      schema === undefined ? {} : { [write ? 'Content-Profile' : 'Accept-Profile']: schema };

    const call = async (fn: string, args: Record<string, unknown>, schema?: string): Promise<unknown> => {
      const response = await this.request(`/rest/v1/rpc/${encodeURIComponent(fn)}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', ...profile(schema, true) },
        body: JSON.stringify(args),
      });
      return this.answer<unknown>(response, fn);
    };

    return {
      mode: 'postgrest',
      actingAs,

      rpc: async <T>(fn: string, args: Record<string, unknown> = {}, schema?: string): Promise<T[]> => {
        const data = await call(fn, args, schema);
        return (Array.isArray(data) ? data : [data]) as T[];
      },

      rpcVoid: async (fn: string, args: Record<string, unknown> = {}, schema?: string): Promise<void> => {
        await call(fn, args, schema);
      },

      select: async <T>(query: SelectQuery): Promise<T[]> => {
        const params = filterParams(query.where);
        params.set('select', query.columns.join(','));
        if (query.order !== undefined && query.order.length > 0) {
          params.set('order', query.order.map((o) => `${o.column}.${o.ascending === false ? 'desc' : 'asc'}`).join(','));
        }
        if (query.limit !== undefined) params.set('limit', String(query.limit));
        const response = await this.request(`/rest/v1/${encodeURIComponent(query.table)}?${params.toString()}`, {
          method: 'GET',
          headers: profile(query.schema, false),
        });
        return this.answer<T[]>(response, `select from ${query.table}`);
      },

      insert: async <T>(table: string, rows: Row[], returning: string[] = ['*'], schema?: string): Promise<T[]> => {
        const params = new URLSearchParams({ select: returning.join(',') });
        const response = await this.request(`/rest/v1/${encodeURIComponent(table)}?${params.toString()}`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', Prefer: 'return=representation', ...profile(schema, true) },
          body: JSON.stringify(rows),
        });
        return this.answer<T[]>(response, `insert into ${table}`);
      },

      update: async <T>(table: string, patch: Row, where: Filter[], returning: string[] = ['*'], schema?: string): Promise<T[]> => {
        const params = filterParams(where);
        params.set('select', returning.join(','));
        const response = await this.request(`/rest/v1/${encodeURIComponent(table)}?${params.toString()}`, {
          method: 'PATCH',
          headers: { 'Content-Type': 'application/json', Prefer: 'return=representation', ...profile(schema, true) },
          body: JSON.stringify(patch),
        });
        return this.answer<T[]>(response, `update ${table}`);
      },

      remove: async (table: string, where: Filter[], schema?: string): Promise<void> => {
        const response = await this.request(`/rest/v1/${encodeURIComponent(table)}?${filterParams(where).toString()}`, {
          method: 'DELETE',
          headers: profile(schema, true),
        });
        if (!response.ok) await this.answer<unknown>(response, `delete from ${table}`);
      },

      close: async (): Promise<void> => {},
    };
  }
}

/** A value inside `in.(…)`: quoted, so a comma or a parenthesis in it is text. */
function listed(value: Value): string {
  return value === null ? 'null' : `"${String(value).replace(/\\/g, '\\\\').replace(/"/g, '\\"')}"`;
}

/** Filters, in the spelling PostgREST reads from a query string. */
function filterParams(filters: Filter[] | undefined): URLSearchParams {
  const params = new URLSearchParams();
  for (const filter of filters ?? []) {
    switch (filter.op) {
      case 'is':
        params.append(filter.column, 'is.null');
        break;
      case 'in':
        params.append(filter.column, `in.(${filter.value.map(listed).join(',')})`);
        break;
      default:
        params.append(filter.column, `${filter.op}.${String(filter.value)}`);
    }
  }
  return params;
}
