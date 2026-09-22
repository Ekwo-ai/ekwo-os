/**
 * The questions a company is created with, asked the same way wherever one is.
 *
 * `ekwo init` creates the first company of an installation and `ekwo company
 * new` every other one, and both ask the same five things: the country, the
 * first day of the financial year, the currency, the chart of accounts and the
 * language of the books. The answers come from the flags, then from a terminal
 * when there is one, then from the pack when it gives only one; and when there
 * is a choice and nobody to make it, the answer is a refusal naming the flag.
 * They were written in `init.ts` first; they live here so a second company is
 * refused on exactly what the first one would have been.
 *
 * Nothing here writes anything. What is created, and how, stays with the
 * command: `bootstrap()` for the first company, `create_company()` for the
 * others.
 */

import { stringFlag, UsageError, type ParsedArgs } from './args.js';
import {
  countryCharts,
  countryCurrency,
  countryFiscalYearOpening,
  countryLanguage,
  countryLanguages,
  installedPacks,
  type ChartChoice,
} from './bootstrap.js';
import { askRequired, choose, NotInteractiveError } from './prompt.js';
import type { SqlClient } from './sql.js';
import { warn } from './ui.js';

/**
 * Which country. There is no default country, and there is no list of
 * countries in this file: both come from the packs this installation holds,
 * named as the pack names itself. A preselected country would be a choice
 * nobody made, and the one question whose wrong answer is a chart of accounts.
 */
export async function chooseCountry(
  db: SqlClient,
  args: ParsedArgs,
  interactive: boolean,
): Promise<string> {
  const packs = await installedPacks(db);
  if (packs.length === 0) {
    throw new Error(
      'no_country_pack: this database holds no country pack, so there is no chart of ' +
        'accounts to install. Apply the reference seeds first.',
    );
  }
  const given = stringFlag(args, 'country');
  if (given !== undefined) return given.toUpperCase();
  if (!interactive) requiredCountry(packs);
  return (
    await choose(
      'Country whose accounting rules apply?',
      packs.map((p) => ({ value: p.country, label: p.name })),
    )
  ).toUpperCase();
}

/**
 * When the first financial year opens. The country model names a month —
 * `calendar`, `april`, `july`, `october` — and the flag names a day. A pack
 * that declares neither is asked about when there is a terminal, and refused
 * when there is not: opening somebody's books on a date nobody chose is found
 * out a year later, in a closing.
 *
 * Undefined means the pack's month applies.
 */
export async function chooseFiscalYearStart(
  db: SqlClient,
  args: ParsedArgs,
  country: string,
  fiscalYear: number,
  interactive: boolean,
): Promise<string | undefined> {
  const packOpening = await countryFiscalYearOpening(db, country);
  const askedStart = stringFlag(args, 'fiscal-year-start');
  if (askedStart !== undefined && !/^\d{4}-\d{2}-\d{2}$/.test(askedStart)) {
    throw new UsageError(`bad_date: --fiscal-year-start takes a day as YYYY-MM-DD, not "${askedStart}".`);
  }
  return (
    askedStart ??
    (packOpening !== undefined
      ? undefined
      : interactive
        ? await askRequired(`First day of the financial year ${fiscalYear}? (YYYY-MM-DD)`)
        : requiredFiscalYearStart(country))
  );
}

/**
 * The currency, when it has to be settled before the company row exists:
 * `companies.currency_code` is `not null`, so there is no later moment at
 * which it is empty and the country model could fill it. The pack answers it;
 * a pack that does not is asked about, never guessed at.
 */
export async function chooseCurrency(
  db: SqlClient,
  args: ParsedArgs,
  country: string,
  interactive: boolean,
): Promise<string> {
  const packCurrency = await countryCurrency(db, country);
  return (
    stringFlag(args, 'currency') ??
    (interactive
      ? await askRequired('Currency of the company?', packCurrency)
      : (packCurrency ?? required('--currency', 'the currency')))
  ).toUpperCase();
}

/**
 * Which chart of accounts. A country with one chart is not a question: there
 * is nothing to choose, and the answer is undefined — the pack's own. A
 * country with two is asked about, with nothing preselected beyond the default
 * the pack itself declares — the wrong answer here is a whole plan of accounts.
 */
export async function chooseChart(
  db: SqlClient,
  args: ParsedArgs,
  country: string,
  interactive: boolean,
): Promise<{ chartCode: string | undefined; charts: ChartChoice[] }> {
  const charts = await countryCharts(db, country);
  const askedChart = stringFlag(args, 'chart');
  if (askedChart !== undefined && !charts.some((c) => c.code === askedChart)) {
    throw new UsageError(
      `unknown_chart: ${country} has no chart ${askedChart}. ` +
        `It has: ${charts.map((c) => c.code).join(', ') || 'none'}.`,
    );
  }
  const chartCode =
    askedChart ??
    (charts.length > 1 && interactive
      ? await choose(
          'Which chart of accounts?',
          charts.map((c) => ({
            value: c.code,
            label:
              `${c.name}${c.audience === null ? '' : ` — ${c.audience}`}` +
              ` (${c.accounts} accounts${c.certificationStatus === null ? '' : `, ${c.certificationStatus}`})`,
          })),
        )
      : charts.length > 1
        ? requiredChart(country, charts)
        : undefined);
  return { chartCode, charts };
}

/**
 * The language of the books. It is written on the company row and decides
 * which label of the pack lands in `accounts.name`.
 *
 * The pack says which languages it publishes, and the question lists them
 * with nothing pre-selected: offering the first of three as the answer to
 * press Enter on is how two companies out of three end up installed in the
 * wrong one. Outside an interactive session `--language` is required whenever
 * there is a choice to make.
 */
export async function chooseLanguage(
  db: SqlClient,
  args: ParsedArgs,
  country: string,
  interactive: boolean,
): Promise<string> {
  const packLanguage = await countryLanguage(db, country);
  const languages = await countryLanguages(db, country);
  const askedLanguage = stringFlag(args, 'language');
  if (
    askedLanguage !== undefined &&
    languages.length > 0 &&
    !languages.some((l) => l.code === askedLanguage.toLowerCase())
  ) {
    warn(
      `${country} publishes its labels in ${languages.map((l) => l.code).join(', ')}; ` +
        `the books will be kept in ${askedLanguage.toLowerCase()} and the chart of accounts ` +
        `will carry the pack's own wording.`,
    );
  }
  return (
    askedLanguage ??
    (interactive && languages.length > 1
      ? await choose(
          'Language of the books?',
          languages.map((l) => ({
            value: l.code,
            label: l.isPackLanguage ? `${l.label}, the language the pack is written in` : l.label,
          })),
        )
      : interactive
        ? await askRequired('Language of the books?', packLanguage)
        : languages.length > 1
          ? required('--language', `the language of the books (${languages.map((l) => l.code).join(', ')})`)
          : (packLanguage ?? required('--language', 'the language of the books')))
  ).toLowerCase();
}

export function required(flag: string, what: string): never {
  throw new NotInteractiveError(what, flag);
}

/**
 * The refusal when `--country` is missing and nobody can be asked. It names
 * the packs this installation holds rather than a country it prefers, because
 * it has no reason to prefer one.
 */
function requiredCountry(packs: { country: string; name: string }[]): never {
  throw new UsageError(
    'missing_input: the country was not given and this is not a terminal. Pass --country, ' +
      `one of: ${packs.map((p) => `${p.country} (${p.name})`).join(', ')}.`,
  );
}

/**
 * The refusal when the pack names no opening month, `--fiscal-year-start` is
 * missing and nobody can be asked. It names the field the pack should carry
 * as well as the flag, because one of the two is the real fix.
 */
function requiredFiscalYearStart(country: string): never {
  throw new UsageError(
    `missing_input: the ${country} pack declares no defaults.fiscal_year_default and this is not a ` +
      'terminal. Pass --fiscal-year-start YYYY-MM-DD, or add the field to the pack.',
  );
}

/**
 * The refusal when a country offers several charts, `--chart` is missing and
 * nobody can be asked. It lists them rather than picking the default: a
 * non-interactive install that meant the other one would find out a year later.
 */
function requiredChart(
  country: string,
  charts: { code: string; name: string; isDefault: boolean }[],
): never {
  throw new UsageError(
    `missing_input: ${country} offers several charts of accounts and this is not a terminal. ` +
      `Pass --chart, one of: ${charts
        .map((c) => `${c.code} (${c.name}${c.isDefault ? ', the default' : ''})`)
        .join(', ')}.`,
  );
}
