-- Ekwo OS, module tax — a row names rows of its own company, by one key.
--
-- A declaration, an adjustment, a credit and a computation name a financial year, and a use of a loss names the loss. Until this file each named it by its id alone, so a row of one
-- company could name a row of another — on a shared installation (decision
-- 0065), a stranger's id was accepted or refused depending on whether it
-- existed, and a reference planted that way could keep the other company from
-- deleting its own row. Where a composite key with `company_id` already stood
-- beside the single one, an id of another company and an id of nobody failed
-- under two different names.
--
-- `scope_references_to_company()`, which the socle migration `20261007113412`
-- adds and runs on `public`, does the same here: every such reference of the
-- `tax` schema becomes a composite key with `company_id`, keeping what
-- it did on delete, and the single-column key goes. The references are read
-- from the catalogue, not listed, so none is forgotten.
--
-- `requires_socle_min` names the socle this module was first built on, and
-- every migration of a module must sort after it, so the work cannot move to
-- the socle file above. `ekwo migrate` applies the socle before the modules;
-- a database that somehow lacks the function is told so by name.

do $$
begin
  if to_regprocedure('public.scope_references_to_company(text)') is null then
    raise exception 'socle_too_old: the tax module needs socle migration 20261007113412 (scope_references_to_company). Run ekwo migrate first.';
  end if;
  perform public.scope_references_to_company('tax');
end;
$$;
