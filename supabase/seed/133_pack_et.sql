-- Ekwo OS — Ethiopia: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/et at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build et`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Value Added Tax Proclamation No. 1341/2024 (Federal Negarit Gazette, 21 August 2024), repealing Proclamation No. 285/2002 (Federal Democratic Republic of Ethiopia, Ministry of Finance)
--     https://www.mofed.gov.et/media/filer_public/af/45/af45af2f-7959-4e8b-b736-9494dda9f017/vat_proclamation_no_1341-2016_with_annex.pdf
--   Value Added Tax Proclamation (Proclamation No. 1341/2024) — federal law register entry (Ministry of Justice of Ethiopia)
--     https://justice.gov.et/en/law/value-added-tax-proclamation-2/
--   Council of Ministers Value Added Tax Regulation No. 570/2025 (Federal Negarit Gazette, 17 March 2025) (Council of Ministers of Ethiopia)
--     https://ethiodata.et/wp-content/uploads/2026/05/Ethiopia-Value-Added-Tax-Regulation-No.-570_2025.pdf
--   Directive exempting the first 200 kWh of electricity and 15 cubic metres of water per month from VAT, 5 September 2024 (Ministry of Finance of Ethiopia, reported by Addis Standard)
--     https://addisstandard.com/finance-ministry-grants-vat-exemption-on-initial-200-kwh-of-electricity-15-cubic-meters-of-water-consumption/
--   Electronic Invoicing System Administration Directive No. 1142/2026 and Tax Administration Amendment Proclamation No. 1434/2026 — summary of the e-invoicing framework (VATupdate, citing the Ministry of Revenues)
--     https://www.vatupdate.com/2026/10/02/ethiopia-e-invoicing-and-e-reporting-framework/
--   Value Added Tax declaration forms (Ethiopian Revenues and Customs Authority (now the Ministry of Revenues))
--     https://www.erca.gov.et/index.php/declaration-forms/59-value-added-tax-vat-forms
--   IFRS Accounting Standards — application around the world, jurisdictional profile: Ethiopia (Financial Reporting Proclamation No. 847/2014) (IFRS Foundation)
--     https://www.ifrs.org/content/dam/ifrs/publications/jurisdictions/pdf-profiles/ethiopia-ifrs-profile.pdf
--   e-Tax — the Ministry of Revenues portal where VAT returns are filed and tax is paid (Ministry of Revenues of Ethiopia)
--     https://etax.mor.gov.et/
--   Ministry of Revenues — legal publications, directives, forms and QR verification (Ministry of Revenues of Ethiopia)
--     https://www.mor.gov.et/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('ET', 'Ethiopia', '0.1.0', date '2026-10-09', '20260923110000', 'community', null, null, '4ceba680761db243f492c67d960895752263a1e8dbbffbe89467aa9156b8c9e4', '[{"key":"vat-proclamation","title":"Value Added Tax Proclamation No. 1341/2024 (Federal Negarit Gazette, 21 August 2024), repealing Proclamation No. 285/2002","publisher":"Federal Democratic Republic of Ethiopia, Ministry of Finance","url":"https://www.mofed.gov.et/media/filer_public/af/45/af45af2f-7959-4e8b-b736-9494dda9f017/vat_proclamation_no_1341-2016_with_annex.pdf","consulted_on":"2026-10-09","kind":"law"},{"key":"vat-proclamation-register","title":"Value Added Tax Proclamation (Proclamation No. 1341/2024) — federal law register entry","publisher":"Ministry of Justice of Ethiopia","url":"https://justice.gov.et/en/law/value-added-tax-proclamation-2/","consulted_on":"2026-10-09","kind":"law"},{"key":"vat-regulation","title":"Council of Ministers Value Added Tax Regulation No. 570/2025 (Federal Negarit Gazette, 17 March 2025)","publisher":"Council of Ministers of Ethiopia","url":"https://ethiodata.et/wp-content/uploads/2026/05/Ethiopia-Value-Added-Tax-Regulation-No.-570_2025.pdf","consulted_on":"2026-10-09","kind":"regulation"},{"key":"utilities-directive","title":"Directive exempting the first 200 kWh of electricity and 15 cubic metres of water per month from VAT, 5 September 2024","publisher":"Ministry of Finance of Ethiopia, reported by Addis Standard","url":"https://addisstandard.com/finance-ministry-grants-vat-exemption-on-initial-200-kwh-of-electricity-15-cubic-meters-of-water-consumption/","consulted_on":"2026-10-09","kind":"guidance"},{"key":"einvoicing-directive","title":"Electronic Invoicing System Administration Directive No. 1142/2026 and Tax Administration Amendment Proclamation No. 1434/2026 — summary of the e-invoicing framework","publisher":"VATupdate, citing the Ministry of Revenues","url":"https://www.vatupdate.com/2026/10/02/ethiopia-e-invoicing-and-e-reporting-framework/","consulted_on":"2026-10-09","kind":"guidance"},{"key":"vat-form","title":"Value Added Tax declaration forms","publisher":"Ethiopian Revenues and Customs Authority (now the Ministry of Revenues)","url":"https://www.erca.gov.et/index.php/declaration-forms/59-value-added-tax-vat-forms","consulted_on":"2026-10-09","kind":"form"},{"key":"ifrs-profile","title":"IFRS Accounting Standards — application around the world, jurisdictional profile: Ethiopia (Financial Reporting Proclamation No. 847/2014)","publisher":"IFRS Foundation","url":"https://www.ifrs.org/content/dam/ifrs/publications/jurisdictions/pdf-profiles/ethiopia-ifrs-profile.pdf","consulted_on":"2026-10-09","kind":"guidance"},{"key":"etax","title":"e-Tax — the Ministry of Revenues portal where VAT returns are filed and tax is paid","publisher":"Ministry of Revenues of Ethiopia","url":"https://etax.mor.gov.et/","consulted_on":"2026-10-09","kind":"portal"},{"key":"mor","title":"Ministry of Revenues — legal publications, directives, forms and QR verification","publisher":"Ministry of Revenues of Ethiopia","url":"https://www.mor.gov.et/","consulted_on":"2026-10-09","kind":"portal"}]'::jsonb)
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
  ('ET', 'default', 'Ethiopia reference chart of accounts (IFRS-inspired)', '{}'::jsonb, true, 'companies', array['ET-IFRS-IS', 'ET-IFRS-SFP']::text[], null, 'There is no legal chart of accounts in Ethiopia. Financial Reporting Proclamation No. 847/2014, art. 5, requires commercial organisations to prepare financial statements under IFRS Accounting Standards (public interest entities) or the IFRS for SMEs Accounting Standard (the others), under the supervision of the Accounting and Auditing Board of Ethiopia (AABE); it prescribes no account plan. This chart is original: four digits, blocked so that each range reaches one line of the IFRS for SMEs statements below, with the accounts an Ethiopian company actually keeps — input and output VAT, import VAT owed to Customs at the border, withholding tax, pension contributions, employment income tax and amounts due to directors.', 'ifrs-profile')
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
  ('ET', 'default', '1000', 'Petty cash', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('ET', 'default', '1010', 'Current account — ETB', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('ET', 'default', '1020', 'Fixed deposits placed for three months or less', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('ET', 'default', '1030', 'Foreign currency account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('ET', 'default', '1040', 'Cash in transit — mobile-money and card settlements', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('ET', 'default', '1100', 'Trade receivables', '{}'::jsonb, 'asset_receivable', true, null, 60),
  ('ET', 'default', '1110', 'Trade receivables — allowance for impairment', '{}'::jsonb, 'asset_current', false, null, 70),
  ('ET', 'default', '1120', 'Other receivables', '{}'::jsonb, 'asset_current', false, null, 80),
  ('ET', 'default', '1130', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 90),
  ('ET', 'default', '1140', 'Deposits paid', '{}'::jsonb, 'asset_current', false, null, 100),
  ('ET', 'default', '1150', 'VAT input tax', '{}'::jsonb, 'asset_current', false, null, 110),
  ('ET', 'default', '1155', 'VAT credit receivable from the Ministry of Revenues — net of a filed return', '{}'::jsonb, 'asset_current', true, null, 120),
  ('ET', 'default', '1160', 'Advances to staff', '{}'::jsonb, 'asset_current', false, null, 130),
  ('ET', 'default', '1200', 'Inventories — goods for resale', '{}'::jsonb, 'asset_current', false, null, 140),
  ('ET', 'default', '1210', 'Inventories — raw materials', '{}'::jsonb, 'asset_current', false, null, 150),
  ('ET', 'default', '1220', 'Inventories — work in progress', '{}'::jsonb, 'asset_current', false, null, 160),
  ('ET', 'default', '1230', 'Inventories — finished goods', '{}'::jsonb, 'asset_current', false, null, 170),
  ('ET', 'default', '1300', 'Short-term investments', '{}'::jsonb, 'asset_current', false, null, 180),
  ('ET', 'default', '1350', 'Current tax recoverable', '{}'::jsonb, 'asset_current', false, null, 190),
  ('ET', 'default', '1400', 'Prepayments', '{}'::jsonb, 'asset_prepayments', false, null, 200),
  ('ET', 'default', '1410', 'Accrued income', '{}'::jsonb, 'asset_prepayments', false, null, 210),
  ('ET', 'default', '1600', 'Land and buildings — cost', '{}'::jsonb, 'asset_fixed', false, null, 220),
  ('ET', 'default', '1601', 'Land and buildings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 230),
  ('ET', 'default', '1610', 'Leasehold improvements — cost', '{}'::jsonb, 'asset_fixed', false, null, 240),
  ('ET', 'default', '1611', 'Leasehold improvements — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 250),
  ('ET', 'default', '1620', 'Plant and machinery — cost', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('ET', 'default', '1621', 'Plant and machinery — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('ET', 'default', '1630', 'Office equipment — cost', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('ET', 'default', '1631', 'Office equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('ET', 'default', '1640', 'Computers — cost', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('ET', 'default', '1641', 'Computers — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('ET', 'default', '1650', 'Furniture and fittings — cost', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('ET', 'default', '1651', 'Furniture and fittings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('ET', 'default', '1660', 'Motor vehicles — cost', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('ET', 'default', '1661', 'Motor vehicles — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('ET', 'default', '1670', 'Right-of-use assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('ET', 'default', '1671', 'Right-of-use assets — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('ET', 'default', '1700', 'Investment property', '{}'::jsonb, 'asset_non_current', false, null, 380),
  ('ET', 'default', '1750', 'Intangible assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 390),
  ('ET', 'default', '1751', 'Intangible assets — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 400),
  ('ET', 'default', '1760', 'Goodwill', '{}'::jsonb, 'asset_fixed', false, null, 410),
  ('ET', 'default', '1800', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('ET', 'default', '1810', 'Investments in joint ventures', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('ET', 'default', '1830', 'Long-term financial assets', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('ET', 'default', '1840', 'Long-term deposits', '{}'::jsonb, 'asset_non_current', false, null, 450),
  ('ET', 'default', '1900', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('ET', 'default', '2000', 'Trade payables', '{}'::jsonb, 'liability_payable', true, null, 470),
  ('ET', 'default', '2010', 'Accrued expenses', '{}'::jsonb, 'liability_current', false, null, 480),
  ('ET', 'default', '2020', 'Other payables', '{}'::jsonb, 'liability_current', false, null, 490),
  ('ET', 'default', '2030', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 500),
  ('ET', 'default', '2040', 'Deposits received from customers', '{}'::jsonb, 'liability_current', false, null, 510),
  ('ET', 'default', '2100', 'VAT output tax', '{}'::jsonb, 'liability_current', false, null, 520),
  ('ET', 'default', '2110', 'VAT payable to the Ministry of Revenues — net of a filed return', '{}'::jsonb, 'liability_current', true, null, 530),
  ('ET', 'default', '2125', 'Import VAT payable to Customs at the border', '{}'::jsonb, 'liability_current', false, null, 540),
  ('ET', 'default', '2140', 'Withholding tax payable to the Ministry of Revenues', '{}'::jsonb, 'liability_current', false, null, 550),
  ('ET', 'default', '2150', 'Pension contributions payable', '{}'::jsonb, 'liability_current', false, null, 560),
  ('ET', 'default', '2155', 'Employment income tax payable', '{}'::jsonb, 'liability_current', false, null, 570),
  ('ET', 'default', '2160', 'Other statutory deductions payable', '{}'::jsonb, 'liability_current', false, null, 580),
  ('ET', 'default', '2180', 'Salaries payable', '{}'::jsonb, 'liability_current', false, null, 590),
  ('ET', 'default', '2190', 'Directors'' fees payable', '{}'::jsonb, 'liability_current', false, null, 600),
  ('ET', 'default', '2200', 'Bank overdraft', '{}'::jsonb, 'liability_current', false, null, 610),
  ('ET', 'default', '2210', 'Bank loans — current portion', '{}'::jsonb, 'liability_current', false, null, 620),
  ('ET', 'default', '2220', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 630),
  ('ET', 'default', '2230', 'Hire purchase — current portion', '{}'::jsonb, 'liability_current', false, null, 640),
  ('ET', 'default', '2240', 'Corporate credit card', '{}'::jsonb, 'liability_credit_card', false, null, 650),
  ('ET', 'default', '2250', 'Amounts due to directors', '{}'::jsonb, 'liability_current', false, null, 660),
  ('ET', 'default', '2300', 'Current tax payable', '{}'::jsonb, 'liability_current', false, null, 670),
  ('ET', 'default', '2350', 'Provision for unutilised leave', '{}'::jsonb, 'liability_current', false, null, 680),
  ('ET', 'default', '2360', 'Other provisions — current', '{}'::jsonb, 'liability_current', false, null, 690),
  ('ET', 'default', '2400', 'Bank loans — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 700),
  ('ET', 'default', '2410', 'Lease liabilities — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 710),
  ('ET', 'default', '2420', 'Hire purchase — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 720),
  ('ET', 'default', '2430', 'Loans from shareholders and directors — non-current', '{}'::jsonb, 'liability_non_current', false, null, 730),
  ('ET', 'default', '2500', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 740),
  ('ET', 'default', '2550', 'Provision for reinstatement costs', '{}'::jsonb, 'liability_non_current', false, null, 750),
  ('ET', 'default', '2990', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 760),
  ('ET', 'default', '3000', 'Share capital', '{}'::jsonb, 'equity', false, null, 770),
  ('ET', 'default', '3010', 'Treasury shares', '{}'::jsonb, 'equity', false, null, 780),
  ('ET', 'default', '3100', 'Other reserves', '{}'::jsonb, 'equity', false, null, 790),
  ('ET', 'default', '3110', 'Foreign currency translation reserve', '{}'::jsonb, 'equity', false, null, 800),
  ('ET', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 810),
  ('ET', 'default', '3210', 'Dividends paid', '{}'::jsonb, 'equity_retained', false, null, 820),
  ('ET', 'default', '4000', 'Sales of goods', '{}'::jsonb, 'income', false, null, 830),
  ('ET', 'default', '4010', 'Services rendered', '{}'::jsonb, 'income', false, null, 840),
  ('ET', 'default', '4020', 'Export sales of goods', '{}'::jsonb, 'income', false, null, 850),
  ('ET', 'default', '4030', 'Export of services', '{}'::jsonb, 'income', false, null, 860),
  ('ET', 'default', '4500', 'Interest income', '{}'::jsonb, 'income_other', false, null, 870),
  ('ET', 'default', '4510', 'Dividend income', '{}'::jsonb, 'income_other', false, null, 880),
  ('ET', 'default', '4520', 'Rental income', '{}'::jsonb, 'income_other', false, null, 890),
  ('ET', 'default', '4530', 'Government grants', '{}'::jsonb, 'income_other', false, null, 900),
  ('ET', 'default', '4700', 'Foreign exchange gains', '{}'::jsonb, 'income_other', false, null, 910),
  ('ET', 'default', '4750', 'Gain on disposal of property plant and equipment', '{}'::jsonb, 'income_other', false, null, 920),
  ('ET', 'default', '4790', 'Other income', '{}'::jsonb, 'income_other', false, null, 930),
  ('ET', 'default', '5000', 'Purchases of goods for resale', '{}'::jsonb, 'expense_direct_cost', false, null, 940),
  ('ET', 'default', '5010', 'Freight inwards and import duties', '{}'::jsonb, 'expense_direct_cost', false, null, 950),
  ('ET', 'default', '5020', 'Subcontract costs', '{}'::jsonb, 'expense_direct_cost', false, null, 960),
  ('ET', 'default', '5100', 'Changes in inventories', '{}'::jsonb, 'expense_direct_cost', false, null, 970),
  ('ET', 'default', '6000', 'Salaries and wages', '{}'::jsonb, 'expense', false, null, 980),
  ('ET', 'default', '6010', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 990),
  ('ET', 'default', '6020', 'Directors'' fees', '{}'::jsonb, 'expense', false, null, 1000),
  ('ET', 'default', '6030', 'Pension contributions — employer', '{}'::jsonb, 'expense', false, null, 1010),
  ('ET', 'default', '6035', 'Provident fund contributions — employer', '{}'::jsonb, 'expense', false, null, 1020),
  ('ET', 'default', '6040', 'Severance pay', '{}'::jsonb, 'expense', false, null, 1030),
  ('ET', 'default', '6060', 'Staff welfare', '{}'::jsonb, 'expense', false, null, 1040),
  ('ET', 'default', '6070', 'Staff medical expenses and insurance', '{}'::jsonb, 'expense', false, null, 1050),
  ('ET', 'default', '6080', 'Staff training', '{}'::jsonb, 'expense', false, null, 1060),
  ('ET', 'default', '6200', 'Depreciation of property plant and equipment', '{}'::jsonb, 'expense_depreciation', false, null, 1070),
  ('ET', 'default', '6210', 'Depreciation of right-of-use assets', '{}'::jsonb, 'expense_depreciation', false, null, 1080),
  ('ET', 'default', '6220', 'Amortisation of intangible assets', '{}'::jsonb, 'expense_depreciation', false, null, 1090),
  ('ET', 'default', '6300', 'Rent — short-term leases', '{}'::jsonb, 'expense', false, null, 1100),
  ('ET', 'default', '6310', 'Utilities', '{}'::jsonb, 'expense', false, null, 1110),
  ('ET', 'default', '6320', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 1120),
  ('ET', 'default', '6330', 'Cleaning and security services', '{}'::jsonb, 'expense', false, null, 1130),
  ('ET', 'default', '6340', 'Telephone and internet', '{}'::jsonb, 'expense', false, null, 1140),
  ('ET', 'default', '6350', 'Software subscriptions', '{}'::jsonb, 'expense', false, null, 1150),
  ('ET', 'default', '6360', 'Advertising and marketing', '{}'::jsonb, 'expense', false, null, 1160),
  ('ET', 'default', '6370', 'Travelling', '{}'::jsonb, 'expense', false, null, 1170),
  ('ET', 'default', '6380', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1180),
  ('ET', 'default', '6390', 'Entertainment', '{}'::jsonb, 'expense', false, null, 1190),
  ('ET', 'default', '6400', 'Subscriptions and memberships', '{}'::jsonb, 'expense', false, null, 1200),
  ('ET', 'default', '6410', 'Insurance', '{}'::jsonb, 'expense', false, null, 1210),
  ('ET', 'default', '6420', 'Professional fees', '{}'::jsonb, 'expense', false, null, 1220),
  ('ET', 'default', '6430', 'Audit fees', '{}'::jsonb, 'expense', false, null, 1230),
  ('ET', 'default', '6440', 'Company secretarial and registration fees', '{}'::jsonb, 'expense', false, null, 1240),
  ('ET', 'default', '6450', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1250),
  ('ET', 'default', '6460', 'Printing and stationery', '{}'::jsonb, 'expense', false, null, 1260),
  ('ET', 'default', '6470', 'Postage and courier', '{}'::jsonb, 'expense', false, null, 1270),
  ('ET', 'default', '6480', 'Licences permits and municipal fees', '{}'::jsonb, 'expense', false, null, 1280),
  ('ET', 'default', '6490', 'Royalties', '{}'::jsonb, 'expense', false, null, 1290),
  ('ET', 'default', '6500', 'Bad debts written off', '{}'::jsonb, 'expense', false, null, 1300),
  ('ET', 'default', '6510', 'Impairment loss on trade receivables', '{}'::jsonb, 'expense', false, null, 1310),
  ('ET', 'default', '6900', 'Donations', '{}'::jsonb, 'expense', false, null, 1320),
  ('ET', 'default', '6950', 'Foreign exchange losses', '{}'::jsonb, 'expense', false, null, 1330),
  ('ET', 'default', '6960', 'Loss on disposal of property plant and equipment', '{}'::jsonb, 'expense', false, null, 1340),
  ('ET', 'default', '6990', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1350),
  ('ET', 'default', '7000', 'Interest on bank loans', '{}'::jsonb, 'expense', false, null, 1360),
  ('ET', 'default', '7010', 'Interest on lease liabilities', '{}'::jsonb, 'expense', false, null, 1370),
  ('ET', 'default', '7020', 'Hire purchase interest', '{}'::jsonb, 'expense', false, null, 1380),
  ('ET', 'default', '7030', 'Interest on loans from related parties and others', '{}'::jsonb, 'expense', false, null, 1390),
  ('ET', 'default', '8000', 'Current income tax expense', '{}'::jsonb, 'expense', false, null, 1400),
  ('ET', 'default', '8010', 'Deferred tax expense', '{}'::jsonb, 'expense', false, null, 1410),
  ('ET', 'default', '8020', 'Under or over provision of income tax in prior years', '{}'::jsonb, 'expense', false, null, 1420)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('ET', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('ET', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('ET', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('ET', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('ET', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('ET', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('ET', 'ET-P-15', 'Purchase, standard rate 15 %, deductible', '{}'::jsonb, 'A local purchase at the general rate, used to make taxable supplies', 'percent', 15, 'purchase', 'domestic', date '2024-08-21', null, 'Value Added Tax Proclamation No. 1341/2024, art. 29(1) — a registered person may credit the input tax on acquisitions made for the purpose of taxable supplies, supported by a tax invoice; art. 8(2) — the rate. Zero-rated supplies are taxable, so their input tax is deductible.', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-proclamation', null, null, null, null),
  ('ET', 'ET-P-15-BL', 'Purchase, standard rate 15 %, input tax disallowed', '{}'::jsonb, 'A passenger vehicle and its repairs, entertainment, or club membership fees', 'percent', 15, 'purchase', 'domestic', date '2024-08-21', null, 'Value Added Tax Proclamation No. 1341/2024, art. 30(1) — no credit for input tax on passenger vehicles and their repair, unless the person deals in them; on entertainment, except in the cases the article lists; or on club membership fees for sporting, social or recreational activities. The tax is a cost: it lands on the account of the line and reaches no box.', null, null, 120, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'vat-proclamation', null, null, null, null),
  ('ET', 'ET-P-EX', 'Purchase, exempt', '{}'::jsonb, 'An insurance premium, or another exempt supply bought for the business', 'percent', 0, 'purchase', 'exempt', date '2024-08-21', null, 'Value Added Tax Proclamation No. 1341/2024, art. 10(1) and Schedule 2 — an exempt supply bears no VAT, so there is nothing to credit.', null, null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-proclamation', null, null, null, null),
  ('ET', 'ET-P-IMP', 'Import of goods, VAT paid at the border', '{}'::jsonb, 'VAT collected by the Customs Commission on importation and credited once paid', 'percent', 15, 'purchase', 'import', date '2024-08-21', null, 'Value Added Tax Proclamation No. 1341/2024, art. 8(1) — VAT is charged on taxable imports; art. 27(1) — the taxable value of imports is the customs value plus duties and fiscal charges; art. 29(1) — the VAT paid on imports is creditable. The tax is owed to Customs, not to the supplier, so it waits on 2125 until the import declaration is settled.', null, null, 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-proclamation', null, null, null, null),
  ('ET', 'ET-S-15', 'Sale, standard rate 15 %', '{}'::jsonb, 'The general rate on a taxable supply made in Ethiopia', 'percent', 15, 'sale', 'domestic', date '2024-08-21', null, 'Value Added Tax Proclamation No. 1341/2024, art. 8(2) — VAT is imposed at zero per cent on a zero-rated supply and at fifteen per cent in every other case; art. 8(1) — it applies to taxable supplies by a registered person. Registration is compulsory above an annual turnover of ETB 2,000,000 (art. 12(2), or the amount the Directive sets). Electricity and water above the monthly 200 kWh and 15 cubic metres thresholds are taxed at this rate (utilities directive of 5 September 2024).', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-proclamation', null, null, null, null),
  ('ET', 'ET-S-EX-FIN', 'Sale, exempt (financial services)', '{}'::jsonb, 'Interest on loans, insurance and other financial services', 'percent', 0, 'sale', 'exempt', date '2024-08-21', null, 'Value Added Tax Proclamation No. 1341/2024, art. 10(1) — a supply specified in Schedule 2 is an exempt supply; Schedule 2 covers financial services (the Regulation excludes legal, accounting and debt-collection services from the exemption). An exempt supply carries no output VAT and no input VAT is deductible against it.', 'E', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-proclamation', null, null, null, null),
  ('ET', 'ET-S-EX-RES', 'Sale, exempt (residential rent)', '{}'::jsonb, 'Letting of residential premises', 'percent', 0, 'sale', 'exempt', date '2024-08-21', null, 'Value Added Tax Proclamation No. 1341/2024, art. 10(1) and Schedule 2 — the letting of residential premises (and parking attached to them, per the Regulation) is exempt.', 'E', null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-proclamation', null, null, null, null),
  ('ET', 'ET-S-EX-UTIL', 'Sale, exempt (first 200 kWh of electricity or 15 m³ of water)', '{}'::jsonb, 'The monthly household allowance of electricity or water supplied exempt from VAT', 'percent', 0, 'sale', 'exempt', date '2024-09-05', null, 'Directive of the Ministry of Finance of 5 September 2024 — electricity and water supplies are taxable under the Proclamation of 21 August 2024 except the first 200 kWh of electricity and the first 15 cubic metres of water consumed in a month (bottled water excluded). The supplier splits a bill into an exempt tier on this code and a taxable one on ET-S-15; the core cannot split a quantity automatically, which docs/international.md records.', 'E', null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'utilities-directive', null, null, null, null),
  ('ET', 'ET-S-ZR-EXP', 'Sale, zero-rated (export of goods)', '{}'::jsonb, 'Goods exported from Ethiopia', 'percent', 0, 'sale', 'export', date '2024-08-21', null, 'Value Added Tax Proclamation No. 1341/2024, art. 9 — a supply specified in Schedule 1 is a zero-rated supply; Schedule 1 covers the export of goods. The seller keeps the documentary proof of export the tax authority accepts. A zero-rated supply remains taxable, so input tax stays deductible.', 'G', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-proclamation', null, null, null, null),
  ('ET', 'ET-S-ZR-EXPSVC', 'Sale, zero-rated (export of services)', '{}'::jsonb, 'A service supplied to a customer outside Ethiopia', 'percent', 0, 'sale', 'export', date '2024-08-21', null, 'Value Added Tax Proclamation No. 1341/2024, art. 9 and Schedule 1 — the export of services is zero-rated; the proof of the customer''s foreign location is documentary and is kept by the seller.', 'G', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-proclamation', null, null, null, null),
  ('ET', 'ET-S-ZR-INTL', 'Sale, zero-rated (international transport)', '{}'::jsonb, 'International air or sea transport of passengers or goods', 'percent', 0, 'sale', 'export', date '2024-08-21', null, 'Value Added Tax Proclamation No. 1341/2024, art. 9 and Schedule 1 — international transport services are zero-rated.', 'G', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-proclamation', null, null, null, null)
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
    ('ET-P-15', 'invoice', 'base', 100, null, '6', array['6']::text[], 100, 'ET-VAT', 10),
    ('ET-P-15', 'invoice', 'tax', 100, '1150', '6', array['6']::text[], 100, 'ET-VAT', 20),
    ('ET-P-15', 'credit_note', 'base', 100, null, '6', array['6']::text[], -100, 'ET-VAT', 10),
    ('ET-P-15', 'credit_note', 'tax', 100, '1150', '6', array['6']::text[], -100, 'ET-VAT', 20),
    ('ET-P-15-BL', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('ET-P-15-BL', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('ET-P-15-BL', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('ET-P-15-BL', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('ET-P-EX', 'invoice', 'base', 100, null, '7', array['7']::text[], 100, 'ET-VAT', 10),
    ('ET-P-EX', 'credit_note', 'base', 100, null, '7', array['7']::text[], -100, 'ET-VAT', 10),
    ('ET-P-IMP', 'invoice', 'base', 100, null, '6', array['6']::text[], 100, 'ET-VAT', 10),
    ('ET-P-IMP', 'invoice', 'tax', 100, '1150', '6', array['6']::text[], 100, 'ET-VAT', 20),
    ('ET-P-IMP', 'invoice', 'tax', -100, '2125', null, null, 100, null, 30),
    ('ET-P-IMP', 'credit_note', 'base', 100, null, '6', array['6']::text[], -100, 'ET-VAT', 10),
    ('ET-P-IMP', 'credit_note', 'tax', 100, '1150', '6', array['6']::text[], -100, 'ET-VAT', 20),
    ('ET-P-IMP', 'credit_note', 'tax', -100, '2125', null, null, 100, null, 30),
    ('ET-S-15', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'ET-VAT', 10),
    ('ET-S-15', 'invoice', 'tax', 100, '2100', '1', array['1']::text[], 100, 'ET-VAT', 20),
    ('ET-S-15', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'ET-VAT', 10),
    ('ET-S-15', 'credit_note', 'tax', 100, '2100', '1', array['1']::text[], -100, 'ET-VAT', 20),
    ('ET-S-EX-FIN', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'ET-VAT', 10),
    ('ET-S-EX-FIN', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'ET-VAT', 10),
    ('ET-S-EX-RES', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'ET-VAT', 10),
    ('ET-S-EX-RES', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'ET-VAT', 10),
    ('ET-S-EX-UTIL', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'ET-VAT', 10),
    ('ET-S-EX-UTIL', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'ET-VAT', 10),
    ('ET-S-ZR-EXP', 'invoice', 'base', 100, null, '2', array['2']::text[], 100, 'ET-VAT', 10),
    ('ET-S-ZR-EXP', 'credit_note', 'base', 100, null, '2', array['2']::text[], -100, 'ET-VAT', 10),
    ('ET-S-ZR-EXPSVC', 'invoice', 'base', 100, null, '2', array['2']::text[], 100, 'ET-VAT', 10),
    ('ET-S-ZR-EXPSVC', 'credit_note', 'base', 100, null, '2', array['2']::text[], -100, 'ET-VAT', 10),
    ('ET-S-ZR-INTL', 'invoice', 'base', 100, null, '2', array['2']::text[], 100, 'ET-VAT', 10),
    ('ET-S-ZR-INTL', 'credit_note', 'base', 100, null, '2', array['2']::text[], -100, 'ET-VAT', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'ET' and t.code = v.tax_code
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
  ('ET', 'ET-VAT', 'Monthly VAT declaration', array['month']::declaration_period[], 'month'::declaration_period, date '2024-08-21', null, 'Value Added Tax Proclamation No. 1341/2024, art. 58 — a registered person files a VAT return for each accounting period, whether or not tax is payable; the accounting period is each calendar month of the Ethiopian calendar, the months of Nehase (August) and Pagumen being aggregated and treated as one month. The return is filed electronically on the Ministry of Revenues e-Tax portal. This pack carries the output side, the credit side and the net figure; credit brought forward from earlier months (art. 48), the refund claim (arts. 49-51), the 50 % withholding of VAT by public bodies (art. 62) and the reverse charge on services bought from abroad (art. 6) are period-to-period settlements or mechanisms the declaration format cannot state as a plus/minus list, and are recorded in docs/international.md. The numbering of the boxes is this pack''s own: the layout of the Ministry''s bilingual monthly declaration could not be opened in machine-readable form, so each box states what it holds and the article it comes from rather than a printed line number.', true,'last_day_of_month_after_period'::filing_deadline_rule, null, null, 'Value Added Tax Proclamation No. 1341/2024, art. 58 — the return is filed on or before the last day of the calendar month following the end of the accounting period; art. 59 — the net VAT is payable by the same date. The Ethiopian calendar has twelve months of thirty days and a thirteenth, Pagumen, of five or six: because Nehase (August) and Pagumen are one accounting period, the deadline is the end of the Ethiopian month that follows that combined period, which the Gregorian month-end this rule computes only approximates. The gap is recorded in docs/international.md.', 'vat-proclamation', null)
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
  ('ET', 'ET-VAT', '1', 'base', 'Taxable sales (15 %) — value', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Art. 8(2): sales at the 15 % rate, excluding VAT.', 'vat-proclamation'),
  ('ET', 'ET-VAT', '1', 'tax', 'Taxable sales (15 %) — output VAT', '{}'::jsonb, 15, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Art. 8(2): the output VAT on the sales of box 1.', 'vat-proclamation'),
  ('ET', 'ET-VAT', '2', 'base', 'Zero-rated sales', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Art. 9 and Schedule 1: exports, international transport and the other zero-rated supplies.', 'vat-proclamation'),
  ('ET', 'ET-VAT', '3', 'base', 'Exempt sales', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Art. 10 and Schedule 2: financial services, residential rent, health, education and the other exempt supplies, and the exempt tier of electricity and water.', 'vat-proclamation'),
  ('ET', 'ET-VAT', '4', 'total', 'Total sales', '{}'::jsonb, 40, null, array['1:base', '2', '3']::text[], '{}'::text[], null, null, false, false, null, 'Sum of boxes 1 (value), 2 and 3.', 'vat-proclamation'),
  ('ET', 'ET-VAT', '5', 'total', 'Total output VAT', '{}'::jsonb, 50, null, array['1:tax']::text[], '{}'::text[], null, null, false, false, null, 'Output VAT of box 1; zero-rated and exempt sales carry none.', 'vat-proclamation'),
  ('ET', 'ET-VAT', '6', 'base', 'Taxable purchases and imports (15 %) — value', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Art. 29(1): purchases and imports whose input tax is creditable.', 'vat-proclamation'),
  ('ET', 'ET-VAT', '6', 'tax', 'Taxable purchases and imports (15 %) — input VAT', '{}'::jsonb, 65, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Art. 29(1): the input tax credited, including VAT paid at customs on imports.', 'vat-proclamation'),
  ('ET', 'ET-VAT', '7', 'base', 'Exempt purchases', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Art. 10: purchases of exempt supplies, which carry no input tax.', 'vat-proclamation'),
  ('ET', 'ET-VAT', '8', 'total', 'Total purchases', '{}'::jsonb, 80, null, array['6:base', '7']::text[], '{}'::text[], null, null, false, false, null, 'Sum of boxes 6 (value) and 7.', 'vat-proclamation'),
  ('ET', 'ET-VAT', '9', 'total', 'Total input VAT', '{}'::jsonb, 90, null, array['6:tax']::text[], '{}'::text[], null, null, false, false, null, 'Input VAT of box 6.', 'vat-proclamation'),
  ('ET', 'ET-VAT', '10', 'total', 'VAT payable / credit for the month', '{}'::jsonb, 100, null, array['5']::text[], array['9']::text[], null, null, false, false, null, 'Output VAT (box 5) less input VAT (box 9). A positive figure is payable by the deadline above (art. 59); a negative one is a credit carried forward to later months (art. 48) or refunded in the cases of arts. 49-51, which this pack does not track.', 'vat-proclamation')
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
   source_key)
values
  ('ET-IFRS-IS', 'ET', 'default', 'Profit and loss account', 'income_statement', 'IFRS-SME', date '2019-07-08', null, 'Financial Reporting Proclamation No. 847/2014, art. 5 — commercial organisations prepare their financial statements under IFRS Accounting Standards, public interest entities in full, and under the IFRS for SMEs Accounting Standard when they have no public accountability; the Accounting and Auditing Board of Ethiopia (AABE) endorses and enforces the standards (IFRS Foundation jurisdictional profile). Ethiopia has no statutory chart of accounts or statement layout, so the lines below follow section 4 (statement of financial position) and section 5 (statement of comprehensive income, expenses by nature) of the IFRS for SMEs Accounting Standard. Presented as a single statement of profit or loss.', 'ifrs-profile'),
  ('ET-IFRS-SFP', 'ET', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS-SME', date '2019-07-08', null, 'Financial Reporting Proclamation No. 847/2014, art. 5 — commercial organisations prepare their financial statements under IFRS Accounting Standards, public interest entities in full, and under the IFRS for SMEs Accounting Standard when they have no public accountability; the Accounting and Auditing Board of Ethiopia (AABE) endorses and enforces the standards (IFRS Foundation jurisdictional profile). Ethiopia has no statutory chart of accounts or statement layout, so the lines below follow section 4 (statement of financial position) and section 5 (statement of comprehensive income, expenses by nature) of the IFRS for SMEs Accounting Standard. Presented as a statement of financial position with total assets less total liabilities equal to equity.', 'ifrs-profile')
on conflict (code) do update set
  country         = excluded.country,
  chart_code      = excluded.chart_code,
  name            = excluded.name,
  kind            = excluded.kind,
  framework       = excluded.framework,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference,
  source_key      = excluded.source_key;

insert into statement_line_templates
  (statement_code, code, parent_code, name, name_i18n, sequence, sign, is_total,
   plus_lines, minus_lines, xbrl_element, legal_reference, source_key)
values
  ('ET-IFRS-IS', '1', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-IS', '2', null, 'Other income', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-IS', '3', null, 'Purchases and changes in inventories', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-IS', '4', null, 'Employee benefits expense', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-IS', '5', null, 'Depreciation and amortisation', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-IS', '6', null, 'Other operating expenses', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-IS', '7', null, 'Finance costs', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-IS', '8', null, 'Profit before tax', '{}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('ET-IFRS-IS', '9', null, 'Income tax expense', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-IS', '10', null, 'Profit for the year', '{}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, null, null),
  ('ET-IFRS-SFP', 'CA', null, 'Current assets', '{}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5', 'CA.6']::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'CA.1', null, 'Cash and cash equivalents', '{}'::jsonb, 11, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'CA.2', null, 'Trade and other receivables', '{}'::jsonb, 12, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'CA.3', null, 'Inventories', '{}'::jsonb, 13, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'CA.4', null, 'Financial assets', '{}'::jsonb, 14, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'CA.5', null, 'Current tax recoverable', '{}'::jsonb, 15, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'CA.6', null, 'Prepayments and accrued income', '{}'::jsonb, 16, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'NCA', null, 'Non-current assets', '{}'::jsonb, 20, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4', 'NCA.5', 'NCA.6', 'NCA.7']::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'NCA.1', null, 'Property, plant and equipment', '{}'::jsonb, 21, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'NCA.2', null, 'Investment property', '{}'::jsonb, 22, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'NCA.3', null, 'Intangible assets', '{}'::jsonb, 23, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'NCA.4', null, 'Investments in associates', '{}'::jsonb, 24, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'NCA.5', null, 'Investments in joint ventures', '{}'::jsonb, 25, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'NCA.6', null, 'Financial assets', '{}'::jsonb, 26, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'NCA.7', null, 'Deferred tax assets', '{}'::jsonb, 27, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'TA', null, 'Total assets', '{}'::jsonb, 30, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'CL', null, 'Current liabilities', '{}'::jsonb, 40, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4', 'CL.5']::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'CL.1', null, 'Trade and other payables', '{}'::jsonb, 41, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'CL.2', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 42, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'CL.3', null, 'Amounts due to directors', '{}'::jsonb, 43, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'CL.4', null, 'Current tax payable', '{}'::jsonb, 44, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'CL.5', null, 'Provisions', '{}'::jsonb, 45, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'NCL', null, 'Non-current liabilities', '{}'::jsonb, 50, 1, true, array['NCL.1', 'NCL.2', 'NCL.3']::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'NCL.1', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 51, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'NCL.2', null, 'Deferred tax liabilities', '{}'::jsonb, 52, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'NCL.3', null, 'Provisions', '{}'::jsonb, 53, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'TL', null, 'Total liabilities', '{}'::jsonb, 60, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'NA', null, 'Net assets', '{}'::jsonb, 70, 1, true, array['TA']::text[], array['TL']::text[], null, null, null),
  ('ET-IFRS-SFP', 'EQ', null, 'Equity', '{}'::jsonb, 80, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'EQ.1', null, 'Share capital', '{}'::jsonb, 81, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'EQ.2', null, 'Other reserves', '{}'::jsonb, 82, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ET-IFRS-SFP', 'EQ.3', null, 'Retained earnings', '{}'::jsonb, 83, -1, false, '{}'::text[], '{}'::text[], null, null, null)
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

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('ET-IFRS-IS', '1', 10, 'code_range', '4000', '4030', null, 'any'),
    ('ET-IFRS-IS', '2', 10, 'code_range', '4500', '4790', null, 'any'),
    ('ET-IFRS-IS', '3', 10, 'code_range', '5000', '5100', null, 'any'),
    ('ET-IFRS-IS', '4', 10, 'code_range', '6000', '6080', null, 'any'),
    ('ET-IFRS-IS', '5', 10, 'code_range', '6200', '6220', null, 'any'),
    ('ET-IFRS-IS', '6', 10, 'code_range', '6300', '6990', null, 'any'),
    ('ET-IFRS-IS', '7', 10, 'code_range', '7000', '7030', null, 'any'),
    ('ET-IFRS-IS', '9', 10, 'code_range', '8000', '8020', null, 'any'),
    ('ET-IFRS-SFP', 'CA.1', 10, 'code_range', '1000', '1040', null, 'any'),
    ('ET-IFRS-SFP', 'CA.2', 10, 'code_range', '1100', '1160', null, 'any'),
    ('ET-IFRS-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('ET-IFRS-SFP', 'CA.4', 10, 'account_code', '1300', null, null, 'any'),
    ('ET-IFRS-SFP', 'CA.5', 10, 'account_code', '1350', null, null, 'any'),
    ('ET-IFRS-SFP', 'CA.6', 10, 'code_range', '1400', '1410', null, 'any'),
    ('ET-IFRS-SFP', 'NCA.1', 10, 'code_range', '1600', '1671', null, 'any'),
    ('ET-IFRS-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('ET-IFRS-SFP', 'NCA.3', 10, 'code_range', '1750', '1760', null, 'any'),
    ('ET-IFRS-SFP', 'NCA.4', 10, 'account_code', '1800', null, null, 'any'),
    ('ET-IFRS-SFP', 'NCA.5', 10, 'account_code', '1810', null, null, 'any'),
    ('ET-IFRS-SFP', 'NCA.6', 10, 'code_range', '1830', '1840', null, 'any'),
    ('ET-IFRS-SFP', 'NCA.7', 10, 'account_code', '1900', null, null, 'any'),
    ('ET-IFRS-SFP', 'CL.1', 10, 'code_range', '2000', '2190', null, 'any'),
    ('ET-IFRS-SFP', 'CL.1', 20, 'account_code', '2990', null, null, 'credit'),
    ('ET-IFRS-SFP', 'CL.2', 10, 'code_range', '2200', '2240', null, 'any'),
    ('ET-IFRS-SFP', 'CL.3', 10, 'account_code', '2250', null, null, 'any'),
    ('ET-IFRS-SFP', 'CL.4', 10, 'account_code', '2300', null, null, 'any'),
    ('ET-IFRS-SFP', 'CL.5', 10, 'code_range', '2350', '2360', null, 'any'),
    ('ET-IFRS-SFP', 'NCL.1', 10, 'code_range', '2400', '2430', null, 'any'),
    ('ET-IFRS-SFP', 'NCL.2', 10, 'account_code', '2500', null, null, 'any'),
    ('ET-IFRS-SFP', 'NCL.3', 10, 'account_code', '2550', null, null, 'any'),
    ('ET-IFRS-SFP', 'EQ.1', 10, 'code_range', '3000', '3010', null, 'any'),
    ('ET-IFRS-SFP', 'EQ.2', 10, 'code_range', '3100', '3110', null, 'any'),
    ('ET-IFRS-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('ET', 'Ethiopia', '{}'::jsonb, array['en']::text[], 'ETB', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, 'month'::declaration_period)
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
  numbering_legal_reference     = 'Value Added Tax Proclamation No. 1341/2024, art. 52 — a registered person issues the original tax invoice for each supply, with the particulars the Regulation sets. No article asks for a gap-free series, which is why the style is `sequential`.',
  numbering_source_key          = 'vat-proclamation',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Value Added Tax Proclamation No. 1341/2024, art. 21(1) — a supply takes place at the earliest of the issue of the tax invoice, the receipt of payment (to the extent paid) and the delivery of the goods or completion of the services. This is a three-way earliest-of test; Ekwo''s `earliest_of_delivery_or_payment` omits the invoice date, so an invoice issued ahead of both delivery and payment fixes the tax point in Ethiopia but not in Ekwo''s own reading of the word. The gap is recorded in docs/international.md.',
  tax_point_source_key          = 'vat-proclamation',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'Ethiopia has no structured-invoice exchange format (no UBL, CII, Peppol or EN 16931 profile has been published) and no ISO 6523 party scheme, so `profile`, `party_scheme` and `vat_scheme` are null. What exists is a clearance model: Electronic Invoicing System Administration Directive No. 1142/2026 (9 June 2026) requires an invoice to be registered in real time on the Ministry of Revenues platform, which returns an Invoice Registration Number (receipts: a Receipt Reference Number) and a QR code, and the Tax Administration Amendment Proclamation No. 1434/2026 (in force 30 July 2026) raises the penalties. The directive is in force but no nationwide go-live date, rollout schedule or grace period had been published on 9 October 2026, and fiscal cash registers remain in use; `obligation` is therefore `none` until the Ministry activates taxpayers, and the clearance itself is outside the core. The gap is recorded in docs/international.md and in this pack''s README.',
  einvoice_source_key           = 'einvoicing-directive',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'july'
 where country = 'ET';
