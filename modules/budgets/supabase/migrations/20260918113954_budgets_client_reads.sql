-- Ekwo module `budgets` — the client preset reads this module too.
--
-- The socle's `client` preset holds what `viewer` holds, and it was filled
-- from `role_capabilities` when the socle's migration ran: on an installation
-- that already carried this module, `budgets.read` was copied then. On a fresh
-- one the socle is applied before any module, so the row has to come from
-- here.
--
-- The label is read from the catalogue rather than written as a literal. A
-- module may be applied on a socle older than the preset, where
-- `'client'::member_role` does not parse; there this inserts nothing, and the
-- socle's migration copies the row the day it arrives.

insert into public.role_capabilities (role, capability)
select e.enumlabel::text::public.member_role, 'budgets.read'
  from pg_catalog.pg_enum e
  join pg_catalog.pg_type t on t.oid = e.enumtypid
  join pg_catalog.pg_namespace n on n.oid = t.typnamespace
 where n.nspname = 'public' and t.typname = 'member_role' and e.enumlabel = 'client'
on conflict do nothing;
