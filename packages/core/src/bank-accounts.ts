/**
 * How a bank account is identified, one scheme at a time.
 *
 * An IBAN is one answer among several. The United States names an account by
 * an ABA routing number and an account number, the United Kingdom by a sort
 * code and an account number, Australia by a BSB, India by an IFSC, Mexico by
 * a CLABE, Japan by a bank code, a branch code and an account number. Asking
 * everybody for an IBAN is asking half the world for something it does not
 * have.
 *
 * So the country pack declares the scheme its banks use (`bank.account_scheme`
 * in `pack.json`, stored in `country_defaults.bank_account_scheme`) and this
 * file is the single registry that knows how to read and check each one. It
 * lives in the core because the command line (`ekwo init`) and the MCP server
 * (`create_bank_account`) both ask it, and a second list would be a second
 * truth. The set of keys is also what `packs/schema/pack.1.json` accepts,
 * which `tests/bank_account_schemes.test.ts` holds together.
 *
 * A pack that declares nothing falls back to `account-number`: a free-text
 * account number, trimmed, never checked. It never falls back to an IBAN.
 *
 * Every scheme reads what a person types — spaces, hyphens, slashes and colons
 * are separators and are ignored — and answers one canonical string: the parts
 * of the identifier, in order, joined by a single space. That string is what
 * `bank_accounts.account_identifier` holds and what a statement is matched
 * against.
 */

/** One piece of an identifier: the routing number of the US, the sort code of the UK. */
interface Part {
  label: string;
  /** Exact length, for every part but the last, which takes what is left. */
  length?: number;
  /** What the part must look like once separators are gone. */
  pattern: RegExp;
}

export interface BankAccountScheme {
  /** The key a pack declares. */
  key: string;
  /** What the identifier is called, for a screen or an error. */
  label: string;
  /** The question asked of a person: "<prompt> of the main bank account?". */
  prompt: string;
  /** A shape, never a real account. */
  example: string;
  parts: Part[];
  /** Case folding applied to the whole identifier before it is read. */
  upper: boolean;
  /** A check across the parts, for schemes that carry a check digit. Null when it holds. */
  check?: (parts: string[]) => string | null;
}

/** The scheme of a pack that declares none: a number as the bank gave it. */
export const FALLBACK_BANK_ACCOUNT_SCHEME = 'account-number';

/** ISO 7064 mod 97-10, the check of an IBAN. */
function mod97(iban: string): number {
  const rearranged = iban.slice(4) + iban.slice(0, 4);
  let remainder = 0;
  for (const char of rearranged) {
    const value = char >= 'A' ? String(char.charCodeAt(0) - 55) : char;
    for (const digit of value) remainder = (remainder * 10 + Number(digit)) % 97;
  }
  return remainder;
}

/** Weighted 3-7-1 sum of the ABA routing number; a valid one is a multiple of ten. */
function abaChecksum(routing: string): number {
  const weights = [3, 7, 1, 3, 7, 1, 3, 7, 1];
  return [...routing].reduce((sum, digit, index) => sum + Number(digit) * (weights[index] ?? 0), 0);
}

/** The CLABE check digit: weights 3-7-1 repeating, each product taken modulo 10. */
function clabeCheckDigit(first17: string): number {
  const weights = [3, 7, 1];
  const sum = [...first17].reduce(
    (total, digit, index) => total + ((Number(digit) * (weights[index % 3] ?? 0)) % 10),
    0,
  );
  return (10 - (sum % 10)) % 10;
}

const digits = (min: number, max: number): RegExp => new RegExp(`^[0-9]{${min},${max}}$`);

export const BANK_ACCOUNT_SCHEMES: readonly BankAccountScheme[] = [
  {
    key: 'iban',
    label: 'IBAN',
    prompt: 'IBAN',
    example: 'two letters, two check digits, then the national account number',
    upper: true,
    parts: [{ label: 'IBAN', pattern: /^[A-Z]{2}[0-9]{2}[A-Z0-9]{11,30}$/ }],
    check: ([iban]) => (mod97(iban ?? '') === 1 ? null : 'the IBAN check digits do not add up'),
  },
  {
    key: 'aba-routing-account',
    label: 'ABA routing number and account number',
    prompt: 'ABA routing number and account number',
    example: '9-digit routing number, then the account number',
    upper: false,
    parts: [
      { label: 'ABA routing number', length: 9, pattern: digits(9, 9) },
      { label: 'account number', pattern: digits(4, 17) },
    ],
    check: ([routing]) =>
      abaChecksum(routing ?? '') % 10 === 0 ? null : 'the ABA routing number check digit does not add up',
  },
  {
    key: 'sort-code-account',
    label: 'sort code and account number',
    prompt: 'Sort code and account number',
    example: '6-digit sort code, then the 8-digit account number',
    upper: false,
    parts: [
      { label: 'sort code', length: 6, pattern: digits(6, 6) },
      { label: 'account number', pattern: digits(6, 8) },
    ],
  },
  {
    key: 'bsb-account',
    label: 'BSB and account number',
    prompt: 'BSB and account number',
    example: '6-digit BSB, then the account number',
    upper: false,
    parts: [
      { label: 'BSB', length: 6, pattern: digits(6, 6) },
      { label: 'account number', pattern: digits(5, 9) },
    ],
  },
  {
    key: 'ifsc-account',
    label: 'IFSC and account number',
    prompt: 'IFSC and account number',
    example: '11-character IFSC, then the account number',
    upper: true,
    parts: [
      { label: 'IFSC', length: 11, pattern: /^[A-Z]{4}0[A-Z0-9]{6}$/ },
      { label: 'account number', pattern: digits(9, 18) },
    ],
  },
  {
    key: 'clabe',
    label: 'CLABE',
    prompt: 'CLABE',
    example: '18 digits, the last one a check digit',
    upper: false,
    parts: [{ label: 'CLABE', pattern: digits(18, 18) }],
    check: ([clabe]) =>
      Number((clabe ?? '')[17]) === clabeCheckDigit((clabe ?? '').slice(0, 17))
        ? null
        : 'the CLABE check digit does not add up',
  },
  {
    key: 'zengin',
    label: 'bank code, branch code and account number',
    prompt: 'Bank code, branch code and account number (Zengin)',
    example: '4-digit bank code, 3-digit branch code, then the account number',
    upper: false,
    parts: [
      { label: 'bank code', length: 4, pattern: digits(4, 4) },
      { label: 'branch code', length: 3, pattern: digits(3, 3) },
      { label: 'account number', pattern: digits(6, 8) },
    ],
  },
  {
    key: 'transit-institution-account',
    label: 'transit number, institution number and account number',
    prompt: 'Transit number, institution number and account number',
    example: '5-digit transit, 3-digit institution, then the account number',
    upper: false,
    parts: [
      { label: 'transit number', length: 5, pattern: digits(5, 5) },
      { label: 'institution number', length: 3, pattern: digits(3, 3) },
      { label: 'account number', pattern: digits(7, 12) },
    ],
  },
  {
    key: FALLBACK_BANK_ACCOUNT_SCHEME,
    label: 'account number',
    prompt: 'Account number',
    example: 'the number your bank gives it, as written',
    upper: false,
    parts: [{ label: 'account number', pattern: /^.{1,64}$/ }],
  },
];

/** Every key a pack may declare, and the fallback. */
export const BANK_ACCOUNT_SCHEME_KEYS: readonly string[] = BANK_ACCOUNT_SCHEMES.map((s) => s.key);

/**
 * The scheme a pack declared, or the free-text fallback where it declared none.
 * An unknown key is `undefined`, not the fallback: a typo in a pack is for
 * `ekwo pack check` to refuse, and for nobody to paper over.
 */
export function bankAccountScheme(key: string | null | undefined): BankAccountScheme | undefined {
  return BANK_ACCOUNT_SCHEMES.find((s) => s.key === (key ?? FALLBACK_BANK_ACCOUNT_SCHEME));
}

export type BankAccountIdentifier =
  | { ok: true; scheme: string; identifier: string }
  | { ok: false; scheme: string; error: string };

/** Reads what a person typed against a scheme: canonical, or the sentence that says why not. */
export function readBankAccountIdentifier(
  key: string | null | undefined,
  raw: string,
): BankAccountIdentifier {
  const scheme = bankAccountScheme(key);
  const name = key ?? FALLBACK_BANK_ACCOUNT_SCHEME;
  if (scheme === undefined) {
    return { ok: false, scheme: name, error: `unknown_bank_account_scheme: ${name} is not a scheme this release reads.` };
  }
  const refuse = (why: string): BankAccountIdentifier => ({
    ok: false,
    scheme: scheme.key,
    error: `invalid_bank_account: ${why}. Expected ${scheme.label}: ${scheme.example}.`,
  });

  if (scheme.key === FALLBACK_BANK_ACCOUNT_SCHEME) {
    const value = raw.trim().replace(/\s+/g, ' ');
    return scheme.parts[0]?.pattern.test(value)
      ? { ok: true, scheme: scheme.key, identifier: value }
      : refuse('the account number is empty or too long');
  }

  const folded = scheme.upper ? raw.toUpperCase() : raw;
  const clean = folded.replace(/[\s\-/:.]/g, '');
  const parts: string[] = [];
  let rest = clean;
  for (const [index, part] of scheme.parts.entries()) {
    const last = index === scheme.parts.length - 1;
    const value = last || part.length === undefined ? rest : rest.slice(0, part.length);
    if (!part.pattern.test(value)) return refuse(`the ${part.label} is not valid`);
    parts.push(value);
    rest = part.length === undefined ? '' : rest.slice(part.length);
  }
  const failed = scheme.check?.(parts) ?? null;
  return failed === null
    ? { ok: true, scheme: scheme.key, identifier: parts.join(' ') }
    : refuse(failed);
}
