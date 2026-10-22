/**
 * The model path: a photograph or a plain PDF, read by a vision model.
 *
 * This package calls no model. It publishes what a caller sends to one — the
 * JSON schema the answer is held to (`readingSchema()`) and the words that go
 * with it (`readingPrompt()`) — and checks what comes back (`readingOf()`)
 * into the `ReceivedInvoice` the exact readers return, so that whatever turns
 * an invoice into a purchase does it once for a Factur-X file and for a
 * photograph of a till receipt. The call, its key, its timeout and what it
 * costs stay with the product that makes it.
 *
 * The model copies; it never computes. Every figure is the text the page
 * prints, every code one the page prints or that names, in a published list,
 * a word the page prints. A field the page does not print is left empty, and
 * `readingOf()` keeps it empty: `null` where `ReceivedInvoice` allows it,
 * `''` where EN 16931 requires a value, named then in `missing`. Nothing is
 * defaulted — not the currency, not the date, not a quantity of one.
 *
 * A caller may ask for more than an invoice: an energy layer asks for the
 * meter, the bands and the contract type. It hands an `extension` — its own
 * properties, in JSON schema — and gets them back, untouched, beside the
 * invoice. The same call reads both.
 */

import {
  checkReceived,
  isValidIban,
  toUnitCode,
  type DecimalText,
  type ReceivedAddress,
  type ReceivedInvoice,
  type ReceivedLine,
  type ReceivedParty,
  type ReceivedPaymentMeans,
  type ReceivedTax,
  type ReceivedViolation,
} from '@ekwo-ai/factur-x';

/** Changed with every change of the schema or of the words below; a product writes it in the log of every reading. */
export const READING_VERSION = '2026-10-22';

/** How sure the model is of what it copied into a field. */
export type Confidence = 'high' | 'medium' | 'low';

export const CONFIDENCES: readonly Confidence[] = ['high', 'medium', 'low'];

/** What the model says the page is. `other` is anything that is not a purchase document, and is read as nothing. */
export type DocumentKind = 'invoice' | 'credit_note' | 'receipt' | 'other';

/**
 * The fields of the document the model rates its confidence in, one by one.
 * A line rates itself (`lines[n]`).
 */
export const CONFIDENCE_FIELDS = [
  'document',
  'number',
  'issue_date',
  'due_date',
  'currency',
  'seller',
  'seller_vat_id',
  'seller_legal_id',
  'buyer',
  'invoicing_period',
  'taxes',
  'totals',
  'payment',
] as const;

export type ConfidenceField = (typeof CONFIDENCE_FIELDS)[number];

/**
 * The categories of VAT EN 16931 names (UNTDID 5305, the subset of BT-118):
 * standard, zero, exempt, reverse charge, intra-Community, export, outside the
 * scope, and the two of the Canary Islands, Ceuta and Melilla.
 */
export const VAT_CATEGORIES: readonly string[] = ['S', 'Z', 'E', 'AE', 'K', 'G', 'O', 'L', 'M'];

/**
 * What a caller adds to the schema: its own properties, read in the same call
 * and returned untouched in `ModelReading.extension`.
 */
export interface ReadingExtension {
  /** JSON schema of each property, as the model's structured output takes it. */
  properties: Record<string, Record<string, unknown>>;
  /** Defaults to every property: a structured output wants each one answered, empty where not printed. */
  required?: string[];
  /** Said to the model after the words of this package: what the properties are and where they are printed. */
  instructions?: string;
}

// ---------------------------------------------------------------------------
// The schema
// ---------------------------------------------------------------------------

const TEXT = (description: string) => ({ type: 'string', description }) as const;
const DECIMAL = (description: string) =>
  TEXT(`${description} Digits, a dot for the decimals, a leading minus where printed; no grouping, no currency sign. Empty if not printed.`);
const DAY = (description: string) => TEXT(`${description} YYYY-MM-DD, or empty if not printed.`);

function object(properties: Record<string, unknown>, description?: string): Record<string, unknown> {
  return {
    type: 'object',
    ...(description === undefined ? {} : { description }),
    additionalProperties: false,
    required: Object.keys(properties),
    properties,
  };
}

const CONFIDENCE = { type: 'string', enum: CONFIDENCES } as const;

const PERIOD = (what: string) =>
  object(
    { start: DAY(`First day of ${what}.`), end: DAY(`Last day of ${what}.`) },
    `${what[0]?.toUpperCase()}${what.slice(1)}, as printed; both empty when none is printed.`,
  );

const ADDRESS = object(
  {
    lines: { type: 'array', items: { type: 'string' }, description: 'The street lines, as printed, in order.' },
    city: TEXT('As printed, or empty.'),
    postal_code: TEXT('As printed, or empty.'),
    country: TEXT('ISO 3166-1 alpha-2 code of the country printed in the address, or empty.'),
  },
  'The postal address, as printed.',
);

const PARTY = (who: string) =>
  object(
    {
      name: TEXT(`The legal name of ${who}, as printed.`),
      trade_name: TEXT(`The name ${who} trades under, where printed beside the legal name; otherwise empty.`),
      vat_id: TEXT(`The VAT identifier of ${who}, as printed, its country prefix included; empty if none is printed.`),
      legal_id: TEXT(`The company registration number of ${who}, as printed; empty if none is printed.`),
      tax_registration_id: TEXT(`A tax registration number of ${who} other than the VAT identifier, as printed; otherwise empty.`),
      address: ADDRESS,
    },
    `${who[0]?.toUpperCase()}${who.slice(1)}.`,
  );

const LINE = object({
  name: TEXT('What the line bills, as printed.'),
  description: TEXT('A further description printed on the line, or empty.'),
  quantity: DECIMAL('The quantity, as printed.'),
  unit: TEXT('The unit of the quantity, as printed (kWh, h, pcs…), or empty.'),
  unit_code: TEXT(
    'The UN/ECE Recommendation 20 code of that unit (KWH, HUR, C62…) where the printed unit names exactly one; otherwise empty.',
  ),
  net_price: DECIMAL('The price of one unit before VAT, as printed.'),
  net_amount: DECIMAL('The amount of the line before VAT, as printed.'),
  vat_category: TEXT(
    'The VAT category of the line, an UNTDID 5305 code (S, Z, E, AE, K, G, O, L, M), where the page prints it or prints the words that name it; otherwise empty.',
  ),
  vat_rate: DECIMAL('The VAT rate of the line in percent, as printed.'),
  period: PERIOD('the period this line bills'),
  confidence: { ...CONFIDENCE, description: 'How sure you are of what you copied on this line.' },
});

const TAX = object({
  category: TEXT('The VAT category of the group, an UNTDID 5305 code, where printed or named; otherwise empty.'),
  rate: DECIMAL('The rate in percent.'),
  base: DECIMAL('The amount the tax is computed on, at that rate.'),
  tax: DECIMAL('The tax at that rate.'),
  amount_including_tax: DECIMAL('The amount including tax at that rate, where the page prints it.'),
  exemption_reason: TEXT('The reason printed for a rate of zero or an exemption, or empty.'),
});

/**
 * The JSON schema of the answer, as a structured output takes it: every
 * object closed, every property required and answered — with an empty text,
 * an empty list — where the page does not print it.
 */
export function readingSchema(extension?: ReadingExtension): Record<string, unknown> {
  const properties: Record<string, unknown> = {
    document: {
      type: 'string',
      enum: ['invoice', 'credit_note', 'receipt', 'other'],
      description:
        'invoice: a supplier asks to be paid. credit_note: it gives money back. receipt: what was bought and already paid, a till receipt. other: anything else.',
    },
    number: TEXT('The number of the invoice, credit note or receipt, as printed; empty if none is printed.'),
    issue_date: DAY('The date the document was issued.'),
    due_date: DAY('The date payment is due, where printed.'),
    tax_point_date: DAY('The date the tax falls due, where printed apart from the issue date.'),
    currency: TEXT(
      'The ISO 4217 code of the currency the amounts are in, where the page prints the code, the symbol or the name of one currency only; empty otherwise. Never the currency of a country the page is from.',
    ),
    seller: PARTY('the supplier who issued the document'),
    buyer: PARTY('the customer the document is addressed to'),
    buyer_reference: TEXT('A reference of the customer printed for its own use (customer number, account number), or empty.'),
    order_reference: TEXT('The purchase order the document refers to, as printed, or empty.'),
    contract_reference: TEXT('The contract the document refers to, as printed, or empty.'),
    preceding_invoice: TEXT('On a credit note, the number of the invoice it corrects, as printed; otherwise empty.'),
    invoicing_period: PERIOD('the period the whole document bills'),
    payment: object(
      {
        iban: TEXT('The account to pay to, as printed, spaces removed, or empty.'),
        bic: TEXT('The BIC of that account, as printed, or empty.'),
        reference: TEXT('The reference to quote when paying, as printed, or empty.'),
        terms: TEXT('The terms of payment, as printed, or empty.'),
      },
      'How the supplier asks to be paid.',
    ),
    lines: {
      type: 'array',
      description: 'One entry per line the page prints, in order; empty when it prints none.',
      items: LINE,
    },
    taxes: {
      type: 'array',
      description: 'One entry per VAT rate the page prints in its tax summary, in order; empty when it prints none.',
      items: TAX,
    },
    totals: object(
      {
        line_total: DECIMAL('The sum of the lines, where printed.'),
        tax_exclusive: DECIMAL('The total without VAT.'),
        tax_total: DECIMAL('The total VAT.'),
        tax_inclusive: DECIMAL('The total with VAT.'),
        prepaid: DECIMAL('What was already paid, where printed.'),
        payable: DECIMAL('The amount still to pay.'),
      },
      'The totals the page prints.',
    ),
    confidence: object(
      Object.fromEntries(CONFIDENCE_FIELDS.map((field) => [field, CONFIDENCE])),
      'How sure you are of what you copied into each field: high, medium, low.',
    ),
  };
  if (extension !== undefined) {
    properties['extension'] = {
      type: 'object',
      additionalProperties: false,
      required: extension.required ?? Object.keys(extension.properties),
      properties: extension.properties,
    };
  }
  return object(properties);
}

/** The words that go with the schema. Nothing in them names a country, a currency or a language. */
export const READING_PROMPT = `You read one purchase document for a company's books: an invoice, a credit note or a receipt, as a photograph or a PDF. Answer with what is printed on it, in the JSON format required.

Copy, never compute. Every amount, quantity, price and rate is the one printed, with a dot as the decimal separator, no grouping and no currency sign. Never add, multiply, convert or round a figure, and never fill a total from its parts: a total that is not printed stays empty.

Leave empty rather than guess. A field the page does not print is an empty text or an empty list. The currency is the one the page prints by code, symbol or name; when it prints none, or a symbol several currencies share, leave it empty. A code (a country, a unit, a VAT category) is given only where the page prints it or prints words that name exactly one.

Dates are YYYY-MM-DD. Give one entry in lines per line printed, with its own period where it prints one, and one entry in taxes per rate of the tax summary. For each field of confidence, say how sure you are of what you copied there.

If the page is not a purchase document, answer document "other" and leave every other field empty.`;

/** The words, with the caller's own instructions for its extension after them. */
export function readingPrompt(extension?: ReadingExtension): string {
  const more = extension?.instructions?.trim();
  return more === undefined || more.length === 0
    ? READING_PROMPT
    : `${READING_PROMPT}\n\nThe field extension is asked for by the caller:\n${more}`;
}

// ---------------------------------------------------------------------------
// The answer, checked
// ---------------------------------------------------------------------------

/** What `readingOf()` returns: the invoice, and what the model's answer did not give. */
export interface ModelReading<E = unknown> {
  /** What the model says the page is. A receipt is an invoice already paid. */
  document: Exclude<DocumentKind, 'other'>;
  /** The page as EN 16931 says it, `syntax: 'model'`. */
  invoice: ReceivedInvoice;
  /**
   * The arithmetic of EN 16931 (BR-CO-10 to BR-CO-17) the printed figures
   * break, as the exact readers report it. Checked only where every total,
   * every line amount and every tax group was read: on a partial reading a
   * rule would only measure what is missing.
   */
  violations: ReceivedViolation[];
  /** The fields EN 16931 requires that the page did not print, by their path: `number`, `totals.payable`, `lines[2].net_amount`. Each is `''` in the invoice. */
  missing: string[];
  /** The fields the model filled with something that is not of their shape — a date that is not a day, a rate in words. Each is left empty and its path named here. */
  rejected: string[];
  /** The model's confidence, by field (`CONFIDENCE_FIELDS`) and by line (`lines[n]`); `null` where it said nothing usable. */
  confidence: Record<string, Confidence | null>;
  /** Per group of `invoice.taxes`, in order: the amount including tax the page prints at that rate, which EN 16931 does not carry. */
  taxInclusiveByGroup: (DecimalText | null)[];
  /** The properties of the caller's extension, as the model answered them; `null` where it answered none. Not checked here: the caller checks its own. */
  extension: E | null;
}

const MAX_LINES = 500;
const MAX_TAXES = 20;

type Bag = Record<string, unknown>;

const bag = (value: unknown): Bag => (value !== null && typeof value === 'object' && !Array.isArray(value) ? (value as Bag) : {});
const list = (value: unknown, max: number): Bag[] => (Array.isArray(value) ? value.slice(0, max).map(bag) : []);

/** The checker of one answer: what it rejects is remembered by path. */
class Checker {
  readonly rejected: string[] = [];

  text(value: unknown, max = 300): string | null {
    if (typeof value !== 'string') return null;
    const kept = value.replace(/\s+/g, ' ').trim().slice(0, max);
    return kept.length === 0 ? null : kept;
  }

  /** A decimal as printed: blanks removed, a lone comma read as the decimal separator; anything else rejected. */
  decimal(value: unknown, path: string): DecimalText | null {
    const raw = this.text(value, 40);
    if (raw === null) return null;
    const compact = raw.replace(/[\s  ]/g, '').replace(/^(-?\d+),(\d+)$/, '$1.$2');
    if (/^-?\d{1,15}(\.\d{1,8})?$/.test(compact)) return compact;
    this.rejected.push(path);
    return null;
  }

  day(value: unknown, path: string): string | null {
    const raw = this.text(value, 40);
    if (raw === null) return null;
    if (/^\d{4}-\d{2}-\d{2}$/.test(raw) && new Date(`${raw}T00:00:00Z`).toISOString().startsWith(raw)) return raw;
    this.rejected.push(path);
    return null;
  }

  code(value: unknown, path: string, shape: RegExp): string | null {
    const raw = this.text(value, 40);
    if (raw === null) return null;
    const upper = raw.toUpperCase();
    if (shape.test(upper)) return upper;
    this.rejected.push(path);
    return null;
  }

  category(value: unknown, path: string): string | null {
    const code = this.code(value, path, /^[A-Z]{1,2}$/);
    if (code === null || VAT_CATEGORIES.includes(code)) return code;
    this.rejected.push(path);
    return null;
  }

  period(value: unknown, path: string): { start: string | null; end: string | null } | null {
    const read = bag(value);
    const start = this.day(read['start'], `${path}.start`);
    const end = this.day(read['end'], `${path}.end`);
    return start === null && end === null ? null : { start, end };
  }
}

function addressOf(check: Checker, value: unknown, path: string): ReceivedAddress | null {
  const read = bag(value);
  const lines = (Array.isArray(read['lines']) ? read['lines'] : [])
    .slice(0, 5)
    .map((line) => check.text(line))
    .filter((line): line is string => line !== null);
  const address: ReceivedAddress = {
    lines,
    city: check.text(read['city'], 100),
    postalCode: check.text(read['postal_code'], 20),
    region: null,
    country: check.code(read['country'], `${path}.country`, /^[A-Z]{2}$/),
  };
  return lines.length === 0 && address.city === null && address.postalCode === null && address.country === null ? null : address;
}

function partyOf(check: Checker, value: unknown, path: string): ReceivedParty {
  const read = bag(value);
  const legal = check.text(read['legal_id'], 60);
  return {
    name: check.text(read['name'], 200),
    tradeName: check.text(read['trade_name'], 200),
    identifiers: [],
    legalId: legal === null ? null : { value: legal, scheme: null },
    vatId: check.text(read['vat_id'], 40)?.replace(/[\s.]/g, '') ?? null,
    taxRegistrationId: check.text(read['tax_registration_id'], 60),
    legalForm: null,
    electronicAddress: null,
    address: addressOf(check, read['address'], `${path}.address`),
    contact: null,
  };
}

function confidenceOf(value: unknown): Confidence | null {
  return typeof value === 'string' && (CONFIDENCES as readonly string[]).includes(value) ? (value as Confidence) : null;
}

/**
 * The model's answer, parsed from its JSON, checked into a `ReceivedInvoice`.
 *
 * Anything not of the shape the schema asks for is left empty and named in
 * `rejected`; anything EN 16931 requires and the answer leaves empty is `''`
 * and named in `missing`. Nothing is computed, defaulted or corrected.
 * `undefined` where the answer is not an object, or says the page is not a
 * purchase document.
 */
export function readingOf<E = unknown>(answer: unknown): ModelReading<E> | undefined {
  if (answer === null || typeof answer !== 'object' || Array.isArray(answer)) return undefined;
  const read = answer as Bag;
  const document = read['document'];
  if (document !== 'invoice' && document !== 'credit_note' && document !== 'receipt') return undefined;

  const check = new Checker();
  const missing: string[] = [];
  const required = (value: string | null, path: string): string => {
    if (value !== null) return value;
    missing.push(path);
    return '';
  };

  const lines: ReceivedLine[] = list(read['lines'], MAX_LINES).map((line, index) => {
    const path = `lines[${index}]`;
    const printedUnit = check.text(line['unit'], 20);
    const unitCode =
      check.code(line['unit_code'], `${path}.unit_code`, /^[A-Z0-9]{2,3}$/) ??
      (printedUnit === null ? null : knownUnit(printedUnit));
    return {
      id: String(index + 1),
      note: null,
      quantity: check.decimal(line['quantity'], `${path}.quantity`),
      unitCode,
      netAmount: required(check.decimal(line['net_amount'], `${path}.net_amount`), `${path}.net_amount`),
      orderLineReference: null,
      period: check.period(line['period'], `${path}.period`),
      allowances: [],
      netPrice: check.decimal(line['net_price'], `${path}.net_price`),
      priceDiscount: null,
      grossPrice: null,
      priceBaseQuantity: null,
      priceBaseUnitCode: null,
      vatCategory: check.category(line['vat_category'], `${path}.vat_category`),
      vatRate: check.decimal(line['vat_rate'], `${path}.vat_rate`),
      name: check.text(line['name']),
      description: check.text(line['description'], 1000),
      sellerItemId: null,
      buyerItemId: null,
      standardItemId: null,
    };
  });

  const printedTaxes = list(read['taxes'], MAX_TAXES);
  const taxes: ReceivedTax[] = printedTaxes.map((tax, index) => {
    const path = `taxes[${index}]`;
    return {
      category: check.category(tax['category'], `${path}.category`),
      rate: check.decimal(tax['rate'], `${path}.rate`),
      base: required(check.decimal(tax['base'], `${path}.base`), `${path}.base`),
      tax: required(check.decimal(tax['tax'], `${path}.tax`), `${path}.tax`),
      exemptionReasonCode: null,
      exemptionReason: check.text(tax['exemption_reason']),
    };
  });
  const taxInclusiveByGroup = printedTaxes.map((tax, index) =>
    check.decimal(tax['amount_including_tax'], `taxes[${index}].amount_including_tax`),
  );

  const totals = bag(read['totals']);
  const payment = bag(read['payment']);
  const iban = check.text(payment['iban'], 40)?.replace(/\s/g, '').toUpperCase() ?? null;
  const bic = check.code(payment['bic'], 'payment.bic', /^[A-Z0-9]{8}([A-Z0-9]{3})?$/);
  const paymentReference = check.text(payment['reference'], 140);
  const paymentMeans: ReceivedPaymentMeans[] =
    iban === null && bic === null && paymentReference === null
      ? []
      : [
          {
            code: null,
            text: null,
            reference: paymentReference,
            account: iban === null ? null : isValidIban(iban) ? { kind: 'iban', value: iban } : { kind: 'other', value: iban },
            accountName: null,
            bic,
            cardNumber: null,
            mandateReference: null,
            debitedAccount: null,
          },
        ];
  const preceding = check.text(read['preceding_invoice'], 60);

  const invoice: ReceivedInvoice = {
    syntax: 'model',
    customizationId: null,
    profileId: null,
    kind: document === 'credit_note' ? 'credit_note' : 'invoice',
    typeCode: null,
    number: required(check.text(read['number'], 60), 'number'),
    issueDate: required(check.day(read['issue_date'], 'issue_date'), 'issue_date'),
    dueDate: check.day(read['due_date'], 'due_date'),
    taxPointDate: check.day(read['tax_point_date'], 'tax_point_date'),
    currency: required(check.code(read['currency'], 'currency', /^[A-Z]{3}$/), 'currency'),
    taxCurrency: null,
    buyerReference: check.text(read['buyer_reference'], 100),
    orderReference: check.text(read['order_reference'], 100),
    salesOrderReference: null,
    contractReference: check.text(read['contract_reference'], 100),
    projectReference: null,
    accountingCost: null,
    precedingInvoices: preceding === null ? [] : [{ number: preceding, issueDate: null }],
    notes: [],
    seller: partyOf(check, read['seller'], 'seller'),
    buyer: partyOf(check, read['buyer'], 'buyer'),
    deliveryDate: null,
    deliveryAddress: null,
    invoicingPeriod: check.period(read['invoicing_period'], 'invoicing_period'),
    paymentTerms: check.text(payment['terms'], 500),
    paymentMeans,
    allowances: [],
    taxes,
    totals: {
      lineTotal: check.decimal(totals['line_total'], 'totals.line_total'),
      allowanceTotal: null,
      chargeTotal: null,
      taxExclusive: required(check.decimal(totals['tax_exclusive'], 'totals.tax_exclusive'), 'totals.tax_exclusive'),
      taxTotal: check.decimal(totals['tax_total'], 'totals.tax_total'),
      taxTotalInTaxCurrency: null,
      taxInclusive: required(check.decimal(totals['tax_inclusive'], 'totals.tax_inclusive'), 'totals.tax_inclusive'),
      prepaid: check.decimal(totals['prepaid'], 'totals.prepaid'),
      rounding: null,
      payable: required(check.decimal(totals['payable'], 'totals.payable'), 'totals.payable'),
    },
    lines,
    attachments: [],
  };
  if (invoice.seller.name === null && invoice.seller.tradeName === null) missing.push('seller.name');

  const figures = ['totals.tax_exclusive', 'totals.tax_inclusive', 'totals.payable', 'lines[', 'taxes['];
  const complete = !missing.some((path) => figures.some((figure) => path.startsWith(figure)));

  const said = bag(read['confidence']);
  const confidence: Record<string, Confidence | null> = Object.fromEntries(
    CONFIDENCE_FIELDS.map((field) => [field, confidenceOf(said[field])]),
  );
  list(read['lines'], MAX_LINES).forEach((line, index) => {
    confidence[`lines[${index}]`] = confidenceOf(line['confidence']);
  });

  const extension = read['extension'];
  return {
    document,
    invoice,
    violations: complete ? checkReceived(invoice) : [],
    missing,
    rejected: check.rejected,
    confidence,
    taxInclusiveByGroup,
    extension: extension !== null && typeof extension === 'object' ? (extension as E) : null,
  };
}

/**
 * The UN/ECE code of a printed unit, where the list of words of
 * `@ekwo-ai/factur-x` knows it; null where it does not, rather than the
 * `C62` that list falls back to — and so null for a printed "unit" too,
 * which the model is asked to code itself.
 */
function knownUnit(printed: string): string | null {
  const code = toUnitCode(printed);
  return code === 'C62' ? null : code;
}
