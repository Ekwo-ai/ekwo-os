-- Ekwo OS — a contact names the territory it is in, within its country.
--
-- `contacts.territory_code` arrived with `20260916125000` so that a tax could
-- follow the territory of the parties: on a purchase the contact is the
-- seller, on a sale it is the buyer, and `document_territory()` reads
-- its territory before its country. `20261121070100` let a company name its
-- own territory and held it within the company's country with a trigger;
-- the contact had no such rule, and no route a person takes wrote the
-- column. The command line and the MCP server now write it, at creation and
-- afterwards, so the rule the company has is given to the contact too.
--
-- A trigger refuses a territory that does not lie within the contact's
-- country (`territory_outside_country`), on insert and whenever either
-- column changes: a supplier in `FR` cannot be said to be in `US-CA`, and a
-- contact in `US-CA` cannot be moved to `FR` while it still says so. A
-- contact with no country is not held to one: its territory is then the
-- whole answer, as the resolution already reads it. Nothing is required —
-- a contact without a territory resolves to its country, as before.
--
-- Rows already written are not touched; the rule applies to what is written
-- from now on. Additive: one function, one trigger.

set search_path = ekwo, pg_temp;

create or replace function ekwo.contacts_territory_within_country()
returns trigger
language plpgsql
set search_path = ekwo, pg_temp
as $$
begin
  if new.territory_code is not null
     and new.country is not null
     and not territory_within(new.territory_code, new.country) then
    raise exception 'territory_outside_country: % is not a territory of %', new.territory_code, new.country
      using errcode = '22023';
  end if;
  return new;
end;
$$;

comment on function ekwo.contacts_territory_within_country() is
  'Refuses a contacts.territory_code that does not lie within the contact''s country, on insert and whenever either column changes. A contact with no country is not held to one, and none is required: a contact without a territory resolves to its country.';

drop trigger if exists contacts_territory_within_country on ekwo.contacts;
create trigger contacts_territory_within_country
  before insert or update of territory_code, country on ekwo.contacts
  for each row execute function ekwo.contacts_territory_within_country();

-- The revoke every file of this directory ends with.
revoke execute on all functions in schema ekwo from public;

notify pgrst, 'reload schema';
