/**
 * `ekwo contact add` and `ekwo contact list` — `createContact()` and
 * `searchContacts()` of the core, which are the MCP server's `create_contact`
 * and `search_contacts`.
 */

import { CONTACT_TYPES, createContact, searchContacts, type ContactType, type CreateContactArgs } from '@ekwo-ai/core';
import { UsageError, numberFlag, rejectUnknownFlags, stringFlag, type ParsedArgs } from '../args.js';
import { BOOKS_FLAGS, CREATE_FLAGS, given, openBooks, stdinDocument, type BooksDeps } from '../books.js';
import { setResult } from '../output.js';
import { dim, heading, note, step, table } from '../ui.js';

const ADD_FLAGS = [...CREATE_FLAGS, 'type', 'vat', 'email', 'country', 'terms', 'aux', 'address', 'postal-code', 'city'] as const;
const LIST_FLAGS = [...BOOKS_FLAGS, 'query', 'type', 'vat', 'limit'] as const;

const ADD_FIELDS = [
  'name', 'contact_type', 'vat_number', 'email', 'country', 'payment_terms_days', 'auxiliary_code',
  'address_line1', 'postal_code', 'city', 'client_ref',
] as const;

function contactType(value: string | undefined): ContactType | undefined {
  if (value === undefined) return undefined;
  if (!(CONTACT_TYPES as readonly string[]).includes(value)) {
    throw new UsageError(`bad_type: --type is one of ${CONTACT_TYPES.join(', ')}, got "${value}".`);
  }
  return value as ContactType;
}

export async function contactCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  const action = args.positional[0];
  if (action === 'add') return add(args, deps);
  if (action === 'list') return list(args, deps);
  throw new UsageError('usage: ekwo contact add <name> [--type --vat --email --country --terms --ref] | ekwo contact list [--query --type --vat]');
}

async function add(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, ADD_FLAGS);
  const input = await stdinDocument(args, deps, ADD_FIELDS);
  const { backend, company } = await openBooks(args, deps);

  const fields = given({
    ...input,
    name: args.positional[1] ?? input['name'],
    contact_type: contactType(stringFlag(args, 'type')) ?? input['contact_type'],
    vat_number: stringFlag(args, 'vat') ?? input['vat_number'],
    email: stringFlag(args, 'email') ?? input['email'],
    country: stringFlag(args, 'country') ?? input['country'],
    payment_terms_days: numberFlag(args, 'terms') ?? input['payment_terms_days'],
    auxiliary_code: stringFlag(args, 'aux') ?? input['auxiliary_code'],
    address_line1: stringFlag(args, 'address') ?? input['address_line1'],
    postal_code: stringFlag(args, 'postal-code') ?? input['postal_code'],
    city: stringFlag(args, 'city') ?? input['city'],
    client_ref: stringFlag(args, 'ref') ?? input['client_ref'],
  });
  if (typeof fields.name !== 'string' || fields.name.length === 0) {
    throw new UsageError('missing_argument: the name of the contact. `ekwo contact add "<name>"`, or `name` under --stdin.');
  }

  const result = (await createContact(backend, { ...fields, company_id: company.id } as CreateContactArgs)) as {
    contact: Record<string, unknown>;
    replayed?: boolean;
  };
  setResult(result);

  heading('Contact');
  const contact = result.contact;
  if (result.replayed === true) note(dim(`already created under the reference ${String(contact['client_ref'])}; nothing was written`));
  step(`${String(contact['name'])} ${dim(String(contact['id']))}, in ${company.name}`);
  return 0;
}

async function list(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, LIST_FLAGS);
  const { backend, company } = await openBooks(args, deps);
  const result = (await searchContacts(backend, given({
    company_id: company.id,
    query: stringFlag(args, 'query'),
    contact_type: contactType(stringFlag(args, 'type')),
    vat_number: stringFlag(args, 'vat'),
    limit: numberFlag(args, 'limit'),
  }))) as { contacts: Record<string, unknown>[]; count: number };
  setResult(result);

  heading(`Contacts of ${company.name}`);
  if (result.contacts.length === 0) note(dim('None.'));
  else {
    table(
      [{ title: 'name' }, { title: 'type' }, { title: 'vat' }, { title: 'id' }],
      result.contacts.map((c) => [String(c['name']), String(c['contact_type']), String(c['vat_number'] ?? ''), dim(String(c['id']))]),
    );
  }
  return 0;
}
