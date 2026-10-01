-- Ekwo OS — United Kingdom: the rules of this country's corporate income tax.
--
-- Generated from packs/gb/corporate_tax.json at version 0.10.0, do not edit.
-- Change the pack and run `ekwo pack build gb`; `ekwo pack check --all`
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
  ('GB', 'GB-CT', 'Corporation tax', '{}'::jsonb, 'GB-CA-SMALL-IS', '20', 'The Small Companies and Groups (Accounts and Directors'' Report) Regulations 2008 (S.I. 2008/409), Schedule 1, Profit and Loss Account Format 1 — the format of this pack prints no result before tax, so the computation starts from item 20, the profit or loss for the financial year, and a rule adds back the tax charge of item 13', 'small-companies-regs', '8200', '2280', null, 'Corporation tax on profit or loss is item 13 of Profit and Loss Account Format 1 of S.I. 2008/409, Schedule 1, and corporation tax payable a creditor under item E of Balance Sheet Format 1; the chart of this pack keeps them on 8200 and 2280', 'small-companies-regs', 'Corporation Tax Act 2009 and Corporation Tax Act 2010 — corporation tax on the profits of a company; the rates of Part 3 of the 2010 Act (ss. 18A to 18E, inserted by Finance Act 2021, Schedule 1) apply to financial years from 2023, and the financial years of corporation tax run from 1 April to 31 March', 'hmrc-ct-rates')
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
  ('GB', 'twelve_month_period', 'The accounting period is twelve months long', '{}'::jsonb, 'boolean'::tax.parameter_type, 'Corporation Tax Act 2010, s. 18D — for an accounting period of less than 12 months the lower limit and the upper limit are proportionately reduced; the pack does not reduce them, so a shorter period is taxed at the main rate', 'cta-2010-s18d', 10),
  ('GB', 'no_associated_companies', 'The company has no associated companies in the accounting period', '{}'::jsonb, 'boolean'::tax.parameter_type, 'Corporation Tax Act 2010, s. 18D and s. 18E — the lower and upper limits are reduced by the number of associated companies; HMRC''s guidance gives the example of a company with 3 other associated companies, whose limits are divided by 4', 'hmrc-marginal-relief', 20),
  ('GB', 'close_investment_holding_company', 'The company is a close investment-holding company in the accounting period', '{}'::jsonb, 'boolean'::tax.parameter_type, 'Corporation Tax Act 2010, s. 18A(1) and s. 18N — the small profits rate and marginal relief are not available to a close investment-holding company', 'cta-2010-s18a', 30),
  ('GB', 'augmented_profits_equal_taxable_profits', 'The company''s augmented profits are the same as its taxable total profits: it received no distributions that count towards augmented profits', '{}'::jsonb, 'boolean'::tax.parameter_type, 'Corporation Tax Act 2010, s. 18A and s. 18B — the small profits rate is for augmented profits not above the lower limit, and marginal relief is the fraction times (U − A) × N / A, with A the augmented profits and N the taxable total profits; the tranches of this pack are the same arithmetic only where A is equal to N', 'cta-2010-s18b', 40)
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
  ('GB', 'corporation-tax-charge', date '2023-04-01', null, 'period_start'::tax.validity_basis, 'Tax on profit or loss — the charge of the accounts', '{}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[{"code_from":"8200","code_to":"8220","kind":"code_range"}]'::jsonb, 'S.I. 2008/409, Schedule 1, Profit and Loss Account Format 1, item 13 — the net result of item 20 is struck after the tax on profit or loss, which is the tax being computed here; the charge is added back to come to the profit before tax the rates apply to. This is the mechanics of the starting line, not a rule of the Corporation Tax Acts.', 'small-companies-regs', 10),
  ('GB', 'tangible-depreciation', date '2023-04-01', null, 'period_start'::tax.validity_basis, 'Depreciation of tangible fixed assets', '{}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[{"code_from":"7600","code_to":"7660","kind":"code_range"}]'::jsonb, 'HMRC Business Income Manual, BIM35201 — for tax purposes depreciation is not an allowable deduction in computing trade profits; Corporation Tax Act 2009, s. 53 — no deduction for items of a capital nature. Intangible amortisation (7670, 7680) is not added back, and the depreciation of distribution assets (6500) is left to the company to declare, because the chart does not say what kind of asset it holds.', 'bim35201', 20),
  ('GB', 'business-entertainment', date '2023-04-01', null, 'period_start'::tax.validity_basis, 'Business entertainment and gifts', '{}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'Corporation Tax Act 2009, s. 1298 — no deduction is allowed for the expenses of business entertainment or gifts, subject to the exceptions of ss. 1299 and 1300 (entertainment of employees, among others). Account 7330 mixes entertainment of customers with entertainment of staff, so the company declares the amount the rule refuses.', 'cta-2009-s1298', 30),
  ('GB', 'fines-penalties', date '2023-04-01', null, 'period_start'::tax.validity_basis, 'Fines and penalties for breaches of the law', '{}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'HMRC Business Income Manual, BIM38515 — penalties incurred for breaching the law are not allowable; Corporation Tax Act 2009, s. 54(1) — no deduction for expenses not incurred wholly and exclusively for the purposes of the trade. The chart has no account for fines, so the company declares the amount.', 'bim38515', 40),
  ('GB', 'capital-allowances', date '2023-04-01', null, 'period_start'::tax.validity_basis, 'Capital allowances', '{}'::jsonb, 'deduction'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'HMRC, Capital allowances — capital allowances let a business deduct some or all of the value of an item from its profits before it pays tax. The amount of the allowances claimed is the company''s to declare: the pack computes none.', 'hmrc-capital-allowances', 50)
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
  ('GB', 'small-profits', date '2023-04-01', null, 'period_start'::tax.validity_basis, 'Small profits rate', '{}'::jsonb, 19, 50000, 'none', '[{"parameter":"twelve_month_period","test":"is_true"},{"parameter":"no_associated_companies","test":"is_true"},{"parameter":"close_investment_holding_company","test":"is_false"},{"parameter":"augmented_profits_equal_taxable_profits","test":"is_true"}]'::jsonb, 'Corporation Tax Act 2010, s. 18A and s. 18D — the standard small profits rate is 19 % (Finance Act 2021, s. 7(2), for the financial year 2023, and the rate HMRC publishes for 2025 and 2026) on profits up to the lower limit of £50,000, for a company with a twelve-month period, no associated company, that is not a close investment-holding company and has no distribution beyond its taxable profits', 'hmrc-ct-rates', 10),
  ('GB', 'marginal-relief', date '2023-04-01', null, 'period_start'::tax.validity_basis, 'Profits between the small profits limit and the main rate limit, marginal relief included', '{}'::jsonb, 26.5, 250000, 'none', '[{"parameter":"twelve_month_period","test":"is_true"},{"parameter":"no_associated_companies","test":"is_true"},{"parameter":"close_investment_holding_company","test":"is_false"},{"parameter":"augmented_profits_equal_taxable_profits","test":"is_true"}]'::jsonb, 'Corporation Tax Act 2010, s. 18B and s. 18D — marginal relief is F × (U − A) × N / A with F = 3/200 (Finance Act 2021, s. 7(2); HMRC rates and allowances), U = £250,000, A the augmented profits and N the taxable total profits. Where A = N, tax at 25 % less 3/200 × (250,000 − N) is 26.5 % × N − 3,750: at £50,000 it is £9,500, the tax of the first slice at 19 %, and at £250,000 it is £62,500, 25 %. The same arithmetic is therefore 26.5 % on the slice from £50,000 to £250,000, exactly and for those conditions only: where A differs from N, or the limits are divided or shortened, it is not, and the main rate applies.', 'hmrc-ct-rates', 20),
  ('GB', 'main', date '2023-04-01', null, 'period_start'::tax.validity_basis, 'Main rate', '{}'::jsonb, 25, null, 'none', '[]'::jsonb, 'Finance Act 2021, s. 7(2) and HMRC, Rates and allowances: Corporation Tax — the main rate is 25 % on profits over the upper limit of £250,000, and HMRC publishes 25 % for the financial years 2025 and 2026', 'hmrc-ct-rates', 30)
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
  ('GB', date '2017-04-01', null, 'period_start'::tax.validity_basis, 5000000, 50, null, 'Corporation Tax Act 2010, s. 45A — a trading loss of an accounting period beginning on or after 1 April 2017 is carried forward to later periods; Part 7ZA, s. 269ZB — the deductions may not exceed the relevant maximum, which is 50 % of the relevant trading profits plus the deductions allowance; s. 269ZF — the relevant trading profits are the qualifying trading profits less the allowance; s. 269ZW(2) — the deductions allowance of a company not in a group is £5,000,000, reduced in proportion for a period under 12 months (s. 269ZW(3)). So £5,000,000 plus 50 % of the profits above it. The text read sets no number of years; the two-year limit of s. 45A is the time to make the claim.', 'cta-2010-s269zb')
on conflict (country, valid_from) do update set
  valid_to            = excluded.valid_to,
  valid_on            = excluded.valid_on,
  floor_amount        = excluded.floor_amount,
  percent_above       = excluded.percent_above,
  carry_forward_years = excluded.carry_forward_years,
  legal_reference     = excluded.legal_reference,
  source_key          = excluded.source_key;
