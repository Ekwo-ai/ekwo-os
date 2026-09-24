/**
 * Amounts added without a float.
 *
 * An amount is held as a `bigint` of millionths: enough for any currency and
 * any rate a spreadsheet prints, and exact. What leaves is a string with two
 * decimals, and more when the file wrote more that are not zero — dropping a
 * written zero is not rounding, dropping anything else would be, and is never
 * done here.
 */

const SCALE = 6;

/** Millionths as a decimal string: signed, two decimals, more when they are written. */
export function formatDecimal(value: bigint): string {
  const negative = value < 0n;
  const digits = (negative ? -value : value).toString().padStart(SCALE + 1, '0');
  const whole = digits.slice(0, -SCALE);
  const fraction = digits.slice(-SCALE).replace(/0+$/, '').padEnd(2, '0');
  return `${negative ? '-' : ''}${whole}.${fraction}`;
}

