/**
 * Documents: drafts and their lines, and the one call that books them.
 *
 * One rule holds everywhere here: the ledger is written by the schema, never
 * by this package. `post_document` carries the accounting rules — balance,
 * numbering, period locks, the counterpart that is the difference of
 * everything else — and this file calls it. Nothing here inserts an `entries`
 * or an `entry_lines` row. Direct inserts are for the objects a person types:
 * draft documents and their lines.
 */

import { BooksError, type Backend, type Filter, type Row } from './backend.js';
import * as columns from './columns.js';
import { amountIn, moneyFields } from './format.js';
import type { DocType } from '../types.js';
import { companyCurrency, createdBefore, idsByCode, namesOf, only, onlyVisible } from './shared.js';

export const DOC_TYPES = [
  'sale_invoice',
  'sale_credit_note',
  'sale_quote',
  'purchase_invoice',
  'purchase_credit_note',
  'purchase_order',
] as const satisfies readonly DocType[];

export const DOCUMENT_STATES = ['draft', 'posted', 'cancelled'] as const;
export const PAYMENT_STATES = ['not_paid', 'partially_paid', 'paid', 'overpaid', 'reversed'] as const;

/** A line as a caller writes it: codes or ids, and whatever a product can fill in. */
export interface LineArgs {
  name?: string | undefined;
  description?: string | undefined;
  quantity?: string | number | undefined;
  unit_code?: string | undefined;
  unit_price?: string | number | undefined;
  discount_percent?: string | number | undefined;
  product_id?: string | undefined;
  product_code?: string | undefined;
  account_id?: string | undefined;
  account_code?: string | undefined;
  tax_id?: string | undefined;
  tax_code?: string | undefined;
}

export interface CreateDocumentArgs {
  company_id: string;
  doc_type: DocType;
  contact_id: string;
  document_date: string;
  due_date?: string | undefined;
  accounting_date?: string | undefined;
  number?: string | undefined;
  supplier_reference?: string | undefined;
  currency_code?: string | undefined;
  journal_id?: string | undefined;
  payment_reference?: string | undefined;
  /** Your own reference. Creating twice under one reference creates once. */
  client_ref?: string | undefined;
  lines: LineArgs[];
}

export interface UpdateDocumentLinesArgs {
  document_id: string;
  lines: LineArgs[];
}

export interface AddDocumentLineArgs {
  document_id: string;
  line: LineArgs;
}

export interface PostDocumentArgs {
  document_id: string;
  /** Ask the database what posting would write, and write nothing. */
  dry_run?: boolean | undefined;
}

export interface ListDocumentsArgs {
  company_id: string;
  doc_type?: DocType | undefined;
  state?: (typeof DOCUMENT_STATES)[number] | undefined;
  payment_state?: (typeof PAYMENT_STATES)[number] | undefined;
  contact_id?: string | undefined;
  from?: string | undefined;
  to?: string | undefined;
  /** Posted and still owed: not paid, or partially. Drafts are owed by nobody. */
  unpaid?: boolean | undefined;
  limit?: number | undefined;
}

export interface GetDocumentArgs {
  document_id: string;
}

export async function createDocument(
  backend: Backend,
  args: CreateDocumentArgs,
): Promise<unknown> {
  const resolved = await resolveLineInputs(backend, args.company_id, args.doc_type, args.lines);

  // Created before under this reference: the answer is that document. A
  // creation is two inserts, the header and then the lines, so a connection
  // that dropped between them left a draft with none — which is finished here
  // rather than handed back empty.
  const before = await createdBefore(backend, 'documents', args.company_id, args.client_ref, ['id', 'state']);
  if (before !== undefined) {
    const id = before['id'] as string;
    const held = await backend.select<Row>({
      table: 'document_lines',
      columns: ['id'],
      where: [{ column: 'document_id', op: 'eq', value: id }],
      limit: 1,
    });
    if (held.length === 0 && before['state'] === 'draft') await insertLines(backend, args.company_id, id, resolved);
    return { ...((await getDocument(backend, { document_id: id })) as Row), replayed: true };
  }

  const currency = args.currency_code ?? (await companyCurrency(backend, args.company_id));

  const document = only(
    await backend.insert<Row>(
      'documents',
      [
        {
          company_id: args.company_id,
          doc_type: args.doc_type,
          contact_id: args.contact_id,
          document_date: args.document_date,
          due_date: args.due_date ?? null,
          accounting_date: args.accounting_date ?? null,
          number: args.number ?? null,
          supplier_reference: args.supplier_reference ?? null,
          currency_code: currency,
          journal_id: args.journal_id ?? null,
          payment_reference: args.payment_reference ?? null,
          client_ref: args.client_ref ?? null,
        },
      ],
      ['id'],
    ),
    'the document could not be created',
  );

  await insertLines(backend, args.company_id, document['id'] as string, resolved);
  return getDocument(backend, { document_id: document['id'] as string });
}

/** A line, with every code turned into an id and every gap the product fills. */
interface ResolvedLine {
  product_id: string | null;
  name: string;
  description: string | null;
  unit_code: string;
  unit_price: string;
  quantity: string;
  discount_percent: string;
  account_id: string | null;
  tax_id: string | null;
}

function isSale(docType: DocType): boolean {
  return docType.startsWith('sale_');
}

/**
 * Turns the lines a model wrote into the rows the schema takes.
 *
 * Two things happen here and nowhere else. Codes become ids — one query per
 * table, so twenty lines are three round trips and not sixty. And a product
 * fills in what the line left out: the text, the description, the unit, the
 * price and the tax. Those are *pre-fills*, in the sense an accounting
 * package has always meant: the line is what is invoiced, and everything the
 * caller gave wins over everything the catalogue says.
 *
 * The account is deliberately not resolved here. The database does it, in
 * `resolve_line_account`, because a product line with no account is refused
 * by a check constraint — so a null can only mean "resolve it", and every
 * client has to get the same answer. A null tax is the opposite: it means no
 * tax at all, which is why it is filled from the product only when the line
 * named none.
 */
async function resolveLineInputs(
  backend: Backend,
  company: string,
  docType: DocType,
  lines: LineArgs[],
): Promise<ResolvedLine[]> {
  const [accounts, taxes, products] = await Promise.all([
    idsByCode(
      backend,
      'accounts',
      company,
      lines.map((line) => line.account_code).filter((code): code is string => typeof code === 'string'),
    ),
    idsByCode(
      backend,
      'taxes',
      company,
      lines.map((line) => line.tax_code).filter((code): code is string => typeof code === 'string'),
    ),
    productsFor(backend, company, lines),
  ]);

  const sale = isSale(docType);

  return lines.map((line, index) => {
    const productId =
      line.product_id ?? (line.product_code === undefined ? null : (products.byCode.get(line.product_code)?.['id'] as string));
    const product =
      productId === null || productId === undefined ? undefined : products.byId.get(productId);

    if (productId !== null && productId !== undefined && product === undefined) {
      throw new BooksError(
        `unknown_product: no product ${productId} in this company. search_products says what exists; a product of another company is invisible here, not merely refused.`,
      );
    }

    const name = line.name ?? (product?.['name'] as string | undefined);
    if (name === undefined) {
      throw new BooksError(
        `missing_line_name: line ${index + 1} has no name and no product to take one from. A line has to say what is being billed.`,
      );
    }

    const catalogPrice = product?.[sale ? 'sale_price' : 'purchase_price'];
    const unitPrice = line.unit_price ?? (typeof catalogPrice === 'string' ? catalogPrice : undefined);
    if (unitPrice === undefined) {
      throw new BooksError(
        `missing_unit_price: line ${index + 1} ("${name}") has no price, and ${
          product === undefined
            ? 'no product to take one from'
            : `product ${String(product['code'])} has no ${sale ? 'sale' : 'purchase'} price`
        }.`,
      );
    }

    const productTax = product?.[sale ? 'sale_tax_id' : 'purchase_tax_id'];

    return {
      product_id: productId ?? null,
      name,
      description:
        line.description ?? ((product?.['description'] as string | null | undefined) ?? null),
      unit_code: line.unit_code ?? ((product?.['unit_code'] as string | undefined) ?? 'C62'),
      unit_price: amountIn(unitPrice),
      quantity: amountIn(line.quantity ?? 1),
      discount_percent: amountIn(line.discount_percent ?? 0),
      account_id:
        line.account_id ?? (line.account_code === undefined ? null : (accounts.get(line.account_code) ?? null)),
      tax_id:
        line.tax_id ??
        (line.tax_code === undefined
          ? (typeof productTax === 'string' ? productTax : null)
          : (taxes.get(line.tax_code) ?? null)),
    };
  });
}

/** The products named by a set of lines, by id and by code, in one query each. */
async function productsFor(
  backend: Backend,
  company: string,
  lines: LineArgs[],
): Promise<{ byId: Map<string, Row>; byCode: Map<string, Row> }> {
  const ids = [...new Set(lines.map((line) => line.product_id).filter((id): id is string => typeof id === 'string'))];
  const codes = [
    ...new Set(lines.map((line) => line.product_code).filter((code): code is string => typeof code === 'string')),
  ];
  if (ids.length === 0 && codes.length === 0) return { byId: new Map(), byCode: new Map() };

  const where: Filter[] = [{ column: 'company_id', op: 'eq', value: company }];
  const rows =
    ids.length > 0 && codes.length > 0
      ? [
          ...(await backend.select<Row>({
            table: 'products',
            columns: columns.PRODUCT,
            where: [...where, { column: 'id', op: 'in', value: ids }],
          })),
          ...(await backend.select<Row>({
            table: 'products',
            columns: columns.PRODUCT,
            where: [...where, { column: 'code', op: 'in', value: codes }],
          })),
        ]
      : await backend.select<Row>({
          table: 'products',
          columns: columns.PRODUCT,
          where: [
            ...where,
            ids.length > 0
              ? { column: 'id', op: 'in', value: ids }
              : { column: 'code', op: 'in', value: codes },
          ],
        });

  const byId = new Map(rows.map((row) => [row['id'] as string, row]));
  const byCode = new Map(rows.map((row) => [row['code'] as string, row]));
  for (const code of codes) {
    if (!byCode.has(code)) {
      throw new BooksError(
        `unknown_product_code: no product "${code}" in this company. search_products says what exists, and create_product adds one.`,
      );
    }
  }
  return { byId, byCode };
}

async function insertLines(
  backend: Backend,
  company: string,
  documentId: string,
  lines: ResolvedLine[],
  after = 0,
): Promise<void> {
  const rows: Row[] = lines.map((line, index) => ({
    document_id: documentId,
    company_id: company,
    sequence: after + (index + 1) * 10,
    line_type: 'product',
    ...line,
  }));
  await backend.insert('document_lines', rows, ['id']);
}

/** The draft a line may be added to or replaced on, or the refusal. */
async function draftOf(backend: Backend, documentId: string): Promise<Row> {
  const document = only(
    await backend.select<Row>({
      table: 'documents',
      columns: ['id', 'company_id', 'state', 'doc_type'],
      where: [{ column: 'id', op: 'eq', value: documentId }],
    }),
    `document ${documentId}`,
  );
  if (document['state'] !== 'draft') {
    throw new BooksError(
      `document_not_draft: document ${documentId} is ${String(document['state'])}. A posted document is not edited; correct it with a credit note.`,
    );
  }
  return document;
}

/** One more line at the end of a draft. The lines already there are untouched. */
export async function addDocumentLine(backend: Backend, args: AddDocumentLineArgs): Promise<unknown> {
  const document = await draftOf(backend, args.document_id);
  const company = document['company_id'] as string;
  const [resolved] = await resolveLineInputs(backend, company, document['doc_type'] as DocType, [args.line]);
  const last = await backend.select<{ sequence: number }>({
    table: 'document_lines',
    columns: ['sequence'],
    where: [{ column: 'document_id', op: 'eq', value: args.document_id }],
    order: [{ column: 'sequence', ascending: false }],
    limit: 1,
  });
  await insertLines(backend, company, args.document_id, [resolved as ResolvedLine], last[0]?.sequence ?? 0);
  return getDocument(backend, { document_id: args.document_id });
}

export async function updateDocumentLines(
  backend: Backend,
  args: UpdateDocumentLinesArgs,
): Promise<unknown> {
  const document = await draftOf(backend, args.document_id);

  const company = document['company_id'] as string;
  const resolved = await resolveLineInputs(
    backend,
    company,
    document['doc_type'] as DocType,
    args.lines,
  );

  await backend.remove('document_lines', [{ column: 'document_id', op: 'eq', value: args.document_id }]);
  await insertLines(backend, company, args.document_id, resolved);
  return getDocument(backend, { document_id: args.document_id });
}

export async function postDocument(
  backend: Backend,
  args: PostDocumentArgs,
): Promise<unknown> {
  if (args.dry_run === true) {
    // The database posts for real and takes it back, so what comes out is
    // what posting would write and a refusal is the one posting would give.
    const rehearsed = only(
      await backend.rpc<Row>('rehearse_post_document', { p_document_id: args.document_id }),
      `document ${args.document_id} produced no entry`,
    );
    return {
      dry_run: true,
      entry: rehearsed['entry'] ?? null,
      entry_lines: rehearsed['entry_lines'] ?? [],
      note: 'Nothing was written. The number is the one the entry would take now; somebody posting first takes it instead.',
    };
  }

  const entries = await backend.rpc<Row>('post_document', { p_document_id: args.document_id });
  const entry = only(
    moneyFields(entries, ['total_debit', 'total_credit']),
    `document ${args.document_id} produced no entry`,
  );

  return {
    entry,
    entry_lines: await entryLinesWithAccounts(backend, entry['id'] as string),
    note: 'The document is posted and carries the entry number. A mistake is undone by cancel_document: back to draft where the country allows it and nothing about the document has left, and otherwise by the credit note that names it.',
  };
}

/** The lines of an entry, each beside the account it is on. */
export async function entryLinesWithAccounts(backend: Backend, entryId: string): Promise<Row[]> {
  const lines = await backend.select<Row>({
    table: 'entry_lines',
    columns: columns.ENTRY_LINE,
    where: [{ column: 'entry_id', op: 'eq', value: entryId }],
    order: [{ column: 'sequence' }],
  });
  const accounts = await backend.select<{ id: string; code: string; name: string }>({
    table: 'accounts',
    columns: ['id', 'code', 'name'],
    where: [
      {
        column: 'id',
        op: 'in',
        value: lines.map((line) => line['account_id']).filter((id): id is string => typeof id === 'string'),
      },
    ],
  });
  const byId = new Map(accounts.map((account) => [account.id, account]));
  return lines.map((line) => ({ ...line, account: byId.get(line['account_id'] as string) ?? null }));
}

export interface CancelDocumentArgs {
  document_id: string;
  /** The day the credit note is issued on. Left out: the invoice's, while its period is open. */
  date?: string | undefined;
}

/**
 * Undoes a posted invoice through `cancel_document()`: the credit note that
 * names it is written, posted and matched against it, and the invoice is
 * cancelled — all in the database, in one statement. What comes back is read
 * afterwards: the credit note as `get_document` shows a document, and the
 * invoice as it now stands.
 */
export async function cancelDocument(backend: Backend, args: CancelDocumentArgs): Promise<unknown> {
  const credited = only(
    await backend.rpc<Row>('cancel_document', {
      p_document_id: args.document_id,
      ...(args.date === undefined ? {} : { p_date: args.date }),
    }),
    `document ${args.document_id} produced no credit note`,
  );
  const creditNote = (await getDocument(backend, { document_id: credited['id'] as string })) as Row;
  const cancelled = onlyVisible(
    moneyFields(
      await backend.select<Row>({
        table: 'documents',
        columns: ['id', 'doc_type', 'number', 'state', 'payment_state', 'amount_total::text', 'amount_residual::text'],
        where: [{ column: 'id', op: 'eq', value: args.document_id }],
      }),
      ['amount_total', 'amount_residual'],
    ),
    `document ${args.document_id}`,
  );
  return {
    cancelled,
    credit_note: creditNote['document'],
    lines: creditNote['lines'],
    entry: creditNote['entry'],
    entry_lines: creditNote['entry_lines'],
    note: 'The credit note is posted and names the invoice, the two are matched, and the invoice is cancelled. Its own number and entry stay as they were: nothing issued is deleted.',
  };
}

export interface UnpostDocumentArgs {
  document_id: string;
}

/**
 * Puts a posted document back to draft through `unpost_document()`, where its
 * country allows it and nothing about it has left. The entry is gone, the
 * number back with the counter where it was the last drawn, and the draft is
 * read afterwards as `get_document` shows a document — beside the record of
 * the act, which says which entry went and whether its number was given back.
 */
export async function unpostDocument(backend: Backend, args: UnpostDocumentArgs): Promise<unknown> {
  only(
    await backend.rpc<Row>('unpost_document', { p_document_id: args.document_id }),
    `document ${args.document_id} did not come back as a draft`,
  );
  const draft = (await getDocument(backend, { document_id: args.document_id })) as Row;
  const unpostings = await backend.select<Row>({
    table: 'document_unpostings',
    columns: ['entry_id', 'entry_number', 'entry_date::text', 'number_returned', 'unposted_at::text'],
    where: [{ column: 'document_id', op: 'eq', value: args.document_id }],
    order: [{ column: 'unposted_at', ascending: false }],
    limit: 1,
  });
  const unposting = unpostings[0] ?? null;
  return {
    draft: draft['document'],
    lines: draft['lines'],
    unposting,
    note:
      unposting !== null && unposting['number_returned'] === false
        ? `The document is a draft again and its entry ${String(unposting['entry_number'])} is gone. Its number was not the last one drawn and stays unused, which this country allows; posting again draws the next one.`
        : 'The document is a draft again and its entry is gone. Its number went back to the counter, and posting again draws it once more.',
  };
}

export interface UndoDocumentArgs {
  document_id: string;
  /** The day a credit note is issued on. Given, it asks for the credit note: a draft has no date to undo on. */
  date?: string | undefined;
  /** True: a credit note, even where the document could go back to draft. */
  credit_note?: boolean | undefined;
}

/**
 * Undoes a posted document the one way its country and its facts allow, and
 * says which.
 *
 * Back to draft where `unpost_refusal()` finds nothing against it — the
 * country's `posted_edit_policy` allows it, the document was never sent, is
 * not settled or declared, its period is open and, where numbering is gapless,
 * its number is the last one drawn. A credit note otherwise, through
 * `cancel_document()`, with the sentence that ruled the draft out. The choice
 * is the database's: this asks it, and never works the rules out again.
 *
 * A date, or `credit_note: true`, asks for the credit note outright. A date
 * says when a correction is booked, which only a credit note has; asking to go
 * back to draft on a given day would be asking for something else.
 */
export async function undoDocument(backend: Backend, args: UndoDocumentArgs): Promise<unknown> {
  let why: string | null;
  if (args.credit_note === true) {
    why = 'A credit note was asked for.';
  } else if (args.date !== undefined) {
    why = `A date was given (${args.date}), and a date is when a credit note is booked.`;
  } else {
    const [refusal] = await backend.rpc<string | null>('unpost_refusal', { p_document_id: args.document_id });
    why = refusal ?? null;
  }

  if (why === null) {
    return { undone_by: 'draft', why: null, ...((await unpostDocument(backend, args)) as Row) };
  }
  return {
    undone_by: 'credit_note',
    why,
    ...((await cancelDocument(backend, { document_id: args.document_id, date: args.date })) as Row),
  };
}

export async function listDocuments(
  backend: Backend,
  args: ListDocumentsArgs,
): Promise<unknown> {
  const where: Filter[] = [{ column: 'company_id', op: 'eq', value: args.company_id }];
  if (args.doc_type !== undefined) where.push({ column: 'doc_type', op: 'eq', value: args.doc_type });
  if (args.state !== undefined) where.push({ column: 'state', op: 'eq', value: args.state });
  if (args.unpaid === true) {
    if (args.state === undefined) where.push({ column: 'state', op: 'eq', value: 'posted' });
    where.push({ column: 'payment_state', op: 'in', value: ['not_paid', 'partially_paid'] });
  }
  if (args.payment_state !== undefined) where.push({ column: 'payment_state', op: 'eq', value: args.payment_state });
  if (args.contact_id !== undefined) where.push({ column: 'contact_id', op: 'eq', value: args.contact_id });
  if (args.from !== undefined) where.push({ column: 'document_date', op: 'gte', value: args.from });
  if (args.to !== undefined) where.push({ column: 'document_date', op: 'lte', value: args.to });

  const documents = await backend.select<Row>({
    table: 'documents',
    columns: columns.DOCUMENT,
    where,
    order: [{ column: 'document_date', ascending: false }],
    limit: args.limit ?? 50,
  });
  const names = await namesOf(backend, 'contacts', documents.map((doc) => doc['contact_id'] as string));

  return {
    documents: documents.map((doc) => ({
      ...doc,
      contact_name: names[doc['contact_id'] as string] ?? null,
    })),
    count: documents.length,
  };
}

export async function getDocument(
  backend: Backend,
  args: GetDocumentArgs,
): Promise<unknown> {
  const document = onlyVisible(
    await backend.select<Row>({
      table: 'documents',
      columns: columns.DOCUMENT,
      where: [{ column: 'id', op: 'eq', value: args.document_id }],
    }),
    `document ${args.document_id}`,
  );

  const lines = await backend.select<Row>({
    table: 'document_lines',
    columns: columns.DOCUMENT_LINE,
    where: [{ column: 'document_id', op: 'eq', value: args.document_id }],
    order: [{ column: 'sequence' }],
  });

  const [contact, accounts, taxes] = await Promise.all([
    namesOf(backend, 'contacts', [document['contact_id'] as string]),
    backend.select<{ id: string; code: string; name: string }>({
      table: 'accounts',
      columns: ['id', 'code', 'name'],
      where: [
        {
          column: 'id',
          op: 'in',
          value: lines.map((line) => line['account_id']).filter((id): id is string => typeof id === 'string'),
        },
      ],
    }),
    backend.select<{ id: string; code: string; amount: string }>({
      table: 'taxes',
      columns: ['id', 'code', 'amount::text'],
      where: [
        {
          column: 'id',
          op: 'in',
          value: lines.map((line) => line['tax_id']).filter((id): id is string => typeof id === 'string'),
        },
      ],
    }),
  ]);
  const accountById = new Map(accounts.map((account) => [account.id, account]));
  const taxById = new Map(taxes.map((tax) => [tax.id, tax]));

  const entryId = document['entry_id'];
  let entry: Row | null = null;
  let entryLines: Row[] = [];
  if (typeof entryId === 'string') {
    entry = (
      await backend.select<Row>({
        table: 'entries',
        columns: columns.ENTRY,
        where: [{ column: 'id', op: 'eq', value: entryId }],
      })
    )[0] as Row;
    entryLines = await backend.select<Row>({
      table: 'entry_lines',
      columns: columns.ENTRY_LINE,
      where: [{ column: 'entry_id', op: 'eq', value: entryId }],
      order: [{ column: 'sequence' }],
    });
  }

  const ledgerAccounts = await namesOf(
    backend,
    'accounts',
    entryLines.map((line) => line['account_id'] as string),
  );

  // What the law of the document's country asks of it. The mentions come from
  // the view, which already decided which of them apply from the treatments of
  // the taxes on the lines; the rules come from the country model, reached
  // through the company's fiscal country — the country whose VAT applies, not
  // the address. Both are null-tolerant: a country that has said nothing
  // returns nothing, and the caller is never handed another country's answer.
  const [mentions, headers] = await Promise.all([
    backend.select<Row>({
      table: 'document_legal_mentions',
      columns: columns.DOCUMENT_LEGAL_MENTION,
      where: [{ column: 'document_id', op: 'eq', value: args.document_id }],
      order: [{ column: 'sequence' }],
    }),
    backend.select<Row>({
      table: 'document_header',
      columns: columns.DOCUMENT_HEADER,
      where: [{ column: 'document_id', op: 'eq', value: args.document_id }],
    }),
  ]);
  const header = headers[0] ?? null;

  // The country rules used to be fetched here, company then country_defaults,
  // which is what `document_header` now does in one read. They keep their own
  // key in the answer because that is what a caller asks for by name — but
  // they are a slice of the header and not a second query.
  const countryRules =
    header === null
      ? null
      : Object.fromEntries(
          columns.COUNTRY_DOCUMENT_RULES.map((column) => {
            const name = column.split('::')[0] as string;
            return [name, header[name] ?? null];
          }),
        );

  return {
    document: { ...document, contact_name: contact[document['contact_id'] as string] ?? null },
    lines: lines.map((line) => ({
      ...line,
      account: accountById.get(line['account_id'] as string) ?? null,
      tax: taxById.get(line['tax_id'] as string) ?? null,
    })),
    header,
    legal_mentions: mentions,
    country_rules: countryRules,
    entry,
    entry_lines: entryLines.map((line) => ({
      ...line,
      account_name: ledgerAccounts[line['account_id'] as string] ?? null,
    })),
  };
}

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/**
 * The document a person means: its id, its number, or the reference its
 * creator gave it. A draft has no number yet, which is what the third is for.
 */
export async function resolveDocument(backend: Backend, company: string, wanted: string): Promise<string> {
  if (UUID.test(wanted)) return wanted.toLowerCase();
  for (const column of ['number', 'client_ref']) {
    const found = await backend.select<{ id: string }>({
      table: 'documents',
      columns: ['id'],
      where: [
        { column: 'company_id', op: 'eq', value: company },
        { column, op: 'eq', value: wanted },
      ],
      limit: 2,
    });
    if (found.length > 1) {
      throw new BooksError(`ambiguous_document: ${found.length} documents of this company carry the ${column} ${wanted}. Name one by its id.`);
    }
    if (found[0] !== undefined) return found[0].id;
  }
  throw new BooksError(`unknown_document: no document of this company has the number or the reference ${wanted}.`);
}
