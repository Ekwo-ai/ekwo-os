-- Ekwo OS — Zambia: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/zm at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build zm`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Value Added Tax Act, Chapter 331 of the Laws of Zambia (consolidated edition published by the Parliament of Zambia): ss. 7, 8, 9, 13, 15, 16, 18, 19 and the schedules (National Assembly of Zambia)
--     https://www.parliament.gov.zm/sites/default/files/documents/acts/Value%20Added%20Tax%20Act.pdf
--   Practice Note No. 1/2024 — the Value Added Tax (Amendment) Act No. 27 of 2023, the Value Added Tax (Exemption) (Amendment) Order, Statutory Instrument No. 60 of 2023, and the electronic invoicing system (Zambia Revenue Authority)
--     https://www.zra.org.zm/wp-content/uploads/2024/02/2024-Practice-Note.pdf
--   VAT Liability Guide — the Value Added Tax (Exemption) Order and the Value Added Tax (Zero-Rating) Order, group by group (Zambia Revenue Authority)
--     https://www.zra.org.zm/wp-content/uploads/2023/08/VAT-Liability-Guide.pdf
--   VAT Guide — the standard rate, registration threshold, filing, input tax and the VAT account that feeds the return (Zambia Revenue Authority)
--     https://www.zra.org.zm/wp-content/uploads/2020/07/VAT-Guide.pdf
--   Payment Due Dates — VAT, Insurance Premium Levy, PAYE, withholding tax and the other monthly obligations (Zambia Revenue Authority)
--     https://www.zra.org.zm/payment-due-dates/
--   Value Added Tax (Zero Rating) (Amendment) Order, 2025, Statutory Instrument No. 95 of 2025 — mains water and sewerage services zero-rated from 1 January 2026 (Government of Zambia, published on ZambiaLII)
--     https://zambialii.org/akn/zm/act/si/2025/95/eng@2025-12-31
--   Smart Invoice — frequently asked questions: the legal requirement to use the electronic invoicing system and the penalties of s. 7A(3) of the Value Added Tax Act (Zambia Revenue Authority)
--     https://www.zra.org.zm/wp-content/uploads/2024/08/Smart-Invoice-FAQs.pdf
--   Smart Invoice — available solutions and eligibility, including certified invoicing systems integrated through the Virtual Sales Data Controller (Zambia Revenue Authority)
--     https://www.zra.org.zm/smart-invoice-learn-more/
--   ZRA Tax Online — the taxpayer portal where the monthly VAT return is filed and the payment registration number is generated (Zambia Revenue Authority)
--     https://portal.zra.org.zm/
--   Financial Reporting — full IFRS adopted in 2005 and the three-tier framework: IFRS, IFRS for SMEs and the Financial Reporting Standard for Micro and Small Entities (Zambia Institute of Chartered Accountants)
--     https://www.zica.co.zm/financial-reporting/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('ZM', 'Zambia', '0.1.0', date '2026-10-10', '20260929141500', 'community', null, null, '3ccc0212ca36332777d8679248ea4794a66c0a8f073c965d07b235658469a10a', '[{"key":"vat-act","title":"Value Added Tax Act, Chapter 331 of the Laws of Zambia (consolidated edition published by the Parliament of Zambia): ss. 7, 8, 9, 13, 15, 16, 18, 19 and the schedules","publisher":"National Assembly of Zambia","url":"https://www.parliament.gov.zm/sites/default/files/documents/acts/Value%20Added%20Tax%20Act.pdf","consulted_on":"2026-10-10","kind":"law"},{"key":"practice-note-2024","title":"Practice Note No. 1/2024 — the Value Added Tax (Amendment) Act No. 27 of 2023, the Value Added Tax (Exemption) (Amendment) Order, Statutory Instrument No. 60 of 2023, and the electronic invoicing system","publisher":"Zambia Revenue Authority","url":"https://www.zra.org.zm/wp-content/uploads/2024/02/2024-Practice-Note.pdf","consulted_on":"2026-10-10","kind":"guidance"},{"key":"vat-liability-guide","title":"VAT Liability Guide — the Value Added Tax (Exemption) Order and the Value Added Tax (Zero-Rating) Order, group by group","publisher":"Zambia Revenue Authority","url":"https://www.zra.org.zm/wp-content/uploads/2023/08/VAT-Liability-Guide.pdf","consulted_on":"2026-10-10","kind":"guidance"},{"key":"vat-guide","title":"VAT Guide — the standard rate, registration threshold, filing, input tax and the VAT account that feeds the return","publisher":"Zambia Revenue Authority","url":"https://www.zra.org.zm/wp-content/uploads/2020/07/VAT-Guide.pdf","consulted_on":"2026-10-10","kind":"guidance"},{"key":"payment-due-dates","title":"Payment Due Dates — VAT, Insurance Premium Levy, PAYE, withholding tax and the other monthly obligations","publisher":"Zambia Revenue Authority","url":"https://www.zra.org.zm/payment-due-dates/","consulted_on":"2026-10-10","kind":"guidance"},{"key":"zero-rating-amendment-2025","title":"Value Added Tax (Zero Rating) (Amendment) Order, 2025, Statutory Instrument No. 95 of 2025 — mains water and sewerage services zero-rated from 1 January 2026","publisher":"Government of Zambia, published on ZambiaLII","url":"https://zambialii.org/akn/zm/act/si/2025/95/eng@2025-12-31","consulted_on":"2026-10-10","kind":"regulation"},{"key":"smart-invoice-faqs","title":"Smart Invoice — frequently asked questions: the legal requirement to use the electronic invoicing system and the penalties of s. 7A(3) of the Value Added Tax Act","publisher":"Zambia Revenue Authority","url":"https://www.zra.org.zm/wp-content/uploads/2024/08/Smart-Invoice-FAQs.pdf","consulted_on":"2026-10-10","kind":"guidance"},{"key":"smart-invoice-solutions","title":"Smart Invoice — available solutions and eligibility, including certified invoicing systems integrated through the Virtual Sales Data Controller","publisher":"Zambia Revenue Authority","url":"https://www.zra.org.zm/smart-invoice-learn-more/","consulted_on":"2026-10-10","kind":"guidance"},{"key":"zra-tax-online","title":"ZRA Tax Online — the taxpayer portal where the monthly VAT return is filed and the payment registration number is generated","publisher":"Zambia Revenue Authority","url":"https://portal.zra.org.zm/","consulted_on":"2026-10-10","kind":"portal"},{"key":"zica-financial-reporting","title":"Financial Reporting — full IFRS adopted in 2005 and the three-tier framework: IFRS, IFRS for SMEs and the Financial Reporting Standard for Micro and Small Entities","publisher":"Zambia Institute of Chartered Accountants","url":"https://www.zica.co.zm/financial-reporting/","consulted_on":"2026-10-10","kind":"guidance"}]'::jsonb)
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
  ('ZM', 'default', 'Zambia reference chart of accounts', '{}'::jsonb, true, 'companies', array['ZM-ZICA-IS', 'ZM-ZICA-SFP']::text[], null, 'There is no legal chart of accounts in Zambia. The Zambia Institute of Chartered Accountants (ZICA), the standard-setting body of the Accountants Act, 2008, adopted IFRS Accounting Standards in 2005 and runs a three-tier framework (full IFRS, IFRS for SMEs, and a standard for micro and small entities). This chart is original: four digits, blocked so that each range reaches one line of the IFRS-based statements below, with the accounts a Zambian company actually keeps — VAT input and output tax, import VAT owed to the Zambia Revenue Authority at the border, NAPSA contributions, PAYE, skills development levy, withholding tax, insurance premium levy and excise duty payable, and the irrecoverable VAT that the Act leaves with a buyer of an imported service.', 'zica-financial-reporting')
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
  ('ZM', 'default', '1000', 'Petty cash', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('ZM', 'default', '1010', 'Current account — ZMW', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('ZM', 'default', '1020', 'Fixed deposits placed for three months or less', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('ZM', 'default', '1030', 'Foreign currency account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('ZM', 'default', '1040', 'Cash in transit — mobile money settlements', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('ZM', 'default', '1100', 'Trade receivables', '{}'::jsonb, 'asset_receivable', true, null, 60),
  ('ZM', 'default', '1110', 'Trade receivables — allowance for impairment', '{}'::jsonb, 'asset_current', false, null, 70),
  ('ZM', 'default', '1120', 'Other receivables', '{}'::jsonb, 'asset_current', false, null, 80),
  ('ZM', 'default', '1130', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 90),
  ('ZM', 'default', '1140', 'Deposits paid', '{}'::jsonb, 'asset_current', false, null, 100),
  ('ZM', 'default', '1150', 'VAT input tax', '{}'::jsonb, 'asset_current', false, null, 110),
  ('ZM', 'default', '1155', 'VAT refundable by ZRA — net of a filed return', '{}'::jsonb, 'asset_current', true, null, 120),
  ('ZM', 'default', '1160', 'Advances to staff', '{}'::jsonb, 'asset_current', false, null, 130),
  ('ZM', 'default', '1200', 'Inventories — goods for resale', '{}'::jsonb, 'asset_current', false, null, 140),
  ('ZM', 'default', '1210', 'Inventories — raw materials', '{}'::jsonb, 'asset_current', false, null, 150),
  ('ZM', 'default', '1220', 'Inventories — work in progress', '{}'::jsonb, 'asset_current', false, null, 160),
  ('ZM', 'default', '1230', 'Inventories — finished goods', '{}'::jsonb, 'asset_current', false, null, 170),
  ('ZM', 'default', '1300', 'Short-term investments', '{}'::jsonb, 'asset_current', false, null, 180),
  ('ZM', 'default', '1350', 'Current tax recoverable', '{}'::jsonb, 'asset_current', false, null, 190),
  ('ZM', 'default', '1400', 'Prepayments', '{}'::jsonb, 'asset_prepayments', false, null, 200),
  ('ZM', 'default', '1410', 'Accrued income', '{}'::jsonb, 'asset_prepayments', false, null, 210),
  ('ZM', 'default', '1600', 'Land and buildings — cost', '{}'::jsonb, 'asset_fixed', false, null, 220),
  ('ZM', 'default', '1601', 'Land and buildings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 230),
  ('ZM', 'default', '1610', 'Leasehold improvements — cost', '{}'::jsonb, 'asset_fixed', false, null, 240),
  ('ZM', 'default', '1611', 'Leasehold improvements — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 250),
  ('ZM', 'default', '1620', 'Plant and machinery — cost', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('ZM', 'default', '1621', 'Plant and machinery — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('ZM', 'default', '1630', 'Office equipment — cost', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('ZM', 'default', '1631', 'Office equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('ZM', 'default', '1640', 'Computers — cost', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('ZM', 'default', '1641', 'Computers — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('ZM', 'default', '1650', 'Furniture and fittings — cost', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('ZM', 'default', '1651', 'Furniture and fittings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('ZM', 'default', '1660', 'Motor vehicles — cost', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('ZM', 'default', '1661', 'Motor vehicles — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('ZM', 'default', '1670', 'Right-of-use assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('ZM', 'default', '1671', 'Right-of-use assets — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('ZM', 'default', '1700', 'Investment property', '{}'::jsonb, 'asset_non_current', false, null, 380),
  ('ZM', 'default', '1750', 'Intangible assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 390),
  ('ZM', 'default', '1751', 'Intangible assets — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 400),
  ('ZM', 'default', '1760', 'Goodwill', '{}'::jsonb, 'asset_fixed', false, null, 410),
  ('ZM', 'default', '1800', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('ZM', 'default', '1810', 'Investments in joint ventures', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('ZM', 'default', '1830', 'Long-term financial assets', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('ZM', 'default', '1840', 'Long-term deposits', '{}'::jsonb, 'asset_non_current', false, null, 450),
  ('ZM', 'default', '1900', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('ZM', 'default', '2000', 'Trade payables', '{}'::jsonb, 'liability_payable', true, null, 470),
  ('ZM', 'default', '2010', 'Accrued expenses', '{}'::jsonb, 'liability_current', false, null, 480),
  ('ZM', 'default', '2020', 'Other payables', '{}'::jsonb, 'liability_current', false, null, 490),
  ('ZM', 'default', '2030', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 500),
  ('ZM', 'default', '2040', 'Deposits received from customers', '{}'::jsonb, 'liability_current', false, null, 510),
  ('ZM', 'default', '2100', 'VAT output tax', '{}'::jsonb, 'liability_current', false, null, 520),
  ('ZM', 'default', '2110', 'VAT payable to ZRA — net of a filed return', '{}'::jsonb, 'liability_current', true, null, 530),
  ('ZM', 'default', '2125', 'Import VAT payable to ZRA at the border', '{}'::jsonb, 'liability_current', false, null, 540),
  ('ZM', 'default', '2140', 'Withholding tax payable to ZRA', '{}'::jsonb, 'liability_current', false, null, 550),
  ('ZM', 'default', '2150', 'NAPSA contributions payable', '{}'::jsonb, 'liability_current', false, null, 560),
  ('ZM', 'default', '2155', 'Skills development levy payable', '{}'::jsonb, 'liability_current', false, null, 570),
  ('ZM', 'default', '2160', 'PAYE payable to ZRA', '{}'::jsonb, 'liability_current', false, null, 580),
  ('ZM', 'default', '2165', 'Insurance premium levy payable to ZRA', '{}'::jsonb, 'liability_current', false, null, 590),
  ('ZM', 'default', '2170', 'Excise duty payable to ZRA', '{}'::jsonb, 'liability_current', false, null, 600),
  ('ZM', 'default', '2175', 'Turnover tax payable to ZRA', '{}'::jsonb, 'liability_current', false, null, 610),
  ('ZM', 'default', '2180', 'Salaries payable', '{}'::jsonb, 'liability_current', false, null, 620),
  ('ZM', 'default', '2190', 'Directors'' fees payable', '{}'::jsonb, 'liability_current', false, null, 630),
  ('ZM', 'default', '2200', 'Bank overdraft', '{}'::jsonb, 'liability_current', false, null, 640),
  ('ZM', 'default', '2210', 'Bank loans — current portion', '{}'::jsonb, 'liability_current', false, null, 650),
  ('ZM', 'default', '2220', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 660),
  ('ZM', 'default', '2230', 'Hire purchase — current portion', '{}'::jsonb, 'liability_current', false, null, 670),
  ('ZM', 'default', '2240', 'Corporate credit card', '{}'::jsonb, 'liability_credit_card', false, null, 680),
  ('ZM', 'default', '2250', 'Amounts due to directors', '{}'::jsonb, 'liability_current', false, null, 690),
  ('ZM', 'default', '2300', 'Current tax payable', '{}'::jsonb, 'liability_current', false, null, 700),
  ('ZM', 'default', '2350', 'Provision for unutilised leave', '{}'::jsonb, 'liability_current', false, null, 710),
  ('ZM', 'default', '2360', 'Other provisions — current', '{}'::jsonb, 'liability_current', false, null, 720),
  ('ZM', 'default', '2400', 'Bank loans — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 730),
  ('ZM', 'default', '2410', 'Lease liabilities — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 740),
  ('ZM', 'default', '2420', 'Hire purchase — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 750),
  ('ZM', 'default', '2430', 'Loans from shareholders and directors — non-current', '{}'::jsonb, 'liability_non_current', false, null, 760),
  ('ZM', 'default', '2500', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 770),
  ('ZM', 'default', '2550', 'Provision for reinstatement costs', '{}'::jsonb, 'liability_non_current', false, null, 780),
  ('ZM', 'default', '2990', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 790),
  ('ZM', 'default', '3000', 'Share capital', '{}'::jsonb, 'equity', false, null, 800),
  ('ZM', 'default', '3010', 'Treasury shares', '{}'::jsonb, 'equity', false, null, 810),
  ('ZM', 'default', '3100', 'Other reserves', '{}'::jsonb, 'equity', false, null, 820),
  ('ZM', 'default', '3110', 'Foreign currency translation reserve', '{}'::jsonb, 'equity', false, null, 830),
  ('ZM', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 840),
  ('ZM', 'default', '3210', 'Dividends paid', '{}'::jsonb, 'equity_retained', false, null, 850),
  ('ZM', 'default', '4000', 'Sales of goods', '{}'::jsonb, 'income', false, null, 860),
  ('ZM', 'default', '4010', 'Services rendered', '{}'::jsonb, 'income', false, null, 870),
  ('ZM', 'default', '4020', 'Export sales of goods', '{}'::jsonb, 'income', false, null, 880),
  ('ZM', 'default', '4030', 'Export of services', '{}'::jsonb, 'income', false, null, 890),
  ('ZM', 'default', '4500', 'Interest income', '{}'::jsonb, 'income_other', false, null, 900),
  ('ZM', 'default', '4510', 'Dividend income', '{}'::jsonb, 'income_other', false, null, 910),
  ('ZM', 'default', '4520', 'Rental income — residential lease', '{}'::jsonb, 'income_other', false, null, 920),
  ('ZM', 'default', '4530', 'Government grants', '{}'::jsonb, 'income_other', false, null, 930),
  ('ZM', 'default', '4700', 'Foreign exchange gains', '{}'::jsonb, 'income_other', false, null, 940),
  ('ZM', 'default', '4750', 'Gain on disposal of property plant and equipment', '{}'::jsonb, 'income_other', false, null, 950),
  ('ZM', 'default', '4790', 'Other income', '{}'::jsonb, 'income_other', false, null, 960),
  ('ZM', 'default', '5000', 'Purchases of goods for resale', '{}'::jsonb, 'expense_direct_cost', false, null, 970),
  ('ZM', 'default', '5010', 'Freight inwards and import duties', '{}'::jsonb, 'expense_direct_cost', false, null, 980),
  ('ZM', 'default', '5020', 'Subcontract costs', '{}'::jsonb, 'expense_direct_cost', false, null, 990),
  ('ZM', 'default', '5100', 'Changes in inventories', '{}'::jsonb, 'expense_direct_cost', false, null, 1000),
  ('ZM', 'default', '6000', 'Salaries and wages', '{}'::jsonb, 'expense', false, null, 1010),
  ('ZM', 'default', '6010', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 1020),
  ('ZM', 'default', '6020', 'Directors'' fees', '{}'::jsonb, 'expense', false, null, 1030),
  ('ZM', 'default', '6030', 'NAPSA contributions — employer', '{}'::jsonb, 'expense', false, null, 1040),
  ('ZM', 'default', '6040', 'Skills development levy — expense', '{}'::jsonb, 'expense', false, null, 1050),
  ('ZM', 'default', '6050', 'Workers'' compensation contributions', '{}'::jsonb, 'expense', false, null, 1060),
  ('ZM', 'default', '6060', 'Staff welfare', '{}'::jsonb, 'expense', false, null, 1070),
  ('ZM', 'default', '6070', 'Staff medical expenses and insurance', '{}'::jsonb, 'expense', false, null, 1080),
  ('ZM', 'default', '6080', 'Staff training', '{}'::jsonb, 'expense', false, null, 1090),
  ('ZM', 'default', '6200', 'Depreciation of property plant and equipment', '{}'::jsonb, 'expense_depreciation', false, null, 1100),
  ('ZM', 'default', '6210', 'Depreciation of right-of-use assets', '{}'::jsonb, 'expense_depreciation', false, null, 1110),
  ('ZM', 'default', '6220', 'Amortisation of intangible assets', '{}'::jsonb, 'expense_depreciation', false, null, 1120),
  ('ZM', 'default', '6300', 'Rent — short-term leases', '{}'::jsonb, 'expense', false, null, 1130),
  ('ZM', 'default', '6310', 'Utilities', '{}'::jsonb, 'expense', false, null, 1140),
  ('ZM', 'default', '6320', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 1150),
  ('ZM', 'default', '6330', 'Cleaning and security services', '{}'::jsonb, 'expense', false, null, 1160),
  ('ZM', 'default', '6340', 'Telephone and internet', '{}'::jsonb, 'expense', false, null, 1170),
  ('ZM', 'default', '6350', 'Software subscriptions', '{}'::jsonb, 'expense', false, null, 1180),
  ('ZM', 'default', '6360', 'Advertising and marketing', '{}'::jsonb, 'expense', false, null, 1190),
  ('ZM', 'default', '6370', 'Travelling', '{}'::jsonb, 'expense', false, null, 1200),
  ('ZM', 'default', '6380', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1210),
  ('ZM', 'default', '6390', 'Entertainment', '{}'::jsonb, 'expense', false, null, 1220),
  ('ZM', 'default', '6400', 'Subscriptions and memberships', '{}'::jsonb, 'expense', false, null, 1230),
  ('ZM', 'default', '6410', 'Insurance', '{}'::jsonb, 'expense', false, null, 1240),
  ('ZM', 'default', '6420', 'Professional fees', '{}'::jsonb, 'expense', false, null, 1250),
  ('ZM', 'default', '6430', 'Audit fees', '{}'::jsonb, 'expense', false, null, 1260),
  ('ZM', 'default', '6440', 'Company secretarial and registration fees', '{}'::jsonb, 'expense', false, null, 1270),
  ('ZM', 'default', '6450', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1280),
  ('ZM', 'default', '6460', 'Printing and stationery', '{}'::jsonb, 'expense', false, null, 1290),
  ('ZM', 'default', '6470', 'Postage and courier', '{}'::jsonb, 'expense', false, null, 1300),
  ('ZM', 'default', '6480', 'Licences permits and local government fees', '{}'::jsonb, 'expense', false, null, 1310),
  ('ZM', 'default', '6490', 'Royalties', '{}'::jsonb, 'expense', false, null, 1320),
  ('ZM', 'default', '6500', 'Bad debts written off', '{}'::jsonb, 'expense', false, null, 1330),
  ('ZM', 'default', '6510', 'Impairment loss on trade receivables', '{}'::jsonb, 'expense', false, null, 1340),
  ('ZM', 'default', '6520', 'Irrecoverable VAT on imported services', '{}'::jsonb, 'expense', false, null, 1350),
  ('ZM', 'default', '6530', 'Irrecoverable input VAT', '{}'::jsonb, 'expense', false, null, 1360),
  ('ZM', 'default', '6900', 'Donations', '{}'::jsonb, 'expense', false, null, 1370),
  ('ZM', 'default', '6950', 'Foreign exchange losses', '{}'::jsonb, 'expense', false, null, 1380),
  ('ZM', 'default', '6960', 'Loss on disposal of property plant and equipment', '{}'::jsonb, 'expense', false, null, 1390),
  ('ZM', 'default', '6990', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1400),
  ('ZM', 'default', '7000', 'Interest on bank loans', '{}'::jsonb, 'expense', false, null, 1410),
  ('ZM', 'default', '7010', 'Interest on lease liabilities', '{}'::jsonb, 'expense', false, null, 1420),
  ('ZM', 'default', '7020', 'Hire purchase interest', '{}'::jsonb, 'expense', false, null, 1430),
  ('ZM', 'default', '7030', 'Interest on loans from related parties and others', '{}'::jsonb, 'expense', false, null, 1440),
  ('ZM', 'default', '8000', 'Current income tax expense', '{}'::jsonb, 'expense', false, null, 1450),
  ('ZM', 'default', '8010', 'Deferred tax expense', '{}'::jsonb, 'expense', false, null, 1460),
  ('ZM', 'default', '8020', 'Under or over provision of income tax in prior years', '{}'::jsonb, 'expense', false, null, 1470)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('ZM', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('ZM', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('ZM', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('ZM', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('ZM', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('ZM', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('ZM', 'ZM-P-16', 'Purchase, standard rate 16 %, deductible', '{}'::jsonb, 'A local purchase at the general rate, used in the business of a registered supplier', 'percent', 16, 'purchase', 'domestic', date '2012-01-01', null, 'Value Added Tax Act, s. 18(1)(a) — the tax payable on a supply to a registered supplier for the purposes of a business may be deducted from the tax liability of that or a later accounting period; s. 18(3), as substituted by Act No. 27 of 2023 — the supplier must hold a tax invoice from a serially numbered invoice book, an authorised computer package or the approved invoicing system when the return is lodged; s. 18(4) — not claimable after the period the law allows. Input tax is not deductible on every purchase (VAT Guide, Part 3.2: entertainment, motor vehicles, petrol and others) — such a purchase takes code ZM-P-16-ND.', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('ZM', 'ZM-P-16-ND', 'Purchase, standard rate 16 %, input tax not deductible', '{}'::jsonb, 'A purchase whose input tax the law blocks — entertainment, passenger motor vehicles, petrol and similar', 'percent', 16, 'purchase', 'domestic', date '2012-01-01', null, 'Value Added Tax Act, s. 18(5) — the Minister may by regulation determine cases in which a deduction or credit of input tax is not allowed; the Authority''s VAT Guide, Part 3.2, lists the items on which input tax cannot be claimed (telephone and internet bills in part, motor vehicles, business entertainment, benefits for directors and employees, petrol, diesel in part, staff housing). The tax follows the expense to account 6530. The list of blocked items is the Authority''s guidance and not a code the pack applies by itself.', null, null, 115, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-guide', null, null, null, null),
  ('ZM', 'ZM-P-EX', 'Purchase, exempt', '{}'::jsonb, 'An insurance premium, or another exempt supply bought for the business', 'percent', 0, 'purchase', 'exempt', date '1995-07-01', null, 'Value Added Tax Act, s. 15(1); Value Added Tax (Exemption) Order, Group 7 — insurance services and financial charges are exempt, so there is no VAT to deduct. The return carries no row for an exempt purchase.', null, null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-liability-guide', null, null, null, null),
  ('ZM', 'ZM-P-IMP', 'Import of goods, VAT paid at the border', '{}'::jsonb, 'VAT charged on the importation of taxable goods, paid to the Authority as a customs duty and claimed as input tax', 'percent', 16, 'purchase', 'import', date '2012-01-01', null, 'Value Added Tax Act, s. 8(1)(b) — tax is charged on a taxable importation of goods; s. 8(4) — tax on an importation is charged as if it were a duty of customs and is payable by the importer; s. 18(1)(b) — tax paid by a registered supplier on the importation of goods used in the business may be deducted; s. 18(3)(e) — the supplier holds the bill of entry and the evidence of payment. The tax is owed to the Authority at the border and not to the supplier, so it waits on 2125 until the import declaration is settled.', null, null, 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('ZM', 'ZM-P-RC-SVC', 'Imported service, reverse-charged, not recoverable', '{}'::jsonb, 'A service supplied by a person outside Zambia, taxed to the recipient who cannot deduct the tax', 'percent', 16, 'purchase', 'foreign_services_received', date '2024-01-01', null, 'Value Added Tax Act, s. 8(1)(b) and s. 8(5), as substituted by Act No. 27 of 2023 and in force on 1 January 2024 — the recipient of an imported service pays the tax on it where the tax was not paid in the country of exportation, the non-resident supplier has no appointed tax agent and the service is not a cross-border electronic service; s. 8(7) — the input tax corresponding to that payment is excluded from a claim, deduction or credit under s. 18. The self-charge is therefore output tax with no input offset: it lands in the cost account 6520. A cross-border electronic service is instead taxed by the non-resident supplier, who registers and charges the tax on its own invoice.', null, null, 150, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'practice-note-2024', null, null, null, null),
  ('ZM', 'ZM-P-Z', 'Purchase, zero-rated (local)', '{}'::jsonb, 'A local purchase of a good the Zero-Rating Order taxes at nil, from a registered supplier', 'percent', 0, 'purchase', 'domestic', date '1995-07-01', null, 'Value Added Tax Act, s. 15(2); Value Added Tax (Zero-Rating) Order — there is no input tax to deduct on a supply taxed at nil.', null, null, 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-liability-guide', null, null, null, null),
  ('ZM', 'ZM-S-16', 'Sale, standard rate 16 %', '{}'::jsonb, 'The general rate on a taxable supply made in Zambia', 'percent', 16, 'sale', 'domestic', date '2012-01-01', null, 'Value Added Tax Act, s. 8(1)(a) — tax is charged on a taxable supply of goods or services, other than a zero-rated supply, made in Zambia in furtherance of a business by a registered supplier; s. 9(1) — it is charged on the taxable value at the prescribed rate; s. 9(3) — the printed rate is seventeen and a half per centum unless the Minister, by statutory order, determines a lower rate, and the Authority''s VAT Guide states that "currently the Standard rate is 16%". All supplies that are not exempt or zero-rated are standard-rated (VAT Guide, s. 1.4). The earliest date this pack could evidence for the 16 % rate is the Authority''s own worked VAT account for the period ending 31 December 2012; the statutory order that set it was not found.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-guide', null, null, null, null),
  ('ZM', 'ZM-S-EX', 'Sale, exempt', '{}'::jsonb, 'A supply the Exemption Order lists: health and medical services, education, residential property, financial and insurance services, passenger transport, books and newspapers', 'percent', 0, 'sale', 'exempt', date '1995-07-01', null, 'Value Added Tax Act, s. 15(1) and (3) read with the Value Added Tax (Exemption) Order — Group 2 health services by a registered practitioner, hospital or clinic; Group 3 educational services to nursery, primary, secondary and post-secondary learners; Group 6 the sale or lease of real property other than commercial property; Group 7 financial and insurance services, including interest, bank charges and insurance commissions; also betting and gaming, funeral services and trade union subscriptions. An exempt supplier cannot register for VAT and recovers no input tax (VAT Guide, s. 1.4.5). Insurance premiums are outside VAT but bear the 5 % Insurance Premium Levy, which this pack documents and does not compute.', 'E', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-liability-guide', null, null, null, null),
  ('ZM', 'ZM-S-EX-WATER', 'Sale, exempt (mains water and sewerage, 2024 and 2025)', '{}'::jsonb, 'Mains water and sewerage services, excluding pump-out services, while the Exemption Order held them', 'percent', 0, 'sale', 'exempt', date '2024-01-01', date '2025-12-31', 'Value Added Tax (Exemption) (Amendment) Order, Statutory Instrument No. 60 of 2023, in force on 1 January 2024 — item 17: the supply of mains water and sewerage services, excluding sewerage pump out services, is exempt. Replaced by the zero rate from 1 January 2026 (code ZM-S-Z-WATER); this code is closed on 31 December 2025.', 'E', null, 45, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'practice-note-2024', null, null, null, null),
  ('ZM', 'ZM-S-Z-DOM', 'Sale, zero-rated (domestic — medical supplies and drugs)', '{}'::jsonb, 'A local supply of medical supplies and drugs, a good the Zero-Rating Order taxes at nil without it leaving Zambia', 'percent', 0, 'sale', 'domestic', date '1995-07-01', null, 'Value Added Tax Act, s. 15(2) and (3) read with the Value Added Tax (Zero-Rating) Order — Group 5, medical supplies: (a) medical supplies and drugs; (b) equipment designed solely for medical or prosthetic use supplied to a registered practitioner, hospital or clinic or to a patient. The same Order zero-rates other local supplies (agricultural inputs, mosquito nets, certain foods and capital equipment); a company selling those picks this code too.', 'Z', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-liability-guide', null, null, null, null),
  ('ZM', 'ZM-S-Z-EXP', 'Sale, zero-rated (export)', '{}'::jsonb, 'A supply of goods exported from Zambia, or a service physically rendered outside Zambia', 'percent', 0, 'sale', 'export', date '1995-07-01', null, 'Value Added Tax Act, s. 15(2) and (3) read with the Value Added Tax (Zero-Rating) Order — Group 1: (a) export of goods from Zambia by or on behalf of a taxable supplier where evidence of exportation is produced; (b) freight transport services from or to the Republic and in transit; (f) services physically rendered outside Zambia. A zero-rated supply is a taxable supply: input tax stays deductible (VAT Guide, s. 1.4.5).', 'G', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-liability-guide', null, null, null, null),
  ('ZM', 'ZM-S-Z-WATER', 'Sale, zero-rated (mains water and sewerage, from 1 January 2026)', '{}'::jsonb, 'Mains water and sewerage services, excluding sewerage pump-out services, zero-rated from 1 January 2026', 'percent', 0, 'sale', 'domestic', date '2026-01-01', null, 'Value Added Tax (Zero Rating) (Amendment) Order, 2025, Statutory Instrument No. 95 of 2025, dated 31 December 2025 and in force on 1 January 2026 — the supply of mains water and sewerage services, excluding sewerage pump-out services, moves from the Exemption Order (item 17, inserted by Statutory Instrument No. 60 of 2023) to the Zero-Rating Order. The page of the instrument refuses a request without a browser, so its wording was not read here; the change is recorded from the Authority-side commentary found in the 2026 Budget analyses and must be confirmed against the instrument itself. Sewerage pump-out services stay standard-rated.', 'Z', null, 35, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zero-rating-amendment-2025', null, null, null, null)
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
    ('ZM-P-16', 'invoice', 'base', 100, null, '2', array['2']::text[], 100, 'ZM-VAT-RETURN', 10),
    ('ZM-P-16', 'invoice', 'tax', 100, '1150', '2', array['2']::text[], 100, 'ZM-VAT-RETURN', 20),
    ('ZM-P-16', 'credit_note', 'base', 100, null, '2', array['2']::text[], -100, 'ZM-VAT-RETURN', 10),
    ('ZM-P-16', 'credit_note', 'tax', 100, '1150', '2', array['2']::text[], -100, 'ZM-VAT-RETURN', 20),
    ('ZM-P-16-ND', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('ZM-P-16-ND', 'invoice', 'tax', 100, '6530', null, null, 100, null, 20),
    ('ZM-P-16-ND', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('ZM-P-16-ND', 'credit_note', 'tax', 100, '6530', null, null, 100, null, 20),
    ('ZM-P-EX', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('ZM-P-EX', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('ZM-P-IMP', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'ZM-VAT-RETURN', 10),
    ('ZM-P-IMP', 'invoice', 'tax', 100, '1150', '3', array['3']::text[], 100, 'ZM-VAT-RETURN', 20),
    ('ZM-P-IMP', 'invoice', 'tax', -100, '2125', null, null, 100, null, 30),
    ('ZM-P-IMP', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'ZM-VAT-RETURN', 10),
    ('ZM-P-IMP', 'credit_note', 'tax', 100, '1150', '3', array['3']::text[], -100, 'ZM-VAT-RETURN', 20),
    ('ZM-P-IMP', 'credit_note', 'tax', -100, '2125', null, null, 100, null, 30),
    ('ZM-P-RC-SVC', 'invoice', 'base', 100, null, '1R', array['1R']::text[], 100, 'ZM-VAT-RETURN', 10),
    ('ZM-P-RC-SVC', 'invoice', 'tax', -100, '2100', '1R', array['1R']::text[], 100, 'ZM-VAT-RETURN', 20),
    ('ZM-P-RC-SVC', 'invoice', 'tax', 100, '6520', null, null, 100, null, 30),
    ('ZM-P-RC-SVC', 'credit_note', 'base', 100, null, '1R', array['1R']::text[], -100, 'ZM-VAT-RETURN', 10),
    ('ZM-P-RC-SVC', 'credit_note', 'tax', -100, '2100', '1R', array['1R']::text[], -100, 'ZM-VAT-RETURN', 20),
    ('ZM-P-RC-SVC', 'credit_note', 'tax', 100, '6520', null, null, 100, null, 30),
    ('ZM-P-Z', 'invoice', 'base', 100, null, 'ZP', array['ZP']::text[], 100, 'ZM-VAT-RETURN', 10),
    ('ZM-P-Z', 'credit_note', 'base', 100, null, 'ZP', array['ZP']::text[], -100, 'ZM-VAT-RETURN', 10),
    ('ZM-S-16', 'invoice', 'base', 100, null, '1S', array['1S']::text[], 100, 'ZM-VAT-RETURN', 10),
    ('ZM-S-16', 'invoice', 'tax', 100, '2100', '1S', array['1S']::text[], 100, 'ZM-VAT-RETURN', 20),
    ('ZM-S-16', 'credit_note', 'base', 100, null, '1S', array['1S']::text[], -100, 'ZM-VAT-RETURN', 10),
    ('ZM-S-16', 'credit_note', 'tax', 100, '2100', '1S', array['1S']::text[], -100, 'ZM-VAT-RETURN', 20),
    ('ZM-S-EX', 'invoice', 'base', 100, null, 'EX', array['EX']::text[], 100, 'ZM-VAT-RETURN', 10),
    ('ZM-S-EX', 'credit_note', 'base', 100, null, 'EX', array['EX']::text[], -100, 'ZM-VAT-RETURN', 10),
    ('ZM-S-EX-WATER', 'invoice', 'base', 100, null, 'EX', array['EX']::text[], 100, 'ZM-VAT-RETURN', 10),
    ('ZM-S-EX-WATER', 'credit_note', 'base', 100, null, 'EX', array['EX']::text[], -100, 'ZM-VAT-RETURN', 10),
    ('ZM-S-Z-DOM', 'invoice', 'base', 100, null, 'ZL', array['ZL']::text[], 100, 'ZM-VAT-RETURN', 10),
    ('ZM-S-Z-DOM', 'credit_note', 'base', 100, null, 'ZL', array['ZL']::text[], -100, 'ZM-VAT-RETURN', 10),
    ('ZM-S-Z-EXP', 'invoice', 'base', 100, null, 'ZE', array['ZE']::text[], 100, 'ZM-VAT-RETURN', 10),
    ('ZM-S-Z-EXP', 'credit_note', 'base', 100, null, 'ZE', array['ZE']::text[], -100, 'ZM-VAT-RETURN', 10),
    ('ZM-S-Z-WATER', 'invoice', 'base', 100, null, 'ZL', array['ZL']::text[], 100, 'ZM-VAT-RETURN', 10),
    ('ZM-S-Z-WATER', 'credit_note', 'base', 100, null, 'ZL', array['ZL']::text[], -100, 'ZM-VAT-RETURN', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'ZM' and t.code = v.tax_code
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
  ('ZM', 'ZM-VAT-RETURN', 'Monthly Value Added Tax return', array['month']::declaration_period[], 'month'::declaration_period, date '1995-07-01', null, 'Value Added Tax Act, s. 16(1) — a taxable supplier lodges a tax return with the Commissioner-General for each prescribed accounting period, in the form the Commissioner-General approves; s. 16(3) — the accounting period is the calendar month unless the Commissioner-General fixes another. The Authority''s VAT Guide, Part 7.3, describes the return through five numbered boxes: box 1 output VAT, box 2 input VAT on domestic purchases, box 3 input VAT on imports, box 4 total input VAT and box 5 the tax payable or repayable. The e-filing form on ZRA Tax Online could not be opened from the machine this pack was written on, so only those five boxes are sourced to the Authority; the value rows (zero-rated, exempt, standard-rated supplies and purchases) are this pack''s own and the gap is recorded in this pack''s README.', true,'day_of_month_after_period'::filing_deadline_rule, 18, null, 'Authority''s Payment Due Dates page — Value Added Tax: payment for electronic submissions is due on the 18th of every month; VAT Guide, Part 2.7 — a return with ten or more transactions is lodged electronically within eighteen days after the end of the accounting period. The Act''s own text (s. 16(2), s. 19(1)) says twenty-one days and is overtaken by the Authority''s electronic-filing practice; a return with fewer than ten transactions may be lodged manually within five days. Penalties for late filing are not modelled.', 'payment-due-dates', null)
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
  ('ZM', 'ZM-VAT-RETURN', 'ZE', 'base', 'Zero-rated supplies — exports', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax (Zero-Rating) Order, Group 1 — the value of exports and other zero-rated supplies made for use outside Zambia. A reporting row of this pack, not one of the five numbered boxes of the VAT Guide.', 'vat-liability-guide'),
  ('ZM', 'ZM-VAT-RETURN', 'ZL', 'base', 'Zero-rated supplies — local', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax (Zero-Rating) Order — the value of local supplies taxed at nil (medical supplies, mains water and sewerage from 2026, agricultural inputs). A reporting row of this pack.', 'vat-liability-guide'),
  ('ZM', 'ZM-VAT-RETURN', 'EX', 'base', 'Exempt supplies', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax (Exemption) Order — the value of exempt supplies. A reporting row of this pack.', 'vat-liability-guide'),
  ('ZM', 'ZM-VAT-RETURN', '1S', 'base', 'Standard-rated supplies — value', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Guide, Part 7.3 — the sales on which the output VAT of box 1 is charged. A reporting row of this pack.', 'vat-guide'),
  ('ZM', 'ZM-VAT-RETURN', '1S', 'tax', 'Output VAT on standard-rated supplies', '{}'::jsonb, 45, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Guide, Part 7.3, box 1 of the VAT return — output VAT on sales and other outputs, net of credit notes given.', 'vat-guide'),
  ('ZM', 'ZM-VAT-RETURN', '1R', 'base', 'Imported services — value', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, s. 8(5), as substituted by Act No. 27 of 2023 — the value of an imported service on which the recipient pays the tax. A reporting row of this pack.', 'practice-note-2024'),
  ('ZM', 'ZM-VAT-RETURN', '1R', 'tax', 'Output VAT on imported services', '{}'::jsonb, 55, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, s. 8(5) — the tax the recipient of an imported service pays; included in box 1 as output tax.', 'practice-note-2024'),
  ('ZM', 'ZM-VAT-RETURN', '1', 'total', 'Box 1 — Output VAT', '{}'::jsonb, 60, null, array['1S:tax', '1R:tax']::text[], '{}'::text[], null, null, false, false, null, 'VAT Guide, Part 7.3 — box 1 of the VAT return: output VAT on sales and other outputs. This pack adds the reverse-charged tax of imported services to the output VAT of standard-rated supplies.', 'vat-guide'),
  ('ZM', 'ZM-VAT-RETURN', 'ZP', 'base', 'Zero-rated purchases — value', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax (Zero-Rating) Order — the value of local purchases taxed at nil. A reporting row of this pack.', 'vat-liability-guide'),
  ('ZM', 'ZM-VAT-RETURN', '2', 'base', 'Standard-rated local purchases — value', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Guide, Part 7.3 — the purchases on which the input VAT of box 2 is incurred. A reporting row of this pack.', 'vat-guide'),
  ('ZM', 'ZM-VAT-RETURN', '2', 'tax', 'Box 2 — Input VAT on domestic purchases', '{}'::jsonb, 85, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Guide, Part 7.3, box 2 of the VAT return — input VAT on domestic purchases and other inputs, net of credits received and of any over-claim.', 'vat-guide'),
  ('ZM', 'ZM-VAT-RETURN', '3', 'base', 'Imports of goods — value', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Guide, Part 7.3 — the customs value of imports on which the import VAT of box 3 is paid. A reporting row of this pack.', 'vat-guide'),
  ('ZM', 'ZM-VAT-RETURN', '3', 'tax', 'Box 3 — Input VAT on imports', '{}'::jsonb, 95, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Guide, Part 7.3, box 3 of the VAT return — input VAT on imports.', 'vat-guide'),
  ('ZM', 'ZM-VAT-RETURN', '4', 'total', 'Box 4 — Total input VAT', '{}'::jsonb, 100, null, array['2:tax', '3:tax']::text[], '{}'::text[], null, null, false, false, null, 'VAT Guide, Part 7.3, box 4 of the VAT return — the total of box 2 and box 3.', 'vat-guide'),
  ('ZM', 'ZM-VAT-RETURN', '5', 'total', 'Box 5 — VAT payable or repayable', '{}'::jsonb, 110, null, array['1']::text[], array['4']::text[], null, null, false, false, null, 'VAT Guide, Part 7.3, box 5 of the VAT return — box 1 minus box 4. A positive figure is payable; a negative figure is a credit the Authority refunds (Value Added Tax Act, s. 19(2)).', 'vat-guide')
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
  ('ZM-ZICA-IS', 'ZM', 'default', 'Statement of profit or loss', 'income_statement', 'IFRS-SME', date '2005-01-01', null, 'The Zambia Institute of Chartered Accountants (ZICA), the professional body recognised under the Accountants Act, 2008, adopted IFRS Accounting Standards in full from 2005 and sets a three-tier framework: full IFRS for listed companies, public interest entities and government-owned enterprises; IFRS for SMEs (or full IFRS at the company''s option) for economically significant companies with a turnover of K20 million and above; and the Zambian Financial Reporting Standard for Micro and Small Entities below that. Zambia has no statutory format for the statements, so these lines are an original presentation by nature of expense that follows IAS 1 / section 4 of IFRS for SMEs (statement of profit or loss; expenses aggregated by nature).', 'zica-financial-reporting'),
  ('ZM-ZICA-SFP', 'ZM', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS-SME', date '2005-01-01', null, 'The Zambia Institute of Chartered Accountants (ZICA), the professional body recognised under the Accountants Act, 2008, adopted IFRS Accounting Standards in full from 2005 and sets a three-tier framework: full IFRS for listed companies, public interest entities and government-owned enterprises; IFRS for SMEs (or full IFRS at the company''s option) for economically significant companies with a turnover of K20 million and above; and the Zambian Financial Reporting Standard for Micro and Small Entities below that. Zambia has no statutory format for the statements, so these lines are an original presentation by nature of expense that follows IAS 1 / section 4 of IFRS for SMEs (statement of financial position).', 'zica-financial-reporting')
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
  ('ZM-ZICA-IS', '1', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-IS', '2', null, 'Other income', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-IS', '3', null, 'Purchases and changes in inventories', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-IS', '4', null, 'Employee benefits expense', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-IS', '5', null, 'Depreciation and amortisation', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-IS', '6', null, 'Other operating expenses', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-IS', '7', null, 'Finance costs', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-IS', '8', null, 'Profit before tax', '{}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('ZM-ZICA-IS', '9', null, 'Income tax expense', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-IS', '10', null, 'Profit for the year', '{}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, null, null),
  ('ZM-ZICA-SFP', 'CA', null, 'Current assets', '{}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5', 'CA.6']::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'CA.1', null, 'Cash and cash equivalents', '{}'::jsonb, 11, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'CA.2', null, 'Trade and other receivables', '{}'::jsonb, 12, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'CA.3', null, 'Inventories', '{}'::jsonb, 13, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'CA.4', null, 'Financial assets', '{}'::jsonb, 14, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'CA.5', null, 'Current tax recoverable', '{}'::jsonb, 15, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'CA.6', null, 'Prepayments and accrued income', '{}'::jsonb, 16, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'NCA', null, 'Non-current assets', '{}'::jsonb, 20, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4', 'NCA.5', 'NCA.6', 'NCA.7']::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'NCA.1', null, 'Property, plant and equipment', '{}'::jsonb, 21, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'NCA.2', null, 'Investment property', '{}'::jsonb, 22, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'NCA.3', null, 'Intangible assets', '{}'::jsonb, 23, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'NCA.4', null, 'Investments in associates', '{}'::jsonb, 24, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'NCA.5', null, 'Investments in joint ventures', '{}'::jsonb, 25, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'NCA.6', null, 'Financial assets', '{}'::jsonb, 26, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'NCA.7', null, 'Deferred tax assets', '{}'::jsonb, 27, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'TA', null, 'Total assets', '{}'::jsonb, 30, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'CL', null, 'Current liabilities', '{}'::jsonb, 40, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4', 'CL.5']::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'CL.1', null, 'Trade and other payables', '{}'::jsonb, 41, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'CL.2', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 42, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'CL.3', null, 'Amounts due to directors', '{}'::jsonb, 43, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'CL.4', null, 'Current tax payable', '{}'::jsonb, 44, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'CL.5', null, 'Provisions', '{}'::jsonb, 45, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'NCL', null, 'Non-current liabilities', '{}'::jsonb, 50, 1, true, array['NCL.1', 'NCL.2', 'NCL.3']::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'NCL.1', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 51, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'NCL.2', null, 'Deferred tax liabilities', '{}'::jsonb, 52, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'NCL.3', null, 'Provisions', '{}'::jsonb, 53, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'TL', null, 'Total liabilities', '{}'::jsonb, 60, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'NA', null, 'Net assets', '{}'::jsonb, 70, 1, true, array['TA']::text[], array['TL']::text[], null, null, null),
  ('ZM-ZICA-SFP', 'EQ', null, 'Equity', '{}'::jsonb, 80, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'EQ.1', null, 'Share capital', '{}'::jsonb, 81, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'EQ.2', null, 'Other reserves', '{}'::jsonb, 82, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZM-ZICA-SFP', 'EQ.3', null, 'Retained earnings', '{}'::jsonb, 83, -1, false, '{}'::text[], '{}'::text[], null, null, null)
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
    ('ZM-ZICA-IS', '1', 10, 'code_range', '4000', '4030', null, 'any'),
    ('ZM-ZICA-IS', '2', 10, 'code_range', '4500', '4790', null, 'any'),
    ('ZM-ZICA-IS', '3', 10, 'code_range', '5000', '5100', null, 'any'),
    ('ZM-ZICA-IS', '4', 10, 'code_range', '6000', '6080', null, 'any'),
    ('ZM-ZICA-IS', '5', 10, 'code_range', '6200', '6220', null, 'any'),
    ('ZM-ZICA-IS', '6', 10, 'code_range', '6300', '6990', null, 'any'),
    ('ZM-ZICA-IS', '7', 10, 'code_range', '7000', '7030', null, 'any'),
    ('ZM-ZICA-IS', '9', 10, 'code_range', '8000', '8020', null, 'any'),
    ('ZM-ZICA-SFP', 'CA.1', 10, 'code_range', '1000', '1040', null, 'any'),
    ('ZM-ZICA-SFP', 'CA.2', 10, 'code_range', '1100', '1160', null, 'any'),
    ('ZM-ZICA-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('ZM-ZICA-SFP', 'CA.4', 10, 'account_code', '1300', null, null, 'any'),
    ('ZM-ZICA-SFP', 'CA.5', 10, 'account_code', '1350', null, null, 'any'),
    ('ZM-ZICA-SFP', 'CA.6', 10, 'code_range', '1400', '1410', null, 'any'),
    ('ZM-ZICA-SFP', 'NCA.1', 10, 'code_range', '1600', '1671', null, 'any'),
    ('ZM-ZICA-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('ZM-ZICA-SFP', 'NCA.3', 10, 'code_range', '1750', '1760', null, 'any'),
    ('ZM-ZICA-SFP', 'NCA.4', 10, 'account_code', '1800', null, null, 'any'),
    ('ZM-ZICA-SFP', 'NCA.5', 10, 'account_code', '1810', null, null, 'any'),
    ('ZM-ZICA-SFP', 'NCA.6', 10, 'code_range', '1830', '1840', null, 'any'),
    ('ZM-ZICA-SFP', 'NCA.7', 10, 'account_code', '1900', null, null, 'any'),
    ('ZM-ZICA-SFP', 'CL.1', 10, 'code_range', '2000', '2190', null, 'any'),
    ('ZM-ZICA-SFP', 'CL.1', 20, 'account_code', '2990', null, null, 'credit'),
    ('ZM-ZICA-SFP', 'CL.2', 10, 'code_range', '2200', '2240', null, 'any'),
    ('ZM-ZICA-SFP', 'CL.3', 10, 'account_code', '2250', null, null, 'any'),
    ('ZM-ZICA-SFP', 'CL.4', 10, 'account_code', '2300', null, null, 'any'),
    ('ZM-ZICA-SFP', 'CL.5', 10, 'code_range', '2350', '2360', null, 'any'),
    ('ZM-ZICA-SFP', 'NCL.1', 10, 'code_range', '2400', '2430', null, 'any'),
    ('ZM-ZICA-SFP', 'NCL.2', 10, 'account_code', '2500', null, null, 'any'),
    ('ZM-ZICA-SFP', 'NCL.3', 10, 'account_code', '2550', null, null, 'any'),
    ('ZM-ZICA-SFP', 'EQ.1', 10, 'code_range', '3000', '3010', null, 'any'),
    ('ZM-ZICA-SFP', 'EQ.2', 10, 'code_range', '3100', '3110', null, 'any'),
    ('ZM-ZICA-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('ZM', 'Zambia', '{}'::jsonb, array['en']::text[], 'ZMW', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, 'month'::declaration_period)
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
  numbering_legal_reference     = 'Value Added Tax Act, s. 18(3), as substituted by the Value Added Tax (Amendment) Act No. 27 of 2023 — input tax is claimed only against a tax invoice issued from a serially numbered invoice book, from an authorised computer package, from the approved invoicing system or with the contents the Commissioner-General''s administrative rule requires. Zambian law asks for a serial number and not for a series with no gap, which is why `numbering` is `sequential` and not `gapless_per_year`.',
  numbering_source_key          = 'practice-note-2024',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Value Added Tax Act, s. 13(2) and (5) — goods are supplied at the earliest of removal from the supplier''s premises or being made available, receipt of payment, and issue of a tax invoice; services at the earliest of receipt of payment, issue of a tax invoice and the time they are performed. That is a three-way earliest test and Ekwo''s closed vocabulary only expresses a two-way one; `earliest_of_delivery_or_payment` is the nearest value, and the gap — an invoice issued ahead of both delivery and payment, which s. 13 still makes the tax point — is recorded in docs/international.md.',
  tax_point_source_key          = 'vat-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No Zambian statute obliges a business to exchange a structured electronic invoice with another business in the sense Ekwo''s vocabulary gives the word: there is no Peppol authority, no published profile and no scheme a party is addressed by, so `profile`, `party_scheme` and `vat_scheme` are null and `obligation` is `none`. What Zambia has instead is Smart Invoice, a clearance system run by the Zambia Revenue Authority: the Value Added Tax (Amendment) Act No. 27 of 2023, in force on 1 January 2024, defines the electronic invoicing system as a core system that transmits production, invoicing and stock data to the Authority in real time, and s. 7A(3) of the Value Added Tax Act punishes a taxpayer who does not issue electronic invoices (not more than K40,000 for a first offence, K80,000 for a second, K120,000 or imprisonment for a third). Smart Invoice has applied to every VAT-registered taxpayer since 30 September 2024 and penalties run from 1 October 2024; the dates come from the Authority''s own announcements and trade commentary, not from a text this pack could open. Invoices must be issued, or integrated through a certified invoicing system and the Virtual Sales Data Controller, before they reach the buyer. That is real-time clearance with the tax administration and not a peer-to-peer exchange; the gap is recorded in docs/international.md and in this pack''s README, and the socle is not patched to fit it.',
  einvoice_source_key           = 'smart-invoice-faqs',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'ZM';
