import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, type Fixture } from './helpers/factory.js';
import { newMember, refusalAs } from './helpers/integrity.js';

// Issue #93: a payout of a payment provider (the invoice less the fee it kept)
// or a bank line with charges could not be settled by settle_from_statement():
// more money than open was refused, and no line was booked for the fee. The
// function now takes how much settles each item, and extra lines booked in the
// same entry, balancing the bank line to the cent.

let db: PGlite;
let fx: Fixture;
let accountant: string;
let customer: string;
let supplier: string;
let bankAccountId: string;
let bankAccountCode: string;
let incomeCode: string;
let expenseCode: string;
let receivableCode: string;
let purchaseTax: { code: string; rate: number; box: string };
let saleOnlyTax: string;
let sequence = 0;

/** A posted invoice of `total`, no tax on it, and the open item it leaves. */
async function openItem(
  number: string,
  total: number,
  options: { date?: string; purchase?: boolean } = {},
): Promise<string> {
  const documentId = await newDocument(db, fx.companyId, {
    docType: options.purchase ? 'purchase_invoice' : 'sale_invoice',
    number,
    contactId: options.purchase ? supplier : customer,
    date: options.date ?? '2026-03-02',
    lines: [{ unitPrice: total, taxCode: null, accountCode: options.purchase ? expenseCode : incomeCode }],
  });
  await db.query(`select post_document($1)`, [documentId]);
  const item = await one<{ line_id: string }>(db, `select line_id from open_items($1) where document_id = $2`, [
    fx.companyId,
    documentId,
  ]);
  return item.line_id;
}

/** What is still open on a ledger line, or null once nothing is. */
async function openOn(lineId: string): Promise<string | null> {
  const row = (
    await rows<{ amount_open: string }>(db, `select amount_open from open_items($1) where line_id = $2`, [
      fx.companyId,
      lineId,
    ])
  )[0];
  return row?.amount_open ?? null;
}

/** A pending statement line, written by the accountant the way an import writes it. */
async function statementLine(amount: number, contactId: string | null = customer): Promise<string> {
  sequence += 1;
  return asUser(db, accountant, async () => {
    const row = await one<{ id: string }>(
      db,
      `insert into bank_transactions (company_id, bank_account_id, sequence, transaction_date, amount, contact_id)
       values ($1, $2, $3, '2026-03-05', $4, $5) returning id`,
      [fx.companyId, bankAccountId, sequence, amount, contactId],
    );
    return row.id;
  });
}

type Extra = { account?: string; amount?: string | number; tax?: string | null; description?: string } & Record<
  string,
  unknown
>;

/** settle_from_statement() as the accountant, with its new arguments. */
async function settle(
  transactionId: string,
  lineIds: string[] | null,
  amounts: string[] | null,
  extras: Extra[] | null,
): Promise<{ entry_id: string; state: string }> {
  return asUser(db, accountant, () =>
    one<{ entry_id: string; state: string }>(
      db,
      `select entry_id, state from settle_from_statement($1, $2::uuid[], $3::numeric[], $4::jsonb)`,
      [transactionId, lineIds, amounts, extras === null ? null : JSON.stringify(extras)],
    ),
  );
}

async function refusal(
  transactionId: string,
  lineIds: string[] | null,
  amounts: string[] | null,
  extras: unknown,
): Promise<string> {
  return refusalAs(db, accountant, `select settle_from_statement($1, $2::uuid[], $3::numeric[], $4::jsonb)`, [
    transactionId,
    lineIds,
    amounts,
    extras === null ? null : JSON.stringify(extras),
  ]);
}

interface Line {
  code: string;
  debit: string;
  credit: string;
  tax_line: boolean;
  box: string | null;
  box_amount: string | null;
}

async function linesOf(entryId: string): Promise<Line[]> {
  return rows<Line>(
    db,
    `select a.code, l.debit, l.credit, l.tax_line, l.declaration_box as box, l.box_amount
       from entry_lines l join accounts a on a.id = l.account_id
      where l.entry_id = $1 order by l.sequence`,
    [entryId],
  );
}

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db);
  accountant = await newMember(db, fx.companyId, 'accountant');
  customer = await newContact(db, fx.companyId, { name: 'Customer' });
  supplier = await newContact(db, fx.companyId, { name: 'Supplier', type: 'supplier' });

  const account = await one<{ id: string; code: string }>(
    db,
    `with b as (
       insert into bank_accounts (company_id, name, currency_code, journal_id)
       select c.id, 'Current account', c.currency_code,
              (select j.id from journals j where j.company_id = c.id and j.journal_type = 'bank' order by j.code limit 1)
         from companies c where c.id = $1
       returning id, account_id, journal_id)
     select b.id, a.code
       from b
       left join journals j on j.id = b.journal_id
       join accounts a on a.id = coalesce(b.account_id, j.default_account_id)`,
    [fx.companyId],
  );
  bankAccountId = account.id;
  bankAccountCode = account.code;

  const pick = async (type: string): Promise<string> =>
    (
      await one<{ code: string }>(
        db,
        `select code from accounts
          where company_id = $1 and account_type = $2::account_type and not reconcilable and not deprecated
          order by code limit 1`,
        [fx.companyId, type],
      )
    ).code;
  incomeCode = await pick('income');
  expenseCode = await pick('expense');
  receivableCode = (
    await one<{ code: string }>(
      db,
      `select a.code from companies c join accounts a on a.id = c.receivable_account_id where c.id = $1`,
      [fx.companyId],
    )
  ).code;

  // A tax the company bears on what it buys, read from its books: a domestic
  // percentage, not on a cash basis, with one tax posting and a box on each
  // side of a purchase invoice.
  const tax = await one<{ code: string; amount: string; box: string }>(
    db,
    `select t.code, t.amount, p.declaration_box as box
       from taxes t
       join tax_postings p on p.tax_id = t.id and p.document_kind = 'invoice' and p.posting_type = 'tax'
      where t.company_id = $1 and t.applies_to in ('purchase', 'both') and t.treatment = 'domestic'
        and t.amount_type = 'percent' and t.amount > 0 and t.active and not t.cash_basis and t.valid_to is null
        and p.declaration_box is not null and p.factor_percent = 100
        and (select count(*) from tax_postings q
              where q.tax_id = t.id and q.document_kind = 'invoice' and q.posting_type <> 'base') = 1
        and exists (select 1 from tax_postings q
                     where q.tax_id = t.id and q.document_kind = 'invoice'
                       and q.posting_type = 'base' and q.declaration_box is not null)
      order by t.amount desc, t.code
      limit 1`,
    [fx.companyId],
  );
  purchaseTax = { code: tax.code, rate: Number(tax.amount), box: tax.box };
  saleOnlyTax = (
    await one<{ code: string }>(
      db,
      `select code from taxes where company_id = $1 and applies_to = 'sale' and amount_type = 'percent' order by code limit 1`,
      [fx.companyId],
    )
  ).code;
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('a payout net of a fee', () => {
  it('settles the invoice of 100.00 with 97.00 and books the fee of 3.00 in the same entry', async () => {
    const item = await openItem('INV-93-1', 100);
    const tx = await statementLine(97);
    const settled = await settle(tx, [item], null, [
      { account: expenseCode, amount: '3.00', description: 'Provider fee' },
    ]);

    expect(settled.state).toBe('reconciled');
    expect(await openOn(item)).toBeNull();
    expect(await linesOf(settled.entry_id)).toEqual([
      { code: bankAccountCode, debit: '97.00', credit: '0.00', tax_line: false, box: null, box_amount: null },
      { code: receivableCode, debit: '0.00', credit: '100.00', tax_line: false, box: null, box_amount: null },
      { code: expenseCode, debit: '3.00', credit: '0.00', tax_line: false, box: null, box_amount: null },
    ]);
    expect(await one(db, `select state from entries where id = $1`, [settled.entry_id])).toEqual({ state: 'posted' });
    // The payment of the customer is what they paid, and it points at the entry.
    expect(
      await one(db, `select amount, direction, contact_id, state from payments where entry_id = $1`, [
        settled.entry_id,
      ]),
    ).toEqual({ amount: '100.00', direction: 'inbound', contact_id: customer, state: 'posted' });
  });

  it('takes the tax out of the fee when the fee bears one, into the box its posting names', async () => {
    const item = await openItem('INV-93-2', 100);
    const tx = await statementLine(97);
    const settled = await settle(tx, [item], ['100.00'], [
      { account: expenseCode, amount: '3.00', tax: purchaseTax.code },
    ]);

    expect(await openOn(item)).toBeNull();
    const lines = await linesOf(settled.entry_id);
    const fee = lines.filter((l) => l.code !== bankAccountCode && l.code !== receivableCode);
    const base = fee.find((l) => !l.tax_line && l.code === expenseCode);
    const tax = fee.find((l) => l.tax_line);
    const expectedBase = Math.round((300 / (1 + purchaseTax.rate / 100))) / 100;
    expect(Number(base?.debit)).toBeCloseTo(expectedBase, 2);
    expect(Number(base?.debit) + Number(tax?.debit)).toBeCloseTo(3, 2);
    expect(tax).toMatchObject({ box: purchaseTax.box, box_amount: tax?.debit });
    expect(base?.box).not.toBeNull();
    const totals = await one<{ debit: string; credit: string }>(
      db,
      `select total_debit as debit, total_credit as credit from entries where id = $1`,
      [settled.entry_id],
    );
    expect(totals).toEqual({ debit: '100.00', credit: '100.00' });
  });
});

describe('amounts named per item', () => {
  it('settles two invoices for what the caller says, one of them in part, in the order named', async () => {
    const older = await openItem('INV-93-3', 100, { date: '2026-02-01' });
    const newer = await openItem('INV-93-4', 100, { date: '2026-02-15' });
    const tx = await statementLine(150);
    // Oldest first would settle the older one in full. The caller says
    // otherwise, and is followed.
    await settle(tx, [newer, older], ['100.00', '50.00'], null);
    expect(await openOn(newer)).toBeNull();
    expect(await openOn(older)).toBe('50.00');
  });

  it('pays a supplier with the bank charges on the same line', async () => {
    const item = await openItem('BILL-93-1', 100, { purchase: true });
    const tx = await statementLine(-102, supplier);
    const settled = await settle(tx, [item], ['100.00'], [{ account: expenseCode, amount: '2.00' }]);
    expect(await openOn(item)).toBeNull();
    const lines = await linesOf(settled.entry_id);
    expect(lines.find((l) => l.code === bankAccountCode)).toMatchObject({ debit: '0.00', credit: '102.00' });
    expect(lines.find((l) => l.code === expenseCode)).toMatchObject({ debit: '2.00', credit: '0.00' });
  });
});

describe('a bank charge on its own', () => {
  it('is settled by its extra line, with no item and no payment', async () => {
    const tx = await statementLine(-5, null);
    const settled = await settle(tx, null, null, [{ account: expenseCode, amount: '5.00', description: 'Charges' }]);
    expect(settled.state).toBe('reconciled');
    expect(await linesOf(settled.entry_id)).toEqual([
      { code: bankAccountCode, debit: '0.00', credit: '5.00', tax_line: false, box: null, box_amount: null },
      { code: expenseCode, debit: '5.00', credit: '0.00', tax_line: false, box: null, box_amount: null },
    ]);
    expect(await one(db, `select count(*)::int as n from payments where entry_id = $1`, [settled.entry_id])).toEqual({
      n: 0,
    });
  });
});

describe('what is refused by name, with nothing booked', () => {
  it('a line that does not balance to the cent', async () => {
    const item = await openItem('INV-93-5', 100);
    const tx = await statementLine(97);
    expect(await refusal(tx, [item], ['100.00'], [{ account: expenseCode, amount: '2.99' }])).toMatch(
      /^settlement_unbalanced: .*off by 0\.01/,
    );
    expect(await refusal(tx, [item], ['50.00'], null)).toMatch(/^settlement_unbalanced\b/);
    // With extra lines and no amounts the items are settled in full: a fee a
    // cent short is refused, not left as a cent open on the invoice.
    expect(await refusal(tx, [item], null, [{ account: expenseCode, amount: '2.99' }])).toMatch(
      /^settlement_unbalanced: .*off by 0\.01/,
    );
    const charge = await statementLine(-5, null);
    expect(await refusal(charge, null, null, [{ account: expenseCode, amount: '4.00' }])).toMatch(
      /^settlement_unbalanced\b/,
    );
    expect(await one(db, `select state, entry_id from bank_transactions where id = $1`, [tx])).toEqual({
      state: 'pending',
      entry_id: null,
    });
  });

  it('amounts that are not one per item, not positive, or more than is open', async () => {
    const item = await openItem('INV-93-6', 100);
    const tx = await statementLine(100);
    expect(await refusal(tx, [item], ['60.00', '40.00'], null)).toMatch(/^settlement_amounts_mismatch\b/);
    expect(await refusal(tx, [item], ['0'], null)).toMatch(/^settlement_amount_not_positive\b/);
    const over = await statementLine(120);
    expect(await refusal(over, [item], ['120.00'], null)).toMatch(/^settlement_over_open\b/);
  });

  it('an account the company does not have, or one that takes no entry by hand', async () => {
    const item = await openItem('INV-93-7', 100);
    const tx = await statementLine(97);
    expect(await refusal(tx, [item], null, [{ account: 'no-such-account', amount: '3.00' }])).toMatch(
      /^unknown_account\b/,
    );
    expect(await refusal(tx, [item], null, [{ account: receivableCode, amount: '3.00' }])).toMatch(
      /^account_takes_no_entries\b.*reconcilable/,
    );
    const deprecated = await one<{ code: string }>(
      db,
      `update accounts set deprecated = true
        where id = (select id from accounts where company_id = $1 and account_type = 'expense'
                     and not reconcilable and code <> $2 order by code desc limit 1)
       returning code`,
      [fx.companyId, expenseCode],
    );
    expect(await refusal(tx, [item], null, [{ account: deprecated.code, amount: '3.00' }])).toMatch(
      /^account_takes_no_entries\b.*deprecated/,
    );
    expect(await refusal(tx, [item], null, [{ amount: '3.00' }])).toMatch(/^extra_line_without_account\b/);
  });

  it('a tax the company does not have, one on sales, or a negative charge bearing a tax', async () => {
    const item = await openItem('INV-93-8', 100);
    const tx = await statementLine(97);
    expect(await refusal(tx, [item], null, [{ account: expenseCode, amount: '3.00', tax: 'NO-SUCH-TAX' }])).toMatch(
      /^unknown_tax\b/,
    );
    expect(await refusal(tx, [item], null, [{ account: expenseCode, amount: '3.00', tax: saleOnlyTax }])).toMatch(
      /^extra_line_tax_on_sales\b/,
    );
    const refund = await statementLine(103);
    expect(
      await refusal(refund, [item], null, [{ account: expenseCode, amount: '-3.00', tax: purchaseTax.code }]),
    ).toMatch(/^extra_line_sign\b/);
  });

  it('an extra line of nothing, finer than the currency, or with a field it does not know', async () => {
    const item = await openItem('INV-93-9', 100);
    const tx = await statementLine(97);
    expect(await refusal(tx, [item], null, [{ account: expenseCode, amount: '0' }])).toMatch(/^extra_line_zero\b/);
    expect(await refusal(tx, [item], null, [{ account: expenseCode, amount: 'three' }])).toMatch(
      /^extra_line_bad_amount\b/,
    );
    expect(await refusal(tx, [item], null, [{ account: expenseCode, amount: '2.999' }])).toMatch(
      /^extra_line_not_rounded\b/,
    );
    expect(await refusal(tx, [item], null, [{ account: expenseCode, amount: '3.00', tax_code: 'X' }])).toMatch(
      /^extra_line_unknown_field\b.*tax_code/,
    );
    expect(await refusal(tx, [item], null, { account: expenseCode, amount: '3.00' })).toMatch(
      /^extra_lines_not_a_list\b/,
    );
    expect(await refusal(tx, [item], null, ['3.00'])).toMatch(/^extra_line_not_an_object\b/);
  });

  it('a counterparty other than the one of the items, as reconcile() rules', async () => {
    const other = await newContact(db, fx.companyId, { name: 'Another customer' });
    const mine = await openItem('INV-93-10', 100);
    const documentId = await newDocument(db, fx.companyId, {
      docType: 'sale_invoice',
      number: 'INV-93-11',
      contactId: other,
      date: '2026-03-02',
      lines: [{ unitPrice: 100, taxCode: null, accountCode: incomeCode }],
    });
    await db.query(`select post_document($1)`, [documentId]);
    const theirs = (
      await one<{ line_id: string }>(db, `select line_id from open_items($1) where document_id = $2`, [
        fx.companyId,
        documentId,
      ])
    ).line_id;
    const tx = await statementLine(194);
    expect(
      await refusal(tx, [mine, theirs], ['100.00', '100.00'], [{ account: expenseCode, amount: '6.00' }]),
    ).toMatch(/^mixed_contacts\b/);
  });
});

describe('every call made before keeps its meaning', () => {
  it('two arguments settle oldest first, booked by post_payment()', async () => {
    const item = await openItem('INV-93-12', 100);
    const tx = await statementLine(100);
    const settled = await asUser(db, accountant, () =>
      one<{ entry_id: string }>(db, `select entry_id from settle_from_statement($1, array[$2]::uuid[])`, [tx, item]),
    );
    expect(await openOn(item)).toBeNull();
    expect(await linesOf(settled.entry_id)).toHaveLength(2);
  });
});
