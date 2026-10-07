/**
 * OpenTimestamps, as `@ekwo-ai/core` writes and reads it, and a filing proof
 * from the file to the block.
 *
 * Nothing here reaches the network. The calendars and the block explorer are
 * a fake `fetch` that answers what the published protocol answers: a calendar
 * returns a timestamp starting from the commitment it was sent, later the
 * path to a Bitcoin attestation; an Esplora explorer returns a block hash for
 * a height and a block with its merkle root in display order. The bytes a
 * stamp produces are compared with bytes assembled here by hand from the
 * format, so the writer and the test are two readings of the same layout.
 */

import { createHash } from 'node:crypto';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import {
  OTS_MAGIC,
  bitcoinAnchors,
  bitcoinBlockAt,
  checkProof,
  lookupFilingProof,
  pendingCalendars,
  proveFile,
  readOts,
  stampDigest,
  upgradeFilingProofs,
  upgradeProof,
  writeOts,
  type ProofFetch,
} from '../packages/core/src/index.js';
import { freshDatabase, one } from './helpers/db.js';
import { newCompany, type Fixture } from './helpers/factory.js';
import { backendFor } from './mcp/helpers.js';

const POOL = 'https://pool.calendar.test';
const CALENDAR = 'https://alice.calendar.test';
const EXPLORER = 'https://explorer.test/api';
const HEIGHT = 912_345;
const BLOCK_TIME = 1_791_400_000; // seconds
const BLOCK_HASH = '00000000000000000001'.padEnd(64, 'a');

const TAG_PENDING = [0x83, 0xdf, 0xe3, 0x0d, 0x2e, 0xf9, 0x0c, 0x8e];
const TAG_BITCOIN = [0x05, 0x88, 0x96, 0x0d, 0x73, 0xd7, 0x19, 0x01];
const PREFIX = Uint8Array.from([1, 2, 3, 4, 5, 6, 7, 8]);

const hash = (bytes: Uint8Array): Uint8Array => Uint8Array.from(createHash('sha256').update(bytes).digest());
const hex = (bytes: Uint8Array): string => Buffer.from(bytes).toString('hex');
const bytes = (...parts: (number[] | Uint8Array)[]): Uint8Array => Uint8Array.from(parts.flatMap((p) => [...p]));

/** A pending attestation as a calendar writes one: 0x00, the tag, the payload. */
const pending = (uri: string): Uint8Array => {
  const encoded = new TextEncoder().encode(uri);
  return bytes([0x00], TAG_PENDING, [encoded.length + 1, encoded.length], encoded);
};

/** What the calendar returns later: prepend 8 bytes, sha256, a Bitcoin attestation at HEIGHT. */
const complete = (): Uint8Array => {
  const height: number[] = [];
  let rest = HEIGHT;
  do {
    let b = rest % 128;
    rest = Math.floor(rest / 128);
    if (rest > 0) b |= 0x80;
    height.push(b);
  } while (rest > 0);
  return bytes([0xf1, PREFIX.length], PREFIX, [0x08, 0x00], TAG_BITCOIN, [height.length], height);
};

interface Fake {
  fetch: ProofFetch;
  calls: string[];
  anchored: boolean;
  merkleRoot: (commitment: Uint8Array) => string;
}

/** Calendars and explorer, answering the way the protocol does. */
function fakeNetwork(options: { anchored?: boolean; failing?: string[] } = {}): Fake {
  const committed = new Set<string>();
  const fake: Fake = {
    calls: [],
    anchored: options.anchored ?? false,
    merkleRoot: (commitment) => hex(Uint8Array.from(hash(bytes(PREFIX, commitment))).reverse()),
    fetch: async (url, init) => {
      fake.calls.push(`${init?.method ?? 'GET'} ${url}`);
      const reply = (status: number, body: Uint8Array | string = '') => ({
        ok: status >= 200 && status < 300,
        status,
        arrayBuffer: async () => {
          const b = typeof body === 'string' ? new TextEncoder().encode(body) : body;
          return b.buffer.slice(b.byteOffset, b.byteOffset + b.byteLength) as ArrayBuffer;
        },
        text: async () => (typeof body === 'string' ? body : new TextDecoder().decode(body)),
      });
      if (options.failing?.some((f) => url.startsWith(f))) return reply(503);
      if (url.endsWith('/digest') && init?.method === 'POST') {
        committed.add(hex(init.body as Uint8Array));
        return reply(200, pending(CALENDAR));
      }
      const asked = url.match(/\/timestamp\/([0-9a-f]+)$/);
      if (asked !== null) {
        if (!fake.anchored || !committed.has(asked[1] as string)) return reply(404);
        return reply(200, complete());
      }
      if (url === `${EXPLORER}/block-height/${HEIGHT}`) return reply(200, BLOCK_HASH);
      if (url === `${EXPLORER}/block/${BLOCK_HASH}`) {
        const [commitment] = [...committed];
        return reply(
          200,
          JSON.stringify({ timestamp: BLOCK_TIME, merkle_root: fake.merkleRoot(Buffer.from(commitment ?? '', 'hex')) }),
        );
      }
      return reply(404);
    },
  };
  return fake;
}

describe('the detached proof file', () => {
  const file = new TextEncoder().encode('annual accounts, as deposited');
  const digest = hash(file);
  const nonce = Uint8Array.from({ length: 16 }, (_, i) => i);

  it('is written byte for byte as the format lays it out', async () => {
    const network = fakeNetwork();
    const stamped = await stampDigest(digest, { fetch: network.fetch, calendars: [POOL], nonce });
    const expected = bytes(
      OTS_MAGIC,
      [0x01], // version
      [0x08], // the file is hashed with sha256
      digest,
      [0xf0, 16], // append the nonce
      nonce,
      [0x08], // sha256: the commitment a calendar sees
      pending(CALENDAR),
    );
    expect(hex(stamped.ots)).toBe(hex(expected));
    expect(network.calls).toEqual([`POST ${POOL}/digest`]);
    // The calendar was sent the commitment, never the hash of the file.
    expect(stamped.calendars).toEqual([POOL]);
  });

  it('reads back what it wrote, and writes it again identically', async () => {
    const stamped = await stampDigest(digest, { fetch: fakeNetwork().fetch, calendars: [POOL], nonce });
    const read = readOts(stamped.ots);
    expect(hex(read.digest)).toBe(hex(digest));
    expect(pendingCalendars(read.timestamp)).toEqual([CALENDAR]);
    expect(hex(writeOts(read))).toBe(hex(stamped.ots));
  });

  it('refuses what is not a proof, a proof cut short, and bytes after the end', async () => {
    const stamped = await stampDigest(digest, { fetch: fakeNetwork().fetch, calendars: [POOL], nonce });
    expect(() => readOts(new TextEncoder().encode('not a proof at all, longer than the magic'))).toThrow(/^ots_not_a_proof: /);
    expect(() => readOts(stamped.ots.slice(0, stamped.ots.length - 3))).toThrow(/^ots_truncated: /);
    expect(() => readOts(bytes(stamped.ots, [0x00]))).toThrow(/^ots_trailing_bytes: /);
  });

  it('refuses a stamp too few calendars answered', async () => {
    const network = fakeNetwork({ failing: ['https://down'] });
    await expect(
      stampDigest(digest, { fetch: network.fetch, calendars: [POOL, 'https://down.one', 'https://down.two'], minimum: 2 }),
    ).rejects.toThrow(/^ots_calendars_unreachable: 1 of 3/);
  });
});

describe('upgrading a proof to a block', () => {
  const digest = hash(new TextEncoder().encode('a declaration'));

  it('stays pending while the calendar has no block, and changes nothing', async () => {
    const network = fakeNetwork();
    const stamped = await stampDigest(digest, { fetch: network.fetch, calendars: [POOL] });
    const upgraded = await upgradeProof(stamped.ots, { fetch: network.fetch, calendars: [CALENDAR] });
    expect(upgraded).toMatchObject({ changed: false, bitcoin: undefined, pending: [CALENDAR] });
    expect(hex(upgraded.ots)).toBe(hex(stamped.ots));
  });

  it('dials no calendar it was not told to trust', async () => {
    const network = fakeNetwork({ anchored: true });
    const stamped = await stampDigest(digest, { fetch: network.fetch, calendars: [POOL] });
    network.calls.length = 0;
    const upgraded = await upgradeProof(stamped.ots, { fetch: network.fetch, calendars: ['https://another.calendar'] });
    expect(network.calls).toEqual([]);
    expect(upgraded.changed).toBe(false);
  });

  it('arrives at the merkle root of the block, which the explorer confirms', async () => {
    const network = fakeNetwork({ anchored: true });
    const stamped = await stampDigest(digest, { fetch: network.fetch, calendars: [POOL] });
    const upgraded = await upgradeProof(stamped.ots, { fetch: network.fetch, calendars: [CALENDAR] });
    expect(upgraded.changed).toBe(true);
    expect(upgraded.bitcoin?.height).toBe(HEIGHT);
    expect(bitcoinAnchors(readOts(upgraded.ots).timestamp)).toHaveLength(1);

    const block = await bitcoinBlockAt(HEIGHT, upgraded.bitcoin?.merkleRoot as Uint8Array, {
      fetch: network.fetch,
      explorer: EXPLORER,
    });
    expect(block).toEqual({ height: HEIGHT, hash: BLOCK_HASH, time: new Date(BLOCK_TIME * 1000).toISOString() });
  });

  it('refuses to date a proof whose path does not end in that block', async () => {
    const network = fakeNetwork({ anchored: true });
    network.merkleRoot = () => 'ff'.repeat(32);
    const stamped = await stampDigest(digest, { fetch: network.fetch, calendars: [POOL] });
    const upgraded = await upgradeProof(stamped.ots, { fetch: network.fetch, calendars: [CALENDAR] });
    await expect(
      bitcoinBlockAt(HEIGHT, upgraded.bitcoin?.merkleRoot as Uint8Array, { fetch: network.fetch, explorer: EXPLORER }),
    ).rejects.toThrow(/^ots_anchor_mismatch: /);
  });
});

describe('a filing proof, from the file to the block', () => {
  let db: PGlite;
  let fx: Fixture;
  let fiscalYearId: string;
  const file = new TextEncoder().encode('<accounts>the statements as deposited</accounts>');

  beforeAll(async () => {
    db = await freshDatabase();
    fx = await newCompany(db);
    fiscalYearId = (await one<{ id: string }>(db, `select id from fiscal_years where company_id = $1`, [fx.companyId])).id;
  }, 300_000);

  afterAll(async () => {
    await db?.close();
  });

  it('is recorded pending, completed on a schedule, and read back by anybody holding the file', async () => {
    const network = fakeNetwork();
    const backend = backendFor(db, fx.ownerId);
    const options = { fetch: network.fetch, calendars: [POOL], upgradeCalendars: [CALENDAR], explorer: EXPLORER };

    const proved = await proveFile(backend, { subject_kind: 'fiscal_year', subject_id: fiscalYearId, bytes: file }, options);
    expect(proved).toMatchObject({ already_proved: false, proof: { status: 'pending', sha256: hex(hash(file)) } });

    // A second call does not submit the same bytes again.
    network.calls.length = 0;
    const again = await proveFile(backend, { subject_kind: 'fiscal_year', subject_id: fiscalYearId, bytes: file }, options);
    expect(again['already_proved']).toBe(true);
    expect(network.calls).toEqual([]);

    // The calendar has no block yet: the scheduled run leaves it pending.
    const early = await upgradeFilingProofs(backend, fx.companyId, options);
    expect(early).toMatchObject({ checked: 1, completed: [], pending: [{ calendars: [CALENDAR] }] });

    // Hours later, it has.
    network.anchored = true;
    const later = await upgradeFilingProofs(backend, fx.companyId, options);
    expect(later.completed).toHaveLength(1);
    expect(later.completed[0]).toMatchObject({ status: 'complete', anchor_chain: 'bitcoin', anchor_reference: BLOCK_HASH });
    expect(String(later.completed[0]?.['anchor_height'])).toBe(String(HEIGHT));
    expect(await upgradeFilingProofs(backend, fx.companyId, options)).toMatchObject({ checked: 0 });

    // Anybody: the public door, then the proof checked with nothing but the
    // file and the explorer.
    const [published] = await lookupFilingProof(backend, hex(hash(file)));
    expect(published).toMatchObject({ method: 'opentimestamps', status: 'complete' });
    expect(new Date(String(published?.anchor_time)).toISOString()).toBe(new Date(BLOCK_TIME * 1000).toISOString());
    const ots = Uint8Array.from(Buffer.from(String(published?.proof_base64), 'base64'));
    const check = await checkProof(file, ots, { fetch: network.fetch, explorer: EXPLORER });
    expect(check).toMatchObject({ matches_file: true, bitcoin: [{ height: HEIGHT, hash: BLOCK_HASH }] });

    // Another file is not what this proof is about.
    expect((await checkProof(new TextEncoder().encode('something else'), ots)).matches_file).toBe(false);
  });
});
