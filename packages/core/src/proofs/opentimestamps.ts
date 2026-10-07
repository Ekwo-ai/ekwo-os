/**
 * OpenTimestamps: the detached proof file (`.ots`), the public calendars that
 * aggregate hashes into Bitcoin transactions, and the block a proof ends in.
 *
 * Written against the format as the reference implementation serialises it
 * (python-opentimestamps, `core/timestamp.py`, `core/op.py`,
 * `core/notary.py`) rather than through a library: the published JavaScript
 * client carries a Bitcoin library and a dozen transitive dependencies to do
 * what a few hundred lines do here, and none of them is needed to stamp, to
 * upgrade, or to read which block a proof is anchored in.
 *
 * Three acts, and the network is only ever reached through the `fetch` the
 * caller hands in:
 *
 *   stampDigest()      a sha256 goes to the calendars; a pending proof comes back
 *   upgradeProof()     the calendars are asked again; a Bitcoin anchor, eventually
 *   bitcoinBlockAt()   a block explorer gives the time of the anchoring block,
 *                      and its merkle root is checked against the proof
 *
 * Only the 32 bytes of the hash leave, and a random nonce is appended before
 * they do, so a calendar does not even learn the hash of the file.
 */

import { createHash, randomBytes } from 'node:crypto';

// ---------------------------------------------------------------------------
// The format
// ---------------------------------------------------------------------------

/** The 31 bytes every detached proof file starts with. */
export const OTS_MAGIC = Uint8Array.from([
  0x00, 0x4f, 0x70, 0x65, 0x6e, 0x54, 0x69, 0x6d, 0x65, 0x73, 0x74, 0x61, 0x6d, 0x70, 0x73, 0x00, 0x00, 0x50,
  0x72, 0x6f, 0x6f, 0x66, 0x00, 0xbf, 0x89, 0xe2, 0xe8, 0x84, 0xe8, 0x92, 0x94,
]);
const OTS_VERSION = 1;

const OP_SHA1 = 0x02;
const OP_RIPEMD160 = 0x03;
const OP_SHA256 = 0x08;
const OP_KECCAK256 = 0x67;
const OP_APPEND = 0xf0;
const OP_PREPEND = 0xf1;
const OP_REVERSE = 0xf2;
const OP_HEXLIFY = 0xf3;

const TAG_PENDING = Uint8Array.from([0x83, 0xdf, 0xe3, 0x0d, 0x2e, 0xf9, 0x0c, 0x8e]);
const TAG_BITCOIN = Uint8Array.from([0x05, 0x88, 0x96, 0x0d, 0x73, 0xd7, 0x19, 0x01]);

const MAX_MESSAGE = 4096;
const MAX_PAYLOAD = 8192;
const MAX_URI = 1000;
const MAX_DEPTH = 256;

export type Op =
  | { tag: typeof OP_SHA1 | typeof OP_RIPEMD160 | typeof OP_SHA256 | typeof OP_REVERSE | typeof OP_HEXLIFY }
  | { tag: typeof OP_APPEND | typeof OP_PREPEND; arg: Uint8Array };

export type Attestation =
  | { kind: 'pending'; uri: string }
  | { kind: 'bitcoin'; height: number }
  | { kind: 'unknown'; tag: Uint8Array; payload: Uint8Array };

/** A message, what is attested about it, and the operations that lead from it. */
export interface Timestamp {
  msg: Uint8Array;
  attestations: Attestation[];
  ops: { op: Op; stamp: Timestamp }[];
}

/** A whole `.ots` file: the hash of the file, and the timestamp of that hash. */
export interface DetachedTimestamp {
  /** sha256 of the file, the only file hash this module writes or reads. */
  digest: Uint8Array;
  timestamp: Timestamp;
}

/** Something the bytes or the network said that a proof cannot be built on. */
export class OtsError extends Error {
  override name = 'OtsError';
  readonly code: string;

  constructor(code: string, message: string) {
    super(`${code}: ${message}`);
    this.code = code;
  }
}

export const toHex = (bytes: Uint8Array): string => Buffer.from(bytes).toString('hex');

export function fromHex(hex: string): Uint8Array {
  if (!/^(?:[0-9a-fA-F]{2})*$/.test(hex)) throw new OtsError('bad_hex', `"${hex.slice(0, 80)}" is not hexadecimal`);
  return Uint8Array.from(Buffer.from(hex, 'hex'));
}

export function sha256(bytes: Uint8Array): Uint8Array {
  return Uint8Array.from(createHash('sha256').update(bytes).digest());
}

function concat(...parts: Uint8Array[]): Uint8Array {
  const out = new Uint8Array(parts.reduce((n, p) => n + p.length, 0));
  let at = 0;
  for (const part of parts) {
    out.set(part, at);
    at += part.length;
  }
  return out;
}

function equal(a: Uint8Array, b: Uint8Array): boolean {
  return a.length === b.length && a.every((byte, i) => byte === b[i]);
}

function compare(a: Uint8Array, b: Uint8Array): number {
  for (let i = 0; i < Math.min(a.length, b.length); i++) {
    if (a[i] !== b[i]) return (a[i] as number) - (b[i] as number);
  }
  return a.length - b.length;
}

/** What an operation makes of a message. */
export function applyOp(op: Op, msg: Uint8Array): Uint8Array {
  let out: Uint8Array;
  switch (op.tag) {
    case OP_SHA256:
      out = sha256(msg);
      break;
    case OP_SHA1:
      out = Uint8Array.from(createHash('sha1').update(msg).digest());
      break;
    case OP_RIPEMD160:
      out = Uint8Array.from(createHash('ripemd160').update(msg).digest());
      break;
    case OP_APPEND:
      out = concat(msg, op.arg);
      break;
    case OP_PREPEND:
      out = concat(op.arg, msg);
      break;
    case OP_REVERSE:
      out = Uint8Array.from(msg).reverse();
      break;
    case OP_HEXLIFY:
      out = new TextEncoder().encode(toHex(msg));
      break;
  }
  if (out.length > MAX_MESSAGE) throw new OtsError('ots_message_too_long', `an operation produced ${out.length} bytes`);
  return out;
}

class Reader {
  private at = 0;

  constructor(private readonly bytes: Uint8Array) {}

  byte(): number {
    const value = this.bytes[this.at];
    if (value === undefined) throw new OtsError('ots_truncated', 'the proof ends in the middle of an item');
    this.at++;
    return value;
  }

  take(length: number): Uint8Array {
    if (this.at + length > this.bytes.length) throw new OtsError('ots_truncated', 'the proof ends in the middle of an item');
    const out = this.bytes.slice(this.at, this.at + length);
    this.at += length;
    return out;
  }

  varuint(): number {
    let value = 0;
    let shift = 0;
    for (;;) {
      const byte = this.byte();
      value += (byte & 0x7f) * 2 ** shift;
      if ((byte & 0x80) === 0) break;
      shift += 7;
      if (shift > 49) throw new OtsError('ots_bad_integer', 'an integer of the proof does not fit');
    }
    return value;
  }

  varbytes(max: number): Uint8Array {
    const length = this.varuint();
    if (length > max) throw new OtsError('ots_item_too_long', `an item of ${length} bytes, over ${max}`);
    return this.take(length);
  }

  done(): boolean {
    return this.at === this.bytes.length;
  }
}

class Writer {
  private readonly parts: Uint8Array[] = [];

  bytes(value: Uint8Array): void {
    this.parts.push(value);
  }

  byte(value: number): void {
    this.parts.push(Uint8Array.of(value));
  }

  varuint(value: number): void {
    const out: number[] = [];
    let rest = value;
    do {
      let byte = rest % 128;
      rest = Math.floor(rest / 128);
      if (rest > 0) byte |= 0x80;
      out.push(byte);
    } while (rest > 0);
    this.parts.push(Uint8Array.from(out));
  }

  varbytes(value: Uint8Array): void {
    this.varuint(value.length);
    this.bytes(value);
  }

  result(): Uint8Array {
    return concat(...this.parts);
  }
}

function readOp(reader: Reader, tag: number): Op {
  switch (tag) {
    case OP_SHA1:
    case OP_RIPEMD160:
    case OP_SHA256:
    case OP_REVERSE:
    case OP_HEXLIFY:
      return { tag };
    case OP_APPEND:
    case OP_PREPEND:
      return { tag, arg: reader.varbytes(MAX_MESSAGE) };
    case OP_KECCAK256:
      throw new OtsError('ots_unsupported_operation', 'keccak256 is not read by this implementation');
    default:
      throw new OtsError('ots_unknown_operation', `operation 0x${tag.toString(16)} is not part of the format`);
  }
}

function writeOp(writer: Writer, op: Op): void {
  writer.byte(op.tag);
  if (op.tag === OP_APPEND || op.tag === OP_PREPEND) writer.varbytes(op.arg);
}

function opBytes(op: Op): Uint8Array {
  const writer = new Writer();
  writeOp(writer, op);
  return writer.result();
}

function readAttestation(reader: Reader): Attestation {
  const tag = reader.take(8);
  const payload = reader.varbytes(MAX_PAYLOAD);
  const inner = new Reader(payload);
  if (equal(tag, TAG_PENDING)) {
    const uri = new TextDecoder('utf-8', { fatal: true }).decode(inner.varbytes(MAX_URI));
    if (!/^[A-Za-z0-9.:/_-]+$/.test(uri)) throw new OtsError('ots_bad_calendar', `"${uri}" is not a calendar address`);
    return { kind: 'pending', uri };
  }
  if (equal(tag, TAG_BITCOIN)) return { kind: 'bitcoin', height: inner.varuint() };
  return { kind: 'unknown', tag, payload };
}

function attestationBytes(attestation: Attestation): Uint8Array {
  const writer = new Writer();
  const payload = new Writer();
  switch (attestation.kind) {
    case 'pending':
      writer.bytes(TAG_PENDING);
      payload.varbytes(new TextEncoder().encode(attestation.uri));
      break;
    case 'bitcoin':
      writer.bytes(TAG_BITCOIN);
      payload.varuint(attestation.height);
      break;
    case 'unknown':
      writer.bytes(attestation.tag);
      payload.bytes(attestation.payload);
      break;
  }
  writer.varbytes(payload.result());
  return writer.result();
}

/** Reads a timestamp whose starting message is `msg`, as a calendar returns one. */
export function readTimestamp(bytes: Uint8Array, msg: Uint8Array): Timestamp {
  const input = new Reader(bytes);
  const stamp = readTimestampFrom(input, msg, 0);
  if (!input.done()) throw new OtsError('ots_trailing_bytes', 'bytes follow the end of the timestamp');
  return stamp;
}

function readTimestampFrom(input: Reader, msg: Uint8Array, depth: number): Timestamp {
  if (depth > MAX_DEPTH) throw new OtsError('ots_too_deep', 'the proof nests deeper than any calendar writes');
  const stamp: Timestamp = { msg, attestations: [], ops: [] };
  const item = (tag: number): void => {
    if (tag === 0x00) {
      stamp.attestations.push(readAttestation(input));
    } else {
      const op = readOp(input, tag);
      stamp.ops.push({ op, stamp: readTimestampFrom(input, applyOp(op, msg), depth + 1) });
    }
  };
  let tag = input.byte();
  while (tag === 0xff) {
    item(input.byte());
    tag = input.byte();
  }
  item(tag);
  return stamp;
}

/** Writes a timestamp: every item but the last is preceded by 0xff. */
export function writeTimestamp(stamp: Timestamp): Uint8Array {
  const writer = new Writer();
  writeTimestampTo(stamp, writer);
  return writer.result();
}

function writeTimestampTo(stamp: Timestamp, writer: Writer): void {
  const attestations = stamp.attestations.map(attestationBytes).sort(compare);
  const ops = [...stamp.ops].sort((a, b) => compare(opBytes(a.op), opBytes(b.op)));
  if (attestations.length === 0 && ops.length === 0) {
    throw new OtsError('ots_empty_timestamp', 'a timestamp attests nothing and leads nowhere');
  }
  const items = attestations.length + ops.length;
  let written = 0;
  for (const attestation of attestations) {
    if (++written < items) writer.byte(0xff);
    writer.byte(0x00);
    writer.bytes(attestation);
  }
  for (const { op, stamp: next } of ops) {
    if (++written < items) writer.byte(0xff);
    writeOp(writer, op);
    writeTimestampTo(next, writer);
  }
}

/** Reads a whole `.ots` file. */
export function readOts(bytes: Uint8Array): DetachedTimestamp {
  const reader = new Reader(bytes);
  if (!equal(reader.take(OTS_MAGIC.length), OTS_MAGIC)) {
    throw new OtsError('ots_not_a_proof', 'the file does not start like an OpenTimestamps proof');
  }
  const version = reader.varuint();
  if (version !== OTS_VERSION) throw new OtsError('ots_unknown_version', `version ${version} of the format`);
  const hashOp = reader.byte();
  if (hashOp !== OP_SHA256) {
    throw new OtsError('ots_unsupported_file_hash', `the file is hashed with operation 0x${hashOp.toString(16)}, and only sha256 is read`);
  }
  const digest = reader.take(32);
  const timestamp = readTimestampFrom(reader, digest, 0);
  if (!reader.done()) throw new OtsError('ots_trailing_bytes', 'bytes follow the end of the proof');
  return { digest, timestamp };
}

/** Writes a whole `.ots` file. */
export function writeOts(proof: DetachedTimestamp): Uint8Array {
  const writer = new Writer();
  writer.bytes(OTS_MAGIC);
  writer.varuint(OTS_VERSION);
  writer.byte(OP_SHA256);
  writer.bytes(proof.digest);
  writeTimestampTo(proof.timestamp, writer);
  return writer.result();
}

/** Every attestation of a timestamp, with the message it attests and the node it sits on. */
export function attestationsOf(stamp: Timestamp): { msg: Uint8Array; attestation: Attestation; node: Timestamp }[] {
  const out: { msg: Uint8Array; attestation: Attestation; node: Timestamp }[] = [];
  const walk = (node: Timestamp): void => {
    for (const attestation of node.attestations) out.push({ msg: node.msg, attestation, node });
    for (const { stamp } of node.ops) walk(stamp);
  };
  walk(stamp);
  return out;
}

/** Adds what `other` knows about the same message to `target`. */
export function mergeTimestamp(target: Timestamp, other: Timestamp): void {
  if (!equal(target.msg, other.msg)) throw new OtsError('ots_merge_mismatch', 'two timestamps of different messages');
  for (const attestation of other.attestations) {
    const bytes = attestationBytes(attestation);
    if (!target.attestations.some((a) => equal(attestationBytes(a), bytes))) target.attestations.push(attestation);
  }
  for (const { op, stamp } of other.ops) {
    const bytes = opBytes(op);
    const same = target.ops.find((o) => equal(opBytes(o.op), bytes));
    if (same === undefined) target.ops.push({ op, stamp });
    else mergeTimestamp(same.stamp, stamp);
  }
}

/** The Bitcoin anchors of a proof: the block height, and the merkle root the proof arrives at. */
export function bitcoinAnchors(stamp: Timestamp): { height: number; merkleRoot: Uint8Array }[] {
  return attestationsOf(stamp)
    .filter((a) => a.attestation.kind === 'bitcoin')
    .map((a) => ({ height: (a.attestation as { height: number }).height, merkleRoot: a.msg }))
    .sort((a, b) => a.height - b.height);
}

/** The calendars a proof still waits on. */
export function pendingCalendars(stamp: Timestamp): string[] {
  return [
    ...new Set(
      attestationsOf(stamp)
        .filter((a) => a.attestation.kind === 'pending')
        .map((a) => (a.attestation as { uri: string }).uri),
    ),
  ];
}

// ---------------------------------------------------------------------------
// The network
// ---------------------------------------------------------------------------

/** What this module needs of `fetch`, so a test or another runtime can stand in for it. */
export type ProofFetch = (
  url: string,
  init?: { method?: string; headers?: Record<string, string>; body?: Uint8Array },
) => Promise<{ ok: boolean; status: number; arrayBuffer(): Promise<ArrayBuffer>; text(): Promise<string> }>;

/**
 * The public calendars the reference client submits to by default. Four
 * operators, so that a proof does not depend on one of them staying up: a
 * hash is submitted to all of them and the proof keeps every answer.
 */
export const DEFAULT_CALENDARS = [
  'https://a.pool.opentimestamps.org',
  'https://b.pool.opentimestamps.org',
  'https://a.pool.eternitywall.com',
  'https://ots.btc.catallaxy.com',
] as const;

/**
 * The calendars the aggregators above hand a proof over to, which are the
 * ones a pending proof names and an upgrade asks. A proof is bytes somebody
 * handed over, so an upgrade dials only calendars it was told to trust; these
 * four by default, as in the reference client.
 */
export const DEFAULT_UPGRADE_CALENDARS = [
  'https://alice.btc.calendar.opentimestamps.org',
  'https://bob.btc.calendar.opentimestamps.org',
  'https://finney.calendar.eternitywall.com',
  'https://btc.calendar.catallaxy.com',
] as const;

/** An Esplora block explorer API, which several public explorers serve. */
export const DEFAULT_BITCOIN_EXPLORER = 'https://blockstream.info/api';

const HEADERS = { Accept: 'application/vnd.opentimestamps.v1', 'User-Agent': 'ekwo-opentimestamps' };

export interface StampOptions {
  fetch: ProofFetch;
  calendars?: readonly string[];
  /** How many calendars have to answer. Two by default, or all of them if fewer are given. */
  minimum?: number;
  /** For a test: the 16 bytes appended before submission. Random otherwise. */
  nonce?: Uint8Array;
}

export interface Stamped {
  /** The `.ots` file, pending. */
  ots: Uint8Array;
  /** The calendars that answered. */
  calendars: string[];
  /** The calendars that did not, and why. */
  failures: { calendar: string; reason: string }[];
}

function calendarUrl(calendar: string): string {
  if (!/^https?:\/\/[^\s]+$/.test(calendar)) throw new OtsError('ots_bad_calendar', `"${calendar}" is not an http(s) address`);
  return calendar.replace(/\/+$/, '');
}

/** Submits the sha256 of a file to the calendars, and returns the pending proof. */
export async function stampDigest(digest: Uint8Array, options: StampOptions): Promise<Stamped> {
  if (digest.length !== 32) throw new OtsError('bad_sha256', `a sha256 is 32 bytes, got ${digest.length}`);
  const calendars = (options.calendars ?? DEFAULT_CALENDARS).map(calendarUrl);
  if (calendars.length === 0) throw new OtsError('ots_no_calendar', 'no calendar to submit to');
  const minimum = options.minimum ?? Math.min(2, calendars.length);

  const nonce = options.nonce ?? Uint8Array.from(randomBytes(16));
  const append: Op = { tag: OP_APPEND, arg: nonce };
  const appended = applyOp(append, digest);
  const commitment = applyOp({ tag: OP_SHA256 }, appended);
  const root: Timestamp = { msg: commitment, attestations: [], ops: [] };

  const answered: string[] = [];
  const failures: { calendar: string; reason: string }[] = [];
  await Promise.all(
    calendars.map(async (calendar) => {
      try {
        const response = await options.fetch(`${calendar}/digest`, {
          method: 'POST',
          headers: { ...HEADERS, 'Content-Type': 'application/x-www-form-urlencoded' },
          body: commitment,
        });
        if (!response.ok) throw new Error(`answered ${response.status}`);
        const stamp = readTimestamp(new Uint8Array(await response.arrayBuffer()), commitment);
        mergeTimestamp(root, stamp);
        answered.push(calendar);
      } catch (error) {
        failures.push({ calendar, reason: (error as Error).message });
      }
    }),
  );

  if (answered.length < minimum) {
    throw new OtsError(
      'ots_calendars_unreachable',
      `${answered.length} of ${calendars.length} calendars answered, ${minimum} needed: ${failures.map((f) => `${f.calendar} ${f.reason}`).join('; ')}`,
    );
  }

  const timestamp: Timestamp = {
    msg: digest,
    attestations: [],
    ops: [{ op: append, stamp: { msg: appended, attestations: [], ops: [{ op: { tag: OP_SHA256 }, stamp: root }] } }],
  };
  return { ots: writeOts({ digest, timestamp }), calendars: answered.sort(), failures };
}

export interface UpgradeOptions {
  fetch: ProofFetch;
  /**
   * The calendars this client agrees to ask. A proof names the calendar it
   * waits on, and a proof is bytes somebody handed over: a calendar outside
   * this list is not dialled. `DEFAULT_UPGRADE_CALENDARS` when left out.
   */
  calendars?: readonly string[];
}

export interface Upgraded {
  ots: Uint8Array;
  /** Whether the calendars added anything. */
  changed: boolean;
  /** The lowest Bitcoin block the proof is now anchored in, if any. */
  bitcoin: { height: number; merkleRoot: Uint8Array } | undefined;
  /** The calendars still waiting for a block. */
  pending: string[];
}

/** Asks each calendar a proof waits on whether its commitment is in a block yet. */
export async function upgradeProof(ots: Uint8Array, options: UpgradeOptions): Promise<Upgraded> {
  const proof = readOts(ots);
  const allowed = new Set((options.calendars ?? DEFAULT_UPGRADE_CALENDARS).map(calendarUrl));
  let changed = false;

  for (const { msg, attestation, node } of attestationsOf(proof.timestamp)) {
    if (attestation.kind !== 'pending') continue;
    const calendar = calendarUrl(attestation.uri);
    if (!allowed.has(calendar)) continue;
    const response = await options.fetch(`${calendar}/timestamp/${toHex(msg)}`, { headers: HEADERS });
    // Not yet: the calendar has not committed this round to a block.
    if (response.status === 404) continue;
    if (!response.ok) throw new OtsError('ots_calendar_error', `${calendar} answered ${response.status}`);
    const before = toHex(writeTimestamp(node));
    mergeTimestamp(node, readTimestamp(new Uint8Array(await response.arrayBuffer()), msg));
    if (toHex(writeTimestamp(node)) !== before) changed = true;
  }

  const anchors = bitcoinAnchors(proof.timestamp);
  return {
    ots: changed ? writeOts(proof) : ots,
    changed,
    bitcoin: anchors[0],
    pending: pendingCalendars(proof.timestamp),
  };
}

export interface BitcoinBlock {
  height: number;
  hash: string;
  /** The time in the block header, ISO 8601. */
  time: string;
}

/**
 * The block at a height, read from an Esplora explorer, with its merkle root
 * checked against the one the proof arrives at. A proof whose path does not
 * end in the merkle root of that block is not a proof of anything, and is
 * refused rather than dated.
 */
export async function bitcoinBlockAt(
  height: number,
  merkleRoot: Uint8Array,
  options: { fetch: ProofFetch; explorer?: string },
): Promise<BitcoinBlock> {
  const explorer = (options.explorer ?? DEFAULT_BITCOIN_EXPLORER).replace(/\/+$/, '');
  const hashResponse = await options.fetch(`${explorer}/block-height/${height}`);
  if (!hashResponse.ok) throw new OtsError('ots_block_unknown', `${explorer} knows no block at height ${height}`);
  const hash = (await hashResponse.text()).trim();
  if (!/^[0-9a-f]{64}$/.test(hash)) throw new OtsError('ots_block_unknown', `${explorer} answered "${hash.slice(0, 80)}" for height ${height}`);
  const blockResponse = await options.fetch(`${explorer}/block/${hash}`);
  if (!blockResponse.ok) throw new OtsError('ots_block_unknown', `${explorer} answered ${blockResponse.status} for block ${hash}`);
  const block = JSON.parse(await blockResponse.text()) as { timestamp?: number; merkle_root?: string };
  // Explorers print the merkle root in reverse byte order; the proof arrives
  // at it in the order the header stores it.
  const expected = toHex(Uint8Array.from(merkleRoot).reverse());
  if (block.merkle_root !== expected) {
    throw new OtsError(
      'ots_anchor_mismatch',
      `the proof arrives at merkle root ${expected}, and block ${height} has ${String(block.merkle_root)}`,
    );
  }
  if (typeof block.timestamp !== 'number') throw new OtsError('ots_block_unknown', `block ${hash} has no time`);
  return { height, hash, time: new Date(block.timestamp * 1000).toISOString() };
}
