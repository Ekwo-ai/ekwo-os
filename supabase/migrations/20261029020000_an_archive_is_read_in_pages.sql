-- ---------------------------------------------------------------------------
-- An archive is read in pages
-- ---------------------------------------------------------------------------
-- A nightly copy of a company over the API is one call, `export_company()`,
-- and one statement: the whole company inside one request. `20261027073538`
-- gave that request five minutes. A company of ten years, or of a few
-- thousand pieces, meets those five minutes too; no clock is long enough for
-- every company, and a request that holds a whole company is the thing to
-- stop doing (decision 0092).
--
-- So an archive can be read in pages, each its own short request, and written
-- by the client as the same files, byte for byte:
--
--   1. `export_company_outline(company)` is the manifest without checksums:
--      the company, its packs and modules, the tables an archive carries in
--      the order an import fills them, how many rows each holds for this
--      company, the tables left behind and the files listed. It asks the
--      right, sweeps the catalogue for an unclassified table and counts —
--      it reads no row.
--   2. `export_company_page(company, table, after, limit)` is up to `limit`
--      rows of one table, in the order of the archive, after the cursor the
--      page before it answered: `lines`, the exact text of the data file for
--      those rows; `canonical`, the canonical form of the rows whose form
--      differs, by their place in the page, so that the client can compute
--      `values_sha256` as the database would; and `after`, the cursor of the
--      next page, null on the last one. A table ordered by its primary key is
--      paged on that key, which no row lacks; a table whose primary key is an
--      identity (the trail), ordered by every column that leaves, is paged by
--      position.
--
-- **Each page is its own snapshot.** Between the outline and the last page the
-- books may move. The client asks the outline again at the end and compares:
-- a row added or removed anywhere changes a count, and every act that changes
-- a posted figure — a posting, a matching, a payment, a closing — writes a
-- line on the trail, which is itself a table of the archive. Counts that
-- moved, or a table read with another number of rows than its outline gave,
-- and the archive is not kept. One statement remains the way to one snapshot:
-- `export_company()`, or `export_company_table()` inside one `repeatable read`
-- transaction, as the command line reads.
--
-- **The bytes do not move.** The manifest is built in one place,
-- `company_archive_manifest()`, which `export_company_archive()` now calls
-- instead of building its own; the columns, the decimals and the order of a
-- table are read in one place, `company_archive_row_shape()`, which
-- `company_archive_rows_query()` and the new `company_archive_page_query()`
-- both use. `tests/archive_in_pages.test.ts` holds `export_company()` equal
-- to itself across this file, and a company read in pages of two rows equal
-- to the same company read in one statement.
-- ---------------------------------------------------------------------------

-- ---------------------------------------------------------------------------
-- 1. The shape of the rows of a table, read once
-- ---------------------------------------------------------------------------

create or replace function company_archive_row_shape(
  p_schema        text,
  p_table         text,
  out columns     text,
  out decimals    text,
  out order_columns text[],
  out key_types   text[],
  out keyset      boolean
)
language plpgsql
stable
set search_path = ekwo, pg_temp
as $$
declare
  v_class regclass := to_regclass(format('%I.%I', p_schema, p_table));
begin
  -- Every column but an identity.
  select string_agg(format('t.%I', a.attname), ', ' order by a.attnum)
    into columns
    from pg_attribute a
   where a.attrelid = v_class and a.attnum > 0 and not a.attisdropped and a.attidentity = '';

  -- Decimals leave as text. `12.50` is a valid JSON number and most readers
  -- hand it back as a float; an archive of a ledger must not depend on which.
  select coalesce(' || jsonb_build_object(' ||
                  string_agg(format('%L, x.%I::text', a.attname, a.attname), ', ' order by a.attnum) || ')', '')
    into decimals
    from pg_attribute a
   where a.attrelid = v_class
     and a.attnum > 0 and not a.attisdropped
     and a.atttypid = 'numeric'::regtype;

  keyset := not exists (select 1 from pg_index i
                          join pg_attribute a on a.attrelid = i.indrelid and a.attnum = any (i.indkey)
                         where i.indrelid = v_class and i.indisprimary and a.attidentity <> '');

  if keyset then
    -- The primary key, in the order of its index: no column of it is null, so
    -- a row comparison against the last key read is the next page.
    select array_agg(a.attname::text order by array_position(i.indkey::smallint[], a.attnum)),
           array_agg(format_type(a.atttypid, a.atttypmod) order by array_position(i.indkey::smallint[], a.attnum))
      into order_columns, key_types
      from pg_index i
      join pg_attribute a on a.attrelid = i.indrelid and a.attnum = any (i.indkey)
     where i.indrelid = v_class and i.indisprimary;
  else
    -- An identity does not leave, so the rows are in the order of every column
    -- that does.
    select array_agg(a.attname::text order by a.attnum)
      into order_columns
      from pg_attribute a
     where a.attrelid = v_class and a.attnum > 0 and not a.attisdropped and a.attidentity = '';
  end if;

  if order_columns is null then
    raise exception 'unknown_table: %.% has no primary key, so its rows have no order to be written in', p_schema, p_table;
  end if;
end;
$$;

comment on function company_archive_row_shape(text, text) is
  'How the rows of one table leave in an archive: the columns (every one but an identity), the decimals written again as text, and the order — the primary key, with its types and `keyset` true, or, for a table whose primary key is an identity, every column that leaves. The one place company_archive_rows_query() and company_archive_page_query() read it from.';

create or replace function company_archive_rows_query(p_schema text, p_table text, p_where text)
returns text
language plpgsql
stable
set search_path = ekwo, pg_temp
as $$
declare
  v_shape record := company_archive_row_shape(p_schema, p_table);
  v_order text;
begin
  select string_agg(format('x.%I', c.name), ', ' order by c.n)
    into v_order
    from unnest(v_shape.order_columns) with ordinality as c(name, n);

  return format('select to_jsonb(x)%s as r, row_number() over (order by %s) as n from (select %s from %I.%I t where %s) x',
                v_shape.decimals, v_order, v_shape.columns, p_schema, p_table, p_where);
end;
$$;

comment on function company_archive_rows_query(text, text, text) is
  'The query that writes the rows of one table of an archive, given the condition that keeps one company (`$1`): `r`, one JSON object a row — decimals as text, no identity column — and `n`, its place in primary key order, or, for a table whose primary key is an identity, in the order of every column that leaves. The one definition both export_company_table() and export_company_archive() read their rows through; its shape is company_archive_row_shape().';

create or replace function company_archive_page_query(p_schema text, p_table text, p_where text)
returns text
language plpgsql
stable
set search_path = ekwo, pg_temp
as $$
declare
  v_shape  record := company_archive_row_shape(p_schema, p_table);
  v_inner  text;
  v_outer  text;
  v_after  text;
  v_cursor text;
begin
  select string_agg(format('t.%I', c.name), ', ' order by c.n),
         string_agg(format('x.%I', c.name), ', ' order by c.n)
    into v_inner, v_outer
    from unnest(v_shape.order_columns) with ordinality as c(name, n);

  if v_shape.keyset then
    -- After the key of the last row read, cast back to the type of its column.
    select format('(%s) > (%s)', v_inner,
                  string_agg(format('($2 ->> %L)::%s', c.name, c.type), ', ' order by c.n)),
           format('jsonb_build_object(%s)',
                  string_agg(format('%L, x.%I::text', c.name, c.name), ', ' order by c.n))
      into v_after, v_cursor
      from unnest(v_shape.order_columns, v_shape.key_types) with ordinality as c(name, type, n);

    return format(
      'select to_jsonb(x)%s as r, row_number() over (order by %s) as n, %s as k '
      'from (select %s from %I.%I t where %s and ($2 is null or %s) order by %s limit $3) x',
      v_shape.decimals, v_outer, v_cursor,
      v_shape.columns, p_schema, p_table, p_where, v_after, v_inner);
  end if;

  -- By position: the order has no key a cursor could name.
  return format(
    'select to_jsonb(x)%s as r, row_number() over (order by %s) as n, '
    'jsonb_build_object(''offset'', coalesce(($2 ->> ''offset'')::bigint, 0) + row_number() over (order by %s)) as k '
    'from (select %s from %I.%I t where %s order by %s offset coalesce(($2 ->> ''offset'')::bigint, 0) limit $3) x',
    v_shape.decimals, v_outer, v_outer,
    v_shape.columns, p_schema, p_table, p_where, v_inner);
end;
$$;

comment on function company_archive_page_query(text, text, text) is
  'The query that writes one page of the rows of one table of an archive: the condition that keeps one company is `$1`, the cursor of the page before is `$2` (null for the first) and the size of the page `$3`. Answers `r` and `n` as company_archive_rows_query() does, in the same order, and `k`, the cursor that follows the row: its primary key, or its position for a table whose primary key is an identity.';

-- ---------------------------------------------------------------------------
-- 2. The manifest, built in one place
-- ---------------------------------------------------------------------------

create or replace function company_archive_catalog(p_company_id uuid)
returns jsonb
language plpgsql
stable
set search_path = ekwo, pg_temp
as $$
declare
  v_problem record;
  v_catalog jsonb;
begin
  perform assert_may_export_company(p_company_id);

  if not exists (select 1 from companies c where c.id = p_company_id) then
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
  return v_catalog;
end;
$$;

comment on function company_archive_catalog(uuid) is
  'What every reading of an archive asks first, once: the right to export, the company, the sweep for an unclassified table, and the list of tables with their disposition, as JSON. Raises what an export raises.';

create or replace function company_archive_manifest(p_company_id uuid, p_catalog jsonb, p_tables jsonb)
returns jsonb
language plpgsql
stable
set search_path = ekwo, pg_temp
set timezone = 'UTC'
as $$
begin
  -- Called by the readers of an archive, which have asked already; asked
  -- again so that nobody learns, from this alone, what they could not export.
  perform assert_may_export_company(p_company_id);

  return jsonb_build_object(
      'format', 'ekwo.company-archive',
      'format_version', 1,
      'exported_at', to_jsonb(now()),
      'exported_by', acting_user(),
      'socle_version', ekwo_schema_version(),
      'origin_instance', (select i.instance_id from instance i),
      'company', (select jsonb_build_object(
                           'id', c.id,
                           'name', c.name,
                           'country', c.country,
                           'fiscal_country', c.fiscal_country,
                           'currency_code', c.currency_code)
                    from companies c where c.id = p_company_id),
      'packs', coalesce((
        select jsonb_agg(jsonb_build_object('country', p.country, 'version', p.version, 'chart_code', p.chart_code)
                         order by p.country)
          from company_packs p where p.company_id = p_company_id), '[]'::jsonb),
      'modules', coalesce((
        select jsonb_agg(jsonb_build_object('code', m.code, 'version', m.version) order by m.code)
          from company_modules cm join modules m on m.code = cm.module_code
         where cm.company_id = p_company_id), '[]'::jsonb),
      'tables', p_tables,
      'excluded', coalesce((
        select jsonb_agg(jsonb_build_object('name', t.table_schema || '.' || t.table_name, 'reason', t.reason)
                         order by t.table_schema, t.table_name)
          from jsonb_to_recordset(p_catalog) as t(table_schema text, table_name text, disposition text, reason text)
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
            from attachments a where a.company_id = p_company_id), '[]'::jsonb)));
end;
$$;

comment on function company_archive_manifest(uuid, jsonb, jsonb) is
  'The manifest of an archive of one company around the entries of its tables: the format, the socle, the packs and modules it needs, the tables left behind with the reason and the files its attachments point at. The one place export_company_archive() and export_company_outline() build it.';

create or replace function export_company_archive(p_company_id uuid, p_with_rows boolean)
returns jsonb
language plpgsql
stable
set search_path = ekwo, pg_temp
set timezone = 'UTC'
as $$
declare
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
  v_catalog := company_archive_catalog(p_company_id);
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
    'manifest', company_archive_manifest(p_company_id, v_catalog, v_tables),
    'tables', case when p_with_rows then
      coalesce((select jsonb_object_agg(x.name, x.rows) from unnest(v_names, v_rows) as x(name, rows)), '{}'::jsonb)
    end);
end;
$$;

comment on function export_company_archive(uuid, boolean) is
  'The archive of one company, read once: `manifest`, and — when asked for — `tables` keyed by table name. The right, the sweep of the catalogue and the list of tables are asked once, and each table is read once for its count, both checksums and its rows. Runs as its caller and needs company.export; stable, so it reads the snapshot of the statement that calls it. What export_company(), export_company_manifest() and export_company_tables() answer.';

-- ---------------------------------------------------------------------------
-- 3. The outline and the page
-- ---------------------------------------------------------------------------

create or replace function export_company_outline(p_company_id uuid)
returns jsonb
language plpgsql
stable
set search_path = ekwo, pg_temp
set timezone = 'UTC'
set statement_timeout = '5min'
as $$
declare
  v_catalog jsonb := company_archive_catalog(p_company_id);
  v_tables  jsonb;
begin
  select coalesce(jsonb_agg(jsonb_build_object(
           'name', t.table_schema || '.' || t.table_name,
           'file', 'data/' || t.table_schema || '.' || t.table_name || '.jsonl',
           'rows', c.row_count)
           order by t.load_order, t.table_schema, t.table_name), '[]'::jsonb)
    into v_tables
    from jsonb_to_recordset(v_catalog)
         as t(table_schema text, table_name text, disposition text, load_order integer)
    join company_archive_row_counts(p_company_id) c on c.table_name = t.table_schema || '.' || t.table_name
   where t.disposition = 'exported';

  return company_archive_manifest(p_company_id, v_catalog, v_tables);
end;
$$;

comment on function export_company_outline(uuid) is
  'The manifest of an archive of one company before a row is read: every table with the number of rows it holds for the company, and no checksum. The first and the last call of an archive read in pages (decision 0092): the two have to agree, or the books moved while they were read. Runs as its caller, needs company.export, refuses while any table of a company is unclassified.';

create or replace function export_company_page(
  p_company_id uuid,
  p_table      text,
  p_after      jsonb default null,
  p_limit      integer default 5000
)
returns jsonb
language plpgsql
stable
set search_path = ekwo, pg_temp
set timezone = 'UTC'
set statement_timeout = '5min'
as $$
declare
  v_schema text := split_part(p_table, '.', 1);
  v_name   text := split_part(p_table, '.', 2);
  v_rows   bigint;
  v_lines  text;
  v_canon  jsonb;
  v_last   jsonb;
begin
  perform assert_may_export_company(p_company_id);

  if p_limit is null or p_limit < 1 or p_limit > 50000 then
    raise exception 'invalid_page_size: a page holds from 1 to 50000 rows, and % were asked for', coalesce(p_limit::text, 'none');
  end if;

  if not exists (select 1 from company_archive_tables() t
                  where t.table_schema = v_schema and t.table_name = v_name
                    and t.disposition = 'exported') then
    raise exception 'unknown_table: % is not a table an archive carries', p_table;
  end if;

  execute format($sql$
    select count(*),
           coalesce(string_agg(q.r::text || E'\n', '' order by q.n), ''),
           coalesce(jsonb_object_agg(q.n::text, canonical_json(q.r)::text)
                      filter (where canonical_json(q.r)::text <> q.r::text), '{}'::jsonb),
           (array_agg(q.k order by q.n desc))[1]
      from (%s) q$sql$,
    company_archive_page_query(v_schema, v_name, company_archive_predicate(v_schema, v_name, 't')))
     into v_rows, v_lines, v_canon, v_last
    using p_company_id, p_after, p_limit;

  return jsonb_build_object(
    'table', p_table,
    'rows', v_rows,
    'lines', v_lines,
    'canonical', v_canon,
    'after', case when v_rows < p_limit then null else v_last end);
end;
$$;

comment on function export_company_page(uuid, text, jsonb, integer) is
  'Up to `p_limit` rows of one table of the archive of one company, after the cursor `p_after` the page before answered (null for the first page), in the order of the archive: `lines`, the exact text of the data file for those rows, a line feed after each; `canonical`, the canonical form of the rows whose form differs from `lines`, keyed by their place in the page from 1, which is what values_sha256 is computed over; `rows`; and `after`, the cursor of the next page, null on the last. Each page is its own snapshot: a client compares export_company_outline() before the first page and after the last (decision 0092). Runs as its caller and needs company.export.';

-- ---------------------------------------------------------------------------
-- Grants
--
-- Reachable by a signed-in user and guarded inside, as every function of an
-- export: the builders of SQL answer text a caller could write themselves,
-- and the outline and the page check company.export before anything else.
-- ---------------------------------------------------------------------------

revoke execute on all functions in schema ekwo from public;

revoke execute on function company_archive_row_shape(text, text) from public, anon;
revoke execute on function company_archive_page_query(text, text, text) from public, anon;
revoke execute on function company_archive_catalog(uuid) from public, anon;
revoke execute on function company_archive_manifest(uuid, jsonb, jsonb) from public, anon;
revoke execute on function export_company_outline(uuid) from public, anon;
revoke execute on function export_company_page(uuid, text, jsonb, integer) from public, anon;

grant execute on function company_archive_row_shape(text, text) to authenticated, service_role;
grant execute on function company_archive_page_query(text, text, text) to authenticated, service_role;
grant execute on function company_archive_catalog(uuid) to authenticated, service_role;
grant execute on function company_archive_manifest(uuid, jsonb, jsonb) to authenticated, service_role;
grant execute on function export_company_outline(uuid) to authenticated, service_role;
grant execute on function export_company_page(uuid, text, jsonb, integer) to authenticated, service_role;
