/**
 * Amounts as the file wrote them, added without a float.
 *
 * An amount is held as a `bigint` of millionths: enough for any currency and
 * any rate a spreadsheet prints, and exact. What leaves is a string with two
 * decimals, and more when the file wrote more that are not zero — dropping a
 * written zero is not rounding, dropping anything else would be, and is never
 * done here.
 */

const SCALE = 6;
const UNIT = 10n ** BigInt(SCALE);

/**
 * The decimal marks a number may be written with. The comma is accepted only
 * where it cannot be a separator of thousands — in a file whose fields are
 * separated by something else — and a number never carries both marks.
 */
export type DecimalMark = '.' | ',';

/**
 * A written amount as millionths, or null when it is not a number this reader
 * accepts: digits, one decimal mark, an optional leading minus or a pair of
 * brackets for a negative. No thousands separator, no currency symbol, no
 * exponent — each of those is refused rather than read one way or another.
 */
export function parseDecimal(text: string, marks: readonly DecimalMark[]): bigint | null {
  let value = text.trim();
  if (value === '') return null;
  let negative = false;
  if (value.startsWith('(') && value.endsWith(')')) {
    negative = true;
    value = value.slice(1, -1).trim();
  }
  if (value.startsWith('-')) {
    if (negative) return null;
    negative = true;
    value = value.slice(1);
  } else if (value.startsWith('+')) {
    value = value.slice(1);
  }
  const pattern = marks.includes(',') ? /^([0-9]+)(?:[.,]([0-9]*))?$|^[.,]([0-9]+)$/ : /^([0-9]+)(?:\.([0-9]*))?$|^\.([0-9]+)$/;
  const match = pattern.exec(value);
  if (match === null) return null;
  const whole = match[1] ?? '0';
  const fraction = match[2] ?? match[3] ?? '';
  if (fraction.length > SCALE) return null;
  const units = BigInt(whole) * UNIT + BigInt(fraction.padEnd(SCALE, '0') || '0');
  return negative ? -units : units;
}

/** Millionths as a decimal string: signed, two decimals, more when they are written. */
export function formatDecimal(value: bigint): string {
  const negative = value < 0n;
  const digits = (negative ? -value : value).toString().padStart(SCALE + 1, '0');
  const whole = digits.slice(0, -SCALE);
  const fraction = digits.slice(-SCALE).replace(/0+$/, '').padEnd(2, '0');
  return `${negative ? '-' : ''}${whole}.${fraction}`;
}

