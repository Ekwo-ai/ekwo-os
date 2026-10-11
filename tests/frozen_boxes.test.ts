/**
 * The boxes a ledger line is declared in, frozen on the line (issue #90).
 *
 * `vat_return()` used to read the boxes a line prints in and the form it is on
 * from today's `tax_postings`, which a member with `settings.write` edits and
 * `pack_upgrade()` rewrites — so a return already filed could move. Since
 * `20261011160431` the line carries both, written with it. These tests hold:
 *
 *   - **the figures did not move.** An installation that already keeps books
 *     is upgraded with the migration, and every pack's golden year returns the
 *     same declarations, to the cent; every guard lifted is back and no line
 *     is dated as edited;
 *   - **a posting changed afterwards moves no return**, and the next line
 *     written takes what the posting says now;
 *   - **nobody types them**, and a reversal is declared in the boxes of what
 *     it undoes.
 *
 * Nothing here names a country: what is booked is each pack's own golden year.
 */

import type { PGlite } from '@electric-sql/pglite';
import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { PackGolden } from '../packages/cli/src/index.js';
import { asUser, freshDatabase, one, repoRoot, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument } from './helpers/factory.js';
import { replayScenario } from './helpers/golden-scenario.js';
import { newMember, plainSale, refusalAs } from './helpers/integrity.js';
import { allPacks } from './helpers/packs.js';

const MIGRATION = '20261011160431_a_line_keeps_the_boxes_it_was_posted_in.sql';

const withGolden = allPacks.filter((pack) => pack.golden !== null);

interface Box {
  box: string;
  kind: string;
  amount: string;
}

async function returnOf(db: PGlite, companyId: string, from: string, to: string): Promise<Box[]> {
  return rows<Box>(
    db,
    `select box, kind, amount::text as amount from vat_return($1, $2::date, $3::date) order by sequence, box, kind`,
    [companyId, from, to],
  );
}

async function returnsOf(db: PGlite, companyId: string, golden: PackGolden): Promise<Record<string, Box[]>> {
  const out: Record<string, Box[]> = {};
  for (const period of golden.periods) out[period.code] = await returnOf(db, companyId, period.from, period.to);
  return out;
}

describe('an installation upgraded with books already in it', () => {
  let db: PGlite;
  const companies = new Map<string, string>();
  const before = new Map<string, Record<string, Box[]>>();
  let touchedBefore = '';

  beforeAll(async () => {
    db = await freshDatabase({ withoutMigrations: [MIGRATION] });
    for (const pack of withGolden) {
      const golden = pack.golden as PackGolden;
      // country-literal: every pack of the checkout books its own year, on its
      // own company, and the country is the pack's own.
      const { companyId } = await newCompany(db, {
        country: pack.manifest.country,
        name: `${golden.name} — frozen`,
        chart: golden.chart,
        language: golden.language,
        fiscalYear: golden.fiscalYear,
      });
      await replayScenario(db, companyId, golden);
      companies.set(pack.slug, companyId);
      before.set(pack.slug, await returnsOf(db, companyId, golden));
    }
    touchedBefore = (
      await one<{ h: string }>(db, `select md5(string_agg(id::text || updated_at::text, ',' order by id)) as h from entry_lines`)
    ).h;
    await db.exec(await readFile(join(repoRoot, 'supabase', 'migrations', MIGRATION), 'utf8'));
  }, 1_200_000);

  afterAll(async () => {
    await db?.close();
  });

  it.each(withGolden.map((pack) => [pack.slug, pack] as const))(
    '%s returns the same declarations after the upgrade, to the cent',
    async (slug, pack) => {
      expect(await returnsOf(db, companies.get(slug) as string, pack.golden as PackGolden)).toEqual(before.get(slug));
    },
  );

  it('freezes every line that names a box, and only those', async () => {
    const counts = await one<{ boxed: number; frozen: number; stray: number }>(
      db,
      `select count(*) filter (where declaration_box is not null)::int as boxed,
              count(*) filter (where declaration_box is not null and declaration_boxes is not null)::int as frozen,
              count(*) filter (where declaration_box is null and (declaration_boxes is not null or report_code is not null))::int as stray
         from entry_lines`,
    );
    expect(counts.boxed).toBeGreaterThan(0);
    expect(counts.frozen).toBe(counts.boxed);
    expect(counts.stray).toBe(0);
  });

  it('puts back every guard it lifted, and dates no line as edited', async () => {
    expect(await rows(db, `select tgrelid::regclass::text as tbl, tgname from pg_trigger where tgenabled <> 'O'`)).toEqual([]);
    const touchedAfter = (
      await one<{ h: string }>(db, `select md5(string_agg(id::text || updated_at::text, ',' order by id)) as h from entry_lines`)
    ).h;
    expect(touchedAfter).toBe(touchedBefore);
  });
});

describe('a posting changed after a line was written', () => {
  let db: PGlite;
  let companyId: string;
  let owner: string;
  let accountant: string;
  let sale: { taxCode: string; taxId: string; accountCode: string };
  let customer: string;

  async function invoice(number: string, date: string): Promise<string> {
    const documentId = await newDocument(db, companyId, {
      docType: 'sale_invoice',
      number,
      contactId: customer,
      date,
      lines: [{ unitPrice: 100, taxCode: sale.taxCode, accountCode: sale.accountCode }],
    });
    await db.query(`select post_document($1)`, [documentId]);
    return documentId;
  }

  async function taxLine(documentId: string): Promise<{ id: string; declaration_boxes: string[]; report_code: string | null }> {
    return one(
      db,
      `select l.id, l.declaration_boxes, l.report_code
         from entry_lines l join documents d on d.entry_id = l.entry_id
        where d.id = $1 and l.tax_line and l.declaration_box is not null`,
      [documentId],
    );
  }

  beforeAll(async () => {
    db = await freshDatabase();
    ({ companyId, ownerId: owner } = await newCompany(db));
    accountant = await newMember(db, companyId, 'accountant');
    sale = await plainSale(db, companyId);
    customer = await newContact(db, companyId, { name: 'Customer' });
  }, 300_000);

  afterAll(async () => {
    await db?.close();
  });

  it('moves no return already computed, and the next line takes what the posting says now', async () => {
    const first = await invoice('INV-90-1', '2026-07-03');
    const frozen = await taxLine(first);
    const july = await returnOf(db, companyId, '2026-07-01', '2026-07-31');
    expect(july.length).toBeGreaterThan(0);

    const extra = `${frozen.declaration_boxes[0]}-extra`;
    await asUser(db, owner, async () => {
      await db.query(
        `update tax_postings set declaration_boxes = declaration_boxes || $2::text, report_code = 'ELSEWHERE'
          where tax_id = $1 and posting_type = 'tax'`,
        [sale.taxId, extra],
      );
    });

    expect(await returnOf(db, companyId, '2026-07-01', '2026-07-31')).toEqual(july);
    expect(await taxLine(first)).toEqual(frozen);

    const second = await invoice('INV-90-2', '2026-08-03');
    const now = await taxLine(second);
    expect(now.declaration_boxes).toContain(extra);
    expect(now.report_code).toBe('ELSEWHERE');
  });

  it('replaces the frozen columns given on an insert, and refuses them changed by hand', async () => {
    const entry = await one<{ id: string }>(
      db,
      `insert into entries (company_id, journal_id, entry_date, state, currency_code)
       select c.id, c.miscellaneous_journal_id, '2026-09-04', 'draft', c.currency_code from companies c where c.id = $1
       returning id`,
      [companyId],
    );
    const posting = await one<{ box: string; account: string }>(
      db,
      `select declaration_box as box, account_id as account from tax_postings
        where tax_id = $1 and posting_type = 'tax' and document_kind = 'invoice' limit 1`,
      [sale.taxId],
    );
    const line = await asUser(db, accountant, () =>
      one<{ id: string; declaration_boxes: string[] }>(
        db,
        `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit,
                                  tax_id, tax_line, declaration_box, box_amount, declaration_boxes, report_code)
         values ($1, $2, $3, 10, 'By hand', 0, 10, $4, true, $5, 10, array['typed'], 'typed')
         returning id, declaration_boxes`,
        [entry.id, companyId, posting.account, sale.taxId, posting.box],
      ),
    );
    expect(line.declaration_boxes).not.toContain('typed');
    expect(
      await refusalAs(db, accountant, `update entry_lines set declaration_boxes = array['typed'] where id = $1`, [line.id]),
    ).toMatch(/^declaration_boxes_from_posting\b/);
    expect(
      await refusalAs(db, accountant, `update entry_lines set report_code = 'typed' where id = $1`, [line.id]),
    ).toMatch(/^declaration_boxes_from_posting\b/);
  });

  it('declares a reversal in the boxes of the line it undoes, whatever the posting says now', async () => {
    const posting = await one<{ box: string; account: string }>(
      db,
      `select declaration_box as box, account_id as account from tax_postings
        where tax_id = $1 and posting_type = 'tax' and document_kind = 'invoice' limit 1`,
      [sale.taxId],
    );
    const income = await one<{ id: string }>(db, `select account_id_by_code($1, $2) as id`, [companyId, sale.accountCode]);
    const twice = `${posting.box}-twice`;
    const listed = (list: string) =>
      db.query(`update tax_postings set declaration_boxes = ${list} where tax_id = $1 and posting_type = 'tax'`, [
        sale.taxId,
      ]);

    await listed(`array[declaration_box, '${twice}']`);
    const entry = await one<{ id: string }>(
      db,
      `insert into entries (company_id, journal_id, entry_date, state, currency_code)
       select c.id, c.miscellaneous_journal_id, '2026-11-04', 'draft', c.currency_code from companies c where c.id = $1
       returning id`,
      [companyId],
    );
    await asUser(db, accountant, async () => {
      await db.query(
        `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit,
                                  tax_id, tax_line, declaration_box, box_amount)
         values ($1, $2, $3, 10, 'By hand', 0, 10, $4, true, $5, 10),
                ($1, $2, $6, 20, 'By hand', 10, 0, null, false, null, null)`,
        [entry.id, companyId, posting.account, sale.taxId, posting.box, income.id],
      );
      await db.query(`select post_entry($1)`, [entry.id]);
    });
    await listed(`array[declaration_box]`);

    const reversal = await asUser(db, accountant, () =>
      one<{ id: string }>(db, `select id from reverse_entry($1)`, [entry.id]),
    );
    const boxes = await rows<{ entry_id: string; declaration_boxes: string[] }>(
      db,
      `select entry_id, declaration_boxes from entry_lines where entry_id in ($1, $2) and declaration_box is not null`,
      [entry.id, reversal.id],
    );
    expect(boxes).toHaveLength(2);
    for (const line of boxes) expect(line.declaration_boxes).toEqual([posting.box, twice].sort());
  });
});
