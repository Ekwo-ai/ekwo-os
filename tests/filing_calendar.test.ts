import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, type Fixture } from './helpers/factory.js';
import { allPacks } from './helpers/packs.js';

let db: PGlite;
const packs = allPacks;

/** PGlite hands back a Date for a date column; the assertions want the day. */
function day(value: string | Date | null): string | null {
  if (value === null) return null;
  return value instanceof Date ? value.toISOString().slice(0, 10) : value;
}

interface Upcoming {
  report_code: string;
  period_start: string | Date;
  period_end: string | Date;
  due_date: string | Date | null;
  state: string | null;
}

beforeAll(async () => {
  db = await freshDatabase();
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('the date a pack declares', () => {
  it('is carried to the database with the text that sets it, or is null', async () => {
    const forms = await rows<{
      country: string;
      code: string;
      deadline_rule: string | null;
      deadline_reference: string | null;
    }>(
      db,
      `select country, code, deadline_rule, deadline_reference
         from tax_report_templates order by country, code`,
    );
    expect(forms.length).toBeGreaterThan(0);
    // Whatever a pack says, it says it completely: a rule always arrives with
    // the text behind it, and a form that says nothing says nothing at all.
    for (const form of forms) {
      if (form.deadline_rule === null) {
        expect(form.deadline_reference).toBeNull();
      } else {
        expect(form.deadline_reference).not.toBeNull();
        expect(form.deadline_reference!.length).toBeGreaterThan(30);
      }
    }
  });

  it('is at least declared by one pack, and read by the function', async () => {
    const declaring = await rows<{ country: string; code: string }>(
      db,
      `select country, code from tax_report_templates where deadline_rule is not null`,
    );
    expect(declaring.length).toBeGreaterThan(0);
  });
});

describe('working the date out', () => {
  it('answers each pack that declares a rule, for a period of its own form', async () => {
    for (const pack of packs) {
      const fx = await newCompany(db, {
        country: pack.manifest.country,
        chart: pack.golden?.chart ?? null,
      });
      const form = await rows<{ code: string; deadline_rule: string | null }>(
        db,
        `select code, deadline_rule from tax_report_templates
          where country = $1 and is_periodic_return`,
        [pack.manifest.country],
      );
      if (form.length === 0) continue;

      const due = await one<{ filing_deadline: string | null }>(
        db,
        `select filing_deadline($1, $2, '2026-03-31'::date) as filing_deadline`,
        [fx.companyId, form[0]!.code],
      );

      if (form[0]!.deadline_rule === null) {
        // A country whose schedule depends on who is filing says nothing, and
        // the function says nothing back rather than inventing a day.
        expect(due.filing_deadline).toBeNull();
      } else {
        expect(due.filing_deadline).not.toBeNull();
        // Whatever the rule, the answer is after the period and within a
        // quarter of it: no pack may quietly place a deadline before the
        // period it declares.
        expect(new Date(due.filing_deadline!).getTime()).toBeGreaterThan(
          new Date('2026-03-31').getTime(),
        );
        expect(new Date(due.filing_deadline!).getTime()).toBeLessThan(
          new Date('2026-07-01').getTime(),
        );
      }
    }
  }, 300_000);

  it('adds the days an administration grants on top of the rule', async () => {
    const extending = await rows<{ country: string; code: string; deadline_plus_days: number }>(
      db,
      `select country, code, deadline_plus_days from tax_report_templates
        where coalesce(deadline_plus_days, 0) > 0`,
    );
    for (const form of extending) {
      const fx = await newCompany(db, { country: form.country });
      const due = await one<{ filing_deadline: string }>(
        db,
        `select filing_deadline($1, $2, '2026-03-31'::date) as filing_deadline`,
        [fx.companyId, form.code],
      );
      const withoutExtension = await one<{ plain: string }>(
        db,
        `select (date_trunc('month', '2026-03-31'::date + interval '2 month')
                 - interval '1 day')::date::text as plain`,
      );
      const days =
        (new Date(due.filing_deadline).getTime() - new Date(withoutExtension.plain).getTime()) /
        86_400_000;
      expect(days).toBe(form.deadline_plus_days);
    }
  }, 300_000);

  it('never runs off the end of a short month', async () => {
    // A pack naming the 31st and a period ending in January would land on a
    // day February does not have. The rule bends to the end of the month
    // rather than raising, which is how an administration reads it.
    const fx = await newCompany(db);
    await db.query(
      `update tax_report_templates set deadline_rule = 'day_of_month_after_period',
                                       deadline_day = 31,
                                       deadline_reference = 'a fixture, to prove the shape'
        where is_periodic_return`,
    );
    const form = await one<{ code: string }>(
      db,
      `select t.code from tax_report_templates t join companies c on c.id = $1
        where t.country = c.country and t.is_periodic_return`,
      [fx.companyId],
    );
    const due = await one<{ filing_deadline: string }>(
      db,
      `select filing_deadline($1, $2, '2026-01-31'::date) as filing_deadline`,
      [fx.companyId, form.code],
    );
    expect(day(due.filing_deadline)).toBe('2026-02-28');
  }, 300_000);
});

describe('what is coming', () => {
  it('lists a period per cadence, with what has been filed against it', async () => {
    const db2 = await freshDatabase();
    try {
      const fx = await newCompany(db2);
      const code = await one<{ code: string }>(db2, `select periodic_return_code($1) as code`, [
        fx.companyId,
      ]);
      await db2.query(
        `insert into company_filing_periods (company_id, report_code, period)
         values ($1, $2, 'quarter')`,
        [fx.companyId, code.code],
      );

      const coming = await rows<Upcoming>(
        db2,
        `select * from upcoming_filings($1, '2026-01-01'::date, '2026-12-31'::date)`,
        [fx.companyId],
      );
      const periodic = coming.filter((c) => c.report_code === code.code);
      expect(periodic).toHaveLength(4);
      expect(day(periodic[0]!.period_start)).toBe('2026-01-01');
      expect(day(periodic[0]!.period_end)).toBe('2026-03-31');
      expect(periodic.every((p) => p.state === null)).toBe(true);

      // Prepare one, and the calendar shows it without changing its shape.
      await db2.query(`select prepare_filing($1, '2026-01-01'::date, '2026-03-31'::date)`, [
        fx.companyId,
      ]);
      const after = await rows<Upcoming>(
        db2,
        `select * from upcoming_filings($1, '2026-01-01'::date, '2026-12-31'::date)`,
        [fx.companyId],
      );
      const first = after.find(
        (c) => c.report_code === code.code && day(c.period_start) === '2026-01-01',
      );
      expect(first!.state).toBe('draft');
      expect(after.filter((c) => c.report_code === code.code)).toHaveLength(4);
    } finally {
      await db2.close();
    }
  }, 300_000);
});
