/**
 * `ekwo contact add`, `ekwo contact list`, `ekwo contact duplicates`,
 * `ekwo contact merge`, `ekwo contact statement` and
 * `ekwo contact certificate add|list` — `createContact()`,
 * `searchContacts()`, `suggestDuplicateContacts()`, `mergeContacts()`,
 * `contactStatement()`, `recordTaxCertificate()` and `listTaxCertificates()`
 * of the core, which are the MCP server's `create_contact`,
 * `search_contacts`, `suggest_duplicate_contacts`, `merge_contacts`,
 * `contact_statement`, `record_tax_certificate` and `list_tax_certificates`.
 */

import {
  CONTACT_TYPES,
  contactStatement,
  createContact,
  listTaxCertificates,
  mergeContacts,
  recordTaxCertificate,
  resolveContact,
  searchContacts,
  suggestDuplicateContacts,
  type ContactType,
  type DuplicateContactPair,
  type CreateContactArgs,
} from '@ekwo-ai/core';
import { UsageError, numberFlag, rejectUnknownFlags, stringFlag, type ParsedArgs } from '../args.js';
import { BOOKS_FLAGS, CREATE_FLAGS, given, openBooks, stdinDocument, today, type BooksDeps } from '../books.js';
import { setResult } from '../output.js';
import { dim, heading, note, pairs, step, table } from '../ui.js';

const ADD_FLAGS = [...CREATE_FLAGS, 'type', 'vat', 'email', 'country', 'terms', 'aux', 'address', 'postal-code', 'city', 'account-scheme', 'account', 'bank-scheme', 'bank'] as const;
const LIST_FLAGS = [...BOOKS_FLAGS, 'query', 'type', 'vat', 'limit'] as const;
const MERGE_FLAGS = [...BOOKS_FLAGS] as const;
const DUPLICATES_FLAGS = [...BOOKS_FLAGS] as const;
const STATEMENT_FLAGS = [...BOOKS_FLAGS, 'from', 'to'] as const;
const CERTIFICATE_ADD_FLAGS = [...CREATE_FLAGS, 'from', 'to', 'territory', 'note'] as const;
const CERTIFICATE_LIST_FLAGS = [...BOOKS_FLAGS] as const;

const USAGE =
  'usage: ekwo contact add <name> [--type --vat --email --country --terms --account-scheme <scheme> --account <identifier> --bank-scheme <scheme> --bank <identifier> --ref] | ekwo contact list [--query --type --vat] | ekwo contact duplicates | ekwo contact merge <keep> <absorb> | ekwo contact statement <name|id> --from <date> [--to <date>] | ekwo contact certificate add <name|id> <reference> --from <date> [--to <date> --territory <code> --note --ref] | ekwo contact certificate list [<name|id>]';

const ADD_FIELDS = [
  'name', 'contact_type', 'vat_number', 'registration_number', 'identifiers', 'email', 'phone', 'country',
  'payment_terms_days', 'auxiliary_code', 'address_line1', 'postal_code', 'city',
  'account_scheme', 'account_identifier', 'bank_scheme', 'bank_identifier', 'client_ref',
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
  if (action === 'duplicates') return duplicates(args, deps);
  if (action === 'merge') return merge(args, deps);
  if (action === 'statement') return statement(args, deps);
  if (action === 'certificate' && args.positional[1] === 'add') return certificateAdd(args, deps);
  if (action === 'certificate' && args.positional[1] === 'list') return certificateList(args, deps);
  throw new UsageError(USAGE);
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
    // The party's account and bank, each a scheme of bank_identifier_schemes
    // and a value; a scheme is never assumed, an IBAN included.
    account_scheme: stringFlag(args, 'account-scheme') ?? input['account_scheme'],
    account_identifier: stringFlag(args, 'account') ?? input['account_identifier'],
    bank_scheme: stringFlag(args, 'bank-scheme') ?? input['bank_scheme'],
    bank_identifier: stringFlag(args, 'bank') ?? input['bank_identifier'],
    client_ref: stringFlag(args, 'ref') ?? input['client_ref'],
  });
  for (const [scheme, value, flag] of [
    ['account_scheme', 'account_identifier', 'account'],
    ['bank_scheme', 'bank_identifier', 'bank'],
  ] as const) {
    if ((fields[scheme] === undefined) !== (fields[value] === undefined)) {
      throw new UsageError(`missing_argument: --${flag}-scheme and --${flag} go together: a ${flag} identifier is read in the scheme named beside it.`);
    }
  }
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

async function duplicates(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, DUPLICATES_FLAGS);
  const { backend, company } = await openBooks(args, deps);
  const result = (await suggestDuplicateContacts(backend, { company_id: company.id })) as {
    pairs: DuplicateContactPair[];
    count: number;
    note: string;
  };
  setResult(result);

  heading(`Contacts that are probably one party, in ${company.name}`);
  if (result.pairs.length === 0) note(dim('None.'));
  else {
    table(
      [{ title: 'keep' }, { title: 'absorb' }, { title: 'score', align: 'right' }, { title: 'evidence' }, { title: 'name proposed' }],
      result.pairs.map((p) => [
        p.keep_name,
        p.absorb_name,
        String(p.score),
        p.evidence.join(', '),
        p.proposed_name === p.keep_name ? '' : p.proposed_name,
      ]),
    );
    note(
      dim(
        'The rows of one kept contact are one party. ekwo contact merge <keep> <absorb> joins a pair; --json gives the ids and the evidence in sentences.',
      ),
    );
  }
  return 0;
}

async function merge(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, MERGE_FLAGS);
  const [wantedKeep, wantedAbsorb] = [args.positional[1], args.positional[2]];
  if (wantedKeep === undefined || wantedAbsorb === undefined) {
    throw new UsageError(`missing_argument: the contact to keep and the contact to absorb, by name or id. ${USAGE}`);
  }
  const { backend, company } = await openBooks(args, deps);
  const keep = await resolveContact(backend, company.id, wantedKeep);
  const absorb = await resolveContact(backend, company.id, wantedAbsorb);

  const result = (await mergeContacts(backend, { keep_contact_id: keep.id, absorb_contact_id: absorb.id })) as {
    merge: { moved: Record<string, number>; filled: string[] };
    kept: Record<string, unknown> | null;
    absorbed: Record<string, unknown> | null;
    note: string;
  };
  setResult(result);

  heading(`Contacts merged, in ${company.name}`);
  pairs([
    ['kept', `${String(result.kept?.['name'] ?? keep.name)}  ${dim(keep.id)}`],
    ['absorbed', `${String(result.absorbed?.['name'] ?? absorb.name)}  ${dim(absorb.id)}`],
  ]);
  const moved = Object.entries(result.merge.moved);
  if (moved.length === 0) note(dim('Nothing named the absorbed contact.'));
  else table([{ title: 'moved' }, { title: 'rows' }], moved.map(([what, count]) => [what, String(count)]));
  if (result.merge.filled.length > 0) note(dim(`filled from the absorbed contact: ${result.merge.filled.join(', ')}`));
  note(dim(result.note));
  return 0;
}

async function statement(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, STATEMENT_FLAGS);
  const wanted = args.positional[1];
  if (wanted === undefined || wanted.length === 0) {
    throw new UsageError('missing_argument: the contact. `ekwo contact statement "<name|id>" --from <date>`.');
  }
  const from = stringFlag(args, 'from');
  if (from === undefined) {
    throw new UsageError('missing_argument: --from, the first day of the period. The balance carried forward is the one before it.');
  }
  const givenTo = stringFlag(args, 'to');
  const to = givenTo ?? today();
  const { backend, company } = await openBooks(args, deps);
  const contact = await resolveContact(backend, company.id, wanted);

  const result = (await contactStatement(backend, { company_id: company.id, contact_id: contact.id, from, to })) as {
    opening_balance: string;
    closing_balance: string;
    lines: Record<string, unknown>[];
    count: number;
  };
  setResult(result);

  heading(`Statement of ${contact.name}, ${from} to ${to}`);
  if (givenTo === undefined) note(dim(`to today, ${to}: no --to was given`));
  pairs([['carried forward', result.opening_balance]]);
  if (result.lines.length === 0) note(dim('No posted line in the period.'));
  else {
    const cell = (value: unknown): string => (value === null || value === undefined ? '' : String(value));
    table(
      [
        { title: 'date' }, { title: 'entry' }, { title: 'document' }, { title: 'account' },
        { title: 'debit', align: 'right' }, { title: 'credit', align: 'right' }, { title: 'balance', align: 'right' },
        { title: 'matched' },
      ],
      result.lines.map((l) => [
        cell(l['entry_date']), cell(l['entry_number']), cell(l['document_number']), cell(l['account_code']),
        cell(l['debit']), cell(l['credit']), cell(l['running_balance']),
        l['matching_state'] === 'matched' ? dim('matched') : cell(l['matching_state']),
      ]),
    );
  }
  pairs([['balance', result.closing_balance]]);
  note(dim('Debit minus credit, in the currency of the company: positive is what the contact owes.'));
  return 0;
}

async function certificateAdd(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, CERTIFICATE_ADD_FLAGS);
  const [wanted, reference] = [args.positional[2], args.positional[3]];
  if (wanted === undefined || reference === undefined) {
    throw new UsageError(
      'missing_argument: the contact and the number the certificate carries. `ekwo contact certificate add "<name|id>" <reference> --from <date>`.',
    );
  }
  const from = stringFlag(args, 'from');
  if (from === undefined) {
    throw new UsageError('missing_argument: --from, the first day the certificate covers.');
  }
  const { backend, company } = await openBooks(args, deps);
  const contact = await resolveContact(backend, company.id, wanted);
  const result = (await recordTaxCertificate(
    backend,
    given({
      company_id: company.id,
      contact_id: contact.id,
      reference,
      valid_from: from,
      valid_to: stringFlag(args, 'to'),
      territory_code: stringFlag(args, 'territory'),
      note: stringFlag(args, 'note'),
      client_ref: stringFlag(args, 'ref'),
    }),
  )) as { certificate: Record<string, unknown>; replayed?: boolean };
  setResult(result);

  heading(`Certificate of ${contact.name}`);
  const c = result.certificate;
  if (result.replayed === true) note(dim(`already recorded under the reference ${String(c['client_ref'])}; nothing was written`));
  pairs([
    ['reference', String(c['reference'])],
    ['territory', c['territory_code'] === null ? dim('every place of supply') : String(c['territory_code'])],
    ['covers', `${String(c['valid_from'])} to ${c['valid_to'] === null ? 'no end' : String(c['valid_to'])}`],
  ]);
  return 0;
}

async function certificateList(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, CERTIFICATE_LIST_FLAGS);
  const wanted = args.positional[2];
  const { backend, company } = await openBooks(args, deps);
  const contact = wanted === undefined ? undefined : await resolveContact(backend, company.id, wanted);
  const result = (await listTaxCertificates(
    backend,
    given({ company_id: company.id, contact_id: contact?.id }),
  )) as { certificates: Record<string, unknown>[]; count: number };
  setResult(result);

  heading(contact === undefined ? `Certificates held, in ${company.name}` : `Certificates of ${contact.name}`);
  if (result.certificates.length === 0) note(dim('None.'));
  else {
    const cell = (value: unknown): string => (value === null || value === undefined ? '' : String(value));
    table(
      [{ title: 'contact' }, { title: 'reference' }, { title: 'territory' }, { title: 'from' }, { title: 'to' }],
      result.certificates.map((c) => [
        cell(c['contact_name']), cell(c['reference']), cell(c['territory_code']), cell(c['valid_from']), cell(c['valid_to']),
      ]),
    );
  }
  return 0;
}
