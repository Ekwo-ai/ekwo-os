-- ---------------------------------------------------------------------------
-- A tenant measures nothing of another
-- ---------------------------------------------------------------------------
-- Decision 0065 lets an operator share one installation between people who do
-- not know each other, and promises that none of them sees, reaches, measures
-- or learns of the existence of another's rows. `20261007060225` closed what
-- answered *about* a company. An outside reading of the branch found eight
-- ways that remained, none of which the sweep of that migration could see,
-- because the sweep only read and only named an id as an argument. This file
-- closes them; `tests/shared_instance.test.ts` now also writes, names ids
-- inside objects and lists, walks every schema that holds a company's rows,
-- and checks that nothing a person reads moves when somebody else works.
--
--   1. **The trail had one counter for the installation.** `audit_log.id` is
--      an identity, and members read it: the gap between two ids of one's own
--      company was the number of changes every other company made in between.
--      The column is no longer granted to a signed-in user. A reader orders
--      the trail by `occurred_at` and `sequence`, the order of a change among
--      those its transaction made to the same company — a counter that counts
--      nothing but what the reader may already read. An archive leaves without
--      the id, which it never carried across anyway: it was drawn again on
--      arrival.
--   2. **The administrators.** On a shared installation nobody claims it,
--      `share_instance()` needs an administrator to exist, and the last one
--      does not leave: an installation with none would be claimed by the first
--      person to sign in, and an administrator reaches every company.
--   3. **Four guards quoted another company's numbers.** The triggers that
--      keep a posted document, its lines, a posted entry and its lines from
--      moving are definer, run before row level security, and read the row a
--      new value names before anything said it was the caller's. They now look
--      for it in the row's own company, and a person or a key writing a row
--      into a company they may not know of is refused before anything is
--      read, with one answer whatever the company. Everybody else — the
--      backend role, the owner, a scheduled job — meets every guard as before.
--   4. **A preference named any company.** `user_preferences` refused a
--      company that does not exist by its foreign key, and so said which ones
--      do. A company the caller may not know of is now refused first, with
--      the same answer as one that does not exist.
--   5. **References by id alone.** A column that names a row of a company's
--      table by its id named it in any company. Every such reference of the
--      socle is now a composite key with `company_id` (the modules do the same
--      in their own migrations), so a row only ever names a row of its own
--      company — and another company cannot plant a reference that keeps one
--      of yours from being deleted. `companies` is one of those tables: its
--      own id is its company, and its default accounts and journals name rows
--      of that company only. A row written before that names a row of another
--      company stops the migration before it changes anything, with every
--      such row counted by table and column. A deposit of a declaration,
--      which reaches its company through the declaration, names files of that
--      company only.
--   6. **Two keys on one column.** Where a column carried both its old key
--      and the composite one, an id of another company failed the second and
--      an id of nobody the first: two constraint names for two facts. The
--      single key goes, its delete action kept on the composite one.
--   7. **A credit note of anybody's.** `documents.reversed_document_id` is now
--      one of those composite keys, and the cancellation guard looks for the
--      credit note in the invoice's own company: nobody else's note can keep
--      an invoice from being cancelled.
--   8. **The allowance counted ownership.** `create_company()` counted the
--      companies a person owned, which handing one to a second account reset.
--      A company now records who created it, the creator stays written, and
--      the allowance counts that.
--
-- Nothing here changes an answer on an installation that is not shared, but
-- three: a signed-in user selects the columns of `audit_log` by name rather
-- than with `*`, a reference that named a row of another company is refused
-- by its composite key, and the error a reference to nothing gives names
-- that key.
-- ---------------------------------------------------------------------------

-- ---------------------------------------------------------------------------
-- 0. Before anything: no row names a row of another company already
-- ---------------------------------------------------------------------------
--
-- Section 5 turns every reference by id alone into a composite key with the
-- company, and validates it over every row. A row written before this that
-- names a row of another company would fail that key half-way through, with
-- the bare words of a foreign key and nothing to say which rows. So the
-- migration first asks, of every key it is about to create, which rows would
-- fail it — one anti-join per key, on the index of the row it names — and
-- says all of them at once, by table, column and count, before it changes
-- anything. It quotes no value: the operator reads the rows themselves.

-- The column a table names its company by: `company_id`, or, for `companies`
-- itself, its own id. Null for a table that holds no company's rows.
create or replace function company_column(p_table regclass)
returns text
language sql
stable
set search_path = public, pg_temp
as $$
  select case
           when p_table = 'public.companies'::regclass then 'id'
           when exists (select 1 from pg_attribute a
                         where a.attrelid = p_table and a.attname = 'company_id' and not a.attisdropped)
             then 'company_id'
         end;
$$;

comment on function company_column(regclass) is
  'The column a table names its company by: company_id, or id for companies itself, whose own id is its company. Null for a table that holds no company''s rows. For migrations (decision 0065).';

-- Every reference of a schema, by one uuid column, from a table that holds a
-- company's rows to another table that does: the keys section 5 makes
-- composite. Read from the catalogue, so a table added later is one of them
-- without anybody listing it.
create or replace function company_references_by_id(p_schema text)
returns table (conname text, conrelid regclass, confrelid regclass, confdeltype "char",
               condeferrable boolean, condeferred boolean,
               col text, fcol text, ccol text, relname text, target_name text,
               source text, target text)
language sql
stable
set search_path = public, pg_temp
as $$
  select f.conname::text, f.conrelid::regclass, f.confrelid::regclass, f.confdeltype,
         f.condeferrable, f.condeferred,
         a.attname::text, fa.attname::text, company_column(f.conrelid),
         rel.relname::text, trel.relname::text,
         format('%I.%I', n.nspname, rel.relname), format('%I.%I', tn.nspname, trel.relname)
    from pg_constraint f
    join pg_class rel on rel.oid = f.conrelid
    join pg_namespace n on n.oid = rel.relnamespace
    join pg_class trel on trel.oid = f.confrelid
    join pg_namespace tn on tn.oid = trel.relnamespace
    join pg_attribute a on a.attrelid = f.conrelid and a.attnum = f.conkey[1]
    join pg_attribute fa on fa.attrelid = f.confrelid and fa.attnum = f.confkey[1]
   where f.contype = 'f'
     and cardinality(f.conkey) = 1
     and n.nspname = p_schema
     and f.confrelid <> 'public.companies'::regclass
     and a.atttypid = 'uuid'::regtype
     and company_column(f.conrelid) is not null
     and a.attname::text <> company_column(f.conrelid)
     and company_column(f.confrelid) = 'company_id'
   order by rel.relname, a.attname, f.conname;
$$;

comment on function company_references_by_id(text) is
  'Every foreign key of a schema by one uuid column from a table that holds a company''s rows (company_column()) to another table that does: what scope_references_to_company() makes composite. For migrations (decision 0065).';

create or replace function assert_references_within_company(p_schema text)
returns void
language plpgsql
set search_path = public, pg_temp
as $$
declare
  r       record;
  v_rows  bigint;
  v_total bigint := 0;
  v_found text[] := '{}';
begin
  for r in select * from company_references_by_id(p_schema) loop
    execute format(
      'select count(*) from %s c
        where c.%I is not null and c.%I is not null
          and not exists (select 1 from %s t where t.%I = c.%I and t.company_id = c.%I)',
      r.conrelid, r.col, r.ccol, r.confrelid, r.fcol, r.col, r.ccol)
      into v_rows;
    if v_rows > 0 then
      v_total := v_total + v_rows;
      v_found := v_found || format('%s.%s names %s of another company in %s row%s',
                                   r.source, r.col, r.target, v_rows, case when v_rows = 1 then '' else 's' end);
    end if;
  end loop;

  if cardinality(v_found) > 0 then
    raise exception 'reference_across_companies: % row% of schema % name a row of another company, which a key with the company refuses from this migration on (decision 0065): %. Nothing was changed.',
      v_total, case when v_total = 1 then '' else 's' end, p_schema, array_to_string(v_found, '; ')
      using errcode = '23503',
            hint = 'Point each of these columns at a row of its own row''s company, or empty it, then run the migration again. A row names the row of the other table whose id it holds and whose company_id differs from its own.';
  end if;
end;
$$;

comment on function assert_references_within_company(text) is
  'Raises reference_across_companies, naming every table and column and how many rows, when a row of the schema names a row of another company by a key scope_references_to_company() is about to make composite. One anti-join per key, run before anything changes. For migrations (decision 0065).';

do $$
begin
  perform assert_references_within_company('public');
end;
$$;

-- ---------------------------------------------------------------------------
-- 1. The trail counts nothing a reader may not read
-- ---------------------------------------------------------------------------

alter table audit_log add column if not exists sequence integer not null default 0;

comment on column audit_log.sequence is
  'The order of this change among those its transaction made to the same company (or to the installation itself), from 1. With occurred_at, the order a reader sorts the trail by. It counts nothing but rows of that company: unlike id, which is the installation''s, it says nothing of anybody else''s work (decision 0065). 0 on a row an archive brought in from an installation that did not write it.';

comment on column audit_log.id is
  'The row''s number in the installation. Not granted to a signed-in user: the gap between two ids of one company is the work of every other company in between. Read the trail in the order of occurred_at and sequence.';

-- The rows already written get the order they were written in. The trail is
-- append-only to every client and, by its trigger, to the owner as well; the
-- migration lifts that trigger for this one statement, which writes nothing
-- but the new column, and puts it back.
alter table audit_log disable trigger audit_log_append_only;
update audit_log l
   set sequence = o.n
  from (select id, row_number() over (partition by company_id, occurred_at order by id) as n from audit_log) o
 where o.id = l.id;
alter table audit_log enable trigger audit_log_append_only;

create or replace function audit_record(p_company_id uuid, p_table text, p_record_id uuid, p_record_key text, p_operation audit_operation, p_action text default NULL::text, p_old jsonb default NULL::jsonb, p_new jsonb default NULL::jsonb)
returns bigint
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  -- One counter per company and per transaction, kept in a setting local to
  -- the transaction: no lock, no table, and nothing another transaction or
  -- another company moves.
  v_key      text := 'ekwo.audit_sequence_' || coalesce(replace(p_company_id::text, '-', ''), 'installation');
  v_sequence integer;
  v_id       bigint;
begin
  v_sequence := coalesce(nullif(current_setting(v_key, true), '')::integer, 0) + 1;
  perform set_config(v_key, v_sequence::text, true);

  insert into audit_log (actor_id, api_key_id, company_id, table_name, record_id,
                         record_key, operation, action, old_values, new_values, sequence)
  values (acting_user(), (select id from current_api_key()), p_company_id, p_table,
          p_record_id, p_record_key, p_operation, p_action, p_old, p_new, v_sequence)
  returning id into v_id;
  return v_id;
end;
$function$;

-- A signed-in user reads every column of the trail but its id, and the
-- backend role no more than a person (`20260914151207`). The owner — the
-- migrations, `ekwo doctor`, the installer's own connection — reads it all.
revoke select on table audit_log from authenticated, service_role;
grant select (occurred_at, sequence, actor_id, api_key_id, company_id, table_name, record_id,
              record_key, operation, action, old_values, new_values)
  on table audit_log to authenticated, service_role;

-- An archive is read as its caller, who no longer reads the id of the trail.
-- It never carried one across anyway: an identity is local to an
-- installation and drawn again on arrival. So an identity does not leave, and
-- a table whose primary key is one is written in the order of every column
-- that does — rows that tie on all of them are the same text, so the order is
-- still one, and the checksum of the manifest still holds.
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
  v_class    regclass;
  v_problem  record;
  v_where    text;
  v_columns  text;
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

  v_class := to_regclass(format('%I.%I', v_schema, v_name));
  v_where := company_archive_predicate(v_schema, v_name, 't');

  execute format('select count(*) from %I.%I t where %s', v_schema, v_name, v_where)
     into v_seen using p_company_id;
  v_held := company_archive_row_count(p_company_id, p_table);
  if v_seen <> v_held then
    raise exception 'export_incomplete: % holds % rows for this company and you may read % of them. An archive is whole or it is not written: ask for the reading capability you lack — or, for the table of a module, for the module to be enabled.',
      p_table, v_held, v_seen
      using errcode = '42501';
  end if;

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
    raise exception 'unknown_table: % has no primary key, so its rows have no order to be written in', p_table;
  end if;

  return query execute format('select to_jsonb(x)%s from (select %s from %I.%I t where %s) x order by %s',
                              v_decimals, v_columns, v_schema, v_name, v_where, v_order)
    using p_company_id;
end;
$$;

comment on function export_company_table(uuid, text) is
  'The rows of one table for one company, one JSON object each, in primary key order — or, for a table whose primary key is an identity, which does not leave, in the order of every column that does: decimals as text, timestamps in UTC. Runs as its caller, needs company.export, refuses when the caller may read fewer rows than the table holds, and refuses while any table of a company is unclassified. Stable, so it reads the snapshot of the statement that calls it: called table after table, it needs a repeatable read transaction around the calls for the tables to agree with each other and with the manifest — which is what the CLI opens — or use export_company(), which is one statement.';

update company_archive_registry
   set reason = 'The trail of the company, with the identifiers of whoever acted kept as a trace, in the order of occurred_at and sequence. The row id is local to an installation: it does not leave, and is drawn again on arrival.'
 where table_schema = 'public' and table_name = 'audit_log';

-- ---------------------------------------------------------------------------
-- 2. A shared installation keeps an administrator
-- ---------------------------------------------------------------------------

-- The first signed-in user may claim an installation nobody administers: the
-- insert policy on `instance_admins` and `claim_instance_admin()` both ask
-- this. A shared one is never claimed that way — whoever arrived first would
-- reach every company on it.
create or replace function instance_has_no_admin()
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select not instance_is_shared() and not exists (select 1 from instance_admins);
$$;

comment on function instance_has_no_admin() is
  'Whether the first signed-in user may claim this installation: it has no administrator, and it is not shared (decision 0065).';

create or replace function share_instance(p_companies_per_person integer)
returns instance
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_old instance%rowtype;
  v_row instance%rowtype;
begin
  if not is_installer() and not is_instance_admin() then
    raise exception 'not_instance_admin: sharing an installation is an instance-level act'
      using errcode = '42501';
  end if;
  if p_companies_per_person is null or p_companies_per_person not between 0 and 1000 then
    raise exception 'bad_companies_per_person: a shared installation says how many companies one person may create, from 0 to 1000';
  end if;
  select * into v_old from instance where id = 1;
  if v_old.id is null then
    raise exception 'instance_not_initialised: run init_instance() first';
  end if;
  if not exists (select 1 from instance_admins) then
    raise exception 'no_instance_admin: a shared installation has an administrator, who is the operator. Appoint one with claim_instance_admin() before sharing it — or the first person to sign in would claim it.'
      using errcode = '55006';
  end if;

  update instance
     set shared = true, companies_per_person = p_companies_per_person, updated_at = now()
   where id = 1
  returning * into v_row;

  perform audit_record(
    null, 'instance', v_row.instance_id, v_row.organization_name, 'update', 'instance_shared',
    jsonb_build_object('shared', v_old.shared, 'companies_per_person', v_old.companies_per_person),
    jsonb_build_object('shared', v_row.shared, 'companies_per_person', v_row.companies_per_person));
  return v_row;
end;
$$;

comment on function share_instance(integer) is
  'Turns the shared setting on (decision 0065): a signed-in person may create up to this many companies of their own, and nobody learns of a company they may not know of. The installer or an instance administrator, on an installation that has an administrator.';

create or replace function instance_admins_keep_one()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if not instance_is_shared() then
    return old;
  end if;
  -- Two administrators leaving at once each see the other: the lock makes the
  -- second wait for the first, and then see that it went.
  perform pg_advisory_xact_lock(hashtextextended('ekwo.instance_admins', 0));
  if not exists (select 1 from instance_admins a where a.user_id <> old.user_id) then
    raise exception 'last_instance_admin: a shared installation keeps an administrator, or the first person to sign in would claim it. Appoint another before this one leaves, or stop sharing it first.'
      using errcode = '55006';
  end if;
  return old;
end;
$$;

comment on function instance_admins_keep_one() is
  'Refuses to remove the last administrator of a shared installation, whoever asks (decision 0065).';

drop trigger if exists instance_admins_keep_one on instance_admins;
create trigger instance_admins_keep_one
  before delete on instance_admins
  for each row execute function instance_admins_keep_one();

-- ---------------------------------------------------------------------------
-- 3. The guards look in the row's own company
-- ---------------------------------------------------------------------------
--
-- Bodies unchanged but for the lines that say why.
--
-- A guard reads, as definer, the rows a new value names. It reads them in the
-- row's own company; and when that company is one the writer may not know of,
-- it reads nothing at all, because what it would then quote or compare is
-- another company's. Stepping aside there and leaving the refusal to row level
-- security would also let past everybody whom row level security does not
-- stop: on a shared installation the backend role, the owner and a scheduled
-- job may know of no company, and they would move posted rows unguarded. So
-- the writer who may not know of the company is refused, by name and before
-- anything is read — the same words for a company that exists and one that
-- does not, since neither is one they may know of — and only a person or a
-- key is ever that writer. Everybody else meets every guard.

create or replace function assert_writes_into_known_company(p_company_id uuid)
returns void
language plpgsql
stable
set search_path = public, pg_temp
as $$
begin
  if (auth.uid() is not null or nullif(current_setting('ekwo.api_key', true), '') is not null)
     and not may_know_of_company(p_company_id) then
    raise exception 'not_allowed: this row is written into no company you may write in'
      using errcode = '42501';
  end if;
end;
$$;

comment on function assert_writes_into_known_company(uuid) is
  'Refuses a person or a machine key who writes a row into a company they may not know of (may_know_of_company()), with one answer whether the company exists or not. Called by the definer guards before they read anything for that row. The backend role, the owner and the installer are neither, and pass: the guard then runs for them in full (decision 0065).';

create or replace function documents_guard_posted()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  -- What may still move once the state has left `draft`. A closed list: a
  -- column that is not named here is frozen, including one that does not
  -- exist yet.
  c_still_moves constant text[] := array[
    'amount_paid', 'amount_residual', 'payment_state',
    'sent_at', 'peppol_status', 'peppol_message_id',
    'updated_at'
  ];
  -- And what moves when a posted document is cancelled: the state, and the
  -- settlement that follows from it. Nothing else, not even what may move on
  -- any other day. `amount_residual` is generated, and not yet computed in a
  -- `before` trigger.
  c_cancel_moves constant text[] := array['state', 'payment_state', 'amount_residual', 'updated_at'];
  -- And what moves when it goes back to draft: the state, its entry, and the
  -- values post_document() derived, given back — the three territories it
  -- judged the document against among them.
  c_unpost_moves constant text[] := array[
    'state', 'entry_id', 'number', 'accounting_date', 'tax_point_date',
    'seller_territory_code', 'buyer_territory_code', 'supply_territory_resolved',
    'payment_state', 'amount_residual', 'updated_at'
  ];
  v_moved  text[];
  v_entry  entries%rowtype;
  v_credit documents%rowtype;
begin
  if tg_op = 'INSERT' then
    if new.state <> 'draft' then
      raise exception 'document_born_posted: a document is written as a draft and posted by post_document(). One that is already % arrives with a company being loaded, by import_company(), and in no other way.',
        new.state
        using errcode = '55006';
    end if;
    return new;
  end if;

  -- A row moved into a company the writer may not know of: nothing below is
  -- read for it.
  if tg_op = 'UPDATE' then
    perform assert_writes_into_known_company(new.company_id);
  end if;

  if tg_op = 'DELETE' then
    if old.state = 'draft'
       or not exists (select 1 from companies c where c.id = old.company_id) then
      return old;
    end if;
    raise exception 'document_posted: % % was issued and cannot be deleted. It is undone by a credit note that names it, which cancel_document() issues.',
      old.doc_type, coalesce(old.number, old.id::text)
      using errcode = '55006';
  end if;

  if old.state = 'draft' then
    -- The one transition that produces an entry has to have produced one.
    if new.state = 'posted' then
      select e.* into v_entry from entries e
       where e.id = new.entry_id and e.company_id = new.company_id and e.state = 'posted';
      if not found then
        raise exception 'document_posted_without_entry: % has no posted entry. A document is posted by post_document(), which builds its entry and posts it first.',
          coalesce(new.number, new.id::text)
          using errcode = '55006';
      end if;
      -- What post_document() leaves behind, read on the two rows: the entry
      -- was built for this document and for no other, the document is booked
      -- on the day its entry is, and it is numbered as it was — or, where it
      -- had no number, as its entry.
      if v_entry.document_id is distinct from new.id
         or new.accounting_date is distinct from v_entry.entry_date
         or new.number is distinct from coalesce(old.number, v_entry.number) then
        raise exception 'document_posted_by_hand: % is not what post_document() writes — its entry % was not built for it, or is not booked on its day, or did not give it its number. A document is posted by post_document() and by nothing else.',
          coalesce(new.number, new.id::text), coalesce(v_entry.number, v_entry.id::text)
          using errcode = '55006';
      end if;
    end if;
    return new;
  end if;

  -- The way out of `posted`, and the only one: what cancel_document() leaves
  -- behind, read on the rows. A posted credit note of the matching type names
  -- this document and carries its total in its currency, and the third-party
  -- lines of this document are matched in full against that credit note's
  -- entry and nothing else. Whoever wrote the statement, those are the facts
  -- that make `cancelled` true.
  if old.state = 'posted' and new.state = 'cancelled' then
    select array_agg(n.key order by n.key)
      into v_moved
      from jsonb_each(to_jsonb(new)) n
      join jsonb_each(to_jsonb(old)) o on o.key = n.key
     where n.value is distinct from o.value
       and n.key <> all (c_cancel_moves);
    if v_moved is not null then
      raise exception 'document_posted: % % is cancelled with nothing else changed, and would change its % (%).',
        old.doc_type, coalesce(old.number, old.id::text),
        case when array_length(v_moved, 1) = 1 then 'value of' else 'values of' end,
        array_to_string(v_moved, ', ')
        using errcode = '55006';
    end if;

    if not is_installer() and not has_capability(old.company_id, 'documents.post') then
      raise exception 'not_allowed: cancelling a document in this company needs documents.post'
        using errcode = '42501';
    end if;

    select c.* into v_credit
      from documents c
     where c.reversed_document_id = old.id
       and c.company_id = old.company_id
       and c.state = 'posted'
       and c.doc_type = case old.doc_type
                          when 'sale_invoice' then 'sale_credit_note'
                          when 'purchase_invoice' then 'purchase_credit_note'
                        end::doc_type
       and c.currency_code = old.currency_code
       and c.amount_total = old.amount_total
     limit 1;

    if not found
       or exists (
         select 1
           from entry_lines l
           join accounts a on a.id = l.account_id
          where l.entry_id = old.entry_id
            and a.reconcilable
            and a.account_type in ('asset_receivable', 'liability_payable')
            and l.matched_amount < abs(l.debit - l.credit))
       or exists (
         select 1
           from reconciliations r
           join entry_lines l on l.id in (r.debit_line_id, r.credit_line_id)
           join entry_lines x on x.id = case when l.id = r.debit_line_id
                                             then r.credit_line_id else r.debit_line_id end
          where l.entry_id = old.entry_id
            and x.entry_id is distinct from v_credit.entry_id) then
      raise exception 'document_cancelled_by_hand: % % is cancelled by cancel_document(), which issues the credit note that names it and matches the two. A posted document becomes cancelled when that credit note exists and settles it in full, and in no other way.',
        old.doc_type, coalesce(old.number, old.id::text)
        using errcode = '55006';
    end if;
    return new;
  end if;

  -- The way back to draft: unpost_document() has recorded the act for this
  -- document and this entry, in this transaction. That row is written by
  -- nobody else, and it is only written once every condition of
  -- unpost_refusal() held. The draft gives up its entry, and its number if it
  -- was the entry's; nothing else moves but what posting had derived.
  if old.state = 'posted' and new.state = 'draft'
     and exists (
       select 1 from document_unpostings u
        where u.document_id = old.id
          and u.entry_id = old.entry_id
          and u.transaction_id = txid_current()) then
    select array_agg(n.key order by n.key)
      into v_moved
      from jsonb_each(to_jsonb(new)) n
      join jsonb_each(to_jsonb(old)) o on o.key = n.key
     where n.value is distinct from o.value
       and n.key <> all (c_unpost_moves);
    if v_moved is not null
       or new.entry_id is not null
       or (new.number is not null and new.number is distinct from old.number) then
      raise exception 'document_posted: % % goes back to draft with nothing else changed, and would change its %.',
        old.doc_type, coalesce(old.number, old.id::text),
        coalesce(array_to_string(v_moved, ', '), 'entry or number')
        using errcode = '55006';
    end if;
    return new;
  end if;

  if new.state is distinct from old.state then
    raise exception 'document_posted: % % is % and stays so. It is undone by a credit note that names it, which cancel_document() issues — or, where its country allows it and nothing about it has left, put back to draft by unpost_document() — never by changing its state to %.',
      old.doc_type, coalesce(old.number, old.id::text), old.state, new.state
      using errcode = '55006';
  end if;

  select array_agg(n.key order by n.key)
    into v_moved
    from jsonb_each(to_jsonb(new)) n
    join jsonb_each(to_jsonb(old)) o on o.key = n.key
   where n.value is distinct from o.value
     and n.key <> all (c_still_moves);

  if v_moved is not null then
    raise exception 'document_posted: % % was issued and keeps its % (%). What produced an entry does not change after it; credit it and issue another.',
      old.doc_type, coalesce(old.number, old.id::text),
      case when array_length(v_moved, 1) = 1 then 'value of' else 'values of' end,
      array_to_string(v_moved, ', ')
      using errcode = '55006';
  end if;

  if new.amount_paid is distinct from old.amount_paid
     and new.amount_paid is distinct from document_amount_paid(new.id) then
    raise exception 'document_amount_paid_is_derived: % has been settled by %, which is what its matching says. The figure is never keyed.',
      coalesce(old.number, old.id::text), document_amount_paid(new.id)
      using errcode = '55006';
  end if;

  if new.payment_state is distinct from old.payment_state
     and new.amount_paid is not distinct from old.amount_paid then
    raise exception 'document_payment_state_is_derived: the settlement of % follows from what was matched against it, and is never keyed.',
      coalesce(old.number, old.id::text)
      using errcode = '55006';
  end if;

  return new;
end;
$function$;

create or replace function document_lines_guard_posted()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  v_state   doc_state;
  v_number  text;
  v_type    doc_type;
  v_moved   text[];
begin
  -- A line written into a company the writer may not know of: nothing is
  -- read for it. And the document a line names is looked for in the line's
  -- own company: one of another company is, to this trigger, one that does
  -- not exist, and the foreign key refuses it as it refuses an id nobody
  -- holds.
  if tg_op <> 'DELETE' then
    perform assert_writes_into_known_company(new.company_id);
  end if;

  select d.state, d.number, d.doc_type into v_state, v_number, v_type
    from documents d
   where d.id = coalesce(new.document_id, old.document_id)
     and d.company_id = coalesce(new.company_id, old.company_id);

  -- No document: it is being deleted, and its lines with it. Whether *that*
  -- was allowed is the question documents_guard_posted() answered.
  if not found or v_state = 'draft' then
    -- A line does not leave a posted document for a draft either.
    if tg_op = 'UPDATE' and new.document_id is distinct from old.document_id then
      select d.state, d.number, d.doc_type into v_state, v_number, v_type
        from documents d where d.id = old.document_id and d.company_id = old.company_id;
      if found and v_state <> 'draft' then
        raise exception 'document_posted: a line of % % was issued with it and stays on it.',
          v_type, coalesce(v_number, old.document_id::text)
          using errcode = '55006';
      end if;
    end if;
    return coalesce(new, old);
  end if;

  if tg_op = 'DELETE' then
    if not exists (select 1 from companies c where c.id = old.company_id) then
      return old;
    end if;
    raise exception 'document_posted: line % of % % was issued and cannot be deleted. Credit the document and issue another.',
      old.sequence, v_type, coalesce(v_number, old.document_id::text)
      using errcode = '55006';
  end if;

  if tg_op = 'INSERT' then
    raise exception 'document_posted: % % was issued with the lines it has, and takes no other. Credit it and issue another.',
      v_type, coalesce(v_number, new.document_id::text)
      using errcode = '55006';
  end if;

  select array_agg(n.key order by n.key)
    into v_moved
    from jsonb_each(to_jsonb(new)) n
    join jsonb_each(to_jsonb(old)) o on o.key = n.key
   where n.value is distinct from o.value
     and n.key <> 'updated_at';

  if v_moved is not null then
    raise exception 'document_posted: line % of % % was issued and keeps its % (%). What produced an entry does not change after it; credit the document and issue another.',
      old.sequence, v_type, coalesce(v_number, old.document_id::text),
      case when array_length(v_moved, 1) = 1 then 'value of' else 'values of' end,
      array_to_string(v_moved, ', ')
      using errcode = '55006';
  end if;
  return new;
end;
$function$;

create or replace function entries_guard_posted()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  v_moved   text[];
  v_format  text;
  v_gapless boolean;
  v_code    text;
  v_period  smallint;
  v_last    integer;
begin
  if tg_op = 'INSERT' then
    if new.state <> 'draft' then
      raise exception 'entry_born_posted: an entry is written as a draft and posted by post_entry(). One that is already % arrives with a company being loaded, by import_company(), and in no other way.',
        new.state
        using errcode = '55006';
    end if;
    return new;
  end if;

  -- An entry moved into a company the writer may not know of: nothing below
  -- is read for it.
  if tg_op = 'UPDATE' then
    perform assert_writes_into_known_company(new.company_id);
  end if;

  if old.state = 'draft' then
    if tg_op = 'UPDATE' and new.state = 'posted' then
      if new.posted_at is null then
        raise exception 'entry_posted_by_hand: entry % would be posted with no instant it was posted at. An entry is posted by post_entry() and by nothing else.',
          coalesce(new.number, new.id::text)
          using errcode = '55006';
      end if;
      -- Null is what post_entry() itself writes where it finds no year — a company
      -- that has not opened one, or a caller who cannot read `fiscal_years`, which
      -- is a machine key today. A year that is *named* has to be the right one.
      if new.fiscal_year_id is not null
         and new.fiscal_year_id is distinct from fiscal_year_at(new.company_id, new.entry_date) then
        raise exception 'entry_posted_by_hand: entry % would be posted outside the financial year its date falls in. An entry is posted by post_entry() and by nothing else.',
          coalesce(new.number, new.id::text)
          using errcode = '55006';
      end if;

      if not exists (select 1 from entry_lines l where l.entry_id = new.id) then
        raise exception 'entry_empty: entry % has no lines', new.id;
      end if;

      perform assert_period_open(new.company_id, new.entry_date, true);

      select r.number_format, r.numbering_gapless into v_format, v_gapless
        from numbering_rules(new.company_id) r;
      -- The journal of the entry's own company, or none: the counter of a
      -- journal of another company is not read, and the foreign key refuses
      -- the entry as it refuses a journal nobody holds.
      select j.code into v_code from journals j
       where j.id = new.journal_id and j.company_id = new.company_id;
      v_period := case when v_format ~ '\{(YYYY|YY)\}'
                       then extract(year from new.entry_date)::smallint
                       else 0::smallint end;
      select s.last_number into v_last
        from journal_sequences s
       where s.journal_id = new.journal_id and s.year = v_period and v_code is not null;

      if v_last is not null and new.number = format_number(v_format, v_code, new.entry_date, v_last) then
        return new;  -- drawn from the counter, a moment ago, by this transaction
      end if;

      -- A number chosen by hand: on the draft beforehand, or in this statement.
      if v_gapless and not (auth.uid() is not null and has_capability(new.company_id, 'entries.import')) then
        raise exception 'entry_posted_by_hand: % is not the number the counter of this journal delivered, and this country forbids a hole in the sequence. An entry is posted by post_entry(), which draws it; books that already have numbers are brought in by whoever holds entries.import.',
          new.number
          using errcode = '55006';
      end if;
      if v_code is not null then
        perform catch_up_journal_sequence(new.journal_id, new.entry_date, new.number);
      end if;
    end if;
    return coalesce(new, old);
  end if;

  if tg_op = 'DELETE' then
    if not exists (select 1 from companies c where c.id = old.company_id) then
      return old;
    end if;
    -- The entry of a document unpost_document() has just put back to draft,
    -- recorded in this transaction, and which no document points at any more.
    if exists (
         select 1 from document_unpostings u
          where u.entry_id = old.id
            and u.transaction_id = txid_current())
       and not exists (select 1 from documents d where d.entry_id = old.id) then
      return old;
    end if;
    raise exception 'entry_posted: entry % is % and cannot be deleted. A posted entry is undone by a reversal that names it.',
      coalesce(old.number, old.id::text), old.state
      using errcode = '55006';
  end if;

  if new.state is distinct from old.state then
    raise exception 'entry_posted: entry % is % and stays so. A posted entry is undone by a reversal that names it, never by changing its state to %.',
      coalesce(old.number, old.id::text), old.state, new.state
      using errcode = '55006';
  end if;

  select array_agg(n.key order by n.key)
    into v_moved
    from jsonb_each(to_jsonb(new)) n
    join jsonb_each(to_jsonb(old)) o on o.key = n.key
   where n.value is distinct from o.value
     -- `is_balanced` is generated, and not yet computed in a `before` trigger.
     and n.key not in ('updated_at', 'is_balanced');

  if v_moved is not null then
    raise exception 'entry_posted: entry % was posted and keeps its % (%). A posted entry is undone by a reversal that names it.',
      coalesce(old.number, old.id::text),
      case when array_length(v_moved, 1) = 1 then 'value of' else 'values of' end,
      array_to_string(v_moved, ', ')
      using errcode = '55006';
  end if;
  return new;
end;
$function$;

create or replace function entry_lines_guard_posted()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  -- What the matching writes, and nothing else. `balance` is generated from
  -- two columns that are frozen, and is not yet computed when a `before`
  -- trigger reads the new row.
  c_still_moves constant text[] := array['matching_number', 'matched_amount', 'balance', 'updated_at'];
  v_state  entry_state;
  v_number text;
  v_moved  text[];
begin
  -- A line written into a company the writer may not know of: nothing is
  -- read for it. The entry a line names is looked for in the line's own
  -- company.
  if tg_op <> 'DELETE' then
    perform assert_writes_into_known_company(new.company_id);
  end if;

  -- The entry the line is leaving, where it is leaving one: a line does not
  -- walk out of a posted entry into a draft.
  select e.state, e.number into v_state, v_number
    from entries e
   where e.id = coalesce(old.entry_id, new.entry_id)
     and e.company_id = coalesce(old.company_id, new.company_id);
  if found and v_state = 'draft' and tg_op = 'UPDATE' and new.entry_id is distinct from old.entry_id then
    select e.state, e.number into v_state, v_number from entries e
     where e.id = new.entry_id and e.company_id = new.company_id;
  end if;

  if not found or v_state = 'draft' then
    return coalesce(new, old);
  end if;

  if tg_op = 'DELETE' then
    if not exists (select 1 from companies c where c.id = old.company_id) then
      return old;
    end if;
    raise exception 'entry_posted: line % of entry % was posted and cannot be deleted. A posted entry is undone by a reversal that names it.',
      old.sequence, coalesce(v_number, old.entry_id::text)
      using errcode = '55006';
  end if;

  if tg_op = 'INSERT' then
    raise exception 'entry_posted: entry % was posted with the lines it has, and takes no other. A posted entry is undone by a reversal that names it.',
      coalesce(v_number, new.entry_id::text)
      using errcode = '55006';
  end if;

  select array_agg(n.key order by n.key)
    into v_moved
    from jsonb_each(to_jsonb(new)) n
    join jsonb_each(to_jsonb(old)) o on o.key = n.key
   where n.value is distinct from o.value
     and n.key <> all (c_still_moves);

  if v_moved is not null then
    raise exception 'entry_posted: line % of entry % was posted and keeps its % (%). A posted entry is undone by a reversal that names it.',
      old.sequence, coalesce(v_number, old.entry_id::text),
      case when array_length(v_moved, 1) = 1 then 'value of' else 'values of' end,
      array_to_string(v_moved, ', ')
      using errcode = '55006';
  end if;
  return new;
end;
$function$;

create or replace function entry_lines_set_declared_on()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  v_entry_date date;
begin
  select e.entry_date into v_entry_date from entries e
   where e.id = new.entry_id and e.company_id = new.company_id;
  -- No entry: the foreign key refuses the row, by its own name.
  new.declared_on := declared_on_of(new.tax_point_date, v_entry_date);
  return new;
end;
$function$;

-- ---------------------------------------------------------------------------
-- 4. A preference names a company its person may know of
-- ---------------------------------------------------------------------------

-- Before the foreign key, which says only whether the company exists — and
-- so for both the one that does not and the one the person may not know of,
-- with the same words. Definer, to see a company the caller cannot read.
create or replace function user_preferences_company_is_known()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if new.preferred_company_id is not null
     and (tg_op = 'INSERT' or new.preferred_company_id is distinct from old.preferred_company_id)
     and (not may_know_of_company(new.preferred_company_id)
          or not exists (select 1 from companies c where c.id = new.preferred_company_id)) then
    raise exception 'unknown_company: % is not a company you may open', new.preferred_company_id
      using errcode = '23503';
  end if;
  return new;
end;
$$;

comment on function user_preferences_company_is_known() is
  'Refuses a preferred company that does not exist or that the person may not know of, with one answer for both (decision 0065).';

drop trigger if exists user_preferences_company_is_known on user_preferences;
create trigger user_preferences_company_is_known
  before insert or update of preferred_company_id on user_preferences
  for each row execute function user_preferences_company_is_known();

-- ---------------------------------------------------------------------------
-- 5, 6, 7. A row names rows of its own company, by one key
-- ---------------------------------------------------------------------------

create or replace function scope_references_to_company(p_schema text)
returns integer
language plpgsql
set search_path = public, pg_temp
as $$
declare
  r           record;
  v_composite record;
  v_name      text;
  v_action    text;
  v_done      integer := 0;
begin
  -- A row that would fail one of the keys below is said now, with every other
  -- one, before anything changes (section 0).
  perform assert_references_within_company(p_schema);

  -- `ccol` is the column the referencing table names its company by:
  -- `company_id`, or `id` for `companies` itself.
  for r in select * from company_references_by_id(p_schema) loop
    -- The table it points at answers to its key and the company together.
    if not exists (
      select 1 from pg_index i
       where i.indrelid = r.confrelid and i.indisunique and i.indpred is null and i.indexprs is null
         and i.indnatts = 2
         and (select array_agg(x.attname::text order by x.attname::text)
                from pg_attribute x where x.attrelid = i.indrelid and x.attnum = any (i.indkey))
             = (select array_agg(v order by v) from unnest(array[r.fcol, 'company_id']) v)) then
      execute format('create unique index %I on %s (%I, company_id)',
                     left(r.target_name || '_' || r.fcol || '_company_idx', 63), r.confrelid, r.fcol);
    end if;

    -- The composite key the column may already have beside this one.
    select c.conname, c.confdeltype into v_composite
      from pg_constraint c
     where c.contype = 'f' and c.conrelid = r.conrelid and c.confrelid = r.confrelid
       and cardinality(c.conkey) = 2
       and exists (select 1 from unnest(c.conkey, c.confkey) k(a, b)
                     join pg_attribute x on x.attrelid = c.conrelid and x.attnum = k.a
                     join pg_attribute y on y.attrelid = c.confrelid and y.attnum = k.b
                    where x.attname = r.col and y.attname = r.fcol)
       and exists (select 1 from unnest(c.conkey, c.confkey) k(a, b)
                     join pg_attribute x on x.attrelid = c.conrelid and x.attnum = k.a
                     join pg_attribute y on y.attrelid = c.confrelid and y.attnum = k.b
                    where x.attname = r.ccol and y.attname = 'company_id')
     limit 1;

    -- What deleting the row it names did — cascade, or empty the column — the
    -- composite key does from now on. `restrict` and `no action` both refuse.
    v_action := case r.confdeltype
                  when 'c' then 'on delete cascade'
                  when 'n' then format('on delete set null (%I)', r.col)
                  when 'd' then format('on delete set default (%I)', r.col)
                  when 'r' then 'on delete restrict'
                  else 'on delete no action'
                end;

    if v_composite.conname is null
       or (r.confdeltype in ('c', 'n', 'd') and v_composite.confdeltype <> r.confdeltype) then
      if v_composite.conname is not null then
        execute format('alter table %s drop constraint %I', r.conrelid, v_composite.conname);
        v_name := v_composite.conname;
      else
        v_name := left(r.relname || '_' || r.col || '_company_id_fkey', 63);
      end if;
      execute format('alter table %s add constraint %I foreign key (%I, %I) references %s (%I, company_id) %s%s',
                     r.conrelid, v_name, r.col, r.ccol, r.confrelid, r.fcol, v_action,
                     case when not r.condeferrable then ''
                          when r.condeferred then ' deferrable initially deferred'
                          else ' deferrable initially immediate' end);
    end if;

    -- And an index that leads with the key, in the key's order, as every
    -- foreign key has.
    if not exists (
      select 1 from pg_index i
       where i.indrelid = r.conrelid and i.indnatts >= 2
         and (select array_agg(x.attname::text order by k.n)
                from unnest((i.indkey::smallint[])[0:1]) with ordinality k(attnum, n)
                join pg_attribute x on x.attrelid = i.indrelid and x.attnum = k.attnum)
             = array[r.col, r.ccol]) then
      execute format('create index %I on %s (%I, %I)',
                     left(r.relname || '_' || r.col || '_company_idx', 63), r.conrelid, r.col, r.ccol);
    end if;

    execute format('alter table %s drop constraint %I', r.conrelid, r.conname);
    v_done := v_done + 1;
  end loop;

  -- A unique key that holds a reference and not the company is the same
  -- question asked another way: a row of one's own that names another
  -- company's row, with the rest of its key equal to one of that company's,
  -- collides with it before any foreign key is asked — and says that it
  -- exists. With the company in the key, it collides with nothing, and the
  -- foreign key answers as for a row of nobody's. A row names rows of its
  -- own company only, so what was unique stays unique.
  for r in
    select i.indexrelid, i.indrelid, i.indisprimary, c.relname::text as relname,
           con.conname, con.contype, company_column(i.indrelid) as ccol,
           pg_get_expr(i.indpred, i.indrelid) as predicate,
           (select string_agg(format('%I', a.attname), ', ' order by k.n)
              from unnest(i.indkey::smallint[]) with ordinality k(attnum, n)
              join pg_attribute a on a.attrelid = i.indrelid and a.attnum = k.attnum) as columns
      from pg_index i
      join pg_class c on c.oid = i.indrelid
      join pg_namespace n on n.oid = c.relnamespace
      left join pg_constraint con on con.conindid = i.indexrelid and con.conrelid = i.indrelid
     where n.nspname = p_schema
       and i.indisunique and i.indexprs is null
       and company_column(i.indrelid) is not null
       and not exists (select 1 from pg_attribute a
                        where a.attrelid = i.indrelid and a.attnum = any (i.indkey)
                          and a.attname::text = company_column(i.indrelid))
       and exists (select 1
                     from pg_constraint f
                     join pg_attribute a on a.attrelid = f.conrelid and a.attnum = any (f.conkey)
                    where f.contype = 'f' and f.conrelid = i.indrelid
                      and f.confrelid <> 'public.companies'::regclass
                      and a.attname::text <> company_column(i.indrelid)
                      and a.attnum = any (i.indkey)
                      and company_column(f.confrelid) = 'company_id')
     order by c.relname, i.indexrelid::regclass::text
  loop
    if r.contype = 'p' then
      execute format('alter table %s drop constraint %I, add constraint %I primary key (%s, %I)',
                     r.indrelid::regclass, r.conname, r.conname, r.columns, r.ccol);
    elsif r.contype = 'u' then
      execute format('alter table %s drop constraint %I, add constraint %I unique (%s, %I)',
                     r.indrelid::regclass, r.conname, r.conname, r.columns, r.ccol);
    else
      v_name := (select relname::text from pg_class where oid = r.indexrelid);
      execute format('drop index %s', r.indexrelid::regclass);
      execute format('create unique index %I on %s (%s, %I)%s',
                     v_name, r.indrelid::regclass, r.columns, r.ccol,
                     case when r.predicate is null then '' else ' where ' || r.predicate end);
    end if;
    v_done := v_done + 1;
  end loop;
  return v_done;
end;
$$;

comment on function scope_references_to_company(text) is
  'Makes every reference of a schema from a company''s table to another company''s table by id alone a composite key with the company — company_id, or the id of companies itself (company_column()) — keeping its delete action, and drops the single-column key: where a composite one stood beside it too, the two failed with different names for an id of another company and an id of nobody. Then adds the company to every unique key of those tables that holds such a reference and not the company, which a row naming another company''s row collided with before any foreign key was asked (decision 0065). Asks assert_references_within_company() first, so a row that would fail a new key stops it before anything changes. Returns how many it changed. For migrations, the socle''s and the modules''; executable by nobody else.';

do $$
begin
  perform scope_references_to_company('public');
end;
$$;

-- `import_bank_statement()` names two of the keys that now hold the company
-- in its `on conflict`. Unchanged but for those two clauses.
create or replace function import_bank_statement(p_company_id uuid, p_file jsonb, p_source jsonb DEFAULT NULL::jsonb, p_bank_account_id uuid DEFAULT NULL::uuid)
 RETURNS TABLE(statement_index integer, statement_id uuid, bank_account_id uuid, statement_ref text, already_imported boolean, lines_read integer, lines_imported integer, lines_known integer, lines_not_booked integer, warnings jsonb)
 LANGUAGE plpgsql
AS $function$
-- The columns this function returns share their names with columns it writes;
-- inside a statement a bare name is the column.
#variable_conflict use_column
declare
  v_statements jsonb := p_file -> 'statements';
  v_format     text  := coalesce(p_file ->> 'namespace', p_file ->> 'version');
  v_stmt       jsonb;
  v_index      integer := 0;
  v_identifier jsonb;
  v_value      text;
  v_account    bank_accounts;
  v_currency   text;
  v_opening    numeric;
  v_closing    numeric;
  v_movement   numeric;
  v_bad        jsonb;
  v_ref        text;
  v_start      date;
  v_end        date;
  v_existing   bank_statements;
  v_id         uuid;
  v_already    boolean;
  v_read       integer;
  v_imported   integer;
  v_listed     integer;
  v_skipped    integer;
  v_warnings   jsonb;
  v_chain      record;
begin
  if not exists (select 1 from companies c where c.id = p_company_id) then
    raise exception 'unknown_company: %', p_company_id using errcode = 'no_data_found';
  end if;
  -- Row level security is what refuses; this is what says why. Without it a
  -- viewer reads "new row violates row-level security policy", which names a
  -- mechanism and not a reason.
  -- Null-safe on purpose: `not NULL` is NULL and `if NULL` does not raise, which
  -- is how a guard of this shape was once skipped for a caller with no session.
  if not coalesce(is_installer(), false)
     and not coalesce(has_capability(p_company_id, 'bank.write'), false) then
    raise exception 'not_allowed: importing a statement into this company needs bank.write'
      using errcode = '42501';
  end if;
  if v_statements is null or jsonb_typeof(v_statements) <> 'array'
     or jsonb_array_length(v_statements) = 0 then
    raise exception 'invalid_statement_file: no statement in what was given — expected { statements: [ … ] } as a format reader returns it';
  end if;
  if p_bank_account_id is not null and jsonb_array_length(v_statements) <> 1 then
    raise exception 'invalid_statement_file: a bank account can be named for a file of one statement, and this one holds %',
      jsonb_array_length(v_statements);
  end if;

  for v_stmt in select value from jsonb_array_elements(v_statements) loop
    v_index      := v_index + 1;
    v_identifier := v_stmt #> '{account,identifier}';
    v_value      := upper(regexp_replace(coalesce(v_identifier ->> 'value', ''), '\s', '', 'g'));
    v_ref        := nullif(v_stmt ->> 'id', '');

    if v_value = '' or v_ref is null then
      raise exception 'invalid_statement_file: statement % has no identifier or names no account', v_index;
    end if;

    -- 1. The account. Known, or refused by name: an account created by an
    --    import is an account nobody decided, mapped to no journal and no
    --    ledger account.
    if p_bank_account_id is not null then
      select * into v_account from bank_accounts b
       where b.id = p_bank_account_id and b.company_id = p_company_id;
      if not found then
        raise exception 'unknown_bank_account: % is not a bank account of this company', p_bank_account_id
          using errcode = 'no_data_found';
      end if;
      if v_account.iban is not null and v_identifier ->> 'kind' = 'iban'
         and upper(regexp_replace(v_account.iban, '\s', '', 'g')) <> v_value then
        raise exception 'bank_account_mismatch: the statement is of account % and the bank account named holds %',
          v_value, v_account.iban;
      end if;
    else
      -- `bank_accounts.iban` is the only column the core has for what
      -- identifies an account, and it is compared with whatever the statement
      -- wrote — IBAN or not. The column is misnamed, which is a known gap with
      -- a change of its own; a second, stricter lookup here would not fix it.
      select * into v_account from bank_accounts b
       where b.company_id = p_company_id
         and b.iban is not null
         and upper(regexp_replace(b.iban, '\s', '', 'g')) = v_value;
      if not found then
        raise exception 'unknown_bank_account: no bank account of this company is identified by % (%) — create it, or name the one this statement belongs to',
          v_value, coalesce(v_identifier ->> 'kind', 'unknown kind')
          using errcode = 'no_data_found';
      end if;
    end if;

    -- 2. The currency. A statement in another currency than its account is
    --    not converted; it is a statement of another account.
    v_currency := coalesce(v_stmt #>> '{account,currency}', v_stmt #>> '{openingBalance,currency}',
                           v_stmt #>> '{closingBalance,currency}');
    if v_currency is distinct from v_account.currency_code::text then
      raise exception 'statement_currency_mismatch: statement % is in % and the bank account % in %',
        v_ref, coalesce(v_currency, 'no currency'), v_account.name, v_account.currency_code;
    end if;

    -- 3. The lines that count: booked, readable, in the account's currency
    --    and no finer than the column that will hold them — which is two
    --    decimals whatever the currency, a limit of `bank_transactions.amount`
    --    written in docs/international.md. Nothing is rounded here: a figure
    --    the column cannot hold is refused, not adjusted.
    select jsonb_agg(jsonb_build_object('line', l.value -> 'index', 'why',
             case
               when l.value ->> 'amount' is null then 'no readable amount'
               when coalesce(l.value ->> 'bookingDate', l.value ->> 'valueDate') is null then 'no date'
               when l.value ->> 'currency' is distinct from v_currency then
                 format('in %s, not converted', coalesce(l.value ->> 'currency', 'no currency'))
               else 'more than two decimals'
             end))
      into v_bad
      from jsonb_array_elements(coalesce(v_stmt -> 'lines', '[]'::jsonb)) l
     where coalesce((l.value ->> 'booked')::boolean, false)
       and (l.value ->> 'amount' is null
            or coalesce(l.value ->> 'bookingDate', l.value ->> 'valueDate') is null
            or l.value ->> 'currency' is distinct from v_currency
            or scale(trim_scale((l.value ->> 'amount')::numeric)) > 2);
    if v_bad is not null then
      raise exception 'unreadable_statement_line: statement % holds booked lines that cannot be imported as they are: %',
        v_ref, v_bad;
    end if;

    -- 4. The balance, recomputed here: what a client says it checked is not a
    --    check. Opening plus what is booked is the closing, or nothing is
    --    written — a statement that does not add up is a file that lost a
    --    line on the way, and importing it would hide which.
    if v_stmt #>> '{openingBalance,amount}' is null or v_stmt #>> '{closingBalance,amount}' is null then
      raise exception 'statement_without_balances: statement % carries no opening or no closing balance, so nothing proves its lines are all there', v_ref;
    end if;
    v_opening := (v_stmt #>> '{openingBalance,amount}')::numeric;
    v_closing := (v_stmt #>> '{closingBalance,amount}')::numeric;
    select coalesce(sum((l.value ->> 'amount')::numeric), 0), count(*)
      into v_movement, v_read
      from jsonb_array_elements(coalesce(v_stmt -> 'lines', '[]'::jsonb)) l
     where coalesce((l.value ->> 'booked')::boolean, false);
    select count(*) into v_skipped
      from jsonb_array_elements(coalesce(v_stmt -> 'lines', '[]'::jsonb)) l
     where not coalesce((l.value ->> 'booked')::boolean, false);
    if v_opening + v_movement <> v_closing then
      raise exception 'unbalanced_statement: statement % opens at %, its booked lines add up to %, and it closes at % — a difference of %',
        v_ref, v_opening, v_movement, v_closing, v_closing - (v_opening + v_movement);
    end if;
    if scale(trim_scale(v_opening)) > 2 or scale(trim_scale(v_closing)) > 2 then
      raise exception 'unreadable_statement_line: the balances of statement % carry more than two decimals', v_ref;
    end if;

    -- 5. The statement: the same one, or a new one.
    select min(coalesce(l.value ->> 'bookingDate', l.value ->> 'valueDate')::date),
           max(coalesce(l.value ->> 'bookingDate', l.value ->> 'valueDate')::date)
      into v_start, v_end
      from jsonb_array_elements(coalesce(v_stmt -> 'lines', '[]'::jsonb)) l
     where coalesce((l.value ->> 'booked')::boolean, false);
    v_start := coalesce((v_stmt #>> '{openingBalance,date}')::date, (v_stmt #>> '{period,from}')::date, v_start);
    v_end   := coalesce((v_stmt #>> '{closingBalance,date}')::date, (v_stmt #>> '{period,to}')::date, v_end);
    if v_end is null then
      raise exception 'invalid_statement_file: statement % has no closing date, no period and no line to take one from', v_ref;
    end if;

    select * into v_existing from bank_statements s
     where s.bank_account_id = v_account.id and s.statement_ref = v_ref and s.statement_date = v_end;
    v_already := found;
    if v_already then
      if v_existing.balance_start <> v_opening or v_existing.balance_end_declared <> v_closing then
        raise exception 'statement_conflict: statement % of % was imported with balances % → %, and this file says % → %',
          v_ref, v_end, v_existing.balance_start, v_existing.balance_end_declared, v_opening, v_closing;
      end if;
      v_id := v_existing.id;
    else
      insert into bank_statements
        (company_id, bank_account_id, name, statement_date, period_start, balance_start,
         balance_end_declared, source, statement_ref, sequence_number, source_format,
         source_file_name, source_checksum)
      values
        (p_company_id, v_account.id, v_ref, v_end, coalesce(v_start, v_end), v_opening,
         v_closing, 'import', v_ref,
         coalesce(v_stmt ->> 'legalSequenceNumber', v_stmt ->> 'electronicSequenceNumber')::numeric,
         v_format, p_source ->> 'file_name', p_source ->> 'checksum')
      returning id into v_id;
    end if;

    -- 6. The lines. Keyed, inserted where the key is new, listed either way.
    with read as (
      select l.value as line,
             (l.value ->> 'index')::integer as position,
             coalesce(l.value ->> 'bookingDate', l.value ->> 'valueDate')::date as booked_on,
             (l.value ->> 'amount')::numeric as amount,
             nullif(l.value ->> 'bankReference', '') as bank_reference,
             (select string_agg(u.value, ' ' order by u.ordinality)
                from jsonb_array_elements_text(coalesce(l.value #> '{remittance,unstructured}', '[]'::jsonb))
                     with ordinality u) as free_text,
             (select string_agg(s.value ->> 'reference', ' ' order by s.ordinality)
                from jsonb_array_elements(coalesce(l.value #> '{remittance,structured}', '[]'::jsonb))
                     with ordinality s) as structured
        from jsonb_array_elements(coalesce(v_stmt -> 'lines', '[]'::jsonb)) l
       where coalesce((l.value ->> 'booked')::boolean, false)
    ),
    described as (
      select r.*,
             case when r.bank_reference is not null
               then concat_ws(chr(31), 'ref', r.bank_reference, coalesce(r.line ->> 'detail', '0'),
                              r.booked_on::text, trim_scale(r.amount)::text)
               else concat_ws(chr(31), 'fp', r.booked_on::text, coalesce(r.line ->> 'valueDate', ''),
                              trim_scale(r.amount)::text, r.line ->> 'currency',
                              coalesce(upper(regexp_replace(r.line #>> '{counterparty,account,value}', '\s', '', 'g')), ''),
                              coalesce(r.line #>> '{counterparty,name}', ''),
                              coalesce(r.structured, ''), coalesce(r.free_text, ''),
                              coalesce(r.line ->> 'endToEndId', ''), coalesce(r.line ->> 'transactionId', ''),
                              coalesce(r.line ->> 'mandateId', ''),
                              coalesce(r.line ->> 'additionalInformation', ''))
             end as said
        from read r
    ),
    keyed as (
      select d.*,
             (case when d.bank_reference is not null then 'ref:' else 'fp:' end)
             || encode(sha256(convert_to(
                  d.said || chr(31)
                  || (row_number() over (partition by d.said order by d.position))::text, 'UTF8')), 'hex')
               as import_key
        from described d
    ),
    inserted as (
      insert into bank_transactions
        (company_id, statement_id, bank_account_id, sequence, transaction_date, value_date,
         amount, currency_code, description, counterpart_name, counterpart_iban, reference,
         structured_reference, state, raw, import_key)
      select p_company_id, v_id, v_account.id, k.position, k.booked_on,
             (k.line ->> 'valueDate')::date, k.amount, v_account.currency_code,
             coalesce(k.free_text, k.line ->> 'additionalInformation'),
             k.line #>> '{counterparty,name}',
             -- What the statement wrote, IBAN or not: it is what recognising a
             -- counterparty compares, and `contact_patterns` already calls it
             -- an account and not an IBAN.
             upper(regexp_replace(k.line #>> '{counterparty,account,value}', '\s', '', 'g')),
             k.bank_reference,
             k.line #>> '{remittance,structured,0,reference}',
             'pending', k.line, k.import_key
        from keyed k
      on conflict (bank_account_id, import_key, company_id) where import_key is not null do nothing
      returning id, import_key
    ),
    -- Listed either way: the lines this statement just brought, which the
    -- table as this statement sees it does not hold yet, and the ones it found.
    listed as (
      insert into bank_statement_lines (company_id, statement_id, transaction_id, position)
      select p_company_id, v_id, t.id, k.position
        from keyed k
        join (select i.id, i.import_key from inserted i
              union all
              select b.id, b.import_key from bank_transactions b
               where b.bank_account_id = v_account.id and b.import_key is not null) t
          on t.import_key = k.import_key
      on conflict (statement_id, transaction_id, company_id) do nothing
      returning 1
    )
    select (select count(*) from inserted), (select count(*) from listed) into v_imported, v_listed;

    -- 7. The file, when the caller stored it somewhere.
    if p_source ->> 'storage_path' is not null and not exists (
      select 1 from attachments a
       where a.entity_type = 'bank_statement' and a.entity_id = v_id
         and a.checksum is not distinct from p_source ->> 'checksum'
         and a.storage_path = p_source ->> 'storage_path'
    ) then
      insert into attachments
        (company_id, entity_type, entity_id, file_name, mime_type, byte_size, storage_path,
         checksum, uploaded_by)
      values
        (p_company_id, 'bank_statement', v_id,
         coalesce(p_source ->> 'file_name', v_ref), p_source ->> 'mime_type',
         (p_source ->> 'byte_size')::bigint, p_source ->> 'storage_path',
         p_source ->> 'checksum', acting_user());
    end if;

    -- 8. What is signalled and never refused: a missing statement.
    v_warnings := '[]'::jsonb;
    select * into v_chain from bank_statement_continuity c where c.statement_id = v_id;
    if v_chain.is_broken then
      v_warnings := v_warnings || jsonb_build_object(
        'code', 'balance_chain_broken',
        'message', format('statement %s opens at %s and the previous one, %s of %s, closed at %s: %s is unaccounted for between them',
                          v_ref, v_opening, coalesce(v_chain.previous_statement_ref, 'unnamed'),
                          v_chain.previous_statement_date, v_chain.previous_balance_end, v_chain.balance_gap),
        'previous_statement_id', v_chain.previous_statement_id,
        'balance_gap', v_chain.balance_gap);
    end if;
    if v_chain.missing_statements is distinct from 0 and v_chain.missing_statements is not null then
      v_warnings := v_warnings || jsonb_build_object(
        'code', 'statement_number_gap',
        'message', format('statement %s is numbered %s and the previous one %s',
                          v_ref, v_chain.sequence_number, v_chain.sequence_number - v_chain.missing_statements - 1),
        'missing_statements', v_chain.missing_statements);
    end if;

    statement_index  := v_index;
    statement_id     := v_id;
    bank_account_id  := v_account.id;
    statement_ref    := v_ref;
    already_imported := v_already;
    lines_read       := v_read;
    lines_imported   := v_imported;
    lines_known      := v_read - v_imported;
    lines_not_booked := v_skipped;
    warnings         := v_warnings;
    return next;
  end loop;
end;
$function$;

-- `import_company()` (`20261005160900`) writes a reference to a table that
-- loads later in a second pass, and finds those references from the foreign
-- keys, less `company_id`. The keys of `companies` now hold its own id beside
-- the account or journal they name; that column is the company itself, there
-- from the first pass. Unchanged but for that line.
create or replace function import_company(p_archive jsonb, p_owner_user_id uuid default null)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_archive   jsonb;
  v_manifest  jsonb;
  v_tables    jsonb;
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

  -- A table a module has renamed since the archive was written is read under
  -- the name it has today; nothing else of the archive changes.
  v_archive  := archive_under_current_names(p_archive);
  v_manifest := v_archive -> 'manifest';
  v_tables   := coalesce(v_archive -> 'tables', '{}'::jsonb);

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

  -- An archive written before `entry_lines.declared_on` existed carries none.
  -- The day is derived from the archive's own lines and entries, by the rule
  -- the column stores, before anything is loaded; the checksums above were
  -- read on the archive as it was written.
  if jsonb_array_length(coalesce(v_tables -> 'public.entry_lines', '[]'::jsonb)) > 0
     and not ((v_tables -> 'public.entry_lines' -> 0) ? 'declared_on') then
    v_tables := jsonb_set(v_tables, array['public.entry_lines'], (
      select jsonb_agg(x.l || jsonb_build_object('declared_on',
                         declared_on_of((x.l ->> 'tax_point_date')::date, (e.v ->> 'entry_date')::date))
                       order by x.n)
        from jsonb_array_elements(v_tables -> 'public.entry_lines') with ordinality as x(l, n)
        left join jsonb_array_elements(coalesce(v_tables -> 'public.entries', '[]'::jsonb)) as e(v)
          on e.v ->> 'id' = x.l ->> 'entry_id'));
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
       and a.attname <> 'company_id'
       -- The company's own id, in the keys that hold `companies` to its own
       -- accounts and journals: it is there from the first pass.
       and not (v_class = 'public.companies'::regclass and a.attname = 'id');

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

  --    And every line counts for a return on the day the rule gives it, which
  --    is what the trigger would have written.
  select coalesce(e.number, '(no number)') || ', line ' || l.sequence into v_found
    from entry_lines l
    join entries e on e.id = l.entry_id
   where l.company_id = v_company
     and l.declared_on is distinct from declared_on_of(l.tax_point_date, e.entry_date)
   limit 1;
  if found then
    raise exception 'declared_on_mismatch: entry % carries a declared_on that is not its tax point, nor the date of its entry where it has none', v_found;
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
  'Takes one company archive into this installation, whole or not at all. Checks the manifest against the values of the rows — `values_sha256`, which a reader reproduces after parsing the archive — and against their bytes for an archive written before 0.9.0. A table a module has renamed since is read under its name of today. entry_lines.declared_on is derived for an archive written before it existed, and checked against declared_on_of() for one that carries it.';

revoke execute on function import_company(jsonb, uuid) from public, anon;
grant execute on function import_company(jsonb, uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 8. A company records who created it
-- ---------------------------------------------------------------------------

alter table companies add column if not exists created_by uuid;

comment on column companies.created_by is
  'The person who created the company — acting_user() when it was written — or null when the installation did (the installer, a migration, an archive brought in). Written once and never changed: it is what companies_per_person counts on a shared installation, whoever owns the company today (decision 0065). No foreign key: it outlives the account, like the trail.';

-- The companies that already exist are counted as the allowance counted them
-- until now: against their first owner. Left empty, a person who already
-- holds their allowance would be given it again by this migration. The
-- column is new, so neither its trail nor the time of its last change has
-- anything to say about it, and both triggers sit out this one statement.
alter table companies disable trigger companies_audit;
alter table companies disable trigger companies_set_updated_at;
update companies c
   set created_by = (select m.user_id from company_members m
                      where m.company_id = c.id and m.role = 'owner'
                      order by m.created_at, m.user_id limit 1)
 where c.created_by is null;
alter table companies enable trigger companies_set_updated_at;
alter table companies enable trigger companies_audit;

create or replace function companies_creator_is_fixed()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
begin
  if tg_op = 'INSERT' then
    if not is_installer() then
      new.created_by := acting_user();
    end if;
    return new;
  end if;
  if new.created_by is distinct from old.created_by and not is_installer() then
    raise exception 'company_creator_is_fixed: who created a company is written when it is created, and stays'
      using errcode = '55006';
  end if;
  return new;
end;
$$;

comment on function companies_creator_is_fixed() is
  'Writes companies.created_by from acting_user() when a company is created, and refuses to change it afterwards. The installer writes what it brings in as it is.';

drop trigger if exists companies_creator_is_fixed on companies;
create trigger companies_creator_is_fixed
  before insert or update of created_by on companies
  for each row execute function companies_creator_is_fixed();

-- `create_company()` counts what the person created. Unchanged but for the
-- count and the words of its refusal.
create or replace function create_company(
  p_name              text,
  p_country           char(2),
  p_currency_code     char(3) default null,
  p_language          char(2) default null,
  p_chart_code        text    default null,
  p_fiscal_year       integer default null,
  p_fiscal_year_start date    default null,
  p_owner_user_id     uuid    default null
)
returns companies
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_defaults country_defaults%rowtype;
  v_currency char(3);
  v_language char(2);
  v_owner    uuid := coalesce(p_owner_user_id, auth.uid());
  v_year     integer := coalesce(p_fiscal_year, extract(year from coalesce(p_fiscal_year_start, current_date))::integer);
  v_bounds   record;
  v_company  companies%rowtype;
  v_sharing  record;
  v_owned    integer;
begin
  if not is_installer() and not is_instance_admin() then
    select * into v_sharing from instance_sharing();
    if not v_sharing.shared then
      raise exception 'not_instance_admin: creating a company is an instance-level act'
        using errcode = '42501';
    end if;
    -- A person, in their own session. A key does not choose who owns a company.
    if auth.uid() is null or nullif(current_setting('ekwo.api_key', true), '') is not null then
      raise exception 'not_allowed: a company of one''s own is created by a signed-in person, in their own session'
        using errcode = '42501';
    end if;
    if p_owner_user_id is not null and p_owner_user_id is distinct from auth.uid() then
      raise exception 'not_allowed: a company of one''s own is owned by whoever creates it'
        using errcode = '42501';
    end if;
    v_owner := auth.uid();
    -- What the person created, whoever owns it now: handing a company to a
    -- second account does not give the allowance back.
    perform pg_advisory_xact_lock(hashtextextended('ekwo.create_company:' || v_owner::text, 0));
    select count(*) into v_owned
      from companies c
     where c.created_by = v_owner;
    if v_owned >= v_sharing.companies_per_person then
      raise exception 'company_limit: this installation lets one person create % compan%, and you have created %',
        v_sharing.companies_per_person,
        case when v_sharing.companies_per_person = 1 then 'y' else 'ies' end,
        v_owned
        using errcode = '42501';
    end if;
  end if;

  select * into v_defaults from country_defaults where country = p_country;

  -- The currency and the language have to be settled before the insert: both
  -- columns are not null with a default, so there is no later moment at which
  -- they are empty and the pack could fill them. The pack answers, or the
  -- caller does, and there is no third answer written here.
  v_currency := upper(coalesce(p_currency_code, v_defaults.currency_code));
  if v_currency is null then
    raise exception 'no_currency: the % pack names no currency; name one', p_country;
  end if;
  v_language := lower(coalesce(p_language, v_defaults.language_default));
  if v_language is null then
    raise exception 'no_language: the % pack names no language for its labels; name one', p_country;
  end if;

  select * into v_bounds from fiscal_year_bounds(p_country, v_year, p_fiscal_year_start);

  insert into companies (name, country, fiscal_country, currency_code, language)
  values (p_name, p_country, p_country, v_currency, v_language)
  returning * into v_company;

  if v_owner is not null then
    insert into company_members (company_id, user_id, role)
    values (v_company.id, v_owner, 'owner')
    on conflict (company_id, user_id) do nothing;
  end if;

  perform install_country_template(v_company.id, p_country, v_language, p_chart_code);

  insert into fiscal_years (company_id, name, start_date, end_date)
  values (v_company.id, 'FY' || v_year::text, v_bounds.start_date, v_bounds.end_date);

  select * into v_company from companies where id = v_company.id;
  return v_company;
end;
$$;

comment on function create_company(text, char, char, char, text, integer, date, uuid) is
  'Creates a company, makes its owner the first member, copies the country pack into it and opens its first financial year on the month that pack declares. An instance-level act; on a shared installation, also a signed-in person''s for a company of their own, up to companies_per_person counted on what they created (decision 0065).';

-- ---------------------------------------------------------------------------
-- 9. A deposit keeps files of its own declaration's company
-- ---------------------------------------------------------------------------
--
-- `tax_filing_deposits` carries no company: it reaches one through its
-- declaration. Its two files named `attachments` by id alone, so a deposit of
-- one's own accepted a file of another company — which said that it exists,
-- and kept a reference to it — and refused an id of nobody by its foreign key.
-- The file is now looked for in the declaration's company, before either key
-- is asked, and refused in the same words whether it is another company's or
-- nobody's. A person or a key who names a declaration of a company they may
-- not know of is refused before anything is read for it, as by the guards of
-- section 3; the backend role and the owner meet the check in full.

create or replace function tax_filing_deposits_files_are_its_own()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_company uuid;
begin
  -- Only what the row names anew: emptying a file, which deleting it does by
  -- its foreign key, names nothing.
  if tg_op = 'UPDATE'
     and new.filing_id = old.filing_id
     and (new.sent_file_id is null or new.sent_file_id is not distinct from old.sent_file_id)
     and (new.acknowledgement_id is null or new.acknowledgement_id is not distinct from old.acknowledgement_id) then
    return new;
  end if;

  select f.company_id into v_company from tax_filings f where f.id = new.filing_id;
  perform assert_writes_into_known_company(v_company);

  if (new.sent_file_id is not null
      and not exists (select 1 from attachments a where a.id = new.sent_file_id and a.company_id = v_company))
     or (new.acknowledgement_id is not null
      and not exists (select 1 from attachments a where a.id = new.acknowledgement_id and a.company_id = v_company)) then
    raise exception 'unknown_attachment: a deposit keeps the files of its own declaration''s company, and names one that is not'
      using errcode = '23503';
  end if;
  return new;
end;
$$;

comment on function tax_filing_deposits_files_are_its_own() is
  'Refuses a deposit whose sent file or receipt is not an attachment of its declaration''s company, in the same words for a file of another company and a file of nobody, before either foreign key is asked; and a person or a key who names a declaration of a company they may not know of, before anything is read (decision 0065).';

drop trigger if exists tax_filing_deposits_files_are_its_own on tax_filing_deposits;
create trigger tax_filing_deposits_files_are_its_own
  before insert or update of filing_id, sent_file_id, acknowledgement_id on tax_filing_deposits
  for each row execute function tax_filing_deposits_files_are_its_own();

-- ---------------------------------------------------------------------------
-- Grants
-- ---------------------------------------------------------------------------

-- Every function redefined above keeps the grants it had. The new ones are
-- triggers, helpers the guards call as definer, and helpers for migrations:
-- nobody's.

revoke execute on all functions in schema public from public;

revoke execute on function instance_admins_keep_one() from public, anon, authenticated, service_role;
revoke execute on function user_preferences_company_is_known() from public, anon, authenticated, service_role;
revoke execute on function companies_creator_is_fixed() from public, anon, authenticated, service_role;
revoke execute on function scope_references_to_company(text) from public, anon, authenticated, service_role;
revoke execute on function company_column(regclass) from public, anon, authenticated, service_role;
revoke execute on function company_references_by_id(text) from public, anon, authenticated, service_role;
revoke execute on function assert_references_within_company(text) from public, anon, authenticated, service_role;
revoke execute on function assert_writes_into_known_company(uuid) from public, anon, authenticated, service_role;
revoke execute on function tax_filing_deposits_files_are_its_own() from public, anon, authenticated, service_role;
