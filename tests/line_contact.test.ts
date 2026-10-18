import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, newUser, type Fixture } from './helpers/factory.js';
import { newMember, plainSale, refusalAs } from './helpers/integrity.js';

// Decision 0070: an open line on a receivable or payable account that names
// nobody — the open items of books brought in line by line — is suggested a
// contact by the scoring statement lines use, and named once by
// set_line_contact(), which the guard of a posted line lets through and the
// trail records.

let db: PGlite;
let fx: Fixture;
let accountant: string;
let viewer: string;
let sale: { taxCode: string; accountCode: string };
let receivable: string;
let payable: string;
/** A reconcilable account that is neither a receivable nor a payable: the bank's, in most charts. */
let otherReconcilable: string;
let income: string;
let alpha: string;
let gamma: string;
let zephyr: string;
let omega: string;
let number = 0;

interface Suggestion {
  line_id: string;
  contact_id: string;
  name: string;
  score: string;
  method: string;
  because: string;
  alternatives: number;
}

const NOWHERE = '7d0f0b4e-0000-4000-8000-00000000abcd';
const UUID = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/g;

/** An account of the company by its type, as the pack gives it: never a code. */
async function accountOfType(companyId: string, where: string): Promise<string> {
  return (
    await one<{ id: string }>(db, `select id from accounts where company_id = $1 and ${where} order by code limit 1`, [
      companyId,
    ])
  ).id;
}

/**
 * A posted entry keyed by hand, the way an import brings it: 50 on `account`
 * against `other`, the first line labelled `name` and naming nobody. Returns
 * the first line; `state` leaves it a draft.
 */
async function anonymousLine(options: {
  companyId?: string;
  account: string;
  other: string;
  name: string;
  side?: 'debit' | 'credit';
  description?: string | null;
  reference?: string | null;
  state?: 'draft' | 'posted';
}): Promise<string> {
  const companyId = options.companyId ?? fx.companyId;
  const entry = await one<{ id: string }>(
    db,
    `insert into entries (company_id, journal_id, entry_date, state, currency_code, description, reference)
     select c.id, c.miscellaneous_journal_id, '2026-04-02', 'draft', c.currency_code, $2, $3 from companies c where c.id = $1
     returning id`,
    [companyId, options.description ?? null, options.reference ?? null],
  );
  const [debit, credit] = (options.side ?? 'debit') === 'debit' ? [50, 0] : [0, 50];
  const line = await one<{ id: string }>(
    db,
    `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit)
     values ($1, $2, $3, 10, $4, $5, $6) returning id`,
    [entry.id, companyId, options.account, options.name, debit, credit],
  );
  await db.query(
    `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit)
     values ($1, $2, $3, 20, $4, $5, $6)`,
    [entry.id, companyId, options.other, options.name, credit, debit],
  );
  if ((options.state ?? 'posted') === 'posted') await db.query(`select post_entry($1)`, [entry.id]);
  return line.id;
}

/** A posted invoice of 100 plus tax to `contact`, under the number given. Returns its receivable line. */
async function invoice(contact: string, invoiceNumber: string): Promise<string> {
  const documentId = await newDocument(db, fx.companyId, {
    docType: 'sale_invoice',
    number: invoiceNumber,
    contactId: contact,
    date: '2026-04-01',
    lines: [{ unitPrice: 100, taxCode: sale.taxCode, accountCode: sale.accountCode }],
  });
  await db.query(`select post_document($1)`, [documentId]);
  return (
    await one<{ line_id: string }>(db, `select line_id from open_items($1) where document_id = $2`, [
      fx.companyId,
      documentId,
    ])
  ).line_id;
}

async function suggestionsFor(lineId: string, companyId = fx.companyId): Promise<Suggestion[]> {
  return rows<Suggestion>(db, `select * from suggest_line_contacts($1, $2)`, [companyId, [lineId]]);
}

const fresh = (): string => `LC-${(number += 1).toString().padStart(5, '0')}`;

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db);
  accountant = await newMember(db, fx.companyId, 'accountant');
  viewer = await newMember(db, fx.companyId, 'viewer');
  sale = await plainSale(db, fx.companyId);
  payable = await accountOfType(fx.companyId, `account_type = 'liability_payable' and reconcilable`);
  otherReconcilable = await accountOfType(
    fx.companyId,
    `reconcilable and account_type not in ('asset_receivable', 'liability_payable')`,
  );
  income = await accountOfType(fx.companyId, `account_type = 'income'`);
  alpha = await newContact(db, fx.companyId, { name: 'Alpha Industries' });
  gamma = await newContact(db, fx.companyId, { name: 'Gamma Works', type: 'supplier' });
  zephyr = await newContact(db, fx.companyId, { name: 'Zephyr Logistics' });
  omega = await newContact(db, fx.companyId, { name: 'Omega Holdings', type: 'supplier' });
  // The receivable an invoice is booked on, so that a line keyed by hand can be
  // matched against one.
  const first = await invoice(alpha, fresh());
  receivable = (await one<{ account_id: string }>(db, `select account_id from entry_lines where id = $1`, [first])).account_id;
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('suggest_line_contacts()', () => {
  it('names the contact of a document whose number the line quotes, very high and alone', async () => {
    const quoted = fresh();
    await invoice(alpha, quoted);
    const line = await anonymousLine({ account: receivable, other: income, name: `Invoice ${quoted} - imported` });
    const [best] = await suggestionsFor(line);
    expect(best).toMatchObject({ line_id: line, contact_id: alpha, name: 'Alpha Industries', method: 'document', alternatives: 1 });
    expect(Number(best?.score)).toBeGreaterThan(0.95);
    expect(best?.because).toContain(quoted);
  });

  it('finds the number in the description or the reference of the entry, and the supplier’s number of a purchase', async () => {
    const theirs = fresh();
    const bill = await newDocument(db, fx.companyId, {
      docType: 'purchase_invoice',
      contactId: gamma,
      date: '2026-04-01',
      lines: [{ unitPrice: 80, accountCode: sale.accountCode }],
    });
    await db.query(`update documents set supplier_reference = $2 where id = $1`, [bill, theirs]);
    const line = await anonymousLine({
      account: payable,
      other: income,
      side: 'credit',
      name: 'Purchases',
      reference: `n°${theirs}.`,
    });
    const [best] = await suggestionsFor(line);
    expect(best).toMatchObject({ contact_id: gamma, method: 'document' });
  });

  it('reads documents of the line’s own side only: a sale number on a payable line is no evidence', async () => {
    const quoted = fresh();
    await invoice(alpha, quoted);
    const line = await anonymousLine({ account: payable, other: income, side: 'credit', name: `Bill ${quoted}` });
    expect((await suggestionsFor(line)).filter((s) => s.method === 'document')).toEqual([]);
  });

  it('scores the words of a contact’s name the way a statement line is scored', async () => {
    const line = await anonymousLine({ account: receivable, other: income, name: 'Transfer', description: 'Zephyr Logistics, March' });
    const [best] = await suggestionsFor(line);
    expect(best).toMatchObject({ contact_id: zephyr, method: 'name', alternatives: 1 });
    expect(Number(best?.score)).toBe(0.9);
    expect(best?.because).toMatch(/^the name on the line shares (logistics, zephyr|zephyr, logistics) with Zephyr Logistics$/);
  });

  it('answers only open third-party lines that name nobody, and only for the company asked', async () => {
    const onOther = await anonymousLine({ account: otherReconcilable, other: income, name: 'Zephyr Logistics' });
    const draft = await anonymousLine({ account: receivable, other: income, name: 'Zephyr Logistics', state: 'draft' });
    expect(await suggestionsFor(onOther)).toEqual([]);
    expect(await suggestionsFor(draft)).toEqual([]);

    const all = await rows<{ line_id: string }>(db, `select distinct line_id from suggest_line_contacts($1)`, [fx.companyId]);
    expect(all.length).toBeGreaterThan(0);
    const named = await rows<{ n: number }>(
      db,
      `select count(*)::int as n from entry_lines where id = any($1) and contact_id is not null`,
      [all.map((r) => r.line_id)],
    );
    expect(named[0]?.n).toBe(0);
  });
});

describe('set_line_contact()', () => {
  it('names the line once, writes the trail and teaches the label as a motif', async () => {
    const line = await anonymousLine({ account: receivable, other: income, name: 'Settlement Kappa North' });
    const named = await asUser(db, accountant, () =>
      one<{ id: string; contact_id: string }>(db, `select id, contact_id from set_line_contact($1, $2)`, [line, zephyr]),
    );
    expect(named).toEqual({ id: line, contact_id: zephyr });

    const trail = await one<{ action: string; actor_id: string; old_values: unknown; new_values: unknown }>(
      db,
      `select action, actor_id, old_values, new_values from audit_log
        where table_name = 'entry_lines' and record_id = $1`,
      [line],
    );
    expect(trail).toEqual({
      action: 'line_contact_named',
      actor_id: accountant,
      old_values: { contact_id: null },
      new_values: { contact_id: zephyr },
    });

    const motif = await one<{ kind: string; source: string; success_count: number }>(
      db,
      `select kind, source, success_count from contact_patterns where contact_id = $1 and value = 'Settlement Kappa North'`,
      [zephyr],
    );
    expect(motif).toEqual({ kind: 'name_variation', source: 'learned', success_count: 1 });

    const items = await rows<{ line_id: string }>(db, `select line_id from open_items($1, $2)`, [fx.companyId, zephyr]);
    expect(items.map((i) => i.line_id)).toContain(line);
  });

  it('suggests a contact the next time from what was learned, and charges a motif that named somebody else', async () => {
    const label = 'Rent of the warehouse, quarterly';
    const first = await anonymousLine({ account: payable, other: income, side: 'credit', name: label });
    expect((await suggestionsFor(first)).filter((s) => s.contact_id === omega)).toEqual([]);
    await asUser(db, accountant, () => db.query(`select set_line_contact($1, $2)`, [first, omega]));

    const second = await anonymousLine({ account: payable, other: income, side: 'credit', name: label });
    const [best] = await suggestionsFor(second);
    expect(best).toMatchObject({ contact_id: omega, method: 'pattern:name_variation', alternatives: 1 });
    expect(best?.because).toContain('confirmed 1 of 1 times');

    // Somebody decides otherwise: the motif of Omega was in front of the
    // decision and lost it.
    await asUser(db, accountant, () => db.query(`select set_line_contact($1, $2)`, [second, gamma]));
    const charged = await one<{ usage_count: number; success_count: number }>(
      db,
      `select usage_count, success_count from contact_patterns where contact_id = $1 and value = $2`,
      [omega, label],
    );
    expect(charged).toEqual({ usage_count: 2, success_count: 1 });
  });

  it('teaches a statement line what a ledger line learned: one memory for both', async () => {
    const label = 'Omega Group Treasury';
    const line = await anonymousLine({ account: payable, other: income, side: 'credit', name: label });
    await asUser(db, accountant, () => db.query(`select set_line_contact($1, $2)`, [line, omega]));
    const bank = await one<{ id: string }>(
      db,
      `insert into bank_accounts (company_id, name, currency_code)
       select $1, 'Current account', currency_code from companies where id = $1 returning id`,
      [fx.companyId],
    );
    const tx = await one<{ id: string }>(
      db,
      `insert into bank_transactions (company_id, bank_account_id, sequence, transaction_date, amount,
                                      currency_code, counterpart_name, state)
       select $1, $2, 1, '2026-04-03', -50, currency_code, $3, 'pending' from companies where id = $1
       returning id`,
      [fx.companyId, bank.id, label],
    );
    const said = await rows<{ contact_id: string; method: string }>(db, `select contact_id, method from suggest_contacts($1)`, [tx.id]);
    expect(said).toContainEqual({ contact_id: omega, method: 'pattern:name_variation' });
  });

  it('refuses each case by its name', async () => {
    const line = await anonymousLine({ account: receivable, other: otherReconcilable, name: 'To be named' });
    const named = await anonymousLine({ account: receivable, other: income, name: 'Named already' });
    await asUser(db, accountant, () => db.query(`select set_line_contact($1, $2)`, [named, alpha]));
    const matchedLine = await anonymousLine({ account: receivable, other: income, name: 'Matched', side: 'credit' });
    await asUser(db, accountant, async () => {
      await db.query(`select reconcile($1, $2)`, [await invoice(alpha, fresh()), matchedLine]);
    });
    const draft = await anonymousLine({ account: receivable, other: income, name: 'A draft', state: 'draft' });
    const cash = (
      await one<{ id: string }>(db, `select id from entry_lines where entry_id = (select entry_id from entry_lines where id = $1) and id <> $1`, [line])
    ).id;
    const elsewhere = await newCompany(db, { name: 'Elsewhere' });
    const stranger = await newContact(db, elsewhere.companyId, { name: 'Zephyr Logistics' });

    const set = (lineId: string, contactId: string, who = accountant): Promise<string> =>
      refusalAs(db, who, `select set_line_contact($1, $2)`, [lineId, contactId]);

    expect(await set(NOWHERE, alpha)).toMatch(/^unknown_line\b/);
    expect(await set(named, zephyr)).toMatch(/^line_has_contact\b/);
    expect(await set(matchedLine, zephyr)).toMatch(/^line_matched\b/);
    expect(await set(cash, zephyr)).toMatch(/^line_not_third_party\b/);
    expect(await set(draft, zephyr)).toMatch(/^line_not_posted\b/);
    expect(await set(line, NOWHERE)).toMatch(/^unknown_contact\b/);
    expect(await set(line, stranger)).toMatch(/^unknown_contact\b/);
    expect(await set(line, zephyr, viewer)).toMatch(/^not_allowed\b.*reconcile\.write/);
    expect(await set(line, zephyr)).toBe('accepted');
  });
});

describe('the guard of a posted line', () => {
  it('still refuses the contact of a posted line written by hand', async () => {
    const line = await anonymousLine({ account: receivable, other: income, name: 'By hand' });
    expect(await refusalAs(db, accountant, `update entry_lines set contact_id = $2 where id = $1`, [line, alpha])).toMatch(
      /^entry_posted\b.*contact_id/,
    );
  });

  it('honours the setting for the line it names, for that column alone, and for a caller who may match', async () => {
    const line = await anonymousLine({ account: receivable, other: income, name: 'By hand, with the setting' });
    const other = await anonymousLine({ account: receivable, other: income, name: 'Another line' });
    const raise = (id: string): string => `select set_config('ekwo.naming_line_contact', '${id}', true)`;

    expect(await refusalAs(db, accountant, `update entry_lines set contact_id = $2 where id = $1`, [line, alpha], raise(other))).toMatch(
      /^entry_posted\b/,
    );
    expect(
      await refusalAs(db, accountant, `update entry_lines set contact_id = $2, name = 'Moved' where id = $1`, [line, alpha], raise(line)),
    ).toMatch(/^entry_posted\b.*contact_id, name/);

    const limited = await newMember(db, fx.companyId, 'accountant');
    await db.query(`update company_members set capabilities_revoked = '{reconcile.write}' where user_id = $1`, [limited]);
    expect(await refusalAs(db, limited, `update entry_lines set contact_id = $2 where id = $1`, [line, alpha], raise(line))).toMatch(
      /^not_allowed\b.*reconcile\.write/,
    );
  });
});

describe('open_items(…, p_third_party_only)', () => {
  it('keeps the receivable and payable lines alone, and answers as before when left out', async () => {
    await anonymousLine({ account: otherReconcilable, other: income, name: 'Bank side' });
    const typed = `select a.account_type::text as type from open_items($1, null, null, $2) o join accounts a on a.id = o.account_id`;
    const everything = await rows<{ type: string }>(db, typed, [fx.companyId, false]);
    const thirdParty = await rows<{ type: string }>(db, typed, [fx.companyId, true]);
    const leftOut = await rows<{ n: number }>(db, `select count(*)::int as n from open_items($1)`, [fx.companyId]);

    expect(leftOut[0]?.n).toBe(everything.length);
    expect(everything.some((r) => r.type !== 'asset_receivable' && r.type !== 'liability_payable')).toBe(true);
    expect(thirdParty.length).toBeGreaterThan(0);
    expect(thirdParty.every((r) => r.type === 'asset_receivable' || r.type === 'liability_payable')).toBe(true);
    expect(thirdParty.length).toBe(
      everything.filter((r) => r.type === 'asset_receivable' || r.type === 'liability_payable').length,
    );
  });
});

describe('on a shared installation', () => {
  it('tells a stranger about another company’s line and contact exactly what it says of none', async () => {
    await db.query(`select share_instance(1)`);
    const bob = await newUser(db);
    const bobs = await newCompany(db, { name: 'Bob books', ownerId: bob });
    const bobReceivable = await accountOfType(bobs.companyId, `account_type = 'asset_receivable'`);
    const bobIncome = await accountOfType(bobs.companyId, `account_type = 'income'`);
    const bobLine = await anonymousLine({ companyId: bobs.companyId, account: bobReceivable, other: bobIncome, name: 'Zephyr Logistics' });
    const bobContact = await newContact(db, bobs.companyId, { name: 'Bob customer' });
    const aliceLine = await anonymousLine({ account: receivable, other: income, name: 'Zephyr Logistics' });

    const scrub = (said: string): string => said.replace(UUID, '<id>');
    const asBob = (sql: string, params: unknown[]): Promise<string> => refusalAs(db, bob, sql, params).then(scrub);

    expect(await asBob(`select set_line_contact($1, $2)`, [aliceLine, bobContact])).toBe(
      await asBob(`select set_line_contact($1, $2)`, [NOWHERE, bobContact]),
    );
    expect(await asBob(`select set_line_contact($1, $2)`, [bobLine, zephyr])).toBe(
      await asBob(`select set_line_contact($1, $2)`, [bobLine, NOWHERE]),
    );
    expect(await asBob(`select set_line_contact($1, $2)`, [bobLine, zephyr])).toMatch(/^unknown_contact\b/);

    const seen = await asUser(db, bob, () =>
      rows(db, `select * from suggest_line_contacts($1, $2)`, [fx.companyId, [aliceLine]]),
    );
    expect(seen).toEqual([]);
    const own = await asUser(db, bob, () => rows<Suggestion>(db, `select * from suggest_line_contacts($1)`, [bobs.companyId]));
    expect(own.map((s) => s.contact_id)).not.toContain(zephyr);

    const untouched = await one<{ contact_id: string | null }>(db, `select contact_id from entry_lines where id = $1`, [aliceLine]);
    expect(untouched.contact_id).toBeNull();
  });
});
