-- Ekwo — the `crm` module: the three reads an agent and a terminal share.
--
-- The first migration of the module writes through functions and reads one
-- contact (`card_of`) or a list of cards (`search_cards`). What an agent and a
-- terminal also need is the shape of the rest: the tree of segments with how
-- many contacts are in each one now, a pipeline as a board — its stages in
-- order, the deals at each, the totals by currency — and what happened to one
-- contact or one deal. Each is one function here, so the MCP server and the
-- command line call the same thing and neither counts, sums or sorts on its
-- own.
--
-- Like the rest of the module they are `security invoker`: the policies
-- decide every row, and `crm.require()` answers by name first. They read; none
-- of them writes.

-- ---------------------------------------------------------------------------
-- The segments, as a tree
-- ---------------------------------------------------------------------------

create or replace function crm.segment_tree(p_company_id uuid)
returns table (
  id          uuid,
  parent_id   uuid,
  kind        crm.segment_kind,
  name        text,
  slug        text,
  description text,
  depth       integer,
  path        text[],
  members     integer
)
language plpgsql
stable
as $$
begin
  perform crm.require(p_company_id, 'crm.read', 'reading the segments');
  return query
  with recursive tree as (
    select s.id, s.parent_id, s.kind, s.name, s.slug, s.description, 0 as depth, array[s.slug] as path
      from crm.segments s
     where s.company_id = p_company_id and s.parent_id is null
    union all
    select s.id, s.parent_id, s.kind, s.name, s.slug, s.description, t.depth + 1, t.path || s.slug
      from crm.segments s
      join tree t on t.id = s.parent_id
     where s.company_id = p_company_id
  )
  select t.id, t.parent_id, t.kind, t.name, t.slug, t.description, t.depth, t.path,
         (select count(*)::integer
            from crm.segment_members m
           where m.segment_id = t.id and m.company_id = p_company_id and m.left_at is null)
    from tree t
   order by t.path;
end;
$$;

comment on function crm.segment_tree(uuid) is
  'Every segment of a company as a tree: each one with its parent, its depth (0 at a root), the path of slugs from the root down to it, and how many contacts are in it now — a contact who left is not counted. Ordered by path, so a parent comes just before its children. Needs crm.read.';

-- ---------------------------------------------------------------------------
-- A pipeline, as a board
-- ---------------------------------------------------------------------------

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
                              'updated_at', d.updated_at)
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
  'One pipeline of a company as a board, or every pipeline when none is named: its stages in order, each with its deals — the open ones, and the closed ones too under p_include_closed — how many there are, and the sum of their amounts by currency. The pipeline carries the same totals over all its stages. A deal without an amount is counted and summed in no currency. Amounts are decimal strings. A pipeline of another company is refused by name, crm_unknown_pipeline. Needs crm.read.';

-- ---------------------------------------------------------------------------
-- What happened to a contact, or to a deal
-- ---------------------------------------------------------------------------

create or replace function crm.timeline(
  p_company_id uuid,
  p_contact_id uuid default null,
  p_deal_id    uuid default null,
  p_since      timestamptz default null,
  p_kinds      text[] default null,
  p_limit      integer default 50
)
returns setof crm.activities
language plpgsql
stable
as $$
declare
  -- Read as the enum: a kind the module does not know is refused by Postgres,
  -- by name, rather than matching nothing.
  v_kinds crm.activity_kind[] := p_kinds::crm.activity_kind[];
begin
  perform crm.require(p_company_id, 'crm.read', 'reading a timeline');
  if p_contact_id is null and p_deal_id is null then
    raise exception 'crm_bad_timeline: a timeline is the activities of a contact or of a deal; name one';
  end if;
  return query
  select a.*
    from crm.activities a
   where a.company_id = p_company_id
     and (p_contact_id is null or a.contact_id = p_contact_id)
     and (p_deal_id is null or a.deal_id = p_deal_id)
     and (p_since is null or a.occurred_at >= p_since)
     and (v_kinds is null or a.kind = any (v_kinds))
   order by a.occurred_at desc, a.created_at desc, a.id
   limit greatest(coalesce(p_limit, 50), 0);
end;
$$;

comment on function crm.timeline(uuid, uuid, uuid, timestamptz, text[], integer) is
  'The activities of one contact, or of one deal, or of both at once — most recent first, from p_since on, of the kinds named (crm.activity_kind; a kind it does not have is refused), at most p_limit rows (50). Naming neither a contact nor a deal is refused, crm_bad_timeline. Needs crm.read.';

-- ---------------------------------------------------------------------------
-- Privileges, by name
-- ---------------------------------------------------------------------------

revoke execute on function crm.segment_tree(uuid) from public, anon;
revoke execute on function crm.board(uuid, uuid, boolean) from public, anon;
revoke execute on function crm.timeline(uuid, uuid, uuid, timestamptz, text[], integer) from public, anon;

grant execute on function crm.segment_tree(uuid) to authenticated, service_role;
grant execute on function crm.board(uuid, uuid, boolean) to authenticated, service_role;
grant execute on function crm.timeline(uuid, uuid, uuid, timestamptz, text[], integer) to authenticated, service_role;
