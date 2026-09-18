/**
 * Contacts: the people and the companies the books name.
 */

import { BooksError, type Backend, type Filter, type Row } from './backend.js';
import * as columns from './columns.js';
import { createdBefore, only } from './shared.js';
import type { ContactType } from '../types.js';

export const CONTACT_TYPES = ['customer', 'supplier', 'both', 'employee', 'other'] as const satisfies readonly ContactType[];

export interface CreateContactArgs {
  company_id: string;
  name: string;
  /** Left out, the database's own default applies. */
  contact_type?: ContactType | undefined;
  vat_number?: string | undefined;
  email?: string | undefined;
  country?: string | undefined;
  payment_terms_days?: number | undefined;
  auxiliary_code?: string | undefined;
  address_line1?: string | undefined;
  postal_code?: string | undefined;
  city?: string | undefined;
  /** Your own reference. Creating twice under one reference creates once. */
  client_ref?: string | undefined;
}

export interface SearchContactsArgs {
  company_id: string;
  query?: string | undefined;
  contact_type?: ContactType | undefined;
  vat_number?: string | undefined;
  limit?: number | undefined;
}

export async function createContact(
  backend: Backend,
  args: CreateContactArgs,
): Promise<unknown> {
  const before = await createdBefore(backend, 'contacts', args.company_id, args.client_ref, columns.CONTACT);
  if (before !== undefined) return { contact: before, replayed: true };

  const { company_id, ...rest } = args;
  const row: Row = { company_id, ...rest };
  const created = only(
    await backend.insert<Row>('contacts', [row], columns.CONTACT),
    'the contact could not be created',
  );
  return { contact: created };
}

export async function searchContacts(
  backend: Backend,
  args: SearchContactsArgs,
): Promise<unknown> {
  const where: Filter[] = [{ column: 'company_id', op: 'eq', value: args.company_id }];
  if (args.query !== undefined) where.push({ column: 'name', op: 'ilike', value: `%${args.query}%` });
  if (args.contact_type !== undefined) where.push({ column: 'contact_type', op: 'eq', value: args.contact_type });
  if (args.vat_number !== undefined) where.push({ column: 'vat_number', op: 'eq', value: args.vat_number });

  const contacts = await backend.select<Row>({
    table: 'contacts',
    columns: columns.CONTACT,
    where,
    order: [{ column: 'name' }],
    limit: args.limit ?? 50,
  });
  return { contacts, count: contacts.length };
}

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/**
 * The contact a person means by an id, a name or part of one.
 *
 * One match is the answer; several are listed and refused, because an invoice
 * addressed to the wrong one of two namesakes is posted before anybody
 * notices. An exact name wins over names that merely contain it.
 */
export async function resolveContact(
  backend: Backend,
  company: string,
  wanted: string,
): Promise<{ id: string; name: string }> {
  if (UUID.test(wanted)) return { id: wanted.toLowerCase(), name: wanted };
  const found = await backend.select<{ id: string; name: string }>({
    table: 'contacts',
    columns: ['id', 'name'],
    where: [
      { column: 'company_id', op: 'eq', value: company },
      { column: 'name', op: 'ilike', value: `%${wanted}%` },
    ],
    order: [{ column: 'name' }],
    limit: 20,
  });
  const exact = found.filter((contact) => contact.name.toLowerCase() === wanted.toLowerCase());
  const matches = exact.length > 0 ? exact : found;
  if (matches.length === 0) {
    throw new BooksError(`unknown_contact: no contact of this company is called ${wanted}, or has it in its name.`);
  }
  if (matches.length > 1) {
    throw new BooksError(
      `ambiguous_contact: ${wanted} is ${matches.length} contacts: ${matches
        .map((contact) => `${contact.name} (${contact.id})`)
        .join(', ')}. Name one by its id.`,
    );
  }
  return matches[0] as { id: string; name: string };
}
