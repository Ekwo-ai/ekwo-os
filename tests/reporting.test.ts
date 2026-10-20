import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { expectError, freshDatabase, one, rows } from './helpers/db.js';
import { demoCompanyId } from './helpers/factory.js';

let db: PGlite;
let companyId: string;

beforeAll(async () => {
  db = await freshDatabase();
  companyId = await demoCompanyId(db);
});

afterAll(async () => {
  await db.close();
});

const n = (value: string | null): number => Number(value ?? 0);

describe('trial_balance on the demo company', () => {
  it('balances: total debit equals total credit', async () => {
    const lines = await rows<{ debit: string; credit: string }>(
      db,
      `select debit, credit from trial_balance($1, '2026-01-01', '2026-12-31')`,
      [companyId],
    );
    const debit = lines.reduce((sum, l) => sum + n(l.debit), 0);
    const credit = lines.reduce((sum, l) => sum + n(l.credit), 0);
    expect(debit).toBeCloseTo(credit, 2);
    expect(debit).toBeGreaterThan(0);
  });

  it('leaves draft entries out of the balances', async () => {
    const before = await one<{ closing_balance: string }>(
      db,
      `select closing_balance from trial_balance($1, '2026-01-01', '2026-12-31')
        where account_code = '704000'`,
      [companyId],
    );

    const entry = await one<{ id: string }>(
      db,
      `insert into entries (company_id, journal_id, entry_date, description, state)
       select $1, id, date '2026-09-01', 'Brouillon', 'draft' from journals
        where company_id = $1 and code = 'MISC' returning id`,
      [companyId],
    );
    await db.query(
      `insert into entry_lines (entry_id, company_id, account_id, sequence, debit, credit)
       values ($1, $2, account_id_by_code($2, '704000'), 10, 0, 9999)`,
      [entry.id, companyId],
    );

    const after = await one<{ closing_balance: string }>(
      db,
      `select closing_balance from trial_balance($1, '2026-01-01', '2026-12-31')
        where account_code = '704000'`,
      [companyId],
    );
    expect(after.closing_balance).toBe(before.closing_balance);

    await db.query(`delete from entries where id = $1`, [entry.id]);
  });

  it('carries an opening balance into the following period', async () => {
    const july = await one<{ closing_balance: string }>(
      db,
      `select closing_balance from trial_balance($1, '2026-07-01', '2026-07-31')
        where account_code = '400000'`,
      [companyId],
    );
    const august = await one<{ opening_balance: string }>(
      db,
      `select opening_balance from trial_balance($1, '2026-08-01', '2026-08-31')
        where account_code = '400000'`,
      [companyId],
    );
    expect(august.opening_balance).toBe(july.closing_balance);
  });
});

describe('vat_return on the demo company', () => {
  it('fills the Belgian boxes of the third quarter', async () => {
    const boxes = await rows<{ box: string; kind: string; amount: string }>(
      db,
      `select box, kind, amount from vat_return($1, '2026-07-01', '2026-09-30')`,
      [companyId],
    );
    const byBox = Object.fromEntries(boxes.map((b) => [b.box, n(b.amount)]));

    expect(byBox['01']).toBeCloseTo(400, 2); // 6 % sales
    expect(byBox['03']).toBeCloseTo(4500, 2); // 21 % sales, net of the credit note base
    expect(byBox['44']).toBeCloseTo(3200, 2); // European Union services supplied
    expect(byBox['47']).toBeCloseTo(5400, 2); // exports
    expect(byBox['49']).toBeCloseTo(300, 2); // credit note issued
    expect(byBox['54']).toBeCloseTo(969, 2); // 4500 x 21 % + 400 x 6 %
    expect(byBox['64']).toBeCloseTo(63, 2); // VAT on the credit note
    expect(byBox['82']).toBeCloseTo(3640, 2); // services purchased, the European Union service of 88 included
    expect(byBox['83']).toBeCloseTo(2400, 2); // capital goods
    expect(byBox['88']).toBeCloseTo(990, 2); // European Union services received
    expect(byBox['55']).toBeCloseTo(207.9, 2); // self-assessed on box 88
    expect(byBox['59']).toBeCloseTo(1268.4, 2); // deductible, self-assessment included
  });

  it('computes boxes 71 and 72 from the others', async () => {
    const boxes = await rows<{ box: string; amount: string; computed: boolean }>(
      db,
      `select box, amount, computed from vat_return($1, '2026-07-01', '2026-09-30')`,
      [companyId],
    );
    const byBox = Object.fromEntries(boxes.map((b) => [b.box, n(b.amount)]));
    const due = ['54', '55', '56', '57', '61', '63'].reduce((s, b) => s + (byBox[b] ?? 0), 0);
    const deductible = ['59', '62', '64'].reduce((s, b) => s + (byBox[b] ?? 0), 0);

    expect(byBox['71'] ?? 0).toBeCloseTo(Math.max(due - deductible, 0), 2);
    expect(byBox['72'] ?? 0).toBeCloseTo(Math.max(deductible - due, 0), 2);
    expect(boxes.find((b) => b.box === '72')?.computed).toBe(true);
  });

  it('leaves the ledger and the return in step on a self-assessed purchase', async () => {
    // The two VAT lines of the European Union purchase cancel each other in
    // the ledger while both boxes are still filled.
    const net = await one<{ balance: string }>(
      db,
      `select coalesce(sum(l.balance), 0)::text as balance
         from entry_lines l
         join entries e on e.id = l.entry_id
         join documents d on d.id = e.document_id
        where d.number = 'ACH-2026-0002' and l.tax_line`,
    );
    expect(n(net.balance)).toBeCloseTo(0, 2);
  });
});

describe('aged_balance on the demo company', () => {
  it('reports only what is still unmatched', async () => {
    const aged = await rows<{ contact_name: string; total: string }>(
      db,
      `select contact_name, total from aged_balance($1, '2026-09-11', 'receivable')`,
      [companyId],
    );
    const dumont = aged.find((a) => a.contact_name === 'Atelier Dumont SRL');
    // 4 477 invoiced and paid, plus 968 and 424 open, less a 363 credit note.
    expect(n(dumont?.total ?? null)).toBeCloseTo(1029, 2);
  });

  it('ties back to the receivable account of the trial balance', async () => {
    const aged = await rows<{ total: string }>(
      db,
      `select total from aged_balance($1, '2026-12-31', 'receivable')`,
      [companyId],
    );
    const agedTotal = aged.reduce((sum, a) => sum + n(a.total), 0);
    const ledger = await one<{ closing_balance: string }>(
      db,
      `select closing_balance from trial_balance($1, '2026-01-01', '2026-12-31')
        where account_code = '400000'`,
      [companyId],
    );
    expect(agedTotal).toBeCloseTo(n(ledger.closing_balance), 2);
  });

  it('buckets by due date', async () => {
    const northwind = await one<{ not_due: string | null; days_over_90: string | null }>(
      db,
      `select not_due, days_over_90 from aged_balance($1, '2026-09-11', 'receivable')
        where contact_name = 'Northwind Systems Inc'`,
      [companyId],
    );
    expect(n(northwind.not_due)).toBeCloseTo(5400, 2);
    expect(northwind.days_over_90).toBeNull();
  });

  // The audit of 13 September 2026. The group was tested as `= 'payable'`
  // twice, so anything that was not exactly that word — a typo, a plural, a
  // capital letter — came back as the receivable ageing: a full, plausible,
  // wrong report, which is the one failure a report must never have.
  it('refuses a group it does not know, instead of answering receivable', async () => {
    for (const group of ['supplier', 'Payable', 'creditors', '']) {
      const message = await expectError(db, `select * from aged_balance($1, '2026-09-11', $2)`, [
        companyId,
        group,
      ]);
      expect(message, group).toMatch(/invalid_group/);
    }
    const nullGroup = await expectError(
      db,
      `select * from aged_balance($1, '2026-09-11', null)`,
      [companyId],
    );
    expect(nullGroup).toMatch(/invalid_group/);

    // The two it does know still answer.
    for (const group of ['receivable', 'payable']) {
      const answer = await rows(db, `select * from aged_balance($1, '2026-09-11', $2)`, [
        companyId,
        group,
      ]);
      expect(Array.isArray(answer), group).toBe(true);
    }
  });
});

describe('general_ledger', () => {
  it('carries the running balance from before the period', async () => {
    const lines = await rows<{ entry_number: string; running_balance: string }>(
      db,
      `select entry_number, running_balance from general_ledger($1, '2026-08-01', '2026-08-31',
              array[account_id_by_code($1, '400000')])`,
      [companyId],
    );
    expect(lines.length).toBeGreaterThan(0);

    const opening = await one<{ opening_balance: string }>(
      db,
      `select opening_balance from trial_balance($1, '2026-08-01', '2026-08-31')
        where account_code = '400000'`,
      [companyId],
    );
    const closing = await one<{ closing_balance: string }>(
      db,
      `select closing_balance from trial_balance($1, '2026-08-01', '2026-08-31')
        where account_code = '400000'`,
      [companyId],
    );
    expect(n(lines.at(-1)?.running_balance ?? null)).toBeCloseTo(n(closing.closing_balance), 2);
    expect(n(opening.opening_balance)).not.toBeNaN();
  });
});

describe('journal_book and journal_totals', () => {
  it('reads every posted line of the period, in the order a book is read', async () => {
    const lines = await rows<{
      journal_code: string;
      entry_number: string | null;
      entry_date: string;
      line_sequence: number;
      debit: string;
      credit: string;
    }>(
      db,
      `select entry_date::text as entry_date, journal_code, entry_number, line_sequence, debit, credit
         from journal_book($1, '2026-01-01', '2026-12-31')`,
      [companyId],
    );
    expect(lines.length).toBeGreaterThan(0);

    // The same lines the ledger holds, account by account: neither reading leaves one out.
    const ledger = await one<{ n: number }>(
      db,
      `select count(*)::int as n from general_ledger($1, '2026-01-01', '2026-12-31')`,
      [companyId],
    );
    expect(lines.length).toBe(ledger.n);

    // Day, journal, number, line: a book is read in that order and no other.
    const keys = lines.map((l) => [l.entry_date, l.journal_code, l.entry_number ?? '', String(l.line_sequence).padStart(6, '0')].join('|'));
    const sorted = [...keys].sort((a, b) => (a < b ? -1 : a > b ? 1 : 0));
    expect(keys).toEqual(sorted);
  });

  it('reads one journal alone, and its totals are the head of that book', async () => {
    const totals = await rows<{
      journal_id: string;
      journal_code: string;
      entries: number;
      lines: number;
      debit: string;
      credit: string;
    }>(db, `select * from journal_totals($1, '2026-01-01', '2026-12-31')`, [companyId]);
    const every = await rows<{ code: string }>(db, `select code from journals where company_id = $1 order by code`, [companyId]);
    // Every journal of the company has its row, the quiet ones at zero.
    expect(totals.map((t) => t.journal_code)).toEqual(every.map((j) => j.code));

    const busy = totals.find((t) => Number(t.entries) > 0);
    expect(busy).toBeDefined();
    const book = await rows<{ entry_id: string; journal_code: string; debit: string; credit: string }>(
      db,
      `select entry_id, journal_code, debit, credit from journal_book($1, '2026-01-01', '2026-12-31', array[$2::uuid])`,
      [companyId, busy!.journal_id],
    );
    expect(book.length).toBe(Number(busy!.lines));
    expect(new Set(book.map((l) => l.journal_code))).toEqual(new Set([busy!.journal_code]));
    expect(new Set(book.map((l) => l.entry_id)).size).toBe(Number(busy!.entries));
    expect(book.reduce((sum, l) => sum + n(l.debit), 0)).toBeCloseTo(n(busy!.debit), 2);
    expect(book.reduce((sum, l) => sum + n(l.credit), 0)).toBeCloseTo(n(busy!.credit), 2);
    // A journal's book balances: what it debits, it credits.
    expect(n(busy!.debit)).toBeCloseTo(n(busy!.credit), 2);
  });

  it('leaves draft entries out of the book and of the totals', async () => {
    const before = await one<{ lines: number }>(
      db,
      `select lines from journal_totals($1, '2026-01-01', '2026-12-31') where journal_code = 'MISC'`,
      [companyId],
    );
    const entry = await one<{ id: string }>(
      db,
      `insert into entries (company_id, journal_id, entry_date, description, state)
       select $1, id, date '2026-09-02', 'Brouillon', 'draft' from journals
        where company_id = $1 and code = 'MISC' returning id`,
      [companyId],
    );
    await db.query(
      `insert into entry_lines (entry_id, company_id, account_id, sequence, debit, credit)
       values ($1, $2, account_id_by_code($2, '704000'), 10, 0, 42)`,
      [entry.id, companyId],
    );
    const after = await one<{ lines: number }>(
      db,
      `select lines from journal_totals($1, '2026-01-01', '2026-12-31') where journal_code = 'MISC'`,
      [companyId],
    );
    expect(Number(after.lines)).toBe(Number(before.lines));
    const drafts = await rows<{ entry_id: string }>(
      db,
      `select entry_id from journal_book($1, '2026-01-01', '2026-12-31') where entry_id = $2`,
      [companyId, entry.id],
    );
    expect(drafts).toEqual([]);
  });
});

describe('general_ledger names the contact of a line', () => {
  it('gives the contact itself beside its name, and nothing where the line names nobody', async () => {
    const lines = await rows<{ entry_line_id: string; contact_id: string | null; contact_name: string | null }>(
      db,
      `select entry_line_id, contact_id, contact_name from general_ledger($1, '2026-01-01', '2026-12-31')`,
      [companyId],
    );
    expect(lines.some((l) => l.contact_id !== null)).toBe(true);
    for (const line of lines) {
      const said = await one<{ contact_id: string | null; name: string | null }>(
        db,
        `select l.contact_id, c.name from entry_lines l left join contacts c on c.id = l.contact_id where l.id = $1`,
        [line.entry_line_id],
      );
      expect(line.contact_id).toBe(said.contact_id);
      expect(line.contact_name).toBe(said.name);
    }
  });
});
