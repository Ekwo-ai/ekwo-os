/**
 * A machine key presented over the API, the way PostgREST presents one.
 *
 * Decision 0006 wrote the limit down: a key authenticates per transaction, and
 * PostgREST runs each request in its own, so the key was never presented when
 * the work ran. `ekwo_pre_request()` is the answer — PostgREST calls it at the
 * start of every request's transaction — and what it does after checking the
 * key is the part worth a faithful test: it moves the request off `anon`,
 * which holds no privilege on any table of this schema.
 *
 * **The harness is the request.** A transaction, `set local role anon`, the
 * headers PostgREST would have put on it, then the pre-request and the work —
 * in that order, which is the order that matters.
 *
 * The privilege behind the role switch gets a test of its own, at the bottom,
 * on a database of its own: `set session authorization` drops the superuser of
 * a session and cannot be taken back, so the one test that needs a real
 * privilege check runs where losing it costs nothing. That form was compared
 * on PostgreSQL 14 against a genuine `authenticator` login and answers
 * identically, statement for statement.
 *
 * Nothing key-shaped is written down here: `create_api_key()` mints the
 * secret, and the test reads it back the way its holder would.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, newDocument, newUser } from './helpers/factory.js';

let db: PGlite;
let companyId: string;
let otherCompanyId: string;
let ownerId: string;

/** The header PostgREST would have put on the request, and nothing else. */
function headers(secret?: string): string {
  return JSON.stringify(secret === undefined ? {} : { 'x-ekwo-api-key': secret });
}

/**
 * One request, as PostgREST makes it: a transaction, the anonymous role, the
 * pre-request, then the work.
 *
 * `readOnly` is the half a test has to ask for on purpose and a real request
 * never does: PostgREST opens a GET, and an RPC whose function is not
 * volatile, inside a read-only transaction. Nothing in this suite met one
 * until it was written down here, which is how a pre-request that stamped
 * `last_used_at` reached a real project and failed every read with
 * `cannot execute UPDATE in a read-only transaction`.
 */
async function request<T>(
  secret: string | undefined,
  fn: () => Promise<T>,
  database: PGlite = db,
  readOnly = false,
): Promise<T> {
  const target = database;
  await target.exec(`
    select set_config('request.jwt.claims', '', false);
    select set_config('ekwo.installing', '', false);
  `);
  await target.query('begin');
  if (readOnly) await target.query('set transaction read only');
  await target.exec(`
    set local role anon;
    select set_config('request.headers', '${headers(secret)}', true);
  `);
  try {
    await target.query(`select ekwo_pre_request()`);
    return await fn();
  } finally {
    await target.query('commit');
    await target.exec(`
      reset role;
      select set_config('request.headers', '', false);
      select set_config('ekwo.installing', 'on', false);
    `);
  }
}

/**
 * What the `client` preset holds, read from the table that decides it.
 *
 * An archive is whole or it is not written, so a key that exports needs to
 * read every table the archive carries — `company.export` alone refuses on
 * the first one it cannot see, by design and with the sentence that says
 * which. The preset a person exports under is the answer to "which
 * capabilities is that", and it is a row of `role_capabilities`, not a list
 * somebody keeps in a test.
 */
async function clientCapabilities(): Promise<string[]> {
  const held = await rows<{ capability: string }>(
    db,
    `select capability from role_capabilities where role = 'client' order by capability`,
  );
  return held.map((row) => row.capability);
}

/** Issues a key as the owner, with the capabilities named. */
async function issue(name: string, capabilities: string[], company = companyId): Promise<string> {
  const key = await asUser(db, ownerId, async () =>
    one<{ secret: string }>(db, `select * from create_api_key($1, $2, $3::jsonb, null)`, [
      company,
      name,
      JSON.stringify(capabilities),
    ]),
  );
  return key.secret;
}

beforeAll(async () => {
  db = await freshDatabase();
  ownerId = await newUser(db, 'owner@keys-over-rest.test');
  ({ companyId } = await newCompany(db, { name: 'Sauvegardee', ownerId }));
  ({ companyId: otherCompanyId } = await newCompany(db, { name: 'Voisine' }));
  const contact = await newContact(db, companyId, { name: 'Cliente' });
  const invoice = await newDocument(db, companyId, {
    docType: 'sale_invoice',
    number: 'FAC-REST-001',
    contactId: contact,
    // country-literal: this company was installed on a Belgian pack above, and
    // these are the codes of its own chart.
    lines: [{ unitPrice: 100, taxCode: 'BE-S-21', accountCode: '704000' }],
  });
  // Posted, so there is a ledger for a key to be allowed or refused.
  await db.query(`select post_document($1)`, [invoice]);
}, 180_000);

afterAll(async () => {
  await db.close();
});

describe('a request that carries no key', () => {
  it('stays anonymous, and anonymous still reaches no table', async () => {
    const seen = await request(undefined, async () =>
      one<{ role: string }>(db, `select current_user::text as role`),
    );
    expect(seen.role).toBe('anon');

    const refused = await request(undefined, async () =>
      expectError(db, `select count(*) from companies`),
    );
    expect(refused).toMatch(/permission denied for (table|relation) companies/);
  });
});

describe('a request that carries a key', () => {
  it('leaves `anon` for `authenticated`, and is still nobody in particular', async () => {
    const secret = await issue('Lectrice', ['entries.read']);
    const who = await request(secret, async () =>
      one<{ role: string; uid: string | null; company: string | null }>(
        db,
        `select current_user::text as role, auth.uid()::text as uid,
                api_key_company()::text as company`,
      ),
    );
    expect(who.role).toBe('authenticated');
    // A key is not a session: every policy that asks for a signed-in user
    // still answers no, which is the whole of decision 0006.
    expect(who.uid).toBeNull();
    expect(who.company).toBe(companyId);
  });

  it('is refused whole when the key is not one', async () => {
    const message = await request('ekwo_0123456789_nope', async () => 'unreachable').catch(
      (error: Error) => error.message,
    );
    expect(message).toMatch(/unknown_api_key/);
  });

  it('is refused once the key has been withdrawn', async () => {
    const secret = await issue('A retirer', ['entries.read']);
    const key = await request(secret, async () =>
      one<{ id: string }>(db, `select id::text from current_api_key()`),
    );
    await asUser(db, ownerId, async () => {
      await db.query(`select * from revoke_api_key($1)`, [key.id]);
    });
    const message = await request(secret, async () => 'unreachable').catch(
      (error: Error) => error.message,
    );
    expect(message).toMatch(/api_key_revoked/);
  });
});

describe('what a key is on', () => {
  it('is its own company, and no other', async () => {
    const secret = await issue('Portee', ['entries.read', 'settings.read']);
    const seen = await request(secret, async () =>
      rows<{ id: string }>(db, `select id::text from companies order by name`),
    );
    expect(seen.map((row) => row.id)).toEqual([companyId]);
    expect(seen.map((row) => row.id)).not.toContain(otherCompanyId);
  });

  it('reads the ledger its capabilities name, and not the one they do not', async () => {
    const reader = await issue('Ecritures', ['entries.read']);
    const lines = await request(reader, async () =>
      one<{ n: number }>(db, `select count(*)::int as n from entry_lines`),
    );
    expect(lines.n).toBeGreaterThan(0);

    // The same company, a key that was not given the documents.
    const narrow = await issue('Etroite', ['entries.read']);
    const documents = await request(narrow, async () =>
      one<{ n: number }>(db, `select count(*)::int as n from documents`),
    );
    expect(documents.n).toBe(0);
  });

  it('writes nothing without a capability that allows it', async () => {
    const secret = await issue('Lecture seule', ['entries.read']);
    const before = await one<{ n: number }>(db, `select count(*)::int as n from contacts`);
    const refused = await request(secret, async () =>
      expectError(db, `insert into contacts (company_id, name) values ($1, 'Interdite')`, [
        companyId,
      ]),
    );
    expect(refused).toMatch(/row-level security|violates/i);
    const after = await one<{ n: number }>(db, `select count(*)::int as n from contacts`);
    expect(after.n).toBe(before.n);
  });
});

describe('a read request, which is what PostgREST opens for a GET', () => {
  // The whole of it: a key presented in a read-only transaction reads, and the
  // pre-request writes nothing that would fail the request it was presented
  // for.
  it('presents the key and reads, in a transaction that may not write', async () => {
    const secret = await issue('Lecture seule sur GET', ['entries.read', 'settings.read']);
    const seen = await request(
      secret,
      async () =>
        one<{ role: string; company: string | null; n: number }>(
          db,
          `select current_user::text as role, api_key_company()::text as company,
                  (select count(*)::int from companies) as n`,
        ),
      db,
      true,
    );
    expect(seen.role).toBe('authenticated');
    expect(seen.company).toBe(companyId);
    expect(seen.n).toBe(1);
  });

  it('leaves last_used_at alone there, and stamps it where it can', async () => {
    const secret = await issue('Horodatee', ['entries.read']);
    const id = await request(secret, async () =>
      one<{ id: string }>(db, `select id::text from current_api_key()`),
    );
    // That first request could write, so it stamped. Clear it, and read again
    // in a read-only transaction: the read works and the stamp stays empty.
    await db.query(`update api_keys set last_used_at = null where id = $1`, [id.id]);
    await request(
      secret,
      async () => one<{ n: number }>(db, `select count(*)::int as n from companies`),
      db,
      true,
    );
    const afterRead = await one<{ used: string | null }>(
      db,
      `select last_used_at::text as used from api_keys where id = $1`,
      [id.id],
    );
    expect(afterRead.used).toBeNull();

    // And a request that may write records the use, as it always did.
    await request(secret, async () => one<{ n: number }>(db, `select count(*)::int as n from companies`));
    const afterWrite = await one<{ used: string | null }>(
      db,
      `select last_used_at::text as used from api_keys where id = $1`,
      [id.id],
    );
    expect(afterWrite.used).not.toBeNull();
  });

  it('answers the version in a read-only transaction, which is how a client asks it', async () => {
    // `installed_schema_version()` is `stable`, so PostgREST runs it read-only
    // even as an RPC. This is the handshake a client makes before anything
    // else, and it was failing with a message about an UPDATE.
    const secret = await issue('Poignee de main', ['entries.read']);
    const answered = await request(
      secret,
      async () =>
        one<{ schema_version: string }>(db, `select * from installed_schema_version()`),
      db,
      true,
    );
    const defined = await one<{ version: string }>(db, `select ekwo_schema_version() as version`);
    expect(answered.schema_version).toBe(defined.version);
  });
});

describe('the version of the schema', () => {
  it('answers the holder of a key', async () => {
    const secret = await issue('Version', ['entries.read']);
    const answered = await request(secret, async () =>
      one<{ schema_version: string }>(db, `select * from installed_schema_version()`),
    );
    const defined = await one<{ version: string }>(db, `select ekwo_schema_version() as version`);
    expect(answered.schema_version).toBe(defined.version);
  });

  it('answers a caller with no key and no session with nothing at all', async () => {
    const seen = await request(undefined, async () =>
      rows(db, `select * from installed_schema_version()`),
    );
    expect(seen).toEqual([]);
  });
});

describe('leaving with the books, which is what this was for', () => {
  it('exports the whole company, over the API, with what a client holds', async () => {
    const secret = await issue('Sauvegarde', await clientCapabilities());
    const archive = await request(secret, async () =>
      one<{ tables: number; company: string }>(
        db,
        `select jsonb_array_length(x.archive -> 'manifest' -> 'tables') as tables,
                x.archive -> 'manifest' -> 'company' ->> 'id' as company
           from (select export_company($1) as archive) x`,
        [companyId],
      ),
    );
    expect(Number(archive.tables)).toBeGreaterThan(0);
    expect(archive.company).toBe(companyId);
  });

  it('records the key, and not a person, on the audit trail', async () => {
    const secret = await issue('Tracee', await clientCapabilities());
    const key = await request(secret, async () =>
      one<{ id: string }>(db, `select id::text from current_api_key()`),
    );
    await request(secret, async () => {
      await db.query(`select export_company($1)`, [companyId]);
    });
    const trail = await one<{ actor_id: string | null; api_key_id: string | null; name: string }>(
      db,
      `select a.actor_id::text, a.api_key_id::text, k.name
         from audit_log a join api_keys k on k.id = a.api_key_id
        where a.company_id = $1 and a.action = 'company_exported'
        order by a.occurred_at desc limit 1`,
      [companyId],
    );
    expect(trail.actor_id).toBeNull();
    expect(trail.api_key_id).toBe(key.id);
    expect(trail.name).toBe('Tracee');
  });

  it('refuses a key that was not given company.export', async () => {
    const secret = await issue('Sans export', ['entries.read']);
    const message = await request(secret, async () =>
      expectError(db, `select export_company($1)`, [companyId]),
    );
    expect(message).toMatch(/not_allowed|company\.export/);
  });

  it('refuses half an archive to a key that may export and not read', async () => {
    // The refusal names the table and the two counts, so an operator knows
    // which capability to add rather than which function to work around.
    const secret = await issue('Export seul', ['company.export']);
    const message = await request(secret, async () =>
      expectError(db, `select export_company($1)`, [companyId]),
    );
    expect(message).toMatch(/export_incomplete/);
  });

  it('refuses to export the company next door', async () => {
    const secret = await issue('Sauvegarde voisine', await clientCapabilities());
    const message = await request(secret, async () =>
      expectError(db, `select export_company($1)`, [otherCompanyId]),
    );
    expect(message).toMatch(/not_allowed|unknown_company/);
  });
});

describe('the role switch itself', () => {
  // The design rests on one privilege: `anon` may become `authenticated`
  // because the session user PostgREST connects as, `authenticator`, is a
  // member of both. A session user that is a member of neither is refused by
  // the server — which is what stops `set role` in a pre-request from being a
  // way out of `anon` for anybody who can call the function.
  //
  // `set session authorization` gives a session the real check and cannot be
  // reversed, so this runs on a database it may keep.
  it('is the session\u2019s privilege, and the server refuses it to a stranger', async () => {
    const own = await freshDatabase();
    try {
      const user = await newUser(own, 'owner@switch.test');
      const { companyId: company } = await newCompany(own, { name: 'Bascule', ownerId: user });
      const key = await asUser(own, user, async () =>
        one<{ secret: string }>(
          own,
          `select * from create_api_key($1, 'Bascule', $2::jsonb, null)`,
          [company, JSON.stringify(['entries.read'])],
        ),
      );

      // `authenticator` is a member of both roles: the switch is allowed, and
      // the request reads its company.
      await own.exec(`set session authorization authenticator;`);
      const allowed = await request(key.secret, async () =>
        one<{ role: string; n: number }>(
          own,
          `select current_user::text as role, (select count(*)::int from companies) as n`,
        ),
        own,
      );
      expect(allowed.role).toBe('authenticated');
      expect(allowed.n).toBe(1);

      // `lonely` is a member of `anon` and of nothing else. The key is still
      // presented — `present_api_key()` is definer — and the switch after it
      // is refused.
      await own.exec(`
        reset role;
        set session authorization postgres;
        do $$ begin
          if not exists (select 1 from pg_roles where rolname = 'lonely') then
            create role lonely nologin noinherit;
          end if;
        end $$;
        grant anon to lonely;
        set session authorization lonely;
      `);
      let message = '';
      await own.query('begin');
      try {
        await own.exec(`
          set local role anon;
          select set_config('request.headers', '${headers(key.secret)}', true);
        `);
        await own.query(`select ekwo_pre_request()`);
      } catch (error) {
        message = (error as Error).message;
      } finally {
        await own.query('rollback');
      }
      expect(message).toMatch(/permission denied to set role/i);
    } finally {
      await own.close();
    }
  });
});
