/**
 * What is posted is undone in one gesture.
 *
 * The guards of `20260918161204` and `20260918161538` freeze a posted entry and
 * a posted document, and say how each is undone: by a reversal that names it,
 * by a credit note that names it. `reverse_entry()` and `cancel_document()` are
 * those two sentences as functions. What is held here:
 *
 *   * the happy path, read back from the ledger rather than from the answer:
 *     the mirror is in the same journal, under a number the counter drew, the
 *     two cancel out account by account, and they are matched;
 *   * what is undone does not move — its number, its entry, its lines, but for
 *     the two columns the matching writes;
 *   * every refusal, by name, and that a refusal writes nothing;
 *   * the date: the original's while its period is open, refused by name when
 *     it is not, and a date given explicitly is asked the question
 *     `post_entry()` asks;
 *   * the one way out of `posted` for a document, which is also the way the
 *     function takes: a hand that writes `cancelled` without the facts behind
 *     it is refused.
 *
 * Every call is made as an accountant of the company, under row level
 * security, the way a person or the MCP server makes it.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { Pack } from '../packages/cli/src/index.js';
import { asUser, freshDatabase, one, rows } from './helpers/db.js';
import { accountId, newCompany, newContact, newDocument, newUser } from './helpers/factory.js';
import { thirdPartyLine } from './helpers/golden-scenario.js';
import { packWhere, roleOf } from './helpers/packs.js';

type PackTax = Pack['taxes'][number];
const charged = (pack: Pack, scope: 'sale' | 'purchase'): PackTax[] =>
  pack.taxes
    .filter(
      (tax) =>
        tax.scope === scope && tax.treatment === 'domestic' && tax.amount_type === 'percent' &&
        tax.rate > 0 && tax.valid_to === null && !tax.price_include && !tax.cash_basis,
    )
    .sort((a, b) => b.rate - a.rate);

let db: PGlite;
let pack: Pack;
let companyId: string;
let ownerId: string;
let accountant: string;
let viewer: string;
let customer: string;
let supplier: string;
let journalId: string;
let receivable: string;
let sales: string;
let bank: string;
let saleTax: PackTax;
let purchaseTax: PackTax;
let yearStart: string;

beforeAll(async () => {
  pack = packWhere('charges a tax on an ordinary sale and an ordinary purchase', (p) =>
    charged(p, 'sale').length > 0 && charged(p, 'purchase').length > 0 &&
    ['receivable', 'sales', 'purchase', 'bank'].every((role) => typeof p.manifest.defaults.roles[role] === 'string'),
  );
  [saleTax] = charged(pack, 'sale') as [PackTax];
  [purchaseTax] = charged(pack, 'purchase') as [PackTax];

  db = await freshDatabase();
  ({ companyId, ownerId } = await newCompany(db, { country: pack.manifest.country, name: 'Undone' }));
  await db.query(`insert into auth.users (id, email) values ($1, 'owner@undo.test') on conflict do nothing`, [ownerId]);
  accountant = await newUser(db, 'accountant@undo.test');
  viewer = await newUser(db, 'viewer@undo.test');
  await db.query(
    `insert into company_members (company_id, user_id, role) values ($1, $2, 'accountant'), ($1, $3, 'viewer')`,
    [companyId, accountant, viewer],
  );
  journalId = (await one<{ id: string }>(db, `select miscellaneous_journal_id as id from companies where id = $1`, [companyId])).id;
  receivable = await accountId(db, companyId, roleOf(pack, 'receivable'));
  sales = await accountId(db, companyId, roleOf(pack, 'sales'));
  bank = await accountId(db, companyId, roleOf(pack, 'bank'));
  customer = await newContact(db, companyId, { country: pack.manifest.country });
  supplier = await newContact(db, companyId, { name: 'A supplier', type: 'supplier', country: pack.manifest.country });
  yearStart = (await one<{ d: string }>(
    db,
    `select min(start_date)::text as d from fiscal_years where company_id = $1`,
    [companyId],
  )).d;
}, 180_000);

afterAll(async () => {
  await db.close();
});

const day = (offset: number): string => {
  const date = new Date(`${yearStart}T00:00:00Z`);
  date.setUTCDate(date.getUTCDate() + offset);
  return date.toISOString().slice(0, 10);
};

/** A posted entry of two lines keyed by the accountant: a receivable against a sale. */
async function entry(options: { date?: string; debit?: string; credit?: string; amount?: number } = {}): Promise<string> {
  return asUser(db, accountant, async () => {
    const row = await one<{ id: string }>(
      db,
      `insert into entries (company_id, journal_id, entry_date, description)
       values ($1, $2, $3, 'By hand') returning id`,
      [companyId, journalId, options.date ?? day(40)],
    );
    await db.query(
      `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit, contact_id)
       values ($1, $2, $3, 10, 'Debit', $5, 0, $6), ($1, $2, $4, 20, 'Credit', 0, $5, null)`,
      [row.id, companyId, options.debit ?? receivable, options.credit ?? sales, options.amount ?? 100, customer],
    );
    await db.query(`select post_entry($1)`, [row.id]);
    return row.id;
  });
}

/** A posted invoice of two lines, as the accountant books it. */
async function invoice(options: { purchase?: boolean; date?: string } = {}): Promise<string> {
  const tax = options.purchase === true ? purchaseTax : saleTax;
  const account = roleOf(pack, options.purchase === true ? 'purchase' : 'sales');
  const id = await newDocument(db, companyId, {
    docType: options.purchase === true ? 'purchase_invoice' : 'sale_invoice',
    contactId: options.purchase === true ? supplier : customer,
    date: options.date ?? day(60),
    lines: [
      { name: 'First', unitPrice: 100, taxCode: tax.code, accountCode: account },
      { name: 'Second', quantity: 3, unitPrice: 33.33, taxCode: tax.code, accountCode: account },
    ],
  });
  await asUser(db, accountant, () => db.query(`select post_document($1)`, [id]));
  return id;
}

const reverse = (id: string, date: string | null = null) =>
  asUser(db, accountant, () =>
    one<{ id: string; number: string; entry_date: string; reversed_entry_id: string; state: string; journal_id: string }>(
      db,
      `select id, number, entry_date::text, reversed_entry_id, state, journal_id from reverse_entry($1, $2::date)`,
      [id, date],
    ),
  );

const cancel = (id: string, date: string | null = null) =>
  asUser(db, accountant, () =>
    one<Record<string, unknown>>(
      db,
      `select id, doc_type, number, state, payment_state, reversed_document_id, entry_id,
              document_date::text, amount_untaxed::text, amount_tax::text, amount_total::text,
              amount_residual::text, currency_code, contact_id
         from cancel_document($1, $2::date)`,
      [id, date],
    ),
  );

/** The refusal a call made as `who` gets, in its own words; the call is rolled back either way. */
async function refusalOf(sql: string, params: unknown[], who: string = accountant): Promise<string> {
  await db.exec('begin');
  try {
    await db.query(`select set_config('ekwo.installing', '', true), set_config('request.jwt.claims', $1, true)`, [
      JSON.stringify({ sub: who, role: 'authenticated' }),
    ]);
    await db.exec('set local role authenticated');
    return await db.query(sql, params).then(
      () => 'accepted',
      (error: Error) => error.message,
    );
  } finally {
    await db.exec('rollback');
  }
}

/** An entry as it stands, less the clock and what the matching writes. */
const frozen = async (entryId: string) => ({
  entry: await one(db, `select to_jsonb(e) - 'updated_at' as row from entries e where id = $1`, [entryId]),
  lines: await rows(
    db,
    `select to_jsonb(l) - 'updated_at' - 'matched_amount' - 'matching_number' as row
       from entry_lines l where entry_id = $1 order by sequence`,
    [entryId],
  ),
});

/** The balance of every account the given entries touch, summed across them. */
const netByAccount = (entryIds: string[]) =>
  rows<{ account_id: string; net: string }>(
    db,
    `select account_id, sum(debit - credit)::text as net
       from entry_lines where entry_id = any($1::uuid[]) group by account_id`,
    [entryIds],
  );

const entryOf = async (documentId: string): Promise<string> =>
  (await one<{ entry_id: string }>(db, `select entry_id from documents where id = $1`, [documentId])).entry_id;

// ---------------------------------------------------------------------------
// reverse_entry
// ---------------------------------------------------------------------------

describe('reverse_entry', () => {
  it('writes the mirror in the same journal, posts it, and matches the two', async () => {
    const original = await entry();
    const before = await frozen(original);
    const reversal = await reverse(original);

    expect(reversal.state).toBe('posted');
    expect(reversal.reversed_entry_id).toBe(original);
    expect(reversal.journal_id).toBe(journalId);
    expect(reversal.entry_date).toBe(day(40));
    expect(reversal.number).not.toBe((before.entry as { row: { number: string } }).row.number);

    // Every line on its account, the other side.
    const mirrored = await rows<{ sequence: number; account_id: string; debit: string; credit: string }>(
      db,
      `select sequence, account_id, debit::text, credit::text from entry_lines where entry_id = $1 order by sequence`,
      [reversal.id],
    );
    expect(mirrored).toEqual([
      { sequence: 10, account_id: receivable, debit: '0.00', credit: '100.00' },
      { sequence: 20, account_id: sales, debit: '100.00', credit: '0.00' },
    ]);

    // The trial balance of the two is nil, account by account.
    const net = await netByAccount([original, reversal.id]);
    expect(net.length).toBe(2);
    expect(net.every((row) => Number(row.net) === 0)).toBe(true);

    // The receivable is matched in full, on both sides, under one letter.
    const matched = await rows<{ matched_amount: string; matching_number: string | null }>(
      db,
      `select matched_amount::text, matching_number from entry_lines
        where entry_id in ($1, $2) and account_id = $3`,
      [original, reversal.id, receivable],
    );
    expect(matched.map((row) => row.matched_amount)).toEqual(['100.00', '100.00']);
    expect(new Set(matched.map((row) => row.matching_number)).size).toBe(1);
    expect(matched[0]?.matching_number).not.toBeNull();

    // The original is what it was: its number, its state, its lines.
    expect(await frozen(original)).toEqual(before);

    // And the audit trail says what happened, in its own word.
    const acts = await rows<{ action: string }>(
      db,
      `select action from audit_log where table_name = 'entries' and record_id = $1`,
      [reversal.id],
    );
    expect(acts.map((row) => row.action)).toContain('entry_reversed');
  });

  it('books on the date it is given, and keeps a box and an analytic split on the mirror', async () => {
    const original = await entry({ date: day(45) });
    const axis = await one<{ id: string }>(
      db,
      `insert into analytic_axes (company_id, code, name) values ($1, 'AX', 'Axis') returning id`,
      [companyId],
    );
    {
      const value = await one<{ id: string }>(
        db,
        `insert into analytic_values (company_id, axis_id, code, name) values ($1, $2, 'V1', 'Value') returning id`,
        [companyId, axis.id],
      );
      await db.query(
        `insert into entry_line_analytics (company_id, entry_line_id, analytic_value_id, percentage, amount)
         select company_id, id, $2, 100, 100 from entry_lines where entry_id = $1 and sequence = 20`,
        [original, value.id],
      );
    }
    const reversal = await reverse(original, day(50));
    expect(reversal.entry_date).toBe(day(50));
    {
      const split = await rows(
        db,
        `select x.percentage::text from entry_line_analytics x join entry_lines l on l.id = x.entry_line_id
          where l.entry_id = $1 and l.sequence = 20`,
        [reversal.id],
      );
      expect(split).toEqual([{ percentage: '100.000' }]);
    }
  });

  it('refuses what it cannot undo, by name, and writes nothing', async () => {
    const count = async () => (await one<{ n: number }>(db, `select count(*)::int as n from entries where company_id = $1`, [companyId])).n;
    const at = await count();

    // A draft.
    const draft = await asUser(db, accountant, () =>
      one<{ id: string }>(
        db,
        `insert into entries (company_id, journal_id, entry_date, description) values ($1, $2, $3, 'Draft') returning id`,
        [companyId, journalId, day(40)],
      ),
    );
    expect(await refusalOf(`select reverse_entry($1)`, [draft.id])).toMatch(/^entry_not_posted\b/);

    // Twice, and a reversal of a reversal.
    const original = await entry();
    const reversal = await reverse(original);
    expect(await refusalOf(`select reverse_entry($1)`, [original])).toMatch(/^entry_already_reversed\b/);
    expect(await refusalOf(`select reverse_entry($1)`, [reversal.id])).toMatch(/^entry_is_a_reversal\b/);

    // The entry of a document: its document is what is undone.
    const invoiceId = await invoice();
    expect(await refusalOf(`select reverse_entry($1)`, [await entryOf(invoiceId)])).toMatch(/^entry_of_a_document\b.*cancel_document/);

    // A matched entry: the matching is undone first.
    const matchedOne = await entry();
    const settlement = await entry({ debit: bank, credit: receivable });
    await asUser(db, accountant, async () => {
      const a = await one<{ id: string }>(db, `select id from entry_lines where entry_id = $1 and account_id = $2`, [matchedOne, receivable]);
      const b = await one<{ id: string }>(db, `select id from entry_lines where entry_id = $1 and account_id = $2`, [settlement, receivable]);
      await db.query(`select reconcile($1, $2)`, [a.id, b.id]);
    });
    expect(await refusalOf(`select reverse_entry($1)`, [matchedOne])).toMatch(/^entry_matched\b.*unreconcile/);

    // An entry some other row owns.
    const owned = await entry({ debit: bank, credit: sales });
    const bankAccount = await one<{ id: string }>(
      db,
      `insert into bank_accounts (company_id, name, iban, account_id, journal_id)
       values ($1, 'Bank', 'XX00UNDO0001', $2, $3) returning id`,
      [companyId, bank, journalId],
    );
    await db.query(
      `insert into bank_transactions (company_id, bank_account_id, sequence, transaction_date, amount, currency_code, entry_id)
       select $1, $2, 1, $3, 100, currency_code, $4 from companies where id = $1`,
      [companyId, bankAccount.id, day(40), owned],
    );
    expect(await refusalOf(`select reverse_entry($1)`, [owned])).toMatch(/^entry_belongs_elsewhere\b.*bank transaction/);

    // Nothing unknown is reversed either.
    expect(await refusalOf(`select reverse_entry(gen_random_uuid())`, [])).toMatch(/^unknown_entry\b/);

    // The refusals wrote nothing: what exists is what the setup wrote.
    expect(await count()).toBe(at + 1 /* draft */ + 2 /* original, reversal */ + 1 /* invoice */ + 3);
  });

  it('refuses the entries of a close and of an opening, and names what undoes them', async () => {
    for (const kind of ['closing', 'appropriation', 'opening']) {
      const id = await asUser(db, accountant, async () => {
        const row = await one<{ id: string }>(
          db,
          `insert into entries (company_id, journal_id, entry_date, description) values ($1, $2, $3, 'Year end') returning id`,
          [companyId, journalId, day(40)],
        );
        await db.query(
          `insert into entry_lines (entry_id, company_id, account_id, sequence, debit, credit)
           values ($1, $2, $3, 10, 5, 0), ($1, $2, $4, 20, 0, 5)`,
          [row.id, companyId, sales, bank],
        );
        return row.id;
      });
      // The kind is written by the functions of a year end, and by nothing
      // else; the test stands in for them the way they do it.
      await db.exec(`select set_config('ekwo.year_end_entry', 'on', false)`);
      await db.query(`update entries set kind = $2 where id = $1`, [id, kind]);
      await db.exec(`select set_config('ekwo.year_end_entry', '', false)`);
      await asUser(db, accountant, () => db.query(`select post_entry($1)`, [id]));

      const refused = await refusalOf(`select reverse_entry($1)`, [id]);
      expect(refused, kind).toMatch(/^entry_of_a_year_end\b/);
      if (kind !== 'opening') expect(refused, kind).toMatch(/reopen_fiscal_year/);
    }
  });

  it('takes the original date only while its period is open, and asks for one otherwise', async () => {
    const original = await entry({ date: day(10) });
    await db.query(`update companies set lock_date = $2 where id = $1`, [companyId, day(20)]);
    try {
      expect(await refusalOf(`select reverse_entry($1)`, [original])).toMatch(/^reversal_date_needed\b.*period_locked/);
      // A date given is asked the same question post_entry() asks.
      expect(await refusalOf(`select reverse_entry($1, $2::date)`, [original, day(15)])).toMatch(/^period_locked\b/);
      expect(await refusalOf(`select reverse_entry($1, $2::date)`, [original, day(5)])).toMatch(/^reversal_before_original\b/);

      const reversal = await reverse(original, day(25));
      expect(reversal.entry_date).toBe(day(25));
      const net = await netByAccount([original, reversal.id]);
      expect(net.every((row) => Number(row.net) === 0)).toBe(true);
    } finally {
      await db.query(`update companies set lock_date = null where id = $1`, [companyId]);
    }
  });

  it('is refused to a member who may only read, and to a key that may post but not match', async () => {
    const original = await entry();
    // Row level security lets a viewer read the entry and not lock it for a
    // change, so to them it is not there.
    expect(await refusalOf(`select reverse_entry($1)`, [original], viewer)).toMatch(/^(not_allowed|unknown_entry)\b/);

    // A key that may post and not match; and one that may match and not read
    // the chart, which is where "reconcilable" is written — the second would
    // otherwise find no line to match and leave the two open without a word.
    const poster = ['entries.read', 'entries.write', 'entries.post', 'contacts.read'];
    for (const [capabilities, refused] of [
      [poster, /^not_allowed\b.*reconcile\.write/],
      [[...poster, 'reconcile.write'], /^not_allowed\b.*settings\.read/],
    ] as const) {
      const key = await asUser(db, ownerId, () =>
        one<{ secret: string }>(db, `select * from create_api_key($1, 'Poster', $2::jsonb)`, [
          companyId,
          JSON.stringify(capabilities),
        ]),
      );
      await db.exec('begin');
      try {
        await db.exec(`select set_config('ekwo.installing', '', true), set_config('request.jwt.claims', '', true)`);
        await db.exec('set local role authenticated');
        await db.query(`select * from use_api_key($1)`, [key.secret]);
        const message = await db.query(`select reverse_entry($1)`, [original]).then(
          () => 'accepted',
          (error: Error) => error.message,
        );
        expect(message).toMatch(refused);
      } finally {
        await db.exec('rollback');
      }
    }
    expect(await rows(db, `select 1 from entries where reversed_entry_id = $1`, [original])).toEqual([]);
  });
});

// ---------------------------------------------------------------------------
// cancel_document
// ---------------------------------------------------------------------------

describe('cancel_document', () => {
  it('issues the credit note of a sale invoice, matches the two and cancels the invoice', async () => {
    const invoiceId = await invoice();
    const original = await one<Record<string, unknown>>(
      db,
      `select number, entry_id, amount_untaxed::text, amount_tax::text, amount_total::text, currency_code, contact_id
         from documents where id = $1`,
      [invoiceId],
    );
    const ledgerBefore = await frozen(original['entry_id'] as string);

    const credit = await cancel(invoiceId);
    expect(credit).toMatchObject({
      doc_type: 'sale_credit_note',
      state: 'posted',
      reversed_document_id: invoiceId,
      document_date: day(60),
      amount_untaxed: original['amount_untaxed'],
      amount_tax: original['amount_tax'],
      amount_total: original['amount_total'],
      currency_code: original['currency_code'],
      contact_id: customer,
      payment_state: 'paid',
      amount_residual: '0.00',
    });
    expect(credit['number']).not.toBeNull();
    expect(credit['number']).not.toBe(original['number']);

    // The same lines, the same taxes and accounts.
    const lines = (id: string) =>
      rows(
        db,
        `select sequence, name, quantity::text, unit_price::text, tax_id, account_id, amount_untaxed::text
           from document_lines where document_id = $1 order by sequence`,
        [id],
      );
    expect(await lines(credit['id'] as string)).toEqual(await lines(invoiceId));

    // The invoice: cancelled, reversed, nothing owed, its number and entry as they were.
    expect(
      await one(db, `select state, payment_state, amount_residual::text, number, entry_id from documents where id = $1`, [invoiceId]),
    ).toEqual({
      state: 'cancelled',
      payment_state: 'reversed',
      amount_residual: '0.00',
      number: original['number'],
      entry_id: original['entry_id'],
    });
    expect(await frozen(original['entry_id'] as string)).toEqual(ledgerBefore);

    // The two entries cancel out, account by account.
    const net = await netByAccount([original['entry_id'] as string, credit['entry_id'] as string]);
    expect(net.length).toBeGreaterThan(2);
    expect(net.every((row) => Number(row.net) === 0)).toBe(true);

    // And the correction reaches the declaration: the credit note books its
    // boxes, in whichever boxes the pack gives a credit note.
    const declared = await one<{ n: number }>(
      db,
      `select count(*)::int as n from entry_lines where entry_id = $1 and declaration_box is not null`,
      [credit['entry_id']],
    );
    expect(declared.n).toBeGreaterThan(0);

    const acts = await rows<{ action: string; record_id: string }>(
      db,
      `select action, record_id from audit_log where table_name = 'documents' and record_id in ($1, $2) order by id`,
      [invoiceId, credit['id']],
    );
    expect(acts).toEqual(
      expect.arrayContaining([
        { action: 'document_posted', record_id: credit['id'] },
        { action: 'document_cancelled', record_id: invoiceId },
      ]),
    );
  });

  it('issues the credit note of a purchase invoice the same way', async () => {
    const invoiceId = await invoice({ purchase: true });
    const credit = await cancel(invoiceId);
    expect(credit['doc_type']).toBe('purchase_credit_note');
    const net = await netByAccount([await entryOf(invoiceId), credit['entry_id'] as string]);
    expect(net.every((row) => Number(row.net) === 0)).toBe(true);
    expect(await one(db, `select state, payment_state from documents where id = $1`, [invoiceId])).toEqual({
      state: 'cancelled',
      payment_state: 'reversed',
    });
  });

  it('refuses what it cannot cancel, by name, and writes nothing', async () => {
    const count = async () => (await one<{ n: number }>(db, `select count(*)::int as n from documents where company_id = $1`, [companyId])).n;

    const draft = await newDocument(db, companyId, {
      docType: 'sale_invoice',
      contactId: customer,
      date: day(60),
      lines: [{ unitPrice: 10, taxCode: saleTax.code, accountCode: roleOf(pack, 'sales') }],
    });
    const at = await count();
    expect(await refusalOf(`select cancel_document($1)`, [draft])).toMatch(/^document_not_posted\b/);

    const cancelled = await invoice();
    const credit = await cancel(cancelled);
    const after = await count();
    expect(await refusalOf(`select cancel_document($1)`, [cancelled])).toMatch(/^document_already_cancelled\b/);
    expect(await refusalOf(`select cancel_document($1)`, [credit['id']])).toMatch(/^document_is_a_credit_note\b/);

    // Paid in part: the payment is unmatched first, by whoever decides it.
    const paid = await invoice();
    const payment = await entry({ debit: bank, credit: receivable, amount: 50 });
    await asUser(db, accountant, async () => {
      const line = await one<{ id: string }>(db, `select id from entry_lines where entry_id = $1 and account_id = $2`, [payment, receivable]);
      await db.query(`select reconcile($1, $2)`, [await thirdPartyLine(db, 'document_id', paid), line.id]);
    });
    expect(await refusalOf(`select cancel_document($1)`, [paid])).toMatch(/^document_paid\b.*unreconcile/);

    // Already credited by hand: cancelling would credit it twice.
    const credited = await invoice();
    const byHand = await newDocument(db, companyId, {
      docType: 'sale_credit_note',
      contactId: customer,
      date: day(60),
      lines: [{ unitPrice: 10, taxCode: saleTax.code, accountCode: roleOf(pack, 'sales') }],
    });
    await asUser(db, accountant, async () => {
      await db.query(`update documents set reversed_document_id = $2 where id = $1`, [byHand, credited]);
      await db.query(`select post_document($1)`, [byHand]);
    });
    expect(await refusalOf(`select cancel_document($1)`, [credited])).toMatch(/^document_already_credited\b/);

    expect(await refusalOf(`select cancel_document(gen_random_uuid())`, [])).toMatch(/^unknown_document\b/);
    expect(await refusalOf(`select cancel_document($1)`, [paid], viewer)).toMatch(/^(not_allowed|unknown_document)\b/);

    // Two invoices and a credit note by hand were written by the setup after
    // `after`; the refusals wrote nothing.
    expect(await count()).toBe(after + 3);
    expect(after).toBe(at + 2);
  });

  it('takes the invoice date only while its period is open, and asks for one otherwise', async () => {
    const invoiceId = await invoice({ date: day(12) });
    await db.query(`update companies set lock_date = $2 where id = $1`, [companyId, day(20)]);
    try {
      expect(await refusalOf(`select cancel_document($1)`, [invoiceId])).toMatch(/^reversal_date_needed\b/);
      expect(await refusalOf(`select cancel_document($1, $2::date)`, [invoiceId, day(18)])).toMatch(/^period_locked\b/);
      expect(await refusalOf(`select cancel_document($1, $2::date)`, [invoiceId, day(2)])).toMatch(/^reversal_before_original\b/);

      const credit = await cancel(invoiceId, day(30));
      expect(credit['document_date']).toBe(day(30));
      expect((await one<{ entry_date: string }>(db, `select entry_date::text from entries where id = $1`, [credit['entry_id']])).entry_date).toBe(day(30));
      expect(await one(db, `select state, payment_state from documents where id = $1`, [invoiceId])).toEqual({
        state: 'cancelled',
        payment_state: 'reversed',
      });
    } finally {
      await db.query(`update companies set lock_date = null where id = $1`, [companyId]);
    }
  });
});

// ---------------------------------------------------------------------------
// The way out of `posted`, by hand
// ---------------------------------------------------------------------------

describe('a posted document becomes cancelled on facts, not on a word', () => {
  it('refuses cancelled keyed by hand on an invoice nothing credits', async () => {
    const invoiceId = await invoice();
    expect(await refusalOf(`update documents set state = 'cancelled' where id = $1`, [invoiceId])).toMatch(/^document_cancelled_by_hand\b/);
    // Nor for the installer: the guard asks nobody who they are.
    await expect(db.query(`update documents set state = 'cancelled' where id = $1`, [invoiceId])).rejects.toThrow(/document_cancelled_by_hand/);
    // And back to draft stays refused, as before.
    expect(await refusalOf(`update documents set state = 'draft' where id = $1`, [invoiceId])).toMatch(/^document_posted\b/);
  });

  it('refuses it while the credit note is posted but does not settle the invoice', async () => {
    const invoiceId = await invoice();
    const lines = await rows<{ name: string; quantity: string; unit_price: string }>(
      db,
      `select name, quantity::float as quantity, unit_price::float as unit_price from document_lines where document_id = $1 order by sequence`,
      [invoiceId],
    );
    const creditId = await newDocument(db, companyId, {
      docType: 'sale_credit_note',
      contactId: customer,
      date: day(60),
      lines: lines.map((l) => ({ name: l.name, quantity: Number(l.quantity), unitPrice: Number(l.unit_price), taxCode: saleTax.code, accountCode: roleOf(pack, 'sales') })),
    });
    await asUser(db, accountant, async () => {
      await db.query(`update documents set reversed_document_id = $2 where id = $1`, [creditId, invoiceId]);
      await db.query(`select post_document($1)`, [creditId]);
    });
    // Unmatched: the invoice is still owed on the ledger.
    expect(await refusalOf(`update documents set state = 'cancelled' where id = $1`, [invoiceId])).toMatch(/^document_cancelled_by_hand\b/);

    // Matched against it in full: those are the facts cancel_document() leaves,
    // and they are what is judged, whoever writes the statement.
    await asUser(db, accountant, async () => {
      await db.query(`select match_reversal($1, $2)`, [await entryOf(invoiceId), await entryOf(creditId)]);
      // Not with anything else moved in the same statement.
      expect(await refusalOf(`update documents set state = 'cancelled', note = 'why' where id = $1`, [invoiceId])).toMatch(/^document_posted\b/);
      await db.query(`update documents set state = 'cancelled' where id = $1`, [invoiceId]);
    });
    expect(await one(db, `select state, payment_state from documents where id = $1`, [invoiceId])).toEqual({
      state: 'cancelled',
      payment_state: 'reversed',
    });
  });
});

// ---------------------------------------------------------------------------
// A tax that falls due on collection
// ---------------------------------------------------------------------------

describe('cancelling an invoice whose tax falls due on collection', () => {
  it('leaves nothing waiting and nothing declared', async () => {
    const waiting = packWhere('taxes on collection', (p) => p.taxes.some((t) => t.cash_basis && t.scope === 'sale'));
    const tax = waiting.taxes.find((t) => t.cash_basis && t.scope === 'sale') as PackTax;
    const { companyId: company, ownerId: owner } = await newCompany(db, { country: waiting.manifest.country, name: 'Collected' });
    const client = await newContact(db, company, { country: waiting.manifest.country });
    const id = await newDocument(db, company, {
      docType: 'sale_invoice',
      contactId: client,
      date: '2026-03-10',
      lines: [{ unitPrice: 1000, taxCode: tax.code, accountCode: roleOf(waiting, 'sales') }],
    });
    await db.query(`select post_document($1)`, [id]);
    const credit = await asUser(db, owner, () =>
      one<{ id: string; entry_id: string }>(db, `select id, entry_id from cancel_document($1)`, [id]),
    );

    // Every entry either document wrote — its own and the transfers the
    // matching made due — nets to nothing, the account the tax waits on
    // included.
    const all = await rows<{ net: string }>(
      db,
      `select sum(l.debit - l.credit)::text as net
         from entry_lines l join entries e on e.id = l.entry_id
        where e.document_id in ($1, $2) group by l.account_id`,
      [id, credit.id],
    );
    expect(all.length).toBeGreaterThan(0);
    expect(all.every((row) => Number(row.net) === 0)).toBe(true);
    expect(await one(db, `select state, payment_state from documents where id = $1`, [id])).toEqual({
      state: 'cancelled',
      payment_state: 'reversed',
    });
  });
});
