-- Ekwo OS — a company leaves an installation with its books, and arrives in
-- another one alive.
--
-- A firm keeps the books of N companies in one installation. That is the
-- normal case and the schema was shaped for it. It is also a trap if nothing
-- else is said: `pg_dump` takes the whole installation or nothing, so the one
-- company whose owner changes accountant cannot be handed its ledger — only
-- the firm's goodwill can. "The client owns the books" was a sentence.
--
-- This migration makes it a function, in four parts.
--
-- **1. What belongs to a company is read from the catalogue, not from a
-- list.** A table is *of a company* when it carries `company_id`, or reaches
-- `companies` by a foreign key, directly or through another such table.
-- `company_scoped_tables()` works that out from `pg_constraint` and
-- `pg_attribute`. `company_archive_registry` then says, table by table, one of
-- two things: `exported`, or `excluded` with a sentence saying why. A table
-- that is of a company and says neither is *unclassified*, and an export
-- refuses to run while one exists — so the day somebody adds a table and
-- forgets this file, the archive does not quietly become incomplete. It stops,
-- by name. A test asks the same question of every checkout.
--
-- A module has its own tables and follows the same rule without the socle
-- knowing it: the convention is `<schema>.archive_tables()`, looked up the way
-- `disable_module()` looks up `<schema>.can_disable()`. A function in the
-- module's schema rather than rows in the socle's table, because a module
-- migration may be applied on a socle that predates this file, where the table
-- does not exist yet.
--
-- **2. Leaving needs a right of its own, `company.export`, and runs as the
-- person who holds it.** Every export function is `security invoker`: it reads
-- what row level security lets its caller read, and there is no exemption for
-- the installer or for `service_role` — whoever holds the database already has
-- `pg_dump`. What row level security would do on its own, though, is hand back
-- *fewer rows and say nothing*: a member whose `bank.read` was revoked would
-- leave with books that have no bank in them and a manifest that looks whole.
-- So each table is counted twice — as the caller, and by a definer function
-- that answers a number and nothing else — and a difference is
-- `export_incomplete`, by table.
--
-- The two readers are `stable`, so they read the snapshot of the statement
-- that calls them, and `export_company()` calls both in one statement: an
-- archive whose lines were read a moment after their entries is one that fails
-- on arrival, after the company has left. Read table by table, they need a
-- repeatable read transaction around them, which is what the CLI opens.
--
-- `owner` holds it, and so does `client`. The reasoning is in
-- `docs/decisions.md` under this date; the short form is that a right to leave
-- which only the firm can exercise is not a right of the client.
--
-- **3. The archive is rows, as JSON, table by table.** One object per row with
-- the column names the schema documents; decimals as strings, so that no
-- reader rounds an amount by parsing it; timestamps in UTC; rows in primary
-- key order. The checksum of a table is the sha256 of its rows written one per
-- line, which is also exactly the file the CLI writes — `shasum` checks an
-- archive without Ekwo. `docs/company-archive.md` is the format.
--
-- **4. Arriving is one call, by whoever may create a company here.**
-- `import_company()` does not replay the books through `post_entry()`: a
-- posted entry is immutable and numbered, and replaying it would draw new
-- numbers, stamp today's date on every act of the audit trail and ask the
-- period locks for permission to rebuild what they protect. It inserts the
-- rows, with the user triggers of the tables it fills switched off for the
-- length of its own transaction — which takes a lock that makes every other
-- writer of those tables wait, so nobody books without guards meanwhile —
-- foreign keys left on, and then checks what the triggers would have
-- guaranteed: every row belongs to the company that arrived, no reference
-- crosses into a company that was already here, every entry balances and
-- agrees with its lines, the matching agrees with the matched amounts, no
-- counter is behind a number or a letter already used, no two financial years
-- overlap. One failure and nothing of it stays.
--
-- It is `security definer`, because nobody holds a right on a company that
-- does not exist yet, and it checks its caller on its first line: the
-- installer, or an administrator of this installation — the two who may call
-- `create_company()` — written `is not true`, because `if not NULL` does not
-- raise: `is_installer()` answered NULL on a connection that never set
-- `ekwo.installing`, until `20260918140000`, and the first draft of this
-- function is how that was found. Identifiers are kept. A company that is already here is
-- refused, which is also the answer to running the same import twice.
--
-- What does not travel, and why, is in the registry rows below and in the
-- documentation: the people (`company_members`, `company_invitations`), the
-- secrets (`api_keys`, `document_shares`), a user's own preferences. The
-- identifiers of the people who acted stay on the rows as a trace — none of
-- those columns is a foreign key — and name nobody in the new installation.
-- The bytes of the attachments are not in the database and are not in the
-- archive: the manifest lists them, path, size and checksum.

-- ---------------------------------------------------------------------------
-- The right
-- ---------------------------------------------------------------------------

insert into capabilities (code, area, description) values
  ('company.export', 'company',
   'Leave with the books: read every row of the company into an archive another installation can take in. It reads, and reads everything, which is why it is not part of any reading capability.')
on conflict (code) do nothing;

insert into role_capabilities (role, capability) values
  ('owner'::member_role,  'company.export'),
  ('client'::member_role, 'company.export')
on conflict do nothing;

-- ---------------------------------------------------------------------------
-- Versions
-- ---------------------------------------------------------------------------

create or replace function version_at_least(p_version text, p_floor text)
returns boolean
language sql
immutable
as $$
  select string_to_array(p_version, '.')::integer[] >= string_to_array(p_floor, '.')::integer[];
$$;

comment on function version_at_least(text, text) is
  'Whether a three-part version is at or above another, number by number: 0.10.0 is above 0.9.0, which a comparison of text gets wrong.';

-- ---------------------------------------------------------------------------
-- The registry
-- ---------------------------------------------------------------------------

create table company_archive_registry (
  table_schema text    not null default 'public',
  table_name   text    not null,
  disposition  text    not null,
  reason       text,
  via_column   text,
  via_table    text,
  load_order   integer,
  primary key (table_schema, table_name),
  constraint company_archive_registry_disposition
    check (disposition in ('exported', 'excluded')),
  constraint company_archive_registry_excluded_says_why
    check (disposition = 'exported' or length(coalesce(reason, '')) >= 20),
  constraint company_archive_registry_exported_has_an_order
    check (disposition = 'excluded' or load_order is not null),
  constraint company_archive_registry_via_is_a_pair
    check ((via_column is null) = (via_table is null))
);

comment on table company_archive_registry is
  'What an archive of one company does with each table of the socle that belongs to a company: `exported`, or `excluded` with the reason. A table of a company that is not named here stops every export. Modules answer for their own tables through `<schema>.archive_tables()`.';
comment on column company_archive_registry.reason is
  'Why the table stays behind. Required on an excluded table; on an exported one, what a reader should know about it.';
comment on column company_archive_registry.via_column is
  'For a table with no `company_id`: the column that leads to one that has it.';
comment on column company_archive_registry.via_table is
  'The table `via_column` points at, schema included. It carries `company_id`.';
comment on column company_archive_registry.load_order is
  'The order an import fills the tables in. A reference that points forward, or at its own table, is filled in a second pass and has to be nullable.';

alter table company_archive_registry enable row level security;

create policy company_archive_registry_select on company_archive_registry
  for select to authenticated using (true);

comment on policy company_archive_registry_select on company_archive_registry is
  'Reference data of the installation: which tables an archive carries is not a secret, and an export runs as its caller.';

revoke all on table company_archive_registry from public, anon;
grant select on table company_archive_registry to authenticated, service_role;

insert into company_archive_registry (table_name, disposition, load_order, via_column, via_table, reason) values
  ('companies',              'exported',  10, null, null, null),
  ('company_packs',          'exported',  20, null, null, null),
  ('company_modules',        'exported',  21, null, null, 'Which modules the company had on. `enabled_by` is a trace, not a user of the new installation.'),
  ('company_filing_periods', 'exported',  22, null, null, null),
  ('matching_settings',      'exported',  23, null, null, null),
  ('matching_sequences',     'exported',  24, null, null, 'The counter of the matching letters, so the next one continues the series.'),
  ('fiscal_years',           'exported',  30, null, null, null),
  ('accounts',               'exported',  31, null, null, null),
  ('bank_accounts',          'exported',  32, null, null, null),
  ('journals',               'exported',  33, null, null, null),
  ('journal_sequences',      'exported',  34, 'journal_id', 'public.journals', 'The counters of the numbered books, so the next entry continues the series.'),
  ('analytic_axes',          'exported',  35, null, null, null),
  ('analytic_values',        'exported',  36, null, null, null),
  ('taxes',                  'exported',  37, null, null, null),
  ('tax_postings',           'exported',  38, null, null, null),
  ('contacts',               'exported',  39, null, null, null),
  ('contact_patterns',       'exported',  40, null, null, null),
  ('products',               'exported',  41, null, null, null),
  ('entries',                'exported',  50, null, null, null),
  ('entry_lines',            'exported',  51, null, null, null),
  ('entry_line_analytics',   'exported',  52, null, null, null),
  ('documents',              'exported',  53, null, null, null),
  ('document_lines',         'exported',  54, null, null, null),
  ('payments',               'exported',  55, null, null, null),
  ('reconciliations',        'exported',  56, null, null, null),
  ('bank_statements',        'exported',  57, null, null, null),
  ('bank_transactions',      'exported',  58, null, null, null),
  ('attachments',            'exported',  60, null, null, 'The rows, not the bytes: `storage_path`, `byte_size` and `checksum` say which files to carry across by other means.'),
  ('tax_filings',            'exported',  61, null, null, null),
  ('tax_filing_boxes',       'exported',  62, 'filing_id', 'public.tax_filings', 'The figures a declaration was frozen with.'),
  ('tax_filing_deposits',    'exported',  63, 'filing_id', 'public.tax_filings', 'The proof a declaration went: when, by which channel, under which reference, and what came back.'),
  ('audit_log',              'exported',  90, null, null, 'The trail of the company, with the identifiers of whoever acted kept as a trace. Row ids are local to an installation and are drawn again on arrival.'),
  ('api_keys',               'excluded', null, null, null, 'A credential of the installation it was issued in. A key that worked in two places would be a secret nobody can withdraw.'),
  ('company_invitations',    'excluded', null, null, null, 'A pending invitation is a token of this installation and the address of a person who has not agreed to be anywhere else.'),
  ('company_members',        'excluded', null, null, null, 'Who may read a company is decided where it lives. The users of one installation do not exist in another.'),
  ('document_shares',        'excluded', null, null, null, 'A shared link is a secret and points at this installation. It stays valid here and means nothing elsewhere.'),
  ('user_preferences',       'excluded', null, null, null, 'Belongs to a person, not to a company: it only names the company somebody opens first.')
on conflict (table_schema, table_name) do nothing;

-- ---------------------------------------------------------------------------
-- What the catalogue says belongs to a company
-- ---------------------------------------------------------------------------

create or replace function company_scoped_tables()
returns table (table_schema text, table_name text, has_company_id boolean)
language sql
stable
set search_path = public, pg_temp
as $$
  with recursive reached (oid) as (
    select 'public.companies'::regclass::oid
    union
    select c.conrelid
      from pg_constraint c
      join reached r on c.confrelid = r.oid
     where c.contype = 'f'
  ),
  named (oid) as (
    select a.attrelid
      from pg_attribute a
     where a.attname = 'company_id' and a.attnum > 0 and not a.attisdropped
  )
  select n.nspname::text, k.relname::text,
         exists (select 1 from named m where m.oid = k.oid)
    from pg_class k
    join pg_namespace n on n.oid = k.relnamespace
   where k.relkind in ('r', 'p')
     and n.nspname !~ '^pg_' and n.nspname <> 'information_schema'
     and (k.oid in (select oid from reached) or k.oid in (select oid from named))
   order by 1, 2;
$$;

comment on function company_scoped_tables() is
  'Every table that belongs to a company, read from the catalogue: it carries `company_id`, or a foreign key leads from it to `companies`, directly or through another such table.';

create or replace function company_archive_tables()
returns table (
  table_schema text,
  table_name   text,
  disposition  text,
  reason       text,
  via_column   text,
  via_table    text,
  load_order   integer
)
language plpgsql
stable
set search_path = public, pg_temp
as $$
declare
  v_module record;
  v_rank   integer := 0;
begin
  return query
    select r.table_schema, r.table_name, r.disposition, r.reason,
           r.via_column, r.via_table, r.load_order
      from company_archive_registry r;

  -- A module comes after the socle, always: it depends on `public` by foreign
  -- key and the dependency points one way.
  for v_module in select m.code, m.schema_name from modules m order by m.code loop
    v_rank := v_rank + 1;
    if to_regprocedure(format('%I.archive_tables()', v_module.schema_name)) is not null then
      return query execute format(
        'select %L::text, a.table_name, a.disposition, a.reason, a.via_column, a.via_table,
                %s + a.load_order
           from %I.archive_tables() a',
        v_module.schema_name, v_rank * 1000, v_module.schema_name);
    end if;
  end loop;
end;
$$;

comment on function company_archive_tables() is
  'The registry of the socle and what every installed module answers through `<schema>.archive_tables()`, as one list. Modules load after the socle.';

create or replace function company_archive_unclassified()
returns table (table_schema text, table_name text, problem text)
language sql
stable
set search_path = public, pg_temp
as $$
  select s.table_schema, s.table_name,
         'belongs to a company and is neither exported nor excluded'::text
    from company_scoped_tables() s
   where not exists (select 1 from company_archive_tables() t
                      where t.table_schema = s.table_schema and t.table_name = s.table_name)
  union all
  select t.table_schema, t.table_name, 'is classified and does not exist'::text
    from company_archive_tables() t
   where to_regclass(format('%I.%I', t.table_schema, t.table_name)) is null
  union all
  select t.table_schema, t.table_name,
         'is exported, carries no company_id and names no table that leads to one'::text
    from company_archive_tables() t
    join company_scoped_tables() s
      on s.table_schema = t.table_schema and s.table_name = t.table_name
   where t.disposition = 'exported' and not s.has_company_id and t.via_table is null
     and (t.table_schema, t.table_name) <> ('public', 'companies')
   order by 1, 2;
$$;

comment on function company_archive_unclassified() is
  'What stands between this installation and an honest archive: a table of a company nobody classified, a classification of a table that is gone, an exported table with no way to a company. Empty is the only answer an export accepts.';

create or replace function company_archive_predicate(p_schema text, p_table text, p_alias text)
returns text
language plpgsql
stable
set search_path = public, pg_temp
as $$
declare
  v_row    record;
  v_target text;
begin
  if (p_schema, p_table) = ('public', 'companies') then
    return format('%I.id = $1', p_alias);
  end if;

  select * into v_row from company_archive_tables() t
   where t.table_schema = p_schema and t.table_name = p_table;
  if not found then
    raise exception 'unknown_table: %.% is not a table an archive knows', p_schema, p_table;
  end if;

  if v_row.via_table is null then
    return format('%I.company_id = $1', p_alias);
  end if;

  -- The column the foreign key lands on, from the catalogue rather than from
  -- the habit of calling it `id`.
  select a.attname into v_target
    from pg_constraint c
    join pg_attribute f on f.attrelid = c.conrelid and f.attnum = c.conkey[1]
    join pg_attribute a on a.attrelid = c.confrelid and a.attnum = c.confkey[1]
   where c.contype = 'f'
     and c.conrelid = to_regclass(format('%I.%I', p_schema, p_table))
     and c.confrelid = to_regclass(v_row.via_table)
     and cardinality(c.conkey) = 1
     and f.attname = v_row.via_column;
  if v_target is null then
    raise exception 'unknown_table: %.% says it reaches a company through % to %, and no foreign key does that',
      p_schema, p_table, v_row.via_column, v_row.via_table;
  end if;

  return format('%I.%I in (select via.%I from %s via where via.company_id = $1)',
                p_alias, v_row.via_column, v_target, to_regclass(v_row.via_table)::text);
end;
$$;

comment on function company_archive_predicate(text, text, text) is
  'The SQL condition that keeps the rows of one company in one table, with the company as `$1`. One place, read by the export, by the count and by the checks of an import.';

-- ---------------------------------------------------------------------------
-- Leaving
-- ---------------------------------------------------------------------------

create or replace function company_archive_row_count(p_company_id uuid, p_table text)
returns bigint
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_schema text := split_part(p_table, '.', 1);
  v_name   text := split_part(p_table, '.', 2);
  v_count  bigint;
begin
  if has_capability(p_company_id, 'company.export') is not true then
    raise exception 'not_allowed: counting the rows of this company needs company.export'
      using errcode = '42501';
  end if;
  if not exists (select 1 from company_archive_tables() t
                  where t.table_schema = v_schema and t.table_name = v_name
                    and t.disposition = 'exported') then
    raise exception 'unknown_table: % is not a table an archive carries', p_table;
  end if;

  execute format('select count(*) from %I.%I t where %s',
                 v_schema, v_name, company_archive_predicate(v_schema, v_name, 't'))
     into v_count using p_company_id;
  return v_count;
end;
$$;

comment on function company_archive_row_count(uuid, text) is
  'How many rows one table holds for one company, whatever the caller may read of them. Definer, guarded by company.export, and it answers a number and nothing else: it is what lets an export notice that row level security handed it less than there is.';

create or replace function note_company_export(p_company_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_name text;
begin
  if has_capability(p_company_id, 'company.export') is not true then
    raise exception 'not_allowed: leaving with the books of this company needs company.export'
      using errcode = '42501';
  end if;

  select c.name into v_name from companies c where c.id = p_company_id;
  perform audit_record(p_company_id, 'companies', p_company_id, coalesce(v_name, p_company_id::text),
                       'update', 'company_exported', null,
                       jsonb_build_object('socle_version', ekwo_schema_version()));
end;
$$;

comment on function note_company_export(uuid) is
  'Writes `company_exported` on the audit trail. Called by `export_company()` and by `ekwo company export` before they read. A record of the act, not a control: a member can always read, table by table, what they may read. Definer because nobody writes the trail; guarded by company.export.';

create or replace function assert_may_export_company(p_company_id uuid)
returns void
language plpgsql
stable
set search_path = public, pg_temp
as $$
begin
  if has_capability(p_company_id, 'company.export') is not true then
    raise exception 'not_allowed: leaving with the books of this company needs company.export'
      using errcode = '42501';
  end if;
  -- Under row level security, or not at all. A role that bypasses it — the
  -- backend role of a Supabase project, the owner of the database — reads
  -- every company at once, so "what the caller may read" means nothing for it
  -- and the comparison below would compare a number with itself. Whoever holds
  -- such a role has `pg_dump`; what they do not get is an archive that says a
  -- person took it.
  if exists (select 1 from pg_roles r where r.rolname = current_user and (r.rolbypassrls or r.rolsuper)) then
    raise exception 'not_allowed: an archive is read under row level security, and % is not subject to it', current_user
      using errcode = '42501';
  end if;
end;
$$;

comment on function assert_may_export_company(uuid) is
  'The two conditions of leaving: company.export on the company, and a caller that row level security applies to. Invoker, so `current_user` is the role that asked.';

create or replace function export_company_table(p_company_id uuid, p_table text)
returns setof jsonb
language plpgsql
stable
set search_path = public, pg_temp
set timezone = 'UTC'
as $$
declare
  v_schema   text := split_part(p_table, '.', 1);
  v_name     text := split_part(p_table, '.', 2);
  v_problem  record;
  v_where    text;
  v_decimals text;
  v_order    text;
  v_seen     bigint;
  v_held     bigint;
begin
  perform assert_may_export_company(p_company_id);

  select * into v_problem from company_archive_unclassified() limit 1;
  if found then
    raise exception 'unclassified_table: %.% % — an archive that might be incomplete is not written. Classify it in company_archive_registry, or in the archive_tables() of its module.',
      v_problem.table_schema, v_problem.table_name, v_problem.problem
      using errcode = '55006';
  end if;

  if not exists (select 1 from company_archive_tables() t
                  where t.table_schema = v_schema and t.table_name = v_name
                    and t.disposition = 'exported') then
    raise exception 'unknown_table: % is not a table an archive carries', p_table;
  end if;

  v_where := company_archive_predicate(v_schema, v_name, 't');

  execute format('select count(*) from %I.%I t where %s', v_schema, v_name, v_where)
     into v_seen using p_company_id;
  v_held := company_archive_row_count(p_company_id, p_table);
  if v_seen <> v_held then
    raise exception 'export_incomplete: % holds % rows for this company and you may read % of them. An archive is whole or it is not written: ask for the reading capability you lack — or, for the table of a module, for the module to be enabled.',
      p_table, v_held, v_seen
      using errcode = '42501';
  end if;

  -- Decimals leave as text. `12.50` is a valid JSON number and most readers
  -- hand it back as a float; an archive of a ledger must not depend on which.
  select coalesce(' || jsonb_build_object(' ||
                  string_agg(format('%L, t.%I::text', a.attname, a.attname), ', ' order by a.attnum) || ')', '')
    into v_decimals
    from pg_attribute a
   where a.attrelid = to_regclass(format('%I.%I', v_schema, v_name))
     and a.attnum > 0 and not a.attisdropped
     and a.atttypid = 'numeric'::regtype;

  select string_agg(format('t.%I', a.attname), ', ' order by array_position(i.indkey::smallint[], a.attnum))
    into v_order
    from pg_index i
    join pg_attribute a on a.attrelid = i.indrelid and a.attnum = any (i.indkey)
   where i.indrelid = to_regclass(format('%I.%I', v_schema, v_name)) and i.indisprimary;
  if v_order is null then
    raise exception 'unknown_table: % has no primary key, so its rows have no order to be written in', p_table;
  end if;

  return query execute format('select to_jsonb(t)%s from %I.%I t where %s order by %s',
                              v_decimals, v_schema, v_name, v_where, v_order)
    using p_company_id;
end;
$$;

comment on function export_company_table(uuid, text) is
  'The rows of one table for one company, one JSON object each, in primary key order: decimals as text, timestamps in UTC. Runs as its caller, needs company.export, refuses when the caller may read fewer rows than the table holds, and refuses while any table of a company is unclassified. Stable, so it reads the snapshot of the statement that calls it: called table after table, it needs a repeatable read transaction around the calls for the tables to agree with each other and with the manifest — which is what the CLI opens — or use export_company(), which is one statement.';

create or replace function export_company_manifest(p_company_id uuid)
returns jsonb
language plpgsql
stable
set search_path = public, pg_temp
set timezone = 'UTC'
as $$
declare
  v_company  companies%rowtype;
  v_table    record;
  v_tables   jsonb := '[]'::jsonb;
  v_rows     bigint;
  v_checksum text;
begin
  perform assert_may_export_company(p_company_id);

  select * into v_company from companies c where c.id = p_company_id;
  if not found then
    raise exception 'unknown_company: % is not a company you may read', p_company_id
      using errcode = 'P0002';
  end if;

  for v_table in
    select t.table_schema || '.' || t.table_name as name
      from company_archive_tables() t
     where t.disposition = 'exported'
     order by t.load_order, t.table_schema, t.table_name
  loop
    select count(*),
           encode(sha256(convert_to(coalesce(string_agg(x.r::text || E'\n', '' order by x.n), ''), 'UTF8')), 'hex')
      into v_rows, v_checksum
      from export_company_table(p_company_id, v_table.name) with ordinality as x(r, n);

    v_tables := v_tables || jsonb_build_object(
      'name', v_table.name,
      'file', 'data/' || v_table.name || '.jsonl',
      'rows', v_rows,
      'sha256', v_checksum);
  end loop;

  return jsonb_build_object(
    'format', 'ekwo.company-archive',
    'format_version', 1,
    'exported_at', to_jsonb(now()),
    'exported_by', auth.uid(),
    'socle_version', ekwo_schema_version(),
    'origin_instance', (select i.instance_id from instance i),
    'company', jsonb_build_object(
      'id', v_company.id,
      'name', v_company.name,
      'country', v_company.country,
      'fiscal_country', v_company.fiscal_country,
      'currency_code', v_company.currency_code),
    'packs', coalesce((
      select jsonb_agg(jsonb_build_object('country', p.country, 'version', p.version, 'chart_code', p.chart_code)
                       order by p.country)
        from company_packs p where p.company_id = p_company_id), '[]'::jsonb),
    'modules', coalesce((
      select jsonb_agg(jsonb_build_object('code', m.code, 'version', m.version) order by m.code)
        from company_modules cm join modules m on m.code = cm.module_code
       where cm.company_id = p_company_id), '[]'::jsonb),
    'tables', v_tables,
    'excluded', coalesce((
      select jsonb_agg(jsonb_build_object('name', t.table_schema || '.' || t.table_name, 'reason', t.reason)
                       order by t.table_schema, t.table_name)
        from company_archive_tables() t where t.disposition = 'excluded'), '[]'::jsonb),
    'files', jsonb_build_object(
      'transported', false,
      'list', coalesce((
        select jsonb_agg(jsonb_build_object(
                 'attachment_id', a.id,
                 'storage_path', a.storage_path,
                 'file_name', a.file_name,
                 'mime_type', a.mime_type,
                 'byte_size', a.byte_size,
                 'checksum', a.checksum) order by a.id)
          from attachments a where a.company_id = p_company_id), '[]'::jsonb)));
end;
$$;

comment on function export_company_manifest(uuid) is
  'What an archive of this company is: the format and its version, the socle, the packs and the modules an installation needs to take it in, every table with its row count and the sha256 of its rows, the tables left behind with the reason, and the list of the files the attachments point at — which the archive does not carry.';

create or replace function export_company_tables(p_company_id uuid)
returns jsonb
language sql
stable
set search_path = public, pg_temp
set timezone = 'UTC'
as $$
  select coalesce(jsonb_object_agg(
           t.table_schema || '.' || t.table_name,
           coalesce((select jsonb_agg(x.r order by x.n)
                       from export_company_table(p_company_id, t.table_schema || '.' || t.table_name)
                            with ordinality as x(r, n)),
                    '[]'::jsonb)), '{}'::jsonb)
    from company_archive_tables() t
   where t.disposition = 'exported';
$$;

comment on function export_company_tables(uuid) is
  'Every exported table of one company as one object, keyed by table name. The `tables` half of export_company().';

create or replace function export_company(p_company_id uuid)
returns jsonb
language plpgsql
set search_path = public, pg_temp
set timezone = 'UTC'
as $$
declare
  v_archive jsonb;
begin
  perform note_company_export(p_company_id);
  -- One statement, so one snapshot: a volatile function sees a new one at each
  -- statement, and an archive whose manifest was computed a moment before its
  -- rows, or whose lines were read a moment after their entries, is one that
  -- fails on arrival — after the company has left. The two readers are stable
  -- and share the snapshot of this select.
  select jsonb_build_object('manifest', export_company_manifest(p_company_id),
                            'tables', export_company_tables(p_company_id))
    into v_archive;
  return v_archive;
end;
$$;

comment on function export_company(uuid) is
  'The whole archive as one document, read in one snapshot: `manifest`, and `tables` keyed by table name. It is what `import_company()` takes, and it writes `company_exported` on the audit trail. A large company is better read table by table, which is what the CLI does; this is the same rows in one answer.';

-- ---------------------------------------------------------------------------
-- Arriving
-- ---------------------------------------------------------------------------

create or replace function import_company(p_archive jsonb, p_owner_user_id uuid default null)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_manifest  jsonb := p_archive -> 'manifest';
  v_tables    jsonb := coalesce(p_archive -> 'tables', '{}'::jsonb);
  v_company   uuid;
  v_owner     uuid := coalesce(p_owner_user_id, auth.uid());
  v_item      jsonb;
  v_problem   record;
  v_table     record;
  v_class     regclass;
  v_rows      jsonb;
  v_count     bigint;
  v_checksum  text;
  v_columns   text[];
  v_deferred  text[];
  v_unknown   text;
  v_select    text;
  v_silenced  regclass[] := '{}';
  v_second    jsonb := '[]'::jsonb;
  v_were_off  jsonb := '[]'::jsonb;
  v_pass      jsonb;
  v_fk        record;
  v_total     bigint := 0;
  v_name      text;
  v_found     text;
begin
  -- The guard, first and in the open: the two callers who may create a company
  -- here, and nobody else. A definer function that checks nobody is how two
  -- doors were found open on 18 September.
  --
  -- `is not true`, not `not`: a helper that answers NULL turns `if not … and
  -- not …` into an `if NULL`, which does not raise. `is_installer()` did, until
  -- `20260918140000`, for the backend role through the API. The guard is
  -- written so that it holds whatever the helpers answer.
  if is_installer() is not true and is_instance_admin() is not true then
    raise exception 'not_instance_admin: taking a company into this installation is an instance-level act'
      using errcode = '42501';
  end if;

  if v_manifest is null or v_manifest ->> 'format' is distinct from 'ekwo.company-archive' then
    raise exception 'not_an_archive: this document does not say it is an ekwo.company-archive';
  end if;
  if v_manifest ->> 'format_version' is distinct from '1' then
    raise exception 'unknown_archive_version: this installation reads version 1 of the format, and the archive says %',
      coalesce(v_manifest ->> 'format_version', 'nothing');
  end if;
  if not coalesce(version_at_least(ekwo_schema_version(), v_manifest ->> 'socle_version'), false) then
    raise exception 'socle_too_old: the archive was written by socle % and this installation is %. Run `ekwo migrate` first.',
      v_manifest ->> 'socle_version', ekwo_schema_version()
      using errcode = '55006';
  end if;

  -- What the company needs is read from its rows as well as from the manifest:
  -- the manifest is a summary somebody could have edited, the rows are what
  -- will be here afterwards.
  for v_item in
    select jsonb_build_object('country', e ->> 'country', 'version', e ->> 'version')
      from jsonb_array_elements(coalesce(v_tables -> 'public.company_packs', '[]'::jsonb)) e
    union
    select jsonb_build_object('country', m ->> 'country', 'version', m ->> 'version')
      from jsonb_array_elements(coalesce(v_manifest -> 'packs', '[]'::jsonb)) m
  loop
    select p.version into v_found from country_packs p where p.country = v_item ->> 'country';
    if not found then
      raise exception 'pack_missing: the company holds the % pack and this installation does not', v_item ->> 'country'
        using errcode = '55006';
    end if;
    if not coalesce(version_at_least(v_found, v_item ->> 'version'), false) then
      raise exception 'pack_too_old: the company is on version % of the % pack and this installation holds %',
        v_item ->> 'version', v_item ->> 'country', v_found
        using errcode = '55006';
    end if;
  end loop;

  for v_item in
    select jsonb_build_object('code', m ->> 'code', 'version', m ->> 'version')
      from jsonb_array_elements(coalesce(v_manifest -> 'modules', '[]'::jsonb)) m
    union
    select jsonb_build_object('code', e ->> 'module_code', 'version', null)
      from jsonb_array_elements(coalesce(v_tables -> 'public.company_modules', '[]'::jsonb)) e
  loop
    select m.version into v_found from modules m where m.code = v_item ->> 'code';
    if not found then
      raise exception 'module_missing: the company uses the % module and this installation does not carry it', v_item ->> 'code'
        using errcode = '55006';
    end if;
    if v_item ->> 'version' is not null and not version_at_least(v_found, v_item ->> 'version') then
      raise exception 'module_too_old: the company used version % of the % module and this installation holds %',
        v_item ->> 'version', v_item ->> 'code', v_found
        using errcode = '55006';
    end if;
  end loop;

  v_company := (v_manifest #>> '{company,id}')::uuid;
  if v_company is null then
    raise exception 'not_an_archive: the manifest names no company';
  end if;
  -- Identifiers are kept, so a company is here or it is not. This is also what
  -- a second run of the same import meets.
  if exists (select 1 from companies c where c.id = v_company) then
    raise exception 'company_already_here: % is a company of this installation. An import never merges: a company arrives whole, once.', v_company
      using errcode = '23505';
  end if;

  select * into v_problem from company_archive_unclassified() limit 1;
  if found then
    raise exception 'unclassified_table: %.% % — this installation cannot say what an archive is made of',
      v_problem.table_schema, v_problem.table_name, v_problem.problem
      using errcode = '55006';
  end if;

  -- The manifest and the tables say the same thing, and every table is one
  -- this installation exports itself.
  for v_name in select jsonb_object_keys(v_tables) loop
    if not exists (select 1 from jsonb_array_elements(v_manifest -> 'tables') m where m ->> 'name' = v_name) then
      raise exception 'archive_corrupt: the archive carries rows of % and its manifest does not list it', v_name;
    end if;
  end loop;
  for v_item in select jsonb_array_elements(coalesce(v_manifest -> 'tables', '[]'::jsonb)) loop
    v_name := v_item ->> 'name';
    if not exists (select 1 from company_archive_tables() t
                    where t.table_schema || '.' || t.table_name = v_name and t.disposition = 'exported') then
      raise exception 'unknown_table: the archive carries %, which this installation does not know as a table of a company', v_name
        using errcode = '55006';
    end if;
    v_rows := coalesce(v_tables -> v_name, '[]'::jsonb);
    select count(*),
           encode(sha256(convert_to(coalesce(string_agg(x.r::text || E'\n', '' order by x.n), ''), 'UTF8')), 'hex')
      into v_count, v_checksum
      from jsonb_array_elements(v_rows) with ordinality as x(r, n);
    if v_count is distinct from (v_item ->> 'rows')::bigint or v_checksum is distinct from v_item ->> 'sha256' then
      raise exception 'archive_corrupt: % does not match its manifest (% rows against %, or another checksum)',
        v_name, v_count, v_item ->> 'rows';
    end if;
  end loop;

  if jsonb_array_length(coalesce(v_tables -> 'public.companies', '[]'::jsonb)) <> 1 then
    raise exception 'foreign_row: an archive holds one company, and this one holds % rows of public.companies',
      jsonb_array_length(coalesce(v_tables -> 'public.companies', '[]'::jsonb));
  end if;

  -- First pass: the rows, in the order the registry names.
  for v_table in
    select t.table_schema, t.table_name, t.load_order,
           t.table_schema || '.' || t.table_name as name
      from company_archive_tables() t
     where t.disposition = 'exported'
     order by t.load_order, t.table_schema, t.table_name
  loop
    v_rows := coalesce(v_tables -> v_table.name, '[]'::jsonb);
    continue when jsonb_array_length(v_rows) = 0;
    v_class := to_regclass(format('%I.%I', v_table.table_schema, v_table.table_name));
    v_total := v_total + jsonb_array_length(v_rows);

    -- A column this installation does not have is data it would drop in
    -- silence. It refuses instead.
    select k.key into v_unknown
      from (select distinct jsonb_object_keys(e) as key from jsonb_array_elements(v_rows) e) k
     where not exists (select 1 from pg_attribute a
                        where a.attrelid = v_class and a.attname = k.key
                          and a.attnum > 0 and not a.attisdropped)
     limit 1;
    if v_unknown is not null then
      raise exception 'unknown_column: %.% is in the archive and not in this installation', v_table.name, v_unknown
        using errcode = '55006';
    end if;

    -- Every row has the columns of the first. The list of columns written is
    -- read from one row; a key that only a later row carries would be dropped
    -- in silence, and one it lacks would be written as null over a default.
    if exists (select 1 from jsonb_array_elements(v_rows) e
                where (select array_agg(k order by k) from jsonb_object_keys(e) k)
                      is distinct from
                      (select array_agg(k order by k) from jsonb_object_keys(v_rows -> 0) k)) then
      raise exception 'archive_corrupt: the rows of % do not all have the same columns', v_table.name;
    end if;

    -- Every row says which company it is of, and it is the one that arrives.
    if v_table.name = 'public.companies' then
      if jsonb_array_length(v_rows) <> 1 or (v_rows -> 0 ->> 'id') is distinct from v_company::text then
        raise exception 'foreign_row: an archive holds one company, the one its manifest names';
      end if;
    elsif exists (select 1 from pg_attribute a
                   where a.attrelid = v_class and a.attname = 'company_id' and not a.attisdropped) then
      if exists (select 1 from jsonb_array_elements(v_rows) e
                  where e ->> 'company_id' is distinct from v_company::text) then
        raise exception 'foreign_row: % holds a row of another company than the one the archive names', v_table.name;
      end if;
    end if;

    -- A reference to a table that loads later, or to its own table, waits for
    -- the second pass. Derived from the foreign keys, so a new one needs no
    -- line here; it has to be nullable, and a test says so before a user does.
    select coalesce(array_agg(distinct a.attname), '{}') into v_deferred
      from pg_constraint c
      join unnest(c.conkey) as k(attnum) on true
      join pg_attribute a on a.attrelid = c.conrelid and a.attnum = k.attnum
      join pg_class rc on rc.oid = c.confrelid
      join pg_namespace rn on rn.oid = rc.relnamespace
      join company_archive_tables() r
        on r.table_schema = rn.nspname and r.table_name = rc.relname and r.disposition = 'exported'
     where c.contype = 'f' and c.conrelid = v_class
       and r.load_order >= v_table.load_order
       and a.attname <> 'company_id';

    if exists (select 1 from pg_attribute a
                where a.attrelid = v_class and a.attname = any (v_deferred) and a.attnotnull) then
      raise exception 'cannot_order: % holds a required reference to a table that loads after it', v_table.name;
    end if;

    -- What is written: every column of the table the archive names, but the
    -- generated ones, which compute themselves, and an identity, which is
    -- local to an installation and is drawn again.
    select array_agg(a.attname order by a.attnum) into v_columns
      from pg_attribute a
     where a.attrelid = v_class and a.attnum > 0 and not a.attisdropped
       and a.attgenerated = '' and a.attidentity = ''
       and (v_rows -> 0) ? a.attname;

    select string_agg(case when c = any (v_deferred) then format('null as %I', c) else format('r.%I', c) end, ', ')
      into v_select
      from unnest(v_columns) as c;

    -- The guards of a table are written for a person booking one thing at a
    -- time, in order, today. They are switched off on the tables being filled
    -- and nowhere else, inside this transaction, under a lock that makes every
    -- other writer of the table wait — and only where there is one to switch
    -- off, so `audit_log`, whose only trigger refuses updates and deletes,
    -- is never touched.
    if exists (select 1 from pg_trigger g
                where g.tgrelid = v_class and not g.tgisinternal
                  and ((g.tgtype & 4) <> 0 or ((g.tgtype & 16) <> 0 and cardinality(v_deferred) > 0))) then
      -- A trigger an operator had set otherwise — off, or firing on a replica
      -- — is put back the way it was.
      v_were_off := v_were_off || coalesce((
        select jsonb_agg(jsonb_build_object(
                 'class', v_class::text, 'name', g.tgname,
                 'verb', case g.tgenabled when 'D' then 'disable trigger'
                                          when 'R' then 'enable replica trigger'
                                          else 'enable always trigger' end))
          from pg_trigger g
         where g.tgrelid = v_class and not g.tgisinternal and g.tgenabled <> 'O'), '[]'::jsonb);
      execute format('alter table %s disable trigger user', v_class);
      v_silenced := v_silenced || v_class;
    end if;

    -- In the order of the archive, so that an identity drawn again — the ids
    -- of the trail — follows the order the rows were written in.
    execute format('insert into %s (%s) select %s from jsonb_array_elements($1) with ordinality as e(v, n)
                      cross join lateral jsonb_populate_record(null::%s, e.v) as r order by e.n',
                   v_class, (select string_agg(format('%I', c), ', ') from unnest(v_columns) c),
                   v_select, v_class)
      using v_rows;

    if cardinality(v_deferred) > 0 then
      v_second := v_second || jsonb_build_object('table', v_table.name, 'class', v_class::text,
                                                 'columns', to_jsonb(v_deferred));
    end if;
  end loop;

  -- Second pass: the references that pointed forward.
  for v_pass in select jsonb_array_elements(v_second) loop
    select array_agg(c) into v_deferred
      from jsonb_array_elements_text(v_pass -> 'columns') c
     where (v_tables -> (v_pass ->> 'table') -> 0) ? c;
    continue when v_deferred is null;
    execute format(
      'update %s t set %s from jsonb_populate_recordset(null::%s, $1) r where %s and (%s)',
      v_pass ->> 'class',
      (select string_agg(format('%I = r.%I', c, c), ', ') from unnest(v_deferred) c),
      v_pass ->> 'class',
      -- By the primary key, read from the catalogue rather than assumed to be `id`.
      (select string_agg(format('t.%I = r.%I', a.attname, a.attname), ' and ')
         from pg_index i
         join pg_attribute a on a.attrelid = i.indrelid and a.attnum = any (i.indkey)
        where i.indrelid = (v_pass ->> 'class')::regclass and i.indisprimary),
      (select string_agg(format('r.%I is not null', c), ' or ') from unnest(v_deferred) c))
      using v_tables -> (v_pass ->> 'table');
  end loop;

  foreach v_class in array v_silenced loop
    execute format('alter table %s enable trigger user', v_class);
  end loop;
  for v_pass in select jsonb_array_elements(v_were_off) loop
    execute format('alter table %s %s %I', v_pass ->> 'class', v_pass ->> 'verb', v_pass ->> 'name');
  end loop;

  -- What the triggers would have guaranteed, asked of the result.

  -- 1. Everything that arrived is of this company: a row that hung itself on
  --    a parent of another company is missing from this count.
  for v_table in
    select t.table_schema, t.table_name, t.table_schema || '.' || t.table_name as name
      from company_archive_tables() t where t.disposition = 'exported'
  loop
    execute format('select count(*) from %I.%I t where %s', v_table.table_schema, v_table.table_name,
                   company_archive_predicate(v_table.table_schema, v_table.table_name, 't'))
       into v_count using v_company;
    if v_count <> jsonb_array_length(coalesce(v_tables -> v_table.name, '[]'::jsonb)) then
      raise exception 'foreign_row: % holds % rows of this company after the import and the archive carried %',
        v_table.name, v_count, jsonb_array_length(coalesce(v_tables -> v_table.name, '[]'::jsonb));
    end if;
  end loop;

  -- 2. No reference leaves the company. Most foreign keys of the schema carry
  --    `company_id` and refuse this themselves; the ones that do not are why
  --    this is asked of all of them.
  for v_fk in
    select c.conrelid::regclass as child, c.confrelid::regclass as parent,
           cn.nspname as child_schema, ck.relname as child_table,
           pn.nspname as parent_schema, pk.relname as parent_table,
           ca.attname as child_column, pa.attname as parent_column
      from pg_constraint c
      join pg_class ck on ck.oid = c.conrelid
      join pg_namespace cn on cn.oid = ck.relnamespace
      join pg_class pk on pk.oid = c.confrelid
      join pg_namespace pn on pn.oid = pk.relnamespace
      join pg_attribute ca on ca.attrelid = c.conrelid and ca.attnum = c.conkey[1]
      join pg_attribute pa on pa.attrelid = c.confrelid and pa.attnum = c.confkey[1]
      join company_archive_tables() ct
        on ct.table_schema = cn.nspname and ct.table_name = ck.relname and ct.disposition = 'exported'
      join company_archive_tables() pt
        on pt.table_schema = pn.nspname and pt.table_name = pk.relname and pt.disposition = 'exported'
     where c.contype = 'f' and cardinality(c.conkey) = 1
  loop
    execute format(
      'select count(*) from %s t join %s p on p.%I = t.%I where %s and not (%s)',
      v_fk.child, v_fk.parent, v_fk.parent_column, v_fk.child_column,
      company_archive_predicate(v_fk.child_schema, v_fk.child_table, 't'),
      company_archive_predicate(v_fk.parent_schema, v_fk.parent_table, 'p'))
      into v_count using v_company;
    if v_count > 0 then
      raise exception 'foreign_row: %.% points at a row of another company in % (% rows)',
        v_fk.child, v_fk.child_column, v_fk.parent, v_count;
    end if;
  end loop;

  -- 3. The ledger: an entry agrees with its lines, and a posted one balances.
  select e.number into v_found
    from entries e
    left join lateral (select coalesce(sum(l.debit), 0) as debit, coalesce(sum(l.credit), 0) as credit
                         from entry_lines l where l.entry_id = e.id) s on true
   where e.company_id = v_company
     and (e.total_debit <> s.debit or e.total_credit <> s.credit
          or (e.state = 'posted' and s.debit <> s.credit))
   limit 1;
  if found then
    raise exception 'unbalanced_entry: entry % does not balance, or does not agree with its lines', coalesce(v_found, '(no number)');
  end if;

  -- 4. The matching: what a line says is matched is what its matchings add up to.
  select l.id::text into v_found
    from entry_lines l
   where l.company_id = v_company
     and l.matched_amount <> coalesce((select sum(r.amount) from reconciliations r
                                        where r.debit_line_id = l.id or r.credit_line_id = l.id), 0)
   limit 1;
  if found then
    raise exception 'matching_mismatch: line % says it is matched for another amount than its matchings add up to', v_found;
  end if;

  -- 5. The numbered books: no counter is behind a number already used, or the
  --    next entry would take a number that exists.
  select e.number into v_found
    from entries e
    join journals j on j.id = e.journal_id
    cross join lateral numbering_rules(v_company) n
   where e.company_id = v_company and e.number is not null
     and number_counter(n.number_format, e.number) is not null
     and number_counter(n.number_format, e.number) > coalesce((
           select s.last_number from journal_sequences s
            where s.journal_id = j.id
              and s.year = case when n.number_format ~ '\{(YYYY|YY)\}'
                                then extract(year from e.entry_date)::smallint
                                else 0::smallint end), 0)
   limit 1;
  if found then
    raise exception 'counter_behind: entry % carries a number its journal has not counted up to; the next entry would collide', v_found;
  end if;

  --    The letters of the matching, the same way.
  select l.matching_number into v_found
    from entry_lines l
   where l.company_id = v_company and l.matching_number ~ '[0-9]+$'
     and substring(l.matching_number from '[0-9]+$')::bigint
         > coalesce((select s.last_number from matching_sequences s where s.company_id = v_company), 0)
   limit 1;
  if found then
    raise exception 'counter_behind: the matching letter % is ahead of the counter of the company; the next matching would reuse a letter', v_found;
  end if;

  -- 6. The financial years do not overlap: every date belongs to one year or
  --    to none, which is what a lock and a closing are read against.
  select x.name into v_found
    from fiscal_years x
    join fiscal_years y on y.company_id = x.company_id and y.id <> x.id
     and daterange(x.start_date, x.end_date, '[]') && daterange(y.start_date, y.end_date, '[]')
   where x.company_id = v_company
   limit 1;
  if found then
    raise exception 'overlapping_years: the financial year % overlaps another one of the same company', v_found;
  end if;

  -- The first member. The people of the other installation did not travel.
  if v_owner is not null then
    insert into company_members (company_id, user_id, role)
    values (v_company, v_owner, 'owner')
    on conflict (company_id, user_id) do nothing;
  end if;

  -- Where this installation's own testimony starts: everything on the trail
  -- of this company before this row is what the archive said.
  perform audit_record(v_company, 'companies', v_company, v_manifest #>> '{company,name}',
                       'insert', 'company_imported', null,
                       jsonb_build_object(
                         'origin_instance', v_manifest -> 'origin_instance',
                         'exported_at', v_manifest -> 'exported_at',
                         'exported_by', v_manifest -> 'exported_by',
                         'socle_version', v_manifest -> 'socle_version',
                         'rows', v_total));

  return jsonb_build_object(
    'company_id', v_company,
    'name', v_manifest #>> '{company,name}',
    'rows', v_total,
    'owner', v_owner,
    'tables', (select jsonb_object_agg(m ->> 'name', (m ->> 'rows')::bigint)
                 from jsonb_array_elements(v_manifest -> 'tables') m),
    'files_to_carry', jsonb_array_length(coalesce(v_manifest #> '{files,list}', '[]'::jsonb)));
end;
$$;

comment on function import_company(jsonb, uuid) is
  'Takes in the archive `export_company()` wrote: one company, whole, with its identifiers, its numbers, its locks and its trail. The installer or an administrator of the installation only. Rows are inserted with the user triggers of the filled tables off for the length of the transaction, foreign keys on, and the result is checked — ownership of every row, no reference into another company, balance, matching, counters — before anything stays. A company already here is refused. `p_owner_user_id`, or the caller, becomes its first owner.';

-- ---------------------------------------------------------------------------
-- Grants. Every function is reachable by a signed-in user and guarded inside,
-- which is the doctrine of 20260914151207.
-- ---------------------------------------------------------------------------

revoke execute on function version_at_least(text, text) from public, anon;
revoke execute on function company_scoped_tables() from public, anon;
revoke execute on function company_archive_tables() from public, anon;
revoke execute on function company_archive_unclassified() from public, anon;
revoke execute on function company_archive_predicate(text, text, text) from public, anon;
revoke execute on function company_archive_row_count(uuid, text) from public, anon;
revoke execute on function note_company_export(uuid) from public, anon;
revoke execute on function assert_may_export_company(uuid) from public, anon;
revoke execute on function export_company_table(uuid, text) from public, anon;
revoke execute on function export_company_manifest(uuid) from public, anon;
revoke execute on function export_company_tables(uuid) from public, anon;
revoke execute on function export_company(uuid) from public, anon;
revoke execute on function import_company(jsonb, uuid) from public, anon;

grant execute on function version_at_least(text, text) to authenticated, service_role;
grant execute on function company_scoped_tables() to authenticated, service_role;
grant execute on function company_archive_tables() to authenticated, service_role;
grant execute on function company_archive_unclassified() to authenticated, service_role;
grant execute on function company_archive_predicate(text, text, text) to authenticated, service_role;
grant execute on function company_archive_row_count(uuid, text) to authenticated, service_role;
grant execute on function note_company_export(uuid) to authenticated, service_role;
grant execute on function assert_may_export_company(uuid) to authenticated, service_role;
grant execute on function export_company_table(uuid, text) to authenticated, service_role;
grant execute on function export_company_manifest(uuid) to authenticated, service_role;
grant execute on function export_company_tables(uuid) to authenticated, service_role;
grant execute on function export_company(uuid) to authenticated, service_role;
grant execute on function import_company(jsonb, uuid) to authenticated, service_role;
