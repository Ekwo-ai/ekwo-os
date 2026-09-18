import { readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { validateXML } from 'xmllint-wasm';
import {
  generatePeppolUbl,
  type DocumentHeaderRow,
  type DocumentLineRow,
  type DocumentTaxRow,
} from '@ekwo-ai/peppol-ubl';
import { freshDatabase, one, repoRoot, rows } from './helpers/db.js';
import { newCompany } from './helpers/factory.js';
import { replayScenario } from './helpers/golden-scenario.js';
import { packsWhere } from './helpers/packs.js';

/**
 * Where a posted sale and the invoice the network carries meet.
 *
 * The chain: a country pack's golden year of books, through the real engine —
 * `post_document()` and nothing else — then the three views a document is read
 * through, then the brick, then the file **read back** and compared with the
 * books to the cent: the total without VAT, the VAT of each rate, the total
 * with VAT, every line. The brick is fed `document_header`,
 * `document_line_items` and `document_tax_summary` — three reads, no join to
 * the tables under them, and no option: the electronic addresses are the
 * company's and the contact's, the category and the rate of a line are the
 * ones it was posted with, and the reason a group charges nothing is the
 * breakdown's. That is the contract: the brick reads no database, and what is
 * sent is what was posted.
 *
 * Every pack that declares `peppol-bis-3` is walked, and none is named: the
 * profile is the pack's claim, and this is where the claim is exercised.
 *
 * A golden scenario is a year of *accounting*, not of invoicing: it records no
 * purchase order, no delivery and no electronic address of a customer, because
 * no ledger needs them. So its documents are not sendable, and this test says exactly
 * why, document by document, from the facts of each — before it posts one that
 * is, and expects nothing at all to be wrong with it.
 */

const packs = packsWhere('declares the profile peppol-bis-3', (pack) => pack.documents.einvoice_profile === 'peppol-bis-3');

// --- The published schema, read from the brick's own fixtures ---------------
const xsd = join(repoRoot, 'packages', 'formats', 'peppol-ubl', 'test', 'xsd');
const common = readdirSync(join(xsd, 'common'))
  .filter((name) => name.endsWith('.xsd'))
  .map((name) => ({ fileName: `common/${name}`, contents: readFileSync(join(xsd, 'common', name), 'utf8') }));

async function schemaErrors(xml: string): Promise<string[]> {
  const main = xml.includes('<CreditNote ') ? 'UBL-CreditNote-2.1.xsd' : 'UBL-Invoice-2.1.xsd';
  const result = await validateXML({
    xml: [{ fileName: 'document.xml', contents: xml }],
    schema: [{ fileName: `maindoc/${main}`, contents: readFileSync(join(xsd, 'maindoc', main), 'utf8') }],
    preload: common,
  });
  return result.errors.map((error) => error.message);
}

// --- Reading the file back ---------------------------------------------------
const cents = (value: string | number): number => Math.round(Number(value) * 100);
const amountOf = (xml: string, element: string): number => {
  const match = new RegExp(`<cbc:${element} currencyID="[A-Z]{3}">(-?[0-9.]+)</cbc:${element}>`).exec(xml);
  expect(match, element).not.toBeNull();
  return cents((match as RegExpExecArray)[1] as string);
};

interface ReadBack {
  taxExclusive: number;
  taxInclusive: number;
  taxTotal: number;
  payable: number;
  /** `category|rate` to [base, tax], in cents. */
  groups: Map<string, [number, number]>;
  lines: number[];
}

function readBack(xml: string): ReadBack {
  const total = /<cac:LegalMonetaryTotal>([\s\S]*?)<\/cac:LegalMonetaryTotal>/.exec(xml)?.[1] ?? '';
  const taxTotal = /<cac:TaxTotal>([\s\S]*?)<\/cac:TaxTotal>/.exec(xml)?.[1] ?? '';
  const groups = new Map<string, [number, number]>();
  for (const match of taxTotal.matchAll(/<cac:TaxSubtotal>([\s\S]*?)<\/cac:TaxSubtotal>/g)) {
    const body = match[1] as string;
    const category = /<cac:TaxCategory>\s*<cbc:ID>([^<]+)</.exec(body)?.[1] ?? '';
    const rate = /<cbc:Percent>([^<]+)</.exec(body)?.[1] ?? '';
    groups.set(`${category}|${rate === '' ? '' : Number(rate)}`, [amountOf(body, 'TaxableAmount'), amountOf(body, 'TaxAmount')]);
  }
  return {
    taxExclusive: amountOf(total, 'TaxExclusiveAmount'),
    taxInclusive: amountOf(total, 'TaxInclusiveAmount'),
    taxTotal: amountOf(taxTotal, 'TaxAmount'),
    payable: amountOf(total, 'PayableAmount'),
    groups,
    lines: [...xml.matchAll(/<cac:(?:InvoiceLine|CreditNoteLine)>([\s\S]*?)<\/cac:(?:InvoiceLine|CreditNoteLine)>/g)].map((match) =>
      amountOf(match[1] as string, 'LineExtensionAmount'),
    ),
  };
}

// --- Reading the books -------------------------------------------------------
type Line = DocumentLineRow & { unit_price_includes_tax: boolean; tax_id: string | null };
type Tax = DocumentTaxRow & { base_amount: string; tax_charged: string; tax_id: string | null };

interface Read {
  header: DocumentHeaderRow;
  lines: Line[];
  taxes: Tax[];
}

/**
 * One document, as three reads of the three views.
 *
 * The dates are read as text: a driver hands a `date` back as an instant, and
 * the brick refuses one rather than decide which day it falls on.
 */
async function read(db: PGlite, documentId: string): Promise<Read> {
  const header = await one<DocumentHeaderRow>(
    db,
    `select h.*, h.document_date::text as document_date, h.due_date::text as due_date,
            h.delivery_date::text as delivery_date, h.tax_point_date::text as tax_point_date
       from document_header h
      where h.document_id = $1`,
    [documentId],
  );
  const lines = await rows<Line>(db, `select * from document_line_items where document_id = $1 order by sequence`, [documentId]);
  const taxes = await rows<Tax>(db, `select * from document_tax_summary where document_id = $1 order by tax_code`, [documentId]);
  return { header, lines, taxes };
}

/** Categories that charge nothing and have to say why (BR-*-10), and the letters their rules are named with. */
const EXEMPTING: Record<string, string> = { E: 'E', AE: 'AE', K: 'IC', G: 'G', O: 'O' };

/**
 * What is wrong with a document of a golden scenario, worked out from the
 * document and from nothing else. Not a list of tolerated failures: each entry
 * is a fact the scenario does not record, and the rule that asks for it.
 */
function expectedOf({ header, lines, taxes }: Read): string[] {
  const out = new Set<string>();
  if (!header.buyer_reference && !header.order_reference) out.add('PEPPOL-EN16931-R003');
  if (!header.buyer_peppol_identifier) out.add('PEPPOL-EN16931-R010');
  const due = cents(header.amount_residual ?? 0);
  if (header.doc_type === 'sale_invoice' && due > 0 && !header.due_date && !header.payment_terms) out.add('BR-CO-25');
  for (const tax of taxes) {
    // The rule asks for a code or for a sentence, and the breakdown has both
    // where the pack has them: the code of the tax, the mention of its treatment.
    const family = EXEMPTING[tax.vat_category ?? ''];
    if (family && !tax.exemption_code && !tax.exemption_reason) out.add(`BR-${family}-10`);
    if (tax.vat_category === 'AE' && !header.buyer_vat_number && !header.buyer_registration_number) out.add('BR-AE-02');
    if (tax.vat_category === 'K') {
      if (!header.buyer_vat_number) out.add('BR-IC-02');
      if (!header.delivery_date) out.add('BR-IC-11');
      if (!header.delivery_country) out.add('BR-IC-12');
    }
  }
  // A price keyed with its tax in it: the view publishes no net price (BT-146),
  // which `docs/international.md` writes up, and the brick works none out.
  if (lines.some((line) => line.unit_price_includes_tax)) {
    for (const code of ['BR-26', 'BR-27', 'PEPPOL-EN16931-R120']) out.add(code);
  }
  return [...out].sort();
}

/** A registration number the rules of its scheme accept. Only one scheme known here has check digits. */
function registrationNumber(scheme: string | null): string {
  if (scheme !== '0208') return '99999999';
  const body = 9_999_999; // 0999 999 9xx: a range no enterprise number was issued in
  return `0${body}${String(97 - (body % 97)).padStart(2, '0')}`;
}

for (const pack of packs) {
  describe(`${pack.slug}: a year of sales, as Peppol BIS Billing 3.0`, () => {
    const golden = pack.golden as NonNullable<typeof pack.golden>;
    let db: PGlite;
    let companyId: string;
    let sales: { ref: string; id: string }[];

    beforeAll(async () => {
      db = await freshDatabase();
      ({ companyId } = await newCompany(db, {
        country: pack.manifest.country,
        name: golden.name,
        chart: golden.chart,
        language: golden.language,
        fiscalYear: golden.fiscalYear,
      }));
      // Who the seller is, and where the network reaches it. A scenario does
      // not say, because a ledger does not ask; an invoice does. Invented, in
      // the shape the country's scheme wants — and the address is a location
      // number, because which identifier a company is registered under is its
      // own business and not something to work out from its VAT number.
      await db.query(
        `update companies
            set legal_name = 'Demo Company', vat_number = $2, registration_number = $3,
                address_line1 = 'Invented Street 1', postal_code = '1000', city = 'Demo City',
                peppol_scheme = '0088', peppol_identifier = '5412345000020'
          where id = $1`,
        [companyId, `${pack.manifest.country}999999999`, registrationNumber(pack.documents.party_scheme)],
      );
      const replayed = await replayScenario(db, companyId, golden);
      sales = golden.documents
        .filter((document) => document.type === 'sale_invoice' || document.type === 'sale_credit_note')
        .map((document) => ({ ref: document.ref, id: replayed.documents.get(document.ref) as string }));
    }, 300_000);

    afterAll(async () => {
      await db?.close();
    });

    it('has sales to write, an invoice and a credit note among them', () => {
      const types = new Set(golden.documents.map((document) => document.type));
      expect(sales.length).toBeGreaterThan(0);
      expect(types.has('sale_invoice') && types.has('sale_credit_note')).toBe(true);
    });

    it('writes every one of them as a document the UBL 2.1 schema accepts', async () => {
      for (const sale of sales) {
        const { file } = generatePeppolUbl(await read(db, sale.id));
        expect(await schemaErrors(file), sale.ref).toEqual([]);
      }
    });

    it('reads every one of them back to the figures of the books, to the cent', async () => {
      for (const sale of sales) {
        const { header, lines, taxes } = await read(db, sale.id);
        const back = readBack(generatePeppolUbl({ header, lines, taxes }).file);

        const booked = await one<{ amount_untaxed: string; amount_tax: string; amount_total: string; amount_residual: string }>(
          db,
          `select amount_untaxed::text, amount_tax::text, amount_total::text, amount_residual::text from documents where id = $1`,
          [sale.id],
        );
        expect(back.taxExclusive, `${sale.ref} without VAT`).toBe(cents(booked.amount_untaxed));
        expect(back.taxTotal, `${sale.ref} VAT`).toBe(cents(booked.amount_tax));
        expect(back.taxInclusive, `${sale.ref} with VAT`).toBe(cents(booked.amount_total));
        expect(back.payable, `${sale.ref} due`).toBe(cents(booked.amount_residual));

        // The VAT of each rate, against the view: one group per category and
        // rate, which is the view's rows added where two taxes share a rate.
        const expected = new Map<string, [number, number]>();
        for (const tax of taxes) {
          const key = `${tax.vat_category}|${tax.vat_category === 'O' ? '' : Number(tax.tax_rate)}`;
          const [base, charged] = expected.get(key) ?? [0, 0];
          expected.set(key, [base + cents(tax.base_amount), charged + cents(tax.tax_charged)]);
        }
        expect(back.groups, `${sale.ref} VAT by rate`).toEqual(expected);
        expect([...back.groups.values()].reduce((total, [, tax]) => total + tax, 0), `${sale.ref} VAT adds up`).toBe(back.taxTotal);

        // And the lines, against the ledger: what the file says was sold is
        // what was credited to the accounts of the lines.
        expect(back.lines, `${sale.ref} lines`).toEqual(lines.map((line) => cents(line.amount_untaxed)));
        const ledger = await one<{ base: string }>(
          db,
          `select coalesce(sum(abs(l.debit - l.credit)), 0)::text as base
             from entry_lines l join documents d on d.entry_id = l.entry_id
            where d.id = $1 and l.account_id in (select account_id from document_lines where document_id = $1)`,
          [sale.id],
        );
        expect(back.lines.reduce((total, net) => total + net, 0), `${sale.ref} against the ledger`).toBe(cents(ledger.base));
      }
    });

    it('says what a year of accounting leaves out of an invoice, and nothing else', async () => {
      const seen = new Set<string>();
      for (const sale of sales) {
        const document = await read(db, sale.id);
        const { violations } = generatePeppolUbl(document);
        const codes = [...new Set(violations.map((violation) => violation.code))].sort();
        expect(codes, sale.ref).toEqual(expectedOf(document));
        for (const code of codes) seen.add(code);
      }
      // Never a figure: no total, no group, no sum is ever among them.
      expect([...seen].filter((code) => /^BR-CO-1\d$|^BR-[A-Z]+-0[89]$|^BR-DEC/.test(code))).toEqual([]);
    });

    it('carries on every line the category and the rate it was posted with', async () => {
      for (const sale of sales) {
        const { lines, taxes } = await read(db, sale.id);
        const ofTax = new Map(taxes.map((tax) => [tax.tax_id, tax]));
        for (const line of lines.filter((each) => each.tax_id !== null)) {
          const tax = ofTax.get(line.tax_id) as Tax;
          expect(line.vat_category, `${sale.ref} category`).toBe(tax.vat_category);
          expect(line.vat_category, `${sale.ref} category`).not.toBeNull();
          expect(Number(line.vat_rate), `${sale.ref} rate`).toBe(Number(tax.tax_rate));
        }
      }
    });

    it('says why, wherever a sale of the year charges nothing', async () => {
      // An exempt sale, an export and a reverse charge have to give a reason
      // (BR-E-10, BR-G-10, BR-AE-10, BR-IC-10, BR-O-10): a code where the pack
      // has one on a published list, the sentence it prints on such an invoice
      // where it has not. Either satisfies the rule.
      const said = new Set<string>();
      for (const sale of sales) {
        const document = await read(db, sale.id);
        const { file, violations } = generatePeppolUbl(document);
        const codes = violations.map((violation) => violation.code);
        expect(codes.filter((code) => /^BR-(E|G|AE|IC|O)-10$/.test(code)), sale.ref).toEqual([]);
        for (const tax of document.taxes.filter((each) => EXEMPTING[each.vat_category ?? ''])) {
          expect(file, sale.ref).toMatch(/<cbc:TaxExemptionReason(Code)?>/);
          said.add(tax.vat_category as string);
        }
      }
      // The year has to sell something that charges nothing, or this proved nothing.
      expect(said.size, 'categories that charge nothing, in this golden year').toBeGreaterThan(0);
    });

    it('writes an invoice with nothing wrong in it, once it is told what an invoice is told', async () => {
      // The first taxed sale of the scenario, posted again with what a customer
      // on the network gives its supplier: an address, an order, a due date.
      const model = golden.documents.find((document) => document.type === 'sale_invoice' && document.lines.every((line) => line.tax !== null)) as (typeof golden.documents)[number];
      const buyer = await one<{ id: string }>(
        db,
        `insert into contacts (company_id, name, contact_type, country, address_line1, postal_code, city,
                               peppol_scheme, peppol_identifier)
         values ($1, 'Demo Buyer', 'customer', $2, 'Invented Avenue 2', '2000', 'Demo Town', '0088', '5412345000013')
         returning id`,
        [companyId, pack.manifest.country],
      );
      const document = await one<{ id: string }>(
        db,
        `insert into documents (company_id, doc_type, contact_id, document_date, due_date, buyer_reference,
                                payment_means_code, payee_iban, payment_reference)
         values ($1, 'sale_invoice', $2, $3::date, ($3::date + 30), 'PO-0001', '30', 'BE68539007547034', 'INV-REF-1')
         returning id`,
        [companyId, buyer.id, model.date],
      );
      for (const [index, line] of model.lines.entries()) {
        await db.query(
          `insert into document_lines (document_id, company_id, sequence, name, quantity, unit_price,
                                       discount_percent, tax_id, account_id)
           values ($1, $2, $3, $4, 3, 33.33, 12.5,
                   (select id from taxes where company_id = $2 and code = $5), account_id_by_code($2, $6))`,
          [document.id, companyId, (index + 1) * 10, line.name, line.tax, line.account],
        );
      }
      await db.query(`select post_document($1)`, [document.id]);

      // Three reads and no option: nothing is told to the brick that the books
      // do not hold.
      const sendable = await read(db, document.id);
      const { file, filename, violations } = generatePeppolUbl(sendable);
      expect(violations).toEqual([]);
      expect(await schemaErrors(file)).toEqual([]);
      expect(filename).toMatch(/^invoice-.+\.xml$/);

      // 3 × 33.33 less 12.5 %: a line the books round once, and a price the
      // file carries unrounded — 29.16375 — so that the two still agree.
      const back = readBack(file);
      const booked = await one<{ amount_untaxed: string; amount_total: string }>(
        db,
        `select amount_untaxed::text, amount_total::text from documents where id = $1`,
        [document.id],
      );
      expect(back.taxExclusive).toBe(cents(booked.amount_untaxed));
      expect(back.taxInclusive).toBe(cents(booked.amount_total));
      expect(file).toContain('>29.16375</cbc:PriceAmount>');
      expect(file).toContain('<cbc:EndpointID schemeID="0088">5412345000020</cbc:EndpointID>');
      expect(file).toContain('<cbc:EndpointID schemeID="0088">5412345000013</cbc:EndpointID>');
    });
  });
}
