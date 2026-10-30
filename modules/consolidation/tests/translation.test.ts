import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from '../../../tests/helpers/db.js';
import { newCompany } from '../../../tests/helpers/factory.js';

// A member that keeps its books in another currency than the group's is
// translated by the closing rate method: what it owns and owes at the closing
// rate, what it earned at the average rate of the period, its equity at the
// rate of the day it came in — and what the three leave over is its
// translation difference, a line of equity of its own.

let db: PGlite;
let ownerId: string;
let parentId: string;
let memberId: string;
let groupId: string;
let groupCurrency: string;
let memberCurrency: string;

interface Translated {
  company_id: string;
  account_code: string | null;
  account_type: string;
  balance: string;
  rate_kind: string;
  rate: string | null;
  translated: string;
  integration_rate: string;
  integrated: string;
}

const translated = (from = '2026-01-01', to = '2026-12-31'): Promise<Translated[]> =>
  rows<Translated>(db, `select * from consolidation.translated_balances($1, $2, $3::date, $4::date)`, [
    parentId,
    groupId,
    from,
    to,
  ]);

/** A posted entry of the company: `amount` debited on one account type and credited on the other. */
async function booked(companyId: string, date: string, debitType: string, creditType: string, amount: number): Promise<void> {
  const account = async (type: string): Promise<string> =>
    (
      await one<{ id: string }>(
        db,
        `select id from accounts where company_id = $1 and account_type = $2::account_type order by code limit 1`,
        [companyId, type],
      )
    ).id;
  const entry = await one<{ id: string }>(
    db,
    `insert into entries (company_id, journal_id, entry_date, state, currency_code, description)
     select c.id, c.miscellaneous_journal_id, $2::date, 'draft', c.currency_code, 'Booked' from companies c where c.id = $1
     returning id`,
    [companyId, date],
  );
  await db.query(
    `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit)
     values ($1, $2, $3, 10, 'Booked', $5, 0), ($1, $2, $4, 20, 'Booked', 0, $5)`,
    [entry.id, companyId, await account(debitType), await account(creditType), amount],
  );
  await db.query(`select post_entry($1)`, [entry.id]);
}

beforeAll(async () => {
  db = await freshDatabase();
  ({ companyId: parentId, ownerId } = await newCompany(db, { country: 'BE', name: 'Holding SA' }));
  ({ companyId: memberId } = await newCompany(db, { country: 'GB', name: 'Subsidiary Ltd', ownerId }));
  ({ currency_code: groupCurrency } = await one<{ currency_code: string }>(
    db,
    `select currency_code from companies where id = $1`,
    [parentId],
  ));
  ({ currency_code: memberCurrency } = await one<{ currency_code: string }>(
    db,
    `select currency_code from companies where id = $1`,
    [memberId],
  ));

  // The member: its capital paid in on the first day, then a sale on credit.
  await booked(memberId, '2026-01-01', 'asset_cash', 'equity', 1000);
  await booked(memberId, '2026-06-15', 'asset_receivable', 'income', 500);
  // The parent books in the group's currency and is never translated.
  await booked(parentId, '2026-03-01', 'asset_cash', 'income', 200);

  await asUser(db, ownerId, async () => {
    await db.query(`select enable_module($1, 'consolidation')`, [parentId]);
    ({ id: groupId } = await one<{ id: string }>(db, `select id from consolidation.create_group($1, 'main', 'Main group')`, [
      parentId,
    ]));
    await db.query(`select consolidation.add_member($1, $2, $3, 'full', 80, date '2026-01-01')`, [
      parentId,
      groupId,
      memberId,
    ]);
  });
});

afterAll(async () => {
  await db.close();
});

describe('the rates of a group', () => {
  it('are refused for the currency of the group, which is never translated', async () => {
    await asUser(db, ownerId, async () => {
      const refused = await expectError(
        db,
        `select consolidation.set_rate($1, $2, $3, date '2026-01-01', date '2026-12-31', 1)`,
        [parentId, groupId, groupCurrency],
      );
      expect(refused).toMatch(/^consolidation_rate_of_the_group_currency:/);
    });
  });

  it('refuse a translation by name while one is missing', async () => {
    await asUser(db, ownerId, async () => {
      const refused = await expectError(
        db,
        `select * from consolidation.translated_balances($1, $2, date '2026-01-01', date '2026-12-31')`,
        [parentId, groupId],
      );
      expect(refused).toMatch(/^consolidation_rate_missing: no closing rate of /);
      expect(refused).toContain(memberCurrency);
      expect(refused).toContain('Subsidiary Ltd');
    });
  });

  it('are corrected, never doubled, when the same currency and last day come again', async () => {
    await asUser(db, ownerId, async () => {
      const first = await one<{ id: string }>(
        db,
        `select * from consolidation.set_rate($1, $2, $3, date '2025-01-01', date '2025-12-31', 0.7)`,
        [parentId, groupId, memberCurrency],
      );
      const again = await one<{ id: string; closing_rate: string; source: string }>(
        db,
        `select * from consolidation.set_rate($1, $2, $3, date '2025-01-01', date '2025-12-31', 0.8, null, 'A central bank')`,
        [parentId, groupId, memberCurrency],
      );
      expect(again).toMatchObject({ id: first.id, closing_rate: '0.80000000', source: 'A central bank' });
      await db.query(
        `select consolidation.set_rate($1, $2, $3, date '2026-01-01', date '2026-12-31', 0.9, 0.85)`,
        [parentId, groupId, memberCurrency],
      );
    });
  });
});

describe('the translated balances', () => {
  it('put assets at the closing rate, income at the average, equity at the rate of the day the member came in', async () => {
    const member = await asUser(db, ownerId, async () =>
      (await translated()).filter((row) => row.company_id === memberId && row.account_code !== null),
    );
    const byType = Object.fromEntries(member.map((row) => [row.account_type, row]));

    expect(byType.asset_cash).toMatchObject({ balance: '1000.00', rate_kind: 'closing', translated: '1111.11' });
    expect(byType.asset_receivable).toMatchObject({ balance: '500.00', rate_kind: 'closing', translated: '555.56' });
    expect(byType.income).toMatchObject({ balance: '-500.00', rate_kind: 'average', translated: '-588.24' });
    expect(byType.equity).toMatchObject({ balance: '-1000.00', rate_kind: 'entry', translated: '-1250.00' });
  });

  it('end the member with its translation difference, which brings its translated balance back to zero', async () => {
    const member = await asUser(db, ownerId, async () =>
      (await translated()).filter((row) => row.company_id === memberId),
    );
    const difference = member.find((row) => row.rate_kind === 'translation_difference');
    expect(difference).toMatchObject({ account_code: null, account_type: 'equity', translated: '171.57' });
    const total = member.reduce((sum, row) => sum + Math.round(Number(row.translated) * 100), 0);
    expect(total).toBe(0);
  });

  it('take a member in at its integration rate, and leave the parent untranslated', async () => {
    const all = await asUser(db, ownerId, async () => translated());
    for (const row of all.filter((r) => r.company_id === memberId)) {
      expect(row).toMatchObject({ integration_rate: '100.0000', integrated: row.translated });
    }
    const parent = all.filter((row) => row.company_id === parentId);
    expect(parent.length).toBeGreaterThan(0);
    for (const row of parent) {
      expect(row).toMatchObject({ rate_kind: 'none', translated: row.balance, integrated: row.balance });
    }
    expect(parent.some((row) => row.rate_kind === 'translation_difference')).toBe(false);
  });

  it('refuse a period whose average rate the group has not set', async () => {
    await asUser(db, ownerId, async () => {
      const refused = await expectError(
        db,
        `select * from consolidation.translated_balances($1, $2, date '2026-07-01', date '2026-12-31')`,
        [parentId, groupId],
      );
      expect(refused).toMatch(/^consolidation_rate_missing: no average rate of /);
    });
  });

  it('travel with an archive of the parent, as its groups do', async () => {
    const rates = await one<{ disposition: string }>(
      db,
      `select disposition from consolidation.archive_tables() where table_name = 'rates'`,
    );
    expect(rates.disposition).toBe('exported');
  });
});
