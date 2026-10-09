/**
 * Issuing the electronic invoice of a posted sale, for every surface at once.
 *
 * The MCP server and the command line call these four functions with their
 * own `Backend`, which acts as the person signed in:
 *
 *   - `validateEinvoice()` writes the file and says what is wrong with it,
 *     and records nothing. A question, asked as often as one likes.
 *   - `issueEinvoice()` writes it and keeps it — the exact text, its
 *     checksum, the rules it breaks — through `einvoicing.record_issue()`;
 *     and, given a transport and asked to, sends it: a transmission recorded
 *     as prepared, the file handed over, and what the transport answered
 *     recorded beside it, in its own words.
 *   - `einvoiceStatus()` is what is known of a document: its files, its
 *     sendings and every answer; given the transport that sent it, it asks
 *     that transport again and records what it says.
 *   - `listEinvoiceTransmissions()` is every sending of a company, or of one
 *     document.
 *
 * The rules that matter are the database's: a document that is not a posted
 * sale, a profile that is not the pack's, a file that breaks a rule, a second
 * sending of a document already on its way, a state that would move backwards
 * — each is refused there, by name, for this code and for any other client.
 * What is here is what only a program can do: run the brick, compute a
 * checksum, call a transport.
 */

import { createHash } from 'node:crypto';
import { BooksError, type Backend, type Row } from '../books/backend.js';
import { onlyVisible } from '../books/shared.js';
import { einvoiceFormat, type EinvoiceSource, type EinvoiceViolation } from './formats.js';
import {
  CLOSED_STATES,
  TransportError,
  type EinvoiceFile,
  type EinvoiceTransport,
  type ElectronicAddress,
  type TransmissionOutcome,
  type TransmissionState,
} from './transport.js';

const SCHEMA = 'einvoicing';

/** What the bricks read of `document_header`, every date and amount as the text the database holds. */
const HEADER = [
  'document_id', 'company_id', 'doc_type', 'state', 'number', 'language',
  'document_date::text', 'due_date::text', 'delivery_date::text', 'tax_point_date::text',
  'currency_code', 'amount_untaxed::text', 'amount_tax::text', 'amount_total::text', 'amount_paid::text',
  'amount_residual::text', 'payment_terms', 'payment_means_code', 'payment_reference', 'payee_iban', 'payee_bic',
  'buyer_reference', 'order_reference', 'contract_reference', 'project_reference', 'note',
  'seller_name', 'seller_legal_name', 'seller_legal_form', 'seller_vat_number', 'seller_registration_number',
  'seller_address_line1', 'seller_address_line2', 'seller_postal_code', 'seller_city', 'seller_country',
  'seller_region', 'seller_email', 'seller_phone',
  'buyer_name', 'buyer_vat_number', 'buyer_registration_number', 'buyer_address_line1', 'buyer_address_line2',
  'buyer_postal_code', 'buyer_city', 'buyer_country', 'buyer_region', 'buyer_email',
  'delivery_address_line1', 'delivery_postal_code', 'delivery_city', 'delivery_country',
  'seller_peppol_scheme', 'seller_peppol_identifier', 'buyer_peppol_scheme', 'buyer_peppol_identifier',
  'einvoice_profile',
];

/** What the bricks read of `document_line_items`. */
const LINES = [
  'sequence', 'line_type', 'item_name', 'item_description', 'seller_item_identifier',
  'quantity::text', 'unit_code', 'unit_price::text', 'discount_percent::text', 'unit_price_includes_tax',
  'amount_untaxed::text', 'vat_category', 'vat_rate::text', 'tax_exemption_code',
];

/** What the bricks read of `document_tax_summary`. */
const TAXES = [
  'tax_code', 'vat_category', 'tax_rate::text', 'base_amount::text', 'tax_charged::text',
  'exemption_code', 'exemption_reason',
];

/** An issue as it is handed back: everything but the file itself, which is asked for by name. */
const ISSUE = [
  'id', 'company_id', 'document_id', 'sequence', 'profile', 'brick', 'specification', 'filename',
  'media_type', 'byte_size', 'checksum', 'violations', 'sendable', 'issued_at', 'issued_by',
];

const TRANSMISSION = [
  'id', 'company_id', 'document_id', 'issue_id', 'sequence', 'channel', 'service', 'reference',
  'state', 'state_at', 'message', 'prepared_at', 'prepared_by',
];

const EVENT = [
  'transmission_id', 'sequence', 'state', 'reference', 'message', 'detail', 'occurred_at', 'recorded_at',
  'recorded_by',
];

/** SHA-256 of a file as UTF-8, in lower-case hexadecimal: what the database computes again. */
export function einvoiceChecksum(content: string): string {
  return createHash('sha256').update(content, 'utf8').digest('hex');
}

/** A file written from the books, before anything was recorded. */
export interface ProducedEinvoice {
  document_id: string;
  company_id: string;
  doc_type: string;
  number: string | null;
  profile: string;
  brick: string;
  syntax: string;
  specification: string;
  filename: string;
  media_type: string;
  checksum: string;
  byte_size: number;
  violations: EinvoiceViolation[];
  sendable: boolean;
  content: string;
  sender: ElectronicAddress | null;
  recipient: ElectronicAddress | null;
}

/** The three views of one document, and the invoice it credits where it is a credit note. */
export async function readEinvoiceSource(backend: Backend, documentId: string): Promise<EinvoiceSource> {
  const header = onlyVisible(
    await backend.select<Row>({
      table: 'document_header',
      columns: HEADER,
      where: [{ column: 'document_id', op: 'eq', value: documentId }],
    }),
    `document ${documentId}`,
  );
  const [lines, taxes, documents] = await Promise.all([
    backend.select<Row>({
      table: 'document_line_items',
      columns: LINES,
      where: [{ column: 'document_id', op: 'eq', value: documentId }],
      order: [{ column: 'sequence' }],
    }),
    backend.select<Row>({
      table: 'document_tax_summary',
      columns: TAXES,
      where: [{ column: 'document_id', op: 'eq', value: documentId }],
      order: [{ column: 'tax_code' }],
    }),
    backend.select<{ reversed_document_id: string | null }>({
      table: 'documents',
      columns: ['reversed_document_id'],
      where: [{ column: 'id', op: 'eq', value: documentId }],
    }),
  ]);

  let preceding: EinvoiceSource['preceding'] = null;
  const credited = documents[0]?.reversed_document_id ?? null;
  if (credited !== null) {
    const [original] = await backend.select<{ number: string | null; document_date: string | null }>({
      table: 'documents',
      columns: ['number', 'document_date::text'],
      where: [{ column: 'id', op: 'eq', value: credited }],
    });
    if (original?.number) preceding = { number: original.number, issueDate: original.document_date ?? null };
  }
  return { header, lines, taxes, preceding };
}

function addressOf(header: Row, side: 'seller' | 'buyer'): ElectronicAddress | null {
  const scheme = header[`${side}_peppol_scheme`];
  const id = header[`${side}_peppol_identifier`];
  return typeof scheme === 'string' && typeof id === 'string' ? { scheme, id } : null;
}

/**
 * Writes the file of a posted sale, in the profile of its company's country
 * pack, and says which rules it breaks. Records nothing.
 */
export async function produceEinvoice(backend: Backend, documentId: string): Promise<ProducedEinvoice> {
  const source = await readEinvoiceSource(backend, documentId);
  const { header } = source;
  const what = `${String(header['doc_type'])} ${String(header['number'] ?? documentId)}`;
  if (header['doc_type'] !== 'sale_invoice' && header['doc_type'] !== 'sale_credit_note') {
    throw new BooksError(
      `document_not_a_sale: ${what} is not a sale invoice or a sale credit note, and only a sale is issued electronically by its seller.`,
    );
  }
  if (header['state'] !== 'posted') {
    throw new BooksError(
      `document_not_posted: ${what} is ${String(header['state'])}, and only a posted document is issued: post it first, and the file says what the books say.`,
      { hint: 'post_document (ekwo post <document>) books it; --dry-run shows the entry first.' },
    );
  }

  const format = einvoiceFormat(header['einvoice_profile'] as string | null);
  const written = format.write(source);
  return {
    document_id: documentId,
    company_id: String(header['company_id']),
    doc_type: String(header['doc_type']),
    number: (header['number'] as string | null) ?? null,
    profile: format.profile,
    brick: format.brick,
    syntax: format.syntax,
    specification: format.specification,
    filename: written.filename,
    media_type: format.mediaType,
    checksum: einvoiceChecksum(written.content),
    byte_size: Buffer.byteLength(written.content, 'utf8'),
    violations: written.violations,
    sendable: written.violations.length === 0,
    content: written.content,
    sender: addressOf(header, 'seller'),
    recipient: addressOf(header, 'buyer'),
  };
}

export interface ValidateEinvoiceArgs {
  document_id: string;
  /** Hand the file back too. Left out, the answer is what is wrong with it. */
  include_file?: boolean;
}

/** The file a posted sale would be issued as, and every rule it breaks. Nothing is recorded. */
export async function validateEinvoice(backend: Backend, args: ValidateEinvoiceArgs): Promise<Row> {
  const produced = await produceEinvoice(backend, args.document_id);
  const { content, sender, recipient, ...rest } = produced;
  return {
    ...rest,
    sender,
    recipient,
    ...(args.include_file === true ? { file: content } : {}),
    note: produced.sendable
      ? 'The file breaks no rule this release re-reads. Nothing was recorded: einvoicing_issue keeps it and sends it.'
      : 'The file breaks the rules listed, and a file that breaks one is not sent. They are completed in the books — an address, a due date, a reference — not in the file. Nothing was recorded.',
  };
}

export interface IssueEinvoiceArgs {
  document_id: string;
  /** Send it as well, through `transport`. Left out, the file is kept and nothing leaves. */
  send?: boolean;
  /** Hand the file back too. */
  include_file?: boolean;
}

/** Every column of an issue but the file. */
function withoutContent(issue: Row): Row {
  return Object.fromEntries(Object.entries(issue).filter(([key]) => key !== 'content'));
}

async function rpcOne(backend: Backend, fn: string, args: Record<string, unknown>): Promise<Row> {
  const [row] = await backend.rpc<Row>(fn, args, SCHEMA);
  if (row === undefined) throw new BooksError(`einvoicing_no_answer: ${SCHEMA}.${fn} answered nothing`);
  return row;
}

async function recordOutcome(
  backend: Backend,
  transmissionId: string,
  outcome: { state: TransmissionState; reference?: string | null; message?: string | null; detail?: unknown; occurredAt?: string | null },
): Promise<Row> {
  return rpcOne(backend, 'record_transmission_outcome', {
    p_transmission_id: transmissionId,
    p_state: outcome.state,
    p_reference: outcome.reference ?? null,
    p_message: outcome.message ?? null,
    p_detail: outcome.detail === undefined || outcome.detail === null ? null : outcome.detail,
    p_occurred_at: outcome.occurredAt ?? null,
  });
}

/**
 * Hands one recorded file to a transport, and records what it answered — or
 * that it could not take the file, in the words of the error.
 */
async function sendThrough(
  backend: Backend,
  transport: EinvoiceTransport,
  produced: ProducedEinvoice,
  issue: Row,
): Promise<Row> {
  const transmission = await rpcOne(backend, 'record_transmission', {
    p_issue_id: issue['id'],
    p_channel: transport.channel,
    p_service: transport.service,
  });
  const file: EinvoiceFile = {
    filename: produced.filename,
    mediaType: produced.media_type,
    content: produced.content,
    checksum: produced.checksum,
    profile: produced.profile,
  };
  let answer;
  try {
    answer = await transport.send(file, {
      companyId: produced.company_id,
      documentId: produced.document_id,
      documentNumber: produced.number,
      docType: produced.doc_type,
      issueId: String(issue['id']),
      transmissionId: String(transmission['id']),
      sender: produced.sender,
      recipient: produced.recipient,
    });
  } catch (error) {
    const refused = error instanceof TransportError ? error : null;
    return recordOutcome(backend, String(transmission['id']), {
      state: refused?.state ?? 'failed',
      message: error instanceof Error ? error.message : String(error),
      detail: refused?.detail ?? null,
    });
  }
  return recordOutcome(backend, String(transmission['id']), {
    state: answer.state ?? 'submitted',
    reference: answer.reference,
    message: answer.message ?? null,
    detail: answer.detail ?? null,
  });
}

/**
 * Writes the file of a posted sale and keeps it; sends it too when asked and
 * given a transport. The same file twice is one issue, and a document already
 * on its way is refused by the database rather than sent twice.
 */
export async function issueEinvoice(
  backend: Backend,
  args: IssueEinvoiceArgs,
  transport?: EinvoiceTransport,
): Promise<Row> {
  if (args.send === true && transport === undefined) {
    throw new BooksError(
      'no_transport: sending was asked for and no transport is configured. The file can be issued and kept without one; sending it needs one — the directory transport writes it to a folder.',
      { hint: 'ekwo einvoice issue <document> --send --to <directory>; for the MCP server, EKWO_EINVOICE_DIRECTORY.' },
    );
  }
  const produced = await produceEinvoice(backend, args.document_id);
  const issue = await rpcOne(backend, 'record_issue', {
    p_document_id: produced.document_id,
    p_profile: produced.profile,
    p_brick: produced.brick,
    p_specification: produced.specification,
    p_filename: produced.filename,
    p_media_type: produced.media_type,
    p_content: produced.content,
    p_checksum: produced.checksum,
    p_violations: produced.violations,
  });

  const transmission = args.send === true && transport !== undefined ? await sendThrough(backend, transport, produced, issue) : null;
  return {
    document_id: produced.document_id,
    number: produced.number,
    doc_type: produced.doc_type,
    issue: withoutContent(issue),
    violations: produced.violations,
    sendable: produced.sendable,
    transmission,
    ...(args.include_file === true ? { file: produced.content } : {}),
    note:
      transmission === null
        ? produced.sendable
          ? 'Issued and kept, and nothing has left. Sending it is einvoicing_issue with send, or ekwo einvoice issue --send.'
          : 'Kept as it was written, with the rules it breaks; a file that breaks one is not sent. Complete the books and issue it again: the new file is a new issue.'
        : (CLOSED_STATES as readonly unknown[]).includes(transmission['state'])
          ? `The sending is ${String(transmission['state'])}: ${String(transmission['message'] ?? 'no word came with it')}. It is recorded, and the document may be sent again.`
          : `Handed over, as ${String(transmission['reference'])}. A reference is not a delivery: einvoicing_status asks again.`,
  };
}

export interface EinvoiceStatusArgs {
  document_id: string;
  /** Ask the transport again about the sending that is still open, and record what it says. */
  refresh?: boolean;
}

/**
 * Everything known of the electronic invoice of one document: its files,
 * every sending and every answer. Asked to refresh and given the transport the
 * open sending went through, asks it again and records the answer.
 */
export async function einvoiceStatus(
  backend: Backend,
  args: EinvoiceStatusArgs,
  transport?: EinvoiceTransport,
): Promise<Row> {
  const transmissionsOf = () =>
    backend.select<Row>({
      schema: SCHEMA,
      table: 'transmissions',
      columns: TRANSMISSION,
      where: [{ column: 'document_id', op: 'eq', value: args.document_id }],
      order: [{ column: 'sequence' }],
    });

  let transmissions = await transmissionsOf();
  const open = transmissions.find((t) => !(CLOSED_STATES as readonly unknown[]).includes(t['state']));
  let asked: Row | null = null;
  if (args.refresh === true && open !== undefined) {
    if (transport === undefined) {
      throw new BooksError('no_transport: asking again was requested and no transport is configured to ask.');
    }
    if (open['channel'] !== transport.channel || (open['service'] ?? null) !== transport.service || open['reference'] === null) {
      asked = {
        asked: false,
        why:
          open['reference'] === null
            ? 'the open sending has no reference yet, so there is nothing to ask about'
            : `the open sending went through ${String(open['service'] ?? open['channel'])}, and the transport configured here is ${String(transport.service ?? transport.channel)}`,
      };
    } else {
      let outcome: TransmissionOutcome;
      try {
        outcome = await transport.status(String(open['reference']));
      } catch (error) {
        // The transport could not be asked: nothing about the sending changed.
        asked = { asked: true, answered: false, message: error instanceof Error ? error.message : String(error) };
        outcome = { state: open['state'] as TransmissionOutcome['state'] };
      }
      if (asked === null) {
        await recordOutcome(backend, String(open['id']), {
          state: outcome.state,
          message: outcome.message ?? null,
          detail: outcome.detail ?? null,
          occurredAt: outcome.occurredAt ?? null,
        });
        asked = { asked: true, answered: true, state: outcome.state, message: outcome.message ?? null };
        transmissions = await transmissionsOf();
      }
    }
  }

  const [issues, events] = await Promise.all([
    backend.select<Row>({
      schema: SCHEMA,
      table: 'issues',
      columns: ISSUE,
      where: [{ column: 'document_id', op: 'eq', value: args.document_id }],
      order: [{ column: 'sequence' }],
    }),
    transmissions.length === 0
      ? Promise.resolve([] as Row[])
      : backend.select<Row>({
          schema: SCHEMA,
          table: 'transmission_events',
          columns: EVENT,
          where: [{ column: 'transmission_id', op: 'in', value: transmissions.map((t) => String(t['id'])) }],
          order: [{ column: 'recorded_at' }, { column: 'sequence' }],
        }),
  ]);

  const current = transmissions[transmissions.length - 1] ?? null;
  return {
    document_id: args.document_id,
    issues,
    transmissions: transmissions.map((t) => ({ ...t, events: events.filter((e) => e['transmission_id'] === t['id']) })),
    state: current === null ? (issues.length === 0 ? 'not_issued' : 'issued') : current['state'],
    ...(asked === null ? {} : { refresh: asked }),
  };
}

export interface ListEinvoiceTransmissionsArgs {
  company_id: string;
  document_id?: string;
  state?: TransmissionState;
  limit?: number;
}

/** Every sending of a company, or of one of its documents, the latest first, with the file each one sent. */
export async function listEinvoiceTransmissions(backend: Backend, args: ListEinvoiceTransmissionsArgs): Promise<Row> {
  const where: { column: string; op: 'eq'; value: string }[] = [{ column: 'company_id', op: 'eq', value: args.company_id }];
  if (args.document_id !== undefined) where.push({ column: 'document_id', op: 'eq', value: args.document_id });
  if (args.state !== undefined) where.push({ column: 'state', op: 'eq', value: args.state });
  const transmissions = await backend.select<Row>({
    schema: SCHEMA,
    table: 'transmissions',
    columns: TRANSMISSION,
    where,
    order: [{ column: 'prepared_at', ascending: false }, { column: 'sequence', ascending: false }],
    limit: args.limit ?? 100,
  });
  const issueIds = [...new Set(transmissions.map((t) => String(t['issue_id'])))];
  const documentIds = [...new Set(transmissions.map((t) => String(t['document_id'])))];
  const [issues, documents] = await Promise.all([
    issueIds.length === 0
      ? Promise.resolve([] as Row[])
      : backend.select<Row>({
          schema: SCHEMA,
          table: 'issues',
          columns: ['id', 'profile', 'filename', 'checksum', 'sequence'],
          where: [{ column: 'id', op: 'in', value: issueIds }],
        }),
    documentIds.length === 0
      ? Promise.resolve([] as Row[])
      : backend.select<Row>({
          table: 'documents',
          columns: ['id', 'doc_type', 'number'],
          where: [{ column: 'id', op: 'in', value: documentIds }],
        }),
  ]);
  const issueById = new Map(issues.map((issue) => [issue['id'], issue]));
  const documentById = new Map(documents.map((document) => [document['id'], document]));
  return {
    transmissions: transmissions.map((t) => ({
      ...t,
      document: documentById.get(t['document_id']) ?? null,
      file: issueById.get(t['issue_id']) ?? null,
    })),
    count: transmissions.length,
  };
}
