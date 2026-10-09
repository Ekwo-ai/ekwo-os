/**
 * A received CII invoice or credit note, read.
 *
 * The XML of a Factur-X or ZUGFeRD file — UN/CEFACT Cross Industry Invoice
 * D16B — turned into the plain shape of `received.ts`, which the UBL reader of
 * the Peppol brick returns too: a business term is in the same field whichever
 * syntax carried it. The reader follows the CII binding of EN 16931 (which
 * business term lives in which element) and reads every profile of Factur-X
 * 1.0 and ZUGFeRD 2.x, from MINIMUM to EXTENDED; `profile` says which one the
 * file declares, and what a lighter profile does not carry comes back null or
 * empty, never invented. EXTENDED elements beyond EN 16931 are not read.
 *
 * It reads what the file says and judges only the arithmetic (see
 * `received-checks.ts`). A file that is not an invoice at all — not XML, not
 * CII, no number, an amount that is not one — is an {@link InvoiceFileError},
 * never a raw error of the parser.
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
import { CREDIT_NOTE_TYPE_CODES, checkReceived, decimalText, decodeBase64, isValidIban } from './received-checks.js';
import type { Profile } from './types.js';
import { parseXml, type XmlElement } from './xml.js';

const NS = {
  rsm: 'urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100',
  ram: 'urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100',
  udt: 'urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100',
  qdt: 'urn:un:unece:uncefact:data:standard:QualifiedDataType:100',
  ublInvoice: 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2',
  ublCreditNote: 'urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2',
} as const;

const CII_NAMESPACES: ReadonlySet<string> = new Set([NS.rsm, NS.ram, NS.udt, NS.qdt]);

const DEFAULTS = { maxBytes: 64 * 1024 * 1024, maxDepth: 64, maxElements: 500_000 };

/**
 * The guideline identifiers (BT-24) of Factur-X 1.0 and ZUGFeRD 2.x, by
 * profile, as the specifications of the two (FNFE-MPE and FeRD) list them.
 * The `urn:zugferd.de:2p0` spellings are those of ZUGFeRD 2.0, written before
 * the two specifications converged on the Factur-X ones.
 */
const PROFILE_GUIDELINES: Readonly<Record<string, Profile>> = {
  'urn:factur-x.eu:1p0:minimum': 'minimum',
  'urn:zugferd.de:2p0:minimum': 'minimum',
  'urn:factur-x.eu:1p0:basicwl': 'basic-wl',
  'urn:zugferd.de:2p0:basicwl': 'basic-wl',
  'urn:cen.eu:en16931:2017#compliant#urn:factur-x.eu:1p0:basic': 'basic',
  'urn:cen.eu:en16931:2017#compliant#urn:zugferd.de:2p0:basic': 'basic',
  'urn:cen.eu:en16931:2017': 'en16931',
  'urn:cen.eu:en16931:2017#conformant#urn:factur-x.eu:1p0:extended': 'extended',
  'urn:cen.eu:en16931:2017#conformant#urn:zugferd.de:2p0:extended': 'extended',
};

/**
 * The profile a guideline identifier declares. Another specification built on
 * EN 16931 by restriction — a CIUS such as XRechnung, written
 * `urn:cen.eu:en16931:2017#compliant#…` — is EN 16931 for a reader: it holds
 * nothing EN 16931 does not. Anything else is null, and `customizationId`
 * keeps what the file wrote.
 */
export function profileOf(guideline: string | null): Profile | null {
  if (guideline === null) return null;
  const known = PROFILE_GUIDELINES[guideline];
  if (known !== undefined) return known;
  return guideline.startsWith('urn:cen.eu:en16931:2017#compliant#') ? 'en16931' : null;
}

/** What {@link readCii} returns: the invoice, what does not add up, and the profile the file declares. */
export interface ReceivedCiiFile extends ReceivedInvoiceFile {
  /** From the guideline identifier (BT-24); null where it names no profile this reader knows. */
  profile: Profile | null;
}

// --- walking the tree ------------------------------------------------------

type Path = string[];

function isCii(element: XmlElement, name: string): boolean {
  return element.name === name && CII_NAMESPACES.has(element.namespace);
}

function find(parent: XmlElement | undefined, path: Path): XmlElement | undefined {
  let current = parent;
  for (const name of path) {
    if (current === undefined) return undefined;
    current = current.children.find((each) => isCii(each, name));
  }
  return current;
}

function all(parent: XmlElement | undefined, name: string): XmlElement[] {
  if (parent === undefined) return [];
  return parent.children.filter((each) => isCii(each, name));
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

function identifier(element: XmlElement | undefined): ReceivedIdentifier | null {
  const value = element?.text.trim();
  if (element === undefined || value === undefined || value === '') return null;
  return { value, scheme: attribute(element, 'schemeID') };
}

const DAY_102 = /^([0-9]{4})([0-9]{2})([0-9]{2})$/;

/**
 * One reading, holding the violations it finds on the way: a date in a format
 * EN 16931 does not use is reported and returned as null rather than refused.
 */
class Reader {
  readonly violations: ReceivedViolation[] = [];

  /**
   * A date of CII: a `DateTimeString` (or `DateString`) of format 102,
   * `YYYYMMDD` — the only format the CII binding of EN 16931 (EN 16931-3-3)
   * uses for a date. `holder` is the element that contains the string,
   * `IssueDateTime` and the like.
   */
  date(holder: XmlElement | undefined, what: string): DateText | null {
    if (holder === undefined) return null;
    const string = holder.children.find((each) => isCii(each, 'DateTimeString') || isCii(each, 'DateString'));
    const raw = string?.text.trim() ?? '';
    if (string === undefined || raw === '') return null;
    const format = attribute(string, 'format');
    if (format !== null && format !== '102') {
      this.violations.push({
        code: 'unsupported_date_format',
        message: `${what} is written in format ${format}; EN 16931 dates are format 102 (YYYYMMDD), and it was not read.`,
      });
      return null;
    }
    const match = DAY_102.exec(raw);
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

  period(element: XmlElement | undefined, what: string): { start: DateText | null; end: DateText | null } | null {
    if (element === undefined) return null;
    return {
      start: this.date(find(element, ['StartDateTime']), `the start of ${what}`),
      end: this.date(find(element, ['EndDateTime']), `the end of ${what}`),
    };
  }

  /** CII says which kind of account it holds; an IBAN whose digits fail is still the IBAN the file wrote, and reported. */
  iban(value: string | null, what: string): ReceivedAccount | null {
    if (value === null) return null;
    const compact = value.replace(/\s+/g, '').toUpperCase();
    if (!isValidIban(compact)) {
      this.violations.push({ code: 'invalid_iban', message: `${what}, ${value}, is written as an IBAN and its check digits fail.` });
    }
    return { kind: 'iban', value: compact };
  }
}

// --- the parts -------------------------------------------------------------

function address(element: XmlElement | undefined): ReceivedAddress | null {
  if (element === undefined) return null;
  const lines = [text(element, 'LineOne'), text(element, 'LineTwo'), text(element, 'LineThree')].filter(
    (line): line is string => line !== null,
  );
  const result: ReceivedAddress = {
    lines,
    city: text(element, 'CityName'),
    postalCode: text(element, 'PostcodeCode'),
    region: text(element, 'CountrySubDivisionName'),
    country: text(element, 'CountryID'),
  };
  return lines.length > 0 || Object.values(result).some((value) => typeof value === 'string') ? result : null;
}

function party(element: XmlElement | undefined, who: 'seller' | 'buyer'): ReceivedParty {
  let vatId: string | null = null;
  let taxRegistrationId: string | null = null;
  for (const registration of all(element, 'SpecifiedTaxRegistration')) {
    const id = find(registration, ['ID']);
    const value = id?.text.trim();
    if (value === undefined || value === '') continue;
    const scheme = (attribute(id, 'schemeID') ?? '').toUpperCase();
    if (scheme === 'VA') vatId ??= value;
    else if (scheme === 'FC' && who === 'seller') taxRegistrationId ??= value;
  }
  const legal = find(element, ['SpecifiedLegalOrganization']);
  const contact = find(element, ['DefinedTradeContact']);
  const contactFields = {
    name: text(contact, 'PersonName') ?? text(contact, 'DepartmentName'),
    phone: text(contact, 'TelephoneUniversalCommunication', 'CompleteNumber'),
    email: text(contact, 'EmailURIUniversalCommunication', 'URIID'),
  };
  return {
    name: text(element, 'Name'),
    tradeName: text(legal, 'TradingBusinessName'),
    // BT-29 / BT-46: GlobalID where the identifier has a scheme, ID where it has none.
    identifiers: [...all(element, 'ID'), ...all(element, 'GlobalID')]
      .map((each) => identifier(each))
      .filter((each): each is ReceivedIdentifier => each !== null),
    legalId: identifier(find(legal, ['ID'])),
    vatId,
    taxRegistrationId,
    legalForm: who === 'seller' ? text(element, 'Description') : null,
    electronicAddress: identifier(find(element, ['URIUniversalCommunication', 'URIID'])),
    address: address(find(element, ['PostalTradeAddress'])),
    contact: Object.values(contactFields).some((value) => value !== null) ? contactFields : null,
  };
}

function allowanceCharge(element: XmlElement, where: string, onLine: boolean): ReceivedAllowanceCharge {
  const indicator = text(element, 'ChargeIndicator', 'Indicator');
  if (indicator !== 'true' && indicator !== 'false') {
    throw new InvoiceFileError('invalid_value', `an allowance or charge of ${where} says neither true nor false: ${JSON.stringify(indicator)}`);
  }
  const charge = indicator === 'true';
  const what = `${charge ? 'a charge' : 'an allowance'} of ${where}`;
  return {
    charge,
    amount: requiredAmount(element, `the amount of ${what}`, 'ActualAmount'),
    baseAmount: amount(element, `the base of ${what}`, 'BasisAmount'),
    percent: amount(element, `the percentage of ${what}`, 'CalculationPercent'),
    reason: text(element, 'Reason'),
    reasonCode: text(element, 'ReasonCode'),
    vatCategory: onLine ? null : text(element, 'CategoryTradeTax', 'CategoryCode'),
    vatRate: onLine ? null : amount(element, `the VAT rate of ${what}`, 'CategoryTradeTax', 'RateApplicablePercent'),
  };
}

function line(reader: Reader, element: XmlElement, position: number): ReceivedLine {
  const document = find(element, ['AssociatedDocumentLineDocument']);
  const id = text(document, 'LineID');
  if (id === null) throw new InvoiceFileError('missing_element', `line ${position} has no identifier (BT-126)`);
  const where = `line ${id}`;
  const product = find(element, ['SpecifiedTradeProduct']);
  const agreement = find(element, ['SpecifiedLineTradeAgreement']);
  const gross = find(agreement, ['GrossPriceProductTradePrice']);
  const net = find(agreement, ['NetPriceProductTradePrice']);
  const settlement = find(element, ['SpecifiedLineTradeSettlement']);
  const tax = find(settlement, ['ApplicableTradeTax']);
  const quantity = find(element, ['SpecifiedLineTradeDelivery', 'BilledQuantity']);
  // BT-149 and BT-150 are written on the net price, and may be on the gross one.
  const baseQuantity = find(net, ['BasisQuantity']) ?? find(gross, ['BasisQuantity']);
  const summation = find(settlement, ['SpecifiedTradeSettlementLineMonetarySummation']);
  return {
    id,
    note: text(document, 'IncludedNote', 'Content'),
    quantity: quantity === undefined || quantity.text.trim() === '' ? null : decimalText(quantity.text, `the quantity of ${where}`),
    unitCode: attribute(quantity, 'unitCode'),
    netAmount: requiredAmount(summation, `the net amount of ${where}`, 'LineTotalAmount'),
    orderLineReference: text(agreement, 'BuyerOrderReferencedDocument', 'LineID'),
    period: reader.period(find(settlement, ['BillingSpecifiedPeriod']), where),
    allowances: all(settlement, 'SpecifiedTradeAllowanceCharge').map((each) => allowanceCharge(each, where, true)),
    netPrice: amount(net, `the net price of ${where}`, 'ChargeAmount'),
    priceDiscount: amount(gross, `the price discount of ${where}`, 'AppliedTradeAllowanceCharge', 'ActualAmount'),
    grossPrice: amount(gross, `the gross price of ${where}`, 'ChargeAmount'),
    priceBaseQuantity:
      baseQuantity === undefined || baseQuantity.text.trim() === ''
        ? null
        : decimalText(baseQuantity.text, `the base quantity of the price of ${where}`),
    priceBaseUnitCode: attribute(baseQuantity, 'unitCode'),
    vatCategory: text(tax, 'CategoryCode'),
    vatRate: amount(tax, `the VAT rate of ${where}`, 'RateApplicablePercent'),
    name: text(product, 'Name'),
    description: text(product, 'Description'),
    sellerItemId: text(product, 'SellerAssignedID'),
    buyerItemId: text(product, 'BuyerAssignedID'),
    standardItemId: identifier(find(product, ['GlobalID'])),
  };
}

function paymentMeans(
  reader: Reader,
  element: XmlElement,
  reference: string | null,
  mandateReference: string | null,
): ReceivedPaymentMeans {
  const payee = find(element, ['PayeePartyCreditorFinancialAccount']);
  const payeeIban = text(payee, 'IBANID');
  const proprietary = text(payee, 'ProprietaryID');
  return {
    code: text(element, 'TypeCode'),
    text: text(element, 'Information'),
    reference,
    account:
      payeeIban !== null
        ? reader.iban(payeeIban, 'The account to pay')
        : proprietary === null
          ? null
          : { kind: 'other', value: proprietary },
    accountName: text(payee, 'AccountName'),
    bic: text(element, 'PayeeSpecifiedCreditorFinancialInstitution', 'BICID'),
    cardNumber: text(element, 'ApplicableTradeSettlementFinancialCard', 'ID'),
    mandateReference,
    debitedAccount: reader.iban(text(element, 'PayerPartyDebtorFinancialAccount', 'IBANID'), 'The account to debit'),
  };
}

/**
 * Reads the XML of a Factur-X or ZUGFeRD invoice: a CII D16B
 * `CrossIndustryInvoice`, whatever its profile. To read it out of the PDF,
 * `readFacturX` of `@ekwo-ai/factur-x/pdf`.
 *
 * Throws an {@link InvoiceFileError} when there is no invoice to return: the
 * bytes are not XML or not UTF-8, the document is not CII, or it lacks a
 * number, a type code, a date, a currency or its totals, or holds an amount
 * or a date that is not one. Everything else comes back, with `violations`
 * naming what does not add up.
 *
 * Whether the document is a credit note is said by its type code (BT-3)
 * alone, as CII has a single root for both; the figures stay as written.
 */
export function readCii(input: string | Uint8Array, options: ReadOptions = {}): ReceivedCiiFile {
  const limits = { ...DEFAULTS, ...options };
  const root = parseXml(input, limits);
  if (root.namespace === NS.ublInvoice || root.namespace === NS.ublCreditNote) {
    throw new InvoiceFileError('not_an_invoice', 'the file is a UBL invoice (Peppol), not CII: read it with the UBL reader');
  }
  if (root.name !== 'CrossIndustryInvoice' || root.namespace !== NS.rsm) {
    throw new InvoiceFileError(
      'not_an_invoice',
      `the document is <${root.name}> in ${root.namespace === '' ? 'no namespace' : root.namespace}, not a CII D16B CrossIndustryInvoice`,
    );
  }

  const reader = new Reader();
  const context = find(root, ['ExchangedDocumentContext']);
  const exchanged = find(root, ['ExchangedDocument']);
  if (exchanged === undefined) throw new InvoiceFileError('missing_element', 'the document has no header (ExchangedDocument)');
  const transaction = find(root, ['SupplyChainTradeTransaction']);
  const agreement = find(transaction, ['ApplicableHeaderTradeAgreement']);
  const delivery = find(transaction, ['ApplicableHeaderTradeDelivery']);
  const settlement = find(transaction, ['ApplicableHeaderTradeSettlement']);
  if (settlement === undefined) {
    throw new InvoiceFileError('missing_element', 'the document has no settlement (ApplicableHeaderTradeSettlement)');
  }

  const guideline = text(context, 'GuidelineSpecifiedDocumentContextParameter', 'ID');
  const typeCode = required(exchanged, 'type code (BT-3)', 'TypeCode');
  const number = required(exchanged, 'number', 'ID');
  const issueDate = reader.date(find(exchanged, ['IssueDateTime']), 'the issue date');
  if (issueDate === null) throw new InvoiceFileError('missing_element', 'the document has no issue date (IssueDateTime)');
  const currency = required(settlement, 'currency', 'InvoiceCurrencyCode');
  const taxCurrency = text(settlement, 'TaxCurrencyCode');

  // BT-110 and BT-111 are both TaxTotalAmount, told apart by their currency.
  const summation = find(settlement, ['SpecifiedTradeSettlementHeaderMonetarySummation']);
  if (summation === undefined) {
    throw new InvoiceFileError('missing_element', 'the document has no totals (SpecifiedTradeSettlementHeaderMonetarySummation)');
  }
  const taxTotals = all(summation, 'TaxTotalAmount');
  const inCurrency = (each: XmlElement, code: string | null): boolean => {
    const written = attribute(each, 'currencyID');
    return written === null ? code === currency : written === code;
  };
  const documentTax = taxTotals.find((each) => inCurrency(each, currency)) ?? (taxCurrency === null ? taxTotals[0] : undefined);
  const taxCurrencyTax =
    taxCurrency !== null && taxCurrency !== currency
      ? taxTotals.find((each) => each !== documentTax && inCurrency(each, taxCurrency))
      : undefined;
  const totalOf = (element: XmlElement | undefined, what: string): string | null =>
    element === undefined || element.text.trim() === '' ? null : decimalText(element.text, what);

  const taxes: ReceivedTax[] = all(settlement, 'ApplicableTradeTax').map((group) => {
    const label = `the VAT group ${text(group, 'CategoryCode') ?? '?'} ${text(group, 'RateApplicablePercent') ?? ''}`.trim();
    return {
      category: text(group, 'CategoryCode'),
      rate: amount(group, `the rate of ${label}`, 'RateApplicablePercent'),
      base: requiredAmount(group, `the base of ${label}`, 'BasisAmount'),
      tax: requiredAmount(group, `the tax of ${label}`, 'CalculatedAmount'),
      exemptionReasonCode: text(group, 'ExemptionReasonCode'),
      exemptionReason: text(group, 'ExemptionReason'),
    };
  });
  // BT-7 is written on the VAT breakdown in CII, once per group and the same in each.
  const taxPointDate =
    all(settlement, 'ApplicableTradeTax')
      .map((group) => reader.date(find(group, ['TaxPointDate']), 'the tax point date'))
      .find((each) => each !== null) ?? null;

  // BG-24 is an additional document of type 916; type 130 is an invoiced
  // object (BT-18) and type 50 a tender or lot (BT-17), neither an attachment.
  const attachments: ReceivedAttachment[] = [];
  for (const reference of all(agreement, 'AdditionalReferencedDocument')) {
    const documentType = text(reference, 'TypeCode');
    if (documentType === '130' || documentType === '50') continue;
    const embedded = find(reference, ['AttachmentBinaryObject']);
    let content: Uint8Array | null = null;
    if (embedded !== undefined) {
      content = decodeBase64(embedded.text);
      if (content === null) {
        reader.violations.push({
          code: 'invalid_attachment',
          message: `The document ${text(reference, 'IssuerAssignedID') ?? 'attached'} is not base64, and was not decoded.`,
        });
      }
    }
    attachments.push({
      id: text(reference, 'IssuerAssignedID'),
      description: text(reference, 'Name'),
      filename: attribute(embedded, 'filename'),
      mimeType: attribute(embedded, 'mimeCode'),
      content,
      uri: text(reference, 'URIID'),
    });
  }

  // BT-9, BT-20 and BT-89 are in the payment terms; BT-83 is one reference for
  // the document. Each is returned on every means of payment, as UBL has them.
  const terms = all(settlement, 'SpecifiedTradePaymentTerms');
  const dueDate = terms.map((each) => reader.date(find(each, ['DueDateDateTime']), 'the due date')).find((each) => each !== null) ?? null;
  const descriptions = terms.map((each) => text(each, 'Description')).filter((each): each is string => each !== null);
  const mandate = terms.map((each) => text(each, 'DirectDebitMandateID')).find((each) => each !== null) ?? null;
  const paymentReference = text(settlement, 'PaymentReference');

  const shipTo = find(delivery, ['ShipToTradeParty']);
  const profile = profileOf(guideline);
  const lineElements = all(transaction, 'IncludedSupplyChainTradeLineItem');
  if (lineElements.length === 0 && profile !== 'minimum' && profile !== 'basic-wl') {
    throw new InvoiceFileError('missing_element', 'the document has no line, and its profile is not one that carries none (MINIMUM, BASIC WL)');
  }

  const invoice: ReceivedInvoice = {
    syntax: 'cii',
    customizationId: guideline,
    profileId: text(context, 'BusinessProcessSpecifiedDocumentContextParameter', 'ID'),
    kind: CREDIT_NOTE_TYPE_CODES.has(typeCode) ? 'credit_note' : 'invoice',
    typeCode,
    number,
    issueDate,
    dueDate,
    taxPointDate,
    currency,
    taxCurrency,
    buyerReference: text(agreement, 'BuyerReference'),
    orderReference: text(agreement, 'BuyerOrderReferencedDocument', 'IssuerAssignedID'),
    salesOrderReference: text(agreement, 'SellerOrderReferencedDocument', 'IssuerAssignedID'),
    contractReference: text(agreement, 'ContractReferencedDocument', 'IssuerAssignedID'),
    projectReference: text(agreement, 'SpecifiedProcuringProject', 'ID'),
    accountingCost: text(settlement, 'ReceivableSpecifiedTradeAccountingAccount', 'ID'),
    precedingInvoices: all(settlement, 'InvoiceReferencedDocument')
      .filter((each) => text(each, 'IssuerAssignedID') !== null)
      .map((each) => ({
        number: text(each, 'IssuerAssignedID') as string,
        issueDate: reader.date(find(each, ['FormattedIssueDateTime']), 'the date of a preceding invoice'),
      })),
    notes: all(exchanged, 'IncludedNote')
      .map((each) => text(each, 'Content'))
      .filter((each): each is string => each !== null),
    seller: party(find(agreement, ['SellerTradeParty']), 'seller'),
    buyer: party(find(agreement, ['BuyerTradeParty']), 'buyer'),
    deliveryDate: reader.date(find(delivery, ['ActualDeliverySupplyChainEvent', 'OccurrenceDateTime']), 'the delivery date'),
    deliveryAddress: address(find(shipTo, ['PostalTradeAddress'])),
    invoicingPeriod: reader.period(find(settlement, ['BillingSpecifiedPeriod']), 'the invoicing period'),
    paymentTerms: descriptions.length === 0 ? null : descriptions.join('\n'),
    paymentMeans: all(settlement, 'SpecifiedTradeSettlementPaymentMeans').map((each) =>
      paymentMeans(reader, each, paymentReference, mandate),
    ),
    allowances: all(settlement, 'SpecifiedTradeAllowanceCharge').map((each) => allowanceCharge(each, 'the document', false)),
    taxes,
    totals: {
      lineTotal: amount(summation, 'the sum of the lines', 'LineTotalAmount'),
      allowanceTotal: amount(summation, 'the sum of the allowances', 'AllowanceTotalAmount'),
      chargeTotal: amount(summation, 'the sum of the charges', 'ChargeTotalAmount'),
      taxExclusive: requiredAmount(summation, 'the total without VAT', 'TaxBasisTotalAmount'),
      taxTotal: totalOf(documentTax, 'the total VAT'),
      taxTotalInTaxCurrency: totalOf(taxCurrencyTax, 'the total VAT in the tax currency'),
      taxInclusive: requiredAmount(summation, 'the total with VAT', 'GrandTotalAmount'),
      prepaid: amount(summation, 'the amount paid', 'TotalPrepaidAmount'),
      rounding: amount(summation, 'the rounding amount', 'RoundingAmount'),
      payable: requiredAmount(summation, 'the amount due', 'DuePayableAmount'),
    },
    lines: lineElements.map((each, index) => line(reader, each, index + 1)),
    attachments,
  };

  return { invoice, violations: [...reader.violations, ...checkReceived(invoice)], profile };
}
