/**
 * The day a ledger line counts for a tax return, stored on the line.
 *
 * `entry_lines.declared_on` holds what a return used to work out at every read
 * — the line's tax point, or the date of its entry where it has none — so that
 * the period of a return is a range on one indexed column. These tests hold
 * the three things that make that safe:
 *
 *   - **the rule did not move.** An installation that already keeps books is
 *     upgraded with the three migrations, and every pack's golden year returns
 *     the same declaration, to the cent, before and after; a declaration filed
 *     before the upgrade does not drift after it;
 *   - **nobody types it.** The trigger derives it on every write, follows the
 *     date of a draft and the tax point a cash-basis settlement writes,
 *     replaces a value written by hand on a draft and refuses one on a posted
 *     line;
 *   - **it travels.** A company archive carries it, an archive written before
 *     it existed arrives with it derived, and one that carries a day the rule
 *     does not give is refused.
 *
 * Nothing here names a country: what is booked is each pack's own golden year.
 */

import type { PGlite } from '@electric-sql/pglite';
import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { Pack, PackGolden } from '../packages/cli/src/index.js';
import { exportAs, importAs, reseal, type Archive } from './helpers/company-archive.js';
import { expectError, freshDatabase, one, repoRoot, rows } from './helpers/db.js';
import { newCompany, newInstanceAdmin, newUser } from './helpers/factory.js';
import { replayScenario } from './helpers/golden-scenario.js';
import { allPacks, packWhere } from './helpers/packs.js';

/** The column, its backfill, and the readers moved onto it — in order. */
const MIGRATIONS = [
  '20261005160858_a_line_says_when_it_is_declared.sql',
  '20261005160859_the_declared_day_of_lines_already_written.sql',
  '20261005160900_a_period_is_read_through_its_index.sql',
];

const withGolden = allPacks.filter((pack) => pack.golden !== null);

interface Box {
  box: string;
  kind: string;
  amount: string;
}

/** Every return of the golden periods, exactly as the database prints it. */
async function returnsOf(db: PGlite, companyId: string, golden: PackGolden): Promise<Record<string, Box[]>> {
  const out: Record<string, Box[]> = {};
  for (const period of golden.periods) {
    out[period.code] = await rows<Box>(
      db,
      `select box, kind, amount::text as amount from vat_return($1, $2::date, $3::date) order by sequence, box, kind`,
      [companyId, period.from, period.to],
    );
  }
  return out;
}

/** Lines whose `declared_on` is not the rule's answer — none, ever. */
async function offTheRule(db: PGlite, companyId?: string): Promise<number> {
  return (
    await one<{ n: number }>(
      db,
      `select count(*)::int as n
         from entry_lines l join entries e on e.id = l.entry_id
        where ($1::uuid is null or l.company_id = $1)
          and l.declared_on is distinct from coalesce(l.tax_point_date, e.entry_date)`,
      [companyId ?? null],
    )
  ).n;
}

// ---------------------------------------------------------------------------
// The upgrade of an installation that already keeps books
// ---------------------------------------------------------------------------

describe('an installation upgraded with books already in it', () => {
  let db: PGlite;
  const companies = new Map<string, string>();
  const before = new Map<string, Record<string, Box[]>>();
  const filings = new Map<string, { id: string; movements: unknown[] }>();
  let touchedBefore = '';

  beforeAll(async () => {
    db = await freshDatabase({ withoutMigrations: MIGRATIONS });
    for (const pack of withGolden) {
      const golden = pack.golden as PackGolden;
      // country-literal: every pack of the checkout books its own year, on its
      // own company, and the country is the pack's own.
      const { companyId } = await newCompany(db, {
        country: pack.manifest.country,
        name: `${golden.name} — upgraded`,
        chart: golden.chart,
        language: golden.language,
        fiscalYear: golden.fiscalYear,
      });
      await replayScenario(db, companyId, golden);
      companies.set(pack.slug, companyId);
      before.set(pack.slug, await returnsOf(db, companyId, golden));

      // A declaration that has gone before the upgrade: what it froze has to
      // be what the ledger still says after it.
      const first = golden.periods[0];
      if (pack.report !== null && first !== undefined) {
        const filing = await one<{ id: string }>(db, `select id from prepare_filing($1, $2::date, $3::date)`, [
          companyId,
          first.from,
          first.to,
        ]);
        await db.query(`select file_filing($1, $2)`, [filing.id, `UPGRADE-${pack.slug.toUpperCase()}`]);
        filings.set(pack.slug, {
          id: filing.id,
          movements: await rows(db, `select account_id, balance::text from filing_tax_movements($1) order by 1`, [
            filing.id,
          ]),
        });
      }
    }
    touchedBefore = (
      await one<{ h: string }>(db, `select md5(string_agg(id::text || updated_at::text, ',' order by id)) as h from entry_lines`)
    ).h;

    for (const file of MIGRATIONS) {
      await db.exec(await readFile(join(repoRoot, 'supabase', 'migrations', file), 'utf8'));
    }
  }, 1_200_000);

  afterAll(async () => {
    await db?.close();
  });

  it('books something in every pack with a form, so the comparison compares figures', () => {
    expect(withGolden.length).toBeGreaterThan(0);
    // A pack with no declaration form — a country without a sales tax — has
    // nothing to compare but empty returns, and is compared all the same.
    for (const pack of withGolden.filter((p) => p.report !== null)) {
      const boxes = Object.values(before.get(pack.slug) ?? {}).flat();
      expect(boxes.length, `${pack.slug} returned nothing before the upgrade`).toBeGreaterThan(0);
    }
  });

  it.each(withGolden.map((pack) => [pack.slug, pack] as const))(
    '%s returns the same declarations after the upgrade, to the cent',
    async (slug, pack) => {
      const companyId = companies.get(slug) as string;
      expect(await returnsOf(db, companyId, pack.golden as PackGolden)).toEqual(before.get(slug));

      const filing = filings.get(slug);
      if (filing !== undefined) {
        expect(await rows(db, `select * from filing_drift($1)`, [filing.id]), `${slug} drifts`).toEqual([]);
        expect(
          await rows(db, `select account_id, balance::text from filing_tax_movements($1) order by 1`, [filing.id]),
        ).toEqual(filing.movements);
        expect(await rows(db, `select * from filings_touched_since($1)`, [companyId])).toEqual([]);
      }
    },
  );

  it('fills every line already written with the rule, and requires it from now on', async () => {
    expect((await one<{ n: number }>(db, `select count(*)::int as n from entry_lines`)).n).toBeGreaterThan(0);
    expect(await offTheRule(db)).toBe(0);
    const column = await one<{ required: boolean }>(
      db,
      `select attnotnull as required from pg_attribute
        where attrelid = 'public.entry_lines'::regclass and attname = 'declared_on'`,
    );
    expect(column.required).toBe(true);
  });

  it('puts back every guard it lifted, and dates no line as edited', async () => {
    const off = await rows(db, `select tgrelid::regclass::text as tbl, tgname from pg_trigger where tgenabled <> 'O'`);
    expect(off).toEqual([]);
    const touchedAfter = (
      await one<{ h: string }>(db, `select md5(string_agg(id::text || updated_at::text, ',' order by id)) as h from entry_lines`)
    ).h;
    expect(touchedAfter).toBe(touchedBefore);
  });

  it('lifts the posted-line guard by its name, in the file of the backfill alone', async () => {
    for (const file of MIGRATIONS) {
      const sql = await readFile(join(repoRoot, 'supabase', 'migrations', file), 'utf8');
      const lifted = /disable trigger entry_lines_guard_posted;/.test(sql);
      expect(lifted, file).toBe(file === MIGRATIONS[1]);
    }
    // Lifted by name, and only by name: no blanket switch in the backfill.
    const backfill = await readFile(join(repoRoot, 'supabase', 'migrations', MIGRATIONS[1] as string), 'utf8');
    expect(backfill).not.toMatch(/disable trigger (all|user)\b/);
  });
});

// ---------------------------------------------------------------------------
// Written by the engine, never by hand
// ---------------------------------------------------------------------------

describe('the day a line counts, as the engine writes it', () => {
  // A pack whose golden year settles a tax that falls due on collection: the
  // one case where the tax point of a line is not the day of its document.
  const pack: Pack = packWhere(
    'books a tax due on collection in its golden year',
    (p) =>
      p.golden !== null &&
      p.taxes.some(
        (t) => t.cash_basis && (p.golden as PackGolden).documents.some((d) => d.lines.some((l) => l.tax === t.code)),
      ),
  );
  const golden = pack.golden as PackGolden;
  let db: PGlite;
  let companyId: string;

  beforeAll(async () => {
    db = await freshDatabase();
    ({ companyId } = await newCompany(db, {
      country: pack.manifest.country,
      name: golden.name,
      chart: golden.chart,
      language: golden.language,
      fiscalYear: golden.fiscalYear,
    }));
    await replayScenario(db, companyId, golden);
  }, 300_000);

  afterAll(async () => {
    await db?.close();
  });

  it('is the rule on every line the engine wrote', async () => {
    expect(await offTheRule(db, companyId)).toBe(0);
    const boxed = await one<{ n: number; dated: number }>(
      db,
      `select count(*)::int as n, count(declared_on)::int as dated
         from entry_lines where company_id = $1 and declaration_box is not null`,
      [companyId],
    );
    expect(boxed.n).toBeGreaterThan(0);
    expect(boxed.dated).toBe(boxed.n);
  });

  it('follows the tax point a cash-basis settlement writes, day for day', async () => {
    // The transfers `settle_cash_basis_tax()` posts when a document is paid:
    // a later entry of the same document, whose lines carry the day of the
    // payment as their tax point.
    const transfers = await rows<{ tax_point: string; declared: string; entry_date: string; invoiced: string }>(
      db,
      `select l.tax_point_date::text as tax_point, l.declared_on::text as declared,
              e.entry_date::text as entry_date, o.entry_date::text as invoiced
         from entry_lines l
         join entries e on e.id = l.entry_id
         join documents d on d.id = e.document_id and d.entry_id <> e.id
         join entries o on o.id = d.entry_id
         join taxes t on t.id = l.tax_id
        where l.company_id = $1 and t.cash_basis`,
      [companyId],
    );
    expect(transfers.length, `${pack.slug} settles no tax due on collection`).toBeGreaterThan(0);
    for (const line of transfers) {
      expect(line.tax_point).toBe(line.entry_date);
      expect(line.declared).toBe(line.tax_point);
    }
    // And the move is visible: a settlement on another day than the invoice
    // counts on the day of the settlement.
    expect(transfers.some((t) => t.declared !== t.invoiced)).toBe(true);

    // Undone, the matching posts its mirror on the day it is undone, and the
    // mirror counts on that day too.
    const matching = await one<{ id: string }>(
      db,
      `select r.id from reconciliations r
         join entry_lines l on l.id = r.debit_line_id or l.id = r.credit_line_id
         join entries e on e.id = l.entry_id
         join documents d on d.entry_id = e.id
         join entry_lines w on w.entry_id = d.entry_id
         join taxes t on t.id = w.tax_id and t.cash_basis
        where r.company_id = $1
        limit 1`,
      [companyId],
    );
    await db.query(`select unreconcile($1)`, [matching.id]);
    expect(await offTheRule(db, companyId)).toBe(0);
  });

  it('replaces a day written by hand, and follows the date of a draft', async () => {
    const accounts = await rows<{ id: string }>(
      db,
      `select id from accounts where company_id = $1 and not reconcilable order by code limit 2`,
      [companyId],
    );
    const entry = await one<{ id: string }>(
      db,
      `insert into entries (company_id, journal_id, fiscal_year_id, entry_date, state, currency_code)
       select c.id, c.miscellaneous_journal_id, fiscal_year_at(c.id, $2::date), $2::date, 'draft', c.currency_code
         from companies c where c.id = $1
       returning id`,
      [companyId, golden.fiscalYear.start],
    );
    const line = await one<{ id: string; declared: string }>(
      db,
      `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit,
                                declaration_box, box_amount, declared_on)
       values ($1, $2, $3, 10, 'by hand', 100, 0, 'X', 100, '1999-12-31')
       returning id, declared_on::text as declared`,
      [entry.id, companyId, accounts[0]?.id],
    );
    expect(line.declared).toBe(golden.fiscalYear.start);

    const declared = async (): Promise<string> =>
      (await one<{ d: string }>(db, `select declared_on::text as d from entry_lines where id = $1`, [line.id])).d;

    await db.query(`update entry_lines set declared_on = '1999-12-31' where id = $1`, [line.id]);
    expect(await declared()).toBe(golden.fiscalYear.start);

    await db.query(`update entries set entry_date = $2::date where id = $1`, [entry.id, golden.fiscalYear.end]);
    expect(await declared()).toBe(golden.fiscalYear.end);

    await db.query(`update entry_lines set tax_point_date = $2::date where id = $1`, [line.id, golden.fiscalYear.start]);
    expect(await declared()).toBe(golden.fiscalYear.start);

    await db.query(`update entry_lines set tax_point_date = null where id = $1`, [line.id]);
    expect(await declared()).toBe(golden.fiscalYear.end);
    await db.query(`delete from entries where id = $1`, [entry.id]);

    // On a posted line the guard of a posted entry answers first, by name.
    const posted = await one<{ id: string }>(
      db,
      `select l.id from entry_lines l join entries e on e.id = l.entry_id
        where l.company_id = $1 and e.state = 'posted' and l.declaration_box is not null limit 1`,
      [companyId],
    );
    expect(await expectError(db, `update entry_lines set declared_on = '1999-12-31' where id = $1`, [posted.id])).toContain(
      'entry_posted',
    );
  });

  it('reads one predicate in every function that asks which lines a period holds', async () => {
    const bodies = await rows<{ name: string; body: string }>(
      db,
      `select p.proname as name, p.prosrc as body from pg_proc p
         join pg_namespace n on n.oid = p.pronamespace
        where n.nspname = 'public' and p.prosrc ~* 'declared_lines\\(|tax_point_date'`,
    );
    const readers = bodies.filter((b) => b.body.includes('declared_lines(')).map((b) => b.name).sort();
    expect(readers).toEqual(['filing_tax_movements', 'filings_touched_since', 'vat_return']);
    // Nobody works the period out again from the two columns.
    const again = bodies.filter((b) => /coalesce\(\s*\w+\.tax_point_date\s*,\s*\w+\.entry_date\s*\)\s*between/i.test(b.body));
    expect(again.map((b) => b.name)).toEqual([]);
  });
});

// ---------------------------------------------------------------------------
// In the company archive
// ---------------------------------------------------------------------------

describe('the day a line counts, in the company archive', () => {
  const pack: Pack = packWhere('carries a golden year and a form', (p) => p.golden !== null && p.report !== null);
  const golden = pack.golden as PackGolden;
  let a: PGlite;
  let b: PGlite;
  let adminOfB: string;
  let ownerId: string;
  let companyId: string;
  let text: string;

  beforeAll(async () => {
    a = await freshDatabase();
    b = await freshDatabase();
    adminOfB = await newInstanceAdmin(b);
    ({ companyId, ownerId } = await newCompany(a, {
      country: pack.manifest.country,
      name: `${golden.name} — archived`,
      chart: golden.chart,
      language: golden.language,
      fiscalYear: golden.fiscalYear,
    }));
    await replayScenario(a, companyId, golden);
    text = await exportAs(a, ownerId, companyId);
  }, 300_000);

  afterAll(async () => {
    await a?.close();
    await b?.close();
  });

  const entryLines = (archive: Archive): Record<string, unknown>[] => archive.tables['public.entry_lines'] ?? [];
  const checksum = (archive: Archive): string | undefined =>
    archive.manifest.tables.find((t) => t.name === 'public.entry_lines')?.values_sha256;

  it('carries declared_on on every ledger line', () => {
    const lines = entryLines(JSON.parse(text) as Archive);
    expect(lines.length).toBeGreaterThan(0);
    for (const line of lines) expect(line['declared_on']).toMatch(/^\d{4}-\d{2}-\d{2}$/);
  });

  it('refuses an archive whose day is not the one the rule gives', async () => {
    const archive = JSON.parse(text) as Archive;
    const boxed = entryLines(archive).find((l) => l['declaration_box'] !== null) as Record<string, unknown>;
    boxed['declared_on'] = '1999-12-31';
    for (const table of Object.keys(archive.tables)) await reseal(b, archive, table);
    const message = await expectError(b, `select import_company($1::jsonb)`, [JSON.stringify(archive)]);
    expect(message).toContain('declared_on_mismatch');
    expect((await one<{ n: number }>(b, `select count(*)::int as n from companies where id = $1`, [companyId])).n).toBe(0);
  });

  it('derives it for an archive written before it existed, and leaves again identical', async () => {
    const archive = JSON.parse(text) as Archive;
    const original = checksum(archive);
    for (const line of entryLines(archive)) delete line['declared_on'];
    for (const table of Object.keys(archive.tables)) await reseal(b, archive, table);
    expect(checksum(archive)).not.toBe(original);

    const ownerInB = await newUser(b);
    await importAs(b, adminOfB, JSON.stringify(archive), ownerInB);
    expect(await offTheRule(b, companyId)).toBe(0);

    // What B exports is what A exported, ledger lines included, to the
    // checksum of their values.
    const back = JSON.parse(await exportAs(b, ownerInB, companyId)) as Archive;
    expect(checksum(back)).toBe(original);
    const resealed = JSON.parse(text) as Archive;
    await reseal(b, resealed, 'public.entry_lines');
    expect(checksum(resealed)).toBe(original);
  });
});
