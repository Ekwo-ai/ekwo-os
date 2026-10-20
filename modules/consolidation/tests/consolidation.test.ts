import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from '../../../tests/helpers/db.js';
import { newCompany } from '../../../tests/helpers/factory.js';

// `consolidation` keeps groups of companies: a group belongs to its parent,
// and names the other companies of the installation it holds, each for a
// period, by a method and at a percentage of interest. It reads the members'
// books as the caller and writes nothing in them.

let db: PGlite;
let ownerId: string;
let parentId: string;
let subsidiaryId: string;
let ventureId: string;
let associateId: string;
let strangerCompanyId: string;
let strangerId: string;
let groupId: string;

interface Member {
  id: string;
  method: string;
  ownership_rate: string;
  integration_rate: string;
  entered_on: string;
  left_on: string | null;
}

interface PerimeterRow {
  company_id: string;
  company_name: string | null;
  is_parent: boolean;
  method: string;
  ownership_rate: string;
  integration_rate: string;
  readable: boolean;
}

const perimeter = (on: string): Promise<PerimeterRow[]> =>
  rows<PerimeterRow>(db, `select * from consolidation.perimeter($1, $2, $3::date)`, [parentId, groupId, on]);

beforeAll(async () => {
  db = await freshDatabase();
  ({ companyId: parentId, ownerId } = await newCompany(db, { country: 'BE', name: 'Holding SA' }));
  ({ companyId: subsidiaryId } = await newCompany(db, { country: 'BE', name: 'Filiale SRL', ownerId }));
  ({ companyId: ventureId } = await newCompany(db, { country: 'BE', name: 'Coentreprise SRL', ownerId }));
  ({ companyId: associateId } = await newCompany(db, { country: 'BE', name: 'Associee SRL', ownerId }));
  ({ companyId: strangerCompanyId, ownerId: strangerId } = await newCompany(db, {
    country: 'BE',
    name: 'Elsewhere SRL',
  }));

  await asUser(db, ownerId, async () => {
    await db.query(`select enable_module($1, 'consolidation')`, [parentId]);
  });
});

afterAll(async () => {
  await db.close();
});

describe('a group', () => {
  it('is created in the parent’s currency when none is given, and found again by its code', async () => {
    await asUser(db, ownerId, async () => {
      const created = await one<{ id: string; currency_code: string; name: string }>(
        db,
        `select * from consolidation.create_group($1, 'main', 'Main group')`,
        [parentId],
      );
      const parent = await one<{ currency_code: string }>(db, `select currency_code from companies where id = $1`, [
        parentId,
      ]);
      expect(created.currency_code).toBe(parent.currency_code);
      groupId = created.id;

      const again = await one<{ id: string; name: string }>(
        db,
        `select * from consolidation.create_group($1, 'main', 'Another name')`,
        [parentId],
      );
      expect(again).toMatchObject({ id: groupId, name: 'Main group' });
    });
  });

  it('is refused on a company that has not enabled the module, by name', async () => {
    await asUser(db, ownerId, async () => {
      const refused = await expectError(db, `select consolidation.create_group($1, 'main', 'Main group')`, [
        subsidiaryId,
      ]);
      expect(refused).toMatch(/^consolidation_module_not_enabled:/);
    });
  });
});

describe('a member', () => {
  it('takes the share its method gives: all of it, its interest, or none line by line', async () => {
    await asUser(db, ownerId, async () => {
      const add = (company: string, method: string, rate: number): Promise<Member> =>
        one<Member>(db, `select * from consolidation.add_member($1, $2, $3, $4, $5, date '2026-01-01')`, [
          parentId,
          groupId,
          company,
          method,
          rate,
        ]);
      expect(await add(subsidiaryId, 'full', 80)).toMatchObject({ ownership_rate: '80.0000', integration_rate: '100.0000' });
      expect(await add(ventureId, 'proportional', 50)).toMatchObject({ integration_rate: '50.0000' });
      expect(await add(associateId, 'equity', 30)).toMatchObject({ integration_rate: '0.0000' });
    });
  });

  it('is the same row when the same call comes twice, and refused when the terms differ', async () => {
    await asUser(db, ownerId, async () => {
      const first = await one<Member>(
        db,
        `select * from consolidation.members where member_company_id = $1`,
        [subsidiaryId],
      );
      const again = await one<Member>(
        db,
        `select * from consolidation.add_member($1, $2, $3, 'full', 80, date '2026-01-01')`,
        [parentId, groupId, subsidiaryId],
      );
      expect(again.id).toBe(first.id);

      const refused = await expectError(
        db,
        `select consolidation.add_member($1, $2, $3, 'full', 90, date '2026-01-01')`,
        [parentId, groupId, subsidiaryId],
      );
      expect(refused).toMatch(/^consolidation_member_exists:/);
    });
  });

  it('cannot be the parent, which is always in at 100 %', async () => {
    await asUser(db, ownerId, async () => {
      const refused = await expectError(
        db,
        `select consolidation.add_member($1, $2, $1, 'full', 100, date '2026-01-01')`,
        [parentId, groupId],
      );
      expect(refused).toMatch(/^consolidation_member_is_the_parent:/);
    });
  });

  it('holds an interest above 0 and up to 100, and an integration rate nobody types', async () => {
    await asUser(db, ownerId, async () => {
      // A closed period of 2025, before the one that is open: only the rate is wrong.
      for (const rate of [0, 120]) {
        expect(
          await expectError(
            db,
            `select consolidation.add_member($1, $2, $3, 'full', $4, date '2025-01-01', date '2025-06-30')`,
            [parentId, groupId, subsidiaryId, rate],
          ),
        ).toMatch(/consolidation_members_ownership/);
      }
      expect(
        await expectError(db, `update consolidation.members set integration_rate = 10 where member_company_id = $1`, [
          ventureId,
        ]),
      ).toMatch(/integration_rate/);
    });
  });
});

describe('a period', () => {
  it('never overlaps another of the same company in the same group', async () => {
    await asUser(db, ownerId, async () => {
      const refused = await expectError(
        db,
        `select consolidation.add_member($1, $2, $3, 'full', 100, date '2026-07-01')`,
        [parentId, groupId, subsidiaryId],
      );
      expect(refused).toMatch(/^consolidation_member_overlap:/);
    });
  });

  it('closes, and the next opens the day after: each date keeps the terms it had', async () => {
    await asUser(db, ownerId, async () => {
      const current = await one<{ id: string }>(
        db,
        `select id from consolidation.members where member_company_id = $1`,
        [subsidiaryId],
      );
      const closed = await one<Member>(db, `select * from consolidation.end_membership($1, $2, date '2026-06-30')`, [
        parentId,
        current.id,
      ]);
      expect(closed.left_on).not.toBeNull();
      await db.query(`select consolidation.add_member($1, $2, $3, 'full', 100, date '2026-07-01')`, [
        parentId,
        groupId,
        subsidiaryId,
      ]);

      const march = await perimeter('2026-03-31');
      const december = await perimeter('2026-12-31');
      expect(march.find((r) => r.company_id === subsidiaryId)?.ownership_rate).toBe('80.0000');
      expect(december.find((r) => r.company_id === subsidiaryId)?.ownership_rate).toBe('100.0000');
    });
  });

  it('gives the perimeter of a date: the parent first, then whoever is in on that day', async () => {
    await asUser(db, ownerId, async () => {
      const december = await perimeter('2026-12-31');
      expect(december[0]).toMatchObject({ company_id: parentId, is_parent: true, integration_rate: '100', readable: true });
      expect(december.map((r) => r.company_id).sort()).toEqual(
        [parentId, subsidiaryId, ventureId, associateId].sort(),
      );
      expect(await perimeter('2025-12-31')).toEqual([expect.objectContaining({ company_id: parentId })]);
    });
  });
});

describe('the books of a member', () => {
  it('are out of reach of whoever cannot read them: a company of somebody else is refused', async () => {
    await asUser(db, ownerId, async () => {
      const refused = await expectError(
        db,
        `select consolidation.add_member($1, $2, $3, 'full', 100, date '2026-01-01')`,
        [parentId, groupId, strangerCompanyId],
      );
      expect(refused).toMatch(/^consolidation_member_unreadable:/);

      // The table itself holds the same rule: the trigger, not the function.
      const direct = await expectError(
        db,
        `insert into consolidation.members (group_id, company_id, member_company_id, method, ownership_rate, entered_on)
         values ($1, $2, $3, 'full', 100, date '2026-01-01')`,
        [groupId, parentId, strangerCompanyId],
      );
      expect(direct).toMatch(/^consolidation_member_unreadable:/);
    });
  });

  it('are read as the caller: a member the reader cannot read is shown as such, and refused by name', async () => {
    const reader = crypto.randomUUID();
    await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'accountant')`, [
      parentId,
      reader,
    ]);
    await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'viewer')`, [
      subsidiaryId,
      reader,
    ]);

    await asUser(db, reader, async () => {
      const seen = await perimeter('2026-12-31');
      expect(seen.find((r) => r.company_id === subsidiaryId)).toMatchObject({ readable: true });
      expect(seen.find((r) => r.company_id === ventureId)).toMatchObject({ readable: false, company_name: null });

      const refused = await expectError(
        db,
        `select consolidation.require_readable($1, $2, date '2026-01-01', date '2026-12-31')`,
        [parentId, groupId],
      );
      expect(refused).toMatch(/^consolidation_member_unreadable:/);
      // The first member it cannot read, whichever of the two it is.
      expect([ventureId, associateId].some((id) => refused.includes(id))).toBe(true);
      expect(refused).not.toContain(subsidiaryId);
    });

    for (const company of [ventureId, associateId]) {
      await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'viewer')`, [
        company,
        reader,
      ]);
    }
    await asUser(db, reader, async () => {
      await db.query(`select consolidation.require_readable($1, $2, date '2026-01-01', date '2026-12-31')`, [
        parentId,
        groupId,
      ]);
      expect((await perimeter('2026-12-31')).every((r) => r.readable)).toBe(true);
    });
  });
});

describe('who may do what', () => {
  it('lets a viewer of the parent read the group and change nothing', async () => {
    const viewer = crypto.randomUUID();
    await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'viewer')`, [
      parentId,
      viewer,
    ]);
    await asUser(db, viewer, async () => {
      expect(await rows(db, `select id from consolidation.groups`)).toHaveLength(1);
      const refused = await expectError(db, `select consolidation.create_group($1, 'second', 'Second group')`, [
        parentId,
      ]);
      expect(refused).toMatch(/^consolidation_not_allowed:/);
      const current = await one<{ id: string }>(
        db,
        `select id from consolidation.members where member_company_id = $1 and left_on is null`,
        [ventureId],
      );
      expect(
        await expectError(db, `select consolidation.end_membership($1, $2, date '2026-12-31')`, [parentId, current.id]),
      ).toMatch(/^consolidation_not_allowed:/);
    });
  });

  it('shows the owner of another company none of it', async () => {
    await asUser(db, strangerId, async () => {
      expect(await rows(db, `select id from consolidation.groups`)).toEqual([]);
      expect(await rows(db, `select id from consolidation.members`)).toEqual([]);
      expect(await expectError(db, `select * from consolidation.perimeter($1, $2)`, [parentId, groupId])).toMatch(
        /^consolidation_module_not_enabled:/,
      );
    });
  });

  it('writes nothing in a member company', async () => {
    const touched = await rows(
      db,
      `select 1 from entries where company_id = any($1::uuid[])
       union all
       select 1 from documents where company_id = any($1::uuid[])`,
      [[subsidiaryId, ventureId, associateId]],
    );
    expect(touched).toEqual([]);
  });
});
