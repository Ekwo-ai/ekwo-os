import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, type Fixture } from './helpers/factory.js';

let db: PGlite;
let fx: Fixture;
let bankAccountId: string;
let sequence = 0;

interface Match {
  kind: string;
  line_ids: string[];
  amount: string;
  method: string;
  score: string;
  because: string;
  alternatives: number;
}

interface Report {
  transaction_id: string;
  action: string;
  method: string;
  line_ids: string[];
  because: string;
}

/** An invoice of 1 000 plus tax, posted, and the receivable it leaves open. */
async function invoice(number: string, date: string, amount = 1000): Promise<string> {
  const documentId = await newDocument(db, fx.companyId, {
    docType: 'sale_invoice',
    number,
    contactId: customerId,
    date,
    lines: [{ unitPrice: amount, taxCode: 'BE-S-21', accountCode: '704000' }],
  });
  await db.query(`select post_document($1)`, [documentId]);
  return documentId;
}

async function statementLine(options: {
  amount: number;
  date?: string;
  contactId?: string | null;
  reference?: string | null;
  structured?: string | null;
  description?: string | null;
  iban?: string | null;
  currency?: string | null;
}): Promise<string> {
  sequence += 1;
  const row = await one<{ id: string }>(
    db,
    `insert into bank_transactions
       (company_id, bank_account_id, sequence, transaction_date, amount, currency_code,
        description, reference, structured_reference, counterpart_iban, contact_id, state)
     select $1, $2, $3, $4::date, $5, coalesce($10, c.currency_code),
            $6, $7, $8, $9, $11, 'pending'
       from companies c where c.id = $1
     returning id`,
    [
      fx.companyId,
      bankAccountId,
      sequence,
      options.date ?? '2026-03-05',
      options.amount,
      options.description ?? null,
      options.reference ?? null,
      options.structured ?? null,
      options.iban ?? null,
      options.currency ?? null,
      options.contactId === undefined ? customerId : options.contactId,
    ],
  );
  return row.id;
}

async function matches(transactionId: string): Promise<Match[]> {
  return rows<Match>(db, `select * from suggest_matches($1)`, [transactionId]);
}

async function pass(apply: boolean): Promise<Report[]> {
  return rows<Report>(db, `select * from auto_settle($1, '2026-01-01', '2026-12-31', $2)`, [
    fx.companyId,
    apply,
  ]);
}

let customerId: string;

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db);
  customerId = await newContact(db, fx.companyId, { name: 'Client Principal' });
  const account = await one<{ id: string }>(
    db,
    `insert into bank_accounts (company_id, name, currency_code, iban, journal_id)
     select $1, 'Compte courant', currency_code, 'BE68539007547034',
            (select id from journals where company_id = $1 and code = 'BNK')
       from companies where id = $1
     returning id`,
    [fx.companyId],
  );
  bankAccountId = account.id;
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('what is still open', () => {
  it('is the third-party line of a posted document, and its document with it', async () => {
    const documentId = await invoice('FAC-OPEN', '2026-02-02');
    const items = await rows<{ side: string; amount_open: string; document_number: string }>(
      db,
      `select side, amount_open, document_number from open_items($1) where document_id = $2`,
      [fx.companyId, documentId],
    );
    expect(items).toHaveLength(1);
    expect(items[0]!.side).toBe('debit');
    expect(items[0]!.amount_open).toBe('1210.00');
  });
});

describe('what a statement line could settle', () => {
  it('proposes the open item of the same amount, once', async () => {
    const documentId = await invoice('FAC-EXACT', '2026-03-01', 1500);
    const tx = await statementLine({ amount: 1815, date: '2026-03-05' });
    const found = (await matches(tx)).filter((m) => m.method === 'exact_amount');
    expect(found).toHaveLength(1);
    expect(found[0]!.alternatives).toBe(1);
    const document = await one<{ number: string }>(
      db,
      `select d.number from documents d
         join entries e on e.id = d.entry_id
         join entry_lines l on l.entry_id = e.id
        where l.id = $1`,
      [found[0]!.line_ids[0]],
    );
    expect(document.number).toBe('FAC-EXACT');
    expect(documentId).toBeTruthy();
  });

  it('counts the candidates when two invoices carry the same amount', async () => {
    const twin = await newContact(db, fx.companyId, { name: 'Client Jumeau' });
    const first = await newDocument(db, fx.companyId, {
      docType: 'sale_invoice',
      number: 'FAC-TWIN-1',
      contactId: twin,
      date: '2026-04-01',
      lines: [{ unitPrice: 500, taxCode: 'BE-S-21', accountCode: '704000' }],
    });
    const second = await newDocument(db, fx.companyId, {
      docType: 'sale_invoice',
      number: 'FAC-TWIN-2',
      contactId: twin,
      date: '2026-04-02',
      lines: [{ unitPrice: 500, taxCode: 'BE-S-21', accountCode: '704000' }],
    });
    await db.query(`select post_document($1)`, [first]);
    await db.query(`select post_document($1)`, [second]);
    const tx = await statementLine({ amount: 605, date: '2026-04-10', contactId: twin });
    const found = (await matches(tx)).filter((m) => m.method === 'exact_amount');
    expect(found).toHaveLength(2);
    expect(found.every((m) => m.alternatives === 2)).toBe(true);
  });

  it('reads a reference the statement carries, and scores it above an amount', async () => {
    const documentId = await newDocument(db, fx.companyId, {
      docType: 'sale_invoice',
      number: 'FAC-REF-9',
      contactId: customerId,
      date: '2026-05-02',
      lines: [{ unitPrice: 777, taxCode: 'BE-S-21', accountCode: '704000' }],
    });
    await db.query(`select post_document($1)`, [documentId]);
    const tx = await statementLine({
      amount: 940.17,
      date: '2026-05-08',
      description: 'Paiement facture FAC-REF-9 merci',
    });
    const found = await matches(tx);
    const byReference = found.filter((m) => m.method === 'reference');
    expect(byReference).toHaveLength(1);
    expect(Number(byReference[0]!.score)).toBe(1);
  });

  it('says a transfer between two accounts of this company settles nothing', async () => {
    const tx = await statementLine({
      amount: -5000,
      date: '2026-06-01',
      iban: 'BE68 5390 0754 7034',
      contactId: null,
    });
    const found = await matches(tx);
    expect(found).toHaveLength(1);
    expect(found[0]!.kind).toBe('internal_transfer');
  });

  it('proposes nothing across currencies, rather than guessing a rate', async () => {
    const documentId = await invoice('FAC-FX', '2026-07-01');
    const tx = await statementLine({ amount: 1210, date: '2026-07-03', currency: 'USD' });
    expect(await matches(tx)).toHaveLength(0);
    expect(documentId).toBeTruthy();
  });
});

describe('the pass over a period', () => {
  it('changes nothing when it is not asked to apply, and says what it would do', async () => {
    const before = await one<{ count: string }>(
      db,
      `select count(*)::text as count from reconciliations where company_id = $1`,
      [fx.companyId],
    );
    const report = await pass(false);
    expect(report.some((r) => r.action === 'would_settle')).toBe(true);
    const after = await one<{ count: string }>(
      db,
      `select count(*)::text as count from reconciliations where company_id = $1`,
      [fx.companyId],
    );
    expect(after.count).toBe(before.count);
  });

  it('settles what one piece of evidence identifies, and the document knows it', async () => {
    const documentId = await invoice('FAC-SETTLE', '2026-08-01', 300);
    const tx = await statementLine({ amount: 363, date: '2026-08-04' });
    const report = (await pass(true)).filter((r) => r.transaction_id === tx);
    expect(report).toHaveLength(1);
    expect(report[0]!.action).toBe('settled');

    const line = await one<{ state: string; booked: boolean }>(
      db,
      `select state, entry_id is not null as booked from bank_transactions where id = $1`,
      [tx],
    );
    expect(line.state).toBe('reconciled');
    expect(line.booked).toBe(true);

    const document = await one<{ payment_state: string; amount_residual: string }>(
      db,
      `select payment_state, amount_residual from documents where id = $1`,
      [documentId],
    );
    expect(document.payment_state).toBe('paid');
    expect(document.amount_residual).toBe('0.00');
  });

  it('leaves an internal transfer alone, with the reason', async () => {
    const report = await pass(false);
    const internal = report.filter((r) => r.method === 'internal_transfer');
    expect(internal.length).toBeGreaterThan(0);
    expect(internal.every((r) => r.action === 'left')).toBe(true);
  });

  /**
   * Four accounting treatments wear the same face: a deposit, a discount, a
   * short payment, an error. The ledger cannot tell them apart, so the machine
   * proposes and a person decides.
   */
  it('never settles a payment smaller than what is open', async () => {
    const documentId = await invoice('FAC-PARTIAL', '2026-09-01', 2000);
    const tx = await statementLine({ amount: 1000, date: '2026-09-03' });
    const report = (await pass(true)).filter((r) => r.transaction_id === tx);
    expect(report[0]!.action).toBe('proposed');
    const document = await one<{ payment_state: string }>(
      db,
      `select payment_state from documents where id = $1`,
      [documentId],
    );
    expect(document.payment_state).not.toBe('paid');
  });

  it('never settles a combination on its own, and still offers it', async () => {
    const grouped = await newContact(db, fx.companyId, { name: 'Client Groupe' });
    for (const [number, amount] of [
      ['FAC-G-1', 100],
      ['FAC-G-2', 200],
    ] as const) {
      const documentId = await newDocument(db, fx.companyId, {
        docType: 'sale_invoice',
        number,
        contactId: grouped,
        date: '2026-10-01',
        lines: [{ unitPrice: amount, taxCode: 'BE-S-21', accountCode: '704000' }],
      });
      await db.query(`select post_document($1)`, [documentId]);
    }
    const tx = await statementLine({ amount: 363, date: '2026-10-09', contactId: grouped });

    const combination = await rows<{ line_ids: string[]; amount: string }>(
      db,
      `select line_ids, amount from suggest_combination($1)`,
      [tx],
    );
    expect(combination).toHaveLength(1);
    expect(combination[0]!.line_ids).toHaveLength(2);
    expect(combination[0]!.amount).toBe('363.00');

    const report = (await pass(true)).filter((r) => r.transaction_id === tx);
    expect(report[0]!.action).toBe('proposed');
  });
});

/**
 * The second incident of the production this design comes from, and the one
 * that cost the most: the pass carried a hard-coded upper bound on the date,
 * so every statement line of the following year walked straight past the
 * matching **in silence** — including a five-figure wire nobody chased for
 * months. Nothing failed, nothing was logged, and the only symptom was an
 * account that would not tie.
 *
 * The shape that makes it impossible here is not the window being a
 * parameter — that is necessary and not sufficient — it is that the pass
 * **accounts for every line it walks over**. A line inside the window comes
 * back with an action and a reason, always, even when the answer is "nothing
 * open matches this". Silence is not a possible output.
 */
describe('nothing is skipped in silence', () => {
  it('returns a row for every pending line of the window, matched or not', async () => {
    const later = await newCompany(db, { name: 'Next Year' });
    const account = await one<{ id: string }>(
      db,
      `insert into bank_accounts (company_id, name, currency_code, journal_id)
       select $1, 'Compte', currency_code,
              (select id from journals where company_id = $1 and code = 'BNK')
         from companies where id = $1 returning id`,
      [later.companyId],
    );
    // Three lines nothing can match: one in the year the ledger knows, two in
    // the year after it.
    for (const [index, date] of ['2026-12-30', '2027-01-04', '2027-06-15'].entries()) {
      await db.query(
        `insert into bank_transactions
           (company_id, bank_account_id, sequence, transaction_date, amount, currency_code, state)
         select $1, $2, $3, $4::date, 100, currency_code, 'pending'
           from companies where id = $1`,
        [later.companyId, account.id, index + 1, date],
      );
    }

    const pending = await one<{ count: string }>(
      db,
      `select count(*)::text as count from bank_transactions
        where company_id = $1 and state = 'pending'`,
      [later.companyId],
    );
    const report = await rows<Report>(
      db,
      `select * from auto_settle($1, '2026-01-01', '2027-12-31', false)`,
      [later.companyId],
    );

    expect(report).toHaveLength(Number(pending.count));
    expect(report.every((r) => r.action !== '' && r.because !== '')).toBe(true);
    // And the window is a window: asking for the first year answers for the
    // first year, and says so by returning fewer rows — not by going quiet.
    const firstYear = await rows<Report>(
      db,
      `select * from auto_settle($1, '2026-01-01', '2026-12-31', false)`,
      [later.companyId],
    );
    expect(firstYear).toHaveLength(1);
  });
});

describe('settling by hand refuses', () => {
  it('a statement line that is already booked', async () => {
    const documentId = await invoice('FAC-TWICE', '2026-11-01', 400);
    const tx = await statementLine({ amount: 484, date: '2026-11-02' });
    const item = await one<{ line_id: string }>(
      db,
      `select line_id from open_items($1) where document_id = $2`,
      [fx.companyId, documentId],
    );
    await db.query(`select settle_from_statement($1, $2)`, [tx, [item.line_id]]);
    const message = await expectError(db, `select settle_from_statement($1, $2)`, [
      tx,
      [item.line_id],
    ]);
    expect(message).toContain('statement_line_already_settled');
  });

  it('more money than the items named leave open', async () => {
    const documentId = await invoice('FAC-SMALL', '2026-11-10', 100);
    const tx = await statementLine({ amount: 5000, date: '2026-11-12' });
    const item = await one<{ line_id: string }>(
      db,
      `select line_id from open_items($1) where document_id = $2`,
      [fx.companyId, documentId],
    );
    const message = await expectError(db, `select settle_from_statement($1, $2)`, [
      tx,
      [item.line_id],
    ]);
    expect(message).toContain('more_money_than_open');
  });

  it('the open items of two different counterparties in one payment', async () => {
    const other = await newContact(db, fx.companyId, { name: 'Client Autre' });
    const mine = await invoice('FAC-MIX-1', '2026-11-20', 100);
    const theirs = await newDocument(db, fx.companyId, {
      docType: 'sale_invoice',
      number: 'FAC-MIX-2',
      contactId: other,
      date: '2026-11-20',
      lines: [{ unitPrice: 100, taxCode: 'BE-S-21', accountCode: '704000' }],
    });
    await db.query(`select post_document($1)`, [theirs]);
    const lines = await rows<{ line_id: string }>(
      db,
      `select line_id from open_items($1) where document_id = any($2)`,
      [fx.companyId, [mine, theirs]],
    );
    const tx = await statementLine({ amount: 242, date: '2026-11-22' });
    const message = await expectError(db, `select settle_from_statement($1, $2)`, [
      tx,
      lines.map((l) => l.line_id),
    ]);
    expect(message).toContain('mixed_contacts');
  });

  it('a line that is not an open item at all', async () => {
    const tx = await statementLine({ amount: 121, date: '2026-12-01' });
    const message = await expectError(db, `select settle_from_statement($1, $2)`, [
      tx,
      [crypto.randomUUID()],
    ]);
    expect(message).toContain('line_not_open');
  });

  it('naming no line at all', async () => {
    const tx = await statementLine({ amount: 121, date: '2026-12-02' });
    const message = await expectError(db, `select settle_from_statement($1, $2)`, [tx, []]);
    expect(message).toContain('no_lines_named');
  });
});
