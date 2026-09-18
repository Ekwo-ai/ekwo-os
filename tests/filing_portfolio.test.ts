import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, newInstanceAdmin, newUser } from './helpers/factory.js';
import { allPacks, packWhere } from './helpers/packs.js';

/**
 * Every company somebody keeps, read at once.
 *
 * `upcoming_filings()` and `filings_touched_since()` answer for one company. A
 * firm that keeps forty asks the question forty times, or asks it once here.
 * What is proved, as the people concerned and under row level security:
 *
 *   1. the portfolio is what the caller may read and nothing else — the
 *      accountant of two companies gets two, the client of one gets one, and
 *      the third company of the installation does not exist for either;
 *   2. it is `filings.read` that decides, not membership: take the capability
 *      away from a member and the company leaves their portfolio;
 *   3. a company is never left out for having nothing to say — a pack that
 *      names no deadline, a window nothing falls due in, an installation that
 *      carries no form for it: each is a row that says which;
 *   4. the administrator of the instance, who creates the companies and keeps
 *      none of their books, reads none of their declarations;
 *   5. an entry posted into a declared period is reported with the company
 *      named, and only to whoever may read that company.
 */

const dated = packWhere(
  'names the day its periodic return is due',
  (p) => p.report !== null && p.report.deadline !== null && p.golden !== null,
);
const undated = packWhere(
  'files a periodic return and names no day for it',
  (p) => p.report !== null && p.report.deadline === null,
);
const third = packWhere(
  'files a periodic return, and is neither of the two above',
  (p) => p.report !== null && p.slug !== dated.slug && p.slug !== undated.slug,
);

function goldenLine(): { tax: string; account: string } {
  for (const document of dated.golden?.documents ?? []) {
    if (document.type !== 'sale_invoice') continue;
    for (const line of document.lines) {
      if (line.tax && line.account) return { tax: line.tax, account: line.account };
    }
  }
  throw new Error(`${dated.slug} has no sale invoice with a tax in its golden`);
}
const SALE = goldenLine();

const PERIODS: Record<string, [string, string]> = {
  month: ['2026-01-01', '2026-01-31'],
  quarter: ['2026-01-01', '2026-03-31'],
  year: ['2026-01-01', '2026-12-31'],
};
const [FROM, TO] = PERIODS[dated.report?.period_default ?? 'month'] ?? PERIODS['month']!;

interface Upcoming {
  company_id: string;
  company_name: string;
  report_code: string | null;
  period_start: string | Date | null;
  period_end: string | Date | null;
  due_date: string | Date | null;
  state: string | null;
  filing_id: string | null;
  reason: string | null;
}

interface Touched {
  company_id: string;
  company_name: string;
  filed: number;
  filing_id: string | null;
  report_code: string | null;
  entries: number | null;
  boxes_moved: number | null;
}

function day(value: string | Date | null): string | null {
  if (value === null) return null;
  return value instanceof Date ? value.toISOString().slice(0, 10) : value;
}

function shift(date: string, days: number): string {
  return new Date(new Date(date).getTime() + days * 86_400_000).toISOString().slice(0, 10);
}

let db: PGlite;
let accountantId: string;
let clientId: string;
let adminId: string;
let strangerId: string;
let datedCo: string;
let undatedCo: string;
let thirdCo: string;
let due: string;
let filingId: string;
let thirdFilingId: string;

const NAMES = { dated: 'Atelier Halvard', undated: 'Comptoir Merrin', third: 'Forge Oswin' };

async function upcomingAs(userId: string, from: string, to: string): Promise<Upcoming[]> {
  return asUser(db, userId, () =>
    rows<Upcoming>(db, `select * from portfolio_upcoming_filings($1::date, $2::date)`, [from, to]),
  );
}

async function touchedAs(userId: string): Promise<Touched[]> {
  return asUser(db, userId, () =>
    rows<Touched>(db, `select * from portfolio_filings_touched_since()`),
  );
}

async function invoice(companyId: string, contactId: string, number: string, pack = dated) {
  let line = SALE;
  if (pack !== dated) {
    const found = (pack.golden?.documents ?? [])
      .filter((d) => d.type === 'sale_invoice')
      .flatMap((d) => d.lines)
      .find((l) => l.tax && l.account);
    if (!found) throw new Error(`${pack.slug} has no sale invoice with a tax in its golden`);
    line = { tax: found.tax!, account: found.account! };
  }
  const documentId = await newDocument(db, companyId, {
    docType: 'sale_invoice',
    number,
    contactId,
    date: FROM,
    lines: [{ unitPrice: 1_000, taxCode: line.tax, accountCode: line.account }],
  });
  await db.query(`select post_document($1)`, [documentId]);
}

/** Books a sale, files the period, then books another into it. */
async function fileThenDisturb(companyId: string, pack = dated): Promise<string> {
  const contactId = await newContact(db, companyId, {
    name: 'Customer',
    country: pack.manifest.country,
  });
  const cadence = pack.report?.period_default ?? 'month';
  const [from, to] = PERIODS[cadence] ?? PERIODS['month']!;
  await invoice(companyId, contactId, 'PF-1', pack);
  const prepared = await one<{ id: string }>(
    db,
    `select id from prepare_filing($1, $2::date, $3::date)`,
    [companyId, from, to],
  );
  await db.query(`select file_filing($1, 'DEP-1')`, [prepared.id]);
  await invoice(companyId, contactId, 'PF-2', pack);
  return prepared.id;
}

beforeAll(async () => {
  db = await freshDatabase();
  accountantId = await newUser(db);
  clientId = await newUser(db);
  strangerId = await newUser(db);
  adminId = await newInstanceAdmin(db);

  // country-literal: three packs picked by what they declare about their
  // deadline, so that three companies of one portfolio owe on three calendars.
  datedCo = (await newCompany(db, { country: dated.manifest.country, name: NAMES.dated, chart: dated.golden?.chart ?? null })).companyId;
  undatedCo = (await newCompany(db, { country: undated.manifest.country, name: NAMES.undated })).companyId;
  thirdCo = (await newCompany(db, { country: third.manifest.country, name: NAMES.third, chart: third.golden?.chart ?? null })).companyId;

  for (const companyId of [datedCo, undatedCo]) {
    await db.query(
      `insert into company_members (company_id, user_id, role) values ($1, $2, 'accountant')`,
      [companyId, accountantId],
    );
  }
  await db.query(
    `insert into company_members (company_id, user_id, role) values ($1, $2, 'client')`,
    [datedCo, clientId],
  );

  const deadline = await one<{ due: string | Date }>(
    db,
    `select filing_deadline($1, periodic_return_code($1), $2::date) as due`,
    [datedCo, TO],
  );
  due = day(deadline.due)!;

  filingId = await fileThenDisturb(datedCo);
  thirdFilingId = await fileThenDisturb(thirdCo, third);
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('the three packs of this file', () => {
  it('are three, which is what makes the calendars differ', () => {
    expect(new Set([dated.slug, undated.slug, third.slug]).size).toBe(3);
    expect(allPacks.length).toBeGreaterThanOrEqual(3);
  });
});

describe('what is due, across the companies somebody may read', () => {
  it('gives the accountant of two companies exactly those two', async () => {
    const coming = await upcomingAs(accountantId, shift(due, -5), shift(due, 5));
    expect([...new Set(coming.map((c) => c.company_id))].sort()).toEqual(
      [datedCo, undatedCo].sort(),
    );
    expect(coming.map((c) => c.company_name)).not.toContain(NAMES.third);

    const mine = coming.filter((c) => c.company_id === datedCo && c.report_code !== null);
    expect(mine.length).toBeGreaterThan(0);
    const filed = mine.find((c) => day(c.period_end) === TO);
    expect(day(filed!.due_date)).toBe(due);
    expect(filed!.filing_id).toBe(filingId);
    expect(filed!.state).toBe('filed');
    expect(filed!.reason).toBeNull();
    // The window is on the day it is due, not on the period: nothing listed
    // with a date falls outside it.
    for (const row of coming.filter((c) => c.due_date !== null)) {
      expect(day(row.due_date)! >= shift(due, -5)).toBe(true);
      expect(day(row.due_date)! <= shift(due, 5)).toBe(true);
    }
  });

  it('gives the client of one company that one', async () => {
    const coming = await upcomingAs(clientId, shift(due, -5), shift(due, 5));
    expect([...new Set(coming.map((c) => c.company_id))]).toEqual([datedCo]);
  });

  it('gives somebody who belongs nowhere nothing at all', async () => {
    expect(await upcomingAs(strangerId, '2026-01-01', '2026-12-31')).toEqual([]);
  });

  it('lists a company whose pack names no deadline, and says that is why there is no date', async () => {
    const year = await upcomingAs(accountantId, '2026-01-01', '2026-12-31');
    const silent = year.filter((c) => c.company_id === undatedCo);
    expect(silent.length).toBeGreaterThan(0);
    for (const row of silent) {
      expect(row.company_name).toBe(NAMES.undated);
      expect(row.report_code).not.toBeNull();
      expect(row.period_end).not.toBeNull();
      expect(row.due_date).toBeNull();
      expect(row.reason).toBe('no_deadline_rule');
    }
  });

  it('lists a company nothing falls due for, and says so', async () => {
    // One day, the day after the return was due: the accountant still hears
    // about both companies.
    const after = await upcomingAs(accountantId, shift(due, 1), shift(due, 1));
    const quiet = after.filter((c) => c.company_id === datedCo);
    expect(quiet).toHaveLength(1);
    expect(quiet[0]!.report_code).toBeNull();
    expect(quiet[0]!.due_date).toBeNull();
    expect(quiet[0]!.reason).toBe('nothing_due');
    expect(after.some((c) => c.company_id === undatedCo)).toBe(true);
  });

  it('follows filings.read and not membership', async () => {
    await db.query(
      `update company_members set capabilities_revoked = array['filings.read']
        where company_id = $1 and user_id = $2`,
      [undatedCo, accountantId],
    );
    try {
      const coming = await upcomingAs(accountantId, '2026-01-01', '2026-12-31');
      expect([...new Set(coming.map((c) => c.company_id))]).toEqual([datedCo]);
      const moved = await touchedAs(accountantId);
      expect([...new Set(moved.map((c) => c.company_id))]).toEqual([datedCo]);
    } finally {
      await db.query(
        `update company_members set capabilities_revoked = '{}'
          where company_id = $1 and user_id = $2`,
        [undatedCo, accountantId],
      );
    }
  });

  it('does not count the administrator of the instance as a reader of anybody', async () => {
    // They see that the companies exist — they created them — and the schema
    // gives them no declaration to read: `tax_filings` asks for filings.read.
    const visible = await asUser(db, adminId, () =>
      rows<{ id: string }>(db, `select id from companies where id = any($1::uuid[])`, [
        [datedCo, undatedCo, thirdCo],
      ]),
    );
    expect(visible).toHaveLength(3);
    const filings = await asUser(db, adminId, () => rows(db, `select id from tax_filings`));
    expect(filings).toEqual([]);

    expect(await upcomingAs(adminId, '2026-01-01', '2026-12-31')).toEqual([]);
    expect(await touchedAs(adminId)).toEqual([]);
  });
});

describe('the rows that carry no date', () => {
  it('lists an undated period while the month after it overlaps the window, and not before or after', async () => {
    const cadence = undated.report?.period_default ?? 'month';
    const [, end] = PERIODS[cadence] ?? PERIODS['month']!;
    const nextMonthStart = shift(end, 1);
    const inside = await upcomingAs(accountantId, nextMonthStart, shift(nextMonthStart, 3));
    expect(
      inside.some((c) => c.company_id === undatedCo && day(c.period_end) === end && c.reason === 'no_deadline_rule'),
    ).toBe(true);

    // Before the period has ended there is nothing to declare yet.
    const before = await upcomingAs(accountantId, shift(end, -3), end);
    expect(before.some((c) => c.company_id === undatedCo && day(c.period_end) === end)).toBe(false);
    // And two months later the closed vocabulary has no date left to give it.
    const later = await upcomingAs(accountantId, shift(end, 70), shift(end, 75));
    expect(later.some((c) => c.company_id === undatedCo && day(c.period_end) === end)).toBe(false);
  });

  it('says of a company the installation carries no return for that there is no form', async () => {
    // A fiscal country no pack of this installation covers: the two letters
    // are taken from outside the packs rather than written here.
    const covered = new Set(allPacks.map((p) => p.manifest.country));
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    let elsewhere = '';
    for (const a of letters) {
      for (const b of letters) {
        if (elsewhere === '' && !covered.has(a + b)) elsewhere = a + b;
      }
    }
    const { companyId } = await newCompany(db, {
      country: undated.manifest.country,
      name: 'Maison Peregrin',
    });
    await db.query(`delete from company_filing_periods where company_id = $1`, [companyId]);
    await db.query(`update companies set fiscal_country = $2 where id = $1`, [companyId, elsewhere]);
    await db.query(
      `insert into company_members (company_id, user_id, role) values ($1, $2, 'accountant')`,
      [companyId, accountantId],
    );
    try {
      const coming = await upcomingAs(accountantId, '2026-01-01', '2026-12-31');
      const formless = coming.filter((c) => c.company_id === companyId);
      expect(formless).toHaveLength(1);
      expect(formless[0]!.report_code).toBeNull();
      expect(formless[0]!.reason).toBe('no_form');
    } finally {
      await db.query(`delete from company_members where company_id = $1 and user_id = $2`, [
        companyId,
        accountantId,
      ]);
    }
  });
});

describe('a machine key', () => {
  it('has no portfolio, because the company row is closed to it', async () => {
    const owner = await one<{ user_id: string }>(
      db,
      `select user_id from company_members where company_id = $1 and role = 'owner'`,
      [thirdCo],
    );
    await db.query(`insert into auth.users (id, email) values ($1, $2) on conflict do nothing`, [
      owner.user_id,
      `${owner.user_id}@example.test`,
    ]);
    const key = await asUser(db, owner.user_id, () =>
      one<{ secret: string }>(
        db,
        `select * from create_api_key($1, 'Calendar reader', $2::jsonb, null::timestamptz)`,
        [thirdCo, JSON.stringify(['filings.read', 'entries.read'])],
      ),
    );

    await db.exec(`set role authenticated;`);
    await db.query(`begin`);
    let coming: Upcoming[];
    let moved: Touched[];
    try {
      await db.query(`select * from use_api_key($1)`, [key.secret]);
      coming = await rows<Upcoming>(
        db,
        `select * from portfolio_upcoming_filings('2026-01-01'::date, '2026-12-31'::date)`,
      );
      moved = await rows<Touched>(db, `select * from portfolio_filings_touched_since()`);
    } finally {
      await db.query(`commit`);
      await db.exec(`reset role;`);
      await db.exec(`select set_config('ekwo.installing', 'on', false);`);
    }
    // Stated on 13 September 2026 and not changed here: a key is not a
    // session, and the policies that ask for a member rather than for a
    // capability — the company row among them — stay closed to it. So a key
    // holding filings.read reads the declarations of its company and cannot
    // be told which company that is; its portfolio is empty rather than wrong.
    expect(coming).toEqual([]);
    expect(moved).toEqual([]);
  });
});

describe('what moved after it went, across the same companies', () => {
  it('names the company an entry landed in', async () => {
    const moved = await touchedAs(accountantId);
    const hit = moved.filter((m) => m.filing_id !== null);
    expect(hit).toHaveLength(1);
    expect(hit[0]!.company_id).toBe(datedCo);
    expect(hit[0]!.company_name).toBe(NAMES.dated);
    expect(hit[0]!.filing_id).toBe(filingId);
    expect(hit[0]!.entries).toBe(1);
    expect(hit[0]!.boxes_moved).toBeGreaterThan(0);
    expect(hit[0]!.filed).toBe(1);
  });

  it('says of a company nothing moved in that it was looked at', async () => {
    const moved = await touchedAs(accountantId);
    const quiet = moved.filter((m) => m.company_id === undatedCo);
    expect(quiet).toHaveLength(1);
    expect(quiet[0]!.company_name).toBe(NAMES.undated);
    expect(quiet[0]!.filed).toBe(0);
    expect(quiet[0]!.filing_id).toBeNull();
    expect(quiet[0]!.entries).toBeNull();
  });

  it('never reports the third company, which was disturbed too', async () => {
    // The disturbance is real: whoever owns the books sees it.
    const theirs = await rows<{ filing_id: string }>(
      db,
      `select filing_id from filings_touched_since($1)`,
      [thirdCo],
    );
    expect(theirs.map((t) => t.filing_id)).toEqual([thirdFilingId]);

    for (const userId of [accountantId, clientId, strangerId]) {
      const moved = await touchedAs(userId);
      expect(moved.map((m) => m.company_id)).not.toContain(thirdCo);
      expect(moved.map((m) => m.filing_id)).not.toContain(thirdFilingId);
    }
  });

  it('shows the client the disturbance in their own books', async () => {
    const moved = await touchedAs(clientId);
    expect(moved).toHaveLength(1);
    expect(moved[0]!.filing_id).toBe(filingId);
  });
});
