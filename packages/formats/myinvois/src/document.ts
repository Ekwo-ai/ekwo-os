/**
 * The model, as the tree of a MyInvois document.
 *
 * The elements are the ones the SDK's data structure maps, at the paths it
 * maps them to, in the order of the OASIS UBL 2.1 schema — which is a
 * sequence and refuses anything else. `test/schema.test.ts` validates the XML
 * against that schema; the JSON is the same tree.
 *
 * The signature (`ext:UBLExtensions` and `cac:Signature`) is not written:
 * version 1.1 is signed by the host, after this package and before the
 * submission.
 */

import { type Decimal, formatDecimal } from './decimal.js';
import type { AddressModel, DocumentModel, LineModel, PartyModel, TaxGroupModel } from './model.js';
import { RINGGIT } from './model.js';
import { type UblElement, group, leaf, textOf } from './tree.js';

/** An amount with its currency, with two decimals at least and every digit given. */
const money = (name: string, value: Decimal | null, currency: string) =>
  value === null ? null : leaf(name, { decimal: formatDecimal(value, 2) }, { currencyID: currency });

const number = (name: string, value: Decimal | null, attributes: Record<string, string | null> = {}) =>
  value === null ? null : leaf(name, { decimal: formatDecimal(value) }, attributes);

/** MyInvois carries no value added tax: every tax is in the scheme "other taxes" of UN/ECE 5153. */
const taxScheme = group('TaxScheme', [leaf('ID', { text: 'OTH' }, { schemeID: 'UN/ECE 5153', schemeAgencyID: '6' })]);

function address(model: AddressModel) {
  return group('PostalAddress', [
    leaf('CityName', textOf(model.city)),
    leaf('PostalZone', textOf(model.postalCode)),
    leaf('CountrySubentityCode', textOf(model.state)),
    ...model.lines.map((line) => group('AddressLine', [leaf('Line', { text: line })])),
    group('Country', [leaf('IdentificationCode', textOf(model.country), { listID: 'ISO3166-1', listAgencyID: '6' })]),
  ]);
}

function party(model: PartyModel) {
  const id = (value: string | null, scheme: string) =>
    value === null ? null : group('PartyIdentification', [leaf('ID', { text: value }, { schemeID: scheme })]);
  return group('Party', [
    model.activity === null
      ? null
      : leaf('IndustryClassificationCode', { text: model.activity.msic }, { name: model.activity.description }),
    id(model.tin, 'TIN'),
    model.registration === null ? null : id(model.registration.id, model.registration.scheme),
    id(model.sst, 'SST'),
    model.role === 'supplier' ? id(model.tourismTax, 'TTX') : null,
    address(model.address),
    group('PartyLegalEntity', [leaf('RegistrationName', textOf(model.name))]),
    group('Contact', [leaf('Telephone', textOf(model.phone)), leaf('ElectronicMail', textOf(model.email))]),
  ]);
}

function category(type: string | null, reason: string | null) {
  return group('TaxCategory', [
    leaf('ID', textOf(type)),
    type === 'E' ? leaf('TaxExemptionReason', textOf(reason)) : null,
    taxScheme,
  ]);
}

/**
 * A subtotal of the breakdown: its base in the document's currency, its tax
 * in the tax currency where the document has one — LHDNM's foreign currency
 * sample writes them so.
 */
function subtotal(model: TaxGroupModel, currency: string, taxCurrency: string | null) {
  return group('TaxSubtotal', [
    money('TaxableAmount', model.base, currency),
    taxCurrency === null ? money('TaxAmount', model.tax, currency) : money('TaxAmount', model.taxInTaxCurrency, taxCurrency),
    category(model.type, model.reason),
  ]);
}

function line(model: LineModel, currency: string, taxCurrency: string | null) {
  const tax = model.tax;
  const taxAmount = taxCurrency === null ? money('TaxAmount', tax.amount, currency) : money('TaxAmount', tax.amountInTaxCurrency, taxCurrency);
  return group('InvoiceLine', [
    leaf('ID', { text: model.id }),
    number('InvoicedQuantity', model.quantity, { unitCode: model.unitCode }),
    money('LineExtensionAmount', model.net, currency),
    model.discount === null
      ? null
      : group('AllowanceCharge', [
          leaf('ChargeIndicator', { indicator: false }),
          number('MultiplierFactorNumeric', model.discount.rate),
          money('Amount', model.discount.amount, currency),
        ]),
    group('TaxTotal', [
      taxAmount,
      group('TaxSubtotal', [
        money('TaxableAmount', tax.base, currency),
        taxAmount,
        number('Percent', tax.rate),
        category(tax.type, tax.reason),
      ]),
    ]),
    group('Item', [
      leaf('Description', textOf(model.description)),
      ...model.classifications.map((code) =>
        group('CommodityClassification', [leaf('ItemClassificationCode', { text: code }, { listID: 'CLASS' })]),
      ),
    ]),
    group('Price', [money('PriceAmount', model.price, currency)]),
    group('ItemPriceExtension', [money('Amount', model.subtotal, currency)]),
  ]);
}

export function documentOf(model: DocumentModel): UblElement[] {
  const { currency } = model;
  const elements = [
    leaf('ID', { text: model.number }),
    leaf('IssueDate', { text: model.issueDate }),
    leaf('IssueTime', { text: model.issueTime }),
    leaf('InvoiceTypeCode', { text: model.typeCode }, { listVersionID: model.version }),
    leaf('DocumentCurrencyCode', { text: currency }),
    model.taxCurrency === null ? null : leaf('TaxCurrencyCode', { text: model.taxCurrency }),
    ...model.adjusts.map((each) =>
      group('BillingReference', [
        group('InvoiceDocumentReference', [leaf('ID', textOf(each.number)), leaf('UUID', textOf(each.uuid))]),
      ]),
    ),
    group('BillingReference', [group('AdditionalDocumentReference', [leaf('ID', textOf(model.billReference))])]),
    group('AccountingSupplierParty', [party(model.supplier)]),
    group('AccountingCustomerParty', [party(model.buyer)]),
    model.paymentMode === null
      ? null
      : group('PaymentMeans', [
          leaf('PaymentMeansCode', { text: model.paymentMode }),
          group('PayeeFinancialAccount', [leaf('ID', textOf(model.account))]),
        ]),
    group('PaymentTerms', [leaf('Note', textOf(model.paymentTerms))]),
    model.exchangeRate === null
      ? null
      : group('TaxExchangeRate', [
          leaf('SourceCurrencyCode', { text: currency }),
          leaf('TargetCurrencyCode', { text: RINGGIT }),
          number('CalculationRate', model.exchangeRate),
        ]),
    group('TaxTotal', [
      model.taxCurrency === null
        ? money('TaxAmount', model.taxTotal, currency)
        : money('TaxAmount', model.taxTotalInTaxCurrency, model.taxCurrency),
      ...model.groups.map((each) => subtotal(each, currency, model.taxCurrency)),
    ]),
    // There is no allowance or charge on the document in the books, so the
    // sum of the lines and the total excluding tax are one figure, and the
    // amount payable is the total including tax: what was paid since is a
    // payment, not a prepayment the document records.
    group('LegalMonetaryTotal', [
      money('LineExtensionAmount', model.taxExclusive, currency),
      money('TaxExclusiveAmount', model.taxExclusive, currency),
      money('TaxInclusiveAmount', model.taxInclusive, currency),
      money('PayableAmount', model.taxInclusive, currency),
    ]),
    ...model.lines.map((each) => line(each, currency, model.taxCurrency)),
  ];
  return elements.filter((element): element is UblElement => element !== null);
}
