-- Ekwo OS — Solomon Islands: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/sb at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build sb`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Goods Tax Act (Cap. 122), reprint authorised by the Attorney General under the Legislation Act 2023 — Part VII section 38 (returns within thirty days), section 42 (payment within thirty days, sixty for a credit sale), section 47 (refunds), Part XI section 69 (tax imposed on the sale value at the rate of the Second Schedule), section 75 (goods tax stated on the invoice), the exempt goods of the First Schedule and the Second Schedule (Solomon Islands Government — Inland Revenue Division)
--     https://www.ird.gov.sb/wp-content/uploads/2025/10/GOODS-TAX-ACT-CAP-122.pdf
--   Goods Tax (Second Schedule) (Amendment) Order 2019, Legal Notice 73 of 28 August 2019 — the Second Schedule substituted: imported goods 15 %, prescribed locally manufactured goods 10 %, rice 5 % (Solomon Islands Government — Inland Revenue Division)
--     https://www.ird.gov.sb/wp-content/uploads/2025/10/Goods-Tax-Second-Schedule-Amendment-Order-2019.pdf
--   Sales Tax Act (Cap. 125), reprint authorised by the Attorney General under the Legislation Act 2023 — section 3 (the purchaser is charged the tax), section 13 (the vendor is the collector), section 14 (collected at the sale, remitted with the returns within thirty days after the end of the month), section 15 (returns), section 17 (liability, due on the 30th of the following month) and Schedule One (prescribed goods and services and their rates) (Solomon Islands Government — Inland Revenue Division)
--     https://www.ird.gov.sb/wp-content/uploads/2025/10/SALE-TAX-ACT-CAP-125.pdf
--   Goods Tax Return, form GT4 (formerly GT3, revised August 2025) — total sales of goods, less exempt goods, less rice taxed at 0 %, taxable sales, locally manufactured goods at 10 %, imported goods at 15 %, total goods tax payable; due within 30 days of the end of the month of the sales; and its instructions GTI 2 with the determination of sale value (Solomon Islands Government — Inland Revenue Division)
--     https://www.ird.gov.sb/wp-content/uploads/2025/10/Goods-Tax-return-August-2025.pdf
--   Sales Tax Return, form ST4 (formerly ST3, revised August 2025) — one line per type of sale: amount of sales, rate, sales tax payable; total sales and total sales tax payable; due within 30 days of the end of the month of the sales; and its instructions STI 2 with the schedule of goods and services subject to sales tax (Solomon Islands Government — Inland Revenue Division)
--     https://www.ird.gov.sb/wp-content/uploads/2025/10/Sales-Tax-return-August-2025.pdf
--   Instructions to complete the Sales Tax Return (STI 2, revised August 2025) — the schedule of the goods and services subject to sales tax: petroleum and diesel at 10 cents a litre, fourteen services at 10 %, six items at an amount per unit (Solomon Islands Government — Inland Revenue Division)
--     https://www.ird.gov.sb/wp-content/uploads/2025/10/Sales-Tax-Return-instructions-August-2025.pdf
--   IAS 1 Presentation of Financial Statements — the statement of financial position and the statement of profit or loss, expenses analysed by nature; no Solomon Islands text prescribing a layout or a chart of accounts was read (IFRS Foundation)
--     https://www.ifrs.org/issued-standards/list-of-standards/ias-1-presentation-of-financial-statements/
--   Inland Revenue Division — tax administration portal (Goods Tax and Sales Tax pages, forms and publications, tax legislation, the eTax service) (Solomon Islands Government — Inland Revenue Division)
--     https://www.ird.gov.sb/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('SB', 'Solomon Islands', '0.1.0', date '2026-10-26', '20261023124650', 'community', null, null, '6fb31736f1e512b2a04f2b58e0f13995debe68bc0c4244855cd950edeadff74d', '[{"key":"goods-tax-act","title":"Goods Tax Act (Cap. 122), reprint authorised by the Attorney General under the Legislation Act 2023 — Part VII section 38 (returns within thirty days), section 42 (payment within thirty days, sixty for a credit sale), section 47 (refunds), Part XI section 69 (tax imposed on the sale value at the rate of the Second Schedule), section 75 (goods tax stated on the invoice), the exempt goods of the First Schedule and the Second Schedule","publisher":"Solomon Islands Government — Inland Revenue Division","url":"https://www.ird.gov.sb/wp-content/uploads/2025/10/GOODS-TAX-ACT-CAP-122.pdf","consulted_on":"2026-10-26","kind":"law"},{"key":"gt-order-2019","title":"Goods Tax (Second Schedule) (Amendment) Order 2019, Legal Notice 73 of 28 August 2019 — the Second Schedule substituted: imported goods 15 %, prescribed locally manufactured goods 10 %, rice 5 %","publisher":"Solomon Islands Government — Inland Revenue Division","url":"https://www.ird.gov.sb/wp-content/uploads/2025/10/Goods-Tax-Second-Schedule-Amendment-Order-2019.pdf","consulted_on":"2026-10-26","kind":"law"},{"key":"sales-tax-act","title":"Sales Tax Act (Cap. 125), reprint authorised by the Attorney General under the Legislation Act 2023 — section 3 (the purchaser is charged the tax), section 13 (the vendor is the collector), section 14 (collected at the sale, remitted with the returns within thirty days after the end of the month), section 15 (returns), section 17 (liability, due on the 30th of the following month) and Schedule One (prescribed goods and services and their rates)","publisher":"Solomon Islands Government — Inland Revenue Division","url":"https://www.ird.gov.sb/wp-content/uploads/2025/10/SALE-TAX-ACT-CAP-125.pdf","consulted_on":"2026-10-26","kind":"law"},{"key":"gt4-form","title":"Goods Tax Return, form GT4 (formerly GT3, revised August 2025) — total sales of goods, less exempt goods, less rice taxed at 0 %, taxable sales, locally manufactured goods at 10 %, imported goods at 15 %, total goods tax payable; due within 30 days of the end of the month of the sales; and its instructions GTI 2 with the determination of sale value","publisher":"Solomon Islands Government — Inland Revenue Division","url":"https://www.ird.gov.sb/wp-content/uploads/2025/10/Goods-Tax-return-August-2025.pdf","consulted_on":"2026-10-26","kind":"form"},{"key":"st4-form","title":"Sales Tax Return, form ST4 (formerly ST3, revised August 2025) — one line per type of sale: amount of sales, rate, sales tax payable; total sales and total sales tax payable; due within 30 days of the end of the month of the sales; and its instructions STI 2 with the schedule of goods and services subject to sales tax","publisher":"Solomon Islands Government — Inland Revenue Division","url":"https://www.ird.gov.sb/wp-content/uploads/2025/10/Sales-Tax-return-August-2025.pdf","consulted_on":"2026-10-26","kind":"form"},{"key":"st-instructions","title":"Instructions to complete the Sales Tax Return (STI 2, revised August 2025) — the schedule of the goods and services subject to sales tax: petroleum and diesel at 10 cents a litre, fourteen services at 10 %, six items at an amount per unit","publisher":"Solomon Islands Government — Inland Revenue Division","url":"https://www.ird.gov.sb/wp-content/uploads/2025/10/Sales-Tax-Return-instructions-August-2025.pdf","consulted_on":"2026-10-26","kind":"guidance"},{"key":"ias-1","title":"IAS 1 Presentation of Financial Statements — the statement of financial position and the statement of profit or loss, expenses analysed by nature; no Solomon Islands text prescribing a layout or a chart of accounts was read","publisher":"IFRS Foundation","url":"https://www.ifrs.org/issued-standards/list-of-standards/ias-1-presentation-of-financial-statements/","consulted_on":"2026-10-26","kind":"guidance"},{"key":"tax-portal","title":"Inland Revenue Division — tax administration portal (Goods Tax and Sales Tax pages, forms and publications, tax legislation, the eTax service)","publisher":"Solomon Islands Government — Inland Revenue Division","url":"https://www.ird.gov.sb/","consulted_on":"2026-10-26","kind":"portal"}]'::jsonb)
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
  ('SB', 'default', 'Solomon Islands reference chart of accounts', '{}'::jsonb, true, 'companies', array['SB-IFRS-IS', 'SB-IFRS-SFP']::text[], null, 'There is no legal chart of accounts in the texts read for Solomon Islands, and no text read names a standard setter or a framework for company accounts. This chart is original: four digits, blocked so that each range reaches one line of the IFRS-style statements below (IAS 1, expenses by nature), with the accounts a Solomon Islands trading company keeps — goods tax and sales tax collected, the net amount payable to the Inland Revenue Division, PAYE withheld, National Provident Fund contributions and withholding taxes payable.', 'ias-1')
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
  ('SB', 'default', '1000', 'Petty cash', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('SB', 'default', '1010', 'Current account — SBD', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('SB', 'default', '1020', 'Fixed deposits placed for three months or less', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('SB', 'default', '1030', 'Foreign currency account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('SB', 'default', '1040', 'Cash in transit — card and mobile-payment settlements', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('SB', 'default', '1100', 'Trade receivables', '{}'::jsonb, 'asset_receivable', true, null, 60),
  ('SB', 'default', '1110', 'Trade receivables — allowance for impairment', '{}'::jsonb, 'asset_current', false, null, 70),
  ('SB', 'default', '1120', 'Other receivables', '{}'::jsonb, 'asset_current', false, null, 80),
  ('SB', 'default', '1130', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 90),
  ('SB', 'default', '1140', 'Deposits paid', '{}'::jsonb, 'asset_current', false, null, 100),
  ('SB', 'default', '1155', 'Goods tax and sales tax refundable by the IRD — net of a filed return', '{}'::jsonb, 'asset_current', true, null, 120),
  ('SB', 'default', '1160', 'Advances to staff', '{}'::jsonb, 'asset_current', false, null, 130),
  ('SB', 'default', '1200', 'Inventories — goods for resale', '{}'::jsonb, 'asset_current', false, null, 140),
  ('SB', 'default', '1210', 'Inventories — raw materials', '{}'::jsonb, 'asset_current', false, null, 150),
  ('SB', 'default', '1220', 'Inventories — work in progress', '{}'::jsonb, 'asset_current', false, null, 160),
  ('SB', 'default', '1230', 'Inventories — finished goods', '{}'::jsonb, 'asset_current', false, null, 170),
  ('SB', 'default', '1300', 'Short-term investments', '{}'::jsonb, 'asset_current', false, null, 180),
  ('SB', 'default', '1350', 'Current tax recoverable', '{}'::jsonb, 'asset_current', false, null, 190),
  ('SB', 'default', '1400', 'Prepayments', '{}'::jsonb, 'asset_prepayments', false, null, 200),
  ('SB', 'default', '1410', 'Accrued income', '{}'::jsonb, 'asset_prepayments', false, null, 210),
  ('SB', 'default', '1600', 'Land and buildings — cost', '{}'::jsonb, 'asset_fixed', false, null, 220),
  ('SB', 'default', '1601', 'Land and buildings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 230),
  ('SB', 'default', '1610', 'Leasehold improvements — cost', '{}'::jsonb, 'asset_fixed', false, null, 240),
  ('SB', 'default', '1611', 'Leasehold improvements — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 250),
  ('SB', 'default', '1620', 'Plant and machinery — cost', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('SB', 'default', '1621', 'Plant and machinery — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('SB', 'default', '1630', 'Office equipment — cost', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('SB', 'default', '1631', 'Office equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('SB', 'default', '1640', 'Computers — cost', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('SB', 'default', '1641', 'Computers — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('SB', 'default', '1650', 'Furniture and fittings — cost', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('SB', 'default', '1651', 'Furniture and fittings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('SB', 'default', '1660', 'Motor vehicles — cost', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('SB', 'default', '1661', 'Motor vehicles — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('SB', 'default', '1670', 'Right-of-use assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('SB', 'default', '1671', 'Right-of-use assets — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('SB', 'default', '1700', 'Investment property', '{}'::jsonb, 'asset_non_current', false, null, 380),
  ('SB', 'default', '1750', 'Intangible assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 390),
  ('SB', 'default', '1751', 'Intangible assets — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 400),
  ('SB', 'default', '1760', 'Goodwill', '{}'::jsonb, 'asset_fixed', false, null, 410),
  ('SB', 'default', '1800', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('SB', 'default', '1810', 'Investments in joint ventures', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('SB', 'default', '1830', 'Long-term financial assets', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('SB', 'default', '1840', 'Long-term deposits', '{}'::jsonb, 'asset_non_current', false, null, 450),
  ('SB', 'default', '1900', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('SB', 'default', '2000', 'Trade payables', '{}'::jsonb, 'liability_payable', true, null, 470),
  ('SB', 'default', '2010', 'Accrued expenses', '{}'::jsonb, 'liability_current', false, null, 480),
  ('SB', 'default', '2020', 'Other payables', '{}'::jsonb, 'liability_current', false, null, 490),
  ('SB', 'default', '2030', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 500),
  ('SB', 'default', '2040', 'Deposits received from customers', '{}'::jsonb, 'liability_current', false, null, 510),
  ('SB', 'default', '2100', 'Goods tax collected on wholesale sales', '{}'::jsonb, 'liability_current', false, null, 520),
  ('SB', 'default', '2105', 'Sales tax collected on prescribed services', '{}'::jsonb, 'liability_current', false, null, 525),
  ('SB', 'default', '2110', 'Goods tax and sales tax payable to the IRD — net of a filed return', '{}'::jsonb, 'liability_current', true, null, 530),
  ('SB', 'default', '2140', 'PAYE withheld and payable to the IRD', '{}'::jsonb, 'liability_current', false, null, 560),
  ('SB', 'default', '2150', 'National Provident Fund contributions payable', '{}'::jsonb, 'liability_current', false, null, 570),
  ('SB', 'default', '2155', 'Excise duty payable', '{}'::jsonb, 'liability_current', false, null, 580),
  ('SB', 'default', '2160', 'Withholding taxes payable to the IRD', '{}'::jsonb, 'liability_current', false, null, 590),
  ('SB', 'default', '2165', 'Other statutory amounts payable', '{}'::jsonb, 'liability_current', false, null, 600),
  ('SB', 'default', '2180', 'Salaries payable', '{}'::jsonb, 'liability_current', false, null, 610),
  ('SB', 'default', '2190', 'Directors'' fees payable', '{}'::jsonb, 'liability_current', false, null, 620),
  ('SB', 'default', '2200', 'Bank overdraft', '{}'::jsonb, 'liability_current', false, null, 630),
  ('SB', 'default', '2210', 'Bank loans — current portion', '{}'::jsonb, 'liability_current', false, null, 640),
  ('SB', 'default', '2220', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 650),
  ('SB', 'default', '2230', 'Hire purchase — current portion', '{}'::jsonb, 'liability_current', false, null, 660),
  ('SB', 'default', '2240', 'Corporate credit card', '{}'::jsonb, 'liability_credit_card', false, null, 670),
  ('SB', 'default', '2250', 'Amounts due to directors', '{}'::jsonb, 'liability_current', false, null, 680),
  ('SB', 'default', '2300', 'Current tax payable', '{}'::jsonb, 'liability_current', false, null, 690),
  ('SB', 'default', '2350', 'Provision for unutilised leave', '{}'::jsonb, 'liability_current', false, null, 700),
  ('SB', 'default', '2360', 'Other provisions — current', '{}'::jsonb, 'liability_current', false, null, 710),
  ('SB', 'default', '2400', 'Bank loans — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 720),
  ('SB', 'default', '2410', 'Lease liabilities — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 730),
  ('SB', 'default', '2420', 'Hire purchase — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 740),
  ('SB', 'default', '2430', 'Loans from shareholders and directors — non-current', '{}'::jsonb, 'liability_non_current', false, null, 750),
  ('SB', 'default', '2500', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 760),
  ('SB', 'default', '2550', 'Provision for reinstatement costs', '{}'::jsonb, 'liability_non_current', false, null, 770),
  ('SB', 'default', '2990', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 780),
  ('SB', 'default', '3000', 'Share capital', '{}'::jsonb, 'equity', false, null, 790),
  ('SB', 'default', '3010', 'Treasury shares', '{}'::jsonb, 'equity', false, null, 800),
  ('SB', 'default', '3100', 'Other reserves', '{}'::jsonb, 'equity', false, null, 810),
  ('SB', 'default', '3110', 'Foreign currency translation reserve', '{}'::jsonb, 'equity', false, null, 820),
  ('SB', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 830),
  ('SB', 'default', '3210', 'Dividends paid', '{}'::jsonb, 'equity_retained', false, null, 840),
  ('SB', 'default', '4000', 'Sales of goods', '{}'::jsonb, 'income', false, null, 850),
  ('SB', 'default', '4010', 'Services rendered', '{}'::jsonb, 'income', false, null, 860),
  ('SB', 'default', '4020', 'Export sales of goods', '{}'::jsonb, 'income', false, null, 870),
  ('SB', 'default', '4030', 'Export of services', '{}'::jsonb, 'income', false, null, 880),
  ('SB', 'default', '4500', 'Interest income', '{}'::jsonb, 'income_other', false, null, 890),
  ('SB', 'default', '4510', 'Dividend income', '{}'::jsonb, 'income_other', false, null, 900),
  ('SB', 'default', '4520', 'Rental income', '{}'::jsonb, 'income_other', false, null, 910),
  ('SB', 'default', '4530', 'Government grants', '{}'::jsonb, 'income_other', false, null, 920),
  ('SB', 'default', '4700', 'Foreign exchange gains', '{}'::jsonb, 'income_other', false, null, 930),
  ('SB', 'default', '4750', 'Gain on disposal of property plant and equipment', '{}'::jsonb, 'income_other', false, null, 940),
  ('SB', 'default', '4790', 'Other income', '{}'::jsonb, 'income_other', false, null, 950),
  ('SB', 'default', '5000', 'Purchases of goods for resale', '{}'::jsonb, 'expense_direct_cost', false, null, 960),
  ('SB', 'default', '5010', 'Freight inwards and import duties', '{}'::jsonb, 'expense_direct_cost', false, null, 970),
  ('SB', 'default', '5020', 'Subcontract costs', '{}'::jsonb, 'expense_direct_cost', false, null, 980),
  ('SB', 'default', '5100', 'Changes in inventories', '{}'::jsonb, 'expense_direct_cost', false, null, 990),
  ('SB', 'default', '6000', 'Salaries and wages', '{}'::jsonb, 'expense', false, null, 1000),
  ('SB', 'default', '6010', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 1010),
  ('SB', 'default', '6020', 'Directors'' fees', '{}'::jsonb, 'expense', false, null, 1020),
  ('SB', 'default', '6030', 'Superannuation contributions — employer', '{}'::jsonb, 'expense', false, null, 1030),
  ('SB', 'default', '6035', 'Staff training and welfare', '{}'::jsonb, 'expense', false, null, 1040),
  ('SB', 'default', '6040', 'Other statutory employment costs', '{}'::jsonb, 'expense', false, null, 1050),
  ('SB', 'default', '6050', 'Retirement gratuity and end-of-service benefits', '{}'::jsonb, 'expense', false, null, 1060),
  ('SB', 'default', '6060', 'Staff amenities', '{}'::jsonb, 'expense', false, null, 1070),
  ('SB', 'default', '6070', 'Staff medical expenses and insurance', '{}'::jsonb, 'expense', false, null, 1080),
  ('SB', 'default', '6080', 'Staff training', '{}'::jsonb, 'expense', false, null, 1090),
  ('SB', 'default', '6200', 'Depreciation of property plant and equipment', '{}'::jsonb, 'expense_depreciation', false, null, 1100),
  ('SB', 'default', '6210', 'Depreciation of right-of-use assets', '{}'::jsonb, 'expense_depreciation', false, null, 1110),
  ('SB', 'default', '6220', 'Amortisation of intangible assets', '{}'::jsonb, 'expense_depreciation', false, null, 1120),
  ('SB', 'default', '6300', 'Rent — short-term leases', '{}'::jsonb, 'expense', false, null, 1130),
  ('SB', 'default', '6310', 'Utilities', '{}'::jsonb, 'expense', false, null, 1140),
  ('SB', 'default', '6320', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 1150),
  ('SB', 'default', '6330', 'Cleaning and security services', '{}'::jsonb, 'expense', false, null, 1160),
  ('SB', 'default', '6340', 'Telephone and internet', '{}'::jsonb, 'expense', false, null, 1170),
  ('SB', 'default', '6350', 'Software subscriptions', '{}'::jsonb, 'expense', false, null, 1180),
  ('SB', 'default', '6360', 'Advertising and marketing', '{}'::jsonb, 'expense', false, null, 1190),
  ('SB', 'default', '6370', 'Travelling', '{}'::jsonb, 'expense', false, null, 1200),
  ('SB', 'default', '6380', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1210),
  ('SB', 'default', '6390', 'Entertainment', '{}'::jsonb, 'expense', false, null, 1220),
  ('SB', 'default', '6400', 'Subscriptions and memberships', '{}'::jsonb, 'expense', false, null, 1230),
  ('SB', 'default', '6410', 'Insurance', '{}'::jsonb, 'expense', false, null, 1240),
  ('SB', 'default', '6420', 'Professional fees', '{}'::jsonb, 'expense', false, null, 1250),
  ('SB', 'default', '6430', 'Audit fees', '{}'::jsonb, 'expense', false, null, 1260),
  ('SB', 'default', '6440', 'Company secretarial and registration fees', '{}'::jsonb, 'expense', false, null, 1270),
  ('SB', 'default', '6450', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1280),
  ('SB', 'default', '6455', 'Donations', '{}'::jsonb, 'expense', false, null, 1290),
  ('SB', 'default', '6460', 'Printing and stationery', '{}'::jsonb, 'expense', false, null, 1300),
  ('SB', 'default', '6470', 'Postage and courier', '{}'::jsonb, 'expense', false, null, 1310),
  ('SB', 'default', '6480', 'Licences permits and local authority fees', '{}'::jsonb, 'expense', false, null, 1320),
  ('SB', 'default', '6490', 'Royalties', '{}'::jsonb, 'expense', false, null, 1330),
  ('SB', 'default', '6500', 'Bad debts written off', '{}'::jsonb, 'expense', false, null, 1340),
  ('SB', 'default', '6510', 'Impairment loss on trade receivables', '{}'::jsonb, 'expense', false, null, 1350),
  ('SB', 'default', '6900', 'Sponsorship', '{}'::jsonb, 'expense', false, null, 1360),
  ('SB', 'default', '6950', 'Foreign exchange losses', '{}'::jsonb, 'expense', false, null, 1370),
  ('SB', 'default', '6960', 'Loss on disposal of property plant and equipment', '{}'::jsonb, 'expense', false, null, 1380),
  ('SB', 'default', '6990', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1390),
  ('SB', 'default', '7000', 'Interest on bank loans', '{}'::jsonb, 'expense', false, null, 1400),
  ('SB', 'default', '7010', 'Interest on lease liabilities', '{}'::jsonb, 'expense', false, null, 1410),
  ('SB', 'default', '7020', 'Hire purchase interest', '{}'::jsonb, 'expense', false, null, 1420),
  ('SB', 'default', '7030', 'Interest on loans from related parties and others', '{}'::jsonb, 'expense', false, null, 1430),
  ('SB', 'default', '8000', 'Current income tax expense', '{}'::jsonb, 'expense', false, null, 1440),
  ('SB', 'default', '8010', 'Deferred tax expense', '{}'::jsonb, 'expense', false, null, 1450),
  ('SB', 'default', '8020', 'Under or over provision of income tax in prior years', '{}'::jsonb, 'expense', false, null, 1460)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('SB', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('SB', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('SB', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('SB', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('SB', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('SB', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('SB', 'SB-GT-EX', 'Goods tax, exempt or not liable goods', '{}'::jsonb, 'Goods the Goods Tax Act exempts (medicines, goods for governments, charities and disabled people), goods exported, and sales not subject to goods tax', 'percent', 0, 'sale', 'exempt', date '2019-08-28', null, 'Form GT4 ''Less Exempt Goods'' and its instructions: exempt sales are those sales not subject to Goods Tax. The Goods Tax web page lists the exempt goods (drugs, medicines and surgical goods, goods used by governments and charitable organisations, goods designed for use by disabled people) and says goods tax does not apply to goods for export. Box G2 of the return, included in the total sales of box G1.', 'E', null, 40, 'sales_tax', true, '{}'::tax_condition[], null, false, false, null, 'gt4-form', null, null, null, null),
  ('SB', 'SB-GT-I15', 'Goods tax, imported goods 15 %', '{}'::jsonb, 'An imported good sold by a wholesaler or by an importer as retailer, goods tax at 15 % of the sale value', 'percent', 15, 'sale', 'domestic', date '2019-08-28', null, 'Goods Tax Act (Cap. 122) section 69 and the Second Schedule as substituted by the Order of 2019: imported goods 15 %. Form GT4, line imported goods 15 %: the exclusive sales in box G7, the tax in box G8. Goods tax on goods an importer brings in is paid to Customs at the port of entry and is not a line of this return.', 'S', null, 20, 'sales_tax', true, '{}'::tax_condition[], null, false, false, null, 'gt-order-2019', null, null, null, null),
  ('SB', 'SB-GT-L10', 'Goods tax, locally manufactured goods 10 %', '{}'::jsonb, 'A prescribed locally manufactured good sold by its manufacturer or a wholesaler, goods tax at 10 % of the sale value', 'percent', 10, 'sale', 'domestic', date '2019-08-28', null, 'Goods Tax Act (Cap. 122) section 69 and the Second Schedule as substituted by the Goods Tax (Second Schedule) (Amendment) Order 2019: prescribed locally manufactured goods 10 %. The tax is stated on the wholesale invoice (section 75) and declared on the Goods Tax Return, form GT4 (formerly GT3): the exclusive sales in box G5, the tax in box G6.', 'S', null, 10, 'sales_tax', true, '{}'::tax_condition[], null, false, false, null, 'gt-order-2019', null, null, null, null),
  ('SB', 'SB-GT-RICE', 'Goods tax, rice at 0 %', '{}'::jsonb, 'Rice, which the return form taxes at the rate of zero percent', 'percent', 0, 'sale', 'domestic', date '2019-08-28', null, 'Form GT4 ''Less Sale of Rice taxed at 0%'' and its instructions: ''Rice is taxable but at the rate of zero percent. Write here the amount of rice you have sold which is subject to the 0% rate.'' The Second Schedule of the Act (Order of 2019) still lists rice at 5 %: the two texts differ and the pack follows the current form, see the README. Box G3 of the return.', 'Z', null, 30, 'sales_tax', true, '{}'::tax_condition[], null, false, false, null, 'gt4-form', null, null, null, null),
  ('SB', 'SB-P-0', 'Purchase, without sales tax', '{}'::jsonb, 'A purchase that carries no sales tax, goods tax included in the price paid to the supplier', 'percent', 0, 'purchase', 'exempt', date '2024-02-05', null, 'Form GT4 and form ST4 declare sales only: a purchase appears on no line of either return. Goods tax paid on goods bought from a manufacturer or wholesaler is in the price and is part of the cost.', 'E', null, 110, 'sales_tax', true, '{}'::tax_condition[], null, false, false, null, 'gt4-form', null, null, null, null),
  ('SB', 'SB-P-ST10', 'Purchase, sales tax 10 % paid, not creditable', '{}'::jsonb, 'A prescribed service bought for the business on which sales tax of 10 % was charged: the tax joins the cost', 'percent', 10, 'purchase', 'domestic', date '2024-02-05', null, 'Sales Tax Act (Cap. 125) section 3(1): the purchaser is charged the tax on the use or consumption of the prescribed goods and services. Neither the Act nor the forms read give a purchaser a credit for it: form ST4 declares the vendor''s sales only, so the tax joins the cost and no box of the return receives the purchase.', 'S', null, 100, 'sales_tax', true, '{}'::tax_condition[], null, false, false, null, 'sales-tax-act', null, null, null, null),
  ('SB', 'SB-S-0', 'Sale, not subject to goods tax or sales tax', '{}'::jsonb, 'A sale of a good or a service the two taxes do not reach, or an export', 'percent', 0, 'sale', 'exempt', date '2019-08-28', null, 'Goods Tax web page: goods tax generally does not apply to services that do not produce goods, sales of land or intangible property, used local goods or goods for export; sales tax applies only to the goods and services of Schedule One of the Sales Tax Act. A sale of goods under this code appears on no box: choose SB-GT-EX to declare it in the total sales of form GT4.', 'E', null, 60, 'sales_tax', true, '{}'::tax_condition[], null, false, false, null, 'goods-tax-act', null, null, null, null),
  ('SB', 'SB-ST-10', 'Sales tax, prescribed services 10 %', '{}'::jsonb, 'A service of the Schedule One of the Sales Tax Act charged at 10 % of its value (telecommunications, restaurants, professional services, hire, repairs and the other items the Schedule lists at a percentage)', 'percent', 10, 'sale', 'domestic', date '2024-02-05', null, 'Sales Tax Act (Cap. 125) section 3(1) and Schedule One, in the reprint in force on 5 February 2024; the Sales Tax Return instructions of August 2025 list the services at 10 %. Charged by the vendor at the time of the sale (section 14) and declared on the Sales Tax Return, form ST4 (formerly ST3): the sales in box S1, the tax in box S2. The items taxed at an amount per unit are not carried (see the README).', 'S', null, 50, 'sales_tax', true, '{}'::tax_condition[], null, false, false, null, 'st-instructions', null, null, null, null)
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
    ('SB-GT-EX', 'invoice', 'base', 100, null, 'G2', array['G2']::text[], 100, 'SB-GT4-ST4', 10),
    ('SB-GT-EX', 'credit_note', 'base', 100, null, 'G2', array['G2']::text[], -100, 'SB-GT4-ST4', 10),
    ('SB-GT-I15', 'invoice', 'base', 100, null, 'G7', array['G7']::text[], 100, 'SB-GT4-ST4', 10),
    ('SB-GT-I15', 'invoice', 'tax', 100, '2100', 'G8', array['G8']::text[], 100, 'SB-GT4-ST4', 20),
    ('SB-GT-I15', 'credit_note', 'base', 100, null, 'G7', array['G7']::text[], -100, 'SB-GT4-ST4', 10),
    ('SB-GT-I15', 'credit_note', 'tax', 100, '2100', 'G8', array['G8']::text[], -100, 'SB-GT4-ST4', 20),
    ('SB-GT-L10', 'invoice', 'base', 100, null, 'G5', array['G5']::text[], 100, 'SB-GT4-ST4', 10),
    ('SB-GT-L10', 'invoice', 'tax', 100, '2100', 'G6', array['G6']::text[], 100, 'SB-GT4-ST4', 20),
    ('SB-GT-L10', 'credit_note', 'base', 100, null, 'G5', array['G5']::text[], -100, 'SB-GT4-ST4', 10),
    ('SB-GT-L10', 'credit_note', 'tax', 100, '2100', 'G6', array['G6']::text[], -100, 'SB-GT4-ST4', 20),
    ('SB-GT-RICE', 'invoice', 'base', 100, null, 'G3', array['G3']::text[], 100, 'SB-GT4-ST4', 10),
    ('SB-GT-RICE', 'credit_note', 'base', 100, null, 'G3', array['G3']::text[], -100, 'SB-GT4-ST4', 10),
    ('SB-P-ST10', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('SB-P-ST10', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('SB-ST-10', 'invoice', 'base', 100, null, 'S1', array['S1']::text[], 100, 'SB-GT4-ST4', 10),
    ('SB-ST-10', 'invoice', 'tax', 100, '2105', 'S2', array['S2']::text[], 100, 'SB-GT4-ST4', 20),
    ('SB-ST-10', 'credit_note', 'base', 100, null, 'S1', array['S1']::text[], -100, 'SB-GT4-ST4', 10),
    ('SB-ST-10', 'credit_note', 'tax', 100, '2105', 'S2', array['S2']::text[], -100, 'SB-GT4-ST4', 20)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'SB' and t.code = v.tax_code
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
  ('SB', 'SB-GT4-ST4', 'Goods Tax Return (GT4) and Sales Tax Return (ST4)', array['month']::declaration_period[], 'month'::declaration_period, date '2019-08-28', null, 'Two monthly returns of the Inland Revenue Division, filed with the payment for the month of the sales: form GT4, Goods Tax Return (formerly GT3, revised August 2025), and form ST4, Sales Tax Return (formerly ST3, revised August 2025). A pack carries one periodic form, so both returns are boxes of one report here: boxes G1 to G9 are form GT4, boxes S1 to S4 form ST4, box T their sum. A company files the forms it is registered for; the boxes of the other stay empty. Both taxes are single-stage taxes without input credit: the return carries only what the taxpayer collected.', true,'day_of_month_after_period'::filing_deadline_rule, 30, null, 'Form GT4 and form ST4: ''to be completed and forwarded with the tax payable to Inland Revenue Division within 30 days of the end of the month in which the sales were made''. Sales Tax Act section 14: remitted with the returns not later than thirty days after the end of the month; section 17(2): debt payable on the 30th day of the month following. The Inland Revenue Division notices give the 30th. Goods Tax Act section 42 allows sixty days for a credit sale: not modelled. A due date on a weekend or a holiday is not shifted by this rule; in February the 30th does not exist, see the README.', 'st4-form', null)
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
  ('SB', 'SB-GT4-ST4', 'G1', 'total', 'GT4 — Total sales of goods', '{}'::jsonb, 10, null, array['G2', 'G3', 'G4']::text[], '{}'::text[], null, null, false, false, null, 'Form GT4, ''Total Sales of Goods'': the sales of goods of the month, exempt and rice included. Here the exempt sales, the rice and the taxable sales added.', 'gt4-form'),
  ('SB', 'SB-GT4-ST4', 'G2', 'base', 'GT4 — Less exempt goods', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GT4, ''Less Exempt Goods'': sales not subject to Goods Tax (instructions).', 'gt4-form'),
  ('SB', 'SB-GT4-ST4', 'G3', 'base', 'GT4 — Less sale of rice taxed at 0%', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GT4, ''Less Sale of Rice taxed at 0%''.', 'gt4-form'),
  ('SB', 'SB-GT4-ST4', 'G4', 'total', 'GT4 — Taxable sales of goods', '{}'::jsonb, 40, null, array['G5', 'G7']::text[], '{}'::text[], null, null, false, false, null, 'Form GT4, ''Taxable Sales of Goods'': total sales less exempt sales and rice (instructions). Here the two taxable bases added.', 'gt4-form'),
  ('SB', 'SB-GT4-ST4', 'G5', 'base', 'GT4 — Locally manufactured goods, sales at 10 %', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GT4, ''Locally manufactured Goods 10%'': the taxable sales at 10 %, valued by the determination of sale value of the instructions.', 'gt4-form'),
  ('SB', 'SB-GT4-ST4', 'G6', 'tax', 'GT4 — Goods tax payable on locally manufactured goods', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GT4, goods tax payable on the locally manufactured goods: 10 % of box G5.', 'gt4-form'),
  ('SB', 'SB-GT4-ST4', 'G7', 'base', 'GT4 — Imported goods, sales at 15 %', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GT4, ''Imported Goods 15%'': the taxable sales at 15 %.', 'gt4-form'),
  ('SB', 'SB-GT4-ST4', 'G8', 'tax', 'GT4 — Goods tax payable on imported goods', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GT4, goods tax payable on the imported goods: 15 % of box G7.', 'gt4-form'),
  ('SB', 'SB-GT4-ST4', 'G9', 'total', 'GT4 — Total goods tax payable', '{}'::jsonb, 90, null, array['G6', 'G8']::text[], '{}'::text[], null, null, false, false, null, 'Form GT4, ''Total Goods Tax payable'': the two taxes added.', 'gt4-form'),
  ('SB', 'SB-GT4-ST4', 'S1', 'base', 'ST4 — Sales subject to sales tax at 10 %', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form ST4, ''Amount of Sales'': the sales of the month of the services of Schedule One taxed at 10 %. The form has one line per type of sale; the pack carries them on one line.', 'st4-form'),
  ('SB', 'SB-GT4-ST4', 'S2', 'tax', 'ST4 — Sales tax payable', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form ST4, ''Sales Tax payable'': the amount of sales times the rate of tax.', 'st4-form'),
  ('SB', 'SB-GT4-ST4', 'S3', 'total', 'ST4 — Total sales', '{}'::jsonb, 130, null, array['S1']::text[], '{}'::text[], null, null, false, false, null, 'Form ST4, ''Total Sales'': the total amount of sales for all types of sales.', 'st4-form'),
  ('SB', 'SB-GT4-ST4', 'S4', 'total', 'ST4 — Total sales tax payable', '{}'::jsonb, 140, null, array['S2']::text[], '{}'::text[], null, null, false, false, null, 'Form ST4, ''Total Sales Tax payable'': the total tax payable for all types of sales.', 'st4-form'),
  ('SB', 'SB-GT4-ST4', 'T', 'total', 'Goods tax and sales tax payable to the IRD', '{}'::jsonb, 150, null, array['G9', 'S4']::text[], '{}'::text[], null, null, false, false, null, 'Not a line of either form: the two returns have the same due date (30 days after the end of the month) and one payment settles the tax account of the pack. Boxes G9 and S4 added.', 'gt4-form')
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
  ('SB-IFRS-IS', 'SB', 'default', 'Statement of profit or loss', 'income_statement', 'IFRS', date '2024-01-01', null, 'IAS 1 asks for a statement of financial position and a statement of profit or loss; expenses are analysed by nature, which these lines follow. No Solomon Islands text prescribing a layout of the statements was found, so the statement is presented as IFRS-style on the pack''s own chart.', 'ias-1', null, null, '{}'::jsonb),
  ('SB-IFRS-SFP', 'SB', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS', date '2024-01-01', null, 'IAS 1 asks for a statement of financial position and a statement of profit or loss; expenses are analysed by nature, which these lines follow. No Solomon Islands text prescribing a layout of the statements was found, so the statement is presented as IFRS-style on the pack''s own chart.', 'ias-1', 'combined', 'Result of the current financial year', '{}'::jsonb)
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
  ('SB-IFRS-IS', '1', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-IS', '2', null, 'Other income', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-IS', '3', null, 'Purchases and changes in inventories', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-IS', '4', null, 'Employee benefits expense', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-IS', '5', null, 'Depreciation and amortisation', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-IS', '6', null, 'Other operating expenses', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-IS', '7', null, 'Finance costs', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-IS', '8', null, 'Profit before tax', '{}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('SB-IFRS-IS', '9', null, 'Income tax expense', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-IS', '10', null, 'Profit for the year', '{}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, null, null),
  ('SB-IFRS-SFP', 'CA', null, 'Current assets', '{}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5', 'CA.6']::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'CA.1', null, 'Cash and cash equivalents', '{}'::jsonb, 11, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'CA.2', null, 'Trade and other receivables', '{}'::jsonb, 12, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'CA.3', null, 'Inventories', '{}'::jsonb, 13, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'CA.4', null, 'Financial assets', '{}'::jsonb, 14, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'CA.5', null, 'Current tax recoverable', '{}'::jsonb, 15, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'CA.6', null, 'Prepayments and accrued income', '{}'::jsonb, 16, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'NCA', null, 'Non-current assets', '{}'::jsonb, 20, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4', 'NCA.5', 'NCA.6', 'NCA.7']::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'NCA.1', null, 'Property, plant and equipment', '{}'::jsonb, 21, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'NCA.2', null, 'Investment property', '{}'::jsonb, 22, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'NCA.3', null, 'Intangible assets', '{}'::jsonb, 23, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'NCA.4', null, 'Investments in associates', '{}'::jsonb, 24, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'NCA.5', null, 'Investments in joint ventures', '{}'::jsonb, 25, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'NCA.6', null, 'Financial assets', '{}'::jsonb, 26, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'NCA.7', null, 'Deferred tax assets', '{}'::jsonb, 27, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'TA', null, 'Total assets', '{}'::jsonb, 30, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'CL', null, 'Current liabilities', '{}'::jsonb, 40, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4', 'CL.5']::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'CL.1', null, 'Trade and other payables', '{}'::jsonb, 41, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'CL.2', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 42, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'CL.3', null, 'Amounts due to directors', '{}'::jsonb, 43, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'CL.4', null, 'Current tax payable', '{}'::jsonb, 44, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'CL.5', null, 'Provisions', '{}'::jsonb, 45, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'NCL', null, 'Non-current liabilities', '{}'::jsonb, 50, 1, true, array['NCL.1', 'NCL.2', 'NCL.3']::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'NCL.1', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 51, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'NCL.2', null, 'Deferred tax liabilities', '{}'::jsonb, 52, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'NCL.3', null, 'Provisions', '{}'::jsonb, 53, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'TL', null, 'Total liabilities', '{}'::jsonb, 60, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'NA', null, 'Net assets', '{}'::jsonb, 70, 1, true, array['TA']::text[], array['TL']::text[], null, null, null),
  ('SB-IFRS-SFP', 'EQ', null, 'Equity', '{}'::jsonb, 80, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'EQ.1', null, 'Share capital', '{}'::jsonb, 81, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'EQ.2', null, 'Other reserves', '{}'::jsonb, 82, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SB-IFRS-SFP', 'EQ.3', null, 'Retained earnings', '{}'::jsonb, 83, -1, false, '{}'::text[], '{}'::text[], null, null, null)
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
 where r.statement_code in ('SB-IFRS-IS', 'SB-IFRS-SFP')
   and (r.statement_code, r.line_code, r.sequence) not in (
     values ('SB-IFRS-IS', '1', 10),
            ('SB-IFRS-IS', '2', 10),
            ('SB-IFRS-IS', '3', 10),
            ('SB-IFRS-IS', '4', 10),
            ('SB-IFRS-IS', '5', 10),
            ('SB-IFRS-IS', '6', 10),
            ('SB-IFRS-IS', '7', 10),
            ('SB-IFRS-IS', '9', 10),
            ('SB-IFRS-SFP', 'CA.1', 10),
            ('SB-IFRS-SFP', 'CA.2', 10),
            ('SB-IFRS-SFP', 'CA.3', 10),
            ('SB-IFRS-SFP', 'CA.4', 10),
            ('SB-IFRS-SFP', 'CA.5', 10),
            ('SB-IFRS-SFP', 'CA.6', 10),
            ('SB-IFRS-SFP', 'NCA.1', 10),
            ('SB-IFRS-SFP', 'NCA.2', 10),
            ('SB-IFRS-SFP', 'NCA.3', 10),
            ('SB-IFRS-SFP', 'NCA.4', 10),
            ('SB-IFRS-SFP', 'NCA.5', 10),
            ('SB-IFRS-SFP', 'NCA.6', 10),
            ('SB-IFRS-SFP', 'NCA.7', 10),
            ('SB-IFRS-SFP', 'CL.1', 10),
            ('SB-IFRS-SFP', 'CL.1', 20),
            ('SB-IFRS-SFP', 'CL.2', 10),
            ('SB-IFRS-SFP', 'CL.3', 10),
            ('SB-IFRS-SFP', 'CL.4', 10),
            ('SB-IFRS-SFP', 'CL.5', 10),
            ('SB-IFRS-SFP', 'NCL.1', 10),
            ('SB-IFRS-SFP', 'NCL.2', 10),
            ('SB-IFRS-SFP', 'NCL.3', 10),
            ('SB-IFRS-SFP', 'EQ.1', 10),
            ('SB-IFRS-SFP', 'EQ.2', 10),
            ('SB-IFRS-SFP', 'EQ.3', 10)
   );

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('SB-IFRS-IS', '1', 10, 'code_range', '4000', '4030', null, 'any'),
    ('SB-IFRS-IS', '2', 10, 'code_range', '4500', '4790', null, 'any'),
    ('SB-IFRS-IS', '3', 10, 'code_range', '5000', '5100', null, 'any'),
    ('SB-IFRS-IS', '4', 10, 'code_range', '6000', '6080', null, 'any'),
    ('SB-IFRS-IS', '5', 10, 'code_range', '6200', '6220', null, 'any'),
    ('SB-IFRS-IS', '6', 10, 'code_range', '6300', '6990', null, 'any'),
    ('SB-IFRS-IS', '7', 10, 'code_range', '7000', '7030', null, 'any'),
    ('SB-IFRS-IS', '9', 10, 'code_range', '8000', '8020', null, 'any'),
    ('SB-IFRS-SFP', 'CA.1', 10, 'code_range', '1000', '1040', null, 'any'),
    ('SB-IFRS-SFP', 'CA.2', 10, 'code_range', '1100', '1160', null, 'any'),
    ('SB-IFRS-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('SB-IFRS-SFP', 'CA.4', 10, 'account_code', '1300', null, null, 'any'),
    ('SB-IFRS-SFP', 'CA.5', 10, 'account_code', '1350', null, null, 'any'),
    ('SB-IFRS-SFP', 'CA.6', 10, 'code_range', '1400', '1410', null, 'any'),
    ('SB-IFRS-SFP', 'NCA.1', 10, 'code_range', '1600', '1671', null, 'any'),
    ('SB-IFRS-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('SB-IFRS-SFP', 'NCA.3', 10, 'code_range', '1750', '1760', null, 'any'),
    ('SB-IFRS-SFP', 'NCA.4', 10, 'account_code', '1800', null, null, 'any'),
    ('SB-IFRS-SFP', 'NCA.5', 10, 'account_code', '1810', null, null, 'any'),
    ('SB-IFRS-SFP', 'NCA.6', 10, 'code_range', '1830', '1840', null, 'any'),
    ('SB-IFRS-SFP', 'NCA.7', 10, 'account_code', '1900', null, null, 'any'),
    ('SB-IFRS-SFP', 'CL.1', 10, 'code_range', '2000', '2190', null, 'any'),
    ('SB-IFRS-SFP', 'CL.1', 20, 'account_code', '2990', null, null, 'credit'),
    ('SB-IFRS-SFP', 'CL.2', 10, 'code_range', '2200', '2240', null, 'any'),
    ('SB-IFRS-SFP', 'CL.3', 10, 'account_code', '2250', null, null, 'any'),
    ('SB-IFRS-SFP', 'CL.4', 10, 'account_code', '2300', null, null, 'any'),
    ('SB-IFRS-SFP', 'CL.5', 10, 'code_range', '2350', '2360', null, 'any'),
    ('SB-IFRS-SFP', 'NCL.1', 10, 'code_range', '2400', '2430', null, 'any'),
    ('SB-IFRS-SFP', 'NCL.2', 10, 'account_code', '2500', null, null, 'any'),
    ('SB-IFRS-SFP', 'NCL.3', 10, 'account_code', '2550', null, null, 'any'),
    ('SB-IFRS-SFP', 'EQ.1', 10, 'code_range', '3000', '3010', null, 'any'),
    ('SB-IFRS-SFP', 'EQ.2', 10, 'code_range', '3100', '3110', null, 'any'),
    ('SB-IFRS-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('SB', 'Solomon Islands', '{}'::jsonb, array['en']::text[], 'SBD', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, 'month'::declaration_period)
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
  numbering_legal_reference     = 'Goods Tax Act section 75 asks the goods tax to be stated on the wholesale invoice; no text read states a numbering rule. `sequential` and the number format are conventions of this pack and not rules of the law.',
  numbering_source_key          = 'goods-tax-act',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_date',
  tax_point_legal_reference     = 'Sales Tax Act section 14: the tax is collected at the time of the sale on the whole amount of the value. Goods Tax Act section 42: payable within thirty days after the close of the month of the sale. `invoice_date` is the pack''s approximation of the time of the sale; a credit sale of goods (sixty days to pay) is not modelled.',
  tax_point_source_key          = 'sales-tax-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No structured e-invoice standard, Peppol profile or clearance system of the Inland Revenue Division was found in the texts read; the returns are paper forms (GT4, ST4) and the eTax service. `obligation` is `none` for want of a text, not on a finding that none exists.',
  einvoice_source_key           = 'tax-portal',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'SB';

update country_defaults set
  tax_payee_name       = 'Solomon Islands Inland Revenue Division',
  tax_payee_source_key = 'tax-portal'
 where country = 'SB';
