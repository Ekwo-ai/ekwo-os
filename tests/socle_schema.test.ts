/**
 * The socle is found where it lives: `public` today, `ekwo` after the move.
 *
 * The clients of this release resolve the socle's schema by its marker,
 * `ekwo_schema_version()`, and name it on every call instead of leaning on a
 * server's default (decision 0090). This holds them to it on both layouts:
 * the database every other test uses, where the socle is in `public` and the
 * schema `ekwo` exists and is empty, and one where this file moves the socle
 * into `ekwo` the way the next release will — every object of the inventory,
 * with `alter … set schema` — and leaves nothing of it in `public`.
 *
 * On the moved layout the role's `search_path` still says `public`, so a call
 * that did not name the socle's schema would not find a single table: the
 * backends answering at all is the proof that they name it.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { socleMarkerAnswer } from '../packages/core/src/index.js';
import { sqlBackend, type SqlClient } from '../packages/mcp/src/index.js';
import { socleSchemaOf, useSocleSchema } from '../packages/cli/src/socle.js';
import { readExpectedObjects } from '../packages/cli/src/inventory.js';
import { UserClient } from '../packages/cli/src/rest.js';
import { adapt } from './mcp/helpers.js';
import { ANON_KEY, FAKE_URL, fakeSupabase } from './cli/fake-supabase.js';
import { freshDatabase, one } from './helpers/db.js';
import { newCompany } from './helpers/factory.js';

type Queryable = Parameters<typeof adapt>[0];

/** The driver, with every statement it was handed written down. */
function recording(db: PGlite): { client: SqlClient; statements: string[] } {
  const statements: string[] = [];
  const wrap = (inner: SqlClient): SqlClient => ({
    query: async (sql, params) => {
      statements.push(sql);
      return inner.query(sql, params);
    },
    exec: async (sql) => {
      statements.push(sql);
      return inner.exec(sql);
    },
    transaction: (fn) => inner.transaction((tx) => fn(wrap(tx))),
    close: () => inner.close(),
  });
  return { client: wrap(adapt(db as unknown as Queryable, db)), statements };
}

/**
 * Moves every object of the socle's inventory from `public` to `ekwo`, and
 * points the functions' own `search_path` at it — what the migration of the
 * next release does, reduced to what these calls need.
 */
async function moveTheSocle(db: PGlite): Promise<void> {
  const expected = await readExpectedObjects();
  if (expected === undefined) throw new Error('the CLI ships no inventory: run `npm run inventory`');
  const socle = expected.socle;
  const statements: string[] = [];
  for (const table of socle.tables) statements.push(`alter table public.${table.name} set schema ekwo;`);
  for (const view of socle.views) statements.push(`alter view public.${view} set schema ekwo;`);
  const names = [...new Set(socle.functions.map((f) => f.name))];
  const routines = await db.query<{ signature: string; kind: string }>(
    `select p.oid::regprocedure::text as signature, p.prokind::text as kind
       from pg_proc p where p.pronamespace = 'public'::regnamespace and p.proname = any($1)`,
    [names],
  );
  for (const routine of routines.rows) {
    statements.push(`alter ${routine.kind === 'a' ? 'aggregate' : 'routine'} ${routine.signature} set schema ekwo;`);
  }
  for (const type of socle.types) statements.push(`alter type public.${type.name} set schema ekwo;`);
  // The signatures name types as `public` calls them, and each type moves
  // along the way: with both schemas on the path, every name resolves.
  await db.exec(`set search_path = public, ekwo;\n${statements.join('\n')}`);
  await db.exec(`
    do $$
    declare r record;
    begin
      for r in select p.oid::regprocedure as routine from pg_proc p
                where p.pronamespace = 'ekwo'::regnamespace and p.prokind in ('f', 'p')
      loop
        execute format('alter routine %s set search_path = ekwo, pg_temp', r.routine);
      end loop;
    end $$;
  `);
}

/**
 * The command line's PostgREST client, signed in as `userId`, against a
 * stand-in for PostgREST that serves a schema by its profile header and
 * answers 404 for a function its schema does not hold, as PostgREST does.
 */
async function overPostgrest(db: PGlite, userId: string): Promise<{ client: UserClient; calls: string[] }> {
  const instance = fakeSupabase(db);
  instance.addUser(userId, 'owner@example.test', 'a long passphrase');
  const signedIn = await instance.fetchImpl(`${FAKE_URL}/auth/v1/token?grant_type=password`, {
    method: 'POST',
    body: JSON.stringify({ email: 'owner@example.test', password: 'a long passphrase' }),
  });
  const { access_token: accessToken } = (await signedIn.json()) as { access_token: string };
  const client = new UserClient({
    instance: { supabaseUrl: FAKE_URL, anonKey: ANON_KEY },
    fetchImpl: instance.fetchImpl,
    accessToken,
    signInAgain: '',
  });
  return { client, calls: instance.calls };
}

describe('the socle in public, ekwo created and empty', () => {
  let db: PGlite;
  let owner: string;

  beforeAll(async () => {
    db = await freshDatabase();
    ({ ownerId: owner } = await newCompany(db));
  });

  afterAll(async () => {
    await db.close();
  });

  it('creates the schema ekwo, empty, reachable by the three roles', async () => {
    const schema = await one<{ objects: number; usage: boolean[] }>(
      db,
      `select (select count(*)::int from pg_class where relnamespace = 'ekwo'::regnamespace)
            + (select count(*)::int from pg_proc where pronamespace = 'ekwo'::regnamespace) as objects,
              array[has_schema_privilege('anon', 'ekwo', 'usage'),
                    has_schema_privilege('authenticated', 'ekwo', 'usage'),
                    has_schema_privilege('service_role', 'ekwo', 'usage')] as usage`,
    );
    expect(schema).toEqual({ objects: 0, usage: [true, true, true] });
  });

  it('is found in public, and every call names public', async () => {
    const { client, statements } = recording(db);
    const backend = sqlBackend(client, { userId: owner });
    expect(await backend.socleSchema()).toBe('public');
    const companies = await backend.select<{ name: string }>({ table: 'companies', columns: ['name'] });
    expect(companies.map((c) => c.name)).toEqual(['Test Company']);
    expect(statements.some((sql) => sql.includes('from public.companies'))).toBe(true);
  });

  it('is found once per connection', async () => {
    const { client, statements } = recording(db);
    const backend = sqlBackend(client, { userId: owner });
    await backend.select({ table: 'companies', columns: ['id'] });
    await backend.rpc('ekwo_schema_version');
    await backend.socleSchema();
    expect(statements.filter((sql) => sql.includes('pg_proc p join pg_namespace n'))).toHaveLength(1);
  });

  it('is found in public over PostgREST, asked once', async () => {
    const { client, calls } = await overPostgrest(db, owner);
    const backend = client.backend(owner);
    expect(await backend.socleSchema()).toBe('public');
    const companies = await backend.select<{ name: string }>({ table: 'companies', columns: ['name'] });
    expect(companies.map((c) => c.name)).toEqual(['Test Company']);
    await client.rpc('ekwo_schema_version');
    expect(calls.filter((call) => call === 'POST /rest/v1/rpc/ekwo_schema_version')).toHaveLength(2);
  });

  it('is found in public by the command line, which puts it first on the path', async () => {
    const client = adapt(db as unknown as Queryable, db);
    expect(await socleSchemaOf(client)).toBe('public');
    expect(await useSocleSchema(client)).toBe('public');
    const path = await one<{ search_path: string }>(db, `select current_setting('search_path') as search_path`);
    expect(path.search_path.split(',')[0]?.trim()).toBe('public');
  });
});

describe('the socle moved to ekwo', () => {
  let db: PGlite;
  let owner: string;
  let version: string;

  beforeAll(async () => {
    db = await freshDatabase();
    ({ ownerId: owner } = await newCompany(db));
    version = (await one<{ v: string }>(db, 'select ekwo_schema_version() as v')).v;
    await moveTheSocle(db);
    // Nothing of the socle is left where a call that names no schema would look.
    await db.exec(`set search_path = public`);
  });

  afterAll(async () => {
    await db.close();
  });

  it('leaves nothing of the socle in public', async () => {
    const left = await one<{ tables: number; marker: boolean }>(
      db,
      `select (select count(*)::int from pg_class where relnamespace = 'public'::regnamespace and relkind = 'r') as tables,
              to_regprocedure('public.ekwo_schema_version()') is not null as marker`,
    );
    expect(left).toEqual({ tables: 0, marker: false });
  });

  it('is found in ekwo, and every call names ekwo', async () => {
    const { client, statements } = recording(db);
    const backend = sqlBackend(client, { userId: owner });
    expect(await backend.socleSchema()).toBe('ekwo');
    expect(await backend.rpc<string>('ekwo_schema_version')).toEqual([version]);
    const companies = await backend.select<{ name: string }>({ table: 'companies', columns: ['name'] });
    expect(companies.map((c) => c.name)).toEqual(['Test Company']);
    expect(statements.some((sql) => sql.includes('from ekwo.companies'))).toBe(true);
    expect(statements.some((sql) => /from (public\.)?companies\b/.test(sql))).toBe(false);
  });

  it('is found in ekwo over PostgREST, by the profile every request carries', async () => {
    const { client } = await overPostgrest(db, owner);
    const backend = client.backend(owner);
    expect(await backend.socleSchema()).toBe('ekwo');
    const companies = await backend.select<{ name: string }>({ table: 'companies', columns: ['name'] });
    expect(companies.map((c) => c.name)).toEqual(['Test Company']);
    expect(await client.rpc<string>('ekwo_schema_version')).toEqual([version]);
  });

  it('is found in ekwo by the command line, whose unqualified SQL then lands there', async () => {
    const client = adapt(db as unknown as Queryable, db);
    expect(await socleSchemaOf(client)).toBe('ekwo');
    await expect(client.query('select count(*) from companies')).rejects.toThrow();
    expect(await useSocleSchema(client)).toBe('ekwo');
    const path = await one<{ search_path: string }>(db, `select current_setting('search_path') as search_path`);
    expect(path.search_path).toBe('ekwo, public');
    const count = await one<{ n: number }>(db, `select count(*)::int as n from companies where name = 'Test Company'`);
    expect(count.n).toBe(1);
  });
});

describe('the marker over PostgREST', () => {
  it('reads an answer, a schema not exposed and a function not there, and nothing else', () => {
    expect(socleMarkerAnswer({ ok: true, status: 200 })).toBe(true);
    expect(socleMarkerAnswer({ ok: false, status: 403, code: '42501' })).toBe(true);
    expect(socleMarkerAnswer({ ok: false, status: 406, code: 'PGRST106' })).toBe(false);
    expect(socleMarkerAnswer({ ok: false, status: 404, code: 'PGRST202' })).toBe(false);
    expect(socleMarkerAnswer({ ok: false, status: 500, code: 'XX000' })).toBeUndefined();
  });
});
