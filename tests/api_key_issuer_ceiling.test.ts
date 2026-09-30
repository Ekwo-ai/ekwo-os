/**
 * A key holds what its issuer still holds.
 *
 * `create_api_key()` refuses a capability the issuer does not hold, and until
 * `20260930103815` that was the only time the issuer was consulted: a key
 * outlived its issuer's rights until somebody withdrew it by hand. Since then
 * `key_holds()` asks, at every call, whether the person who issued the key
 * still holds the capability on the company — computed, never maintained.
 *
 * The assertions follow the ways a person loses a right: a change of preset,
 * one capability revoked by adjustment, leaving the company, an account
 * deleted whose membership was removed with it. Then the two things that must
 * not move: a key the installation issued, bounded by its list alone, and a
 * person, whose path is the one it was. Last, `api_key_reach` says what
 * `has_capability()` says, over a matrix of keys, companies and capabilities,
 * because both call the same function.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newUser } from './helpers/factory.js';

let db: PGlite;
let companyId: string;
let otherCompanyId: string;
let ownerId: string;
let capabilityCodes: string[];

interface IssuedKey {
  api_key_id: string;
  secret: string;
}

async function issue(as: string | null, name: string, capabilities: string[]): Promise<IssuedKey> {
  const sql = `select * from create_api_key($1, $2, $3::jsonb, null)`;
  const params = [companyId, name, JSON.stringify(capabilities)];
  // `null` is the installation itself: this connection is the installer.
  if (as === null) return one<IssuedKey>(db, sql, params);
  return asUser(db, as, () => one<IssuedKey>(db, sql, params));
}

/** What a machine holding a key can do, inside one transaction. */
async function withKey<T>(secret: string, fn: () => Promise<T>): Promise<T> {
  await db.exec(`set role authenticated;`);
  await db.query(`begin`);
  try {
    await db.query(`select * from use_api_key($1)`, [secret]);
    return await fn();
  } finally {
    await db.query(`commit`);
    await db.exec(`reset role;`);
  }
}

/** Every capability the key holds on a company, as `has_capability()` says. */
async function held(secret: string, company = companyId): Promise<string[]> {
  return withKey(secret, async () =>
    (
      await rows<{ code: string }>(
        db,
        `select code from capabilities where has_capability($1, code) order by code`,
        [company],
      )
    ).map((r) => r.code),
  );
}

/** A member who may issue keys, on a preset, with members.manage granted. */
async function issuerOn(role: string): Promise<string> {
  const id = await newUser(db);
  await db.query(
    `insert into company_members (company_id, user_id, role, capabilities_granted)
     values ($1, $2, $3::member_role, array['members.manage'])`,
    [companyId, id, role],
  );
  return id;
}

async function presetHolds(role: string, capability: string): Promise<boolean> {
  return (
    await one<{ holds: boolean }>(
      db,
      `select exists (select 1 from role_capabilities where role = $1::member_role and capability = $2) as holds`,
      [role, capability],
    )
  ).holds;
}

beforeAll(async () => {
  db = await freshDatabase();
  ownerId = await newUser(db, 'owner@ceiling.test');
  ({ companyId } = await newCompany(db, { name: 'Plafond SRL', ownerId }));
  ({ companyId: otherCompanyId } = await newCompany(db, { name: 'Voisine SRL', ownerId }));
  capabilityCodes = (await rows<{ code: string }>(db, `select code from capabilities order by code`)).map(
    (r) => r.code,
  );
});

afterAll(async () => {
  await db.close();
});

describe('a key whose issuer loses a right', () => {
  it('loses the capabilities the new preset of its issuer does not carry', async () => {
    // Read from the presets rather than assumed: the accountant writes
    // documents and the viewer does not.
    expect(await presetHolds('accountant', 'documents.write')).toBe(true);
    expect(await presetHolds('viewer', 'documents.write')).toBe(false);
    expect(await presetHolds('viewer', 'documents.read')).toBe(true);

    const issuer = await issuerOn('accountant');
    const key = await issue(issuer, 'Saisie', ['documents.read', 'documents.write']);
    expect(await held(key.secret)).toEqual(['documents.read', 'documents.write']);

    await asUser(db, ownerId, () =>
      one(db, `select * from set_member_role($1, $2, 'viewer')`, [companyId, issuer]),
    );
    expect(await held(key.secret)).toEqual(['documents.read']);
  });

  it('follows an adjustment revoked on its issuer, and one given back', async () => {
    const issuer = await issuerOn('accountant');
    const key = await issue(issuer, 'Lecture', ['documents.read', 'entries.read']);

    await db.query(
      `update company_members set capabilities_revoked = array['entries.read']
        where company_id = $1 and user_id = $2`,
      [companyId, issuer],
    );
    expect(await held(key.secret)).toEqual(['documents.read']);

    await db.query(
      `update company_members set capabilities_revoked = '{}'
        where company_id = $1 and user_id = $2`,
      [companyId, issuer],
    );
    // Computed at the call, not written down when the right went: the right
    // coming back brings the key's back with it.
    expect(await held(key.secret)).toEqual(['documents.read', 'entries.read']);
  });

  it('reaches nothing once its issuer has left the company', async () => {
    const issuer = await issuerOn('accountant');
    const key = await issue(issuer, 'Sauvegarde', ['documents.read', 'entries.read', 'settings.read']);
    expect(await held(key.secret)).toHaveLength(3);

    await asUser(db, ownerId, () =>
      one(db, `select * from remove_member($1, $2)`, [companyId, issuer]),
    );

    expect(await held(key.secret)).toEqual([]);
    const seen = await withKey(key.secret, () =>
      one<{
        member: boolean;
        any_member: boolean;
        known: boolean;
        companies: number;
        documents: number;
        version: number;
      }>(
        db,
        `select is_company_member($1) as member,
                is_any_company_member() as any_member,
                is_known_caller() as known,
                (select count(*)::int from companies) as companies,
                (select count(*)::int from documents) as documents,
                (select count(*)::int from installed_schema_version()) as version`,
        [companyId],
      ),
    );
    // Not even the rows that describe the company: a key is on a company
    // because it reaches something there, and this one reaches nothing.
    expect(seen).toEqual({
      member: false,
      any_member: false,
      known: false,
      companies: 0,
      documents: 0,
      version: 0,
    });
  });

  it('reaches nothing once its issuer is gone from auth and from the company', async () => {
    const issuer = await issuerOn('accountant');
    const key = await issue(issuer, 'Orpheline', ['documents.read']);
    await db.query(`delete from company_members where company_id = $1 and user_id = $2`, [
      companyId,
      issuer,
    ]);
    await db.query(`delete from auth.users where id = $1`, [issuer]);
    expect(await held(key.secret)).toEqual([]);
  });

  it('keeps being bounded by a membership whose account is gone, which the doctor reports', async () => {
    // No foreign key from company_members to auth.users (decision 0001), so
    // deleting an account leaves the membership — and the membership keeps
    // bounding the keys. `ekwo doctor` lists that orphan under *company
    // members*; removing the row is what withdraws the keys.
    const issuer = await issuerOn('accountant');
    const key = await issue(issuer, 'Toujours bornee', ['documents.read']);
    await db.query(`delete from auth.users where id = $1`, [issuer]);
    expect(await held(key.secret)).toEqual(['documents.read']);
  });
});

describe('a key the installation issued', () => {
  it('is bounded by its own list alone, and owes nothing to any member', async () => {
    const key = await issue(null, 'De l’installation', ['documents.read', 'entries.read']);
    const row = await one<{ created_by: string | null }>(
      db,
      `select created_by from api_keys where id = $1`,
      [key.api_key_id],
    );
    expect(row.created_by).toBeNull();

    // Whatever happens to the people of the company, the list is the answer.
    await db.query(
      `update company_members set capabilities_revoked = array['documents.read']
        where company_id = $1 and user_id = $2`,
      [companyId, ownerId],
    );
    try {
      expect(await held(key.secret)).toEqual(['documents.read', 'entries.read']);
      expect(await held(key.secret, otherCompanyId)).toEqual([]);
    } finally {
      await db.query(
        `update company_members set capabilities_revoked = '{}'
          where company_id = $1 and user_id = $2`,
        [companyId, ownerId],
      );
    }
  });
});

describe('a key issued while another key is presented', () => {
  it('is a delegation from the person behind that key, and dies with their rights', async () => {
    const issuer = await issuerOn('accountant');
    const parent = await issue(issuer, 'Qui administre', ['members.manage', 'documents.read']);
    const child = await withKey(parent.secret, () =>
      one<IssuedKey>(db, `select * from create_api_key($1, 'Fille', '["documents.read"]'::jsonb, null)`, [
        companyId,
      ]),
    );
    const row = await one<{ created_by: string | null }>(
      db,
      `select created_by from api_keys where id = $1`,
      [child.api_key_id],
    );
    // Not null: a key cannot mint a key that looks like the installation's
    // own and is bounded by nothing but its list.
    expect(row.created_by).toBe(issuer);

    await db.query(`delete from company_members where company_id = $1 and user_id = $2`, [
      companyId,
      issuer,
    ]);
    expect(await held(child.secret)).toEqual([]);
  });
});

describe('a person', () => {
  it('holds what member_capabilities() lists, capability by capability', async () => {
    const member = await newUser(db);
    await db.query(
      `insert into company_members (company_id, user_id, role, capabilities_granted, capabilities_revoked)
       values ($1, $2, 'accountant', array['members.manage'], array['documents.read'])`,
      [companyId, member],
    );
    const listed = await asUser(db, member, async () =>
      (await rows<{ c: string }>(db, `select member_capabilities($1) as c`, [companyId])).map((r) => r.c),
    );
    const asked = await asUser(db, member, async () =>
      (
        await rows<{ code: string }>(
          db,
          `select code from capabilities where has_capability($1, code) order by code`,
          [companyId],
        )
      ).map((r) => r.code),
    );
    expect(asked).toEqual(listed);
    expect(listed).toContain('members.manage');
    expect(listed).not.toContain('documents.read');
  });

  it('keeps what they hold while presenting a key whose issuer has left', async () => {
    const issuer = await issuerOn('accountant');
    const key = await issue(issuer, 'Morte', ['documents.read']);
    await db.query(`delete from company_members where company_id = $1 and user_id = $2`, [
      companyId,
      issuer,
    ]);
    await db.exec(
      `select set_config('request.jwt.claims', '${JSON.stringify({ sub: ownerId, role: 'authenticated' })}', false);`,
    );
    try {
      const still = await withKey(key.secret, () =>
        one<{ write: boolean }>(db, `select has_capability($1, 'company.write') as write`, [companyId]),
      );
      expect(still.write).toBe(true);
    } finally {
      await db.exec(`select set_config('request.jwt.claims', '', false);`);
    }
  });
});

// ---------------------------------------------------------------------------
// api_key_reach against has_capability()
// ---------------------------------------------------------------------------

describe('api_key_reach', () => {
  let keys: { name: string; secret: string; id: string }[];

  beforeAll(async () => {
    const full = await issuerOn('accountant');
    const demoted = await issuerOn('accountant');
    const adjusted = await issuerOn('accountant');
    const gone = await issuerOn('accountant');
    const reads = capabilityCodes.filter((c) => c.endsWith('.read'));
    const wide = ['documents.read', 'documents.write', 'entries.read', 'entries.post'];

    const made = [
      { name: 'full', key: await issue(full, 'full', wide) },
      { name: 'demoted', key: await issue(demoted, 'demoted', wide) },
      { name: 'adjusted', key: await issue(adjusted, 'adjusted', reads) },
      { name: 'gone', key: await issue(gone, 'gone', reads) },
      { name: 'installation', key: await issue(null, 'installation', ['company.write', 'entries.read']) },
      { name: 'withdrawn', key: await issue(full, 'withdrawn', ['documents.read']) },
    ];

    await asUser(db, ownerId, () =>
      one(db, `select * from set_member_role($1, $2, 'viewer')`, [companyId, demoted]),
    );
    await db.query(
      `update company_members set capabilities_revoked = array['entries.read', 'documents.read']
        where company_id = $1 and user_id = $2`,
      [companyId, adjusted],
    );
    await db.query(`delete from company_members where company_id = $1 and user_id = $2`, [
      companyId,
      gone,
    ]);
    const withdrawn = made.find((m) => m.name === 'withdrawn');
    await asUser(db, ownerId, () =>
      one(db, `select * from revoke_api_key($1)`, [withdrawn?.key.api_key_id]),
    );

    keys = made.map((m) => ({ name: m.name, secret: m.key.secret, id: m.key.api_key_id }));
  });

  /** Every (company, capability) the view says the key reaches. */
  async function reachOf(id: string, reader: string | null): Promise<string[]> {
    const sql = `select company_id::text || ':' || capability as pair
                   from api_key_reach where api_key_id = $1 and reaches order by 1`;
    const read = () => rows<{ pair: string }>(db, sql, [id]);
    const found = reader === null ? await read() : await asUser(db, reader, read);
    return found.map((r) => r.pair);
  }

  it('says what has_capability() says, for every key, company and capability', async () => {
    const companies = [companyId, otherCompanyId];
    for (const key of keys) {
      // A withdrawn key cannot be presented at all, and reaches nothing.
      const asked =
        key.name === 'withdrawn'
          ? []
          : await withKey(key.secret, async () =>
              (
                await rows<{ pair: string }>(
                  db,
                  `select c.id::text || ':' || k.code as pair
                     from unnest($1::uuid[]) as c(id)
                    cross join unnest($2::text[]) as k(code)
                    where has_capability(c.id, k.code)
                    order by 1`,
                  [companies, capabilityCodes],
                )
              ).map((r) => r.pair),
            );
      expect({ key: key.name, reach: await reachOf(key.id, null) }).toEqual({ key: key.name, reach: asked });
      // The same answer to the person who administers the company, reading
      // under their own policies.
      expect({ key: key.name, reach: await reachOf(key.id, ownerId) }).toEqual({ key: key.name, reach: asked });
    }
  });

  it('reads as expected for each way of losing a right', async () => {
    const reach = async (name: string) => {
      const key = keys.find((k) => k.name === name);
      return (await reachOf(key?.id ?? '', null)).map((pair) => pair.split(':')[1]);
    };
    expect(await reach('full')).toEqual(['documents.read', 'documents.write', 'entries.post', 'entries.read']);
    expect(await reach('demoted')).toEqual(['documents.read', 'entries.read']);
    expect(await reach('adjusted')).not.toContain('entries.read');
    expect(await reach('adjusted')).not.toContain('documents.read');
    expect(await reach('gone')).toEqual([]);
    expect(await reach('installation')).toEqual(['company.write', 'entries.read']);
    expect(await reach('withdrawn')).toEqual([]);
  });

  it('is read by whoever reads the keys, and shows no hash', async () => {
    const columns = (
      await rows<{ column_name: string }>(
        db,
        `select column_name from information_schema.columns
          where table_schema = 'public' and table_name = 'api_key_reach'`,
      )
    ).map((r) => r.column_name);
    expect(columns).not.toContain('key_hash');

    const stranger = await newUser(db);
    const seen = await asUser(db, stranger, () => rows(db, `select * from api_key_reach`));
    expect(seen).toEqual([]);

    const viewer = await newUser(db);
    await db.query(
      `insert into company_members (company_id, user_id, role) values ($1, $2, 'viewer')`,
      [companyId, viewer],
    );
    const byViewer = await asUser(db, viewer, () => rows(db, `select * from api_key_reach`));
    expect(byViewer).toEqual([]);
  });
});
