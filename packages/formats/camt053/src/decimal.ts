/**
 * Amounts as the file wrote them, added without a float.
 *
 * ISO 20022 amounts are `xs:decimal` with at most five fraction digits and
 * eighteen digits in all, and unsigned: the sign is a separate element. A
 * statement's arithmetic is a sum of those, and a sum of binary floats is not
 * the sum the bank computed. Everything here is a `bigint` of hundred-
 * thousandths, and what leaves is a string.
 */

const SCALE = 5;
const UNSIGNED = /^\+?([0-9]*)(?:\.([0-9]*))?$/;

/** An unsigned ISO 20022 amount in hundred-thousandths, or null if it is not one. */
export function parseUnsigned(text: string): bigint | null {
  const match = UNSIGNED.exec(text.trim());
  if (!match) return null;
  const whole = match[1] ?? '';
  const fraction = match[2] ?? '';
  if (whole === '' && fraction === '') return null;
  if (fraction.length > SCALE || whole.replace(/^0+/, '').length + fraction.length > 18) {
    return null;
  }
  return BigInt((whole === '' ? '0' : whole) + fraction.padEnd(SCALE, '0'));
}

/**
 * The amount as a decimal string: signed, no exponent, no leading zeros, and
 * the fraction digits the file wrote — never fewer than it wrote, so that
 * `100.00` does not come back as `100`, and never more.
 */
export function signedText(text: string, negative: boolean): string {
  const match = UNSIGNED.exec(text.trim());
  const whole = (match?.[1] ?? '').replace(/^0+(?=[0-9])/, '') || '0';
  const fraction = match?.[2] ?? '';
  const unsigned = fraction === '' ? whole : `${whole}.${fraction}`;
  return negative && /[1-9]/.test(unsigned) ? `-${unsigned}` : unsigned;
}

/** Hundred-thousandths back to a decimal string, with at least two decimals. */
export function formatScaled(value: bigint): string {
  const negative = value < 0n;
  const digits = (negative ? -value : value).toString().padStart(SCALE + 1, '0');
  const whole = digits.slice(0, -SCALE);
  const fraction = digits.slice(-SCALE).replace(/0{1,3}$/, '');
  return `${negative ? '-' : ''}${whole}.${fraction}`;
}
