import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { CLASSIFICATION_CODES } from '@ekwo-ai/myinvois';
import {
  cancelDocument,
  createDocument,
  EINVOICE_FORMATS,
  fiscalisationStatus,
  invertRate,
  issueEinvoice,
  postDocument,
  recordClearanceAnswer,
  readVerification,
  recordClearanceSubmission,
  renderDocumentPdf,
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

describe('a sale validated under a regime whose issuer builds the verification link', () => {
  const unreached = saleRef((tax) => typeOf(tax) === '06');
  const template = regime.clearance?.verification_url;
  const placeholders = [...(template?.production ?? '').matchAll(/\{([A-Za-z][A-Za-z0-9_]*)\}/g)].map((m) => m[1] as string);
  const IDENTIFIER = 'INVENTEDUIN000000000000002';
  // The authority's answer carries every value the template names but the identifier, invented.
  const answer = Object.fromEntries(placeholders.filter((name) => name !== 'identifier').map((name) => [name, `INVENTED${name.toUpperCase()}0001`]));
  const link = (environment: 'production' | 'test'): string =>
    String(environment === 'test' ? template?.test : template?.production).replace(/\{([A-Za-z][A-Za-z0-9_]*)\}/g, (_w, name: string) =>
      name === 'identifier' ? IDENTIFIER : String(answer[name]),
    );

  it('is declared so by the pack, with a link for production and one for the test environment', () => {
    expect(regime.clearance?.verification).toBe('computed');
    expect(template?.production).toMatch(/^https:\/\//);
    expect(template?.test).toMatch(/^https:\/\//);
    expect(placeholders).toContain('identifier');
  });

  it('refuses a validation whose answer lacks what the link is built from, and records nothing', async () => {
    await recordClearanceSubmission(backend, documentOf(unreached.ref), { reference: 'INVENTED-SUBMISSION-2' });
    if (placeholders.length > 1) {
      await expect(
        recordClearanceAnswer(backend, documentOf(unreached.ref), { state: 'validated', identifier: IDENTIFIER, validatedAt: '2026-01-20T03:00:00Z' }),
      ).rejects.toThrow(/clearance_verification_unbuilt/);
    }
  });

  it('builds the link of the environment that answered from the identifier and the answer', async () => {
    const result = await recordClearanceAnswer(backend, documentOf(unreached.ref), {
      state: 'validated',
      identifier: IDENTIFIER,
      validatedAt: '2026-01-20T03:00:00Z',
      answer,
      environment: 'test',
    });
    expect(result['clearance']).toMatchObject({ state: 'validated', identifier: IDENTIFIER, verification_url: link('test') });
  });

  it('prints the QR code of that link on the PDF, with what the pack names beside it', async () => {
    const pdf = await renderDocumentPdf(backend, { document_id: documentOf(unreached.ref) });
    expect(pdf.verification_url).toBe(link('test'));
    const verification = await readVerification(backend, documentOf(unreached.ref), companyId);
    const printed = regime.clearance?.printed;
    expect(verification).toMatchObject({ url: link('test'), heading: printed?.heading });
    const values: Record<string, string> = { identifier: IDENTIFIER, validated_at: '2026-01-20 03:00:00+00' };
    expect(verification?.fields).toEqual(
      (printed?.fields ?? []).map((entry) => ({
        label: entry.label,
        value: values[entry.field],
        kind: entry.field.endsWith('_at') ? 'datetime' : 'text',
      })),
    );
  });

  it('prints nothing of a validation on a sale that has none', async () => {
    const pdf = await renderDocumentPdf(backend, { document_id: documentOf(saleRef((tax) => typeOf(tax) === 'E').ref) });
    expect(pdf.verification_url).toBeNull();
  });
});

describe('a line that says what the format asks of it', () => {
  const exempt = saleRef((tax) => typeOf(tax) === 'E');
  const scenario = golden.documents.find((document) => document.ref === exempt.ref) as PackGolden['documents'][number];
  const scenarioLine = scenario.lines[0] as PackGolden['documents'][number]['lines'][number];
  // The attribute the pack gives every line, and an entry of the format's own list that is not the pack's.
  const CLASSIFICATION = Object.keys(regime.line_attributes ?? {})[0] as string;
  const named = Object.keys(CLASSIFICATION_CODES).find((code) => code !== regime.line_attributes?.[CLASSIFICATION]) as string;
  const OWN_REASON = 'Exemption certificate INVENTED-0002.';
  const packReason = (): string | undefined => regime.tax_attributes[exempt.tax]?.['exemption_reason'];
  let invoiceId: string;

  /** A sale of the scenario's exempted line, from a product of the catalogue, with what the line says of itself. */
  async function sale(attributes: Record<string, string>): Promise<string> {
    const created = (await createDocument(backend, {
      company_id: companyId,
      doc_type: 'sale_invoice',
      contact_id: contactOf(exempt.contact),
      document_date: scenario.date,
      lines: [
        {
          product_code: 'INVENTED-ITEM',
          unit_price: scenarioLine.unit_price ?? undefined,
          quantity: scenarioLine.quantity ?? undefined,
          tax_code: scenarioLine.tax ?? undefined,
          account_code: scenarioLine.account ?? undefined,
          attributes,
        },
      ],
    })) as Row;
    const id = String((created['document'] as Row | undefined)?.['id'] ?? created['id']);
    await postDocument(backend, { document_id: id });
    return id;
  }

  beforeAll(async () => {
    await completeBuyer(contactOf(exempt.contact));
    // A buyer abroad has no state of the country: the format's list has an entry for that.
    await db.query(
      `update contacts set region = '17' where id = $1 and country is distinct from (select fiscal_country from companies where id = $2)`,
      [contactOf(exempt.contact), companyId],
    );
    await db.query(
      `insert into products (company_id, code, name, kind, unit_code, currency_code, attributes)
       select $1, 'INVENTED-ITEM', 'Invented item', 'goods', 'C62', currency_code, $2 from companies where id = $1`,
      [companyId, { [CLASSIFICATION]: named }],
    );
    invoiceId = await sale({ exemption_reason: OWN_REASON });
  });

  it('is declared by the pack with a reason for every exempted tax', () => {
    for (const [code, attributes] of Object.entries(regime.tax_attributes)) {
      if (attributes['myinvois_tax_type'] === 'E') expect(attributes['exemption_reason'], code).toMatch(/\S/);
    }
  });

  it('takes the classification of its product and its own reason of exemption, over the pack\'s', async () => {
    const [line] = await db.query<{ attributes: Record<string, string> }>(`select attributes from document_lines where document_id = $1`, [invoiceId]).then((r) => r.rows);
    expect(line?.attributes).toEqual({ [CLASSIFICATION]: named, exemption_reason: OWN_REASON });

    const result = await validateEinvoice(backend, { document_id: invoiceId, issued_at: '2026-01-25T09:00:00+08:00', include_file: true });
    expect(result['violations']).toEqual([]);
    const text = JSON.stringify(JSON.parse(String(result['file'])));
    expect(text).toContain(`"_":"${named}","listID":"CLASS"`);
    expect(text).not.toContain(`"_":"${regime.line_attributes?.[CLASSIFICATION] as string}","listID":"CLASS"`);
    expect(text).toContain(OWN_REASON);
    if (packReason() !== undefined) expect(text).not.toContain(packReason() as string);
  });

  it('gives the reason of the pack where the line says none', async () => {
    const plain = await sale({});
    const result = await validateEinvoice(backend, { document_id: plain, issued_at: '2026-01-25T09:00:00+08:00', include_file: true });
    expect(result['violations']).toEqual([]);
    expect(String(result['file'])).toContain(packReason() as string);
  });

  it('is checked against the format\'s own list of classifications', async () => {
    const unknown = '9'.repeat(named.length);
    expect(CLASSIFICATION_CODES[unknown]).toBeUndefined();
    const wrong = await sale({ [CLASSIFICATION]: unknown });
    const result = await validateEinvoice(backend, { document_id: wrong, issued_at: '2026-01-25T09:00:00+08:00' });
    const messages = (result['violations'] as { message: string }[]).map((v) => v.message);
    expect(messages.some((m) => m.includes(unknown) && m.includes('ClassificationCodes'))).toBe(true);
  });

  it('is frozen with its document once posted, and copied by the credit note that cancels it', async () => {
    await expect(db.query(`update document_lines set attributes = '{}' where document_id = $1`, [invoiceId])).rejects.toThrow();
    const cancelled = (await cancelDocument(backend, { document_id: invoiceId })) as Row;
    const creditId = String((cancelled['credit_note'] as Row)['id']);
    const [line] = await db.query<{ attributes: Record<string, string> }>(`select attributes from document_lines where document_id = $1`, [creditId]).then((r) => r.rows);
    expect(line?.attributes).toEqual({ [CLASSIFICATION]: named, exemption_reason: OWN_REASON });
  });
});

describe('a sale in another currency than the company\'s', () => {
  const goods = saleRef((tax) => typeOf(tax) === '01');
  const scenario = golden.documents.find((document) => document.ref === goods.ref) as PackGolden['documents'][number];
  const scenarioLine = scenario.lines[0] as PackGolden['documents'][number]['lines'][number];
  // Units of the document's currency for one unit of the company's, as the books hold a rate: its inverse is exact.
  const RATE = '0.25000000';

  it('states the rate the other way round, exactly to eight decimals', () => {
    expect(invertRate('0.25000000')).toBe('4');
    expect(invertRate('0.21186441')).toBe('4.71999993');
    expect(invertRate('3')).toBe('0.33333333');
    expect(invertRate('0.00213000')).toBe('469.48356808');
    expect(() => invertRate('0')).toThrow(/zero/);
    expect(() => invertRate('-1')).toThrow(/positive/);
  });

  it('carries its currency, the company\'s as the tax currency, the rate it was posted at and the tax its entry posted', async () => {
    const company = await one<{ currency_code: string; decimals: number }>(
      db,
      `select c.currency_code, cur.decimal_places as decimals from companies c join currencies cur on cur.code = c.currency_code where c.id = $1`,
      [companyId],
    );
    // Another currency of the reference data, with as many decimals as the company's.
    const other = (
      await one<{ code: string }>(
        db,
        `select code from currencies where code <> $1 and decimal_places = $2 order by code limit 1`,
        [company.currency_code, company.decimals],
      )
    ).code;
    const created = (await createDocument(backend, {
      company_id: companyId,
      doc_type: 'sale_invoice',
      contact_id: contactOf(goods.contact),
      document_date: scenario.date,
      currency_code: other,
      lines: [
        {
          name: scenarioLine.name ?? 'Invented goods',
          unit_price: scenarioLine.unit_price ?? undefined,
          quantity: scenarioLine.quantity ?? undefined,
          tax_code: scenarioLine.tax ?? undefined,
          account_code: scenarioLine.account ?? undefined,
        },
      ],
    })) as Row;
    const id = String((created['document'] as Row | undefined)?.['id'] ?? created['id']);
    await db.query(`update documents set exchange_rate = $2 where id = $1`, [id, RATE]);
    await postDocument(backend, { document_id: id });
    await completeBuyer(contactOf(goods.contact));

    const posted = await one<{ tax: string; doc_tax: string }>(
      db,
      `select (select sum(l.credit - l.debit)::text from entry_lines l
                where l.entry_id = d.entry_id and l.tax_line and l.posting_type = 'tax') as tax,
              d.amount_tax::text as doc_tax
         from documents d where d.id = $1`,
      [id],
    );
    expect(Number(posted.tax)).toBeGreaterThan(0);

    const result = await validateEinvoice(backend, { document_id: id, issued_at: '2026-01-26T09:00:00+08:00', include_file: true });
    expect(result['violations']).toEqual([]);
    const document = (JSON.parse(String(result['file'])) as { Invoice: Record<string, unknown>[] }).Invoice[0] as Record<string, unknown>;
    expect(document['DocumentCurrencyCode']).toEqual([{ _: other }]);
    expect(document['TaxCurrencyCode']).toEqual([{ _: company.currency_code }]);
    expect(document['TaxExchangeRate']).toEqual([
      {
        SourceCurrencyCode: [{ _: other }],
        TargetCurrencyCode: [{ _: company.currency_code }],
        CalculationRate: [{ _: 1 / Number(RATE) }],
      },
    ]);
    const total = (document['TaxTotal'] as Record<string, unknown>[])[0] as Record<string, unknown>;
    expect(total['TaxAmount']).toEqual([{ _: Number(posted.tax), currencyID: company.currency_code }]);
    const monetary = (document['LegalMonetaryTotal'] as Record<string, unknown>[])[0] as Record<string, { currencyID: string }[]>;
    expect(monetary['PayableAmount']?.[0]?.currencyID).toBe(other);
    // The tax of the entry is the document's, converted at the rate it was posted at.
    expect(Number(posted.tax)).toBeCloseTo(Number(posted.doc_tax) / Number(RATE), 2);
  });
});
