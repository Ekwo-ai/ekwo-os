/**
 * Peppol participant identifiers: `scheme:value`, the address a business is
 * registered under on the network and the one an invoice is delivered to.
 *
 * What is checked, and where it comes from:
 *
 * - **the scheme** is a code of the electronic address scheme list (EAS) that
 *   EN 16931 publishes, as the Schematron Peppol ships carries it
 *   (`ELECTRONIC_ADDRESS_SCHEMES`, generated from that file), less the schemes
 *   Peppol does not deliver to (`SCHEMES_NOT_ON_PEPPOL`);
 * - **the spelling**: the numeric code is the identifier. Some registrations
 *   and older documents write a symbolic name instead (`BE:EN` for `0208`);
 *   those of {@link SYMBOLIC_SCHEMES} are read and returned as the code;
 * - **the value**, for the schemes whose number carries check digits under a
 *   published, well-defined rule — each one cites where the rule is
 *   published. A scheme that is not listed there is not checked beyond being
 *   non-empty: a rule written from a guess would refuse somebody's real
 *   address. The French SIRET (0009) is one: its Luhn rule has a published
 *   exception for one issuer whose exact extent this package could not
 *   source, so it is not checked at all rather than checked wrongly.
 *
 * The comparison is the network's: a participant identifier is
 * case-insensitive (OpenPEPPOL, *Policy for use of Identifiers*, version 4,
 * policy 1), which is why {@link validateParticipantId} returns it lower-cased
 * beside the form it was given in.
 */

import { ELECTRONIC_ADDRESS_SCHEMES } from './codelists.js';
import { SCHEMES_NOT_ON_PEPPOL } from './rules.js';

/** The identifier scheme of every participant identifier on Peppol (Policy for use of Identifiers, policy 2). */
export const PARTICIPANT_IDENTIFIER_SCHEME = 'iso6523-actorid-upis';

/**
 * Symbolic names of participant identifier schemes, and the numeric code each
 * stands for, transcribed from the "Scheme ID" column of the Peppol code list
 * *Participant identifier schemes* (docs.peppol.eu, Peppol Code Lists). Only
 * the names that list gives are here; a name that is not is refused, not
 * guessed.
 */
export const SYMBOLIC_SCHEMES: Readonly<Record<string, string>> = Object.freeze({
  'FR:SIRENE': '0002',
  'SE:ORGNR': '0007',
  'FR:SIRET': '0009',
  'FI:OVT': '0037',
  DUNS: '0060',
  GLN: '0088',
  'NL:KVK': '0106',
  'AU:ABN': '0151',
  'DK:DIGST': '0184',
  'NL:OINO': '0190',
  'NO:ORG': '0192',
  LEI: '0199',
  'DE:LWID': '0204',
  'BE:EN': '0208',
  'HU:VAT': '9910',
  'AT:VAT': '9914',
  'ES:VAT': '9920',
  'AD:VAT': '9922',
  'AL:VAT': '9923',
  'BA:VAT': '9924',
  'BE:VAT': '9925',
  'BG:VAT': '9926',
  'CH:VAT': '9927',
  'CY:VAT': '9928',
  'CZ:VAT': '9929',
  'DE:VAT': '9930',
  'EE:VAT': '9931',
  'GB:VAT': '9932',
  'GR:VAT': '9933',
  'HR:VAT': '9934',
  'IE:VAT': '9935',
  'LI:VAT': '9936',
  'LT:VAT': '9937',
  'LU:VAT': '9938',
  'LV:VAT': '9939',
  'MC:VAT': '9940',
  'ME:VAT': '9941',
  'MK:VAT': '9942',
  'MT:VAT': '9943',
  'NL:VAT': '9944',
  'PL:VAT': '9945',
  'PT:VAT': '9946',
  'RO:VAT': '9947',
  'RS:VAT': '9948',
  'SI:VAT': '9949',
  'SK:VAT': '9950',
  'SM:VAT': '9951',
  'TR:VAT': '9952',
  'VA:VAT': '9953',
  'FR:VAT': '9957',
});

/** Why an identifier is not one Peppol can deliver to. */
export type ParticipantIdProblem =
  /** Not `scheme:value`: no separator, an empty side, or another identifier scheme than `iso6523-actorid-upis`. */
  | 'malformed'
  /** A scheme of no list: neither an EAS code nor a symbolic name of {@link SYMBOLIC_SCHEMES}. */
  | 'unknown_scheme'
  /** An EAS code of EN 16931 that Peppol does not deliver to (an e-mail address, a telephone number…). */
  | 'scheme_not_on_peppol'
  /** A value that is not written the way its scheme writes numbers. */
  | 'invalid_format'
  /** A value whose check digits are wrong. */
  | 'invalid_check_digits';

export interface ParticipantIdCheck {
  /** True when nothing below is wrong. */
  valid: boolean;
  /** The numeric scheme, `0208`, whatever spelling it was given in. Null where it could not be read. */
  scheme: string | null;
  /** The value, as given, trimmed. */
  value: string | null;
  /** `scheme:value`, numeric scheme, as given. Null where either side is. */
  identifier: string | null;
  /** The same, lower-cased: the form the network compares and hashes. */
  canonical: string | null;
  /** Empty when `valid`. */
  problems: { code: ParticipantIdProblem; message: string }[];
}

// --- check digits ---------------------------------------------------------
// Each function cites the rule it implements. A scheme is only here when the
// rule is published by the body that issues the numbers.

/**
 * The GS1 check digit of a GLN, thirteen digits: weights 3 and 1 alternating
 * from the right, the check digit bringing the sum to a multiple of ten. GS1
 * General Specifications, section 7.9, "Check digit calculation"; the Peppol
 * Schematron applies the same rule to scheme 0088 (`u:gln`,
 * PEPPOL-COMMON-R040).
 */
function gln(value: string): boolean | null {
  if (!/^[0-9]{13}$/.test(value)) return null;
  const body = [...value.slice(0, -1)].reverse().map(Number);
  const weighted = body.reduce((total, digit, i) => total + digit * (i % 2 === 0 ? 3 : 1), 0);
  return (10 - (weighted % 10)) % 10 === Number(value.slice(-1));
}

/**
 * The Belgian enterprise number, ten digits: the last two are 97 less the
 * first eight modulo 97. Crossroads Bank for Enterprises (KBO/BCE); the Peppol
 * Schematron applies it to scheme 0208 (`u:mod97-0208`, PEPPOL-COMMON-R043).
 */
function belgianEnterprise(value: string): boolean | null {
  if (!/^[0-9]{10}$/.test(value)) return null;
  return 97 - (Number(value.slice(0, 8)) % 97) === Number(value.slice(8));
}

/** The Luhn algorithm (ISO/IEC 7812-1, annex B): from the right, every second digit doubled. */
function luhn(digits: string): boolean {
  let total = 0;
  for (let i = 0; i < digits.length; i += 1) {
    let digit = Number(digits[digits.length - 1 - i]);
    if (i % 2 === 1) {
      digit *= 2;
      if (digit > 9) digit -= 9;
    }
    total += digit;
  }
  return total % 10 === 0;
}

/** A French SIREN, nine digits, Luhn — INSEE, *Répertoire SIRENE*, the structure of the SIREN number. */
function siren(value: string): boolean | null {
  return /^[0-9]{9}$/.test(value) ? luhn(value) : null;
}

/**
 * A Swedish organisation number, ten digits, Luhn over the ten.
 * Skatteverket, *Organisationsnummer* (SKV 709), the check digit.
 */
function swedishOrganisation(value: string): boolean | null {
  return /^[0-9]{10}$/.test(value) ? luhn(value) : null;
}

/**
 * A Norwegian organisation number, nine digits: weights 3 2 7 6 5 4 3 2 on the
 * first eight, the check digit 11 less the sum modulo 11 (0 for 11, and no
 * number is issued for 10). Brønnøysund Register Centre, *Organisasjonsnummer*.
 */
function norwegianOrganisation(value: string): boolean | null {
  if (!/^[0-9]{9}$/.test(value)) return null;
  const weights = [3, 2, 7, 6, 5, 4, 3, 2];
  const total = weights.reduce((sum, weight, i) => sum + weight * Number(value[i]), 0);
  const check = 11 - (total % 11);
  if (check === 10) return false;
  return (check === 11 ? 0 : check) === Number(value[8]);
}

/**
 * An Australian Business Number, eleven digits: one subtracted from the first
 * digit, weights 10 1 3 5 7 9 11 13 15 17 19, the sum a multiple of 89.
 * Australian Business Register, *Format of the ABN*.
 */
function australianBusiness(value: string): boolean | null {
  if (!/^[0-9]{11}$/.test(value)) return null;
  const weights = [10, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19];
  const digits = [...value].map(Number);
  digits[0] = (digits[0] as number) - 1;
  return digits.reduce((sum, digit, i) => sum + digit * (weights[i] as number), 0) % 89 === 0;
}

/**
 * A Legal Entity Identifier, twenty characters, the last two check digits of
 * ISO 7064 MOD 97-10 (letters as 10 to 35, the whole modulo 97 is 1).
 * ISO 17442-1, as the GLEIF publishes it.
 */
function legalEntityIdentifier(value: string): boolean | null {
  const upper = value.toUpperCase();
  if (!/^[0-9A-Z]{18}[0-9]{2}$/.test(upper)) return null;
  let remainder = 0;
  for (const character of upper) {
    const code = character.charCodeAt(0);
    const digits = code >= 65 ? String(code - 55) : character;
    for (const digit of digits) remainder = (remainder * 10 + Number(digit)) % 97;
  }
  return remainder === 1;
}

/**
 * The schemes whose values are checked, and what they hold. A function
 * returns null for a value that is not written the way the scheme writes
 * numbers, false for wrong check digits.
 */
const CHECKED: Readonly<Record<string, readonly [what: string, check: (value: string) => boolean | null]>> = {
  '0002': ['a SIREN number, nine digits', siren],
  '0007': ['a Swedish organisation number, ten digits', swedishOrganisation],
  '0088': ['a GLN, thirteen digits', gln],
  '0151': ['an Australian Business Number, eleven digits', australianBusiness],
  '0192': ['a Norwegian organisation number, nine digits', norwegianOrganisation],
  '0199': ['a Legal Entity Identifier, twenty characters', legalEntityIdentifier],
  '0208': ['a Belgian enterprise number, ten digits', belgianEnterprise],
};

/** The schemes whose values {@link validateParticipantId} checks digit by digit. */
export const CHECKED_SCHEMES: readonly string[] = Object.freeze(Object.keys(CHECKED));

/** Thrown where a participant identifier is needed and the one given is not one. */
export class ParticipantIdError extends Error {
  override name = 'ParticipantIdError';
  readonly problems: ParticipantIdCheck['problems'];

  constructor(problems: ParticipantIdCheck['problems']) {
    super(`not a Peppol participant identifier: ${problems.map((each) => each.message).join(' ')}`);
    this.problems = problems;
  }
}

function problem(check: ParticipantIdCheck, code: ParticipantIdProblem, message: string): ParticipantIdCheck {
  return { ...check, valid: false, problems: [...check.problems, { code, message }] };
}

/**
 * Checks a participant identifier: `0208:0999999922`, with or without the
 * `iso6523-actorid-upis::` in front of it, or with a symbolic scheme
 * (`BE:EN:0999999922`).
 *
 * Pure: the question whether the participant is *registered* is the SML's,
 * and {@link smlHostname} computes where to ask it.
 */
export function validateParticipantId(input: string): ParticipantIdCheck {
  let rest = String(input ?? '').trim();
  const empty: ParticipantIdCheck = { valid: true, scheme: null, value: null, identifier: null, canonical: null, problems: [] };

  const separator = rest.indexOf('::');
  if (separator !== -1) {
    const identifierScheme = rest.slice(0, separator);
    if (identifierScheme.toLowerCase() !== PARTICIPANT_IDENTIFIER_SCHEME) {
      return problem(empty, 'malformed', `${identifierScheme} is not the identifier scheme of Peppol participants, ${PARTICIPANT_IDENTIFIER_SCHEME}.`);
    }
    rest = rest.slice(separator + 2);
  }

  let scheme: string | null = null;
  let value: string | null = null;
  const symbolic = Object.keys(SYMBOLIC_SCHEMES)
    .sort((a, b) => b.length - a.length)
    .find((name) => rest.toUpperCase().startsWith(`${name}:`));
  if (symbolic !== undefined) {
    scheme = SYMBOLIC_SCHEMES[symbolic] as string;
    value = rest.slice(symbolic.length + 1).trim();
  } else {
    const colon = rest.indexOf(':');
    if (colon === -1) return problem(empty, 'malformed', `${JSON.stringify(rest)} is not scheme:value.`);
    scheme = rest.slice(0, colon).trim();
    value = rest.slice(colon + 1).trim();
  }
  if (scheme === '' || value === '') return problem(empty, 'malformed', `${JSON.stringify(rest)} has an empty scheme or value.`);

  const identifier = `${scheme}:${value}`;
  let check: ParticipantIdCheck = { ...empty, scheme, value, identifier, canonical: identifier.toLowerCase() };
  if (!ELECTRONIC_ADDRESS_SCHEMES.has(scheme)) {
    return problem({ ...check, scheme: null, identifier: null, canonical: null }, 'unknown_scheme', `${scheme} is neither an electronic address scheme (EAS) nor a symbolic name of one.`);
  }
  if (SCHEMES_NOT_ON_PEPPOL.includes(scheme)) {
    check = problem(check, 'scheme_not_on_peppol', `${scheme} is an electronic address scheme of EN 16931 that Peppol does not deliver to.`);
  }
  const rule = CHECKED[scheme];
  if (rule !== undefined) {
    const [what, verify] = rule;
    const verdict = verify(value);
    if (verdict === null) check = problem(check, 'invalid_format', `A value in scheme ${scheme} is ${what}; ${value} is not.`);
    else if (!verdict) check = problem(check, 'invalid_check_digits', `${value} is written as ${what}, and its check digits are wrong.`);
  }
  return check;
}
