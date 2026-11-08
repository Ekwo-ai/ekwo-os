/**
 * Amounts as the file wrote them, added without a float.
 *
 * An amount is held as a `bigint` of millionths: enough for any currency, and
 * exact. What leaves is a string with two decimals, and more when the file
 * wrote more that are not zero — dropping a written zero is not rounding,
 * dropping anything else would be, and is never done here. Nothing here knows
 * how many decimals a currency has.
 */

const SCALE = 6;
const UNIT = 10n ** BigInt(SCALE);

export interface NumberMarks {
  decimal: '.' | ',';
  /** Empty when the file groups no thousands. */
  thousands: string;
}

/**
 * A written amount as millionths, or null when it is not one: digits, the
 * decimal mark of the profile at most once, the thousands mark of the profile
 * between groups of three, and a sign — a leading `-` or `+`, a trailing `-`,
 * or a pair of brackets. No currency symbol, no exponent: each of those is
 * refused rather than read one way or another.
 */
export function parseAmount(text: string, marks: NumberMarks): bigint | null {
  let value = text.trim();
  if (value === '') return null;
  let negative = false;
  if (value.startsWith('(') && value.endsWith(')')) {
    negative = true;
    value = value.slice(1, -1).trim();
  }
  if (value.endsWith('-')) {
    if (negative) return null;
    negative = true;
    value = value.slice(0, -1).trim();
  }
  if (value.startsWith('-')) {
    if (negative) return null;
    negative = true;
    value = value.slice(1).trim();
  } else if (value.startsWith('+')) {
    value = value.slice(1).trim();
  }
  const [integer, fraction, ...more] = value.split(marks.decimal);
  if (more.length > 0 || integer === undefined) return null;
  let whole = integer;
  if (marks.thousands !== '' && whole.includes(marks.thousands)) {
    const groups = whole.split(marks.thousands);
    if (!/^[0-9]{1,3}$/.test(groups[0] as string) || groups.slice(1).some((group) => !/^[0-9]{3}$/.test(group))) {
      return null;
    }
    whole = groups.join('');
  }
  if (!/^[0-9]*$/.test(whole) || (fraction !== undefined && !/^[0-9]*$/.test(fraction))) return null;
  if (whole === '' && (fraction === undefined || fraction === '')) return null;
  const decimals = fraction ?? '';
  if (decimals.replace(/0+$/, '').length > SCALE) return null;
  const units = BigInt(whole === '' ? '0' : whole) * UNIT + BigInt(decimals.slice(0, SCALE).padEnd(SCALE, '0') || '0');
  return negative ? -units : units;
}

/** Millionths as a decimal string: signed, two decimals, more when they are written. */
export function formatAmount(value: bigint): string {
  const negative = value < 0n;
  const digits = (negative ? -value : value).toString().padStart(SCALE + 1, '0');
  const whole = digits.slice(0, -SCALE);
  const fraction = digits.slice(-SCALE).replace(/0+$/, '').padEnd(2, '0');
  return `${negative ? '-' : ''}${whole}.${fraction}`;
}
