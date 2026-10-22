import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { Pack, PackReport, PackVatScheme } from '../packages/cli/src/pack/read.js';
import { freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument } from './helpers/factory.js';
import { packWhere, roleOf } from './helpers/packs.js';

/**
 * VAT schemes in the core: the scheme a company is on decides which forms it
 * files, an annual return restates the boxes of the periodic one, and the
 * instalments of a year are planned from the previous year's return, deducted
 * on the next one, and listed with the returns.
 *
 * Nothing here names a country. The pack is the one that carries a scheme
 * with instalments, a scheme that charges no VAT and a scheme that files the
 * periodic return; every expected figure is taken from that pack — the boxes
 * of its annual form, the percentages of its schedule — or from the periodic
 * return of the same books computed before any scheme was recorded.
 *
 *   1. a company that records no scheme files as before;
 *   2. on the scheme with instalments: its filing periods follow, the periodic
 *      return is refused by name, the annual return adds up the periodic boxes
 *      it names, to the cent;
 *   3. the plan of the next year from the frozen return, the payments recorded
 *      on account, the annual return deducting them, upcoming_filings() listing
 *      them beside the return;
 *   4. under the minimum base, nothing is due;
 *   5. under a scheme that charges no VAT: no return, a sale with VAT refused,
 *      the exemption mention printed;
 *   6. a scheme starts on the first day of a financial year, and a cadence the
 *      scheme does not allow is refused.
 */

const pack: Pack = packWhere(
  'whose VAT schemes plan instalments, exempt from VAT and file the periodic return',
  (p) =>
    (p.vatSchemes?.schemes.some((s) => s.instalments !== null) ?? false) &&
    (p.vatSchemes?.schemes.some((s) => !s.charges_vat) ?? false) &&
    (p.vatSchemes?.schemes.some((s) => s.forms.some((f) => f.report === p.reportCode)) ?? false),
);
const country = pack.manifest.country;
const periodic = pack.report as PackReport;
const withInstalments = pack.vatSchemes!.schemes.find((s) => s.instalments !== null) as PackVatScheme;
const exempt = pack.vatSchemes!.schemes.find((s) => !s.charges_vat) as PackVatScheme;
const normal = pack.vatSchemes!.schemes.find((s) => s.forms.some((f) => f.report === periodic.code)) as PackVatScheme;
const annual = pack.reports.find((r) => r.code === withInstalments.instalments!.report) as PackReport;
const instalments = withInstalments.instalments!;

// A sale tax of the periodic return that the annual form restates: charged on
// a domestic sale, on invoicing, with a rate, and posted in a box `from` names.
const restated = new Set(annual.boxes.flatMap((b) => b.from.map((ref) => ref.split(':')[0])));
const saleTax = pack.taxes.find(
  (t) =>
    t.kind === 'vat' &&
    t.rate > 0 &&
    t.scope === 'sale' &&
    t.treatment === 'domestic' &&
    !t.cash_basis &&
    t.postings.invoice.some((posting) => posting.boxes.some((box) => restated.has(box))),
)!;
const income = roleOf(pack, 'sales');

let db: PGlite;
let number = 0;

async function company(name: string, years: number[]): Promise<{ id: string; customer: string }> {
  const first = years[0]!;
  const fixture = await newCompany(db, {
    country,
    name,
    fiscalYear: { name: `FY ${first}`, start: `${first}-01-01`, end: `${first}-12-31` },
  });
  for (const year of years.slice(1)) {
    await db.query(`insert into fiscal_years (company_id, name, start_date, end_date) values ($1, $2, $3, $4)`, [
      fixture.companyId,
      `FY ${year}`,
      `${year}-01-01`,
      `${year}-12-31`,
    ]);
  }
  return { id: fixture.companyId, customer: await newContact(db, fixture.companyId, { country }) };
}

async function sale(companyId: string, customer: string, date: string, amount: number, taxCode: string | null): Promise<string> {
  number += 1;
  const document = await newDocument(db, companyId, {
    docType: 'sale_invoice',
    number: `VS-${number}`,
    contactId: customer,
    date,
    lines: [{ unitPrice: amount, accountCode: income, taxCode }],
  });
  if (taxCode === null) await db.query(`update document_lines set tax_id = null where document_id = $1`, [document]);
  return document;
}

async function post(document: string): Promise<void> {
  await db.query(`select post_document($1)`, [document]);
}

async function boxes(companyId: string, from: string, to: string, report: string | null): Promise<Map<string, number>> {
  const result = await rows<{ box: string; kind: string; amount: string }>(
    db,
    `select box, kind, amount::text from vat_return($1, $2, $3, $4)`,
    [companyId, from, to, report],
  );
  return new Map(result.map((r) => [`${r.box}|${r.kind}`, Number(r.amount)]));
}

/** What a box of the annual form must hold: the sum of the periodic boxes it names. */
function restatedValue(box: PackReport['boxes'][number], periodicBoxes: Map<string, number>): number {
  let sum = 0;
  for (const ref of box.from) {
    const [code, kind] = ref.split(':');
    for (const [key, value] of periodicBoxes) {
      const [k, kk] = key.split('|');
      if (k === code && (kind === undefined || kk === kind)) sum += value;
    }
  }
  return Math.round(sum * 100) / 100;
}

const cents = (value: number): number => Math.round(value * 100) / 100;

/** The database refuses, and its sentence starts with the reason's name. */
async function refused(attempt: Promise<unknown>, reason: string): Promise<void> {
  await expect(attempt).rejects.toThrow(new RegExp(`^${reason}:`));
}

beforeAll(async () => {
  db = await freshDatabase();
});

afterAll(async () => {
  await db.close();
});

describe('a company that records no scheme', () => {
  it('files the periodic return as before, and is listed no instalment', async () => {
    const { id, customer } = await company('No scheme', [2026]);
    await post(await sale(id, customer, '2026-03-10', 1000, saleTax.code));
    const march = await boxes(id, '2026-03-01', '2026-03-31', null);
    expect(march.size).toBeGreaterThan(0);
    const listed = await rows<{ report_code: string; instalment: number | null }>(
      db,
      `select report_code, instalment from upcoming_filings($1, '2026-01-01', '2026-12-31')`,
      [id],
    );
    expect(listed.every((row) => row.instalment === null)).toBe(true);
    expect(listed.some((row) => row.report_code === periodic.code)).toBe(true);
    expect(await rows(db, `select * from instalment_plan($1, '2026-01-01', '2026-12-31')`, [id])).toEqual([]);
  });
});

describe('a company on a scheme with instalments', () => {
  let id: string;
  let customer: string;
  let firstYearPeriodic: Map<string, number>;

  beforeAll(async () => {
    ({ id, customer } = await company('Annual filer', [2026, 2027]));
    await post(await sale(id, customer, '2026-02-10', 12000, saleTax.code));
    await post(await sale(id, customer, '2026-09-20', 8000, saleTax.code));
    // The oracle: the periodic boxes of the year, read before any scheme.
    firstYearPeriodic = await boxes(id, '2026-01-01', '2026-12-31', periodic.code);
    await db.query(`insert into company_vat_schemes (company_id, valid_from, scheme_code) values ($1, '2026-01-01', $2)`, [
      id,
      withInstalments.code,
    ]);
  });

  it('records the cadences of its scheme and nothing else', async () => {
    const periods = await rows<{ report_code: string; period: string }>(
      db,
      `select report_code, period::text from company_filing_periods where company_id = $1 order by report_code`,
      [id],
    );
    expect(periods).toEqual(
      withInstalments.forms.map((f) => ({ report_code: f.report, period: f.period_default ?? f.periods[0] })),
    );
    const mirror = await one<{ vat_period: string | null }>(db, `select vat_period::text from companies where id = $1`, [id]);
    expect(mirror.vat_period).toBeNull();
  });

  it('is refused the periodic return, by name', async () => {
    await refused(
      db.query(`select * from vat_return($1, '2026-02-01', '2026-02-28', $2)`, [id, periodic.code]),
      'form_not_in_vat_scheme',
    );
    await refused(
      db.query(`update companies set vat_period = $2::declaration_period where id = $1`, [id, periodic.periods[0]]),
      'form_not_in_vat_scheme',
    );
  });

  it('files the annual form, which adds up the periodic boxes it names', async () => {
    const year = await boxes(id, '2026-01-01', '2026-12-31', null);
    const restatedBoxes = annual.boxes.filter((b) => b.from.length > 0);
    for (const box of restatedBoxes) {
      expect(year.get(`${box.box}|${box.kind}`) ?? 0, `${box.box}:${box.kind}`).toBe(restatedValue(box, firstYearPeriodic));
    }
    // The sales of the year are in it: a base and a tax, not two empty forms agreeing.
    expect(restatedBoxes.filter((box) => restatedValue(box, firstYearPeriodic) > 0).map((box) => box.kind).sort()).toEqual(['base', 'tax']);
    // And the base of next year's instalments is there to read.
    expect(year.get(`${instalments.base_box}|${instalments.base_kind}`) ?? 0).toBeGreaterThan(Number(instalments.minimum_base ?? 0));
  });

  it('plans next year from the frozen return, and deducts what is due on the next one', async () => {
    await db.query(`select prepare_filing($1, '2026-01-01', '2026-12-31', $2)`, [id, annual.code]);
    const base = (await boxes(id, '2026-01-01', '2026-12-31', annual.code)).get(
      `${instalments.base_box}|${instalments.base_kind}`,
    )!;

    const plan = await rows<{ sequence: number; due_month: string; base: string; amount_due: string; paid: string; reason: string | null }>(
      db,
      `select sequence, due_month::text, base::text, amount_due::text, paid::text, reason
         from instalment_plan($1, '2027-01-01', '2027-12-31') order by sequence`,
      [id],
    );
    expect(plan.map((row) => row.due_month)).toEqual(
      instalments.schedule.map((row) => `2027-${String(row.month).padStart(2, '0')}-01`),
    );
    for (const [i, row] of plan.entries()) {
      expect(Number(row.base)).toBe(base);
      expect(Number(row.amount_due)).toBe(cents((base * Number(instalments.schedule[i]!.percent)) / 100));
      expect(row.reason).toBeNull();
    }

    // The first one paid, in full; the second one not yet.
    await db.query(
      `insert into declaration_instalments (company_id, report_code, period_start, period_end, sequence, paid_on, amount)
       values ($1, $2, '2027-01-01', '2027-12-31', 1, '2027-07-15', $3)`,
      [id, annual.code, plan[0]!.amount_due],
    );
    const paid = await rows<{ paid: string; outstanding: string }>(
      db,
      `select paid::text, outstanding::text from instalment_plan($1, '2027-01-01', '2027-12-31') order by sequence`,
      [id],
    );
    expect(Number(paid[0]!.paid)).toBe(Number(plan[0]!.amount_due));
    expect(Number(paid[0]!.outstanding)).toBe(0);
    expect(Number(paid[1]!.outstanding)).toBe(Number(plan[1]!.amount_due));

    // The return of the year deducts what was due on account, paid or not.
    await post(await sale(id, customer, '2027-03-10', 15000, saleTax.code));
    const next = await boxes(id, '2027-01-01', '2027-12-31', annual.code);
    const deducted = annual.boxes.find((b) => b.reads === 'instalments_due' || b.reads === 'instalments_paid')!;
    const due = plan.reduce((sum, row) => sum + Number(row.amount_due), 0);
    expect(next.get(`${deducted.box}|${deducted.kind}`)).toBe(cents(due));
    // A total that subtracts it says so: what is left to pay is the tax less the instalments.
    const balance = annual.boxes.find((b) => b.kind === 'total' && b.minus.some((ref) => ref.split(':')[0] === deducted.box) && b.floor_zero)!;
    const owed = annual.boxes.find((b) => b.kind === 'total' && b.plus.length === 1 && balance.plus.includes(b.box))!;
    expect(next.get(`${balance.box}|total`) ?? 0).toBe(cents(Math.max((next.get(`${owed.box}|total`) ?? 0) - due, 0)));
  });

  it('lists the instalments beside the annual return, and no periodic return', async () => {
    const listed = await rows<{ report_code: string; period_start: string; instalment: number | null }>(
      db,
      `select report_code, period_start::text, instalment from upcoming_filings($1, '2027-01-01', '2027-12-31')`,
      [id],
    );
    expect(listed.filter((row) => row.instalment !== null)).toEqual(
      instalments.schedule.map((row) => ({
        report_code: annual.code,
        period_start: `2027-${String(row.month).padStart(2, '0')}-01`,
        instalment: row.sequence,
      })),
    );
    expect(listed.some((row) => row.instalment === null && row.report_code === annual.code)).toBe(true);
    expect(listed.some((row) => row.report_code === periodic.code)).toBe(false);
  });
});

describe('under the minimum base', () => {
  it('plans instalments of nothing, and lists none', async () => {
    const { id, customer } = await company('Small annual filer', [2026, 2027]);
    await db.query(`insert into company_vat_schemes (company_id, valid_from, scheme_code) values ($1, '2026-01-01', $2)`, [
      id,
      withInstalments.code,
    ]);
    await post(await sale(id, customer, '2026-05-10', 100, saleTax.code));
    const plan = await rows<{ amount_due: string; reason: string }>(
      db,
      `select amount_due::text, reason from instalment_plan($1, '2027-01-01', '2027-12-31')`,
      [id],
    );
    expect(plan.length).toBe(instalments.schedule.length);
    expect(plan.every((row) => Number(row.amount_due) === 0 && row.reason === 'below_minimum')).toBe(true);
    const listed = await rows<{ instalment: number | null }>(
      db,
      `select instalment from upcoming_filings($1, '2027-01-01', '2027-12-31') where instalment is not null`,
      [id],
    );
    expect(listed).toEqual([]);
  });
});

describe('a company on a scheme that charges no VAT', () => {
  let id: string;
  let customer: string;

  beforeAll(async () => {
    ({ id, customer } = await company('Exempt', [2026]));
    await db.query(`insert into company_vat_schemes (company_id, valid_from, scheme_code) values ($1, '2026-01-01', $2)`, [
      id,
      exempt.code,
    ]);
  });

  it('files no return', async () => {
    await refused(db.query(`select * from vat_return($1, '2026-01-01', '2026-01-31')`, [id]), 'vat_scheme_files_no_return');
    await refused(
      db.query(`select * from vat_return($1, '2026-01-01', '2026-01-31', $2)`, [id, periodic.code]),
      'form_not_in_vat_scheme',
    );
    expect(await rows(db, `select * from company_filing_periods where company_id = $1`, [id])).toEqual([]);
    expect(await rows(db, `select * from upcoming_filings($1, '2026-01-01', '2026-12-31')`, [id])).toEqual([]);
  });

  it('is refused a sale that charges VAT, and prints the exemption on one that does not', async () => {
    await refused(post(await sale(id, customer, '2026-04-02', 500, saleTax.code)), 'vat_charged_under_exemption');
    const document = await sale(id, customer, '2026-04-03', 500, null);
    await post(document);
    const mentions = await rows<{ applies_when: string }>(
      db,
      `select applies_when from document_legal_mentions where document_id = $1`,
      [document],
    );
    const declared = pack.documents.mentions.some((m) => m.applies_when === 'small_business');
    expect(mentions.some((m) => m.applies_when === 'small_business')).toBe(declared);
  });

  it('is told when a ceiling of its scheme is crossed, and stays on it', async () => {
    const crossed = await rows<{ measure: string; crossed: boolean | null }>(
      db,
      `select measure, crossed from vat_scheme_ceilings_crossed($1, '2026-01-01', '2026-12-31')`,
      [id],
    );
    expect(crossed.length).toBe(exempt.ceilings.length);
    const scheme = await one<{ code: string }>(db, `select (vat_scheme_at($1, '2026-12-31')).code`, [id]);
    expect(scheme.code).toBe(exempt.code);
  });
});

describe('a scheme is recorded by the year and checked', () => {
  it('starts on the first day of a financial year', async () => {
    const { id } = await company('Mid year', [2026]);
    await refused(
      db.query(`insert into company_vat_schemes (company_id, valid_from, scheme_code) values ($1, '2026-07-01', $2)`, [
        id,
        normal.code,
      ]),
      'scheme_change_mid_year',
    );
    await refused(
      db.query(`insert into company_vat_schemes (company_id, valid_from, scheme_code) values ($1, '2026-01-01', 'no-such-scheme')`, [
        id,
      ]),
      'unknown_vat_scheme',
    );
  });

  it('refuses a cadence the scheme does not allow, and a period the scheme does not file on', async () => {
    const { id } = await company('Normal', [2026]);
    await db.query(`insert into company_vat_schemes (company_id, valid_from, scheme_code) values ($1, '2026-01-01', $2)`, [
      id,
      normal.code,
    ]);
    const form = normal.forms.find((f) => f.report === periodic.code)!;
    const refused = periodic.periods.find((p) => !form.periods.includes(p));
    if (refused !== undefined) {
      await refused(
        db.query(`update company_filing_periods set period = $2::declaration_period where company_id = $1 and report_code = $3`, [
          id,
          refused,
          periodic.code,
        ]),
        'wrong_declaration_period',
      );
    }
    const allowed = await one<{ period: string }>(
      db,
      `select period::text from company_filing_periods where company_id = $1 and report_code = $2`,
      [id, periodic.code],
    );
    expect(form.periods).toContain(allowed.period);
  });
});
