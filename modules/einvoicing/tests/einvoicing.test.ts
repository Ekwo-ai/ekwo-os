import { mkdtemp, readFile, readdir, rm, writeFile, mkdir } from 'node:fs/promises';
import { readFileSync, readdirSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { validateXML } from 'xmllint-wasm';
import {
  BooksError,
  EINVOICE_FORMATS,
  TransportError,
  directoryTransport,
  einvoiceChecksum,
  einvoiceStatus,
  issueEinvoice,
  listEinvoiceTransmissions,
  validateEinvoice,
  type EinvoiceTransport,
} from '@ekwo-ai/core';
import { asUser, expectError, freshDatabase, one, repoRoot, rows } from '../../../tests/helpers/db.js';
import { newCompany, newUser } from '../../../tests/helpers/factory.js';
import { backendFor } from '../../../tests/mcp/helpers.js';
import {
  decimal,
  packIssuing,
  packWithoutBrick,
  packWithoutProfile,
  profileOf,
  sale,
  seller,
  type Seller,
} from './helpers.js';

// The `einvoicing` module: the electronic invoice of a posted sale, and every
// time it was sent.
//
// Nothing here names a country. The two profiles a brick writes are taken by
// their name, which is a format's, and each test takes the first pack that
// declares the one it needs; the codes a document carries are that pack's.
// What is asserted is the module — the file is the books', a broken rule
// keeps it home, a state only moves forward, the service's words are kept as
// they came — and not what any one country requires.

const PEPPOL = 'peppol-bis-3';
const FACTUR_X = 'factur-x-en16931';

let db: PGlite;
let peppol: Seller;
let facturX: Seller;
let root: string;

beforeAll(async () => {
  db = await freshDatabase();
  peppol = await seller(db, packIssuing(PEPPOL), 'Network Seller');
  facturX = await seller(db, packIssuing(FACTUR_X), 'Platform Seller');
  root = await mkdtemp(join(tmpdir(), 'ekwo-einvoicing-'));
}, 300_000);

afterAll(async () => {
  await db.close();
  await rm(root, { recursive: true, force: true });
});

// --- The published UBL schema, from the brick's own fixtures ----------------
const xsd = join(repoRoot, 'packages', 'formats', 'peppol-ubl', 'test', 'xsd');
const common = readdirSync(join(xsd, 'common'))
  .filter((name) => name.endsWith('.xsd'))
  .map((name) => ({ fileName: `common/${name}`, contents: readFileSync(join(xsd, 'common', name), 'utf8') }));

async function ublErrors(xml: string): Promise<string[]> {
  const main = xml.includes('<CreditNote ') ? 'UBL-CreditNote-2.1.xsd' : 'UBL-Invoice-2.1.xsd';
  const result = await validateXML({
    xml: [{ fileName: 'document.xml', contents: xml }],
    schema: [{ fileName: `maindoc/${main}`, contents: readFileSync(join(xsd, 'maindoc', main), 'utf8') }],
    preload: common,
  });
  return result.errors.map((error) => error.message);
}

/** The amount of an element of the file, read back as the decimal it says. */
function amountIn(xml: string, element: string): string | null {
  const match = new RegExp(`<(?:cbc|ram):${element}(?: [^>]*)?>(-?[0-9.]+)</(?:cbc|ram):${element}>`).exec(xml);
  return match === null ? null : decimal(match[1] as string);
}

const totalsOf = (documentId: string) =>
  one<{ amount_untaxed: string; amount_tax: string; amount_total: string }>(
    db,
    `select amount_untaxed::text, amount_tax::text, amount_total::text from documents where id = $1`,
    [documentId],
  );

const issueRow = (id: string) =>
  one<{ content: string; checksum: string; sendable: boolean; violations: unknown[]; profile: string; sequence: number }>(
    db,
    `select content, checksum, sendable, violations, profile, sequence from einvoicing.issues where id = $1`,
    [id],
  );

/** A transport that records what it was handed and answers what it is told to. */
function scriptedTransport(answer: (file: string) => Promise<{ reference: string; message?: string }>): EinvoiceTransport & { sent: string[] } {
  const sent: string[] = [];
  return {
    channel: 'service',
    service: 'Scripted access point',
    sent,
    async send(file) {
      sent.push(file.content);
      return answer(file.content);
    },
    async status() {
      return { state: 'submitted' };
    },
    async receive() {
      return [];
    },
    async lookup() {
      return { reachable: null };
    },
  };
}

// ------------------------------------------------------------ two profiles

describe('a posted invoice and a credit note, in the two profiles a brick writes', () => {
  for (const profile of [PEPPOL, FACTUR_X]) {
    it(`${profile}: writes each as a file that breaks no rule and says what the books say`, async () => {
      const s = profile === PEPPOL ? peppol : facturX;
      expect(profileOf(s.pack)).toBe(profile);
      const invoice = await sale(db, s);
      const credit = await sale(db, s, {
        docType: 'sale_credit_note',
        credits: invoice,
        lines: [{ name: 'Returned licence', quantity: '1', price: '100.00' }],
      });

      for (const documentId of [invoice, credit]) {
        const issued = await issueEinvoice(s.backend, { document_id: documentId, include_file: true });
        expect(issued['violations'], documentId).toEqual([]);
        expect(issued['sendable']).toBe(true);
        const file = issued['file'] as string;

        // Kept to the byte, under its own checksum, in the pack's profile.
        const kept = await issueRow(String((issued['issue'] as Record<string, unknown>)['id']));
        expect(kept.content).toBe(file);
        expect(kept.checksum).toBe(einvoiceChecksum(file));
        expect(kept.profile).toBe(profile);
        expect(kept.sendable).toBe(true);

        // And the figures are the ledger's, read back out of the file.
        const books = await totalsOf(documentId);
        if (profile === PEPPOL) {
          expect(await ublErrors(file)).toEqual([]);
          expect(amountIn(file, 'TaxExclusiveAmount')).toBe(decimal(books.amount_untaxed));
          expect(amountIn(file, 'TaxInclusiveAmount')).toBe(decimal(books.amount_total));
          expect(file).toContain(documentId === credit ? '<CreditNote ' : '<Invoice ');
        } else {
          expect(file).toContain(EINVOICE_FORMATS[FACTUR_X]?.specification);
          expect(amountIn(file, 'TaxBasisTotalAmount')).toBe(decimal(books.amount_untaxed));
          expect(amountIn(file, 'TaxTotalAmount')).toBe(decimal(books.amount_tax));
          expect(amountIn(file, 'GrandTotalAmount')).toBe(decimal(books.amount_total));
          expect(file).toContain(`<ram:TypeCode>${documentId === credit ? '381' : '380'}</ram:TypeCode>`);
        }
      }

      // The credit note names the invoice it credits, from the books.
      const number = await one<{ number: string }>(db, `select number from documents where id = $1`, [invoice]);
      const back = await validateEinvoice(s.backend, { document_id: credit, include_file: true });
      expect(back['file']).toContain(number.number);
    });
  }
});

// ------------------------------------------------- a profile without a brick

describe('a profile no brick writes, and a pack that declares none', () => {
  it('is refused by name, and nothing is written in another format', async () => {
    const pack = packWithoutBrick();
    const s = await seller(db, pack, 'Unwritten Seller');
    const documentId = await sale(db, s);
    const refused = await validateEinvoice(s.backend, { document_id: documentId }).catch((error: unknown) => error);
    expect(refused).toBeInstanceOf(BooksError);
    expect((refused as Error).message).toMatch(new RegExp(`^format_without_brick: .*${profileOf(pack) as string}`));
    expect(await issueEinvoice(s.backend, { document_id: documentId }).catch((error: Error) => error.message)).toMatch(
      /^format_without_brick:/,
    );
    expect(await rows(db, `select 1 from einvoicing.issues where document_id = $1`, [documentId])).toEqual([]);
  });

  it('is refused by name where the pack declares no profile, here and in the database', async () => {
    const s = await seller(db, packWithoutProfile(), 'Paper Seller');
    const documentId = await sale(db, s);
    expect(await validateEinvoice(s.backend, { document_id: documentId }).catch((error: Error) => error.message)).toMatch(
      /^no_einvoicing_profile:/,
    );
    const message = await asUser(db, s.accountantId, () =>
      expectError(db, `select einvoicing.record_issue($1, $2, 'brick', null, 'f.xml', 'application/xml', 'x', $3)`, [
        documentId,
        PEPPOL,
        einvoiceChecksum('x'),
      ]),
    );
    expect(message).toMatch(/^no_einvoicing_profile:/);
  });

  it('refuses in the database a file written in another profile than the pack declares', async () => {
    const documentId = await sale(db, peppol);
    const message = await asUser(db, peppol.accountantId, () =>
      expectError(db, `select einvoicing.record_issue($1, $2, 'brick', null, 'f.xml', 'application/xml', 'x', $3)`, [
        documentId,
        FACTUR_X,
        einvoiceChecksum('x'),
      ]),
    );
    expect(message).toMatch(new RegExp(`^einvoice_profile_mismatch: .* as ${PEPPOL}`));
  });
});

// ----------------------------------------------------- what the database checks

describe('what is issued', () => {
  it('is a posted sale, and nothing else', async () => {
    const draft = await sale(db, peppol, { post: false });
    expect(await validateEinvoice(peppol.backend, { document_id: draft }).catch((error: Error) => error.message)).toMatch(
      /^document_not_posted:/,
    );
    const message = await asUser(db, peppol.accountantId, () =>
      expectError(db, `select einvoicing.record_issue($1, $2, 'brick', null, 'f.xml', 'application/xml', 'x', $3)`, [
        draft,
        PEPPOL,
        einvoiceChecksum('x'),
      ]),
    );
    expect(message).toMatch(/^document_not_posted:/);
  });

  it('carries the checksum of its own text, or is refused', async () => {
    const documentId = await sale(db, peppol);
    const message = await asUser(db, peppol.accountantId, () =>
      expectError(db, `select einvoicing.record_issue($1, $2, 'brick', null, 'f.xml', 'application/xml', 'x', $3)`, [
        documentId,
        PEPPOL,
        einvoiceChecksum('y'),
      ]),
    );
    expect(message).toMatch(/^einvoice_checksum_mismatch:/);
  });

  it('is one issue however often it is asked for, and a new one only when the file changes', async () => {
    const documentId = await sale(db, peppol);
    const first = (await issueEinvoice(peppol.backend, { document_id: documentId }))['issue'] as Record<string, unknown>;
    const again = (await issueEinvoice(peppol.backend, { document_id: documentId }))['issue'] as Record<string, unknown>;
    expect(again['id']).toBe(first['id']);
    expect(await rows(db, `select 1 from einvoicing.issues where document_id = $1`, [documentId])).toHaveLength(1);

    // Another text for the same document is a second issue, the first kept.
    await asUser(db, peppol.accountantId, () =>
      db.query(`select einvoicing.record_issue($1, $2, 'brick', null, 'f.xml', 'application/xml', 'other', $3)`, [
        documentId,
        PEPPOL,
        einvoiceChecksum('other'),
      ]),
    );
    expect(
      (await rows<{ sequence: number }>(db, `select sequence from einvoicing.issues where document_id = $1 order by 1`, [documentId])).map(
        (r) => r.sequence,
      ),
    ).toEqual([1, 2]);
  });

  it('is never rewritten nor deleted, by anybody', async () => {
    const documentId = await sale(db, peppol);
    const issue = (await issueEinvoice(peppol.backend, { document_id: documentId }))['issue'] as Record<string, unknown>;
    expect(await expectError(db, `update einvoicing.issues set content = 'forged' where id = $1`, [issue['id']])).toMatch(
      /^einvoice_issued:/,
    );
    expect(await expectError(db, `delete from einvoicing.issues where id = $1`, [issue['id']])).toMatch(/^einvoice_issued:/);
  });

  it('leaves the posted document as it was posted', async () => {
    const documentId = await sale(db, peppol);
    const before = await one(db, `select * from documents where id = $1`, [documentId]);
    await issueEinvoice(peppol.backend, { document_id: documentId });
    expect(await one(db, `select * from documents where id = $1`, [documentId])).toEqual(before);
  });
});

// ------------------------------------------------------ a rule broken keeps it home

describe('a file that breaks a rule', () => {
  it('is kept with its rules, and refused at the door with the rules verbatim', async () => {
    // A customer the books know no electronic address for: the network has
    // nowhere to deliver, and the brick says so by the rule's name.
    const documentId = await sale(db, peppol, { contactId: peppol.unreachableId });
    const checked = await validateEinvoice(peppol.backend, { document_id: documentId });
    const codes = (checked['violations'] as { code: string }[]).map((v) => v.code);
    expect(codes).toContain('PEPPOL-EN16931-R010');
    expect(checked['sendable']).toBe(false);

    const issued = await issueEinvoice(peppol.backend, { document_id: documentId });
    const issue = issued['issue'] as Record<string, unknown>;
    expect(issue['sendable']).toBe(false);
    expect((await issueRow(String(issue['id']))).violations).toEqual(checked['violations']);

    const transport = scriptedTransport(async () => ({ reference: 'never' }));
    const refused = await issueEinvoice(peppol.backend, { document_id: documentId, send: true }, transport).catch(
      (error: Error) => error.message,
    );
    expect(refused).toMatch(/^einvoice_not_sendable:/);
    for (const violation of checked['violations'] as { code: string; message: string }[]) {
      expect(refused).toContain(`${violation.code}`);
      expect(refused).toContain(violation.message);
    }
    expect(transport.sent).toEqual([]);
    expect(await rows(db, `select 1 from einvoicing.transmissions where document_id = $1`, [documentId])).toEqual([]);
  });
});

// --------------------------------------------------------------- the states

describe('a sending', () => {
  const outcome = (who: string, id: string, state: string, reference: string | null = null, message: string | null = null) =>
    asUser(db, who, () =>
      one<{ state: string; reference: string | null; message: string | null }>(
        db,
        `select state::text, reference, message
           from einvoicing.record_transmission_outcome($1, $2::einvoicing.transmission_state, $3, $4)`,
        [id, state, reference, message],
      ),
    );

  it('only moves forward, keeps the service’s words as they came, and closes', async () => {
    const documentId = await sale(db, peppol);
    const transport = scriptedTransport(async () => ({ reference: 'AP-0001' }));
    const issued = await issueEinvoice(peppol.backend, { document_id: documentId, send: true }, transport);
    const transmission = issued['transmission'] as Record<string, unknown>;
    expect(transmission).toMatchObject({ state: 'submitted', reference: 'AP-0001', channel: 'service', service: 'Scripted access point' });
    expect(transport.sent).toHaveLength(1);
    const id = String(transmission['id']);

    // Words of a service, kept to the character: accents, quotes, a line break.
    const words = 'Validé par l’access point — «OK»\nref: 7f3a';
    expect(await outcome(peppol.accountantId, id, 'accepted_by_access_point', null, words)).toMatchObject({
      state: 'accepted_by_access_point',
      message: words,
    });
    // Asking twice, with nothing new, is not an event.
    await outcome(peppol.accountantId, id, 'accepted_by_access_point');

    expect(await asUser(db, peppol.accountantId, () =>
      expectError(db, `select einvoicing.record_transmission_outcome($1, 'submitted')`, [id]),
    )).toMatch(/^transmission_state_backwards:/);
    expect(await asUser(db, peppol.accountantId, () =>
      expectError(db, `select einvoicing.record_transmission_outcome($1, 'delivered', 'AP-9999')`, [id]),
    )).toMatch(/^transmission_reference_differs:/);
    expect(await asUser(db, peppol.accountantId, () =>
      expectError(db, `select einvoicing.record_transmission_outcome($1, 'failed')`, [id]),
    )).toMatch(/^transmission_already_left:/);

    await outcome(peppol.accountantId, id, 'delivered', null, 'MLS AP');
    expect(await asUser(db, peppol.accountantId, () =>
      expectError(db, `select einvoicing.record_transmission_outcome($1, 'rejected', null, 'too late')`, [id]),
    )).toMatch(/^transmission_closed:/);

    const events = await rows<{ sequence: number; state: string; message: string | null }>(
      db,
      `select sequence, state::text, message from einvoicing.transmission_events where transmission_id = $1 order by sequence`,
      [id],
    );
    expect(events).toEqual([
      { sequence: 1, state: 'prepared', message: null },
      { sequence: 2, state: 'submitted', message: null },
      { sequence: 3, state: 'accepted_by_access_point', message: words },
      { sequence: 4, state: 'delivered', message: 'MLS AP' },
    ]);
    expect(await expectError(db, `update einvoicing.transmission_events set message = 'nicer' where transmission_id = $1`, [id])).toMatch(
      /^transmission_event_recorded:/,
    );
    expect(await expectError(db, `delete from einvoicing.transmissions where id = $1`, [id])).toMatch(/^transmission_recorded:/);
  });

  it('marks the document as having left, which is what keeps it from going back to draft', async () => {
    const documentId = await sale(db, peppol);
    await issueEinvoice(peppol.backend, { document_id: documentId, send: true }, scriptedTransport(async () => ({ reference: 'AP-0002' })));
    expect(await one(db, `select peppol_status, peppol_message_id from documents where id = $1`, [documentId])).toEqual({
      peppol_status: 'submitted',
      peppol_message_id: 'AP-0002',
    });
  });

  it('is not sent twice while one is on its way, and is sent again once one is rejected', async () => {
    const documentId = await sale(db, peppol);
    const transport = scriptedTransport(async () => ({ reference: `AP-${transport.sent.length}` }));
    const first = (await issueEinvoice(peppol.backend, { document_id: documentId, send: true }, transport))['transmission'] as Record<
      string,
      unknown
    >;
    expect(
      await issueEinvoice(peppol.backend, { document_id: documentId, send: true }, transport).catch((error: Error) => error.message),
    ).toMatch(/^einvoice_already_sent:/);
    expect(transport.sent).toHaveLength(1);

    const refusal = 'Rejected: receiver not registered for this document type';
    await outcome(peppol.accountantId, String(first['id']), 'rejected', null, refusal);
    const second = (await issueEinvoice(peppol.backend, { document_id: documentId, send: true }, transport))['transmission'] as Record<
      string,
      unknown
    >;
    expect(second).toMatchObject({ sequence: 2, state: 'submitted' });

    const status = await einvoiceStatus(peppol.backend, { document_id: documentId });
    const history = status['transmissions'] as { sequence: number; state: string; message: string | null }[];
    expect(history.map((t) => [t.sequence, t.state])).toEqual([
      [1, 'rejected'],
      [2, 'submitted'],
    ]);
    expect(history[0]?.message).toBe(refusal);
    expect(status['state']).toBe('submitted');
  });

  it('that the transport could not make is failed, in the transport’s words, and may be made again', async () => {
    const documentId = await sale(db, peppol);
    const down = scriptedTransport(async () => {
      throw new TransportError('connect ECONNREFUSED 10.0.0.1:443');
    });
    const failed = (await issueEinvoice(peppol.backend, { document_id: documentId, send: true }, down))['transmission'] as Record<
      string,
      unknown
    >;
    expect(failed).toMatchObject({ state: 'failed', reference: null, message: 'connect ECONNREFUSED 10.0.0.1:443' });
    // It never left: the document says nothing of a sending.
    expect(await one(db, `select peppol_status from documents where id = $1`, [documentId])).toEqual({ peppol_status: null });

    const up = scriptedTransport(async () => ({ reference: 'AP-UP' }));
    expect(((await issueEinvoice(peppol.backend, { document_id: documentId, send: true }, up))['transmission'] as Record<string, unknown>)['state']).toBe(
      'submitted',
    );
  });

  it('keeps the module from being turned off while it is on its way', async () => {
    const s = await seller(db, peppol.pack, 'Busy Seller');
    const documentId = await sale(db, s);
    const transmission = (await issueEinvoice(s.backend, { document_id: documentId, send: true }, scriptedTransport(async () => ({ reference: 'AP-B' }))))[
      'transmission'
    ] as Record<string, unknown>;
    expect(await asUser(db, s.ownerId, () => expectError(db, `select disable_module($1, 'einvoicing')`, [s.companyId]))).toMatch(
      /on its way/,
    );
    await outcome(s.accountantId, String(transmission['id']), 'delivered');
    await asUser(db, s.ownerId, () => db.query(`select disable_module($1, 'einvoicing')`, [s.companyId]));
    // Turned off, nothing is deleted; turned on, it all comes back.
    await asUser(db, s.ownerId, () => db.query(`select enable_module($1, 'einvoicing')`, [s.companyId]));
    expect(await asUser(db, s.accountantId, () => rows(db, `select 1 from einvoicing.transmissions where company_id = $1`, [s.companyId]))).toHaveLength(1);
  });
});

// ------------------------------------------------------------------- who

describe('who sees and who sends', () => {
  let documentId: string;

  beforeAll(async () => {
    documentId = await sale(db, peppol);
    await issueEinvoice(peppol.backend, { document_id: documentId, send: true }, scriptedTransport(async () => ({ reference: 'AP-RLS' })));
  });

  const seen = (userId: string, document = documentId) =>
    asUser(db, userId, async () => ({
      issues: (await rows(db, `select 1 from einvoicing.issues where document_id = $1`, [document])).length,
      transmissions: (await rows(db, `select 1 from einvoicing.transmissions where document_id = $1`, [document])).length,
      events: (
        await rows(
          db,
          `select 1 from einvoicing.transmission_events e join einvoicing.transmissions t on t.id = e.transmission_id
            where t.document_id = $1`,
          [document],
        )
      ).length,
    }));

  it('a member who reads the books reads it all, a stranger nothing', async () => {
    expect(await seen(peppol.viewerId)).toEqual({ issues: 1, transmissions: 1, events: 2 });
    const stranger = await newUser(db, 'stranger@einvoicing.test');
    const elsewhere = await newCompany(db, { country: peppol.pack.manifest.country, name: 'Elsewhere', ownerId: stranger });
    await asUser(db, stranger, () => db.query(`select enable_module($1, 'einvoicing')`, [elsewhere.companyId]));
    expect(await seen(stranger)).toEqual({ issues: 0, transmissions: 0, events: 0 });
  });

  it('a company whose module is off shows nothing, even to its owner, and issues nothing', async () => {
    const s = await seller(db, peppol.pack, 'Offline Seller', { enable: false });
    const other = await sale(db, s);
    expect(
      await asUser(db, s.ownerId, () =>
        expectError(db, `select einvoicing.record_issue($1, $2, 'brick', null, 'f.xml', 'application/xml', 'x', $3)`, [
          other,
          PEPPOL,
          einvoiceChecksum('x'),
        ]),
      ),
    ).toMatch(/^module_not_enabled:/);
    // Turned on, a file issued and delivered; turned off, the rows are there
    // and unseen, by its owner too.
    await asUser(db, s.ownerId, () => db.query(`select enable_module($1, 'einvoicing')`, [s.companyId]));
    const sent = (await issueEinvoice(s.backend, { document_id: other, send: true }, scriptedTransport(async () => ({ reference: 'AP-OFF' }))))[
      'transmission'
    ] as Record<string, unknown>;
    await asUser(db, s.accountantId, () =>
      db.query(`select einvoicing.record_transmission_outcome($1, 'delivered')`, [sent['id']]),
    );
    expect(await seen(s.ownerId, other)).toEqual({ issues: 1, transmissions: 1, events: 3 });
    await asUser(db, s.ownerId, () => db.query(`select disable_module($1, 'einvoicing')`, [s.companyId]));
    expect(await seen(s.ownerId, other)).toEqual({ issues: 0, transmissions: 0, events: 0 });
    expect(await one(db, `select count(*)::int as n from einvoicing.issues where document_id = $1`, [other])).toEqual({ n: 1 });
  });

  it('a viewer reads and does not issue, and posting is not sending', async () => {
    const viewer = backendFor(db, peppol.viewerId);
    expect((await einvoiceStatus(viewer, { document_id: documentId }))['state']).toBe('submitted');
    expect(await issueEinvoice(viewer, { document_id: await sale(db, peppol) }).catch((error: Error) => error.message)).toMatch(
      /^not_allowed: .*einvoicing\.send/,
    );

    // An accountant who still books, and may not let a file leave.
    await db.query(
      `update company_members set capabilities_revoked = array['einvoicing.send'] where company_id = $1 and user_id = $2`,
      [peppol.companyId, peppol.accountantId],
    );
    try {
      const posted = await sale(db, peppol);
      expect(await issueEinvoice(peppol.backend, { document_id: posted }).catch((error: Error) => error.message)).toMatch(
        /^not_allowed: .*einvoicing\.send/,
      );
    } finally {
      await db.query(`update company_members set capabilities_revoked = '{}' where company_id = $1 and user_id = $2`, [
        peppol.companyId,
        peppol.accountantId,
      ]);
    }
  });

  it('no client writes a table of the module: the functions are the only way in', async () => {
    const refused = await asUser(db, peppol.ownerId, () =>
      expectError(db, `update einvoicing.transmissions set state = 'delivered' where document_id = $1`, [documentId]),
    );
    expect(refused).toMatch(/permission denied/);
  });
});

// --------------------------------------------------- the directory, end to end

describe('the directory transport, end to end', () => {
  it('writes the file, follows the receipts left beside it, and sends again after a refusal', async () => {
    const folder = join(root, 'outgoing');
    const transport = directoryTransport(folder);
    const documentId = await sale(db, facturX);

    const issued = await issueEinvoice(facturX.backend, { document_id: documentId, send: true, include_file: true }, transport);
    const transmission = issued['transmission'] as Record<string, unknown>;
    expect(transmission).toMatchObject({ channel: 'self', service: null, state: 'submitted' });
    const reference = String(transmission['reference']);
    expect(reference).toMatch(/^outbox\/invoice-.+\.cii\.[0-9a-f]{12}\.xml$/);
    expect(await readFile(join(folder, reference), 'utf8')).toBe(issued['file']);

    // Nobody has answered yet: still submitted, and nothing recorded.
    const quiet = await einvoiceStatus(facturX.backend, { document_id: documentId, refresh: true }, transport);
    expect(quiet['state']).toBe('submitted');

    // Whatever carries the folder refuses it, in its own words.
    const words = 'REJ-12: le destinataire est inconnu de l’annuaire\n(code 404)';
    await writeFile(join(folder, `${reference}.rejected`), words);
    const rejected = await einvoiceStatus(facturX.backend, { document_id: documentId, refresh: true }, transport);
    expect(rejected['state']).toBe('rejected');
    expect((rejected['transmissions'] as { message: string }[])[0]?.message).toBe(words);

    // The same file again: the folder holds it already, byte for byte, and
    // the second sending is a second row.
    const again = (await issueEinvoice(facturX.backend, { document_id: documentId, send: true }, transport))['transmission'] as Record<
      string,
      unknown
    >;
    expect(again).toMatchObject({ sequence: 2, state: 'submitted', reference });
    await rm(join(folder, `${reference}.rejected`));
    await writeFile(join(folder, `${reference}.delivered`), '');
    const delivered = await einvoiceStatus(facturX.backend, { document_id: documentId, refresh: true }, transport);
    expect(delivered['state']).toBe('delivered');

    const listed = await listEinvoiceTransmissions(facturX.backend, { company_id: facturX.companyId, document_id: documentId });
    expect((listed['transmissions'] as { state: string }[]).map((t) => t.state)).toEqual(['delivered', 'rejected']);
    expect(await readdir(join(folder, 'outbox'))).toHaveLength(2);
  });

  it('never overwrites a file it did not write, reads what arrived, and cannot tell who is reachable', async () => {
    const folder = join(root, 'shared');
    const transport = directoryTransport(folder);
    const file = { filename: 'invoice-X.xml', mediaType: 'application/xml', content: '<a/>', checksum: einvoiceChecksum('<a/>'), profile: PEPPOL };
    const metadata = {
      companyId: 'c', documentId: 'd', documentNumber: 'X', docType: 'sale_invoice', issueId: 'i', transmissionId: 't', sender: null, recipient: null,
    };
    const first = await transport.send(file, metadata);
    expect(await transport.send(file, metadata)).toEqual(first);
    await writeFile(join(folder, first.reference), '<b/>');
    await expect(transport.send(file, metadata)).rejects.toThrow(/^directory_conflict:/);
    await expect(transport.status('outbox/../../etc/passwd')).rejects.toThrow(/^unknown_reference:/);

    await mkdir(join(folder, 'inbox'), { recursive: true });
    await writeFile(join(folder, 'inbox', 'incoming.xml'), '<Invoice/>');
    expect(await transport.receive()).toMatchObject([
      { reference: 'inbox/incoming.xml', filename: 'incoming.xml', mediaType: 'application/xml', content: '<Invoice/>' },
    ]);
    expect(await transport.lookup({ scheme: '0088', id: '5412345000013' })).toMatchObject({ reachable: null });
  });
});
