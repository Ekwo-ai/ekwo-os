/**
 * The policies of `consolidation` ask once per statement
 * (`20261109154107_consolidation_policies_ask_once.sql`): the same rows for the same callers before and after the
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
import { newCompany } from '../../../tests/helpers/factory.js';
/** A group, a member company in it, and a closing rate. */
async function fill(db: PGlite, companyId: string): Promise<void> {
  const member = await newCompany(db, { name: 'Member SRL' });
  const [group] = (
    await db.query<{ id: string }>(
      `insert into consolidation.groups (company_id, code, name, currency_code)
       select id, 'main', 'Main group', currency_code from companies where id = $1
       returning id`,
      [companyId],
    )
  ).rows;
  await db.query(
    `insert into consolidation.members (group_id, company_id, member_company_id, method, ownership_rate, entered_on)
     values ($1, $2, $3, 'full', 80, date '2026-01-01')`,
    [group!.id, companyId, member.companyId],
  );
  await db.query(
    `insert into consolidation.rates (group_id, company_id, currency_code, period_from, period_to, closing_rate)
     select $1, $2, c.code, date '2026-01-01', date '2026-12-31', 1.1
       from currencies c where c.code <> (select currency_code from companies where id = $2) order by c.code limit 1`,
    [group!.id, companyId],
  );
}

let proof: PolicyProof;

beforeAll(async () => {
  proof = await provePolicyRewrite({
    module: 'consolidation',
    schema: 'consolidation',
    migration: '20261109154107_consolidation_policies_ask_once.sql',
    fill,
  });
}, 120_000);

afterAll(async () => {
  await proof.db.close();
});

describe('the policies of consolidation, asked once per statement', () => {
  it('let every caller read and write exactly the rows it could before', () => {
    expect(proof.after).toEqual(proof.before);
  });

  it('give the member its rows, and the others what they are owed', () => {
    expectEachCallerInItsPlace(proof, ['consolidation.groups', 'consolidation.members', 'consolidation.rates']);
  });

  it('evaluate the policy as an InitPlan, not a filter on each row', () => {
    expectPoliciesAskedOnce(proof);
  });
});
