import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, type Fixture } from './helpers/factory.js';

let db: PGlite;
let fx: Fixture;
let customerId: string;

interface Filing {
  id: string;
  report_code: string;
  state: string;
  reference: string | null;
  supersedes_id: string | null;
}

async function invoice(number: string, date: string, amount: number): Promise<string> {
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

async function prepare(from: string, to: string): Promise<Filing> {
  return one<Filing>(db, `select * from prepare_filing($1, $2::date, $3::date)`, [
    fx.companyId,
    from,
    to,
  ]);
}

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db);
  customerId = await newContact(db, fx.companyId, { name: 'Client Declaration' });
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('preparing a declaration', () => {
  it('keeps the figures the return computed, box by box', async () => {
    await invoice('FAC-Q1-1', '2026-01-15', 1000);
    const filing = await prepare('2026-01-01', '2026-03-31');
    expect(filing.state).toBe('draft');

    const boxes = await rows<{ box: string; amount: string }>(
      db,
      `select box, amount from tax_filing_boxes where filing_id = $1 order by box`,
      [filing.id],
    );
    expect(boxes.length).toBeGreaterThan(0);

    // The frozen figures are the ones the return answers today, since nothing
    // has moved yet.
    const live = await rows<{ box: string; amount: string }>(
      db,
      `select box, amount from vat_return($1, '2026-01-01'::date, '2026-03-31'::date, $2)
        where not hidden order by box`,
      [fx.companyId, filing.report_code],
    );
    expect(boxes).toEqual(live);
  });

  it('refreshes a draft rather than making a second one', async () => {
    const first = await prepare('2026-01-01', '2026-03-31');
    await invoice('FAC-Q1-2', '2026-02-10', 500);
    const second = await prepare('2026-01-01', '2026-03-31');
    expect(second.id).toBe(first.id);

    const count = await one<{ count: string }>(
      db,
      `select count(*)::text as count from tax_filings
        where company_id = $1 and period_start = '2026-01-01'`,
      [fx.companyId],
    );
    expect(count.count).toBe('1');
  });

  it('refuses a form no pack in this installation carries', async () => {
    const message = await expectError(
      db,
      `select prepare_filing($1, '2026-01-01'::date, '2026-03-31'::date, 'XX-NOT-A-FORM')`,
      [fx.companyId],
    );
    expect(message).toContain('unknown_report_code');
  });
});

describe('a period where nothing happened', () => {
  /**
   * A nil return is a return: most administrations require one and fine its
   * absence. The first version of `file_filing()` counted the boxes and
   * refused an empty declaration, which would have made Ekwo unable to file
   * the most ordinary declaration a dormant company makes.
   */
  it('is filed nil rather than refused', async () => {
    const filing = await prepare('2025-01-01', '2025-03-31');
    const boxes = await one<{ count: string }>(
      db,
      `select count(*)::text as count from tax_filing_boxes where filing_id = $1`,
      [filing.id],
    );
    expect(boxes.count).toBe('0');
    const filed = await one<Filing>(db, `select * from file_filing($1, 'REF-NIL')`, [filing.id]);
    expect(filed.state).toBe('filed');
  });

  it('still refuses a declaration whose figures were never computed', async () => {
    const row = await one<{ id: string }>(
      db,
      `insert into tax_filings (company_id, report_code, period_start, period_end)
       select $1, periodic_return_code($1), '2024-01-01'::date, '2024-03-31'::date
       returning id`,
      [fx.companyId],
    );
    const message = await expectError(db, `select file_filing($1)`, [row.id]);
    expect(message).toContain('filing_not_prepared');
  });
});

describe('a declaration that has gone', () => {
  it('cannot have its figures changed, by anybody', async () => {
    // A period with something in it: an update over no rows fires no trigger,
    // and a freeze nobody can test is a freeze nobody should trust.
    await invoice('FAC-Q2-1', '2026-05-02', 400);
    const filing = await prepare('2026-04-01', '2026-06-30');
    await db.query(`select file_filing($1, 'REF-2026-Q2')`, [filing.id]);

    const changed = await expectError(
      db,
      `update tax_filing_boxes set amount = 1 where filing_id = $1`,
      [filing.id],
    );
    expect(changed).toContain('filing_is_frozen');

    const added = await expectError(
      db,
      `insert into tax_filing_boxes (filing_id, box, amount) values ($1, 'ZZ', 1)`,
      [filing.id],
    );
    expect(added).toContain('filing_is_frozen');
  });

  it('is not prepared again — the word for that is a corrective', async () => {
    const message = await expectError(
      db,
      `select prepare_filing($1, '2026-04-01'::date, '2026-06-30'::date)`,
      [fx.companyId],
    );
    expect(message).toContain('filing_already_filed');
  });

  it('shows what the ledger says now against what was sent', async () => {
    const filing = await one<Filing>(
      db,
      `select * from tax_filings where company_id = $1 and period_start = '2026-04-01'`,
      [fx.companyId],
    );
    const before = await rows(db, `select * from filing_drift($1)`, [filing.id]);
    expect(before).toEqual([]);

    // A late invoice lands in a period already declared.
    await invoice('FAC-LATE', '2026-05-20', 800);
    const after = await rows<{ box: string; filed: string; ledger: string; difference: string }>(
      db,
      `select * from filing_drift($1)`,
      [filing.id],
    );
    expect(after.length).toBeGreaterThan(0);
    expect(after.some((d) => Number(d.difference) === 800)).toBe(true);
  });
});

describe('the outcome', () => {
  it('refuses to come back before it has gone', async () => {
    const filing = await prepare('2026-07-01', '2026-09-30');
    const message = await expectError(db, `select record_filing_outcome($1, 'accepted')`, [
      filing.id,
    ]);
    expect(message).toContain('filing_not_sent');
  });

  it('refuses paying what was never accepted', async () => {
    const filing = await one<Filing>(
      db,
      `select * from tax_filings where company_id = $1 and period_start = '2026-07-01'`,
      [fx.companyId],
    );
    await db.query(`select file_filing($1, 'REF-2026-Q3')`, [filing.id]);
    const message = await expectError(db, `select record_filing_outcome($1, 'paid')`, [filing.id]);
    expect(message).toContain('filing_not_accepted');
  });

  it('takes accepted, then paid, and keeps the reference', async () => {
    const filing = await one<Filing>(
      db,
      `select * from tax_filings where company_id = $1 and period_start = '2026-07-01'`,
      [fx.companyId],
    );
    await db.query(`select record_filing_outcome($1, 'accepted')`, [filing.id]);
    const paid = await one<Filing>(db, `select * from record_filing_outcome($1, 'paid')`, [
      filing.id,
    ]);
    expect(paid.state).toBe('paid');
    expect(paid.reference).toBe('REF-2026-Q3');
  });

  it('refuses a state an administration never answers', async () => {
    const filing = await one<Filing>(
      db,
      `select * from tax_filings where company_id = $1 and period_start = '2026-07-01'`,
      [fx.companyId],
    );
    const message = await expectError(db, `select record_filing_outcome($1, 'draft')`, [filing.id]);
    expect(message).toContain('not_an_outcome');
  });
});

describe('a corrective', () => {
  it('replaces without erasing, and carries the ledger of today', async () => {
    const original = await one<Filing>(
      db,
      `select * from tax_filings where company_id = $1 and period_start = '2026-04-01'`,
      [fx.companyId],
    );
    const filedFigures = await rows<{ box: string; amount: string }>(
      db,
      `select box, amount from tax_filing_boxes where filing_id = $1 order by box`,
      [original.id],
    );

    const corrective = await one<Filing>(db, `select * from supersede_filing($1)`, [original.id]);
    expect(corrective.supersedes_id).toBe(original.id);
    expect(corrective.state).toBe('draft');

    const old = await one<Filing>(db, `select * from tax_filings where id = $1`, [original.id]);
    expect(old.state).toBe('superseded');
    // What was sent stays as it was sent.
    const stillThere = await rows<{ box: string; amount: string }>(
      db,
      `select box, amount from tax_filing_boxes where filing_id = $1 order by box`,
      [original.id],
    );
    expect(stillThere).toEqual(filedFigures);

    // And the corrective carries the late invoice.
    const drift = await rows(db, `select * from filing_drift($1)`, [corrective.id]);
    expect(drift).toEqual([]);
  });

  it('lets one live filing and one superseded share a period', async () => {
    const live = await rows<{ id: string }>(
      db,
      `select id from tax_filings
        where company_id = $1 and period_start = '2026-04-01' and state <> 'superseded'`,
      [fx.companyId],
    );
    expect(live).toHaveLength(1);
  });

  it('refuses to correct a declaration that never went', async () => {
    const draft = await prepare('2026-10-01', '2026-12-31');
    const message = await expectError(db, `select supersede_filing($1)`, [draft.id]);
    expect(message).toContain('filing_not_sent');
  });
});

describe('who may file', () => {
  it('reads and writes under a capability of its own, not under the ledger one', async () => {
    const granted = await rows<{ role: string }>(
      db,
      `select role::text from role_capabilities where capability = 'filings.write' order by role`,
    );
    expect(granted.length).toBeGreaterThan(0);
    const readers = await rows<{ role: string }>(
      db,
      `select role::text from role_capabilities where capability = 'filings.read' order by role`,
    );
    // Reading is granted more widely than filing.
    expect(readers.length).toBeGreaterThan(granted.length);
  });
});
