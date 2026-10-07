-- ---------------------------------------------------------------------------
-- A person joins a company of their own accord
-- ---------------------------------------------------------------------------
-- `company_members.user_id` carries no foreign key, on purpose: a membership
-- may be written before its person signs up (decision 0007). Whoever holds
-- `members.manage` on a company could therefore write any id into it, and so
-- add any person to their company — without asking them — or move a
-- membership to somebody else by rewriting `user_id`. On an installation that
-- is one customer's, every account is that customer's, and an owner adding a
-- colleague directly is the documented way to staff a company (0004, 0007).
-- On a shared one it is a stranger enrolling a stranger: the person added
-- reads, under that company's name, whatever it shows them, and never agreed
-- to be there.
--
-- So on a shared installation (decision 0065) a membership is written by its
-- own person, in their own session — which is what `accept_invitation()` does
-- for the invitee and `create_company()` for the creator — or by the
-- installer or an instance administrator. A membership is never handed to
-- another person or moved to another company. The refusal comes before
-- anything else is asked, so a person who has an account and an id nobody
-- holds are answered alike.
--
-- An installation that is not shared is unchanged.
-- ---------------------------------------------------------------------------

create or replace function company_members_join_of_their_own_accord()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if not instance_is_shared() or is_installer() or is_instance_admin() then
    return new;
  end if;

  if tg_op = 'UPDATE' then
    if new.user_id is distinct from old.user_id or new.company_id is distinct from old.company_id then
      raise exception 'not_allowed: on a shared installation a membership stays the one its person accepted, in the company they accepted it in. Invite the other person instead.'
        using errcode = '42501';
    end if;
    return new;
  end if;

  if auth.uid() is null
     or nullif(current_setting('ekwo.api_key', true), '') is not null
     or new.user_id is distinct from auth.uid() then
    raise exception 'not_allowed: on a shared installation a person joins a company by accepting an invitation, or by creating it, and nobody adds somebody else. Invite them with invite_member().'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

comment on function company_members_join_of_their_own_accord() is
  'On a shared installation, refuses a membership written for anybody but the signed-in person writing it — accept_invitation() and create_company() write the caller''s own — and any change of who or which company a membership is for; the installer and an instance administrator excepted. One answer whether the person named has an account or not. Unchanged on an installation that is not shared (decision 0065).';

drop trigger if exists company_members_join_of_their_own_accord on company_members;
create trigger company_members_join_of_their_own_accord
  before insert or update of user_id, company_id on company_members
  for each row execute function company_members_join_of_their_own_accord();

revoke execute on function company_members_join_of_their_own_accord() from public, anon, authenticated, service_role;
