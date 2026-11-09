/**
 * The policies of `contracts` ask once per statement
 * (`20261109154842_contracts_policies_ask_once.sql`): the same rows for the same callers before and after the
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
import { newContact } from '../../../tests/helpers/factory.js';
/** A signed contract, its schedule, the invoice it made, an amendment and a template — through the module's own functions. */
async function fill(db: PGlite, companyId: string, ownerId: string): Promise<void> {
  const customer = await newContact(db, companyId, { name: 'A customer', type: 'customer' });
  const { code: tax } = await one<{ code: string }>(
    db,
    `select code from taxes
      where company_id = $1 and applies_to in ('sale', 'both') and amount_type = 'percent' and active
        and valid_from <= date '2026-01-01' and (valid_to is null or valid_to >= date '2026-12-31')
      order by amount desc, sequence, code limit 1`,
    [companyId],
  );
  await asUser(db, ownerId, async () => {
    const { id: contractId } = await one<{ id: string }>(db, `select id from contracts.upsert_contract($1, 'CTR-0001', $2)`, [
      companyId,
      { contact_id: customer, name: 'Support', kind: 'subscription', direction: 'sale', starts_on: '2026-01-31', state: 'signed', signed_on: '2026-01-20' },
    ]);
    const { id: scheduleId } = await one<{ id: string }>(db, `select id from contracts.upsert_schedule($1, $2, null, $3)`, [
      companyId,
      contractId,
      { name: 'Hosting', unit_price: '500', tax_code: tax, frequency: 'monthly', next_on: '2026-01-31' },
    ]);
    await db.query(`select * from contracts.issue_due($1, date '2026-01-31')`, [companyId]);
    await db.query(`select * from contracts.amend($1, $2, 'New price', date '2026-05-01', $3)`, [
      companyId,
      contractId,
      { schedules: { [scheduleId]: { unit_price: '550' } } },
    ]);
    await db.query(
      `insert into contracts.templates (company_id, name, format, html) values ($1, 'Support agreement', 'html', '<p>Between us.</p>')`,
      [companyId],
    );
  });
}

let proof: PolicyProof;

beforeAll(async () => {
  proof = await provePolicyRewrite({
    module: 'contracts',
    schema: 'contracts',
    migration: '20261109154842_contracts_policies_ask_once.sql',
    fill,
  });
}, 120_000);

afterAll(async () => {
  await proof.db.close();
});

describe('the policies of contracts, asked once per statement', () => {
  it('let every caller read and write exactly the rows it could before', () => {
    expect(proof.after).toEqual(proof.before);
  });

  it('give the member its rows, and the others what they are owed', () => {
    expectEachCallerInItsPlace(proof, ['contracts.contracts', 'contracts.schedules', 'contracts.issues', 'contracts.amendments', 'contracts.templates']);
  });

  it('evaluate the policy as an InitPlan, not a filter on each row', () => {
    expectPoliciesAskedOnce(proof);
  });
});
