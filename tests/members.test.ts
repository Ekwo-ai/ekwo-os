/**
 * A member leaves a company, or moves to another preset.
 *
 * Everything here runs as a signed-in user, like the invitations it follows:
 * the refusals — no `members.manage`, the last owner — are aimed at somebody
 * holding a session, and the audit trail records only what a person did.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newInstanceAdmin, newUser } from './helpers/factory.js';

let db: PGlite;
let companyId: string;
let ownerId: string;
let accountantId: string;
let viewerId: string;
let strangerId: string;

interface Member {
  user_id: string;
  role: string;
  capabilities_granted: string[];
  capabilities_revoked: string[];
}

async function join(userId: string, role: string, granted: string[] = [], revoked: string[] = []): Promise<void> {
  await db.query(
    `insert into company_members (company_id, user_id, role, capabilities_granted, capabilities_revoked)
     values ($1, $2, $3::member_role, $4::text[], $5::text[])
     on conflict (company_id, user_id) do update
       set role = excluded.role,
           capabilities_granted = excluded.capabilities_granted,
           capabilities_revoked = excluded.capabilities_revoked`,
    [companyId, userId, role, granted, revoked],
  );
}

async function roleOf(userId: string): Promise<string | null> {
  const found = await rows<{ role: string }>(
    db,
    `select role::text from company_members where company_id = $1 and user_id = $2`,
    [companyId, userId],
  );
  return found[0]?.role ?? null;
}

beforeAll(async () => {
  db = await freshDatabase();
  ({ companyId, ownerId } = await newCompany(db, { name: 'Members SRL' }));
  await db.query(`insert into auth.users (id, email) values ($1, $2) on conflict do nothing`, [
    ownerId,
    'owner@members.test',
  ]);
  accountantId = await newUser(db, 'accountant@members.test');
  viewerId = await newUser(db, 'viewer@members.test');
  strangerId = await newUser(db, 'stranger@members.test');
  await join(accountantId, 'accountant');
  await join(viewerId, 'viewer');
});

afterAll(async () => {
  await db.close();
});

describe('removing a member', () => {
  it('is done by an owner, and returns the row that left', async () => {
    const leaving = await newUser(db, 'leaving@members.test');
    await join(leaving, 'viewer');

    const removed = await asUser(db, ownerId, () =>
      one<Member>(db, `select user_id, role::text from remove_member($1, $2)`, [companyId, leaving]),
    );
    expect(removed.user_id).toBe(leaving);
    expect(removed.role).toBe('viewer');
    expect(await roleOf(leaving)).toBeNull();
  });

  it('needs members.manage, which an accountant does not have by preset', async () => {
    const message = await asUser(db, accountantId, () =>
      expectError(db, `select remove_member($1, $2)`, [companyId, viewerId]),
    );
    expect(message).toMatch(/not_allowed: removing somebody from this company needs members\.manage/);
    expect(await roleOf(viewerId)).toBe('viewer');

    const byStranger = await asUser(db, strangerId, () =>
      expectError(db, `select remove_member($1, $2)`, [companyId, viewerId]),
    );
    expect(byStranger).toMatch(/not_allowed/);
  });

  it('is open to an accountant granted members.manage', async () => {
    const leaving = await newUser(db, 'removed-by-accountant@members.test');
    await join(leaving, 'viewer');
    await join(accountantId, 'accountant', ['members.manage']);
    await asUser(db, accountantId, () => db.query(`select remove_member($1, $2)`, [companyId, leaving]));
    expect(await roleOf(leaving)).toBeNull();
    await join(accountantId, 'accountant');
  });

  it('lets a member leave by themself, without members.manage', async () => {
    const leaving = await newUser(db, 'self@members.test');
    await join(leaving, 'viewer');
    await asUser(db, leaving, () => db.query(`select remove_member($1, $2)`, [companyId, leaving]));
    expect(await roleOf(leaving)).toBeNull();
  });

  it('refuses somebody who is not a member', async () => {
    const message = await asUser(db, ownerId, () =>
      expectError(db, `select remove_member($1, $2)`, [companyId, strangerId]),
    );
    expect(message).toMatch(/unknown_member/);
  });

  it('refuses the last owner, even leaving by themself', async () => {
    const byThemself = await asUser(db, ownerId, () =>
      expectError(db, `select remove_member($1, $2)`, [companyId, ownerId]),
    );
    expect(byThemself).toMatch(/last_owner/);

    const byAnInstanceAdmin = await asUser(db, await newInstanceAdmin(db), () =>
      expectError(db, `select remove_member($1, $2)`, [companyId, ownerId]),
    );
    expect(byAnInstanceAdmin).toMatch(/last_owner/);
    expect(await roleOf(ownerId)).toBe('owner');
  });

  it('lets an owner go once there is another', async () => {
    const second = await newUser(db, 'second-owner@members.test');
    await join(second, 'owner');
    await asUser(db, ownerId, () => db.query(`select remove_member($1, $2)`, [companyId, second]));
    expect(await roleOf(second)).toBeNull();
    expect(await roleOf(ownerId)).toBe('owner');
  });
});

describe('changing the role of a member', () => {
  it('is done by an owner, and resets what was adjusted on the member', async () => {
    const moving = await newUser(db, 'moving@members.test');
    await join(moving, 'accountant', ['members.manage'], ['year_end.close']);

    const changed = await asUser(db, ownerId, () =>
      one<Member>(
        db,
        `select user_id, role::text, capabilities_granted, capabilities_revoked
           from set_member_role($1, $2, 'viewer')`,
        [companyId, moving],
      ),
    );
    expect(changed.role).toBe('viewer');
    expect(changed.capabilities_granted).toEqual([]);
    expect(changed.capabilities_revoked).toEqual([]);

    // The grant made for the accountant did not follow them to the new seat.
    const held = await asUser(db, moving, () =>
      rows<{ member_capabilities: string }>(db, `select member_capabilities($1)`, [companyId]),
    );
    expect(held.map((row) => row.member_capabilities)).not.toContain('members.manage');
  });

  it('writes the grants given with the new role, as an invitation would', async () => {
    const moving = await newUser(db, 'granted@members.test');
    await join(moving, 'viewer');
    const changed = await asUser(db, ownerId, () =>
      one<Member>(
        db,
        `select role::text, capabilities_granted from set_member_role($1, $2, 'client', '["documents.write"]'::jsonb)`,
        [companyId, moving],
      ),
    );
    expect(changed.role).toBe('client');
    expect(changed.capabilities_granted).toEqual(['documents.write']);
  });

  it('refuses a capability nobody declared, and a role outside a company', async () => {
    const unknown = await asUser(db, ownerId, () =>
      expectError(db, `select set_member_role($1, $2, 'viewer', '["books.burn"]'::jsonb)`, [
        companyId,
        viewerId,
      ]),
    );
    expect(unknown).toMatch(/unknown_capability: books\.burn/);

    const instance = await asUser(db, ownerId, () =>
      expectError(db, `select set_member_role($1, $2, 'instance_admin')`, [companyId, viewerId]),
    );
    expect(instance).toMatch(/bad_role/);
  });

  it('needs members.manage, for somebody else and for oneself', async () => {
    const other = await asUser(db, accountantId, () =>
      expectError(db, `select set_member_role($1, $2, 'owner')`, [companyId, viewerId]),
    );
    expect(other).toMatch(/not_allowed: changing the role of a member of this company needs members\.manage/);

    const self = await asUser(db, viewerId, () =>
      expectError(db, `select set_member_role($1, $2, 'owner')`, [companyId, viewerId]),
    );
    expect(self).toMatch(/not_allowed/);
    expect(await roleOf(viewerId)).toBe('viewer');
  });

  it('refuses to demote the last owner, and lets them go once a successor is promoted', async () => {
    const message = await asUser(db, ownerId, () =>
      expectError(db, `select set_member_role($1, $2, 'accountant')`, [companyId, ownerId]),
    );
    expect(message).toMatch(/last_owner/);
    expect(await roleOf(ownerId)).toBe('owner');

    const successor = await newUser(db, 'successor@members.test');
    await join(successor, 'accountant');
    await asUser(db, ownerId, () =>
      db.query(`select set_member_role($1, $2, 'owner')`, [companyId, successor]),
    );
    await asUser(db, successor, () =>
      db.query(`select set_member_role($1, $2, 'accountant')`, [companyId, ownerId]),
    );
    expect(await roleOf(ownerId)).toBe('accountant');
    expect(await roleOf(successor)).toBe('owner');

    // Back as it was, for the tests below.
    await asUser(db, successor, () =>
      db.query(`select set_member_role($1, $2, 'owner')`, [companyId, ownerId]),
    );
    await asUser(db, ownerId, () => db.query(`select remove_member($1, $2)`, [companyId, successor]));
  });
});

describe('what the audit trail says', () => {
  it('records a removal and a role change, with the caller as actor', async () => {
    const subject = await newUser(db, 'audited@members.test');
    await join(subject, 'viewer');
    await asUser(db, ownerId, () =>
      db.query(`select set_member_role($1, $2, 'accountant')`, [companyId, subject]),
    );
    await asUser(db, ownerId, () => db.query(`select remove_member($1, $2)`, [companyId, subject]));

    const trail = await rows<{
      operation: string;
      actor_id: string;
      old_role: string | null;
      new_role: string | null;
    }>(
      db,
      `select operation::text, actor_id, old_values ->> 'role' as old_role, new_values ->> 'role' as new_role
         from audit_log
        where company_id = $1 and table_name = 'company_members' and record_key = $2::text
        order by id`,
      [companyId, subject],
    );
    expect(trail).toEqual([
      { operation: 'update', actor_id: ownerId, old_role: 'viewer', new_role: 'accountant' },
      { operation: 'delete', actor_id: ownerId, old_role: 'accountant', new_role: null },
    ]);
  });
});

describe('listing the members of a company', () => {
  it('gives whoever manages members the address of each one', async () => {
    const listed = await asUser(db, ownerId, () =>
      rows<{ user_id: string; email: string | null; role: string }>(
        db,
        `select user_id, email, role::text from company_members_list($1)`,
        [companyId],
      ),
    );
    const byUser = new Map(listed.map((row) => [row.user_id, row]));
    expect(byUser.get(ownerId)?.email).toBe('owner@members.test');
    expect(byUser.get(accountantId)).toMatchObject({ email: 'accountant@members.test', role: 'accountant' });
    expect(byUser.get(viewerId)).toMatchObject({ email: 'viewer@members.test', role: 'viewer' });
    expect(byUser.has(strangerId)).toBe(false);
  });

  it('is refused to a member without members.manage, and to a stranger', async () => {
    const byViewer = await asUser(db, viewerId, () =>
      expectError(db, `select * from company_members_list($1)`, [companyId]),
    );
    expect(byViewer).toMatch(/not_allowed: listing the members of this company/);

    const byStranger = await asUser(db, strangerId, () =>
      expectError(db, `select * from company_members_list($1)`, [companyId]),
    );
    expect(byStranger).toMatch(/not_allowed/);
  });
});
