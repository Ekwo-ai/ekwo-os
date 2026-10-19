import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, type Fixture } from './helpers/factory.js';
import { newMember, plainSale, refusalAs } from './helpers/integrity.js';

// Decision 0074: two contacts of one company are merged — every reference of
// the absorbed one moves onto the kept one, in one audited transaction, and
// the absorbed one is retired, never deleted.

let db: PGlite;
let fx: Fixture;
let other: Fixture;
let accountant: string;
let viewer: string;
let stranger: string;
let receivable: string;
let income: string;
let bankAccount: string;
let sale: { taxCode: string; accountCode: string };
let names = 0;
let statementSequence = 0;

interface Merge {
  id: string;
  company_id: string;
  kept_id: string;
  absorbed_id: string;
  moved: Record<string, number>;
  filled: string[];
  merged_by: string | null;
}

const NOWHERE = '7d0f0b4e-0000-4000-8000-00000000abcd';
const UUID = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/g;

async function accountOfType(companyId: string, where: string): Promise<string> {
  return (
    await one<{ id: string }>(db, `select id from accounts where company_id = $1 and ${where} order by code limit 1`, [
      companyId,
    ])
  ).id;
}

async function contact(name?: string, companyId = fx.companyId): Promise<string> {
  return newContact(db, companyId, { name: name ?? `Party ${(names += 1).toString().padStart(3, '0')}` });
}

/** A posted entry keyed by hand: `amount` on the receivable account, for `who`. Returns the line. */
async function item(amount: number, side: 'debit' | 'credit', who: string | null, companyId = fx.companyId): Promise<string> {
  const entry = await one<{ id: string }>(
    db,
    `insert into entries (company_id, journal_id, entry_date, state, currency_code, description)
     select c.id, c.miscellaneous_journal_id, '2026-04-02', 'draft', c.currency_code, 'Item' from companies c where c.id = $1
     returning id`,
    [companyId],
  );
  const [debit, credit] = side === 'debit' ? [amount, 0] : [0, amount];
  const account = companyId === fx.companyId ? receivable : await accountOfType(companyId, `account_type = 'asset_receivable' and reconcilable`);
  const against = companyId === fx.companyId ? income : await accountOfType(companyId, `account_type = 'income' and not reconcilable`);
  const created = await one<{ id: string }>(
    db,
    `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit, contact_id)
     values ($1, $2, $3, 10, 'Item', $4, $5, $6) returning id`,
    [entry.id, companyId, account, debit, credit, who],
  );
  await db.query(
    `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit)
     values ($1, $2, $3, 20, 'Item', $4, $5)`,
    [entry.id, companyId, against, credit, debit],
  );
  await db.query(`select post_entry($1)`, [entry.id]);
  return created.id;
}

/** A sale invoice of 100 before tax to `who`, posted. Returns the document. */
async function postedInvoice(who: string): Promise<string> {
  const doc = await newDocument(db, fx.companyId, {
    docType: 'sale_invoice',
    contactId: who,
    lines: [{ unitPrice: 100, taxCode: sale.taxCode, accountCode: sale.accountCode }],
  });
  await db.query(`select post_document($1)`, [doc]);
  return doc;
}

/** The invoice's open line on the receivable account. */
async function lineOf(documentId: string): Promise<string> {
  return (
    await one<{ id: string }>(
      db,
      `select l.id from entry_lines l join documents d on d.entry_id = l.entry_id
        where d.id = $1 and l.account_id = $2`,
      [documentId, receivable],
    )
  ).id;
}

async function merge(keep: string, absorb: string, who = accountant): Promise<Merge> {
  return asUser(db, who, () => one<Merge>(db, `select * from merge_contacts($1, $2)`, [keep, absorb]));
}

/** Every column of the schema that references contacts, read from the catalogue. */
async function references(): Promise<{ tbl: string; col: string }[]> {
  return rows<{ tbl: string; col: string }>(
    db,
    `select c.conrelid::regclass::text as tbl, a.attname as col
       from pg_constraint c
       join unnest(c.conkey) as k(attnum) on true
       join pg_attribute a on a.attrelid = c.conrelid and a.attnum = k.attnum
      where c.contype = 'f' and c.confrelid = 'public.contacts'::regclass and a.attname <> 'company_id'
      order by 1, 2`,
  );
}

async function namingCount(tbl: string, col: string, id: string): Promise<number> {
  return Number((await one<{ n: string }>(db, `select count(*) as n from ${tbl} where ${col} = $1`, [id])).n);
}

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db);
  other = await newCompany(db, { name: 'Another Company' });
  accountant = await newMember(db, fx.companyId, 'accountant');
  viewer = await newMember(db, fx.companyId, 'viewer');
  stranger = await newMember(db, other.companyId, 'accountant');
  receivable = await accountOfType(fx.companyId, `account_type = 'asset_receivable' and reconcilable`);
  income = await accountOfType(fx.companyId, `account_type = 'income' and not reconcilable`);
  sale = await plainSale(db, fx.companyId);
  bankAccount = (
    await one<{ id: string }>(
      db,
      `insert into bank_accounts (company_id, name, currency_code, journal_id)
       select c.id, 'Current account', c.currency_code,
              (select j.id from journals j where j.company_id = c.id and j.journal_type = 'bank' order by j.code limit 1)
         from companies c where c.id = $1
       returning id`,
      [fx.companyId],
    )
  ).id;
}, 300_000);

afterAll(async () => {
  await db?.close();
});

// ---------------------------------------------------------------------------
// What moves
// ---------------------------------------------------------------------------

describe('merge_contacts() moves every reference', () => {
  it('moves posted lines, issued and draft documents, statement lines, payments, branches, files and motifs', async () => {
    const keep = await contact('Marlow Jane');
    const absorb = await contact('Jane Marlow');

    const invoice = await postedInvoice(absorb);
    const draft = await newDocument(db, fx.companyId, {
      docType: 'sale_invoice',
      contactId: absorb,
      lines: [{ unitPrice: 40, taxCode: sale.taxCode, accountCode: sale.accountCode }],
    });
    const byHand = await item(75, 'debit', absorb);
    const statementLine = (
      await one<{ id: string }>(
        db,
        `insert into bank_transactions (company_id, bank_account_id, sequence, transaction_date, amount, contact_id)
         values ($1, $2, $3, '2026-03-05', 12.5, $4) returning id`,
        [fx.companyId, bankAccount, (statementSequence += 1), absorb],
      )
    ).id;
    const payment = (
      await one<{ id: string }>(
        db,
        `insert into payments (company_id, direction, payment_date, amount, currency_code, contact_id, journal_id)
         select c.id, 'inbound', '2026-04-10', 30, c.currency_code, $2,
                (select j.id from journals j where j.company_id = c.id and j.journal_type = 'bank' order by j.code limit 1)
           from companies c where c.id = $1
         returning id`,
        [fx.companyId, absorb],
      )
    ).id;
    const branch = await contact('Jane Marlow, workshop');
    await db.query(`update contacts set parent_id = $1 where id = $2`, [absorb, branch]);
    const file = (
      await one<{ id: string }>(
        db,
        `insert into attachments (company_id, entity_type, entity_id, file_name, storage_path)
         values ($1, 'contact', $2, 'card.pdf', 'contacts/card.pdf') returning id`,
        [fx.companyId, absorb],
      )
    ).id;
    // A module's row names the contact too: read from the catalogue like the rest.
    const asset = (
      await one<{ id: string }>(
        db,
        `insert into fixed_assets.fixed_assets (company_id, code, name, contact_id, acquisition_date, cost, duration_months,
                                                asset_account_id, depreciation_account_id, expense_account_id)
         values ($1, 'A-1', 'Lathe', $2, '2026-01-10', 900, 60, $3, $3, $3) returning id`,
        [fx.companyId, absorb, income],
      )
    ).id;

    const merged = await merge(keep, absorb);

    // Nothing in the schema names the absorbed contact any more, but its own
    // record and the record of the merge.
    for (const ref of await references()) {
      if (ref.tbl === 'contact_merges') continue;
      expect(await namingCount(ref.tbl, ref.col, absorb), `${ref.tbl}.${ref.col}`).toBe(0);
    }
    expect(await namingCount('attachments', 'entity_id', absorb)).toBe(0);

    const postedLines = await rows<{ contact_id: string }>(
      db,
      `select l.contact_id from entry_lines l join documents d on d.entry_id = l.entry_id
        where d.id = $1 and l.contact_id is not null`,
      [invoice],
    );
    expect(postedLines.length).toBeGreaterThan(0);
    expect(postedLines.every((l) => l.contact_id === keep)).toBe(true);
    expect(await one(db, `select contact_id, state from documents where id = $1`, [invoice])).toEqual({
      contact_id: keep,
      state: 'posted',
    });
    expect(await one(db, `select contact_id from documents where id = $1`, [draft])).toEqual({ contact_id: keep });
    expect(await one(db, `select contact_id from entry_lines where id = $1`, [byHand])).toEqual({ contact_id: keep });
    expect(await one(db, `select contact_id from bank_transactions where id = $1`, [statementLine])).toEqual({ contact_id: keep });
    expect(await one(db, `select contact_id from payments where id = $1`, [payment])).toEqual({ contact_id: keep });
    expect(await one(db, `select parent_id from contacts where id = $1`, [branch])).toEqual({ parent_id: keep });
    expect(await one(db, `select entity_id from attachments where id = $1`, [file])).toEqual({ entity_id: keep });
    expect(await one(db, `select contact_id from fixed_assets.fixed_assets where id = $1`, [asset])).toEqual({ contact_id: keep });

    expect(merged.moved).toMatchObject({
      entry_lines: postedLines.length + 1,
      documents: 2,
      bank_transactions: 1,
      payments: 1,
      'contacts.parent_id': 1,
      attachments: 1,
      'fixed_assets.fixed_assets': 1,
    });

    // Retired, not deleted.
    expect(await one(db, `select active, merged_into, name from contacts where id = $1`, [absorb])).toEqual({
      active: false,
      merged_into: keep,
      name: 'Jane Marlow',
    });
    expect(merged).toMatchObject({ company_id: fx.companyId, kept_id: keep, absorbed_id: absorb, merged_by: accountant });
    expect(await one(db, `select active, merged_into from contacts where id = $1`, [keep])).toEqual({ active: true, merged_into: null });

    // The record of the act, and the trail.
    expect(
      await one(db, `select kept_id, absorbed_id, merged_by, moved from contact_merges where id = $1`, [merged.id]),
    ).toEqual({ kept_id: keep, absorbed_id: absorb, merged_by: accountant, moved: merged.moved });
    const trail = await rows<{ action: string; n: number }>(
      db,
      `select action, count(*) as n from audit_log
        where company_id = $1 and action in ('contacts_merged', 'line_contact_merged', 'document_contact_merged')
          and (record_id = $2 or new_values ->> 'contact_id' = $3::text)
        group by action order by action`,
      [fx.companyId, absorb, keep],
    );
    expect(trail).toEqual([
      { action: 'contacts_merged', n: 1 },
      { action: 'document_contact_merged', n: 1 },
      { action: 'line_contact_merged', n: postedLines.length + 1 },
    ]);
    const act = await one<{ actor_id: string; new_values: { merged_into: string; moved: Record<string, number> } }>(
      db,
      `select actor_id, new_values from audit_log where action = 'contacts_merged' and record_id = $1`,
      [absorb],
    );
    expect(act.actor_id).toBe(accountant);
    expect(act.new_values.merged_into).toBe(keep);
    expect(act.new_values.moved).toEqual(merged.moved);
  });

  it('fills the empty fields of the kept contact and overwrites none', async () => {
    const keep = await contact();
    const absorb = await contact();
    await db.query(`update contacts set email = 'kept@example.test', contact_type = 'customer', country = null where id = $1`, [keep]);
    await db.query(
      `update contacts set vat_number = 'TEST-VAT-0001', email = 'absorbed@example.test', iban = 'TEST-IBAN-01', bic = 'TESTBIC1',
              address_line1 = '1 Mill Street', postal_code = '1000', city = 'Riverside',
              auxiliary_code = 'AUX-ABS', contact_type = 'supplier'
        where id = $1`,
      [absorb],
    );

    const merged = await merge(keep, absorb);
    expect(await one(db, `select vat_number, email, iban, bic, address_line1, postal_code, city, auxiliary_code, contact_type from contacts where id = $1`, [keep])).toEqual({
      vat_number: 'TEST-VAT-0001',
      email: 'kept@example.test',
      iban: 'TEST-IBAN-01',
      bic: 'TESTBIC1',
      address_line1: '1 Mill Street',
      postal_code: '1000',
      city: 'Riverside',
      auxiliary_code: 'AUX-ABS',
      contact_type: 'both',
    });
    expect(merged.filled).toEqual(expect.arrayContaining(['vat_number', 'iban', 'bic', 'address_line1', 'auxiliary_code', 'contact_type']));
    expect(merged.filled).not.toContain('email');
    // The absorbed contact keeps its record, but for the auxiliary code, which is unique.
    expect(await one(db, `select vat_number, email, auxiliary_code from contacts where id = $1`, [absorb])).toEqual({
      vat_number: 'TEST-VAT-0001',
      email: 'absorbed@example.test',
      auxiliary_code: null,
    });
  });

  it('folds the learned motifs of the two: one motif both had keeps both histories', async () => {
    const keep = await contact();
    const absorb = await contact();
    const motif = (who: string, value: string, usage: number, success: number) =>
      db.query(
        `insert into contact_patterns (company_id, contact_id, kind, value, source, usage_count, success_count, confidence)
         values ($1, $2, 'name_variation', $3, 'learned', $4, $5, ($5 + 1)::numeric / ($4 + 2))`,
        [fx.companyId, who, value, usage, success],
      );
    await motif(keep, 'J MARLOW', 3, 2);
    await motif(absorb, 'J MARLOW', 4, 4);
    await motif(absorb, 'MARLOW JANE LTD', 1, 1);

    const merged = await merge(keep, absorb);
    expect(merged.moved).toMatchObject({ contact_patterns: 1, contact_patterns_folded: 1 });
    expect(
      await rows(
        db,
        `select value, usage_count, success_count, confidence from contact_patterns where contact_id = $1 order by value`,
        [keep],
      ),
    ).toEqual([
      { value: 'J MARLOW', usage_count: 7, success_count: 6, confidence: '0.778' },
      { value: 'MARLOW JANE LTD', usage_count: 1, success_count: 1, confidence: '0.667' },
    ]);
    expect(await namingCount('contact_patterns', 'contact_id', absorb)).toBe(0);

    // What a statement line written that way is told now: the kept contact.
    const told = await rows<{ contact_id: string }>(
      db,
      `select contact_id from contact_candidates($1, 'the statement', 'J MARLOW', null::text, 'J MARLOW', null::text,
                                                 10::numeric, null::char(3), null::doc_type[])`,
      [fx.companyId],
    );
    expect(told.map((t) => t.contact_id)).toContain(keep);
    expect(told.map((t) => t.contact_id)).not.toContain(absorb);
  });

  it('a kept contact that was a branch of the absorbed one goes up to its parent', async () => {
    const parent = await contact();
    const absorb = await contact();
    const keep = await contact();
    await db.query(`update contacts set parent_id = $1 where id = $2`, [parent, absorb]);
    await db.query(`update contacts set parent_id = $1 where id = $2`, [absorb, keep]);
    await merge(keep, absorb);
    expect(await one(db, `select parent_id from contacts where id = $1`, [keep])).toEqual({ parent_id: parent });
  });
});

// ---------------------------------------------------------------------------
// Matchings, open items, the aged balance
// ---------------------------------------------------------------------------

describe('the kept contact holds the history of both', () => {
  it('keeps every matching whole, and lets the two spellings be matched with each other', async () => {
    const keep = await contact('Okafor Ada');
    const absorb = await contact('Ada Okafor');

    // A matching of the absorbed contact's own items.
    const invoice = await item(300, 'debit', absorb);
    const paid = await item(300, 'credit', absorb);
    const matching = await one<{ id: string; matching_number: string }>(
      db,
      `select id, matching_number from reconcile($1, $2)`,
      [invoice, paid],
    );
    // An open invoice of the absorbed contact, and a payment booked on the kept one.
    const open = await item(120, 'debit', absorb);
    const payment = await item(120, 'credit', keep);
    expect(await expectError(db, `select reconcile($1, $2)`, [open, payment])).toMatch(/^reconcile_contact_mismatch:/);

    await merge(keep, absorb);

    const after = await one<{ debit_line_id: string; credit_line_id: string; matching_number: string }>(
      db,
      `select debit_line_id, credit_line_id, matching_number from reconciliations where id = $1`,
      [matching.id],
    );
    expect(after).toEqual({ debit_line_id: invoice, credit_line_id: paid, matching_number: matching.matching_number });
    expect(
      await rows(db, `select contact_id, matched_amount from entry_lines where id = any($1) order by debit desc`, [[invoice, paid]]),
    ).toEqual([
      { contact_id: keep, matched_amount: '300.00' },
      { contact_id: keep, matched_amount: '300.00' },
    ]);

    // The open items and the aged balance of the kept contact carry the absorbed history.
    const items = await rows<{ line_id: string }>(db, `select line_id from open_items($1, $2)`, [fx.companyId, keep]);
    expect(items.map((i) => i.line_id)).toEqual(expect.arrayContaining([open, payment]));
    expect(await rows(db, `select line_id from open_items($1, $2)`, [fx.companyId, absorb])).toEqual([]);
    const aged = await rows<{ contact_id: string }>(db, `select contact_id from aged_balance($1, '2026-12-31')`, [fx.companyId]);
    expect(aged.map((a) => a.contact_id)).not.toContain(absorb);

    await one(db, `select id from reconcile($1, $2)`, [open, payment]);
    expect(await rows(db, `select line_id from open_items($1, $2) where line_id = any($3)`, [fx.companyId, keep, [open, payment]])).toEqual([]);
  });

  it('a kept contact with no parent takes the absorbed one\'s, so a matching with the parent stays of one party', async () => {
    const parent = await contact();
    const absorb = await contact();
    const keep = await contact();
    await db.query(`update contacts set parent_id = $1 where id = $2`, [parent, absorb]);
    const branchInvoice = await item(55, 'debit', absorb);
    const parentPayment = await item(55, 'credit', parent);
    await one(db, `select id from reconcile($1, $2)`, [branchInvoice, parentPayment]);

    const merged = await merge(keep, absorb);
    expect(merged.filled).toContain('parent_id');
    expect(await one(db, `select parent_id from contacts where id = $1`, [keep])).toEqual({ parent_id: parent });
  });

  it('refuses matching_across_parties when the kept contact has another parent, and moves nothing', async () => {
    const parent = await contact();
    const elsewhere = await contact();
    const absorb = await contact();
    const keep = await contact();
    await db.query(`update contacts set parent_id = $1 where id = $2`, [parent, absorb]);
    await db.query(`update contacts set parent_id = $1 where id = $2`, [elsewhere, keep]);
    const branchInvoice = await item(65, 'debit', absorb);
    const parentPayment = await item(65, 'credit', parent);
    await one(db, `select id from reconcile($1, $2)`, [branchInvoice, parentPayment]);

    const refused = await refusalAs(db, accountant, `select merge_contacts($1, $2)`, [keep, absorb]);
    expect(refused).toMatch(/^matching_across_parties:/);
    expect(await one(db, `select contact_id from entry_lines where id = $1`, [branchInvoice])).toEqual({ contact_id: absorb });
    expect(await one(db, `select active, merged_into from contacts where id = $1`, [absorb])).toEqual({ active: true, merged_into: null });
  });
});

// ---------------------------------------------------------------------------
// Refusals, and who may merge
// ---------------------------------------------------------------------------

describe('what merge_contacts() refuses', () => {
  it('refuses same_contact, unknown_contact, already_merged and different_identifiers by name', async () => {
    const a = await contact();
    const b = await contact();
    const c = await contact();
    expect(await refusalAs(db, accountant, `select merge_contacts($1, $1)`, [a])).toMatch(/^same_contact:/);
    expect(await refusalAs(db, accountant, `select merge_contacts($1, $2)`, [a, NOWHERE])).toMatch(/^unknown_contact:/);
    expect(await refusalAs(db, accountant, `select merge_contacts($1, $2)`, [NOWHERE, a])).toMatch(/^unknown_contact:/);

    await db.query(`update contacts set vat_number = 'TEST-VAT-1000' where id = $1`, [a]);
    await db.query(`update contacts set vat_number = 'test vat 1000' where id = $1`, [b]);
    await db.query(`update contacts set vat_number = 'TEST-VAT-2000' where id = $1`, [c]);
    expect(await refusalAs(db, accountant, `select merge_contacts($1, $2)`, [a, c])).toMatch(/^different_identifiers:/);
    // The same number, written another way, is one party.
    await merge(a, b);

    expect(await refusalAs(db, accountant, `select merge_contacts($1, $2)`, [a, b])).toMatch(/^already_merged:/);
    expect(await refusalAs(db, accountant, `select merge_contacts($1, $2)`, [b, c])).toMatch(/^already_merged:.*merge into that one/);
  });

  it('asks contacts.write and reconcile.write: a viewer is refused not_allowed', async () => {
    const a = await contact();
    const b = await contact();
    expect(await refusalAs(db, viewer, `select merge_contacts($1, $2)`, [a, b])).toMatch(/^not_allowed:.*contacts\.write/);
  });

  it('keeps tenants apart: a contact of another company is unknown, read or not', async () => {
    const mine = await contact();
    const theirs = await contact(undefined, other.companyId);
    // A member of the other company does not know this company's contacts.
    const mineName = (await one<{ name: string }>(db, `select name from contacts where id = $1`, [mine])).name;
    const fromOutside = await refusalAs(db, stranger, `select merge_contacts($1, $2)`, [mine, theirs]);
    expect(fromOutside).toMatch(/^unknown_contact:/);
    expect(fromOutside.replace(UUID, '<id>')).not.toContain(mineName);
    // And from inside, a contact of another company is not one to merge with.
    expect(await refusalAs(db, accountant, `select merge_contacts($1, $2)`, [mine, theirs])).toMatch(/^unknown_contact:/);
    expect(await refusalAs(db, stranger, `select merge_contacts($1, $2)`, [theirs, mine])).toMatch(/^unknown_contact:/);
    expect(await one(db, `select merged_into from contacts where id = $1`, [theirs])).toEqual({ merged_into: null });
  });

  it('nobody moves a posted line or an issued document from one contact to another by hand', async () => {
    const a = await contact();
    const b = await contact();
    const lineId = await item(10, 'debit', a);
    const invoice = await postedInvoice(a);
    expect(await refusalAs(db, accountant, `update entry_lines set contact_id = $1 where id = $2`, [b, lineId])).toMatch(/^entry_posted:/);
    expect(await refusalAs(db, accountant, `update documents set contact_id = $1 where id = $2`, [b, invoice])).toMatch(/^document_posted:/);
    // The record of a merge is written by merge_contacts() and nobody else.
    expect(
      await refusalAs(db, accountant, `insert into contact_merges (company_id, kept_id, absorbed_id) values ($1, $2, $3)`, [fx.companyId, b, a]),
    ).toMatch(/permission denied/);
    expect(
      await refusalAs(db, accountant, `update contacts set active = false, merged_into = $1 where id = $2`, [b, a]),
    ).toMatch(/^contact_merged_by_merge_contacts:/);
  });
});

// ---------------------------------------------------------------------------
// After the merge
// ---------------------------------------------------------------------------

describe('an absorbed contact is not used again', () => {
  it('is named by no new row, is not made active again, and is not deleted', async () => {
    const keep = await contact('Kept Holdings');
    const absorb = await contact('Kept Holdings Ltd');
    await merge(keep, absorb);

    const named = /^contact_merged: Kept Holdings Ltd was merged into Kept Holdings/;
    expect(
      await refusalAs(
        db,
        accountant,
        `insert into documents (company_id, doc_type, contact_id, document_date) values ($1, 'sale_invoice', $2, '2026-05-01')`,
        [fx.companyId, absorb],
      ),
    ).toMatch(named);
    expect(
      await refusalAs(
        db,
        accountant,
        `insert into bank_transactions (company_id, bank_account_id, sequence, transaction_date, amount, contact_id)
         values ($1, $2, 9999, '2026-03-05', 5, $3)`,
        [fx.companyId, bankAccount, absorb],
      ),
    ).toMatch(named);
    const stray = await item(5, 'debit', null);
    expect(await refusalAs(db, accountant, `select set_line_contact($1, $2)`, [stray, absorb])).toMatch(named);
    expect(await refusalAs(db, accountant, `update contacts set parent_id = $1 where id = $2`, [absorb, await contact()])).toMatch(named);
    expect(
      await refusalAs(
        db,
        accountant,
        `insert into contact_patterns (company_id, contact_id, kind, value, source) values ($1, $2, 'name_variation', 'KH', 'declared')`,
        [fx.companyId, absorb],
      ),
    ).toMatch(named);

    expect(await refusalAs(db, accountant, `update contacts set active = true where id = $1`, [absorb])).toMatch(/^contact_merged:/);
    expect(await refusalAs(db, accountant, `delete from contacts where id = $1`, [absorb])).toMatch(/^contact_merged:/);
    // Its own record may still be read, and its notes corrected.
    expect(await refusalAs(db, accountant, `update contacts set notes = 'second import' where id = $1`, [absorb])).toBe('accepted');
  });

  it('a contact merged before follows the one it was merged into when that one is merged in its turn', async () => {
    const first = await contact();
    const second = await contact();
    const third = await contact();
    await merge(second, first);
    await merge(third, second);
    expect(await rows(db, `select id, merged_into from contacts where id = any($1) order by merged_into nulls last, id`, [[first, second]])).toEqual(
      expect.arrayContaining([
        { id: first, merged_into: third },
        { id: second, merged_into: third },
      ]),
    );
  });
});
