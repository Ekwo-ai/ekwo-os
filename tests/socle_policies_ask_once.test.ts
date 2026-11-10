/**
 * The socle's last policies ask once per statement
 * (`20261110124117_the_socle_policies_ask_once.sql`): the same rows for the
 * same callers before and after the rewrite, and a plan that asks once.
 *
 * The proof is the modules' (`tests/helpers/policy-proof.ts`), given the
 * socle's tables by name: the database is built without the migration, two
 * companies are furnished the way the archive tests furnish one — a year of
 * books, a declaration filed with its proof, a draft of the next, pieces —
 * and the few rows that furniture does not hold are added (an invitation, a
 * machine key, a piece a client deposited, a filing cadence, a VAT scheme, a
 * turnover regime). Every caller then reads, updates and deletes every
 * touched table, each write rolled back; the migration is applied to the
 * same database and it is all done again.
 *
 * The callers are those the rewritten terms are about: the owner, a member
 * whose every capability is revoked (a member still, which is what
 * `is_company_member()` asks), a client who deposited a piece
 * (`attachments_select_own_deposit`), the owner of another company, a person
 * of no company, an instance administrator (`or is_instance_admin()`), a
 * machine key that holds what the owner holds, and one that holds a single
 * capability (a member through its key, and nothing more).
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { filers, furnish } from './helpers/company-archive.js';
import { asUser, freshDatabase, one, replayMigration } from './helpers/db.js';
import { newInstanceAdmin, newUser } from './helpers/factory.js';
import {
  guarded,
  planOf,
  policyEvaluation,
  whatEachReaches,
  type Caller,
  type Guarded,
  type PolicyEvaluation,
  type Reach,
  type Record_,
} from './helpers/policy-proof.js';

const MIGRATION = '20261110124117_the_socle_policies_ask_once.sql';

/** The tables the migration touches, and the column each one's policies read the company through. */
const TOUCHED: [string, string][] = [
  ['ekwo.api_keys', 'company_id'],
  ['ekwo.attachments', 'company_id'],
  ['ekwo.companies', 'id'],
  ['ekwo.company_filing_periods', 'company_id'],
  ['ekwo.company_invitations', 'company_id'],
  ['ekwo.company_members', 'company_id'],
  ['ekwo.company_modules', 'company_id'],
  ['ekwo.company_tax_regimes', 'company_id'],
  ['ekwo.company_vat_schemes', 'company_id'],
  ['ekwo.journal_sequences', 'journal_id'],
  ['ekwo.matching_settings', 'company_id'],
  ['ekwo.tax_filing_boxes', 'filing_id'],
  ['ekwo.tax_filing_deposits', 'filing_id'],
];

/** The tables whose every rewritten policy asks through a parent row. */
const THROUGH_A_PARENT = ['ekwo.journal_sequences', 'ekwo.tax_filing_boxes', 'ekwo.tax_filing_deposits'];

/** The rows `furnish()` does not write, for one company. */
async function complete(db: PGlite, companyId: string, ownerId: string, clientId: string): Promise<void> {
  await asUser(db, ownerId, () =>
    db.query(`select invite_member($1, $2, 'viewer', null, interval '7 days')`, [companyId, `${companyId}@example.test`]),
  );
  await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'client')`, [companyId, clientId]);
  await db.query(
    `insert into attachments (company_id, entity_type, entity_id, file_name, storage_path, byte_size, checksum, uploaded_by)
     values ($1::uuid, 'company', $1::uuid, 'deposited.pdf', $1::text || '/deposits/deposited.pdf', 1024, 'sha256:bb22', $2)`,
    [companyId, clientId],
  );
  await db.query(
    `insert into company_filing_periods (company_id, report_code, period)
     select f.company_id, f.report_code, 'month' from tax_filings f where f.company_id = $1
     order by f.created_at limit 1
     on conflict do nothing`,
    [companyId],
  );
  // Which scheme or regime a company may be on is `vat_schemes.test.ts` and
  // `turnover_tax_regime.test.ts`; who reads the row is this. The guards that
  // hold a row to its country are left out for these two rows, and any row of
  // the reference tables does.
  await db.exec(`set session_replication_role = replica`);
  try {
    await db.query(
      `insert into company_vat_schemes (company_id, valid_from, country, scheme_code)
       select $1, date '2026-01-01', s.country, s.code from vat_schemes s order by s.country, s.code limit 1`,
      [companyId],
    );
    await db.query(
      `insert into company_tax_regimes (company_id, regime_code, valid_from)
       select $1, r.code, date '2026-01-01' from turnover_tax_regimes r order by r.code limit 1`,
      [companyId],
    );
  } finally {
    await db.exec(`set session_replication_role = origin`);
  }
}

let db: PGlite;
let tables: Guarded[];
let callers: Caller[];
let before: Record_;
let after: Record_;
let companyId: string;
let otherCompanyId: string;
const plansBefore: Record<string, PolicyEvaluation> = {};
const plansAfter: Record<string, PolicyEvaluation> = {};

async function plans(into: Record<string, PolicyEvaluation>): Promise<void> {
  for (const { table } of tables) into[table] = policyEvaluation(await planOf(db, callers[0]!, `select * from ${table}`));
}

beforeAll(async () => {
  db = await freshDatabase({ withoutMigrations: [MIGRATION] });
  const pack = filers[0]!;
  const mine = await furnish(db, pack, 'Proof SRL', 'MINE');
  const other = await furnish(db, pack, 'Neighbour SRL', 'OTHER');
  companyId = mine.companyId;
  otherCompanyId = other.companyId;
  const client = await newUser(db);
  await complete(db, mine.companyId, mine.ownerId, client);
  await complete(db, other.companyId, other.ownerId, await newUser(db));

  const revoked = await newUser(db);
  await db.query(
    `insert into company_members (company_id, user_id, role, capabilities_revoked)
     select $1, $2, 'viewer', array_agg(code) from capabilities`,
    [companyId, revoked],
  );
  const key = async (capabilities: string[]): Promise<string> =>
    (
      await asUser(db, mine.ownerId, () =>
        one<{ secret: string }>(db, `select secret from create_api_key($1, 'Proof key', $2::jsonb)`, [
          companyId,
          JSON.stringify(capabilities),
        ]),
      )
    ).secret;
  const ownerHolds = (
    await db.query<{ capability: string }>(`select capability from role_capabilities where role = 'owner' order by capability`)
  ).rows.map((r) => r.capability);

  callers = [
    { name: 'member', user: mine.ownerId },
    { name: 'member holding no capability', user: revoked },
    { name: 'client who deposited a piece', user: client },
    { name: 'member of another company', user: other.ownerId },
    { name: 'person of no company', user: await newUser(db) },
    { name: 'instance administrator', user: await newInstanceAdmin(db) },
    { name: 'machine key', key: await key(ownerHolds) },
    { name: 'machine key holding one capability', key: await key(['documents.read']) },
  ];
  tables = [];
  for (const [table, column] of TOUCHED) tables.push(await guarded(db, table, column));

  before = await whatEachReaches(db, tables, callers);
  await plans(plansBefore);
  await replayMigration(db, MIGRATION);
  after = await whatEachReaches(db, tables, callers);
  await plans(plansAfter);
}, 600_000);

afterAll(async () => {
  await db?.close();
});

/**
 * What a caller reaches, with the one thing that moves between the two
 * records taken out: a machine key writes `api_keys.last_used_at` each time
 * it is presented, so its own row reads differently every time.
 */
function stable(reach: Reach, table: string): Reach {
  if (table !== 'ekwo.api_keys') return reach;
  return { ...reach, read: reach.read.map((row) => row.replace(/"\d{4}-\d\d-\d\d \d\d:\d\d:\d\d(\.\d+)?\+00"/g, '<at>')) };
}

describe('the socle policies, asked once per statement', () => {
  it('let every caller read, update and delete exactly the rows it could before', () => {
    for (const caller of callers) {
      for (const { table } of tables) {
        expect(stable(after[caller.name]![table]!, table), `${caller.name} on ${table}`).toEqual(
          stable(before[caller.name]![table]!, table),
        );
      }
    }
  });

  it('are tried on rows that are there, by callers that differ', () => {
    const member = after['member']!;
    for (const { table } of tables) {
      expect(member[table]!.read.length, `${table} holds rows of the member`).toBeGreaterThan(0);
      expect(
        member[table]!.read.filter((r) => r.includes(otherCompanyId)),
        `${table}: the member reads nothing of the other company`,
      ).toEqual([]);
    }
    // A member who holds nothing is still on the company; a stranger is not.
    expect(after['member holding no capability']!['ekwo.companies']!.read).toHaveLength(1);
    expect(after['member holding no capability']!['ekwo.api_keys']!.read).toEqual([]);
    expect(after['person of no company']!['ekwo.companies']!.read).toEqual([]);
    expect(after['person of no company']!['ekwo.company_members']!.read).toEqual([]);
    // The administrator sees every company and its keys, and not its books.
    expect(after['instance administrator']!['ekwo.companies']!.read.length).toBeGreaterThanOrEqual(2);
    expect(after['instance administrator']!['ekwo.api_keys']!.read.length).toBeGreaterThan(0);
    expect(after['instance administrator']!['ekwo.matching_settings']!.read).toEqual([]);
    // The client reads the piece it deposited; a key that reads documents is on the company.
    expect(after['client who deposited a piece']!['ekwo.attachments']!.read.some((r) => r.includes('deposited.pdf'))).toBe(true);
    expect(after['machine key holding one capability']!['ekwo.companies']!.read.every((r) => r.includes(companyId))).toBe(true);
    expect(after['machine key holding one capability']!['ekwo.companies']!.read).toHaveLength(1);
    expect(after['machine key holding one capability']!['ekwo.company_invitations']!.read).toEqual([]);
  });

  it('evaluate the company as an InitPlan, not a call on each row', () => {
    for (const { table } of tables) {
      if (table !== 'ekwo.attachments') {
        expect(
          plansBefore[table]!.perRowFilters.length + plansBefore[table]!.perRowSubPlans.length,
          `${table} asked per row before`,
        ).toBeGreaterThan(0);
      }
      expect(plansAfter[table]!.perRowFilters, table).toEqual([]);
      expect(plansAfter[table]!.initPlans, table).toBeGreaterThan(0);
    }
  });

  it('read a parent row once: its ids are hashed, and no parent row is asked about', () => {
    // Postgres 17 already ran the correlated `exists` as a hashed sub-plan,
    // but that sub-plan called `has_capability()` for every row of the
    // parent it read; now it compares with an InitPlan, and stays hashed.
    for (const table of THROUGH_A_PARENT) {
      expect(plansBefore[table]!.perRowFilters.join(), `${table} before`).toMatch(/has_capability\(company_id/);
      expect(plansAfter[table]!.perRowSubPlans, table).toEqual([]);
    }
  });
});
