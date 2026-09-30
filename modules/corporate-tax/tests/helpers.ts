import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import type { PGlite } from '@electric-sql/pglite';
import { asUser, one, rows } from '../../../tests/helpers/db.js';
import { newCompany, type Fixture } from '../../../tests/helpers/factory.js';
import type { Pack } from '../../../packages/cli/src/index.js';

/** One line of `tax.estimate()`, amounts as the database writes them. */
export interface EstimateLine {
  sequence: number;
  kind: string;
  code: string | null;
  name: string | null;
  base: string | null;
  rate: string | null;
  amount: string | null;
  legal_reference: string | null;
  source_key: string | null;
}

export interface GoldenLine {
  kind: string;
  code?: string | null;
  note?: string | null;
  base?: string | null;
  rate?: string | null;
  amount?: string | null;
}

export interface GoldenCompany {
  ref: string;
  name: string;
  why: string;
  entries: { date: string; description: string; lines: { account: string; debit?: string; credit?: string }[] }[];
  parameters?: Record<string, boolean | string>;
  adjustments?: { rule: string; account?: string; amount?: string; parameters?: Record<string, unknown> }[];
  losses?: { origin_period_end: string; amount: string }[];
  expected: { computation: string[]; lines: GoldenLine[]; tax: string };
}

export interface GoldenCorporateTax {
  fiscal_year: { name: string; start: string; end: string };
  companies: GoldenCompany[];
}

/** `packs/<cc>/golden/corporate_tax.json`, the worked examples a pack ships beside its section. */
export function goldenOf(pack: Pack): GoldenCorporateTax {
  return JSON.parse(readFileSync(join(pack.dir, 'golden', 'corporate_tax.json'), 'utf8')) as GoldenCorporateTax;
}

/**
 * A decimal string without the zeros that say nothing: `100000.00`, `100000`
 * and `100000.0` are one amount. Compared as text, so nothing here is a float.
 */
export function decimal(value: string | null | undefined): string | null {
  if (value === null || value === undefined) return null;
  const [whole, fraction = ''] = value.split('.');
  const trimmed = fraction.replace(/0+$/, '');
  const text = trimmed === '' ? (whole as string) : `${whole as string}.${trimmed}`;
  return text === '-0' ? '0' : text;
}

/** What a test compares of a line: its kind, its code, and its three figures. */
export function figures(line: EstimateLine | GoldenLine): Record<string, string | null> {
  return {
    kind: line.kind,
    code: line.code ?? null,
    base: decimal(line.base),
    rate: decimal(line.rate),
    amount: decimal(line.amount),
  };
}

/** A company of a pack's country with the module on, as its owner enabled it. */
export async function taxCompany(
  db: PGlite,
  country: string,
  name: string,
  fiscalYear: { name: string; start: string; end: string },
): Promise<Fixture & { fiscalYearId: string }> {
  const fixture = await newCompany(db, { country, name, fiscalYear });
  await asUser(db, fixture.ownerId, async () => {
    await db.query(`select enable_module($1, 'tax')`, [fixture.companyId]);
  });
  const year = await one<{ id: string }>(
    db,
    `select id from fiscal_years where company_id = $1 and start_date = $2::date`,
    [fixture.companyId, fiscalYear.start],
  );
  return { ...fixture, fiscalYearId: year.id };
}

/** Books one journal entry on the miscellaneous journal the pack names, and posts it. */
export async function book(
  db: PGlite,
  companyId: string,
  entry: { date: string; description: string; lines: { account: string; debit?: string; credit?: string }[] },
): Promise<string> {
  const row = await one<{ id: string }>(
    db,
    `insert into entries (company_id, journal_id, entry_date, description, state)
     select c.id, j.id, $2::date, $3, 'draft'
       from companies c
       join country_defaults d on d.country = c.fiscal_country
       join journals j on j.company_id = c.id and j.code = d.misc_journal_code
      where c.id = $1
     returning id`,
    [companyId, entry.date, entry.description],
  );
  let sequence = 0;
  for (const line of entry.lines) {
    sequence += 10;
    await db.query(
      `insert into entry_lines (entry_id, company_id, account_id, sequence, debit, credit)
       values ($1, $2, account_id_by_code($2, $3), $4, $5::numeric, $6::numeric)`,
      [row.id, companyId, line.account, sequence, line.debit ?? '0', line.credit ?? '0'],
    );
  }
  await db.query(`select post_entry($1)`, [row.id]);
  return row.id;
}

/** Declares what a worked example declares: parameters, adjustments and the losses carried in. */
export async function declare(
  db: PGlite,
  fixture: Fixture & { fiscalYearId: string },
  company: Pick<GoldenCompany, 'parameters' | 'adjustments' | 'losses'>,
): Promise<void> {
  await asUser(db, fixture.ownerId, async () => {
    for (const [code, value] of Object.entries(company.parameters ?? {})) {
      await db.query(
        `insert into tax.company_parameters (company_id, fiscal_year_id, code, value_boolean, value_amount)
         values ($1, $2, $3, $4::boolean, $5::numeric)`,
        [
          fixture.companyId,
          fixture.fiscalYearId,
          code,
          typeof value === 'boolean' ? value : null,
          typeof value === 'boolean' ? null : value,
        ],
      );
    }
    for (const adjustment of company.adjustments ?? []) {
      await db.query(
        `insert into tax.adjustments (company_id, fiscal_year_id, rule_code, account_id, amount, parameters)
         values ($1, $2, $3, account_id_by_code($1, $4), $5::numeric, $6::jsonb)`,
        [
          fixture.companyId,
          fixture.fiscalYearId,
          adjustment.rule,
          adjustment.account ?? null,
          adjustment.amount ?? null,
          JSON.stringify(adjustment.parameters ?? {}),
        ],
      );
    }
    for (const loss of company.losses ?? []) {
      await db.query(
        `insert into tax.losses (company_id, origin_period_end, amount) values ($1, $2::date, $3::numeric)`,
        [fixture.companyId, loss.origin_period_end, loss.amount],
      );
    }
  });
}

/** `tax.estimate()` as a member of the company asks for it. */
export async function estimate(
  db: PGlite,
  fixture: Fixture & { fiscalYearId: string },
  at: string | null = null,
): Promise<EstimateLine[]> {
  return asUser(db, fixture.ownerId, () =>
    rows<EstimateLine>(
      db,
      `select sequence, kind, code, name, base::text, rate::text, amount::text, legal_reference, source_key
         from tax.estimate($1, $2, $3::date) order by sequence`,
      [fixture.companyId, fixture.fiscalYearId, at],
    ),
  );
}

/** The packs of this repository that carry a `corporate_tax` section. */
export function taxPacks(packs: Pack[]): Pack[] {
  return packs.filter((pack) => pack.corporateTax !== null);
}

type Section = NonNullable<Pack['corporateTax']>;

/** The rate of a pack that takes the whole base unconditionally, in force on a day. */
export function ordinaryRate(section: Section, day: string): Section['rates'][number] {
  const rate = section.rates.find(
    (r) => r.up_to === null && r.conditions.length === 0 && r.valid_from <= day && (r.valid_to === null || r.valid_to >= day),
  );
  if (rate === undefined) throw new Error(`no unconditional rate in force on ${day}`);
  return rate;
}

/** The rate with a threshold in force for a financial year, read the way the pack says. */
export function thresholdRate(
  section: Section,
  year: { start: string; end: string },
): Section['rates'][number] | undefined {
  return section.rates.find((r) => {
    const day = r.valid_on === 'period_end' ? year.end : year.start;
    return r.up_to !== null && r.valid_from <= day && (r.valid_to === null || r.valid_to >= day);
  });
}

/**
 * What a company has to declare for every condition of a rate to be met,
 * derived from the conditions themselves: true where one asks is_true, the
 * amount where one compares. A test that wrote the parameters by hand would
 * be a test of one country.
 */
export function meeting(rate: Section['rates'][number]): Record<string, boolean | string> {
  const out: Record<string, boolean | string> = {};
  for (const condition of rate.conditions) {
    switch (condition.test) {
      case 'is_true':
        out[condition.parameter] = true;
        break;
      case 'is_false':
        out[condition.parameter] = false;
        break;
      case 'at_least':
      case 'at_most':
        out[condition.parameter] = String(condition.amount);
        break;
      case 'below':
        out[condition.parameter] = String((condition.amount ?? 0) - 1);
        break;
      case 'above':
        out[condition.parameter] = String((condition.amount ?? 0) + 1);
        break;
    }
  }
  return out;
}

/** An account of the pack's default chart nothing is a parent of, by type, first in the chart's own order. */
export function leafAccount(pack: Pack, type: string): string {
  const parents = new Set(pack.accounts.map((a) => a.parent).filter((p): p is string => p !== null));
  const account = [...pack.accounts]
    .sort((a, b) => a.sequence - b.sequence)
    .find((a) => a.type === type && !parents.has(a.code));
  if (account === undefined) throw new Error(`packs/${pack.slug} has no leaf account of type ${type}`);
  return account.code;
}

/** Books an income against cash: the simplest profit a chart can carry. */
export async function earn(db: PGlite, pack: Pack, companyId: string, date: string, amount: string): Promise<string> {
  return book(db, companyId, {
    date,
    description: 'Income',
    lines: [
      { account: leafAccount(pack, 'asset_cash'), debit: amount },
      { account: leafAccount(pack, 'income'), credit: amount },
    ],
  });
}

/** Books an expense against cash. */
export async function spend(db: PGlite, pack: Pack, companyId: string, date: string, amount: string): Promise<string> {
  return book(db, companyId, {
    date,
    description: 'Expense',
    lines: [
      { account: leafAccount(pack, 'expense'), debit: amount },
      { account: leafAccount(pack, 'asset_cash'), credit: amount },
    ],
  });
}

/** `amount × percent / 100`, to the cent, without a float in the way. */
export function share(amount: string, percent: number): string {
  const [whole, fraction = ''] = amount.split('.');
  const cents = BigInt(`${whole as string}${fraction.padEnd(2, '0').slice(0, 2)}`);
  // Percentages of a pack carry at most six decimals.
  const millionths = BigInt(Math.round(percent * 1_000_000));
  const scaled = cents * millionths; // cents × 10^6 × percent
  const divisor = 100_000_000n;
  const rounded = (scaled * 2n + divisor) / (divisor * 2n);
  const text = rounded.toString().padStart(3, '0');
  return `${text.slice(0, -2)}.${text.slice(-2)}`;
}
