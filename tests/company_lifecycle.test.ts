/**
 * A company is archived, restored and deleted by its owner (decision 0081).
 *
 * Three acts, one actor. The owner archives a company and its books become
 * read-only for the ledger: posting an entry, booking a document, booking a
 * payment and closing a year are refused with `company_archived`, while the
 * books are still read and still leave as an archive. The owner restores it
 * and posting works again. The owner deletes it, by typing its name, once
 * nobody else reaches the books through it and no machine key is scoped to
 * it; then nothing of the company is left. An accountant and a viewer do none
 * of the three, the column is written by nobody, and `delete from companies`
 * is not a way out any more.
 *
 * The company is furnished with the golden scenario of a pack that carries
 * one, so that the deletion removes real books — entries, documents,
 * payments, matchings — and nothing here names a country.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { Pack, PackGolden } from '../packages/cli/src/index.js';
import { asUser, expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newDocument, newUser } from './helpers/factory.js';
import { replayScenario, type Replayed } from './helpers/golden-scenario.js';
import { allPacks } from './helpers/packs.js';

let db: PGlite;
let pack: Pack;
let golden: PackGolden;
let companyId: string;
let ownerId: string;
let accountantId: string;
let viewerId: string;
let replayed: Replayed;
/** The year before the scenario's, empty, so that closing it needs no figure. */
let previousYearId: string;

/** A draft sales or purchase document, shaped like the first one of the scenario. */
async function draftDocument(): Promise<string> {
  const model = golden.documents[0];
  if (model === undefined) throw new Error('the scenario has no document');
  return newDocument(db, companyId, {
    docType: model.type,
    contactId: replayed.contacts.get(model.contact) as string,
    date: model.date,
    supplyTerritory: model.supply_territory,
    lines: model.lines.map((line) => ({
      name: line.name,
      quantity: line.quantity,
      unitPrice: line.unit_price,
      discountPercent: line.discount_percent,
      taxCode: line.tax,
      accountCode: line.account,
    })),
  });
}

/** A payment not yet booked, shaped like the first one of the scenario. */
async function draftPayment(): Promise<string> {
  const model = golden.payments[0];
  if (model === undefined) throw new Error('the scenario has no payment');
  const row = await one<{ id: string }>(
    db,
    `insert into payments (company_id, direction, payment_date, amount, contact_id, journal_id)
     values ($1, $2, $3::date, $4, $5, (select id from journals where company_id = $1 and code = $6))
     returning id`,
    [companyId, model.direction, model.date, model.amount, replayed.contacts.get(model.contact) as string, model.journal],
  );
  return row.id;
}

async function member(role: 'accountant' | 'viewer'): Promise<string> {
  const id = await newUser(db);
  await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, $3)`, [
    companyId,
    id,
    role,
  ]);
  return id;
}

async function archivedAt(): Promise<string | null> {
  const row = await one<{ archived_at: string | null }>(db, `select archived_at from companies where id = $1`, [
    companyId,
  ]);
  return row.archived_at;
}

/** How many rows of the company a table holds. */
async function countOf(table: string): Promise<number> {
  const row = await one<{ n: number }>(db, `select count(*)::int as n from ${table} where company_id = $1`, [
    companyId,
  ]);
  return row.n;
}

beforeAll(async () => {
  db = await freshDatabase();
  const found = allPacks.find((p) => p.golden !== null);
  if (found === undefined || found.golden === null) throw new Error('no pack of this checkout carries a golden scenario');
  pack = found;
  golden = found.golden;

  ownerId = await newUser(db);
  ({ companyId } = await newCompany(db, {
    country: pack.manifest.country,
    name: 'Lifecycle Example',
    ownerId,
    chart: golden.chart,
    language: golden.language,
    fiscalYear: golden.fiscalYear,
  }));
  accountantId = await member('accountant');
  viewerId = await member('viewer');
  replayed = await replayScenario(db, companyId, golden);

  const start = new Date(`${golden.fiscalYear.start}T00:00:00Z`);
  const previousEnd = new Date(start.getTime() - 86_400_000);
  const previousStart = new Date(Date.UTC(start.getUTCFullYear() - 1, start.getUTCMonth(), start.getUTCDate()));
  previousYearId = (
    await one<{ id: string }>(
      db,
      `insert into fiscal_years (company_id, name, start_date, end_date)
       values ($1, 'The year before', $2::date, $3::date) returning id`,
      [companyId, previousStart.toISOString().slice(0, 10), previousEnd.toISOString().slice(0, 10)],
    )
  ).id;
}, 300_000);

afterAll(async () => {
  await db?.close();
});

// ---------------------------------------------------------------------------
// Archived: read-only for the ledger
// ---------------------------------------------------------------------------

describe('an archived company', () => {
  it('is archived by its owner, once', async () => {
    expect(await archivedAt()).toBeNull();
    const first = await asUser(db, ownerId, () =>
      one<{ archived_at: string | null }>(db, `select archived_at from archive_company($1)`, [companyId]),
    );
    expect(first.archived_at).not.toBeNull();

    // Archiving an archived company changes nothing and answers the row.
    const again = await asUser(db, ownerId, () =>
      one<{ archived_at: string | null }>(db, `select archived_at from archive_company($1)`, [companyId]),
    );
    expect(again.archived_at).toEqual(first.archived_at);

    const trail = await rows<{ action: string }>(
      db,
      `select action from audit_log where company_id = $1 and action = 'company_archived'`,
      [companyId],
    );
    expect(trail).toHaveLength(1);
  });

  it('refuses to post an entry', async () => {
    const entry = await one<{ id: string }>(
      db,
      `insert into entries (company_id, journal_id, entry_date, description)
       values ($1, (select miscellaneous_journal_id from companies where id = $1), $2::date, 'While archived')
       returning id`,
      [companyId, golden.fiscalYear.start],
    );
    // A balanced draft, so that the only reason left to refuse it is the archive.
    await db.query(
      `insert into entry_lines (entry_id, company_id, account_id, sequence, debit, credit)
       values ($1, $2, (select id from accounts where company_id = $2 and account_type = 'expense'
                        and not deprecated order by code limit 1), 10, 10, 0),
              ($1, $2, (select id from accounts where company_id = $2 and account_type = 'asset_cash'
                        and not deprecated order by code limit 1), 20, 0, 10)`,
      [entry.id, companyId],
    );
    const message = await asUser(db, ownerId, () => expectError(db, `select post_entry($1)`, [entry.id]));
    expect(message).toMatch(/^company_archived:/);
  });

  it('refuses to book a document', async () => {
    const documentId = await draftDocument();
    const message = await asUser(db, ownerId, () => expectError(db, `select post_document($1)`, [documentId]));
    expect(message).toMatch(/^company_archived:/);
    const state = await one<{ state: string; entry_id: string | null }>(
      db,
      `select state, entry_id from documents where id = $1`,
      [documentId],
    );
    expect(state).toEqual({ state: 'draft', entry_id: null });
  });

  it('refuses to book a payment', async () => {
    const paymentId = await draftPayment();
    const message = await asUser(db, ownerId, () => expectError(db, `select post_payment($1)`, [paymentId]));
    expect(message).toMatch(/^company_archived:/);
  });

  it('refuses to close a year', async () => {
    const message = await asUser(db, ownerId, () =>
      expectError(db, `select close_fiscal_year($1)`, [previousYearId]),
    );
    expect(message).toMatch(/^company_archived:/);
    const year = await one<{ is_closed: boolean }>(db, `select is_closed from fiscal_years where id = $1`, [
      previousYearId,
    ]);
    expect(year.is_closed).toBe(false);
  });

  it('is still read, and still leaves with its books', async () => {
    const seen = await asUser(db, ownerId, () =>
      one<{ entries: number; documents: number }>(
        db,
        `select (select count(*)::int from entries where company_id = $1) as entries,
                (select count(*)::int from documents where company_id = $1 and state = 'posted') as documents`,
        [companyId],
      ),
    );
    expect(seen.entries).toBeGreaterThan(0);
    expect(seen.documents).toBeGreaterThan(0);

    const archive = await asUser(db, ownerId, () =>
      one<{ archive: { manifest: { company: { id: string } }; tables: Record<string, unknown[]> } }>(
        db,
        `select export_company($1) as archive`,
        [companyId],
      ),
    );
    expect(archive.archive.manifest.company.id).toBe(companyId);
    expect((archive.archive.tables['ekwo.entries'] ?? []).length).toBe(seen.entries);
  });

  it('keeps its members and its profile', async () => {
    await asUser(db, ownerId, () =>
      db.query(`update companies set trade_name = 'Archived Trading' where id = $1`, [companyId]),
    );
    const row = await one<{ trade_name: string; members: number }>(
      db,
      `select trade_name, (select count(*)::int from company_members where company_id = $1) as members
         from companies where id = $1`,
      [companyId],
    );
    expect(row).toEqual({ trade_name: 'Archived Trading', members: 3 });
  });
});

// ---------------------------------------------------------------------------
// Restored: posting works again
// ---------------------------------------------------------------------------

describe('a restored company', () => {
  it('is restored by its owner, once', async () => {
    const first = await asUser(db, ownerId, () =>
      one<{ archived_at: string | null }>(db, `select archived_at from unarchive_company($1)`, [companyId]),
    );
    expect(first.archived_at).toBeNull();
    const again = await asUser(db, ownerId, () =>
      one<{ archived_at: string | null }>(db, `select archived_at from unarchive_company($1)`, [companyId]),
    );
    expect(again.archived_at).toBeNull();
    const trail = await rows<{ action: string }>(
      db,
      `select action from audit_log where company_id = $1 and action = 'company_unarchived'`,
      [companyId],
    );
    expect(trail).toHaveLength(1);
  });

  it('books a document again', async () => {
    const documentId = await draftDocument();
    await asUser(db, ownerId, () => db.query(`select post_document($1)`, [documentId]));
    const posted = await one<{ state: string; entry_id: string | null }>(
      db,
      `select state, entry_id from documents where id = $1`,
      [documentId],
    );
    expect(posted.state).toBe('posted');
    expect(posted.entry_id).not.toBeNull();
  });
});

// ---------------------------------------------------------------------------
// Who may, and how
// ---------------------------------------------------------------------------

describe('the three acts belong to the owner', () => {
  it.each([
    ['archive', 'select archive_company($1)'],
    ['restore', 'select unarchive_company($1)'],
  ])('an accountant and a viewer cannot %s', async (_act, sql) => {
    for (const userId of [accountantId, viewerId]) {
      const message = await asUser(db, userId, () => expectError(db, sql, [companyId]));
      expect(message).toMatch(/^not_allowed:/);
    }
    expect(await archivedAt()).toBeNull();
  });

  it('an accountant and a viewer cannot delete', async () => {
    for (const userId of [accountantId, viewerId]) {
      const message = await asUser(db, userId, () =>
        expectError(db, `select delete_company($1, $2)`, [companyId, 'Lifecycle Example']),
      );
      expect(message).toMatch(/^not_allowed:/);
    }
    expect(await countOf('entries')).toBeGreaterThan(0);
  });

  it('a stranger is told nothing but no', async () => {
    const strangerId = await newUser(db);
    const message = await asUser(db, strangerId, () => expectError(db, `select archive_company($1)`, [companyId]));
    expect(message).toMatch(/^not_allowed:/);
  });

  it('the column is written by nobody, the owner included', async () => {
    const message = await asUser(db, ownerId, () =>
      expectError(db, `update companies set archived_at = now() where id = $1`, [companyId]),
    );
    expect(message).toMatch(/^company_archive_not_a_column:/);
    expect(await archivedAt()).toBeNull();
  });

  it('delete from companies is not a way out any more', async () => {
    await asUser(db, ownerId, async () => {
      // Refused by the grant, or judged by no policy and so deleting nothing:
      // either way the company is still there.
      await db.query(`delete from companies where id = $1`, [companyId]).catch(() => undefined);
    });
    const still = await rows(db, `select 1 from companies where id = $1`, [companyId]);
    expect(still).toHaveLength(1);
    const policies = await rows<{ polname: string }>(
      db,
      `select p.polname from pg_policy p join pg_class c on c.oid = p.polrelid
        where c.relname = 'companies' and p.polcmd = 'd'`,
    );
    expect(policies).toEqual([]);
  });
});

// ---------------------------------------------------------------------------
// Deleted: by name, alone, and then nothing is left
// ---------------------------------------------------------------------------

describe('deleting a company', () => {
  let apiKeyId: string;

  it('is refused with the wrong name', async () => {
    for (const given of ['lifecycle example', 'Lifecycle Example ', '', null]) {
      const message = await asUser(db, ownerId, () =>
        expectError(db, `select delete_company($1, $2)`, [companyId, given]),
      );
      expect(message, `given ${JSON.stringify(given)}`).toMatch(/^company_name_mismatch:/);
    }
  });

  it('is refused while another member reaches the books', async () => {
    const message = await asUser(db, ownerId, () =>
      expectError(db, `select delete_company($1, $2)`, [companyId, 'Lifecycle Example']),
    );
    expect(message).toMatch(/^company_has_other_members: 2 other member/);
  });

  it('is refused while a machine key of the company is live', async () => {
    await asUser(db, ownerId, async () => {
      await db.query(`select remove_member($1, $2)`, [companyId, accountantId]);
      await db.query(`select remove_member($1, $2)`, [companyId, viewerId]);
    });
    const key = await asUser(db, ownerId, () =>
      one<{ api_key_id: string }>(
        db,
        `select api_key_id from create_api_key($1, 'Nightly export', '["entries.read"]'::jsonb)`,
        [companyId],
      ),
    );
    apiKeyId = key.api_key_id;
    const message = await asUser(db, ownerId, () =>
      expectError(db, `select delete_company($1, $2)`, [companyId, 'Lifecycle Example']),
    );
    expect(message).toMatch(/^company_has_live_keys: 1 machine key/);
  });

  it('deletes the company and everything that belonged to it', async () => {
    await asUser(db, ownerId, () => db.query(`select revoke_api_key($1)`, [apiKeyId]));

    const before = {
      entries: await countOf('entries'),
      entry_lines: await countOf('entry_lines'),
      documents: await countOf('documents'),
      payments: await countOf('payments'),
      reconciliations: await countOf('reconciliations'),
      contacts: await countOf('contacts'),
      accounts: await countOf('accounts'),
      journals: await countOf('journals'),
      fiscal_years: await countOf('fiscal_years'),
      company_members: await countOf('company_members'),
      api_keys: await countOf('api_keys'),
    };
    for (const [table, n] of Object.entries(before)) {
      expect(n, `${table} before`).toBeGreaterThan(0);
    }

    await asUser(db, ownerId, () => db.query(`select delete_company($1, $2)`, [companyId, 'Lifecycle Example']));

    expect(await rows(db, `select 1 from companies where id = $1`, [companyId])).toEqual([]);
    for (const table of Object.keys(before)) {
      expect(await countOf(table), `${table} after`).toBe(0);
    }

    // Every table of a company, read from the catalogue: nothing of this one
    // is left anywhere, in the socle or in a module.
    const scoped = await rows<{ table_schema: string; table_name: string; has_company_id: boolean }>(
      db,
      `select * from company_scoped_tables() where has_company_id`,
    );
    // The trail is the one table of a company with no foreign key to it: it
    // outlives the company, as checked below.
    for (const table of scoped.filter((t) => !(t.table_schema === 'ekwo' && t.table_name === 'audit_log'))) {
      const row = await one<{ n: number }>(
        db,
        `select count(*)::int as n from ${table.table_schema}.${table.table_name} where company_id = $1`,
        [companyId],
      );
      expect(row.n, `${table.table_schema}.${table.table_name} after`).toBe(0);
    }

    // The trail is not a table of the company: it keeps what it holds, and
    // ends with the deletion.
    const trail = await rows<{ action: string | null }>(
      db,
      `select action from audit_log where company_id = $1 order by id desc limit 1`,
      [companyId],
    );
    expect(trail).toEqual([{ action: 'company_deleted' }]);

    // The guards are back on the tables they were taken off.
    const off = await rows<{ tgname: string }>(
      db,
      `select g.tgname from pg_trigger g where not g.tgisinternal and g.tgenabled <> 'O'`,
    );
    expect(off).toEqual([]);
  });
});
