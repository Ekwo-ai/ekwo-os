import { GERMAN_LABELS } from './labels/de.js';
import { SPANISH_LABELS } from './labels/es.js';
import { FRENCH_LABELS } from './labels/fr.js';
import { DUTCH_LABELS } from './labels/nl.js';
import type { InvoiceLabels } from './types.js';

/**
 * The words of the layout in English: the set every other language is
 * checked against, and the one printed where a language has no set.
 *
 * The words of the layout are the same from one country to another, so they
 * are held here once per language, in `labels/<language>.ts`. A country's own
 * wording — the title its law prescribes, which tax is called what, what the
 * law wants printed — is not: it arrives in the rows, as the name of a tax and
 * as legal mentions, or from the caller through `options.labels`.
 */
export const ENGLISH_LABELS: InvoiceLabels = {
  invoice: 'Invoice',
  creditNote: 'Credit note',
  draftInvoice: 'Draft invoice',
  draftCreditNote: 'Draft credit note',
  cancelled: 'Cancelled',
  number: 'Number',
  date: 'Date',
  dueDate: 'Due date',
  deliveryDate: 'Delivery date',
  taxPointDate: 'Tax point',
  buyerReference: 'Your reference',
  orderReference: 'Order',
  contractReference: 'Contract',
  projectReference: 'Project',
  supplierReference: 'Our reference',
  billTo: 'Bill to',
  deliverTo: 'Deliver to',
  vatNumber: 'VAT number',
  registrationNumber: 'Registration number',
  electronicAddress: 'Electronic address',
  email: 'Email',
  phone: 'Phone',
  website: 'Website',
  shareCapital: 'Share capital',
  description: 'Description',
  quantity: 'Quantity',
  unitPrice: 'Unit price',
  discount: 'Discount',
  taxRate: 'Tax rate',
  amount: 'Amount',
  priceIncludesTax: 'Unit price including tax.',
  taxSummary: 'Tax summary',
  taxBase: 'Taxable amount',
  taxCharged: 'Tax',
  totalUntaxed: 'Total excluding tax',
  totalTax: 'Total tax',
  total: 'Total',
  amountPaid: 'Paid',
  amountDue: 'Amount due',
  amountCredited: 'Amount credited',
  payment: 'Payment',
  paymentTerms: 'Terms',
  paymentReference: 'Reference',
  iban: 'IBAN',
  bic: 'BIC',
  note: 'Note',
  page: 'Page {page} of {pages}',
  clearanceVerification: 'Validated by the tax authority',
  clearanceIdentifier: 'Unique identifier',
  clearanceValidatedAt: 'Validated on',
  units: {
    C62: '',
    H87: '',
    EA: '',
    HUR: 'h',
    MIN: 'min',
    DAY: 'days',
    WEE: 'weeks',
    MON: 'months',
    ANN: 'years',
    KGM: 'kg',
    GRM: 'g',
    TNE: 't',
    MTR: 'm',
    KMT: 'km',
    MTK: 'm²',
    MTQ: 'm³',
    LTR: 'l',
    KWH: 'kWh',
    SET: 'sets',
    PR: 'pairs',
  },
};

/** Every set of words this package carries, by language subtag. */
export const INVOICE_LABELS: Readonly<Record<string, InvoiceLabels>> = {
  de: GERMAN_LABELS,
  en: ENGLISH_LABELS,
  es: SPANISH_LABELS,
  fr: FRENCH_LABELS,
  nl: DUTCH_LABELS,
};

/**
 * The entry of `sets` for a BCP 47 tag: the whole tag (`pt-br`), then its
 * language (`fr` for `fr-BE`), or null. Keys are lower-case subtags. The one
 * rule by which a set of words is chosen for a language, here and for the
 * words a country pack names (`country_defaults.invoice_labels`).
 */
export function forLanguage<T>(
  sets: Readonly<Record<string, T>>,
  tag: string | null | undefined,
): { language: string; value: T } | null {
  const whole = (tag ?? '').trim().toLowerCase().replace(/_/g, '-');
  const primary = whole.split('-')[0] ?? '';
  for (const language of [whole, primary]) {
    if (language !== '' && Object.hasOwn(sets, language)) return { language, value: sets[language] as T };
  }
  return null;
}

/**
 * The words of the layout for a BCP 47 tag: the set of the whole tag
 * (`pt-br`), then of its language (`fr` for `fr-BE`), then English.
 * `language` is the set the words come from, so that a caller can say when a
 * document is printed in English for want of a set in its language.
 */
export function labelsFor(tag: string | null | undefined): { language: string; labels: InvoiceLabels } {
  const found = forLanguage(INVOICE_LABELS, tag);
  return found === null ? { language: 'en', labels: ENGLISH_LABELS } : { language: found.language, labels: found.value };
}

/**
 * The set of a language — English by default — with the caller's words over
 * it; `units` are merged too.
 */
export function labelsWith(given: Partial<InvoiceLabels> | undefined, base: InvoiceLabels = ENGLISH_LABELS): InvoiceLabels {
  if (given === undefined) return base;
  return { ...base, ...given, units: { ...base.units, ...(given.units ?? {}) } };
}
