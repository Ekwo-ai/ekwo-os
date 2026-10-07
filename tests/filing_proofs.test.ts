/**
 * A filing, proved by its hash.
 *
 * Two halves, tested as two different things. A member of the company records
 * a proof and later completes it, and row level security decides which
 * member: `filings.prove` sits on the two presets that carry the outward acts.
 * Then somebody who is not signed in at all presents a hash, and what comes
 * back is the proof and *only* the proof — no company, no subject, no row id.
 *
 * The proof bytes here are opaque: what an OpenTimestamps file contains is
 * the business of `tests/opentimestamps.test.ts`, and the database keeps the
 * bytes it is handed.
 */

import { createHash } from 'node:crypto';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newUser, type Fixture } from './helpers/factory.js';

let db: PGlite;
let fx: Fixture;
let other: Fixture;
let accountantId: string;
let viewerId: string;
let strangerId: string;
let filingId: string;
let fiscalYearId: string;

interface Proof {
  id: string;
  company_id: string;
  subject_kind: string;
  tax_filing_id: string | null;
  fiscal_year_id: string | null;
  sha256: string;
  values_sha256: string | null;
  method: string;
  status: string;
  anchor_chain: string | null;
  anchor_height: string | null;
  completed_at: string | null;
}

type PublicProof = Record<string, unknown>;

const sha256 = (text: string): string => createHash('sha256').update(text).digest('hex');
const base64 = (text: string): string => Buffer.from(text).toString('base64');

async function record(
  userId: string,
  kind: string,
  subject: string,
  hash: string,
  proof = 'pending proof bytes',
): Promise<Proof> {
  return asUser(db, userId, () =>
    one<Proof>(
      db,
      `select * from record_filing_proof($1::filing_proof_subject, $2, $3, 'opentimestamps', $4,
                                         '["https://calendar.example"]'::jsonb)`,
      [kind, subject, hash, base64(proof)],
    ),
  );
}

async function readAsVisitor(hash: string): Promise<PublicProof[]> {
  return asUser(db, strangerId, () => rows<PublicProof>(db, `select * from filing_proof($1)`, [hash]), 'anon');
}

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db);
  other = await newCompany(db, { name: 'Another Company' });
  accountantId = await newUser(db, 'accountant@proofs.test');
  viewerId = await newUser(db, 'viewer@proofs.test');
  strangerId = await newUser(db, 'stranger@proofs.test');
  await db.query(
    `insert into company_members (company_id, user_id, role)
     values ($1, $2, 'accountant'), ($1, $3, 'viewer')`,
    [fx.companyId, accountantId, viewerId],
  );
  // A nil return is a return: its figures are computed, and there are none.
  filingId = (
    await one<{ id: string }>(db, `select id from prepare_filing($1, '2026-01-01'::date, '2026-03-31'::date)`, [
      fx.companyId,
    ])
  ).id;
  fiscalYearId = (
    await one<{ id: string }>(db, `select id from fiscal_years where company_id = $1`, [fx.companyId])
  ).id;
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('recording a proof', () => {
  it('is something an owner and an accountant do, on the company of the subject', async () => {
    const proof = await record(fx.ownerId, 'tax_filing', filingId, sha256('declaration v1'));
    expect(proof).toMatchObject({
      company_id: fx.companyId,
      subject_kind: 'tax_filing',
      tax_filing_id: filingId,
      method: 'opentimestamps',
      status: 'pending',
      completed_at: null,
    });
    const annual = await record(accountantId, 'fiscal_year', fiscalYearId, sha256('annual accounts'));
    expect(annual.fiscal_year_id).toBe(fiscalYearId);
  });

  it('is refused to a viewer and to a stranger, by name', async () => {
    const viewer = await asUser(db, viewerId, () =>
      expectError(
        db,
        `select record_filing_proof('tax_filing', $1, $2, 'opentimestamps', $3)`,
        [filingId, sha256('viewer'), base64('x')],
      ),
    );
    expect(viewer).toMatch(/^not_allowed: .*filings\.prove/);
    const stranger = await asUser(db, strangerId, () =>
      expectError(
        db,
        `select record_filing_proof('tax_filing', $1, $2, 'opentimestamps', $3)`,
        [filingId, sha256('stranger'), base64('x')],
      ),
    );
    expect(stranger).toMatch(/^not_allowed: /);
  });

  it('derives the canonical hash of a declaration from its boxes, never from the caller', async () => {
    const [proof] = await rows<Proof>(db, `select * from filing_proofs where tax_filing_id = $1`, [filingId]);
    const derived = await one<{ h: string }>(db, `select tax_filing_values_sha256($1) as h`, [filingId]);
    expect(derived.h).toMatch(/^[0-9a-f]{64}$/);
    expect(proof?.values_sha256).toBe(derived.h);

    // What a reader recomputes with nothing but the figures: one canonical
    // JSON line for the declaration, then one per box.
    const filing = await one<{ report_code: string; period_start: string; period_end: string }>(
      db,
      `select report_code, period_start::text, period_end::text from tax_filings where id = $1`,
      [filingId],
    );
    const boxes = await rows<{ line: string }>(
      db,
      `select canonical_json(jsonb_build_object('box', box, 'kind', kind, 'amount', amount))::text as line
         from tax_filing_boxes where filing_id = $1 order by box, kind`,
      [filingId],
    );
    const header = await one<{ line: string }>(
      db,
      `select canonical_json(jsonb_build_object('report_code', $1::text, 'period_start', $2::date, 'period_end', $3::date))::text as line`,
      [filing.report_code, filing.period_start, filing.period_end],
    );
    const text = [header.line, ...boxes.map((b) => b.line)].map((l) => `${l}\n`).join('');
    expect(derived.h).toBe(sha256(text));
  });

  it('returns the same proof when the same bytes are recorded again', async () => {
    const hash = sha256('declaration v1');
    const again = await record(fx.ownerId, 'tax_filing', filingId, hash);
    const count = await one<{ n: number }>(db, `select count(*)::int as n from filing_proofs where sha256 = $1`, [hash]);
    expect(count.n).toBe(1);
    expect(again.sha256).toBe(hash);
  });

  it('refuses the same bytes for another subject, a malformed hash and an empty proof', async () => {
    const elsewhere = await asUser(db, fx.ownerId, () =>
      expectError(
        db,
        `select record_filing_proof('fiscal_year', $1, $2, 'opentimestamps', $3)`,
        [fiscalYearId, sha256('declaration v1'), base64('x')],
      ),
    );
    expect(elsewhere).toMatch(/^proof_already_recorded: /);
    const malformed = await asUser(db, fx.ownerId, () =>
      expectError(db, `select record_filing_proof('tax_filing', $1, 'abc', 'opentimestamps', $2)`, [
        filingId,
        base64('x'),
      ]),
    );
    expect(malformed).toMatch(/^bad_sha256: /);
    const empty = await asUser(db, fx.ownerId, () =>
      expectError(db, `select record_filing_proof('tax_filing', $1, $2, 'opentimestamps', '')`, [
        filingId,
        sha256('empty'),
      ]),
    );
    expect(empty).toMatch(/^bad_proof: /);
  });

  it('is not written to directly by anybody signed in', async () => {
    const message = await asUser(db, fx.ownerId, () =>
      expectError(
        db,
        `insert into filing_proofs (company_id, subject_kind, tax_filing_id, sha256, method, proof)
         values ($1, 'tax_filing', $2, $3, 'opentimestamps', '\\x00')`,
        [fx.companyId, filingId, sha256('direct')],
      ),
    );
    expect(message).toMatch(/permission denied/);
  });

  it('is read by the members who read the declarations, and by nobody of another company', async () => {
    const seenByViewer = await asUser(db, viewerId, () =>
      rows<Proof>(db, `select * from filing_proofs where company_id = $1`, [fx.companyId]),
    );
    expect(seenByViewer.length).toBe(2);
    const seenByOther = await asUser(db, other.ownerId, () => rows<Proof>(db, `select * from filing_proofs`));
    expect(seenByOther).toEqual([]);
  });
});

describe('upgrading a proof', () => {
  it('keeps a proof pending until an anchor is given, then freezes it', async () => {
    const hash = sha256('annual accounts');
    const proof = await one<Proof>(db, `select * from filing_proofs where sha256 = $1`, [hash]);

    const still = await asUser(db, accountantId, () =>
      one<Proof>(db, `select * from upgrade_filing_proof($1, $2)`, [proof.id, base64('longer pending proof')]),
    );
    expect(still.status).toBe('pending');

    const done = await asUser(db, accountantId, () =>
      one<Proof>(db, `select * from upgrade_filing_proof($1, $2, 'bitcoin', 900000, '2026-10-07T20:00:00Z')`, [
        proof.id,
        base64('complete proof'),
      ]),
    );
    expect(done).toMatchObject({ status: 'complete', anchor_chain: 'bitcoin' });
    expect(String(done.anchor_height)).toBe('900000');
    expect(done.completed_at).not.toBeNull();

    const frozen = await asUser(db, accountantId, () =>
      expectError(db, `select upgrade_filing_proof($1, $2)`, [proof.id, base64('another')]),
    );
    expect(frozen).toMatch(/^proof_complete: /);
  });

  it('refuses an anchor that names no block and no reference', async () => {
    const proof = await one<Proof>(db, `select * from filing_proofs where sha256 = $1`, [sha256('declaration v1')]);
    const message = await asUser(db, fx.ownerId, () =>
      expectError(db, `select upgrade_filing_proof($1, $2, 'bitcoin')`, [proof.id, base64('x')]),
    );
    expect(message).toMatch(/^anchor_incomplete: /);
  });

  it('is refused to a member without filings.prove', async () => {
    const proof = await one<Proof>(db, `select * from filing_proofs where sha256 = $1`, [sha256('declaration v1')]);
    const message = await asUser(db, viewerId, () =>
      expectError(db, `select upgrade_filing_proof($1, $2)`, [proof.id, base64('x')]),
    );
    expect(message).toMatch(/^not_allowed: /);
  });
});

describe('the public door', () => {
  it('answers a hash with its proof and nothing about who proved it', async () => {
    const answer = await readAsVisitor(sha256('annual accounts'));
    expect(answer).toHaveLength(1);
    const [proof] = answer;
    expect(Object.keys(proof ?? {}).sort()).toEqual([
      'anchor_chain',
      'anchor_height',
      'anchor_reference',
      'anchor_time',
      'completed_at',
      'method',
      'proof_base64',
      'recorded_at',
      'sha256',
      'status',
    ]);
    expect(proof).toMatchObject({
      sha256: sha256('annual accounts'),
      method: 'opentimestamps',
      status: 'complete',
      anchor_chain: 'bitcoin',
    });
    expect(String(proof?.['anchor_height'])).toBe('900000');
    expect(Buffer.from(String(proof?.['proof_base64']), 'base64').toString()).toBe('complete proof');
    // Nothing that identifies the company or the subject, anywhere in it.
    const text = JSON.stringify(answer);
    for (const id of [fx.companyId, fiscalYearId, filingId]) expect(text).not.toContain(id);
  });

  it('answers the hash in upper case as well, since a hash is a number', async () => {
    expect(await readAsVisitor(sha256('annual accounts').toUpperCase())).toHaveLength(1);
  });

  it('gives the same empty answer to a malformed hash and to a hash nobody proved', async () => {
    expect(await readAsVisitor('not a hash')).toEqual([]);
    expect(await readAsVisitor(sha256('never proved'))).toEqual([]);
    expect(await readAsVisitor('')).toEqual([]);
  });

  it('is the only thing the anonymous role reaches', async () => {
    const message = await asUser(
      db,
      strangerId,
      () => expectError(db, `select * from filing_proofs`),
      'anon',
    );
    expect(message).toMatch(/permission denied/);
  });
});
