/**
 * What a reader asks of a received invoice once it is read, and the small
 * helpers both readers need to read it.
 *
 * Copied, byte for byte, in the two e-invoicing bricks of this repository, as
 * `received.ts` is, and compared by the same test: a UBL invoice and a CII invoice
 * that say the same thing are held to the same rules in the same words.
 *
 * The rules are the arithmetic of EN 16931 (BR-CO-10 to BR-CO-17), re-read
 * from the published Schematron with the rounding it is written with, XPath's
 * `round()` on two decimals. A reader reports and never corrects: a total that
 * is not its parts is named here, and stays the total the file wrote.
 */

import {
  type Decimal,
  ZERO,
  abs,
  add,
  compare,
  equal,
  formatDecimal,
  multiply,
  parseDecimal,
  roundXPath,
  subtract,
  sum,
} from './decimal.js';
import { InvoiceFileError } from './errors.js';
import type { DecimalText, ReceivedInvoice, ReceivedViolation } from './received.js';

/**
 * UNTDID 1001 codes of EN 16931 that name a credit note: 81, 83, 261, 262,
 * 296, 308, 381, 396, 420, 458 and 532. Every other code of the list is an
 * invoice of one kind or another (a corrective invoice, 384, asks for money
 * like any invoice).
 */
export const CREDIT_NOTE_TYPE_CODES: ReadonlySet<string> = new Set([
  '81',
  '83',
  '261',
  '262',
  '296',
  '308',
  '381',
  '396',
  '420',
  '458',
  '532',
]);

/** A decimal as written, or a named error: an amount that is not one leaves nothing to book. */
export function decimalText(raw: string, what: string): DecimalText {
  const trimmed = raw.trim();
  if (parseDecimal(trimmed) === null) {
    throw new InvoiceFileError('invalid_value', `${what} is not a decimal: ${JSON.stringify(raw)}`);
  }
  return trimmed;
}

/** ISO 13616: move four characters to the end, letters to numbers, mod 97 is 1. */
export function isValidIban(iban: string): boolean {
  if (!/^[A-Z]{2}[0-9]{2}[A-Za-z0-9]{1,30}$/.test(iban)) return false;
  const rearranged = (iban.slice(4) + iban.slice(0, 4)).toUpperCase();
  let remainder = 0;
  for (const character of rearranged) {
    const code = character.charCodeAt(0);
    const value = code >= 65 ? code - 55 : code - 48;
    remainder = (value > 9 ? remainder * 100 + value : remainder * 10 + value) % 97;
  }
  return remainder === 1;
}

const BASE64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
const BASE64_VALUE: ReadonlyMap<string, number> = new Map([...BASE64].map((character, index) => [character, index]));

/**
 * `xs:base64Binary`, decoded: whitespace is allowed between the characters,
 * `=` only at the end and only as much as the length needs. Null for anything
 * else — a binary object that is not base64 is reported, never half-decoded.
 */
export function decodeBase64(text: string): Uint8Array | null {
  const compact = text.replace(/[\t\n\r ]+/g, '');
  if (compact.length % 4 !== 0) return null;
  const padding = compact.endsWith('==') ? 2 : compact.endsWith('=') ? 1 : 0;
  const body = compact.slice(0, compact.length - padding);
  const out = new Uint8Array((body.length * 3) >> 2);
  let buffer = 0;
  let bits = 0;
  let at = 0;
  for (const character of body) {
    const value = BASE64_VALUE.get(character);
    if (value === undefined) return null;
    buffer = (buffer << 6) | value;
    bits += 6;
    if (bits >= 8) {
      bits -= 8;
      out[at] = (buffer >> bits) & 0xff;
      at += 1;
    }
  }
  // The bits left over are padding, and RFC 4648 says they are zero.
  if ((buffer & ((1 << bits) - 1)) !== 0) return null;
  return out;
}

const money = (value: Decimal): string => formatDecimal(value, 2);
const read = (text: DecimalText | null): Decimal | null => (text === null ? null : parseDecimal(text));
const round2 = (value: Decimal): Decimal => roundXPath(value, 2);
const HUNDRED: Decimal = { units: 100n, scale: 0 };
const ONE: Decimal = { units: 1n, scale: 0 };

/**
 * BR-CO-17: the tax of a group is its base times its rate, rounded to two
 * decimals, within one unit either way; a group whose rate rounds to nothing
 * has a tax that rounds to nothing.
 */
function groupTaxRule(invoice: ReceivedInvoice, out: ReceivedViolation[]): void {
  for (const group of invoice.taxes) {
    const label = `${group.category ?? '?'} ${group.rate ?? '(no rate)'}%`;
    const base = read(group.base) as Decimal;
    const tax = read(group.tax) as Decimal;
    const rate = read(group.rate);
    if (rate === null || roundXPath(rate, 0).units === 0n) {
      if (roundXPath(tax, 0).units !== 0n) {
        out.push({ code: 'BR-CO-17', message: `The VAT group ${label} has no rate and a tax of ${group.tax}.` });
      }
      continue;
    }
    const product = multiply(abs(base), rate);
    const expected = round2({ units: product.units, scale: product.scale + 2 });
    const low = subtract(abs(tax), ONE);
    const high = add(abs(tax), ONE);
    if (!(compare(low, expected) < 0 && compare(high, expected) > 0)) {
      out.push({
        code: 'BR-CO-17',
        message: `The VAT group ${label} has a base of ${group.base} and a tax of ${group.tax}; the rate gives ${money(expected)}.`,
      });
    }
  }
}

/** The arithmetic of the document (BG-22), as EN 16931 states it. */
export function checkReceived(invoice: ReceivedInvoice): ReceivedViolation[] {
  const out: ReceivedViolation[] = [];
  const totals = invoice.totals;
  const lineTotal = read(totals.lineTotal);
  const allowanceTotal = read(totals.allowanceTotal);
  const chargeTotal = read(totals.chargeTotal);
  const taxExclusive = read(totals.taxExclusive) as Decimal;
  const taxTotal = read(totals.taxTotal);
  const taxInclusive = read(totals.taxInclusive) as Decimal;
  const prepaid = read(totals.prepaid);
  const rounding = read(totals.rounding);
  const payable = read(totals.payable) as Decimal;

  // BR-CO-10: the sum of the lines.
  if (lineTotal !== null && invoice.lines.length > 0) {
    const lines = round2(sum(invoice.lines.map((line) => read(line.netAmount) as Decimal)));
    if (!equal(lineTotal, lines)) {
      out.push({ code: 'BR-CO-10', message: `The lines add up to ${money(lines)} and the document says ${totals.lineTotal}.` });
    }
  }

  // BR-CO-11 and BR-CO-12: the sums of the allowances and of the charges.
  for (const [code, charge, total, what] of [
    ['BR-CO-11', false, allowanceTotal, 'allowances'],
    ['BR-CO-12', true, chargeTotal, 'charges'],
  ] as const) {
    const items = invoice.allowances.filter((each) => each.charge === charge);
    const added = round2(sum(items.map((each) => read(each.amount) as Decimal)));
    if (total === null ? items.length > 0 : !equal(total, added)) {
      out.push({
        code,
        message: `The ${what} of the document add up to ${money(added)} and the document says ${total === null ? 'nothing' : formatDecimal(total)}.`,
      });
    }
  }

  // BR-CO-13: the total without VAT. With neither an allowance nor a charge
  // the rule compares the two figures as written, unrounded.
  if (lineTotal !== null) {
    const adjusted = subtract(add(lineTotal, chargeTotal ?? ZERO), allowanceTotal ?? ZERO);
    const expected = chargeTotal === null && allowanceTotal === null ? lineTotal : round2(adjusted);
    if (!equal(taxExclusive, expected)) {
      out.push({
        code: 'BR-CO-13',
        message: `The total without VAT is ${totals.taxExclusive}; the lines, less the allowances and plus the charges, are ${money(expected)}.`,
      });
    }
  }

  // BR-CO-14: the total VAT is its groups.
  if (taxTotal !== null && invoice.taxes.length > 0) {
    const groups = round2(sum(invoice.taxes.map((group) => read(group.tax) as Decimal)));
    if (!equal(taxTotal, groups)) {
      out.push({ code: 'BR-CO-14', message: `The VAT groups add up to ${money(groups)} and the document says ${totals.taxTotal}.` });
    }
  }

  groupTaxRule(invoice, out);

  // BR-CO-15: the total with VAT.
  const inclusive = round2(add(taxExclusive, taxTotal ?? ZERO));
  if (!equal(taxInclusive, inclusive)) {
    out.push({
      code: 'BR-CO-15',
      message: `The total with VAT is ${totals.taxInclusive}; the total without VAT and the VAT make ${money(inclusive)}.`,
    });
  }

  // BR-CO-16: the amount due, which a rounding amount may adjust. Each side is
  // rounded only where something was subtracted from it, as the rule does.
  const due = prepaid === null ? taxInclusive : round2(subtract(taxInclusive, prepaid));
  const asked = rounding === null ? payable : round2(subtract(payable, rounding));
  if (!equal(asked, due)) {
    out.push({
      code: 'BR-CO-16',
      message: `The amount due is ${totals.payable}; the total with VAT less what was paid${rounding === null ? '' : ', and the rounding,'} is ${money(due)}.`,
    });
  }

  return out;
}
