/**
 * Amounts as the file wrote them, added without a float.
 *
 * A CODA amount is fifteen digits: twelve and **three decimals**, whatever the
 * currency, unsigned — the sign is another position of the record. Sums are
 * made on a `bigint` of thousandths, and what leaves is a string.
 */

const DIGITS = /^[0-9]{15}$/;

/** Fifteen digits as thousandths, or null when they are not fifteen digits. */
export function parseAmount(field: string): bigint | null {
  return DIGITS.test(field) ? BigInt(field) : null;
}

/**
 * Thousandths as a decimal string: signed, no leading zeros, two decimals —
 * and the third when the file wrote one that is not zero. Dropping a written
 * zero is not rounding; dropping anything else would be, and is never done.
 */
export function formatAmount(value: bigint): string {
  const negative = value < 0n;
  const digits = (negative ? -value : value).toString().padStart(4, '0');
  const whole = digits.slice(0, -3);
  const fraction = digits.slice(-3).replace(/0$/, '');
  return `${negative ? '-' : ''}${whole}.${fraction}`;
}
