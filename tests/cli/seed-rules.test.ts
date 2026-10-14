/**
 * Re-applying the seeds leaves a statement with the rules its pack declares,
 * and only those.
 *
 * `ekwo migrate` re-applies every seed. A release that turns a line into a
 * total, or drops one of its ranges, stops declaring a rule; an installation
 * that upgraded must lose it too, or the accounts it catches land on a line
 * that only adds up its children, and leave the statement.
 */

import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { applyMigrations, applySeeds, listMigrations, type SqlClient } from '../../packages/cli/src/index.js';
import { emptyDatabase, migrationsPath, seedPath } from './helpers.js';

let db: SqlClient;

beforeEach(async () => {
  ({ db } = await emptyDatabase());
  await applyMigrations(db, await listMigrations(migrationsPath));
  await applySeeds(db, seedPath);
});

afterEach(async () => {
  await db.close().catch(() => {});
});

type Rule = { statement_code: string; line_code: string; sequence: number };

const allRules = async (): Promise<string[]> =>
  (
    await db.query<Rule>(
      `select statement_code, line_code, sequence from statement_line_rules
        order by statement_code, line_code, sequence`,
    )
  ).map((r) => `${r.statement_code}|${r.line_code}|${r.sequence}`);

describe('re-applying the seeds', () => {
  it('drops a rule the pack no longer declares, on a total line and on a detail line', async () => {
    const declared = await allRules();
    expect(declared.length).toBeGreaterThan(0);

    // A total line, as a release may leave it: still carrying a rule from
    // before it became a total.
    const [total] = await db.query<{ statement_code: string; code: string }>(
      `select statement_code, code from statement_line_templates
        where is_total order by statement_code, code limit 1`,
    );
    // A detail line that keeps its rules, with one more the pack never declared.
    const [detail] = await db.query<Rule>(
      `select statement_code, line_code, max(sequence) as sequence from statement_line_rules
        group by statement_code, line_code order by statement_code, line_code limit 1`,
    );
    expect(total).toBeDefined();
    expect(detail).toBeDefined();

    await db.query(
      `insert into statement_line_rules (statement_code, line_code, sequence, rule_kind, code_from)
       values ($1, $2, 10, 'code_prefix', '9'), ($3, $4, $5, 'code_prefix', '9')`,
      [total!.statement_code, total!.code, detail!.statement_code, detail!.line_code, Number(detail!.sequence) + 1000],
    );
    expect(await allRules()).toHaveLength(declared.length + 2);

    await applySeeds(db, seedPath);

    expect(await allRules()).toEqual(declared);
  });

  it('changes nothing in an installation that is up to date', async () => {
    const before = await allRules();
    await applySeeds(db, seedPath);
    expect(await allRules()).toEqual(before);
  });
});
