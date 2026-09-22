-- Ekwo OS — reference data is for a caller this installation knows.
--
-- Eighteen tables of the socle carry the reference data every reading depends
-- on: the currencies and their rates, the charts of accounts and their
-- templates, the taxes and where they post, the boxes of the declaration
-- forms, the financial statement schemes, the legal mentions, the territories,
-- the modules, and the list of capabilities itself. None of them belongs to a
-- company. Their policy has always been the same sentence — `auth.uid() is not
-- null` — which reads "somebody signed in", and was the right sentence while
-- the only caller this installation had was a person.
--
-- `20260922160000` gave it a second kind of caller. A machine key now reaches
-- the API, arrives as `authenticated` and is on its own company, and every
-- policy that asks a capability follows. These eighteen ask none: they ask for
-- a session, and a key is not a session, so they answered no — and a caller
-- that cannot read `modules` cannot even be told which tables an archive
-- carries, which is how `export_company()` was still refusing a key that held
-- `company.export`. The refusal was not about the company's data at all. It
-- was about a list of module codes.
--
-- So the sentence is replaced by what it was always reaching for, in one
-- helper that every one of them now calls:
--
--     is_known_caller() — a signed-in user, or the holder of a live key.
--
-- Nothing else changes. These tables hold no customer data: a chart of
-- accounts and a currency are the same rows on every installation, which is
-- why the seed writes them and nobody may. What widens is who may read what
-- the installation already publishes to every person signed into it, and the
-- set of callers grows by exactly one: somebody holding a key this
-- installation minted, which is a stronger claim than having signed up.
--
-- `anon` is untouched and still reads none of them: `is_known_caller()`
-- answers false without a session and without a key, which is the same word
-- `auth.uid() is not null` gave it.
--
-- The two reference tables of the assets module are the same question in a
-- module's schema, and are moved in the module's own migration, where they
-- belong.

create or replace function is_known_caller()
returns boolean
language sql
stable
as $$
  select auth.uid() is not null or api_key_company() is not null;
$$;

comment on function is_known_caller() is
  'Whether this installation knows who is asking: a signed-in user, or the holder of a live machine key. What the policies of the reference tables ask, in place of the `auth.uid() is not null` they asked while a person was the only caller.';

drop policy account_templates_select on account_templates;
create policy account_templates_select on account_templates
  for select using (is_known_caller());

drop policy capabilities_select on capabilities;
create policy capabilities_select on capabilities
  for select using (is_known_caller());

drop policy chart_templates_select on chart_templates;
create policy chart_templates_select on chart_templates
  for select using (is_known_caller());

drop policy country_defaults_select on country_defaults;
create policy country_defaults_select on country_defaults
  for select using (is_known_caller());

drop policy currencies_select on currencies;
create policy currencies_select on currencies
  for select using (is_known_caller());

drop policy currency_rates_select on currency_rates;
create policy currency_rates_select on currency_rates
  for select using (is_known_caller());

drop policy journal_templates_select on journal_templates;
create policy journal_templates_select on journal_templates
  for select using (is_known_caller());

drop policy legal_mention_templates_select on legal_mention_templates;
create policy legal_mention_templates_select on legal_mention_templates
  for select using (is_known_caller());

drop policy modules_select on modules;
create policy modules_select on modules
  for select using (is_known_caller());

drop policy role_capabilities_select on role_capabilities;
create policy role_capabilities_select on role_capabilities
  for select using (is_known_caller());

drop policy statement_line_rules_select on statement_line_rules;
create policy statement_line_rules_select on statement_line_rules
  for select using (is_known_caller());

drop policy statement_line_templates_select on statement_line_templates;
create policy statement_line_templates_select on statement_line_templates
  for select using (is_known_caller());

drop policy statement_templates_select on statement_templates;
create policy statement_templates_select on statement_templates
  for select using (is_known_caller());

drop policy tax_posting_templates_select on tax_posting_templates;
create policy tax_posting_templates_select on tax_posting_templates
  for select using (is_known_caller());

drop policy tax_report_box_templates_select on tax_report_box_templates;
create policy tax_report_box_templates_select on tax_report_box_templates
  for select using (is_known_caller());

drop policy tax_report_templates_select on tax_report_templates;
create policy tax_report_templates_select on tax_report_templates
  for select using (is_known_caller());

drop policy tax_templates_select on tax_templates;
create policy tax_templates_select on tax_templates
  for select using (is_known_caller());

drop policy territories_select on territories;
create policy territories_select on territories
  for select using (is_known_caller());

revoke execute on all functions in schema public from public;

revoke execute on function is_known_caller() from public;
grant execute on function is_known_caller() to anon, authenticated, service_role;
