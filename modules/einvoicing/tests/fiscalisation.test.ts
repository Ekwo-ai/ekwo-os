import { createHash } from 'node:crypto';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import {
  BooksError,
  EINVOICE_FORMATS,
  FISCALISATION_FORMATS,
  einvoiceChecksum,
  fiscalisationStatus,
  fiscaliseDocument,
  hashedFields,
  issueEinvoice,
  parseFiscalSystem,
  readVerification,
  type FiscalRecordInput,
  type FiscalSystem,
  type FiscalisationFormat,
} from '@ekwo-ai/core';
import { asUser, expectError, freshDatabase, one, rows, withoutTrigger } from '../../../tests/helpers/db.js';
import { allPacks, packWhere } from '../../../tests/helpers/packs.js';
import { backendFor } from '../../../tests/mcp/helpers.js';
import { sale, seller, standardTaxOf, type Seller } from './helpers.js';

// Fiscalisation, the chained record of every invoice: a capability of the
// `einvoicing` module.
//
// Nothing here names a country. The pack that declares a regime is found by
// what it declares, and its brick is the one the core's registry names for
// its format. The chain itself is exercised with a fake format, in a company
// whose country has no regime and is given one of invented values for the
// length of this file — so what is asserted is the module and the core: a
// record is chained after the tail, the database checks the digest and the
// fields, nothing moves once chained, and the status names what is missing.

const FAKE = 'fake-chain';
const FIELDS = ['number', 'date', 'total', 'previous'];

/** A format of invented rules: `name=value` pairs joined by `;`, hashed by SHA-256 in lower-case hexadecimal. */
const fake: FiscalisationFormat = {
  format: FAKE,
  brick: '@ekwo-ai/fake-chain',
  specification: 'An invented record 1.0',
  hashInput(input: FiscalRecordInput) {
    return [
      `number=${String(input.header['number'])}`,
      `date=${String(input.header['document_date'])}`,
      `total=${input.kind === 'anulacion' ? '0' : String(input.header['amount_total'])}`,
      `previous=${input.previous?.hash ?? ''}`,
    ].join(';');
  },
  hash(input) {
    return createHash('sha256').update(this.hashInput(input), 'utf8').digest('hex');
  },
  write(input) {
    return {
      content: `<record kind="${input.kind}" at="${input.generatedAt}">${this.hashInput(input)}</record>`,
      filename: `record-${String(input.header['number'])}-${input.kind}.xml`,
      mediaType: 'application/xml',
      violations: input.header['note'] === 'break a rule' ? [{ code: 'FAKE-1', message: 'An invented rule.' }] : [],
    };
  },
  verificationUrl(input, mode) {
    return `https://verify.invalid/${mode}?n=${encodeURIComponent(String(input.header['number']))}`;
  },
};
const FORMATS = { [FAKE]: fake };

/** The invented regime the fake company's country is given for the length of this file. */
const REGIME = {
  mandatory_from: [{ who: null, from: '2026-01-01' }],
  format: FAKE,
  hash: { algorithm: 'SHA-256', code: null, encoding: 'hex-lower', separator: ';', fields: { '*': FIELDS }, legal_reference: null, source: null },
  qr: null,
  mention: [],
  submission: { mode: 'batch', modes: ['batch', 'none'], batch_max: null, interval_seconds: null, retry_seconds: null, legal_reference: null, source: null },
  events: { summary_every_hours: 6, modes: ['none'], legal_reference: null, source: null },
  tax_attributes: {},
  legal_reference: 'An invented article',
  source: 'invented',
};

const SYSTEM: FiscalSystem = {
  name: 'Invented system',
  id: 'ZZ',
  version: '1.0',
  installation: 'test-1',
  producerName: 'Invented producer',
  producerTaxId: 'ZZ999999999',
  verifactuOnly: true,
  multipleTaxpayers: true,
  multipleTaxpayersNow: true,
};
const OTHER: FiscalSystem = { ...SYSTEM, installation: 'test-2' };
const AT = '2026-06-20T10:15:00+02:00';

let db: PGlite;
let chained: Seller;
let declaring: Seller;
let originalRegime: unknown;

beforeAll(async () => {
  db = await freshDatabase();
  const withRegime = packWhere(
    'declares a chained fiscalisation regime and charges a standard rate',
    (pack) => pack.documents.einvoice_fiscalisation?.hash != null && standardTaxOf(pack) !== undefined,
  );
  declaring = await seller(db, withRegime, 'Chained Seller');
  // A country whose pack declares a profile a brick writes and no regime.
  const plain = packWhere(
    'issues in peppol-bis-3, declares no fiscalisation regime and charges a standard rate',
    (pack) =>
      pack.documents.einvoice_profile === 'peppol-bis-3' &&
      pack.documents.einvoice_fiscalisation === null &&
      standardTaxOf(pack) !== undefined,
  );
  chained = await seller(db, plain, 'Fake Chain Seller');
  originalRegime = (await one<{ r: unknown }>(db, `select einvoice_fiscalisation as r from country_defaults where country = $1`, [plain.manifest.country])).r;
  await db.query(`update country_defaults set einvoice_fiscalisation = $2 where country = $1`, [plain.manifest.country, REGIME]);
}, 300_000);

afterAll(async () => {
  await db.close();
});

const chainOf = (companyId: string, systemId: string) =>
  rows<{ seq: number; kind: string; hash: string; previous_hash: string | null; is_first: boolean; record: Record<string, string>; issue_id: string; document_id: string }>(
    db,
    `select seq, kind::text, hash, previous_hash, is_first, record, issue_id, document_id
       from einvoicing.fiscal_chain where company_id = $1 and system_id = $2 order by seq`,
    [companyId, systemId],
  );

const systemId = (system: FiscalSystem) => `${system.id}:${system.installation}`;

// ------------------------------------------------------------------- the chain

describe('fiscaliseDocument, with a format of invented rules', () => {
  it('chains the first record as the first, and the next after it, keeping each file', async () => {
    const first = await sale(db, chained);
    const second = await sale(db, chained);
    const a = await fiscaliseDocument(chained.backend, first, { system: SYSTEM, generatedAt: AT }, FORMATS);
    const b = await fiscaliseDocument(chained.backend, second, { system: SYSTEM, generatedAt: AT }, FORMATS);
    expect(a['chained']).toBe(true);
    expect(b['chained']).toBe(true);

    const chain = await chainOf(chained.companyId, systemId(SYSTEM));
    expect(chain.map((r) => [r.seq, r.is_first])).toEqual([[1, true], [2, false]]);
    expect(chain[0]!.previous_hash).toBeNull();
    expect(chain[1]!.previous_hash).toBe(chain[0]!.hash);
    // The hashed fields, read back out of the text the brick hashed.
    // jsonb keeps the keys, not their order: the order is the pack's list.
    expect(Object.keys(chain[1]!.record).sort()).toEqual([...FIELDS].sort());
    expect(chain[1]!.record['previous']).toBe(chain[0]!.hash);
    // The file is an issue of the document, of its own artefact.
    const issue = await one<{ artefact: string; profile: string; brick: string; sequence: number }>(
      db,
      `select artefact::text, profile, brick, sequence from einvoicing.issues where id = $1`,
      [chain[1]!.issue_id],
    );
    expect(issue).toEqual({ artefact: 'fiscal_record', profile: FAKE, brick: fake.brick, sequence: 1 });
    expect(b['verification_url']).toBe(fake.verificationUrl({ header: { number: b['number'] } } as unknown as FiscalRecordInput, 'batch'));
  });

  it('answers a document chained already with its record, and chains nothing twice', async () => {
    const documentId = await sale(db, chained);
    await fiscaliseDocument(chained.backend, documentId, { system: SYSTEM, generatedAt: AT }, FORMATS);
    const before = (await chainOf(chained.companyId, systemId(SYSTEM))).length;
    const again = await fiscaliseDocument(chained.backend, documentId, { system: SYSTEM, generatedAt: AT }, FORMATS);
    expect(again['already']).toBe(true);
    expect((await chainOf(chained.companyId, systemId(SYSTEM))).length).toBe(before);
  });

  it('cancels a record by one more record, once', async () => {
    const documentId = await sale(db, chained);
    await fiscaliseDocument(chained.backend, documentId, { system: SYSTEM, generatedAt: AT }, FORMATS);
    const cancelled = await fiscaliseDocument(chained.backend, documentId, { system: SYSTEM, generatedAt: AT, kind: 'anulacion' }, FORMATS);
    expect((cancelled['record'] as Record<string, unknown>)['kind']).toBe('anulacion');
    const kinds = (await chainOf(chained.companyId, systemId(SYSTEM))).filter((r) => r.document_id === documentId).map((r) => r.kind);
    expect(kinds).toEqual(['alta', 'anulacion']);
  });

  it('keeps one chain per system', async () => {
    const documentId = await sale(db, chained);
    await fiscaliseDocument(chained.backend, documentId, { system: OTHER, generatedAt: AT }, FORMATS);
    const other = await chainOf(chained.companyId, systemId(OTHER));
    expect(other.map((r) => [r.seq, r.is_first])).toEqual([[1, true]]);
  });

  it('chains nothing for a record that breaks a rule, or on a dry run', async () => {
    const broken = await sale(db, chained, { post: false });
    await db.query(`update documents set note = 'break a rule' where id = $1`, [broken]);
    await db.query(`select post_document($1)`, [broken]);
    const before = (await chainOf(chained.companyId, systemId(SYSTEM))).length;
    const refused = await fiscaliseDocument(chained.backend, broken, { system: SYSTEM, generatedAt: AT }, FORMATS);
    expect(refused['chained']).toBe(false);
    expect(refused['violations']).toEqual([{ code: 'FAKE-1', message: 'An invented rule.' }]);
    const dry = await fiscaliseDocument(chained.backend, await sale(db, chained), { system: SYSTEM, generatedAt: AT, dryRun: true }, FORMATS);
    expect(dry['chained']).toBe(false);
    expect(typeof dry['hash']).toBe('string');
    expect((await chainOf(chained.companyId, systemId(SYSTEM))).length).toBe(before);
  });

  it('refuses by name a format no brick writes, a mode the pack does not allow, and a company without a regime', async () => {
    const documentId = await sale(db, chained);
    expect(await fiscaliseDocument(chained.backend, documentId, { system: SYSTEM }).catch((e: Error) => e.message)).toMatch(
      /^format_without_brick: .*fake-chain/,
    );
    expect(
      await fiscaliseDocument(chained.backend, documentId, { system: SYSTEM, mode: 'realtime' }, FORMATS).catch((e: Error) => e.message),
    ).toMatch(/^fiscal_mode_not_allowed:/);
    const draft = await sale(db, chained, { post: false });
    expect(await fiscaliseDocument(chained.backend, draft, { system: SYSTEM }, FORMATS).catch((e: Error) => e.message)).toMatch(
      /^document_not_posted:/,
    );
  });

  it('refuses a pack and a brick that disagree about what is hashed', async () => {
    const documentId = await sale(db, chained);
    const disagreeing: FiscalisationFormat = { ...fake, hashInput: (input) => fake.hashInput(input).replace('date=', 'day=') };
    disagreeing.hash = (input) => createHash('sha256').update(disagreeing.hashInput(input), 'utf8').digest('hex');
    expect(
      await fiscaliseDocument(chained.backend, documentId, { system: SYSTEM }, { [FAKE]: disagreeing }).catch((e: Error) => e.message),
    ).toMatch(/^fiscal_hash_fields_unread:/);
  });

  it('reads the hashed fields in order, a separator inside a value included', () => {
    expect(hashedFields('a=1;b=x;y;c=3', ['a', 'b', 'c'], ';')).toEqual({ a: '1', b: 'x;y', c: '3' });
    expect(hashedFields('a=1;c=3', ['a', 'b', 'c'], ';')).toBeNull();
  });
});

// ------------------------------------------------------- what the database checks

describe('einvoicing.append_fiscal_record', () => {
  /** The arguments of a record of `documentId`, as fiscaliseDocument would pass them, with what a test overrides. */
  async function append(documentId: string, system: string, previous: string | null, override: Record<string, unknown> = {}) {
    const header = await one<{ number: string; document_date: string; amount_total: string }>(
      db,
      `select number, document_date::text, amount_total::text from documents where id = $1`,
      [documentId],
    );
    const input = `number=${header.number};date=${header.document_date};total=${header.amount_total};previous=${previous ?? ''}`;
    const args = {
      kind: 'alta',
      record: { number: header.number, date: header.document_date, total: header.amount_total, previous: previous ?? '' },
      hash_input: input,
      hash: createHash('sha256').update(input, 'utf8').digest('hex'),
      previous,
      content: `<r>${input}</r>`,
      violations: [],
      ...override,
    };
    return asUser(db, chained.accountantId, () =>
      expectError(
        db,
        `select einvoicing.append_fiscal_record($1, $2, $3::einvoicing.fiscal_record_kind, $4, 'batch', 'ZZ1', '', $5, $6::date,
                $7, $8, $9, $10, $11, null, $12, null, 'r.xml', 'application/xml', $13, $14, $15)`,
        [
          documentId, system, args.kind, FAKE, header.number, header.document_date, args.record, args.hash_input, args.hash,
          args.previous, AT, fake.brick, args.content, einvoiceChecksum(args.content as string), args.violations,
        ],
      ).catch((error: Error) => (error.message.startsWith('expected an error') ? 'appended' : Promise.reject(error))),
    );
  }

  it('refuses a hash that is not the digest of its text, a first record that names a previous one, and a link to another tail', async () => {
    const system = 'direct:1';
    const documentId = await sale(db, chained);
    expect(await append(documentId, system, null, { hash: 'f'.repeat(64) })).toMatch(/^fiscal_hash_mismatch:/);
    expect(await append(documentId, system, 'a'.repeat(64))).toMatch(/^fiscal_chain_not_first:/);
    expect(await append(documentId, system, null)).toBe('appended');
    expect(await append(await sale(db, chained), system, 'a'.repeat(64))).toMatch(/^fiscal_chain_link:/);
    expect(await append(documentId, system, (await chainOf(chained.companyId, system))[0]!.hash)).toMatch(/^fiscal_record_exists:/);
  });

  it('refuses a record without the fields the pack says the hash covers, or one that breaks a rule', async () => {
    const documentId = await sale(db, chained);
    expect(await append(documentId, 'direct:2', null, { record: { number: 'x' } })).toMatch(/^fiscal_record_fields_missing:/);
    expect(await append(documentId, 'direct:2', null, { violations: [{ code: 'R', message: 'broken' }] })).toMatch(
      /^fiscal_record_not_chainable: .*R: broken/,
    );
    expect(await append(documentId, 'direct:2', null, { kind: 'anulacion' })).toMatch(/^fiscal_nothing_to_cancel:/);
  });

  it('keeps the file of a record only for a record it chains', async () => {
    const documentId = await sale(db, chained);
    const message = await asUser(db, chained.accountantId, () =>
      expectError(
        db,
        `select einvoicing.record_issue($1, $2, 'brick', null, 'r.xml', 'application/xml', 'x', $3, '[]', 'fiscal_record')`,
        [documentId, FAKE, einvoiceChecksum('x')],
      ),
    );
    expect(message).toMatch(/^fiscal_record_outside_chain:/);
  });

  it('never rewrites nor deletes a record or an event, for anybody', async () => {
    const [record] = await chainOf(chained.companyId, systemId(SYSTEM));
    expect(await expectError(db, `update einvoicing.fiscal_chain set hash = 'x' where company_id = $1 and seq = 1`, [chained.companyId])).toMatch(
      /^fiscal_record_kept:/,
    );
    expect(await expectError(db, `delete from einvoicing.fiscal_chain where issue_id = $1`, [record!.issue_id])).toMatch(/^fiscal_record_kept:/);
    await asUser(db, chained.accountantId, () => db.query(`select einvoicing.log_fiscal_event($1, 'events:1', 'started')`, [chained.companyId]));
    expect(await expectError(db, `delete from einvoicing.fiscal_events where company_id = $1`, [chained.companyId])).toMatch(/^fiscal_record_kept:/);
  });
});

describe('einvoicing.verify_fiscal_chain', () => {
  it('finds nothing in an intact chain, and the first break in one that was tampered with', async () => {
    const system = OTHER;
    for (let i = 0; i < 2; i += 1) {
      await fiscaliseDocument(chained.backend, await sale(db, chained), { system, generatedAt: AT }, FORMATS);
    }
    const verify = () =>
      asUser(db, chained.viewerId, () =>
        rows<{ seq: number; problem: string }>(db, `select seq, problem from einvoicing.verify_fiscal_chain($1, $2)`, [chained.companyId, systemId(system)]),
      );
    expect(await verify()).toEqual([]);

    // The tail, rewritten behind the guard's back: what a restore from a
    // doctored backup would look like.
    const tail = (await chainOf(chained.companyId, systemId(system))).at(-1)!;
    await withoutTrigger(db, 'einvoicing.fiscal_chain', 'einvoicing_fiscal_chain_guard', () =>
      db.query(`update einvoicing.fiscal_chain set hash_input = hash_input || 'x' where company_id = $1 and system_id = $2 and seq = $3`, [
        chained.companyId,
        systemId(system),
        tail.seq,
      ]),
    );
    expect(await verify()).toEqual([{ seq: tail.seq, problem: 'hash_mismatch' }]);

    // Nothing more is chained to it, and the status says where it breaks.
    expect(
      await fiscaliseDocument(chained.backend, await sale(db, chained), { system, generatedAt: AT }, FORMATS).catch((e: Error) => e.message),
    ).toMatch(/^fiscal_chain_broken:/);
    const status = await fiscalisationStatus(chained.backend, chained.companyId);
    expect(status['verified']).toBe(false);
    const broken = (status['systems'] as Record<string, unknown>[]).find((s) => s['system_id'] === systemId(system))!;
    expect(broken['break']).toMatchObject({ seq: tail.seq, problem: 'hash_mismatch' });
  });

  it('follows the links backward, so two records with one hash are a break the forward walk cannot see', async () => {
    const fork: FiscalSystem = { ...SYSTEM, id: 'fork', installation: '1' };
    for (let i = 0; i < 4; i += 1) {
      await fiscaliseDocument(chained.backend, await sale(db, chained), { system: fork, generatedAt: AT }, FORMATS);
    }
    // Record 3 made a copy of record 1 — its text and its hash — and record 4
    // chained to it: every link holds going forward, and going back from 4
    // the hash it names is carried by two records.
    await withoutTrigger(db, 'einvoicing.fiscal_chain', 'einvoicing_fiscal_chain_guard', async () => {
      await db.query(
        `update einvoicing.fiscal_chain c set hash_input = f.hash_input, hash = f.hash
           from einvoicing.fiscal_chain f
          where c.company_id = $1 and c.system_id = $2 and c.seq = 3
            and f.company_id = c.company_id and f.system_id = c.system_id and f.seq = 1`,
        [chained.companyId, systemId(fork)],
      );
      await db.query(
        `update einvoicing.fiscal_chain c set previous_hash = f.hash
           from einvoicing.fiscal_chain f
          where c.company_id = $1 and c.system_id = $2 and c.seq = 4
            and f.company_id = c.company_id and f.system_id = c.system_id and f.seq = 1`,
        [chained.companyId, systemId(fork)],
      );
    });
    const found = await rows<{ seq: number; problem: string }>(db, `select seq, problem from einvoicing.verify_fiscal_chain($1, $2)`, [
      chained.companyId,
      systemId(fork),
    ]);
    expect(found).toEqual([{ seq: 4, problem: 'link_unresolved' }]);
  });
});

// ------------------------------------------------------------------ events, status

describe('fiscal events', () => {
  it('are numbered per system, named in lower case, and shown by the status', async () => {
    const log = (kind: string) =>
      asUser(db, chained.accountantId, () =>
        one<{ seq: number }>(db, `select seq from einvoicing.log_fiscal_event($1, 'events:2', $2, '{"records": 3}')`, [chained.companyId, kind]),
      );
    expect((await log('summary')).seq).toBe(1);
    expect((await log('stopped')).seq).toBe(2);
    expect(
      await asUser(db, chained.accountantId, () =>
        expectError(db, `select einvoicing.log_fiscal_event($1, 'events:2', 'Not A Name')`, [chained.companyId]),
      ),
    ).toMatch(/^bad_fiscal_event:/);
    expect(
      await asUser(db, chained.viewerId, () => expectError(db, `select einvoicing.log_fiscal_event($1, 'events:2', 'summary')`, [chained.companyId])),
    ).toMatch(/^not_allowed:/);
    const status = await fiscalisationStatus(chained.backend, chained.companyId);
    expect((status['events'] as Record<string, unknown>[]).map((e) => e['kind'])).toContain('stopped');
  });
});

describe('fiscalisationStatus', () => {
  it('names the posted sales without a record, never fiscalising them, and tells the obligation from before it', async () => {
    const waiting = await sale(db, chained, { date: '2026-07-01' });
    const before = await sale(db, chained, { date: '2025-12-01' });
    const status = await fiscalisationStatus(chained.backend, chained.companyId, { limit: 500 });
    const missing = (status['missing'] as Record<string, unknown>[]).map((d) => d['id']);
    expect(missing).toContain(waiting);
    expect(missing).not.toContain(before);
    expect(status['before_obligation_count']).toBeGreaterThanOrEqual(1);
    expect(await rows(db, `select 1 from einvoicing.fiscal_chain where document_id = $1`, [waiting])).toHaveLength(0);
    expect((status['regime'] as Record<string, unknown>)['format']).toBe(FAKE);
  });

  it('counts a record to send until the authority took it, alongside the electronic invoice of the same document', async () => {
    const documentId = await sale(db, chained);
    const result = await fiscaliseDocument(chained.backend, documentId, { system: SYSTEM, generatedAt: AT }, FORMATS);
    const issueId = String((result['record'] as Record<string, unknown>)['issue_id']);
    const pendingOf = async () =>
      ((await fiscalisationStatus(chained.backend, chained.companyId, { limit: 500 }))['pending'] as Record<string, unknown>[]).map((p) => p['issue_id']);
    expect(await pendingOf()).toContain(issueId);
    expect(await asUser(db, chained.ownerId, () => one<{ r: string | null }>(db, `select einvoicing.can_disable($1) as r`, [chained.companyId]))).toEqual({
      r: expect.stringMatching(/fiscal record/) as unknown as string,
    });

    // The electronic invoice of the same document goes its own way.
    const einvoice = await issueEinvoice(chained.backend, { document_id: documentId });
    await asUser(db, chained.accountantId, async () => {
      const toCustomer = await one<{ id: string }>(db, `select id from einvoicing.record_transmission($1, 'service', 'Access point')`, [
        (einvoice['issue'] as Record<string, unknown>)['id'],
      ]);
      const toAuthority = await one<{ id: string; artefact: string }>(
        db,
        `select id, artefact::text from einvoicing.record_transmission($1, 'service', 'Tax authority')`,
        [issueId],
      );
      expect(toAuthority.artefact).toBe('fiscal_record');
      await db.query(`select einvoicing.record_transmission_outcome($1, 'accepted_by_access_point', 'AUTH-1')`, [toAuthority.id]);
      expect(toCustomer.id).not.toBe(toAuthority.id);
    });
    expect(await pendingOf()).not.toContain(issueId);
    // A record sent to the authority is not the invoice sent to the customer.
    expect(await one(db, `select peppol_status from documents where id = $1`, [documentId])).toEqual({ peppol_status: null });
  });

  it('says a company without a regime has none, and shows a stranger nothing', async () => {
    const plain = packWhere(
      'declares no fiscalisation regime, a profile a brick writes, and a standard rate',
      (pack) =>
        pack.documents.einvoice_fiscalisation === null &&
        pack.manifest.country !== chained.pack.manifest.country &&
        pack.documents.einvoice_profile !== null &&
        EINVOICE_FORMATS[pack.documents.einvoice_profile] !== undefined &&
        standardTaxOf(pack) !== undefined,
    );
    const other = await seller(db, plain, 'No Regime Seller');
    const status = await fiscalisationStatus(other.backend, other.companyId);
    expect(status['regime']).toBeNull();
    expect(
      await fiscaliseDocument(other.backend, await sale(db, other), { system: SYSTEM }).catch((e: Error) => e.message),
    ).toMatch(/^no_fiscalisation_regime:/);
    const stranger = backendFor(db, other.accountantId);
    expect(await rows(db, `select 1 from einvoicing.fiscal_chain where company_id = $1`, [chained.companyId])).not.toHaveLength(0);
    const seen = await stranger.select({ schema: 'einvoicing', table: 'fiscal_chain', columns: ['id'], where: [{ column: 'company_id', op: 'eq', value: chained.companyId }] });
    expect(seen).toEqual([]);
  });

  it('lets a viewer read the chain and not write it', async () => {
    const viewer = backendFor(db, chained.viewerId);
    expect(
      await fiscaliseDocument(viewer, await sale(db, chained), { system: SYSTEM, generatedAt: AT }, FORMATS).catch((e: Error) => e.message),
    ).toMatch(/^not_allowed:/);
    const read = await viewer.select({ schema: 'einvoicing', table: 'fiscal_chain', columns: ['id'], where: [{ column: 'company_id', op: 'eq', value: chained.companyId }] });
    expect(read.length).toBeGreaterThan(0);
  });
});

describe('a regime that reports, or that is only announced', () => {
  /** The fake company's country given another regime for the length of one test, then its invented one back. */
  async function under<T>(regime: Record<string, unknown>, run: () => Promise<T>): Promise<T> {
    await db.query(`update country_defaults set einvoice_fiscalisation = $2 where country = $1`, [chained.pack.manifest.country, regime]);
    try {
      return await run();
    } finally {
      await db.query(`update country_defaults set einvoice_fiscalisation = $2 where country = $1`, [chained.pack.manifest.country, REGIME]);
    }
  }
  const REPORTING = {
    ...REGIME,
    kind: 'reporting',
    format: 'fake-report',
    hash: null,
    announced_from: null,
    announced_by: null,
    announced_on: null,
    events: null,
    reported: [{ what: 'invented_scope', by: ['supplier'], legal_reference: null, source: null }],
  };
  const ANNOUNCED = { ...REGIME, kind: 'chained', mandatory_from: [], announced_from: '2026-01-01', announced_by: 'An invented council', announced_on: '2025-06-01' };

  it('counts no sale as missing under a reporting regime, and says no brick writes its report', async () => {
    const documentId = await sale(db, chained, { date: '2026-07-02' });
    const status = await under(REPORTING, () => fiscalisationStatus(chained.backend, chained.companyId, { limit: 500 }));
    expect(status['missing']).toEqual([]);
    expect(status['missing_count']).toBe(0);
    expect(status['regime']).toMatchObject({ kind: 'reporting', format: 'fake-report', brick: null });
    expect(String(status['note'])).toMatch(/reporting regime, fake-report: .* nothing is chained/);
    expect(String(status['note'])).toMatch(/format_without_brick/);
    expect(await rows(db, `select 1 from einvoicing.fiscal_chain where document_id = $1`, [documentId])).toHaveLength(0);
  });

  it('refuses to chain a record under a reporting regime: without a brick by format_without_brick, with one by fiscal_regime_without_chain', async () => {
    const documentId = await sale(db, chained);
    const withoutBrick = await under(REPORTING, () =>
      fiscaliseDocument(chained.backend, documentId, { system: SYSTEM, generatedAt: AT }, FORMATS).catch((e: Error) => e.message),
    );
    expect(withoutBrick).toMatch(/^format_without_brick: .* keeps its fiscal records as fake-report/);
    const withBrick = await under(REPORTING, () =>
      fiscaliseDocument(chained.backend, documentId, { system: SYSTEM, generatedAt: AT }, { 'fake-report': { ...fake, format: 'fake-report' } }).catch(
        (e: Error) => e.message,
      ),
    );
    expect(withBrick).toMatch(/^fiscal_regime_without_chain: .* reporting regime, fake-report/);
    expect(await rows(db, `select 1 from einvoicing.fiscal_chain where document_id = $1`, [documentId])).toHaveLength(0);
  });

  it('counts no sale as missing while the obligation is only announced, and says who announced it and when', async () => {
    const documentId = await sale(db, chained, { date: '2026-07-03' });
    const status = await under(ANNOUNCED, () => fiscalisationStatus(chained.backend, chained.companyId, { limit: 500 }));
    expect((status['missing'] as Record<string, unknown>[]).map((d) => d['id'])).not.toContain(documentId);
    expect(status['missing_count']).toBe(0);
    expect(status['regime']).toMatchObject({ announced_from: '2026-01-01', mandatory_from: [] });
    expect(String(status['note'])).toMatch(/only announced, from 2026-01-01 \(An invented council, 2025-06-01\)/);
    // The same sale, under the regime in force, is missing its record.
    const inForce = await fiscalisationStatus(chained.backend, chained.companyId, { limit: 500 });
    expect((inForce['missing'] as Record<string, unknown>[]).map((d) => d['id'])).toContain(documentId);
  });
});

// ---------------------------------------------------------------- the real brick

describe('the brick the declaring pack names', () => {
  it('is in the registry, and chains two invoices whose second hashes the first', async () => {
    const regime = declaring.pack.documents.einvoice_fiscalisation!;
    const format = FISCALISATION_FORMATS[regime.format];
    expect(format, `no brick for ${regime.format}`).toBeDefined();

    // The producer is identified as the regime requires: here, by the seller's own tax number.
    const own = (await one<{ v: string }>(db, `select vat_number as v from companies where id = $1`, [declaring.companyId])).v;
    const system: FiscalSystem = { ...SYSTEM, producerTaxId: own };
    const first = await fiscaliseDocument(declaring.backend, await sale(db, declaring), { system, generatedAt: AT });
    expect(first['violations']).toEqual([]);
    expect(first['chained']).toBe(true);
    const second = await fiscaliseDocument(declaring.backend, await sale(db, declaring), { system, generatedAt: AT });
    expect(second['chained']).toBe(true);

    const chain = await chainOf(declaring.companyId, systemId(SYSTEM));
    expect(chain.map((r) => r.seq)).toEqual([1, 2]);
    // The record holds the fields the pack names, in its order; the second
    // carries the first's hash among them.
    const fields = regime.hash!.fields['alta'] ?? regime.hash!.fields['*']!;
    expect(Object.keys(chain[1]!.record).sort()).toEqual([...fields].sort());
    expect(Object.values(chain[1]!.record)).toContain(chain[0]!.hash);
    // The verification URL points at the production service the pack names for the default mode.
    const service = regime.qr?.services.find((s) => s.environment === 'production' && s.modes.includes(regime.submission.mode));
    expect(String(second['verification_url']).startsWith(service?.url ?? regime.qr?.url ?? '')).toBe(true);
    const verified = await rows(db, `select * from einvoicing.verify_fiscal_chain($1, $2)`, [declaring.companyId, systemId(SYSTEM)]);
    expect(verified).toEqual([]);
  });

  it('puts the QR code of the record of its issue on the PDF, with the words and the mention the pack prescribes', async () => {
    const regime = declaring.pack.documents.einvoice_fiscalisation!;
    const own = (await one<{ v: string }>(db, `select vat_number as v from companies where id = $1`, [declaring.companyId])).v;
    const system: FiscalSystem = { ...SYSTEM, producerTaxId: own };
    const documentId = await sale(db, declaring);
    expect(await readVerification(declaring.backend, documentId, declaring.companyId)).toBeNull();

    const record = await fiscaliseDocument(declaring.backend, documentId, { system, generatedAt: AT });
    const verification = await readVerification(declaring.backend, documentId, declaring.companyId);
    const mode = String(record['mode']);
    expect(verification).toEqual({
      url: record['verification_url'],
      heading: regime.qr?.label ?? null,
      notes: regime.mention.filter((m) => m.modes.length === 0 || m.modes.includes(mode as never)).map((m) => m.text),
      ...(regime.qr === null
        ? {}
        : {
            errorCorrection: regime.qr.error_correction,
            sizeMm: regime.qr.size_mm.min,
            ...(regime.qr.quiet_zone_mm === null ? {} : { quietZoneMm: regime.qr.quiet_zone_mm.recommended ?? regime.qr.quiet_zone_mm.min }),
          }),
    });

    // Once the record is cancelled, the invoice no longer carries its code.
    await fiscaliseDocument(declaring.backend, documentId, { system, kind: 'anulacion', generatedAt: AT });
    expect(await readVerification(declaring.backend, documentId, declaring.companyId)).toBeNull();
  });

  it('names a posted sale dated before the obligation as before it, not as missing', async () => {
    const documentId = await sale(db, declaring);
    const status = await fiscalisationStatus(declaring.backend, declaring.companyId, { limit: 500 });
    const from = [...declaring.pack.documents.einvoice_fiscalisation!.mandatory_from.map((m) => m.from)].sort()[0]!;
    const date = (await one<{ d: string }>(db, `select document_date::text as d from documents where id = $1`, [documentId])).d;
    const missing = (status['missing'] as Record<string, unknown>[]).map((d) => d['id']);
    expect(missing.includes(documentId)).toBe(date >= from);
  });
});

describe('the invoicing system', () => {
  it('is described by its operator, and never filled in', () => {
    expect(parseFiscalSystem(JSON.stringify(SYSTEM))).toEqual(SYSTEM);
    expect(() => parseFiscalSystem('{"name": "x"}')).toThrow(/^bad_fiscal_system: .* names no id, version, installation, producerName, producerTaxId/);
    expect(() => parseFiscalSystem('not json')).toThrow(BooksError);
    expect(() => parseFiscalSystem({ ...SYSTEM, verifactuOnly: 'yes' })).toThrow(/true or false/);
  });
});

describe('the compiled regime', () => {
  it('is in country_defaults as the pack normalised it, and nowhere a pack declares none', async () => {
    const compiled = await rows<{ country: string; r: unknown }>(
      db,
      `select country, einvoice_fiscalisation as r from country_defaults where einvoice_fiscalisation is not null and country <> $1`,
      [chained.pack.manifest.country],
    );
    const declared = allPacks.filter(
      (pack) => pack.documents.einvoice_fiscalisation !== null && pack.manifest.country !== chained.pack.manifest.country,
    );
    expect(compiled.map((c) => c.country).sort()).toEqual(declared.map((pack) => pack.manifest.country).sort());
    for (const pack of declared) {
      const row = compiled.find((c) => c.country === pack.manifest.country);
      expect(row?.r).toEqual(JSON.parse(JSON.stringify(pack.documents.einvoice_fiscalisation)));
    }
    expect(originalRegime).toBeNull();
  });
});
