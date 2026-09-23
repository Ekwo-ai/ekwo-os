/**
 * Every guard of this schema, asked by a machine key.
 *
 * `20260922160000` changed what "nobody is signed in" means. It used to mean
 * the installer, on a direct connection, before anybody existed. It now also
 * means a key: one arrives as `authenticated` with `auth.uid()` null, because
 * a key is not a session. So a guard written as
 *
 *     if auth.uid() is not null and not has_capability(…) then raise
 *
 * stopped being the guard it reads as. It says "check the caller, unless there
 * is nobody to check", and with a key there is nobody — the condition is
 * false, and whoever holds any key of the company walks past it.
 *
 * Two tests here, and they are different in kind. The first is the sweep: it
 * asks the database which functions test whether `auth.uid()` is null, and
 * holds them against a list somebody argued for, so a guard written that way
 * tomorrow is a failure here and not a finding a year later. The second is
 * `pack_upgrade()`, which had it the wrong way round.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newUser } from './helpers/factory.js';

let db: PGlite;
let companyId: string;
let ownerId: string;
let country: string;

/** One request carrying a key, the way `ekwo_pre_request()` receives it. */
async function withKey<T>(secret: string, fn: () => Promise<T>): Promise<T | string> {
  await db.exec(`
    select set_config('request.jwt.claims', '', false);
    select set_config('ekwo.installing', '', false);
  `);
  await db.query('begin');
  await db.exec(`
    set local role anon;
    select set_config('request.headers', '${JSON.stringify({ 'x-ekwo-api-key': secret })}', true);
  `);
  try {
    await db.query(`select ekwo_pre_request()`);
    return await fn();
  } catch (error) {
    return (error as Error).message;
  } finally {
    await db.query('commit');
    await db.exec(`
      reset role;
      select set_config('request.headers', '', false);
      select set_config('ekwo.installing', 'on', false);
    `);
  }
}

beforeAll(async () => {
  db = await freshDatabase();
  ownerId = await newUser(db, 'owner@guards.test');
  ({ companyId } = await newCompany(db, { name: 'Gardes', ownerId }));
  country = (
    await one<{ country: string }>(db, `select country from companies where id = $1`, [companyId])
  ).country;
}, 180_000);

afterAll(async () => {
  await db.close();
});

describe('every guard that asks whether anybody is signed in', () => {
  /**
   * The functions allowed to test `auth.uid()` for null, and why each is
   * right. A name arriving here is a decision: with a key presented,
   * `auth.uid()` is null and the caller is not an absence.
   */
  const ARGUED: Record<string, string> = {
    // Raise when nobody is signed in, so a key is refused. Right: an
    // invitation is accepted by a person, and preferences belong to one.
    accept_invitation: 'raises when there is no user',
    set_preferences: 'raises when there is no user',
    // Asks for a signed-in user *and* the capability before allowing, so a key
    // fails the condition and the guard fires. The safe direction.
    entries_guard_posted: 'demands a user before allowing, so a key is refused',
    // False as soon as a key is presented: a key is never the installer.
    is_installer: 'is false whenever a key is presented',
    // Ask the question the other way round: a key is a caller this
    // installation knows, not an absence.
    is_known_caller: 'counts a key as a caller',
    installed_schema_version: 'answers a session or a key, and nobody else',
  };

  it('is one somebody argued for, and no other', async () => {
    const found = await rows<{ fn: string }>(
      db,
      `select p.proname as fn
         from pg_proc p join pg_namespace n on n.oid = p.pronamespace
        where n.nspname in ('public', 'assets', 'budgets') and p.prokind = 'f'
          and (p.prosrc ~* 'auth\\.uid\\(\\)\\s+is\\s+null'
            or p.prosrc ~* 'auth\\.uid\\(\\)\\s+is\\s+not\\s+null')
        order by 1`,
    );
    expect(found.map((f) => f.fn)).toEqual(Object.keys(ARGUED).sort());
  });

  it('never skips its check merely because nobody is signed in', async () => {
    // The shape that stopped being safe: a guard whose whole condition is
    // `auth.uid() is not null and not <something>`. A key makes the first half
    // false, so the raise never happens. `entries_guard_posted` is the one
    // phrasing that is safe with a null user, and it is named rather than
    // matched loosely.
    const skipped = await rows<{ fn: string }>(
      db,
      `select p.proname as fn
         from pg_proc p join pg_namespace n on n.oid = p.pronamespace
        where n.nspname in ('public', 'assets', 'budgets') and p.prokind = 'f'
          and p.prosrc ~* 'if\\s+auth\\.uid\\(\\)\\s+is\\s+not\\s+null\\s+and\\s+not\\s'
        order by 1`,
    );
    expect(skipped.map((f) => f.fn)).toEqual([]);
  });
});

describe('pack_upgrade, which had it the wrong way round', () => {
  it('refuses a key that does not hold company.write', async () => {
    const key = await asUser(db, ownerId, async () =>
      one<{ secret: string }>(
        db,
        `select * from create_api_key($1, 'lecture', '["entries.read"]'::jsonb, null)`,
        [companyId],
      ),
    );

    const held = await withKey(key.secret, async () =>
      one<{ writes: boolean }>(db, `select has_capability($1, 'company.write') as writes`, [
        companyId,
      ]),
    );
    expect(typeof held).toBe('object');
    expect((held as { writes: boolean }).writes).toBe(false);

    // It moves a company onto another version of its country pack: the chart,
    // the taxes and where each posts, the boxes of the declaration form. A key
    // holding nothing but `entries.read` used to be answered.
    const said = await withKey(key.secret, async () =>
      one(db, `select pack_upgrade($1, $2::char(2), true) as answer`, [companyId, country]),
    );
    expect(typeof said, JSON.stringify(said)).toBe('string');
    expect(said as string).toMatch(/not_allowed/);
    expect(said as string).toContain('company.write');
  });

  it('answers a key that does hold it', async () => {
    const key = await asUser(db, ownerId, async () =>
      one<{ secret: string }>(
        db,
        `select * from create_api_key($1, 'ecriture', '["company.write"]'::jsonb, null)`,
        [companyId],
      ),
    );
    const answered = await withKey(key.secret, async () =>
      one<{ answer: { company_id: string } }>(
        db,
        `select pack_upgrade($1, $2::char(2), false) as answer`,
        [companyId, country],
      ),
    );
    expect(typeof answered, JSON.stringify(answered)).toBe('object');
    expect((answered as { answer: { company_id: string } }).answer.company_id).toBe(companyId);
  });

  it('still answers a member who holds it, and refuses one who does not', async () => {
    const listed = await asUser(db, ownerId, async () =>
      one<{ answer: { company_id: string } }>(
        db,
        `select pack_upgrade($1, $2::char(2), false) as answer`,
        [companyId, country],
      ),
    );
    expect(listed.answer.company_id).toBe(companyId);

    const viewer = await newUser(db, 'viewer@guards.test');
    await db.query(
      `insert into company_members (company_id, user_id, role) values ($1, $2, 'viewer')`,
      [companyId, viewer],
    );
    let said = 'answered';
    try {
      await asUser(db, viewer, async () =>
        one(db, `select pack_upgrade($1, $2::char(2), true) as answer`, [companyId, country]),
      );
    } catch (error) {
      said = (error as Error).message;
    }
    expect(said).toMatch(/not_allowed/);
  });
});
