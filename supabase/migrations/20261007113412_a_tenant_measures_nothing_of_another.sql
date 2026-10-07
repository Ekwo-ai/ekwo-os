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
--      for it in the row's own company, and step aside for a row headed for a
--      company the caller may not know of, which row level security refuses.
--   4. **A preference named any company.** `user_preferences` refused a
--      company that does not exist by its foreign key, and so said which ones
--      do. A company the caller may not know of is now refused first, with
--      the same answer as one that does not exist.
--   5. **References by id alone.** A column that names a row of a company's
--      table by its id named it in any company. Every such reference of the
--      socle is now a composite key with `company_id` (the modules do the same
--      in their own migrations), so a row only ever names a row of its own
--      company — and another company cannot plant a reference that keeps one
--      of yours from being deleted.
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

  -- A row moved to a company the caller may not know of is refused by row
  -- level security, after this trigger; nothing below is read for it.
  if tg_op = 'UPDATE' and not may_know_of_company(new.company_id) then
    return new;
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
  -- A line written into a company the caller may not know of is refused by
  -- row level security, after this trigger; nothing is read for it. And the
  -- document a line names is looked for in the line's own company: one of
  -- another company is, to this trigger, one that does not exist, and the
  -- foreign key refuses it as it refuses an id nobody holds.
  if tg_op <> 'DELETE' and not may_know_of_company(new.company_id) then
    return new;
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

  -- An entry moved to a company the caller may not know of is refused by row
  -- level security, after this trigger; nothing below is read for it.
  if tg_op = 'UPDATE' and not may_know_of_company(new.company_id) then
    return new;
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
  -- A line written into a company the caller may not know of is refused by
  -- row level security, after this trigger; nothing is read for it. The entry
  -- a line names is looked for in the line's own company.
  if tg_op <> 'DELETE' and not may_know_of_company(new.company_id) then
    return new;
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
  for r in
    select f.conname, f.conrelid, f.confrelid, f.confdeltype, f.condeferrable, f.condeferred,
           a.attname::text as col, fa.attname::text as fcol,
           rel.relname::text as relname, trel.relname::text as target_name
      from pg_constraint f
      join pg_class rel on rel.oid = f.conrelid
      join pg_namespace n on n.oid = rel.relnamespace
      join pg_class trel on trel.oid = f.confrelid
      join pg_attribute a on a.attrelid = f.conrelid and a.attnum = f.conkey[1]
      join pg_attribute fa on fa.attrelid = f.confrelid and fa.attnum = f.confkey[1]
     where f.contype = 'f'
       and cardinality(f.conkey) = 1
       and n.nspname = p_schema
       and f.confrelid <> 'public.companies'::regclass
       and a.attname <> 'company_id'
       and a.atttypid = 'uuid'::regtype
       and exists (select 1 from pg_attribute c
                    where c.attrelid = f.conrelid and c.attname = 'company_id' and not c.attisdropped)
       and exists (select 1 from pg_attribute c
                    where c.attrelid = f.confrelid and c.attname = 'company_id' and not c.attisdropped)
     order by rel.relname, a.attname, f.conname
  loop
    -- The table it points at answers to its key and the company together.
    if not exists (
      select 1 from pg_index i
       where i.indrelid = r.confrelid and i.indisunique and i.indpred is null and i.indexprs is null
         and i.indnatts = 2
         and (select array_agg(x.attname::text order by x.attname::text)
                from pg_attribute x where x.attrelid = i.indrelid and x.attnum = any (i.indkey))
             = (select array_agg(v order by v) from unnest(array[r.fcol, 'company_id']) v)) then
      execute format('create unique index %I on %s (%I, company_id)',
                     left(r.target_name || '_' || r.fcol || '_company_idx', 63), r.confrelid::regclass, r.fcol);
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
                    where x.attname = 'company_id' and y.attname = 'company_id')
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
        execute format('alter table %s drop constraint %I', r.conrelid::regclass, v_composite.conname);
        v_name := v_composite.conname;
      else
        v_name := left(r.relname || '_' || r.col || '_company_id_fkey', 63);
      end if;
      execute format('alter table %s add constraint %I foreign key (%I, company_id) references %s (%I, company_id) %s%s',
                     r.conrelid::regclass, v_name, r.col, r.confrelid::regclass, r.fcol, v_action,
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
             = array[r.col, 'company_id']) then
      execute format('create index %I on %s (%I, company_id)',
                     left(r.relname || '_' || r.col || '_company_idx', 63), r.conrelid::regclass, r.col);
    end if;

    execute format('alter table %s drop constraint %I', r.conrelid::regclass, r.conname);
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
           con.conname, con.contype,
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
       and exists (select 1 from pg_attribute a
                    where a.attrelid = i.indrelid and a.attname = 'company_id' and not a.attisdropped)
       and not exists (select 1 from pg_attribute a
                        where a.attrelid = i.indrelid and a.attnum = any (i.indkey) and a.attname = 'company_id')
       and exists (select 1
                     from pg_constraint f
                     join pg_attribute a on a.attrelid = f.conrelid and a.attnum = any (f.conkey)
                    where f.contype = 'f' and f.conrelid = i.indrelid
                      and f.confrelid <> 'public.companies'::regclass
                      and a.attname <> 'company_id'
                      and a.attnum = any (i.indkey)
                      and exists (select 1 from pg_attribute t
                                   where t.attrelid = f.confrelid and t.attname = 'company_id' and not t.attisdropped))
     order by c.relname, i.indexrelid::regclass::text
  loop
    if r.contype = 'p' then
      execute format('alter table %s drop constraint %I, add constraint %I primary key (%s, company_id)',
                     r.indrelid::regclass, r.conname, r.conname, r.columns);
    elsif r.contype = 'u' then
      execute format('alter table %s drop constraint %I, add constraint %I unique (%s, company_id)',
                     r.indrelid::regclass, r.conname, r.conname, r.columns);
    else
      v_name := (select relname::text from pg_class where oid = r.indexrelid);
      execute format('drop index %s', r.indexrelid::regclass);
      execute format('create unique index %I on %s (%s, company_id)%s',
                     v_name, r.indrelid::regclass, r.columns,
                     case when r.predicate is null then '' else ' where ' || r.predicate end);
    end if;
    v_done := v_done + 1;
  end loop;
  return v_done;
end;
$$;

comment on function scope_references_to_company(text) is
  'Makes every reference of a schema from a company''s table to another company''s table by id alone a composite key with company_id, keeping its delete action, and drops the single-column key — where a composite one stood beside it too, the two failed with different names for an id of another company and an id of nobody. Then adds company_id to every unique key of those tables that holds such a reference and not the company, which a row naming another company''s row collided with before any foreign key was asked (decision 0065). Returns how many it changed. For migrations, the socle''s and the modules''; executable by nobody else.';

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
-- Grants
-- ---------------------------------------------------------------------------

-- Every function redefined above keeps the grants it had. The new ones are
-- triggers, and a helper for migrations: nobody's.

revoke execute on all functions in schema public from public;

revoke execute on function instance_admins_keep_one() from public, anon, authenticated, service_role;
revoke execute on function user_preferences_company_is_known() from public, anon, authenticated, service_role;
revoke execute on function companies_creator_is_fixed() from public, anon, authenticated, service_role;
revoke execute on function scope_references_to_company(text) from public, anon, authenticated, service_role;
