-- Ekwo module `assets` — its reference tables answer the same caller the
-- socle's do.
--
-- `assets.country_rules` and `assets.category_templates` are reference data of
-- the module: the depreciation rules a country allows, and the categories a
-- register starts from. Their policy is the sentence the socle used everywhere
-- before `20260922162500` — `auth.uid() is not null`, which reads "somebody
-- signed in" — and the socle has since replaced it with what it was reaching
-- for: `is_known_caller()`, a signed-in user or the holder of a live machine
-- key.
--
-- A module does not get to answer that question differently. A key that may
-- read the register and cannot read the rules the register is built on reads
-- half a module, and the half it is missing is the half that explains the
-- other. The company's own rows are untouched: they keep asking
-- `has_capability()` and `module_enabled()`, as they did.

drop policy assets_country_rules_select on assets.country_rules;
create policy assets_country_rules_select on assets.country_rules
  for select using (public.is_known_caller());

drop policy assets_category_templates_select on assets.category_templates;
create policy assets_category_templates_select on assets.category_templates
  for select using (public.is_known_caller());
