/**
 * From three reads of the books to what the file will say.
 *
 * Everything that is decided is decided here, once: which number goes in which
 * business term, which lines are lines, how the taxes of the books become the
 * VAT breakdown of the standard. The writer prints this model and the rules
 * re-read it, so the file and what is said of the file cannot disagree.
 *
 * What is refused here is what would make the file absurd rather than wrong:
 * a purchase, a draft without a number, an amount that is not a number. Those
 * throw. Everything else is kept as it was given and left to the rules.
 */

import {
  type Decimal,
  ZERO,
  add,
  formatDecimal,
  isZero,
  multiply,
  parseDecimal,
  subtract,
} from './decimal.js';
import type {
  DocumentHeaderRow,
  DocumentLineRow,
  DocumentTaxRow,
  ElectronicAddress,
  Numeric,
  PeppolUblInput,
  PeppolUblOptions,
} from './types.js';

export class PeppolUblError extends Error {
  override name = 'PeppolUblError';
}

export interface PartyModel {
  endpoint: ElectronicAddress | null;
  /** BT-28, only where a legal name stands beside it and differs. */
  tradeName: string | null;
  /** BT-27 / BT-44. */
  registrationName: string | null;
  legalForm: string | null;
  vatId: string | null;
  legalId: string | null;
  legalIdScheme: string | null;
  address: {
    line1: string | null;
    line2: string | null;
    city: string | null;
    postalCode: string | null;
    region: string | null;
    country: string | null;
  } | null;
  contact: { phone: string | null; email: string | null } | null;
}

export interface LineModel {
  id: string;
  quantity: Decimal | null;
  unitCode: string | null;
  netAmount: Decimal;
  name: string | null;
  description: string | null;
  sellerItemId: string | null;
  category: string | null;
  rate: Decimal | null;
  /** BT-146. Null where the books cannot say it. */
  netPrice: Decimal | null;
  /** BT-148 and BT-147, written only where a discount stands between the two prices. */
  grossPrice: Decimal | null;
  priceDiscount: Decimal | null;
}

export interface SubtotalModel {
  category: string | null;
  rate: Decimal | null;
  base: Decimal;
  tax: Decimal;
  reasonCode: string | null;
  reason: string | null;
  /** More than one exemption code was found for this group, so none was written. */
  ambiguousReasonCodes: string[];
}

export interface DocumentModel {
  kind: 'Invoice' | 'CreditNote';
  /** BT-3, UNTDID 1001: 380 for an invoice, 381 for a credit note. */
  typeCode: '380' | '381';
  number: string;
  issueDate: string;
  dueDate: string | null;
  taxPointDate: string | null;
  note: string | null;
  currency: string;
  buyerReference: string | null;
  orderReference: string | null;
  contractReference: string | null;
  projectReference: string | null;
  preceding: { number: string; issueDate: string | null } | null;
  seller: PartyModel;
  buyer: PartyModel;
  delivery: {
    date: string | null;
    address: { line1: string | null; city: string | null; postalCode: string | null; country: string | null } | null;
  } | null;
  payment: { meansCode: string; reference: string | null; iban: string | null; bic: string | null } | null;
  /** An account or a reference was given with no code to file it under, so nothing was written. */
  paymentWithoutMeans: boolean;
  paymentTerms: string | null;
  taxTotal: Decimal;
  subtotals: SubtotalModel[];
  lineTotal: Decimal;
  taxExclusive: Decimal;
  taxInclusive: Decimal;
  prepaid: Decimal | null;
  payable: Decimal;
  lines: LineModel[];
}

const DATE = /^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$/;

/** A value with something in it, or null. Blank text is the absence of text. */
function text(value: string | null | undefined): string | null {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed === '' ? null : trimmed;
}

function date(value: string | null | undefined, what: string): string | null {
  // A database driver hands a `date` column back as a `Date`: an instant, at a
  // midnight that is UTC for one driver and local for the next. Which day that
  // is depends on where the process runs, so it is refused rather than guessed
  // — `select document_date::text` is the day the books mean.
  if ((value as unknown) instanceof Date) {
    throw new PeppolUblError(`${what} was given as a Date object, which is an instant and not a day: pass it as YYYY-MM-DD text`);
  }
  const raw = text(value);
  if (raw === null) return null;
  // A timestamp is accepted for the day it names; anything else is not a date.
  const day = raw.slice(0, 10);
  // 30 February has the shape of a date and is read by JavaScript as 2 March.
  const parsed = DATE.test(day) ? new Date(`${day}T00:00:00Z`) : null;
  if (parsed === null || Number.isNaN(parsed.getTime()) || parsed.toISOString().slice(0, 10) !== day) {
    throw new PeppolUblError(`${what} is not a date: ${raw}`);
  }
  return day;
}

function amount(value: Numeric | null | undefined, what: string): Decimal {
  const parsed = parseDecimal(value);
  if (parsed === null) throw new PeppolUblError(`${what} is not an amount: ${String(value)}`);
  return parsed;
}

function optionalAmount(value: Numeric | null | undefined, what: string): Decimal | null {
  if (value === null || value === undefined || value === '') return null;
  return amount(value, what);
}

/** An identifier as a register compares it: no spaces, no dots. */
function identifier(value: string | null | undefined): string | null {
  const raw = text(value);
  return raw === null ? null : raw.replace(/[\s.]/g, '');
}

/**
 * An electronic address: the one the caller gave, else the one the header
 * carries. Never one worked out from another identifier.
 */
function endpoint(
  given: ElectronicAddress | undefined,
  scheme: string | null | undefined,
  identifier: string | null | undefined,
): ElectronicAddress | null {
  const id = text(given ? given.id : identifier);
  if (id === null) return null;
  return { scheme: text(given ? given.scheme : scheme) ?? '', id };
}

function party(
  header: DocumentHeaderRow,
  who: 'seller' | 'buyer',
  address: ElectronicAddress | undefined,
  registrationScheme: string | undefined,
): PartyModel {
  const seller = who === 'seller';
  const name = text(seller ? header.seller_name : header.buyer_name);
  const legalName = seller ? text(header.seller_legal_name) : null;
  const registrationName = legalName ?? name;
  const fields = {
    line1: text(seller ? header.seller_address_line1 : header.buyer_address_line1),
    line2: text(seller ? header.seller_address_line2 : header.buyer_address_line2),
    city: text(seller ? header.seller_city : header.buyer_city),
    postalCode: text(seller ? header.seller_postal_code : header.buyer_postal_code),
    region: text(seller ? header.seller_region : header.buyer_region),
    country: text(seller ? header.seller_country : header.buyer_country)?.toUpperCase() ?? null,
  };
  const phone = seller ? text(header.seller_phone) : null;
  const email = text(seller ? header.seller_email : header.buyer_email);
  const legalId = identifier(seller ? header.seller_registration_number : header.buyer_registration_number);
  return {
    endpoint: endpoint(
      address,
      seller ? header.seller_peppol_scheme : header.buyer_peppol_scheme,
      seller ? header.seller_peppol_identifier : header.buyer_peppol_identifier,
    ),
    tradeName: legalName !== null && name !== null && name !== legalName ? name : null,
    registrationName,
    legalForm: seller ? text(header.seller_legal_form) : null,
    vatId: identifier(seller ? header.seller_vat_number : header.buyer_vat_number)?.toUpperCase() ?? null,
    legalId,
    legalIdScheme: legalId !== null ? text(registrationScheme) : null,
    address: Object.values(fields).some((value) => value !== null) ? fields : null,
    contact: phone !== null || email !== null ? { phone, email } : null,
  };
}

function line(row: DocumentLineRow, position: number): LineModel {
  const id = text(row.sequence === null || row.sequence === undefined ? null : String(row.sequence)) ?? String(position);
  const what = `line ${id}`;
  const keyed = optionalAmount(row.unit_price, `the unit price of ${what}`);
  const discount = optionalAmount(row.discount_percent, `the discount of ${what}`);

  let netPrice: Decimal | null;
  let grossPrice: Decimal | null = null;
  let priceDiscount: Decimal | null = null;
  if (row.unit_price_includes_tax) {
    // The keyed price holds the tax. The net one is the books' to give.
    netPrice = optionalAmount(row.net_unit_price, `the net unit price of ${what}`);
  } else if (keyed !== null && discount !== null && !isZero(discount)) {
    // BT-147 = BT-148 × the discount, BT-146 = BT-148 − BT-147. Exact: a price
    // has as many decimals as it needs, and nothing is rounded to get there.
    grossPrice = keyed;
    priceDiscount = { units: multiply(keyed, discount).units, scale: keyed.scale + discount.scale + 2 };
    netPrice = subtract(keyed, priceDiscount);
  } else {
    netPrice = optionalAmount(row.net_unit_price, `the net unit price of ${what}`) ?? keyed;
  }

  return {
    id,
    quantity: optionalAmount(row.quantity, `the quantity of ${what}`),
    unitCode: text(row.unit_code),
    netAmount: amount(row.amount_untaxed, `the net amount of ${what}`),
    name: text(row.item_name),
    description: text(row.item_description),
    sellerItemId: text(row.seller_item_identifier),
    category: text(row.vat_category)?.toUpperCase() ?? null,
    rate: optionalAmount(row.vat_rate, `the VAT rate of ${what}`),
    netPrice,
    grossPrice,
    priceDiscount,
  };
}

/**
 * The VAT breakdown of the standard from the taxes of the books.
 *
 * The books keep one row per tax; EN 16931 wants one group per category and
 * rate (BG-23). Two taxes at the same rate — goods and services at the standard
 * rate is the ordinary case — are therefore one group here, their bases added
 * and their taxes added. Adding is all that is done: each tax was rounded once
 * by the books and is not rounded again.
 */
function subtotals(input: PeppolUblInput): SubtotalModel[] {
  const groups = new Map<
    string,
    SubtotalModel & { codes: Set<string>; reasons: Set<string>; codedByBreakdown: boolean }
  >();
  const keyOf = (category: string | null, rate: Decimal | null): string =>
    `${category ?? ''}|${rate === null ? '' : formatDecimal(rate)}`;

  for (const row of input.taxes) {
    const category = text(row.vat_category)?.toUpperCase() ?? null;
    const rate = optionalAmount(row.tax_rate, 'a VAT rate of the breakdown');
    const key = keyOf(category, rate);
    const group = groups.get(key) ?? {
      category,
      rate,
      base: ZERO,
      tax: ZERO,
      reasonCode: null,
      reason: null,
      ambiguousReasonCodes: [],
      codes: new Set<string>(),
      reasons: new Set<string>(),
      codedByBreakdown: false,
    };
    group.base = add(group.base, amount(row.base_amount, 'a base of the VAT breakdown'));
    group.tax = add(group.tax, amount(row.tax_charged, 'a tax of the VAT breakdown'));
    const code = text(row.exemption_code);
    if (code !== null) {
      group.codes.add(code);
      group.codedByBreakdown = true;
    }
    const reason = text(row.exemption_reason);
    if (reason !== null) group.reasons.add(reason);
    groups.set(key, group);
  }

  // A group the breakdown gave no code to takes the one its lines carry.
  for (const row of input.lines) {
    if ((row.line_type ?? 'product') !== 'product') continue;
    const code = text(row.tax_exemption_code);
    if (code === null) continue;
    const category = text(row.vat_category)?.toUpperCase() ?? null;
    const group = groups.get(keyOf(category, optionalAmount(row.vat_rate, 'a VAT rate')));
    if (group && !group.codedByBreakdown) group.codes.add(code);
  }

  return [...groups.values()].map(({ codes, reasons, codedByBreakdown: _, ...group }) => ({
    ...group,
    reasonCode: codes.size === 1 ? ([...codes][0] as string) : null,
    // Several reasons for one group are several sentences, and a sentence can
    // be joined to another where a code cannot.
    reason: reasons.size > 0 ? [...reasons].join(' ') : null,
    ambiguousReasonCodes: codes.size > 1 ? [...codes].sort() : [],
  }));
}

export function buildModel(given: PeppolUblInput, options: PeppolUblOptions): DocumentModel {
  const input = given;
  const { header } = input;
  const kind = header.doc_type === 'sale_invoice' ? 'Invoice' : header.doc_type === 'sale_credit_note' ? 'CreditNote' : null;
  if (kind === null) {
    throw new PeppolUblError(
      `a ${String(header.doc_type)} is not a document this format carries: only a sales invoice and a sales credit note are`,
    );
  }
  const number = text(header.number);
  if (number === null) throw new PeppolUblError('the document has no number: it was never issued');
  const issueDate = date(header.document_date, 'the document date');
  if (issueDate === null) throw new PeppolUblError('the document has no date');
  const currency = text(header.currency_code)?.toUpperCase() ?? null;
  if (currency === null) throw new PeppolUblError('the document has no currency, and there is no default');

  const lines = input.lines
    .filter((row) => (row.line_type ?? 'product') === 'product')
    .map((row, index) => line(row, index + 1));
  if (lines.length === 0) throw new PeppolUblError('the document has no line');

  const taxExclusive = amount(header.amount_untaxed, 'the total without VAT');
  const taxInclusive = amount(header.amount_total, 'the total with VAT');
  const paid = optionalAmount(header.amount_paid, 'the amount paid');
  const prepaid = paid !== null && !isZero(paid) ? paid : null;
  const payable =
    optionalAmount(header.amount_residual, 'the amount due') ?? subtract(taxInclusive, prepaid ?? ZERO);

  const meansCode = text(header.payment_means_code);
  const iban = identifier(header.payee_iban)?.toUpperCase() ?? null;
  const bic = identifier(header.payee_bic)?.toUpperCase() ?? null;
  const reference = text(header.payment_reference);

  const deliveryDate = date(header.delivery_date, 'the delivery date');
  const deliveryFields = {
    line1: text(header.delivery_address_line1),
    city: text(header.delivery_city),
    postalCode: text(header.delivery_postal_code),
    country: text(header.delivery_country)?.toUpperCase() ?? null,
  };
  const deliveryAddress = Object.values(deliveryFields).some((value) => value !== null) ? deliveryFields : null;

  const precedingNumber = text(options.precedingInvoice?.number);

  return {
    kind,
    typeCode: kind === 'Invoice' ? '380' : '381',
    number,
    issueDate,
    dueDate: date(header.due_date, 'the due date'),
    taxPointDate: date(header.tax_point_date, 'the tax point date'),
    note: text(header.note),
    currency,
    buyerReference: text(header.buyer_reference),
    orderReference: text(header.order_reference),
    contractReference: text(header.contract_reference),
    projectReference: text(header.project_reference),
    preceding:
      precedingNumber === null
        ? null
        : { number: precedingNumber, issueDate: date(options.precedingInvoice?.issueDate, 'the date of the preceding invoice') },
    seller: party(header, 'seller', options.sellerEndpoint, options.sellerRegistrationScheme),
    buyer: party(header, 'buyer', options.buyerEndpoint, options.buyerRegistrationScheme),
    delivery: deliveryDate !== null || deliveryAddress !== null ? { date: deliveryDate, address: deliveryAddress } : null,
    payment: meansCode === null ? null : { meansCode, reference, iban, bic },
    paymentWithoutMeans: meansCode === null && (iban !== null || bic !== null || reference !== null),
    paymentTerms: text(header.payment_terms),
    taxTotal: amount(header.amount_tax, 'the total VAT'),
    subtotals: subtotals(input),
    // There is no document-level allowance or charge in this model, so the sum
    // of the lines and the total without VAT are one figure (BR-CO-13). It is
    // the books' figure that is written in both places, not a sum made here.
    lineTotal: taxExclusive,
    taxExclusive,
    taxInclusive,
    prepaid,
    payable,
    lines,
  };
}
