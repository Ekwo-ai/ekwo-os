import type { PGlite } from '@electric-sql/pglite';
import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, repoRoot, rows } from './helpers/db.js';
import { newCompany } from './helpers/factory.js';
import { allPacks, declarationPeriods, packWhere } from './helpers/packs.js';

// One cadence per declaration, and not one cadence.
//
// `companies.vat_period` held how often a company files, named after the return
// it was about. A company is subject to several declarations and each has a
// cadence of its own: the recapitulative statement of intra-Community supplies
// is filed monthly from the first euro in one of the countries read here, above
// a threshold counting goods alone in another, on separately chosen cadences
// for goods and services in a third, and with the return in the fourth. So the
// statement had no cadence of its own to read, and refused no period at all.
//
// What is proved here: the table records one row per declaration, the
// deprecated column is a mirror of one of those rows and never a second place
// the fact is decided, each guard reads the cadence of the form it is about,
// and both guards still refuse only what is certain.

let db: PGlite;

/** A whole month, quarter or year, for a form filed on each. */
const RANGE: Record<string, [string, string]> = {
  month: ['2026-07-01', '2026-07-31'],
  quarter: ['2026-07-01', '2026-09-30'],
  year: ['2026-01-01', '2026-12-31'],
};

/** The pack whose periodic return offers a choice: there is a wrong period. */
const choice = packWhere(
  'whose periodic return is filed on more than one cadence',
  (pack) => (pack.report?.periods.length ?? 0) > 1,
);
const form = choice.report!.code;
const files = choice.report!.periods[1]!;
const asked = choice.report!.periods[0]!;

beforeAll(async () => {
  db = await freshDatabase();
}, 120_000);

afterAll(async () => {
  await db.close();
});

describe('a company records a cadence per declaration', () => {
  it('holds one row per form, keyed on the company and the form', async () => {
    const company = await newCompany(db, { country: choice.manifest.country, name: 'Deux formulaires' });
    await asUser(db, company.ownerId, async () => {
      await db.query(
        `insert into company_filing_periods (company_id, report_code, period)
         values ($1, $2, $3::declaration_period)`,
        [company.companyId, form, files],
      );
    });
    expect(await one<{ period: string }>(
      db,
      'select period::text as period from company_filing_periods where company_id = $1 and report_code = $2',
      [company.companyId, form],
    )).toEqual({ period: files });
    expect(await one<{ period: string | null }>(
      db,
      'select filing_period($1, $2)::text as period',
      [company.companyId, form],
    )).toEqual({ period: files });
  });

  it('answers null for a declaration nothing was recorded for', async () => {
    const company = await newCompany(db, { country: choice.manifest.country, name: 'Rien de dit' });
    expect(await one<{ period: string | null }>(
      db,
      'select filing_period($1, $2)::text as period',
      [company.companyId, form],
    )).toEqual({ period: null });
  });

  it('refuses a cadence recorded against a form no installation carries, by name', async () => {
    const company = await newCompany(db, { country: choice.manifest.country, name: 'Formulaire fantôme' });
    const message = await expectError(
      db,
      `insert into company_filing_periods (company_id, report_code, period)
       values ($1, 'NOT-A-FORM', 'month')`,
      [company.companyId],
    );
    expect(message).toMatch(/unknown_tax_report: NOT-A-FORM/);
  });

  it('refuses a cadence that is not one, at the column', async () => {
    const company = await newCompany(db, { country: choice.manifest.country, name: 'Quinzaine' });
    const message = await expectError(
      db,
      `insert into company_filing_periods (company_id, report_code, period)
       values ($1, $2, 'fortnight')`,
      [company.companyId, form],
    );
    expect(message).toMatch(/declaration_period|invalid input value/i);
  });
});

describe('the deprecated column is a mirror and never a second answer', () => {
  it('follows the row recorded for the periodic return', async () => {
    const company = await newCompany(db, { country: choice.manifest.country, name: 'Miroir' });
    await asUser(db, company.ownerId, async () => {
      await db.query(
        `insert into company_filing_periods (company_id, report_code, period)
         values ($1, $2, $3::declaration_period)`,
        [company.companyId, form, files],
      );
    });
    expect(await one<{ vat_period: string | null }>(
      db,
      'select vat_period::text as vat_period from companies where id = $1',
      [company.companyId],
    )).toEqual({ vat_period: files });

    await asUser(db, company.ownerId, async () => {
      await db.query(
        `update company_filing_periods set period = $3::declaration_period
          where company_id = $1 and report_code = $2`,
        [company.companyId, form, asked],
      );
    });
    expect(await one<{ vat_period: string | null }>(
      db,
      'select vat_period::text as vat_period from companies where id = $1',
      [company.companyId],
    )).toEqual({ vat_period: asked });

    await asUser(db, company.ownerId, async () => {
      await db.query('delete from company_filing_periods where company_id = $1', [company.companyId]);
    });
    expect(await one<{ vat_period: string | null }>(
      db,
      'select vat_period::text as vat_period from companies where id = $1',
      [company.companyId],
    )).toEqual({ vat_period: null });
  });

  it('records a write to the column as what it is: a cadence for the periodic return', async () => {
    // Everything written before the table existed names the column and nothing
    // else. Such a writer stays correct without learning a table, and what it
    // wrote is readable where every other cadence is.
    const company = await newCompany(db, { country: choice.manifest.country, name: 'Ancien écrivain' });
    await asUser(db, company.ownerId, async () => {
      await db.query('update companies set vat_period = $2::declaration_period where id = $1', [
        company.companyId,
        files,
      ]);
    });
    expect(await rows<{ report_code: string; period: string }>(
      db,
      `select report_code, period::text as period from company_filing_periods
        where company_id = $1`,
      [company.companyId],
    )).toEqual([{ report_code: form, period: files }]);

    await asUser(db, company.ownerId, async () => {
      await db.query('update companies set vat_period = null where id = $1', [company.companyId]);
    });
    expect(await rows(
      db,
      'select report_code from company_filing_periods where company_id = $1',
      [company.companyId],
    )).toEqual([]);
  });

  it('names the periodic return by asking the pack, not by knowing a country', async () => {
    for (const pack of allPacks) {
      if (pack.report === null) continue;
      const company = await newCompany(db, { country: pack.manifest.country, name: `Code ${pack.slug}` });
      expect(await one<{ code: string | null }>(
        db,
        'select periodic_return_code($1) as code',
        [company.companyId],
      )).toEqual({ code: pack.report.code });
    }
  });
});

describe('each guard reads the cadence of the declaration it is about', () => {
  let filer: { companyId: string; ownerId: string };
  /** A second declaration of this test's own: no pack carries one yet. */
  const statement = `${choice.manifest.country}-RECAP-FIXTURE`;

  beforeAll(async () => {
    filer = await newCompany(db, { country: choice.manifest.country, name: 'Deux cadences' });
    await db.query(
      `insert into tax_report_templates (country, code, name, periods, is_periodic_return)
       values ($1, $2, 'A statement of its own', array[$3, $4]::declaration_period[], false)`,
      [choice.manifest.country, statement, asked, files],
    );
    await asUser(db, filer.ownerId, async () => {
      // The return on one cadence, the statement on the other. That is the
      // ordinary case in three of the four countries read while this was
      // written, and it is what one column could not hold.
      await db.query(
        `insert into company_filing_periods (company_id, report_code, period)
         values ($1, $2, $3::declaration_period), ($1, $4, $5::declaration_period)`,
        [filer.companyId, form, files, statement, asked],
      );
    });
  }, 60_000);

  it('refuses the return on a cadence the company does not file it on', async () => {
    const message = await expectError(db, 'select * from vat_return($1, $2::date, $3::date)', [
      filer.companyId,
      ...RANGE[asked]!,
    ]);
    expect(message).toMatch(/wrong_declaration_period/);
    expect(message).toMatch(new RegExp(`${files}\\b`));
  });

  it('answers the return on the cadence the company does file it on', async () => {
    const [from, to] = RANGE[files]!;
    const boxes = await rows(db, 'select * from vat_return($1, $2::date, $3::date)', [
      filer.companyId,
      from,
      to,
    ]);
    expect(Array.isArray(boxes)).toBe(true);
  });

  it('refuses the statement on a cadence the company does not file it on', async () => {
    const message = await expectError(
      db,
      'select * from ec_sales_list($1, $2::date, $3::date, $4)',
      [filer.companyId, ...RANGE[files]!, statement],
    );
    expect(message).toMatch(/wrong_declaration_period/);
    expect(message).toMatch(new RegExp(`${asked}\\b`));
  });

  it('answers the statement on its own cadence, which is not the return\'s', async () => {
    // The whole point. The company files its return on one cadence and its
    // statement on the other; borrowing the return's cadence would refuse this.
    const lines = await rows(db, 'select * from ec_sales_list($1, $2::date, $3::date, $4)', [
      filer.companyId,
      ...RANGE[asked]!,
      statement,
    ]);
    expect(Array.isArray(lines)).toBe(true);
  });

  it('refuses nothing when the caller names no statement', async () => {
    // Reading the figures is not filing, and a reader that has not said which
    // declaration it is preparing is asking for an analysis.
    for (const cadence of declarationPeriods) {
      const [from, to] = RANGE[cadence]!;
      const lines = await rows(db, 'select * from ec_sales_list($1, $2::date, $3::date)', [
        filer.companyId,
        from,
        to,
      ]);
      expect(Array.isArray(lines), cadence).toBe(true);
    }
  });

  it('refuses a statement form that is not one, by name', async () => {
    const [from, to] = RANGE[asked]!;
    const message = await expectError(
      db,
      `select * from ec_sales_list($1, $2::date, $3::date, 'NOT-A-FORM')`,
      [filer.companyId, from, to],
    );
    expect(message).toMatch(/unknown_tax_report: NOT-A-FORM/);
  });

  it('imposes nothing on a company that has recorded no cadence for a form', async () => {
    const silent = await newCompany(db, { country: choice.manifest.country, name: 'Sans cadence' });
    const [from, to] = RANGE[asked]!;
    const boxes = await rows(db, 'select * from vat_return($1, $2::date, $3::date)', [
      silent.companyId,
      from,
      to,
    ]);
    expect(Array.isArray(boxes)).toBe(true);
  });

  it('refuses nothing for a range that is no filing period at all', async () => {
    const boxes = await rows(db, 'select * from vat_return($1, $2::date, $3::date)', [
      filer.companyId,
      '2026-07-01',
      '2026-07-15',
    ]);
    expect(Array.isArray(boxes)).toBe(true);
    const lines = await rows(db, 'select * from ec_sales_list($1, $2::date, $3::date, $4)', [
      filer.companyId,
      '2026-07-01',
      '2026-07-15',
      statement,
    ]);
    expect(Array.isArray(lines)).toBe(true);
  });
});

describe('who may read and who may write a filing cadence', () => {
  it('lets a member read and refuses a stranger', async () => {
    const owner = await newCompany(db, { country: choice.manifest.country, name: 'Chez nous' });
    const stranger = await newCompany(db, { country: choice.manifest.country, name: 'Chez eux' });
    await asUser(db, owner.ownerId, async () => {
      await db.query(
        `insert into company_filing_periods (company_id, report_code, period)
         values ($1, $2, $3::declaration_period)`,
        [owner.companyId, form, files],
      );
    });
    await asUser(db, owner.ownerId, async () => {
      expect(
        await rows(db, 'select report_code from company_filing_periods where company_id = $1', [
          owner.companyId,
        ]),
      ).toHaveLength(1);
    });
    await asUser(db, stranger.ownerId, async () => {
      expect(
        await rows(db, 'select report_code from company_filing_periods where company_id = $1', [
          owner.companyId,
        ]),
      ).toHaveLength(0);
    });
  });

  it('refuses a write into another company books', async () => {
    const owner = await newCompany(db, { country: choice.manifest.country, name: 'Cible' });
    const stranger = await newCompany(db, { country: choice.manifest.country, name: 'Intrus' });
    await asUser(db, stranger.ownerId, async () => {
      const message = await expectError(
        db,
        `insert into company_filing_periods (company_id, report_code, period)
         values ($1, $2, $3::declaration_period)`,
        [owner.companyId, form, files],
      );
      expect(message).toMatch(/row-level security|violates/i);
    });
  });

  it('writes a line into the audit trail, like every other act of configuration', async () => {
    const company = await newCompany(db, { country: choice.manifest.country, name: 'Tracée' });
    await asUser(db, company.ownerId, async () => {
      await db.query(
        `insert into company_filing_periods (company_id, report_code, period)
         values ($1, $2, $3::declaration_period)`,
        [company.companyId, form, files],
      );
    });
    const trail = await rows<{ record_key: string; operation: string }>(
      db,
      `select record_key, operation::text as operation from audit_log
        where table_name = 'company_filing_periods' and company_id = $1`,
      [company.companyId],
    );
    expect(trail).toEqual([{ record_key: form, operation: 'insert' }]);
  });
});

describe('no country is written into this change', () => {
  it('leaves no country code in the migrations of this change', async () => {
    for (const file of [
      '20260916094500_a_company_files_more_than_one_declaration.sql',
      '20260916103000_a_ledger_line_names_its_posting.sql',
    ]) {
      const sql = await readFile(join(repoRoot, 'supabase', 'migrations', file), 'utf8');
      const offending = sql
        .split('\n')
        .filter((l) => !l.trimStart().startsWith('--'))
        .filter((l) => /'[A-Z]{2}'/.test(l));
      expect(offending, file).toEqual([]);
    }
  });
});
