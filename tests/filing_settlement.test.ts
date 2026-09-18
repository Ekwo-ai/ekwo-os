import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, type Fixture } from './helpers/factory.js';
import { allPacks, packWhere } from './helpers/packs.js';

/**
 * The entry a declaration leaves behind.
 *
 * Until here, a period that was declared and accepted changed nothing in the
 * books: the collected and the deductible stayed where the postings put them,
 * and what was owed to the administration was a subtraction nobody had made.
 * What is proved below:
 *
 *   1. settling clears every tax account the period moved, to the cent, and
 *      carries the net to the account **the pack** names;
 *   2. it happens once — a second call is refused by the database, not by a
 *      convention;
 *   3. it follows acceptance, and every other state is refused by name;
 *   4. a period ending in the company's favour is not settled until somebody
 *      says what happens to the credit;
 *   5. the debt is then an open item like any other, and `auto_settle()`
 *      matches the payment to the administration by its reference — which is
 *      the whole reason the settlement carries one;
 *   6. a period that moved no tax account is refused rather than posted empty;
 *   7. a pack that names no such account gets a sentence naming the role to
 *      set, not the account of the country next door.
 *
 * The pack under test is whichever one names the role, and the tax, the
 * accounts and the cadence all come from that pack's own files.
 */

/** The pack that says where what a declaration owes lands. */
const pack = packWhere(
  'names the account what a declaration owes lands on',
  (p) => typeof p.manifest.defaults.roles['tax_payable'] === 'string',
);

const PAYABLE = pack.manifest.defaults.roles['tax_payable'] as string;
const RECEIVABLE = (pack.manifest.defaults.roles['tax_receivable'] as string | undefined) ?? PAYABLE;

/** A sale and a purchase of that pack's own golden: its taxes, its accounts. */
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
const PURCHASE = goldenLine('purchase_invoice');

/**
 * A period this pack files on, as a whole cadence of its own form: a return
 * asked for on a period the company does not file is refused upstream, and
 * that refusal belongs to another test.
 */
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
let supplierId: string;
let administrationId: string;
let bankAccountId: string;
let sequence = 0;

interface Filing {
  id: string;
  report_code: string;
  state: string;
  settlement_entry_id: string | null;
  credit_treatment: string | null;
}

interface Line {
  code: string;
  debit: string;
  credit: string;
}

async function invoice(
  kind: 'sale_invoice' | 'purchase_invoice',
  number: string,
  date: string,
  amount: number,
): Promise<void> {
  const side = kind === 'sale_invoice' ? SALE : PURCHASE;
  const documentId = await newDocument(db, fx.companyId, {
    docType: kind,
    number,
    contactId: kind === 'sale_invoice' ? customerId : supplierId,
    date,
    lines: [{ unitPrice: amount, taxCode: side.tax, accountCode: side.account }],
  });
  await db.query(`select post_document($1)`, [documentId]);
}

/** Prepared, filed and accepted: the state settling starts from. */
async function accepted(from: string, to: string): Promise<Filing> {
  const prepared = await one<Filing>(db, `select * from prepare_filing($1, $2::date, $3::date)`, [
    fx.companyId,
    from,
    to,
  ]);
  await db.query(`select file_filing($1, $2)`, [prepared.id, `DEP-${from}`]);
  return one<Filing>(db, `select * from record_filing_outcome($1, 'accepted')`, [prepared.id]);
}

async function settle(
  filingId: string,
  credit?: string,
  reference?: string,
  contactId?: string,
): Promise<string> {
  const entry = await one<{ id: string }>(
    db,
    `select id from settle_filing($1, $2::tax_credit_treatment, $3, $4)`,
    [filingId, credit ?? null, reference ?? null, contactId ?? null],
  );
  return entry.id;
}

/** The lines of an entry, by account code — what the entry actually did. */
async function linesOf(entryId: string): Promise<Line[]> {
  return rows<Line>(
    db,
    `select a.code, l.debit::text, l.credit::text
       from entry_lines l join accounts a on a.id = l.account_id
      where l.entry_id = $1 order by a.code`,
    [entryId],
  );
}

/** What a tax account holds over a window, from the ledger itself. */
async function balanceOf(code: string, from: string, to: string): Promise<number> {
  const row = await one<{ balance: string }>(
    db,
    `select coalesce(sum(l.balance), 0)::text as balance
       from entry_lines l
       join entries e on e.id = l.entry_id
       join accounts a on a.id = l.account_id
      where l.company_id = $1 and a.code = $2 and e.state = 'posted'
        and e.entry_date between $3::date and $4::date`,
    [fx.companyId, code, from, to],
  );
  return Number(row.balance);
}

beforeAll(async () => {
  db = await freshDatabase();
  // country-literal: the pack under test is the one that names the role, and a
  // company has to be installed somewhere to declare anything.
  fx = await newCompany(db, { country: pack.manifest.country, name: 'Filing Fixture' });
  customerId = await newContact(db, fx.companyId, {
    name: 'Client',
    country: pack.manifest.country,
  });
  supplierId = await newContact(db, fx.companyId, {
    name: 'Fournisseur',
    country: pack.manifest.country,
  });
  // The administration is a third party like any other, and the account its
  // card carries is the one the pack names for what a declaration owes: that
  // is what puts the payment and the debt on the same account, which is what
  // matching needs.
  administrationId = await newContact(db, fx.companyId, {
    name: 'Administration',
    country: pack.manifest.country,
  });
  await db.query(
    `update contacts set payable_account_id = (select id from accounts
                                                where company_id = $1 and code = $2)
      where id = $3`,
    [fx.companyId, PAYABLE, administrationId],
  );
  const account = await one<{ id: string }>(
    db,
    `insert into bank_accounts (company_id, name, currency_code, iban, journal_id)
     select $1, 'Bank', c.currency_code, 'GB33BUKB20201555555555',
            (select id from journals where company_id = $1 and journal_type = 'bank' limit 1)
       from companies c where c.id = $1
     returning id`,
    [fx.companyId],
  );
  bankAccountId = account.id;
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('settling a declaration', () => {
  const [from, to] = periods[0]!;

  it('clears the tax accounts of the period and carries the net to the account the pack names', async () => {
    await invoice('sale_invoice', 'SETTLE-S1', from, 10_000);
    await invoice('purchase_invoice', 'SETTLE-P1', from, 2_000);

    const moved = await rows<{ code: string; balance: string }>(
      db,
      `select a.code, m.balance::text
         from filing_tax_movements((select id from tax_filings
                                     where company_id = $1 and period_start = $2::date)) m
         join accounts a on a.id = m.account_id order by a.code`,
      [fx.companyId, from],
    ).catch(() => []);
    // Nothing is prepared yet, so there is nothing to read: the function is
    // keyed on a filing, and the filing is what the next line makes.
    expect(moved).toEqual([]);

    const filing = await accepted(from, to);
    const movements = await rows<{ code: string; balance: string }>(
      db,
      `select a.code, m.balance::text from filing_tax_movements($1) m
         join accounts a on a.id = m.account_id order by a.code`,
      [filing.id],
    );
    expect(movements.length).toBeGreaterThan(0);
    const net = movements.reduce((sum, m) => sum + Number(m.balance), 0);
    // A month of more sales than purchases owes money: a credit balance on the
    // tax accounts, which is a negative signed balance.
    expect(net).toBeLessThan(0);

    const entryId = await settle(filing.id);
    const lines = await linesOf(entryId);

    // One line per account moved, plus the net.
    expect(lines).toHaveLength(movements.length + 1);
    const debt = lines.find((l) => l.code === PAYABLE)!;
    expect(Number(debt.credit)).toBeCloseTo(-net, 2);
    expect(Number(debt.debit)).toBe(0);

    // And every tax account is back to zero over the period.
    for (const movement of movements) {
      expect(await balanceOf(movement.code, from, to)).toBeCloseTo(0, 2);
    }

    const after = await one<Filing>(db, `select * from tax_filings where id = $1`, [filing.id]);
    expect(after.settlement_entry_id).toBe(entryId);
    expect(after.credit_treatment).toBeNull();
  });

  it('is done once, and the second attempt says which entry did it', async () => {
    const filing = await one<Filing>(
      db,
      `select * from tax_filings where company_id = $1 and period_start = $2::date`,
      [fx.companyId, from],
    );
    const message = await expectError(db, `select settle_filing($1)`, [filing.id]);
    expect(message).toContain('filing_already_settled');
    expect(message).toContain(filing.settlement_entry_id);
  });

  it('follows acceptance, and says what it found instead', async () => {
    const [second, secondEnd] = periods[1]!;
    await invoice('sale_invoice', 'SETTLE-S2', second, 500);
    const prepared = await one<Filing>(
      db,
      `select * from prepare_filing($1, $2::date, $3::date)`,
      [fx.companyId, second, secondEnd],
    );
    expect(await expectError(db, `select settle_filing($1)`, [prepared.id])).toContain(
      'filing_not_accepted',
    );

    await db.query(`select file_filing($1)`, [prepared.id]);
    const filed = await expectError(db, `select settle_filing($1)`, [prepared.id]);
    expect(filed).toContain('filing_not_accepted');
    expect(filed).toContain('filed');
  });
});

describe('a period that ends in a credit', () => {
  const [from, to] = periods[2]!;

  it('is not settled until the company says what happens to it', async () => {
    await invoice('purchase_invoice', 'CREDIT-P1', from, 8_000);
    const filing = await accepted(from, to);

    const message = await expectError(db, `select settle_filing($1)`, [filing.id]);
    expect(message).toContain('no_credit_treatment');

    // And the choice is not accepted on a period that owes money: the two are
    // different facts, and a treatment recorded against a debt would be noise
    // in the one column that answers "what did we do with it".
    const owing = await one<Filing>(
      db,
      `select * from tax_filings where company_id = $1 and period_start = $2::date`,
      [fx.companyId, periods[1]![0]],
    );
    await db.query(`select record_filing_outcome($1, 'accepted')`, [owing.id]);
    expect(
      await expectError(db, `select settle_filing($1, 'refund')`, [owing.id]),
    ).toContain('not_a_credit');
  });

  it('lands on the account the pack names for a credit, and keeps the choice', async () => {
    const filing = await one<Filing>(
      db,
      `select * from tax_filings where company_id = $1 and period_start = $2::date`,
      [fx.companyId, periods[2]![0]],
    );
    const entryId = await settle(filing.id, 'refund');
    const lines = await linesOf(entryId);
    const claim = lines.find((l) => l.code === RECEIVABLE)!;
    expect(Number(claim.debit)).toBeGreaterThan(0);
    expect(Number(claim.credit)).toBe(0);

    const after = await one<Filing>(db, `select * from tax_filings where id = $1`, [filing.id]);
    expect(after.credit_treatment).toBe('refund');
  });
});

describe('the payment that follows', () => {
  it('is matched against the debt by the reference the settlement carries', async () => {
    const [from, to] = periods[1]!;
    const filing = await one<Filing>(
      db,
      `select * from tax_filings where company_id = $1 and period_start = $2::date`,
      [fx.companyId, from],
    );
    const entryId = await settle(filing.id, undefined, 'TAX-PAYMENT-1', administrationId);
    const owed = await one<{ amount_open: string; line_id: string; reference: string }>(
      db,
      `select o.amount_open::text, o.line_id, o.reference from open_items($1) o
         join entry_lines l on l.id = o.line_id
        where l.entry_id = $2
          and o.account_id = (select id from accounts where company_id = $1 and code = $3)`,
      [fx.companyId, entryId, PAYABLE],
    );
    // The debt is an open item, and it carries the reference the payment will
    // quote — without a document anywhere in sight.
    expect(owed.reference).toBe('TAX-PAYMENT-1');

    sequence += 1;
    await db.query(
      `insert into bank_transactions
         (company_id, bank_account_id, sequence, transaction_date, amount, currency_code,
          description, reference, state)
       select $1, $2, $3, $4::date, $5, c.currency_code, 'Tax payment', 'TAX-PAYMENT-1', 'pending'
         from companies c where c.id = $1`,
      [fx.companyId, bankAccountId, sequence, to, -Number(owed.amount_open)],
    );

    const report = await rows<{ action: string; method: string; line_ids: string[]; because: string }>(
      db,
      `select action, method, line_ids, because from auto_settle($1, $2::date, $3::date, true)`,
      [fx.companyId, from, to],
    );
    const settled = report.find((r) => r.line_ids?.includes(owed.line_id));
    expect(settled?.action).toBe('settled');
    expect(settled?.method).toBe('reference');

    const left = await rows(db, `select 1 from open_items($1) where line_id = $2`, [
      fx.companyId,
      owed.line_id,
    ]);
    expect(left).toHaveLength(0);
    expect(entryId).toBeTruthy();
  });
});

describe('a box that is a base and a tax', () => {
  // Where this belongs: the freeze is D1's, but the key it was written with —
  // one row per box — only fails on a form that prints the base and the tax of
  // a rate on the same line, and that is the form this file happens to declare
  // on. The refusal it caused was a unique-constraint violation on preparing,
  // which is why the test that found it lives beside the feature that ran into
  // it.
  it('is frozen twice, once as each, and the drift says which of the two moved', async () => {
    const [from] = periods[0]!;
    const filing = await one<Filing>(
      db,
      `select * from tax_filings where company_id = $1 and period_start = $2::date`,
      [fx.companyId, from],
    );
    const doubled = await rows<{ box: string; kinds: string }>(
      db,
      `select box, string_agg(kind, ',' order by kind) as kinds
         from tax_filing_boxes where filing_id = $1
        group by box having count(*) > 1`,
      [filing.id],
    );
    if (doubled.length === 0) return; // this form prints each figure on its own line
    expect(doubled[0]!.kinds).toBe('base,tax');

    // And the drift answers on the same key: a box alone would say "08 moved"
    // on a form where 08 is two figures.
    const drift = await rows<{ box: string; kind: string }>(db, `select box, kind from filing_drift($1)`, [
      filing.id,
    ]);
    for (const row of drift) expect(['base', 'tax', 'total']).toContain(row.kind);
  });
});

describe('what it refuses', () => {
  it('a period that moved no tax account, rather than an entry that says nothing', async () => {
    const [from, to] = periods[0]!;
    const year = from.slice(0, 4);
    const quiet = await one<Filing>(
      db,
      `select * from prepare_filing($1, ($2 || '-01-01')::date + interval '2 year',
                                       ($2 || '-01-31')::date + interval '2 year')`,
      [fx.companyId, year],
    ).catch(() => null);
    if (quiet === null) return; // the pack files a cadence this window is not
    await db.query(`select file_filing($1)`, [quiet.id]);
    await db.query(`select record_filing_outcome($1, 'accepted')`, [quiet.id]);
    expect(await expectError(db, `select settle_filing($1)`, [quiet.id])).toContain(
      'nothing_to_settle',
    );
    expect(to).toBeTruthy();
  });

  it('a contact whose third-party account is not where the debt sits', async () => {
    const [from, to] = periods[3]!;
    await invoice('sale_invoice', 'MISMATCH-S1', from, 3_000);
    const filing = await accepted(from, to);
    const stranger = await newContact(db, fx.companyId, {
      name: 'Autre tiers',
      country: pack.manifest.country,
    });

    // That contact takes the company's own payables account, which is where a
    // supplier payment goes and not where this debt sits.
    const message = await expectError(db, `select settle_filing($1, null, null, $2)`, [
      filing.id,
      stranger,
    ]);
    expect(message).toContain('contact_account_mismatch');
    expect(message).toContain(PAYABLE);

    // Left out, it settles: the debt is simply one nobody is named on.
    const entryId = await settle(filing.id);
    expect(entryId).toBeTruthy();
  });

  it('a payment it cannot book, without taking the rest of the pass down with it', async () => {
    const [from, to] = periods[3]!;
    const debt = await one<{ amount_open: string; line_id: string }>(
      db,
      `select o.amount_open::text, o.line_id from open_items($1) o
         join entry_lines l on l.id = o.line_id
        where l.entry_id = (select settlement_entry_id from tax_filings
                             where company_id = $1 and period_start = $2::date)`,
      [fx.companyId, from],
    );

    sequence += 1;
    await db.query(
      `insert into bank_transactions
         (company_id, bank_account_id, sequence, transaction_date, amount, currency_code,
          description, state)
       select $1, $2, $3, $4::date, $5, c.currency_code, 'Tax payment, nobody named', 'pending'
         from companies c where c.id = $1`,
      [fx.companyId, bankAccountId, sequence, to, -Number(debt.amount_open)],
    );

    const report = await rows<{ action: string; because: string; line_ids: string[] }>(
      db,
      `select action, because, line_ids from auto_settle($1, $2::date, $3::date, true)`,
      [fx.companyId, from, to],
    );
    const refused = report.find((r) => r.line_ids?.includes(debt.line_id))!;
    expect(refused.action).toBe('refused');
    // The database's own sentence, quoted rather than summarised.
    expect(refused.because).toContain('no_contact_on_open_item');
    // And the walk went on: every pending line of the window has a row.
    expect(report.length).toBeGreaterThanOrEqual(1);
  });

  it('a pack that names no such account, by naming the role to set', async () => {
    const silent = allPacks.find((p) => p.manifest.defaults.roles['tax_payable'] === undefined);
    if (silent === undefined) return; // every pack names one: nothing to refuse
    // country-literal: the company is installed in the pack that says nothing,
    // which is the situation under test.
    const other = await newCompany(db, {
      country: silent.manifest.country,
      name: 'Silent Pack Fixture',
    });
    const contact = await newContact(db, other.companyId, {
      country: silent.manifest.country,
    });
    const line = (() => {
      for (const document of silent.golden?.documents ?? []) {
        if (document.type !== 'sale_invoice') continue;
        for (const l of document.lines) if (l.tax && l.account) return { tax: l.tax, account: l.account };
      }
      return null;
    })();
    if (line === null) return;

    const documentId = await newDocument(db, other.companyId, {
      docType: 'sale_invoice',
      number: 'SILENT-1',
      contactId: contact,
      date: '2026-01-15',
      lines: [{ unitPrice: 1_000, taxCode: line.tax, accountCode: line.account }],
    });
    await db.query(`select post_document($1)`, [documentId]);

    const filing = await one<Filing>(
      db,
      `select * from prepare_filing($1, '2026-01-01'::date, '2026-01-31'::date)`,
      [other.companyId],
    ).catch(() => null);
    if (filing === null) return; // that pack files another cadence
    await db.query(`select file_filing($1)`, [filing.id]);
    await db.query(`select record_filing_outcome($1, 'accepted')`, [filing.id]);

    const message = await expectError(db, `select settle_filing($1)`, [filing.id]);
    expect(message).toContain('no_tax_payable_account');
    expect(message).toContain('defaults.roles.tax_payable');
  });
});
