import type { PGlite } from '@electric-sql/pglite';
import { cp, mkdtemp, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, rows } from './helpers/db.js';
import { newCompany, newUser } from './helpers/factory.js';
import { compilePack, describePack, packsDir, readPack, type Pack } from '../packages/cli/src/index.js';
import { allPacks, packWhere } from './helpers/packs.js';

/**
 * A declaration says when its tax is paid, where that is another day
 * (`20261127070000`).
 *
 * A form of `tax_report.json` may carry `deadline.payment`, a second rule of
 * the two that produce a date. What is proved:
 *
 *   1. a pack that names none compiles a seed that does not mention the
 *      columns, so it still loads on an older schema;
 *   2. a pack that names one is read, described and compiled, and
 *      `payment_deadline()`, `upcoming_filings()` and
 *      `portfolio_upcoming_filings()` answer the day its rule gives, beside a
 *      filing day `filing_deadline()` still computes as before;
 *   3. a form that names none answers no payment day;
 *   4. the schema of a pack, `ekwo pack check` and the column refuse a
 *      payment rule beside `depends_on_taxpayer`, and a shape that does not
 *      fit its rule.
 */

type Rule = 'day_of_month_after_period' | 'last_day_of_month_after_period' | 'depends_on_taxpayer';

/** The day a rule gives for a period ending on `end`, worked out here apart from the database. */
function after(rule: Rule, day: number | null, plusDays: number | null, end: string): string {
  const [y, m] = end.split('-').map(Number) as [number, number];
  // The month after the one the period ends in; Date.UTC carries December over.
  const last = new Date(Date.UTC(y, m + 1, 0)).getUTCDate();
  const chosen = rule === 'day_of_month_after_period' ? Math.min(day!, last) : last;
  const date = new Date(Date.UTC(y, m, chosen) + (plusDays ?? 0) * 86_400_000);
  return date.toISOString().slice(0, 10);
}

const paying = packWhere('names a payment day apart from its filing day', (p) =>
  p.reports.some((r) => r.deadline?.payment != null),
);
const paidForm = paying.reports.find((r) => r.deadline?.payment != null)!;

const silentPack = packWhere(
  'files a periodic return on a dated rule, and names no payment day',
  (p) =>
    p.report !== null &&
    p.report.period_default !== null &&
    p.report.deadline !== null &&
    p.report.deadline.rule !== 'depends_on_taxpayer' &&
    p.reports.every((r) => r.deadline?.payment == null),
);
const silentForm = silentPack.report!;

const WINDOW: [string, string] = ['2026-01-01', '2026-12-31'];

interface Upcoming {
  report_code: string | null;
  period_end: string | null;
  due_date: string | null;
  payment_due_date: string | null;
  instalment: number | null;
}

let db: PGlite;
let payerId: string;
let silentId: string;
let accountantId: string;

async function copyWith(pack: Pack, code: string, change: (report: Record<string, unknown>) => void): Promise<string> {
  const dir = await mkdtemp(join(tmpdir(), 'ekwo-payment-day-'));
  await cp(join(packsDir(), 'schema'), join(dir, 'schema'), { recursive: true });
  await cp(join(packsDir(), pack.slug), join(dir, pack.slug), { recursive: true });
  const file = join(dir, pack.slug, 'tax_report.json');
  const raw = JSON.parse(await readFile(file, 'utf8')) as Record<string, unknown> | Record<string, unknown>[];
  const forms = Array.isArray(raw) ? raw : [raw];
  change(forms.find((f) => f['code'] === code)!);
  await writeFile(file, JSON.stringify(raw), 'utf8');
  return dir;
}

async function upcoming(companyId: string): Promise<Upcoming[]> {
  return rows<Upcoming>(
    db,
    `select report_code, period_end::text, due_date::text, payment_due_date::text, instalment
       from upcoming_filings($1, $2::date, $3::date)`,
    [companyId, ...WINDOW],
  );
}

beforeAll(async () => {
  db = await freshDatabase();
  payerId = (await newCompany(db, { country: paying.manifest.country, name: 'Pays Later Works' })).companyId;
  silentId = (await newCompany(db, { country: silentPack.manifest.country, name: 'Pays When Filing Works' })).companyId;
  // The cadence is a fact about the company; the shortest the form accepts.
  await db.query(
    `insert into company_filing_periods (company_id, report_code, period) values ($1, $2, $3::declaration_period)
     on conflict (company_id, report_code) do update set period = excluded.period`,
    [payerId, paidForm.code, paidForm.periods[0]],
  );
  accountantId = await newUser(db);
  await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'accountant')`, [
    payerId,
    accountantId,
  ]);
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('the payment day of a declaration, in the pack', () => {
  it('is not mentioned by the seed of a pack that names none', () => {
    const silent = allPacks.filter((p) => p.reports.every((r) => r.deadline?.payment == null));
    expect(silent.length).toBeGreaterThan(0);
    for (const pack of silent) expect(compilePack(pack)).not.toMatch(/payment_rule/);
  });

  it('is read, described and compiled where the pack names one', () => {
    const payment = paidForm.deadline!.payment!;
    const described = describePack(paying).declarations.find((d) => d.code === paidForm.code)!;
    expect(described.deadline!.payment).toEqual({ rule: payment.rule, day: payment.day, plusDays: payment.plus_days });
    expect(compilePack(paying)).toMatch(/payment_rule\s+= excluded\.payment_rule/);
  });

  it('is refused beside a filing day assigned per filer, and in a shape its rule does not take', async () => {
    const perFiler = await copyWith(paying, paidForm.code, (r) => {
      const d = r['deadline'] as Record<string, unknown>;
      d['rule'] = 'depends_on_taxpayer';
      delete d['day'];
      delete d['plus_days'];
    });
    await expect(readPack(paying.slug, perFiler)).rejects.toThrow(/depends_on_taxpayer names no filing day/);

    const noDay = await copyWith(paying, paidForm.code, (r) => {
      (r['deadline'] as Record<string, unknown>)['payment'] = { rule: 'day_of_month_after_period' };
    });
    await expect(readPack(paying.slug, noDay)).rejects.toThrow(/deadline\.payment/);

    const ownText = await copyWith(paying, paidForm.code, (r) => {
      (r['deadline'] as Record<string, unknown>)['payment'] = {
        rule: 'last_day_of_month_after_period',
        legal_reference: 'a text of its own',
      };
    });
    await expect(readPack(paying.slug, ownText)).rejects.toThrow(/pack_invalid/);
  });
});

describe('the payment day of a declaration, in the database', () => {
  it('is refused by the column beside depends_on_taxpayer and in a shape its rule does not take', async () => {
    const where = [paying.manifest.country, paidForm.code];
    for (const [sql, constraint] of [
      [`update tax_report_templates set payment_rule = 'depends_on_taxpayer', payment_day = null where country = $1 and code = $2`, 'tax_report_templates_payment_shape'],
      [`update tax_report_templates set payment_rule = 'last_day_of_month_after_period', payment_day = 15 where country = $1 and code = $2`, 'tax_report_templates_payment_shape'],
      [`update tax_report_templates set payment_rule = 'day_of_month_after_period', payment_day = null where country = $1 and code = $2`, 'tax_report_templates_payment_shape'],
    ] as const) {
      expect(await expectError(db, sql, where)).toMatch(new RegExp(constraint));
    }
  });

  it('is the day the rule gives, beside the filing day, for the company and across the portfolio', async () => {
    const deadline = paidForm.deadline!;
    const payment = deadline.payment!;
    const due = (await upcoming(payerId)).filter((r) => r.report_code === paidForm.code && r.instalment === null);
    expect(due.length).toBeGreaterThan(0);
    for (const row of due) {
      expect(row.due_date).toBe(after(deadline.rule, deadline.day, deadline.plus_days, row.period_end!));
      expect(row.payment_due_date).toBe(after(payment.rule, payment.day, payment.plus_days, row.period_end!));
      expect(row.payment_due_date).not.toBe(row.due_date);
    }

    const [one] = await rows<{ day: string }>(db, `select payment_deadline($1, $2, $3::date)::text as day`, [
      payerId,
      paidForm.code,
      due[0]!.period_end,
    ]);
    expect(one!.day).toBe(due[0]!.payment_due_date);

    const listed = await asUser(db, accountantId, () =>
      rows<Upcoming & { company_id: string }>(
        db,
        `select company_id, report_code, period_end::text, due_date::text, payment_due_date::text, instalment
           from portfolio_upcoming_filings($1::date, $2::date)`,
        WINDOW,
      ),
    );
    const mine = listed.filter((r) => r.company_id === payerId && r.report_code === paidForm.code);
    expect(mine.length).toBeGreaterThan(0);
    for (const row of mine) {
      expect(row.payment_due_date).toBe(after(payment.rule, payment.day, payment.plus_days, row.period_end!));
    }
  });

  it('is none on a form that names one day for both', async () => {
    const deadline = silentForm.deadline!;
    const due = (await upcoming(silentId)).filter((r) => r.report_code === silentForm.code && r.instalment === null);
    expect(due.length).toBeGreaterThan(0);
    for (const row of due) {
      expect(row.due_date).toBe(after(deadline.rule, deadline.day, deadline.plus_days, row.period_end!));
      expect(row.payment_due_date).toBeNull();
    }
  });
});
