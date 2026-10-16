-- Ekwo OS — Antigua and Barbuda: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/ag at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build ag`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   The Antigua and Barbuda Sales Tax Act, 2006 (No. 5 of 2006): ss. 8, 15, 18, 28, 29, 39, 57 and Schedules 1 to 5 (the published copy is an image scan, read by optical character recognition) (Government of Antigua and Barbuda — Laws of Antigua and Barbuda)
--     https://laws.gov.ag/wp-content/uploads/2022/12/NO.-5-of-2006-The-Antigua-and-Barbuda-Sales-Tax-Act-2006.pdf
--   The Antigua and Barbuda Sales Tax (Amendment) Act 2024 (No. 1 of 2024): section 39(1) replaced — the return is due fifteen calendar days after the end of the period, from the period ending 31 March 2024 (Government of Antigua and Barbuda — Laws of Antigua and Barbuda)
--     https://laws.gov.ag/wp-content/uploads/2025/01/No.-1-of-2024-Antigua-and-Barbuda-Sales-Tax-Amendment-Act-2024.pdf
--   The Antigua and Barbuda Sales Tax (Amendment) Act, 2019 (No. 32 of 2019): section 8(3)(b), the 14 per cent special rate (Government of Antigua and Barbuda — Laws of Antigua and Barbuda)
--     https://laws.gov.ag/wp-content/uploads/2021/10/ANTIGUA-AND-BARBUDA-SALES-TAX-AMENDMENT-ACT-2019-no-32-of-2019.pdf
--   The Tax Administration and Procedure Act, 2018 (No. 12 of 2018): s. 22 accounts and records, ss. 57, 72 and 77 (Government of Antigua and Barbuda — Laws of Antigua and Barbuda)
--     https://laws.gov.ag/wp-content/uploads/2019/03/Tax-Administration-Act-2018.pdf
--   The Institute of Chartered Accountants of the Eastern Caribbean Agreement Act, 2013 (No. 23 of 2013): the Institute prescribes the accounting standards its members adopt (Government of Antigua and Barbuda — Laws of Antigua and Barbuda)
--     https://laws.gov.ag/wp-content/uploads/2019/04/No.-23-of-2013-The-Institute-of-Chartered-Accountants-of-the-Eastern-Caribbean-Agreement-Act-2013.pdf
--   Frequently asked questions: ABST (rates, registration at EC$300,000, monthly filing, nil returns, invoices and receipts, penalties). The copy online still states the 15 % rate in force before 1 January 2024 (Inland Revenue Department, Antigua and Barbuda)
--     https://ird.gov.ag/wp-content/uploads/2020/06/Frequently_asked_questions_ABST.pdf
--   Form AB03 — ABST tax remittance form (ABST return), version of 26 July 2022: lines 100 to 600 (Inland Revenue Department, Antigua and Barbuda)
--     https://ird.gov.ag/wp-content/uploads/2022/07/AB03-ABST-Monthly-V5.pdf
--   Antigua and Barbuda Sales Tax — guides, registration and remittance forms (Inland Revenue Department, Antigua and Barbuda)
--     https://ird.gov.ag/index.php/antigua-and-barbuda-sales-tax/
--   Antigua and Barbuda: Standard Sales Tax Rate Increase from January 1, 2024 — reports the Inland Revenue Department announcement of 22 December 2023 (the notice itself is on the Department's social media pages and was not opened) (Sovos)
--     https://sovos.com/regulatory-updates/sut/antigua-and-barbuda-standard-sales-tax-rate-increase-from-january-1-2024/
--   Antigua and Barbuda Prime Minister Confirms Sales Tax (ABST) Increase and Other Budget Measures for 2024 — the 2024 Budget Statement of 15 December 2023: rate from 15 % to 17 %, concessionary rates ended (Orbitax)
--     https://orbitax.com/news/country/article/Antigua-and-Barbuda-Prime-Mini-54480
--   ISO 4217 currency code list, list one — ANTIGUA AND BARBUDA, East Caribbean Dollar, XCD, 951, two minor units (SIX Group (maintenance agency of ISO 4217))
--     https://www.six-group.com/dam/download/financial-information/data-center/iso-currrency/lists/list-one.xml
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('AG', 'Antigua and Barbuda', '0.1.0', date '2026-10-16', '20261011120000', 'community', null, null, '4b475ff153ea82d9f3523fdc53a12831bb4104c67493e3fd7c407f4872ac1847', '[{"key":"abst-act-2006","title":"The Antigua and Barbuda Sales Tax Act, 2006 (No. 5 of 2006): ss. 8, 15, 18, 28, 29, 39, 57 and Schedules 1 to 5 (the published copy is an image scan, read by optical character recognition)","publisher":"Government of Antigua and Barbuda — Laws of Antigua and Barbuda","url":"https://laws.gov.ag/wp-content/uploads/2022/12/NO.-5-of-2006-The-Antigua-and-Barbuda-Sales-Tax-Act-2006.pdf","consulted_on":"2026-10-16","kind":"law"},{"key":"abst-amend-2024","title":"The Antigua and Barbuda Sales Tax (Amendment) Act 2024 (No. 1 of 2024): section 39(1) replaced — the return is due fifteen calendar days after the end of the period, from the period ending 31 March 2024","publisher":"Government of Antigua and Barbuda — Laws of Antigua and Barbuda","url":"https://laws.gov.ag/wp-content/uploads/2025/01/No.-1-of-2024-Antigua-and-Barbuda-Sales-Tax-Amendment-Act-2024.pdf","consulted_on":"2026-10-16","kind":"law"},{"key":"abst-amend-2019","title":"The Antigua and Barbuda Sales Tax (Amendment) Act, 2019 (No. 32 of 2019): section 8(3)(b), the 14 per cent special rate","publisher":"Government of Antigua and Barbuda — Laws of Antigua and Barbuda","url":"https://laws.gov.ag/wp-content/uploads/2021/10/ANTIGUA-AND-BARBUDA-SALES-TAX-AMENDMENT-ACT-2019-no-32-of-2019.pdf","consulted_on":"2026-10-16","kind":"law"},{"key":"tapa-2018","title":"The Tax Administration and Procedure Act, 2018 (No. 12 of 2018): s. 22 accounts and records, ss. 57, 72 and 77","publisher":"Government of Antigua and Barbuda — Laws of Antigua and Barbuda","url":"https://laws.gov.ag/wp-content/uploads/2019/03/Tax-Administration-Act-2018.pdf","consulted_on":"2026-10-16","kind":"law"},{"key":"icaec-act-2013","title":"The Institute of Chartered Accountants of the Eastern Caribbean Agreement Act, 2013 (No. 23 of 2013): the Institute prescribes the accounting standards its members adopt","publisher":"Government of Antigua and Barbuda — Laws of Antigua and Barbuda","url":"https://laws.gov.ag/wp-content/uploads/2019/04/No.-23-of-2013-The-Institute-of-Chartered-Accountants-of-the-Eastern-Caribbean-Agreement-Act-2013.pdf","consulted_on":"2026-10-16","kind":"law"},{"key":"abst-faq","title":"Frequently asked questions: ABST (rates, registration at EC$300,000, monthly filing, nil returns, invoices and receipts, penalties). The copy online still states the 15 % rate in force before 1 January 2024","publisher":"Inland Revenue Department, Antigua and Barbuda","url":"https://ird.gov.ag/wp-content/uploads/2020/06/Frequently_asked_questions_ABST.pdf","consulted_on":"2026-10-16","kind":"guidance"},{"key":"ab03-form","title":"Form AB03 — ABST tax remittance form (ABST return), version of 26 July 2022: lines 100 to 600","publisher":"Inland Revenue Department, Antigua and Barbuda","url":"https://ird.gov.ag/wp-content/uploads/2022/07/AB03-ABST-Monthly-V5.pdf","consulted_on":"2026-10-16","kind":"form"},{"key":"ird-abst-page","title":"Antigua and Barbuda Sales Tax — guides, registration and remittance forms","publisher":"Inland Revenue Department, Antigua and Barbuda","url":"https://ird.gov.ag/index.php/antigua-and-barbuda-sales-tax/","consulted_on":"2026-10-16","kind":"portal"},{"key":"rate-2024-sovos","title":"Antigua and Barbuda: Standard Sales Tax Rate Increase from January 1, 2024 — reports the Inland Revenue Department announcement of 22 December 2023 (the notice itself is on the Department''s social media pages and was not opened)","publisher":"Sovos","url":"https://sovos.com/regulatory-updates/sut/antigua-and-barbuda-standard-sales-tax-rate-increase-from-january-1-2024/","consulted_on":"2026-10-16","kind":"guidance"},{"key":"rate-2024-orbitax","title":"Antigua and Barbuda Prime Minister Confirms Sales Tax (ABST) Increase and Other Budget Measures for 2024 — the 2024 Budget Statement of 15 December 2023: rate from 15 % to 17 %, concessionary rates ended","publisher":"Orbitax","url":"https://orbitax.com/news/country/article/Antigua-and-Barbuda-Prime-Mini-54480","consulted_on":"2026-10-16","kind":"guidance"},{"key":"iso-4217","title":"ISO 4217 currency code list, list one — ANTIGUA AND BARBUDA, East Caribbean Dollar, XCD, 951, two minor units","publisher":"SIX Group (maintenance agency of ISO 4217)","url":"https://www.six-group.com/dam/download/financial-information/data-center/iso-currrency/lists/list-one.xml","consulted_on":"2026-10-16","kind":"standard"}]'::jsonb)
on conflict (country) do update set
  name                 = excluded.name,
  version              = excluded.version,
  released_at          = excluded.released_at,
  schema_min           = excluded.schema_min,
  certification_status = excluded.certification_status,
  certified_by         = excluded.certified_by,
  certified_at         = excluded.certified_at,
  checksum             = excluded.checksum,
  sources              = excluded.sources;

insert into chart_templates
  (country, code, name, name_i18n, is_default, audience, statements,
   certification_status, legal_reference, source_key)
values
  ('AG', 'default', 'Antigua and Barbuda reference chart of accounts', '{}'::jsonb, true, 'companies', array['AG-IFRS-IS', 'AG-IFRS-SFP']::text[], null, 'There is no statutory chart of accounts in Antigua and Barbuda. The Tax Administration and Procedure Act, 2018, s. 22, obliges a person in business to keep records and accounts that explain every transaction, show the financial position and allow financial statements to be prepared, and to keep them seven years; the Institute of Chartered Accountants of the Eastern Caribbean prescribes the accounting standards its members adopt (Act No. 23 of 2013). This chart is original: four digits, blocked so that each range reaches one line of the IFRS-style statements, with the accounts an Antiguan company keeps — an EC dollar current account and a foreign currency account, ABST output and input tax, the net ABST settlement account, ABST collected by the Comptroller of Customs on imports, and the payroll deductions owed to the Inland Revenue Department and the Social Security Board.', 'tapa-2018')
on conflict (country, code) do update set
  name                 = excluded.name,
  name_i18n            = excluded.name_i18n,
  is_default           = excluded.is_default,
  audience             = excluded.audience,
  statements           = excluded.statements,
  certification_status = excluded.certification_status,
  legal_reference      = excluded.legal_reference,
  source_key           = excluded.source_key;

insert into account_templates
  (country, chart_code, code, name, name_i18n, account_type, reconcilable,
   parent_code, sequence)
values
  ('AG', 'default', '1000', 'Petty cash', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('AG', 'default', '1010', 'Current account — XCD', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('AG', 'default', '1020', 'Fixed deposits placed for three months or less', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('AG', 'default', '1030', 'Foreign currency account (USD and others)', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('AG', 'default', '1040', 'Cash in transit — card and mobile-payment settlements', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('AG', 'default', '1100', 'Trade receivables', '{}'::jsonb, 'asset_receivable', true, null, 60),
  ('AG', 'default', '1110', 'Trade receivables — allowance for impairment', '{}'::jsonb, 'asset_current', false, null, 70),
  ('AG', 'default', '1120', 'Other receivables', '{}'::jsonb, 'asset_current', false, null, 80),
  ('AG', 'default', '1130', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 90),
  ('AG', 'default', '1140', 'Deposits paid', '{}'::jsonb, 'asset_current', false, null, 100),
  ('AG', 'default', '1150', 'ABST input tax', '{}'::jsonb, 'asset_current', false, null, 110),
  ('AG', 'default', '1155', 'ABST refundable by the Inland Revenue Department — net of a filed return', '{}'::jsonb, 'asset_current', true, null, 120),
  ('AG', 'default', '1160', 'Advances to staff', '{}'::jsonb, 'asset_current', false, null, 130),
  ('AG', 'default', '1200', 'Inventories — goods for resale', '{}'::jsonb, 'asset_current', false, null, 140),
  ('AG', 'default', '1210', 'Inventories — raw materials', '{}'::jsonb, 'asset_current', false, null, 150),
  ('AG', 'default', '1220', 'Inventories — work in progress', '{}'::jsonb, 'asset_current', false, null, 160),
  ('AG', 'default', '1230', 'Inventories — finished goods', '{}'::jsonb, 'asset_current', false, null, 170),
  ('AG', 'default', '1300', 'Short-term investments', '{}'::jsonb, 'asset_current', false, null, 180),
  ('AG', 'default', '1350', 'Current tax recoverable', '{}'::jsonb, 'asset_current', false, null, 190),
  ('AG', 'default', '1400', 'Prepayments', '{}'::jsonb, 'asset_prepayments', false, null, 200),
  ('AG', 'default', '1410', 'Accrued income', '{}'::jsonb, 'asset_prepayments', false, null, 210),
  ('AG', 'default', '1600', 'Land and buildings — cost', '{}'::jsonb, 'asset_fixed', false, null, 220),
  ('AG', 'default', '1601', 'Land and buildings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 230),
  ('AG', 'default', '1610', 'Leasehold improvements — cost', '{}'::jsonb, 'asset_fixed', false, null, 240),
  ('AG', 'default', '1611', 'Leasehold improvements — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 250),
  ('AG', 'default', '1620', 'Plant and machinery — cost', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('AG', 'default', '1621', 'Plant and machinery — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('AG', 'default', '1630', 'Office equipment — cost', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('AG', 'default', '1631', 'Office equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('AG', 'default', '1640', 'Computers — cost', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('AG', 'default', '1641', 'Computers — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('AG', 'default', '1650', 'Furniture and fittings — cost', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('AG', 'default', '1651', 'Furniture and fittings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('AG', 'default', '1660', 'Motor vehicles — cost', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('AG', 'default', '1661', 'Motor vehicles — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('AG', 'default', '1670', 'Right-of-use assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('AG', 'default', '1671', 'Right-of-use assets — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('AG', 'default', '1700', 'Investment property', '{}'::jsonb, 'asset_non_current', false, null, 380),
  ('AG', 'default', '1750', 'Intangible assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 390),
  ('AG', 'default', '1751', 'Intangible assets — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 400),
  ('AG', 'default', '1760', 'Goodwill', '{}'::jsonb, 'asset_fixed', false, null, 410),
  ('AG', 'default', '1800', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('AG', 'default', '1810', 'Investments in joint ventures', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('AG', 'default', '1830', 'Long-term financial assets', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('AG', 'default', '1840', 'Long-term deposits', '{}'::jsonb, 'asset_non_current', false, null, 450),
  ('AG', 'default', '1900', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('AG', 'default', '2000', 'Trade payables', '{}'::jsonb, 'liability_payable', true, null, 470),
  ('AG', 'default', '2010', 'Accrued expenses', '{}'::jsonb, 'liability_current', false, null, 480),
  ('AG', 'default', '2020', 'Other payables', '{}'::jsonb, 'liability_current', false, null, 490),
  ('AG', 'default', '2030', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 500),
  ('AG', 'default', '2040', 'Deposits received from customers', '{}'::jsonb, 'liability_current', false, null, 510),
  ('AG', 'default', '2100', 'ABST output tax', '{}'::jsonb, 'liability_current', false, null, 520),
  ('AG', 'default', '2110', 'ABST payable to the Inland Revenue Department — net of a filed return', '{}'::jsonb, 'liability_current', true, null, 530),
  ('AG', 'default', '2125', 'ABST payable to the Comptroller of Customs on imports', '{}'::jsonb, 'liability_current', false, null, 540),
  ('AG', 'default', '2126', 'Other taxes and levies payable to the Inland Revenue Department', '{}'::jsonb, 'liability_current', false, null, 550),
  ('AG', 'default', '2140', 'PAYE and tax deducted at source payable to the Inland Revenue Department', '{}'::jsonb, 'liability_current', false, null, 560),
  ('AG', 'default', '2150', 'Social Security and Medical Benefits contributions payable', '{}'::jsonb, 'liability_current', false, null, 570),
  ('AG', 'default', '2155', 'Education Levy and other payroll levies payable', '{}'::jsonb, 'liability_current', false, null, 580),
  ('AG', 'default', '2160', 'Other statutory deductions payable', '{}'::jsonb, 'liability_current', false, null, 590),
  ('AG', 'default', '2165', 'Other statutory payables', '{}'::jsonb, 'liability_current', false, null, 600),
  ('AG', 'default', '2180', 'Salaries payable', '{}'::jsonb, 'liability_current', false, null, 610),
  ('AG', 'default', '2190', 'Directors'' fees payable', '{}'::jsonb, 'liability_current', false, null, 620),
  ('AG', 'default', '2200', 'Bank overdraft', '{}'::jsonb, 'liability_current', false, null, 630),
  ('AG', 'default', '2210', 'Bank loans — current portion', '{}'::jsonb, 'liability_current', false, null, 640),
  ('AG', 'default', '2220', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 650),
  ('AG', 'default', '2230', 'Hire purchase — current portion', '{}'::jsonb, 'liability_current', false, null, 660),
  ('AG', 'default', '2240', 'Corporate credit card', '{}'::jsonb, 'liability_credit_card', false, null, 670),
  ('AG', 'default', '2250', 'Amounts due to directors', '{}'::jsonb, 'liability_current', false, null, 680),
  ('AG', 'default', '2300', 'Current tax payable', '{}'::jsonb, 'liability_current', false, null, 690),
  ('AG', 'default', '2350', 'Provision for unutilised leave', '{}'::jsonb, 'liability_current', false, null, 700),
  ('AG', 'default', '2360', 'Other provisions — current', '{}'::jsonb, 'liability_current', false, null, 710),
  ('AG', 'default', '2400', 'Bank loans — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 720),
  ('AG', 'default', '2410', 'Lease liabilities — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 730),
  ('AG', 'default', '2420', 'Hire purchase — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 740),
  ('AG', 'default', '2430', 'Loans from shareholders and directors — non-current', '{}'::jsonb, 'liability_non_current', false, null, 750),
  ('AG', 'default', '2500', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 760),
  ('AG', 'default', '2550', 'Provision for reinstatement costs', '{}'::jsonb, 'liability_non_current', false, null, 770),
  ('AG', 'default', '2990', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 780),
  ('AG', 'default', '3000', 'Share capital', '{}'::jsonb, 'equity', false, null, 790),
  ('AG', 'default', '3010', 'Treasury shares', '{}'::jsonb, 'equity', false, null, 800),
  ('AG', 'default', '3100', 'Other reserves', '{}'::jsonb, 'equity', false, null, 810),
  ('AG', 'default', '3110', 'Foreign currency translation reserve', '{}'::jsonb, 'equity', false, null, 820),
  ('AG', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 830),
  ('AG', 'default', '3210', 'Dividends paid', '{}'::jsonb, 'equity_retained', false, null, 840),
  ('AG', 'default', '4000', 'Sales of goods', '{}'::jsonb, 'income', false, null, 850),
  ('AG', 'default', '4010', 'Services rendered', '{}'::jsonb, 'income', false, null, 860),
  ('AG', 'default', '4020', 'Export sales of goods', '{}'::jsonb, 'income', false, null, 870),
  ('AG', 'default', '4030', 'Export of services', '{}'::jsonb, 'income', false, null, 880),
  ('AG', 'default', '4500', 'Interest income', '{}'::jsonb, 'income_other', false, null, 890),
  ('AG', 'default', '4510', 'Dividend income', '{}'::jsonb, 'income_other', false, null, 900),
  ('AG', 'default', '4520', 'Rental income', '{}'::jsonb, 'income_other', false, null, 910),
  ('AG', 'default', '4530', 'Government grants', '{}'::jsonb, 'income_other', false, null, 920),
  ('AG', 'default', '4700', 'Foreign exchange gains', '{}'::jsonb, 'income_other', false, null, 930),
  ('AG', 'default', '4750', 'Gain on disposal of property plant and equipment', '{}'::jsonb, 'income_other', false, null, 940),
  ('AG', 'default', '4790', 'Other income', '{}'::jsonb, 'income_other', false, null, 950),
  ('AG', 'default', '5000', 'Purchases of goods for resale', '{}'::jsonb, 'expense_direct_cost', false, null, 960),
  ('AG', 'default', '5010', 'Freight inwards and import duties', '{}'::jsonb, 'expense_direct_cost', false, null, 970),
  ('AG', 'default', '5020', 'Subcontract costs', '{}'::jsonb, 'expense_direct_cost', false, null, 980),
  ('AG', 'default', '5100', 'Changes in inventories', '{}'::jsonb, 'expense_direct_cost', false, null, 990),
  ('AG', 'default', '6000', 'Salaries and wages', '{}'::jsonb, 'expense', false, null, 1000),
  ('AG', 'default', '6010', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 1010),
  ('AG', 'default', '6020', 'Directors'' fees', '{}'::jsonb, 'expense', false, null, 1020),
  ('AG', 'default', '6030', 'Social Security and Medical Benefits contributions — employer', '{}'::jsonb, 'expense', false, null, 1030),
  ('AG', 'default', '6035', 'Other employer payroll levies', '{}'::jsonb, 'expense', false, null, 1040),
  ('AG', 'default', '6040', 'Staff pension scheme contributions — employer', '{}'::jsonb, 'expense', false, null, 1050),
  ('AG', 'default', '6050', 'Retirement gratuity and end-of-service benefits', '{}'::jsonb, 'expense', false, null, 1060),
  ('AG', 'default', '6060', 'Staff welfare', '{}'::jsonb, 'expense', false, null, 1070),
  ('AG', 'default', '6070', 'Staff medical expenses and insurance', '{}'::jsonb, 'expense', false, null, 1080),
  ('AG', 'default', '6080', 'Staff training', '{}'::jsonb, 'expense', false, null, 1090),
  ('AG', 'default', '6200', 'Depreciation of property plant and equipment', '{}'::jsonb, 'expense_depreciation', false, null, 1100),
  ('AG', 'default', '6210', 'Depreciation of right-of-use assets', '{}'::jsonb, 'expense_depreciation', false, null, 1110),
  ('AG', 'default', '6220', 'Amortisation of intangible assets', '{}'::jsonb, 'expense_depreciation', false, null, 1120),
  ('AG', 'default', '6300', 'Rent — short-term leases', '{}'::jsonb, 'expense', false, null, 1130),
  ('AG', 'default', '6310', 'Utilities', '{}'::jsonb, 'expense', false, null, 1140),
  ('AG', 'default', '6320', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 1150),
  ('AG', 'default', '6330', 'Cleaning and security services', '{}'::jsonb, 'expense', false, null, 1160),
  ('AG', 'default', '6340', 'Telephone and internet', '{}'::jsonb, 'expense', false, null, 1170),
  ('AG', 'default', '6350', 'Software subscriptions', '{}'::jsonb, 'expense', false, null, 1180),
  ('AG', 'default', '6360', 'Advertising and marketing', '{}'::jsonb, 'expense', false, null, 1190),
  ('AG', 'default', '6370', 'Travelling', '{}'::jsonb, 'expense', false, null, 1200),
  ('AG', 'default', '6380', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1210),
  ('AG', 'default', '6390', 'Entertainment', '{}'::jsonb, 'expense', false, null, 1220),
  ('AG', 'default', '6400', 'Subscriptions and memberships', '{}'::jsonb, 'expense', false, null, 1230),
  ('AG', 'default', '6410', 'Insurance', '{}'::jsonb, 'expense', false, null, 1240),
  ('AG', 'default', '6420', 'Professional fees', '{}'::jsonb, 'expense', false, null, 1250),
  ('AG', 'default', '6430', 'Audit fees', '{}'::jsonb, 'expense', false, null, 1260),
  ('AG', 'default', '6440', 'Company secretarial and registration fees', '{}'::jsonb, 'expense', false, null, 1270),
  ('AG', 'default', '6450', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1280),
  ('AG', 'default', '6455', 'Sponsorships and community contributions', '{}'::jsonb, 'expense', false, null, 1290),
  ('AG', 'default', '6460', 'Printing and stationery', '{}'::jsonb, 'expense', false, null, 1300),
  ('AG', 'default', '6470', 'Postage and courier', '{}'::jsonb, 'expense', false, null, 1310),
  ('AG', 'default', '6480', 'Licences permits and local authority fees', '{}'::jsonb, 'expense', false, null, 1320),
  ('AG', 'default', '6490', 'Royalties', '{}'::jsonb, 'expense', false, null, 1330),
  ('AG', 'default', '6500', 'Bad debts written off', '{}'::jsonb, 'expense', false, null, 1340),
  ('AG', 'default', '6510', 'Impairment loss on trade receivables', '{}'::jsonb, 'expense', false, null, 1350),
  ('AG', 'default', '6900', 'Donations', '{}'::jsonb, 'expense', false, null, 1360),
  ('AG', 'default', '6950', 'Foreign exchange losses', '{}'::jsonb, 'expense', false, null, 1370),
  ('AG', 'default', '6960', 'Loss on disposal of property plant and equipment', '{}'::jsonb, 'expense', false, null, 1380),
  ('AG', 'default', '6990', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1390),
  ('AG', 'default', '7000', 'Interest on bank loans', '{}'::jsonb, 'expense', false, null, 1400),
  ('AG', 'default', '7010', 'Interest on lease liabilities', '{}'::jsonb, 'expense', false, null, 1410),
  ('AG', 'default', '7020', 'Hire purchase interest', '{}'::jsonb, 'expense', false, null, 1420),
  ('AG', 'default', '7030', 'Interest on loans from related parties and others', '{}'::jsonb, 'expense', false, null, 1430),
  ('AG', 'default', '8000', 'Current income tax expense', '{}'::jsonb, 'expense', false, null, 1440),
  ('AG', 'default', '8010', 'Deferred tax expense', '{}'::jsonb, 'expense', false, null, 1450),
  ('AG', 'default', '8020', 'Under or over provision of income tax in prior years', '{}'::jsonb, 'expense', false, null, 1460)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('AG', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('AG', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('AG', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('AG', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('AG', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('AG', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
on conflict (country, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  journal_type = excluded.journal_type,
  sequence     = excluded.sequence;

insert into tax_templates
  (country, code, name, name_i18n, description, amount_type, amount, applies_to, treatment,
   valid_from, valid_to, legal_reference, vat_category, exemption_code, sequence,
   tax_kind, recoverable, conditions, jurisdiction, price_include, cash_basis,
   cash_basis_transition_account_code, source_key,
   applies_seller_territory, applies_buyer_territory, applies_supply_territory,
   applies_supply_vs_seller)
values
  ('AG', 'AG-P-17', 'Purchase, standard rate 17 %, deductible', '{}'::jsonb, 'A local purchase from a person registered for ABST, for a taxable activity: the input tax is claimed.', 'percent', 17, 'purchase', 'domestic', date '2024-01-01', null, 'The Antigua and Barbuda Sales Tax Act 2006, s. 8(3)(d) — the rate is 15 per cent in any case not otherwise provided for. The Inland Revenue Department announced on 22 December 2023 that the rate rises from 15 % to 17 % on 1 January 2024 (Sovos, reporting the announcement) and the 2024 Budget Statement of 15 December 2023 confirmed it (Orbitax). The statute that raises the rate was not found among the Acts published on laws.gov.ag and the Department''s own notice was not opened, so the figure rests on guidance; the form AB03 on the Department''s site (version of July 2022) and its FAQ still print 15 %. The Antigua and Barbuda Sales Tax Act 2006, s. 29(1) — if all the person''s supplies in the period are taxable, the input tax on taxable acquisitions and imports is allowed in full. Line 310 takes the value of domestic purchases and line 330 the ABST paid on them.', 'S', null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'rate-2024-sovos', null, null, null, null),
  ('AG', 'AG-P-17-BL', 'Purchase, standard rate 17 %, input tax not allowed', '{}'::jsonb, 'A purchase on which section 28 refuses the credit — a passenger vehicle, entertainment, a club membership or a private use: the tax is part of the cost.', 'percent', 17, 'purchase', 'domestic', date '2024-01-01', null, 'The Antigua and Barbuda Sales Tax Act 2006, s. 28(2) — no input tax credit arises to the extent that the acquisition is not made for the taxable activity (a), is a passenger vehicle or its spare parts and repairs, unless the person deals in or hires out vehicles (b), is used to provide entertainment (c), is a membership of a sporting, social or recreational club (d) or is otherwise private or domestic (e). The tax stays in the cost of the asset or the expense. The Antigua and Barbuda Sales Tax Act 2006, s. 8(3)(d) — the rate is 15 per cent in any case not otherwise provided for. The Inland Revenue Department announced on 22 December 2023 that the rate rises from 15 % to 17 % on 1 January 2024 (Sovos, reporting the announcement) and the 2024 Budget Statement of 15 December 2023 confirmed it (Orbitax). The statute that raises the rate was not found among the Acts published on laws.gov.ag and the Department''s own notice was not opened, so the figure rests on guidance; the form AB03 on the Department''s site (version of July 2022) and its FAQ still print 15 %. ', 'S', null, 70, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'abst-act-2006', null, null, null, null),
  ('AG', 'AG-P-EX', 'Purchase, exempt', '{}'::jsonb, 'A local purchase of an exempt supply: no tax was charged, and none can be claimed.', 'percent', 0, 'purchase', 'exempt', date '2007-01-29', null, 'The Antigua and Barbuda Sales Tax Act 2006, Schedule 4: an exempt supply carries no ABST. Value on line 310 of form AB03.', 'E', null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'abst-act-2006', null, null, null, null),
  ('AG', 'AG-P-IMP', 'Import of goods, ABST paid at the border', '{}'::jsonb, 'The ABST the Comptroller of Customs collects on a taxable import, claimed as input tax.', 'percent', 17, 'purchase', 'import', date '2024-01-01', null, 'The Antigua and Barbuda Sales Tax Act 2006, s. 8(1)(b) — ABST is levied on a taxable import; s. 29(1) — the input tax on a taxable import is allowed. Form AB03, line 300 (value of imports) and line 320 (ABST paid to the Comptroller of Customs on imports). The customs value on which the ABST is computed is entered by the user. The Antigua and Barbuda Sales Tax Act 2006, s. 8(3)(d) — the rate is 15 per cent in any case not otherwise provided for. The Inland Revenue Department announced on 22 December 2023 that the rate rises from 15 % to 17 % on 1 January 2024 (Sovos, reporting the announcement) and the 2024 Budget Statement of 15 December 2023 confirmed it (Orbitax). The statute that raises the rate was not found among the Acts published on laws.gov.ag and the Department''s own notice was not opened, so the figure rests on guidance; the form AB03 on the Department''s site (version of July 2022) and its FAQ still print 15 %. ', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'abst-act-2006', null, null, null, null),
  ('AG', 'AG-P-IMP-EX', 'Import of exempt goods', '{}'::jsonb, 'An import Schedule 5 exempts.', 'percent', 0, 'purchase', 'import', date '2007-01-29', null, 'The Antigua and Barbuda Sales Tax Act 2006, Schedule 5 — imports exempt from ABST. Value on line 300 of form AB03.', null, null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'abst-act-2006', null, null, null, null),
  ('AG', 'AG-P-IMP-ZR', 'Import of zero-rated goods', '{}'::jsonb, 'An import of goods Schedule 3 zero-rates.', 'percent', 0, 'purchase', 'import', date '2007-01-29', null, 'The Antigua and Barbuda Sales Tax Act 2006, s. 8(3)(a) and Schedule 3, paragraph (2): a supply or import of the goods listed is zero-rated. Value on line 300 of form AB03.', null, null, 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'abst-act-2006', null, null, null, null),
  ('AG', 'AG-P-NR', 'Purchase from a supplier not registered for ABST', '{}'::jsonb, 'A purchase from a person who does not charge ABST: nothing to claim.', 'percent', 0, 'purchase', 'not_subject', date '2007-01-29', null, 'The Department''s FAQ, question 9 — only a business registered for ABST can charge the tax; a supplier below the EC$300,000 threshold (question 11) charges none, so there is no input tax to claim. The value is entered on line 310 of form AB03 with the other domestic purchases.', 'O', null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'abst-faq', null, null, null, null),
  ('AG', 'AG-P-ZR', 'Purchase, zero-rated', '{}'::jsonb, 'A local purchase of a zero-rated good or service.', 'percent', 0, 'purchase', 'domestic', date '2007-01-29', null, 'The Antigua and Barbuda Sales Tax Act 2006, s. 8(3)(a) and Schedule 3: the supplier charges zero per cent. Value on line 310 of form AB03.', 'Z', null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'abst-act-2006', null, null, null, null),
  ('AG', 'AG-S-17', 'Sale, standard rate 17 %', '{}'::jsonb, 'The general rate on a taxable supply of goods or services by a person registered for ABST, from 1 January 2024.', 'percent', 17, 'sale', 'domestic', date '2024-01-01', null, 'The Antigua and Barbuda Sales Tax Act 2006, s. 8(3)(d) — the rate is 15 per cent in any case not otherwise provided for. The Inland Revenue Department announced on 22 December 2023 that the rate rises from 15 % to 17 % on 1 January 2024 (Sovos, reporting the announcement) and the 2024 Budget Statement of 15 December 2023 confirmed it (Orbitax). The statute that raises the rate was not found among the Acts published on laws.gov.ag and the Department''s own notice was not opened, so the figure rests on guidance; the form AB03 on the Department''s site (version of July 2022) and its FAQ still print 15 %. Line 200 of the return takes the standard-rated sales and line 250 the ABST on them.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'rate-2024-sovos', null, null, null, null),
  ('AG', 'AG-S-EX', 'Sale, exempt', '{}'::jsonb, 'A supply Schedule 4 lists as exempt — financial services and insurance, education services, medical services, residential property and passenger transport within the country among them.', 'percent', 0, 'sale', 'exempt', date '2007-01-29', null, 'The Antigua and Barbuda Sales Tax Act 2006, Schedule 4, paragraph (1) — a supply listed in one of the items is an exempt supply: item 1 financial services and insurance, item 4 and 5 residential property and leases, item 9 passenger transport within the country, item 10 education services, item 11 medical, dental and nursing services, item 13 prescription medicines, and the others the Schedule lists. Exempt is not taxable (FAQ, question 7) and carries no input tax credit (s. 29). Line 230 of form AB03.', 'E', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'abst-act-2006', null, null, null, null),
  ('AG', 'AG-S-ZR-DOM', 'Sale, zero-rated (local supply)', '{}'::jsonb, 'A local supply Schedule 3 zero-rates: food of a kind the Regulations specify, electricity for domestic use, water, fuel under the tariff headings 2710 and 2711 and the goods the Regulations list.', 'percent', 0, 'sale', 'domestic', date '2007-01-29', null, 'The Antigua and Barbuda Sales Tax Act 2006, s. 8(3)(a); Schedule 3, paragraph (2), items 1 to 5 — food for human consumption of a kind specified in the Regulations, goods specified in the Regulations, electricity for residential domestic use, water and fuel (Customs Tariff headings 2710.10 to 2710.40 and 2711.00) are zero-rated. The Regulations were not read: which food and which goods are zero-rated is for the user and the accountant. Line 220 of form AB03.', 'Z', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'abst-act-2006', null, null, null, null),
  ('AG', 'AG-S-ZR-EXPG', 'Sale, zero-rated (export of goods)', '{}'::jsonb, 'A supply of goods the supplier has entered, or will enter, for export under the Customs (Control and Management) Act, or that the Commissioner is satisfied have been or will be exported.', 'percent', 0, 'sale', 'export', date '2007-01-29', null, 'The Antigua and Barbuda Sales Tax Act 2006, s. 8(3)(a) — a zero-rated supply is taxed at zero per cent; Schedule 1, paragraph (1), items 1 and 2 — a supply of goods entered or to be entered for export and actually exported, or exported by the supplier to the Commissioner''s satisfaction, is zero-rated; paragraphs (2) and (3) refuse the zero rate to goods altered or used in Antigua and Barbuda after the supply and to unprocessed agricultural products. Line 220 of form AB03.', 'G', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'abst-act-2006', null, null, null, null),
  ('AG', 'AG-S-ZR-EXPS', 'Sale, zero-rated (export of services)', '{}'::jsonb, 'A supply of services listed in Schedule 2 — services in connection with land or goods outside Antigua and Barbuda, and the other items the Schedule lists.', 'percent', 0, 'sale', 'export', date '2007-01-29', null, 'The Antigua and Barbuda Sales Tax Act 2006, s. 8(3)(a); Schedule 2, paragraph (1) — a taxable supply listed in one of the items (services in connection with land or improvements to land outside Antigua and Barbuda, with goods outside the country when the services are performed, with goods temporarily imported, services physically performed outside the country, and the others the Schedule lists) is zero-rated, subject to paragraphs (2) and (3), which refuse it to some services consumed in the country. Line 220 of form AB03.', 'G', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'abst-act-2006', null, null, null, null)
on conflict (country, code) do update set
  name            = excluded.name,
  name_i18n       = excluded.name_i18n,
  description     = excluded.description,
  amount_type     = excluded.amount_type,
  amount          = excluded.amount,
  applies_to      = excluded.applies_to,
  treatment       = excluded.treatment,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference,
  vat_category    = excluded.vat_category,
  exemption_code  = excluded.exemption_code,
  sequence        = excluded.sequence,
  tax_kind        = excluded.tax_kind,
  recoverable     = excluded.recoverable,
  conditions      = excluded.conditions,
  jurisdiction    = excluded.jurisdiction,
  price_include   = excluded.price_include,
  cash_basis      = excluded.cash_basis,
  cash_basis_transition_account_code = excluded.cash_basis_transition_account_code,
  source_key      = excluded.source_key,
  applies_seller_territory = excluded.applies_seller_territory,
  applies_buyer_territory  = excluded.applies_buyer_territory,
  applies_supply_territory = excluded.applies_supply_territory,
  applies_supply_vs_seller = excluded.applies_supply_vs_seller;

insert into tax_posting_templates
  (tax_template_id, document_kind, posting_type, factor_percent, account_code,
   declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
select t.id,
       v.document_kind::tax_document_kind,
       v.posting_type::tax_posting_type,
       v.factor_percent::numeric,
       v.account_code::text,
       v.declaration_box::text,
       v.declaration_boxes::text[],
       v.box_factor_percent::numeric,
       v.report_code::text,
       v.sequence::integer
  from (values
    ('AG-P-17', 'invoice', 'base', 100, null, '310', array['310']::text[], 100, 'AG-AB03', 10),
    ('AG-P-17', 'invoice', 'tax', 100, '1150', '330', array['330']::text[], 100, 'AG-AB03', 20),
    ('AG-P-17', 'credit_note', 'base', 100, null, '310', array['310']::text[], -100, 'AG-AB03', 10),
    ('AG-P-17', 'credit_note', 'tax', 100, '1150', '330', array['330']::text[], -100, 'AG-AB03', 20),
    ('AG-P-17-BL', 'invoice', 'base', 100, null, '310', array['310']::text[], 100, 'AG-AB03', 10),
    ('AG-P-17-BL', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('AG-P-17-BL', 'credit_note', 'base', 100, null, '310', array['310']::text[], -100, 'AG-AB03', 10),
    ('AG-P-17-BL', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('AG-P-EX', 'invoice', 'base', 100, null, '310', array['310']::text[], 100, 'AG-AB03', 10),
    ('AG-P-EX', 'credit_note', 'base', 100, null, '310', array['310']::text[], -100, 'AG-AB03', 10),
    ('AG-P-IMP', 'invoice', 'base', 100, null, '300', array['300']::text[], 100, 'AG-AB03', 10),
    ('AG-P-IMP', 'invoice', 'tax', 100, '1150', '320', array['320']::text[], 100, 'AG-AB03', 20),
    ('AG-P-IMP', 'invoice', 'tax', -100, '2125', null, null, 100, null, 30),
    ('AG-P-IMP', 'credit_note', 'base', 100, null, '300', array['300']::text[], -100, 'AG-AB03', 10),
    ('AG-P-IMP', 'credit_note', 'tax', 100, '1150', '320', array['320']::text[], -100, 'AG-AB03', 20),
    ('AG-P-IMP', 'credit_note', 'tax', -100, '2125', null, null, 100, null, 30),
    ('AG-P-IMP-EX', 'invoice', 'base', 100, null, '300', array['300']::text[], 100, 'AG-AB03', 10),
    ('AG-P-IMP-EX', 'credit_note', 'base', 100, null, '300', array['300']::text[], -100, 'AG-AB03', 10),
    ('AG-P-IMP-ZR', 'invoice', 'base', 100, null, '300', array['300']::text[], 100, 'AG-AB03', 10),
    ('AG-P-IMP-ZR', 'credit_note', 'base', 100, null, '300', array['300']::text[], -100, 'AG-AB03', 10),
    ('AG-P-NR', 'invoice', 'base', 100, null, '310', array['310']::text[], 100, 'AG-AB03', 10),
    ('AG-P-NR', 'credit_note', 'base', 100, null, '310', array['310']::text[], -100, 'AG-AB03', 10),
    ('AG-P-ZR', 'invoice', 'base', 100, null, '310', array['310']::text[], 100, 'AG-AB03', 10),
    ('AG-P-ZR', 'credit_note', 'base', 100, null, '310', array['310']::text[], -100, 'AG-AB03', 10),
    ('AG-S-17', 'invoice', 'base', 100, null, '200', array['200']::text[], 100, 'AG-AB03', 10),
    ('AG-S-17', 'invoice', 'tax', 100, '2100', '250', array['250']::text[], 100, 'AG-AB03', 20),
    ('AG-S-17', 'credit_note', 'base', 100, null, '200', array['200']::text[], -100, 'AG-AB03', 10),
    ('AG-S-17', 'credit_note', 'tax', 100, '2100', '250', array['250']::text[], -100, 'AG-AB03', 20),
    ('AG-S-EX', 'invoice', 'base', 100, null, '230', array['230']::text[], 100, 'AG-AB03', 10),
    ('AG-S-EX', 'credit_note', 'base', 100, null, '230', array['230']::text[], -100, 'AG-AB03', 10),
    ('AG-S-ZR-DOM', 'invoice', 'base', 100, null, '220', array['220']::text[], 100, 'AG-AB03', 10),
    ('AG-S-ZR-DOM', 'credit_note', 'base', 100, null, '220', array['220']::text[], -100, 'AG-AB03', 10),
    ('AG-S-ZR-EXPG', 'invoice', 'base', 100, null, '220', array['220']::text[], 100, 'AG-AB03', 10),
    ('AG-S-ZR-EXPG', 'credit_note', 'base', 100, null, '220', array['220']::text[], -100, 'AG-AB03', 10),
    ('AG-S-ZR-EXPS', 'invoice', 'base', 100, null, '220', array['220']::text[], 100, 'AG-AB03', 10),
    ('AG-S-ZR-EXPS', 'credit_note', 'base', 100, null, '220', array['220']::text[], -100, 'AG-AB03', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'AG' and t.code = v.tax_code
on conflict (tax_template_id, document_kind, posting_type, sequence) do update set
  factor_percent     = excluded.factor_percent,
  account_code       = excluded.account_code,
  declaration_box    = excluded.declaration_box,
  declaration_boxes  = excluded.declaration_boxes,
  box_factor_percent = excluded.box_factor_percent,
  report_code        = excluded.report_code;

insert into tax_report_templates
  (country, code, name, periods, period_default, valid_from, valid_to, legal_reference,
   is_periodic_return, deadline_rule, deadline_day, deadline_plus_days,
   deadline_reference, deadline_source_key, file_format)
values
  ('AG', 'AG-AB03', 'ABST return (form AB03)', array['month']::declaration_period[], 'month'::declaration_period, date '2007-01-29', null, 'The Antigua and Barbuda Sales Tax Act 2006, s. 39 — a taxable person lodges an ABST return for each tax period on the form the Commissioner prescribes; the FAQ (questions 17 and 18) — every registered business files monthly, and a nil return is filed when there were no sales. The form is AB03; this pack carries the lines a document writes into and the totals between them (200 to 400). Lines 210, 260 (accommodation and other supplies to guests at the special rate) are not carried: see the README. Penalties for a late return and a late payment are in the README.', true,'day_of_month_after_period'::filing_deadline_rule, 15, null, 'The Antigua and Barbuda Sales Tax (Amendment) Act 2024, s. 3 — section 39(1) of the Act now reads "a taxable person must lodge an ABST return for each tax period no later than fifteen (15) calendar days after the end of the period", applicable from the tax period ending 31 March 2024. Before it, the Act (s. 39(1)) and the FAQ (question 17) gave one calendar month. The Act does not move a date that falls on a weekend or a holiday; the FAQ does (next working day), and the pack does not carry that.', 'abst-amend-2024', null)
on conflict (country, code) do update set
  name                = excluded.name,
  periods             = excluded.periods,
  period_default      = excluded.period_default,
  valid_from          = excluded.valid_from,
  valid_to            = excluded.valid_to,
  legal_reference     = excluded.legal_reference,
  is_periodic_return  = excluded.is_periodic_return,
  deadline_rule       = excluded.deadline_rule,
  deadline_day        = excluded.deadline_day,
  deadline_plus_days  = excluded.deadline_plus_days,
  deadline_reference  = excluded.deadline_reference,
  deadline_source_key = excluded.deadline_source_key,
  file_format         = excluded.file_format;

insert into tax_report_box_templates
  (country, report_code, box, kind, name, name_i18n, sequence, print_sequence,
   plus_boxes, minus_boxes, rate, rate_of_box, floor_zero, hidden, xml_element,
   legal_reference, source_key)
values
  ('AG', 'AG-AB03', '200', 'base', 'Line 200 — Standard-rated supplies (sales), value without ABST', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form AB03, line 200 — standard-rated supplies. The form prints the line ABST-inclusive (the Act''s s. 57 requires inclusive prices); this box holds the value without tax and the total below adds the tax back.', 'ab03-form'),
  ('AG', 'AG-AB03', '250', 'tax', 'Line 250 — ABST payable on standard-rated supplies', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form AB03, line 250 = line 200 × (rate / (100 + rate)), 17/117 from 1 January 2024.', 'ab03-form'),
  ('AG', 'AG-AB03', '200I', 'total', 'Line 200 as printed — standard-rated supplies, ABST included', '{}'::jsonb, 30, null, array['200', '250']::text[], '{}'::text[], null, null, false, false, null, 'Form AB03, line 200, ABST-inclusive as the form prints it.', 'ab03-form'),
  ('AG', 'AG-AB03', '220', 'base', 'Line 220 — Zero-rated supplies (sales)', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form AB03, line 220 — zero-rated supplies, exports and local.', 'ab03-form'),
  ('AG', 'AG-AB03', '230', 'base', 'Line 230 — Exempt supplies (sales)', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form AB03, line 230 — exempt supplies.', 'ab03-form'),
  ('AG', 'AG-AB03', '240', 'total', 'Line 240 — Total supplies', '{}'::jsonb, 60, null, array['200I', '220', '230']::text[], '{}'::text[], null, null, false, false, null, 'Form AB03, line 240 — the total of lines 200, 220 and 230.', 'ab03-form'),
  ('AG', 'AG-AB03', '270', 'tax', 'Line 270 — ABST adjustments (debit notes issued, credit notes received)', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form AB03, line 270 — declared and empty: a credit note issued is written into lines 200 and 250 by the document itself, so the line stays for the adjustments the preparer enters by hand.', 'ab03-form'),
  ('AG', 'AG-AB03', '295', 'total', 'Line 295 — Total output tax for this period', '{}'::jsonb, 80, null, array['250', '270']::text[], '{}'::text[], null, null, false, false, null, 'Form AB03, line 295 — the total of lines 250 and 270.', 'ab03-form'),
  ('AG', 'AG-AB03', '300', 'base', 'Line 300 — Total value of imports (standard-rated, zero-rated and exempt)', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form AB03, line 300.', 'ab03-form'),
  ('AG', 'AG-AB03', '310', 'base', 'Line 310 — Total value of domestic purchases (standard-rated, zero-rated and exempt)', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form AB03, line 310.', 'ab03-form'),
  ('AG', 'AG-AB03', '320', 'tax', 'Line 320 — ABST paid to the Comptroller of Customs on imports', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form AB03, line 320.', 'ab03-form'),
  ('AG', 'AG-AB03', '330', 'tax', 'Line 330 — ABST paid or payable on local taxable purchases', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form AB03, line 330.', 'ab03-form'),
  ('AG', 'AG-AB03', '340', 'tax', 'Line 340 — ABST adjustments (debit notes received, credit notes issued)', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form AB03, line 340 — declared and empty, for the reason given at line 270.', 'ab03-form'),
  ('AG', 'AG-AB03', '395', 'total', 'Line 395 — Total input tax for this period', '{}'::jsonb, 140, null, array['320', '330', '340']::text[], '{}'::text[], null, null, false, false, null, 'Form AB03, line 395 — the total of lines 320, 330 and 340.', 'ab03-form'),
  ('AG', 'AG-AB03', '400', 'total', 'Line 400 — Tax payable (positive) or excess credit (negative)', '{}'::jsonb, 150, null, array['295']::text[], array['395']::text[], null, null, false, false, null, 'Form AB03, line 400 is line 295 less line 395 when 295 is the greater; line 500 (excess credit) is line 395 less line 295 when 395 is the greater. The two are one signed figure here. Lines 100 (credit brought forward), 410 to 430 (payment) and 510 and 600 settle one period against the next and are not documents.', 'ab03-form')
on conflict (country, report_code, box, kind) do update set
  name            = excluded.name,
  name_i18n       = excluded.name_i18n,
  sequence        = excluded.sequence,
  print_sequence  = excluded.print_sequence,
  plus_boxes      = excluded.plus_boxes,
  minus_boxes     = excluded.minus_boxes,
  rate            = excluded.rate,
  rate_of_box     = excluded.rate_of_box,
  floor_zero      = excluded.floor_zero,
  hidden          = excluded.hidden,
  xml_element     = excluded.xml_element,
  legal_reference = excluded.legal_reference,
  source_key      = excluded.source_key;

insert into statement_templates
  (code, country, chart_code, name, kind, framework, valid_from, valid_to, legal_reference,
   source_key, result_in_progress, result_in_progress_name, result_in_progress_name_i18n)
values
  ('AG-IFRS-IS', 'AG', 'default', 'Statement of profit or loss', 'income_statement', 'IFRS', date '2013-01-01', null, 'No Antiguan statute prescribes the layout of a company''s financial statements in the texts consulted. The Tax Administration and Procedure Act, 2018, s. 22(2)(a)(iii), requires records that allow financial statements to be prepared, and the Institute of Chartered Accountants of the Eastern Caribbean prescribes the accounting standards its members adopt (Act No. 23 of 2013). The layout is the one IAS 1 asks for, as in the neighbouring packs; the accounts-to-line rules are this pack''s own and are not a legal form.', 'tapa-2018', null, null, '{}'::jsonb),
  ('AG-IFRS-SFP', 'AG', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS', date '2013-01-01', null, 'No Antiguan statute prescribes the layout of a company''s financial statements in the texts consulted. The Tax Administration and Procedure Act, 2018, s. 22(2)(a)(iii), requires records that allow financial statements to be prepared, and the Institute of Chartered Accountants of the Eastern Caribbean prescribes the accounting standards its members adopt (Act No. 23 of 2013). The layout is the one IAS 1 asks for, as in the neighbouring packs; the accounts-to-line rules are this pack''s own and are not a legal form.', 'tapa-2018', 'combined', 'Result of the current financial year', '{}'::jsonb)
on conflict (code) do update set
  country         = excluded.country,
  chart_code      = excluded.chart_code,
  name            = excluded.name,
  kind            = excluded.kind,
  framework       = excluded.framework,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference,
  source_key      = excluded.source_key,
  result_in_progress           = excluded.result_in_progress,
  result_in_progress_name      = excluded.result_in_progress_name,
  result_in_progress_name_i18n = excluded.result_in_progress_name_i18n;

insert into statement_line_templates
  (statement_code, code, parent_code, name, name_i18n, sequence, sign, is_total,
   plus_lines, minus_lines, xbrl_element, legal_reference, source_key)
values
  ('AG-IFRS-IS', '1', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-IS', '2', null, 'Other income', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-IS', '3', null, 'Purchases and changes in inventories', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-IS', '4', null, 'Employee benefits expense', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-IS', '5', null, 'Depreciation and amortisation', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-IS', '6', null, 'Other operating expenses', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-IS', '7', null, 'Finance costs', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-IS', '8', null, 'Profit before tax', '{}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('AG-IFRS-IS', '9', null, 'Income tax expense', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-IS', '10', null, 'Profit for the year', '{}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, null, null),
  ('AG-IFRS-SFP', 'CA', null, 'Current assets', '{}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5', 'CA.6']::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'CA.1', null, 'Cash and cash equivalents', '{}'::jsonb, 11, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'CA.2', null, 'Trade and other receivables', '{}'::jsonb, 12, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'CA.3', null, 'Inventories', '{}'::jsonb, 13, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'CA.4', null, 'Financial assets', '{}'::jsonb, 14, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'CA.5', null, 'Current tax recoverable', '{}'::jsonb, 15, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'CA.6', null, 'Prepayments and accrued income', '{}'::jsonb, 16, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'NCA', null, 'Non-current assets', '{}'::jsonb, 20, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4', 'NCA.5', 'NCA.6', 'NCA.7']::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'NCA.1', null, 'Property, plant and equipment', '{}'::jsonb, 21, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'NCA.2', null, 'Investment property', '{}'::jsonb, 22, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'NCA.3', null, 'Intangible assets', '{}'::jsonb, 23, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'NCA.4', null, 'Investments in associates', '{}'::jsonb, 24, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'NCA.5', null, 'Investments in joint ventures', '{}'::jsonb, 25, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'NCA.6', null, 'Financial assets', '{}'::jsonb, 26, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'NCA.7', null, 'Deferred tax assets', '{}'::jsonb, 27, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'TA', null, 'Total assets', '{}'::jsonb, 30, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'CL', null, 'Current liabilities', '{}'::jsonb, 40, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4', 'CL.5']::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'CL.1', null, 'Trade and other payables', '{}'::jsonb, 41, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'CL.2', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 42, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'CL.3', null, 'Amounts due to directors', '{}'::jsonb, 43, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'CL.4', null, 'Current tax payable', '{}'::jsonb, 44, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'CL.5', null, 'Provisions', '{}'::jsonb, 45, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'NCL', null, 'Non-current liabilities', '{}'::jsonb, 50, 1, true, array['NCL.1', 'NCL.2', 'NCL.3']::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'NCL.1', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 51, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'NCL.2', null, 'Deferred tax liabilities', '{}'::jsonb, 52, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'NCL.3', null, 'Provisions', '{}'::jsonb, 53, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'TL', null, 'Total liabilities', '{}'::jsonb, 60, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'NA', null, 'Net assets', '{}'::jsonb, 70, 1, true, array['TA']::text[], array['TL']::text[], null, null, null),
  ('AG-IFRS-SFP', 'EQ', null, 'Equity', '{}'::jsonb, 80, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'EQ.1', null, 'Share capital', '{}'::jsonb, 81, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'EQ.2', null, 'Other reserves', '{}'::jsonb, 82, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AG-IFRS-SFP', 'EQ.3', null, 'Retained earnings', '{}'::jsonb, 83, -1, false, '{}'::text[], '{}'::text[], null, null, null)
on conflict (statement_code, code) do update set
  parent_code     = excluded.parent_code,
  name            = excluded.name,
  name_i18n       = excluded.name_i18n,
  sequence        = excluded.sequence,
  sign            = excluded.sign,
  is_total        = excluded.is_total,
  plus_lines      = excluded.plus_lines,
  minus_lines     = excluded.minus_lines,
  xbrl_element    = excluded.xbrl_element,
  legal_reference = excluded.legal_reference,
  source_key      = excluded.source_key;

delete from statement_line_rules r
 where r.statement_code in ('AG-IFRS-IS', 'AG-IFRS-SFP')
   and (r.statement_code, r.line_code, r.sequence) not in (
     values ('AG-IFRS-IS', '1', 10),
            ('AG-IFRS-IS', '2', 10),
            ('AG-IFRS-IS', '3', 10),
            ('AG-IFRS-IS', '4', 10),
            ('AG-IFRS-IS', '5', 10),
            ('AG-IFRS-IS', '6', 10),
            ('AG-IFRS-IS', '7', 10),
            ('AG-IFRS-IS', '9', 10),
            ('AG-IFRS-SFP', 'CA.1', 10),
            ('AG-IFRS-SFP', 'CA.2', 10),
            ('AG-IFRS-SFP', 'CA.3', 10),
            ('AG-IFRS-SFP', 'CA.4', 10),
            ('AG-IFRS-SFP', 'CA.5', 10),
            ('AG-IFRS-SFP', 'CA.6', 10),
            ('AG-IFRS-SFP', 'NCA.1', 10),
            ('AG-IFRS-SFP', 'NCA.2', 10),
            ('AG-IFRS-SFP', 'NCA.3', 10),
            ('AG-IFRS-SFP', 'NCA.4', 10),
            ('AG-IFRS-SFP', 'NCA.5', 10),
            ('AG-IFRS-SFP', 'NCA.6', 10),
            ('AG-IFRS-SFP', 'NCA.7', 10),
            ('AG-IFRS-SFP', 'CL.1', 10),
            ('AG-IFRS-SFP', 'CL.1', 20),
            ('AG-IFRS-SFP', 'CL.2', 10),
            ('AG-IFRS-SFP', 'CL.3', 10),
            ('AG-IFRS-SFP', 'CL.4', 10),
            ('AG-IFRS-SFP', 'CL.5', 10),
            ('AG-IFRS-SFP', 'NCL.1', 10),
            ('AG-IFRS-SFP', 'NCL.2', 10),
            ('AG-IFRS-SFP', 'NCL.3', 10),
            ('AG-IFRS-SFP', 'EQ.1', 10),
            ('AG-IFRS-SFP', 'EQ.2', 10),
            ('AG-IFRS-SFP', 'EQ.3', 10)
   );

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('AG-IFRS-IS', '1', 10, 'code_range', '4000', '4030', null, 'any'),
    ('AG-IFRS-IS', '2', 10, 'code_range', '4500', '4790', null, 'any'),
    ('AG-IFRS-IS', '3', 10, 'code_range', '5000', '5100', null, 'any'),
    ('AG-IFRS-IS', '4', 10, 'code_range', '6000', '6080', null, 'any'),
    ('AG-IFRS-IS', '5', 10, 'code_range', '6200', '6220', null, 'any'),
    ('AG-IFRS-IS', '6', 10, 'code_range', '6300', '6990', null, 'any'),
    ('AG-IFRS-IS', '7', 10, 'code_range', '7000', '7030', null, 'any'),
    ('AG-IFRS-IS', '9', 10, 'code_range', '8000', '8020', null, 'any'),
    ('AG-IFRS-SFP', 'CA.1', 10, 'code_range', '1000', '1040', null, 'any'),
    ('AG-IFRS-SFP', 'CA.2', 10, 'code_range', '1100', '1160', null, 'any'),
    ('AG-IFRS-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('AG-IFRS-SFP', 'CA.4', 10, 'account_code', '1300', null, null, 'any'),
    ('AG-IFRS-SFP', 'CA.5', 10, 'account_code', '1350', null, null, 'any'),
    ('AG-IFRS-SFP', 'CA.6', 10, 'code_range', '1400', '1410', null, 'any'),
    ('AG-IFRS-SFP', 'NCA.1', 10, 'code_range', '1600', '1671', null, 'any'),
    ('AG-IFRS-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('AG-IFRS-SFP', 'NCA.3', 10, 'code_range', '1750', '1760', null, 'any'),
    ('AG-IFRS-SFP', 'NCA.4', 10, 'account_code', '1800', null, null, 'any'),
    ('AG-IFRS-SFP', 'NCA.5', 10, 'account_code', '1810', null, null, 'any'),
    ('AG-IFRS-SFP', 'NCA.6', 10, 'code_range', '1830', '1840', null, 'any'),
    ('AG-IFRS-SFP', 'NCA.7', 10, 'account_code', '1900', null, null, 'any'),
    ('AG-IFRS-SFP', 'CL.1', 10, 'code_range', '2000', '2190', null, 'any'),
    ('AG-IFRS-SFP', 'CL.1', 20, 'account_code', '2990', null, null, 'credit'),
    ('AG-IFRS-SFP', 'CL.2', 10, 'code_range', '2200', '2240', null, 'any'),
    ('AG-IFRS-SFP', 'CL.3', 10, 'account_code', '2250', null, null, 'any'),
    ('AG-IFRS-SFP', 'CL.4', 10, 'account_code', '2300', null, null, 'any'),
    ('AG-IFRS-SFP', 'CL.5', 10, 'code_range', '2350', '2360', null, 'any'),
    ('AG-IFRS-SFP', 'NCL.1', 10, 'code_range', '2400', '2430', null, 'any'),
    ('AG-IFRS-SFP', 'NCL.2', 10, 'account_code', '2500', null, null, 'any'),
    ('AG-IFRS-SFP', 'NCL.3', 10, 'account_code', '2550', null, null, 'any'),
    ('AG-IFRS-SFP', 'EQ.1', 10, 'code_range', '3000', '3010', null, 'any'),
    ('AG-IFRS-SFP', 'EQ.2', 10, 'code_range', '3100', '3110', null, 'any'),
    ('AG-IFRS-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
  ) as v (statement_code, line_code, sequence, rule_kind, code_from, code_to,
          account_type, balance_side)
on conflict (statement_code, line_code, sequence) do update set
  rule_kind    = excluded.rule_kind,
  code_from    = excluded.code_from,
  code_to      = excluded.code_to,
  account_type = excluded.account_type,
  balance_side = excluded.balance_side;

insert into country_defaults
  (country, name, name_i18n, languages, currency_code, receivable_code, payable_code, suspense_code,
   rounding_code, retained_earnings_code, sales_account_code, purchase_account_code,
   bank_account_code, cash_account_code, sales_journal_code, purchase_journal_code,
   misc_journal_code, language_default, closing_style, current_year_result_profit_code,
   current_year_result_loss_code, retained_earnings_loss_code, opening_journal_code,
   rounding_method, cash_rounding_unit, fx_gain_code, fx_loss_code,
   asset_disposal_gain_code, asset_disposal_loss_code,
   asset_disposal_proceeds_code, asset_disposal_value_code,
   tax_payable_code, tax_receivable_code, opening_entry_label,
   vat_period_default)
values
  ('AG', 'Antigua and Barbuda', '{}'::jsonb, array['en']::text[], 'XCD', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, 'month'::declaration_period)
on conflict (country) do update set
  name                   = excluded.name,
  name_i18n              = excluded.name_i18n,
  languages              = excluded.languages,
  currency_code          = excluded.currency_code,
  receivable_code        = excluded.receivable_code,
  payable_code           = excluded.payable_code,
  suspense_code          = excluded.suspense_code,
  rounding_code          = excluded.rounding_code,
  retained_earnings_code = excluded.retained_earnings_code,
  sales_account_code     = excluded.sales_account_code,
  purchase_account_code  = excluded.purchase_account_code,
  bank_account_code      = excluded.bank_account_code,
  cash_account_code      = excluded.cash_account_code,
  sales_journal_code     = excluded.sales_journal_code,
  purchase_journal_code  = excluded.purchase_journal_code,
  misc_journal_code      = excluded.misc_journal_code,
  language_default       = excluded.language_default,
  closing_style          = excluded.closing_style,
  current_year_result_profit_code = excluded.current_year_result_profit_code,
  current_year_result_loss_code   = excluded.current_year_result_loss_code,
  retained_earnings_loss_code     = excluded.retained_earnings_loss_code,
  opening_journal_code            = excluded.opening_journal_code,
  rounding_method        = excluded.rounding_method,
  cash_rounding_unit     = excluded.cash_rounding_unit,
  fx_gain_code           = excluded.fx_gain_code,
  fx_loss_code           = excluded.fx_loss_code,
  asset_disposal_gain_code        = excluded.asset_disposal_gain_code,
  asset_disposal_loss_code        = excluded.asset_disposal_loss_code,
  asset_disposal_proceeds_code    = excluded.asset_disposal_proceeds_code,
  asset_disposal_value_code       = excluded.asset_disposal_value_code,
  tax_payable_code                = excluded.tax_payable_code,
  tax_receivable_code             = excluded.tax_receivable_code,
  opening_entry_label             = excluded.opening_entry_label,
  vat_period_default              = excluded.vat_period_default;

update country_defaults set
  numbering_gapless             = false,
  number_format                 = '{CODE}-{YYYY}-{NNNN}',
  legal_payment_days            = null,
  late_payment_reference        = null,
  numbering_legal_reference     = 'FAQ question 24 — an ABST invoice shows the supplier''s and the recipient''s TIN, name and address, the serial number and date of issue, a description with quantity and period, the unit price, the consideration and the ABST charged. The text asks for a serial number and not for a series without gaps, which is why the style is `sequential`.',
  numbering_source_key          = 'abst-faq',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_date',
  tax_point_legal_reference     = 'The time of supply is a rule of the Act that is not carried here: the text of the Act was read for the rates, the schedules and the return, not for its time-of-supply provisions. `invoice_date` is declared as a convention of this pack and not as a rule of the law; a payment received before the invoice, which may bring the supply forward, is recorded as a gap in the README.',
  tax_point_source_key          = 'abst-act-2006',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'None of the texts consulted (the Sales Tax Act 2006 and its amendments to 2024, the Tax Administration and Procedure Act 2018, the Department''s FAQ and guides) imposes a structured electronic invoice or a clearance system: the FAQ describes an ABST invoice and an ABST receipt as documents with a list of required contents (questions 20 to 24). No Peppol authority or published profile was found, so `profile`, `party_scheme` and `vat_scheme` are null and `obligation` is `none`.',
  einvoice_source_key           = 'abst-faq',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'AG';
