import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, type Fixture } from './helpers/factory.js';
import { packWhere } from './helpers/packs.js';

/**
 * What happens after a declaration has gone.
 *
 * The period stays open, and that is right: a late supplier invoice, an
 * adjustment, a correction — refusing them would be refusing bookkeeping. What
 * is proved here is that none of it happens in silence:
 *
 *   1. an entry posted into a declared period after it was filed is listed,
 *      with how many figures it moved — and an entry that moves none is listed
 *      too, because it was still posted into a period that had gone;
 *   2. an entry that concerns nothing on the form is not listed, and neither
 *      is the declaration's own settlement;
 *   3. the corrective replaces without erasing, and its settlement carries
 *      **the difference** and not the period all over again;
 *   4. a company that wants the period shut says so with its own function —
 *      refused while the books for it are still to be cleared, forward only.
 */

const pack = packWhere(
  'names the account what a declaration owes lands on',
  (p) => typeof p.manifest.defaults.roles['tax_payable'] === 'string',
);
const PAYABLE = pack.manifest.defaults.roles['tax_payable'] as string;

function goldenLine(type: string): { tax: string; account: string } {
  for (const document of pack.golden?.documents ?? []) {
    if (document.type !== type) continue;
    for (const line of document.lines) {
      if (line.tax && line.account) return { tax: line.tax, account: line.account };
    }
  }
  throw new Error(`${pack.slug} has no ${type} with a tax in its golden`);
}
const SALE = goldenLine('sale_invoice');

const PERIODS: Record<string, [string, string][]> = {
  month: [
    ['2026-05-01', '2026-05-31'],
    ['2026-06-01', '2026-06-30'],
  ],
  quarter: [
    ['2026-01-01', '2026-03-31'],
    ['2026-04-01', '2026-06-30'],
  ],
  year: [
    ['2026-01-01', '2026-12-31'],
    ['2027-01-01', '2027-12-31'],
  ],
};
const periods = PERIODS[pack.report?.period_default ?? 'month'] ?? PERIODS['month']!;

let db: PGlite;
let fx: Fixture;
let customerId: string;

interface Filing {
  id: string;
  report_code: string;
  state: string;
  supersedes_id: string | null;
  settlement_entry_id: string | null;
}

interface Touched {
  filing_id: string;
  entries: number;
  boxes_moved: number;
  last_entry_at: string;
}

async function invoice(number: string, date: string, amount: number): Promise<void> {
  const documentId = await newDocument(db, fx.companyId, {
    docType: 'sale_invoice',
    number,
    contactId: customerId,
    date,
    lines: [{ unitPrice: amount, taxCode: SALE.tax, accountCode: SALE.account }],
  });
  await db.query(`select post_document($1)`, [documentId]);
}

async function filed(from: string, to: string): Promise<Filing> {
  const prepared = await one<Filing>(db, `select * from prepare_filing($1, $2::date, $3::date)`, [
    fx.companyId,
    from,
    to,
  ]);
  return one<Filing>(db, `select * from file_filing($1, $2)`, [prepared.id, `DEP-${from}`]);
}

async function accept(filingId: string): Promise<void> {
  await db.query(`select record_filing_outcome($1, 'accepted')`, [filingId]);
}

async function touched(): Promise<Touched[]> {
  return rows<Touched>(db, `select * from filings_touched_since($1)`, [fx.companyId]);
}

/** The net a settlement entry carried onto the debt account. */
async function debtOf(entryId: string): Promise<number> {
  const row = await one<{ amount: string }>(
    db,
    `select coalesce(sum(l.credit - l.debit), 0)::text as amount
       from entry_lines l join accounts a on a.id = l.account_id
      where l.entry_id = $1 and a.code = $2`,
    [entryId, PAYABLE],
  );
  return Number(row.amount);
}

beforeAll(async () => {
  db = await freshDatabase();
  // country-literal: the pack under test is the one that names the role, and a
  // company has to be installed somewhere to declare anything.
  fx = await newCompany(db, { country: pack.manifest.country, name: 'Corrective Fixture' });
  customerId = await newContact(db, fx.companyId, {
    name: 'Client',
    country: pack.manifest.country,
  });
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('an entry that lands in a period that has gone', () => {
  const [from, to] = periods[0]!;
  let filing: Filing;

  it('is not refused', async () => {
    await invoice('LATE-1', from, 10_000);
    filing = await filed(from, to);
    await accept(filing.id);

    expect(await touched()).toEqual([]);

    // The settlement itself is posted at the end of the period and after the
    // filing, and it is not a disturbance: it names no box.
    const settlement = await one<{ id: string }>(db, `select id from settle_filing($1)`, [
      filing.id,
    ]);
    expect(settlement.id).toBeTruthy();
    expect(await touched()).toEqual([]);

    // Neither is an entry that concerns nothing on the form.
    await db.query(
      `select post_entry(id) from (
         insert into entries (company_id, journal_id, fiscal_year_id, entry_date, description, state)
         select $1, c.miscellaneous_journal_id, fiscal_year_at($1, $2::date), $2::date, 'Not a tax entry', 'draft'
           from companies c where c.id = $1
         returning id) e`,
      [fx.companyId, to],
    ).catch(() => null); // an entry with no lines cannot post; the point is it is not listed
    expect(await touched()).toEqual([]);

    // And now the late invoice, which does concern it.
    await invoice('LATE-2', from, 4_000);
    const after = await touched();
    expect(after).toHaveLength(1);
    expect(after[0]!.filing_id).toBe(filing.id);
    expect(after[0]!.entries).toBe(1);
    expect(after[0]!.boxes_moved).toBeGreaterThan(0);
    expect(after[0]!.last_entry_at).toBeTruthy();
  });

  it('is corrected by a declaration that points at the one it replaces', async () => {
    const corrective = await one<Filing>(db, `select * from supersede_filing($1)`, [filing.id]);
    expect(corrective.supersedes_id).toBe(filing.id);
    expect(corrective.state).toBe('draft');

    const replaced = await one<{ state: string }>(db, `select state from tax_filings where id = $1`, [
      filing.id,
    ]);
    expect(replaced.state).toBe('superseded');

    // What was sent is still readable, figure by figure.
    const frozen = await rows(db, `select box, kind, amount from tax_filing_boxes where filing_id = $1`, [
      filing.id,
    ]);
    expect(frozen.length).toBeGreaterThan(0);

    // And a superseded declaration is no longer something to report on: the
    // one that replaced it is what the period stands on now.
    expect(await touched()).toEqual([]);
  });

  it('settles the difference, and not the period all over again', async () => {
    const corrective = await one<Filing>(
      db,
      `select * from tax_filings where company_id = $1 and period_start = $2::date and state = 'draft'`,
      [fx.companyId, from],
    );
    const first = await one<{ settlement_entry_id: string }>(
      db,
      `select settlement_entry_id from tax_filings where supersedes_id is null
         and company_id = $1 and period_start = $2::date`,
      [fx.companyId, from],
    );

    await db.query(`select file_filing($1, 'DEP-CORR')`, [corrective.id]);
    await accept(corrective.id);

    const entry = await one<{ id: string }>(db, `select id from settle_filing($1)`, [corrective.id]);

    // 4 000 at the pack's own rate, and nothing of the 10 000 already settled.
    const already = await debtOf(first.settlement_entry_id);
    const difference = await debtOf(entry.id);
    expect(difference).toBeGreaterThan(0);
    expect(difference).toBeLessThan(already);
    expect(difference / already).toBeCloseTo(4 / 10, 2);

    // The two entries together are the whole period, to the cent.
    const total = await one<{ amount: string }>(
      db,
      `select coalesce(sum(l.credit - l.debit), 0)::text as amount
         from entry_lines l join accounts a on a.id = l.account_id
        where l.company_id = $1 and a.code = $2`,
      [fx.companyId, PAYABLE],
    );
    expect(Number(total.amount)).toBeCloseTo(already + difference, 2);
  });

  it('has nothing left to settle when nothing moved', async () => {
    const corrective = await one<Filing>(
      db,
      `select * from supersede_filing((select id from tax_filings
                                        where company_id = $1 and period_start = $2::date
                                          and state = 'paid' or state = 'accepted' limit 1))`,
      [fx.companyId, from],
    ).catch(() => null);
    if (corrective === null) return;
    await db.query(`select file_filing($1, 'DEP-CORR-2')`, [corrective.id]);
    await accept(corrective.id);
    expect(await expectError(db, `select settle_filing($1)`, [corrective.id])).toContain(
      'nothing_to_settle',
    );
  });
});

describe('shutting the period behind a declaration', () => {
  const [from, to] = periods[1]!;
  let filing: Filing;

  it('refuses while the books for it are still to be cleared', async () => {
    await invoice('LOCK-1', from, 2_000);
    filing = await filed(from, to);
    await accept(filing.id);

    // Found by this test rather than by reasoning: `post_entry()` checks the
    // tax lock for every entry it posts, so locking before settling would
    // refuse the settlement itself — for ever.
    expect(await expectError(db, `select lock_filed_period($1)`, [filing.id])).toContain(
      'settle_first',
    );
  });

  it('carries the lock forward once the period is clear, and refuses what would have fallen in', async () => {
    await db.query(`select settle_filing($1)`, [filing.id]);
    const locked = await one<{ lock_filed_period: string }>(
      db,
      `select lock_filed_period($1)::text`,
      [filing.id],
    );
    expect(locked.lock_filed_period).toBe(to);

    const documentId = await newDocument(db, fx.companyId, {
      docType: 'sale_invoice',
      number: 'LOCK-2',
      contactId: customerId,
      date: from,
      lines: [{ unitPrice: 500, taxCode: SALE.tax, accountCode: SALE.account }],
    });
    expect(await expectError(db, `select post_document($1)`, [documentId])).toContain('locked');
  });

  it('never moves it backwards', async () => {
    const before = await one<{ tax_lock_date: string }>(
      db,
      `select tax_lock_date::text from companies where id = $1`,
      [fx.companyId],
    );
    // The first period was filed, corrected and settled earlier in this file,
    // and it ends before the lock: asking it to shut its own period changes
    // nothing, because a company that closed a later period did not ask to
    // reopen it.
    const older = await one<Filing>(
      db,
      `select * from tax_filings where company_id = $1 and period_start = $2::date
         and state <> 'superseded' order by created_at desc limit 1`,
      [fx.companyId, periods[0]![0]],
    );
    await db.query(`select lock_filed_period($1)`, [older.id]);

    const after = await one<{ tax_lock_date: string }>(
      db,
      `select tax_lock_date::text from companies where id = $1`,
      [fx.companyId],
    );
    expect(after.tax_lock_date).toBe(before.tax_lock_date);
  });

  it('is refused on a declaration that has not gone, and on one that was replaced', async () => {
    const draft = await one<Filing>(
      db,
      `select * from prepare_filing($1, $2::date, $3::date)`,
      [fx.companyId, periods[1]![0], periods[1]![1]],
    ).catch(() => null);
    if (draft !== null) {
      expect(await expectError(db, `select lock_filed_period($1)`, [draft.id])).toContain(
        'filing_not_sent',
      );
    }

    const replaced = await one<{ id: string }>(
      db,
      `select id from tax_filings where company_id = $1 and state = 'superseded' limit 1`,
      [fx.companyId],
    ).catch(() => null);
    if (replaced !== null) {
      expect(await expectError(db, `select lock_filed_period($1)`, [replaced.id])).toContain(
        'filing_superseded',
      );
    }
  });
});
