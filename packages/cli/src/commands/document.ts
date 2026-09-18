/**
 * The verbs on a document: `invoice new`, `invoice line add`, `post`,
 * `doc list` and `doc show`.
 *
 * Each is one function of the core — `createDocument()`, `addDocumentLine()`,
 * `postDocument()`, `listDocuments()`, `getDocument()` — which the MCP server
 * calls for `create_document`, `post_document`, `list_documents` and
 * `get_document`. What is printed is what came back: the totals are the
 * database's, the entry is the one `post_document()` wrote, and a refusal is
 * left to `output.ts` to repeat word for word.
 */

import {
  DOCUMENT_STATES,
  DOC_TYPES,
  addDocumentLine,
  createDocument,
  getDocument,
  listDocuments,
  postDocument,
  resolveContact,
  resolveDocument,
  type CreateDocumentArgs,
  type DocType,
  type LineArgs,
  type ListDocumentsArgs,
} from '@ekwo-ai/core';
import { UsageError, boolFlag, numberFlag, rejectUnknownFlags, stringFlag, stringFlags, type ParsedArgs } from '../args.js';
import {
  BOOKS_FLAGS,
  CREATE_FLAGS,
  LINE_FIELDS,
  checkedLines,
  given,
  openBooks,
  parseLine,
  required,
  stdinDocument,
  today,
  type BooksDeps,
} from '../books.js';
import { setResult } from '../output.js';
import { dim, heading, line, note, pairs, step, table } from '../ui.js';

type Row = Record<string, unknown>;

const NEW_FLAGS = [
  ...CREATE_FLAGS, 'contact', 'line', 'type', 'date', 'due', 'accounting-date', 'number', 'supplier-ref', 'currency', 'payment-ref',
] as const;
const NEW_FIELDS = [
  'doc_type', 'contact_id', 'contact', 'document_date', 'due_date', 'accounting_date', 'number', 'supplier_reference',
  'currency_code', 'journal_id', 'payment_reference', 'client_ref', 'lines',
] as const;
const LINE_ADD_FLAGS = [
  ...BOOKS_FLAGS, 'stdin', 'name', 'description', 'qty', 'unit', 'price', 'amount', 'discount', 'product', 'account', 'tax',
] as const;
const POST_FLAGS = [...BOOKS_FLAGS, 'dry-run'] as const;
const LIST_FLAGS = [...BOOKS_FLAGS, 'unpaid', 'since', 'until', 'type', 'state', 'contact', 'limit'] as const;

function oneOf<T extends string>(value: unknown, allowed: readonly T[], what: string): T | undefined {
  if (value === undefined) return undefined;
  if (typeof value !== 'string' || !(allowed as readonly string[]).includes(value)) {
    throw new UsageError(`bad_value: ${what} is one of ${allowed.join(', ')}, got "${String(value)}".`);
  }
  return value as T;
}

const text = (value: unknown): string => (value === null || value === undefined ? '' : String(value));

/** A document as it came back, for a person. Every figure is the database's. */
function printDocument(result: Row): void {
  const document = (result['document'] ?? {}) as Row;
  pairs([
    ['document', `${text(document['doc_type'])} ${text(document['number']) || dim('no number yet')}  ${dim(text(document['id']))}`],
    ['contact', text(document['contact_name'])],
    ['date', text(document['document_date'])],
    ['state', `${text(document['state'])}, ${text(document['payment_state'])}`],
    ['untaxed', `${text(document['amount_untaxed'])} ${text(document['currency_code'])}`],
    ['tax', `${text(document['amount_tax'])} ${text(document['currency_code'])}`],
    ['total', `${text(document['amount_total'])} ${text(document['currency_code'])}`],
  ]);
  const lines = (result['lines'] ?? []) as Row[];
  if (lines.length > 0) {
    line();
    table(
      [{ title: 'line' }, { title: 'qty', align: 'right' }, { title: 'price', align: 'right' }, { title: 'account' }, { title: 'tax' }],
      lines.map((l) => [
        text(l['name']),
        text(l['quantity']),
        text(l['unit_price']),
        text((l['account'] as Row | null)?.['code']),
        text((l['tax'] as Row | null)?.['code']),
      ]),
    );
  }
}

function printEntry(result: Row): void {
  const entry = (result['entry'] ?? {}) as Row;
  pairs([
    ['entry', `${text(entry['number'])}  ${text(entry['entry_date'])}`],
    ['debit', text(entry['total_debit'])],
    ['credit', text(entry['total_credit'])],
  ]);
  const lines = (result['entry_lines'] ?? []) as Row[];
  line();
  table(
    [{ title: 'account' }, { title: 'label' }, { title: 'debit', align: 'right' }, { title: 'credit', align: 'right' }],
    lines.map((l) => [
      text(l['account_code'] ?? (l['account'] as Row | null)?.['code']),
      text(l['name']),
      text(l['debit']),
      text(l['credit']),
    ]),
  );
}

export async function invoiceCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  const [action, second] = args.positional;
  if (action === 'new') return invoiceNew(args, deps);
  if (action === 'line' && second === 'add') return lineAdd(args, deps);
  throw new UsageError('usage: ekwo invoice new --contact <name|id> --line "name=…,price=…,tax=…" [--type --date --ref] | ekwo invoice line add <document> --price <amount> [--name --account --tax]');
}

async function invoiceNew(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, NEW_FLAGS);
  const input = await stdinDocument(args, deps, NEW_FIELDS);
  const { backend, company } = await openBooks(args, deps);

  const typed = stringFlags(args, 'line').map(parseLine);
  const lines = typed.length > 0 ? typed : input['lines'] === undefined ? [] : checkedLines(input['lines']);
  if (lines.length === 0) {
    throw new UsageError('missing_argument: a document needs a line. Pass --line "name=…,price=…", or `lines` under --stdin.');
  }

  const wanted = stringFlag(args, 'contact') ?? (input['contact_id'] as string | undefined) ?? (input['contact'] as string | undefined);
  const contact = await resolveContact(backend, company.id, required(wanted, 'who the document is for', '--contact'));

  // The one value this command supplies when nobody gave it, and it says so.
  const date = stringFlag(args, 'date') ?? (input['document_date'] as string | undefined);
  const documentDate = date ?? today();

  const fields = given({
    company_id: company.id,
    doc_type: oneOf<DocType>(stringFlag(args, 'type') ?? input['doc_type'], DOC_TYPES, '--type') ?? ('sale_invoice' satisfies DocType),
    contact_id: contact.id,
    document_date: documentDate,
    due_date: stringFlag(args, 'due') ?? input['due_date'],
    accounting_date: stringFlag(args, 'accounting-date') ?? input['accounting_date'],
    number: stringFlag(args, 'number') ?? input['number'],
    supplier_reference: stringFlag(args, 'supplier-ref') ?? input['supplier_reference'],
    currency_code: stringFlag(args, 'currency') ?? input['currency_code'],
    journal_id: input['journal_id'],
    payment_reference: stringFlag(args, 'payment-ref') ?? input['payment_reference'],
    client_ref: stringFlag(args, 'ref') ?? input['client_ref'],
    lines: lines as LineArgs[],
  }) as CreateDocumentArgs;

  const result = (await createDocument(backend, fields)) as Row;
  setResult(result);

  heading(`Draft, in ${company.name}`);
  if (result['replayed'] === true) note(dim(`already created under the reference ${text(fields.client_ref)}; nothing was written twice`));
  if (date === undefined) note(dim(`dated today, ${documentDate}: no --date was given`));
  printDocument(result);
  line();
  note(dim('A draft books nothing. `ekwo post <document>` does, and `--dry-run` shows the entry first.'));
  return 0;
}

async function lineAdd(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, LINE_ADD_FLAGS);
  const input = await stdinDocument(args, deps, LINE_FIELDS);
  const { backend, company } = await openBooks(args, deps);
  const documentId = await resolveDocument(backend, company.id, required(args.positional[2], 'the document', '<document>'));

  const lineArgs = given({
    ...input,
    name: stringFlag(args, 'name') ?? input['name'],
    description: stringFlag(args, 'description') ?? input['description'],
    quantity: stringFlag(args, 'qty') ?? input['quantity'],
    unit_code: stringFlag(args, 'unit') ?? input['unit_code'],
    unit_price: stringFlag(args, 'price') ?? stringFlag(args, 'amount') ?? input['unit_price'],
    discount_percent: stringFlag(args, 'discount') ?? input['discount_percent'],
    product_code: stringFlag(args, 'product') ?? input['product_code'],
    account_code: stringFlag(args, 'account') ?? input['account_code'],
    tax_code: stringFlag(args, 'tax') ?? input['tax_code'],
  }) as LineArgs;

  const result = (await addDocumentLine(backend, { document_id: documentId, line: lineArgs })) as Row;
  setResult(result);
  heading(`Draft, in ${company.name}`);
  printDocument(result);
  return 0;
}

export async function postCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  rejectUnknownFlags(args, POST_FLAGS);
  const { backend, company } = await openBooks(args, deps);
  const documentId = await resolveDocument(backend, company.id, required(args.positional[0], 'the document to post', '<document>'));
  const dryRun = boolFlag(args, 'dry-run');

  const result = (await postDocument(backend, { document_id: documentId, dry_run: dryRun })) as Row;
  setResult({ document_id: documentId, ...result });

  heading(dryRun ? `What posting would write, in ${company.name}` : `Posted, in ${company.name}`);
  printEntry(result);
  line();
  note(dim(text(result['note'])));
  return 0;
}

export async function docCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  const action = args.positional[0];
  if (action === 'list') return docList(args, deps);
  if (action === 'show') return docShow(args, deps);
  throw new UsageError('usage: ekwo doc list [--unpaid --since <date> --until <date> --type --state --contact] | ekwo doc show <document>');
}

async function docList(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, LIST_FLAGS);
  const { backend, company } = await openBooks(args, deps);
  const contact = stringFlag(args, 'contact');
  const filters = given({
    company_id: company.id,
    doc_type: oneOf<DocType>(stringFlag(args, 'type'), DOC_TYPES, '--type'),
    state: oneOf(stringFlag(args, 'state'), DOCUMENT_STATES, '--state'),
    contact_id: contact === undefined ? undefined : (await resolveContact(backend, company.id, contact)).id,
    from: stringFlag(args, 'since'),
    to: stringFlag(args, 'until'),
    unpaid: boolFlag(args, 'unpaid') ? true : undefined,
    limit: numberFlag(args, 'limit'),
  }) as ListDocumentsArgs;

  const result = (await listDocuments(backend, filters)) as { documents: Row[]; count: number };
  setResult(result);

  heading(`Documents of ${company.name}`);
  if (result.documents.length === 0) note(dim('None.'));
  else {
    table(
      [
        { title: 'date' }, { title: 'type' }, { title: 'number' }, { title: 'contact' }, { title: 'state' },
        { title: 'total', align: 'right' }, { title: 'open', align: 'right' }, { title: '' }, { title: 'id' },
      ],
      result.documents.map((d) => [
        text(d['document_date']), text(d['doc_type']), text(d['number']), text(d['contact_name']),
        `${text(d['state'])}/${text(d['payment_state'])}`, text(d['amount_total']), text(d['amount_residual']),
        text(d['currency_code']), dim(text(d['id'])),
      ]),
    );
  }
  return 0;
}

async function docShow(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, BOOKS_FLAGS);
  const { backend, company } = await openBooks(args, deps);
  const documentId = await resolveDocument(backend, company.id, required(args.positional[1], 'the document', '<document>'));
  const result = (await getDocument(backend, { document_id: documentId })) as Row;
  setResult(result);
  heading(`Document, in ${company.name}`);
  printDocument(result);
  if (result['entry'] !== null && result['entry'] !== undefined) {
    line();
    step('booked');
    printEntry({ entry: result['entry'], entry_lines: (result['entry_lines'] as Row[]).map((l) => ({ ...l, account_code: l['account_name'] })) });
  }
  return 0;
}
