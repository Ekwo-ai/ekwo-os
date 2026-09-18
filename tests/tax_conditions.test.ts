/**
 * What an exemption depends on, said as data and never as a test.
 *
 * Three exemptions of the first pack of a country with no value added tax turn
 * on an answer that is not in the books: a sale for resale is untaxed because
 * the seller holds a certificate the buyer signed, a sale of food is untaxed
 * unless it is hot or carbonated or alcoholic, and a seller collects in a State
 * only once a running total of sales into it has been crossed. A pack could
 * state the code a bookkeeper reaches for **once the answer is known** and
 * could not say what the question was, so a reader of the chart saw three
 * zero-rated codes and one long sentence each.
 *
 * `conditions` says what the question is. Four claims, in five tests, and none
 * of them names a country:
 *
 *   1. the vocabulary is the same list in the three places that write it down
 *      — the Postgres enum, the TypeScript constant and the pack schema — in
 *      the same order, which is what `tests/vat_codes.test.ts` already holds
 *      of the treatments beside it;
 *   2. nothing in it carries a value, an operator or an expression, which is
 *      the invariant that keeps it data: the words are bare and the article
 *      that sets a threshold or prescribes a certificate is the one the tax
 *      already cites;
 *   3. every condition a pack declares is a word of that vocabulary, and the
 *      tax that declares one cites the text it comes from;
 *   4. the column carries what the pack wrote, through the seed, into the
 *      database — and at least one pack writes something, or the claims above
 *      are checked against nothing.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { readSchema } from '../packages/cli/src/index.js';
import { TAX_CONDITIONS } from '../packages/core/src/types.js';
import { freshDatabase, rows } from './helpers/db.js';
import { allPacks, packsRoot } from './helpers/packs.js';

/** The enum of the pack schema, which is the third place the list is written. */
async function schemaConditions(): Promise<string[]> {
  const schema = await readSchema(packsRoot);
  const defs = (schema['$defs'] ?? {}) as Record<string, Record<string, unknown>>;
  const properties = (defs['tax']?.['properties'] ?? {}) as Record<string, Record<string, unknown>>;
  const items = (properties['conditions']?.['items'] ?? {}) as Record<string, unknown>;
  const values = items['enum'];
  if (!Array.isArray(values) || values.length === 0) {
    throw new Error('packs/schema/pack.1.json defines no tax condition');
  }
  return values as string[];
}

describe('what a tax turns on that the ledger cannot see', () => {
  let db: PGlite;

  beforeAll(async () => {
    db = await freshDatabase();
  }, 120_000);

  afterAll(async () => {
    await db.close();
  });

  it('is the same list in the database, in TypeScript and in the pack schema', async () => {
    const enumerated = (
      await rows<{ label: string }>(
        db,
        `select e.enumlabel as label from pg_enum e
           join pg_type t on t.oid = e.enumtypid
          where t.typname = 'tax_condition' order by e.enumsortorder`,
      )
    ).map((row) => row.label);

    expect(enumerated).toEqual([...TAX_CONDITIONS]);
    expect(await schemaConditions()).toEqual([...TAX_CONDITIONS]);
  });

  it('is a word and never a test', () => {
    // The whole point of the field. A pack that could carry the condition's
    // *value* — five hundred thousand dollars, a certificate number, a date —
    // would be a pack that evaluates, and this format has no field through
    // which a pack can run anything. So every word is a bare identifier: no
    // digit, no comparison, no separator a formula would need.
    for (const condition of TAX_CONDITIONS) {
      expect(condition, condition).toMatch(/^[a-z]+(_[a-z]+)*$/);
    }
  });

  it('is declared by at least one pack, or nothing above is checked', () => {
    const declared = allPacks.flatMap((pack) => pack.taxes.flatMap((tax) => tax.conditions));
    expect(declared.length).toBeGreaterThan(0);
  });

  it('is, wherever a pack declares one, a word of that vocabulary and a sourced rule', () => {
    for (const pack of allPacks) {
      for (const tax of pack.taxes) {
        for (const condition of tax.conditions) {
          expect(TAX_CONDITIONS as readonly string[], `${pack.slug} ${tax.code}`).toContain(
            condition,
          );
        }
        if (tax.conditions.length > 0) {
          // A condition says the answer is outside the books; the text that
          // says so is what makes it reviewable. `legal_reference` is required
          // on every tax anyway, and this states why it matters twice here.
          expect(tax.legal_reference, `${pack.slug} ${tax.code}`).toMatch(/\S/);
          expect(new Set(tax.conditions).size, `${pack.slug} ${tax.code}`).toBe(
            tax.conditions.length,
          );
        }
      }
    }
  });

  it('reaches the database exactly as the pack wrote it', async () => {
    // The seeds are applied by `freshDatabase`, so this compares the column
    // against the packs on disk, per country and per tax code.
    const stored = await rows<{ country: string; code: string; declared: string; empty: boolean }>(
      db,
      `select country, code, array_to_string(conditions, ',') as declared,
              conditions is null as empty
         from tax_templates order by country, code`,
    );
    const byKey = new Map(stored.map((row) => [`${row.country} ${row.code}`, row]));

    for (const pack of allPacks) {
      for (const tax of pack.taxes) {
        const key = `${pack.manifest.country} ${tax.code}`;
        expect(byKey.get(key)?.declared, key).toBe(tax.conditions.join(','));
        // A column that can be null is a column with two ways of saying
        // nothing, and this one says nothing by being the empty list.
        expect(byKey.get(key)?.empty, key).toBe(false);
      }
    }
  });
});
