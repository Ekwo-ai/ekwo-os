/**
 * Two contacts of one company proposed as one party (decision 0075) and
 * merged through the tools (decision 0074).
 *
 * The tools are thin calls on `suggest_duplicate_contacts()` and
 * `merge_contacts()`: the first answers the pairs with the two names beside
 * the ids, the second the record of the merge and the two contacts as they
 * stand, and a refusal is the database's own sentence with the hint that says
 * what to do.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { explain, readTools, writeTools, type Backend } from '../../packages/mcp/src/index.js';
import { freshDatabase } from '../helpers/db.js';
import { newCompany, newContact, type Fixture } from '../helpers/factory.js';
import { somePack } from '../helpers/packs.js';
import { backendFor, record } from './helpers.js';

const pack = somePack;

let db: PGlite;
let fx: Fixture;
let backend: Backend;

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db, { country: pack.manifest.country, name: 'Merging tools' });
  backend = backendFor(db, fx.ownerId);
}, 180_000);

afterAll(async () => {
  await db.close();
});

describe('suggest_duplicate_contacts', () => {
  it('proposes the two spellings of one party, with the one to keep and the evidence', async () => {
    const older = await newContact(db, fx.companyId, { country: pack.manifest.country, name: 'Pemberton Ashdown' });
    const newer = await newContact(db, fx.companyId, { country: pack.manifest.country, name: 'Ashdown Pemberton' });
    await db.query(`update contacts set created_at = now() - interval '1 day' where id = $1`, [older]);

    const answer = record(await readTools.suggestDuplicateContacts(backend, { company_id: fx.companyId }));
    expect(answer['pairs']).toEqual([
      expect.objectContaining({
        keep_id: older,
        keep_name: 'Pemberton Ashdown',
        absorb_id: newer,
        absorb_name: 'Ashdown Pemberton',
        score: 0.9,
        evidence: ['name'],
        proposed_name: 'Pemberton Ashdown',
      }),
    ]);
    expect(answer['count']).toBe(1);

    await writeTools.mergeContacts(backend, { keep_contact_id: older, absorb_contact_id: newer });
    expect(record(await readTools.suggestDuplicateContacts(backend, { company_id: fx.companyId }))['pairs']).toEqual([]);
  });
});

describe('merge_contacts', () => {
  it('retires the absorbed contact into the kept one, and says what moved', async () => {
    const keep = await newContact(db, fx.companyId, { country: pack.manifest.country, name: 'Marlow Jane' });
    const absorb = await newContact(db, fx.companyId, { country: pack.manifest.country, name: 'Jane Marlow', vat: 'TEST-VAT-0042' });

    const answer = record(await writeTools.mergeContacts(backend, { keep_contact_id: keep, absorb_contact_id: absorb }));
    expect(record(answer['merge'])).toMatchObject({ kept_id: keep, absorbed_id: absorb, filled: ['vat_number'] });
    expect(record(answer['kept'])).toMatchObject({ id: keep, vat_number: 'TEST-VAT-0042', active: true, merged_into: null });
    expect(record(answer['absorbed'])).toMatchObject({ id: absorb, active: false, merged_into: keep });

    const refusal = await writeTools.mergeContacts(backend, { keep_contact_id: keep, absorb_contact_id: absorb }).then(
      () => undefined,
      (error: Error) => explain(error.message),
    );
    expect(refusal?.message).toMatch(/^already_merged\b/);
    expect(refusal?.hint).toMatch(/merged before/);
  });
});
