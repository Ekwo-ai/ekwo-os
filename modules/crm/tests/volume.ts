/**
 * A company the size of an imported address book, for the reads of `crm`.
 *
 * Every other test of the module writes a handful of rows, and Postgres plans
 * a handful of rows the same way whatever the indexes and the predicates are.
 * This builds, in one transaction and without a random draw, a company of the
 * order an ordinary import produces:
 *
 *   - organisations, and people of whom two in three belong to one;
 *   - a card on about one contact in three;
 *   - a tree of segments, and memberships of which one in five has left;
 *   - two pipelines with their stages, and deals at every stage;
 *   - activities on the carded contacts, spread over three years.
 *
 * Every figure is a multiple of `scale`, 1 being the size the search was seen
 * failing at and 10 the size it has to hold. The country and the language of
 * each contact cycle over the ones the seeds carry, read from the database —
 * a contact without either takes its organisation's, which is the fallback
 * `search_cards()` reads.
 *
 * The rows are written by the installer, the way an import writes them, and
 * read back by the test as a member: the policies apply to every read.
 */

import type { PGlite } from '@electric-sql/pglite';

export interface VolumeSize {
  organisations: number;
  people: number;
  cards: number;
  segmentRoots: number;
  segmentChildren: number;
  memberships: number;
  deals: number;
  activities: number;
}

/**
 * The size at scale 1: about 33 000 contacts, 10 500 cards, 213 segments, 226
 * deals and 21 500 activities. A fraction gives a small company of the same
 * shape; the tree of segments keeps its size at every scale.
 */
export function volumeSize(scale: number): VolumeSize {
  const times = (n: number): number => Math.max(1, Math.round(n * scale));
  return {
    organisations: times(3_000),
    people: times(30_000),
    cards: times(10_500),
    segmentRoots: 13,
    segmentChildren: 200,
    memberships: times(30_000),
    deals: times(226),
    activities: times(21_500),
  };
}

/** What a test needs to name, once the company is built. */
export interface Volume {
  size: VolumeSize;
  segmentId: string;
  stageId: string;
  country: string;
  language: string;
  owner: string;
  /** A fragment of text found in some names, e-mails and organisation names, and not in most. */
  text: string;
  /** A moment inside the span of the activities. */
  moment: string;
}

/**
 * Fills a company that already has the module enabled. `ref` is a fixed
 * moment the activities count back from, so two runs write the same rows.
 */
export async function fillVolume(db: PGlite, companyId: string, scale: number): Promise<Volume> {
  const size = volumeSize(scale);
  const ref = '2026-06-30T12:00:00Z';
  await db.transaction(async (tx) => {
    await tx.query(
      `create temporary table volume_places on commit drop as
         select row_number() over (order by d.country, l.language) - 1 as i, d.country, l.language::char(2) as language
           from country_defaults d
           cross join lateral unnest(d.languages) as l(language)
          where length(l.language) = 2`,
    );
    // Organisations: every one has a country and a language.
    await tx.query(
      `insert into contacts (company_id, name, is_company, contact_type, email, country, language)
       select $1, 'Organisation ' || to_char(g, 'FM000000') || case when g % 23 = 0 then ' Harbourline' else '' end,
              true, 'other', 'office@org' || g || '.example',
              p.country, p.language
         from generate_series(1, $2::int) g
         join volume_places p on p.i = g % (select count(*) from volume_places)`,
      [companyId, size.organisations],
    );
    // People: two in three belong to an organisation and carry neither a
    // country nor a language of their own; the others carry both.
    await tx.query(
      `with orgs as (
         select id, row_number() over (order by name) as n from contacts
          where company_id = $1 and is_company
       )
       insert into contacts (company_id, name, is_company, contact_type, parent_id, email, country, language)
       select $1, 'Person ' || to_char(g, 'FM0000000') || case when g % 41 = 0 then ' Harbourline' else '' end,
              false, 'other', o.id,
              case when g % 5 = 0 then null
                   when g % 37 = 0 then 'p' || g || '@harbourline.example'
                   else 'p' || g || '@mail.example' end,
              case when o.id is null then p.country end,
              case when o.id is null then p.language end
         from generate_series(1, $2::int) g
         left join orgs o on g % 3 <> 0 and o.n = 1 + g % $3::int
         join volume_places p on p.i = (g / 7) % (select count(*) from volume_places)`,
      [companyId, size.people, size.organisations],
    );
    // Cards: every third contact by name, statuses, priorities and owners cycling.
    await tx.query(
      `with picked as (
         select id, row_number() over (order by name) as n from contacts where company_id = $1
       )
       insert into crm.cards (company_id, contact_id, status, priority, owner, no_outbound)
       select $1, p.id,
              (enum_range(null::crm.relationship_status))[1 + p.n % array_length(enum_range(null::crm.relationship_status), 1)],
              (enum_range(null::crm.priority))[1 + p.n % array_length(enum_range(null::crm.priority), 1)],
              case when p.n % 4 = 0 then null else 'desk-' || (p.n % 9) end,
              p.n % 13 = 0
         from picked p
        where p.n % 3 = 0
        limit $2`,
      [companyId, size.cards],
    );
    // Segments: roots, and children spread under them.
    await tx.query(
      `insert into crm.segments (company_id, kind, name, slug)
       select $1, (enum_range(null::crm.segment_kind))[1 + g % array_length(enum_range(null::crm.segment_kind), 1)],
              'Root ' || g, 'root-' || g
         from generate_series(1, $2::int) g`,
      [companyId, size.segmentRoots],
    );
    await tx.query(
      `insert into crm.segments (company_id, parent_id, kind, name, slug)
       select $1, r.id, 'segment', 'Segment ' || g, 'segment-' || to_char(g, 'FM000')
         from generate_series(1, $2::int) g
         join crm.segments r on r.company_id = $1 and r.slug = 'root-' || (1 + g % $3::int)`,
      [companyId, size.segmentChildren, size.segmentRoots],
    );
    // Memberships: carded contacts first, a few segments each; one in five has left.
    await tx.query(
      `with k as (select contact_id, row_number() over (order by contact_id) as n from crm.cards where company_id = $1),
            s as (select id, row_number() over (order by slug) as n, count(*) over () as total
                    from crm.segments where company_id = $1),
            pairs as (
              select distinct on (k.contact_id, s.id) k.contact_id, s.id as segment_id, g
                from generate_series(0, $2::int - 1) g
                join k on k.n = 1 + g % (select count(*) from k)
                join s on s.n = 1 + (g * 7 + g / (select count(*) from k)) % s.total
            )
       insert into crm.segment_members (company_id, segment_id, contact_id, added_by, joined_at, left_at)
       select $1, segment_id, contact_id, 'import',
              $3::timestamptz - (g % 900) * interval '1 day',
              case when g % 5 = 0 then $3::timestamptz - (g % 30) * interval '1 day' end
         from pairs
       on conflict do nothing`,
      [companyId, size.memberships, ref],
    );
    // Pipelines and stages.
    await tx.query(
      `insert into crm.pipelines (company_id, name, slug) values ($1, 'Sales', 'sales'), ($1, 'Partners', 'partners')`,
      [companyId],
    );
    await tx.query(
      `insert into crm.stages (company_id, pipeline_id, name, position, outcome)
       select $1, p.id, s.name, s.position, s.outcome::crm.stage_outcome
         from crm.pipelines p
         cross join (values ('Lead', 1, 'open'), ('Qualified', 2, 'open'), ('Proposal', 3, 'open'),
                            ('Won', 4, 'won'), ('Lost', 5, 'lost')) s(name, position, outcome)
        where p.company_id = $1`,
      [companyId],
    );
    // Deals on carded contacts, at every stage; the closed ones closed.
    await tx.query(
      `with k as (select contact_id, row_number() over (order by contact_id) as n from crm.cards where company_id = $1),
            st as (select s.id, s.pipeline_id, s.outcome, row_number() over (order by p.slug, s.position) as n
                     from crm.stages s join crm.pipelines p on p.id = s.pipeline_id where s.company_id = $1)
       insert into crm.deals (company_id, pipeline_id, stage_id, contact_id, title, amount, currency_code,
                              expected_on, owner, closed_at, closed_outcome)
       select $1, st.pipeline_id, st.id, k.contact_id, 'Deal ' || g,
              case when g % 4 = 0 then null else (1000 + g * 37 % 9000)::numeric(18, 2) end,
              case when g % 4 = 0 then null else c.currency_code end,
              $3::date + (g % 120), 'desk-' || (g % 9),
              case when st.outcome <> 'open' then $3::timestamptz - (g % 60) * interval '1 day' end,
              case when st.outcome <> 'open' then st.outcome end
         from generate_series(1, $2::int) g
         join k on k.n = 1 + (g * 31) % (select count(*) from k)
         join st on st.n = 1 + g % (select count(*) from st)
         join companies c on c.id = $1`,
      [companyId, size.deals, ref],
    );
    // Activities: on carded contacts, over three years; the trigger keeps
    // each card's last_activity_at.
    await tx.query(
      `with k as (select contact_id, row_number() over (order by contact_id) as n from crm.cards where company_id = $1)
       insert into crm.activities (company_id, contact_id, kind, actor, occurred_at, subject)
       select $1, k.contact_id,
              (enum_range(null::crm.activity_kind))[1 + g % array_length(enum_range(null::crm.activity_kind), 1)],
              'desk-' || (g % 9), $3::timestamptz - ((g * 7919) % 1095) * interval '1 day', 'Activity ' || g
         from generate_series(1, $2::int) g
         join k on k.n = 1 + (g * 13) % (select count(*) from k)`,
      [companyId, size.activities, ref],
    );
    // Last, one person in fifty of those without a card was absorbed by a
    // merge, recorded the way merge_contacts() records it: a merged contact
    // is named by no new row, and is left out of every search.
    await tx.query(
      `create temporary table volume_merges on commit drop as
         select id as absorbed_id, keep as kept_id
           from (select id, lag(id) over (order by name) as keep, row_number() over (order by name) as n
                   from contacts c where c.company_id = $1 and not c.is_company
                    and not exists (select 1 from crm.cards k where k.contact_id = c.id)) k
          where k.n % 50 = 7 and k.keep is not null`,
      [companyId],
    );
    await tx.query(
      `insert into contact_merges (company_id, kept_id, absorbed_id)
       select $1, kept_id, absorbed_id from volume_merges`,
      [companyId],
    );
    await tx.query(
      `update contacts c set merged_into = m.kept_id, active = false
         from volume_merges m where c.id = m.absorbed_id`,
    );
  });
  await db.exec('analyze');

  const segment = await db.query<{ id: string }>(
    `select m.segment_id as id from crm.segment_members m where m.company_id = $1 and m.left_at is null
      group by m.segment_id order by count(*) desc, m.segment_id limit 1`,
    [companyId],
  );
  const stage = await db.query<{ id: string }>(
    `select d.stage_id as id from crm.deals d where d.company_id = $1
      group by d.stage_id order by count(*) desc, d.stage_id limit 1`,
    [companyId],
  );
  const place = await db.query<{ country: string; language: string }>(
    `select country, language from contacts where company_id = $1 and is_company order by name limit 1`,
    [companyId],
  );
  return {
    size,
    segmentId: segment.rows[0]!.id,
    stageId: stage.rows[0]!.id,
    country: place.rows[0]!.country,
    language: place.rows[0]!.language,
    owner: 'desk-3',
    text: 'harbourline',
    moment: '2026-01-01T00:00:00Z',
  };
}
