/**
 * What produced an entry stops moving when the entry exists.
 *
 * Until `20260918161204` a posted document was immutable by convention. A
 * member holding `documents.write` could rewrite any column of any line of an
 * issued invoice, add a line, delete one, rewrite its totals, its number, its
 * dates and its customer, unhook it from its entry, send it back to draft and
 * post it again, or delete it — and the ledger said nothing, because the
 * period locks guard the ledger and nothing guarded the document.
 *
 * These tests are written from three seats, under row level security, in an
 * open period: an accountant of the company, its owner, and a machine holding
 * an API key with the capabilities of the first. The owner is there because a
 * rule that holds for the least of them and not for the greatest is a
 * permission, not an invariant. The expectations are
 * not a list of columns somebody remembered. Every column of both tables is
 * read from the catalogue and tried; the only list written here is the closed
 * one of what may still move, which is the decision under test — a column added
 * tomorrow is tried by this file the day it lands, and has to be refused.
 *
 * The rest holds what must not break: a draft is still free, `post_document()`
 * still posts, the matching still writes what a document was settled by, and
 * the way to undo an issued invoice — a credit note that names it — exists.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { Pack } from '../packages/cli/src/index.js';
import { asUser, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, newInstanceAdmin, newUser, taxId } from './helpers/factory.js';
import { thirdPartyLine } from './helpers/golden-scenario.js';
import { packWhere, roleOf } from './helpers/packs.js';

/** The decision under test: what may still move on a document that is no longer a draft. */
const STILL_MOVES = ['amount_paid', 'amount_residual', 'payment_state', 'sent_at', 'peppol_status', 'peppol_message_id', 'updated_at'];

/** What a client may write into the three columns that record what happened after issue. */
const AFTER_ISSUE: Record<string, string> = {
  sent_at: `now()`,
  peppol_status: `'delivered'`,
  peppol_message_id: `'message-1'`,
};

type PackTax = Pack['taxes'][number];
const charged = (pack: Pack): PackTax[] =>
  pack.taxes
    .filter(
      (tax) =>
        tax.scope === 'sale' && tax.treatment === 'domestic' && tax.amount_type === 'percent' &&
        tax.rate > 0 && tax.valid_to === null && !tax.price_include,
    )
    .sort((a, b) => b.rate - a.rate);

let db: PGlite;
let pack: Pack;
let companyId: string;
let accountant: string;
let ownerId: string;
let customer: string;
let other: string;
let salesAccount: string;
let standard: PackTax;
let reduced: PackTax;
/** Rows to point a column at, other than the ones the invoice under test points at. */
const ids = { reducedTax: '', journal: '', account: '', product: '', draft: '', currency: '', territory: '' };

beforeAll(async () => {
  pack = packWhere('charges two rates on an ordinary sale', (p) => charged(p).length >= 2);
  [standard, reduced] = charged(pack) as [PackTax, PackTax];
  salesAccount = roleOf(pack, 'sales');

  db = await freshDatabase();
  ({ companyId, ownerId } = await newCompany(db, { country: pack.manifest.country, name: 'Issued' }));
  await db.query(`insert into auth.users (id, email) values ($1, 'owner@posted.test') on conflict do nothing`, [ownerId]);
  accountant = await newUser(db, 'accountant@posted.test');
  await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'accountant')`, [companyId, accountant]);
  const key = await asUser(db, ownerId, () =>
    one<{ secret: string }>(db, `select * from create_api_key($1, 'Integration', $2::jsonb)`, [
      companyId,
      JSON.stringify(['documents.read', 'documents.write', 'documents.post', 'entries.read', 'entries.write', 'entries.post', 'contacts.read']),
    ]),
  );
  ids.reducedTax = await taxId(db, companyId, reduced.code);
  ids.journal = (await one<{ id: string }>(db, `select id from journals where company_id = $1 and id <> (select sales_journal_id from companies where id = $1) limit 1`, [companyId])).id;
  ids.account = (await one<{ id: string }>(
    db,
    `select a.id from accounts a
      where a.company_id = $1 and a.id <> account_id_by_code($1, $2)
        and a.account_type = (select account_type from accounts where id = account_id_by_code($1, $2)) limit 1`,
    [companyId, salesAccount],
  )).id;
  ids.product = (await one<{ id: string }>(db, `insert into products (company_id, code, name) values ($1, 'P-1', 'A product') returning id`, [companyId])).id;
  ids.currency = (await one<{ code: string }>(db, `select code from currencies where code <> (select currency_code from companies where id = $1) order by code limit 1`, [companyId])).code;
  ids.territory = (await one<{ code: string }>(db, `select code from territories order by code limit 1`)).code;
  SEATS.push(
    { name: 'an accountant', user: accountant },
    { name: 'the owner', user: ownerId },
    { name: 'a machine holding an API key', secret: key.secret },
  );
  customer = await newContact(db, companyId, { country: pack.manifest.country });
  other = await newContact(db, companyId, { name: 'Somebody else', country: pack.manifest.country });
  ids.draft = await newDocument(db, companyId, { docType: 'sale_invoice', contactId: customer, lines: twoLines() });
}, 180_000);

afterAll(async () => {
  await db.close();
});

const twoLines = () => [
  { name: 'First', unitPrice: 100, taxCode: standard.code, accountCode: salesAccount },
  { name: 'Second', unitPrice: 50, taxCode: standard.code, accountCode: salesAccount },
];

async function invoice(post = true, docType: 'sale_invoice' | 'sale_credit_note' = 'sale_invoice'): Promise<string> {
  const id = await newDocument(db, companyId, { docType, contactId: customer, lines: twoLines() });
  if (post) await asUser(db, accountant, () => db.query(`select post_document($1)`, [id]));
  return id;
}

/** Everything the books hold of a document: its row, its lines, the lines of its entry. */
const whole = async (documentId: string) => ({
  document: await one(db, `select to_jsonb(d) - 'updated_at' as row from documents d where id = $1`, [documentId]),
  lines: await rows(db, `select to_jsonb(l) - 'updated_at' as row from document_lines l where document_id = $1 order by sequence`, [documentId]),
  ledger: await rows(
    db,
    `select l.account_id, l.debit::text, l.credit::text
       from entry_lines l join documents d on d.entry_id = l.entry_id
      where d.id = $1 order by l.sequence`,
    [documentId],
  ),
});

/** Who is asking: a person with a session, or a machine with a key. */
interface Seat {
  name: string;
  user?: string;
  secret?: string;
}
const SEATS: Seat[] = [];
const SEAT_NAMES = ['an accountant', 'the owner', 'a machine holding an API key'];
const seat = (name: string): Seat => SEATS.find((each) => each.name === name) as Seat;

interface Refusal {
  code: string | undefined;
  message: string;
}

/**
 * Run a statement from a seat, inside a transaction that is then undone; what
 * it was refused with, or null when it went through. Everything that makes the
 * connection somebody is local to that transaction.
 */
async function refusalOf(sql: string, params: unknown[], who: Seat = seat('an accountant')): Promise<Refusal | null> {
  await db.exec('begin');
  try {
    await db.query(`select set_config('ekwo.installing', '', true), set_config('request.jwt.claims', $1, true)`, [
      who.user ? JSON.stringify({ sub: who.user, role: 'authenticated' }) : '',
    ]);
    await db.exec('set local role authenticated');
    if (who.secret) await db.query(`select * from use_api_key($1)`, [who.secret]);
    await db.exec('savepoint attempt');
    try {
      const result = await db.query(sql, params);
      // Row level security does not raise on an update it filters out: a
      // statement that reached no row proved nothing, and says so.
      if (/^\s*(update|delete)/i.test(sql) && result.affectedRows === 0) {
        return { code: 'no-row', message: `no row reached: ${who.name} cannot see or write it` };
      }
      return null;
    } catch (error) {
      const refused = error as { code?: string; message: string };
      return { code: refused.code, message: refused.message };
    }
  } finally {
    await db.exec('rollback');
  }
}

/** What the books hold of a document after a statement, which is then undone. */
async function after(sql: string, params: unknown[], documentId: string) {
  await db.exec('begin');
  try {
    await db.query(sql, params);
    return await whole(documentId);
  } finally {
    await db.exec('rollback');
  }
}

/** A value of the column's type that differs from the one the row holds. */
function another(column: { name: string; type: string; udt: string }, row: Record<string, unknown>): string | null {
  const held = row[column.name];
  // Found beforehand, as the installer: a value a seat cannot read is a value
  // it cannot write, and the statement would then prove nothing.
  const references: Record<string, string> = {
    contact_id: `'${other}'`,
    tax_id: `'${ids.reducedTax}'`,
    journal_id: `'${ids.journal}'`,
    account_id: `'${ids.account}'`,
    product_id: `'${ids.product}'`,
    document_id: `'${ids.draft}'`,
    currency_code: `'${ids.currency}'`,
    currency_code_tax: `'${ids.currency}'`,
    supply_territory_code: `'${ids.territory}'`,
    language: held === 'en' ? `'fr'` : `'en'`,
    doc_type: `'sale_credit_note'`,
    state: `'draft'`,
    payment_state: `'paid'`,
    line_type: `'note'`,
    reversed_document_id: `id`,
    delivery_country: `'ZZ'`,
    unit_code: `'HUR'`,
  };
  if (column.name in references) return references[column.name] as string;
  if (column.name.endsWith('_id')) return held === null ? null : 'null';
  switch (column.type) {
    case 'numeric':
    case 'smallint':
    case 'integer':
      return `coalesce(${column.name}, 0) + 7`;
    case 'date':
      return `coalesce(${column.name}, document_date) - 40`;
    case 'timestamp with time zone':
      return `now()`;
    case 'boolean':
      return `not ${column.name}`;
    case 'text':
    case 'character':
      return `'changed'`;
    default:
      return null;
  }
}

const columnsOf = (table: string) =>
  rows<{ name: string; type: string; udt: string; generated: string }>(
    db,
    `select column_name as name, data_type as type, udt_name as udt, is_generated as generated
       from information_schema.columns
      where table_schema = 'public' and table_name = $1
        and column_name not in ('id', 'company_id', 'created_at')
      order by ordinal_position`,
    [table],
  );

describe.each(SEAT_NAMES)('a posted document, from the seat of %s', (who) => {
  let documentId: string;
  let before: Awaited<ReturnType<typeof whole>>;

  beforeAll(async () => {
    documentId = await invoice();
    before = await whole(documentId);
  });

  it('keeps every column of its row but the closed list of what happens after issue', async () => {
    const row = (await one<{ row: Record<string, unknown> }>(db, `select to_jsonb(d) as row from documents d where id = $1`, [documentId])).row;
    const tried: string[] = [];
    for (const column of await columnsOf('documents')) {
      if (column.generated === 'ALWAYS' || STILL_MOVES.includes(column.name)) continue;
      // `document_id` of a line is tried below; a document has none.
      const value = another(column, row);
      expect(value, `no value to try on documents.${column.name}: teach another() its type`).not.toBeNull();
      const refused = await refusalOf(`update documents set ${column.name} = ${value} where id = $1`, [documentId], seat(who));
      expect(refused, `documents.${column.name} was rewritten on a posted invoice`).not.toBeNull();
      expect(refused?.code, `documents.${column.name}: ${refused?.message}`).toBe('55006');
      expect(refused?.message, column.name).toMatch(/^document_(posted|language_frozen)\b/);
      tried.push(column.name);
    }
    // The columns an invoice is made of were among them: the catalogue was read.
    expect(tried).toEqual(
      expect.arrayContaining(['amount_total', 'number', 'document_date', 'contact_id', 'currency_code', 'entry_id', 'state', 'due_date', 'note']),
    );
    expect(await whole(documentId)).toEqual(before);
  });

  it('keeps every column of every line', async () => {
    const row = (await one<{ row: Record<string, unknown> }>(
      db,
      `select to_jsonb(l) as row from document_lines l where document_id = $1 and sequence = 10`,
      [documentId],
    )).row;
    const tried: string[] = [];
    const derived: string[] = [];
    for (const column of await columnsOf('document_lines')) {
      if (column.generated === 'ALWAYS' || column.name === 'updated_at') continue;
      const value = another(column, row);
      expect(value, `no value to try on document_lines.${column.name}: teach another() its type`).not.toBeNull();
      const statement = `update document_lines set ${column.name} = ${value} where document_id = $1 and sequence = 10`;
      const refused = await refusalOf(statement, [documentId], seat(who));
      if (refused === null) {
        // A derived column: the line's own trigger wrote the figure back
        // before anybody judged it, so nothing moved and nothing was refused.
        expect(await after(statement, [documentId], documentId), `document_lines.${column.name} was rewritten on a posted invoice`).toEqual(before);
        derived.push(column.name);
        continue;
      }
      expect(refused?.code, `document_lines.${column.name}: ${refused?.message}`).toBe('55006');
      expect(refused?.message, column.name).toMatch(/^document_posted\b/);
      tried.push(column.name);
    }
    expect(tried).toEqual(
      expect.arrayContaining(['quantity', 'unit_price', 'discount_percent', 'tax_id', 'account_id', 'name', 'vat_rate', 'document_id']),
    );
    // Nothing is let through for being derived: the guard judges the line as it was keyed.
    expect(derived).toEqual([]);
    expect(await whole(documentId)).toEqual(before);
  });

  it('takes no new line and loses none', async () => {
    const added = await refusalOf(
      `insert into document_lines (document_id, company_id, sequence, name, quantity, unit_price, tax_id, account_id)
       select document_id, company_id, 30, 'Slipped in', 1, 999, tax_id, account_id
         from document_lines where document_id = $1 and sequence = 10`,
      [documentId],
      seat(who),
    );
    const removed = await refusalOf(`delete from document_lines where document_id = $1 and sequence = 10`, [documentId], seat(who));
    for (const refused of [added, removed]) {
      expect(refused?.code).toBe('55006');
      expect(refused?.message).toMatch(/^document_posted\b/);
    }
    expect(await whole(documentId)).toEqual(before);
  });

  it('is not deleted, not sent back to draft, and not cancelled by an update', async () => {
    for (const statement of [
      `delete from documents where id = $1`,
      `update documents set state = 'draft' where id = $1`,
      `update documents set state = 'cancelled' where id = $1`,
    ]) {
      const refused = await refusalOf(statement, [documentId], seat(who));
      expect(refused?.code, statement).toBe('55006');
      expect(refused?.message, statement).toMatch(/^document_posted\b.*credit note/);
    }
    expect(await whole(documentId)).toEqual(before);
  });

  it('holds the entry it produced, and the entry holds itself', async () => {
    // The entry has a guard of its own (`tests/posted_entry.test.ts`), which
    // answers first. Without it the document still would: deleting the entry
    // nulls `documents.entry_id`, and that is a column of an issued document.
    const statement = `delete from entries where id = (select entry_id from documents where id = $1)`;
    const refused = await refusalOf(statement, [documentId], seat(who));
    expect(refused?.code).toBe('55006');
    expect(refused?.message).toMatch(/^entry_posted\b/);

    await db.exec(`alter table entries disable trigger entries_guard_posted;
                   alter table entry_lines disable trigger entry_lines_guard_posted;`);
    try {
      const held = await refusalOf(statement, [documentId], seat(who));
      expect(held?.code).toBe('55006');
      expect(held?.message).toMatch(/^document_posted\b.*entry_id/);
    } finally {
      await db.exec(`alter table entries enable trigger entries_guard_posted;
                     alter table entry_lines enable trigger entry_lines_guard_posted;`);
    }
  });

  it('refuses the installer what it refuses a member: nobody is exempt', async () => {
    await expect(db.query(`update document_lines set quantity = 7 where document_id = $1`, [documentId])).rejects.toThrow(/document_posted/);
    await expect(db.query(`update documents set amount_total = 1 where id = $1`, [documentId])).rejects.toThrow(/document_posted/);
    expect(await whole(documentId)).toEqual(before);
  });

  it('lets an update that changes nothing through, because nothing changed', async () => {
    // A machine key cannot write a document line at all today, posted or not:
    // the line's own trigger rounds by the company, and a key cannot read
    // `companies`. That is a defect of its own, older than this file, and the
    // reason the line is not asked of that seat here.
    if (seat(who).secret === undefined) {
      expect(await refusalOf(`update document_lines set quantity = quantity where document_id = $1`, [documentId], seat(who))).toBeNull();
    }
    expect(await refusalOf(`update documents set number = number where id = $1`, [documentId], seat(who))).toBeNull();
  });
});

describe('what still moves after a document is issued', () => {
  it('is what happened to it afterwards: that it was sent, and what the network said', async () => {
    const documentId = await invoice();
    for (const [column, value] of Object.entries(AFTER_ISSUE)) {
      await asUser(db, accountant, () => db.query(`update documents set ${column} = ${value} where id = $1`, [documentId]));
    }
    const row = await one<Record<string, unknown>>(db, `select sent_at, peppol_status, peppol_message_id from documents where id = $1`, [documentId]);
    expect(row.sent_at).not.toBeNull();
    expect(row).toMatchObject({ peppol_status: 'delivered', peppol_message_id: 'message-1' });
    expect(Object.keys(AFTER_ISSUE).concat(['amount_paid', 'amount_residual', 'payment_state', 'updated_at']).sort()).toEqual([...STILL_MOVES].sort());
  });

  it('is what it was settled by — the figure the matching gives, and no other', async () => {
    const documentId = await invoice();
    for (const who of SEATS) {
      for (const keyed of [`amount_paid = 1`, `amount_paid = amount_total`, `payment_state = 'paid'`]) {
        const refused = await refusalOf(`update documents set ${keyed} where id = $1`, [documentId], who);
        expect(refused?.code, `${who.name}: ${keyed}`).toBe('55006');
        expect(refused?.message, `${who.name}: ${keyed}`).toMatch(/^document_(amount_paid|payment_state)_is_derived\b/);
      }
    }
  });

  it('attachments and share links, which are rows of other tables', async () => {
    const documentId = await invoice();
    const before = await whole(documentId);
    await asUser(db, accountant, () =>
      db.query(
        `insert into attachments (company_id, entity_type, entity_id, file_name, storage_path)
         values ($1, 'document', $2, 'scan.pdf', 'scans/scan.pdf')`,
        [companyId, documentId],
      ),
    );
    expect(await whole(documentId)).toEqual(before);
  });
});

describe('a document that is born posted', () => {
  const born = `insert into documents (company_id, doc_type, state, number, contact_id, document_date, entry_id)
     select company_id, doc_type, 'posted', $2, contact_id, document_date, $3 from documents where id = $1`;

  it('is refused to everybody: post_document() never saw it', async () => {
    const model = await invoice();
    // An entry to point at, so that what is refused is the birth and nothing else.
    const spare = await one<{ id: string }>(
      db,
      `insert into entries (company_id, journal_id, entry_date, description)
       select company_id, journal_id, entry_date, 'Spare' from entries where document_id = $1 returning id`,
      [model],
    );
    // An administrator of the instance who is also the owner of the company:
    // the policy would let the row in. A machine key is never one.
    const admin = await newInstanceAdmin(db);
    await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'owner')`, [companyId, admin]);
    for (const who of [...SEATS, { name: 'an administrator of the instance', user: admin }]) {
      const refused = await refusalOf(born, [model, `BORN-${who.name}`, spare.id], who);
      expect(refused?.code, who.name).toBe('55006');
      expect(refused?.message, who.name).toMatch(/^document_born_posted\b/);
    }
    // And the connection that installed the schema.
    await expect(db.query(born, [model, 'BORN-installer', spare.id])).rejects.toThrow(/document_born_posted/);
    await expect(
      db.query(
        `insert into document_lines (document_id, company_id, sequence, name, quantity, unit_price, tax_id, account_id)
         select document_id, company_id, 30, 'Slipped in', 1, 10, tax_id, account_id from document_lines where document_id = $1 and sequence = 10`,
        [model],
      ),
    ).rejects.toThrow(/document_posted/);
  });
});

describe('the way an issued invoice is undone', () => {
  it('is a credit note that names it, posted by the same function, matched against it', async () => {
    const invoiceId = await invoice();
    const creditId = await newDocument(db, companyId, { docType: 'sale_credit_note', contactId: customer, lines: twoLines() });
    await asUser(db, accountant, async () => {
      // A credit note says what it credits while it is still a draft.
      await db.query(`update documents set reversed_document_id = $2 where id = $1`, [creditId, invoiceId]);
      await db.query(`select post_document($1)`, [creditId]);
      await db.query(`select reconcile($1, $2)`, [
        await thirdPartyLine(db, 'document_id', invoiceId),
        await thirdPartyLine(db, 'document_id', creditId),
      ]);
    });

    // The two entries cancel out, account by account.
    const net = await rows<{ net: string }>(
      db,
      `select sum(l.debit - l.credit)::text as net
         from entry_lines l join documents d on d.entry_id = l.entry_id
        where d.id in ($1, $2) group by l.account_id`,
      [invoiceId, creditId],
    );
    expect(net.length).toBeGreaterThan(0);
    expect(net.every((row) => Number(row.net) === 0)).toBe(true);

    // And the matching wrote what each was settled by: through the guard, as
    // the accountant, because the figure is the one the matching gives.
    const settled = await rows<{ payment_state: string; residual: string; state: string }>(
      db,
      `select payment_state, amount_residual::text as residual, state from documents where id in ($1, $2)`,
      [invoiceId, creditId],
    );
    expect(settled).toEqual([
      { payment_state: 'paid', residual: '0.00', state: 'posted' },
      { payment_state: 'paid', residual: '0.00', state: 'posted' },
    ]);

    // Unmatching is the same path backwards.
    const invoiceLine = await thirdPartyLine(db, 'document_id', invoiceId);
    await asUser(db, accountant, () =>
      db.query(`select unreconcile(r.id) from reconciliations r where r.debit_line_id = $1 or r.credit_line_id = $1`, [invoiceLine]),
    );
    expect(await one(db, `select payment_state, amount_paid::text from documents where id = $1`, [invoiceId])).toEqual({
      payment_state: 'not_paid',
      amount_paid: '0.00',
    });

    // Once posted, the credit note no longer chooses what it credits.
    const refused = await refusalOf(`update documents set reversed_document_id = null where id = $1`, [creditId]);
    expect(refused?.message).toMatch(/^document_posted\b/);
  });
});

describe('what has to keep working', () => {
  it('a draft is free: its lines, its header, its deletion', async () => {
    const draft = await invoice(false);
    await asUser(db, accountant, async () => {
      await db.query(`update document_lines set quantity = 3, tax_id = $2 where document_id = $1 and sequence = 10`, [
        draft,
        await taxId(db, companyId, reduced.code),
      ]);
      await db.query(`delete from document_lines where document_id = $1 and sequence = 20`, [draft]);
      await db.query(`update documents set contact_id = $2, note = 'changed', due_date = document_date + 10 where id = $1`, [draft, other]);
    });
    const totals = await one<{ amount_untaxed: string }>(db, `select amount_untaxed::text from documents where id = $1`, [draft]);
    expect(totals.amount_untaxed).toBe('300.00');
    await asUser(db, accountant, () => db.query(`delete from documents where id = $1`, [draft]));
    expect(await rows(db, `select 1 from document_lines where document_id = $1`, [draft])).toEqual([]);
  });

  it('a draft that is abandoned may be cancelled, and a cancelled one stays so', async () => {
    const draft = await invoice(false);
    await asUser(db, accountant, () => db.query(`update documents set state = 'cancelled' where id = $1`, [draft]));
    const refused = await refusalOf(`update documents set state = 'draft' where id = $1`, [draft]);
    expect(refused?.message).toMatch(/^document_posted\b/);
  });

  it('a document does not become posted without the entry post_document() builds, and posts', async () => {
    const draft = await invoice(false);
    const refused = await refusalOf(`update documents set state = 'posted', number = 'BY-HAND-1' where id = $1`, [draft]);
    expect(refused?.code).toBe('55006');
    expect(refused?.message).toMatch(/^document_posted_without_entry\b/);

    // Nor with an entry that is still a draft: the ledger does not hold it yet.
    const unposted = await one<{ id: string }>(
      db,
      `insert into entries (company_id, journal_id, entry_date, description)
       select $1, sales_journal_id, current_date, 'Not posted' from companies where id = $1 returning id`,
      [companyId],
    );
    const half = await refusalOf(`update documents set state = 'posted', number = 'BY-HAND-2', entry_id = $2 where id = $1`, [draft, unposted.id]);
    expect(half?.message).toMatch(/^document_posted_without_entry\b/);
  });

  it('a tax that changes still reaches the drafts that carry it, and only them', async () => {
    const posted = await invoice();
    const draft = await invoice(false);
    const before = await whole(posted);
    const tax = await taxId(db, companyId, standard.code);
    await db.query(`update taxes set amount = $2 where id = $1`, [tax, standard.rate + 1]);
    try {
      expect(await whole(posted)).toEqual(before);
      const line = await one<{ vat_rate: string }>(db, `select vat_rate::text from document_lines where document_id = $1 and sequence = 10`, [draft]);
      expect(Number(line.vat_rate)).toBe(standard.rate + 1);
    } finally {
      await db.query(`update taxes set amount = $2 where id = $1`, [tax, standard.rate]);
    }
  });

  it('a company that is deleted takes its issued documents with it', async () => {
    const gone = await newCompany(db, { country: pack.manifest.country, name: 'Wound up' });
    const contact = await newContact(db, gone.companyId, { country: pack.manifest.country });
    const id = await newDocument(db, gone.companyId, { docType: 'sale_invoice', contactId: contact, lines: twoLines() });
    // A company with books is deleted by whoever runs the installation, and
    // the ledger has its own say in it; what is asked here is only that the
    // document guard is not what stands in the way.
    await db.query(`select post_document($1)`, [id]);
    const message = await db.query(`delete from companies where id = $1`, [gone.companyId]).then(
      () => null,
      (error: Error) => error.message,
    );
    expect(message ?? '').not.toMatch(/document_posted/);
  });
});
