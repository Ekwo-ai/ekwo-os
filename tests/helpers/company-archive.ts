/**
 * What the tests about a company leaving an installation share: the furniture
 * a company is given before it leaves, and the two ends of the journey.
 *
 * Two files use it — `tests/company_archive.test.ts`, which is the journey, and
 * `tests/company_archive_refusals.test.ts`, which is every archive that lies.
 * They are two files because each runs in a worker of its own: PGlite answers
 * on the thread that asked, a long file leaves the runner's own messages
 * waiting, and the continuous integration runner is a third of the speed of a
 * laptop.
 */

import type { PGlite } from '@electric-sql/pglite';
import type { Pack, PackGolden } from '../../packages/cli/src/index.js';
import { asUser, one, rows } from './db.js';
import { newCompany, newUser } from './factory.js';
import { replayScenario, type Replayed } from './golden-scenario.js';
import { allPacks, monthsOf } from './packs.js';

/** Lets the runner's timers and messages through between two long stretches of database work. */
export const breathe = (): Promise<void> => new Promise((resolve) => setImmediate(resolve));

/** The packs with a year of books and a form to file it on. */
export const filers = allPacks.filter((pack) => pack.report !== null && pack.golden !== null);

/** Written on everything the company that stays owns a name for. */
export const STAYS = 'ZZSTAYS';

export const UUID = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/g;

export interface Manifest {
  format: string;
  format_version: number;
  socle_version: string;
  company: { id: string; name: string };
  packs: { country: string; version: string }[];
  modules: { code: string; version: string }[];
  tables: { name: string; file: string; rows: number; sha256: string }[];
  excluded: { name: string; reason: string }[];
  files: { transported: boolean; list: { storage_path: string; checksum: string | null }[] };
}

export interface Archive {
  manifest: Manifest;
  tables: Record<string, Record<string, unknown>[]>;
}

export interface Furnished {
  companyId: string;
  ownerId: string;
  replayed: Replayed;
  filingId: string;
  draftFilingId: string;
  period: { from: string; to: string };
  lockDate: string;
  closedYearId: string;
}

export const iso = (date: Date): string => date.toISOString().slice(0, 10);
export const day = (text: string): Date => new Date(`${text}T00:00:00Z`);

/**
 * The period of the pack's own cadence that books the most, among those that
 * end before the year does — so that there is a day left, after the lock, to
 * post the document that proves the numbering.
 */
export function filedPeriod(pack: Pack): { from: string; to: string } {
  const golden = pack.golden as PackGolden;
  const cadence = pack.report?.period_default ?? 'month';
  const span = monthsOf(cadence);
  const start = day(golden.fiscalYear.start);
  const counts = new Map<number, number>();
  for (const document of golden.documents) {
    const at = day(document.date);
    const months =
      (at.getUTCFullYear() - start.getUTCFullYear()) * 12 + (at.getUTCMonth() - start.getUTCMonth());
    if (months < 0) continue;
    const index = Math.floor(months / span);
    counts.set(index, (counts.get(index) ?? 0) + 1);
  }
  const ranked = [...counts.entries()].sort((x, y) => y[1] - x[1] || x[0] - y[0]);
  const bounds = (index: number): { from: string; to: string } => {
    const from = new Date(Date.UTC(start.getUTCFullYear(), start.getUTCMonth() + index * span, 1));
    const to = new Date(Date.UTC(from.getUTCFullYear(), from.getUTCMonth() + span, 0));
    return { from: iso(from), to: iso(to) };
  };
  const early = ranked.find(([index]) => bounds(index).to < golden.fiscalYear.end);
  return bounds((early ?? ranked[0] ?? [0])[0]);
}

/**
 * A year of books and everything around it: a bank and a statement, a product,
 * an analytic split, a learned counterparty, a budget, pieces, a declaration
 * that went with its proof, a draft of the next one, a closed year and a lock.
 */
export async function furnish(db: PGlite, pack: Pack, name: string, tag: string): Promise<Furnished> {
  await breathe();
  const golden = pack.golden as PackGolden;
  const ownerId = await newUser(db);
  // country-literal: every filing pack of the checkout is walked, each on its
  // own companies, and the country is the pack's own.
  const { companyId } = await newCompany(db, {
    country: pack.manifest.country,
    name,
    ownerId,
    chart: golden.chart,
    language: golden.language,
    fiscalYear: golden.fiscalYear,
  });
  const replayed = await replayScenario(db, companyId, golden);
  await db.query(`update contacts set notes = $2 where company_id = $1`, [companyId, tag]);

  // The bank, a statement and two lines of it.
  const journal = await one<{ id: string; default_account_id: string | null }>(
    db,
    `select id, default_account_id from journals
      where company_id = $1 and journal_type = 'bank' order by code limit 1`,
    [companyId],
  );
  const bank = await one<{ id: string }>(
    db,
    `insert into bank_accounts (company_id, name, iban, account_id, journal_id)
     values ($1, $2, 'XX00 0000 0000 0000', $3, $4) returning id`,
    [companyId, `Current account ${tag}`, journal.default_account_id, journal.id],
  );
  await db.query(`update companies set default_bank_account_id = $2 where id = $1`, [companyId, bank.id]);
  const statement = await one<{ id: string }>(
    db,
    `insert into bank_statements (company_id, bank_account_id, name, statement_date,
                                  balance_start, balance_end_declared)
     values ($1, $2, $3, $4::date, 0, 150.25) returning id`,
    [companyId, bank.id, `Statement ${tag}`, golden.fiscalYear.end],
  );
  await db.query(
    `insert into bank_transactions (company_id, statement_id, bank_account_id, sequence,
                                    transaction_date, amount, description, raw)
     values ($1, $2, $3, 1, $4::date, 200.50, $5, '{"fee": 1.50}'::jsonb),
            ($1, $2, $3, 2, $4::date, -50.25, $5, null)`,
    [companyId, statement.id, bank.id, golden.fiscalYear.end, `Line ${tag}`],
  );
  // A second statement that overlaps the first: it lists the second line
  // instead of storing it again, and proves its closing balance over the list.
  const overlap = await one<{ id: string }>(
    db,
    `insert into bank_statements (company_id, bank_account_id, name, statement_date,
                                  balance_start, balance_end_declared)
     values ($1, $2, $3, $4::date, 200.50, 150.25) returning id`,
    [companyId, bank.id, `Overlap ${tag}`, golden.fiscalYear.end],
  );
  await db.query(
    `insert into bank_statement_lines (company_id, statement_id, transaction_id, position)
     select $1, $2, t.id, 1 from bank_transactions t
      where t.company_id = $1 and t.statement_id = $3 and t.sequence = 2`,
    [companyId, overlap.id, statement.id],
  );

  // A product, an analytic split, a learned counterparty, settings of its own.
  await db.query(
    `insert into products (company_id, code, name, sale_price) values ($1, 'P-1', $2, 12.345678)`,
    [companyId, `Product ${tag}`],
  );
  const axis = await one<{ id: string }>(
    db,
    `insert into analytic_axes (company_id, code, name) values ($1, 'AX', $2) returning id`,
    [companyId, `Axis ${tag}`],
  );
  const value = await one<{ id: string }>(
    db,
    `insert into analytic_values (company_id, axis_id, code, name) values ($1, $2, 'V1', $3) returning id`,
    [companyId, axis.id, `Value ${tag}`],
  );
  await db.query(
    `insert into entry_line_analytics (company_id, entry_line_id, analytic_value_id, percentage, amount)
     select $1, l.id, $2, 100, l.debit + l.credit
       from entry_lines l where l.company_id = $1 order by l.created_at, l.id limit 1`,
    [companyId, value.id],
  );
  await db.query(
    `insert into contact_patterns (company_id, contact_id, kind, value, source)
     select $1, c.id, 'name_variation', $2, 'declared'
       from contacts c where c.company_id = $1 order by c.name limit 1`,
    [companyId, `Variation ${tag}`],
  );
  await db.query(`insert into matching_settings (company_id, date_window_days) values ($1, 9)`, [companyId]);

  // A module with rows of its own.
  await asUser(db, ownerId, async () => {
    await db.query(`select enable_module($1, 'budgets')`, [companyId]);
  });
  const budget = await one<{ id: string }>(
    db,
    `insert into budgets.budgets (company_id, fiscal_year_id, code, name)
     values ($1, (select id from fiscal_years where company_id = $1 limit 1), 'B1', $2) returning id`,
    [companyId, `Budget ${tag}`],
  );
  await db.query(
    `insert into budgets.lines (budget_id, company_id, account_id, period_start, period_end, amount)
     select $1, $2, l.account_id, $3::date, $4::date, 1234.56
       from entry_lines l where l.company_id = $2 order by l.created_at, l.id limit 1`,
    [budget.id, companyId, golden.fiscalYear.start, golden.fiscalYear.end],
  );

  // A second module: a fixed asset on the register with the first line of its
  // schedule. Written by hand — what a country says about depreciation is not
  // the subject, that the rows travel is.
  await asUser(db, ownerId, async () => {
    await db.query(`select enable_module($1, 'assets')`, [companyId]);
  });
  const asset = await one<{ id: string }>(
    db,
    `insert into assets.assets (company_id, code, name, acquisition_date, cost, method, duration_months,
                                asset_account_id, depreciation_account_id, expense_account_id)
     select $1, 'A-1', $2, $3::date, 6000, 'straight_line', 60, x.ids[1], x.ids[2], x.ids[3]
       from (select array_agg(id order by code) as ids from accounts where company_id = $1) x
     returning id`,
    [companyId, `Asset ${tag}`, golden.fiscalYear.start],
  );
  await db.query(
    `insert into assets.depreciation_lines (asset_id, company_id, sequence, period_start, period_end,
                                            amount, accumulated, net_book_value)
     values ($1, $2, 1, $3::date, $4::date, 1200, 1200, 4800)`,
    [asset.id, companyId, golden.fiscalYear.start, golden.fiscalYear.end],
  );

  // A piece on a document.
  const someDocument = [...replayed.documents.values()][0] as string;
  await db.query(
    `insert into attachments (company_id, entity_type, entity_id, file_name, mime_type, byte_size,
                              storage_path, checksum, uploaded_by)
     values ($1, 'document', $2, $3, 'application/pdf', 48213, $4, $5, $6)`,
    [companyId, someDocument, `invoice-${tag}.pdf`, `${companyId}/documents/${someDocument}.pdf`,
     'sha256:0f343b0931126a20f133d67c2b018a3b', ownerId],
  );

  // A document that went back to draft, as unpost_document() records it.
  // Written by hand: which country allows it is not the subject, that the
  // record of an entry that no longer exists travels is.
  await db.query(
    `insert into document_unpostings (company_id, document_id, doc_type, entry_id, entry_number,
                                      journal_id, entry_date, number_returned, unposted_by)
     select $1, d.id, d.doc_type, gen_random_uuid(), $3, e.journal_id, e.entry_date, true, $4
       from documents d join entries e on e.id = d.entry_id where d.id = $2`,
    [companyId, someDocument, `UNPOSTED-${tag}`, ownerId],
  );

  // The record of books taken over from another system, as import_books()
  // writes it. Written by hand: what an import posts is `import_books.test.ts`,
  // that its record travels is this.
  await db.query(
    `insert into book_imports (company_id, source, checksum, file_names, entry_count, line_count, created_by)
     values ($1, 'fec', 'sha256:' || encode(sha256(convert_to($2, 'UTF8')), 'hex'), array[$2], 0, 0, $3)`,
    [companyId, `books-${tag}.txt`, ownerId],
  );

  // A declaration that went, with its proof, and the draft of the next one.
  const period = filedPeriod(pack);
  const filing = await one<{ id: string }>(db, `select id from prepare_filing($1, $2::date, $3::date)`, [
    companyId, period.from, period.to,
  ]);
  await asUser(db, ownerId, async () => {
    await db.query(`select file_filing($1, $2)`, [filing.id, `REF-${tag}`]);
  });
  const attach = async (file: string): Promise<string> =>
    (
      await one<{ id: string }>(
        db,
        `insert into attachments (company_id, entity_type, entity_id, file_name, storage_path, byte_size, checksum)
         values ($1, 'tax_filing', $2, $3, $4, 2048, 'sha256:aa11') returning id`,
        [companyId, filing.id, `${file}-${tag}`, `${companyId}/filings/${filing.id}/${file}`],
      )
    ).id;
  await db.query(
    `update tax_filing_deposits set sent_file_id = $2, acknowledgement_id = $3 where filing_id = $1`,
    [filing.id, await attach('declaration.xml'), await attach('acknowledgement.pdf')],
  );
  await db.query(`select record_filing_outcome($1, 'accepted', null, $2)`, [filing.id, `Accepted ${tag}`]);

  const next = day(period.to);
  next.setUTCDate(next.getUTCDate() + 1);
  const nextTo = new Date(Date.UTC(next.getUTCFullYear(), next.getUTCMonth() + 1, 0));
  const draft = await one<{ id: string }>(db, `select id from prepare_filing($1, $2::date, $3::date)`, [
    companyId, iso(next), iso(nextTo),
  ]);

  // The year before, closed. Empty, which is enough to be a closed year: what
  // has to survive the journey is that nobody books in it.
  const before = day(golden.fiscalYear.start);
  const previousEnd = new Date(before.getTime() - 86_400_000);
  const previousStart = new Date(Date.UTC(before.getUTCFullYear() - 1, before.getUTCMonth(), before.getUTCDate()));
  const previous = await one<{ id: string }>(
    db,
    `insert into fiscal_years (company_id, name, start_date, end_date)
     values ($1, 'The year before', $2::date, $3::date) returning id`,
    [companyId, iso(previousStart), iso(previousEnd)],
  );
  await db.query(`select close_fiscal_year($1)`, [previous.id]);

  // The locks, last — the order the work has.
  const lock = period.to < golden.fiscalYear.end ? period.to : iso(new Date(day(period.to).getTime() - 86_400_000));
  await db.query(`update companies set lock_date = $2::date, tax_lock_date = $2::date where id = $1`, [
    companyId, lock,
  ]);

  return {
    companyId, ownerId, replayed, filingId: filing.id, draftFilingId: draft.id,
    period, lockDate: lock, closedYearId: previous.id,
  };
}

export async function exportAs(db: PGlite, userId: string, companyId: string, role = 'authenticated'): Promise<string> {
  await breathe();
  return asUser(
    db,
    userId,
    async () => (await one<{ archive: string }>(db, `select export_company($1)::text as archive`, [companyId])).archive,
    role,
  );
}

export async function importAs(db: PGlite, userId: string, archive: string, owner?: string): Promise<Record<string, unknown>> {
  await breathe();
  return asUser(db, userId, async () =>
    (await one<{ result: Record<string, unknown> }>(db, `select import_company($1::jsonb, $2) as result`, [
      archive, owner ?? null,
    ])).result,
  );
}

/** The figures a company is judged on, as text, so a cent is a cent. */
export async function figures(db: PGlite, reader: string, f: Furnished, golden: PackGolden): Promise<Record<string, unknown>> {
  await breathe();
  return asUser(db, reader, async () => ({
    trialBalance: await rows(
      db,
      `select to_jsonb(t)::text as row from trial_balance($1, $2::date, $3::date) t`,
      [f.companyId, golden.fiscalYear.start, golden.fiscalYear.end],
    ),
    generalLedger: await rows(
      db,
      `select to_jsonb(g)::text as row from general_ledger($1, $2::date, $3::date, null) g`,
      [f.companyId, golden.fiscalYear.start, golden.fiscalYear.end],
    ),
    taxReturn: await rows(
      db,
      `select box, kind, amount::text from vat_return($1, $2::date, $3::date) order by box, kind`,
      [f.companyId, f.period.from, f.period.to],
    ),
    drift: await rows(db, `select to_jsonb(d)::text as row from filing_drift($1) d`, [f.filingId]),
    agedReceivable: await rows(
      db,
      `select to_jsonb(x)::text as row from aged_balance($1, $2::date, 'receivable') x`,
      [f.companyId, golden.fiscalYear.end],
    ),
    agedPayable: await rows(
      db,
      `select to_jsonb(x)::text as row from aged_balance($1, $2::date, 'payable') x`,
      [f.companyId, golden.fiscalYear.end],
    ),
  }));
}

/** The manifest line of a table, recomputed by the database that will read it. */
export async function reseal(db: PGlite, archive: Archive, table: string): Promise<void> {
  const sealed = await one<{ rows: number; sha256: string }>(
    db,
    `select count(*)::int as rows,
            encode(sha256(convert_to(coalesce(string_agg(x.r::text || E'\\n', '' order by x.n), ''), 'UTF8')), 'hex') as sha256
       from jsonb_array_elements($1::jsonb) with ordinality as x(r, n)`,
    [JSON.stringify(archive.tables[table] ?? [])],
  );
  let line = archive.manifest.tables.find((t) => t.name === table);
  if (line === undefined) {
    line = { name: table, file: `data/${table}.jsonl`, rows: 0, sha256: '' };
    archive.manifest.tables.push(line);
  }
  line.rows = sealed.rows;
  line.sha256 = sealed.sha256;
}
