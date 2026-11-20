/**
 * The territory of a company through the server: `create_company` names it,
 * and `update_company_profile` moves it. The refusals are the database's,
 * read back in its words. No country is written here: the pack that requires
 * a territory is found by what its row says.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { writeTools, type Backend } from '../../packages/mcp/src/index.js';
import { freshDatabase, one } from '../helpers/db.js';
import { newInstanceAdmin } from '../helpers/factory.js';
import { backendFor, record } from './helpers.js';

let db: PGlite;
let asAdmin: Backend;
let country: string;
let inside: string[];

beforeAll(async () => {
  db = await freshDatabase();
  asAdmin = backendFor(db, await newInstanceAdmin(db));
  ({ country } = await one<{ country: string }>(
    db,
    'select country from country_defaults where territory_required order by country limit 1',
  ));
  const rows = await db.query<{ code: string }>(
    'select code from territories where parent_code = $1 order by code limit 2',
    [country],
  );
  inside = rows.rows.map((row) => row.code);
});

afterAll(async () => {
  await db.close();
});

describe('the territory of a company through the server', () => {
  it('is refused when the pack requires one and none is named', async () => {
    await expect(writeTools.createCompany(asAdmin, { name: 'Unrooted Inc.', country })).rejects.toThrow(
      /territory_required/,
    );
  });

  it('is written by create_company and moved by update_company_profile', async () => {
    const created = record(
      await writeTools.createCompany(asAdmin, { name: 'Rooted Inc.', country, territory: inside[0]!.toLowerCase() }),
    );
    const company = record(created['company']);
    expect(company['territory_code']).toBe(inside[0]);

    const moved = record(
      await writeTools.updateCompanyProfile(asAdmin, {
        company_id: company['id'] as string,
        territory_code: inside[1]!,
      }),
    );
    expect(record(moved['company'])['territory_code']).toBe(inside[1]);

    await expect(
      writeTools.updateCompanyProfile(asAdmin, { company_id: company['id'] as string, territory_code: null }),
    ).rejects.toThrow(/territory_required/);
  });
});
