/**
 * Cross Industry Invoice (CII, UN/CEFACT D16B) XML for Factur-X / ZUGFeRD,
 * following the element order of the EN 16931 schema and its business rules
 * for VAT breakdowns.
 */
import type { DocumentType, GenerateOptions, Invoice, Party, Profile } from './types.js';
import { computeTotals, lineNetAmount, lineVatCategory } from './totals.js';
import { toUnitCode } from './units.js';
import { DEFAULT_EXEMPTION_REASONS, EXEMPTION_REASON_CODES, EXEMPT_CATEGORIES } from './vat.js';

/** Guideline identifiers (BT-24) per conformance level. */
export const GUIDELINES: Readonly<Record<Profile, string>> = {
  minimum: 'urn:factur-x.eu:1p0:minimum',
  'basic-wl': 'urn:factur-x.eu:1p0:basicwl',
  basic: 'urn:cen.eu:en16931:2017#compliant#urn:factur-x.eu:1p0:basic',
  en16931: 'urn:cen.eu:en16931:2017',
  extended: 'urn:cen.eu:en16931:2017#conformant#urn:factur-x.eu:1p0:extended',
};

/** UNTDID 1001 document type codes (BT-3). */
export const DOCUMENT_TYPE_CODES: Readonly<Record<DocumentType, string>> = {
  invoice: '380',
  'credit-note': '381',
  'corrected-invoice': '384',
  'self-billed-invoice': '389',
  'prepayment-invoice': '386',
};

export function escapeXml(s: string): string {
  return s
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;');
}

const amount = (n: number) => n.toFixed(2);
const quantity = (n: number) => n.toFixed(4);
const ymd = (iso: string) => iso.replace(/-/g, '').slice(0, 8);
const date102 = (iso: string) => `<udt:DateTimeString format="102">${ymd(iso)}</udt:DateTimeString>`;
const tag = (name: string, value: string | undefined | null) => (value ? `<${name}>${escapeXml(value)}</${name}>` : '');

/** The profiles that carry the whole EN 16931 model; the ones below it are subsets. */
const carriesEn16931 = (profile: Profile) => profile === 'en16931' || profile === 'extended';
/** MINIMUM and BASIC WL ("without lines") describe the document and its totals only. */
const carriesLines = (profile: Profile) => profile !== 'minimum' && profile !== 'basic-wl';

function partyXml(name: 'SellerTradeParty' | 'BuyerTradeParty', party: Party, profile: Profile): string {
  const a = party.address;
  const legal = party.legalId
    ? `<ram:SpecifiedLegalOrganization><ram:ID${party.legalId.scheme ? ` schemeID="${escapeXml(party.legalId.scheme)}"` : ''}>${escapeXml(party.legalId.value.replace(/\s/g, ''))}</ram:ID></ram:SpecifiedLegalOrganization>`
    : '';
  const contact =
    carriesEn16931(profile)
      ? party.contact
        ? `<ram:DefinedTradeContact>${tag('ram:PersonName', party.contact.name)}${
            party.contact.phone ? `<ram:TelephoneUniversalCommunication>${tag('ram:CompleteNumber', party.contact.phone)}</ram:TelephoneUniversalCommunication>` : ''
          }${party.contact.email ? `<ram:EmailURIUniversalCommunication>${tag('ram:URIID', party.contact.email)}</ram:EmailURIUniversalCommunication>` : ''}</ram:DefinedTradeContact>`
        : ''
      : '';
  // MINIMUM names a party, its identifiers and its country, nothing more.
  const minimum = profile === 'minimum';
  const electronic = party.electronicAddress && !minimum
    ? `<ram:URIUniversalCommunication><ram:URIID schemeID="${escapeXml(party.electronicAddress.scheme)}">${escapeXml(party.electronicAddress.value)}</ram:URIID></ram:URIUniversalCommunication>`
    : '';
  const vat = party.vatId
    ? `<ram:SpecifiedTaxRegistration><ram:ID schemeID="VA">${escapeXml(party.vatId.replace(/\s/g, ''))}</ram:ID></ram:SpecifiedTaxRegistration>`
    : '';
  return `<ram:${name}>
        ${tag('ram:Name', party.name)}
        ${legal}${contact}
        <ram:PostalTradeAddress>
          ${minimum ? '' : tag('ram:PostcodeCode', a.postalCode)}
          ${minimum ? '' : tag('ram:LineOne', a.line1)}
          ${minimum ? '' : tag('ram:LineTwo', a.line2)}
          ${minimum ? '' : tag('ram:LineThree', a.line3)}
          ${minimum ? '' : tag('ram:CityName', a.city)}
          <ram:CountryID>${escapeXml(a.country.toUpperCase())}</ram:CountryID>
          ${minimum ? '' : tag('ram:CountrySubDivisionName', a.subdivision)}
        </ram:PostalTradeAddress>
        ${electronic}${vat}
      </ram:${name}>`;
}

/**
 * The CII XML document for an invoice, as a UTF-8 string ready to be
 * embedded as `factur-x.xml`.
 */
export function generateCiiXml(invoice: Invoice, options: GenerateOptions = {}): string {
  const profile = options.profile ?? 'basic';
  // MINIMUM is the header and four totals: the note, the delivery, the
  // payment, the VAT breakdown and the preceding invoice start at BASIC WL.
  const minimum = profile === 'minimum';
  // The currency (BT-5) is the caller's to state: no currency is assumed.
  if (typeof invoice.currency !== 'string' || !/^[A-Za-z]{3}$/.test(invoice.currency)) {
    throw new TypeError('invoice.currency is required: the ISO 4217 code of the invoice currency (BT-5), for example "CHF"');
  }
  const currency = invoice.currency.toUpperCase();
  const totals = computeTotals(invoice);
  const typeCode = DOCUMENT_TYPE_CODES[invoice.type ?? 'invoice'];

  // The seller's item identifier (BT-155) and the item description (BT-154)
  // belong to EN 16931: the BASIC schema admits the name and the global
  // identifier of a product only.
  const detailed = carriesEn16931(profile);
  const lines = (carriesLines(profile) ? invoice.lines : [])
    .map((line, i) => {
      const category = lineVatCategory(line, invoice);
      const rate = category === 'S' ? line.vatRate : 0;
      return `
    <ram:IncludedSupplyChainTradeLineItem>
      <ram:AssociatedDocumentLineDocument>
        <ram:LineID>${escapeXml(line.id ?? String(i + 1))}</ram:LineID>
        ${line.note ? `<ram:IncludedNote>${tag('ram:Content', line.note)}</ram:IncludedNote>` : ''}
      </ram:AssociatedDocumentLineDocument>
      <ram:SpecifiedTradeProduct>
        ${detailed ? tag('ram:SellerAssignedID', line.sellerItemId) : ''}
        ${tag('ram:Name', line.name)}
        ${detailed ? tag('ram:Description', line.description) : ''}
      </ram:SpecifiedTradeProduct>
      <ram:SpecifiedLineTradeAgreement>
        <ram:NetPriceProductTradePrice>
          <ram:ChargeAmount>${amount(line.unitPrice)}</ram:ChargeAmount>
        </ram:NetPriceProductTradePrice>
      </ram:SpecifiedLineTradeAgreement>
      <ram:SpecifiedLineTradeDelivery>
        <ram:BilledQuantity unitCode="${escapeXml(toUnitCode(line.unitCode))}">${quantity(line.quantity)}</ram:BilledQuantity>
      </ram:SpecifiedLineTradeDelivery>
      <ram:SpecifiedLineTradeSettlement>
        <ram:ApplicableTradeTax>
          <ram:TypeCode>VAT</ram:TypeCode>
          <ram:CategoryCode>${category}</ram:CategoryCode>
          ${category === 'O' ? '' : `<ram:RateApplicablePercent>${amount(rate)}</ram:RateApplicablePercent>`}
        </ram:ApplicableTradeTax>
        <ram:SpecifiedTradeSettlementLineMonetarySummation>
          <ram:LineTotalAmount>${amount(lineNetAmount(line))}</ram:LineTotalAmount>
        </ram:SpecifiedTradeSettlementLineMonetarySummation>
      </ram:SpecifiedLineTradeSettlement>
    </ram:IncludedSupplyChainTradeLineItem>`;
    })
    .join('');

  // Header VAT breakdown. Element order of the schema: CalculatedAmount,
  // TypeCode, ExemptionReason, BasisAmount, CategoryCode, ExemptionReasonCode,
  // DueDateTypeCode, RateApplicablePercent.
  const breakdown = totals.breakdown
    .map((g) => {
      const exempt = EXEMPT_CATEGORIES.has(g.category);
      const reason = exempt
        ? invoice.exemptionReasons?.[g.category as keyof typeof DEFAULT_EXEMPTION_REASONS] ??
          DEFAULT_EXEMPTION_REASONS[g.category as keyof typeof DEFAULT_EXEMPTION_REASONS]
        : undefined;
      const reasonCode = exempt ? EXEMPTION_REASON_CODES[g.category] : undefined;
      return `
      <ram:ApplicableTradeTax>
        <ram:CalculatedAmount>${amount(g.tax)}</ram:CalculatedAmount>
        <ram:TypeCode>VAT</ram:TypeCode>
        ${tag('ram:ExemptionReason', reason)}
        <ram:BasisAmount>${amount(g.basis)}</ram:BasisAmount>
        <ram:CategoryCode>${g.category}</ram:CategoryCode>
        ${tag('ram:ExemptionReasonCode', reasonCode)}
        ${g.category === 'O' ? '' : `<ram:RateApplicablePercent>${amount(g.rate)}</ram:RateApplicablePercent>`}
      </ram:ApplicableTradeTax>`;
    })
    .join('');

  const p = invoice.payment;
  const paymentMeans =
    !minimum && p && (p.iban || p.meansCode)
      ? `
      <ram:SpecifiedTradeSettlementPaymentMeans>
        <ram:TypeCode>${escapeXml(p.meansCode ?? '58')}</ram:TypeCode>
        ${p.iban ? `<ram:PayeePartyCreditorFinancialAccount><ram:IBANID>${escapeXml(p.iban.replace(/\s/g, ''))}</ram:IBANID></ram:PayeePartyCreditorFinancialAccount>` : ''}
        ${p.bic && carriesEn16931(profile) ? `<ram:PayeeSpecifiedCreditorFinancialInstitution><ram:BICID>${escapeXml(p.bic)}</ram:BICID></ram:PayeeSpecifiedCreditorFinancialInstitution>` : ''}
      </ram:SpecifiedTradeSettlementPaymentMeans>`
      : '';

  const paymentTerms =
    !minimum && (p?.terms || invoice.dueDate)
      ? `
      <ram:SpecifiedTradePaymentTerms>
        ${tag('ram:Description', p?.terms)}
        ${invoice.dueDate ? `<ram:DueDateDateTime>${date102(invoice.dueDate)}</ram:DueDateDateTime>` : ''}
      </ram:SpecifiedTradePaymentTerms>`
      : '';

  const preceding = invoice.precedingInvoice && !minimum
    ? `
      <ram:InvoiceReferencedDocument>
        ${tag('ram:IssuerAssignedID', invoice.precedingInvoice.number)}
        ${invoice.precedingInvoice.issueDate ? `<ram:FormattedIssueDateTime><qdt:DateTimeString format="102">${ymd(invoice.precedingInvoice.issueDate)}</qdt:DateTimeString></ram:FormattedIssueDateTime>` : ''}
      </ram:InvoiceReferencedDocument>`
    : '';

  const note = minimum ? '' : invoice.note?.replace(/\s+/g, ' ').trim();

  return `<?xml version="1.0" encoding="UTF-8"?>
<rsm:CrossIndustryInvoice xmlns:rsm="urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100" xmlns:qdt="urn:un:unece:uncefact:data:standard:QualifiedDataType:100" xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100" xmlns:udt="urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100">
  <rsm:ExchangedDocumentContext>
    <ram:BusinessProcessSpecifiedDocumentContextParameter>
      <ram:ID>${escapeXml(options.businessProcess ?? 'A1')}</ram:ID>
    </ram:BusinessProcessSpecifiedDocumentContextParameter>
    <ram:GuidelineSpecifiedDocumentContextParameter>
      <ram:ID>${GUIDELINES[profile]}</ram:ID>
    </ram:GuidelineSpecifiedDocumentContextParameter>
  </rsm:ExchangedDocumentContext>
  <rsm:ExchangedDocument>
    <ram:ID>${escapeXml(invoice.number)}</ram:ID>
    <ram:TypeCode>${typeCode}</ram:TypeCode>
    <ram:IssueDateTime>${date102(invoice.issueDate)}</ram:IssueDateTime>
    ${note ? `<ram:IncludedNote>${tag('ram:Content', note)}</ram:IncludedNote>` : ''}
  </rsm:ExchangedDocument>
  <rsm:SupplyChainTradeTransaction>${lines}
    <ram:ApplicableHeaderTradeAgreement>
      ${tag('ram:BuyerReference', invoice.buyerReference)}
      ${partyXml('SellerTradeParty', invoice.seller, profile)}
      ${partyXml('BuyerTradeParty', invoice.buyer, profile)}
      ${invoice.orderReference ? `<ram:BuyerOrderReferencedDocument>${tag('ram:IssuerAssignedID', invoice.orderReference)}</ram:BuyerOrderReferencedDocument>` : ''}
      ${invoice.contractReference && !minimum ? `<ram:ContractReferencedDocument>${tag('ram:IssuerAssignedID', invoice.contractReference)}</ram:ContractReferencedDocument>` : ''}
    </ram:ApplicableHeaderTradeAgreement>
    ${
      minimum
        ? '<ram:ApplicableHeaderTradeDelivery/>'
        : `<ram:ApplicableHeaderTradeDelivery>
      <ram:ActualDeliverySupplyChainEvent>
        <ram:OccurrenceDateTime>${date102(invoice.deliveryDate ?? invoice.issueDate)}</ram:OccurrenceDateTime>
      </ram:ActualDeliverySupplyChainEvent>
    </ram:ApplicableHeaderTradeDelivery>`
    }
    <ram:ApplicableHeaderTradeSettlement>
      ${minimum ? '' : tag('ram:PaymentReference', p?.reference)}
      <ram:InvoiceCurrencyCode>${escapeXml(currency)}</ram:InvoiceCurrencyCode>${paymentMeans}${minimum ? '' : breakdown}${paymentTerms}
      <ram:SpecifiedTradeSettlementHeaderMonetarySummation>
        ${minimum ? '' : `<ram:LineTotalAmount>${amount(totals.lineTotal)}</ram:LineTotalAmount>`}
        <ram:TaxBasisTotalAmount>${amount(totals.taxBasisTotal)}</ram:TaxBasisTotalAmount>
        <ram:TaxTotalAmount currencyID="${escapeXml(currency)}">${amount(totals.taxTotal)}</ram:TaxTotalAmount>
        <ram:GrandTotalAmount>${amount(totals.grandTotal)}</ram:GrandTotalAmount>
        ${totals.prepaid && !minimum ? `<ram:TotalPrepaidAmount>${amount(totals.prepaid)}</ram:TotalPrepaidAmount>` : ''}
        <ram:DuePayableAmount>${amount(totals.duePayable)}</ram:DuePayableAmount>
      </ram:SpecifiedTradeSettlementHeaderMonetarySummation>${preceding}
    </ram:ApplicableHeaderTradeSettlement>
  </rsm:SupplyChainTradeTransaction>
</rsm:CrossIndustryInvoice>
`
    .split('\n')
    .filter((l) => l.trim() !== '')
    .join('\n') + '\n';
}
