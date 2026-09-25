-- Ekwo OS — Philippines: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/ph at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build ph`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Republic Act No. 11976 — Ease of Paying Taxes Act, amending Sections 106, 108, 109, 110, 113, 114, 236, 237 and 238 of the National Internal Revenue Code of 1997, among others (Supreme Court of the Philippines — E-Library)
--     https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/96948
--   Republic Act No. 10963 — Tax Reform for Acceleration and Inclusion (TRAIN) Act, amending Sections 106, 107, 108 and 109 of the National Internal Revenue Code of 1997, among others — the zero-rated sales and exempt-transactions lists this pack reads (Supreme Court of the Philippines — E-Library)
--     https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/80559
--   Republic Act No. 12066 — CREATE MORE Act, amending Sections 106, 108, 109 and 237-A of the National Internal Revenue Code of 1997, among others (VAT zero-rating of export-oriented registered enterprises) (Supreme Court of the Philippines — E-Library)
--     https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/98085
--   BIR Form No. 2550Q, April 2024 (ENCS) — Quarterly Value-Added Tax Return (Bureau of Internal Revenue)
--     https://bir-cdn.bir.gov.ph/BIR/pdf/2550Q%20%20April%202024%20ENCS_Final.pdf
--   Guidelines and Instructions for BIR Form No. 2550Q, April 2024 (ENCS) (Bureau of Internal Revenue)
--     https://bir-cdn.bir.gov.ph/BIR/pdf/2550Q%20guidelines%20April%202024_final.pdf
--   Revenue Regulations No. 8-2022 — policies and guidelines for the use of the Electronic Invoicing/Receipting System (EIS) under Sections 237 and 237-A of the Tax Code, as amended by the TRAIN Law (Bureau of Internal Revenue)
--     https://bir-cdn.bir.gov.ph/local/pdf/RR%208-2022.pdf
--   Guidelines and Instructions for BIR Form No. 1600-VT (January 2018) — Monthly Remittance Return of Value-Added Tax Withheld, filed by a private withholding agent making payments to a non-resident subject to VAT (Bureau of Internal Revenue)
--     https://bir-cdn.bir.gov.ph/local/pdf/BIR%20Form%20No.%201600-VT%202018%20Guidelines.pdf
--   Electronic Filing and Payment System (eFPS) — where BIR Form 2550Q is filed and paid electronically (Bureau of Internal Revenue)
--     https://efps.bir.gov.ph
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('PH', 'Philippines', '0.1.0', date '2026-09-25', '20260923110000', 'community', null, null, '4734063df9cea59fca58c2ef24b93cb78e16cb96ce2526c9693c24e1dc327fe9', '[{"key":"ra-11976","title":"Republic Act No. 11976 — Ease of Paying Taxes Act, amending Sections 106, 108, 109, 110, 113, 114, 236, 237 and 238 of the National Internal Revenue Code of 1997, among others","publisher":"Supreme Court of the Philippines — E-Library","url":"https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/96948","consulted_on":"2026-09-25","kind":"law"},{"key":"ra-10963","title":"Republic Act No. 10963 — Tax Reform for Acceleration and Inclusion (TRAIN) Act, amending Sections 106, 107, 108 and 109 of the National Internal Revenue Code of 1997, among others — the zero-rated sales and exempt-transactions lists this pack reads","publisher":"Supreme Court of the Philippines — E-Library","url":"https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/80559","consulted_on":"2026-09-25","kind":"law"},{"key":"ra-12066","title":"Republic Act No. 12066 — CREATE MORE Act, amending Sections 106, 108, 109 and 237-A of the National Internal Revenue Code of 1997, among others (VAT zero-rating of export-oriented registered enterprises)","publisher":"Supreme Court of the Philippines — E-Library","url":"https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/98085","consulted_on":"2026-09-25","kind":"law"},{"key":"bir-2550q-form","title":"BIR Form No. 2550Q, April 2024 (ENCS) — Quarterly Value-Added Tax Return","publisher":"Bureau of Internal Revenue","url":"https://bir-cdn.bir.gov.ph/BIR/pdf/2550Q%20%20April%202024%20ENCS_Final.pdf","consulted_on":"2026-09-25","kind":"form"},{"key":"bir-2550q-guidelines","title":"Guidelines and Instructions for BIR Form No. 2550Q, April 2024 (ENCS)","publisher":"Bureau of Internal Revenue","url":"https://bir-cdn.bir.gov.ph/BIR/pdf/2550Q%20guidelines%20April%202024_final.pdf","consulted_on":"2026-09-25","kind":"form"},{"key":"rr-8-2022","title":"Revenue Regulations No. 8-2022 — policies and guidelines for the use of the Electronic Invoicing/Receipting System (EIS) under Sections 237 and 237-A of the Tax Code, as amended by the TRAIN Law","publisher":"Bureau of Internal Revenue","url":"https://bir-cdn.bir.gov.ph/local/pdf/RR%208-2022.pdf","consulted_on":"2026-09-25","kind":"regulation"},{"key":"bir-1600vt-guidelines","title":"Guidelines and Instructions for BIR Form No. 1600-VT (January 2018) — Monthly Remittance Return of Value-Added Tax Withheld, filed by a private withholding agent making payments to a non-resident subject to VAT","publisher":"Bureau of Internal Revenue","url":"https://bir-cdn.bir.gov.ph/local/pdf/BIR%20Form%20No.%201600-VT%202018%20Guidelines.pdf","consulted_on":"2026-09-25","kind":"form"},{"key":"bir-efps","title":"Electronic Filing and Payment System (eFPS) — where BIR Form 2550Q is filed and paid electronically","publisher":"Bureau of Internal Revenue","url":"https://efps.bir.gov.ph","consulted_on":"2026-09-25","kind":"portal"}]'::jsonb)
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
  ('PH', 'default', 'Ekwo reference chart of accounts for the Philippines', '{}'::jsonb, true, 'companies', array['PH-BS', 'PH-IS']::text[], null, 'The Philippines prescribes no chart of accounts. What this session could verify is that the Financial and Sustainability Reporting Standards Council (FSRSC), under the authority of the Board of Accountancy (Republic Act No. 9298, the Philippine Accountancy Act of 2004), adopts the Philippine Financial Reporting Standards, the Philippine Financial Reporting Standard for Small and Medium-sized Entities and the Philippine Financial Reporting Standard for Small Entities, and that the Securities and Exchange Commission requires financial statements filed with it to follow one of those frameworks (Revised Securities Regulation Code Rule 68) — none of which prescribes a numbered account code. This chart is therefore original, not transcribed: four digits by class in the numbering the sibling Southeast Asian packs (Thailand, Vietnam, Singapore) use — 1 assets, 2 liabilities, 3 equity, 4 revenue, 5 cost of sales, 6 operating expenses, 7 finance items, 8 income tax — with the accounts a VAT-registered Philippine company''s books hold: output and input value-added tax, the VAT payable or refundable account a filed return settles to, VAT withheld on services from a non-resident pending remittance, and the SSS, PhilHealth and Pag-IBIG contributions and 13th-month pay every Philippine payroll carries. Its statements, `PH-BS` and `PH-IS` in `statements.json`, are original: lines grouped by the code ranges this chart''s own numbering gives its accounts, current and non-current, without transcribing a PFRS taxonomy''s own line items or their numbering.', null)
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
  ('PH', 'default', '1000', 'Cash on hand', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('PH', 'default', '1010', 'Cash in bank - current account', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('PH', 'default', '1020', 'Cash in bank - savings account', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('PH', 'default', '1030', 'Cash in bank - foreign currency (US dollar)', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('PH', 'default', '1090', 'Cash in transit / undeposited collections', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('PH', 'default', '1100', 'Trade receivables', '{}'::jsonb, 'asset_receivable', true, null, 60),
  ('PH', 'default', '1105', 'Notes receivable', '{}'::jsonb, 'asset_receivable', true, null, 70),
  ('PH', 'default', '1110', 'Receivables from related parties', '{}'::jsonb, 'asset_receivable', true, null, 80),
  ('PH', 'default', '1120', 'Unbilled receivables', '{}'::jsonb, 'asset_current', false, null, 90),
  ('PH', 'default', '1121', 'Advances to suppliers', '{}'::jsonb, 'asset_current', false, null, 100),
  ('PH', 'default', '1125', 'Accrued interest receivable', '{}'::jsonb, 'asset_current', false, null, 110),
  ('PH', 'default', '1130', 'Advances to employees', '{}'::jsonb, 'asset_current', false, null, 120),
  ('PH', 'default', '1140', 'Allowance for doubtful accounts', '{}'::jsonb, 'asset_current', false, null, 130),
  ('PH', 'default', '1150', 'Input value-added tax', '{}'::jsonb, 'asset_current', false, null, 140),
  ('PH', 'default', '1155', 'Value-added tax refundable / tax credit certificate receivable', '{}'::jsonb, 'asset_current', true, null, 150),
  ('PH', 'default', '1160', 'Creditable withholding tax (income tax)', '{}'::jsonb, 'asset_current', false, null, 160),
  ('PH', 'default', '1170', 'Other receivables', '{}'::jsonb, 'asset_current', false, null, 170),
  ('PH', 'default', '1200', 'Merchandise inventory', '{}'::jsonb, 'asset_current', false, null, 180),
  ('PH', 'default', '1210', 'Raw materials and supplies inventory', '{}'::jsonb, 'asset_current', false, null, 190),
  ('PH', 'default', '1220', 'Work in process', '{}'::jsonb, 'asset_current', false, null, 200),
  ('PH', 'default', '1230', 'Goods in transit', '{}'::jsonb, 'asset_current', false, null, 210),
  ('PH', 'default', '1300', 'Prepaid expenses', '{}'::jsonb, 'asset_prepayments', false, null, 220),
  ('PH', 'default', '1310', 'Deposits (rental and utility)', '{}'::jsonb, 'asset_prepayments', false, null, 230),
  ('PH', 'default', '1320', 'Prepaid insurance', '{}'::jsonb, 'asset_prepayments', false, null, 240),
  ('PH', 'default', '1330', 'Creditable withholding tax carried forward', '{}'::jsonb, 'asset_prepayments', false, null, 250),
  ('PH', 'default', '1600', 'Land', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('PH', 'default', '1610', 'Buildings and improvements', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('PH', 'default', '1611', 'Accumulated depreciation - buildings and improvements', '{}'::jsonb, 'asset_fixed', false, '1610', 280),
  ('PH', 'default', '1620', 'Office furniture, fixtures and equipment', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('PH', 'default', '1621', 'Accumulated depreciation - office furniture, fixtures and equipment', '{}'::jsonb, 'asset_fixed', false, '1620', 300),
  ('PH', 'default', '1630', 'Transportation equipment', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('PH', 'default', '1631', 'Accumulated depreciation - transportation equipment', '{}'::jsonb, 'asset_fixed', false, '1630', 320),
  ('PH', 'default', '1640', 'Computer equipment', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('PH', 'default', '1641', 'Accumulated depreciation - computer equipment', '{}'::jsonb, 'asset_fixed', false, '1640', 340),
  ('PH', 'default', '1650', 'Leasehold improvements', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('PH', 'default', '1651', 'Accumulated depreciation - leasehold improvements', '{}'::jsonb, 'asset_fixed', false, '1650', 360),
  ('PH', 'default', '1660', 'Machinery and production equipment', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('PH', 'default', '1661', 'Accumulated depreciation - machinery and production equipment', '{}'::jsonb, 'asset_fixed', false, '1660', 380),
  ('PH', 'default', '1700', 'Intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 390),
  ('PH', 'default', '1710', 'Long-term deposits', '{}'::jsonb, 'asset_non_current', false, null, 400),
  ('PH', 'default', '1720', 'Computer software and licenses', '{}'::jsonb, 'asset_non_current', false, null, 410),
  ('PH', 'default', '1730', 'Goodwill', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('PH', 'default', '1740', 'Long-term investments', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('PH', 'default', '1750', 'Deferred tax asset', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('PH', 'default', '2000', 'Trade payables', '{}'::jsonb, 'liability_payable', true, null, 450),
  ('PH', 'default', '2005', 'Notes payable', '{}'::jsonb, 'liability_payable', true, null, 460),
  ('PH', 'default', '2020', 'Accrued salaries and wages', '{}'::jsonb, 'liability_current', false, null, 470),
  ('PH', 'default', '2030', 'Accrued 13th month pay', '{}'::jsonb, 'liability_current', false, null, 480),
  ('PH', 'default', '2040', 'Customer deposits / advances from customers', '{}'::jsonb, 'liability_current', false, null, 490),
  ('PH', 'default', '2050', 'Other payables', '{}'::jsonb, 'liability_current', false, null, 500),
  ('PH', 'default', '2060', 'Unearned revenue', '{}'::jsonb, 'liability_current', false, null, 510),
  ('PH', 'default', '2070', 'Current portion of long-term debt', '{}'::jsonb, 'liability_current', false, null, 520),
  ('PH', 'default', '2080', 'Provision for warranty', '{}'::jsonb, 'liability_current', false, null, 530),
  ('PH', 'default', '2100', 'Output value-added tax', '{}'::jsonb, 'liability_current', false, null, 540),
  ('PH', 'default', '2110', 'Value-added tax payable', '{}'::jsonb, 'liability_current', true, null, 550),
  ('PH', 'default', '2115', 'Value-added tax withheld on services from non-residents payable', '{}'::jsonb, 'liability_current', false, null, 560),
  ('PH', 'default', '2120', 'Import duties and taxes payable', '{}'::jsonb, 'liability_current', false, null, 570),
  ('PH', 'default', '2130', 'SSS, PhilHealth and Pag-IBIG contributions payable', '{}'::jsonb, 'liability_current', false, null, 580),
  ('PH', 'default', '2140', 'Expanded withholding tax payable', '{}'::jsonb, 'liability_current', false, null, 590),
  ('PH', 'default', '2141', 'Withholding tax on compensation payable', '{}'::jsonb, 'liability_current', false, null, 600),
  ('PH', 'default', '2150', 'Percentage tax payable', '{}'::jsonb, 'liability_current', false, null, 610),
  ('PH', 'default', '2160', 'Income tax payable', '{}'::jsonb, 'liability_current', false, null, 620),
  ('PH', 'default', '2200', 'Short-term loans payable', '{}'::jsonb, 'liability_current', false, null, 630),
  ('PH', 'default', '2210', 'Other accrued expenses', '{}'::jsonb, 'liability_current', false, null, 640),
  ('PH', 'default', '2220', 'Advances from officers', '{}'::jsonb, 'liability_current', false, null, 650),
  ('PH', 'default', '2230', 'Dividends payable', '{}'::jsonb, 'liability_current', false, null, 660),
  ('PH', 'default', '2500', 'Long-term loans payable', '{}'::jsonb, 'liability_non_current', false, null, 690),
  ('PH', 'default', '2510', 'Bonds payable', '{}'::jsonb, 'liability_non_current', false, null, 700),
  ('PH', 'default', '2520', 'Finance lease liability - non-current', '{}'::jsonb, 'liability_non_current', false, null, 710),
  ('PH', 'default', '2530', 'Retirement benefit obligation', '{}'::jsonb, 'liability_non_current', false, null, 720),
  ('PH', 'default', '2540', 'Deferred tax liability', '{}'::jsonb, 'liability_non_current', false, null, 730),
  ('PH', 'default', '2900', 'Due to related parties', '{}'::jsonb, 'liability_current', false, null, 670),
  ('PH', 'default', '2990', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 680),
  ('PH', 'default', '3000', 'Share capital', '{}'::jsonb, 'equity', false, null, 740),
  ('PH', 'default', '3050', 'Subscriptions receivable', '{}'::jsonb, 'equity', false, '3000', 750),
  ('PH', 'default', '3100', 'Additional paid-in capital', '{}'::jsonb, 'equity', false, null, 760),
  ('PH', 'default', '3110', 'Appropriated retained earnings / legal reserve', '{}'::jsonb, 'equity', false, null, 770),
  ('PH', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 780),
  ('PH', 'default', '3210', 'Dividends declared', '{}'::jsonb, 'equity_retained', false, null, 790),
  ('PH', 'default', '4000', 'Sales - domestic', '{}'::jsonb, 'income', false, null, 800),
  ('PH', 'default', '4010', 'Service revenue - domestic', '{}'::jsonb, 'income', false, null, 810),
  ('PH', 'default', '4020', 'Sales - export', '{}'::jsonb, 'income', false, null, 820),
  ('PH', 'default', '4030', 'Service revenue - rendered to a non-resident', '{}'::jsonb, 'income', false, null, 830),
  ('PH', 'default', '4040', 'Other service fees', '{}'::jsonb, 'income', false, null, 840),
  ('PH', 'default', '4050', 'Installation and maintenance revenue', '{}'::jsonb, 'income', false, null, 850),
  ('PH', 'default', '4090', 'Sales discounts and allowances', '{}'::jsonb, 'income', false, null, 860),
  ('PH', 'default', '4500', 'Rental income', '{}'::jsonb, 'income', false, null, 870),
  ('PH', 'default', '4700', 'Foreign exchange gain', '{}'::jsonb, 'income_other', false, null, 880),
  ('PH', 'default', '4710', 'Interest income', '{}'::jsonb, 'income_other', false, null, 890),
  ('PH', 'default', '4720', 'Dividend income', '{}'::jsonb, 'income_other', false, null, 900),
  ('PH', 'default', '4750', 'Gain on disposal of fixed assets', '{}'::jsonb, 'income_other', false, null, 910),
  ('PH', 'default', '4900', 'Miscellaneous income', '{}'::jsonb, 'income_other', false, null, 920),
  ('PH', 'default', '5000', 'Cost of goods sold', '{}'::jsonb, 'expense_direct_cost', false, null, 930),
  ('PH', 'default', '5010', 'Freight-in', '{}'::jsonb, 'expense_direct_cost', false, null, 940),
  ('PH', 'default', '5020', 'Direct labor', '{}'::jsonb, 'expense_direct_cost', false, null, 950),
  ('PH', 'default', '5030', 'Manufacturing overhead', '{}'::jsonb, 'expense_direct_cost', false, null, 960),
  ('PH', 'default', '5040', 'Import duties on goods', '{}'::jsonb, 'expense_direct_cost', false, null, 970),
  ('PH', 'default', '5050', 'Inventory write-down', '{}'::jsonb, 'expense_direct_cost', false, null, 980),
  ('PH', 'default', '6000', 'Salaries and wages', '{}'::jsonb, 'expense', false, null, 990),
  ('PH', 'default', '6001', 'Overtime pay', '{}'::jsonb, 'expense', false, null, 1000),
  ('PH', 'default', '6005', '13th month pay', '{}'::jsonb, 'expense', false, null, 1010),
  ('PH', 'default', '6010', 'SSS, PhilHealth and Pag-IBIG contributions - employer share', '{}'::jsonb, 'expense', false, null, 1020),
  ('PH', 'default', '6015', 'Employee training', '{}'::jsonb, 'expense', false, null, 1030),
  ('PH', 'default', '6020', 'Retirement benefit expense', '{}'::jsonb, 'expense', false, null, 1040),
  ('PH', 'default', '6025', 'Uniforms and protective gear', '{}'::jsonb, 'expense', false, null, 1050),
  ('PH', 'default', '6030', 'Recruitment expense', '{}'::jsonb, 'expense', false, null, 1060),
  ('PH', 'default', '6040', 'Employee health insurance (HMO)', '{}'::jsonb, 'expense', false, null, 1070),
  ('PH', 'default', '6050', 'Employee welfare and benefits', '{}'::jsonb, 'expense', false, null, 1080),
  ('PH', 'default', '6100', 'Rent expense', '{}'::jsonb, 'expense', false, null, 1090),
  ('PH', 'default', '6110', 'Utilities - water and electricity', '{}'::jsonb, 'expense', false, null, 1100),
  ('PH', 'default', '6120', 'Telephone and internet', '{}'::jsonb, 'expense', false, null, 1110),
  ('PH', 'default', '6130', 'Transportation and travel', '{}'::jsonb, 'expense', false, null, 1120),
  ('PH', 'default', '6140', 'Fuel and vehicle maintenance', '{}'::jsonb, 'expense', false, null, 1130),
  ('PH', 'default', '6150', 'Parking and toll fees', '{}'::jsonb, 'expense', false, null, 1140),
  ('PH', 'default', '6160', 'Postage and courier', '{}'::jsonb, 'expense', false, null, 1150),
  ('PH', 'default', '6170', 'Office supplies', '{}'::jsonb, 'expense', false, null, 1160),
  ('PH', 'default', '6180', 'Membership dues and subscriptions', '{}'::jsonb, 'expense', false, null, 1170),
  ('PH', 'default', '6190', 'Software subscriptions - domestic', '{}'::jsonb, 'expense', false, null, 1180),
  ('PH', 'default', '6200', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1190),
  ('PH', 'default', '6210', 'Professional and consultancy fees - domestic', '{}'::jsonb, 'expense', false, null, 1200),
  ('PH', 'default', '6220', 'Advertising and promotion', '{}'::jsonb, 'expense', false, null, 1210),
  ('PH', 'default', '6230', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 1220),
  ('PH', 'default', '6240', 'Representation and entertainment', '{}'::jsonb, 'expense', false, null, 1230),
  ('PH', 'default', '6250', 'Printing and stationery', '{}'::jsonb, 'expense', false, null, 1240),
  ('PH', 'default', '6260', 'Legal fees - domestic', '{}'::jsonb, 'expense', false, null, 1250),
  ('PH', 'default', '6270', 'Audit and accounting fees', '{}'::jsonb, 'expense', false, null, 1260),
  ('PH', 'default', '6280', 'Translation and documentation fees', '{}'::jsonb, 'expense', false, null, 1270),
  ('PH', 'default', '6290', 'Import/export documentation fees', '{}'::jsonb, 'expense', false, null, 1280),
  ('PH', 'default', '6300', 'Insurance expense', '{}'::jsonb, 'expense', false, null, 1290),
  ('PH', 'default', '6310', 'Real property tax', '{}'::jsonb, 'expense', false, null, 1300),
  ('PH', 'default', '6320', 'Local business tax and permits', '{}'::jsonb, 'expense', false, null, 1310),
  ('PH', 'default', '6330', 'Vehicle registration fees', '{}'::jsonb, 'expense', false, null, 1320),
  ('PH', 'default', '6340', 'Donations and charitable contributions', '{}'::jsonb, 'expense', false, null, 1330),
  ('PH', 'default', '6350', 'Software and digital services from a non-resident', '{}'::jsonb, 'expense', false, null, 1340),
  ('PH', 'default', '6360', 'Professional fees - individual not VAT-registered', '{}'::jsonb, 'expense', false, null, 1350),
  ('PH', 'default', '6370', 'International remittance fees', '{}'::jsonb, 'expense', false, null, 1360),
  ('PH', 'default', '6380', 'Foreign exchange loss on transactions', '{}'::jsonb, 'expense', false, null, 1370),
  ('PH', 'default', '6390', 'Credit card processing fees', '{}'::jsonb, 'expense', false, null, 1380),
  ('PH', 'default', '6400', 'Directors'' fees', '{}'::jsonb, 'expense', false, null, 1390),
  ('PH', 'default', '6410', 'Bad debts written off', '{}'::jsonb, 'expense', false, null, 1400),
  ('PH', 'default', '6420', 'Inventory shrinkage loss', '{}'::jsonb, 'expense', false, null, 1410),
  ('PH', 'default', '6430', 'Loss from calamity', '{}'::jsonb, 'expense', false, null, 1420),
  ('PH', 'default', '6440', 'Surcharges, interest and compromise penalties on tax', '{}'::jsonb, 'expense', false, null, 1430),
  ('PH', 'default', '6450', 'Miscellaneous expense', '{}'::jsonb, 'expense', false, null, 1440),
  ('PH', 'default', '6900', 'Provision for doubtful accounts', '{}'::jsonb, 'expense', false, null, 1450),
  ('PH', 'default', '6950', 'Foreign exchange loss', '{}'::jsonb, 'expense', false, null, 1460),
  ('PH', 'default', '6960', 'Loss on disposal of fixed assets', '{}'::jsonb, 'expense', false, null, 1470),
  ('PH', 'default', '6970', 'Depreciation expense', '{}'::jsonb, 'expense_depreciation', false, null, 1480),
  ('PH', 'default', '6975', 'Amortization of intangible assets', '{}'::jsonb, 'expense_depreciation', false, null, 1490),
  ('PH', 'default', '6990', 'Rounding difference', '{}'::jsonb, 'expense', false, null, 1500),
  ('PH', 'default', '7000', 'Interest expense', '{}'::jsonb, 'expense', false, null, 1510),
  ('PH', 'default', '7010', 'Interest expense on finance lease', '{}'::jsonb, 'expense', false, null, 1520),
  ('PH', 'default', '7020', 'Loan facility fees', '{}'::jsonb, 'expense', false, null, 1530),
  ('PH', 'default', '7030', 'Loss on early loan repayment', '{}'::jsonb, 'expense', false, null, 1540),
  ('PH', 'default', '8000', 'Income tax expense - current', '{}'::jsonb, 'expense', false, null, 1550),
  ('PH', 'default', '8010', 'Income tax expense - deferred', '{}'::jsonb, 'expense', false, null, 1560)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('PH', 'BNK', 'Bank journal', '{}'::jsonb, 'bank', 30),
  ('PH', 'CSH', 'Petty cash journal', '{}'::jsonb, 'cash', 40),
  ('PH', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('PH', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('PH', 'PUR', 'Purchase journal', '{}'::jsonb, 'purchase', 20),
  ('PH', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('PH', 'PH-P-EX', 'Purchase — exempt, lease of a residential unit at or below the threshold rental', '{}'::jsonb, 'Lease of a residential unit with a monthly rental not exceeding the statutory threshold, bought from an individual lessor.', 'percent', 0, 'purchase', 'exempt', date '2018-01-01', null, 'National Internal Revenue Code of 1997, Section 109(Q), as for PH-S-EX: what is leased carries no value-added tax, so there is no input tax and no box.', null, null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ra-10963', null, null, null, null),
  ('PH', 'PH-P-RC', 'Purchase — service from a non-resident, value-added tax withheld and remitted', '{}'::jsonb, 'A service performed for the company by a person not established in the Philippines, used in the Philippines: the company withholds and remits the value-added tax itself rather than the supplier charging it.', 'percent', 12, 'purchase', 'foreign_services_received', date '2018-01-01', null, 'National Internal Revenue Code of 1997, Section 108(A), which taxes ''the performance of all kinds of services in the Philippines for others'', read together with BIR Form No. 1600-VT and its Guidelines and Instructions (January 2018), read directly this session: ''Private withholding agents making payments to non-residents subject to VAT'' file the Monthly Remittance Return of Value-Added Tax Withheld ''on or before the tenth (10th) day of the month following the month in which the withholding was made''. This session did not read the Revenue Regulations that first imposed this withholding mechanism (secondary sources name Revenue Regulations No. 4-2007''s amendment of the VAT withholding rules, not read here in its primary text) against Section 114(C) of the Code. **The two-return timing is not modelled**: BIR Form 1600-VT is a monthly return this pack does not carry as a `tax_report.json` — it names no box of BIR Form 2550Q — while the corresponding input tax credit is claimed on 2550Q''s own item 45; this code posts the withholding liability and the credit on the same document, which is faster than the separate monthly remittance the law requires, exactly the simplification `packs/th/`''s TH-P-RC names for Thailand''s VAT 36/VAT 30 pair.', null, null, 70, 'vat', true, array['buyer_status']::tax_condition[], null, false, false, null, 'bir-1600vt-guidelines', null, null, null, null),
  ('PH', 'PH-P-STD', 'Purchase — value-added tax at 12%, creditable', '{}'::jsonb, 'A purchase of goods or services in the Philippines from a VAT-registered supplier, whose input tax this pack takes as fully creditable.', 'percent', 12, 'purchase', 'domestic', date '2006-02-01', null, 'National Internal Revenue Code of 1997, Sections 106(A)/108(A) as for PH-S-STD, and Section 110(A), as amended by Republic Act No. 11976 section 19 — an input tax evidenced by a VAT invoice issued under Section 113 is creditable against output tax where the purchase is for sale, for use as materials or supplies, or for use in trade or business. This session did not read a primary text listing purchases whose input tax the law excludes from credit (entertainment expenses not directly connected to the trade, non-depreciable vehicles above a ceiling, by secondary reputation and not by an article read this session); this code assumes every standard-rated purchase is fully creditable, and the gap is named in the pack''s README.', null, null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ra-11976', null, null, null, null),
  ('PH', 'PH-S-EX', 'Sale — exempt, lease of a residential unit at or below the threshold rental', '{}'::jsonb, 'Lease of a residential unit with a monthly rental not exceeding the statutory threshold.', 'percent', 0, 'sale', 'exempt', date '2018-01-01', null, 'National Internal Revenue Code of 1997, Section 109(Q), as amended by Republic Act No. 10963 (TRAIN Law) section 34, read directly this session: exempt transactions include ''lease of a residential unit with a monthly rental not exceeding Fifteen thousand pesos (P15,000)''. This session did not verify whether this threshold is one of the amounts Section 109(CC) and Republic Act No. 11976 subject to triennial adjustment by the Consumer Price Index — the text of (CC) speaks only of its own paragraph''s three-million-peso figure — so P15,000 is carried as the amount the Act itself states, not re-indexed. It carries no report box: nothing read this session shows BIR Form 2550Q asking for the value of an exempt sale on a line of its own the way it asks for zero-rated sales at item 32; box 33 (Exempt Sales) is where this pack reports it instead.', 'E', null, 50, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'ra-10963', null, null, null, null),
  ('PH', 'PH-S-STD', 'Sale — value-added tax at 12%', '{}'::jsonb, 'A sale, barter or exchange of goods, properties or services in the ordinary course of trade or business in the Philippines.', 'percent', 12, 'sale', 'domestic', date '2006-02-01', null, 'National Internal Revenue Code of 1997, Sections 106(A) and 108(A), as amended by Republic Act No. 11976 (Ease of Paying Taxes Act), sections 16 and 17 — ''a value-added tax equivalent to twelve percent (12%) of the gross sales'', read directly this session from the Supreme Court E-Library''s text of the amending Act. The 12% rate itself dates from Republic Act No. 9337, effective 1 February 2006, which this session did not re-verify against its own primary text; Republic Act No. 11976 restates the rate as already 12% and only renames ''gross selling price''/''gross value in money''/''gross receipts'' to ''gross sales''.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ra-11976', null, null, null, null),
  ('PH', 'PH-S-ZR-EXP', 'Sale — export of goods, zero-rated', '{}'::jsonb, 'The sale and actual shipment of goods from the Philippines to a foreign country, paid for in acceptable foreign currency and accounted for under Bangko Sentral ng Pilipinas rules.', 'percent', 0, 'sale', 'export', date '2018-01-01', null, 'National Internal Revenue Code of 1997, Section 106(A)(2)(a)(1), as amended by Republic Act No. 10963 (TRAIN Law) section 31, read directly this session from the Supreme Court E-Library''s text of the amending Act: ''export sales'' at zero percent (0%) includes ''the sale and actual shipment of goods from the Philippines to a foreign country ... and paid for in acceptable foreign currency or its equivalent in goods or services, and accounted for in accordance with the rules and regulations of the Bangko Sentral ng Pilipinas (BSP)''. This subparagraph is not one of the export-sale categories a conditional sunset clause of the same section reduces to 12% once an enhanced VAT-refund system is certified (subparagraphs (3), (4) and (5) only), and this session found nothing suggesting that clause has been triggered for it. Republic Act No. 12066 (CREATE MORE Act) touches Sections 106, 108 and 109 to broaden zero-rating for local purchases of IPA-registered export-oriented enterprises; that regime is separate from this ordinary direct-exporter zero-rating and is out of scope of this pack (see README).', 'G', null, 30, 'vat', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'ra-10963', null, null, null, null),
  ('PH', 'PH-S-ZR-SVC', 'Sale — service rendered to a person doing business outside the Philippines, zero-rated', '{}'::jsonb, 'A service performed in the Philippines for a person engaged in business conducted outside the Philippines, or for a nonresident person not engaged in business who is outside the Philippines when the service is performed, paid for in acceptable foreign currency and accounted for under Bangko Sentral ng Pilipinas rules.', 'percent', 0, 'sale', 'export', date '2018-01-01', null, 'National Internal Revenue Code of 1997, Section 108(B)(2), as amended by Republic Act No. 10963 (TRAIN Law) section 33, read directly this session: zero-rated services include those ''rendered to a person engaged in business conducted outside the Philippines or to a nonresident person not engaged in business who is outside the Philippines when the services are performed, the consideration for which is paid for in acceptable foreign currency and accounted for in accordance with the rules and regulations of the Bangko Sentral ng Pilipinas (BSP)''. Whether the buyer is engaged in business outside the Philippines, and whether the service''s benefit is received there, is a fact of the engagement the ledger does not hold, which is why this code carries `conditions` rather than a rule the core evaluates.', 'G', null, 40, 'vat', true, array['supply_nature', 'buyer_status']::tax_condition[], null, false, false, null, 'ra-10963', null, null, null, null)
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
    ('PH-P-EX', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('PH-P-EX', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('PH-P-RC', 'invoice', 'base', 100, null, '45', array['45']::text[], 100, 'PH-VAT-2550Q', 10),
    ('PH-P-RC', 'invoice', 'tax', -100, '2115', null, null, 100, null, 20),
    ('PH-P-RC', 'invoice', 'tax', 100, '1150', '45', array['45']::text[], 100, 'PH-VAT-2550Q', 30),
    ('PH-P-RC', 'credit_note', 'base', 100, null, '45', array['45']::text[], -100, 'PH-VAT-2550Q', 10),
    ('PH-P-RC', 'credit_note', 'tax', -100, '2115', null, null, -100, null, 20),
    ('PH-P-RC', 'credit_note', 'tax', 100, '1150', '45', array['45']::text[], -100, 'PH-VAT-2550Q', 30),
    ('PH-P-STD', 'invoice', 'base', 100, null, '44', array['44']::text[], 100, 'PH-VAT-2550Q', 10),
    ('PH-P-STD', 'invoice', 'tax', 100, '1150', '44', array['44']::text[], 100, 'PH-VAT-2550Q', 20),
    ('PH-P-STD', 'credit_note', 'base', 100, null, '44', array['44']::text[], -100, 'PH-VAT-2550Q', 10),
    ('PH-P-STD', 'credit_note', 'tax', 100, '1150', '44', array['44']::text[], -100, 'PH-VAT-2550Q', 20),
    ('PH-S-EX', 'invoice', 'base', 100, null, '33', array['33']::text[], 100, 'PH-VAT-2550Q', 10),
    ('PH-S-EX', 'credit_note', 'base', 100, null, '33', array['33']::text[], -100, 'PH-VAT-2550Q', 10),
    ('PH-S-STD', 'invoice', 'base', 100, null, '31', array['31']::text[], 100, 'PH-VAT-2550Q', 10),
    ('PH-S-STD', 'invoice', 'tax', 100, '2100', '31', array['31']::text[], 100, 'PH-VAT-2550Q', 20),
    ('PH-S-STD', 'credit_note', 'base', 100, null, '31', array['31']::text[], -100, 'PH-VAT-2550Q', 10),
    ('PH-S-STD', 'credit_note', 'tax', 100, '2100', '31', array['31']::text[], -100, 'PH-VAT-2550Q', 20),
    ('PH-S-ZR-EXP', 'invoice', 'base', 100, null, '32', array['32']::text[], 100, 'PH-VAT-2550Q', 10),
    ('PH-S-ZR-EXP', 'credit_note', 'base', 100, null, '32', array['32']::text[], -100, 'PH-VAT-2550Q', 10),
    ('PH-S-ZR-SVC', 'invoice', 'base', 100, null, '32', array['32']::text[], 100, 'PH-VAT-2550Q', 10),
    ('PH-S-ZR-SVC', 'credit_note', 'base', 100, null, '32', array['32']::text[], -100, 'PH-VAT-2550Q', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'PH' and t.code = v.tax_code
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
  ('PH', 'PH-VAT-2550Q', 'BIR Form No. 2550Q — Quarterly Value-Added Tax Return', array['quarter']::declaration_period[], 'quarter'::declaration_period, date '2023-01-01', null, 'National Internal Revenue Code of 1997, Section 114(A), as amended by Republic Act No. 11976 (Ease of Paying Taxes Act) section 22, read directly this session: ''Every person liable to pay the value-added tax ... shall file ... a quarterly return of the amount of his gross sales within twenty-five (25) days following the close of each taxable quarter ... Provided, finally, That beginning January 1, 2023, the filing and payment required under this Subsection shall be done within twenty-five (25) days following the close of each taxable quarter.'' The same subsection carries an earlier proviso requiring VAT-registered persons to pay on a monthly basis; the January-2023 proviso quoted above is read as superseding it for filing and payment alike, which matches Revenue Memorandum Circular No. 5-2023''s own instruction (read only through a secondary summary this session, not the Circular''s primary text) that BIR Form No. 2550M (Monthly Value-Added Tax Declaration) is no longer required beginning 1 January 2023 and that only BIR Form No. 2550Q remains. The box numbers below (`31` to `61`) reproduce the item numbers printed on BIR Form No. 2550Q, April 2024 (ENCS), read directly from the form itself; the boxes this pack does not model — items `15`-`30` (tax credits, penalties and payment details), `34`-`43` (the running total, uncollected-receivables adjustment, and carried-over/transitional/presumptive input tax), `46`-`50` (importations and other current purchases) and `52`-`60` (deductions from input tax and their schedules) — are named in the pack''s README.', true,'day_of_month_after_period'::filing_deadline_rule, 25, null, 'National Internal Revenue Code of 1997, Section 114(A), as quoted above: ''within twenty-five (25) days following the close of each taxable quarter''.', 'ra-11976', null)
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
  ('PH', 'PH-VAT-2550Q', '31', 'base', 'VATable Sales', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'BIR Form No. 2550Q, April 2024 (ENCS), Part IV item 31, column A — sales for the quarter, exclusive of value-added tax, taxed under Sections 106(A)/108(A) at the standard rate. See PH-S-STD.', 'bir-2550q-form'),
  ('PH', 'PH-VAT-2550Q', '31', 'tax', 'Output Tax on VATable Sales', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'BIR Form No. 2550Q, April 2024 (ENCS), Part IV item 31, column B. See PH-S-STD.', 'bir-2550q-form'),
  ('PH', 'PH-VAT-2550Q', '32', 'base', 'Zero-Rated Sales', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'BIR Form No. 2550Q, April 2024 (ENCS), Part IV item 32 — the value of a sale taxed at zero percent under Section 106(A)(2) or Section 108(B). See PH-S-ZR-EXP and PH-S-ZR-SVC.', 'bir-2550q-form'),
  ('PH', 'PH-VAT-2550Q', '33', 'base', 'Exempt Sales', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'BIR Form No. 2550Q, April 2024 (ENCS), Part IV item 33 — the value of a sale exempt under Section 109. See PH-S-EX.', 'bir-2550q-form'),
  ('PH', 'PH-VAT-2550Q', '37', 'total', 'Total Adjusted Output Tax Due', '{}'::jsonb, 50, null, array['31:tax']::text[], '{}'::text[], null, null, false, false, null, 'BIR Form No. 2550Q, April 2024 (ENCS), Part IV item 37 — ''Item 34B Less Item 35B Add Item 36B''. This pack does not model item 34''s own running total, nor items 35 and 36 (the Ease of Paying Taxes Act''s output-tax adjustment for uncollected and recovered receivables under Section 110(D)); item 37 is therefore taken directly from item 31''s own output tax, named as a gap in the README.', 'bir-2550q-form'),
  ('PH', 'PH-VAT-2550Q', '44', 'base', 'Domestic Purchases', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'BIR Form No. 2550Q, April 2024 (ENCS), Part IV item 44, column A. See PH-P-STD.', 'bir-2550q-form'),
  ('PH', 'PH-VAT-2550Q', '44', 'tax', 'Input Tax on Domestic Purchases', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'BIR Form No. 2550Q, April 2024 (ENCS), Part IV item 44, column B. See PH-P-STD.', 'bir-2550q-form'),
  ('PH', 'PH-VAT-2550Q', '45', 'base', 'Services Rendered by Non-Residents', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'BIR Form No. 2550Q, April 2024 (ENCS), Part IV item 45, column A. See PH-P-RC.', 'bir-2550q-form'),
  ('PH', 'PH-VAT-2550Q', '45', 'tax', 'Input Tax on Services Rendered by Non-Residents', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'BIR Form No. 2550Q, April 2024 (ENCS), Part IV item 45, column B — the input tax credit a payer of a non-resident''s service claims once the value-added tax withheld on it has been remitted on BIR Form No. 1600-VT. See PH-P-RC, whose README entry names the two-return timing this pack does not reproduce.', 'bir-2550q-form'),
  ('PH', 'PH-VAT-2550Q', '51', 'total', 'Total Available Input Tax', '{}'::jsonb, 100, null, array['44:tax', '45:tax']::text[], '{}'::text[], null, null, false, false, null, 'BIR Form No. 2550Q, April 2024 (ENCS), Part IV item 51 — ''Sum of Items 43B and 50B''. This pack does not model item 43 (input tax carried over, deferred on capital goods, transitional or presumptive) nor the rest of item 50 (importations and other current purchases); item 51 is therefore taken directly from items 44 and 45.', 'bir-2550q-form'),
  ('PH', 'PH-VAT-2550Q', '61', 'total', 'Net VAT Payable/(Excess Input Tax)', '{}'::jsonb, 110, null, array['37']::text[], array['51']::text[], null, null, false, false, null, 'BIR Form No. 2550Q, April 2024 (ENCS), Part IV item 61 — ''Item 37B Less Item 60B''. This pack does not model items 52 to 60 (deductions from and adjustments to input tax); item 61 is therefore item 37 less item 51. A negative figure is not floored to zero: it is an excess input tax a taxpayer carries to the next quarter (item 38 of that later return) rather than a refund claimed automatically, and this session did not read Section 112 closely enough to model the choice between carry-over and refund.', 'bir-2550q-form')
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
  ('PH-BS', 'PH', 'default', 'Statement of Financial Position', 'balance_sheet', 'PH-ORIGINAL', date '1970-01-01', null, 'The Philippines prescribes no line items of its own that this session could read: the Financial and Sustainability Reporting Standards Council adopts the Philippine Financial Reporting Standards and the Philippine Financial Reporting Standard for Small Entities, and this session could not open either standard''s own text (see the pack''s README, "Sources"). This statement is original: it groups this chart''s own accounts by the code ranges accounts.csv gives them — current and non-current, receivables and payables split from other balances — the same classification IFRS for SMEs, section 4, uses without transcribing that section''s own line items or their numbering.', null),
  ('PH-IS', 'PH', 'default', 'Statement of Comprehensive Income', 'income_statement', 'PH-ORIGINAL', date '1970-01-01', null, 'As PH-BS: original, grouped by the code ranges accounts.csv gives this chart''s revenue, cost and expense accounts.', null)
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
  ('PH-BS', 'A-C-CASH', 'A-C', 'Cash and cash equivalents', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PH-BS', 'A-C-REC', 'A-C', 'Trade and other receivables', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PH-BS', 'A-C-OTH', 'A-C', 'Input value-added tax, other current receivables and inventories', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PH-BS', 'A-C-PREP', 'A-C', 'Prepaid expenses and deposits', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PH-BS', 'A-C', null, 'Current assets', '{}'::jsonb, 50, 1, true, array['A-C-CASH', 'A-C-REC', 'A-C-OTH', 'A-C-PREP']::text[], '{}'::text[], null, null, null),
  ('PH-BS', 'A-NC-FIX', 'A-NC', 'Property and equipment, net of accumulated depreciation', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PH-BS', 'A-NC-OTH', 'A-NC', 'Intangible and other non-current assets', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PH-BS', 'A-NC', null, 'Non-current assets', '{}'::jsonb, 80, 1, true, array['A-NC-FIX', 'A-NC-OTH']::text[], '{}'::text[], null, null, null),
  ('PH-BS', 'A-TOT', null, 'Total assets', '{}'::jsonb, 90, 1, true, array['A-C', 'A-NC']::text[], '{}'::text[], null, null, null),
  ('PH-BS', 'L-C-PAY', 'L-C', 'Trade and other payables', '{}'::jsonb, 100, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PH-BS', 'L-C-OTH', 'L-C', 'Output value-added tax, statutory dues and other current liabilities', '{}'::jsonb, 110, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PH-BS', 'L-C', null, 'Current liabilities', '{}'::jsonb, 120, 1, true, array['L-C-PAY', 'L-C-OTH']::text[], '{}'::text[], null, null, null),
  ('PH-BS', 'L-NC', 'L-TOT', 'Non-current liabilities', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PH-BS', 'L-TOT', null, 'Total liabilities', '{}'::jsonb, 140, 1, true, array['L-C', 'L-NC']::text[], '{}'::text[], null, null, null),
  ('PH-BS', 'E-CAP', 'E-TOT', 'Share capital and reserves', '{}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PH-BS', 'E-RET', 'E-TOT', 'Retained earnings', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PH-BS', 'E-RESULT', 'E-TOT', 'Result for the period, not yet closed', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PH-BS', 'E-TOT', null, 'Total equity', '{}'::jsonb, 180, 1, true, array['E-CAP', 'E-RET', 'E-RESULT']::text[], '{}'::text[], null, null, null),
  ('PH-BS', 'EL-TOT', null, 'Total liabilities and equity', '{}'::jsonb, 190, 1, true, array['L-TOT', 'E-TOT']::text[], '{}'::text[], null, null, null),
  ('PH-IS', 'REV', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PH-IS', 'COST', null, 'Cost of sales', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PH-IS', 'GROSS', null, 'Gross profit', '{}'::jsonb, 30, 1, true, array['REV']::text[], array['COST']::text[], null, null, null),
  ('PH-IS', 'OTH-INC', null, 'Other income', '{}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PH-IS', 'OPEX', null, 'Operating and finance expenses', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PH-IS', 'DEPR', null, 'Depreciation and amortization', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PH-IS', 'PRETAX', null, 'Income before income tax', '{}'::jsonb, 70, 1, true, array['GROSS', 'OTH-INC']::text[], array['OPEX', 'DEPR']::text[], null, null, null),
  ('PH-IS', 'TAX', null, 'Income tax expense', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PH-IS', 'PROFIT', null, 'Net income for the period', '{}'::jsonb, 90, 1, true, array['PRETAX']::text[], array['TAX']::text[], null, null, null)
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
    ('PH-BS', 'A-C-CASH', 10, 'code_range', '1000', '1099', null, 'any'),
    ('PH-BS', 'A-C-REC', 10, 'code_range', '1100', '1119', null, 'any'),
    ('PH-BS', 'A-C-OTH', 10, 'code_range', '1120', '1299', null, 'any'),
    ('PH-BS', 'A-C-PREP', 10, 'code_range', '1300', '1399', null, 'any'),
    ('PH-BS', 'A-NC-FIX', 10, 'code_range', '1600', '1699', null, 'any'),
    ('PH-BS', 'A-NC-OTH', 10, 'code_range', '1700', '1799', null, 'any'),
    ('PH-BS', 'L-C-PAY', 10, 'code_range', '2000', '2009', null, 'any'),
    ('PH-BS', 'L-C-OTH', 10, 'code_range', '2010', '2499', null, 'any'),
    ('PH-BS', 'L-C-OTH', 20, 'code_range', '2900', '2999', null, 'any'),
    ('PH-BS', 'L-NC', 10, 'code_range', '2500', '2599', null, 'any'),
    ('PH-BS', 'E-CAP', 10, 'code_range', '3000', '3199', null, 'any'),
    ('PH-BS', 'E-RET', 10, 'code_range', '3200', '3299', null, 'any'),
    ('PH-BS', 'E-RESULT', 10, 'code_range', '4000', '5999', null, 'any'),
    ('PH-BS', 'E-RESULT', 20, 'code_range', '6000', '8999', null, 'any'),
    ('PH-IS', 'REV', 10, 'code_range', '4000', '4599', null, 'any'),
    ('PH-IS', 'COST', 10, 'code_range', '5000', '5099', null, 'any'),
    ('PH-IS', 'OTH-INC', 10, 'code_range', '4700', '4999', null, 'any'),
    ('PH-IS', 'OPEX', 10, 'code_range', '6000', '6969', null, 'any'),
    ('PH-IS', 'OPEX', 20, 'code_range', '6980', '7099', null, 'any'),
    ('PH-IS', 'DEPR', 10, 'code_range', '6970', '6979', null, 'any'),
    ('PH-IS', 'TAX', 10, 'code_range', '8000', '8099', null, 'any')
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
  ('PH', 'Philippines', '{}'::jsonb, array['en']::text[], 'PHP', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', default, default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, 'quarter'::declaration_period)
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
  numbering_legal_reference     = 'Section 238 of the National Internal Revenue Code, as amended by Republic Act No. 11976, section 36 — an invoice printed under a Bureau of Internal Revenue authority to print (or system permit to use) has to be ''serially numbered'', which asks for an identifying number rather than, in so many words, a series with no gap across a whole registration; numbering is therefore `sequential` and the pattern in `number_format` is one a business may choose within that requirement.',
  numbering_source_key          = 'ra-11976',
  payment_terms_legal_reference = 'No statute setting a payment term between businesses in the absence of an agreement was found this session; the search was not exhaustive, and Republic Act No. 9510 (the Credit Information System Act) and sector-specific rules on suppliers to large enterprises (Republic Act No. 9501 and its implementing rules for micro, small and medium enterprises) may bear on parts of this question without answering it in general. `legal_payment_days` and `late_payment_reference` are left null rather than guessed.',
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'Section 113(A) and (B) of the National Internal Revenue Code, as amended, ties the value-added tax invoice to ''every sale, barter, exchange, or lease of goods or properties, and for every sale, barter or exchange of services'', issued at the point of the transaction (Section 237(A)); the accrual basis the Ease of Paying Taxes Act adopted for both goods and services (Revenue Regulations No. 3-2024, read only through the Bureau''s own two-page digest this session, not the regulation''s full text) makes the invoice, rather than collection, the trigger for both. `invoice_if_issued` is the closest of this format''s five values; it does not carry Revenue Regulations No. 3-2024''s own transitory rule crediting output tax on a receivable only once collected for a service billed before the Regulations took effect, which is named as a gap in the pack''s README.',
  tax_point_source_key          = 'ra-11976',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_legal_reference      = 'The Bureau of Internal Revenue operates the Electronic Invoicing/Receipting System (EIS) under Sections 237 and 237-A of the National Internal Revenue Code (introduced by the TRAIN Law, Republic Act No. 10963, and implemented by Revenue Regulations No. 8-2022): a taxpayer the Regulations cover — initially large taxpayers, taxpayers engaged in e-commerce, and taxpayers exporting goods and services — issues a structured electronic invoice and transmits its sales data to the Bureau''s own platform (eis.bir.gov.ph) rather than exchanging a document with the buyer''s own access point. It is a clearance/reporting regime the way `packs/mx/`''s CFDI, `packs/vn/`''s hóa đơn có mã and `packs/sa/`''s FATOORA are, and not an exchange built on EN 16931: `profile` names a profile a brick of `packages/formats/` actually writes — `peppol-bis-3`, `factur-x-en16931`, a PINT — and none of them describes a document the Bureau itself stamps or receives sales data from in near-real time. No component of `packages/formats/` writes the EIS''s own JSON schema or talks to its API, so a document Ekwo posts is not an Electronic Invoice within the Bureau''s own meaning. `profile`, `mandatory_from` and `obligation` are therefore left empty although the obligation itself is real and, by secondary reporting this session could not verify against a primary Revenue Memorandum Circular, due to reach the large-taxpayer and exporter group covered by Revenue Regulations No. 8-2022 by 31 December 2026 — the schema itself ties the three fields together (`mandatory` needs a `mandatory_from`, which needs a `profile`), so a pack in this position cannot say the one true thing it knows without a fourth field for the exchange model, which `docs/international.md`''s ''From Saudi Arabia'' section already asks for. `party_scheme` and `vat_scheme` are empty because the Philippines carries no ISO 6523 identifier: it is absent from the Peppol participant identifier scheme list. What a Philippine invoice carries instead is the twelve-digit Taxpayer Identification Number, the last three digits of which are the branch code (BIR Form 2550Q guidelines, April 2024).',
  einvoice_source_key           = 'rr-8-2022',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'PH';
