/**
 * The territory of a contact through the server: `create_contact` names it,
 * and `set_contact_territory` moves it or takes it back.
 *
 * `contacts.territory_code` is read before the country when a tax names a
 * territory, and until `20261126071412` no route a person takes wrote it, nor
 * held it within the contact's country. The refusals are the database's, read
 * back in its words, and row level security decides who may change a contact.
 *
 * No country is written here: a country with territories inside it, two of
 * them and one outside it are read from the database the packs were loaded
 * into.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { writeTools, type Backend } from '../../packages/mcp/src/index.js';
import { freshDatabase, one } from '../helpers/db.js';
import { newCompany, type Fixture } from '../helpers/factory.js';
import { backendFor, record } from './helpers.js';

let db: PGlite;
let fx: Fixture;
let owner: Backend;
let viewer: Backend;
/** A country with territories inside it, two of them, and one outside it. */
let place: { country: string; inside: string; other: string; outside: string; elsewhere: string };

beforeAll(async () => {
  db = await freshDatabase();
  const { country } = await one<{ country: string }>(
    db,
    `select t.parent_code as country
       from territories t
       join country_defaults d on d.country = t.parent_code
      group by t.parent_code
     having count(*) >= 2
      order by t.parent_code limit 1`,
  );
  const inside = await db.query<{ code: string }>(
    'select code from territories where parent_code = $1 order by code limit 2',
    [country],
  );
  const outside = await one<{ code: string; parent_code: string }>(
    db,
    `select code, parent_code from territories
      where parent_code is not null and parent_code <> $1
        and parent_code in (select country from country_defaults)
      order by code limit 1`,
    [country],
  );
  place = {
    country,
    inside: inside.rows[0]!.code,
    other: inside.rows[1]!.code,
    outside: outside.code,
    elsewhere: outside.parent_code,
  };
  fx = await newCompany(db, { country, name: 'Territories Example' });
  const viewerId = crypto.randomUUID();
  await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'viewer')`, [fx.companyId, viewerId]);
  owner = backendFor(db, fx.ownerId);
  viewer = backendFor(db, viewerId);
}, 180_000);

afterAll(async () => {
  await db.close();
});

async function territoryOf(contactId: string): Promise<string | null> {
  return (await one<{ territory_code: string | null }>(db, 'select territory_code from contacts where id = $1', [contactId]))
    .territory_code;
}

describe('the territory of a contact through the server', () => {
  it('is written by create_contact, in capitals, and read back with the contact', async () => {
    const created = record(
      await writeTools.createContact(owner, {
        company_id: fx.companyId,
        name: 'Example Customer',
        contact_type: 'customer',
        country: place.country,
        territory_code: place.inside.toLowerCase(),
      }),
    );
    const contact = record(created['contact']);
    expect(contact['territory_code']).toBe(place.inside);
    expect(await territoryOf(contact['id'] as string)).toBe(place.inside);
  });

  it('is moved and taken back by set_contact_territory, the country unchanged', async () => {
    const created = record(
      await writeTools.createContact(owner, { company_id: fx.companyId, name: 'Example Supplier', contact_type: 'supplier', country: place.country }),
    );
    const id = record(created['contact'])['id'] as string;
    expect(record(created['contact'])['territory_code']).toBeNull();

    const moved = record(await writeTools.setContactTerritory(owner, { company_id: fx.companyId, contact_id: id, territory_code: place.other }));
    expect(record(moved['contact'])).toMatchObject({ territory_code: place.other, country: place.country });

    const cleared = record(await writeTools.setContactTerritory(owner, { company_id: fx.companyId, contact_id: id, territory_code: null }));
    expect(record(cleared['contact'])).toMatchObject({ territory_code: null, country: place.country });
  });

  it('refuses a territory outside the contact\'s country, at creation and afterwards', async () => {
    await expect(
      writeTools.createContact(owner, {
        company_id: fx.companyId,
        name: 'Misplaced Example',
        contact_type: 'customer',
        country: place.country,
        territory_code: place.outside,
      }),
    ).rejects.toThrow(/territory_outside_country/);

    const created = record(
      await writeTools.createContact(owner, { company_id: fx.companyId, name: 'Placed Example', contact_type: 'customer', country: place.country, territory_code: place.inside }),
    );
    const id = record(created['contact'])['id'] as string;
    await expect(
      writeTools.setContactTerritory(owner, { company_id: fx.companyId, contact_id: id, territory_code: place.outside }),
    ).rejects.toThrow(/territory_outside_country/);
    expect(await territoryOf(id)).toBe(place.inside);

    // Moving the contact to another country while it still names a territory
    // of the first is the same contradiction, from the other column.
    await expect(db.query('update contacts set country = $2 where id = $1', [id, place.elsewhere])).rejects.toThrow(
      /territory_outside_country/,
    );
  });

  it('holds a contact with no country to none', async () => {
    const created = record(
      await writeTools.createContact(owner, { company_id: fx.companyId, name: 'Countryless Example', contact_type: 'customer', territory_code: place.outside }),
    );
    expect(record(created['contact'])).toMatchObject({ country: null, territory_code: place.outside });
  });

  it('is refused to a member who may not change contacts', async () => {
    const created = record(
      await writeTools.createContact(owner, { company_id: fx.companyId, name: 'Guarded Example', contact_type: 'customer', country: place.country }),
    );
    const id = record(created['contact'])['id'] as string;
    await expect(
      writeTools.setContactTerritory(viewer, { company_id: fx.companyId, contact_id: id, territory_code: place.inside }),
    ).rejects.toThrow(/not_found/);
    expect(await territoryOf(id)).toBeNull();
  });
});
