import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from '../../../tests/helpers/db.js';
import { newCompany } from '../../../tests/helpers/factory.js';
import { somePack } from '../../../tests/helpers/packs.js';

// Cards build themselves from e-mail: an activity named by an address finds
// or creates its contact, then the organisation of its domain — never one for
// a generic domain — and a card's first and last interaction are computed from
// its activities whenever they are read.

const HOME = somePack.manifest.country;

let db: PGlite;
let companyId: string;
let ownerId: string;

interface Resolved {
  contact_id: string;
  organisation_id: string | null;
  address: string;
  domain: string;
  generic_domain: boolean;
  contact_created: boolean;
  organisation_created: boolean;
  replayed?: boolean;
  activity?: { id: string; contact_id: string; kind: string; source: string | null; source_ref: string | null };
}

const asOwner = <T>(fn: () => Promise<T>) => asUser(db, ownerId, fn);

function byEmail(
  email: string,
  options: { kind?: string; at?: string; ref?: string; name?: string; company?: string } = {},
): Promise<Resolved> {
  return asOwner(async () =>
    (
      await one<{ r: Resolved }>(
        db,
        `select crm.log_activity_by_email($1, $2, $3::crm.activity_kind, 'Hello', null, null, 'mailbox-agent',
                                          $4::timestamptz, null, null, $5, $6, $7) as r`,
        [
          options.company ?? companyId,
          email,
          options.kind ?? 'email_in',
          options.at ?? null,
          options.ref === undefined ? null : 'mailbox',
          options.ref ?? null,
          options.name ?? null,
        ],
      )
    ).r,
  );
}

const contactRow = (id: string) =>
  one<{ name: string; email: string | null; is_company: boolean; parent_id: string | null; contact_type: string }>(
    db,
    `select name, email, is_company, parent_id, contact_type::text from contacts where id = $1`,
    [id],
  );

const card = (contact: string) =>
  asOwner(async () => (await one<{ c: { card: Record<string, unknown> | null } }>(db, `select crm.card_of($1, $2) as c`, [companyId, contact])).c.card);

beforeAll(async () => {
  db = await freshDatabase();
  ({ companyId, ownerId } = await newCompany(db, { country: HOME, name: 'Mailbox SRL' }));
  await asOwner(() => db.query(`select enable_module($1, 'crm')`, [companyId]));
});

afterAll(async () => {
  await db.close();
});

describe('an activity named by an address', () => {
  it('creates the contact, the organisation of its domain, and a card for each', async () => {
    const r = await byEmail('Grace Hopper <Grace@Harbour-Logistics.example>', { name: 'Grace Hopper', ref: '<m1@x>' });

    expect(r).toMatchObject({
      address: 'grace@harbour-logistics.example',
      domain: 'harbour-logistics.example',
      generic_domain: false,
      contact_created: true,
      organisation_created: true,
      replayed: false,
    });
    expect(await contactRow(r.contact_id)).toEqual({
      name: 'Grace Hopper',
      email: 'grace@harbour-logistics.example',
      is_company: false,
      parent_id: r.organisation_id,
      contact_type: 'other',
    });
    expect(await contactRow(r.organisation_id!)).toMatchObject({
      name: 'harbour-logistics.example',
      is_company: true,
      parent_id: null,
      contact_type: 'other',
    });
    expect(r.activity).toMatchObject({ contact_id: r.contact_id, kind: 'email_in', source: 'mailbox', source_ref: '<m1@x>' });
    const cards = await rows<{ contact_id: string; source: string }>(
      db,
      `select contact_id, source from crm.cards where company_id = $1 and contact_id = any($2::uuid[]) order by contact_id`,
      [companyId, [r.contact_id, r.organisation_id]],
    );
    expect(cards).toHaveLength(2);
    expect(cards.every((c) => c.source === 'mailbox')).toBe(true);
  });

  it('finds the contact already on file at that address, whatever its case', async () => {
    const first = await byEmail('linus@harbour-logistics.example');
    const again = await byEmail('LINUS@harbour-logistics.example', { kind: 'email_out' });
    expect(again.contact_id).toBe(first.contact_id);
    expect(again.contact_created).toBe(false);
  });

  it('groups the people of one domain under one organisation', async () => {
    const grace = await byEmail('grace@harbour-logistics.example');
    const ada = await byEmail('ada@harbour-logistics.example');
    expect(ada.organisation_id).toBe(grace.organisation_id);
    expect(ada.organisation_created).toBe(false);
    const named = await rows(db, `select id from contacts where company_id = $1 and name = 'harbour-logistics.example'`, [companyId]);
    expect(named).toHaveLength(1);
  });

  it('takes the organisation whose own address is at the domain, and gives a person on file without one that organisation', async () => {
    const { org, person } = await asOwner(async () => {
      const org = (
        await one<{ id: string }>(
          db,
          `insert into contacts (company_id, name, is_company, contact_type, email)
           values ($1, 'Fjord Shipping', true, 'other', 'info@fjord-shipping.example') returning id`,
          [companyId],
        )
      ).id;
      const person = (
        await one<{ id: string }>(
          db,
          `insert into contacts (company_id, name, is_company, contact_type, email)
           values ($1, 'Karin Berg', false, 'other', 'karin@fjord-shipping.example') returning id`,
          [companyId],
        )
      ).id;
      return { org, person };
    });

    const karin = await byEmail('karin@fjord-shipping.example');
    expect(karin).toMatchObject({ contact_id: person, organisation_id: org, contact_created: false, organisation_created: false });
    expect((await contactRow(person)).parent_id).toBe(org);

    const info = await byEmail('info@fjord-shipping.example');
    expect(info).toMatchObject({ contact_id: org, organisation_id: org, contact_created: false });
  });

  it('refuses a text that holds no address, by name', async () => {
    const refused = await asOwner(() =>
      expectError(db, `select crm.log_activity_by_email($1, 'nobody at all', 'email_in')`, [companyId]),
    );
    expect(refused).toMatch(/^crm_bad_email: /);
  });

  it('refuses to create a contact for a member who may not write contacts', async () => {
    const reader = crypto.randomUUID();
    await db.query(
      `insert into company_members (company_id, user_id, role, capabilities_revoked)
       values ($1, $2, 'owner', array['contacts.write'])`,
      [companyId, reader],
    );
    const refused = await asUser(db, reader, () =>
      expectError(db, `select crm.log_activity_by_email($1, 'new@unknown-firm.example', 'email_in')`, [companyId]),
    );
    expect(refused).toMatch(/^crm_not_allowed: creating the contact of new@unknown-firm\.example needs contacts\.write/);
  });
});

describe('a generic domain', () => {
  it('never becomes an organisation', async () => {
    const before = await one<{ n: number }>(db, `select count(*)::int as n from contacts where company_id = $1 and is_company`, [companyId]);
    const r = await byEmail('jane.doe@gmail.com', { name: 'Jane Doe' });
    expect(r).toMatchObject({ generic_domain: true, contact_created: true, organisation_created: false, organisation_id: null });
    expect((await contactRow(r.contact_id)).parent_id).toBeNull();
    const after = await one<{ n: number }>(db, `select count(*)::int as n from contacts where company_id = $1 and is_company`, [companyId]);
    expect(after.n).toBe(before.n);
  });

  it('covers its sub-domains', async () => {
    const r = await byEmail('someone@tenant.onmicrosoft.com');
    expect(r).toMatchObject({ generic_domain: true, organisation_id: null, organisation_created: false });
  });

  it('is data: a company adds its own, which another company does not see', async () => {
    const other = await newCompany(db, { country: HOME, name: 'Other SRL' });
    await asUser(db, other.ownerId, () => db.query(`select enable_module($1, 'crm')`, [other.companyId]));
    await asOwner(() =>
      db.query(`insert into crm.generic_email_domains (company_id, domain, kind) values ($1, 'coworking.example', 'provider')`, [
        companyId,
      ]),
    );

    const here = await byEmail('desk-12@coworking.example');
    expect(here).toMatchObject({ generic_domain: true, organisation_created: false });

    const there = await asUser(db, other.ownerId, async () =>
      (await one<{ r: Resolved }>(db, `select crm.contact_from_email($1, 'desk-12@coworking.example') as r`, [other.companyId])).r,
    );
    expect(there).toMatchObject({ generic_domain: false, organisation_created: true });
  });

  it('is shipped by the module, and an installation row is written by the installation only', async () => {
    const shipped = await one<{ n: number }>(
      db,
      `select count(*)::int as n from crm.generic_email_domains where shipped and company_id is null`,
    );
    expect(shipped.n).toBeGreaterThan(50);
    const refused = await asOwner(() =>
      expectError(db, `insert into crm.generic_email_domains (domain, kind) values ('mine.example', 'personal')`),
    );
    expect(refused).toMatch(/row-level security/);
    await db.query(`insert into crm.generic_email_domains (domain, kind) values ('installation-mail.example', 'personal')`);
    expect((await byEmail('x@installation-mail.example')).generic_domain).toBe(true);
  });

  it('refuses a domain that is not one, and a kind it does not know', async () => {
    expect(await expectError(db, `insert into crm.generic_email_domains (domain, kind) values ('Upper.Example', 'personal')`)).toMatch(
      /crm_generic_email_domains_domain_shape/,
    );
    expect(await expectError(db, `insert into crm.generic_email_domains (domain, kind) values ('ok.example', 'other')`)).toMatch(
      /crm_generic_email_domains_kind/,
    );
  });
});

describe('the first and last interaction', () => {
  it('are computed from the activities, on the person and on its organisation', async () => {
    const first = await byEmail('ines@delta-works.example', { at: '2026-03-02T09:00:00Z' });
    await byEmail('ines@delta-works.example', { kind: 'meeting', at: '2026-05-10T14:00:00Z' });
    await byEmail('tom@delta-works.example', { kind: 'email_out', at: '2026-07-01T08:00:00Z' });
    // A note is not an interaction: it moves last_activity_at, not these.
    await asOwner(() =>
      db.query(`select crm.log_activity($1, $2, 'note', 'Internal', p_occurred_at => '2026-09-01T00:00:00Z')`, [
        companyId,
        first.contact_id,
      ]),
    );

    const person = await card(first.contact_id);
    expect(person).toMatchObject({ interactions: 2 });
    expect(new Date(person!['first_interaction_at'] as string).toISOString()).toBe('2026-03-02T09:00:00.000Z');
    expect(new Date(person!['last_interaction_at'] as string).toISOString()).toBe('2026-05-10T14:00:00.000Z');
    expect(new Date(person!['last_activity_at'] as string).toISOString()).toBe('2026-09-01T00:00:00.000Z');

    const organisation = await card(first.organisation_id!);
    expect(organisation).toMatchObject({ interactions: 3 });
    expect(new Date(organisation!['first_interaction_at'] as string).toISOString()).toBe('2026-03-02T09:00:00.000Z');
    expect(new Date(organisation!['last_interaction_at'] as string).toISOString()).toBe('2026-07-01T08:00:00.000Z');
  });

  it('are null on a card nothing was exchanged on', async () => {
    const id = await asOwner(async () => {
      const contact = (
        await one<{ id: string }>(db, `insert into contacts (company_id, name, is_company, contact_type) values ($1, 'Quiet Ltd', true, 'other') returning id`, [
          companyId,
        ])
      ).id;
      await db.query(`select crm.upsert_card($1, $2, '{}')`, [companyId, contact]);
      return contact;
    });
    expect(await card(id)).toMatchObject({ first_interaction_at: null, last_interaction_at: null, interactions: 0 });
  });

  it('follow a merge, with nothing to copy', async () => {
    const kept = await byEmail('ola@merge-a.example', { at: '2026-02-01T00:00:00Z' });
    const absorbed = await byEmail('ola.private@gmail.com', { at: '2026-01-15T00:00:00Z' });
    await asOwner(() => db.query(`select merge_contacts($1, $2)`, [kept.contact_id, absorbed.contact_id]));
    const merged = await card(kept.contact_id);
    expect(merged).toMatchObject({ interactions: 2 });
    expect(new Date(merged!['first_interaction_at'] as string).toISOString()).toBe('2026-01-15T00:00:00.000Z');
    // The address of the absorbed contact is not looked up again: it was merged.
    const again = await byEmail('ola@merge-a.example');
    expect(again.contact_id).toBe(kept.contact_id);
  });
});

describe('a replay', () => {
  it('writes nothing, looks nothing up, and answers the activity already kept', async () => {
    const first = await byEmail('replay@echo-systems.example', { ref: '<replay-1@echo>', name: 'Replay Person' });
    const count = () =>
      one<{ contacts: number; activities: number; cards: number }>(
        db,
        `select (select count(*)::int from contacts where company_id = $1) as contacts,
                (select count(*)::int from crm.activities where company_id = $1) as activities,
                (select count(*)::int from crm.cards where company_id = $1) as cards`,
        [companyId],
      );
    const before = await count();
    const second = await byEmail('replay@echo-systems.example', { ref: '<replay-1@echo>', name: 'Replay Person' });
    expect(await count()).toEqual(before);
    expect(second).toMatchObject({
      contact_id: first.contact_id,
      organisation_id: first.organisation_id,
      contact_created: false,
      organisation_created: false,
      replayed: true,
    });
    expect(second.activity!.id).toBe(first.activity!.id);
  });

  it('of a whole mailbox gives the same contacts, organisations and cards', async () => {
    const mailbox = [
      { email: 'a@replay-corp.example', ref: '<r1>' },
      { email: 'b@replay-corp.example', ref: '<r2>' },
      { email: 'c@gmail.com', ref: '<r3>' },
    ];
    for (const m of mailbox) await byEmail(m.email, { ref: m.ref });
    const snapshot = () =>
      rows(
        db,
        `select c.id, c.name, c.parent_id, k.id as card_id
           from contacts c left join crm.cards k on k.contact_id = c.id
          where c.company_id = $1 order by c.id`,
        [companyId],
      );
    const before = await snapshot();
    for (const m of mailbox) await byEmail(m.email, { ref: m.ref });
    expect(await snapshot()).toEqual(before);
  });
});
