import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, rows } from './helpers/db.js';
import { newCompany, newInstanceAdmin, newUser } from './helpers/factory.js';

// The audit of 11 September 2026: what can someone who is not a member of any
// company reach? Two answers were wider than they should have been — every
// function was executable by `anon`, and every signed-in user could list the
// administrators. Migration 20260911210131 narrows both; this file keeps them
// narrow.

let db: PGlite;
let companyId: string;
let ownerId: string;
let adminId: string;
let strangerId: string;

beforeAll(async () => {
  db = await freshDatabase();
  ({ companyId, ownerId } = await newCompany(db));
  adminId = await newInstanceAdmin(db);
  strangerId = await newUser(db, 'stranger@example.com');
});

afterAll(async () => {
  await db.close();
});

describe('the anonymous role', () => {
  it('holds no privilege on a table at all, so a read is refused outright', async () => {
    const message = await asUser(
      db,
      strangerId,
      () => expectError(db, `select id from documents`),
      'anon',
    );
    expect(message).toMatch(/permission denied for table documents/);
  });

  it('cannot execute a report', async () => {
    const message = await asUser(
      db,
      strangerId,
      () =>
        expectError(db, `select * from trial_balance($1, date '2026-01-01', date '2026-12-31')`, [
          companyId,
        ]),
      'anon',
    );
    expect(message).toMatch(/permission denied for function trial_balance/);
  });

  it('cannot execute a posting function either', async () => {
    const message = await asUser(
      db,
      strangerId,
      () => expectError(db, `select post_document($1)`, [companyId]),
      'anon',
    );
    expect(message).toMatch(/permission denied for function post_document/);
  });

  it('has execute on nothing but the policy helpers', async () => {
    const callable = await rows<{ proname: string }>(
      db,
      `select p.proname
         from pg_proc p join pg_namespace n on n.oid = p.pronamespace
        where n.nspname = 'public' and p.prokind = 'f'
          and has_function_privilege('anon', p.oid, 'execute')
        order by 1`,
    );
    // Eight since 20260911210131, and one more for each question a policy
    // learned to ask since. `has_capability` is what every policy of the core
    // now calls, and `module_enabled` is what a module's policies call — the
    // latter answering "this module is on for this company **and** you are a
    // member of it", so what it gives an anonymous request away is the same
    // word `is_company_member` already does. Both answer about `auth.uid()`,
    // which is null for `anon`. Without the grants, an anonymous select would
    // raise "permission denied for function" instead of returning nothing.
    //
    // `shared_document` is of a different kind: it does not answer about the
    // caller, it *is* the public door of `20260915153000`. What it gives away
    // is bounded by the token presented to it — one document, or the same null
    // for every token that is not a live link — and it reaches no table on the
    // caller's behalf. An entry here is a decision about what an anonymous
    // visitor may reach, not a detail of a migration.
    //
    // Five arrived with `20260922160000`, which let a machine key reach the
    // API, and each is a door or the hinge of one.
    //
    // `ekwo_pre_request` is the door: PostgREST calls it as `anon` at the
    // start of every request, so `anon` has to be able to execute it or no
    // request works at all. It answers void, and does nothing whatsoever
    // without the header.
    //
    // `present_api_key` is what it calls. `use_api_key()` was not granted and
    // is not granted now: it returns the row, `key_hash` included, and
    // whatever the pre-request may call, an anonymous caller may call. This
    // returns void. What an anonymous caller can learn from it is whether a
    // secret they already hold is a live key of this installation — which is
    // what presenting a bearer credential means, and the answer to a secret
    // they do not hold is the refusal every wrong key gets.
    //
    // `api_key_company` and `is_known_caller` are hinges: `is_company_member`
    // and the policies of the reference tables call them, and `anon` already
    // executes those on behalf of a policy. Both answer about the key
    // presented in this transaction, which for `anon` without a header is
    // nothing — the same word `auth.uid()` gives it.
    //
    // `installed_schema_version` is granted and answers `anon` with zero rows
    // (`20260922161500`): the grant is for the screen that checks a pasted key
    // before presenting it, and an anonymous call learns nothing.
    expect(callable.map((r) => r.proname)).toEqual([
      'api_key_company',
      'can_write_company',
      'company_has_no_member',
      'company_role',
      'ekwo_pre_request',
      'has_capability',
      'installed_schema_version',
      'instance_has_no_admin',
      'is_any_company_member',
      'is_company_member',
      'is_company_owner',
      'is_instance_admin',
      'is_known_caller',
      'module_enabled',
      'present_api_key',
      'shared_document',
    ]);
  });

  it('is not handed a function through PUBLIC by a migration that forgot', async () => {
    // A function created without an explicit revoke comes out executable by
    // PUBLIC — `anon` included — and `alter default privileges … revoke
    // execute on functions from public` does *not* prevent it: PostgreSQL
    // merges the stored default with the built-in one, so the new function
    // still carries `=X`. Migration 20260911210131 believed otherwise and
    // 20260912074712 found out, with `install_country_template` published as
    // an anonymous RPC endpoint for the length of one commit.
    //
    // A null `proacl` is the same failure wearing the built-in default.
    // Every migration that adds a function ends with
    // `revoke execute on all functions in schema public from public;` —
    // from PUBLIC, never from `anon`, which holds the grants above.
    const open = await rows<{ proname: string }>(
      db,
      `select p.proname
         from pg_proc p join pg_namespace n on n.oid = p.pronamespace
        where n.nspname = 'public' and p.prokind = 'f'
          and (p.proacl is null
               or exists (select 1 from aclexplode(p.proacl) a
                           where a.grantee = 0 and a.privilege_type = 'EXECUTE'))
        order by 1`,
    );
    expect(
      open.map((r) => r.proname),
      'these functions are executable by PUBLIC: add the revoke to the migration that created them',
    ).toEqual([]);
  });
});

describe('a signed-in stranger', () => {
  it('does not see who administers the installation', async () => {
    const seen = await asUser(db, strangerId, () => rows(db, `select user_id from instance_admins`));
    expect(seen).toEqual([]);
  });

  it('can still not read a company', async () => {
    const seen = await asUser(db, strangerId, () => rows(db, `select id from companies`));
    expect(seen).toEqual([]);
  });
});

describe('a member and an administrator', () => {
  it('see the administrators', async () => {
    // The demo seed installs an administrator of its own, so the list has two.
    const byMember = await asUser(db, ownerId, () => rows(db, `select user_id from instance_admins`));
    expect(byMember.map((r) => r['user_id'])).toContain(adminId);
    const byAdmin = await asUser(db, adminId, () => rows(db, `select user_id from instance_admins`));
    expect(byAdmin.map((r) => r['user_id']).sort()).toEqual(byMember.map((r) => r['user_id']).sort());
  });

  it('can run a report as a signed-in member', async () => {
    const balance = await asUser(db, ownerId, () =>
      rows(db, `select * from trial_balance($1, date '2026-01-01', date '2026-12-31')`, [companyId]),
    );
    expect(Array.isArray(balance)).toBe(true);
  });
});

// ---------------------------------------------------------------------------
// The audit of 13 September 2026: a guard that answers NULL never fires.
//
// `company_role()` is NULL for a stranger, and two helpers were built on it
// with a bare comparison, so they were NULL too. `if not <that>(…) then raise`
// does not branch on NULL: the stranger walked into the body of a SECURITY
// DEFINER function. Migration 20260913101536 makes both answer `false`, and
// this is the rule that keeps the shape safe for whoever writes the next one.
// ---------------------------------------------------------------------------

describe('a boolean helper a guard is written on', () => {
  it('answers false, not NULL, for somebody who is a member of nothing', async () => {
    await asUser(db, strangerId, async () => {
      const answers = await rows<Record<string, boolean | null>>(
        db,
        `select is_company_owner($1)  as owner,
                can_write_company($1) as writer,
                is_company_member($1) as member,
                has_capability($1, 'company.write') as capable,
                is_installer() as installer`,
        [companyId],
      );
      expect(answers[0]).toEqual({
        owner: false,
        writer: false,
        member: false,
        capable: false,
        installer: false,
      });
    });
  });

  it('is never tested by a function body in a way NULL would slip through', async () => {
    // Derived by calling them, not by reading them: every public function
    // that answers a boolean about a company — no argument, one company, or a
    // company and a name — is asked as a stranger, and none may answer NULL.
    // While that holds, the shape `if not <helper>(…) then raise` is safe
    // wherever somebody writes it, which is the property this file defends.
    const helpers = await rows<{ proname: string; args: string }>(
      db,
      `select p.proname,
              array_to_string(array(select format_type(t, null)
                                      from unnest(p.proargtypes) t), ', ') as args
         from pg_proc p join pg_namespace n on n.oid = p.pronamespace
        where n.nspname = 'public'
          and p.prorettype = 'boolean'::regtype
          and array_to_string(array(select format_type(t, null)
                                      from unnest(p.proargtypes) t), ', ')
              in ('', 'uuid', 'uuid, text')
        order by 1`,
    );
    expect(helpers.length).toBeGreaterThan(8);

    const nullable: string[] = [];
    await asUser(db, strangerId, async () => {
      for (const helper of helpers) {
        const call =
          helper.args === ''
            ? `${helper.proname}()`
            : helper.args === 'uuid'
              ? `${helper.proname}($1)`
              : `${helper.proname}($1, 'budgets')`;
        const answer = await rows<{ answer: boolean | null }>(
          db,
          `select ${call} as answer`,
          helper.args === '' ? [] : [companyId],
        );
        if (answer[0]?.answer === null) nullable.push(`${helper.proname}(${helper.args})`);
      }
    });
    expect(nullable, 'these helpers answer NULL for a stranger').toEqual([]);
  });
});
