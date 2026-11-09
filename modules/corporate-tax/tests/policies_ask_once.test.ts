/**
 * The policies of `tax` ask once per statement
 * (`20261109160318_tax_policies_ask_once.sql`): the same rows for the same callers before and after the
 * rewrite, and a plan that asks once. `tests/helpers/policy-proof.ts` is the
 * proof; this file gives it the rows.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import {
  expectEachCallerInItsPlace,
  expectPoliciesAskedOnce,
  provePolicyRewrite,
  type PolicyProof,
} from '../../../tests/helpers/policy-proof.js';
import { asUser, one } from '../../../tests/helpers/db.js';
import { newCompany } from '../../../tests/helpers/factory.js';
import { allPacks } from '../../../tests/helpers/packs.js';
import { earn, taxPacks } from './helpers.js';
const pack = taxPacks(allPacks)[0]!;
const YEAR = { name: 'Year 2025', start: '2025-01-01', end: '2025-12-31' };

/** A company of the first pack that carries the module's section, its year 2025 open. */
function company(db: PGlite, name: string): Promise<{ companyId: string; ownerId: string }> {
  return newCompany(db, { country: pack.manifest.country, name, fiscalYear: YEAR });
}

/**
 * A profit booked, a loss carried in, a prepayment, an adjustment by amount
 * and a computation recorded and finalised, which uses the loss — the module's tables as
 * its own tests write them. The rule of the adjustment is the pack's first.
 */
async function fill(db: PGlite, companyId: string, ownerId: string): Promise<void> {
  const { id: yearId } = await one<{ id: string }>(db, `select id from fiscal_years where company_id = $1`, [companyId]);
  await earn(db, pack, companyId, '2025-06-30', '5000.00');
  await asUser(db, ownerId, async () => {
    await db.query(`insert into tax.losses (company_id, origin_period_end, amount) values ($1, date '2023-12-31', 1000)`, [companyId]);
    await db.query(`insert into tax.prepayments (company_id, fiscal_year_id, paid_on, amount) values ($1, $2, date '2025-04-01', 100)`, [
      companyId,
      yearId,
    ]);
    await db.query(
      `insert into tax.adjustments (company_id, fiscal_year_id, rule_code, amount)
       select $1, $2, t.code, 10
         from tax.adjustment_rule_templates t join companies c on c.id = $1 and t.country = c.fiscal_country
        order by t.code limit 1`,
      [companyId, yearId],
    );
    const { id } = await one<{ id: string }>(db, `select tax.record_computation($1, $2) as id`, [companyId, yearId]);
    await db.query(`select tax.finalise_computation($1)`, [id]);
  });
}

let proof: PolicyProof;

beforeAll(async () => {
  proof = await provePolicyRewrite({
    module: 'tax',
    schema: 'tax',
    migration: '20261109160318_tax_policies_ask_once.sql',
    fill,
    company,
  });
}, 120_000);

afterAll(async () => {
  await proof.db.close();
});

describe('the policies of tax, asked once per statement', () => {
  it('let every caller read and write exactly the rows it could before', () => {
    expect(proof.after).toEqual(proof.before);
  });

  it('give the member its rows, and the others what they are owed', () => {
    expectEachCallerInItsPlace(proof, ['tax.computations', 'tax.computation_lines', 'tax.losses', 'tax.loss_uses', 'tax.prepayments', 'tax.adjustments']);
  });

  it('evaluate the policy as an InitPlan, not a filter on each row', () => {
    expectPoliciesAskedOnce(proof);
  });
});
