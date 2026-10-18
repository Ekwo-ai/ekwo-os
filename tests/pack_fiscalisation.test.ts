import { cp, mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { FISCALISATION_FORMATS } from '@ekwo-ai/core';
import { readPack } from '../packages/cli/src/index.js';
import { packWhere, packsRoot, somePack } from './helpers/packs.js';

// `einvoicing.fiscalisation`: the chained record a country requires for every
// invoice the software issues. Nothing here names a country: the pack that
// declares a regime is found by what it declares, and the refusals are made
// on a copy of whichever pack comes first, given a regime of invented values
// in a format no brick writes.

const declaring = packWhere('declares a fiscalisation regime', (pack) => pack.documents.einvoice_fiscalisation !== null);

let dir: string;
let manifestFile: string;
let manifest: Record<string, unknown>;
let sourceKey: string;
let taxCode: string;

/** A regime of invented values, every one a shape the schema allows. */
function regime(): Record<string, unknown> {
  return {
    mandatory_from: '2030-01-01',
    format: 'invented-chain',
    hash: { algorithm: 'SHA-256', separator: ';', fields: ['number', 'date', 'total', 'previous'] },
    qr: { url: 'https://verify.invalid/check', size_mm: { min: 20, max: 30 }, error_correction: 'Q' },
    mention: [{ text: 'An invented sentence' }],
    submission: { mode: 'batch', modes: ['batch', 'none'], batch_max: 50, interval_seconds: 30 },
    events: { summary_every_hours: 12, modes: ['none'] },
    tax_attributes: { [taxCode]: { invented_key: 'X1' } },
    legal_reference: 'An invented article',
    source: sourceKey,
  };
}

async function withRegime(block: unknown): Promise<string> {
  const einvoicing = { ...((manifest['einvoicing'] ?? {}) as Record<string, unknown>), fiscalisation: block };
  await writeFile(manifestFile, JSON.stringify({ ...manifest, einvoicing }), 'utf8');
  return somePack.slug;
}

const refusal = async (block: unknown): Promise<string> =>
  readPack(await withRegime(block), dir).then(
    () => 'accepted',
    (error: Error) => error.message,
  );

beforeAll(async () => {
  dir = await mkdtemp(join(tmpdir(), 'ekwo-fiscalisation-'));
  await cp(join(packsRoot, 'schema'), join(dir, 'schema'), { recursive: true });
  await cp(join(packsRoot, somePack.slug), join(dir, somePack.slug), { recursive: true });
  manifestFile = join(dir, somePack.slug, 'pack.json');
  manifest = JSON.parse(await readFile(manifestFile, 'utf8')) as Record<string, unknown>;
  const sources = (manifest['certification'] as { sources: ({ key: string } | string)[] }).sources;
  sourceKey = (sources.find((s) => typeof s !== 'string') as { key: string }).key;
  taxCode = somePack.taxes[0]!.code;
});

afterAll(async () => {
  await rm(dir, { recursive: true, force: true });
});

describe('a pack that declares a fiscalisation regime', () => {
  it('reads, cites its texts and names a format a brick of this release writes', () => {
    const block = declaring.documents.einvoice_fiscalisation!;
    expect(block.legal_reference.length).toBeGreaterThan(0);
    const keys = new Set(declaring.manifest.certification?.sources?.map((s) => (typeof s === 'string' ? s : s.key)));
    for (const source of [block.source, block.hash.source, block.qr?.source, block.submission.source, block.events?.source]) {
      if (source !== null && source !== undefined) expect(keys.has(source)).toBe(true);
    }
    expect(FISCALISATION_FORMATS[block.format]?.brick).toBeDefined();
    expect(block.submission.modes).toContain(block.submission.mode);
    expect(block.mandatory_from.length).toBeGreaterThan(0);
  });

  it('says which fields the hash covers for every kind of record a brick writes', () => {
    const fields = declaring.documents.einvoice_fiscalisation!.hash.fields;
    expect((fields['*'] ?? fields['alta'] ?? []).length).toBeGreaterThan(0);
  });

  it('is a block no other pack is made to carry: absent reads as no regime', () => {
    const silent = packWhere('declares no fiscalisation regime', (pack) => pack.documents.einvoice_fiscalisation === null);
    expect(silent.documents.einvoice_fiscalisation).toBeNull();
  });
});

describe('the schema of einvoicing.fiscalisation', () => {
  it('accepts a regime with one date, normalised into a list and a hash list for every kind', async () => {
    const pack = await readPack(await withRegime(regime()), dir);
    const block = pack.documents.einvoice_fiscalisation!;
    expect(block.mandatory_from).toEqual([{ who: null, from: '2030-01-01' }]);
    expect(block.hash.fields).toEqual({ '*': ['number', 'date', 'total', 'previous'] });
    expect(block.submission).toMatchObject({ mode: 'batch', modes: ['batch', 'none'], batch_max: 50 });
    expect(block.tax_attributes).toEqual({ [taxCode]: { invented_key: 'X1' } });
  });

  it('accepts a date per category of taxpayer, and a hash list per kind of record', async () => {
    const pack = await readPack(
      await withRegime({
        ...regime(),
        mandatory_from: [{ who: 'large', from: '2030-01-01' }, { who: 'others', from: '2031-01-01' }],
        hash: { algorithm: 'SHA-512', separator: '&', fields: { alta: ['a', 'b'], anulacion: ['c'] } },
      }),
      dir,
    );
    expect(pack.documents.einvoice_fiscalisation!.mandatory_from).toHaveLength(2);
    expect(pack.documents.einvoice_fiscalisation!.hash.fields).toEqual({ alta: ['a', 'b'], anulacion: ['c'] });
  });

  it('refuses a regime that cites no text, or a text the register does not carry', async () => {
    const { legal_reference: _l, ...uncited } = regime();
    expect(await refusal(uncited)).toMatch(/missing "legal_reference"/);
    const { source: _s, ...unsourced } = regime();
    expect(await refusal(unsourced)).toMatch(/missing "source"/);
    expect(await refusal({ ...regime(), source: 'no-such-text' })).toMatch(/names the source no-such-text/);
    expect(await refusal({ ...regime(), hash: { ...(regime()['hash'] as object), source: 'no-such-text' } })).toMatch(
      /einvoicing\.fiscalisation\.hash: names the source no-such-text/,
    );
  });

  it('refuses a format that is not a name, a day that does not exist, and a date that is not one', async () => {
    expect(await refusal({ ...regime(), format: 'Invented Chain!' })).toMatch(/format: does not match/);
    expect(await refusal({ ...regime(), mandatory_from: '2030-02-30' })).toMatch(/2030-02-30 is not a day of the calendar/);
    expect(await refusal({ ...regime(), mandatory_from: 'next year' })).toMatch(/mandatory_from: is neither/);
  });

  it('refuses what one field cannot know of another', async () => {
    const base = regime();
    expect(await refusal({ ...base, submission: { mode: 'realtime', modes: ['batch'] } })).toMatch(/submission\.modes does not list/);
    expect(await refusal({ ...base, qr: { ...(base['qr'] as object), size_mm: { min: 40, max: 30 } } })).toMatch(/min 40 is above max 30/);
    expect(await refusal({ ...base, submission: { mode: 'realtime', batch_max: 10 } })).toMatch(/batch is not a mode this regime allows/);
    expect(await refusal({ ...base, mention: [{ text: 'x', modes: ['realtime'] }] })).toMatch(/names realtime, which submission\.modes does not list/);
    expect(await refusal({ ...base, tax_attributes: { 'NO-SUCH-TAX': { k: 'v' } } })).toMatch(/NO-SUCH-TAX is not a tax of this pack/);
    expect(
      await refusal({ ...base, hash: { algorithm: 'SHA-256', separator: '&', fields: ['a', 'a'] } }),
    ).toMatch(/names a twice/);
  });

  it('refuses a hash without its separator, an unknown digest and an unknown field', async () => {
    expect(await refusal({ ...regime(), hash: { algorithm: 'SHA-256', fields: ['a'] } })).toMatch(/missing "separator"/);
    expect(await refusal({ ...regime(), hash: { algorithm: 'MD5', separator: '&', fields: ['a'] } })).toMatch(/not one of/);
    expect(await refusal({ ...regime(), comment: 'a remark' })).toMatch(/unknown field "comment"/);
  });
});
