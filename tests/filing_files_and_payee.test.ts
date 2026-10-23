import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, newUser, type Fixture } from './helpers/factory.js';
import { allPacks, packWhere } from './helpers/packs.js';

/**
 * A declaration names its files, is paid to somebody, and says so
 * (`20261023124650`, decision 0087).
 *
 *   1. the two files of a send are named by `record_filing_files()`, on the
 *      last deposit, and what does not fit is refused by name: nothing sent
 *      yet, a declaration a corrective replaced, a file of another company, a
 *      file kept on something else, no file at all, one file twice, a member
 *      who may not file;
 *   2. the administration is a contact of the company: `tax_payee()` finds the
 *      one contact that books to the account the pack names, or creates it
 *      under the name the pack gives, and `settle_filing()` names it when its
 *      caller names nobody;
 *   3. the debt matched in full makes the declaration paid, and undoing the
 *      matching makes it accepted again.
 *
 * The pack under test is one that names both the account and the
 * administration; every name and code comes from its own files.
 */

interface Payee {
  name: string;
  source: string;
}

const payeeOf = (p: (typeof allPacks)[number]): Payee | undefined =>
  p.manifest.defaults['tax_payee'] as Payee | undefined;

const pack = packWhere(
  'names the administration a declaration is paid to, and the account it owes on',
  (p) =>
    payeeOf(p) !== undefined &&
    typeof p.manifest.defaults.roles['tax_payable'] === 'string' &&
    p.report !== null &&
    p.report.boxes.length > 0 &&
    (p.golden?.documents ?? []).some(
      (d) => d.type === 'sale_invoice' && d.lines.some((l) => l.tax && l.account),
    ),
);

const PAYEE = payeeOf(pack)!;
const PAYABLE = pack.manifest.defaults.roles['tax_payable'] as string;
const RECEIVABLE = (pack.manifest.defaults.roles['tax_receivable'] as string | undefined) ?? PAYABLE;

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
  ],
  quarter: [
    ['2026-01-01', '2026-03-31'],
    ['2026-04-01', '2026-06-30'],
    ['2026-07-01', '2026-09-30'],
  ],
  year: [
    ['2026-01-01', '2026-12-31'],
    ['2027-01-01', '2027-12-31'],
    ['2028-01-01', '2028-12-31'],
  ],
};
const periods = PERIODS[pack.report?.period_default ?? 'month'] ?? PERIODS['month']!;

let db: PGlite;
let fx: Fixture;
let other: Fixture;
let customerId: string;
let bankAccountId: string;
let sequence = 0;

interface Filing {
  id: string;
  state: string;
  settlement_entry_id: string | null;
}

interface Deposit {
  sequence: number;
  sent_file_id: string | null;
  acknowledgement_id: string | null;
  outcome: string | null;
}

async function sale(number: string, date: string, amount: number): Promise<void> {
  const documentId = await newDocument(db, fx.companyId, {
    docType: 'sale_invoice',
    number,
    contactId: customerId,
    date,
    lines: [{ unitPrice: amount, taxCode: SALE.tax, accountCode: SALE.account }],
  });
  await db.query(`select post_document($1)`, [documentId]);
}

async function prepared(from: string, to: string): Promise<Filing> {
  return one<Filing>(db, `select * from prepare_filing($1, $2::date, $3::date)`, [
    fx.companyId,
    from,
    to,
  ]);
}

async function attach(companyId: string, entityType: string, entityId: string, name: string): Promise<string> {
  const row = await one<{ id: string }>(
    db,
    `insert into attachments (company_id, entity_type, entity_id, file_name, storage_path)
     values ($1, $2, $3, $4, $5) returning id`,
    [companyId, entityType, entityId, name, `${entityType}/${entityId}/${name}`],
  );
  return row.id;
}

async function deposits(filingId: string): Promise<Deposit[]> {
  return rows<Deposit>(
    db,
    `select sequence, sent_file_id, acknowledgement_id, outcome
       from tax_filing_deposits where filing_id = $1 order by sequence`,
    [filingId],
  );
}

async function payees(companyId: string): Promise<{ id: string; name: string }[]> {
  return rows<{ id: string; name: string }>(
    db,
    `select k.id, k.name from contacts k
      where k.company_id = $1 and k.active
        and k.payable_account_id = (select id from accounts where company_id = $1 and code = $2)
      order by k.created_at`,
    [companyId, PAYABLE],
  );
}

beforeAll(async () => {
  db = await freshDatabase();
  // country-literal: the company is installed in the pack under test, which is
  // whichever one names its administration.
  fx = await newCompany(db, { country: pack.manifest.country, name: 'Payee Fixture' });
  other = await newCompany(db, { country: pack.manifest.country, name: 'Another Company' });
  customerId = await newContact(db, fx.companyId, { name: 'Client', country: pack.manifest.country });
  const account = await one<{ id: string }>(
    db,
    `insert into bank_accounts (company_id, name, currency_code, journal_id)
     select $1, 'Bank', c.currency_code,
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

describe('the files of a send', () => {
  const [from, to] = periods[0]!;
  let filing: Filing;
  let sent: string;
  let receipt: string;

  beforeAll(async () => {
    await sale('FILES-1', from, 4_000);
    filing = await prepared(from, to);
  });

  it('are refused on a declaration that has not been sent', async () => {
    sent = await attach(fx.companyId, 'tax_filing', filing.id, 'return.xml');
    const message = await expectError(db, `select record_filing_files($1, $2)`, [filing.id, sent]);
    expect(message).toContain('filing_not_sent');
    expect(message).toContain('file_filing()');
  });

  it('are named on the last deposit, the receipt later than the file', async () => {
    await db.query(`select file_filing($1, 'FILES-DEP-1')`, [filing.id]);
    const first = await one<Deposit>(db, `select * from record_filing_files($1, $2)`, [filing.id, sent]);
    expect(first.sent_file_id).toBe(sent);
    expect(first.acknowledgement_id).toBeNull();

    receipt = await attach(fx.companyId, 'tax_filing', filing.id, 'acknowledgement.pdf');
    const second = await one<Deposit>(db, `select * from record_filing_files($1, null, $2)`, [
      filing.id,
      receipt,
    ]);
    // A file left null keeps what the deposit named.
    expect(second.sent_file_id).toBe(sent);
    expect(second.acknowledgement_id).toBe(receipt);

    const named = await one<{ yes: boolean }>(db, `select attachment_is_filing_deposit_file($1) as yes`, [receipt]);
    expect(named.yes).toBe(true);
  });

  it('go on the send they belong to, which is the last one', async () => {
    await db.query(`select record_filing_outcome($1, 'rejected', null, 'Refused')`, [filing.id]);
    await db.query(`select file_filing($1, 'FILES-DEP-2')`, [filing.id]);
    const again = await attach(fx.companyId, 'tax_filing', filing.id, 'return-again.xml');
    await db.query(`select record_filing_files($1, $2)`, [filing.id, again]);

    const sends = await deposits(filing.id);
    expect(sends.map((d) => d.sent_file_id)).toEqual([sent, again]);
    expect(sends[0]!.acknowledgement_id).toBe(receipt);
    expect(sends[1]!.acknowledgement_id).toBeNull();
  });

  it('are refused when there is none, or one twice', async () => {
    expect(await expectError(db, `select record_filing_files($1)`, [filing.id])).toContain('no_file_named');
    expect(
      await expectError(db, `select record_filing_files($1, $2, $2)`, [filing.id, receipt]),
    ).toContain('same_file_twice');
  });

  it('are refused when the file is another company’s, in the words a file of nobody gets', async () => {
    const foreign = await attach(other.companyId, 'tax_filing', filing.id, 'foreign.xml');
    const theirs = await expectError(db, `select record_filing_files($1, $2)`, [filing.id, foreign]);
    const nobodys = await expectError(db, `select record_filing_files($1, $2)`, [
      filing.id,
      crypto.randomUUID(),
    ]);
    expect(theirs).toContain('unknown_attachment');
    expect(nobodys).toContain('unknown_attachment');
    expect(theirs.replace(foreign, '?')).toBe(nobodys.replace(/[0-9a-f-]{36}/, '?'));
  });

  it('are refused when the file is kept on something else', async () => {
    const onACustomer = await attach(fx.companyId, 'contact', customerId, 'letter.pdf');
    const onAContact = await expectError(db, `select record_filing_files($1, $2)`, [filing.id, onACustomer]);
    expect(onAContact).toContain('attachment_not_of_filing');
    expect(onAContact).toContain('contact');

    const [second, secondEnd] = periods[1]!;
    await sale('FILES-2', second, 1_000);
    const another = await prepared(second, secondEnd);
    const ofAnother = await attach(fx.companyId, 'tax_filing', another.id, 'other-return.xml');
    expect(
      await expectError(db, `select record_filing_files($1, $2)`, [filing.id, ofAnother]),
    ).toContain('attachment_not_of_filing');
  });

  it('are refused to a member who may not file, and recorded for one who may', async () => {
    const reader = await newUser(db);
    const filer = await newUser(db);
    await db.query(
      `insert into company_members (company_id, user_id, role, capabilities_revoked)
       values ($1, $2, 'accountant', array['filings.write']), ($1, $3, 'accountant', '{}')`,
      [fx.companyId, reader, filer],
    );
    const refused = await asUser(db, reader, () =>
      expectError(db, `select record_filing_files($1, null, $2)`, [filing.id, receipt]),
    );
    expect(refused).toContain('not_allowed');
    expect(refused).toContain('filings.write');

    const kept = await asUser(db, filer, () =>
      one<Deposit>(db, `select * from record_filing_files($1, null, $2)`, [filing.id, receipt]),
    );
    expect(kept.acknowledgement_id).toBe(receipt);
  });

  it('are refused on a declaration a corrective replaced', async () => {
    await db.query(`select record_filing_outcome($1, 'accepted')`, [filing.id]);
    await db.query(`select supersede_filing($1)`, [filing.id]);
    expect(await expectError(db, `select record_filing_files($1, $2)`, [filing.id, sent])).toContain(
      'filing_superseded',
    );
  });
});

describe('the administration', () => {
  it('is created on first need, under the name the pack gives, on the accounts settling uses', async () => {
    expect(await payees(other.companyId)).toEqual([]);
    const payee = await one<{ id: string; name: string; payable: string; receivable: string }>(
      db,
      `select p.id, p.name,
              (select code from accounts where id = p.payable_account_id) as payable,
              (select code from accounts where id = p.receivable_account_id) as receivable
         from tax_payee($1) p`,
      [other.companyId],
    );
    expect(payee.name).toBe(PAYEE.name);
    expect(payee.payable).toBe(PAYABLE);
    expect(payee.receivable).toBe(RECEIVABLE);

    // Asked again, it is the same contact: the account is the link.
    const again = await one<{ id: string }>(db, `select id from tax_payee($1)`, [other.companyId]);
    expect(again.id).toBe(payee.id);
    expect(await payees(other.companyId)).toHaveLength(1);
  });

  it('is the contact that already books to the account, whatever it is called', async () => {
    const own = await newContact(db, fx.companyId, { name: 'Our tax office', country: pack.manifest.country });
    await db.query(
      `update contacts set payable_account_id = (select id from accounts where company_id = $1 and code = $2)
        where id = $3`,
      [fx.companyId, PAYABLE, own],
    );
    const found = await one<{ id: string; receivable: string }>(
      db,
      `select p.id, (select code from accounts where id = p.receivable_account_id) as receivable
         from tax_payee($1) p`,
      [fx.companyId],
    );
    expect(found.id).toBe(own);
    // A contact that said nothing about a credit is given the account the
    // pack names for it: a refund comes from the same administration.
    expect(found.receivable).toBe(RECEIVABLE);
  });

  it('is named by settling when its caller names nobody, and the payment makes it paid', async () => {
    const [from, to] = periods[2]!;
    await sale('PAYEE-1', from, 10_000);
    const filing = await prepared(from, to);
    await db.query(`select file_filing($1, 'PAYEE-DEP')`, [filing.id]);
    await db.query(`select record_filing_outcome($1, 'accepted')`, [filing.id]);
    const entry = await one<{ id: string }>(
      db,
      `select id from settle_filing($1, null, 'PAYEE-REF')`,
      [filing.id],
    );
    const debt = await one<{ line_id: string; contact_id: string; amount_open: string }>(
      db,
      `select o.line_id, o.contact_id, o.amount_open::text from open_items($1) o
         join entry_lines l on l.id = o.line_id where l.entry_id = $2`,
      [fx.companyId, entry.id],
    );
    const payee = await one<{ id: string }>(db, `select id from tax_payee($1)`, [fx.companyId]);
    expect(debt.contact_id).toBe(payee.id);

    // Half the money: still accepted, the debt is open.
    const pay = async (amount: number): Promise<string> => {
      sequence += 1;
      const line = await one<{ id: string }>(
        db,
        `insert into bank_transactions
           (company_id, bank_account_id, sequence, transaction_date, amount, currency_code,
            description, reference, state)
         select $1, $2, $3, $4::date, $5, c.currency_code, 'Tax payment', 'PAYEE-REF', 'pending'
           from companies c where c.id = $1
         returning id`,
        [fx.companyId, bankAccountId, sequence, to, -amount],
      );
      await db.query(`select settle_from_statement($1, $2::uuid[])`, [line.id, [debt.line_id]]);
      return line.id;
    };
    const owed = Number(debt.amount_open);
    const half = Math.round(owed * 50) / 100;
    await pay(half);
    expect((await one<Filing>(db, `select * from tax_filings where id = $1`, [filing.id])).state).toBe(
      'accepted',
    );

    // The rest: paid, on the declaration and on the send it answers.
    await pay(Math.round((owed - half) * 100) / 100);
    expect((await one<Filing>(db, `select * from tax_filings where id = $1`, [filing.id])).state).toBe(
      'paid',
    );
    expect((await deposits(filing.id)).at(-1)!.outcome).toBe('paid');

    // Undone, the debt is open again and so is the declaration's money.
    const last = await one<{ id: string }>(
      db,
      `select r.id from reconciliations r where r.debit_line_id = $1 or r.credit_line_id = $1
        order by r.created_at desc limit 1`,
      [debt.line_id],
    );
    await db.query(`select unreconcile($1)`, [last.id]);
    expect((await one<Filing>(db, `select * from tax_filings where id = $1`, [filing.id])).state).toBe(
      'accepted',
    );
  });

  it('is refused when several contacts book to the account and none carries the pack’s name', async () => {
    const second = await newContact(db, fx.companyId, { name: 'Another office', country: pack.manifest.country });
    await db.query(
      `update contacts set payable_account_id = (select id from accounts where company_id = $1 and code = $2)
        where id = $3`,
      [fx.companyId, PAYABLE, second],
    );
    const message = await expectError(db, `select tax_payee($1)`, [fx.companyId]);
    expect(message).toContain('several_tax_payees');
    expect(message).toContain('Another office');

    // One of them under the pack's name settles the question.
    await db.query(`update contacts set name = $2 where id = $1`, [second, PAYEE.name]);
    const found = await one<{ id: string }>(db, `select id from tax_payee($1)`, [fx.companyId]);
    expect(found.id).toBe(second);
  });

  it('is asked of a member who may file', async () => {
    const reader = await newUser(db);
    await db.query(
      `insert into company_members (company_id, user_id, role, capabilities_revoked)
       values ($1, $2, 'accountant', array['filings.write'])`,
      [other.companyId, reader],
    );
    const message = await asUser(db, reader, () => expectError(db, `select tax_payee($1)`, [other.companyId]));
    expect(message).toContain('not_allowed');
  });

  it('is unknown where the pack names none and nobody books to the account', async () => {
    const silent = allPacks.find(
      (p) => payeeOf(p) === undefined && typeof p.manifest.defaults.roles['tax_payable'] === 'string',
    );
    if (silent === undefined) return; // every pack names its administration
    // country-literal: the company is installed in a pack that names no
    // administration, which is the situation under test.
    const quiet = await newCompany(db, { country: silent.manifest.country, name: 'Quiet Pack Fixture' });
    const answer = await one<{ id: string | null }>(db, `select (tax_payee($1)).id as id`, [quiet.companyId]);
    expect(answer.id).toBeNull();
  });
});
