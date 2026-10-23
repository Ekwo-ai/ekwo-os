-- Ekwo OS — an agent posts in the mode its company chose.
--
-- A person stays in control of the books by setting the rules and the rights,
-- and then by choosing, company by company, how an agent books a document.
-- The choice is a setting of the company, `companies.agent_posting`, read and
-- written where the rest of its profile is:
--
--   review       a document an agent proposes is posted once a person has
--                approved the draft as it stands. The default. A session may
--                still opt into autopilot (below).
--   autopilot    agents post directly, within the rights of the person they
--                act for; every posting stays on the audit trail, saying so.
--   review_only  as review, and no session may opt into autopilot.
--
-- The model is the permissions of a coding agent: a default mode in the
-- settings, a flag a person passes to one session to skip the questions, and
-- a setting that forbids that flag. Until now "ask the user first" was a
-- sentence in the instructions of the MCP server, which a model may or may
-- not follow. It is now a rule of the database, so the command line, the
-- REST API and the MCP server answer the same way.
--
-- **Who is an agent.** A caller presenting a machine key (`current_api_key()`)
-- is one, always. So is the MCP server, which acts as a person
-- (decision 0053) and therefore marks every transaction it opens: the setting
-- `ekwo.agent` on a direct connection, the header `X-Ekwo-Agent` through
-- PostgREST. `agent_call()` reads the three. A person signed in — in the web
-- application, in the command line — posts as before, approved by the act of
-- posting.
--
-- **The session's choice** is the value of that mark: `autopilot` or
-- `review`, or anything else for none, and then the company's setting
-- decides. `ekwo.agent_session` / `X-Ekwo-Agent-Session` names the session,
-- for the trail. `agent_posting_mode(company)` is the mode a posting of this
-- transaction meets: `review`, `autopilot`, or `autopilot_forbidden` when the
-- session asks for autopilot in a company that is `review_only` — and a
-- posting is then refused by that name.
--
-- **Who changes the setting** is who may write the company
-- (`companies_update`, `company.write`), and the change is on the audit trail
-- with the company's other columns. An agent may make it stricter — autopilot
-- to review, review to review_only — and never looser: a key holding
-- `company.write` does not switch its own company to autopilot.
--
-- **An approval is an act on the audit trail**, not a new table:
-- `approve_document(document)` writes a `document_approved` row naming the
-- version of the draft it approves. The version is `document_version()`, a
-- digest of the document and its lines as they stand, so an approval covers
-- what the person saw and nothing written afterwards: a draft changed after
-- its approval needs another. An approval counts only after the last time the
-- document went back to draft, so a document unposted and posted again by an
-- agent is approved again. Only a person who may post the document approves
-- it — an agent cannot approve its own proposal.
--
-- **The rule is a trigger on the posting itself**, beside
-- `documents_assert_may_post`: whatever path sets a document to posted meets
-- it. In review an agent's posting without a valid approval is refused,
-- `approval_required`; in either mode an agent's posting writes a
-- `document_posted_by_agent` row naming the mode, the setting, the session
-- and, in review, the approval it rests on — the key that did it is the
-- trail's own `api_key_id`. A rehearsal (`rehearse_post_document()`) posts and
-- rolls back, so it is not held to the mode: showing a person the entry is
-- how they decide to approve it.

-- ---------------------------------------------------------------------------
-- 1. The setting, on the company
-- ---------------------------------------------------------------------------

alter table companies
  add column if not exists agent_posting text not null default 'review';

alter table companies
  drop constraint if exists companies_agent_posting_known;
alter table companies
  add constraint companies_agent_posting_known
  check (agent_posting in ('review', 'autopilot', 'review_only'));

comment on column companies.agent_posting is
  'How an agent — a machine key, or the MCP server — books a document of this company: review (the default), once a person has approved the draft as it stands (approve_document()), unless the session opted into autopilot; autopilot, directly, within the capabilities it holds; review_only, as review, and no session may opt into autopilot. A person signed in posts as before in all three. Written with company.write; an agent may only make it stricter.';

-- ---------------------------------------------------------------------------
-- 2. Who is an agent, and what its session asked for
-- ---------------------------------------------------------------------------

create or replace function agent_mark(p_name text)
returns text
language sql
stable
security invoker
set search_path = public, pg_temp
as $$
  select coalesce(
    nullif(current_setting('ekwo.' || p_name, true), ''),
    nullif(nullif(current_setting('request.headers', true), '')::jsonb ->> ('x-ekwo-' || replace(p_name, '_', '-')), ''));
$$;

comment on function agent_mark(text) is
  'What the MCP server, or a program holding a key, says of this transaction: the setting ekwo.<name> on a direct connection, the header X-Ekwo-<Name> through PostgREST. agent is the mark of an agent and its session''s posting mode, agent_session the name of its session.';

revoke execute on function agent_mark(text) from public, anon;
grant execute on function agent_mark(text) to authenticated, service_role;

create or replace function agent_call()
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select (select k.id from current_api_key() k) is not null
      or agent_mark('agent') is not null;
$$;

comment on function agent_call() is
  'Whether this transaction is an agent''s: a machine key is presented (current_api_key()), or the MCP server marked it — the setting ekwo.agent on a direct connection, the header X-Ekwo-Agent through PostgREST. Decides how a document is posted under companies.agent_posting.';

revoke execute on function agent_call() from public, anon;
grant execute on function agent_call() to authenticated, service_role;

create or replace function agent_posting_mode(p_company_id uuid)
returns text
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select case
           when c.agent_posting = 'review_only' and agent_mark('agent') = 'autopilot' then 'autopilot_forbidden'
           when c.agent_posting = 'review_only' then 'review'
           when agent_mark('agent') in ('review', 'autopilot') then agent_mark('agent')
           else c.agent_posting
         end
    from companies c
   where c.id = p_company_id
     and (is_installer() or has_capability(c.id, 'documents.read'));
$$;

comment on function agent_posting_mode(uuid) is
  'The mode an agent''s posting in this transaction meets in a company: the session''s choice (the mark agent: review or autopilot) where it made one, the company''s agent_posting otherwise; review in a company that is review_only, and autopilot_forbidden when the session asked for autopilot there. Null for a company the caller cannot see.';

revoke execute on function agent_posting_mode(uuid) from public, anon;
grant execute on function agent_posting_mode(uuid) to authenticated, service_role;

create or replace function companies_agent_posting_by_a_person()
returns trigger
language plpgsql
as $$
declare
  v_rank constant jsonb := '{"autopilot": 0, "review": 1, "review_only": 2}';
  v_from text := case when tg_op = 'UPDATE' then old.agent_posting else 'review' end;
begin
  if new.agent_posting is not distinct from v_from then
    return new;
  end if;
  if agent_call() and (v_rank ->> new.agent_posting)::int < (v_rank ->> v_from)::int then
    raise exception 'agent_posting_by_a_person: an agent may make the posting of agents stricter, never looser — from % to % is chosen by a person signed in, never by an agent or a machine key.', v_from, new.agent_posting
      using errcode = '42501';
  end if;
  return new;
end;
$$;

comment on function companies_agent_posting_by_a_person() is
  'Refuses, in a transaction of an agent (agent_call()), a change of companies.agent_posting that loosens it — review_only to review, review to autopilot — and a company created looser than review. Stricter is allowed.';

revoke execute on function companies_agent_posting_by_a_person() from public, anon, authenticated, service_role;

drop trigger if exists companies_agent_posting_by_a_person on companies;
create trigger companies_agent_posting_by_a_person
  before insert or update of agent_posting on companies
  for each row execute function companies_agent_posting_by_a_person();
-- ---------------------------------------------------------------------------
-- 3. The version of a draft, and its approval
-- ---------------------------------------------------------------------------

create or replace function document_version(p_document_id uuid)
returns text
language sql
stable
security invoker
set search_path = public, pg_temp
as $$
  select md5(
    (to_jsonb(d) - 'updated_at')::text
    || coalesce((select jsonb_agg(to_jsonb(l) - 'updated_at' order by l.sequence, l.id)
                   from document_lines l
                  where l.document_id = d.id)::text, '[]'))
    from documents d
   where d.id = p_document_id;
$$;

comment on function document_version(uuid) is
  'A digest of a document and its lines as they stand, every column but updated_at: what approve_document() approves, and what a posting by an agent in review compares to it. Any change to the draft gives another. Null for a document the caller cannot read.';

revoke execute on function document_version(uuid) from public, anon;
grant execute on function document_version(uuid) to authenticated, service_role;

create or replace function approve_document(p_document_id uuid)
returns text
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_doc     documents%rowtype;
  v_version text;
begin
  select * into v_doc from documents where id = p_document_id;
  if v_doc.id is null
     or not (is_installer() or has_capability(v_doc.company_id, 'documents.read')) then
    raise exception 'unknown_document: no document % in the companies you can see', p_document_id
      using errcode = 'P0002';
  end if;
  if agent_call() or (auth.uid() is null and not is_installer()) then
    raise exception 'approval_by_a_person: a document is approved by a person signed in, never by an agent or a machine key. The agent that proposed it waits for that approval.'
      using errcode = '42501';
  end if;
  if not is_installer() and not has_capability(v_doc.company_id, 'documents.post') then
    raise exception 'not_allowed: approving a document for posting needs documents.post'
      using errcode = '42501';
  end if;
  if v_doc.state <> 'draft' then
    raise exception 'document_not_draft: document % is %. Only a draft is approved for posting.', p_document_id, v_doc.state
      using errcode = '55006';
  end if;

  v_version := document_version(p_document_id);
  perform audit_record(
    v_doc.company_id, 'documents', v_doc.id, coalesce(v_doc.number, v_doc.id::text),
    'update', 'document_approved', null,
    jsonb_build_object('version', v_version));
  return v_version;
end;
$$;

comment on function approve_document(uuid) is
  'A person who may post a draft approves it, as it stands, for an agent to post in review: writes a document_approved row on the audit trail naming document_version(). A change to the draft afterwards voids it. Refused to an agent or a machine key (approval_by_a_person), without documents.post (not_allowed), and on a document that is not a draft. Returns the version approved.';

revoke execute on function approve_document(uuid) from public, anon;
grant execute on function approve_document(uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 4. The rule, on the posting
-- ---------------------------------------------------------------------------

create or replace function documents_posting_mode()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_mode     text;
  v_version  text;
  v_approval audit_log%rowtype;
begin
  if not agent_call() or coalesce(current_setting('ekwo.rehearsal', true), '') = 'on' then
    return new;
  end if;

  v_mode := agent_posting_mode(new.company_id);

  if v_mode = 'autopilot_forbidden' then
    raise exception 'autopilot_forbidden: this company''s agent_posting is review_only, so no session posts in autopilot. Start the session in review (without --autopilot, or with the mark X-Ekwo-Agent: review), and a person approves each draft (approve_document(), ekwo doc approve).'
      using errcode = '42501';
  end if;

  if v_mode is distinct from 'autopilot' then
    -- A trigger before the update reads the row as it still stands, so this
    -- is the version of the draft that is being posted.
    v_version := document_version(old.id);

    select a.* into v_approval
      from audit_log a
     where a.table_name = 'documents'
       and a.record_id = new.id
       and a.action = 'document_approved'
       and a.api_key_id is null
       and a.new_values ->> 'version' = v_version
       and a.id > coalesce((select max(b.id) from audit_log b
                             where b.table_name = 'documents'
                               and b.record_id = new.id
                               and b.action = 'document_draft'), 0)
     order by a.id desc
     limit 1;

    if v_approval.id is null then
      raise exception 'approval_required: % % has not been approved by a person as it stands, and agents post in review here. A person who may post it approves it (approve_document(), ekwo doc approve), or posts it; a draft changed after its approval is approved again.',
        new.doc_type, coalesce(new.number, new.id::text)
        using errcode = '42501';
    end if;
  end if;

  perform audit_record(
    new.company_id, 'documents', new.id, coalesce(new.number, new.id::text),
    'update', 'document_posted_by_agent', null,
    jsonb_strip_nulls(jsonb_build_object(
      'posting_mode', v_mode,
      'agent_posting', (select c.agent_posting from companies c where c.id = new.company_id),
      'session', agent_mark('agent_session'),
      'version', v_version,
      'approved_by', v_approval.actor_id,
      'approved_at', v_approval.occurred_at)));
  return new;
end;
$$;

comment on function documents_posting_mode() is
  'Holds the posting of a document by an agent (agent_call()) to agent_posting_mode(): autopilot_forbidden when the session asked for autopilot in a company that is review_only; in review, approval_required unless a person approved the draft as it stood (approve_document()) since it last went back to draft. Every posting by an agent writes document_posted_by_agent on the audit trail: the mode, the company''s setting, the session, and in review the approval; the key is the row''s api_key_id. A rehearsal is not held to it.';

revoke execute on function documents_posting_mode() from public, anon, authenticated, service_role;

drop trigger if exists documents_posting_mode on documents;
create trigger documents_posting_mode
  before update of state on documents
  for each row when (new.state = 'posted' and old.state = 'draft')
  execute function documents_posting_mode();

-- ---------------------------------------------------------------------------
-- 5. A rehearsal shows the entry, whatever the mode
--
-- `20260918143417` as it was, with the setting that tells the rule above it
-- is a rehearsal. The setting is made inside the block the rehearsal rolls
-- back, so it is undone with everything else.
-- ---------------------------------------------------------------------------

create or replace function rehearse_post_document(p_document_id uuid)
returns jsonb
language plpgsql
volatile
security invoker
as $$
declare
  v_entry  entries;
  v_result jsonb;
begin
  begin
    perform set_config('ekwo.rehearsal', 'on', true);
    v_entry := post_document(p_document_id);

    select jsonb_build_object(
      'entry', jsonb_build_object(
        'number',       v_entry.number,
        'entry_date',   v_entry.entry_date::text,
        'journal_id',   v_entry.journal_id,
        'total_debit',  v_entry.total_debit::text,
        'total_credit', v_entry.total_credit::text
      ),
      'entry_lines', coalesce((
        select jsonb_agg(jsonb_build_object(
                 'sequence',     l.sequence,
                 'account_id',   l.account_id,
                 'account_code', a.code,
                 'account_name', a.name,
                 'name',         l.name,
                 'debit',        l.debit::text,
                 'credit',       l.credit::text,
                 'tax_id',       l.tax_id,
                 'contact_id',   l.contact_id
               ) order by l.sequence)
        from entry_lines l
        join accounts a on a.id = l.account_id
        where l.entry_id = v_entry.id
      ), '[]'::jsonb)
    ) into v_result;

    -- The way out of the block that undoes everything done inside it. A
    -- variable is not part of the transaction, so the answer survives.
    raise exception using errcode = 'EKW01', message = 'rehearsal';
  exception
    when sqlstate 'EKW01' then
      null;
  end;

  return v_result;
end;
$$;
