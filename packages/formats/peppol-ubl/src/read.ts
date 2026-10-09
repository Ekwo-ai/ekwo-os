/**
 * A received UBL 2.1 invoice or credit note, read.
 *
 * The other half of e-invoicing: what a supplier sends over Peppol, turned
 * into the plain shape of `received.ts`, which the CII reader of the Factur-X
 * brick returns too. The reader is written against Peppol BIS Billing 3.0 and
 * the UBL binding of EN 16931 — which business term lives in which element —
 * and reads any UBL 2.1 `Invoice` or `CreditNote` that follows that binding,
 * Peppol or not; `customizationId` says what the file claims to be.
 *
 * It reads what the file says and judges only the arithmetic (see
 * `received-checks.ts`). It does not re-run the rules of the writer: a
 * received invoice is somebody else's document, and whether it is valid on
 * the network was the sending access point's question. A file that is not an
 * invoice at all — not XML, not UBL, no number, an amount that is not one — is
 * an {@link InvoiceFileError}, never a raw error of the parser.
 */

import { InvoiceFileError } from './errors.js';
import type {
  DateText,
  ReadOptions,
  ReceivedAccount,
  ReceivedAddress,
  ReceivedAllowanceCharge,
  ReceivedAttachment,
  ReceivedIdentifier,
  ReceivedInvoice,
  ReceivedInvoiceFile,
  ReceivedLine,
  ReceivedParty,
  ReceivedPaymentMeans,
  ReceivedTax,
  ReceivedViolation,
} from './received.js';
import { checkReceived, decimalText, decodeBase64, isValidIban } from './received-checks.js';
import { parseXml, type XmlElement } from './xml.js';

const NS = {
  Invoice: 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2',
  CreditNote: 'urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2',
  cac: 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2',
  cbc: 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2',
  /** The envelope a Peppol access point may hand the document over in. */
  sbdh: 'http://www.unece.org/cefact/namespaces/StandardBusinessDocumentHeader',
  cii: 'urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100',
} as const;

const DEFAULTS = { maxBytes: 64 * 1024 * 1024, maxDepth: 64, maxElements: 500_000 };

// --- walking the tree ------------------------------------------------------

type Path = string[];

/** `cac:A/cbc:B` written as `['A', 'B']`: every step but the last is an aggregate, the last is either. */
function find(parent: XmlElement | undefined, path: Path): XmlElement | undefined {
  let current = parent;
  for (const name of path) {
    if (current === undefined) return undefined;
    current = current.children.find((each) => each.name === name && (each.namespace === NS.cac || each.namespace === NS.cbc));
  }
  return current;
}

function all(parent: XmlElement | undefined, name: string): XmlElement[] {
  if (parent === undefined) return [];
  return parent.children.filter((each) => each.name === name && (each.namespace === NS.cac || each.namespace === NS.cbc));
}

/** The trimmed text at a path, or null when absent or blank. */
function text(parent: XmlElement | undefined, ...path: Path): string | null {
  const value = find(parent, path)?.text.trim();
  return value === undefined || value === '' ? null : value;
}

function attribute(element: XmlElement | undefined, name: string): string | null {
  const value = element?.attributes[name]?.trim();
  return value === undefined || value === '' ? null : value;
}

function required(parent: XmlElement | undefined, what: string, ...path: Path): string {
  const value = text(parent, ...path);
  if (value === null) throw new InvoiceFileError('missing_element', `the document has no ${what} (${path.join('/')})`);
  return value;
}

function amount(parent: XmlElement | undefined, what: string, ...path: Path): string | null {
  const value = text(parent, ...path);
  return value === null ? null : decimalText(value, what);
}

function requiredAmount(parent: XmlElement | undefined, what: string, ...path: Path): string {
  return decimalText(required(parent, what, ...path), what);
}

const DAY = /^([0-9]{4})-([0-9]{2})-([0-9]{2})(?:Z|[+-][0-9]{2}:[0-9]{2})?$/;

/** An `xs:date`: the day it names, as written — never moved to another time zone. */
function date(parent: XmlElement | undefined, what: string, ...path: Path): DateText | null {
  const raw = text(parent, ...path);
  if (raw === null) return null;
  const match = DAY.exec(raw);
  const year = Number(match?.[1]);
  const month = Number(match?.[2]);
  const day = Number(match?.[3]);
  const leap = (year % 4 === 0 && year % 100 !== 0) || year % 400 === 0;
  const length = [31, leap ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month - 1];
  if (match === null || length === undefined || day < 1 || day > length) {
    throw new InvoiceFileError('invalid_value', `${what} is not a date: ${JSON.stringify(raw)}`);
  }
  return `${match[1]}-${match[2]}-${match[3]}`;
}

function identifier(element: XmlElement | undefined): ReceivedIdentifier | null {
  const value = element?.text.trim();
  if (element === undefined || value === undefined || value === '') return null;
  return { value, scheme: attribute(element, 'schemeID') };
}

function account(value: string | null): ReceivedAccount | null {
  if (value === null) return null;
  const compact = value.replace(/\s+/g, '').toUpperCase();
  return isValidIban(compact) ? { kind: 'iban', value: compact } : { kind: 'other', value };
}

// --- the parts -------------------------------------------------------------

function address(element: XmlElement | undefined): ReceivedAddress | null {
  if (element === undefined) return null;
  const lines = [
    text(element, 'StreetName'),
    text(element, 'AdditionalStreetName'),
    ...all(element, 'AddressLine').map((line) => text(line, 'Line')),
  ].filter((line): line is string => line !== null);
  const result: ReceivedAddress = {
    lines,
    city: text(element, 'CityName'),
    postalCode: text(element, 'PostalZone'),
    region: text(element, 'CountrySubentity'),
    country: text(element, 'Country', 'IdentificationCode'),
  };
  return lines.length > 0 || Object.values(result).some((value) => typeof value === 'string') ? result : null;
}

function party(element: XmlElement | undefined, who: 'seller' | 'buyer'): ReceivedParty {
  let vatId: string | null = null;
  let taxRegistrationId: string | null = null;
  for (const scheme of all(element, 'PartyTaxScheme')) {
    const id = text(scheme, 'CompanyID');
    if (id === null) continue;
    if ((text(scheme, 'TaxScheme', 'ID') ?? '').toUpperCase() === 'VAT') vatId ??= id;
    else if (who === 'seller') taxRegistrationId ??= id;
  }
  const legal = find(element, ['PartyLegalEntity']);
  const contact = find(element, ['Contact']);
  const contactFields = {
    name: text(contact, 'Name'),
    phone: text(contact, 'Telephone'),
    email: text(contact, 'ElectronicMail'),
  };
  return {
    name: text(legal, 'RegistrationName'),
    tradeName: text(element, 'PartyName', 'Name'),
    identifiers: all(element, 'PartyIdentification')
      .map((each) => identifier(find(each, ['ID'])))
      .filter((each): each is ReceivedIdentifier => each !== null),
    legalId: identifier(find(legal, ['CompanyID'])),
    vatId,
    taxRegistrationId,
    legalForm: text(legal, 'CompanyLegalForm'),
    electronicAddress: identifier(find(element, ['EndpointID'])),
    address: address(find(element, ['PostalAddress'])),
    contact: Object.values(contactFields).some((value) => value !== null) ? contactFields : null,
  };
}

function allowanceCharge(element: XmlElement, where: string, onLine: boolean): ReceivedAllowanceCharge {
  const indicator = text(element, 'ChargeIndicator');
  if (indicator !== 'true' && indicator !== 'false') {
    throw new InvoiceFileError('invalid_value', `an allowance or charge of ${where} says neither true nor false: ${JSON.stringify(indicator)}`);
  }
  const charge = indicator === 'true';
  const what = `${charge ? 'a charge' : 'an allowance'} of ${where}`;
  return {
    charge,
    amount: requiredAmount(element, `the amount of ${what}`, 'Amount'),
    baseAmount: amount(element, `the base of ${what}`, 'BaseAmount'),
    percent: amount(element, `the percentage of ${what}`, 'MultiplierFactorNumeric'),
    reason: text(element, 'AllowanceChargeReason'),
    reasonCode: text(element, 'AllowanceChargeReasonCode'),
    vatCategory: onLine ? null : text(element, 'TaxCategory', 'ID'),
    vatRate: onLine ? null : amount(element, `the VAT rate of ${what}`, 'TaxCategory', 'Percent'),
  };
}

function line(element: XmlElement, kind: 'Invoice' | 'CreditNote', position: number): ReceivedLine {
  const id = text(element, 'ID');
  if (id === null) throw new InvoiceFileError('missing_element', `line ${position} has no identifier (BT-126)`);
  const where = `line ${id}`;
  const quantity = find(element, [kind === 'Invoice' ? 'InvoicedQuantity' : 'CreditedQuantity']);
  const item = find(element, ['Item']);
  const price = find(element, ['Price']);
  const priceAllowance = find(price, ['AllowanceCharge']);
  const period = find(element, ['InvoicePeriod']);
  const baseQuantity = find(price, ['BaseQuantity']);
  return {
    id,
    note: text(element, 'Note'),
    quantity: quantity === undefined || quantity.text.trim() === '' ? null : decimalText(quantity.text, `the quantity of ${where}`),
    unitCode: attribute(quantity, 'unitCode'),
    netAmount: requiredAmount(element, `the net amount of ${where}`, 'LineExtensionAmount'),
    orderLineReference: text(element, 'OrderLineReference', 'LineID'),
    period:
      period === undefined
        ? null
        : { start: date(period, `the start of ${where}`, 'StartDate'), end: date(period, `the end of ${where}`, 'EndDate') },
    allowances: all(element, 'AllowanceCharge').map((each) => allowanceCharge(each, where, true)),
    netPrice: amount(price, `the net price of ${where}`, 'PriceAmount'),
    priceDiscount: amount(priceAllowance, `the price discount of ${where}`, 'Amount'),
    grossPrice: amount(priceAllowance, `the gross price of ${where}`, 'BaseAmount'),
    priceBaseQuantity:
      baseQuantity === undefined || baseQuantity.text.trim() === ''
        ? null
        : decimalText(baseQuantity.text, `the base quantity of the price of ${where}`),
    priceBaseUnitCode: attribute(baseQuantity, 'unitCode'),
    vatCategory: text(item, 'ClassifiedTaxCategory', 'ID'),
    vatRate: amount(item, `the VAT rate of ${where}`, 'ClassifiedTaxCategory', 'Percent'),
    name: text(item, 'Name'),
    description: text(item, 'Description'),
    sellerItemId: text(item, 'SellersItemIdentification', 'ID'),
    buyerItemId: text(item, 'BuyersItemIdentification', 'ID'),
    standardItemId: identifier(find(item, ['StandardItemIdentification', 'ID'])),
  };
}

function paymentMeans(element: XmlElement): ReceivedPaymentMeans {
  const code = find(element, ['PaymentMeansCode']);
  const payee = find(element, ['PayeeFinancialAccount']);
  const mandate = find(element, ['PaymentMandate']);
  return {
    code: text(element, 'PaymentMeansCode'),
    text: attribute(code, 'name'),
    reference: text(element, 'PaymentID'),
    account: account(text(payee, 'ID')),
    accountName: text(payee, 'Name'),
    bic: text(payee, 'FinancialInstitutionBranch', 'ID'),
    cardNumber: text(element, 'CardAccount', 'PrimaryAccountNumberID'),
    mandateReference: text(mandate, 'ID'),
    debitedAccount: account(text(mandate, 'PayerFinancialAccount', 'ID')),
  };
}

/** The document inside, where the file is the envelope of a Peppol access point. */
function unwrap(root: XmlElement): XmlElement {
  if (root.namespace !== NS.sbdh || root.name !== 'StandardBusinessDocument') return root;
  const inside = root.children.filter((each) => !(each.namespace === NS.sbdh && each.name === 'StandardBusinessDocumentHeader'));
  if (inside.length !== 1) {
    throw new InvoiceFileError('not_an_invoice', 'the envelope (StandardBusinessDocument) carries no single document');
  }
  return inside[0] as XmlElement;
}

/**
 * Reads a UBL 2.1 `Invoice` or `CreditNote` — bare, or in the
 * `StandardBusinessDocument` envelope an access point hands it over in.
 *
 * Throws an {@link InvoiceFileError} when there is no invoice to return: the
 * bytes are not XML or not UTF-8, the document is not UBL, or it lacks a
 * number, a date, a currency, its totals or a line, or holds an amount or a
 * date that is not one. Everything else comes back, with `violations` naming
 * what does not add up.
 */
export function readUbl(input: string | Uint8Array, options: ReadOptions = {}): ReceivedInvoiceFile {
  const limits = { ...DEFAULTS, ...options };
  const root = unwrap(parseXml(input, limits));
  if (root.namespace === NS.cii) {
    throw new InvoiceFileError('not_an_invoice', 'the file is a CII invoice (Factur-X, ZUGFeRD), not UBL: read it with the CII reader');
  }
  const kind = root.name === 'Invoice' && root.namespace === NS.Invoice
    ? 'Invoice'
    : root.name === 'CreditNote' && root.namespace === NS.CreditNote
      ? 'CreditNote'
      : null;
  if (kind === null) {
    throw new InvoiceFileError(
      'not_an_invoice',
      `the document is <${root.name}> in ${root.namespace === '' ? 'no namespace' : root.namespace}, not a UBL 2.1 Invoice or CreditNote`,
    );
  }

  const violations: ReceivedViolation[] = [];
  const currency = required(root, 'currency', 'DocumentCurrencyCode');
  const taxCurrency = text(root, 'TaxCurrencyCode');

  // BT-110 is the total VAT in the currency of the document; BT-111 the one
  // in the tax currency, which UBL writes as a second TaxTotal.
  const taxTotals = all(root, 'TaxTotal');
  const inCurrency = (each: XmlElement, code: string | null): boolean => {
    const written = attribute(find(each, ['TaxAmount']), 'currencyID');
    return written === null ? code === currency : written === code;
  };
  const documentTax = taxTotals.find((each) => inCurrency(each, currency)) ?? taxTotals[0];
  const taxCurrencyTax = taxCurrency !== null && taxCurrency !== currency
    ? taxTotals.find((each) => each !== documentTax && inCurrency(each, taxCurrency))
    : undefined;

  const taxes: ReceivedTax[] = all(documentTax, 'TaxSubtotal').map((subtotal) => {
    const category = find(subtotal, ['TaxCategory']);
    const label = `the VAT group ${text(category, 'ID') ?? '?'} ${text(category, 'Percent') ?? ''}`.trim();
    return {
      category: text(category, 'ID'),
      rate: amount(category, `the rate of ${label}`, 'Percent'),
      base: requiredAmount(subtotal, `the base of ${label}`, 'TaxableAmount'),
      tax: requiredAmount(subtotal, `the tax of ${label}`, 'TaxAmount'),
      exemptionReasonCode: text(category, 'TaxExemptionReasonCode'),
      exemptionReason: text(category, 'TaxExemptionReason'),
    };
  });

  const totals = find(root, ['LegalMonetaryTotal']);
  if (totals === undefined) throw new InvoiceFileError('missing_element', 'the document has no totals (LegalMonetaryTotal)');

  // A credit note has no element of its own for a project (BT-11) and writes
  // it as an additional document of type 50; an invoice object (BT-18) is one
  // of type 130. Neither is an attachment.
  let projectReference = kind === 'Invoice' ? text(root, 'ProjectReference', 'ID') : null;
  const attachments: ReceivedAttachment[] = [];
  for (const reference of all(root, 'AdditionalDocumentReference')) {
    const typeCode = text(reference, 'DocumentTypeCode');
    if (typeCode === '130') continue;
    if (typeCode === '50' && kind === 'CreditNote') {
      projectReference ??= text(reference, 'ID');
      continue;
    }
    const attachment = find(reference, ['Attachment']);
    const embedded = find(attachment, ['EmbeddedDocumentBinaryObject']);
    let content: Uint8Array | null = null;
    if (embedded !== undefined) {
      content = decodeBase64(embedded.text);
      if (content === null) {
        violations.push({
          code: 'invalid_attachment',
          message: `The document ${text(reference, 'ID') ?? 'attached'} is not base64, and was not decoded.`,
        });
      }
    }
    attachments.push({
      id: text(reference, 'ID'),
      description: text(reference, 'DocumentDescription'),
      filename: attribute(embedded, 'filename'),
      mimeType: attribute(embedded, 'mimeCode'),
      content,
      uri: text(attachment, 'ExternalReference', 'URI'),
    });
  }

  const means = all(root, 'PaymentMeans');
  const lineElements = all(root, kind === 'Invoice' ? 'InvoiceLine' : 'CreditNoteLine');
  if (lineElements.length === 0) throw new InvoiceFileError('missing_element', 'the document has no line');
  const period = find(root, ['InvoicePeriod']);
  const delivery = find(root, ['Delivery']);

  const invoice: ReceivedInvoice = {
    syntax: 'ubl',
    customizationId: text(root, 'CustomizationID'),
    profileId: text(root, 'ProfileID'),
    kind: kind === 'Invoice' ? 'invoice' : 'credit_note',
    typeCode: text(root, kind === 'Invoice' ? 'InvoiceTypeCode' : 'CreditNoteTypeCode'),
    number: required(root, 'number', 'ID'),
    issueDate: date(root, 'the issue date', 'IssueDate') ?? required(root, 'issue date', 'IssueDate'),
    // A credit note has no due date of its own in UBL 2.1: BT-9 lives in the payment means.
    dueDate:
      kind === 'Invoice'
        ? date(root, 'the due date', 'DueDate')
        : means.map((each) => date(each, 'the due date', 'PaymentDueDate')).find((each) => each !== null) ?? null,
    taxPointDate: date(root, 'the tax point date', 'TaxPointDate'),
    currency,
    taxCurrency,
    buyerReference: text(root, 'BuyerReference'),
    orderReference: text(root, 'OrderReference', 'ID'),
    salesOrderReference: text(root, 'OrderReference', 'SalesOrderID'),
    contractReference: text(root, 'ContractDocumentReference', 'ID'),
    projectReference,
    accountingCost: text(root, 'AccountingCost'),
    precedingInvoices: all(root, 'BillingReference')
      .map((each) => find(each, ['InvoiceDocumentReference']))
      .filter((each): each is XmlElement => each !== undefined && text(each, 'ID') !== null)
      .map((each) => ({
        number: text(each, 'ID') as string,
        issueDate: date(each, 'the date of a preceding invoice', 'IssueDate'),
      })),
    notes: all(root, 'Note')
      .map((each) => each.text.trim())
      .filter((each) => each !== ''),
    seller: party(find(root, ['AccountingSupplierParty', 'Party']), 'seller'),
    buyer: party(find(root, ['AccountingCustomerParty', 'Party']), 'buyer'),
    deliveryDate: date(delivery, 'the delivery date', 'ActualDeliveryDate'),
    deliveryAddress: address(find(delivery, ['DeliveryLocation', 'Address'])),
    invoicingPeriod:
      period === undefined
        ? null
        : { start: date(period, 'the start of the invoicing period', 'StartDate'), end: date(period, 'the end of the invoicing period', 'EndDate') },
    paymentTerms: text(root, 'PaymentTerms', 'Note'),
    paymentMeans: means.map(paymentMeans),
    allowances: all(root, 'AllowanceCharge').map((each) => allowanceCharge(each, 'the document', false)),
    taxes,
    totals: {
      lineTotal: amount(totals, 'the sum of the lines', 'LineExtensionAmount'),
      allowanceTotal: amount(totals, 'the sum of the allowances', 'AllowanceTotalAmount'),
      chargeTotal: amount(totals, 'the sum of the charges', 'ChargeTotalAmount'),
      taxExclusive: requiredAmount(totals, 'the total without VAT', 'TaxExclusiveAmount'),
      taxTotal: amount(documentTax, 'the total VAT', 'TaxAmount'),
      taxTotalInTaxCurrency: amount(taxCurrencyTax, 'the total VAT in the tax currency', 'TaxAmount'),
      taxInclusive: requiredAmount(totals, 'the total with VAT', 'TaxInclusiveAmount'),
      prepaid: amount(totals, 'the amount paid', 'PrepaidAmount'),
      rounding: amount(totals, 'the rounding amount', 'PayableRoundingAmount'),
      payable: requiredAmount(totals, 'the amount due', 'PayableAmount'),
    },
    lines: lineElements.map((each, index) => line(each, kind, index + 1)),
    attachments,
  };

  return { invoice, violations: [...violations, ...checkReceived(invoice)] };
}
