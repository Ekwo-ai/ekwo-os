/**
 * The policies of `assets` ask once per statement
 * (`20261109155512_assets_policies_ask_once.sql`): the same rows for the same callers before and after the
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

/**
 * Two assets with their schedules, one of them disposed of. The accounts are
 * the first of each type in the company's chart, so no country is named.
 */
async function fill(db: PGlite, companyId: string): Promise<void> {
  const assets = (
    await db.query<{ id: string }>(
      `insert into fixed_assets.fixed_assets (company_id, code, name, acquisition_date, cost, duration_months,
                                              asset_account_id, depreciation_account_id, expense_account_id)
       select $1, x.code, x.name, date '2026-01-01', 3600, 36,
              (select id from accounts where company_id = $1 and account_type = 'asset_fixed' order by code limit 1),
              (select id from accounts where company_id = $1 and account_type = 'asset_fixed' order by code desc limit 1),
              (select id from accounts where company_id = $1 and account_type = 'expense_depreciation' order by code limit 1)
         from (values ('IT-01', 'Laptop'), ('IT-02', 'Screen')) as x(code, name)
       returning (select fixed_assets.generate_schedule(id)), id`,
      [companyId],
    )
  ).rows;
  await db.query(
    `insert into fixed_assets.disposals (asset_id, company_id, disposal_date, cost, accumulated, net_book_value, result)
     values ($1, $2, date '2026-12-31', 3600, 1200, 2400, 0)`,
    [assets[1]!.id, companyId],
  );
}

let proof: PolicyProof;

beforeAll(async () => {
  proof = await provePolicyRewrite({
    module: 'assets',
    schema: 'fixed_assets',
    migration: '20261109155512_assets_policies_ask_once.sql',
    fill,
  });
}, 120_000);

afterAll(async () => {
  await proof.db.close();
});

describe('the policies of assets, asked once per statement', () => {
  it('let every caller read and write exactly the rows it could before', () => {
    expect(proof.after).toEqual(proof.before);
  });

  it('give the member its rows, and the others what they are owed', () => {
    expectEachCallerInItsPlace(proof, ['fixed_assets.fixed_assets', 'fixed_assets.depreciation_lines', 'fixed_assets.disposals']);
  });

  it('evaluate the policy as an InitPlan, not a filter on each row', () => {
    expectPoliciesAskedOnce(proof);
  });
});
