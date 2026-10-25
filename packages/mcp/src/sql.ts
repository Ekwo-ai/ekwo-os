/**
 * The direct-Postgres backend.
 *
 * For a self-hosted installation where PostgREST is not in front of the
 * database, and for the tests, which run the real schema in Postgres compiled
 * to WebAssembly. It is the second route, not the privileged one: every call
 * runs inside a transaction that sets `request.jwt.claims` and switches to
 * the `authenticated` role, so row level security binds exactly as it does
 * over the API. A connection that could bypass the policies would make this
 * server a way round them, which is the one thing it must never be.
 *
 * The driver is behind `SqlClient` — thirty lines with nothing to decide — so
 * the tests plug PGlite in and never load a network driver.
 */

import {
  EkwoMcpError,
  columnName,
  explain,
  identifier,
  qualified,
  type AgentSession,
  type Backend,
  type Filter,
  type Row,
  type SelectQuery,
  type Value,
} from './backend.js';
import { onSocle, socleMarkerInCatalogue, socleSchemaResolver, type SocleBackend } from '@ekwo-ai/core';

/** A Postgres connection, reduced to what this server needs. */
export interface SqlClient {
  query<T = Record<string, unknown>>(sql: string, params?: unknown[]): Promise<T[]>;
  exec(sql: string): Promise<void>;
  transaction<T>(fn: (tx: SqlClient) => Promise<T>): Promise<T>;
  close(): Promise<void>;
}

/** Builds `where` with $n placeholders, appending to `params`. */
function whereClause(filters: Filter[] | undefined, params: unknown[]): string {
  if (filters === undefined || filters.length === 0) return '';
  const parts = filters.map((filter) => {
    const column = identifier(filter.column);
    switch (filter.op) {
      case 'is':
        return `${column} is null`;
      case 'in': {
        if (filter.value.length === 0) return 'false';
        const slots = filter.value.map((value) => {
          params.push(value);
          return `$${params.length}`;
        });
        return `${column} in (${slots.join(', ')})`;
      }
      case 'ilike':
        params.push(filter.value);
        return `${column} ilike $${params.length}`;
      default: {
        const operator = { eq: '=', neq: '<>', gt: '>', gte: '>=', lt: '<', lte: '<=' }[filter.op];
        params.push(filter.value);
        return `${column} ${operator} $${params.length}`;
      }
    }
  });
  return ` where ${parts.join(' and ')}`;
}

/** `amount::text` is selected as `amount::text as amount`, so keys never shift. */
function selectList(columns: string[]): string {
  return columns
    .map((column) => {
      const cast = column.indexOf('::');
      if (cast === -1) return identifier(column);
      const name = columnName(column);
      const type = column.slice(cast + 2);
      if (!/^[a-z ]+$/.test(type)) {
        throw new EkwoMcpError(`bad_identifier: ${column} is not a column and a cast`);
      }
      return `${name}::${type} as ${name}`;
    })
    .join(', ');
}

export interface SqlBackendOptions {
  /**
   * The user this server acts for. Required: without it there is no
   * `auth.uid()`, every policy fails closed, and the useful-looking
   * alternative — running as the owner — is the one that must not exist.
   */
  userId: string;
  /** Extra JWT claims, if an installation reads more than `sub` and `role`. */
  claims?: Record<string, unknown>;
  /**
   * Marks every transaction as an agent's (`ekwo.agent`, with the session's
   * choice of `review` or `autopilot` if it made one, and `ekwo.agent_session`),
   * which the database reads to hold a posting to the company's
   * `agent_posting`. The MCP server sets it; a script acting for a person does
   * not.
   */
  agent?: AgentSession | undefined;
}

/** `fn(p_a => $1, p_b => $2)` and the parameters in that order. */
/**
 * An argument that is an object or an array is JSON, and is sent as JSON.
 *
 * PostgREST posts the arguments as a JSON body, so a `jsonb` parameter
 * receives a real array on that route. A Postgres driver does not: handed a
 * JavaScript array it builds a Postgres *array* literal, and `node-postgres`
 * turns an array of objects into `{"[object Object]"}`. So the value is
 * stringified here and the placeholder carries an explicit `::jsonb`, which
 * makes the two routes agree instead of agreeing by accident on one driver.
 *
 * The cast goes through `text`. A driver that asks the server for the type
 * of each parameter — `postgres`, the one `connect()` opens — is told `jsonb`
 * for `$1::jsonb` and serialises the value as JSON a second time: the string
 * arrives as a JSON string, and `p_books ->> 'source'` reads null. Told
 * `text`, every driver sends the string as it is.
 */
function callOf(
  fn: string,
  args: Record<string, unknown>,
  schema?: string,
  arrays: ReadonlyMap<string, string> = new Map(),
): { call: string; params: unknown[] } {
  const entries = Object.entries(args);
  const params: unknown[] = [];
  const parts = entries.map(([name, value], index) => {
    const array = arrays.get(name);
    if (array !== undefined && Array.isArray(value)) {
      params.push(arrayLiteral(value));
      return `${identifier(name)} => $${index + 1}::text::${array}`;
    }
    const json = typeof value === 'object' && value !== null;
    params.push(json ? JSON.stringify(value) : value);
    return `${identifier(name)} => $${index + 1}${json ? '::text::jsonb' : ''}`;
  });
  return { call: `${qualified(schema, fn)}(${parts.join(', ')})`, params };
}

/**
 * A list for a parameter declared as a Postgres array — `uuid[]`,
 * `numeric[]` — is that array, not JSON: PostgREST reads the JSON list into
 * the declared type, and this route says the same thing in the literal
 * Postgres reads, each element quoted, through `text` like a JSON argument.
 */
function arrayLiteral(values: unknown[]): string {
  const element = (value: unknown): string =>
    value === null || value === undefined ? 'NULL' : `"${String(value).replace(/["\\]/g, (c) => `\\${c}`)}"`;
  return `{${values.map(element).join(',')}}`;
}

/** Only such a name reaches a cast, so a type read from the catalogue is checked all the same. */
const ARRAY_TYPE = /^[a-z_][a-z0-9_ ]*\[\]$/;

export function sqlBackend(db: SqlClient, options: SqlBackendOptions): SocleBackend {
  const agent = options.agent;
  const claims = JSON.stringify({
    ...(options.claims ?? {}),
    sub: options.userId,
    role: 'authenticated',
  });

  /**
   * One statement, as the user.
   *
   * `set_config(..., true)` and `set local role` are both transaction-scoped,
   * so nothing leaks into the next call even on a pooled connection.
   */
  async function asUser<T>(run: (tx: SqlClient) => Promise<T>): Promise<T> {
    try {
      return await db.transaction(async (tx) => {
        await tx.query('select set_config($1, $2, true)', ['request.jwt.claims', claims]);
        if (agent !== undefined) {
          await tx.query(
            "select set_config('ekwo.agent', $1, true), set_config('ekwo.agent_session', $2, true)",
            [agent.posting ?? 'on', agent.id ?? ''],
          );
        }
        await tx.exec('set local role authenticated');
        return run(tx);
      });
    } catch (error) {
      throw explain((error as Error).message);
    }
  }

  /**
   * The parameters of a function that are Postgres arrays, by name, read once
   * per function from the catalogue. Every other list is JSON.
   */
  const arrayParameters = new Map<string, Promise<ReadonlyMap<string, string>>>();
  function arraysOf(fn: string, schema?: string): Promise<ReadonlyMap<string, string>> {
    const key = `${schema ?? ''}.${fn}`;
    let found = arrayParameters.get(key);
    if (found === undefined) {
      found = asUser((tx) =>
        tx.query<{ name: string; type: string }>(
          `select a.name, a.type::regtype::text as type
             from pg_proc p
             join pg_namespace n on n.oid = p.pronamespace
             cross join lateral unnest(p.proargnames, coalesce(p.proallargtypes, p.proargtypes::oid[])) as a (name, type)
            where n.nspname = coalesce($1, current_schema()) and p.proname = $2`,
          [schema ?? null, fn],
        ),
      ).then(
        (rows) => new Map(rows.filter((row) => ARRAY_TYPE.test(row.type)).map((row) => [row.name, row.type])),
        (error: unknown) => {
          arrayParameters.delete(key);
          throw error;
        },
      );
      arrayParameters.set(key, found);
    }
    return found;
  }

  /** The call, with a list for an array parameter sent as that array. */
  async function callFor(fn: string, args: Record<string, unknown>, schema?: string): Promise<{ call: string; params: unknown[] }> {
    const arrays = Object.values(args).some(Array.isArray) ? await arraysOf(fn, schema) : undefined;
    return callOf(fn, args, schema, arrays);
  }

  // Every call below receives its schema from `onSocle()`: a module's, or
  // the socle's as the marker resolved it, once for this connection.
  const backend: Backend = {
    mode: 'sql',
    actingAs: options.userId,
    agent,

    async rpc<T>(fn: string, args: Record<string, unknown> = {}, schema?: string): Promise<T[]> {
      const { call, params } = await callFor(fn, args, schema);
      // Aggregated as JSON so the shape matches what PostgREST returns for the
      // same function, instead of depending on how a driver types a column.
      const rows = await asUser((tx) =>
        tx.query<{ value: unknown }>(
          `select coalesce(jsonb_agg(to_jsonb(f)), '[]'::jsonb) as value from ${call} f`,
          params,
        ),
      );
      return (rows[0]?.value ?? []) as T[];
    },

    async rpcVoid(fn: string, args: Record<string, unknown> = {}, schema?: string): Promise<void> {
      const { call, params } = await callFor(fn, args, schema);
      await asUser((tx) => tx.query(`select ${call}`, params));
    },

    async select<T>(query: SelectQuery): Promise<T[]> {
      const params: unknown[] = [];
      let sql = `select ${selectList(query.columns)} from ${qualified(query.schema, query.table)}`;
      sql += whereClause(query.where, params);
      if (query.order !== undefined && query.order.length > 0) {
        const parts = query.order.map(
          (order) => `${identifier(order.column)} ${order.ascending === false ? 'desc' : 'asc'}`,
        );
        sql += ` order by ${parts.join(', ')}`;
      }
      if (query.limit !== undefined) {
        params.push(query.limit);
        sql += ` limit $${params.length}`;
      }
      return asUser((tx) => tx.query<T>(sql, params));
    },

    async insert<T>(
      table: string,
      rows: Row[],
      returning: string[] = ['*'],
      schema?: string,
    ): Promise<T[]> {
      if (rows.length === 0) return [];
      const columns = Object.keys(rows[0] as Row).map(identifier);
      const params: unknown[] = [];
      const tuples = rows.map((row) => {
        const slots = columns.map((column) => {
          params.push((row as Row)[column] as Value);
          return `$${params.length}`;
        });
        return `(${slots.join(', ')})`;
      });
      const sql =
        `insert into ${qualified(schema, table)} (${columns.join(', ')}) values ${tuples.join(', ')}` +
        ` returning ${returning[0] === '*' ? '*' : selectList(returning)}`;
      return asUser((tx) => tx.query<T>(sql, params));
    },

    async update<T>(
      table: string,
      patch: Row,
      where: Filter[],
      returning: string[] = ['*'],
      schema?: string,
    ): Promise<T[]> {
      const params: unknown[] = [];
      const assignments = Object.keys(patch).map((column) => {
        params.push(patch[column] as Value);
        return `${identifier(column)} = $${params.length}`;
      });
      if (assignments.length === 0) {
        throw new EkwoMcpError(`empty_update: nothing to change on ${table}`);
      }
      const sql =
        `update ${qualified(schema, table)} set ${assignments.join(', ')}` +
        whereClause(where, params) +
        ` returning ${returning[0] === '*' ? '*' : selectList(returning)}`;
      return asUser((tx) => tx.query<T>(sql, params));
    },

    async remove(table: string, where: Filter[], schema?: string): Promise<void> {
      const params: unknown[] = [];
      const sql = `delete from ${qualified(schema, table)}` + whereClause(where, params);
      await asUser((tx) => tx.query(sql, params));
    },

    async close(): Promise<void> {
      await db.close();
    },
  };
  return onSocle(backend, socleSchemaResolver((schema) => socleMarkerInCatalogue((sql, params) => db.query(sql, params), schema)));
}

/** Opens a connection with the `postgres` driver. */
export async function connect(connectionString: string): Promise<SqlClient> {
  // Imported lazily, and declared as an optional peer dependency: the
  // recommended route needs no Postgres driver at all, so an operator who
  // never sets EKWO_DB_URL should not have to install one.
  const { default: postgres } = await import('postgres').catch(() => {
    throw new EkwoMcpError(
      'missing_driver: EKWO_DB_URL needs the `postgres` package. Install it alongside this server, or use SUPABASE_URL with a user session instead.',
    );
  });

  const sql = postgres(connectionString, {
    max: 1,
    prepare: false,
    idle_timeout: 20,
    connect_timeout: 30,
    onnotice: () => {},
  });

  type Sql = typeof sql;

  const wrap = (handle: Sql): SqlClient => ({
    async query<T = Record<string, unknown>>(text: string, params: unknown[] = []): Promise<T[]> {
      const result = await handle.unsafe(text, params as never[]);
      return result as unknown as T[];
    },
    async exec(text: string): Promise<void> {
      await handle.unsafe(text).simple();
    },
    async transaction<T>(fn: (tx: SqlClient) => Promise<T>): Promise<T> {
      return (await handle.begin(async (tx) => fn(wrap(tx as unknown as Sql)))) as T;
    },
    async close(): Promise<void> {
      await sql.end({ timeout: 5 });
    },
  });

  try {
    await sql`select 1`;
  } catch (error) {
    await sql.end({ timeout: 5 }).catch(() => {});
    throw error;
  }

  return wrap(sql);
}
