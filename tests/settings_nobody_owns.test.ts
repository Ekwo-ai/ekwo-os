/**
 * The `ekwo.*` settings belong to nobody.
 *
 * A custom setting — a placeholder GUC, in PostgreSQL's words — has no
 * privileges. Any session may `set ekwo.installing = 'on'`, and so may any
 * session set `ekwo.year_end_entry` or `ekwo.closing_fiscal_year`. PostgREST
 * gives a client no way to issue a `SET`, so a request through the API never
 * reaches this. A direct connection does, and a direct connection is the way
 * Ekwo OS is put forward on a Postgres of one's own.
 *
 * Found by an outside reader of the migrations, who put it this way: a second
 * login role — a reporting user, a BI tool, a restricted bookkeeper — has
 * `auth.uid()` null and no `ekwo.api_key`, so one `SET` made `is_installer()`
 * true for it. Every guard written `if not is_installer() and not
 * has_capability(…)` then stood aside.
 *
 * So the first group is that role, made the way an operator would make it: a
 * login, a member of `authenticated` so that the schema's grants reach it, and
 * nothing else. `set session authorization` is what makes it a second login
 * rather than the owner wearing another hat — `set role` leaves
 * `session_user` where it was, and `session_user` is what the installer is
 * now judged on.
 *
 * The second group is the two settings the year-end functions raise while
 * they write. Those are read by guards that could not tell who had set them,
 * so a person on a direct connection could raise the flag by hand and do what
 * only the function was meant to do. They now also ask whether that person
 * could have called the function at all.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one } from './helpers/db.js';
import { newCompany } from './helpers/factory.js';

let db: PGlite;
let companyId: string;
let ownerId: string;
/** The login of the harness, which the second one hands back to. */
let harness: string;

beforeAll(async () => {
  db = await freshDatabase();
  ({ companyId, ownerId } = await newCompany(db, { name: 'Second Login Ltd' }));
  ({ harness } = await one<{ harness: string }>(db, `select session_user::text as harness`));
  await db.exec(`
    create role reporting login;
    grant authenticated to reporting;
  `);
});

afterAll(async () => {
  await db.close();
});

/**
 * Runs `fn` as the `reporting` login, with no session and no key, after it
 * has made the one `SET` the audit describes. The owner's connection is put
 * back afterwards whatever happened.
 */
async function asSecondLogin<T>(fn: () => Promise<T>): Promise<T> {
  await db.exec(`
    select set_config('request.jwt.claims', '', false);
    select set_config('ekwo.installing', '', false);
    set session authorization reporting;
    select set_config('ekwo.installing', 'on', false);
  `);
  try {
    return await fn();
  } finally {
    // By name: under PGlite `reset session authorization` stays on the
    // second login, which a real server would not do. The harness is a
    // superuser, so it may take its own name back.
    await db.exec(`
      set session authorization ${harness};
      select set_config('ekwo.installing', 'on', false);
    `);
  }
}

async function keysOfCompany(): Promise<number> {
  const { n } = await one<{ n: number }>(
    db,
    `select count(*)::int as n from api_keys where company_id = $1`,
    [companyId],
  );
  return n;
}

describe('a second login role that sets ekwo.installing', () => {
  it('is who this test says it is: another login, no session, no key', async () => {
    const who = await asSecondLogin(() =>
      one<{ session_user: string; uid: string | null; key: string | null; installing: string }>(
        db,
        `select session_user::text as session_user, auth.uid()::text as uid,
                nullif(current_setting('ekwo.api_key', true), '') as key,
                current_setting('ekwo.installing', true) as installing`,
      ),
    );
    expect(who).toEqual({ session_user: 'reporting', uid: null, key: null, installing: 'on' });
  });

  it('is not the installer', async () => {
    const { installer } = await asSecondLogin(() =>
      one<{ installer: boolean }>(db, `select is_installer() as installer`),
    );
    expect(installer).toBe(false);
  });

  it('cannot issue itself a machine key carrying every capability of the company', async () => {
    // The privilege the one `SET` used to buy. `create_api_key()` is definer
    // and runs past row level security, so its guard was the only thing
    // between this role and a key it could then present as a member of the
    // company — with no person behind it and nothing on the audit trail
    // saying who.
    const before = await keysOfCompany();
    const { every } = await one<{ every: unknown }>(
      db,
      `select jsonb_agg(code order by code) as every from capabilities`,
    );
    const message = await asSecondLogin(() =>
      expectError(db, `select * from create_api_key($1, 'bi tool', $2::jsonb)`, [
        companyId,
        JSON.stringify(every),
      ]),
    );
    expect(message).toMatch(/not_allowed/);
    expect(await keysOfCompany()).toBe(before);
  });

  it('leaves the owner of the tables the installer it always was', async () => {
    // The migration runner and `ekwo init` connect as the owner, and a
    // superuser — the test harness, a local Postgres — is a member of every
    // role. Neither may lose what they had, or nothing installs.
    const { installer } = await one<{ installer: boolean }>(
      db,
      `select is_installer() as installer`,
    );
    expect(installer).toBe(true);
  });

  it('takes the owner as installer only when it asks to be one', async () => {
    await db.exec(`select set_config('ekwo.installing', '', false);`);
    try {
      const { installer } = await one<{ installer: boolean }>(
        db,
        `select is_installer() as installer`,
      );
      expect(installer).toBe(false);
    } finally {
      await db.exec(`select set_config('ekwo.installing', 'on', false);`);
    }
  });
});

describe('a person who raises a year-end flag by hand', () => {
  // A member who may post entries and may not close the year: the owner
  // preset with `year_end.close` revoked, which is how an installation hands
  // the books to somebody without handing them the close.
  beforeAll(async () => {
    await db.query(
      `update company_members set capabilities_revoked = array['year_end.close']
        where company_id = $1 and user_id = $2`,
      [companyId, ownerId],
    );
  });

  afterAll(async () => {
    await db.query(
      `update company_members set capabilities_revoked = '{}'
        where company_id = $1 and user_id = $2`,
      [companyId, ownerId],
    );
  });

  it('cannot label an entry as a closing entry', async () => {
    // A closing entry is left out of the income statement. An entry that says
    // it is one and is not takes its amounts out of the result with it.
    const journal = await one<{ id: string }>(
      db,
      `select id from journals where company_id = $1 order by code limit 1`,
      [companyId],
    );
    const year = await one<{ id: string; end_date: string }>(
      db,
      `select id, end_date::text from fiscal_years where company_id = $1 order by start_date limit 1`,
      [companyId],
    );
    const message = await asUser(db, ownerId, async () => {
      await db.exec(`select set_config('ekwo.year_end_entry', 'on', false);`);
      try {
        return await expectError(
          db,
          `insert into entries (company_id, journal_id, fiscal_year_id, entry_date,
                                description, state, kind)
           values ($1, $2, $3, $4::date, 'Not a closing entry', 'draft', 'closing')`,
          [companyId, journal.id, year.id, year.end_date],
        );
      } finally {
        await db.exec(`select set_config('ekwo.year_end_entry', '', false);`);
      }
    });
    // The words of the capability guard: the flag no longer stands in for it.
    expect(message).toMatch(/not_allowed: closing or re-opening a financial year needs year_end\.close/);
  });

  it('still records an opening balance, which needs entries.post and not the close', async () => {
    // What the guard must not take away: the function raises the flag for a
    // caller who may do what it does, and that caller is let through.
    const accounts = await db.query<{ code: string }>(
      `select code from accounts
        where company_id = $1 and carries_forward
        order by code limit 2`,
      [companyId],
    );
    const [debit, credit] = accounts.rows.map((row) => row.code);
    const year = await one<{ id: string }>(
      db,
      `select id from fiscal_years where company_id = $1 order by start_date limit 1`,
      [companyId],
    );
    const entry = await asUser(db, ownerId, () =>
      one<{ id: string }>(db, `select opening_balance($1, $2, $3::jsonb) as id`, [
        companyId,
        year.id,
        JSON.stringify([
          { account_code: debit, debit: '100.00' },
          { account_code: credit, credit: '100.00' },
        ]),
      ]),
    );
    const { kind } = await one<{ kind: string }>(db, `select kind::text from entries where id = $1`, [
      entry.id,
    ]);
    expect(kind).toBe('opening');
  });

  it('cannot move the date a year was closed on', async () => {
    // `is_closed` itself is guarded twice — the flag, and `year_end.close` on
    // the transition. `closed_at` was guarded by the flag alone.
    const year = await one<{ id: string }>(
      db,
      `select id from fiscal_years where company_id = $1 order by start_date limit 1`,
      [companyId],
    );
    const message = await asUser(db, ownerId, async () => {
      await db.exec(`select set_config('ekwo.closing_fiscal_year', 'on', false);`);
      try {
        return await expectError(
          db,
          `update fiscal_years set closed_at = now() - interval '1 year' where id = $1`,
          [year.id],
        );
      } finally {
        await db.exec(`select set_config('ekwo.closing_fiscal_year', '', false);`);
      }
    });
    expect(message).toMatch(/not_allowed: closing or re-opening a financial year needs year_end\.close/);
  });
});
