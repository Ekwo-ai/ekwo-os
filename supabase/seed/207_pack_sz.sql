-- Ekwo OS — Eswatini: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/sz at version 0.2.0, do not edit.
-- Change the pack and run `ekwo pack build sz`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Value Added Tax Act, 2011 (Act No. 12 of 2011), as published by the Eswatini Revenue Service: ss. 3, 4, 6, 14, 16, 19, 24, 28, 29, 30, 31, 32 and the First and Second Schedules (Eswatini Revenue Service)
--     https://www.ers.org.sz/documents/EswatiniTax-VAT_Act_2011.pdf
--   Value Added Tax Regulations (Legal Notice No. 52 of 2012): credit for input tax (reg. 7), reverse charge on imported services (reg. 18), zero rate on aid-funded contracts (Eswatini Revenue Service)
--     https://www.ers.org.sz/documents/EswatiniTax-VAT_Regulations.pdf
--   Value Added Tax (Rates) (Amendment) Regulations, 2018 (Legal Notice No. 112 of 2018, Swaziland Government Gazette Extraordinary No. 102 of 9 July 2018): the rate of Value Added Tax is fifteen per cent, from 1 August 2018 (Eswatini Revenue Service)
--     https://www.ers.org.sz/documents/VATRateAmendmentRegulation2018.pdf
--   VAT Registration — who must register, the annual taxable turnover threshold of E900 000, voluntary registration (Eswatini Revenue Service)
--     https://www.ers.org.sz/Registration
--   Zero Rated Goods & Services — the lists of the Second Schedule as the Authority publishes them (Eswatini Revenue Service)
--     https://www.ers.org.sz/VAT/ZeroRated
--   Exempt Supplies of Goods & Services — the First Schedule as the Authority publishes it (Eswatini Revenue Service)
--     https://www.ers.org.sz/ExemptSupplies
--   e-Invoicing — the Authority's rollout of electronic fiscal devices and approved vendors (Eswatini Revenue Service)
--     https://www.ers.org.sz/e-invoicing
--   TaxEase — the Authority's taxpayer portal, where VAT returns are filed (Eswatini Revenue Service)
--     https://taxease.ers.org.sz/
--   Eswatini — use of IFRS Standards by jurisdiction: Companies Act, 2009 requires financial statements in conformity with Swaziland and International Financial Reporting Standards; IFRS for SMEs permitted (IFRS Foundation)
--     https://www.ifrs.org/use-around-the-world/use-of-ifrs-standards-by-jurisdiction/view-jurisdiction/eswatini/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('SZ', 'Eswatini', '0.2.0', date '2026-10-23', '20261023124650', 'community', null, null, '08f2ee591330aca14cbf8a895d64a1a589441f98a7c84ac9c71519bfeb412ccf', '[{"key":"vat-act","title":"Value Added Tax Act, 2011 (Act No. 12 of 2011), as published by the Eswatini Revenue Service: ss. 3, 4, 6, 14, 16, 19, 24, 28, 29, 30, 31, 32 and the First and Second Schedules","publisher":"Eswatini Revenue Service","url":"https://www.ers.org.sz/documents/EswatiniTax-VAT_Act_2011.pdf","consulted_on":"2026-10-19","kind":"law"},{"key":"vat-regulations","title":"Value Added Tax Regulations (Legal Notice No. 52 of 2012): credit for input tax (reg. 7), reverse charge on imported services (reg. 18), zero rate on aid-funded contracts","publisher":"Eswatini Revenue Service","url":"https://www.ers.org.sz/documents/EswatiniTax-VAT_Regulations.pdf","consulted_on":"2026-10-19","kind":"regulation"},{"key":"vat-rate-2018","title":"Value Added Tax (Rates) (Amendment) Regulations, 2018 (Legal Notice No. 112 of 2018, Swaziland Government Gazette Extraordinary No. 102 of 9 July 2018): the rate of Value Added Tax is fifteen per cent, from 1 August 2018","publisher":"Eswatini Revenue Service","url":"https://www.ers.org.sz/documents/VATRateAmendmentRegulation2018.pdf","consulted_on":"2026-10-19","kind":"regulation"},{"key":"ers-registration","title":"VAT Registration — who must register, the annual taxable turnover threshold of E900 000, voluntary registration","publisher":"Eswatini Revenue Service","url":"https://www.ers.org.sz/Registration","consulted_on":"2026-10-19","kind":"guidance"},{"key":"ers-zero-rated","title":"Zero Rated Goods & Services — the lists of the Second Schedule as the Authority publishes them","publisher":"Eswatini Revenue Service","url":"https://www.ers.org.sz/VAT/ZeroRated","consulted_on":"2026-10-19","kind":"guidance"},{"key":"ers-exempt","title":"Exempt Supplies of Goods & Services — the First Schedule as the Authority publishes it","publisher":"Eswatini Revenue Service","url":"https://www.ers.org.sz/ExemptSupplies","consulted_on":"2026-10-19","kind":"guidance"},{"key":"ers-einvoicing","title":"e-Invoicing — the Authority''s rollout of electronic fiscal devices and approved vendors","publisher":"Eswatini Revenue Service","url":"https://www.ers.org.sz/e-invoicing","consulted_on":"2026-10-19","kind":"guidance"},{"key":"taxease","title":"TaxEase — the Authority''s taxpayer portal, where VAT returns are filed","publisher":"Eswatini Revenue Service","url":"https://taxease.ers.org.sz/","consulted_on":"2026-10-19","kind":"portal"},{"key":"ifrs-profile","title":"Eswatini — use of IFRS Standards by jurisdiction: Companies Act, 2009 requires financial statements in conformity with Swaziland and International Financial Reporting Standards; IFRS for SMEs permitted","publisher":"IFRS Foundation","url":"https://www.ifrs.org/use-around-the-world/use-of-ifrs-standards-by-jurisdiction/view-jurisdiction/eswatini/","consulted_on":"2026-10-19","kind":"guidance"}]'::jsonb)
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
  ('SZ', 'default', 'Eswatini reference chart of accounts', '{}'::jsonb, true, 'companies', array['SZ-IFRS-IS', 'SZ-IFRS-SFP']::text[], null, 'There is no legal chart of accounts in Eswatini. The Companies Act, 2009 requires annual financial statements in conformity with Swaziland and International Financial Reporting Standards, the Eswatini Institute of Accountants has approved IFRS Standards and the IFRS for SMEs Standard, and small companies may choose the latter. This chart is original: four digits, blocked so that each range reaches one line of the IFRS-based statements below, with the accounts an Eswatini company actually keeps — VAT input and output tax, the VAT settlement account owed to or by the Eswatini Revenue Service, import VAT owed at the border, PAYE and withholding tax payable, provident fund contributions, and the irrecoverable VAT that the Act leaves with a buyer of an imported service or of entertainment.', 'ifrs-profile')
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
  ('SZ', 'default', '1000', 'Petty cash', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('SZ', 'default', '1010', 'Current account — SZL', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('SZ', 'default', '1020', 'Fixed deposits placed for three months or less', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('SZ', 'default', '1030', 'Foreign currency account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('SZ', 'default', '1040', 'Cash in transit — mobile money settlements', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('SZ', 'default', '1100', 'Trade receivables', '{}'::jsonb, 'asset_receivable', true, null, 60),
  ('SZ', 'default', '1110', 'Trade receivables — allowance for impairment', '{}'::jsonb, 'asset_current', false, null, 70),
  ('SZ', 'default', '1120', 'Other receivables', '{}'::jsonb, 'asset_current', false, null, 80),
  ('SZ', 'default', '1130', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 90),
  ('SZ', 'default', '1140', 'Deposits paid', '{}'::jsonb, 'asset_current', false, null, 100),
  ('SZ', 'default', '1150', 'VAT input tax', '{}'::jsonb, 'asset_current', false, null, 110),
  ('SZ', 'default', '1155', 'VAT refundable by ERS — net of a filed return', '{}'::jsonb, 'asset_current', true, null, 120),
  ('SZ', 'default', '1160', 'Advances to staff', '{}'::jsonb, 'asset_current', false, null, 130),
  ('SZ', 'default', '1200', 'Inventories — goods for resale', '{}'::jsonb, 'asset_current', false, null, 140),
  ('SZ', 'default', '1210', 'Inventories — raw materials', '{}'::jsonb, 'asset_current', false, null, 150),
  ('SZ', 'default', '1220', 'Inventories — work in progress', '{}'::jsonb, 'asset_current', false, null, 160),
  ('SZ', 'default', '1230', 'Inventories — finished goods', '{}'::jsonb, 'asset_current', false, null, 170),
  ('SZ', 'default', '1300', 'Short-term investments', '{}'::jsonb, 'asset_current', false, null, 180),
  ('SZ', 'default', '1350', 'Current tax recoverable', '{}'::jsonb, 'asset_current', false, null, 190),
  ('SZ', 'default', '1400', 'Prepayments', '{}'::jsonb, 'asset_prepayments', false, null, 200),
  ('SZ', 'default', '1410', 'Accrued income', '{}'::jsonb, 'asset_prepayments', false, null, 210),
  ('SZ', 'default', '1600', 'Land and buildings — cost', '{}'::jsonb, 'asset_fixed', false, null, 220),
  ('SZ', 'default', '1601', 'Land and buildings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 230),
  ('SZ', 'default', '1610', 'Leasehold improvements — cost', '{}'::jsonb, 'asset_fixed', false, null, 240),
  ('SZ', 'default', '1611', 'Leasehold improvements — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 250),
  ('SZ', 'default', '1620', 'Plant and machinery — cost', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('SZ', 'default', '1621', 'Plant and machinery — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('SZ', 'default', '1630', 'Office equipment — cost', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('SZ', 'default', '1631', 'Office equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('SZ', 'default', '1640', 'Computers — cost', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('SZ', 'default', '1641', 'Computers — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('SZ', 'default', '1650', 'Furniture and fittings — cost', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('SZ', 'default', '1651', 'Furniture and fittings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('SZ', 'default', '1660', 'Motor vehicles — cost', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('SZ', 'default', '1661', 'Motor vehicles — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('SZ', 'default', '1670', 'Right-of-use assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('SZ', 'default', '1671', 'Right-of-use assets — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('SZ', 'default', '1700', 'Investment property', '{}'::jsonb, 'asset_non_current', false, null, 380),
  ('SZ', 'default', '1750', 'Intangible assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 390),
  ('SZ', 'default', '1751', 'Intangible assets — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 400),
  ('SZ', 'default', '1760', 'Goodwill', '{}'::jsonb, 'asset_fixed', false, null, 410),
  ('SZ', 'default', '1800', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('SZ', 'default', '1810', 'Investments in joint ventures', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('SZ', 'default', '1830', 'Long-term financial assets', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('SZ', 'default', '1840', 'Long-term deposits', '{}'::jsonb, 'asset_non_current', false, null, 450),
  ('SZ', 'default', '1900', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('SZ', 'default', '2000', 'Trade payables', '{}'::jsonb, 'liability_payable', true, null, 470),
  ('SZ', 'default', '2010', 'Accrued expenses', '{}'::jsonb, 'liability_current', false, null, 480),
  ('SZ', 'default', '2020', 'Other payables', '{}'::jsonb, 'liability_current', false, null, 490),
  ('SZ', 'default', '2030', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 500),
  ('SZ', 'default', '2040', 'Deposits received from customers', '{}'::jsonb, 'liability_current', false, null, 510),
  ('SZ', 'default', '2100', 'VAT output tax', '{}'::jsonb, 'liability_current', false, null, 520),
  ('SZ', 'default', '2110', 'VAT payable to ERS — net of a filed return', '{}'::jsonb, 'liability_current', true, null, 530),
  ('SZ', 'default', '2125', 'Import VAT payable at the border', '{}'::jsonb, 'liability_current', false, null, 540),
  ('SZ', 'default', '2140', 'Withholding tax payable to ERS', '{}'::jsonb, 'liability_current', false, null, 550),
  ('SZ', 'default', '2150', 'Provident fund contributions payable', '{}'::jsonb, 'liability_current', false, null, 560),
  ('SZ', 'default', '2155', 'Other statutory deductions payable', '{}'::jsonb, 'liability_current', false, null, 570),
  ('SZ', 'default', '2160', 'PAYE payable to ERS', '{}'::jsonb, 'liability_current', false, null, 580),
  ('SZ', 'default', '2165', 'Other taxes and levies payable to ERS', '{}'::jsonb, 'liability_current', false, null, 590),
  ('SZ', 'default', '2170', 'Excise duty payable', '{}'::jsonb, 'liability_current', false, null, 600),
  ('SZ', 'default', '2175', 'Presumptive tax payable to ERS', '{}'::jsonb, 'liability_current', false, null, 610),
  ('SZ', 'default', '2180', 'Salaries payable', '{}'::jsonb, 'liability_current', false, null, 620),
  ('SZ', 'default', '2190', 'Directors'' fees payable', '{}'::jsonb, 'liability_current', false, null, 630),
  ('SZ', 'default', '2200', 'Bank overdraft', '{}'::jsonb, 'liability_current', false, null, 640),
  ('SZ', 'default', '2210', 'Bank loans — current portion', '{}'::jsonb, 'liability_current', false, null, 650),
  ('SZ', 'default', '2220', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 660),
  ('SZ', 'default', '2230', 'Hire purchase — current portion', '{}'::jsonb, 'liability_current', false, null, 670),
  ('SZ', 'default', '2240', 'Corporate credit card', '{}'::jsonb, 'liability_credit_card', false, null, 680),
  ('SZ', 'default', '2250', 'Amounts due to directors', '{}'::jsonb, 'liability_current', false, null, 690),
  ('SZ', 'default', '2300', 'Current tax payable', '{}'::jsonb, 'liability_current', false, null, 700),
  ('SZ', 'default', '2350', 'Provision for unutilised leave', '{}'::jsonb, 'liability_current', false, null, 710),
  ('SZ', 'default', '2360', 'Other provisions — current', '{}'::jsonb, 'liability_current', false, null, 720),
  ('SZ', 'default', '2400', 'Bank loans — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 730),
  ('SZ', 'default', '2410', 'Lease liabilities — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 740),
  ('SZ', 'default', '2420', 'Hire purchase — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 750),
  ('SZ', 'default', '2430', 'Loans from shareholders and directors — non-current', '{}'::jsonb, 'liability_non_current', false, null, 760),
  ('SZ', 'default', '2500', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 770),
  ('SZ', 'default', '2550', 'Provision for reinstatement costs', '{}'::jsonb, 'liability_non_current', false, null, 780),
  ('SZ', 'default', '2990', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 790),
  ('SZ', 'default', '3000', 'Share capital', '{}'::jsonb, 'equity', false, null, 800),
  ('SZ', 'default', '3010', 'Treasury shares', '{}'::jsonb, 'equity', false, null, 810),
  ('SZ', 'default', '3100', 'Other reserves', '{}'::jsonb, 'equity', false, null, 820),
  ('SZ', 'default', '3110', 'Foreign currency translation reserve', '{}'::jsonb, 'equity', false, null, 830),
  ('SZ', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 840),
  ('SZ', 'default', '3210', 'Dividends paid', '{}'::jsonb, 'equity_retained', false, null, 850),
  ('SZ', 'default', '4000', 'Sales of goods', '{}'::jsonb, 'income', false, null, 860),
  ('SZ', 'default', '4010', 'Services rendered', '{}'::jsonb, 'income', false, null, 870),
  ('SZ', 'default', '4020', 'Export sales of goods', '{}'::jsonb, 'income', false, null, 880),
  ('SZ', 'default', '4030', 'Export of services', '{}'::jsonb, 'income', false, null, 890),
  ('SZ', 'default', '4500', 'Interest income', '{}'::jsonb, 'income_other', false, null, 900),
  ('SZ', 'default', '4510', 'Dividend income', '{}'::jsonb, 'income_other', false, null, 910),
  ('SZ', 'default', '4520', 'Rental income — residential lease', '{}'::jsonb, 'income_other', false, null, 920),
  ('SZ', 'default', '4530', 'Government grants', '{}'::jsonb, 'income_other', false, null, 930),
  ('SZ', 'default', '4700', 'Foreign exchange gains', '{}'::jsonb, 'income_other', false, null, 940),
  ('SZ', 'default', '4750', 'Gain on disposal of property plant and equipment', '{}'::jsonb, 'income_other', false, null, 950),
  ('SZ', 'default', '4790', 'Other income', '{}'::jsonb, 'income_other', false, null, 960),
  ('SZ', 'default', '5000', 'Purchases of goods for resale', '{}'::jsonb, 'expense_direct_cost', false, null, 970),
  ('SZ', 'default', '5010', 'Freight inwards and import duties', '{}'::jsonb, 'expense_direct_cost', false, null, 980),
  ('SZ', 'default', '5020', 'Subcontract costs', '{}'::jsonb, 'expense_direct_cost', false, null, 990),
  ('SZ', 'default', '5100', 'Changes in inventories', '{}'::jsonb, 'expense_direct_cost', false, null, 1000),
  ('SZ', 'default', '6000', 'Salaries and wages', '{}'::jsonb, 'expense', false, null, 1010),
  ('SZ', 'default', '6010', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 1020),
  ('SZ', 'default', '6020', 'Directors'' fees', '{}'::jsonb, 'expense', false, null, 1030),
  ('SZ', 'default', '6030', 'Provident fund contributions — employer', '{}'::jsonb, 'expense', false, null, 1040),
  ('SZ', 'default', '6040', 'Other statutory employer contributions', '{}'::jsonb, 'expense', false, null, 1050),
  ('SZ', 'default', '6050', 'Workers'' compensation contributions', '{}'::jsonb, 'expense', false, null, 1060),
  ('SZ', 'default', '6060', 'Staff welfare', '{}'::jsonb, 'expense', false, null, 1070),
  ('SZ', 'default', '6070', 'Staff medical expenses and insurance', '{}'::jsonb, 'expense', false, null, 1080),
  ('SZ', 'default', '6080', 'Staff training', '{}'::jsonb, 'expense', false, null, 1090),
  ('SZ', 'default', '6200', 'Depreciation of property plant and equipment', '{}'::jsonb, 'expense_depreciation', false, null, 1100),
  ('SZ', 'default', '6210', 'Depreciation of right-of-use assets', '{}'::jsonb, 'expense_depreciation', false, null, 1110),
  ('SZ', 'default', '6220', 'Amortisation of intangible assets', '{}'::jsonb, 'expense_depreciation', false, null, 1120),
  ('SZ', 'default', '6300', 'Rent — short-term leases', '{}'::jsonb, 'expense', false, null, 1130),
  ('SZ', 'default', '6310', 'Utilities', '{}'::jsonb, 'expense', false, null, 1140),
  ('SZ', 'default', '6320', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 1150),
  ('SZ', 'default', '6330', 'Cleaning and security services', '{}'::jsonb, 'expense', false, null, 1160),
  ('SZ', 'default', '6340', 'Telephone and internet', '{}'::jsonb, 'expense', false, null, 1170),
  ('SZ', 'default', '6350', 'Software subscriptions', '{}'::jsonb, 'expense', false, null, 1180),
  ('SZ', 'default', '6360', 'Advertising and marketing', '{}'::jsonb, 'expense', false, null, 1190),
  ('SZ', 'default', '6370', 'Travelling', '{}'::jsonb, 'expense', false, null, 1200),
  ('SZ', 'default', '6380', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1210),
  ('SZ', 'default', '6390', 'Entertainment', '{}'::jsonb, 'expense', false, null, 1220),
  ('SZ', 'default', '6400', 'Subscriptions and memberships', '{}'::jsonb, 'expense', false, null, 1230),
  ('SZ', 'default', '6410', 'Insurance', '{}'::jsonb, 'expense', false, null, 1240),
  ('SZ', 'default', '6420', 'Professional fees', '{}'::jsonb, 'expense', false, null, 1250),
  ('SZ', 'default', '6430', 'Audit fees', '{}'::jsonb, 'expense', false, null, 1260),
  ('SZ', 'default', '6440', 'Company secretarial and registration fees', '{}'::jsonb, 'expense', false, null, 1270),
  ('SZ', 'default', '6450', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1280),
  ('SZ', 'default', '6460', 'Printing and stationery', '{}'::jsonb, 'expense', false, null, 1290),
  ('SZ', 'default', '6470', 'Postage and courier', '{}'::jsonb, 'expense', false, null, 1300),
  ('SZ', 'default', '6480', 'Licences permits and local government fees', '{}'::jsonb, 'expense', false, null, 1310),
  ('SZ', 'default', '6490', 'Royalties', '{}'::jsonb, 'expense', false, null, 1320),
  ('SZ', 'default', '6500', 'Bad debts written off', '{}'::jsonb, 'expense', false, null, 1330),
  ('SZ', 'default', '6510', 'Impairment loss on trade receivables', '{}'::jsonb, 'expense', false, null, 1340),
  ('SZ', 'default', '6520', 'Irrecoverable VAT on imported services', '{}'::jsonb, 'expense', false, null, 1350),
  ('SZ', 'default', '6530', 'Irrecoverable input VAT', '{}'::jsonb, 'expense', false, null, 1360),
  ('SZ', 'default', '6900', 'Donations', '{}'::jsonb, 'expense', false, null, 1370),
  ('SZ', 'default', '6950', 'Foreign exchange losses', '{}'::jsonb, 'expense', false, null, 1380),
  ('SZ', 'default', '6960', 'Loss on disposal of property plant and equipment', '{}'::jsonb, 'expense', false, null, 1390),
  ('SZ', 'default', '6990', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1400),
  ('SZ', 'default', '7000', 'Interest on bank loans', '{}'::jsonb, 'expense', false, null, 1410),
  ('SZ', 'default', '7010', 'Interest on lease liabilities', '{}'::jsonb, 'expense', false, null, 1420),
  ('SZ', 'default', '7020', 'Hire purchase interest', '{}'::jsonb, 'expense', false, null, 1430),
  ('SZ', 'default', '7030', 'Interest on loans from related parties and others', '{}'::jsonb, 'expense', false, null, 1440),
  ('SZ', 'default', '8000', 'Current income tax expense', '{}'::jsonb, 'expense', false, null, 1450),
  ('SZ', 'default', '8010', 'Deferred tax expense', '{}'::jsonb, 'expense', false, null, 1460),
  ('SZ', 'default', '8020', 'Under or over provision of income tax in prior years', '{}'::jsonb, 'expense', false, null, 1470)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('SZ', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('SZ', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('SZ', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('SZ', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('SZ', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('SZ', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('SZ', 'SZ-P-15', 'Purchase, standard rate 15 %, deductible', '{}'::jsonb, 'A local purchase at the general rate, used in the business of a taxable person', 'percent', 15, 'purchase', 'domestic', date '2018-08-01', null, 'Value Added Tax Act, 2011, s. 28(1)(a) — a credit is allowed for the tax payable on all taxable supplies made to the taxable person during the tax period, for goods and services used in the business; s. 29 — the credit rests on a tax invoice with the particulars of the Third Schedule; s. 28(5) and regulation 7 — some purchases carry no credit, and those take code SZ-P-15-ND. Rate: Legal Notice No. 112 of 2018, 15 % from 1 August 2018.', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('SZ', 'SZ-P-15-ND', 'Purchase, standard rate 15 %, input tax not deductible', '{}'::jsonb, 'A purchase whose input tax the Act blocks — entertainment, passenger automobiles and their repairs', 'percent', 15, 'purchase', 'domestic', date '2018-08-01', null, 'Value Added Tax Act, 2011, s. 28(5) — no input tax credit for a passenger automobile, including spare parts, repairs and maintenance, unless it is acquired for dealing in or hiring passenger automobiles; for entertainment, unless the taxable person is in the business of providing entertainment; and for mobile telephone services up to a limit the Minister sets. Regulation 7 lists what counts as entertainment (staff refreshments and meals, hospitality for clients, staff parties and gifts) and allows only 50 % of the tax on mobile telephone services. The tax follows the expense to account 6530. The 50 % telephone credit is not modelled: a company books the blocked half on this code and splits the line.', null, null, 115, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('SZ', 'SZ-P-EX', 'Purchase, exempt', '{}'::jsonb, 'An insurance premium, or another exempt supply bought for the business', 'percent', 0, 'purchase', 'exempt', date '2012-04-01', null, 'Value Added Tax Act, 2011, s. 19 and the First Schedule — insurance and financial services are exempt, so there is no VAT to deduct. The return carries no row for an exempt purchase.', null, null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('SZ', 'SZ-P-IMP', 'Import of goods, VAT paid at the border', '{}'::jsonb, 'VAT charged on the importation of taxable goods, paid at the border and claimed as input tax', 'percent', 15, 'purchase', 'import', date '2018-08-01', null, 'Value Added Tax Act, 2011, s. 3(b) — tax is charged on every import of goods other than an exempt import; s. 17 — an import takes place on the date customs duty is payable or, failing that, the date the goods are brought into Eswatini; s. 28(1)(b) — a credit is allowed for the tax paid on imports of goods by the taxable person. The tax is owed at the border and not to the supplier, so it waits on 2125 until the import declaration is settled.', null, null, 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('SZ', 'SZ-P-RC-SVC', 'Imported service, reverse-charged, not recoverable', '{}'::jsonb, 'A service listed in s. 16(2) supplied by a person outside Eswatini, taxed to the recipient who cannot deduct the tax', 'percent', 15, 'purchase', 'foreign_services_received', date '2018-08-01', null, 'Value Added Tax Act, 2011, s. 3(c) — tax is charged on the supply of imported services; s. 16(2) lists them (consultants, engineers, lawyers, accountants, data processing, financial and insurance transactions, supply of staff, hire of movable property, telecommunications, broadcasting, electronically supplied services); s. 16(3) — the recipient declares and pays the tax within 30 days of the earlier of invoice or payment; s. 16(4) — the obligation does not apply to a taxable person with the right to full deduction of input tax; regulation 18 — the reverse charge, and private individuals only above E5 000 a month. This code is for the recipient who cannot recover the tax (an exempt or partly exempt business): the self-charge is output tax with no input offset, so it lands in the cost account 6520. Whether a partly exempt recipient may recover part of it is for the accountant; the pack takes the prudent reading.', null, null, 150, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('SZ', 'SZ-P-Z', 'Purchase, zero-rated (local)', '{}'::jsonb, 'A local purchase of a good the Zero-Rating Order taxes at nil, from a registered supplier', 'percent', 0, 'purchase', 'domestic', date '2012-04-01', null, 'Value Added Tax Act, 2011, s. 24(4) and the Second Schedule — there is no input tax to deduct on a supply taxed at nil.', null, null, 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('SZ', 'SZ-S-15', 'Sale, standard rate 15 %', '{}'::jsonb, 'The general rate on a taxable supply made in Eswatini', 'percent', 15, 'sale', 'domestic', date '2018-08-01', null, 'Value Added Tax Act, 2011, s. 3(a) — tax is charged on every taxable supply in Eswatini made by a taxable person; s. 24(1) and (3) — it is calculated by applying the rate specified in the VAT Regulations to the taxable value; Legal Notice No. 112 of 2018 — "The rate of Value Added Tax shall be fifteen percent (15%)", in force on 1 August 2018, replacing the rate set by Legal Notice No. 52 of 2012 (the tax was introduced on 1 April 2012). Every supply that is neither exempt (First Schedule) nor zero-rated (Second Schedule) is standard-rated.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-rate-2018', null, null, null, null),
  ('SZ', 'SZ-S-EX', 'Sale, exempt', '{}'::jsonb, 'A supply the First Schedule lists: financial and insurance services, residential property and long lets, education, medical, dental and nursing services, passenger transport, water and sewage, burial and cremation', 'percent', 0, 'sale', 'exempt', date '2012-04-01', null, 'Value Added Tax Act, 2011, s. 19 and the First Schedule, paragraph 1 — postage stamps; financial services; insurance services; land and buildings other than for commercial and industrial use; lease or letting of immovable property other than commercial premises, hotel or holiday accommodation, residential accommodation for periods not exceeding 45 days and parking or storage space; education services; medical, dental and nursing services; social welfare services; betting, lotteries and gambling; transfer of a business as a going concern between taxable persons; burial and cremation; passenger transportation other than by registered tour operators; tap water and sewage; non-profit cultural, amateur sporting and charity activities. An exempt supplier charges no tax and recovers no input tax on what it uses to make exempt supplies (s. 28(7)).', 'E', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ers-exempt', null, null, null, null),
  ('SZ', 'SZ-S-Z-DOM', 'Sale, zero-rated (domestic — basic foodstuffs, farm inputs, medicines, school text books)', '{}'::jsonb, 'A local supply the Second Schedule taxes at nil: maize meal, maize, beans, brown bread, milk, fresh fruit and vegetables, eggs, rice, vegetable oil, paraffin, fertilizers, seeds, pesticides, animal feeds, prescription drugs and medicines, school text books', 'percent', 0, 'sale', 'domestic', date '2012-04-01', null, 'Value Added Tax Act, 2011, s. 24(4) and the Second Schedule, paragraph 1(c) to (q) — maize meal, maize, beans, agricultural inputs (fertilizers, seeds, pesticides), paraffin for cooking, illuminating and heating, milk, brown bread, animal feeds, samp, fresh fruit and vegetables, fresh eggs, rice, vegetable oil other than olive oil, prescription drugs and medicines, and school text books approved by the Ministry of Education. The Authority''s page lists the same goods with their tariff headings. Zero-rating a good is not exempting it: input tax stays deductible. The company picks this code for any of those lines and names the item on the invoice.', 'Z', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ers-zero-rated', null, null, null, null),
  ('SZ', 'SZ-S-Z-EXP', 'Sale, zero-rated (export)', '{}'::jsonb, 'A supply of goods or services exported from Eswatini, or the international transport of goods or passengers', 'percent', 0, 'sale', 'export', date '2012-04-01', null, 'Value Added Tax Act, 2011, s. 24(4) and the Second Schedule, paragraph 1(a) and (b) — the supply of goods or services exported from Eswatini as part of the supply, and international transport of goods or passengers by road, rail or air; paragraph 2 — goods are exported when delivered or made available at an address outside Eswatini, services when supplied for use or consumption outside Eswatini, in each case as evidenced by documentary proof acceptable to the Commissioner-General. A zero-rated supply is a taxable supply: input tax stays deductible.', 'G', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null)
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
    ('SZ-P-15', 'invoice', 'base', 100, null, '2', array['2']::text[], 100, 'SZ-VAT-RETURN', 10),
    ('SZ-P-15', 'invoice', 'tax', 100, '1150', '2', array['2']::text[], 100, 'SZ-VAT-RETURN', 20),
    ('SZ-P-15', 'credit_note', 'base', 100, null, '2', array['2']::text[], -100, 'SZ-VAT-RETURN', 10),
    ('SZ-P-15', 'credit_note', 'tax', 100, '1150', '2', array['2']::text[], -100, 'SZ-VAT-RETURN', 20),
    ('SZ-P-15-ND', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('SZ-P-15-ND', 'invoice', 'tax', 100, '6530', null, null, 100, null, 20),
    ('SZ-P-15-ND', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('SZ-P-15-ND', 'credit_note', 'tax', 100, '6530', null, null, 100, null, 20),
    ('SZ-P-EX', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('SZ-P-EX', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('SZ-P-IMP', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'SZ-VAT-RETURN', 10),
    ('SZ-P-IMP', 'invoice', 'tax', 100, '1150', '3', array['3']::text[], 100, 'SZ-VAT-RETURN', 20),
    ('SZ-P-IMP', 'invoice', 'tax', -100, '2125', null, null, 100, null, 30),
    ('SZ-P-IMP', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'SZ-VAT-RETURN', 10),
    ('SZ-P-IMP', 'credit_note', 'tax', 100, '1150', '3', array['3']::text[], -100, 'SZ-VAT-RETURN', 20),
    ('SZ-P-IMP', 'credit_note', 'tax', -100, '2125', null, null, 100, null, 30),
    ('SZ-P-RC-SVC', 'invoice', 'base', 100, null, '1R', array['1R']::text[], 100, 'SZ-VAT-RETURN', 10),
    ('SZ-P-RC-SVC', 'invoice', 'tax', -100, '2100', '1R', array['1R']::text[], 100, 'SZ-VAT-RETURN', 20),
    ('SZ-P-RC-SVC', 'invoice', 'tax', 100, '6520', null, null, 100, null, 30),
    ('SZ-P-RC-SVC', 'credit_note', 'base', 100, null, '1R', array['1R']::text[], -100, 'SZ-VAT-RETURN', 10),
    ('SZ-P-RC-SVC', 'credit_note', 'tax', -100, '2100', '1R', array['1R']::text[], -100, 'SZ-VAT-RETURN', 20),
    ('SZ-P-RC-SVC', 'credit_note', 'tax', 100, '6520', null, null, 100, null, 30),
    ('SZ-P-Z', 'invoice', 'base', 100, null, 'ZP', array['ZP']::text[], 100, 'SZ-VAT-RETURN', 10),
    ('SZ-P-Z', 'credit_note', 'base', 100, null, 'ZP', array['ZP']::text[], -100, 'SZ-VAT-RETURN', 10),
    ('SZ-S-15', 'invoice', 'base', 100, null, '1S', array['1S']::text[], 100, 'SZ-VAT-RETURN', 10),
    ('SZ-S-15', 'invoice', 'tax', 100, '2100', '1S', array['1S']::text[], 100, 'SZ-VAT-RETURN', 20),
    ('SZ-S-15', 'credit_note', 'base', 100, null, '1S', array['1S']::text[], -100, 'SZ-VAT-RETURN', 10),
    ('SZ-S-15', 'credit_note', 'tax', 100, '2100', '1S', array['1S']::text[], -100, 'SZ-VAT-RETURN', 20),
    ('SZ-S-EX', 'invoice', 'base', 100, null, 'EX', array['EX']::text[], 100, 'SZ-VAT-RETURN', 10),
    ('SZ-S-EX', 'credit_note', 'base', 100, null, 'EX', array['EX']::text[], -100, 'SZ-VAT-RETURN', 10),
    ('SZ-S-Z-DOM', 'invoice', 'base', 100, null, 'ZL', array['ZL']::text[], 100, 'SZ-VAT-RETURN', 10),
    ('SZ-S-Z-DOM', 'credit_note', 'base', 100, null, 'ZL', array['ZL']::text[], -100, 'SZ-VAT-RETURN', 10),
    ('SZ-S-Z-EXP', 'invoice', 'base', 100, null, 'ZE', array['ZE']::text[], 100, 'SZ-VAT-RETURN', 10),
    ('SZ-S-Z-EXP', 'credit_note', 'base', 100, null, 'ZE', array['ZE']::text[], -100, 'SZ-VAT-RETURN', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'SZ' and t.code = v.tax_code
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
  ('SZ', 'SZ-VAT-RETURN', 'Monthly Value Added Tax return', array['month']::declaration_period[], 'month'::declaration_period, date '2012-04-01', null, 'Value Added Tax Act, 2011, s. 31(1) — the tax period is one month ending on the last day of each calendar month, unless the Minister authorises another for a class of persons (s. 31(2)); s. 32(1) — a taxable person submits a return for each tax period within 20 days after its end; s. 32(2) — the return is in the form the Commissioner-General prescribes and states the tax payable, the output tax and the input tax; s. 25 — the tax payable is the output tax less the input tax credits. The form on TaxEase could not be opened from the machine this pack was written on: the rows below are this pack''s own, grouped under those three figures, and the gap is recorded in this pack''s README.', true,'day_of_month_after_period'::filing_deadline_rule, 20, null, 'Value Added Tax Act, 2011, s. 32(1) — within 20 days after the end of the tax period. Press reports on the Authority''s notices of 2025 (VAT schedules submitted on TaxEase) give the 27th of the month; no text of the Authority''s own states it, so the pack carries the Act''s 20 days and flags the difference in its README. Penalties for late filing (2 % a month) are not modelled.', 'vat-act', null)
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
  ('SZ', 'SZ-VAT-RETURN', 'ZE', 'base', 'Zero-rated supplies — exports and international transport', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, 2011, Second Schedule, paragraph 1(a) and (b) — the value of exports and international transport. A reporting row of this pack.', 'vat-act'),
  ('SZ', 'SZ-VAT-RETURN', 'ZL', 'base', 'Zero-rated supplies — local (Second Schedule)', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, 2011, Second Schedule, paragraph 1(c) to (q) — the value of local supplies taxed at nil. A reporting row of this pack.', 'ers-zero-rated'),
  ('SZ', 'SZ-VAT-RETURN', 'EX', 'base', 'Exempt supplies (First Schedule)', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, 2011, First Schedule — the value of exempt supplies. A reporting row of this pack.', 'ers-exempt'),
  ('SZ', 'SZ-VAT-RETURN', '1S', 'base', 'Standard-rated supplies — value', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, 2011, s. 24 — the sales on which the output tax is charged. A reporting row of this pack.', 'vat-act'),
  ('SZ', 'SZ-VAT-RETURN', '1S', 'tax', 'Output tax on standard-rated supplies', '{}'::jsonb, 45, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, 2011, ss. 25 and 32(2) — output tax on standard-rated supplies, net of credit notes given.', 'vat-act'),
  ('SZ', 'SZ-VAT-RETURN', '1R', 'base', 'Imported services — value', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, 2011, ss. 3(c) and 16 — the value of an imported service on which the recipient pays the tax. A reporting row of this pack.', 'vat-act'),
  ('SZ', 'SZ-VAT-RETURN', '1R', 'tax', 'Output VAT on imported services', '{}'::jsonb, 55, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, 2011, s. 16(3) — the tax the recipient of an imported service declares and pays; included in output tax.', 'vat-act'),
  ('SZ', 'SZ-VAT-RETURN', '1', 'total', 'Total output tax', '{}'::jsonb, 60, null, array['1S:tax', '1R:tax']::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, 2011, ss. 25 and 32(2) — total output tax: the tax on standard-rated supplies plus the reverse-charged tax of imported services.', 'vat-act'),
  ('SZ', 'SZ-VAT-RETURN', 'ZP', 'base', 'Zero-rated purchases — value', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, 2011, Second Schedule — the value of local purchases taxed at nil. A reporting row of this pack.', 'vat-act'),
  ('SZ', 'SZ-VAT-RETURN', '2', 'base', 'Standard-rated local purchases — value', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, 2011, s. 28(1)(a) — the purchases on which input tax is incurred. A reporting row of this pack.', 'vat-act'),
  ('SZ', 'SZ-VAT-RETURN', '2', 'tax', 'Input tax on local purchases', '{}'::jsonb, 85, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, 2011, s. 28(1)(a) — input tax credit on local purchases, net of credits received.', 'vat-act'),
  ('SZ', 'SZ-VAT-RETURN', '3', 'base', 'Imports of goods — value', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, 2011, ss. 3(b) and 23 — the customs value of imports on which import tax is paid. A reporting row of this pack.', 'vat-act'),
  ('SZ', 'SZ-VAT-RETURN', '3', 'tax', 'Input tax on imports', '{}'::jsonb, 95, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, 2011, s. 28(1)(b) — input tax credit on tax paid on imports of goods.', 'vat-act'),
  ('SZ', 'SZ-VAT-RETURN', '4', 'total', 'Total input tax', '{}'::jsonb, 100, null, array['2:tax', '3:tax']::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, 2011, ss. 25 and 28 — total input tax credit: local purchases plus imports.', 'vat-act'),
  ('SZ', 'SZ-VAT-RETURN', '5', 'total', 'Tax payable or repayable', '{}'::jsonb, 110, null, array['1']::text[], array['4']::text[], null, null, false, false, null, 'Value Added Tax Act, 2011, s. 25 — the tax payable: output tax less input tax credit. A negative figure is refunded to the taxable person under s. 47(1).', 'vat-act')
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
  ('SZ-IFRS-IS', 'SZ', 'default', 'Statement of profit or loss', 'income_statement', 'IFRS-SME', date '2005-01-01', null, 'The Companies Act, 2009 requires annual financial statements in conformity with Swaziland and International Financial Reporting Standards; the Eswatini Institute of Accountants has approved IFRS Standards and the IFRS for SMEs Standard. Eswatini has no statutory format for the statements, so these lines are an original presentation by nature of expense that follows IAS 1 / section 4 of IFRS for SMEs (statement of profit or loss; expenses aggregated by nature).', 'ifrs-profile', null, null, '{}'::jsonb),
  ('SZ-IFRS-SFP', 'SZ', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS-SME', date '2005-01-01', null, 'The Companies Act, 2009 requires annual financial statements in conformity with Swaziland and International Financial Reporting Standards; the Eswatini Institute of Accountants has approved IFRS Standards and the IFRS for SMEs Standard. Eswatini has no statutory format for the statements, so these lines are an original presentation by nature of expense that follows IAS 1 / section 4 of IFRS for SMEs (statement of financial position).', 'ifrs-profile', 'combined', 'Result of the current financial year', '{}'::jsonb)
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
  ('SZ-IFRS-IS', '1', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-IS', '2', null, 'Other income', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-IS', '3', null, 'Purchases and changes in inventories', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-IS', '4', null, 'Employee benefits expense', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-IS', '5', null, 'Depreciation and amortisation', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-IS', '6', null, 'Other operating expenses', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-IS', '7', null, 'Finance costs', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-IS', '8', null, 'Profit before tax', '{}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('SZ-IFRS-IS', '9', null, 'Income tax expense', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-IS', '10', null, 'Profit for the year', '{}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, null, null),
  ('SZ-IFRS-SFP', 'CA', null, 'Current assets', '{}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5', 'CA.6']::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'CA.1', null, 'Cash and cash equivalents', '{}'::jsonb, 11, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'CA.2', null, 'Trade and other receivables', '{}'::jsonb, 12, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'CA.3', null, 'Inventories', '{}'::jsonb, 13, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'CA.4', null, 'Financial assets', '{}'::jsonb, 14, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'CA.5', null, 'Current tax recoverable', '{}'::jsonb, 15, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'CA.6', null, 'Prepayments and accrued income', '{}'::jsonb, 16, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'NCA', null, 'Non-current assets', '{}'::jsonb, 20, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4', 'NCA.5', 'NCA.6', 'NCA.7']::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'NCA.1', null, 'Property, plant and equipment', '{}'::jsonb, 21, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'NCA.2', null, 'Investment property', '{}'::jsonb, 22, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'NCA.3', null, 'Intangible assets', '{}'::jsonb, 23, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'NCA.4', null, 'Investments in associates', '{}'::jsonb, 24, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'NCA.5', null, 'Investments in joint ventures', '{}'::jsonb, 25, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'NCA.6', null, 'Financial assets', '{}'::jsonb, 26, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'NCA.7', null, 'Deferred tax assets', '{}'::jsonb, 27, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'TA', null, 'Total assets', '{}'::jsonb, 30, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'CL', null, 'Current liabilities', '{}'::jsonb, 40, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4', 'CL.5']::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'CL.1', null, 'Trade and other payables', '{}'::jsonb, 41, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'CL.2', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 42, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'CL.3', null, 'Amounts due to directors', '{}'::jsonb, 43, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'CL.4', null, 'Current tax payable', '{}'::jsonb, 44, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'CL.5', null, 'Provisions', '{}'::jsonb, 45, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'NCL', null, 'Non-current liabilities', '{}'::jsonb, 50, 1, true, array['NCL.1', 'NCL.2', 'NCL.3']::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'NCL.1', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 51, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'NCL.2', null, 'Deferred tax liabilities', '{}'::jsonb, 52, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'NCL.3', null, 'Provisions', '{}'::jsonb, 53, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'TL', null, 'Total liabilities', '{}'::jsonb, 60, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'NA', null, 'Net assets', '{}'::jsonb, 70, 1, true, array['TA']::text[], array['TL']::text[], null, null, null),
  ('SZ-IFRS-SFP', 'EQ', null, 'Equity', '{}'::jsonb, 80, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'EQ.1', null, 'Share capital', '{}'::jsonb, 81, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'EQ.2', null, 'Other reserves', '{}'::jsonb, 82, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SZ-IFRS-SFP', 'EQ.3', null, 'Retained earnings', '{}'::jsonb, 83, -1, false, '{}'::text[], '{}'::text[], null, null, null)
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
 where r.statement_code in ('SZ-IFRS-IS', 'SZ-IFRS-SFP')
   and (r.statement_code, r.line_code, r.sequence) not in (
     values ('SZ-IFRS-IS', '1', 10),
            ('SZ-IFRS-IS', '2', 10),
            ('SZ-IFRS-IS', '3', 10),
            ('SZ-IFRS-IS', '4', 10),
            ('SZ-IFRS-IS', '5', 10),
            ('SZ-IFRS-IS', '6', 10),
            ('SZ-IFRS-IS', '7', 10),
            ('SZ-IFRS-IS', '9', 10),
            ('SZ-IFRS-SFP', 'CA.1', 10),
            ('SZ-IFRS-SFP', 'CA.2', 10),
            ('SZ-IFRS-SFP', 'CA.3', 10),
            ('SZ-IFRS-SFP', 'CA.4', 10),
            ('SZ-IFRS-SFP', 'CA.5', 10),
            ('SZ-IFRS-SFP', 'CA.6', 10),
            ('SZ-IFRS-SFP', 'NCA.1', 10),
            ('SZ-IFRS-SFP', 'NCA.2', 10),
            ('SZ-IFRS-SFP', 'NCA.3', 10),
            ('SZ-IFRS-SFP', 'NCA.4', 10),
            ('SZ-IFRS-SFP', 'NCA.5', 10),
            ('SZ-IFRS-SFP', 'NCA.6', 10),
            ('SZ-IFRS-SFP', 'NCA.7', 10),
            ('SZ-IFRS-SFP', 'CL.1', 10),
            ('SZ-IFRS-SFP', 'CL.1', 20),
            ('SZ-IFRS-SFP', 'CL.2', 10),
            ('SZ-IFRS-SFP', 'CL.3', 10),
            ('SZ-IFRS-SFP', 'CL.4', 10),
            ('SZ-IFRS-SFP', 'CL.5', 10),
            ('SZ-IFRS-SFP', 'NCL.1', 10),
            ('SZ-IFRS-SFP', 'NCL.2', 10),
            ('SZ-IFRS-SFP', 'NCL.3', 10),
            ('SZ-IFRS-SFP', 'EQ.1', 10),
            ('SZ-IFRS-SFP', 'EQ.2', 10),
            ('SZ-IFRS-SFP', 'EQ.3', 10)
   );

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('SZ-IFRS-IS', '1', 10, 'code_range', '4000', '4030', null, 'any'),
    ('SZ-IFRS-IS', '2', 10, 'code_range', '4500', '4790', null, 'any'),
    ('SZ-IFRS-IS', '3', 10, 'code_range', '5000', '5100', null, 'any'),
    ('SZ-IFRS-IS', '4', 10, 'code_range', '6000', '6080', null, 'any'),
    ('SZ-IFRS-IS', '5', 10, 'code_range', '6200', '6220', null, 'any'),
    ('SZ-IFRS-IS', '6', 10, 'code_range', '6300', '6990', null, 'any'),
    ('SZ-IFRS-IS', '7', 10, 'code_range', '7000', '7030', null, 'any'),
    ('SZ-IFRS-IS', '9', 10, 'code_range', '8000', '8020', null, 'any'),
    ('SZ-IFRS-SFP', 'CA.1', 10, 'code_range', '1000', '1040', null, 'any'),
    ('SZ-IFRS-SFP', 'CA.2', 10, 'code_range', '1100', '1160', null, 'any'),
    ('SZ-IFRS-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('SZ-IFRS-SFP', 'CA.4', 10, 'account_code', '1300', null, null, 'any'),
    ('SZ-IFRS-SFP', 'CA.5', 10, 'account_code', '1350', null, null, 'any'),
    ('SZ-IFRS-SFP', 'CA.6', 10, 'code_range', '1400', '1410', null, 'any'),
    ('SZ-IFRS-SFP', 'NCA.1', 10, 'code_range', '1600', '1671', null, 'any'),
    ('SZ-IFRS-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('SZ-IFRS-SFP', 'NCA.3', 10, 'code_range', '1750', '1760', null, 'any'),
    ('SZ-IFRS-SFP', 'NCA.4', 10, 'account_code', '1800', null, null, 'any'),
    ('SZ-IFRS-SFP', 'NCA.5', 10, 'account_code', '1810', null, null, 'any'),
    ('SZ-IFRS-SFP', 'NCA.6', 10, 'code_range', '1830', '1840', null, 'any'),
    ('SZ-IFRS-SFP', 'NCA.7', 10, 'account_code', '1900', null, null, 'any'),
    ('SZ-IFRS-SFP', 'CL.1', 10, 'code_range', '2000', '2190', null, 'any'),
    ('SZ-IFRS-SFP', 'CL.1', 20, 'account_code', '2990', null, null, 'credit'),
    ('SZ-IFRS-SFP', 'CL.2', 10, 'code_range', '2200', '2240', null, 'any'),
    ('SZ-IFRS-SFP', 'CL.3', 10, 'account_code', '2250', null, null, 'any'),
    ('SZ-IFRS-SFP', 'CL.4', 10, 'account_code', '2300', null, null, 'any'),
    ('SZ-IFRS-SFP', 'CL.5', 10, 'code_range', '2350', '2360', null, 'any'),
    ('SZ-IFRS-SFP', 'NCL.1', 10, 'code_range', '2400', '2430', null, 'any'),
    ('SZ-IFRS-SFP', 'NCL.2', 10, 'account_code', '2500', null, null, 'any'),
    ('SZ-IFRS-SFP', 'NCL.3', 10, 'account_code', '2550', null, null, 'any'),
    ('SZ-IFRS-SFP', 'EQ.1', 10, 'code_range', '3000', '3010', null, 'any'),
    ('SZ-IFRS-SFP', 'EQ.2', 10, 'code_range', '3100', '3110', null, 'any'),
    ('SZ-IFRS-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('SZ', 'Eswatini', '{}'::jsonb, array['en']::text[], 'ZMW', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, 'month'::declaration_period)
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
  numbering_legal_reference     = 'Value Added Tax Act, 2011, s. 29(4) and the Third Schedule, section 1 — a tax invoice carries the particulars the Schedule lists, among them a serial number; the Act asks for a serial number and not for a series with no gap, which is why `numbering` is `sequential` and not `gapless_per_year`.',
  numbering_source_key          = 'vat-act',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Value Added Tax Act, 2011, s. 14(1)(c) — goods and services are supplied at the earliest of delivery or completion, payment and issue of a tax invoice. That is a three-way earliest test and Ekwo''s closed vocabulary only expresses a two-way one; `earliest_of_delivery_or_payment` is the nearest value, and the gap — an invoice issued ahead of both delivery and payment, which s. 14 still makes the tax point — is recorded in this pack''s README.',
  tax_point_source_key          = 'vat-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No Eswatini statute obliges a business to exchange a structured electronic invoice with another business in the sense Ekwo''s vocabulary gives the word: there is no Peppol authority, no published profile and no scheme a party is addressed by, so `profile`, `party_scheme` and `vat_scheme` are null and `obligation` is `none`. What the Eswatini Revenue Service is rolling out instead (its e-Invoicing page) is a fiscal-device regime: a taxpayer issues invoices through an approved electronic fiscal device or an approved vendor''s software, and the data reaches the Authority''s e-invoicing system. That is clearance with the tax administration and not a peer-to-peer exchange; the gap is recorded in this pack''s README, and the core is not patched to fit it.',
  einvoice_source_key           = 'ers-einvoicing',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'SZ';

update country_defaults set
  tax_payee_name       = 'Eswatini Revenue Service',
  tax_payee_source_key = 'taxease'
 where country = 'SZ';
