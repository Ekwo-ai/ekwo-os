/**
 * The purchase a received invoice becomes, before anybody's books are read.
 *
 * Whichever way the invoice was read — a Factur-X file, a UBL message, a
 * photograph read by a model — it is one `ReceivedInvoice`, and this file
 * turns it into the draft of a purchase document in the columns of Ekwo OS
 * (`documents`, `document_lines`): the fields a caller passes to
 * `create_document` once it has chosen, in its own books, the supplier, the
 * account and the tax. Those three choices need the books and the country
 * pack, so they are not made here; the draft carries what they are made
 * from — the supplier as the invoice names it, and each line's VAT category
 * and rate.
 *
 * What the core has a column for goes in that column: the unit code of a
 * line, the supplier's invoice number, the references, the due date, the
 * tax point. What it has none for and EN 16931 carries on a line — the period
 * a line bills (BG-26) — goes in the line's `attributes`, which hold "what an
 * electronic invoice format asks of this line that no other column says".
 * The period of the whole invoice (BG-14) has no column on a document: each
 * line that states no period of its own takes it, which is what EN 16931
 * means by it, and the draft returns it as well for whoever keeps it beside
 * the document.
 *
 * Nothing is defaulted: no currency, no date, no name. Where the invoice is
 * silent the draft is silent, and the caller asks, or fills in its own.
 */

import type { DecimalText, ReceivedAllowanceCharge, ReceivedInvoice, ReceivedLine } from '@ekwo-ai/factur-x';

/** A period as EN 16931 carries it: either end may be unknown. */
export interface Period {
  start: string | null;
  end: string | null;
}

/**
 * The names under which a line's `attributes` carry what no column of
 * `document_lines` holds. The period is BT-134 and BT-135; the three
 * `invoiced_*` keep the invoice's own quantity, unit and price where the
 * line had to be written as one unit at its amount (see `PurchaseDraftLine`).
 */
export const LINE_ATTRIBUTES = {
  periodStart: 'period_start',
  periodEnd: 'period_end',
  invoicedQuantity: 'invoiced_quantity',
  invoicedUnitCode: 'invoiced_unit_code',
  invoicedNetPrice: 'invoiced_net_price',
} as const;

/** One line of the draft, in the fields of `document_lines` (`LineArgs` of `@ekwo-ai/core`). */
export interface PurchaseDraftLine {
  /** BT-153, else BT-154, else BT-127; null where the invoice names nothing, for the caller to name. */
  name: string | null;
  /** BT-154, where it is beside a name. */
  description: string | null;
  /**
   * The invoice's quantity, unit code and net price where they make the
   * line's amount at the decimals of its currency, as `document_lines`
   * computes `amount_untaxed`; otherwise one unit (`C62`) at the line's
   * amount, the invoice's own figures kept in `attributes`.
   */
  quantity: DecimalText;
  unit_code: string;
  unit_price: DecimalText;
  /** BT-151 and BT-152, from which the caller chooses the tax of its own pack. */
  vat_category: string | null;
  vat_rate: DecimalText | null;
  /** What `document_lines.attributes` keeps that no column holds; see `LINE_ATTRIBUTES`. */
  attributes: Record<string, string>;
}

/** The draft of a purchase document, in the fields of `documents`. */
export interface PurchaseDraft {
  doc_type: 'purchase_invoice' | 'purchase_credit_note';
  /** BT-2; null where it was not read. */
  document_date: string | null;
  /** BT-9. */
  due_date: string | null;
  /** BT-7. */
  tax_point_date: string | null;
  /** BT-1: the supplier's own number. */
  supplier_reference: string | null;
  /** BT-5, as the invoice says it; null where it was not read, never the company's. */
  currency_code: string | null;
  buyer_reference: string | null;
  order_reference: string | null;
  contract_reference: string | null;
  project_reference: string | null;
  delivery_date: string | null;
  payment_terms: string | null;
  payment_reference: string | null;
  /** BT-84 where it is an IBAN. */
  payee_iban: string | null;
  /** BG-14. No column of `documents` holds it: it is on each line without a period of its own, and here. */
  invoicing_period: Period | null;
  /** The supplier as the invoice names it, for the caller to find among its contacts or to add. */
  supplier: {
    name: string | null;
    trade_name: string | null;
    vat_id: string | null;
    legal_id: string | null;
    country: string | null;
  };
  /** BT-112 and BT-115, as the invoice says them. */
  total: DecimalText | null;
  payable: DecimalText | null;
  /** One per line of the invoice, then one per allowance or charge of the whole document. */
  lines: PurchaseDraftLine[];
}

const nonEmpty = (value: string | null | undefined): string | null =>
  value === null || value === undefined || value.trim().length === 0 ? null : value;

/** The decimals a currency is written with, as the platform's `Intl` knows it; null for a code it does not know. */
export function currencyDigits(currency: string): number | null {
  try {
    return new Intl.NumberFormat('en', { style: 'currency', currency }).resolvedOptions().maximumFractionDigits ?? null;
  } catch {
    return null;
  }
}

/** A decimal as an integer and a scale: `-12.50` is `{ units: -1250n, scale: 2 }`. */
function decimal(text: string): { units: bigint; scale: number } | null {
  const match = /^(-?)(\d+)(?:\.(\d+))?$/.exec(text.trim());
  if (match === null) return null;
  const fraction = match[3] ?? '';
  const units = BigInt(`${match[2]}${fraction}`);
  return { units: match[1] === '-' ? -units : units, scale: fraction.length };
}

/**
 * Whether `quantity × price`, rounded half up on its absolute value at
 * `digits` decimals — the rounding of `document_lines.amount_untaxed` — is
 * `amount`.
 */
export function makesAmount(quantity: string, price: string, amount: string, digits: number): boolean {
  const q = decimal(quantity);
  const p = decimal(price);
  const a = decimal(amount);
  if (q === null || p === null || a === null) return false;
  const product = q.units * p.units;
  const scale = q.scale + p.scale;
  const negative = product < 0n;
  const magnitude = negative ? -product : product;
  let rounded: bigint;
  if (scale <= digits) {
    rounded = magnitude * 10n ** BigInt(digits - scale);
  } else {
    const divisor = 10n ** BigInt(scale - digits);
    rounded = magnitude / divisor + ((magnitude % divisor) * 2n >= divisor ? 1n : 0n);
  }
  const signed = negative ? -rounded : rounded;
  // The amount may be written with more decimals than the currency has, as long as they are zeros.
  return a.scale <= digits ? signed === a.units * 10n ** BigInt(digits - a.scale) : signed * 10n ** BigInt(a.scale - digits) === a.units;
}

function periodAttributes(period: Period | null): Record<string, string> {
  const out: Record<string, string> = {};
  if (period?.start) out[LINE_ATTRIBUTES.periodStart] = period.start;
  if (period?.end) out[LINE_ATTRIBUTES.periodEnd] = period.end;
  return out;
}

function lineOf(line: ReceivedLine, digits: number, invoicing: Period | null): PurchaseDraftLine {
  const name = nonEmpty(line.name) ?? nonEmpty(line.description) ?? nonEmpty(line.note);
  const perUnit = line.priceBaseQuantity === null || /^0*1(\.0*)?$/.test(line.priceBaseQuantity);
  const exact =
    line.quantity !== null &&
    line.netPrice !== null &&
    perUnit &&
    line.netAmount.length > 0 &&
    makesAmount(line.quantity, line.netPrice, line.netAmount, digits);
  const attributes = periodAttributes(line.period ?? invoicing);
  if (!exact) {
    if (line.quantity !== null) attributes[LINE_ATTRIBUTES.invoicedQuantity] = line.quantity;
    if (line.unitCode !== null) attributes[LINE_ATTRIBUTES.invoicedUnitCode] = line.unitCode;
    if (line.netPrice !== null) attributes[LINE_ATTRIBUTES.invoicedNetPrice] = line.netPrice;
  }
  return {
    name,
    description: name === nonEmpty(line.name) ? nonEmpty(line.description) : null,
    quantity: exact ? (line.quantity as string) : '1',
    unit_code: exact ? (line.unitCode ?? 'C62') : 'C62',
    unit_price: exact ? (line.netPrice as string) : line.netAmount,
    vat_category: line.vatCategory,
    vat_rate: line.vatRate,
    attributes,
  };
}

function adjustmentOf(one: ReceivedAllowanceCharge, invoicing: Period | null): PurchaseDraftLine {
  return {
    name: nonEmpty(one.reason) ?? nonEmpty(one.reasonCode),
    description: null,
    quantity: '1',
    unit_code: 'C62',
    unit_price: one.charge ? one.amount : one.amount.startsWith('-') ? one.amount.slice(1) : `-${one.amount}`,
    vat_category: one.vatCategory,
    vat_rate: one.vatRate,
    attributes: periodAttributes(invoicing),
  };
}

/**
 * The draft of the purchase a received invoice becomes.
 *
 * One line per line of the invoice, its amount net of the line's own
 * allowances; then one line per allowance (negative) or charge of the whole
 * document. A credit note is a purchase credit note, its figures positive as
 * the invoice writes them. Where the currency was not read, amounts are
 * compared at the decimals the invoice wrote them with.
 */
export function purchaseDraftOf(invoice: ReceivedInvoice): PurchaseDraft {
  const currency = nonEmpty(invoice.currency);
  const invoicing =
    invoice.invoicingPeriod === null || (invoice.invoicingPeriod.start === null && invoice.invoicingPeriod.end === null)
      ? null
      : invoice.invoicingPeriod;
  const lines = invoice.lines.map((line) => {
    const written = decimal(line.netAmount)?.scale ?? 2;
    const digits = currency === null ? written : (currencyDigits(currency) ?? written);
    return lineOf(line, digits, invoicing);
  });
  lines.push(...invoice.allowances.map((one) => adjustmentOf(one, invoicing)));
  const means = invoice.paymentMeans.find((one) => one.reference !== null || one.account !== null);
  const iban = invoice.paymentMeans.map((one) => one.account).find((account) => account?.kind === 'iban');
  return {
    doc_type: invoice.kind === 'credit_note' ? 'purchase_credit_note' : 'purchase_invoice',
    document_date: nonEmpty(invoice.issueDate),
    due_date: invoice.dueDate,
    tax_point_date: invoice.taxPointDate,
    supplier_reference: nonEmpty(invoice.number),
    currency_code: currency,
    buyer_reference: invoice.buyerReference,
    order_reference: invoice.orderReference,
    contract_reference: invoice.contractReference,
    project_reference: invoice.projectReference,
    delivery_date: invoice.deliveryDate,
    payment_terms: invoice.paymentTerms,
    payment_reference: means?.reference ?? null,
    payee_iban: iban?.value ?? null,
    invoicing_period: invoicing,
    supplier: {
      name: invoice.seller.name,
      trade_name: invoice.seller.tradeName,
      vat_id: invoice.seller.vatId,
      legal_id: invoice.seller.legalId?.value ?? null,
      country: invoice.seller.address?.country ?? null,
    },
    total: nonEmpty(invoice.totals.taxInclusive),
    payable: nonEmpty(invoice.totals.payable),
    lines,
  };
}
