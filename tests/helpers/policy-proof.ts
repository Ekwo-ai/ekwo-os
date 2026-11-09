/**
 * The proof a module gives when its policies are rewritten to ask once per
 * statement: the same rows, for the same callers, and a plan that asks once.
 *
 * A policy rewritten from `module_enabled(company_id, …) and
 * has_capability(company_id, …)` to `company_id = any ((select …))` must let
 * through exactly what it let through before. `provePolicyRewrite()` builds
 * the database without the module's rewriting migration, lets the module's
 * test write its fixtures, and records, for each caller and each table of the
 * module's schema that a policy ties to a company:
 *
 * - **read** — every row the caller selects, as text;
 * - **update** — the rows an `update … set company_id = company_id` reaches,
 *   or the error it raises;
 * - **delete** — the rows a `delete` reaches, or the error it raises.
 *
 * Every write is made inside a transaction that is rolled back, so the books
 * are the same before and after. Then it applies the migration to the same
 * database and records it all again. The two records are what the module's
 * test compares.
 *
 * The callers are the four the task of a policy is about: a member of the
 * company, a member of it without any capability of the module, a member of
 * another company with the module on, and a machine key of the company
 * carrying every capability of the module.
 *
 * `planOf()` is the second half: the plan of a read as a member, in which
 * `firstPolicyNodes()` finds how the policy is evaluated — an InitPlan once
 * per statement, or a filter calling the functions per row.
 */

import type { PGlite } from '@electric-sql/pglite';
import { expect } from 'vitest';
import { nodesOf } from '../../scripts/load/hot-paths.mjs';
import { asUser, freshDatabase, moduleMigrationFiles, one, replaySql, rows } from './db.js';
import { newCompany } from './factory.js';

export type Caller = { name: string; user: string } | { name: string; key: string };

/** What one caller reaches in one table. */
export interface Reach {
  read: string[];
  update: string[] | string;
  delete: string[] | string;
}

/** caller → `schema.table` → what it reaches. */
export type Record_ = Record<string, Record<string, Reach>>;

/**
 * Runs `fn` as `caller` inside one transaction, rolled back whatever happens:
 * a person through the claims of a session, a machine through `use_api_key()`.
 */
export async function asCaller<T>(db: PGlite, caller: Caller, fn: () => Promise<T>): Promise<T> {
  await db.query('begin');
  try {
    await db.query(`select set_config('ekwo.installing', '', true)`);
    if ('user' in caller) {
      await db.query(`select set_config('request.jwt.claims', $1, true)`, [
        JSON.stringify({ sub: caller.user, role: 'authenticated' }),
      ]);
      await db.exec('set local role authenticated');
    } else {
      await db.exec('set local role authenticated');
      await db.query('select * from use_api_key($1)', [caller.key]);
    }
    return await fn();
  } finally {
    await db.query('rollback');
  }
}

/** The tables of `schema` whose policies are about a company, with the columns of their primary key. */
async function companyTables(db: PGlite, schema: string): Promise<{ table: string; key: string[] }[]> {
  return rows<{ table: string; key: string[] }>(
    db,
    `select c.relname as table,
            coalesce((select array_agg(a.attname::text order by a.attnum)
                        from pg_index i
                        join pg_attribute a on a.attrelid = i.indrelid and a.attnum = any (i.indkey)
                       where i.indrelid = c.oid and i.indisprimary), '{}') as key
       from pg_class c
       join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = $1 and c.relkind = 'r'
        and exists (select 1 from pg_policies p
                     where p.schemaname = n.nspname and p.tablename = c.relname
                       and p.qual like '%company_id%')
      order by c.relname`,
    [schema],
  );
}

/** A write tried and undone: the keys of the rows it reached, or the message it raised. */
async function tryWrite(db: PGlite, sql: string): Promise<string[] | string> {
  await db.query('savepoint attempt');
  try {
    const reached = (await db.query<{ k: string }>(sql)).rows.map((r) => r.k).sort();
    await db.query('rollback to savepoint attempt');
    return reached;
  } catch (error) {
    await db.query('rollback to savepoint attempt');
    return `refused: ${(error as Error).message}`;
  }
}

/** What each caller reads, updates and deletes in each table of the schema that a policy ties to a company. */
export async function whatEachReaches(db: PGlite, schema: string, callers: Caller[]): Promise<Record_> {
  const tables = await companyTables(db, schema);
  const out: Record_ = {};
  for (const caller of callers) {
    out[caller.name] = {};
    for (const { table, key } of tables) {
      const qualified = `${schema}.${table}`;
      const keyText = key.length > 0 ? `(${key.map((k) => `t.${k}`).join(', ')})::text` : `t::text`;
      out[caller.name]![qualified] = await asCaller(db, caller, async () => ({
        read: (await db.query<{ r: string }>(`select t::text as r from ${qualified} t`)).rows.map((r) => r.r).sort(),
        update: await tryWrite(db, `update ${qualified} t set company_id = t.company_id returning ${keyText} as k`),
        delete: await tryWrite(db, `delete from ${qualified} t returning ${keyText} as k`),
      }));
    }
  }
  return out;
}

export interface Fixture {
  companyId: string;
  ownerId: string;
  /** Another company of the instance, with the module on and rows of its own. */
  otherCompanyId: string;
  otherOwnerId: string;
}

export interface PolicyProof {
  db: PGlite;
  fixture: Fixture;
  callers: Caller[];
  before: Record_;
  after: Record_;
  /** `schema.table` → how a read of it as the member evaluates the policy, before and after the migration. */
  plansBefore: Record<string, PolicyEvaluation>;
  plansAfter: Record<string, PolicyEvaluation>;
}

export interface PolicyEvaluation {
  initPlans: number;
  perRowFilters: string[];
}

/**
 * Builds the database without `migration` (a file of `modules/<folder>/`),
 * makes two companies with the module on and lets `fill` write the rows of
 * each, records what every caller reaches, applies the migration, and records
 * it again. The database is left open for the plans; the caller closes it.
 */
export async function provePolicyRewrite(options: {
  /** The module's code: `budgets`, `assets`, `tax`. */
  module: string;
  schema: string;
  /** The file name of the migration that rewrites the policies. */
  migration: string;
  /** Writes the module's rows for one company, as the owner of the database. */
  fill: (db: PGlite, companyId: string, ownerId: string) => Promise<void>;
  /**
   * Makes each of the two companies, where the module's own tests make theirs
   * another way (a pack of a kind, a profile filled in). `newCompany` when
   * left out. The module is turned on here, either way.
   */
  company?: (db: PGlite, name: string) => Promise<{ companyId: string; ownerId: string }>;
}): Promise<PolicyProof> {
  const file = (await moduleMigrationFiles()).find((m) => m.file === options.migration);
  if (file === undefined) throw new Error(`no module migration ${options.migration}`);
  const db = await freshDatabase({ withoutMigrations: [options.migration] });

  const make = options.company ?? ((into: PGlite, name: string) => newCompany(into, { name }));
  const mine = await make(db, 'Proof SRL');
  const other = await make(db, 'Neighbour SRL');
  for (const { companyId, ownerId } of [mine, other]) {
    await asUser(db, ownerId, () => db.query(`select enable_module($1, $2)`, [companyId, options.module]));
  }
  await options.fill(db, mine.companyId, mine.ownerId);
  await options.fill(db, other.companyId, other.ownerId);

  // A member of the company who holds none of the module's capabilities.
  const capabilities = (
    await rows<{ code: string }>(db, `select code from capabilities where code like $1 order by code`, [`${options.module}.%`])
  ).map((r) => r.code);
  if (capabilities.length === 0) throw new Error(`the module ${options.module} declares no capability`);
  const without = crypto.randomUUID();
  await db.query(
    `insert into company_members (company_id, user_id, role, capabilities_revoked) values ($1, $2, 'owner', $3)`,
    [mine.companyId, without, capabilities],
  );
  // A machine key of the company carrying every capability of the module.
  const issued = await asUser(db, mine.ownerId, () =>
    one<{ secret: string }>(db, `select secret from create_api_key($1, 'Proof key', $2::jsonb)`, [
      mine.companyId,
      JSON.stringify(capabilities),
    ]),
  );

  const callers: Caller[] = [
    { name: 'member', user: mine.ownerId },
    { name: 'member without the capabilities of the module', user: without },
    { name: 'member of another company', user: other.ownerId },
    { name: 'machine key', key: issued.secret },
  ];
  const before = await whatEachReaches(db, options.schema, callers);
  const plansBefore = await plansOfEveryTable(db, options.schema, callers[0]!);
  await replaySql(db, file.path);
  const after = await whatEachReaches(db, options.schema, callers);
  const plansAfter = await plansOfEveryTable(db, options.schema, callers[0]!);
  return {
    db,
    fixture: { companyId: mine.companyId, ownerId: mine.ownerId, otherCompanyId: other.companyId, otherOwnerId: other.ownerId },
    callers,
    before,
    after,
    plansBefore,
    plansAfter,
  };
}

async function plansOfEveryTable(db: PGlite, schema: string, caller: Caller): Promise<Record<string, PolicyEvaluation>> {
  const out: Record<string, PolicyEvaluation> = {};
  for (const { table } of await companyTables(db, schema)) {
    out[`${schema}.${table}`] = policyEvaluation(await planOf(db, caller, `select * from ${schema}.${table}`));
  }
  return out;
}

/** The plan of `sql` read as `caller`, as Postgres' JSON. */
export async function planOf(db: PGlite, caller: Caller, sql: string): Promise<Record<string, unknown>> {
  return asCaller(db, caller, async () => {
    const [row] = (await db.query<{ 'QUERY PLAN': [{ Plan: Record<string, unknown> }] }>(`explain (format json) ${sql}`)).rows;
    return row!['QUERY PLAN'][0].Plan;
  });
}

/**
 * How a plan evaluates the policy of a table: the InitPlans it runs once per
 * statement, and the filters that still call `module_enabled()` or
 * `has_capability()` with a column — once per row.
 */
export function policyEvaluation(plan: Record<string, unknown>): PolicyEvaluation {
  let initPlans = 0;
  const perRowFilters: string[] = [];
  for (const node of nodesOf(plan as never) as Iterable<Record<string, unknown>>) {
    if (node['Parent Relationship'] === 'InitPlan') initPlans += 1;
    const filter = node['Filter'];
    if (typeof filter === 'string' && /(module_enabled|has_capability)\(\w*\.?company_id/.test(filter)) {
      perRowFilters.push(filter);
    }
  }
  return { initPlans, perRowFilters };
}

/**
 * Each caller in its place, after the rewrite: the member reads rows of its
 * company and of no other, and every table `filled` names holds some; the
 * member without the module's capabilities reads nothing; the member of the
 * other company reads none of the company's rows; the key reads what the
 * member reads.
 */
export function expectEachCallerInItsPlace(proof: PolicyProof, filled: string[]): void {
  const { companyId, otherCompanyId } = proof.fixture;
  const member = proof.after['member']!;
  for (const [table, reach] of Object.entries(member)) {
    expect(reach.read.filter((r) => !r.includes(companyId) || r.includes(otherCompanyId)), table).toEqual([]);
  }
  for (const table of filled) expect(member[table]?.read.length ?? 0, `${table} holds rows of the member`).toBeGreaterThan(0);
  for (const [table, reach] of Object.entries(proof.after['member without the capabilities of the module']!)) {
    expect(reach.read, table).toEqual([]);
  }
  for (const [table, reach] of Object.entries(proof.after['member of another company']!)) {
    expect(reach.read.filter((r) => r.includes(companyId)), table).toEqual([]);
  }
  for (const [table, reach] of Object.entries(proof.after['machine key']!)) {
    expect(reach.read, table).toEqual(member[table]!.read);
  }
}

/**
 * Every table of the schema a policy ties to a company, read as the member:
 * before the migration the policy was a filter calling the functions on each
 * row — which is what makes this assertion able to fail — and after it, an
 * InitPlan and no such filter.
 */
export function expectPoliciesAskedOnce(proof: PolicyProof): void {
  const tables = Object.keys(proof.plansAfter);
  expect(tables.length).toBeGreaterThan(0);
  for (const table of tables) {
    expect(proof.plansBefore[table]!.perRowFilters.length, `${table} asked per row before`).toBeGreaterThan(0);
    expect(proof.plansAfter[table]!.perRowFilters, table).toEqual([]);
    expect(proof.plansAfter[table]!.initPlans, table).toBeGreaterThan(0);
  }
}
