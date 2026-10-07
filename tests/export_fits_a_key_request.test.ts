/**
 * An export does the work of a table once, and writes the same bytes.
 *
 * `20261007190000` rewrote the reader of an archive so that the right, the
 * sweep of the catalogue and the list of tables are asked once per archive,
 * and each table is read once for its count, both checksums and its rows. An
 * archive is a promise to another installation: the rewrite is only allowed
 * if nothing it writes moves.
 *
 * So the installation here is the one 0.11.0 left — every migration but that
 * one — with a company furnished across every table an archive carries. The
 * export is taken with the functions of 0.11.0, the migration is applied
 * inside the same transaction, and the export is taken again: `now()` is the
 * same instant on both sides, and the two documents have to be the same text,
 * byte for byte. A savepoint takes back the first `company_exported` the trail
 * records, so the second export writes the same one again.
 *
 * The time of both is printed, for the record of the release.
 */

import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { Pack } from '../packages/cli/src/index.js';
import { freshDatabase, one, repoRoot, rows } from './helpers/db.js';
import { filers, furnish, type Archive, type Furnished } from './helpers/company-archive.js';

const FIX = '20261007190000_an_export_fits_a_key_request.sql';
/** The migrations of this release, left out so that the database is the one 0.11.0 left. */
const RELEASE = [FIX, '20261007200000_schema_version_0_11_1.sql'];

let db: PGlite;
let furnished: Furnished;

/** Runs a block as the owner of the company, inside the transaction already open. */
async function asOwner<T>(fn: () => Promise<T>): Promise<T> {
  await db.exec(`
    select set_config('request.jwt.claims', '${JSON.stringify({ sub: furnished.ownerId, role: 'authenticated' })}', true);
    select set_config('ekwo.installing', '', true);
    set local role authenticated;
  `);
  try {
    return await fn();
  } finally {
    await db.exec(`
      reset role;
      select set_config('request.jwt.claims', '', true);
      select set_config('ekwo.installing', 'on', true);
    `);
  }
}

interface Reading {
  archive: string;
  manifest: string;
  tables: string;
  perTable: Record<string, string[]>;
  ms: number;
}

/** Everything a client can read of an archive, as text, and the time `export_company()` took. */
async function readEverything(companyId: string): Promise<Reading> {
  return asOwner(async () => {
    const started = performance.now();
    const archive = (await one<{ a: string }>(db, `select export_company($1)::text as a`, [companyId])).a;
    const ms = performance.now() - started;
    const manifest = (await one<{ m: string }>(db, `select export_company_manifest($1)::text as m`, [companyId])).m;
    const tables = (await one<{ t: string }>(db, `select export_company_tables($1)::text as t`, [companyId])).t;
    const perTable: Record<string, string[]> = {};
    for (const table of (JSON.parse(manifest) as Archive['manifest']).tables) {
      perTable[table.name] = (
        await rows<{ r: string }>(db, `select r::text as r from export_company_table($1, $2) as r`, [
          companyId,
          table.name,
        ])
      ).map((row) => row.r);
    }
    return { archive, manifest, tables, perTable, ms };
  });
}

beforeAll(async () => {
  db = await freshDatabase({ withoutMigrations: RELEASE });
  furnished = await furnish(db, filers[0] as Pack, 'Leaves at night', 'NIGHT');
}, 600_000);

afterAll(async () => {
  await db?.close();
});

describe('an export after 20261007190000', () => {
  it('writes the archive of 0.11.0 byte for byte, and reads each table once', async () => {
    const { companyId } = furnished;
    const fix = await readFile(join(repoRoot, 'supabase', 'migrations', FIX), 'utf8');

    await db.query('begin');
    let before: Reading;
    let after: Reading;
    let warm: number;
    try {
      // Before: the functions as 0.11.0 published them. Twice, and the second
      // is the one timed — the first warms the plans of every function body.
      await db.query('savepoint before');
      await readEverything(companyId);
      await db.query('rollback to savepoint before');
      before = await readEverything(companyId);
      await db.query('rollback to savepoint before');

      await db.exec(fix);

      await readEverything(companyId);
      await db.query('rollback to savepoint before');
      await db.exec(fix);
      after = await readEverything(companyId);
      warm = after.ms;
    } finally {
      await db.query('rollback');
    }

    const manifest = JSON.parse(after.manifest) as Archive['manifest'];
    const filled = manifest.tables.filter((t) => t.rows > 0).length;
    console.info(
      `export_company(): ${manifest.tables.length} tables, ${filled} with rows, ` +
        `${manifest.tables.reduce((n, t) => n + t.rows, 0)} rows — ` +
        `0.11.0 ${before.ms.toFixed(0)} ms, 0.11.1 ${warm.toFixed(0)} ms`,
    );

    // The claim is not vacuous: the company has rows in most of what leaves,
    // in the socle and in the modules.
    expect(filled).toBeGreaterThan(30);
    expect(manifest.format_version).toBe(1);

    expect(after.archive).toBe(before.archive);
    expect(after.manifest).toBe(before.manifest);
    expect(after.tables).toBe(before.tables);
    expect(after.perTable).toEqual(before.perTable);
    expect(warm).toBeLessThan(before.ms);
  }, 600_000);

  it('still refuses half an archive, by name', async () => {
    // A member who may export and may not read the books: the count the
    // administrator holds, now taken once for every table, still stops it.
    const { companyId } = furnished;
    const fix = await readFile(join(repoRoot, 'supabase', 'migrations', FIX), 'utf8');
    await db.query('begin');
    try {
      await db.exec(fix);
      await db.query(
        `update company_members set capabilities_revoked = array['entries.read']
          where company_id = $1 and user_id = $2`,
        [companyId, furnished.ownerId],
      );
      // A refusal aborts what it ran in, so it runs inside a savepoint of its own.
      await db.query('savepoint refused');
      const said = await asOwner(() =>
        db.query(`select export_company($1)`, [companyId]).then(
          () => 'exported',
          async (error: Error) => {
            await db.query('rollback to savepoint refused');
            return error.message;
          },
        ),
      );
      expect(said).toMatch(/export_incomplete: public\.\w+ holds \d+ rows for this company and you may read 0/);
    } finally {
      await db.query('rollback');
    }
  }, 600_000);
});
