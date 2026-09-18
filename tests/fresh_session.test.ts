import { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { expectError, freshDatabase, one, rows } from './helpers/db.js';

/**
 * A session nobody prepared.
 *
 * Every other test of this repository runs on the connection `freshDatabase`
 * hands out, where `ekwo.installing` has been set — to `on` for the owner, to
 * the empty string inside `asUser`. A setting that was set and emptied answers
 * `''`; a setting that was **never set** answers NULL, and that is what a new
 * connection looks like: a request through PostgREST, a pooled connection, a
 * `psql` somebody opened. `NULL = 'on'` is NULL, `not NULL` is NULL, and
 * `if NULL then raise` does not raise — so a guard written
 * `if not is_installer() and not has_capability(…)` was skipped for a caller
 * with no session and no key, which is what `service_role` is.
 *
 * So this file reloads the database into a second instance, where nothing was
 * ever set, and asks the questions there.
 */

let prepared: PGlite;
let db: PGlite;

beforeAll(async () => {
  prepared = await freshDatabase();
  db = new PGlite({ loadDataDir: await prepared.dumpDataDir('none') });
  await db.waitReady;
});

afterAll(async () => {
  await db.close();
  await prepared.close();
});

describe('a session where nothing was ever set', () => {
  it('is what this test says it is: the setting is NULL, not empty', async () => {
    const { setting } = await one<{ setting: string | null }>(
      db,
      `select current_setting('ekwo.installing', true) as setting`,
    );
    expect(setting).toBeNull();
  });

  it('is not the installer — and says false, not NULL', async () => {
    for (const role of ['service_role', 'authenticated']) {
      await db.exec(`set role ${role};`);
      try {
        const { installer } = await one<{ installer: boolean | null }>(
          db,
          `select is_installer() as installer`,
        );
        expect(installer, role).toBe(false);
      } finally {
        await db.exec(`reset role;`);
      }
    }
  });

  it('cannot create a company by holding no session and no key', async () => {
    const [country] = await rows<{ code: string }>(
      db,
      `select country as code from country_defaults order by 1 limit 1`,
    );
    await db.exec(`set role service_role;`);
    try {
      const message = await expectError(db, `select create_company('Nobody Ltd', $1)`, [
        (country as { code: string }).code,
      ]);
      expect(message).toMatch(/not_allowed|instance_admin|permission/);
    } finally {
      await db.exec(`reset role;`);
    }
    const { n } = await one<{ n: number }>(
      db,
      `select count(*)::int as n from companies where name = 'Nobody Ltd'`,
    );
    expect(n).toBe(0);
  });

  it('no helper a guard negates can answer NULL to such a caller', async () => {
    // `not f()` is only a refusal when f() is false. Every boolean helper that
    // takes no argument and is read by a guard is asked here, as the caller
    // with nothing; a new one that can answer NULL fails this test.
    const helpers = await rows<{ name: string }>(
      db,
      `select p.proname as name
         from pg_proc p
         join pg_namespace n on n.oid = p.pronamespace
        where n.nspname = 'public'
          and p.prorettype = 'boolean'::regtype
          and p.pronargs = 0
          and p.prokind = 'f'
        order by 1`,
    );
    expect(helpers.map((h) => h.name)).toContain('is_installer');
    await db.exec(`set role service_role;`);
    try {
      for (const { name } of helpers) {
        const { answer } = await one<{ answer: boolean | null }>(
          db,
          `select ${name}() as answer`,
        );
        expect(answer, `${name}()`).not.toBeNull();
      }
    } finally {
      await db.exec(`reset role;`);
    }
  });
});
