/**
 * The books at volume: what the plans look like when there is something to plan.
 *
 * Every other test of this repository books a handful of documents — the
 * largest golden scenario holds fifteen — and Postgres plans fifteen rows the
 * same way whatever the indexes are. The schema declares 173 of them and two
 * guards in `schema.test.ts` refuse a foreign key or a `company_id` without
 * one; neither says an index is *used*. This file loads an instance, reads
 * the plan of the six reads a set of books is judged on, and breaks the build
 * when one of them walks a large table from end to end.
 *
 * ---------------------------------------------------------------------------
 * What is asserted, and what is only reported.
 *
 * **Asserted: the shape of the plan.** No sequential scan of a large table
 * inside a hot path; a policy that asks who the caller is a bounded number of
 * times, not once per row; a declaration that reads the period it was asked
 * for and not the history of the company. All three are properties of the
 * plan and of the data, both of which are deterministic here.
 *
 * **Reported: the time.** A time measured on a shared runner, on Postgres
 * compiled to WebAssembly, is noise with a trend in it. It goes into the
 * report — next to the budget of the path, so a reader sees the distance —
 * and into no `expect()`. The times that mean something are taken on a real
 * Postgres by `scripts/e2e-supabase.mjs`, from the same definitions.
 *
 * The assertions are written as "this does not appear" rather than "this
 * index is used": which of two good indexes the planner prefers depends on
 * statistics and cost settings, and is its business. That it never prefers
 * reading everything is ours.
 *
 * ---------------------------------------------------------------------------
 * The instance.
 *
 * Several companies, because a plan is only a question when the predicate is
 * selective: in an instance of one company, `company_id = $1` keeps every
 * row, and a sequential scan of `entry_lines` is then the *right* plan for a
 * trial balance. The company under test holds `EKWO_LOAD_DOCUMENTS` documents
 * spread over five financial years, and each of the others as many.
 *
 * Every company is installed from a pack and books that pack's golden year
 * through `post_document()`, `post_payment()` and `reconcile()`; the volume
 * is that year copied, which `scripts/load/books.mjs` explains and defends.
 * The pack is a parameter — `EKWO_LOAD_PACK`, a slug — and no country is
 * named here: left out, it is the first pack that carries a golden scenario.
 *
 *   EKWO_LOAD_DOCUMENTS   documents per company. 10 000 when left out, which
 *                         is what the CI runs. 100 000 is for a workstation:
 *                         see `docs/load.md` for what it needs
 *   EKWO_LOAD_COMPANIES   companies in the instance, the one under test
 *                         included. 5 when left out
 *   EKWO_LOAD_PACK        slug of the pack every company is installed from
 *   EKWO_LOAD_REPORT      a path: the report is written there as JSON, in the
 *                         format `docs/load.md` documents, besides being
 *                         printed
 */

import { writeFile } from 'node:fs/promises';
import type { PGlite } from '@electric-sql/pglite';
import { auto_explain } from '@electric-sql/pglite/contrib/auto_explain';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { Pack, PackGolden } from '../../packages/cli/src/index.js';
import type { SqlClient } from '../../packages/cli/src/sql.js';
import {
  COPIED_TABLES,
  NOT_COPIED_TABLES,
  bankStatementMonth,
  checkCoherence,
  fingerprint,
  multiplyBooks,
} from '../../scripts/load/books.mjs';
import {
  LARGE_TABLES,
  RECORD_PLANS,
  STOP_RECORDING,
  accessOf,
  hotPaths,
  largeSequentialScans,
  planRecorder,
  rowsReadOf,
  type HotPath,
  type RecordedPlan,
} from '../../scripts/load/hot-paths.mjs';
import { adapt, type Queryable } from '../cli/helpers.js';
import { asUser, freshDatabase, one, rows } from '../helpers/db.js';
import { newCompany } from '../helpers/factory.js';
import { replayScenario } from '../helpers/golden-scenario.js';
import { allPacks, packWhere } from '../helpers/packs.js';

const DOCUMENTS = Number(process.env['EKWO_LOAD_DOCUMENTS'] ?? 10_000);
const COMPANIES = Number(process.env['EKWO_LOAD_COMPANIES'] ?? 5);
const YEARS = 5;
const CONTACTS = 500;
const SEED = 41;

/**
 * How many times a hot path may ask `has_capability()`, as a member.
 *
 * Not a tuned figure: what it separates is "once per table the statement
 * reads" — a dozen or two — from "once per row", which is tens of thousands
 * at this volume. Anything in between is a path that grew a loop.
 */
const CAPABILITY_CHECKS_AT_MOST = 100;

function chosenPack(): Pack {
  const slug = process.env['EKWO_LOAD_PACK'];
  if (slug === undefined || slug === '') {
    return packWhere('carries a golden scenario', (pack) => pack.golden !== null);
  }
  const pack = allPacks.find((p) => p.slug === slug);
  if (pack === undefined) throw new Error(`EKWO_LOAD_PACK=${slug} is not a pack of this repository`);
  if (pack.golden === null) throw new Error(`packs/${slug} carries no golden scenario to book`);
  return pack;
}

const pack = chosenPack();
const golden = pack.golden as PackGolden;

/** A company of the pack with its golden year booked by the engine. */
async function bookedCompany(pg: PGlite, name: string): Promise<{ companyId: string; ownerId: string }> {
  const company = await newCompany(pg, {
    country: pack.manifest.country,
    name,
    chart: golden.chart,
    language: golden.language,
    fiscalYear: golden.fiscalYear,
  });
  await replayScenario(pg, company.companyId, golden);
  return company;
}

async function tableCounts(pg: PGlite): Promise<Map<string, number>> {
  const tables = await rows<{ name: string }>(
    pg,
    `select c.relname as name from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relkind = 'r' order by 1`,
  );
  const counts = new Map<string, number>();
  for (const { name } of tables) {
    counts.set(name, (await one<{ n: number }>(pg, `select count(*)::int as n from "${name}"`)).n);
  }
  return counts;
}

interface Measured {
  path: HotPath;
  as: 'owner' | 'member';
  rows: number;
  ms: number;
  plans: RecordedPlan[];
  statements: number;
  capabilityChecks: number;
}

describe(`${DOCUMENTS} documents in each of ${COMPANIES} companies — packs/${pack.slug}`, () => {
  let pg: PGlite;
  let db: SqlClient;
  let companyId: string;
  let ownerId: string;
  let paths: HotPath[];
  let wroteTo: string[] = [];
  const generation: Record<string, number> = {};
  const measured: Measured[] = [];
  const started = performance.now();

  beforeAll(async () => {
    pg = await freshDatabase({ extensions: { auto_explain } });
    db = adapt(pg as unknown as Queryable, pg);
    // Loaded once, as the owner of the database: the settings of the module
    // are the superuser's to change, and they hold across `set role`.
    await pg.exec(`load 'auto_explain';`);

    let at = performance.now();
    // Installing a company writes the pack; booking its year writes the
    // books. Only the second is watched, so the two are done apart here.
    const subject = await newCompany(pg, {
      country: pack.manifest.country,
      name: 'Company under test',
      chart: golden.chart,
      language: golden.language,
      fiscalYear: golden.fiscalYear,
    });
    const before = await tableCounts(pg);
    await replayScenario(pg, subject.companyId, golden);
    const after = await tableCounts(pg);
    wroteTo = [...after.keys()].filter((t) => after.get(t) !== before.get(t));
    companyId = subject.companyId;
    ownerId = subject.ownerId;
    generation['template_ms'] = Math.round(performance.now() - at);

    at = performance.now();
    await multiplyBooks(db, { companyId, documents: DOCUMENTS, years: YEARS, contacts: CONTACTS, seed: SEED });
    for (let i = 1; i < COMPANIES; i += 1) {
      const other = await bookedCompany(pg, `Other company ${i}`);
      await multiplyBooks(db, {
        companyId: other.companyId,
        documents: DOCUMENTS,
        years: YEARS,
        contacts: CONTACTS,
        seed: SEED + i,
      });
    }
    // A month of statement at the rhythm of the books: a twelfth of a year.
    const lines = Math.max(10, Math.round(DOCUMENTS / YEARS / 12));
    const statement = await bankStatementMonth(db, { companyId, lines, seed: SEED });
    generation['multiply_ms'] = Math.round(performance.now() - at);

    // Without statistics the planner assumes a table it has never looked at,
    // and every plan read below would be the plan of that assumption.
    at = performance.now();
    await pg.exec('analyze;');
    generation['analyze_ms'] = Math.round(performance.now() - at);

    // The ledger asked for is the busiest account of the company: the worst
    // case of "one account", and the same one on every run.
    const account = await one<{ account_id: string }>(
      pg,
      `select l.account_id from entry_lines l join accounts a on a.id = l.account_id
        where l.company_id = $1 group by l.account_id, a.code
        order by count(*) desc, a.code limit 1`,
      [companyId],
    );
    const period = golden.periods[0];
    if (period === undefined) throw new Error(`packs/${pack.slug} declares no period in its golden`);
    paths = hotPaths({
      companyId,
      yearFrom: golden.fiscalYear.start,
      yearTo: golden.fiscalYear.end,
      periodFrom: period.from,
      periodTo: period.to,
      accountId: account.account_id,
      statementId: statement.statementId,
    });

    for (const who of ['owner', 'member'] as const) {
      const acting = <T>(fn: () => Promise<T>): Promise<T> =>
        who === 'owner' ? fn() : asUser(pg, ownerId, fn);
      for (const path of paths) {
        // Timed without the recording, three times, and the median kept: the
        // first run pays for the plan cache and `auto_explain` is not free.
        const times: number[] = [];
        let answer = 0;
        for (let run = 0; run < 3; run += 1) {
          const t0 = performance.now();
          const result = await acting(() => pg.query<{ rows: number }>(path.sql, path.params));
          times.push(performance.now() - t0);
          answer = result.rows[0]?.rows ?? 0;
        }
        times.sort((a, b) => a - b);

        const recorder = planRecorder();
        await pg.exec(RECORD_PLANS);
        try {
          await acting(() =>
            pg.query(path.planSql ?? path.sql, path.params, { onNotice: recorder.onNotice }),
          );
        } finally {
          await pg.exec(STOP_RECORDING);
        }
        measured.push({
          path,
          as: who,
          rows: answer,
          ms: Math.round(times[1] as number),
          plans: recorder.plans,
          statements: recorder.counts.statements,
          capabilityChecks: recorder.counts.capabilityChecks,
        });
      }
    }
  }, 600_000);

  afterAll(async () => {
    const volume = await one<Record<string, number>>(
      pg,
      `select ${LARGE_TABLES.map((t) => `(select count(*)::int from ${t}) as ${t}`).join(', ')},
              (select count(*)::int from contacts) as contacts`,
    );
    const report = {
      format: 'ekwo-load-report/1',
      engine: (await one<{ v: string }>(pg, `select version() as v`)).v,
      pack: pack.slug,
      documents_per_company: DOCUMENTS,
      companies: COMPANIES,
      years: YEARS,
      seed: SEED,
      rows: volume,
      generation_ms: generation,
      total_ms: Math.round(performance.now() - started),
      paths: measured.map((m) => ({
        key: m.path.key,
        name: m.path.name,
        as: m.as,
        rows_returned: m.rows,
        ms: m.ms,
        budget_ms: m.path.budgetMs,
        within_budget: m.ms <= m.path.budgetMs,
        large_table_rows_read: rowsReadOf(m.plans),
        capability_checks: m.capabilityChecks,
        access: accessOf(m.plans),
      })),
    };
    const target = process.env['EKWO_LOAD_REPORT'];
    if (target !== undefined && target !== '') await writeFile(target, `${JSON.stringify(report, null, 2)}\n`);

    const width = Math.max(...report.paths.map((p) => p.key.length));
    const lines = report.paths.map(
      (p) =>
        `${p.as.padEnd(6)} ${p.key.padEnd(width)} ${String(p.ms).padStart(6)} ms / ${String(p.budget_ms).padStart(5)}` +
        `  read ${String(p.large_table_rows_read).padStart(8)}  asked ${String(p.capability_checks).padStart(6)}  ${p.access.join('; ')}`,
    );
    process.stdout.write(
      `\nload report — packs/${pack.slug}, ${COMPANIES} × ${DOCUMENTS} documents, ` +
        `${volume['entry_lines']} ledger lines, ${report.total_ms} ms in all\n${lines.join('\n')}\n`,
    );
    await pg.close();
  });

  it('knows every table a year of bookkeeping writes to', () => {
    // The generator copies a list of tables. The day the engine starts
    // writing a new one, the copies would silently lack it — so the replay is
    // watched, and a table nobody classified fails here by name.
    const known = new Set([...COPIED_TABLES, ...NOT_COPIED_TABLES]);
    expect(wroteTo.filter((table) => !known.has(table))).toEqual([]);
  });

  it('copies books that the foreign keys and the triggers would have accepted', async () => {
    expect(await checkCoherence(db, companyId)).toEqual([]);
    const count = await one<{ documents: number; posted: number }>(
      pg,
      `select count(*)::int as documents,
              count(*) filter (where entry_id is not null)::int as posted
         from documents where company_id = $1`,
      [companyId],
    );
    expect(count.documents).toBeGreaterThanOrEqual(DOCUMENTS);
    expect(count.posted).toBe(count.documents);
  });

  it('balances, year by year, like the template it was copied from', async () => {
    const years = await rows<{ debit: string; credit: string }>(
      pg,
      `select sum(l.debit)::text as debit, sum(l.credit)::text as credit
         from entry_lines l join entries e on e.id = l.entry_id
        where l.company_id = $1 group by e.fiscal_year_id`,
      [companyId],
    );
    expect(years).toHaveLength(YEARS);
    for (const year of years) expect(year.debit).toBe(year.credit);
  });

  it('read statistics before it read a plan', async () => {
    // `pg_stats` has a row per analysed column. A table without one has never
    // been analysed, and its plans are guesses.
    const analysed = await rows<{ tablename: string }>(
      pg,
      `select distinct tablename::text from pg_stats
        where schemaname = 'public' and tablename = any ($1::text[])`,
      [LARGE_TABLES],
    );
    const populated: string[] = [];
    for (const table of LARGE_TABLES) {
      if ((await one<{ n: number }>(pg, `select count(*)::int as n from ${table}`)).n > 0) populated.push(table);
    }
    expect(analysed.map((r) => r.tablename).sort()).toEqual(expect.arrayContaining(populated.sort()));
    const estimate = await one<{ reltuples: number; n: number }>(
      pg,
      `select c.reltuples::float8 as reltuples, (select count(*)::int from entry_lines) as n
         from pg_class c where c.oid = 'public.entry_lines'::regclass`,
    );
    expect(Math.abs(estimate.reltuples - estimate.n) / estimate.n).toBeLessThan(0.1);
  });

  it('recorded a plan for every path, as the owner and as a member', () => {
    expect(measured).toHaveLength(12);
    for (const m of measured) {
      expect(m.plans.length, `${m.path.key} as ${m.as} recorded no plan on a large table`).toBeGreaterThan(0);
    }
  });

  it('never walks a large table from end to end inside a hot path', () => {
    const found = measured.flatMap((m) =>
      largeSequentialScans(m.plans).map(
        (scan) =>
          `${m.path.key} as ${m.as}: Seq Scan on ${scan.table}, ${scan.rows} rows kept and ${scan.removed} thrown away, in: ${scan.query}`,
      ),
    );
    expect(found).toEqual([]);
  });

  it('gives a member the answer it gives the owner', () => {
    for (const path of paths) {
      const [owner, member] = ['owner', 'member'].map((who) =>
        measured.find((m) => m.path.key === path.key && m.as === who),
      );
      expect(member?.rows, path.key).toBe(owner?.rows);
      expect(owner?.rows, `${path.key} returned nothing, so its plan proves nothing`).toBeGreaterThan(0);
    }
  });

  it('asks who the caller is a bounded number of times, not once per row', () => {
    const asked = measured
      .filter((m) => m.as === 'member')
      .map((m) => ({ path: m.path.key, checks: m.capabilityChecks }));
    // A member is judged at all — a path that asked nothing ran as somebody
    // row level security does not apply to, and measured nothing.
    for (const a of asked) expect(a.checks, a.path).toBeGreaterThan(0);
    expect(asked.filter((a) => a.checks > CAPABILITY_CHECKS_AT_MOST)).toEqual([]);
  });

  it('still books a document through the engine, into books of this size', async () => {
    // A sale of the latest year — the copies of earlier years carry taxes at
    // dates the pack may not have them in force — booked again, as new.
    const template = await one<{ id: string; contact_id: string }>(
      pg,
      `select d.id, d.contact_id from documents d
        where d.company_id = $1 and d.doc_type = 'sale_invoice' and d.document_date >= $2::date
        order by d.document_date, d.number limit 1`,
      [companyId, golden.fiscalYear.start],
    );
    const contact = { id: template.contact_id };
    const t0 = performance.now();
    const created = await one<{ id: string }>(
      pg,
      `insert into documents (company_id, doc_type, contact_id, document_date)
       select company_id, doc_type, $2, document_date from documents where id = $1 returning id`,
      [template.id, contact.id],
    );
    await pg.query(
      `insert into document_lines (document_id, company_id, sequence, name, quantity, unit_price,
                                   discount_percent, tax_id, account_id)
       select $2, company_id, sequence, name, quantity, unit_price, discount_percent, tax_id, account_id
         from document_lines where document_id = $1`,
      [template.id, created.id],
    );
    await pg.query(`select post_document($1)`, [created.id]);
    generation['post_one_document_ms'] = Math.round(performance.now() - t0);
    const posted = await one<{ state: string; balanced: boolean }>(
      pg,
      `select d.state::text as state, e.is_balanced as balanced
         from documents d join entries e on e.id = d.entry_id where d.id = $1`,
      [created.id],
    );
    expect(posted.balanced).toBe(true);
  });
});

describe('the generator is deterministic', () => {
  it('gives the same books for the same seed, and other books for another', async () => {
    // Two databases, because "the same seed gives the same books" is a claim
    // about two runs and not about two companies of one.
    const books = async (seeds: number[]): Promise<string[]> => {
      const pg = await freshDatabase();
      try {
        const db = adapt(pg as unknown as Queryable, pg);
        const prints: string[] = [];
        for (const seed of seeds) {
          const { companyId } = await bookedCompany(pg, `Seeded ${seed}`);
          await multiplyBooks(db, { companyId, documents: 300, years: 3, contacts: 40, seed });
          prints.push(await fingerprint(db, companyId));
        }
        return prints;
      } finally {
        await pg.close();
      }
    };
    const [first, other] = await books([7, 8]);
    const [second] = await books([7]);
    expect(second).toBe(first);
    expect(other).not.toBe(first);
  });
});
