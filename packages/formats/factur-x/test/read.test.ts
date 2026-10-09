import { existsSync, readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { PDFDocument, StandardFonts } from 'pdf-lib';
import { describe, expect, it, vi } from 'vitest';
import {
  DOCUMENT_TYPE_CODES,
  GUIDELINES,
  InvoiceFileError,
  computeTotals,
  generateCiiXml,
  lineNetAmount,
  lineVatCategory,
  profileOf,
  readCii,
  type Invoice,
  type Profile,
  type ReceivedInvoice,
} from '../src/index.js';
import { embedFacturX, readFacturX } from '../src/pdf.js';
import { domesticInvoice, exampleInvoice } from './fixtures/example-invoice.js';

/**
 * The CII reader, four ways.
 *
 * - **What the writer writes reads back as what it was given**, for every
 *   profile, as XML and as a PDF the brick's own `embedFacturX` produced.
 * - **What another system sends reads as it says**: the files under
 *   `fixtures/received/`, an EN 16931 invoice with an embedded PDF, a BASIC
 *   credit note and a MINIMUM invoice.
 * - **One invoice, two syntaxes, one result**: the EN 16931 invoice is the
 *   received UBL invoice of the Peppol brick written in CII, and the two
 *   readers return the same thing for it.
 * - **What is not an invoice is refused by name**, and nothing the XML parser
 *   or `pdf-lib` underneath could throw escapes as anything else.
 */

const here = dirname(fileURLToPath(import.meta.url));
const received = (name: string): string => readFileSync(join(here, 'fixtures', 'received', name), 'utf8');

/** The sibling brick, where this package is read inside its repository. */
const peppol = join(here, '..', '..', 'peppol-ubl');
const inRepository = existsSync(join(peppol, 'src', 'read.ts'));

async function blankPdf(): Promise<Uint8Array> {
  const doc = await PDFDocument.create();
  const page = doc.addPage([595, 842]);
  page.drawText('Invoice', { x: 50, y: 780, size: 18, font: await doc.embedFont(StandardFonts.Helvetica) });
  return doc.save();
}

// --- what the writer writes ------------------------------------------------

const creditNote: Invoice = {
  ...domesticInvoice,
  number: 'CN-2026-0001',
  type: 'credit-note',
  precedingInvoice: { number: 'INV-2026-0043', issueDate: '2026-04-02' },
  note: 'Returned:\n two books',
  payment: { iban: 'BE71096123456769', terms: 'Refunded within 15 days', reference: 'CN-2026-0001' },
};

const outsideScope: Invoice = {
  ...domesticInvoice,
  number: 'INV-2026-0044',
  deliveryDate: '2026-03-30',
  contractReference: 'FRAME-2026',
  seller: {
    ...domesticInvoice.seller,
    electronicAddress: { scheme: '0208', value: '0999999031' },
    contact: { name: 'Invoicing desk', phone: '+32 81 00 00 00' },
  },
  lines: [
    { id: 'A', name: 'Deposit', quantity: 1, unitPrice: 50, vatRate: 0, vatCategory: 'O', note: 'Refundable' },
    { id: 'B', name: 'Crate', quantity: 2.5, unitCode: 'KGM', unitPrice: 3.333, vatRate: 21, sellerItemId: 'CR-1' },
  ],
  prepaidAmount: undefined,
  exemptionReasons: { O: 'Outside the scope of VAT' },
};

const WRITTEN: Record<string, Invoice> = {
  'an invoice between Member States': exampleInvoice,
  'a domestic invoice with a prepayment': domesticInvoice,
  'a credit note': creditNote,
  'an invoice outside the scope of VAT': outsideScope,
};
const PROFILES = Object.keys(GUIDELINES) as Profile[];

const money = (n: number): string => n.toFixed(2);
const compact = (s: string): string => s.replace(/\s/g, '');

/** What the reader must find in the XML the writer printed from this invoice. */
function expectedFrom(invoice: Invoice, profile: Profile) {
  const totals = computeTotals(invoice);
  const detailed = profile === 'en16931' || profile === 'extended';
  const party = (p: Invoice['seller']) => ({
    name: p.name,
    vatId: p.vatId === undefined ? null : compact(p.vatId),
    legalId: p.legalId === undefined ? null : { value: compact(p.legalId.value), scheme: p.legalId.scheme },
    electronicAddress: p.electronicAddress ?? null,
    address: {
      lines: [p.address.line1, p.address.line2, p.address.line3].filter((line) => line !== undefined),
      city: p.address.city,
      postalCode: p.address.postalCode,
      region: p.address.subdivision ?? null,
      country: p.address.country,
    },
    contact: detailed && p.contact ? { name: p.contact.name ?? null, phone: p.contact.phone ?? null, email: p.contact.email ?? null } : null,
  });
  const payment = invoice.payment;
  const category = (line: Invoice['lines'][number]) => lineVatCategory(line, invoice);
  return {
    syntax: 'cii',
    customizationId: GUIDELINES[profile],
    kind: invoice.type === 'credit-note' ? 'credit_note' : 'invoice',
    typeCode: DOCUMENT_TYPE_CODES[invoice.type ?? 'invoice'],
    number: invoice.number,
    issueDate: invoice.issueDate,
    dueDate: invoice.dueDate ?? null,
    deliveryDate: invoice.deliveryDate ?? invoice.issueDate,
    currency: invoice.currency ?? 'EUR',
    buyerReference: invoice.buyerReference ?? null,
    orderReference: invoice.orderReference ?? null,
    contractReference: invoice.contractReference ?? null,
    precedingInvoices: invoice.precedingInvoice
      ? [{ number: invoice.precedingInvoice.number, issueDate: invoice.precedingInvoice.issueDate ?? null }]
      : [],
    notes: invoice.note ? [invoice.note.replace(/\s+/g, ' ').trim()] : [],
    seller: party(invoice.seller),
    buyer: party(invoice.buyer),
    paymentTerms: payment?.terms ?? null,
    paymentMeans:
      payment && (payment.iban || payment.meansCode)
        ? [
            {
              code: payment.meansCode ?? '58',
              reference: payment.reference ?? null,
              account: payment.iban ? { kind: 'iban', value: compact(payment.iban) } : null,
              bic: detailed ? (payment.bic ?? null) : null,
            },
          ]
        : [],
    taxes: totals.breakdown.map((group) => ({
      category: group.category,
      rate: group.category === 'O' ? null : money(group.rate),
      base: money(group.basis),
      tax: money(group.tax),
    })),
    totals: {
      lineTotal: money(totals.lineTotal),
      allowanceTotal: null,
      chargeTotal: null,
      taxExclusive: money(totals.taxBasisTotal),
      taxTotal: money(totals.taxTotal),
      taxInclusive: money(totals.grandTotal),
      prepaid: totals.prepaid ? money(totals.prepaid) : null,
      rounding: null,
      payable: money(totals.duePayable),
    },
    lines: invoice.lines.map((line, i) => ({
      id: line.id ?? String(i + 1),
      note: line.note ?? null,
      quantity: line.quantity.toFixed(4),
      netAmount: money(lineNetAmount(line)),
      netPrice: money(line.unitPrice),
      vatCategory: category(line),
      vatRate: category(line) === 'O' ? null : money(category(line) === 'S' ? line.vatRate : 0),
      name: line.name,
      description: line.description ?? null,
      sellerItemId: line.sellerItemId ?? null,
    })),
  };
}

/** The same fields, from what the reader returned. */
function found(invoice: ReceivedInvoice) {
  const party = (p: ReceivedInvoice['seller']) => ({
    name: p.name,
    vatId: p.vatId,
    legalId: p.legalId,
    electronicAddress: p.electronicAddress,
    address: p.address,
    contact: p.contact,
  });
  return {
    syntax: invoice.syntax,
    customizationId: invoice.customizationId,
    kind: invoice.kind,
    typeCode: invoice.typeCode,
    number: invoice.number,
    issueDate: invoice.issueDate,
    dueDate: invoice.dueDate,
    deliveryDate: invoice.deliveryDate,
    currency: invoice.currency,
    buyerReference: invoice.buyerReference,
    orderReference: invoice.orderReference,
    contractReference: invoice.contractReference,
    precedingInvoices: invoice.precedingInvoices,
    notes: invoice.notes,
    seller: party(invoice.seller),
    buyer: party(invoice.buyer),
    paymentTerms: invoice.paymentTerms,
    paymentMeans: invoice.paymentMeans.map((each) => ({ code: each.code, reference: each.reference, account: each.account, bic: each.bic })),
    taxes: invoice.taxes.map((each) => ({ category: each.category, rate: each.rate, base: each.base, tax: each.tax })),
    totals: { ...invoice.totals, taxTotalInTaxCurrency: undefined },
    lines: invoice.lines.map((each) => ({
      id: each.id,
      note: each.note,
      quantity: each.quantity,
      netAmount: each.netAmount,
      netPrice: each.netPrice,
      vatCategory: each.vatCategory,
      vatRate: each.vatRate,
      name: each.name,
      description: each.description,
      sellerItemId: each.sellerItemId,
    })),
  };
}

describe('what the writer writes reads back as what it was given', () => {
  for (const [name, invoice] of Object.entries(WRITTEN)) {
    for (const profile of PROFILES) {
      it(`${name}, ${profile}`, () => {
        const result = readCii(generateCiiXml(invoice, { profile }));
        expect(found(result.invoice)).toEqual({ ...expectedFrom(invoice, profile), totals: { ...expectedFrom(invoice, profile).totals, taxTotalInTaxCurrency: undefined } });
        expect(result.profile).toBe(profile);
        expect(result.violations).toEqual([]);
      });
    }
  }

  it('reads the units of the lines as the writer coded them', () => {
    const { invoice } = readCii(generateCiiXml(outsideScope));
    expect(invoice.lines.map((line) => line.unitCode)).toEqual(['C62', 'KGM']);
  });

  it('reads the invoice out of a PDF the brick embedded it in, under its name', async () => {
    for (const [name, invoice] of Object.entries(WRITTEN)) {
      const xml = generateCiiXml(invoice, { profile: 'en16931' });
      const pdf = await embedFacturX(await blankPdf(), xml, { profile: 'en16931', date: new Date('2026-09-30T10:00:00Z') });
      const result = await readFacturX(pdf);
      expect(result.filename, name).toBe('factur-x.xml');
      expect(result.profile, name).toBe('en16931');
      expect(result.invoice, name).toEqual(readCii(xml).invoice);
    }
  });
});

// --- what another system sends ---------------------------------------------

describe('a received EN 16931 invoice with an embedded PDF', () => {
  const xml = received('invoice-with-pdf.xml');
  const { invoice, violations, profile } = readCii(xml);

  it('adds up, and is EN 16931', () => {
    expect(violations).toEqual([]);
    expect(profile).toBe('en16931');
  });

  it('reads the parties, with their schemes', () => {
    expect(invoice.seller).toMatchObject({
      name: 'Atelier Fictif SRL',
      tradeName: 'Atelier Fictif',
      identifiers: [{ value: '0200000000011', scheme: '0088' }],
      legalId: { value: '0999999031', scheme: '0208' },
      vatId: 'BE0999999031',
      legalForm: 'SRL, capital invented',
      electronicAddress: { value: '0999999031', scheme: '0208' },
    });
    expect(invoice.buyer.electronicAddress).toEqual({ value: 'NL999999999B01', scheme: '9944' });
  });

  it('returns the PDF as bytes, with its type and its name, and a linked document as its address', () => {
    const [pdf, timesheet] = invoice.attachments;
    expect(invoice.attachments).toHaveLength(2);
    expect(pdf).toMatchObject({ id: 'RCV-2026-0107', description: 'Invoice as printed', filename: 'RCV-2026-0107.pdf', mimeType: 'application/pdf', uri: null });
    expect(new TextDecoder('latin1').decode(pdf?.content?.subarray(0, 5))).toBe('%PDF-');
    expect(timesheet).toMatchObject({ id: 'TIMESHEET-08', content: null, uri: 'https://atelier-fictif.example.test/timesheets/08' });
  });

  it('tells an IBAN from another account by the element the file used', () => {
    expect(invoice.paymentMeans.map((each) => each.account)).toEqual([
      { kind: 'iban', value: 'BE53999000000099' },
      { kind: 'other', value: 'ACC-000-1234' },
    ]);
  });

  it('reports an IBAN whose check digits fail, and keeps it as written', () => {
    const result = readCii(xml.replace('BE53999000000099', 'BE54999000000099'));
    expect(result.invoice.paymentMeans[0]?.account).toEqual({ kind: 'iban', value: 'BE54999000000099' });
    expect(result.violations.map((each) => each.code)).toEqual(['invalid_iban']);
  });

  it('reads a direct debit: the mandate of the terms and the account debited', () => {
    const debit = xml
      .replace('<ram:TypeCode>30</ram:TypeCode>', '<ram:TypeCode>59</ram:TypeCode><ram:PayerPartyDebtorFinancialAccount><ram:IBANID>BE53999000000099</ram:IBANID></ram:PayerPartyDebtorFinancialAccount>')
      .replace('<ram:DueDateDateTime>', '<ram:DirectDebitMandateID>MANDATE-7</ram:DirectDebitMandateID><ram:DueDateDateTime>');
    const means = readCii(debit).invoice.paymentMeans[1];
    expect(means).toMatchObject({ code: '59', mandateReference: 'MANDATE-7', debitedAccount: { kind: 'iban', value: 'BE53999000000099' } });
  });

  it('reports a total that does not add up, and keeps it as written', () => {
    const result = readCii(xml.replace('<ram:GrandTotalAmount>748.40', '<ram:GrandTotalAmount>748.41'));
    expect(result.invoice.totals.taxInclusive).toBe('748.41');
    expect(result.violations.map((each) => each.code)).toEqual(['BR-CO-15', 'BR-CO-16']);
  });

  it('reports a date in another format than 102 and reads the rest', () => {
    const result = readCii(xml.replace('<udt:DateTimeString format="102">20260801</udt:DateTimeString>', '<udt:DateTimeString format="610">202608</udt:DateTimeString>'));
    expect(result.invoice.invoicingPeriod).toEqual({ start: null, end: '2026-08-31' });
    expect(result.violations.map((each) => each.code)).toEqual(['unsupported_date_format']);
  });

  it.runIf(inRepository)('is what the UBL reader of the Peppol brick reads from the same invoice in UBL', async () => {
    const ubl = await import(pathToFileURL(join(peppol, 'src', 'read.ts')).href);
    const other: ReceivedInvoice = ubl.readUbl(readFileSync(join(peppol, 'test', 'fixtures', 'received', 'invoice-with-pdf.xml'))).invoice;
    // What tells the two files apart: the syntax and what each claims to conform to.
    const neutral = (each: ReceivedInvoice) => ({ ...each, syntax: null, customizationId: null });
    expect(neutral(invoice)).toEqual(neutral(other));
  });
});

describe('a received BASIC credit note', () => {
  const { invoice, violations, profile } = readCii(received('credit-note-basic.xml'));

  it('is a credit note by its type code, its figures positive as written', () => {
    expect(violations).toEqual([]);
    expect(profile).toBe('basic');
    expect(invoice).toMatchObject({
      kind: 'credit_note',
      typeCode: '381',
      number: 'AV-2026-0009',
      issueDate: '2026-09-22',
      dueDate: '2026-10-07',
      taxPointDate: '2026-09-10',
      deliveryDate: '2026-09-10',
      precedingInvoices: [{ number: 'FI-2026-0311', issueDate: '2026-09-10' }],
      paymentTerms: 'Refunded by transfer within 15 days',
      totals: { lineTotal: '102.50', taxExclusive: '102.50', taxTotal: '20.50', taxInclusive: '123.00', payable: '123.00' },
    });
    expect(invoice.lines.map((line) => [line.quantity, line.netAmount, line.vatRate])).toEqual([
      ['2.0000', '90.00', '20.00'],
      ['1.0000', '12.50', '20.00'],
    ]);
  });

  it('reads a seller addressed by SIRET, with a tax registration beside its VAT number, and a buyer by VAT number', () => {
    expect(invoice.seller).toMatchObject({
      legalId: { value: '999999990', scheme: '0002' },
      vatId: 'FR00999999990',
      taxRegistrationId: '9999999999999',
      electronicAddress: { value: '99999999000017', scheme: '0009' },
    });
    expect(invoice.buyer).toMatchObject({ vatId: 'LU99999999', taxRegistrationId: null, electronicAddress: { value: 'LU99999999', scheme: '9938' } });
  });

  it('compacts an IBAN written in groups', () => {
    expect(invoice.paymentMeans[0]?.account).toEqual({ kind: 'iban', value: 'FR4099999000010000001234506' });
  });
});

describe('a received MINIMUM invoice', () => {
  const { invoice, violations, profile } = readCii(received('invoice-minimum.xml'));

  it('carries no line and only the totals, and says which profile it is', () => {
    expect(profile).toBe('minimum');
    expect(violations).toEqual([]);
    expect(invoice.lines).toEqual([]);
    expect(invoice.totals).toEqual({
      lineTotal: null,
      allowanceTotal: null,
      chargeTotal: null,
      taxExclusive: '615.00',
      taxTotal: '123.00',
      taxTotalInTaxCurrency: null,
      taxInclusive: '738.00',
      prepaid: null,
      rounding: null,
      payable: '738.00',
    });
    expect(invoice).toMatchObject({ profileId: null, buyerReference: 'LOG-ACHATS', orderReference: 'BC-0042', deliveryDate: null });
    expect(invoice.seller.address).toEqual({ lines: [], city: null, postalCode: null, region: null, country: 'FR' });
  });

  it('is refused without a line once the profile is one that carries lines', () => {
    const basic = received('invoice-minimum.xml').replace('urn:factur-x.eu:1p0:minimum', GUIDELINES.basic);
    expect(() => readCii(basic)).toThrow(InvoiceFileError);
  });
});

describe('the profile a guideline identifier declares', () => {
  it.each<[string, Profile | null]>([
    ...PROFILES.map((profile): [string, Profile] => [GUIDELINES[profile], profile]),
    ['urn:zugferd.de:2p0:basicwl', 'basic-wl'],
    ['urn:cen.eu:en16931:2017#compliant#urn:zugferd.de:2p0:basic', 'basic'],
    ['urn:cen.eu:en16931:2017#compliant#urn:xeinkauf.de:kosit:xrechnung_3.0', 'en16931'],
    ['urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0', 'en16931'],
    ['urn:example:something-else', null],
  ])('%s', (guideline, profile) => {
    expect(profileOf(guideline)).toBe(profile);
  });
});

// --- what is not an invoice ------------------------------------------------

describe('what is not an invoice is refused by name', () => {
  const xml = received('credit-note-basic.xml');

  const refusal = (input: string | Uint8Array, options = {}): string => {
    try {
      readCii(input, options);
    } catch (error) {
      expect(error).toBeInstanceOf(InvoiceFileError);
      return (error as InvoiceFileError).code;
    }
    throw new Error('read without refusal');
  };

  it.each([
    ['not XML', 'this is a PDF, honestly', 'malformed_xml'],
    ['a DOCTYPE', '<?xml version="1.0"?><!DOCTYPE x [<!ENTITY a "b">]><x/>', 'doctype_forbidden'],
    ['an entity of its own', xml.replace('Two cartridges', '&cartridges;'), 'undefined_entity'],
    ['a UBL invoice', '<Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"/>', 'not_an_invoice'],
    ['the CII of ZUGFeRD 1', '<rsm:CrossIndustryDocument xmlns:rsm="urn:ferd:CrossIndustryDocument:invoice:1p0"/>', 'not_an_invoice'],
    ['no number', xml.replace('<ram:ID>AV-2026-0009</ram:ID>', ''), 'missing_element'],
    ['no type code', xml.replace('<ram:TypeCode>381</ram:TypeCode>', ''), 'missing_element'],
    ['no issue date', xml.replace(/<ram:IssueDateTime>[\s\S]*?<\/ram:IssueDateTime>/, ''), 'missing_element'],
    ['no currency', xml.replace('<ram:InvoiceCurrencyCode>EUR</ram:InvoiceCurrencyCode>', ''), 'missing_element'],
    ['no totals', xml.replace(/<ram:SpecifiedTradeSettlementHeaderMonetarySummation>[\s\S]*<\/ram:SpecifiedTradeSettlementHeaderMonetarySummation>/, ''), 'missing_element'],
    ['no line', xml.replace(/<ram:IncludedSupplyChainTradeLineItem>[\s\S]*<\/ram:IncludedSupplyChainTradeLineItem>/, ''), 'missing_element'],
    ['a day that does not exist', xml.replace('20260922', '20260230'), 'invalid_value'],
    ['an amount that is not a number', xml.replace('<ram:DuePayableAmount>123.00', '<ram:DuePayableAmount>123,00'), 'invalid_value'],
    ['an indicator that is neither true nor false', received('invoice-with-pdf.xml').replace('<udt:Indicator>true</udt:Indicator>', '<udt:Indicator>yes</udt:Indicator>'), 'invalid_value'],
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
        readCii(xml.slice(0, at));
      } catch (error) {
        if (!(error instanceof InvoiceFileError)) escaped.push(`at ${at}: ${String(error)}`);
      }
    }
    expect(escaped).toEqual([]);
  });
});

describe('what is not a Factur-X PDF is refused by name', () => {
  const refusal = async (input: Uint8Array, options = {}): Promise<string> => {
    try {
      await readFacturX(input, options);
    } catch (error) {
      expect(error).toBeInstanceOf(InvoiceFileError);
      return (error as InvoiceFileError).code;
    }
    throw new Error('read without refusal');
  };

  it('refuses bytes that are not a PDF, and a PDF without the XML', async () => {
    expect(await refusal(new TextEncoder().encode(received('credit-note-basic.xml')))).toBe('not_a_pdf');
    expect(await refusal(new TextEncoder().encode('%PDF-1.7\nnothing else'))).toBe('not_a_pdf');
    expect(await refusal(await blankPdf())).toBe('no_embedded_invoice');
  });

  it('refuses a PDF over the limit before opening it, and an embedded XML that is not an invoice', async () => {
    const pdf = await embedFacturX(await blankPdf(), generateCiiXml(exampleInvoice));
    expect(await refusal(pdf, { maxBytes: 1000 })).toBe('too_large');
    expect(await refusal(await embedFacturX(await blankPdf(), '<not-an-invoice/>'))).toBe('not_an_invoice');
  });

  it('throws nothing but its own error, wherever the PDF is cut', async () => {
    // pdf-lib reads a damaged file leniently and says so on the console.
    const quiet = [vi.spyOn(console, 'warn').mockImplementation(() => {}), vi.spyOn(console, 'log').mockImplementation(() => {})];
    const pdf = await embedFacturX(await blankPdf(), generateCiiXml(exampleInvoice));
    const escaped: string[] = [];
    for (let at = 0; at < pdf.length; at += Math.ceil(pdf.length / 60)) {
      try {
        await readFacturX(pdf.slice(0, at));
      } catch (error) {
        if (!(error instanceof InvoiceFileError)) escaped.push(`at ${at}: ${String(error)}`);
      }
    }
    for (const spy of quiet) spy.mockRestore();
    expect(escaped).toEqual([]);
  });
});

// --- the copies --------------------------------------------------------------

describe.runIf(inRepository)('the files this brick shares with the Peppol brick', () => {
  it.each(['received.ts', 'received-checks.ts', 'errors.ts', 'xml.ts', 'decimal.ts'])('%s is the same, byte for byte', (file) => {
    expect(readFileSync(join(here, '..', 'src', file), 'utf8')).toBe(readFileSync(join(peppol, 'src', file), 'utf8'));
  });
});
