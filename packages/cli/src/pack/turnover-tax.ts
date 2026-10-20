/**
 * `packs/<cc>/turnover_tax.json` — the regimes of a country where one tax on
 * turnover replaces VAT (decision 0080).
 *
 * It is read with the rest of the pack, by the one reader a pack has, and it
 * compiles into statements appended to the pack's socle seed, written only
 * for a pack that carries the file, so the seed of every other pack is byte
 * for byte what it was. What is here is the three things a section owes: its
 * shape once read, what it obliges the rest of the pack to say, and the SQL it
 * becomes.
 *
 * A regime is data and never an expression: the kinds of tax it replaces, the
 * window its bracket is read over, the account its tax is an expense on, the
 * form it is declared on, and a table of brackets — a threshold, a nominal
 * rate, a deduction — each dated and cited.
 */

import type { Issue } from './schema.js';
import type { PackChart } from './read.js';

/** One bracket of a regime: up to a base, a nominal rate less a deduction. */
export interface PackTurnoverBracket {
  valid_from: string;
  valid_to: string | null;
  /** The highest base the bracket takes, inclusive, as a decimal string. Null: everything above. */
  up_to: string | null;
  /** Percent, as a decimal string. */
  rate: string;
  /** Subtracted from base x rate, as a decimal string. */
  deduction: string;
  legal_reference: string;
  source: string | null;
  sequence: number;
}

/** The form a regime's tax is declared on, a row of `tax_report_templates`. */
export interface PackTurnoverReport {
  code: string;
  name: string;
  periods: string[];
  period_default: string | null;
  valid_from: string;
  legal_reference: string;
  deadline: { rule: string; day: number | null; legal_reference: string; source: string | null } | null;
}

/** One regime of the country. */
export interface PackTurnoverRegime {
  code: string;
  name: string;
  replaces: string[];
  window: { months: number; includes_period: boolean; short: 'annualise' | 'as_is' } | null;
  expense_account: string;
  legal_reference: string;
  source: string | null;
  report: PackTurnoverReport;
  brackets: PackTurnoverBracket[];
  sequence: number;
}

export interface PackTurnoverTax {
  regimes: PackTurnoverRegime[];
}

type Raw = Record<string, unknown>;

const str = (value: unknown): string | null => (value === undefined || value === null ? null : String(value));

/** The file as the schema let it through, with every optional key resolved. */
export function normaliseTurnoverTax(raw: Raw): PackTurnoverTax {
  const regimes = ((raw['regimes'] ?? []) as Raw[]).map((regime, index): PackTurnoverRegime => {
    const window = regime['window'] as Raw | undefined;
    const report = (regime['report'] ?? {}) as Raw;
    const deadline = report['deadline'] as Raw | undefined;
    return {
      code: String(regime['code']),
      name: String(regime['name']),
      replaces: ((regime['replaces'] ?? []) as unknown[]).map(String),
      window:
        window === undefined
          ? null
          : {
              months: Number(window['months']),
              includes_period: window['includes_period'] === true,
              short: window['short'] === 'as_is' ? 'as_is' : 'annualise',
            },
      expense_account: String(regime['expense_account']),
      legal_reference: String(regime['legal_reference']),
      source: str(regime['source']),
      report: {
        code: String(report['code']),
        name: String(report['name']),
        periods: ((report['periods'] ?? []) as unknown[]).map(String),
        period_default: str(report['period_default']),
        valid_from: String(report['valid_from']),
        legal_reference: String(report['legal_reference']),
        deadline:
          deadline === undefined
            ? null
            : {
                rule: String(deadline['rule']),
                day: deadline['day'] === undefined ? null : Number(deadline['day']),
                legal_reference: String(deadline['legal_reference']),
                source: str(deadline['source']),
              },
      },
      brackets: ((regime['brackets'] ?? []) as Raw[]).map((bracket, position) => ({
        valid_from: String(bracket['valid_from']),
        valid_to: str(bracket['valid_to']),
        up_to: str(bracket['up_to']),
        rate: String(bracket['rate']),
        deduction: str(bracket['deduction']) ?? '0',
        legal_reference: String(bracket['legal_reference']),
        source: str(bracket['source']),
        sequence: (position + 1) * 10,
      })),
      sequence: (index + 1) * 10,
    };
  });
  return { regimes };
}

/** Every reference the section makes into the register of sources. */
export function turnoverTaxSources(section: PackTurnoverTax | null): { path: string; source: string | null }[] {
  if (section === null) return [];
  return section.regimes.flatMap((regime) => [
    { path: `turnover_tax.json ${regime.code}`, source: regime.source },
    ...(regime.report.deadline === null
      ? []
      : [{ path: `turnover_tax.json ${regime.code} report.deadline`, source: regime.report.deadline.source }]),
    ...regime.brackets.map((bracket) => ({
      path: `turnover_tax.json ${regime.code} brackets.${bracket.valid_from}.${bracket.sequence}`,
      source: bracket.source,
    })),
  ]);
}

/**
 * What the section obliges the rest of the pack to hold, and what it has to
 * hold itself: an expense account every chart carries, a form of its own
 * apart from the periodic return, and brackets that rise.
 */
export function turnoverTaxReferences(
  section: PackTurnoverTax,
  charts: PackChart[],
  periodicReturnCode: string | null,
): Issue[] {
  const issues: Issue[] = [];
  const seen = new Set<string>();
  for (const regime of section.regimes) {
    const at = (what: string): string => `turnover_tax.json ${regime.code}${what === '' ? '' : ` ${what}`}`;
    if (seen.has(regime.code)) issues.push({ path: at(''), message: 'the regime is declared twice' });
    seen.add(regime.code);

    for (const chart of charts) {
      if (!chart.accounts.some((account) => account.code === regime.expense_account)) {
        issues.push({
          path: at('expense_account'),
          message: `${regime.expense_account} is not an account of the chart ${chart.code}`,
        });
      }
    }
    if (regime.report.code === periodicReturnCode) {
      issues.push({
        path: at('report.code'),
        message: `${regime.report.code} is the periodic return of tax_report.json; a regime is declared on a form of its own`,
      });
    }
    if (regime.report.period_default !== null && !regime.report.periods.includes(regime.report.period_default)) {
      issues.push({ path: at('report.period_default'), message: `${regime.report.period_default} is not one of its periods` });
    }

    // Each version of the table, by the day it applies from: thresholds that
    // rise, and one bracket without a threshold, the last.
    const versions = new Map<string, PackTurnoverBracket[]>();
    for (const bracket of regime.brackets) {
      versions.set(bracket.valid_from, [...(versions.get(bracket.valid_from) ?? []), bracket]);
    }
    for (const [from, brackets] of versions) {
      const open = brackets.filter((bracket) => bracket.up_to === null);
      if (open.length !== 1 || brackets[brackets.length - 1]?.up_to !== null) {
        issues.push({
          path: at(`brackets.${from}`),
          message: 'a table of brackets ends with exactly one bracket without up_to, and only that one',
        });
      }
      const thresholds = brackets.filter((bracket) => bracket.up_to !== null).map((bracket) => Number(bracket.up_to));
      if (thresholds.some((value, i) => i > 0 && value <= (thresholds[i - 1] ?? 0))) {
        issues.push({ path: at(`brackets.${from}`), message: 'the thresholds of up_to rise from one bracket to the next' });
      }
    }
  }
  return issues;
}

const sqlText = (value: string | null): string => (value === null ? 'null' : `'${value.replace(/'/g, "''")}'`);
const sqlDate = (value: string | null): string => (value === null ? 'null' : `date '${value}'`);

/**
 * The SQL of the section, appended to the pack's socle seed. A pack carries
 * the whole list: a regime it no longer declares is removed with its
 * brackets, and the brackets of one it declares are written again.
 */
export function compileTurnoverTaxSection(section: PackTurnoverTax, country: string): string[] {
  const c = sqlText(country);
  const codes = section.regimes.map((regime) => sqlText(regime.code));
  const out: string[] = [
    '-- The regimes where a tax on turnover replaces VAT (turnover_tax.json, decision 0080).',
    codes.length === 0
      ? `delete from turnover_tax_regimes where country = ${c};`
      : `delete from turnover_tax_regimes where country = ${c} and code <> all (array[${codes.join(', ')}]);`,
    `delete from turnover_tax_brackets where country = ${c};`,
    '',
  ];
  for (const regime of section.regimes) {
    const report = regime.report;
    out.push(
      'insert into tax_report_templates',
      '  (country, code, name, periods, period_default, valid_from, legal_reference, is_periodic_return,',
      '   deadline_rule, deadline_day, deadline_reference, deadline_source_key)',
      'values',
      `  (${c}, ${sqlText(report.code)}, ${sqlText(report.name)}, ` +
        `array[${report.periods.map(sqlText).join(', ')}]::declaration_period[], ` +
        `${report.period_default === null ? 'null' : `${sqlText(report.period_default)}::declaration_period`}, ` +
        `${sqlDate(report.valid_from)}, ${sqlText(report.legal_reference)}, false, ` +
        `${report.deadline === null ? 'null' : `${sqlText(report.deadline.rule)}::filing_deadline_rule`}, ` +
        `${report.deadline?.day ?? 'null'}, ${sqlText(report.deadline?.legal_reference ?? null)}, ` +
        `${sqlText(report.deadline?.source ?? null)})`,
      'on conflict (country, code) do update set',
      '  name                = excluded.name,',
      '  periods             = excluded.periods,',
      '  period_default      = excluded.period_default,',
      '  valid_from          = excluded.valid_from,',
      '  legal_reference     = excluded.legal_reference,',
      '  is_periodic_return  = excluded.is_periodic_return,',
      '  deadline_rule       = excluded.deadline_rule,',
      '  deadline_day        = excluded.deadline_day,',
      '  deadline_reference  = excluded.deadline_reference,',
      '  deadline_source_key = excluded.deadline_source_key;',
      '',
      'insert into turnover_tax_regimes',
      '  (country, code, name, replaces, report_code, window_months, window_includes_period, short_window,',
      '   expense_account_code, legal_reference, source_key, sequence)',
      'values',
      `  (${c}, ${sqlText(regime.code)}, ${sqlText(regime.name)}, ` +
        `array[${regime.replaces.map(sqlText).join(', ')}]::tax_kind[], ${sqlText(report.code)}, ` +
        `${regime.window?.months ?? 'null'}, ${regime.window?.includes_period === true ? 'true' : 'false'}, ` +
        `${sqlText(regime.window?.short ?? 'annualise')}, ${sqlText(regime.expense_account)}, ` +
        `${sqlText(regime.legal_reference)}, ${sqlText(regime.source)}, ${regime.sequence})`,
      'on conflict (country, code) do update set',
      '  name                   = excluded.name,',
      '  replaces               = excluded.replaces,',
      '  report_code            = excluded.report_code,',
      '  window_months          = excluded.window_months,',
      '  window_includes_period = excluded.window_includes_period,',
      '  short_window           = excluded.short_window,',
      '  expense_account_code   = excluded.expense_account_code,',
      '  legal_reference        = excluded.legal_reference,',
      '  source_key             = excluded.source_key,',
      '  sequence               = excluded.sequence;',
      '',
    );
    if (regime.brackets.length > 0) {
      out.push(
        'insert into turnover_tax_brackets',
        '  (country, regime_code, valid_from, valid_to, sequence, up_to, nominal_rate, deduction, legal_reference, source_key)',
        'values',
        regime.brackets
          .map(
            (b) =>
              `  (${c}, ${sqlText(regime.code)}, ${sqlDate(b.valid_from)}, ${sqlDate(b.valid_to)}, ${b.sequence}, ` +
              `${b.up_to ?? 'null'}, ${b.rate}, ${b.deduction}, ${sqlText(b.legal_reference)}, ${sqlText(b.source)})`,
          )
          .join(',\n') + ';',
        '',
      );
    }
  }
  return out;
}
