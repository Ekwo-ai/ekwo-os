import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import {
  EINVOICE_FORMATS,
  fiscalisationStatus,
  fiscaliseDocument,
  recordClearanceAnswer,
  recordClearanceSubmission,
  type ClearanceAnswer,
  type FiscalSystem,
} from '@ekwo-ai/core';
import { expectError, freshDatabase, one, rows } from '../../../tests/helpers/db.js';
import { packWhere } from '../../../tests/helpers/packs.js';
import { backendFor } from '../../../tests/mcp/helpers.js';
import { sale, seller, standardTaxOf, type Seller } from './helpers.js';

// Clearance: the invoice the authority validates before it is issued, a
// regime of the `einvoicing` module beside the chained record and the report.
//
// Nothing here names a country. The transitions are exercised in a company
// whose country declares no regime and is given one of invented values for
// the length of this file — a format no brick writes, a verification link the
// authority returns, a window to cancel and one to reject — so what is
// asserted is the module and the core: a submission is answered once, a
// state only moves forward, a window closes, and the status names every sale
// that is not validated. The pack that declares a clearance regime is found
// by what it declares, and only read.

const FORMAT = 'fake-clearance';

/** The invented regime the fake company's country is given for the length of this file. */
const REGIME = {
  kind: 'clearance',
  mandatory_from: [
    { who: 'largest', from: '2026-01-01', turnover_above: { amount: 1000, currency: 'XTS' } },
    { who: 'others', from: '2026-03-01', turnover_above: { amount: 10, currency: 'XTS' } },
  ],
  exemption: [{ turnover_below: { amount: 5, currency: 'XTS' }, valid_from: '2026-01-01', legal_reference: 'An invented guideline', source: null }],
  clearance: { verification: 'returned', cancellation_window: 'PT72H', rejection_window: 'PT72H', legal_reference: null, source: null },
  announced_from: null,
  announced_by: null,
  announced_on: null,
  format: FORMAT,
  hash: null,
  qr: null,
  mention: [],
  submission: { mode: 'realtime', modes: ['realtime'], batch_max: null, interval_seconds: null, retry_seconds: null, channel: 'authority_service', cadence: [], legal_reference: null, source: null },
  events: null,
  reported: [],
  tax_attributes: {},
  legal_reference: 'An invented article',
  source: 'invented',
};

const VALIDATED_AT = '2026-06-20T10:00:00+00:00';
const WITHIN = '2026-06-23T09:59:00+00:00';
const AFTER = '2026-06-23T10:01:00+00:00';
const URL = 'https://verify.invalid/share/';

let db: PGlite;
let cleared: Seller;
let plain: Seller;

beforeAll(async () => {
  db = await freshDatabase();
  const withoutRegime = (exclude: string | null) =>
    packWhere(
      'issues in peppol-bis-3, declares no fiscalisation regime and charges a standard rate',
      (pack) =>
        pack.documents.einvoice_profile === 'peppol-bis-3' &&
        pack.documents.einvoice_fiscalisation === null &&
        pack.manifest.country !== exclude &&
        standardTaxOf(pack) !== undefined,
    );
  const fake = withoutRegime(null);
  cleared = await seller(db, fake, 'Fake Clearance Seller');
  plain = await seller(db, withoutRegime(fake.manifest.country), 'No Regime Seller');
  await db.query(`update country_defaults set einvoice_fiscalisation = $2 where country = $1`, [fake.manifest.country, REGIME]);
}, 300_000);

afterAll(async () => {
  await db.close();
});

/** Under another regime for the length of one block, then the invented one back. */
async function under<T>(regime: Record<string, unknown>, run: () => Promise<T>): Promise<T> {
  await db.query(`update country_defaults set einvoice_fiscalisation = $2 where country = $1`, [cleared.pack.manifest.country, regime]);
  try {
    return await run();
  } finally {
    await db.query(`update country_defaults set einvoice_fiscalisation = $2 where country = $1`, [cleared.pack.manifest.country, REGIME]);
  }
}

const refused = (promise: Promise<unknown>): Promise<string> => promise.then(
  () => 'accepted',
  (error: Error) => error.message,
);

let identifiers = 0;
/** A posted sale, submitted and validated with an identifier of its own. */
async function validatedSale(input: Parameters<typeof sale>[2] = {}): Promise<string> {
  const documentId = await sale(db, cleared, input);
  await recordClearanceSubmission(cleared.backend, documentId, { reference: `SUB-${documentId}` });
  identifiers += 1;
  await recordClearanceAnswer(cleared.backend, documentId, {
    state: 'validated',
    identifier: `UIN-${identifiers}`,
    validatedAt: VALIDATED_AT,
    verificationUrl: `${URL}${identifiers}`,
  });
  return documentId;
}

const answer = (documentId: string, given: ClearanceAnswer) => refused(recordClearanceAnswer(cleared.backend, documentId, given));

// ------------------------------------------------------------- the transitions

describe('a submission and its answer', () => {
  it('records a submission as attempt 1, waiting, with its answer verbatim among the fiscal events', async () => {
    const documentId = await sale(db, cleared);
    const result = await recordClearanceSubmission(cleared.backend, documentId, { reference: 'SUB-1', answer: { submissionUid: 'SUB-1', accepted: 1 } });
    expect(result['clearance']).toMatchObject({ attempt: 1, state: 'submitted', format: FORMAT, reference: 'SUB-1', identifier: null });
    const [event] = await rows<{ kind: string; system_id: string; detail: Record<string, unknown> }>(
      db,
      `select kind, system_id, detail from einvoicing.fiscal_events where company_id = $1 and detail ->> 'document_id' = $2`,
      [cleared.companyId, documentId],
    );
    expect(event).toMatchObject({ kind: 'clearance_submitted', system_id: FORMAT, detail: { attempt: 1, answer: { submissionUid: 'SUB-1', accepted: 1 } } });
    expect(await refused(recordClearanceSubmission(cleared.backend, documentId))).toMatch(/^clearance_pending: .*\(attempt 1\)/);
  });

  it('validates with the identifier, the moment and the link the authority gave, once', async () => {
    const documentId = await sale(db, cleared);
    await recordClearanceSubmission(cleared.backend, documentId);
    expect(await answer(documentId, { state: 'validated', validatedAt: VALIDATED_AT, verificationUrl: URL })).toMatch(/^bad_clearance_answer: a validation names the identifier/);
    expect(await answer(documentId, { state: 'validated', identifier: 'UIN-A', validatedAt: VALIDATED_AT })).toMatch(/^clearance_verification_missing: .* \(returned\)/);
    expect(await answer(documentId, { state: 'validated', identifier: 'UIN-A', validatedAt: VALIDATED_AT, verificationUrl: 'http://verify.invalid' })).toMatch(
      /^bad_clearance_answer: the verification link is an https:\/\/ address/,
    );
    const validated = await recordClearanceAnswer(cleared.backend, documentId, {
      state: 'validated',
      identifier: 'UIN-A',
      validatedAt: VALIDATED_AT,
      verificationUrl: `${URL}A`,
      answer: { status: 'Valid' },
    });
    expect(validated['clearance']).toMatchObject({ state: 'validated', identifier: 'UIN-A', verification_url: `${URL}A` });
    expect(String(validated['note'])).toMatch(/^Validated by the authority as UIN-A/);

    // The same answer twice records nothing; another identifier is refused.
    const again = await recordClearanceAnswer(cleared.backend, documentId, { state: 'validated', identifier: 'UIN-A', validatedAt: VALIDATED_AT, verificationUrl: `${URL}A` });
    expect((again['clearance'] as Record<string, unknown>)['updated_at']).toBe((validated['clearance'] as Record<string, unknown>)['updated_at']);
    expect(await answer(documentId, { state: 'validated', identifier: 'UIN-B', validatedAt: VALIDATED_AT, verificationUrl: URL })).toMatch(/^clearance_identifier_differs: .* as UIN-A/);
    expect(await refused(recordClearanceSubmission(cleared.backend, documentId))).toMatch(/^clearance_already_validated: .* as UIN-A/);

    // One identifier is one invoice.
    const other = await sale(db, cleared);
    await recordClearanceSubmission(cleared.backend, other);
    expect(await answer(other, { state: 'validated', identifier: 'UIN-A', validatedAt: VALIDATED_AT, verificationUrl: URL })).toMatch(/^clearance_identifier_taken: .* UIN-A/);
  });

  it('closes an attempt the authority rejected, and takes the corrected submission as the next', async () => {
    const documentId = await sale(db, cleared);
    await recordClearanceSubmission(cleared.backend, documentId);
    expect(await answer(documentId, { state: 'rejected' })).toMatch(/^bad_clearance_answer: a rejection says why/);
    const rejected = await recordClearanceAnswer(cleared.backend, documentId, { state: 'rejected', reason: 'An invented validation error', answer: { errors: ['E1'] } });
    expect(rejected['clearance']).toMatchObject({ state: 'rejected', rejected_by: 'authority', rejection_reason: 'An invented validation error' });
    expect(await answer(documentId, { state: 'validated', identifier: 'UIN-R', validatedAt: VALIDATED_AT, verificationUrl: URL })).toMatch(
      /^clearance_state_backwards: attempt 1 .* is rejected/,
    );
    expect(await answer(documentId, { state: 'cancelled', reason: 'Too late' })).toMatch(/^clearance_state_backwards: .* only a validated invoice is cancelled/);
    const second = await recordClearanceSubmission(cleared.backend, documentId);
    expect(second['clearance']).toMatchObject({ attempt: 2, state: 'submitted' });
  });

  it('answers nothing that was not submitted, and nothing the authority does not answer', async () => {
    const documentId = await sale(db, cleared);
    expect(await answer(documentId, { state: 'validated', identifier: 'UIN-N', validatedAt: VALIDATED_AT, verificationUrl: URL })).toMatch(/^clearance_not_submitted:/);
    await recordClearanceSubmission(cleared.backend, documentId);
    expect(await refused(recordClearanceAnswer(cleared.backend, documentId, { state: 'submitted' as never }))).toMatch(/^not_an_answer:/);
    expect(await answer(documentId, { state: 'validated', identifier: 'UIN-N', validatedAt: VALIDATED_AT, verificationUrl: URL, by: 'buyer' })).toMatch(
      /^bad_clearance_answer: by names who rejected an invoice/,
    );
    expect(await answer(documentId, { state: 'rejected', reason: 'Not mine', by: 'buyer' })).toMatch(/^clearance_state_backwards: .* the buyer rejects only a validated invoice/);
  });
});

describe('the windows of the regime', () => {
  it('lets the buyer reject a validated invoice within its window, and the issuer cancel it then', async () => {
    const documentId = await validatedSale();
    const rejected = await recordClearanceAnswer(cleared.backend, documentId, { state: 'rejected', by: 'buyer', reason: 'Wrong quantity', at: WITHIN });
    expect(rejected['clearance']).toMatchObject({ state: 'rejected', rejected_by: 'buyer', rejection_reason: 'Wrong quantity' });
    expect(await refused(recordClearanceSubmission(cleared.backend, documentId))).toMatch(/^clearance_already_validated:/);
    const cancelled = await recordClearanceAnswer(cleared.backend, documentId, { state: 'cancelled', reason: 'Rejected by the buyer', at: WITHIN });
    expect(cancelled['clearance']).toMatchObject({ state: 'cancelled', cancellation_reason: 'Rejected by the buyer' });
    expect(await refused(recordClearanceSubmission(cleared.backend, documentId))).toMatch(/^clearance_cancelled: .* cancel_document/);
    expect(await answer(documentId, { state: 'rejected', by: 'buyer', reason: 'Again', at: WITHIN })).toMatch(/^clearance_state_backwards:/);
  });

  it('refuses a rejection or a cancellation once its window has closed', async () => {
    const documentId = await validatedSale();
    expect(await answer(documentId, { state: 'rejected', by: 'buyer', reason: 'Late', at: AFTER })).toMatch(
      /^clearance_window_closed: the buyer may reject an invoice within PT72H of its validation/,
    );
    expect(await answer(documentId, { state: 'cancelled', reason: 'Late', at: AFTER })).toMatch(
      /^clearance_window_closed: the issuer may cancel an invoice within PT72H .* corrected by a credit note/,
    );
    expect(await answer(documentId, { state: 'cancelled', at: WITHIN })).toMatch(/^bad_clearance_answer: a cancellation says why/);
  });

  it('refuses both to a regime that grants neither', async () => {
    const documentId = await validatedSale();
    const strict = { ...REGIME, clearance: { verification: 'computed', cancellation_window: null, rejection_window: null, legal_reference: null, source: null } };
    expect(await under(strict, () => answer(documentId, { state: 'cancelled', reason: 'Mistake', at: WITHIN }))).toMatch(
      /^clearance_not_cancellable: .* corrected by a credit note/,
    );
    expect(await under(strict, () => answer(documentId, { state: 'rejected', by: 'buyer', reason: 'No', at: WITHIN }))).toMatch(
      /^clearance_buyer_cannot_reject:/,
    );
  });
});

describe('what the database keeps', () => {
  it('never deletes a clearance, never rewrites what was given, and moves a state only forward, for anybody', async () => {
    const documentId = await validatedSale();
    expect(await expectError(db, `delete from einvoicing.clearances where document_id = $1`, [documentId])).toMatch(/^clearance_recorded: .* not deleted/);
    expect(await expectError(db, `update einvoicing.clearances set identifier = 'UIN-X' where document_id = $1`, [documentId])).toMatch(
      /^clearance_recorded: the identifier/,
    );
    expect(await expectError(db, `update einvoicing.clearances set reference = 'other' where document_id = $1`, [documentId])).toMatch(
      /^clearance_recorded: what was submitted/,
    );
    expect(
      await expectError(db, `update einvoicing.clearances set state = 'submitted', identifier = null, validated_at = null, verification_url = null where document_id = $1`, [documentId]),
    ).toMatch(/^clearance_recorded/);
  });

  it('refuses a draft, a purchase, a company without a regime and one whose regime clears nothing', async () => {
    const draft = await sale(db, cleared, { post: false });
    expect(await refused(recordClearanceSubmission(cleared.backend, draft))).toMatch(/^document_not_posted: .* draft/);
    const elsewhere = await sale(db, plain);
    expect(await refused(recordClearanceSubmission(plain.backend, elsewhere))).toMatch(/^no_fiscalisation_regime:/);
    const chained = { ...REGIME, kind: 'chained', clearance: undefined, hash: { algorithm: 'SHA-256', separator: ';', fields: { '*': ['a'] } } };
    const documentId = await sale(db, cleared);
    expect(await under(chained, () => refused(recordClearanceSubmission(cleared.backend, documentId)))).toMatch(
      /^fiscal_regime_not_clearance: .* a chained regime, fake-clearance/,
    );
  });

  it('lets a viewer read the clearances and record none, and shows a stranger nothing', async () => {
    const documentId = await sale(db, cleared);
    expect(await refused(recordClearanceSubmission(backendFor(db, cleared.viewerId), documentId))).toMatch(/^not_allowed:/);
    const read = await backendFor(db, cleared.viewerId).select({ schema: 'einvoicing', table: 'clearances', columns: ['id'], where: [{ column: 'company_id', op: 'eq', value: cleared.companyId }] });
    expect(read.length).toBeGreaterThan(0);
    const seen = await plain.backend.select({ schema: 'einvoicing', table: 'clearances', columns: ['id'], where: [{ column: 'company_id', op: 'eq', value: cleared.companyId }] });
    expect(seen).toEqual([]);
    expect(await refused(recordClearanceSubmission(plain.backend, documentId))).toMatch(/^(unknown_document|not_allowed):/);
  });

  it('keeps the module on while an invoice waits for the authority', async () => {
    const documentId = await sale(db, cleared);
    await recordClearanceSubmission(cleared.backend, documentId);
    const { r } = await one<{ r: string | null }>(db, `select einvoicing.can_disable($1) as r`, [cleared.companyId]);
    expect(r).toMatch(/waiting for the authority's validation/);
    await recordClearanceAnswer(cleared.backend, documentId, { state: 'rejected', reason: 'An invented error' });
  });

  it('chains nothing under a clearance regime', async () => {
    const system: FiscalSystem = { name: 'Invented', id: 'ZZ', version: '1', installation: 'one', producerName: 'Invented', producerTaxId: 'ZZ1' };
    expect(await refused(fiscaliseDocument(cleared.backend, await sale(db, cleared), { system }))).toMatch(
      /^fiscal_regime_without_chain: .* a clearance regime, fake-clearance: .* einvoicing_clearance/,
    );
  });
});

// ------------------------------------------------------------------ the status

describe('fiscalisationStatus under a clearance regime', () => {
  it('names every posted sale within the obligation without a validation, and tells waiting, rejected and cancelled apart', async () => {
    const never = await sale(db, cleared, { date: '2026-07-01' });
    const before = await sale(db, cleared, { date: '2025-12-01' });
    const waiting = await sale(db, cleared, { date: '2026-07-01' });
    await recordClearanceSubmission(cleared.backend, waiting);
    const refusedOnce = await sale(db, cleared, { date: '2026-07-01' });
    await recordClearanceSubmission(cleared.backend, refusedOnce);
    await recordClearanceAnswer(cleared.backend, refusedOnce, { state: 'rejected', reason: 'An invented error' });
    const valid = await validatedSale({ date: '2026-07-01' });
    const byBuyer = await validatedSale({ date: '2026-07-01' });
    await recordClearanceAnswer(cleared.backend, byBuyer, { state: 'rejected', by: 'buyer', reason: 'Not ordered', at: WITHIN });
    const voided = await validatedSale({ date: '2026-07-01' });
    await recordClearanceAnswer(cleared.backend, voided, { state: 'cancelled', reason: 'Issued twice', at: WITHIN });
    // The credit note that undoes an invoice void at the authority is the books' half of its cancellation.
    const undoing = await sale(db, cleared, { docType: 'sale_credit_note', credits: voided, date: '2026-07-02' });

    const status = await fiscalisationStatus(cleared.backend, cleared.companyId, { limit: 500 });
    const ids = (key: string, from: Record<string, unknown> = status) => ((from[key] as Record<string, unknown>[]) ?? []).map((d) => d['id']);
    expect(ids('missing')).toEqual(expect.arrayContaining([never, refusedOnce]));
    for (const id of [before, waiting, valid, byBuyer, voided, undoing]) expect(ids('missing')).not.toContain(id);
    expect(status['before_obligation_count']).toBeGreaterThanOrEqual(1);

    const clearance = status['clearance'] as Record<string, unknown>;
    expect(ids('awaiting', clearance)).toContain(waiting);
    expect(ids('rejected', clearance)).toContain(refusedOnce);
    expect(ids('buyer_rejected', clearance)).toContain(byBuyer);
    expect(ids('cancelled_still_posted', clearance)).toContain(voided);
    expect(clearance['validated_count']).toBeGreaterThanOrEqual(1);

    expect(status['regime']).toMatchObject({
      kind: 'clearance',
      format: FORMAT,
      brick: null,
      clearance: { verification: 'returned', cancellation_window: 'PT72H' },
      exemption: { turnover_below: { amount: 5, currency: 'XTS' }, valid_from: '2026-01-01' },
    });
    const note = String(status['note']);
    expect(note).toMatch(/clearance regime, fake-clearance/);
    expect(note).toMatch(/No brick of packages\/formats\/ writes fake-clearance yet \(format_without_brick\)/);
    expect(note).toMatch(/have no validation and none on its way/);
    expect(note).toMatch(/cancel_document undoes them in the books/);
    expect(note).toMatch(/below 5 XTS of annual turnover is exempted since 2026-01-01; .* the count starts on the earliest day, 2026-01-01/);
  });

  it('counts nothing while the clearance is only announced', async () => {
    const documentId = await sale(db, cleared, { date: '2026-07-03' });
    const announced = { ...REGIME, mandatory_from: [], announced_from: '2026-01-01', announced_by: 'An invented council', announced_on: '2025-06-01' };
    const status = await under(announced, () => fiscalisationStatus(cleared.backend, cleared.companyId, { limit: 500 }));
    expect(status['missing_count']).toBe(0);
    expect((status['missing'] as Record<string, unknown>[]).map((d) => d['id'])).not.toContain(documentId);
    expect(String(status['note'])).toMatch(/only announced/);
  });
});

describe('the pack that declares a clearance regime', () => {
  it('is compiled as it declares it, names its unvalidated sales, and says whether a brick writes its format', async () => {
    const pack = packWhere(
      'declares a clearance regime and charges a standard rate',
      (candidate) => candidate.documents.einvoice_fiscalisation?.kind === 'clearance' && standardTaxOf(candidate) !== undefined,
    );
    const regime = pack.documents.einvoice_fiscalisation!;
    const compiled = await one<{ r: Record<string, unknown> }>(db, `select einvoice_fiscalisation as r from country_defaults where country = $1`, [pack.manifest.country]);
    expect(compiled.r).toEqual(JSON.parse(JSON.stringify(regime)));
    expect(compiled.r['hash']).toBeNull();

    const company = await seller(db, pack, 'Declaring Clearance Seller');
    const from = [...regime.mandatory_from.map((entry) => entry.from)].sort()[0]!;
    const documentId = await sale(db, company, { date: from });
    const status = await fiscalisationStatus(company.backend, company.companyId, { limit: 500 });
    expect((status['missing'] as Record<string, unknown>[]).map((d) => d['id'])).toContain(documentId);
    const brick = EINVOICE_FORMATS[regime.format]?.brick;
    expect(status['regime']).toMatchObject({ kind: 'clearance', format: regime.format, brick: brick ?? null });
    expect(String(status['note'])).toMatch(brick === undefined ? /format_without_brick/ : new RegExp(`${brick} writes the file submitted`));

    // Its windows are the ones the database reads.
    await recordClearanceSubmission(company.backend, documentId);
    const validatedAt = '2026-06-20T10:00:00+00:00';
    await recordClearanceAnswer(company.backend, documentId, {
      state: 'validated',
      identifier: 'UIN-DECLARED-1',
      validatedAt,
      ...(regime.clearance!.verification === 'none' ? {} : { verificationUrl: 'https://verify.invalid/declared' }),
    });
    const cancel = (at: string) => refused(recordClearanceAnswer(company.backend, documentId, { state: 'cancelled', reason: 'Issued twice', at }));
    if (regime.clearance!.cancellation_window === null) {
      expect(await cancel(validatedAt)).toMatch(/^clearance_not_cancellable:/);
    } else {
      expect(await cancel('2027-06-20T10:00:00+00:00')).toMatch(/^clearance_window_closed:/);
      expect(await cancel('2026-06-20T10:30:00+00:00')).toBe('accepted');
    }
  });
});
