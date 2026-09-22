/**
 * A company leaves an installation with its books — the refusals.
 *
 * `tests/company_archive.test.ts` is the journey of an honest archive. This
 * file is everything that must not get through: an archive that lies, offered
 * to an installation that already keeps somebody else's books; the backend
 * role on a session nobody prepared; and what `docs/decisions/0043-a-company-leaves-with-its-books.md` writes down
 * as missing, tested as it stands. Nothing here names a country.
 */

import { PGlite } from '@electric-sql/pglite';
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import type { Pack } from '../packages/cli/src/index.js';
import { asUser, expectError, freshDatabase, one, rows } from './helpers/db.js';
import {
  breathe,
  exportAs,
  filers,
  furnish,
  importAs,
  reseal,
  type Archive,
  type Furnished,
  type Manifest,
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
// An archive that lies
// ---------------------------------------------------------------------------

describe('an archive that lies is refused whole', () => {
  const pack = filers[0] as Pack;
  let honest: string;
  let victim: Furnished;
  let liar: Furnished;

  beforeAll(async () => {
    // The victim lives in B already; the liar tries to arrive beside it.
    victim = await furnish(a, pack, 'Victim', 'VICTIM');
    await importAs(b, adminOfB, await exportAs(a, victim.ownerId, victim.companyId));
    liar = await furnish(a, pack, 'Liar', 'LIAR');
    honest = await exportAs(a, liar.ownerId, liar.companyId);
  }, 300_000);

  /**
   * Bends the honest archive and offers it to B. Going through `JSON.parse`
   * rewrites `1.50` as `1.5` inside the jsonb columns, so every table is sealed
   * again by default — the lie under test is then the only one. `sealed: false`
   * bends after the seal, which is what a file changed on the way looks like.
   */
  const attempt = async (bend: (archive: Archive) => Promise<void> | void, sealed = true): Promise<string> => {
    const archive = JSON.parse(honest) as Archive;
    if (sealed) await bend(archive);
    for (const table of Object.keys(archive.tables)) await reseal(b, archive, table);
    if (!sealed) await bend(archive);
    const message = await asUser(b, adminOfB, () =>
      expectError(b, `select import_company($1::jsonb)`, [JSON.stringify(archive)]),
    );
    // Whole: nothing of it stays, and every guard is back on.
    const left = await one<{ n: number }>(b, `select count(*)::int as n from companies where id = $1`, [liar.companyId]);
    expect(left.n).toBe(0);
    const off = await rows(b, `select tgname from pg_trigger where tgenabled <> 'O'`);
    expect(off).toEqual([]);
    return message;
  };

  const firstRow = (archive: Archive, table: string): Record<string, unknown> =>
    (archive.tables[table] ?? [])[0] as Record<string, unknown>;

  it('a row changed after the manifest was written', async () => {
    expect(await attempt((x) => { firstRow(x, 'public.contacts')['name'] = 'Somebody else'; }, false)).toContain('archive_corrupt');
  });

  it('rows that do not all have the same columns, or no company at all', async () => {
    expect(
      await attempt((x) => { delete (x.tables['public.contacts'] as Record<string, unknown>[])[1]?.['notes']; }),
    ).toContain('archive_corrupt');
    expect(await attempt((x) => { x.tables['public.companies'] = []; })).toContain('foreign_row');
    expect(await attempt((x) => { delete firstRow(x, 'public.companies')['id']; })).toContain('foreign_row');
    expect(
      await attempt((x) => { delete (x.manifest.tables[0] as Partial<Manifest['tables'][number]>).rows; }, false),
    ).toContain('archive_corrupt');
  });

  it('a row that says it is of another company', async () => {
    expect(
      await attempt((x) => { firstRow(x, 'public.contacts')['company_id'] = victim.companyId; }),
    ).toContain('foreign_row');
  });

  it('a figure hung on the declaration of a company that was already here', async () => {
    const message = await attempt((x) => {
      (x.tables['public.tax_filing_boxes'] as Record<string, unknown>[]).push({
        ...firstRow(x, 'public.tax_filing_boxes'), filing_id: victim.filingId, box: 'ZZ',
      });
    });
    expect(message).toContain('foreign_row');
    const planted = await one<{ n: number }>(b, `select count(*)::int as n from tax_filing_boxes where box = 'ZZ'`);
    expect(planted.n).toBe(0);
  });

  it('a reference that reaches into a company that was already here', async () => {
    const theirs = await one<{ id: string }>(b, `select id from entries where company_id = $1 limit 1`, [victim.companyId]);
    expect(
      await attempt((x) => { firstRow(x, 'public.entries')['reversed_entry_id'] = theirs.id; }),
    ).toContain('foreign_row');
  });

  it('an entry that does not balance', async () => {
    const message = await attempt((x) => {
      const line = (x.tables['public.entry_lines'] as Record<string, unknown>[]).find((l) => Number(l['debit']) > 0);
      (line as Record<string, unknown>)['debit'] = (Number((line as Record<string, unknown>)['debit']) + 1).toFixed(2);
    });
    expect(message).toContain('unbalanced_entry');
  });

  it('a matched amount its matchings do not add up to', async () => {
    const message = await attempt((x) => {
      const line = (x.tables['public.entry_lines'] as Record<string, unknown>[]).find((l) => Number(l['matched_amount']) > 0);
      (line as Record<string, unknown>)['matched_amount'] = '0.01';
    });
    expect(message).toContain('matching_mismatch');
  });

  it('a matching letter ahead of its counter, and two years that overlap', async () => {
    expect(
      await attempt((x) => { firstRow(x, 'public.matching_sequences')['last_number'] = 0; }),
    ).toContain('counter_behind');
    expect(
      await attempt((x) => {
        const years = x.tables['public.fiscal_years'] as Record<string, unknown>[];
        (years[0] as Record<string, unknown>)['start_date'] = '1990-01-01';
        (years[1] as Record<string, unknown>)['start_date'] = '1990-06-01';
      }),
    ).toContain('overlapping_years');
  });

  it('a counter behind the numbers already used', async () => {
    const message = await attempt((x) => {
      for (const counter of x.tables['public.journal_sequences'] as Record<string, unknown>[]) counter['last_number'] = 0;
    });
    expect(message).toContain('counter_behind');
  });

  it('a column, a table, a format or a version this installation does not know', async () => {
    expect(
      await attempt((x) => { firstRow(x, 'public.contacts')['shoe_size'] = 43; }),
    ).toContain('unknown_column');
    expect(
      await attempt((x) => { x.tables['public.company_members'] = []; }),
    ).toContain('unknown_table');
    expect(await attempt((x) => { x.manifest.format_version = 2; })).toContain('unknown_archive_version');
    expect(await attempt((x) => { x.manifest.format = 'something.else'; })).toContain('not_an_archive');
    expect(await attempt((x) => { x.manifest.socle_version = '99.0.0'; })).toContain('socle_too_old');
    expect(await attempt((x) => { delete (x.manifest as Partial<Manifest>).socle_version; })).toContain('socle_too_old');
    // The rows say what the company needs, whatever the manifest was made to say.
    expect(
      await attempt((x) => {
        x.manifest.packs = [];
        firstRow(x, 'public.company_packs')['version'] = '99.0.0';
      }),
    ).toContain('pack_too_old');
    expect(await attempt((x) => { (x.manifest.packs[0] as { version: string }).version = '99.0.0'; })).toContain('pack_too_old');
    expect(await attempt((x) => { (x.manifest.packs[0] as { country: string }).country = 'ZZ'; })).toContain('pack_missing');
    expect(await attempt((x) => { x.manifest.modules.push({ code: 'zz_module', version: '1.0.0' }); })).toContain('module_missing');
  });

  it('an export that leaked: the sweep sees it, and so does the door', async () => {
    // Not a lie somebody told — a bug somebody could write. The predicate of
    // one table is broken on purpose in a scratch installation, and both ends
    // have to notice on their own.
    const leaky = await freshDatabase();
    try {
      const one1 = await furnish(leaky, pack, 'First', 'FIRST');
      await furnish(leaky, pack, 'Second', 'SECOND');
      await leaky.exec(`
        create or replace function company_archive_predicate(p_schema text, p_table text, p_alias text)
        returns text language sql stable as $f$
          select case when p_table = 'companies' then format('%I.id = $1', p_alias)
                      when p_table in ('journal_sequences') then format('%I.journal_id in (select id from journals where company_id = $1)', p_alias)
                      when p_table in ('tax_filing_boxes', 'tax_filing_deposits') then format('%I.filing_id in (select id from tax_filings where company_id = $1)', p_alias)
                      when p_table = 'products' then 'true'
                      else format('%I.company_id = $1', p_alias) end;
        $f$;
      `);
      const leaked = await exportAs(leaky, one1.ownerId, one1.companyId).catch((error: Error) => error.message);
      // Row level security is the first to notice: the owner of one company
      // cannot read the products of the other, so the counts disagree.
      expect(leaked).toContain('export_incomplete');

      // Somebody who belongs to every company gets the archive — and it fails the sweep
      // and the import.
      await leaky.query(
        `insert into company_members (company_id, user_id, role)
         select id, $1, 'owner' from companies on conflict do nothing`,
        [one1.ownerId],
      );
      const text = await exportAs(leaky, one1.ownerId, one1.companyId);
      expect(text).toContain('Product SECOND');
      const refused = await asUser(b, adminOfB, () => expectError(b, `select import_company($1::jsonb)`, [text]));
      expect(refused).toContain('foreign_row');
    } finally {
      await leaky.close();
    }
  }, 300_000);

  it('a guard an operator had switched off is still off afterwards, and the others are back on', async () => {
    const scratch = await freshDatabase();
    try {
      const admin = await newInstanceAdmin(scratch);
      await scratch.exec(`alter table contacts disable trigger contacts_set_updated_at`);
      await importAs(scratch, admin, honest);
      const off = await rows<{ tgname: string }>(scratch, `select tgname from pg_trigger where tgenabled <> 'O'`);
      expect(off).toEqual([{ tgname: 'contacts_set_updated_at' }]);
    } finally {
      await scratch.close();
    }
  }, 120_000);

  it('and the honest one still arrives afterwards', async () => {
    const result = await importAs(b, adminOfB, honest);
    expect(result['company_id']).toBe(liar.companyId);
    // No owner was named and the administrator is a person: they own it.
    const members = await rows<{ user_id: string }>(b, `select user_id from company_members where company_id = $1`, [liar.companyId]);
    expect(members).toEqual([{ user_id: adminOfB }]);
  });
});


// ---------------------------------------------------------------------------
// A connection that never said what it is
// ---------------------------------------------------------------------------

describe('the backend role, on a connection where nothing was ever set', () => {
  /**
   * A guard written `if not is_installer() and not …` is an `if NULL` when a
   * helper answers NULL, and does not raise — which `is_installer()` did, until
   * `20260918140000`, in a session where `ekwo.installing` was never set: every
   * request `service_role` makes through the API. The first draft of
   * `import_company()` took a company in that way. The harness cannot see it,
   * because it always sets the setting, to `on` or to the empty string; so this
   * block reloads the data directory into a new server, where the session is
   * new, and asks the doors of this migration there.
   */
  let db: PGlite;
  let text: string;
  let companyId: string;

  beforeAll(async () => {
    const first = await freshDatabase();
    const pack = filers[0] as Pack;
    const owner = await newUser(first);
    // country-literal: any pack would do; the country is the pack's own.
    ({ companyId } = await newCompany(first, { country: pack.manifest.country, ownerId: owner, name: 'Already here' }));
    const other = await newCompany(first, { country: pack.manifest.country, ownerId: owner, name: 'Arriving' });
    text = await exportAs(first, owner, other.companyId);
    await first.query(`delete from companies where id = $1`, [other.companyId]).catch(() => undefined);
    const data = await first.dumpDataDir('none');
    await first.close();
    db = new PGlite({ loadDataDir: data });
    await db.waitReady;
  }, 300_000);

  afterAll(async () => {
    await db?.close();
  });

  it('is the session this block says it is', async () => {
    const session = await one<{ installer: boolean | null; setting: string | null }>(
      db,
      `select is_installer() as installer, current_setting('ekwo.installing', true) as setting`,
    );
    // Nothing was set. Whether the helper then says NULL or false is its own
    // affair — it said NULL when this was written — and the guards under test
    // hold either way.
    expect(session.setting).toBeNull();
    expect(session.installer).not.toBe(true);
  });

  it('takes no company in and leaves with none', async () => {
    await db.exec(`set role service_role`);
    try {
      const arriving = JSON.parse(text) as Archive;
      arriving.manifest.company.id = crypto.randomUUID();
      expect(await expectError(db, `select import_company($1::jsonb)`, [JSON.stringify(arriving)])).toContain(
        'not_instance_admin',
      );
      expect(await expectError(db, `select export_company($1)`, [companyId])).toContain('not_allowed');
      expect(await expectError(db, `select * from export_company_table($1, 'public.entries')`, [companyId])).toContain(
        'not_allowed',
      );
      expect(await expectError(db, `select company_archive_row_count($1, 'public.entries')`, [companyId])).toContain(
        'not_allowed',
      );
      expect(await expectError(db, `select note_company_export($1)`, [companyId])).toContain('not_allowed');
    } finally {
      await db.exec(`reset role`);
    }
  });
});

// ---------------------------------------------------------------------------
// Written down in docs/decisions/0043 as missing, and tested as it stands
// ---------------------------------------------------------------------------

describe('what is written down as missing', () => {
  const pack = filers[0] as Pack;
  let db: PGlite;
  let owner: string;
  let companyId: string;

  beforeAll(async () => {
    db = await freshDatabase();
    owner = await newUser(db);
    // country-literal: any pack would do; the country is the pack's own.
    ({ companyId } = await newCompany(db, { country: pack.manifest.country, ownerId: owner }));
  }, 120_000);

  afterAll(async () => {
    await db?.close();
  });

  it('a module turned off with rows in it stops the export until it is turned back on', async () => {
    const toggle = (on: boolean) =>
      asUser(db, owner, async () => {
        await db.query(on ? `select enable_module($1, 'budgets')` : `select disable_module($1, 'budgets')`, [companyId]);
      });
    await toggle(true);
    await db.query(`insert into budgets.budgets (company_id, code, name) values ($1, 'B1', 'A plan')`, [companyId]);
    await toggle(false);

    // Turning a module off hides its rows from everybody and deletes none. An
    // archive without them would look whole, so there is none.
    const refusal = await asUser(db, owner, () => expectError(db, `select export_company($1)`, [companyId]));
    expect(refusal).toContain('export_incomplete');
    expect(refusal).toContain('budgets.budgets');

    await toggle(true);
    const archive = JSON.parse(await exportAs(db, owner, companyId)) as Archive;
    expect(archive.tables['budgets.budgets']).toHaveLength(1);
  });

  /**
   * One export, presented the way a machine key is: one transaction, the key
   * first. Answers the archive as text, or the refusal.
   */
  async function exportWithKey(secret: string): Promise<string> {
    await db.exec(`select set_config('ekwo.installing', '', false); set role authenticated;`);
    try {
      let answer = '';
      await db.transaction(async (tx) => {
        await tx.query(`select present_api_key($1)`, [secret]);
        const result = await tx.query<{ archive: string }>(
          `select export_company($1)::text as archive`,
          [companyId],
        );
        answer = result.rows[0]?.archive ?? '';
      });
      return answer;
    } catch (error) {
      return (error as Error).message;
    } finally {
      await db.exec(`reset role; select set_config('ekwo.installing', 'on', false);`);
    }
  }

  it('a machine key leaves with the books, once it may read them', async () => {
    // It used to leave with nothing: `companies` asked `is_company_member()`,
    // a key was not one, and the archive stopped at `unknown_company` on the
    // first table. Since `20260922160000` a key is on the company it was
    // minted for, and what stops it now is the honest refusal — an archive is
    // whole or it is not written, so a key that may export and may not read
    // is told which table it cannot see.
    const exportOnly = await asUser(db, owner, () =>
      one<{ secret: string }>(db, `select secret from create_api_key($1, 'exporter', '["company.export"]'::jsonb)`, [
        companyId,
      ]),
    );
    expect(await exportWithKey(exportOnly.secret)).toContain('export_incomplete');

    // And with what a client holds — the preset a person exports under, read
    // from the table that decides it — the whole company comes back.
    const held = await rows<{ capability: string }>(
      db,
      `select capability from role_capabilities where role = 'client' order by capability`,
    );
    const full = await asUser(db, owner, () =>
      one<{ secret: string }>(
        db,
        `select secret from create_api_key($1, 'sauvegarde', $2::jsonb)`,
        [companyId, JSON.stringify(held.map((row) => row.capability))],
      ),
    );
    const said = await exportWithKey(full.secret);
    expect(said).not.toContain('export_incomplete');
    expect(said).not.toContain('unknown_company');
    expect(JSON.parse(said).manifest.company.id).toBe(companyId);
  });

  it('an administrator of the installation is not a member, and does not leave with a company either', async () => {
    const admin = await newInstanceAdmin(db);
    const refusal = await asUser(db, admin, () => expectError(db, `select export_company($1)`, [companyId]));
    expect(refusal).toContain('not_allowed');
  });
});

