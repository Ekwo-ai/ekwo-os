-- Ekwo OS — an archive survives an honest reader printing it again.
--
-- The archive is rows as JSON, and the checksum of a table is the sha256 of
-- the bytes the database wrote, one row per line. That is exactly the file the
-- CLI writes, so `shasum` checks an archive without Ekwo — a property worth
-- keeping, and kept here.
--
-- It also means the checksum answers a question about **text**. Anything that
-- stores the archive, streams it, or moves it between two services parses it
-- and prints it again, and that changes the text without changing one value.
-- The reader gets `archive_corrupt`, with the same row count and another
-- checksum, which reads like a damaged archive and is not one.
--
-- **One thing changes, and only one.** `jsonb` normalises key order and
-- whitespace on both sides, so the round trip is invisible — except for
-- numbers **nested inside a jsonb column**. PostgreSQL keeps the trailing
-- zeros of `1230.00`; a JSON parser hands back `1230`. The rule that decimals
-- leave as text was written for exactly this hazard and it protects the
-- `numeric` columns, which it converts on the way out. It cannot reach inside
-- a `jsonb` one, and `audit_log.old_values` and `new_values` are full of
-- amounts. So the table that fails is the audit trail, every time, and the
-- books look fine beside it.
--
-- The CLI knows this and says so where it exports: "the rows are never parsed
-- here". Nothing made it fail early for anybody else.
--
-- ---------------------------------------------------------------------------
-- Two checksums, because there are two questions
-- ---------------------------------------------------------------------------
--
-- Answering only one of them means losing the other, so the manifest carries
-- both, per table:
--
--   `sha256`         the bytes the database wrote. What `shasum` checks on
--                    `data/<table>.jsonl`, and what the CLI verifies when it
--                    writes an archive and when it reads one back from disk.
--                    Unchanged, byte for byte, from what 0.8.0 wrote.
--
--   `values_sha256`  the same rows in a canonical form, which any reader
--                    reproduces after parsing them. This is what
--                    `import_company()` checks.
--
-- **The canonical form is the rows with every nested number normalised**, and
-- nothing else: `canonical_json()` walks a value and re-renders each number
-- through `trim_scale()`, so `1230.00` and `1230` become the same thing on
-- both sides. Key order and whitespace are already `jsonb`'s own business. The
-- data files do not change: this is a second way of reading the same rows, not
-- a second way of writing them.
--
-- **What it guarantees and what it does not.** A changed value, an added row,
-- a removed row, a row of another company: all refused, exactly as before —
-- the canonical form is a normalisation of the numbers' *notation* and never
-- of their magnitude, so `1230.00` and `1230.01` stay two different archives.
-- What it stops refusing is a reader that printed the same values again.
--
-- It does not guarantee that a reader can lose precision for free. A number
-- with more significant digits than a double carries does not survive a JSON
-- parser, and an archive that went through one is refused — which is the right
-- answer, because the value really did change. No column of this schema stores
-- such a number inside a `jsonb`, and the refusal is there for the day one
-- does.
--
-- **An archive written before this migration carries only `sha256`**, and
-- `import_company()` checks that one for it, as it always did. Its refusal now
-- says why the bytes may differ and what to do about it, instead of naming a
-- checksum and stopping.

create or replace function canonical_json(p_value jsonb)
returns jsonb
language plpgsql
immutable
set search_path = public, pg_temp
as $$
declare
  v_out jsonb;
begin
  case jsonb_typeof(p_value)
    when 'number' then
      -- `trim_scale` drops the trailing zeros a JSON parser drops, and keeps
      -- every significant digit. It is the whole of the normalisation.
      return to_jsonb(trim_scale(p_value::text::numeric));
    when 'object' then
      select coalesce(jsonb_object_agg(e.k, canonical_json(e.v)), '{}'::jsonb)
        into v_out from jsonb_each(p_value) as e(k, v);
      return v_out;
    when 'array' then
      select coalesce(jsonb_agg(canonical_json(e.v) order by e.n), '[]'::jsonb)
        into v_out from jsonb_array_elements(p_value) with ordinality as e(v, n);
      return v_out;
    else
      return p_value;
  end case;
end;
$$;

comment on function canonical_json(jsonb) is
  'A value with every number it holds, at any depth, re-rendered through trim_scale(): the form two sides agree on once a JSON parser has been between them. What the `values_sha256` of an archive is computed over. Normalises notation and never magnitude.';

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
  v_values   text;
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
           encode(sha256(convert_to(coalesce(string_agg(x.r::text || E'\n', '' order by x.n), ''), 'UTF8')), 'hex'),
           encode(sha256(convert_to(coalesce(string_agg(canonical_json(x.r)::text || E'\n', '' order by x.n), ''), 'UTF8')), 'hex')
      into v_rows, v_checksum, v_values
      from export_company_table(p_company_id, v_table.name) with ordinality as x(r, n);

    v_tables := v_tables || jsonb_build_object(
      'name', v_table.name,
      'file', 'data/' || v_table.name || '.jsonl',
      'rows', v_rows,
      'sha256', v_checksum,
      'values_sha256', v_values);
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
  'What an archive of this company is: the format and its version, the socle, the packs and the modules an installation needs to take it in, every table with its row count, the sha256 of the bytes its file holds and the sha256 of its values, the tables left behind with the reason, and the list of the files the attachments point at — which the archive does not carry.';

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
  v_values    text;
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
    -- Two checksums, and the manifest says which one this archive carries.
    -- `values_sha256` is over the canonical form of the rows, which a reader
    -- reproduces after parsing them; `sha256` is over the bytes the database
    -- wrote, which is what `shasum` checks on the file and what an archive
    -- from 0.8.0 or earlier carries alone. Whichever is checked, the answer to
    -- a changed value is the same refusal.
    select count(*),
           encode(sha256(convert_to(coalesce(string_agg(x.r::text || E'\n', '' order by x.n), ''), 'UTF8')), 'hex'),
           encode(sha256(convert_to(coalesce(string_agg(canonical_json(x.r)::text || E'\n', '' order by x.n), ''), 'UTF8')), 'hex')
      into v_count, v_checksum, v_values
      from jsonb_array_elements(v_rows) with ordinality as x(r, n);
    if v_count is distinct from (v_item ->> 'rows')::bigint then
      raise exception 'archive_corrupt: % does not match its manifest (% rows against %)',
        v_name, v_count, v_item ->> 'rows';
    end if;
    if v_item ? 'values_sha256' then
      if v_values is distinct from v_item ->> 'values_sha256' then
        raise exception 'archive_corrupt: the values of % are not the ones its manifest was written for', v_name;
      end if;
    elsif v_checksum is distinct from v_item ->> 'sha256' then
      raise exception 'archive_corrupt: % does not match its manifest (another checksum). An archive written before 0.9.0 carries a checksum of its bytes, so a reader that printed it again changed them — keep the archive as the database wrote it, or export it again.',
        v_name;
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
  'Takes one company archive into this installation, whole or not at all. Checks the manifest against the values of the rows — `values_sha256`, which a reader reproduces after parsing the archive — and against their bytes for an archive written before 0.9.0.';

revoke execute on all functions in schema public from public;

revoke execute on function canonical_json(jsonb) from public, anon;
grant execute on function canonical_json(jsonb) to authenticated, service_role;
revoke execute on function export_company_manifest(uuid) from public, anon;
grant execute on function export_company_manifest(uuid) to authenticated, service_role;
revoke execute on function import_company(jsonb, uuid) from public, anon;
grant execute on function import_company(jsonb, uuid) to authenticated, service_role;
