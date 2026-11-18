-- Ekwo — the `crm` module: a deal carries its documents, and a quote's answer
-- moves the deal.
--
-- The socle records the answer to a quote as dated facts —
-- `documents.accepted_at`, `accepted_by`, `declined_at`, written by
-- `accept_document()`, `decline_document()` and `undo_document_answer()` —
-- and derives its status with `quote_status()`. It knows no deal. The deal
-- carries the commercial status, here, and this file is the link between the
-- two.
--
-- **The link.** `crm.deal_documents`: a document belongs to at most one deal,
-- and a deal carries several — the versions of a quote, the phases of a
-- piece of business. Both sides name the company, so a deal of one company
-- never carries a document of another. `crm.attach_document()` and
-- `crm.detach_document()` write it; `crm.card_of()` and `crm.board()` give
-- each deal its documents with their derived status.
--
-- **The consequence, in the database.** A trigger of this module on the
-- socle's `documents` follows the answer of a document a deal carries, with
-- no agent and no approval of its own — the answer was the act, and the rule
-- below is its meaning:
--
-- - **accepted**: the deal moves to the first `won` stage of its pipeline,
--   through the same body as `crm.move_deal()`, so its party becomes a
--   customer;
-- - **declined**: the deal moves to the first `lost` stage, only when no other
--   answerable document of the deal is still alive — neither declined, nor
--   expired, nor cancelled;
-- - **sent** or **expired**: nothing moves. The open stages are named by each
--   company, and the module presumes none;
-- - **undone**: a deal this document's answer had closed, and that is still
--   closed that way, opens again at the stage it was at before — the last
--   open stage of the pipeline where that stage is no longer an open one.
--
-- A pipeline without a `won` (or `lost`) stage keeps the deal where it is: the
-- fact stays on the quote, and nothing fails. A company that has not enabled
-- the module, and a document no deal carries, are left alone. The trigger is
-- the module's, so a database without the module has none, and the socle's
-- functions answer the same with or without it.
--
-- **Who moves the deal.** The trigger is `security definer`: the person who
-- records an answer holds `documents.write`, and the module's rule applies
-- whatever else they hold — the move is written on the deal's timeline as a
-- system activity naming the document, as any move is.
--
-- **`crm.move_deal()` and the trigger share one body.** `crm.place_deal()`
-- holds what `move_deal()` did after its checks — the stage, the closing, the
-- customer, the activity — and both call it. The activity is written directly
-- rather than through `log_activity()`, whose check of `crm.write` belongs to
-- the person calling `move_deal()`, which still makes it first.
--
-- Names of the socle are written `public.`, as the module's files are; the
-- installer reads them for the socle's schema of the day.

-- The module's manifest still asks the socle it was first written for, as
-- every migration of the module sorts after it; what this file needs of a
-- newer socle is asked here, by name, before anything is written.
do $$
begin
  if to_regprocedure('public.quote_status(public.documents)') is null then
    raise exception 'socle_too_old: the crm module needs socle migration 20261118144012 (quote_status). Run ekwo migrate first.';
  end if;
end;
$$;

-- ---------------------------------------------------------------------------
-- 1. The link
-- ---------------------------------------------------------------------------

create table crm.deal_documents (
  id                     uuid primary key default gen_random_uuid(),
  company_id             uuid not null references public.companies(id) on delete cascade,
  deal_id                uuid not null,
  document_id            uuid not null,
  -- Where the deal stood when this document's answer closed it: what undoing
  -- the answer opens it again at. A memory of a stage, not a reference — a
  -- stage removed since is answered by the last open stage of the pipeline.
  stage_before_answer_id uuid,
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now(),
  -- A document belongs to one deal at most. The company leads the key: a row
  -- that names a document of another company fails on the foreign key, never
  -- on "duplicate", which would say the document exists and is carried.
  unique (company_id, document_id),
  foreign key (deal_id, company_id) references crm.deals (id, company_id) on delete cascade,
  foreign key (document_id, company_id) references public.documents (id, company_id) on delete cascade
);

comment on table crm.deal_documents is
  'The documents a deal carries — the versions of a quote, an order, the invoices of its phases. A document belongs to one deal at most, of the same company. The answer to a quote a deal carries moves the deal: accepted wins it, declined loses it when no other quote of the deal is still alive.';
comment on column crm.deal_documents.stage_before_answer_id is
  'The stage the deal was at when the answer to this document closed it, kept so that undoing the answer opens the deal again there. Null when the answer moved nothing. Not a foreign key: a stage removed since is answered by the last open stage of the pipeline.';

create unique index crm_deal_documents_id_company_idx on crm.deal_documents (id, company_id);
create index crm_deal_documents_deal_company_idx on crm.deal_documents (deal_id, company_id);
create index crm_deal_documents_document_company_idx on crm.deal_documents (document_id, company_id);
create index crm_deal_documents_company_idx on crm.deal_documents (company_id);

create trigger crm_deal_documents_set_updated_at
  before update on crm.deal_documents
  for each row execute function public.set_updated_at();

alter table crm.deal_documents enable row level security;

create policy crm_deal_documents_select on crm.deal_documents
  for select using (company_id = any ((select array(
    select x from unnest(public.companies_with_capability('crm.read')) as x where public.module_enabled(x, 'crm')
  ))::uuid[]));
create policy crm_deal_documents_write on crm.deal_documents
  for all using (company_id = any ((select array(
    select x from unnest(public.companies_with_capability('crm.write')) as x where public.module_enabled(x, 'crm')
  ))::uuid[]))
  with check (public.module_enabled(company_id, 'crm') and public.has_capability(company_id, 'crm.write'));

grant select, insert, update, delete on table crm.deal_documents to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 2. One body for a deal that moves
-- ---------------------------------------------------------------------------

create or replace function crm.place_deal(
  p_company_id uuid,
  p_deal_id    uuid,
  p_stage_id   uuid,
  p_why        jsonb default null
)
returns crm.deals
language plpgsql
as $$
declare
  v_deal   crm.deals%rowtype;
  v_from   crm.stages%rowtype;
  v_stage  crm.stages%rowtype;
  v_entity uuid;
  v_type   public.contact_type;
  v_n      integer;
begin
  select * into v_deal from crm.deals d where d.id = p_deal_id and d.company_id = p_company_id for update;
  if not found then
    raise exception 'crm_unknown_deal: deal % is not a deal of company %', p_deal_id, p_company_id;
  end if;
  select * into v_stage from crm.stages s where s.id = p_stage_id and s.pipeline_id = v_deal.pipeline_id;
  if not found then
    raise exception 'crm_stage_not_in_pipeline: stage % is not a stage of the pipeline deal % moves in', p_stage_id, v_deal.title;
  end if;
  if v_stage.id = v_deal.stage_id then
    return v_deal;
  end if;
  select * into v_from from crm.stages s where s.id = v_deal.stage_id;

  update crm.deals d
     set stage_id       = v_stage.id,
         closed_at      = case when v_stage.outcome = 'open' then null else now() end,
         closed_outcome = case when v_stage.outcome = 'open' then null else v_stage.outcome end
   where d.id = v_deal.id
  returning * into v_deal;

  -- A deal won makes its party a customer: the organisation at the root of
  -- the contact's chain, which is the row an invoice is issued to.
  if v_stage.outcome = 'won' then
    v_entity := public.commercial_entity(v_deal.contact_id);
    select c.contact_type into v_type from public.contacts c where c.id = v_entity and c.company_id = p_company_id;
    if v_type in ('other', 'supplier') then
      update public.contacts c
         set contact_type = case c.contact_type when 'other' then 'customer'::public.contact_type
                                                 else 'both'::public.contact_type end
       where c.id = v_entity and c.company_id = p_company_id;
      get diagnostics v_n = row_count;
      if v_n = 0 then
        raise exception 'crm_not_allowed: winning deal % makes its party a customer, which needs contacts.write', v_deal.title
          using errcode = '42501';
      end if;
    end if;
  end if;

  insert into crm.activities (company_id, contact_id, deal_id, kind, subject, payload)
  values (p_company_id, v_deal.contact_id, v_deal.id, 'system', 'moved to ' || v_stage.name,
          jsonb_build_object('from_stage_id', v_from.id, 'from_stage', v_from.name,
                             'to_stage_id', v_stage.id, 'to_stage', v_stage.name,
                             'outcome', v_stage.outcome)
          || coalesce(p_why, '{}'::jsonb));
  return v_deal;
end;
$$;

comment on function crm.place_deal(uuid, uuid, uuid, jsonb) is
  'The body of a deal that moves, shared by crm.move_deal() and the answer to a quote: the stage, the closing at a won or lost stage and the opening again at an open one, the party made a customer by a won deal (contacts.write), and the system activity on the timeline, its payload completed by p_why. The same stage again changes nothing. Asks nothing by name itself: move_deal() asks first, and the policies decide every row.';

create or replace function crm.move_deal(p_company_id uuid, p_deal_id uuid, p_stage_id uuid)
returns crm.deals
language plpgsql
as $$
begin
  perform crm.require(p_company_id, 'crm.write', 'moving a deal');
  return crm.place_deal(p_company_id, p_deal_id, p_stage_id);
end;
$$;

comment on function crm.move_deal(uuid, uuid, uuid) is
  'Moves a deal to another stage of its pipeline and logs it as a system activity (crm.place_deal()). Reaching a won or a lost stage closes the deal with its date and its outcome; going back to an open stage opens it again. A deal won makes the organisation at the root of its contact''s chain a customer — other becomes customer, supplier becomes both — which needs contacts.write. The same stage again changes nothing. Needs crm.write.';

-- ---------------------------------------------------------------------------
-- 3. Attaching and detaching a document
-- ---------------------------------------------------------------------------

create or replace function crm.attach_document(p_company_id uuid, p_deal_id uuid, p_document_id uuid)
returns crm.deal_documents
language plpgsql
as $$
declare
  v_row crm.deal_documents%rowtype;
begin
  perform crm.require(p_company_id, 'crm.write', 'attaching a document to a deal');
  if not exists (select 1 from crm.deals d where d.id = p_deal_id and d.company_id = p_company_id) then
    raise exception 'crm_unknown_deal: deal % is not a deal of company %', p_deal_id, p_company_id;
  end if;
  if not exists (select 1 from public.documents d where d.id = p_document_id and d.company_id = p_company_id) then
    raise exception 'crm_unknown_document: document % is not a document of company % you can read', p_document_id, p_company_id;
  end if;

  select * into v_row from crm.deal_documents l where l.document_id = p_document_id;
  if found then
    if v_row.deal_id = p_deal_id then
      return v_row;
    end if;
    raise exception 'crm_document_in_another_deal: document % is carried by another deal (%); detach it there first', p_document_id, v_row.deal_id;
  end if;

  insert into crm.deal_documents (company_id, deal_id, document_id)
  values (p_company_id, p_deal_id, p_document_id)
  returning * into v_row;
  return v_row;
end;
$$;

comment on function crm.attach_document(uuid, uuid, uuid) is
  'Attaches a document of the company — a quote, an order, an invoice — to a deal of the same company. The same pair again returns the link already kept; a document another deal carries is refused, crm_document_in_another_deal. From then on an answer recorded on the document moves the deal (accepted: won; declined: lost when no other quote of the deal is alive); an answer recorded before is not replayed. Needs crm.write, and a document the caller can read (crm_unknown_document).';

create or replace function crm.detach_document(p_company_id uuid, p_document_id uuid)
returns crm.deal_documents
language plpgsql
as $$
declare
  v_row crm.deal_documents%rowtype;
begin
  perform crm.require(p_company_id, 'crm.write', 'detaching a document from a deal');
  delete from crm.deal_documents l
   where l.document_id = p_document_id and l.company_id = p_company_id
  returning * into v_row;
  if v_row.id is null then
    raise exception 'crm_document_not_attached: document % is carried by no deal of company %', p_document_id, p_company_id;
  end if;
  return v_row;
end;
$$;

comment on function crm.detach_document(uuid, uuid) is
  'Takes a document off the deal that carries it, and returns the link as it was. The deal stays where it is. Refuses a document no deal of the company carries, crm_document_not_attached. Needs crm.write.';

-- ---------------------------------------------------------------------------
-- 4. The documents of a deal, as every read gives them
-- ---------------------------------------------------------------------------

create or replace function crm.deal_documents_of(p_company_id uuid, p_deal_id uuid)
returns jsonb
language sql
stable
as $$
  select coalesce(jsonb_agg(jsonb_build_object(
           'id', d.id, 'doc_type', d.doc_type, 'number', d.number, 'state', d.state,
           'document_date', d.document_date, 'due_date', d.due_date,
           'amount_total', d.amount_total::text, 'currency_code', d.currency_code,
           'sent_at', d.sent_at, 'accepted_at', d.accepted_at, 'accepted_by', d.accepted_by,
           'declined_at', d.declined_at, 'quote_status', public.quote_status(d))
         order by d.document_date, d.created_at, d.id), '[]'::jsonb)
    from crm.deal_documents l
    join public.documents d on d.id = l.document_id and d.company_id = l.company_id
   where l.deal_id = p_deal_id and l.company_id = p_company_id;
$$;

comment on function crm.deal_documents_of(uuid, uuid) is
  'The documents a deal carries, as a JSON array, oldest first: each with its type, number, state, dates, total as a decimal string and currency, the answer recorded on it (sent_at, accepted_at, accepted_by, declined_at) and quote_status, derived by the socle''s quote_status(). A document the caller cannot read is absent. What crm.card_of() and crm.board() give each deal.';

create or replace function crm.card_of(p_company_id uuid, p_contact_id uuid)
returns jsonb
language plpgsql
stable
as $$
declare
  v_contact public.contacts%rowtype;
  v_out     jsonb;
begin
  perform crm.require(p_company_id, 'crm.read', 'reading a card');
  select * into v_contact from public.contacts c where c.id = p_contact_id and c.company_id = p_company_id;
  if not found then
    raise exception 'crm_unknown_contact: contact % is not a contact of company %', p_contact_id, p_company_id;
  end if;

  select jsonb_build_object(
    'contact', jsonb_build_object(
      'id', v_contact.id, 'name', v_contact.name, 'is_company', v_contact.is_company,
      'contact_type', v_contact.contact_type, 'parent_id', v_contact.parent_id,
      'email', v_contact.email, 'phone', v_contact.phone, 'city', v_contact.city,
      'country', v_contact.country, 'language', v_contact.language,
      'vat_number', v_contact.vat_number, 'active', v_contact.active),
    'organisation', (select jsonb_build_object('id', o.id, 'name', o.name, 'contact_type', o.contact_type)
                       from public.contacts o
                      where o.id = v_contact.parent_id and o.company_id = p_company_id),
    'card', (select to_jsonb(k) from crm.cards k where k.contact_id = p_contact_id and k.company_id = p_company_id),
    'segments', coalesce((select jsonb_agg(jsonb_build_object('id', s.id, 'slug', s.slug, 'name', s.name,
                                                               'kind', s.kind, 'joined_at', m.joined_at)
                                           order by s.slug)
                            from crm.segment_members m
                            join crm.segments s on s.id = m.segment_id and s.company_id = m.company_id
                           where m.contact_id = p_contact_id and m.company_id = p_company_id
                             and m.left_at is null), '[]'::jsonb),
    -- An organisation's deals include those with its people.
    'deals', coalesce((select jsonb_agg(jsonb_build_object('id', d.id, 'title', d.title, 'contact_id', d.contact_id,
                                                            'pipeline_id', d.pipeline_id, 'stage_id', d.stage_id,
                                                            'stage', st.name, 'amount', d.amount,
                                                            'currency_code', d.currency_code,
                                                            'expected_on', d.expected_on, 'owner', d.owner,
                                                            'documents', crm.deal_documents_of(p_company_id, d.id))
                                         order by d.created_at)
                         from crm.deals d
                         join crm.stages st on st.id = d.stage_id
                        where d.company_id = p_company_id and d.closed_at is null
                          and (d.contact_id = p_contact_id
                               or d.contact_id in (select c.id from public.contacts c
                                                    where c.parent_id = p_contact_id and c.company_id = p_company_id))),
                      '[]'::jsonb),
    'activities', coalesce((select jsonb_agg(to_jsonb(a) order by a.occurred_at desc, a.created_at desc)
                              from (select * from crm.activities a
                                     where a.company_id = p_company_id and a.contact_id = p_contact_id
                                     order by a.occurred_at desc, a.created_at desc
                                     limit 20) a), '[]'::jsonb)
  ) into v_out;
  return v_out;
end;
$$;

comment on function crm.card_of(uuid, uuid) is
  'Everything on one contact, as one JSON object: the contact as the socle holds it, its organisation, its card, the segments it is in now, the open deals with it — and, for an organisation, with its people — each with the documents it carries and their quote_status (crm.deal_documents_of()), and its 20 latest activities. Needs crm.read.';

create or replace function crm.board(
  p_company_id     uuid,
  p_pipeline_id    uuid default null,
  p_include_closed boolean default false
)
returns jsonb
language plpgsql
stable
as $$
declare
  v_out jsonb;
begin
  perform crm.require(p_company_id, 'crm.read', 'reading a board');
  if p_pipeline_id is not null
     and not exists (select 1 from crm.pipelines p where p.id = p_pipeline_id and p.company_id = p_company_id) then
    raise exception 'crm_unknown_pipeline: pipeline % is not a pipeline of company %', p_pipeline_id, p_company_id;
  end if;

  with shown as (
    -- The deals on the board: the open ones, and the closed ones when asked.
    select d.*, c.name as contact_name
      from crm.deals d
      join public.contacts c on c.id = d.contact_id and c.company_id = d.company_id
     where d.company_id = p_company_id
       and (p_pipeline_id is null or d.pipeline_id = p_pipeline_id)
       and (coalesce(p_include_closed, false) or d.closed_at is null)
  ),
  stage_totals as (
    select s.stage_id,
           jsonb_agg(jsonb_build_object('currency_code', s.currency_code, 'amount', s.amount::text, 'deals', s.deals)
                     order by s.currency_code) as totals
      from (select stage_id, currency_code, sum(amount) as amount, count(*)::integer as deals
              from shown where amount is not null
             group by stage_id, currency_code) s
     group by s.stage_id
  ),
  pipeline_totals as (
    select s.pipeline_id,
           jsonb_agg(jsonb_build_object('currency_code', s.currency_code, 'amount', s.amount::text, 'deals', s.deals)
                     order by s.currency_code) as totals
      from (select pipeline_id, currency_code, sum(amount) as amount, count(*)::integer as deals
              from shown where amount is not null
             group by pipeline_id, currency_code) s
     group by s.pipeline_id
  )
  select jsonb_build_object(
    'include_closed', coalesce(p_include_closed, false),
    'pipelines', coalesce(jsonb_agg(
      jsonb_build_object(
        'id', p.id, 'name', p.name, 'slug', p.slug,
        'stages', coalesce((
          select jsonb_agg(jsonb_build_object(
                   'id', st.id, 'name', st.name, 'position', st.position, 'outcome', st.outcome,
                   'deals', coalesce((
                     select jsonb_agg(jsonb_build_object(
                              'id', d.id, 'title', d.title,
                              'contact_id', d.contact_id, 'contact_name', d.contact_name,
                              'amount', d.amount::text, 'currency_code', d.currency_code,
                              'expected_on', d.expected_on, 'owner', d.owner, 'external_url', d.external_url,
                              'closed_at', d.closed_at, 'closed_outcome', d.closed_outcome,
                              'updated_at', d.updated_at,
                              'documents', crm.deal_documents_of(p_company_id, d.id))
                            order by d.expected_on nulls last, d.created_at, d.id)
                       from shown d where d.stage_id = st.id), '[]'::jsonb),
                   'count', (select count(*)::integer from shown d where d.stage_id = st.id),
                   'totals', coalesce((select t.totals from stage_totals t where t.stage_id = st.id), '[]'::jsonb))
                 order by st.position)
            from crm.stages st
           where st.pipeline_id = p.id and st.company_id = p_company_id), '[]'::jsonb),
        'count', (select count(*)::integer from shown d where d.pipeline_id = p.id),
        'totals', coalesce((select t.totals from pipeline_totals t where t.pipeline_id = p.id), '[]'::jsonb))
      order by p.name, p.id), '[]'::jsonb))
    into v_out
    from crm.pipelines p
   where p.company_id = p_company_id
     and (p_pipeline_id is null or p.id = p_pipeline_id);
  return v_out;
end;
$$;

comment on function crm.board(uuid, uuid, boolean) is
  'One pipeline of a company as a board, or every pipeline when none is named: its stages in order, each with its deals — the open ones, and the closed ones too under p_include_closed — each with the documents it carries and their quote_status (crm.deal_documents_of()), how many there are, and the sum of their amounts by currency. The pipeline carries the same totals over all its stages. A deal without an amount is counted and summed in no currency. Amounts are decimal strings. A pipeline of another company is refused by name, crm_unknown_pipeline. Needs crm.read.';

-- ---------------------------------------------------------------------------
-- 5. The consequence of an answer
-- ---------------------------------------------------------------------------

create or replace function crm.follow_document_answer()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_link  crm.deal_documents%rowtype;
  v_deal  crm.deals%rowtype;
  v_stage uuid;
  v_why   jsonb := jsonb_build_object('document_id', new.id, 'document_number', new.number);
begin
  if not public.module_is_enabled(new.company_id, 'crm') then
    return null;
  end if;
  select * into v_link from crm.deal_documents l where l.document_id = new.id and l.company_id = new.company_id;
  if not found then
    return null;
  end if;
  select * into v_deal from crm.deals d where d.id = v_link.deal_id and d.company_id = v_link.company_id for update;

  if new.accepted_at is not null and old.accepted_at is null then
    -- Accepted: the first won stage of the pipeline, if it has one.
    select s.id into v_stage from crm.stages s
     where s.pipeline_id = v_deal.pipeline_id and s.outcome = 'won'
     order by s.position limit 1;
    if v_stage is null or v_stage = v_deal.stage_id then
      return null;
    end if;
    update crm.deal_documents l set stage_before_answer_id = v_deal.stage_id where l.id = v_link.id;
    perform crm.place_deal(v_deal.company_id, v_deal.id, v_stage, v_why || '{"answer": "accepted"}'::jsonb);

  elsif new.declined_at is not null and old.declined_at is null then
    -- Declined: lost, unless another quote of the deal is still alive.
    if exists (select 1
                 from crm.deal_documents l
                 join public.documents d on d.id = l.document_id and d.company_id = l.company_id
                where l.deal_id = v_deal.id and l.document_id <> new.id
                  and public.quote_status(d) not in ('declined', 'expired', 'cancelled')) then
      return null;
    end if;
    select s.id into v_stage from crm.stages s
     where s.pipeline_id = v_deal.pipeline_id and s.outcome = 'lost'
     order by s.position limit 1;
    if v_stage is null or v_stage = v_deal.stage_id then
      return null;
    end if;
    update crm.deal_documents l set stage_before_answer_id = v_deal.stage_id where l.id = v_link.id;
    perform crm.place_deal(v_deal.company_id, v_deal.id, v_stage, v_why || '{"answer": "declined"}'::jsonb);

  elsif new.accepted_at is null and new.declined_at is null and v_link.stage_before_answer_id is not null then
    -- Undone: a deal this answer closed, and still closed that way, opens
    -- again where it was — or at the last open stage of its pipeline.
    if v_deal.closed_outcome is distinct from
         (case when old.accepted_at is not null then 'won' else 'lost' end)::crm.stage_outcome then
      update crm.deal_documents l set stage_before_answer_id = null where l.id = v_link.id;
      return null;
    end if;
    select s.id into v_stage from crm.stages s
     where s.id = v_link.stage_before_answer_id and s.pipeline_id = v_deal.pipeline_id and s.outcome = 'open';
    if v_stage is null then
      select s.id into v_stage from crm.stages s
       where s.pipeline_id = v_deal.pipeline_id and s.outcome = 'open'
       order by s.position desc limit 1;
    end if;
    update crm.deal_documents l set stage_before_answer_id = null where l.id = v_link.id;
    if v_stage is not null then
      perform crm.place_deal(v_deal.company_id, v_deal.id, v_stage, v_why || '{"answer": "undone"}'::jsonb);
    end if;
  end if;
  return null;
end;
$$;

comment on function crm.follow_document_answer() is
  'After the answer to a document moves (accepted_at, declined_at), moves the deal that carries it, in a company that holds the module: accepted, to the first won stage of its pipeline — its party becomes a customer; declined, to the first lost stage when no other answerable document of the deal is alive (neither declined, expired nor cancelled); undone, back to the stage it was at before when this answer closed it and it is still closed that way, or the last open stage of the pipeline. A pipeline without the stage, a document no deal carries and a company without the module: nothing moves. Sent and expired move nothing. Through crm.place_deal(), so the move is on the timeline with the document named.';

drop trigger if exists crm_follow_document_answer on public.documents;
create trigger crm_follow_document_answer
  after update of accepted_at, declined_at on public.documents
  for each row when (new.accepted_at is distinct from old.accepted_at
                     or new.declined_at is distinct from old.declined_at)
  execute function crm.follow_document_answer();

-- ---------------------------------------------------------------------------
-- 6. The archive of a company carries the link
-- ---------------------------------------------------------------------------

create or replace function crm.archive_tables()
returns table (
  table_name  text,
  disposition text,
  reason      text,
  via_column  text,
  via_table   text,
  load_order  integer
)
language sql
immutable
as $$
  values
    ('pipelines'::text,  'exported'::text, null::text, null::text, null::text, 1),
    ('stages',           'exported',       null,       null,       null,       2),
    ('segments',         'exported',       null,       null,       null,       3),
    ('cards',            'exported',       null,       null,       null,       4),
    ('segment_members',  'exported',       null,       null,       null,       5),
    ('deals',            'exported',       null,       null,       null,       6),
    ('activities',       'exported',       null,       null,       null,       7),
    ('deal_documents',   'exported',       null,       null,       null,       8);
$$;

comment on function crm.archive_tables() is
  'What an archive of one company does with each table of this module: all eight travel — a relationship is the company''s as much as its books, and the documents its deals carry with it. Read by `public.company_archive_tables()`.';

-- ---------------------------------------------------------------------------
-- 7. Privileges, by name
-- ---------------------------------------------------------------------------

revoke execute on function crm.place_deal(uuid, uuid, uuid, jsonb) from public, anon;
revoke execute on function crm.move_deal(uuid, uuid, uuid) from public, anon;
revoke execute on function crm.attach_document(uuid, uuid, uuid) from public, anon;
revoke execute on function crm.detach_document(uuid, uuid) from public, anon;
revoke execute on function crm.deal_documents_of(uuid, uuid) from public, anon;
revoke execute on function crm.card_of(uuid, uuid) from public, anon;
revoke execute on function crm.board(uuid, uuid, boolean) from public, anon;
revoke execute on function crm.archive_tables() from public, anon;

grant execute on function crm.place_deal(uuid, uuid, uuid, jsonb) to authenticated, service_role;
grant execute on function crm.move_deal(uuid, uuid, uuid) to authenticated, service_role;
grant execute on function crm.attach_document(uuid, uuid, uuid) to authenticated, service_role;
grant execute on function crm.detach_document(uuid, uuid) to authenticated, service_role;
grant execute on function crm.deal_documents_of(uuid, uuid) to authenticated, service_role;
grant execute on function crm.card_of(uuid, uuid) to authenticated, service_role;
grant execute on function crm.board(uuid, uuid, boolean) to authenticated, service_role;
grant execute on function crm.archive_tables() to authenticated, service_role;

-- The trigger body is fired by its table and called by nobody.
revoke execute on function crm.follow_document_answer() from public, anon, authenticated, service_role;
