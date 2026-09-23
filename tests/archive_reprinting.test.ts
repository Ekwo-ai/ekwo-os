/**
 * An archive survives an honest reader printing it again.
 *
 * The archive is rows as JSON, and the checksum of a table is the sha256 of
 * the bytes the database wrote. That is what makes `shasum` check an archive
 * without Ekwo, and it is worth keeping. It also means the checksum answers a
 * question about *text*, and a reader that parses the archive and prints it
 * again — which is what any program that stores it, streams it or copies it
 * between two services does — changes that text without changing a single
 * value.
 *
 * One thing changes, and only one. `jsonb` already normalises key order and
 * whitespace on both sides, so the round trip is invisible except for numbers
 * **nested inside a jsonb column**: PostgreSQL keeps the trailing zeros of
 * `1230.00`, and a JSON parser hands back `1230`. The rule that decimals leave
 * as text protects the `numeric` columns and cannot reach inside a `jsonb`
 * one, and `audit_log.old_values` / `new_values` are full of them.
 *
 * The CLI knows this and never parses the rows. Nothing made it fail for
 * anybody else: an honest reader got `archive_corrupt` on `audit_log`, with
 * the same row count and another checksum, which reads like a damaged archive
 * and is not one. This is that reader.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, newInstanceAdmin, newUser } from './helpers/factory.js';
import { packWhere } from './helpers/packs.js';

let a: PGlite;
let companyId: string;
let ownerId: string;

/** An empty installation, and an administrator of it. One per import: an
 *  installation takes the same company once, which is its own test elsewhere. */
async function emptyInstallation(): Promise<{ db: PGlite; admin: string }> {
  const db = await freshDatabase();
  return { db, admin: await newInstanceAdmin(db) };
}

/** Imports an archive into a fresh installation and answers what came back. */
async function importInto(archive: string): Promise<Record<string, unknown> | string> {
  const { db, admin } = await emptyInstallation();
  try {
    const answer = await asUser(db, admin, async () =>
      one<{ result: Record<string, unknown> }>(db, `select import_company($1::jsonb) as result`, [
        archive,
      ]),
    );
    return answer.result;
  } catch (error) {
    return (error as Error).message;
  } finally {
    await db.close();
  }
}

/** The pack the books below are kept on. Its own codes, read from the pack. */
const pack = packWhere('carries a chart and a golden year', (p) => p.golden !== null);

interface Archive {
  manifest: {
    format_version: number;
    tables: { name: string; rows: number; sha256: string; values_sha256?: string }[];
  };
  tables: Record<string, unknown[]>;
}

/** The archive as the database wrote it: text, never parsed. */
async function exportText(): Promise<string> {
  return asUser(a, ownerId, async () =>
    (
      await one<{ archive: string }>(a, `select export_company($1)::text as archive`, [companyId])
    ).archive,
  );
}

/**
 * What an honest reader does: parse it, keep every value, print it again.
 *
 * No value is touched here. `JSON.parse` and `JSON.stringify` is the whole of
 * it, and it is the shortest way to write "this archive went through a program
 * that is not the CLI".
 */
function reprint(archive: string): string {
  return JSON.stringify(JSON.parse(archive));
}

beforeAll(async () => {
  a = await freshDatabase();
  ownerId = await newUser(a, 'owner@reprint.test');
  ({ companyId } = await newCompany(a, {
    country: pack.manifest.country,
    name: 'Reprinted',
    ownerId,
  }));
  const customer = await newContact(a, companyId, { name: 'A customer' });
  const chart = pack.charts.find((c) => c.is_default) ?? pack.charts[0]!;
  const sales = pack.manifest.defaults.roles['sales'] as string;
  const tax = pack.taxes.find((t) => t.kind === 'sale')?.code;
  const invoice = await newDocument(a, companyId, {
    docType: 'sale_invoice',
    number: 'INV-REPRINT-1',
    contactId: customer,
    // A price with cents, so the audit trail carries a number whose trailing
    // zero is the whole of this test: 1230.00 and 1230 are the same amount and
    // not the same text.
    lines: [{ unitPrice: 1230, taxCode: tax, accountCode: sales }],
  });
  expect(chart.code).toBeTruthy();
  await a.query(`select post_document($1)`, [invoice]);
}, 240_000);

afterAll(async () => {
  await a.close();
});

describe('the trail this is about', () => {
  it('carries numbers with trailing zeros, inside a jsonb column', async () => {
    const found = await rows<{ value: string }>(
      a,
      `select distinct (val #>> '{}') as value
         from audit_log l, lateral jsonb_each(coalesce(l.new_values, '{}'::jsonb)) as e(k, val)
        where l.company_id = $1
          and jsonb_typeof(val) = 'number' and (val #>> '{}') like '%.%0'`,
      [companyId],
    );
    expect(found.length).toBeGreaterThan(0);
  });

  it('is not the same text once a parser has been through it', () => {
    // The mechanism, in one line and without a database: this is what every
    // reader that is not the CLI does to the archive.
    expect(JSON.stringify(JSON.parse('{"amount":1230.00}'))).toBe('{"amount":1230}');
  });
});

describe('an archive printed again by an honest reader', () => {
  it('arrives, and arrives whole', async () => {
    const archive = await exportText();
    const again = reprint(archive);
    expect(again).not.toBe(archive);

    const { db, admin } = await emptyInstallation();
    try {
      const answer = await asUser(db, admin, async () =>
        one<{ result: Record<string, unknown> }>(db, `select import_company($1::jsonb) as result`, [
          again,
        ]),
      );
      const arrived = answer.result['company_id'] as string;
      expect(arrived).toBeTruthy();

      // Every table of the archive, row for row. `audit_log` is the one that
      // grows on the way in — arriving is itself an act, and the trail records
      // it — so it is compared as "at least what the archive carried".
      const manifest = (JSON.parse(archive) as Archive).manifest;
      for (const table of manifest.tables) {
        if (table.rows === 0) continue;
        const [schema, name] = table.name.split('.');
        const counted = await one<{ n: number }>(
          db,
          `select count(*)::int as n from ${schema}.${name} where company_id = $1`,
          [arrived],
        ).catch(() => undefined);
        if (counted === undefined) continue;
        if (table.name === 'public.audit_log') {
          expect(counted.n, table.name).toBeGreaterThanOrEqual(table.rows);
        } else {
          expect(counted.n, table.name).toBe(table.rows);
        }
      }
    } finally {
      await db.close();
    }
  });

  it('is refused all the same when a value was changed', async () => {
    const archive = JSON.parse(await exportText()) as Archive;
    const lines = archive.tables['public.entry_lines'] as Record<string, unknown>[];
    expect(lines.length).toBeGreaterThan(0);
    // One cent, on one line. Nothing else touched, and the row count is the
    // same — which is exactly the shape a checksum exists to catch.
    lines[0]!['debit'] = '999999.00';

    const said = await importInto(JSON.stringify(archive));
    expect(typeof said).toBe('string');
    expect(said as string).toMatch(/archive_corrupt/);
    expect(said as string).toContain('public.entry_lines');
  });

  it('is refused when a row is removed, printed again or not', async () => {
    const archive = JSON.parse(await exportText()) as Archive;
    const lines = archive.tables['public.entry_lines'] as unknown[];
    lines.pop();

    const said = await importInto(JSON.stringify(archive));
    expect(typeof said).toBe('string');
    expect(said as string).toMatch(/archive_corrupt/);
  });
});

describe('an archive written before this migration', () => {
  // It carries `sha256` and no `values_sha256`, and `import_company()` checks
  // the one it has. Taking that away is the only honest way to write an
  // archive of 0.8.0 in a test of 0.9.0.
  //
  // Built in the database, and it has to be: taking a field out in JavaScript
  // means parsing the archive, which is the very thing under test. The rows
  // never leave `jsonb` here, so their numbers are the database's own.
  async function asWrittenBefore(): Promise<string> {
    return asUser(a, ownerId, async () =>
      (
        await one<{ archive: string }>(
          a,
          `select jsonb_set(x.archive, '{manifest,tables}',
                    (select jsonb_agg(t - 'values_sha256' order by n)
                       from jsonb_array_elements(x.archive -> 'manifest' -> 'tables')
                            with ordinality as e(t, n)))::text as archive
             from (select export_company($1) as archive) x`,
          [companyId],
        )
      ).archive,
    );
  }

  it('still arrives, checked against its bytes', async () => {
    const archive = await asWrittenBefore();
    expect(archive).not.toContain('values_sha256');
    const answer = await importInto(archive);
    expect(typeof answer, JSON.stringify(answer)).toBe('object');
  });

  it('is refused when it was printed again, and the refusal says why', async () => {
    const said = await importInto(reprint(await asWrittenBefore()));
    expect(typeof said).toBe('string');
    expect(said as string).toMatch(/archive_corrupt/);
    expect(said as string).toContain('0.9.0');
    expect(said as string).toContain('export it again');
  });
});

describe('what each checksum of the manifest answers', () => {
  it('keeps the one `shasum` checks, over the bytes the database wrote', async () => {
    const archive = JSON.parse(await exportText()) as Archive;
    const audit = archive.manifest.tables.find((t) => t.name === 'public.audit_log');
    expect(audit).toBeDefined();
    expect(audit!.sha256).toMatch(/^[0-9a-f]{64}$/);

    // The bytes of the file the CLI writes are the rows as the database wrote
    // them, one per line — so the same sha256, computed here the way `shasum`
    // computes it on that file.
    const lines = await asUser(a, ownerId, async () =>
      rows<{ row: string }>(
        a,
        `select r::text as row from export_company_table($1, 'public.audit_log') as r`,
        [companyId],
      ),
    );
    const { createHash } = await import('node:crypto');
    const body = lines.map((l) => `${l.row}\n`).join('');
    expect(createHash('sha256').update(body, 'utf8').digest('hex')).toBe(audit!.sha256);
  });

  it('adds one over the values, which a reader reproduces after parsing', async () => {
    const text = await exportText();
    const archive = JSON.parse(text) as Archive;
    const again = JSON.parse(reprint(text)) as Archive;
    for (const table of archive.manifest.tables) {
      const twin = again.manifest.tables.find((t) => t.name === table.name);
      expect(twin, table.name).toBeDefined();
      expect(table.values_sha256, `${table.name} carries a checksum over its values`).toMatch(
        /^[0-9a-f]{64}$/,
      );
      // The bytes change and the values do not: that is the whole distinction.
      expect(twin!.values_sha256, table.name).toBe(table.values_sha256);
    }
  });
});
