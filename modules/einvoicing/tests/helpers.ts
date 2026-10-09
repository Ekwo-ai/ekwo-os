import type { PGlite } from '@electric-sql/pglite';
import { EINVOICE_FORMATS, type Backend } from '@ekwo-ai/core';
import { asUser, one } from '../../../tests/helpers/db.js';
import { newCompany, newUser, type Fixture } from '../../../tests/helpers/factory.js';
import { packWhere, roleOf } from '../../../tests/helpers/packs.js';
import { backendFor } from '../../../tests/mcp/helpers.js';
import type { Pack } from '../../../packages/cli/src/index.js';

// Everything a test of this module needs to keep books in a country it does
// not name. A pack is chosen for what it declares — a profile a brick writes,
// one no brick writes, none at all — and every code a document carries is
// read from that pack: its standard sale tax, the account its chart gives the
// role of sales. A new pack that declares a profile is exercised here the day
// it lands, without a line of this file changing.

type PackTax = Pack['taxes'][number];

/** The tax a pack charges on an ordinary domestic sale: its highest rate with a category. */
export function standardTaxOf(pack: Pack): PackTax | undefined {
  return pack.taxes
    .filter(
      (tax) =>
        tax.scope === 'sale' &&
        tax.amount_type === 'percent' &&
        tax.valid_to === null &&
        !tax.price_include &&
        tax.treatment === 'domestic' &&
        tax.rate > 0 &&
        tax.vat_category !== null,
    )
    .sort((a, b) => b.rate - a.rate)[0];
}

/** The profile a pack declares, as the socle compiles it. */
export const profileOf = (pack: Pack): string | null => pack.documents.einvoice_profile;

/** A pack that issues in `profile`, and can book an ordinary sale. */
export function packIssuing(profile: string): Pack {
  return packWhere(
    `declares the e-invoicing profile ${profile} and charges a standard rate`,
    (pack) => profileOf(pack) === profile && standardTaxOf(pack) !== undefined,
  );
}

/** A pack whose profile no brick of this release writes. */
export function packWithoutBrick(): Pack {
  return packWhere(
    'declares an e-invoicing profile that no brick writes',
    (pack) => profileOf(pack) !== null && EINVOICE_FORMATS[profileOf(pack) as string] === undefined && standardTaxOf(pack) !== undefined,
  );
}

/** A pack that declares no profile at all. */
export function packWithoutProfile(): Pack {
  return packWhere(
    'declares no e-invoicing profile',
    (pack) => profileOf(pack) === null && standardTaxOf(pack) !== undefined,
  );
}

/** A company of a pack with the module on, an accountant beside its owner, and a customer on the network. */
export interface Seller extends Fixture {
  pack: Pack;
  accountantId: string;
  viewerId: string;
  customerId: string;
  /** A customer the books know no electronic address for. */
  unreachableId: string;
  tax: string;
  sales: string;
  backend: Backend;
}

/**
 * A seller whose books say everything an electronic invoice is told: who it
 * is, where it is, its VAT number and its electronic address — invented, in
 * the shapes the rules check — and a customer with an address and an
 * electronic address of its own.
 */
export async function seller(db: PGlite, pack: Pack, name: string, options: { enable?: boolean } = {}): Promise<Seller> {
  const country = pack.manifest.country;
  const fixture = await newCompany(db, { country, name });
  await db.query(
    `update companies
        set legal_name = $2, vat_number = $3, registration_number = '99999999',
            address_line1 = 'Invented Street 1', postal_code = '1000', city = 'Demo City',
            peppol_scheme = '0088', peppol_identifier = '5412345000020'
      where id = $1`,
    [fixture.companyId, name, `${country}999999999`],
  );
  const customer = async (label: string, reachable: boolean): Promise<string> =>
    (
      await one<{ id: string }>(
        db,
        `insert into contacts (company_id, name, contact_type, country, address_line1, postal_code, city,
                               peppol_scheme, peppol_identifier)
         values ($1, $2, 'customer', $3, 'Invented Avenue 2', '2000', 'Demo Town', $4, $5)
         returning id`,
        [fixture.companyId, label, country, reachable ? '0088' : null, reachable ? '5412345000013' : null],
      )
    ).id;

  const accountantId = await newUser(db, `accountant@${fixture.companyId}.test`);
  const viewerId = await newUser(db, `viewer@${fixture.companyId}.test`);
  await db.query(
    `insert into company_members (company_id, user_id, role) values ($1, $2, 'accountant'), ($1, $3, 'viewer')`,
    [fixture.companyId, accountantId, viewerId],
  );
  if (options.enable !== false) {
    await asUser(db, fixture.ownerId, () => db.query(`select enable_module($1, 'einvoicing')`, [fixture.companyId]));
  }
  return {
    ...fixture,
    pack,
    accountantId,
    viewerId,
    customerId: await customer('Demo Buyer', true),
    unreachableId: await customer('Paper Buyer', false),
    tax: (standardTaxOf(pack) as PackTax).code,
    sales: roleOf(pack, 'sales'),
    backend: backendFor(db, accountantId),
  };
}

export interface Sale {
  docType?: 'sale_invoice' | 'sale_credit_note';
  contactId?: string;
  /** The invoice a credit note credits. */
  credits?: string;
  date?: string;
  lines?: { name: string; quantity: string; price: string; discount?: string }[];
  post?: boolean;
}

/**
 * A sale as a customer on the network expects it — an order reference, a due
 * date, a payment means and an account — posted unless asked otherwise.
 */
export async function sale(db: PGlite, s: Seller, input: Sale = {}): Promise<string> {
  const document = await one<{ id: string }>(
    db,
    `insert into documents (company_id, doc_type, contact_id, document_date, due_date, buyer_reference,
                            payment_means_code, payee_iban, payment_reference, reversed_document_id)
     values ($1, $2, $3, $4::date, ($4::date + 30), 'PO-0001', '30', 'BE68539007547034', 'REF-1', $5)
     returning id`,
    [s.companyId, input.docType ?? 'sale_invoice', input.contactId ?? s.customerId, input.date ?? '2026-06-15', input.credits ?? null],
  );
  let sequence = 0;
  for (const line of input.lines ?? [
    { name: 'Consulting', quantity: '3', price: '33.33', discount: '12.5' },
    { name: 'Licence', quantity: '1', price: '1200.00' },
  ]) {
    sequence += 10;
    await db.query(
      `insert into document_lines (document_id, company_id, sequence, name, quantity, unit_price, discount_percent,
                                   tax_id, account_id)
       values ($1, $2, $3, $4, $5::numeric, $6::numeric, $7::numeric,
               (select id from taxes where company_id = $2 and code = $8), account_id_by_code($2, $9))`,
      [document.id, s.companyId, sequence, line.name, line.quantity, line.price, line.discount ?? '0', s.tax, s.sales],
    );
  }
  if (input.post !== false) await db.query(`select post_document($1)`, [document.id]);
  return document.id;
}

/** A decimal without the zeros that say nothing, compared as text. */
export function decimal(value: string | null | undefined): string | null {
  if (value === null || value === undefined) return null;
  const [whole, fraction = ''] = value.split('.');
  const trimmed = fraction.replace(/0+$/, '');
  return trimmed === '' ? (whole as string) : `${whole as string}.${trimmed}`;
}
