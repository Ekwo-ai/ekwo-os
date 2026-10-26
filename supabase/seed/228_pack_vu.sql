-- Ekwo OS — Vanuatu: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/vu at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build vu`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Value Added Tax Act [Cap. 247], Consolidated Edition 2020 — section 5 (time of supply), 10 and Schedules 1 and 2 (exempt supplies and importations), 11 (rate of 15 %, 0 % for the supplies of Schedule 3), 12 (registration above VT 4 million), 15 (taxable periods: one month, or three months for a person under VT 8 million who applies), 16 (returns, due the 27th of the following month), 17 (invoice or payments basis; payments basis when no election), 19 (tax payable), 21 (tax invoices), Schedule 3 (zero-rated supplies) (Government of Vanuatu — Department of Customs and Inland Revenue (DCIR))
--     https://vanuatucustoms.gov.vu/images/Laws_Regulations/VAT/247_Value_Added_Tax_Consolidated_2020.pdf
--   Value Added Tax Return, form CT 205 (Value Added Tax Act [Cap 247]): sixteen numbered boxes — 5 to 10 the VAT on sales and income (box 5 total sales including VAT, box 6 zero-rated supplies, box 7 = box 5 less box 6, box 8 = box 7 divided by 7.6667, box 9 adjustments, box 10 = boxes 8 and 9), 11 to 15 the VAT on purchases and expenses (box 11 purchases including VAT but without imports, box 12 = box 11 divided by 7.6667, box 13 VAT paid to Customs on imported goods, box 14 adjustments, box 15 = boxes 12, 13 and 14) and box 16 the difference between boxes 10 and 15 (refund or VAT to pay); the pay-in slip carries boxes 17 to 19 (Government of Vanuatu — Department of Customs and Inland Revenue (DCIR))
--     https://vanuatucustoms.gov.vu/images/Forms/rates_taxes_forms/VAT_Return_Form_English.xlsx
--   Value added tax — introduction: VAT at 15 % on most goods and services, registration above VT 4 million of taxable supplies in 12 months (voluntary below), exempt supplies (financial services, residential rental, education, donated goods of a non-profit body) and zero-rated supplies (exports), monthly return or quarterly below VT 8 million, due the 27th of the following month (Government of Vanuatu — Department of Customs and Inland Revenue (DCIR))
--     https://vanuatucustoms.gov.vu/taxes-and-licensing/taxes/value-added-tax-vat/introduction.html
--   Change of VAT rate to 15 per cent — the Parliament raised the rate from 12.5 % to 15 % from 1 January 2018; VAT-inclusive prices divide by 7.6667 (3/23) to find the VAT, VAT-exclusive prices multiply by 3/20 (Government of Vanuatu — Department of Customs and Inland Revenue (DCIR))
--     https://vanuatucustoms.gov.vu/images/VAT/VAT_Rate_Change-Calculations_English.pdf
--   Filing your VAT Return — due date (27th of the month, or the next working day), payment, refunds, the late filing penalty (VT 30,000 for an individual, VT 50,000 for an entity, then a daily penalty), the late payment penalty (5 %) and the late payment interest (20 % a year, daily) (Government of Vanuatu — Department of Customs and Inland Revenue (DCIR))
--     https://vanuatucustoms.gov.vu/images/Brochures/IRD/eng/Filing_your_VAT_Return_21.pdf
--   VAT application for registration form — the person who carries on a taxable activity applies within 21 days of becoming liable; the form asks for the accounting basis (invoice or payments) and the taxable period (monthly, or three-monthly under VT 8 million) (Government of Vanuatu — Department of Customs and Inland Revenue (DCIR))
--     https://vanuatucustoms.gov.vu/images/Forms/VAT/VAT_Application_for_Registration_English.pdf
--   Tax Administration Act No. 37 of 2018 — returns, assessments, penalties and interest for the taxes the Department administers, VAT included (Government of Vanuatu — Department of Customs and Inland Revenue (DCIR))
--     https://vanuatucustoms.gov.vu/images/TAA/Tax_Administration_Act_No_37_of_2018.pdf
--   IAS 1 Presentation of Financial Statements — the statement of financial position and the statement of profit or loss, expenses analysed by nature; no Vanuatu text prescribing a layout or a chart of accounts was found (IFRS Foundation)
--     https://www.ifrs.org/issued-standards/list-of-standards/ias-1-presentation-of-financial-statements/
--   Department of Customs and Inland Revenue — tax administration portal (forms, brochures, legislation, the VAT return and the registration application) (Government of Vanuatu — Department of Customs and Inland Revenue (DCIR))
--     https://vanuatucustoms.gov.vu
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('VU', 'Vanuatu', '0.1.0', date '2026-10-27', '20261023124650', 'community', null, null, '338a949ac55cb0dcf7b786dfe6a8471d22367c1a609e180a04c8f5a3a4b91ac6', '[{"key":"vat-act","title":"Value Added Tax Act [Cap. 247], Consolidated Edition 2020 — section 5 (time of supply), 10 and Schedules 1 and 2 (exempt supplies and importations), 11 (rate of 15 %, 0 % for the supplies of Schedule 3), 12 (registration above VT 4 million), 15 (taxable periods: one month, or three months for a person under VT 8 million who applies), 16 (returns, due the 27th of the following month), 17 (invoice or payments basis; payments basis when no election), 19 (tax payable), 21 (tax invoices), Schedule 3 (zero-rated supplies)","publisher":"Government of Vanuatu — Department of Customs and Inland Revenue (DCIR)","url":"https://vanuatucustoms.gov.vu/images/Laws_Regulations/VAT/247_Value_Added_Tax_Consolidated_2020.pdf","consulted_on":"2026-10-27","kind":"law"},{"key":"vat-return","title":"Value Added Tax Return, form CT 205 (Value Added Tax Act [Cap 247]): sixteen numbered boxes — 5 to 10 the VAT on sales and income (box 5 total sales including VAT, box 6 zero-rated supplies, box 7 = box 5 less box 6, box 8 = box 7 divided by 7.6667, box 9 adjustments, box 10 = boxes 8 and 9), 11 to 15 the VAT on purchases and expenses (box 11 purchases including VAT but without imports, box 12 = box 11 divided by 7.6667, box 13 VAT paid to Customs on imported goods, box 14 adjustments, box 15 = boxes 12, 13 and 14) and box 16 the difference between boxes 10 and 15 (refund or VAT to pay); the pay-in slip carries boxes 17 to 19","publisher":"Government of Vanuatu — Department of Customs and Inland Revenue (DCIR)","url":"https://vanuatucustoms.gov.vu/images/Forms/rates_taxes_forms/VAT_Return_Form_English.xlsx","consulted_on":"2026-10-27","kind":"form"},{"key":"vat-intro","title":"Value added tax — introduction: VAT at 15 % on most goods and services, registration above VT 4 million of taxable supplies in 12 months (voluntary below), exempt supplies (financial services, residential rental, education, donated goods of a non-profit body) and zero-rated supplies (exports), monthly return or quarterly below VT 8 million, due the 27th of the following month","publisher":"Government of Vanuatu — Department of Customs and Inland Revenue (DCIR)","url":"https://vanuatucustoms.gov.vu/taxes-and-licensing/taxes/value-added-tax-vat/introduction.html","consulted_on":"2026-10-27","kind":"guidance"},{"key":"vat-rate-change","title":"Change of VAT rate to 15 per cent — the Parliament raised the rate from 12.5 % to 15 % from 1 January 2018; VAT-inclusive prices divide by 7.6667 (3/23) to find the VAT, VAT-exclusive prices multiply by 3/20","publisher":"Government of Vanuatu — Department of Customs and Inland Revenue (DCIR)","url":"https://vanuatucustoms.gov.vu/images/VAT/VAT_Rate_Change-Calculations_English.pdf","consulted_on":"2026-10-27","kind":"guidance"},{"key":"vat-filing","title":"Filing your VAT Return — due date (27th of the month, or the next working day), payment, refunds, the late filing penalty (VT 30,000 for an individual, VT 50,000 for an entity, then a daily penalty), the late payment penalty (5 %) and the late payment interest (20 % a year, daily)","publisher":"Government of Vanuatu — Department of Customs and Inland Revenue (DCIR)","url":"https://vanuatucustoms.gov.vu/images/Brochures/IRD/eng/Filing_your_VAT_Return_21.pdf","consulted_on":"2026-10-27","kind":"guidance"},{"key":"vat-registration","title":"VAT application for registration form — the person who carries on a taxable activity applies within 21 days of becoming liable; the form asks for the accounting basis (invoice or payments) and the taxable period (monthly, or three-monthly under VT 8 million)","publisher":"Government of Vanuatu — Department of Customs and Inland Revenue (DCIR)","url":"https://vanuatucustoms.gov.vu/images/Forms/VAT/VAT_Application_for_Registration_English.pdf","consulted_on":"2026-10-27","kind":"form"},{"key":"tax-admin-act","title":"Tax Administration Act No. 37 of 2018 — returns, assessments, penalties and interest for the taxes the Department administers, VAT included","publisher":"Government of Vanuatu — Department of Customs and Inland Revenue (DCIR)","url":"https://vanuatucustoms.gov.vu/images/TAA/Tax_Administration_Act_No_37_of_2018.pdf","consulted_on":"2026-10-27","kind":"law"},{"key":"ias-1","title":"IAS 1 Presentation of Financial Statements — the statement of financial position and the statement of profit or loss, expenses analysed by nature; no Vanuatu text prescribing a layout or a chart of accounts was found","publisher":"IFRS Foundation","url":"https://www.ifrs.org/issued-standards/list-of-standards/ias-1-presentation-of-financial-statements/","consulted_on":"2026-10-27","kind":"guidance"},{"key":"tax-portal","title":"Department of Customs and Inland Revenue — tax administration portal (forms, brochures, legislation, the VAT return and the registration application)","publisher":"Government of Vanuatu — Department of Customs and Inland Revenue (DCIR)","url":"https://vanuatucustoms.gov.vu","consulted_on":"2026-10-27","kind":"portal"}]'::jsonb)
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
  ('VU', 'default', 'Vanuatu reference chart of accounts', '{}'::jsonb, true, 'companies', array['VU-IFRS-IS', 'VU-IFRS-SFP']::text[], null, 'There is no legal chart of accounts in the texts read for Vanuatu, and no text read names a standard setter or a framework for company accounts. This chart is original: four digits, blocked so that each range reaches one line of the IFRS-style statements below (IAS 1, expenses by nature), with the accounts a Vanuatu trading company keeps — VAT output and input tax, import VAT owed to Customs at the border, and the liabilities for withholding and contributions.', 'ias-1')
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
  ('VU', 'default', '1000', 'Petty cash', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('VU', 'default', '1010', 'Current account — VUV', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('VU', 'default', '1020', 'Fixed deposits placed for three months or less', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('VU', 'default', '1030', 'Foreign currency account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('VU', 'default', '1040', 'Cash in transit — card and mobile-payment settlements', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('VU', 'default', '1100', 'Trade receivables', '{}'::jsonb, 'asset_receivable', true, null, 60),
  ('VU', 'default', '1110', 'Trade receivables — allowance for impairment', '{}'::jsonb, 'asset_current', false, null, 70),
  ('VU', 'default', '1120', 'Other receivables', '{}'::jsonb, 'asset_current', false, null, 80),
  ('VU', 'default', '1130', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 90),
  ('VU', 'default', '1140', 'Deposits paid', '{}'::jsonb, 'asset_current', false, null, 100),
  ('VU', 'default', '1150', 'VAT input tax', '{}'::jsonb, 'asset_current', false, null, 110),
  ('VU', 'default', '1155', 'VAT refundable by the Department of Customs and Inland Revenue — net of a filed return', '{}'::jsonb, 'asset_current', true, null, 120),
  ('VU', 'default', '1160', 'Advances to staff', '{}'::jsonb, 'asset_current', false, null, 130),
  ('VU', 'default', '1200', 'Inventories — goods for resale', '{}'::jsonb, 'asset_current', false, null, 140),
  ('VU', 'default', '1210', 'Inventories — raw materials', '{}'::jsonb, 'asset_current', false, null, 150),
  ('VU', 'default', '1220', 'Inventories — work in progress', '{}'::jsonb, 'asset_current', false, null, 160),
  ('VU', 'default', '1230', 'Inventories — finished goods', '{}'::jsonb, 'asset_current', false, null, 170),
  ('VU', 'default', '1300', 'Short-term investments', '{}'::jsonb, 'asset_current', false, null, 180),
  ('VU', 'default', '1350', 'Current tax recoverable', '{}'::jsonb, 'asset_current', false, null, 190),
  ('VU', 'default', '1400', 'Prepayments', '{}'::jsonb, 'asset_prepayments', false, null, 200),
  ('VU', 'default', '1410', 'Accrued income', '{}'::jsonb, 'asset_prepayments', false, null, 210),
  ('VU', 'default', '1600', 'Land and buildings — cost', '{}'::jsonb, 'asset_fixed', false, null, 220),
  ('VU', 'default', '1601', 'Land and buildings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 230),
  ('VU', 'default', '1610', 'Leasehold improvements — cost', '{}'::jsonb, 'asset_fixed', false, null, 240),
  ('VU', 'default', '1611', 'Leasehold improvements — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 250),
  ('VU', 'default', '1620', 'Plant and machinery — cost', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('VU', 'default', '1621', 'Plant and machinery — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('VU', 'default', '1630', 'Office equipment — cost', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('VU', 'default', '1631', 'Office equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('VU', 'default', '1640', 'Computers — cost', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('VU', 'default', '1641', 'Computers — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('VU', 'default', '1650', 'Furniture and fittings — cost', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('VU', 'default', '1651', 'Furniture and fittings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('VU', 'default', '1660', 'Motor vehicles — cost', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('VU', 'default', '1661', 'Motor vehicles — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('VU', 'default', '1670', 'Right-of-use assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('VU', 'default', '1671', 'Right-of-use assets — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('VU', 'default', '1700', 'Investment property', '{}'::jsonb, 'asset_non_current', false, null, 380),
  ('VU', 'default', '1750', 'Intangible assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 390),
  ('VU', 'default', '1751', 'Intangible assets — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 400),
  ('VU', 'default', '1760', 'Goodwill', '{}'::jsonb, 'asset_fixed', false, null, 410),
  ('VU', 'default', '1800', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('VU', 'default', '1810', 'Investments in joint ventures', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('VU', 'default', '1830', 'Long-term financial assets', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('VU', 'default', '1840', 'Long-term deposits', '{}'::jsonb, 'asset_non_current', false, null, 450),
  ('VU', 'default', '1900', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('VU', 'default', '2000', 'Trade payables', '{}'::jsonb, 'liability_payable', true, null, 470),
  ('VU', 'default', '2010', 'Accrued expenses', '{}'::jsonb, 'liability_current', false, null, 480),
  ('VU', 'default', '2020', 'Other payables', '{}'::jsonb, 'liability_current', false, null, 490),
  ('VU', 'default', '2030', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 500),
  ('VU', 'default', '2040', 'Deposits received from customers', '{}'::jsonb, 'liability_current', false, null, 510),
  ('VU', 'default', '2100', 'VAT output tax', '{}'::jsonb, 'liability_current', false, null, 520),
  ('VU', 'default', '2110', 'VAT payable to the Department of Customs and Inland Revenue — net of a filed return', '{}'::jsonb, 'liability_current', true, null, 530),
  ('VU', 'default', '2125', 'Import VAT payable to Customs at the border', '{}'::jsonb, 'liability_current', false, null, 540),
  ('VU', 'default', '2126', 'VAT on imported capital goods — held until paid', '{}'::jsonb, 'liability_current', false, null, 550),
  ('VU', 'default', '2140', 'Payroll deductions withheld and payable', '{}'::jsonb, 'liability_current', false, null, 560),
  ('VU', 'default', '2150', 'Superannuation contributions payable', '{}'::jsonb, 'liability_current', false, null, 570),
  ('VU', 'default', '2155', 'Excise duty payable', '{}'::jsonb, 'liability_current', false, null, 580),
  ('VU', 'default', '2160', 'Other taxes withheld and payable to the Department of Customs and Inland Revenue', '{}'::jsonb, 'liability_current', false, null, 590),
  ('VU', 'default', '2165', 'Other statutory amounts payable', '{}'::jsonb, 'liability_current', false, null, 600),
  ('VU', 'default', '2180', 'Salaries payable', '{}'::jsonb, 'liability_current', false, null, 610),
  ('VU', 'default', '2190', 'Directors'' fees payable', '{}'::jsonb, 'liability_current', false, null, 620),
  ('VU', 'default', '2200', 'Bank overdraft', '{}'::jsonb, 'liability_current', false, null, 630),
  ('VU', 'default', '2210', 'Bank loans — current portion', '{}'::jsonb, 'liability_current', false, null, 640),
  ('VU', 'default', '2220', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 650),
  ('VU', 'default', '2230', 'Hire purchase — current portion', '{}'::jsonb, 'liability_current', false, null, 660),
  ('VU', 'default', '2240', 'Corporate credit card', '{}'::jsonb, 'liability_credit_card', false, null, 670),
  ('VU', 'default', '2250', 'Amounts due to directors', '{}'::jsonb, 'liability_current', false, null, 680),
  ('VU', 'default', '2300', 'Current tax payable', '{}'::jsonb, 'liability_current', false, null, 690),
  ('VU', 'default', '2350', 'Provision for unutilised leave', '{}'::jsonb, 'liability_current', false, null, 700),
  ('VU', 'default', '2360', 'Other provisions — current', '{}'::jsonb, 'liability_current', false, null, 710),
  ('VU', 'default', '2400', 'Bank loans — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 720),
  ('VU', 'default', '2410', 'Lease liabilities — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 730),
  ('VU', 'default', '2420', 'Hire purchase — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 740),
  ('VU', 'default', '2430', 'Loans from shareholders and directors — non-current', '{}'::jsonb, 'liability_non_current', false, null, 750),
  ('VU', 'default', '2500', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 760),
  ('VU', 'default', '2550', 'Provision for reinstatement costs', '{}'::jsonb, 'liability_non_current', false, null, 770),
  ('VU', 'default', '2990', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 780),
  ('VU', 'default', '3000', 'Share capital', '{}'::jsonb, 'equity', false, null, 790),
  ('VU', 'default', '3010', 'Treasury shares', '{}'::jsonb, 'equity', false, null, 800),
  ('VU', 'default', '3100', 'Other reserves', '{}'::jsonb, 'equity', false, null, 810),
  ('VU', 'default', '3110', 'Foreign currency translation reserve', '{}'::jsonb, 'equity', false, null, 820),
  ('VU', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 830),
  ('VU', 'default', '3210', 'Dividends paid', '{}'::jsonb, 'equity_retained', false, null, 840),
  ('VU', 'default', '4000', 'Sales of goods', '{}'::jsonb, 'income', false, null, 850),
  ('VU', 'default', '4010', 'Services rendered', '{}'::jsonb, 'income', false, null, 860),
  ('VU', 'default', '4020', 'Export sales of goods', '{}'::jsonb, 'income', false, null, 870),
  ('VU', 'default', '4030', 'Export of services', '{}'::jsonb, 'income', false, null, 880),
  ('VU', 'default', '4500', 'Interest income', '{}'::jsonb, 'income_other', false, null, 890),
  ('VU', 'default', '4510', 'Dividend income', '{}'::jsonb, 'income_other', false, null, 900),
  ('VU', 'default', '4520', 'Rental income', '{}'::jsonb, 'income_other', false, null, 910),
  ('VU', 'default', '4530', 'Government grants', '{}'::jsonb, 'income_other', false, null, 920),
  ('VU', 'default', '4700', 'Foreign exchange gains', '{}'::jsonb, 'income_other', false, null, 930),
  ('VU', 'default', '4750', 'Gain on disposal of property plant and equipment', '{}'::jsonb, 'income_other', false, null, 940),
  ('VU', 'default', '4790', 'Other income', '{}'::jsonb, 'income_other', false, null, 950),
  ('VU', 'default', '5000', 'Purchases of goods for resale', '{}'::jsonb, 'expense_direct_cost', false, null, 960),
  ('VU', 'default', '5010', 'Freight inwards and import duties', '{}'::jsonb, 'expense_direct_cost', false, null, 970),
  ('VU', 'default', '5020', 'Subcontract costs', '{}'::jsonb, 'expense_direct_cost', false, null, 980),
  ('VU', 'default', '5100', 'Changes in inventories', '{}'::jsonb, 'expense_direct_cost', false, null, 990),
  ('VU', 'default', '6000', 'Salaries and wages', '{}'::jsonb, 'expense', false, null, 1000),
  ('VU', 'default', '6010', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 1010),
  ('VU', 'default', '6020', 'Directors'' fees', '{}'::jsonb, 'expense', false, null, 1020),
  ('VU', 'default', '6030', 'Superannuation contributions — employer', '{}'::jsonb, 'expense', false, null, 1030),
  ('VU', 'default', '6035', 'Staff training and welfare', '{}'::jsonb, 'expense', false, null, 1040),
  ('VU', 'default', '6040', 'Other statutory employment costs', '{}'::jsonb, 'expense', false, null, 1050),
  ('VU', 'default', '6050', 'Retirement gratuity and end-of-service benefits', '{}'::jsonb, 'expense', false, null, 1060),
  ('VU', 'default', '6060', 'Staff amenities', '{}'::jsonb, 'expense', false, null, 1070),
  ('VU', 'default', '6070', 'Staff medical expenses and insurance', '{}'::jsonb, 'expense', false, null, 1080),
  ('VU', 'default', '6080', 'Staff training', '{}'::jsonb, 'expense', false, null, 1090),
  ('VU', 'default', '6200', 'Depreciation of property plant and equipment', '{}'::jsonb, 'expense_depreciation', false, null, 1100),
  ('VU', 'default', '6210', 'Depreciation of right-of-use assets', '{}'::jsonb, 'expense_depreciation', false, null, 1110),
  ('VU', 'default', '6220', 'Amortisation of intangible assets', '{}'::jsonb, 'expense_depreciation', false, null, 1120),
  ('VU', 'default', '6300', 'Rent — short-term leases', '{}'::jsonb, 'expense', false, null, 1130),
  ('VU', 'default', '6310', 'Utilities', '{}'::jsonb, 'expense', false, null, 1140),
  ('VU', 'default', '6320', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 1150),
  ('VU', 'default', '6330', 'Cleaning and security services', '{}'::jsonb, 'expense', false, null, 1160),
  ('VU', 'default', '6340', 'Telephone and internet', '{}'::jsonb, 'expense', false, null, 1170),
  ('VU', 'default', '6350', 'Software subscriptions', '{}'::jsonb, 'expense', false, null, 1180),
  ('VU', 'default', '6360', 'Advertising and marketing', '{}'::jsonb, 'expense', false, null, 1190),
  ('VU', 'default', '6370', 'Travelling', '{}'::jsonb, 'expense', false, null, 1200),
  ('VU', 'default', '6380', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1210),
  ('VU', 'default', '6390', 'Entertainment', '{}'::jsonb, 'expense', false, null, 1220),
  ('VU', 'default', '6400', 'Subscriptions and memberships', '{}'::jsonb, 'expense', false, null, 1230),
  ('VU', 'default', '6410', 'Insurance', '{}'::jsonb, 'expense', false, null, 1240),
  ('VU', 'default', '6420', 'Professional fees', '{}'::jsonb, 'expense', false, null, 1250),
  ('VU', 'default', '6430', 'Audit fees', '{}'::jsonb, 'expense', false, null, 1260),
  ('VU', 'default', '6440', 'Company secretarial and registration fees', '{}'::jsonb, 'expense', false, null, 1270),
  ('VU', 'default', '6450', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1280),
  ('VU', 'default', '6455', 'Donations', '{}'::jsonb, 'expense', false, null, 1290),
  ('VU', 'default', '6460', 'Printing and stationery', '{}'::jsonb, 'expense', false, null, 1300),
  ('VU', 'default', '6470', 'Postage and courier', '{}'::jsonb, 'expense', false, null, 1310),
  ('VU', 'default', '6480', 'Licences permits and local authority fees', '{}'::jsonb, 'expense', false, null, 1320),
  ('VU', 'default', '6490', 'Royalties', '{}'::jsonb, 'expense', false, null, 1330),
  ('VU', 'default', '6500', 'Bad debts written off', '{}'::jsonb, 'expense', false, null, 1340),
  ('VU', 'default', '6510', 'Impairment loss on trade receivables', '{}'::jsonb, 'expense', false, null, 1350),
  ('VU', 'default', '6900', 'Sponsorship', '{}'::jsonb, 'expense', false, null, 1360),
  ('VU', 'default', '6950', 'Foreign exchange losses', '{}'::jsonb, 'expense', false, null, 1370),
  ('VU', 'default', '6960', 'Loss on disposal of property plant and equipment', '{}'::jsonb, 'expense', false, null, 1380),
  ('VU', 'default', '6990', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1390),
  ('VU', 'default', '7000', 'Interest on bank loans', '{}'::jsonb, 'expense', false, null, 1400),
  ('VU', 'default', '7010', 'Interest on lease liabilities', '{}'::jsonb, 'expense', false, null, 1410),
  ('VU', 'default', '7020', 'Hire purchase interest', '{}'::jsonb, 'expense', false, null, 1420),
  ('VU', 'default', '7030', 'Interest on loans from related parties and others', '{}'::jsonb, 'expense', false, null, 1430),
  ('VU', 'default', '8000', 'Current income tax expense', '{}'::jsonb, 'expense', false, null, 1440),
  ('VU', 'default', '8010', 'Deferred tax expense', '{}'::jsonb, 'expense', false, null, 1450),
  ('VU', 'default', '8020', 'Under or over provision of income tax in prior years', '{}'::jsonb, 'expense', false, null, 1460)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('VU', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('VU', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('VU', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('VU', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('VU', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('VU', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('VU', 'VU-P-0', 'Purchase, no VAT', '{}'::jsonb, 'A purchase from a supplier who charged no VAT — exempt, unregistered or outside Vanuatu', 'percent', 0, 'purchase', 'exempt', date '2018-01-01', null, 'Value Added Tax Act [Cap. 247], s. 10 and Schedule 1 — a purchase from an exempt supplier (financial services, residential rental, education…) or outside the scope of the tax carries no VAT and no box of form CT 205.', null, null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('VU', 'VU-P-15', 'Purchase, standard rate 15 %', '{}'::jsonb, 'Goods or services bought in Vanuatu from a registered person for the taxable activity, with a tax invoice', 'percent', 15, 'purchase', 'domestic', date '2018-01-01', null, 'Value Added Tax Act [Cap. 247], s. 11(1) and s. 19 — the VAT paid on local purchases and expenses of the taxable activity is deducted from the VAT collected; the tax invoice (s. 21) is the proof. Form CT 205: box 11 is the purchases including VAT (imports excluded), box 12 the VAT paid, box 11 divided by 7.6667. The engine posts the exclusive base to box 11a (not a box of the form) and the VAT to box 12.', 'S', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('VU', 'VU-P-15-NC', 'Purchase, standard rate 15 % — no input credit', '{}'::jsonb, 'A purchase carrying 15 % VAT that gives no input credit — bought for exempt supplies or for private use', 'percent', 15, 'purchase', 'domestic', date '2018-01-01', null, 'Value Added Tax Act [Cap. 247], s. 19 — the credit is for VAT on purchases used in the taxable activity; where no credit is allowed the VAT is part of the cost of the purchase and appears in no box of the return. This code books the VAT into the expense or asset account (tax on base) and posts nothing to the form.', 'S', null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('VU', 'VU-P-IMP', 'Purchase, import of goods', '{}'::jsonb, 'Goods imported into Vanuatu, VAT paid to the Customs Service at the border', 'percent', 15, 'purchase', 'import', date '2018-01-01', null, 'Value Added Tax Act [Cap. 247], s. 11(1)(b) — on importation the tax is 15 % of the customs value plus the customs duty, the excise tax and the cost of transport and insurance to Vanuatu, collected by Customs at the border. Form CT 205, box 13: the VAT paid to Customs on imported goods, which box 11 excludes (“do not include imported goods here”). The customs value goes to box 13a, which is not a box of the form.', null, null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('VU', 'VU-S-15', 'Sale, standard rate 15 %', '{}'::jsonb, 'A taxable supply of goods or services made in Vanuatu by a registered person, neither zero-rated nor exempt', 'percent', 15, 'sale', 'domestic', date '2018-01-01', null, 'Value Added Tax Act [Cap. 247], s. 11(1) — the rate of value added tax is 15 % of the value of the supply (12.5 % before the increase of 1 January 2018). Form CT 205: box 5 is the total sales including VAT, box 6 the zero-rated supplies, box 7 the difference (taxable sales, VAT included) and box 8 the VAT collected, box 7 divided by 7.6667 (the tax fraction 3/23). The engine posts the exclusive base to box 7a, which is not a box of the form, and the VAT to box 8.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('VU', 'VU-S-EX', 'Sale, exempt', '{}'::jsonb, 'A supply the VAT Act exempts — financial services, residential rental, education, donated goods of a non-profit body', 'percent', 0, 'sale', 'exempt', date '2018-01-01', null, 'Value Added Tax Act [Cap. 247], s. 10 and Schedule 1 — exempt supplies: (1) financial services, (2) donated goods or services of a non-profit body, (3) residential accommodation by way of hire, (4) rental of leasehold land used for a dwelling, (5) the sale of a dwelling used for five years for those rentals, (6) education by a registered educational institution. An exempt supply is not a taxable supply, carries no input credit and is disregarded for the registration threshold (s. 12(2)(a)). Form CT 205 has no box for exempt sales: they appear on no line of the return.', 'E', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('VU', 'VU-S-ZR', 'Sale, zero-rated (other)', '{}'::jsonb, 'A zero-rated supply made in Vanuatu that is not an export — international transport, aid projects, going concerns, supplies to international organisations', 'percent', 0, 'sale', 'domestic', date '2018-01-01', null, 'Value Added Tax Act [Cap. 247], s. 11(2) and Schedule 3 — besides exports: (2) goods situated outside Vanuatu at the time of supply, (3) international transport of passengers and goods, (7) approved aid projects, (9) the transfer of a going concern between registered persons by written agreement, (11) services to overseas postal organisations, (12) services to a visiting vessel, (13) payments to a State agency under an Appropriation Act, (14) supplies to an international organisation holding an approval certificate. One tax code carries the list; which clause applies is the preparer''s judgement. Box 6 of form CT 205.', 'Z', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('VU', 'VU-S-ZR-EXP', 'Sale, zero-rated (export)', '{}'::jsonb, 'Goods exported or supplied for use outside Vanuatu, or services performed or used outside Vanuatu, taxable at 0 %', 'percent', 0, 'sale', 'export', date '2018-01-01', null, 'Value Added Tax Act [Cap. 247], s. 11(2) and Schedule 3, clause 1 — a supply of goods the registered person exports, or that is supplied for consumption or use outside Vanuatu, and clause 4 — services physically performed outside Vanuatu, are zero-rated; clause 5 adds services to a non-resident outside Vanuatu with limits. Zero-rated supplies are box 6 of form CT 205, included in box 5; the supplier keeps the input tax credit.', 'G', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null)
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
    ('VU-P-15', 'invoice', 'base', 100, null, '11a', array['11a']::text[], 100, 'VU-VAT', 10),
    ('VU-P-15', 'invoice', 'tax', 100, '1150', '12', array['12']::text[], 100, 'VU-VAT', 20),
    ('VU-P-15', 'credit_note', 'base', 100, null, '11a', array['11a']::text[], -100, 'VU-VAT', 10),
    ('VU-P-15', 'credit_note', 'tax', 100, '1150', '12', array['12']::text[], -100, 'VU-VAT', 20),
    ('VU-P-15-NC', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('VU-P-15-NC', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('VU-P-IMP', 'invoice', 'base', 100, null, '13a', array['13a']::text[], 100, 'VU-VAT', 10),
    ('VU-P-IMP', 'invoice', 'tax', 100, '1150', '13', array['13']::text[], 100, 'VU-VAT', 20),
    ('VU-P-IMP', 'invoice', 'tax', -100, '2125', null, null, 100, null, 30),
    ('VU-P-IMP', 'credit_note', 'base', 100, null, '13a', array['13a']::text[], -100, 'VU-VAT', 10),
    ('VU-P-IMP', 'credit_note', 'tax', 100, '1150', '13', array['13']::text[], -100, 'VU-VAT', 20),
    ('VU-P-IMP', 'credit_note', 'tax', -100, '2125', null, null, 100, null, 30),
    ('VU-S-15', 'invoice', 'base', 100, null, '7a', array['7a']::text[], 100, 'VU-VAT', 10),
    ('VU-S-15', 'invoice', 'tax', 100, '2100', '8', array['8']::text[], 100, 'VU-VAT', 20),
    ('VU-S-15', 'credit_note', 'base', 100, null, '7a', array['7a']::text[], -100, 'VU-VAT', 10),
    ('VU-S-15', 'credit_note', 'tax', 100, '2100', '8', array['8']::text[], -100, 'VU-VAT', 20),
    ('VU-S-ZR', 'invoice', 'base', 100, null, '6', array['6']::text[], 100, 'VU-VAT', 10),
    ('VU-S-ZR', 'credit_note', 'base', 100, null, '6', array['6']::text[], -100, 'VU-VAT', 10),
    ('VU-S-ZR-EXP', 'invoice', 'base', 100, null, '6', array['6']::text[], 100, 'VU-VAT', 10),
    ('VU-S-ZR-EXP', 'credit_note', 'base', 100, null, '6', array['6']::text[], -100, 'VU-VAT', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'VU' and t.code = v.tax_code
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
  ('VU', 'VU-VAT', 'VAT return (form CT 205)', array['month', 'quarter']::declaration_period[], null, date '2018-01-01', null, 'Form CT 205, Value Added Tax Return (Value Added Tax Act [Cap 247]): boxes 1 to 4 are the taxpayer''s identity and period, boxes 5 to 10 the VAT on sales and income, boxes 11 to 15 the VAT on purchases and expenses and box 16 the difference (refund or VAT to pay); boxes 17 to 19 are the pay-in slip. The return is filed for a taxable period of one month (Category A) or of three months for a person whose taxable supplies stay under VT 8 million and who applied for it (s. 15 of the Act). The form is VAT-inclusive: boxes 5, 7 and 11 are totals here (exclusive base plus VAT) and the exclusive figures sit in boxes 7a and 11a. Box 16 is signed: negative is the refund. The quarterly periods are anchored on January–March here; the Director may fix other months for a Category B person (s. 15(1)(b)), see the README.', true,'day_of_month_after_period'::filing_deadline_rule, 27, null, 'Value Added Tax Act [Cap. 247], s. 16(1)(b) — the return is due by the 27th day of the month following the taxable period, and if that day is not a working day by the working day that follows; s. 16(1)(a) puts the return of a period ending on 30 November at the 5th of January. The payment is due with the return (form reminders). The rollover to the next working day and the November exception are not computed by the pack.', 'vat-act', null)
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
  ('VU', 'VU-VAT', '5', 'total', 'Box 5 — Total sales and income for the period (VAT included)', '{}'::jsonb, 10, null, array['6:base', '7']::text[], '{}'::text[], null, null, false, false, null, 'Form CT 205, box 5 — the total sales and income of the period including VAT, zero-rated supplies included; exempt supplies are not taxable supplies and the form has no line for them. Here box 6 plus box 7.', 'vat-return'),
  ('VU', 'VU-VAT', '6', 'base', 'Box 6 — Zero-rated supplies included in box 5', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form CT 205, box 6 — the zero-rated supplies of the period (Schedule 3 of the Act), included in box 5.', 'vat-return'),
  ('VU', 'VU-VAT', '7', 'total', 'Box 7 — Taxable sales (box 5 less box 6), VAT included', '{}'::jsonb, 30, null, array['7a:base', '8:tax']::text[], '{}'::text[], null, null, false, false, null, 'Form CT 205, box 7 — box 6 subtracted from box 5, the supplies charged with VAT, VAT included. Here the exclusive base of box 7a plus the VAT of box 8.', 'vat-return'),
  ('VU', 'VU-VAT', '7a', 'base', 'Box 7a — Taxable sales, VAT excluded', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Not a box of the form: the exclusive value of the supplies of box 7, which the engine posts and from which box 7 is rebuilt.', 'vat-return'),
  ('VU', 'VU-VAT', '8', 'tax', 'Box 8 — VAT collected by you (box 7 divided by 7.6667)', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form CT 205, box 8 — box 7 divided by 7.6667, the tax fraction 3/23 of the 15 % rate (15/115).', 'vat-return'),
  ('VU', 'VU-VAT', '9', 'tax', 'Box 9 — Adjustments to VAT collected', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form CT 205, box 9 — adjustments added to the VAT collected (the Department''s VAT guidance). Declared and empty: an adjustment is a decision of the preparer, no tax code posts to it.', 'vat-return'),
  ('VU', 'VU-VAT', '10', 'total', 'Box 10 — Total VAT collected on sales and income (boxes 8 and 9)', '{}'::jsonb, 70, null, array['8', '9']::text[], '{}'::text[], null, null, false, false, null, 'Form CT 205, box 10 — boxes 8 and 9 added.', 'vat-return'),
  ('VU', 'VU-VAT', '11', 'total', 'Box 11 — Total business purchases and expenses (VAT included, imports excluded)', '{}'::jsonb, 80, null, array['11a:base', '12:tax']::text[], '{}'::text[], null, null, false, false, null, 'Form CT 205, box 11 — total business-related purchases and expenses including VAT, imported goods excluded (they go to box 13). Here the exclusive base of box 11a plus the VAT of box 12.', 'vat-return'),
  ('VU', 'VU-VAT', '11a', 'base', 'Box 11a — Local purchases carrying creditable VAT, VAT excluded', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Not a box of the form: the exclusive value of the purchases of box 11, which the engine posts and from which box 11 is rebuilt.', 'vat-return'),
  ('VU', 'VU-VAT', '12', 'tax', 'Box 12 — VAT paid on purchases (box 11 divided by 7.6667)', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form CT 205, box 12 — box 11 divided by 7.6667.', 'vat-return'),
  ('VU', 'VU-VAT', '13', 'tax', 'Box 13 — VAT paid to Customs on imported goods', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form CT 205, box 13 — the VAT paid to Customs on imported goods, 15 % of the customs value plus duty, excise and carriage to Vanuatu (s. 11(1)(b)).', 'vat-return'),
  ('VU', 'VU-VAT', '13a', 'base', 'Box 13a — Imports, value for VAT', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Not a box of the form: the value on which Customs charged the VAT of box 13, which the engine posts for the statement of the tax base.', 'vat-return'),
  ('VU', 'VU-VAT', '14', 'tax', 'Box 14 — Adjustments to VAT paid', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form CT 205, box 14 — adjustments added to the VAT paid (refer to the VAT guide). Declared and empty: an adjustment is a decision of the preparer.', 'vat-return'),
  ('VU', 'VU-VAT', '15', 'total', 'Box 15 — Total VAT paid on purchases and expenses (boxes 12, 13 and 14)', '{}'::jsonb, 140, null, array['12', '13', '14']::text[], '{}'::text[], null, null, false, false, null, 'Form CT 205, box 15 — boxes 12, 13 and 14 added.', 'vat-return'),
  ('VU', 'VU-VAT', '16', 'total', 'Box 16 — VAT to pay (positive) or VAT refund (negative), box 10 less box 15', '{}'::jsonb, 150, null, array['10']::text[], array['15']::text[], null, null, false, false, null, 'Form CT 205, box 16 — the difference between box 10 and box 15: if box 15 is larger the difference is the refund, if box 10 is larger it is VAT to pay. Signed here: negative is the refund. Boxes 17 to 19 of the pay-in slip (the payment, the late payment penalty, the total) are not boxes of the return.', 'vat-return')
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
  ('VU-IFRS-IS', 'VU', 'default', 'Statement of profit or loss', 'income_statement', 'IFRS', date '2024-01-01', null, 'IAS 1 asks for a statement of financial position and a statement of profit or loss; expenses are analysed by nature, which these lines follow. No Vanuatu text prescribing a layout of the statements was found, so the statement is presented as IFRS-style on the pack''s own chart.', 'ias-1', null, null, '{}'::jsonb),
  ('VU-IFRS-SFP', 'VU', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS', date '2024-01-01', null, 'IAS 1 asks for a statement of financial position and a statement of profit or loss; expenses are analysed by nature, which these lines follow. No Vanuatu text prescribing a layout of the statements was found, so the statement is presented as IFRS-style on the pack''s own chart.', 'ias-1', 'combined', 'Result of the current financial year', '{}'::jsonb)
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
  ('VU-IFRS-IS', '1', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-IS', '2', null, 'Other income', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-IS', '3', null, 'Purchases and changes in inventories', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-IS', '4', null, 'Employee benefits expense', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-IS', '5', null, 'Depreciation and amortisation', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-IS', '6', null, 'Other operating expenses', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-IS', '7', null, 'Finance costs', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-IS', '8', null, 'Profit before tax', '{}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('VU-IFRS-IS', '9', null, 'Income tax expense', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-IS', '10', null, 'Profit for the year', '{}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, null, null),
  ('VU-IFRS-SFP', 'CA', null, 'Current assets', '{}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5', 'CA.6']::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'CA.1', null, 'Cash and cash equivalents', '{}'::jsonb, 11, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'CA.2', null, 'Trade and other receivables', '{}'::jsonb, 12, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'CA.3', null, 'Inventories', '{}'::jsonb, 13, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'CA.4', null, 'Financial assets', '{}'::jsonb, 14, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'CA.5', null, 'Current tax recoverable', '{}'::jsonb, 15, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'CA.6', null, 'Prepayments and accrued income', '{}'::jsonb, 16, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'NCA', null, 'Non-current assets', '{}'::jsonb, 20, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4', 'NCA.5', 'NCA.6', 'NCA.7']::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'NCA.1', null, 'Property, plant and equipment', '{}'::jsonb, 21, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'NCA.2', null, 'Investment property', '{}'::jsonb, 22, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'NCA.3', null, 'Intangible assets', '{}'::jsonb, 23, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'NCA.4', null, 'Investments in associates', '{}'::jsonb, 24, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'NCA.5', null, 'Investments in joint ventures', '{}'::jsonb, 25, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'NCA.6', null, 'Financial assets', '{}'::jsonb, 26, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'NCA.7', null, 'Deferred tax assets', '{}'::jsonb, 27, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'TA', null, 'Total assets', '{}'::jsonb, 30, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'CL', null, 'Current liabilities', '{}'::jsonb, 40, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4', 'CL.5']::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'CL.1', null, 'Trade and other payables', '{}'::jsonb, 41, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'CL.2', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 42, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'CL.3', null, 'Amounts due to directors', '{}'::jsonb, 43, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'CL.4', null, 'Current tax payable', '{}'::jsonb, 44, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'CL.5', null, 'Provisions', '{}'::jsonb, 45, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'NCL', null, 'Non-current liabilities', '{}'::jsonb, 50, 1, true, array['NCL.1', 'NCL.2', 'NCL.3']::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'NCL.1', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 51, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'NCL.2', null, 'Deferred tax liabilities', '{}'::jsonb, 52, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'NCL.3', null, 'Provisions', '{}'::jsonb, 53, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'TL', null, 'Total liabilities', '{}'::jsonb, 60, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'NA', null, 'Net assets', '{}'::jsonb, 70, 1, true, array['TA']::text[], array['TL']::text[], null, null, null),
  ('VU-IFRS-SFP', 'EQ', null, 'Equity', '{}'::jsonb, 80, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'EQ.1', null, 'Share capital', '{}'::jsonb, 81, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'EQ.2', null, 'Other reserves', '{}'::jsonb, 82, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VU-IFRS-SFP', 'EQ.3', null, 'Retained earnings', '{}'::jsonb, 83, -1, false, '{}'::text[], '{}'::text[], null, null, null)
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
 where r.statement_code in ('VU-IFRS-IS', 'VU-IFRS-SFP')
   and (r.statement_code, r.line_code, r.sequence) not in (
     values ('VU-IFRS-IS', '1', 10),
            ('VU-IFRS-IS', '2', 10),
            ('VU-IFRS-IS', '3', 10),
            ('VU-IFRS-IS', '4', 10),
            ('VU-IFRS-IS', '5', 10),
            ('VU-IFRS-IS', '6', 10),
            ('VU-IFRS-IS', '7', 10),
            ('VU-IFRS-IS', '9', 10),
            ('VU-IFRS-SFP', 'CA.1', 10),
            ('VU-IFRS-SFP', 'CA.2', 10),
            ('VU-IFRS-SFP', 'CA.3', 10),
            ('VU-IFRS-SFP', 'CA.4', 10),
            ('VU-IFRS-SFP', 'CA.5', 10),
            ('VU-IFRS-SFP', 'CA.6', 10),
            ('VU-IFRS-SFP', 'NCA.1', 10),
            ('VU-IFRS-SFP', 'NCA.2', 10),
            ('VU-IFRS-SFP', 'NCA.3', 10),
            ('VU-IFRS-SFP', 'NCA.4', 10),
            ('VU-IFRS-SFP', 'NCA.5', 10),
            ('VU-IFRS-SFP', 'NCA.6', 10),
            ('VU-IFRS-SFP', 'NCA.7', 10),
            ('VU-IFRS-SFP', 'CL.1', 10),
            ('VU-IFRS-SFP', 'CL.1', 20),
            ('VU-IFRS-SFP', 'CL.2', 10),
            ('VU-IFRS-SFP', 'CL.3', 10),
            ('VU-IFRS-SFP', 'CL.4', 10),
            ('VU-IFRS-SFP', 'CL.5', 10),
            ('VU-IFRS-SFP', 'NCL.1', 10),
            ('VU-IFRS-SFP', 'NCL.2', 10),
            ('VU-IFRS-SFP', 'NCL.3', 10),
            ('VU-IFRS-SFP', 'EQ.1', 10),
            ('VU-IFRS-SFP', 'EQ.2', 10),
            ('VU-IFRS-SFP', 'EQ.3', 10)
   );

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('VU-IFRS-IS', '1', 10, 'code_range', '4000', '4030', null, 'any'),
    ('VU-IFRS-IS', '2', 10, 'code_range', '4500', '4790', null, 'any'),
    ('VU-IFRS-IS', '3', 10, 'code_range', '5000', '5100', null, 'any'),
    ('VU-IFRS-IS', '4', 10, 'code_range', '6000', '6080', null, 'any'),
    ('VU-IFRS-IS', '5', 10, 'code_range', '6200', '6220', null, 'any'),
    ('VU-IFRS-IS', '6', 10, 'code_range', '6300', '6990', null, 'any'),
    ('VU-IFRS-IS', '7', 10, 'code_range', '7000', '7030', null, 'any'),
    ('VU-IFRS-IS', '9', 10, 'code_range', '8000', '8020', null, 'any'),
    ('VU-IFRS-SFP', 'CA.1', 10, 'code_range', '1000', '1040', null, 'any'),
    ('VU-IFRS-SFP', 'CA.2', 10, 'code_range', '1100', '1160', null, 'any'),
    ('VU-IFRS-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('VU-IFRS-SFP', 'CA.4', 10, 'account_code', '1300', null, null, 'any'),
    ('VU-IFRS-SFP', 'CA.5', 10, 'account_code', '1350', null, null, 'any'),
    ('VU-IFRS-SFP', 'CA.6', 10, 'code_range', '1400', '1410', null, 'any'),
    ('VU-IFRS-SFP', 'NCA.1', 10, 'code_range', '1600', '1671', null, 'any'),
    ('VU-IFRS-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('VU-IFRS-SFP', 'NCA.3', 10, 'code_range', '1750', '1760', null, 'any'),
    ('VU-IFRS-SFP', 'NCA.4', 10, 'account_code', '1800', null, null, 'any'),
    ('VU-IFRS-SFP', 'NCA.5', 10, 'account_code', '1810', null, null, 'any'),
    ('VU-IFRS-SFP', 'NCA.6', 10, 'code_range', '1830', '1840', null, 'any'),
    ('VU-IFRS-SFP', 'NCA.7', 10, 'account_code', '1900', null, null, 'any'),
    ('VU-IFRS-SFP', 'CL.1', 10, 'code_range', '2000', '2190', null, 'any'),
    ('VU-IFRS-SFP', 'CL.1', 20, 'account_code', '2990', null, null, 'credit'),
    ('VU-IFRS-SFP', 'CL.2', 10, 'code_range', '2200', '2240', null, 'any'),
    ('VU-IFRS-SFP', 'CL.3', 10, 'account_code', '2250', null, null, 'any'),
    ('VU-IFRS-SFP', 'CL.4', 10, 'account_code', '2300', null, null, 'any'),
    ('VU-IFRS-SFP', 'CL.5', 10, 'code_range', '2350', '2360', null, 'any'),
    ('VU-IFRS-SFP', 'NCL.1', 10, 'code_range', '2400', '2430', null, 'any'),
    ('VU-IFRS-SFP', 'NCL.2', 10, 'account_code', '2500', null, null, 'any'),
    ('VU-IFRS-SFP', 'NCL.3', 10, 'account_code', '2550', null, null, 'any'),
    ('VU-IFRS-SFP', 'EQ.1', 10, 'code_range', '3000', '3010', null, 'any'),
    ('VU-IFRS-SFP', 'EQ.2', 10, 'code_range', '3100', '3110', null, 'any'),
    ('VU-IFRS-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('VU', 'Vanuatu', '{}'::jsonb, array['en']::text[], 'VUV', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, null)
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
  numbering_legal_reference     = 'Value Added Tax Act [Cap. 247], s. 21 — a registered person making a taxable supply to another registered person provides a tax invoice within 28 days of a request, with the particulars of the approved form; a buyer-created tax invoice needs the Director''s approval and the words “buyer created tax invoice – VAT approved”. The text read states no document numbering rule, so numbering is `free`; the number format is a convention of this pack.',
  numbering_source_key          = 'vat-act',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'Value Added Tax Act [Cap. 247], s. 5(1) — a supply takes place at the earliest of the time an invoice is issued and the time a payment is received; s. 17 lets the registered person account for the tax on an invoice basis or on a payments basis, and a person who elects nothing is deemed to be on the payments basis. `invoice_if_issued` states the invoice as the point of the tax where one is issued, the invoice basis; the payments basis and a payment received before the invoice are gaps recorded in the README.',
  tax_point_source_key          = 'vat-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No structured e-invoice standard, Peppol profile or clearance system of the Department was found in the texts read; the VAT return is lodged at the counter, by post or by e-mail. `obligation` is `none` for want of a text, not on a finding that none exists.',
  einvoice_source_key           = 'tax-portal',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'VU';

update country_defaults set
  tax_payee_name       = 'Department of Customs and Inland Revenue (DCIR)',
  tax_payee_source_key = 'tax-portal'
 where country = 'VU';
