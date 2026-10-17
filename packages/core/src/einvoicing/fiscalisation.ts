/**
 * Fiscalisation: the chained record a country requires the invoicing
 * software to leave for every invoice it issues.
 *
 * A capability of the `einvoicing` module, and the same shape as issuing an
 * electronic invoice: a posted sale, an artefact a brick writes, a state the
 * database records. Here the artefact is a fiscal record, and what the
 * database keeps is a chain — each record carries the hash of the one before
 * it, in one company and one invoicing system.
 *
 * **The core knows no country.** Whether a company has such a regime, and
 * every rule of it, is the `einvoicing.fiscalisation` block of its country
 * pack, which the socle compiles into `country_defaults.einvoice_fiscalisation`
 * and `einvoicing.fiscal_regime()` reads back. Which brick writes the record
 * is the pack's `format`, looked up in `FISCALISATION_FORMATS` — the same
 * pattern as `EINVOICE_FORMATS` — and a format no brick of this release writes
 * is refused by name, `format_without_brick`.
 *
 * **The gesture is explicit.** Nothing here runs on posting. A posted sale of
 * a company whose pack declares a regime and that has no record is named by
 * `fiscalisationStatus()`, and `fiscaliseDocument()` is called by somebody who
 * decided to chain it — `ekwo einvoice fiscalise`, `einvoicing_fiscalise`.
 *
 * What only a program can do is here: run the brick, read the tail of the
 * chain, read the hashed fields back out of the text the brick hashed. What
 * can be checked without trusting this code is checked again by
 * `einvoicing.append_fiscal_record()`: the regime, the digest, the fields, the
 * tail, a record made once.
 */

import { VERIFACTU } from '@ekwo-ai/verifactu';
import { BooksError, type Backend, type Row } from '../books/backend.js';
import type { EinvoiceViolation } from './formats.js';
import { assertPostedSale, einvoiceChecksum, readEinvoiceSource } from './issue.js';

const SCHEMA = 'einvoicing';

/** How the records of an invoicing system reach the authority. */
export type FiscalSubmissionMode = 'realtime' | 'batch' | 'none';

export const FISCAL_SUBMISSION_MODES = ['realtime', 'batch', 'none'] as const;

/** What a record says of its invoice: issued, or its record cancelled. */
export type FiscalRecordKind = 'alta' | 'anulacion';

export const FISCAL_RECORD_KINDS = ['alta', 'anulacion'] as const;

/**
 * The invoicing system that generates the record. Every field is a fact of
 * the product or of its installation that the operator states, and none is
 * invented here. The three booleans are facts a regime may ask of the
 * product — whether it can only send, whether it can keep the books of
 * several taxpayers, whether it does now; a brick whose regime does not ask
 * ignores them.
 */
export interface FiscalSystem {
  name: string;
  id: string;
  version: string;
  installation: string;
  producerName: string;
  producerTaxId: string;
  verifactuOnly?: boolean;
  multipleTaxpayers?: boolean;
  multipleTaxpayersNow?: boolean;
}

/** One record to write: the document as the books publish it, and what only the system knows. */
export interface FiscalRecordInput {
  header: Row;
  lines: Row[];
  taxes: Row[];
  kind: FiscalRecordKind;
  /** ISO 8601 with its offset: `2027-01-04T10:15:00+01:00`. */
  generatedAt: string;
  system: FiscalSystem;
  /** The record before it in this system, or null for the first. */
  previous: { taxId: string; series: string; number: string; issuedOn: string; hash: string } | null;
}

/** What a brick of `packages/formats/` provides for one fiscalisation format. */
export interface FiscalisationFormat {
  /** The name a pack declares in `einvoicing.fiscalisation.format`. */
  format: string;
  /** The package that writes it, by its published name. */
  brick: string;
  /** What the record declares it follows. */
  specification: string;
  /** The exact text the regime hashes. */
  hashInput(input: FiscalRecordInput): string;
  /** Its digest, as the record carries it. */
  hash(input: FiscalRecordInput): string;
  write(input: FiscalRecordInput): { content: string; filename: string; mediaType: string; violations: EinvoiceViolation[] };
  /** What the QR code of the invoice encodes, for a mode of submission. */
  verificationUrl(input: FiscalRecordInput, mode: FiscalSubmissionMode, environment?: 'production' | 'test'): string;
}

/** Every fiscalisation format a brick of this release writes, by the name a pack declares it under. */
export const FISCALISATION_FORMATS: Readonly<Record<string, FiscalisationFormat>> = {
  [VERIFACTU.format]: VERIFACTU,
};

/**
 * The format of a pack's regime, or the refusal that names the missing brick.
 * Nothing is written in the nearest format that exists: a record in another
 * format is a record the authority refuses.
 */
export function fiscalisationFormat(
  format: string,
  formats: Readonly<Record<string, FiscalisationFormat>> = FISCALISATION_FORMATS,
): FiscalisationFormat {
  const found = formats[format];
  if (found === undefined) {
    throw new BooksError(
      `format_without_brick: the country pack of this company keeps its fiscal records as ${format}, and no brick of packages/formats/ writes ${format} yet. ` +
        `This release writes ${Object.keys(formats).join(' and ') || 'none'}; a record in another format is not a ${format} record, and none is written in its place.`,
    );
  }
  return found;
}

/** The regime of a company as the socle compiled it from its pack, or null where it has none. */
export interface FiscalRegime {
  format: string;
  mandatory_from: { who: string | null; from: string }[];
  hash: { algorithm: string; separator: string | null; fields: Partial<Record<FiscalRecordKind | '*', string[]>> };
  qr: { size_mm: { min: number; max: number }; error_correction: string; label: string | null } | null;
  mention: { text: string; alternatives: string[]; modes: FiscalSubmissionMode[] }[];
  submission: { mode: FiscalSubmissionMode; modes: FiscalSubmissionMode[] };
  events: { summary_every_hours: number; modes: FiscalSubmissionMode[] } | null;
  tax_attributes: Record<string, Record<string, string>>;
  legal_reference: string;
  source: string;
}

/** The fiscalisation regime of a company's fiscal country, or null. */
export async function fiscalRegime(backend: Backend, companyId: string): Promise<FiscalRegime | null> {
  const [regime] = await backend.rpc<FiscalRegime | null>('fiscal_regime', { p_company_id: companyId }, SCHEMA);
  return regime ?? null;
}

/**
 * The fields a hash covers, read back out of the text the brick hashed, in
 * the order the pack names them: `name=value` joined by the pack's separator.
 * Null where the text does not hold them in that order — the pack and the
 * brick then disagree about what is hashed, and nothing is chained.
 */
export function hashedFields(text: string, fields: readonly string[], separator: string): Record<string, string> | null {
  const out: Record<string, string> = {};
  let rest = text;
  for (const [index, field] of fields.entries()) {
    const prefix = `${index === 0 ? '' : separator}${field}=`;
    if (!rest.startsWith(prefix)) return null;
    rest = rest.slice(prefix.length);
    const next = fields[index + 1];
    if (next === undefined) {
      out[field] = rest;
      rest = '';
    } else {
      const at = rest.indexOf(`${separator}${next}=`);
      if (at < 0) return null;
      out[field] = rest.slice(0, at);
      rest = rest.slice(at);
    }
  }
  return out;
}

/** Now, as ISO 8601 with the offset of this machine: what a record says it was generated at. */
export function generatedNow(at: Date = new Date()): string {
  const offset = -at.getTimezoneOffset();
  const local = new Date(at.getTime() + offset * 60_000).toISOString().slice(0, 19);
  const sign = offset < 0 ? '-' : '+';
  const hours = String(Math.floor(Math.abs(offset) / 60)).padStart(2, '0');
  const minutes = String(Math.abs(offset) % 60).padStart(2, '0');
  return `${local}${sign}${hours}:${minutes}`;
}

/** The chain a system keeps for a company: its identifier and its installation. */
export const fiscalSystemId = (system: FiscalSystem): string => `${system.id}:${system.installation}`;

const CHAIN = [
  'id', 'company_id', 'system_id', 'seq', 'document_id', 'kind', 'format', 'issuer_tax_id', 'series', 'number',
  'issued_on::text', 'record', 'hash', 'previous_hash', 'is_first', 'generated_at', 'mode', 'verification_url',
  'issue_id', 'recorded_at', 'recorded_by',
];

export interface FiscaliseOptions {
  system: FiscalSystem;
  /** `alta` (the default) when the invoice is issued, `anulacion` when its record is cancelled. */
  kind?: FiscalRecordKind;
  /** One of the modes the pack allows; the pack's default when left out. */
  mode?: FiscalSubmissionMode;
  /** When the record is generated, ISO 8601 with its offset. Now, on this machine, when left out. */
  generatedAt?: string;
  /** Which service of the authority the verification URL points at. */
  environment?: 'production' | 'test';
  /** Why a credit note rectifies, in the regime's own code, where it asks and the books do not say. */
  rectification?: string;
  /** Write the record and say what is wrong with it; chain nothing. */
  dryRun?: boolean;
  /** Hand the file back too. */
  includeFile?: boolean;
}

/**
 * Writes the fiscal record of a posted sale with the brick its pack's regime
 * names, and — unless it breaks a rule or `dryRun` is asked — chains it after
 * the tail of the system's chain and keeps its file. A document whose record
 * is in the chain already is answered with that record, not chained twice.
 */
export async function fiscaliseDocument(
  backend: Backend,
  documentId: string,
  options: FiscaliseOptions,
  formats: Readonly<Record<string, FiscalisationFormat>> = FISCALISATION_FORMATS,
): Promise<Row> {
  const source = await readEinvoiceSource(backend, documentId);
  const { header } = source;
  assertPostedSale(header, documentId);
  const companyId = String(header['company_id']);
  const what = `${String(header['doc_type'])} ${String(header['number'] ?? documentId)}`;

  const regime = await fiscalRegime(backend, companyId);
  if (regime === null) {
    throw new BooksError(
      `no_fiscalisation_regime: the country pack of this company declares no fiscalisation regime, so ${what} has no fiscal record to keep.`,
      { hint: 'A pack declares one in einvoicing.fiscalisation; describe_pack (ekwo pack describe) shows it.' },
    );
  }
  const format = fiscalisationFormat(regime.format, formats);
  const kind = options.kind ?? 'alta';
  const mode = options.mode ?? regime.submission.mode;
  if (!regime.submission.modes.includes(mode)) {
    throw new BooksError(
      `fiscal_mode_not_allowed: a record of this company is sent as one of ${regime.submission.modes.join(', ')}, not as ${mode}.`,
    );
  }
  const systemId = fiscalSystemId(options.system);

  const chain = await backend.select<Row>({
    schema: SCHEMA,
    table: 'fiscal_chain',
    columns: CHAIN,
    where: [
      { column: 'company_id', op: 'eq', value: companyId },
      { column: 'system_id', op: 'eq', value: systemId },
    ],
    order: [{ column: 'seq', ascending: false }],
    limit: 1,
  });
  const tail = chain[0] ?? null;

  // Asking twice is not a second record.
  const [last] = await backend.select<Row>({
    schema: SCHEMA,
    table: 'fiscal_chain',
    columns: CHAIN,
    where: [
      { column: 'document_id', op: 'eq', value: documentId },
      { column: 'system_id', op: 'eq', value: systemId },
    ],
    order: [{ column: 'seq', ascending: false }],
    limit: 1,
  });
  if (last !== undefined && last['kind'] === kind && options.dryRun !== true) {
    return {
      document_id: documentId,
      number: header['number'] ?? null,
      doc_type: header['doc_type'],
      format: format.format,
      brick: format.brick,
      kind,
      system_id: systemId,
      chained: true,
      already: true,
      record: last,
      violations: [],
      verification_url: last['verification_url'] ?? null,
      note: `${what} has its ${kind} record in this system already, number ${String(last['seq'])} of the chain; nothing was chained again.`,
    };
  }

  // The tax lines carry what the regime needs that the category does not decide alone.
  const taxes = source.taxes.map((tax) => ({ ...tax, ...(regime.tax_attributes[String(tax['tax_code'])] ?? {}) }));
  const input: FiscalRecordInput = {
    header: {
      ...header,
      ...(source.preceding === null
        ? {}
        : { rectified_number: source.preceding.number, rectified_date: source.preceding.issueDate }),
      ...(options.rectification === undefined ? {} : { rectification_type: options.rectification }),
    },
    lines: source.lines,
    taxes,
    kind,
    generatedAt: options.generatedAt ?? generatedNow(),
    system: options.system,
    previous:
      tail === null
        ? null
        : {
            taxId: String(tail['issuer_tax_id']),
            series: String(tail['series'] ?? ''),
            number: String(tail['number']),
            issuedOn: String(tail['issued_on']),
            hash: String(tail['hash']),
          },
  };

  const written = format.write(input);
  const hashInput = format.hashInput(input);
  const hash = format.hash(input);
  const verificationUrl = format.verificationUrl(input, mode, options.environment ?? 'production');
  const fields = regime.hash.fields[kind] ?? regime.hash.fields['*'] ?? [];
  const record = regime.hash.separator === null ? null : hashedFields(hashInput, fields, regime.hash.separator);
  if (record === null) {
    throw new BooksError(
      `fiscal_hash_fields_unread: the pack says the hash of a ${kind} record covers ${fields.join(', ')}, and the text ${format.brick} hashed does not hold them in that order. The pack and the brick disagree about what is hashed; nothing is chained.`,
    );
  }

  const base = {
    document_id: documentId,
    number: header['number'] ?? null,
    doc_type: header['doc_type'],
    format: format.format,
    brick: format.brick,
    specification: format.specification,
    kind,
    mode,
    system_id: systemId,
    generated_at: input.generatedAt,
    hash,
    previous_hash: input.previous?.hash ?? null,
    fields: record,
    verification_url: verificationUrl,
    filename: written.filename,
    violations: written.violations,
    ...(options.includeFile === true ? { file: written.content } : {}),
  };

  if (written.violations.length > 0 || options.dryRun === true) {
    return {
      ...base,
      chained: false,
      record: null,
      note:
        written.violations.length > 0
          ? 'The record breaks the rules listed, and a record that breaks one is not chained: the next one would follow a record the authority refuses. They are completed in the books, not in the record. Nothing was recorded.'
          : 'The record breaks no rule this release re-reads. Nothing was recorded: fiscalise it without dry run to chain it.',
    };
  }

  const [row] = await backend.rpc<Row>(
    'append_fiscal_record',
    {
      p_document_id: documentId,
      p_system_id: systemId,
      p_kind: kind,
      p_format: format.format,
      p_mode: mode,
      p_issuer_tax_id: String(header['seller_vat_number'] ?? ''),
      p_series: '',
      p_number: String(header['number'] ?? ''),
      p_issued_on: header['document_date'],
      p_record: record,
      p_hash_input: hashInput,
      p_hash: hash,
      p_previous_hash: input.previous?.hash ?? null,
      p_generated_at: input.generatedAt,
      p_verification_url: verificationUrl,
      p_brick: format.brick,
      p_specification: format.specification,
      p_filename: written.filename,
      p_media_type: written.mediaType,
      p_content: written.content,
      p_checksum: einvoiceChecksum(written.content),
      p_violations: written.violations,
    },
    SCHEMA,
  );
  if (row === undefined) throw new BooksError('einvoicing_no_answer: einvoicing.append_fiscal_record answered nothing');
  return {
    ...base,
    chained: true,
    record: row,
    note: `Chained as record ${String(row['seq'])} of system ${systemId}${row['is_first'] === true ? ', the first of its chain' : ''}, and its file kept. ${
      mode === 'none'
        ? 'It is kept, and handed over when the authority asks.'
        : 'It is to be sent to the authority: its file is an issue of artefact fiscal_record, sent by a transport the host brings.'
    }`,
  };
}

/** The earliest day a regime binds anybody, or null where the pack names none. */
function earliestObligation(regime: FiscalRegime): string | null {
  const days = regime.mandatory_from.map((entry) => entry.from).sort();
  return days[0] ?? null;
}

/**
 * Where the fiscal records of a company stand: its regime, each chain
 * verified, the records still to be sent, the posted sales without a record,
 * and the latest events. A posted sale without a record is named here and
 * never fiscalised on the way.
 */
export async function fiscalisationStatus(backend: Backend, companyId: string, options: { limit?: number } = {}): Promise<Row> {
  const limit = options.limit ?? 50;
  const regime = await fiscalRegime(backend, companyId);

  const records = await backend.select<Row>({
    schema: SCHEMA,
    table: 'fiscal_chain',
    columns: ['system_id', 'seq', 'document_id', 'kind', 'hash', 'mode', 'issue_id', 'recorded_at'],
    where: [{ column: 'company_id', op: 'eq', value: companyId }],
    order: [{ column: 'system_id' }, { column: 'seq' }],
  });

  const systems: Row[] = [];
  for (const systemId of [...new Set(records.map((r) => String(r['system_id'])))]) {
    const own = records.filter((r) => r['system_id'] === systemId);
    const tail = own[own.length - 1] as Row;
    const breaks = await backend.rpc<Row>('verify_fiscal_chain', { p_company_id: companyId, p_system_id: systemId }, SCHEMA);
    systems.push({
      system_id: systemId,
      records: own.length,
      last_seq: tail['seq'],
      last_hash: tail['hash'],
      last_at: tail['recorded_at'],
      verified: breaks.length === 0,
      break: breaks[0] ?? null,
    });
  }

  // Sent means somebody on the way took charge of it.
  const reached = new Set(
    (
      await backend.select<Row>({
        schema: SCHEMA,
        table: 'transmissions',
        columns: ['issue_id', 'state'],
        where: [
          { column: 'company_id', op: 'eq', value: companyId },
          { column: 'artefact', op: 'eq', value: 'fiscal_record' },
          { column: 'state', op: 'in', value: ['accepted_by_access_point', 'delivered'] },
        ],
      })
    ).map((t) => String(t['issue_id'])),
  );
  const pending = records
    .filter((r) => r['mode'] !== 'none' && !reached.has(String(r['issue_id'])))
    .map((r) => ({ system_id: r['system_id'], seq: r['seq'], document_id: r['document_id'], kind: r['kind'], issue_id: r['issue_id'] }));

  const fiscalised = new Set(records.filter((r) => r['kind'] === 'alta').map((r) => String(r['document_id'])));
  const posted = await backend.select<Row>({
    table: 'documents',
    columns: ['id', 'doc_type', 'number', 'document_date::text'],
    where: [
      { column: 'company_id', op: 'eq', value: companyId },
      { column: 'state', op: 'eq', value: 'posted' },
      { column: 'doc_type', op: 'in', value: ['sale_invoice', 'sale_credit_note'] },
    ],
    order: [{ column: 'document_date' }, { column: 'number' }],
  });
  const from = regime === null ? null : earliestObligation(regime);
  const without = posted.filter((d) => !fiscalised.has(String(d['id'])));
  const missing = regime === null ? [] : without.filter((d) => from === null || String(d['document_date']) >= from);

  const events = await backend.select<Row>({
    schema: SCHEMA,
    table: 'fiscal_events',
    columns: ['system_id', 'seq', 'kind', 'detail', 'at', 'recorded_by'],
    where: [{ column: 'company_id', op: 'eq', value: companyId }],
    order: [{ column: 'at', ascending: false }, { column: 'seq', ascending: false }],
    limit: 10,
  });

  const broken = systems.filter((s) => s['verified'] !== true);
  return {
    company_id: companyId,
    regime:
      regime === null
        ? null
        : {
            format: regime.format,
            brick: FISCALISATION_FORMATS[regime.format]?.brick ?? null,
            mandatory_from: regime.mandatory_from,
            mode: regime.submission.mode,
            modes: regime.submission.modes,
            events: regime.events,
            legal_reference: regime.legal_reference,
          },
    systems,
    verified: broken.length === 0,
    pending: pending.slice(0, limit),
    pending_count: pending.length,
    missing: missing.slice(0, limit),
    missing_count: missing.length,
    before_obligation_count: regime === null ? 0 : without.length - missing.length,
    events,
    note:
      regime === null
        ? 'The country pack of this company declares no fiscalisation regime.'
        : broken.length > 0
          ? `The chain of ${broken.map((s) => String(s['system_id'])).join(', ')} breaks where break says. Nothing more is chained to it; this is for the company's accountant before anything else.`
          : missing.length > 0
            ? `${missing.length} posted sale(s) dated from ${from ?? 'the start of the obligation'} have no fiscal record. Nothing is fiscalised on its own: einvoicing_fiscalise (ekwo einvoice fiscalise) chains one.`
            : 'Every posted sale within the obligation has its record, and every chain is intact.',
  };
}

/** The variable the command line and the MCP server read the invoicing system from, as JSON. */
export const FISCAL_SYSTEM_ENV = 'EKWO_FISCAL_SYSTEM';

/**
 * The invoicing system, from the JSON an operator wrote: every text field
 * present and not blank, the three booleans booleans where given. Nothing is
 * filled in — a producer's tax number guessed is a record the authority
 * attributes to somebody else.
 */
export function parseFiscalSystem(value: unknown, where = FISCAL_SYSTEM_ENV): FiscalSystem {
  let raw = value;
  if (typeof raw === 'string') {
    try {
      raw = JSON.parse(raw) as unknown;
    } catch (error) {
      throw new BooksError(`bad_fiscal_system: ${where} is not JSON: ${error instanceof Error ? error.message : String(error)}`);
    }
  }
  if (raw === null || typeof raw !== 'object' || Array.isArray(raw)) {
    throw new BooksError(`bad_fiscal_system: ${where} describes the invoicing system as an object.`);
  }
  const entry = raw as Record<string, unknown>;
  const missing = (['name', 'id', 'version', 'installation', 'producerName', 'producerTaxId'] as const).filter(
    (key) => typeof entry[key] !== 'string' || (entry[key] as string).trim() === '',
  );
  if (missing.length > 0) {
    throw new BooksError(
      `bad_fiscal_system: ${where} names no ${missing.join(', ')}. The invoicing system is described by its operator — name, id, version, installation, producerName, producerTaxId — and none of it is invented.`,
    );
  }
  const system: FiscalSystem = {
    name: String(entry['name']),
    id: String(entry['id']),
    version: String(entry['version']),
    installation: String(entry['installation']),
    producerName: String(entry['producerName']),
    producerTaxId: String(entry['producerTaxId']),
  };
  for (const key of ['verifactuOnly', 'multipleTaxpayers', 'multipleTaxpayersNow'] as const) {
    const flag = entry[key];
    if (flag === undefined) continue;
    if (typeof flag !== 'boolean') throw new BooksError(`bad_fiscal_system: ${key} in ${where} is true or false.`);
    system[key] = flag;
  }
  return system;
}
