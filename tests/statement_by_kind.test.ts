/**
 * Asking for a balance sheet without knowing which scheme answers.
 *
 * `financial_statement()` takes the code of a scheme, and that code belongs to
 * a country pack. A client that knows which company it is looking at does not
 * know the string, and the moment it writes one down it has written a country
 * into code. `available_statements()` said what a company may ask for;
 * `default_statement_code()` and `financial_statement_of_kind()` are the step
 * after it — from *a balance sheet* to the one scheme that answers, decided in
 * one place so that two readers cannot disagree.
 *
 * Every pack of this checkout is walked, because the contract is about the
 * core and not about the countries somebody listed: each carries its own
 * schemes, and what is asserted is read back from the pack.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from './helpers/db.js';
import { demoCompanyId, newCompany, newUser } from './helpers/factory.js';
import { allPacks, packsWhere } from './helpers/packs.js';

let db: PGlite;

beforeAll(async () => {
  db = await freshDatabase();
}, 120_000);

afterAll(async () => {
  await db.close();
});

/** The kinds of statement a pack declares, from its own `statements.json`. */
function kindsOf(pack: (typeof allPacks)[number]): string[] {
  return [...new Set(pack.statements.map((statement) => statement.kind))].sort();
}

interface Offered {
  code: string;
  kind: string;
  country: string | null;
  is_default: boolean;
}

describe('every pack of this checkout', () => {
  const carriers = packsWhere('declares a financial statement', (pack) => pack.statements.length > 0);

  it('is read by more than one country, or this test proves nothing', () => {
    expect(new Set(carriers.map((pack) => pack.manifest.country)).size).toBeGreaterThan(1);
  });

  for (const pack of carriers) {
    describe(`the ${pack.slug} pack`, () => {
      let company: string;
      let offered: Offered[];

      beforeAll(async () => {
        const fixture = await newCompany(db, {
          country: pack.manifest.country,
          name: `Statements ${pack.slug}`,
        });
        company = fixture.companyId;
        offered = await rows<Offered>(
          db,
          `select code, kind, country, is_default from available_statements($1)`,
          [company],
        );
      }, 120_000);

      it('resolves each kind it declares to one of the schemes it offers', async () => {
        for (const kind of kindsOf(pack)) {
          const chosen = await one<{ code: string | null }>(
            db,
            `select default_statement_code($1, $2) as code`,
            [company, kind],
          );
          const candidates = offered.filter((statement) => statement.kind === kind);
          expect(candidates.length).toBeGreaterThan(0);
          expect(candidates.map((statement) => statement.code)).toContain(chosen.code);
        }
      });

      it('prefers the scheme its own chart declares over the generic framework', async () => {
        for (const kind of kindsOf(pack)) {
          const candidates = offered.filter((statement) => statement.kind === kind);
          const declared = candidates.filter((statement) => statement.is_default);
          const national = candidates.filter((statement) => statement.country !== null);
          const chosen = await one<{ code: string | null }>(
            db,
            `select default_statement_code($1, $2) as code`,
            [company, kind],
          );
          const expected = (declared[0] ?? national[0] ?? candidates[0])!;
          expect(chosen.code).toBe(expected.code);
        }
      });

      it('answers by kind exactly what it answers by code', async () => {
        for (const kind of kindsOf(pack)) {
          const chosen = await one<{ code: string }>(
            db,
            `select default_statement_code($1, $2) as code`,
            [company, kind],
          );
          const byKind = await rows<Record<string, unknown>>(
            db,
            `select * from financial_statement_of_kind($1, $2, $3::date, $4::date)`,
            [company, kind, '2026-01-01', '2026-12-31'],
          );
          const byCode = await rows<Record<string, unknown>>(
            db,
            `select * from financial_statement($1, $2, $3::date, $4::date)`,
            [company, chosen.code, '2026-01-01', '2026-12-31'],
          );
          expect(byKind.length).toBe(byCode.length);
          expect(byKind.length).toBeGreaterThan(0);
          expect(byKind.map(({ statement_code: _, ...line }) => line)).toEqual(byCode);
          expect(new Set(byKind.map((line) => line['statement_code']))).toEqual(
            new Set([chosen.code]),
          );
        }
      });
    });
  }
});

describe('a kind nothing of this installation reports', () => {
  it('is refused, and the refusal says what the company does report', async () => {
    const demo = await demoCompanyId(db);
    const reported = await rows<{ kind: string }>(
      db,
      `select distinct kind from available_statements($1) order by kind`,
      [demo],
    );
    const absent = ['cash_flow', 'not_a_kind'].find(
      (kind) => !reported.some((row) => row.kind === kind),
    );
    expect(absent).toBeDefined();

    const message = await expectError(
      db,
      `select * from financial_statement_of_kind($1, $2, '2026-01-01'::date, '2026-12-31'::date)`,
      [demo, absent],
    );
    expect(message).toMatch(/unknown_statement/);
    for (const row of reported) expect(message).toContain(row.kind);
  });

  it('answers null rather than raising, when only the code was asked for', async () => {
    const demo = await demoCompanyId(db);
    const chosen = await one<{ code: string | null }>(
      db,
      `select default_statement_code($1, 'not_a_kind') as code`,
      [demo],
    );
    expect(chosen.code).toBeNull();
  });
});

describe('a company nobody knows', () => {
  it('is named in the refusal, as financial_statement() names it', async () => {
    const message = await expectError(
      db,
      `select * from financial_statement_of_kind($1, 'balance_sheet',
                                                 '2026-01-01'::date, '2026-12-31'::date)`,
      [crypto.randomUUID()],
    );
    expect(message).toMatch(/unknown_company/);
  });
});

describe('a reader who was invited', () => {
  it('reaches both functions, and a stranger reaches no row through them', async () => {
    const demo = await demoCompanyId(db);
    const member = await one<{ user_id: string }>(
      db,
      `select user_id from company_members where company_id = $1 limit 1`,
      [demo],
    );
    const seen = await asUser(db, member.user_id, async () =>
      rows(db, `select * from financial_statement_of_kind($1, 'balance_sheet',
                                                          '2026-01-01'::date, '2026-12-31'::date)`, [demo]),
    );
    expect(seen.length).toBeGreaterThan(0);

    // A stranger is not a member, and `available_statements()` reads the
    // company row through the policies: no company, no scheme, no statement.
    const stranger = await newUser(db);
    const message = await asUser(db, stranger, async () =>
      expectError(
        db,
        `select * from financial_statement_of_kind($1, 'balance_sheet',
                                                   '2026-01-01'::date, '2026-12-31'::date)`,
        [demo],
      ),
    );
    expect(message).toMatch(/unknown_company|unknown_statement/);
  });
});
