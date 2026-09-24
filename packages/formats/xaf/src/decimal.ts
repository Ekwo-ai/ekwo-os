/**
 * Amounts as the file wrote them, added without a float.
 *
 * An audit file writes its amounts as `xsd:decimal` with two fraction digits
 * at most, the side in an element of its own. An amount is held here as a
 * `bigint` of millionths — the unit every reader of books in this repository
 * adds in — and what leaves is a string with two decimals, and more when the
 * file wrote more that are not zero.
 */

const SCALE = 6;
const UNIT = 10n ** BigInt(SCALE);
const XSD_DECIMAL = /^([+-])?([0-9]*)(?:\.([0-9]*))?$/;

/**
 * An `xsd:decimal` as millionths, or null when it is not one: an optional
 * sign, digits, an optional point and digits. No exponent, no thousands
 * separator, no comma — the lexical space of the type, and nothing else.
 */
export function parseXsdDecimal(text: string): bigint | null {
  const match = XSD_DECIMAL.exec(text.trim());
  if (match === null) return null;
  const whole = match[2] ?? '';
  const fraction = match[3] ?? '';
  if (whole === '' && fraction === '') return null;
  if (fraction.length > SCALE) return null;
  const units = BigInt(whole === '' ? '0' : whole) * UNIT + BigInt(fraction.padEnd(SCALE, '0') || '0');
  return match[1] === '-' ? -units : units;
}

/** Millionths as a decimal string: signed, two decimals, more when they are written. */
export function formatDecimal(value: bigint): string {
  const negative = value < 0n;
  const digits = (negative ? -value : value).toString().padStart(SCALE + 1, '0');
  const whole = digits.slice(0, -SCALE);
  const fraction = digits.slice(-SCALE).replace(/0+$/, '').padEnd(2, '0');
  return `${negative ? '-' : ''}${whole}.${fraction}`;
}
