import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, repoRoot, withoutTrigger } from './helpers/db.js';
import { newCompany, newContact, newDocument, newUser, type Fixture } from './helpers/factory.js';
import { packWhere } from './helpers/packs.js';

/**
 * What came after the cycle of `20261023124650`:
 *
 *   1. `20261023160000` records `paid` on a declaration whose debt was matched
 *      in full before the trigger existed, through `record_filing_outcome()`,
 *      and does nothing the second time;
 *   2. `20261023160100` takes the direct writes of `tax_filing_deposits` back
 *      from `authenticated`: a send, an outcome and the files are written by
 *      the core's functions, each asking `filings.write`, and paid is still
 *      recorded when the person matching the payment may not file.
 *
 * The pack under test is one that names the account a declaration owes on;
 * every code comes from its own files.
 */

const BACKFILL = '20261023160000_a_declaration_already_paid_says_so.sql';

const pack = packWhere(
  'names the administration a declaration is paid to, and the account it owes on',
  (p) =>
    p.manifest.defaults['tax_payee'] !== undefined &&
    typeof p.manifest.defaults.roles['tax_payable'] === 'string' &&
    p.report !== null &&
    p.report.boxes.length > 0 &&
    (p.golden?.documents ?? []).some(
      (d) => d.type === 'sale_invoice' && d.lines.some((l) => l.tax && l.account),
    ),
);

function goldenSale(): { tax: string; account: string } {
  for (const document of pack.golden?.documents ?? []) {
    if (document.type !== 'sale_invoice') continue;
    for (const line of document.lines) {
      if (line.tax && line.account) return { tax: line.tax, account: line.account };
    }
  }
  throw new Error(`${pack.slug} has no sale invoice with a tax in its golden`);
}
const SALE = goldenSale();

const PERIODS: Record<string, [string, string][]> = {
  month: [
    ['2026-01-01', '2026-01-31'],
    ['2026-02-01', '2026-02-28'],
    ['2026-03-01', '2026-03-31'],
    ['2026-04-01', '2026-04-30'],
  ],
  quarter: [
    ['2026-01-01', '2026-03-31'],
    ['2026-04-01', '2026-06-30'],
    ['2026-07-01', '2026-09-30'],
    ['2026-10-01', '2026-12-31'],
  ],
  year: [
    ['2026-01-01', '2026-12-31'],
    ['2027-01-01', '2027-12-31'],
    ['2028-01-01', '2028-12-31'],
    ['2029-01-01', '2029-12-31'],
  ],
};
const periods = PERIODS[pack.report?.period_default ?? 'month'] ?? PERIODS['month']!;

let db: PGlite;
let fx: Fixture;
let customerId: string;
let bankAccountId: string;
let sequence = 0;
let backfill: string;

interface Filing {
  id: string;
  state: string;
}

interface Deposit {
  outcome: string | null;
  outcome_at: string | null;
}

async function filingOf(id: string): Promise<Filing> {
  return one<Filing>(db, `select id, state from tax_filings where id = $1`, [id]);
}

async function lastDeposit(id: string): Promise<Deposit> {
  return one<Deposit>(
    db,
    `select outcome, outcome_at::text from tax_filing_deposits where filing_id = $1 order by sequence desc limit 1`,
    [id],
  );
}

/** A declaration of the period, sent, accepted and settled; its debt line, open. */
async function settled(index: number, amount: number): Promise<{ filing: string; debt: string; owed: number }> {
  const [from, to] = periods[index]!;
  const documentId = await newDocument(db, fx.companyId, {
    docType: 'sale_invoice',
    number: `CORE-${index}`,
    contactId: customerId,
    date: from,
    lines: [{ unitPrice: amount, taxCode: SALE.tax, accountCode: SALE.account }],
  });
  await db.query(`select post_document($1)`, [documentId]);
  const filing = await one<{ id: string }>(db, `select id from prepare_filing($1, $2::date, $3::date)`, [
    fx.companyId,
    from,
    to,
  ]);
  await db.query(`select file_filing($1, $2)`, [filing.id, `CORE-DEP-${index}`]);
  await db.query(`select record_filing_outcome($1, 'accepted')`, [filing.id]);
  const entry = await one<{ id: string }>(db, `select id from settle_filing($1, null, $2)`, [
    filing.id,
    `CORE-REF-${index}`,
  ]);
  const debt = await one<{ line_id: string; amount_open: string }>(
    db,
    `select o.line_id, o.amount_open::text from open_items($1) o
       join entry_lines l on l.id = o.line_id where l.entry_id = $2`,
    [fx.companyId, entry.id],
  );
  return { filing: filing.id, debt: debt.line_id, owed: Number(debt.amount_open) };
}

/** A bank line of the amount, matched to the debt. */
async function pay(index: number, debt: string, amount: number): Promise<void> {
  sequence += 1;
  const line = await one<{ id: string }>(
    db,
    `insert into bank_transactions
       (company_id, bank_account_id, sequence, transaction_date, amount, currency_code,
        description, reference, state)
     select $1, $2, $3, $4::date, $5, c.currency_code, 'Tax payment', $6, 'pending'
       from companies c where c.id = $1
     returning id`,
    [fx.companyId, bankAccountId, sequence, periods[index]![1], -amount, `CORE-REF-${index}`],
  );
  await db.query(`select settle_from_statement($1, $2::uuid[])`, [line.id, [debt]]);
}

beforeAll(async () => {
  db = await freshDatabase();
  backfill = await readFile(join(repoRoot, 'supabase', 'migrations', BACKFILL), 'utf8');
  // country-literal: the company is installed in the pack under test, which is
  // whichever one names the account a declaration owes on.
  fx = await newCompany(db, { country: pack.manifest.country, name: 'Deposit Fixture' });
  customerId = await newContact(db, fx.companyId, { name: 'Client', country: pack.manifest.country });
  bankAccountId = (
    await one<{ id: string }>(
      db,
      `insert into bank_accounts (company_id, name, currency_code, journal_id)
       select $1, 'Bank', c.currency_code,
              (select id from journals where company_id = $1 and journal_type = 'bank' limit 1)
         from companies c where c.id = $1
       returning id`,
      [fx.companyId],
    )
  ).id;
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('a declaration whose debt was matched before matching said so', () => {
  let paidBefore: string;
  let halfPaid: string;

  beforeAll(async () => {
    // Matched as a database before `20261023124650` matched it: no trigger.
    const full = await settled(0, 6_000);
    const half = await settled(1, 3_000);
    await withoutTrigger(db, 'entry_lines', 'tax_filings_paid_by_matching', async () => {
      await pay(0, full.debt, full.owed);
      await pay(1, half.debt, Math.round(half.owed * 50) / 100);
    });
    paidBefore = full.filing;
    halfPaid = half.filing;
  });

  it('is still accepted until the migration runs', async () => {
    expect((await filingOf(paidBefore)).state).toBe('accepted');
    expect((await filingOf(halfPaid)).state).toBe('accepted');
  });

  it('is paid once it has run, on the declaration and on its last send', async () => {
    await db.exec(backfill);
    expect((await filingOf(paidBefore)).state).toBe('paid');
    expect((await lastDeposit(paidBefore)).outcome).toBe('paid');
    // Paid in part is not paid, as by the trigger.
    expect((await filingOf(halfPaid)).state).toBe('accepted');
    expect((await lastDeposit(halfPaid)).outcome).toBe('accepted');
  });

  it('is left as it is by a second run', async () => {
    const before = await lastDeposit(paidBefore);
    await db.exec(backfill);
    expect(await lastDeposit(paidBefore)).toEqual(before);
    expect((await filingOf(halfPaid)).state).toBe('accepted');
  });
});

describe('a deposit', () => {
  let filer: string;
  let bookkeeper: string;

  beforeAll(async () => {
    filer = await newUser(db);
    bookkeeper = await newUser(db);
    await db.query(
      `insert into company_members (company_id, user_id, role, capabilities_revoked)
       values ($1, $2, 'accountant', '{}'), ($1, $3, 'accountant', array['filings.write'])`,
      [fx.companyId, filer, bookkeeper],
    );
  });

  it('is not written directly, even by a member who may file', async () => {
    const deposit = await one<{ id: string; filing_id: string }>(
      db,
      `select d.id, d.filing_id from tax_filing_deposits d join tax_filings f on f.id = d.filing_id
        where f.company_id = $1 order by d.id limit 1`,
      [fx.companyId],
    );
    await asUser(db, filer, async () => {
      expect(
        await expectError(db, `update tax_filing_deposits set reference = 'rewritten' where id = $1`, [deposit.id]),
      ).toContain('permission denied');
      expect(
        await expectError(db, `insert into tax_filing_deposits (filing_id, sequence) values ($1, 99)`, [
          deposit.filing_id,
        ]),
      ).toContain('permission denied');
      expect(await expectError(db, `delete from tax_filing_deposits where id = $1`, [deposit.id])).toContain(
        'permission denied',
      );
      // Reading stays.
      const seen = await one<{ n: number }>(db, `select count(*)::int as n from tax_filing_deposits where id = $1`, [
        deposit.id,
      ]);
      expect(seen.n).toBe(1);
    });
  });

  it('is written by the functions for a member who may file, and refused to one who may not', async () => {
    const [from, to] = periods[2]!;
    const documentId = await newDocument(db, fx.companyId, {
      docType: 'sale_invoice',
      number: 'CORE-FN',
      contactId: customerId,
      date: from,
      lines: [{ unitPrice: 1_000, taxCode: SALE.tax, accountCode: SALE.account }],
    });
    await db.query(`select post_document($1)`, [documentId]);
    const filing = await one<{ id: string }>(db, `select id from prepare_filing($1, $2::date, $3::date)`, [
      fx.companyId,
      from,
      to,
    ]);

    const refusedSend = await asUser(db, bookkeeper, () =>
      expectError(db, `select file_filing($1, 'NOT-MINE')`, [filing.id]),
    );
    expect(refusedSend).toContain('not_allowed');
    expect(refusedSend).toContain('filings.write');

    await asUser(db, filer, async () => {
      await db.query(`select file_filing($1, 'MINE')`, [filing.id]);
    });
    const sent = await one<{ sent_by: string; reference: string }>(
      db,
      `select sent_by, reference from tax_filing_deposits where filing_id = $1`,
      [filing.id],
    );
    expect(sent).toEqual({ sent_by: filer, reference: 'MINE' });

    const refusedOutcome = await asUser(db, bookkeeper, () =>
      expectError(db, `select record_filing_outcome($1, 'accepted')`, [filing.id]),
    );
    expect(refusedOutcome).toContain('not_allowed');
    expect((await filingOf(filing.id)).state).toBe('filed');

    await asUser(db, filer, async () => {
      await db.query(`select record_filing_outcome($1, 'accepted', null, 'Received')`, [filing.id]);
    });
    expect((await filingOf(filing.id)).state).toBe('accepted');
    expect((await lastDeposit(filing.id)).outcome).toBe('accepted');

    // Nobody calls the body directly.
    const body = await asUser(db, filer, () =>
      expectError(db, `select write_filing_outcome($1, 'paid')`, [filing.id]),
    );
    expect(body).toContain('permission denied');
  });

  it('is recorded paid when the payment is matched by somebody who keeps the books without filing', async () => {
    const debt = await settled(3, 2_000);
    sequence += 1;
    const line = await one<{ id: string }>(
      db,
      `insert into bank_transactions
         (company_id, bank_account_id, sequence, transaction_date, amount, currency_code,
          description, reference, state)
       select $1, $2, $3, $4::date, $5, c.currency_code, 'Tax payment', 'CORE-REF-3', 'pending'
         from companies c where c.id = $1
       returning id`,
      [fx.companyId, bankAccountId, sequence, periods[3]![1], -debt.owed],
    );
    await asUser(db, bookkeeper, async () => {
      await db.query(`select settle_from_statement($1, $2::uuid[])`, [line.id, [debt.debt]]);
    });
    expect((await filingOf(debt.filing)).state).toBe('paid');
    expect((await lastDeposit(debt.filing)).outcome).toBe('paid');
  });
});
