import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, newUser, type Fixture } from './helpers/factory.js';
import { packWhere } from './helpers/packs.js';

/**
 * A deposit, and what came back.
 *
 * Filing used to be one act with one date, which is the happy path and was the
 * only one the schema could describe. What is proved here:
 *
 *   1. every send is a row, with the reference and the answer that belong to
 *      **that** send;
 *   2. a rejected declaration is sent again — it was never received, so it has
 *      nothing to correct — and the second send is a second deposit;
 *   3. a rejection on the substance goes back to draft, is recomputed, and the
 *      refused send stays readable;
 *   4. an accepted declaration is not reopened: that one is a corrective;
 *   5. the administration's own words are kept, not summarised;
 *   6. what was sent and what came back are files of the declaration, and the
 *      deposit is what tells the two apart;
 *   7. those files are read with `filings.read` and written with
 *      `filings.write`, like the deposit, by a person and by a machine key —
 *      every other attachment keeps `documents.read` and `documents.write`.
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

let db: PGlite;
let fx: Fixture;
let customerId: string;
let documentId: string;

interface Filing {
  id: string;
  state: string;
  reference: string | null;
  filed_at: string | null;
  prepared_at: string | null;
}

interface Deposit {
  sequence: number;
  channel: string;
  service: string | null;
  reference: string | null;
  outcome: string | null;
  outcome_at: string | null;
  message: string | null;
  sent_file_id: string | null;
  acknowledgement_id: string | null;
}

async function deposits(filingId: string): Promise<Deposit[]> {
  return rows<Deposit>(
    db,
    `select sequence, channel, service, reference, outcome, outcome_at::text, message,
            sent_file_id, acknowledgement_id
       from tax_filing_deposits where filing_id = $1 order by sequence`,
    [filingId],
  );
}

async function prepare(): Promise<Filing> {
  return one<Filing>(db, `select * from prepare_filing($1, $2::date, $3::date)`, [
    fx.companyId,
    FROM,
    TO,
  ]);
}

beforeAll(async () => {
  db = await freshDatabase();
  // country-literal: the company is installed in the pack under test, which is
  // whichever one carries a periodic return.
  fx = await newCompany(db, { country: pack.manifest.country, name: 'Deposit Fixture' });
  customerId = await newContact(db, fx.companyId, {
    name: 'Client',
    country: pack.manifest.country,
  });
  documentId = await newDocument(db, fx.companyId, {
    docType: 'sale_invoice',
    number: 'DEP-1',
    contactId: customerId,
    date: FROM,
    lines: [{ unitPrice: 5_000, taxCode: SALE.tax, accountCode: SALE.account }],
  });
  await db.query(`select post_document($1)`, [documentId]);
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('a send is a row', () => {
  let filingId: string;

  it('carries the channel, the service and the reference of that send', async () => {
    const filing = await prepare();
    filingId = filing.id;
    await db.query(`select file_filing($1, $2, null, 'service', $3)`, [
      filingId,
      'DEP-0001',
      'A transmission service',
    ]);

    const sent = await deposits(filingId);
    expect(sent).toHaveLength(1);
    expect(sent[0]!.sequence).toBe(1);
    expect(sent[0]!.channel).toBe('service');
    expect(sent[0]!.service).toBe('A transmission service');
    expect(sent[0]!.reference).toBe('DEP-0001');
    expect(sent[0]!.outcome).toBeNull();
  });

  it('defaults to the portal, which is a person uploading the file themselves', async () => {
    const other = await one<Filing>(
      db,
      `select * from prepare_filing($1, ($2::date + interval '1 year')::date,
                                       ($3::date + interval '1 year')::date)`,
      [fx.companyId, FROM, TO],
    );
    await db.query(`select file_filing($1)`, [other.id]);
    const sent = await deposits(other.id);
    expect(sent[0]!.channel).toBe('portal');
    expect(sent[0]!.service).toBeNull();
  });

  it('writes the answer on the send it answers, in the words it came in', async () => {
    await db.query(`select record_filing_outcome($1, 'rejected', null, $2)`, [
      filingId,
      'GRID 54 : le montant déclaré ne correspond pas à la base',
    ]);
    const sent = await deposits(filingId);
    expect(sent[0]!.outcome).toBe('rejected');
    expect(sent[0]!.outcome_at).toBeTruthy();
    expect(sent[0]!.message).toContain('GRID 54');
  });
});

describe('a rejected declaration', () => {
  it('is sent again, and the second send is a second deposit', async () => {
    const filing = await one<Filing>(
      db,
      `select * from tax_filings where company_id = $1 and period_start = $2::date`,
      [fx.companyId, FROM],
    );
    expect(filing.state).toBe('rejected');

    // Nothing to correct: it was never received.
    await db.query(`select file_filing($1, $2)`, [filing.id, 'DEP-0002']);
    const sent = await deposits(filing.id);
    expect(sent).toHaveLength(2);
    expect(sent.map((d) => d.sequence)).toEqual([1, 2]);
    expect(sent[0]!.reference).toBe('DEP-0001');
    expect(sent[1]!.reference).toBe('DEP-0002');
    // The first answer stays on the first send.
    expect(sent[0]!.outcome).toBe('rejected');
    expect(sent[1]!.outcome).toBeNull();

    const after = await one<Filing>(db, `select * from tax_filings where id = $1`, [filing.id]);
    expect(after.state).toBe('filed');
  });

  it('goes back to draft when the figures themselves have to be redone', async () => {
    const filing = await one<Filing>(
      db,
      `select * from tax_filings where company_id = $1 and period_start = $2::date`,
      [fx.companyId, FROM],
    );
    await db.query(`select record_filing_outcome($1, 'rejected', null, $2)`, [
      filing.id,
      'Base erronée',
    ]);

    const reopened = await one<Filing>(db, `select * from reopen_filing($1)`, [filing.id]);
    expect(reopened.state).toBe('draft');
    expect(reopened.filed_at).toBeNull();
    expect(reopened.reference).toBeNull();

    // Both refused sends are still there, which is what makes this safe.
    expect(await deposits(filing.id)).toHaveLength(2);

    // And the figures can be worked out again, which is what it was for.
    const documentId = await newDocument(db, fx.companyId, {
      docType: 'sale_invoice',
      number: 'DEP-2',
      contactId: customerId,
      date: FROM,
      lines: [{ unitPrice: 1_000, taxCode: SALE.tax, accountCode: SALE.account }],
    });
    await db.query(`select post_document($1)`, [documentId]);
    const again = await prepare();
    expect(again.id).toBe(filing.id);
    expect(again.prepared_at).toBeTruthy();

    // A third send, on the same declaration.
    await db.query(`select file_filing($1, $2)`, [filing.id, 'DEP-0003']);
    const sent = await deposits(filing.id);
    expect(sent).toHaveLength(3);
    expect(sent[2]!.reference).toBe('DEP-0003');
  });
});

describe('what it refuses', () => {
  it('reopening a declaration the administration accepted', async () => {
    const filing = await one<Filing>(
      db,
      `select * from tax_filings where company_id = $1 and period_start = $2::date`,
      [fx.companyId, FROM],
    );
    await db.query(`select record_filing_outcome($1, 'accepted')`, [filing.id]);

    const message = await expectError(db, `select reopen_filing($1)`, [filing.id]);
    expect(message).toContain('filing_not_rejected');
    expect(message).toContain('corrective');
  });

  it('sending a declaration that has been accepted', async () => {
    const filing = await one<Filing>(
      db,
      `select * from tax_filings where company_id = $1 and period_start = $2::date`,
      [fx.companyId, FROM],
    );
    expect(await expectError(db, `select file_filing($1)`, [filing.id])).toContain(
      'filing_already_accepted',
    );
  });

  it('an outcome on a declaration that never went', async () => {
    const draft = await one<Filing>(
      db,
      `select * from prepare_filing($1, ($2::date + interval '2 year')::date,
                                      ($3::date + interval '2 year')::date)`,
      [fx.companyId, FROM, TO],
    );
    expect(
      await expectError(db, `select record_filing_outcome($1, 'accepted')`, [draft.id]),
    ).toContain('filing_not_sent');
    expect(await deposits(draft.id)).toEqual([]);
  });
});

describe('the two files of a deposit', () => {
  it('are attachments of the declaration, and the deposit says which is which', async () => {
    const filing = await one<Filing>(
      db,
      `select * from tax_filings where company_id = $1 and period_start = $2::date`,
      [fx.companyId, FROM],
    );
    const attach = async (name: string): Promise<string> => {
      const row = await one<{ id: string }>(
        db,
        `insert into attachments (company_id, entity_type, entity_id, file_name, storage_path)
         values ($1, 'tax_filing', $2, $3, $4) returning id`,
        [fx.companyId, filing.id, name, `filings/${filing.id}/${name}`],
      );
      return row.id;
    };
    const sent = await attach('declaration.xml');
    const receipt = await attach('acknowledgement.pdf');

    await db.query(
      `update tax_filing_deposits set sent_file_id = $2, acknowledgement_id = $3
        where filing_id = $1 and sequence = (select max(sequence) from tax_filing_deposits
                                              where filing_id = $1)`,
      [filing.id, sent, receipt],
    );

    const last = (await deposits(filing.id)).at(-1)!;
    expect(last.sent_file_id).toBe(sent);
    expect(last.acknowledgement_id).toBe(receipt);

    // Both belong to the declaration, so a company that stops paying for the
    // transmission keeps its proof of filing in its own database.
    const held = await rows<{ file_name: string }>(
      db,
      `select file_name from attachments
        where entity_type = 'tax_filing' and entity_id = $1 order by file_name`,
      [filing.id],
    );
    expect(held.map((a) => a.file_name)).toEqual(['acknowledgement.pdf', 'declaration.xml']);
  });
});

describe('the files of a declaration are read as a declaration', () => {
  // `filings.read` is granted apart from `documents.read`: what a company
  // declared is not the same secret as what it books. The deposit already
  // asked it; the files it names asked `documents.read` until
  // `20261010203452`.
  let sentId: string;
  let receiptId: string;
  let invoiceFileId: string;
  let pinnedId: string;
  let withoutFilings: string;
  let reader: string;

  async function member(capabilities: { granted?: string[]; revoked?: string[] }): Promise<string> {
    const id = await newUser(db);
    await db.query(
      `insert into company_members (company_id, user_id, role, capabilities_granted,
                                    capabilities_revoked)
       values ($1, $2, 'viewer', $3, $4)`,
      [fx.companyId, id, capabilities.granted ?? [], capabilities.revoked ?? []],
    );
    return id;
  }

  async function seen(as: string): Promise<string[]> {
    return asUser(db, as, async () =>
      (
        await rows<{ id: string }>(db, `select id from attachments where id = any($1::uuid[])`, [
          [sentId, receiptId, invoiceFileId, pinnedId],
        ])
      ).map((a) => a.id),
    );
  }

  /** What a machine holding a key reads, inside one transaction. */
  async function seenWithKey(capabilities: string[]): Promise<string[]> {
    await db.query(`insert into auth.users (id, email) values ($1, $2) on conflict do nothing`, [
      fx.ownerId,
      'owner@deposit.test',
    ]);
    const key = await asUser(db, fx.ownerId, () =>
      one<{ secret: string }>(db, `select secret from create_api_key($1, $2, $3::jsonb)`, [
        fx.companyId,
        `Lecture ${capabilities.join(' ')}`,
        JSON.stringify(capabilities),
      ]),
    );
    await db.exec(`set role authenticated;`);
    await db.query(`begin`);
    try {
      await db.query(`select * from use_api_key($1)`, [key.secret]);
      return (
        await rows<{ id: string }>(db, `select id from attachments where id = any($1::uuid[])`, [
          [sentId, receiptId, invoiceFileId, pinnedId],
        ])
      ).map((a) => a.id);
    } finally {
      await db.query(`commit`);
      await db.exec(`reset role;`);
    }
  }

  beforeAll(async () => {
    const named = await one<{ sent_file_id: string; acknowledgement_id: string }>(
      db,
      `select d.sent_file_id, d.acknowledgement_id
         from tax_filing_deposits d join tax_filings f on f.id = d.filing_id
        where f.company_id = $1 and d.sent_file_id is not null`,
      [fx.companyId],
    );
    sentId = named.sent_file_id;
    receiptId = named.acknowledgement_id;
    invoiceFileId = (
      await one<{ id: string }>(
        db,
        `insert into attachments (company_id, entity_type, entity_id, file_name, storage_path)
         values ($1, 'document', $2, 'invoice.pdf', 'documents/invoice.pdf') returning id`,
        [fx.companyId, documentId],
      )
    ).id;
    // A receipt pinned on a document and named by a deposit: the deposit is
    // what makes it proof of filing, wherever it was pinned.
    pinnedId = (
      await one<{ id: string }>(
        db,
        `insert into attachments (company_id, entity_type, entity_id, file_name, storage_path)
         values ($1, 'document', $2, 'receipt-on-a-document.pdf', 'documents/receipt.pdf')
         returning id`,
        [fx.companyId, documentId],
      )
    ).id;
    const bare = await one<{ id: string }>(
      db,
      `select d.id from tax_filing_deposits d join tax_filings f on f.id = d.filing_id
        where f.company_id = $1 and d.acknowledgement_id is null limit 1`,
      [fx.companyId],
    );
    await db.query(`update tax_filing_deposits set acknowledgement_id = $2 where id = $1`, [
      bare.id,
      pinnedId,
    ]);
    withoutFilings = await member({ revoked: ['filings.read'] });
    reader = await member({});
  });

  it('are hidden from a member who reads the documents and not the declarations', async () => {
    const ids = await seen(withoutFilings);
    expect(ids).toEqual([invoiceFileId]);
    // …who sees no deposit either, which is the rule the files now follow.
    const deposits = await asUser(db, withoutFilings, () =>
      rows(db, `select id from tax_filing_deposits`),
    );
    expect(deposits).toEqual([]);
  });

  it('are read by a member who reads the declarations', async () => {
    expect((await seen(reader)).sort()).toEqual(
      [sentId, receiptId, invoiceFileId, pinnedId].sort(),
    );
  });

  it('follow the same rule for a machine key', async () => {
    expect(await seenWithKey(['documents.read'])).toEqual([invoiceFileId]);
    expect((await seenWithKey(['documents.read', 'filings.read'])).sort()).toEqual(
      [sentId, receiptId, invoiceFileId, pinnedId].sort(),
    );
  });

  it('are written with filings.write, and every other file with documents.write', async () => {
    const filing = await one<{ id: string }>(
      db,
      `select filing_id as id from tax_filing_deposits where sent_file_id = $1`,
      [sentId],
    );
    const bookkeeper = await newUser(db);
    await db.query(
      `insert into company_members (company_id, user_id, role, capabilities_revoked)
       values ($1, $2, 'accountant', array['filings.write'])`,
      [fx.companyId, bookkeeper],
    );
    const message = await asUser(db, bookkeeper, () =>
      expectError(
        db,
        `insert into attachments (company_id, entity_type, entity_id, file_name, storage_path)
         values ($1, 'tax_filing', $2, 'forged.xml', 'filings/forged.xml')`,
        [fx.companyId, filing.id],
      ),
    );
    expect(message).toMatch(/row-level security/);
    // The receipt is read — the bookkeeper holds filings.read — and not removed.
    const removed = await asUser(db, bookkeeper, () =>
      db.query(`delete from attachments where id = any($1::uuid[])`, [[receiptId, pinnedId]]),
    );
    expect(removed.affectedRows).toBe(0);
    const kept = await asUser(db, bookkeeper, () =>
      one<{ id: string }>(
        db,
        `insert into attachments (company_id, entity_type, entity_id, file_name, storage_path)
         values ($1, 'document', $2, 'quote.pdf', 'documents/quote.pdf') returning id`,
        [fx.companyId, documentId],
      ),
    );
    expect(kept.id).toBeTruthy();
  });
});
