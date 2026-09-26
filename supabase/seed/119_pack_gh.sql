-- Ekwo OS — Ghana: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/gh at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build gh`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Value Added Tax Act, 2025 (Act 1151), assented to on 9 December 2025, in force on 1 January 2026 (s. 75) — ss. 1 to 3 (imposition and the 15 % rate), 35 and 36 (exempt and zero-rated supplies), 38 (relief), 39 (time of supply), 43 (tax invoice through a Certified Invoicing System), 44 (taxable value, excluding the Tax, the GETFund Levy and the NHIL), 49 and 50 (deductible input tax, motor vehicles), 55 to 57 (VAT withholding), 59 and 60 (monthly return and payment), 72 ("tax period" means one calendar month), 73 (repeal of Act 870); First, Second and Third Schedules (Ghana Revenue Authority)
--     https://gra.gov.gh/wp-content/uploads/2026/01/VALUE-ADDED-TAX-ACT-2025-ACT-1151.pdf
--   VAT Administrative Guidelines for the Value Added Tax Act, 2025 (Act 1151), Administrative Guideline GRA/AG/25/002 of 31 December 2025 — computation of the Tax and the levies on the same taxable value (§ 6.0, § 15.3), NHIL and GETFund 2.5 % each and a combined 20 % (appendix), abolition of the flat rate and conversion to the standard rate (§ 15.2), filing of returns (§ 15.4), the COVID-19 levy field to be ignored since its Act was repealed (§ 15.6), VAT withholding at 7 % (§ 12.1) (Ghana Revenue Authority)
--     https://gra.gov.gh/wp-content/uploads/2026/01/VAT-Guidelines-for-VAT-ACT-1151.pdf
--   Notice to all VAT registered taxpayers — Value Added Tax Act, 2025 (Act 1151) effective 1 January 2026: registration threshold for goods raised to GH₵750,000, COVID-19 Health Recovery Levy abolished, NHIL and GETFund recoupled and deductible as input tax, VAT Flat Rate Scheme abolished (Ghana Revenue Authority)
--     https://gra.gov.gh/news/portfolio/notice-to-all-vat-registered-taxpayers/
--   Value Added Tax — rates (VAT 15 %, NHIL 2.5 %, GETFund 2.5 %), zero-rated supplies, filing and payment by the last working day of the following month (Ghana Revenue Authority)
--     https://gra.gov.gh/domestic-tax/tax-types/vat/
--   Monthly Standard VAT Return, form DT 0135 ver 1.5 (VAT, NHIL, GETFund and COVID-19 levy standard rate return) with its completion notes, boxes i to iv and 1 to 26 (Ghana Revenue Authority)
--     https://gra.gov.gh/wp-content/uploads/2021/06/DT-0135-VAT-NHIL-COVID-19-Standard-Rate-Return-Form-20082018-Ver1.5.pdf
--   GRA forms — the list of return forms the Authority publishes, DT 0135 being the standard-rate VAT return still listed (Ghana Revenue Authority)
--     https://gra.gov.gh/forms/
--   GRA Taxpayers' Portal — where the monthly VAT return is filed and paid (Ghana Revenue Authority)
--     https://taxpayersportal.com/
--   E-VAT — the Certified Invoicing System of the Commissioner-General: invoices signed by the Commissioner-General, with a QR code and a time stamp, standalone or integrated with the taxpayer's own system (Ghana Revenue Authority)
--     https://gra.gov.gh/e-services/e-vat/
--   VAT withholding — appointed withholding agents, rate and certificates (Ghana Revenue Authority)
--     https://gra.gov.gh/domestic-tax/tax-types/vat-withholding/
--   Companies Act, 2019 (Act 992), s. 127 — accounting records and financial statements prepared in compliance with the IFRS adopted by the Institute of Chartered Accountants, Ghana; Sixth Schedule (Ghana Investment Promotion Centre)
--     https://gipc.gov.gh/wp-content/uploads/2023/04/COMPANIES-ACT-2019-ACT-992.pdf
--   Adoption of the IFRS for SMEs — publication of the Institute of Chartered Accountants (Ghana) (Institute of Chartered Accountants (Ghana))
--     https://icagh.org/wp-content/uploads/2021/03/Adoption-of-IFRS-for-SMEs-publication.pdf
--   Use of IFRS Standards by jurisdiction — Ghana: IFRS adopted in 2007, IFRS for SMEs in 2010 (IFRS Foundation)
--     https://www.ifrs.org/use-around-the-world/use-of-ifrs-standards-by-jurisdiction/view-jurisdiction/ghana/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('GH', 'Ghana', '0.1.0', date '2026-09-26', '20260923110000', 'community', null, null, '8a9ff8b099951702c531a097b8c7943e9b8eb520412375292d81f6dbf70beb88', '[{"key":"vat-act-2025","title":"Value Added Tax Act, 2025 (Act 1151), assented to on 9 December 2025, in force on 1 January 2026 (s. 75) — ss. 1 to 3 (imposition and the 15 % rate), 35 and 36 (exempt and zero-rated supplies), 38 (relief), 39 (time of supply), 43 (tax invoice through a Certified Invoicing System), 44 (taxable value, excluding the Tax, the GETFund Levy and the NHIL), 49 and 50 (deductible input tax, motor vehicles), 55 to 57 (VAT withholding), 59 and 60 (monthly return and payment), 72 (\"tax period\" means one calendar month), 73 (repeal of Act 870); First, Second and Third Schedules","publisher":"Ghana Revenue Authority","url":"https://gra.gov.gh/wp-content/uploads/2026/01/VALUE-ADDED-TAX-ACT-2025-ACT-1151.pdf","consulted_on":"2026-09-26","kind":"law"},{"key":"gra-ag-25-002","title":"VAT Administrative Guidelines for the Value Added Tax Act, 2025 (Act 1151), Administrative Guideline GRA/AG/25/002 of 31 December 2025 — computation of the Tax and the levies on the same taxable value (§ 6.0, § 15.3), NHIL and GETFund 2.5 % each and a combined 20 % (appendix), abolition of the flat rate and conversion to the standard rate (§ 15.2), filing of returns (§ 15.4), the COVID-19 levy field to be ignored since its Act was repealed (§ 15.6), VAT withholding at 7 % (§ 12.1)","publisher":"Ghana Revenue Authority","url":"https://gra.gov.gh/wp-content/uploads/2026/01/VAT-Guidelines-for-VAT-ACT-1151.pdf","consulted_on":"2026-09-26","kind":"guidance"},{"key":"gra-notice-2026","title":"Notice to all VAT registered taxpayers — Value Added Tax Act, 2025 (Act 1151) effective 1 January 2026: registration threshold for goods raised to GH₵750,000, COVID-19 Health Recovery Levy abolished, NHIL and GETFund recoupled and deductible as input tax, VAT Flat Rate Scheme abolished","publisher":"Ghana Revenue Authority","url":"https://gra.gov.gh/news/portfolio/notice-to-all-vat-registered-taxpayers/","consulted_on":"2026-09-26","kind":"guidance"},{"key":"gra-vat","title":"Value Added Tax — rates (VAT 15 %, NHIL 2.5 %, GETFund 2.5 %), zero-rated supplies, filing and payment by the last working day of the following month","publisher":"Ghana Revenue Authority","url":"https://gra.gov.gh/domestic-tax/tax-types/vat/","consulted_on":"2026-09-26","kind":"guidance"},{"key":"dt-0135","title":"Monthly Standard VAT Return, form DT 0135 ver 1.5 (VAT, NHIL, GETFund and COVID-19 levy standard rate return) with its completion notes, boxes i to iv and 1 to 26","publisher":"Ghana Revenue Authority","url":"https://gra.gov.gh/wp-content/uploads/2021/06/DT-0135-VAT-NHIL-COVID-19-Standard-Rate-Return-Form-20082018-Ver1.5.pdf","consulted_on":"2026-09-26","kind":"form"},{"key":"gra-forms","title":"GRA forms — the list of return forms the Authority publishes, DT 0135 being the standard-rate VAT return still listed","publisher":"Ghana Revenue Authority","url":"https://gra.gov.gh/forms/","consulted_on":"2026-09-26","kind":"guidance"},{"key":"taxpayers-portal","title":"GRA Taxpayers'' Portal — where the monthly VAT return is filed and paid","publisher":"Ghana Revenue Authority","url":"https://taxpayersportal.com/","consulted_on":"2026-09-26","kind":"portal"},{"key":"e-vat","title":"E-VAT — the Certified Invoicing System of the Commissioner-General: invoices signed by the Commissioner-General, with a QR code and a time stamp, standalone or integrated with the taxpayer''s own system","publisher":"Ghana Revenue Authority","url":"https://gra.gov.gh/e-services/e-vat/","consulted_on":"2026-09-26","kind":"portal"},{"key":"gra-vat-withholding","title":"VAT withholding — appointed withholding agents, rate and certificates","publisher":"Ghana Revenue Authority","url":"https://gra.gov.gh/domestic-tax/tax-types/vat-withholding/","consulted_on":"2026-09-26","kind":"guidance"},{"key":"companies-act-2019","title":"Companies Act, 2019 (Act 992), s. 127 — accounting records and financial statements prepared in compliance with the IFRS adopted by the Institute of Chartered Accountants, Ghana; Sixth Schedule","publisher":"Ghana Investment Promotion Centre","url":"https://gipc.gov.gh/wp-content/uploads/2023/04/COMPANIES-ACT-2019-ACT-992.pdf","consulted_on":"2026-09-26","kind":"law"},{"key":"icag-ifrs-sme","title":"Adoption of the IFRS for SMEs — publication of the Institute of Chartered Accountants (Ghana)","publisher":"Institute of Chartered Accountants (Ghana)","url":"https://icagh.org/wp-content/uploads/2021/03/Adoption-of-IFRS-for-SMEs-publication.pdf","consulted_on":"2026-09-26","kind":"guidance"},{"key":"ifrs-ghana","title":"Use of IFRS Standards by jurisdiction — Ghana: IFRS adopted in 2007, IFRS for SMEs in 2010","publisher":"IFRS Foundation","url":"https://www.ifrs.org/use-around-the-world/use-of-ifrs-standards-by-jurisdiction/view-jurisdiction/ghana/","consulted_on":"2026-09-26","kind":"guidance"}]'::jsonb)
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
  ('GH', 'default', 'Ghana reference chart of accounts', '{}'::jsonb, true, 'companies', array['GH-ICAG-IS', 'GH-ICAG-SFP']::text[], null, 'There is no legal chart of accounts in Ghana. Companies Act, 2019 (Act 992), s. 127(1) requires every company to keep proper accounting records of the sums received and spent, of its sales and purchases and of its assets and liabilities; s. 127(2) says records that do not give a true and fair view are not proper records; s. 127(5) requires the financial statements — a statement of financial position, a statement of comprehensive income, a statement of cash flows, a statement of changes in equity and the notes — to be prepared in compliance with the International Financial Reporting Standards adopted by the Institute of Chartered Accountants, Ghana, which adopted the IFRS in 2007 and the IFRS for SMEs in 2010. This chart is original: four digits, blocked so that each range reaches one line of the IFRS for SMEs statements below, with the accounts a Ghanaian company actually keeps — VAT, NHIL and GETFund output and input accounts kept apart, the net VAT and levies due to or from GRA after a return, import VAT and levies owed to GRA Customs at the border, VAT withheld by an appointed agent, SSNIT first-tier and second-tier pension contributions, PAYE.', 'companies-act-2019')
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
  ('GH', 'default', '1000', 'Petty cash', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('GH', 'default', '1010', 'Current account — GHS', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('GH', 'default', '1020', 'Fixed deposits placed for three months or less', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('GH', 'default', '1030', 'Foreign currency account — USD', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('GH', 'default', '1040', 'Cash in transit — mobile money and card settlements', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('GH', 'default', '1100', 'Trade receivables', '{}'::jsonb, 'asset_receivable', true, null, 60),
  ('GH', 'default', '1110', 'Trade receivables — allowance for impairment', '{}'::jsonb, 'asset_current', false, null, 70),
  ('GH', 'default', '1120', 'Other receivables', '{}'::jsonb, 'asset_current', false, null, 80),
  ('GH', 'default', '1130', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 90),
  ('GH', 'default', '1140', 'Deposits paid', '{}'::jsonb, 'asset_current', false, null, 100),
  ('GH', 'default', '1150', 'VAT input tax', '{}'::jsonb, 'asset_current', false, null, 110),
  ('GH', 'default', '1151', 'NHIL input levy', '{}'::jsonb, 'asset_current', false, null, 120),
  ('GH', 'default', '1152', 'GETFund input levy', '{}'::jsonb, 'asset_current', false, null, 130),
  ('GH', 'default', '1155', 'VAT and levies refundable by GRA — net of a filed return', '{}'::jsonb, 'asset_current', true, null, 140),
  ('GH', 'default', '1156', 'Withholding VAT credits — certificates received', '{}'::jsonb, 'asset_current', false, null, 150),
  ('GH', 'default', '1157', 'Upfront VAT paid at import — recoverable', '{}'::jsonb, 'asset_current', false, null, 160),
  ('GH', 'default', '1160', 'Advances to staff', '{}'::jsonb, 'asset_current', false, null, 170),
  ('GH', 'default', '1200', 'Inventories — goods for resale', '{}'::jsonb, 'asset_current', false, null, 180),
  ('GH', 'default', '1210', 'Inventories — raw materials', '{}'::jsonb, 'asset_current', false, null, 190),
  ('GH', 'default', '1220', 'Inventories — work in progress', '{}'::jsonb, 'asset_current', false, null, 200),
  ('GH', 'default', '1230', 'Inventories — finished goods', '{}'::jsonb, 'asset_current', false, null, 210),
  ('GH', 'default', '1300', 'Short-term investments', '{}'::jsonb, 'asset_current', false, null, 220),
  ('GH', 'default', '1350', 'Current tax recoverable', '{}'::jsonb, 'asset_current', false, null, 230),
  ('GH', 'default', '1400', 'Prepayments', '{}'::jsonb, 'asset_prepayments', false, null, 240),
  ('GH', 'default', '1410', 'Accrued income', '{}'::jsonb, 'asset_prepayments', false, null, 250),
  ('GH', 'default', '1600', 'Land and buildings — cost', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('GH', 'default', '1601', 'Land and buildings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('GH', 'default', '1610', 'Leasehold improvements — cost', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('GH', 'default', '1611', 'Leasehold improvements — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('GH', 'default', '1620', 'Plant and machinery — cost', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('GH', 'default', '1621', 'Plant and machinery — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('GH', 'default', '1630', 'Office equipment — cost', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('GH', 'default', '1631', 'Office equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('GH', 'default', '1640', 'Computers — cost', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('GH', 'default', '1641', 'Computers — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('GH', 'default', '1650', 'Furniture and fittings — cost', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('GH', 'default', '1651', 'Furniture and fittings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('GH', 'default', '1660', 'Motor vehicles — cost', '{}'::jsonb, 'asset_fixed', false, null, 380),
  ('GH', 'default', '1661', 'Motor vehicles — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 390),
  ('GH', 'default', '1670', 'Right-of-use assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 400),
  ('GH', 'default', '1671', 'Right-of-use assets — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 410),
  ('GH', 'default', '1700', 'Investment property', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('GH', 'default', '1750', 'Intangible assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 430),
  ('GH', 'default', '1751', 'Intangible assets — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 440),
  ('GH', 'default', '1760', 'Goodwill', '{}'::jsonb, 'asset_fixed', false, null, 450),
  ('GH', 'default', '1800', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('GH', 'default', '1810', 'Investments in joint ventures', '{}'::jsonb, 'asset_non_current', false, null, 470),
  ('GH', 'default', '1830', 'Long-term financial assets', '{}'::jsonb, 'asset_non_current', false, null, 480),
  ('GH', 'default', '1840', 'Long-term deposits', '{}'::jsonb, 'asset_non_current', false, null, 490),
  ('GH', 'default', '1900', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 500),
  ('GH', 'default', '2000', 'Trade payables', '{}'::jsonb, 'liability_payable', true, null, 510),
  ('GH', 'default', '2010', 'Accrued expenses', '{}'::jsonb, 'liability_current', false, null, 520),
  ('GH', 'default', '2020', 'Other payables', '{}'::jsonb, 'liability_current', false, null, 530),
  ('GH', 'default', '2030', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 540),
  ('GH', 'default', '2040', 'Deposits received from customers', '{}'::jsonb, 'liability_current', false, null, 550),
  ('GH', 'default', '2100', 'VAT output tax', '{}'::jsonb, 'liability_current', false, null, 560),
  ('GH', 'default', '2101', 'NHIL output levy', '{}'::jsonb, 'liability_current', false, null, 570),
  ('GH', 'default', '2102', 'GETFund output levy', '{}'::jsonb, 'liability_current', false, null, 580),
  ('GH', 'default', '2110', 'VAT and levies payable to GRA — net of a filed return', '{}'::jsonb, 'liability_current', true, null, 590),
  ('GH', 'default', '2125', 'Import VAT and levies payable to GRA Customs at the border', '{}'::jsonb, 'liability_current', false, null, 600),
  ('GH', 'default', '2130', 'VAT withheld from suppliers — payable to GRA', '{}'::jsonb, 'liability_current', false, null, 610),
  ('GH', 'default', '2135', 'Communications Service Tax payable', '{}'::jsonb, 'liability_current', false, null, 620),
  ('GH', 'default', '2140', 'Withholding tax payable to GRA', '{}'::jsonb, 'liability_current', false, null, 630),
  ('GH', 'default', '2150', 'SSNIT contributions payable — first tier', '{}'::jsonb, 'liability_current', false, null, 640),
  ('GH', 'default', '2155', 'Occupational pension contributions payable — second tier', '{}'::jsonb, 'liability_current', false, null, 650),
  ('GH', 'default', '2160', 'PAYE income tax payable to GRA', '{}'::jsonb, 'liability_current', false, null, 660),
  ('GH', 'default', '2165', 'Tourism levy payable', '{}'::jsonb, 'liability_current', false, null, 670),
  ('GH', 'default', '2180', 'Salaries payable', '{}'::jsonb, 'liability_current', false, null, 680),
  ('GH', 'default', '2190', 'Directors'' fees payable', '{}'::jsonb, 'liability_current', false, null, 690),
  ('GH', 'default', '2200', 'Bank overdraft', '{}'::jsonb, 'liability_current', false, null, 700),
  ('GH', 'default', '2210', 'Bank loans — current portion', '{}'::jsonb, 'liability_current', false, null, 710),
  ('GH', 'default', '2220', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 720),
  ('GH', 'default', '2230', 'Hire purchase — current portion', '{}'::jsonb, 'liability_current', false, null, 730),
  ('GH', 'default', '2240', 'Corporate credit card', '{}'::jsonb, 'liability_credit_card', false, null, 740),
  ('GH', 'default', '2250', 'Amounts due to directors', '{}'::jsonb, 'liability_current', false, null, 750),
  ('GH', 'default', '2300', 'Current tax payable', '{}'::jsonb, 'liability_current', false, null, 760),
  ('GH', 'default', '2350', 'Provision for unutilised leave', '{}'::jsonb, 'liability_current', false, null, 770),
  ('GH', 'default', '2360', 'Other provisions — current', '{}'::jsonb, 'liability_current', false, null, 780),
  ('GH', 'default', '2400', 'Bank loans — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 790),
  ('GH', 'default', '2410', 'Lease liabilities — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 800),
  ('GH', 'default', '2420', 'Hire purchase — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 810),
  ('GH', 'default', '2430', 'Loans from shareholders and directors — non-current', '{}'::jsonb, 'liability_non_current', false, null, 820),
  ('GH', 'default', '2500', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 830),
  ('GH', 'default', '2550', 'Provision for reinstatement costs', '{}'::jsonb, 'liability_non_current', false, null, 840),
  ('GH', 'default', '2990', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 850),
  ('GH', 'default', '3000', 'Share capital', '{}'::jsonb, 'equity', false, null, 860),
  ('GH', 'default', '3010', 'Treasury shares', '{}'::jsonb, 'equity', false, null, 870),
  ('GH', 'default', '3100', 'Other reserves', '{}'::jsonb, 'equity', false, null, 880),
  ('GH', 'default', '3110', 'Foreign currency translation reserve', '{}'::jsonb, 'equity', false, null, 890),
  ('GH', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 900),
  ('GH', 'default', '3210', 'Dividends paid', '{}'::jsonb, 'equity_retained', false, null, 910),
  ('GH', 'default', '4000', 'Sales of goods', '{}'::jsonb, 'income', false, null, 920),
  ('GH', 'default', '4010', 'Services rendered', '{}'::jsonb, 'income', false, null, 930),
  ('GH', 'default', '4020', 'Export sales of goods', '{}'::jsonb, 'income', false, null, 940),
  ('GH', 'default', '4030', 'Export of services', '{}'::jsonb, 'income', false, null, 950),
  ('GH', 'default', '4500', 'Interest income', '{}'::jsonb, 'income_other', false, null, 960),
  ('GH', 'default', '4510', 'Dividend income', '{}'::jsonb, 'income_other', false, null, 970),
  ('GH', 'default', '4520', 'Rental income', '{}'::jsonb, 'income_other', false, null, 980),
  ('GH', 'default', '4530', 'Government grants', '{}'::jsonb, 'income_other', false, null, 990),
  ('GH', 'default', '4700', 'Foreign exchange gains', '{}'::jsonb, 'income_other', false, null, 1000),
  ('GH', 'default', '4750', 'Gain on disposal of property plant and equipment', '{}'::jsonb, 'income_other', false, null, 1010),
  ('GH', 'default', '4790', 'Other income', '{}'::jsonb, 'income_other', false, null, 1020),
  ('GH', 'default', '5000', 'Purchases of goods for resale', '{}'::jsonb, 'expense_direct_cost', false, null, 1030),
  ('GH', 'default', '5010', 'Freight inwards and import duties', '{}'::jsonb, 'expense_direct_cost', false, null, 1040),
  ('GH', 'default', '5020', 'Subcontract costs', '{}'::jsonb, 'expense_direct_cost', false, null, 1050),
  ('GH', 'default', '5100', 'Changes in inventories', '{}'::jsonb, 'expense_direct_cost', false, null, 1060),
  ('GH', 'default', '6000', 'Salaries and wages', '{}'::jsonb, 'expense', false, null, 1070),
  ('GH', 'default', '6010', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 1080),
  ('GH', 'default', '6020', 'Directors'' fees', '{}'::jsonb, 'expense', false, null, 1090),
  ('GH', 'default', '6030', 'SSNIT contributions — employer first tier', '{}'::jsonb, 'expense', false, null, 1100),
  ('GH', 'default', '6035', 'Occupational pension contributions — employer second tier', '{}'::jsonb, 'expense', false, null, 1110),
  ('GH', 'default', '6040', 'Provident fund contributions — third tier', '{}'::jsonb, 'expense', false, null, 1120),
  ('GH', 'default', '6045', 'Staff canteen and meals', '{}'::jsonb, 'expense', false, null, 1130),
  ('GH', 'default', '6060', 'Staff welfare', '{}'::jsonb, 'expense', false, null, 1140),
  ('GH', 'default', '6070', 'Staff medical expenses and insurance', '{}'::jsonb, 'expense', false, null, 1150),
  ('GH', 'default', '6080', 'Staff training', '{}'::jsonb, 'expense', false, null, 1160),
  ('GH', 'default', '6200', 'Depreciation of property plant and equipment', '{}'::jsonb, 'expense_depreciation', false, null, 1170),
  ('GH', 'default', '6210', 'Depreciation of right-of-use assets', '{}'::jsonb, 'expense_depreciation', false, null, 1180),
  ('GH', 'default', '6220', 'Amortisation of intangible assets', '{}'::jsonb, 'expense_depreciation', false, null, 1190),
  ('GH', 'default', '6300', 'Rent — short-term leases', '{}'::jsonb, 'expense', false, null, 1200),
  ('GH', 'default', '6310', 'Utilities', '{}'::jsonb, 'expense', false, null, 1210),
  ('GH', 'default', '6320', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 1220),
  ('GH', 'default', '6330', 'Cleaning and security services', '{}'::jsonb, 'expense', false, null, 1230),
  ('GH', 'default', '6340', 'Telephone and internet', '{}'::jsonb, 'expense', false, null, 1240),
  ('GH', 'default', '6350', 'Software subscriptions', '{}'::jsonb, 'expense', false, null, 1250),
  ('GH', 'default', '6360', 'Advertising and marketing', '{}'::jsonb, 'expense', false, null, 1260),
  ('GH', 'default', '6370', 'Travelling', '{}'::jsonb, 'expense', false, null, 1270),
  ('GH', 'default', '6380', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1280),
  ('GH', 'default', '6390', 'Entertainment', '{}'::jsonb, 'expense', false, null, 1290),
  ('GH', 'default', '6395', 'Fuel and lubricants', '{}'::jsonb, 'expense', false, null, 1300),
  ('GH', 'default', '6400', 'Subscriptions and memberships', '{}'::jsonb, 'expense', false, null, 1310),
  ('GH', 'default', '6410', 'Insurance', '{}'::jsonb, 'expense', false, null, 1320),
  ('GH', 'default', '6420', 'Professional fees', '{}'::jsonb, 'expense', false, null, 1330),
  ('GH', 'default', '6430', 'Audit fees', '{}'::jsonb, 'expense', false, null, 1340),
  ('GH', 'default', '6440', 'Company secretarial and registration fees', '{}'::jsonb, 'expense', false, null, 1350),
  ('GH', 'default', '6450', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1360),
  ('GH', 'default', '6460', 'Printing and stationery', '{}'::jsonb, 'expense', false, null, 1370),
  ('GH', 'default', '6470', 'Postage and courier', '{}'::jsonb, 'expense', false, null, 1380),
  ('GH', 'default', '6480', 'Licences permits and metropolitan assembly fees', '{}'::jsonb, 'expense', false, null, 1390),
  ('GH', 'default', '6485', 'Property rates', '{}'::jsonb, 'expense', false, null, 1400),
  ('GH', 'default', '6490', 'Royalties', '{}'::jsonb, 'expense', false, null, 1410),
  ('GH', 'default', '6500', 'Bad debts written off', '{}'::jsonb, 'expense', false, null, 1420),
  ('GH', 'default', '6510', 'Impairment loss on trade receivables', '{}'::jsonb, 'expense', false, null, 1430),
  ('GH', 'default', '6900', 'Donations', '{}'::jsonb, 'expense', false, null, 1440),
  ('GH', 'default', '6950', 'Foreign exchange losses', '{}'::jsonb, 'expense', false, null, 1450),
  ('GH', 'default', '6960', 'Loss on disposal of property plant and equipment', '{}'::jsonb, 'expense', false, null, 1460),
  ('GH', 'default', '6990', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1470),
  ('GH', 'default', '7000', 'Interest on bank loans', '{}'::jsonb, 'expense', false, null, 1480),
  ('GH', 'default', '7010', 'Interest on lease liabilities', '{}'::jsonb, 'expense', false, null, 1490),
  ('GH', 'default', '7020', 'Hire purchase interest', '{}'::jsonb, 'expense', false, null, 1500),
  ('GH', 'default', '7030', 'Interest on loans from related parties and others', '{}'::jsonb, 'expense', false, null, 1510),
  ('GH', 'default', '8000', 'Current income tax expense', '{}'::jsonb, 'expense', false, null, 1520),
  ('GH', 'default', '8010', 'Deferred tax expense', '{}'::jsonb, 'expense', false, null, 1530),
  ('GH', 'default', '8020', 'Under or over provision of income tax in prior years', '{}'::jsonb, 'expense', false, null, 1540)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('GH', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('GH', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('GH', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('GH', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('GH', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('GH', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('GH', 'GH-P-20', 'Purchase, standard rate — VAT 15 % + NHIL 2.5 % + GETFund 2.5 %', '{}'::jsonb, 'A local purchase from a VAT-registered supplier, whose VAT and levies are all deductible', 'percent', 20, 'purchase', 'domestic', date '2026-01-01', null, 'The Value Added Tax Act, 2025 (Act 1151), s. 3, charges the Tax at fifteen per cent of the value of the taxable supply; the National Health Insurance Levy and the Ghana Education Trust Fund Levy are charged at 2.5 % each on the same value (GRA Administrative Guideline GRA/AG/25/002, § 6.0 and § 15.3: "the VAT rate and the Levies (GETFund and NHIL) are imposed on the same taxable value"), and s. 44(1)(a) keeps all three out of the value they are charged on — so the three are side by side, never one in the other''s base, and come to 20 % of the value (the appendix of the Guideline: "15% + 2.5% + 2.5% = 20%"). One 20 % code therefore carries three `tax` postings: 75 % of the tax (15/20) is the VAT, 12.5 % (2.5/20) the NHIL and 12.5 % the GETFund Levy, each on its own account, the arithmetic packs/ca uses for Québec. Section 49(1)(a) lets a taxable person deduct the tax on goods and services purchased in the country and used wholly, exclusively and necessarily in the taxable activity, on a tax invoice; since 1 January 2026 the NHIL and the GETFund Levy are deducted as input tax as well (GRA notice to VAT registered taxpayers; Guideline, appendix, "Tax Fractions for Deductible Input Tax" — a fraction of 1/6 of a tax-inclusive price, the whole 20 %). Form DT 0135, box 12 — taxable local purchases at the standard rate; box 14 — the tax charged on them, here the VAT and both levies together, which is what the recoupling makes deductible.', null, null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'gra-ag-25-002', null, null, null, null),
  ('GH', 'GH-P-20-BL', 'Purchase, standard rate — input tax disallowed (motor vehicle)', '{}'::jsonb, 'A motor vehicle or spare part bought by a business that does not deal in or hire vehicles: the VAT and the levies become part of its cost', 'percent', 20, 'purchase', 'domestic', date '2026-01-01', null, 'Value Added Tax Act, 2025 (Act 1151), s. 50(1) — a taxable person does not qualify for deductible input tax on a taxable supply or import of a motor vehicle or vehicle spare parts unless it is in the business of dealing in or hiring motor vehicles or selling spare parts and the vehicle or part is for use in that business. The 20 % the supplier charged (VAT 15 %, NHIL 2.5 %, GETFund 2.5 %) lands on the account of the line and reaches no box of form DT 0135.', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act-2025', null, null, null, null),
  ('GH', 'GH-P-EX', 'Purchase, exempt', '{}'::jsonb, 'A purchase of a supply the First Schedule exempts, such as insurance other than non-life insurance, a residential lease or local unprocessed food', 'percent', 0, 'purchase', 'exempt', date '2026-01-01', null, 'Value Added Tax Act, 2025 (Act 1151), s. 35(1) and the First Schedule. No tax is charged; form DT 0135 has no box for exempt inputs, so this code reaches none.', null, null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act-2025', null, null, null, null),
  ('GH', 'GH-P-IMP', 'Import of goods — VAT 15 % + NHIL 2.5 % + GETFund 2.5 % paid at customs', '{}'::jsonb, 'Goods imported for home consumption: the VAT and the levies are paid to GRA Customs on the bill of entry and deducted as input tax on the monthly return', 'percent', 20, 'purchase', 'import', date '2026-01-01', null, 'Value Added Tax Act, 2025 (Act 1151), s. 1(1)(b) and s. 1(3) — the Tax is chargeable and payable on the importation of goods; s. 2(b) — by the importer; s. 45(1) — on the customs value, the import duties and taxes other than the Tax, and insurance and freight not already in it; s. 49(1)(a)(iii) — deductible on the customs entries showing the Tax was paid. The levies are charged on the same value and deducted the same way since 1 January 2026. Form DT 0135, box 15 — value of imports; box 17 — the tax charged on them. The customs value is the base a line here should carry, which is the importer''s to compute from the bill of entry; the opposite posting holds what is owed to GRA Customs on account 2125 until it is paid.', null, null, 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act-2025', null, null, null, null),
  ('GH', 'GH-P-ZR', 'Purchase, zero-rated', '{}'::jsonb, 'A purchase of a supply the Second Schedule zero-rates', 'percent', 0, 'purchase', 'domestic', date '2026-01-01', null, 'Value Added Tax Act, 2025 (Act 1151), s. 36(1) and the Second Schedule. No tax is charged, so there is none to deduct; form DT 0135 reports inputs taxed at a positive rate only (boxes 9 to 17), so this code reaches no box.', null, null, 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act-2025', null, null, null, null),
  ('GH', 'GH-S-20', 'Sale, standard rate — VAT 15 % + NHIL 2.5 % + GETFund 2.5 %', '{}'::jsonb, 'The standard charge on a taxable supply made in Ghana: 20 % of the value, of which 15 points are VAT and 2.5 points each the two levies', 'percent', 20, 'sale', 'domestic', date '2026-01-01', null, 'The Value Added Tax Act, 2025 (Act 1151), s. 3, charges the Tax at fifteen per cent of the value of the taxable supply; the National Health Insurance Levy and the Ghana Education Trust Fund Levy are charged at 2.5 % each on the same value (GRA Administrative Guideline GRA/AG/25/002, § 6.0 and § 15.3: "the VAT rate and the Levies (GETFund and NHIL) are imposed on the same taxable value"), and s. 44(1)(a) keeps all three out of the value they are charged on — so the three are side by side, never one in the other''s base, and come to 20 % of the value (the appendix of the Guideline: "15% + 2.5% + 2.5% = 20%"). One 20 % code therefore carries three `tax` postings: 75 % of the tax (15/20) is the VAT, 12.5 % (2.5/20) the NHIL and 12.5 % the GETFund Levy, each on its own account, the arithmetic packs/ca uses for Québec. Section 1(1)(a) imposes the Tax on a supply made in the country other than an exempt one, and s. 2(a) makes the taxable person who makes it liable. Form DT 0135, box i — the value of taxable supplies; box ii — NHIL; box iii — GETFund Levy; box 3 — VAT. Since 1 January 2026 the levies are no longer non-deductible costs charged ahead of the VAT: the COVID-19 Health Recovery Levy was repealed and the NHIL and the GETFund Levy recoupled, which is why no code here computes the VAT on a levy-inclusive value any more.', null, null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'gra-ag-25-002', null, null, null, null),
  ('GH', 'GH-S-EX', 'Exempt supply — First Schedule', '{}'::jsonb, 'A supply the First Schedule exempts: unprocessed local food, education, medical services, pharmaceuticals, domestic passenger transport, residential accommodation, financial services other than non-life insurance, among others', 'percent', 0, 'sale', 'exempt', date '2026-01-01', null, 'Value Added Tax Act, 2025 (Act 1151), s. 35(1) — the supply of goods or services specified in the First Schedule is an exempt supply and not subject to the Tax; First Schedule, paragraphs 2 to 24; s. 49(3) — no input tax deduction on purchases in respect of exempt supplies. Form DT 0135, box 7 — exempt supplies.', null, null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act-2025', null, null, null, null),
  ('GH', 'GH-S-NS-SVC', 'Service supplied outside Ghana — not subject', '{}'::jsonb, 'A service whose place of supply is outside Ghana, such as a professional or advertising service used by a recipient abroad', 'percent', 0, 'sale', 'not_subject', date '2026-01-01', null, 'Value Added Tax Act, 2025 (Act 1151), s. 1(1)(a) — the Tax is charged on a supply of goods or services made in the country; s. 42(2) — the services it lists (the service of a consultant, engineer, lawyer, architect, accountant or other professional, data processing, advertising, the supply of personnel, the transfer of a right) take place where the recipient uses them; s. 42(4) — a service supplied from a place of business in Ghana that is treated as supplied outside it is considered exported. The Second Schedule, paragraph 3, zero-rates only the services it names, so a service exported under s. 42(4) is outside the Tax rather than zero-rated. Form DT 0135 has no box for a supply made outside the country, and this code reaches none.', null, null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act-2025', null, null, null, null),
  ('GH', 'GH-S-RELIEF', 'Relief supply — Third Schedule', '{}'::jsonb, 'A supply to a person the Third Schedule relieves from the Tax: an embassy or its diplomats on reciprocity, an international agency under an agreement approved by Parliament, a holder of a mineral reconnaissance or prospecting licence', 'percent', 0, 'sale', 'domestic', date '2026-01-01', null, 'Value Added Tax Act, 2025 (Act 1151), s. 38(1) — the individuals, organisations and matters specified in the Third Schedule are entitled to relief from the Tax on taxable supplies of goods acquired in the country; Third Schedule, paragraphs 2 to 9. Form DT 0135, box 5 — supplies on which authority has been granted to remit or relieve the VAT that would normally have been chargeable. The Guideline, § 15.8, has the reconnaissance and prospecting licence holder pay the Tax and claim a refund under s. 53, which is a sale at GH-S-20 and not this code.', null, null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act-2025', null, null, null, null),
  ('GH', 'GH-S-ZR-DOM', 'Domestic supply, zero-rated', '{}'::jsonb, 'A supply the Second Schedule zero-rates without the goods leaving Ghana — locally manufactured sanitary towels, locally manufactured textiles by an approved manufacturer until 31 December 2028, goods to a free zone developer or enterprise', 'percent', 0, 'sale', 'domestic', date '2026-01-01', null, 'Value Added Tax Act, 2025 (Act 1151), s. 36(1); Second Schedule, paragraph 2(6) — goods supplied to a free zone developer or free zone enterprise with documentation satisfying the Free Zone Act, 1995 (Act 504); paragraph 2(10) — locally manufactured textiles supplied up to 31 December 2028 by a manufacturer approved by the Minister responsible for Trade; paragraph 2(11) — locally manufactured sanitary towels. Form DT 0135, box 4.', null, null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act-2025', null, null, null, null),
  ('GH', 'GH-S-ZR-EXP', 'Export of goods, zero-rated', '{}'::jsonb, 'Goods the supplier entered for export under the Customs Act and exported', 'percent', 0, 'sale', 'export', date '2026-01-01', null, 'Value Added Tax Act, 2025 (Act 1151), s. 36(1) — a taxable supply is taxable at zero per cent if the Second Schedule specifies it; Second Schedule, paragraph 2(1) — a supply of goods the supplier entered for export under the Customs Act, 2015 (Act 891) and exported; paragraph 2(3) — the conditions of examination and cargo manifest; s. 36(2) — documentary proof retained. No levy is charged either: the levies are charged on the value of a taxable supply at the positive rate. Form DT 0135, box 4 — zero rated (e.g. exports).', null, null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act-2025', null, null, null, null)
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
    ('GH-P-20', 'invoice', 'base', 100, null, '12', array['12']::text[], 100, 'GH-DT0135', 10),
    ('GH-P-20', 'invoice', 'tax', 75, '1150', '14', array['14']::text[], 75, 'GH-DT0135', 20),
    ('GH-P-20', 'invoice', 'tax', 12.5, '1151', '14', array['14']::text[], 12.5, 'GH-DT0135', 30),
    ('GH-P-20', 'invoice', 'tax', 12.5, '1152', '14', array['14']::text[], 12.5, 'GH-DT0135', 40),
    ('GH-P-20', 'credit_note', 'base', 100, null, '12', array['12']::text[], -100, 'GH-DT0135', 10),
    ('GH-P-20', 'credit_note', 'tax', 75, '1150', '14', array['14']::text[], -75, 'GH-DT0135', 20),
    ('GH-P-20', 'credit_note', 'tax', 12.5, '1151', '14', array['14']::text[], -12.5, 'GH-DT0135', 30),
    ('GH-P-20', 'credit_note', 'tax', 12.5, '1152', '14', array['14']::text[], -12.5, 'GH-DT0135', 40),
    ('GH-P-20-BL', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('GH-P-20-BL', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('GH-P-20-BL', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('GH-P-20-BL', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('GH-P-EX', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('GH-P-EX', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('GH-P-IMP', 'invoice', 'base', 100, null, '15', array['15']::text[], 100, 'GH-DT0135', 10),
    ('GH-P-IMP', 'invoice', 'tax', 75, '1150', '17', array['17']::text[], 75, 'GH-DT0135', 20),
    ('GH-P-IMP', 'invoice', 'tax', 12.5, '1151', '17', array['17']::text[], 12.5, 'GH-DT0135', 30),
    ('GH-P-IMP', 'invoice', 'tax', 12.5, '1152', '17', array['17']::text[], 12.5, 'GH-DT0135', 40),
    ('GH-P-IMP', 'invoice', 'tax', -100, '2125', null, null, 100, null, 50),
    ('GH-P-IMP', 'credit_note', 'base', 100, null, '15', array['15']::text[], -100, 'GH-DT0135', 10),
    ('GH-P-IMP', 'credit_note', 'tax', 75, '1150', '17', array['17']::text[], -75, 'GH-DT0135', 20),
    ('GH-P-IMP', 'credit_note', 'tax', 12.5, '1151', '17', array['17']::text[], -12.5, 'GH-DT0135', 30),
    ('GH-P-IMP', 'credit_note', 'tax', 12.5, '1152', '17', array['17']::text[], -12.5, 'GH-DT0135', 40),
    ('GH-P-IMP', 'credit_note', 'tax', -100, '2125', null, null, 100, null, 50),
    ('GH-P-ZR', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('GH-P-ZR', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('GH-S-20', 'invoice', 'base', 100, null, 'i', array['i']::text[], 100, 'GH-DT0135', 10),
    ('GH-S-20', 'invoice', 'tax', 75, '2100', '3', array['3']::text[], 75, 'GH-DT0135', 20),
    ('GH-S-20', 'invoice', 'tax', 12.5, '2101', 'ii', array['ii']::text[], 12.5, 'GH-DT0135', 30),
    ('GH-S-20', 'invoice', 'tax', 12.5, '2102', 'iii', array['iii']::text[], 12.5, 'GH-DT0135', 40),
    ('GH-S-20', 'credit_note', 'base', 100, null, 'i', array['i']::text[], -100, 'GH-DT0135', 10),
    ('GH-S-20', 'credit_note', 'tax', 75, '2100', '3', array['3']::text[], -75, 'GH-DT0135', 20),
    ('GH-S-20', 'credit_note', 'tax', 12.5, '2101', 'ii', array['ii']::text[], -12.5, 'GH-DT0135', 30),
    ('GH-S-20', 'credit_note', 'tax', 12.5, '2102', 'iii', array['iii']::text[], -12.5, 'GH-DT0135', 40),
    ('GH-S-EX', 'invoice', 'base', 100, null, '7', array['7']::text[], 100, 'GH-DT0135', 10),
    ('GH-S-EX', 'credit_note', 'base', 100, null, '7', array['7']::text[], -100, 'GH-DT0135', 10),
    ('GH-S-NS-SVC', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('GH-S-NS-SVC', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('GH-S-RELIEF', 'invoice', 'base', 100, null, '5', array['5']::text[], 100, 'GH-DT0135', 10),
    ('GH-S-RELIEF', 'credit_note', 'base', 100, null, '5', array['5']::text[], -100, 'GH-DT0135', 10),
    ('GH-S-ZR-DOM', 'invoice', 'base', 100, null, '4', array['4']::text[], 100, 'GH-DT0135', 10),
    ('GH-S-ZR-DOM', 'credit_note', 'base', 100, null, '4', array['4']::text[], -100, 'GH-DT0135', 10),
    ('GH-S-ZR-EXP', 'invoice', 'base', 100, null, '4', array['4']::text[], 100, 'GH-DT0135', 10),
    ('GH-S-ZR-EXP', 'credit_note', 'base', 100, null, '4', array['4']::text[], -100, 'GH-DT0135', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'GH' and t.code = v.tax_code
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
  ('GH', 'GH-DT0135', 'Monthly Standard VAT Return (form DT 0135)', array['month']::declaration_period[], 'month'::declaration_period, date '2026-01-01', null, 'Value Added Tax Act, 2025 (Act 1151), s. 59(1) — a taxable person accounts for the Tax for each tax period on a tax return; s. 59(2)(a) — in the form and manner the Commissioner-General prescribes; s. 72 — "tax period" means one calendar month, for every taxable person, which is why the period is fixed. The form the Commissioner-General still publishes is DT 0135 ver 1.5, the standard rate return of VAT, NHIL, GETFund and COVID-19 levy; the return is filed on the GRA Taxpayers'' Portal. The pack carries its boxes i to iv and 1 to 25 with the adaptations the 2026 reform requires, each said on its box: no flat rate inputs (boxes 9 to 11), no withholding VAT credits (18 to 20), no credit brought forward (26), no rates (2, 13, 16, 19).', true,'last_day_of_month_after_period'::filing_deadline_rule, null, null, 'Value Added Tax Act, 2025 (Act 1151), s. 59(5) — the tax return is submitted not later than the last working day of the month immediately following the month to which it relates, whether or not Tax is payable; s. 60(1) — the Tax is paid by the same date. Ekwo''s rule is the last calendar day of that month; a month that ends on a Saturday, a Sunday or a public holiday brings the Ghanaian date forward to the working day before, which the rule does not see.', 'vat-act-2025', null)
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
  ('GH', 'GH-DT0135', 'i', 'base', 'Taxable supplies', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form DT 0135, line i — the value of taxable supplies of goods and services made during the month, excluding the Tax and the levies (Value Added Tax Act, 2025, s. 44(1)(a)).', 'dt-0135'),
  ('GH', 'GH-DT0135', 'ii', 'tax', 'NHIL', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form DT 0135, line ii — the National Health Insurance Levy, 2.5 % of the value on line i since 1 January 2026 (Guideline GRA/AG/25/002, § 15.3).', 'gra-ag-25-002'),
  ('GH', 'GH-DT0135', 'iii', 'tax', 'GET Fund Levy', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form DT 0135, line iii — the Ghana Education Trust Fund Levy, 2.5 % of the value on line i since 1 January 2026 (Guideline GRA/AG/25/002, § 15.3).', 'gra-ag-25-002'),
  ('GH', 'GH-DT0135', 'iv', 'tax', 'COVID-19 Levy', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form DT 0135, line iv — the COVID-19 Health Recovery Levy. The levy was abolished on 1 January 2026 by the repeal of the COVID-19 Health Recovery Levy Act, 2021 (Act 1068); the Guideline, § 15.6, tells taxpayers to ignore the COVID-19 field of the form still in use. The line is carried so the form reads as it prints, and no tax code of this pack ever posts to it.', 'gra-notice-2026'),
  ('GH', 'GH-DT0135', '1', 'total', 'Taxable value inclusive of levies', '{}'::jsonb, 50, null, array['i', 'ii', 'iii', 'iv']::text[], '{}'::text[], null, null, false, false, null, 'Form DT 0135, box 1 — the VAT-exclusive value of taxable supplies, which includes items i to iv. Under the repealed Act 870 this was the base of the VAT; under Act 1151 the VAT is charged on the value of line i alone, so box 1 is kept as the form prints it and box 3 is no longer box 1 multiplied by box 2.', 'dt-0135'),
  ('GH', 'GH-DT0135', '3', 'tax', 'VAT', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form DT 0135, box 3 — the amount of VAT charged, 15 % of the value of the taxable supply (Value Added Tax Act, 2025, s. 3). Box 2, the rate, is a percentage and not an amount, and is not carried.', 'dt-0135'),
  ('GH', 'GH-DT0135', '4', 'base', 'Zero rated', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form DT 0135, box 4 — the value of zero-rated supplies (e.g. exports) made during the month; Value Added Tax Act, 2025, s. 36 and the Second Schedule.', 'dt-0135'),
  ('GH', 'GH-DT0135', '5', 'base', 'Relief', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form DT 0135, box 5 — the value of supplies on which authority has been granted to remit or relieve the VAT; Value Added Tax Act, 2025, s. 38 and the Third Schedule.', 'dt-0135'),
  ('GH', 'GH-DT0135', '6', 'total', 'Total value of taxable supplies', '{}'::jsonb, 90, null, array['1', '4', '5']::text[], '{}'::text[], null, null, false, false, null, 'Form DT 0135, box 6 — the sum of boxes 1, 4 and 5.', 'dt-0135'),
  ('GH', 'GH-DT0135', '7', 'base', 'Exempt supplies', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form DT 0135, box 7 — the value of exempt supplies made during the month; Value Added Tax Act, 2025, s. 35 and the First Schedule.', 'dt-0135'),
  ('GH', 'GH-DT0135', '8', 'total', 'Total value of supplies', '{}'::jsonb, 110, null, array['6', '7']::text[], '{}'::text[], null, null, false, false, null, 'Form DT 0135, box 8 — the sum of boxes 6 and 7.', 'dt-0135'),
  ('GH', 'GH-DT0135', '12', 'base', 'Local input (standard) — value', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form DT 0135, box 12 — the VAT-exclusive value of taxable local purchases and expenses taxed at the standard rate. Boxes 9 to 11, local inputs from a VAT flat rate taxpayer, are not carried: the VAT Flat Rate Scheme was abolished on 1 January 2026 (GRA notice to VAT registered taxpayers; Guideline, § 15.2).', 'dt-0135'),
  ('GH', 'GH-DT0135', '14', 'tax', 'Local input (standard) — VAT and levies', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form DT 0135, box 14 — the tax charged on the purchases of box 12. Since the NHIL and the GETFund Levy are deductible as input tax from 1 January 2026, this pack reports the VAT and both levies here, the single tax column the form has on its input side; box 13, the rate, is not carried.', 'gra-notice-2026'),
  ('GH', 'GH-DT0135', '15', 'base', 'Imports — value', '{}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form DT 0135, box 15 — the VAT-exclusive value of imports made during the period; Value Added Tax Act, 2025, s. 45(1).', 'dt-0135'),
  ('GH', 'GH-DT0135', '17', 'tax', 'Imports — VAT and levies', '{}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form DT 0135, box 17 — the tax charged on imports, here the VAT and both levies paid on the bill of entry; box 16, the rate, is not carried.', 'dt-0135'),
  ('GH', 'GH-DT0135', '21', 'total', 'Total value of inputs', '{}'::jsonb, 160, null, array['12', '15']::text[], '{}'::text[], null, null, false, false, null, 'Form DT 0135, box 21 — the sum of boxes 9, 12, 15 and 18. Box 9 (flat rate inputs, abolished) and box 18 (supplies on which a withholding VAT certificate was received, a figure that comes from the certificates and not from a posting) are not carried, so the total is boxes 12 and 15.', 'dt-0135'),
  ('GH', 'GH-DT0135', '22', 'total', 'Total VAT on inputs', '{}'::jsonb, 170, null, array['14', '17']::text[], '{}'::text[], null, null, false, false, null, 'Form DT 0135, box 22 — the sum of boxes 11, 14, 17 and 20; boxes 11 and 20 are not carried, for the reasons given at box 21, so the total is boxes 14 and 17. A withholding VAT credit (box 20) is claimed by hand from the certificate the agent issued (Value Added Tax Act, 2025, s. 56; Guideline, § 12.1 D).', 'dt-0135'),
  ('GH', 'GH-DT0135', '23', 'total', 'Deductible input VAT', '{}'::jsonb, 180, null, array['22']::text[], '{}'::text[], null, null, false, false, null, 'Form DT 0135, box 23 — the input tax the taxable person is entitled to offset; for a fully taxable person the completion notes say it may be the figure of box 22. Apportionment for a person who also makes exempt supplies (Value Added Tax Act, 2025, s. 52 and the Fifth Schedule) is not carried, so box 23 is box 22 — the figure a wholly taxable business files.', 'dt-0135'),
  ('GH', 'GH-DT0135', 'OUT', 'total', 'Output VAT and levies', '{}'::jsonb, 185, null, array['3', 'ii', 'iii', 'iv']::text[], '{}'::text[], null, null, false, true, null, 'Not a box of form DT 0135: the tax charged on the month''s supplies — the VAT of box 3 and the levies of lines ii to iv — which the portal return settles together since the levies are paid to GRA on the same return and, from 1 January 2026, deducted against the same inputs.', 'gra-ag-25-002'),
  ('GH', 'GH-DT0135', '24', 'total', 'Net payment due', '{}'::jsonb, 190, null, array['OUT']::text[], array['23']::text[], null, null, true, false, null, 'Form DT 0135, box 24 — box 3 minus box 23 when the output figure is greater. Box 3 on the printed form is the VAT of a levy-inclusive value, which carried the levies with it; under Act 1151 the levies are charged beside the VAT, so this pack takes the output VAT and the levies together (the hidden total OUT) less box 23. Payable by the day the return is due (Value Added Tax Act, 2025, s. 60(1)).', 'dt-0135'),
  ('GH', 'GH-DT0135', '25', 'total', 'Net credit or overpayment', '{}'::jsonb, 200, null, array['23']::text[], array['OUT']::text[], null, null, true, false, null, 'Form DT 0135, box 25 — box 23 minus the output figure when the input is greater, dealt with under s. 48(2) and s. 53 of the Value Added Tax Act, 2025 (refund or credit). Box 26, the credit brought forward from the last month, is period-to-period settlement and not a figure a document posts, and is not carried.', 'dt-0135')
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
  ('GH-ICAG-IS', 'GH', 'default', 'Statement of profit or loss', 'income_statement', 'IFRS-SME', date '2019-08-02', null, 'Companies Act, 2019 (Act 992), s. 127(5)(a)(ii) — the financial statements comprise a statement of comprehensive income, prepared under s. 127(5)(b) in compliance with the IFRS adopted by the Institute of Chartered Accountants, Ghana; the definition of "financial year" in s. 383 is the period that statement covers. The lines are the analysis of expenses by nature that section 5 of the IFRS for SMEs allows, down to profit for the year; other comprehensive income is not booked by any account of this chart, so the statement stops at profit or loss.', 'companies-act-2019'),
  ('GH-ICAG-SFP', 'GH', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS-SME', date '2019-08-02', null, 'Companies Act, 2019 (Act 992), s. 127(5)(a)(i) — the financial statements of a company comprise a statement of financial position; s. 127(5)(b) — they are prepared in compliance with the International Financial Reporting Standards adopted by the Institute of Chartered Accountants, Ghana, or any other standards the Institute approves or adopts; Sixth Schedule, Part Two, paragraph 13 — assets and liabilities are classified under headings appropriate to the business, distinguishing current from non-current assets and current from other liabilities, in accordance with the IFRS. The Institute adopted the IFRS as Ghana National Accounting Standards in 2007 and the IFRS for SMEs in 2010, for periods ending on or after 31 December 2015 after a two-year moratorium. There is no prescribed layout: the lines below are the minimum line items of section 4 of the IFRS for SMEs, which a full-IFRS company expands under IAS 1.', 'companies-act-2019')
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
  ('GH-ICAG-IS', '1', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-IS', '2', null, 'Other income', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-IS', '3', null, 'Purchases and changes in inventories', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-IS', '4', null, 'Employee benefits expense', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-IS', '5', null, 'Depreciation and amortisation', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-IS', '6', null, 'Other operating expenses', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-IS', '7', null, 'Finance costs', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-IS', '8', null, 'Profit before tax', '{}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('GH-ICAG-IS', '9', null, 'Income tax expense', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-IS', '10', null, 'Profit for the year', '{}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, null, null),
  ('GH-ICAG-SFP', 'CA', null, 'Current assets', '{}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5', 'CA.6']::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'CA.1', null, 'Cash and cash equivalents', '{}'::jsonb, 11, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'CA.2', null, 'Trade and other receivables', '{}'::jsonb, 12, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'CA.3', null, 'Inventories', '{}'::jsonb, 13, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'CA.4', null, 'Financial assets', '{}'::jsonb, 14, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'CA.5', null, 'Current tax recoverable', '{}'::jsonb, 15, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'CA.6', null, 'Prepayments and accrued income', '{}'::jsonb, 16, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'NCA', null, 'Non-current assets', '{}'::jsonb, 20, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4', 'NCA.5', 'NCA.6', 'NCA.7']::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'NCA.1', null, 'Property, plant and equipment', '{}'::jsonb, 21, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'NCA.2', null, 'Investment property', '{}'::jsonb, 22, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'NCA.3', null, 'Intangible assets', '{}'::jsonb, 23, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'NCA.4', null, 'Investments in associates', '{}'::jsonb, 24, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'NCA.5', null, 'Investments in joint ventures', '{}'::jsonb, 25, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'NCA.6', null, 'Financial assets', '{}'::jsonb, 26, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'NCA.7', null, 'Deferred tax assets', '{}'::jsonb, 27, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'TA', null, 'Total assets', '{}'::jsonb, 30, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'CL', null, 'Current liabilities', '{}'::jsonb, 40, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4', 'CL.5']::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'CL.1', null, 'Trade and other payables', '{}'::jsonb, 41, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'CL.2', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 42, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'CL.3', null, 'Amounts due to directors', '{}'::jsonb, 43, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'CL.4', null, 'Current tax payable', '{}'::jsonb, 44, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'CL.5', null, 'Provisions', '{}'::jsonb, 45, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'NCL', null, 'Non-current liabilities', '{}'::jsonb, 50, 1, true, array['NCL.1', 'NCL.2', 'NCL.3']::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'NCL.1', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 51, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'NCL.2', null, 'Deferred tax liabilities', '{}'::jsonb, 52, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'NCL.3', null, 'Provisions', '{}'::jsonb, 53, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'TL', null, 'Total liabilities', '{}'::jsonb, 60, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'NA', null, 'Net assets', '{}'::jsonb, 70, 1, true, array['TA']::text[], array['TL']::text[], null, null, null),
  ('GH-ICAG-SFP', 'EQ', null, 'Equity', '{}'::jsonb, 80, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'EQ.1', null, 'Share capital', '{}'::jsonb, 81, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'EQ.2', null, 'Other reserves', '{}'::jsonb, 82, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GH-ICAG-SFP', 'EQ.3', null, 'Retained earnings', '{}'::jsonb, 83, -1, false, '{}'::text[], '{}'::text[], null, null, null)
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
    ('GH-ICAG-IS', '1', 10, 'code_range', '4000', '4030', null, 'any'),
    ('GH-ICAG-IS', '2', 10, 'code_range', '4500', '4790', null, 'any'),
    ('GH-ICAG-IS', '3', 10, 'code_range', '5000', '5100', null, 'any'),
    ('GH-ICAG-IS', '4', 10, 'code_range', '6000', '6080', null, 'any'),
    ('GH-ICAG-IS', '5', 10, 'code_range', '6200', '6220', null, 'any'),
    ('GH-ICAG-IS', '6', 10, 'code_range', '6300', '6990', null, 'any'),
    ('GH-ICAG-IS', '7', 10, 'code_range', '7000', '7030', null, 'any'),
    ('GH-ICAG-IS', '9', 10, 'code_range', '8000', '8020', null, 'any'),
    ('GH-ICAG-SFP', 'CA.1', 10, 'code_range', '1000', '1040', null, 'any'),
    ('GH-ICAG-SFP', 'CA.2', 10, 'code_range', '1100', '1160', null, 'any'),
    ('GH-ICAG-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('GH-ICAG-SFP', 'CA.4', 10, 'account_code', '1300', null, null, 'any'),
    ('GH-ICAG-SFP', 'CA.5', 10, 'account_code', '1350', null, null, 'any'),
    ('GH-ICAG-SFP', 'CA.6', 10, 'code_range', '1400', '1410', null, 'any'),
    ('GH-ICAG-SFP', 'NCA.1', 10, 'code_range', '1600', '1671', null, 'any'),
    ('GH-ICAG-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('GH-ICAG-SFP', 'NCA.3', 10, 'code_range', '1750', '1760', null, 'any'),
    ('GH-ICAG-SFP', 'NCA.4', 10, 'account_code', '1800', null, null, 'any'),
    ('GH-ICAG-SFP', 'NCA.5', 10, 'account_code', '1810', null, null, 'any'),
    ('GH-ICAG-SFP', 'NCA.6', 10, 'code_range', '1830', '1840', null, 'any'),
    ('GH-ICAG-SFP', 'NCA.7', 10, 'account_code', '1900', null, null, 'any'),
    ('GH-ICAG-SFP', 'CL.1', 10, 'code_range', '2000', '2190', null, 'any'),
    ('GH-ICAG-SFP', 'CL.1', 20, 'account_code', '2990', null, null, 'credit'),
    ('GH-ICAG-SFP', 'CL.2', 10, 'code_range', '2200', '2240', null, 'any'),
    ('GH-ICAG-SFP', 'CL.3', 10, 'account_code', '2250', null, null, 'any'),
    ('GH-ICAG-SFP', 'CL.4', 10, 'account_code', '2300', null, null, 'any'),
    ('GH-ICAG-SFP', 'CL.5', 10, 'code_range', '2350', '2360', null, 'any'),
    ('GH-ICAG-SFP', 'NCL.1', 10, 'code_range', '2400', '2430', null, 'any'),
    ('GH-ICAG-SFP', 'NCL.2', 10, 'account_code', '2500', null, null, 'any'),
    ('GH-ICAG-SFP', 'NCL.3', 10, 'account_code', '2550', null, null, 'any'),
    ('GH-ICAG-SFP', 'EQ.1', 10, 'code_range', '3000', '3010', null, 'any'),
    ('GH-ICAG-SFP', 'EQ.2', 10, 'code_range', '3100', '3110', null, 'any'),
    ('GH-ICAG-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('GH', 'Ghana', '{}'::jsonb, array['en']::text[], 'GHS', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, 'month'::declaration_period)
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
  numbering_legal_reference     = 'Value Added Tax Act, 2025 (Act 1151), s. 43(4) — a taxable person, on issuing a tax invoice, retains a copy of it in a sequential identifying number order; s. 43(7) — only one tax invoice or sales receipt for each taxable supply. The Act asks for a sequence and not that it carry no gap, which is why the style is `sequential`.',
  numbering_source_key          = 'vat-act-2025',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Value Added Tax Act, 2025 (Act 1151), s. 39(1)(c) — except for own use and gifts, a supply occurs on the EARLIEST of the dates on which (i) the goods are removed from the premises of the taxable person, (ii) the goods are made available to the recipient, (iii) the performance of the service is completed, (iv) payment is received, or (v) a tax invoice or sales receipt is issued; s. 39(2) limits (iv) and (v) to the part paid or invoiced. Ekwo''s closed vocabulary expresses only a two-way earliest-of; `earliest_of_delivery_or_payment` is the nearest value, and the gap — an invoice issued ahead of both delivery and payment, which fixes the time of supply in Ghana — is recorded in docs/international.md and in the README of this pack.',
  tax_point_source_key          = 'vat-act-2025',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No Ghanaian statute obliges a business to exchange a structured electronic invoice with another business in the sense Ekwo''s vocabulary gives the word — there is no Ghanaian Peppol authority, no published profile and no ISO 6523 scheme a party is addressed by, so `profile`, `party_scheme` and `vat_scheme` are null and `obligation` is `none`. What Ghana has instead is a clearance system: Value Added Tax Act, 2025 (Act 1151), s. 43(2) requires a taxable person to issue a tax invoice through a Certified Invoicing System and to integrate it into the invoicing system of the Commissioner-General; s. 43(3) lets the Commissioner-General access it; s. 43(10) requires the taxable person to report within twenty-four hours a system that goes offline; s. 66(2) penalises failing to issue through it or to integrate it; s. 72 defines a tax invoice as an electronic invoice issued through a Certified Invoicing System or any other invoice the Commissioner-General approves. GRA''s E-VAT signs each invoice with the Commissioner-General''s signature, a QR code and a time stamp. That is a real-time validation of an invoice with the tax administration, not a peer-to-peer exchange between two businesses in the sense `einvoicing.profile` describes; Ekwo does not connect to E-VAT, and the gap is recorded in docs/international.md and in this pack''s README.',
  einvoice_source_key           = 'vat-act-2025',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'GH';
