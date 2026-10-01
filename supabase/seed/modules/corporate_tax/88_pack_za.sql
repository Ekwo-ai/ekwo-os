-- Ekwo OS — South Africa: the rules of this country's corporate income tax.
--
-- Generated from packs/za/corporate_tax.json at version 0.2.0, do not edit.
-- Change the pack and run `ekwo pack build za`; `ekwo pack check --all`
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
  ('ZA', 'ZA-CIT', 'Income tax on companies', '{}'::jsonb, 'ZA-IFRSSME-PL', '8', 'IFRS for SMEs, paragraph 5.5 — profit before income tax is the line of the pack''s income statement above the income tax expense (accounts 8000 to 8020), so the tax charge never enters the computation; Tax Guide for Small Businesses 2025/2026, paragraph 3.2.13 — taxable income is determined from gross income less deductions, and paragraph 3.2.24(c) — taxes imposed under the Act are not deductible', 'ifrs-for-smes', '8000', '2300', '1350', 'This pack''s chart of accounts, the lines of IFRS for SMEs paragraph 4.2(n) — 8000 Income tax expense — current, 2300 Income tax payable and 1350 Income tax refundable; provisional tax payments are kept on 2310', 'ifrs-for-smes', 'Income Tax Act 58 of 1962 — normal tax on the taxable income of a company; the rates are those SARS publishes for each year of assessment (Tax Guide for Small Businesses 2025/2026, paragraph 3.2.15(c))', 'sars-company-rates')
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
  ('ZA', 'sbc_holders_natural_persons', 'All the holders of shares in the company, or the members of the close corporation, co-operative or personal liability company, were natural persons at all times during the year of assessment', '{}'::jsonb, 'boolean'::tax.parameter_type, 'Income Tax Act 58 of 1962, s 12E(4), definition of small business corporation; Tax Guide for Small Businesses 2025/2026, paragraph 3.2.18 — the company must comply with all of the conditions of section 12E(4) — all holders of shares or members must at all times during a year of assessment be natural persons', 'sars-sb-guide-2025-26', 10),
  ('ZA', 'sbc_holds_interest_in_other_company', 'A holder of shares or a member of the company holds shares or an interest in the equity of another company, other than the companies the definition of small business corporation in section 12E(4) allows', '{}'::jsonb, 'boolean'::tax.parameter_type, 'Income Tax Act 58 of 1962, s 12E(4); Tax Guide for Small Businesses 2025/2026, paragraph 3.2.18 — the company must comply with all of the conditions of section 12E(4) — no holder of shares or member may hold shares or any interest in the equity of any other company, other than companies specified in the definition', 'sars-sb-guide-2025-26', 20),
  ('ZA', 'sbc_gross_income', 'The gross income of the company for the year of assessment, as section 1(1) defines it', '{}'::jsonb, 'amount'::tax.parameter_type, 'Income Tax Act 58 of 1962, s 12E(4); Tax Guide for Small Businesses 2025/2026, paragraph 3.2.18 — the company must comply with all of the conditions of section 12E(4) — the gross income of the entity for the year of assessment may not exceed R20 million', 'sars-sb-guide-2025-26', 30),
  ('ZA', 'sbc_passive_and_personal_service_percent', 'The percentage of the total of all receipts and accruals not of a capital nature, and of all capital gains, that consists collectively of investment income and income from rendering a personal service, both as section 12E(4) defines them', '{}'::jsonb, 'amount'::tax.parameter_type, 'Income Tax Act 58 of 1962, s 12E(4); Tax Guide for Small Businesses 2025/2026, paragraph 3.2.18 — the company must comply with all of the conditions of section 12E(4) — not more than 20 % of that total may consist collectively of investment income and income from rendering a personal service. The guide adds that a company that provides personal services still qualifies if it employs three or more full-time employees as section 12E specifies and the service is not performed by a person who holds an interest in it: the company states the percentage it reaches after that exception.', 'sars-sb-guide-2025-26', 40),
  ('ZA', 'personal_service_provider', 'The company is a personal service provider as paragraph 1 of the Fourth Schedule defines it', '{}'::jsonb, 'boolean'::tax.parameter_type, 'Income Tax Act 58 of 1962, s 12E(4); Tax Guide for Small Businesses 2025/2026, paragraph 3.2.18 — the company must comply with all of the conditions of section 12E(4) — the company may not be a personal service provider as defined in the Fourth Schedule; Tax Guide for Small Businesses 2025/2026, paragraph 2.1.6(c)', 'sars-sb-guide-2025-26', 50)
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
  ('ZA', 'tax-interest-penalties', date '2025-04-01', null, 'period_end'::tax.validity_basis, 'Interest on late payment of tax — not deductible', '{}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[{"code_from":"7030","kind":"account_code"}]'::jsonb, 'Income Tax Act 58 of 1962, s 23(d), (e) and (g), as paragraph 3.2.24(c) of the Tax Guide for Small Businesses 2025/2026 groups them — prohibited deductions include taxes or interest imposed under the Act and interest or penalties imposed under other Acts administered by the Commissioner. Account 7030 holds interest on late payment of tax and nothing else.', 'sars-sb-guide-2025-26', 10),
  ('ZA', 'unlawful-fines', date '2025-04-01', null, 'period_end'::tax.validity_basis, 'Fines and penalties for an unlawful activity, and bribes — not deductible', '{}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'Income Tax Act 58 of 1962, s 23(o)(i) and (ii) — a bribe, or a fine or penalty imposed as a result of carrying out an unlawful activity in South Africa or abroad, is not deductible (Tax Guide for Small Businesses 2025/2026, paragraph 3.2.24(b)). The chart keeps no account for them, and a fine for something that is not unlawful is deductible: the company states the amount.', 'sars-sb-guide-2025-26', 20)
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
  ('ZA', 'sbc-nil', date '2025-04-01', date '2026-03-31', 'period_end'::tax.validity_basis, 'Small business corporation — first band, nil rate', '{}'::jsonb, 0, 95750, 'none', '[{"parameter":"sbc_holders_natural_persons","test":"is_true"},{"parameter":"sbc_holds_interest_in_other_company","test":"is_false"},{"amount":20000000,"parameter":"sbc_gross_income","test":"at_most"},{"amount":20,"parameter":"sbc_passive_and_personal_service_percent","test":"at_most"},{"parameter":"personal_service_provider","test":"is_false"}]'::jsonb, 'Income Tax Act 58 of 1962, s 12E(4), for a company that meets its conditions — taxable income of R1 to R95 750 at 0 % for a year of assessment ending between 1 April 2025 and 31 March 2026 (SARS rates of tax; Tax Guide for Small Businesses 2025/2026, paragraph 3.2.15(c)(ii))', 'sars-company-rates', 5),
  ('ZA', 'sbc-nil', date '2026-04-01', null, 'period_end'::tax.validity_basis, 'Small business corporation — first band, nil rate', '{}'::jsonb, 0, 99000, 'none', '[{"parameter":"sbc_holders_natural_persons","test":"is_true"},{"parameter":"sbc_holds_interest_in_other_company","test":"is_false"},{"amount":20000000,"parameter":"sbc_gross_income","test":"at_most"},{"amount":20,"parameter":"sbc_passive_and_personal_service_percent","test":"at_most"},{"parameter":"personal_service_provider","test":"is_false"}]'::jsonb, 'Income Tax Act 58 of 1962, s 12E(4), for a company that meets its conditions — taxable income of R1 to R99 000 at 0 % for a year of assessment ending between 1 April 2026 and 31 March 2027 (SARS rates of tax for companies, trusts and small business corporations)', 'sars-company-rates', 5),
  ('ZA', 'sbc-7', date '2025-04-01', null, 'period_end'::tax.validity_basis, 'Small business corporation — 7 % band', '{}'::jsonb, 7, 365000, 'none', '[{"parameter":"sbc_holders_natural_persons","test":"is_true"},{"parameter":"sbc_holds_interest_in_other_company","test":"is_false"},{"amount":20000000,"parameter":"sbc_gross_income","test":"at_most"},{"amount":20,"parameter":"sbc_passive_and_personal_service_percent","test":"at_most"},{"parameter":"personal_service_provider","test":"is_false"}]'::jsonb, 'Income Tax Act 58 of 1962, s 12E(4), for a company that meets its conditions — 7 % of the amount by which taxable income exceeds the nil band, up to R365 000, in the tables of the years of assessment ending 1 April 2025 to 31 March 2026 and 1 April 2026 to 31 March 2027 (SARS rates of tax). SARS prints the tax at R365 000 as a whole-rand figure (R18 848 in the first, R18 620 in the second); this section computes the 7 % to the cent.', 'sars-company-rates', 6),
  ('ZA', 'sbc-21', date '2025-04-01', null, 'period_end'::tax.validity_basis, 'Small business corporation — 21 % band', '{}'::jsonb, 21, 550000, 'none', '[{"parameter":"sbc_holders_natural_persons","test":"is_true"},{"parameter":"sbc_holds_interest_in_other_company","test":"is_false"},{"amount":20000000,"parameter":"sbc_gross_income","test":"at_most"},{"amount":20,"parameter":"sbc_passive_and_personal_service_percent","test":"at_most"},{"parameter":"personal_service_provider","test":"is_false"}]'::jsonb, 'Income Tax Act 58 of 1962, s 12E(4), for a company that meets its conditions — R18 848 plus 21 % of the amount by which taxable income exceeds R365 000, up to R550 000 (SARS rates of tax, year ending 1 April 2025 to 31 March 2026; the same 21 % and the same bounds in the table of the following year). Above R550 000 the 27 % rate of the table is the company rate.', 'sars-company-rates', 7),
  ('ZA', 'standard', date '2023-03-31', null, 'period_end'::tax.validity_basis, 'Company rate', '{}'::jsonb, 27, null, 'none', '[]'::jsonb, 'Income Tax Act 58 of 1962 — 27 % of taxable income for years of assessment ending on or after 31 March 2023 (SARS archive of tax rates); the same rate for the years ending 1 April 2025 to 31 March 2027 (SARS rates of tax for companies, trusts and small business corporations)', 'sars-company-rates', 20)
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
