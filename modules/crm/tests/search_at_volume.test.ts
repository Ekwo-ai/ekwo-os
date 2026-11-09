/**
 * The reads of `crm` on a company the size of an imported address book.
 *
 * `crm.search_cards()` is the entry of every screen and every agent tool of
 * the module, and it was seen ending in a statement timeout on a company of
 * about 33 000 contacts and 10 500 cards. The cause was not the shape of the
 * plan but the policies: each row a scan visited asked `module_enabled()` and
 * `has_capability()` again (`20261109120000_crm_reads_hold_at_volume.sql`).
 *
 * Three things are held here, on a company built by `volume.ts`:
 *
 * - **Asserted, and deterministic: how often the caller is asked about.** A
 *   policy that asks once per statement asks a handful of times per read; one
 *   that asks once per row asks tens of thousands of times. The count is a
 *   property of the plan and of the data, both fixed here, so it is the guard
 *   that does not flake.
 * - **Asserted, with room: the time.** Every filter of the search alone and
 *   combined, and the default call, are timed together against a bound many
 *   times what they take on a workstation and well under what they took
 *   before. PGlite on a shared runner is noisy; the bound is set so noise
 *   never reaches it, and a policy that asks per row again does.
 * - **Asserted: the same rows.** On a small company, a member reads exactly
 *   the rows the database owner reads — who sees through every policy — for
 *   each filter. A policy rewritten to ask the other way round must let
 *   through what it let through before, and nothing to a member without the
 *   capability or a company without the module.
 *
 *   EKWO_CRM_VOLUME_SCALE   multiple of the size above; 1 when left out. 10
 *                           is the size the search has to hold, and takes a
 *                           few minutes to build on PGlite
 */

import type { PGlite } from '@electric-sql/pglite';
import { auto_explain } from '@electric-sql/pglite/contrib/auto_explain';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { RECORD_PLANS, STOP_RECORDING, planRecorder } from '../../../scripts/load/hot-paths.mjs';
import { asUser, freshDatabase, rows } from '../../../tests/helpers/db.js';
import { newCompany } from '../../../tests/helpers/factory.js';
import { fillVolume, type Volume } from './volume.js';

const SCALE = Number(process.env['EKWO_CRM_VOLUME_SCALE'] ?? 1);

/**
 * All the searches below together, in milliseconds, at scale 1. They take
 * about 300 ms on a workstation; asking per row, they took fourteen seconds.
 * Grows with the scale, since a search with no selective filter reads every
 * card of the company.
 */
const SEARCHES_WITHIN_MS = 5_000 * SCALE;

/** One read of the tree, a board or a timeline, at scale 1: about 15 ms; the tree took 2.7 s asking per row. */
const READ_WITHIN_MS = 1_500 * SCALE;

/**
 * How many times one read may evaluate `has_capability()`. Not a tuned
 * figure: what it separates is "once per company the caller is on, per table
 * read" — a handful — from "once per row", which is tens of thousands here.
 */
const CAPABILITY_CHECKS_AT_MOST = 50;

let db: PGlite;
let companyId: string;
let ownerId: string;
let volume: Volume;

/** Every filter of the search alone, the default call, a wider page, and filters combined. */
function searches(v: Volume): { name: string; args: string }[] {
  return [
    { name: 'no filter', args: '' },
    { name: 'text', args: `, p_query => '${v.text}'` },
    { name: 'status', args: `, p_status => 'contacted'` },
    { name: 'segment', args: `, p_segment_id => '${v.segmentId}'` },
    { name: 'stage', args: `, p_stage_id => '${v.stageId}'` },
    { name: 'country', args: `, p_country => '${v.country}'` },
    { name: 'language', args: `, p_language => '${v.language}'` },
    { name: 'owner', args: `, p_owner => '${v.owner}'` },
    { name: 'no_outbound', args: `, p_no_outbound => true` },
    { name: 'active since', args: `, p_active_since => '${v.moment}'` },
    { name: 'inactive since', args: `, p_inactive_since => '${v.moment}'` },
    {
      name: 'combined',
      args: `, p_query => 'person', p_status => 'contacted', p_no_outbound => false, p_inactive_since => '${v.moment}'`,
    },
    { name: '500 rows', args: `, p_limit => 500` },
  ];
}

async function timed(sql: string): Promise<{ ms: number; rows: number }> {
  const started = performance.now();
  const result = await db.query(sql);
  return { ms: Math.round(performance.now() - started), rows: result.rows.length };
}

/** How many times `sql` evaluates `has_capability()`, read from the nested statements it runs. */
async function capabilityChecks(sql: string): Promise<number> {
  const recorder = planRecorder();
  // auto_explain is set by the owner of the database, then the member reads.
  await db.exec(`reset role; ${RECORD_PLANS} set role authenticated;`);
  try {
    await db.query(sql, [], { onNotice: (notice) => recorder.onNotice(notice) });
  } finally {
    await db.exec(`reset role; ${STOP_RECORDING} set role authenticated;`);
  }
  return recorder.counts.capabilityChecks;
}

describe(`the reads of crm on a company of an imported address book (scale ${SCALE})`, () => {
  beforeAll(async () => {
    db = await freshDatabase({ extensions: { auto_explain } });
    await db.exec(`load 'auto_explain'`);
    ({ companyId, ownerId } = await newCompany(db, { name: 'Volume SRL' }));
    // Another company in the instance, so that `company_id = …` selects.
    const other = await newCompany(db, { name: 'Neighbour SRL' });
    await asUser(db, ownerId, () => db.query(`select enable_module($1, 'crm')`, [companyId]));
    await asUser(db, other.ownerId, () => db.query(`select enable_module($1, 'crm')`, [other.companyId]));
    volume = await fillVolume(db, companyId, SCALE);
    await fillVolume(db, other.companyId, 0.1);
  }, 600_000 * SCALE);

  afterAll(async () => {
    await db.close();
  });

  it('answers every filter of the search, alone and combined, within the bound', async () => {
    const report: string[] = [];
    let total = 0;
    await asUser(db, ownerId, async () => {
      for (const { name, args } of searches(volume)) {
        const sql = `select * from crm.search_cards('${companyId}'${args})`;
        await db.query(sql); // the first call pays for the plan
        const { ms, rows: found } = await timed(sql);
        total += ms;
        report.push(`  ${name.padEnd(16)} ${String(found).padStart(4)} rows  ${String(ms).padStart(6)} ms`);
        expect(found, name).toBeGreaterThan(0);
      }
    });
    console.log(`search_cards at scale ${SCALE}, as a member:\n${report.join('\n')}\n  all together ${total} ms`);
    expect(total).toBeLessThan(SEARCHES_WITHIN_MS);
  }, 600_000 * SCALE);

  it('reads the segment tree, a board and a timeline within the bound', async () => {
    const [busy] = await rows<{ id: string }>(
      db,
      `select contact_id as id from crm.activities where company_id = $1
        group by contact_id order by count(*) desc, contact_id limit 1`,
      [companyId],
    );
    const [deal] = await rows<{ id: string }>(db, `select id from crm.deals where company_id = $1 order by id limit 1`, [
      companyId,
    ]);
    const reads = [
      { name: 'segment_tree', sql: `select * from crm.segment_tree('${companyId}')` },
      { name: 'board', sql: `select crm.board('${companyId}')` },
      { name: 'board, closed too', sql: `select crm.board('${companyId}', null, true)` },
      { name: 'timeline of a contact', sql: `select * from crm.timeline('${companyId}', '${busy!.id}')` },
      { name: 'timeline of a deal', sql: `select * from crm.timeline('${companyId}', null, '${deal!.id}')` },
    ];
    const report: string[] = [];
    await asUser(db, ownerId, async () => {
      for (const { name, sql } of reads) {
        await db.query(sql);
        const { ms } = await timed(sql);
        report.push(`  ${name.padEnd(22)} ${String(ms).padStart(6)} ms`);
        expect(ms, name).toBeLessThan(READ_WITHIN_MS);
      }
    });
    console.log(`the other reads at scale ${SCALE}, as a member:\n${report.join('\n')}`);
  }, 600_000 * SCALE);

  it('asks who the caller is a bounded number of times, whatever the size', async () => {
    const reads = [
      ...searches(volume).map(({ name, args }) => ({
        name: `search_cards, ${name}`,
        sql: `select * from crm.search_cards('${companyId}'${args})`,
      })),
      { name: 'segment_tree', sql: `select * from crm.segment_tree('${companyId}')` },
      { name: 'board', sql: `select crm.board('${companyId}', null, true)` },
    ];
    const asked: { name: string; checks: number }[] = [];
    await asUser(db, ownerId, async () => {
      for (const { name, sql } of reads) asked.push({ name, checks: await capabilityChecks(sql) });
    });
    expect(asked.filter((a) => a.checks > CAPABILITY_CHECKS_AT_MOST)).toEqual([]);
    // And the recorder did see them: a count of zero would prove nothing.
    expect(asked.every((a) => a.checks > 0)).toBe(true);
  }, 600_000 * SCALE);
});

describe('the search finds the rows it found before, on a small company', () => {
  let small: PGlite;
  let smallCompany: string;
  let smallOwner: string;
  let smallVolume: Volume;

  beforeAll(async () => {
    small = await freshDatabase();
    ({ companyId: smallCompany, ownerId: smallOwner } = await newCompany(small, { name: 'Small SRL' }));
    await asUser(small, smallOwner, () => small.query(`select enable_module($1, 'crm')`, [smallCompany]));
    smallVolume = await fillVolume(small, smallCompany, 0.02);
  }, 120_000);

  afterAll(async () => {
    await small.close();
  });

  /** Every filter, with a page wide enough to hold every row it finds. */
  function calls(): { name: string; sql: string }[] {
    return searches(smallVolume).map(({ name, args }) => ({
      name,
      sql: `select * from crm.search_cards('${smallCompany}'${args}${args.includes('p_limit') ? '' : ', p_limit => 100000'})`,
    }));
  }

  it('gives a member every row the owner of the database reads, in the same order', async () => {
    for (const { name, sql } of calls()) {
      // The owner of the database is not subject to row level security.
      const everything = await rows(small, sql);
      const member = await asUser(small, smallOwner, () => rows(small, sql));
      expect(member, name).toEqual(everything);
      expect(everything.length, name).toBeGreaterThan(0);
    }
  });

  it('gives a viewer the same rows, and nothing to a member without crm.read', async () => {
    const viewer = crypto.randomUUID();
    const withoutRead = crypto.randomUUID();
    await small.query(
      `insert into company_members (company_id, user_id, role, capabilities_revoked)
       values ($1, $2, 'viewer', '{}'), ($1, $3, 'owner', array['crm.read', 'crm.write'])`,
      [smallCompany, viewer, withoutRead],
    );
    for (const { name, sql } of calls()) {
      const everything = await rows(small, sql);
      expect(await asUser(small, viewer, () => rows(small, sql)), name).toEqual(everything);
      expect(await asUser(small, withoutRead, () => rows(small, sql)), name).toEqual([]);
    }
  });

  it('gives nothing once the module is turned off, and every row back when it is on again', async () => {
    const [{ sql }] = calls();
    const before = await asUser(small, smallOwner, () => rows(small, sql!));
    await asUser(small, smallOwner, () => small.query(`select disable_module($1, 'crm')`, [smallCompany]));
    expect(await asUser(small, smallOwner, () => rows(small, sql!))).toEqual([]);
    await asUser(small, smallOwner, () => small.query(`select enable_module($1, 'crm')`, [smallCompany]));
    expect(await asUser(small, smallOwner, () => rows(small, sql!))).toEqual(before);
  });
});
