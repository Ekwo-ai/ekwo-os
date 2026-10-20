-- Ekwo OS — a company is archived before it leaves.
--
-- Until this file nothing in the schema said how a company ends. `companies`
-- had no state but "here", no function closed one, and the policy
-- `companies_delete` let anybody holding `company.write` run
-- `delete from companies`: thirty-nine foreign keys cascade from that table,
-- so one statement erased the whole books — entries, documents, the bank, the
-- declarations and their proofs — with no guard, no second word and no export
-- first. A screen about to draw a "danger zone" on the company profile needs
-- the rule in the core, once, where the command line, the MCP server and
-- every client meet it the same way (decision 0081).
--
-- **A company is archived first.** `companies.archived_at` is the state:
-- null while the books are kept, a moment once they are closed. An archived
-- company is read-only for the ledger. The acts that write a posted entry —
-- posting an entry, booking a document, booking a payment, an entry of a
-- module, closing or re-opening a year — are refused with `company_archived`,
-- where each of them is already judged: the three capability triggers of
-- `20260913083216` guard the transition to `posted` on `entries` and
-- `documents` and the flip of `is_closed` on `fiscal_years`, for every path
-- into it, so no function of a thousand lines is republished for one check.
-- Reading, `export_company()`, the members and the profile stay as they were:
-- an archived company is a company one reads, exports and leaves.
--
-- **The owner archives and restores.** `archive_company()` and
-- `unarchive_company()` are the act of the owner preset and of nobody else —
-- not a capability an accountant may be granted, because closing the books of
-- a company is the client's decision as leaving with them is (decision 0043).
-- Both are idempotent and answer the row. The column itself is written by
-- nobody: `companies_guard_archived()` refuses a hand-written change, and the
-- setting the two functions raise is honoured for an owner only, as the
-- settings of the year end are honoured for whoever holds the capability
-- (`20260929094126`).
--
-- **Deleting is a function, with the name of the company as its signature.**
-- `delete_company(company, confirm_name)` is the act of the owner too. It
-- refuses a name that is not the company's, exactly (`company_name_mismatch`);
-- a company another member still reaches (`company_has_other_members`),
-- because nobody loses books through a decision they were not part of; and a
-- company a live machine key is scoped to (`company_has_live_keys`), because a
-- key that writes into a company that no longer exists is an incident waiting
-- to be read in a log. Then it deletes the row and lets the foreign keys do
-- the rest, with the user triggers of the company's tables off for its
-- transaction, as `import_company()` fills them: the guards of a posted entry
-- and of a locked period are written for a person moving one row in a company
-- that goes on, and this company does not. The trail is not a table of the
-- company — `audit_log.company_id` is no foreign key — so it keeps every row
-- it holds about the company, and gains `company_deleted`, written last.
--
-- The policy `companies_delete` is dropped and the `delete` privilege on
-- `companies` is taken back from `authenticated` and `service_role`, so the
-- function is the only way out: a grant says what the policies say, and there
-- is no policy left to say it (decision 0003).

-- ---------------------------------------------------------------------------
-- 1. The state
-- ---------------------------------------------------------------------------

alter table companies add column archived_at timestamptz;

comment on column companies.archived_at is
  'When the owner archived the company; null while its books are kept. An archived company is read-only for the ledger: posting an entry, booking a document or a payment and closing a year are refused with company_archived, while reading, exporting, the members and the profile stay available. Set by archive_company() and cleared by unarchive_company(), never written by hand.';

-- ---------------------------------------------------------------------------
-- 2. The column is written by its functions
-- ---------------------------------------------------------------------------

create or replace function companies_guard_archived()
returns trigger
language plpgsql
as $$
begin
  if new.archived_at is not distinct from old.archived_at then
    return new;
  end if;

  if coalesce(current_setting('ekwo.archiving_company', true), '') = 'on' then
    if is_installer() or is_company_owner(new.id) then
      return new;
    end if;
    raise exception 'not_allowed: archiving or restoring a company is the act of its owner'
      using errcode = '42501';
  end if;

  raise exception 'company_archive_not_a_column: archived_at is set by archive_company() and cleared by unarchive_company()'
    using errcode = '55006';
end;
$$;
comment on function companies_guard_archived() is
  'Refuses a hand-written change to archived_at. The setting archive_company() and unarchive_company() raise is honoured only for the installer or the owner of the company, because any session may set it. A column any client may flip is not a state.';

create trigger companies_guard_archived
  before update of archived_at on companies
  for each row execute function companies_guard_archived();

-- ---------------------------------------------------------------------------
-- 3. An archived company is read-only for the ledger
-- ---------------------------------------------------------------------------

create or replace function assert_company_live(p_company_id uuid)
returns void
language plpgsql
stable
set search_path = public, pg_temp
as $$
begin
  if exists (select 1 from companies c where c.id = p_company_id and c.archived_at is not null) then
    raise exception 'company_archived: this company is archived and its books are read-only; its owner restores it with unarchive_company() before anything is posted'
      using errcode = '55006';
  end if;
end;
$$;
comment on function assert_company_live(uuid) is
  'Raises company_archived while companies.archived_at is set. Asked by the guards of the acts that write a posted entry — posting an entry, booking a document or a payment, an entry of a module, closing or re-opening a year — once the capability of the caller has been checked.';

-- The three guards of `20260913083216`, as `20260913102115` left them, each
-- with the one question more. The capability is asked first: a stranger
-- learns nothing about the state of a company they are not in.

create or replace function assert_may_post_entry()
returns trigger
language plpgsql
as $$
begin
  if not is_installer() and not has_capability(new.company_id, 'entries.post') then
    raise exception 'not_allowed: posting an entry in this company needs entries.post'
      using errcode = '42501';
  end if;
  if not is_installer() then
    perform assert_company_live(new.company_id);
  end if;
  return new;
end;
$$;

create or replace function assert_may_post_document()
returns trigger
language plpgsql
as $$
begin
  if not is_installer() and not has_capability(new.company_id, 'documents.post') then
    raise exception 'not_allowed: booking a document in this company needs documents.post'
      using errcode = '42501';
  end if;
  if not is_installer() then
    perform assert_company_live(new.company_id);
  end if;
  return new;
end;
$$;

create or replace function assert_may_close_year()
returns trigger
language plpgsql
as $$
begin
  if not is_installer() and not has_capability(new.company_id, 'year_end.close') then
    raise exception 'not_allowed: closing or re-opening a financial year needs year_end.close'
      using errcode = '42501';
  end if;
  if not is_installer() then
    perform assert_company_live(new.company_id);
  end if;
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- 4. The owner archives, and restores
-- ---------------------------------------------------------------------------

create or replace function archive_company(p_company_id uuid)
returns companies
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_row companies%rowtype;
begin
  if not is_company_owner(p_company_id) then
    raise exception 'not_allowed: archiving a company is the act of its owner'
      using errcode = '42501';
  end if;

  select * into v_row from companies where id = p_company_id for update;
  if not found then
    raise exception 'unknown_company: %', p_company_id;
  end if;
  if v_row.archived_at is not null then
    return v_row;
  end if;

  perform set_config('ekwo.archiving_company', 'on', true);
  update companies
     set archived_at = now()
   where id = p_company_id
  returning * into v_row;
  perform set_config('ekwo.archiving_company', 'off', true);

  perform audit_record(p_company_id, 'companies', p_company_id, v_row.name,
                       'update', 'company_archived',
                       null, jsonb_build_object('archived_at', v_row.archived_at));
  return v_row;
end;
$$;
comment on function archive_company(uuid) is
  'Archives a company: its books become read-only for the ledger, while reading, exporting, the members and the profile stay available. The act of the owner preset, refused to everybody else with not_allowed. Archiving a company that is already archived changes nothing and answers the row. Writes company_archived on the trail.';

create or replace function unarchive_company(p_company_id uuid)
returns companies
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_row companies%rowtype;
begin
  if not is_company_owner(p_company_id) then
    raise exception 'not_allowed: restoring a company is the act of its owner'
      using errcode = '42501';
  end if;

  select * into v_row from companies where id = p_company_id for update;
  if not found then
    raise exception 'unknown_company: %', p_company_id;
  end if;
  if v_row.archived_at is null then
    return v_row;
  end if;

  perform set_config('ekwo.archiving_company', 'on', true);
  update companies
     set archived_at = null
   where id = p_company_id
  returning * into v_row;
  perform set_config('ekwo.archiving_company', 'off', true);

  perform audit_record(p_company_id, 'companies', p_company_id, v_row.name,
                       'update', 'company_unarchived',
                       null, jsonb_build_object('archived_at', null));
  return v_row;
end;
$$;
comment on function unarchive_company(uuid) is
  'Restores an archived company: posting, booking and closing are possible again. The act of the owner preset, refused to everybody else with not_allowed. Restoring a company that is not archived changes nothing and answers the row. Writes company_unarchived on the trail.';

-- ---------------------------------------------------------------------------
-- 5. The owner deletes, by name
-- ---------------------------------------------------------------------------

create or replace function delete_company(p_company_id uuid, p_confirm_name text)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_row      companies%rowtype;
  v_others   integer;
  v_keys     integer;
  v_table    record;
  v_class    regclass;
  v_silenced regclass[] := '{}';
  v_were_off jsonb := '[]'::jsonb;
  v_pass     jsonb;
begin
  if not is_company_owner(p_company_id) then
    raise exception 'not_allowed: deleting a company is the act of its owner'
      using errcode = '42501';
  end if;

  select * into v_row from companies where id = p_company_id for update;
  if not found then
    raise exception 'unknown_company: %', p_company_id;
  end if;

  -- The name, exactly as the profile shows it: a confirmation is typed, not
  -- clicked, and a name that differs by a space is not the name.
  if p_confirm_name is distinct from v_row.name then
    raise exception 'company_name_mismatch: the name given does not match the name of the company; type it exactly as its profile shows it'
      using errcode = '22023';
  end if;

  select count(*) into v_others
    from company_members m
   where m.company_id = p_company_id
     and m.user_id is distinct from acting_user();
  if v_others > 0 then
    raise exception 'company_has_other_members: % other member(s) still reach the books through this company; remove them first, or let them leave'
      , v_others
      using errcode = '55006';
  end if;

  select count(*) into v_keys
    from api_keys k
   where k.company_id = p_company_id
     and k.revoked_at is null
     and (k.expires_at is null or k.expires_at > now());
  if v_keys > 0 then
    raise exception 'company_has_live_keys: % machine key(s) of this company are live; revoke them first'
      , v_keys
      using errcode = '55006';
  end if;

  -- The guards of the tables of a company are written for a person moving
  -- one row in a company that goes on: a posted entry does not move, a locked
  -- period takes nothing back, a filed declaration is frozen. This company
  -- does not go on, so they are switched off, on its tables and nowhere else,
  -- inside this transaction, as `import_company()` switches them off to fill
  -- the same tables — and only where there is one to switch off. A trigger an
  -- operator had set otherwise is put back the way it was.
  for v_table in
    select t.table_schema, t.table_name
      from company_scoped_tables() t
     where not (t.table_schema = 'public' and t.table_name = 'companies')
  loop
    v_class := format('%I.%I', v_table.table_schema, v_table.table_name)::regclass;
    if exists (select 1 from pg_trigger g where g.tgrelid = v_class and not g.tgisinternal) then
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
  end loop;

  delete from companies where id = p_company_id;

  foreach v_class in array v_silenced loop
    execute format('alter table %s enable trigger user', v_class);
  end loop;
  for v_pass in select jsonb_array_elements(v_were_off) loop
    execute format('alter table %s %s %I', v_pass ->> 'class', v_pass ->> 'verb', v_pass ->> 'name');
  end loop;

  -- The trail is not a table of the company and keeps what it holds about it;
  -- this is its last row.
  perform audit_record(p_company_id, 'companies', p_company_id, v_row.name,
                       'delete', 'company_deleted',
                       jsonb_build_object('name', v_row.name, 'country', v_row.country,
                                          'archived_at', v_row.archived_at),
                       null);
end;
$$;
comment on function delete_company(uuid, text) is
  'Deletes a company and, through the foreign keys, everything that belongs to it. The act of the owner preset; p_confirm_name must be the name of the company exactly (company_name_mismatch). Refused while another member still reaches the books through it (company_has_other_members) and while a machine key scoped to it is live (company_has_live_keys). The user triggers of the company''s tables are off for the transaction, as import_company() has them. The trail keeps its rows about the company and ends them with company_deleted. The only way a company leaves: no policy lets a client delete from companies.';

-- ---------------------------------------------------------------------------
-- 6. The function is the only way out
-- ---------------------------------------------------------------------------

drop policy if exists companies_delete on companies;

-- A grant says what the policies say, and no policy judges a delete any more.
revoke delete on table companies from authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Grants
-- ---------------------------------------------------------------------------

-- `create or replace` keeps the privileges a function already had, and a new
-- function comes out with the built-in default, which Supabase publishes as
-- an anonymous RPC endpoint: every migration of this directory ends with the
-- revoke, and grants what it created by name. A trigger body is granted to
-- nobody.
revoke execute on all functions in schema public from public;

revoke execute on function assert_company_live(uuid) from public, anon;
grant  execute on function assert_company_live(uuid) to authenticated, service_role;
revoke execute on function archive_company(uuid) from public, anon;
grant  execute on function archive_company(uuid) to authenticated, service_role;
revoke execute on function unarchive_company(uuid) from public, anon;
grant  execute on function unarchive_company(uuid) to authenticated, service_role;
revoke execute on function delete_company(uuid, text) from public, anon;
grant  execute on function delete_company(uuid, text) to authenticated, service_role;
