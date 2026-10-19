import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import {
  EINVOICE_FORMATS,
  fiscalisationStatus,
  issueEinvoice,
  recordClearanceAnswer,
  recordClearanceSubmission,
  validateEinvoice,
  type Backend,
  type Row,
} from '@ekwo-ai/core';
import type { Pack, PackGolden } from '../packages/cli/src/index.js';
import { asUser, freshDatabase, one } from './helpers/db.js';
import { newCompany } from './helpers/factory.js';
import { replayScenario, type Replayed } from './helpers/golden-scenario.js';
import { packWhere } from './helpers/packs.js';
import { backendFor } from './mcp/helpers.js';

// A clearance format a brick writes, from a year of books to the authority's
// validation.
//
// The pack is found by the profile it issues in, `myinvois`, which is a format
// and not a country: the identifiers given to both parties below are the
// schemes that format names (TIN, SST, TTX), and every figure, tax type and
// classification asserted is read from the pack and from the document the
// books produced. The company replays the pack's golden year, so the sale
// issued is a sale the pack's own scenario booked.
//
// Every identifier, number and address here is invented, in the shapes the
// format checks.

const PROFILE = 'myinvois';

const pack: Pack = packWhere(
  `issues in ${PROFILE}, under a clearance regime, with a golden year`,
  (candidate) =>
    candidate.documents.einvoice_profile === PROFILE &&
    candidate.documents.einvoice_fiscalisation?.kind === 'clearance' &&
    candidate.golden !== null,
);
const golden = pack.golden as PackGolden;
const regime = pack.documents.einvoice_fiscalisation as NonNullable<Pack['documents']['einvoice_fiscalisation']>;

/** The first sale of the golden year under a tax, by the code the scenario books it with. */
function saleRef(predicate: (tax: string) => boolean): { ref: string; contact: string; tax: string } {
  const found = golden.documents.find(
    (document) => document.type === 'sale_invoice' && document.lines.length === 1 && predicate(String(document.lines[0]?.tax)),
  );
  if (found === undefined) throw new Error(`the golden year of ${pack.slug} books no such sale`);
  return { ref: found.ref, contact: found.contact, tax: String(found.lines[0]?.tax) };
}

const typeOf = (tax: string): string | undefined => regime.tax_attributes[tax]?.['myinvois_tax_type'];

let db: PGlite;
let companyId: string;
let backend: Backend;
let replayed: Replayed;

const SELLER = {
  TIN: 'C12345678010',
  SST: 'W10-1808-32000001',
  TTX: 'NA',
};
const BUYER_TIN = 'C98765432100';

/** A buyer the books say everything about, but for what `omit` leaves out. */
async function completeBuyer(contactId: string, omit: { tin?: boolean } = {}): Promise<void> {
  await db.query(
    `update contacts
        set registration_number = '202001234567', address_line1 = 'Invented Jalan 2', postal_code = '40000',
            city = 'Invented Town', region = $2, phone = '+60123456789', identifiers = $3
      where id = $1`,
    [contactId, '10', omit.tin === true ? {} : { TIN: BUYER_TIN }],
  );
}

beforeAll(async () => {
  db = await freshDatabase();
  const fixture = await newCompany(db, {
    country: pack.manifest.country,
    name: golden.name,
    chart: golden.chart,
    language: golden.language,
    fiscalYear: golden.fiscalYear,
  });
  companyId = fixture.companyId;
  await db.query(
    `update companies
        set legal_name = 'Invented Trading Sdn. Bhd.', registration_number = '201901000005',
            address_line1 = 'Invented Jalan 1', postal_code = '50450', city = 'Invented City', region = '14',
            phone = '+60312345678', email = 'books@invented.invalid',
            activity_code = '46510', activity_scheme = 'MSIC',
            activity_description = 'Wholesale of invented goods',
            identifiers = $2
      where id = $1`,
    [companyId, SELLER],
  );
  await asUser(db, fixture.ownerId, () => db.query(`select enable_module($1, 'einvoicing')`, [companyId]));
  replayed = await replayScenario(db, companyId, golden);
  backend = backendFor(db, fixture.ownerId);
}, 300_000);

afterAll(async () => {
  await db.close();
});

const documentOf = (ref: string): string => replayed.documents.get(ref) as string;
const contactOf = (ref: string): string => replayed.contacts.get(ref) as string;

describe(`a posted sale of the golden year of ${pack.slug}, issued in ${PROFILE}`, () => {
  const goods = saleRef((tax) => typeOf(tax) === '01');

  it('is counted as missing its validation before anything is submitted', async () => {
    const status = await fiscalisationStatus(backend, companyId);
    expect(status['regime']).toMatchObject({ kind: 'clearance', format: PROFILE, brick: EINVOICE_FORMATS[PROFILE]?.brick });
    expect(String(status['note'])).not.toMatch(/format_without_brick/);
    expect((status['missing'] as Row[]).map((d) => d['id'])).toContain(documentOf(goods.ref));
  });

  it('writes the document of the format with no violation, from the books and the pack alone', async () => {
    await completeBuyer(contactOf(goods.contact));
    const result = await issueEinvoice(backend, {
      document_id: documentOf(goods.ref),
      issued_at: '2026-01-15T10:30:00+08:00',
      include_file: true,
    });
    expect(result['violations']).toEqual([]);
    expect(result['sendable']).toBe(true);
    expect(result['issue']).toMatchObject({ profile: PROFILE, brick: EINVOICE_FORMATS[PROFILE]?.brick, sendable: true });

    // The document says what the books and the pack say.
    const file = JSON.parse(String(result['file'])) as { Invoice: Record<string, unknown>[] };
    const text = JSON.stringify(file);
    const header = await one<{ amount_total: string; amount_tax: string }>(
      db,
      `select amount_total::text, amount_tax::text from documents where id = $1`,
      [documentOf(goods.ref)],
    );
    expect(text).toContain(`"_":"${SELLER.TIN}","schemeID":"TIN"`);
    expect(text).toContain(`"_":"${BUYER_TIN}","schemeID":"TIN"`);
    expect(text).toContain(`"_":"${SELLER.SST}","schemeID":"SST"`);
    expect(text).toContain(`"_":"${typeOf(goods.tax) as string}"`);
    expect(text).toContain(`"_":"${regime.line_attributes?.['myinvois_classification'] as string}","listID":"CLASS"`);
    expect(text).toContain('"_":"2026-01-15"');
    expect(text).toContain('"_":"02:30:00Z"');
    expect(text).toContain(`"_":${Number(header.amount_total)}`);
  });

  it('is no longer missing once the authority has validated it, and the status says the brick writes it', async () => {
    const [issue] = (await backend.select<Row>({
      schema: 'einvoicing',
      table: 'issues',
      columns: ['id'],
      where: [{ column: 'document_id', op: 'eq', value: documentOf(goods.ref) }],
    })) as Row[];
    await recordClearanceSubmission(backend, documentOf(goods.ref), { issueId: String(issue?.['id']), reference: 'INVENTED-SUBMISSION-1' });
    const answer = await recordClearanceAnswer(backend, documentOf(goods.ref), {
      state: 'validated',
      identifier: 'INVENTEDUIN000000000000001',
      validatedAt: '2026-01-15T02:31:00Z',
      verificationUrl: 'https://verify.invalid/INVENTEDUIN000000000000001/share',
    });
    expect(answer['clearance']).toMatchObject({ state: 'validated', format: PROFILE });

    const status = await fiscalisationStatus(backend, companyId);
    expect((status['missing'] as Row[]).map((d) => d['id'])).not.toContain(documentOf(goods.ref));
    expect(status['clearance']).toMatchObject({ validated_count: 1, awaiting_count: 0, rejected_count: 0 });
    expect(String(status['note'])).toContain(`${EINVOICE_FORMATS[PROFILE]?.brick as string} writes the file submitted`);
  });
});

describe('a sale whose buyer has no tax identification number in the books', () => {
  const services = saleRef((tax) => typeOf(tax) === '02');

  it('is written with the violation that names it, and nothing else', async () => {
    await completeBuyer(contactOf(services.contact), { tin: true });
    const result = await validateEinvoice(backend, {
      document_id: documentOf(services.ref),
      issued_at: '2026-01-22T09:00:00+08:00',
    });
    expect(result['sendable']).toBe(false);
    expect((result['violations'] as { code: string }[]).map((v) => v.code)).toEqual(['input:buyer_tin']);
  });
});
