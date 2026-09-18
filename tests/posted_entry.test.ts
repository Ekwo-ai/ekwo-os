/**
 * A posted entry is immutable, in an open period too.
 *
 * The schema said so everywhere and enforced it in a locked period only. In an
 * open one, a member holding `entries.write` could delete the lines of a posted
 * entry, delete the entry, or set it back to draft — and the audit trail, which
 * records the act of posting and deliberately not the lines, kept no trace.
 *
 * Written from three seats, under row level security, in an open period: an
 * accountant, the owner, and a machine holding an API key — the third because
 * a guard that reads under the caller's policies is answered "no row" by
 * whoever cannot read, and the first version of these guards let exactly that
 * seat delete what the owner could not. As in `posted_document.test.ts`, the columns are read from the
 * catalogue and every one is tried: the only list written here is the closed
 * one of what still moves, which is what the matching writes.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { Pack } from '../packages/cli/src/index.js';
import { asUser, freshDatabase, one, rows } from './helpers/db.js';
import { accountId, newCompany, newInstanceAdmin, newUser } from './helpers/factory.js';
import { roleOf, somePack } from './helpers/packs.js';

/** The decision under test, per table. Generated columns follow from frozen ones. */
const STILL_MOVES = {
  entries: ['updated_at'],
  entry_lines: ['matching_number', 'matched_amount', 'updated_at'],
};

let db: PGlite;
const pack: Pack = somePack;
let companyId: string;
let accountant: string;
let ownerId: string;
let journalId: string;

/** Who is asking: a person with a session, or a machine with a key. */
interface Seat {
  name: string;
  user?: string;
  secret?: string;
}
const SEATS: Seat[] = [];
const SEAT_NAMES = ['an accountant', 'the owner', 'a machine holding an API key'];
const seat = (name: string): Seat => SEATS.find((each) => each.name === name) as Seat;
let receivable: string;
let sales: string;

beforeAll(async () => {
  db = await freshDatabase();
  ({ companyId, ownerId } = await newCompany(db, { country: pack.manifest.country, name: 'Ledger' }));
  await db.query(`insert into auth.users (id, email) values ($1, 'owner@entry.test') on conflict do nothing`, [ownerId]);
  accountant = await newUser(db, 'accountant@entry.test');
  await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'accountant')`, [companyId, accountant]);
  const key = await asUser(db, ownerId, () =>
    one<{ secret: string }>(db, `select * from create_api_key($1, 'Integration', $2::jsonb)`, [
      companyId,
      JSON.stringify(['entries.read', 'entries.write', 'entries.post', 'reconcile.write', 'contacts.read']),
    ]),
  );
  SEATS.push(
    { name: 'an accountant', user: accountant },
    { name: 'the owner', user: ownerId },
    { name: 'a machine holding an API key', secret: key.secret },
  );
  journalId = (await one<{ id: string }>(db, `select miscellaneous_journal_id as id from companies where id = $1`, [companyId])).id;
  receivable = await accountId(db, companyId, roleOf(pack, 'receivable'));
  sales = await accountId(db, companyId, roleOf(pack, 'sales'));
}, 180_000);

afterAll(async () => {
  await db.close();
});

/** An entry of two lines, written and — unless asked otherwise — posted by the accountant. */
async function entry(options: { post?: boolean; debit?: string; credit?: string; reverses?: string } = {}): Promise<string> {
  return asUser(db, accountant, async () => {
    const row = await one<{ id: string }>(
      db,
      `insert into entries (company_id, journal_id, entry_date, description, reversed_entry_id)
       select $1, $2, f.start_date + 30, 'By hand', $3 from fiscal_years f where f.company_id = $1
       returning id`,
      [companyId, journalId, options.reverses ?? null],
    );
    await db.query(
      `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit)
       values ($1, $2, $3, 10, 'Debit', 100, 0), ($1, $2, $4, 20, 'Credit', 0, 100)`,
      [row.id, companyId, options.debit ?? receivable, options.credit ?? sales],
    );
    if (options.post !== false) await db.query(`select post_entry($1)`, [row.id]);
    return row.id;
  });
}

const whole = async (entryId: string) => ({
  entry: await one(db, `select to_jsonb(e) - 'updated_at' as row from entries e where id = $1`, [entryId]),
  lines: await rows(db, `select to_jsonb(l) - 'updated_at' as row from entry_lines l where entry_id = $1 order by sequence`, [entryId]),
});

async function refusalOf(sql: string, params: unknown[], who: Seat = seat('an accountant')): Promise<{ code?: string; message: string } | null> {
  await db.exec('begin');
  try {
    await db.query(`select set_config('ekwo.installing', '', true), set_config('request.jwt.claims', $1, true)`, [
      who.user ? JSON.stringify({ sub: who.user, role: 'authenticated' }) : '',
    ]);
    await db.exec('set local role authenticated');
    if (who.secret) await db.query(`select * from use_api_key($1)`, [who.secret]);
    try {
      const result = await db.query(sql, params);
      // Row level security does not raise on a write it filters out: a
      // statement that reached no row proved nothing, and says so.
      if (/^\s*(update|delete)/i.test(sql) && result.affectedRows === 0) {
        return { code: 'no-row', message: `no row reached: ${who.name} cannot see or write it` };
      }
      return null;
    } catch (error) {
      const refused = error as { code?: string; message: string };
      return { code: refused.code, message: refused.message };
    }
  } finally {
    await db.exec('rollback');
  }
}

const columnsOf = (table: string) =>
  rows<{ name: string; type: string }>(
    db,
    `select column_name as name, data_type as type
       from information_schema.columns
      where table_schema = 'public' and table_name = $1 and is_generated = 'NEVER'
        and column_name not in ('id', 'company_id', 'created_at')
      order by ordinal_position`,
    [table],
  );

/** Rows to point a column at, other than the ones the entry under test points at. */
const ids = { journal: '', account: '', contact: '', tax: '', currency: '', module: '' };

/** A value of the column's type that differs from the one the row holds. */
function another(column: { name: string; type: string }, row: Record<string, unknown>, draftEntry: string): string | null {
  const held = row[column.name];
  // Found beforehand, as the installer: a value a seat cannot read is a value
  // it cannot write, and the statement would then prove nothing.
  const references: Record<string, string> = {
    entry_id: `'${draftEntry}'`,
    journal_id: `'${ids.journal}'`,
    account_id: `'${ids.account}'`,
    contact_id: `'${ids.contact}'`,
    tax_id: `'${ids.tax}'`,
    document_id: `gen_random_uuid()`,
    reversed_entry_id: `'${draftEntry}'`,
    fiscal_year_id: `null`,
    currency_code: `'${ids.currency}'`,
    state: `'draft'`,
    kind: `'opening'`,
    posting_type: `'base'`,
    module_code: `'${ids.module}'`,
  };
  void held;
  if (column.name in references) return references[column.name] as string;
  switch (column.type) {
    case 'numeric':
    case 'integer':
      return `coalesce(${column.name}, 0) + 7`;
    case 'date':
      return `coalesce(${column.name}, current_date) - 3`;
    case 'timestamp with time zone':
      return `now() - interval '1 day'`;
    case 'boolean':
      return `not ${column.name}`;
    case 'text':
      return `'changed'`;
    default:
      return null;
  }
}

describe.each(SEAT_NAMES)('a posted entry, from the seat of %s', (who) => {
  let entryId: string;
  let draftId: string;
  let before: Awaited<ReturnType<typeof whole>>;

  beforeAll(async () => {
    entryId = await entry();
    draftId = await entry({ post: false });
    const id = async (sql: string) => (await one<{ id: string }>(db, sql, [companyId])).id;
    ids.contact = await id(`insert into contacts (company_id, name) values ($1, 'Somebody') returning id`);
    ids.journal = await id(`select id from journals where company_id = $1 and id <> '${journalId}' limit 1`);
    ids.account = await id(`select id from accounts where company_id = $1 and id not in ('${receivable}', '${sales}') limit 1`);
    ids.tax = await id(`select id from taxes where company_id = $1 limit 1`);
    ids.currency = await id(`select code as id from currencies where code <> (select currency_code from companies where id = $1) order by code limit 1`);
    ids.module = await id(`select code as id from modules where $1::uuid is not null order by code limit 1`);
    before = await whole(entryId);
  });

  for (const table of ['entries', 'entry_lines'] as const) {
    it(`keeps every column of ${table} but what the closed list names`, async () => {
      const where = table === 'entries' ? `id = $1` : `entry_id = $1 and sequence = 10`;
      const row = (await one<{ row: Record<string, unknown> }>(db, `select to_jsonb(t) as row from ${table} t where ${where}`, [entryId])).row;
      const tried: string[] = [];
      for (const column of await columnsOf(table)) {
        if (STILL_MOVES[table].includes(column.name)) continue;
        const value = another(column, row, draftId);
        expect(value, `no value to try on ${table}.${column.name}: teach another() its type`).not.toBeNull();
        const refused = await refusalOf(`update ${table} set ${column.name} = ${value} where ${where}`, [entryId], seat(who));
        expect(refused, `${table}.${column.name} was rewritten on a posted entry`).not.toBeNull();
        // Older guards stand on a posted entry too — who may post, what a
        // module tag may become, which period is locked — and answer first
        // where they are the more precise. What matters is that one does, as
        // a refusal, and that nothing moved.
        expect(refused?.code, `${table}.${column.name}: ${refused?.message}`).toMatch(/^(55006|P0001|23\d{3}|42501)$/);
        tried.push(column.name);
      }
      expect(tried).toEqual(
        expect.arrayContaining(table === 'entries' ? ['entry_date', 'number', 'state', 'journal_id', 'posted_at'] : ['debit', 'credit', 'account_id', 'entry_id', 'declaration_box']),
      );
      expect(await whole(entryId)).toEqual(before);
    });
  }

  it('is refused by name where nothing older answers first', async () => {
    for (const statement of [
      `update entries set description = 'rewritten' where id = $1`,
      `update entries set state = 'draft' where id = $1`,
      `delete from entries where id = $1`,
      `update entry_lines set name = 'rewritten' where entry_id = $1`,
      `delete from entry_lines where entry_id = $1`,
      `insert into entry_lines (entry_id, company_id, account_id, sequence, debit, credit)
       select entry_id, company_id, account_id, 99, 0, 0 from entry_lines where entry_id = $1 and sequence = 10`,
    ]) {
      const refused = await refusalOf(statement, [entryId], seat(who));
      expect(refused?.code, statement).toBe('55006');
      expect(refused?.message, statement).toMatch(/^entry_posted\b.*reversal/);
    }
    expect(await whole(entryId)).toEqual(before);
  });

  it('refuses the installer what it refuses a member', async () => {
    await expect(db.query(`delete from entry_lines where entry_id = $1`, [entryId])).rejects.toThrow(/entry_posted/);
    await expect(db.query(`update entries set state = 'draft' where id = $1`, [entryId])).rejects.toThrow(/entry_posted/);
  });
});

describe('an entry that is born posted', () => {
  const born = `insert into entries (company_id, journal_id, entry_date, description, state, number, total_debit, total_credit)
     select company_id, journal_id, entry_date, 'Loaded', 'posted', $2, 100, 100 from entries where id = $1`;

  it('is refused to everybody: post_entry() never saw it', async () => {
    const model = await entry();
    // An administrator of the instance who is also the owner of the company:
    // the policy would let the row in. A machine key is never one.
    const admin = await newInstanceAdmin(db);
    await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'owner')`, [companyId, admin]);
    for (const who of [...SEATS, { name: 'an administrator of the instance', user: admin }]) {
      const refused = await refusalOf(born, [model, `BORN-${who.name}`], who);
      expect(refused, who.name).not.toBeNull();
      // `entries.post` is asked first of a seat that does not hold it; the
      // seats that do are told what the matter really is.
      expect(refused?.message, who.name).toMatch(/^(entry_born_posted|not_allowed)\b/);
    }
    expect((await refusalOf(born, [model, 'BORN-owner'], seat('the owner')))?.message).toMatch(/^entry_born_posted\b/);
    // And the connection that installed the schema.
    await expect(db.query(born, [model, 'BORN-installer'])).rejects.toThrow(/entry_born_posted/);
    await expect(
      db.query(
        `insert into entry_lines (entry_id, company_id, account_id, sequence, debit, credit)
         select entry_id, company_id, account_id, 99, 0, 0 from entry_lines where entry_id = $1 and sequence = 10`,
        [model],
      ),
    ).rejects.toThrow(/entry_posted/);
  });
});

describe('what has to keep working', () => {
  it('a draft is free, and post_entry() still posts it', async () => {
    const draft = await entry({ post: false });
    await asUser(db, accountant, async () => {
      await db.query(`update entry_lines set debit = 250 where entry_id = $1 and sequence = 10`, [draft]);
      await db.query(`update entry_lines set credit = 250 where entry_id = $1 and sequence = 20`, [draft]);
      await db.query(`update entries set description = 'Rewritten while a draft' where id = $1`, [draft]);
      await db.query(`select post_entry($1)`, [draft]);
    });
    expect(await one(db, `select state, total_debit::text from entries where id = $1`, [draft])).toEqual({ state: 'posted', total_debit: '250.00' });

    const abandoned = await entry({ post: false });
    await asUser(db, accountant, () => db.query(`delete from entries where id = $1`, [abandoned]));
    expect(await rows(db, `select 1 from entry_lines where entry_id = $1`, [abandoned])).toEqual([]);
  });

  it('a posted entry is undone by a reversal that names it, and the two are matched', async () => {
    const original = await entry();
    const reversal = await entry({ debit: sales, credit: receivable, reverses: original });
    const line = (id: string) =>
      one<{ id: string }>(db, `select id from entry_lines where entry_id = $1 and account_id = $2`, [id, receivable]).then((row) => row.id);

    // The matching writes two columns of a posted line, and that is the list.
    await asUser(db, accountant, async () => db.query(`select reconcile($1, $2)`, [await line(original), await line(reversal)]));
    const matched = await rows<{ matched_amount: string; matching_number: string | null }>(
      db,
      `select matched_amount::text, matching_number from entry_lines where entry_id in ($1, $2) and account_id = $3`,
      [original, reversal, receivable],
    );
    expect(matched.map((row) => row.matched_amount)).toEqual(['100.00', '100.00']);
    expect(matched.every((row) => row.matching_number !== null)).toBe(true);

    const net = await one<{ net: string }>(
      db,
      `select sum(debit - credit)::text as net from entry_lines where entry_id in ($1, $2) and account_id = $3`,
      [original, reversal, sales],
    );
    expect(Number(net.net)).toBe(0);
  });
});
