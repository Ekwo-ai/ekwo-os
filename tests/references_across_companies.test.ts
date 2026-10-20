/**
 * A reference that already crosses companies stops the migration before it
 * changes anything (decision 0065).
 *
 * `20261007113412` turns every reference by id alone between two tables that
 * hold a company's rows into a composite key with the company, and validates
 * it over every row. An installation whose rows were written before may hold
 * one that names a row of another company: the migration has to say so, by
 * table, column and count, with no value of the rows in its words — and
 * leave the database as it found it. These books are written by the schema as
 * it was, the reference is planted there, and the migration is run on them.
 */

import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { freshDatabase, one, repoRoot } from './helpers/db.js';
import { newCompany, newContact } from './helpers/factory.js';

const MIGRATION = '20261007113412_a_tenant_measures_nothing_of_another.sql';
const LATER = [
  '20261007160000_a_person_joins_a_company_of_their_own_accord.sql',
  // Replaces the guard of a posted line with the body of MIGRATION, which
  // calls a function MIGRATION defines.
  '20261018180416_a_line_that_names_nobody_is_named_once.sql',
  // Both make their new references composite with scope_references_to_company(),
  // which MIGRATION defines.
  '20261018210000_several_lines_settle_together_and_a_difference_is_booked.sql',
  '20261018210500_a_line_is_left_unnamed_and_a_crowded_name_is_doubted.sql',
  // Reads open_items() as 20261018180416 left it, and makes its references
  // composite with scope_references_to_company().
  '20261018230000_sure_pairs_are_matched_in_one_gesture.sql',
  // Replaces the guards of a posted line and of an issued document with the
  // bodies of MIGRATION, and its record names contacts by composite keys.
  '20261019090000_two_contacts_of_one_company_are_merged.sql',
  // Replaces merge_contacts(), which answers a row of contact_merges, and
  // contact_candidates(), which the migration before it defined.
  '20261019104812_the_contacts_that_are_probably_one_party.sql',
  // Redefines merge_contacts(), which returns the record 20261019090000
  // creates.
  '20261019130000_an_analytic_value_is_entered_on_the_line.sql',
  // Replaces post_document() as 20261019130000 left it, which asks the
  // analytic axes that migration defines.
  '20261020072000_a_tax_computed_inside_its_own_base.sql',
  // Republishes entries_guard_posted() as this migration left it, which asks
  // assert_writes_into_known_company().
  '20261020160000_a_company_numbers_its_documents_its_own_way.sql',
];

let db: PGlite;
let sql: string;
let mine: string;
let theirs: string;
let planted: { contact: string; account: string };

beforeAll(async () => {
  // The modules scope their own schemas after this migration, so they are
  // left out with it.
  db = await freshDatabase({ withoutMigrations: [MIGRATION, ...LATER], modules: false });
  sql = await readFile(join(repoRoot, 'supabase', 'migrations', MIGRATION), 'utf8');
  const country = (await one<{ country: string }>(db, `select country from chart_templates where is_default order by country limit 1`)).country;
  mine = (await newCompany(db, { country, name: 'Mine' })).companyId;
  theirs = (await newCompany(db, { country, name: 'Theirs' })).companyId;
  const contact = await newContact(db, mine);
  const account = (await one<{ id: string }>(db, `select id from accounts where company_id = $1 order by code limit 1`, [theirs])).id;
  // A customer of mine and my company itself, each with a receivable account
  // of theirs: both accepted by the keys of the time.
  await db.query(`update contacts set receivable_account_id = $2 where id = $1`, [contact, account]);
  await db.query(`update companies set receivable_account_id = $2 where id = $1`, [mine, account]);
  planted = { contact, account };
}, 300_000);

afterAll(async () => {
  await db.close();
});

describe('a reference that crosses companies, written before the keys held the company', () => {
  it('stops the migration with one named error that lists every table and column, and how many rows', async () => {
    const said = await db.exec(sql).then(
      () => 'the migration ran',
      (error: Error) => error.message,
    );
    expect(said).toMatch(/^reference_across_companies: 2 rows of schema public name a row of another company/);
    expect(said).toContain('public.contacts.receivable_account_id names public.accounts of another company in 1 row');
    expect(said).toContain('public.companies.receivable_account_id names public.accounts of another company in 1 row');
    expect(said).toContain('Nothing was changed');
    // No value of any row.
    for (const value of [mine, theirs, planted.contact, planted.account]) expect(said).not.toContain(value);
  });

  it('gives the remedy beside it', async () => {
    try {
      await db.exec(sql);
      throw new Error('the migration ran');
    } catch (error) {
      expect((error as Error & { hint?: string }).hint).toMatch(/^Point each of these columns at a row of its own row's company, or empty it/);
    }
  });

  it('leaves the database as it found it', async () => {
    const after = await one<{ sequence: boolean; single: boolean; composite: boolean }>(
      db,
      `select exists (select 1 from pg_attribute where attrelid = 'audit_log'::regclass and attname = 'sequence') as sequence,
              exists (select 1 from pg_constraint where conname = 'contacts_receivable_account_id_fkey') as single,
              exists (select 1 from pg_constraint where conname = 'contacts_receivable_account_id_company_id_fkey') as composite`,
    );
    expect(after).toEqual({ sequence: false, single: true, composite: false });
  });

  it('runs once the rows name their own company’s', async () => {
    const own = (await one<{ id: string }>(db, `select id from accounts where company_id = $1 order by code limit 1`, [mine])).id;
    await db.query(`update contacts set receivable_account_id = $2 where id = $1`, [planted.contact, own]);
    await db.query(`update companies set receivable_account_id = null where id = $1`, [mine]);
    await db.exec(sql);
    const keys = await one<{ contacts: boolean; companies: boolean }>(
      db,
      `select exists (select 1 from pg_constraint where conname = 'contacts_receivable_account_id_company_id_fkey') as contacts,
              exists (select 1 from pg_constraint where conname = 'companies_receivable_account_id_company_id_fkey') as companies`,
    );
    expect(keys).toEqual({ contacts: true, companies: true });
  });
});
