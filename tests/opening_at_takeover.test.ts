/**
 * An opening on the day the books were taken over, whose open items are
 * documents (issue #92).
 *
 * A company that changes software on 1 July arrives with the trial balance of
 * 30 June — the income and expense of the half-year included — and the list
 * of invoices still open, each with its number, its payment reference and its
 * due date. `opening_balance()` takes the day and the list: the balance is
 * the opening entry of that day, and each item a posted document on the
 * opening journal, which the statement matching finds the way it finds an
 * invoice issued here.
 *
 * Every write is made as the owner, signed in, under `authenticated`: an
 * opening only the database owner could make is an opening nobody can make.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, type Fixture } from './helpers/factory.js';

let db: PGlite;
let fx: Fixture;
let year: string;
let customerA: string;
let customerB: string;
let supplier: string;

beforeEach(async () => {
  db = await freshDatabase();
  fx = await newCompany(db, { name: 'Taken Over' });
  year = (
    await one<{ id: string }>(db, `select id from fiscal_years where company_id = $1`, [fx.companyId])
  ).id;
  customerA = await newContact(db, fx.companyId, { name: 'Atelier Sirocco' });
  customerB = await newContact(db, fx.companyId, { name: 'Brume et Fils' });
  supplier = await newContact(db, fx.companyId, { name: 'Verger du Moulin', type: 'supplier' });
});

afterEach(async () => {
  await db.close();
});

/** The trial balance of 30 June, as the previous system printed it. */
const BALANCE = [
  { account_code: '550000', debit: '40000.00' },
  { account_code: '400000', debit: '3630.00', label: 'Customers' },
  { account_code: '440000', credit: '605.00', label: 'Suppliers' },
  { account_code: '610000', debit: '15000.00' },
  { account_code: '700000', credit: '50000.00' },
  { account_code: '100000', credit: '8025.00' },
];

function items(): Record<string, unknown>[] {
  return [
    {
      doc_type: 'sale_invoice', number: 'F2026-0101', contact_id: customerA, amount: '1210.00',
      document_date: '2026-05-15', due_date: '2026-07-15', payment_reference: '+++090/9337/55493+++',
    },
    {
      doc_type: 'sale_invoice', number: 'F2026-0102', contact_id: customerB, amount: '2420.00',
      document_date: '2026-06-20', due_date: '2026-07-20', payment_reference: '+++123/4567/89002+++',
    },
    {
      doc_type: 'purchase_invoice', number: 'ACH-0077', contact_id: supplier, amount: '605.00',
      document_date: '2026-06-10', due_date: '2026-07-10', supplier_reference: 'VM-5521',
      payment_reference: 'VM-5521',
    },
  ];
}

async function open(
  options: { date?: string; lines?: unknown[]; items?: unknown[] } = {},
): Promise<string> {
  return asUser(db, fx.ownerId, async () =>
    (
      await one<{ opening_balance: string }>(
        db,
        `select opening_balance($1, $2, $3::jsonb, true, $4::date, $5::jsonb)`,
        [
          fx.companyId,
          year,
          JSON.stringify(options.lines ?? BALANCE),
          options.date ?? '2026-07-01',
          JSON.stringify(options.items ?? items()),
        ],
      )
    ).opening_balance,
  );
}

async function refusal(options: { date?: string; lines?: unknown[]; items?: unknown[] }): Promise<string> {
  return asUser(db, fx.ownerId, () =>
    expectError(db, `select opening_balance($1, $2, $3::jsonb, true, $4::date, $5::jsonb)`, [
      fx.companyId,
      year,
      JSON.stringify(options.lines ?? BALANCE),
      options.date ?? '2026-07-01',
      JSON.stringify(options.items ?? items()),
    ]),
  );
}

async function balances(from: string, to: string): Promise<{ code: string; balance: string }[]> {
  return rows(
    db,
    `select account_code as code, closing_balance::text as balance
       from trial_balance($1, $2::date, $3::date)
      where closing_balance <> 0
      order by account_code`,
    [fx.companyId, from, to],
  );
}

describe('an opening on the day the books were taken over', () => {
  it('is dated on that day, and leaves the receivable and the payable to the items', async () => {
    const entryId = await open();

    const entry = await one<{ entry_date: string; kind: string; state: string; journal: string }>(
      db,
      `select e.entry_date::text, e.kind::text, e.state::text, j.journal_type::text as journal
         from entries e join journals j on j.id = e.journal_id where e.id = $1`,
      [entryId],
    );
    expect(entry).toEqual({ entry_date: '2026-07-01', kind: 'opening', state: 'posted', journal: 'opening' });

    // The two lines the items carry wait on the suspense account.
    const lines = await rows<{ code: string; debit: string; credit: string; contact_id: string | null }>(
      db,
      `select a.code, l.debit::text, l.credit::text, l.contact_id
         from entry_lines l join accounts a on a.id = l.account_id
        where l.entry_id = $1 order by l.sequence`,
      [entryId],
    );
    expect(lines.map((l) => l.code)).toEqual(['550000', '499000', '499000', '610000', '700000', '100000']);
    expect(lines[1]).toMatchObject({ debit: '3630.00', credit: '0.00', contact_id: null });
    expect(lines[2]).toMatchObject({ debit: '0.00', credit: '605.00', contact_id: null });
  });

  it('makes each open item a posted document with its number, reference and dates', async () => {
    await open();

    const documents = await rows<Record<string, string | null>>(
      db,
      `select d.doc_type::text, d.number, d.payment_reference, d.supplier_reference,
              d.document_date::text, d.accounting_date::text, d.due_date::text,
              d.state::text, d.amount_total::text, d.amount_tax::text, d.payment_state::text,
              j.journal_type::text as journal
         from documents d join journals j on j.id = d.journal_id
        where d.company_id = $1 order by d.number`,
      [fx.companyId],
    );
    expect(documents).toEqual([
      {
        doc_type: 'purchase_invoice', number: 'ACH-0077', payment_reference: 'VM-5521', supplier_reference: 'VM-5521',
        document_date: '2026-06-10', accounting_date: '2026-07-01', due_date: '2026-07-10',
        state: 'posted', amount_total: '605.00', amount_tax: '0.00', payment_state: 'not_paid', journal: 'opening',
      },
      {
        doc_type: 'sale_invoice', number: 'F2026-0101', payment_reference: '+++090/9337/55493+++', supplier_reference: null,
        document_date: '2026-05-15', accounting_date: '2026-07-01', due_date: '2026-07-15',
        state: 'posted', amount_total: '1210.00', amount_tax: '0.00', payment_state: 'not_paid', journal: 'opening',
      },
      {
        doc_type: 'sale_invoice', number: 'F2026-0102', payment_reference: '+++123/4567/89002+++', supplier_reference: null,
        document_date: '2026-06-20', accounting_date: '2026-07-01', due_date: '2026-07-20',
        state: 'posted', amount_total: '2420.00', amount_tax: '0.00', payment_state: 'not_paid', journal: 'opening',
      },
    ]);

    // Its entry: the receivable of its customer, due when the invoice said,
    // against the suspense account — no revenue, no tax, nothing re-booked.
    const ledger = await rows<{ code: string; debit: string; credit: string; contact_id: string | null; due: string | null; tax: boolean }>(
      db,
      `select a.code, l.debit::text, l.credit::text, l.contact_id, l.date_maturity::text as due,
              l.tax_id is not null or l.declaration_box is not null as tax
         from documents d
         join entry_lines l on l.entry_id = d.entry_id
         join accounts a on a.id = l.account_id
        where d.number = 'F2026-0101' and d.company_id = $1
        order by l.debit`,
      [fx.companyId],
    );
    expect(ledger).toEqual([
      { code: '499000', debit: '0.00', credit: '1210.00', contact_id: null, due: null, tax: false },
      { code: '400000', debit: '1210.00', credit: '0.00', contact_id: customerA, due: '2026-07-15', tax: false },
    ]);
  });

  it('reads on either side of the day: nothing before it, the previous figures from it', async () => {
    await open();

    expect(await balances('2026-01-01', '2026-06-30')).toEqual([]);
    const after = [
      { code: '100000', balance: '-8025.00' },
      { code: '400000', balance: '3630.00' },
      { code: '440000', balance: '-605.00' },
      { code: '550000', balance: '40000.00' },
      { code: '610000', balance: '15000.00' },
      { code: '700000', balance: '-50000.00' },
    ];
    // The suspense account comes out at nothing, so it is not in the list.
    expect(await balances('2026-01-01', '2026-12-31')).toEqual(after);
    expect(await balances('2026-07-01', '2026-07-31')).toEqual(after);

    const aged = await rows<{ contact_id: string; amount_open: string; document_number: string; date_maturity: string }>(
      db,
      `select contact_id, amount_open::text, document_number, date_maturity::text
         from open_items($1) order by document_number`,
      [fx.companyId],
    );
    expect(aged).toEqual([
      { contact_id: supplier, amount_open: '605.00', document_number: 'ACH-0077', date_maturity: '2026-07-10' },
      { contact_id: customerA, amount_open: '1210.00', document_number: 'F2026-0101', date_maturity: '2026-07-15' },
      { contact_id: customerB, amount_open: '2420.00', document_number: 'F2026-0102', date_maturity: '2026-07-20' },
    ]);
  });

  it('is found by the payment reference a bank line quotes, and settled like an invoice issued here', async () => {
    await open();
    const bank = await one<{ id: string }>(
      db,
      `insert into bank_accounts (company_id, name, currency_code, iban, journal_id)
       select $1, 'Current account', currency_code, 'BE68539007547034',
              (select id from journals where company_id = $1 and code = 'BNK')
         from companies where id = $1
       returning id`,
      [fx.companyId],
    );
    // A transfer from somebody the statement does not name, quoting the
    // structured reference without its punctuation.
    const tx = await one<{ id: string }>(
      db,
      `insert into bank_transactions
         (company_id, bank_account_id, sequence, transaction_date, amount, currency_code,
          description, structured_reference, state)
       select $1, $2, 1, date '2026-07-12', 1210.00, currency_code, 'Payment', '090933755493', 'pending'
         from companies where id = $1
       returning id`,
      [fx.companyId, bank.id],
    );

    const found = await asUser(db, fx.ownerId, () =>
      rows<{ method: string; line_ids: string[]; amount: string; because: string }>(
        db,
        `select method, line_ids, amount::text, because from suggest_matches($1)`,
        [tx.id],
      ),
    );
    const byReference = found.filter((m) => m.method === 'reference');
    expect(byReference).toHaveLength(1);
    expect(byReference[0]!.amount).toBe('1210.00');
    expect(byReference[0]!.because).toContain('F2026-0101');
    const line = await one<{ number: string }>(
      db,
      `select d.number from entry_lines l join documents d on d.entry_id = l.entry_id where l.id = $1`,
      [byReference[0]!.line_ids[0]],
    );
    expect(line.number).toBe('F2026-0101');

    // settle_from_statement() books the receipt and matches it by reconcile().
    await asUser(db, fx.ownerId, () =>
      db.query(`select settle_from_statement($1, $2::uuid[])`, [tx.id, byReference[0]!.line_ids]),
    );
    const invoice = await one<{ payment_state: string; amount_residual: string }>(
      db,
      `select payment_state::text, amount_residual::text from documents where company_id = $1 and number = 'F2026-0101'`,
      [fx.companyId],
    );
    expect(invoice).toEqual({ payment_state: 'paid', amount_residual: '0.00' });
  });

  it('is matched by reconcile() against a payment booked by hand', async () => {
    await open();
    // The supplier is paid from the bank, booked as an entry of the bank journal.
    const paymentLine = await asUser(db, fx.ownerId, async () => {
      const entry = await one<{ id: string }>(
        db,
        `insert into entries (company_id, journal_id, entry_date, description, state)
         select $1, j.id, date '2026-07-08', 'Verger du Moulin VM-5521', 'draft'
           from journals j where j.company_id = $1 and j.code = 'BNK'
         returning id`,
        [fx.companyId],
      );
      await db.query(
        `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit, contact_id)
         select $1, $2, a.id, s.seq, 'VM-5521', s.debit, s.credit, s.contact
           from (values ('440000', 10, 605.00, 0, $3::uuid), ('550000', 20, 0, 605.00, null::uuid))
                  as s (code, seq, debit, credit, contact)
           join accounts a on a.company_id = $2 and a.code = s.code`,
        [entry.id, fx.companyId, supplier],
      );
      await db.query(`select post_entry($1)`, [entry.id]);
      return (
        await one<{ id: string }>(
          db,
          `select l.id from entry_lines l join accounts a on a.id = l.account_id
            where l.entry_id = $1 and a.code = '440000'`,
          [entry.id],
        )
      ).id;
    });
    const invoiceLine = await one<{ line_id: string }>(
      db,
      `select line_id from open_items($1) where document_number = 'ACH-0077'`,
      [fx.companyId],
    );

    await asUser(db, fx.ownerId, () => db.query(`select reconcile($1, $2)`, [paymentLine, invoiceLine.line_id]));
    const invoice = await one<{ payment_state: string }>(
      db,
      `select payment_state::text from documents where company_id = $1 and number = 'ACH-0077'`,
      [fx.companyId],
    );
    expect(invoice.payment_state).toBe('paid');
  });

  it('takes a credit note, which the receivable nets', async () => {
    await open({
      lines: BALANCE.map((l) => (l.account_code === '400000' ? { ...l, debit: '3509.00' } : l))
        .map((l) => (l.account_code === '100000' ? { ...l, credit: '7904.00' } : l)),
      items: [
        ...items(),
        {
          doc_type: 'sale_credit_note', number: 'NC2026-0007', contact_id: customerA, amount: '121.00',
          document_date: '2026-06-25',
        },
      ],
    });
    expect((await balances('2026-01-01', '2026-12-31')).find((b) => b.code === '400000')).toEqual({
      code: '400000', balance: '3509.00',
    });
    const credit = await one<{ side: string; amount_open: string }>(
      db,
      `select side, amount_open::text from open_items($1) where document_number = 'NC2026-0007'`,
      [fx.companyId],
    );
    expect(credit).toEqual({ side: 'credit', amount_open: '121.00' });
  });

  it('still opens on the first day of the year when no day is given', async () => {
    const entryId = await asUser(db, fx.ownerId, async () =>
      (
        await one<{ opening_balance: string }>(db, `select opening_balance($1, $2, $3::jsonb)`, [
          fx.companyId,
          year,
          JSON.stringify([
            { account_code: '550000', debit: '100.00' },
            { account_code: '100000', credit: '100.00' },
          ]),
        ])
      ).opening_balance,
    );
    const entry = await one<{ entry_date: string }>(db, `select entry_date::text from entries where id = $1`, [entryId]);
    expect(entry.entry_date).toBe('2026-01-01');
  });
});

describe('a chart whose suspense account is reconcilable', () => {
  it('matches the lines the opening and its items write there, so none is left open', async () => {
    // Several charts keep their suspense account reconcilable. The country is
    // the first such pack the seeds carry, and its codes are read from the
    // company the pack installed: nothing here names an account.
    const country = (
      await one<{ country: string }>(
        db,
        `select d.country from country_defaults d
           join account_templates t on t.country = d.country and t.code = d.suspense_code
          where t.reconcilable order by d.country limit 1`,
      )
    ).country;
    const other = await newCompany(db, { country, name: 'Suspense Reconcilable' });
    const codes = await one<{ receivable: string; payable: string; equity: string; suspense: string; year: string }>(
      db,
      `select r.code as receivable, p.code as payable, e.code as equity, s.code as suspense,
              (select id from fiscal_years where company_id = c.id) as year
         from companies c
         join accounts r on r.id = c.receivable_account_id
         join accounts p on p.id = c.payable_account_id
         join accounts e on e.id = c.retained_earnings_account_id
         join accounts s on s.id = c.suspense_account_id
        where c.id = $1`,
      [other.companyId],
    );
    const reconcilable = await one<{ reconcilable: boolean }>(
      db,
      `select a.reconcilable from companies c join accounts a on a.id = c.suspense_account_id where c.id = $1`,
      [other.companyId],
    );
    expect(reconcilable.reconcilable).toBe(true);
    const customer = await newContact(db, other.companyId, { name: 'Customer', country: null });
    const seller = await newContact(db, other.companyId, { name: 'Supplier', type: 'supplier', country: null });

    await asUser(db, other.ownerId, () =>
      db.query(`select opening_balance($1, $2, $3::jsonb, false, date '2026-07-01', $4::jsonb)`, [
        other.companyId,
        codes.year,
        JSON.stringify([
          { account_code: codes.receivable, debit: '1000.00' },
          { account_code: codes.payable, credit: '400.00' },
          { account_code: codes.equity, credit: '600.00' },
        ]),
        JSON.stringify([
          { doc_type: 'sale_invoice', number: 'S-1', contact_id: customer, amount: '1000.00', document_date: '2026-06-01' },
          { doc_type: 'purchase_invoice', number: 'P-1', contact_id: seller, amount: '400.00', document_date: '2026-06-02' },
        ]),
      ]),
    );

    const open = await rows<{ document_number: string | null; amount_open: string }>(
      db,
      `select document_number, amount_open::text from open_items($1) order by document_number`,
      [other.companyId],
    );
    expect(open).toEqual([
      { document_number: 'P-1', amount_open: '400.00' },
      { document_number: 'S-1', amount_open: '1000.00' },
    ]);
    const suspense = await one<{ lines: number; unmatched: number }>(
      db,
      `select count(*)::int as lines,
              count(*) filter (where abs(l.balance) - l.matched_amount <> 0)::int as unmatched
         from entry_lines l join accounts a on a.id = l.account_id
        where l.company_id = $1 and a.code = $2`,
      [other.companyId, codes.suspense],
    );
    expect(suspense).toEqual({ lines: 4, unmatched: 0 });
  });
});

describe('what an opening with open items refuses', () => {
  async function nothingWritten(): Promise<void> {
    const written = await one<{ entries: number; documents: number }>(
      db,
      `select (select count(*)::int from entries where company_id = $1) as entries,
              (select count(*)::int from documents where company_id = $1) as documents`,
      [fx.companyId],
    );
    expect(written).toEqual({ entries: 0, documents: 0 });
  }

  it('items that do not add up to the line of their account', async () => {
    const message = await refusal({ items: items().slice(1) });
    expect(message).toMatch(
      /opening_items_unbalanced: 400000 opens at a debit of 3630\.00 in the balance and its open items come to a debit of 2420\.00/,
    );
    await nothingWritten();
  });

  it('items on an account the balance leaves out', async () => {
    const message = await refusal({
      lines: BALANCE.filter((l) => l.account_code !== '440000').map((l) =>
        l.account_code === '100000' ? { ...l, credit: '8630.00' } : l,
      ),
    });
    expect(message).toMatch(/opening_items_unbalanced: 440000 opens at a debit of 0 in the balance and its open items come to a credit of 605\.00/);
    await nothingWritten();
  });

  it('a number twice in the list, or one a document of the company already carries', async () => {
    const twice = items();
    twice[1] = { ...twice[1]!, number: 'F2026-0101' };
    expect(await refusal({ items: twice })).toMatch(/opening_item_duplicate: sale_invoice F2026-0101/);
    await nothingWritten();

    await newDocument(db, fx.companyId, {
      docType: 'sale_invoice',
      number: 'F2026-0102',
      contactId: customerB,
      date: '2026-06-01',
      lines: [{ unitPrice: 100, taxCode: 'BE-S-21', accountCode: '700000' }],
    });
    expect(await refusal({})).toMatch(/opening_item_duplicate: sale_invoice F2026-0102/);
  });

  it('an item issued after the opening, or due before it was issued', async () => {
    const late = items();
    late[0] = { ...late[0]!, document_date: '2026-07-02' };
    expect(await refusal({ items: late })).toMatch(
      /opening_item_after_opening: sale_invoice F2026-0101 was issued on 2026-07-02, after the opening on 2026-07-01/,
    );
    const early = items();
    early[0] = { ...early[0]!, due_date: '2026-05-01' };
    expect(await refusal({ items: early })).toMatch(/opening_item_due_before_issue: sale_invoice F2026-0101/);
    await nothingWritten();
  });

  it('an opening day outside the year', async () => {
    expect(await refusal({ date: '2027-01-01' })).toMatch(/opening_date_outside_year: 2027-01-01/);
  });

  it('an item of another type, with no number, no contact of the company or no amount', async () => {
    const quote = items();
    quote[0] = { ...quote[0]!, doc_type: 'sale_quote' };
    expect(await refusal({ items: quote })).toMatch(/opening_item_type: item 1 \(F2026-0101\) is a sale_quote/);

    const unnumbered = items();
    unnumbered[0] = { ...unnumbered[0]!, number: ' ' };
    expect(await refusal({ items: unnumbered })).toMatch(/opening_item_without_number: item 1/);

    const elsewhere = await newCompany(db, { name: 'Somebody Else' });
    const stranger = await newContact(db, elsewhere.companyId, { name: 'Stranger' });
    const foreign = items();
    foreign[0] = { ...foreign[0]!, contact_id: stranger };
    expect(await refusal({ items: foreign })).toMatch(/opening_item_unknown_contact: sale_invoice F2026-0101/);

    const negative = items();
    negative[0] = { ...negative[0]!, amount: '-1210.00' };
    expect(await refusal({ items: negative })).toMatch(/opening_item_amount: sale_invoice F2026-0101/);
    await nothingWritten();
  });
});
