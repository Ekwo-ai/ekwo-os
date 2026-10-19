/**
 * Which brick writes which profile, and how each is fed from the books.
 *
 * A country pack says which e-invoicing profile its companies issue in —
 * `peppol-bis-3`, `factur-x-en16931`, `xrechnung`, a PINT — and the socle
 * compiles it into `country_defaults.einvoice_profile`, which
 * `document_header` publishes. A profile is a format, not a country: the
 * mapping below names no country and would be the same for any pack that
 * declared the same profile.
 *
 * **A profile without a brick is refused by name**, `format_without_brick`,
 * and never written in the nearest format that exists: a file in another
 * profile is a file the network or the platform refuses, after it has left.
 * Adding a profile is adding an entry here and a brick under
 * `packages/formats/`, nothing else.
 *
 * Every writer reads the same three rows the views publish and nothing else,
 * plus one fact the views do not carry and the books do: which invoice a
 * credit note credits (BG-3), read from `documents.reversed_document_id`.
 * Nothing is defaulted on the way: a value the books do not hold is a value
 * the file does not hold, and the rule that wanted it is reported.
 */

import { CUSTOMIZATION_ID, PeppolUblError, generatePeppolUbl } from '@ekwo-ai/peppol-ubl';
import type { DocumentHeaderRow, DocumentLineRow, DocumentTaxRow } from '@ekwo-ai/peppol-ubl';
import { computeTotals, generateCiiXml, GUIDELINES } from '@ekwo-ai/factur-x';
import type { Invoice, InvoiceLine, Party, VatCategory } from '@ekwo-ai/factur-x';
import { MYINVOIS, MyInvoisError } from '@ekwo-ai/myinvois';
import type { MyInvoisInput, PartyIdentifiers, RegistrationScheme } from '@ekwo-ai/myinvois';
import { BooksError, type Row } from '../books/backend.js';

/** One rule of the format a file breaks, named as the brick or the published rule names it. */
export interface EinvoiceViolation {
  code: string;
  message: string;
  line?: string;
}

/** A posted sale as the books publish it: three views, and the invoice a credit note credits. */
export interface EinvoiceSource {
  header: Row;
  lines: Row[];
  taxes: Row[];
  /**
   * The invoice a credit note credits. `identifier` is the one the tax
   * authority gave it when it cleared it, read for a format that reads the
   * regime and null where it cleared none.
   */
  preceding: { number: string; issueDate: string | null; documentId?: string; identifier?: string | null } | null;
  /** The moment the file is issued, ISO 8601 with its offset, for a format that carries it. */
  issuedAt?: string;
}

/** What a writer hands back. */
export interface WrittenEinvoice {
  content: string;
  filename: string;
  violations: EinvoiceViolation[];
}

/** One profile a brick writes. */
export interface EinvoiceFormat {
  profile: string;
  /** The package of `packages/formats/` that writes it, by its published name. */
  brick: string;
  syntax: string;
  mediaType: string;
  /** What the file declares it follows: a customization identifier, a guideline. */
  specification: string;
  /**
   * The brick reads what the pack's fiscalisation regime gives the taxes and
   * the lines (`tax_attributes`, `line_attributes`), and the identifier the
   * authority gave the invoice a credit note credits. Left out, it reads the
   * three views alone.
   */
  readsRegime?: boolean;
  write(source: EinvoiceSource): WrittenEinvoice;
}

// ---------------------------------------------------------------------------
// Peppol BIS Billing 3.0 — UBL 2.1, by @ekwo-ai/peppol-ubl
//
// The brick was written for exactly this: it reads the three views as they
// are, writes the figures as posted, and names every rule the file breaks. So
// the adapter is one call, and the preceding invoice of a credit note.
// ---------------------------------------------------------------------------

const PEPPOL_BIS_3: EinvoiceFormat = {
  profile: 'peppol-bis-3',
  brick: '@ekwo-ai/peppol-ubl',
  syntax: 'UBL 2.1',
  mediaType: 'application/xml',
  specification: CUSTOMIZATION_ID,
  write(source) {
    try {
      const written = generatePeppolUbl(
        {
          header: source.header as unknown as DocumentHeaderRow,
          lines: source.lines as unknown as DocumentLineRow[],
          taxes: source.taxes as unknown as DocumentTaxRow[],
        },
        source.preceding === null
          ? {}
          : {
              precedingInvoice:
                source.preceding.issueDate === null
                  ? { number: source.preceding.number }
                  : { number: source.preceding.number, issueDate: source.preceding.issueDate },
            },
      );
      return { content: written.file, filename: written.filename, violations: written.violations };
    } catch (error) {
      if (error instanceof PeppolUblError) {
        throw new BooksError(`einvoice_unwritable: ${error.message}`);
      }
      throw error;
    }
  },
};

// ---------------------------------------------------------------------------
// Factur-X, EN 16931 profile — UN/CEFACT CII D16B, by @ekwo-ai/factur-x
//
// The older brick. It takes a plain invoice object of JavaScript numbers,
// computes its own totals and fills in what it is not given: a currency, a
// unit, a payment means, a delivery date, the sentence of an exemption.
// Decision 0050 names it as the brick to move to the contract of the views;
// until it is, this adapter holds it to the books from the outside:
//
//   * everything it would default is given from the books, or not given and
//     reported — never left for it to invent;
//   * what it computes is compared with what was posted, total by total and
//     group by group, and a difference is a broken rule. A file that disagrees
//     with the ledger by a cent is worse than a file that is refused.
//
// The file kept is the CII XML. The PDF/A-3 that carries it is rendered on
// demand by `renderDocumentPdf()` (books/document-pdf.ts), which hands this
// writer's XML and the visual invoice to the brick's `/pdf` entry.
// ---------------------------------------------------------------------------

/** A decimal as text without the zeros that say nothing: `100.50`, `100.5` and `100.500` are one amount. */
function canonical(value: unknown): string | null {
  if (value === null || value === undefined || value === '') return null;
  const text = String(value).trim();
  if (!/^-?\d+(\.\d+)?$/.test(text)) return text;
  const negative = text.startsWith('-');
  const [whole = '0', fraction = ''] = (negative ? text.slice(1) : text).split('.');
  const digits = whole.replace(/^0+(?=\d)/, '');
  const decimals = fraction.replace(/0+$/, '');
  const body = decimals === '' ? digits : `${digits}.${decimals}`;
  return negative && body !== '0' ? `-${body}` : body;
}

/** The brick's figure, as the two decimals it writes, in the same canonical form. */
const written = (value: number): string | null => canonical(value.toFixed(2));

const text = (value: unknown): string | null => {
  if (value === null || value === undefined) return null;
  const out = String(value).trim();
  return out === '' ? null : out;
};

/** The rule an exempting category breaks when nothing says why (BR-E-10, BR-AE-10, BR-IC-10, BR-G-10, BR-O-10). */
const REASON_RULE: Partial<Record<string, string>> = { E: 'E', AE: 'AE', K: 'IC', G: 'G', O: 'O' };
const CATEGORIES = new Set<string>(['S', 'Z', 'E', 'AE', 'K', 'G', 'O']);

function partyOf(
  header: Row,
  side: 'seller' | 'buyer',
  violations: EinvoiceViolation[],
): Party {
  const name = text(header[`${side}_legal_name`]) ?? text(header[`${side}_name`]);
  const country = text(header[`${side}_country`]);
  if (name === null) {
    violations.push({ code: side === 'seller' ? 'BR-06' : 'BR-07', message: `The ${side} has no name in the books.` });
  }
  if (country === null) {
    violations.push({
      code: side === 'seller' ? 'BR-09' : 'BR-11',
      message: `The postal address of the ${side} has no country in the books.`,
    });
  }
  const party: Party = {
    name: name ?? '',
    address: {
      line1: text(header[`${side}_address_line1`]) ?? '',
      postalCode: text(header[`${side}_postal_code`]) ?? '',
      city: text(header[`${side}_city`]) ?? '',
      country: country ?? '',
    },
  };
  const line2 = text(header[`${side}_address_line2`]);
  if (line2 !== null) party.address.line2 = line2;
  const region = text(header[`${side}_region`]);
  if (region !== null) party.address.subdivision = region;
  const vat = text(header[`${side}_vat_number`]);
  if (vat !== null) party.vatId = vat;
  const scheme = text(header[`${side}_peppol_scheme`]);
  const identifier = text(header[`${side}_peppol_identifier`]);
  if (scheme !== null && identifier !== null) party.electronicAddress = { scheme, value: identifier };
  return party;
}

/** The net price of a line, exactly, as the brick's number: the price as keyed less its discount. */
function netPrice(line: Row): number {
  const price = Number(line['unit_price'] ?? 0);
  const discount = Number(line['discount_percent'] ?? 0);
  return discount === 0 ? price : (price * (100 - discount)) / 100;
}

function writeFacturX(source: EinvoiceSource): WrittenEinvoice {
  const { header } = source;
  const violations: EinvoiceViolation[] = [];

  const number = text(header['number']);
  const issueDate = text(header['document_date']);
  const currency = text(header['currency_code']);
  const docType = text(header['doc_type']);
  if (docType !== 'sale_invoice' && docType !== 'sale_credit_note') {
    throw new BooksError(`einvoice_unwritable: a ${docType ?? 'document'} is not a sale invoice or a sale credit note`);
  }
  if (number === null) throw new BooksError('einvoice_unwritable: a document without a number was never issued');
  if (issueDate === null) throw new BooksError('einvoice_unwritable: the document has no date');
  if (currency === null) throw new BooksError('einvoice_unwritable: the document has no currency');

  const seller = partyOf(header, 'seller', violations);
  const buyer = partyOf(header, 'buyer', violations);
  if (seller.vatId === undefined && text(header['seller_registration_number']) === null) {
    violations.push({
      code: 'BR-CO-26',
      message: 'The seller has neither a VAT number nor a registration number in the books.',
    });
  }

  // The day the supply happened. The books state it, or derive it when the
  // document is posted (the tax point); the brick would write the date of the
  // invoice instead, which is a fact nobody stated.
  const delivery = text(header['delivery_date']) ?? text(header['tax_point_date']);
  if (delivery === null) {
    violations.push({
      code: 'delivery-date-missing',
      message:
        'The books state no date of delivery and no tax point for this document, and Factur-X writes one on every invoice (BT-72): the brick would put the date of the invoice there.',
    });
  }

  // The sentence of each exempting group, from the breakdown and nowhere else.
  const reasons: Partial<Record<VatCategory, string>> = {};
  for (const tax of source.taxes) {
    const category = text(tax['vat_category']);
    const reason = text(tax['exemption_reason']);
    if (category === null || REASON_RULE[category] === undefined) continue;
    if (reason !== null) reasons[category as Exclude<VatCategory, 'S' | 'Z'>] = reason;
    else {
      violations.push({
        code: `BR-${REASON_RULE[category] as string}-10`,
        message: `The VAT group ${category} charges nothing and the books carry no sentence saying why; the brick would write one of its own.`,
      });
    }
  }

  const lines: InvoiceLine[] = [];
  for (const row of source.lines) {
    if (text(row['line_type']) !== null && text(row['line_type']) !== 'product') continue;
    const id = String(row['sequence'] ?? lines.length + 1);
    const category = text(row['vat_category']);
    if (category === null || !CATEGORIES.has(category)) {
      violations.push({
        code: 'BR-CO-04',
        message: category === null ? 'The line carries no VAT category.' : `${category} is not a VAT category of EN 16931.`,
        line: id,
      });
    }
    if (row['unit_price_includes_tax'] === true) {
      violations.push({
        code: 'BR-26',
        message:
          'The price of this line was keyed with its tax in it, and the books publish no net price for it (BT-146): working one out is a rounding the books have not made.',
        line: id,
      });
    }
    const line: InvoiceLine = {
      id,
      name: text(row['item_name']) ?? '',
      quantity: Number(row['quantity'] ?? 0),
      unitPrice: row['unit_price_includes_tax'] === true ? 0 : netPrice(row),
      vatRate: Number(row['vat_rate'] ?? 0),
      netAmount: Number(row['amount_untaxed'] ?? 0),
    };
    if (category !== null && CATEGORIES.has(category)) line.vatCategory = category as VatCategory;
    const unit = text(row['unit_code']);
    if (unit !== null) line.unitCode = unit;
    const description = text(row['item_description']);
    if (description !== null) line.description = description;
    const sellerItem = text(row['seller_item_identifier']);
    if (sellerItem !== null) line.sellerItemId = sellerItem;
    lines.push(line);
  }
  if (lines.length === 0) throw new BooksError('einvoice_unwritable: the document has no line to invoice');

  const invoice: Invoice = {
    number,
    type: docType === 'sale_credit_note' ? 'credit-note' : 'invoice',
    issueDate,
    currency,
    seller,
    buyer,
    lines,
    exemptionReasons: reasons,
  };
  if (delivery !== null) invoice.deliveryDate = delivery;
  const due = text(header['due_date']);
  if (due !== null) invoice.dueDate = due;
  for (const [field, column] of [
    ['buyerReference', 'buyer_reference'],
    ['orderReference', 'order_reference'],
    ['contractReference', 'contract_reference'],
    ['note', 'note'],
  ] as const) {
    const value = text(header[column]);
    if (value !== null) invoice[field] = value;
  }
  if (source.preceding !== null) {
    invoice.precedingInvoice =
      source.preceding.issueDate === null
        ? { number: source.preceding.number }
        : { number: source.preceding.number, issueDate: source.preceding.issueDate };
  }

  // Payment: a means is a code the books hold or nothing. An account without
  // a code is not written, because the brick would call it a transfer.
  const means = text(header['payment_means_code']);
  const iban = text(header['payee_iban']);
  const terms = text(header['payment_terms']);
  const reference = text(header['payment_reference']);
  if (iban !== null && means === null) {
    violations.push({
      code: 'payment-means-missing',
      message: 'The books hold an account to pay into and no payment means code (BT-81): the account is not written.',
    });
  }
  if (means !== null || terms !== null || reference !== null) {
    invoice.payment = {};
    if (means !== null) {
      invoice.payment.meansCode = means;
      if (iban !== null) invoice.payment.iban = iban;
      const bic = text(header['payee_bic']);
      if (bic !== null) invoice.payment.bic = bic;
    }
    if (terms !== null) invoice.payment.terms = terms;
    if (reference !== null) invoice.payment.reference = reference;
  }
  const paid = canonical(header['amount_paid']);
  if (paid !== null && paid !== '0') invoice.prepaidAmount = Number(paid);

  const residual = canonical(header['amount_residual']);
  if (docType === 'sale_invoice' && due === null && terms === null && residual !== null && residual !== '0') {
    violations.push({
      code: 'BR-CO-25',
      message: 'An amount is due and the books state neither a due date nor payment terms.',
    });
  }

  // The brick's arithmetic against the ledger's, figure by figure.
  const totals = computeTotals(invoice);
  for (const [what, books, brick] of [
    ['total without VAT (BT-109)', header['amount_untaxed'], totals.taxBasisTotal],
    ['total VAT (BT-110)', header['amount_tax'], totals.taxTotal],
    ['total with VAT (BT-112)', header['amount_total'], totals.grandTotal],
    ['amount due (BT-115)', header['amount_residual'], totals.duePayable],
  ] as const) {
    if (canonical(books) !== null && canonical(books) !== written(brick)) {
      violations.push({
        code: 'totals-disagree',
        message: `The ${what} the file would carry, ${brick.toFixed(2)}, is not the ${String(books)} the books posted.`,
      });
    }
  }
  const posted = new Map<string, { base: number; tax: number }>();
  for (const tax of source.taxes) {
    const category = text(tax['vat_category']) ?? '';
    const rate = category === 'S' ? canonical(tax['tax_rate']) ?? '0' : '0';
    const key = `${category}|${rate}`;
    const group = posted.get(key) ?? { base: 0, tax: 0 };
    group.base += Number(tax['base_amount'] ?? 0);
    group.tax += Number(tax['tax_charged'] ?? 0);
    posted.set(key, group);
  }
  for (const group of totals.breakdown) {
    const key = `${group.category}|${canonical(group.rate) ?? '0'}`;
    const books = posted.get(key);
    if (books === undefined || written(books.base) !== written(group.basis) || written(books.tax) !== written(group.tax)) {
      violations.push({
        code: 'breakdown-disagree',
        message: `The VAT group ${group.category} at ${group.rate} % would carry ${group.basis.toFixed(2)} and ${group.tax.toFixed(2)} of VAT, which is not what the books posted for it${books === undefined ? ' — they posted no such group' : `: ${books.base.toFixed(2)} and ${books.tax.toFixed(2)}`}.`,
      });
    }
  }

  const safe = number.replace(/[^A-Za-z0-9._-]+/g, '-').replace(/^-+|-+$/g, '');
  return {
    content: generateCiiXml(invoice, { profile: 'en16931' }),
    filename: `${docType === 'sale_credit_note' ? 'credit-note' : 'invoice'}-${safe === '' ? 'document' : safe}.cii.xml`,
    violations,
  };
}

const FACTUR_X_EN16931: EinvoiceFormat = {
  profile: 'factur-x-en16931',
  brick: '@ekwo-ai/factur-x',
  syntax: 'UN/CEFACT CII D16B',
  mediaType: 'application/xml',
  specification: GUIDELINES.en16931,
  write: writeFacturX,
};

// ---------------------------------------------------------------------------
// MyInvois — UBL 2.1 in its JSON syntax, by @ekwo-ai/myinvois
//
// The document a tax authority validates before the invoice is issued. The
// brick reads the three views as they are and names every rule of the SDK the
// document breaks; what it asks beyond the views is read from the books and
// from the pack, never defaulted here:
//
//   * the tax type of each tax and the classification of each line are the
//     attributes the pack's fiscalisation regime gives them (`readsRegime`),
//     merged into the rows before this adapter sees them;
//   * the identifiers of both parties are `companies.identifiers` and
//     `contacts.identifiers`, published as `seller_identifiers` and
//     `buyer_identifiers`, by the scheme the format names them (`TIN`, `SST`,
//     `TTX`, and `BRN`, `NRIC`, `PASSPORT`, `ARMY` for the registration where
//     `registration_number` does not hold it); the supplier's activity is
//     `activity_code` with `activity_description`, the buyer's telephone
//     `buyer_phone`;
//   * the moment of issuance is the moment the file is written, and the
//     document a credit note adjusts is the invoice it credits with the
//     identifier the authority gave it, where it cleared one;
//   * a payment means of the books (UNTDID 4461) is written as the payment
//     mode of the same meaning in the format's list, where there is one.
//
// The version is the brick's default, 1.1, which the host signs before it
// submits; the core signs nothing and sends nothing. What the books do not
// hold — a foreign currency's rate to the ringgit, a mode with no
// counterpart — the brick reports by name.
// ---------------------------------------------------------------------------

/** UNTDID 4461 payment means, by the payment mode of the format's list that says the same thing. */
const PAYMENT_MODES: Partial<Record<string, string>> = {
  '10': '01', // In cash — Cash
  '20': '02', // Cheque — Cheque
  '30': '03', // Credit transfer — Bank Transfer
  '31': '03', // Debit transfer — Bank Transfer
  '42': '03', // Payment to bank account — Bank Transfer
  '58': '03', // SEPA credit transfer — Bank Transfer
  '54': '04', // Credit card — Credit Card
  '55': '05', // Debit card — Debit Card
};

const REGISTRATION_SCHEMES: readonly RegistrationScheme[] = ['BRN', 'NRIC', 'PASSPORT', 'ARMY'];

/** The identifiers of one side, by scheme, as the view publishes them. */
function identifiersOf(header: Row, side: 'seller' | 'buyer'): Record<string, string> {
  return byScheme(header[`${side}_identifiers`]);
}

/**
 * A column of codes by scheme — the identifiers of a party, the
 * classifications of a line (decision 0078) — as an object of texts, however
 * the backend handed the JSON over.
 */
function byScheme(raw: unknown): Record<string, string> {
  const parsed: unknown = typeof raw === 'string' ? JSON.parse(raw) : raw;
  if (parsed === null || typeof parsed !== 'object' || Array.isArray(parsed)) return {};
  return Object.fromEntries(
    Object.entries(parsed as Record<string, unknown>)
      .map(([scheme, value]) => [scheme, text(value)] as const)
      .filter((entry): entry is readonly [string, string] => entry[1] !== null),
  );
}

function partyIdentifiers(identifiers: Record<string, string>): PartyIdentifiers {
  const party: PartyIdentifiers = {};
  if (identifiers['TIN'] !== undefined) party.tin = identifiers['TIN'];
  if (identifiers['SST'] !== undefined) party.sst = identifiers['SST'];
  const scheme = REGISTRATION_SCHEMES.find((each) => identifiers[each] !== undefined);
  if (scheme !== undefined) party.registration = { scheme, id: identifiers[scheme] as string };
  return party;
}

function writeMyInvois(source: EinvoiceSource): WrittenEinvoice {
  const { header } = source;
  if (source.issuedAt === undefined) {
    throw new BooksError('einvoice_unwritable: MyInvois carries the moment of issuance, and none was given');
  }
  const seller = identifiersOf(header, 'seller');
  const buyer = identifiersOf(header, 'buyer');
  const activity = text(header['seller_activity_code']);
  const input: MyInvoisInput = {
    header,
    // A line that names a code of LHDNM's list (`CLASS`, the list identifier
    // the document writes) by its own classification gives it over the
    // default the regime gives every line.
    lines: source.lines.map((line) => {
      const own = byScheme(line['classifications'])['CLASS'];
      return own === undefined ? line : { ...line, myinvois_classification: own };
    }),
    taxes: source.taxes,
    issuedAt: source.issuedAt,
    supplier: {
      ...partyIdentifiers(seller),
      ...(seller['TTX'] === undefined ? {} : { tourismTax: seller['TTX'] }),
      ...(activity === null ? {} : { activity: { msic: activity, description: text(header['seller_activity_description']) ?? '' } }),
    },
    buyer: partyIdentifiers(buyer),
  };
  const mode = PAYMENT_MODES[text(header['payment_means_code']) ?? ''];
  if (mode !== undefined) input.paymentMode = mode;
  const credited = source.preceding;
  if (credited !== null && text(credited.identifier) !== null) {
    input.adjusts = [{ number: credited.number, uuid: credited.identifier as string }];
  }
  try {
    const written = MYINVOIS.write(input);
    return { content: written.content, filename: written.filename, violations: written.violations };
  } catch (error) {
    if (error instanceof MyInvoisError) throw new BooksError(`einvoice_unwritable: ${error.message}`);
    throw error;
  }
}

const MYINVOIS_JSON: EinvoiceFormat = {
  profile: 'myinvois',
  brick: MYINVOIS.brick,
  syntax: 'UBL 2.1 (JSON)',
  mediaType: 'application/json',
  specification: MYINVOIS.specification,
  readsRegime: true,
  write: writeMyInvois,
};

/** Every profile a brick of this release writes, by the name a pack declares it under. */
export const EINVOICE_FORMATS: Readonly<Record<string, EinvoiceFormat>> = {
  [PEPPOL_BIS_3.profile]: PEPPOL_BIS_3,
  [FACTUR_X_EN16931.profile]: FACTUR_X_EN16931,
  [MYINVOIS_JSON.profile]: MYINVOIS_JSON,
};

/**
 * The format of a profile, or the refusal that names what is missing: no
 * profile in the pack (`no_einvoicing_profile`), or a profile no brick of this
 * release writes (`format_without_brick`).
 */
export function einvoiceFormat(profile: string | null | undefined): EinvoiceFormat {
  if (profile === null || profile === undefined || profile.trim() === '') {
    throw new BooksError(
      'no_einvoicing_profile: the country pack of this company declares no e-invoicing profile, so there is no format to issue in.',
      { hint: 'A pack says which profile its companies issue in, in its einvoicing section; describe_pack (ekwo pack describe) shows it.' },
    );
  }
  const format = EINVOICE_FORMATS[profile];
  if (format === undefined) {
    throw new BooksError(
      `format_without_brick: the country pack of this company issues in ${profile}, and no brick of packages/formats/ writes ${profile} yet. ` +
        `This release writes ${Object.keys(EINVOICE_FORMATS).join(' and ')}; a file in one of those is not a ${profile} file, and none is written in its place.`,
    );
  }
  return format;
}
