/**
 * The model, printed as UBL 2.1.
 *
 * The order of the elements is the order of the OASIS schema, which is a
 * sequence and refuses anything else — and it is not the same order in an
 * invoice and in a credit note, which is why the two are written apart rather
 * than from one template with the word replaced. `test/schema.test.ts`
 * validates both against the published schema.
 *
 * Nothing is written empty. An element with nothing in it is a rule broken
 * (PEPPOL-EN16931-R008), so an absent value is an absent element.
 */

import { type Decimal, formatDecimal, isZero } from './decimal.js';
import type { DocumentModel, LineModel, PartyModel, SubtotalModel } from './model.js';

/** BT-24: what the file claims to conform to. */
export const CUSTOMIZATION_ID = 'urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0';
/** BT-23: the one business process Peppol BIS Billing 3.0 defines. */
export const PROFILE_ID = 'urn:fdc:peppol.eu:2017:poacc:billing:01:1.0';

const NAMESPACES = {
  Invoice: 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2',
  CreditNote: 'urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2',
  cac: 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2',
  cbc: 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2',
} as const;

export function escapeXml(value: string): string {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

type Node = string | null;

/** `<name attrs>text</name>`, or nothing where there is no text. */
function leaf(name: string, value: string | null, attributes: Record<string, string | null> = {}): Node {
  if (value === null || value === '') return null;
  const attrs = Object.entries(attributes)
    .filter((entry): entry is [string, string] => entry[1] !== null && entry[1] !== '')
    .map(([key, text]) => ` ${key}="${escapeXml(text)}"`)
    .join('');
  return `<${name}${attrs}>${escapeXml(value)}</${name}>`;
}

/** `<name>children</name>`, indented, or nothing where there are no children. */
function group(name: string, children: Node[]): Node {
  const present = children.filter((child): child is string => child !== null);
  if (present.length === 0) return null;
  const body = present.map((child) => child.replace(/^/gm, '  ')).join('\n');
  return `<${name}>\n${body}\n</${name}>`;
}

/**
 * An amount, with its currency. Two decimals at least, because that is how the
 * standard writes an amount; more where more were given, because a digit is not
 * dropped here — the rule it breaks is reported instead (BR-DEC-*).
 */
function money(name: string, value: Decimal | null, currency: string): Node {
  return value === null ? null : leaf(name, formatDecimal(value, 2), { currencyID: currency });
}

const vatScheme = group('cac:TaxScheme', [leaf('cbc:ID', 'VAT')]);

function party(model: PartyModel): Node {
  const a = model.address;
  return group('cac:Party', [
    model.endpoint ? leaf('cbc:EndpointID', model.endpoint.id, { schemeID: model.endpoint.scheme }) : null,
    group('cac:PartyName', [leaf('cbc:Name', model.tradeName)]),
    a &&
      group('cac:PostalAddress', [
        leaf('cbc:StreetName', a.line1),
        leaf('cbc:AdditionalStreetName', a.line2),
        leaf('cbc:CityName', a.city),
        leaf('cbc:PostalZone', a.postalCode),
        leaf('cbc:CountrySubentity', a.region),
        group('cac:Country', [leaf('cbc:IdentificationCode', a.country)]),
      ]),
    model.vatId === null ? null : group('cac:PartyTaxScheme', [leaf('cbc:CompanyID', model.vatId), vatScheme]),
    group('cac:PartyLegalEntity', [
      leaf('cbc:RegistrationName', model.registrationName),
      leaf('cbc:CompanyID', model.legalId, { schemeID: model.legalIdScheme }),
      leaf('cbc:CompanyLegalForm', model.legalForm),
    ]),
    model.contact &&
      group('cac:Contact', [leaf('cbc:Telephone', model.contact.phone), leaf('cbc:ElectronicMail', model.contact.email)]),
  ]);
}

/** The rate of a category, where the category has one: outside the scope of VAT there is none (BR-O-05). */
function percent(category: string | null, rate: Decimal | null): Node {
  if (rate === null) return null;
  if (category === 'O' && isZero(rate)) return null;
  return leaf('cbc:Percent', formatDecimal(rate));
}

function subtotal(model: SubtotalModel, currency: string): Node {
  return group('cac:TaxSubtotal', [
    money('cbc:TaxableAmount', model.base, currency),
    money('cbc:TaxAmount', model.tax, currency),
    group('cac:TaxCategory', [
      leaf('cbc:ID', model.category),
      percent(model.category, model.rate),
      leaf('cbc:TaxExemptionReasonCode', model.reasonCode),
      leaf('cbc:TaxExemptionReason', model.reason),
      vatScheme,
    ]),
  ]);
}

function line(model: LineModel, kind: DocumentModel['kind'], currency: string): Node {
  const quantity = kind === 'Invoice' ? 'cbc:InvoicedQuantity' : 'cbc:CreditedQuantity';
  return group(kind === 'Invoice' ? 'cac:InvoiceLine' : 'cac:CreditNoteLine', [
    leaf('cbc:ID', model.id),
    model.quantity === null ? null : leaf(quantity, formatDecimal(model.quantity), { unitCode: model.unitCode }),
    money('cbc:LineExtensionAmount', model.netAmount, currency),
    group('cac:Item', [
      leaf('cbc:Description', model.description),
      leaf('cbc:Name', model.name),
      group('cac:SellersItemIdentification', [leaf('cbc:ID', model.sellerItemId)]),
      group('cac:ClassifiedTaxCategory', [
        leaf('cbc:ID', model.category),
        percent(model.category, model.rate),
        model.category === null ? null : vatScheme,
      ]),
    ]),
    model.netPrice === null
      ? null
      : group('cac:Price', [
          leaf('cbc:PriceAmount', formatDecimal(model.netPrice), { currencyID: currency }),
          model.grossPrice !== null && model.priceDiscount !== null
            ? group('cac:AllowanceCharge', [
                leaf('cbc:ChargeIndicator', 'false'),
                leaf('cbc:Amount', formatDecimal(model.priceDiscount), { currencyID: currency }),
                leaf('cbc:BaseAmount', formatDecimal(model.grossPrice), { currencyID: currency }),
              ])
            : null,
        ]),
  ]);
}

export function writeUbl(model: DocumentModel): string {
  const { kind, currency } = model;
  const invoice = kind === 'Invoice';

  const delivery =
    model.delivery &&
    group('cac:Delivery', [
      leaf('cbc:ActualDeliveryDate', model.delivery.date),
      model.delivery.address &&
        group('cac:DeliveryLocation', [
          group('cac:Address', [
            leaf('cbc:StreetName', model.delivery.address.line1),
            leaf('cbc:CityName', model.delivery.address.city),
            leaf('cbc:PostalZone', model.delivery.address.postalCode),
            group('cac:Country', [leaf('cbc:IdentificationCode', model.delivery.address.country)]),
          ]),
        ]),
    ]);

  const payment =
    model.payment &&
    group('cac:PaymentMeans', [
      leaf('cbc:PaymentMeansCode', model.payment.meansCode),
      // A credit note has no due date of its own in UBL 2.1; BT-9 lives here.
      invoice ? null : leaf('cbc:PaymentDueDate', model.dueDate),
      leaf('cbc:PaymentID', model.payment.reference),
      model.payment.iban === null
        ? null
        : group('cac:PayeeFinancialAccount', [
            leaf('cbc:ID', model.payment.iban),
            group('cac:FinancialInstitutionBranch', [leaf('cbc:ID', model.payment.bic)]),
          ]),
    ]);

  const billingReference =
    model.preceding &&
    group('cac:BillingReference', [
      group('cac:InvoiceDocumentReference', [
        leaf('cbc:ID', model.preceding.number),
        leaf('cbc:IssueDate', model.preceding.issueDate),
      ]),
    ]);

  // BT-11 has an element of its own in an invoice. A credit note has none in
  // UBL 2.1, and carries it as an additional document of type 50.
  const project = invoice
    ? group('cac:ProjectReference', [leaf('cbc:ID', model.projectReference)])
    : model.projectReference === null
      ? null
      : group('cac:AdditionalDocumentReference', [
          leaf('cbc:ID', model.projectReference),
          leaf('cbc:DocumentTypeCode', '50'),
        ]);

  const head: Node[] = invoice
    ? [
        leaf('cbc:CustomizationID', CUSTOMIZATION_ID),
        leaf('cbc:ProfileID', PROFILE_ID),
        leaf('cbc:ID', model.number),
        leaf('cbc:IssueDate', model.issueDate),
        leaf('cbc:DueDate', model.dueDate),
        leaf('cbc:InvoiceTypeCode', model.typeCode),
        leaf('cbc:Note', model.note),
        leaf('cbc:TaxPointDate', model.taxPointDate),
        leaf('cbc:DocumentCurrencyCode', currency),
        leaf('cbc:BuyerReference', model.buyerReference),
      ]
    : [
        leaf('cbc:CustomizationID', CUSTOMIZATION_ID),
        leaf('cbc:ProfileID', PROFILE_ID),
        leaf('cbc:ID', model.number),
        leaf('cbc:IssueDate', model.issueDate),
        leaf('cbc:TaxPointDate', model.taxPointDate),
        leaf('cbc:CreditNoteTypeCode', model.typeCode),
        leaf('cbc:Note', model.note),
        leaf('cbc:DocumentCurrencyCode', currency),
        leaf('cbc:BuyerReference', model.buyerReference),
      ];

  const body = group(kind, [
    ...head,
    group('cac:OrderReference', [leaf('cbc:ID', model.orderReference)]),
    billingReference,
    group('cac:ContractDocumentReference', [leaf('cbc:ID', model.contractReference)]),
    // In both schemas the additional documents come before the project.
    project,
    group('cac:AccountingSupplierParty', [party(model.seller)]),
    group('cac:AccountingCustomerParty', [party(model.buyer)]),
    delivery,
    payment,
    group('cac:PaymentTerms', [leaf('cbc:Note', model.paymentTerms)]),
    // The total VAT is the books' figure and is written with or without a
    // breakdown under it; a document without one is reported, not tidied.
    group('cac:TaxTotal', [
      money('cbc:TaxAmount', model.taxTotal, currency),
      ...model.subtotals.map((each) => subtotal(each, currency)),
    ]),
    group('cac:LegalMonetaryTotal', [
      money('cbc:LineExtensionAmount', model.lineTotal, currency),
      money('cbc:TaxExclusiveAmount', model.taxExclusive, currency),
      money('cbc:TaxInclusiveAmount', model.taxInclusive, currency),
      money('cbc:PrepaidAmount', model.prepaid, currency),
      money('cbc:PayableAmount', model.payable, currency),
    ]),
    ...model.lines.map((each) => line(each, kind, currency)),
  ]) as string;

  const root = `<${kind} xmlns="${NAMESPACES[kind]}" xmlns:cac="${NAMESPACES.cac}" xmlns:cbc="${NAMESPACES.cbc}">`;
  return `<?xml version="1.0" encoding="UTF-8"?>\n${body.replace(`<${kind}>`, root)}\n`;
}
