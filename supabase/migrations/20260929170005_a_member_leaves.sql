-- ---------------------------------------------------------------------------
-- A member leaves, or changes seat
-- ---------------------------------------------------------------------------
--
-- `20260913083901` gave membership its way in: `invite_member()`,
-- `accept_invitation()`, and `revoke_invitation()` for an invitation nobody
-- took up. It gave it no way out. `revoke_invitation()` answers an accepted
-- invitation with "remove the member instead", and nothing did that except a
-- hand-written `delete from company_members` — which the policy of that table
-- allows to whoever holds `members.manage`, and which checks nothing else. A
-- company could be left with nobody able to administer it, by a click.
--
-- Three functions, written like their neighbours: `security definer`, the
-- caller checked on the first line, a refusal named and prefixed.
--
-- * `remove_member(company, user)` takes somebody out of a company. It needs
--   `members.manage`, except for one's own seat: leaving a company is not
--   administering it, and a viewer who wants to go should not have to ask.
-- * `set_member_role(company, user, role, capabilities)` moves a member to
--   another preset. It needs `members.manage`.
-- * `company_members_list(company)` reads the members of a company with the
--   address each one signed up with. `company_members` holds a user id and no
--   address, `auth.users` is out of reach of a client, and nothing else of the
--   schema joins the two.
--
-- **A company always keeps an owner.** Neither function lets the last member
-- on the `owner` preset go, whether by removal or by demotion — the owner
-- themself included. Whoever wants to hand a company over promotes the
-- successor first. The owners of the company are locked while they are
-- counted, so two owners removing each other in two concurrent transactions
-- cannot both be told they were not the last.
--
-- **What the audit trail records** is what it records for an invitation: the
-- row change, written by `company_members_audit` (`20260914103412`) with the
-- caller as actor — a delete carrying the row that left, an update carrying
-- the preset and the adjustments before and after. The functions add no
-- second line for the same act.
--
-- **The direct path stays open.** The policies of `company_members` still let
-- a holder of `members.manage` delete or update a row by hand, as they did
-- before this file; closing them is a change to what a client may do, and
-- belongs to a file of its own.
-- ---------------------------------------------------------------------------

create or replace function remove_member(p_company_id uuid, p_user_id uuid)
returns company_members
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_row    company_members%rowtype;
  v_owners integer;
begin
  if not is_installer()
     and p_user_id is distinct from auth.uid()
     and not has_capability(p_company_id, 'members.manage')
     and not is_instance_admin() then
    raise exception 'not_allowed: removing somebody from this company needs members.manage'
      using errcode = '42501';
  end if;

  select * into v_row
    from company_members
   where company_id = p_company_id and user_id = p_user_id
     for update;
  if v_row.user_id is null then
    raise exception 'unknown_member: % is not a member of this company', p_user_id
      using errcode = 'P0002';
  end if;

  if v_row.role = 'owner' then
    perform 1 from company_members
      where company_id = p_company_id and role = 'owner'
        for update;
    select count(*) into v_owners
      from company_members
     where company_id = p_company_id and role = 'owner';
    if v_owners <= 1 then
      raise exception 'last_owner: % is the last owner of this company; make somebody else owner first', p_user_id
        using errcode = '55006';
    end if;
  end if;

  delete from company_members
   where company_id = p_company_id and user_id = p_user_id;

  return v_row;
end;
$$;

comment on function remove_member(uuid, uuid) is
  'Takes a member out of a company and returns the row that left. Needs members.manage, except to leave oneself. The last owner of a company is refused, themself included: promote a successor first. Pending invitations are not touched; revoke_invitation() withdraws them.';

-- ---------------------------------------------------------------------------
-- Changing the preset
--
-- **The adjustments follow the act, not the member.** A capability granted or
-- revoked on one member was decided against the preset they were on: an
-- accountant given `members.manage`, an owner kept from closing a year.
-- Carried over to another preset, it becomes a right nobody decided — the
-- demoted accountant still manages members. So a role change writes the
-- member the way `accept_invitation()` writes a new one, the preset and the
-- grants given with it, nothing else: `capabilities_granted` becomes
-- `p_capabilities` (none by default, the same JSON list `invite_member()`
-- takes) and `capabilities_revoked` is emptied. The answer is the row as it
-- now stands, so the caller sees what the member holds.
-- ---------------------------------------------------------------------------

create or replace function set_member_role(
  p_company_id   uuid,
  p_user_id      uuid,
  p_role         member_role,
  p_capabilities jsonb default '[]'::jsonb
)
returns company_members
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_row     company_members%rowtype;
  v_owners  integer;
  v_unknown text;
  v_caps    text[] := coalesce(
    (select array_agg(value) from jsonb_array_elements_text(coalesce(p_capabilities, '[]'::jsonb)) as value),
    '{}');
begin
  if not is_installer() and not has_capability(p_company_id, 'members.manage')
     and not is_instance_admin() then
    raise exception 'not_allowed: changing the role of a member of this company needs members.manage'
      using errcode = '42501';
  end if;

  if p_role is null or p_role = 'instance_admin' then
    raise exception 'bad_role: % is not a role within a company', coalesce(p_role::text, 'null');
  end if;

  select c into v_unknown
    from unnest(v_caps) as c
   where c not in (select code from capabilities)
   limit 1;
  if v_unknown is not null then
    raise exception 'unknown_capability: % is not a capability of this installation', v_unknown;
  end if;

  select * into v_row
    from company_members
   where company_id = p_company_id and user_id = p_user_id
     for update;
  if v_row.user_id is null then
    raise exception 'unknown_member: % is not a member of this company', p_user_id
      using errcode = 'P0002';
  end if;

  if v_row.role = 'owner' and p_role <> 'owner' then
    perform 1 from company_members
      where company_id = p_company_id and role = 'owner'
        for update;
    select count(*) into v_owners
      from company_members
     where company_id = p_company_id and role = 'owner';
    if v_owners <= 1 then
      raise exception 'last_owner: % is the last owner of this company; make somebody else owner first', p_user_id
        using errcode = '55006';
    end if;
  end if;

  update company_members
     set role = p_role,
         capabilities_granted = v_caps,
         capabilities_revoked = '{}'
   where company_id = p_company_id and user_id = p_user_id
  returning * into v_row;

  return v_row;
end;
$$;

comment on function set_member_role(uuid, uuid, member_role, jsonb) is
  'Moves a member to another preset. Needs members.manage; the last owner of a company is not demoted. The per-member adjustments are reset, as accept_invitation() writes a new member: capabilities_granted becomes p_capabilities (none by default) and capabilities_revoked is emptied, because an adjustment was decided against the preset the member leaves.';

-- ---------------------------------------------------------------------------
-- Reading who is on a company
--
-- The address comes from `auth.users` of the customer's own Supabase Auth,
-- which is why this is definer. A member who has not got an account any more
-- is listed with no address: `ekwo doctor` reports that orphan, and this
-- function does not hide it. What a member effectively holds, preset and
-- adjustments resolved, stays the answer of `member_capabilities()`; this
-- returns the adjustments as they are stored.
-- ---------------------------------------------------------------------------

create or replace function company_members_list(p_company_id uuid)
returns table (
  user_id              uuid,
  email                text,
  role                 member_role,
  capabilities_granted text[],
  capabilities_revoked text[],
  joined_at            timestamptz
)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
begin
  if not is_installer() and not has_capability(p_company_id, 'members.manage')
     and not is_instance_admin() then
    raise exception 'not_allowed: listing the members of this company with their addresses needs members.manage'
      using errcode = '42501';
  end if;

  return query
    select m.user_id, u.email::text, m.role, m.capabilities_granted, m.capabilities_revoked,
           m.created_at
      from company_members m
      left join auth.users u on u.id = m.user_id
     where m.company_id = p_company_id
     order by m.created_at, m.user_id;
end;
$$;

comment on function company_members_list(uuid) is
  'The members of a company with the address each signed up with, their preset, their stored adjustments and when they joined. Needs members.manage. An address is null for a member whose account is gone.';

-- ---------------------------------------------------------------------------
-- Grants
-- ---------------------------------------------------------------------------

revoke execute on all functions in schema public from public;

revoke execute on function remove_member(uuid, uuid) from public, anon;
grant execute on function remove_member(uuid, uuid) to authenticated, service_role;

revoke execute on function set_member_role(uuid, uuid, member_role, jsonb) from public, anon;
grant execute on function set_member_role(uuid, uuid, member_role, jsonb) to authenticated, service_role;

revoke execute on function company_members_list(uuid) from public, anon;
grant execute on function company_members_list(uuid) to authenticated, service_role;
