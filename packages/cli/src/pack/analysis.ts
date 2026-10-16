/**
 * `packs/<cc>/analysis.json` — what the accounts of a pack mean to an analysis
 * of the books.
 *
 * A statement knows its national lines and nothing else: rubric `21/28` of a
 * Belgian balance sheet, line `CO` of a French one. A ratio needs the same
 * figure in every country — the revenue, the equity, the current assets — so
 * this section names a closed list of generic aggregates, each made of the
 * pack's own accounts by the rules a statement line already uses. How an
 * aggregate is read, on the movements of a period or on the balance at its
 * end, and the sign it comes back with, belong to the aggregate and are the
 * core's: `analysis_aggregates`, read by `financial_analysis()`. A pack says
 * which accounts, and where that reading of its chart comes from.
 *
 * Optional, and never borrowed from another country: a company whose pack
 * carries no section is read through the framework pack's own section
 * (`packs/generic/analysis.json`), which takes account types only and leaves
 * out what no account type tells apart — never through another country's
 * chart.
 */

import type { Issue } from './schema.js';
import type { PackChart, PackStatementRule } from './read.js';
import { ruleTakes } from './rules.js';

/**
 * The aggregates a pack must define once it declares the section: the four a
 * reader of any analysis needs first — what the company sells, what it earns,
 * what it owns and what of that is its own — and the figures `total_assets =
 * equity + liabilities` is read from.
 */
export const REQUIRED_AGGREGATES = ['revenue', 'net_result', 'equity', 'total_assets'] as const;

/** One aggregate of `analysis.json`. */
export interface PackAnalysisAggregate {
  code: string;
  legal_reference: string;
  /** Key of the register entry where that reference can be read. */
  source: string | null;
  rules: PackStatementRule[];
}

/** `analysis.json`, normalised. */
export interface PackAnalysis {
  /** The charts the rules are written for: the default chart where the section names none. */
  charts: string[];
  aggregates: PackAnalysisAggregate[];
}

type Raw = Record<string, unknown>;

export function normaliseAnalysis(raw: Raw, charts: PackChart[]): PackAnalysis {
  const fallback = charts.find((chart) => chart.is_default)?.code ?? charts[0]?.code;
  return {
    charts: (raw['charts'] as string[] | undefined) ?? (fallback === undefined ? [] : [fallback]),
    aggregates: ((raw['aggregates'] ?? []) as Raw[]).map((aggregate) => ({
      code: String(aggregate['code']),
      legal_reference: String(aggregate['legal_reference'] ?? ''),
      source: (aggregate['source'] as string | undefined) ?? null,
      rules: ((aggregate['rules'] ?? []) as Raw[]).map((rule, position) => ({
        kind: rule['kind'] as PackStatementRule['kind'],
        code_from: (rule['code_from'] as string | undefined) ?? null,
        code_to: (rule['code_to'] as string | undefined) ?? null,
        account_type: (rule['account_type'] as string | undefined) ?? null,
        side: ((rule['side'] as string | undefined) ?? 'any') as PackStatementRule['side'],
        sequence: typeof rule['sequence'] === 'number' ? rule['sequence'] : (position + 1) * 10,
      })),
    })),
  };
}

/**
 * What the schema cannot say about the section.
 *
 * A chart it names that the pack does not carry. An aggregate defined twice.
 * One of the four every analysis starts from left out. A rule missing the
 * arguments of its kind — the table it compiles into refuses that row, and
 * the seed would stop halfway. And a rule that reaches no account of a chart
 * it is written for: a range typed one digit off reads as a definition and
 * catches nothing, and an aggregate that is silently nil is the figure this
 * check exists to stop.
 */
export function analysisReferences(section: PackAnalysis, charts: PackChart[]): Issue[] {
  const issues: Issue[] = [];
  const path = 'analysis.json';

  const covered: PackChart[] = [];
  for (const code of section.charts) {
    const chart = charts.find((c) => c.code === code);
    if (chart === undefined) {
      issues.push({ path: `${path} charts`, message: `${code} is not a chart of this pack` });
      continue;
    }
    if (covered.includes(chart)) {
      issues.push({ path: `${path} charts`, message: `${code} is named twice` });
      continue;
    }
    covered.push(chart);
  }

  const seen = new Set<string>();
  for (const aggregate of section.aggregates) {
    if (seen.has(aggregate.code)) {
      issues.push({ path: `${path} ${aggregate.code}`, message: 'is defined twice; an aggregate is one list of rules' });
    }
    seen.add(aggregate.code);
  }
  for (const code of REQUIRED_AGGREGATES) {
    if (!seen.has(code)) {
      issues.push({
        path: `${path} aggregates`,
        message: `defines no ${code}. A pack that declares the section defines ${REQUIRED_AGGREGATES.join(', ')} at least`,
      });
    }
  }

  for (const aggregate of section.aggregates) {
    for (const [index, rule] of aggregate.rules.entries()) {
      const where = `${path} ${aggregate.code}.rules[${index}]`;
      const problem = ruleArguments(rule);
      if (problem !== null) {
        issues.push({ path: where, message: problem });
        continue;
      }
      for (const chart of covered) {
        if (!chart.accounts.some((account) => ruleTakes(rule, account))) {
          issues.push({
            path: where,
            message: `${describeRule(rule)} reaches no account of the chart ${chart.code}`,
          });
        }
      }
    }
  }

  return issues;
}

/** The arguments each kind of rule takes, as `analysis_rules` constrains them. */
function ruleArguments(rule: PackStatementRule): string | null {
  switch (rule.kind) {
    case 'account_type':
      if (rule.account_type === null) return 'an account_type rule names the account_type it takes';
      if (rule.code_from !== null || rule.code_to !== null) return 'an account_type rule takes no code_from or code_to';
      return null;
    case 'code_range':
      if (rule.code_from === null || rule.code_to === null) return 'a code_range rule names both code_from and code_to';
      if (rule.account_type !== null) return 'a code_range rule takes no account_type';
      return null;
    default:
      if (rule.code_from === null) return `a ${rule.kind} rule names its code in code_from`;
      if (rule.code_to !== null) return `code_to belongs to a code_range rule, not to ${rule.kind}`;
      if (rule.account_type !== null) return `a ${rule.kind} rule takes no account_type`;
      return null;
  }
}

function describeRule(rule: PackStatementRule): string {
  const side = rule.side === 'any' ? '' : ` (${rule.side} side)`;
  switch (rule.kind) {
    case 'account_type':
      return `account_type ${rule.account_type ?? ''}${side}`;
    case 'code_range':
      return `code_range ${rule.code_from ?? ''}..${rule.code_to ?? ''}${side}`;
    default:
      return `${rule.kind} ${rule.code_from ?? ''}${side}`;
  }
}

/** Every reference the section makes to the register of sources. */
export function analysisSources(section: PackAnalysis | null): { path: string; source: string | null }[] {
  return (section?.aggregates ?? []).map((aggregate) => ({
    path: `analysis.json ${aggregate.code}`,
    source: aggregate.source,
  }));
}

function text(value: string | null | undefined): string {
  if (value === null || value === undefined) return 'null';
  return `'${value.replace(/'/g, "''")}'`;
}

/**
 * The SQL of the section, for the pack seed: one `analysis_templates` row per
 * chart and aggregate, and its rules in `analysis_rules`.
 *
 * The seeds are re-applied by every `ekwo migrate`, so what the tables hold for
 * this country is the pack's and nothing else: a rule or an aggregate a
 * release dropped is deleted here, as the rules of a statement are, because a
 * range left behind by an upgrade would keep adding an account to a figure
 * the pack no longer says it belongs to.
 */
export function compileAnalysis(section: PackAnalysis | null, country: string): string[] {
  // A pack that has never declared the section writes nothing at all, so its
  // seed keeps running on a schema older than the analysis tables.
  if (section === null) return [];
  return compileRows(section, {
    columns: ['country', 'chart_code'],
    scope: (alias) => `${alias}.country = ${text(country)}`,
    key: ['chart_code'],
    parts: [...section.charts].sort().map((chart) => ({ owner: [text(country), text(chart)], key: [text(chart)] })),
  });
}

/**
 * The SQL of a framework's section, for the framework seed: the same rows,
 * owned by the framework rather than by a country and a chart — `country` and
 * `chart_code` stay null and `framework` carries the framework's code, which
 * the caller reads from the manifest. `financial_analysis()` reads them for a
 * company whose country pack defines no analysis for its chart.
 *
 * Idempotent the way a country's section is: the delete is scoped to this
 * framework's rows, so a release that drops an aggregate drops its row, and
 * no country's row is touched.
 */
export function compileFrameworkAnalysis(section: PackAnalysis | null, framework: string): string[] {
  if (section === null) return [];
  return compileRows(section, {
    columns: ['framework'],
    scope: (alias) => `${alias}.country is null and ${alias}.framework = ${text(framework)}`,
    key: [],
    parts: [{ owner: [text(framework)], key: [] }],
  });
}

/** Whose rows a section compiles into, and how its seed finds them again. */
interface Owner {
  /** The columns that say whose a row is, written before `aggregate`. */
  columns: string[];
  /** The condition that scopes the deletes to this owner's rows. */
  scope: (alias: string) => string;
  /** The columns of `columns` that vary inside this owner, part of the keys kept. */
  key: string[];
  /** One entry per chart, or one for a framework: the values of `columns` and of `key`. */
  parts: { owner: string[]; key: string[] }[];
}

function compileRows(section: PackAnalysis, owner: Owner): string[] {
  const out: string[] = [];
  const templates: string[] = [];
  const rules: string[] = [];
  const templateKeys: string[] = [];
  const ruleKeys: string[] = [];

  const aggregates = [...section.aggregates].sort((a, b) => (a.code < b.code ? -1 : a.code > b.code ? 1 : 0));
  for (const part of owner.parts) {
    for (const aggregate of aggregates) {
      templates.push(
        `  (${[...part.owner, text(aggregate.code), text(aggregate.legal_reference), text(aggregate.source)].join(', ')})`,
      );
      templateKeys.push(`(${[...part.key, text(aggregate.code)].join(', ')})`);
      for (const rule of [...aggregate.rules].sort((a, b) => a.sequence - b.sequence)) {
        rules.push(
          `  (${[
            ...part.owner,
            text(aggregate.code),
            String(rule.sequence),
            text(rule.kind),
            text(rule.code_from),
            text(rule.code_to),
            text(rule.account_type),
            text(rule.side),
          ].join(', ')})`,
        );
        ruleKeys.push(`(${[...part.key, text(aggregate.code), String(rule.sequence)].join(', ')})`);
      }
    }
  }

  const keyOf = (alias: string, columns: string[]): string =>
    `(${[...owner.key, ...columns].map((column) => `${alias}.${column}`).join(', ')})`;
  out.push(
    'delete from analysis_rules r',
    ` where ${owner.scope('r')}`,
    ...(ruleKeys.length > 0
      ? [`   and ${keyOf('r', ['aggregate', 'sequence'])} not in (`, `     values ${ruleKeys.join(',\n            ')}`, '   );']
      : ['   ;']),
    '',
    'delete from analysis_templates t',
    ` where ${owner.scope('t')}`,
    ...(templateKeys.length > 0
      ? [`   and ${keyOf('t', ['aggregate'])} not in (`, `     values ${templateKeys.join(',\n            ')}`, '   );']
      : ['   ;']),
    '',
  );

  if (templates.length === 0) return out;

  const columns = owner.columns.join(', ');
  const values = owner.columns.map((column) => `v.${column}`).join(', ');
  out.push(
    'insert into analysis_templates',
    `  (${columns}, aggregate, legal_reference, source_key)`,
    'values',
    templates.join(',\n'),
    `on conflict (${columns}, aggregate) do update set`,
    '  legal_reference = excluded.legal_reference,',
    '  source_key      = excluded.source_key;',
    '',
    'insert into analysis_rules',
    `  (${columns}, aggregate, sequence, rule_kind, code_from, code_to,`,
    '   account_type, balance_side)',
    `select ${values}, v.aggregate, v.sequence, v.rule_kind, v.code_from,`,
    '       v.code_to, v.account_type::account_type, v.balance_side',
    '  from (values',
    rules.map((row) => `  ${row}`).join(',\n'),
    `  ) as v (${columns}, aggregate, sequence, rule_kind, code_from, code_to,`,
    '          account_type, balance_side)',
    `on conflict (${columns}, aggregate, sequence) do update set`,
    '  rule_kind    = excluded.rule_kind,',
    '  code_from    = excluded.code_from,',
    '  code_to      = excluded.code_to,',
    '  account_type = excluded.account_type,',
    '  balance_side = excluded.balance_side;',
    '',
  );
  return out;
}
