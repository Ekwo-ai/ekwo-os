import { readFileSync, readdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { validateXML } from 'xmllint-wasm';
import { formatDecimal, parseDecimal } from '../src/decimal.js';
import { InvoiceFileError, generatePeppolUbl, readUbl, type ReceivedInvoice } from '../src/index.js';
import { buildModel, type DocumentModel, type PartyModel } from '../src/model.js';
import { decodeBase64 } from '../src/received-checks.js';
import { CASES } from './fixtures/cases.js';

/**
 * The reader, three ways.
 *
 * - **What the writer writes reads back as what it was given.** Every case of
 *   `fixtures/cases.ts` — the right ones and the broken ones, which are still
 *   documents — is written, read, and compared with the model the writer
 *   printed, field for field and digit for digit.
 * - **What another system sends reads as it says.** The files under
 *   `fixtures/received/` carry what the writer never writes (allowances and
 *   charges, an embedded PDF, a prefixed root); each is first held against the
 *   OASIS schema, then read.
 * - **What is not an invoice is refused by name**, and nothing the parser
 *   underneath could throw escapes as anything else.
 *
 * And the arithmetic the reader reports is held to the published Schematron:
 * for every committed file, the BR-CO rules it names are the BR-CO rules the
 * Schematron named (`fixtures/verdicts.json`).
 */

const here = dirname(fileURLToPath(import.meta.url));
const fixtures = join(here, 'fixtures');
const received = (name: string): Buffer => readFileSync(join(fixtures, 'received', name));

const xsd = join(here, 'xsd');
const common = readdirSync(join(xsd, 'common'))
  .filter((name) => name.endsWith('.xsd'))
  .map((name) => ({ fileName: `common/${name}`, contents: readFileSync(join(xsd, 'common', name), 'utf8') }));

async function validate(xml: string): Promise<{ valid: boolean; errors: string[] }> {
  const main = /<(?:\w+:)?CreditNote[\s>]/.test(xml) ? 'UBL-CreditNote-2.1.xsd' : 'UBL-Invoice-2.1.xsd';
  const result = await validateXML({
    xml: [{ fileName: 'document.xml', contents: xml }],
    schema: [{ fileName: `maindoc/${main}`, contents: readFileSync(join(xsd, 'maindoc', main), 'utf8') }],
    preload: common,
  });
  return { valid: result.valid, errors: result.errors.map((error) => error.message) };
}

/** A decimal written the one way, so that `21` and `21.00` compare as what they are. */
const same = (value: string | null): string | null => (value === null ? null : formatDecimal(parseDecimal(value)!));
const decimal = (value: { units: bigint; scale: number } | null): string | null => (value === null ? null : formatDecimal(value));

function expectedParty(model: PartyModel) {
  return {
    name: model.registrationName,
    tradeName: model.tradeName,
    vatId: model.vatId,
    legalId: model.legalId === null ? null : { value: model.legalId, scheme: model.legalIdScheme },
    legalForm: model.legalForm,
    electronicAddress: model.endpoint === null ? null : { value: model.endpoint.id, scheme: model.endpoint.scheme || null },
    address:
      model.address === null
        ? null
        : {
            lines: [model.address.line1, model.address.line2].filter((line) => line !== null),
            city: model.address.city,
            postalCode: model.address.postalCode,
            region: model.address.region,
            country: model.address.country,
          },
    contact: model.contact === null ? null : { name: null, ...model.contact },
  };
}

/** What the reader must find in the file the writer printed from this model. */
function expected(model: DocumentModel) {
  return {
    kind: model.kind === 'Invoice' ? 'invoice' : 'credit_note',
    typeCode: model.typeCode,
    number: model.number,
    issueDate: model.issueDate,
    dueDate: model.payment === null && model.kind === 'CreditNote' ? null : model.dueDate,
    taxPointDate: model.taxPointDate,
    currency: model.currency,
    buyerReference: model.buyerReference,
    orderReference: model.orderReference,
    contractReference: model.contractReference,
    projectReference: model.projectReference,
    precedingInvoices: model.preceding === null ? [] : [model.preceding],
    notes: model.note === null ? [] : [model.note],
    seller: expectedParty(model.seller),
    buyer: expectedParty(model.buyer),
    deliveryDate: model.delivery?.date ?? null,
    paymentTerms: model.paymentTerms,
    paymentMeans:
      model.payment === null
        ? []
        : [{ code: model.payment.meansCode, reference: model.payment.reference, iban: model.payment.iban, bic: model.payment.bic }],
    taxes: model.subtotals.map((each) => ({
      category: each.category,
      // Outside the scope of VAT a rate of zero is not written (BR-O-05).
      rate: each.category === 'O' && each.rate !== null && each.rate.units === 0n ? null : decimal(each.rate),
      base: decimal(each.base),
      tax: decimal(each.tax),
      exemptionReasonCode: each.reasonCode,
      exemptionReason: each.reason,
    })),
    totals: {
      lineTotal: decimal(model.lineTotal),
      taxExclusive: decimal(model.taxExclusive),
      taxTotal: decimal(model.taxTotal),
      taxInclusive: decimal(model.taxInclusive),
      prepaid: decimal(model.prepaid),
      payable: decimal(model.payable),
    },
    lines: model.lines.map((each) => ({
      id: each.id,
      quantity: decimal(each.quantity),
      unitCode: each.unitCode,
      netAmount: decimal(each.netAmount),
      netPrice: decimal(each.netPrice),
      grossPrice: each.priceDiscount === null ? null : decimal(each.grossPrice),
      priceDiscount: each.grossPrice === null ? null : decimal(each.priceDiscount),
      vatCategory: each.category,
      vatRate: each.category === 'O' && each.rate !== null && each.rate.units === 0n ? null : decimal(each.rate),
      name: each.name,
      description: each.description,
      sellerItemId: each.sellerItemId,
    })),
  };
}

/** The same fields, from what the reader returned. */
function found(invoice: ReceivedInvoice) {
  const party = (p: ReceivedInvoice['seller']) => ({
    name: p.name,
    tradeName: p.tradeName,
    vatId: p.vatId,
    legalId: p.legalId,
    legalForm: p.legalForm,
    electronicAddress: p.electronicAddress,
    address: p.address,
    contact: p.contact,
  });
  return {
    kind: invoice.kind,
    typeCode: invoice.typeCode,
    number: invoice.number,
    issueDate: invoice.issueDate,
    dueDate: invoice.dueDate,
    taxPointDate: invoice.taxPointDate,
    currency: invoice.currency,
    buyerReference: invoice.buyerReference,
    orderReference: invoice.orderReference,
    contractReference: invoice.contractReference,
    projectReference: invoice.projectReference,
    precedingInvoices: invoice.precedingInvoices,
    notes: invoice.notes,
    seller: party(invoice.seller),
    buyer: party(invoice.buyer),
    deliveryDate: invoice.deliveryDate,
    paymentTerms: invoice.paymentTerms,
    paymentMeans: invoice.paymentMeans.map((each) => ({
      code: each.code,
      reference: each.reference,
      iban: each.account?.value ?? null,
      bic: each.bic,
    })),
    taxes: invoice.taxes.map((each) => ({ ...each, rate: same(each.rate), base: same(each.base), tax: same(each.tax) })),
    totals: {
      lineTotal: same(invoice.totals.lineTotal),
      taxExclusive: same(invoice.totals.taxExclusive),
      taxTotal: same(invoice.totals.taxTotal),
      taxInclusive: same(invoice.totals.taxInclusive),
      prepaid: same(invoice.totals.prepaid),
      payable: same(invoice.totals.payable),
    },
    lines: invoice.lines.map((each) => ({
      id: each.id,
      quantity: same(each.quantity),
      unitCode: each.unitCode,
      netAmount: same(each.netAmount),
      netPrice: same(each.netPrice),
      grossPrice: same(each.grossPrice),
      priceDiscount: same(each.priceDiscount),
      vatCategory: each.vatCategory,
      vatRate: same(each.vatRate),
      name: each.name,
      description: each.description,
      sellerItemId: each.sellerItemId,
    })),
  };
}

describe('what the writer writes reads back as what it was given', () => {
  for (const each of CASES) {
    it(each.name, () => {
      const { file } = generatePeppolUbl(each.input, each.options);
      const { invoice } = readUbl(file);
      expect(found(invoice)).toEqual(expected(buildModel(each.input, each.options)));
      expect(invoice.syntax).toBe('ubl');
      expect(invoice.customizationId).toBe('urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0');
    });
  }

  it('covers an invoice and a credit note', () => {
    const kinds = new Set(CASES.map((each) => readUbl(generatePeppolUbl(each.input, each.options).file).invoice.kind));
    expect(kinds).toEqual(new Set(['invoice', 'credit_note']));
  });
});

describe('the arithmetic it reports is what the published Schematron reported', () => {
  const recorded = JSON.parse(readFileSync(join(fixtures, 'verdicts.json'), 'utf8')) as {
    verdicts: Record<string, { fatal: string[] }>;
  };
  const arithmetic = (code: string): boolean => /^BR-CO-1[0-7]$/.test(code);

  for (const [name, verdict] of Object.entries(recorded.verdicts)) {
    it(name, () => {
      const { violations } = readUbl(readFileSync(join(fixtures, `${name}.xml`)));
      const mine = [...new Set(violations.map((each) => each.code).filter(arithmetic))].sort();
      expect(mine).toEqual(verdict.fatal.filter(arithmetic).sort());
    });
  }

  it('was held against files that break each of the rules it checks', () => {
    const named = new Set(Object.values(recorded.verdicts).flatMap((each) => each.fatal.filter(arithmetic)));
    expect([...named].sort()).toEqual(['BR-CO-10', 'BR-CO-14', 'BR-CO-15', 'BR-CO-16', 'BR-CO-17']);
  });
});

describe('a received invoice with an embedded PDF', () => {
  const xml = received('invoice-with-pdf.xml').toString('utf8');

  it('is a UBL 2.1 invoice by the published schema', async () => {
    expect(await validate(xml)).toEqual({ valid: true, errors: [] });
  });

  const { invoice, violations } = readUbl(xml);

  it('adds up', () => {
    expect(violations).toEqual([]);
  });

  it('reads the header', () => {
    expect(invoice).toMatchObject({
      syntax: 'ubl',
      profileId: 'urn:fdc:peppol.eu:2017:poacc:billing:01:1.0',
      kind: 'invoice',
      typeCode: '380',
      number: 'RCV-2026-0107',
      issueDate: '2026-09-15',
      dueDate: '2026-10-15',
      taxPointDate: null,
      currency: 'EUR',
      taxCurrency: null,
      buyerReference: 'DEPT-OPS',
      orderReference: 'PO-RCV-55',
      salesOrderReference: 'SO-7710',
      contractReference: 'FRAME-2026',
      projectReference: 'OFFICE-REFIT',
      accountingCost: 'WORKSHOP-FURNITURE',
      precedingInvoices: [],
      notes: ['Delivered in August, invoiced in September.', 'Questions: invoicing@atelier-fictif.example.test'],
      deliveryDate: '2026-08-28',
      deliveryAddress: { lines: ['Proefweg 5'], city: 'Utrecht', postalCode: '3512 BB', region: null, country: 'NL' },
      invoicingPeriod: { start: '2026-08-01', end: '2026-08-31' },
      paymentTerms: '30 days net; 100.00 paid on order',
    });
  });

  it('reads both parties, with their schemes', () => {
    expect(invoice.seller).toEqual({
      name: 'Atelier Fictif SRL',
      tradeName: 'Atelier Fictif',
      identifiers: [{ value: '0200000000011', scheme: '0088' }],
      legalId: { value: '0999999031', scheme: '0208' },
      vatId: 'BE0999999031',
      taxRegistrationId: null,
      legalForm: 'SRL, capital invented',
      electronicAddress: { value: '0999999031', scheme: '0208' },
      address: { lines: ['Rue des Essais 12', 'Boîte 3'], city: 'Namur', postalCode: '5000', region: null, country: 'BE' },
      contact: { name: 'Invoicing desk', phone: '+32 81 00 00 00', email: 'invoicing@atelier-fictif.example.test' },
    });
    expect(invoice.buyer).toMatchObject({
      name: 'Voorbeeld Kantoor BV',
      tradeName: 'Voorbeeld Kantoor',
      legalId: { value: '99999999', scheme: null },
      vatId: 'NL999999999B01',
      electronicAddress: { value: 'NL999999999B01', scheme: '9944' },
      address: { lines: ['Verzonnenstraat 2', 'Second floor'], city: 'Utrecht', postalCode: '3511 AA', region: null, country: 'NL' },
      contact: null,
    });
  });

  it('reads the payment means, telling an IBAN from another account', () => {
    expect(invoice.paymentMeans).toEqual([
      {
        code: '58',
        text: 'SEPA credit transfer',
        reference: 'RCV-2026-0107',
        account: { kind: 'iban', value: 'BE53999000000099' },
        accountName: 'Atelier Fictif SRL',
        bic: 'ZZZZBEB0',
        cardNumber: null,
        mandateReference: null,
        debitedAccount: null,
      },
      {
        code: '30',
        text: null,
        reference: 'RCV-2026-0107',
        account: { kind: 'other', value: 'ACC-000-1234' },
        accountName: null,
        bic: null,
        cardNumber: null,
        mandateReference: null,
        debitedAccount: null,
      },
    ]);
  });

  it('reads the allowances and charges of the document, the breakdown and the totals, as the digits written', () => {
    expect(invoice.allowances).toEqual([
      { charge: false, amount: '17.00', baseAmount: null, percent: null, reason: 'Early order discount', reasonCode: '95', vatCategory: 'S', vatRate: '21' },
      { charge: true, amount: '20.00', baseAmount: '500.00', percent: '4', reason: 'Packaging', reasonCode: 'ABL', vatCategory: 'S', vatRate: '21' },
    ]);
    expect(invoice.taxes).toEqual([
      { category: 'S', rate: '21', base: '608.00', tax: '127.68', exemptionReasonCode: null, exemptionReason: null },
      { category: 'S', rate: '6', base: '12.00', tax: '0.72', exemptionReasonCode: null, exemptionReason: null },
    ]);
    expect(invoice.totals).toEqual({
      lineTotal: '617.00',
      allowanceTotal: '17.00',
      chargeTotal: '20.00',
      taxExclusive: '620.00',
      taxTotal: '128.40',
      taxTotalInTaxCurrency: null,
      taxInclusive: '748.40',
      prepaid: '100.00',
      rounding: null,
      payable: '648.40',
    });
  });

  it('reads a line with its allowance, its prices and its identifiers', () => {
    expect(invoice.lines).toHaveLength(3);
    expect(invoice.lines[0]).toEqual({
      id: '1',
      note: 'Assembled on site',
      quantity: '4',
      unitCode: 'C62',
      netAmount: '470.00',
      orderLineReference: '3',
      period: null,
      allowances: [{ charge: false, amount: '10.00', baseAmount: null, percent: null, reason: 'Loyalty', reasonCode: '95', vatCategory: null, vatRate: null }],
      netPrice: '120.00',
      priceDiscount: '5.00',
      grossPrice: '125.00',
      priceBaseQuantity: '1',
      priceBaseUnitCode: 'C62',
      vatCategory: 'S',
      vatRate: '21',
      name: 'Oak shelving, assembled',
      description: 'Oak, 180 x 90 cm',
      sellerItemId: 'AF-SH-180',
      buyerItemId: 'SHELF-OAK',
      standardItemId: { value: '02000000000108', scheme: '0160' },
    });
    expect(invoice.lines[1]?.period).toEqual({ start: '2026-08-27', end: '2026-08-28' });
  });

  it('returns the PDF as bytes, with its type and its name, and a linked document as its address', () => {
    expect(invoice.attachments).toHaveLength(2);
    const [pdf, link] = invoice.attachments;
    expect(pdf).toMatchObject({ id: 'RCV-2026-0107', description: 'Invoice as printed', filename: 'RCV-2026-0107.pdf', mimeType: 'application/pdf', uri: null });
    const bytes = pdf!.content!;
    expect(bytes).toBeInstanceOf(Uint8Array);
    expect(bytes.length).toBe(596);
    expect(Buffer.from(bytes.subarray(0, 8)).toString('latin1')).toBe('%PDF-1.4');
    expect(Buffer.from(bytes.subarray(-6)).toString('latin1')).toBe('%%EOF\n');
    expect(Buffer.from(bytes).toString('latin1')).toContain('(Invoice RCV-2026-0107) Tj');
    expect(link).toEqual({
      id: 'TIMESHEET-08',
      description: 'Installation timesheet',
      filename: null,
      mimeType: null,
      content: null,
      uri: 'https://atelier-fictif.example.test/timesheets/08',
    });
  });

  it('reports a total that does not add up, and keeps it as written', () => {
    const wrong = xml.replace('<cbc:PayableAmount currencyID="EUR">648.40', '<cbc:PayableAmount currencyID="EUR">648.41');
    const read = readUbl(wrong);
    expect(read.invoice.totals.payable).toBe('648.41');
    expect(read.violations.map((each) => each.code)).toEqual(['BR-CO-16']);
  });

  it('reports a document allowance the totals leave out', () => {
    const wrong = xml.replace('<cbc:AllowanceTotalAmount currencyID="EUR">17.00</cbc:AllowanceTotalAmount>', '');
    expect(readUbl(wrong).violations.map((each) => each.code)).toEqual(['BR-CO-11', 'BR-CO-13']);
  });

  it('reports an embedded document that is not base64, and returns the rest', () => {
    const wrong = xml.replace('JVBERi0xLjQK', 'JVBERi0x*jQK');
    const read = readUbl(wrong);
    expect(read.invoice.attachments[0]?.content).toBeNull();
    expect(read.violations).toEqual([{ code: 'invalid_attachment', message: expect.stringContaining('RCV-2026-0107') }]);
  });

  it('reads the document inside the envelope an access point hands it over in', () => {
    const body = xml.replace(/^<\?xml[^>]*>\s*/, '');
    const wrapped = `<?xml version="1.0" encoding="UTF-8"?>
<StandardBusinessDocument xmlns="http://www.unece.org/cefact/namespaces/StandardBusinessDocumentHeader">
  <StandardBusinessDocumentHeader><HeaderVersion>1.0</HeaderVersion></StandardBusinessDocumentHeader>
  ${body}
</StandardBusinessDocument>`;
    expect(readUbl(wrapped).invoice).toEqual(invoice);
  });

  it('reads bytes and text alike, and a byte order mark', () => {
    expect(readUbl(received('invoice-with-pdf.xml')).invoice).toEqual(invoice);
    expect(readUbl(`﻿${xml}`).invoice).toEqual(invoice);
  });
});

describe('a received credit note', () => {
  const xml = received('credit-note.xml').toString('utf8');

  it('is a UBL 2.1 credit note by the published schema', async () => {
    expect(await validate(xml)).toEqual({ valid: true, errors: [] });
  });

  const { invoice, violations } = readUbl(xml);

  it('is a credit note, its figures positive as written', () => {
    expect(violations).toEqual([]);
    expect(invoice).toMatchObject({
      kind: 'credit_note',
      typeCode: '381',
      number: 'GS-CN-0042',
      issueDate: '2026-09-20',
      taxPointDate: '2026-09-19',
      precedingInvoices: [{ number: 'GS-INV-0317', issueDate: '2026-09-01' }],
      notes: ['Two trestles returned undamaged.'],
      totals: { taxExclusive: '160.00', taxTotal: '30.40', taxInclusive: '190.40', payable: '190.40' },
    });
    expect(invoice.lines).toMatchObject([{ id: '1', quantity: '2', unitCode: 'C62', netAmount: '160.00', vatCategory: 'S', vatRate: '19', name: 'Trestle, returned' }]);
  });

  it('finds the due date in the payment means and the project in a document of type 50, where a credit note keeps them', () => {
    expect(invoice.dueDate).toBe('2026-10-20');
    expect(invoice.projectReference).toBe('WAREHOUSE-2');
    expect(invoice.attachments).toEqual([]);
  });

  it('reads a seller addressed by GLN, with a tax registration beside its VAT number', () => {
    expect(invoice.seller).toMatchObject({
      name: 'Gerüstbau Beispiel GmbH',
      tradeName: null,
      vatId: 'DE999999999',
      taxRegistrationId: '999/999/99999',
      electronicAddress: { value: '0299999000010', scheme: '0088' },
    });
    expect(invoice.buyer.electronicAddress).toEqual({ value: '0999999130', scheme: '0208' });
    expect(invoice.paymentMeans[0]?.account).toEqual({ kind: 'iban', value: 'NL19ZZZZ0999999999' });
  });
});

describe('what is not an invoice is refused by name', () => {
  const xml = received('credit-note.xml').toString('utf8');

  const refusal = (input: string | Uint8Array, options = {}): string => {
    try {
      readUbl(input, options);
    } catch (error) {
      expect(error).toBeInstanceOf(InvoiceFileError);
      return (error as InvoiceFileError).code;
    }
    throw new Error('read without refusal');
  };

  it.each([
    ['not XML', 'this is a PDF, honestly', 'malformed_xml'],
    ['a DOCTYPE', '<?xml version="1.0"?><!DOCTYPE x [<!ENTITY a "b">]><x/>', 'doctype_forbidden'],
    ['an entity of its own', xml.replace('Two trestles', '&trestles;'), 'undefined_entity'],
    ['another root', '<Order xmlns="urn:oasis:names:specification:ubl:schema:xsd:Order-2"/>', 'not_an_invoice'],
    ['a CII invoice', '<rsm:CrossIndustryInvoice xmlns:rsm="urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100"/>', 'not_an_invoice'],
    ['no number', xml.replace('<cbc:ID>GS-CN-0042</cbc:ID>', ''), 'missing_element'],
    ['no currency', xml.replace('<cbc:DocumentCurrencyCode>EUR</cbc:DocumentCurrencyCode>', ''), 'missing_element'],
    ['no totals', xml.replace(/<cac:LegalMonetaryTotal>[\s\S]*<\/cac:LegalMonetaryTotal>/, ''), 'missing_element'],
    ['no line', xml.replace(/<cac:CreditNoteLine>[\s\S]*<\/cac:CreditNoteLine>/, ''), 'missing_element'],
    ['a day that does not exist', xml.replace('2026-09-20', '2026-02-30'), 'invalid_value'],
    ['an amount that is not a number', xml.replace('>190.40</cbc:PayableAmount>', '>190,40</cbc:PayableAmount>'), 'invalid_value'],
    ['an amount with an exponent', xml.replace('>160.00</cbc:LineExtensionAmount>', '>1.6E2</cbc:LineExtensionAmount>'), 'invalid_value'],
  ])('%s', (_, input, code) => {
    expect(refusal(input)).toBe(code);
  });

  it('refuses bytes that are not UTF-8, and a file over the limit before reading it', () => {
    expect(refusal(Uint8Array.from([0x3c, 0x61, 0xff, 0x3e]))).toBe('unsupported_encoding');
    expect(refusal(xml, { maxBytes: 100 })).toBe('too_large');
    expect(refusal(xml, { maxDepth: 3 })).toBe('too_deep');
    expect(refusal(xml, { maxElements: 10 })).toBe('too_many_elements');
  });

  it('throws nothing but its own error, wherever the file is cut', () => {
    const escaped: string[] = [];
    for (let at = 0; at < xml.length; at += 7) {
      try {
        readUbl(xml.slice(0, at));
      } catch (error) {
        if (!(error instanceof InvoiceFileError)) escaped.push(`at ${at}: ${String(error)}`);
      }
    }
    expect(escaped).toEqual([]);
  });
});

describe('base64, as xs:base64Binary has it', () => {
  it('decodes what Node encodes, at every length', () => {
    for (let length = 0; length < 70; length += 1) {
      const bytes = Uint8Array.from({ length }, (_, i) => (i * 37 + length) & 0xff);
      const encoded = Buffer.from(bytes).toString('base64').replace(/(.{10})/g, '$1\n ');
      expect(decodeBase64(encoded)).toEqual(bytes);
    }
  });

  it.each(['QQ', 'QQ=', 'Q===', 'QR==', 'QQ==QQ==', 'Q*Q='])('refuses %s', (text) => {
    expect(decodeBase64(text)).toBeNull();
  });
});
