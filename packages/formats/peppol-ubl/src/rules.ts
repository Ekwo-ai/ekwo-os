/**
 * The published rules, re-read against what is about to be written.
 *
 * A Peppol access point validates an invoice three times before it carries it:
 * against the UBL 2.1 schema, against the Schematron of EN 16931, and against
 * the Schematron of Peppol BIS Billing 3.0. The two Schematrons are XSLT 2.0,
 * which nothing in a JavaScript runtime executes, so they cannot be run from
 * here. What can be done is to read each assertion and ask the same question
 * of the same figures — and to name the answer by the identifier the rule is
 * published under, so that what this package reports and what the network
 * would report are the same sentence.
 *
 * Every function below cites the rule it re-reads. The rule identifiers are
 * checked against the Schematron itself by `test/rules.test.ts`, and the
 * verdicts by the procedure the README describes. What is *not* here is listed
 * in the README, by name.
 */

import {
  COUNTRY_CODES,
  CURRENCY_CODES,
  ELECTRONIC_ADDRESS_SCHEMES,
  EXEMPTION_REASON_CODES,
  IDENTIFIER_SCHEMES,
  PAYMENT_MEANS_CODES,
  UNIT_CODES,
  VAT_CATEGORY_CODES,
  VAT_IDENTIFIER_PREFIXES,
} from './codelists.js';
import {
  type Decimal,
  ZERO,
  abs,
  add,
  compare,
  equal,
  formatDecimal,
  isZero,
  multiply,
  roundXPath,
  significantScale,
  subtract,
  sum,
} from './decimal.js';
import type { DocumentModel, LineModel, PartyModel, SubtotalModel } from './model.js';
import type { Violation } from './types.js';

const ONE: Decimal = { units: 1n, scale: 0 };
const SLACK: Decimal = { units: 2n, scale: 2 };

/** The categories whose rules come in the same numbered family, and the letters the family is named with. */
const FAMILIES: Readonly<Record<string, string>> = {
  S: 'S',
  Z: 'Z',
  E: 'E',
  AE: 'AE',
  K: 'IC',
  G: 'G',
  O: 'O',
};

/** Exemption reason codes that belong to one category and no other (PEPPOL-EN16931-P0104 to P0111). */
const CODE_CATEGORY: Readonly<Record<string, readonly [rule: string, category: string]>> = {
  'VATEX-EU-G': ['PEPPOL-EN16931-P0104', 'G'],
  'VATEX-EU-O': ['PEPPOL-EN16931-P0105', 'O'],
  'VATEX-EU-IC': ['PEPPOL-EN16931-P0106', 'K'],
  'VATEX-EU-AE': ['PEPPOL-EN16931-P0107', 'AE'],
  'VATEX-EU-D': ['PEPPOL-EN16931-P0108', 'E'],
  'VATEX-EU-F': ['PEPPOL-EN16931-P0109', 'E'],
  'VATEX-EU-I': ['PEPPOL-EN16931-P0110', 'E'],
  'VATEX-EU-J': ['PEPPOL-EN16931-P0111', 'E'],
};

/**
 * Electronic address schemes EN 16931 lists and Peppol does not: an e-mail
 * address or a telephone number is an electronic address to the standard and
 * not somewhere the network delivers. The Peppol Schematron carries its own,
 * shorter list (`eaid`); this is the difference between the two, and
 * `scripts/play-schematron.mjs` recomputes it from the published files.
 */
export const SCHEMES_NOT_ON_PEPPOL: readonly string[] = Object.freeze(['0219', '0220', 'AN', 'AQ', 'AS', 'AU', 'EM']);

const money = (value: Decimal): string => formatDecimal(value, 2);

/**
 * BR-DEC-* and UBL-DT-01: an amount has two decimals at most. The first is the
 * rule of the standard, one per business term; the second is the rule of its
 * UBL binding, one for every amount that is not a price. Both fire.
 */
function decimalsRule(code: string, value: Decimal | null, what: string, out: Violation[], line?: string): void {
  if (value === null || significantScale(value) <= 2) return;
  const message = `${what}, ${formatDecimal(value)}, has more than two decimals.`;
  const on = line === undefined ? {} : { line };
  out.push({ code, message, ...on }, { code: 'UBL-DT-01', message, ...on });
}

/** `u:gln` of the Peppol Schematron: the GS1 check digit. */
function validGln(value: string): boolean {
  if (!/^[0-9]+$/.test(value)) return false;
  const body = [...value.slice(0, -1)].reverse().map(Number);
  const weighted = body.reduce((total, digit, i) => total + digit * (1 + ((i + 1) % 2) * 2), 0);
  return (10 - (weighted % 10)) % 10 === Number(value.slice(-1));
}

/** `u:mod97-0208` of the Peppol Schematron: the check digits of a Belgian enterprise number. */
function validEnterpriseNumber0208(value: string): boolean {
  if (!/^[0-9]{10}$/.test(value)) return false;
  return 97 - (Number(value.slice(0, 8)) % 97) === Number(value.slice(8));
}

/** PEPPOL-COMMON-R040 and R043: an identifier in a scheme that has a check digit. */
function identifierRules(scheme: string | null, value: string | null, what: string, out: Violation[]): void {
  if (scheme === null || value === null) return;
  if (scheme === '0088' && !validGln(value)) {
    out.push({ code: 'PEPPOL-COMMON-R040', message: `${what} is given as a GLN and ${value} is not one: its check digit is wrong.` });
  }
  if (scheme === '0208' && !validEnterpriseNumber0208(value)) {
    out.push({
      code: 'PEPPOL-COMMON-R043',
      message: `${what} is given in scheme 0208 and ${value} is not a Belgian enterprise number: ten digits, the last two being 97 less the first eight modulo 97.`,
    });
  }
}

function partyRules(party: PartyModel, who: 'seller' | 'buyer', out: Violation[]): void {
  const seller = who === 'seller';
  const Who = seller ? 'The seller' : 'The buyer';

  if (party.registrationName === null) {
    out.push({ code: seller ? 'BR-06' : 'BR-07', message: `${Who} has no name.` });
  }
  if (party.address === null) {
    out.push({ code: seller ? 'BR-08' : 'BR-10', message: `${Who} has no postal address.` });
  } else if (party.address.country === null) {
    out.push({ code: seller ? 'BR-09' : 'BR-11', message: `The address of ${who === 'seller' ? 'the seller' : 'the buyer'} has no country.` });
  } else if (!COUNTRY_CODES.has(party.address.country)) {
    out.push({ code: 'BR-CL-14', message: `${party.address.country} is not an ISO 3166-1 country code.` });
  }

  if (party.endpoint === null) {
    out.push({
      code: seller ? 'PEPPOL-EN16931-R020' : 'PEPPOL-EN16931-R010',
      message: `${Who} has no electronic address, and the network delivers to nothing else.`,
    });
  } else if (party.endpoint.scheme === '') {
    out.push({ code: seller ? 'BR-62' : 'BR-63', message: `The electronic address of ${seller ? 'the seller' : 'the buyer'} names no scheme.` });
  } else if (!ELECTRONIC_ADDRESS_SCHEMES.has(party.endpoint.scheme)) {
    // The two Schematrons each carry the list and each report it.
    const message = `${party.endpoint.scheme} is not an electronic address scheme (EAS).`;
    out.push({ code: 'BR-CL-25', message }, { code: 'PEPPOL-EN16931-CL008', message });
  } else if (SCHEMES_NOT_ON_PEPPOL.includes(party.endpoint.scheme)) {
    out.push({
      code: 'PEPPOL-EN16931-CL008',
      message: `${party.endpoint.scheme} is an electronic address scheme of EN 16931 and not one Peppol delivers to.`,
    });
  } else {
    identifierRules(party.endpoint.scheme, party.endpoint.id, `The electronic address of ${seller ? 'the seller' : 'the buyer'}`, out);
  }

  if (party.vatId !== null && !VAT_IDENTIFIER_PREFIXES.has(party.vatId.slice(0, 2))) {
    out.push({
      code: 'BR-CO-09',
      message: `The VAT identifier of ${seller ? 'the seller' : 'the buyer'} starts with ${party.vatId.slice(0, 2)}, which is not a country.`,
    });
  }
  if (party.legalIdScheme !== null) {
    if (!IDENTIFIER_SCHEMES.has(party.legalIdScheme)) {
      out.push({ code: 'BR-CL-11', message: `${party.legalIdScheme} is not an ISO 6523 identifier scheme.` });
    } else {
      identifierRules(party.legalIdScheme, party.legalId, `The registration number of ${seller ? 'the seller' : 'the buyer'}`, out);
    }
  }
  if (seller && party.vatId === null && party.legalId === null) {
    out.push({ code: 'BR-CO-26', message: 'The seller has neither a VAT identifier nor a registration number, so a buyer cannot tell who it is.' });
  }
}

function lineRules(line: LineModel, out: Violation[]): void {
  const on = { line: line.id };
  if (line.quantity === null) out.push({ code: 'BR-22', message: 'The line has no quantity.', ...on });
  if (line.unitCode === null) {
    out.push({ code: 'BR-23', message: 'The quantity of the line has no unit.', ...on });
  } else if (!UNIT_CODES.has(line.unitCode)) {
    out.push({ code: 'BR-CL-23', message: `${line.unitCode} is not a unit of UN/ECE Recommendation 20.`, ...on });
  }
  if (line.name === null) out.push({ code: 'BR-25', message: 'The line names no item.', ...on });
  decimalsRule('BR-DEC-23', line.netAmount, 'The net amount of the line', out, line.id);

  if (line.netPrice === null) {
    out.push({
      code: 'BR-26',
      message: 'The line has no net price. A price keyed with its tax in it is not one, and the net price is not worked out here.',
      ...on,
    });
    // The rule that a price is not negative is written so that an absent price
    // fails it too, and a validator reports the two together.
    out.push({ code: 'BR-27', message: 'The line has no net price, which the rule against a negative one also refuses.', ...on });
  } else if (line.netPrice.units < 0n) {
    out.push({ code: 'BR-27', message: `The net price of the line, ${formatDecimal(line.netPrice)}, is negative.`, ...on });
  }
  if (line.grossPrice !== null && line.grossPrice.units < 0n) {
    out.push({ code: 'BR-28', message: `The gross price of the line, ${formatDecimal(line.grossPrice)}, is negative.`, ...on });
  }

  // PEPPOL-EN16931-R120: the net amount is the quantity times the net price,
  // give or take two cents. An absent quantity counts for one and an absent
  // price for nothing, as the rule itself reads them.
  const expected = multiply(line.quantity ?? ONE, line.netPrice ?? ZERO);
  if (compare(add(line.netAmount, SLACK), expected) < 0 || compare(subtract(line.netAmount, SLACK), expected) > 0) {
    out.push({
      code: 'PEPPOL-EN16931-R120',
      message: `The net amount of the line is ${money(line.netAmount)} and its quantity times its net price is ${formatDecimal(expected)}.`,
      ...on,
    });
  }

  if (line.category === null) {
    // Once for the standard, once for its UBL binding, which counts the element.
    out.push(
      { code: 'BR-CO-04', message: 'The line has no VAT category.', ...on },
      { code: 'UBL-SR-48', message: 'The line has no VAT category, and the UBL binding wants exactly one.', ...on },
    );
    return;
  }
  if (!VAT_CATEGORY_CODES.has(line.category)) {
    out.push({ code: 'BR-CL-18', message: `${line.category} is not a VAT category of EN 16931.`, ...on });
    return;
  }
  const family = FAMILIES[line.category];
  if (family === undefined) return;
  if (line.category === 'S') {
    if (line.rate === null || line.rate.units <= 0n) {
      out.push({ code: 'BR-S-05', message: 'A standard-rated line has a rate above zero.', ...on });
    }
  } else if (line.category === 'O') {
    if (line.rate !== null && !isZero(line.rate)) {
      out.push({ code: 'BR-O-05', message: 'A line outside the scope of VAT has no rate.', ...on });
    }
  } else if (line.rate === null || !isZero(line.rate)) {
    out.push({ code: `BR-${family}-05`, message: `A line in category ${line.category} has a rate of zero.`, ...on });
  }
}

function subtotalRules(model: DocumentModel, subtotal: SubtotalModel, out: Violation[]): void {
  const { category, rate } = subtotal;
  const label = `${category ?? '?'}${rate === null ? '' : ` at ${formatDecimal(rate)} %`}`;

  decimalsRule('BR-DEC-19', subtotal.base, `The base of the VAT group ${label}`, out);
  decimalsRule('BR-DEC-20', subtotal.tax, `The tax of the VAT group ${label}`, out);
  if (category === null) {
    out.push({ code: 'BR-47', message: 'A group of the VAT breakdown has no category.' });
    return;
  }
  if (!VAT_CATEGORY_CODES.has(category)) {
    out.push({ code: 'BR-CL-17', message: `${category} is not a VAT category of EN 16931.` });
    return;
  }
  if (rate === null && category !== 'O') {
    out.push({ code: 'BR-48', message: `The VAT group ${label} has no rate.` });
    // A standard-rated group is also asked for a tax that is its base times its
    // rate, and with no rate the answer is no.
    if (category === 'S') out.push({ code: 'BR-S-09', message: 'A standard-rated group has no rate to work its tax out from.' });
  }

  // BR-CO-17: the tax of a group is its base times its rate, within one unit
  // either way. One unit and not one cent: the standard leaves room for a tax
  // rounded line by line, and this re-reads the rule rather than tightening it.
  const written = category === 'O' && (rate === null || isZero(rate)) ? null : rate;
  const rounded = written === null ? ZERO : roundXPath(written, 0);
  if (isZero(rounded)) {
    if (!isZero(roundXPath(subtotal.tax, 0))) {
      out.push({ code: 'BR-CO-17', message: `The VAT group ${label} has no rate and a tax of ${money(subtotal.tax)}.` });
    }
  } else {
    const expected = roundXPath({ units: multiply(abs(subtotal.base), written as Decimal).units, scale: subtotal.base.scale + (written as Decimal).scale + 2 }, 2);
    const tax = abs(subtotal.tax);
    if (!(compare(subtract(tax, ONE), expected) < 0 && compare(add(tax, ONE), expected) > 0)) {
      out.push({
        code: 'BR-CO-17',
        message: `The VAT group ${label} has a base of ${money(subtotal.base)} and a tax of ${money(subtotal.tax)}, which is not the one times the other.`,
      });
      if (category === 'S') {
        out.push({ code: 'BR-S-09', message: `The tax of the standard-rated group at ${formatDecimal(written as Decimal)} % is not its base times its rate.` });
      }
    }
  }

  const family = FAMILIES[category];
  if (family === undefined) return;

  // BR-*-08: the base of a group is the sum of the lines of its category —
  // within one unit for the standard rate, where a group is also a rate, and
  // to the cent for every other category, which has one group whatever its
  // lines say of their rate.
  if (category === 'S') {
    if (written !== null) {
      const ofRate = model.lines.filter((line) => line.category === 'S' && line.rate !== null && equal(line.rate, written));
      const lines = sum(ofRate.map((line) => line.netAmount));
      const within = compare(subtract(subtotal.base, ONE), lines) < 0 && compare(add(subtotal.base, ONE), lines) > 0;
      if (ofRate.length === 0 || !within) {
        out.push({
          code: 'BR-S-08',
          message: `The standard-rated group at ${formatDecimal(written)} % has a base of ${money(subtotal.base)} and its lines add up to ${money(lines)}.`,
        });
      }
    }
  } else {
    const lines = sum(model.lines.filter((line) => line.category === category).map((line) => line.netAmount));
    if (!equal(subtotal.base, lines)) {
      out.push({
        code: `BR-${family}-08`,
        message: `The VAT group ${category} has a base of ${money(subtotal.base)} and its lines add up to ${money(lines)}.`,
      });
    }
    if (category !== 'Z' && !isZero(subtotal.tax)) {
      out.push({ code: `BR-${family}-09`, message: `The VAT group ${category} charges ${money(subtotal.tax)}, and a group of that category charges nothing.` });
    }
    if (category === 'Z' && !isZero(subtotal.tax)) {
      out.push({ code: 'BR-Z-09', message: `The zero-rated group charges ${money(subtotal.tax)}.` });
    }
  }

  // BR-*-10: a reason where the category exempts, and none where it does not.
  const reasoned = subtotal.reasonCode !== null || subtotal.reason !== null;
  if (category === 'S' || category === 'Z') {
    if (reasoned) out.push({ code: `BR-${family}-10`, message: `The VAT group ${label} gives a reason for an exemption it is not.` });
  } else if (!reasoned) {
    out.push({ code: `BR-${family}-10`, message: `The VAT group ${category} gives no reason for charging no tax: neither a code nor a text.` });
  }
  if (subtotal.ambiguousReasonCodes.length > 0) {
    out.push({
      code: 'exemption-reason-ambiguous',
      message: `The lines of the VAT group ${category} carry several exemption codes (${subtotal.ambiguousReasonCodes.join(', ')}) and a group has room for one: none was written.`,
    });
  }
  if (subtotal.reasonCode !== null) {
    const code = subtotal.reasonCode;
    if (!EXEMPTION_REASON_CODES.has(code.toUpperCase()) && !EXEMPTION_REASON_CODES.has(code)) {
      out.push({ code: 'BR-CL-22', message: `${code} is not a VATEX exemption reason code.` });
    }
    const belongs = CODE_CATEGORY[code.toUpperCase()];
    if (belongs && belongs[1] !== category) {
      out.push({ code: belongs[0], message: `${code} is the reason of category ${belongs[1]} and stands on a group of category ${category}.` });
    }
  }
}

/** Every published rule the document breaks, in the order a reader meets them. */
export function check(model: DocumentModel): Violation[] {
  const out: Violation[] = [];

  // --- The document -------------------------------------------------------
  if (model.buyerReference === null && model.orderReference === null) {
    out.push({ code: 'PEPPOL-EN16931-R003', message: 'The document carries neither a buyer reference nor a purchase order reference, and the network requires one of the two.' });
  }
  if (!CURRENCY_CODES.has(model.currency)) {
    // One wrong code is reported where it is declared and where it is used.
    const message = `${model.currency} is not an ISO 4217 currency code.`;
    out.push({ code: 'BR-CL-04', message }, { code: 'BR-CL-03', message }, { code: 'PEPPOL-EN16931-CL007', message });
  }

  partyRules(model.seller, 'seller', out);
  partyRules(model.buyer, 'buyer', out);

  if (model.delivery?.address) {
    const { country } = model.delivery.address;
    if (country === null) out.push({ code: 'BR-57', message: 'The delivery address has no country.' });
    else if (!COUNTRY_CODES.has(country)) out.push({ code: 'BR-CL-14', message: `${country} is not an ISO 3166-1 country code.` });
  }

  // --- Payment ------------------------------------------------------------
  if (model.paymentWithoutMeans) {
    out.push({
      code: 'payment-means-missing',
      message: 'An account or a payment reference was given without a payment means code (UNTDID 4461). The format files both under the code, so neither was written.',
    });
  }
  if (model.payment) {
    const { meansCode, iban } = model.payment;
    if (!PAYMENT_MEANS_CODES.has(meansCode)) {
      out.push({ code: 'BR-CL-16', message: `${meansCode} is not a UNTDID 4461 payment means code.` });
    }
    if ((meansCode === '30' || meansCode === '58') && iban === null) {
      out.push({ code: 'BR-61', message: `Payment means ${meansCode} is a credit transfer, and no account to transfer to is given.` });
    }
  }
  if (model.kind === 'Invoice' && model.payable.units > 0n && model.dueDate === null && model.paymentTerms === null) {
    out.push({ code: 'BR-CO-25', message: `${money(model.payable)} is due and the invoice says neither when nor on what terms.` });
  }

  // --- Lines --------------------------------------------------------------
  for (const line of model.lines) lineRules(line, out);

  // --- The VAT breakdown ----------------------------------------------------
  if (model.subtotals.length === 0) {
    // Once for the standard, once for Peppol, which counts the totals that have groups.
    out.push(
      { code: 'BR-CO-18', message: 'The document has no VAT breakdown.' },
      { code: 'PEPPOL-EN16931-R053', message: 'The document has no VAT total with a breakdown, and Peppol wants exactly one.' },
      // The total is still written, because the books have one; and a total
      // with nothing under it is what Peppol keeps for a second currency.
      { code: 'PEPPOL-EN16931-R054', message: 'The VAT total stands without a breakdown, which Peppol allows only for a total in a second currency.' },
    );
  }
  for (const subtotal of model.subtotals) subtotalRules(model, subtotal, out);

  for (const [category, family] of Object.entries(FAMILIES)) {
    const onLines = model.lines.some((line) => line.category === category);
    const groups = model.subtotals.filter((subtotal) => subtotal.category === category).length;
    // BR-*-01. The standard rate has one group per rate and wants at least one;
    // every other category has exactly one, and a group without a line is as
    // much of a mismatch as a line without a group.
    const broken = category === 'S' ? onLines !== groups > 0 : (onLines || groups > 0) && groups !== 1;
    if (broken) {
      out.push({
        code: `BR-${family}-01`,
        message: onLines
          ? `Lines are in VAT category ${category} and the breakdown has ${groups === 0 ? 'no group' : `${groups} groups`} for it.`
          : `The breakdown has a group for VAT category ${category} and no line is in it.`,
      });
    }
    if (!onLines) continue;

    // BR-*-02: who has to be identified for VAT when a line is in this category.
    const sellerVat = model.seller.vatId !== null;
    const buyerVat = model.buyer.vatId !== null;
    if (category === 'O') {
      if (sellerVat || buyerVat) {
        out.push({ code: 'BR-O-02', message: 'A document outside the scope of VAT carries no VAT identifier, and this one carries one.' });
      }
    } else if (!sellerVat) {
      out.push({ code: `BR-${family}-02`, message: `A line is in VAT category ${category} and the seller has no VAT identifier.` });
    } else if (category === 'K' && !buyerVat) {
      out.push({ code: 'BR-IC-02', message: 'An intra-community supply names the VAT identifier of the buyer, and the buyer has none.' });
    } else if (category === 'AE' && !buyerVat && model.buyer.legalId === null) {
      out.push({ code: 'BR-AE-02', message: 'A reverse charge names the buyer by a VAT identifier or a registration number, and the buyer has neither.' });
    }
  }

  const categories = new Set(model.subtotals.map((subtotal) => subtotal.category));
  if (categories.has('O')) {
    if (categories.size > 1) out.push({ code: 'BR-O-11', message: 'A breakdown with a group outside the scope of VAT has no other group.' });
    if (model.lines.some((line) => line.category !== 'O')) {
      out.push({ code: 'BR-O-12', message: 'A document with a group outside the scope of VAT has no line in another category.' });
    }
  }
  if (categories.has('K')) {
    if (model.delivery?.date == null) {
      out.push({ code: 'BR-IC-11', message: 'An intra-community supply says when the goods were delivered, and this one has no delivery date.' });
    }
    if (model.delivery?.address?.country == null) {
      out.push({ code: 'BR-IC-12', message: 'An intra-community supply says which country the goods were delivered to, and this one has no delivery country.' });
    }
  }

  // --- Totals -------------------------------------------------------------
  const decimals: [string, Decimal | null, string][] = [
    ['BR-DEC-09', model.lineTotal, 'The sum of the lines'],
    ['BR-DEC-12', model.taxExclusive, 'The total without VAT'],
    ['BR-DEC-14', model.taxInclusive, 'The total with VAT'],
    ['BR-DEC-16', model.prepaid, 'The amount paid'],
    ['BR-DEC-18', model.payable, 'The amount due'],
  ];
  for (const [code, value, what] of decimals) decimalsRule(code, value, what, out);
  // The total VAT has a rule of its own, BR-DEC-13, and the published
  // Schematron never reports it: its test looks for the currency of the
  // document underneath the amount, where it is not. The rule of the binding
  // catches the same digits, and it is the one that is reported here.
  if (significantScale(model.taxTotal) > 2) {
    out.push({ code: 'UBL-DT-01', message: `The total VAT, ${formatDecimal(model.taxTotal)}, has more than two decimals.` });
  }

  const lines = sum(model.lines.map((line) => line.netAmount));
  if (!equal(model.lineTotal, roundXPath(lines, 2))) {
    out.push({ code: 'BR-CO-10', message: `The lines add up to ${money(lines)} and the document says ${money(model.lineTotal)}.` });
  }
  const taxes = sum(model.subtotals.map((subtotal) => subtotal.tax));
  if (model.subtotals.length > 0 && !equal(model.taxTotal, roundXPath(taxes, 2))) {
    out.push({ code: 'BR-CO-14', message: `The VAT groups add up to ${money(taxes)} and the document says ${money(model.taxTotal)}.` });
  }
  if (!equal(model.taxInclusive, roundXPath(add(model.taxExclusive, model.taxTotal), 2))) {
    out.push({
      code: 'BR-CO-15',
      message: `${money(model.taxExclusive)} without VAT and ${money(model.taxTotal)} of VAT are not the ${money(model.taxInclusive)} the document totals.`,
    });
  }
  // BR-CO-16 rounds the difference where something was paid and compares the
  // two figures as they stand where nothing was — which is how it is written,
  // and the difference shows on an amount with a third decimal.
  const due = model.prepaid === null ? model.taxInclusive : roundXPath(subtract(model.taxInclusive, model.prepaid), 2);
  if (!equal(model.payable, due)) {
    out.push({
      code: 'BR-CO-16',
      message: `${money(model.taxInclusive)} less ${money(model.prepaid ?? ZERO)} already paid is not the ${money(model.payable)} the document says is due.`,
    });
  }

  return out;
}
