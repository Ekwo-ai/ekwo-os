import type { PeppolUblInput, PeppolUblOptions } from '../../src/index.js';

/**
 * The documents the tests are made of. Every one is invented: the companies do
 * not exist, the addresses are not addresses and the account is not an account.
 *
 * Two identifiers had to be chosen with care, because the rules check them.
 * `0999999922` is not the `0999999999` the rest of this repository uses: a
 * Belgian enterprise number carries check digits (PEPPOL-COMMON-R043), the
 * ten nines do not pass them, and no number in the 0999 range has been issued.
 * `BE68539007547034` is the IBAN the ISO 13616 documentation prints.
 *
 * Each case is written to `<name>.xml` beside this file, byte for byte what the
 * generator returns, and `verdicts.json` records what the published Schematron
 * said of that file. A case that is right breaks no rule; a case that is wrong
 * is wrong in one way, and says which rule it expects to hear about.
 */

export interface Case {
  name: string;
  why: string;
  input: PeppolUblInput;
  options: PeppolUblOptions;
}

const seller = {
  seller_name: 'Demo Atelier',
  seller_legal_name: 'Demo Atelier SRL',
  seller_legal_form: 'SRL',
  seller_vat_number: 'BE0999999922',
  seller_registration_number: '0999.999.922',
  seller_address_line1: 'Rue Inventée 1',
  seller_address_line2: null,
  seller_postal_code: '1000',
  seller_city: 'Bruxelles',
  seller_country: 'BE',
  seller_region: null,
  seller_email: 'billing@seller.example.test',
  seller_phone: '+32 2 000 00 00',
};

const buyer = {
  buyer_name: 'Example Buyer BV',
  buyer_vat_number: 'NL999999999B01',
  buyer_registration_number: '99999999',
  buyer_address_line1: 'Verzonnenstraat 2',
  buyer_address_line2: null,
  buyer_postal_code: '1011 AA',
  buyer_city: 'Amsterdam',
  buyer_country: 'NL',
  buyer_region: null,
  buyer_email: 'ap@buyer.example.test',
};

const endpoints: PeppolUblOptions = {
  sellerRegistrationScheme: '0208',
  sellerEndpoint: { scheme: '0208', id: '0999999922' },
  buyerEndpoint: { scheme: '9944', id: 'NL999999999B01' },
};

const standard: PeppolUblInput = {
  header: {
    doc_type: 'sale_invoice',
    number: 'INV-2026-0001',
    document_date: '2026-03-02',
    due_date: '2026-04-01',
    delivery_date: '2026-02-27',
    currency_code: 'EUR',
    amount_untaxed: '1450.00',
    amount_tax: '267.00',
    amount_total: '1717.00',
    amount_paid: '0.00',
    amount_residual: '1717.00',
    payment_terms: '30 days net',
    payment_means_code: '58',
    payment_reference: '+++090/9337/55493+++',
    payee_iban: 'BE68 5390 0754 7034',
    payee_bic: null,
    buyer_reference: 'PO-7781',
    order_reference: null,
    contract_reference: 'C-2026-04',
    project_reference: 'P-12',
    note: 'Thank you & see you soon',
    ...seller,
    ...buyer,
    buyer_vat_number: 'BE0999999823',
    buyer_country: 'BE',
    buyer_postal_code: '4000',
    buyer_city: 'Liège',
    buyer_address_line1: 'Quai Imaginaire 3',
  },
  lines: [
    {
      line_type: 'product',
      sequence: 10,
      item_name: 'Workshop day',
      item_description: 'On site, two people',
      seller_item_identifier: 'WS-DAY',
      quantity: '2',
      unit_code: 'DAY',
      unit_price: '600.0000',
      discount_percent: '0',
      unit_price_includes_tax: false,
      amount_untaxed: '1200.00',
      vat_category: 'S',
      vat_rate: '21.00',
      tax_exemption_code: null,
    },
    { line_type: 'section', sequence: 15, item_name: 'Books', quantity: null, amount_untaxed: '0' },
    {
      line_type: 'product',
      sequence: 20,
      item_name: 'Handbook',
      quantity: '10.000',
      unit_code: 'C62',
      unit_price: '27.7778',
      discount_percent: '10.00',
      unit_price_includes_tax: false,
      amount_untaxed: '250.00',
      vat_category: 'S',
      vat_rate: '6.00',
      tax_exemption_code: null,
    },
  ],
  taxes: [
    { vat_category: 'S', tax_rate: '21.00', base_amount: '1200.00', tax_charged: '252.00' },
    { vat_category: 'S', tax_rate: '6.00', base_amount: '250.00', tax_charged: '15.00' },
  ],
};

const intraCommunity: PeppolUblInput = {
  header: {
    ...standard.header,
    number: 'INV-2026-0002',
    amount_untaxed: '8000.00',
    amount_tax: '0.00',
    amount_total: '8000.00',
    amount_residual: '8000.00',
    project_reference: null,
    note: null,
    ...buyer,
    delivery_address_line1: 'Verzonnenstraat 2',
    delivery_postal_code: '1011 AA',
    delivery_city: 'Amsterdam',
    delivery_country: 'NL',
  },
  lines: [
    {
      sequence: 10,
      item_name: 'Goods delivered to the Netherlands',
      quantity: '4',
      unit_code: 'H87',
      unit_price: '2000',
      amount_untaxed: '8000.00',
      vat_category: 'K',
      vat_rate: '0',
      tax_exemption_code: 'VATEX-EU-IC',
    },
  ],
  taxes: [{ vat_category: 'K', tax_rate: '0', base_amount: '8000.00', tax_charged: '0.00' }],
};

const creditNote: PeppolUblInput = {
  header: {
    ...standard.header,
    doc_type: 'sale_credit_note',
    number: 'CN-2026-0001',
    document_date: '2026-03-20',
    due_date: '2026-04-19',
    delivery_date: null,
    amount_untaxed: '600.00',
    amount_tax: '126.00',
    amount_total: '726.00',
    amount_residual: '726.00',
    tax_point_date: '2026-03-02',
  },
  lines: [
    {
      sequence: 10,
      item_name: 'Workshop day, cancelled',
      quantity: '1',
      unit_code: 'DAY',
      unit_price: '600',
      amount_untaxed: '600.00',
      vat_category: 'S',
      vat_rate: '21',
    },
  ],
  taxes: [{ vat_category: 'S', tax_rate: '21', base_amount: '600.00', tax_charged: '126.00' }],
};

/** One line and one group, in a category that charges nothing. */
function uncharged(number: string, category: string, code: string | null, reason: string | null): PeppolUblInput {
  return {
    header: {
      ...standard.header,
      number,
      amount_untaxed: '500.00',
      amount_tax: '0.00',
      amount_total: '500.00',
      amount_residual: '500.00',
      project_reference: null,
      contract_reference: null,
      note: null,
    },
    lines: [
      {
        sequence: 1,
        item_name: 'Training session',
        quantity: '5',
        unit_code: 'HUR',
        unit_price: '100',
        amount_untaxed: '500.00',
        vat_category: category,
        vat_rate: category === 'O' ? null : '0',
        tax_exemption_code: code,
      },
    ],
    taxes: [{ vat_category: category, tax_rate: category === 'O' ? null : '0', base_amount: '500.00', tax_charged: '0.00', exemption_reason: reason }],
  };
}

/** One field of the header changed, the rest as it was. */
const withHeader = (input: PeppolUblInput, header: Partial<PeppolUblInput['header']>): PeppolUblInput => ({
  ...input,
  header: { ...input.header, ...header },
});

const WRITTEN: Case[] = [
  { name: 'invoice-standard', why: 'Two standard rates, a discount on a price, a section that is not a line.', input: standard, options: endpoints },
  { name: 'invoice-intra-community', why: 'Category K: an exemption code carried up from the line, a delivery country.', input: intraCommunity, options: endpoints },
  {
    name: 'credit-note',
    why: 'The other schema: another order, another quantity, a due date that lives elsewhere, a project with no element of its own.',
    input: creditNote,
    options: { ...endpoints, precedingInvoice: { number: 'INV-2026-0001', issueDate: '2026-03-02' } },
  },
  {
    name: 'invoice-minimal',
    why: 'Nothing but what the rules require.',
    input: {
      header: {
        doc_type: 'sale_invoice',
        number: '1',
        document_date: '2026-03-02',
        due_date: '2026-03-02',
        currency_code: 'EUR',
        amount_untaxed: '100',
        amount_tax: '21',
        amount_total: '121',
        order_reference: 'ORDER-1',
        seller_name: 'Demo Atelier SRL',
        seller_vat_number: 'BE0999999922',
        seller_country: 'BE',
        buyer_name: 'Example Buyer',
        buyer_country: 'BE',
      },
      lines: [{ item_name: 'Service', quantity: 1, unit_code: 'C62', unit_price: 100, amount_untaxed: 100, vat_category: 'S', vat_rate: 21 }],
      taxes: [{ vat_category: 'S', tax_rate: 21, base_amount: 100, tax_charged: 21 }],
    },
    options: endpoints,
  },
  { name: 'broken-no-endpoints', why: 'Neither party can be delivered to.', input: standard, options: { sellerRegistrationScheme: '0208' } },
  { name: 'broken-no-reference', why: 'Neither a buyer reference nor an order.', input: withHeader(standard, { buyer_reference: null }), options: endpoints },
  { name: 'broken-total', why: 'A total with VAT that is not the two others added.', input: withHeader(standard, { amount_total: '1717.01', amount_residual: '1717.01' }), options: endpoints },
  { name: 'broken-due', why: 'An amount due that is not the total less what was paid.', input: withHeader(standard, { amount_paid: '100.00', amount_residual: '1717.00' }), options: endpoints },
  { name: 'broken-vat-total', why: 'A total VAT that is not the sum of its groups.', input: withHeader(standard, { amount_tax: '266.99', amount_total: '1716.99', amount_residual: '1716.99' }), options: endpoints },
  {
    name: 'broken-line-sum',
    why: 'Lines that do not add up to the document, nor to their group.',
    input: { ...standard, lines: standard.lines.map((line) => (line.sequence === 10 ? { ...line, quantity: '3', amount_untaxed: '1800.00' } : line)) },
    options: endpoints,
  },
  {
    name: 'broken-line-arithmetic',
    why: 'A line whose amount is not its quantity times its price.',
    input: { ...standard, lines: standard.lines.map((line) => (line.sequence === 10 ? { ...line, unit_price: '599.00' } : line)) },
    options: endpoints,
  },
  {
    name: 'broken-group-tax',
    why: 'A tax that is not its base times its rate, by more than the standard tolerates.',
    input: {
      ...withHeader(standard, { amount_tax: '269.50', amount_total: '1719.50', amount_residual: '1719.50' }),
      taxes: [standard.taxes[0]!, { ...standard.taxes[1]!, tax_charged: '17.50' }],
    },
    options: endpoints,
  },
  {
    name: 'broken-no-exemption-reason',
    why: 'An intra-community supply that does not say why it charges nothing.',
    input: { ...intraCommunity, lines: intraCommunity.lines.map((line) => ({ ...line, tax_exemption_code: null })) },
    options: endpoints,
  },
  {
    name: 'broken-wrong-exemption-reason',
    why: 'The reason of an export on an intra-community supply.',
    input: { ...intraCommunity, lines: intraCommunity.lines.map((line) => ({ ...line, tax_exemption_code: 'VATEX-EU-G' })) },
    options: endpoints,
  },
  {
    name: 'broken-intra-community-delivery',
    why: 'An intra-community supply that says neither when nor where it was delivered, to a buyer without a VAT number.',
    input: withHeader(intraCommunity, { delivery_date: null, delivery_country: null, delivery_address_line1: null, delivery_city: null, delivery_postal_code: null, buyer_vat_number: null }),
    options: { ...endpoints, buyerEndpoint: { scheme: '0106', id: '99999999' } },
  },
  { name: 'broken-currency', why: 'A currency that is not one.', input: withHeader(standard, { currency_code: 'EUX' }), options: endpoints },
  {
    name: 'broken-codes',
    why: 'A unit, a country, a payment means and an address scheme, none of which exists.',
    input: {
      ...withHeader(standard, { buyer_country: 'ZZ', payment_means_code: '999' }),
      lines: standard.lines.map((line) => (line.sequence === 20 ? { ...line, unit_code: 'BOX' } : line)),
    },
    options: { ...endpoints, buyerEndpoint: { scheme: '0000', id: 'x' } },
  },
  {
    name: 'broken-enterprise-number',
    why: 'Ten nines: the number every test in this repository uses, and not a Belgian enterprise number.',
    input: withHeader(standard, { seller_registration_number: '0999999999' }),
    options: { ...endpoints, sellerEndpoint: { scheme: '0208', id: '0999999999' } },
  },
  {
    name: 'broken-gross-price',
    why: 'A price keyed with its tax in it, and no net price from the books.',
    input: { ...standard, lines: standard.lines.map((line) => (line.sequence === 10 ? { ...line, unit_price: '726.00', unit_price_includes_tax: true } : line)) },
    options: endpoints,
  },
  {
    name: 'broken-parties',
    why: 'A seller nobody can identify, a buyer without an address.',
    input: withHeader(standard, {
      seller_vat_number: null,
      seller_registration_number: null,
      buyer_address_line1: null,
      buyer_postal_code: null,
      buyer_city: null,
      buyer_country: null,
    }),
    options: { ...endpoints, sellerEndpoint: { scheme: '0088', id: '1234567890123' } },
  },
  { name: 'broken-no-due-date', why: 'Money due, and neither a date nor terms.', input: withHeader(standard, { due_date: null, payment_terms: null }), options: endpoints },
  { name: 'broken-transfer-without-account', why: 'A credit transfer to no account.', input: withHeader(standard, { payee_iban: null }), options: endpoints },
  { name: 'invoice-exempt', why: 'Category E, with the code of the exemption and its text.', input: uncharged('INV-2026-0003', 'E', 'VATEX-EU-132-1I', 'Exempt: education, article 132(1)(i) of Directive 2006/112/EC'), options: endpoints },
  { name: 'invoice-reverse-charge', why: 'Category AE.', input: uncharged('INV-2026-0004', 'AE', 'VATEX-EU-AE', null), options: endpoints },
  { name: 'invoice-zero-rated', why: 'Category Z, which exempts nothing and gives no reason.', input: uncharged('INV-2026-0005', 'Z', null, null), options: endpoints },
  {
    name: 'invoice-outside-scope',
    why: 'Category O: no rate at all, and no VAT number on either side.',
    input: withHeader(uncharged('INV-2026-0006', 'O', 'VATEX-EU-O', null), { seller_vat_number: null, buyer_vat_number: null }),
    options: endpoints,
  },
  {
    name: 'invoice-two-taxes-one-rate',
    why: 'Goods and services are two taxes in the books and one group in the standard.',
    input: {
      ...standard,
      lines: standard.lines.map((line) => (line.sequence === 20 ? { ...line, vat_rate: '21' } : line)),
      header: { ...standard.header, amount_tax: '304.50', amount_total: '1754.50', amount_residual: '1754.50' },
      taxes: [
        { vat_category: 'S', tax_rate: '21.00', base_amount: '1200.00', tax_charged: '252.00' },
        { vat_category: 'S', tax_rate: '21', base_amount: '250.00', tax_charged: '52.50' },
      ],
    },
    options: endpoints,
  },
  {
    name: 'credit-note-minimal',
    why: 'A credit note owes nobody a due date.',
    input: withHeader(creditNote, { due_date: null, payment_terms: null, payment_means_code: null, payee_iban: null, payment_reference: null, tax_point_date: null }),
    options: endpoints,
  },
  {
    name: 'broken-address-scheme-not-on-peppol',
    why: 'An e-mail address: an electronic address for the standard, and nowhere the network delivers.',
    input: standard,
    options: { ...endpoints, buyerEndpoint: { scheme: 'EM', id: 'ap@buyer.example.test' } },
  },
  {
    name: 'broken-rate-on-exempt',
    why: 'An exempt line with a rate.',
    input: {
      ...uncharged('INV-2026-0007', 'E', 'VATEX-EU-132-1I', null),
      lines: uncharged('x', 'E', 'VATEX-EU-132-1I', null).lines.map((line) => ({ ...line, vat_rate: '6' })),
      taxes: [{ vat_category: 'E', tax_rate: '6', base_amount: '500.00', tax_charged: '0.00' }],
    },
    options: endpoints,
  },
  {
    name: 'broken-reason-on-standard',
    why: 'A reason for an exemption on a group that is not exempt.',
    input: { ...standard, taxes: [{ ...standard.taxes[0]!, exemption_reason: 'Exempt' }, standard.taxes[1]!] },
    options: endpoints,
  },
  {
    name: 'broken-mixed-outside-scope',
    why: 'Outside the scope of VAT, and a standard-rated line beside it.',
    input: {
      ...standard,
      header: { ...standard.header, amount_untaxed: '1950.00', amount_total: '2217.00', amount_residual: '2217.00' },
      lines: [...standard.lines, ...uncharged('x', 'O', 'VATEX-EU-O', null).lines.map((line) => ({ ...line, sequence: 30 }))],
      taxes: [...standard.taxes, ...uncharged('x', 'O', 'VATEX-EU-O', null).taxes],
    },
    options: endpoints,
  },
  {
    name: 'broken-group-without-line',
    why: 'A standard-rated group no line belongs to.',
    input: { ...standard, taxes: [...standard.taxes, { vat_category: 'S', tax_rate: '12', base_amount: '0.00', tax_charged: '0.00' }] },
    options: endpoints,
  },
  {
    name: 'broken-line-without-group',
    why: 'An exempt line the breakdown does not know of.',
    input: {
      ...standard,
      header: { ...standard.header, amount_untaxed: '1950.00', amount_total: '2217.00', amount_residual: '2217.00' },
      lines: [...standard.lines, ...uncharged('x', 'E', null, null).lines.map((line) => ({ ...line, sequence: 30 }))],
    },
    options: endpoints,
  },
  {
    name: 'broken-empty-line',
    why: 'A line that says nothing of what it is: no name, no quantity, no unit, no category.',
    input: {
      ...standard,
      lines: standard.lines.map((line) =>
        line.sequence === 10 ? { ...line, item_name: null, item_description: null, quantity: null, unit_code: null, vat_category: null, vat_rate: null } : line,
      ),
    },
    options: endpoints,
  },
  { name: 'broken-names', why: 'Two parties without a name.', input: withHeader(standard, { seller_name: null, seller_legal_name: null, buyer_name: null }), options: endpoints },
  { name: 'broken-delivery-country', why: 'A delivery address in no country.', input: withHeader(standard, { delivery_city: 'Liège' }), options: endpoints },
  { name: 'broken-vat-prefix', why: 'A VAT number that starts with no country.', input: withHeader(standard, { seller_vat_number: 'QQ0999999922' }), options: endpoints },
  { name: 'broken-identifier-scheme', why: 'A registration number in a scheme that does not exist.', input: standard, options: { ...endpoints, sellerRegistrationScheme: '9999' } },
  { name: 'broken-negative-price', why: 'A price below zero.', input: { ...standard, lines: standard.lines.map((line) => (line.sequence === 10 ? { ...line, quantity: '-2', unit_price: '-600' } : line)) }, options: endpoints },
  { name: 'broken-decimals', why: 'Three decimals, which a dinar has and the standard does not.', input: withHeader(standard, { amount_total: '1717.005', amount_residual: '1717.005' }), options: endpoints },
];

/**
 * The same five mistakes, made once in every category that charges nothing.
 * The rules come in families — BR-E-*, BR-AE-*, BR-IC-*, BR-G-*, BR-O-*,
 * BR-Z-* — that read alike and are not alike: which party has to be identified,
 * whether a rate is zero or absent, whether a reason is required or forbidden.
 * A family is only known to be re-read correctly once each member was asked.
 */
const CODES: Record<string, string | null> = { Z: null, E: 'VATEX-EU-132-1I', AE: 'VATEX-EU-AE', K: 'VATEX-EU-IC', G: 'VATEX-EU-G', O: 'VATEX-EU-O' };

function family(category: string): Case[] {
  const tag = category.toLowerCase();
  const base = (): PeppolUblInput => {
    const input = uncharged(`INV-${category}`, category, CODES[category] ?? null, null);
    const header = { ...input.header, ...buyer };
    if (category === 'K') Object.assign(header, { delivery_country: 'NL', delivery_city: 'Amsterdam' });
    if (category === 'O') Object.assign(header, { seller_vat_number: null, buyer_vat_number: null });
    return { ...input, header };
  };
  const line = (change: Partial<PeppolUblInput['lines'][number]>): PeppolUblInput => ({ ...base(), lines: base().lines.map((each) => ({ ...each, ...change })) });
  const tax = (change: Partial<PeppolUblInput['taxes'][number]>): PeppolUblInput => ({ ...base(), taxes: base().taxes.map((each) => ({ ...each, ...change })) });
  return [
    { name: `family-${tag}`, why: `Category ${category}, as it should be.`, input: base(), options: endpoints },
    { name: `broken-${tag}-no-group`, why: `A line in category ${category} and no group for it.`, input: { ...base(), taxes: [] }, options: endpoints },
    {
      name: `broken-${tag}-vat-numbers`,
      why: `Category ${category} with the VAT numbers the other way round: there where there should be none, absent where they are required.`,
      input: withHeader(base(), category === 'O' ? { seller_vat_number: 'BE0999999922' } : { seller_vat_number: null, buyer_vat_number: null, buyer_registration_number: null }),
      options: endpoints,
    },
    { name: `broken-${tag}-rate`, why: `A rate of 6 on a line and a group of category ${category}.`, input: { ...line({ vat_rate: '6' }), taxes: tax({ tax_rate: '6' }).taxes }, options: endpoints },
    { name: `broken-${tag}-base`, why: `A group of category ${category} whose base is not its lines.`, input: tax({ base_amount: '499.99' }), options: endpoints },
    {
      name: `broken-${tag}-tax`,
      why: `A group of category ${category} that charges.`,
      input: { ...withHeader(base(), { amount_tax: '1.00', amount_total: '501.00', amount_residual: '501.00' }), taxes: tax({ tax_charged: '1.00' }).taxes },
      options: endpoints,
    },
    {
      name: `broken-${tag}-reason`,
      why: category === 'Z' ? 'A zero-rated group that gives a reason.' : `A group of category ${category} that gives none.`,
      input: category === 'Z' ? tax({ exemption_reason: 'Zero rated' }) : line({ tax_exemption_code: null }),
      options: endpoints,
    },
  ];
}

/** One exemption code that belongs to a category, on a group of another. */
const misplaced = (code: string, category: string): Case => ({
  name: `broken-reason-${code.toLowerCase()}-on-${category.toLowerCase()}`,
  why: `${code} on a group of category ${category}.`,
  input: (() => {
    const input = uncharged('INV-R', category, code, null);
    return category === 'O' ? withHeader(input, { seller_vat_number: null, buyer_vat_number: null }) : input;
  })(),
  options: endpoints,
});

const MORE: Case[] = [
  { name: 'broken-seller-address', why: 'A seller with no address at all.', input: withHeader(standard, { seller_address_line1: null, seller_postal_code: null, seller_city: null, seller_country: null }), options: endpoints },
  { name: 'broken-countries', why: 'Two addresses in no country.', input: withHeader(standard, { seller_country: null, buyer_country: null }), options: endpoints },
  { name: 'broken-endpoint-schemes', why: 'Two electronic addresses in no scheme.', input: standard, options: { sellerRegistrationScheme: '0208', sellerEndpoint: { scheme: '', id: '0999999922' }, buyerEndpoint: { scheme: ' ', id: 'x' } } },
  { name: 'broken-group-category', why: 'A group in no category, and one in a category that does not exist.', input: { ...standard, taxes: [{ ...standard.taxes[0]!, vat_category: null }, { ...standard.taxes[1]!, vat_category: 'X' }] }, options: endpoints },
  { name: 'broken-line-category', why: 'A line in a category that does not exist.', input: { ...standard, lines: standard.lines.map((each) => (each.sequence === 20 ? { ...each, vat_category: 'X' } : each)) }, options: endpoints },
  { name: 'broken-group-rate', why: 'A standard-rated group and its line, with no rate.', input: { ...standard, lines: standard.lines.map((each) => (each.sequence === 20 ? { ...each, vat_rate: null } : each)), taxes: [standard.taxes[0]!, { ...standard.taxes[1]!, tax_rate: null }] }, options: endpoints },
  { name: 'broken-no-breakdown', why: 'No VAT breakdown at all.', input: { ...standard, taxes: [] }, options: endpoints },
  { name: 'broken-exemption-code', why: 'An exemption code that is not on the list.', input: uncharged('INV-X', 'E', 'VATEX-XX-1', null), options: endpoints },
  { name: 'broken-negative-gross-price', why: 'A discounted price below zero.', input: { ...standard, lines: standard.lines.map((each) => (each.sequence === 20 ? { ...each, quantity: '-10', unit_price: '-27.7778' } : each)) }, options: endpoints },
  {
    name: 'broken-decimals-everywhere',
    why: 'A third decimal on every amount that has a rule of its own.',
    input: {
      header: { ...standard.header, amount_untaxed: '1450.001', amount_tax: '267.001', amount_total: '1717.002', amount_paid: '0.001', amount_residual: '1717.001' },
      lines: standard.lines.map((each) => (each.sequence === 10 ? { ...each, amount_untaxed: '1200.001' } : each)),
      taxes: [{ ...standard.taxes[0]!, base_amount: '1200.001', tax_charged: '252.001' }, standard.taxes[1]!],
    },
    options: endpoints,
  },
  misplaced('VATEX-EU-O', 'E'),
  misplaced('VATEX-EU-IC', 'E'),
  misplaced('VATEX-EU-AE', 'E'),
  misplaced('VATEX-EU-D', 'AE'),
  misplaced('VATEX-EU-F', 'AE'),
  misplaced('VATEX-EU-I', 'AE'),
  misplaced('VATEX-EU-J', 'AE'),
];

export const CASES: Case[] = [...WRITTEN, ...MORE, ...['Z', 'E', 'AE', 'K', 'G', 'O'].flatMap(family)];
