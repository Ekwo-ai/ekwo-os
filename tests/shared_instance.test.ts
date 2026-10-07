/**
 * A shared instance keeps its tenants apart (decision 0065).
 *
 * Two people on one installation, each with a company of their own, and one of
 * them looking for the other's through every surface the schema has: the
 * tables and views that carry a company, every function that takes one, the
 * functions that take the id of a row of one, the members, the invitations,
 * the keys, the shares, the trail, the archive — as a signed-in person, the way
 * PostgREST runs a session, and through a machine key, the way PostgREST runs
 * a key. What a stranger is answered about the other person's company has to
 * be exactly what they are answered about a company that does not exist: not a
 * row, not a different error, not a different word.
 *
 * The sweeps are asked of the catalogue rather than listed here, so that a
 * table or a function added tomorrow is probed without anybody remembering to.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from './helpers/db.js';
import { DEMO_OWNER, demoCompanyId, newUser } from './helpers/factory.js';

let db: PGlite;
/** A country the seeds carry a default chart for, read from them rather than named. */
let country: string;
let alice: string;
let bob: string;
let aliceCompany: string;
let bobCompany: string;
let demoCompany: string;
/** Rows of Alice's company that Bob will name by their id. */
const aliceRows = { document: '', share: '', apiKey: '', invitation: '', contact: '' };
/** A module Alice enabled. */
let moduleCode: string;
/** The secret of a key Bob issued on his own company. */
let bobSecret: string;

/** An id nobody holds. */
const NOWHERE = '7d0f0b4e-0000-4000-8000-00000000abcd';

function headers(secret: string): string {
  return JSON.stringify({ 'x-ekwo-api-key': secret });
}

/** One request through a key, as PostgREST makes it: a transaction, `anon`, the pre-request, the work. */
async function throughKey<T>(secret: string, fn: () => Promise<T>): Promise<T> {
  await db.exec(`select set_config('request.jwt.claims', '', false); select set_config('ekwo.installing', '', false);`);
  await db.query('begin');
  await db.exec(`set local role anon; select set_config('request.headers', '${headers(secret)}', true);`);
  try {
    await db.query(`select ekwo_pre_request()`);
    return await fn();
  } finally {
    await db.query('rollback');
    await db.exec(`reset role; select set_config('request.headers', '', false); select set_config('ekwo.installing', 'on', false);`);
  }
}

/** What a call answered, with the ids in it replaced, so two answers can be compared. */
async function outcome(sql: string, params: unknown[], ids: readonly string[]): Promise<string> {
  const scrub = (text: string): string => ids.reduce((said, id) => said.split(id).join('<id>'), text);
  await db.query('savepoint probe');
  try {
    const result = await db.query(sql, params);
    return `ok ${scrub(JSON.stringify(result.rows))}`;
  } catch (error) {
    return `error ${scrub((error as Error).message)}`;
  } finally {
    await db.query('rollback to savepoint probe');
  }
}

/** The same, inside a transaction of its own, for a caller who is not in one. */
async function probe(sql: string, params: unknown[], ids: readonly string[]): Promise<string> {
  await db.query('begin');
  try {
    return await outcome(sql, params, ids);
  } finally {
    await db.query('rollback');
  }
}

beforeAll(async () => {
  db = await freshDatabase();
  country = (
    await one<{ country: string }>(db, `select country from chart_templates where is_default order by country limit 1`)
  ).country;
  demoCompany = await demoCompanyId(db);
  alice = await newUser(db, 'alice@example.test');
  bob = await newUser(db, 'bob@example.test');
  moduleCode = (await one<{ code: string }>(db, `select code from modules where status = 'available' order by code limit 1`)).code;
});

afterAll(async () => {
  await db.close();
});

describe('an installation that is one customer’s, as it was', () => {
  it('is not shared until somebody says so', async () => {
    const sharing = await one<{ shared: boolean; companies_per_person: number | null }>(db, `select * from instance_sharing()`);
    expect(sharing).toEqual({ shared: false, companies_per_person: null });
  });

  it('keeps creating a company an instance-level act', async () => {
    const said = await asUser(db, bob, () => expectError(db, `select create_company('Bob', $1)`, [country]));
    expect(said).toMatch(/^not_instance_admin/);
  });

  it('still lets the first member of a company with none claim it, and says that it has none', async () => {
    const empty = await one<{ id: string }>(
      db,
      `insert into companies (name, country, fiscal_country, currency_code, language)
       select 'Nobody''s', d.country, d.country, d.currency_code, d.language_default
         from country_defaults d where d.country = $1 returning id`,
      [country],
    );
    expect((await asUser(db, bob, () => one<{ x: boolean }>(db, `select company_has_no_member($1) as x`, [empty.id]))).x).toBe(true);
    await db.query(`delete from companies where id = $1`, [empty.id]);
  });
});

describe('sharing it', () => {
  it('is refused to a person', async () => {
    const said = await asUser(db, bob, () => expectError(db, `select share_instance(1)`));
    expect(said).toMatch(/^not_instance_admin/);
  });

  it('is the installer’s or an administrator’s, says how many companies one person may create, and is on the trail', async () => {
    await expectError(db, `select share_instance(null)`).then((said) => expect(said).toMatch(/^bad_companies_per_person/));
    await db.query(`select share_instance(1)`);
    expect(await one(db, `select * from instance_sharing()`)).toEqual({ shared: true, companies_per_person: 1 });
    const trail = await one<{ action: string }>(
      db,
      `select action from audit_log where table_name = 'instance' order by id desc limit 1`,
    );
    expect(trail.action).toBe('instance_shared');
  });
});

describe('a company of one’s own', () => {
  it('is created by a person, in their own session, and owned by them', async () => {
    aliceCompany = (await asUser(db, alice, () => one<{ id: string }>(db, `select id from create_company('Alice', $1)`, [country]))).id;
    bobCompany = (await asUser(db, bob, () => one<{ id: string }>(db, `select id from create_company('Bob', $1)`, [country]))).id;
    const owners = await rows<{ user_id: string; role: string }>(
      db,
      `select user_id, role from company_members where company_id = $1`,
      [aliceCompany],
    );
    expect(owners).toEqual([{ user_id: alice, role: 'owner' }]);
    const accounts = await one<{ n: number }>(db, `select count(*)::int as n from accounts where company_id = $1`, [aliceCompany]);
    expect(accounts.n).toBeGreaterThan(0);
    const years = await one<{ n: number }>(db, `select count(*)::int as n from fiscal_years where company_id = $1`, [aliceCompany]);
    expect(years.n).toBe(1);
  });

  it('is recorded as created by that person', async () => {
    const created = await one<{ actor_id: string }>(
      db,
      `select actor_id from audit_log where company_id = $1 and table_name = 'companies' order by id limit 1`,
      [aliceCompany],
    );
    expect(created.actor_id).toBe(alice);
  });

  it('is one, as many as the installation says', async () => {
    const said = await asUser(db, alice, () => expectError(db, `select create_company('Alice again', $1)`, [country]));
    expect(said).toMatch(/^company_limit/);
  });

  it('is never somebody else’s', async () => {
    const carol = await newUser(db, 'carol@example.test');
    const said = await asUser(db, carol, () => expectError(db, `select create_company('For Alice', $1, null, null, null, null, null, $2)`, [country, alice]));
    expect(said).toMatch(/^not_allowed/);
  });

  it('is not created by a machine key', async () => {
    const key = await asUser(db, bob, () =>
      one<{ secret: string }>(db, `select * from create_api_key($1, 'owner key', (select to_jsonb(array_agg(capability)) from role_capabilities where role = 'owner'), null)`, [bobCompany]),
    );
    const said = await throughKey(key.secret, () => expectError(db, `select create_company('By a key', $1)`, [country]));
    expect(said).toMatch(/^not_allowed/);
  });
});

describe('what one person keeps in their company', () => {
  it('is written in it as its owner', async () => {
    await asUser(db, alice, async () => {
      aliceRows.contact = (
        await one<{ id: string }>(
          db,
          `insert into contacts (company_id, name, contact_type, country) values ($1, 'Alice''s customer', 'customer', $2) returning id`,
          [aliceCompany, country],
        )
      ).id;
      aliceRows.document = (
        await one<{ id: string }>(
          db,
          `insert into documents (company_id, doc_type, contact_id, document_date) values ($1, 'sale_invoice', $2, current_date) returning id`,
          [aliceCompany, aliceRows.contact],
        )
      ).id;
      aliceRows.invitation = (
        await one<{ invitation_id: string }>(db, `select invitation_id from invite_member($1, 'dave@example.test')`, [aliceCompany])
      ).invitation_id;
      aliceRows.apiKey = (
        await one<{ api_key_id: string }>(
          db,
          `select api_key_id from create_api_key($1, 'Alice''s key', '["documents.read"]'::jsonb, null)`,
          [aliceCompany],
        )
      ).api_key_id;
      await db.query(`select enable_module($1, $2)`, [aliceCompany, moduleCode]);
      // One line on an income account of her own chart, and the invoice posted:
      // the ledger has rows of hers too.
      await db.query(
        `insert into document_lines (document_id, company_id, sequence, name, quantity, unit_price, account_id)
         select $1, $2, 10, 'Work', 1, 100,
                (select a.id from accounts a where a.company_id = $2 and a.account_type = 'income' order by a.code limit 1)`,
        [aliceRows.document, aliceCompany],
      );
      await db.query(`select post_document($1)`, [aliceRows.document]);
    });
    // A link to one of her documents, written as the installation would.
    aliceRows.share = (
      await one<{ id: string }>(
        db,
        `insert into document_shares (company_id, subject_kind, document_id, token_hash)
         values ($1, 'document', $2, encode(sha256('alice'::bytea), 'hex')) returning id`,
        [aliceCompany, aliceRows.document],
      )
    ).id;
    // A key Bob holds on his own company, the client preset.
    bobSecret = (
      await asUser(db, bob, () =>
        one<{ secret: string }>(
          db,
          `select * from create_api_key($1, 'Bob''s client key', (select to_jsonb(array_agg(capability)) from role_capabilities where role = 'client'), null)`,
          [bobCompany],
        ),
      )
    ).secret;
  });
});

/** Every table and view of `public` with a `company_id`, from the catalogue. */
async function companyRelations(): Promise<string[]> {
  const found = await rows<{ name: string }>(
    db,
    `select c.relname as name
       from pg_class c
       join pg_namespace n on n.oid = c.relnamespace
       join pg_attribute a on a.attrelid = c.oid and a.attname = 'company_id' and not a.attisdropped
      where n.nspname = 'public' and c.relkind in ('r', 'v')
      order by 1`,
  );
  return found.map((one) => one.name);
}


/**
 * Every function of `public` a signed-in user may call whose first argument
 * is one of these uuids, with a call that names it and gives null to every
 * other argument it needs.
 */
async function takingFirst(names: readonly string[]): Promise<{ name: string; first: string; call: string }[]> {
  const found = await rows<{ name: string; first: string; args: string | null }>(
    db,
    `select p.proname as name,
            p.proargnames[1] as first,
            string_agg(format('%I => null::%s', a.name, format_type(a.type, null)), ', ' order by a.n)
              filter (where a.n > 1 and a.n <= p.pronargs - p.pronargdefaults) as args
       from pg_proc p
       join pg_namespace s on s.oid = p.pronamespace
       cross join lateral unnest(p.proargnames[1:p.pronargs], p.proargtypes::oid[]) with ordinality as a(name, type, n)
      where s.nspname = 'public'
        and p.prokind = 'f'
        and p.prorettype <> 'trigger'::regtype
        and p.pronargs >= 1
        and p.proargnames[1] = any($1::text[])
        and p.proargtypes[0] = 'uuid'::regtype
        and has_function_privilege('authenticated', p.oid, 'execute')
      group by p.oid, p.proname, p.proargnames
      order by 1`,
    [names],
  );
  return found.map((fn) => ({
    name: fn.name,
    first: fn.first,
    call: `select * from public.${fn.name}(${fn.first} => $1::uuid${fn.args === null ? '' : `, ${fn.args}`})`,
  }));
}

/** The rows of Alice's company each kind of id names. */
function aliceRowOf(argument: string): string | undefined {
  return {
    p_company_id: aliceCompany,
    p_document_id: aliceRows.document,
    p_share_id: aliceRows.share,
    p_api_key_id: aliceRows.apiKey,
    p_invitation_id: aliceRows.invitation,
    p_contact_id: aliceRows.contact,
  }[argument];
}

/**
 * One row of Alice's company from every table that carries a company and has
 * a uuid of its own, read as the installer: what a stranger could try to name.
 */
async function aliceIds(): Promise<{ table: string; id: string }[]> {
  const tables = await rows<{ name: string }>(
    db,
    `select c.relname as name
       from pg_class c
       join pg_namespace n on n.oid = c.relnamespace
       join pg_attribute k on k.attrelid = c.oid and k.attname = 'company_id' and not k.attisdropped
       join pg_attribute i on i.attrelid = c.oid and i.attname = 'id' and not i.attisdropped and i.atttypid = 'uuid'::regtype
      where n.nspname = 'public' and c.relkind = 'r'
      order by 1`,
  );
  // Alice herself too: a function that takes a person must not say whether she is one.
  const found: { table: string; id: string }[] = [
    { table: 'companies', id: aliceCompany },
    { table: 'auth.users', id: alice },
  ];
  for (const { name } of tables) {
    const row = (await rows<{ id: string }>(db, `select id::text as id from public.${name} where company_id = $1 order by id limit 1`, [aliceCompany]))[0];
    if (row !== undefined) found.push({ table: name, id: row.id });
  }
  return found;
}

/**
 * Every function a signed-in user may call, once for each of its uuid
 * arguments, in any position: a call that gives that argument and null to
 * every other one the function needs.
 */
async function takingUuid(): Promise<{ name: string; first: string; call: string }[]> {
  const found = await rows<{ name: string; arg: string; args: string | null }>(
    db,
    `with fns as (
       select p.oid, p.proname, p.pronargs, p.pronargdefaults, a.name, a.type, a.n
         from pg_proc p
         join pg_namespace s on s.oid = p.pronamespace
         cross join lateral unnest(p.proargnames[1:p.pronargs], p.proargtypes::oid[]) with ordinality as a(name, type, n)
        where s.nspname = 'public' and p.prokind = 'f' and p.prorettype <> 'trigger'::regtype
          and p.proargnames is not null
          and has_function_privilege('authenticated', p.oid, 'execute')
     )
     select u.proname as name, u.name as arg,
            string_agg(format('%I => null::%s', o.name, format_type(o.type, null)), ', ' order by o.n)
              filter (where o.n <> u.n and o.n <= o.pronargs - o.pronargdefaults) as args
       from fns u
       join fns o on o.oid = u.oid
      where u.type = 'uuid'::regtype
      group by u.oid, u.proname, u.name, u.n
      order by 1, 2`,
  );
  return found.map((fn) => ({
    name: `${fn.name}.${fn.arg}`,
    first: fn.arg,
    call: `select * from public.${fn.name}(${fn.arg} => $1::uuid${fn.args === null ? '' : `, ${fn.args}`})`,
  }));
}

const ROW_ARGUMENTS = ['p_document_id', 'p_share_id', 'p_api_key_id', 'p_invitation_id', 'p_contact_id'] as const;

describe('the other person, signed in', () => {
  it('sees their own company and no other — not the demo one, not Alice’s', async () => {
    const seen = await asUser(db, bob, () => rows<{ id: string }>(db, `select id from companies order by id`));
    expect(seen.map((one) => one.id)).toEqual([bobCompany]);
    expect(demoCompany).not.toBe(bobCompany);
  });

  it('reads no row of Alice’s company from any table or view that carries a company', async () => {
    const relations = await companyRelations();
    expect(relations.length).toBeGreaterThan(20);
    const leaked: string[] = [];
    let read = 0;
    await asUser(db, bob, async () => {
      for (const relation of relations) {
        const said = await probe(`select count(*)::int as n from public.${relation} where company_id = $1`, [aliceCompany], [aliceCompany]);
        // A relation the person may not read at all is an error, and the same one for any company.
        if (said.startsWith('ok')) read += 1;
        if (said.startsWith('ok') && said !== 'ok [{"n":0}]') leaked.push(`${relation}: ${said}`);
      }
    });
    expect(leaked).toEqual([]);
    // Asked, not refused: the person reads these relations, and finds nothing of Alice's there.
    expect(read).toBeGreaterThan(20);
  });

  it('is answered about Alice’s company exactly as about a company that does not exist, by every function that takes one', async () => {
    const functions = await takingFirst(['p_company_id']);
    expect(functions.length).toBeGreaterThan(30);
    const differs: string[] = [];
    await asUser(db, bob, async () => {
      for (const fn of functions) {
        const theirs = await probe(fn.call, [aliceCompany], [aliceCompany, NOWHERE]);
        const nobodys = await probe(fn.call, [NOWHERE], [aliceCompany, NOWHERE]);
        if (theirs !== nobodys) differs.push(`${fn.name}: ${theirs} / ${nobodys}`);
      }
    });
    expect(differs).toEqual([]);
  });

  it('is answered about every row of Alice’s, named by its id, as about a row that does not exist, by every function that takes an id', async () => {
    const ids = await aliceIds();
    expect(ids.length).toBeGreaterThan(10);
    const functions = await takingUuid();
    expect(functions.length).toBeGreaterThan(80);
    const differs: string[] = [];
    await asUser(db, bob, async () => {
      for (const fn of functions) {
        const nobodys = await probe(fn.call, [NOWHERE], [NOWHERE]);
        for (const { table, id } of ids) {
          const theirs = await probe(fn.call, [id], [id]);
          if (theirs !== nobodys) differs.push(`${fn.name}(${table}): ${theirs} / ${nobodys}`);
        }
      }
    });
    expect(differs).toEqual([]);
  });

  it('is answered about a row of Alice’s company as about a row that does not exist', async () => {
    const calls: [string, string][] = [
      ['share_document', `select * from share_document($1)`],
      ['revoke_share', `select * from revoke_share($1)`],
      ['revoke_api_key', `select * from revoke_api_key($1)`],
      ['revoke_invitation', `select * from revoke_invitation($1)`],
    ];
    const ids: Record<string, string> = {
      share_document: aliceRows.document,
      revoke_share: aliceRows.share,
      revoke_api_key: aliceRows.apiKey,
      revoke_invitation: aliceRows.invitation,
    };
    await asUser(db, bob, async () => {
      for (const [name, sql] of calls) {
        const theirs = await probe(sql, [ids[name]], [ids[name] ?? '', NOWHERE]);
        const nobodys = await probe(sql, [NOWHERE], [ids[name] ?? '', NOWHERE]);
        expect(theirs, name).toBe(nobodys);
        expect(theirs, name).toMatch(/^error unknown_/);
      }
    });
  });

  it('cannot take over a company that has no member, nor learn that it has none', async () => {
    const empty = await one<{ id: string }>(
      db,
      `insert into companies (name, country, fiscal_country, currency_code, language)
       select 'Nobody''s', d.country, d.country, d.currency_code, d.language_default
         from country_defaults d where d.country = $1 returning id`,
      [country],
    );
    await asUser(db, bob, async () => {
      expect((await one<{ x: boolean }>(db, `select company_has_no_member($1) as x`, [empty.id])).x).toBe(false);
      const claim = (id: string) => probe(`insert into company_members (company_id, user_id, role) values ($1, $2, 'owner')`, [id, bob], [id, empty.id, NOWHERE]);
      const taken = await claim(empty.id);
      expect(taken).toMatch(/^error .*row-level security/);
      expect(taken).toBe(await claim(NOWHERE));
      expect(await claim(aliceCompany)).toBe(taken);
    });
    // The installer still may, as it always could.
    expect((await one<{ x: boolean }>(db, `select company_has_no_member($1) as x`, [empty.id])).x).toBe(true);
    await db.query(`delete from companies where id = $1`, [empty.id]);
  });

  it('learns nothing of Alice’s module, settings or languages', async () => {
    await asUser(db, bob, async () => {
      expect((await one<{ x: boolean }>(db, `select module_is_enabled($1, $2) as x`, [aliceCompany, moduleCode])).x).toBe(false);
      expect((await one<{ x: unknown }>(db, `select module_settings($1, $2) as x`, [aliceCompany, moduleCode])).x).toBeNull();
      expect((await one<{ x: string[] }>(db, `select preferred_languages('zz', $1) as x`, [aliceCompany])).x).toEqual(['zz']);
    });
    // Alice does.
    await asUser(db, alice, async () => {
      expect((await one<{ x: boolean }>(db, `select module_is_enabled($1, $2) as x`, [aliceCompany, moduleCode])).x).toBe(true);
      expect((await one<{ x: string[] }>(db, `select preferred_languages('zz', $1) as x`, [aliceCompany])).x.length).toBeGreaterThan(1);
    });
  });

  it('reads no address of anybody: auth.users is not theirs to read, and the member list is per company', async () => {
    await asUser(db, bob, async () => {
      expect(await probe(`select email from auth.users`, [], [])).toMatch(/^error permission denied/);
      const list = await probe(`select * from company_members_list($1)`, [aliceCompany], [aliceCompany, NOWHERE]);
      expect(list).toBe(await probe(`select * from company_members_list($1)`, [NOWHERE], [aliceCompany, NOWHERE]));
      expect(list).not.toContain('alice@example.test');
    });
  });

  it('learns nothing of who has an account by inviting: an address with one and an address with none are answered alike', async () => {
    await asUser(db, bob, async () => {
      const invite = (email: string) =>
        probe(`select expires_at > now() as live from invite_member($1, $2)`, [bobCompany, email], [email]);
      expect(await invite('alice@example.test')).toBe(await invite('nobody-at-all@example.test'));
    });
  });

  it('cannot invite into Alice’s company, export it or take an archive into the installation', async () => {
    await asUser(db, bob, async () => {
      const invite = (id: string) => probe(`select * from invite_member($1, 'eve@example.test')`, [id], [id]);
      expect(await invite(aliceCompany)).toBe(await invite(NOWHERE));
      const exported = (id: string) => probe(`select export_company($1)`, [id], [id]);
      expect(await exported(aliceCompany)).toBe(await exported(NOWHERE));
      expect(await expectError(db, `select import_company('{}'::jsonb)`)).toMatch(/not_instance_admin|not_allowed/);
    });
  });

  it('cannot share or unshare the installation, nor read what an administrator wrote on it', async () => {
    await asUser(db, bob, async () => {
      expect(await expectError(db, `select unshare_instance()`)).toMatch(/^not_instance_admin/);
      const trail = await rows(db, `select id from audit_log where company_id is null`);
      expect(trail).toEqual([]);
    });
  });

  it('keeps everything Alice may do in her own company', async () => {
    await asUser(db, alice, async () => {
      const seen = await rows<{ id: string }>(db, `select id from companies order by id`);
      expect(seen.map((one) => one.id)).toEqual([aliceCompany]);
      const docs = await rows(db, `select id from documents where company_id = $1`, [aliceCompany]);
      expect(docs).toHaveLength(1);
      const revoked = await one<{ revoked_at: string | null }>(db, `select revoked_at from revoke_invitation($1)`, [aliceRows.invitation]);
      expect(revoked.revoked_at).not.toBeNull();
    });
  });
});

describe('the other person, through a machine key', () => {
  it('reaches their own company and no other', async () => {
    const seen = await throughKey(bobSecret, () => rows<{ id: string }>(db, `select id from companies`));
    expect(seen.map((one) => one.id)).toEqual([bobCompany]);
  });

  it('reads no row of Alice’s company from any table or view that carries a company', async () => {
    const relations = await companyRelations();
    const leaked: string[] = [];
    let read = 0;
    await throughKey(bobSecret, async () => {
      for (const relation of relations) {
        const said = await outcome(`select count(*)::int as n from public.${relation} where company_id = $1`, [aliceCompany], [aliceCompany]);
        if (said.startsWith('ok')) read += 1;
        if (said.startsWith('ok') && said !== 'ok [{"n":0}]') leaked.push(`${relation}: ${said}`);
      }
    });
    expect(leaked).toEqual([]);
    expect(read).toBeGreaterThan(20);
  });

  it('is answered about every row of Alice’s, named by its id, as about nothing, by every function that takes an id', async () => {
    const ids = await aliceIds();
    const functions = await takingUuid();
    const differs: string[] = [];
    await throughKey(bobSecret, async () => {
      for (const fn of functions) {
        const nobodys = await outcome(fn.call, [NOWHERE], [NOWHERE]);
        for (const { table, id } of ids) {
          const theirs = await outcome(fn.call, [id], [id]);
          if (theirs !== nobodys) differs.push(`${fn.name}(${table}): ${theirs} / ${nobodys}`);
        }
      }
    });
    expect(differs).toEqual([]);
  });

  it('is answered about Alice’s company as about one that does not exist', async () => {
    await throughKey(bobSecret, async () => {
      for (const sql of [
        `select export_company($1)`,
        `select * from trial_balance($1, '1900-01-01'::date, '2999-12-31'::date)`,
        `select module_is_enabled($1, '${moduleCode}')`,
        `select * from member_capabilities($1)`,
        `select * from create_api_key($1, 'widen', '["documents.read"]'::jsonb, null)`,
      ]) {
        expect(await outcome(sql, [aliceCompany], [aliceCompany, NOWHERE]), sql).toBe(await outcome(sql, [NOWHERE], [aliceCompany, NOWHERE]));
      }
    });
  });
});

describe('the operator', () => {
  it('administers the shared installation and is the one caller who sees every company — never a person on a trial', async () => {
    // The demo owner is the seeded administrator; on a trial instance it is the
    // operator's own account, which the operator never hands to anybody.
    const seen = await asUser(db, DEMO_OWNER, () => rows<{ id: string }>(db, `select id from companies`));
    expect(seen.map((one) => one.id)).toEqual(expect.arrayContaining([aliceCompany, bobCompany]));
  });

  it('turns sharing off again, and creating a company is an instance-level act again', async () => {
    await db.query(`select unshare_instance()`);
    const carol = await newUser(db, 'carol2@example.test');
    expect(await asUser(db, carol, () => expectError(db, `select create_company('Carol', $1)`, [country]))).toMatch(/^not_instance_admin/);
  });
});
