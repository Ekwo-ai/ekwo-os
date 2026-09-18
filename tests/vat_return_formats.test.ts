import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { generateVatConsignment, type FiledBox } from '@ekwo-ai/vat-consignment';
import { freshDatabase, one, rows } from './helpers/db.js';
import { newCompany } from './helpers/factory.js';
import { replayScenario } from './helpers/golden-scenario.js';
import { packOfCountry } from './helpers/packs.js';

/**
 * Where a filed declaration and a format brick meet.
 *
 * The chain this proves is the whole point of the declaration epic: a year of
 * real postings, the return computed from them, the figures **frozen** by
 * filing, and the file built from the freeze — not from a second computation.
 * Every figure in the XML is checked against the row it came from, to the cent,
 * and nothing is written down here that the books do not already say.
 *
 * The brick is fed `tax_filing_boxes` and nothing else. That is the contract:
 * it reads no database, and what is deposited is what was declared.
 *
 * country-literal: a format brick implements one administration's file, so the
 * block that tests it names the pack whose books that administration reads.
 * The core's own tests walk every pack instead.
 */

const pack = packOfCountry('BE');

interface Box {
  box: string;
  kind: string;
  amount: string;
}

let db: PGlite;
let companyId: string;
let filingId: string;
let boxes: Box[];

/**
 * The first quarter of the golden year — the one the scenario books the most
 * in — read from the pack rather than written here. The Belgian financial year
 * of that scenario is the calendar one, so the quarter of the form and the
 * quarter of the books are the same three months; a scenario whose year opened
 * mid-quarter would need the two told apart, and this says so rather than
 * quietly using one for the other.
 */
const openedOn = new Date(`${(pack.golden as NonNullable<typeof pack.golden>).fiscalYear.start}T00:00:00Z`);
const YEAR = openedOn.getUTCFullYear();
const QUARTER = Math.floor(openedOn.getUTCMonth() / 3) + 1;

beforeAll(async () => {
  const golden = pack.golden as NonNullable<typeof pack.golden>;
  db = await freshDatabase();
  ({ companyId } = await newCompany(db, {
    country: pack.manifest.country,
    name: golden.name,
    chart: golden.chart,
    language: golden.language,
    fiscalYear: golden.fiscalYear,
  }));
  await replayScenario(db, companyId, golden);

  expect(openedOn.getUTCMonth() % 3, 'the golden year opens on a quarter').toBe(0);

  const filing = await one<{ id: string }>(
    db,
    `select id from prepare_filing($1, $2::date,
              ($2::date + interval '3 month' - interval '1 day')::date)`,
    [companyId, golden.fiscalYear.start],
  );
  filingId = filing.id;
  await db.query(`select file_filing($1, 'TEST-DEPOSIT')`, [filingId]);
  boxes = await rows<Box>(
    db,
    `select box, kind, amount::text from tax_filing_boxes where filing_id = $1 order by box, kind`,
    [filingId],
  );
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('the Belgian return, from a year of Belgian books', () => {
  it('freezes figures the form can hold: one value per grid', () => {
    expect(boxes.length).toBeGreaterThan(0);
    const byGrid = new Map<string, string[]>();
    for (const row of boxes) {
      byGrid.set(row.box, [...(byGrid.get(row.box) ?? []), row.kind]);
    }
    // This form prints a base and a tax on lines of their own. A form that does
    // not — the French CA3 puts both on line 08 — produces two rows on one
    // grid, and the brick says so rather than silently dropping one.
    for (const kinds of byGrid.values()) expect(kinds).toHaveLength(1);
  });

  it('writes a file whose every grid is the figure that was filed', () => {
    const { file, filename, violations } = generateVatConsignment(boxes as FiledBox[], {
      declarant: { vatNumber: '0999999999', name: 'Demo', countryCode: pack.manifest.country },
      period: { year: YEAR, quarter: QUARTER },
      declarantReference: 'TEST-DEPOSIT',
    });

    expect(violations).toEqual([]);
    expect(filename).toMatch(/\.xml$/);

    for (const row of boxes) {
      const amount = Number(row.amount);
      if (Math.abs(amount) < 0.005) {
        expect(file).not.toContain(`GridNumber="${row.box.padStart(2, '0')}"`);
        continue;
      }
      expect(file).toContain(
        `<ns2:Amount GridNumber="${row.box.padStart(2, '0')}">${amount.toFixed(2)}</ns2:Amount>`,
      );
    }
  });

  it('carries the tax the books actually came to, and not a number computed twice', async () => {
    // Read the same period straight from the ledger, the way the return does,
    // and check the file against it: the freeze, the file and the books agree.
    const live = await rows<{ box: string; kind: string; amount: string }>(
      db,
      `select box, kind, amount::text from vat_return($1,
          (select period_start from tax_filings where id = $2),
          (select period_end from tax_filings where id = $2))
        where not hidden order by box, kind`,
      [companyId, filingId],
    );
    expect(live).toEqual(boxes);

    const { file } = generateVatConsignment(boxes as FiledBox[], {
      declarant: { vatNumber: '0999999999' },
      period: { year: YEAR, quarter: QUARTER },
    });
    const written = [...file.matchAll(/GridNumber="([0-9]{2})">(-?[0-9]+\.[0-9]{2})</g)].map(
      (match) => [match[1], match[2]] as const,
    );
    const expected = boxes
      .filter((row) => Math.abs(Number(row.amount)) >= 0.005)
      .map((row) => [row.box.padStart(2, '0'), Number(row.amount).toFixed(2)] as const)
      .sort((a, b) => Number(a[0]) - Number(b[0]));
    expect(written).toEqual(expected);
  });

  it('is the file the pack says this form is deposited as', async () => {
    const form = await one<{ file_format: string | null }>(
      db,
      `select file_format from tax_report_templates t
         join tax_filings f on f.report_code = t.code
        where f.id = $1`,
      [filingId],
    );
    // The pack names the brick, and the brick is the one this test imported.
    expect(form.file_format).toBe('vat-consignment');
  });

  it('keeps saying the same thing after the ledger moves, because the freeze is what it reads', async () => {
    // A late invoice, posted into the quarter after it was filed. This is the
    // case the whole freeze exists for: the return would answer differently
    // now, and the file must not.
    const before = generateVatConsignment(boxes as FiledBox[], {
      declarant: { vatNumber: '0999999999' },
      period: { year: YEAR, quarter: QUARTER },
    });

    const golden = pack.golden as NonNullable<typeof pack.golden>;
    const late = (golden.documents ?? []).find(
      (doc) => doc.type === 'sale_invoice' && doc.lines.some((l) => l.tax !== null),
    ) as NonNullable<typeof pack.golden>['documents'][number];
    const line = late.lines.find((l) => l.tax !== null)!;
    const contact = await one<{ id: string }>(
      db,
      `select id from contacts where company_id = $1 order by created_at limit 1`,
      [companyId],
    );
    const documentId = await one<{ id: string }>(
      db,
      `insert into documents (company_id, doc_type, number, contact_id, document_date)
       values ($1, 'sale_invoice', 'LATE-FOR-FILING', $2, $3::date) returning id`,
      [companyId, contact.id, golden.fiscalYear.start],
    );
    await db.query(
      `insert into document_lines (document_id, company_id, name, quantity, unit_price,
                                   account_id, tax_id)
       select $1, $2, 'Late', 1, 1000,
              (select id from accounts where company_id = $2 and code = $3),
              (select id from taxes where company_id = $2 and code = $4)`,
      [documentId.id, companyId, line.account, line.tax],
    );
    await db.query(`select post_document($1)`, [documentId.id]);

    // The ledger moved; the frozen figures did not.
    const frozen = await rows<Box>(
      db,
      `select box, kind, amount::text from tax_filing_boxes where filing_id = $1 order by box, kind`,
      [filingId],
    );
    expect(frozen).toEqual(boxes);

    const after = generateVatConsignment(frozen as FiledBox[], {
      declarant: { vatNumber: '0999999999' },
      period: { year: YEAR, quarter: QUARTER },
    });
    expect(after.file).toBe(before.file);

    // And the difference is not lost: it is what the drift reports.
    const drift = await rows<{ box: string; kind: string; difference: string }>(
      db,
      `select box, kind, difference::text from filing_drift($1)`,
      [filingId],
    );
    expect(drift.length).toBeGreaterThan(0);
  });
});
