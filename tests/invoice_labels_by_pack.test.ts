import { cp, mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import type { PGlite } from '@electric-sql/pglite';
import { INVOICE_LABELS } from '@ekwo-ai/invoice-pdf';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { readPack } from '../packages/cli/src/index.js';
import { INVOICE_LABEL_KEYS, renderDocumentPdf } from '../packages/core/src/index.js';
import { sale, seller, type Seller } from '../modules/einvoicing/tests/helpers.js';
import { freshDatabase, one } from './helpers/db.js';
import { allPacks, packWhere, packsRoot } from './helpers/packs.js';

/**
 * The words of an invoice the law of a country names (`20261026071500`).
 *
 * The words of the layout are held once per language by
 * `@ekwo-ai/invoice-pdf`; a pack names, in `documents.invoice_labels`, the few
 * its law prescribes — each with its article — and translates them in its
 * language files. They compile into `country_defaults.invoice_labels`, by
 * language, and the PDF of a document prints the pack's word for the
 * document's language over the layout's.
 *
 * The pack under test is whichever one names a word and translates it; every
 * word and language comes from its own files.
 */

const pack = packWhere(
  'names a word of its invoices and translates it',
  (p) =>
    p.documents.invoice_labels.some((label) => Object.keys(label.text_i18n).length > 0) &&
    typeof p.manifest.defaults.language === 'string',
);

const OWN = pack.manifest.defaults.language as string;
const WORD = pack.documents.invoice_labels.find((label) => Object.keys(label.text_i18n).length > 0)!;
const [LANGUAGE, TRANSLATED] = Object.entries(WORD.text_i18n)[0]!;
/** A language the layout carries words for and the pack names none in. */
const UNNAMED = Object.keys(INVOICE_LABELS).find(
  (language) => language !== OWN && !pack.documents.invoice_labels.some((label) => language in label.text_i18n),
);

let db: PGlite;
let s: Seller;

/** The draft of a sale to a customer who reads `language`, and its PDF. */
async function pdfIn(language: string): Promise<Awaited<ReturnType<typeof renderDocumentPdf>>> {
  await db.query(`update contacts set language = $2 where id = $1`, [s.customerId, language]);
  const draft = await sale(db, s, { post: false });
  const { language: held } = await one<{ language: string }>(db, `select language from documents where id = $1`, [draft]);
  expect(held).toBe(language);
  return renderDocumentPdf(s.backend, { document_id: draft });
}

beforeAll(async () => {
  db = await freshDatabase();
  s = await seller(db, pack, 'Words Of The Law', { enable: false });
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('the words a pack names', () => {
  it('are words of the layout, and every one the schema allows is one', async () => {
    const schema = JSON.parse(await readFile(join(packsRoot, 'schema', 'pack.1.json'), 'utf8')) as {
      $defs: { documents: { properties: { invoice_labels: { properties: Record<string, unknown> } } } };
    };
    const allowed = Object.keys(schema.$defs.documents.properties.invoice_labels.properties);
    expect(allowed.length).toBeGreaterThan(0);
    for (const key of allowed) expect(INVOICE_LABEL_KEYS).toContain(key);
    for (const p of allPacks) for (const label of p.documents.invoice_labels) expect(allowed).toContain(label.key);
  });

  it('each cite an article read in the register', () => {
    const keys = new Set((pack.manifest.certification?.sources ?? []).map((source) => (typeof source === 'string' ? source : source.key)));
    for (const label of pack.documents.invoice_labels) {
      expect(label.legal_reference.length).toBeGreaterThan(0);
      expect(keys.has(label.source ?? '')).toBe(true);
    }
  });

  it('reach country_defaults by language, the pack’s own among the others', async () => {
    const row = await one<{ labels: Record<string, Record<string, string>> }>(
      db,
      `select invoice_labels as labels from country_defaults where country = $1`,
      [pack.manifest.country],
    );
    expect(row.labels[OWN]?.[WORD.key]).toBe(WORD.text);
    expect(row.labels[LANGUAGE]?.[WORD.key]).toBe(TRANSLATED);
  });

  it('are empty for a pack that names none', async () => {
    const silent = allPacks.find((p) => p.documents.invoice_labels.length === 0);
    if (silent === undefined) return;
    const row = await one<{ labels: Record<string, unknown> }>(
      db,
      `select invoice_labels as labels from country_defaults where country = $1`,
      [silent.manifest.country],
    );
    expect(row.labels).toEqual({});
  });
});

describe('the PDF of a document', () => {
  it('prints the pack’s words in the document’s language', async () => {
    const pdf = await pdfIn(LANGUAGE);
    expect(pdf.pack_labels).toContain(WORD.key);
  });

  it('prints them in the pack’s own language', async () => {
    const pdf = await pdfIn(OWN);
    expect(pdf.pack_labels).toContain(WORD.key);
  });

  it('prints the layout’s words in a language the pack names none in', async () => {
    if (UNNAMED === undefined) return;
    const pdf = await pdfIn(UNNAMED);
    expect(pdf.pack_labels).toEqual([]);
    expect(pdf.labels_language).toBe(UNNAMED);
  });
});

describe('a language file that names a word of an invoice', () => {
  let dir: string;
  let file: string;
  let original: Record<string, unknown>;

  beforeAll(async () => {
    dir = await mkdtemp(join(tmpdir(), 'ekwo-invoice-labels-'));
    await cp(join(packsRoot, 'schema'), join(dir, 'schema'), { recursive: true });
    await cp(join(packsRoot, pack.slug), join(dir, pack.slug), { recursive: true });
    file = join(dir, pack.slug, 'i18n', `${LANGUAGE}.json`);
    original = JSON.parse(await readFile(file, 'utf8')) as Record<string, unknown>;
  });

  afterAll(async () => {
    await rm(dir, { recursive: true, force: true });
  });

  const refusal = async (): Promise<string> =>
    readPack(pack.slug, dir).then(
      () => 'accepted',
      (error: Error) => error.message,
    );

  it('is refused for a word the manifest does not name', async () => {
    const other = INVOICE_LABEL_KEYS.find((key) => !pack.documents.invoice_labels.some((label) => label.key === key))!;
    const labels = { ...(original['invoice_labels'] as Record<string, string>), [other]: 'Anything' };
    await writeFile(file, JSON.stringify({ ...original, invoice_labels: labels }));
    const said = await refusal();
    expect(said).toContain(`i18n/${LANGUAGE}.json invoice_labels`);
    expect(said).toContain(other);
  });

  it('is refused, in a declared language, when it leaves a word out', async () => {
    const { invoice_labels: _dropped, ...rest } = original;
    await writeFile(file, JSON.stringify(rest));
    const said = await refusal();
    if (!(pack.manifest.languages ?? []).includes(LANGUAGE)) {
      expect(said).toBe('accepted');
      return;
    }
    expect(said).toContain(`i18n/${LANGUAGE}.json invoice_labels`);
    expect(said).toContain(WORD.key);
  });
});
