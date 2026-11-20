import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { Pack, PackGoldenContact, PackGoldenDocument, PackTax } from '../packages/cli/src/index.js';
import { expectError, freshDatabase, one } from './helpers/db.js';
import { newCompany, newContact, newDocument } from './helpers/factory.js';
import { packWhere } from './helpers/packs.js';

/**
 * A buyer's certificate is held on the contact.
 *
 * A tax may say, in `conditions`, that it applies on a certificate the buyer
 * hands the seller. The word documented the question; `contact_tax_certificates`
 * records the answer, and a sale invoice under such a tax is refused at
 * posting unless its buyer holds one that covers it — on the document's date,
 * and for the place of supply where the certificate names a territory.
 *
 * Nothing below names a country. The pack under test is the one whose golden
 * scenario sells under such a tax to a buyer in a named territory, and the
 * sale, the buyer and the account come out of that scenario.
 */

function certified(tax: PackTax | undefined): boolean {
  return tax !== undefined && tax.scope === 'sale' && tax.conditions.includes('buyer_certificate');
}

/** The scenario's sale under a certificate, the tax it carries and its buyer. */
function certifiedSale(pack: Pack):
  | { document: PackGoldenDocument; tax: PackTax; buyer: PackGoldenContact }
  | undefined {
  for (const document of pack.golden?.documents ?? []) {
    if (document.type !== 'sale_invoice') continue;
    for (const line of document.lines) {
      const tax = pack.taxes.find((t) => t.code === line.tax);
      const buyer = pack.golden?.contacts.find((c) => c.ref === document.contact);
      if (certified(tax) && buyer !== undefined) return { document, tax: tax as PackTax, buyer };
    }
  }
  return undefined;
}

const pack: Pack = packWhere('a golden sale under a buyer certificate, to a buyer in a territory', (p) => {
  const sale = certifiedSale(p);
  return sale !== undefined && sale.buyer.territory !== null && sale.tax.applies_supply_territory !== null;
});
const { document: sale, tax, buyer } = certifiedSale(pack) as NonNullable<ReturnType<typeof certifiedSale>>;
const territory = buyer.territory as string;
const account = sale.lines[0]?.account as string;
const year = pack.golden?.fiscalYear as { name: string; start: string; end: string };

function shift(date: string, days: number): string {
  const d = new Date(`${date}T00:00:00Z`);
  d.setUTCDate(d.getUTCDate() + days);
  return d.toISOString().slice(0, 10);
}

describe('a sale under a tax that turns on a buyer certificate', () => {
  let db: PGlite;
  let companyId: string;
  let elsewhere: string;

  beforeAll(async () => {
    db = await freshDatabase({ modules: false });
    const fixture = await newCompany(db, {
      country: pack.manifest.country,
      chart: pack.golden?.chart ?? null,
      fiscalYear: year,
    });
    companyId = fixture.companyId;
    await db.query(`update companies set territory_code = $2 where id = $1`, [
      companyId,
      pack.golden?.territory ?? null,
    ]);
    // Another territory of the same level, which the place of supply is not in.
    const other = await one<{ code: string }>(
      db,
      `select t.code from territories t
        where t.parent_code = (select parent_code from territories where code = $1)
          and t.code <> $1
        order by t.code limit 1`,
      [territory],
    );
    elsewhere = other.code;
  }, 300_000);

  afterAll(async () => {
    await db.close();
  });

  async function reseller(): Promise<string> {
    return newContact(db, companyId, { type: 'customer', country: buyer.country, territory });
  }

  async function certificate(
    contactId: string,
    from: string,
    to: string | null = null,
    where: string | null = territory,
  ): Promise<void> {
    await db.query(
      `insert into contact_tax_certificates (company_id, contact_id, reference, territory_code, valid_from, valid_to)
       values ($1, $2, 'EXAMPLE-0001', $3, $4::date, $5::date)`,
      [companyId, contactId, where, from, to],
    );
  }

  async function invoice(contactId: string, docType = 'sale_invoice'): Promise<string> {
    return newDocument(db, companyId, {
      docType: docType as 'sale_invoice',
      contactId,
      date: sale.date,
      lines: [{ unitPrice: 1000, taxCode: tax.code, accountCode: account }],
    });
  }

  async function state(id: string): Promise<string> {
    return (await one<{ state: string }>(db, `select state from documents where id = $1`, [id])).state;
  }

  it('refuses it when the buyer holds no certificate, naming the tax', async () => {
    const id = await invoice(await reseller());
    const message = await expectError(db, `select post_document($1)`, [id]);
    expect(message).toContain('no_buyer_certificate');
    expect(message).toContain(tax.code);
    expect(await state(id)).toBe('draft');
  });

  it('refuses it under a certificate that ended before the sale', async () => {
    const contactId = await reseller();
    await certificate(contactId, shift(sale.date, -400), shift(sale.date, -1));
    const message = await expectError(db, `select post_document($1)`, [await invoice(contactId)]);
    expect(message).toContain('no_buyer_certificate');
  });

  it('refuses it under a certificate that starts after the sale', async () => {
    const contactId = await reseller();
    await certificate(contactId, shift(sale.date, 1));
    const message = await expectError(db, `select post_document($1)`, [await invoice(contactId)]);
    expect(message).toContain('no_buyer_certificate');
  });

  it('refuses it under a certificate given for another territory', async () => {
    const contactId = await reseller();
    await certificate(contactId, shift(sale.date, -30), null, elsewhere);
    const message = await expectError(db, `select post_document($1)`, [await invoice(contactId)]);
    expect(message).toContain('no_buyer_certificate');
  });

  it('books it under a certificate that covers the day and the place of supply', async () => {
    const contactId = await reseller();
    await certificate(contactId, sale.date, sale.date);
    const id = await invoice(contactId);
    await db.query(`select post_document($1)`, [id]);
    expect(await state(id)).toBe('posted');
    const covering = await one<{ reference: string }>(
      db,
      `select (buyer_certificate_for($1)).reference`,
      [id],
    );
    expect(covering.reference).toBe('EXAMPLE-0001');
  });

  it('books it under a certificate that names no territory', async () => {
    const contactId = await reseller();
    await certificate(contactId, shift(sale.date, -30), null, null);
    const id = await invoice(contactId);
    await db.query(`select post_document($1)`, [id]);
    expect(await state(id)).toBe('posted');
  });

  // A credit note reverses a sale that was: refusing it because a certificate
  // lapsed since would keep the wrong figure in the books.
  it('does not hold a credit note to it', async () => {
    const id = await invoice(await reseller(), 'sale_credit_note');
    await db.query(`select post_document($1)`, [id]);
    expect(await state(id)).toBe('posted');
  });

  it('refuses a certificate that ends before it starts, and one with no reference', async () => {
    const contactId = await reseller();
    expect(
      await expectError(
        db,
        `insert into contact_tax_certificates (company_id, contact_id, reference, valid_from, valid_to)
         values ($1, $2, 'EXAMPLE-0002', '2026-06-30', '2026-06-01')`,
        [companyId, contactId],
      ),
    ).toContain('contact_tax_certificates_period');
    expect(
      await expectError(
        db,
        `insert into contact_tax_certificates (company_id, contact_id, reference, valid_from)
         values ($1, $2, '  ', '2026-06-01')`,
        [companyId, contactId],
      ),
    ).toContain('contact_tax_certificates_reference_named');
  });
});
