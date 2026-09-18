/**
 * Exact decimals, on the text they arrive as.
 *
 * Every figure of an invoice reaches this package as Postgres wrote it — a
 * `numeric` read as text — and leaves it the same way. The rules of EN 16931
 * compare those figures with `=`, not with a tolerance: a sum that a binary
 * float gets wrong by one part in 2^52 is a rule reported broken on an invoice
 * that is right. So nothing here is a `number`. A decimal is an integer and a
 * scale, the integer is a `bigint`, and the four operations the rules need are
 * exact.
 */

export interface Decimal {
  /** The digits, as an integer: 12.30 is `1230n` at scale 2. */
  readonly units: bigint;
  /** How many of those digits are after the point. */
  readonly scale: number;
}

const SYNTAX = /^[+-]?(\d+)(\.\d+)?$|^[+-]?(\.\d+)$/;

/**
 * Reads a decimal, or returns null for anything that is not one. An exponent,
 * a thousands separator and a comma are not decimals: `xs:decimal` refuses the
 * three, and what is refused there is refused here.
 */
export function parseDecimal(value: string | number | null | undefined): Decimal | null {
  if (value === null || value === undefined) return null;
  let text: string;
  if (typeof value === 'number') {
    if (!Number.isFinite(value)) return null;
    // A number is accepted for convenience and printed the way JavaScript
    // prints it, which is the shortest text that reads back as the same
    // double. Past 1e21 that text has an exponent and is refused below.
    text = String(value);
  } else {
    text = value.trim();
  }
  if (!SYNTAX.test(text)) return null;
  const negative = text.startsWith('-');
  const unsigned = text.replace(/^[+-]/, '');
  const [whole = '', fraction = ''] = unsigned.split('.');
  const units = BigInt((whole || '0') + fraction);
  return { units: negative ? -units : units, scale: fraction.length };
}

function align(a: Decimal, b: Decimal): [bigint, bigint, number] {
  const scale = Math.max(a.scale, b.scale);
  return [a.units * 10n ** BigInt(scale - a.scale), b.units * 10n ** BigInt(scale - b.scale), scale];
}

export function add(a: Decimal, b: Decimal): Decimal {
  const [x, y, scale] = align(a, b);
  return { units: x + y, scale };
}

export function subtract(a: Decimal, b: Decimal): Decimal {
  const [x, y, scale] = align(a, b);
  return { units: x - y, scale };
}

export function multiply(a: Decimal, b: Decimal): Decimal {
  return { units: a.units * b.units, scale: a.scale + b.scale };
}

export function compare(a: Decimal, b: Decimal): -1 | 0 | 1 {
  const [x, y] = align(a, b);
  return x < y ? -1 : x > y ? 1 : 0;
}

export const equal = (a: Decimal, b: Decimal): boolean => compare(a, b) === 0;

export const ZERO: Decimal = { units: 0n, scale: 0 };

export const isZero = (a: Decimal): boolean => a.units === 0n;

export function abs(a: Decimal): Decimal {
  return a.units < 0n ? { units: -a.units, scale: a.scale } : a;
}

export function sum(values: readonly Decimal[]): Decimal {
  return values.reduce(add, ZERO);
}

/**
 * Rounds to `places` decimals the way XPath's `round()` does: half towards
 * positive infinity, so 2.5 becomes 3 and -2.5 becomes -2. It is the rounding
 * the published rules are written with, and it is used here for nothing but
 * re-reading them — this package rounds no figure it writes.
 */
export function roundXPath(a: Decimal, places: number): Decimal {
  if (a.scale <= places) return a;
  const divisor = 10n ** BigInt(a.scale - places);
  // floor(x + 1/2), on integers: floor((2·units + divisor) / (2·divisor)).
  const numerator = 2n * a.units + divisor;
  const denominator = 2n * divisor;
  let quotient = numerator / denominator;
  if (numerator % denominator !== 0n && numerator < 0n) quotient -= 1n;
  return { units: quotient, scale: places };
}

/** How many digits follow the point once the zeros that say nothing are gone. */
export function significantScale(a: Decimal): number {
  let { units, scale } = a;
  while (scale > 0 && units % 10n === 0n) {
    units /= 10n;
    scale -= 1;
  }
  return scale;
}

/**
 * The text of a decimal: a point, no exponent, no sign on zero, and at least
 * `minScale` digits after the point. Trailing zeros beyond that are dropped,
 * which changes no value and keeps `21.0000` — a rate as `numeric(7,4)` stores
 * it — from travelling as four digits of nothing.
 */
export function formatDecimal(a: Decimal, minScale = 0): string {
  let { units, scale } = a;
  while (scale > minScale && units % 10n === 0n) {
    units /= 10n;
    scale -= 1;
  }
  if (scale < minScale) {
    units *= 10n ** BigInt(minScale - scale);
    scale = minScale;
  }
  const negative = units < 0n;
  const digits = (negative ? -units : units).toString().padStart(scale + 1, '0');
  const whole = digits.slice(0, digits.length - scale);
  const fraction = scale > 0 ? `.${digits.slice(digits.length - scale)}` : '';
  return `${negative ? '-' : ''}${whole}${fraction}`;
}
