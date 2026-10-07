-- ---------------------------------------------------------------------------
-- An export fits the time a key's request is given
-- ---------------------------------------------------------------------------
-- A nightly copy of a company calls `export_company()` over the API, with the
-- publishable key and a machine key in `X-Ekwo-Api-Key`. Measured on a real
-- 0.10.0 installation, every such copy failed with `canceling statement due
-- to statement timeout`, for two reasons that only meet over HTTP.
--
--   1. **The request kept the clock of `anon`.** PostgREST arms the
--      `statement_timeout` of the role it starts the request as — `anon`,
--      three seconds on a hosted project. `ekwo_pre_request()` moves the
--      request onto `authenticated` once the key is presented, and the clock
--      stayed the anonymous one: a member who signed in had eight seconds for
--      the same call, a key three. The pre-request now also takes the
--      `statement_timeout` configured for `authenticated` — read from
--      `pg_db_role_setting` by `authenticated_statement_timeout()`, the
--      setting for this database first and the one for every database after
--      it, which is the order PostgreSQL applies them in. Where none is configured the request keeps the clock it has:
--      no number is written here.
--
--   2. **An export did the work of a table forty-seven times, twice.**
--      `export_company()` read the manifest and then the rows, and each half
--      called `export_company_table()` once per table. Each call checked the
--      right to export, swept the catalogue for an unclassified table
--      (`company_archive_unclassified()`, about 20 ms on its own), listed the
--      tables of an archive, built the condition of the table from that list
--      again, and counted the rows twice — about 30 ms before a single row
--      was read, on an empty table as on a full one. The rows of every table
--      were then read twice: once to checksum them, once to write them.
--
--      `export_company_archive()` is the export, once: the right, the sweep
--      and the list of tables are asked once per archive, the rows the
--      administrator holds are counted once for every table by
--      `company_archive_row_counts()`, and each table is read once — its
--      count, both checksums and its rows come from the same pass.
--      `export_company()`, `export_company_manifest()` and
--      `export_company_tables()` are that function, whole or in half.
--
--      The bytes do not move. The rows are written by one query, which
--      `export_company_table()` — the reader of the command line, table by
--      table — now builds from the same place (`company_archive_rows_query()`),
--      the order is the one it always was, and the checksums are computed
--      over the same text. `tests/export_fits_a_key_request.test.ts` exports
--      a furnished company with the functions of 0.11.0 and with these, in
--      one transaction, and compares the two documents byte for byte.
--
--      Still one snapshot: the function is stable, and `export_company()`
--      calls it from one statement.
--
--   3. **The trail asked who reads it once per row.** `audit_log_select` now
--      asks it once per statement, the way the policies of `20260918141627`
--      do: `caller_companies()` lists the companies the caller is on, and the
--      policy compares `company_id` with that list.
-- ---------------------------------------------------------------------------

-- ---------------------------------------------------------------------------
-- 1. The pre-request takes the clock of the role it gives
-- ---------------------------------------------------------------------------

create or replace function authenticated_statement_timeout()
returns text
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  -- The setting for this database wins over the one for every database, as
  -- it does when PostgreSQL applies them at login.
  select substr(c.setting, length('statement_timeout=') + 1)
    from pg_db_role_setting s
    join pg_roles r on r.oid = s.setrole
   cross join lateral unnest(s.setconfig) as c(setting)
   where r.rolname = 'authenticated'
     and s.setdatabase in (0, (select d.oid from pg_database d where d.datname = current_database()))
     and c.setting like 'statement\_timeout=%'
   order by s.setdatabase desc
   limit 1;
$$;

comment on function authenticated_statement_timeout() is
  'The statement_timeout configured for the role `authenticated` on this database, or NULL when none is. Definer because the catalogue of role settings is not every role''s to read; it answers that one value and nothing else.';

create or replace function ekwo_pre_request()
returns void
language plpgsql
set search_path = public, pg_temp
as $$
declare
  v_headers json := nullif(current_setting('request.headers', true), '')::json;
  v_secret  text := nullif(v_headers ->> 'x-ekwo-api-key', '');
  v_timeout text;
begin
  if v_secret is null then
    return;
  end if;

  -- Raises on a key that is unknown, withdrawn or expired, and the raise fails
  -- the request. Nothing below this line runs for a key that is not one.
  perform present_api_key(v_secret);

  -- Off `anon`, which holds no privilege on any table, and onto the role whose
  -- grants row level security is written against. `auth.uid()` stays null.
  perform set_config('role', 'authenticated', true);

  -- And onto its clock. PostgREST armed the one of the role it started the
  -- request as; the work that follows is the work of `authenticated`, and is
  -- given its time.
  v_timeout := authenticated_statement_timeout();
  if v_timeout is not null then
    perform set_config('statement_timeout', v_timeout, true);
  end if;
end;
$$;

comment on function ekwo_pre_request() is
  'Called by PostgREST at the start of every request (pgrst.db_pre_request). Presents the key in X-Ekwo-Api-Key when there is one, then moves the request off `anon` so that row level security decides instead of the grants, and gives it the statement_timeout configured for `authenticated`, when one is. No header, no effect.';

-- ---------------------------------------------------------------------------
-- 2. An export does the work of a table once
-- ---------------------------------------------------------------------------

create or replace function company_archive_predicate_via(
  p_schema     text,
  p_table      text,
  p_via_column text,
  p_via_table  text,
  p_alias      text
)
returns text
language plpgsql
stable
set search_path = public, pg_temp
as $$
declare
  v_target text;
begin
  if (p_schema, p_table) = ('public', 'companies') then
    return format('%I.id = $1', p_alias);
  end if;

  if p_via_table is null then
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
     and c.confrelid = to_regclass(p_via_table)
     and cardinality(c.conkey) = 1
     and f.attname = p_via_column;
  if v_target is null then
    raise exception 'unknown_table: %.% says it reaches a company through % to %, and no foreign key does that',
      p_schema, p_table, p_via_column, p_via_table;
  end if;

  return format('%I.%I in (select via.%I from %s via where via.company_id = $1)',
                p_alias, p_via_column, v_target, to_regclass(p_via_table)::text);
end;
$$;

comment on function company_archive_predicate_via(text, text, text, text, text) is
  'The condition of company_archive_predicate(), from a line of company_archive_tables() the caller already holds: a loop over the tables of an archive builds it without listing them again for each one.';

create or replace function company_archive_predicate(p_schema text, p_table text, p_alias text)
returns text
language plpgsql
stable
set search_path = public, pg_temp
as $$
declare
  v_row record;
begin
  if (p_schema, p_table) = ('public', 'companies') then
    return company_archive_predicate_via(p_schema, p_table, null, null, p_alias);
  end if;

  select * into v_row from company_archive_tables() t
   where t.table_schema = p_schema and t.table_name = p_table;
  if not found then
    raise exception 'unknown_table: %.% is not a table an archive knows', p_schema, p_table;
  end if;

  return company_archive_predicate_via(p_schema, p_table, v_row.via_column, v_row.via_table, p_alias);
end;
$$;

comment on function company_archive_predicate(text, text, text) is
  'The SQL condition that keeps the rows of one company in one table, with the company as `$1`. One place, read by the export, by the count and by the checks of an import.';

create or replace function company_archive_rows_query(p_schema text, p_table text, p_where text)
returns text
language plpgsql
stable
set search_path = public, pg_temp
as $$
declare
  v_class    regclass := to_regclass(format('%I.%I', p_schema, p_table));
  v_columns  text;
  v_decimals text;
  v_order    text;
begin
  -- Every column but an identity.
  select string_agg(format('t.%I', a.attname), ', ' order by a.attnum)
    into v_columns
    from pg_attribute a
   where a.attrelid = v_class and a.attnum > 0 and not a.attisdropped and a.attidentity = '';

  -- Decimals leave as text. `12.50` is a valid JSON number and most readers
  -- hand it back as a float; an archive of a ledger must not depend on which.
  select coalesce(' || jsonb_build_object(' ||
                  string_agg(format('%L, x.%I::text', a.attname, a.attname), ', ' order by a.attnum) || ')', '')
    into v_decimals
    from pg_attribute a
   where a.attrelid = v_class
     and a.attnum > 0 and not a.attisdropped
     and a.atttypid = 'numeric'::regtype;

  if exists (select 1 from pg_index i
               join pg_attribute a on a.attrelid = i.indrelid and a.attnum = any (i.indkey)
              where i.indrelid = v_class and i.indisprimary and a.attidentity <> '') then
    select string_agg(format('x.%I', a.attname), ', ' order by a.attnum)
      into v_order
      from pg_attribute a
     where a.attrelid = v_class and a.attnum > 0 and not a.attisdropped and a.attidentity = '';
  else
    select string_agg(format('x.%I', a.attname), ', ' order by array_position(i.indkey::smallint[], a.attnum))
      into v_order
      from pg_index i
      join pg_attribute a on a.attrelid = i.indrelid and a.attnum = any (i.indkey)
     where i.indrelid = v_class and i.indisprimary;
  end if;
  if v_order is null then
    raise exception 'unknown_table: %.% has no primary key, so its rows have no order to be written in', p_schema, p_table;
  end if;

  return format('select to_jsonb(x)%s as r, row_number() over (order by %s) as n from (select %s from %I.%I t where %s) x',
                v_decimals, v_order, v_columns, p_schema, p_table, p_where);
end;
$$;

comment on function company_archive_rows_query(text, text, text) is
  'The query that writes the rows of one table of an archive, given the condition that keeps one company (`$1`): `r`, one JSON object a row — decimals as text, no identity column — and `n`, its place in primary key order, or, for a table whose primary key is an identity, in the order of every column that leaves. The one definition both export_company_table() and export_company_archive() read their rows through.';

create or replace function company_archive_row_counts(p_company_id uuid)
returns table (table_name text, row_count bigint)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_table record;
  v_count bigint;
begin
  if has_capability(p_company_id, 'company.export') is not true then
    raise exception 'not_allowed: counting the rows of this company needs company.export'
      using errcode = '42501';
  end if;

  for v_table in
    select t.table_schema, t.table_name, t.via_column, t.via_table
      from company_archive_tables() t
     where t.disposition = 'exported'
  loop
    execute format('select count(*) from %I.%I t where %s',
                   v_table.table_schema, v_table.table_name,
                   company_archive_predicate_via(v_table.table_schema, v_table.table_name,
                                                 v_table.via_column, v_table.via_table, 't'))
       into v_count using p_company_id;
    table_name := v_table.table_schema || '.' || v_table.table_name;
    row_count := v_count;
    return next;
  end loop;
end;
$$;

comment on function company_archive_row_counts(uuid) is
  'company_archive_row_count() for every table an archive carries, asked once: how many rows each holds for one company, whatever the caller may read of them. Definer, guarded by company.export, and it answers numbers and nothing else.';

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

  return query execute format('select q.r from (%s) q order by q.n',
                              company_archive_rows_query(v_schema, v_name, v_where))
    using p_company_id;
end;
$$;

comment on function export_company_table(uuid, text) is
  'The rows of one table for one company, one JSON object each, in primary key order — or, for a table whose primary key is an identity, which does not leave, in the order of every column that does: decimals as text, timestamps in UTC. Runs as its caller, needs company.export, refuses when the caller may read fewer rows than the table holds, and refuses while any table of a company is unclassified. Stable, so it reads the snapshot of the statement that calls it: called table after table, it needs a repeatable read transaction around the calls for the tables to agree with each other and with the manifest — which is what the CLI opens — or use export_company(), which is one statement.';

create or replace function export_company_archive(p_company_id uuid, p_with_rows boolean)
returns jsonb
language plpgsql
stable
set search_path = public, pg_temp
set timezone = 'UTC'
as $$
declare
  v_company  companies%rowtype;
  v_problem  record;
  v_catalog  jsonb;
  v_held     jsonb;
  v_table    record;
  v_query    text;
  v_seen     bigint;
  v_data     jsonb;
  v_checksum text;
  v_values   text;
  v_tables   jsonb := '[]'::jsonb;
  v_names    text[] := '{}';
  v_rows     jsonb[] := '{}';
begin
  -- Once per archive, not once per table: the right, the company, the sweep
  -- of the catalogue and the list of tables.
  perform assert_may_export_company(p_company_id);

  select * into v_company from companies c where c.id = p_company_id;
  if not found then
    raise exception 'unknown_company: % is not a company you may read', p_company_id
      using errcode = 'P0002';
  end if;

  select * into v_problem from company_archive_unclassified() limit 1;
  if found then
    raise exception 'unclassified_table: %.% % — an archive that might be incomplete is not written. Classify it in company_archive_registry, or in the archive_tables() of its module.',
      v_problem.table_schema, v_problem.table_name, v_problem.problem
      using errcode = '55006';
  end if;

  select coalesce(jsonb_agg(to_jsonb(t)), '[]'::jsonb) into v_catalog from company_archive_tables() t;
  select coalesce(jsonb_object_agg(c.table_name, c.row_count), '{}'::jsonb)
    into v_held
    from company_archive_row_counts(p_company_id) c;

  for v_table in
    select t.table_schema, t.table_name, t.via_column, t.via_table,
           t.table_schema || '.' || t.table_name as name
      from jsonb_to_recordset(v_catalog)
           as t(table_schema text, table_name text, disposition text, via_column text, via_table text, load_order integer)
     where t.disposition = 'exported'
     order by t.load_order, t.table_schema, t.table_name
  loop
    v_query := company_archive_rows_query(
      v_table.table_schema, v_table.table_name,
      company_archive_predicate_via(v_table.table_schema, v_table.table_name,
                                    v_table.via_column, v_table.via_table, 't'));

    -- One read of the table: the count, both checksums and the rows.
    execute format($sql$
      select count(*),
             jsonb_agg(q.r order by q.n) filter (where $2),
             encode(sha256(convert_to(coalesce(string_agg(q.r::text || E'\n', '' order by q.n), ''), 'UTF8')), 'hex'),
             encode(sha256(convert_to(coalesce(string_agg(canonical_json(q.r)::text || E'\n', '' order by q.n), ''), 'UTF8')), 'hex')
        from (%s) q$sql$, v_query)
       into v_seen, v_data, v_checksum, v_values
      using p_company_id, p_with_rows;

    if v_seen is distinct from (v_held ->> v_table.name)::bigint then
      raise exception 'export_incomplete: % holds % rows for this company and you may read % of them. An archive is whole or it is not written: ask for the reading capability you lack — or, for the table of a module, for the module to be enabled.',
        v_table.name, v_held ->> v_table.name, v_seen
        using errcode = '42501';
    end if;

    v_tables := v_tables || jsonb_build_object(
      'name', v_table.name,
      'file', 'data/' || v_table.name || '.jsonl',
      'rows', v_seen,
      'sha256', v_checksum,
      'values_sha256', v_values);
    if p_with_rows then
      v_names := array_append(v_names, v_table.name);
      v_rows := array_append(v_rows, coalesce(v_data, '[]'::jsonb));
    end if;
  end loop;

  return jsonb_build_object(
    'manifest', jsonb_build_object(
      'format', 'ekwo.company-archive',
      'format_version', 1,
      'exported_at', to_jsonb(now()),
      'exported_by', acting_user(),
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
          from jsonb_to_recordset(v_catalog) as t(table_schema text, table_name text, disposition text, reason text)
         where t.disposition = 'excluded'), '[]'::jsonb),
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
            from attachments a where a.company_id = p_company_id), '[]'::jsonb))),
    'tables', case when p_with_rows then
      coalesce((select jsonb_object_agg(x.name, x.rows) from unnest(v_names, v_rows) as x(name, rows)), '{}'::jsonb)
    end);
end;
$$;

comment on function export_company_archive(uuid, boolean) is
  'The archive of one company, read once: `manifest`, and — when asked for — `tables` keyed by table name. The right, the sweep of the catalogue and the list of tables are asked once, and each table is read once for its count, both checksums and its rows. Runs as its caller and needs company.export; stable, so it reads the snapshot of the statement that calls it. What export_company(), export_company_manifest() and export_company_tables() answer.';

create or replace function export_company_manifest(p_company_id uuid)
returns jsonb
language sql
stable
set search_path = public, pg_temp
set timezone = 'UTC'
as $$
  select export_company_archive(p_company_id, false) -> 'manifest';
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
  select export_company_archive(p_company_id, true) -> 'tables';
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
  -- fails on arrival — after the company has left. The reader is stable and
  -- runs inside the snapshot of this select.
  select export_company_archive(p_company_id, true) into v_archive;
  return v_archive;
end;
$$;

comment on function export_company(uuid) is
  'The whole archive as one document, read in one snapshot: `manifest`, and `tables` keyed by table name. It is what `import_company()` takes, and it writes `company_exported` on the audit trail. A large company is better read table by table, which is what the CLI does; this is the same rows in one answer.';

-- ---------------------------------------------------------------------------
-- 3. The trail asks who reads it once per statement
-- ---------------------------------------------------------------------------

create or replace function caller_companies()
returns uuid[]
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select coalesce(array_agg(x.company_id), '{}'::uuid[])
    from (
      select m.company_id
        from company_members m
       where m.user_id = auth.uid()
      union
      select k.company_id
        from api_keys k
       where k.key_hash = nullif(current_setting('ekwo.api_key', true), '')
    ) x
   where is_company_member(x.company_id);
$$;

comment on function caller_companies() is
  'The companies the current caller is on — the question is_company_member() answers, asked once for all of them, over the only companies where its answer can be yes. What a row level security policy compares company_id against, inside a sub-select, so that it is worked out once per statement instead of once per row.';

alter policy audit_log_select on audit_log
  using (
    case when company_id is null then (select is_instance_admin())
         else company_id = any ((select caller_companies())::uuid[]) or (select is_instance_admin())
    end
  );

-- ---------------------------------------------------------------------------
-- Grants
--
-- The functions of an export are reachable by a signed-in user and guarded
-- inside, which is the doctrine of 20260914151207: the two builders of SQL
-- answer text a caller could write themselves, the count and the archive
-- check company.export before anything else.
-- ---------------------------------------------------------------------------

revoke execute on all functions in schema public from public;

revoke execute on function authenticated_statement_timeout() from public, anon;
revoke execute on function company_archive_predicate_via(text, text, text, text, text) from public, anon;
revoke execute on function company_archive_rows_query(text, text, text) from public, anon;
revoke execute on function company_archive_row_counts(uuid) from public, anon;
revoke execute on function export_company_archive(uuid, boolean) from public, anon;
revoke execute on function caller_companies() from public, anon;

grant execute on function authenticated_statement_timeout() to authenticated, service_role;
grant execute on function company_archive_predicate_via(text, text, text, text, text) to authenticated, service_role;
grant execute on function company_archive_rows_query(text, text, text) to authenticated, service_role;
grant execute on function company_archive_row_counts(uuid) to authenticated, service_role;
grant execute on function export_company_archive(uuid, boolean) to authenticated, service_role;
grant execute on function caller_companies() to authenticated, service_role;
