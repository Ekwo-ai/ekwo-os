/**
 * A JSON argument reaches the function as JSON, whatever the driver.
 *
 * PGlite hands a string parameter to the server as it is, and so does the
 * PGlite adapter every other MCP test uses. The `postgres` driver, the one
 * `connect()` opens for `EKWO_DB_URL`, asks the server the type of each
 * parameter first and serialises the value for that type: told `jsonb`, it
 * runs `JSON.stringify` on a string that is JSON already. This test puts a
 * driver that does the same in front of PGlite, and calls a function that
 * takes `jsonb` with an object.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { sqlBackend, type SqlClient } from '../../packages/mcp/src/index.js';
import { freshDatabase } from '../helpers/db.js';
import { newUser } from '../helpers/factory.js';

type Handle = Pick<PGlite, 'query' | 'exec'>;

/** The type the server gives each parameter of a statement, as a driver asks before it sends them. */
async function parameterTypes(handle: Handle, sql: string): Promise<string[]> {
  await handle.exec(`prepare described as ${sql}`);
  try {
    const result = await handle.query<{ types: string[] }>(
      `select parameter_types::text[] as types from pg_prepared_statements where name = 'described'`,
    );
    return result.rows[0]?.types ?? [];
  } finally {
    await handle.exec('deallocate described');
  }
}

/** A driver that serialises each parameter for the type the server describes. */
function typedDriver(handle: Handle, root: PGlite): SqlClient {
  return {
    async query<T = Record<string, unknown>>(sql: string, params: unknown[] = []): Promise<T[]> {
      const types = params.length === 0 ? [] : await parameterTypes(handle, sql);
      const sent = params.map((value, i) =>
        types[i] === 'json' || types[i] === 'jsonb' ? JSON.stringify(value) : value,
      );
      return (await handle.query<T>(sql, sent)).rows;
    },
    async exec(sql: string): Promise<void> {
      await handle.exec(sql);
    },
    async transaction<T>(fn: (tx: SqlClient) => Promise<T>): Promise<T> {
      return (await root.transaction(async (tx) => fn(typedDriver(tx as unknown as Handle, root))));
    },
    async close(): Promise<void> {
      await root.close();
    },
  };
}

let db: PGlite;
let user: string;

beforeAll(async () => {
  db = await freshDatabase();
  user = await newUser(db);
});

afterAll(async () => {
  await db.close();
});

describe('a JSON argument over a typed driver', () => {
  it('arrives as an object, not as a string holding one', async () => {
    const backend = sqlBackend(typedDriver(db, db), { userId: user });
    const rows = await backend.rpc('canonical_json', { p_value: { b: 2, a: [1] } });
    expect(rows).toEqual([{ a: [1], b: 2 }]);
  });
});
