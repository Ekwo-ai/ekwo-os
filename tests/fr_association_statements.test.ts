import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany } from './helpers/factory.js';
import { packWhere, roleOf } from './helpers/packs.js';

// The French association chart (règlement ANC n° 2018-06) draws its own
// bilan and compte de résultat — FR-ASSOC-BS and FR-ASSOC-IS — instead of
// reporting only on the generic framework by account type. This is what a
// year of an association looks like on them: membership fees, a gift
// counted as public generosity, a grant partly carried to a dedicated fund,
// and in-kind volunteering, kept off the balance sheet as the regulation
// has it.
//
// country-literal: the scenario books cotisations, public generosity and in-kind volunteering on the statements of a French association
const pack = packWhere(
  'a French association chart with its own statements',
  (p) => p.manifest.country === 'FR' && p.charts.some((c) => c.code === 'association'),
);
const chart = pack.charts.find((c) => c.code === 'association')!;

const BANK = roleOf(pack, 'bank');
const DUES = '756100'; // Cotisations sans contrepartie
const GIFTS = '754110'; // Dons manuels
const GRANT = '740000'; // Subventions d'exploitation
const TO_DEDICATED = '689400'; // Reports en fonds dédiés sur subventions d'exploitation
const DEDICATED = '194000'; // Fonds dédiés sur subventions d'exploitation
const VOLUNTEER_STAFF = '864000'; // Personnel bénévole (emplois, hors bilan)
const VOLUNTEERING = '875000'; // Bénévolat (ressources, hors bilan)

const from = '2026-01-01';
const to = '2026-12-31';

let db: PGlite;
let companyId: string;
let ownerId: string;

const n = (value: string | null | undefined): number => Number(value ?? 0);

async function entry(date: string, debit: string, credit: string, amount: number, label: string): Promise<void> {
  const row = await one<{ id: string }>(
    db,
    `insert into entries (company_id, journal_id, entry_date, description)
     select $1, miscellaneous_journal_id, $2::date, $3 from companies where id = $1 returning id`,
    [companyId, date, label],
  );
  await db.query(
    `insert into entry_lines (entry_id, company_id, account_id, sequence, debit, credit)
     values ($1, $2, account_id_by_code($2, $3), 10, $5, 0),
            ($1, $2, account_id_by_code($2, $4), 20, 0, $5)`,
    [row.id, companyId, debit, credit, amount],
  );
  await db.query('select post_entry($1)', [row.id]);
}

async function amounts(code: string): Promise<Record<string, number>> {
  const lines = await rows<{ line_code: string; amount: string }>(
    db,
    'select line_code, amount from financial_statement($1, $2, $3, $4)',
    [companyId, code, from, to],
  );
  return Object.fromEntries(lines.map((l) => [l.line_code, n(l.amount)]));
}

beforeAll(async () => {
  db = await freshDatabase();
  ({ companyId, ownerId } = await newCompany(db, { country: pack.manifest.country, chart: chart.code, name: 'Association' }));
}, 120_000);

afterAll(async () => {
  await db.close();
});

describe('a company on the French association chart, reporting on FR-ASSOC-BS and FR-ASSOC-IS', () => {
  it('is offered its own statements, marked as its chart default, beside the generic framework', async () => {
    const offered = await rows<{ code: string; is_default: boolean }>(
      db,
      'select code, is_default from available_statements($1)',
      [companyId],
    );
    expect(offered.filter((s) => s.is_default).map((s) => s.code).sort()).toEqual(['FR-ASSOC-BS', 'FR-ASSOC-IS']);
    expect(offered.some((s) => s.code === 'IFRS-SME-BS' && !s.is_default)).toBe(true);
  });

  it('books membership fees, a gift under public generosity, and a grant partly carried to a dedicated fund', async () => {
    await entry('2026-02-01', BANK, DUES, 500, 'Cotisations des adhérents');
    await entry('2026-03-15', BANK, GIFTS, 1000, 'Dons de la campagne de printemps');
    await entry('2026-06-01', BANK, GRANT, 800, "Subvention d'exploitation reçue");
    await entry('2026-12-31', TO_DEDICATED, DEDICATED, 200, 'Part de la subvention non utilisée');
    await entry('2026-12-31', VOLUNTEER_STAFF, VOLUNTEERING, 300, 'Heures de bénévolat valorisées');

    for (const code of ['FR-ASSOC-BS', 'FR-ASSOC-IS']) {
      expect(await rows(db, 'select * from unmapped_accounts($1, $2, $3, $4)', [companyId, code, from, to]), code).toEqual(
        [],
      );
    }

    const is = await amounts('FR-ASSOC-IS');
    expect(is['PR756']).toBeCloseTo(500, 2); // Cotisations
    expect(is['PR754']).toBeCloseTo(1000, 2); // Générosité du public
    expect(is['PR74']).toBeCloseTo(800, 2); // Subventions d'exploitation
    expect(is['CH689']).toBeCloseTo(200, 2); // Report en fonds dédiés et reportés
    expect(is['RESNET']).toBeCloseTo(500 + 1000 + 800 - 200, 2);

    // Volunteering is valued in the compte de résultat's memo section, on
    // both the uses and the resources of in-kind voluntary contributions —
    // and never reaches the bilan.
    expect(is['CVN_EMPLOIS']).toBeCloseTo(300, 2);
    expect(is['CVN_RESSOURCES']).toBeCloseTo(300, 2);

    const bs = await amounts('FR-ASSOC-BS');
    expect(bs['P194']).toBeCloseTo(200, 2); // Fonds dédiés sur subventions d'exploitation
    expect(bs['P12']).toBeCloseTo(2100, 2); // Résultat de l'exercice, before the close
    expect(bs['ATOT']).toBeCloseTo(bs['PTOT']!, 2);
    // The transfer to the dedicated fund moves 200 from the result to fonds
    // dédiés, both within equity and liabilities: cash is untouched, so total
    // assets still reads the full 2,300 of cotisations, gift and grant.
    expect(bs['ATOT']).toBeCloseTo(2300, 2);
    for (const code of ['860', '861', '862', '864', '870', '871', '875']) {
      expect(bs).not.toHaveProperty(code);
    }
  });

  it('closes the year onto the result accounts of the pack, equity without right of return left untouched', async () => {
    await entry('2026-04-01', BANK, '102100', 5000, 'Première situation nette établie');

    const year = await one<{ id: string }>(db, 'select id from fiscal_years where company_id = $1', [companyId]);
    const closed = await asUser(db, ownerId, () =>
      one<{ close_fiscal_year: { result: string; result_kind: string } }>(db, 'select close_fiscal_year($1)', [year.id]),
    );
    expect(n(closed.close_fiscal_year.result)).toBeCloseTo(2100, 2);
    expect(closed.close_fiscal_year.result_kind).toBe('profit');

    const bs = await amounts('FR-ASSOC-BS');
    expect(bs['P102']).toBeCloseTo(5000, 2); // Fonds propres sans droit de reprise
    expect(bs['ATOT']).toBeCloseTo(bs['PTOT']!, 2);
    expect(bs['ATOT']).toBeCloseTo(2300 + 5000, 2);
  });
});
