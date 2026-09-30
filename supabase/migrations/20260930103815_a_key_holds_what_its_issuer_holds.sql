-- Ekwo OS — a key holds what its issuer still holds.
--
-- `create_api_key()` has always refused to put on a key a capability the
-- person issuing it does not hold. It checked that once, at issuance. At use,
-- `has_capability()` looked at the key's own list and its company and at
-- nothing else, and no trigger on `company_members` ever touched `api_keys`.
-- So a key issued by somebody who then left the company, or lost a
-- capability, kept every capability it carried until somebody withdrew it by
-- hand — and nothing listed the keys of an installation against the people
-- who had issued them.
--
-- Three documents said the opposite: decision 0006, `docs/machine-access.md`
-- and the comment of `create_api_key()` itself. A guarantee that is written
-- down and not implemented is worse than one nobody claimed, because nobody
-- goes looking for the hole. This file makes the sentence true.
--
-- ---------------------------------------------------------------------------
-- The rule
-- ---------------------------------------------------------------------------
--
-- A key is a delegation from a person. At use, it holds a capability on a
-- company when
--
--   * the company is the key's company,
--   * the capability is on the key's list, and
--   * the person who issued it holds that capability on that company *now*.
--
-- The third condition is **computed at the moment of the call**, never kept
-- in a column a trigger maintains. A maintained state drifts: a role changes,
-- an adjustment is added to `capabilities_revoked`, a user is deleted from
-- `auth.users` and nothing fires. Working the answer out when it is asked is
-- already how this schema answers "which companies may I read" (decision
-- 0040), and it is the only form of the answer that cannot fall behind.
--
-- A key the installation issued itself — `created_by` null, because no
-- person was signed in — has no person to be bounded by, and is bounded by
-- its list alone. That is the same rule and not an exception to it: the
-- installation is who issued it, and the installation does not lose rights.
--
-- A key presented while issuing another no longer launders its issuer away.
-- `create_api_key()` used to record `auth.uid()`, which is null for a key, so
-- a key holding `members.manage` could mint a second key that looked like the
-- installation's own and was bounded by nothing but its list. The new key now
-- records the person behind the key that issued it.
--
-- ---------------------------------------------------------------------------
-- The bricks
-- ---------------------------------------------------------------------------
--
-- `member_holds(member, capability)` — whether one membership holds one
-- capability: revoked beats granted, granted beats the preset. It is the rule
-- `has_capability()` and `member_capabilities()` each wrote out for
-- themselves; both now call it, and so does the key path, so there is one
-- place where a person's rights are decided.
--
-- `key_holds(key, company, capability)` — whether one key holds one
-- capability on one company now: live, on that company, listed, and its
-- issuer's membership there answering `member_holds()` yes.
--
-- `api_key_on_company(company)` — whether the key presented in this
-- transaction reaches anything at all on that company. It replaces
-- `api_key_company()`, which answered with *the* company of the key: a single
-- value, which is a lie as soon as a key names more than one, and which said
-- "on the company" of a key whose issuer had left it.
--
-- `has_capability()`, `is_company_member()`, `is_any_company_member()`,
-- `is_known_caller()`, `installed_schema_version()` and `member_capabilities()`
-- are rewritten onto those. `companies_with_capability()` asks
-- `has_capability()` and follows without being touched.
--
-- ---------------------------------------------------------------------------
-- What a key really reaches, readable
-- ---------------------------------------------------------------------------
--
-- `api_key_reach`: one row per key and per capability on its list, saying
-- whether the key reaches it today. It calls `key_holds()`, the function
-- `has_capability()` calls, so the two cannot say different things.
-- `security_invoker`, so it shows exactly the keys `api_keys` shows the
-- reader — whoever holds `members.manage` on the company, and the instance
-- administrators — and never `key_hash`.
--
-- ---------------------------------------------------------------------------
-- What changes for an installation that upgrades
-- ---------------------------------------------------------------------------
--
-- No table changes. A key whose list is within what its issuer holds today
-- works as it did. A key whose issuer has since lost a capability stops
-- reaching that capability; a key whose issuer left the company, or whose
-- issuer's account is gone with memberships removed, stops reaching
-- anything. That is the point of the file. `ekwo doctor` lists those keys
-- under *keys beyond their issuer*, before and after the upgrade.

-- ---------------------------------------------------------------------------
-- member_holds
--
-- Invoker, no `set search_path`: it runs with the rights of whoever calls
-- it, and it is called from definer functions that already hold every right.
-- Qualified names instead of a search path, so that a caller's path cannot
-- redirect it. It reads `role_capabilities`, which any caller this
-- installation knows may read anyway.
--
-- **PL/pgSQL, and the numbers that chose it.** `has_capability()` is on the
-- path of every policy, so the brick it calls was measured on PGlite as 20 000
-- calls of `has_capability()` by a member, each with its own argument:
--
--     the rule written inside has_capability(), as before     about 200 ms
--     member_holds() in SQL                                    about 630 ms
--     member_holds() in PL/pgSQL                               about 240 ms
--
-- A SQL function whose body holds a sub-select is never inlined, and a SQL
-- function that is not inlined is parsed and planned again at every call of
-- the definer function around it. PL/pgSQL keeps its plan for the session.
-- Two microseconds a call, against one definition of a person's rights
-- instead of two: the second copy is what let the key path forget the issuer
-- in the first place. The six reads of `tests/load/` ask the question at most
-- a few dozen times each, since policies ask `companies_with_capability()`
-- once per statement (`20260918141627`), and do not move.
--
-- False and never NULL, whatever it is handed: `x = any(null)` is NULL, a
-- `case` skips a NULL branch, and `exists` is false.
-- ---------------------------------------------------------------------------

create or replace function member_holds(p_member company_members, p_capability text)
returns boolean
language plpgsql
stable
as $$
begin
  return case
           when p_capability = any (p_member.capabilities_revoked) then false
           when p_capability = any (p_member.capabilities_granted) then true
           else exists (
             select 1 from public.role_capabilities rc
              where rc.role = p_member.role and rc.capability = p_capability
           )
         end;
end;
$$;

comment on function member_holds(company_members, text) is
  'Whether one membership holds one capability: revoked beats granted, granted beats the preset. The one place a person''s rights on a company are decided — has_capability(), member_capabilities() and key_holds() all ask it. False, never NULL.';

-- ---------------------------------------------------------------------------
-- key_holds
--
-- Invoker and PL/pgSQL as well, for the same reasons. Called by
-- `has_capability()`, which is definer, it reads the issuer's membership with
-- every right; called by a reader of `api_key_reach`, it reads that
-- membership under the reader's own policies — and whoever may read a key of
-- a company (`members.manage` there, or an instance administrator) may read
-- the members of that company, so the answer is the same.
-- ---------------------------------------------------------------------------

create or replace function key_holds(p_key api_keys, p_company_id uuid, p_capability text)
returns boolean
language plpgsql
stable
as $$
begin
  return coalesce(
    p_key.company_id = p_company_id
    and p_capability = any (p_key.capabilities)
    and p_key.revoked_at is null
    and (p_key.expires_at is null or p_key.expires_at > now())
    and (
      -- Issued by the installation: bounded by its list alone.
      p_key.created_by is null
      -- Issued by a person: bounded by what that person holds there now. No
      -- membership, no answer, and `coalesce` makes that a no.
      or coalesce(
           (select public.member_holds(m, p_capability)
              from public.company_members m
             where m.company_id = p_company_id
               and m.user_id = p_key.created_by),
           false)
    ),
    false);
end;
$$;

comment on function key_holds(api_keys, uuid, text) is
  'Whether one machine key holds one capability on one company now: the key is live and on that company, the capability is on its list, and the person who issued it holds it there today (member_holds). A key the installation issued, created_by null, is bounded by its list alone. Worked out at the call, never stored.';

-- ---------------------------------------------------------------------------
-- has_capability
--
-- The member answer first, as before: presenting a key never takes away what
-- the signed-in person already had. Then the key, through `key_holds()`.
-- ---------------------------------------------------------------------------

create or replace function has_capability(p_company_id uuid, p_capability text)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select coalesce(
    (select member_holds(m, p_capability)
       from company_members m
      where m.company_id = p_company_id
        and m.user_id = auth.uid()),
    (select key_holds(k, p_company_id, p_capability)
       from api_keys k
      where k.key_hash = nullif(current_setting('ekwo.api_key', true), '')),
    false);
$$;

comment on function has_capability(uuid, text) is
  'Whether the current caller may do one named thing in one company — a signed-in member by their preset and their adjustments (member_holds), or a machine key by its own list and by what its issuer still holds there (key_holds). Revoked beats granted, a key is never wider than its issuer today, and a non-member holding no key holds nothing.';

-- ---------------------------------------------------------------------------
-- The key presented, on a company
--
-- "On" means it reaches at least one thing there. A key whose issuer left
-- the company reaches nothing, and so is not on it either: it does not keep
-- reading the company row, the members and the audit trail through
-- `is_company_member()` once every capability it carried is gone.
-- ---------------------------------------------------------------------------

create or replace function api_key_on_company(p_company_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1
      from api_keys k
     cross join lateral unnest(k.capabilities) as c(capability)
     where k.key_hash = nullif(current_setting('ekwo.api_key', true), '')
       and key_holds(k, p_company_id, c.capability)
  );
$$;

comment on function api_key_on_company(uuid) is
  'Whether the machine key presented in this transaction reaches anything on this company — at least one capability of its list that key_holds() still grants there. What is_company_member() asks for a key. False, never NULL, and false without a key.';

create or replace function is_company_member(p_company_id uuid)
returns boolean
language sql
stable
as $$
  -- `api_key_on_company()` answers false, never NULL, so the `or` does too.
  select company_role(p_company_id) is not null
      or api_key_on_company(p_company_id);
$$;

comment on function is_company_member(uuid) is
  'Whether the caller is on a company: a member of it, or the holder of a machine key that still reaches something there. False, never NULL, for a stranger.';

create or replace function is_any_company_member()
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (select 1 from company_members m where m.user_id = auth.uid())
      or exists (
           select 1 from api_keys k
            where k.key_hash = nullif(current_setting('ekwo.api_key', true), '')
              and api_key_on_company(k.company_id)
         );
$$;

comment on function is_any_company_member() is
  'Whether the caller belongs to at least one company of this installation, as a member or as the holder of a machine key that still reaches something on its company.';

-- A key that reaches nothing is not a caller this installation knows either:
-- it read the reference tables only because it was a key of somebody.
create or replace function is_known_caller()
returns boolean
language sql
stable
as $$
  select auth.uid() is not null or is_any_company_member();
$$;

comment on function is_known_caller() is
  'Whether this installation knows who is asking: a signed-in user, or the holder of a live machine key that still reaches something. What the policies of the reference tables ask.';

create or replace function installed_schema_version()
returns table (schema_version text, edition text)
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select i.schema_version, i.edition::text
    from instance i
   where i.id = 1
     and is_known_caller();
$$;

comment on function installed_schema_version() is
  'The schema version this installation runs, and its edition, for a caller it knows: a signed-in account that is on no company yet, or the holder of a machine key that still reaches something. No rows for anybody else, so an anonymous call learns nothing. Nothing else of the instance row comes with it.';

-- Its callers are the four functions above; nothing else named it.
drop function api_key_company();

-- ---------------------------------------------------------------------------
-- member_capabilities, on the same brick
-- ---------------------------------------------------------------------------

create or replace function member_capabilities(p_company_id uuid, p_user_id uuid default null)
returns setof text
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_user uuid := coalesce(p_user_id, auth.uid());
begin
  if v_user is distinct from auth.uid() and not has_capability(p_company_id, 'members.manage') then
    raise exception 'not_allowed: reading what another member may do needs members.manage'
      using errcode = '42501';
  end if;

  return query
    select c.code
      from capabilities c
      join company_members m
        on m.company_id = p_company_id and m.user_id = v_user
     where member_holds(m, c.code)
     order by c.code;
end;
$$;

-- ---------------------------------------------------------------------------
-- create_api_key: the person behind a key that issues a key
--
-- The body is the one of `20260913102115` with two changes: the comment
-- beside the ceiling says what the ceiling now is, and `created_by` is the
-- person behind the key presented when there is no session.
-- ---------------------------------------------------------------------------

create or replace function create_api_key(
  p_company_id   uuid,
  p_name         text,
  p_capabilities jsonb,
  p_expires_at   timestamptz default null
)
returns table (api_key_id uuid, secret text, prefix text, expires_at timestamptz)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_caps   text[] := coalesce(
    (select array_agg(value) from jsonb_array_elements_text(coalesce(p_capabilities, '[]'::jsonb)) as value),
    '{}');
  v_prefix text := left(replace(gen_random_uuid()::text, '-', ''), 12);
  v_secret text;
  v_cap    text;
  v_row    api_keys%rowtype;
  v_issuer uuid := coalesce(auth.uid(), (current_api_key()).created_by);
begin
  if not is_installer() and not has_capability(p_company_id, 'members.manage') then
    raise exception 'not_allowed: issuing a key for this company needs members.manage'
      using errcode = '42501';
  end if;

  if cardinality(v_caps) = 0 then
    raise exception 'api_key_without_capability: name what this key may do; a key that may do nothing is a secret to look after for no reason';
  end if;

  foreach v_cap in array v_caps loop
    if v_cap not in (select code from capabilities) then
      raise exception 'unknown_capability: % is not a capability of this installation', v_cap;
    end if;
    -- Nobody mints a key stronger than they are, and this is only the first
    -- time it is checked. At every use `key_holds()` asks again whether the
    -- issuer still holds the capability, so a capability withdrawn from a
    -- person is withdrawn from the keys they issued.
    if not is_installer() and not has_capability(p_company_id, v_cap) then
      raise exception 'not_allowed: you do not hold % yourself, so you cannot put it on a key', v_cap
        using errcode = '42501';
    end if;
  end loop;

  v_secret := 'ekwo_' || v_prefix || '_' ||
              replace(gen_random_uuid()::text, '-', '') ||
              replace(gen_random_uuid()::text, '-', '');

  insert into api_keys (company_id, name, prefix, key_hash, capabilities, created_by, expires_at)
  values (p_company_id, p_name, v_prefix,
          encode(sha256(convert_to(v_secret, 'UTF8')), 'hex'),
          v_caps, v_issuer, p_expires_at)
  returning * into v_row;

  return query select v_row.id, v_secret, v_row.prefix, v_row.expires_at;
end;
$$;

comment on function create_api_key(uuid, text, jsonb, timestamptz) is
  'Issues a machine key on one company and returns the secret once. Only the hash is stored. No capability can be put on a key that the person issuing it does not hold, and at every use the key holds only what that person still holds (key_holds). A key issued while another key is presented records the person behind that key.';

comment on column api_keys.created_by is
  'auth.users.id of the person the key is a delegation from: whoever issued it, or the person behind the key that issued it. Null for a key the installation issued itself. The key never holds more than this person holds today. No foreign key, for the same reason company_members has none.';

comment on table api_keys is
  'Machine access to one company. Hashed at rest, scoped to an explicit list of capabilities, and never wider than the person who issued it — at issuance and at every use.';

-- ---------------------------------------------------------------------------
-- api_key_reach
-- ---------------------------------------------------------------------------

create or replace view api_key_reach
with (security_invoker = true) as
select k.id           as api_key_id,
       k.company_id,
       k.name,
       k.prefix,
       k.created_by,
       c.capability,
       key_holds(k, k.company_id, c.capability) as reaches
  from api_keys k
 cross join lateral unnest(k.capabilities) as c(capability);

comment on view api_key_reach is
  'What each machine key really reaches: one row per key, company and capability on its list, and whether key_holds() — the function has_capability() asks — grants it today. False for a key withdrawn or expired, and for a capability its issuer no longer holds. Shows the keys api_keys shows the reader, and never the hash.';
comment on column api_key_reach.reaches is
  'Whether the key holds this capability on this company now. When false on a live key, the person who issued it no longer holds it there.';

-- ---------------------------------------------------------------------------
-- Grants
-- ---------------------------------------------------------------------------

revoke execute on all functions in schema public from public;

-- The two bricks are read by the view as its reader, so a signed-in user
-- executes them; `anon` reaches them only through definer functions.
revoke execute on function member_holds(company_members, text)  from public, anon;
revoke execute on function key_holds(api_keys, uuid, text)      from public, anon;
grant  execute on function member_holds(company_members, text)  to authenticated, service_role;
grant  execute on function key_holds(api_keys, uuid, text)      to authenticated, service_role;

-- A policy helper in place of `api_key_company()`: `is_company_member()`
-- calls it, and `anon` evaluates that on behalf of a policy. Without a key
-- presented it answers false.
revoke execute on function api_key_on_company(uuid) from public;
grant  execute on function api_key_on_company(uuid) to anon, authenticated, service_role;

grant select on api_key_reach to authenticated, service_role;
