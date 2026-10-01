-- Ekwo OS — Nigeria: the rules of this country's corporate income tax.
--
-- Generated from packs/ng/corporate_tax.json at version 0.2.0, do not edit.
-- Change the pack and run `ekwo pack build ng`; `ekwo pack check --all`
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
  ('NG', 'NG-CIT', 'Companies income tax', '{}'::jsonb, 'NG-CAMA-IS', 'PBT', 'Companies and Allied Matters Act 2020, First Schedule, Section C, Profit and Loss Account Format 1 — the profit or loss on ordinary activities before taxation, which items 13 and 14 are computed from; Nigeria Tax Act 2025, s. 21(e) — a deduction is not allowed for taxes on profit or income levied in Nigeria or elsewhere, so the computation starts before the tax charge, which this chart books on accounts 8200 to 8300 below the line', 'nta-2025', '8200', '2310', '1160', 'The chart is the pack''s own (there is no legal chart of accounts in Nigeria): 8200 is the Companies Income Tax charge, item 13 of the Profit and Loss Account Format 1 of the First Schedule to the Companies and Allied Matters Act 2020, 2310 the Companies Income Tax payable and 1160 the Companies Income Tax recoverable', 'cama-2020', 'Nigeria Tax Act 2025 (Act No. 7 of 2025), Chapter Two — taxation of income of persons, and Part IX, s. 56: tax is levied for each year of assessment on the total profits of every company; the Act commenced on 1 January 2026 and repealed the Companies Income Tax Act, Cap. C21, LFN 2004 (s. 195(c))', 'nta-2025')
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
  ('NG', 'gross_turnover', 'Gross turnover of the financial year, restated to twelve months where the year is shorter or longer', '{}'::jsonb, 'amount'::tax.parameter_type, 'Nigeria Tax Act 2025, s. 202 (interpretation) — "small company": a business that earns gross turnover of N100,000,000 or less per annum with total fixed assets not exceeding N250,000,000', 'nta-2025', 10),
  ('NG', 'total_fixed_assets', 'Total fixed assets of the company at the end of the financial year', '{}'::jsonb, 'amount'::tax.parameter_type, 'Nigeria Tax Act 2025, s. 202 (interpretation) — "small company": total fixed assets not exceeding N250,000,000', 'nta-2025', 20)
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
  ('NG', 'depreciation', date '2026-01-01', null, 'period_start'::tax.validity_basis, 'Depreciation of fixed assets', '{}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[{"code_from":"6500","kind":"account_code"},{"code_from":"7600","code_to":"7660","kind":"code_range"}]'::jsonb, 'Nigeria Tax Act 2025, s. 21(g) — a deduction is not allowed for depreciation or impairment of any fixed asset or investment; the relief is the capital allowance of s. 27(1) and (2) and Part I of the First Schedule, which the company declares under capital-allowances', 'nta-2025', 10),
  ('NG', 'capital-allowances', date '2026-01-01', null, 'period_start'::tax.validity_basis, 'Capital allowances', '{}'::jsonb, 'deduction'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'Nigeria Tax Act 2025, s. 27(1) and (2) — the total profits of a company are its total assessable profits less the capital allowance in accordance with Part I of the First Schedule, relating to the qualifying capital expenditure incurred in generating the assessable profits. The allowance is not computed here: the company declares the amount', 'nta-2025', 20),
  ('NG', 'fines-penalties', date '2026-01-01', null, 'period_start'::tax.validity_basis, 'Penalties and fines imposed under any law', '{}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'Nigeria Tax Act 2025, s. 21(l) — a deduction is not allowed for a penalty or fine imposed under any law. The chart has no account of its own for them, so the company declares the amount', 'nta-2025', 30),
  ('NG', 'unrealised-exchange-loss', date '2026-01-01', null, 'period_start'::tax.validity_basis, 'Unrealised exchange difference on items denominated in foreign currency', '{}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'Nigeria Tax Act 2025, s. 21(g) — a deduction is not allowed for an unrealised exchange difference on any item denominated in foreign currency; the chart''s account 7700 holds realised and unrealised losses together, so the company declares the unrealised part', 'nta-2025', 40)
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
  ('NG', 'small-company', date '2026-01-01', null, 'period_start'::tax.validity_basis, 'Small company', '{}'::jsonb, 0, null, 'none', '[{"amount":100000000,"parameter":"gross_turnover","test":"at_most"},{"amount":250000000,"parameter":"total_fixed_assets","test":"at_most"}]'::jsonb, 'Nigeria Tax Act 2025, s. 56(a) — tax is levied on the total profits of a small company at 0 %; s. 202 — a small company earns gross turnover of N100,000,000 or less per annum with total fixed assets not exceeding N250,000,000. The rate takes the whole base, and it is the first of the rates with no threshold: when its conditions are not met the standard rate takes the whole base instead', 'nta-2025', 10),
  ('NG', 'standard', date '2026-01-01', null, 'period_start'::tax.validity_basis, 'Standard rate', '{}'::jsonb, 30, null, 'none', '[]'::jsonb, 'Nigeria Tax Act 2025, s. 56(b) — tax is levied on the total profits of any other company at the rate of 30 % from the commencement of the Act', 'nta-2025', 20)
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
  ('NG', date '2026-01-01', null, 'period_start'::tax.validity_basis, null, null, null, 'Nigeria Tax Act 2025, s. 27(6) — the loss is deducted to the extent possible from the assessable profits of the first year of assessment after that in which it was incurred, and in subsequent years until it is fully recouped; the aggregate deductions may not exceed the loss, and it can only be deducted from the trade or business in which it was incurred. No limit of amount or of years is written', 'nta-2025')
on conflict (country, valid_from) do update set
  valid_to            = excluded.valid_to,
  valid_on            = excluded.valid_on,
  floor_amount        = excluded.floor_amount,
  percent_above       = excluded.percent_above,
  carry_forward_years = excluded.carry_forward_years,
  legal_reference     = excluded.legal_reference,
  source_key          = excluded.source_key;
