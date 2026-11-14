/**
 * The portfolio readings, as the tools an agent calls.
 *
 * The database side is proved in `tests/filing_portfolio.test.ts`. What is
 * proved here is that the tools add nothing to it and take nothing away: the
 * accountant of two companies is told about two, a company with nothing to say
 * is still named, and somebody with no company is told that, in words, instead
 * of being handed an empty list that reads like good news.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { SCHEMA_FEATURES } from '../../packages/core/src/index.js';
import { readTools } from '../../packages/mcp/src/index.js';
import { freshDatabase } from '../helpers/db.js';
import { newCompany, newUser } from '../helpers/factory.js';
import { packsWhere } from '../helpers/packs.js';
import { backendFor } from './helpers.js';

const filing = packsWhere('files a periodic return', (p) => p.report !== null);

interface UpcomingAnswer {
  companies: number;
  filings: { company_id: string; company_name: string; due_date: string | null; reason: string | null }[];
  note: string;
}

interface TouchedAnswer {
  companies: number;
  touched: number;
  filings: unknown[];
  untouched: { company_id: string; company_name: string; filed: number }[];
  note: string;
}

let db: PGlite;
let accountantId: string;
let strangerId: string;
let kept: string[];
let notKept: string;

beforeAll(async () => {
  db = await freshDatabase();
  accountantId = await newUser(db);
  strangerId = await newUser(db);
  const ids: string[] = [];
  for (const [index, pack] of [filing[0]!, filing[1 % filing.length]!, filing[2 % filing.length]!].entries()) {
    // country-literal: whichever packs file a return, one company on each.
    const { companyId } = await newCompany(db, {
      country: pack.manifest.country,
      name: `Portfolio ${index + 1}`,
    });
    ids.push(companyId);
  }
  kept = ids.slice(0, 2);
  notKept = ids[2]!;
  for (const companyId of kept) {
    await db.query(
      `insert into company_members (company_id, user_id, role) values ($1, $2, 'accountant')`,
      [companyId, accountantId],
    );
  }
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('portfolio_upcoming_filings', () => {
  it('names every company the caller keeps, and no other', async () => {
    const answer = (await readTools.portfolioUpcomingFilings(backendFor(db, accountantId), {
      from: '2026-01-01',
      to: '2026-12-31',
    })) as UpcomingAnswer;
    expect(answer.companies).toBe(2);
    expect([...new Set(answer.filings.map((f) => f.company_id))].sort()).toEqual([...kept].sort());
    expect(answer.filings.map((f) => f.company_id)).not.toContain(notKept);
    // A row is a date or the reason there is none.
    for (const row of answer.filings) {
      expect(row.due_date !== null || row.reason !== null).toBe(true);
    }
    expect(answer.note).toContain('no_deadline_rule');
  });

  it('tells somebody with no company that nothing was read', async () => {
    const answer = (await readTools.portfolioUpcomingFilings(backendFor(db, strangerId), {
      from: '2026-01-01',
      to: '2026-12-31',
    })) as UpcomingAnswer;
    expect(answer.filings).toEqual([]);
    expect(answer.note).toContain('no portfolio');
  });
});

describe('portfolio_filings_touched_since', () => {
  it('names the companies that were looked at when nothing moved', async () => {
    const answer = (await readTools.portfolioFilingsTouchedSince(
      backendFor(db, accountantId),
      {},
    )) as TouchedAnswer;
    expect(answer.companies).toBe(2);
    expect(answer.touched).toBe(0);
    expect(answer.untouched.map((u) => u.company_id).sort()).toEqual([...kept].sort());
    expect(answer.untouched.every((u) => u.filed === 0)).toBe(true);
  });
});

interface OverviewAnswer {
  on: string;
  companies: number;
  overview: { company_id: string; currency_code: string; customers_open: string; suppliers_late: number }[];
  note: string;
}

describe('portfolio_overview', () => {
  // `portfolio_overview()` is read on a schema that says it has it
  // (`SCHEMA_FEATURES.portfolio_overview`). Until the release that brings it
  // redefines `ekwo_schema_version()`, this database says the version it will
  // be for these tests, each on a backend of its own, and says its own again
  // after them.
  let definition: string;
  beforeAll(async () => {
    const version = await db.query<{ definition: string }>(
      `select pg_get_functiondef('ekwo.ekwo_schema_version()'::regprocedure) as definition`,
    );
    definition = version.rows[0]!.definition;
    await db.query(
      `create or replace function ekwo.ekwo_schema_version() returns text language sql immutable as $$ select '${SCHEMA_FEATURES.portfolio_overview.since}'::text $$`,
    );
  });
  afterAll(async () => {
    await db.query(definition);
  });

  it('names every company the caller keeps, with zeros where nothing is open', async () => {
    const answer = (await readTools.portfolioOverview(backendFor(db, accountantId), {
      on: '2026-06-30',
    })) as OverviewAnswer;
    expect(answer.on).toBe('2026-06-30');
    expect(answer.companies).toBe(2);
    expect(answer.overview.map((o) => o.company_id).sort()).toEqual([...kept].sort());
    for (const row of answer.overview) {
      expect(Number(row.customers_open)).toBe(0);
      expect(row.suppliers_late).toBe(0);
      expect(row.currency_code).toMatch(/^[A-Z]{3}$/);
    }
    expect(answer.note).toContain('currency_code');
  });

  it('reads today when no day is given', async () => {
    const answer = (await readTools.portfolioOverview(backendFor(db, accountantId), {})) as OverviewAnswer;
    expect(answer.on).toBe(new Date().toISOString().slice(0, 10));
    expect(answer.companies).toBe(2);
  });

  it('tells somebody with no company that nothing was read', async () => {
    const answer = (await readTools.portfolioOverview(backendFor(db, strangerId), {})) as OverviewAnswer;
    expect(answer.overview).toEqual([]);
    expect(answer.note).toContain('no portfolio');
  });
});
