/**
 * A company names the territory it is established in, and a pack can require
 * it.
 *
 * `companies.territory_code` decides which taxes that name a territory reach a
 * sale, and until `20261121070100` no route a person takes could write it.
 * These are the routes: `create_company()`, which the MCP tool and `ekwo
 * company new` call, the profile of the company, which is an update of the
 * row, and the refusals that guard both.
 *
 * No country is written here. The pack that requires a territory, the one
 * that does not, and the territories inside and outside each are read from
 * the database the packs were loaded into.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one } from './helpers/db.js';
import { newInstanceAdmin } from './helpers/factory.js';

let db: PGlite;
let adminId: string;
/** A country whose pack requires a territory, one inside it and one outside. */
let required: { country: string; inside: string; other: string; outside: string };
/** A country whose pack does not, and a territory inside it where there is one. */
let free: { country: string };

beforeAll(async () => {
  db = await freshDatabase();
  adminId = await newInstanceAdmin(db);
  const pack = await one<{ country: string }>(
    db,
    `select country from country_defaults where territory_required order by country limit 1`,
  );
  const inside = await db.query<{ code: string }>(
    `select code from territories where parent_code = $1 order by code limit 2`,
    [pack.country],
  );
  const outside = await one<{ code: string }>(
    db,
    `select code from territories
      where parent_code is not null and parent_code <> $1
      order by code limit 1`,
    [pack.country],
  );
  required = {
    country: pack.country,
    inside: inside.rows[0]!.code,
    other: inside.rows[1]!.code,
    outside: outside.code,
  };
  free = await one<{ country: string }>(
    db,
    `select country from country_defaults
      where not territory_required and fiscal_year_default is not null
      order by country limit 1`,
  );
});

afterAll(async () => {
  await db.close();
});

async function create(name: string, country: string, territory: string | null): Promise<{ id: string; territory_code: string | null }> {
  return asUser(db, adminId, () =>
    one<{ id: string; territory_code: string | null }>(
      db,
      `select id, territory_code from create_company($1, $2, p_territory_code => $3)`,
      [name, country, territory],
    ),
  );
}

async function companiesCount(): Promise<number> {
  return Number((await one<{ n: string }>(db, `select count(*)::text as n from companies`)).n);
}

describe('create_company and the territory', () => {
  it('writes the territory it is given', async () => {
    const company = await create('Inside Corp', required.country, required.inside.toLowerCase());
    expect(company.territory_code).toBe(required.inside);
  });

  it('refuses no territory where the pack requires one, and lists them', async () => {
    const before = await companiesCount();
    const message = await asUser(db, adminId, () =>
      expectError(db, `select * from create_company($1, $2)`, ['Nowhere Corp', required.country]),
    );
    expect(message).toMatch(/territory_required/);
    expect(message).toContain(required.inside);
    expect(await companiesCount()).toBe(before);
  });

  it('refuses a territory outside the country', async () => {
    const before = await companiesCount();
    const message = await asUser(db, adminId, () =>
      expectError(db, `select * from create_company($1, $2, p_territory_code => $3)`, [
        'Elsewhere Corp',
        required.country,
        required.outside,
      ]),
    );
    expect(message).toMatch(/territory_outside_country/);
    expect(await companiesCount()).toBe(before);
  });

  it('asks nothing of a pack that does not require one', async () => {
    const company = await create('Plain SRL', free.country, null);
    expect(company.territory_code).toBeNull();
  });

  it('keeps the arguments it had, by position', async () => {
    const company = await asUser(db, adminId, () =>
      one<{ territory_code: string | null }>(
        db,
        `select territory_code from create_company($1, $2, null, null, null, 2026, null)`,
        ['Positional SRL', free.country],
      ),
    );
    expect(company.territory_code).toBeNull();
  });
});

describe('the territory on the row', () => {
  it('moves to another territory of the country', async () => {
    const company = await create('Moving Corp', required.country, required.inside);
    await db.query(`update companies set territory_code = $2 where id = $1`, [company.id, required.other]);
    const after = await one<{ territory_code: string }>(
      db,
      `select territory_code from companies where id = $1`,
      [company.id],
    );
    expect(after.territory_code).toBe(required.other);
  });

  it('refuses a territory outside the country', async () => {
    const company = await create('Stray Corp', required.country, required.inside);
    const message = await expectError(db, `update companies set territory_code = $2 where id = $1`, [
      company.id,
      required.outside,
    ]);
    expect(message).toMatch(/territory_outside_country/);
  });

  it('refuses taking it back to none where the pack requires one', async () => {
    const company = await create('Rooted Corp', required.country, required.inside);
    const message = await expectError(db, `update companies set territory_code = null where id = $1`, [
      company.id,
    ]);
    expect(message).toMatch(/territory_required/);
  });

  it('is changed by the owner through the profile, under row level security', async () => {
    const company = await create('Owned Corp', required.country, required.inside);
    await asUser(db, adminId, () =>
      db.query(`update companies set territory_code = $2 where id = $1`, [company.id, required.other]),
    );
    const after = await one<{ territory_code: string }>(
      db,
      `select territory_code from companies where id = $1`,
      [company.id],
    );
    expect(after.territory_code).toBe(required.other);
  });
});
