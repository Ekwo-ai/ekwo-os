import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, newInstanceAdmin, newUser } from './helpers/factory.js';
import { packWhere } from './helpers/packs.js';

/**
 * A firm keeps the books of several companies in one installation, and the
 * person who runs one of them is a guest in it: the `client` preset.
 *
 * What is proved here, as that person and under row level security:
 *
 *   1. they read their own company — documents, ledger, declarations and the
 *      proof that each one went;
 *   2. they hand a piece over, it lands where the firm sees it, and that is the
 *      only row they can write;
 *   3. every other write is refused, by the table and by the function, and the
 *      database is byte for byte what it was before they tried;
 *   4. the other companies of the firm do not exist for them;
 *   5. an invitation can carry the preset.
 *
 * The third is written against the catalogue and not against a list somebody
 * remembered: every table `authenticated` may write and every volatile function
 * it may call is swept, so a table or a function added next month is tried by
 * this file the day it lands — and a function nobody classified fails it.
 */

const pack = packWhere(
  'files a periodic return this test can prepare',
  (p) => p.report !== null && p.report.boxes.length > 0,
);

function goldenLine(): { tax: string; account: string } {
  for (const document of pack.golden?.documents ?? []) {
    if (document.type !== 'sale_invoice') continue;
    for (const line of document.lines) {
      if (line.tax && line.account) return { tax: line.tax, account: line.account };
    }
  }
  throw new Error(`${pack.slug} has no sale invoice with a tax in its golden`);
}
const SALE = goldenLine();

const PERIODS: Record<string, [string, string]> = {
  month: ['2026-01-01', '2026-01-31'],
  quarter: ['2026-01-01', '2026-03-31'],
  year: ['2026-01-01', '2026-12-31'],
};
const [FROM, TO] = PERIODS[pack.report?.period_default ?? 'month'] ?? PERIODS['month']!;

/** Everything one company of the firm holds, so that each refusal has a real target. */
interface Books {
  companyId: string;
  contactId: string;
  postedDocumentId: string;
  draftDocumentId: string;
  draftEntryId: string;
  draftPaymentId: string;
  bankJournalId: string;
  bankAccountId: string;
  bankTransactionId: string;
  receivableLineId: string;
  fiscalYearId: string;
  filedFilingId: string;
  rejectedFilingId: string;
  draftFilingId: string;
  reconciliationId: string;
  openPaymentLineId: string;
  accountCodes: string[];
  proofId: string;
  invitationId: string;
  apiKeyId: string;
  shareId: string;
}

let db: PGlite;
let accountantId: string;
let clientId: string;
let otherClientId: string;
let viewerId: string;
let mine: Books;
let theirs: Books;

const SCHEMAS = ['public', 'assets', 'budgets'];

async function asClient<T>(fn: () => Promise<T>): Promise<T> {
  return asUser(db, clientId, fn);
}

async function keepBooks(name: string): Promise<Books> {
  // country-literal: both companies are installed in whichever pack files a
  // periodic return, which is the pack under test.
  const { companyId } = await newCompany(db, { country: pack.manifest.country, name });
  await db.query(
    `insert into company_members (company_id, user_id, role) values ($1, $2, 'accountant')`,
    [companyId, accountantId],
  );
  const contactId = await newContact(db, companyId, {
    name: `Customer of ${name}`,
    country: pack.manifest.country,
  });
  const line = [{ unitPrice: 5_000, taxCode: SALE.tax, accountCode: SALE.account }];
  const postedDocumentId = await newDocument(db, companyId, {
    docType: 'sale_invoice',
    number: 'CLI-1',
    contactId,
    date: FROM,
    lines: line,
  });
  await db.query(`select post_document($1)`, [postedDocumentId]);
  const draftDocumentId = await newDocument(db, companyId, {
    docType: 'sale_invoice',
    number: 'CLI-2',
    contactId,
    date: FROM,
    lines: line,
  });

  const general = await one<{ id: string }>(
    db,
    `select id from journals where company_id = $1 and journal_type = 'general' order by code limit 1`,
    [companyId],
  );
  const bank = await one<{ id: string }>(
    db,
    `select id from journals where company_id = $1 and journal_type = 'bank' order by code limit 1`,
    [companyId],
  );
  const draftEntry = await one<{ id: string }>(
    db,
    `insert into entries (company_id, journal_id, entry_date, description, state)
     values ($1, $2, $3::date, 'A draft the firm has not posted', 'draft') returning id`,
    [companyId, general.id, FROM],
  );
  const draftPayment = await one<{ id: string }>(
    db,
    `insert into payments (company_id, direction, payment_date, amount, currency_code,
                           contact_id, journal_id)
     select $1, 'inbound', $2::date, 100, c.currency_code, $3, $4
       from companies c where c.id = $1
     returning id`,
    [companyId, FROM, contactId, bank.id],
  );
  const bankAccount = await one<{ id: string }>(
    db,
    `insert into bank_accounts (company_id, name, currency_code, journal_id)
     select $1, 'Current account', currency_code, $2 from companies where id = $1
     returning id`,
    [companyId, bank.id],
  );
  const bankTransaction = await one<{ id: string }>(
    db,
    `insert into bank_transactions
       (company_id, bank_account_id, sequence, transaction_date, amount, currency_code, state)
     select $1, $2, 1, $3::date, 100, currency_code, 'pending' from companies where id = $1
     returning id`,
    [companyId, bankAccount.id, FROM],
  );
  const receivable = await one<{ id: string }>(
    db,
    `select l.id
       from entry_lines l
       join entries e on e.id = l.entry_id
       join documents d on d.entry_id = e.id
      where d.id = $1 and l.contact_id = $2 and l.debit > 0
      order by l.debit desc limit 1`,
    [postedDocumentId, contactId],
  );
  const fiscalYear = await one<{ id: string }>(
    db,
    `select id from fiscal_years where company_id = $1 limit 1`,
    [companyId],
  );

  const filed = await one<{ id: string }>(
    db,
    `select id from prepare_filing($1, $2::date, $3::date)`,
    [companyId, FROM, TO],
  );
  await db.query(`select file_filing($1, $2)`, [filed.id, `REF-${name}`]);
  const proof = await one<{ id: string }>(
    db,
    `insert into attachments (company_id, entity_type, entity_id, file_name, storage_path)
     values ($1, 'tax_filing', $2, 'acknowledgement.pdf', $3) returning id`,
    [companyId, filed.id, `filings/${filed.id}/acknowledgement.pdf`],
  );
  await db.query(
    `update tax_filing_deposits set acknowledgement_id = $2 where filing_id = $1`,
    [filed.id, proof.id],
  );
  const draftFiling = await one<{ id: string }>(
    db,
    `select id from prepare_filing($1, ($2::date + interval '1 year')::date,
                                       ($3::date + interval '1 year')::date)`,
    [companyId, FROM, TO],
  );

  const rejected = await one<{ id: string }>(
    db,
    `select id from prepare_filing($1, ($2::date + interval '3 years')::date,
                                       ($3::date + interval '3 years')::date)`,
    [companyId, FROM, TO],
  );
  await db.query(`select file_filing($1)`, [rejected.id]);
  await db.query(`select record_filing_outcome($1, 'rejected', null, 'Unreadable')`, [rejected.id]);

  // Money against the invoice: one payment matched, so there is a matching to
  // undo, and one left open, so there is a matching to make.
  const pay = async (): Promise<string> => {
    const payment = await one<{ id: string }>(
      db,
      `insert into payments (company_id, direction, payment_date, amount, currency_code,
                             contact_id, journal_id)
       select $1, 'inbound', $2::date, 100, c.currency_code, $3, $4
         from companies c where c.id = $1
       returning id`,
      [companyId, FROM, contactId, bank.id],
    );
    await db.query(`select post_payment($1)`, [payment.id]);
    const line = await one<{ id: string }>(
      db,
      `select l.id from entry_lines l join payments p on p.entry_id = l.entry_id
        where p.id = $1 and l.contact_id = $2`,
      [payment.id, contactId],
    );
    return line.id;
  };
  const matchedLine = await pay();
  await db.query(`select reconcile($1, $2, 100)`, [receivable.id, matchedLine]);
  const reconciliation = await one<{ id: string }>(
    db,
    `select id from reconciliations where company_id = $1 limit 1`,
    [companyId],
  );
  const openPaymentLineId = await pay();

  const accountCodes = (
    await rows<{ code: string }>(
      db,
      `select code from accounts where company_id = $1 order by code limit 3`,
      [companyId],
    )
  ).map((a) => a.code);

  const invitation = await one<{ invitation_id: string }>(
    db,
    `select invitation_id from invite_member($1, $2)`,
    [companyId, `pending-${companyId}@example.test`],
  );
  const apiKey = await one<{ api_key_id: string }>(
    db,
    `select api_key_id from create_api_key($1, 'A reader', '["documents.read"]'::jsonb)`,
    [companyId],
  );
  const share = await one<{ share_id: string }>(
    db,
    `select share_id from share_document($1)`,
    [postedDocumentId],
  );

  return {
    companyId,
    contactId,
    postedDocumentId,
    draftDocumentId,
    draftEntryId: draftEntry.id,
    draftPaymentId: draftPayment.id,
    bankJournalId: bank.id,
    bankAccountId: bankAccount.id,
    bankTransactionId: bankTransaction.id,
    receivableLineId: receivable.id,
    fiscalYearId: fiscalYear.id,
    filedFilingId: filed.id,
    rejectedFilingId: rejected.id,
    draftFilingId: draftFiling.id,
    reconciliationId: reconciliation.id,
    openPaymentLineId,
    accountCodes,
    proofId: proof.id,
    invitationId: invitation.invitation_id,
    apiKeyId: apiKey.api_key_id,
    shareId: share.share_id,
  };
}

/**
 * A fingerprint of every table of the installation, read as the installer.
 * `attachments` and `user_preferences` are left to the tests that are about
 * them: they are the two tables a client does write.
 */
async function fingerprint(): Promise<Record<string, string>> {
  const tables = await rows<{ name: string }>(
    db,
    `select format('%I.%I', schemaname, tablename) as name
       from pg_tables
      where schemaname = any ($1)
        and tablename not in ('attachments', 'user_preferences')
      order by 1`,
    [SCHEMAS],
  );
  const out: Record<string, string> = {};
  for (const { name } of tables) {
    const print = await one<{ print: string }>(
      db,
      `select count(*) || ':' || coalesce(md5(string_agg(t::text, '|' order by t::text)), '')
              as print from ${name} t`,
    );
    out[name] = print.print;
  }
  return out;
}

beforeAll(async () => {
  db = await freshDatabase();
  await newInstanceAdmin(db);
  accountantId = await newUser(db, 'keeper@firm.example.test');
  clientId = await newUser(db, 'director@lune.example.test');
  otherClientId = await newUser(db, 'director@brume.example.test');
  viewerId = await newUser(db, 'reader@lune.example.test');

  mine = await keepBooks('Atelier Lune');
  theirs = await keepBooks('Verger Brume');

  await db.query(
    `insert into company_members (company_id, user_id, role)
     values ($1, $2, 'client'), ($3, $4, 'client'), ($1, $5, 'viewer')`,
    [mine.companyId, clientId, theirs.companyId, otherClientId, viewerId],
  );
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('the preset', () => {
  it('holds what a viewer holds, and two things more', async () => {
    const preset = async (role: string): Promise<string[]> =>
      (
        await rows<{ capability: string }>(
          db,
          `select capability from role_capabilities where role = $1::member_role order by 1`,
          [role],
        )
      ).map((r) => r.capability);

    const viewer = await preset('viewer');
    const client = await preset('client');
    expect(viewer.length).toBeGreaterThan(5);
    // Handing a piece over, and leaving with the books: the two acts of
    // somebody who owns a ledger that somebody else keeps.
    expect(client).toEqual([...viewer, 'documents.deposit', 'company.export'].sort());
  });

  it('holds nothing that writes, posts, files, pays, matches or administers', async () => {
    const held = (
      await asClient(() =>
        rows<{ member_capabilities: string }>(db, `select member_capabilities($1)`, [
          mine.companyId,
        ]),
      )
    ).map((r) => r.member_capabilities);

    expect(held).toContain('documents.read');
    expect(held).toContain('entries.read');
    expect(held).toContain('filings.read');
    expect(held).toContain('documents.deposit');
    // The reads of the modules come from the modules' own migrations.
    const moduleReads = (
      await rows<{ code: string }>(
        db,
        `select code from capabilities
          where area in (select code from modules) and code like '%.read' order by 1`,
      )
    ).map((r) => r.code);
    expect(moduleReads.length).toBeGreaterThan(0);
    for (const code of moduleReads) expect(held, code).toContain(code);

    // `company.export` reads, and reads everything: it writes no line of the books.
    for (const code of held) {
      expect(
        code === 'documents.deposit' || code === 'company.export' || code.endsWith('.read'),
        code,
      ).toBe(true);
    }
  });

  it('is described where a capability is described, so an interface can say what it is', async () => {
    const row = await one<{ area: string; description: string }>(
      db,
      `select area, description from capabilities where code = 'documents.deposit'`,
    );
    expect(row.area).toBe('documents');
    expect(row.description).toMatch(/insert only/i);
  });
});

describe('a client reads their own company', () => {
  it('reads the documents and their lines, drafts included', async () => {
    const seen = await asClient(() =>
      rows<{ id: string }>(db, `select id from documents where company_id = $1`, [mine.companyId]),
    );
    expect(seen.map((d) => d.id).sort()).toEqual(
      [mine.postedDocumentId, mine.draftDocumentId].sort(),
    );
    const lines = await asClient(() =>
      rows(db, `select id from document_lines where document_id = $1`, [mine.postedDocumentId]),
    );
    expect(lines.length).toBeGreaterThan(0);
  });

  it('reads the ledger, because the books are theirs', async () => {
    const lines = await asClient(() =>
      rows(db, `select id from entry_lines where company_id = $1`, [mine.companyId]),
    );
    expect(lines.length).toBeGreaterThan(1);
    const balance = await asClient(() =>
      rows(db, `select * from trial_balance($1, $2::date, $3::date)`, [mine.companyId, FROM, TO]),
    );
    expect(balance.length).toBeGreaterThan(0);
  });

  it('reads a filed declaration, its frozen figures and the deposit that carried it', async () => {
    const filing = await asClient(() =>
      one<{ state: string; reference: string }>(
        db,
        `select state, reference from tax_filings where id = $1`,
        [mine.filedFilingId],
      ),
    );
    expect(filing.state).toBe('filed');
    expect(filing.reference).toBe('REF-Atelier Lune');

    const boxes = await asClient(() =>
      rows(db, `select * from tax_filing_boxes where filing_id = $1`, [mine.filedFilingId]),
    );
    expect(boxes.length).toBeGreaterThan(0);

    const deposits = await asClient(() =>
      rows<{ acknowledgement_id: string }>(
        db,
        `select acknowledgement_id from tax_filing_deposits where filing_id = $1`,
        [mine.filedFilingId],
      ),
    );
    expect(deposits).toHaveLength(1);
    expect(deposits[0]!.acknowledgement_id).toBe(mine.proofId);
  });

  it('reads the proof of filing itself', async () => {
    const proof = await asClient(() =>
      one<{ file_name: string; storage_path: string }>(
        db,
        `select file_name, storage_path from attachments where id = $1`,
        [mine.proofId],
      ),
    );
    expect(proof.file_name).toBe('acknowledgement.pdf');
    expect(proof.storage_path).toContain(mine.filedFilingId);
  });
});

describe('a client hands a piece over', () => {
  let depositId: string;

  it('inserts it and reads it back in the same statement', async () => {
    // `returning` is checked against the SELECT policies: an insert the policy
    // admits and the read refuses fails as a whole, which is the trap.
    const row = await asClient(() =>
      one<{ id: string; uploaded_by: string }>(
        db,
        `insert into attachments (company_id, entity_type, entity_id, file_name, mime_type,
                                  storage_path)
         values ($1, 'company', $1, 'fuel-receipt.jpg', 'image/jpeg', $2)
         returning id, uploaded_by`,
        [mine.companyId, `inbox/${mine.companyId}/fuel-receipt.jpg`],
      ),
    );
    depositId = row.id;
    // Nobody said who: the column defaults to the caller.
    expect(row.uploaded_by).toBe(clientId);
  });

  it('lands where the firm sees it, signed', async () => {
    const tray = await asUser(db, accountantId, () =>
      rows<{ id: string; file_name: string; uploaded_by: string }>(
        db,
        `select id, file_name, uploaded_by from attachments
          where company_id = $1 and entity_type = 'company' and entity_id = $1`,
        [mine.companyId],
      ),
    );
    expect(tray).toEqual([
      { id: depositId, file_name: 'fuel-receipt.jpg', uploaded_by: clientId },
    ]);
  });

  it('is the firm’s to file: the accountant moves it onto the document it becomes', async () => {
    const moved = await asUser(db, accountantId, () =>
      db.query(
        `update attachments set entity_type = 'document', entity_id = $2 where id = $1`,
        [depositId, mine.draftDocumentId],
      ),
    );
    expect(moved.affectedRows).toBe(1);
    // …and the client still reads it there, through `documents.read`.
    const seen = await asClient(() =>
      one<{ entity_type: string }>(db, `select entity_type from attachments where id = $1`, [
        depositId,
      ]),
    );
    expect(seen.entity_type).toBe('document');
  });

  it('cannot be pinned on anything but the company', async () => {
    const targets: Array<[string, string]> = [
      ['document', mine.postedDocumentId],
      ['document', mine.draftDocumentId],
      ['entry', mine.draftEntryId],
      ['payment', mine.draftPaymentId],
      ['bank_transaction', mine.bankTransactionId],
      // The one that matters: a file of the client's making beside the receipt
      // the administration sent.
      ['tax_filing', mine.filedFilingId],
      ['fiscal_year', mine.fiscalYearId],
      ['contact', mine.contactId],
    ];
    for (const [type, id] of targets) {
      const message = await asClient(() =>
        expectError(
          db,
          `insert into attachments (company_id, entity_type, entity_id, file_name, storage_path)
           values ($1, $2, $3, 'forged.pdf', 'inbox/forged.pdf')`,
          [mine.companyId, type, id],
        ),
      );
      expect(message, type).toMatch(/row-level security/);
    }
  });

  it('cannot be signed with somebody else’s name, nor left unsigned', async () => {
    for (const signer of [accountantId, null]) {
      const message = await asClient(() =>
        expectError(
          db,
          `insert into attachments (company_id, entity_type, entity_id, file_name, storage_path,
                                    uploaded_by)
           values ($1, 'company', $1, 'unsigned.pdf', 'inbox/unsigned.pdf', $2)`,
          [mine.companyId, signer],
        ),
      );
      expect(message, String(signer)).toMatch(/row-level security/);
    }
  });

  it('cannot be dropped into another company of the firm', async () => {
    for (const [company, entity] of [
      [theirs.companyId, theirs.companyId],
      // A row of the client's company that points at the other one.
      [mine.companyId, theirs.companyId],
      [theirs.companyId, mine.companyId],
    ]) {
      const message = await asClient(() =>
        expectError(
          db,
          `insert into attachments (company_id, entity_type, entity_id, file_name, storage_path)
           values ($1, 'company', $2, 'stray.pdf', 'inbox/stray.pdf')`,
          [company, entity],
        ),
      );
      expect(message).toMatch(/row-level security/);
    }
  });

  it('is insert only: what was handed over is not changed or taken back', async () => {
    const second = await asClient(() =>
      one<{ id: string }>(
        db,
        `insert into attachments (company_id, entity_type, entity_id, file_name, storage_path)
         values ($1, 'company', $1, 'lease.pdf', 'inbox/lease.pdf') returning id`,
        [mine.companyId],
      ),
    );
    const updated = await asClient(() =>
      db.query(`update attachments set file_name = 'other.pdf' where id = $1`, [second.id]),
    );
    expect(updated.affectedRows).toBe(0);
    const deleted = await asClient(() =>
      db.query(`delete from attachments where id = $1`, [second.id]),
    );
    expect(deleted.affectedRows).toBe(0);
    // Nor the proof of a filing, which the same table holds.
    const proof = await asClient(() =>
      db.query(`delete from attachments where id = $1`, [mine.proofId]),
    );
    expect(proof.affectedRows).toBe(0);
    const still = await one<{ file_name: string }>(
      db,
      `select file_name from attachments where id = $1`,
      [second.id],
    );
    expect(still.file_name).toBe('lease.pdf');
  });

  it('is refused to a viewer, who reads and hands nothing over', async () => {
    const message = await asUser(db, viewerId, () =>
      expectError(
        db,
        `insert into attachments (company_id, entity_type, entity_id, file_name, storage_path)
         values ($1, 'company', $1, 'viewer.pdf', 'inbox/viewer.pdf')`,
        [mine.companyId],
      ),
    );
    expect(message).toMatch(/row-level security/);
  });

  it('works for somebody who may deposit and may not read, and shows them only their own', async () => {
    const scannerId = await newUser(db, 'scanner@lune.example.test');
    await db.query(
      `insert into company_members (company_id, user_id, role, capabilities_granted,
                                    capabilities_revoked)
       values ($1, $2, 'viewer', array['documents.deposit'], array['documents.read'])`,
      [mine.companyId, scannerId],
    );
    const row = await asUser(db, scannerId, () =>
      one<{ id: string }>(
        db,
        `insert into attachments (company_id, entity_type, entity_id, file_name, storage_path)
         values ($1, 'company', $1, 'scan-0001.pdf', 'inbox/scan-0001.pdf') returning id`,
        [mine.companyId],
      ),
    );
    const seen = await asUser(db, scannerId, () =>
      rows<{ id: string }>(db, `select id from attachments where company_id = $1`, [
        mine.companyId,
      ]),
    );
    expect(seen).toEqual([{ id: row.id }]);
  });
});

describe('a client writes nothing else — by the table', () => {
  interface Table {
    name: string;
    has_company: boolean;
    first_column: string;
  }
  let tables: Table[];
  let before: Record<string, string>;

  beforeAll(async () => {
    tables = await rows<Table>(
      db,
      `select format('%I.%I', n.nspname, c.relname) as name,
              exists (select 1 from pg_attribute a
                       where a.attrelid = c.oid and a.attname = 'company_id'
                         and not a.attisdropped) as has_company,
              (select a.attname from pg_attribute a
                where a.attrelid = c.oid and a.attnum > 0 and not a.attisdropped
                  and a.attgenerated = ''
                order by a.attnum limit 1) as first_column
         from pg_class c
         join pg_namespace n on n.oid = c.relnamespace
        where c.relkind = 'r' and n.nspname = any ($1)
          and (has_table_privilege('authenticated', c.oid, 'insert')
               or has_table_privilege('authenticated', c.oid, 'update')
               or has_table_privilege('authenticated', c.oid, 'delete'))
          and c.relname <> 'user_preferences'
        order by 1`,
      [SCHEMAS],
    );
    before = await fingerprint();
  });

  it('sweeps every table a signed-in person may write, and there are many', () => {
    expect(tables.length).toBeGreaterThan(25);
    const names = tables.map((t) => t.name);
    for (const must of [
      'public.documents',
      'public.document_lines',
      'public.entries',
      'public.entry_lines',
      'public.payments',
      'public.reconciliations',
      'public.bank_transactions',
      'public.tax_filings',
      'public.tax_filing_boxes',
      'public.tax_filing_deposits',
      'public.accounts',
      'public.journals',
      'public.taxes',
      'public.fiscal_years',
      'public.companies',
      'public.company_members',
      'public.attachments',
    ]) {
      expect(names, must).toContain(must);
    }
  });

  it('changes no row of any of them', async () => {
    const touched: string[] = [];
    for (const table of tables) {
      if (!(await may(table.name, 'update'))) continue;
      const result = await asClient(() =>
        db
          .query(`update ${table.name} set "${table.first_column}" = "${table.first_column}"`)
          .then((r) => r.affectedRows ?? 0)
          // A guard that raises is a refusal too; what it must not be is a change.
          .catch(() => 0),
      );
      if (result > 0) touched.push(`${table.name}: ${result}`);
    }
    expect(touched).toEqual([]);
  });

  it('deletes no row of any of them', async () => {
    const touched: string[] = [];
    for (const table of tables) {
      if (!(await may(table.name, 'delete'))) continue;
      const result = await asClient(() =>
        db
          .query(`delete from ${table.name}`)
          .then((r) => r.affectedRows ?? 0)
          .catch(() => 0),
      );
      if (result > 0) touched.push(`${table.name}: ${result}`);
    }
    expect(touched).toEqual([]);
  });

  it('inserts no row in any table of their company', async () => {
    const admitted: string[] = [];
    for (const table of tables.filter((t) => t.has_company)) {
      if (!(await may(table.name, 'insert'))) continue;
      const outcome = await asClient(() =>
        db
          .query(`insert into ${table.name} (company_id) values ($1)`, [mine.companyId])
          .then(() => 'inserted')
          .catch((error: Error) => error.message),
      );
      if (outcome === 'inserted') admitted.push(table.name);
    }
    expect(admitted).toEqual([]);
  });

  it('writes each thing a firm writes, by name, and is refused each time', async () => {
    const attempts: Array<[string, string, unknown[]]> = [
      [
        'a document',
        `insert into documents (company_id, doc_type, contact_id, document_date)
         values ($1, 'purchase_invoice', $2, $3::date)`,
        [mine.companyId, mine.contactId, FROM],
      ],
      [
        'a line on a draft',
        `insert into document_lines (company_id, document_id, sequence, description, quantity, unit_price)
         values ($1, $2, 99, 'slipped in', 1, 1)`,
        [mine.companyId, mine.draftDocumentId],
      ],
      [
        'an entry',
        `insert into entries (company_id, journal_id, entry_date, description, state)
         values ($1, (select journal_id from entries where id = $2), $3::date, 'by the client', 'draft')`,
        [mine.companyId, mine.draftEntryId, FROM],
      ],
      [
        'a ledger line',
        `insert into entry_lines (entry_id, company_id, account_id, sequence, debit, credit)
         values ($1, $2, (select id from accounts where company_id = $2 limit 1), 10, 1, 0)`,
        [mine.draftEntryId, mine.companyId],
      ],
      [
        'a payment',
        `insert into payments (company_id, direction, payment_date, amount, currency_code, contact_id, journal_id)
         select $1, 'outbound', $2::date, 50, currency_code, $3, $4 from companies where id = $1`,
        [mine.companyId, FROM, mine.contactId, mine.bankJournalId],
      ],
      [
        'a bank line',
        `insert into bank_transactions (company_id, bank_account_id, sequence, transaction_date, amount, currency_code, state)
         select $1, $2, 2, $3::date, 10, currency_code, 'pending' from companies where id = $1`,
        [mine.companyId, mine.bankAccountId, FROM],
      ],
      [
        'a declaration',
        `insert into tax_filings (company_id, report_code, period_start, period_end)
         select company_id, report_code, period_start + 1000, period_end + 1000
           from tax_filings where id = $1`,
        [mine.filedFilingId],
      ],
      [
        'a deposit of a declaration',
        `insert into tax_filing_deposits (filing_id, sequence, channel)
         values ($1, 99, 'portal')`,
        [mine.filedFilingId],
      ],
      [
        'a contact',
        `insert into contacts (company_id, name) values ($1, 'A supplier of their own')`,
        [mine.companyId],
      ],
      [
        'a member',
        `insert into company_members (company_id, user_id, role) values ($1, $2, 'owner')`,
        [mine.companyId, otherClientId],
      ],
      [
        'a preset',
        `insert into role_capabilities (role, capability) values ('client', 'entries.write')`,
        [],
      ],
    ];
    for (const [what, sql, params] of attempts) {
      const message = await asClient(() => expectError(db, sql, params));
      expect(message, what).toMatch(/row-level security|permission denied|not_allowed/);
    }
  });

  it('cannot promote itself', async () => {
    const result = await asClient(() =>
      db.query(
        `update company_members
            set role = 'owner', capabilities_granted = array['entries.write']
          where company_id = $1 and user_id = $2`,
        [mine.companyId, clientId],
      ),
    );
    expect(result.affectedRows).toBe(0);
  });

  it('left the installation exactly as it was', async () => {
    expect(await fingerprint()).toEqual(before);
  });

  async function may(table: string, privilege: string): Promise<boolean> {
    const row = await one<{ may: boolean }>(
      db,
      `select has_table_privilege('authenticated', $1::regclass, $2) as may`,
      [table, privilege],
    );
    return row.may;
  }
});

describe('a client writes nothing else — by the function', () => {
  /**
   * What a client may call, and why each one is not a write to the books.
   * Everything else that is volatile and executable is in `REFUSED` below; a
   * function in neither list fails the test, which is the point of it.
   */
  const THEIRS_TO_CALL: Record<string, string> = {
    'public.accept_invitation': 'how they became a member in the first place',
    'public.set_preferences': 'their own language and display, keyed on their own user id',
    'public.use_api_key': 'presents a secret; holds nothing without one',
    'public.shared_document': 'what anybody holding a link may read',
    'public.export_company': 'leaves with the books of their own company: reads, and says so on the trail',
    'public.note_company_export': 'the line on the trail, which company.export is what allows',
  };

  let refused: Record<string, { sql: string; params: unknown[] }>;

  beforeAll(() => {
    const [first, second] = mine.accountCodes;
    const lines = JSON.stringify([
      { account_code: first, debit: '10', credit: '0' },
      { account_code: second, debit: '0', credit: '10' },
    ]);
    refused = {
      'public.post_document': { sql: `select post_document($1)`, params: [mine.draftDocumentId] },
      // Presenting a key is a door and not a privilege: a client who does not
      // hold one is told the secret is not a key of this installation, in the
      // same words anybody else is told.
      'public.present_api_key': { sql: `select present_api_key('not-a-key-of-this-installation')`, params: [] },
      // A rehearsal is the real call inside a block that is rolled back, so it
      // is refused where posting is — before there is anything to roll back.
      'public.rehearse_post_document': { sql: `select rehearse_post_document($1)`, params: [mine.draftDocumentId] },
      'public.post_entry': { sql: `select post_entry($1)`, params: [mine.draftEntryId] },
      'public.cancel_document': { sql: `select cancel_document($1)`, params: [mine.postedDocumentId] },
      // Definer: it asks documents.post itself, before it reads anything.
      'public.unpost_document': { sql: `select unpost_document($1)`, params: [mine.postedDocumentId] },
      'public.reverse_entry': {
        sql: `select reverse_entry((select entry_id from entry_lines where id = $1))`,
        params: [mine.receivableLineId],
      },
      'public.match_reversal': {
        sql: `select match_reversal(l.entry_id, l.entry_id) from (select (select entry_id from entry_lines where id = $1) as entry_id) l`,
        params: [mine.receivableLineId],
      },
      'public.post_payment': { sql: `select post_payment($1)`, params: [mine.draftPaymentId] },
      'public.post_module_entry': {
        sql: `select post_module_entry($1, 'assets', 'client:1', $2::date, 'by the client', $3::jsonb, null)`,
        params: [mine.companyId, FROM, lines],
      },
      'public.reconcile': {
        sql: `select reconcile($1, $2, 100)`,
        params: [mine.receivableLineId, mine.openPaymentLineId],
      },
      'public.unreconcile': { sql: `select unreconcile($1)`, params: [mine.reconciliationId] },
      'public.settle_from_statement': {
        sql: `select settle_from_statement($1, array[$2]::uuid[])`,
        params: [mine.bankTransactionId, mine.receivableLineId],
      },
      'public.confirm_contact': {
        sql: `select confirm_contact($1, $2)`,
        params: [mine.bankTransactionId, mine.contactId],
      },
      'public.settle_cash_basis_tax': {
        sql: `select settle_cash_basis_tax($1, $2::date)`,
        params: [mine.postedDocumentId, TO],
      },
      'public.prepare_filing': {
        sql: `select prepare_filing($1, ($2::date + interval '2 years')::date, ($3::date + interval '2 years')::date)`,
        params: [mine.companyId, FROM, TO],
      },
      'public.file_filing': { sql: `select file_filing($1, 'BY-THE-CLIENT')`, params: [mine.draftFilingId] },
      'public.record_filing_outcome': {
        sql: `select record_filing_outcome($1, 'accepted', null, null)`,
        params: [mine.filedFilingId],
      },
      'public.settle_filing': { sql: `select settle_filing($1)`, params: [mine.filedFilingId] },
      'public.supersede_filing': { sql: `select supersede_filing($1)`, params: [mine.filedFilingId] },
      'public.reopen_filing': { sql: `select reopen_filing($1)`, params: [mine.rejectedFilingId] },
      'public.lock_filed_period': { sql: `select lock_filed_period($1)`, params: [mine.filedFilingId] },
      'public.auto_settle': {
        sql: `select auto_settle($1, $2::date, $3::date, true)`,
        params: [mine.companyId, FROM, TO],
      },
      // Refused on the person before the file is looked at, so what the file
      // holds does not matter here; `bank_statement_import.test.ts` has the
      // same refusal with a statement that would otherwise import.
      'public.import_bank_statement': {
        sql: `select import_bank_statement($1, '{"statements": []}'::jsonb)`,
        params: [mine.companyId],
      },
      // Refused on the person, by name, before the books are read.
      'public.import_books': {
        sql: `select import_books($1, jsonb_build_object('source', 'fec', 'checksum', 'sha256:' || repeat('0', 64), 'entries', '[]'::jsonb))`,
        params: [mine.companyId],
      },
      // Invoker: the year it would open is refused by the policy of fiscal_years.
      'public.import_fiscal_year_for': {
        sql: `select import_fiscal_year_for($1, ($2::date - interval '20 years')::date)`,
        params: [mine.companyId, FROM],
      },
      'public.close_fiscal_year': { sql: `select close_fiscal_year($1)`, params: [mine.fiscalYearId] },
      'public.reopen_fiscal_year': { sql: `select reopen_fiscal_year($1)`, params: [mine.fiscalYearId] },
      'public.opening_balance': {
        sql: `select opening_balance($1, $2, $3::jsonb, true)`,
        params: [mine.companyId, mine.fiscalYearId, lines],
      },
      'public.next_entry_number': {
        sql: `select next_entry_number($1, $2::date)`,
        params: [mine.bankJournalId, FROM],
      },
      'public.next_matching_number': { sql: `select next_matching_number($1)`, params: [mine.companyId] },
      'public.catch_up_journal_sequence': {
        sql: `select catch_up_journal_sequence($1, $2::date, '9999')`,
        params: [mine.bankJournalId, FROM],
      },
      'public.invite_member': {
        sql: `select * from invite_member($1, 'accomplice@example.test', 'owner')`,
        params: [mine.companyId],
      },
      'public.revoke_invitation': { sql: `select revoke_invitation($1)`, params: [mine.invitationId] },
      'public.create_api_key': {
        sql: `select * from create_api_key($1, 'A key of their own', '["entries.write"]'::jsonb)`,
        params: [mine.companyId],
      },
      'public.revoke_api_key': { sql: `select revoke_api_key($1)`, params: [mine.apiKeyId] },
      'public.share_document': { sql: `select * from share_document($1)`, params: [mine.postedDocumentId] },
      'public.revoke_share': { sql: `select revoke_share($1)`, params: [mine.shareId] },
      'public.enable_module': { sql: `select enable_module($1, 'budgets')`, params: [mine.companyId] },
      'public.disable_module': { sql: `select disable_module($1, 'budgets')`, params: [mine.companyId] },
      'public.pack_upgrade': {
        sql: `select * from pack_upgrade($1, (select country from companies where id = $1), true)`,
        params: [mine.companyId],
      },
      'public.install_country_template': {
        sql: `select install_country_template($1, (select country from companies where id = $1), null, null)`,
        params: [mine.companyId],
      },
      'public.pin_referenced_accounts': {
        sql: `select pin_referenced_accounts($1)`,
        params: [mine.companyId],
      },
      'public.create_company': {
        sql: `select create_company('A company of their own', (select country from companies where id = $1))`,
        params: [mine.companyId],
      },
      'public.import_company': {
        sql: `select import_company(jsonb_build_object('manifest', jsonb_build_object('format', 'ekwo.company-archive')))`,
        params: [],
      },
      'public.claim_instance_admin': { sql: `select claim_instance_admin($1)`, params: [clientId] },
      'public.init_instance': {
        sql: `select init_instance('Theirs now', (select country from companies where id = $1))`,
        params: [mine.companyId],
      },
      'public.register_instance': { sql: `select register_instance('client@example.test')`, params: [] },
      'public.unregister_instance': { sql: `select unregister_instance()`, params: [] },
      'public.documents_refresh_totals': {
        sql: `select documents_refresh_totals($1)`,
        params: [mine.draftDocumentId],
      },
      'public.documents_refresh_amount_paid': {
        sql: `select documents_refresh_amount_paid($1)`,
        params: [mine.postedDocumentId],
      },
      'public.documents_allocate_included_tax': {
        sql: `select documents_allocate_included_tax($1)`,
        params: [mine.draftDocumentId],
      },
      'public.ekwo_pre_request': { sql: `select ekwo_pre_request()`, params: [] },
      'assets.create_asset': {
        sql: `select assets.create_asset($1, 'CLI', 'A van', $2::date, 1000, $3, $4, $5, null, 36)`,
        params: [mine.companyId, FROM, ...mine.accountCodes],
      },
      'assets.run_depreciation': {
        sql: `select assets.run_depreciation($1, $2::date)`,
        params: [mine.companyId, TO],
      },
      'assets.generate_schedule': { sql: `select assets.generate_schedule($1)`, params: [mine.companyId] },
      'assets.split_into_months': { sql: `select assets.split_into_months($1)`, params: [mine.companyId] },
      'assets.dispose_asset': {
        sql: `select assets.dispose_asset($1, $2::date, 0, null, null)`,
        params: [mine.companyId, TO],
      },
    };
  });

  it('classifies every volatile function a signed-in person may call', async () => {
    const callable = (
      await rows<{ name: string }>(
        db,
        `select distinct n.nspname || '.' || p.proname as name
           from pg_proc p join pg_namespace n on n.oid = p.pronamespace
          where n.nspname = any ($1)
            and p.prorettype <> 'trigger'::regtype
            and p.provolatile = 'v'
            and has_function_privilege('authenticated', p.oid, 'execute')
          order by 1`,
        [SCHEMAS],
      )
    ).map((r) => r.name);

    const known = new Set([...Object.keys(THEIRS_TO_CALL), ...Object.keys(refused)]);
    expect(callable.filter((name) => !known.has(name))).toEqual([]);
    // …and the lists name nothing that is gone.
    expect([...known].filter((name) => !callable.includes(name))).toEqual([]);
  });

  /**
   * Functions that answer a client without raising, because the statement
   * inside them met row level security and changed no row. They are not
   * refusals a person can read, and `docs/decisions/0004-a-permission-is-a-capability.md` says so; what is
   * asserted of them is the only thing that matters here, which is that the
   * books did not move.
   */
  const QUIET = [
    'assets.run_depreciation',
    'public.auto_settle',
    'public.confirm_contact',
    'public.documents_allocate_included_tax',
    'public.documents_refresh_amount_paid',
    'public.documents_refresh_totals',
    // PostgREST calls it at the start of every request. With no header on the
    // request — which is every request a person makes — it returns having done
    // nothing, and that is the whole of what it does here.
    'public.ekwo_pre_request',
    'public.pin_referenced_accounts',
    'public.record_filing_outcome',
    'public.reopen_filing',
    'public.settle_cash_basis_tax',
    'public.unreconcile',
  ];

  it('is refused by each of them, or changes nothing, and the books are what they were', async () => {
    // Both modules on, so that a refusal is about the person and not about
    // the company having no such thing.
    await db.query(`select enable_module($1, 'budgets')`, [mine.companyId]);
    await db.query(`select enable_module($1, 'assets')`, [mine.companyId]);
    const before = await fingerprint();
    const outcomes: Record<string, string> = {};
    for (const [name, call] of Object.entries(refused)) {
      outcomes[name] = await asClient(() =>
        db
          .query(call.sql, call.params)
          .then(() => 'returned')
          .catch((error: Error) => error.message),
      );
    }
    expect(await fingerprint()).toEqual(before);

    const quiet = Object.keys(outcomes).filter((name) => outcomes[name] === 'returned');
    expect(quiet.sort()).toEqual(QUIET);
  });
});

describe('two definer functions that checked nobody', () => {
  /**
   * Found by the sweep above, and the reason it prints nothing and compares
   * everything: both returned quietly. `catch_up_journal_sequence()` trusted
   * that `post_entry()` had checked its caller, and was executable on its own;
   * `touch_api_key()` was only ever meant to be called by `use_api_key()`.
   */
  async function counters(companyId: string): Promise<string> {
    const row = await one<{ print: string }>(
      db,
      `select coalesce(string_agg(s.journal_id || ':' || s.year || ':' || s.last_number, '|'
                                  order by s.journal_id, s.year), '') as print
         from journal_sequences s join journals j on j.id = s.journal_id
        where j.company_id = $1`,
      [companyId],
    );
    return row.print;
  }

  /** A number of the journal's own shape, a long way ahead of the last one drawn. */
  async function farAhead(documentId: string): Promise<{ journalId: string; number: string }> {
    const entry = await one<{ journal_id: string; number: string }>(
      db,
      `select e.journal_id, e.number from entries e join documents d on d.entry_id = e.id
        where d.id = $1`,
      [documentId],
    );
    const number = entry.number.replace(/\d+$/, (digits) => '9'.repeat(digits.length));
    expect(number).not.toBe(entry.number);
    return { journalId: entry.journal_id, number };
  }

  it('a counter is not moved by a client, in their company or in another', async () => {
    for (const books of [mine, theirs]) {
      const before = await counters(books.companyId);
      const { journalId, number } = await farAhead(books.postedDocumentId);
      const message = await asClient(() =>
        expectError(db, `select catch_up_journal_sequence($1, $2::date, $3)`, [
          journalId,
          FROM,
          number,
        ]),
      );
      expect(message).toMatch(/not_allowed: .* needs entries\.post/);
      expect(await counters(books.companyId)).toBe(before);
    }
  });

  it('still catches the counter up for whoever posts an imported entry', async () => {
    // The path the function exists for, walked by somebody who holds both
    // capabilities, so the guard is known to let the real caller through.
    const importer = await newUser(db, 'importer@firm.example.test');
    await db.query(
      `insert into company_members (company_id, user_id, role, capabilities_granted)
       values ($1, $2, 'accountant', array['entries.import'])`,
      [mine.companyId, importer],
    );
    const { journalId, number } = await farAhead(mine.postedDocumentId);
    const before = await counters(mine.companyId);
    await asUser(db, importer, () =>
      db.query(`select catch_up_journal_sequence($1, $2::date, $3)`, [journalId, FROM, number]),
    );
    expect(await counters(mine.companyId)).not.toBe(before);
  });

  it('a key is not stamped as used by somebody who did not present it', async () => {
    const message = await asClient(() =>
      expectError(db, `select touch_api_key($1)`, [mine.apiKeyId]),
    );
    expect(message).toMatch(/permission denied/);
    const key = await one<{ last_used_at: string | null }>(
      db,
      `select last_used_at::text from api_keys where id = $1`,
      [mine.apiKeyId],
    );
    expect(key.last_used_at).toBeNull();
  });
});

describe('the other companies of the firm', () => {
  it('do not exist for a client: no row of any table, in any schema', async () => {
    const tables = await rows<{ name: string }>(
      db,
      `select format('%I.%I', n.nspname, c.relname) as name
         from pg_class c
         join pg_namespace n on n.oid = c.relnamespace
         join pg_attribute a on a.attrelid = c.oid and a.attname = 'company_id' and not a.attisdropped
        where c.relkind in ('r', 'v') and n.nspname = any ($1)
          and has_table_privilege('authenticated', c.oid, 'select')
        order by 1`,
      [SCHEMAS],
    );
    expect(tables.length).toBeGreaterThan(25);

    const leaks: string[] = [];
    let populated = 0;
    for (const { name } of tables) {
      const held = await one<{ n: number }>(
        db,
        `select count(*)::int as n from ${name} where company_id = $1`,
        [theirs.companyId],
      );
      if (held.n > 0) populated += 1;
      const seen = await asClient(() =>
        one<{ n: number }>(db, `select count(*)::int as n from ${name} where company_id = $1`, [
          theirs.companyId,
        ]),
      );
      if (seen.n > 0) leaks.push(`${name}: ${seen.n}`);
    }
    // The sweep is only worth something if the other company has books to leak.
    expect(populated).toBeGreaterThan(12);
    expect(leaks).toEqual([]);
  });

  it('are not in the list of companies, nor reachable through a child table', async () => {
    const companies = await asClient(() => rows<{ id: string }>(db, `select id from companies`));
    expect(companies).toEqual([{ id: mine.companyId }]);

    for (const [table, id] of [
      ['tax_filing_boxes', theirs.filedFilingId],
      ['tax_filing_deposits', theirs.filedFilingId],
    ] as const) {
      const seen = await asClient(() =>
        rows(db, `select 1 from ${table} where filing_id = $1`, [id]),
      );
      expect(seen, table).toEqual([]);
    }
  });

  it('answer nothing through a function either', async () => {
    const balance = await asClient(() =>
      rows(db, `select * from trial_balance($1, $2::date, $3::date)`, [theirs.companyId, FROM, TO]),
    );
    expect(balance).toEqual([]);
    const held = await asClient(() =>
      rows(db, `select member_capabilities($1)`, [theirs.companyId]),
    );
    expect(held).toEqual([]);
    const other = await asClient(() =>
      expectError(db, `select member_capabilities($1, $2)`, [theirs.companyId, otherClientId]),
    );
    expect(other).toMatch(/not_allowed/);
  });

  it('take no piece from them', async () => {
    const before = await one<{ n: number }>(
      db,
      `select count(*)::int as n from attachments where company_id = $1`,
      [theirs.companyId],
    );
    expect(before.n).toBe(1);
  });

  it('hold the same for the client on the other side', async () => {
    const companies = await asUser(db, otherClientId, () =>
      rows<{ id: string }>(db, `select id from companies`),
    );
    expect(companies).toEqual([{ id: theirs.companyId }]);
  });
});

describe('an invitation', () => {
  it('carries the preset, and accepting it makes a client', async () => {
    const invited = await newUser(db, 'successor@lune.example.test');
    const created = await one<{ token: string }>(
      db,
      `select token from invite_member($1, 'successor@lune.example.test', 'client')`,
      [mine.companyId],
    );
    const stored = await one<{ role: string }>(
      db,
      `select role from company_invitations
        where company_id = $1 and email = 'successor@lune.example.test'`,
      [mine.companyId],
    );
    expect(stored.role).toBe('client');

    await asUser(db, invited, () => db.query(`select accept_invitation($1)`, [created.token]));
    const membership = await one<{ role: string }>(
      db,
      `select role from company_members where company_id = $1 and user_id = $2`,
      [mine.companyId, invited],
    );
    expect(membership.role).toBe('client');

    const held = await asUser(db, invited, () =>
      rows<{ member_capabilities: string }>(db, `select member_capabilities($1)`, [mine.companyId]),
    );
    expect(held.map((r) => r.member_capabilities)).toContain('documents.deposit');
    expect(held.map((r) => r.member_capabilities)).not.toContain('documents.write');
  });
});
