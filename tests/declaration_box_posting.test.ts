import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, freshDatabase, one, rows } from './helpers/db.js';
import { accountId, newCompany, type Fixture } from './helpers/factory.js';
import { newMember, plainSale, refusalAs } from './helpers/integrity.js';

// Issue #88: a line keyed by hand could name any declaration box, with any
// amount and no tax, and `vat_return()` summed it into that box.

let db: PGlite;
let fx: Fixture;
let accountant: string;
let tax: { id: string; box: string; account: string; baseBox: string };
let income: string;
let cash: string;

interface Line {
  account: string;
  debit: number;
  credit: number;
  tax?: string | null;
  taxLine?: boolean;
  box?: string | null;
  boxAmount?: number | null;
}

const insertLine = `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit,
                                             tax_id, tax_line, declaration_box, box_amount)
                    values ($1, $2, $3, $4, 'By hand', $5, $6, $7, $8, $9, $10)`;

function lineParams(entry: string, line: Line, sequence: number): unknown[] {
  return [
    entry,
    fx.companyId,
    line.account,
    sequence,
    line.debit,
    line.credit,
    line.tax ?? null,
    line.taxLine ?? false,
    line.box ?? null,
    line.boxAmount ?? null,
  ];
}

/** A draft entry in the miscellaneous journal, written by the owner. */
async function draft(): Promise<string> {
  const row = await one<{ id: string }>(
    db,
    `insert into entries (company_id, journal_id, entry_date, state, currency_code)
     select c.id, c.miscellaneous_journal_id, '2026-05-04', 'draft', c.currency_code from companies c where c.id = $1
     returning id`,
    [fx.companyId],
  );
  return row.id;
}

/** A sale of 100 keyed by hand, the way post_document would have booked it. */
async function saleByHand(): Promise<string> {
  const entry = await draft();
  await asUser(db, accountant, async () => {
    const lines: Line[] = [
      { account: cash, debit: 110, credit: 0 },
      { account: income, debit: 0, credit: 100, tax: tax.id, box: tax.baseBox, boxAmount: 100 },
      { account: tax.account, debit: 0, credit: 10, tax: tax.id, taxLine: true, box: tax.box, boxAmount: 10 },
    ];
    for (const [index, line] of lines.entries()) await db.query(insertLine, lineParams(entry, line, (index + 1) * 10));
    await db.query(`select post_entry($1)`, [entry]);
  });
  return entry;
}

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db);
  accountant = await newMember(db, fx.companyId, 'accountant');
  const sale = await plainSale(db, fx.companyId);
  const posting = await one<{ box: string; account: string; base_box: string }>(
    db,
    `select t.declaration_box as box, t.account_id as account, b.declaration_box as base_box
       from tax_postings t
       join tax_postings b on b.tax_id = t.tax_id and b.document_kind = t.document_kind and b.posting_type = 'base'
      where t.tax_id = $1 and t.document_kind = 'invoice' and t.posting_type = 'tax'
      limit 1`,
    [sale.taxId],
  );
  tax = { id: sale.taxId, box: posting.box, account: posting.account, baseBox: posting.base_box };
  income = await accountId(db, fx.companyId, sale.accountCode);
  cash = (
    await one<{ id: string }>(
      db,
      `select id from accounts where company_id = $1 and account_type = 'asset_cash' order by code limit 1`,
      [fx.companyId],
    )
  ).id;
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('a line keyed by hand names a box its tax posting writes', () => {
  it('refuses a box on a line with no tax', async () => {
    const entry = await draft();
    expect(
      await refusalAs(db, accountant, insertLine, lineParams(entry, { account: cash, debit: 50, credit: 0, box: tax.box, boxAmount: 50 }, 10)),
    ).toMatch(/^declaration_box_without_posting\b.*no tax/);
  });

  it('refuses a box no posting of its tax writes, and the base box on the tax side', async () => {
    const entry = await draft();
    const nowhere = `${tax.box}-nowhere`;
    for (const box of [nowhere, tax.baseBox === tax.box ? nowhere : tax.baseBox]) {
      expect(
        await refusalAs(
          db,
          accountant,
          insertLine,
          lineParams(entry, { account: tax.account, debit: 0, credit: 10, tax: tax.id, taxLine: true, box, boxAmount: 10 }, 10),
        ),
      ).toMatch(/^declaration_box_without_posting\b.*tax side/);
    }
  });

  it('refuses a box written afterwards on a draft line', async () => {
    const entry = await draft();
    const line = await one<{ id: string }>(
      db,
      `${insertLine} returning id`,
      lineParams(entry, { account: income, debit: 0, credit: 100, tax: tax.id }, 10),
    );
    expect(
      await refusalAs(db, accountant, `update entry_lines set declaration_box = $2, box_amount = 100 where id = $1`, [
        line.id,
        `${tax.baseBox}-nowhere`,
      ]),
    ).toMatch(/^declaration_box_without_posting\b/);
  });

  it('accepts the boxes the postings write, and the return reads them', async () => {
    const before = await rows<{ box: string; kind: string; amount: string }>(
      db,
      `select box, kind, amount from vat_return($1, '2026-05-01', '2026-05-31') where not computed`,
      [fx.companyId],
    );
    expect(before).toEqual([]);
    await saleByHand();
    const after = await rows<{ box: string; kind: string; amount: string }>(
      db,
      `select box, kind, amount::text from vat_return($1, '2026-05-01', '2026-05-31') where not computed order by kind`,
      [fx.companyId],
    );
    expect(after).toEqual(
      expect.arrayContaining([
        { box: tax.baseBox, kind: 'base', amount: '100.00' },
        { box: tax.box, kind: 'tax', amount: '10.00' },
      ]),
    );
  });

  it('reverses a line in the box it was posted in, after the posting has moved', async () => {
    const entry = await saleByHand();
    const moved = `${tax.box}-moved`;
    await db.query(
      `update tax_postings set declaration_box = $2, declaration_boxes = array[$2]
        where tax_id = $1 and posting_type = 'tax' and declaration_box = $3`,
      [tax.id, moved, tax.box],
    );
    try {
      expect(await refusalAs(db, accountant, `select reverse_entry($1)`, [entry])).toBe('accepted');
    } finally {
      await db.query(
        `update tax_postings set declaration_box = $3, declaration_boxes = array[$3]
          where tax_id = $1 and posting_type = 'tax' and declaration_box = $2`,
        [tax.id, moved, tax.box],
      );
    }
  });
});
