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

/**
 * The two-digit key that completes a bank code, a branch code and an account
 * number into the twenty-three characters printed on a relevé d'identité
 * bancaire. A letter of the account number counts as a digit: A and J as 1,
 * B, K and S as 2, … I, R and Z as 9. Null when the three parts are not what
 * the format says they are.
 */
export function ribKey(bankCode: string, branchCode: string, accountNumber: string): string | null {
  if (!/^[0-9]{5}$/.test(bankCode) || !/^[0-9]{5}$/.test(branchCode) || !/^[0-9A-Z]{11}$/.test(accountNumber)) {
    return null;
  }
  const numeric = [...accountNumber]
    .map((character) => {
      const code = character.charCodeAt(0);
      if (code < 65) return character;
      const rank = code - 65; // A = 0
      return String(rank < 9 ? rank + 1 : rank < 18 ? rank - 8 : rank - 16);
    })
    .join('');
  const sum = 89n * BigInt(bankCode) + 15n * BigInt(branchCode) + 3n * BigInt(numeric);
  return String(97n - (sum % 97n)).padStart(2, '0');
}

/**
 * The IBAN of an account a CFONB 120 identifies, **in the country the caller
 * names**: the format carries a bank, a branch and an account, and no country —
 * the same lay-out serves more than one. Null when the parts are not what the
 * format says, or the country is not two letters.
 */
export function ibanOf(
  country: string,
  bankCode: string,
  branchCode: string,
  accountNumber: string,
): string | null {
  const key = ribKey(bankCode, branchCode, accountNumber);
  if (key === null || !/^[A-Z]{2}$/.test(country)) return null;
  const bban = bankCode + branchCode + accountNumber + key;
  const check = String(98 - mod97(`${bban}${country}00`)).padStart(2, '0');
  return `${country}${check}${bban}`;
}
