/**
 * A company leaves an installation with its books, and arrives in another one
 * alive.
 *
 * A firm keeps N companies in one installation, and the client owns the books:
 * so one company has to be able to leave, whole, without the others — and to
 * become a living company somewhere else. This file is that sentence as a
 * test, and it is asked of every pack of the checkout that carries a year of
 * books and a declaration form. Nothing here names a country.
 *
 * Installation A holds two companies per pack, furnished the same way on
 * purpose: whatever table the one that leaves has rows in, the one that stays
 * has rows in too, so "nothing of the other company is in the archive" is
 * asked of every table and not only of the ledger. Installation B starts with
 * the same socle and the same packs, and no company.
 *
 * What is proved, in the order of the blocks below:
 *
 *   - the registry against the catalogue: a table of a company that nobody
 *     classified stops the export, by name;
 *   - the right: `company.export`, under row level security, and an archive is
 *     whole or is not written;
 *   - the archive holds nothing of the other company — swept, not listed;
 *   - trial balance, general ledger, the return and `filing_drift()` agree to
 *     the cent on both sides;
 *   - the declaration that went is still frozen and its proof is there;
 *   - the locks hold in B;
 *   - the next number in B is the next number in A;
 *   - a second import is refused.
 *
 * Every archive that lies, the backend role on a session nobody prepared, and
 * what is written down as missing are in `company_archive_refusals.test.ts`.
 */

import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import type { Pack, PackGolden } from '../packages/cli/src/index.js';
import { asUser, expectError, freshDatabase, one, repoRoot, rows } from './helpers/db.js';
import {
  STAYS,
  UUID,
  breathe,
  exportAs,
  figures,
  filers,
  furnish,
  importAs,
  type Archive,
  type Furnished,
} from './helpers/company-archive.js';
import { newCompany, newInstanceAdmin, newUser } from './helpers/factory.js';

let a: PGlite;
let b: PGlite;
let adminOfB: string;

beforeAll(async () => {
  a = await freshDatabase();
  b = await freshDatabase();
  adminOfB = await newInstanceAdmin(b);
}, 300_000);

afterEach(breathe);

afterAll(async () => {
  await a?.close();
  await b?.close();
});

// ---------------------------------------------------------------------------
// The registry, against the catalogue
// ---------------------------------------------------------------------------

describe('what belongs to a company is read from the catalogue', () => {
  it('classifies every table of a company, in the socle and in every module', async () => {
    const problems = await rows(a, `select * from company_archive_unclassified()`);
    expect(problems, 'a table of a company is neither exported nor excluded').toEqual([]);

    // The claim is not vacuous: the catalogue finds the tables that carry no
    // `company_id` and reach a company through another table.
    const scoped = await rows<{ table_schema: string; table_name: string; has_company_id: boolean }>(
      a,
      `select * from company_scoped_tables()`,
    );
    const indirect = scoped.filter((t) => !t.has_company_id).map((t) => `${t.table_schema}.${t.table_name}`);
    expect(indirect).toEqual(
      expect.arrayContaining(['public.journal_sequences', 'public.tax_filing_boxes', 'public.tax_filing_deposits']),
    );
    const modules = await rows<{ schema_name: string }>(a, `select schema_name from modules`);
    for (const module of modules) {
      expect(
        scoped.some((t) => t.table_schema === module.schema_name),
        `the ${module.schema_name} module has tables of a company, and the catalogue sees them`,
      ).toBe(true);
    }
  });

  it('says why, for every table it leaves behind', async () => {
    const excluded = await rows<{ table_name: string; reason: string | null }>(
      a,
      `select table_name, reason from company_archive_tables() where disposition = 'excluded'`,
    );
    expect(excluded.length).toBeGreaterThan(0);
    for (const table of excluded) {
      expect((table.reason ?? '').length, `${table.table_name} is excluded without a reason`).toBeGreaterThan(20);
    }
    // No secret and nobody's membership travels.
    expect(excluded.map((t) => t.table_name)).toEqual(
      expect.arrayContaining(['api_keys', 'company_members', 'company_invitations', 'document_shares']),
    );
  });

  it('is the list the documentation of the format gives', async () => {
    const page = await readFile(join(repoRoot, 'docs', 'company-archive.md'), 'utf8');
    const tables = await rows<{ table_schema: string; table_name: string }>(
      a,
      `select table_schema, table_name from company_archive_tables()`,
    );
    for (const table of tables) {
      const written = table.table_schema === 'public' ? table.table_name : `${table.table_schema}.${table.table_name}`;
      expect(page, `docs/company-archive.md does not mention ${written}`).toContain(`\`${written}\``);
    }
  });

  it('can order every table it exports, and write every row it reads', async () => {
    const unordered = await rows(
      a,
      `select t.table_schema, t.table_name
         from company_archive_tables() t
        where t.disposition = 'exported'
          and not exists (select 1 from pg_index i
                           where i.indrelid = to_regclass(format('%I.%I', t.table_schema, t.table_name))
                             and i.indisprimary)`,
    );
    expect(unordered, 'an exported table has no primary key to order its rows by').toEqual([]);

    // A reference that points forward, or at its own table, is filled in a
    // second pass: it has to be nullable, and its table has to have an `id`.
    const stuck = await rows(
      a,
      `select c.conrelid::regclass::text as child, a.attname as col, a.attnotnull as required,
              exists (select 1 from pg_attribute i where i.attrelid = c.conrelid and i.attname = 'id') as has_id
         from pg_constraint c
         join pg_class ck on ck.oid = c.conrelid join pg_namespace cn on cn.oid = ck.relnamespace
         join pg_class pk on pk.oid = c.confrelid join pg_namespace pn on pn.oid = pk.relnamespace
         join company_archive_tables() ct on ct.table_schema = cn.nspname and ct.table_name = ck.relname
         join company_archive_tables() pt on pt.table_schema = pn.nspname and pt.table_name = pk.relname
         join unnest(c.conkey) as k(attnum) on true
         join pg_attribute a on a.attrelid = c.conrelid and a.attnum = k.attnum
        where c.contype = 'f' and ct.disposition = 'exported' and pt.disposition = 'exported'
          and pt.load_order >= ct.load_order and a.attname <> 'company_id'
          and (a.attnotnull or not exists (select 1 from pg_attribute i
                                            where i.attrelid = c.conrelid and i.attname = 'id'))`,
    );
    expect(stuck, 'a required reference points at a table that loads later').toEqual([]);

    // An exported table never depends on an excluded one for a required column.
    const orphaned = await rows(
      a,
      `select c.conrelid::regclass::text as child, c.confrelid::regclass::text as parent
         from pg_constraint c
         join pg_class ck on ck.oid = c.conrelid join pg_namespace cn on cn.oid = ck.relnamespace
         join pg_class pk on pk.oid = c.confrelid join pg_namespace pn on pn.oid = pk.relnamespace
         join company_archive_tables() ct on ct.table_schema = cn.nspname and ct.table_name = ck.relname
         join company_archive_tables() pt on pt.table_schema = pn.nspname and pt.table_name = pk.relname
        where c.contype = 'f' and ct.disposition = 'exported' and pt.disposition = 'excluded'`,
    );
    expect(orphaned, 'an exported table references one that stays behind').toEqual([]);
  });

  it('stops the export, by name, the day a table is added and not classified', async () => {
    const db = await freshDatabase();
    try {
      const owner = await newUser(db);
      const pack = filers[0] as Pack;
      const { companyId } = await newCompany(db, { country: pack.manifest.country, ownerId: owner });

      await db.exec(`
        create table zz_notes (id uuid primary key default gen_random_uuid(),
                               company_id uuid not null references companies(id), body text);
        create table zz_journal_marks (journal_id uuid primary key references journals(id), mark text);
        grant select on zz_notes, zz_journal_marks to authenticated;
      `);
      const problems = await rows<{ table_name: string }>(db, `select * from company_archive_unclassified()`);
      expect(problems.map((p) => p.table_name).sort()).toEqual(['zz_journal_marks', 'zz_notes']);

      const refusal = await asUser(db, owner, () => expectError(db, `select export_company($1)`, [companyId]));
      expect(refusal).toContain('unclassified_table');
      expect(refusal).toMatch(/zz_(notes|journal_marks)/);

      // Classifying is a row: one leaves, one stays and says why.
      await db.exec(`
        insert into company_archive_registry (table_name, disposition, load_order, via_column, via_table)
        values ('zz_journal_marks', 'exported', 95, 'journal_id', 'public.journals');
        insert into company_archive_registry (table_name, disposition, reason)
        values ('zz_notes', 'excluded', 'A scratch table of this test, which no company would miss.');
      `);
      await db.query(
        `insert into zz_journal_marks (journal_id, mark)
         select id, 'kept' from journals where company_id = $1 order by code limit 1`,
        [companyId],
      );
      const archive = JSON.parse(await exportAs(db, owner, companyId)) as Archive;
      expect(archive.tables['public.zz_journal_marks']).toHaveLength(1);
      expect(archive.manifest.excluded.map((t) => t.name)).toContain('public.zz_notes');
    } finally {
      await db.close();
    }
  }, 120_000);

  it('follows a module that answers for its tables, and notices one that does not', async () => {
    const db = await freshDatabase();
    try {
      await db.exec(`drop function budgets.archive_tables();`);
      const problems = await rows<{ table_schema: string; table_name: string }>(
        db,
        `select * from company_archive_unclassified()`,
      );
      expect(problems.map((p) => `${p.table_schema}.${p.table_name}`).sort()).toEqual([
        'budgets.budgets',
        'budgets.lines',
      ]);
    } finally {
      await db.close();
    }
  }, 120_000);
});


// ---------------------------------------------------------------------------
// The journey, pack by pack
// ---------------------------------------------------------------------------

describe.each(filers.map((pack) => [pack.slug, pack] as const))(
  'a company on the %s pack leaves A and arrives in B',
  (slug, pack) => {
    const golden = pack.golden as PackGolden;
    let leaves: Furnished;
    let stays: Furnished;
    let text: string;
    let archive: Archive;
    let ownerInB: string;
    let before: Record<string, unknown>;

    beforeAll(async () => {
      leaves = await furnish(a, pack, `${golden.name} — leaves`, 'LEAVES');
      stays = await furnish(a, pack, `${golden.name} — ${STAYS}`, STAYS);
      before = await figures(a, leaves.ownerId, leaves, golden);
      text = await exportAs(a, leaves.ownerId, leaves.companyId);
      archive = JSON.parse(text) as Archive;
      ownerInB = await newUser(b);
    }, 300_000);

    it('needs company.export, runs under row level security, and is whole or not written', async () => {
      // Held by the owner and by the client; not by whoever keeps the books,
      // not by a reader, not by a stranger, not by the backend role, and not
      // by the connection that installed the schema.
      const member = async (role: string): Promise<string> => {
        const id = await newUser(a);
        await a.query(`insert into company_members (company_id, user_id, role) values ($1, $2, $3)`, [
          leaves.companyId, id, role,
        ]);
        return id;
      };
      for (const role of ['accountant', 'viewer']) {
        const refusal = await asUser(a, await member(role), () =>
          expectError(a, `select export_company($1)`, [leaves.companyId]),
        );
        expect(refusal, `${role} left with the books`).toContain('not_allowed');
      }
      const stranger = await asUser(a, stays.ownerId, () =>
        expectError(a, `select export_company($1)`, [leaves.companyId]),
      );
      expect(stranger).toContain('not_allowed');
      const backend = await asUser(
        a, leaves.ownerId, () => expectError(a, `select export_company($1)`, [leaves.companyId]), 'service_role',
      ).catch((error: Error) => error.message);
      expect(backend).toMatch(/not_allowed|permission denied/);
      expect(await expectError(a, `select export_company($1)`, [leaves.companyId])).toContain('not_allowed');

      // The client of a firm leaves with the same archive the owner does.
      const client = await member('client');
      const theirs = JSON.parse(await exportAs(a, client, leaves.companyId)) as Archive;
      const ours = JSON.parse(await exportAs(a, leaves.ownerId, leaves.companyId)) as Archive;
      const counts = (x: Archive): Record<string, number> =>
        Object.fromEntries(x.manifest.tables.filter((t) => t.name !== 'public.audit_log').map((t) => [t.name, t.rows]));
      expect(counts(theirs)).toEqual(counts(ours));

      // Row level security hands back fewer rows and says nothing. The export says it.
      await a.query(
        `update company_members set capabilities_revoked = array['bank.read'] where company_id = $1 and user_id = $2`,
        [leaves.companyId, client],
      );
      const partial = await asUser(a, client, () => expectError(a, `select export_company($1)`, [leaves.companyId]));
      expect(partial).toContain('export_incomplete');
      expect(partial).toContain('public.bank_');

      // And leaving is an act the company can see.
      const noted = await rows<{ actor_id: string }>(
        a,
        `select actor_id from audit_log where company_id = $1 and action = 'company_exported'`,
        [leaves.companyId],
      );
      expect(noted.map((n) => n.actor_id)).toEqual(expect.arrayContaining([leaves.ownerId, client]));
    });

    it('says what it is, what it needs, and what it leaves behind', () => {
      expect(archive.manifest.format).toBe('ekwo.company-archive');
      expect(archive.manifest.format_version).toBe(1);
      expect(archive.manifest.company.id).toBe(leaves.companyId);
      expect(archive.manifest.packs.map((p) => p.country)).toEqual([pack.manifest.country]);
      expect(archive.manifest.modules.map((m) => m.code)).toEqual(['assets', 'budgets']);
      expect(Object.keys(archive.tables).sort()).toEqual(archive.manifest.tables.map((t) => t.name).sort());

      // The files are listed, and said not to be carried.
      expect(archive.manifest.files.transported).toBe(false);
      expect(archive.manifest.files.list).toHaveLength(3);
      for (const file of archive.manifest.files.list) expect(file.storage_path).toContain(leaves.companyId);

      // Decimals are text, all the way down to six places.
      const product = (archive.tables['public.products'] ?? [])[0] as Record<string, unknown>;
      expect(product['sale_price']).toBe('12.345678');

      // Furnished on purpose: a table this file fills is a table the import
      // has really written. What stays empty is printed rather than hidden.
      const empty = archive.manifest.tables.filter((t) => t.rows === 0).map((t) => t.name).sort();
      expect(empty, `${slug}: tables the journey never exercised`).toEqual(
        [
          // A disposal posts to the ledger under rules a pack may not carry.
          'assets.disposals',
          ...(empty.includes('public.company_filing_periods') ? ['public.company_filing_periods'] : []),
        ].sort(),
      );
    });

    it('holds nothing of the company that stays', async () => {
      expect(text).not.toContain(STAYS);
      expect(text).not.toContain(stays.companyId);
      expect(text).not.toContain(stays.ownerId);

      // Swept, not listed: every identifier that appears anywhere in the
      // archive of the other company — whatever the table, whatever the
      // column, inside a jsonb or not — is absent from this one.
      const other = await exportAs(a, stays.ownerId, stays.companyId);
      expect(other).toContain(STAYS);
      const theirs = new Set(other.match(UUID) ?? []);
      const ours = new Set(text.match(UUID) ?? []);
      // The installation is the one thing the two have in common.
      const origin = (await one<{ id: string }>(a, `select instance_id::text as id from instance`)).id;
      const shared = [...ours].filter((id) => theirs.has(id) && id !== origin);
      expect(shared, 'an identifier of the company that stays is in the archive').toEqual([]);
      expect(theirs.size).toBeGreaterThan(100);

      // And the other way round: every row of the archive is of this company.
      for (const [table, tableRows] of Object.entries(archive.tables)) {
        for (const row of tableRows) {
          if ('company_id' in row) expect(row['company_id'], table).toBe(leaves.companyId);
        }
      }
    });

    it('arrives in B by the hand of an administrator, and of nobody else', async () => {
      const nobody = await asUser(b, ownerInB, () => expectError(b, `select import_company($1::jsonb)`, [text]));
      expect(nobody).toContain('not_instance_admin');
      const backend = await asUser(b, ownerInB, () => expectError(b, `select import_company($1::jsonb)`, [text]), 'service_role');
      expect(backend).toContain('not_instance_admin');

      const result = await importAs(b, adminOfB, text, ownerInB);
      expect(result['company_id']).toBe(leaves.companyId);
      expect(result['files_to_carry']).toBe(3);

      // Every guard that was switched off is back on.
      const off = await rows(b, `select tgrelid::regclass::text, tgname from pg_trigger where tgenabled <> 'O'`);
      expect(off).toEqual([]);

      // The people did not travel; the one the administrator named owns it.
      const members = await rows<{ user_id: string; role: string }>(
        b,
        `select user_id, role from company_members where company_id = $1`,
        [leaves.companyId],
      );
      expect(members).toEqual([{ user_id: ownerInB, role: 'owner' }]);
      for (const table of ['api_keys', 'company_invitations', 'document_shares']) {
        const held = await one<{ n: number }>(b, `select count(*)::int as n from ${table} where company_id = $1`, [
          leaves.companyId,
        ]);
        expect(held.n, table).toBe(0);
      }
    });

    it('agrees with A to the cent: balance, ledger, return and drift', async () => {
      const after = await figures(b, ownerInB, leaves, golden);
      expect(after).toEqual(before);
      expect((before['trialBalance'] as unknown[]).length).toBeGreaterThan(0);
      expect((before['generalLedger'] as unknown[]).length).toBeGreaterThan(0);
      expect((before['taxReturn'] as unknown[]).length).toBeGreaterThan(0);
      // Nothing moved after the declaration went, on either side.
      expect(before['drift']).toEqual([]);

      // Row for row: what B would export is what A exported, the trail aside —
      // B's own testimony starts with the import.
      const back = JSON.parse(await exportAs(b, ownerInB, leaves.companyId)) as Archive;
      for (const table of archive.manifest.tables) {
        if (table.name === 'public.audit_log') continue;
        const there = back.manifest.tables.find((t) => t.name === table.name);
        expect(there?.sha256, `${table.name} is not the same rows in B`).toBe(table.sha256);
      }
    });

    it('keeps the declaration frozen, and its proof', async () => {
      const filing = await one<{ state: string; reference: string; filed_by: string }>(
        b,
        `select state, reference, filed_by from tax_filings where id = $1`,
        [leaves.filingId],
      );
      expect(filing.state).toBe('accepted');
      expect(filing.reference).toBe('REF-LEAVES');
      // Who filed is a trace: the identifier, and nobody of this installation.
      expect(filing.filed_by).toBe(leaves.ownerId);
      const known = await one<{ n: number }>(b, `select count(*)::int as n from auth.users where id = $1`, [leaves.ownerId]);
      expect(known.n).toBe(0);

      const boxes = (table: PGlite) =>
        rows(table, `select box, kind, amount::text from tax_filing_boxes where filing_id = $1 order by box, kind`, [
          leaves.filingId,
        ]);
      expect(await boxes(b)).toEqual(await boxes(a));
      expect((await boxes(b)).length).toBeGreaterThan(0);

      const proof = await rows<{ sent: string | null; ack: string | null; outcome: string; message: string }>(
        b,
        `select s.storage_path as sent, k.storage_path as ack, d.outcome, d.message
           from tax_filing_deposits d
           left join attachments s on s.id = d.sent_file_id
           left join attachments k on k.id = d.acknowledgement_id
          where d.filing_id = $1`,
        [leaves.filingId],
      );
      expect(proof).toHaveLength(1);
      expect(proof[0]?.outcome).toBe('accepted');
      expect(proof[0]?.sent).toContain('declaration.xml');
      expect(proof[0]?.ack).toContain('acknowledgement.pdf');

      // Frozen for the owner of B as it was for the owner of A.
      const thaw = await asUser(b, ownerInB, () =>
        expectError(b, `update tax_filing_boxes set amount = amount + 1 where filing_id = $1`, [leaves.filingId]),
      );
      expect(thaw).toContain('filing_is_frozen');
      const again = await asUser(b, ownerInB, () =>
        expectError(b, `select prepare_filing($1, $2::date, $3::date)`, [
          leaves.companyId, leaves.period.from, leaves.period.to,
        ]),
      );
      expect(again).toContain('filing_already_accepted');

      // The draft of the next period travelled as a draft, and can still be prepared again.
      const draft = await one<{ state: string }>(b, `select state from tax_filings where id = $1`, [leaves.draftFilingId]);
      expect(draft.state).toBe('draft');
    });

    it('restores the locks: the dates, the closed year, and what they refuse', async () => {
      const company = await one<{ lock_date: string; tax_lock_date: string }>(
        b,
        `select lock_date::text, tax_lock_date::text from companies where id = $1`,
        [leaves.companyId],
      );
      expect(company).toEqual({ lock_date: leaves.lockDate, tax_lock_date: leaves.lockDate });

      const years = (table: PGlite) =>
        rows(table, `select name, start_date::text, end_date::text, is_closed from fiscal_years where company_id = $1 order by start_date`, [
          leaves.companyId,
        ]);
      expect(await years(b)).toEqual(await years(a));
      const closed = await one<{ is_closed: boolean; closed_at: string | null }>(
        b,
        `select is_closed, closed_at::text from fiscal_years where id = $1`,
        [leaves.closedYearId],
      );
      expect(closed.is_closed).toBe(true);
      expect(closed.closed_at).not.toBeNull();

      // A document dated inside the lock is refused in B with the words A uses.
      const first = golden.documents[0] as PackGolden['documents'][number];
      const tryLocked = async (db: PGlite, owner: string): Promise<string> =>
        asUser(db, owner, async () => {
          const doc = await one<{ id: string }>(
            db,
            `insert into documents (company_id, doc_type, contact_id, document_date)
             values ($1, $2, $3, $4::date) returning id`,
            [leaves.companyId, first.type, leaves.replayed.contacts.get(first.contact), leaves.period.from],
          );
          await db.query(
            `insert into document_lines (document_id, company_id, sequence, name, quantity, unit_price, tax_id, account_id)
             values ($1, $2, 10, 'Late', 1, 10,
                     (select id from taxes where company_id = $2 and code = $3), account_id_by_code($2, $4))`,
            [doc.id, leaves.companyId, first.lines[0]?.tax ?? null, first.lines[0]?.account],
          );
          const message = await expectError(db, `select post_document($1)`, [doc.id]);
          await db.query(`delete from documents where id = $1`, [doc.id]);
          return message;
        });
      const refusedInA = await tryLocked(a, leaves.ownerId);
      const refusedInB = await tryLocked(b, ownerInB);
      expect(refusedInB).toBe(refusedInA);
      expect(refusedInB).toMatch(/lock/i);
    });

    it('continues the numbering: the next number in B is the next number in A', async () => {
      const first = golden.documents[0] as PackGolden['documents'][number];
      const postNext = async (db: PGlite, owner: string): Promise<string> =>
        asUser(db, owner, async () => {
          const doc = await one<{ id: string }>(
            db,
            `insert into documents (company_id, doc_type, contact_id, document_date)
             values ($1, $2, $3, $4::date) returning id`,
            [leaves.companyId, first.type, leaves.replayed.contacts.get(first.contact), golden.fiscalYear.end],
          );
          await db.query(
            `insert into document_lines (document_id, company_id, sequence, name, quantity, unit_price, tax_id, account_id)
             values ($1, $2, 10, 'The day after arriving', 1, 100,
                     (select id from taxes where company_id = $2 and code = $3), account_id_by_code($2, $4))`,
            [doc.id, leaves.companyId, first.lines[0]?.tax ?? null, first.lines[0]?.account],
          );
          await db.query(`select post_document($1)`, [doc.id]);
          return (await one<{ number: string }>(db, `select number from documents where id = $1`, [doc.id])).number;
        });

      const used = new Set(
        (await rows<{ number: string }>(b, `select number from entries where company_id = $1 and number is not null`, [
          leaves.companyId,
        ])).map((r) => r.number),
      );
      const counterBefore = await rows<{ journal_id: string; year: number; last_number: number }>(
        b,
        `select s.journal_id, s.year, s.last_number from journal_sequences s
           join journals j on j.id = s.journal_id where j.company_id = $1 order by 1, 2`,
        [leaves.companyId],
      );

      const inB = await postNext(b, ownerInB);
      const inA = await postNext(a, leaves.ownerId);
      expect(inB, 'B drew another number than A would have').toBe(inA);
      expect(used.has(inB), 'B drew a number that was already used').toBe(false);

      // No hole: exactly one counter moved, by exactly one.
      const counterAfter = await rows<{ journal_id: string; year: number; last_number: number }>(
        b,
        `select s.journal_id, s.year, s.last_number from journal_sequences s
           join journals j on j.id = s.journal_id where j.company_id = $1 order by 1, 2`,
        [leaves.companyId],
      );
      const moved = counterAfter.filter(
        (now) => counterBefore.find((was) => was.journal_id === now.journal_id && was.year === now.year)?.last_number !== now.last_number,
      );
      expect(moved).toHaveLength(1);
      const was = counterBefore.find((c) => c.journal_id === moved[0]?.journal_id && c.year === moved[0]?.year);
      expect(moved[0]?.last_number).toBe((was?.last_number ?? 0) + 1);

      // The letters of the matching continue too.
      const letters = (table: PGlite) =>
        one<{ last_number: number }>(table, `select last_number from matching_sequences where company_id = $1`, [
          leaves.companyId,
        ]);
      expect((await letters(b)).last_number).toBe((await letters(a)).last_number);
    });

    it('is a living company: its trail goes on, and B wrote where its own testimony starts', async () => {
      const trail = await rows<{ action: string | null; actor_id: string | null }>(
        b,
        `select action, actor_id from audit_log where company_id = $1 order by id`,
        [leaves.companyId],
      );
      const arrived = trail.findIndex((row) => row.action === 'company_imported');
      expect(arrived).toBeGreaterThan(0);
      expect(trail[arrived]?.actor_id).toBe(adminOfB);
      // Before it, what the archive said, acts of A's people included.
      expect(trail.slice(0, arrived).some((row) => row.action === 'company_exported')).toBe(true);
      // After it, the document B posted.
      expect(trail.slice(arrived + 1).some((row) => row.action === 'document_posted')).toBe(true);

      // The module came on with the company, and its rows read under B's row level security.
      const budgets = await asUser(b, ownerInB, () =>
        rows<{ name: string }>(b, `select name from budgets.budgets where company_id = $1`, [leaves.companyId]),
      );
      expect(budgets).toEqual([{ name: 'Budget LEAVES' }]);
    });

    it('refuses to arrive twice', async () => {
      const count = async (): Promise<number> =>
        (await one<{ n: number }>(b, `select count(*)::int as n from entries where company_id = $1`, [leaves.companyId])).n;
      const held = await count();
      const again = await asUser(b, adminOfB, () => expectError(b, `select import_company($1::jsonb)`, [text]));
      expect(again).toContain('company_already_here');
      expect(await count()).toBe(held);

      // Nor does it come home while it is still there.
      const admin = await newInstanceAdmin(a);
      const home = await asUser(a, admin, () => expectError(a, `select import_company($1::jsonb)`, [text]));
      expect(home).toContain('company_already_here');
    });
  },
);

