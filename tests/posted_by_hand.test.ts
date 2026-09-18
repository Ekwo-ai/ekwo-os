/**
 * An entry is posted by `post_entry()`, and a document by `post_document()`.
 *
 * Once posted, neither moves — and that made the way in worth a second look.
 * `update entries set state = 'posted', number = 'HAND/1'` on a balanced draft
 * went through for anybody holding `entries.post`: a number chosen by hand in a
 * country whose law forbids a hole in the sequence, no `posted_at`, no financial
 * year, no look at the period or at whether the entry has a line — and the
 * guard published the same day then froze the result for good.
 *
 * The rule is judged on facts, not on a flag: a setting that says "post_entry is
 * running" can be set by any session that can run `set_config`. What
 * `post_entry()` produces can be checked on the row it produces, so the
 * transition is held to it whoever writes it — which also means that every
 * refusal of `post_entry()` has to be a refusal by hand, and the last block
 * walks them side by side so the two cannot drift.
 *
 * Three seats, under row level security: an accountant, the owner, a machine key.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { Pack } from '../packages/cli/src/index.js';
import { asUser, expectError, freshDatabase, one } from './helpers/db.js';
import { accountId, newCompany, newContact, newDocument, newUser } from './helpers/factory.js';
import { packWhere, roleOf } from './helpers/packs.js';

interface Seat {
  name: string;
  user?: string;
  secret?: string;
}
const SEATS: Seat[] = [];
const SEAT_NAMES = ['an accountant', 'the owner', 'a machine holding an API key'];
const seat = (name: string): Seat => SEATS.find((each) => each.name === name) as Seat;

let db: PGlite;
let pack: Pack;
let companyId: string;
let ownerId: string;
let journalId: string;
let receivable: string;
let sales: string;

beforeAll(async () => {
  // A country whose law forbids a hole in the sequence: that is where a number
  // chosen by hand is a breach and not a preference.
  pack = packWhere('numbers without a hole', (p) => p.documents.numbering_gapless === true);
  db = await freshDatabase();
  ({ companyId, ownerId } = await newCompany(db, { country: pack.manifest.country, name: 'By hand' }));
  await db.query(`insert into auth.users (id, email) values ($1, 'owner@hand.test') on conflict do nothing`, [ownerId]);
  const accountant = await newUser(db, 'accountant@hand.test');
  await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'accountant')`, [companyId, accountant]);
  const key = await asUser(db, ownerId, () =>
    one<{ secret: string }>(db, `select * from create_api_key($1, 'Integration', $2::jsonb)`, [
      companyId,
      JSON.stringify(['entries.read', 'entries.write', 'entries.post', 'documents.read', 'documents.write', 'documents.post']),
    ]),
  );
  SEATS.push({ name: 'an accountant', user: accountant }, { name: 'the owner', user: ownerId }, { name: 'a machine holding an API key', secret: key.secret });
  journalId = (await one<{ id: string }>(db, `select miscellaneous_journal_id as id from companies where id = $1`, [companyId])).id;
  receivable = await accountId(db, companyId, roleOf(pack, 'receivable'));
  sales = await accountId(db, companyId, roleOf(pack, 'sales'));
}, 180_000);

afterAll(async () => {
  await db.close();
});

/** A balanced draft of two lines, or an empty one. */
async function draft(lines = true, date = `f.start_date + 30`): Promise<string> {
  const row = await one<{ id: string }>(
    db,
    `insert into entries (company_id, journal_id, entry_date, description)
     select $1, $2, ${date}, 'By hand' from fiscal_years f where f.company_id = $1 order by f.start_date limit 1 returning id`,
    [companyId, journalId],
  );
  if (lines) {
    await db.query(
      `insert into entry_lines (entry_id, company_id, account_id, sequence, debit, credit)
       values ($1, $2, $3, 10, 100, 0), ($1, $2, $4, 20, 0, 100)`,
      [row.id, companyId, receivable, sales],
    );
  }
  return row.id;
}

/** Run a statement from a seat in a transaction that is then undone; the refusal, or null. */
async function refusalOf(sql: string, params: unknown[], who: Seat): Promise<{ code?: string; message: string } | null> {
  await db.exec('begin');
  try {
    await db.query(`select set_config('ekwo.installing', '', true), set_config('request.jwt.claims', $1, true)`, [
      who.user ? JSON.stringify({ sub: who.user, role: 'authenticated' }) : '',
    ]);
    await db.exec('set local role authenticated');
    if (who.secret) await db.query(`select * from use_api_key($1)`, [who.secret]);
    try {
      const result = await db.query(sql, params);
      if (/^\s*update/i.test(sql) && result.affectedRows === 0) return { code: 'no-row', message: `no row reached by ${who.name}` };
      return null;
    } catch (error) {
      const refused = error as { code?: string; message: string };
      return { code: refused.code, message: refused.message };
    }
  } finally {
    await db.exec('rollback');
  }
}

/** Everything `post_entry()` writes, written by hand instead. */
const BY_HAND = {
  bare: `update entries set state = 'posted', number = 'HAND/1' where id = $1`,
  dressed: `update entries set state = 'posted', number = 'HAND/1', posted_at = now(),
                   fiscal_year_id = fiscal_year_at(company_id, entry_date) where id = $1`,
  drawn: `update entries set state = 'posted', number = next_entry_number(journal_id, entry_date), posted_at = now(),
                 fiscal_year_id = fiscal_year_at(company_id, entry_date) where id = $1`,
};

describe.each(SEAT_NAMES)('posting an entry by hand, from the seat of %s', (who) => {
  it('is refused with a number chosen by hand, however the rest of the row is dressed', async () => {
    const id = await draft();
    for (const [how, statement] of Object.entries({ bare: BY_HAND.bare, dressed: BY_HAND.dressed })) {
      const refused = await refusalOf(statement, [id], seat(who));
      expect(refused?.code, how).toBe('55006');
      expect(refused?.message, how).toMatch(/^entry_posted_by_hand\b/);
    }
    expect(await one(db, `select state, number from entries where id = $1`, [id])).toEqual({ state: 'draft', number: null });
  });

  it('is refused without the instant it was posted at, and in a financial year that is not its own', async () => {
    const id = await draft();
    const elsewhere = await one<{ id: string }>(
      db,
      `insert into fiscal_years (company_id, name, start_date, end_date)
       select company_id, 'Another year', end_date + 1, end_date + 365 from fiscal_years where company_id = $1
       on conflict do nothing returning id`,
      [companyId],
    ).catch(() => one<{ id: string }>(db, `select id from fiscal_years where company_id = $1 and name = 'Another year'`, [companyId]));
    for (const statement of [
      `update entries set state = 'posted', number = next_entry_number(journal_id, entry_date),
              fiscal_year_id = fiscal_year_at(company_id, entry_date) where id = $1`,
      `update entries set state = 'posted', number = next_entry_number(journal_id, entry_date), posted_at = now(),
              fiscal_year_id = '${elsewhere.id}' where id = $1`,
    ]) {
      const refused = await refusalOf(statement, [id], seat(who));
      expect(refused?.code, statement).toBe('55006');
      expect(refused?.message, statement).toMatch(/^entry_posted_by_hand\b/);
    }
  });

  it('goes through when it is, fact for fact, what post_entry() would have written', async () => {
    // Not a door left open: nothing distinguishes this row from the one the
    // function writes, the number was drawn from the counter, and every check
    // below was passed. A rule about facts cannot refuse the facts.
    const id = await draft();
    expect(await refusalOf(BY_HAND.drawn, [id], seat(who))).toBeNull();
  });
});

describe('every refusal of post_entry() is a refusal by hand', () => {
  const cases: [string, () => Promise<string>, RegExp][] = [
    ['an entry with no line', () => draft(false), /entry_empty/],
    ['an entry dated in a locked period', async () => {
      const id = await draft(true, `f.start_date + 3`);
      await db.query(`update companies set lock_date = (select start_date + 10 from fiscal_years where company_id = $1 order by start_date limit 1) where id = $1`, [companyId]);
      return id;
    }, /period_locked/],
  ];

  it.each(cases)('%s', async (_what, arrange, name) => {
    const id = await arrange();
    try {
      for (const who of SEATS) {
        const byFunction = await refusalOf(`select post_entry($1)`, [id], who);
        const byHand = await refusalOf(BY_HAND.drawn, [id], who);
        expect(byFunction?.message, `${who.name}, post_entry()`).toMatch(name);
        expect(byHand?.message, `${who.name}, by hand`).toMatch(name);
      }
    } finally {
      await db.query(`update companies set lock_date = null where id = $1`, [companyId]);
    }
  });

  it('and post_entry() itself still posts, numbers from the counter, and is not slowed by any of this', async () => {
    const id = await draft();
    await asUser(db, seat('an accountant').user as string, () => db.query(`select post_entry($1)`, [id]));
    const row = await one<{ state: string; number: string; posted_at: string | null; fiscal_year_id: string | null }>(
      db,
      `select state, number, posted_at::text, fiscal_year_id from entries where id = $1`,
      [id],
    );
    expect(row.state).toBe('posted');
    expect(row.posted_at).not.toBeNull();
    expect(row.fiscal_year_id).not.toBeNull();
  });
});

describe('posting a document by hand', () => {
  it('is refused on an entry that is posted and is not the one it produced', async () => {
    const contact = await newContact(db, companyId, { country: pack.manifest.country });
    const documentId = await newDocument(db, companyId, {
      docType: 'sale_invoice',
      contactId: contact,
      lines: [{ unitPrice: 100, taxCode: null, accountCode: roleOf(pack, 'sales') }],
    });
    // A legitimately posted entry that belongs to no document.
    const keyed = await draft();
    await db.query(`select post_entry($1)`, [keyed]);
    for (const who of SEATS) {
      const refused = await refusalOf(
        `update documents set state = 'posted', number = 'HAND-DOC-1', entry_id = $2, accounting_date = document_date where id = $1`,
        [documentId, keyed],
        who,
      );
      expect(refused?.code, who.name).toBe('55006');
      expect(refused?.message, who.name).toMatch(/^document_posted_by_hand\b/);
    }
    // And post_document() still does what it did.
    await asUser(db, ownerId, () => db.query(`select post_document($1)`, [documentId]));
    expect(await expectError(db, `update documents set note = 'x' where id = $1`, [documentId])).toMatch(/document_posted/);
  });
});
