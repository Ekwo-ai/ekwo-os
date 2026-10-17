/**
 * `ekwo einvoice validate | issue | status | list | fiscalise | fiscalisation`
 * — the electronic invoice of a posted sale, and the fiscal record its
 * country's fiscalisation regime requires, through the `einvoicing` module.
 *
 * Each verb is one function of the core — `validateEinvoice()`,
 * `issueEinvoice()`, `einvoiceStatus()`, `listEinvoiceTransmissions()` — which
 * the MCP server calls for the tool of the same name. Which format a document
 * is written in is its company's country pack's; which rules the file breaks
 * is the brick's; whether it may leave is the database's. What is here is the
 * one thing a command line adds: where the file goes. `--to <directory>` (or
 * `EKWO_EINVOICE_DIRECTORY`) is the folder transport, the one this release
 * ships; nothing else is ever dialled.
 *
 * The exit code follows the contract. A file that breaks a rule is a check
 * that found something — 1, the rules in the document — whether it was only
 * checked or also kept; a refusal of the database is 3, word for word.
 */

import { readFile, writeFile } from 'node:fs/promises';
import {
  FISCAL_RECORD_KINDS,
  FISCAL_SUBMISSION_MODES,
  FISCAL_SYSTEM_ENV,
  TRANSMISSION_STATES,
  directoryTransport,
  einvoiceStatus,
  fiscalisationStatus,
  fiscaliseDocument,
  parseFiscalSystem,
  issueEinvoice,
  listEinvoiceTransmissions,
  resolveDocument,
  validateEinvoice,
  type EinvoiceTransport,
  type FiscalRecordKind,
  type FiscalSubmissionMode,
  type TransmissionState,
} from '@ekwo-ai/core';
import { UsageError, boolFlag, numberFlag, rejectUnknownFlags, stringFlag, type ParsedArgs } from '../args.js';
import { BOOKS_FLAGS, given, openBooks, required, type BooksDeps } from '../books.js';
import { EXIT_ERROR, EXIT_OK, setResult } from '../output.js';
import { dim, heading, line, note, pairs, step, table, warn } from '../ui.js';

type Row = Record<string, unknown>;

/** The variable that names the folder, as the MCP server reads it too. */
export const EINVOICE_DIRECTORY_ENV = 'EKWO_EINVOICE_DIRECTORY';

const VALIDATE_FLAGS = [...BOOKS_FLAGS, 'out'] as const;
const ISSUE_FLAGS = [...BOOKS_FLAGS, 'out', 'send', 'to'] as const;
const STATUS_FLAGS = [...BOOKS_FLAGS, 'refresh', 'to'] as const;
const LIST_FLAGS = [...BOOKS_FLAGS, 'doc', 'state', 'limit'] as const;
const FISCALISE_FLAGS = [...BOOKS_FLAGS, 'system', 'kind', 'mode', 'rectification', 'dry-run', 'out'] as const;
const FISCALISATION_FLAGS = [...BOOKS_FLAGS, 'limit'] as const;

const USAGE =
  'usage: ekwo einvoice validate <document> [--out <file>]' +
  ' | ekwo einvoice issue <document> [--send --to <directory>] [--out <file>]' +
  ' | ekwo einvoice status <document> [--refresh --to <directory>]' +
  ' | ekwo einvoice list [--doc <document> --state <state> --limit <n>]' +
  ' | ekwo einvoice fiscalise <document> [--system <file>] [--kind alta|anulacion] [--mode <mode>] [--rectification <code>] [--dry-run] [--out <file>]' +
  ' | ekwo einvoice fiscalisation [--limit <n>]';

const text = (value: unknown): string => (value === null || value === undefined ? '' : String(value));

/** The folder of `--to`, or of the environment; none when neither names one. */
function transportOf(args: ParsedArgs, deps: BooksDeps): EinvoiceTransport | undefined {
  const directory = stringFlag(args, 'to') ?? (deps.env ?? process.env)[EINVOICE_DIRECTORY_ENV]?.trim();
  return directory === undefined || directory === '' ? undefined : directoryTransport(directory);
}

/** The rules a file breaks, one per line, as the format names them. */
function printViolations(violations: Row[]): void {
  if (violations.length === 0) {
    note(dim('It breaks no rule this release re-reads.'));
    return;
  }
  warn(`It breaks ${violations.length} rule(s), and a file that breaks one is not sent:`);
  for (const violation of violations) {
    line(`  ${text(violation['code'])}${violation['line'] === undefined ? '' : ` (line ${text(violation['line'])})`}: ${text(violation['message'])}`);
  }
}

export async function einvoiceCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  switch (args.positional[0]) {
    case 'validate':
      return validate(args, deps);
    case 'issue':
      return issue(args, deps);
    case 'status':
      return status(args, deps);
    case 'list':
      return list(args, deps);
    case 'fiscalise':
      return fiscalise(args, deps);
    case 'fiscalisation':
      return fiscalisation(args, deps);
    default:
      throw new UsageError(USAGE);
  }
}

async function validate(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, VALIDATE_FLAGS);
  const { backend, company } = await openBooks(args, deps);
  const documentId = await resolveDocument(backend, company.id, required(args.positional[1], 'the document', '<document>'));
  const out = stringFlag(args, 'out');

  const result = await validateEinvoice(backend, { document_id: documentId, include_file: out !== undefined });
  const { file, ...rest } = result;
  if (out !== undefined) await writeFile(out, String(file), 'utf8');
  setResult({ ...rest, ...(out === undefined ? {} : { written_to: out }) });

  heading(`The electronic invoice of ${text(result['number'])}, in ${company.name}`);
  pairs([
    ['profile', `${text(result['profile'])}  ${dim(text(result['brick']))}`],
    ['file', `${text(result['filename'])}  ${dim(`${text(result['byte_size'])} bytes, sha256 ${text(result['checksum'])}`)}`],
    ...(out === undefined ? [] : [['written to', out] as [string, string]]),
  ]);
  line();
  printViolations(result['violations'] as Row[]);
  line();
  note(dim(text(result['note'])));
  return result['sendable'] === true ? EXIT_OK : EXIT_ERROR;
}

async function issue(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, ISSUE_FLAGS);
  const { backend, company } = await openBooks(args, deps);
  const documentId = await resolveDocument(backend, company.id, required(args.positional[1], 'the document', '<document>'));
  const out = stringFlag(args, 'out');
  const send = boolFlag(args, 'send');
  const transport = transportOf(args, deps);
  if (!send && stringFlag(args, 'to') !== undefined) {
    throw new UsageError('bad_flags: --to says where a file is sent, and --send was not given. Nothing would leave.');
  }

  const result = await issueEinvoice(backend, { document_id: documentId, send, include_file: out !== undefined }, transport);
  const { file, ...rest } = result;
  if (out !== undefined) await writeFile(out, String(file), 'utf8');
  setResult({ ...rest, ...(out === undefined ? {} : { written_to: out }) });

  const kept = (result['issue'] ?? {}) as Row;
  heading(`Issued, in ${company.name}`);
  pairs([
    ['document', `${text(result['doc_type'])} ${text(result['number'])}  ${dim(documentId)}`],
    ['issue', `${text(kept['sequence'])} — ${text(kept['profile'])}, ${text(kept['filename'])}  ${dim(text(kept['id']))}`],
    ['checksum', dim(`sha256 ${text(kept['checksum'])}`)],
    ...(out === undefined ? [] : [['written to', out] as [string, string]]),
  ]);
  line();
  printViolations(result['violations'] as Row[]);
  const transmission = result['transmission'] as Row | null;
  if (transmission !== null) {
    line();
    step(`sending ${text(transmission['sequence'])}: ${text(transmission['state'])}`);
    pairs([
      ['through', text(transmission['service'] ?? transmission['channel'])],
      ['reference', text(transmission['reference'])],
      ...(transmission['message'] === null ? [] : [['message', text(transmission['message'])] as [string, string]]),
    ]);
  }
  line();
  note(dim(text(result['note'])));
  return result['sendable'] === true ? EXIT_OK : EXIT_ERROR;
}

async function status(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, STATUS_FLAGS);
  const { backend, company } = await openBooks(args, deps);
  const documentId = await resolveDocument(backend, company.id, required(args.positional[1], 'the document', '<document>'));
  const refresh = boolFlag(args, 'refresh');

  const result = await einvoiceStatus(backend, { document_id: documentId, refresh }, refresh ? transportOf(args, deps) : undefined);
  setResult(result);

  heading(`The electronic invoice of ${documentId}, in ${company.name}`);
  pairs([['state', text(result['state'])]]);
  const issues = result['issues'] as Row[];
  if (issues.length > 0) {
    line();
    table(
      [{ title: 'issue', align: 'right' }, { title: 'profile' }, { title: 'file' }, { title: 'sendable' }, { title: 'issued' }],
      issues.map((i) => [text(i['sequence']), text(i['profile']), text(i['filename']), i['sendable'] === true ? 'yes' : 'no', text(i['issued_at'])]),
    );
  }
  for (const transmission of result['transmissions'] as Row[]) {
    line();
    step(`sending ${text(transmission['sequence'])}: ${text(transmission['state'])} — ${text(transmission['service'] ?? transmission['channel'])} ${dim(text(transmission['reference']))}`);
    for (const event of (transmission['events'] ?? []) as Row[]) {
      line(`    ${dim(text(event['recorded_at']))}  ${text(event['state'])}${event['message'] === null ? '' : `: ${text(event['message'])}`}`);
    }
  }
  const asked = result['refresh'] as Row | undefined;
  if (asked !== undefined) {
    line();
    note(dim(asked['asked'] === false ? `Not asked: ${text(asked['why'])}.` : asked['answered'] === false ? `The transport could not be asked: ${text(asked['message'])}` : 'Asked again, and recorded.'));
  }
  return EXIT_OK;
}

async function list(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, LIST_FLAGS);
  const { backend, company } = await openBooks(args, deps);
  const doc = stringFlag(args, 'doc');
  const state = stringFlag(args, 'state');
  if (state !== undefined && !(TRANSMISSION_STATES as readonly string[]).includes(state)) {
    throw new UsageError(`bad_value: --state is one of ${TRANSMISSION_STATES.join(', ')}, got "${state}".`);
  }
  const result = await listEinvoiceTransmissions(
    backend,
    given({
      company_id: company.id,
      document_id: doc === undefined ? undefined : await resolveDocument(backend, company.id, doc),
      state: state as TransmissionState | undefined,
      limit: numberFlag(args, 'limit'),
    }) as Parameters<typeof listEinvoiceTransmissions>[1],
  );
  setResult(result);

  heading(`Electronic invoices sent by ${company.name}`);
  const transmissions = result['transmissions'] as Row[];
  if (transmissions.length === 0) note(dim('None.'));
  else {
    table(
      [{ title: 'prepared' }, { title: 'document' }, { title: 'sending', align: 'right' }, { title: 'state' }, { title: 'through' }, { title: 'reference' }],
      transmissions.map((t) => [
        text(t['prepared_at']),
        text((t['document'] as Row | null)?.['number']),
        text(t['sequence']),
        text(t['state']),
        text(t['service'] ?? t['channel']),
        text(t['reference']),
      ]),
    );
  }
  return EXIT_OK;
}

/** The invoicing system, from --system <file> or the environment; refused by name when neither says. */
async function systemOf(args: ParsedArgs, deps: BooksDeps) {
  const file = stringFlag(args, 'system');
  if (file !== undefined) return parseFiscalSystem(await readFile(file, 'utf8'), file);
  const value = (deps.env ?? process.env)[FISCAL_SYSTEM_ENV]?.trim();
  if (value === undefined || value === '') {
    throw new UsageError(
      `no_fiscal_system: a fiscal record is chained by an invoicing system its operator describes — --system <file> or ${FISCAL_SYSTEM_ENV}, as JSON: name, id, version, installation, producerName, producerTaxId.`,
    );
  }
  return parseFiscalSystem(value);
}

async function fiscalise(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, FISCALISE_FLAGS);
  const kind = stringFlag(args, 'kind');
  if (kind !== undefined && !(FISCAL_RECORD_KINDS as readonly string[]).includes(kind)) {
    throw new UsageError(`bad_value: --kind is one of ${FISCAL_RECORD_KINDS.join(', ')}, got "${kind}".`);
  }
  const mode = stringFlag(args, 'mode');
  if (mode !== undefined && !(FISCAL_SUBMISSION_MODES as readonly string[]).includes(mode)) {
    throw new UsageError(`bad_value: --mode is one of ${FISCAL_SUBMISSION_MODES.join(', ')}, got "${mode}".`);
  }
  const system = await systemOf(args, deps);
  const { backend, company } = await openBooks(args, deps);
  const documentId = await resolveDocument(backend, company.id, required(args.positional[1], 'the document', '<document>'));
  const out = stringFlag(args, 'out');
  const rectification = stringFlag(args, 'rectification');

  const result = await fiscaliseDocument(backend, documentId, {
    system,
    dryRun: boolFlag(args, 'dry-run'),
    includeFile: out !== undefined,
    ...(kind === undefined ? {} : { kind: kind as FiscalRecordKind }),
    ...(mode === undefined ? {} : { mode: mode as FiscalSubmissionMode }),
    ...(rectification === undefined ? {} : { rectification }),
  });
  const { file, ...rest } = result;
  if (out !== undefined && typeof file === 'string') await writeFile(out, file, 'utf8');
  setResult({ ...rest, ...(out === undefined || typeof file !== 'string' ? {} : { written_to: out }) });

  const record = result['record'] as Row | null;
  heading(`The fiscal record of ${text(result['number'])}, in ${company.name}`);
  pairs([
    ['format', `${text(result['format'])}  ${dim(text(result['brick']))}`],
    ['kind', `${text(result['kind'])}${result['mode'] === undefined ? '' : `, sent ${text(result['mode'])}`}`],
    ['system', text(result['system_id'])],
    ...(record === null
      ? []
      : ([
          ['chain', `record ${text(record['seq'])}${record['is_first'] === true ? ', the first' : ''}  ${dim(text(record['id']))}`],
          ['hash', dim(text(record['hash']))],
        ] as [string, string][])),
    ...(result['verification_url'] === null || result['verification_url'] === undefined
      ? []
      : ([['QR code', text(result['verification_url'])]] as [string, string][])),
    ...(out === undefined || typeof file !== 'string' ? [] : [['written to', out] as [string, string]]),
  ]);
  line();
  const violations = (result['violations'] ?? []) as Row[];
  if (violations.length === 0) note(dim('It breaks no rule this release re-reads.'));
  else {
    warn(`It breaks ${violations.length} rule(s), and a record that breaks one is not chained:`);
    for (const violation of violations) line(`  ${text(violation['code'])}: ${text(violation['message'])}`);
  }
  line();
  note(dim(text(result['note'])));
  return violations.length === 0 ? EXIT_OK : EXIT_ERROR;
}

async function fiscalisation(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, FISCALISATION_FLAGS);
  const { backend, company } = await openBooks(args, deps);
  const limit = numberFlag(args, 'limit');
  const result = await fiscalisationStatus(backend, company.id, limit === undefined ? {} : { limit });
  setResult(result);

  heading(`Fiscal records of ${company.name}`);
  const regime = result['regime'] as Row | null;
  if (regime === null) {
    note(dim(text(result['note'])));
    return EXIT_OK;
  }
  pairs([
    ['format', `${text(regime['format'])}  ${dim(text(regime['brick']))}`],
    ['sent', `${text(regime['mode'])} ${dim(`(${(regime['modes'] as string[]).join(', ')})`)}`],
    [
      'obligation',
      (regime['mandatory_from'] as Row[]).map((entry) => (entry['who'] === null ? text(entry['from']) : `${text(entry['from'])} (${text(entry['who'])})`)).join(', ') || 'no date declared',
    ],
  ]);
  const systems = result['systems'] as Row[];
  if (systems.length > 0) {
    line();
    table(
      [{ title: 'system' }, { title: 'records', align: 'right' }, { title: 'chain' }],
      systems.map((s) => [
        text(s['system_id']),
        text(s['records']),
        s['verified'] === true ? 'intact' : `breaks at ${text((s['break'] as Row | null)?.['seq'])}: ${text((s['break'] as Row | null)?.['problem'])}`,
      ]),
    );
  }
  line();
  pairs([
    ['to send', text(result['pending_count'])],
    ['without a record', text(result['missing_count'])],
  ]);
  for (const document of result['missing'] as Row[]) {
    line(`    ${text(document['document_date'])}  ${text(document['number'])}  ${dim(text(document['id']))}`);
  }
  line();
  note(dim(text(result['note'])));
  return result['verified'] === true ? EXIT_OK : EXIT_ERROR;
}
