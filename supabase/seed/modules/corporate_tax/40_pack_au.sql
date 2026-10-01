-- Ekwo OS — Australia: the rules of this country's corporate income tax.
--
-- Generated from packs/au/corporate_tax.json at version 0.3.0, do not edit.
-- Change the pack and run `ekwo pack build au`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Applied by the module migration runner — `ekwo migrate`, or `ekwo module
-- migrate` — and never by the socle seed step: these tables exist only on an
-- installation that carries the corporate income tax module.
--
-- Reference data: read where it stands, never copied into a company. A figure
-- that changes is a new row with a new valid_from, so a past year keeps its answer.

insert into tax.country_rules
  (country, tax_code, name, name_i18n, result_statement_code, result_line_code, result_legal_reference, result_source_key, expense_account_code, payable_account_code, receivable_account_code, accounts_legal_reference, accounts_source_key, legal_reference, source_key)
values
  ('AU', 'AU-CIT', 'Company income tax', '{}'::jsonb, 'AU-AASB1060-PL', '8', 'AASB 1060, paragraph 35 — the income statement of the pack prints line 8, « Profit before income tax », before the income tax expense of line 9. The computation starts from that line, so the income tax expense booked on account 8000 to 8020 never enters it and needs no add-back.', 'aasb-1060', '8000', '2300', '1350', 'There is no legal chart of accounts in Australia (Corporations Act 2001, s. 286 prescribes none); these are accounts of the reference chart of this pack: 8000 « Income tax expense — current », 2300 « Income tax payable » and 1350 « Income tax refundable ».', 'corporations-act', 'Income Tax Rates Act 1986, s. 23 — the rates of tax payable by a company on its taxable income; Income Tax Assessment Act 1997 — taxable income of a corporate tax entity', 'itra-1986')
on conflict (country) do update set
  tax_code                 = excluded.tax_code,
  name                     = excluded.name,
  name_i18n                = excluded.name_i18n,
  result_statement_code    = excluded.result_statement_code,
  result_line_code         = excluded.result_line_code,
  result_legal_reference   = excluded.result_legal_reference,
  result_source_key        = excluded.result_source_key,
  expense_account_code     = excluded.expense_account_code,
  payable_account_code     = excluded.payable_account_code,
  receivable_account_code  = excluded.receivable_account_code,
  accounts_legal_reference = excluded.accounts_legal_reference,
  accounts_source_key      = excluded.accounts_source_key,
  legal_reference          = excluded.legal_reference,
  source_key               = excluded.source_key;

insert into tax.parameter_templates
  (country, code, name, name_i18n, value_type, legal_reference, source_key, sequence)
values
  ('AU', 'aggregated_turnover', 'Aggregated turnover of the company for the income year, worked out as at the end of that year, including the turnover of connected entities and affiliates', '{}'::jsonb, 'amount'::tax.parameter_type, 'Income Tax Rates Act 1986, s. 23AA(b) — aggregated turnover, within the meaning of the Income Tax Assessment Act 1997, for the year of income, worked out as at the end of that year', 'itra-1986', 10),
  ('AU', 'passive_income_percent', 'Share, in percent, of the assessable income of the year that is base rate entity passive income (distributions, franking credits, non-share dividends, interest, royalties, rent, gains on qualifying securities, net capital gains and the trust and partnership amounts referable to them)', '{}'::jsonb, 'amount'::tax.parameter_type, 'Income Tax Rates Act 1986, s. 23AA(a) and s. 23AB — base rate entity passive income, with its exceptions for entities that lend or provide finance commercially', 'itra-1986', 20)
on conflict (country, code) do update set
  name            = excluded.name,
  name_i18n       = excluded.name_i18n,
  value_type      = excluded.value_type,
  legal_reference = excluded.legal_reference,
  source_key      = excluded.source_key,
  sequence        = excluded.sequence;

insert into tax.adjustment_rule_templates
  (country, code, valid_from, valid_to, valid_on, name, name_i18n, direction, percent, formula, account_rules, legal_reference, source_key, sequence)
values
  ('AU', 'entertainment', date '2025-01-01', null, 'period_end'::tax.validity_basis, 'Entertainment — food, drink, recreation and the travel or accommodation that goes with it', '{}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'Income Tax Assessment Act 1997, s. 32-5 — to the extent that a loss or outgoing is incurred in providing entertainment, it cannot be deducted under s. 8-1, subject to the exceptions of Subdivision 32-B; s. 32-10 — what entertainment is. The company states the amount that falls under the rule, net of what an exception covers.', 'itaa-1997-c256-v1', 10),
  ('AU', 'penalties', date '2025-01-01', null, 'period_end'::tax.validity_basis, 'Penalties and amounts ordered by a court on conviction', '{}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'Income Tax Assessment Act 1997, s. 26-5(1) — an amount payable by way of penalty under an Australian or a foreign law, and an amount ordered by a court on conviction for an offence, cannot be deducted; s. 26-5(2) — except a penalty under Subdivision 162-D of the GST Act. The reference chart carries no account of penalties alone, so the company states the amount.', 'itaa-1997-c256-v1', 20)
on conflict (country, code, valid_from) do update set
  valid_to        = excluded.valid_to,
  valid_on        = excluded.valid_on,
  name            = excluded.name,
  name_i18n       = excluded.name_i18n,
  direction       = excluded.direction,
  percent         = excluded.percent,
  formula         = excluded.formula,
  account_rules   = excluded.account_rules,
  legal_reference = excluded.legal_reference,
  source_key      = excluded.source_key,
  sequence        = excluded.sequence;

insert into tax.rate_templates
  (country, code, valid_from, valid_to, valid_on, name, name_i18n, rate, up_to, up_to_prorata, conditions, legal_reference, source_key, sequence)
values
  ('AU', 'base-rate-entity', date '2024-07-01', null, 'period_start'::tax.validity_basis, 'Base rate entity rate', '{}'::jsonb, 25, null, 'none', '[{"amount":50000000,"parameter":"aggregated_turnover","test":"below"},{"amount":80,"parameter":"passive_income_percent","test":"at_most"}]'::jsonb, 'Income Tax Rates Act 1986, s. 23(2)(a) — 25 % where the company is a base rate entity for the year of income; s. 23AA — a base rate entity has no more than 80 % of its assessable income as base rate entity passive income and an aggregated turnover for the year, worked out as at the end of it, of less than $50 million', 'itra-1986', 10),
  ('AU', 'standard', date '2024-07-01', null, 'period_start'::tax.validity_basis, 'Company rate', '{}'::jsonb, 30, null, 'none', '[]'::jsonb, 'Income Tax Rates Act 1986, s. 23(2)(b) — 30 % for a company that is not a base rate entity for the year of income', 'itra-1986', 20)
on conflict (country, code, valid_from) do update set
  valid_to        = excluded.valid_to,
  valid_on        = excluded.valid_on,
  name            = excluded.name,
  name_i18n       = excluded.name_i18n,
  rate            = excluded.rate,
  up_to           = excluded.up_to,
  up_to_prorata   = excluded.up_to_prorata,
  conditions      = excluded.conditions,
  legal_reference = excluded.legal_reference,
  source_key      = excluded.source_key,
  sequence        = excluded.sequence;

insert into tax.loss_rule_templates
  (country, valid_from, valid_to, valid_on, floor_amount, percent_above, carry_forward_years, legal_reference, source_key)
values
  ('AU', date '2025-01-01', null, 'period_end'::tax.validity_basis, null, null, null, 'Income Tax Assessment Act 1997, s. 36-17(2) — a corporate tax entity deducts from the excess of assessable income over deductions so much of the tax loss of an earlier loss year as it chooses; the section sets no limit on the amount or on the number of years. Subject to s. 165-10 (read with s. 165-12 and s. 165-13): the company must keep the same owners or satisfy the business continuity test, which this pack does not compute.', 'itaa-1997-c256-v1')
on conflict (country, valid_from) do update set
  valid_to            = excluded.valid_to,
  valid_on            = excluded.valid_on,
  floor_amount        = excluded.floor_amount,
  percent_above       = excluded.percent_above,
  carry_forward_years = excluded.carry_forward_years,
  legal_reference     = excluded.legal_reference,
  source_key          = excluded.source_key;
