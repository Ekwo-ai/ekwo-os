/**
 * The policies of `einvoicing` ask once per statement
 * (`20261109155021_einvoicing_policies_ask_once.sql`): the same rows for the same callers before and after the
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
import { issueEinvoice, type EinvoiceTransport } from '@ekwo-ai/core';
import { packIssuing, sale, seller, type Seller } from './helpers.js';
const pack = packIssuing('peppol-bis-3');
const sellers = new Map<string, Seller>();

/** A seller of the module's own tests, the module left for the proof to turn on. */
async function company(db: PGlite, name: string): Promise<Seller> {
  const made = await seller(db, pack, name, { enable: false });
  sellers.set(made.companyId, made);
  return made;
}

/** A posted sale, its file issued and sent through a transport that answers, as an accountant does it. */
async function fill(db: PGlite, companyId: string): Promise<void> {
  const s = sellers.get(companyId)!;
  const documentId = await sale(db, s);
  const transport: EinvoiceTransport = {
    channel: 'service',
    service: 'Scripted access point',
    async send() {
      return { reference: `AP-${companyId.slice(0, 8)}` };
    },
    async status() {
      return { state: 'submitted' };
    },
    async receive() {
      return [];
    },
    async lookup() {
      return { reachable: null };
    },
  };
  await issueEinvoice(s.backend, { document_id: documentId, send: true }, transport);
}

let proof: PolicyProof;

beforeAll(async () => {
  proof = await provePolicyRewrite({
    module: 'einvoicing',
    schema: 'einvoicing',
    migration: '20261109155021_einvoicing_policies_ask_once.sql',
    fill,
    company,
  });
}, 120_000);

afterAll(async () => {
  await proof.db.close();
});

describe('the policies of einvoicing, asked once per statement', () => {
  it('let every caller read and write exactly the rows it could before', () => {
    expect(proof.after).toEqual(proof.before);
  });

  it('give the member its rows, and the others what they are owed', () => {
    expectEachCallerInItsPlace(proof, ['einvoicing.issues', 'einvoicing.transmissions', 'einvoicing.transmission_events']);
  });

  it('evaluate the policy as an InitPlan, not a filter on each row', () => {
    expectPoliciesAskedOnce(proof);
  });
});
