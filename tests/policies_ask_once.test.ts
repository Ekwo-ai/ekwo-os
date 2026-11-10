import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import {
  inventory,
  parseNodeTree,
  policyInventory,
  policyKey,
  type PolicyRow,
} from '../scripts/inventory-policies.mjs';
import { freshDatabase } from './helpers/db.js';

/**
 * No row level security policy asks who the caller is once per row.
 *
 * A policy that calls `has_capability(company_id, …)` or `module_enabled(company_id, …)`
 * with a column of the row runs the function for every row a scan visits:
 * neither is inlined, and `stable` does not make Postgres remember an answer.
 * The socle found it on its own tables (`20260918141627_a_policy_asks_once.sql`),
 * the `crm` module on its own, and the six other modules carried it too; each
 * now asks in a sub-select that depends on no column, run once per statement.
 *
 * The rule is read by `scripts/inventory-policies.mjs`, the inventory replayed
 * before every wave, so the inventory and this test cannot disagree: the
 * `using` of every policy of the socle and of every module is `once`. `with
 * check` is not held: it is evaluated once per row written, which is what a
 * check is for.
 *
 * Two policies of the socle still ask per row, and only these. The inventory
 * of 9 November 2026 found seventeen; `20261110124117_the_socle_policies_ask_once.sql`
 * rewrote fifteen with the rights each grants unchanged
 * (`tests/socle_policies_ask_once.test.ts` is the proof). The two left are
 * the policies of `attachments` that choose the capability a row needs:
 *
 *     case when entity_type = 'tax_filing' or attachment_is_filing_deposit_file(id)
 *          then company_id = any ((select companies_with_capability('filings.…'))::uuid[])
 *          else company_id = any ((select companies_with_capability('documents.…'))::uuid[]) end
 *
 * Each branch already asks once; the condition does not.
 * `attachment_is_filing_deposit_file(id)` is security definer and answers
 * about one attachment, on purpose — the policy asks it for callers who may
 * not read the deposits (decision 0065) — and it has no set-returning
 * counterpart. Asking it as a sub-select of the policy would read the
 * deposits as the caller, which is a different right, so they stay until a
 * change gives that function its "attachments where" form.
 *
 * The list only shrinks: a policy that comes to ask once has to leave it, and
 * a policy that is not on it is refused.
 */
const STILL_PER_ROW = new Set([
  'ekwo.attachments attachments_select',
  'ekwo.attachments attachments_write',
]);

/** The policies whose `using` asks per row and that the list does not allow, with the calls behind each. */
function refused(rows: PolicyRow[], allowed: Set<string>): string[] {
  return rows
    .filter((row) => row.using.verdict === 'per row' && !allowed.has(policyKey(row)))
    .map((row) => `${policyKey(row)}: ${row.using.perRow.join(', ')}`);
}

describe('every policy of the socle and of the modules', () => {
  let rows: PolicyRow[];

  beforeAll(async () => {
    rows = await inventory();
  }, 120_000);

  it('is read, the socle and every module', () => {
    const schemas = new Set(rows.map((row) => row.schema));
    for (const schema of ['ekwo', 'budgets', 'consolidation', 'contracts', 'crm', 'einvoicing', 'fixed_assets', 'tax']) {
      expect(schemas.has(schema), schema).toBe(true);
    }
    expect(rows.filter((row) => row.using.verdict === 'once').length).toBeGreaterThan(100);
  });

  it('asks who the caller is once per statement, not once per row', () => {
    expect(refused(rows, STILL_PER_ROW), 'a policy whose using calls a function with a column of the row').toEqual([]);
  });

  it('keeps on the list of the socle only the policies that still ask per row', () => {
    const verdicts = new Map(rows.map((row) => [policyKey(row), row.using.verdict]));
    const stale = [...STILL_PER_ROW]
      .filter((key) => verdicts.get(key) !== 'per row')
      .map((key) => `${key}: ${verdicts.get(key) ?? 'no such policy'}`);
    expect(stale, 'remove these policies from STILL_PER_ROW: they ask once now, or are gone').toEqual([]);
  });

  it('allows no module on the list', () => {
    expect([...STILL_PER_ROW].filter((key) => !key.startsWith('ekwo.'))).toEqual([]);
  });
});

describe('the inventory, on policies written to break the rule', () => {
  let db: PGlite;
  let rows: PolicyRow[];

  beforeAll(async () => {
    db = await freshDatabase({ seed: false, modules: false });
    await db.exec(`
      create schema broken;
      create table broken.items (id uuid primary key, company_id uuid not null, parent_id uuid);
      alter table broken.items enable row level security;
      -- per row: a column of the row, as it is and through a cast
      create policy per_row on broken.items for select
        using (has_capability(company_id, 'entries.read'));
      create policy per_row_cast on broken.items for update
        using (is_company_member((company_id::text)::uuid));
      -- per row: a sub-select that refers to the row runs again for each
      create policy per_row_correlated on broken.items for delete
        using (exists (select 1 from companies c where c.id = items.company_id and has_capability(c.id, 'entries.write')));
      -- once: the same question in a sub-select that depends on no column
      create policy once on broken.items for select
        using (company_id = any ((select companies_with_capability('entries.read'))::uuid[]));
      -- once in using; with check is read and not held
      create policy check_only on broken.items for insert
        with check (has_capability(company_id, 'entries.write'));
      -- once: a call with no column at all
      create policy bare on broken.items for select using (is_known_caller());
    `);
    rows = (await policyInventory(db)).filter((row) => row.schema === 'broken');
  }, 120_000);

  afterAll(async () => {
    await db.close();
  });

  it('reads each the way Postgres evaluates it', () => {
    const verdicts = Object.fromEntries(rows.map((row) => [row.policy, [row.using.verdict, row.withCheck.verdict]]));
    expect(verdicts).toEqual({
      per_row: ['per row', '-'],
      per_row_cast: ['per row', '-'],
      per_row_correlated: ['per row', '-'],
      once: ['once', '-'],
      check_only: ['-', 'per row'],
      bare: ['once', '-'],
    });
    const named = Object.fromEntries(rows.map((row) => [row.policy, row.using.perRow]));
    expect(named['per_row']).toEqual(['has_capability(company_id)']);
    expect(named['per_row_correlated']).toEqual(['has_capability(…) in a sub-select on the row']);
    expect(rows.find((row) => row.policy === 'bare')!.using.bare).toEqual(['is_known_caller()']);
  });

  it('is refused by the rule, policy by policy, and the one that asks once is not', () => {
    expect(refused(rows, STILL_PER_ROW).sort()).toEqual([
      'broken.items per_row: has_capability(company_id)',
      'broken.items per_row_cast: is_company_member(…)',
      'broken.items per_row_correlated: has_capability(…) in a sub-select on the row',
    ]);
  });

  it('reads a tree that holds a constant, a null and a quoted name', () => {
    expect(
      parseNodeTree('{FUNCEXPR :funcid 17000 :args ({VAR :varno 1 :varattno 2 :varlevelsup 0} {CONST :constvalue 4 [ 1 0 0 0 ]}) :alias <> :colnames ("a b" "c\\"d")}'),
    ).toEqual({
      node: 'FUNCEXPR',
      funcid: '17000',
      args: [
        { node: 'VAR', varno: '1', varattno: '2', varlevelsup: '0' },
        { node: 'CONST', constvalue: '4' },
      ],
      alias: null,
      colnames: ['a b', 'c"d'],
    });
  });
});
