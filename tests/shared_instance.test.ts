/**
 * A shared instance keeps its tenants apart (decision 0065).
 *
 * Two people on one installation, each with companies of their own, and one of
 * them looking for the other's through every surface the schema has: the
 * tables and views that carry a company, in every schema that holds a
 * company's rows, every function that takes one, the functions that take the
 * id of a row of one — as an argument, inside an object or inside a list —
 * every write that names a row of another table, the members, the invitations,
 * the keys, the shares, the trail, the archive — as a signed-in person, the
 * way PostgREST runs a session, and through a machine key, the way PostgREST
 * runs a key. What a stranger is answered about the other person's company has
 * to be exactly what they are answered about a company that does not exist:
 * not a row, not a different error, not a different word, and nothing they
 * read moves when the other person works.
 *
 * The sweeps are asked of the catalogue rather than listed here, so that a
 * table or a function added tomorrow is probed without anybody remembering to.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { filers, furnish } from './helpers/company-archive.js';
import { asUser, expectError, freshDatabase, one, rows } from './helpers/db.js';
import { DEMO_OWNER, demoCompanyId, newUser } from './helpers/factory.js';
import type { PackGolden } from '../packages/cli/src/index.js';

let db: PGlite;
/** A country the seeds carry a default chart for, read from them rather than named. */
let country: string;
let alice: string;
let bob: string;
let aliceCompany: string;
let bobCompany: string;
/** A year of books each, in every table a company has, modules included. */
let aliceBooks: string;
let bobBooks: string;
/** The last day of the furnished year, open for booking. */
let openDay: string;
let demoCompany: string;
/** Rows of Alice's company that Bob will name by their id. */
const aliceRows = { document: '', share: '', apiKey: '', invitation: '', contact: '' };
/** A module Alice enabled. */
let moduleCode: string;
/** The secret of a key Bob issued on his own company. */
let bobSecret: string;

/** An id nobody holds. */
const NOWHERE = '7d0f0b4e-0000-4000-8000-00000000abcd';
const UUID = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/g;

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

/**
 * What a call answered, with the ids in it replaced, so two answers can be
 * compared. The detail of an error is part of the answer: PostgREST hands it
 * to the client beside the message.
 */
async function outcome(sql: string, params: unknown[], ids: readonly string[]): Promise<string> {
  const scrub = (text: string): string => ids.reduce((said, id) => said.split(id).join('<id>'), text);
  await db.query('savepoint probe');
  try {
    const result = await db.query(sql, params);
    return `ok ${scrub(JSON.stringify(result.rows))}`;
  } catch (error) {
    const { message, detail } = error as Error & { detail?: string };
    return `error ${scrub(message)}${detail === undefined ? '' : ` | ${scrub(detail)}`}`;
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

/**
 * A write, the same way, with every key checked as it is written: a deferred
 * key is otherwise only asked at a commit the probe never makes.
 */
async function probeWrite(sql: string, params: unknown[], ids: readonly string[]): Promise<string> {
  await db.query('begin');
  try {
    await db.query('set constraints all immediate');
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

  // A year of books for each, in every table a company has, with every module
  // on. The installation wrote them, as an operator moving a company in would;
  // each person owns theirs.
  const pack = filers[0];
  if (pack === undefined) throw new Error('no pack with a golden scenario to furnish books from');
  openDay = (pack.golden as PackGolden).fiscalYear.end;
  aliceBooks = (await furnish(db, pack, 'Alice Books', 'ALICE')).companyId;
  bobBooks = (await furnish(db, pack, 'Bob Books', 'BOB')).companyId;
  await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'owner'), ($3, $4, 'owner')`, [
    aliceBooks, alice, bobBooks, bob,
  ]);
  // The one table the books leave empty: an asset sold, naming its buyer, its
  // counterpart account and the entry that booked it.
  for (const company of [aliceBooks, bobBooks]) {
    const asset = await one<{ id: string }>(
      db,
      `insert into fixed_assets.fixed_assets (company_id, code, name, acquisition_date, cost, method, duration_months,
                                              asset_account_id, depreciation_account_id, expense_account_id)
       select f.company_id, 'A-2', f.name || ' (sold)', f.acquisition_date, f.cost, f.method, f.duration_months,
              f.asset_account_id, f.depreciation_account_id, f.expense_account_id
         from fixed_assets.fixed_assets f where f.company_id = $1 order by f.code limit 1
       returning id`,
      [company],
    );
    await db.query(
      `insert into fixed_assets.disposals (asset_id, company_id, disposal_date, proceeds, counterpart_account_id, contact_id,
                                           cost, accumulated, net_book_value, result, entry_id)
       select $1, $2, $3::date, 100, (select id from accounts where company_id = $2 order by code limit 1),
              (select id from contacts where company_id = $2 order by id limit 1), 6000, 1200, 4800, -4700,
              (select id from entries where company_id = $2 and state = 'posted' order by id limit 1)`,
      [asset.id, company, openDay],
    );
    // And a deposit of one of its declarations, with the file sent and the
    // receipt: a table that reaches its company through its declaration.
    await db.query(
      `insert into tax_filing_deposits (filing_id, sequence, sent_file_id, acknowledgement_id)
       select f.id, 99, a.id, a.id
         from tax_filings f, attachments a
        where f.company_id = $1 and a.company_id = $1
        order by f.id, a.id limit 1`,
      [company],
    );
  }
}, 600_000);

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

  it('is refused while the installation has no administrator: the first person to sign in would claim it', async () => {
    const admins = await rows<{ user_id: string }>(db, `select user_id from instance_admins`);
    expect(admins.length).toBeGreaterThan(0);
    await db.query('begin');
    try {
      await db.query(`delete from instance_admins`);
      expect(await expectError(db, `select share_instance(1)`)).toMatch(/^no_instance_admin/);
    } finally {
      await db.query('rollback');
    }
  });

  it('is the installer’s or an administrator’s, says how many companies one person may create, and is on the trail', async () => {
    await expectError(db, `select share_instance(null)`).then((said) => expect(said).toMatch(/^bad_companies_per_person/));
    await db.query(`select share_instance(1)`);
    expect(await one(db, `select * from instance_sharing()`)).toEqual({ shared: true, companies_per_person: 1 });
    const trail = await one<{ action: string }>(
      db,
      `select action from audit_log where table_name = 'instance' order by occurred_at desc, sequence desc limit 1`,
    );
    expect(trail.action).toBe('instance_shared');
  });
});

describe('the administrators of a shared installation', () => {
  it('are not joined by a person who claims the installation, nor appointed by one', async () => {
    await asUser(db, bob, async () => {
      expect(await probe(`insert into instance_admins (user_id) values ($1)`, [bob], [bob])).toMatch(/^error .*row-level security/);
      expect(await probe(`select * from claim_instance_admin()`, [], [bob])).toMatch(/^error instance_already_claimed/);
      expect((await one<{ x: boolean }>(db, `select instance_has_no_admin() as x`)).x).toBe(false);
    });
  });

  it('are never left at none: the last one does not leave, whoever asks', async () => {
    const admins = await rows<{ user_id: string }>(db, `select user_id from instance_admins`);
    expect(admins).toHaveLength(1);
    const last = (admins[0] as { user_id: string }).user_id;
    expect(await probe(`delete from instance_admins where user_id = $1`, [last], [last])).toMatch(/^error last_instance_admin/);
    expect(await asUser(db, last, () => probe(`delete from instance_admins where user_id = $1`, [last], [last]))).toMatch(
      /^error last_instance_admin/,
    );
    // With a second one, either may go.
    const second = await newUser(db);
    await db.query('begin');
    try {
      await db.query(`insert into instance_admins (user_id) values ($1)`, [second]);
      await asUser(db, last, () => db.query(`delete from instance_admins where user_id = $1`, [last]));
      expect(await outcome(`delete from instance_admins where user_id = $1`, [second], [second])).toMatch(/^error last_instance_admin/);
    } finally {
      await db.query('rollback');
    }
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

  it('is recorded as created by that person, on the company and on the trail', async () => {
    const created = await one<{ actor_id: string }>(
      db,
      `select actor_id from audit_log where company_id = $1 and table_name = 'companies' order by occurred_at, sequence limit 1`,
      [aliceCompany],
    );
    expect(created.actor_id).toBe(alice);
    expect((await one<{ created_by: string }>(db, `select created_by from companies where id = $1`, [aliceCompany])).created_by).toBe(alice);
    // Books the installation brought in count against nobody.
    expect((await one<{ created_by: string | null }>(db, `select created_by from companies where id = $1`, [aliceBooks])).created_by).toBeNull();
  });

  it('is one, as many as the installation says', async () => {
    const said = await asUser(db, alice, () => expectError(db, `select create_company('Alice again', $1)`, [country]));
    expect(said).toMatch(/^company_limit/);
  });

  it('stays counted when its owner hands it to somebody else, and its creator cannot be rewritten', async () => {
    const carol = await newUser(db, 'carol-owner@example.test');
    await db.query('begin');
    try {
      // Carol joins by accepting an invitation: on a shared installation
      // nobody adds somebody else.
      const { token } = await asUser(db, alice, () =>
        one<{ token: string }>(db, `select token from invite_member($1, 'carol-owner@example.test', 'owner')`, [aliceCompany]),
      );
      await asUser(db, carol, () => db.query(`select accept_invitation($1)`, [token]));
      await asUser(db, alice, async () => {
        await db.query(`delete from company_members where company_id = $1 and user_id = $2`, [aliceCompany, alice]);
      });
      expect(await rows(db, `select 1 from company_members where user_id = $1 and role = 'owner' and company_id = $2`, [alice, aliceCompany])).toEqual([]);
      await asUser(db, alice, async () => {
        expect(await outcome(`select create_company('Alice once more', $1)`, [country], [])).toMatch(/^error company_limit/);
      });
      await asUser(db, carol, async () => {
        expect(await outcome(`update companies set created_by = null where id = $1`, [aliceCompany], [aliceCompany])).toMatch(
          /^error company_creator_is_fixed/,
        );
        expect(await outcome(`update companies set created_by = $2 where id = $1`, [aliceCompany, carol], [aliceCompany, carol])).toMatch(
          /^error company_creator_is_fixed/,
        );
      });
    } finally {
      await db.query('rollback');
    }
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

/** Every schema that holds a company's rows: one with a table that carries `company_id`. */
async function tenantSchemas(): Promise<string[]> {
  const found = await rows<{ name: string }>(
    db,
    `select distinct n.nspname as name
       from pg_class c
       join pg_namespace n on n.oid = c.relnamespace
       join pg_attribute a on a.attrelid = c.oid and a.attname = 'company_id' and not a.attisdropped
      where c.relkind = 'r' and n.nspname !~ '^pg_' and n.nspname not in ('information_schema', 'auth')
      order by 1`,
  );
  return found.map((one) => one.name);
}

/** Every table and view of those schemas with a `company_id`, from the catalogue, qualified. */
async function companyRelations(): Promise<string[]> {
  const found = await rows<{ name: string }>(
    db,
    `select format('%I.%I', n.nspname, c.relname) as name
       from pg_class c
       join pg_namespace n on n.oid = c.relnamespace
       join pg_attribute a on a.attrelid = c.oid and a.attname = 'company_id' and not a.attisdropped
      where n.nspname = any ($1::text[]) and c.relkind in ('r', 'v')
      order by 1`,
    [await tenantSchemas()],
  );
  return found.map((one) => one.name);
}

/**
 * Every function of those schemas a signed-in user may call whose first
 * argument is one of these uuids, with a call that names it and gives null to
 * every other argument it needs.
 */
async function takingFirst(names: readonly string[]): Promise<{ name: string; first: string; call: string }[]> {
  const found = await rows<{ name: string; first: string; args: string | null }>(
    db,
    `select format('%I.%I', s.nspname, p.proname) as name,
            p.proargnames[1] as first,
            string_agg(format('%I => null::%s', a.name, format_type(a.type, null)), ', ' order by a.n)
              filter (where a.n > 1 and a.n <= p.pronargs - p.pronargdefaults) as args
       from pg_proc p
       join pg_namespace s on s.oid = p.pronamespace
       cross join lateral unnest(p.proargnames[1:p.pronargs], p.proargtypes::oid[]) with ordinality as a(name, type, n)
      where s.nspname = any ($2::text[])
        and p.prokind = 'f'
        and p.prorettype <> 'trigger'::regtype
        and p.pronargs >= 1
        and p.proargnames[1] = any($1::text[])
        and p.proargtypes[0] = 'uuid'::regtype
        and has_function_privilege('authenticated', p.oid, 'execute')
      group by p.oid, s.nspname, p.proname, p.proargnames
      order by 1`,
    [names, await tenantSchemas()],
  );
  return found.map((fn) => ({
    name: fn.name,
    first: fn.first,
    call: `select * from ${fn.name}(${fn.first} => $1::uuid${fn.args === null ? '' : `, ${fn.args}`})`,
  }));
}

/** Alice's companies: the one she created, and her year of books. */
function aliceCompanies(): string[] {
  return [aliceCompany, aliceBooks];
}

/**
 * Rows of Alice's companies from every table that carries a company and has a
 * uuid of its own, read as the installer: what a stranger could try to name.
 * One row per table, and one per state where the table has one — a posted
 * document is guarded where a draft is not.
 */
async function aliceIds(): Promise<{ table: string; id: string }[]> {
  const tables = await rows<{ name: string; state: boolean }>(
    db,
    `select format('%I.%I', n.nspname, c.relname) as name,
            exists (select 1 from pg_attribute s where s.attrelid = c.oid and s.attname = 'state' and not s.attisdropped) as state
       from pg_class c
       join pg_namespace n on n.oid = c.relnamespace
       join pg_attribute k on k.attrelid = c.oid and k.attname = 'company_id' and not k.attisdropped
       join pg_attribute i on i.attrelid = c.oid and i.attname = 'id' and not i.attisdropped and i.atttypid = 'uuid'::regtype
      where n.nspname = any ($1::text[]) and c.relkind = 'r'
      order by 1`,
    [await tenantSchemas()],
  );
  // Alice herself too: a function that takes a person must not say whether she is one.
  const found: { table: string; id: string }[] = [
    { table: 'companies', id: aliceCompany },
    { table: 'companies', id: aliceBooks },
    { table: 'auth.users', id: alice },
  ];
  for (const { name, state } of tables) {
    const picked = await rows<{ id: string }>(
      db,
      state
        ? `select distinct on (state) id::text as id from ${name} where company_id = any ($1::uuid[]) order by state, id`
        : `select id::text as id from ${name} where company_id = any ($1::uuid[]) order by id limit 1`,
      [aliceCompanies()],
    );
    for (const row of picked) found.push({ table: name, id: row.id });
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
       select p.oid, format('%I.%I', s.nspname, p.proname) as proname, p.pronargs, p.pronargdefaults, a.name, a.type, a.n
         from pg_proc p
         join pg_namespace s on s.oid = p.pronamespace
         cross join lateral unnest(p.proargnames[1:p.pronargs], p.proargtypes::oid[]) with ordinality as a(name, type, n)
        where s.nspname = any ($1::text[]) and p.prokind = 'f' and p.prorettype <> 'trigger'::regtype
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
    [await tenantSchemas()],
  );
  return found.map((fn) => ({
    name: `${fn.name}.${fn.arg}`,
    first: fn.arg,
    call: `select * from ${fn.name}(${fn.arg} => $1::uuid${fn.args === null ? '' : `, ${fn.args}`})`,
  }));
}

interface Writable {
  table: string;
  /** The column the table names its company by: `company_id`, `id` for `companies`, or none for a child table. */
  companyColumn: string | null;
  /** For a table that carries no company: the column that names its parent, which does. */
  parent: { column: string; table: string; key: string } | null;
  /** The primary key, column by column. */
  key: string[];
  /** What an insert may name: every column but the generated ones and an identity. */
  columns: string[];
  /** Each uuid column a foreign key reads, and the table it points at. */
  references: { column: string; target: string }[];
  /** The type of its `state` column, when it has one. */
  stateType: string | null;
}

/**
 * Every table of a tenant schema that holds a company's rows and that a
 * signed-in user may insert into or update, with the uuid columns its foreign
 * keys read: the column of a composite key with the company points at the row
 * it names, and `company_id` points at `companies`. A table holds a company's
 * rows by its `company_id`; `companies` by its own id; and a table with
 * neither through a parent that does, named by a column that may not be empty
 * — a deposit through its declaration. A person is named by `user_id`, which
 * carries no key on purpose (decision 0007): that column points at
 * `auth.users` all the same.
 */
async function writableTables(): Promise<Writable[]> {
  const found = await rows<{
    table: string;
    company_column: string | null;
    parent: { column: string; table: string; key: string } | null;
    key: string[];
    columns: string[];
    refs: { column: string; target: string }[] | null;
    state_type: string | null;
  }>(
    db,
    `select * from (
     select format('%I.%I', n.nspname, c.relname) as table,
            case when c.oid = 'public.companies'::regclass then 'id'
                 when exists (select 1 from pg_attribute k where k.attrelid = c.oid and k.attname = 'company_id' and not k.attisdropped)
                   then 'company_id' end as company_column,
            (select jsonb_build_object('column', a.attname, 'table', format('%I.%I', tn.nspname, tc.relname), 'key', fa.attname)
               from pg_constraint f
               join pg_attribute a on a.attrelid = f.conrelid and a.attnum = f.conkey[1]
               join pg_attribute fa on fa.attrelid = f.confrelid and fa.attnum = f.confkey[1]
               join pg_class tc on tc.oid = f.confrelid
               join pg_namespace tn on tn.oid = tc.relnamespace
              where f.conrelid = c.oid and f.contype = 'f' and cardinality(f.conkey) = 1 and a.attnotnull
                and exists (select 1 from pg_attribute t where t.attrelid = f.confrelid and t.attname = 'company_id' and not t.attisdropped)
              order by a.attname limit 1) as parent,
            array(select a.attname::text
                    from pg_index i join pg_attribute a on a.attrelid = i.indrelid and a.attnum = any (i.indkey)
                   where i.indrelid = c.oid and i.indisprimary
                   order by array_position(i.indkey::smallint[], a.attnum)) as key,
            array(select a.attname::text from pg_attribute a
                   where a.attrelid = c.oid and a.attnum > 0 and not a.attisdropped
                     and a.attgenerated = '' and a.attidentity = ''
                   order by a.attnum) as columns,
            (select jsonb_agg(distinct r.ref)
               from (select jsonb_build_object('column', a.attname, 'target', format('%I.%I', tn.nspname, tc.relname)) as ref
                       from pg_constraint f
                       cross join lateral unnest(f.conkey, f.confkey) as k(attnum, fattnum)
                       join pg_attribute a on a.attrelid = f.conrelid and a.attnum = k.attnum
                       join pg_attribute fa on fa.attrelid = f.confrelid and fa.attnum = k.fattnum
                       join pg_class tc on tc.oid = f.confrelid
                       join pg_namespace tn on tn.oid = tc.relnamespace
                      where f.conrelid = c.oid and f.contype = 'f' and a.atttypid = 'uuid'::regtype
                        and fa.attname <> 'company_id'
                     union all
                     select jsonb_build_object('column', a.attname, 'target', 'auth.users')
                       from pg_attribute a
                      where a.attrelid = c.oid and a.attname = 'user_id' and a.atttypid = 'uuid'::regtype and not a.attisdropped
                        and not exists (select 1 from pg_constraint f
                                         where f.conrelid = c.oid and f.contype = 'f' and a.attnum = any (f.conkey))) r) as refs,
            (select format_type(s.atttypid, null) from pg_attribute s
              where s.attrelid = c.oid and s.attname = 'state' and not s.attisdropped
                and exists (select 1 from pg_type t where t.oid = s.atttypid and t.typtype = 'e')) as state_type
       from pg_class c
       join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = any ($1::text[]) and c.relkind = 'r'
        and (has_table_privilege('authenticated', c.oid, 'insert') or has_any_column_privilege('authenticated', c.oid, 'update'))
     ) t
     where t.company_column is not null or t.parent is not null
     order by 1`,
    [await tenantSchemas()],
  );
  return found.map((one) => ({
    table: one.table,
    companyColumn: one.company_column,
    parent: one.company_column === null ? one.parent : null,
    key: one.key,
    columns: one.columns,
    references: one.refs ?? [],
    stateType: one.state_type,
  }));
}

/** Rows of a company's table to write over: one, and one per state where it has a state. */
async function rowsOf(table: Writable, companyId: string): Promise<Record<string, unknown>[]> {
  const from =
    table.companyColumn !== null
      ? `${table.table} t where t.${table.companyColumn} = $1`
      : `${table.table} t join ${table.parent?.table} p on p.${table.parent?.key} = t.${table.parent?.column} where p.company_id = $1`;
  const picked = await rows<{ row: Record<string, unknown> }>(
    db,
    table.stateType === null
      ? `select to_jsonb(t) as row from ${from} order by ${table.key.map((k) => `t.${k}`).join(', ')} limit 1`
      : `select distinct on (t.state) to_jsonb(t) as row from ${from} order by t.state, ${table.key.map((k) => `t.${k}`).join(', ')}`,
    [companyId],
  );
  return picked.map((one) => one.row);
}

/** Rows of Alice's that a column pointing at this table could name. */
async function aliceTargets(target: string): Promise<string[]> {
  if (target === 'public.companies') return aliceCompanies();
  if (target === 'auth.users') return [alice];
  const state = await one<{ x: boolean }>(
    db,
    `select exists (select 1 from pg_attribute a where a.attrelid = $1::regclass and a.attname = 'state' and not a.attisdropped)
        and exists (select 1 from pg_attribute a where a.attrelid = $1::regclass and a.attname = 'company_id' and not a.attisdropped) as x`,
    [target],
  );
  const hasCompany = await one<{ x: boolean }>(
    db,
    `select exists (select 1 from pg_attribute a where a.attrelid = $1::regclass and a.attname = 'company_id' and not a.attisdropped) as x`,
    [target],
  );
  if (!hasCompany.x) return [];
  const picked = await rows<{ id: string }>(
    db,
    state.x
      ? `select distinct on (state) id::text as id from ${target} where company_id = any ($1::uuid[]) order by state, id`
      : `select id::text as id from ${target} where company_id = any ($1::uuid[]) order by id limit 2`,
    [aliceCompanies()],
  );
  return picked.map((one) => one.id);
}

/**
 * The functions that read ids out of an object or a list they are given, and
 * how to hand them one. Found from the catalogue — every function a signed-in
 * user may call that takes `jsonb` and names a key ending in `_id` in its
 * body, or takes a list of uuids — and written here, because what shape an
 * object has is the function's: the test below refuses a function that is
 * found and not written down. A key the function only writes, never reads
 * from its argument, is said so rather than probed.
 */
const READS_IDS_INSIDE: Record<string, { reads: string[]; writesOnly?: string[]; calls?: (id: string) => { sql: string; params: unknown[] }[] }> = {
  'public.set_preferences': {
    reads: ['preferred_company_id'],
    calls: (id) => [{ sql: `select preferred_company_id from set_preferences($1::jsonb)`, params: [{ preferred_company_id: id }] }],
  },
  'public.post_module_entry': {
    reads: ['account_id', 'contact_id'],
    calls: (id) => [
      {
        sql: `select * from post_module_entry($1, 'assets', 'probe', $2::date, 'probe', $3::jsonb, null)`,
        params: [bobBooks, openDay, [{ account_id: id, debit: 10 }, { account_code: '__first__', credit: 10 }]],
      },
      {
        sql: `select * from post_module_entry($1, 'assets', 'probe', $2::date, 'probe', $3::jsonb, null)`,
        params: [bobBooks, openDay, [{ account_code: '__first__', debit: 10, contact_id: id }, { account_code: '__first__', credit: 10 }]],
      },
    ],
  },
  'public.opening_balance': {
    reads: ['contact_id'],
    calls: (id) => [
      {
        sql: `select * from opening_balance($1, (select f.id from fiscal_years f where f.company_id = $1 order by f.start_date desc limit 1), $2::jsonb, false)`,
        params: [bobBooks, [{ account_code: '__first__', debit: 10, contact_id: id }, { account_code: '__first__', credit: 10 }]],
      },
    ],
  },
  'public.general_ledger': {
    reads: [],
    calls: (id) => [{ sql: `select * from general_ledger($1, '1900-01-01'::date, '2999-12-31'::date, $2::uuid[])`, params: [bobBooks, [id]] }],
  },
  'public.settle_from_statement': {
    reads: [],
    calls: (id) => [
      {
        sql: `select * from settle_from_statement((select t.id from bank_transactions t where t.company_id = $1 order by t.id limit 1), $2::uuid[])`,
        params: [bobBooks, [id]],
      },
    ],
  },
  'public.import_company': {
    reads: ['company_id', 'entry_id'],
    calls: (id) => [{ sql: `select import_company($1::jsonb)`, params: [{ manifest: { company: { id } }, tables: { 'public.companies': [{ id, company_id: id }] } }] }],
  },
  // These name an id only in what they write: the contact a line of the books
  // was matched to, the statement a new one follows.
  'public.import_books': { reads: [], writesOnly: ['contact_id'] },
  'public.import_bank_statement': { reads: [], writesOnly: ['previous_statement_id'] },
  // The jsonb it takes is a list of calendar addresses; the subject it names
  // is an argument of its own, and the key is only what it writes on the trail.
  'public.record_filing_proof': { reads: [], writesOnly: ['subject_id'] },
};

describe('the other person, signed in', () => {
  it('sees their own companies and no other — not the demo one, not Alice’s', async () => {
    const seen = await asUser(db, bob, () => rows<{ id: string }>(db, `select id from companies order by id`));
    expect(seen.map((one) => one.id)).toEqual([bobCompany, bobBooks].sort());
    expect(demoCompany).not.toBe(bobCompany);
  });

  it('is probed in every schema that holds a company’s rows, modules included', async () => {
    const schemas = await tenantSchemas();
    expect(schemas).toEqual(expect.arrayContaining(['public', 'budgets', 'fixed_assets', 'tax']));
    // Every module table Alice could have rows in, she has: the probes below name them.
    const empty = await rows<{ name: string }>(
      db,
      `select format('%I.%I', n.nspname, c.relname) as name
         from pg_class c join pg_namespace n on n.oid = c.relnamespace
         join pg_attribute a on a.attrelid = c.oid and a.attname = 'company_id' and not a.attisdropped
        where n.nspname = any ($1::text[]) and n.nspname <> 'public' and c.relkind = 'r'
        order by 1`,
      [schemas],
    );
    const missing: string[] = [];
    for (const { name } of empty) {
      const n = await one<{ n: number }>(db, `select count(*)::int as n from ${name} where company_id = any ($1::uuid[])`, [aliceCompanies()]);
      if (n.n === 0) missing.push(name);
    }
    expect(missing).toEqual([]);
  });

  it('reads no row of Alice’s companies from any table or view that carries a company', async () => {
    const relations = await companyRelations();
    expect(relations.length).toBeGreaterThan(30);
    const leaked: string[] = [];
    let read = 0;
    await asUser(db, bob, async () => {
      for (const relation of relations) {
        for (const company of aliceCompanies()) {
          const said = await probe(`select count(*)::int as n from ${relation} where company_id = $1`, [company], [company]);
          // A relation the person may not read at all is an error, and the same one for any company.
          if (said.startsWith('ok')) read += 1;
          if (said.startsWith('ok') && said !== 'ok [{"n":0}]') leaked.push(`${relation}: ${said}`);
        }
      }
    });
    expect(leaked).toEqual([]);
    // Asked, not refused: the person reads these relations, and finds nothing of Alice's there.
    expect(read).toBeGreaterThan(40);
  });

  it('is answered about Alice’s company exactly as about a company that does not exist, by every function that takes one', async () => {
    const functions = await takingFirst(['p_company_id']);
    expect(functions.length).toBeGreaterThan(30);
    const differs: string[] = [];
    await asUser(db, bob, async () => {
      for (const fn of functions) {
        const nobodys = await probe(fn.call, [NOWHERE], [...aliceCompanies(), NOWHERE]);
        for (const company of aliceCompanies()) {
          const theirs = await probe(fn.call, [company], [...aliceCompanies(), NOWHERE]);
          if (theirs !== nobodys) differs.push(`${fn.name}: ${theirs} / ${nobodys}`);
        }
      }
    });
    expect(differs).toEqual([]);
  });

  it('is answered about every row of Alice’s, named by its id, as about a row that does not exist, by every function that takes an id', async () => {
    const ids = await aliceIds();
    expect(ids.length).toBeGreaterThan(40);
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

  it('is answered about an id of Alice’s inside an object or a list as about an id nobody holds', async () => {
    const found = await rows<{ name: string; keys: string[] | null; list: boolean }>(
      db,
      `select format('%I.%I', n.nspname, p.proname) as name,
              (select array_agg(distinct m[1] order by m[1]) from regexp_matches(p.prosrc, '''([a-z_]+_id)''', 'g') m) as keys,
              'uuid[]'::regtype = any (p.proargtypes::oid[]) as list
         from pg_proc p join pg_namespace n on n.oid = p.pronamespace
        where n.nspname = any ($1::text[]) and p.prokind = 'f'
          and has_function_privilege('authenticated', p.oid, 'execute')
          and (('uuid[]'::regtype = any (p.proargtypes::oid[]))
               or (('jsonb'::regtype = any (p.proargtypes::oid[]) or 'json'::regtype = any (p.proargtypes::oid[]))
                   and p.prosrc ~ '''[a-z_]+_id'''))
        order by 1`,
      [await tenantSchemas()],
    );
    expect(found.length).toBeGreaterThan(5);
    // Every one of them is written down above, with every key its body names.
    const unwritten = found
      .filter((fn) => {
        const known = READS_IDS_INSIDE[fn.name];
        if (known === undefined) return true;
        const said = new Set([...known.reads, ...(known.writesOnly ?? [])]);
        return (fn.keys ?? []).some((key) => !said.has(key)) || (known.calls === undefined && (known.reads.length > 0 || fn.list));
      })
      .map((fn) => `${fn.name} (${(fn.keys ?? []).join(', ')}${fn.list ? '; a list of uuids' : ''})`);
    expect(unwritten).toEqual([]);

    const firstAccount = (await one<{ code: string }>(db, `select code from accounts where company_id = $1 order by code limit 1`, [bobBooks])).code;
    const ids = await aliceIds();
    const differs: string[] = [];
    let probed = 0;
    await asUser(db, bob, async () => {
      for (const [name, known] of Object.entries(READS_IDS_INSIDE)) {
        if (known.calls === undefined) continue;
        const fill = (value: unknown): unknown => JSON.parse(JSON.stringify(value).split('__first__').join(firstAccount));
        const nobodys = known.calls(NOWHERE).map((call) => ({ ...call, params: call.params.map(fill) }));
        for (const { table, id } of ids) {
          const theirs = known.calls(id).map((call) => ({ ...call, params: call.params.map(fill) }));
          for (const [index, call] of theirs.entries()) {
            const other = nobodys[index] as { sql: string; params: unknown[] };
            const a = await probe(call.sql, call.params, [id, NOWHERE]);
            const b = await probe(other.sql, other.params, [id, NOWHERE]);
            probed += 1;
            if (a !== b) differs.push(`${name}#${index}(${table}): ${a} / ${b}`);
          }
        }
      }
    });
    expect(probed).toBeGreaterThan(100);
    expect(differs).toEqual([]);
  });

  it('is answered alike when a row of their own names a row of Alice’s or a row that does not exist, and is never let write it', async () => {
    const tables = await writableTables();
    expect(tables.length).toBeGreaterThan(30);
    // The company itself, a table that reaches its company through a parent,
    // and the members, whose person carries no key: found, not listed.
    expect(tables.map((table) => table.table)).toEqual(
      expect.arrayContaining(['public.companies', 'public.tax_filing_deposits', 'public.company_members']),
    );
    expect(tables.find((table) => table.table === 'public.company_members')?.references).toEqual(
      expect.arrayContaining([{ column: 'user_id', target: 'auth.users' }]),
    );
    const differs: string[] = [];
    // A write that names a row of Alice's and goes through is a leak whatever
    // a row of nobody's is answered: it plants a reference to her row, or puts
    // her somewhere she did not ask to be.
    const written: string[] = [];
    let probed = 0;
    const targets = new Map<string, string[]>();
    for (const table of tables) {
      for (const { target } of table.references) {
        if (!targets.has(target)) targets.set(target, await aliceTargets(target));
      }
    }
    const states = new Map<string, string[]>();
    for (const table of tables) {
      if (table.stateType !== null && !states.has(table.stateType)) {
        const labels = await one<{ labels: string[] }>(db, `select enum_range(null::${table.stateType})::text[] as labels`);
        states.set(table.stateType, labels.labels);
      }
    }
    const own = new Map<string, Record<string, unknown>[]>();
    for (const table of tables) own.set(table.table, await rowsOf(table, bobBooks));
    for (const name of ['public.companies', 'public.tax_filing_deposits', 'public.company_members']) {
      expect(own.get(name)?.length, name).toBeGreaterThan(0);
    }

    await asUser(db, bob, async () => {
      for (const table of tables) {
        for (const row of own.get(table.table) ?? []) {
          const where = table.key.map((k, i) => `t.${k}::text = $${i + 2}`).join(' and ');
          const keyValues = table.key.map((k) => String(row[k]));
          // The same new id for both inserts, so that an answer quoting it does not differ.
          const fresh = crypto.randomUUID();
          for (const { column, target } of table.references) {
            const theirs = targets.get(target) ?? [];
            const variants: { set: string; params: unknown[] }[] = [{ set: '', params: [] }];
            if (table.stateType !== null) {
              for (const label of states.get(table.stateType) ?? []) {
                if (label !== row['state']) variants.push({ set: `, state = '${label}'::${table.stateType}`, params: [] });
              }
            }
            const write = async (id: string): Promise<string[]> => {
              const said: string[] = [];
              for (const variant of variants) {
                said.push(
                  await probeWrite(
                    `update ${table.table} t set ${column} = $1::uuid${variant.set} where ${where} returning true as written`,
                    [id, ...keyValues],
                    [id, NOWHERE],
                  ),
                );
              }
              const copy: Record<string, unknown> = { ...row, [column]: id };
              if (table.key.length === 1 && table.key[0] === 'id' && column !== 'id') copy['id'] = fresh;
              said.push(
                await probeWrite(
                  `insert into ${table.table} (${table.columns.join(', ')}) select ${table.columns.join(', ')} from jsonb_populate_record(null::${table.table}, $1::jsonb) returning true as written`,
                  [copy],
                  [id, NOWHERE, fresh],
                ),
              );
              return said;
            };
            const nobodys = await write(NOWHERE);
            for (const id of theirs) {
              const answers = await write(id);
              probed += answers.length;
              for (const [index, answer] of answers.entries()) {
                if (answer !== nobodys[index]) differs.push(`${table.table}.${column} (${String(row['state'] ?? '')} #${index}): ${answer} / ${nobodys[index]}`);
                if (answer.startsWith('ok [{')) written.push(`${table.table}.${column} (${String(row['state'] ?? '')} #${index})`);
              }
            }
          }
        }
      }
    });
    expect(probed).toBeGreaterThan(300);
    expect(differs).toEqual([]);
    expect(written).toEqual([]);
  });

  it('cannot post a draft of their own onto an entry of Alice’s, nor learn the number it carries', async () => {
    const theirs = await one<{ id: string; number: string }>(
      db,
      `select e.id, e.number from entries e where e.company_id = $1 and e.state = 'posted' and e.number is not null order by e.number limit 1`,
      [aliceBooks],
    );
    const draft = await one<{ id: string }>(
      db,
      `select d.id from documents d where d.company_id = $1 and d.state = 'draft' order by d.id limit 1`,
      [bobBooks],
    ).catch(async () =>
      one<{ id: string }>(
        db,
        `insert into documents (company_id, doc_type, contact_id, document_date)
         select $1, 'sale_invoice', c.id, $2::date from contacts c where c.company_id = $1 order by c.id limit 1 returning id`,
        [bobBooks, openDay],
      ),
    );
    await asUser(db, bob, async () => {
      const post = (entry: string) =>
        probe(`update documents set state = 'posted', entry_id = $2, accounting_date = $3::date where id = $1`, [draft.id, entry, openDay], [entry, NOWHERE]);
      const said = await post(theirs.id);
      expect(said).not.toContain(theirs.number);
      expect(said).toBe(await post(NOWHERE));
    });
  });

  it('cannot post an entry of their own on a journal of Alice’s to read where her numbering stands', async () => {
    const posted = await one<{ journal_id: string; number: string; entry_date: string }>(
      db,
      `select e.journal_id, e.number, e.entry_date::text from entries e
        where e.company_id = $1 and e.state = 'posted' and e.number is not null order by e.posted_at desc limit 1`,
      [aliceBooks],
    );
    // Where a country forbids a hole in the sequence, the guard compares the
    // number with the counter of the journal: that is where it would read hers.
    await db.query('begin');
    try {
      await db.query(
        `update country_defaults set numbering_gapless = true where country = (select fiscal_country from companies where id = $1)`,
        [bobBooks],
      );
      const draft = await one<{ id: string }>(
        db,
        `insert into entries (company_id, journal_id, entry_date, description)
         select $1, j.id, $2::date, 'probe' from journals j where j.company_id = $1 order by j.code limit 1 returning id`,
        [bobBooks, posted.entry_date],
      );
      await db.query(
        `insert into entry_lines (entry_id, company_id, account_id, debit, credit)
         select $1, $2, a.id, case when n = 1 then 10 else 0 end, case when n = 2 then 10 else 0 end
           from (select id, row_number() over (order by code) as n from accounts where company_id = $2) a where a.n <= 2`,
        [draft.id, bobBooks],
      );
      await asUser(db, bob, async () => {
        const post = (journal: string, number: string) =>
          outcome(
            `update entries set state = 'posted', posted_at = now(), journal_id = $2, number = $3 where id = $1`,
            [draft.id, journal, number],
            [journal, NOWHERE],
          );
        // Her last number, and one that is not: the answer is the one given for a journal nobody holds.
        for (const number of [posted.number, `${posted.number}9`]) {
          const theirs = await post(posted.journal_id, number);
          expect(theirs).toMatch(/^error /);
          expect(theirs).toBe(await post(NOWHERE, number));
        }
      });
    } finally {
      await db.query('rollback');
    }
  });

  it('cannot keep Alice from cancelling an invoice by naming it on a credit note of their own', async () => {
    const invoice = await one<{ id: string }>(
      db,
      `select d.id from documents d where d.company_id = $1 and d.state = 'posted' and d.doc_type = 'sale_invoice' order by d.number limit 1`,
      [aliceBooks],
    );
    await asUser(db, bob, async () => {
      const plant = (id: string) =>
        probe(
          `insert into documents (company_id, doc_type, contact_id, document_date, reversed_document_id)
           select $1, 'sale_credit_note', c.id, $3::date, $2 from contacts c where c.company_id = $1 order by c.id limit 1`,
          [bobBooks, id, openDay],
          [id, NOWHERE],
        );
      expect(await plant(invoice.id)).toBe(await plant(NOWHERE));
      expect(await plant(invoice.id)).toMatch(/^error /);
    });
  });

  it('cannot name a company they may not know of as the one they open first', async () => {
    await asUser(db, bob, async () => {
      const prefer = (id: string) => probe(`select * from set_preferences(jsonb_build_object('preferred_company_id', $1::text))`, [id], [id, NOWHERE]);
      const nobodys = await prefer(NOWHERE);
      expect(nobodys).toMatch(/^error unknown_company/);
      for (const company of aliceCompanies()) expect(await prefer(company)).toBe(nobodys);
      const direct = (id: string) => probe(`insert into user_preferences (user_id, preferred_company_id) values ($1, $2)`, [bob, id], [id, NOWHERE]);
      for (const company of aliceCompanies()) expect(await direct(company)).toBe(await direct(NOWHERE));
      expect(await prefer(bobBooks)).toMatch(/^ok /);
    });
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
      const trail = await rows(db, `select table_name from audit_log where company_id is null`);
      expect(trail).toEqual([]);
    });
  });

  it('reads no counter of the trail: the row id is the installation’s, and not theirs to read', async () => {
    await asUser(db, bob, async () => {
      expect(await probe(`select id from audit_log limit 1`, [], [])).toMatch(/^error permission denied/);
      expect(await probe(`select * from audit_log limit 1`, [], [])).toMatch(/^error permission denied/);
      expect(await probe(`select last_value from audit_log_id_seq`, [], [])).toMatch(/^error permission denied/);
      // What they read of their own trail, in its order.
      expect(
        await probe(`select occurred_at, sequence, table_name, action from audit_log where company_id = $1 order by occurred_at, sequence`, [bobBooks], []),
      ).toMatch(/^ok /);
    });
  });

  it('reads nothing that moves when Alice works: every table and view of theirs reads the same whether she did nothing or a great deal', async () => {
    const readable = await rows<{ name: string; columns: string[] }>(
      db,
      `select format('%I.%I', n.nspname, c.relname) as name,
              array(select format('%I', a.attname) from pg_attribute a
                     where a.attrelid = c.oid and a.attnum > 0 and not a.attisdropped
                       and has_column_privilege('authenticated', c.oid, a.attnum, 'select')
                     order by a.attnum) as columns
         from pg_class c join pg_namespace n on n.oid = c.relnamespace
        where n.nspname = any ($1::text[]) and c.relkind in ('r', 'v', 'm')
          and has_any_column_privilege('authenticated', c.oid, 'select')
        order by 1`,
      [await tenantSchemas()],
    );
    expect(readable.length).toBeGreaterThan(50);
    const scrub = (text: string): string =>
      text.replace(UUID, '<id>').replace(/\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}(\.\d+)?([+-]\d{2}(:\d{2})?|Z)?/g, '<at>');
    const view = async (): Promise<Record<string, string>> => {
      const seen: Record<string, string> = {};
      await asUser(db, bob, async () => {
        for (const { name, columns } of readable) {
          if (columns.length === 0) continue;
          // Row by row, sorted once the ids are out: what a row says, not where a random id put it.
          const said = await outcome(`select ${columns.join(', ')} from ${name}`, [], []);
          seen[name] = said.startsWith('ok ')
            ? (JSON.parse(said.slice(3)) as unknown[]).map((row) => scrub(JSON.stringify(row))).sort().join('\n')
            : scrub(said);
        }
      });
      return seen;
    };
    const contact = (company: string, name: string) =>
      db.query(`insert into contacts (company_id, name, contact_type, country) values ($1, $2, 'customer', $3)`, [company, name, country]);
    // Bob writes, Alice writes so much or not at all, Bob writes again, and Bob reads.
    const scenario = async (times: number): Promise<Record<string, string>> => {
      await db.query('begin');
      try {
        await asUser(db, bob, () => contact(bobBooks, 'Before'));
        for (let n = 0; n < times; n += 1) {
          await asUser(db, alice, async () => {
            await contact(aliceBooks, `Alice ${n}`);
            await db.query(`update accounts set name = name || '.' where company_id = $1 and id = (select id from accounts where company_id = $1 order by code limit 1)`, [aliceBooks]);
          });
        }
        await asUser(db, bob, () => contact(bobBooks, 'After'));
        return await view();
      } finally {
        await db.query('rollback');
      }
    };
    const quiet = await scenario(0);
    const busy = await scenario(5);
    const moved = Object.keys(quiet).filter((name) => quiet[name] !== busy[name]);
    expect(moved).toEqual([]);
  });

  it('keeps everything Alice may do in her own company', async () => {
    await asUser(db, alice, async () => {
      const seen = await rows<{ id: string }>(db, `select id from companies order by id`);
      expect(seen.map((one) => one.id)).toEqual(aliceCompanies().sort());
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
        for (const company of aliceCompanies()) {
          const said = await outcome(`select count(*)::int as n from ${relation} where company_id = $1`, [company], [company]);
          if (said.startsWith('ok')) read += 1;
          if (said.startsWith('ok') && said !== 'ok [{"n":0}]') leaked.push(`${relation}: ${said}`);
        }
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
        for (const company of aliceCompanies()) {
          expect(await outcome(sql, [company], [company, NOWHERE]), sql).toBe(await outcome(sql, [NOWHERE], [company, NOWHERE]));
        }
      }
    });
  });
});

/**
 * Run a block as a connection that is neither a person nor a key nor the
 * installer: the backend role, which row level security does not stop, or —
 * with no role — the owner, as the management API, `psql` or a scheduled job
 * connects.
 */
async function asBackend<T>(role: 'service_role' | null, fn: () => Promise<T>): Promise<T> {
  await db.exec(
    `select set_config('request.jwt.claims', '', false); select set_config('ekwo.installing', '', false);${role === null ? '' : ` set role ${role};`}`,
  );
  try {
    return await fn();
  } finally {
    await db.exec(`reset role; select set_config('ekwo.installing', 'on', false);`);
  }
}

describe('a posted row, on a shared installation', () => {
  /** Every change a posted document, its lines, its entry and the entry's lines refuse. */
  const changes = async (): Promise<{ sql: string; params: unknown[] }[]> => {
    // The last one booked: past any lock date, so that the guards of a posted
    // row are what answers, and not the closed period.
    const document = await one<{ id: string; entry_id: string; account: string }>(
      db,
      `select d.id, d.entry_id, (select a.id from accounts a where a.company_id = d.company_id order by a.code limit 1) as account
         from documents d join entries e on e.id = d.entry_id
        where d.company_id = $1 and d.state = 'posted'
          and exists (select 1 from document_lines l where l.document_id = d.id)
        order by e.entry_date desc, d.number desc limit 1`,
      [aliceBooks],
    );
    const line = await one<{ id: string }>(db, `select id from document_lines where document_id = $1 order by sequence limit 1`, [document.id]);
    const entryLine = await one<{ id: string }>(db, `select id from entry_lines where entry_id = $1 order by id limit 1`, [document.entry_id]);
    return [
      { sql: `update documents set number = number || '-9' where id = $1`, params: [document.id] },
      { sql: `update documents set state = 'draft' where id = $1`, params: [document.id] },
      { sql: `update documents set company_id = $2 where id = $1`, params: [document.id, bobBooks] },
      { sql: `delete from documents where id = $1`, params: [document.id] },
      { sql: `update document_lines set unit_price = unit_price + 1 where id = $1`, params: [line.id] },
      {
        sql: `insert into document_lines (document_id, company_id, sequence, name, quantity, unit_price) values ($1, $2, 9999, 'More', 1, 1)`,
        params: [document.id, aliceBooks],
      },
      { sql: `delete from document_lines where id = $1`, params: [line.id] },
      { sql: `update entries set number = number || '-9' where id = $1`, params: [document.entry_id] },
      { sql: `update entries set state = 'draft' where id = $1`, params: [document.entry_id] },
      { sql: `update entries set company_id = $2 where id = $1`, params: [document.entry_id, bobBooks] },
      { sql: `delete from entries where id = $1`, params: [document.entry_id] },
      { sql: `update entry_lines set debit = debit + 1, credit = credit + 1 where id = $1`, params: [entryLine.id] },
      {
        sql: `insert into entry_lines (entry_id, company_id, account_id, debit, credit) values ($1, $2, $3, 1, 0)`,
        params: [document.entry_id, aliceBooks, document.account],
      },
      { sql: `delete from entry_lines where id = $1`, params: [entryLine.id] },
    ];
  };

  for (const role of ['service_role', null] as const) {
    it(`cannot be changed by ${role ?? 'the owner'}, who may know of no company and is not stopped by row level security`, async () => {
      const all = await changes();
      const said = await asBackend(role, async () => {
        // What made the guards step aside for them once.
        const known = await one<{ x: boolean; installer: boolean }>(db, `select may_know_of_company($1) as x, is_installer() as installer`, [aliceBooks]);
        expect(known).toEqual({ x: false, installer: false });
        const answers: string[] = [];
        for (const change of all) answers.push(`${change.sql.split('\n')[0]} → ${await probeWrite(change.sql, change.params, [])}`);
        return answers;
      });
      const through = said.filter((answer) => !/→ error (document_posted|entry_posted)/.test(answer));
      expect(through).toEqual([]);
    });
  }

  it('is refused to a person who writes into a company they may not know of, before anything is read, as for a company of nobody’s', async () => {
    const all = await changes();
    const draft = await one<{ id: string }>(db, `select id from documents where company_id = $1 and state = 'draft' order by id limit 1`, [bobBooks]).catch(
      async () =>
        one<{ id: string }>(
          db,
          `insert into documents (company_id, doc_type, contact_id, document_date)
           select $1, 'sale_invoice', c.id, $2::date from contacts c where c.company_id = $1 order by c.id limit 1 returning id`,
          [bobBooks, openDay],
        ),
    );
    await asUser(db, bob, async () => {
      const move = (company: string) => probeWrite(`update documents set company_id = $2 where id = $1`, [draft.id, company], [company, NOWHERE]);
      expect(await move(aliceBooks)).toMatch(/^error not_allowed: this row is written into no company you may write in/);
      expect(await move(aliceBooks)).toBe(await move(NOWHERE));
      // A line onto her posted document and onto her posted entry, and the
      // same with ids of nobody's.
      for (const change of all.filter((one) => one.sql.startsWith('insert'))) {
        const theirs = await probeWrite(change.sql, change.params, change.params.map(String));
        expect(theirs).toBe(await probeWrite(change.sql, change.params.map(() => NOWHERE), [NOWHERE]));
        expect(theirs).toMatch(/^error not_allowed/);
      }
    });
  });
});

describe('a company’s own defaults, on a shared installation', () => {
  it('name accounts and journals of that company only, and say nothing of anybody else’s', async () => {
    const theirs = await one<{ account: string; journal: string }>(
      db,
      `select (select id from accounts where company_id = $1 order by code limit 1) as account,
              (select id from journals where company_id = $1 order by code limit 1) as journal`,
      [aliceBooks],
    );
    const columns = await rows<{ col: string; target: string }>(
      db,
      `select a.attname::text as col, f.confrelid::regclass::text as target
         from pg_constraint f join pg_attribute a on a.attrelid = f.conrelid and a.attnum = f.conkey[1]
        where f.conrelid = 'public.companies'::regclass and f.contype = 'f' and f.confrelid in ('accounts'::regclass, 'journals'::regclass)
        order by 1`,
    );
    expect(columns.length).toBeGreaterThanOrEqual(10);
    await asUser(db, bob, async () => {
      for (const { col, target } of columns) {
        const id = target === 'accounts' ? theirs.account : theirs.journal;
        const set = (value: string) => probeWrite(`update companies set ${col} = $2 where id = $1 returning true as written`, [bobBooks, value], [value, NOWHERE]);
        const said = await set(id);
        expect(said, col).toMatch(new RegExp(`^error .*"companies_${col}_company_id_fkey"`));
        expect(said, col).toBe(await set(NOWHERE));
      }
    });
  });
});

describe('a deposit of a declaration, on a shared installation', () => {
  it('names files of its own declaration’s company only, and is answered alike for a file of Alice’s and a file of nobody’s', async () => {
    const own = await one<{ filing: string; file: string }>(
      db,
      `select (select id from tax_filings where company_id = $1 order by id limit 1) as filing,
              (select id from attachments where company_id = $1 order by id limit 1) as file`,
      [bobBooks],
    );
    const hers = await one<{ filing: string; file: string }>(
      db,
      `select (select id from tax_filings where company_id = $1 order by id limit 1) as filing,
              (select id from attachments where company_id = $1 order by id limit 1) as file`,
      [aliceBooks],
    );
    const deposit = (filing: string, file: string) =>
      probeWrite(
        `insert into tax_filing_deposits (filing_id, sequence, sent_file_id) values ($1, 77, $2) returning true as written`,
        [filing, file],
        [filing, file, NOWHERE],
      );
    await asUser(db, bob, async () => {
      expect(await deposit(own.filing, hers.file)).toMatch(/^error unknown_attachment/);
      expect(await deposit(own.filing, hers.file)).toBe(await deposit(own.filing, NOWHERE));
      expect(await deposit(hers.filing, hers.file)).toMatch(/^error not_allowed/);
      expect(await deposit(hers.filing, hers.file)).toBe(await deposit(NOWHERE, NOWHERE));
      expect(await deposit(own.filing, own.file)).toMatch(/^ok /);
    });
    // The backend role meets the same check.
    await asBackend('service_role', async () => {
      expect(await deposit(own.filing, hers.file)).toMatch(/^error unknown_attachment/);
      expect(await deposit(own.filing, own.file)).toMatch(/^ok /);
    });
  });
});

describe('the members of a company, on a shared installation', () => {
  it('are not joined by somebody a manager names, whether that person has an account or not', async () => {
    await asUser(db, bob, async () => {
      const add = (person: string) =>
        probeWrite(`insert into company_members (company_id, user_id, role) values ($1, $2, 'viewer') returning true as written`, [bobBooks, person], [person, NOWHERE]);
      const said = await add(alice);
      expect(said).toMatch(/^error not_allowed: on a shared installation a person joins a company by accepting an invitation/);
      expect(said).toBe(await add(NOWHERE));
    });
  });

  it('are not handed to another person, nor moved to another company', async () => {
    await asUser(db, bob, async () => {
      const hand = (person: string) =>
        probeWrite(`update company_members set user_id = $2 where company_id = $1 and user_id = $3 returning true as written`, [bobBooks, person, bob], [person, NOWHERE]);
      expect(await hand(alice)).toMatch(/^error not_allowed: on a shared installation a membership stays/);
      expect(await hand(alice)).toBe(await hand(NOWHERE));
      const move = (company: string) =>
        probeWrite(`update company_members set company_id = $2 where company_id = $1 and user_id = $3 returning true as written`, [bobBooks, company, bob], [company, NOWHERE]);
      expect(await move(bobCompany)).toMatch(/^error not_allowed/);
      expect(await move(aliceBooks)).toBe(await move(NOWHERE));
    });
  });

  it('are joined by a person who accepts an invitation, and added by the operator', async () => {
    const dave = await newUser(db, 'dave-joins@example.test');
    const erin = await newUser(db, 'erin-added@example.test');
    await db.query('begin');
    try {
      const { token } = await asUser(db, bob, () =>
        one<{ token: string }>(db, `select token from invite_member($1, 'dave-joins@example.test', 'viewer')`, [bobBooks]),
      );
      await asUser(db, dave, () => db.query(`select accept_invitation($1)`, [token]));
      await asUser(db, DEMO_OWNER, () =>
        db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'viewer')`, [bobBooks, erin]),
      );
      const members = await rows<{ user_id: string }>(db, `select user_id from company_members where company_id = $1 and user_id = any ($2::uuid[]) order by user_id`, [
        bobBooks,
        [dave, erin],
      ]);
      expect(members.map((one) => one.user_id)).toEqual([dave, erin].sort());
    } finally {
      await db.query('rollback');
    }
  });
});

describe('the operator', () => {
  it('administers the shared installation and is the one caller who sees every company — never a person on a trial', async () => {
    // The demo owner is the seeded administrator; on a trial instance it is the
    // operator's own account, which the operator never hands to anybody.
    const seen = await asUser(db, DEMO_OWNER, () => rows<{ id: string }>(db, `select id from companies`));
    expect(seen.map((one) => one.id)).toEqual(expect.arrayContaining([aliceCompany, bobCompany, aliceBooks, bobBooks]));
  });

  it('turns sharing off again, and creating a company is an instance-level act again', async () => {
    await db.query(`select unshare_instance()`);
    const carol = await newUser(db, 'carol2@example.test');
    expect(await asUser(db, carol, () => expectError(db, `select create_company('Carol', $1)`, [country]))).toMatch(/^not_instance_admin/);
  });

  it('lets an owner staff their company directly again once it is one customer’s', async () => {
    const colleague = await newUser(db, 'colleague@example.test');
    await db.query('begin');
    try {
      await asUser(db, bob, () =>
        db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'viewer')`, [bobBooks, colleague]),
      );
    } finally {
      await db.query('rollback');
    }
  });

  it('may leave the installation without an administrator once it is one customer’s again', async () => {
    await db.query('begin');
    try {
      await db.query(`delete from instance_admins`);
      expect((await one<{ x: boolean }>(db, `select instance_has_no_admin() as x`)).x).toBe(true);
    } finally {
      await db.query('rollback');
    }
  });
});
