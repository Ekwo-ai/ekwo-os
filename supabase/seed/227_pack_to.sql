-- Ekwo OS — Tonga: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/to at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build to`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Consumption Tax Act 2003 (Cap. 26.02, 2016 Revised Edition) — s. 2 (Consumption Tax period: one month from 1 October 2005), s. 5(3) (rate 15 %; exempt and zero-rated by Order), s. 6 (registration at TOP 100,000), s. 9 (time of supply), s. 11 (tax fraction), s. 15 (reverse charge on foreign services), s. 16 (A – B), s. 17 (input tax credits), s. 18–19 (invoices, credit and debit notes), s. 21–22 (return and payment within 28 days), s. 24 (carry forward and refund) (Government of Tonga)
--     https://tonga.tradeportal.org/media/ConsumptionTaxAct_2.pdf
--   Form CT206 — Consumption Tax Return (boxes 1 to 19: sales, CT collected, purchases, CT paid, credit brought forward, result; divisor 7.6667) (Government of Tonga — Ministry of Revenue and Customs)
--     https://www.revenue.gov.to/sites/default/files/inline-files/CT%20Return%202022.pdf
--   Consumption Tax Regulations (Cap. 26.02.1, 2012 Revised Edition) — the Orders-in-Council reproduced in its endnotes: GS 3B of 31 March 2005 (exempt supplies, zero-rated supplies, exempt imports) and the later Orders (Government of Tonga — Ministry of Revenue and Customs)
--     https://web.archive.org/web/20181029003442/http://www.revenue.gov.to/Resource.aspx?ID=1065
--   Consumption Tax Order 2013 — exempt imports and zero-rated supplies for fishing, pearl and aquaculture (Government of Tonga — Ministry of Revenue and Customs)
--     https://web.archive.org/web/20181029003442/http://www.revenue.gov.to/Resource.aspx?ID=1344
--   Consumption Tax registration form — application for registration (the Act requires it within 7 days of becoming liable) (Government of Tonga — Ministry of Revenue and Customs)
--     https://www.revenue.gov.to/sites/default/files/inline-files/CTRegistrationform%20%281%29_0_0.doc
--   Consumption Tax overview — 15 % since 1 April 2005, registration within 7 days, output tax less input tax, claims not allowed, CT on imports collected by Customs (worked example) (Government of Tonga — Ministry of Revenue and Customs)
--     https://www.revenue.gov.to/consumption-tax-overview
--   IAS 1 Presentation of Financial Statements — the statement of financial position and the statement of profit or loss, expenses analysed by nature; no Tonga text prescribing a layout or a chart of accounts was read (IFRS Foundation)
--     https://www.ifrs.org/issued-standards/list-of-standards/ias-1-presentation-of-financial-statements/
--   Ministry of Revenue and Customs — tax administration portal (forms, legislation, eTax for filing and paying online) (Government of Tonga — Ministry of Revenue and Customs)
--     https://www.revenue.gov.to/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('TO', 'Tonga', '0.1.0', date '2026-10-26', '20261023124650', 'community', null, null, 'cc3f6312d793207ad7fd35a8d3dba41841cf3723b215d4ed16e38d8add012e43', '[{"key":"ct-act","title":"Consumption Tax Act 2003 (Cap. 26.02, 2016 Revised Edition) — s. 2 (Consumption Tax period: one month from 1 October 2005), s. 5(3) (rate 15 %; exempt and zero-rated by Order), s. 6 (registration at TOP 100,000), s. 9 (time of supply), s. 11 (tax fraction), s. 15 (reverse charge on foreign services), s. 16 (A – B), s. 17 (input tax credits), s. 18–19 (invoices, credit and debit notes), s. 21–22 (return and payment within 28 days), s. 24 (carry forward and refund)","publisher":"Government of Tonga","url":"https://tonga.tradeportal.org/media/ConsumptionTaxAct_2.pdf","consulted_on":"2026-10-26","kind":"law"},{"key":"ct-206","title":"Form CT206 — Consumption Tax Return (boxes 1 to 19: sales, CT collected, purchases, CT paid, credit brought forward, result; divisor 7.6667)","publisher":"Government of Tonga — Ministry of Revenue and Customs","url":"https://www.revenue.gov.to/sites/default/files/inline-files/CT%20Return%202022.pdf","consulted_on":"2026-10-26","kind":"form"},{"key":"ct-regs","title":"Consumption Tax Regulations (Cap. 26.02.1, 2012 Revised Edition) — the Orders-in-Council reproduced in its endnotes: GS 3B of 31 March 2005 (exempt supplies, zero-rated supplies, exempt imports) and the later Orders","publisher":"Government of Tonga — Ministry of Revenue and Customs","url":"https://web.archive.org/web/20181029003442/http://www.revenue.gov.to/Resource.aspx?ID=1065","consulted_on":"2026-10-26","kind":"law"},{"key":"ct-order-2013","title":"Consumption Tax Order 2013 — exempt imports and zero-rated supplies for fishing, pearl and aquaculture","publisher":"Government of Tonga — Ministry of Revenue and Customs","url":"https://web.archive.org/web/20181029003442/http://www.revenue.gov.to/Resource.aspx?ID=1344","consulted_on":"2026-10-26","kind":"law"},{"key":"ct-registration","title":"Consumption Tax registration form — application for registration (the Act requires it within 7 days of becoming liable)","publisher":"Government of Tonga — Ministry of Revenue and Customs","url":"https://www.revenue.gov.to/sites/default/files/inline-files/CTRegistrationform%20%281%29_0_0.doc","consulted_on":"2026-10-26","kind":"form"},{"key":"ct-overview","title":"Consumption Tax overview — 15 % since 1 April 2005, registration within 7 days, output tax less input tax, claims not allowed, CT on imports collected by Customs (worked example)","publisher":"Government of Tonga — Ministry of Revenue and Customs","url":"https://www.revenue.gov.to/consumption-tax-overview","consulted_on":"2026-10-26","kind":"guidance"},{"key":"ias-1","title":"IAS 1 Presentation of Financial Statements — the statement of financial position and the statement of profit or loss, expenses analysed by nature; no Tonga text prescribing a layout or a chart of accounts was read","publisher":"IFRS Foundation","url":"https://www.ifrs.org/issued-standards/list-of-standards/ias-1-presentation-of-financial-statements/","consulted_on":"2026-10-26","kind":"guidance"},{"key":"tax-portal","title":"Ministry of Revenue and Customs — tax administration portal (forms, legislation, eTax for filing and paying online)","publisher":"Government of Tonga — Ministry of Revenue and Customs","url":"https://www.revenue.gov.to/","consulted_on":"2026-10-26","kind":"portal"}]'::jsonb)
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
  ('TO', 'default', 'Tonga reference chart of accounts', '{}'::jsonb, true, 'companies', array['TO-IFRS-IS', 'TO-IFRS-SFP']::text[], null, 'There is no legal chart of accounts in the texts read for Tonga, and no text read names a standard setter or a framework for company accounts. This chart is original: four digits, blocked so that each range reaches one line of the IFRS-style statements below (IAS 1, expenses by nature), with the accounts a Tonga trading company keeps — CT output and input tax, import CT owed to Customs, PAYE withheld, retirement fund contributions and withholding taxes payable.', 'ias-1')
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
  ('TO', 'default', '1000', 'Petty cash', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('TO', 'default', '1010', 'Current account — TOP', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('TO', 'default', '1020', 'Fixed deposits placed for three months or less', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('TO', 'default', '1030', 'Foreign currency account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('TO', 'default', '1040', 'Cash in transit — card and mobile-payment settlements', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('TO', 'default', '1100', 'Trade receivables', '{}'::jsonb, 'asset_receivable', true, null, 60),
  ('TO', 'default', '1110', 'Trade receivables — allowance for impairment', '{}'::jsonb, 'asset_current', false, null, 70),
  ('TO', 'default', '1120', 'Other receivables', '{}'::jsonb, 'asset_current', false, null, 80),
  ('TO', 'default', '1130', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 90),
  ('TO', 'default', '1140', 'Deposits paid', '{}'::jsonb, 'asset_current', false, null, 100),
  ('TO', 'default', '1150', 'CT input tax', '{}'::jsonb, 'asset_current', false, null, 110),
  ('TO', 'default', '1155', 'CT refundable by the Ministry of Revenue and Customs — net of a filed return', '{}'::jsonb, 'asset_current', true, null, 120),
  ('TO', 'default', '1160', 'Advances to staff', '{}'::jsonb, 'asset_current', false, null, 130),
  ('TO', 'default', '1200', 'Inventories — goods for resale', '{}'::jsonb, 'asset_current', false, null, 140),
  ('TO', 'default', '1210', 'Inventories — raw materials', '{}'::jsonb, 'asset_current', false, null, 150),
  ('TO', 'default', '1220', 'Inventories — work in progress', '{}'::jsonb, 'asset_current', false, null, 160),
  ('TO', 'default', '1230', 'Inventories — finished goods', '{}'::jsonb, 'asset_current', false, null, 170),
  ('TO', 'default', '1300', 'Short-term investments', '{}'::jsonb, 'asset_current', false, null, 180),
  ('TO', 'default', '1350', 'Current tax recoverable', '{}'::jsonb, 'asset_current', false, null, 190),
  ('TO', 'default', '1400', 'Prepayments', '{}'::jsonb, 'asset_prepayments', false, null, 200),
  ('TO', 'default', '1410', 'Accrued income', '{}'::jsonb, 'asset_prepayments', false, null, 210),
  ('TO', 'default', '1600', 'Land and buildings — cost', '{}'::jsonb, 'asset_fixed', false, null, 220),
  ('TO', 'default', '1601', 'Land and buildings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 230),
  ('TO', 'default', '1610', 'Leasehold improvements — cost', '{}'::jsonb, 'asset_fixed', false, null, 240),
  ('TO', 'default', '1611', 'Leasehold improvements — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 250),
  ('TO', 'default', '1620', 'Plant and machinery — cost', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('TO', 'default', '1621', 'Plant and machinery — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('TO', 'default', '1630', 'Office equipment — cost', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('TO', 'default', '1631', 'Office equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('TO', 'default', '1640', 'Computers — cost', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('TO', 'default', '1641', 'Computers — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('TO', 'default', '1650', 'Furniture and fittings — cost', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('TO', 'default', '1651', 'Furniture and fittings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('TO', 'default', '1660', 'Motor vehicles — cost', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('TO', 'default', '1661', 'Motor vehicles — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('TO', 'default', '1670', 'Right-of-use assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('TO', 'default', '1671', 'Right-of-use assets — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('TO', 'default', '1700', 'Investment property', '{}'::jsonb, 'asset_non_current', false, null, 380),
  ('TO', 'default', '1750', 'Intangible assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 390),
  ('TO', 'default', '1751', 'Intangible assets — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 400),
  ('TO', 'default', '1760', 'Goodwill', '{}'::jsonb, 'asset_fixed', false, null, 410),
  ('TO', 'default', '1800', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('TO', 'default', '1810', 'Investments in joint ventures', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('TO', 'default', '1830', 'Long-term financial assets', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('TO', 'default', '1840', 'Long-term deposits', '{}'::jsonb, 'asset_non_current', false, null, 450),
  ('TO', 'default', '1900', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('TO', 'default', '2000', 'Trade payables', '{}'::jsonb, 'liability_payable', true, null, 470),
  ('TO', 'default', '2010', 'Accrued expenses', '{}'::jsonb, 'liability_current', false, null, 480),
  ('TO', 'default', '2020', 'Other payables', '{}'::jsonb, 'liability_current', false, null, 490),
  ('TO', 'default', '2030', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 500),
  ('TO', 'default', '2040', 'Deposits received from customers', '{}'::jsonb, 'liability_current', false, null, 510),
  ('TO', 'default', '2100', 'CT output tax', '{}'::jsonb, 'liability_current', false, null, 520),
  ('TO', 'default', '2110', 'CT payable to the Ministry of Revenue and Customs — net of a filed return', '{}'::jsonb, 'liability_current', true, null, 530),
  ('TO', 'default', '2125', 'Import CT payable to Customs at the border', '{}'::jsonb, 'liability_current', false, null, 540),
  ('TO', 'default', '2126', 'CT on imported capital goods — held until paid', '{}'::jsonb, 'liability_current', false, null, 550),
  ('TO', 'default', '2140', 'PAYE (salary and wages tax) withheld and payable to the Ministry of Revenue and Customs and Customs', '{}'::jsonb, 'liability_current', false, null, 560),
  ('TO', 'default', '2150', 'Retirement fund contributions payable', '{}'::jsonb, 'liability_current', false, null, 570),
  ('TO', 'default', '2155', 'Excise duty payable', '{}'::jsonb, 'liability_current', false, null, 580),
  ('TO', 'default', '2160', 'Withholding taxes payable to the Ministry of Revenue and Customs', '{}'::jsonb, 'liability_current', false, null, 590),
  ('TO', 'default', '2165', 'Other statutory amounts payable', '{}'::jsonb, 'liability_current', false, null, 600),
  ('TO', 'default', '2180', 'Salaries payable', '{}'::jsonb, 'liability_current', false, null, 610),
  ('TO', 'default', '2190', 'Directors'' fees payable', '{}'::jsonb, 'liability_current', false, null, 620),
  ('TO', 'default', '2200', 'Bank overdraft', '{}'::jsonb, 'liability_current', false, null, 630),
  ('TO', 'default', '2210', 'Bank loans — current portion', '{}'::jsonb, 'liability_current', false, null, 640),
  ('TO', 'default', '2220', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 650),
  ('TO', 'default', '2230', 'Hire purchase — current portion', '{}'::jsonb, 'liability_current', false, null, 660),
  ('TO', 'default', '2240', 'Corporate credit card', '{}'::jsonb, 'liability_credit_card', false, null, 670),
  ('TO', 'default', '2250', 'Amounts due to directors', '{}'::jsonb, 'liability_current', false, null, 680),
  ('TO', 'default', '2300', 'Current tax payable', '{}'::jsonb, 'liability_current', false, null, 690),
  ('TO', 'default', '2350', 'Provision for unutilised leave', '{}'::jsonb, 'liability_current', false, null, 700),
  ('TO', 'default', '2360', 'Other provisions — current', '{}'::jsonb, 'liability_current', false, null, 710),
  ('TO', 'default', '2400', 'Bank loans — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 720),
  ('TO', 'default', '2410', 'Lease liabilities — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 730),
  ('TO', 'default', '2420', 'Hire purchase — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 740),
  ('TO', 'default', '2430', 'Loans from shareholders and directors — non-current', '{}'::jsonb, 'liability_non_current', false, null, 750),
  ('TO', 'default', '2500', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 760),
  ('TO', 'default', '2550', 'Provision for reinstatement costs', '{}'::jsonb, 'liability_non_current', false, null, 770),
  ('TO', 'default', '2990', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 780),
  ('TO', 'default', '3000', 'Share capital', '{}'::jsonb, 'equity', false, null, 790),
  ('TO', 'default', '3010', 'Treasury shares', '{}'::jsonb, 'equity', false, null, 800),
  ('TO', 'default', '3100', 'Other reserves', '{}'::jsonb, 'equity', false, null, 810),
  ('TO', 'default', '3110', 'Foreign currency translation reserve', '{}'::jsonb, 'equity', false, null, 820),
  ('TO', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 830),
  ('TO', 'default', '3210', 'Dividends paid', '{}'::jsonb, 'equity_retained', false, null, 840),
  ('TO', 'default', '4000', 'Sales of goods', '{}'::jsonb, 'income', false, null, 850),
  ('TO', 'default', '4010', 'Services rendered', '{}'::jsonb, 'income', false, null, 860),
  ('TO', 'default', '4020', 'Export sales of goods', '{}'::jsonb, 'income', false, null, 870),
  ('TO', 'default', '4030', 'Export of services', '{}'::jsonb, 'income', false, null, 880),
  ('TO', 'default', '4500', 'Interest income', '{}'::jsonb, 'income_other', false, null, 890),
  ('TO', 'default', '4510', 'Dividend income', '{}'::jsonb, 'income_other', false, null, 900),
  ('TO', 'default', '4520', 'Rental income', '{}'::jsonb, 'income_other', false, null, 910),
  ('TO', 'default', '4530', 'Government grants', '{}'::jsonb, 'income_other', false, null, 920),
  ('TO', 'default', '4700', 'Foreign exchange gains', '{}'::jsonb, 'income_other', false, null, 930),
  ('TO', 'default', '4750', 'Gain on disposal of property plant and equipment', '{}'::jsonb, 'income_other', false, null, 940),
  ('TO', 'default', '4790', 'Other income', '{}'::jsonb, 'income_other', false, null, 950),
  ('TO', 'default', '5000', 'Purchases of goods for resale', '{}'::jsonb, 'expense_direct_cost', false, null, 960),
  ('TO', 'default', '5010', 'Freight inwards and import duties', '{}'::jsonb, 'expense_direct_cost', false, null, 970),
  ('TO', 'default', '5020', 'Subcontract costs', '{}'::jsonb, 'expense_direct_cost', false, null, 980),
  ('TO', 'default', '5100', 'Changes in inventories', '{}'::jsonb, 'expense_direct_cost', false, null, 990),
  ('TO', 'default', '6000', 'Salaries and wages', '{}'::jsonb, 'expense', false, null, 1000),
  ('TO', 'default', '6010', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 1010),
  ('TO', 'default', '6020', 'Directors'' fees', '{}'::jsonb, 'expense', false, null, 1020),
  ('TO', 'default', '6030', 'Retirement fund contributions — employer', '{}'::jsonb, 'expense', false, null, 1030),
  ('TO', 'default', '6035', 'Staff training and welfare', '{}'::jsonb, 'expense', false, null, 1040),
  ('TO', 'default', '6040', 'Other statutory employment costs', '{}'::jsonb, 'expense', false, null, 1050),
  ('TO', 'default', '6050', 'Retirement gratuity and end-of-service benefits', '{}'::jsonb, 'expense', false, null, 1060),
  ('TO', 'default', '6060', 'Staff amenities', '{}'::jsonb, 'expense', false, null, 1070),
  ('TO', 'default', '6070', 'Staff medical expenses and insurance', '{}'::jsonb, 'expense', false, null, 1080),
  ('TO', 'default', '6080', 'Staff training', '{}'::jsonb, 'expense', false, null, 1090),
  ('TO', 'default', '6200', 'Depreciation of property plant and equipment', '{}'::jsonb, 'expense_depreciation', false, null, 1100),
  ('TO', 'default', '6210', 'Depreciation of right-of-use assets', '{}'::jsonb, 'expense_depreciation', false, null, 1110),
  ('TO', 'default', '6220', 'Amortisation of intangible assets', '{}'::jsonb, 'expense_depreciation', false, null, 1120),
  ('TO', 'default', '6300', 'Rent — short-term leases', '{}'::jsonb, 'expense', false, null, 1130),
  ('TO', 'default', '6310', 'Utilities', '{}'::jsonb, 'expense', false, null, 1140),
  ('TO', 'default', '6320', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 1150),
  ('TO', 'default', '6330', 'Cleaning and security services', '{}'::jsonb, 'expense', false, null, 1160),
  ('TO', 'default', '6340', 'Telephone and internet', '{}'::jsonb, 'expense', false, null, 1170),
  ('TO', 'default', '6350', 'Software subscriptions', '{}'::jsonb, 'expense', false, null, 1180),
  ('TO', 'default', '6360', 'Advertising and marketing', '{}'::jsonb, 'expense', false, null, 1190),
  ('TO', 'default', '6370', 'Travelling', '{}'::jsonb, 'expense', false, null, 1200),
  ('TO', 'default', '6380', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1210),
  ('TO', 'default', '6390', 'Entertainment', '{}'::jsonb, 'expense', false, null, 1220),
  ('TO', 'default', '6400', 'Subscriptions and memberships', '{}'::jsonb, 'expense', false, null, 1230),
  ('TO', 'default', '6410', 'Insurance', '{}'::jsonb, 'expense', false, null, 1240),
  ('TO', 'default', '6420', 'Professional fees', '{}'::jsonb, 'expense', false, null, 1250),
  ('TO', 'default', '6430', 'Audit fees', '{}'::jsonb, 'expense', false, null, 1260),
  ('TO', 'default', '6440', 'Company secretarial and registration fees', '{}'::jsonb, 'expense', false, null, 1270),
  ('TO', 'default', '6450', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1280),
  ('TO', 'default', '6455', 'Donations', '{}'::jsonb, 'expense', false, null, 1290),
  ('TO', 'default', '6460', 'Printing and stationery', '{}'::jsonb, 'expense', false, null, 1300),
  ('TO', 'default', '6470', 'Postage and courier', '{}'::jsonb, 'expense', false, null, 1310),
  ('TO', 'default', '6480', 'Licences permits and local authority fees', '{}'::jsonb, 'expense', false, null, 1320),
  ('TO', 'default', '6490', 'Royalties', '{}'::jsonb, 'expense', false, null, 1330),
  ('TO', 'default', '6500', 'Bad debts written off', '{}'::jsonb, 'expense', false, null, 1340),
  ('TO', 'default', '6510', 'Impairment loss on trade receivables', '{}'::jsonb, 'expense', false, null, 1350),
  ('TO', 'default', '6900', 'Sponsorship', '{}'::jsonb, 'expense', false, null, 1360),
  ('TO', 'default', '6950', 'Foreign exchange losses', '{}'::jsonb, 'expense', false, null, 1370),
  ('TO', 'default', '6960', 'Loss on disposal of property plant and equipment', '{}'::jsonb, 'expense', false, null, 1380),
  ('TO', 'default', '6990', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1390),
  ('TO', 'default', '7000', 'Interest on bank loans', '{}'::jsonb, 'expense', false, null, 1400),
  ('TO', 'default', '7010', 'Interest on lease liabilities', '{}'::jsonb, 'expense', false, null, 1410),
  ('TO', 'default', '7020', 'Hire purchase interest', '{}'::jsonb, 'expense', false, null, 1420),
  ('TO', 'default', '7030', 'Interest on loans from related parties and others', '{}'::jsonb, 'expense', false, null, 1430),
  ('TO', 'default', '8000', 'Current income tax expense', '{}'::jsonb, 'expense', false, null, 1440),
  ('TO', 'default', '8010', 'Deferred tax expense', '{}'::jsonb, 'expense', false, null, 1450),
  ('TO', 'default', '8020', 'Under or over provision of income tax in prior years', '{}'::jsonb, 'expense', false, null, 1460)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('TO', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('TO', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('TO', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('TO', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('TO', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('TO', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('TO', 'TO-P-0', 'Purchase, no CT', '{}'::jsonb, 'A purchase from a supplier who charged no CT — exempt, unregistered or outside Tonga', 'percent', 0, 'purchase', 'exempt', date '2005-10-01', null, 'Form CT206, boxes 11 to 15 — only the CT actually paid on taxable supplies purchased is declared; a purchase that carries no CT appears on no line of the return. The Act allows no credit for CT that was not charged (s. 17(2)).', null, null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ct-206', null, null, null, null),
  ('TO', 'TO-P-15', 'Purchase, standard rate 15 %', '{}'::jsonb, 'Goods or services bought in Tonga from a registered person for the enterprise, with a Consumption Tax invoice', 'percent', 15, 'purchase', 'domestic', date '2005-10-01', null, 'Consumption Tax Act 2003, s. 17 — a taxable person may claim a credit for the input tax paid on a taxable supply to the person, in the period in which the person holds the Consumption Tax invoice (s. 17(7)); s. 17(4) and (5) refuse the credit for a passenger vehicle, petroleum products not used wholly in the business, entertainment, and what serves exempt or private use. Form CT206: box 11 is the total taxable supplies purchased, CT included, excluding CT paid to Customs; box 12 is box 11 divided by 7.6667. The engine posts the exclusive base to box 11a, which is not a box of the form, and the CT to box 12. The apportionment is the preparer''s.', 'S', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ct-206', null, null, null, null),
  ('TO', 'TO-P-15-NC', 'Purchase, standard rate 15 % — no input credit', '{}'::jsonb, 'A purchase carrying 15 % CT that gives no input credit — a passenger vehicle, entertainment, or goods bought for exempt supplies or private use', 'percent', 15, 'purchase', 'domestic', date '2005-10-01', null, 'Consumption Tax Act 2003, s. 17(4) and (5) — no credit for a passenger vehicle (unless the person deals in or hires such vehicles), for petroleum products not used wholly in the business, for entertainment, or to the extent that the supply is used to make exempt supplies or for private purposes. The CT joins the cost and no box of the return receives the purchase. Which purchases are barred is the preparer''s judgement.', 'S', null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ct-act', null, null, null, null),
  ('TO', 'TO-P-IMP', 'Purchase, import of goods', '{}'::jsonb, 'Goods imported into Tonga, CT paid to Customs at the border', 'percent', 15, 'purchase', 'import', date '2005-10-01', null, 'Consumption Tax Act 2003, s. 22(2) and s. 23 — CT on a taxable import is payable by the importer at the time of import, collected by Customs with the duties; the value on which it is levied is the customs value plus insurance and freight, customs duty and other charges (the Ministry''s worked example: 1,370.00 × 15 % = 205.50). Form CT206, box 13: CT paid to Customs; box 11 excludes it. The import value is posted to box 13a, which is not a box of the form. The CT owed to Customs sits on the import control account until paid.', null, null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ct-206', null, null, null, null),
  ('TO', 'TO-S-15', 'Sale, standard rate 15 %', '{}'::jsonb, 'A taxable supply of goods or services made in Tonga by a registered person, neither zero-rated nor exempt', 'percent', 15, 'sale', 'domestic', date '2005-10-01', null, 'Consumption Tax Act 2003, s. 5(3)(a) — the rate of Consumption Tax is 15 per cent; s. 5(1) and s. 11 — the value of a supply is the consideration, and a price without a separate CT amount is reduced by the tax fraction r/(100+r). Form CT206: box 5 is the total taxable supplies including CT, box 6 the zero-rated supplies included in it, box 7 the difference (taxable supplies, CT included) and box 8 the CT collected, box 7 divided by 7.6667 (15/115). The engine posts the exclusive base to box 7a, which is not a box of the form, and the CT to box 8.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ct-act', null, null, null, null),
  ('TO', 'TO-S-EX', 'Sale, exempt', '{}'::jsonb, 'A supply the Orders exempt — health, dental and nursing services, education, financial services, public transport, residential land lease', 'percent', 0, 'sale', 'exempt', date '2005-10-01', null, 'Consumption Tax Order-in-Council GS 3B of 31 March 2005, Order 1 — exempt supplies: (a) medical prescription, dental, nursing or health services, (b) education services, (c) financial services, (d) public transport services, (e) lease of land for residential purposes; Consumption Tax Act 2003, s. 5(3)(a). An exempt supply is not a taxable supply and carries no input credit (s. 17(5)). Form CT206 prints a line for exempt sales without a box number and says not to include them in box 5 or 6: the pack posts them to no box.', 'E', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ct-regs', null, null, null, null),
  ('TO', 'TO-S-ZR', 'Sale, zero-rated (other)', '{}'::jsonb, 'A zero-rated supply made in Tonga that is not an export — international transport, a going concern transferred between registered persons, domestic electricity, the first 20 cubic metres of water a month, fishing and aquaculture supplies', 'percent', 0, 'sale', 'domestic', date '2005-10-01', null, 'Consumption Tax Order-in-Council GS 3B of 31 March 2005, Order 2(c) to (f) — zero rate for international transport of goods or passengers, the transfer of a business as a going concern between registered persons (with the written agreement and notice the Order requires), electricity supplied for domestic purposes and the first 20 cubic metres of water a month for domestic purposes; the Order of 2005 as added also zero-rates supplies to His Majesty the King and electricity for commercial use; the Consumption Tax Order 2013, Order 3, zero-rates fishing vessels and gear, fuel for registered vessels and aquaculture materials within its provisos. One tax code carries the lists; which item applies is the preparer''s judgement, and the Orders in force today were not all read (see the README). Box 6 of form CT206.', 'Z', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ct-regs', null, null, null, null),
  ('TO', 'TO-S-ZR-EXP', 'Sale, zero-rated (export)', '{}'::jsonb, 'An export of goods or of services supplied for use outside Tonga, taxable at 0 %', 'percent', 0, 'sale', 'export', date '2005-10-01', null, 'Consumption Tax Order-in-Council GS 3B of 31 March 2005 (reproduced in the Consumption Tax Regulations), Order 2(a) and (b) — an export of goods and an export of services supplied for use outside Tonga are subject to the zero rate of Consumption Tax, under Consumption Tax Act 2003 s. 5(3)(a). Zero-rated supplies are box 6 of form CT206, included in box 5. A zero-rated supply keeps the input credit.', 'G', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ct-regs', null, null, null, null)
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
    ('TO-P-15', 'invoice', 'base', 100, null, '11a', array['11a']::text[], 100, 'TO-CT', 10),
    ('TO-P-15', 'invoice', 'tax', 100, '1150', '12', array['12']::text[], 100, 'TO-CT', 20),
    ('TO-P-15', 'credit_note', 'base', 100, null, '11a', array['11a']::text[], -100, 'TO-CT', 10),
    ('TO-P-15', 'credit_note', 'tax', 100, '1150', '12', array['12']::text[], -100, 'TO-CT', 20),
    ('TO-P-15-NC', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('TO-P-15-NC', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('TO-P-IMP', 'invoice', 'base', 100, null, '13a', array['13a']::text[], 100, 'TO-CT', 10),
    ('TO-P-IMP', 'invoice', 'tax', 100, '1150', '13', array['13']::text[], 100, 'TO-CT', 20),
    ('TO-P-IMP', 'invoice', 'tax', -100, '2125', null, null, 100, null, 30),
    ('TO-P-IMP', 'credit_note', 'base', 100, null, '13a', array['13a']::text[], -100, 'TO-CT', 10),
    ('TO-P-IMP', 'credit_note', 'tax', 100, '1150', '13', array['13']::text[], -100, 'TO-CT', 20),
    ('TO-P-IMP', 'credit_note', 'tax', -100, '2125', null, null, 100, null, 30),
    ('TO-S-15', 'invoice', 'base', 100, null, '7a', array['7a']::text[], 100, 'TO-CT', 10),
    ('TO-S-15', 'invoice', 'tax', 100, '2100', '8', array['8']::text[], 100, 'TO-CT', 20),
    ('TO-S-15', 'credit_note', 'base', 100, null, '7a', array['7a']::text[], -100, 'TO-CT', 10),
    ('TO-S-15', 'credit_note', 'tax', 100, '2100', '8', array['8']::text[], -100, 'TO-CT', 20),
    ('TO-S-ZR', 'invoice', 'base', 100, null, '6', array['6']::text[], 100, 'TO-CT', 10),
    ('TO-S-ZR', 'credit_note', 'base', 100, null, '6', array['6']::text[], -100, 'TO-CT', 10),
    ('TO-S-ZR-EXP', 'invoice', 'base', 100, null, '6', array['6']::text[], 100, 'TO-CT', 10),
    ('TO-S-ZR-EXP', 'credit_note', 'base', 100, null, '6', array['6']::text[], -100, 'TO-CT', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'TO' and t.code = v.tax_code
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
  ('TO', 'TO-CT', 'Consumption Tax return (form CT206)', array['month']::declaration_period[], 'month'::declaration_period, date '2005-10-01', null, 'Form CT206, Consumption Tax Return (Consumption Tax Act 2003), filed for a Consumption Tax period of one month (s. 2, from 1 October 2005): boxes 1 to 4 are the identity and the period, boxes 5 to 10 the sales and the CT collected, boxes 11 to 15 the purchases and the CT paid, boxes 16 to 18 the credit brought forward and the result. The form is CT-inclusive: boxes 5, 7 and 11 are totals here (exclusive base plus CT) and the exclusive figures sit in boxes 7a and 11a. Box 18 is signed: negative is the credit. The form also prints a line for exempt sales, without a number, outside boxes 5 and 6; the pack posts none.', true,'day_of_month_after_period'::filing_deadline_rule, 28, null, 'Consumption Tax Act 2003, s. 21(1) — a taxable person lodges the return for each Consumption Tax period within 28 days after the end of the period, and s. 22(1) makes the CT payable by the same date. A month ends on the 28th to the 31st, so 28 days after the end is the 28th of the following month in every case.', 'ct-act', null)
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
  ('TO', 'TO-CT', '5', 'total', 'Box 5 — Total taxable supplies made for the period, CT included', '{}'::jsonb, 50, null, array['6', '7']::text[], '{}'::text[], null, null, false, false, null, 'Form CT206, Consumption Tax Return, box 5 — total taxable supplies made for the period including CT, zero-rated supplies included. Here boxes 6 and 7 added.', 'ct-206'),
  ('TO', 'TO-CT', '6', 'base', 'Box 6 — Zero-rated supplies included in box 5', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form CT206, Consumption Tax Return, box 6 — zero-rated supplies included in box 5: exports and the other supplies the Orders put at the zero rate (Consumption Tax Act 2003, s. 5(3)(a)).', 'ct-206'),
  ('TO', 'TO-CT', '7', 'total', 'Box 7 — Taxable supplies at 15 % (box 5 less box 6), CT included', '{}'::jsonb, 70, null, array['7a:base', '8:tax']::text[], '{}'::text[], null, null, false, false, null, 'Form CT206, Consumption Tax Return, box 7 — box 5 minus box 6. Here the exclusive base of box 7a plus the CT of box 8.', 'ct-206'),
  ('TO', 'TO-CT', '7a', 'base', 'Box 7a — Taxable supplies at 15 %, CT excluded', '{}'::jsonb, 75, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Not a box of the form: the exclusive value of the taxable sales of box 7, which the engine posts and from which box 7 is rebuilt.', 'ct-206'),
  ('TO', 'TO-CT', '8', 'tax', 'Box 8 — CT collected (box 7 divided by 7.6667)', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form CT206, Consumption Tax Return, box 8 — divide box 7 by 7.6667, the tax fraction of 15 % (15/115). Consumption Tax Act 2003, s. 11(1): tax fraction r/(100+r).', 'ct-act'),
  ('TO', 'TO-CT', '9', 'tax', 'Box 9 — Tax adjustments (CT amount only), sales side', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form CT206, Consumption Tax Return, box 9 — tax adjustments, CT amount only (credit and debit notes outside the period, bad debts, private use). Declared and empty: a decision of the preparer, no tax code posts to it.', 'ct-206'),
  ('TO', 'TO-CT', '10', 'total', 'Box 10 — Total output tax (boxes 8 and 9)', '{}'::jsonb, 100, null, array['8', '9']::text[], '{}'::text[], null, null, false, false, null, 'Form CT206, Consumption Tax Return, box 10 — add boxes 8 and 9: total output tax.', 'ct-206'),
  ('TO', 'TO-CT', '11', 'total', 'Box 11 — Total taxable supplies purchased, CT included, excluding CT paid to Customs', '{}'::jsonb, 110, null, array['11a:base', '12:tax']::text[], '{}'::text[], null, null, false, false, null, 'Form CT206, Consumption Tax Return, box 11 — total taxable supplies purchased including CT, excluding CT paid to the Customs. Here the exclusive base of box 11a plus the CT of box 12.', 'ct-206'),
  ('TO', 'TO-CT', '11a', 'base', 'Box 11a — Local purchases carrying creditable CT, CT excluded', '{}'::jsonb, 115, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Not a box of the form: the exclusive value of the local purchases whose CT is posted to box 12.', 'ct-206'),
  ('TO', 'TO-CT', '12', 'tax', 'Box 12 — CT paid (box 11 divided by 7.6667)', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form CT206, Consumption Tax Return, box 12 — divide box 11 by 7.6667. Consumption Tax Act 2003, s. 17(1) and (7): the credit is claimed in the period in which the person holds the Consumption Tax invoice.', 'ct-act'),
  ('TO', 'TO-CT', '13', 'tax', 'Box 13 — CT paid to Customs', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form CT206, Consumption Tax Return, box 13 — add CT paid to Customs. The CT of imported goods is posted here; box 11 excludes it.', 'ct-206'),
  ('TO', 'TO-CT', '13a', 'base', 'Box 13a — Imports, value for CT', '{}'::jsonb, 135, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Not a box of the form: the value of the imported goods whose CT is posted to box 13; the form asks for the CT only.', 'ct-206'),
  ('TO', 'TO-CT', '14', 'tax', 'Box 14 — Tax adjustments (CT amount only), purchases side', '{}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form CT206, Consumption Tax Return, box 14 — add tax adjustments, CT amount only. Declared and empty: a decision of the preparer, no tax code posts to it.', 'ct-206'),
  ('TO', 'TO-CT', '15', 'total', 'Box 15 — Total input tax (boxes 12, 13 and 14)', '{}'::jsonb, 150, null, array['12', '13', '14']::text[], '{}'::text[], null, null, false, false, null, 'Form CT206, Consumption Tax Return, box 15 — add boxes 12, 13 and 14: total input tax.', 'ct-206'),
  ('TO', 'TO-CT', '16', 'tax', 'Box 16 — CT credit brought forward', '{}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form CT206, Consumption Tax Return, box 16 — CT credit brought forward, entered as a positive amount. Declared and empty: it is the preparer''s, from the previous return (Consumption Tax Act 2003, s. 24(1)(a): the excess is carried forward).', 'ct-206'),
  ('TO', 'TO-CT', '17', 'total', 'Box 17 — Total tax credit (boxes 15 and 16)', '{}'::jsonb, 170, null, array['15', '16']::text[], '{}'::text[], null, null, false, false, null, 'Form CT206, Consumption Tax Return, box 17 — add box 15 and box 16: total tax credit.', 'ct-206'),
  ('TO', 'TO-CT', '18', 'total', 'Box 18 — CT to pay (positive) or CT credit (negative), box 10 less box 17', '{}'::jsonb, 180, null, array['10']::text[], array['17']::text[], null, null, false, false, null, 'Form CT206, Consumption Tax Return, box 18 — the difference between box 10 and box 17: if box 17 is larger the difference is the CT credit, if box 10 is larger it is the CT to pay. Consumption Tax Act 2003, s. 16, formula A – B. Signed: negative is the credit; the CT is payable by the filing date (s. 22(1)).', 'ct-act')
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
  ('TO-IFRS-IS', 'TO', 'default', 'Statement of profit or loss', 'income_statement', 'IFRS', date '2024-01-01', null, 'IAS 1 asks for a statement of financial position and a statement of profit or loss; expenses are analysed by nature, which these lines follow. No Tonga text prescribing a layout of the statements was found, so the statement is presented as IFRS-style on the pack''s own chart.', 'ias-1', null, null, '{}'::jsonb),
  ('TO-IFRS-SFP', 'TO', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS', date '2024-01-01', null, 'IAS 1 asks for a statement of financial position and a statement of profit or loss; expenses are analysed by nature, which these lines follow. No Tonga text prescribing a layout of the statements was found, so the statement is presented as IFRS-style on the pack''s own chart.', 'ias-1', 'combined', 'Result of the current financial year', '{}'::jsonb)
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
  ('TO-IFRS-IS', '1', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-IS', '2', null, 'Other income', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-IS', '3', null, 'Purchases and changes in inventories', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-IS', '4', null, 'Employee benefits expense', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-IS', '5', null, 'Depreciation and amortisation', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-IS', '6', null, 'Other operating expenses', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-IS', '7', null, 'Finance costs', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-IS', '8', null, 'Profit before tax', '{}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('TO-IFRS-IS', '9', null, 'Income tax expense', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-IS', '10', null, 'Profit for the year', '{}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, null, null),
  ('TO-IFRS-SFP', 'CA', null, 'Current assets', '{}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5', 'CA.6']::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'CA.1', null, 'Cash and cash equivalents', '{}'::jsonb, 11, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'CA.2', null, 'Trade and other receivables', '{}'::jsonb, 12, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'CA.3', null, 'Inventories', '{}'::jsonb, 13, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'CA.4', null, 'Financial assets', '{}'::jsonb, 14, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'CA.5', null, 'Current tax recoverable', '{}'::jsonb, 15, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'CA.6', null, 'Prepayments and accrued income', '{}'::jsonb, 16, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'NCA', null, 'Non-current assets', '{}'::jsonb, 20, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4', 'NCA.5', 'NCA.6', 'NCA.7']::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'NCA.1', null, 'Property, plant and equipment', '{}'::jsonb, 21, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'NCA.2', null, 'Investment property', '{}'::jsonb, 22, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'NCA.3', null, 'Intangible assets', '{}'::jsonb, 23, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'NCA.4', null, 'Investments in associates', '{}'::jsonb, 24, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'NCA.5', null, 'Investments in joint ventures', '{}'::jsonb, 25, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'NCA.6', null, 'Financial assets', '{}'::jsonb, 26, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'NCA.7', null, 'Deferred tax assets', '{}'::jsonb, 27, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'TA', null, 'Total assets', '{}'::jsonb, 30, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'CL', null, 'Current liabilities', '{}'::jsonb, 40, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4', 'CL.5']::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'CL.1', null, 'Trade and other payables', '{}'::jsonb, 41, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'CL.2', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 42, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'CL.3', null, 'Amounts due to directors', '{}'::jsonb, 43, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'CL.4', null, 'Current tax payable', '{}'::jsonb, 44, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'CL.5', null, 'Provisions', '{}'::jsonb, 45, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'NCL', null, 'Non-current liabilities', '{}'::jsonb, 50, 1, true, array['NCL.1', 'NCL.2', 'NCL.3']::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'NCL.1', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 51, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'NCL.2', null, 'Deferred tax liabilities', '{}'::jsonb, 52, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'NCL.3', null, 'Provisions', '{}'::jsonb, 53, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'TL', null, 'Total liabilities', '{}'::jsonb, 60, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'NA', null, 'Net assets', '{}'::jsonb, 70, 1, true, array['TA']::text[], array['TL']::text[], null, null, null),
  ('TO-IFRS-SFP', 'EQ', null, 'Equity', '{}'::jsonb, 80, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'EQ.1', null, 'Share capital', '{}'::jsonb, 81, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'EQ.2', null, 'Other reserves', '{}'::jsonb, 82, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TO-IFRS-SFP', 'EQ.3', null, 'Retained earnings', '{}'::jsonb, 83, -1, false, '{}'::text[], '{}'::text[], null, null, null)
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
 where r.statement_code in ('TO-IFRS-IS', 'TO-IFRS-SFP')
   and (r.statement_code, r.line_code, r.sequence) not in (
     values ('TO-IFRS-IS', '1', 10),
            ('TO-IFRS-IS', '2', 10),
            ('TO-IFRS-IS', '3', 10),
            ('TO-IFRS-IS', '4', 10),
            ('TO-IFRS-IS', '5', 10),
            ('TO-IFRS-IS', '6', 10),
            ('TO-IFRS-IS', '7', 10),
            ('TO-IFRS-IS', '9', 10),
            ('TO-IFRS-SFP', 'CA.1', 10),
            ('TO-IFRS-SFP', 'CA.2', 10),
            ('TO-IFRS-SFP', 'CA.3', 10),
            ('TO-IFRS-SFP', 'CA.4', 10),
            ('TO-IFRS-SFP', 'CA.5', 10),
            ('TO-IFRS-SFP', 'CA.6', 10),
            ('TO-IFRS-SFP', 'NCA.1', 10),
            ('TO-IFRS-SFP', 'NCA.2', 10),
            ('TO-IFRS-SFP', 'NCA.3', 10),
            ('TO-IFRS-SFP', 'NCA.4', 10),
            ('TO-IFRS-SFP', 'NCA.5', 10),
            ('TO-IFRS-SFP', 'NCA.6', 10),
            ('TO-IFRS-SFP', 'NCA.7', 10),
            ('TO-IFRS-SFP', 'CL.1', 10),
            ('TO-IFRS-SFP', 'CL.1', 20),
            ('TO-IFRS-SFP', 'CL.2', 10),
            ('TO-IFRS-SFP', 'CL.3', 10),
            ('TO-IFRS-SFP', 'CL.4', 10),
            ('TO-IFRS-SFP', 'CL.5', 10),
            ('TO-IFRS-SFP', 'NCL.1', 10),
            ('TO-IFRS-SFP', 'NCL.2', 10),
            ('TO-IFRS-SFP', 'NCL.3', 10),
            ('TO-IFRS-SFP', 'EQ.1', 10),
            ('TO-IFRS-SFP', 'EQ.2', 10),
            ('TO-IFRS-SFP', 'EQ.3', 10)
   );

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('TO-IFRS-IS', '1', 10, 'code_range', '4000', '4030', null, 'any'),
    ('TO-IFRS-IS', '2', 10, 'code_range', '4500', '4790', null, 'any'),
    ('TO-IFRS-IS', '3', 10, 'code_range', '5000', '5100', null, 'any'),
    ('TO-IFRS-IS', '4', 10, 'code_range', '6000', '6080', null, 'any'),
    ('TO-IFRS-IS', '5', 10, 'code_range', '6200', '6220', null, 'any'),
    ('TO-IFRS-IS', '6', 10, 'code_range', '6300', '6990', null, 'any'),
    ('TO-IFRS-IS', '7', 10, 'code_range', '7000', '7030', null, 'any'),
    ('TO-IFRS-IS', '9', 10, 'code_range', '8000', '8020', null, 'any'),
    ('TO-IFRS-SFP', 'CA.1', 10, 'code_range', '1000', '1040', null, 'any'),
    ('TO-IFRS-SFP', 'CA.2', 10, 'code_range', '1100', '1160', null, 'any'),
    ('TO-IFRS-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('TO-IFRS-SFP', 'CA.4', 10, 'account_code', '1300', null, null, 'any'),
    ('TO-IFRS-SFP', 'CA.5', 10, 'account_code', '1350', null, null, 'any'),
    ('TO-IFRS-SFP', 'CA.6', 10, 'code_range', '1400', '1410', null, 'any'),
    ('TO-IFRS-SFP', 'NCA.1', 10, 'code_range', '1600', '1671', null, 'any'),
    ('TO-IFRS-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('TO-IFRS-SFP', 'NCA.3', 10, 'code_range', '1750', '1760', null, 'any'),
    ('TO-IFRS-SFP', 'NCA.4', 10, 'account_code', '1800', null, null, 'any'),
    ('TO-IFRS-SFP', 'NCA.5', 10, 'account_code', '1810', null, null, 'any'),
    ('TO-IFRS-SFP', 'NCA.6', 10, 'code_range', '1830', '1840', null, 'any'),
    ('TO-IFRS-SFP', 'NCA.7', 10, 'account_code', '1900', null, null, 'any'),
    ('TO-IFRS-SFP', 'CL.1', 10, 'code_range', '2000', '2190', null, 'any'),
    ('TO-IFRS-SFP', 'CL.1', 20, 'account_code', '2990', null, null, 'credit'),
    ('TO-IFRS-SFP', 'CL.2', 10, 'code_range', '2200', '2240', null, 'any'),
    ('TO-IFRS-SFP', 'CL.3', 10, 'account_code', '2250', null, null, 'any'),
    ('TO-IFRS-SFP', 'CL.4', 10, 'account_code', '2300', null, null, 'any'),
    ('TO-IFRS-SFP', 'CL.5', 10, 'code_range', '2350', '2360', null, 'any'),
    ('TO-IFRS-SFP', 'NCL.1', 10, 'code_range', '2400', '2430', null, 'any'),
    ('TO-IFRS-SFP', 'NCL.2', 10, 'account_code', '2500', null, null, 'any'),
    ('TO-IFRS-SFP', 'NCL.3', 10, 'account_code', '2550', null, null, 'any'),
    ('TO-IFRS-SFP', 'EQ.1', 10, 'code_range', '3000', '3010', null, 'any'),
    ('TO-IFRS-SFP', 'EQ.2', 10, 'code_range', '3100', '3110', null, 'any'),
    ('TO-IFRS-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('TO', 'Tonga', '{}'::jsonb, array['en']::text[], 'WST', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, 'month'::declaration_period)
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
  numbering_legal_reference     = 'Consumption Tax Act 2003, s. 18(1)–(2) — a registered person making a taxable supply to another registered person issues the original Consumption Tax invoice at the time of the supply, bearing the words CONSUMPTION TAX INVOICE and an individualised serial number; s. 19 does the same for credit and debit notes. The text read states no numbering sequence rule, so numbering is `free`; the number format is a convention of this pack.',
  numbering_source_key          = 'ct-act',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'Consumption Tax Act 2003, s. 9(1) — a supply occurs on the earlier of the date the invoice for the supply is issued and the date any payment, part payment included, is made. `invoice_if_issued` states the invoice as the point of the tax where one is issued; a payment received before the invoice brings the supply forward, which the engine does not model for a cash-first sale (see the README). Section 17(7) allows the input tax credit in the period in which the person holds the Consumption Tax invoice (or the customs entry), which the engine follows by the date of the purchase.',
  tax_point_source_key          = 'ct-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'The Revenue Services Administration (Electronic Sales Register System) Regulations 2022, listed on the Ministry''s legislation page, regulate electronic sales registers; their text was not read. No structured e-invoice standard or Peppol profile was found, so `obligation` is `none` for a business-to-business e-invoice; the electronic sales register is not modelled (see the README).',
  einvoice_source_key           = 'tax-portal',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'TO';

update country_defaults set
  tax_payee_name       = 'Tonga Ministry of Revenue and Customs',
  tax_payee_source_key = 'tax-portal'
 where country = 'TO';
