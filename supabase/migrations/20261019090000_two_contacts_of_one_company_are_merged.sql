-- Ekwo OS — two contacts of one company are merged (decision 0074).
--
-- Books taken over in two passes create one party twice, under two spellings,
-- and each contact carries half of one history: two rows of the aged balance,
-- a payment on one that `reconcile()` refuses to match with an invoice of the
-- other (`reconcile_contact_mismatch`), the learning split in two. A posted
-- line and an issued document keep their contact (`20260918161538`,
-- `20260918161204`), and `set_line_contact()` only names a line that named
-- nobody (`20261018180416`), so nothing could join them.
--
-- `merge_contacts(keep, absorb)` moves every reference of the absorbed contact
-- onto the kept one in one transaction, completes the kept one, and retires
-- the absorbed one — inactive, `merged_into` naming the kept one — never a
-- delete.
--
-- **What moves is read from the catalogue.** Every foreign key to `contacts`,
-- of any schema: the socle's (ledger lines, documents, statement lines,
-- payments) and a module's (a disposal of an asset, the asset itself), and
-- whatever a later migration adds, with no line here. Three references are
-- handled by name: `contacts.parent_id`, because the kept contact may itself
-- be a branch of the absorbed one; `contact_patterns`, which is folded — a
-- motif both had becomes one, with its counters added and its confidence
-- derived again — rather than moved into a collision with its unique key; and
-- the files attached to the contact, which `attachments` names by
-- `entity_type` and `entity_id`, not by a key.
--
-- **The two guards of what was posted let this through, and nothing else.**
-- `entry_lines_guard_posted()` and `documents_guard_posted()` are replaced
-- whole with one more exemption each: `contact_id` alone, from the absorbed
-- contact to the kept one, in the transaction in which `merge_contacts()`
-- recorded that merge in `contact_merges`. It is the transaction-local
-- exemption of `set_line_contact()`, held to a row rather than to a setting:
-- any session may raise a setting (`20260929094126`), so a member who may
-- merge could have raised one by hand and moved one posted line of their
-- choosing; nobody but `merge_contacts()` writes a merge, the way nobody but
-- `unpost_document()` writes an unposting. Each row let through is written to
-- the trail where it is let through: `line_contact_merged`,
-- `document_contact_merged`. The period guard needs no exemption: a change of
-- contact alone is not a change to the accounts, and it already stands aside
-- for it.
--
-- **`contact_merges` is the record of the act**: which contact was absorbed
-- into which, by whom, when, what moved table by table and what was filled.
-- One row per absorbed contact, read by whoever reads the contacts, written by
-- `merge_contacts()` alone, and carried by a company that leaves.
--
-- **What a merge asks: `contacts.write` and `reconcile.write`.** The record of
-- the party, and who an item belongs to — what naming the counterparty of a
-- posted line already asks. Not `entries.write` or `documents.post`: no
-- amount, account, date, box or number moves. The function is `security
-- definer`, so that a policy the caller does not meet — `bank.write` on the
-- statement lines, `payments.write` on the payments — cannot leave part of the
-- history on the absorbed contact without a word. Its checks are its first
-- lines, and a contact the caller may not read is a contact that does not
-- exist.
--
-- **A matching stays the matching of one party.** Both sides of a matching
-- move together, so a matching of the absorbed contact's items becomes one of
-- the kept contact's. Where the absorbed contact was matched with the items of
-- its parent, the kept contact takes that parent when it has none; when it has
-- another, the merge would leave a matching across two parties, and is
-- refused, `matching_across_parties`.
--
-- **An absorbed contact is named no more.** `refuse_merged_contact()` is a
-- trigger on every table that references `contacts`, attached by
-- `refuse_merged_contacts_in(schema)` the way `scope_references_to_company()`
-- reaches every reference: here for `public`, and by a module migration for
-- its own schema. `contacts_guard_merged()` keeps a merged contact retired:
-- written merged only by `merge_contacts()`, never made active again, never
-- deleted while its company stands, and pointed elsewhere only to follow the
-- contact it names when that one is merged in its turn — so `merged_into`
-- always names a contact in use, and no chain is ever read.

-- ---------------------------------------------------------------------------
-- 1. merged_into, and the record of a merge
-- ---------------------------------------------------------------------------

alter table contacts add column merged_into uuid;

alter table contacts
  add constraint contacts_merged_into_company_id_fkey
  foreign key (merged_into, company_id) references contacts (id, company_id);

alter table contacts
  add constraint contacts_merged_is_retired
  check (merged_into is null or (merged_into <> id and not active));

create index contacts_merged_into_company_idx on contacts (merged_into, company_id)
  where merged_into is not null;

comment on column contacts.merged_into is
  'The contact this one was merged into by merge_contacts(), which moved every reference of this one onto it (decision 0074). Null for a contact in use. A merged contact is inactive, stays as the record of what was imported, and is named by no row again.';

create table contact_merges (
  id           uuid primary key default gen_random_uuid(),
  company_id   uuid not null references companies(id) on delete cascade,
  kept_id      uuid not null,
  absorbed_id  uuid not null,
  -- What moved onto the kept contact, by table, and the fields it took.
  moved        jsonb not null default '{}',
  filled       text[] not null default '{}',
  merged_by    uuid,
  merged_at    timestamptz not null default now(),
  -- The transaction that wrote the row, which is the one the guards let
  -- through. Nothing after it can use this row to move anything.
  transaction_id bigint not null default txid_current(),
  foreign key (kept_id, company_id) references contacts (id, company_id),
  foreign key (absorbed_id, company_id) references contacts (id, company_id),
  constraint contact_merges_two_contacts check (kept_id <> absorbed_id)
);

comment on table contact_merges is
  'Every merge of two contacts, by merge_contacts() (decision 0074): the contact absorbed, the one kept, who merged them and when, what moved and what was filled. Written by merge_contacts() and by nothing else — no role may insert — so the guards of a posted line and of an issued document read a row here, written in the same transaction, as the exemption that lets contact_id move from the absorbed contact to the kept one.';
comment on column contact_merges.kept_id is
  'The contact that took the history. It may itself be merged later; contacts.merged_into then follows, and this row keeps saying what happened.';
comment on column contact_merges.absorbed_id is
  'The contact retired by the merge. Absorbed once: a merged contact is not merged again.';
comment on column contact_merges.moved is
  'What moved onto the kept contact, table by table, with the number of rows: every foreign key to contacts, the branches (contacts.parent_id), the files (attachments), the learned motifs moved (contact_patterns) and folded into one the kept contact had (contact_patterns_folded).';
comment on column contact_merges.filled is
  'The fields of the kept contact that were empty and were taken from the absorbed one.';
comment on column contact_merges.merged_by is
  'Who merged: the signed-in user, or the person who issued the machine key presented (acting_user()); null for the installer.';
comment on column contact_merges.transaction_id is
  'The transaction that merged, the only one in which the guards honour this row.';

create unique index contact_merges_absorbed_idx on contact_merges (absorbed_id, company_id);
create index contact_merges_kept_idx on contact_merges (kept_id, company_id);
create index contact_merges_company_idx on contact_merges (company_id, merged_at);
create index contact_merges_transaction_idx on contact_merges (transaction_id);

alter table contact_merges enable row level security;

create policy contact_merges_select on contact_merges
  for select using (company_id = any ((select companies_with_capability('contacts.read'))::uuid[]));

comment on policy contact_merges_select on contact_merges is
  'Whoever reads the contacts of a company reads which of them were merged. Nobody writes here but merge_contacts(), so there is no other policy.';

grant select on table contact_merges to authenticated, service_role;

-- A company leaves with the record, after the contacts it names.
insert into company_archive_registry (table_name, disposition, load_order, via_column, via_table, reason) values
  ('contact_merges', 'exported', 41, null, null, null)
on conflict (table_schema, table_name) do nothing;

-- ---------------------------------------------------------------------------
-- 2. A merged contact stays retired
-- ---------------------------------------------------------------------------

create or replace function contacts_guard_merged()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_into text;
begin
  if tg_op = 'INSERT' then
    if new.merged_into is not null then
      raise exception 'contact_merged_by_merge_contacts: a contact is merged by merge_contacts(), which moves its history first, and is never created merged.'
        using errcode = '55006';
    end if;
    return new;
  end if;

  if tg_op = 'DELETE' then
    if old.merged_into is null
       or not exists (select 1 from companies c where c.id = old.company_id) then
      return old;
    end if;
    select k.name into v_into from contacts k
     where k.id = old.merged_into and k.company_id = old.company_id;
    raise exception 'contact_merged: % was merged into % and stays, retired: the trail and the archives taken before the merge name it.',
      old.name, coalesce(v_into, old.merged_into::text)
      using errcode = '55006';
  end if;

  if new.merged_into is not distinct from old.merged_into
     and (old.merged_into is null or not new.active) then
    return new;
  end if;

  -- Merged, or following the contact it was merged into when that one is
  -- merged in its turn: in the transaction merge_contacts() recorded it.
  if new.merged_into is not null and not new.active
     and exists (select 1 from contact_merges m
                  where m.company_id = old.company_id
                    and m.absorbed_id = coalesce(old.merged_into, old.id)
                    and m.kept_id = new.merged_into
                    and m.transaction_id = txid_current()) then
    return new;
  end if;

  if old.merged_into is null then
    raise exception 'contact_merged_by_merge_contacts: a contact is merged by merge_contacts(), which moves its history onto the contact it is merged into first.'
      using errcode = '55006';
  end if;
  select k.name into v_into from contacts k
   where k.id = old.merged_into and k.company_id = old.company_id;
  raise exception 'contact_merged: % was merged into % and stays retired: it is not made active again, and is not merged anywhere else.',
    old.name, coalesce(v_into, old.merged_into::text)
    using errcode = '55006';
end;
$$;

comment on function contacts_guard_merged() is
  'Keeps a merged contact retired (decision 0074): merged_into is written by merge_contacts() alone, in the transaction that recorded the merge in contact_merges (contact_merged_by_merge_contacts otherwise, and on an insert that arrives merged); once written it changes only to follow the contact it names when that one is merged in its turn, the contact is not made active again and is not deleted while its company stands (contact_merged).';

create trigger contacts_guard_merged
  before insert or update or delete on contacts
  for each row execute function contacts_guard_merged();

revoke execute on function contacts_guard_merged() from public, anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 3. An absorbed contact is named no more
-- ---------------------------------------------------------------------------

create or replace function refuse_merged_contact()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_id      uuid := (to_jsonb(new) ->> tg_argv[0])::uuid;
  v_company uuid := (to_jsonb(new) ->> 'company_id')::uuid;
  v_name    text;
  v_into    uuid;
  v_kept    text;
begin
  if v_id is null
     or (tg_op = 'UPDATE' and v_id is not distinct from (to_jsonb(old) ->> tg_argv[0])::uuid) then
    return new;
  end if;

  -- Looked for in the row's own company: a contact of another one is the
  -- foreign key's to refuse, and this says nothing of it.
  select c.name, c.merged_into, k.name into v_name, v_into, v_kept
    from contacts c
    left join contacts k on k.id = c.merged_into and k.company_id = c.company_id
   where c.id = v_id and c.company_id = v_company and c.merged_into is not null;

  if found then
    raise exception 'contact_merged: % was merged into % (%), which holds its history now, and is named by no row again. Name that one.',
      v_name, coalesce(v_kept, v_into::text), v_into
      using errcode = '55006';
  end if;
  return new;
end;
$$;

comment on function refuse_merged_contact() is
  'Trigger, its argument the column that names a contact: refuses contact_merged on a row written or moved to name a contact that merge_contacts() retired, with the contact that holds its history now (decision 0074). Attached to every table referencing contacts by refuse_merged_contacts_in().';

revoke execute on function refuse_merged_contact() from public, anon, authenticated, service_role;

create or replace function refuse_merged_contacts_in(p_schema text)
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  r      record;
  v_name text;
  v_done integer := 0;
begin
  for r in
    select c.conrelid::regclass as tbl, cl.relname, a.attname
      from pg_constraint c
      join pg_class cl on cl.oid = c.conrelid
      join pg_namespace n on n.oid = cl.relnamespace
      join unnest(c.conkey) as k(attnum) on true
      join pg_attribute a on a.attrelid = c.conrelid and a.attnum = k.attnum
     where c.contype = 'f'
       and c.confrelid = 'public.contacts'::regclass
       and n.nspname = p_schema
       and a.attname <> 'company_id'
     order by cl.relname, a.attname
  loop
    v_name := left(format('%s_%s_not_merged', r.relname, r.attname), 63);
    execute format('drop trigger if exists %I on %s', v_name, r.tbl);
    execute format(
      'create trigger %I before insert or update of %I on %s for each row execute function public.refuse_merged_contact(%L)',
      v_name, r.attname, r.tbl, r.attname);
    v_done := v_done + 1;
  end loop;
  return v_done;
end;
$$;

comment on function refuse_merged_contacts_in(text) is
  'Attaches refuse_merged_contact() to every column of a schema that references contacts, read from the foreign keys, so that no row names a merged contact (decision 0074). Returns how many it attached. For migrations, the socle''s and the modules''; executable by nobody else.';

revoke execute on function refuse_merged_contacts_in(text) from public, anon, authenticated, service_role;

do $$
begin
  perform refuse_merged_contacts_in('public');
end;
$$;

-- ---------------------------------------------------------------------------
-- 4. The guard of a posted line — `20261018180416`, and one more exemption
-- ---------------------------------------------------------------------------

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

  -- The one exemption (decision 0070): the contact of an open third-party
  -- line that names nobody, named once, by set_line_contact() — which raises
  -- the setting with the id of this very line — for a caller who may match.
  -- Everything else of the row is held to the rule above, and the act is
  -- written to the trail here, where it is let through.
  if v_moved = array['contact_id']
     and old.contact_id is null
     and new.contact_id is not null
     and old.matched_amount = 0
     and old.matching_number is null
     and coalesce(current_setting('ekwo.naming_line_contact', true), '') = old.id::text
     and exists (select 1 from accounts a
                  where a.id = old.account_id and a.company_id = old.company_id
                    and a.account_type in ('asset_receivable', 'liability_payable'))
  then
    if not is_installer() and not has_capability(old.company_id, 'reconcile.write') then
      raise exception 'not_allowed: naming the contact of a line in this company needs reconcile.write'
        using errcode = '42501';
    end if;
    perform audit_record(
      old.company_id, 'entry_lines', old.id,
      format('%s/%s', coalesce(v_number, old.entry_id::text), old.sequence),
      'update', 'line_contact_named',
      jsonb_build_object('contact_id', null),
      jsonb_build_object('contact_id', new.contact_id));
    return new;
  end if;

  -- The other exemption (decision 0074): the contact of a posted line, from
  -- the absorbed contact to the kept one, in the transaction where
  -- merge_contacts() recorded that merge — a row nobody else writes. Every
  -- other column is held to the rule above, and the act is written to the
  -- trail here, where it is let through.
  if v_moved = array['contact_id']
     and old.contact_id is not null
     and new.contact_id is not null
     and exists (select 1 from contact_merges m
                  where m.company_id = old.company_id
                    and m.absorbed_id = old.contact_id
                    and m.kept_id = new.contact_id
                    and m.transaction_id = txid_current())
  then
    perform audit_record(
      old.company_id, 'entry_lines', old.id,
      format('%s/%s', coalesce(v_number, old.entry_id::text), old.sequence),
      'update', 'line_contact_merged',
      jsonb_build_object('contact_id', old.contact_id),
      jsonb_build_object('contact_id', new.contact_id));
    return new;
  end if;

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

comment on function entry_lines_guard_posted() is
  'Once an entry has left draft, its lines are the lines that were posted: no insert, no delete, and no column changed but the two the matching writes, matching_number and matched_amount. Refuses entry_posted, by name, to everybody. Two exemptions, contact_id alone each time: from null to a contact, on an unmatched line of a receivable or payable account, under the setting ekwo.naming_line_contact holding that line''s id — raised by set_line_contact() — for a caller holding reconcile.write, written to the trail as line_contact_named (decision 0070); and from the absorbed contact to the kept one, in the transaction in which merge_contacts() recorded that merge in contact_merges, written to the trail as line_contact_merged (decision 0074).';

revoke execute on function entry_lines_guard_posted() from public, anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 5. The guard of an issued document — `20261007113412`, and one exemption
-- ---------------------------------------------------------------------------

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

  -- One exemption (decision 0074): the contact of an issued document, from
  -- the absorbed contact to the kept one, in the transaction where
  -- merge_contacts() recorded that merge — a row nobody else writes. Nothing
  -- else of the row moves with it, and the act is written to the trail here.
  if v_moved = array['contact_id']
     and old.contact_id is not null
     and new.contact_id is not null
     and exists (select 1 from contact_merges m
                  where m.company_id = old.company_id
                    and m.absorbed_id = old.contact_id
                    and m.kept_id = new.contact_id
                    and m.transaction_id = txid_current())
  then
    perform audit_record(
      old.company_id, 'documents', old.id, coalesce(old.number, old.id::text),
      'update', 'document_contact_merged',
      jsonb_build_object('contact_id', old.contact_id),
      jsonb_build_object('contact_id', new.contact_id));
    return new;
  end if;

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

comment on function documents_guard_posted() is
  'Once a document has left draft: it is not deleted, no column moves but the closed list of what happens to a document after it is issued — amount_paid (to the figure the matching gives, and no other), payment_state, sent_at, peppol_status, peppol_message_id — and its state has two ways out: posted to cancelled, taken by cancel_document() and held to a posted credit note of the matching type that names it and settles it in full, for a caller holding documents.post (document_cancelled_by_hand otherwise); and posted to draft, taken by unpost_document(). Refuses document_posted, by name, to everybody. Becoming posted is held to what post_document() writes (document_posted_by_hand otherwise), and nobody inserts a document that is already posted (document_born_posted). One exemption (decision 0074): contact_id alone, from the absorbed contact to the kept one, in the transaction in which merge_contacts() recorded that merge in contact_merges, written to the trail as document_contact_merged.';

revoke execute on function documents_guard_posted() from public, anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 6. merge_contacts
-- ---------------------------------------------------------------------------

create or replace function merge_contacts(p_keep uuid, p_absorb uuid)
returns contact_merges
language plpgsql
volatile
security definer
set search_path = public, pg_temp
as $$
declare
  v_keep     contacts;
  v_absorb   contacts;
  v_new      contacts;
  v_company  uuid;
  v_filled   text[] := '{}';
  v_moved    jsonb := '{}';
  v_folded   integer := 0;
  v_pmoved   integer := 0;
  v_n        integer;
  v_chain    uuid;
  v_depth    integer;
  r          record;
  v_twin     uuid;
  v_bad      record;
  v_merge    uuid;
  v_record   contact_merges;
begin
  -- A contact the caller may not read is a contact that does not exist, here
  -- as under row level security.
  select * into v_keep from contacts c where c.id = p_keep;
  if not found or not (is_installer() or has_capability(v_keep.company_id, 'contacts.read')) then
    raise exception 'unknown_contact: no contact %', p_keep
      using errcode = 'no_data_found';
  end if;
  v_company := v_keep.company_id;

  if not is_installer() and not has_capability(v_company, 'contacts.write') then
    raise exception 'not_allowed: merging two contacts in this company needs contacts.write'
      using errcode = '42501';
  end if;
  if not is_installer() and not has_capability(v_company, 'reconcile.write') then
    raise exception 'not_allowed: merging two contacts in this company needs reconcile.write, since it restates who each of their items belongs to'
      using errcode = '42501';
  end if;

  if p_absorb is not distinct from p_keep then
    raise exception 'same_contact: % is one contact, and a merge joins two', v_keep.name
      using errcode = '22023';
  end if;

  select * into v_absorb from contacts c where c.id = p_absorb and c.company_id = v_company;
  if not found then
    raise exception 'unknown_contact: no contact % in the company of %', p_absorb, v_keep.name
      using errcode = 'no_data_found';
  end if;


  -- Two merges of one contact wait for each other, in one order whoever asks.
  perform 1 from contacts c where c.id in (p_keep, p_absorb) order by c.id for update;
  select * into v_keep from contacts c where c.id = p_keep;
  select * into v_absorb from contacts c where c.id = p_absorb;

  if v_absorb.merged_into is not null then
    raise exception 'already_merged: % was merged into % before, and has nothing left to move',
      v_absorb.name, coalesce((select k.name from contacts k where k.id = v_absorb.merged_into), v_absorb.merged_into::text)
      using errcode = '55006';
  end if;
  if v_keep.merged_into is not null then
    raise exception 'already_merged: % was merged into % (%), which holds its history: merge into that one',
      v_keep.name, coalesce((select k.name from contacts k where k.id = v_keep.merged_into), v_keep.merged_into::text),
      v_keep.merged_into
      using errcode = '55006';
  end if;

  -- Two numbers are two legal persons, whatever their names say; and a
  -- declaration reads the number.
  if upper(regexp_replace(coalesce(v_keep.vat_number, ''), '[^0-9A-Za-z]', '', 'g'))
       <> upper(regexp_replace(coalesce(v_absorb.vat_number, ''), '[^0-9A-Za-z]', '', 'g'))
     and coalesce(btrim(v_keep.vat_number), '') <> ''
     and coalesce(btrim(v_absorb.vat_number), '') <> '' then
    raise exception 'different_identifiers: % carries the VAT number % and % carries %: two numbers are two parties, and are not merged',
      v_keep.name, v_keep.vat_number, v_absorb.name, v_absorb.vat_number
      using errcode = '55006';
  end if;
  if upper(regexp_replace(coalesce(v_keep.registration_number, ''), '[^0-9A-Za-z]', '', 'g'))
       <> upper(regexp_replace(coalesce(v_absorb.registration_number, ''), '[^0-9A-Za-z]', '', 'g'))
     and coalesce(btrim(v_keep.registration_number), '') <> ''
     and coalesce(btrim(v_absorb.registration_number), '') <> '' then
    raise exception 'different_identifiers: % carries the registration number % and % carries %: two numbers are two parties, and are not merged',
      v_keep.name, v_keep.registration_number, v_absorb.name, v_absorb.registration_number
      using errcode = '55006';
  end if;

  -- -------------------------------------------------------------------------
  -- The kept contact, completed and never overwritten
  -- -------------------------------------------------------------------------
  v_new := v_keep;

  if coalesce(btrim(v_new.vat_number), '') = '' and coalesce(btrim(v_absorb.vat_number), '') <> '' then
    v_new.vat_number := v_absorb.vat_number; v_filled := v_filled || 'vat_number'::text;
  end if;
  if coalesce(btrim(v_new.registration_number), '') = '' and coalesce(btrim(v_absorb.registration_number), '') <> '' then
    v_new.registration_number := v_absorb.registration_number; v_filled := v_filled || 'registration_number'::text;
  end if;
  if coalesce(btrim(v_new.auxiliary_code), '') = '' and coalesce(btrim(v_absorb.auxiliary_code), '') <> '' then
    v_new.auxiliary_code := v_absorb.auxiliary_code; v_filled := v_filled || 'auxiliary_code'::text;
  end if;
  if coalesce(btrim(v_new.email), '') = '' and coalesce(btrim(v_absorb.email), '') <> '' then
    v_new.email := v_absorb.email; v_filled := v_filled || 'email'::text;
  end if;
  if coalesce(btrim(v_new.phone), '') = '' and coalesce(btrim(v_absorb.phone), '') <> '' then
    v_new.phone := v_absorb.phone; v_filled := v_filled || 'phone'::text;
  end if;
  if v_new.language is null and v_absorb.language is not null then
    v_new.language := v_absorb.language; v_filled := v_filled || 'language'::text;
  end if;
  if v_new.currency_code is null and v_absorb.currency_code is not null then
    v_new.currency_code := v_absorb.currency_code; v_filled := v_filled || 'currency_code'::text;
  end if;
  if v_new.receivable_account_id is null and v_absorb.receivable_account_id is not null then
    v_new.receivable_account_id := v_absorb.receivable_account_id; v_filled := v_filled || 'receivable_account_id'::text;
  end if;
  if v_new.payable_account_id is null and v_absorb.payable_account_id is not null then
    v_new.payable_account_id := v_absorb.payable_account_id; v_filled := v_filled || 'payable_account_id'::text;
  end if;
  if coalesce(btrim(v_new.notes), '') = '' and coalesce(btrim(v_absorb.notes), '') <> '' then
    v_new.notes := v_absorb.notes; v_filled := v_filled || 'notes'::text;
  end if;

  -- The postal address is one fact: taken whole, where the kept contact has
  -- none, and not from another country than the one it already names.
  if coalesce(btrim(v_new.address_line1), '') = '' and coalesce(btrim(v_new.address_line2), '') = ''
     and coalesce(btrim(v_new.postal_code), '') = '' and coalesce(btrim(v_new.city), '') = ''
     and coalesce(btrim(v_new.region), '') = ''
     and (coalesce(btrim(v_absorb.address_line1), '') <> '' or coalesce(btrim(v_absorb.city), '') <> ''
          or coalesce(btrim(v_absorb.postal_code), '') <> '')
     and (v_new.country is null or v_absorb.country is null or v_new.country = v_absorb.country) then
    v_new.address_line1 := v_absorb.address_line1;
    v_new.address_line2 := v_absorb.address_line2;
    v_new.postal_code   := v_absorb.postal_code;
    v_new.city          := v_absorb.city;
    v_new.region        := v_absorb.region;
    v_filled := v_filled || array['address_line1', 'address_line2', 'postal_code', 'city', 'region'];
  end if;
  if v_new.country is null and v_absorb.country is not null then
    v_new.country := v_absorb.country;
    v_new.territory_code := coalesce(v_new.territory_code, v_absorb.territory_code);
    v_filled := v_filled || array['country', 'territory_code'];
  end if;

  -- A bank account and its BIC, an electronic address and its scheme: the
  -- one without the other is somebody else's.
  if coalesce(btrim(v_new.iban), '') = '' and coalesce(btrim(v_absorb.iban), '') <> '' then
    v_new.iban := v_absorb.iban;
    v_new.bic  := v_absorb.bic;
    v_filled := v_filled || array['iban', 'bic'];
  end if;
  if coalesce(btrim(v_new.peppol_identifier), '') = '' and coalesce(btrim(v_absorb.peppol_identifier), '') <> '' then
    v_new.peppol_scheme     := v_absorb.peppol_scheme;
    v_new.peppol_identifier := v_absorb.peppol_identifier;
    v_filled := v_filled || array['peppol_scheme', 'peppol_identifier'];
  end if;

  -- A customer who is also a supplier is both; a contact nobody typed takes
  -- the type of the one it absorbs.
  if v_new.contact_type = 'other' and v_absorb.contact_type <> 'other' then
    v_new.contact_type := v_absorb.contact_type; v_filled := v_filled || 'contact_type'::text;
  elsif v_new.contact_type in ('customer', 'supplier')
        and v_absorb.contact_type in ('customer', 'supplier', 'both')
        and v_absorb.contact_type <> v_new.contact_type then
    v_new.contact_type := 'both'; v_filled := v_filled || 'contact_type'::text;
  end if;

  -- The parent. A branch of the absorbed contact that is the kept one goes up
  -- to the absorbed contact's own parent; a kept contact with no parent takes
  -- the absorbed one's, unless that parent is below the kept contact.
  if v_new.parent_id = p_absorb then
    v_new.parent_id := v_absorb.parent_id;
  end if;
  if v_new.parent_id is null and v_absorb.parent_id is not null and v_absorb.parent_id <> p_keep then
    v_chain := v_absorb.parent_id;
    v_depth := 0;
    while v_chain is not null and v_chain <> p_keep and v_depth <= 32 loop
      select c.parent_id into v_chain from contacts c where c.id = v_chain and c.company_id = v_company;
      v_depth := v_depth + 1;
    end loop;
    if v_chain is null then
      v_new.parent_id := v_absorb.parent_id; v_filled := v_filled || 'parent_id'::text;
    end if;
  end if;

  -- An auxiliary code is unique in the company: the absorbed contact gives
  -- its own up before the kept one takes it.
  if 'auxiliary_code' = any (v_filled) then
    update contacts c set auxiliary_code = null where c.id = p_absorb;
  end if;

  update contacts c
     set vat_number            = v_new.vat_number,
         registration_number   = v_new.registration_number,
         auxiliary_code        = v_new.auxiliary_code,
         email                 = v_new.email,
         phone                 = v_new.phone,
         language              = v_new.language,
         currency_code         = v_new.currency_code,
         receivable_account_id = v_new.receivable_account_id,
         payable_account_id    = v_new.payable_account_id,
         notes                 = v_new.notes,
         address_line1         = v_new.address_line1,
         address_line2         = v_new.address_line2,
         postal_code           = v_new.postal_code,
         city                  = v_new.city,
         region                = v_new.region,
         country               = v_new.country,
         territory_code        = v_new.territory_code,
         iban                  = v_new.iban,
         bic                   = v_new.bic,
         peppol_scheme         = v_new.peppol_scheme,
         peppol_identifier     = v_new.peppol_identifier,
         contact_type          = v_new.contact_type,
         parent_id             = v_new.parent_id
   where c.id = p_keep
     and (v_filled <> '{}' or c.parent_id is distinct from v_new.parent_id);

  -- -------------------------------------------------------------------------
  -- Every reference, read from the catalogue
  -- -------------------------------------------------------------------------
  -- The record the guards read: in this transaction, and only for these two.
  insert into contact_merges (company_id, kept_id, absorbed_id, merged_by)
  values (v_company, p_keep, p_absorb, acting_user())
  returning id into v_merge;

  for r in
    select c.conrelid::regclass as tbl, a.attname
      from pg_constraint c
      join unnest(c.conkey) as k(attnum) on true
      join pg_attribute a on a.attrelid = c.conrelid and a.attnum = k.attnum
     where c.contype = 'f'
       and c.confrelid = 'public.contacts'::regclass
       and a.attname <> 'company_id'
       -- By name, below: the contacts themselves and the learned motifs; and
       -- the record of the merges, which says what happened and stays.
       and c.conrelid not in ('public.contacts'::regclass, 'public.contact_patterns'::regclass,
                              'public.contact_merges'::regclass)
     order by c.conrelid::regclass::text, a.attname
  loop
    execute format('update %s set %I = $1 where %I = $2 and company_id = $3', r.tbl, r.attname, r.attname)
      using p_keep, p_absorb, v_company;
    get diagnostics v_n = row_count;
    if v_n > 0 then
      v_moved := v_moved || jsonb_build_object(
        case when r.attname = 'contact_id' then r.tbl::text else r.tbl::text || '.' || r.attname end, v_n);
    end if;
  end loop;

  -- The branches of the absorbed contact are branches of the kept one.
  update contacts c set parent_id = p_keep
   where c.company_id = v_company and c.parent_id = p_absorb and c.id <> p_keep;
  get diagnostics v_n = row_count;
  if v_n > 0 then
    v_moved := v_moved || jsonb_build_object('contacts.parent_id', v_n);
  end if;

  -- The files attached to the contact, which name it by entity, not by key.
  update attachments a set entity_id = p_keep
   where a.company_id = v_company and a.entity_type = 'contact' and a.entity_id = p_absorb;
  get diagnostics v_n = row_count;
  if v_n > 0 then
    v_moved := v_moved || jsonb_build_object('attachments', v_n);
  end if;

  -- The learned motifs, folded: one motif the two had is one motif with both
  -- histories, and its confidence is what the two counters say together.
  for r in
    select * from contact_patterns p
     where p.company_id = v_company and p.contact_id = p_absorb
     order by p.created_at, p.id
  loop
    select t.id into v_twin
      from contact_patterns t
     where t.company_id = v_company and t.contact_id = p_keep and t.kind = r.kind
       and ((r.value is not null and t.value = r.value)
            or (r.value is null and t.value is null
                and t.amount_min = r.amount_min and t.amount_max = r.amount_max
                and t.currency_code = r.currency_code))
     for update;
    if found then
      update contact_patterns t
         set usage_count     = t.usage_count + r.usage_count,
             success_count   = t.success_count + r.success_count,
             confidence      = (t.success_count + r.success_count + 1)::numeric
                               / (t.usage_count + r.usage_count + 2),
             last_matched_at = greatest(t.last_matched_at, r.last_matched_at),
             amount_typical  = coalesce(t.amount_typical, r.amount_typical),
             exclude_words   = case when t.exclude_words is null and r.exclude_words is null then null
                                    else array(select distinct w
                                                 from unnest(coalesce(t.exclude_words, '{}') || coalesce(r.exclude_words, '{}')) w
                                                order by w) end,
             -- A motif somebody wrote down is an instruction, whoever learned it too.
             source          = case when 'declared' in (t.source, r.source) then 'declared' else 'learned' end::contact_pattern_source,
             active          = t.active or r.active
       where t.id = v_twin;
      delete from contact_patterns p where p.id = r.id;
      v_folded := v_folded + 1;
    else
      update contact_patterns p set contact_id = p_keep where p.id = r.id;
      v_pmoved := v_pmoved + 1;
    end if;
  end loop;
  if v_pmoved > 0 then
    v_moved := v_moved || jsonb_build_object('contact_patterns', v_pmoved);
  end if;
  if v_folded > 0 then
    v_moved := v_moved || jsonb_build_object('contact_patterns_folded', v_folded);
  end if;

  -- -------------------------------------------------------------------------
  -- The absorbed contact, retired
  -- -------------------------------------------------------------------------
  update contacts c set active = false, merged_into = p_keep where c.id = p_absorb;

  -- A contact merged into the absorbed one before follows it, so that
  -- merged_into always names a contact in use.
  update contacts c set merged_into = p_keep
   where c.company_id = v_company and c.merged_into = p_absorb;
  get diagnostics v_n = row_count;
  if v_n > 0 then
    v_moved := v_moved || jsonb_build_object('contacts.merged_into', v_n);
  end if;

  -- Every matching of the kept party's items is still of one party: both
  -- lines in its tree, or one of them naming nobody.
  with recursive party(id) as (
    select commercial_entity(p_keep)
    union
    select c.id from contacts c join party p on c.parent_id = p.id where c.company_id = v_company
  )
  select rc.matching_number, d.id as debit_id, k.id as credit_id,
         case when d.contact_id in (select id from party) then k.contact_id else d.contact_id end as other
    into v_bad
    from reconciliations rc
    join entry_lines d on d.id = rc.debit_line_id and d.company_id = rc.company_id
    join entry_lines k on k.id = rc.credit_line_id and k.company_id = rc.company_id
   where rc.company_id = v_company
     and d.contact_id is not null and k.contact_id is not null
     and (d.contact_id in (select id from party)) <> (k.contact_id in (select id from party))
   limit 1;
  if found then
    raise exception 'matching_across_parties: once % is merged into %, matching % would settle lines % and % of two parties — % is not of %''s party. Undo that matching first, with unreconcile(), or give the two contacts one parent.',
      v_absorb.name, v_keep.name, coalesce(v_bad.matching_number, '?'), v_bad.debit_id, v_bad.credit_id,
      coalesce((select c.name from contacts c where c.id = v_bad.other), v_bad.other::text), v_keep.name
      using errcode = '55006';
  end if;

  select * into v_keep from contacts c where c.id = p_keep;
  select * into v_absorb from contacts c where c.id = p_absorb;

  update contact_merges m set moved = v_moved, filled = v_filled where m.id = v_merge
  returning * into v_record;

  perform audit_record(
    v_company, 'contacts', p_absorb, v_absorb.name,
    'update', 'contacts_merged',
    jsonb_build_object('merged_into', null),
    jsonb_build_object('merged_into', p_keep, 'kept', v_keep.name, 'moved', v_moved, 'filled', to_jsonb(v_filled)));

  return v_record;
end;
$$;

comment on function merge_contacts(uuid, uuid) is
  'Merges two contacts of one company (decision 0074): every reference of p_absorb — every foreign key to contacts, read from the catalogue, posted lines and issued documents included, the branches whose parent it was, the files attached to it — moves onto p_keep in one transaction; its learned motifs are folded into the kept contact''s; the kept contact''s empty fields are filled from the absorbed one, never overwritten; and the absorbed contact is retired, inactive with merged_into = p_keep, never deleted. Needs contacts.write and reconcile.write. Refuses unknown_contact, same_contact, already_merged, different_identifiers (two VAT or registration numbers), matching_across_parties and not_allowed by name. Recorded in contact_merges, which the two guards of what was posted read in this transaction alone, and written to the trail as contacts_merged, with line_contact_merged and document_contact_merged for each posted row moved. Answers the row of contact_merges: the two contacts, who merged them, what moved, table by table, and what was filled.';

revoke execute on function merge_contacts(uuid, uuid) from public, anon;
grant execute on function merge_contacts(uuid, uuid) to authenticated, service_role;
