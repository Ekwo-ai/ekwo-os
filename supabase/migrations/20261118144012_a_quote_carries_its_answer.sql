-- Ekwo OS — a quote carries its answer, as dated facts.
--
-- A `sale_quote` and a `purchase_order` are documents that are never booked:
-- `post_document()` refuses them (`document_not_accountable`). What happens to
-- one is that it is sent, and that the other party accepts it or declines
-- it. `sent_at` already said the first; nothing said the second, so a company
-- that issues quotes could not tell an accepted one from a draft.
--
-- **Facts, not a status.** Three columns, each a fact somebody records:
-- `accepted_at` and `declined_at`, when the other party answered, and
-- `accepted_by`, who accepted, in the words of whoever recorded it. Never both
-- dates at once, and only on the two kinds of document an answer is given
-- to — checks of the table, so no path writes anything else. `due_date` stays
-- what it is on a quote: the day it is valid until. Nothing is written to the
-- ledger.
--
-- **The status is read, never stored.** `quote_status(document)` derives it
-- from the facts, and every reader asks it — `quote_statuses()` for a list of
-- documents, the `crm` module for the documents of a deal, PostgREST as a
-- computed field: `draft`, then `sent` once `sent_at` is set, `accepted` or
-- `declined` once answered; `expired` when it is neither accepted nor declined
-- and its `due_date` has passed; `cancelled` stays the document's state. Null
-- for a document no answer is given to. One function, so no screen works the
-- rule out again.
--
-- **One function per fact.** `accept_document()`, `decline_document()` and
-- `undo_document_answer()` write them, check what can be refused by name, and
-- record the act on the audit trail. They are `security definer`, as
-- `approve_document()` is, because the trail is written by the schema and by
-- nobody else; they ask what the policy of `documents` would — `documents.read`
-- to see the document at all, `documents.write` to change it, the right that
-- writes a draft, which a quote always is.
--
-- **An agent answers in the mode its company chose.** The rule that holds an
-- agent's posting (decision 0089) holds its answer too, on the same trigger:
-- `documents_posting_mode` now also fires when `accepted_at` or `declined_at`
-- moves. In autopilot the agent records the answer; in review it needs the
-- approval of a person of the document as it stands (`approve_document()`),
-- `approval_required` otherwise; in a `review_only` company a session in
-- autopilot is refused, `autopilot_forbidden`. Every answer by an agent writes
-- `document_answered_by_agent` on the trail, as a posting writes
-- `document_posted_by_agent`. One rule, one trigger, never a second path.
--
-- **The socle knows no module.** What an answer means for a deal is the
-- `crm` module's business, in its own schema; this file says nothing of it.

-- ---------------------------------------------------------------------------
-- 1. The facts
-- ---------------------------------------------------------------------------

alter table ekwo.documents
  add column if not exists accepted_at timestamptz,
  add column if not exists accepted_by text,
  add column if not exists declined_at timestamptz;

alter table ekwo.documents
  drop constraint if exists documents_answered_once;
alter table ekwo.documents
  add constraint documents_answered_once
  check (accepted_at is null or declined_at is null);

alter table ekwo.documents
  drop constraint if exists documents_answer_of_an_offer;
alter table ekwo.documents
  add constraint documents_answer_of_an_offer
  check ((accepted_at is null and declined_at is null and accepted_by is null)
         or doc_type in ('sale_quote', 'purchase_order'));

alter table ekwo.documents
  drop constraint if exists documents_accepted_by_on_acceptance;
alter table ekwo.documents
  add constraint documents_accepted_by_on_acceptance
  check (accepted_by is null or (accepted_at is not null and char_length(btrim(accepted_by)) between 1 and 200));

comment on column ekwo.documents.accepted_at is
  'When the other party accepted this quote or order. Written by accept_document(), cleared by undo_document_answer(); never set together with declined_at, and only on a sale_quote or a purchase_order. Nothing is booked.';
comment on column ekwo.documents.accepted_by is
  'Who accepted it, in the words of whoever recorded it: a name, a role, a reference to a signed copy. Free text, set only with accepted_at.';
comment on column ekwo.documents.declined_at is
  'When the other party declined this quote or order. Written by decline_document(), cleared by undo_document_answer(); never set together with accepted_at, and only on a sale_quote or a purchase_order.';

-- ---------------------------------------------------------------------------
-- 2. The status, derived
-- ---------------------------------------------------------------------------

create or replace function ekwo.quote_status(p_document ekwo.documents)
returns text
language sql
stable
as $$
  select case
           when p_document.doc_type not in ('sale_quote', 'purchase_order') then null
           when p_document.state = 'cancelled' then 'cancelled'
           when p_document.accepted_at is not null then 'accepted'
           when p_document.declined_at is not null then 'declined'
           when p_document.due_date < current_date then 'expired'
           when p_document.sent_at is not null then 'sent'
           else 'draft'
         end;
$$;

comment on function ekwo.quote_status(ekwo.documents) is
  'The status of a quote or an order, derived from its facts and stored nowhere: cancelled when the document is; accepted (accepted_at) or declined (declined_at) once the other party answered; expired when it is neither and its due_date, the day it is valid until, has passed; sent once sent_at is set; draft otherwise. Null for a document no answer is given to. The one source every reader asks — quote_statuses(), the crm module, PostgREST as the computed field quote_status.';

create or replace function ekwo.quote_statuses(p_document_ids uuid[])
returns table (document_id uuid, quote_status text)
language sql
stable
security invoker
set search_path = ekwo, pg_temp
as $$
  select d.id, ekwo.quote_status(d)
    from ekwo.documents d
   where d.id = any (p_document_ids)
     and d.doc_type in ('sale_quote', 'purchase_order');
$$;

comment on function ekwo.quote_statuses(uuid[]) is
  'quote_status() of each quote and order among the documents named, one row each; a document of another kind, or one the caller cannot read, is absent. What a client reads beside a list of documents, so the status is worked out once, here. Security invoker.';

-- ---------------------------------------------------------------------------
-- 3. The three facts, one function each
-- ---------------------------------------------------------------------------

-- The document an answer is recorded on, or the refusal by name.
create or replace function ekwo.document_to_answer(p_document_id uuid)
returns ekwo.documents
language plpgsql
stable
security invoker
set search_path = ekwo, pg_temp
as $$
declare
  v_doc ekwo.documents%rowtype;
begin
  select * into v_doc from ekwo.documents d where d.id = p_document_id;
  if v_doc.id is null
     or not (is_installer() or has_capability(v_doc.company_id, 'documents.read')) then
    raise exception 'unknown_document: no document % in the companies you can see', p_document_id
      using errcode = 'P0002';
  end if;
  if not is_installer() and not has_capability(v_doc.company_id, 'documents.write') then
    raise exception 'not_allowed: recording the answer to a document needs documents.write'
      using errcode = '42501';
  end if;
  if v_doc.doc_type not in ('sale_quote', 'purchase_order') then
    raise exception 'document_not_answerable: a % is not accepted or declined; an answer is recorded on a sale_quote or a purchase_order', v_doc.doc_type
      using errcode = '22023';
  end if;
  if v_doc.state = 'cancelled' then
    raise exception 'document_cancelled: % % is cancelled, and a cancelled document is answered no more', v_doc.doc_type, coalesce(v_doc.number, v_doc.id::text)
      using errcode = '55006';
  end if;
  return v_doc;
end;
$$;

comment on function ekwo.document_to_answer(uuid) is
  'The document an answer is recorded on, or the refusal by name: unknown_document (absent, or outside the companies where the caller holds documents.read), not_allowed (documents.write), document_not_answerable (neither a sale_quote nor a purchase_order), document_cancelled. The first lines of accept_document(), decline_document() and undo_document_answer().';

create or replace function ekwo.accept_document(
  p_document_id uuid,
  p_accepted_by text default null,
  p_at          timestamptz default null
)
returns ekwo.documents
language plpgsql
security definer
set search_path = ekwo, pg_temp
as $$
declare
  v_doc ekwo.documents%rowtype := ekwo.document_to_answer(p_document_id);
  v_new ekwo.documents%rowtype;
begin
  if v_doc.declined_at is not null then
    raise exception 'document_already_answered: % % was declined on %. Undo that answer first (undo_document_answer(), ekwo doc answer undo).',
      v_doc.doc_type, coalesce(v_doc.number, v_doc.id::text), v_doc.declined_at::date
      using errcode = '55006';
  end if;
  if v_doc.accepted_at is not null then
    -- Recorded already: the same call twice records it once.
    return v_doc;
  end if;
  if p_at is not null and p_at > now() then
    raise exception 'answer_in_the_future: an answer is recorded once it is given, and % has not come yet', p_at
      using errcode = '22023';
  end if;

  update ekwo.documents d
     set accepted_at = coalesce(p_at, now()),
         accepted_by = nullif(btrim(p_accepted_by), '')
   where d.id = v_doc.id
  returning * into v_new;

  perform audit_record(
    v_new.company_id, 'documents', v_new.id, coalesce(v_new.number, v_new.id::text),
    'update', 'document_accepted', null,
    jsonb_strip_nulls(jsonb_build_object('accepted_at', v_new.accepted_at, 'accepted_by', v_new.accepted_by)));
  return v_new;
end;
$$;

comment on function ekwo.accept_document(uuid, text, timestamptz) is
  'Records that the other party accepted a sale_quote or a purchase_order: accepted_at (p_at, now when not given, never in the future) and accepted_by (free text). The same call on an accepted document returns it as it is; a declined one is refused, document_already_answered — undo_document_answer() first. Writes document_accepted on the audit trail; books nothing. Needs documents.write; an agent records it in the mode of its company, as it posts (documents_posting_mode).';

create or replace function ekwo.decline_document(
  p_document_id uuid,
  p_at          timestamptz default null
)
returns ekwo.documents
language plpgsql
security definer
set search_path = ekwo, pg_temp
as $$
declare
  v_doc ekwo.documents%rowtype := ekwo.document_to_answer(p_document_id);
  v_new ekwo.documents%rowtype;
begin
  if v_doc.accepted_at is not null then
    raise exception 'document_already_answered: % % was accepted on %. Undo that answer first (undo_document_answer(), ekwo doc answer undo).',
      v_doc.doc_type, coalesce(v_doc.number, v_doc.id::text), v_doc.accepted_at::date
      using errcode = '55006';
  end if;
  if v_doc.declined_at is not null then
    return v_doc;
  end if;
  if p_at is not null and p_at > now() then
    raise exception 'answer_in_the_future: an answer is recorded once it is given, and % has not come yet', p_at
      using errcode = '22023';
  end if;

  update ekwo.documents d
     set declined_at = coalesce(p_at, now())
   where d.id = v_doc.id
  returning * into v_new;

  perform audit_record(
    v_new.company_id, 'documents', v_new.id, coalesce(v_new.number, v_new.id::text),
    'update', 'document_declined', null,
    jsonb_build_object('declined_at', v_new.declined_at));
  return v_new;
end;
$$;

comment on function ekwo.decline_document(uuid, timestamptz) is
  'Records that the other party declined a sale_quote or a purchase_order: declined_at (p_at, now when not given, never in the future). The same call on a declined document returns it as it is; an accepted one is refused, document_already_answered — undo_document_answer() first. Writes document_declined on the audit trail; books nothing. Needs documents.write; an agent records it in the mode of its company, as it posts (documents_posting_mode).';

create or replace function ekwo.undo_document_answer(p_document_id uuid)
returns ekwo.documents
language plpgsql
security definer
set search_path = ekwo, pg_temp
as $$
declare
  v_doc ekwo.documents%rowtype := ekwo.document_to_answer(p_document_id);
  v_new ekwo.documents%rowtype;
begin
  if v_doc.accepted_at is null and v_doc.declined_at is null then
    raise exception 'document_not_answered: % % carries no answer to undo', v_doc.doc_type, coalesce(v_doc.number, v_doc.id::text)
      using errcode = '55006';
  end if;

  update ekwo.documents d
     set accepted_at = null,
         accepted_by = null,
         declined_at = null
   where d.id = v_doc.id
  returning * into v_new;

  perform audit_record(
    v_new.company_id, 'documents', v_new.id, coalesce(v_new.number, v_new.id::text),
    'update', 'document_answer_undone',
    jsonb_strip_nulls(jsonb_build_object('accepted_at', v_doc.accepted_at, 'accepted_by', v_doc.accepted_by,
                                         'declined_at', v_doc.declined_at)),
    null);
  return v_new;
end;
$$;

comment on function ekwo.undo_document_answer(uuid) is
  'Takes back the answer recorded on a sale_quote or a purchase_order — accepted_at, accepted_by, declined_at back to null — and writes document_answer_undone on the audit trail with what it was. Refuses a document with no answer, document_not_answered. Needs documents.write; an agent undoes it in the mode of its company, as it posts (documents_posting_mode).';

-- ---------------------------------------------------------------------------
-- 4. An agent answers in the mode its company chose: the posting's rule
--
-- `20261023174709` as it was, holding one more act. The trigger fires on the
-- posting of a draft, as before, and now on a change of accepted_at or
-- declined_at; the mode, the approval of the document as it stands and the
-- record on the trail are the same, and only the words say which act it is.
-- ---------------------------------------------------------------------------

create or replace function ekwo.documents_posting_mode()
returns trigger
language plpgsql
security definer
set search_path = ekwo, pg_temp
as $$
declare
  v_posting  boolean := new.state = 'posted' and old.state = 'draft';
  v_mode     text;
  v_version  text;
  v_approval ekwo.audit_log%rowtype;
begin
  if not agent_call() or coalesce(current_setting('ekwo.rehearsal', true), '') = 'on' then
    return new;
  end if;

  v_mode := agent_posting_mode(new.company_id);

  if v_mode = 'autopilot_forbidden' then
    raise exception 'autopilot_forbidden: this company''s agent_posting is review_only, so no session and no key posts in autopilot. Start the session in review (without --autopilot, or with the mark X-Ekwo-Agent: review), or use a key issued in review, and a person approves each draft (approve_document(), ekwo doc approve).'
      using errcode = '42501';
  end if;

  if v_mode is distinct from 'autopilot' then
    -- A trigger before the update reads the row as it still stands, so this
    -- is the version of the draft that is being posted or answered.
    v_version := document_version(old.id);

    select a.* into v_approval
      from ekwo.audit_log a
     where a.table_name = 'documents'
       and a.record_id = new.id
       and a.action = 'document_approved'
       and a.api_key_id is null
       and a.new_values ->> 'version' = v_version
       and a.id > coalesce((select max(b.id) from ekwo.audit_log b
                             where b.table_name = 'documents'
                               and b.record_id = new.id
                               and b.action = 'document_draft'), 0)
     order by a.id desc
     limit 1;

    if v_approval.id is null then
      if v_posting then
        raise exception 'approval_required: % % has not been approved by a person as it stands, and agents post in review here. A person who may post it approves it (approve_document(), ekwo doc approve), or posts it; a draft changed after its approval is approved again.',
          new.doc_type, coalesce(new.number, new.id::text)
          using errcode = '42501';
      end if;
      raise exception 'approval_required: % % has not been approved by a person as it stands, and agents record an answer in review here. A person who may post it approves it (approve_document(), ekwo doc approve), or records the answer; a document changed after its approval is approved again.',
        new.doc_type, coalesce(new.number, new.id::text)
        using errcode = '42501';
    end if;
  end if;

  perform audit_record(
    new.company_id, 'documents', new.id, coalesce(new.number, new.id::text),
    'update', case when v_posting then 'document_posted_by_agent' else 'document_answered_by_agent' end, null,
    jsonb_strip_nulls(jsonb_build_object(
      'posting_mode', v_mode,
      'agent_posting', (select c.agent_posting from ekwo.companies c where c.id = new.company_id),
      'session', agent_mark('agent_session'),
      'version', v_version,
      'approved_by', v_approval.actor_id,
      'approved_at', v_approval.occurred_at,
      'accepted_at', case when v_posting then null else new.accepted_at end,
      'declined_at', case when v_posting then null else new.declined_at end)));
  return new;
end;
$$;

comment on function ekwo.documents_posting_mode() is
  'Holds an agent''s posting of a document, and its answer to a quote or an order (accepted_at, declined_at), to agent_posting_mode(): autopilot_forbidden when the key or the session is in autopilot in a company that is review_only; in review, approval_required unless a person approved the document as it stood (approve_document()) since it last went back to draft. Every posting by an agent writes document_posted_by_agent on the audit trail, every answer document_answered_by_agent: the mode, the company''s setting, the session, and in review the approval; the key is the row''s api_key_id. A rehearsal is not held to it.';

revoke execute on function ekwo.documents_posting_mode() from public, anon, authenticated, service_role;

drop trigger if exists documents_posting_mode on ekwo.documents;
create trigger documents_posting_mode
  before update of state, accepted_at, declined_at on ekwo.documents
  for each row when ((new.state = 'posted' and old.state = 'draft')
                     or new.accepted_at is distinct from old.accepted_at
                     or new.declined_at is distinct from old.declined_at)
  execute function ekwo.documents_posting_mode();

-- ---------------------------------------------------------------------------
-- 5. Privileges, by name
-- ---------------------------------------------------------------------------

revoke execute on function ekwo.quote_status(ekwo.documents) from public, anon;
revoke execute on function ekwo.quote_statuses(uuid[]) from public, anon;
revoke execute on function ekwo.document_to_answer(uuid) from public, anon;
revoke execute on function ekwo.accept_document(uuid, text, timestamptz) from public, anon;
revoke execute on function ekwo.decline_document(uuid, timestamptz) from public, anon;
revoke execute on function ekwo.undo_document_answer(uuid) from public, anon;

grant execute on function ekwo.quote_status(ekwo.documents) to authenticated, service_role;
grant execute on function ekwo.quote_statuses(uuid[]) to authenticated, service_role;
grant execute on function ekwo.document_to_answer(uuid) to authenticated, service_role;
grant execute on function ekwo.accept_document(uuid, text, timestamptz) to authenticated, service_role;
grant execute on function ekwo.decline_document(uuid, timestamptz) to authenticated, service_role;
grant execute on function ekwo.undo_document_answer(uuid) to authenticated, service_role;

-- The revoke every file of this directory ends with, and the Data API told
-- the functions are there.
revoke execute on all functions in schema ekwo from public;

notify pgrst, 'reload schema';
