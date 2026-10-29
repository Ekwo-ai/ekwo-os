-- Ekwo — the `consolidation` module: a group of companies, and who is in it.
--
-- This is the ground the rest of consolidation stands on. A group belongs to
-- the company that consolidates it — the parent, the one that enables the
-- module — and names the other companies of the installation it holds, each
-- for a period: the method it is consolidated by, the percentage of interest
-- held, and from that the share of its figures the group takes in. The
-- eliminations, the translation of currencies and the consolidated statements
-- read this and come after; this file computes nothing.
--
-- **The parent is always in, at 100 %.** It is the group's own company and is
-- never a row of `members`: `perimeter()` returns it first, and a member row
-- naming it is refused.
--
-- **A membership is a period.** `entered_on` is the first day a company is in
-- the perimeter and `left_on` the last, null while it stays. A change of the
-- interest held, or of the method, closes one row and opens the next, so the
-- perimeter of any date is the rows whose period holds it — and two rows of
-- one company in one group never overlap, which a trigger refuses.
--
-- **The integration rate is derived, never typed.** `full` takes 100 % of a
-- member's figures, `proportional` the percentage of interest, `equity` none
-- line by line (the group carries its share of the equity instead). One rule,
-- in a generated column, so a rate cannot disagree with its method.
--
-- **Nothing is written in a member company.** The module reads the members'
-- books, under their own row level security, and keeps its own rows in its own
-- schema. So the person who builds a group must be able to read the books of
-- every company they put in it — `entries.read` there, as a member or through a
-- key — and the trigger refuses a member they cannot read. Whoever reads the
-- group later is held to the same: `require_readable()` names the first member
-- whose books the caller cannot read, rather than letting a consolidation come
-- out quietly short of a company.
--
-- **No country, no currency, no language.** The presentation currency of a
-- group is a code of `ekwo.currencies`, given or taken from the parent.
--
-- **Written for the socle in `ekwo`.** Every name of the socle is qualified
-- with its schema, and every function carries its own path — this module's
-- schema, then `ekwo` — so it finds the socle whatever path the request came
-- in with. Hence `requires_socle_min`: the move of the socle to `ekwo`.

create schema consolidation;

comment on schema consolidation is
  'Ekwo module `consolidation`: groups of companies of the installation, who is in each and for which period, by which method and at which percentage of interest. Reads the members'' books under their own row level security, and writes nothing in them.';

create type consolidation.method as enum ('full', 'proportional', 'equity');

comment on type consolidation.method is
  'How a member is consolidated: full (every figure, 100 %, the share of others shown apart), proportional (the share of interest held, line by line), equity (no line of its own: the group carries its share of the member''s equity).';

-- ---------------------------------------------------------------------------
-- Groups
-- ---------------------------------------------------------------------------

create table consolidation.groups (
  id            uuid primary key default gen_random_uuid(),
  company_id    uuid not null references ekwo.companies(id) on delete cascade,
  code          text not null,
  name          text not null,
  currency_code char(3) not null references ekwo.currencies(code),
  notes         text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  unique (company_id, code),
  constraint consolidation_groups_code check (code ~ '^[a-z0-9][a-z0-9_-]{0,62}$')
);

comment on table consolidation.groups is
  'A group of companies, owned by the company that consolidates it — its parent, which is always in the perimeter at 100 % and is never a row of members.';
comment on column consolidation.groups.code is
  'The caller''s own key for the group, unique in the parent: create_group() with a code that exists returns that group.';
comment on column consolidation.groups.currency_code is
  'The currency the group presents its consolidated figures in. The parent''s own when create_group() is given none.';

create unique index consolidation_groups_id_company_idx on consolidation.groups (id, company_id);
create index consolidation_groups_currency_idx on consolidation.groups (currency_code);

create trigger consolidation_groups_set_updated_at
  before update on consolidation.groups
  for each row execute function ekwo.set_updated_at();

-- ---------------------------------------------------------------------------
-- Members
-- ---------------------------------------------------------------------------

create table consolidation.members (
  id                uuid primary key default gen_random_uuid(),
  group_id          uuid not null,
  company_id        uuid not null references ekwo.companies(id) on delete cascade,
  member_company_id uuid not null references ekwo.companies(id) on delete cascade,
  method            consolidation.method not null,
  ownership_rate    numeric(7, 4) not null,
  integration_rate  numeric(7, 4) not null generated always as (
    case method
      when 'full' then 100
      when 'proportional' then ownership_rate
      else 0
    end
  ) stored,
  entered_on        date not null,
  left_on           date,
  notes             text,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  -- The parent leads the key, so a row naming the group of another company
  -- meets the foreign key below and never this constraint.
  unique (company_id, group_id, member_company_id, entered_on),
  foreign key (group_id, company_id) references consolidation.groups(id, company_id) on delete cascade,
  constraint consolidation_members_ownership check (ownership_rate > 0 and ownership_rate <= 100),
  constraint consolidation_members_period check (left_on is null or left_on >= entered_on),
  constraint consolidation_members_not_the_parent check (member_company_id <> company_id)
);

comment on table consolidation.members is
  'One company of the installation in one group, for one period: from entered_on to left_on included, null while it stays. A change of interest or of method closes the row and opens the next; two periods of one company in one group never overlap.';
comment on column consolidation.members.company_id is
  'The parent — the company the group belongs to, whose module and capabilities decide who sees and writes the row. The member itself is member_company_id.';
comment on column consolidation.members.member_company_id is
  'The company held. Its books are read under its own row level security, and nothing is ever written in it.';
comment on column consolidation.members.ownership_rate is
  'The percentage of interest the group holds in the member, above 0 and up to 100.';
comment on column consolidation.members.integration_rate is
  'The percentage of the member''s figures the group takes in line by line, derived from the method: 100 for full, the ownership rate for proportional, 0 for equity.';

create index consolidation_members_group_company_idx on consolidation.members (group_id, company_id);
create index consolidation_members_company_idx on consolidation.members (company_id);
create index consolidation_members_member_idx on consolidation.members (member_company_id, entered_on);

create trigger consolidation_members_set_updated_at
  before update on consolidation.members
  for each row execute function ekwo.set_updated_at();

-- ---------------------------------------------------------------------------
-- The guard of a membership, for every way in
-- ---------------------------------------------------------------------------

create or replace function consolidation.guard_member()
returns trigger
language plpgsql
set search_path = consolidation, ekwo, pg_temp
as $$
begin
  if (tg_op = 'INSERT' or new.member_company_id is distinct from old.member_company_id)
     and not ekwo.is_installer()
     and not ekwo.has_capability(new.member_company_id, 'entries.read') then
    -- The same sentence for a company that exists and one that does not: the
    -- refusal tells a stranger nothing about the companies of others.
    raise exception 'consolidation_member_unreadable: you cannot read the books of that company, so it cannot be put in a group'
      using errcode = '42501';
  end if;
  if exists (
    select 1
      from consolidation.members m
     where m.group_id = new.group_id
       and m.member_company_id = new.member_company_id
       and m.id <> new.id
       and daterange(m.entered_on, m.left_on, '[]') && daterange(new.entered_on, new.left_on, '[]')
  ) then
    raise exception 'consolidation_member_overlap: company % is already in this group for part of that period; close its current period first', new.member_company_id
      using errcode = '23P01';
  end if;
  return new;
end;
$$;

comment on function consolidation.guard_member() is
  'Refuses a member the writer cannot read (entries.read in that company) when it is put in the group — closing its period later needs no more than consolidation.write — and a period that overlaps another of the same company in the same group. A trigger, so the rule holds for psql and PostgREST as for the functions.';

create trigger consolidation_members_guard
  before insert or update of member_company_id, entered_on, left_on, group_id on consolidation.members
  for each row execute function consolidation.guard_member();

-- ---------------------------------------------------------------------------
-- The functions an agent or a screen calls
-- ---------------------------------------------------------------------------

create or replace function consolidation.require(p_company_id uuid, p_capability text, p_what text)
returns void
language plpgsql
stable
set search_path = consolidation, ekwo, pg_temp
as $$
begin
  if p_company_id is null
     or not ekwo.module_is_enabled(p_company_id, 'consolidation')
     or (not ekwo.is_installer() and not ekwo.module_enabled(p_company_id, 'consolidation')) then
    raise exception 'consolidation_module_not_enabled: the consolidation module is not enabled on company %', p_company_id
      using errcode = '42501';
  end if;
  if not ekwo.is_installer() and not ekwo.has_capability(p_company_id, p_capability) then
    raise exception 'consolidation_not_allowed: % needs %', p_what, p_capability
      using errcode = '42501';
  end if;
end;
$$;

comment on function consolidation.require(uuid, text, text) is
  'Raises consolidation_module_not_enabled when the module is off for the company or the caller is not a member of it, and consolidation_not_allowed when the caller does not hold the capability. The first lines of every function of this module; the policies still decide every row.';

create or replace function consolidation.create_group(
  p_company_id    uuid,
  p_code          text,
  p_name          text,
  p_currency_code char(3) default null,
  p_notes         text default null
)
returns consolidation.groups
language plpgsql
set search_path = consolidation, ekwo, pg_temp
as $$
declare
  v_group consolidation.groups;
begin
  perform consolidation.require(p_company_id, 'consolidation.write', 'creating a group');

  select * into v_group from consolidation.groups where company_id = p_company_id and code = p_code;
  if found then
    return v_group;
  end if;

  insert into consolidation.groups (company_id, code, name, currency_code, notes)
  select p_company_id, p_code, p_name, coalesce(p_currency_code, c.currency_code), p_notes
    from ekwo.companies c
   where c.id = p_company_id
  returning * into v_group;

  return v_group;
end;
$$;

comment on function consolidation.create_group(uuid, text, text, char, text) is
  'Creates a group owned by the company, in the currency given or the company''s own. Idempotent by code: a code the company already has returns that group, unchanged.';

create or replace function consolidation.add_member(
  p_company_id        uuid,
  p_group_id          uuid,
  p_member_company_id uuid,
  p_method            consolidation.method,
  p_ownership_rate    numeric,
  p_entered_on        date,
  p_left_on           date default null,
  p_notes             text default null
)
returns consolidation.members
language plpgsql
set search_path = consolidation, ekwo, pg_temp
as $$
declare
  v_member consolidation.members;
begin
  perform consolidation.require(p_company_id, 'consolidation.write', 'putting a company in a group');

  if not exists (select 1 from consolidation.groups g where g.id = p_group_id and g.company_id = p_company_id) then
    raise exception 'consolidation_group_not_found: no group % in company %', p_group_id, p_company_id
      using errcode = 'P0002';
  end if;
  if p_member_company_id = p_company_id then
    raise exception 'consolidation_member_is_the_parent: the company a group belongs to is always in it, at 100 %%, and is not added'
      using errcode = '22023';
  end if;

  select * into v_member
    from consolidation.members m
   where m.group_id = p_group_id
     and m.member_company_id = p_member_company_id
     and m.entered_on = p_entered_on;
  if found then
    if v_member.method = p_method
       and v_member.ownership_rate = p_ownership_rate
       and v_member.left_on is not distinct from p_left_on then
      return v_member;
    end if;
    raise exception 'consolidation_member_exists: company % already enters this group on % with other terms; close that period and open another', p_member_company_id, p_entered_on
      using errcode = '23505';
  end if;

  insert into consolidation.members
    (group_id, company_id, member_company_id, method, ownership_rate, entered_on, left_on, notes)
  values
    (p_group_id, p_company_id, p_member_company_id, p_method, p_ownership_rate, p_entered_on, p_left_on, p_notes)
  returning * into v_member;

  return v_member;
end;
$$;

comment on function consolidation.add_member(uuid, uuid, uuid, consolidation.method, numeric, date, date, text) is
  'Puts a company in a group for a period, by a method and at a percentage of interest. The same call twice returns the first row; the same company and entry date with other terms is refused, as is a period overlapping another and a company whose books the caller cannot read.';

create or replace function consolidation.end_membership(
  p_company_id uuid,
  p_member_id  uuid,
  p_left_on    date
)
returns consolidation.members
language plpgsql
set search_path = consolidation, ekwo, pg_temp
as $$
declare
  v_member consolidation.members;
begin
  perform consolidation.require(p_company_id, 'consolidation.write', 'taking a company out of a group');

  update consolidation.members m
     set left_on = p_left_on
   where m.id = p_member_id
     and m.company_id = p_company_id
  returning * into v_member;

  if not found then
    raise exception 'consolidation_member_not_found: no membership % in company %', p_member_id, p_company_id
      using errcode = 'P0002';
  end if;

  return v_member;
end;
$$;

comment on function consolidation.end_membership(uuid, uuid, date) is
  'Closes a period: p_left_on is the last day the company is in the perimeter. A change of interest or method is this, then add_member() from the next day.';

create or replace function consolidation.perimeter(
  p_company_id uuid,
  p_group_id   uuid,
  p_on         date default current_date
)
returns table (
  company_id       uuid,
  company_name     text,
  currency_code    char(3),
  is_parent        boolean,
  method           consolidation.method,
  ownership_rate   numeric,
  integration_rate numeric,
  entered_on       date,
  left_on          date,
  readable         boolean
)
language plpgsql
stable
set search_path = consolidation, ekwo, pg_temp
as $$
begin
  perform consolidation.require(p_company_id, 'consolidation.read', 'reading the perimeter of a group');

  if not exists (select 1 from consolidation.groups g where g.id = p_group_id and g.company_id = p_company_id) then
    raise exception 'consolidation_group_not_found: no group % in company %', p_group_id, p_company_id
      using errcode = 'P0002';
  end if;

  return query
    select p.id,
           p.name,
           p.currency_code,
           true,
           'full'::consolidation.method,
           100::numeric,
           100::numeric,
           null::date,
           null::date,
           true
      from ekwo.companies p
     where p.id = p_company_id
    union all
    select m.member_company_id,
           c.name,
           c.currency_code,
           false,
           m.method,
           m.ownership_rate,
           m.integration_rate,
           m.entered_on,
           m.left_on,
           ekwo.is_installer() or ekwo.has_capability(m.member_company_id, 'entries.read')
      from consolidation.members m
      left join ekwo.companies c on c.id = m.member_company_id
     where m.group_id = p_group_id
       and m.company_id = p_company_id
       and m.entered_on <= p_on
       and (m.left_on is null or m.left_on >= p_on)
     order by 4 desc, 2 nulls last, 1;
end;
$$;

comment on function consolidation.perimeter(uuid, uuid, date) is
  'The companies in a group on a date: the parent first, at 100 %, then every member whose period holds the date, with its method, interest and integration rate, and whether the caller can read its books. A member the caller cannot read comes with readable false, and with its name and currency null when the caller cannot see the company at all.';

create or replace function consolidation.require_readable(
  p_company_id uuid,
  p_group_id   uuid,
  p_from       date,
  p_to         date
)
returns void
language plpgsql
stable
set search_path = consolidation, ekwo, pg_temp
as $$
declare
  v_company uuid;
begin
  perform consolidation.require(p_company_id, 'consolidation.read', 'reading a group');

  if not ekwo.is_installer() and not ekwo.has_capability(p_company_id, 'entries.read') then
    raise exception 'consolidation_member_unreadable: you cannot read the books of company %, the parent of the group', p_company_id
      using errcode = '42501';
  end if;

  select m.member_company_id into v_company
    from consolidation.members m
   where m.group_id = p_group_id
     and m.company_id = p_company_id
     and m.entered_on <= p_to
     and (m.left_on is null or m.left_on >= p_from)
     and not (ekwo.is_installer() or ekwo.has_capability(m.member_company_id, 'entries.read'))
   order by m.entered_on, m.member_company_id
   limit 1;

  if found then
    raise exception 'consolidation_member_unreadable: you cannot read the books of company %, which is in the group between % and %', v_company, p_from, p_to
      using errcode = '42501';
  end if;
end;
$$;

comment on function consolidation.require_readable(uuid, uuid, date, date) is
  'Raises consolidation_member_unreadable, naming the company, when the caller cannot read the books of the parent or of a member in the perimeter at any time between the two dates. What every consolidated figure calls first, so that none comes out short of a company.';

-- ---------------------------------------------------------------------------
-- The conventions the socle looks a module up by
-- ---------------------------------------------------------------------------

-- No `consolidation.can_disable()`: turning the module off hides the groups
-- and turning it back on gives them back, as `budgets` does.

create or replace function consolidation.archive_tables()
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
set search_path = consolidation, ekwo, pg_temp
as $$
  values
    ('groups'::text, 'exported'::text, null::text, null::text, null::text, 1),
    ('members',      'excluded',
     'each row names another company of this installation by its id, which means nothing where the archive arrives; the perimeter is declared again there, once the companies it holds are there too',
     null, null, 2);
$$;

comment on function consolidation.archive_tables() is
  'What an archive of one company does with each table of this module: its groups travel, their members do not — they name other companies of the installation. Read by `ekwo.company_archive_tables()`.';

-- ---------------------------------------------------------------------------
-- Capabilities
--
-- Reading goes to whoever reads the books, client included. Writing is the
-- module's own word. Neither reaches into a member: the books of each member
-- are read with what the caller holds in that member.
-- ---------------------------------------------------------------------------

insert into ekwo.capabilities (code, area, description) values
  ('consolidation.read',  'consolidation', 'Read the groups of a company and who is in each.'),
  ('consolidation.write', 'consolidation', 'Create groups and change who is in each, by which method and at which percentage of interest.')
on conflict (code) do update set area = excluded.area, description = excluded.description;

insert into ekwo.role_capabilities (role, capability) values
  ('viewer'::ekwo.member_role,     'consolidation.read'),
  ('accountant'::ekwo.member_role, 'consolidation.read'),
  ('accountant'::ekwo.member_role, 'consolidation.write'),
  ('owner'::ekwo.member_role,      'consolidation.read'),
  ('owner'::ekwo.member_role,      'consolidation.write')
on conflict do nothing;

-- The client preset holds what a viewer holds. Its label is read from the
-- catalogue rather than written as a literal, so this file applies on a socle
-- older than the preset.
insert into ekwo.role_capabilities (role, capability)
select e.enumlabel::text::ekwo.member_role, 'consolidation.read'
  from pg_catalog.pg_enum e
  join pg_catalog.pg_type t on t.oid = e.enumtypid
  join pg_catalog.pg_namespace n on n.oid = t.typnamespace
 where n.nspname = 'ekwo' and t.typname = 'member_role' and e.enumlabel = 'client'
on conflict do nothing;

-- ---------------------------------------------------------------------------
-- Row level security
-- ---------------------------------------------------------------------------

alter table consolidation.groups  enable row level security;
alter table consolidation.members enable row level security;

do $$
declare
  v_table text;
begin
  foreach v_table in array array['groups', 'members'] loop
    execute format(
      'create policy %I on consolidation.%I for select using (ekwo.module_enabled(company_id, %L) and ekwo.has_capability(company_id, %L))',
      'consolidation_' || v_table || '_select', v_table, 'consolidation', 'consolidation.read');
    execute format(
      'create policy %I on consolidation.%I for all using (ekwo.module_enabled(company_id, %L) and ekwo.has_capability(company_id, %L)) '
      'with check (ekwo.module_enabled(company_id, %L) and ekwo.has_capability(company_id, %L))',
      'consolidation_' || v_table || '_write', v_table, 'consolidation', 'consolidation.write', 'consolidation', 'consolidation.write');
  end loop;
end;
$$;

-- ---------------------------------------------------------------------------
-- Privileges, by name
-- ---------------------------------------------------------------------------

grant usage on schema consolidation to anon, authenticated, service_role;

grant select, insert, update, delete on table
  consolidation.groups,
  consolidation.members
to authenticated, service_role;

revoke execute on function consolidation.require(uuid, text, text) from public, anon;
revoke execute on function consolidation.create_group(uuid, text, text, char, text) from public, anon;
revoke execute on function consolidation.add_member(uuid, uuid, uuid, consolidation.method, numeric, date, date, text) from public, anon;
revoke execute on function consolidation.end_membership(uuid, uuid, date) from public, anon;
revoke execute on function consolidation.perimeter(uuid, uuid, date) from public, anon;
revoke execute on function consolidation.require_readable(uuid, uuid, date, date) from public, anon;
revoke execute on function consolidation.archive_tables() from public, anon;

grant execute on function consolidation.require(uuid, text, text) to authenticated, service_role;
grant execute on function consolidation.create_group(uuid, text, text, char, text) to authenticated, service_role;
grant execute on function consolidation.add_member(uuid, uuid, uuid, consolidation.method, numeric, date, date, text) to authenticated, service_role;
grant execute on function consolidation.end_membership(uuid, uuid, date) to authenticated, service_role;
grant execute on function consolidation.perimeter(uuid, uuid, date) to authenticated, service_role;
grant execute on function consolidation.require_readable(uuid, uuid, date, date) to authenticated, service_role;
grant execute on function consolidation.archive_tables() to authenticated, service_role;

-- The trigger body is fired by its table and called by nobody.
revoke execute on function consolidation.guard_member() from public, anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- The registry row
-- ---------------------------------------------------------------------------

insert into ekwo.modules (code, name, description, schema_name, version, status, requires_socle_min)
values (
  'consolidation',
  'Consolidation',
  'Groups of companies of the installation: who is in each and for which period, by which method and at which percentage of interest, the share each brings in derived from them. Reads the members'' books under their own row level security, and writes nothing in them or to the ledger.',
  'consolidation',
  '0.1.0',
  'available',
  '20261028040000'
)
on conflict (code) do update set
  name = excluded.name,
  description = excluded.description,
  schema_name = excluded.schema_name,
  version = excluded.version,
  status = excluded.status,
  requires_socle_min = excluded.requires_socle_min;
