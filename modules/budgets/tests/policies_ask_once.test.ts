/**
 * The policies of `budgets` ask once per statement
 * (`20261109153212_budgets_policies_ask_once.sql`): the same rows for the
 * same callers before and after the rewrite, and a plan that asks once.
 * `tests/helpers/policy-proof.ts` is the proof; this file gives it the rows.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import {
  expectEachCallerInItsPlace,
  expectPoliciesAskedOnce,
  provePolicyRewrite,
  type PolicyProof,
} from '../../../tests/helpers/policy-proof.js';

async function fill(db: PGlite, companyId: string): Promise<void> {
  const [budget] = (
    await db.query<{ id: string }>(
      `insert into budgets.budgets (company_id, fiscal_year_id, code, name, state)
       values ($1, (select id from fiscal_years where company_id = $1 limit 1), 'B2026', 'Budget 2026', 'approved'),
              ($1, null, 'DRAFT', 'A draft', 'draft')
       returning id`,
      [companyId],
    )
  ).rows;
  await db.query(
    `insert into budgets.lines (budget_id, company_id, account_id, period_start, period_end, amount)
     select $1, $2, a.id, date '2026-01-01', date '2026-12-31', 100
       from (select id from accounts where company_id = $2 order by code limit 3) a`,
    [budget!.id, companyId],
  );
}

let proof: PolicyProof;

beforeAll(async () => {
  proof = await provePolicyRewrite({
    module: 'budgets',
    schema: 'budgets',
    migration: '20261109153212_budgets_policies_ask_once.sql',
    fill,
  });
}, 120_000);

afterAll(async () => {
  await proof.db.close();
});

describe('the policies of budgets, asked once per statement', () => {
  it('let every caller read and write exactly the rows it could before', () => {
    expect(proof.after).toEqual(proof.before);
  });

  it('give the member its rows, and the others what they are owed', () => {
    expectEachCallerInItsPlace(proof, ['budgets.budgets', 'budgets.lines']);
  });

  it('evaluate the policy as an InitPlan, not a filter on each row', () => {
    expectPoliciesAskedOnce(proof);
  });
});
