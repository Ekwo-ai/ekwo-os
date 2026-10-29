/**
 * The socle is found where it lives: `public` today, `ekwo` after the move.
 *
 * The clients of this release resolve the socle's schema by its marker,
 * `ekwo_schema_version()`, and name it on every call instead of leaning on a
 * server's default (decision 0090). This holds them to it on both layouts:
 * the database every other test uses, where `20261028040000` has moved the
 * socle into `ekwo` and left nothing of it in `public`, and an installation
 * that has not run that file yet, built here from the migrations before it,
 * where the socle is in `public` and the schema `ekwo` exists and is empty.
 *
 * On the moved layout this file sets the path back to `public`, so a call
 * that did not name the socle's schema would not find a single table: the
 * backends answering at all is the proof that they name it. The move itself
 * is checked too: what `public` kept, what the functions name, what an
 * archive written before still reads as, and how a module's published file is
 * read.
 */

import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { socleMarkerAnswer, socleNamed } from '../packages/core/src/index.js';
import { sqlBackend, type SqlClient } from '../packages/mcp/src/index.js';
import { socleSchemaOf, useSocleSchema } from '../packages/cli/src/socle.js';
import { UserClient } from '../packages/cli/src/rest.js';
import { adapt } from './mcp/helpers.js';
import { ANON_KEY, FAKE_URL, fakeSupabase } from './cli/fake-supabase.js';
import { freshDatabase, migrationFiles, one, repoRoot, rows } from './helpers/db.js';
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

/** The migration that moved the socle; left out to build the layout before it. */
const THE_MOVE = '20261028040000_the_socle_moves_to_its_schema.sql';

/** A file after the move whose column the pack seeds write. */
const WORDS_OF_A_PACK = '20261029021600_a_pack_names_the_words_of_its_invoices.sql';

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

describe('an installation before the move: the socle in public, ekwo created and empty', () => {
  let db: PGlite;
  let owner: string;

  beforeAll(async () => {
    // The move and every file after it: those are written for the socle in
    // `ekwo`, and an installation before the move has run none of them.
    const fromTheMove = (await migrationFiles()).filter((file) => file >= THE_MOVE);
    // Today's seeds are loaded all the same, and the pack seeds write
    // `country_defaults.invoice_labels`, which a file after the move adds to
    // `ekwo`: it is added here to the socle in `public`, as nothing else.
    const migrations = join(repoRoot, 'supabase', 'migrations');
    const beforeSeeds = (await readFile(join(migrations, WORDS_OF_A_PACK), 'utf8')).replaceAll('ekwo.country_defaults', 'public.country_defaults');
    db = await freshDatabase({ withoutMigrations: fromTheMove, beforeSeeds });
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

describe('this release: the socle moved to ekwo', () => {
  let db: PGlite;
  let owner: string;
  let version: string;

  beforeAll(async () => {
    db = await freshDatabase();
    ({ ownerId: owner } = await newCompany(db));
    version = (await one<{ v: string }>(db, 'select ekwo_schema_version() as v')).v;
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

  it('names ekwo in every function of the socle and of the modules, settings and bodies alike', async () => {
    const naming = await rows<{ schema: string; name: string }>(
      db,
      `select n.nspname as schema, p.proname as name
         from pg_proc p join pg_namespace n on n.oid = p.pronamespace
        where n.nspname in (select 'ekwo' union all select schema_name from ekwo.modules)
          and (p.prosrc ~ 'public\\.[a-z_]' or p.prosrc ~ '''public'''
               or exists (select 1 from unnest(p.proconfig) c where c ~ 'public'))
        order by 1, 2`,
    );
    expect(naming).toEqual([]);
    const paths = await rows<{ path: string; n: number }>(
      db,
      `select c as path, count(*)::int as n from pg_proc p, unnest(p.proconfig) c
        where p.pronamespace = 'ekwo'::regnamespace and c like 'search_path=%' group by 1 order by 1`,
    );
    expect(paths.map((p) => p.path)).toEqual(['search_path=ekwo', 'search_path=ekwo, pg_temp']);
  });

  it('keeps the modules where they were, pointing at the socle where it is', async () => {
    const modules = await rows<{ schema_name: string; tables: number; foreign_keys: number }>(
      db,
      `select m.schema_name,
              (select count(*)::int from pg_class c where c.relnamespace = to_regnamespace(m.schema_name) and c.relkind = 'r') as tables,
              (select count(*)::int from pg_constraint k join pg_class r on r.oid = k.confrelid
                where k.contype = 'f' and k.connamespace = to_regnamespace(m.schema_name) and r.relnamespace = 'ekwo'::regnamespace) as foreign_keys
         from ekwo.modules m order by 1`,
    );
    expect(modules.length).toBeGreaterThan(3);
    for (const m of modules) {
      expect(m.tables, m.schema_name).toBeGreaterThan(0);
      expect(m.foreign_keys, m.schema_name).toBeGreaterThan(0);
    }
  });

  it('calls the request hook where it now lives', async () => {
    const hook = await one<{ setting: string | null }>(
      db,
      `select (select s from unnest(coalesce(r.rolconfig, '{}')) as s where s like 'pgrst.db_pre_request=%') as setting
         from pg_roles r where r.rolname = 'authenticator'`,
    );
    expect(hook.setting).toBe('pgrst.db_pre_request=ekwo.ekwo_pre_request');
  });

  it('reads an archive written before the move under the names of today', async () => {
    const registry = await rows<{ table_schema: string }>(db, `select distinct table_schema from ekwo.company_archive_registry order by 1`);
    expect(registry.map((r) => r.table_schema)).not.toContain('public');
    const read = await one<{ out: { tables: Record<string, unknown>; manifest: { tables: Array<{ name: string }> } } }>(
      db,
      `select ekwo.archive_under_current_names($1::jsonb) as out`,
      [
        JSON.stringify({
          tables: { 'public.contacts': [{ id: 1 }], 'public.not_of_the_socle': [], 'fixed_assets.assets': [] },
          manifest: { tables: [{ name: 'public.contacts' }, { name: 'public.not_of_the_socle' }, { name: 'fixed_assets.assets' }] },
        }),
      ],
    );
    expect(Object.keys(read.out.tables).sort()).toEqual(['ekwo.contacts', 'fixed_assets.assets', 'public.not_of_the_socle']);
    expect(read.out.tables['ekwo.contacts']).toEqual([{ id: 1 }]);
    expect(read.out.manifest.tables.map((t) => t.name)).toEqual(['ekwo.contacts', 'public.not_of_the_socle', 'fixed_assets.assets']);
    await expect(
      db.query(`select ekwo.archive_under_current_names($1::jsonb)`, [
        JSON.stringify({ tables: { 'public.contacts': [], 'ekwo.contacts': [] } }),
      ]),
    ).rejects.toThrow(/archive_corrupt/);
  });
});

describe('a module’s published file is read for the socle’s schema of the day', () => {
  const file = [
    'create table assets.things (company_id uuid references public.companies(id));',
    "create policy p on assets.things using (public.is_company_member(company_id, 'assets'));",
    'create function assets.f() returns void language sql set search_path = public, pg_temp as $$ select 1 $$;',
    "insert into public.modules (code, schema_name) values ('assets', 'assets');",
    "-- A sentence that ends with the word public. Then another, with 'public' quoted.",
  ].join('\n');

  it('is left as published while the socle is in public', () => {
    expect(socleNamed(file, 'public')).toBe(file);
  });

  it('names ekwo before every name, in search_path and in the quoted schema, once the socle is there', () => {
    const read = socleNamed(file, 'ekwo');
    expect(read).toContain('references ekwo.companies(id)');
    expect(read).toContain('ekwo.is_company_member(company_id');
    expect(read).toContain('set search_path = ekwo, pg_temp');
    expect(read).toContain('insert into ekwo.modules');
    expect(read).toContain("with 'ekwo' quoted");
    expect(read).toContain('the word public. Then');
    expect(read).not.toMatch(/public\.[a-z]/);
  });

  it('passes a file written for ekwo unchanged', () => {
    const written = socleNamed(file, 'ekwo');
    expect(socleNamed(written, 'ekwo')).toBe(written);
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
