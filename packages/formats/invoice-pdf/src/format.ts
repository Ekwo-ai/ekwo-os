/**
 * Amounts, rates, quantities, dates and country names, written in the
 * language of the document by `Intl` and by nothing else: no separator, no
 * currency symbol, no date order and no number of decimals is decided here.
 *
 * A figure arrives as the decimal text the books hold and is handed to
 * `Intl.NumberFormat` as text, which formats it digit for digit — never
 * through a JavaScript number, which would round `0.1 + 0.2` the way floats do.
 */

import { InvoicePdfError } from './errors.js';
import type { Numeric } from './types.js';

const DECIMAL = /^-?\d+(\.\d+)?$/;

/** The decimal text of a figure, or null when there is none. Anything else is refused. */
export function decimal(value: Numeric | null | undefined, what: string): string | null {
  if (value === null || value === undefined) return null;
  const text = typeof value === 'number' ? String(value) : value.trim();
  if (text === '') return null;
  if (!DECIMAL.test(text)) throw new InvoicePdfError('invalid_value', `${what} is "${text}", which is not a decimal`);
  return text;
}

/** True for `0`, `0.00`, `-0.0`. */
export function isZero(text: string): boolean {
  return /^-?0+(\.0+)?$/.test(text);
}

/** `21` → `0.21`, by moving the decimal point: a rate in per cent, as a fraction, without a float. */
function hundredth(text: string): string {
  const negative = text.startsWith('-');
  const [whole = '0', fraction = ''] = (negative ? text.slice(1) : text).split('.');
  const padded = whole.padStart(3, '0');
  const out = `${padded.slice(0, -2).replace(/^0+(?=\d)/, '')}.${padded.slice(-2)}${fraction}`;
  return negative ? `-${out}` : out;
}

/** `Intl.NumberFormat.format` takes a decimal string since ES2023, exactly; the types of ES2022 do not say so. */
type Formattable = number & string;
const asText = (text: string): Formattable => text as Formattable;

export interface Formatter {
  locale: string;
  amount(value: string): string;
  /** A per-cent rate, `21` → `21%` written the way the language writes it. */
  rate(value: string): string;
  quantity(value: string): string;
  date(value: string): string;
  country(code: string): string;
}

export function formatterFor(locale: string, currency: string): Formatter {
  let canonical: string;
  try {
    canonical = Intl.getCanonicalLocales(locale)[0] ?? 'en';
  } catch {
    throw new InvoicePdfError('invalid_language', `"${locale}" is not a language tag Intl accepts`);
  }
  let money: Intl.NumberFormat;
  try {
    money = new Intl.NumberFormat(canonical, { style: 'currency', currency });
  } catch {
    throw new InvoicePdfError('invalid_value', `"${currency}" is not an ISO 4217 currency code`);
  }
  const percent = new Intl.NumberFormat(canonical, { style: 'percent', maximumFractionDigits: 4 });
  const plain = new Intl.NumberFormat(canonical, { maximumFractionDigits: 6 });
  const day = new Intl.DateTimeFormat(canonical, { dateStyle: 'medium', timeZone: 'UTC' });
  let regions: Intl.DisplayNames | undefined;
  try {
    regions = new Intl.DisplayNames([canonical], { type: 'region' });
  } catch {
    regions = undefined;
  }

  return {
    locale: canonical,
    amount: (value) => money.format(asText(value)),
    rate: (value) => percent.format(asText(hundredth(value))),
    quantity: (value) => plain.format(asText(value)),
    date(value) {
      const match = /^(\d{4})-(\d{2})-(\d{2})/.exec(value);
      if (match === null) throw new InvoicePdfError('invalid_value', `the date "${value}" is not YYYY-MM-DD`);
      return day.format(new Date(Date.UTC(Number(match[1]), Number(match[2]) - 1, Number(match[3]))));
    },
    country(code) {
      try {
        return regions?.of(code.toUpperCase()) ?? code;
      } catch {
        return code;
      }
    },
  };
}

/** An IBAN in groups of four, as it is read aloud and printed. */
export function groupIban(iban: string): string {
  const compact = iban.replace(/\s+/g, '').toUpperCase();
  return compact.replace(/(.{4})(?=.)/g, '$1 ');
}
