import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from '../../../tests/helpers/db.js';
import { newCompany } from '../../../tests/helpers/factory.js';
import { allPacks } from '../../../tests/helpers/packs.js';
import { installFixturePack } from '../../../tests/helpers/fixture-pack.js';
import {
  book,
  decimal,
  declare,
  earn,
  estimate,
  leafAccount,
  meeting,
  ordinaryRate,
  share,
  spend,
  taxCompany,
  taxPacks,
  thresholdRate,
} from './helpers.js';

// The `tax` module apart from its worked examples, which `golden.test.ts`
// replays per country. Everything here is about the engine, so nothing here
// expects a country: a test takes the first pack that carries what it needs —
// a rate with conditions, a threshold shared out over months, a rule with a
// formula — and works its expectation out from that pack's own figures.

const packs = taxPacks(allPacks);
const YEAR = { name: 'Year 2025', start: '2025-01-01', end: '2025-12-31' };
const NEXT = { name: 'Year 2026', start: '2026-01-01', end: '2026-12-31' };

/** A pack whose reduced rate is in force for the year the tests book in. */
const pack = packs.find((p) => thresholdRate(p.corporateTax!, YEAR) !== undefined)!;
const section = pack.corporateTax!;
const country = pack.manifest.country;
const reduced = thresholdRate(section, YEAR)!;
const ordinary = ordinaryRate(section, YEAR.start);

let db: PGlite;

beforeAll(async () => {
  db = await freshDatabase();
}, 300_000);

afterAll(async () => {
  await db.close();
});

const amountOf = (lines: { kind: string; amount: string | null }[], kind: string): string | null =>
  decimal(lines.find((line) => line.kind === kind)?.amount);

// --------------------------------------------------------- the vocabulary

describe('reading a rule', () => {
  it('reads a validity on the first or the last day of the year, as the rule says', async () => {
    const asked = await one<{ opened: boolean; closed: boolean; ended: boolean }>(
      db,
      `select tax.in_force(date '2025-07-01', null, 'period_start', date '2025-01-01', date '2025-12-31') as opened,
              tax.in_force(date '2025-07-01', null, 'period_end',   date '2025-01-01', date '2025-12-31') as closed,
              tax.in_force(date '2024-01-01', date '2025-06-30', 'period_end', date '2025-01-01', date '2025-12-31') as ended`,
    );
    // Opened before the rule began, closed after it: the two readings differ,
    // which is the whole reason the rule says which one it is.
    expect(asked).toEqual({ opened: false, closed: true, ended: false });
  });

  it('matches an account the way a statement line does', async () => {
    const asked = await one<{ code: boolean; prefix: boolean; range: boolean; outside: boolean; none: boolean }>(
      db,
      `select tax.account_matches('671200', '[{"kind":"account_code","code_from":"671200"}]') as code,
              tax.account_matches('695100', '[{"kind":"code_prefix","code_from":"695"}]') as prefix,
              tax.account_matches('771000', '[{"kind":"code_range","code_from":"67","code_to":"77"}]') as range,
              tax.account_matches('780000', '[{"kind":"code_range","code_from":"67","code_to":"77"}]') as outside,
              tax.account_matches('671200', '[]') as none`,
    );
    expect(asked).toEqual({ code: true, prefix: true, range: true, outside: false, none: false });
  });

  it('works a percentage out of a straight line, its bounds and its steps', async () => {
    // The shape a pack gives an expense that is accepted less as it emits
    // more: a deductible share of 120 − 0,5 × coefficient × the variable,
    // rounded to a tenth, never under 50 nor over 100, and 40 from 200 up.
    const formula = JSON.stringify({
      yields: 'deductible_percent',
      variable: 'grams',
      intercept: 120,
      slope: -0.5,
      coefficient: { parameter: 'kind', values: { heavy: 1, light: 0.95 } },
      decimals: 1,
      min: 50,
      max: 100,
      steps: [{ from: 200, percent: 40 }],
    });
    const percent = async (parameters: Record<string, unknown>): Promise<string | null> =>
      decimal(
        (
          await one<{ p: string }>(db, `select tax.formula_percent($1::jsonb, $2::jsonb)::text as p`, [
            formula,
            JSON.stringify(parameters),
          ])
        ).p,
      );

    // 120 − 55 = 65 deductible, so 35 is moved.
    expect(await percent({ grams: 110, kind: 'heavy' })).toBe('35');
    // 120 − 0,475 × 101 = 72,025, rounded to 72,0: 28 is moved.
    expect(await percent({ grams: 101, kind: 'light' })).toBe('28');
    // 120 − 10 = 110, held at 100: nothing is moved.
    expect(await percent({ grams: 20, kind: 'heavy' })).toBe('0');
    // 120 − 95 = 25, held at 50.
    expect(await percent({ grams: 190, kind: 'heavy' })).toBe('50');
    // The step replaces the line from 200 upwards: 40 deductible, 60 moved.
    expect(await percent({ grams: 200, kind: 'heavy' })).toBe('60');

    expect(
      await expectError(db, `select tax.formula_percent($1::jsonb, '{"kind":"heavy"}'::jsonb)`, [formula]),
    ).toMatch(/adjustment_parameter_missing: .* grams/);
    expect(
      await expectError(db, `select tax.formula_percent($1::jsonb, '{"grams":100,"kind":"steam"}'::jsonb)`, [formula]),
    ).toMatch(/adjustment_parameter_unknown: steam .* heavy, light/);
  });

  it('never assumes a parameter nobody declared, and lets a declaration lift a condition', async () => {
    const failure = async (condition: object, values: object, base = 0): Promise<string | null> =>
      (
        await one<{ f: string | null }>(db, `select tax.condition_failure($1::jsonb, $2::jsonb, $3::numeric) as f`, [
          JSON.stringify(condition),
          JSON.stringify(values),
          base,
        ])
      ).f;

    expect(await failure({ parameter: 'small', test: 'is_true' }, {})).toBe('not_declared: small');
    expect(await failure({ parameter: 'small', test: 'is_true' }, { small: false })).toBe('not_met: small');
    expect(await failure({ parameter: 'small', test: 'is_true' }, { small: true })).toBeNull();
    expect(await failure({ parameter: 'paid', test: 'at_least', amount: 45000 }, { paid: 45000 })).toBeNull();
    expect(await failure({ parameter: 'paid', test: 'at_least', amount: 45000 }, { paid: 44999.99 })).toBe('not_met: paid');
    expect(await failure({ parameter: 'sales', test: 'at_most', amount: 100 }, { sales: 100 })).toBeNull();
    expect(await failure({ parameter: 'sales', test: 'below', amount: 100 }, { sales: 100 })).toBe('not_met: sales');

    // Below the threshold and still at least the base of the year.
    const alternative = { parameter: 'paid', test: 'at_least', amount: 45000, or_at_least: 'taxable_base' };
    expect(await failure(alternative, { paid: 30000 }, 25000)).toBeNull();
    expect(await failure(alternative, { paid: 30000 }, 30000.01)).toBe('not_met: paid');

    // A waiver declared true lifts the condition, even one nobody answered.
    const waived = { parameter: 'paid', test: 'at_least', amount: 45000, waived_by: ['starting', 'cooperative'] };
    expect(await failure(waived, { cooperative: true })).toBeNull();
    expect(await failure(waived, { starting: false })).toBe('not_declared: paid');

    expect(await expectError(db, `select tax.condition_failure('{"parameter":"x","test":"roughly"}', '{"x":1}', 0)`)).toMatch(
      /unknown_condition_test/,
    );
  });
});

// ------------------------------------------------------------ the estimate

describe('an estimate', () => {
  it('reads the ledger up to the day it is asked for, and the whole year when no day is given', async () => {
    const fixture = await taxCompany(db, country, 'At a date', YEAR);
    await earn(db, pack, fixture.companyId, '2025-03-15', '10000.00');
    await earn(db, pack, fixture.companyId, '2025-09-15', '5000.00');

    const march = await estimate(db, fixture, '2025-03-31');
    expect(amountOf(march, 'accounting_result')).toBe('10000');
    expect(amountOf(march, 'estimated_tax')).toBe(decimal(share('10000.00', ordinary.rate)));

    const year = await estimate(db, fixture);
    expect(amountOf(year, 'accounting_result')).toBe('15000');
    // A day after the year ends reads the year, and no further.
    expect((await estimate(db, fixture, '2030-01-01')).map((l) => l.amount)).toEqual(year.map((l) => l.amount));

    const before = await asUser(db, fixture.ownerId, () =>
      expectError(db, `select * from tax.estimate($1, $2, date '2024-12-31')`, [fixture.companyId, fixture.fiscalYearId]),
    );
    expect(before).toMatch(/estimate_before_period/);
  });

  it('still reads a year that has been closed', async () => {
    // The closing entry empties every income and expense account. The
    // statement the estimate starts from leaves that entry out, so the year
    // reads after its close as it read before.
    const fixture = await taxCompany(db, country, 'Closed year', YEAR);
    await earn(db, pack, fixture.companyId, '2025-05-02', '20000.00');
    await spend(db, pack, fixture.companyId, '2025-05-03', '8000.00');
    const open = await estimate(db, fixture);
    await db.query(`select close_fiscal_year($1)`, [fixture.fiscalYearId]);
    const closed = await estimate(db, fixture);
    expect(amountOf(open, 'accounting_result')).toBe('12000');
    expect(closed.map((l) => [l.kind, l.code, l.amount])).toEqual(open.map((l) => [l.kind, l.code, l.amount]));
  });

  it('does not apply a rate whose condition nobody declared, and says which one', async () => {
    const fixture = await taxCompany(db, country, 'Nothing declared', YEAR);
    await earn(db, pack, fixture.companyId, '2025-03-15', '10000.00');

    const lines = await estimate(db, fixture);
    const refused = lines.find((l) => l.kind === 'rate_not_applied');
    expect(refused?.code).toBe(reduced.code);
    expect(refused?.name).toBe(`not_declared: ${reduced.conditions[0]?.parameter}`);
    expect(refused?.amount).toBeNull();
    // Everything at the ordinary rate, then.
    expect(amountOf(lines, 'estimated_tax')).toBe(decimal(share('10000.00', ordinary.rate)));

    // Declared, the same books are taxed at the reduced rate: the base is
    // under the threshold, so one slice and one rate.
    await declare(db, fixture, { parameters: meeting(reduced) });
    const declared = await estimate(db, fixture);
    expect(declared.filter((l) => l.kind === 'rate').map((l) => l.code)).toEqual([reduced.code]);
    expect(amountOf(declared, 'estimated_tax')).toBe(decimal(share('10000.00', reduced.rate)));
  });

  it('shares a threshold out over the months of a year that is not twelve, where the pack says so', async () => {
    const prorated = packs.find((p) =>
      p.corporateTax!.rates.some((r) => r.up_to_prorata === 'months' && thresholdRate(p.corporateTax!, YEAR) === r),
    );
    expect(prorated, 'no pack shares a threshold out over months').toBeDefined();
    const rate = thresholdRate(prorated!.corporateTax!, YEAR)!;
    const top = ordinaryRate(prorated!.corporateTax!, '2025-07-01');

    // Six months, so half the threshold; the profit is the whole threshold.
    const half = { name: 'Second half of 2025', start: '2025-07-01', end: '2025-12-31' };
    const fixture = await taxCompany(db, prorated!.manifest.country, 'Six months', half);
    const profit = `${rate.up_to}.00`;
    await earn(db, prorated!, fixture.companyId, '2025-09-15', profit);
    await declare(db, fixture, { parameters: meeting(rate) });

    const slices = (await estimate(db, fixture)).filter((l) => l.kind === 'rate');
    const cap = share(profit, 50);
    expect(slices.map((l) => [l.code, decimal(l.base), decimal(l.amount)])).toEqual([
      [rate.code, decimal(cap), decimal(share(cap, rate.rate))],
      [top.code, decimal(cap), decimal(share(cap, top.rate))],
    ]);
  });

  it('reads the base of a rule from an account the company names, once', async () => {
    // An account named by the company is taken out of what the pack's own
    // account rules catch, so an expense is never added back twice — and its
    // balance is read from the ledger each time, so the estimate moves with it.
    const rule = section.adjustment_rules.find((r) => r.percent !== null && r.direction === 'add_back')!;
    const fixture = await taxCompany(db, country, 'Named account', YEAR);
    const expense = leafAccount(pack, 'expense');
    await earn(db, pack, fixture.companyId, '2025-02-01', '50000.00');
    await spend(db, pack, fixture.companyId, '2025-02-02', '1000.00');
    await declare(db, fixture, { adjustments: [{ rule: rule.code, account: expense }] });

    const first = (await estimate(db, fixture)).filter((l) => l.kind === 'adjustment' && l.code === rule.code);
    expect(first.map((l) => [decimal(l.base), decimal(l.amount)])).toEqual([
      ['1000', decimal(share('1000.00', rule.percent!))],
    ]);
    expect(first[0]?.legal_reference).toBe(rule.legal_reference);
    expect(first[0]?.source_key).toBe(rule.source);

    await spend(db, pack, fixture.companyId, '2025-02-03', '500.00');
    const second = (await estimate(db, fixture)).filter((l) => l.kind === 'adjustment' && l.code === rule.code);
    expect(second.map((l) => decimal(l.base))).toEqual(['1500']);

    const inUse = await rows<{ code: string }>(
      db,
      `select a.code from tax.accounts_in_use($1) u join accounts a on a.id = u`,
      [fixture.companyId],
    );
    expect(inUse.map((a) => a.code)).toEqual([expense]);
  });

  it('says so when a rule or a credit the company named is not in force for the year', async () => {
    // Reference rows a test owns: a rule and a credit that begin in a far year.
    await db.query(
      `insert into tax.adjustment_rule_templates (country, code, valid_from, name, direction, percent, legal_reference)
       values ($1, 'test-later-rule', date '2999-01-01', 'A rule of a later year', 'add_back', 100, 'test')`,
      [country],
    );
    await db.query(
      `insert into tax.credit_templates (country, code, valid_from, name, refundable, legal_reference, sequence)
       values ($1, 'test-later-credit', date '2999-01-01', 'A credit of a later year', false, 'test', 10)`,
      [country],
    );
    const fixture = await taxCompany(db, country, 'Not in force', YEAR);
    await earn(db, pack, fixture.companyId, '2025-02-01', '10000.00');
    await declare(db, fixture, { adjustments: [{ rule: 'test-later-rule', amount: '700.00' }] });
    await asUser(db, fixture.ownerId, async () => {
      await db.query(
        `insert into tax.credits (company_id, fiscal_year_id, credit_code, amount) values ($1, $2, 'test-later-credit', 50)`,
        [fixture.companyId, fixture.fiscalYearId],
      );
    });

    const lines = await estimate(db, fixture);
    expect(lines.filter((l) => l.kind.endsWith('_not_applied') && l.kind !== 'rate_not_applied').map((l) => [l.kind, l.code, l.name])).toEqual([
      ['adjustment_not_applied', 'test-later-rule', 'rule_not_in_force'],
      ['credit_not_applied', 'test-later-credit', 'credit_not_in_force'],
    ]);
    // Neither moved the figure.
    expect(amountOf(lines, 'fiscal_result')).toBe('10000');
    expect(amountOf(lines, 'estimated_tax')).toBe(decimal(share('10000.00', ordinary.rate)));
  });

  it('sets a credit against the tax: one that is not paid back stops at the tax, one that is goes below', async () => {
    await db.query(
      `insert into tax.credit_templates (country, code, valid_from, name, refundable, legal_reference, sequence)
       values ($1, 'test-kept', date '2000-01-01', 'A credit that is not paid back', false, 'test article A', 10),
              ($1, 'test-paid-back', date '2000-01-01', 'A credit that is paid back', true, 'test article B', 20)`,
      [country],
    );
    const fixture = await taxCompany(db, country, 'Credits', YEAR);
    await earn(db, pack, fixture.companyId, '2025-02-01', '1000.00');
    const tax = share('1000.00', ordinary.rate);
    await asUser(db, fixture.ownerId, async () => {
      await db.query(
        `insert into tax.credits (company_id, fiscal_year_id, credit_code, amount)
         values ($1, $2, 'test-paid-back', 40), ($1, $2, 'test-kept', 100000)`,
        [fixture.companyId, fixture.fiscalYearId],
      );
    });

    const lines = await estimate(db, fixture);
    expect(amountOf(lines, 'tax_before_credits')).toBe(decimal(tax));
    expect(lines.filter((l) => l.kind === 'credit').map((l) => [l.code, decimal(l.base), decimal(l.amount), l.legal_reference])).toEqual([
      // The one that is not paid back first, and only as far as the tax.
      ['test-kept', '100000', decimal(`-${tax}`), 'test article A'],
      ['test-paid-back', '40', '-40', 'test article B'],
    ]);
    expect(amountOf(lines, 'estimated_tax')).toBe('-40');
  });

  it('refuses by name what the pack does not say', async () => {
    // A country whose pack carries no section.
    const silent = allPacks.find((p) => p.corporateTax === null)!;
    const without = await taxCompany(db, silent.manifest.country, 'No section', YEAR);
    expect(
      await asUser(db, without.ownerId, () =>
        expectError(db, `select * from tax.estimate($1, $2)`, [without.companyId, without.fiscalYearId]),
      ),
    ).toMatch(new RegExp(`no_corporate_tax_rules: the country pack of ${silent.manifest.country}`));

    // A chart of the country that does not report on the statement the rules start from.
    const other = packs
      .flatMap((p) => p.charts.map((chart) => ({ p, chart })))
      .find(({ p, chart }) => !chart.statements.includes(p.corporateTax!.result.statement));
    if (other !== undefined) {
      const company = await newCompany(db, {
        country: other.p.manifest.country,
        name: 'Another chart',
        chart: other.chart.code,
        fiscalYear: YEAR,
      });
      await asUser(db, company.ownerId, async () => {
        await db.query(`select enable_module($1, 'tax')`, [company.companyId]);
      });
      const year = await one<{ id: string }>(db, `select id from fiscal_years where company_id = $1`, [company.companyId]);
      expect(
        await asUser(db, company.ownerId, () =>
          expectError(db, `select * from tax.estimate($1, $2)`, [company.companyId, year.id]),
        ),
      ).toMatch(/no_result_statement/);
    }

    // A year before any rate of the pack: a profit and nothing to tax it with.
    const early = { name: 'Year 1990', start: '1990-01-01', end: '1990-12-31' };
    const old = await taxCompany(db, country, 'Before the rates', early);
    await earn(db, pack, old.companyId, '1990-06-01', '1000.00');
    expect(
      await asUser(db, old.ownerId, () =>
        expectError(db, `select * from tax.estimate($1, $2)`, [old.companyId, old.fiscalYearId]),
      ),
    ).toMatch(/no_rate_in_force/);

    // A formula that is not told what it needs.
    const formulaPack = packs.find((p) => p.corporateTax!.adjustment_rules.some((r) => r.formula !== null));
    expect(formulaPack, 'no pack carries a rule with a formula').toBeDefined();
    const formulaRule = formulaPack!.corporateTax!.adjustment_rules.find((r) => {
      const day = r.valid_on === 'period_end' ? YEAR.end : YEAR.start;
      return r.formula !== null && r.valid_from <= day && (r.valid_to === null || r.valid_to >= day);
    })!;
    // Refused when the adjustment is written, so that one careless line does
    // not stop the estimate of a whole year later on.
    const car = await taxCompany(db, formulaPack!.manifest.country, 'Formula', YEAR);
    const variable = String(formulaRule.formula!['variable']);
    const stated = (parameters: Record<string, unknown>): Promise<string> =>
      asUser(db, car.ownerId, () =>
        expectError(
          db,
          `insert into tax.adjustments (company_id, fiscal_year_id, rule_code, amount, parameters)
           values ($1, $2, $3, 100, $4::jsonb)`,
          [car.companyId, car.fiscalYearId, formulaRule.code, JSON.stringify(parameters)],
        ),
      );
    expect(await stated({})).toMatch(new RegExp(`adjustment_parameter_missing: .* ${variable}`));
    expect(await stated({ [variable]: 'a lot' })).toMatch(new RegExp(`adjustment_parameter_type: ${variable} is a number`));
  });

  it('refuses two versions of one rule in force for the same year, which a seed can leave behind', async () => {
    // A seed only ever adds. A pack that moved the valid_from of a rule leaves
    // the earlier row where it was, open-ended, and both would apply.
    const fixture = await taxCompany(db, country, 'Two versions', YEAR);
    await earn(db, pack, fixture.companyId, '2025-02-01', '1000.00');
    await db.query(
      `insert into tax.adjustment_rule_templates (country, code, valid_from, name, direction, percent, legal_reference)
       values ($1, 'test-twice', date '2001-01-01', 'Left behind', 'add_back', 100, 'test'),
              ($1, 'test-twice', date '2002-01-01', 'Its successor', 'add_back', 100, 'test')`,
      [country],
    );
    try {
      expect(
        await asUser(db, fixture.ownerId, () =>
          expectError(db, `select * from tax.estimate($1, $2)`, [fixture.companyId, fixture.fiscalYearId]),
        ),
      ).toMatch(/rule_versions_overlap: .* adjustment rule test-twice/);
    } finally {
      await db.query(`delete from tax.adjustment_rule_templates where code = 'test-twice'`);
    }
  });
});

// ------------------------------------------------------- what is declared

describe('what a company declares', () => {
  it('is held to the codes of its country pack, to their type and to its own years', async () => {
    const fixture = await taxCompany(db, country, 'Declarations', YEAR);
    const stranger = await taxCompany(db, country, 'Somebody else', YEAR);
    const boolean = section.parameters.find((p) => p.type === 'boolean')!;
    const amount = section.parameters.find((p) => p.type === 'amount')!;

    const refused = async (sql: string, params: unknown[]): Promise<string> =>
      asUser(db, fixture.ownerId, () => expectError(db, sql, params));

    expect(
      await refused(
        `insert into tax.company_parameters (company_id, fiscal_year_id, code, value_boolean) values ($1, $2, 'not_a_parameter', true)`,
        [fixture.companyId, fixture.fiscalYearId],
      ),
    ).toMatch(/unknown_tax_parameter: not_a_parameter/);
    expect(
      await refused(
        `insert into tax.company_parameters (company_id, fiscal_year_id, code, value_amount) values ($1, $2, $3, 12)`,
        [fixture.companyId, fixture.fiscalYearId, boolean.code],
      ),
    ).toMatch(/tax_parameter_type: .* boolean/);
    expect(
      await refused(
        `insert into tax.company_parameters (company_id, fiscal_year_id, code, value_boolean) values ($1, $2, $3, true)`,
        [fixture.companyId, fixture.fiscalYearId, amount.code],
      ),
    ).toMatch(/tax_parameter_type: .* amount/);
    expect(
      await refused(
        `insert into tax.company_parameters (company_id, fiscal_year_id, code, value_boolean) values ($1, $2, $3, true)`,
        [fixture.companyId, stranger.fiscalYearId, boolean.code],
      ),
    ).toMatch(/unknown_fiscal_year/);
    expect(
      await refused(
        `insert into tax.adjustments (company_id, fiscal_year_id, rule_code, amount) values ($1, $2, 'not-a-rule', 10)`,
        [fixture.companyId, fixture.fiscalYearId],
      ),
    ).toMatch(/unknown_adjustment_rule: not-a-rule/);
    expect(
      await refused(
        `insert into tax.credits (company_id, fiscal_year_id, credit_code, amount) values ($1, $2, 'not-a-credit', 10)`,
        [fixture.companyId, fixture.fiscalYearId],
      ),
    ).toMatch(/unknown_tax_credit: not-a-credit/);
    // An amount with no year, and an adjustment that is both or neither.
    const rule = section.adjustment_rules[0]!.code;
    expect(
      await refused(`insert into tax.adjustments (company_id, rule_code, amount) values ($1, $2, 10)`, [
        fixture.companyId,
        rule,
      ]),
    ).toMatch(/tax_adjustments_amount_has_year/);
    expect(
      await refused(`insert into tax.adjustments (company_id, fiscal_year_id, rule_code) values ($1, $2, $3)`, [
        fixture.companyId,
        fixture.fiscalYearId,
        rule,
      ]),
    ).toMatch(/tax_adjustments_account_or_amount/);
  });

  it('is written at the decimals of the company currency', async () => {
    const fixture = await taxCompany(db, country, 'Decimals', YEAR);
    const amount = section.parameters.find((p) => p.type === 'amount')!;
    await declare(db, fixture, {
      parameters: { [amount.code]: '1234.5678' },
      losses: [{ origin_period_end: '2024-12-31', amount: '99.999' }],
    });
    const stored = await one<{ parameter: string; loss: string; decimals: number }>(
      db,
      `select (select value_amount::text from tax.company_parameters where company_id = $1) as parameter,
              (select amount::text from tax.losses where company_id = $1) as loss,
              (rounding_of($1)).decimals::integer as decimals`,
      [fixture.companyId],
    );
    expect(stored.parameter).toBe((1234.5678).toFixed(stored.decimals));
    expect(stored.loss).toBe((99.999).toFixed(stored.decimals));
  });
});

// ------------------------------------------- kept, final, and the losses

describe('a computation that is kept', () => {
  it('is an estimate until an owner calls it final, and the losses follow the final ones', async () => {
    const fixture = await taxCompany(db, country, 'Two years', YEAR);
    await db.query(
      `insert into fiscal_years (company_id, name, start_date, end_date) values ($1, $2, $3::date, $4::date)`,
      [fixture.companyId, NEXT.name, NEXT.start, NEXT.end],
    );
    const next = await one<{ id: string }>(
      db,
      `select id from fiscal_years where company_id = $1 and start_date = $2::date`,
      [fixture.companyId, NEXT.start],
    );
    const accountant = crypto.randomUUID();
    await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'accountant')`, [
      fixture.companyId,
      accountant,
    ]);
    const record = (user: string, year: string, at: string | null = null): Promise<string> =>
      asUser(db, user, async () =>
        (
          await one<{ id: string }>(db, `select tax.record_computation($1, $2, $3::date) as id`, [
            fixture.companyId,
            year,
            at,
          ])
        ).id,
      );
    const computation = (id: string): Promise<{ version: number; status: string; tax: string; loss: string; at: string; last: string }> =>
      one(
        db,
        `select c.version, c.status::text, c.tax::text, c.loss_of_period::text as loss, c.computed_at::text as at,
                (select l.kind from tax.computation_lines l where l.computation_id = c.id order by l.sequence desc limit 1) as last
           from tax.computations c where c.id = $1`,
        [id],
      );

    // Year one ends 4 000 below zero.
    await earn(db, pack, fixture.companyId, '2025-04-01', '6000.00');
    await spend(db, pack, fixture.companyId, '2025-04-02', '10000.00');

    // An accountant records; the first one is of a part of the year.
    const partial = await record(accountant, fixture.fiscalYearId, '2025-04-01');
    // On 1 April only the income is in the books: the estimate is a tax on it.
    expect(await computation(partial)).toEqual({
      version: 1,
      status: 'estimate',
      tax: share('6000.00', ordinary.rate),
      loss: '0',
      at: '2025-04-01',
      last: 'estimated_tax',
    });
    const whole = await record(accountant, fixture.fiscalYearId);
    expect(await computation(whole)).toMatchObject({ version: 2, status: 'estimate', at: YEAR.end });
    expect(decimal((await computation(whole)).loss)).toBe('4000');

    // Calling it final is not the accountant's to do.
    expect(
      await asUser(db, accountant, () => expectError(db, `select tax.finalise_computation($1)`, [whole])),
    ).toMatch(/not_allowed: .* tax\.finalize/);
    // Nor is a part of a year, or a version that is no longer the latest.
    expect(
      await asUser(db, fixture.ownerId, () => expectError(db, `select tax.finalise_computation($1)`, [partial])),
    ).toMatch(/computation_not_whole_year/);

    // The books move after the recording: the recorded computation is history.
    const late = await spend(db, pack, fixture.companyId, '2025-12-30', '500.00');
    expect(
      await asUser(db, fixture.ownerId, () => expectError(db, `select tax.finalise_computation($1)`, [whole])),
    ).toMatch(/computation_stale/);
    const again = await record(fixture.ownerId, fixture.fiscalYearId);
    expect(
      await asUser(db, fixture.ownerId, () => expectError(db, `select tax.finalise_computation($1)`, [whole])),
    ).toMatch(/computation_not_latest/);
    expect(late).toBeTruthy();

    // The owner calls the latest one final: its last line changes its name,
    // and the loss of the year enters the stock.
    await asUser(db, fixture.ownerId, async () => {
      await db.query(`select tax.finalise_computation($1)`, [again]);
    });
    expect(await computation(again)).toMatchObject({ version: 3, status: 'final', last: 'tax_due' });
    expect(await computation(whole)).toMatchObject({ status: 'estimate', last: 'estimated_tax' });
    const stock = (before: string | null = null): Promise<{ origin: string; amount: string | null; used: string | null; remaining: string | null }[]> =>
      asUser(db, fixture.ownerId, async () =>
        (
          await rows<{ origin: string; amount: string; used: string; remaining: string }>(
            db,
            `select origin_period_end::text as origin, amount::text, used::text, remaining::text
               from tax.loss_stock($1, $2::date)`,
            [fixture.companyId, before],
          )
        ).map((l) => ({ origin: l.origin, amount: decimal(l.amount), used: decimal(l.used), remaining: decimal(l.remaining) })),
      );
    expect(await stock()).toEqual([{ origin: YEAR.end, amount: '4500', used: '0', remaining: '4500' }]);

    // A year with a final computation takes no other, and a final is final once.
    expect(
      await asUser(db, fixture.ownerId, () =>
        expectError(db, `select tax.record_computation($1, $2)`, [fixture.companyId, fixture.fiscalYearId]),
      ),
    ).toMatch(/fiscal_year_has_final_computation/);
    expect(
      await asUser(db, fixture.ownerId, () => expectError(db, `select tax.finalise_computation($1)`, [again])),
    ).toMatch(/computation_not_an_estimate/);

    // Year two earns 10 000 and uses the loss of year one.
    await earn(db, pack, fixture.companyId, '2026-03-01', '10000.00');
    const second = { ...fixture, fiscalYearId: next.id };
    const lines = await estimate(db, second);
    expect(lines.filter((l) => l.kind === 'loss_used').map((l) => [l.code, decimal(l.base), decimal(l.amount)])).toEqual([
      [YEAR.end, '4500', '-4500'],
    ]);
    expect(amountOf(lines, 'taxable_base')).toBe('5500');
    // An estimate uses nothing: the stock is what final computations say.
    expect((await stock())[0]?.remaining).toBe('4500');

    const secondFinal = await record(fixture.ownerId, next.id);
    await asUser(db, fixture.ownerId, async () => {
      await db.query(`select tax.finalise_computation($1)`, [secondFinal]);
    });
    expect(await stock()).toEqual([{ origin: YEAR.end, amount: '4500', used: '4500', remaining: '0' }]);
    // As the stock stood for year two, before it used anything.
    expect(await stock(NEXT.start)).toEqual([{ origin: YEAR.end, amount: '4500', used: '0', remaining: '4500' }]);
    // The final computation of year two still gives the same estimate.
    expect(amountOf(await estimate(db, second), 'taxable_base')).toBe('5500');

    // Withdrawing goes backwards: the year whose loss was used comes second.
    expect(
      await asUser(db, fixture.ownerId, () => expectError(db, `select tax.withdraw_computation($1)`, [again])),
    ).toMatch(/loss_already_used/);
    expect(
      await asUser(db, accountant, () => expectError(db, `select tax.withdraw_computation($1)`, [secondFinal])),
    ).toMatch(/not_allowed: .* tax\.finalize/);
    await asUser(db, fixture.ownerId, async () => {
      await db.query(`select tax.withdraw_computation($1)`, [secondFinal]);
      await db.query(`select tax.withdraw_computation($1)`, [again]);
    });
    expect(await computation(again)).toMatchObject({ status: 'superseded', last: 'estimated_tax' });
    expect(await stock()).toEqual([]);
    // And the year can be recorded again.
    const fresh = await record(accountant, fixture.fiscalYearId);
    expect(await computation(fresh)).toMatchObject({ version: 4, status: 'estimate' });
  });

  it('calls the years final in their order, and leaves a loss that was used alone', async () => {
    const fixture = await taxCompany(db, country, 'Out of order', YEAR);
    await db.query(
      `insert into fiscal_years (company_id, name, start_date, end_date) values ($1, $2, $3::date, $4::date)`,
      [fixture.companyId, NEXT.name, NEXT.start, NEXT.end],
    );
    const next = await one<{ id: string }>(
      db,
      `select id from fiscal_years where company_id = $1 and start_date = $2::date`,
      [fixture.companyId, NEXT.start],
    );
    await declare(db, fixture, { losses: [{ origin_period_end: '2024-12-31', amount: '100.00' }] });
    await earn(db, pack, fixture.companyId, '2025-05-01', '80.00');
    await earn(db, pack, fixture.companyId, '2026-05-01', '100.00');
    const asOwner = <T>(fn: () => Promise<T>): Promise<T> => asUser(db, fixture.ownerId, fn);
    const record = (year: string): Promise<string> =>
      asOwner(async () =>
        (await one<{ id: string }>(db, `select tax.record_computation($1, $2) as id`, [fixture.companyId, year])).id,
      );

    // The later year first: it uses the whole loss.
    const later = await record(next.id);
    await asOwner(() => db.query(`select tax.finalise_computation($1)`, [later]));

    // The earlier year would use the same loss again. It is refused, and the
    // stock is what it was.
    const earlier = await record(fixture.fiscalYearId);
    expect(await asOwner(() => expectError(db, `select tax.finalise_computation($1)`, [earlier]))).toMatch(
      /later_year_final/,
    );
    const stock = await asOwner(() =>
      rows<{ remaining: string }>(db, `select remaining::text from tax.loss_stock($1)`, [fixture.companyId]),
    );
    expect(stock.map((l) => decimal(l.remaining))).toEqual(['0']);

    // A loss a final computation has used keeps its amount and its year.
    expect(
      await asOwner(() => expectError(db, `update tax.losses set amount = 10 where company_id = $1`, [fixture.companyId])),
    ).toMatch(/loss_in_use/);
    expect(
      await asOwner(() => expectError(db, `delete from tax.losses where company_id = $1`, [fixture.companyId])),
    ).toMatch(/foreign key|loss_uses/);
    // A note on it is still the company's to write.
    await asOwner(() => db.query(`update tax.losses set note = 'carried in' where company_id = $1`, [fixture.companyId]));

    // A computation of another company does not exist for a stranger.
    const stranger = await taxCompany(db, country, 'A stranger', YEAR);
    for (const call of ['finalise_computation', 'withdraw_computation']) {
      expect(
        await asUser(db, stranger.ownerId, () => expectError(db, `select tax.${call}($1)`, [later])),
      ).toMatch(/unknown_computation/);
    }
  });

  it('refuses to call a loss year final over a loss the company declared for that same year', async () => {
    const fixture = await taxCompany(db, country, 'Declared twice', YEAR);
    await earn(db, pack, fixture.companyId, '2025-05-01', '10.00');
    await spend(db, pack, fixture.companyId, '2025-05-02', '50.00');
    await declare(db, fixture, { losses: [{ origin_period_end: YEAR.end, amount: '40.00' }] });
    const message = await asUser(db, fixture.ownerId, async () => {
      const recorded = await one<{ id: string }>(db, `select tax.record_computation($1, $2) as id`, [
        fixture.companyId,
        fixture.fiscalYearId,
      ]);
      return expectError(db, `select tax.finalise_computation($1)`, [recorded.id]);
    });
    expect(message).toMatch(/loss_already_declared/);
  });

  it('refuses a loss to carry where the pack has no rule in force for it', async () => {
    const early = { name: 'Year 1995', start: '1995-01-01', end: '1995-12-31' };
    await db.query(
      `insert into tax.rate_templates (country, code, valid_from, valid_to, name, rate, legal_reference)
       values ($1, 'test-old-rate', date '1995-01-01', date '1995-12-31', 'A rate of long ago', 10, 'test')`,
      [country],
    );
    const fixture = await taxCompany(db, country, 'Old loss', early);
    await earn(db, pack, fixture.companyId, '1995-06-01', '1000.00');
    await declare(db, fixture, { losses: [{ origin_period_end: '1994-12-31', amount: '300.00' }] });
    expect(
      await asUser(db, fixture.ownerId, () =>
        expectError(db, `select * from tax.estimate($1, $2)`, [fixture.companyId, fixture.fiscalYearId]),
      ),
    ).toMatch(/no_loss_carryforward_rule/);
  });

  it('cannot be written by hand, by anybody', async () => {
    const fixture = await taxCompany(db, country, 'By hand', YEAR);
    await earn(db, pack, fixture.companyId, '2025-04-01', '6000.00');
    const id = await asUser(db, fixture.ownerId, async () =>
      (
        await one<{ id: string }>(db, `select tax.record_computation($1, $2) as id`, [
          fixture.companyId,
          fixture.fiscalYearId,
        ])
      ).id,
    );
    for (const statement of [
      `update tax.computations set status = 'final', finalised_at = now() where id = '${id}'`,
      `update tax.computation_lines set kind = 'tax_due' where computation_id = '${id}'`,
      `delete from tax.computations where id = '${id}'`,
      `insert into tax.loss_uses (company_id, loss_id, computation_id, amount) values ('${fixture.companyId}', gen_random_uuid(), '${id}', 1)`,
    ]) {
      expect(await asUser(db, fixture.ownerId, () => expectError(db, statement))).toMatch(/permission denied/);
    }
    // A loss a final computation recorded is not the company's to rewrite;
    // one it declared is.
    await spend(db, pack, fixture.companyId, '2025-04-02', '9000.00');
    const loss = await asUser(db, fixture.ownerId, async () => {
      const recorded = await one<{ id: string }>(db, `select tax.record_computation($1, $2) as id`, [
        fixture.companyId,
        fixture.fiscalYearId,
      ]);
      await db.query(`select tax.finalise_computation($1)`, [recorded.id]);
      const changed = await db.query(`update tax.losses set amount = 1 where company_id = $1 returning id`, [
        fixture.companyId,
      ]);
      return changed.rows.length;
    });
    expect(loss).toBe(0);
    expect(
      decimal((await one<{ amount: string }>(db, `select amount::text from tax.losses where company_id = $1`, [fixture.companyId])).amount),
    ).toBe('3000');
  });
});

// ------------------------------------------------------ row level security

describe('row level security', () => {
  const TABLES = [
    'company_parameters',
    'adjustments',
    'credits',
    'computations',
    'computation_lines',
    'losses',
    'loss_uses',
  ];

  async function populated(name: string): Promise<Awaited<ReturnType<typeof taxCompany>>> {
    await db.query(
      `insert into tax.credit_templates (country, code, valid_from, name, refundable, legal_reference, sequence)
       values ($1, 'test-rls', date '2000-01-01', 'A credit', true, 'test', 30)
       on conflict do nothing`,
      [country],
    );
    const fixture = await taxCompany(db, country, name, YEAR);
    await db.query(
      `insert into fiscal_years (company_id, name, start_date, end_date) values ($1, $2, $3::date, $4::date)`,
      [fixture.companyId, NEXT.name, NEXT.start, NEXT.end],
    );
    await earn(db, pack, fixture.companyId, '2025-04-01', '1000.00');
    await spend(db, pack, fixture.companyId, '2025-04-02', '3000.00');
    await earn(db, pack, fixture.companyId, '2026-04-01', '5000.00');
    await declare(db, fixture, {
      parameters: meeting(reduced),
      adjustments: [{ rule: section.adjustment_rules.find((r) => r.percent !== null)!.code, amount: '10.00' }],
    });
    await asUser(db, fixture.ownerId, async () => {
      await db.query(
        `insert into tax.credits (company_id, fiscal_year_id, credit_code, amount) values ($1, $2, 'test-rls', 5)`,
        [fixture.companyId, fixture.fiscalYearId],
      );
      // A final loss year, then a final year that uses it: every table holds a row.
      const first = await one<{ id: string }>(db, `select tax.record_computation($1, $2) as id`, [
        fixture.companyId,
        fixture.fiscalYearId,
      ]);
      await db.query(`select tax.finalise_computation($1)`, [first.id]);
      const second = await one<{ id: string }>(
        db,
        `select tax.record_computation($1, (select id from fiscal_years where company_id = $1 and start_date = $2::date)) as id`,
        [fixture.companyId, NEXT.start],
      );
      await db.query(`select tax.finalise_computation($1)`, [second.id]);
    });
    return fixture;
  }

  const counts = async (userId: string): Promise<Record<string, number>> =>
    asUser(db, userId, async () => {
      const out: Record<string, number> = {};
      for (const table of TABLES) {
        out[table] = (await rows(db, `select 1 from tax.${table}`)).length;
      }
      return out;
    });

  const nothing = Object.fromEntries(TABLES.map((table) => [table, 0]));

  it('shows a member every table of the module, and a stranger none of it', async () => {
    const fixture = await populated('Seen by its members');
    const mine = await counts(fixture.ownerId);
    for (const table of TABLES) expect(mine[table], table).toBeGreaterThan(0);

    // The owner of another company that holds the module too.
    const other = await taxCompany(db, country, 'Another company', YEAR);
    expect(await counts(other.ownerId)).toEqual(nothing);

    // And no function answers for a company the caller is not a member of.
    expect(
      await asUser(db, other.ownerId, () =>
        expectError(db, `select * from tax.estimate($1, $2)`, [fixture.companyId, fixture.fiscalYearId]),
      ),
    ).toMatch(/module_not_enabled/);
    expect(
      await asUser(db, other.ownerId, () =>
        expectError(db, `select tax.record_computation($1, $2)`, [fixture.companyId, fixture.fiscalYearId]),
      ),
    ).toMatch(/not_allowed/);
    expect(
      await asUser(db, other.ownerId, () => rows(db, `select * from tax.loss_stock($1)`, [fixture.companyId])),
    ).toEqual([]);
    expect(
      await asUser(db, other.ownerId, () => rows(db, `select * from tax.accounts_in_use($1)`, [fixture.companyId])),
    ).toEqual([]);
    // Nor may a stranger write into it: the company is not even there for them.
    expect(
      await asUser(db, other.ownerId, () =>
        expectError(db, `insert into tax.losses (company_id, origin_period_end, amount) values ($1, date '2020-12-31', 5)`, [
          fixture.companyId,
        ]),
      ),
    ).toMatch(/row-level security|unknown_company/);
  });

  it('shows nobody anything once the module is disabled, and gives it all back when it is enabled again', async () => {
    const fixture = await populated('Switched off');
    const before = await counts(fixture.ownerId);

    await asUser(db, fixture.ownerId, async () => {
      await db.query(`select disable_module($1, 'tax')`, [fixture.companyId]);
    });
    expect(await counts(fixture.ownerId)).toEqual(nothing);
    expect(
      await asUser(db, fixture.ownerId, () =>
        expectError(db, `select * from tax.estimate($1, $2)`, [fixture.companyId, fixture.fiscalYearId]),
      ),
    ).toMatch(/module_not_enabled/);
    expect(
      await asUser(db, fixture.ownerId, () =>
        expectError(db, `select tax.record_computation($1, $2)`, [fixture.companyId, fixture.fiscalYearId]),
      ),
    ).toMatch(/module_not_enabled/);
    expect(
      await asUser(db, fixture.ownerId, () =>
        expectError(db, `insert into tax.losses (company_id, origin_period_end, amount) values ($1, date '2020-12-31', 5)`, [
          fixture.companyId,
        ]),
      ),
    ).toMatch(/row-level security/);

    // Nothing was deleted: a disable hides, and an enable shows again.
    await asUser(db, fixture.ownerId, async () => {
      await db.query(`select enable_module($1, 'tax')`, [fixture.companyId]);
    });
    expect(await counts(fixture.ownerId)).toEqual(before);
  });

  it('lets a viewer read and not write, and keeps a member without tax.read out', async () => {
    const fixture = await populated('Presets');
    const viewer = crypto.randomUUID();
    const bookkeeper = crypto.randomUUID();
    await db.query(
      `insert into company_members (company_id, user_id, role) values ($1, $2, 'viewer')`,
      [fixture.companyId, viewer],
    );
    await db.query(
      `insert into company_members (company_id, user_id, role, capabilities_revoked)
       values ($1, $2, 'accountant', array['tax.read', 'tax.write'])`,
      [fixture.companyId, bookkeeper],
    );

    expect(await counts(viewer)).toEqual(await counts(fixture.ownerId));
    expect((await estimate(db, { ...fixture, ownerId: viewer })).at(-1)?.kind).toBe('estimated_tax');
    expect(
      await asUser(db, viewer, () =>
        expectError(db, `insert into tax.losses (company_id, origin_period_end, amount) values ($1, date '2020-12-31', 5)`, [
          fixture.companyId,
        ]),
      ),
    ).toMatch(/row-level security/);
    expect(
      await asUser(db, viewer, () =>
        expectError(db, `select tax.record_computation($1, $2)`, [fixture.companyId, fixture.fiscalYearId]),
      ),
    ).toMatch(/not_allowed: .* tax\.write/);

    // Still an accountant of the company by every other measure.
    expect(await counts(bookkeeper)).toEqual(nothing);
    expect(
      await asUser(db, bookkeeper, () =>
        expectError(db, `select * from tax.estimate($1, $2)`, [fixture.companyId, fixture.fiscalYearId]),
      ),
    ).toMatch(/not_allowed: .* tax\.read/);
  });

  it('serves the rules of every country to a caller the installation knows, and to nobody else', async () => {
    const fixture = await taxCompany(db, country, 'Reference data', YEAR);
    const REFERENCE = [
      'country_rules',
      'parameter_templates',
      'adjustment_rule_templates',
      'rate_templates',
      'loss_rule_templates',
      'prepayment_templates',
      'credit_templates',
    ];
    const seen = await asUser(db, fixture.ownerId, async () => {
      const out: string[][] = [];
      for (const table of ['country_rules', 'rate_templates']) {
        out.push((await rows<{ country: string }>(db, `select distinct country from tax.${table} order by 1`)).map((r) => r.country));
      }
      return out;
    });
    const countries = packs.map((p) => p.manifest.country).sort();
    expect(seen).toEqual([countries, countries]);

    for (const table of REFERENCE) {
      // Not written by a member, whatever they hold.
      expect(
        await asUser(db, fixture.ownerId, () => expectError(db, `delete from tax.${table}`)),
        table,
      ).toMatch(/permission denied/);
      // And not read by somebody who is not signed in.
      expect(
        await asUser(db, fixture.ownerId, () => expectError(db, `select 1 from tax.${table}`), 'anon'),
        table,
      ).toMatch(/permission denied/);
    }
  });
});

// ------------------------------------------------------------ the seeds

describe('what the packs compiled into the module', () => {
  it('is every figure of every section, under the day it applies from and the article it comes from', async () => {
    for (const p of packs) {
      const s = p.corporateTax!;
      const code = p.manifest.country;
      const header = await one<Record<string, string | null>>(
        db,
        `select tax_code, result_statement_code, result_line_code, expense_account_code, payable_account_code,
                receivable_account_code from tax.country_rules where country = $1`,
        [code],
      );
      expect(header).toEqual({
        tax_code: s.tax.code,
        result_statement_code: s.result.statement,
        result_line_code: s.result.line,
        expense_account_code: s.accounts.expense,
        payable_account_code: s.accounts.payable,
        receivable_account_code: s.accounts.receivable,
      });

      const rates = await rows<{ code: string; valid_from: string; rate: string; up_to: string | null; legal_reference: string }>(
        db,
        `select code, valid_from::text, rate::text, up_to::text, legal_reference
           from tax.rate_templates where country = $1 and code not like 'test-%' order by code, valid_from`,
        [code],
      );
      expect(rates.map((r) => [r.code, r.valid_from, decimal(r.rate), decimal(r.up_to), r.legal_reference])).toEqual(
        [...s.rates]
          .sort((a, b) => a.code.localeCompare(b.code) || a.valid_from.localeCompare(b.valid_from))
          .map((r) => [r.code, r.valid_from, String(r.rate), r.up_to === null ? null : String(r.up_to), r.legal_reference]),
      );

      const counted = await one<{ rules: number; parameters: number; losses: number; prepayments: number; unreferenced: number }>(
        db,
        `select (select count(*)::integer from tax.adjustment_rule_templates where country = $1 and code not like 'test-%') as rules,
                (select count(*)::integer from tax.parameter_templates where country = $1) as parameters,
                (select count(*)::integer from tax.loss_rule_templates where country = $1) as losses,
                (select count(*)::integer from tax.prepayment_templates where country = $1) as prepayments,
                (select count(*)::integer from tax.adjustment_rule_templates
                  where country = $1 and coalesce(legal_reference, '') = '') as unreferenced`,
        [code],
      );
      expect(counted).toEqual({
        rules: s.adjustment_rules.length,
        parameters: s.parameters.length,
        losses: s.loss_carryforward.length,
        prepayments: s.prepayments.length,
        unreferenced: 0,
      });

      // The accounts the pack names are accounts a company of that country gets.
      const fixture = await newCompany(db, { country: code, name: `Accounts ${p.slug}`, fiscalYear: YEAR });
      const held = await rows<{ code: string }>(
        db,
        `select code from accounts where company_id = $1 and code = any($2::text[]) order by code`,
        [fixture.companyId, [s.accounts.expense, s.accounts.payable, s.accounts.receivable].filter((c) => c !== null)],
      );
      expect(held.map((a) => a.code)).toEqual(
        [s.accounts.expense, s.accounts.payable, s.accounts.receivable].filter((c): c is string => c !== null).sort(),
      );
    }
  });

  it('returns the labels in the language of the reader', async () => {
    const translated = packs.find((p) => (p.manifest.languages ?? []).length > 0)!;
    const language = (translated.manifest.languages ?? [])[0]!;
    const s = translated.corporateTax!;
    const fixture = await taxCompany(db, translated.manifest.country, 'In another language', YEAR);
    await earn(db, translated, fixture.companyId, '2025-02-01', '1000.00');

    const own = (await estimate(db, fixture)).at(-1)?.name;
    expect(own).toBe(s.tax.name);

    await db.query(`update companies set language = $2 where id = $1`, [fixture.companyId, language]);
    const other = (await estimate(db, fixture)).at(-1)?.name;
    expect(other).toBe(s.tax.name_i18n[language]);
    expect(other).not.toBe(own);
  });
});

describe('a currency that is not written with cents', () => {
  it('rounds every figure at the decimals of the currency, by the method of the country', async () => {
    // A real pack moved to a country that exists nowhere, in a currency with
    // no decimals at all. Its tax rules move with it: the rows of the country
    // the fixture was copied from, under the fixture's own code, naming the
    // fixture's own statement.
    const fixture = { country: 'ZY', currency: 'ZYA', currencyName: 'Zeroland unit', decimals: 0 };
    await installFixturePack(db, fixture);
    const origin = await one<{ country: string }>(
      db,
      `select t.country from tax.country_rules t
        where exists (select 1 from statement_templates s
                       where s.country = $1::text
                         and s.code = replace(t.result_statement_code, t.country || '-', $1::text || '-'))`,
      [fixture.country],
    );
    await db.query(
      `insert into tax.country_rules
         (country, tax_code, name, result_statement_code, result_line_code, result_legal_reference,
          expense_account_code, payable_account_code, accounts_legal_reference, legal_reference)
       select $1::text, t.tax_code, t.name, replace(t.result_statement_code, t.country || '-', $1::text || '-'),
              t.result_line_code, t.result_legal_reference, t.expense_account_code, t.payable_account_code,
              t.accounts_legal_reference, t.legal_reference
         from tax.country_rules t where t.country = $2`,
      [fixture.country, origin.country],
    );
    await db.query(
      `insert into tax.rate_templates (country, code, valid_from, valid_to, valid_on, name, rate, up_to,
                                       up_to_prorata, conditions, legal_reference)
       select $1::text, t.code, t.valid_from, t.valid_to, t.valid_on, t.name, t.rate, t.up_to, t.up_to_prorata,
              t.conditions, t.legal_reference
         from tax.rate_templates t where t.country = $2 and t.code not like 'test-%'`,
      [fixture.country, origin.country],
    );
    await db.query(
      `insert into tax.adjustment_rule_templates (country, code, valid_from, name, direction, percent, legal_reference)
       values ($1, 'test-third', date '2000-01-01', 'A third refused', 'add_back', 33.333333, 'test')`,
      [fixture.country],
    );
    const copied = packs.find((p) => p.manifest.country === origin.country)!;
    const top = ordinaryRate(copied.corporateTax!, YEAR.start);

    const company = await taxCompany(db, fixture.country, 'No decimals', YEAR);
    // 1 001 units of profit, and an expense of 100 refused for a third.
    await earn(db, copied, company.companyId, '2025-03-01', '1001');
    await declare(db, company, { adjustments: [{ rule: 'test-third', amount: '100' }] });

    const lines = await estimate(db, company);
    // 100 × 33,333333 % = 33,33…, which this currency writes 33.
    expect(lines.filter((l) => l.kind === 'adjustment').map((l) => [l.base, l.amount])).toEqual([['100', '33']]);
    expect(lines.find((l) => l.kind === 'fiscal_result')?.amount).toBe('1034');
    // 1 034 at the ordinary rate, rounded to the unit and written without a decimal.
    const tax = Math.round((1034 * top.rate) / 100);
    expect(1034 * top.rate, 'the example has to leave a fraction to round').not.toBe(tax * 100);
    expect(lines.at(-1)?.amount).toBe(String(tax));
    for (const line of lines) {
      for (const figure of [line.base, line.amount]) expect(figure ?? '0').not.toContain('.');
    }
  });
});

describe('booking nothing', () => {
  it('leaves the ledger as it found it', async () => {
    const fixture = await taxCompany(db, country, 'No entry', YEAR);
    await earn(db, pack, fixture.companyId, '2025-04-01', '6000.00');
    const entries = async (): Promise<number> =>
      (await rows(db, `select 1 from entries where company_id = $1`, [fixture.companyId])).length;
    const before = await entries();
    await asUser(db, fixture.ownerId, async () => {
      const recorded = await one<{ id: string }>(db, `select tax.record_computation($1, $2) as id`, [
        fixture.companyId,
        fixture.fiscalYearId,
      ]);
      await db.query(`select tax.finalise_computation($1)`, [recorded.id]);
    });
    await book(db, fixture.companyId, {
      date: '2025-04-03',
      description: 'An entry of the company itself',
      lines: [
        { account: leafAccount(pack, 'asset_cash'), debit: '1.00' },
        { account: leafAccount(pack, 'income'), credit: '1.00' },
      ],
    });
    expect(await entries()).toBe(before + 1);
  });
});
