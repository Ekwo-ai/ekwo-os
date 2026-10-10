import type { InvoiceLabels } from './types.js';

/**
 * The words of the layout in English, the one language this package carries.
 *
 * Another language is the caller's to pass, through `options.labels`: the
 * books know the language of a document, and the words for "Invoice" in it
 * are not this package's to hold. A country's own wording — which tax is
 * called what, what the law wants printed — is not here either: it arrives in
 * the rows, as the name of a tax and as legal mentions.
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

/** The English set with the caller's words over it; `units` are merged too. */
export function labelsWith(given: Partial<InvoiceLabels> | undefined): InvoiceLabels {
  if (given === undefined) return ENGLISH_LABELS;
  return { ...ENGLISH_LABELS, ...given, units: { ...ENGLISH_LABELS.units, ...(given.units ?? {}) } };
}
