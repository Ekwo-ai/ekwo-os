/**
 * An archive is read in pages, and is the same archive.
 *
 * `20261029020000` lets a client read a company as many short requests —
 * `export_company_outline()`, then `export_company_page()` table after table —
 * instead of one statement that has to fit one clock (decision 0092). The
 * promise is the archive itself: the files a client writes from the pages are
 * the files `export_company_table()` reads, the checksums it computes are the
 * ones `export_company_manifest()` gives, and `export_company()` does not move
 * by a byte across the file, which builds its manifest and its rows through
 * the places the pages read too.
 *
 * Pages of two rows, so that every table of more than two rows is read in
 * several: a primary key of one column, of several, and the trail, whose
 * primary key is an identity and which is paged by position.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { readCompanyArchive, SCHEMA_FEATURES } from '../packages/core/src/index.js';
import type { Pack } from '../packages/cli/src/index.js';
import { freshDatabase, one, readMigration, rows } from './helpers/db.js';
import { filers, furnish, type Archive, type Furnished } from './helpers/company-archive.js';
import { backendFor } from './mcp/helpers.js';

const FIX = '20261029020000_an_archive_is_read_in_pages.sql';

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

/** The manifest and every data file, as `export_company_manifest()` and `export_company_table()` read them in one snapshot. */
async function readInOne(companyId: string): Promise<{ manifest: Archive['manifest']; files: Record<string, string> }> {
  await db.query('begin isolation level repeatable read');
  try {
    return await asOwner(async () => {
      const manifest = JSON.parse(
        (await one<{ m: string }>(db, `select export_company_manifest($1)::text as m`, [companyId])).m,
      ) as Archive['manifest'];
      const files: Record<string, string> = {};
      for (const table of manifest.tables) {
        const lines = await rows<{ r: string }>(db, `select r::text as r from export_company_table($1, $2) as r`, [
          companyId,
          table.name,
        ]);
        files[`data/${table.name}.jsonl`] = lines.map((line) => `${line.r}\n`).join('');
      }
      return { manifest, files };
    });
  } finally {
    await db.query('rollback');
  }
}

async function readInPages(
  companyId: string,
  onPage?: (table: string, read: number) => Promise<void>,
): Promise<{ manifest: Awaited<ReturnType<typeof readCompanyArchive>>; files: Record<string, string>; pages: number }> {
  const files: Record<string, string> = {};
  let pages = 0;
  const manifest = await readCompanyArchive(backendFor(db, furnished.ownerId), companyId, {
    pageSize: 2,
    write: (file, text) => {
      files[file] = (files[file] ?? '') + text;
    },
    onPage: async (table, read) => {
      pages += 1;
      await onPage?.(table, read);
    },
  });
  return { manifest, files, pages };
}

beforeAll(async () => {
  db = await freshDatabase({ withoutMigrations: [FIX] });
  furnished = await furnish(db, filers[0] as Pack, 'Read in pages', 'PAGES');
  // This checkout is the release that brings the pages, whose schema version
  // the release commit writes; the core asks for it before it calls them.
  await db.exec(`create or replace function ekwo_schema_version() returns text language sql immutable as $$ select '${SCHEMA_FEATURES.archive_in_pages.since}'::text $$`);
}, 600_000);

afterAll(async () => {
  await db?.close();
});

describe('an archive read in pages', () => {
  it('leaves export_company() as it was, byte for byte', async () => {
    const { companyId } = furnished;
    const fix = await readMigration(db, FIX);
    const read = () =>
      asOwner(async () => (await one<{ a: string }>(db, `select export_company($1)::text as a`, [companyId])).a);

    // One transaction, so `now()` is one instant on both sides; a savepoint
    // takes back the first `company_exported`, so the second writes it again.
    await db.query('begin');
    let before: string;
    let after: string;
    try {
      await db.query('savepoint before');
      before = await read();
      await db.query('rollback to savepoint before');
      await db.exec(fix);
      after = await read();
      await db.query('rollback to savepoint before');
      await db.exec(fix);
      await db.query('commit');
    } catch (error) {
      await db.query('rollback');
      throw error;
    }
    expect(after).toBe(before);
  }, 600_000);

  it('writes the files and the checksums of the archive read in one snapshot', async () => {
    const { companyId } = furnished;
    const paged = await readInPages(companyId);
    const whole = await readInOne(companyId);

    // The claim is not vacuous: most tables have rows, many of them several
    // pages, and one row's canonical form differs from its text.
    expect(whole.manifest.tables.filter((t) => t.rows > 2).length).toBeGreaterThan(10);
    expect(paged.pages).toBeGreaterThan(whole.manifest.tables.length * 2);
    expect(Object.values(whole.files).some((text) => text.includes('"fee": 1.50'))).toBe(true);

    expect(paged.manifest.tables).toEqual(whole.manifest.tables);
    expect(paged.files).toEqual(Object.fromEntries(Object.entries(whole.files).filter(([, text]) => text !== '')));
    const { exported_at: pagedAt, ...pagedRest } = { ...paged.manifest, tables: [] } as Record<string, unknown>;
    const { exported_at: wholeAt, ...wholeRest } = { ...whole.manifest, tables: [] } as Record<string, unknown>;
    expect(pagedAt).toBeTypeOf('string');
    expect(wholeAt).toBeTypeOf('string');
    expect(pagedRest).toEqual(wholeRest);
  }, 600_000);

  it('refuses an archive whose books moved while it was read', async () => {
    const { companyId } = furnished;
    let added = false;
    await expect(
      readInPages(companyId, async (table) => {
        if (added || table !== 'ekwo.accounts') return;
        added = true;
        await db.query(
          `insert into contacts (company_id, name, contact_type) values ($1, 'Arrived during the copy', 'customer')`,
          [companyId],
        );
      }),
    ).rejects.toThrow(/^archive_moved: the books changed while they were read \(.*ekwo\.contacts/);
    expect(added).toBe(true);
  }, 600_000);

  it('refuses half an archive, by name', async () => {
    const { companyId, ownerId } = furnished;
    await db.query(
      `update company_members set capabilities_revoked = array['entries.read'] where company_id = $1 and user_id = $2`,
      [companyId, ownerId],
    );
    try {
      await expect(readInPages(companyId)).rejects.toThrow(
        /^export_incomplete: ekwo\.\w+ holds \d+ rows for this company and you may read 0/,
      );
    } finally {
      await db.query(
        `update company_members set capabilities_revoked = '{}' where company_id = $1 and user_id = $2`,
        [companyId, ownerId],
      );
    }
  }, 600_000);

  it('refuses a page of no row and a table an archive does not carry', async () => {
    const backend = backendFor(db, furnished.ownerId);
    const { companyId } = furnished;
    await expect(
      backend.rpc('export_company_page', { p_company_id: companyId, p_table: 'ekwo.accounts', p_after: null, p_limit: 0 }),
    ).rejects.toThrow(/invalid_page_size/);
    await expect(
      backend.rpc('export_company_page', { p_company_id: companyId, p_table: 'ekwo.api_keys', p_after: null, p_limit: 10 }),
    ).rejects.toThrow(/unknown_table: ekwo\.api_keys/);
  }, 600_000);
});
