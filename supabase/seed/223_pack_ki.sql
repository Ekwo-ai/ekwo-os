-- Ekwo OS — Kiribati: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/ki at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build ki`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Guidelines & Obligations of VAT Registered Businesses (31 May 2024) — registration threshold of $100,000 of sales, tax invoices showing the TIN and VAT-inclusive prices, VAT at 12.5 % on taxable supplies and none on exempt or zero-rated ones, the return and the VAT payable due within 15 days after the end of the quarter, late filing fee of $30 a month, late payment penalty of 15 % and interest of 15 % a year (Kiribati Tax Division, Ministry of Finance and Economic Development)
--     https://tax.gov.ki/wp-content/uploads/2025/05/Guidelines-Obligations-for-VAT-Registered-Businesses.pdf
--   Exemptions and Zero-rated items (August 2024) — the 26 exempt supplies and imports and the 9 zero-rated supplies of the VAT Act 2013 schedules, and the apportionment of input tax when part of the sales is exempt (full credit above 80 % taxable sales, proportional down to 20 %, none below) (Kiribati Tax Division, Ministry of Finance and Economic Development)
--     https://tax.gov.ki/wp-content/uploads/2025/05/Exempt-0-rated-supplies_AUG-2024-1.pdf
--   Value Added Tax Return, form RET 020, for a period of three months: boxes 1 to 7 (VAT collected), boxes 8 to 15 (VAT paid) and box 16 (VAT to pay or VAT credit); box 5 and box 11 are the VAT-inclusive totals divided by 9 (Kiribati Tax Division, Ministry of Finance and Economic Development)
--     https://tax.gov.ki/wp-content/uploads/2025/05/VAT-Return-Form.pdf
--   Kiribati VAT return instruction (January 2025) — the sixteen boxes one by one, written in Gilbertese with English terms: box 1 includes the zero-rated and exempt sales, box 4 is box 1 less boxes 2 and 3, box 5 is box 4 divided by 9, box 8 leaves out imports, box 12 is the VAT paid to Customs, box 13 the VAT withheld by the Government (Kiribati Tax Division, Ministry of Finance and Economic Development)
--     https://tax.gov.ki/wp-content/uploads/2025/05/Kiribati-VAT-return-instruction.pdf
--   Taxpayer's Obligation pamphlet (January 2026) — the tax invoice for VAT-registered businesses (VAT Regulations 2014, s 9), the quarterly VAT return due within 15 days after the end of the quarter, records kept seven years, late filing penalty of $30 a month, the PAYE and withholding tax returns due within 21 days after the end of the month (Kiribati Tax Division, Ministry of Finance and Economic Development)
--     https://tax.gov.ki/wp-content/uploads/2026/01/JAN-2026-Tax-Obligation-pamphlet.pdf
--   VAT — the forms and guidance of the Tax Division: blank VAT return, return instruction, exempt and zero-rated supplies, mixed supplies fact sheet, guidelines for registered businesses (Kiribati Tax Division, Ministry of Finance and Economic Development)
--     https://tax.gov.ki/tax/vat/
--   IAS 1 Presentation of Financial Statements — the statement of financial position and the statement of profit or loss, expenses analysed by nature; no Kiribati text prescribing a layout or a chart of accounts was found (IFRS Foundation)
--     https://www.ifrs.org/issued-standards/list-of-standards/ias-1-presentation-of-financial-statements/
--   Kiribati Tax Division — tax administration portal (forms, guides, contacts; returns are filed at the tax office) (Kiribati Tax Division, Ministry of Finance and Economic Development)
--     https://tax.gov.ki/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('KI', 'Kiribati', '0.1.0', date '2026-10-25', '20261023124650', 'community', null, null, '4c2dbc5044241ee74e96396818f5717b7156af2f4fdb9f1653b12f173dd6cfe1', '[{"key":"guidelines","title":"Guidelines & Obligations of VAT Registered Businesses (31 May 2024) — registration threshold of $100,000 of sales, tax invoices showing the TIN and VAT-inclusive prices, VAT at 12.5 % on taxable supplies and none on exempt or zero-rated ones, the return and the VAT payable due within 15 days after the end of the quarter, late filing fee of $30 a month, late payment penalty of 15 % and interest of 15 % a year","publisher":"Kiribati Tax Division, Ministry of Finance and Economic Development","url":"https://tax.gov.ki/wp-content/uploads/2025/05/Guidelines-Obligations-for-VAT-Registered-Businesses.pdf","consulted_on":"2026-10-25","kind":"guidance"},{"key":"exempt-zero-rated","title":"Exemptions and Zero-rated items (August 2024) — the 26 exempt supplies and imports and the 9 zero-rated supplies of the VAT Act 2013 schedules, and the apportionment of input tax when part of the sales is exempt (full credit above 80 % taxable sales, proportional down to 20 %, none below)","publisher":"Kiribati Tax Division, Ministry of Finance and Economic Development","url":"https://tax.gov.ki/wp-content/uploads/2025/05/Exempt-0-rated-supplies_AUG-2024-1.pdf","consulted_on":"2026-10-25","kind":"guidance"},{"key":"vat-return","title":"Value Added Tax Return, form RET 020, for a period of three months: boxes 1 to 7 (VAT collected), boxes 8 to 15 (VAT paid) and box 16 (VAT to pay or VAT credit); box 5 and box 11 are the VAT-inclusive totals divided by 9","publisher":"Kiribati Tax Division, Ministry of Finance and Economic Development","url":"https://tax.gov.ki/wp-content/uploads/2025/05/VAT-Return-Form.pdf","consulted_on":"2026-10-25","kind":"form"},{"key":"return-instructions","title":"Kiribati VAT return instruction (January 2025) — the sixteen boxes one by one, written in Gilbertese with English terms: box 1 includes the zero-rated and exempt sales, box 4 is box 1 less boxes 2 and 3, box 5 is box 4 divided by 9, box 8 leaves out imports, box 12 is the VAT paid to Customs, box 13 the VAT withheld by the Government","publisher":"Kiribati Tax Division, Ministry of Finance and Economic Development","url":"https://tax.gov.ki/wp-content/uploads/2025/05/Kiribati-VAT-return-instruction.pdf","consulted_on":"2026-10-25","kind":"guidance"},{"key":"obligations","title":"Taxpayer''s Obligation pamphlet (January 2026) — the tax invoice for VAT-registered businesses (VAT Regulations 2014, s 9), the quarterly VAT return due within 15 days after the end of the quarter, records kept seven years, late filing penalty of $30 a month, the PAYE and withholding tax returns due within 21 days after the end of the month","publisher":"Kiribati Tax Division, Ministry of Finance and Economic Development","url":"https://tax.gov.ki/wp-content/uploads/2026/01/JAN-2026-Tax-Obligation-pamphlet.pdf","consulted_on":"2026-10-25","kind":"guidance"},{"key":"vat-page","title":"VAT — the forms and guidance of the Tax Division: blank VAT return, return instruction, exempt and zero-rated supplies, mixed supplies fact sheet, guidelines for registered businesses","publisher":"Kiribati Tax Division, Ministry of Finance and Economic Development","url":"https://tax.gov.ki/tax/vat/","consulted_on":"2026-10-25","kind":"guidance"},{"key":"ias-1","title":"IAS 1 Presentation of Financial Statements — the statement of financial position and the statement of profit or loss, expenses analysed by nature; no Kiribati text prescribing a layout or a chart of accounts was found","publisher":"IFRS Foundation","url":"https://www.ifrs.org/issued-standards/list-of-standards/ias-1-presentation-of-financial-statements/","consulted_on":"2026-10-25","kind":"guidance"},{"key":"tax-portal","title":"Kiribati Tax Division — tax administration portal (forms, guides, contacts; returns are filed at the tax office)","publisher":"Kiribati Tax Division, Ministry of Finance and Economic Development","url":"https://tax.gov.ki/","consulted_on":"2026-10-25","kind":"portal"}]'::jsonb)
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
  ('KI', 'default', 'Kiribati reference chart of accounts', '{}'::jsonb, true, 'companies', array['KI-IFRS-IS', 'KI-IFRS-SFP']::text[], null, 'There is no legal chart of accounts in the texts read for Kiribati, and no text read names a standard setter or a framework for company accounts. This chart is original: four digits, blocked so that each range reaches one line of the IFRS-style statements below (IAS 1, expenses by nature), with the accounts a Kiribati trading company keeps — VAT output and input tax, import VAT owed to Customs, PAYE withheld, provident fund contributions and withholding taxes payable.', 'ias-1')
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
  ('KI', 'default', '1000', 'Petty cash', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('KI', 'default', '1010', 'Current account — AUD', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('KI', 'default', '1020', 'Fixed deposits placed for three months or less', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('KI', 'default', '1030', 'Foreign currency account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('KI', 'default', '1040', 'Cash in transit — card and mobile-payment settlements', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('KI', 'default', '1100', 'Trade receivables', '{}'::jsonb, 'asset_receivable', true, null, 60),
  ('KI', 'default', '1110', 'Trade receivables — allowance for impairment', '{}'::jsonb, 'asset_current', false, null, 70),
  ('KI', 'default', '1120', 'Other receivables', '{}'::jsonb, 'asset_current', false, null, 80),
  ('KI', 'default', '1130', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 90),
  ('KI', 'default', '1140', 'Deposits paid', '{}'::jsonb, 'asset_current', false, null, 100),
  ('KI', 'default', '1150', 'VAT input tax', '{}'::jsonb, 'asset_current', false, null, 110),
  ('KI', 'default', '1155', 'VAT refundable by the Tax Division — net of a filed return', '{}'::jsonb, 'asset_current', true, null, 120),
  ('KI', 'default', '1160', 'Advances to staff', '{}'::jsonb, 'asset_current', false, null, 130),
  ('KI', 'default', '1200', 'Inventories — goods for resale', '{}'::jsonb, 'asset_current', false, null, 140),
  ('KI', 'default', '1210', 'Inventories — raw materials', '{}'::jsonb, 'asset_current', false, null, 150),
  ('KI', 'default', '1220', 'Inventories — work in progress', '{}'::jsonb, 'asset_current', false, null, 160),
  ('KI', 'default', '1230', 'Inventories — finished goods', '{}'::jsonb, 'asset_current', false, null, 170),
  ('KI', 'default', '1300', 'Short-term investments', '{}'::jsonb, 'asset_current', false, null, 180),
  ('KI', 'default', '1350', 'Current tax recoverable', '{}'::jsonb, 'asset_current', false, null, 190),
  ('KI', 'default', '1400', 'Prepayments', '{}'::jsonb, 'asset_prepayments', false, null, 200),
  ('KI', 'default', '1410', 'Accrued income', '{}'::jsonb, 'asset_prepayments', false, null, 210),
  ('KI', 'default', '1600', 'Land and buildings — cost', '{}'::jsonb, 'asset_fixed', false, null, 220),
  ('KI', 'default', '1601', 'Land and buildings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 230),
  ('KI', 'default', '1610', 'Leasehold improvements — cost', '{}'::jsonb, 'asset_fixed', false, null, 240),
  ('KI', 'default', '1611', 'Leasehold improvements — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 250),
  ('KI', 'default', '1620', 'Plant and machinery — cost', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('KI', 'default', '1621', 'Plant and machinery — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('KI', 'default', '1630', 'Office equipment — cost', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('KI', 'default', '1631', 'Office equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('KI', 'default', '1640', 'Computers — cost', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('KI', 'default', '1641', 'Computers — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('KI', 'default', '1650', 'Furniture and fittings — cost', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('KI', 'default', '1651', 'Furniture and fittings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('KI', 'default', '1660', 'Motor vehicles — cost', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('KI', 'default', '1661', 'Motor vehicles — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('KI', 'default', '1670', 'Right-of-use assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('KI', 'default', '1671', 'Right-of-use assets — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('KI', 'default', '1700', 'Investment property', '{}'::jsonb, 'asset_non_current', false, null, 380),
  ('KI', 'default', '1750', 'Intangible assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 390),
  ('KI', 'default', '1751', 'Intangible assets — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 400),
  ('KI', 'default', '1760', 'Goodwill', '{}'::jsonb, 'asset_fixed', false, null, 410),
  ('KI', 'default', '1800', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('KI', 'default', '1810', 'Investments in joint ventures', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('KI', 'default', '1830', 'Long-term financial assets', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('KI', 'default', '1840', 'Long-term deposits', '{}'::jsonb, 'asset_non_current', false, null, 450),
  ('KI', 'default', '1900', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('KI', 'default', '2000', 'Trade payables', '{}'::jsonb, 'liability_payable', true, null, 470),
  ('KI', 'default', '2010', 'Accrued expenses', '{}'::jsonb, 'liability_current', false, null, 480),
  ('KI', 'default', '2020', 'Other payables', '{}'::jsonb, 'liability_current', false, null, 490),
  ('KI', 'default', '2030', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 500),
  ('KI', 'default', '2040', 'Deposits received from customers', '{}'::jsonb, 'liability_current', false, null, 510),
  ('KI', 'default', '2100', 'VAT output tax', '{}'::jsonb, 'liability_current', false, null, 520),
  ('KI', 'default', '2110', 'VAT payable to the Tax Division — net of a filed return', '{}'::jsonb, 'liability_current', true, null, 530),
  ('KI', 'default', '2125', 'Import VAT payable to Customs at the border', '{}'::jsonb, 'liability_current', false, null, 540),
  ('KI', 'default', '2126', 'VAT on imported capital goods — held until paid', '{}'::jsonb, 'liability_current', false, null, 550),
  ('KI', 'default', '2140', 'PAYE withheld and payable to the Tax Division', '{}'::jsonb, 'liability_current', false, null, 560),
  ('KI', 'default', '2150', 'Provident fund contributions payable', '{}'::jsonb, 'liability_current', false, null, 570),
  ('KI', 'default', '2155', 'Excise duty payable', '{}'::jsonb, 'liability_current', false, null, 580),
  ('KI', 'default', '2160', 'Withholding taxes payable to the Tax Division', '{}'::jsonb, 'liability_current', false, null, 590),
  ('KI', 'default', '2165', 'Other statutory amounts payable', '{}'::jsonb, 'liability_current', false, null, 600),
  ('KI', 'default', '2180', 'Salaries payable', '{}'::jsonb, 'liability_current', false, null, 610),
  ('KI', 'default', '2190', 'Directors'' fees payable', '{}'::jsonb, 'liability_current', false, null, 620),
  ('KI', 'default', '2200', 'Bank overdraft', '{}'::jsonb, 'liability_current', false, null, 630),
  ('KI', 'default', '2210', 'Bank loans — current portion', '{}'::jsonb, 'liability_current', false, null, 640),
  ('KI', 'default', '2220', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 650),
  ('KI', 'default', '2230', 'Hire purchase — current portion', '{}'::jsonb, 'liability_current', false, null, 660),
  ('KI', 'default', '2240', 'Corporate credit card', '{}'::jsonb, 'liability_credit_card', false, null, 670),
  ('KI', 'default', '2250', 'Amounts due to directors', '{}'::jsonb, 'liability_current', false, null, 680),
  ('KI', 'default', '2300', 'Current tax payable', '{}'::jsonb, 'liability_current', false, null, 690),
  ('KI', 'default', '2350', 'Provision for unutilised leave', '{}'::jsonb, 'liability_current', false, null, 700),
  ('KI', 'default', '2360', 'Other provisions — current', '{}'::jsonb, 'liability_current', false, null, 710),
  ('KI', 'default', '2400', 'Bank loans — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 720),
  ('KI', 'default', '2410', 'Lease liabilities — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 730),
  ('KI', 'default', '2420', 'Hire purchase — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 740),
  ('KI', 'default', '2430', 'Loans from shareholders and directors — non-current', '{}'::jsonb, 'liability_non_current', false, null, 750),
  ('KI', 'default', '2500', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 760),
  ('KI', 'default', '2550', 'Provision for reinstatement costs', '{}'::jsonb, 'liability_non_current', false, null, 770),
  ('KI', 'default', '2990', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 780),
  ('KI', 'default', '3000', 'Share capital', '{}'::jsonb, 'equity', false, null, 790),
  ('KI', 'default', '3010', 'Treasury shares', '{}'::jsonb, 'equity', false, null, 800),
  ('KI', 'default', '3100', 'Other reserves', '{}'::jsonb, 'equity', false, null, 810),
  ('KI', 'default', '3110', 'Foreign currency translation reserve', '{}'::jsonb, 'equity', false, null, 820),
  ('KI', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 830),
  ('KI', 'default', '3210', 'Dividends paid', '{}'::jsonb, 'equity_retained', false, null, 840),
  ('KI', 'default', '4000', 'Sales of goods', '{}'::jsonb, 'income', false, null, 850),
  ('KI', 'default', '4010', 'Services rendered', '{}'::jsonb, 'income', false, null, 860),
  ('KI', 'default', '4020', 'Export sales of goods', '{}'::jsonb, 'income', false, null, 870),
  ('KI', 'default', '4030', 'Export of services', '{}'::jsonb, 'income', false, null, 880),
  ('KI', 'default', '4500', 'Interest income', '{}'::jsonb, 'income_other', false, null, 890),
  ('KI', 'default', '4510', 'Dividend income', '{}'::jsonb, 'income_other', false, null, 900),
  ('KI', 'default', '4520', 'Rental income', '{}'::jsonb, 'income_other', false, null, 910),
  ('KI', 'default', '4530', 'Government grants', '{}'::jsonb, 'income_other', false, null, 920),
  ('KI', 'default', '4700', 'Foreign exchange gains', '{}'::jsonb, 'income_other', false, null, 930),
  ('KI', 'default', '4750', 'Gain on disposal of property plant and equipment', '{}'::jsonb, 'income_other', false, null, 940),
  ('KI', 'default', '4790', 'Other income', '{}'::jsonb, 'income_other', false, null, 950),
  ('KI', 'default', '5000', 'Purchases of goods for resale', '{}'::jsonb, 'expense_direct_cost', false, null, 960),
  ('KI', 'default', '5010', 'Freight inwards and import duties', '{}'::jsonb, 'expense_direct_cost', false, null, 970),
  ('KI', 'default', '5020', 'Subcontract costs', '{}'::jsonb, 'expense_direct_cost', false, null, 980),
  ('KI', 'default', '5100', 'Changes in inventories', '{}'::jsonb, 'expense_direct_cost', false, null, 990),
  ('KI', 'default', '6000', 'Salaries and wages', '{}'::jsonb, 'expense', false, null, 1000),
  ('KI', 'default', '6010', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 1010),
  ('KI', 'default', '6020', 'Directors'' fees', '{}'::jsonb, 'expense', false, null, 1020),
  ('KI', 'default', '6030', 'Provident fund contributions — employer', '{}'::jsonb, 'expense', false, null, 1030),
  ('KI', 'default', '6035', 'Staff training and welfare', '{}'::jsonb, 'expense', false, null, 1040),
  ('KI', 'default', '6040', 'Other statutory employment costs', '{}'::jsonb, 'expense', false, null, 1050),
  ('KI', 'default', '6050', 'Retirement gratuity and end-of-service benefits', '{}'::jsonb, 'expense', false, null, 1060),
  ('KI', 'default', '6060', 'Staff amenities', '{}'::jsonb, 'expense', false, null, 1070),
  ('KI', 'default', '6070', 'Staff medical expenses and insurance', '{}'::jsonb, 'expense', false, null, 1080),
  ('KI', 'default', '6080', 'Staff training', '{}'::jsonb, 'expense', false, null, 1090),
  ('KI', 'default', '6200', 'Depreciation of property plant and equipment', '{}'::jsonb, 'expense_depreciation', false, null, 1100),
  ('KI', 'default', '6210', 'Depreciation of right-of-use assets', '{}'::jsonb, 'expense_depreciation', false, null, 1110),
  ('KI', 'default', '6220', 'Amortisation of intangible assets', '{}'::jsonb, 'expense_depreciation', false, null, 1120),
  ('KI', 'default', '6300', 'Rent — short-term leases', '{}'::jsonb, 'expense', false, null, 1130),
  ('KI', 'default', '6310', 'Utilities', '{}'::jsonb, 'expense', false, null, 1140),
  ('KI', 'default', '6320', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 1150),
  ('KI', 'default', '6330', 'Cleaning and security services', '{}'::jsonb, 'expense', false, null, 1160),
  ('KI', 'default', '6340', 'Telephone and internet', '{}'::jsonb, 'expense', false, null, 1170),
  ('KI', 'default', '6350', 'Software subscriptions', '{}'::jsonb, 'expense', false, null, 1180),
  ('KI', 'default', '6360', 'Advertising and marketing', '{}'::jsonb, 'expense', false, null, 1190),
  ('KI', 'default', '6370', 'Travelling', '{}'::jsonb, 'expense', false, null, 1200),
  ('KI', 'default', '6380', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1210),
  ('KI', 'default', '6390', 'Entertainment', '{}'::jsonb, 'expense', false, null, 1220),
  ('KI', 'default', '6400', 'Subscriptions and memberships', '{}'::jsonb, 'expense', false, null, 1230),
  ('KI', 'default', '6410', 'Insurance', '{}'::jsonb, 'expense', false, null, 1240),
  ('KI', 'default', '6420', 'Professional fees', '{}'::jsonb, 'expense', false, null, 1250),
  ('KI', 'default', '6430', 'Audit fees', '{}'::jsonb, 'expense', false, null, 1260),
  ('KI', 'default', '6440', 'Company secretarial and registration fees', '{}'::jsonb, 'expense', false, null, 1270),
  ('KI', 'default', '6450', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1280),
  ('KI', 'default', '6455', 'Donations', '{}'::jsonb, 'expense', false, null, 1290),
  ('KI', 'default', '6460', 'Printing and stationery', '{}'::jsonb, 'expense', false, null, 1300),
  ('KI', 'default', '6470', 'Postage and courier', '{}'::jsonb, 'expense', false, null, 1310),
  ('KI', 'default', '6480', 'Licences permits and local authority fees', '{}'::jsonb, 'expense', false, null, 1320),
  ('KI', 'default', '6490', 'Royalties', '{}'::jsonb, 'expense', false, null, 1330),
  ('KI', 'default', '6500', 'Bad debts written off', '{}'::jsonb, 'expense', false, null, 1340),
  ('KI', 'default', '6510', 'Impairment loss on trade receivables', '{}'::jsonb, 'expense', false, null, 1350),
  ('KI', 'default', '6900', 'Sponsorship', '{}'::jsonb, 'expense', false, null, 1360),
  ('KI', 'default', '6950', 'Foreign exchange losses', '{}'::jsonb, 'expense', false, null, 1370),
  ('KI', 'default', '6960', 'Loss on disposal of property plant and equipment', '{}'::jsonb, 'expense', false, null, 1380),
  ('KI', 'default', '6990', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1390),
  ('KI', 'default', '7000', 'Interest on bank loans', '{}'::jsonb, 'expense', false, null, 1400),
  ('KI', 'default', '7010', 'Interest on lease liabilities', '{}'::jsonb, 'expense', false, null, 1410),
  ('KI', 'default', '7020', 'Hire purchase interest', '{}'::jsonb, 'expense', false, null, 1420),
  ('KI', 'default', '7030', 'Interest on loans from related parties and others', '{}'::jsonb, 'expense', false, null, 1430),
  ('KI', 'default', '8000', 'Current income tax expense', '{}'::jsonb, 'expense', false, null, 1440),
  ('KI', 'default', '8010', 'Deferred tax expense', '{}'::jsonb, 'expense', false, null, 1450),
  ('KI', 'default', '8020', 'Under or over provision of income tax in prior years', '{}'::jsonb, 'expense', false, null, 1460)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('KI', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('KI', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('KI', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('KI', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('KI', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('KI', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('KI', 'KI-P-0', 'Purchase, exempt or without VAT', '{}'::jsonb, 'A purchase of an exempt supply (for example a financial service), carrying no VAT', 'percent', 0, 'purchase', 'exempt', date '2024-01-01', null, 'Return RET 020, box 9 — non-creditable acquisitions: purchases on which no VAT was charged (instructions, box 9). They are in box 8 and out of box 10.', 'E', null, 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'return-instructions', null, null, null, null),
  ('KI', 'KI-P-12.5', 'Purchase, standard rate 12.5 %, deductible', '{}'::jsonb, 'A local purchase of goods, services or capital goods at the standard rate, used to make taxable supplies', 'percent', 12.5, 'purchase', 'domestic', date '2024-01-01', null, 'The Guidelines & Obligations for VAT Registered Businesses (item 6) charge VAT on taxable supplies at the rate of 12.5 %, none on exempt or zero-rated ones; the return divides the VAT-inclusive total by 9, which is the tax fraction of 12.5 %. Return RET 020, box 10 — purchases and expenses with VAT less the non-creditable ones — and box 11 — box 10 divided by 9. The engine posts the exclusive base to box 10a and the VAT to box 11. The form has no separate line for capital goods.', 'S', null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'guidelines', null, null, null, null),
  ('KI', 'KI-P-12.5-NC', 'Purchase, standard rate 12.5 %, input tax not claimed', '{}'::jsonb, 'A purchase on which input tax is not claimed — the VAT joins the cost', 'percent', 12.5, 'purchase', 'domestic', date '2024-01-01', null, 'Return RET 020, box 9 — non-creditable acquisitions: purchases that carry no creditable VAT, such as those from businesses that charge none and salaries and wages (instructions, box 9). Which purchases are barred is the preparer''s judgement. The VAT joins the cost; the base is posted to box 9, VAT excluded, which understates the VAT-inclusive figure the form asks for (see the README).', 'S', null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'return-instructions', null, null, null, null),
  ('KI', 'KI-P-IMP', 'Purchase of imported goods, 12.5 % VAT paid at Customs', '{}'::jsonb, 'Imported goods: the VAT paid to Customs at the border is claimed as input tax in box 12', 'percent', 12.5, 'purchase', 'import', date '2024-01-01', null, 'Return RET 020, box 12 — VAT on imports paid to Customs; the instructions of box 8 say the total of purchases must leave out imported goods and the VAT paid to Customs, claimed in box 12. The VAT owed to Customs sits on the import control account until paid.', null, null, 150, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'return-instructions', null, null, null, null),
  ('KI', 'KI-S-12.5', 'Sale, standard rate 12.5 %', '{}'::jsonb, 'A taxable supply of goods or services made in Kiribati by a registered person, neither zero-rated nor exempt', 'percent', 12.5, 'sale', 'domestic', date '2024-01-01', null, 'The Guidelines & Obligations for VAT Registered Businesses (item 6) charge VAT on taxable supplies at the rate of 12.5 %, none on exempt or zero-rated ones; the return divides the VAT-inclusive total by 9, which is the tax fraction of 12.5 %. Return RET 020, box 4 — sales subject to VAT, VAT included (box 1 less boxes 2 and 3) — and box 5 — box 4 divided by 9. The engine posts the exclusive base to box 4a and the VAT to box 5.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'guidelines', null, null, null, null),
  ('KI', 'KI-S-EX', 'Sale, exempt', '{}'::jsonb, 'A supply the VAT Act exempts — uncooked rice and flour, kerosene, financial services, education, medical services, residential letting and the others of the sheet', 'percent', 0, 'sale', 'exempt', date '2024-01-01', null, 'Exempt and zero-rated supplies sheet (August 2024): twenty-six exemptions, among them uncooked rice, uncooked wheat flour, kerosene, financial services, education, medical, dental and nursing services, and residential leases of two months or more. No VAT is charged and no credit is allowed on the inputs of an exempt sale. Return RET 020, box 3 — exempt sales, included in box 1 and taken out of box 4.', 'E', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'exempt-zero-rated', null, null, null, null),
  ('KI', 'KI-S-ZR', 'Sale, zero-rated (other)', '{}'::jsonb, 'A zero-rated supply made in Kiribati that is not an export — passenger transport by bus, truck or taxi, the transfer of a going concern between registered persons, consumable stores for vessels and aircraft going abroad and the like', 'percent', 0, 'sale', 'domestic', date '2024-01-01', null, 'Exempt and zero-rated supplies sheet (August 2024), the nine zero-rated items: exports, consumable stores for a fishing vessel, aircraft or ship going outside Kiribati, repair of temporarily imported goods, services used outside Kiribati, telecommunication services to non-residents, international transport, the transfer of an enterprise as a going concern between registered persons, a fishing licence used principally for exports, and passenger transport in Kiribati by bus, truck or taxi other than by a tour operator. One tax code carries the whole list; which item applies is the preparer''s judgement. Return RET 020, box 2.', 'Z', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'exempt-zero-rated', null, null, null, null),
  ('KI', 'KI-S-ZR-EXP', 'Sale, zero-rated (export or service used outside Kiribati)', '{}'::jsonb, 'Goods exported, or a service supplied to be used outside Kiribati, taxable at 0 %', 'percent', 0, 'sale', 'export', date '2024-01-01', null, 'Exempt and zero-rated supplies sheet (August 2024), zero-rated for VAT: exports; services to be used outside Kiribati; international transport services. A zero-rated supply is a taxable supply that keeps the input tax credit. Return RET 020, box 2 — zero-rated sales, included in box 1.', 'G', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'exempt-zero-rated', null, null, null, null)
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
    ('KI-P-0', 'invoice', 'base', 100, null, '9', array['9']::text[], 100, 'KI-VAT', 10),
    ('KI-P-0', 'credit_note', 'base', 100, null, '9', array['9']::text[], -100, 'KI-VAT', 10),
    ('KI-P-12.5', 'invoice', 'base', 100, null, '10a', array['10a']::text[], 100, 'KI-VAT', 10),
    ('KI-P-12.5', 'invoice', 'tax', 100, '1150', '11', array['11']::text[], 100, 'KI-VAT', 20),
    ('KI-P-12.5', 'credit_note', 'base', 100, null, '10a', array['10a']::text[], -100, 'KI-VAT', 10),
    ('KI-P-12.5', 'credit_note', 'tax', 100, '1150', '11', array['11']::text[], -100, 'KI-VAT', 20),
    ('KI-P-12.5-NC', 'invoice', 'base', 100, null, '9', array['9']::text[], 100, 'KI-VAT', 10),
    ('KI-P-12.5-NC', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('KI-P-12.5-NC', 'credit_note', 'base', 100, null, '9', array['9']::text[], -100, 'KI-VAT', 10),
    ('KI-P-12.5-NC', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('KI-P-IMP', 'invoice', 'base', 100, null, '12', array['12']::text[], 100, 'KI-VAT', 10),
    ('KI-P-IMP', 'invoice', 'tax', 100, '1150', '12', array['12']::text[], 100, 'KI-VAT', 20),
    ('KI-P-IMP', 'invoice', 'tax', -100, '2125', null, null, 100, null, 30),
    ('KI-P-IMP', 'credit_note', 'base', 100, null, '12', array['12']::text[], -100, 'KI-VAT', 10),
    ('KI-P-IMP', 'credit_note', 'tax', 100, '1150', '12', array['12']::text[], -100, 'KI-VAT', 20),
    ('KI-P-IMP', 'credit_note', 'tax', -100, '2125', null, null, 100, null, 30),
    ('KI-S-12.5', 'invoice', 'base', 100, null, '4a', array['4a']::text[], 100, 'KI-VAT', 10),
    ('KI-S-12.5', 'invoice', 'tax', 100, '2100', '5', array['5']::text[], 100, 'KI-VAT', 20),
    ('KI-S-12.5', 'credit_note', 'base', 100, null, '4a', array['4a']::text[], -100, 'KI-VAT', 10),
    ('KI-S-12.5', 'credit_note', 'tax', 100, '2100', '5', array['5']::text[], -100, 'KI-VAT', 20),
    ('KI-S-EX', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'KI-VAT', 10),
    ('KI-S-EX', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'KI-VAT', 10),
    ('KI-S-ZR', 'invoice', 'base', 100, null, '2', array['2']::text[], 100, 'KI-VAT', 10),
    ('KI-S-ZR', 'credit_note', 'base', 100, null, '2', array['2']::text[], -100, 'KI-VAT', 10),
    ('KI-S-ZR-EXP', 'invoice', 'base', 100, null, '2', array['2']::text[], 100, 'KI-VAT', 10),
    ('KI-S-ZR-EXP', 'credit_note', 'base', 100, null, '2', array['2']::text[], -100, 'KI-VAT', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'KI' and t.code = v.tax_code
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
  ('KI', 'KI-VAT', 'VAT return (RET 020)', array['quarter']::declaration_period[], 'quarter'::declaration_period, date '2024-01-01', null, 'Form RET 020, Value Added Tax Return, for a period of three months: sixteen boxes in two steps — VAT collected (1 to 7) and VAT paid (8 to 15) — and the difference in box 16. A registered business files quarterly (Guidelines & Obligations for VAT Registered Businesses, item 7). The form is VAT-inclusive on both sides: boxes 1, 4, 8 and 10 are totals here (exclusive base plus VAT), and the exclusive figures sit in the boxes 4a and 10a. Box 16 is signed: negative is the VAT credit.', true,'day_of_month_after_period'::filing_deadline_rule, 15, null, 'Guidelines & Obligations for VAT Registered Businesses, items 7 and 8, and the Tax Division''s Taxpayer''s Obligations pamphlet (January 2026): the return and the VAT payable are due within 15 days after the end of the quarter — the 15th of the month that follows a quarter ending on 31 March, 30 June, 30 September or 31 December. A due date on a weekend or a holiday is not shifted by this rule.', 'guidelines', null)
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
  ('KI', 'KI-VAT', '1', 'total', 'Box 1 — Total sales and income including VAT (zero-rated and exempt sales included)', '{}'::jsonb, 10, null, array['2', '3', '4']::text[], '{}'::text[], null, null, false, false, null, 'Form RET 020, box 1 — total sales and income including VAT; the instructions of box 1 include the zero-rated and the exempt sales. Here boxes 2, 3 and 4 added.', 'vat-return'),
  ('KI', 'KI-VAT', '2', 'base', 'Box 2 — Zero-rated supplies', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form RET 020, box 2 — the zero-rated sales of the period, included in box 1 (exports and the other zero-rated supplies of the VAT Act).', 'vat-return'),
  ('KI', 'KI-VAT', '3', 'base', 'Box 3 — Exempt supplies', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form RET 020, box 3 — the exempt sales of the period, included in box 1.', 'vat-return'),
  ('KI', 'KI-VAT', '4', 'total', 'Box 4 — Sales subject to VAT, VAT included (box 1 less boxes 2 and 3)', '{}'::jsonb, 40, null, array['4a:base', '5:tax']::text[], '{}'::text[], null, null, false, false, null, 'Form RET 020, box 4 — box 1 less boxes 2 and 3. Here the exclusive base of box 4a plus the VAT of box 5.', 'vat-return'),
  ('KI', 'KI-VAT', '4a', 'base', 'Box 4a — Sales subject to VAT, VAT excluded', '{}'::jsonb, 45, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Not a box of the form: the exclusive value of the sales of box 4, which the engine posts and from which box 4 is rebuilt.', 'return-instructions'),
  ('KI', 'KI-VAT', '5', 'tax', 'Box 5 — VAT collected (box 4 divided by 9)', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form RET 020, box 5 — box 4 divided by 9, the tax fraction of 12.5 % (instructions, box 5).', 'return-instructions'),
  ('KI', 'KI-VAT', '6', 'tax', 'Box 6 — Adjustments to VAT collected', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form RET 020, box 6 — adjustments to the VAT collected, such as corrections of earlier returns (instructions, box 6; the Tax Division''s approval or a written explanation is needed). Declared and empty: an adjustment is a decision of the preparer, no tax code posts to it.', 'return-instructions'),
  ('KI', 'KI-VAT', '7', 'total', 'Box 7 — Total VAT collected (boxes 5 + 6)', '{}'::jsonb, 70, null, array['5', '6']::text[], '{}'::text[], null, null, false, false, null, 'Form RET 020, box 7 — boxes 5 and 6 added.', 'vat-return'),
  ('KI', 'KI-VAT', '8', 'total', 'Box 8 — Total purchases and expenses including VAT', '{}'::jsonb, 80, null, array['9', '10']::text[], '{}'::text[], null, null, false, false, null, 'Form RET 020, box 8 — the purchases and expenses of the period that carry VAT, imported goods and the VAT paid to Customs left out (they are claimed in box 12). Here boxes 9 and 10 added.', 'vat-return'),
  ('KI', 'KI-VAT', '9', 'base', 'Box 9 — Non-creditable acquisitions', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form RET 020, box 9 — purchases on which no VAT was charged, or whose VAT is not claimed, and salaries and wages (instructions, box 9). The engine posts the exclusive value; the form asks for the amount actually paid.', 'return-instructions'),
  ('KI', 'KI-VAT', '10', 'total', 'Box 10 — Purchases subject to claimable VAT, VAT included (box 8 less box 9)', '{}'::jsonb, 100, null, array['10a:base', '11:tax']::text[], '{}'::text[], null, null, false, false, null, 'Form RET 020, box 10 — box 8 less box 9. Here the exclusive base of box 10a plus the VAT of box 11.', 'vat-return'),
  ('KI', 'KI-VAT', '10a', 'base', 'Box 10a — Purchases subject to claimable VAT, VAT excluded', '{}'::jsonb, 105, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Not a box of the form: the exclusive value of the purchases of box 10, which the engine posts and from which box 10 is rebuilt.', 'return-instructions'),
  ('KI', 'KI-VAT', '11', 'tax', 'Box 11 — VAT paid on purchases (box 10 divided by 9)', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form RET 020, box 11 — box 10 divided by 9, the tax fraction of 12.5 % (instructions, box 11).', 'return-instructions'),
  ('KI', 'KI-VAT', '12', 'base', 'Box 12 — Imports, customs value (basis of box 12)', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The imported goods whose VAT is claimed in box 12; the form asks for the VAT only.', 'return-instructions'),
  ('KI', 'KI-VAT', '12', 'tax', 'Box 12 — VAT on imports paid to Customs', '{}'::jsonb, 125, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form RET 020, box 12 — the VAT paid to Customs on imported goods (instructions, boxes 8 and 12).', 'return-instructions'),
  ('KI', 'KI-VAT', '13', 'tax', 'Box 13 — Government withheld VAT', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form RET 020, box 13 — the VAT the Government withheld on its payments for goods or services supplied to it in the period, which the supplier invoices but is not paid; it may be claimed here before the Government pays it (instructions, box 13). Declared and empty: the withholding is not modelled (see the README).', 'return-instructions'),
  ('KI', 'KI-VAT', '14', 'tax', 'Box 14 — Adjustments to VAT paid (credits of earlier returns, one-off import duty credit)', '{}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form RET 020, box 14 — credits seen in earlier returns, and the one-off credit on the duty paid on goods held at the start of the VAT; claims need the approval of the Tax Division or documentary evidence (instructions, box 14). Declared and empty: a decision of the preparer.', 'return-instructions'),
  ('KI', 'KI-VAT', '15', 'total', 'Box 15 — Total VAT paid (boxes 11 + 12 + 13 + 14)', '{}'::jsonb, 150, null, array['11', '12:tax', '13', '14']::text[], '{}'::text[], null, null, false, false, null, 'Form RET 020, box 15 — boxes 11, 12, 13 and 14 added.', 'vat-return'),
  ('KI', 'KI-VAT', '16', 'total', 'Box 16 — VAT to pay (positive) or VAT credit (negative) (box 7 less box 15)', '{}'::jsonb, 160, null, array['7']::text[], array['15']::text[], null, null, false, false, null, 'Form RET 020, box 16 — the difference between box 7 and box 15: box 7 larger is the VAT to pay, box 15 larger is a VAT credit, which may be refunded (instructions, box 16).', 'vat-return')
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
  ('KI-IFRS-IS', 'KI', 'default', 'Statement of profit or loss', 'income_statement', 'IFRS', date '2024-01-01', null, 'IAS 1 asks for a statement of financial position and a statement of profit or loss; expenses are analysed by nature, which these lines follow. No Kiribati text prescribing a layout of the statements was found, so the statement is presented as IFRS-style on the pack''s own chart.', 'ias-1', null, null, '{}'::jsonb),
  ('KI-IFRS-SFP', 'KI', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS', date '2024-01-01', null, 'IAS 1 asks for a statement of financial position and a statement of profit or loss; expenses are analysed by nature, which these lines follow. No Kiribati text prescribing a layout of the statements was found, so the statement is presented as IFRS-style on the pack''s own chart.', 'ias-1', 'combined', 'Result of the current financial year', '{}'::jsonb)
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
  ('KI-IFRS-IS', '1', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-IS', '2', null, 'Other income', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-IS', '3', null, 'Purchases and changes in inventories', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-IS', '4', null, 'Employee benefits expense', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-IS', '5', null, 'Depreciation and amortisation', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-IS', '6', null, 'Other operating expenses', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-IS', '7', null, 'Finance costs', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-IS', '8', null, 'Profit before tax', '{}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('KI-IFRS-IS', '9', null, 'Income tax expense', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-IS', '10', null, 'Profit for the year', '{}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, null, null),
  ('KI-IFRS-SFP', 'CA', null, 'Current assets', '{}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5', 'CA.6']::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'CA.1', null, 'Cash and cash equivalents', '{}'::jsonb, 11, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'CA.2', null, 'Trade and other receivables', '{}'::jsonb, 12, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'CA.3', null, 'Inventories', '{}'::jsonb, 13, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'CA.4', null, 'Financial assets', '{}'::jsonb, 14, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'CA.5', null, 'Current tax recoverable', '{}'::jsonb, 15, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'CA.6', null, 'Prepayments and accrued income', '{}'::jsonb, 16, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'NCA', null, 'Non-current assets', '{}'::jsonb, 20, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4', 'NCA.5', 'NCA.6', 'NCA.7']::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'NCA.1', null, 'Property, plant and equipment', '{}'::jsonb, 21, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'NCA.2', null, 'Investment property', '{}'::jsonb, 22, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'NCA.3', null, 'Intangible assets', '{}'::jsonb, 23, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'NCA.4', null, 'Investments in associates', '{}'::jsonb, 24, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'NCA.5', null, 'Investments in joint ventures', '{}'::jsonb, 25, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'NCA.6', null, 'Financial assets', '{}'::jsonb, 26, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'NCA.7', null, 'Deferred tax assets', '{}'::jsonb, 27, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'TA', null, 'Total assets', '{}'::jsonb, 30, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'CL', null, 'Current liabilities', '{}'::jsonb, 40, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4', 'CL.5']::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'CL.1', null, 'Trade and other payables', '{}'::jsonb, 41, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'CL.2', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 42, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'CL.3', null, 'Amounts due to directors', '{}'::jsonb, 43, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'CL.4', null, 'Current tax payable', '{}'::jsonb, 44, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'CL.5', null, 'Provisions', '{}'::jsonb, 45, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'NCL', null, 'Non-current liabilities', '{}'::jsonb, 50, 1, true, array['NCL.1', 'NCL.2', 'NCL.3']::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'NCL.1', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 51, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'NCL.2', null, 'Deferred tax liabilities', '{}'::jsonb, 52, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'NCL.3', null, 'Provisions', '{}'::jsonb, 53, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'TL', null, 'Total liabilities', '{}'::jsonb, 60, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'NA', null, 'Net assets', '{}'::jsonb, 70, 1, true, array['TA']::text[], array['TL']::text[], null, null, null),
  ('KI-IFRS-SFP', 'EQ', null, 'Equity', '{}'::jsonb, 80, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'EQ.1', null, 'Share capital', '{}'::jsonb, 81, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'EQ.2', null, 'Other reserves', '{}'::jsonb, 82, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KI-IFRS-SFP', 'EQ.3', null, 'Retained earnings', '{}'::jsonb, 83, -1, false, '{}'::text[], '{}'::text[], null, null, null)
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
 where r.statement_code in ('KI-IFRS-IS', 'KI-IFRS-SFP')
   and (r.statement_code, r.line_code, r.sequence) not in (
     values ('KI-IFRS-IS', '1', 10),
            ('KI-IFRS-IS', '2', 10),
            ('KI-IFRS-IS', '3', 10),
            ('KI-IFRS-IS', '4', 10),
            ('KI-IFRS-IS', '5', 10),
            ('KI-IFRS-IS', '6', 10),
            ('KI-IFRS-IS', '7', 10),
            ('KI-IFRS-IS', '9', 10),
            ('KI-IFRS-SFP', 'CA.1', 10),
            ('KI-IFRS-SFP', 'CA.2', 10),
            ('KI-IFRS-SFP', 'CA.3', 10),
            ('KI-IFRS-SFP', 'CA.4', 10),
            ('KI-IFRS-SFP', 'CA.5', 10),
            ('KI-IFRS-SFP', 'CA.6', 10),
            ('KI-IFRS-SFP', 'NCA.1', 10),
            ('KI-IFRS-SFP', 'NCA.2', 10),
            ('KI-IFRS-SFP', 'NCA.3', 10),
            ('KI-IFRS-SFP', 'NCA.4', 10),
            ('KI-IFRS-SFP', 'NCA.5', 10),
            ('KI-IFRS-SFP', 'NCA.6', 10),
            ('KI-IFRS-SFP', 'NCA.7', 10),
            ('KI-IFRS-SFP', 'CL.1', 10),
            ('KI-IFRS-SFP', 'CL.1', 20),
            ('KI-IFRS-SFP', 'CL.2', 10),
            ('KI-IFRS-SFP', 'CL.3', 10),
            ('KI-IFRS-SFP', 'CL.4', 10),
            ('KI-IFRS-SFP', 'CL.5', 10),
            ('KI-IFRS-SFP', 'NCL.1', 10),
            ('KI-IFRS-SFP', 'NCL.2', 10),
            ('KI-IFRS-SFP', 'NCL.3', 10),
            ('KI-IFRS-SFP', 'EQ.1', 10),
            ('KI-IFRS-SFP', 'EQ.2', 10),
            ('KI-IFRS-SFP', 'EQ.3', 10)
   );

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('KI-IFRS-IS', '1', 10, 'code_range', '4000', '4030', null, 'any'),
    ('KI-IFRS-IS', '2', 10, 'code_range', '4500', '4790', null, 'any'),
    ('KI-IFRS-IS', '3', 10, 'code_range', '5000', '5100', null, 'any'),
    ('KI-IFRS-IS', '4', 10, 'code_range', '6000', '6080', null, 'any'),
    ('KI-IFRS-IS', '5', 10, 'code_range', '6200', '6220', null, 'any'),
    ('KI-IFRS-IS', '6', 10, 'code_range', '6300', '6990', null, 'any'),
    ('KI-IFRS-IS', '7', 10, 'code_range', '7000', '7030', null, 'any'),
    ('KI-IFRS-IS', '9', 10, 'code_range', '8000', '8020', null, 'any'),
    ('KI-IFRS-SFP', 'CA.1', 10, 'code_range', '1000', '1040', null, 'any'),
    ('KI-IFRS-SFP', 'CA.2', 10, 'code_range', '1100', '1160', null, 'any'),
    ('KI-IFRS-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('KI-IFRS-SFP', 'CA.4', 10, 'account_code', '1300', null, null, 'any'),
    ('KI-IFRS-SFP', 'CA.5', 10, 'account_code', '1350', null, null, 'any'),
    ('KI-IFRS-SFP', 'CA.6', 10, 'code_range', '1400', '1410', null, 'any'),
    ('KI-IFRS-SFP', 'NCA.1', 10, 'code_range', '1600', '1671', null, 'any'),
    ('KI-IFRS-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('KI-IFRS-SFP', 'NCA.3', 10, 'code_range', '1750', '1760', null, 'any'),
    ('KI-IFRS-SFP', 'NCA.4', 10, 'account_code', '1800', null, null, 'any'),
    ('KI-IFRS-SFP', 'NCA.5', 10, 'account_code', '1810', null, null, 'any'),
    ('KI-IFRS-SFP', 'NCA.6', 10, 'code_range', '1830', '1840', null, 'any'),
    ('KI-IFRS-SFP', 'NCA.7', 10, 'account_code', '1900', null, null, 'any'),
    ('KI-IFRS-SFP', 'CL.1', 10, 'code_range', '2000', '2190', null, 'any'),
    ('KI-IFRS-SFP', 'CL.1', 20, 'account_code', '2990', null, null, 'credit'),
    ('KI-IFRS-SFP', 'CL.2', 10, 'code_range', '2200', '2240', null, 'any'),
    ('KI-IFRS-SFP', 'CL.3', 10, 'account_code', '2250', null, null, 'any'),
    ('KI-IFRS-SFP', 'CL.4', 10, 'account_code', '2300', null, null, 'any'),
    ('KI-IFRS-SFP', 'CL.5', 10, 'code_range', '2350', '2360', null, 'any'),
    ('KI-IFRS-SFP', 'NCL.1', 10, 'code_range', '2400', '2430', null, 'any'),
    ('KI-IFRS-SFP', 'NCL.2', 10, 'account_code', '2500', null, null, 'any'),
    ('KI-IFRS-SFP', 'NCL.3', 10, 'account_code', '2550', null, null, 'any'),
    ('KI-IFRS-SFP', 'EQ.1', 10, 'code_range', '3000', '3010', null, 'any'),
    ('KI-IFRS-SFP', 'EQ.2', 10, 'code_range', '3100', '3110', null, 'any'),
    ('KI-IFRS-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('KI', 'Kiribati', '{}'::jsonb, array['en']::text[], 'AUD', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, 'quarter'::declaration_period)
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
  numbering_legal_reference     = 'The tax invoice must carry the words TAX INVOICE, a date and an individualised serial number, the name, address and TIN of supplier and recipient, a description of the goods or services, and the price and VAT charged (VAT Regulations 2014, s 9, as summarised in the Taxpayer''s Obligation pamphlet). `sequential` and the number format are conventions of this pack and not rules of the law.',
  numbering_source_key          = 'obligations',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_date',
  tax_point_legal_reference     = 'No text read states when the VAT becomes due on a supply (the VAT Act 2013 itself could not be opened). `invoice_date` is the pack''s simplification and not a finding of the law; the point of the tax is a gap recorded in the README.',
  tax_point_source_key          = 'guidelines',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No structured e-invoice standard, Peppol profile or clearance system of the Tax Division was found in the texts read; returns are filed at the tax office on the paper or spreadsheet form. `obligation` is `none` for want of a text, not on a finding that none exists.',
  einvoice_source_key           = 'tax-portal',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'KI';

update country_defaults set
  tax_payee_name       = 'Kiribati Tax Division, Ministry of Finance and Economic Development',
  tax_payee_source_key = 'tax-portal'
 where country = 'KI';
