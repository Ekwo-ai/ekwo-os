-- Ekwo OS — Uganda: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/ug at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build ug`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Value Added Tax Act, Chapter 349, revised and consolidated by the Law Reform Commission of Uganda, as researched and applied by Laws.Africa for the Uganda Legal Information Institute (Uganda Legal Information Institute (ULII) / Laws.Africa)
--     https://ulii.org/akn/ug/act/statute/1996/8
--   Tax Procedures Code Act, Chapter 343, s. 92 — electronic receipting and electronic invoicing (Uganda Legal Information Institute (ULII) / Laws.Africa)
--     https://ulii.org/akn/ug/act/2014/14
--   Companies Act, 2012 (Act 1 of 2012), Chapter 106, ss. 150 and 152 — books of accounts and the true and fair view a balance sheet and profit and loss account must give (Uganda Legal Information Institute (ULII) / Laws.Africa)
--     https://ulii.org/akn/ug/act/2012/1
--   Information paper on the adoption and publication of IFRS, ISA, IFRS for SMEs and IPSAS in Uganda (Institute of Certified Public Accountants of Uganda (ICPAU))
--     https://www.icpau.co.ug/sites/default/files/Resources/INFORMATION%20PAPER%20ON%20ADOPTION%20AND%20PUBLICATION%20OF%20STANDARDS%20IN%20UGANDA.pdf
--   A Simplified Guide — Value Added Tax: the standard rate, zero-rated and exempt supplies, registration, filing and EFRIS (Uganda Revenue Authority (The Taxman))
--     https://thetaxman.ura.go.ug/?p=2193
--   Form DT-2031 — Monthly Value Added Tax Return (revision 07/2018) (Uganda Revenue Authority)
--     https://ura.go.ug/en/download/dt-2031-monthly-vat-return-form/
--   e-Tax — where the monthly VAT return, form DT-2031, is filed (Uganda Revenue Authority)
--     https://etax.ura.go.ug/
--   EFRIS — the Electronic Fiscal Receipting and Invoicing Solution of s. 92 of the Tax Procedures Code Act (Uganda Revenue Authority)
--     https://ura.go.ug/en/efris/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('UG', 'Uganda', '0.1.0', date '2026-09-26', '20260923110000', 'community', null, null, 'bb02a1ae2f1ecef35ceb10d84724ad98be953917af167b359ef347d3aed25a5f', '[{"key":"vat-act","title":"Value Added Tax Act, Chapter 349, revised and consolidated by the Law Reform Commission of Uganda, as researched and applied by Laws.Africa for the Uganda Legal Information Institute","publisher":"Uganda Legal Information Institute (ULII) / Laws.Africa","url":"https://ulii.org/akn/ug/act/statute/1996/8","consulted_on":"2026-09-26","kind":"law"},{"key":"tpca","title":"Tax Procedures Code Act, Chapter 343, s. 92 — electronic receipting and electronic invoicing","publisher":"Uganda Legal Information Institute (ULII) / Laws.Africa","url":"https://ulii.org/akn/ug/act/2014/14","consulted_on":"2026-09-26","kind":"law"},{"key":"companies-act-2012","title":"Companies Act, 2012 (Act 1 of 2012), Chapter 106, ss. 150 and 152 — books of accounts and the true and fair view a balance sheet and profit and loss account must give","publisher":"Uganda Legal Information Institute (ULII) / Laws.Africa","url":"https://ulii.org/akn/ug/act/2012/1","consulted_on":"2026-09-26","kind":"law"},{"key":"icpau-ifrs-sme","title":"Information paper on the adoption and publication of IFRS, ISA, IFRS for SMEs and IPSAS in Uganda","publisher":"Institute of Certified Public Accountants of Uganda (ICPAU)","url":"https://www.icpau.co.ug/sites/default/files/Resources/INFORMATION%20PAPER%20ON%20ADOPTION%20AND%20PUBLICATION%20OF%20STANDARDS%20IN%20UGANDA.pdf","consulted_on":"2026-09-26","kind":"guidance"},{"key":"ura-vat-guide","title":"A Simplified Guide — Value Added Tax: the standard rate, zero-rated and exempt supplies, registration, filing and EFRIS","publisher":"Uganda Revenue Authority (The Taxman)","url":"https://thetaxman.ura.go.ug/?p=2193","consulted_on":"2026-09-26","kind":"guidance"},{"key":"dt-2031-form","title":"Form DT-2031 — Monthly Value Added Tax Return (revision 07/2018)","publisher":"Uganda Revenue Authority","url":"https://ura.go.ug/en/download/dt-2031-monthly-vat-return-form/","consulted_on":"2026-09-26","kind":"form"},{"key":"etax","title":"e-Tax — where the monthly VAT return, form DT-2031, is filed","publisher":"Uganda Revenue Authority","url":"https://etax.ura.go.ug/","consulted_on":"2026-09-26","kind":"portal"},{"key":"efris","title":"EFRIS — the Electronic Fiscal Receipting and Invoicing Solution of s. 92 of the Tax Procedures Code Act","publisher":"Uganda Revenue Authority","url":"https://ura.go.ug/en/efris/","consulted_on":"2026-09-26","kind":"portal"}]'::jsonb)
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
  ('UG', 'default', 'Uganda reference chart of accounts', '{}'::jsonb, true, 'companies', array['UG-ICPAU-IS', 'UG-ICPAU-SFP']::text[], null, 'There is no legal chart of accounts in Uganda. Companies Act, 2012 (Act 1 of 2012), s. 150(1) requires every company to keep proper books of accounts with respect to money received and expended, sales and purchases, and assets and liabilities, of a kind necessary to give a true and fair view of the company''s affairs; s. 152(1) requires the balance sheet and the profit and loss account themselves to give that true and fair view. The Institute of Certified Public Accountants of Uganda, the standard-setting body the Accountants Act, 2013 recognises, has applied the IFRS Accounting Standards without modification since 1998 and has adopted the IFRS for SMEs Accounting Standard for an entity with no public accountability. This chart is original: four digits, blocked so that each range reaches one line of the IFRS for SMEs statements below, with the accounts a Ugandan company actually keeps — VAT input and output tax, import VAT owed to URA at the border, NSSF contributions, withholding tax and local service tax payable, VAT withheld by an appointed agent, and amounts due to directors.', 'companies-act-2012')
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
  ('UG', 'default', '1000', 'Petty cash', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('UG', 'default', '1010', 'Current account — UGX', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('UG', 'default', '1020', 'Fixed deposits placed for three months or less', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('UG', 'default', '1030', 'Foreign currency account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('UG', 'default', '1040', 'Cash in transit — mobile money settlements', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('UG', 'default', '1100', 'Trade receivables', '{}'::jsonb, 'asset_receivable', true, null, 60),
  ('UG', 'default', '1110', 'Trade receivables — allowance for impairment', '{}'::jsonb, 'asset_current', false, null, 70),
  ('UG', 'default', '1120', 'Other receivables', '{}'::jsonb, 'asset_current', false, null, 80),
  ('UG', 'default', '1130', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 90),
  ('UG', 'default', '1140', 'Deposits paid', '{}'::jsonb, 'asset_current', false, null, 100),
  ('UG', 'default', '1150', 'VAT input tax', '{}'::jsonb, 'asset_current', false, null, 110),
  ('UG', 'default', '1155', 'VAT refundable by URA — net of a filed return', '{}'::jsonb, 'asset_current', true, null, 120),
  ('UG', 'default', '1160', 'Advances to staff', '{}'::jsonb, 'asset_current', false, null, 130),
  ('UG', 'default', '1200', 'Inventories — goods for resale', '{}'::jsonb, 'asset_current', false, null, 140),
  ('UG', 'default', '1210', 'Inventories — raw materials', '{}'::jsonb, 'asset_current', false, null, 150),
  ('UG', 'default', '1220', 'Inventories — work in progress', '{}'::jsonb, 'asset_current', false, null, 160),
  ('UG', 'default', '1230', 'Inventories — finished goods', '{}'::jsonb, 'asset_current', false, null, 170),
  ('UG', 'default', '1300', 'Short-term investments', '{}'::jsonb, 'asset_current', false, null, 180),
  ('UG', 'default', '1350', 'Current tax recoverable', '{}'::jsonb, 'asset_current', false, null, 190),
  ('UG', 'default', '1400', 'Prepayments', '{}'::jsonb, 'asset_prepayments', false, null, 200),
  ('UG', 'default', '1410', 'Accrued income', '{}'::jsonb, 'asset_prepayments', false, null, 210),
  ('UG', 'default', '1600', 'Land and buildings — cost', '{}'::jsonb, 'asset_fixed', false, null, 220),
  ('UG', 'default', '1601', 'Land and buildings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 230),
  ('UG', 'default', '1610', 'Leasehold improvements — cost', '{}'::jsonb, 'asset_fixed', false, null, 240),
  ('UG', 'default', '1611', 'Leasehold improvements — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 250),
  ('UG', 'default', '1620', 'Plant and machinery — cost', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('UG', 'default', '1621', 'Plant and machinery — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('UG', 'default', '1630', 'Office equipment — cost', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('UG', 'default', '1631', 'Office equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('UG', 'default', '1640', 'Computers — cost', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('UG', 'default', '1641', 'Computers — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('UG', 'default', '1650', 'Furniture and fittings — cost', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('UG', 'default', '1651', 'Furniture and fittings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('UG', 'default', '1660', 'Motor vehicles — cost', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('UG', 'default', '1661', 'Motor vehicles — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('UG', 'default', '1670', 'Right-of-use assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('UG', 'default', '1671', 'Right-of-use assets — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('UG', 'default', '1700', 'Investment property', '{}'::jsonb, 'asset_non_current', false, null, 380),
  ('UG', 'default', '1750', 'Intangible assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 390),
  ('UG', 'default', '1751', 'Intangible assets — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 400),
  ('UG', 'default', '1760', 'Goodwill', '{}'::jsonb, 'asset_fixed', false, null, 410),
  ('UG', 'default', '1800', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('UG', 'default', '1810', 'Investments in joint ventures', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('UG', 'default', '1830', 'Long-term financial assets', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('UG', 'default', '1840', 'Long-term deposits', '{}'::jsonb, 'asset_non_current', false, null, 450),
  ('UG', 'default', '1900', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('UG', 'default', '2000', 'Trade payables', '{}'::jsonb, 'liability_payable', true, null, 470),
  ('UG', 'default', '2010', 'Accrued expenses', '{}'::jsonb, 'liability_current', false, null, 480),
  ('UG', 'default', '2020', 'Other payables', '{}'::jsonb, 'liability_current', false, null, 490),
  ('UG', 'default', '2030', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 500),
  ('UG', 'default', '2040', 'Deposits received from customers', '{}'::jsonb, 'liability_current', false, null, 510),
  ('UG', 'default', '2100', 'VAT output tax', '{}'::jsonb, 'liability_current', false, null, 520),
  ('UG', 'default', '2110', 'VAT payable to URA — net of a filed return', '{}'::jsonb, 'liability_current', true, null, 530),
  ('UG', 'default', '2125', 'Import VAT payable to URA at the border', '{}'::jsonb, 'liability_current', false, null, 540),
  ('UG', 'default', '2140', 'Withholding tax payable to URA', '{}'::jsonb, 'liability_current', false, null, 550),
  ('UG', 'default', '2150', 'NSSF contributions payable', '{}'::jsonb, 'liability_current', false, null, 560),
  ('UG', 'default', '2155', 'VAT withheld by an appointed agent, payable to URA', '{}'::jsonb, 'liability_current', false, null, 570),
  ('UG', 'default', '2160', 'Local service tax payable', '{}'::jsonb, 'liability_current', false, null, 580),
  ('UG', 'default', '2180', 'Salaries payable', '{}'::jsonb, 'liability_current', false, null, 590),
  ('UG', 'default', '2190', 'Directors'' fees payable', '{}'::jsonb, 'liability_current', false, null, 600),
  ('UG', 'default', '2200', 'Bank overdraft', '{}'::jsonb, 'liability_current', false, null, 610),
  ('UG', 'default', '2210', 'Bank loans — current portion', '{}'::jsonb, 'liability_current', false, null, 620),
  ('UG', 'default', '2220', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 630),
  ('UG', 'default', '2230', 'Hire purchase — current portion', '{}'::jsonb, 'liability_current', false, null, 640),
  ('UG', 'default', '2240', 'Corporate credit card', '{}'::jsonb, 'liability_credit_card', false, null, 650),
  ('UG', 'default', '2250', 'Amounts due to directors', '{}'::jsonb, 'liability_current', false, null, 660),
  ('UG', 'default', '2300', 'Current tax payable', '{}'::jsonb, 'liability_current', false, null, 670),
  ('UG', 'default', '2350', 'Provision for unutilised leave', '{}'::jsonb, 'liability_current', false, null, 680),
  ('UG', 'default', '2360', 'Other provisions — current', '{}'::jsonb, 'liability_current', false, null, 690),
  ('UG', 'default', '2400', 'Bank loans — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 700),
  ('UG', 'default', '2410', 'Lease liabilities — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 710),
  ('UG', 'default', '2420', 'Hire purchase — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 720),
  ('UG', 'default', '2430', 'Loans from shareholders and directors — non-current', '{}'::jsonb, 'liability_non_current', false, null, 730),
  ('UG', 'default', '2500', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 740),
  ('UG', 'default', '2550', 'Provision for reinstatement costs', '{}'::jsonb, 'liability_non_current', false, null, 750),
  ('UG', 'default', '2990', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 760),
  ('UG', 'default', '3000', 'Share capital', '{}'::jsonb, 'equity', false, null, 770),
  ('UG', 'default', '3010', 'Treasury shares', '{}'::jsonb, 'equity', false, null, 780),
  ('UG', 'default', '3100', 'Other reserves', '{}'::jsonb, 'equity', false, null, 790),
  ('UG', 'default', '3110', 'Foreign currency translation reserve', '{}'::jsonb, 'equity', false, null, 800),
  ('UG', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 810),
  ('UG', 'default', '3210', 'Dividends paid', '{}'::jsonb, 'equity_retained', false, null, 820),
  ('UG', 'default', '4000', 'Sales of goods', '{}'::jsonb, 'income', false, null, 830),
  ('UG', 'default', '4010', 'Services rendered', '{}'::jsonb, 'income', false, null, 840),
  ('UG', 'default', '4020', 'Export sales of goods', '{}'::jsonb, 'income', false, null, 850),
  ('UG', 'default', '4030', 'Export of services', '{}'::jsonb, 'income', false, null, 860),
  ('UG', 'default', '4500', 'Interest income', '{}'::jsonb, 'income_other', false, null, 870),
  ('UG', 'default', '4510', 'Dividend income', '{}'::jsonb, 'income_other', false, null, 880),
  ('UG', 'default', '4520', 'Rental income — residential lease', '{}'::jsonb, 'income_other', false, null, 890),
  ('UG', 'default', '4530', 'Government grants', '{}'::jsonb, 'income_other', false, null, 900),
  ('UG', 'default', '4700', 'Foreign exchange gains', '{}'::jsonb, 'income_other', false, null, 910),
  ('UG', 'default', '4750', 'Gain on disposal of property plant and equipment', '{}'::jsonb, 'income_other', false, null, 920),
  ('UG', 'default', '4790', 'Other income', '{}'::jsonb, 'income_other', false, null, 930),
  ('UG', 'default', '5000', 'Purchases of goods for resale', '{}'::jsonb, 'expense_direct_cost', false, null, 940),
  ('UG', 'default', '5010', 'Freight inwards and import duties', '{}'::jsonb, 'expense_direct_cost', false, null, 950),
  ('UG', 'default', '5020', 'Subcontract costs', '{}'::jsonb, 'expense_direct_cost', false, null, 960),
  ('UG', 'default', '5100', 'Changes in inventories', '{}'::jsonb, 'expense_direct_cost', false, null, 970),
  ('UG', 'default', '6000', 'Salaries and wages', '{}'::jsonb, 'expense', false, null, 980),
  ('UG', 'default', '6010', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 990),
  ('UG', 'default', '6020', 'Directors'' fees', '{}'::jsonb, 'expense', false, null, 1000),
  ('UG', 'default', '6030', 'NSSF contributions — employer', '{}'::jsonb, 'expense', false, null, 1010),
  ('UG', 'default', '6060', 'Staff welfare', '{}'::jsonb, 'expense', false, null, 1040),
  ('UG', 'default', '6070', 'Staff medical expenses and insurance', '{}'::jsonb, 'expense', false, null, 1050),
  ('UG', 'default', '6080', 'Staff training', '{}'::jsonb, 'expense', false, null, 1060),
  ('UG', 'default', '6200', 'Depreciation of property plant and equipment', '{}'::jsonb, 'expense_depreciation', false, null, 1070),
  ('UG', 'default', '6210', 'Depreciation of right-of-use assets', '{}'::jsonb, 'expense_depreciation', false, null, 1080),
  ('UG', 'default', '6220', 'Amortisation of intangible assets', '{}'::jsonb, 'expense_depreciation', false, null, 1090),
  ('UG', 'default', '6300', 'Rent — short-term leases', '{}'::jsonb, 'expense', false, null, 1100),
  ('UG', 'default', '6310', 'Utilities', '{}'::jsonb, 'expense', false, null, 1110),
  ('UG', 'default', '6320', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 1120),
  ('UG', 'default', '6330', 'Cleaning and security services', '{}'::jsonb, 'expense', false, null, 1130),
  ('UG', 'default', '6340', 'Telephone and internet', '{}'::jsonb, 'expense', false, null, 1140),
  ('UG', 'default', '6350', 'Software subscriptions', '{}'::jsonb, 'expense', false, null, 1150),
  ('UG', 'default', '6360', 'Advertising and marketing', '{}'::jsonb, 'expense', false, null, 1160),
  ('UG', 'default', '6370', 'Travelling', '{}'::jsonb, 'expense', false, null, 1170),
  ('UG', 'default', '6380', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1180),
  ('UG', 'default', '6390', 'Entertainment', '{}'::jsonb, 'expense', false, null, 1190),
  ('UG', 'default', '6400', 'Subscriptions and memberships', '{}'::jsonb, 'expense', false, null, 1200),
  ('UG', 'default', '6410', 'Insurance', '{}'::jsonb, 'expense', false, null, 1210),
  ('UG', 'default', '6420', 'Professional fees', '{}'::jsonb, 'expense', false, null, 1220),
  ('UG', 'default', '6430', 'Audit fees', '{}'::jsonb, 'expense', false, null, 1230),
  ('UG', 'default', '6440', 'Company secretarial and registration fees', '{}'::jsonb, 'expense', false, null, 1240),
  ('UG', 'default', '6450', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1250),
  ('UG', 'default', '6460', 'Printing and stationery', '{}'::jsonb, 'expense', false, null, 1260),
  ('UG', 'default', '6470', 'Postage and courier', '{}'::jsonb, 'expense', false, null, 1270),
  ('UG', 'default', '6480', 'Licences permits and local government fees', '{}'::jsonb, 'expense', false, null, 1280),
  ('UG', 'default', '6490', 'Royalties', '{}'::jsonb, 'expense', false, null, 1290),
  ('UG', 'default', '6500', 'Bad debts written off', '{}'::jsonb, 'expense', false, null, 1300),
  ('UG', 'default', '6510', 'Impairment loss on trade receivables', '{}'::jsonb, 'expense', false, null, 1310),
  ('UG', 'default', '6900', 'Donations', '{}'::jsonb, 'expense', false, null, 1320),
  ('UG', 'default', '6950', 'Foreign exchange losses', '{}'::jsonb, 'expense', false, null, 1330),
  ('UG', 'default', '6960', 'Loss on disposal of property plant and equipment', '{}'::jsonb, 'expense', false, null, 1340),
  ('UG', 'default', '6990', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1350),
  ('UG', 'default', '7000', 'Interest on bank loans', '{}'::jsonb, 'expense', false, null, 1360),
  ('UG', 'default', '7010', 'Interest on lease liabilities', '{}'::jsonb, 'expense', false, null, 1370),
  ('UG', 'default', '7020', 'Hire purchase interest', '{}'::jsonb, 'expense', false, null, 1380),
  ('UG', 'default', '7030', 'Interest on loans from related parties and others', '{}'::jsonb, 'expense', false, null, 1390),
  ('UG', 'default', '8000', 'Current income tax expense', '{}'::jsonb, 'expense', false, null, 1400),
  ('UG', 'default', '8010', 'Deferred tax expense', '{}'::jsonb, 'expense', false, null, 1410),
  ('UG', 'default', '8020', 'Under or over provision of income tax in prior years', '{}'::jsonb, 'expense', false, null, 1420)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('UG', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('UG', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('UG', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('UG', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('UG', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('UG', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('UG', 'UG-P-18', 'Purchase, standard rate 18 %, deductible', '{}'::jsonb, 'A local purchase at the general rate, used in the business of the taxable person', 'percent', 18, 'purchase', 'domestic', date '2005-07-01', null, 'Value Added Tax Act, s. 28(1) — a credit is allowed for the tax payable in respect of a taxable supply made to the taxable person during the tax period, if the supply is for use in the business of the taxable person; s. 28(11) — the credit may not be claimed until the tax period in which the person holds an original tax invoice. Form DT-2031, Section D, row 13 — Standard Rated Purchases Local, VAT Incurred.', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('UG', 'UG-P-EX', 'Purchase, exempt (insurance)', '{}'::jsonb, 'An insurance premium, or another exempt supply bought for the business', 'percent', 0, 'purchase', 'exempt', date '1996-07-01', null, 'Value Added Tax Act, s. 19(1); Second Schedule, paragraph 1(d) — the supply of insurance services is an exempt supply, so there is no VAT to deduct. Form DT-2031 carries no box for an exempt purchase: unlike the sales side (row 3), the purchase side of the form only lists the rated and zero-rated rows a credit could be claimed on, so this base is not printed anywhere.', null, null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('UG', 'UG-P-IMP', 'Import of goods, VAT paid at the border', '{}'::jsonb, 'VAT charged on the importation of taxable goods, paid to the Commissioner of Customs and claimed as input tax once paid', 'percent', 18, 'purchase', 'import', date '2005-07-01', null, 'Value Added Tax Act, s. 4(b) — tax is charged on every import of goods other than an exempt import; s. 5(b) — the importer pays it; s. 17 — an import of goods takes place where customs duty is payable, or otherwise when the goods are brought into Uganda; s. 23 — the taxable value of an import is the customs value plus duty and other fiscal charges; s. 28(1) — the tax so paid is deductible as input tax once the person holds the bill of entry required by s. 28(11)(b). Form DT-2031, Section D, row 15 — Standard Rated Imports (Goods), VAT Incurred. The tax is owed to URA at the border and not to the supplier, so it waits on 2125 until the import declaration is settled.', null, null, 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('UG', 'UG-P-RC-SVC', 'Imported service, self-charged and claimed', '{}'::jsonb, 'A service supplied by a person from outside Uganda, taxed to the recipient and claimed where used to make taxable supplies', 'percent', 18, 'purchase', 'foreign_services_received', date '2005-07-01', null, 'Value Added Tax Act, s. 4(c) — tax is charged on the supply of any imported services by any person; s. 5(c) — the tax is paid by the recipient of the imported services; s. 28(1) — a credit is allowed for that tax where the service is for use in the business of the taxable person. Form DT-2031, Section C, row 9(i) — Adjustments to Output tax, Imported Services, and Section D, row 21(i) — Adjustment of input tax, Imported Services: the return carries the self-charge as an output adjustment and, in the same period, its claim as an input adjustment, rather than folding it into the ordinary rows of standard-rated sales or purchases.', null, null, 150, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('UG', 'UG-P-Z', 'Purchase, zero-rated (local — drugs and medicines)', '{}'::jsonb, 'A local purchase of a good the Third Schedule zero-rates, from a registered supplier', 'percent', 0, 'purchase', 'domestic', date '1996-07-01', null, 'Value Added Tax Act, s. 24(4); Third Schedule, paragraph 1(c) — there is no input tax to deduct on a supply taxed at nil. Form DT-2031, Section D, row 11 — Zero Rated Purchases, Local.', null, null, 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('UG', 'UG-S-18', 'Sale, standard rate 18 %', '{}'::jsonb, 'The general rate on a taxable supply made in Uganda', 'percent', 18, 'sale', 'domestic', date '2005-07-01', null, 'Value Added Tax Act, s. 4(a) — tax is charged on every taxable supply in Uganda made by a taxable person; s. 24(1) and (3) — the tax payable on a taxable transaction is the rate applied to the taxable value, the rate being the one specified under section 78(2); s. 78(2) — the Minister may by statutory order specify the rate, exercised by the Value Added Tax (Rate of Tax) Order, 2005 (Statutory Instrument 2005 No. 51), made 8 June 2005 and in force from 1 July 2005, which fixes the rate at eighteen per cent of the taxable value. Form DT-2031, Section C, row 4 — Standard Rated Sales, VAT Charged.', null, null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('UG', 'UG-S-EX', 'Sale, exempt (residential lease)', '{}'::jsonb, 'A lease or letting of immovable property other than commercial premises, hotel or holiday accommodation, a short lease, parking or storage, or a serviced apartment', 'percent', 0, 'sale', 'exempt', date '1996-07-01', null, 'Value Added Tax Act, s. 19(1) — a supply of goods or services is an exempt supply if it is specified in the Second Schedule; Second Schedule, paragraph 1(f) — a supply by way of lease or letting of immovable property, other than a lease or letting of commercial premises, of hotel or holiday accommodation, for a period not exceeding three months, for parking or storing cars or other vehicles, or of a serviced apartment. Form DT-2031, Section C, row 3 — Exempt Local Sales.', null, null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('UG', 'UG-S-Z-DOM', 'Sale, zero-rated (domestic — drugs and medicines)', '{}'::jsonb, 'A local supply of drugs and medicines, a good the Third Schedule zero-rates without it leaving Uganda', 'percent', 0, 'sale', 'domestic', date '1996-07-01', null, 'Value Added Tax Act, s. 24(4); Third Schedule, paragraph 1(c) — the supply of drugs and medicines. Form DT-2031, Section C, row 1 — Zero Rated Sales, Local.', null, null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('UG', 'UG-S-Z-EXP', 'Sale, zero-rated (export)', '{}'::jsonb, 'A supply of goods or services exported from Uganda', 'percent', 0, 'sale', 'export', date '1996-07-01', null, 'Value Added Tax Act, s. 24(4) — the rate of tax imposed on a taxable supply specified in the Third Schedule is zero; Third Schedule, paragraph 1(a) — a supply of goods or services where the goods or services are exported from Uganda as part of the supply; paragraph 2 — goods are treated as exported if delivered to, or made available at, an address outside Uganda as evidenced by documentary proof, and services if supplied for use or consumption outside Uganda as evidenced by documentary proof. Form DT-2031, Section C, row 2 — Zero Rated Sales, Exports.', null, null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null)
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
    ('UG-P-18', 'invoice', 'base', 100, null, '13', array['13']::text[], 100, 'UG-VAT-DT2031', 10),
    ('UG-P-18', 'invoice', 'tax', 100, '1150', '13', array['13']::text[], 100, 'UG-VAT-DT2031', 20),
    ('UG-P-18', 'credit_note', 'base', 100, null, '13', array['13']::text[], -100, 'UG-VAT-DT2031', 10),
    ('UG-P-18', 'credit_note', 'tax', 100, '1150', '13', array['13']::text[], -100, 'UG-VAT-DT2031', 20),
    ('UG-P-EX', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('UG-P-EX', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('UG-P-IMP', 'invoice', 'base', 100, null, '15', array['15']::text[], 100, 'UG-VAT-DT2031', 10),
    ('UG-P-IMP', 'invoice', 'tax', 100, '1150', '15', array['15']::text[], 100, 'UG-VAT-DT2031', 20),
    ('UG-P-IMP', 'invoice', 'tax', -100, '2125', null, null, 100, null, 30),
    ('UG-P-IMP', 'credit_note', 'base', 100, null, '15', array['15']::text[], -100, 'UG-VAT-DT2031', 10),
    ('UG-P-IMP', 'credit_note', 'tax', 100, '1150', '15', array['15']::text[], -100, 'UG-VAT-DT2031', 20),
    ('UG-P-IMP', 'credit_note', 'tax', -100, '2125', null, null, 100, null, 30),
    ('UG-P-RC-SVC', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('UG-P-RC-SVC', 'invoice', 'tax', -100, '2100', '9i', array['9i']::text[], 100, 'UG-VAT-DT2031', 20),
    ('UG-P-RC-SVC', 'invoice', 'tax', 100, '1150', '21i', array['21i']::text[], 100, 'UG-VAT-DT2031', 30),
    ('UG-P-RC-SVC', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('UG-P-RC-SVC', 'credit_note', 'tax', -100, '2100', '9i', array['9i']::text[], -100, 'UG-VAT-DT2031', 20),
    ('UG-P-RC-SVC', 'credit_note', 'tax', 100, '1150', '21i', array['21i']::text[], -100, 'UG-VAT-DT2031', 30),
    ('UG-P-Z', 'invoice', 'base', 100, null, '11', array['11']::text[], 100, 'UG-VAT-DT2031', 10),
    ('UG-P-Z', 'credit_note', 'base', 100, null, '11', array['11']::text[], -100, 'UG-VAT-DT2031', 10),
    ('UG-S-18', 'invoice', 'base', 100, null, '4', array['4']::text[], 100, 'UG-VAT-DT2031', 10),
    ('UG-S-18', 'invoice', 'tax', 100, '2100', '4', array['4']::text[], 100, 'UG-VAT-DT2031', 20),
    ('UG-S-18', 'credit_note', 'base', 100, null, '4', array['4']::text[], -100, 'UG-VAT-DT2031', 10),
    ('UG-S-18', 'credit_note', 'tax', 100, '2100', '4', array['4']::text[], -100, 'UG-VAT-DT2031', 20),
    ('UG-S-EX', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'UG-VAT-DT2031', 10),
    ('UG-S-EX', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'UG-VAT-DT2031', 10),
    ('UG-S-Z-DOM', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'UG-VAT-DT2031', 10),
    ('UG-S-Z-DOM', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'UG-VAT-DT2031', 10),
    ('UG-S-Z-EXP', 'invoice', 'base', 100, null, '2', array['2']::text[], 100, 'UG-VAT-DT2031', 10),
    ('UG-S-Z-EXP', 'credit_note', 'base', 100, null, '2', array['2']::text[], -100, 'UG-VAT-DT2031', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'UG' and t.code = v.tax_code
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
  ('UG', 'UG-VAT-DT2031', 'Monthly Value Added Tax Return (form DT-2031)', array['month']::declaration_period[], 'month'::declaration_period, date '1996-07-01', null, 'Value Added Tax Act, s. 1(1)(v) — "tax period" means the calendar month; s. 31(1) — a taxable person shall lodge a tax return with the Commissioner General for each tax period within fifteen days after the end of the period. Form DT-2031, revision 07/2018, is laid out in Section C — Sales (rows 1 to 10), Section D — Purchases (rows 11 to 22), Section E — for an investment trader only (rows 23 to 28), Section F — the apportionment of input tax credit for a partly exempt business (rows 29 to 33), Section G — VAT withheld payable and creditable, and Section H — the calculation of the tax due. This pack carries the sales and purchases rows every VAT-registered company files (1 to 4, 8, 9(i), 10, 11, 13, 15, 20, 21(i) and 22) and the final net calculation of Section H; the gaps are recorded in this pack''s README and in docs/international.md.', true,'day_of_month_after_period'::filing_deadline_rule, 15, null, 'Value Added Tax Act, s. 31(1) — a taxable person shall lodge a tax return for each tax period within fifteen days after the end of the period; s. 34(1)(a) — the tax payable for that period is due and payable on the date the return must be lodged. Form DT-2031 itself: "To be completed and submitted by the 15th day of the month following the period of return."', 'vat-act', null)
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
  ('UG', 'UG-VAT-DT2031', '1', 'base', 'Zero Rated Sales — Local', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form DT-2031, Section C, row 1 — the value of local sales the Third Schedule zero-rates.', 'dt-2031-form'),
  ('UG', 'UG-VAT-DT2031', '2', 'base', 'Zero Rated Sales — Exports', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form DT-2031, Section C, row 2 — the value of sales the Third Schedule zero-rates as exports.', 'dt-2031-form'),
  ('UG', 'UG-VAT-DT2031', '3', 'base', 'Exempt Local Sales', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form DT-2031, Section C, row 3 — the value of local sales exempt under the Second Schedule.', 'dt-2031-form'),
  ('UG', 'UG-VAT-DT2031', '4', 'base', 'Standard Rated Sales — VAT Charged — value', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form DT-2031, Section C, row 4 — the value exclusive of VAT of sales taxed at the standard rate.', 'dt-2031-form'),
  ('UG', 'UG-VAT-DT2031', '4', 'tax', 'Standard Rated Sales — VAT Charged', '{}'::jsonb, 45, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form DT-2031, Section C, row 4 — the VAT Charged column beside the standard-rated sales.', 'dt-2031-form'),
  ('UG', 'UG-VAT-DT2031', '8', 'total', 'Total Output tax', '{}'::jsonb, 80, null, array['4:tax']::text[], '{}'::text[], null, null, false, false, null, 'Form DT-2031, Section C, row 8 — Total Output tax (4b + 5b + 6b + 7b − 5b − 7b). Rows 5, 6 and 7 (VAT charged and deemed on capital goods sold, and VAT deemed on ordinary sales) are not carried by this pack — see the top-level legal_reference — and the deemed columns the form does carry cancel algebraically in its own formula (+5b−5b, +7b−7b), so the row reduces to 4b alone for the company this pack models.', 'dt-2031-form'),
  ('UG', 'UG-VAT-DT2031', '9i', 'base', 'Adjustments to Output tax — Imported Services — value', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form DT-2031, Section C, row 9(i) — the value of a service imported under section 4(c) of the Value Added Tax Act.', 'dt-2031-form'),
  ('UG', 'UG-VAT-DT2031', '9i', 'tax', 'Adjustments to Output tax — Imported Services', '{}'::jsonb, 95, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form DT-2031, Section C, row 9(i) — the VAT self-charged on an imported service, under Value Added Tax Act, s. 4(c) and s. 5(c).', 'dt-2031-form'),
  ('UG', 'UG-VAT-DT2031', '10', 'total', 'Total Tax Charged for the Period', '{}'::jsonb, 100, null, array['8', '9i:tax']::text[], '{}'::text[], null, null, false, false, null, 'Form DT-2031, Section C, row 10 — Total Tax Charged for the Period (8b + 9(i)b + 9(ii)b + 9(iii)b + 9(iv)b + 9(v)b). Rows 9(ii) to 9(v) (VAT deferred at importation, and tax charges from bad debts recovered, a change of accounting basis or an end-of-year apportionment) are not carried by this pack — see the top-level legal_reference.', 'dt-2031-form'),
  ('UG', 'UG-VAT-DT2031', '11', 'base', 'Zero Rated Purchases — Local', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form DT-2031, Section D, row 11 — the value of local purchases of a good the Third Schedule zero-rates.', 'dt-2031-form'),
  ('UG', 'UG-VAT-DT2031', '13', 'base', 'Standard Rated Purchases Local — VAT Incurred — value', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form DT-2031, Section D, row 13 — the value exclusive of VAT of local purchases taxed at the standard rate and actually invoiced.', 'dt-2031-form'),
  ('UG', 'UG-VAT-DT2031', '13', 'tax', 'Standard Rated Purchases Local — VAT Incurred', '{}'::jsonb, 135, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form DT-2031, Section D, row 13 — the VAT Incurred column beside the standard-rated local purchases.', 'dt-2031-form'),
  ('UG', 'UG-VAT-DT2031', '15', 'base', 'Standard Rated Imports (Goods) — VAT Incurred — value', '{}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form DT-2031, Section D, row 15 — the customs value of imports of goods taxed at the standard rate and actually paid.', 'dt-2031-form'),
  ('UG', 'UG-VAT-DT2031', '15', 'tax', 'Standard Rated Imports (Goods) — VAT Incurred', '{}'::jsonb, 155, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form DT-2031, Section D, row 15 — the VAT Incurred column beside the standard-rated imports.', 'dt-2031-form'),
  ('UG', 'UG-VAT-DT2031', '20', 'total', 'Total Input Tax', '{}'::jsonb, 200, null, array['13:tax', '15:tax']::text[], '{}'::text[], null, null, false, false, null, 'Form DT-2031, Section D, row 20 — Total Input Tax (13b + 14b − 14b + 15b + 16b − 16b + 17b + 18b − 19b − 19b). Rows 14, 16 and 19 (VAT deemed on purchases and capital goods) and rows 17 and 18 (administrative expenses and capital goods bought, carried separately by the form but not modelled by a tax code of their own in this pack) are not carried — see the top-level legal_reference — and the deemed columns the form does carry cancel algebraically in its own formula, so the row reduces to 13b + 15b for the company this pack models.', 'dt-2031-form'),
  ('UG', 'UG-VAT-DT2031', '21i', 'base', 'Adjustment of input tax — Imported Services — value', '{}'::jsonb, 210, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form DT-2031, Section D, row 21(i) — the value of a service imported under section 4(c) of the Value Added Tax Act, claimed as input tax under section 28(1).', 'dt-2031-form'),
  ('UG', 'UG-VAT-DT2031', '21i', 'tax', 'Adjustment of input tax — Imported Services', '{}'::jsonb, 215, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form DT-2031, Section D, row 21(i) — the input tax claimed on an imported service self-charged at row 9(i).', 'dt-2031-form'),
  ('UG', 'UG-VAT-DT2031', '22', 'total', 'Total Input Tax for the Period', '{}'::jsonb, 220, null, array['20', '21i:tax']::text[], '{}'::text[], null, null, false, false, null, 'Form DT-2031, Section D, row 22 — Total Input Tax for the Period (20c + 21(i)c − 21(ii)c + 21(iii)c + 21(iv)c). Rows 21(ii) to 21(iv) (deferred VAT discharged, tax claims from bad debts written off or a change of accounting basis) are not carried by this pack — see the top-level legal_reference.', 'dt-2031-form'),
  ('UG', 'UG-VAT-DT2031', 'NET', 'total', 'Net VAT Due / Claimable', '{}'::jsonb, 300, null, array['10']::text[], array['22']::text[], null, null, false, false, null, 'Form DT-2031, Section H — Calculation of Tax Due: Output tax Charged, less Total Input tax Allowed, gives the Total VAT Payable/Claimable. This pack does not carry the further lines of Section H — an offset brought forward from a previous month and a credit for VAT withheld by an appointed agent — so this total is the figure before either adjustment; both gaps are recorded in this pack''s README. A positive figure is payable by the fifteenth of the following month (s. 31(1), s. 34(1)(a)); a negative figure is a credit a taxable person may offset against a future period or, where it exceeds five million shillings, claim as a cash refund (Section H itself; Value Added Tax Act, s. 42).', 'dt-2031-form')
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
  ('UG-ICPAU-IS', 'UG', 'default', 'Profit and loss account', 'income_statement', 'IFRS-SME', date '2013-01-01', null, 'Companies Act, 2012, s. 152(1) — every profit and loss account of a company shall give a true and fair view of the profit or loss of the company for the financial year. ICPAU''s adoption of the IFRS for SMEs Accounting Standard aggregates expenses by nature, which these lines follow.', 'companies-act-2012'),
  ('UG-ICPAU-SFP', 'UG', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS-SME', date '2013-01-01', null, 'Companies Act, 2012, s. 152(1) — every balance sheet of a company shall give a true and fair view of the state of affairs of the company as at the end of its financial year; s. 152(2) — the balance sheet complies with the requirements of the Fourth Schedule to the Act, so far as applicable. The Institute of Certified Public Accountants of Uganda has adopted the IFRS for SMEs Accounting Standard for an entity with no public accountability; the lines below follow section 4 of that standard.', 'companies-act-2012')
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
  ('UG-ICPAU-IS', '1', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-IS', '2', null, 'Other income', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-IS', '3', null, 'Purchases and changes in inventories', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-IS', '4', null, 'Employee benefits expense', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-IS', '5', null, 'Depreciation and amortisation', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-IS', '6', null, 'Other operating expenses', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-IS', '7', null, 'Finance costs', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-IS', '8', null, 'Profit before tax', '{}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('UG-ICPAU-IS', '9', null, 'Income tax expense', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-IS', '10', null, 'Profit for the year', '{}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, null, null),
  ('UG-ICPAU-SFP', 'CA', null, 'Current assets', '{}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5', 'CA.6']::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'CA.1', null, 'Cash and cash equivalents', '{}'::jsonb, 11, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'CA.2', null, 'Trade and other receivables', '{}'::jsonb, 12, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'CA.3', null, 'Inventories', '{}'::jsonb, 13, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'CA.4', null, 'Financial assets', '{}'::jsonb, 14, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'CA.5', null, 'Current tax recoverable', '{}'::jsonb, 15, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'CA.6', null, 'Prepayments and accrued income', '{}'::jsonb, 16, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'NCA', null, 'Non-current assets', '{}'::jsonb, 20, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4', 'NCA.5', 'NCA.6', 'NCA.7']::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'NCA.1', null, 'Property, plant and equipment', '{}'::jsonb, 21, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'NCA.2', null, 'Investment property', '{}'::jsonb, 22, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'NCA.3', null, 'Intangible assets', '{}'::jsonb, 23, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'NCA.4', null, 'Investments in associates', '{}'::jsonb, 24, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'NCA.5', null, 'Investments in joint ventures', '{}'::jsonb, 25, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'NCA.6', null, 'Financial assets', '{}'::jsonb, 26, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'NCA.7', null, 'Deferred tax assets', '{}'::jsonb, 27, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'TA', null, 'Total assets', '{}'::jsonb, 30, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'CL', null, 'Current liabilities', '{}'::jsonb, 40, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4', 'CL.5']::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'CL.1', null, 'Trade and other payables', '{}'::jsonb, 41, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'CL.2', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 42, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'CL.3', null, 'Amounts due to directors', '{}'::jsonb, 43, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'CL.4', null, 'Current tax payable', '{}'::jsonb, 44, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'CL.5', null, 'Provisions', '{}'::jsonb, 45, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'NCL', null, 'Non-current liabilities', '{}'::jsonb, 50, 1, true, array['NCL.1', 'NCL.2', 'NCL.3']::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'NCL.1', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 51, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'NCL.2', null, 'Deferred tax liabilities', '{}'::jsonb, 52, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'NCL.3', null, 'Provisions', '{}'::jsonb, 53, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'TL', null, 'Total liabilities', '{}'::jsonb, 60, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'NA', null, 'Net assets', '{}'::jsonb, 70, 1, true, array['TA']::text[], array['TL']::text[], null, null, null),
  ('UG-ICPAU-SFP', 'EQ', null, 'Equity', '{}'::jsonb, 80, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'EQ.1', null, 'Share capital', '{}'::jsonb, 81, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'EQ.2', null, 'Other reserves', '{}'::jsonb, 82, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('UG-ICPAU-SFP', 'EQ.3', null, 'Retained earnings', '{}'::jsonb, 83, -1, false, '{}'::text[], '{}'::text[], null, null, null)
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
    ('UG-ICPAU-IS', '1', 10, 'code_range', '4000', '4030', null, 'any'),
    ('UG-ICPAU-IS', '2', 10, 'code_range', '4500', '4790', null, 'any'),
    ('UG-ICPAU-IS', '3', 10, 'code_range', '5000', '5100', null, 'any'),
    ('UG-ICPAU-IS', '4', 10, 'code_range', '6000', '6080', null, 'any'),
    ('UG-ICPAU-IS', '5', 10, 'code_range', '6200', '6220', null, 'any'),
    ('UG-ICPAU-IS', '6', 10, 'code_range', '6300', '6990', null, 'any'),
    ('UG-ICPAU-IS', '7', 10, 'code_range', '7000', '7030', null, 'any'),
    ('UG-ICPAU-IS', '9', 10, 'code_range', '8000', '8020', null, 'any'),
    ('UG-ICPAU-SFP', 'CA.1', 10, 'code_range', '1000', '1040', null, 'any'),
    ('UG-ICPAU-SFP', 'CA.2', 10, 'code_range', '1100', '1160', null, 'any'),
    ('UG-ICPAU-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('UG-ICPAU-SFP', 'CA.4', 10, 'account_code', '1300', null, null, 'any'),
    ('UG-ICPAU-SFP', 'CA.5', 10, 'account_code', '1350', null, null, 'any'),
    ('UG-ICPAU-SFP', 'CA.6', 10, 'code_range', '1400', '1410', null, 'any'),
    ('UG-ICPAU-SFP', 'NCA.1', 10, 'code_range', '1600', '1671', null, 'any'),
    ('UG-ICPAU-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('UG-ICPAU-SFP', 'NCA.3', 10, 'code_range', '1750', '1760', null, 'any'),
    ('UG-ICPAU-SFP', 'NCA.4', 10, 'account_code', '1800', null, null, 'any'),
    ('UG-ICPAU-SFP', 'NCA.5', 10, 'account_code', '1810', null, null, 'any'),
    ('UG-ICPAU-SFP', 'NCA.6', 10, 'code_range', '1830', '1840', null, 'any'),
    ('UG-ICPAU-SFP', 'NCA.7', 10, 'account_code', '1900', null, null, 'any'),
    ('UG-ICPAU-SFP', 'CL.1', 10, 'code_range', '2000', '2190', null, 'any'),
    ('UG-ICPAU-SFP', 'CL.1', 20, 'account_code', '2990', null, null, 'credit'),
    ('UG-ICPAU-SFP', 'CL.2', 10, 'code_range', '2200', '2240', null, 'any'),
    ('UG-ICPAU-SFP', 'CL.3', 10, 'account_code', '2250', null, null, 'any'),
    ('UG-ICPAU-SFP', 'CL.4', 10, 'account_code', '2300', null, null, 'any'),
    ('UG-ICPAU-SFP', 'CL.5', 10, 'code_range', '2350', '2360', null, 'any'),
    ('UG-ICPAU-SFP', 'NCL.1', 10, 'code_range', '2400', '2430', null, 'any'),
    ('UG-ICPAU-SFP', 'NCL.2', 10, 'account_code', '2500', null, null, 'any'),
    ('UG-ICPAU-SFP', 'NCL.3', 10, 'account_code', '2550', null, null, 'any'),
    ('UG-ICPAU-SFP', 'EQ.1', 10, 'code_range', '3000', '3010', null, 'any'),
    ('UG-ICPAU-SFP', 'EQ.2', 10, 'code_range', '3100', '3110', null, 'any'),
    ('UG-ICPAU-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('UG', 'Uganda', '{}'::jsonb, array['en']::text[], 'UGX', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, 'month'::declaration_period)
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
  numbering_legal_reference     = 'Value Added Tax Act, s. 29(1) — a taxable person making a taxable supply to any person shall provide that person, at the time of supply, with an original tax invoice; s. 29(8) — a tax invoice is an invoice containing the particulars specified in section 2 of the Fourth Schedule, which includes an individualised serial number. The Act asks for a serial number identifying each invoice and not for a series with no gap, which is why `numbering` is `sequential` and not `gapless_per_year`.',
  numbering_source_key          = 'vat-act',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Value Added Tax Act, s. 14(1) — except as otherwise provided, a supply of goods or services occurs, in any case other than an own-use application or a gift, on the EARLIEST of the date the goods are delivered or made available or the performance of the service is completed, the date payment is made, or the date a tax invoice is issued. That is a three-way earliest test and Ekwo''s closed vocabulary only expresses a two-way one; `earliest_of_delivery_or_payment` is the nearest value, and the gap — an invoice issued ahead of both delivery and payment, which section 14(1)(c) would still make the tax point but this word would not — is recorded in docs/international.md, as it is for the same three-way rule found in Kenya and Nigeria.',
  tax_point_source_key          = 'vat-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No Ugandan statute obliges a business to exchange a structured electronic invoice with another business, or to accept one, in the sense Ekwo''s vocabulary gives the word — there is no Ugandan Peppol authority, no published profile and no ISO 6523 scheme a party is addressed by, so `profile`, `party_scheme` and `vat_scheme` are all null and `obligation` is `none`. What Uganda has instead is EFRIS, a clearance system: Tax Procedures Code Act, s. 92(1) lets a taxpayer issue an e-invoice or e-receipt, or employ an electronic fiscal device linked to the Uganda Revenue Authority''s own centralised invoicing and receipting system, and s. 92(2) lets the Commissioner General designate, by notice in the Gazette, the taxpayers for whom that becomes mandatory; s. 92(3) then binds a designated taxpayer to issue e-invoices or e-receipts, or use such a device, in every business transaction; s. 93 sets a penal tax for a designated taxpayer who does not. The Commissioner General''s Gazette notice of 23 June 2020 required VAT-registered taxpayers to comply from 1 July 2020, twice extended, first to 1 October 2020 and then, finally, to 1 January 2021; the scope has since been widened by further Gazette notices to businesses outside the VAT register. This is a real-time clearance with the tax administration — the invoice is validated by the centralised system, or generated on a device linked to it, before or as it reaches the buyer — and not a peer-to-peer exchange of a structured document between two businesses in the sense `einvoicing.profile` describes; the gap is recorded in docs/international.md and in this pack''s README, and the socle is not patched to fit it.',
  einvoice_source_key           = 'tpca',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'UG';
