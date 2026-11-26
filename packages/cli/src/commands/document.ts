/**
 * The verbs on a document: `doc new`, `doc line add`, `doc approve`, `post`,
 * `cancel`, `doc list` and `doc show` — on a quote or an order, the other
 * party's answer: `doc accept`, `doc decline` and `doc answer undo` — and its
 * piece: `doc attach` and `doc files`.
 *
 * All five work on the same object, so they are named after it. A document is
 * a sale invoice, a purchase invoice — a bill — a quote or a credit note,
 * chosen with `--type`; `invoice` stayed the name of the verb that creates one
 * long after it created any of them, so `ekwo invoice` is now an alias of
 * `ekwo doc` and does exactly the same thing.
 *
 * Each is one function of the core — `createDocument()`, `addDocumentLine()`,
 * `postDocument()`, `undoDocument()`, `listDocuments()`, `getDocument()` —
 * which the MCP server calls for `create_document`, `post_document`,
 * `cancel_document`, `list_documents` and `get_document`. What is printed is what came back: the totals are the
 * database's, the entry is the one `post_document()` wrote, and a refusal is
 * left to `output.ts` to repeat word for word.
 */

import {
  DOCUMENT_STATES,
  DOC_TYPES,
  acceptDocument,
  addDocumentLine,
  approveDocument,
  attachDocumentFile,
  declineDocument,
  undoDocumentAnswer,
  undoDocument,
  createDocument,
  getDocument,
  listDocumentFiles,
  listDocuments,
  postDocument,
  renderDocumentPdf,
  resolveContact,
  resolveDocument,
  type AttachDocumentFileArgs,
  type CreateDocumentArgs,
  type DocType,
  type LineArgs,
  type DocumentPdfArgs,
  type ListDocumentsArgs,
} from '@ekwo-ai/core';
import { createHash } from 'node:crypto';
import { readFile, writeFile } from 'node:fs/promises';
import { basename, extname } from 'node:path';
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
import { EXIT_ERROR, EXIT_OK, setResult } from '../output.js';
import { dim, heading, line, note, pairs, step, table, warn } from '../ui.js';

type Row = Record<string, unknown>;

const NEW_FLAGS = [
  ...CREATE_FLAGS, 'contact', 'line', 'type', 'date', 'due', 'accounting-date', 'number', 'supplier-ref', 'currency', 'rate', 'payment-ref',
] as const;
const NEW_FIELDS = [
  'doc_type', 'contact_id', 'contact', 'document_date', 'due_date', 'accounting_date', 'number', 'supplier_reference',
  'currency_code', 'exchange_rate', 'journal_id', 'payment_reference', 'client_ref', 'lines',
] as const;
const LINE_ADD_FLAGS = [
  ...BOOKS_FLAGS, 'stdin', 'name', 'description', 'qty', 'unit', 'price', 'amount', 'discount', 'product', 'account', 'tax',
] as const;
const POST_FLAGS = [...BOOKS_FLAGS, 'dry-run'] as const;
const APPROVE_FLAGS = [...BOOKS_FLAGS] as const;
const ACCEPT_FLAGS = [...BOOKS_FLAGS, 'by', 'at'] as const;
const DECLINE_FLAGS = [...BOOKS_FLAGS, 'at'] as const;
const CANCEL_FLAGS = [...BOOKS_FLAGS, 'date', 'credit'] as const;
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
    // A quote or an order says where its answer stands, as the database derives it.
    document['quote_status'] === undefined || document['quote_status'] === null
      ? ['state', `${text(document['state'])}, ${text(document['payment_state'])}`]
      : ['status', answerOf(document)],
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

/** `accepted 2026-11-18 by The buyer`, `declined 2026-11-18`, or the status alone. */
function answerOf(document: Row): string {
  const status = text(document['quote_status']);
  if (document['accepted_at'] !== null && document['accepted_at'] !== undefined) {
    const by = text(document['accepted_by']);
    return `${status} ${text(document['accepted_at']).slice(0, 10)}${by === '' ? '' : ` by ${by}`}`;
  }
  if (document['declined_at'] !== null && document['declined_at'] !== undefined) {
    return `${status} ${text(document['declined_at']).slice(0, 10)}`;
  }
  return status;
}

export function printEntry(result: Row): void {
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

async function docNew(args: ParsedArgs, deps: BooksDeps): Promise<number> {
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
    exchange_rate: stringFlag(args, 'rate') ?? input['exchange_rate'],
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
  // The rate the database proposed, where nobody gave one: its day and source.
  const used = result['exchange_rate_used'] as Row | undefined;
  if (used !== undefined) {
    note(
      dim(
        `booked at ${text(used['rate'])} ${text((result['document'] as Row)['currency_code'])} for one unit of the company's currency: the ${text(used['origin'])} rate of ${text(used['rate_date'])}${used['source'] ? `, ${text(used['source'])}` : ''}. --rate gives another.`,
      ),
    );
  }
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

/**
 * `ekwo doc approve <document>`: a person approves a draft, as it stands, for
 * an agent to post it where agents post in `review`. Signed in
 * as yourself; the database refuses it to a machine key.
 */
async function docApprove(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, APPROVE_FLAGS);
  const { backend, company } = await openBooks(args, deps);
  const documentId = await resolveDocument(backend, company.id, required(args.positional[1], 'the document to approve', '<document>'));
  const result = (await approveDocument(backend, { document_id: documentId })) as Row;
  setResult(result);
  heading(`Approved, in ${company.name}`);
  pairs([
    ['document', documentId],
    ['version', text(result['version'])],
  ]);
  line();
  note(dim(text(result['note'])));
  return 0;
}

/**
 * `ekwo doc accept <document> [--by <who>] [--at <date>]`, `ekwo doc decline
 * <document> [--at <date>]` and `ekwo doc answer undo <document>`: the other
 * party's answer to a quote or an order, recorded as a dated fact by
 * `accept_document()`, `decline_document()` and `undo_document_answer()`.
 * Nothing is booked; a deal of the `crm` module that carries the quote moves
 * in the database.
 */
async function docAnswer(args: ParsedArgs, deps: BooksDeps, answer: 'accept' | 'decline' | 'undo'): Promise<number> {
  rejectUnknownFlags(args, answer === 'accept' ? ACCEPT_FLAGS : answer === 'decline' ? DECLINE_FLAGS : BOOKS_FLAGS);
  const { backend, company } = await openBooks(args, deps);
  const wanted = required(args.positional[answer === 'undo' ? 2 : 1], 'the quote or order', '<document>');
  const documentId = await resolveDocument(backend, company.id, wanted);
  const at = stringFlag(args, 'at');
  const result = (
    answer === 'accept'
      ? await acceptDocument(backend, given({ document_id: documentId, accepted_by: stringFlag(args, 'by'), at }) as { document_id: string })
      : answer === 'decline'
        ? await declineDocument(backend, given({ document_id: documentId, at }) as { document_id: string })
        : await undoDocumentAnswer(backend, { document_id: documentId })
  ) as Row;
  setResult(result);
  heading(`${answer === 'accept' ? 'Accepted' : answer === 'decline' ? 'Declined' : 'Answer taken back'}, in ${company.name}`);
  printDocument(result);
  line();
  note(dim(text(result['note'])));
  return 0;
}

export async function cancelCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  rejectUnknownFlags(args, CANCEL_FLAGS);
  const { backend, company } = await openBooks(args, deps);
  const documentId = await resolveDocument(backend, company.id, required(args.positional[0], 'the document to cancel', '<document>'));
  // No date given is not today: the database takes the invoice's own day while
  // its period is open, and refuses by name when it is not.
  const date = stringFlag(args, 'date');
  // Which of the two ways is the database's answer, asked once in the core:
  // back to draft where the country and the facts allow it, a credit note
  // otherwise. A date or --credit asks for the credit note outright.
  const result = (await undoDocument(backend, {
    document_id: documentId,
    date,
    credit_note: boolFlag(args, 'credit'),
  })) as Row;
  setResult({ document_id: documentId, ...result });

  if (result['undone_by'] === 'draft') {
    const unposting = (result['unposting'] ?? {}) as Row;
    heading(`Back to draft, in ${company.name}`);
    pairs([
      ['undone by', 'back to draft — this country allows it, and nothing about the document had left'],
      ['entry', `${text(unposting['entry_number'])} taken away${unposting['number_returned'] === true ? ', its number given back' : ''}`],
    ]);
    line();
    printDocument({ document: result['draft'], lines: result['lines'] });
    line();
    note(dim(text(result['note'])));
    return 0;
  }

  const cancelled = (result['cancelled'] ?? {}) as Row;
  heading(`Cancelled, in ${company.name}`);
  pairs([
    ['undone by', `a credit note — ${text(result['why'])}`],
    ['cancelled', `${text(cancelled['doc_type'])} ${text(cancelled['number'])}  ${dim(text(cancelled['id']))}`],
    ['state', `${text(cancelled['state'])}, ${text(cancelled['payment_state'])}`],
  ]);
  line();
  step('by the credit note');
  printDocument({ document: result['credit_note'], lines: result['lines'] });
  line();
  printEntry(result);
  line();
  note(dim(text(result['note'])));
  return 0;
}

export async function docCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  const [action, second] = args.positional;
  if (action === 'new') return docNew(args, deps);
  if (action === 'line' && second === 'add') return lineAdd(args, deps);
  if (action === 'list') return docList(args, deps);
  if (action === 'show') return docShow(args, deps);
  if (action === 'pdf') return docPdf(args, deps);
  if (action === 'approve') return docApprove(args, deps);
  if (action === 'accept') return docAnswer(args, deps, 'accept');
  if (action === 'decline') return docAnswer(args, deps, 'decline');
  if (action === 'answer' && second === 'undo') return docAnswer(args, deps, 'undo');
  if (action === 'attach') return docAttach(args, deps);
  if (action === 'files') return docFiles(args, deps);
  throw new UsageError(
    'usage: ekwo doc new --contact <name|id> --line "name=…,price=…,tax=…" [--type --date --ref]' +
      ' | ekwo doc line add <document> --price <amount> [--name --account --tax]' +
      ' | ekwo doc list [--unpaid --since <date> --until <date> --type --state --contact]' +
      ' | ekwo doc show <document>' +
      ' | ekwo doc approve <document>' +
      ' | ekwo doc accept <document> [--by <who> --at <date>] | ekwo doc decline <document> [--at <date>] | ekwo doc answer undo <document>' +
      ' | ekwo doc pdf <document> [--factur-x --out <file> --page-size A4|Letter --labels <file.json>]' +
      ' | ekwo doc attach <document> <storage-path> [--file <local copy> --name <file name> --mime <type>]' +
      ' | ekwo doc files <document>',
  );
}

/**
 * `ekwo invoice`, kept so that no example already published stops working. It
 * is the same verbs on the same object, under the name they used to have.
 */
export async function invoiceCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  return docCommand(args, deps);
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
        d['quote_status'] === undefined || d['quote_status'] === null
          ? `${text(d['state'])}/${text(d['payment_state'])}`
          : text(d['quote_status']),
        text(d['amount_total']), text(d['amount_residual']),
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

const PDF_FLAGS = [...BOOKS_FLAGS, 'factur-x', 'out', 'page-size', 'labels'] as const;

/**
 * `ekwo doc pdf <document>` — the PDF of a sale invoice or credit note, from
 * the views, through `renderDocumentPdf()`; `render_invoice_pdf` is the same
 * call. Written to `--out`, or under its own name in the current directory.
 * The logo the company names by URL is fetched here, on this machine.
 *
 * `--factur-x` embeds the CII of the document; the rules of EN 16931 it
 * breaks are listed, and end on exit code 1 like a check that found something.
 * The file is written all the same, so that it can be looked at.
 */
async function docPdf(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, PDF_FLAGS);
  const { backend, company } = await openBooks(args, deps);
  const documentId = await resolveDocument(backend, company.id, required(args.positional[1], 'the document', '<document>'));
  const pageSize = stringFlag(args, 'page-size');
  if (pageSize !== undefined && pageSize !== 'A4' && pageSize !== 'Letter') {
    throw new UsageError(`bad_value: --page-size is A4 or Letter, got "${pageSize}".`);
  }
  const labelsFile = stringFlag(args, 'labels');
  let labels: Record<string, unknown> | undefined;
  if (labelsFile !== undefined) {
    try {
      labels = JSON.parse(await readFile(labelsFile, 'utf8')) as Record<string, unknown>;
    } catch (error) {
      throw new UsageError(`bad_value: --labels names a JSON file of the words of the layout; ${labelsFile} could not be read as one (${error instanceof Error ? error.message : String(error)}).`);
    }
  }

  const { file, ...result } = await renderDocumentPdf(
    backend,
    given({ document_id: documentId, factur_x: boolFlag(args, 'factur-x') ? true : undefined, page_size: pageSize, labels }) as DocumentPdfArgs,
    { fetch: (url, init) => (deps.fetchImpl ?? globalThis.fetch)(url, init) },
  );
  const out = stringFlag(args, 'out') ?? result.filename;
  await writeFile(out, file);
  setResult({ ...result, written_to: out });

  heading(`${result.title}, in ${company.name}`);
  pairs([
    ['file', `${out}  ${dim(`${result.byte_size} bytes, ${result.page_count} page(s)`)}`],
    ['logo', result.logo],
    ...(result.pack_labels.length === 0 ? [] : [['law', `${result.pack_labels.join(', ')} ${dim('as the country\'s pack names them')}`] as [string, string]]),
    ['words', result.language === null || result.labels_language === result.language ? result.labels_language : `${result.labels_language} ${dim(`(no words in ${result.language} yet)`)}`],
    ...(result.verification_url === null ? [] : [['verification', `QR code of ${result.verification_url}`] as [string, string]]),
    ...(result.factur_x === null ? [] : [['factur-x', `${result.factur_x.profile}, embedded`] as [string, string]]),
  ]);
  const violations = result.factur_x?.violations ?? [];
  if (violations.length > 0) {
    line();
    warn(`The embedded XML breaks ${violations.length} rule(s):`);
    for (const violation of violations) {
      line(`  ${violation.code}${violation.line === undefined ? '' : ` (line ${violation.line})`}: ${violation.message}`);
    }
  }
  line();
  note(dim('Rendered from the books, and recorded nowhere: the copy you send is yours to keep.'));
  return violations.length > 0 ? EXIT_ERROR : EXIT_OK;
}

const ATTACH_FLAGS = [...BOOKS_FLAGS, 'file', 'name', 'mime'] as const;

/** The media types a piece usually has, by its extension; anything else is left unsaid. */
const MEDIA_TYPES: Record<string, string> = {
  '.pdf': 'application/pdf',
  '.xml': 'application/xml',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.heic': 'image/heic',
  '.tif': 'image/tiff',
  '.tiff': 'image/tiff',
};

/**
 * `ekwo doc attach <document> <storage-path> [--file <local copy>]` — records
 * the file stored at `<storage-path>` as the piece of the document, through
 * `attachDocumentFile()`, which `attach_document_file` calls too. Nothing is
 * uploaded: the file is where the installation keeps files already. With
 * `--file`, a copy of it on this machine is read for its size and its SHA-256,
 * so that the same file recorded again is recognised; its name is the file's
 * unless `--name` says another.
 */
async function docAttach(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, ATTACH_FLAGS);
  const { backend, company } = await openBooks(args, deps);
  const documentId = await resolveDocument(backend, company.id, required(args.positional[1], 'the document', '<document>'));
  const storagePath = required(args.positional[2], 'where the file is stored', '<storage-path>');
  const local = stringFlag(args, 'file');
  let measured: { byte_size: number; checksum: string } | undefined;
  if (local !== undefined) {
    let bytes: Buffer;
    try {
      bytes = await readFile(local);
    } catch (error) {
      throw new UsageError(`bad_value: --file names a copy of the file on this machine; ${local} could not be read (${error instanceof Error ? error.message : String(error)}).`);
    }
    measured = { byte_size: bytes.byteLength, checksum: createHash('sha256').update(bytes).digest('hex') };
  }
  const fileName = stringFlag(args, 'name') ?? basename(local ?? storagePath);
  const result = (await attachDocumentFile(
    backend,
    given({
      document_id: documentId,
      storage_path: storagePath,
      file_name: fileName,
      mime_type: stringFlag(args, 'mime') ?? MEDIA_TYPES[extname(fileName).toLowerCase()],
      ...measured,
    }) as unknown as AttachDocumentFileArgs,
  )) as Row;
  setResult(result);
  const attachment = (result['attachment'] ?? {}) as Row;
  heading(`${result['replayed'] === true ? 'Already recorded' : 'Recorded'}, in ${company.name}`);
  pairs([
    ['document', documentId],
    ['file', `${text(attachment['file_name'])}  ${dim(text(attachment['mime_type']))}`],
    ['stored at', text(attachment['storage_path'])],
    ['sha-256', text(attachment['checksum'])],
  ]);
  line();
  note(dim('The row is recorded; the file stays where it is stored.'));
  return 0;
}

/** `ekwo doc files <document>` — the pieces recorded on a document, through `listDocumentFiles()`. */
async function docFiles(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, BOOKS_FLAGS);
  const { backend, company } = await openBooks(args, deps);
  const documentId = await resolveDocument(backend, company.id, required(args.positional[1], 'the document', '<document>'));
  const result = (await listDocumentFiles(backend, { document_id: documentId })) as { attachments: Row[]; count: number };
  setResult(result);
  heading(`Files of the document, in ${company.name}`);
  if (result.attachments.length === 0) note(dim('None.'));
  else {
    table(
      [{ title: 'name' }, { title: 'type' }, { title: 'bytes', align: 'right' }, { title: 'stored at' }, { title: 'id' }],
      result.attachments.map((a) => [
        text(a['file_name']), text(a['mime_type']), text(a['byte_size']), text(a['storage_path']), dim(text(a['id'])),
      ]),
    );
  }
  return 0;
}
