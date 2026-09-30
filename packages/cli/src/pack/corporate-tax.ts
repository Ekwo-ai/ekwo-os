/**
 * `packs/<cc>/corporate_tax.json` — the country data of the corporate income
 * tax module.
 *
 * It is read with the rest of the pack, by the one reader a pack has, and it
 * compiles into a seed of its own under `supabase/seed/modules/corporate_tax/`
 * because the tables it fills exist only on an installation that carries the
 * module. What is here is the three things a section owes: its shape once
 * read, what it obliges the rest of the pack to say, and the SQL it becomes.
 *
 * The rule the section exists to keep is the one every other part of a pack
 * keeps: **a figure carries the article it comes from and the day it applies
 * from**. The schema requires both on every rate, every rule, every limit and
 * every instalment, so a pack that cannot cite a figure cannot write it.
 */

import type { Issue } from './schema.js';
import type { PackChart, PackStatement } from './read.js';

/** Which day of a financial year a validity is read on. */
export type ValidityBasis = 'period_start' | 'period_end';

interface Dated {
  valid_from: string;
  valid_to: string | null;
  valid_on: ValidityBasis;
}

interface Cited {
  legal_reference: string;
  /** Key of the register entry where that reference can be read. */
  source: string | null;
}

/** A fact a company declares for a financial year. */
export interface PackTaxParameter extends Cited {
  code: string;
  name: string;
  name_i18n: Record<string, string>;
  type: 'boolean' | 'amount';
  sequence: number;
}

/** One account matcher of an adjustment rule, in the vocabulary of a statement rule. */
export interface PackTaxAccountRule {
  kind: 'account_code' | 'code_prefix' | 'code_range';
  code_from: string;
  code_to: string | null;
}

/** One dated version of a rule between the accounting result and the taxable one. */
export interface PackTaxAdjustmentRule extends Dated, Cited {
  code: string;
  name: string;
  name_i18n: Record<string, string>;
  direction: 'add_back' | 'deduction';
  percent: number | null;
  formula: Record<string, unknown> | null;
  accounts: PackTaxAccountRule[];
  sequence: number;
}

/** One condition of a rate, on a parameter the company declares. */
export interface PackTaxCondition {
  parameter: string;
  test: 'is_true' | 'is_false' | 'at_least' | 'at_most' | 'below' | 'above';
  amount: number | null;
  or_at_least: 'taxable_base' | null;
  waived_by: string[];
}

/** One dated version of a rate. */
export interface PackTaxRate extends Dated, Cited {
  code: string;
  name: string;
  name_i18n: Record<string, string>;
  rate: number;
  up_to: number | null;
  up_to_prorata: 'none' | 'months';
  conditions: PackTaxCondition[];
  sequence: number;
}

export interface PackTaxLossRule extends Dated, Cited {
  floor: number | null;
  percent_above: number | null;
  years: number | null;
}

export interface PackTaxInstalment {
  sequence: number;
  month: number;
  day: number;
  share_percent: number | null;
  credit_percent: number | null;
}

export interface PackTaxPrepayment extends Dated, Cited {
  method: 'surcharge_on_shortfall' | 'share_of_reference_tax';
  month_basis: 'fiscal' | 'calendar';
  instalments: PackTaxInstalment[];
  surcharge_percent: number | null;
  exempt_up_to: number | null;
}

export interface PackTaxCredit extends Dated, Cited {
  code: string;
  name: string;
  name_i18n: Record<string, string>;
  refundable: boolean;
  sequence: number;
}

export interface PackCorporateTax {
  tax: Cited & { code: string; name: string; name_i18n: Record<string, string> };
  result: Cited & { statement: string; line: string };
  accounts: Cited & { expense: string; payable: string; receivable: string | null };
  parameters: PackTaxParameter[];
  adjustment_rules: PackTaxAdjustmentRule[];
  rates: PackTaxRate[];
  loss_carryforward: PackTaxLossRule[];
  prepayments: PackTaxPrepayment[];
  credits: PackTaxCredit[];
}

type Raw = Record<string, unknown>;

const text = (value: unknown): string | null =>
  value === undefined || value === null ? null : String(value);
const numeric = (value: unknown): number | null =>
  value === undefined || value === null ? null : Number(value);

function cited(raw: Raw): Cited {
  return { legal_reference: String(raw['legal_reference'] ?? ''), source: text(raw['source']) };
}

function dated(raw: Raw): Dated {
  return {
    valid_from: String(raw['valid_from'] ?? ''),
    valid_to: text(raw['valid_to']),
    // A law that says nothing else applies to the financial years opened from
    // its date, which is the reading a bare `valid_from` gets.
    valid_on: raw['valid_on'] === 'period_end' ? 'period_end' : 'period_start',
  };
}

/** The section as the rest of the CLI reads it, every optional field given its value. */
export function normaliseCorporateTax(raw: Raw): PackCorporateTax {
  const list = (key: string): Raw[] => (raw[key] ?? []) as Raw[];
  const tax = (raw['tax'] ?? {}) as Raw;
  const result = (raw['result'] ?? {}) as Raw;
  const accounts = (raw['accounts'] ?? {}) as Raw;
  const sequence = (item: Raw, index: number): number => Number(item['sequence'] ?? (index + 1) * 10);

  return {
    tax: { code: String(tax['code'] ?? ''), name: String(tax['name'] ?? ''), name_i18n: {}, ...cited(tax) },
    result: { statement: String(result['statement'] ?? ''), line: String(result['line'] ?? ''), ...cited(result) },
    accounts: {
      expense: String(accounts['expense'] ?? ''),
      payable: String(accounts['payable'] ?? ''),
      receivable: text(accounts['receivable']),
      ...cited(accounts),
    },
    parameters: list('parameters').map((item, index) => ({
      code: String(item['code']),
      name: String(item['name']),
      name_i18n: {},
      type: item['type'] === 'amount' ? 'amount' : 'boolean',
      sequence: sequence(item, index),
      ...cited(item),
    })),
    adjustment_rules: list('adjustment_rules').map((item, index) => ({
      code: String(item['code']),
      name: String(item['name']),
      name_i18n: {},
      direction: item['direction'] === 'deduction' ? 'deduction' : 'add_back',
      percent: numeric(item['percent']),
      formula: (item['formula'] ?? null) as Record<string, unknown> | null,
      accounts: ((item['accounts'] ?? []) as Raw[]).map((rule) => ({
        kind: rule['kind'] as PackTaxAccountRule['kind'],
        code_from: String(rule['code_from']),
        code_to: text(rule['code_to']),
      })),
      sequence: sequence(item, index),
      ...dated(item),
      ...cited(item),
    })),
    rates: list('rates').map((item, index) => ({
      code: String(item['code']),
      name: String(item['name']),
      name_i18n: {},
      rate: Number(item['rate']),
      up_to: numeric(item['up_to']),
      up_to_prorata: item['up_to_prorata'] === 'months' ? 'months' : 'none',
      conditions: ((item['conditions'] ?? []) as Raw[]).map((condition) => ({
        parameter: String(condition['parameter']),
        test: condition['test'] as PackTaxCondition['test'],
        amount: numeric(condition['amount']),
        or_at_least: condition['or_at_least'] === 'taxable_base' ? 'taxable_base' : null,
        waived_by: ((condition['waived_by'] ?? []) as unknown[]).map((code) => String(code)),
      })),
      sequence: sequence(item, index),
      ...dated(item),
      ...cited(item),
    })),
    loss_carryforward: list('loss_carryforward').map((item) => ({
      floor: numeric(item['floor']),
      percent_above: numeric(item['percent_above']),
      years: numeric(item['years']),
      ...dated(item),
      ...cited(item),
    })),
    prepayments: list('prepayments').map((item) => ({
      method: item['method'] as PackTaxPrepayment['method'],
      month_basis: item['month_basis'] === 'fiscal' ? 'fiscal' : 'calendar',
      instalments: ((item['instalments'] ?? []) as Raw[]).map((instalment) => ({
        sequence: Number(instalment['sequence']),
        month: Number(instalment['month']),
        day: Number(instalment['day']),
        share_percent: numeric(instalment['share_percent']),
        credit_percent: numeric(instalment['credit_percent']),
      })),
      surcharge_percent: numeric(item['surcharge_percent']),
      exempt_up_to: numeric(item['exempt_up_to']),
      ...dated(item),
      ...cited(item),
    })),
    credits: list('credits').map((item, index) => ({
      code: String(item['code']),
      name: String(item['name']),
      name_i18n: {},
      refundable: item['refundable'] === true,
      sequence: sequence(item, index),
      ...dated(item),
      ...cited(item),
    })),
  };
}

/**
 * The keys of the `corporate_tax` section of an i18n file, in the order a
 * missing one is reported: the tax itself, then every parameter, rule, rate
 * and credit by its code. A code with several dated versions is one key.
 */
export function corporateTaxLabelKeys(section: PackCorporateTax | null): string[] {
  if (section === null) return [];
  const unique = (codes: string[]): string[] => [...new Set(codes)];
  return [
    'tax',
    ...section.parameters.map((p) => `parameter:${p.code}`),
    ...unique(section.adjustment_rules.map((r) => `rule:${r.code}`)),
    ...unique(section.rates.map((r) => `rate:${r.code}`)),
    ...unique(section.credits.map((c) => `credit:${c.code}`)),
  ];
}

/** Puts the translations of `i18n/<lang>.json` on the rows that carry a label. */
export function applyCorporateTaxLabels(
  section: PackCorporateTax | null,
  labels: Record<string, Record<string, string>>,
): void {
  if (section === null) return;
  section.tax.name_i18n = labels['tax'] ?? {};
  for (const parameter of section.parameters) parameter.name_i18n = labels[`parameter:${parameter.code}`] ?? {};
  for (const rule of section.adjustment_rules) rule.name_i18n = labels[`rule:${rule.code}`] ?? {};
  for (const rate of section.rates) rate.name_i18n = labels[`rate:${rate.code}`] ?? {};
  for (const credit of section.credits) credit.name_i18n = labels[`credit:${credit.code}`] ?? {};
}

/** Every place the section names a source, for the register check. */
export function corporateTaxSources(section: PackCorporateTax | null): { path: string; source: string | null }[] {
  if (section === null) return [];
  const at = (what: string): string => `corporate_tax.json ${what}`;
  return [
    { path: at('tax'), source: section.tax.source },
    { path: at('result'), source: section.result.source },
    { path: at('accounts'), source: section.accounts.source },
    ...section.parameters.map((p) => ({ path: at(`parameters.${p.code}`), source: p.source })),
    ...section.adjustment_rules.map((r) => ({
      path: at(`adjustment_rules.${r.code}@${r.valid_from}`),
      source: r.source,
    })),
    ...section.rates.map((r) => ({ path: at(`rates.${r.code}@${r.valid_from}`), source: r.source })),
    ...section.loss_carryforward.map((l) => ({ path: at(`loss_carryforward@${l.valid_from}`), source: l.source })),
    ...section.prepayments.map((p) => ({ path: at(`prepayments@${p.valid_from}`), source: p.source })),
    ...section.credits.map((c) => ({ path: at(`credits.${c.code}@${c.valid_from}`), source: c.source })),
  ];
}

/**
 * What a `corporate_tax.json` obliges the rest of the pack to say, and what it
 * has to agree with itself about.
 *
 * The schema has already checked the shape. What is left is what only the
 * pack knows: that the statement and the line exist, that the accounts are in
 * every chart, that a condition names a parameter somebody declared, and that
 * no rule gives two answers for the same day.
 */
export function corporateTaxReferences(
  section: PackCorporateTax,
  charts: PackChart[],
  statements: PackStatement[],
): Issue[] {
  const issues: Issue[] = [];
  const at = (what: string): string => `corporate_tax.json ${what}`;

  // The line the computation starts from.
  const statement = statements.find((s) => s.code === section.result.statement);
  if (statement === undefined) {
    issues.push({
      path: at('result.statement'),
      message: `${section.result.statement} is not a statement of this pack`,
    });
  } else {
    if (statement.kind !== 'income_statement') {
      issues.push({
        path: at('result.statement'),
        message: `${statement.code} is a ${statement.kind}; the accounting result is a line of an income statement`,
      });
    }
    if (!statement.lines.some((line) => line.code === section.result.line)) {
      issues.push({
        path: at('result.line'),
        message: `${section.result.line} is not a line of ${statement.code}`,
      });
    }
  }

  // The accounts the tax is booked on: in every chart, like a role.
  for (const [role, code] of Object.entries({
    expense: section.accounts.expense,
    payable: section.accounts.payable,
    receivable: section.accounts.receivable,
  })) {
    if (code === null) continue;
    for (const chart of charts) {
      if (!chart.accounts.some((account) => account.code === code)) {
        issues.push({
          path: at(`accounts.${role}`),
          message: `account ${code} is not in the chart ${chart.code}`,
        });
      }
    }
  }

  // The parameters, and the conditions that name them.
  const parameters = new Map<string, PackTaxParameter>();
  for (const parameter of section.parameters) {
    if (parameters.has(parameter.code)) {
      issues.push({ path: at(`parameters.${parameter.code}`), message: 'duplicate parameter code' });
    }
    parameters.set(parameter.code, parameter);
  }
  for (const rate of section.rates) {
    const where = at(`rates.${rate.code}@${rate.valid_from}`);
    for (const condition of rate.conditions) {
      const parameter = parameters.get(condition.parameter);
      if (parameter === undefined) {
        issues.push({ path: where, message: `a condition names ${condition.parameter}, which is not a parameter of this section` });
        continue;
      }
      const compares = condition.test !== 'is_true' && condition.test !== 'is_false';
      if (compares !== (parameter.type === 'amount')) {
        issues.push({
          path: where,
          message: `${condition.test} is asked of ${parameter.code}, which is declared as ${parameter.type}`,
        });
      }
      if (compares && condition.amount === null) {
        issues.push({ path: where, message: `${condition.test} on ${parameter.code} compares with no amount` });
      }
      if (!compares && (condition.amount !== null || condition.or_at_least !== null)) {
        issues.push({ path: where, message: `${condition.test} on ${parameter.code} takes no amount` });
      }
      for (const waiver of condition.waived_by) {
        if (parameters.get(waiver)?.type !== 'boolean') {
          issues.push({ path: where, message: `waived_by names ${waiver}, which is not a boolean parameter of this section` });
        }
      }
    }
  }

  // A rule says one thing: a percentage, or how to work one out.
  for (const rule of section.adjustment_rules) {
    const where = at(`adjustment_rules.${rule.code}@${rule.valid_from}`);
    if ((rule.percent === null) === (rule.formula === null)) {
      issues.push({ path: where, message: 'a rule takes a percent or a formula, and exactly one of them' });
    }
    // A formula reads what the company states about one expense. An account
    // the pack names has nobody to state it.
    if (rule.formula !== null && rule.accounts.length > 0) {
      issues.push({
        path: where,
        message: 'a rule with a formula names no accounts: the figures it needs are stated by the company, expense by expense',
      });
    }
    for (const matcher of rule.accounts) {
      if ((matcher.kind === 'code_range') !== (matcher.code_to !== null)) {
        issues.push({ path: where, message: `${matcher.kind} on ${matcher.code_from}: code_to belongs to a code_range and to nothing else` });
      }
      if (matcher.kind !== 'account_code') continue;
      // An account named by its code has to exist wherever the computation can
      // start: in every chart that reports on the statement it starts from.
      for (const chart of charts.filter((c) => c.statements.includes(section.result.statement))) {
        if (!chart.accounts.some((account) => account.code === matcher.code_from)) {
          issues.push({ path: where, message: `account ${matcher.code_from} is not in the chart ${chart.code}` });
        }
      }
    }
  }

  // No two answers for one day. Two versions of one code, or two limits on
  // losses, or two prepayment schedules, may not be in force together.
  const versions: [string, (Dated & { key: string })[]][] = [
    ['adjustment_rules', section.adjustment_rules.map((r) => ({ ...r, key: r.code }))],
    ['rates', section.rates.map((r) => ({ ...r, key: r.code }))],
    ['credits', section.credits.map((c) => ({ ...c, key: c.code }))],
    ['loss_carryforward', section.loss_carryforward.map((l) => ({ ...l, key: '' }))],
    ['prepayments', section.prepayments.map((p) => ({ ...p, key: '' }))],
  ];
  for (const [name, rows] of versions) {
    const byKey = new Map<string, (Dated & { key: string })[]>();
    for (const row of rows) byKey.set(row.key, [...(byKey.get(row.key) ?? []), row]);
    for (const [key, group] of byKey) {
      const where = at(key === '' ? name : `${name}.${key}`);
      for (const row of group) {
        if (row.valid_to !== null && row.valid_to < row.valid_from) {
          issues.push({ path: `${where}@${row.valid_from}`, message: 'valid_to is before valid_from' });
        }
      }
      if (new Set(group.map((row) => row.valid_on)).size > 1) {
        issues.push({
          path: where,
          message: 'its versions read their validity on different days of the financial year; one code, one valid_on',
        });
        continue;
      }
      const ordered = [...group].sort((a, b) => (a.valid_from < b.valid_from ? -1 : 1));
      for (let i = 1; i < ordered.length; i += 1) {
        const before = ordered[i - 1] as Dated;
        const after = ordered[i] as Dated;
        if (before.valid_to === null || before.valid_to >= after.valid_from) {
          issues.push({
            path: `${where}@${after.valid_from}`,
            message: `overlaps the version valid from ${before.valid_from}; close that one with a valid_to the day before`,
          });
        }
      }
    }
  }

  // Something always applies: a rate with no threshold and no condition.
  if (!section.rates.some((rate) => rate.up_to === null && rate.conditions.length === 0)) {
    issues.push({
      path: at('rates'),
      message: 'no rate applies unconditionally to the whole base; a reduced rate needs the ordinary one beside it',
    });
  }
  for (const rate of section.rates) {
    if (rate.up_to !== null && rate.up_to <= 0) {
      issues.push({ path: at(`rates.${rate.code}@${rate.valid_from}`), message: 'up_to is the top of a slice, and a slice has a width' });
    }
    if (rate.up_to === null && rate.up_to_prorata !== 'none') {
      issues.push({ path: at(`rates.${rate.code}@${rate.valid_from}`), message: 'up_to_prorata shares out a threshold, and this rate has none' });
    }
  }

  for (const rule of section.loss_carryforward) {
    if ((rule.floor === null) !== (rule.percent_above === null)) {
      issues.push({
        path: at(`loss_carryforward@${rule.valid_from}`),
        message: 'floor and percent_above go together: both for a limit, neither for none',
      });
    }
  }

  for (const prepayment of section.prepayments) {
    const where = at(`prepayments@${prepayment.valid_from}`);
    const sequences = new Set(prepayment.instalments.map((i) => i.sequence));
    if (sequences.size !== prepayment.instalments.length) {
      issues.push({ path: where, message: 'two instalments carry the same sequence' });
    }
    if (prepayment.method === 'share_of_reference_tax') {
      if (prepayment.instalments.some((i) => i.share_percent === null)) {
        issues.push({ path: where, message: 'share_of_reference_tax: every instalment states its share_percent' });
      }
    } else {
      if (prepayment.surcharge_percent === null) {
        issues.push({ path: where, message: 'surcharge_on_shortfall: the surcharge_percent is the rule itself' });
      }
      if (prepayment.instalments.some((i) => i.credit_percent === null)) {
        issues.push({ path: where, message: 'surcharge_on_shortfall: every instalment states its credit_percent' });
      }
    }
  }

  return issues;
}

// ---------------------------------------------------------------------------
// The seed
// ---------------------------------------------------------------------------

const sqlText = (value: string | null): string => (value === null ? 'null' : `'${value.replace(/'/g, "''")}'`);
const sqlDate = (value: string | null): string => (value === null ? 'null' : `date '${value}'`);
const sqlNumber = (value: number | null): string => (value === null ? 'null' : String(value));
const sqlBool = (value: boolean): string => (value ? 'true' : 'false');

/** A jsonb literal with its keys in a fixed order, so the same pack compiles to the same bytes. */
function sqlJson(value: unknown): string {
  return `${sqlText(JSON.stringify(sorted(value)))}::jsonb`;
}

function sorted(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(sorted);
  if (value !== null && typeof value === 'object') {
    const out: Record<string, unknown> = {};
    for (const key of Object.keys(value as Record<string, unknown>).sort()) {
      out[key] = sorted((value as Record<string, unknown>)[key]);
    }
    return out;
  }
  return value;
}

/** By code units, never by locale: the same pack compiles to the same bytes on every machine. */
const compare = (a: string, b: string): number => (a < b ? -1 : a > b ? 1 : 0);

const byCodeThenDate = <T extends { sequence?: number; code?: string; valid_from?: string }>(a: T, b: T): number =>
  (a.sequence ?? 0) - (b.sequence ?? 0) ||
  compare(a.code ?? '', b.code ?? '') ||
  compare(a.valid_from ?? '', b.valid_from ?? '');

function upsert(table: string, columns: string[], key: string[], rows: string[]): string[] {
  if (rows.length === 0) return [];
  const updated = columns.filter((column) => !key.includes(column));
  const width = Math.max(...updated.map((column) => column.length));
  return [
    `insert into ${table}`,
    `  (${columns.join(', ')})`,
    'values',
    rows.map((row) => `  (${row})`).join(',\n'),
    `on conflict (${key.join(', ')}) do update set`,
    updated.map((column) => `  ${column.padEnd(width)} = excluded.${column}`).join(',\n') + ';',
    '',
  ];
}

/**
 * `packs/<cc>/corporate_tax.json` → the reference tables of the corporate
 * income tax module, for one country.
 *
 * Every insert upserts on the key of its table, like the pack seed: a seed is
 * allowed to re-state reference data, and an installation that applies it
 * again receives what the pack now says. What an upsert cannot do is remove —
 * which is the rule anyway: a figure that stops applying gets a `valid_to`.
 */
export function compileCorporateTaxSection(
  section: PackCorporateTax,
  pack: { slug: string; name: string; version: string; country: string },
): string {
  const country = sqlText(pack.country);
  // The three columns of a validity always travel together.
  const validity = (row: Dated): string =>
    `${sqlDate(row.valid_from)}, ${sqlDate(row.valid_to)}, ${sqlText(row.valid_on)}::tax.validity_basis`;

  const out: string[] = [
    `-- Ekwo OS — ${pack.name}: the rules of this country's corporate income tax.`,
    '--',
    `-- Generated from packs/${pack.slug}/corporate_tax.json at version ${pack.version}, do not edit.`,
    `-- Change the pack and run \`ekwo pack build ${pack.slug}\`; \`ekwo pack check --all\``,
    '-- refuses a seed that is not the exact output of its pack, and the CI runs it.',
    '--',
    '-- Applied by the module migration runner — `ekwo migrate`, or `ekwo module',
    '-- migrate` — and never by the socle seed step: these tables exist only on an',
    '-- installation that carries the corporate income tax module.',
    '--',
    '-- Reference data: read where it stands, never copied into a company. A figure',
    '-- that changes is a new row with a new valid_from, so a past year keeps its answer.',
    '',
  ];

  out.push(
    ...upsert(
      'tax.country_rules',
      [
        'country', 'tax_code', 'name', 'name_i18n', 'result_statement_code', 'result_line_code',
        'result_legal_reference', 'result_source_key', 'expense_account_code', 'payable_account_code',
        'receivable_account_code', 'accounts_legal_reference', 'accounts_source_key',
        'legal_reference', 'source_key',
      ],
      ['country'],
      [
        [
          country, sqlText(section.tax.code), sqlText(section.tax.name), sqlJson(section.tax.name_i18n),
          sqlText(section.result.statement), sqlText(section.result.line),
          sqlText(section.result.legal_reference), sqlText(section.result.source),
          sqlText(section.accounts.expense), sqlText(section.accounts.payable),
          sqlText(section.accounts.receivable), sqlText(section.accounts.legal_reference),
          sqlText(section.accounts.source), sqlText(section.tax.legal_reference), sqlText(section.tax.source),
        ].join(', '),
      ],
    ),
    ...upsert(
      'tax.parameter_templates',
      ['country', 'code', 'name', 'name_i18n', 'value_type', 'legal_reference', 'source_key', 'sequence'],
      ['country', 'code'],
      [...section.parameters].sort(byCodeThenDate).map((p) =>
        [
          country, sqlText(p.code), sqlText(p.name), sqlJson(p.name_i18n),
          `${sqlText(p.type)}::tax.parameter_type`, sqlText(p.legal_reference), sqlText(p.source), p.sequence,
        ].join(', '),
      ),
    ),
    ...upsert(
      'tax.adjustment_rule_templates',
      [
        'country', 'code', 'valid_from', 'valid_to', 'valid_on', 'name', 'name_i18n', 'direction',
        'percent', 'formula', 'account_rules', 'legal_reference', 'source_key', 'sequence',
      ],
      ['country', 'code', 'valid_from'],
      [...section.adjustment_rules].sort(byCodeThenDate).map((r) =>
        [
          country, sqlText(r.code), validity(r),
          sqlText(r.name), sqlJson(r.name_i18n), `${sqlText(r.direction)}::tax.adjustment_direction`,
          sqlNumber(r.percent), r.formula === null ? 'null' : sqlJson(r.formula),
          sqlJson(r.accounts.map((a) => (a.code_to === null ? { kind: a.kind, code_from: a.code_from } : a))),
          sqlText(r.legal_reference), sqlText(r.source), r.sequence,
        ].join(', '),
      ),
    ),
    ...upsert(
      'tax.rate_templates',
      [
        'country', 'code', 'valid_from', 'valid_to', 'valid_on', 'name', 'name_i18n', 'rate', 'up_to',
        'up_to_prorata', 'conditions', 'legal_reference', 'source_key', 'sequence',
      ],
      ['country', 'code', 'valid_from'],
      [...section.rates].sort(byCodeThenDate).map((r) =>
        [
          country, sqlText(r.code), validity(r),
          sqlText(r.name), sqlJson(r.name_i18n), sqlNumber(r.rate), sqlNumber(r.up_to), sqlText(r.up_to_prorata),
          sqlJson(
            r.conditions.map((c) => ({
              parameter: c.parameter,
              test: c.test,
              ...(c.amount === null ? {} : { amount: c.amount }),
              ...(c.or_at_least === null ? {} : { or_at_least: c.or_at_least }),
              ...(c.waived_by.length === 0 ? {} : { waived_by: c.waived_by }),
            })),
          ),
          sqlText(r.legal_reference), sqlText(r.source), r.sequence,
        ].join(', '),
      ),
    ),
    ...upsert(
      'tax.loss_rule_templates',
      [
        'country', 'valid_from', 'valid_to', 'valid_on', 'floor_amount', 'percent_above',
        'carry_forward_years', 'legal_reference', 'source_key',
      ],
      ['country', 'valid_from'],
      [...section.loss_carryforward].sort(byCodeThenDate).map((l) =>
        [
          country, validity(l),
          sqlNumber(l.floor), sqlNumber(l.percent_above), sqlNumber(l.years),
          sqlText(l.legal_reference), sqlText(l.source),
        ].join(', '),
      ),
    ),
    ...upsert(
      'tax.prepayment_templates',
      [
        'country', 'valid_from', 'valid_to', 'valid_on', 'method', 'month_basis', 'instalments',
        'surcharge_percent', 'exempt_up_to', 'legal_reference', 'source_key',
      ],
      ['country', 'valid_from'],
      [...section.prepayments].sort(byCodeThenDate).map((p) =>
        [
          country, validity(p),
          sqlText(p.method), sqlText(p.month_basis),
          sqlJson(
            [...p.instalments]
              .sort((a, b) => a.sequence - b.sequence)
              .map((i) => ({
                sequence: i.sequence,
                month: i.month,
                day: i.day,
                ...(i.share_percent === null ? {} : { share_percent: i.share_percent }),
                ...(i.credit_percent === null ? {} : { credit_percent: i.credit_percent }),
              })),
          ),
          sqlNumber(p.surcharge_percent), sqlNumber(p.exempt_up_to), sqlText(p.legal_reference), sqlText(p.source),
        ].join(', '),
      ),
    ),
    ...upsert(
      'tax.credit_templates',
      [
        'country', 'code', 'valid_from', 'valid_to', 'valid_on', 'name', 'name_i18n', 'refundable',
        'legal_reference', 'source_key', 'sequence',
      ],
      ['country', 'code', 'valid_from'],
      [...section.credits].sort(byCodeThenDate).map((c) =>
        [
          country, sqlText(c.code), validity(c),
          sqlText(c.name), sqlJson(c.name_i18n), sqlBool(c.refundable),
          sqlText(c.legal_reference), sqlText(c.source), c.sequence,
        ].join(', '),
      ),
    ),
  );

  return `${out.join('\n')}`;
}
