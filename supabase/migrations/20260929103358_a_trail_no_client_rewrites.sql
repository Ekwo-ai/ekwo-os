-- ---------------------------------------------------------------------------
-- A trail no client rewrites
-- ---------------------------------------------------------------------------
-- Found by an outside reader of these migrations, on 29 September 2026.
--
-- `20260914103412` said of `audit_log` that its trigger "holds for everyone,
-- owner included", and `20260914151207` that the table was "append-only by
-- trigger for every role including its owner". A trigger cannot promise that.
-- The owner of a table may `alter table audit_log disable trigger …`, may set
-- `session_replication_role` to `replica` if it is a superuser, and could
-- until this file simply `set local ekwo.audit_purge = 'on'` — the guard let
-- any delete through on that setting, and the cutoff and the record of the
-- purge lived only inside `purge_audit_log()`, so a purge made by hand had
-- neither. That is ordinary PostgreSQL: whoever owns the database owns what is
-- in it. The claim was wider than the code.
--
-- What holds, and what this schema says from here: **no client rewrites the
-- history.** A person, a machine key, `service_role`, a second login an
-- operator created — none holds UPDATE, DELETE or TRUNCATE on the table, and
-- the trigger refuses the first two to any role a grant ever reaches. The
-- owner of the database is not a client: it is bound as long as it leaves the
-- triggers enabled, and not further. An installation that needs a trail its
-- own operator cannot edit needs a copy that has left the database; that is a
-- design of its own and is not in this file.
--
-- Within that limit, the purge moves from the function into the table:
--
-- * **The setting now carries the cutoff.** `ekwo.audit_purge` holds the date
--   written `YYYY-MM-DD`, not `on`. A row leaves only if it was written
--   strictly before that date, the date is not in the future, and the role
--   deleting it is the owner of the table — which `purge_audit_log()`, a
--   definer function, is. The same checks run whether the delete came through
--   the function or through a `set local` by hand.
-- * **The record is written by the table.** A statement trigger after the
--   delete writes the `audit_log_purged` row, with the cutoff, the number of
--   rows and the login that did it, so a purge made by hand leaves the same
--   line as one made by the function. It is a trigger of its own: switching
--   the guard off by name leaves the record on.
-- * **TRUNCATE is refused.** A row trigger never sees one, and the owner could
--   empty the table without meeting the guard at all.
--
-- `purge_audit_log(date)` keeps its signature, its refusals and its answer —
-- the number of rows dropped — and now only raises the setting and deletes.
-- ---------------------------------------------------------------------------

create or replace function audit_log_is_append_only()
returns trigger
language plpgsql
as $$
declare
  v_setting text := nullif(current_setting('ekwo.audit_purge', true), '');
  v_before  date;
begin
  if tg_op = 'DELETE' and v_setting is not null then
    -- The owner first: for anybody else the answer does not depend on the
    -- date, and saying so is shorter than checking it.
    if not pg_has_role(current_user,
                       (select c.relowner from pg_class c where c.oid = tg_relid),
                       'MEMBER') then
      raise exception 'audit_purge_not_the_owner: only the owner of audit_log purges it. Call purge_audit_log(date), which service_role may.'
        using errcode = '42501';
    end if;
    -- Written in full, so that no `DateStyle` reads it as another day.
    if v_setting !~ '^\d{4}-\d{2}-\d{2}$' then
      raise exception 'audit_purge_needs_a_date: ekwo.audit_purge holds %, which is not a date written YYYY-MM-DD. Call purge_audit_log(date) with the date before which rows are dropped.', v_setting
        using errcode = '22007';
    end if;
    v_before := v_setting::date;
    if v_before > current_date then
      raise exception 'audit_purge_in_the_future: % is not in the past, so this would empty the trail.', v_before
        using errcode = '22008';
    end if;
    if old.occurred_at < v_before::timestamptz then
      return old;
    end if;
    raise exception 'audit_purge_after_the_cutoff: a row written on % is not older than %. A purge drops only what is older than the date it names.', old.occurred_at, v_before
      using errcode = '55006';
  end if;
  raise exception 'audit_log_append_only: the audit trail is written once. % is refused; rows leave it only through purge_audit_log(date).', lower(tg_op)
    using errcode = '55006';
end;
$$;

comment on function audit_log_is_append_only() is
  'Refuses every update and every delete on audit_log to any role a grant reaches — no client holds those verbs, and this refuses them again. A delete passes only while ekwo.audit_purge names a date, for a row older than it, by the owner of the table, which is how purge_audit_log() runs. The owner can disable this trigger: it keeps clients from rewriting the history, not the owner of the database.';

create or replace function audit_log_refuses_truncate()
returns trigger
language plpgsql
as $$
begin
  raise exception 'audit_log_append_only: the audit trail is written once. truncate is refused; rows leave it only through purge_audit_log(date).'
    using errcode = '55006';
end;
$$;

comment on function audit_log_refuses_truncate() is
  'Refuses TRUNCATE on audit_log, which a row trigger never sees.';

create trigger audit_log_no_truncate
  before truncate on audit_log
  for each statement execute function audit_log_refuses_truncate();

-- Definer, like every function of this schema that writes the trail:
-- `audit_record()` is closed to everybody but the owner.
create or replace function audit_log_purge_is_recorded()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_setting text := nullif(current_setting('ekwo.audit_purge', true), '');
  v_before  date;
  v_rows    bigint;
begin
  -- The guard has checked the date row by row. It is read again here without
  -- raising, because this trigger has to write even when the guard was
  -- switched off and the setting says anything at all.
  if v_setting ~ '^\d{4}-\d{2}-\d{2}$' then
    v_before := v_setting::date;
  end if;
  select count(*) into v_rows from purged;
  -- A delete that matched nothing, outside a purge, is not an act.
  if v_rows = 0 and v_setting is null then
    return null;
  end if;

  perform audit_record(null, 'audit_log', null, coalesce(v_setting, '(no cutoff)'),
                       'delete', 'audit_log_purged', null,
                       jsonb_build_object('before', v_before, 'rows', v_rows,
                                          'login', session_user::text));
  return null;
end;
$$;

comment on function audit_log_purge_is_recorded() is
  'Writes audit_log_purged after every delete on audit_log — the cutoff, the number of rows and the login — whether it came through purge_audit_log() or not. A trigger of its own, so switching the guard off by name leaves it on.';

create trigger audit_log_purge_recorded
  after delete on audit_log
  referencing old table as purged
  for each statement execute function audit_log_purge_is_recorded();

create or replace function purge_audit_log(p_before date)
returns bigint
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_deleted bigint;
begin
  if p_before is null then
    raise exception 'audit_purge_needs_a_date: name the date before which rows are dropped. There is no default retention.';
  end if;
  if p_before > current_date then
    raise exception 'audit_purge_in_the_future: % is not in the past, so this would empty the trail.', p_before;
  end if;

  -- The cutoff goes to the trigger, which checks it again and writes the
  -- record: the function no longer holds a rule the table does not.
  perform set_config('ekwo.audit_purge', to_char(p_before, 'YYYY-MM-DD'), true);
  delete from audit_log where occurred_at < p_before::timestamptz;
  get diagnostics v_deleted = row_count;
  perform set_config('ekwo.audit_purge', '', true);

  return v_deleted;
end;
$$;

comment on function purge_audit_log(date) is
  'Drops audit rows older than a date the caller names; the table checks the date again and records the purge. service_role only: retention is the operator''s decision and no signed-in user may make it.';

comment on table audit_log is
  'Append-only record of every change to the configuration and reference data of a company, and of the acts that change the state of a document, a payment, a financial year or a pack. Written by trigger, never by a client, and no client rewrites it: no role is granted update, delete or truncate, and triggers refuse them. The owner of the database is bound only while it leaves those triggers enabled.';

comment on policy audit_log_select on audit_log is
  'Members of the company read its trail; an instance administrator reads that and the rows of the installation itself. No client writes, updates or deletes: there is no policy for it and no grant, and a trigger refuses the update and the delete to any role that holds one.';

-- ---------------------------------------------------------------------------
-- Grants
--
-- Two new functions, both returning `trigger`, which is granted to nobody.
-- ---------------------------------------------------------------------------

revoke execute on all functions in schema public from public;

revoke execute on function audit_log_refuses_truncate() from public, anon, authenticated, service_role;
revoke execute on function audit_log_purge_is_recorded() from public, anon, authenticated, service_role;
