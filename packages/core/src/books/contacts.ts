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
    throw new BooksError(`unknown_contact: no contact of this company is called ${wanted}, or has it in its name.`, {
      hint: 'search_contacts (ekwo contact list) finds a contact by part of its name; create_contact (ekwo contact add) adds one.',
    });
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

export interface MergeContactsArgs {
  /** The contact that stays, and takes the history of the other. */
  keep_contact_id: string;
  /** The contact that is retired once everything naming it names the kept one. */
  absorb_contact_id: string;
}

/**
 * Merges two contacts of one company through `merge_contacts()` (decision
 * 0074): every row naming the absorbed contact — posted lines and issued
 * documents included — names the kept one, the learned motifs are folded, the
 * kept contact's empty fields are filled, and the absorbed contact is retired.
 * What moved and what was filled are the database's answer; the refusals are
 * its own, by name.
 */
export async function mergeContacts(backend: Backend, args: MergeContactsArgs): Promise<unknown> {
  const merge = only(
    await backend.rpc<Row>('merge_contacts', { p_keep: args.keep_contact_id, p_absorb: args.absorb_contact_id }),
    `contacts ${args.keep_contact_id} and ${args.absorb_contact_id} were not merged`,
  );
  const both = await backend.select<Row>({
    table: 'contacts',
    columns: [...columns.CONTACT, 'merged_into'],
    where: [{ column: 'id', op: 'in', value: [args.keep_contact_id, args.absorb_contact_id] }],
  });
  const byId = new Map(both.map((contact) => [String(contact['id']), contact]));
  return {
    merge: {
      id: merge['id'],
      kept_id: merge['kept_id'],
      absorbed_id: merge['absorbed_id'],
      moved: merge['moved'],
      filled: merge['filled'],
      merged_by: merge['merged_by'],
      merged_at: merge['merged_at'],
    },
    kept: byId.get(args.keep_contact_id) ?? null,
    absorbed: byId.get(args.absorb_contact_id) ?? null,
    note: 'Everything that named the absorbed contact names the kept one now, posted lines and issued documents included; the absorbed contact is retired, kept as the record of what was imported, and is named by no row again. There is no unmerge: the audit trail lists every line and document that moved.',
  };
}

export interface SuggestContactDuplicatesArgs {
  company_id: string;
}

/** One pair of contacts that are probably one party, as `suggest_contact_duplicates()` answers it. */
export interface ContactDuplicate {
  keep: { id: string; name: string; rows: number };
  absorb: { id: string; name: string; rows: number };
  score: number;
  method: string;
  because: string;
  evidence: string[];
}

/**
 * The pairs of contacts of a company that are probably one party, through
 * `suggest_contact_duplicates()` (decision 0075): the same VAT number,
 * registration number or bank account, the same name, or the words of one
 * name inside the other's. Each pair proposes the contact more rows name as
 * the one to keep; the person chooses, and `mergeContacts()` joins them.
 */
export async function suggestContactDuplicates(backend: Backend, args: SuggestContactDuplicatesArgs): Promise<unknown> {
  const found = await backend.rpc<Row>('suggest_contact_duplicates', { p_company_id: args.company_id });
  const pairs: ContactDuplicate[] = found.map((row) => ({
    keep: { id: String(row['keep_id']), name: String(row['keep_name']), rows: Number(row['keep_rows']) },
    absorb: { id: String(row['absorb_id']), name: String(row['absorb_name']), rows: Number(row['absorb_rows']) },
    score: Number(row['score']),
    method: String(row['method']),
    because: String(row['because']),
    evidence: (row['evidence'] as string[] | null) ?? [],
  }));
  return {
    pairs,
    count: pairs.length,
    note: 'Each pair is a proposal: the contact more ledger lines and documents name is proposed as the one to keep. Nothing is merged until a person chooses; merge_contacts joins a pair in either order. Two different VAT or registration numbers are two parties and are never proposed.',
  };
}
