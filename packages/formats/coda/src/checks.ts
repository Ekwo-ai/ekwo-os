/** ISO 7064 MOD 97-10 over a string of digits and letters (A = 10 … Z = 35). */
function mod97(text: string): number {
  let remainder = 0;
  for (const character of text) {
    const code = character.charCodeAt(0);
    const value = code >= 65 ? code - 55 : code - 48;
    remainder = (value > 9 ? remainder * 100 + value : remainder * 10 + value) % 97;
  }
  return remainder;
}

/** ISO 13616: move four characters to the end, letters to numbers, mod 97 is 1. */
export function isValidIban(iban: string): boolean {
  if (!/^[A-Z]{2}[0-9]{2}[A-Z0-9]{1,30}$/.test(iban)) return false;
  return mod97(iban.slice(4) + iban.slice(0, 4)) === 1;
}

/** ISO 11649: `RF`, two check digits, up to twenty-one characters; same arithmetic as an IBAN. */
export function isValidCreditorReference(reference: string): boolean {
  if (!/^RF[0-9]{2}[A-Z0-9]{1,21}$/.test(reference)) return false;
  return mod97(reference.slice(4) + reference.slice(0, 4)) === 1;
}

/**
 * The Belgian structured communication: twelve digits, the last two being the
 * first ten modulo 97 — and 97 when that is zero, never 00.
 */
export function isValidBelgianReference(digits: string): boolean {
  if (!/^[0-9]{12}$/.test(digits)) return false;
  const check = Number(BigInt(digits.slice(0, 10)) % 97n) || 97;
  return check === Number(digits.slice(10));
}

/** `123456789002` as it is printed on an invoice: `+++123/4567/89002+++`. Twelve digits or null. */
export function formatBelgianReference(digits: string): string | null {
  if (!/^[0-9]{12}$/.test(digits)) return null;
  return `+++${digits.slice(0, 3)}/${digits.slice(3, 7)}/${digits.slice(7)}+++`;
}
