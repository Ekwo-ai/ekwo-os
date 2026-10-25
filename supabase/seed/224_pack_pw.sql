-- Ekwo OS — Palau: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/pw at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build pw`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Republic of Palau Public Law (RPPL) No. 11-11, which repeals and replaces Chapter 12 of Title 40 of the Palau National Code: the Palau Goods and Services Tax (PGST) — § 1211 (10 % on a taxable supply and on a supply of imported services, 0 % on a zero-rated supply), § 1212 (zero-rated supplies), § 1213 (the supply of financial services is exempt), § 1214 (10 % on a taxable import, payable at the time of import), § 1241 (input tax credit), § 1261 (net PGST payable for a PGST period = (A + B) - C), § 1262 (an excess of credit is carried forward, and refunded on written application), § 1281 (a return for each PGST period within thirty days after its end), § 1282 (payment by the due date of the return) and the definition of a PGST period as a calendar month (Bureau of Revenue and Taxation (BRT), Ministry of Finance, Republic of Palau)
--     https://www.palaugov.pw/wp-content/uploads/2022/04/RPPL-11-11.pdf
--   Palau Goods and Services Tax Regulations (as of 2 July 2023): § 312 — the PGST payable on imported services is outside the formula of § 1261 when the registered person uses the services wholly to make taxable supplies, and no recipient-created invoice is prepared in that case; § 401 — apportionment of input tax credits for acquisitions made partly to make taxable supplies (Bureau of Revenue and Taxation (BRT), Ministry of Finance, Republic of Palau)
--     https://www.palaugov.pw/wp-content/uploads/Regulations_Palau-Goods-and-Services-Tax.pdf
--   Form Tax 500, Palau Goods & Services Monthly Tax Return (revised 30 July 2022) and its instructions: lines A to C (business outputs), E to H (business inputs), J and K (imported services subject to the reverse charge rules), L and M (business capital assets), N to P (net PGST payable or creditable = N - O), each with an amount excluding PGST in column 1 and the PGST in column 2; the return and the payment are due on or before the thirtieth day of the month following the PGST period; a negative line P is a credit carried forward to the following period (Bureau of Revenue and Taxation (BRT), Ministry of Finance, Republic of Palau)
--     https://www.palaugov.pw/wp-content/uploads/Tax-500-Palau-Goods-Services-Tax-Return-Form.pdf
--   PGST — Input Tax Credit, Tax Returns, Record-keeping: what a creditable acquisition is (a taxable supply by another registered person, a supply of imported services, a taxable import), the documents that support the credit (PGST invoice, customs documentation, recipient-created invoice for imported services, debit or credit note), the monthly self-assessed return lodged by the thirtieth day of the following month and the three-year retention of records (Bureau of Revenue and Taxation (BRT), Ministry of Finance, Republic of Palau)
--     https://www.palaugov.pw/wp-content/uploads/2022/07/PGST-Input-tax-credit-tax-returns-recordkeeping.pdf
--   PGST — Types of supplies: the taxable supplies (goods, services, utilities, telecommunications, leases and licences), the list of zero-rated supplies (exports, aircraft and ship stores, international transport and telecommunications, prescription medicine supplied to a licensed pharmacy, clinic or hospital, and the others) and the exempt supplies (financial services) (Bureau of Revenue and Taxation (BRT), Ministry of Finance, Republic of Palau)
--     https://www.palaugov.pw/taxreform/pgst-types-of-supplies/
--   PGST — Calculating your supplies: registration is compulsory above USD 300,000 of average taxable supplies (the current projected year and the three previous years, divided by four), within seven days of exceeding the threshold; a holder of a Foreign Investment Approval Certificate registers whatever the turnover (Bureau of Revenue and Taxation (BRT), Ministry of Finance, Republic of Palau)
--     https://www.palaugov.pw/executive-branch/ministries/finance/brt/pgst-calculating-your-supplies/
--   Taxpayer calendar for the year 2023: the PGST return of a month is due on the 30th of the month after the PGST period (the January 2023 return on 2 March, thirty days after the end of the period), and a due date that falls on a weekend or a public holiday moves to the next working day (Bureau of Revenue and Taxation (BRT), Ministry of Finance, Republic of Palau)
--     https://www.palaugov.pw/wp-content/uploads/Taxpayer-Calendar_Year-2023-1.pdf
--   IAS 1 Presentation of Financial Statements — the statement of financial position and the statement of profit or loss, expenses analysed by nature; no Palau text prescribing a layout of the statements or a chart of accounts was found, and the IFRS Foundation page of the jurisdiction could not be read (IFRS Foundation)
--     https://www.ifrs.org/issued-standards/list-of-standards/ias-1-presentation-of-financial-statements/
--   Bureau of Revenue and Taxation — tax administration page (filing forms, the Tax Filing App, registration forms, the PGST guidance) (Bureau of Revenue and Taxation (BRT), Ministry of Finance, Republic of Palau)
--     https://www.palaugov.pw/executive-branch/ministries/finance/brt/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('PW', 'Palau', '0.1.0', date '2026-10-25', '20261023124650', 'community', null, null, 'a137173609a5b4e073ad596b538f012df66e8efff1d3ddec6384167de8d7e3ac', '[{"key":"pgst-act","title":"Republic of Palau Public Law (RPPL) No. 11-11, which repeals and replaces Chapter 12 of Title 40 of the Palau National Code: the Palau Goods and Services Tax (PGST) — § 1211 (10 % on a taxable supply and on a supply of imported services, 0 % on a zero-rated supply), § 1212 (zero-rated supplies), § 1213 (the supply of financial services is exempt), § 1214 (10 % on a taxable import, payable at the time of import), § 1241 (input tax credit), § 1261 (net PGST payable for a PGST period = (A + B) - C), § 1262 (an excess of credit is carried forward, and refunded on written application), § 1281 (a return for each PGST period within thirty days after its end), § 1282 (payment by the due date of the return) and the definition of a PGST period as a calendar month","publisher":"Bureau of Revenue and Taxation (BRT), Ministry of Finance, Republic of Palau","url":"https://www.palaugov.pw/wp-content/uploads/2022/04/RPPL-11-11.pdf","consulted_on":"2026-10-25","kind":"law"},{"key":"pgst-regulations","title":"Palau Goods and Services Tax Regulations (as of 2 July 2023): § 312 — the PGST payable on imported services is outside the formula of § 1261 when the registered person uses the services wholly to make taxable supplies, and no recipient-created invoice is prepared in that case; § 401 — apportionment of input tax credits for acquisitions made partly to make taxable supplies","publisher":"Bureau of Revenue and Taxation (BRT), Ministry of Finance, Republic of Palau","url":"https://www.palaugov.pw/wp-content/uploads/Regulations_Palau-Goods-and-Services-Tax.pdf","consulted_on":"2026-10-25","kind":"regulation"},{"key":"pgst-return","title":"Form Tax 500, Palau Goods & Services Monthly Tax Return (revised 30 July 2022) and its instructions: lines A to C (business outputs), E to H (business inputs), J and K (imported services subject to the reverse charge rules), L and M (business capital assets), N to P (net PGST payable or creditable = N - O), each with an amount excluding PGST in column 1 and the PGST in column 2; the return and the payment are due on or before the thirtieth day of the month following the PGST period; a negative line P is a credit carried forward to the following period","publisher":"Bureau of Revenue and Taxation (BRT), Ministry of Finance, Republic of Palau","url":"https://www.palaugov.pw/wp-content/uploads/Tax-500-Palau-Goods-Services-Tax-Return-Form.pdf","consulted_on":"2026-10-25","kind":"form"},{"key":"pgst-itc-returns","title":"PGST — Input Tax Credit, Tax Returns, Record-keeping: what a creditable acquisition is (a taxable supply by another registered person, a supply of imported services, a taxable import), the documents that support the credit (PGST invoice, customs documentation, recipient-created invoice for imported services, debit or credit note), the monthly self-assessed return lodged by the thirtieth day of the following month and the three-year retention of records","publisher":"Bureau of Revenue and Taxation (BRT), Ministry of Finance, Republic of Palau","url":"https://www.palaugov.pw/wp-content/uploads/2022/07/PGST-Input-tax-credit-tax-returns-recordkeeping.pdf","consulted_on":"2026-10-25","kind":"guidance"},{"key":"pgst-supplies","title":"PGST — Types of supplies: the taxable supplies (goods, services, utilities, telecommunications, leases and licences), the list of zero-rated supplies (exports, aircraft and ship stores, international transport and telecommunications, prescription medicine supplied to a licensed pharmacy, clinic or hospital, and the others) and the exempt supplies (financial services)","publisher":"Bureau of Revenue and Taxation (BRT), Ministry of Finance, Republic of Palau","url":"https://www.palaugov.pw/taxreform/pgst-types-of-supplies/","consulted_on":"2026-10-25","kind":"guidance"},{"key":"pgst-threshold","title":"PGST — Calculating your supplies: registration is compulsory above USD 300,000 of average taxable supplies (the current projected year and the three previous years, divided by four), within seven days of exceeding the threshold; a holder of a Foreign Investment Approval Certificate registers whatever the turnover","publisher":"Bureau of Revenue and Taxation (BRT), Ministry of Finance, Republic of Palau","url":"https://www.palaugov.pw/executive-branch/ministries/finance/brt/pgst-calculating-your-supplies/","consulted_on":"2026-10-25","kind":"guidance"},{"key":"taxpayer-calendar","title":"Taxpayer calendar for the year 2023: the PGST return of a month is due on the 30th of the month after the PGST period (the January 2023 return on 2 March, thirty days after the end of the period), and a due date that falls on a weekend or a public holiday moves to the next working day","publisher":"Bureau of Revenue and Taxation (BRT), Ministry of Finance, Republic of Palau","url":"https://www.palaugov.pw/wp-content/uploads/Taxpayer-Calendar_Year-2023-1.pdf","consulted_on":"2026-10-25","kind":"guidance"},{"key":"ias-1","title":"IAS 1 Presentation of Financial Statements — the statement of financial position and the statement of profit or loss, expenses analysed by nature; no Palau text prescribing a layout of the statements or a chart of accounts was found, and the IFRS Foundation page of the jurisdiction could not be read","publisher":"IFRS Foundation","url":"https://www.ifrs.org/issued-standards/list-of-standards/ias-1-presentation-of-financial-statements/","consulted_on":"2026-10-25","kind":"standard"},{"key":"brt-portal","title":"Bureau of Revenue and Taxation — tax administration page (filing forms, the Tax Filing App, registration forms, the PGST guidance)","publisher":"Bureau of Revenue and Taxation (BRT), Ministry of Finance, Republic of Palau","url":"https://www.palaugov.pw/executive-branch/ministries/finance/brt/","consulted_on":"2026-10-25","kind":"portal"}]'::jsonb)
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
  ('PW', 'default', 'Palau reference chart of accounts', '{}'::jsonb, true, 'companies', array['PW-FS-IS', 'PW-FS-SFP']::text[], null, 'There is no legal chart of accounts in the texts read for Palau: no text found prescribes one, nor the layout of the financial statements. This chart is original: four digits, blocked so that each range reaches one line of the IAS 1-style statements below (expenses by nature), with the accounts a Palau trading company keeps — PGST output and input tax, import PGST owed at the time of import, wages and salary tax withheld, social security contributions and other taxes payable.', 'ias-1')
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
  ('PW', 'default', '1000', 'Petty cash', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('PW', 'default', '1010', 'Current account — USD', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('PW', 'default', '1020', 'Fixed deposits placed for three months or less', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('PW', 'default', '1030', 'Foreign currency account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('PW', 'default', '1040', 'Cash in transit — card and mobile-payment settlements', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('PW', 'default', '1100', 'Trade receivables', '{}'::jsonb, 'asset_receivable', true, null, 60),
  ('PW', 'default', '1110', 'Trade receivables — allowance for impairment', '{}'::jsonb, 'asset_current', false, null, 70),
  ('PW', 'default', '1120', 'Other receivables', '{}'::jsonb, 'asset_current', false, null, 80),
  ('PW', 'default', '1130', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 90),
  ('PW', 'default', '1140', 'Deposits paid', '{}'::jsonb, 'asset_current', false, null, 100),
  ('PW', 'default', '1150', 'PGST input tax', '{}'::jsonb, 'asset_current', false, null, 110),
  ('PW', 'default', '1155', 'PGST credit receivable from the BRT — net of a filed return', '{}'::jsonb, 'asset_current', true, null, 120),
  ('PW', 'default', '1160', 'Advances to staff', '{}'::jsonb, 'asset_current', false, null, 130),
  ('PW', 'default', '1200', 'Inventories — goods for resale', '{}'::jsonb, 'asset_current', false, null, 140),
  ('PW', 'default', '1210', 'Inventories — raw materials', '{}'::jsonb, 'asset_current', false, null, 150),
  ('PW', 'default', '1220', 'Inventories — work in progress', '{}'::jsonb, 'asset_current', false, null, 160),
  ('PW', 'default', '1230', 'Inventories — finished goods', '{}'::jsonb, 'asset_current', false, null, 170),
  ('PW', 'default', '1300', 'Short-term investments', '{}'::jsonb, 'asset_current', false, null, 180),
  ('PW', 'default', '1350', 'Current tax recoverable', '{}'::jsonb, 'asset_current', false, null, 190),
  ('PW', 'default', '1400', 'Prepayments', '{}'::jsonb, 'asset_prepayments', false, null, 200),
  ('PW', 'default', '1410', 'Accrued income', '{}'::jsonb, 'asset_prepayments', false, null, 210),
  ('PW', 'default', '1600', 'Land and buildings — cost', '{}'::jsonb, 'asset_fixed', false, null, 220),
  ('PW', 'default', '1601', 'Land and buildings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 230),
  ('PW', 'default', '1610', 'Leasehold improvements — cost', '{}'::jsonb, 'asset_fixed', false, null, 240),
  ('PW', 'default', '1611', 'Leasehold improvements — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 250),
  ('PW', 'default', '1620', 'Plant and machinery — cost', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('PW', 'default', '1621', 'Plant and machinery — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('PW', 'default', '1630', 'Office equipment — cost', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('PW', 'default', '1631', 'Office equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('PW', 'default', '1640', 'Computers — cost', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('PW', 'default', '1641', 'Computers — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('PW', 'default', '1650', 'Furniture and fittings — cost', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('PW', 'default', '1651', 'Furniture and fittings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('PW', 'default', '1660', 'Motor vehicles — cost', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('PW', 'default', '1661', 'Motor vehicles — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('PW', 'default', '1670', 'Right-of-use assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('PW', 'default', '1671', 'Right-of-use assets — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('PW', 'default', '1700', 'Investment property', '{}'::jsonb, 'asset_non_current', false, null, 380),
  ('PW', 'default', '1750', 'Intangible assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 390),
  ('PW', 'default', '1751', 'Intangible assets — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 400),
  ('PW', 'default', '1760', 'Goodwill', '{}'::jsonb, 'asset_fixed', false, null, 410),
  ('PW', 'default', '1800', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('PW', 'default', '1810', 'Investments in joint ventures', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('PW', 'default', '1830', 'Long-term financial assets', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('PW', 'default', '1840', 'Long-term deposits', '{}'::jsonb, 'asset_non_current', false, null, 450),
  ('PW', 'default', '1900', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('PW', 'default', '2000', 'Trade payables', '{}'::jsonb, 'liability_payable', true, null, 470),
  ('PW', 'default', '2010', 'Accrued expenses', '{}'::jsonb, 'liability_current', false, null, 480),
  ('PW', 'default', '2020', 'Other payables', '{}'::jsonb, 'liability_current', false, null, 490),
  ('PW', 'default', '2030', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 500),
  ('PW', 'default', '2040', 'Deposits received from customers', '{}'::jsonb, 'liability_current', false, null, 510),
  ('PW', 'default', '2100', 'PGST output tax', '{}'::jsonb, 'liability_current', false, null, 520),
  ('PW', 'default', '2110', 'PGST payable to the BRT — net of a filed return', '{}'::jsonb, 'liability_current', true, null, 530),
  ('PW', 'default', '2125', 'Import PGST payable at the time of import', '{}'::jsonb, 'liability_current', false, null, 540),
  ('PW', 'default', '2126', 'PGST on imported capital goods — held until paid', '{}'::jsonb, 'liability_current', false, null, 550),
  ('PW', 'default', '2140', 'Wages and salary tax withheld and payable to the BRT', '{}'::jsonb, 'liability_current', false, null, 560),
  ('PW', 'default', '2150', 'Social security contributions payable', '{}'::jsonb, 'liability_current', false, null, 570),
  ('PW', 'default', '2155', 'Excise duty payable', '{}'::jsonb, 'liability_current', false, null, 580),
  ('PW', 'default', '2160', 'Withholding taxes payable to the BRT', '{}'::jsonb, 'liability_current', false, null, 590),
  ('PW', 'default', '2165', 'Other statutory amounts payable', '{}'::jsonb, 'liability_current', false, null, 600),
  ('PW', 'default', '2180', 'Salaries payable', '{}'::jsonb, 'liability_current', false, null, 610),
  ('PW', 'default', '2190', 'Directors'' fees payable', '{}'::jsonb, 'liability_current', false, null, 620),
  ('PW', 'default', '2200', 'Bank overdraft', '{}'::jsonb, 'liability_current', false, null, 630),
  ('PW', 'default', '2210', 'Bank loans — current portion', '{}'::jsonb, 'liability_current', false, null, 640),
  ('PW', 'default', '2220', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 650),
  ('PW', 'default', '2230', 'Hire purchase — current portion', '{}'::jsonb, 'liability_current', false, null, 660),
  ('PW', 'default', '2240', 'Corporate credit card', '{}'::jsonb, 'liability_credit_card', false, null, 670),
  ('PW', 'default', '2250', 'Amounts due to directors', '{}'::jsonb, 'liability_current', false, null, 680),
  ('PW', 'default', '2300', 'Current tax payable', '{}'::jsonb, 'liability_current', false, null, 690),
  ('PW', 'default', '2350', 'Provision for unutilised leave', '{}'::jsonb, 'liability_current', false, null, 700),
  ('PW', 'default', '2360', 'Other provisions — current', '{}'::jsonb, 'liability_current', false, null, 710),
  ('PW', 'default', '2400', 'Bank loans — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 720),
  ('PW', 'default', '2410', 'Lease liabilities — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 730),
  ('PW', 'default', '2420', 'Hire purchase — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 740),
  ('PW', 'default', '2430', 'Loans from shareholders and directors — non-current', '{}'::jsonb, 'liability_non_current', false, null, 750),
  ('PW', 'default', '2500', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 760),
  ('PW', 'default', '2550', 'Provision for reinstatement costs', '{}'::jsonb, 'liability_non_current', false, null, 770),
  ('PW', 'default', '2990', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 780),
  ('PW', 'default', '3000', 'Share capital', '{}'::jsonb, 'equity', false, null, 790),
  ('PW', 'default', '3010', 'Treasury shares', '{}'::jsonb, 'equity', false, null, 800),
  ('PW', 'default', '3100', 'Other reserves', '{}'::jsonb, 'equity', false, null, 810),
  ('PW', 'default', '3110', 'Foreign currency translation reserve', '{}'::jsonb, 'equity', false, null, 820),
  ('PW', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 830),
  ('PW', 'default', '3210', 'Dividends paid', '{}'::jsonb, 'equity_retained', false, null, 840),
  ('PW', 'default', '4000', 'Sales of goods', '{}'::jsonb, 'income', false, null, 850),
  ('PW', 'default', '4010', 'Services rendered', '{}'::jsonb, 'income', false, null, 860),
  ('PW', 'default', '4020', 'Export sales of goods', '{}'::jsonb, 'income', false, null, 870),
  ('PW', 'default', '4030', 'Export of services', '{}'::jsonb, 'income', false, null, 880),
  ('PW', 'default', '4500', 'Interest income', '{}'::jsonb, 'income_other', false, null, 890),
  ('PW', 'default', '4510', 'Dividend income', '{}'::jsonb, 'income_other', false, null, 900),
  ('PW', 'default', '4520', 'Rental income', '{}'::jsonb, 'income_other', false, null, 910),
  ('PW', 'default', '4530', 'Government grants', '{}'::jsonb, 'income_other', false, null, 920),
  ('PW', 'default', '4700', 'Foreign exchange gains', '{}'::jsonb, 'income_other', false, null, 930),
  ('PW', 'default', '4750', 'Gain on disposal of property plant and equipment', '{}'::jsonb, 'income_other', false, null, 940),
  ('PW', 'default', '4790', 'Other income', '{}'::jsonb, 'income_other', false, null, 950),
  ('PW', 'default', '5000', 'Purchases of goods for resale', '{}'::jsonb, 'expense_direct_cost', false, null, 960),
  ('PW', 'default', '5010', 'Freight inwards and import duties', '{}'::jsonb, 'expense_direct_cost', false, null, 970),
  ('PW', 'default', '5020', 'Subcontract costs', '{}'::jsonb, 'expense_direct_cost', false, null, 980),
  ('PW', 'default', '5100', 'Changes in inventories', '{}'::jsonb, 'expense_direct_cost', false, null, 990),
  ('PW', 'default', '6000', 'Salaries and wages', '{}'::jsonb, 'expense', false, null, 1000),
  ('PW', 'default', '6010', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 1010),
  ('PW', 'default', '6020', 'Directors'' fees', '{}'::jsonb, 'expense', false, null, 1020),
  ('PW', 'default', '6030', 'Social security contributions — employer', '{}'::jsonb, 'expense', false, null, 1030),
  ('PW', 'default', '6035', 'Staff training and welfare', '{}'::jsonb, 'expense', false, null, 1040),
  ('PW', 'default', '6040', 'Other statutory employment costs', '{}'::jsonb, 'expense', false, null, 1050),
  ('PW', 'default', '6050', 'Retirement gratuity and end-of-service benefits', '{}'::jsonb, 'expense', false, null, 1060),
  ('PW', 'default', '6060', 'Staff amenities', '{}'::jsonb, 'expense', false, null, 1070),
  ('PW', 'default', '6070', 'Staff medical expenses and insurance', '{}'::jsonb, 'expense', false, null, 1080),
  ('PW', 'default', '6080', 'Staff training', '{}'::jsonb, 'expense', false, null, 1090),
  ('PW', 'default', '6200', 'Depreciation of property plant and equipment', '{}'::jsonb, 'expense_depreciation', false, null, 1100),
  ('PW', 'default', '6210', 'Depreciation of right-of-use assets', '{}'::jsonb, 'expense_depreciation', false, null, 1110),
  ('PW', 'default', '6220', 'Amortisation of intangible assets', '{}'::jsonb, 'expense_depreciation', false, null, 1120),
  ('PW', 'default', '6300', 'Rent — short-term leases', '{}'::jsonb, 'expense', false, null, 1130),
  ('PW', 'default', '6310', 'Utilities', '{}'::jsonb, 'expense', false, null, 1140),
  ('PW', 'default', '6320', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 1150),
  ('PW', 'default', '6330', 'Cleaning and security services', '{}'::jsonb, 'expense', false, null, 1160),
  ('PW', 'default', '6340', 'Telephone and internet', '{}'::jsonb, 'expense', false, null, 1170),
  ('PW', 'default', '6350', 'Software subscriptions', '{}'::jsonb, 'expense', false, null, 1180),
  ('PW', 'default', '6360', 'Advertising and marketing', '{}'::jsonb, 'expense', false, null, 1190),
  ('PW', 'default', '6370', 'Travelling', '{}'::jsonb, 'expense', false, null, 1200),
  ('PW', 'default', '6380', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1210),
  ('PW', 'default', '6390', 'Entertainment', '{}'::jsonb, 'expense', false, null, 1220),
  ('PW', 'default', '6400', 'Subscriptions and memberships', '{}'::jsonb, 'expense', false, null, 1230),
  ('PW', 'default', '6410', 'Insurance', '{}'::jsonb, 'expense', false, null, 1240),
  ('PW', 'default', '6420', 'Professional fees', '{}'::jsonb, 'expense', false, null, 1250),
  ('PW', 'default', '6430', 'Audit fees', '{}'::jsonb, 'expense', false, null, 1260),
  ('PW', 'default', '6440', 'Company secretarial and registration fees', '{}'::jsonb, 'expense', false, null, 1270),
  ('PW', 'default', '6450', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1280),
  ('PW', 'default', '6455', 'Donations', '{}'::jsonb, 'expense', false, null, 1290),
  ('PW', 'default', '6460', 'Printing and stationery', '{}'::jsonb, 'expense', false, null, 1300),
  ('PW', 'default', '6470', 'Postage and courier', '{}'::jsonb, 'expense', false, null, 1310),
  ('PW', 'default', '6480', 'Licences permits and local authority fees', '{}'::jsonb, 'expense', false, null, 1320),
  ('PW', 'default', '6490', 'Royalties', '{}'::jsonb, 'expense', false, null, 1330),
  ('PW', 'default', '6500', 'Bad debts written off', '{}'::jsonb, 'expense', false, null, 1340),
  ('PW', 'default', '6510', 'Impairment loss on trade receivables', '{}'::jsonb, 'expense', false, null, 1350),
  ('PW', 'default', '6900', 'Sponsorship', '{}'::jsonb, 'expense', false, null, 1360),
  ('PW', 'default', '6950', 'Foreign exchange losses', '{}'::jsonb, 'expense', false, null, 1370),
  ('PW', 'default', '6960', 'Loss on disposal of property plant and equipment', '{}'::jsonb, 'expense', false, null, 1380),
  ('PW', 'default', '6990', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1390),
  ('PW', 'default', '7000', 'Interest on bank loans', '{}'::jsonb, 'expense', false, null, 1400),
  ('PW', 'default', '7010', 'Interest on lease liabilities', '{}'::jsonb, 'expense', false, null, 1410),
  ('PW', 'default', '7020', 'Hire purchase interest', '{}'::jsonb, 'expense', false, null, 1420),
  ('PW', 'default', '7030', 'Interest on loans from related parties and others', '{}'::jsonb, 'expense', false, null, 1430),
  ('PW', 'default', '8000', 'Current tax expense — business profits tax', '{}'::jsonb, 'expense', false, null, 1440),
  ('PW', 'default', '8010', 'Deferred tax expense', '{}'::jsonb, 'expense', false, null, 1450),
  ('PW', 'default', '8020', 'Under or over provision of income tax in prior years', '{}'::jsonb, 'expense', false, null, 1460)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('PW', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('PW', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('PW', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('PW', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('PW', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('PW', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('PW', 'PW-P-0', 'Purchase, without PGST', '{}'::jsonb, 'A purchase of an exempt supply, or from a supplier who is not registered for PGST, or of a service bought abroad that is not subject to PGST, carrying no PGST', 'percent', 0, 'purchase', 'exempt', date '2023-01-01', null, 'Return Tax 500, line H, as the instructions word it: the value of all goods and services purchased that were not subject to PGST, including purchases from non-registered suppliers and services bought overseas that are not subject to PGST. There is no PGST to claim.', 'E', null, 150, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pgst-return', null, null, null, null),
  ('PW', 'PW-P-10', 'Purchase, standard rate 10 %, credit allowed', '{}'::jsonb, 'A purchase in Palau of goods, services or capital goods on which 10 % PGST is paid to a registered supplier, used to make taxable supplies', 'percent', 10, 'purchase', 'domestic', date '2023-01-01', null, 'Act § 1241: an input tax credit is allowed for a creditable acquisition — a taxable supply by another registered person — in the PGST period in which the input tax is paid, on a PGST invoice. Return Tax 500, line E, columns 1 and 2; line O adds the credit. The form has no separate line for capital goods: they are in line E, and line M is the preparer''s.', 'S', null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pgst-return', null, null, null, null),
  ('PW', 'PW-P-10-NC', 'Purchase, standard rate 10 %, credit not claimed', '{}'::jsonb, 'A purchase on which the PGST is not claimed as input tax — the PGST joins the cost', 'percent', 10, 'purchase', 'domestic', date '2023-01-01', null, 'Act § 1242 denies the input tax credit in the cases it lists, and Regulations § 401 apportions it for acquisitions made partly for exempt supplies. Which purchases are barred is the preparer''s judgement; the pack lists none. The PGST joins the cost and the code posts to no box of the return.', 'S', null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pgst-act', null, null, null, null),
  ('PW', 'PW-P-IMP', 'Purchase of imported goods, 10 % PGST paid at import', '{}'::jsonb, 'Imported goods: the PGST is collected on the import and claimed as input tax in line G', 'percent', 10, 'purchase', 'import', date '2023-01-01', null, 'Act § 1214: PGST at ten percent (10 %) on the value of a taxable import, payable at the time of import (§ 1282(b)), collected by the Director on the customs declaration (§ 1283). Return Tax 500, line G, columns 1 and 2, to the extent the goods are used to make taxable supplies; line O adds the credit. The PGST owed at the border sits on the import account until it is paid.', null, null, 160, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pgst-act', null, null, null, null),
  ('PW', 'PW-P-RC-SVC', 'Imported service, reverse-charged and credited', '{}'::jsonb, 'A service supplied by an unregistered person outside Palau to a registered person in Palau, for a person who makes exempt supplies as well: the PGST is accounted for by the recipient, who credits it to the extent the service serves taxable supplies', 'percent', 10, 'purchase', 'foreign_services_received', date '2023-01-01', null, 'Act § 1211(a)(2) and § 1261 (component B): the recipient is liable for PGST at 10 % on a supply of imported services; Regulations § 312: the liability falls outside the formula when the services are used wholly for taxable supplies. Return Tax 500, line J — imported services subject to the 10 % reverse charge — and line K — imported services eligible for input tax credit; line N adds line J and line O adds line K. The pack credits the whole service; the share used for exempt supplies is the preparer''s adjustment.', null, null, 170, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pgst-return', null, null, null, null),
  ('PW', 'PW-P-ZR', 'Purchase, zero-rated', '{}'::jsonb, 'A purchase of a zero-rated supply (for example an export-related service) carrying PGST at 0 %', 'percent', 0, 'purchase', 'domestic', date '2023-01-01', null, 'Act § 1212: a zero-rated supply bears PGST at 0 %. Return Tax 500, line F — zero-rated goods and services purchased, to the extent they were purchased to make taxable supplies; no PGST, so nothing in column 2.', 'Z', null, 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pgst-return', null, null, null, null),
  ('PW', 'PW-S-10', 'Sale, standard rate 10 %', '{}'::jsonb, 'A taxable supply of goods or services made in Palau by a registered person, neither zero-rated nor exempt', 'percent', 10, 'sale', 'domestic', date '2023-01-01', null, 'Act § 1211(b)(2): PGST at ten percent (10 %) on a taxable supply that is not zero-rated; in force from 1 January 2023. Return Tax 500, line A — supplies on which 10 % PGST is collected, the amount excluding PGST in column 1 and the PGST in column 2.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pgst-act', null, null, null, null),
  ('PW', 'PW-S-EX', 'Sale, exempt (financial services)', '{}'::jsonb, 'A supply of financial services — loans, deposits, interest-bearing investments, securities, insurance, retirement savings and the like', 'percent', 0, 'sale', 'exempt', date '2023-01-01', null, 'Act § 1213: a supply of financial services, if not zero-rated, is an exempt supply. No PGST is charged and no input tax credit is allowed on the inputs that serve it (Regulations § 401, apportionment). Return Tax 500, line C — supplies not subject to PGST.', 'E', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pgst-act', null, null, null, null),
  ('PW', 'PW-S-ZR', 'Sale, zero-rated (other than export)', '{}'::jsonb, 'A zero-rated supply made in Palau that is not an export — international transport, prescription medicine supplied to a licensed pharmacy, clinic or hospital, the transfer of a business as a going concern and the others on the list', 'percent', 0, 'sale', 'domestic', date '2023-01-01', null, 'Act § 1212 and the list of zero-rated supplies (PGST types of supplies): aircraft or ship stores, international transport and telecommunications, prescription medicine to a licensed pharmacy, clinic or hospital, the transfer of a business as a going concern, plastic pellets and empty containers for local bottling, and supplies by a non-resident contractor under an international agreement. One tax code carries the whole list; which item applies is the preparer''s judgement. Return Tax 500, line B.', 'Z', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pgst-supplies', null, null, null, null),
  ('PW', 'PW-S-ZR-EXP', 'Sale, zero-rated (export)', '{}'::jsonb, 'Goods exported or a service supplied to a person outside Palau, taxable at 0 %', 'percent', 0, 'sale', 'export', date '2023-01-01', null, 'Act § 1211(b)(1) and § 1212: a zero-rated supply bears PGST at 0 % and keeps the input tax credit; the supplies of goods for export and of exported services are on the list (PGST types of supplies). Return Tax 500, line B. Which conditions an export meets is the preparer''s judgement.', 'G', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pgst-supplies', null, null, null, null)
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
    ('PW-P-0', 'invoice', 'base', 100, null, 'H', array['H']::text[], 100, 'PW-PGST', 10),
    ('PW-P-0', 'credit_note', 'base', 100, null, 'H', array['H']::text[], -100, 'PW-PGST', 10),
    ('PW-P-10', 'invoice', 'base', 100, null, 'E', array['E']::text[], 100, 'PW-PGST', 10),
    ('PW-P-10', 'invoice', 'tax', 100, '1150', 'E', array['E']::text[], 100, 'PW-PGST', 20),
    ('PW-P-10', 'credit_note', 'base', 100, null, 'E', array['E']::text[], -100, 'PW-PGST', 10),
    ('PW-P-10', 'credit_note', 'tax', 100, '1150', 'E', array['E']::text[], -100, 'PW-PGST', 20),
    ('PW-P-10-NC', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('PW-P-10-NC', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('PW-P-10-NC', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('PW-P-10-NC', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('PW-P-IMP', 'invoice', 'base', 100, null, 'G', array['G']::text[], 100, 'PW-PGST', 10),
    ('PW-P-IMP', 'invoice', 'tax', 100, '1150', 'G', array['G']::text[], 100, 'PW-PGST', 20),
    ('PW-P-IMP', 'invoice', 'tax', -100, '2125', null, null, 100, null, 30),
    ('PW-P-IMP', 'credit_note', 'base', 100, null, 'G', array['G']::text[], -100, 'PW-PGST', 10),
    ('PW-P-IMP', 'credit_note', 'tax', 100, '1150', 'G', array['G']::text[], -100, 'PW-PGST', 20),
    ('PW-P-IMP', 'credit_note', 'tax', -100, '2125', null, null, 100, null, 30),
    ('PW-P-RC-SVC', 'invoice', 'base', 100, null, 'J', array['J']::text[], 100, 'PW-PGST', 10),
    ('PW-P-RC-SVC', 'invoice', 'tax', -100, '2100', 'J', array['J']::text[], 100, 'PW-PGST', 20),
    ('PW-P-RC-SVC', 'invoice', 'tax', 100, '1150', 'K', array['K']::text[], 100, 'PW-PGST', 30),
    ('PW-P-RC-SVC', 'credit_note', 'base', 100, null, 'J', array['J']::text[], -100, 'PW-PGST', 10),
    ('PW-P-RC-SVC', 'credit_note', 'tax', -100, '2100', 'J', array['J']::text[], -100, 'PW-PGST', 20),
    ('PW-P-RC-SVC', 'credit_note', 'tax', 100, '1150', 'K', array['K']::text[], -100, 'PW-PGST', 30),
    ('PW-P-ZR', 'invoice', 'base', 100, null, 'F', array['F']::text[], 100, 'PW-PGST', 10),
    ('PW-P-ZR', 'credit_note', 'base', 100, null, 'F', array['F']::text[], -100, 'PW-PGST', 10),
    ('PW-S-10', 'invoice', 'base', 100, null, 'A', array['A']::text[], 100, 'PW-PGST', 10),
    ('PW-S-10', 'invoice', 'tax', 100, '2100', 'A', array['A']::text[], 100, 'PW-PGST', 20),
    ('PW-S-10', 'credit_note', 'base', 100, null, 'A', array['A']::text[], -100, 'PW-PGST', 10),
    ('PW-S-10', 'credit_note', 'tax', 100, '2100', 'A', array['A']::text[], -100, 'PW-PGST', 20),
    ('PW-S-EX', 'invoice', 'base', 100, null, 'C', array['C']::text[], 100, 'PW-PGST', 10),
    ('PW-S-EX', 'credit_note', 'base', 100, null, 'C', array['C']::text[], -100, 'PW-PGST', 10),
    ('PW-S-ZR', 'invoice', 'base', 100, null, 'B', array['B']::text[], 100, 'PW-PGST', 10),
    ('PW-S-ZR', 'credit_note', 'base', 100, null, 'B', array['B']::text[], -100, 'PW-PGST', 10),
    ('PW-S-ZR-EXP', 'invoice', 'base', 100, null, 'B', array['B']::text[], 100, 'PW-PGST', 10),
    ('PW-S-ZR-EXP', 'credit_note', 'base', 100, null, 'B', array['B']::text[], -100, 'PW-PGST', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'PW' and t.code = v.tax_code
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
  ('PW', 'PW-PGST', 'PGST return (Tax 500)', array['month']::declaration_period[], 'month'::declaration_period, date '2023-01-01', null, 'Form Tax 500, Palau Goods & Services Monthly Tax Return: lines A to P, with the amount excluding PGST in column 1 and the PGST in column 2. The PGST period is a calendar month (Act § 1202); the return is filed on the Tax 500 form and is due within thirty days after the end of the period (§ 1281). Lines L and M (capital assets) are the preparer''s: declared and empty. The continuation sheet (summary by business licence) is not produced.', true,'day_of_month_after_period'::filing_deadline_rule, 30, null, 'Act § 1281 — a return for each PGST period within thirty (30) days after the end of the period, and § 1282(a) — payment by the same date; the form''s instructions say on or before the thirtieth day of the month following the period. The taxpayer calendar gives 30 March for February, 30 April for March and so on, and 2 March for January (thirty days after 31 January); a date that falls on a weekend or a public holiday moves to the next working day. The rule below is the thirtieth day: for a January return it is two days earlier than the Act, and the weekend rule is not applied.', 'taxpayer-calendar', null)
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
  ('PW', 'PW-PGST', 'A', 'base', 'Line A, column 1 — Supplies on which 10 % PGST is collected (amount excluding PGST)', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form Tax 500, line A, column 1: the taxable supplies, sales of capital assets included, that were subject to PGST at 10 %, excluding PGST.', 'pgst-return'),
  ('PW', 'PW-PGST', 'A', 'tax', 'Line A, column 2 — PGST collected on the supplies of line A', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form Tax 500, line A, column 2: the PGST collected on the amount of column 1, deemed taxable supplies and adjustments included.', 'pgst-return'),
  ('PW', 'PW-PGST', 'B', 'base', 'Line B — Supplies on which zero rate (0 %) PGST is collected', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form Tax 500, line B: the value of the zero-rated goods and services supplied during the PGST period (exports and the others on the list).', 'pgst-return'),
  ('PW', 'PW-PGST', 'C', 'base', 'Line C — Supplies not subject to PGST (exempt supplies)', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form Tax 500, line C: the goods and services supplied that were not subject to PGST — the exempt financial services (Act § 1213).', 'pgst-return'),
  ('PW', 'PW-PGST', 'D', 'total', 'Line D — Total business outputs (A + B + C, column 1)', '{}'::jsonb, 50, null, array['A:base', 'B:base', 'C:base']::text[], '{}'::text[], null, null, false, false, null, 'Form Tax 500, line D: lines A, B and C of column 1 added.', 'pgst-return'),
  ('PW', 'PW-PGST', 'E', 'base', 'Line E, column 1 — Domestic supplies on which 10 % PGST paid (amount excluding PGST)', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form Tax 500, line E, column 1: the business inputs (goods, capital assets, services) subject to PGST at 10%, excluding PGST.', 'pgst-return'),
  ('PW', 'PW-PGST', 'E', 'tax', 'Line E, column 2 — PGST paid on the domestic purchases of line E', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form Tax 500, line E, column 2: the PGST paid on purchases during the period, adjustments included.', 'pgst-return'),
  ('PW', 'PW-PGST', 'F', 'base', 'Line F — Domestic supplies on which zero rate (0 %) PGST paid', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form Tax 500, line F: zero-rated goods and services purchased, to the extent they were purchased to make taxable supplies.', 'pgst-return'),
  ('PW', 'PW-PGST', 'G', 'base', 'Line G, column 1 — Imported goods on which 10 % PGST paid (amount excluding PGST)', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form Tax 500, line G, column 1: the value of the goods imported, excluding PGST, to the extent they were used to make taxable supplies.', 'pgst-return'),
  ('PW', 'PW-PGST', 'G', 'tax', 'Line G, column 2 — PGST paid on the imported goods', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form Tax 500, line G, column 2: the PGST paid on the imported goods of column 1.', 'pgst-return'),
  ('PW', 'PW-PGST', 'H', 'base', 'Line H — Supplies not subject to PGST (exempt supplies purchased)', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form Tax 500, line H: the value of all goods and services purchased that were not subject to PGST, including purchases from non-registered suppliers and services bought overseas that are not subject to PGST.', 'pgst-return'),
  ('PW', 'PW-PGST', 'I', 'total', 'Line I — Total business inputs (E + F + G + H, column 1)', '{}'::jsonb, 120, null, array['E:base', 'F:base', 'G:base', 'H:base']::text[], '{}'::text[], null, null, false, false, null, 'Form Tax 500, line I: lines E, F, G and H of column 1 added.', 'pgst-return'),
  ('PW', 'PW-PGST', 'J', 'base', 'Line J, column 1 — Imported services subject to the 10 % reverse charge (value)', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form Tax 500, line J, column 1: the value of the imported services.', 'pgst-return'),
  ('PW', 'PW-PGST', 'J', 'tax', 'Line J, column 2 — PGST reverse-charged on the imported services (10 %)', '{}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form Tax 500, line J, column 2: an amount equal to 10 % of the value of line J, column 1 (Act § 1211(a)(2)).', 'pgst-return'),
  ('PW', 'PW-PGST', 'K', 'tax', 'Line K — Input tax credit on the imported services (10 % of the value used to make taxable supplies)', '{}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form Tax 500, line K, column 2: an amount equal to 10 % of the value of line K, column 1. Only the PGST is a box of the pack: the code credits the whole service, so the value of column 1 is the value of line J.', 'pgst-return'),
  ('PW', 'PW-PGST', 'L', 'base', 'Line L — Total sales of business capital assets included in line D', '{}'::jsonb, 170, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form Tax 500, line L: the value of the business capital assets sold during the period, excluding PGST. Declared and empty: whether an item is a capital asset (a useful life over one year, inventory excluded) is the preparer''s judgement, and no tax code posts to it.', 'pgst-return'),
  ('PW', 'PW-PGST', 'M', 'base', 'Line M — Total purchases of business capital assets included in line I', '{}'::jsonb, 180, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form Tax 500, line M: the value of the business capital assets purchased during the period. Declared and empty, for the reason given at line L.', 'pgst-return'),
  ('PW', 'PW-PGST', 'N', 'total', 'Line N — PGST collected plus PGST reverse-charged on imported services (A + J, column 2)', '{}'::jsonb, 190, null, array['A:tax', 'J:tax']::text[], '{}'::text[], null, null, false, false, null, 'Form Tax 500, line N: the sum of column 2 of lines A and J — components A and B of the formula of Act § 1261.', 'pgst-return'),
  ('PW', 'PW-PGST', 'O', 'total', 'Line O — PGST input tax credit claimable (E + G + K, column 2)', '{}'::jsonb, 200, null, array['E:tax', 'G:tax', 'K:tax']::text[], '{}'::text[], null, null, false, false, null, 'Form Tax 500, line O: the sum of column 2 of lines E, G and K — component C of the formula of Act § 1261.', 'pgst-return'),
  ('PW', 'PW-PGST', 'P', 'total', 'Line P — Net PGST payable (positive) or creditable (negative) (N - O)', '{}'::jsonb, 210, null, array['N']::text[], array['O']::text[], null, null, false, false, null, 'Form Tax 500, line P: line N less line O, the formula (A + B) - C of Act § 1261. A negative line P is a credit carried forward to the following PGST period (§ 1262); a refund needs a written application.', 'pgst-return')
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
  ('PW-FS-IS', 'PW', 'default', 'Statement of profit or loss', 'income_statement', 'IFRS', date '2014-01-20', null, 'IAS 1 asks for a statement of financial position and a statement of profit or loss; expenses are analysed by nature, which these lines follow. No Palau text prescribing a layout of the statements was found, so the statement is presented in the layout of IAS 1 on the pack''s own chart.', 'ias-1', null, null, '{}'::jsonb),
  ('PW-FS-SFP', 'PW', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS', date '2014-01-20', null, 'IAS 1 asks for a statement of financial position and a statement of profit or loss; expenses are analysed by nature, which these lines follow. No Palau text prescribing a layout of the statements was found, so the statement is presented in the layout of IAS 1 on the pack''s own chart.', 'ias-1', 'combined', 'Result of the current financial year', '{}'::jsonb)
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
  ('PW-FS-IS', '1', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-IS', '2', null, 'Other income', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-IS', '3', null, 'Purchases and changes in inventories', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-IS', '4', null, 'Employee benefits expense', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-IS', '5', null, 'Depreciation and amortisation', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-IS', '6', null, 'Other operating expenses', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-IS', '7', null, 'Finance costs', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-IS', '8', null, 'Profit before tax', '{}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('PW-FS-IS', '9', null, 'Income tax expense', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-IS', '10', null, 'Profit for the year', '{}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, null, null),
  ('PW-FS-SFP', 'CA', null, 'Current assets', '{}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5', 'CA.6']::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'CA.1', null, 'Cash and cash equivalents', '{}'::jsonb, 11, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'CA.2', null, 'Trade and other receivables', '{}'::jsonb, 12, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'CA.3', null, 'Inventories', '{}'::jsonb, 13, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'CA.4', null, 'Financial assets', '{}'::jsonb, 14, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'CA.5', null, 'Current tax recoverable', '{}'::jsonb, 15, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'CA.6', null, 'Prepayments and accrued income', '{}'::jsonb, 16, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'NCA', null, 'Non-current assets', '{}'::jsonb, 20, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4', 'NCA.5', 'NCA.6', 'NCA.7']::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'NCA.1', null, 'Property, plant and equipment', '{}'::jsonb, 21, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'NCA.2', null, 'Investment property', '{}'::jsonb, 22, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'NCA.3', null, 'Intangible assets', '{}'::jsonb, 23, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'NCA.4', null, 'Investments in associates', '{}'::jsonb, 24, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'NCA.5', null, 'Investments in joint ventures', '{}'::jsonb, 25, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'NCA.6', null, 'Financial assets', '{}'::jsonb, 26, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'NCA.7', null, 'Deferred tax assets', '{}'::jsonb, 27, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'TA', null, 'Total assets', '{}'::jsonb, 30, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'CL', null, 'Current liabilities', '{}'::jsonb, 40, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4', 'CL.5']::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'CL.1', null, 'Trade and other payables', '{}'::jsonb, 41, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'CL.2', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 42, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'CL.3', null, 'Amounts due to directors', '{}'::jsonb, 43, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'CL.4', null, 'Current tax payable', '{}'::jsonb, 44, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'CL.5', null, 'Provisions', '{}'::jsonb, 45, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'NCL', null, 'Non-current liabilities', '{}'::jsonb, 50, 1, true, array['NCL.1', 'NCL.2', 'NCL.3']::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'NCL.1', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 51, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'NCL.2', null, 'Deferred tax liabilities', '{}'::jsonb, 52, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'NCL.3', null, 'Provisions', '{}'::jsonb, 53, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'TL', null, 'Total liabilities', '{}'::jsonb, 60, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'NA', null, 'Net assets', '{}'::jsonb, 70, 1, true, array['TA']::text[], array['TL']::text[], null, null, null),
  ('PW-FS-SFP', 'EQ', null, 'Equity', '{}'::jsonb, 80, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'EQ.1', null, 'Share capital', '{}'::jsonb, 81, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'EQ.2', null, 'Other reserves', '{}'::jsonb, 82, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PW-FS-SFP', 'EQ.3', null, 'Retained earnings', '{}'::jsonb, 83, -1, false, '{}'::text[], '{}'::text[], null, null, null)
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
 where r.statement_code in ('PW-FS-IS', 'PW-FS-SFP')
   and (r.statement_code, r.line_code, r.sequence) not in (
     values ('PW-FS-IS', '1', 10),
            ('PW-FS-IS', '2', 10),
            ('PW-FS-IS', '3', 10),
            ('PW-FS-IS', '4', 10),
            ('PW-FS-IS', '5', 10),
            ('PW-FS-IS', '6', 10),
            ('PW-FS-IS', '7', 10),
            ('PW-FS-IS', '9', 10),
            ('PW-FS-SFP', 'CA.1', 10),
            ('PW-FS-SFP', 'CA.2', 10),
            ('PW-FS-SFP', 'CA.3', 10),
            ('PW-FS-SFP', 'CA.4', 10),
            ('PW-FS-SFP', 'CA.5', 10),
            ('PW-FS-SFP', 'CA.6', 10),
            ('PW-FS-SFP', 'NCA.1', 10),
            ('PW-FS-SFP', 'NCA.2', 10),
            ('PW-FS-SFP', 'NCA.3', 10),
            ('PW-FS-SFP', 'NCA.4', 10),
            ('PW-FS-SFP', 'NCA.5', 10),
            ('PW-FS-SFP', 'NCA.6', 10),
            ('PW-FS-SFP', 'NCA.7', 10),
            ('PW-FS-SFP', 'CL.1', 10),
            ('PW-FS-SFP', 'CL.1', 20),
            ('PW-FS-SFP', 'CL.2', 10),
            ('PW-FS-SFP', 'CL.3', 10),
            ('PW-FS-SFP', 'CL.4', 10),
            ('PW-FS-SFP', 'CL.5', 10),
            ('PW-FS-SFP', 'NCL.1', 10),
            ('PW-FS-SFP', 'NCL.2', 10),
            ('PW-FS-SFP', 'NCL.3', 10),
            ('PW-FS-SFP', 'EQ.1', 10),
            ('PW-FS-SFP', 'EQ.2', 10),
            ('PW-FS-SFP', 'EQ.3', 10)
   );

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('PW-FS-IS', '1', 10, 'code_range', '4000', '4030', null, 'any'),
    ('PW-FS-IS', '2', 10, 'code_range', '4500', '4790', null, 'any'),
    ('PW-FS-IS', '3', 10, 'code_range', '5000', '5100', null, 'any'),
    ('PW-FS-IS', '4', 10, 'code_range', '6000', '6080', null, 'any'),
    ('PW-FS-IS', '5', 10, 'code_range', '6200', '6220', null, 'any'),
    ('PW-FS-IS', '6', 10, 'code_range', '6300', '6990', null, 'any'),
    ('PW-FS-IS', '7', 10, 'code_range', '7000', '7030', null, 'any'),
    ('PW-FS-IS', '9', 10, 'code_range', '8000', '8020', null, 'any'),
    ('PW-FS-SFP', 'CA.1', 10, 'code_range', '1000', '1040', null, 'any'),
    ('PW-FS-SFP', 'CA.2', 10, 'code_range', '1100', '1160', null, 'any'),
    ('PW-FS-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('PW-FS-SFP', 'CA.4', 10, 'account_code', '1300', null, null, 'any'),
    ('PW-FS-SFP', 'CA.5', 10, 'account_code', '1350', null, null, 'any'),
    ('PW-FS-SFP', 'CA.6', 10, 'code_range', '1400', '1410', null, 'any'),
    ('PW-FS-SFP', 'NCA.1', 10, 'code_range', '1600', '1671', null, 'any'),
    ('PW-FS-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('PW-FS-SFP', 'NCA.3', 10, 'code_range', '1750', '1760', null, 'any'),
    ('PW-FS-SFP', 'NCA.4', 10, 'account_code', '1800', null, null, 'any'),
    ('PW-FS-SFP', 'NCA.5', 10, 'account_code', '1810', null, null, 'any'),
    ('PW-FS-SFP', 'NCA.6', 10, 'code_range', '1830', '1840', null, 'any'),
    ('PW-FS-SFP', 'NCA.7', 10, 'account_code', '1900', null, null, 'any'),
    ('PW-FS-SFP', 'CL.1', 10, 'code_range', '2000', '2190', null, 'any'),
    ('PW-FS-SFP', 'CL.1', 20, 'account_code', '2990', null, null, 'credit'),
    ('PW-FS-SFP', 'CL.2', 10, 'code_range', '2200', '2240', null, 'any'),
    ('PW-FS-SFP', 'CL.3', 10, 'account_code', '2250', null, null, 'any'),
    ('PW-FS-SFP', 'CL.4', 10, 'account_code', '2300', null, null, 'any'),
    ('PW-FS-SFP', 'CL.5', 10, 'code_range', '2350', '2360', null, 'any'),
    ('PW-FS-SFP', 'NCL.1', 10, 'code_range', '2400', '2430', null, 'any'),
    ('PW-FS-SFP', 'NCL.2', 10, 'account_code', '2500', null, null, 'any'),
    ('PW-FS-SFP', 'NCL.3', 10, 'account_code', '2550', null, null, 'any'),
    ('PW-FS-SFP', 'EQ.1', 10, 'code_range', '3000', '3010', null, 'any'),
    ('PW-FS-SFP', 'EQ.2', 10, 'code_range', '3100', '3110', null, 'any'),
    ('PW-FS-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('PW', 'Palau', '{}'::jsonb, array['en']::text[], 'USD', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, 'month'::declaration_period)
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
  numbering_legal_reference     = 'A PGST invoice must carry the particulars § 1271 of the Act lists; no text read says how invoices are numbered. `sequential` and the number format are conventions of this pack and not rules of the law.',
  numbering_source_key          = 'pgst-act',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_date',
  tax_point_legal_reference     = 'Act § 1232 sets the time of supply and § 1211(c) the time the liability arises; the pack does not model the rules of § 1232 and takes the invoice date as the tax point. That is a simplification, recorded in the README.',
  tax_point_source_key          = 'pgst-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No structured e-invoice standard, Peppol profile or clearance system of the BRT was found in the texts read; the returns are filed on the Tax 500 form with the Tax Filing App of the Bureau. `obligation` is `none` for want of a text, not on a finding that none exists.',
  einvoice_source_key           = 'brt-portal',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'PW';

update country_defaults set
  tax_payee_name       = 'Bureau of Revenue and Taxation (BRT), Ministry of Finance',
  tax_payee_source_key = 'brt-portal'
 where country = 'PW';
