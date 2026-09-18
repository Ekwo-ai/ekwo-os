/**
 * What the core has to say for a posted invoice to be sendable.
 *
 * The brick that writes a Peppol invoice reads three views and nothing else,
 * and its end-to-end test found four things the views could not tell it. These
 * tests hold the four, in the core, where no brick is involved:
 *
 *   1. a line carries the category and the rate of its tax — BT-151, BT-152 —
 *      following the tax while the document is a draft and frozen from the
 *      moment it is posted, and the VAT breakdown reads the line. A tax that
 *      changes afterwards rewrites no invoice that was sent: not its lines,
 *      not its breakdown, not its totals;
 *   2. the lines that were there before the core wrote the snapshot take the
 *      tax as it stands, once, and no figure moves;
 *   3. a company has an electronic address, a scheme and a value, whole or
 *      absent, and who may write it is who may write the company;
 *   4. the header carries the tax point, the delivery and both electronic
 *      addresses, and the breakdown says why a group charges nothing — in the
 *      pack's code, and in the sentence the pack puts on such an invoice, in
 *      the language of the document.
 *
 * Every expectation is read from the pack whose books are being kept: which
 * tax is the standard one, which charges nothing and has a sentence for it,
 * what that sentence is. No category, rate or country is written down here.
 */

import { PGlite } from '@electric-sql/pglite';
import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { Pack } from '../packages/cli/src/index.js';
import {
  asUser,
  expectError,
  freshDatabase,
  migrationFiles,
  one,
  repoRoot,
  rows,
  seedFiles,
  shimPath,
} from './helpers/db.js';
import { newCompany, newContact, newDocument, newUser, taxId } from './helpers/factory.js';
import { packWhere, roleOf } from './helpers/packs.js';

/**
 * The migration that writes the snapshot, and the one after it that replaces
 * the same view with more columns — which therefore cannot come first.
 */
const SNAPSHOT = [
  '20260918141107_a_line_keeps_the_tax_it_was_posted_with.sql',
  '20260918141605_an_invoice_reads_whole_from_the_views.sql',
  // Published after the backfill it would refuse: on a real database the
  // posted lines were filled before anything froze them, and so they are here.
  '20260918161204_a_posted_document_does_not_move.sql',
];

/** The treatments each condition of a legal mention covers — the vocabulary of `applies_when`, as the schema documents it. */
const CONDITION_OF: Record<string, string> = {
  domestic_reverse_charge: 'reverse_charge',
  intracom_goods: 'intra_eu_goods',
  intracom_services: 'intra_eu_services',
  export: 'export',
  exempt: 'exempt',
};

type PackTax = Pack['taxes'][number];

const onSale = (tax: PackTax): boolean =>
  tax.scope === 'sale' && tax.amount_type === 'percent' && tax.valid_to === null && !tax.price_include;

/** The tax a pack charges on an ordinary sale: the highest domestic rate it has. */
function standardTaxOf(pack: Pack): PackTax | undefined {
  return pack.taxes
    .filter((tax) => onSale(tax) && tax.treatment === 'domestic' && tax.rate > 0 && tax.vat_category !== null)
    .sort((a, b) => b.rate - a.rate)[0];
}

/** A sale that charges nothing, whose treatment the pack has a sentence for — in more than one language. */
function reasonedTaxOf(pack: Pack): PackTax | undefined {
  return pack.taxes.find(
    (tax) =>
      onSale(tax) &&
      tax.exemption_code !== null &&
      pack.documents.mentions.some(
        (mention) => mention.applies_when === CONDITION_OF[tax.treatment] && Object.keys(mention.text_i18n).length > 0,
      ),
  );
}

let db: PGlite;
let pack: Pack;
let companyId: string;
let ownerId: string;
let customerId: string;
let standard: PackTax;
let reasoned: PackTax;
let salesAccount: string;

beforeAll(async () => {
  pack = packWhere(
    'charges a standard rate, and has a coded sale that charges nothing with a sentence to say so in two languages',
    (p) => standardTaxOf(p) !== undefined && reasonedTaxOf(p) !== undefined,
  );
  standard = standardTaxOf(pack) as PackTax;
  reasoned = reasonedTaxOf(pack) as PackTax;
  salesAccount = roleOf(pack, 'sales');

  db = await freshDatabase();
  ({ companyId, ownerId } = await newCompany(db, { country: pack.manifest.country, name: 'Sendable' }));
  customerId = await newContact(db, companyId, { country: pack.manifest.country });
}, 180_000);

afterAll(async () => {
  await db.close();
});

interface LineSnapshot {
  vat_category: string | null;
  vat_rate: string | null;
}

const snapshotOf = (documentId: string): Promise<LineSnapshot[]> =>
  rows<LineSnapshot>(
    db,
    `select vat_category, vat_rate::text from document_lines where document_id = $1 order by sequence`,
    [documentId],
  );

const rate = (value: number): string => value.toFixed(4);

describe('the category and the rate a line carries', () => {
  it('are those of its tax, whatever the caller keyed', async () => {
    const documentId = await newDocument(db, companyId, {
      docType: 'sale_invoice',
      contactId: customerId,
      lines: [{ unitPrice: 100, taxCode: standard.code, accountCode: salesAccount }],
    });
    expect(await snapshotOf(documentId)).toEqual([{ vat_category: standard.vat_category, vat_rate: rate(standard.rate) }]);

    // Derived, never keyed: a draft answers with its tax again.
    await db.query(`update document_lines set vat_category = 'O', vat_rate = 1 where document_id = $1`, [documentId]);
    expect(await snapshotOf(documentId)).toEqual([{ vat_category: standard.vat_category, vat_rate: rate(standard.rate) }]);
  });

  it('are absent from a line that bills nothing, and from a line without a tax', async () => {
    const documentId = await newDocument(db, companyId, {
      docType: 'sale_invoice',
      contactId: customerId,
      lines: [{ unitPrice: 100, taxCode: null, accountCode: salesAccount }],
    });
    await db.query(
      `insert into document_lines (document_id, company_id, sequence, line_type, name, tax_id)
       values ($1, $2, 20, 'section', 'A heading', $3)`,
      [documentId, companyId, await taxId(db, companyId, standard.code)],
    );
    expect(await snapshotOf(documentId)).toEqual([
      { vat_category: null, vat_rate: null },
      { vat_category: null, vat_rate: null },
    ]);
  });

  it('follow the tax for as long as the document is a draft, and the totals with them', async () => {
    const documentId = await newDocument(db, companyId, {
      docType: 'sale_invoice',
      contactId: customerId,
      lines: [{ unitPrice: 200, taxCode: standard.code, accountCode: salesAccount }],
    });
    const tax = await taxId(db, companyId, standard.code);
    const moved = standard.rate + 1;

    await db.query(`update taxes set amount = $2 where id = $1`, [tax, moved]);
    try {
      expect(await snapshotOf(documentId)).toEqual([{ vat_category: standard.vat_category, vat_rate: rate(moved) }]);
      const totals = await one<{ amount_tax: string }>(db, `select amount_tax::text from documents where id = $1`, [documentId]);
      expect(Number(totals.amount_tax)).toBeCloseTo((200 * moved) / 100, 2);
    } finally {
      await db.query(`update taxes set amount = $2 where id = $1`, [tax, standard.rate]);
    }
    expect(await snapshotOf(documentId)).toEqual([{ vat_category: standard.vat_category, vat_rate: rate(standard.rate) }]);
  });
});

describe('a posted invoice, and a tax that changes after it', () => {
  let documentId: string;
  let tax: string;
  let before: { lines: LineSnapshot[]; summary: unknown[]; totals: unknown };

  const read = async () => ({
    lines: await snapshotOf(documentId),
    summary: await rows(
      db,
      `select vat_category, tax_rate::text, base_amount::text, tax_amount::text, tax_charged::text
         from document_tax_summary where document_id = $1`,
      [documentId],
    ),
    totals: await one(
      db,
      `select amount_untaxed::text, amount_tax::text, amount_total::text from documents where id = $1`,
      [documentId],
    ),
  });

  beforeAll(async () => {
    documentId = await newDocument(db, companyId, {
      docType: 'sale_invoice',
      contactId: customerId,
      lines: [{ unitPrice: 300, taxCode: standard.code, accountCode: salesAccount }],
    });
    await db.query(`select post_document($1)`, [documentId]);
    tax = await taxId(db, companyId, standard.code);
    before = await read();
  });

  it('carries the tax it was posted with', () => {
    expect(before.lines).toEqual([{ vat_category: standard.vat_category, vat_rate: rate(standard.rate) }]);
    expect(before.summary).toHaveLength(1);
  });

  it('keeps its lines, its breakdown and its totals when the rate and the category move', async () => {
    await db.query(`update taxes set amount = $2, vat_category = 'O' where id = $1`, [tax, standard.rate + 1]);
    try {
      expect(await read()).toEqual(before);
      // Touching the line is what used to recompute a sent invoice at the
      // rate of the day: the totals are refreshed from the breakdown on every
      // write of a line, and the breakdown read the tax. A line of a posted
      // document is no longer touched at all — `tests/posted_document.test.ts`
      // — so the figures are asked for again the way the trigger would.
      await db.query(`select documents_refresh_totals($1)`, [documentId]);
      expect(await read()).toEqual(before);
    } finally {
      await db.query(`update taxes set amount = $2, vat_category = $3 where id = $1`, [
        tax,
        standard.rate,
        standard.vat_category,
      ]);
    }
  });

  it('refuses by name to have either rewritten', async () => {
    for (const change of [`vat_rate = 0`, `vat_category = 'O'`, `vat_category = null`]) {
      const message = await expectError(db, `update document_lines set ${change} where document_id = $1`, [documentId]);
      expect(message, change).toMatch(/^document_posted\b.*vat_/);
    }
    expect(await read()).toEqual(before);
  });
});

describe('the lines that were there before the core wrote the snapshot', () => {
  it('take the tax as it stands, once, keep a stamp somebody wrote, and no total moves', async () => {
    // Every migration but these, rather than every migration older: the seeds
    // are the output of the packs at head and ask for the schema at head.
    const files = await migrationFiles();
    expect(files).toEqual(expect.arrayContaining(SNAPSHOT));

    const old = new PGlite();
    await old.waitReady;
    try {
      await old.exec(await readFile(shimPath, 'utf8'));
      for (const file of files.filter((name) => !SNAPSHOT.includes(name))) {
        await old.exec(await readFile(join(repoRoot, 'supabase', 'migrations', file), 'utf8'));
      }
      for (const file of await seedFiles()) {
        await old.exec(await readFile(join(repoRoot, 'supabase', 'seed', file), 'utf8'));
      }
      await old.exec(`select set_config('ekwo.installing', 'on', false);`);

      const company = await newCompany(old, { country: pack.manifest.country, name: 'Before' });
      const contact = await newContact(old, company.companyId, { country: pack.manifest.country });
      const line = { unitPrice: 123.45, taxCode: standard.code, accountCode: salesAccount };
      const silent = await newDocument(old, company.companyId, { docType: 'sale_invoice', contactId: contact, lines: [line] });
      const stamped = await newDocument(old, company.companyId, { docType: 'sale_invoice', contactId: contact, lines: [line] });
      const draft = await newDocument(old, company.companyId, { docType: 'sale_invoice', contactId: contact, lines: [line] });
      await old.query(`select post_document($1)`, [silent]);
      await old.query(`select post_document($1)`, [stamped]);
      // What an application did while the core did not: its own stamp, which
      // is evidence of the day and is kept.
      await old.query(`update document_lines set vat_category = 'Z', vat_rate = 0 where document_id = $1`, [stamped]);

      const totals = () =>
        rows(old, `select id, amount_untaxed::text, amount_tax::text, amount_total::text from documents order by id`);
      const before = await totals();
      expect(
        await rows(old, `select 1 from document_lines where document_id = $1 and vat_category is not null`, [silent]),
      ).toEqual([]);

      for (const file of SNAPSHOT) {
        await old.exec(await readFile(join(repoRoot, 'supabase', 'migrations', file), 'utf8'));
      }

      const carried = (id: string) =>
        rows<LineSnapshot>(old, `select vat_category, vat_rate::text from document_lines where document_id = $1`, [id]);
      const fromTheTax = [{ vat_category: standard.vat_category, vat_rate: rate(standard.rate) }];
      expect(await carried(silent)).toEqual(fromTheTax);
      expect(await carried(draft)).toEqual(fromTheTax);
      expect(await carried(stamped)).toEqual([{ vat_category: 'Z', vat_rate: rate(0) }]);

      const after = await totals();
      expect(after.filter((row) => (row as { id: string }).id !== stamped)).toEqual(
        before.filter((row) => (row as { id: string }).id !== stamped),
      );
    } finally {
      await old.close();
    }
  }, 300_000);
});

describe('the electronic address of the company', () => {
  const address = (): Promise<{ peppol_scheme: string | null; peppol_identifier: string | null }> =>
    one(db, `select peppol_scheme, peppol_identifier from companies where id = $1`, [companyId]);

  it('is a scheme and a value, whole or absent', async () => {
    expect(await expectError(db, `update companies set peppol_scheme = '0088' where id = $1`, [companyId])).toMatch(
      /companies_electronic_address_whole/,
    );
    expect(
      await expectError(db, `update companies set peppol_identifier = '5412345000013' where id = $1`, [companyId]),
    ).toMatch(/companies_electronic_address_whole/);
  });

  it('is written by whoever may write the company, and by nobody else', async () => {
    const accountant = await newUser(db, 'accountant@sendable.test');
    const stranger = await newUser(db, 'stranger@sendable.test');
    await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'accountant')`, [
      companyId,
      accountant,
    ]);
    const write = `update companies set peppol_scheme = '0088', peppol_identifier = '5412345000013' where id = $1`;

    // Row level security does not raise on an update: it finds no row.
    await asUser(db, accountant, () => db.query(write, [companyId]));
    await asUser(db, stranger, () => db.query(write, [companyId]));
    expect(await address()).toEqual({ peppol_scheme: null, peppol_identifier: null });

    await asUser(db, ownerId, () => db.query(write, [companyId]));
    expect(await address()).toEqual({ peppol_scheme: '0088', peppol_identifier: '5412345000013' });

    // Reading it is reading the company.
    expect(await asUser(db, accountant, address)).toEqual(await address());
    expect(await asUser(db, stranger, () => rows(db, `select 1 from companies where id = $1`, [companyId]))).toEqual([]);
  });
});

describe('what the three views say of an invoice', () => {
  let documentId: string;
  let language: string;

  beforeAll(async () => {
    await db.query(`update companies set peppol_scheme = '0088', peppol_identifier = '5412345000013' where id = $1`, [companyId]);
    const buyer = await newContact(db, companyId, { name: 'On the network', country: pack.manifest.country });
    await db.query(`update contacts set peppol_scheme = '0088', peppol_identifier = '5412345000020' where id = $1`, [buyer]);
    documentId = await newDocument(db, companyId, {
      docType: 'sale_invoice',
      contactId: buyer,
      deliveryCountry: pack.manifest.country,
      lines: [
        { unitPrice: 100, taxCode: standard.code, accountCode: salesAccount },
        { unitPrice: 50, taxCode: reasoned.code, accountCode: salesAccount },
      ],
    });
    await db.query(
      `update documents
          set tax_point_date = document_date - 3, delivery_address_line1 = 'Invented Quay 3',
              delivery_postal_code = '3000', delivery_city = 'Demo Harbour'
        where id = $1`,
      [documentId],
    );
    ({ language } = await one<{ language: string }>(db, `select language from documents where id = $1`, [documentId]));
  });

  it('carries the tax point, the delivery and both electronic addresses in the header, for a member who reads it', async () => {
    const header = await asUser(db, ownerId, () =>
      one<Record<string, string | null>>(
        db,
        `select tax_point_date::text, (document_date - 3)::text as stated,
                delivery_address_line1, delivery_postal_code, delivery_city, delivery_country,
                seller_peppol_scheme, seller_peppol_identifier, buyer_peppol_scheme, buyer_peppol_identifier
           from document_header where document_id = $1`,
        [documentId],
      ),
    );
    expect(header.tax_point_date).toBe(header.stated);
    expect(header).toMatchObject({
      delivery_address_line1: 'Invented Quay 3',
      delivery_postal_code: '3000',
      delivery_city: 'Demo Harbour',
      delivery_country: pack.manifest.country, // country-literal: read from the pack, never written here
      seller_peppol_scheme: '0088',
      seller_peppol_identifier: '5412345000013',
      buyer_peppol_scheme: '0088',
      buyer_peppol_identifier: '5412345000020',
    });
  });

  it('gives a group that charges nothing its code and its sentence, and a group that charges something neither', async () => {
    const summary = await asUser(db, ownerId, () =>
      rows<{ tax_code: string; exemption_code: string | null; exemption_reason: string | null; legal_reference: string | null }>(
        db,
        `select tax_code, exemption_code, exemption_reason, legal_reference
           from document_tax_summary where document_id = $1`,
        [documentId],
      ),
    );
    const mentions = pack.documents.mentions
      .filter((mention) => mention.applies_when === CONDITION_OF[reasoned.treatment])
      .sort((a, b) => a.sequence - b.sequence)
      .map((mention) => mention.text_i18n[language] ?? mention.text);
    expect(mentions.length).toBeGreaterThan(0);

    const byCode = new Map(summary.map((row) => [row.tax_code, row]));
    expect(byCode.get(reasoned.code)).toEqual({
      tax_code: reasoned.code,
      exemption_code: reasoned.exemption_code,
      exemption_reason: mentions.join(' '),
      legal_reference: reasoned.legal_reference,
    });
    expect(byCode.get(standard.code)).toMatchObject({ exemption_code: null, exemption_reason: null });
  });

  it('says that sentence in the language the document was written in', async () => {
    const other = (pack.manifest.languages ?? []).find(
      (candidate) =>
        candidate !== language &&
        pack.documents.mentions.some(
          (mention) => mention.applies_when === CONDITION_OF[reasoned.treatment] && mention.text_i18n[candidate],
        ),
    );
    expect(other, 'the pack was chosen for having one').toBeDefined();
    if (other === undefined) return;

    await db.query(`update documents set language = $2 where id = $1`, [documentId, other]);
    const row = await one<{ exemption_reason: string }>(
      db,
      `select exemption_reason from document_tax_summary where document_id = $1 and tax_code = $2`,
      [documentId, reasoned.code],
    );
    const expected = pack.documents.mentions
      .filter((mention) => mention.applies_when === CONDITION_OF[reasoned.treatment])
      .sort((a, b) => a.sequence - b.sequence)
      .map((mention) => mention.text_i18n[other] ?? mention.text);
    expect(row.exemption_reason).toBe(expected.join(' '));
  });

  it('still prints the same sentences at the foot of the document', async () => {
    const printed = await rows<{ applies_when: string }>(
      db,
      `select applies_when from document_legal_mentions where document_id = $1`,
      [documentId],
    );
    expect(printed.map((mention) => mention.applies_when)).toContain(CONDITION_OF[reasoned.treatment]);
  });
});
