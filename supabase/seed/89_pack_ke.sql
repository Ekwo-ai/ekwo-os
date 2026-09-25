-- Ekwo OS — Kenya: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/ke at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build ke`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Value Added Tax Act (Cap. 476), consolidated as at 27 December 2024 (National Council for Law Reporting (Kenya Law))
--     https://new.kenyalaw.org/akn/ke/act/2013/35/eng@2024-12-27/
--   Tax Procedures Act (Cap. 469B), consolidated as at 27 December 2024, s. 23A — electronic tax invoices (National Council for Law Reporting (Kenya Law))
--     https://new.kenyalaw.org/akn/ke/act/2015/29/eng@2024-12-27/
--   Value Added Tax (Electronic Tax Invoice) Regulations, 2020 — Legal Notice No. 189 of 2020 (Kenya Revenue Authority, gazetted by the Government Printer)
--     https://www.kra.go.ke/images/publications/L.N.-189---VAT-ELECTRONIC-TAX-INVOICE-REGULATIONS-2020.pdf
--   Companies Act (Cap. 486, No. 17 of 2015), consolidated as at 27 December 2024, ss. 628 and 636 to 638 — accounting records and financial statements (National Council for Law Reporting (Kenya Law))
--     https://new.kenyalaw.org/akn/ke/act/2015/17/eng@2024-12-27/
--   Illustrative generic IFRS for SMEs financial statements — Kenya SME Limited (Institute of Certified Public Accountants of Kenya (ICPAK))
--     https://www.icpak.com/wp-content/uploads/2023/03/Kenya-SME-Ltd-Illustrative-SME-Financial-Statements-2022-ICPAK-v1.1.pdf
--   Value Added Tax (VAT) — rates, filing and eTIMS on-boarding (Kenya Revenue Authority)
--     https://www.kra.go.ke/individual/filing-paying/types-of-taxes/value-added-tax
--   VAT Monthly Return, form VAT 3 (workbook template) (Kenya Revenue Authority)
--     https://www.kra.go.ke/images/publications/VAT3_Return-11.0.4-2.xls
--   iTax — where the VAT 3 return is filed and self-assessment payments are registered (Kenya Revenue Authority)
--     https://itax.kra.go.ke/
--   eTIMS — the electronic tax invoicing system of section 23A of the Tax Procedures Act (Kenya Revenue Authority)
--     https://etims.kra.go.ke/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('KE', 'Kenya', '0.1.0', date '2026-09-25', '20260923110000', 'community', null, null, 'd248579b88e4991327510fa7b04852c61dc390e80d7ff3c036e2aefb310c0039', '[{"key":"vat-act","title":"Value Added Tax Act (Cap. 476), consolidated as at 27 December 2024","publisher":"National Council for Law Reporting (Kenya Law)","url":"https://new.kenyalaw.org/akn/ke/act/2013/35/eng@2024-12-27/","consulted_on":"2026-09-25","kind":"law"},{"key":"tpa","title":"Tax Procedures Act (Cap. 469B), consolidated as at 27 December 2024, s. 23A — electronic tax invoices","publisher":"National Council for Law Reporting (Kenya Law)","url":"https://new.kenyalaw.org/akn/ke/act/2015/29/eng@2024-12-27/","consulted_on":"2026-09-25","kind":"law"},{"key":"vat-etr-regs-2020","title":"Value Added Tax (Electronic Tax Invoice) Regulations, 2020 — Legal Notice No. 189 of 2020","publisher":"Kenya Revenue Authority, gazetted by the Government Printer","url":"https://www.kra.go.ke/images/publications/L.N.-189---VAT-ELECTRONIC-TAX-INVOICE-REGULATIONS-2020.pdf","consulted_on":"2026-09-25","kind":"regulation"},{"key":"companies-act-2015","title":"Companies Act (Cap. 486, No. 17 of 2015), consolidated as at 27 December 2024, ss. 628 and 636 to 638 — accounting records and financial statements","publisher":"National Council for Law Reporting (Kenya Law)","url":"https://new.kenyalaw.org/akn/ke/act/2015/17/eng@2024-12-27/","consulted_on":"2026-09-25","kind":"law"},{"key":"icpak-ifrs-sme","title":"Illustrative generic IFRS for SMEs financial statements — Kenya SME Limited","publisher":"Institute of Certified Public Accountants of Kenya (ICPAK)","url":"https://www.icpak.com/wp-content/uploads/2023/03/Kenya-SME-Ltd-Illustrative-SME-Financial-Statements-2022-ICPAK-v1.1.pdf","consulted_on":"2026-09-25","kind":"guidance"},{"key":"kra-vat","title":"Value Added Tax (VAT) — rates, filing and eTIMS on-boarding","publisher":"Kenya Revenue Authority","url":"https://www.kra.go.ke/individual/filing-paying/types-of-taxes/value-added-tax","consulted_on":"2026-09-25","kind":"guidance"},{"key":"vat3-form","title":"VAT Monthly Return, form VAT 3 (workbook template)","publisher":"Kenya Revenue Authority","url":"https://www.kra.go.ke/images/publications/VAT3_Return-11.0.4-2.xls","consulted_on":"2026-09-25","kind":"form"},{"key":"itax","title":"iTax — where the VAT 3 return is filed and self-assessment payments are registered","publisher":"Kenya Revenue Authority","url":"https://itax.kra.go.ke/","consulted_on":"2026-09-25","kind":"portal"},{"key":"etims","title":"eTIMS — the electronic tax invoicing system of section 23A of the Tax Procedures Act","publisher":"Kenya Revenue Authority","url":"https://etims.kra.go.ke/","consulted_on":"2026-09-25","kind":"portal"}]'::jsonb)
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
  ('KE', 'default', 'Kenya reference chart of accounts', '{}'::jsonb, true, 'companies', array['KE-ICPAK-IS', 'KE-ICPAK-SFP']::text[], null, 'There is no legal chart of accounts in Kenya. Companies Act (Cap. 486), s. 628(1) requires every company to keep proper accounting records, s. 628(3)(b) requires those records to comply with the prescribed financial accounting standards, and s. 638 requires the directors'' individual financial statements — a balance sheet, a profit and loss account, a statement of cash flow and a statement of changes in equity — to give a true and fair view and to comply with those same prescribed standards; the Institute of Certified Public Accountants of Kenya, the standard-setting body the Accountants Act, 2008 recognises, has adopted the IFRS Accounting Standards and, for an entity with no public accountability, the IFRS for SMEs Accounting Standard. This chart is original: four digits, blocked so that each range reaches one line of the IFRS for SMEs statements below, with the accounts a Kenyan company actually keeps — VAT input and output tax, import VAT owed to KRA at the border, NSSF and SHIF contributions, the NITA training levy, withholding tax, amounts due to directors.', 'companies-act-2015')
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
  ('KE', 'default', '1000', 'Petty cash', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('KE', 'default', '1010', 'Current account — KES', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('KE', 'default', '1020', 'Fixed deposits placed for three months or less', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('KE', 'default', '1030', 'Foreign currency account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('KE', 'default', '1040', 'Cash in transit — M-Pesa and card settlements', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('KE', 'default', '1100', 'Trade receivables', '{}'::jsonb, 'asset_receivable', true, null, 60),
  ('KE', 'default', '1110', 'Trade receivables — allowance for impairment', '{}'::jsonb, 'asset_current', false, null, 70),
  ('KE', 'default', '1120', 'Other receivables', '{}'::jsonb, 'asset_current', false, null, 80),
  ('KE', 'default', '1130', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 90),
  ('KE', 'default', '1140', 'Deposits paid', '{}'::jsonb, 'asset_current', false, null, 100),
  ('KE', 'default', '1150', 'VAT input tax', '{}'::jsonb, 'asset_current', false, null, 110),
  ('KE', 'default', '1155', 'VAT refundable by KRA — net of a filed return', '{}'::jsonb, 'asset_current', true, null, 120),
  ('KE', 'default', '1160', 'Advances to staff', '{}'::jsonb, 'asset_current', false, null, 130),
  ('KE', 'default', '1200', 'Inventories — goods for resale', '{}'::jsonb, 'asset_current', false, null, 140),
  ('KE', 'default', '1210', 'Inventories — raw materials', '{}'::jsonb, 'asset_current', false, null, 150),
  ('KE', 'default', '1220', 'Inventories — work in progress', '{}'::jsonb, 'asset_current', false, null, 160),
  ('KE', 'default', '1230', 'Inventories — finished goods', '{}'::jsonb, 'asset_current', false, null, 170),
  ('KE', 'default', '1300', 'Short-term investments', '{}'::jsonb, 'asset_current', false, null, 180),
  ('KE', 'default', '1350', 'Current tax recoverable', '{}'::jsonb, 'asset_current', false, null, 190),
  ('KE', 'default', '1400', 'Prepayments', '{}'::jsonb, 'asset_prepayments', false, null, 200),
  ('KE', 'default', '1410', 'Accrued income', '{}'::jsonb, 'asset_prepayments', false, null, 210),
  ('KE', 'default', '1600', 'Land and buildings — cost', '{}'::jsonb, 'asset_fixed', false, null, 220),
  ('KE', 'default', '1601', 'Land and buildings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 230),
  ('KE', 'default', '1610', 'Leasehold improvements — cost', '{}'::jsonb, 'asset_fixed', false, null, 240),
  ('KE', 'default', '1611', 'Leasehold improvements — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 250),
  ('KE', 'default', '1620', 'Plant and machinery — cost', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('KE', 'default', '1621', 'Plant and machinery — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('KE', 'default', '1630', 'Office equipment — cost', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('KE', 'default', '1631', 'Office equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('KE', 'default', '1640', 'Computers — cost', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('KE', 'default', '1641', 'Computers — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('KE', 'default', '1650', 'Furniture and fittings — cost', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('KE', 'default', '1651', 'Furniture and fittings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('KE', 'default', '1660', 'Motor vehicles — cost', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('KE', 'default', '1661', 'Motor vehicles — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('KE', 'default', '1670', 'Right-of-use assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('KE', 'default', '1671', 'Right-of-use assets — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('KE', 'default', '1700', 'Investment property', '{}'::jsonb, 'asset_non_current', false, null, 380),
  ('KE', 'default', '1750', 'Intangible assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 390),
  ('KE', 'default', '1751', 'Intangible assets — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 400),
  ('KE', 'default', '1760', 'Goodwill', '{}'::jsonb, 'asset_fixed', false, null, 410),
  ('KE', 'default', '1800', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('KE', 'default', '1810', 'Investments in joint ventures', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('KE', 'default', '1830', 'Long-term financial assets', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('KE', 'default', '1840', 'Long-term deposits', '{}'::jsonb, 'asset_non_current', false, null, 450),
  ('KE', 'default', '1900', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('KE', 'default', '2000', 'Trade payables', '{}'::jsonb, 'liability_payable', true, null, 470),
  ('KE', 'default', '2010', 'Accrued expenses', '{}'::jsonb, 'liability_current', false, null, 480),
  ('KE', 'default', '2020', 'Other payables', '{}'::jsonb, 'liability_current', false, null, 490),
  ('KE', 'default', '2030', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 500),
  ('KE', 'default', '2040', 'Deposits received from customers', '{}'::jsonb, 'liability_current', false, null, 510),
  ('KE', 'default', '2100', 'VAT output tax', '{}'::jsonb, 'liability_current', false, null, 520),
  ('KE', 'default', '2110', 'VAT payable to KRA — net of a filed return', '{}'::jsonb, 'liability_current', true, null, 530),
  ('KE', 'default', '2125', 'Import VAT payable to KRA at the border', '{}'::jsonb, 'liability_current', false, null, 540),
  ('KE', 'default', '2140', 'Withholding tax payable to KRA', '{}'::jsonb, 'liability_current', false, null, 550),
  ('KE', 'default', '2150', 'NSSF contributions payable', '{}'::jsonb, 'liability_current', false, null, 560),
  ('KE', 'default', '2155', 'SHIF contributions payable', '{}'::jsonb, 'liability_current', false, null, 570),
  ('KE', 'default', '2160', 'NITA training levy payable', '{}'::jsonb, 'liability_current', false, null, 580),
  ('KE', 'default', '2180', 'Salaries payable', '{}'::jsonb, 'liability_current', false, null, 590),
  ('KE', 'default', '2190', 'Directors'' fees payable', '{}'::jsonb, 'liability_current', false, null, 600),
  ('KE', 'default', '2200', 'Bank overdraft', '{}'::jsonb, 'liability_current', false, null, 610),
  ('KE', 'default', '2210', 'Bank loans — current portion', '{}'::jsonb, 'liability_current', false, null, 620),
  ('KE', 'default', '2220', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 630),
  ('KE', 'default', '2230', 'Hire purchase — current portion', '{}'::jsonb, 'liability_current', false, null, 640),
  ('KE', 'default', '2240', 'Corporate credit card', '{}'::jsonb, 'liability_credit_card', false, null, 650),
  ('KE', 'default', '2250', 'Amounts due to directors', '{}'::jsonb, 'liability_current', false, null, 660),
  ('KE', 'default', '2300', 'Current tax payable', '{}'::jsonb, 'liability_current', false, null, 670),
  ('KE', 'default', '2350', 'Provision for unutilised leave', '{}'::jsonb, 'liability_current', false, null, 680),
  ('KE', 'default', '2360', 'Other provisions — current', '{}'::jsonb, 'liability_current', false, null, 690),
  ('KE', 'default', '2400', 'Bank loans — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 700),
  ('KE', 'default', '2410', 'Lease liabilities — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 710),
  ('KE', 'default', '2420', 'Hire purchase — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 720),
  ('KE', 'default', '2430', 'Loans from shareholders and directors — non-current', '{}'::jsonb, 'liability_non_current', false, null, 730),
  ('KE', 'default', '2500', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 740),
  ('KE', 'default', '2550', 'Provision for reinstatement costs', '{}'::jsonb, 'liability_non_current', false, null, 750),
  ('KE', 'default', '2990', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 760),
  ('KE', 'default', '3000', 'Share capital', '{}'::jsonb, 'equity', false, null, 770),
  ('KE', 'default', '3010', 'Treasury shares', '{}'::jsonb, 'equity', false, null, 780),
  ('KE', 'default', '3100', 'Other reserves', '{}'::jsonb, 'equity', false, null, 790),
  ('KE', 'default', '3110', 'Foreign currency translation reserve', '{}'::jsonb, 'equity', false, null, 800),
  ('KE', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 810),
  ('KE', 'default', '3210', 'Dividends paid', '{}'::jsonb, 'equity_retained', false, null, 820),
  ('KE', 'default', '4000', 'Sales of goods', '{}'::jsonb, 'income', false, null, 830),
  ('KE', 'default', '4010', 'Services rendered', '{}'::jsonb, 'income', false, null, 840),
  ('KE', 'default', '4020', 'Export sales of goods', '{}'::jsonb, 'income', false, null, 850),
  ('KE', 'default', '4030', 'Export of services', '{}'::jsonb, 'income', false, null, 860),
  ('KE', 'default', '4500', 'Interest income', '{}'::jsonb, 'income_other', false, null, 870),
  ('KE', 'default', '4510', 'Dividend income', '{}'::jsonb, 'income_other', false, null, 880),
  ('KE', 'default', '4520', 'Rental income', '{}'::jsonb, 'income_other', false, null, 890),
  ('KE', 'default', '4530', 'Government grants', '{}'::jsonb, 'income_other', false, null, 900),
  ('KE', 'default', '4700', 'Foreign exchange gains', '{}'::jsonb, 'income_other', false, null, 910),
  ('KE', 'default', '4750', 'Gain on disposal of property plant and equipment', '{}'::jsonb, 'income_other', false, null, 920),
  ('KE', 'default', '4790', 'Other income', '{}'::jsonb, 'income_other', false, null, 930),
  ('KE', 'default', '5000', 'Purchases of goods for resale', '{}'::jsonb, 'expense_direct_cost', false, null, 940),
  ('KE', 'default', '5010', 'Freight inwards and import duties', '{}'::jsonb, 'expense_direct_cost', false, null, 950),
  ('KE', 'default', '5020', 'Subcontract costs', '{}'::jsonb, 'expense_direct_cost', false, null, 960),
  ('KE', 'default', '5100', 'Changes in inventories', '{}'::jsonb, 'expense_direct_cost', false, null, 970),
  ('KE', 'default', '6000', 'Salaries and wages', '{}'::jsonb, 'expense', false, null, 980),
  ('KE', 'default', '6010', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 990),
  ('KE', 'default', '6020', 'Directors'' fees', '{}'::jsonb, 'expense', false, null, 1000),
  ('KE', 'default', '6030', 'NSSF contributions — employer', '{}'::jsonb, 'expense', false, null, 1010),
  ('KE', 'default', '6035', 'SHIF contributions — employer', '{}'::jsonb, 'expense', false, null, 1020),
  ('KE', 'default', '6040', 'NITA training levy', '{}'::jsonb, 'expense', false, null, 1030),
  ('KE', 'default', '6060', 'Staff welfare', '{}'::jsonb, 'expense', false, null, 1040),
  ('KE', 'default', '6070', 'Staff medical expenses and insurance', '{}'::jsonb, 'expense', false, null, 1050),
  ('KE', 'default', '6080', 'Staff training', '{}'::jsonb, 'expense', false, null, 1060),
  ('KE', 'default', '6200', 'Depreciation of property plant and equipment', '{}'::jsonb, 'expense_depreciation', false, null, 1070),
  ('KE', 'default', '6210', 'Depreciation of right-of-use assets', '{}'::jsonb, 'expense_depreciation', false, null, 1080),
  ('KE', 'default', '6220', 'Amortisation of intangible assets', '{}'::jsonb, 'expense_depreciation', false, null, 1090),
  ('KE', 'default', '6300', 'Rent — short-term leases', '{}'::jsonb, 'expense', false, null, 1100),
  ('KE', 'default', '6310', 'Utilities', '{}'::jsonb, 'expense', false, null, 1110),
  ('KE', 'default', '6320', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 1120),
  ('KE', 'default', '6330', 'Cleaning and security services', '{}'::jsonb, 'expense', false, null, 1130),
  ('KE', 'default', '6340', 'Telephone and internet', '{}'::jsonb, 'expense', false, null, 1140),
  ('KE', 'default', '6350', 'Software subscriptions', '{}'::jsonb, 'expense', false, null, 1150),
  ('KE', 'default', '6360', 'Advertising and marketing', '{}'::jsonb, 'expense', false, null, 1160),
  ('KE', 'default', '6370', 'Travelling', '{}'::jsonb, 'expense', false, null, 1170),
  ('KE', 'default', '6380', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1180),
  ('KE', 'default', '6390', 'Entertainment', '{}'::jsonb, 'expense', false, null, 1190),
  ('KE', 'default', '6400', 'Subscriptions and memberships', '{}'::jsonb, 'expense', false, null, 1200),
  ('KE', 'default', '6410', 'Insurance', '{}'::jsonb, 'expense', false, null, 1210),
  ('KE', 'default', '6420', 'Professional fees', '{}'::jsonb, 'expense', false, null, 1220),
  ('KE', 'default', '6430', 'Audit fees', '{}'::jsonb, 'expense', false, null, 1230),
  ('KE', 'default', '6440', 'Company secretarial and registration fees', '{}'::jsonb, 'expense', false, null, 1240),
  ('KE', 'default', '6450', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1250),
  ('KE', 'default', '6460', 'Printing and stationery', '{}'::jsonb, 'expense', false, null, 1260),
  ('KE', 'default', '6470', 'Postage and courier', '{}'::jsonb, 'expense', false, null, 1270),
  ('KE', 'default', '6480', 'Licences permits and county government fees', '{}'::jsonb, 'expense', false, null, 1280),
  ('KE', 'default', '6490', 'Royalties', '{}'::jsonb, 'expense', false, null, 1290),
  ('KE', 'default', '6500', 'Bad debts written off', '{}'::jsonb, 'expense', false, null, 1300),
  ('KE', 'default', '6510', 'Impairment loss on trade receivables', '{}'::jsonb, 'expense', false, null, 1310),
  ('KE', 'default', '6900', 'Donations', '{}'::jsonb, 'expense', false, null, 1320),
  ('KE', 'default', '6950', 'Foreign exchange losses', '{}'::jsonb, 'expense', false, null, 1330),
  ('KE', 'default', '6960', 'Loss on disposal of property plant and equipment', '{}'::jsonb, 'expense', false, null, 1340),
  ('KE', 'default', '6990', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1350),
  ('KE', 'default', '7000', 'Interest on bank loans', '{}'::jsonb, 'expense', false, null, 1360),
  ('KE', 'default', '7010', 'Interest on lease liabilities', '{}'::jsonb, 'expense', false, null, 1370),
  ('KE', 'default', '7020', 'Hire purchase interest', '{}'::jsonb, 'expense', false, null, 1380),
  ('KE', 'default', '7030', 'Interest on loans from related parties and others', '{}'::jsonb, 'expense', false, null, 1390),
  ('KE', 'default', '8000', 'Current income tax expense', '{}'::jsonb, 'expense', false, null, 1400),
  ('KE', 'default', '8010', 'Deferred tax expense', '{}'::jsonb, 'expense', false, null, 1410),
  ('KE', 'default', '8020', 'Under or over provision of income tax in prior years', '{}'::jsonb, 'expense', false, null, 1420)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('KE', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('KE', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('KE', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('KE', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('KE', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('KE', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('KE', 'KE-P-16', 'Purchase, standard rate 16 %, deductible', '{}'::jsonb, 'A local purchase at the general rate, used to make taxable supplies', 'percent', 16, 'purchase', 'domestic', date '2013-09-02', null, 'Value Added Tax Act, s. 17(1) — input tax on a taxable supply to a registered person may be deducted, to the extent the supply was acquired to make taxable supplies, subject to the documentation of s. 17(3); s. 5(2)(b) — the rate. Form VAT 3, Section N, row 7 — Taxable Purchases (General Rate).', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('KE', 'KE-P-16-BL', 'Purchase, standard rate 16 %, input tax disallowed', '{}'::jsonb, 'A passenger car or minibus and its running costs, or entertainment, restaurant and accommodation services bought other than in the ordinary course of a business that provides them', 'percent', 16, 'purchase', 'domestic', date '2013-09-02', null, 'Value Added Tax Act, s. 17(4)(a) — a registered person shall not deduct input tax relating to the acquisition, leasing or hiring of passenger cars or minibuses and their repair and maintenance, unless acquired for resale, leasing or hiring in the ordinary course of a continuous and regular business of dealing in them; s. 17(4)(b) — nor of entertainment, restaurant and accommodation services, with the exceptions that paragraph lists. The disallowed tax is not a claim on Form VAT 3, so it lands on the account of the line and reaches no box.', null, null, 120, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('KE', 'KE-P-EX', 'Purchase, exempt', '{}'::jsonb, 'An insurance premium, or another exempt supply bought for the business', 'percent', 0, 'purchase', 'exempt', date '2013-09-02', null, 'Value Added Tax Act, s. 22(1); First Schedule, Part II, paragraph 2 — insurance and reinsurance services, other than management and related consultancy, actuarial services, and the services of assessors and loss adjusters, are exempt supplies, so there is no VAT to deduct. Form VAT 3, Section N, row 10 — Exempt Purchases.', null, null, 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('KE', 'KE-P-IMP', 'Import of goods, VAT paid at the border', '{}'::jsonb, 'VAT collected by the Commissioner of Customs on importation and claimed as input tax once paid', 'percent', 16, 'purchase', 'import', date '2013-09-02', null, 'Value Added Tax Act, s. 5(1)(b) and (5) — tax on the importation of taxable goods is charged as if it were a duty of customs and becomes due and payable by the importer at the time of importation; s. 14 — the taxable value of imported goods; s. 22(1) and (3)(a) — a person may not take delivery of imported goods from customs control without having paid the tax in full, which the Commissioner of Customs collects at that time; s. 17(1) — the tax so paid is then deductible as input tax. Form VAT 3, Section N, row 7 — Taxable Purchases (General Rate), which the workbook does not further split between local and imported goods. The tax is owed to KRA at the border and not to the supplier, so it waits on 2125 until the import declaration is settled.', null, null, 150, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('KE', 'KE-P-RC-IMPSVC', 'Imported service, self-charged and claimed', '{}'::jsonb, 'A service supplied by a person with no place of business in Kenya, wholly used to make taxable supplies', 'percent', 16, 'purchase', 'foreign_services_received', date '2013-09-02', null, 'Value Added Tax Act, s. 10(1) — a registered person receiving a supply of imported taxable services is deemed to have made a taxable supply to himself; s. 10(2)(b) — where entitled to a full input tax credit, the value of that deemed supply is reduced to zero; s. 10(3) — the output tax on it is payable at the time of the supply. In practice the registered person raises a Self-Assessment payment on iTax and remits the tax directly to KRA rather than through the ordinary output side of Form VAT 3, then claims it back at Section O, row 15 — VAT Claimable on Services Imported into Kenya — so the deemed output liability reaches the ledger but no box, and only the claim does.', null, null, 160, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('KE', 'KE-P-ZR', 'Purchase, zero-rated', '{}'::jsonb, 'A purchase of a good the Second Schedule zero-rates, from a registered supplier', 'percent', 0, 'purchase', 'domestic', date '2013-09-02', null, 'Value Added Tax Act, s. 7(2) — the supply is in all other respects a taxable supply, at a rate of nil, so there is no input tax to deduct. Form VAT 3, Section N, row 9 — Purchases (Zero Rated).', null, null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('KE', 'KE-S-16', 'Sale, standard rate 16 %', '{}'::jsonb, 'The general rate on a taxable supply made in Kenya', 'percent', 16, 'sale', 'domestic', date '2013-09-02', null, 'Value Added Tax Act, s. 5(1)(a) — tax is charged on a taxable supply made by a registered person in Kenya; s. 5(2)(b) — at sixteen per cent of the taxable value in any case other than a zero-rated supply. Form VAT 3, Section M, row 1 — Taxable Sales (General Rate).', null, null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('KE', 'KE-S-EX-FIN', 'Sale, exempt (financial services)', '{}'::jsonb, 'A money-transfer or account-operation service, including agency banking and mobile-money commission', 'percent', 0, 'sale', 'exempt', date '2013-09-02', null, 'Value Added Tax Act, s. 22(1) — an exempt supply is not a taxable supply; First Schedule, Part II, paragraph 1(b) — the issue, transfer, receipt or any other dealing with money, including money transfer services and accepting over-the-counter payments of household bills, excluding the carriage of cash, restocking of cash machines, and sorting or counting of money. Form VAT 3, Section M, row 4 — Sales (Exempt).', null, null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('KE', 'KE-S-EXP-SVC', 'Sale, zero-rated (export of services)', '{}'::jsonb, 'A taxable service supplied to a customer outside Kenya', 'percent', 0, 'sale', 'export', date '2023-07-01', null, 'Value Added Tax Act, s. 7(1) and (2); Second Schedule, Part A, paragraph 23 — the exportation of taxable services, inserted by the Finance Act, 2022 (Act No. 22 of 2022, s. 31(a)) and restated by the Finance Act, 2023 (Act No. 4 of 2023, s. 38(a)(ii)) in line with the OECD destination principle. Form VAT 3, Section M, row 3 — Sales (Zero Rated).', null, null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('KE', 'KE-S-ZR-DOM', 'Sale, zero-rated (domestic)', '{}'::jsonb, 'A local sale of a good the Second Schedule zero-rates without it leaving Kenya — liquefied petroleum gas', 'percent', 0, 'sale', 'domestic', date '2023-07-01', null, 'Value Added Tax Act, s. 7(1) and (2) — no tax is charged on a supply of a description specified in the Second Schedule, which is in all other respects a taxable supply; Second Schedule, Part A, paragraph 27 — Liquefied Petroleum Gas, inserted by the Finance Act, 2023 (Act No. 4 of 2023, s. 38(a)(iii)). Form VAT 3, Section M, row 3 — Sales (Zero Rated).', null, null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('KE', 'KE-S-ZR-EXP', 'Sale, zero-rated (export of goods)', '{}'::jsonb, 'Goods exported from Kenya', 'percent', 0, 'sale', 'export', date '2013-09-02', null, 'Value Added Tax Act, s. 7(1) and (2); Second Schedule, Part A, paragraph 1 — the exportation of goods. Form VAT 3, Section M, row 3 — Sales (Zero Rated).', null, null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null)
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
    ('KE-P-16', 'invoice', 'base', 100, null, '7', array['7']::text[], 100, 'KE-VAT3', 10),
    ('KE-P-16', 'invoice', 'tax', 100, '1150', '7', array['7']::text[], 100, 'KE-VAT3', 20),
    ('KE-P-16', 'credit_note', 'base', 100, null, '7', array['7']::text[], -100, 'KE-VAT3', 10),
    ('KE-P-16', 'credit_note', 'tax', 100, '1150', '7', array['7']::text[], -100, 'KE-VAT3', 20),
    ('KE-P-16-BL', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('KE-P-16-BL', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('KE-P-16-BL', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('KE-P-16-BL', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('KE-P-EX', 'invoice', 'base', 100, null, '10', array['10']::text[], 100, 'KE-VAT3', 10),
    ('KE-P-EX', 'credit_note', 'base', 100, null, '10', array['10']::text[], -100, 'KE-VAT3', 10),
    ('KE-P-IMP', 'invoice', 'base', 100, null, '7', array['7']::text[], 100, 'KE-VAT3', 10),
    ('KE-P-IMP', 'invoice', 'tax', 100, '1150', '7', array['7']::text[], 100, 'KE-VAT3', 20),
    ('KE-P-IMP', 'invoice', 'tax', -100, '2125', null, null, 100, null, 30),
    ('KE-P-IMP', 'credit_note', 'base', 100, null, '7', array['7']::text[], -100, 'KE-VAT3', 10),
    ('KE-P-IMP', 'credit_note', 'tax', 100, '1150', '7', array['7']::text[], -100, 'KE-VAT3', 20),
    ('KE-P-IMP', 'credit_note', 'tax', -100, '2125', null, null, 100, null, 30),
    ('KE-P-RC-IMPSVC', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('KE-P-RC-IMPSVC', 'invoice', 'tax', 100, '1150', '15', array['15']::text[], 100, 'KE-VAT3', 20),
    ('KE-P-RC-IMPSVC', 'invoice', 'tax', -100, '2100', null, null, 100, null, 30),
    ('KE-P-RC-IMPSVC', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('KE-P-RC-IMPSVC', 'credit_note', 'tax', 100, '1150', '15', array['15']::text[], -100, 'KE-VAT3', 20),
    ('KE-P-RC-IMPSVC', 'credit_note', 'tax', -100, '2100', null, null, 100, null, 30),
    ('KE-P-ZR', 'invoice', 'base', 100, null, '9', array['9']::text[], 100, 'KE-VAT3', 10),
    ('KE-P-ZR', 'credit_note', 'base', 100, null, '9', array['9']::text[], -100, 'KE-VAT3', 10),
    ('KE-S-16', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'KE-VAT3', 10),
    ('KE-S-16', 'invoice', 'tax', 100, '2100', '1', array['1']::text[], 100, 'KE-VAT3', 20),
    ('KE-S-16', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'KE-VAT3', 10),
    ('KE-S-16', 'credit_note', 'tax', 100, '2100', '1', array['1']::text[], -100, 'KE-VAT3', 20),
    ('KE-S-EX-FIN', 'invoice', 'base', 100, null, '4', array['4']::text[], 100, 'KE-VAT3', 10),
    ('KE-S-EX-FIN', 'credit_note', 'base', 100, null, '4', array['4']::text[], -100, 'KE-VAT3', 10),
    ('KE-S-EXP-SVC', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'KE-VAT3', 10),
    ('KE-S-EXP-SVC', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'KE-VAT3', 10),
    ('KE-S-ZR-DOM', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'KE-VAT3', 10),
    ('KE-S-ZR-DOM', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'KE-VAT3', 10),
    ('KE-S-ZR-EXP', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'KE-VAT3', 10),
    ('KE-S-ZR-EXP', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'KE-VAT3', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'KE' and t.code = v.tax_code
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
  ('KE', 'KE-VAT3', 'VAT Monthly Return (form VAT 3)', array['month']::declaration_period[], 'month'::declaration_period, date '2013-09-02', null, 'Value Added Tax Act, s. 2(1) — a "tax period" means one calendar month or such other period as may be prescribed; s. 44(1) — a registered person submits a return for each tax period, in the prescribed form, which is form VAT 3. The workbook lays sales and purchases out in Section M (rows 1 to 6), Section N (rows 7 to 12) and Section O (rows 13 to 28). This pack carries rows 1 to 15 and the final row 20; rows 16 to 18 (an apportionment of input tax between taxable and exempt use, expressed as a ratio of a ratio the pack''s declaration format cannot state as a plus/minus list or a single rate) and rows 21 to 28 (credit brought forward, withheld-VAT credits, payments already made and adjustment vouchers — period-to-period settlement rather than a figure a document posts) are not carried; both gaps are recorded in docs/international.md.', true,'day_of_month_after_period'::filing_deadline_rule, 20, null, 'Value Added Tax Act, s. 44(1) — a return is submitted not later than the twentieth day after the end of the tax period; s. 19(2) — payment may be deferred to the same day. KRA, Value Added Tax (VAT): "VAT is due on or before the 20th day of the following month. This includes both the return and payment."', 'vat-act', null)
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
  ('KE', 'KE-VAT3', '1', 'base', 'Taxable Sales (General Rate) — value', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form VAT 3, Section M, row 1 — the value excluding VAT of sales taxed at the general rate.', 'vat3-form'),
  ('KE', 'KE-VAT3', '1', 'tax', 'Taxable Sales (General Rate) — output VAT', '{}'::jsonb, 15, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form VAT 3, Section M, row 1 — the output VAT column beside the general-rate sales.', 'vat3-form'),
  ('KE', 'KE-VAT3', '2', 'base', 'Taxable Sales (Other Rate) — value', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form VAT 3, Section M, row 2 — sales taxed at a rate the Cabinet Secretary has varied by an order under s. 6(1) of the Value Added Tax Act, published in the Gazette (most recently Legal Notice No. 69 of 2026 and Legal Notice No. 70 of 2026, an 8 % rate on specified petroleum products from 16 April to 14 October 2026). Such an order is administratively varied every few months and reversed as often, which is exactly the kind of rate feed docs/packs.md says does not belong in a pack; this pack carries the row so the form reads as it prints, without a tax code ever posting to it.', 'vat-act'),
  ('KE', 'KE-VAT3', '2', 'tax', 'Taxable Sales (Other Rate) — output VAT', '{}'::jsonb, 25, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form VAT 3, Section M, row 2 — declared and empty, for the reason given at box 2.', 'vat3-form'),
  ('KE', 'KE-VAT3', '3', 'base', 'Sales (Zero Rated)', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form VAT 3, Section M, row 3 — sales zero-rated under s. 7 of the Value Added Tax Act and the Second Schedule, domestic and exported alike.', 'vat3-form'),
  ('KE', 'KE-VAT3', '4', 'base', 'Sales (Exempt)', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form VAT 3, Section M, row 4 — sales exempt under s. 22 of the Value Added Tax Act and the First Schedule.', 'vat3-form'),
  ('KE', 'KE-VAT3', '5', 'total', 'Total Sales', '{}'::jsonb, 50, null, array['1:base', '2:base', '3', '4']::text[], '{}'::text[], null, null, false, false, null, 'Form VAT 3, Section M, row 5 — Total Sales (1+2+3+4).', 'vat3-form'),
  ('KE', 'KE-VAT3', '6', 'total', 'Total Output VAT', '{}'::jsonb, 60, null, array['1:tax', '2:tax']::text[], '{}'::text[], null, null, false, false, null, 'Form VAT 3, Section M, row 6 — Total Output VAT (1+2+3); box 3 contributes nothing, since a zero-rated sale carries no output VAT by definition, so it is left out of the sum without changing the figure.', 'vat3-form'),
  ('KE', 'KE-VAT3', '7', 'base', 'Taxable Purchases (General Rate) — value', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form VAT 3, Section N, row 7 — the value excluding VAT of purchases, local or imported, taxed at the general rate and whose input tax is claimable.', 'vat3-form'),
  ('KE', 'KE-VAT3', '7', 'tax', 'Taxable Purchases (General Rate) — input VAT', '{}'::jsonb, 75, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form VAT 3, Section N, row 7 — the input VAT column beside the general-rate purchases.', 'vat3-form'),
  ('KE', 'KE-VAT3', '8', 'base', 'Taxable Purchases (Other Rate) — value', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form VAT 3, Section N, row 8 — purchases taxed at a rate the Cabinet Secretary has varied under s. 6(1), for the reason given at box 2. Declared and empty.', 'vat-act'),
  ('KE', 'KE-VAT3', '8', 'tax', 'Taxable Purchases (Other Rate) — input VAT', '{}'::jsonb, 85, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form VAT 3, Section N, row 8 — declared and empty, for the reason given at box 2.', 'vat3-form'),
  ('KE', 'KE-VAT3', '9', 'base', 'Purchases (Zero Rated)', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form VAT 3, Section N, row 9 — purchases of a good or service the Second Schedule zero-rates.', 'vat3-form'),
  ('KE', 'KE-VAT3', '10', 'base', 'Exempt Purchases', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form VAT 3, Section N, row 10 — purchases exempt under s. 22 and the First Schedule.', 'vat3-form'),
  ('KE', 'KE-VAT3', '11', 'total', 'Total Purchases', '{}'::jsonb, 110, null, array['7:base', '8:base', '9', '10']::text[], '{}'::text[], null, null, false, false, null, 'Form VAT 3, Section N, row 11 — Total Purchases (7+8+9+10).', 'vat3-form'),
  ('KE', 'KE-VAT3', '12', 'total', 'Total Input VAT', '{}'::jsonb, 120, null, array['7:tax', '8:tax']::text[], '{}'::text[], null, null, false, false, null, 'Form VAT 3, Section N, row 12 — Total Input VAT (7+8+9); box 9 and box 10 carry no input VAT by definition, so they are left out of the sum without changing the figure.', 'vat3-form'),
  ('KE', 'KE-VAT3', '13', 'total', 'Output VAT', '{}'::jsonb, 130, null, array['6']::text[], '{}'::text[], null, null, false, false, null, 'Form VAT 3, Section O, row 13 — Output VAT (6).', 'vat3-form'),
  ('KE', 'KE-VAT3', '14', 'total', 'Input VAT', '{}'::jsonb, 140, null, array['12']::text[], '{}'::text[], null, null, false, false, null, 'Form VAT 3, Section O, row 14 — Input VAT (12).', 'vat3-form'),
  ('KE', 'KE-VAT3', '15', 'tax', 'VAT Claimable on Services Imported into Kenya', '{}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form VAT 3, Section O, row 15, from the detail of Section J — VAT Claimable on Services Imported into Kenya; Value Added Tax Act, s. 10(2).', 'vat3-form'),
  ('KE', 'KE-VAT3', '19', 'total', 'Deductible Input VAT', '{}'::jsonb, 190, null, array['14', '15']::text[], '{}'::text[], null, null, false, false, null, 'Form VAT 3, Section O, row 19 — Deductible Input VAT (14+15-16-18); rows 16 and 18, the apportionment of input tax between taxable and exempt use, are not carried by this pack (see the top-level legal_reference), so this total is the sum of rows 14 and 15 alone — the figure a wholly taxable business files.', 'vat3-form'),
  ('KE', 'KE-VAT3', '20', 'total', 'VAT Payable / Credit Due for the period', '{}'::jsonb, 200, null, array['13']::text[], array['19']::text[], null, null, false, false, null, 'Form VAT 3, Section O, row 20 — VAT Payable / Credit Due for the period (13-19). A positive figure is payable to KRA by the twentieth of the following month (s. 19(2), s. 44(1)); a negative figure is a credit, carried forward under s. 17(5) or refunded within the conditions that subsection sets, which rows 21 to 28 of the workbook track and this pack does not carry.', 'vat3-form')
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
  ('KE-ICPAK-IS', 'KE', 'default', 'Profit and loss account', 'income_statement', 'IFRS-SME', date '2015-09-15', null, 'Companies Act (Cap. 486), s. 638(2)(a)(ii) — an individual financial statement comprises a profit and loss account; s. 638(2)(b)(ii) — it gives a true and fair view of the profit or loss of the company for the financial year. ICPAK''s illustrative statement aggregates expenses by nature, which these lines follow.', 'companies-act-2015'),
  ('KE-ICPAK-SFP', 'KE', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS-SME', date '2015-09-15', null, 'Companies Act (Cap. 486), s. 638(2)(a)(i) — an individual financial statement comprises a balance sheet as at the last day of the financial year; s. 638(2)(b)(i) — it gives a true and fair view of the financial position of the company; s. 638(2)(c) — it complies with the prescribed financial accounting standards as to form and content. ICPAK has adopted the IFRS for SMEs Accounting Standard for an entity with no public accountability; the lines below follow ICPAK''s own illustrative statement, section 4 of that standard.', 'companies-act-2015')
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
  ('KE-ICPAK-IS', '1', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-IS', '2', null, 'Other income', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-IS', '3', null, 'Purchases and changes in inventories', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-IS', '4', null, 'Employee benefits expense', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-IS', '5', null, 'Depreciation and amortisation', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-IS', '6', null, 'Other operating expenses', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-IS', '7', null, 'Finance costs', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-IS', '8', null, 'Profit before tax', '{}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('KE-ICPAK-IS', '9', null, 'Income tax expense', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-IS', '10', null, 'Profit for the year', '{}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, null, null),
  ('KE-ICPAK-SFP', 'CA', null, 'Current assets', '{}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5', 'CA.6']::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'CA.1', null, 'Cash and cash equivalents', '{}'::jsonb, 11, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'CA.2', null, 'Trade and other receivables', '{}'::jsonb, 12, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'CA.3', null, 'Inventories', '{}'::jsonb, 13, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'CA.4', null, 'Financial assets', '{}'::jsonb, 14, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'CA.5', null, 'Current tax recoverable', '{}'::jsonb, 15, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'CA.6', null, 'Prepayments and accrued income', '{}'::jsonb, 16, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'NCA', null, 'Non-current assets', '{}'::jsonb, 20, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4', 'NCA.5', 'NCA.6', 'NCA.7']::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'NCA.1', null, 'Property, plant and equipment', '{}'::jsonb, 21, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'NCA.2', null, 'Investment property', '{}'::jsonb, 22, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'NCA.3', null, 'Intangible assets', '{}'::jsonb, 23, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'NCA.4', null, 'Investments in associates', '{}'::jsonb, 24, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'NCA.5', null, 'Investments in joint ventures', '{}'::jsonb, 25, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'NCA.6', null, 'Financial assets', '{}'::jsonb, 26, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'NCA.7', null, 'Deferred tax assets', '{}'::jsonb, 27, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'TA', null, 'Total assets', '{}'::jsonb, 30, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'CL', null, 'Current liabilities', '{}'::jsonb, 40, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4', 'CL.5']::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'CL.1', null, 'Trade and other payables', '{}'::jsonb, 41, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'CL.2', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 42, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'CL.3', null, 'Amounts due to directors', '{}'::jsonb, 43, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'CL.4', null, 'Current tax payable', '{}'::jsonb, 44, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'CL.5', null, 'Provisions', '{}'::jsonb, 45, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'NCL', null, 'Non-current liabilities', '{}'::jsonb, 50, 1, true, array['NCL.1', 'NCL.2', 'NCL.3']::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'NCL.1', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 51, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'NCL.2', null, 'Deferred tax liabilities', '{}'::jsonb, 52, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'NCL.3', null, 'Provisions', '{}'::jsonb, 53, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'TL', null, 'Total liabilities', '{}'::jsonb, 60, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'NA', null, 'Net assets', '{}'::jsonb, 70, 1, true, array['TA']::text[], array['TL']::text[], null, null, null),
  ('KE-ICPAK-SFP', 'EQ', null, 'Equity', '{}'::jsonb, 80, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'EQ.1', null, 'Share capital', '{}'::jsonb, 81, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'EQ.2', null, 'Other reserves', '{}'::jsonb, 82, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KE-ICPAK-SFP', 'EQ.3', null, 'Retained earnings', '{}'::jsonb, 83, -1, false, '{}'::text[], '{}'::text[], null, null, null)
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
    ('KE-ICPAK-IS', '1', 10, 'code_range', '4000', '4030', null, 'any'),
    ('KE-ICPAK-IS', '2', 10, 'code_range', '4500', '4790', null, 'any'),
    ('KE-ICPAK-IS', '3', 10, 'code_range', '5000', '5100', null, 'any'),
    ('KE-ICPAK-IS', '4', 10, 'code_range', '6000', '6080', null, 'any'),
    ('KE-ICPAK-IS', '5', 10, 'code_range', '6200', '6220', null, 'any'),
    ('KE-ICPAK-IS', '6', 10, 'code_range', '6300', '6990', null, 'any'),
    ('KE-ICPAK-IS', '7', 10, 'code_range', '7000', '7030', null, 'any'),
    ('KE-ICPAK-IS', '9', 10, 'code_range', '8000', '8020', null, 'any'),
    ('KE-ICPAK-SFP', 'CA.1', 10, 'code_range', '1000', '1040', null, 'any'),
    ('KE-ICPAK-SFP', 'CA.2', 10, 'code_range', '1100', '1160', null, 'any'),
    ('KE-ICPAK-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('KE-ICPAK-SFP', 'CA.4', 10, 'account_code', '1300', null, null, 'any'),
    ('KE-ICPAK-SFP', 'CA.5', 10, 'account_code', '1350', null, null, 'any'),
    ('KE-ICPAK-SFP', 'CA.6', 10, 'code_range', '1400', '1410', null, 'any'),
    ('KE-ICPAK-SFP', 'NCA.1', 10, 'code_range', '1600', '1671', null, 'any'),
    ('KE-ICPAK-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('KE-ICPAK-SFP', 'NCA.3', 10, 'code_range', '1750', '1760', null, 'any'),
    ('KE-ICPAK-SFP', 'NCA.4', 10, 'account_code', '1800', null, null, 'any'),
    ('KE-ICPAK-SFP', 'NCA.5', 10, 'account_code', '1810', null, null, 'any'),
    ('KE-ICPAK-SFP', 'NCA.6', 10, 'code_range', '1830', '1840', null, 'any'),
    ('KE-ICPAK-SFP', 'NCA.7', 10, 'account_code', '1900', null, null, 'any'),
    ('KE-ICPAK-SFP', 'CL.1', 10, 'code_range', '2000', '2190', null, 'any'),
    ('KE-ICPAK-SFP', 'CL.1', 20, 'account_code', '2990', null, null, 'credit'),
    ('KE-ICPAK-SFP', 'CL.2', 10, 'code_range', '2200', '2240', null, 'any'),
    ('KE-ICPAK-SFP', 'CL.3', 10, 'account_code', '2250', null, null, 'any'),
    ('KE-ICPAK-SFP', 'CL.4', 10, 'account_code', '2300', null, null, 'any'),
    ('KE-ICPAK-SFP', 'CL.5', 10, 'code_range', '2350', '2360', null, 'any'),
    ('KE-ICPAK-SFP', 'NCL.1', 10, 'code_range', '2400', '2430', null, 'any'),
    ('KE-ICPAK-SFP', 'NCL.2', 10, 'account_code', '2500', null, null, 'any'),
    ('KE-ICPAK-SFP', 'NCL.3', 10, 'account_code', '2550', null, null, 'any'),
    ('KE-ICPAK-SFP', 'EQ.1', 10, 'code_range', '3000', '3010', null, 'any'),
    ('KE-ICPAK-SFP', 'EQ.2', 10, 'code_range', '3100', '3110', null, 'any'),
    ('KE-ICPAK-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('KE', 'Kenya', '{}'::jsonb, array['en']::text[], 'KES', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, 'month'::declaration_period)
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
  numbering_legal_reference     = 'Tax Procedures Act, s. 23A(2A)(d) — an electronic tax invoice states the serial number of the invoice; the section asks that each invoice be identified, and not that the series carry no gap, which is why the style is `sequential`. Value Added Tax Act, s. 42(1) requires a tax invoice with the prescribed details at the time of every taxable supply.',
  numbering_source_key          = 'tpa',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Value Added Tax Act, s. 12(1) — subject to subsection (3), the time of supply, including a supply of imported services, is the EARLIEST of: (a) the date the goods are delivered or the services performed; (b) the date a supervising architect, surveyor or consultant issues a certificate; (c) the date the invoice for the supply is issued; or (d) the date payment is received, in whole or in part. This is a four-way earliest-of test and Ekwo''s closed vocabulary only expresses a two-way one; `earliest_of_delivery_or_payment` is the nearest value, and the gap — an invoice issued, or a consultant''s certificate, ahead of both delivery and payment, which would fix the tax point in Kenya but not in Ekwo''s own reading of this word — is recorded in docs/international.md. Section 19(1) then makes the tax due and payable at the time of that supply.',
  tax_point_source_key          = 'vat-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No Kenyan statute obliges a business to exchange a structured electronic invoice with another business, or to accept one, in the sense Ekwo''s vocabulary gives the word — there is no Kenyan Peppol authority, no published profile and no ISO 6523 scheme a party is addressed by, so `profile`, `party_scheme` and `vat_scheme` are all null and `obligation` is `none`. What Kenya has instead is eTIMS, a clearance system: Tax Procedures Act, s. 23A(1) lets the Commissioner establish an electronic system for the issue of tax invoices and the keeping of stock records; s. 23A(2), as amended by the Finance Act, 2023 (Act No. 4 of 2023, s. 52) and the Tax Laws (Amendment) Act, 2024 (Act No. 21 of 2024, s. 3), requires every person carrying on business to issue an electronic tax invoice through that system and to maintain its stock records in it; s. 23A(2A) lists the fields such an invoice carries; s. 23A(3A) excuses the purchaser from a small business or small-scale farmer under KES 5,000,000 of annual turnover from generating one themselves. The Value Added Tax (Electronic Tax Invoice) Regulations, 2020 (Legal Notice No. 189 of 2020) rolled the requirement out to VAT-registered persons from 1 August 2021; the Finance Act, 2023 extended it to every business from 1 September 2023 and, from 1 January 2024, disallows an expense for income tax purposes when it is not backed by an eTIMS invoice. This is a real-time validation of an invoice already issued to a Kenyan buyer or kept on the seller''s own stock records — a clearance with the tax administration through an ETR device, the OSCU or VSCU software, or the free eTIMS Lite web and USSD channels — and not a peer-to-peer exchange of a structured document between two businesses in the sense `einvoicing.profile` describes; the gap is recorded in docs/international.md and in this pack''s README, and the socle is not patched to fit it.',
  einvoice_source_key           = 'tpa',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'KE';
