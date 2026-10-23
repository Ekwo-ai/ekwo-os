-- Ekwo OS — an agent posts in the mode its company chose.
--
-- A person stays in control of the books by setting the rules and the rights,
-- and then by choosing, company by company, how an agent books a document:
--
--   review     every document an agent proposes is approved by a person
--              before the agent may post it. The default.
--   autopilot  the agent posts directly, within the rules and the rights it
--              has; every posting stays on the audit trail, saying so.
--
-- Until now "ask the user first" was a sentence in the instructions of the
-- MCP server, which a model may or may not follow. It is now a rule of the
-- database, so the command line, the REST API and the MCP server answer the
-- same way.
--
-- **Who is an agent.** A caller presenting a machine key (`current_api_key()`)
-- is one, always. So is the MCP server, which acts as a person
-- (decision 0053) and therefore marks every transaction it opens: the setting
-- `ekwo.agent` on a direct connection, the header `X-Ekwo-Agent` through
-- PostgREST. `agent_call()` reads the three. A person signed in — in the web
-- application, in the command line — posts as before, approved by the act of
-- posting.
--
-- **The mode is a column of the company**, `companies.posting_mode`, written
-- by whoever may write the company (`companies_update`, `company.write`),
-- and audited with it. An agent never changes it: `agent_call()` is refused
-- on the column, so a key holding `company.write` cannot switch its own
-- company to autopilot.
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
-- `document_posted_by_agent` row naming the mode, and in review the approval
-- it rests on. A rehearsal (`rehearse_post_document()`) posts and rolls back,
-- so it is not held to the approval: showing a person the entry is how they
-- decide to approve it.

-- ---------------------------------------------------------------------------
-- 1. The mode, on the company
-- ---------------------------------------------------------------------------

alter table companies
  add column if not exists posting_mode text not null default 'review';

alter table companies
  drop constraint if exists companies_posting_mode_known;
alter table companies
  add constraint companies_posting_mode_known
  check (posting_mode in ('review', 'autopilot'));

comment on column companies.posting_mode is
  'How an agent — a machine key, or the MCP server — books a document of this company: review (the default), only once a person has approved the draft as it stands (approve_document()); autopilot, directly, within the capabilities it holds. A person signed in posts as before in both. Written by a person only, never by an agent.';

-- ---------------------------------------------------------------------------
-- 2. Who is an agent
-- ---------------------------------------------------------------------------

create or replace function agent_call()
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select (select k.id from current_api_key() k) is not null
      or coalesce(current_setting('ekwo.agent', true), '') = 'on'
      or coalesce(nullif(current_setting('request.headers', true), '')::jsonb ->> 'x-ekwo-agent', '') <> '';
$$;

comment on function agent_call() is
  'Whether this transaction is an agent''s: a machine key is presented (current_api_key()), or the MCP server marked it — the setting ekwo.agent on a direct connection, the header X-Ekwo-Agent through PostgREST. Decides how a document is posted under companies.posting_mode.';

revoke execute on function agent_call() from public, anon;
grant execute on function agent_call() to authenticated, service_role;

create or replace function companies_posting_mode_by_a_person()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'UPDATE' and new.posting_mode is not distinct from old.posting_mode then
    return new;
  end if;
  if agent_call() and (tg_op = 'UPDATE' or new.posting_mode <> 'review') then
    raise exception 'posting_mode_by_a_person: how an agent posts in a company is chosen by a person signed in, never by an agent or a machine key.'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

comment on function companies_posting_mode_by_a_person() is
  'Refuses a change of companies.posting_mode, and a company created in autopilot, in a transaction of an agent (agent_call()).';

revoke execute on function companies_posting_mode_by_a_person() from public, anon, authenticated, service_role;

drop trigger if exists companies_posting_mode_by_a_person on companies;
create trigger companies_posting_mode_by_a_person
  before insert or update of posting_mode on companies
  for each row execute function companies_posting_mode_by_a_person();

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
  'A person who may post a draft approves it, as it stands, for an agent to post under posting_mode review: writes a document_approved row on the audit trail naming document_version(). A change to the draft afterwards voids it. Refused to an agent or a machine key (approval_by_a_person), without documents.post (not_allowed), and on a document that is not a draft. Returns the version approved.';

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

  select posting_mode into v_mode from companies where id = new.company_id;

  if v_mode = 'review' then
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
      raise exception 'approval_required: % % has not been approved by a person as it stands, and this company''s posting_mode is review. A person who may post it approves it (approve_document(), ekwo doc approve), or posts it; a draft changed after its approval is approved again.',
        new.doc_type, coalesce(new.number, new.id::text)
        using errcode = '42501';
    end if;
  end if;

  perform audit_record(
    new.company_id, 'documents', new.id, coalesce(new.number, new.id::text),
    'update', 'document_posted_by_agent', null,
    jsonb_strip_nulls(jsonb_build_object(
      'posting_mode', v_mode,
      'version', v_version,
      'approved_by', v_approval.actor_id,
      'approved_at', v_approval.occurred_at)));
  return new;
end;
$$;

comment on function documents_posting_mode() is
  'Holds the posting of a document by an agent (agent_call()) to companies.posting_mode: in review, refuses approval_required unless a person approved the draft as it stood (approve_document()) since it last went back to draft; in either mode, writes document_posted_by_agent on the audit trail with the mode, and in review the approval. A rehearsal is not held to it.';

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
