-- Ekwo — the `crm` module: the record of a relationship, beside the books.
--
-- A CRM here keeps no contact of its own. A person is a row of
-- `public.contacts` with `is_company = false` and `parent_id` naming their
-- organisation; an organisation is a row with `is_company = true`. Both stay
-- `contact_type = 'other'` while they are prospects, and the organisation
-- becomes a customer the day a deal is won, so the invoice is issued to the
-- very row the relationship was built on. Two rows that turn out to be one
-- party are merged by the socle's `merge_contacts()`, which moves every
-- reference of this schema with the rest.
--
-- What the module holds: a card per contact that is followed, segments to
-- group contacts (a tree), pipelines with their stages, the deals moving
-- through them, and every activity — a note, an e-mail, a call, a signal read
-- somewhere. It knows nothing of who works a relationship: `owner` and `actor`
-- are handles, free text, a member or an agent, and what an agent decides is
-- outside the database. It writes nothing to the ledger: `module.json` says
-- `"posts": false`, and a test holds it to that.
--
-- **Every reference is composite with `company_id`.** A card, a membership, a
-- deal and an activity name their contact by `(contact_id, company_id)`, a
-- deal names its stage by `(stage_id, pipeline_id)` and its pipeline by
-- `(pipeline_id, company_id)`, so a row of one company can never name a
-- contact, a segment or a deal of another, whatever id it is handed.
--
-- **The functions are `security invoker`.** The policies decide: whoever holds
-- `crm.write` on a company that holds the module writes, whoever holds
-- `crm.read` reads, and nobody else sees a row. The functions check the module
-- and the capability first only to answer by name, `crm_<code>: <sentence>`,
-- rather than with the bare refusal of a policy. Winning a deal also changes
-- the contact, which is the socle's table and the socle's policy:
-- `contacts.write`.
--
-- **No country, no currency, no language.** A deal's currency is a code of
-- `public.currencies`, given or taken from the company itself; a contact's
-- country and language are the socle's columns, read where they stand.

create schema crm;

comment on schema crm is
  'Ekwo module `crm`: the record of a relationship — cards, segments, pipelines, deals and activities — kept on the socle''s contacts. Posts nothing to the ledger.';

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------

create type crm.relationship_status as enum (
  'new', 'contacted', 'in_discussion', 'client', 'partner', 'declined', 'dormant'
);

comment on type crm.relationship_status is
  'Where a relationship stands, as the people working it say it. new: on file, never approached. contacted: approached, no answer yet. in_discussion: a conversation is going on. client: buys. partner: works with the company without buying. declined: said no. dormant: nothing has happened for long enough to say so. A reading, not a gate: nothing in the module refuses a move between two of them.';

create type crm.priority as enum ('high', 'medium', 'low');

comment on type crm.priority is
  'How much attention a relationship is meant to get now. Three words, and the order is theirs.';

create type crm.segment_kind as enum ('taxonomy', 'segment', 'cohort', 'brand');

comment on type crm.segment_kind is
  'What a segment is for. taxonomy: a branch of a classification (an industry, a size). segment: a target the company addresses as one. cohort: the contacts reached together, at one moment, by one campaign. brand: the contacts one brand of the company speaks to.';

create type crm.stage_outcome as enum ('open', 'won', 'lost');

comment on type crm.stage_outcome is
  'What reaching a stage means. open: the deal is still being worked. won and lost close it: crm.move_deal() writes the date and the outcome on the deal.';

create type crm.activity_kind as enum (
  'note', 'email_out', 'email_in', 'call', 'meeting', 'message', 'signal', 'enrichment', 'task', 'system'
);

comment on type crm.activity_kind is
  'What happened. note: written by somebody. email_out and email_in: an e-mail sent or received. call, meeting, message: a conversation by telephone, in a room or on a messaging service. signal: something read elsewhere about the contact — a post, a hire, a news item. enrichment: data added to the card from a source. task: something somebody is meant to do. system: written by the module itself, a deal moving.';

-- ---------------------------------------------------------------------------
-- Cards
-- ---------------------------------------------------------------------------

create table crm.cards (
  id               uuid primary key default gen_random_uuid(),
  company_id       uuid not null references public.companies(id) on delete cascade,
  contact_id       uuid not null,
  status           crm.relationship_status not null default 'new',
  priority         crm.priority not null default 'medium',
  -- A handle: a member, an agent, a team. Free text on purpose — the module
  -- records who works a relationship and holds no list of who may.
  owner            text,
  job_title        text,
  linkedin_url     text,
  source           text,
  tags             text[] not null default '{}',
  no_outbound      boolean not null default false,
  custom           jsonb not null default '{}'::jsonb,
  last_activity_at timestamptz,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  -- One card per contact. The company is in the key on purpose: a row that
  -- names a contact of another company must fail on the foreign key, never
  -- answer "duplicate" and so say that the other company follows it.
  unique (company_id, contact_id),
  foreign key (contact_id, company_id) references public.contacts (id, company_id) on delete cascade,
  constraint crm_cards_custom_object check (jsonb_typeof(custom) = 'object')
);

comment on table crm.cards is
  'One card per contact the company follows: where the relationship stands, how much it matters, who works it and when anything last happened. The contact itself — its name, e-mail, country, organisation — is the socle''s row and is not repeated here.';
comment on column crm.cards.owner is
  'Who works the relationship, as a handle: a member, an agent, a team. Free text: the module holds no list of who may.';
comment on column crm.cards.source is
  'Where the contact came from — an import, a form, an event — in the words of whoever recorded it.';
comment on column crm.cards.no_outbound is
  'True when the contact is not to be approached first: no prospecting e-mail, no unsolicited message. An answer to the contact is still an answer.';
comment on column crm.cards.custom is
  'The fields a company keeps that the module does not name, as a JSON object.';
comment on column crm.cards.last_activity_at is
  'The latest occurred_at of the contact''s activities, kept by a trigger on crm.activities. Null while nothing has happened.';

create unique index crm_cards_id_company_idx on crm.cards (id, company_id);
create index crm_cards_contact_company_idx on crm.cards (contact_id, company_id);
create index crm_cards_company_status_idx on crm.cards (company_id, status);

create trigger crm_cards_set_updated_at
  before update on crm.cards
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Segments, and who is in them
-- ---------------------------------------------------------------------------

create table crm.segments (
  id          uuid primary key default gen_random_uuid(),
  company_id  uuid not null references public.companies(id) on delete cascade,
  parent_id   uuid,
  kind        crm.segment_kind not null,
  name        text not null,
  slug        text not null,
  description text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (company_id, slug),
  -- The key a parent and a membership name a segment by, declared here
  -- because the table names itself.
  constraint crm_segments_id_company_key unique (id, company_id),
  foreign key (parent_id, company_id) references crm.segments (id, company_id),
  constraint crm_segments_not_own_parent check (parent_id is null or parent_id <> id),
  constraint crm_segments_slug_shape check (slug ~ '^[a-z0-9][a-z0-9_-]*$')
);

comment on table crm.segments is
  'A group of contacts, in a tree: a taxonomy branch, a target, a cohort, a brand. A parent belongs to the same company, and the chain of parents has no cycle and at most 32 levels.';
comment on column crm.segments.slug is
  'The segment''s name for a machine: lower case, digits, hyphens and underscores, unique in the company.';

create index crm_segments_parent_company_idx on crm.segments (parent_id, company_id);

create trigger crm_segments_set_updated_at
  before update on crm.segments
  for each row execute function public.set_updated_at();

create table crm.segment_members (
  id          uuid primary key default gen_random_uuid(),
  company_id  uuid not null references public.companies(id) on delete cascade,
  segment_id  uuid not null,
  contact_id  uuid not null,
  added_by    text,
  joined_at   timestamptz not null default now(),
  -- Not null: the contact left, and the membership is remembered. Joining
  -- again sets it back to null.
  left_at     timestamptz,
  note        text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  -- The company leads the key, for the same reason as on cards.
  unique (company_id, segment_id, contact_id),
  foreign key (segment_id, company_id) references crm.segments (id, company_id) on delete cascade,
  foreign key (contact_id, company_id) references public.contacts (id, company_id) on delete cascade
);

comment on table crm.segment_members is
  'A contact in a segment. A contact who leaves keeps the row, with left_at set; joining again clears it. One row per segment and contact.';
comment on column crm.segment_members.added_by is
  'Who put the contact in the segment, as a handle. Free text.';
comment on column crm.segment_members.left_at is
  'When the contact left the segment. Null while the contact is in it.';

create index crm_segment_members_contact_company_idx on crm.segment_members (contact_id, company_id);
create index crm_segment_members_segment_company_idx on crm.segment_members (segment_id, company_id);

create trigger crm_segment_members_set_updated_at
  before update on crm.segment_members
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Pipelines, stages and deals
-- ---------------------------------------------------------------------------

create table crm.pipelines (
  id          uuid primary key default gen_random_uuid(),
  company_id  uuid not null references public.companies(id) on delete cascade,
  name        text not null,
  slug        text not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (company_id, slug),
  constraint crm_pipelines_slug_shape check (slug ~ '^[a-z0-9][a-z0-9_-]*$')
);

comment on table crm.pipelines is
  'A sequence of stages a deal moves through: sales, partnerships, hiring. None is created for a company: a pipeline is a decision of the company, written by insertion.';

create unique index crm_pipelines_id_company_idx on crm.pipelines (id, company_id);

create trigger crm_pipelines_set_updated_at
  before update on crm.pipelines
  for each row execute function public.set_updated_at();

create table crm.stages (
  id          uuid primary key default gen_random_uuid(),
  company_id  uuid not null references public.companies(id) on delete cascade,
  pipeline_id uuid not null,
  name        text not null,
  position    smallint not null,
  outcome     crm.stage_outcome not null default 'open',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  -- The company leads the key: a stage named with the pipeline of another
  -- company fails on the foreign key, never on "duplicate".
  unique (company_id, pipeline_id, position),
  unique (id, pipeline_id),
  foreign key (pipeline_id, company_id) references crm.pipelines (id, company_id) on delete cascade
);

comment on table crm.stages is
  'One step of a pipeline, in the order of position. A deal opens at the first open stage; reaching a won or a lost stage closes it.';
comment on column crm.stages.outcome is
  'open while a deal at this stage is still being worked; won or lost when reaching it closes the deal.';

create unique index crm_stages_id_company_idx on crm.stages (id, company_id);
create index crm_stages_pipeline_company_idx on crm.stages (pipeline_id, company_id);

create trigger crm_stages_set_updated_at
  before update on crm.stages
  for each row execute function public.set_updated_at();

create table crm.deals (
  id             uuid primary key default gen_random_uuid(),
  company_id     uuid not null references public.companies(id) on delete cascade,
  pipeline_id    uuid not null,
  stage_id       uuid not null,
  contact_id     uuid not null,
  title          text not null,
  amount         numeric(18, 2),
  currency_code  char(3) references public.currencies (code),
  expected_on    date,
  external_url   text,
  owner          text,
  closed_at      timestamptz,
  closed_outcome crm.stage_outcome,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  foreign key (pipeline_id, company_id) references crm.pipelines (id, company_id),
  foreign key (stage_id, pipeline_id) references crm.stages (id, pipeline_id),
  foreign key (contact_id, company_id) references public.contacts (id, company_id),
  constraint crm_deals_closed check ((closed_at is null) = (closed_outcome is null)),
  constraint crm_deals_closed_outcome check (closed_outcome is null or closed_outcome <> 'open'),
  constraint crm_deals_amount_currency check (amount is null or currency_code is not null)
);

comment on table crm.deals is
  'A piece of business with one contact, moving through the stages of one pipeline. Closed, with its date and its outcome, when it reaches a won or a lost stage. An amount is in a currency, always named.';
comment on column crm.deals.contact_id is
  'Who the deal is with: an organisation, or a person of one. Winning it makes the organisation at the root of the contact''s chain a customer.';
comment on column crm.deals.external_url is
  'Where the deal is described elsewhere: a proposal, a tender, a thread.';
comment on column crm.deals.closed_outcome is
  'won or lost once the deal is closed, null while it is open. Written by crm.move_deal() with closed_at.';

create unique index crm_deals_id_company_idx on crm.deals (id, company_id);
create index crm_deals_contact_company_idx on crm.deals (contact_id, company_id);
create index crm_deals_pipeline_company_idx on crm.deals (pipeline_id, company_id);
create index crm_deals_stage_pipeline_idx on crm.deals (stage_id, pipeline_id);
create index crm_deals_company_idx on crm.deals (company_id);
create index crm_deals_currency_idx on crm.deals (currency_code);

create trigger crm_deals_set_updated_at
  before update on crm.deals
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Activities
-- ---------------------------------------------------------------------------

create table crm.activities (
  id          uuid primary key default gen_random_uuid(),
  company_id  uuid not null references public.companies(id) on delete cascade,
  contact_id  uuid not null,
  deal_id     uuid,
  kind        crm.activity_kind not null,
  actor       text,
  occurred_at timestamptz not null default now(),
  subject     text,
  body        text,
  link        text,
  payload     jsonb not null default '{}'::jsonb,
  -- Where the activity was read from, and its identifier there: an import
  -- that runs twice finds the row it wrote the first time.
  source      text,
  source_ref  text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  foreign key (contact_id, company_id) references public.contacts (id, company_id) on delete cascade,
  foreign key (deal_id, company_id) references crm.deals (id, company_id) on delete set null (deal_id),
  constraint crm_activities_payload_object check (jsonb_typeof(payload) = 'object')
);

comment on table crm.activities is
  'Everything that happened with a contact, one row each: a note, an e-mail, a call, a meeting, a signal, a deal moving. Optionally about one deal. An activity read from elsewhere carries its source and its identifier there, and is written once.';
comment on column crm.activities.actor is
  'Who did it, as a handle: a member, an agent, the contact. Free text.';
comment on column crm.activities.payload is
  'Whatever structured detail came with the activity, as a JSON object.';
comment on column crm.activities.source is
  'Where the activity was read from: a mailbox, a calendar, a messaging service, an import. With source_ref, unique in the company.';
comment on column crm.activities.source_ref is
  'The identifier of the activity at its source — a message identifier, an event identifier. The same pair twice is the same activity.';

create unique index crm_activities_id_company_idx on crm.activities (id, company_id);
create unique index crm_activities_source_idx on crm.activities (company_id, source, source_ref)
  where source is not null;
create index crm_activities_contact_company_idx on crm.activities (contact_id, company_id, occurred_at desc);
create index crm_activities_deal_company_idx on crm.activities (deal_id, company_id);

create trigger crm_activities_set_updated_at
  before update on crm.activities
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Triggers of the module
-- ---------------------------------------------------------------------------

create or replace function crm.guard_segment_parent()
returns trigger
language plpgsql
as $$
declare
  v_id    uuid := new.parent_id;
  v_guard integer := 0;
begin
  while v_id is not null loop
    if v_id = new.id then
      raise exception 'crm_segment_cycle: segment % cannot have % above it, which it is itself above', new.slug, new.parent_id
        using errcode = '23514';
    end if;
    v_guard := v_guard + 1;
    if v_guard > 32 then
      raise exception 'crm_segment_too_deep: segment % would sit more than 32 levels down', new.slug
        using errcode = '23514';
    end if;
    select s.parent_id into v_id from crm.segments s where s.id = v_id;
  end loop;
  return new;
end;
$$;

comment on function crm.guard_segment_parent() is
  'Refuses a parent that would make the tree of segments a cycle (crm_segment_cycle) or deeper than 32 levels (crm_segment_too_deep), the bound commercial_entity() keeps on contacts.';

create trigger crm_segments_guard_parent
  before insert or update of parent_id on crm.segments
  for each row execute function crm.guard_segment_parent();

create or replace function crm.touch_card()
returns trigger
language plpgsql
as $$
begin
  update crm.cards k
     set last_activity_at = greatest(k.last_activity_at, new.occurred_at)
   where k.contact_id = new.contact_id
     and k.company_id = new.company_id
     and k.last_activity_at is distinct from greatest(k.last_activity_at, new.occurred_at);
  return null;
end;
$$;

comment on function crm.touch_card() is
  'After an activity is written, moves the last_activity_at of the contact''s card to its occurred_at when that is later. Does nothing where the contact has no card.';

create trigger crm_activities_touch_card
  after insert on crm.activities
  for each row execute function crm.touch_card();

-- A merge moves every reference of the absorbed contact onto the kept one,
-- with one `update` per foreign key. Where both had a card, or both were in
-- one segment, that update would collide with a unique key and the merge
-- would fail. These two triggers fold the two rows into the moving one and
-- remove the kept contact's, in the transaction `merge_contacts()` recorded in
-- `public.contact_merges` and in no other: anywhere else, the unique key
-- refuses as it should.

create or replace function crm.fold_card_on_merge()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_kept crm.cards%rowtype;
begin
  if not exists (select 1 from public.contact_merges m
                  where m.absorbed_id = old.contact_id and m.kept_id = new.contact_id
                    and m.company_id = new.company_id and m.transaction_id = txid_current()) then
    return new;
  end if;
  select * into v_kept from crm.cards k where k.contact_id = new.contact_id;
  if not found then
    return new;
  end if;
  -- The kept contact's card wins where it says something; the absorbed one
  -- fills what it left empty. A `no_outbound` on either side holds.
  new.status           := case when v_kept.status = 'new' then new.status else v_kept.status end;
  new.priority         := v_kept.priority;
  new.owner            := coalesce(v_kept.owner, new.owner);
  new.job_title        := coalesce(v_kept.job_title, new.job_title);
  new.linkedin_url     := coalesce(v_kept.linkedin_url, new.linkedin_url);
  new.source           := coalesce(v_kept.source, new.source);
  new.tags             := array(select distinct t from unnest(v_kept.tags || new.tags) t order by t);
  new.no_outbound      := v_kept.no_outbound or new.no_outbound;
  new.custom           := new.custom || v_kept.custom;
  new.last_activity_at := greatest(v_kept.last_activity_at, new.last_activity_at);
  new.created_at       := least(v_kept.created_at, new.created_at);
  delete from crm.cards k where k.id = v_kept.id;
  return new;
end;
$$;

comment on function crm.fold_card_on_merge() is
  'During merge_contacts(), and only then: when the kept contact already has a card, folds it with the absorbed contact''s card into one — the kept card''s answers first, the absorbed one''s filling the gaps, the tags joined, a no_outbound on either side kept — so the merge does not collide with the one card per contact.';

create trigger crm_cards_fold_on_merge
  before update of contact_id on crm.cards
  for each row when (old.contact_id is distinct from new.contact_id)
  execute function crm.fold_card_on_merge();

create or replace function crm.fold_membership_on_merge()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_kept crm.segment_members%rowtype;
begin
  if not exists (select 1 from public.contact_merges m
                  where m.absorbed_id = old.contact_id and m.kept_id = new.contact_id
                    and m.company_id = new.company_id and m.transaction_id = txid_current()) then
    return new;
  end if;
  select * into v_kept from crm.segment_members s
   where s.segment_id = new.segment_id and s.contact_id = new.contact_id;
  if not found then
    return new;
  end if;
  new.joined_at  := least(v_kept.joined_at, new.joined_at);
  new.left_at    := case when v_kept.left_at is null or new.left_at is null then null
                         else greatest(v_kept.left_at, new.left_at) end;
  new.added_by   := coalesce(v_kept.added_by, new.added_by);
  new.note       := coalesce(v_kept.note, new.note);
  new.created_at := least(v_kept.created_at, new.created_at);
  delete from crm.segment_members s where s.id = v_kept.id;
  return new;
end;
$$;

comment on function crm.fold_membership_on_merge() is
  'During merge_contacts(), and only then: when the kept contact is already in the segment, folds the two memberships into one — the earliest joining, still in it if either was — so the merge does not collide with the one membership per segment and contact.';

create trigger crm_segment_members_fold_on_merge
  before update of contact_id on crm.segment_members
  for each row when (old.contact_id is distinct from new.contact_id)
  execute function crm.fold_membership_on_merge();

-- No row of this schema names a contact merge_contacts() retired: the socle's
-- refusal, attached to every reference of the schema read from its foreign
-- keys.
do $$
begin
  if to_regprocedure('public.refuse_merged_contacts_in(text)') is null then
    raise exception 'socle_too_old: the crm module needs socle migration 20261019090000 (refuse_merged_contacts_in). Run ekwo migrate first.';
  end if;
  perform public.refuse_merged_contacts_in('crm');
end;
$$;

-- ---------------------------------------------------------------------------
-- The functions an agent or a screen calls
-- ---------------------------------------------------------------------------

create or replace function crm.require(p_company_id uuid, p_capability text, p_what text)
returns void
language plpgsql
stable
as $$
begin
  if p_company_id is null
     or not public.module_is_enabled(p_company_id, 'crm')
     or (not public.is_installer() and not public.module_enabled(p_company_id, 'crm')) then
    raise exception 'crm_module_not_enabled: the customer relationship module (crm) is not enabled on company %', p_company_id
      using errcode = '42501';
  end if;
  if not public.is_installer() and not public.has_capability(p_company_id, p_capability) then
    raise exception 'crm_not_allowed: % needs %', p_what, p_capability
      using errcode = '42501';
  end if;
end;
$$;

comment on function crm.require(uuid, text, text) is
  'Raises crm_module_not_enabled when the module is off for the company or the caller is not a member of it, and crm_not_allowed when the caller does not hold the capability. The first lines of every function of this module; the policies still decide every row.';

create or replace function crm.upsert_card(p_company_id uuid, p_contact_id uuid, p_patch jsonb default '{}'::jsonb)
returns crm.cards
language plpgsql
as $$
declare
  v_fields constant text[] := array['status', 'priority', 'owner', 'job_title', 'linkedin_url',
                                    'source', 'tags', 'no_outbound', 'custom'];
  v_bad    text;
  v_card   crm.cards%rowtype;
  v_new    crm.cards%rowtype;
begin
  perform crm.require(p_company_id, 'crm.write', 'writing a card');
  if p_patch is null or jsonb_typeof(p_patch) <> 'object' then
    raise exception 'crm_bad_patch: the fields of a card are given as a JSON object';
  end if;
  select k into v_bad from jsonb_object_keys(p_patch) k where k <> all (v_fields) order by k limit 1;
  if found then
    raise exception 'crm_unknown_field: a card has no field %; the fields are %', v_bad, array_to_string(v_fields, ', ');
  end if;

  insert into crm.cards (company_id, contact_id) values (p_company_id, p_contact_id)
  on conflict (company_id, contact_id) do nothing;
  select * into v_card from crm.cards k
   where k.contact_id = p_contact_id and k.company_id = p_company_id
   for update;
  if not found then
    raise exception 'crm_unknown_contact: contact % is not a contact of company %', p_contact_id, p_company_id;
  end if;

  -- The patch laid over the card as it stands: a field the patch names takes
  -- its value, every other one keeps its own.
  v_new := jsonb_populate_record(v_card, p_patch);
  update crm.cards k
     set status       = v_new.status,
         priority     = v_new.priority,
         owner        = v_new.owner,
         job_title    = v_new.job_title,
         linkedin_url = v_new.linkedin_url,
         source       = v_new.source,
         tags         = v_new.tags,
         no_outbound  = v_new.no_outbound,
         custom       = v_new.custom
   where k.id = v_card.id
  returning * into v_card;
  return v_card;
end;
$$;

comment on function crm.upsert_card(uuid, uuid, jsonb) is
  'Creates the card of a contact, or changes it: each field the patch names takes its value, every other one keeps its own. The fields are status, priority, owner, job_title, linkedin_url, source, tags, no_outbound and custom; any other key is refused by name, crm_unknown_field. Needs crm.write. Returns the card.';

create or replace function crm.log_activity(
  p_company_id  uuid,
  p_contact_id  uuid,
  p_kind        crm.activity_kind,
  p_subject     text default null,
  p_body        text default null,
  p_deal_id     uuid default null,
  p_actor       text default null,
  p_occurred_at timestamptz default null,
  p_link        text default null,
  p_payload     jsonb default null,
  p_source      text default null,
  p_source_ref  text default null
)
returns crm.activities
language plpgsql
as $$
declare
  v_row crm.activities%rowtype;
begin
  perform crm.require(p_company_id, 'crm.write', 'logging an activity');
  if p_kind is null then
    raise exception 'crm_bad_activity: an activity has a kind';
  end if;
  if p_source_ref is not null and p_source is null then
    raise exception 'crm_bad_activity: an identifier at a source (%) needs the source it is an identifier of', p_source_ref;
  end if;

  -- Read from elsewhere, and already written: the row that is there.
  if p_source is not null then
    select * into v_row from crm.activities a
     where a.company_id = p_company_id and a.source = p_source and a.source_ref = p_source_ref;
    if found then
      return v_row;
    end if;
  end if;

  insert into crm.activities (company_id, contact_id, deal_id, kind, actor, occurred_at, subject, body,
                              link, payload, source, source_ref)
  values (p_company_id, p_contact_id, p_deal_id, p_kind, p_actor, coalesce(p_occurred_at, now()),
          p_subject, p_body, p_link, coalesce(p_payload, '{}'::jsonb), p_source, p_source_ref)
  on conflict (company_id, source, source_ref) where source is not null do nothing
  returning * into v_row;

  if v_row.id is null then
    -- Two writers of the same import at once: the other one's row.
    select * into v_row from crm.activities a
     where a.company_id = p_company_id and a.source = p_source and a.source_ref = p_source_ref;
  end if;
  return v_row;
end;
$$;

comment on function crm.log_activity(uuid, uuid, crm.activity_kind, text, text, uuid, text, timestamptz, text, jsonb, text, text) is
  'Writes one activity of a contact, optionally about one deal of the same company, and moves the card''s last_activity_at. An activity read from elsewhere names its source and its identifier there: the same pair a second time writes nothing and returns the activity already kept, which is what makes an import idempotent. Needs crm.write.';

create or replace function crm.join_segment(
  p_company_id uuid,
  p_segment_id uuid,
  p_contact_id uuid,
  p_added_by   text default null,
  p_note       text default null
)
returns crm.segment_members
language plpgsql
as $$
declare
  v_row crm.segment_members%rowtype;
begin
  perform crm.require(p_company_id, 'crm.write', 'putting a contact in a segment');
  insert into crm.segment_members (company_id, segment_id, contact_id, added_by, note)
  values (p_company_id, p_segment_id, p_contact_id, p_added_by, p_note)
  on conflict (company_id, segment_id, contact_id) do update
     set left_at   = null,
         joined_at = case when crm.segment_members.left_at is null then crm.segment_members.joined_at else now() end,
         added_by  = case when crm.segment_members.left_at is null
                          then coalesce(crm.segment_members.added_by, excluded.added_by)
                          else coalesce(excluded.added_by, crm.segment_members.added_by) end,
         note      = coalesce(excluded.note, crm.segment_members.note)
   where crm.segment_members.company_id = excluded.company_id
  returning * into v_row;
  if v_row.id is null then
    raise exception 'crm_unknown_segment: segment % is not a segment of company %', p_segment_id, p_company_id;
  end if;
  return v_row;
end;
$$;

comment on function crm.join_segment(uuid, uuid, uuid, text, text) is
  'Puts a contact in a segment of the same company. A contact who had left joins again on the same row: left_at goes back to null and joined_at is the day of the return. A contact already in it stays as it is, with the note replaced when one is given. Needs crm.write.';

create or replace function crm.leave_segment(p_company_id uuid, p_segment_id uuid, p_contact_id uuid)
returns crm.segment_members
language plpgsql
as $$
declare
  v_row crm.segment_members%rowtype;
begin
  perform crm.require(p_company_id, 'crm.write', 'taking a contact out of a segment');
  update crm.segment_members s
     set left_at = coalesce(s.left_at, now())
   where s.company_id = p_company_id and s.segment_id = p_segment_id and s.contact_id = p_contact_id
  returning * into v_row;
  if not found then
    raise exception 'crm_not_a_member: contact % was never in segment %', p_contact_id, p_segment_id;
  end if;
  return v_row;
end;
$$;

comment on function crm.leave_segment(uuid, uuid, uuid) is
  'Takes a contact out of a segment by setting left_at; the row stays, so the membership is remembered. Leaving twice keeps the first date. Refuses a contact that was never in it, crm_not_a_member. Needs crm.write.';

create or replace function crm.open_deal(
  p_company_id    uuid,
  p_pipeline_id   uuid,
  p_contact_id    uuid,
  p_title         text,
  p_amount        numeric default null,
  p_currency_code char(3) default null,
  p_expected_on   date default null,
  p_external_url  text default null,
  p_owner         text default null
)
returns crm.deals
language plpgsql
as $$
declare
  v_stage    crm.stages%rowtype;
  v_currency char(3);
  v_deal     crm.deals%rowtype;
begin
  perform crm.require(p_company_id, 'crm.write', 'opening a deal');
  if nullif(btrim(p_title), '') is null then
    raise exception 'crm_bad_deal: a deal has a title';
  end if;
  if not exists (select 1 from crm.pipelines p where p.id = p_pipeline_id and p.company_id = p_company_id) then
    raise exception 'crm_unknown_pipeline: pipeline % is not a pipeline of company %', p_pipeline_id, p_company_id;
  end if;
  select * into v_stage from crm.stages s
   where s.pipeline_id = p_pipeline_id and s.outcome = 'open'
   order by s.position
   limit 1;
  if not found then
    raise exception 'crm_pipeline_without_open_stage: pipeline % has no open stage for a deal to start at', p_pipeline_id;
  end if;

  -- An amount is in a currency: the one given, or the company's own.
  if p_amount is not null then
    v_currency := coalesce(p_currency_code, (select c.currency_code from public.companies c where c.id = p_company_id));
  else
    v_currency := p_currency_code;
  end if;

  insert into crm.deals (company_id, pipeline_id, stage_id, contact_id, title, amount, currency_code,
                         expected_on, external_url, owner)
  values (p_company_id, p_pipeline_id, v_stage.id, p_contact_id, btrim(p_title), p_amount, v_currency,
          p_expected_on, p_external_url, p_owner)
  returning * into v_deal;

  perform crm.log_activity(p_company_id, p_contact_id, 'system', 'opened at ' || v_stage.name,
                           null, v_deal.id, p_owner, null, null,
                           jsonb_build_object('stage_id', v_stage.id));
  return v_deal;
end;
$$;

comment on function crm.open_deal(uuid, uuid, uuid, text, numeric, char, date, text, text) is
  'Opens a deal with a contact at the first open stage of a pipeline of the same company, and logs it as a system activity. An amount given without a currency is in the company''s own currency. Refuses a pipeline with no open stage, crm_pipeline_without_open_stage. Needs crm.write.';

create or replace function crm.move_deal(p_company_id uuid, p_deal_id uuid, p_stage_id uuid)
returns crm.deals
language plpgsql
as $$
declare
  v_deal   crm.deals%rowtype;
  v_from   crm.stages%rowtype;
  v_stage  crm.stages%rowtype;
  v_entity uuid;
  v_type   public.contact_type;
  v_n      integer;
begin
  perform crm.require(p_company_id, 'crm.write', 'moving a deal');
  select * into v_deal from crm.deals d where d.id = p_deal_id and d.company_id = p_company_id for update;
  if not found then
    raise exception 'crm_unknown_deal: deal % is not a deal of company %', p_deal_id, p_company_id;
  end if;
  select * into v_stage from crm.stages s where s.id = p_stage_id and s.pipeline_id = v_deal.pipeline_id;
  if not found then
    raise exception 'crm_stage_not_in_pipeline: stage % is not a stage of the pipeline deal % moves in', p_stage_id, v_deal.title;
  end if;
  if v_stage.id = v_deal.stage_id then
    return v_deal;
  end if;
  select * into v_from from crm.stages s where s.id = v_deal.stage_id;

  update crm.deals d
     set stage_id       = v_stage.id,
         closed_at      = case when v_stage.outcome = 'open' then null else now() end,
         closed_outcome = case when v_stage.outcome = 'open' then null else v_stage.outcome end
   where d.id = v_deal.id
  returning * into v_deal;

  -- A deal won makes its party a customer: the organisation at the root of
  -- the contact's chain, which is the row an invoice is issued to.
  if v_stage.outcome = 'won' then
    v_entity := public.commercial_entity(v_deal.contact_id);
    select c.contact_type into v_type from public.contacts c where c.id = v_entity and c.company_id = p_company_id;
    if v_type in ('other', 'supplier') then
      update public.contacts c
         set contact_type = case c.contact_type when 'other' then 'customer'::public.contact_type
                                                 else 'both'::public.contact_type end
       where c.id = v_entity and c.company_id = p_company_id;
      get diagnostics v_n = row_count;
      if v_n = 0 then
        raise exception 'crm_not_allowed: winning deal % makes its party a customer, which needs contacts.write', v_deal.title
          using errcode = '42501';
      end if;
    end if;
  end if;

  perform crm.log_activity(p_company_id, v_deal.contact_id, 'system', 'moved to ' || v_stage.name,
                           null, v_deal.id, null, null, null,
                           jsonb_build_object('from_stage_id', v_from.id, 'from_stage', v_from.name,
                                              'to_stage_id', v_stage.id, 'to_stage', v_stage.name,
                                              'outcome', v_stage.outcome));
  return v_deal;
end;
$$;

comment on function crm.move_deal(uuid, uuid, uuid) is
  'Moves a deal to another stage of its pipeline and logs it as a system activity. Reaching a won or a lost stage closes the deal with its date and its outcome; going back to an open stage opens it again. A deal won makes the organisation at the root of its contact''s chain a customer — other becomes customer, supplier becomes both — which needs contacts.write. The same stage again changes nothing. Needs crm.write.';

create or replace function crm.card_of(p_company_id uuid, p_contact_id uuid)
returns jsonb
language plpgsql
stable
as $$
declare
  v_contact public.contacts%rowtype;
  v_out     jsonb;
begin
  perform crm.require(p_company_id, 'crm.read', 'reading a card');
  select * into v_contact from public.contacts c where c.id = p_contact_id and c.company_id = p_company_id;
  if not found then
    raise exception 'crm_unknown_contact: contact % is not a contact of company %', p_contact_id, p_company_id;
  end if;

  select jsonb_build_object(
    'contact', jsonb_build_object(
      'id', v_contact.id, 'name', v_contact.name, 'is_company', v_contact.is_company,
      'contact_type', v_contact.contact_type, 'parent_id', v_contact.parent_id,
      'email', v_contact.email, 'phone', v_contact.phone, 'city', v_contact.city,
      'country', v_contact.country, 'language', v_contact.language,
      'vat_number', v_contact.vat_number, 'active', v_contact.active),
    'organisation', (select jsonb_build_object('id', o.id, 'name', o.name, 'contact_type', o.contact_type)
                       from public.contacts o
                      where o.id = v_contact.parent_id and o.company_id = p_company_id),
    'card', (select to_jsonb(k) from crm.cards k where k.contact_id = p_contact_id and k.company_id = p_company_id),
    'segments', coalesce((select jsonb_agg(jsonb_build_object('id', s.id, 'slug', s.slug, 'name', s.name,
                                                               'kind', s.kind, 'joined_at', m.joined_at)
                                           order by s.slug)
                            from crm.segment_members m
                            join crm.segments s on s.id = m.segment_id and s.company_id = m.company_id
                           where m.contact_id = p_contact_id and m.company_id = p_company_id
                             and m.left_at is null), '[]'::jsonb),
    -- An organisation's deals include those with its people.
    'deals', coalesce((select jsonb_agg(jsonb_build_object('id', d.id, 'title', d.title, 'contact_id', d.contact_id,
                                                            'pipeline_id', d.pipeline_id, 'stage_id', d.stage_id,
                                                            'stage', st.name, 'amount', d.amount,
                                                            'currency_code', d.currency_code,
                                                            'expected_on', d.expected_on, 'owner', d.owner)
                                         order by d.created_at)
                         from crm.deals d
                         join crm.stages st on st.id = d.stage_id
                        where d.company_id = p_company_id and d.closed_at is null
                          and (d.contact_id = p_contact_id
                               or d.contact_id in (select c.id from public.contacts c
                                                    where c.parent_id = p_contact_id and c.company_id = p_company_id))),
                      '[]'::jsonb),
    'activities', coalesce((select jsonb_agg(to_jsonb(a) order by a.occurred_at desc, a.created_at desc)
                              from (select * from crm.activities a
                                     where a.company_id = p_company_id and a.contact_id = p_contact_id
                                     order by a.occurred_at desc, a.created_at desc
                                     limit 20) a), '[]'::jsonb)
  ) into v_out;
  return v_out;
end;
$$;

comment on function crm.card_of(uuid, uuid) is
  'Everything on one contact, as one JSON object: the contact as the socle holds it, its organisation, its card, the segments it is in now, the open deals with it — and, for an organisation, with its people — and its 20 latest activities. Needs crm.read.';

create or replace function crm.search_cards(
  p_company_id     uuid,
  p_query          text default null,
  p_status         crm.relationship_status default null,
  p_segment_id     uuid default null,
  p_stage_id       uuid default null,
  p_country        char(2) default null,
  p_language       char(2) default null,
  p_owner          text default null,
  p_no_outbound    boolean default null,
  p_active_since   timestamptz default null,
  p_inactive_since timestamptz default null,
  p_limit          integer default 50
)
returns table (
  contact_id        uuid,
  name              text,
  is_company        boolean,
  organisation_name text,
  email             text,
  country           char(2),
  status            crm.relationship_status,
  priority          crm.priority,
  owner             text,
  last_activity_at  timestamptz,
  segments          text[]
)
language sql
stable
as $$
  select c.id,
         c.name,
         c.is_company,
         o.name,
         c.email,
         coalesce(c.country, o.country)::char(2),
         k.status,
         k.priority,
         k.owner,
         k.last_activity_at,
         array(select s.slug
                 from crm.segment_members m
                 join crm.segments s on s.id = m.segment_id and s.company_id = m.company_id
                where m.contact_id = c.id and m.company_id = c.company_id and m.left_at is null
                order by s.slug)
    from crm.cards k
    join public.contacts c on c.id = k.contact_id and c.company_id = k.company_id
    left join public.contacts o on o.id = c.parent_id and o.company_id = c.company_id
   where k.company_id = p_company_id
     and c.merged_into is null
     and (p_query is null
          or c.name ilike '%' || p_query || '%'
          or c.email ilike '%' || p_query || '%'
          or o.name ilike '%' || p_query || '%')
     and (p_status is null or k.status = p_status)
     and (p_segment_id is null
          or exists (select 1 from crm.segment_members m
                      where m.segment_id = p_segment_id and m.contact_id = c.id
                        and m.company_id = c.company_id and m.left_at is null))
     and (p_stage_id is null
          or exists (select 1 from crm.deals d
                      where d.stage_id = p_stage_id and d.contact_id = c.id and d.company_id = c.company_id))
     and (p_country is null or coalesce(c.country, o.country) = upper(p_country))
     and (p_language is null or coalesce(c.language, o.language) = lower(p_language))
     and (p_owner is null or k.owner = p_owner)
     and (p_no_outbound is null or k.no_outbound = p_no_outbound)
     and (p_active_since is null or k.last_activity_at >= p_active_since)
     and (p_inactive_since is null or k.last_activity_at is null or k.last_activity_at < p_inactive_since)
   order by k.last_activity_at desc nulls last, c.name, c.id
   limit greatest(coalesce(p_limit, 50), 0);
$$;

comment on function crm.search_cards(uuid, text, crm.relationship_status, uuid, uuid, char, char, text, boolean, timestamptz, timestamptz, integer) is
  'The cards of a company, filtered: a text found in the name, the e-mail or the organisation''s name, a status, a segment the contact is in now, a stage one of its deals is at, a country and a language (the contact''s, or its organisation''s where it has none), an owner, no_outbound, active since or inactive since a moment. Every filter is optional. Merged contacts are left out. Most recently active first, at most p_limit rows (50).';

-- ---------------------------------------------------------------------------
-- The conventions the socle looks a module up by
-- ---------------------------------------------------------------------------

-- No `crm.can_disable()`: turning the module off hides the rows and turning
-- it back on gives them back, as `budgets` does.

create or replace function crm.archive_tables()
returns table (
  table_name  text,
  disposition text,
  reason      text,
  via_column  text,
  via_table   text,
  load_order  integer
)
language sql
immutable
as $$
  values
    ('pipelines'::text,  'exported'::text, null::text, null::text, null::text, 1),
    ('stages',           'exported',       null,       null,       null,       2),
    ('segments',         'exported',       null,       null,       null,       3),
    ('cards',            'exported',       null,       null,       null,       4),
    ('segment_members',  'exported',       null,       null,       null,       5),
    ('deals',            'exported',       null,       null,       null,       6),
    ('activities',       'exported',       null,       null,       null,       7);
$$;

comment on function crm.archive_tables() is
  'What an archive of one company does with each table of this module: all seven travel — a relationship is the company''s as much as its books. Read by `public.company_archive_tables()`.';

-- ---------------------------------------------------------------------------
-- Capabilities
--
-- Reading goes to whoever reads the books, client included. Writing is the
-- module's own word: a member who keeps the ledger does not, by that alone,
-- write to the relationships, and the reverse.
-- ---------------------------------------------------------------------------

insert into public.capabilities (code, area, description) values
  ('crm.read',  'crm', 'Read the cards, segments, pipelines, deals and activities of a company.'),
  ('crm.write', 'crm', 'Create and change cards, segments, pipelines and deals, and log activities.')
on conflict (code) do update set area = excluded.area, description = excluded.description;

insert into public.role_capabilities (role, capability) values
  ('viewer'::public.member_role,     'crm.read'),
  ('accountant'::public.member_role, 'crm.read'),
  ('accountant'::public.member_role, 'crm.write'),
  ('owner'::public.member_role,      'crm.read'),
  ('owner'::public.member_role,      'crm.write')
on conflict do nothing;

-- The client preset holds what a viewer holds. Its label is read from the
-- catalogue rather than written as a literal, so this file applies on a socle
-- older than the preset.
insert into public.role_capabilities (role, capability)
select e.enumlabel::text::public.member_role, 'crm.read'
  from pg_catalog.pg_enum e
  join pg_catalog.pg_type t on t.oid = e.enumtypid
  join pg_catalog.pg_namespace n on n.oid = t.typnamespace
 where n.nspname = 'public' and t.typname = 'member_role' and e.enumlabel = 'client'
on conflict do nothing;

-- ---------------------------------------------------------------------------
-- Row level security
-- ---------------------------------------------------------------------------

alter table crm.cards           enable row level security;
alter table crm.segments        enable row level security;
alter table crm.segment_members enable row level security;
alter table crm.pipelines       enable row level security;
alter table crm.stages          enable row level security;
alter table crm.deals           enable row level security;
alter table crm.activities      enable row level security;

do $$
declare
  v_table text;
begin
  foreach v_table in array array['cards', 'segments', 'segment_members', 'pipelines', 'stages', 'deals', 'activities'] loop
    execute format(
      'create policy %I on crm.%I for select using (public.module_enabled(company_id, %L) and public.has_capability(company_id, %L))',
      'crm_' || v_table || '_select', v_table, 'crm', 'crm.read');
    execute format(
      'create policy %I on crm.%I for all using (public.module_enabled(company_id, %L) and public.has_capability(company_id, %L)) '
      'with check (public.module_enabled(company_id, %L) and public.has_capability(company_id, %L))',
      'crm_' || v_table || '_write', v_table, 'crm', 'crm.write', 'crm', 'crm.write');
  end loop;
end;
$$;

-- ---------------------------------------------------------------------------
-- Privileges, by name
-- ---------------------------------------------------------------------------

grant usage on schema crm to anon, authenticated, service_role;

grant select, insert, update, delete on table
  crm.cards,
  crm.segments,
  crm.segment_members,
  crm.pipelines,
  crm.stages,
  crm.deals,
  crm.activities
to authenticated, service_role;

revoke execute on function crm.require(uuid, text, text) from public, anon;
revoke execute on function crm.upsert_card(uuid, uuid, jsonb) from public, anon;
revoke execute on function crm.log_activity(uuid, uuid, crm.activity_kind, text, text, uuid, text, timestamptz, text, jsonb, text, text) from public, anon;
revoke execute on function crm.join_segment(uuid, uuid, uuid, text, text) from public, anon;
revoke execute on function crm.leave_segment(uuid, uuid, uuid) from public, anon;
revoke execute on function crm.open_deal(uuid, uuid, uuid, text, numeric, char, date, text, text) from public, anon;
revoke execute on function crm.move_deal(uuid, uuid, uuid) from public, anon;
revoke execute on function crm.card_of(uuid, uuid) from public, anon;
revoke execute on function crm.search_cards(uuid, text, crm.relationship_status, uuid, uuid, char, char, text, boolean, timestamptz, timestamptz, integer) from public, anon;
revoke execute on function crm.archive_tables() from public, anon;

grant execute on function crm.require(uuid, text, text) to authenticated, service_role;
grant execute on function crm.upsert_card(uuid, uuid, jsonb) to authenticated, service_role;
grant execute on function crm.log_activity(uuid, uuid, crm.activity_kind, text, text, uuid, text, timestamptz, text, jsonb, text, text) to authenticated, service_role;
grant execute on function crm.join_segment(uuid, uuid, uuid, text, text) to authenticated, service_role;
grant execute on function crm.leave_segment(uuid, uuid, uuid) to authenticated, service_role;
grant execute on function crm.open_deal(uuid, uuid, uuid, text, numeric, char, date, text, text) to authenticated, service_role;
grant execute on function crm.move_deal(uuid, uuid, uuid) to authenticated, service_role;
grant execute on function crm.card_of(uuid, uuid) to authenticated, service_role;
grant execute on function crm.search_cards(uuid, text, crm.relationship_status, uuid, uuid, char, char, text, boolean, timestamptz, timestamptz, integer) to authenticated, service_role;
grant execute on function crm.archive_tables() to authenticated, service_role;

-- The trigger bodies are fired by their tables and called by nobody.
revoke execute on function crm.guard_segment_parent() from public, anon, authenticated, service_role;
revoke execute on function crm.touch_card() from public, anon, authenticated, service_role;
revoke execute on function crm.fold_card_on_merge() from public, anon, authenticated, service_role;
revoke execute on function crm.fold_membership_on_merge() from public, anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- The registry row
-- ---------------------------------------------------------------------------

insert into public.modules (code, name, description, schema_name, version, status, requires_socle_min)
values (
  'crm',
  'Customer relationship',
  'The record of a relationship, kept beside the books on the same contacts: cards, segments, pipelines, deals and activities, exposed as functions an agent or a screen calls. A deal won makes its party a customer. Knows no country, and writes nothing to the ledger.',
  'crm',
  '0.1.0',
  'available',
  '20261019150000'
)
on conflict (code) do update set
  name               = excluded.name,
  description        = excluded.description,
  schema_name        = excluded.schema_name,
  version            = excluded.version,
  status             = excluded.status,
  requires_socle_min = excluded.requires_socle_min;
