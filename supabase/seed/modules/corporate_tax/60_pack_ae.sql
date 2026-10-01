-- Ekwo OS — United Arab Emirates: the rules of this country's corporate income tax.
--
-- Generated from packs/ae/corporate_tax.json at version 0.4.0, do not edit.
-- Change the pack and run `ekwo pack build ae`; `ekwo pack check --all`
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
  ('AE', 'AE-CT', 'Corporate Tax', '{}'::jsonb, 'AE-IFRSSME-IS', '8', 'Federal Decree-Law No. 47 of 2022 on the Taxation of Corporations and Businesses, art. 20, paras 1 and 2 — Taxable Income is the Accounting Income of the financial statements, adjusted as the Decree-Law provides; art. 33, para 6 — Corporate Tax itself is not deductible, so the computation starts from line 8 ''Profit before corporate tax'', above the tax expense of line 9', 'ct-decree-law', '8000', '2130', '1350', 'The pack''s own chart of accounts: 8000 ''Corporate tax charge for the year'', 2130 ''Corporate tax payable'', 1350 ''Corporate tax recoverable''. The Decree-Law prescribes no chart of accounts.', 'ct-decree-law', 'Federal Decree-Law No. 47 of 2022 on the Taxation of Corporations and Businesses, art. 2 — Corporate Tax is imposed on Taxable Income at the rates of art. 3', 'ct-decree-law')
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

insert into tax.adjustment_rule_templates
  (country, code, valid_from, valid_to, valid_on, name, name_i18n, direction, percent, formula, account_rules, legal_reference, source_key, sequence)
values
  ('AE', 'entertainment', date '2023-06-01', null, 'period_start'::tax.validity_basis, 'Entertainment, amusement and recreation expenditure — non-deductible half', '{}'::jsonb, 'add_back'::tax.adjustment_direction, 50, null, '[{"code_from":"6310","kind":"account_code"}]'::jsonb, 'Federal Decree-Law No. 47 of 2022 on the Taxation of Corporations and Businesses, art. 32, paras 1 and 2 — 50 % of entertainment, amusement or recreation expenditure is deductible: meals, accommodation, transport, admission fees and facilities for customers, shareholders, suppliers or other business partners', 'ct-decree-law', 10),
  ('AE', 'fines-penalties', date '2023-06-01', null, 'period_start'::tax.validity_basis, 'Fines and penalties', '{}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'Federal Decree-Law No. 47 of 2022 on the Taxation of Corporations and Businesses, art. 33, para 2 — no deduction for fines and penalties, other than amounts awarded as compensation for damages or breach of contract', 'ct-decree-law', 20),
  ('AE', 'non-qualifying-donations', date '2023-06-01', null, 'period_start'::tax.validity_basis, 'Donations, grants and gifts to an entity that is not a Qualifying Public Benefit Entity', '{}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'Federal Decree-Law No. 47 of 2022 on the Taxation of Corporations and Businesses, art. 33, para 1 — no deduction for donations, grants or gifts made to an entity that is not a Qualifying Public Benefit Entity', 'ct-decree-law', 30),
  ('AE', 'illicit-payments', date '2023-06-01', null, 'period_start'::tax.validity_basis, 'Bribes and other illicit payments', '{}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'Federal Decree-Law No. 47 of 2022 on the Taxation of Corporations and Businesses, art. 33, para 3 — no deduction for bribes or other illicit payments', 'ct-decree-law', 40),
  ('AE', 'foreign-income-tax', date '2023-06-01', null, 'period_start'::tax.validity_basis, 'Tax on income imposed on the company outside the State', '{}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'Federal Decree-Law No. 47 of 2022 on the Taxation of Corporations and Businesses, art. 33, para 8 — no deduction for tax on income imposed on the Taxable Person outside the State', 'ct-decree-law', 50)
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
  ('AE', 'zero-band', date '2023-06-01', null, 'period_start'::tax.validity_basis, 'Zero rate on the first 375 000 AED of Taxable Income', '{}'::jsonb, 0, 375000, 'none', '[]'::jsonb, 'Federal Decree-Law No. 47 of 2022 on the Taxation of Corporations and Businesses, art. 3, para 1(a); Cabinet Decision No. 116 of 2022, art. 2, para 1 — the portion of Taxable Income not exceeding 375 000 dirhams is subject to a 0 % rate in the Tax Period; applies to Tax Periods commencing on or after 1 June 2023 (Decree-Law art. 69)', 'cabinet-116-2022', 10),
  ('AE', 'standard', date '2023-06-01', null, 'period_start'::tax.validity_basis, 'Standard rate', '{}'::jsonb, 9, null, 'none', '[]'::jsonb, 'Federal Decree-Law No. 47 of 2022 on the Taxation of Corporations and Businesses, art. 3, para 1(b); Cabinet Decision No. 116 of 2022, art. 3 — 9 % on Taxable Income exceeding 375 000 dirhams; applies to Tax Periods commencing on or after 1 June 2023 (Decree-Law art. 69)', 'cabinet-116-2022', 20)
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
  ('AE', date '2023-06-01', null, 'period_start'::tax.validity_basis, 0, 75, null, 'Federal Decree-Law No. 47 of 2022 on the Taxation of Corporations and Businesses, art. 37, paras 1, 2 and 4 — a Tax Loss is offset against the Taxable Income of subsequent Tax Periods, oldest first, up to 75 % of the Taxable Income of the period before any Tax Loss relief, with no limit of time. Not computed here: art. 37, para 3 (losses before the commencement of Corporate Tax or before the person became a Taxable Person), art. 39 (50 % continuity of ownership), art. 38 (transfer between group companies) and art. 21, para 2(d) (no loss relief in a period of Small Business Relief).', 'ct-decree-law')
on conflict (country, valid_from) do update set
  valid_to            = excluded.valid_to,
  valid_on            = excluded.valid_on,
  floor_amount        = excluded.floor_amount,
  percent_above       = excluded.percent_above,
  carry_forward_years = excluded.carry_forward_years,
  legal_reference     = excluded.legal_reference,
  source_key          = excluded.source_key;
