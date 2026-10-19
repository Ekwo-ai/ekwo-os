-- Ekwo OS, module assets — an asset and a disposal name no merged contact.
--
-- `merge_contacts()` (socle migration `20261019090000`, decision 0074) moves
-- every reference of an absorbed contact onto the contact it is merged into,
-- this module's among them, read from the foreign keys. What it cannot do from
-- the socle is refuse a row of this schema written to name the absorbed
-- contact afterwards: the socle's migration runs before this schema exists.
-- `refuse_merged_contacts_in()` attaches that refusal to every column of a
-- schema that references `contacts`, as `scope_references_to_company()` did
-- for the keys; here it is run on `fixed_assets`.

do $$
begin
  if to_regprocedure('public.refuse_merged_contacts_in(text)') is null then
    raise exception 'socle_too_old: the assets module needs socle migration 20261019090000 (refuse_merged_contacts_in). Run ekwo migrate first.';
  end if;
  perform public.refuse_merged_contacts_in('fixed_assets');
end;
$$;
