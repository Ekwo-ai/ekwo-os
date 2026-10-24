-- Ekwo OS — Fiji: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/fj at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build fj`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   VAT Guide (1 November 2023 edition) — who must register (gross annual turnover above FJ$100,000, within 21 days), the zero-rated and exempt supplies, the right to deduct input tax (not on exempt supplies), tax invoices, accounting on the invoice basis unless the CEO approves the payment basis, taxable periods (monthly above FJ$300,000, three-monthly or yearly below) and their due dates, and the output and input adjustments (Fiji Revenue and Customs Service (FRCS))
--     https://www.frcs.org.fj/wp-content/uploads/2023/11/VAT-Guide-01.11.2-Online-version.pdf
--   VAT Guide — rates and tax labels: 12.5 % (tax fraction 1/9) from 1 August 2025 on goods and services other than exempt and zero-rated ones, 15 % (3/23) from 1 August 2023, 0 % for the zero-rated supplies of Schedule 2, exempt supplies of Schedule 1; monthly, quarterly and annual filing; returns due on or before the last day of the month following the taxable period (Section 33 of the VAT Act) (Fiji Revenue and Customs Service (FRCS))
--     https://frcs.org.fj/?p=28316
--   Value Added Tax Return, form IRS217 (revised 26 November 2014): Section B boxes 1 to 6 (output tax), Section C boxes 7 to 12 (input tax), box 13 (amount to pay or refund due), and the panels for the output and input adjustments and the apportionment of input tax. The form prints the tax fraction of its day (9/109); the rate in force is the one of the rates source (Fiji Revenue and Customs Service (FRCS))
--     https://www.frcs.org.fj/wp-content/uploads/2018/07/IRS-217_FillableSec26022016.pdf
--   Instructions for completing the VAT return (IRS217A, 28 July 2015): the thirteen boxes one by one — box 1 VAT-inclusive, box 3 = box 1 less box 2, box 4 = box 3 × tax fraction, box 7 from the input tax schedule, box 8 VAT invoiced by Customs on imports, box 13 may be negative (refund); an amount below FJ$5 is not remitted or refunded (Fiji Revenue and Customs Service (FRCS))
--     https://www.frcs.org.fj/wp-content/uploads/2018/05/IRS217A.pdf
--   Tax Talk — VAT Return Filing and the Return Lines: what the thirteen lines of the return relate to; exempt supplies (First Schedule of the VAT Act) stay out of line 1, zero-rated supplies (Second Schedule) are declared in lines 1 and 2 and keep the input tax credit (Fiji Revenue and Customs Service (FRCS))
--     https://www.frcs.org.fj/wp-content/uploads/2019/02/Tax-Talk-on-VAT-Return-Lines-.pdf
--   Use of IFRS Standards by jurisdiction — Fiji: the Fiji Institute of Accountants is the standard setter and has adopted IFRS Standards for large and publicly accountable entities and IFRS for SMEs for the others (IFRS Foundation)
--     https://www.ifrs.org/use-around-the-world/use-of-ifrs-standards-by-jurisdiction/view-jurisdiction/fiji/
--   IAS 1 Presentation of Financial Statements — the statement of financial position and the statement of profit or loss, expenses analysed by nature; no Fiji text prescribing a layout or a chart of accounts was found (IFRS Foundation)
--     https://www.ifrs.org/issued-standards/list-of-standards/ias-1-presentation-of-financial-statements/
--   Fiji Revenue and Customs Service — tax administration portal (forms, guides, the TPOS taxpayer portal on which VAT returns are filed and paid) (Fiji Revenue and Customs Service (FRCS))
--     https://www.frcs.org.fj
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('FJ', 'Fiji', '0.1.0', date '2026-10-24', '20261023124650', 'community', null, null, '7dffeba6c0cf7693357cedae624b2033c603557a48cc98a57e33bca98d92be73', '[{"key":"vat-guide","title":"VAT Guide (1 November 2023 edition) — who must register (gross annual turnover above FJ$100,000, within 21 days), the zero-rated and exempt supplies, the right to deduct input tax (not on exempt supplies), tax invoices, accounting on the invoice basis unless the CEO approves the payment basis, taxable periods (monthly above FJ$300,000, three-monthly or yearly below) and their due dates, and the output and input adjustments","publisher":"Fiji Revenue and Customs Service (FRCS)","url":"https://www.frcs.org.fj/wp-content/uploads/2023/11/VAT-Guide-01.11.2-Online-version.pdf","consulted_on":"2026-10-24","kind":"guidance"},{"key":"vat-rates","title":"VAT Guide — rates and tax labels: 12.5 % (tax fraction 1/9) from 1 August 2025 on goods and services other than exempt and zero-rated ones, 15 % (3/23) from 1 August 2023, 0 % for the zero-rated supplies of Schedule 2, exempt supplies of Schedule 1; monthly, quarterly and annual filing; returns due on or before the last day of the month following the taxable period (Section 33 of the VAT Act)","publisher":"Fiji Revenue and Customs Service (FRCS)","url":"https://frcs.org.fj/?p=28316","consulted_on":"2026-10-24","kind":"guidance"},{"key":"vat-return","title":"Value Added Tax Return, form IRS217 (revised 26 November 2014): Section B boxes 1 to 6 (output tax), Section C boxes 7 to 12 (input tax), box 13 (amount to pay or refund due), and the panels for the output and input adjustments and the apportionment of input tax. The form prints the tax fraction of its day (9/109); the rate in force is the one of the rates source","publisher":"Fiji Revenue and Customs Service (FRCS)","url":"https://www.frcs.org.fj/wp-content/uploads/2018/07/IRS-217_FillableSec26022016.pdf","consulted_on":"2026-10-24","kind":"form"},{"key":"vat-return-instructions","title":"Instructions for completing the VAT return (IRS217A, 28 July 2015): the thirteen boxes one by one — box 1 VAT-inclusive, box 3 = box 1 less box 2, box 4 = box 3 × tax fraction, box 7 from the input tax schedule, box 8 VAT invoiced by Customs on imports, box 13 may be negative (refund); an amount below FJ$5 is not remitted or refunded","publisher":"Fiji Revenue and Customs Service (FRCS)","url":"https://www.frcs.org.fj/wp-content/uploads/2018/05/IRS217A.pdf","consulted_on":"2026-10-24","kind":"guidance"},{"key":"vat-return-lines","title":"Tax Talk — VAT Return Filing and the Return Lines: what the thirteen lines of the return relate to; exempt supplies (First Schedule of the VAT Act) stay out of line 1, zero-rated supplies (Second Schedule) are declared in lines 1 and 2 and keep the input tax credit","publisher":"Fiji Revenue and Customs Service (FRCS)","url":"https://www.frcs.org.fj/wp-content/uploads/2019/02/Tax-Talk-on-VAT-Return-Lines-.pdf","consulted_on":"2026-10-24","kind":"guidance"},{"key":"ifrs-profile","title":"Use of IFRS Standards by jurisdiction — Fiji: the Fiji Institute of Accountants is the standard setter and has adopted IFRS Standards for large and publicly accountable entities and IFRS for SMEs for the others","publisher":"IFRS Foundation","url":"https://www.ifrs.org/use-around-the-world/use-of-ifrs-standards-by-jurisdiction/view-jurisdiction/fiji/","consulted_on":"2026-10-24","kind":"guidance"},{"key":"ias-1","title":"IAS 1 Presentation of Financial Statements — the statement of financial position and the statement of profit or loss, expenses analysed by nature; no Fiji text prescribing a layout or a chart of accounts was found","publisher":"IFRS Foundation","url":"https://www.ifrs.org/issued-standards/list-of-standards/ias-1-presentation-of-financial-statements/","consulted_on":"2026-10-24","kind":"guidance"},{"key":"frcs-portal","title":"Fiji Revenue and Customs Service — tax administration portal (forms, guides, the TPOS taxpayer portal on which VAT returns are filed and paid)","publisher":"Fiji Revenue and Customs Service (FRCS)","url":"https://www.frcs.org.fj","consulted_on":"2026-10-24","kind":"portal"}]'::jsonb)
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
  ('FJ', 'default', 'Fiji reference chart of accounts', '{}'::jsonb, true, 'companies', array['FJ-IFRS-IS', 'FJ-IFRS-SFP']::text[], null, 'There is no legal chart of accounts in the texts read for Fiji: the Fiji Institute of Accountants sets the standards (IFRS Standards and IFRS for SMEs) and prescribes no chart. This chart is original: four digits, blocked so that each range reaches one line of the IFRS-style statements below (IAS 1, expenses by nature), with the accounts a Fiji trading company keeps — VAT output and input tax, import VAT owed to FRCS at the border, PAYE withheld, FNPF (Fiji National Provident Fund) contributions and withholding taxes payable.', 'ias-1')
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
  ('FJ', 'default', '1000', 'Petty cash', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('FJ', 'default', '1010', 'Current account — FJD', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('FJ', 'default', '1020', 'Fixed deposits placed for three months or less', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('FJ', 'default', '1030', 'Foreign currency account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('FJ', 'default', '1040', 'Cash in transit — card and mobile-payment settlements', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('FJ', 'default', '1100', 'Trade receivables', '{}'::jsonb, 'asset_receivable', true, null, 60),
  ('FJ', 'default', '1110', 'Trade receivables — allowance for impairment', '{}'::jsonb, 'asset_current', false, null, 70),
  ('FJ', 'default', '1120', 'Other receivables', '{}'::jsonb, 'asset_current', false, null, 80),
  ('FJ', 'default', '1130', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 90),
  ('FJ', 'default', '1140', 'Deposits paid', '{}'::jsonb, 'asset_current', false, null, 100),
  ('FJ', 'default', '1150', 'VAT input tax', '{}'::jsonb, 'asset_current', false, null, 110),
  ('FJ', 'default', '1155', 'VAT refundable by FRCS — net of a filed return', '{}'::jsonb, 'asset_current', true, null, 120),
  ('FJ', 'default', '1160', 'Advances to staff', '{}'::jsonb, 'asset_current', false, null, 130),
  ('FJ', 'default', '1200', 'Inventories — goods for resale', '{}'::jsonb, 'asset_current', false, null, 140),
  ('FJ', 'default', '1210', 'Inventories — raw materials', '{}'::jsonb, 'asset_current', false, null, 150),
  ('FJ', 'default', '1220', 'Inventories — work in progress', '{}'::jsonb, 'asset_current', false, null, 160),
  ('FJ', 'default', '1230', 'Inventories — finished goods', '{}'::jsonb, 'asset_current', false, null, 170),
  ('FJ', 'default', '1300', 'Short-term investments', '{}'::jsonb, 'asset_current', false, null, 180),
  ('FJ', 'default', '1350', 'Current tax recoverable', '{}'::jsonb, 'asset_current', false, null, 190),
  ('FJ', 'default', '1400', 'Prepayments', '{}'::jsonb, 'asset_prepayments', false, null, 200),
  ('FJ', 'default', '1410', 'Accrued income', '{}'::jsonb, 'asset_prepayments', false, null, 210),
  ('FJ', 'default', '1600', 'Land and buildings — cost', '{}'::jsonb, 'asset_fixed', false, null, 220),
  ('FJ', 'default', '1601', 'Land and buildings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 230),
  ('FJ', 'default', '1610', 'Leasehold improvements — cost', '{}'::jsonb, 'asset_fixed', false, null, 240),
  ('FJ', 'default', '1611', 'Leasehold improvements — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 250),
  ('FJ', 'default', '1620', 'Plant and machinery — cost', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('FJ', 'default', '1621', 'Plant and machinery — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('FJ', 'default', '1630', 'Office equipment — cost', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('FJ', 'default', '1631', 'Office equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('FJ', 'default', '1640', 'Computers — cost', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('FJ', 'default', '1641', 'Computers — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('FJ', 'default', '1650', 'Furniture and fittings — cost', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('FJ', 'default', '1651', 'Furniture and fittings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('FJ', 'default', '1660', 'Motor vehicles — cost', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('FJ', 'default', '1661', 'Motor vehicles — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('FJ', 'default', '1670', 'Right-of-use assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('FJ', 'default', '1671', 'Right-of-use assets — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('FJ', 'default', '1700', 'Investment property', '{}'::jsonb, 'asset_non_current', false, null, 380),
  ('FJ', 'default', '1750', 'Intangible assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 390),
  ('FJ', 'default', '1751', 'Intangible assets — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 400),
  ('FJ', 'default', '1760', 'Goodwill', '{}'::jsonb, 'asset_fixed', false, null, 410),
  ('FJ', 'default', '1800', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('FJ', 'default', '1810', 'Investments in joint ventures', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('FJ', 'default', '1830', 'Long-term financial assets', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('FJ', 'default', '1840', 'Long-term deposits', '{}'::jsonb, 'asset_non_current', false, null, 450),
  ('FJ', 'default', '1900', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('FJ', 'default', '2000', 'Trade payables', '{}'::jsonb, 'liability_payable', true, null, 470),
  ('FJ', 'default', '2010', 'Accrued expenses', '{}'::jsonb, 'liability_current', false, null, 480),
  ('FJ', 'default', '2020', 'Other payables', '{}'::jsonb, 'liability_current', false, null, 490),
  ('FJ', 'default', '2030', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 500),
  ('FJ', 'default', '2040', 'Deposits received from customers', '{}'::jsonb, 'liability_current', false, null, 510),
  ('FJ', 'default', '2100', 'VAT output tax', '{}'::jsonb, 'liability_current', false, null, 520),
  ('FJ', 'default', '2110', 'VAT payable to FRCS — net of a filed return', '{}'::jsonb, 'liability_current', true, null, 530),
  ('FJ', 'default', '2125', 'Import VAT payable to FRCS Customs at the border', '{}'::jsonb, 'liability_current', false, null, 540),
  ('FJ', 'default', '2126', 'VAT on imported capital goods — held until paid', '{}'::jsonb, 'liability_current', false, null, 550),
  ('FJ', 'default', '2140', 'PAYE (Pay-As-You-Earn) withheld and payable to FRCS', '{}'::jsonb, 'liability_current', false, null, 560),
  ('FJ', 'default', '2150', 'FNPF (Fiji National Provident Fund) contributions payable', '{}'::jsonb, 'liability_current', false, null, 570),
  ('FJ', 'default', '2155', 'Excise duty payable', '{}'::jsonb, 'liability_current', false, null, 580),
  ('FJ', 'default', '2160', 'Withholding taxes payable to FRCS', '{}'::jsonb, 'liability_current', false, null, 590),
  ('FJ', 'default', '2165', 'Other statutory amounts payable', '{}'::jsonb, 'liability_current', false, null, 600),
  ('FJ', 'default', '2180', 'Salaries payable', '{}'::jsonb, 'liability_current', false, null, 610),
  ('FJ', 'default', '2190', 'Directors'' fees payable', '{}'::jsonb, 'liability_current', false, null, 620),
  ('FJ', 'default', '2200', 'Bank overdraft', '{}'::jsonb, 'liability_current', false, null, 630),
  ('FJ', 'default', '2210', 'Bank loans — current portion', '{}'::jsonb, 'liability_current', false, null, 640),
  ('FJ', 'default', '2220', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 650),
  ('FJ', 'default', '2230', 'Hire purchase — current portion', '{}'::jsonb, 'liability_current', false, null, 660),
  ('FJ', 'default', '2240', 'Corporate credit card', '{}'::jsonb, 'liability_credit_card', false, null, 670),
  ('FJ', 'default', '2250', 'Amounts due to directors', '{}'::jsonb, 'liability_current', false, null, 680),
  ('FJ', 'default', '2300', 'Current tax payable', '{}'::jsonb, 'liability_current', false, null, 690),
  ('FJ', 'default', '2350', 'Provision for unutilised leave', '{}'::jsonb, 'liability_current', false, null, 700),
  ('FJ', 'default', '2360', 'Other provisions — current', '{}'::jsonb, 'liability_current', false, null, 710),
  ('FJ', 'default', '2400', 'Bank loans — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 720),
  ('FJ', 'default', '2410', 'Lease liabilities — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 730),
  ('FJ', 'default', '2420', 'Hire purchase — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 740),
  ('FJ', 'default', '2430', 'Loans from shareholders and directors — non-current', '{}'::jsonb, 'liability_non_current', false, null, 750),
  ('FJ', 'default', '2500', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 760),
  ('FJ', 'default', '2550', 'Provision for reinstatement costs', '{}'::jsonb, 'liability_non_current', false, null, 770),
  ('FJ', 'default', '2990', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 780),
  ('FJ', 'default', '3000', 'Share capital', '{}'::jsonb, 'equity', false, null, 790),
  ('FJ', 'default', '3010', 'Treasury shares', '{}'::jsonb, 'equity', false, null, 800),
  ('FJ', 'default', '3100', 'Other reserves', '{}'::jsonb, 'equity', false, null, 810),
  ('FJ', 'default', '3110', 'Foreign currency translation reserve', '{}'::jsonb, 'equity', false, null, 820),
  ('FJ', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 830),
  ('FJ', 'default', '3210', 'Dividends paid', '{}'::jsonb, 'equity_retained', false, null, 840),
  ('FJ', 'default', '4000', 'Sales of goods', '{}'::jsonb, 'income', false, null, 850),
  ('FJ', 'default', '4010', 'Services rendered', '{}'::jsonb, 'income', false, null, 860),
  ('FJ', 'default', '4020', 'Export sales of goods', '{}'::jsonb, 'income', false, null, 870),
  ('FJ', 'default', '4030', 'Export of services', '{}'::jsonb, 'income', false, null, 880),
  ('FJ', 'default', '4500', 'Interest income', '{}'::jsonb, 'income_other', false, null, 890),
  ('FJ', 'default', '4510', 'Dividend income', '{}'::jsonb, 'income_other', false, null, 900),
  ('FJ', 'default', '4520', 'Rental income', '{}'::jsonb, 'income_other', false, null, 910),
  ('FJ', 'default', '4530', 'Government grants', '{}'::jsonb, 'income_other', false, null, 920),
  ('FJ', 'default', '4700', 'Foreign exchange gains', '{}'::jsonb, 'income_other', false, null, 930),
  ('FJ', 'default', '4750', 'Gain on disposal of property plant and equipment', '{}'::jsonb, 'income_other', false, null, 940),
  ('FJ', 'default', '4790', 'Other income', '{}'::jsonb, 'income_other', false, null, 950),
  ('FJ', 'default', '5000', 'Purchases of goods for resale', '{}'::jsonb, 'expense_direct_cost', false, null, 960),
  ('FJ', 'default', '5010', 'Freight inwards and import duties', '{}'::jsonb, 'expense_direct_cost', false, null, 970),
  ('FJ', 'default', '5020', 'Subcontract costs', '{}'::jsonb, 'expense_direct_cost', false, null, 980),
  ('FJ', 'default', '5100', 'Changes in inventories', '{}'::jsonb, 'expense_direct_cost', false, null, 990),
  ('FJ', 'default', '6000', 'Salaries and wages', '{}'::jsonb, 'expense', false, null, 1000),
  ('FJ', 'default', '6010', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 1010),
  ('FJ', 'default', '6020', 'Directors'' fees', '{}'::jsonb, 'expense', false, null, 1020),
  ('FJ', 'default', '6030', 'FNPF contributions — employer', '{}'::jsonb, 'expense', false, null, 1030),
  ('FJ', 'default', '6035', 'Staff training and welfare', '{}'::jsonb, 'expense', false, null, 1040),
  ('FJ', 'default', '6040', 'Other statutory employment costs', '{}'::jsonb, 'expense', false, null, 1050),
  ('FJ', 'default', '6050', 'Retirement gratuity and end-of-service benefits', '{}'::jsonb, 'expense', false, null, 1060),
  ('FJ', 'default', '6060', 'Staff amenities', '{}'::jsonb, 'expense', false, null, 1070),
  ('FJ', 'default', '6070', 'Staff medical expenses and insurance', '{}'::jsonb, 'expense', false, null, 1080),
  ('FJ', 'default', '6080', 'Staff training', '{}'::jsonb, 'expense', false, null, 1090),
  ('FJ', 'default', '6200', 'Depreciation of property plant and equipment', '{}'::jsonb, 'expense_depreciation', false, null, 1100),
  ('FJ', 'default', '6210', 'Depreciation of right-of-use assets', '{}'::jsonb, 'expense_depreciation', false, null, 1110),
  ('FJ', 'default', '6220', 'Amortisation of intangible assets', '{}'::jsonb, 'expense_depreciation', false, null, 1120),
  ('FJ', 'default', '6300', 'Rent — short-term leases', '{}'::jsonb, 'expense', false, null, 1130),
  ('FJ', 'default', '6310', 'Utilities', '{}'::jsonb, 'expense', false, null, 1140),
  ('FJ', 'default', '6320', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 1150),
  ('FJ', 'default', '6330', 'Cleaning and security services', '{}'::jsonb, 'expense', false, null, 1160),
  ('FJ', 'default', '6340', 'Telephone and internet', '{}'::jsonb, 'expense', false, null, 1170),
  ('FJ', 'default', '6350', 'Software subscriptions', '{}'::jsonb, 'expense', false, null, 1180),
  ('FJ', 'default', '6360', 'Advertising and marketing', '{}'::jsonb, 'expense', false, null, 1190),
  ('FJ', 'default', '6370', 'Travelling', '{}'::jsonb, 'expense', false, null, 1200),
  ('FJ', 'default', '6380', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1210),
  ('FJ', 'default', '6390', 'Entertainment', '{}'::jsonb, 'expense', false, null, 1220),
  ('FJ', 'default', '6400', 'Subscriptions and memberships', '{}'::jsonb, 'expense', false, null, 1230),
  ('FJ', 'default', '6410', 'Insurance', '{}'::jsonb, 'expense', false, null, 1240),
  ('FJ', 'default', '6420', 'Professional fees', '{}'::jsonb, 'expense', false, null, 1250),
  ('FJ', 'default', '6430', 'Audit fees', '{}'::jsonb, 'expense', false, null, 1260),
  ('FJ', 'default', '6440', 'Company secretarial and registration fees', '{}'::jsonb, 'expense', false, null, 1270),
  ('FJ', 'default', '6450', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1280),
  ('FJ', 'default', '6455', 'Donations', '{}'::jsonb, 'expense', false, null, 1290),
  ('FJ', 'default', '6460', 'Printing and stationery', '{}'::jsonb, 'expense', false, null, 1300),
  ('FJ', 'default', '6470', 'Postage and courier', '{}'::jsonb, 'expense', false, null, 1310),
  ('FJ', 'default', '6480', 'Licences permits and local authority fees', '{}'::jsonb, 'expense', false, null, 1320),
  ('FJ', 'default', '6490', 'Royalties', '{}'::jsonb, 'expense', false, null, 1330),
  ('FJ', 'default', '6500', 'Bad debts written off', '{}'::jsonb, 'expense', false, null, 1340),
  ('FJ', 'default', '6510', 'Impairment loss on trade receivables', '{}'::jsonb, 'expense', false, null, 1350),
  ('FJ', 'default', '6900', 'Sponsorship', '{}'::jsonb, 'expense', false, null, 1360),
  ('FJ', 'default', '6950', 'Foreign exchange losses', '{}'::jsonb, 'expense', false, null, 1370),
  ('FJ', 'default', '6960', 'Loss on disposal of property plant and equipment', '{}'::jsonb, 'expense', false, null, 1380),
  ('FJ', 'default', '6990', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1390),
  ('FJ', 'default', '7000', 'Interest on bank loans', '{}'::jsonb, 'expense', false, null, 1400),
  ('FJ', 'default', '7010', 'Interest on lease liabilities', '{}'::jsonb, 'expense', false, null, 1410),
  ('FJ', 'default', '7020', 'Hire purchase interest', '{}'::jsonb, 'expense', false, null, 1420),
  ('FJ', 'default', '7030', 'Interest on loans from related parties and others', '{}'::jsonb, 'expense', false, null, 1430),
  ('FJ', 'default', '8000', 'Current income tax expense', '{}'::jsonb, 'expense', false, null, 1440),
  ('FJ', 'default', '8010', 'Deferred tax expense', '{}'::jsonb, 'expense', false, null, 1450),
  ('FJ', 'default', '8020', 'Under or over provision of income tax in prior years', '{}'::jsonb, 'expense', false, null, 1460)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('FJ', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('FJ', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('FJ', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('FJ', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('FJ', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('FJ', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('FJ', 'FJ-P-0', 'Purchase, exempt or without VAT', '{}'::jsonb, 'A purchase of an exempt supply (for example a financial service), carrying no VAT', 'percent', 0, 'purchase', 'exempt', date '2025-08-01', null, 'VAT Guide, exempt goods and services: no VAT is charged on them, so there is no input tax to claim and no box on the return.', 'E', null, 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-guide', null, null, null, null),
  ('FJ', 'FJ-P-12.5', 'Purchase, standard rate 12.5 %, deductible', '{}'::jsonb, 'A local purchase of goods, services or capital goods at the standard rate, used to make taxable supplies', 'percent', 12.5, 'purchase', 'domestic', date '2025-08-01', null, 'FRCS VAT Guide, rates: 12.5 % (tax fraction 1/9) on goods and services other than exempt and zero-rated ones, from 1 August 2025. Return IRS217, box 7 — VAT on purchases and expenses for which the tax invoicing requirements have been met, excluding imported goods, taken from the input tax schedule. The form has no separate line for capital goods.', 'S', null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-return-instructions', null, null, null, null),
  ('FJ', 'FJ-P-12.5-NC', 'Purchase, standard rate 12.5 %, input tax not allowed', '{}'::jsonb, 'A purchase on which input tax is not claimed — the VAT joins the cost', 'percent', 12.5, 'purchase', 'domestic', date '2025-08-01', null, 'VAT Guide, claiming input tax credits: a credit needs a tax invoice, use in the business and no link to exempt supplies. Which purchases are barred is the preparer''s judgement; the pack lists none. The VAT joins the cost and the code posts to no box, since the return has no line for it.', 'S', null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-guide', null, null, null, null),
  ('FJ', 'FJ-P-IMP', 'Purchase of imported goods, 12.5 % VAT paid at the border', '{}'::jsonb, 'Imported goods: the VAT is invoiced by Customs at the border and claimed as input tax in box 8', 'percent', 12.5, 'purchase', 'import', date '2025-08-01', null, 'FRCS VAT Guide, rates: 12.5 % (tax fraction 1/9) on goods and services other than exempt and zero-rated ones, from 1 August 2025. Return IRS217, box 8 — total VAT paid to or invoiced by Customs for imports, under the business''s name and used for the business (instructions, box 8). The VAT owed to FRCS Customs sits on the import control account until paid.', null, null, 150, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-return-instructions', null, null, null, null),
  ('FJ', 'FJ-S-12.5', 'Sale, standard rate 12.5 %', '{}'::jsonb, 'A taxable supply of goods or services made in Fiji by a registered person, neither zero-rated nor exempt', 'percent', 12.5, 'sale', 'domestic', date '2025-08-01', null, 'FRCS VAT Guide, rates: 12.5 % (tax fraction 1/9) on goods and services other than exempt and zero-rated ones, from 1 August 2025. Return IRS217, box 3 — supplies subject to VAT (box 1 less box 2, VAT included) and box 4 — the VAT charged, box 3 × the tax fraction.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-rates', null, null, null, null),
  ('FJ', 'FJ-S-EX', 'Sale, exempt', '{}'::jsonb, 'A supply the First Schedule exempts — financial services, residential accommodation, educational services by an educational institution', 'percent', 0, 'sale', 'exempt', date '2025-08-01', null, 'VAT Guide, exempt goods and services: financial services, residential accommodation (whatever the turnover), educational services of an educational institution and the goods and services incidental to them, and the others of the First Schedule of the VAT Act 1991. No VAT is charged and no input tax is deductible. An exempt supply is outside box 1 of the return (Tax Talk on the return lines), so the code posts to no box.', 'E', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-guide', null, null, null, null),
  ('FJ', 'FJ-S-ZR', 'Sale, zero-rated (other than export)', '{}'::jsonb, 'A zero-rated supply made in Fiji that is not an export — the essential items and prescribed medicines of the Second Schedule, ship stores, the sale of a going concern to another registered person and the like', 'percent', 0, 'sale', 'domestic', date '2025-08-01', null, 'VAT Guide, rates: 0 % covers exports, supplies of ship stores, the sale of a going concern to another registered person, services in connection with goods situated outside Fiji and the others of the Second Schedule; the rate table of FRCS adds the 21 essential items (from 1 April 2022) and prescribed medicines (from 1 August 2023). One tax code carries the whole list; which item applies is the preparer''s judgement. Return, boxes 1 and 2.', 'Z', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-guide', null, null, null, null),
  ('FJ', 'FJ-S-ZR-EXP', 'Sale, zero-rated (export)', '{}'::jsonb, 'Goods exported or a service supplied to a person outside Fiji, taxable at 0 %', 'percent', 0, 'sale', 'export', date '2025-08-01', null, 'VAT Guide, rates: 0 % applies to exports (subject to certain conditions) and to the other supplies of the Second Schedule of the VAT Act 1991. A zero-rated supply is declared in boxes 1 and 2 of the return and keeps the input tax credit (Tax Talk on the return lines). Which conditions apply to an export is the preparer''s judgement.', 'G', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-guide', null, null, null, null)
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
    ('FJ-P-0', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('FJ-P-0', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('FJ-P-12.5', 'invoice', 'base', 100, null, '7', array['7']::text[], 100, 'FJ-VAT', 10),
    ('FJ-P-12.5', 'invoice', 'tax', 100, '1150', '7', array['7']::text[], 100, 'FJ-VAT', 20),
    ('FJ-P-12.5', 'credit_note', 'base', 100, null, '7', array['7']::text[], -100, 'FJ-VAT', 10),
    ('FJ-P-12.5', 'credit_note', 'tax', 100, '1150', '7', array['7']::text[], -100, 'FJ-VAT', 20),
    ('FJ-P-12.5-NC', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('FJ-P-12.5-NC', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('FJ-P-12.5-NC', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('FJ-P-12.5-NC', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('FJ-P-IMP', 'invoice', 'base', 100, null, '8', array['8']::text[], 100, 'FJ-VAT', 10),
    ('FJ-P-IMP', 'invoice', 'tax', 100, '1150', '8', array['8']::text[], 100, 'FJ-VAT', 20),
    ('FJ-P-IMP', 'invoice', 'tax', -100, '2125', null, null, 100, null, 30),
    ('FJ-P-IMP', 'credit_note', 'base', 100, null, '8', array['8']::text[], -100, 'FJ-VAT', 10),
    ('FJ-P-IMP', 'credit_note', 'tax', 100, '1150', '8', array['8']::text[], -100, 'FJ-VAT', 20),
    ('FJ-P-IMP', 'credit_note', 'tax', -100, '2125', null, null, 100, null, 30),
    ('FJ-S-12.5', 'invoice', 'base', 100, null, '3a', array['3a']::text[], 100, 'FJ-VAT', 10),
    ('FJ-S-12.5', 'invoice', 'tax', 100, '2100', '4', array['4']::text[], 100, 'FJ-VAT', 20),
    ('FJ-S-12.5', 'credit_note', 'base', 100, null, '3a', array['3a']::text[], -100, 'FJ-VAT', 10),
    ('FJ-S-12.5', 'credit_note', 'tax', 100, '2100', '4', array['4']::text[], -100, 'FJ-VAT', 20),
    ('FJ-S-EX', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('FJ-S-EX', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('FJ-S-ZR', 'invoice', 'base', 100, null, '2', array['2']::text[], 100, 'FJ-VAT', 10),
    ('FJ-S-ZR', 'credit_note', 'base', 100, null, '2', array['2']::text[], -100, 'FJ-VAT', 10),
    ('FJ-S-ZR-EXP', 'invoice', 'base', 100, null, '2', array['2']::text[], 100, 'FJ-VAT', 10),
    ('FJ-S-ZR-EXP', 'credit_note', 'base', 100, null, '2', array['2']::text[], -100, 'FJ-VAT', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'FJ' and t.code = v.tax_code
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
  ('FJ', 'FJ-VAT', 'VAT return (IRS217)', array['month', 'quarter', 'year']::declaration_period[], 'month'::declaration_period, date '2025-08-01', null, 'FRCS Value Added Tax Return, form IRS217: thirteen boxes in three steps — output tax (1 to 6), input tax (7 to 12) and the amount to pay or refund (13). The return is filed monthly above FJ$300,000 of annual gross turnover, three-monthly or yearly below (VAT Guide, chapter 10). The form is VAT-inclusive on the sales side: box 1 and box 3 are totals here (exclusive base plus tax) and the exclusive figures sit in the boxes 2 and 3a. Boxes 5, 9 and 11 (adjustments, apportionment) are the preparer''s: declared and empty.', true,'last_day_of_month_after_period'::filing_deadline_rule, null, null, 'Section 33 of the VAT Act as quoted by FRCS — the return is due on or before the last day of the month following the last day of every taxable period: January 2025 monthly return by 28 February 2025; January–March 2024 quarter by 30 April 2024; calendar year 2023 by 31 January 2024 (VAT Guide, chapter 10). Payment is due with the return.', 'vat-rates', null)
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
  ('FJ', 'FJ-VAT', '1', 'total', 'Box 1 — Total taxable supplies for the period (VAT included, zero-rated supplies included)', '{}'::jsonb, 10, null, array['2:base', '3']::text[], '{}'::text[], null, null, false, false, null, 'Form IRS217, box 1 — the total taxable supplies of the period including VAT and the zero-rated supplies; exempt supplies are not in it. Here box 2 plus box 3.', 'vat-return'),
  ('FJ', 'FJ-VAT', '2', 'base', 'Box 2 — Zero-rated supplies included in box 1', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form IRS217, box 2 — the zero-rated supplies of the period, included in box 1 (exports and the other zero-rated supplies).', 'vat-return'),
  ('FJ', 'FJ-VAT', '3', 'total', 'Box 3 — Supplies subject to VAT (box 1 less box 2, VAT included)', '{}'::jsonb, 30, null, array['3a:base', '4:tax']::text[], '{}'::text[], null, null, false, false, null, 'Form IRS217, box 3 — box 1 less box 2, the supplies charged with VAT, VAT included. Here the exclusive base of box 3a plus the VAT of box 4.', 'vat-return'),
  ('FJ', 'FJ-VAT', '3a', 'base', 'Box 3a — Supplies subject to VAT, VAT excluded', '{}'::jsonb, 35, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Not a box of the form: the exclusive value of the supplies of box 3, which the engine posts and from which box 3 is rebuilt.', 'vat-return-instructions'),
  ('FJ', 'FJ-VAT', '4', 'tax', 'Box 4 — VAT charged by you (box 3 × tax fraction)', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form IRS217, box 4 — box 3 multiplied by the tax fraction: 1/9 at 12.5 % (FRCS rate table), 3/23 at 15 %.', 'vat-rates'),
  ('FJ', 'FJ-VAT', '5', 'tax', 'Box 5 — VAT on output adjustments', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form IRS217, box 5 and panel 1 — goods and services taken for private use, bartered, given as fringe benefits, bad debts recovered, debit notes issued, credit notes received and the like. Declared and empty: an adjustment is a decision of the preparer, no tax code posts to it.', 'vat-return-instructions'),
  ('FJ', 'FJ-VAT', '6', 'total', 'Box 6 — Total output tax (box 4 plus box 5)', '{}'::jsonb, 60, null, array['4', '5']::text[], '{}'::text[], null, null, false, false, null, 'Form IRS217, box 6 — the total VAT charged on taxable supplies.', 'vat-return'),
  ('FJ', 'FJ-VAT', '7', 'base', 'Box 7 — Purchases and expenses, VAT excluded (basis of box 7)', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The purchases on which the VAT of box 7 is claimed; the form asks for the VAT only, the value is kept for the reader.', 'vat-return-instructions'),
  ('FJ', 'FJ-VAT', '7', 'tax', 'Box 7 — Total VAT on purchases and expenses (tax invoicing requirements met, imports excluded)', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form IRS217, box 7 — the VAT of the input tax schedule, which must meet the invoicing requirements; it excludes imported goods.', 'vat-return-instructions'),
  ('FJ', 'FJ-VAT', '8', 'base', 'Box 8 — Imports, customs value (basis of box 8)', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The imported goods whose VAT is claimed in box 8; the form asks for the VAT only.', 'vat-return-instructions'),
  ('FJ', 'FJ-VAT', '8', 'tax', 'Box 8 — Total VAT paid to or invoiced by Customs for imports', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form IRS217, box 8 — the VAT invoiced by Customs on goods imported under the business''s name and used in the business.', 'vat-return-instructions'),
  ('FJ', 'FJ-VAT', '9', 'tax', 'Box 9 — VAT on input adjustments', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form IRS217, box 9 and panel 2 — bad debts written off, credit notes issued, debit notes received and the VAT refundable on a change of accounting basis. Declared and empty, for the reason given at box 5.', 'vat-return-instructions'),
  ('FJ', 'FJ-VAT', '10', 'total', 'Box 10 — Total VAT on purchases, credit adjustments and expenses (boxes 7 + 8 + 9)', '{}'::jsonb, 120, null, array['7:tax', '8:tax', '9']::text[], '{}'::text[], null, null, false, false, null, 'Form IRS217, box 10 — boxes 7, 8 and 9 added.', 'vat-return'),
  ('FJ', 'FJ-VAT', '11', 'tax', 'Box 11 — VAT on purchases not wholly used in making taxable supplies', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form IRS217, box 11 and panel 3 — the part of the input tax that matches the supplies not subject to VAT, unless those are 5 % of the supplies or FJ$4,000 at most, whichever is less. Declared and empty: the apportionment is a decision of the preparer.', 'vat-return-instructions'),
  ('FJ', 'FJ-VAT', '12', 'total', 'Box 12 — Total VAT incurred on taxable purchases (box 10 less box 11)', '{}'::jsonb, 140, null, array['10']::text[], array['11']::text[], null, null, false, false, null, 'Form IRS217, box 12.', 'vat-return'),
  ('FJ', 'FJ-VAT', '13', 'total', 'Box 13 — Amount to pay (positive) or refund due (negative) (box 6 less box 12)', '{}'::jsonb, 150, null, array['6']::text[], array['12']::text[], null, null, false, false, null, 'Form IRS217, box 13 — box 6 less box 12: positive is VAT payable, negative is the refund due. An amount under FJ$5 is not remitted and not refunded (instructions), a rule the engine does not apply.', 'vat-return')
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
  ('FJ-IFRS-IS', 'FJ', 'default', 'Statement of profit or loss', 'income_statement', 'IFRS', date '2014-01-20', null, 'IAS 1 asks for a statement of financial position and a statement of profit or loss; expenses are analysed by nature, which these lines follow. No Fiji text prescribing a layout of the statements was found, so the statement is presented as IFRS-style on the pack''s own chart.', 'ias-1', null, null, '{}'::jsonb),
  ('FJ-IFRS-SFP', 'FJ', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS', date '2014-01-20', null, 'IAS 1 asks for a statement of financial position and a statement of profit or loss; expenses are analysed by nature, which these lines follow. No Fiji text prescribing a layout of the statements was found, so the statement is presented as IFRS-style on the pack''s own chart.', 'ias-1', 'combined', 'Result of the current financial year', '{}'::jsonb)
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
  ('FJ-IFRS-IS', '1', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-IS', '2', null, 'Other income', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-IS', '3', null, 'Purchases and changes in inventories', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-IS', '4', null, 'Employee benefits expense', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-IS', '5', null, 'Depreciation and amortisation', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-IS', '6', null, 'Other operating expenses', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-IS', '7', null, 'Finance costs', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-IS', '8', null, 'Profit before tax', '{}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('FJ-IFRS-IS', '9', null, 'Income tax expense', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-IS', '10', null, 'Profit for the year', '{}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, null, null),
  ('FJ-IFRS-SFP', 'CA', null, 'Current assets', '{}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5', 'CA.6']::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'CA.1', null, 'Cash and cash equivalents', '{}'::jsonb, 11, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'CA.2', null, 'Trade and other receivables', '{}'::jsonb, 12, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'CA.3', null, 'Inventories', '{}'::jsonb, 13, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'CA.4', null, 'Financial assets', '{}'::jsonb, 14, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'CA.5', null, 'Current tax recoverable', '{}'::jsonb, 15, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'CA.6', null, 'Prepayments and accrued income', '{}'::jsonb, 16, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'NCA', null, 'Non-current assets', '{}'::jsonb, 20, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4', 'NCA.5', 'NCA.6', 'NCA.7']::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'NCA.1', null, 'Property, plant and equipment', '{}'::jsonb, 21, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'NCA.2', null, 'Investment property', '{}'::jsonb, 22, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'NCA.3', null, 'Intangible assets', '{}'::jsonb, 23, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'NCA.4', null, 'Investments in associates', '{}'::jsonb, 24, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'NCA.5', null, 'Investments in joint ventures', '{}'::jsonb, 25, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'NCA.6', null, 'Financial assets', '{}'::jsonb, 26, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'NCA.7', null, 'Deferred tax assets', '{}'::jsonb, 27, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'TA', null, 'Total assets', '{}'::jsonb, 30, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'CL', null, 'Current liabilities', '{}'::jsonb, 40, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4', 'CL.5']::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'CL.1', null, 'Trade and other payables', '{}'::jsonb, 41, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'CL.2', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 42, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'CL.3', null, 'Amounts due to directors', '{}'::jsonb, 43, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'CL.4', null, 'Current tax payable', '{}'::jsonb, 44, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'CL.5', null, 'Provisions', '{}'::jsonb, 45, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'NCL', null, 'Non-current liabilities', '{}'::jsonb, 50, 1, true, array['NCL.1', 'NCL.2', 'NCL.3']::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'NCL.1', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 51, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'NCL.2', null, 'Deferred tax liabilities', '{}'::jsonb, 52, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'NCL.3', null, 'Provisions', '{}'::jsonb, 53, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'TL', null, 'Total liabilities', '{}'::jsonb, 60, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'NA', null, 'Net assets', '{}'::jsonb, 70, 1, true, array['TA']::text[], array['TL']::text[], null, null, null),
  ('FJ-IFRS-SFP', 'EQ', null, 'Equity', '{}'::jsonb, 80, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'EQ.1', null, 'Share capital', '{}'::jsonb, 81, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'EQ.2', null, 'Other reserves', '{}'::jsonb, 82, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FJ-IFRS-SFP', 'EQ.3', null, 'Retained earnings', '{}'::jsonb, 83, -1, false, '{}'::text[], '{}'::text[], null, null, null)
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
 where r.statement_code in ('FJ-IFRS-IS', 'FJ-IFRS-SFP')
   and (r.statement_code, r.line_code, r.sequence) not in (
     values ('FJ-IFRS-IS', '1', 10),
            ('FJ-IFRS-IS', '2', 10),
            ('FJ-IFRS-IS', '3', 10),
            ('FJ-IFRS-IS', '4', 10),
            ('FJ-IFRS-IS', '5', 10),
            ('FJ-IFRS-IS', '6', 10),
            ('FJ-IFRS-IS', '7', 10),
            ('FJ-IFRS-IS', '9', 10),
            ('FJ-IFRS-SFP', 'CA.1', 10),
            ('FJ-IFRS-SFP', 'CA.2', 10),
            ('FJ-IFRS-SFP', 'CA.3', 10),
            ('FJ-IFRS-SFP', 'CA.4', 10),
            ('FJ-IFRS-SFP', 'CA.5', 10),
            ('FJ-IFRS-SFP', 'CA.6', 10),
            ('FJ-IFRS-SFP', 'NCA.1', 10),
            ('FJ-IFRS-SFP', 'NCA.2', 10),
            ('FJ-IFRS-SFP', 'NCA.3', 10),
            ('FJ-IFRS-SFP', 'NCA.4', 10),
            ('FJ-IFRS-SFP', 'NCA.5', 10),
            ('FJ-IFRS-SFP', 'NCA.6', 10),
            ('FJ-IFRS-SFP', 'NCA.7', 10),
            ('FJ-IFRS-SFP', 'CL.1', 10),
            ('FJ-IFRS-SFP', 'CL.1', 20),
            ('FJ-IFRS-SFP', 'CL.2', 10),
            ('FJ-IFRS-SFP', 'CL.3', 10),
            ('FJ-IFRS-SFP', 'CL.4', 10),
            ('FJ-IFRS-SFP', 'CL.5', 10),
            ('FJ-IFRS-SFP', 'NCL.1', 10),
            ('FJ-IFRS-SFP', 'NCL.2', 10),
            ('FJ-IFRS-SFP', 'NCL.3', 10),
            ('FJ-IFRS-SFP', 'EQ.1', 10),
            ('FJ-IFRS-SFP', 'EQ.2', 10),
            ('FJ-IFRS-SFP', 'EQ.3', 10)
   );

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('FJ-IFRS-IS', '1', 10, 'code_range', '4000', '4030', null, 'any'),
    ('FJ-IFRS-IS', '2', 10, 'code_range', '4500', '4790', null, 'any'),
    ('FJ-IFRS-IS', '3', 10, 'code_range', '5000', '5100', null, 'any'),
    ('FJ-IFRS-IS', '4', 10, 'code_range', '6000', '6080', null, 'any'),
    ('FJ-IFRS-IS', '5', 10, 'code_range', '6200', '6220', null, 'any'),
    ('FJ-IFRS-IS', '6', 10, 'code_range', '6300', '6990', null, 'any'),
    ('FJ-IFRS-IS', '7', 10, 'code_range', '7000', '7030', null, 'any'),
    ('FJ-IFRS-IS', '9', 10, 'code_range', '8000', '8020', null, 'any'),
    ('FJ-IFRS-SFP', 'CA.1', 10, 'code_range', '1000', '1040', null, 'any'),
    ('FJ-IFRS-SFP', 'CA.2', 10, 'code_range', '1100', '1160', null, 'any'),
    ('FJ-IFRS-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('FJ-IFRS-SFP', 'CA.4', 10, 'account_code', '1300', null, null, 'any'),
    ('FJ-IFRS-SFP', 'CA.5', 10, 'account_code', '1350', null, null, 'any'),
    ('FJ-IFRS-SFP', 'CA.6', 10, 'code_range', '1400', '1410', null, 'any'),
    ('FJ-IFRS-SFP', 'NCA.1', 10, 'code_range', '1600', '1671', null, 'any'),
    ('FJ-IFRS-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('FJ-IFRS-SFP', 'NCA.3', 10, 'code_range', '1750', '1760', null, 'any'),
    ('FJ-IFRS-SFP', 'NCA.4', 10, 'account_code', '1800', null, null, 'any'),
    ('FJ-IFRS-SFP', 'NCA.5', 10, 'account_code', '1810', null, null, 'any'),
    ('FJ-IFRS-SFP', 'NCA.6', 10, 'code_range', '1830', '1840', null, 'any'),
    ('FJ-IFRS-SFP', 'NCA.7', 10, 'account_code', '1900', null, null, 'any'),
    ('FJ-IFRS-SFP', 'CL.1', 10, 'code_range', '2000', '2190', null, 'any'),
    ('FJ-IFRS-SFP', 'CL.1', 20, 'account_code', '2990', null, null, 'credit'),
    ('FJ-IFRS-SFP', 'CL.2', 10, 'code_range', '2200', '2240', null, 'any'),
    ('FJ-IFRS-SFP', 'CL.3', 10, 'account_code', '2250', null, null, 'any'),
    ('FJ-IFRS-SFP', 'CL.4', 10, 'account_code', '2300', null, null, 'any'),
    ('FJ-IFRS-SFP', 'CL.5', 10, 'code_range', '2350', '2360', null, 'any'),
    ('FJ-IFRS-SFP', 'NCL.1', 10, 'code_range', '2400', '2430', null, 'any'),
    ('FJ-IFRS-SFP', 'NCL.2', 10, 'account_code', '2500', null, null, 'any'),
    ('FJ-IFRS-SFP', 'NCL.3', 10, 'account_code', '2550', null, null, 'any'),
    ('FJ-IFRS-SFP', 'EQ.1', 10, 'code_range', '3000', '3010', null, 'any'),
    ('FJ-IFRS-SFP', 'EQ.2', 10, 'code_range', '3100', '3110', null, 'any'),
    ('FJ-IFRS-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('FJ', 'Fiji', '{}'::jsonb, array['en']::text[], 'FJD', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, 'month'::declaration_period)
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
  numbering_legal_reference     = 'The tax invoice must state the words “tax invoice” (VAT Guide; instructions of the return); no text read states how invoices are numbered. `sequential` and the number format are conventions of this pack and not rules of the law.',
  numbering_source_key          = 'vat-guide',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_date',
  tax_point_legal_reference     = 'VAT Guide, chapter 10 — on the invoice basis VAT is accounted for at the earlier of the tax invoice, a payment received and the delivery; the payment basis needs the approval of the CEO of FRCS (public or local authorities, non-profit bodies, or taxable supplies under FJ$100,000 over 12 months). `invoice_date` is the pack''s simplification of the invoice basis, and the payment basis is a gap recorded in the README.',
  tax_point_source_key          = 'vat-guide',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No structured e-invoice standard, Peppol profile or clearance system of FRCS was found in the texts read; returns are filed and paid on the TPOS portal, which does not take invoices. `obligation` is `none` for want of a text, not on a finding that none exists.',
  einvoice_source_key           = 'frcs-portal',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'FJ';

update country_defaults set
  tax_payee_name       = 'Fiji Revenue and Customs Service (FRCS)',
  tax_payee_source_key = 'frcs-portal'
 where country = 'FJ';
