/**
 * `packs/<cc>/vat_schemes.json` — the VAT schemes of a country.
 *
 * A scheme is the fact that decides which declarations a company files at
 * all. Most countries have more than one: a normal scheme with a monthly or
 * quarterly return, a simplified one with an annual return and payments on
 * account during the year, and a small business exemption under which no VAT
 * is charged and no periodic return is filed. Before this file a pack could
 * only carry the forms; which of them a given company files was a fact
 * nobody recorded.
 *
 * It is read with the rest of the pack and compiles into statements appended
 * to the pack's socle seed, written only for a pack that carries the file, so
 * the seed of every other pack is byte for byte what it was. A scheme is data
 * and never an expression: the forms it files and on which cadences, whether
 * VAT is charged, ceilings as a measure, an amount, a currency and the text
 * that sets them, and a schedule of instalments as months and percentages of
 * a box of the previous year's return.
 */

import type { Issue } from './schema.js';
import type { PackReport } from './read.js';
import { resolveBoxRef } from './read.js';

/** A form filed under a scheme, and the cadences it is filed on there. */
export interface PackVatSchemeForm {
  report: string;
  periods: string[];
  period_default: string | null;
}

/**
 * One ceiling of a scheme: up to this amount of this measure, a company may
 * be on it. Closed vocabularies for both the measure and the activity it is
 * counted on.
 */
export interface PackVatSchemeCeiling {
  measure: 'turnover_previous_year' | 'turnover_current_year' | 'tax_previous_year';
  activity: 'all' | 'goods' | 'services';
  /** Decimal string. */
  amount: string;
  currency: string;
  valid_from: string;
  valid_to: string | null;
  legal_reference: string;
  source: string | null;
  sequence: number;
}

/** One payment on account of the year's return. */
export interface PackVatSchemeInstalment {
  /** Month of the year the return is for, 1 to 12. */
  month: number;
  /** Day of that month, or null where the day depends on the taxpayer. */
  day: number | null;
  /** Percent of the base, as a decimal string. */
  percent: string;
  sequence: number;
}

/**
 * The payments on account a scheme asks for: on account of which form, a
 * percentage of which box of the previous year's return, nothing at all
 * below a minimum base, and when.
 */
export interface PackVatSchemeInstalments {
  report: string;
  base_report: string;
  base_box: string;
  base_kind: 'base' | 'tax' | 'total';
  /** Decimal string, or null where every base gives instalments. */
  minimum_base: string | null;
  legal_reference: string;
  source: string | null;
  schedule: PackVatSchemeInstalment[];
}

export interface PackVatScheme {
  code: string;
  name: string;
  /** False under a small business exemption: the company charges no VAT and recovers none. */
  charges_vat: boolean;
  legal_reference: string;
  source: string | null;
  forms: PackVatSchemeForm[];
  ceilings: PackVatSchemeCeiling[];
  instalments: PackVatSchemeInstalments | null;
  sequence: number;
}

export interface PackVatSchemes {
  schemes: PackVatScheme[];
}

type Raw = Record<string, unknown>;

const str = (value: unknown): string | null => (value === undefined || value === null ? null : String(value));

/** The file as the schema let it through, with every optional key resolved. */
export function normaliseVatSchemes(raw: unknown[]): PackVatSchemes {
  const schemes = (raw as Raw[]).map((scheme, index): PackVatScheme => {
    const instalments = scheme['instalments'] as Raw | undefined;
    const base = (instalments?.['base'] ?? {}) as Raw;
    const [baseBox, baseKind] = String(base['box'] ?? '').split(':');
    return {
      code: String(scheme['code']),
      name: String(scheme['name']),
      charges_vat: scheme['charges_vat'] !== false,
      legal_reference: String(scheme['legal_reference']),
      source: str(scheme['source']),
      forms: ((scheme['forms'] ?? []) as Raw[]).map((form) => ({
        report: String(form['report']),
        periods: ((form['periods'] ?? []) as unknown[]).map(String),
        period_default: str(form['period_default']),
      })),
      ceilings: ((scheme['ceilings'] ?? []) as Raw[]).map((ceiling, position) => ({
        measure: ceiling['measure'] as PackVatSchemeCeiling['measure'],
        activity: (ceiling['activity'] as PackVatSchemeCeiling['activity'] | undefined) ?? 'all',
        amount: String(ceiling['amount']),
        currency: String(ceiling['currency']),
        valid_from: String(ceiling['valid_from']),
        valid_to: str(ceiling['valid_to']),
        legal_reference: String(ceiling['legal_reference']),
        source: str(ceiling['source']),
        sequence: (position + 1) * 10,
      })),
      instalments:
        instalments === undefined
          ? null
          : {
              report: String(instalments['report']),
              base_report: String(base['report']),
              base_box: baseBox ?? '',
              base_kind: (baseKind as PackVatSchemeInstalments['base_kind'] | undefined) ?? 'total',
              minimum_base: str(instalments['minimum_base']),
              legal_reference: String(instalments['legal_reference']),
              source: str(instalments['source']),
              schedule: ((instalments['schedule'] ?? []) as Raw[]).map((row, position) => ({
                month: Number(row['month']),
                day: row['day'] === undefined || row['day'] === null ? null : Number(row['day']),
                percent: String(row['percent']),
                sequence: position + 1,
              })),
            },
      sequence: (index + 1) * 10,
    };
  });
  return { schemes };
}

/** Every reference the section makes into the register of sources. */
export function vatSchemeSources(section: PackVatSchemes | null): { path: string; source: string | null }[] {
  if (section === null) return [];
  return section.schemes.flatMap((scheme) => [
    { path: `vat_schemes.json ${scheme.code}`, source: scheme.source },
    ...scheme.ceilings.map((ceiling) => ({
      path: `vat_schemes.json ${scheme.code} ceilings.${ceiling.sequence}`,
      source: ceiling.source,
    })),
    ...(scheme.instalments === null
      ? []
      : [{ path: `vat_schemes.json ${scheme.code} instalments`, source: scheme.instalments.source }]),
  ]);
}

/**
 * What the section obliges the rest of the pack to hold: every form a scheme
 * names is a form of `tax_report.json`, filed on cadences that form accepts;
 * the instalments are on account of a form the scheme files and read a box
 * that exists; and a ceiling is in the pack's currency.
 */
export function vatSchemeReferences(section: PackVatSchemes, reports: PackReport[], currency: string | undefined): Issue[] {
  const issues: Issue[] = [];
  const seen = new Set<string>();
  for (const scheme of section.schemes) {
    const at = (what: string): string => `vat_schemes.json ${scheme.code}${what === '' ? '' : ` ${what}`}`;
    if (seen.has(scheme.code)) issues.push({ path: at(''), message: 'the scheme is declared twice' });
    seen.add(scheme.code);

    const filed = new Set<string>();
    for (const form of scheme.forms) {
      const report = reports.find((candidate) => candidate.code === form.report);
      if (report === undefined) {
        issues.push({ path: at(`forms.${form.report}`), message: `${form.report} is not a form of tax_report.json` });
        continue;
      }
      if (filed.has(form.report)) issues.push({ path: at(`forms.${form.report}`), message: 'the form is named twice' });
      filed.add(form.report);
      for (const period of form.periods) {
        if (!report.periods.includes(period)) {
          issues.push({
            path: at(`forms.${form.report}.periods`),
            message: `${period} is not a cadence ${form.report} is filed on (${report.periods.join(', ')})`,
          });
        }
      }
      if (form.period_default !== null && !form.periods.includes(form.period_default)) {
        issues.push({
          path: at(`forms.${form.report}.period_default`),
          message: `${form.period_default} is not one of the cadences this scheme files ${form.report} on`,
        });
      }
    }

    for (const ceiling of scheme.ceilings) {
      if (currency !== undefined && ceiling.currency !== currency) {
        issues.push({
          path: at(`ceilings.${ceiling.sequence}`),
          message: `the ceiling is in ${ceiling.currency} and the pack keeps its books in ${currency}`,
        });
      }
      if (ceiling.valid_to !== null && ceiling.valid_to < ceiling.valid_from) {
        issues.push({ path: at(`ceilings.${ceiling.sequence}`), message: 'valid_to is before valid_from' });
      }
    }

    const instalments = scheme.instalments;
    if (instalments !== null) {
      if (!filed.has(instalments.report)) {
        issues.push({
          path: at('instalments.report'),
          message: `${instalments.report} is not a form this scheme files; instalments are paid on account of one`,
        });
      }
      const base = reports.find((candidate) => candidate.code === instalments.base_report);
      if (base === undefined) {
        issues.push({ path: at('instalments.base'), message: `${instalments.base_report} is not a form of tax_report.json` });
      } else {
        const target = resolveBoxRef(`${instalments.base_box}:${instalments.base_kind}`, base.boxes);
        if (typeof target === 'string') issues.push({ path: at('instalments.base'), message: `${base.code}: ${target}` });
      }
      const total = instalments.schedule.reduce((sum, row) => sum + Number(row.percent), 0);
      if (total > 100) {
        issues.push({ path: at('instalments.schedule'), message: `the instalments add up to ${total} % of the base` });
      }
      const months = instalments.schedule.map((row) => row.month);
      if (months.some((month, i) => i > 0 && month <= (months[i - 1] ?? 0))) {
        issues.push({ path: at('instalments.schedule'), message: 'the instalments are listed in the order they fall due, one per month' });
      }
    }
  }
  return issues;
}

const sqlText = (value: string | null): string => (value === null ? 'null' : `'${value.replace(/'/g, "''")}'`);
const sqlDate = (value: string | null): string => (value === null ? 'null' : `date '${value}'`);
const sqlPeriods = (periods: string[]): string => `array[${periods.map(sqlText).join(', ')}]::declaration_period[]`;

/**
 * The SQL of the section, appended to the pack's socle seed. A pack carries
 * the whole list, so the rows of the country are written again from it; a
 * scheme a company is on is kept by the foreign key of company_vat_schemes,
 * which refuses the delete rather than leave a company on nothing.
 */
export function compileVatSchemesSection(section: PackVatSchemes, country: string): string[] {
  const c = sqlText(country);
  const codes = section.schemes.map((scheme) => sqlText(scheme.code));
  const out: string[] = [
    '-- The VAT schemes of the country (vat_schemes.json).',
    codes.length === 0
      ? `delete from vat_schemes where country = ${c};`
      : `delete from vat_schemes where country = ${c} and code <> all (array[${codes.join(', ')}]);`,
    `delete from vat_scheme_forms where country = ${c};`,
    `delete from vat_scheme_ceilings where country = ${c};`,
    `delete from vat_scheme_instalments where country = ${c};`,
    '',
  ];
  for (const scheme of section.schemes) {
    const s = sqlText(scheme.code);
    out.push(
      'insert into vat_schemes (country, code, name, charges_vat, legal_reference, source_key, sequence)',
      'values',
      `  (${c}, ${s}, ${sqlText(scheme.name)}, ${scheme.charges_vat ? 'true' : 'false'}, ` +
        `${sqlText(scheme.legal_reference)}, ${sqlText(scheme.source)}, ${scheme.sequence})`,
      'on conflict (country, code) do update set',
      '  name            = excluded.name,',
      '  charges_vat     = excluded.charges_vat,',
      '  legal_reference = excluded.legal_reference,',
      '  source_key      = excluded.source_key,',
      '  sequence        = excluded.sequence;',
      '',
    );
    if (scheme.forms.length > 0) {
      out.push(
        'insert into vat_scheme_forms (country, scheme_code, report_code, periods, period_default)',
        'values',
        scheme.forms
          .map(
            (form) =>
              `  (${c}, ${s}, ${sqlText(form.report)}, ${sqlPeriods(form.periods)}, ` +
              `${form.period_default === null ? 'null' : `${sqlText(form.period_default)}::declaration_period`})`,
          )
          .join(',\n') + ';',
        '',
      );
    }
    if (scheme.ceilings.length > 0) {
      out.push(
        'insert into vat_scheme_ceilings',
        '  (country, scheme_code, sequence, measure, activity, amount, currency_code, valid_from, valid_to,',
        '   legal_reference, source_key)',
        'values',
        scheme.ceilings
          .map(
            (ceiling) =>
              `  (${c}, ${s}, ${ceiling.sequence}, ${sqlText(ceiling.measure)}, ${sqlText(ceiling.activity)}, ` +
              `${ceiling.amount}, ${sqlText(ceiling.currency)}, ${sqlDate(ceiling.valid_from)}, ${sqlDate(ceiling.valid_to)}, ` +
              `${sqlText(ceiling.legal_reference)}, ${sqlText(ceiling.source)})`,
          )
          .join(',\n') + ';',
        '',
      );
    }
    const instalments = scheme.instalments;
    if (instalments !== null && instalments.schedule.length > 0) {
      out.push(
        'insert into vat_scheme_instalments',
        '  (country, scheme_code, sequence, report_code, due_month, due_day, percent, base_report_code, base_box,',
        '   base_kind, minimum_base, legal_reference, source_key)',
        'values',
        instalments.schedule
          .map(
            (row) =>
              `  (${c}, ${s}, ${row.sequence}, ${sqlText(instalments.report)}, ${row.month}, ${row.day ?? 'null'}, ` +
              `${row.percent}, ${sqlText(instalments.base_report)}, ${sqlText(instalments.base_box)}, ` +
              `${sqlText(instalments.base_kind)}, ${instalments.minimum_base ?? 'null'}, ` +
              `${sqlText(instalments.legal_reference)}, ${sqlText(instalments.source)})`,
          )
          .join(',\n') + ';',
        '',
      );
    }
  }
  return out;
}
