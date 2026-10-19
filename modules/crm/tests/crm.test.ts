import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from '../../../tests/helpers/db.js';
import { newCompany } from '../../../tests/helpers/factory.js';

// `crm` keeps the record of a relationship on the socle's own contacts: an
// organisation, a person of it, both prospects (`other`) until a deal is won.
// No contact of its own, no country, and nothing written to the ledger.

let db: PGlite;
let companyId: string;
let ownerId: string;
let orgId: string;
let personId: string;
let pipelineId: string;
let stages: Record<string, string>;
let segmentId: string;
let homeCountry: string;
let otherCountry: string;

async function contact(
  company: string,
  values: { name: string; isCompany: boolean; parentId?: string | null; email?: string | null; country?: string | null },
): Promise<string> {
  const row = await one<{ id: string }>(
    db,
    `insert into contacts (company_id, name, is_company, contact_type, parent_id, email, country)
     values ($1, $2, $3, 'other', $4, $5, $6) returning id`,
    [company, values.name, values.isCompany, values.parentId ?? null, values.email ?? null, values.country ?? null],
  );
  return row.id;
}

beforeAll(async () => {
  db = await freshDatabase();
  ({ companyId, ownerId } = await newCompany(db, { country: 'BE', name: 'Relations SRL' }));
  // The country of the company, and another one the seeds carry: read, not named.
  homeCountry = (await one<{ country: string }>(db, `select country from companies where id = $1`, [companyId]))
    .country;
  otherCountry = (
    await one<{ country: string }>(
      db,
      `select country from country_defaults where country <> $1 order by country limit 1`,
      [homeCountry],
    )
  ).country;

  orgId = await contact(companyId, { name: 'Northwind Trading', isCompany: true, country: homeCountry });
  personId = await contact(companyId, {
    name: 'Ada Lovelace',
    isCompany: false,
    parentId: orgId,
    email: 'ada@northwind.example',
  });

  await asUser(db, ownerId, async () => {
    await db.query(`select enable_module($1, 'crm')`, [companyId]);
    pipelineId = (
      await one<{ id: string }>(
        db,
        `insert into crm.pipelines (company_id, name, slug) values ($1, 'Sales', 'sales') returning id`,
        [companyId],
      )
    ).id;
    const inserted = await rows<{ name: string; id: string }>(
      db,
      `insert into crm.stages (company_id, pipeline_id, name, position, outcome) values
         ($1, $2, 'Lead', 1, 'open'), ($1, $2, 'Contacted', 2, 'open'), ($1, $2, 'Qualified', 3, 'open'),
         ($1, $2, 'Proposal', 4, 'open'), ($1, $2, 'Won', 5, 'won'), ($1, $2, 'Lost', 6, 'lost')
       returning name, id`,
      [companyId, pipelineId],
    );
    stages = Object.fromEntries(inserted.map((s) => [s.name, s.id]));
    segmentId = (
      await one<{ id: string }>(
        db,
        `insert into crm.segments (company_id, kind, name, slug) values ($1, 'segment', 'Retail', 'retail') returning id`,
        [companyId],
      )
    ).id;
  });
});

afterAll(async () => {
  await db.close();
});

describe('a card', () => {
  it('is created by upsert_card, then changed field by field', async () => {
    await asUser(db, ownerId, async () => {
      const created = await one<Record<string, unknown>>(
        db,
        `select * from crm.upsert_card($1, $2, '{"owner": "sales-desk", "tags": ["event"]}')`,
        [companyId, personId],
      );
      expect(created).toMatchObject({ status: 'new', priority: 'medium', owner: 'sales-desk', tags: ['event'] });

      const changed = await one<Record<string, unknown>>(
        db,
        `select * from crm.upsert_card($1, $2, '{"status": "contacted", "job_title": "Buyer"}')`,
        [companyId, personId],
      );
      expect(changed).toMatchObject({
        id: created['id'],
        status: 'contacted',
        priority: 'medium',
        owner: 'sales-desk',
        job_title: 'Buyer',
        tags: ['event'],
      });
      expect(await rows(db, `select id from crm.cards where contact_id = $1`, [personId])).toHaveLength(1);

      await db.query(`select crm.upsert_card($1, $2, '{"priority": "high"}')`, [companyId, orgId]);
    });
  });

  it('refuses a field it does not have, by name', async () => {
    await asUser(db, ownerId, async () => {
      const refused = await expectError(db, `select crm.upsert_card($1, $2, '{"colour": "blue"}')`, [
        companyId,
        personId,
      ]);
      expect(refused).toMatch(/^crm_unknown_field: a card has no field colour/);
    });
  });
});

describe('a segment', () => {
  it('is joined, left and joined again on the same row', async () => {
    await asUser(db, ownerId, async () => {
      const joined = await one<{ id: string; left_at: string | null; added_by: string }>(
        db,
        `select * from crm.join_segment($1, $2, $3, 'import', 'met at a fair')`,
        [companyId, segmentId, personId],
      );
      expect(joined.left_at).toBeNull();

      const left = await one<{ id: string; left_at: string | null }>(
        db,
        `select * from crm.leave_segment($1, $2, $3)`,
        [companyId, segmentId, personId],
      );
      expect(left.id).toBe(joined.id);
      expect(left.left_at).not.toBeNull();

      const back = await one<{ id: string; left_at: string | null; note: string }>(
        db,
        `select * from crm.join_segment($1, $2, $3)`,
        [companyId, segmentId, personId],
      );
      expect(back).toMatchObject({ id: joined.id, left_at: null, note: 'met at a fair' });

      const never = await expectError(db, `select crm.leave_segment($1, $2, $3)`, [companyId, segmentId, orgId]);
      expect(never).toMatch(/^crm_not_a_member:/);
    });
  });

  it('refuses a parent that would make the tree a cycle', async () => {
    await asUser(db, ownerId, async () => {
      const child = await one<{ id: string }>(
        db,
        `insert into crm.segments (company_id, parent_id, kind, name, slug)
         values ($1, $2, 'taxonomy', 'Retail food', 'retail-food') returning id`,
        [companyId, segmentId],
      );
      const cycle = await expectError(db, `update crm.segments set parent_id = $1 where id = $2`, [child.id, segmentId]);
      expect(cycle).toMatch(/^crm_segment_cycle:/);
    });
  });
});

describe('a deal', () => {
  let dealId: string;

  it('opens at the first open stage, in the company’s currency when none is given', async () => {
    await asUser(db, ownerId, async () => {
      const deal = await one<Record<string, unknown>>(
        db,
        `select * from crm.open_deal($1, $2, $3, 'Annual subscription', 12000)`,
        [companyId, pipelineId, personId],
      );
      dealId = deal['id'] as string;
      const currency = await one<{ currency_code: string }>(db, `select currency_code from companies where id = $1`, [
        companyId,
      ]);
      expect(deal).toMatchObject({
        stage_id: stages['Lead'],
        amount: '12000.00',
        currency_code: currency.currency_code,
        closed_at: null,
        closed_outcome: null,
      });
    });
  });

  it('moves, and a won stage closes it and makes the organisation a customer', async () => {
    await asUser(db, ownerId, async () => {
      const proposal = await one<Record<string, unknown>>(db, `select * from crm.move_deal($1, $2, $3)`, [
        companyId,
        dealId,
        stages['Proposal'],
      ]);
      expect(proposal).toMatchObject({ closed_at: null, closed_outcome: null });

      const won = await one<Record<string, unknown>>(db, `select * from crm.move_deal($1, $2, $3)`, [
        companyId,
        dealId,
        stages['Won'],
      ]);
      expect(won['closed_outcome']).toBe('won');
      expect(won['closed_at']).not.toBeNull();

      const types = await rows<{ name: string; contact_type: string }>(
        db,
        `select name, contact_type::text from contacts where id = any($1) order by name`,
        [[orgId, personId]],
      );
      // The organisation at the root is the party; the person stays as they were.
      expect(types).toEqual([
        { name: 'Ada Lovelace', contact_type: 'other' },
        { name: 'Northwind Trading', contact_type: 'customer' },
      ]);

      const logged = await rows<{ subject: string }>(
        db,
        `select subject from crm.activities where deal_id = $1 and kind = 'system' order by occurred_at, created_at`,
        [dealId],
      );
      expect(logged.map((a) => a.subject)).toEqual(['opened at Lead', 'moved to Proposal', 'moved to Won']);
    });
  });

  it('is not won by a member who may not change the contact', async () => {
    const prospect = await contact(companyId, { name: 'Contoso Partners', isCompany: true });
    const seller = crypto.randomUUID();
    await db.query(
      `insert into company_members (company_id, user_id, role, capabilities_revoked)
       values ($1, $2, 'accountant', array['contacts.write'])`,
      [companyId, seller],
    );
    await asUser(db, seller, async () => {
      const deal = await one<{ id: string }>(db, `select id from crm.open_deal($1, $2, $3, 'Pilot')`, [
        companyId,
        pipelineId,
        prospect,
      ]);
      const refused = await expectError(db, `select crm.move_deal($1, $2, $3)`, [companyId, deal.id, stages['Won']]);
      expect(refused).toMatch(/^crm_not_allowed: .*contacts\.write/);
    });
    const still = await one<{ contact_type: string }>(db, `select contact_type::text from contacts where id = $1`, [
      prospect,
    ]);
    expect(still.contact_type).toBe('other');
  });

  it('refuses a stage of another pipeline', async () => {
    await asUser(db, ownerId, async () => {
      const other = await one<{ id: string }>(
        db,
        `with p as (insert into crm.pipelines (company_id, name, slug) values ($1, 'Partners', 'partners') returning id)
         insert into crm.stages (company_id, pipeline_id, name, position) select $1, p.id, 'Talk', 1 from p returning id`,
        [companyId],
      );
      const refused = await expectError(db, `select crm.move_deal($1, $2, $3)`, [companyId, dealId, other.id]);
      expect(refused).toMatch(/^crm_stage_not_in_pipeline:/);
    });
  });
});

describe('an activity', () => {
  it('is written once per source and reference, and moves the card', async () => {
    await asUser(db, ownerId, async () => {
      const first = await one<{ id: string }>(
        db,
        `select * from crm.log_activity($1, $2, 'email_in', 'Re: proposal', 'Looks good.',
                                        p_occurred_at => timestamptz '2027-01-15 10:00:00+00',
                                        p_source => 'mailbox', p_source_ref => '<m1@example.org>')`,
        [companyId, personId],
      );
      const again = await one<{ id: string }>(
        db,
        `select * from crm.log_activity($1, $2, 'email_in', 'Re: proposal (copy)',
                                        p_source => 'mailbox', p_source_ref => '<m1@example.org>')`,
        [companyId, personId],
      );
      expect(again.id).toBe(first.id);
      expect(
        await rows(db, `select 1 from crm.activities where source = 'mailbox' and source_ref = '<m1@example.org>'`),
      ).toHaveLength(1);

      const card = await one<{ last_activity_at: Date }>(
        db,
        `select last_activity_at from crm.cards where contact_id = $1`,
        [personId],
      );
      expect(card.last_activity_at.toISOString()).toBe('2027-01-15T10:00:00.000Z');

      // An older activity does not move it back.
      await db.query(
        `select crm.log_activity($1, $2, 'note', 'Old note', p_occurred_at => timestamptz '2026-01-01 00:00:00+00')`,
        [companyId, personId],
      );
      const still = await one<{ last_activity_at: Date }>(
        db,
        `select last_activity_at from crm.cards where contact_id = $1`,
        [personId],
      );
      expect(still.last_activity_at.toISOString()).toBe('2027-01-15T10:00:00.000Z');
    });
  });
});

describe('searching the cards', () => {
  it('finds by text, status, segment and country', async () => {
    await asUser(db, ownerId, async () => {
      const names = async (sql: string, params: unknown[]): Promise<string[]> =>
        (await rows<{ name: string }>(db, sql, params)).map((r) => r.name);

      expect(await names(`select name from crm.search_cards($1, p_query => 'northwind')`, [companyId])).toEqual([
        'Ada Lovelace',
        'Northwind Trading',
      ]);
      expect(await names(`select name from crm.search_cards($1, p_query => 'ada@')`, [companyId])).toEqual([
        'Ada Lovelace',
      ]);
      expect(await names(`select name from crm.search_cards($1, p_status => 'contacted')`, [companyId])).toEqual([
        'Ada Lovelace',
      ]);
      expect(await names(`select name from crm.search_cards($1, p_segment_id => $2)`, [companyId, segmentId])).toEqual(
        ['Ada Lovelace'],
      );
      // The person has no country of their own and takes their organisation's.
      expect(
        await names(`select name from crm.search_cards($1, p_country => $2) order by name`, [companyId, homeCountry]),
      ).toEqual(['Ada Lovelace', 'Northwind Trading']);
      expect(await names(`select name from crm.search_cards($1, p_country => $2)`, [companyId, otherCountry])).toEqual(
        [],
      );

      const ada = await one<{ organisation_name: string; segments: string[]; email: string }>(
        db,
        `select * from crm.search_cards($1, p_query => 'ada')`,
        [companyId],
      );
      expect(ada).toMatchObject({
        organisation_name: 'Northwind Trading',
        segments: ['retail'],
        email: 'ada@northwind.example',
      });
    });
  });
});

describe('card_of', () => {
  it('gives the contact, its card, its segments, its open deals and its latest activities', async () => {
    await asUser(db, ownerId, async () => {
      await db.query(`select crm.open_deal($1, $2, $3, 'Second site')`, [companyId, pipelineId, personId]);
      const card = (
        await one<{ card: Record<string, unknown> }>(db, `select crm.card_of($1, $2) as card`, [companyId, personId])
      ).card;
      expect(card['contact']).toMatchObject({ id: personId, name: 'Ada Lovelace', is_company: false });
      expect(card['organisation']).toMatchObject({ id: orgId, contact_type: 'customer' });
      expect(card['card']).toMatchObject({ status: 'contacted' });
      expect((card['segments'] as { slug: string }[]).map((s) => s.slug)).toEqual(['retail']);
      // The won deal is closed; the second one is open.
      expect((card['deals'] as { title: string }[]).map((d) => d.title)).toEqual(['Second site']);
      const activities = card['activities'] as { subject: string }[];
      expect(activities.length).toBeGreaterThanOrEqual(5);
      expect(activities[0]?.subject).toBe('Re: proposal');

      // An organisation sees the open deals with its people.
      const org = (
        await one<{ card: Record<string, unknown> }>(db, `select crm.card_of($1, $2) as card`, [companyId, orgId])
      ).card;
      expect((org['deals'] as { title: string }[]).map((d) => d.title)).toEqual(['Second site']);
    });
  });
});

describe('another company', () => {
  let other: { companyId: string; ownerId: string };
  let strangerContact: string;

  beforeAll(async () => {
    other = await newCompany(db, { country: 'BE', name: 'Voisine SRL' });
    strangerContact = await contact(other.companyId, { name: 'Somebody Else', isCompany: true });
    await asUser(db, other.ownerId, async () => {
      await db.query(`select enable_module($1, 'crm')`, [other.companyId]);
    });
  });

  it('cannot have its contact named by a row of this one: the composite key refuses it', async () => {
    const refused = await expectError(
      db,
      `insert into crm.cards (company_id, contact_id) values ($1, $2)`,
      [companyId, strangerContact],
    );
    expect(refused).toMatch(/foreign key/i);
    await asUser(db, ownerId, async () => {
      const viaFunction = await expectError(db, `select crm.upsert_card($1, $2, '{}')`, [companyId, strangerContact]);
      expect(viaFunction).toMatch(/foreign key/i);
    });
  });

  it('reads nothing of this company, and is told so by name when it tries to write', async () => {
    await asUser(db, other.ownerId, async () => {
      for (const table of ['cards', 'segments', 'segment_members', 'pipelines', 'stages', 'deals', 'activities']) {
        expect(await rows(db, `select id from crm.${table} where company_id = $1`, [companyId])).toEqual([]);
      }
      expect(await rows(db, `select * from crm.search_cards($1)`, [companyId])).toEqual([]);
      const refused = await expectError(db, `select crm.upsert_card($1, $2, '{}')`, [companyId, personId]);
      expect(refused).toMatch(/^crm_module_not_enabled:/);
    });
  });
});

describe('a merge of two contacts', () => {
  it('folds the two cards and the two memberships into one', async () => {
    const twin = await contact(companyId, { name: 'A. Lovelace', isCompany: false, parentId: orgId });
    await asUser(db, ownerId, async () => {
      await db.query(`select crm.upsert_card($1, $2, '{"tags": ["webinar"], "no_outbound": true}')`, [
        companyId,
        twin,
      ]);
      await db.query(`select crm.join_segment($1, $2, $3)`, [companyId, segmentId, twin]);
      await db.query(`select crm.log_activity($1, $2, 'call', 'Called the twin')`, [companyId, twin]);
      await db.query(`select merge_contacts($1, $2)`, [personId, twin]);

      const cards = await rows<{ tags: string[]; no_outbound: boolean; status: string }>(
        db,
        `select tags, no_outbound, status::text from crm.cards where contact_id = any($1)`,
        [[personId, twin]],
      );
      expect(cards).toEqual([{ tags: ['event', 'webinar'], no_outbound: true, status: 'contacted' }]);
      expect(
        await rows(db, `select 1 from crm.segment_members where contact_id = any($1)`, [[personId, twin]]),
      ).toHaveLength(1);
      expect(await rows(db, `select 1 from crm.activities where contact_id = $1`, [twin])).toEqual([]);
      expect(
        await rows(db, `select 1 from crm.activities where contact_id = $1 and subject = 'Called the twin'`, [personId]),
      ).toHaveLength(1);
    });
  });
});

describe('the module', () => {
  it('classifies every table it holds for the archive of a company', async () => {
    const classified = await rows<{ table_name: string; disposition: string }>(
      db,
      `select table_name, disposition from crm.archive_tables() order by table_name`,
    );
    const tables = await rows<{ relname: string }>(
      db,
      `select c.relname from pg_class c join pg_namespace n on n.oid = c.relnamespace
        where n.nspname = 'crm' and c.relkind = 'r' order by c.relname`,
    );
    expect(classified.map((t) => t.table_name)).toEqual(tables.map((t) => t.relname));
    expect(new Set(classified.map((t) => t.disposition))).toEqual(new Set(['exported']));
    expect(await rows(db, `select * from company_archive_unclassified() where table_schema = 'crm'`)).toEqual([]);
  });
});
