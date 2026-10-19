/**
 * From three reads of the books, and what only the caller knows, to what the
 * document will say.
 *
 * Everything that is decided is decided here, once: which document of LHDNM's
 * list a row is, which side of the books is the supplier, which line was
 * booked under which tax and what tax type that is, what each line's tax is.
 * The writer prints this model and the rules re-read it, so the document and
 * what is said of the document cannot disagree.
 *
 * What is refused here is what would make the document absurd rather than
 * wrong: a quote, a draft without a number, an amount or a moment that is not
 * one. Those throw. What the books do not hold is reported as it is found,
 * and everything else is kept as it was given and left to the rules.
 */

import { ALPHA3, STATE_CODES } from './codelists.js';
import {
  type Decimal,
  ZERO,
  add,
  equal,
  isZero,
  multiply,
  parseDecimal,
  significantScale,
  subtract,
  sum,
} from './decimal.js';
import type {
  AdjustedDocument,
  DocumentHeaderRow,
  DocumentKind,
  DocumentLineRow,
  DocumentTaxRow,
  MyInvoisInput,
  PartyIdentifiers,
  RegistrationScheme,
  Violation,
} from './types.js';

export class MyInvoisError extends Error {
  override name = 'MyInvoisError';
}

export interface AddressModel {
  /** `cac:AddressLine/cbc:Line`, in order. */
  lines: string[];
  city: string | null;
  postalCode: string | null;
  /** `cbc:CountrySubentityCode`: a code of the list, or a foreign region as given. */
  state: string | null;
  /** ISO 3166-1 alpha-3, or null where the books hold none or one with no alpha-3 in LHDNM's list. */
  country: string | null;
}

export interface PartyModel {
  /** Supplier or buyer of the document — which is not always the side of the books it came from. */
  role: 'supplier' | 'buyer';
  name: string | null;
  tin: string | null;
  registration: { scheme: RegistrationScheme; id: string } | null;
  sst: string | null;
  /** Written for the supplier only. */
  tourismTax: string | null;
  /** Written for the supplier only. */
  activity: { msic: string; description: string } | null;
  address: AddressModel;
  phone: string | null;
  email: string | null;
}

export interface LineTaxModel {
  /** `cac:TaxCategory/cbc:ID`, LHDNM's tax type. */
  type: string | null;
  rate: Decimal | null;
  base: Decimal;
  amount: Decimal | null;
  reason: string | null;
}

export interface LineModel {
  id: string;
  quantity: Decimal | null;
  unitCode: string | null;
  /** `cac:Price/cbc:PriceAmount`: the price without its tax. */
  price: Decimal | null;
  /** `cac:ItemPriceExtension/cbc:Amount`: price times quantity, before the discount. */
  subtotal: Decimal | null;
  /** `cac:AllowanceCharge`: the discount, as a rate (0.15) and as the amount between subtotal and net. */
  discount: { rate: Decimal; amount: Decimal } | null;
  net: Decimal;
  description: string | null;
  classifications: string[];
  tax: LineTaxModel;
}

export interface TaxGroupModel {
  type: string | null;
  base: Decimal;
  tax: Decimal;
  reason: string | null;
}

export interface DocumentModel {
  typeCode: string;
  kind: DocumentKind;
  selfBilled: boolean;
  version: '1.0' | '1.1';
  number: string;
  issueDate: string;
  issueTime: string;
  currency: string;
  exchangeRate: Decimal | null;
  billReference: string | null;
  adjusts: AdjustedDocument[];
  supplier: PartyModel;
  buyer: PartyModel;
  paymentMode: string | null;
  account: string | null;
  paymentTerms: string | null;
  taxTotal: Decimal;
  groups: TaxGroupModel[];
  taxExclusive: Decimal;
  taxInclusive: Decimal;
  lines: LineModel[];
}

/** MyInvois's own currency: every other one needs an exchange rate to it. */
export const RINGGIT = 'MYR';

/** The code of a document, by kind, for a supplier's document and for a self-billed one. */
const TYPE_CODES: Record<DocumentKind, [string, string]> = {
  invoice: ['01', '11'],
  'credit-note': ['02', '12'],
  'debit-note': ['03', '13'],
  'refund-note': ['04', '14'],
};

/** Which kinds each type of the books can be. */
const KINDS: Record<string, { selfBilled: boolean; kinds: DocumentKind[] }> = {
  sale_invoice: { selfBilled: false, kinds: ['invoice', 'debit-note'] },
  sale_credit_note: { selfBilled: false, kinds: ['credit-note', 'refund-note'] },
  purchase_invoice: { selfBilled: true, kinds: ['invoice', 'debit-note'] },
  purchase_credit_note: { selfBilled: true, kinds: ['credit-note', 'refund-note'] },
};

const INSTANT = /^(\d{4}-\d{2}-\d{2})T(\d{2}):(\d{2}):(\d{2})(?:\.\d+)?(Z|[+-]\d{2}:\d{2})$/;

/** A value with something in it, or null. Blank text is the absence of text. */
function text(value: unknown): string | null {
  if (value === null || value === undefined) return null;
  const trimmed = String(value).trim();
  return trimmed === '' ? null : trimmed;
}

function amount(value: unknown, what: string): Decimal {
  const parsed = parseDecimal(value as string | number | null | undefined);
  if (parsed === null) throw new MyInvoisError(`${what} is not an amount: ${String(value)}`);
  return parsed;
}

function optionalAmount(value: unknown, what: string): Decimal | null {
  if (value === null || value === undefined || value === '') return null;
  return amount(value, what);
}

/** `cbc:IssueDate` and `cbc:IssueTime`, in UTC, from a moment with its offset. */
function utc(issuedAt: string): { date: string; time: string } {
  const match = INSTANT.exec(String(issuedAt ?? '').trim());
  const instant = match ? new Date(String(issuedAt).trim()) : null;
  if (instant === null || Number.isNaN(instant.getTime())) {
    throw new MyInvoisError(`the moment of issuance is not ISO 8601 with an offset: ${String(issuedAt)}`);
  }
  // 30 February has the shape of a date and is read by JavaScript as 2 March.
  const day = new Date(`${(match as RegExpExecArray)[1]}T00:00:00Z`);
  if (Number.isNaN(day.getTime()) || day.toISOString().slice(0, 10) !== (match as RegExpExecArray)[1]) {
    throw new MyInvoisError(`the moment of issuance is not a day of the calendar: ${String(issuedAt)}`);
  }
  const iso = instant.toISOString();
  return { date: iso.slice(0, 10), time: `${iso.slice(11, 19)}Z` };
}

/**
 * A state code from what the books hold: a code of the list as it is, a name
 * of the list read back as its code, a foreign region as it is. `17` (Not
 * Applicable) is the SDK's own value for an address outside Malaysia that
 * names no state.
 */
function stateOf(region: string | null, country: string | null, given: string | null): string | null {
  if (given !== null) return given;
  if (region !== null) {
    if (STATE_CODES[region] !== undefined) return region;
    const named = Object.entries(STATE_CODES).find(([, name]) => name.toLowerCase() === region.toLowerCase());
    if (named !== undefined) return named[0];
    return country === 'MYS' ? null : region;
  }
  return country !== null && country !== 'MYS' ? '17' : null;
}

function partyOf(
  header: DocumentHeaderRow,
  side: 'seller' | 'buyer',
  role: 'supplier' | 'buyer',
  given: PartyIdentifiers & { activity?: { msic: string; description: string } | null },
  violations: Violation[],
): PartyModel {
  const field = (name: string): string | null => text((header as unknown as Record<string, unknown>)[`${side}_${name}`]);
  const alpha2 = field('country')?.toUpperCase() ?? null;
  const country = alpha2 === null ? null : (ALPHA3[alpha2] ?? null);
  if (alpha2 !== null && country === null) {
    violations.push({
      code: `input:${role}_country`,
      message: `The ${role}'s country is ${alpha2}, and no three-letter code of LHDNM's list of countries is known for it: the address carries no country.`,
    });
  }
  const registrationNumber = field('registration_number');
  const registration =
    given.registration !== null && given.registration !== undefined
      ? { scheme: given.registration.scheme, id: given.registration.id.trim() }
      : registrationNumber === null
        ? null
        : { scheme: 'BRN' as const, id: registrationNumber };
  const lines = [field('address_line1'), field('address_line2')].filter((line): line is string => line !== null);
  return {
    role,
    name: field('legal_name') ?? field('name'),
    tin: text(given.tin),
    registration,
    sst: text(given.sst) ?? (role === 'buyer' ? 'NA' : null),
    tourismTax: role === 'supplier' ? text(given.tourismTax) : null,
    activity:
      role === 'supplier' && given.activity
        ? { msic: String(given.activity.msic).trim(), description: String(given.activity.description).trim() }
        : null,
    address: {
      lines,
      city: field('city'),
      postalCode: field('postal_code'),
      state: stateOf(field('region'), country, text(given.state)),
      country,
    },
    phone: text(given.phone) ?? field('phone'),
    email: field('email'),
  };
}

/** The tax row a line was booked under: by its code, else the one row of its category and rate. */
function rowOf(line: DocumentLineRow, taxes: readonly DocumentTaxRow[]): DocumentTaxRow | null {
  const code = text(line.tax_code);
  if (code !== null) return taxes.find((row) => text(row.tax_code) === code) ?? null;
  const category = text(line.vat_category)?.toUpperCase() ?? null;
  const rate = optionalAmount(line.vat_rate, 'a tax rate');
  const found = taxes.filter((row) => {
    const rowRate = optionalAmount(row.tax_rate, 'a tax rate of the breakdown');
    return (
      (text(row.vat_category)?.toUpperCase() ?? null) === category &&
      (rate === null ? rowRate === null : rowRate !== null && equal(rate, rowRate))
    );
  });
  return found.length === 1 ? (found[0] as DocumentTaxRow) : null;
}

function classifications(value: unknown): string[] {
  if (value === null || value === undefined) return [];
  const all = Array.isArray(value) ? value : String(value).split(',');
  return all.map((each) => String(each).trim()).filter((each) => each !== '');
}

/** One hundredth of a percentage: 15 % is the factor 0.15. */
const percentOf = (rate: Decimal): Decimal => ({ units: rate.units, scale: rate.scale + 2 });

/**
 * The tax of each line. The books round the tax of a group of lines once, so
 * the tax of one line is a figure they hold only where the line is alone in
 * its group, or where the row says it. Otherwise it is base times rate, and
 * written only where that is exact to the cent for every line of the group and
 * adds up to what was posted: a figure that needs rounding is a rounding the
 * books have not made.
 */
function lineTaxes(lines: readonly DocumentLineRow[], rows: (DocumentTaxRow | null)[], nets: Decimal[]): (Decimal | null)[] {
  const out: (Decimal | null)[] = lines.map((line, index) =>
    optionalAmount(line.tax_amount, `the tax of line ${index + 1}`),
  );
  const groups = new Map<DocumentTaxRow, number[]>();
  rows.forEach((row, index) => {
    if (row !== null && out[index] === null) groups.set(row, [...(groups.get(row) ?? []), index]);
  });
  for (const [row, members] of groups) {
    const charged = amount(row.tax_charged, 'a tax of the breakdown');
    const alone = rows.filter((each) => each === row).length === 1;
    if (alone && members.length === 1) {
      out[members[0] as number] = charged;
      continue;
    }
    const rate = optionalAmount(row.tax_rate, 'a tax rate of the breakdown') ?? ZERO;
    const exact = members.map((index) => multiply(nets[index] as Decimal, percentOf(rate)));
    const given = rows
      .map((each, index) => (each === row && !members.includes(index) ? out[index] : null))
      .filter((each): each is Decimal => each !== null);
    if (exact.every((each) => significantScale(each) <= 2) && equal(sum([...exact, ...given]), charged)) {
      members.forEach((index, at) => (out[index] = exact[at] as Decimal));
    }
  }
  return out;
}

export function buildModel(input: MyInvoisInput): { model: DocumentModel; violations: Violation[] } {
  if (!input || !input.header) throw new MyInvoisError('no document was given');
  const header = input.header as unknown as DocumentHeaderRow;
  const violations: Violation[] = [];

  const allowed = KINDS[String(header.doc_type)];
  if (allowed === undefined) {
    throw new MyInvoisError(
      `a ${String(header.doc_type)} is not a document MyInvois carries: a sale invoice or credit note is the supplier's, a purchase invoice or credit note is self-billed, and nothing else is either`,
    );
  }
  const kind = input.kind ?? (allowed.kinds[0] as DocumentKind);
  if (!allowed.kinds.includes(kind)) {
    throw new MyInvoisError(`a ${String(header.doc_type)} cannot be written as a ${kind}: it is one of ${allowed.kinds.join(', ')}`);
  }
  if (input.version !== '1.0' && input.version !== '1.1') {
    throw new MyInvoisError(`the version of the document is 1.0 or 1.1, never ${String(input.version)}`);
  }
  const number = text(header.number);
  if (number === null) throw new MyInvoisError('the document has no number: it was never issued');
  const currency = text(header.currency_code)?.toUpperCase() ?? null;
  if (currency === null) throw new MyInvoisError('the document has no currency, and there is no default');
  const issued = utc(input.issuedAt);

  // The two sides of the books, and which is which in the document.
  const selfBilled = allowed.selfBilled;
  const supplier = partyOf(header, selfBilled ? 'buyer' : 'seller', 'supplier', input.supplier ?? {}, violations);
  const buyer = partyOf(header, selfBilled ? 'seller' : 'buyer', 'buyer', input.buyer ?? {}, violations);

  const rows = (input.taxes ?? []) as unknown as DocumentTaxRow[];
  const products = ((input.lines ?? []) as unknown as DocumentLineRow[]).filter(
    (row) => (text(row.line_type) ?? 'product') === 'product',
  );
  if (products.length === 0) throw new MyInvoisError('the document has no line');

  const nets = products.map((row, index) => amount(row.amount_untaxed, `the net amount of line ${index + 1}`));
  const lineRows = products.map((row) => rowOf(row, rows));
  const taxes = lineTaxes(products, lineRows, nets);

  const lines: LineModel[] = products.map((row, index) => {
    const id = text(row.sequence) ?? String(index + 1);
    const taxRow = lineRows[index] ?? null;
    const net = nets[index] as Decimal;
    const quantity = optionalAmount(row.quantity, `the quantity of line ${id}`);
    let price: Decimal | null;
    if (row.unit_price_includes_tax === true) {
      price = optionalAmount(row.net_unit_price, `the net unit price of line ${id}`);
      if (price === null) {
        violations.push({
          code: 'input:net_unit_price',
          line: id,
          message:
            'The price of this line was keyed with its tax in it, and the books publish no price without it: working one out is a rounding the books have not made.',
        });
      }
    } else {
      price = optionalAmount(row.unit_price, `the unit price of line ${id}`);
    }
    const subtotal = price !== null && quantity !== null ? multiply(price, quantity) : null;
    const discountRate = optionalAmount(row.discount_percent, `the discount of line ${id}`);
    const discount =
      discountRate !== null && !isZero(discountRate) && subtotal !== null
        ? { rate: percentOf(discountRate), amount: subtract(subtotal, net) }
        : null;

    const type = text(row.myinvois_tax_type) ?? text(taxRow?.myinvois_tax_type);
    if (type === null) {
      violations.push({
        code: 'input:tax_type',
        line: id,
        message:
          taxRow === null
            ? 'The line names no tax of the breakdown and carries no LHDNM tax type: which tax it was booked under cannot be told.'
            : `The tax ${text(taxRow.tax_code) ?? 'of this line'} carries no LHDNM tax type (myinvois_tax_type), and nothing in the books decides one.`,
      });
    }
    if (taxes[index] === null) {
      violations.push({
        code: 'input:line_tax_amount',
        line: id,
        message:
          'The books hold the tax of the group this line shares with others, rounded once, and not the tax of the line: base times rate is not exact to the cent here, and splitting the posted tax is a rounding the books have not made.',
      });
    }
    const classes = classifications(row.myinvois_classification);
    if (classes.length === 0) {
      violations.push({
        code: 'input:classification',
        line: id,
        message:
          'The line carries no classification code of LHDNM (myinvois_classification): what was sold is a fact the books do not record by that list.',
      });
    }
    return {
      id,
      quantity,
      unitCode: text(row.unit_code),
      price,
      subtotal,
      discount,
      net,
      description: text(row.item_name) ?? text(row.item_description),
      classifications: classes,
      tax: {
        type,
        rate: optionalAmount(row.vat_rate, `the tax rate of line ${id}`) ?? optionalAmount(taxRow?.tax_rate, 'a tax rate'),
        base: net,
        amount: taxes[index] ?? null,
        reason: text(taxRow?.exemption_reason),
      },
    };
  });

  // The breakdown, per tax type: each row of the books, added to the others of its type.
  const groups = new Map<string | null, TaxGroupModel & { reasons: Set<string> }>();
  for (const row of rows) {
    const types = new Set(
      lines.filter((_, index) => lineRows[index] === row).map((line) => line.tax.type).filter((each) => each !== null),
    );
    const type = text(row.myinvois_tax_type) ?? (types.size === 1 ? ([...types][0] as string) : null);
    // A row whose lines carry no type is reported on each of them, above.
    if (type === null && (types.size > 1 || !lineRows.includes(row))) {
      violations.push({
        code: 'input:tax_type',
        message: `The tax ${text(row.tax_code) ?? 'of the breakdown'} carries no LHDNM tax type (myinvois_tax_type), and ${types.size > 1 ? `its lines say ${[...types].sort().join(' and ')}` : 'no line says one'}.`,
      });
    }
    const group = groups.get(type) ?? { type, base: ZERO, tax: ZERO, reason: null, reasons: new Set<string>() };
    group.base = add(group.base, amount(row.base_amount, 'a base of the breakdown'));
    group.tax = add(group.tax, amount(row.tax_charged, 'a tax of the breakdown'));
    const reason = text(row.exemption_reason);
    if (reason !== null) group.reasons.add(reason);
    groups.set(type, group);
  }

  const rate = optionalAmount(input.exchangeRate, 'the exchange rate');
  if (currency !== RINGGIT && rate === null) {
    violations.push({
      code: 'input:exchange_rate',
      message: `The document is in ${currency}, and MyInvois asks for the rate at which it converts into ringgit (cac:TaxExchangeRate); the books publish none for it.`,
    });
  }

  const account = text(header.payee_iban);
  const paymentMode = text(input.paymentMode);
  if (account !== null && paymentMode === null) {
    violations.push({
      code: 'input:payment_mode',
      message:
        "The books hold an account to pay into and no payment mode of LHDNM's list: cac:PaymentMeans needs its code, so the account is not written.",
    });
  }

  const adjusts = (input.adjusts ?? []).map((each) => ({ number: String(each.number).trim(), uuid: String(each.uuid).trim() }));
  if (kind !== 'invoice' && adjusts.length === 0) {
    violations.push({
      code: 'input:adjusts',
      message: `A ${selfBilled ? 'self-billed ' : ''}${kind.replace('-', ' ')} names the document it adjusts by its number and the Unique Identifier Number LHDNM gave it (cac:BillingReference/cac:InvoiceDocumentReference); none was given.`,
    });
  }

  return {
    model: {
      typeCode: (TYPE_CODES[kind] as [string, string])[selfBilled ? 1 : 0],
      kind,
      selfBilled,
      version: input.version,
      number,
      issueDate: issued.date,
      issueTime: issued.time,
      currency,
      exchangeRate: currency === RINGGIT ? null : rate,
      billReference: text(header.payment_reference),
      adjusts,
      supplier,
      buyer,
      paymentMode,
      account: paymentMode === null ? null : account,
      paymentTerms: text(header.payment_terms),
      taxTotal: amount(header.amount_tax, 'the total tax'),
      groups: [...groups.values()].map(({ reasons, ...group }) => ({
        ...group,
        // Several reasons for one tax type are several sentences, and a
        // sentence can be joined to another.
        reason: reasons.size > 0 ? [...reasons].join(' ') : null,
      })),
      taxExclusive: amount(header.amount_untaxed, 'the total excluding tax'),
      taxInclusive: amount(header.amount_total, 'the total including tax'),
      lines,
    },
    violations,
  };
}
