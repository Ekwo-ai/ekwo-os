/**
 * Filing proofs, for every surface: prove a file, complete what is pending,
 * read a proof back by its hash.
 *
 * The network half — calendars, block explorer — is `opentimestamps.ts`; the
 * database half is three functions of the schema (`record_filing_proof`,
 * `upgrade_filing_proof`, `filing_proof`). This file joins them through the
 * same `Backend` every bookkeeping function is written against, so the
 * command line, the MCP server and a scheduled job act as the person or key
 * they are, under row level security.
 */

import { BooksError, type Backend, type Row } from '../books/backend.js';
import {
  bitcoinAnchors,
  bitcoinBlockAt,
  pendingCalendars,
  readOts,
  sha256,
  stampDigest,
  toHex,
  upgradeProof,
  type ProofFetch,
} from './opentimestamps.js';

export type FilingProofSubject = 'tax_filing' | 'fiscal_year' | 'document';

export const FILING_PROOF_SUBJECTS: readonly FilingProofSubject[] = ['tax_filing', 'fiscal_year', 'document'];

/** The columns a proof is read with. The bytes travel as hex text on both routes. */
const PROOF_COLUMNS = [
  'id',
  'company_id',
  'subject_kind',
  'tax_filing_id',
  'fiscal_year_id',
  'document_id',
  'attachment_id',
  'sha256',
  'values_sha256',
  'method',
  'status',
  'calendars',
  'anchor_chain',
  'anchor_height',
  'anchor_time',
  'anchor_reference',
  'created_at',
  'completed_at',
];

export interface NetworkOptions {
  fetch: ProofFetch;
  /** Calendars a hash is submitted to. `DEFAULT_CALENDARS` otherwise. */
  calendars?: readonly string[];
  /** The only calendars an upgrade dials. `DEFAULT_UPGRADE_CALENDARS` otherwise. */
  upgradeCalendars?: readonly string[];
  /** An Esplora block explorer, for the time of the anchoring block. */
  explorer?: string;
}

export interface ProveFileArgs {
  subject_kind: FilingProofSubject;
  subject_id: string;
  /** The exact bytes of the file. Only their sha256 leaves this process. */
  bytes: Uint8Array;
  attachment_id?: string;
  values_sha256?: string;
}

/** What a stored proof carries, without its bytes. */
function proofView(row: Row): Row {
  const { proof: _proof, ...rest } = row;
  return rest;
}

/** `\x0001…` — how both routes render a bytea column. */
function bytesOfHexText(value: unknown): Uint8Array {
  const text = String(value ?? '');
  if (!text.startsWith('\\x')) throw new BooksError(`bad_proof: a proof read back as "${text.slice(0, 20)}…"`);
  return Uint8Array.from(Buffer.from(text.slice(2), 'hex'));
}

/**
 * Hashes a file, submits the hash to the calendars and records the pending
 * proof. A file already proved by this company is not submitted again: the
 * proof it has is returned.
 */
export async function proveFile(backend: Backend, args: ProveFileArgs, network: NetworkOptions): Promise<Row> {
  const digest = sha256(args.bytes);
  const hex = toHex(digest);

  const existing = await backend.select<Row>({
    table: 'filing_proofs',
    columns: PROOF_COLUMNS,
    where: [
      { column: 'sha256', op: 'eq', value: hex },
      { column: 'method', op: 'eq', value: 'opentimestamps' },
    ],
  });
  if (existing.length > 0) {
    return { proof: existing[0], already_proved: true, calendars_failed: [] };
  }

  const stamped = await stampDigest(digest, {
    fetch: network.fetch,
    ...(network.calendars === undefined ? {} : { calendars: network.calendars }),
  });
  const [row] = await backend.rpc<Row>('record_filing_proof', {
    p_subject_kind: args.subject_kind,
    p_subject_id: args.subject_id,
    p_sha256: hex,
    p_method: 'opentimestamps',
    p_proof_base64: Buffer.from(stamped.ots).toString('base64'),
    p_calendars: stamped.calendars,
    ...(args.attachment_id === undefined ? {} : { p_attachment_id: args.attachment_id }),
    ...(args.values_sha256 === undefined ? {} : { p_values_sha256: args.values_sha256 }),
  });
  if (row === undefined) throw new BooksError('record_filing_proof returned no row');
  return { proof: proofView(row), already_proved: false, calendars_failed: stamped.failures };
}

export interface UpgradeReport {
  checked: number;
  /** Anchored in a block during this run. */
  completed: Row[];
  /** Still waiting on a calendar. */
  pending: { id: string; sha256: string; calendars: string[] }[];
}

/**
 * Asks the calendars about every pending proof of a company, records the
 * longer proof, and completes those a Bitcoin block now anchors — with the
 * time of that block, after checking its merkle root against the proof.
 * Meant to run on a schedule: a calendar commits a round to a block in a few
 * hours, and asking again before then costs one request and changes nothing.
 */
export async function upgradeFilingProofs(
  backend: Backend,
  companyId: string,
  network: NetworkOptions,
): Promise<UpgradeReport> {
  const rows = await backend.select<Row>({
    table: 'filing_proofs',
    columns: ['id', 'sha256', 'proof::text'],
    where: [
      { column: 'company_id', op: 'eq', value: companyId },
      { column: 'status', op: 'eq', value: 'pending' },
      { column: 'method', op: 'eq', value: 'opentimestamps' },
    ],
    order: [{ column: 'created_at' }],
  });

  const report: UpgradeReport = { checked: rows.length, completed: [], pending: [] };
  for (const row of rows) {
    const ots = bytesOfHexText(row['proof']);
    const upgraded = await upgradeProof(ots, {
      fetch: network.fetch,
      ...(network.upgradeCalendars === undefined ? {} : { calendars: network.upgradeCalendars }),
    });

    if (upgraded.bitcoin !== undefined) {
      const block = await bitcoinBlockAt(upgraded.bitcoin.height, upgraded.bitcoin.merkleRoot, {
        fetch: network.fetch,
        ...(network.explorer === undefined ? {} : { explorer: network.explorer }),
      });
      const [done] = await backend.rpc<Row>('upgrade_filing_proof', {
        p_proof_id: row['id'],
        p_proof_base64: Buffer.from(upgraded.ots).toString('base64'),
        p_anchor_chain: 'bitcoin',
        p_anchor_height: block.height,
        p_anchor_time: block.time,
        p_anchor_reference: block.hash,
      });
      if (done !== undefined) report.completed.push(proofView(done));
      continue;
    }
    if (upgraded.changed) {
      await backend.rpc<Row>('upgrade_filing_proof', {
        p_proof_id: row['id'],
        p_proof_base64: Buffer.from(upgraded.ots).toString('base64'),
      });
    }
    report.pending.push({ id: String(row['id']), sha256: String(row['sha256']), calendars: upgraded.pending });
  }
  return report;
}

export interface PublishedProof {
  sha256: string;
  method: string;
  status: string;
  anchor_chain: string | null;
  anchor_height: number | string | null;
  anchor_time: string | null;
  anchor_reference: string | null;
  recorded_at: string;
  completed_at: string | null;
  proof_base64: string;
}

/** What the public door of the schema says about a hash: one row per method, or none. */
export async function lookupFilingProof(backend: Backend, sha256Hex: string): Promise<PublishedProof[]> {
  return backend.rpc<PublishedProof>('filing_proof', { p_sha256: sha256Hex });
}

export interface ProofCheck {
  /** The proof is about these bytes. */
  matches_file: boolean;
  /** Bitcoin blocks the proof is anchored in, checked against an explorer when one was asked. */
  bitcoin: { height: number; hash?: string; time?: string }[];
  /** Calendars the proof still waits on. */
  pending: string[];
}

/**
 * Checks a `.ots` file against the bytes it claims to be about, and — given
 * an explorer — each Bitcoin anchor against the block it names. Needs nothing
 * from any Ekwo installation: a proof is verified against the public ledger.
 */
export async function checkProof(
  bytes: Uint8Array,
  ots: Uint8Array,
  network?: { fetch: ProofFetch; explorer?: string },
): Promise<ProofCheck> {
  const proof = readOts(ots);
  const matches = toHex(proof.digest) === toHex(sha256(bytes));
  const anchors = bitcoinAnchors(proof.timestamp);
  const bitcoin: ProofCheck['bitcoin'] = [];
  for (const anchor of anchors) {
    if (network === undefined) {
      bitcoin.push({ height: anchor.height });
      continue;
    }
    const block = await bitcoinBlockAt(anchor.height, anchor.merkleRoot, network);
    bitcoin.push({ height: block.height, hash: block.hash, time: block.time });
  }
  return { matches_file: matches, bitcoin, pending: pendingCalendars(proof.timestamp) };
}
