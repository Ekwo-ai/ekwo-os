-- Ekwo OS — Samoa: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/ws at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build ws`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Value Added Goods and Services Tax Act 2015 — sections 8 (rate), 9 (registration), 15 (time of supply), 26 (input tax credit), 29 (GST periods), 30 (net GST), 33 (tax invoices), 41–42 (return and payment), Schedules 2 (exempt supplies) and 3 (zero-rated supplies) (Government of Samoa — Ministry of Revenue)
--     https://revenue.gov.ws/wp-content/uploads/2022/08/Value-Added-Goods-and-Services-Tax-Act-2015.pdf
--   Form VAGST 001 — Value Added Goods and Services Tax Return (fifteen boxes: sales, VAGST collected, purchases, VAGST paid, calculation) (Government of Samoa — Ministry of Revenue)
--     https://revenue.gov.ws/wp-content/uploads/2022/09/VAGST-001.pdf
--   Notice to all taxpayers — tax returns and payments due for March 2025 (VAGST Category 'A' return due 22 April 2025; late filing fees, late payment interest and penalty) (Government of Samoa — Ministry of Revenue)
--     https://revenue.gov.ws/2025/04/11/due-date-notice-vagst-paye-april-2025/
--   Form IR31 — VAGST registration form (Government of Samoa — Ministry of Revenue)
--     https://revenue.gov.ws/wp-content/uploads/2022/09/IR31-VAGST-Registration-Form-1.pdf
--   Tax Administration Act 2012 — penalties, records and the return declaration (Government of Samoa — Ministry of Revenue)
--     https://revenue.gov.ws/wp-content/uploads/2022/08/Tax-Administration-Act-2012.pdf
--   Income Tax Act 2012 — section 2: the tax year is the calendar year (Government of Samoa — Ministry of Revenue)
--     https://revenue.gov.ws/wp-content/uploads/2022/08/Income-Tax-Act-2012.pdf
--   IAS 1 Presentation of Financial Statements — the statement of financial position and the statement of profit or loss, expenses analysed by nature; no Samoa text prescribing a layout or a chart of accounts was read (IFRS Foundation)
--     https://www.ifrs.org/issued-standards/list-of-standards/ias-1-presentation-of-financial-statements/
--   Ministry of Revenue — tax administration portal (forms, public notices of filing deadlines, Samoa e-Tax for filing and paying online) (Government of Samoa — Ministry of Revenue)
--     https://revenue.gov.ws/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('WS', 'Samoa', '0.1.0', date '2026-10-26', '20261023124650', 'community', null, null, '65cd505167f3abac86b6ea85b05d0f9281af2015da28f692de46512d1c247151', '[{"key":"vagst-act","title":"Value Added Goods and Services Tax Act 2015 — sections 8 (rate), 9 (registration), 15 (time of supply), 26 (input tax credit), 29 (GST periods), 30 (net GST), 33 (tax invoices), 41–42 (return and payment), Schedules 2 (exempt supplies) and 3 (zero-rated supplies)","publisher":"Government of Samoa — Ministry of Revenue","url":"https://revenue.gov.ws/wp-content/uploads/2022/08/Value-Added-Goods-and-Services-Tax-Act-2015.pdf","consulted_on":"2026-10-26","kind":"law"},{"key":"vagst-001","title":"Form VAGST 001 — Value Added Goods and Services Tax Return (fifteen boxes: sales, VAGST collected, purchases, VAGST paid, calculation)","publisher":"Government of Samoa — Ministry of Revenue","url":"https://revenue.gov.ws/wp-content/uploads/2022/09/VAGST-001.pdf","consulted_on":"2026-10-26","kind":"form"},{"key":"due-date-notice","title":"Notice to all taxpayers — tax returns and payments due for March 2025 (VAGST Category ''A'' return due 22 April 2025; late filing fees, late payment interest and penalty)","publisher":"Government of Samoa — Ministry of Revenue","url":"https://revenue.gov.ws/2025/04/11/due-date-notice-vagst-paye-april-2025/","consulted_on":"2026-10-26","kind":"guidance"},{"key":"vagst-registration","title":"Form IR31 — VAGST registration form","publisher":"Government of Samoa — Ministry of Revenue","url":"https://revenue.gov.ws/wp-content/uploads/2022/09/IR31-VAGST-Registration-Form-1.pdf","consulted_on":"2026-10-26","kind":"form"},{"key":"tax-admin-act","title":"Tax Administration Act 2012 — penalties, records and the return declaration","publisher":"Government of Samoa — Ministry of Revenue","url":"https://revenue.gov.ws/wp-content/uploads/2022/08/Tax-Administration-Act-2012.pdf","consulted_on":"2026-10-26","kind":"law"},{"key":"income-tax-act","title":"Income Tax Act 2012 — section 2: the tax year is the calendar year","publisher":"Government of Samoa — Ministry of Revenue","url":"https://revenue.gov.ws/wp-content/uploads/2022/08/Income-Tax-Act-2012.pdf","consulted_on":"2026-10-26","kind":"law"},{"key":"ias-1","title":"IAS 1 Presentation of Financial Statements — the statement of financial position and the statement of profit or loss, expenses analysed by nature; no Samoa text prescribing a layout or a chart of accounts was read","publisher":"IFRS Foundation","url":"https://www.ifrs.org/issued-standards/list-of-standards/ias-1-presentation-of-financial-statements/","consulted_on":"2026-10-26","kind":"guidance"},{"key":"tax-portal","title":"Ministry of Revenue — tax administration portal (forms, public notices of filing deadlines, Samoa e-Tax for filing and paying online)","publisher":"Government of Samoa — Ministry of Revenue","url":"https://revenue.gov.ws/","consulted_on":"2026-10-26","kind":"portal"}]'::jsonb)
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
  ('WS', 'default', 'Samoa reference chart of accounts', '{}'::jsonb, true, 'companies', array['WS-IFRS-IS', 'WS-IFRS-SFP']::text[], null, 'There is no legal chart of accounts in the texts read for Samoa, and no text read names a standard setter or a framework for company accounts. This chart is original: four digits, blocked so that each range reaches one line of the IFRS-style statements below (IAS 1, expenses by nature), with the accounts a Samoa trading company keeps — VAVAGST output and input tax, import VAVAGST owed to Customs, salary and wages tax withheld, superannuation contributions and withholding taxes payable.', 'ias-1')
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
  ('WS', 'default', '1000', 'Petty cash', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('WS', 'default', '1010', 'Current account — WST', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('WS', 'default', '1020', 'Fixed deposits placed for three months or less', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('WS', 'default', '1030', 'Foreign currency account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('WS', 'default', '1040', 'Cash in transit — card and mobile-payment settlements', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('WS', 'default', '1100', 'Trade receivables', '{}'::jsonb, 'asset_receivable', true, null, 60),
  ('WS', 'default', '1110', 'Trade receivables — allowance for impairment', '{}'::jsonb, 'asset_current', false, null, 70),
  ('WS', 'default', '1120', 'Other receivables', '{}'::jsonb, 'asset_current', false, null, 80),
  ('WS', 'default', '1130', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 90),
  ('WS', 'default', '1140', 'Deposits paid', '{}'::jsonb, 'asset_current', false, null, 100),
  ('WS', 'default', '1150', 'VAGST input tax', '{}'::jsonb, 'asset_current', false, null, 110),
  ('WS', 'default', '1155', 'VAGST refundable by the Ministry of Revenue — net of a filed return', '{}'::jsonb, 'asset_current', true, null, 120),
  ('WS', 'default', '1160', 'Advances to staff', '{}'::jsonb, 'asset_current', false, null, 130),
  ('WS', 'default', '1200', 'Inventories — goods for resale', '{}'::jsonb, 'asset_current', false, null, 140),
  ('WS', 'default', '1210', 'Inventories — raw materials', '{}'::jsonb, 'asset_current', false, null, 150),
  ('WS', 'default', '1220', 'Inventories — work in progress', '{}'::jsonb, 'asset_current', false, null, 160),
  ('WS', 'default', '1230', 'Inventories — finished goods', '{}'::jsonb, 'asset_current', false, null, 170),
  ('WS', 'default', '1300', 'Short-term investments', '{}'::jsonb, 'asset_current', false, null, 180),
  ('WS', 'default', '1350', 'Current tax recoverable', '{}'::jsonb, 'asset_current', false, null, 190),
  ('WS', 'default', '1400', 'Prepayments', '{}'::jsonb, 'asset_prepayments', false, null, 200),
  ('WS', 'default', '1410', 'Accrued income', '{}'::jsonb, 'asset_prepayments', false, null, 210),
  ('WS', 'default', '1600', 'Land and buildings — cost', '{}'::jsonb, 'asset_fixed', false, null, 220),
  ('WS', 'default', '1601', 'Land and buildings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 230),
  ('WS', 'default', '1610', 'Leasehold improvements — cost', '{}'::jsonb, 'asset_fixed', false, null, 240),
  ('WS', 'default', '1611', 'Leasehold improvements — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 250),
  ('WS', 'default', '1620', 'Plant and machinery — cost', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('WS', 'default', '1621', 'Plant and machinery — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('WS', 'default', '1630', 'Office equipment — cost', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('WS', 'default', '1631', 'Office equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('WS', 'default', '1640', 'Computers — cost', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('WS', 'default', '1641', 'Computers — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('WS', 'default', '1650', 'Furniture and fittings — cost', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('WS', 'default', '1651', 'Furniture and fittings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('WS', 'default', '1660', 'Motor vehicles — cost', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('WS', 'default', '1661', 'Motor vehicles — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('WS', 'default', '1670', 'Right-of-use assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('WS', 'default', '1671', 'Right-of-use assets — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('WS', 'default', '1700', 'Investment property', '{}'::jsonb, 'asset_non_current', false, null, 380),
  ('WS', 'default', '1750', 'Intangible assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 390),
  ('WS', 'default', '1751', 'Intangible assets — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 400),
  ('WS', 'default', '1760', 'Goodwill', '{}'::jsonb, 'asset_fixed', false, null, 410),
  ('WS', 'default', '1800', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('WS', 'default', '1810', 'Investments in joint ventures', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('WS', 'default', '1830', 'Long-term financial assets', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('WS', 'default', '1840', 'Long-term deposits', '{}'::jsonb, 'asset_non_current', false, null, 450),
  ('WS', 'default', '1900', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('WS', 'default', '2000', 'Trade payables', '{}'::jsonb, 'liability_payable', true, null, 470),
  ('WS', 'default', '2010', 'Accrued expenses', '{}'::jsonb, 'liability_current', false, null, 480),
  ('WS', 'default', '2020', 'Other payables', '{}'::jsonb, 'liability_current', false, null, 490),
  ('WS', 'default', '2030', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 500),
  ('WS', 'default', '2040', 'Deposits received from customers', '{}'::jsonb, 'liability_current', false, null, 510),
  ('WS', 'default', '2100', 'VAGST output tax', '{}'::jsonb, 'liability_current', false, null, 520),
  ('WS', 'default', '2110', 'VAGST payable to the Ministry of Revenue — net of a filed return', '{}'::jsonb, 'liability_current', true, null, 530),
  ('WS', 'default', '2125', 'Import VAGST payable to Customs at the border', '{}'::jsonb, 'liability_current', false, null, 540),
  ('WS', 'default', '2126', 'VAGST on imported capital goods — held until paid', '{}'::jsonb, 'liability_current', false, null, 550),
  ('WS', 'default', '2140', 'Salary and wages tax withheld and payable to the Ministry of Revenue', '{}'::jsonb, 'liability_current', false, null, 560),
  ('WS', 'default', '2150', 'Superannuation contributions payable', '{}'::jsonb, 'liability_current', false, null, 570),
  ('WS', 'default', '2155', 'Excise duty payable', '{}'::jsonb, 'liability_current', false, null, 580),
  ('WS', 'default', '2160', 'Withholding taxes payable to the Ministry of Revenue', '{}'::jsonb, 'liability_current', false, null, 590),
  ('WS', 'default', '2165', 'Other statutory amounts payable', '{}'::jsonb, 'liability_current', false, null, 600),
  ('WS', 'default', '2180', 'Salaries payable', '{}'::jsonb, 'liability_current', false, null, 610),
  ('WS', 'default', '2190', 'Directors'' fees payable', '{}'::jsonb, 'liability_current', false, null, 620),
  ('WS', 'default', '2200', 'Bank overdraft', '{}'::jsonb, 'liability_current', false, null, 630),
  ('WS', 'default', '2210', 'Bank loans — current portion', '{}'::jsonb, 'liability_current', false, null, 640),
  ('WS', 'default', '2220', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 650),
  ('WS', 'default', '2230', 'Hire purchase — current portion', '{}'::jsonb, 'liability_current', false, null, 660),
  ('WS', 'default', '2240', 'Corporate credit card', '{}'::jsonb, 'liability_credit_card', false, null, 670),
  ('WS', 'default', '2250', 'Amounts due to directors', '{}'::jsonb, 'liability_current', false, null, 680),
  ('WS', 'default', '2300', 'Current tax payable', '{}'::jsonb, 'liability_current', false, null, 690),
  ('WS', 'default', '2350', 'Provision for unutilised leave', '{}'::jsonb, 'liability_current', false, null, 700),
  ('WS', 'default', '2360', 'Other provisions — current', '{}'::jsonb, 'liability_current', false, null, 710),
  ('WS', 'default', '2400', 'Bank loans — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 720),
  ('WS', 'default', '2410', 'Lease liabilities — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 730),
  ('WS', 'default', '2420', 'Hire purchase — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 740),
  ('WS', 'default', '2430', 'Loans from shareholders and directors — non-current', '{}'::jsonb, 'liability_non_current', false, null, 750),
  ('WS', 'default', '2500', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 760),
  ('WS', 'default', '2550', 'Provision for reinstatement costs', '{}'::jsonb, 'liability_non_current', false, null, 770),
  ('WS', 'default', '2990', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 780),
  ('WS', 'default', '3000', 'Share capital', '{}'::jsonb, 'equity', false, null, 790),
  ('WS', 'default', '3010', 'Treasury shares', '{}'::jsonb, 'equity', false, null, 800),
  ('WS', 'default', '3100', 'Other reserves', '{}'::jsonb, 'equity', false, null, 810),
  ('WS', 'default', '3110', 'Foreign currency translation reserve', '{}'::jsonb, 'equity', false, null, 820),
  ('WS', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 830),
  ('WS', 'default', '3210', 'Dividends paid', '{}'::jsonb, 'equity_retained', false, null, 840),
  ('WS', 'default', '4000', 'Sales of goods', '{}'::jsonb, 'income', false, null, 850),
  ('WS', 'default', '4010', 'Services rendered', '{}'::jsonb, 'income', false, null, 860),
  ('WS', 'default', '4020', 'Export sales of goods', '{}'::jsonb, 'income', false, null, 870),
  ('WS', 'default', '4030', 'Export of services', '{}'::jsonb, 'income', false, null, 880),
  ('WS', 'default', '4500', 'Interest income', '{}'::jsonb, 'income_other', false, null, 890),
  ('WS', 'default', '4510', 'Dividend income', '{}'::jsonb, 'income_other', false, null, 900),
  ('WS', 'default', '4520', 'Rental income', '{}'::jsonb, 'income_other', false, null, 910),
  ('WS', 'default', '4530', 'Government grants', '{}'::jsonb, 'income_other', false, null, 920),
  ('WS', 'default', '4700', 'Foreign exchange gains', '{}'::jsonb, 'income_other', false, null, 930),
  ('WS', 'default', '4750', 'Gain on disposal of property plant and equipment', '{}'::jsonb, 'income_other', false, null, 940),
  ('WS', 'default', '4790', 'Other income', '{}'::jsonb, 'income_other', false, null, 950),
  ('WS', 'default', '5000', 'Purchases of goods for resale', '{}'::jsonb, 'expense_direct_cost', false, null, 960),
  ('WS', 'default', '5010', 'Freight inwards and import duties', '{}'::jsonb, 'expense_direct_cost', false, null, 970),
  ('WS', 'default', '5020', 'Subcontract costs', '{}'::jsonb, 'expense_direct_cost', false, null, 980),
  ('WS', 'default', '5100', 'Changes in inventories', '{}'::jsonb, 'expense_direct_cost', false, null, 990),
  ('WS', 'default', '6000', 'Salaries and wages', '{}'::jsonb, 'expense', false, null, 1000),
  ('WS', 'default', '6010', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 1010),
  ('WS', 'default', '6020', 'Directors'' fees', '{}'::jsonb, 'expense', false, null, 1020),
  ('WS', 'default', '6030', 'Superannuation contributions — employer', '{}'::jsonb, 'expense', false, null, 1030),
  ('WS', 'default', '6035', 'Staff training and welfare', '{}'::jsonb, 'expense', false, null, 1040),
  ('WS', 'default', '6040', 'Other statutory employment costs', '{}'::jsonb, 'expense', false, null, 1050),
  ('WS', 'default', '6050', 'Retirement gratuity and end-of-service benefits', '{}'::jsonb, 'expense', false, null, 1060),
  ('WS', 'default', '6060', 'Staff amenities', '{}'::jsonb, 'expense', false, null, 1070),
  ('WS', 'default', '6070', 'Staff medical expenses and insurance', '{}'::jsonb, 'expense', false, null, 1080),
  ('WS', 'default', '6080', 'Staff training', '{}'::jsonb, 'expense', false, null, 1090),
  ('WS', 'default', '6200', 'Depreciation of property plant and equipment', '{}'::jsonb, 'expense_depreciation', false, null, 1100),
  ('WS', 'default', '6210', 'Depreciation of right-of-use assets', '{}'::jsonb, 'expense_depreciation', false, null, 1110),
  ('WS', 'default', '6220', 'Amortisation of intangible assets', '{}'::jsonb, 'expense_depreciation', false, null, 1120),
  ('WS', 'default', '6300', 'Rent — short-term leases', '{}'::jsonb, 'expense', false, null, 1130),
  ('WS', 'default', '6310', 'Utilities', '{}'::jsonb, 'expense', false, null, 1140),
  ('WS', 'default', '6320', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 1150),
  ('WS', 'default', '6330', 'Cleaning and security services', '{}'::jsonb, 'expense', false, null, 1160),
  ('WS', 'default', '6340', 'Telephone and internet', '{}'::jsonb, 'expense', false, null, 1170),
  ('WS', 'default', '6350', 'Software subscriptions', '{}'::jsonb, 'expense', false, null, 1180),
  ('WS', 'default', '6360', 'Advertising and marketing', '{}'::jsonb, 'expense', false, null, 1190),
  ('WS', 'default', '6370', 'Travelling', '{}'::jsonb, 'expense', false, null, 1200),
  ('WS', 'default', '6380', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1210),
  ('WS', 'default', '6390', 'Entertainment', '{}'::jsonb, 'expense', false, null, 1220),
  ('WS', 'default', '6400', 'Subscriptions and memberships', '{}'::jsonb, 'expense', false, null, 1230),
  ('WS', 'default', '6410', 'Insurance', '{}'::jsonb, 'expense', false, null, 1240),
  ('WS', 'default', '6420', 'Professional fees', '{}'::jsonb, 'expense', false, null, 1250),
  ('WS', 'default', '6430', 'Audit fees', '{}'::jsonb, 'expense', false, null, 1260),
  ('WS', 'default', '6440', 'Company secretarial and registration fees', '{}'::jsonb, 'expense', false, null, 1270),
  ('WS', 'default', '6450', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1280),
  ('WS', 'default', '6455', 'Donations', '{}'::jsonb, 'expense', false, null, 1290),
  ('WS', 'default', '6460', 'Printing and stationery', '{}'::jsonb, 'expense', false, null, 1300),
  ('WS', 'default', '6470', 'Postage and courier', '{}'::jsonb, 'expense', false, null, 1310),
  ('WS', 'default', '6480', 'Licences permits and local authority fees', '{}'::jsonb, 'expense', false, null, 1320),
  ('WS', 'default', '6490', 'Royalties', '{}'::jsonb, 'expense', false, null, 1330),
  ('WS', 'default', '6500', 'Bad debts written off', '{}'::jsonb, 'expense', false, null, 1340),
  ('WS', 'default', '6510', 'Impairment loss on trade receivables', '{}'::jsonb, 'expense', false, null, 1350),
  ('WS', 'default', '6900', 'Sponsorship', '{}'::jsonb, 'expense', false, null, 1360),
  ('WS', 'default', '6950', 'Foreign exchange losses', '{}'::jsonb, 'expense', false, null, 1370),
  ('WS', 'default', '6960', 'Loss on disposal of property plant and equipment', '{}'::jsonb, 'expense', false, null, 1380),
  ('WS', 'default', '6990', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1390),
  ('WS', 'default', '7000', 'Interest on bank loans', '{}'::jsonb, 'expense', false, null, 1400),
  ('WS', 'default', '7010', 'Interest on lease liabilities', '{}'::jsonb, 'expense', false, null, 1410),
  ('WS', 'default', '7020', 'Hire purchase interest', '{}'::jsonb, 'expense', false, null, 1420),
  ('WS', 'default', '7030', 'Interest on loans from related parties and others', '{}'::jsonb, 'expense', false, null, 1430),
  ('WS', 'default', '8000', 'Current income tax expense', '{}'::jsonb, 'expense', false, null, 1440),
  ('WS', 'default', '8010', 'Deferred tax expense', '{}'::jsonb, 'expense', false, null, 1450),
  ('WS', 'default', '8020', 'Under or over provision of income tax in prior years', '{}'::jsonb, 'expense', false, null, 1460)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('WS', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('WS', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('WS', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('WS', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('WS', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('WS', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('WS', 'WS-P-0', 'Purchase, no VAGST', '{}'::jsonb, 'A purchase from a supplier who charged no VAGST — exempt, unregistered or outside Samoa', 'percent', 0, 'purchase', 'exempt', date '2015-01-01', null, 'Form VAGST 001, boxes 9 to 12 — only the VAGST actually paid on taxable purchases and expenses is declared; a purchase that carries no VAGST appears on no line of the return.', null, null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vagst-001', null, null, null, null),
  ('WS', 'WS-P-15', 'Purchase, standard rate 15 %', '{}'::jsonb, 'Goods or services bought in Samoa from a registered person for the taxable activity, with a tax invoice', 'percent', 15, 'purchase', 'domestic', date '2015-01-01', null, 'Value Added Goods and Services Tax Act 2015, s. 26(1) — a registered person is allowed a credit for the input tax on a creditable acquisition to the extent that it was for making taxable supplies. Form VAGST 001: box 9 is the total taxable purchases and expenses received, VAGST included, and excludes tax paid to the Customs Service; box 10 is box 9 divided by 7.66667. The engine posts the exclusive base to box 9a, which is not a box of the form, and the VAGST to box 10. Apportionment for exempt or private use (s. 20 and s. 26) is the preparer''s.', 'S', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vagst-001', null, null, null, null),
  ('WS', 'WS-P-15-NC', 'Purchase, standard rate 15 % — no input credit', '{}'::jsonb, 'A purchase carrying 15 % VAGST that gives no input credit — bought for exempt supplies or for private use', 'percent', 15, 'purchase', 'domestic', date '2015-01-01', null, 'Value Added Goods and Services Tax Act 2015, s. 26(1) — the credit is allowed only to the extent that the acquisition was for making taxable supplies; s. 20 treats the application of goods to a private or exempt use as a taxable supply where a credit was allowed. A purchase made wholly for exempt supplies or private use gives no credit: the VAGST joins the cost and no box of the return receives the purchase. Which purchases are barred is the preparer''s judgement.', 'S', null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vagst-act', null, null, null, null),
  ('WS', 'WS-P-IMP', 'Purchase, import of goods', '{}'::jsonb, 'Goods imported into Samoa, VAGST paid to the Customs Service at the border', 'percent', 15, 'purchase', 'import', date '2015-01-01', null, 'Value Added Goods and Services Tax Act 2015, s. 8(1)(b) and s. 42(2) — GST on a taxable import is payable by the importer at the time of import, to the Comptroller of Customs (s. 43); s. 25 — the value of the import is the customs value plus freight and insurance, import duty, excise tax and levies. Form VAGST 001, box 11: tax adjustments, VAGST amount only, including VAGST paid to the Customs Service; box 9 excludes it. The customs value is posted to box 11a, which is not a box of the form. The VAGST owed to Customs sits on the import control account until paid.', null, null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vagst-001', null, null, null, null),
  ('WS', 'WS-S-15', 'Sale, standard rate 15 %', '{}'::jsonb, 'A taxable supply of goods or services made in Samoa by a registered person, neither zero-rated nor exempt', 'percent', 15, 'sale', 'domestic', date '2015-01-01', null, 'Value Added Goods and Services Tax Act 2015, s. 8(3)(b) — GST is imposed at 15 % on a taxable supply that is not zero-rated. Form VAGST 001: box 3 is the total sales inclusive of VAGST, box 4 the zero-rated supplies, box 5 the difference (taxable sales, VAGST included) and box 6 the VAGST collected, box 5 divided by 7.66667 (the tax fraction of 15 %, 15/115). The engine posts the exclusive base to box 5a, which is not a box of the form, and the VAGST to box 6.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vagst-act', null, null, null, null),
  ('WS', 'WS-S-EX', 'Sale, exempt', '{}'::jsonb, 'A supply the VAGST Act exempts — financial services, bus and taxi passenger transport, donated goods of a non-profit body, the departure charge', 'percent', 0, 'sale', 'exempt', date '2015-01-01', null, 'Value Added Goods and Services Tax Act 2015, Schedule 2, clause 1 — exempt supplies: (a) financial services, (b) donated goods or services of a non-profit body, (c) passenger transport by bus and taxi, (d) the departure charge, (e) interconnection fees between resident telecommunications suppliers, (f) the carriage of passengers by ships within Samoa, (g) supplies for an overseas funded aid project where the agreement says so. An exempt supply is not a taxable supply and carries no input credit; clause 2 treats a supply that is both exempt and zero-rated as zero-rated. Form VAGST 001 has no box for exempt sales: they are outside box 3 and appear on no line of the return.', 'E', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vagst-act', null, null, null, null),
  ('WS', 'WS-S-ZR', 'Sale, zero-rated (other)', '{}'::jsonb, 'A zero-rated supply made in Samoa that is not an export — international transport, educational services, medical goods or services provided in hospitals, water, electricity', 'percent', 0, 'sale', 'domestic', date '2015-01-01', null, 'Value Added Goods and Services Tax Act 2015, Schedule 3, Part 1, clause 1 — besides exports, zero-rated: (g) international transport services, (h) supplies to the Head of State, (i) goods to the Gambling Control Authority, (j) educational services, (k) medical goods or services provided in hospitals, (l) water, (m) totalisator betting facilities, (n) the licensing of casinos, (o) electricity under the Electric Power Corporation Act 1980, and (f) some telecommunications services. One tax code carries the list; which item applies is the preparer''s judgement. Box 4 of form VAGST 001.', 'Z', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vagst-act', null, null, null, null),
  ('WS', 'WS-S-ZR-EXP', 'Sale, zero-rated (export)', '{}'::jsonb, 'Goods exported within 28 days of the supply, or services for use or consumption outside Samoa, taxable at 0 %', 'percent', 0, 'sale', 'export', date '2015-01-01', null, 'Value Added Goods and Services Tax Act 2015, Schedule 3, Part 1, clause 1(a) and (e), and clause 2 — an export of goods is zero-rated unless the goods are re-imported or are not exported within 28 days of the supply (or a longer period the Commissioner sets); a supply of services for use or consumption outside Samoa is zero-rated on documentary proof acceptable to the Commissioner. Zero-rated supplies are box 4 of form VAGST 001, included in box 3. A zero-rated supply keeps the input credit.', 'G', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vagst-act', null, null, null, null)
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
    ('WS-P-15', 'invoice', 'base', 100, null, '9a', array['9a']::text[], 100, 'WS-VAGST', 10),
    ('WS-P-15', 'invoice', 'tax', 100, '1150', '10', array['10']::text[], 100, 'WS-VAGST', 20),
    ('WS-P-15', 'credit_note', 'base', 100, null, '9a', array['9a']::text[], -100, 'WS-VAGST', 10),
    ('WS-P-15', 'credit_note', 'tax', 100, '1150', '10', array['10']::text[], -100, 'WS-VAGST', 20),
    ('WS-P-15-NC', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('WS-P-15-NC', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('WS-P-IMP', 'invoice', 'base', 100, null, '11a', array['11a']::text[], 100, 'WS-VAGST', 10),
    ('WS-P-IMP', 'invoice', 'tax', 100, '1150', '11', array['11']::text[], 100, 'WS-VAGST', 20),
    ('WS-P-IMP', 'invoice', 'tax', -100, '2125', null, null, 100, null, 30),
    ('WS-P-IMP', 'credit_note', 'base', 100, null, '11a', array['11a']::text[], -100, 'WS-VAGST', 10),
    ('WS-P-IMP', 'credit_note', 'tax', 100, '1150', '11', array['11']::text[], -100, 'WS-VAGST', 20),
    ('WS-P-IMP', 'credit_note', 'tax', -100, '2125', null, null, 100, null, 30),
    ('WS-S-15', 'invoice', 'base', 100, null, '5a', array['5a']::text[], 100, 'WS-VAGST', 10),
    ('WS-S-15', 'invoice', 'tax', 100, '2100', '6', array['6']::text[], 100, 'WS-VAGST', 20),
    ('WS-S-15', 'credit_note', 'base', 100, null, '5a', array['5a']::text[], -100, 'WS-VAGST', 10),
    ('WS-S-15', 'credit_note', 'tax', 100, '2100', '6', array['6']::text[], -100, 'WS-VAGST', 20),
    ('WS-S-ZR', 'invoice', 'base', 100, null, '4', array['4']::text[], 100, 'WS-VAGST', 10),
    ('WS-S-ZR', 'credit_note', 'base', 100, null, '4', array['4']::text[], -100, 'WS-VAGST', 10),
    ('WS-S-ZR-EXP', 'invoice', 'base', 100, null, '4', array['4']::text[], 100, 'WS-VAGST', 10),
    ('WS-S-ZR-EXP', 'credit_note', 'base', 100, null, '4', array['4']::text[], -100, 'WS-VAGST', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'WS' and t.code = v.tax_code
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
  ('WS', 'WS-VAGST', 'VAGST return (form VAGST 001)', array['bimonth']::declaration_period[], 'bimonth'::declaration_period, date '2015-01-01', null, 'Form VAGST 001, Value Added Goods and Services Tax Return (Value Added Goods and Services Tax Act 2015), filed for a GST period of two months (s. 29): fifteen numbered items, of which boxes 1 and 2 are the registration number and the name, boxes 3 to 8 the sales and the VAGST collected, boxes 9 to 12 the purchases and the VAGST paid, and boxes 13 to 15 the calculation. The form is VAGST-inclusive: boxes 3, 5 and 9 are totals here (exclusive base plus VAGST) and the exclusive figures sit in boxes 5a and 9a. Box 15 is signed: negative is the credit. The pack declares the bimonth anchored on January–February (Category B, periods ending in February, April, June…); Category A periods (ending in January, March, May…) are a gap of the core, see the README.', true,'depends_on_taxpayer'::filing_deadline_rule, null, null, 'Value Added Goods and Services Tax Act 2015, s. 41(1) — the return is filed within 15 working days after the end of the GST period, and s. 42(1) makes the net GST payable by the same date; s. 41(2) lets the Commissioner set an alternative date for a non-profit body or a particular case. The date is a count of working days and depends on public holidays, so no day of the month is declared: the Ministry''s notice for March 2025 gives Tuesday 22 April 2025 for the Category ''A'' period February–March.', 'vagst-act', null)
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
  ('WS', 'WS-VAGST', '3', 'total', 'Box 3 — Total sales/income inclusive of VAGST', '{}'::jsonb, 30, null, array['4', '5']::text[], '{}'::text[], null, null, false, false, null, 'Form VAGST 001, box 3 — total sales and income inclusive of VAGST (including imported services consumed by exempt bodies), zero-rated supplies included. Here boxes 4 and 5 added.', 'vagst-001'),
  ('WS', 'WS-VAGST', '4', 'base', 'Box 4 — Zero-rated supplies', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form VAGST 001, box 4 — the amount of zero-rated supplies, if any; included in box 3.', 'vagst-001'),
  ('WS', 'WS-VAGST', '5', 'total', 'Box 5 — Taxable sales (box 3 less box 4), VAGST included', '{}'::jsonb, 50, null, array['5a:base', '6:tax']::text[], '{}'::text[], null, null, false, false, null, 'Form VAGST 001, box 5 — subtract box 4 from box 3. Here the exclusive base of box 5a plus the VAGST of box 6.', 'vagst-001'),
  ('WS', 'WS-VAGST', '5a', 'base', 'Box 5a — Taxable sales, VAGST excluded', '{}'::jsonb, 55, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Not a box of the form: the exclusive value of the taxable sales of box 5, which the engine posts and from which box 5 is rebuilt.', 'vagst-001'),
  ('WS', 'WS-VAGST', '6', 'tax', 'Box 6 — VAGST collected by you (box 5 divided by 7.66667)', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form VAGST 001, box 6 — divide box 5 by 7.66667, the tax fraction of 15 % (15/115). Value Added Goods and Services Tax Act 2015, s. 8(3)(b).', 'vagst-act'),
  ('WS', 'WS-VAGST', '7', 'tax', 'Box 7 — Tax adjustments (VAGST amount only), sales side', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form VAGST 001, box 7 — tax adjustments, VAGST amount only (adjustment events and bad debts). Declared and empty: a decision of the preparer, no tax code posts to it.', 'vagst-001'),
  ('WS', 'WS-VAGST', '8', 'total', 'Box 8 — Total output tax (boxes 6 and 7)', '{}'::jsonb, 80, null, array['6', '7']::text[], '{}'::text[], null, null, false, false, null, 'Form VAGST 001, box 8 — add box 6 and 7: total output tax.', 'vagst-001'),
  ('WS', 'WS-VAGST', '9', 'total', 'Box 9 — Total taxable purchases/expenses received, VAGST included', '{}'::jsonb, 90, null, array['9a:base', '10:tax']::text[], '{}'::text[], null, null, false, false, null, 'Form VAGST 001, box 9 — total taxable purchases and expenses received including VAGST, excluding tax paid to the Customs Service. Here the exclusive base of box 9a plus the VAGST of box 10.', 'vagst-001'),
  ('WS', 'WS-VAGST', '9a', 'base', 'Box 9a — Local purchases carrying creditable VAGST, VAGST excluded', '{}'::jsonb, 95, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Not a box of the form: the exclusive value of the local purchases whose VAGST is posted to box 10.', 'vagst-001'),
  ('WS', 'WS-VAGST', '10', 'tax', 'Box 10 — VAGST paid by you (box 9 divided by 7.66667)', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form VAGST 001, box 10 — divide box 9 by 7.66667. Value Added Goods and Services Tax Act 2015, s. 26(1).', 'vagst-act'),
  ('WS', 'WS-VAGST', '11', 'tax', 'Box 11 — Tax adjustments (VAGST amount only), including VAGST paid to Customs', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form VAGST 001, box 11 — tax adjustments, VAGST amount only, including VAGST paid to the Customs Service. The VAGST of imported goods is posted here.', 'vagst-001'),
  ('WS', 'WS-VAGST', '11a', 'base', 'Box 11a — Imports, customs value', '{}'::jsonb, 115, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Not a box of the form: the value of the imported goods whose VAGST is posted to box 11; the form asks for the VAGST only.', 'vagst-001'),
  ('WS', 'WS-VAGST', '12', 'total', 'Box 12 — Total input tax (boxes 10 and 11)', '{}'::jsonb, 120, null, array['10', '11']::text[], '{}'::text[], null, null, false, false, null, 'Form VAGST 001, box 12 — add box 10 and 11: total input tax.', 'vagst-001'),
  ('WS', 'WS-VAGST', '13', 'total', 'Box 13 — VAGST to pay (positive) or VAGST credit (negative), box 8 less box 12', '{}'::jsonb, 130, null, array['8']::text[], array['12']::text[], null, null, false, false, null, 'Form VAGST 001, box 13 — the difference between box 8 and box 12: if box 12 is greater, the difference is the VAGST credit; if box 8 is greater, it is the VAGST to pay. Value Added Goods and Services Tax Act 2015, s. 30, net GST payable (A+B)-C. Signed: negative is the credit.', 'vagst-act'),
  ('WS', 'WS-VAGST', '14', 'tax', 'Box 14 — Credit brought forward from previous months', '{}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form VAGST 001, box 14 — credit brought forward, entered as a positive amount. Declared and empty: it is the preparer''s, from the previous return (s. 31, refunds).', 'vagst-001'),
  ('WS', 'WS-VAGST', '15', 'total', 'Box 15 — VAGST to pay (positive) or total VAGST credit (negative)', '{}'::jsonb, 150, null, array['13']::text[], array['14']::text[], null, null, false, false, null, 'Form VAGST 001, box 15 — if box 13 is VAGST to pay, subtract the credit brought forward of box 14; if box 13 is a credit, add box 14 to it. Signed: negative is the credit; the net GST is payable by the filing date (s. 42(1)).', 'vagst-001')
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
  ('WS-IFRS-IS', 'WS', 'default', 'Statement of profit or loss', 'income_statement', 'IFRS', date '2024-01-01', null, 'IAS 1 asks for a statement of financial position and a statement of profit or loss; expenses are analysed by nature, which these lines follow. No Samoa text prescribing a layout of the statements was found, so the statement is presented as IFRS-style on the pack''s own chart.', 'ias-1', null, null, '{}'::jsonb),
  ('WS-IFRS-SFP', 'WS', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS', date '2024-01-01', null, 'IAS 1 asks for a statement of financial position and a statement of profit or loss; expenses are analysed by nature, which these lines follow. No Samoa text prescribing a layout of the statements was found, so the statement is presented as IFRS-style on the pack''s own chart.', 'ias-1', 'combined', 'Result of the current financial year', '{}'::jsonb)
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
  ('WS-IFRS-IS', '1', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-IS', '2', null, 'Other income', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-IS', '3', null, 'Purchases and changes in inventories', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-IS', '4', null, 'Employee benefits expense', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-IS', '5', null, 'Depreciation and amortisation', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-IS', '6', null, 'Other operating expenses', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-IS', '7', null, 'Finance costs', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-IS', '8', null, 'Profit before tax', '{}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('WS-IFRS-IS', '9', null, 'Income tax expense', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-IS', '10', null, 'Profit for the year', '{}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, null, null),
  ('WS-IFRS-SFP', 'CA', null, 'Current assets', '{}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5', 'CA.6']::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'CA.1', null, 'Cash and cash equivalents', '{}'::jsonb, 11, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'CA.2', null, 'Trade and other receivables', '{}'::jsonb, 12, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'CA.3', null, 'Inventories', '{}'::jsonb, 13, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'CA.4', null, 'Financial assets', '{}'::jsonb, 14, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'CA.5', null, 'Current tax recoverable', '{}'::jsonb, 15, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'CA.6', null, 'Prepayments and accrued income', '{}'::jsonb, 16, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'NCA', null, 'Non-current assets', '{}'::jsonb, 20, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4', 'NCA.5', 'NCA.6', 'NCA.7']::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'NCA.1', null, 'Property, plant and equipment', '{}'::jsonb, 21, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'NCA.2', null, 'Investment property', '{}'::jsonb, 22, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'NCA.3', null, 'Intangible assets', '{}'::jsonb, 23, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'NCA.4', null, 'Investments in associates', '{}'::jsonb, 24, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'NCA.5', null, 'Investments in joint ventures', '{}'::jsonb, 25, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'NCA.6', null, 'Financial assets', '{}'::jsonb, 26, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'NCA.7', null, 'Deferred tax assets', '{}'::jsonb, 27, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'TA', null, 'Total assets', '{}'::jsonb, 30, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'CL', null, 'Current liabilities', '{}'::jsonb, 40, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4', 'CL.5']::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'CL.1', null, 'Trade and other payables', '{}'::jsonb, 41, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'CL.2', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 42, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'CL.3', null, 'Amounts due to directors', '{}'::jsonb, 43, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'CL.4', null, 'Current tax payable', '{}'::jsonb, 44, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'CL.5', null, 'Provisions', '{}'::jsonb, 45, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'NCL', null, 'Non-current liabilities', '{}'::jsonb, 50, 1, true, array['NCL.1', 'NCL.2', 'NCL.3']::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'NCL.1', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 51, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'NCL.2', null, 'Deferred tax liabilities', '{}'::jsonb, 52, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'NCL.3', null, 'Provisions', '{}'::jsonb, 53, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'TL', null, 'Total liabilities', '{}'::jsonb, 60, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'NA', null, 'Net assets', '{}'::jsonb, 70, 1, true, array['TA']::text[], array['TL']::text[], null, null, null),
  ('WS-IFRS-SFP', 'EQ', null, 'Equity', '{}'::jsonb, 80, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'EQ.1', null, 'Share capital', '{}'::jsonb, 81, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'EQ.2', null, 'Other reserves', '{}'::jsonb, 82, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('WS-IFRS-SFP', 'EQ.3', null, 'Retained earnings', '{}'::jsonb, 83, -1, false, '{}'::text[], '{}'::text[], null, null, null)
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
 where r.statement_code in ('WS-IFRS-IS', 'WS-IFRS-SFP')
   and (r.statement_code, r.line_code, r.sequence) not in (
     values ('WS-IFRS-IS', '1', 10),
            ('WS-IFRS-IS', '2', 10),
            ('WS-IFRS-IS', '3', 10),
            ('WS-IFRS-IS', '4', 10),
            ('WS-IFRS-IS', '5', 10),
            ('WS-IFRS-IS', '6', 10),
            ('WS-IFRS-IS', '7', 10),
            ('WS-IFRS-IS', '9', 10),
            ('WS-IFRS-SFP', 'CA.1', 10),
            ('WS-IFRS-SFP', 'CA.2', 10),
            ('WS-IFRS-SFP', 'CA.3', 10),
            ('WS-IFRS-SFP', 'CA.4', 10),
            ('WS-IFRS-SFP', 'CA.5', 10),
            ('WS-IFRS-SFP', 'CA.6', 10),
            ('WS-IFRS-SFP', 'NCA.1', 10),
            ('WS-IFRS-SFP', 'NCA.2', 10),
            ('WS-IFRS-SFP', 'NCA.3', 10),
            ('WS-IFRS-SFP', 'NCA.4', 10),
            ('WS-IFRS-SFP', 'NCA.5', 10),
            ('WS-IFRS-SFP', 'NCA.6', 10),
            ('WS-IFRS-SFP', 'NCA.7', 10),
            ('WS-IFRS-SFP', 'CL.1', 10),
            ('WS-IFRS-SFP', 'CL.1', 20),
            ('WS-IFRS-SFP', 'CL.2', 10),
            ('WS-IFRS-SFP', 'CL.3', 10),
            ('WS-IFRS-SFP', 'CL.4', 10),
            ('WS-IFRS-SFP', 'CL.5', 10),
            ('WS-IFRS-SFP', 'NCL.1', 10),
            ('WS-IFRS-SFP', 'NCL.2', 10),
            ('WS-IFRS-SFP', 'NCL.3', 10),
            ('WS-IFRS-SFP', 'EQ.1', 10),
            ('WS-IFRS-SFP', 'EQ.2', 10),
            ('WS-IFRS-SFP', 'EQ.3', 10)
   );

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('WS-IFRS-IS', '1', 10, 'code_range', '4000', '4030', null, 'any'),
    ('WS-IFRS-IS', '2', 10, 'code_range', '4500', '4790', null, 'any'),
    ('WS-IFRS-IS', '3', 10, 'code_range', '5000', '5100', null, 'any'),
    ('WS-IFRS-IS', '4', 10, 'code_range', '6000', '6080', null, 'any'),
    ('WS-IFRS-IS', '5', 10, 'code_range', '6200', '6220', null, 'any'),
    ('WS-IFRS-IS', '6', 10, 'code_range', '6300', '6990', null, 'any'),
    ('WS-IFRS-IS', '7', 10, 'code_range', '7000', '7030', null, 'any'),
    ('WS-IFRS-IS', '9', 10, 'code_range', '8000', '8020', null, 'any'),
    ('WS-IFRS-SFP', 'CA.1', 10, 'code_range', '1000', '1040', null, 'any'),
    ('WS-IFRS-SFP', 'CA.2', 10, 'code_range', '1100', '1160', null, 'any'),
    ('WS-IFRS-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('WS-IFRS-SFP', 'CA.4', 10, 'account_code', '1300', null, null, 'any'),
    ('WS-IFRS-SFP', 'CA.5', 10, 'account_code', '1350', null, null, 'any'),
    ('WS-IFRS-SFP', 'CA.6', 10, 'code_range', '1400', '1410', null, 'any'),
    ('WS-IFRS-SFP', 'NCA.1', 10, 'code_range', '1600', '1671', null, 'any'),
    ('WS-IFRS-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('WS-IFRS-SFP', 'NCA.3', 10, 'code_range', '1750', '1760', null, 'any'),
    ('WS-IFRS-SFP', 'NCA.4', 10, 'account_code', '1800', null, null, 'any'),
    ('WS-IFRS-SFP', 'NCA.5', 10, 'account_code', '1810', null, null, 'any'),
    ('WS-IFRS-SFP', 'NCA.6', 10, 'code_range', '1830', '1840', null, 'any'),
    ('WS-IFRS-SFP', 'NCA.7', 10, 'account_code', '1900', null, null, 'any'),
    ('WS-IFRS-SFP', 'CL.1', 10, 'code_range', '2000', '2190', null, 'any'),
    ('WS-IFRS-SFP', 'CL.1', 20, 'account_code', '2990', null, null, 'credit'),
    ('WS-IFRS-SFP', 'CL.2', 10, 'code_range', '2200', '2240', null, 'any'),
    ('WS-IFRS-SFP', 'CL.3', 10, 'account_code', '2250', null, null, 'any'),
    ('WS-IFRS-SFP', 'CL.4', 10, 'account_code', '2300', null, null, 'any'),
    ('WS-IFRS-SFP', 'CL.5', 10, 'code_range', '2350', '2360', null, 'any'),
    ('WS-IFRS-SFP', 'NCL.1', 10, 'code_range', '2400', '2430', null, 'any'),
    ('WS-IFRS-SFP', 'NCL.2', 10, 'account_code', '2500', null, null, 'any'),
    ('WS-IFRS-SFP', 'NCL.3', 10, 'account_code', '2550', null, null, 'any'),
    ('WS-IFRS-SFP', 'EQ.1', 10, 'code_range', '3000', '3010', null, 'any'),
    ('WS-IFRS-SFP', 'EQ.2', 10, 'code_range', '3100', '3110', null, 'any'),
    ('WS-IFRS-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('WS', 'Samoa', '{}'::jsonb, array['en']::text[], 'WST', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, 'bimonth'::declaration_period)
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
  numbering_legal_reference     = 'Value Added Goods and Services Tax Act 2015, s. 33 — a registered person making a taxable supply to another registered person issues the original tax invoice within 28 days of the time of supply, and none is required below $20; s. 39(3) requires copies to be kept. The text read states no document numbering rule, so numbering is `free`; the number format is a convention of this pack.',
  numbering_source_key          = 'vagst-act',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'Value Added Goods and Services Tax Act 2015, s. 15(1) — a supply occurs on the earlier of the date the invoice for the supply is issued and the date any payment, part payment included, is made. `invoice_if_issued` states the invoice as the point of the tax where one is issued; a payment received before the invoice brings the supply forward, which the engine does not model for a cash-first sale (see the README). Section 26(2) allows the input tax credit in the GST period in which the input tax is paid, which the engine does not model either.',
  tax_point_source_key          = 'vagst-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'The Ministry of Revenue runs a Tax Invoice Monitoring System (TIMS) for point-of-sale and electronic sales data devices, announced to vendors in public notices. No structured e-invoice standard or Peppol profile was found, so `obligation` is `none` for a business-to-business e-invoice; the reporting of sales to TIMS is not modelled (see the README).',
  einvoice_source_key           = 'tax-portal',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'WS';

update country_defaults set
  tax_payee_name       = 'Samoa Ministry of Revenue',
  tax_payee_source_key = 'tax-portal'
 where country = 'WS';
