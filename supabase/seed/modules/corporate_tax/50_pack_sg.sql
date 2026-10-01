-- Ekwo OS — Singapore: the rules of this country's corporate income tax.
--
-- Generated from packs/sg/corporate_tax.json at version 0.2.0, do not edit.
-- Change the pack and run `ekwo pack build sg`; `ekwo pack check --all`
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
  ('SG', 'SG-CIT', 'Corporate income tax', '{}'::jsonb, 'SG-SFRSSE-IS', '8', 'SFRS for Small Entities, Section 5 — line 8 ''Profit before income tax'' of the income statement of this pack, printed before the tax charge of line 9, so the tax expense never enters the computation. IRAS, Explanatory Notes to Form C for YA 2026, Annex — the computation of tax payable starts from the adjusted trade profit, that is the accounting profit after adjustment for non-taxable items and disallowable expenses.', 'iras-form-c-ya2026', '8000', '2300', '1350', 'Reference chart of this pack, which is not a statutory chart: no Singapore law prescribes a chart of accounts (Companies Act 1967, s. 199). 8000 ''Current income tax expense'' is the charge of the year, 2300 ''Income tax payable'' the estimated debt to IRAS and 1350 ''Income tax recoverable'' a prepayment or a refund to come.', 'companies-act', 'Income Tax Act 1947 — income tax charged on the chargeable income of a company for a year of assessment, on the income of the preceding year (basis period); IRAS, Explanatory Notes to Form C for YA 2026, ''Normal Companies'': the basis period for any YA is the financial year ending in the year preceding the YA', 'iras-form-c-ya2026')
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
  ('SG', 'new_start_up_company', 'The company meets every condition of the tax exemption scheme for new start-up companies for this year of assessment: incorporated in Singapore, tax resident in Singapore for the year of assessment, in its first three consecutive years of assessment, its total share capital beneficially held directly by no more than 20 shareholders throughout the basis period (all of them individuals, or at least one an individual holding at least 10 % of the issued ordinary shares), and neither an investment holding company nor a company that undertakes property development', '{}'::jsonb, 'boolean'::tax.parameter_type, 'IRAS, Explanatory Notes to Form C for YA 2026, ''General Info'' — qualifying conditions of the Tax Exemption Scheme for New Start-Up Companies; the exemption is granted for each of the first 3 consecutive years of assessment. A company that does not qualify enjoys the partial tax exemption. A company limited by guarantee is tested on its members and their contributions instead of its shareholders.', 'iras-form-c-ya2026', 10)
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
  ('SG', 'depreciation', date '2025-01-01', null, 'period_end'::tax.validity_basis, 'Depreciation of property, plant and equipment in the financial statements', '{}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[{"code_from":"6200","kind":"account_code"}]'::jsonb, 'Income Tax Act 1947, s. 15(1)(c) — deductions on capital expenditure are disallowed, including depreciation expenses in the financial statements (IRAS, ''IRAS'' audits on family-owned/managed companies'', section 3(a)). The allowance that replaces it is the capital allowance of s. 19/19A: the company states it under the rule capital-allowances. Only account 6200 is named; the depreciation of right-of-use assets (6210) and the amortisation of intangible assets (6220) were not read and are left to the company.', 'iras-family-audits', 10),
  ('SG', 'private-motor-vehicle', date '2025-01-01', null, 'period_end'::tax.validity_basis, 'Private motor vehicle expenses (S-plated cars)', '{}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'Income Tax Act 1947, s. 15(1)(k) — private motor vehicle expenses (S-plated cars) are not deductible even if incurred in the course of business: petrol, insurance, repair and maintenance, parking, ERP charges (IRAS, ''IRAS'' audits on family-owned/managed companies'', section 3(b)). The chart keeps all car expenses on 6380 together with those of vehicles that may be deducted, so no account is named: the company states the amount, or an account of its own that holds nothing else.', 'iras-family-audits', 20),
  ('SG', 'capital-allowances', date '2025-01-01', null, 'period_end'::tax.validity_basis, 'Capital allowances on machinery or plant', '{}'::jsonb, 'deduction'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'Income Tax Act 1947, s. 19/19A — capital allowances are allowed on capital expenditure incurred on machinery or plant for the purpose of the trade, profession or business (IRAS, ''IRAS'' audits on family-owned/managed companies'', section 3(c)); IRAS, Explanatory Notes to Form C for YA 2026, items 18 to 20 — the current year allowance and the unutilised allowance brought forward. The books carry no allowance, and the amount depends on the pool of assets: the company states it.', 'iras-family-audits', 30)
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
  ('SG', 'partial-exemption-first-10000', date '2019-01-01', null, 'period_end'::tax.validity_basis, 'Partial tax exemption — first 10 000 of normal chargeable income, 25 % taxed (75 % exempt)', '{}'::jsonb, 4.25, 10000, 'none', '[{"parameter":"new_start_up_company","test":"is_false"}]'::jsonb, 'Income Tax Act 1947 — partial tax exemption: 75 % of the first S$10,000 of normal chargeable income is exempt, from YA 2020 (IRAS, examples of the tax exemption, ''changes to the partial tax exemption as announced in Budget 2018 will apply with effect from YA 2020 onwards''; Explanatory Notes to Form C for YA 2026, ''General Info''). Written as the tax on the slice: 17 % × (100 % − 75 %) = 4,25 %, which is the 17 % on what the exemption leaves. It applies to a company that does not qualify for the new start-up exemption. IRAS rounds the exempt amount to the dollar in its own examples; the estimate keeps the cent. Valid from YA 2020, i.e. financial years closing from 1 January 2019. Valid dates read on the last day of the financial year (`valid_on: period_end`): Singapore assesses the income of the financial year that ends in the year before the year of assessment (YA), so a financial year closing in calendar 2025 is the basis period of YA 2026.', 'iras-exemption-examples', 10),
  ('SG', 'partial-exemption-next-190000', date '2019-01-01', null, 'period_end'::tax.validity_basis, 'Partial tax exemption — next 190 000 of normal chargeable income, 50 % taxed (50 % exempt)', '{}'::jsonb, 8.5, 200000, 'none', '[{"parameter":"new_start_up_company","test":"is_false"}]'::jsonb, 'Income Tax Act 1947 — partial tax exemption: 50 % of the next S$190,000 of normal chargeable income is exempt, from YA 2020 (IRAS, examples of the tax exemption, Example 2 and Example 5; Explanatory Notes to Form C for YA 2026, ''General Info''). Written as the tax on the slice from 10 000 up to 200 000: 17 % × (100 % − 50 %) = 8,5 %. Worked in IRAS'' Annex: exempt amount 102 500, tax on the rest at 17 %. Valid dates read on the last day of the financial year (`valid_on: period_end`): Singapore assesses the income of the financial year that ends in the year before the year of assessment (YA), so a financial year closing in calendar 2025 is the basis period of YA 2026.', 'iras-exemption-examples', 20),
  ('SG', 'start-up-exemption-first-100000', date '2019-01-01', null, 'period_end'::tax.validity_basis, 'Tax exemption for new start-up companies — first 100 000 of normal chargeable income, 25 % taxed (75 % exempt)', '{}'::jsonb, 4.25, 100000, 'none', '[{"parameter":"new_start_up_company","test":"is_true"}]'::jsonb, 'Income Tax Act 1947 — tax exemption for new start-up companies: 75 % of the first S$100,000 of normal chargeable income is exempt, for each of the first 3 consecutive years of assessment, from YA 2020 (IRAS, examples of the tax exemption, Example 1, YA 2020 and YA 2021; Explanatory Notes to Form C for YA 2026, ''General Info''). Written as the tax on the slice: 17 % × (100 % − 75 %) = 4,25 %. Conditions are the company''s declaration (new_start_up_company). Valid dates read on the last day of the financial year (`valid_on: period_end`): Singapore assesses the income of the financial year that ends in the year before the year of assessment (YA), so a financial year closing in calendar 2025 is the basis period of YA 2026.', 'iras-exemption-examples', 30),
  ('SG', 'start-up-exemption-next-100000', date '2019-01-01', null, 'period_end'::tax.validity_basis, 'Tax exemption for new start-up companies — next 100 000 of normal chargeable income, 50 % taxed (50 % exempt)', '{}'::jsonb, 8.5, 200000, 'none', '[{"parameter":"new_start_up_company","test":"is_true"}]'::jsonb, 'Income Tax Act 1947 — tax exemption for new start-up companies: 50 % of the next S$100,000 of normal chargeable income is exempt, from YA 2020 (IRAS, examples of the tax exemption, Example 1; Explanatory Notes to Form C for YA 2026, ''General Info''; Annex example: 75 % on the first 100,000 and 50 % on the next 21,200). Written as the tax on the slice from 100 000 up to 200 000: 17 % × (100 % − 50 %) = 8,5 %. Valid dates read on the last day of the financial year (`valid_on: period_end`): Singapore assesses the income of the financial year that ends in the year before the year of assessment (YA), so a financial year closing in calendar 2025 is the basis period of YA 2026.', 'iras-exemption-examples', 40),
  ('SG', 'standard', date '2018-01-01', null, 'period_end'::tax.validity_basis, 'Corporate income tax rate', '{}'::jsonb, 17, null, 'none', '[]'::jsonb, 'Income Tax Act 1947 — tax at 17 % on the chargeable income of a company after the exempt amount (IRAS, Explanatory Notes to Form C for YA 2026, Annex: ''Tax assessed at 17%''; IRAS, examples of the tax exemption, ''Tax payable @ 17%'' from YA 2019 to YA 2022). Dated from YA 2019, the earliest year read; the rate is carried open-ended and no year after YA 2026 was read. Valid dates read on the last day of the financial year (`valid_on: period_end`): Singapore assesses the income of the financial year that ends in the year before the year of assessment (YA), so a financial year closing in calendar 2025 is the basis period of YA 2026.', 'iras-exemption-examples', 50)
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
  ('SG', date '2025-01-01', null, 'period_end'::tax.validity_basis, null, null, null, 'Income Tax Act 1947, s. 37 — unabsorbed trade losses are carried forward with no time limit and no limit on the amount, provided the shareholding test is met: 50 % or more of the company''s (or its ultimate parent''s) issued shares held by the same persons at the relevant dates (IRAS e-Tax Guide ''Utilising Unabsorbed Capital Allowances, Trade Losses and Donations'', paragraph 4.3 and section 5; Explanatory Notes to Form C for YA 2026, items 16a and 16b). The test is not computed: the company records in tax.losses only the losses that pass it. Unabsorbed capital allowances and donations follow rules of their own and are not in this stock.', 'iras-unabsorbed-items')
on conflict (country, valid_from) do update set
  valid_to            = excluded.valid_to,
  valid_on            = excluded.valid_on,
  floor_amount        = excluded.floor_amount,
  percent_above       = excluded.percent_above,
  carry_forward_years = excluded.carry_forward_years,
  legal_reference     = excluded.legal_reference,
  source_key          = excluded.source_key;
