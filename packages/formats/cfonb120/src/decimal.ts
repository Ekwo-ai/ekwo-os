/**
 * Amounts as the file wrote them, added without a float.
 *
 * A CFONB 120 amount is fourteen positions: thirteen digits, and a last
 * character that is a digit **and** the sign, written over one another the way
 * punched cards did. `{` and `A` to `I` are 0 to 9 of a credit; `}` and `J` to
 * `R` are 0 to 9 of a debit. How many of the fourteen digits are decimals is
 * said by another position of the same record, and read from there: nothing
 * here knows that a euro has cents.
 */

const POSITIVE = '{ABCDEFGHI';
const NEGATIVE = '}JKLMNOPQR';

/** The fourteen positions as a signed integer of minor units, or null when they are not an amount. */
export function parseSigned(field: string): bigint | null {
  if (!/^[0-9]{13}.$/.test(field)) return null;
  const last = field.charAt(13);
  const positive = POSITIVE.indexOf(last);
  const negative = NEGATIVE.indexOf(last);
  if (positive < 0 && negative < 0) return null;
  const value = BigInt(field.slice(0, 13) + String(positive >= 0 ? positive : negative));
  return negative >= 0 ? -value : value;
}

/** Fourteen digits, unsigned: the amount of origin of a `MMO` complement. */
export function parseUnsigned(field: string): bigint | null {
  return /^[0-9]+$/.test(field) ? BigInt(field) : null;
}

/**
 * Minor units as a decimal string with exactly the decimals the record
 * announced: signed, no leading zeros, no exponent, nothing rounded.
 */
export function formatAmount(value: bigint, decimals: number): string {
  const negative = value < 0n;
  const digits = (negative ? -value : value).toString().padStart(decimals + 1, '0');
  const whole = digits.slice(0, digits.length - decimals);
  const fraction = decimals === 0 ? '' : `.${digits.slice(-decimals)}`;
  return `${negative ? '-' : ''}${whole}${fraction}`;
}
