import type { PGlite } from '@electric-sql/pglite';
import { cp, mkdtemp, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { readPack, type Pack } from '../packages/cli/src/index.js';
import { expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany } from './helpers/factory.js';
import { replayScenario } from './helpers/golden-scenario.js';
import { allPacks, cadenceMonths, declarationPeriods, packsRoot, packWhere } from './helpers/packs.js';

// A cadence of any whole number of months, and a box frozen at its unit.
//
// Three packs of this repository wrote down what the schema could not say about
// filing: a return whose law makes the period two months, a return kept in a
// currency without decimals that froze with two, and a form filed in whole
// units over a ledger kept in cents. Each is proved here on the pack that
// carries the property, found by the property and never by its country.

let db: PGlite;

beforeAll(async () => {
  db = await freshDatabase();
}, 300_000);

afterAll(async () => {
  await db?.close();
});

/** PGlite hands back a Date for a date column; the assertions want the day. */
function day(value: string | Date | null): string | null {
  if (value === null) return null;
  return value instanceof Date ? value.toISOString().slice(0, 10) : value;
}

const iso = (date: Date): string => date.toISOString().slice(0, 10);

/** The day a period closed on `end` is due under a pack's rule, worked out here and not by the database. */
function dueUnder(pack: Pack, end: string): string | null {
  const deadline = pack.report?.deadline ?? null;
  if (deadline === null) return null;
  const closed = new Date(`${end}T00:00:00Z`);
  const lastOfNext = new Date(Date.UTC(closed.getUTCFullYear(), closed.getUTCMonth() + 2, 0));
  let due: Date;
  if (deadline.rule === 'day_of_month_after_period') {
    due = new Date(
      Date.UTC(lastOfNext.getUTCFullYear(), lastOfNext.getUTCMonth(),
        Math.min(deadline.day!, lastOfNext.getUTCDate())),
    );
  } else if (deadline.rule === 'last_day_of_month_after_period') {
    due = lastOfNext;
  } else {
    return null;
  }
  due.setUTCDate(due.getUTCDate() + (deadline.plus_days ?? 0));
  return iso(due);
}

/** A company of a pack with its golden year booked. */
async function booked(pack: Pack, name: string): Promise<string> {
  const golden = pack.golden!;
  // country-literal: the country is the pack's own, found by its property.
  const { companyId } = await newCompany(db, {
    country: pack.manifest.country,
    name,
    chart: golden.chart,
    language: golden.language,
    fiscalYear: golden.fiscalYear,
  });
  await replayScenario(db, companyId, golden);
  return companyId;
}

/** The first period of the golden year whose return has figures, frozen. */
async function frozenPeriod(
  pack: Pack,
  companyId: string,
): Promise<{ filingId: string; from: string; to: string }> {
  for (const period of pack.golden!.periods) {
    const figures = await rows(db, `select 1 from vat_return($1, $2::date, $3::date) where not hidden`, [
      companyId,
      period.from,
      period.to,
    ]);
    if (figures.length === 0) continue;
    const filing = await one<{ id: string }>(db, `select id from prepare_filing($1, $2::date, $3::date)`, [
      companyId,
      period.from,
      period.to,
    ]);
    return { filingId: filing.id, from: period.from, to: period.to };
  }
  throw new Error(`${pack.slug}: no period of the golden year has a figure`);
}

describe('a cadence is a whole number of months, anchored on 1 January', () => {
  it('has a length for every value of the type, the same one the tests use', async () => {
    const lengths = await rows<{ period: string; months: number }>(
      db,
      `select p::text as period, declaration_period_months(p) as months
         from unnest(enum_range(null::declaration_period)) as p`,
    );
    expect(lengths.map((l) => l.period).sort()).toEqual([...declarationPeriods].sort());
    for (const length of lengths) {
      expect(length.months, length.period).toBe(cadenceMonths[length.period]);
    }
  });

  it('recognises every whole period of every cadence, and nothing else', async () => {
    for (const [cadence, months] of Object.entries(cadenceMonths)) {
      for (let start = 0; start < 12; start += months) {
        const from = new Date(Date.UTC(2026, start, 1));
        const to = new Date(Date.UTC(2026, start + months, 0));
        const got = await one<{ period: string | null }>(
          db,
          `select declaration_period_of($1::date, $2::date)::text as period`,
          [iso(from), iso(to)],
        );
        expect(got.period, `${cadence} from ${iso(from)}`).toBe(cadence);
      }
      if (months > 1 && months < 12) {
        // The same length, one month off its anchor, is an analysis.
        const from = new Date(Date.UTC(2026, 1, 1));
        const to = new Date(Date.UTC(2026, 1 + months, 0));
        const got = await one<{ period: string | null }>(
          db,
          `select declaration_period_of($1::date, $2::date)::text as period`,
          [iso(from), iso(to)],
        );
        expect(got.period, `${cadence} off its anchor`).toBeNull();
      }
    }
  });
});

describe('a return filed on two-month periods', () => {
  const pack = packWhere(
    'whose periodic return is filed on two-month periods unless the company asks otherwise',
    (p) => p.report?.period_default === 'bimonth' && p.golden !== null,
  );
  const form = pack.report!.code;
  let companyId: string;

  beforeAll(async () => {
    companyId = await booked(pack, 'Two-month filer');
  }, 300_000);

  it('produces six periods a year, each due on the day its pack says', async () => {
    const upcoming = await rows<{
      report_code: string;
      period_start: string | Date;
      period_end: string | Date;
      due_date: string | Date | null;
    }>(db, `select * from upcoming_filings($1, '2026-01-01', '2026-12-31') where report_code = $2`, [
      companyId,
      form,
    ]);
    expect(upcoming.map((u) => day(u.period_start))).toEqual([
      '2026-01-01', '2026-03-01', '2026-05-01', '2026-07-01', '2026-09-01', '2026-11-01',
    ]);
    expect(upcoming.map((u) => day(u.period_end))).toEqual([
      '2026-02-28', '2026-04-30', '2026-06-30', '2026-08-31', '2026-10-31', '2026-12-31',
    ]);
    for (const u of upcoming) {
      expect(day(u.due_date), `due for ${day(u.period_end)}`).toBe(dueUnder(pack, day(u.period_end)!));
    }
  });

  it('files one of them, and the calendar shows it filed on that period', async () => {
    const { filingId, from, to } = await frozenPeriod(pack, companyId);
    const asked = await one<{ period: string | null }>(
      db,
      `select declaration_period_of($1::date, $2::date)::text as period`,
      [from, to],
    );
    expect(asked.period, 'the golden year files on the cadence its form proposes').toBe('bimonth');

    await db.query(`select file_filing($1, $2)`, [filingId, `CADENCE-${pack.slug.toUpperCase()}`]);
    const listed = await one<{ state: string; due_date: string | Date | null }>(
      db,
      `select state::text as state, due_date from upcoming_filings($1, $2::date, $3::date)
        where report_code = $4 and period_start = $2::date and period_end = $3::date`,
      [companyId, from, to, form],
    );
    expect(listed.state).toBe('filed');
    expect(day(listed.due_date)).toBe(dueUnder(pack, to));
  });

  it('refuses another cadence of the form once the company records two months', async () => {
    const other = pack.report!.periods.find((c) => c !== 'bimonth' && c !== 'year');
    await db.query(
      `insert into company_filing_periods (company_id, report_code, period) values ($1, $2, 'bimonth')
       on conflict (company_id, report_code) do update set period = excluded.period`,
      [companyId, form],
    );
    const bimonth = await rows(db, `select * from vat_return($1, '2026-07-01', '2026-08-31')`, [companyId]);
    expect(Array.isArray(bimonth)).toBe(true);
    if (other !== undefined) {
      const months = cadenceMonths[other]!;
      const to = iso(new Date(Date.UTC(2026, 6 + months, 0)));
      const message = await expectError(db, `select * from vat_return($1, '2026-07-01', $2::date)`, [
        companyId,
        to,
      ]);
      expect(message).toMatch(new RegExp(`wrong_declaration_period: .* is a ${other}`));
    }
  });
});

describe('a return in a currency without decimals', () => {
  let pack: Pack;
  let companyId: string;

  beforeAll(async () => {
    const whole = await rows<{ country: string }>(
      db,
      `select d.country from country_defaults d join currencies c on c.code = d.currency_code
        where c.decimal_places = 0 order by d.country`,
    );
    const countries = new Set(whole.map((w) => w.country));
    const found = allPacks.find(
      (p) => countries.has(p.manifest.country) && p.report !== null && p.golden !== null,
    );
    if (found === undefined) throw new Error('no pack of this repository keeps its books in a currency without decimals');
    pack = found;
    companyId = await booked(pack, 'Whole-unit currency');
  }, 300_000);

  it('freezes each box without a decimal, as the return answers it', async () => {
    const { filingId } = await frozenPeriod(pack, companyId);
    const frozen = await rows<{ box: string; kind: string; amount: string; scale: number }>(
      db,
      `select box, kind, amount::text as amount, scale(amount) as scale
         from tax_filing_boxes where filing_id = $1 order by box, kind`,
      [filingId],
    );
    expect(frozen.length).toBeGreaterThan(0);
    for (const box of frozen) {
      expect(box.scale, `${pack.slug} ${box.box}|${box.kind} = ${box.amount}`).toBe(0);
      expect(box.amount).not.toContain('.');
    }
  });
});

describe('a form filed in whole units over a ledger kept in cents', () => {
  const pack = packWhere(
    'whose declaration form is filed in units coarser than its currency',
    (p) => p.report?.rounding !== null && p.report?.rounding !== undefined && p.golden !== null,
  );
  const form = pack.report!.code;
  const unit = pack.report!.rounding!.unit;
  const decimals = 0 - Math.round(Math.log10(unit));
  let companyId: string;

  beforeAll(async () => {
    companyId = await booked(pack, 'Whole-unit form');
  }, 300_000);

  it('carries the unit and the text that sets it to the form', async () => {
    const row = await one<{ rounding_unit: string; rounding_reference: string | null }>(
      db,
      `select rounding_unit::text, rounding_reference from tax_report_templates
        where country = $1 and code = $2`,
      [pack.manifest.country, form],
    );
    expect(Number(row.rounding_unit)).toBe(unit);
    expect(row.rounding_reference!.length).toBeGreaterThan(30);
    const rounding = await one<{ decimals: number }>(
      db,
      `select (filing_rounding($1, $2)).decimals as decimals`,
      [companyId, form],
    );
    expect(rounding.decimals).toBe(decimals);
  });

  it('freezes every box at the unit, from its exact figure, and does not drift for the cents', async () => {
    const { filingId, from, to } = await frozenPeriod(pack, companyId);
    const frozen = await rows<{ box: string; kind: string; amount: string }>(
      db,
      `select box, kind, amount::text as amount from tax_filing_boxes where filing_id = $1 order by box, kind`,
      [filingId],
    );
    const exact = await rows<{ box: string; kind: string; amount: string }>(
      db,
      `select box, kind, amount::text as amount from vat_return($1, $2::date, $3::date)
        where not hidden order by box, kind`,
      [companyId, from, to],
    );
    expect(frozen.map((b) => `${b.box}|${b.kind}`)).toEqual(exact.map((b) => `${b.box}|${b.kind}`));
    frozen.forEach((box, i) => {
      const value = Number(box.amount);
      expect(Number.isInteger(value * 10 ** decimals), `${box.box} = ${box.amount}`).toBe(true);
      expect(Math.abs(value - Number(exact[i]!.amount))).toBeLessThanOrEqual(unit / 2);
    });

    await db.query(`select file_filing($1, $2)`, [filingId, `UNIT-${pack.slug.toUpperCase()}`]);
    const drift = await rows(db, `select * from filing_drift($1)`, [filingId]);
    expect(drift).toEqual([]);
  });

  it('refuses a unit that is not a power of ten, and a unit without its text', async () => {
    const coin = await expectError(
      db,
      `update tax_report_templates set rounding_unit = 0.05 where country = $1 and code = $2`,
      [pack.manifest.country, form],
    );
    expect(coin).toContain('tax_report_templates_rounding_unit_is_a_power_of_ten');
    const silent = await expectError(
      db,
      `update tax_report_templates set rounding_reference = null where country = $1 and code = $2`,
      [pack.manifest.country, form],
    );
    expect(silent).toContain('tax_report_templates_rounding_unit_has_its_text');
  });

  it('is refused by `ekwo pack check` when it is not a power of ten', async () => {
    const dir = await mkdtemp(join(tmpdir(), 'ekwo-unit-'));
    await cp(join(packsRoot, 'schema'), join(dir, 'schema'), { recursive: true });
    await cp(join(packsRoot, pack.slug), join(dir, pack.slug), { recursive: true });
    const file = join(dir, pack.slug, 'tax_report.json');
    const content = JSON.parse(await readFile(file, 'utf8')) as Record<string, Record<string, unknown>>;
    content['rounding']!['unit'] = 0.05;
    await writeFile(file, JSON.stringify(content), 'utf8');
    await expect(readPack(pack.slug, dir)).rejects.toThrow(/not a power of ten/);
  });
});

describe('a form that names no unit', () => {
  it('freezes at the decimals of its currency, as before', async () => {
    const forms = await rows<{ country: string; code: string }>(
      db,
      `select country, code from tax_report_templates where rounding_unit is null order by country, code`,
    );
    expect(forms.length).toBeGreaterThan(0);
    for (const form of forms) {
      const { companyId } = await newCompany(db, { country: form.country, name: `Unit of ${form.code}` });
      const got = await one<{ same: boolean }>(
        db,
        `select filing_rounding($1, $2) = rounding_of($1) as same`,
        [companyId, form.code],
      );
      expect(got.same, form.code).toBe(true);
    }
  }, 300_000);
});
