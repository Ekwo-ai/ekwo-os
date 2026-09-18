import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, type Fixture } from './helpers/factory.js';
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
 *      deposit is what tells the two apart.
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
  const documentId = await newDocument(db, fx.companyId, {
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
