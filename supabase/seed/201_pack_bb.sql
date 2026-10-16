-- Ekwo OS — Barbados: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/bb at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build bb`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Value Added Tax Act, Cap. 87 (consolidated text, L.R.O. 1997 to 2008, as published by the Authority; the amending Acts and Orders listed on the same page are not applied to it) (Barbados Revenue Authority — Laws of Barbados)
--     https://bra.gov.bb/attachment?file=Attachments%2fValue+Added+Tax+Act%2c+Cap.+87.pdf&name=Value+Added+Tax+Act%2c+Cap.87
--   Value Added Tax Regulations, 1996 (Cap. 87A) (Barbados Revenue Authority — Laws of Barbados)
--     https://bra.gov.bb/attachment?file=Attachments%2fValue+Added+Tax+Regulations+Cap.+87%27A.pdf&name=Value+Added+Tax+Regulations+Cap.+87%27A
--   Value Added Tax — VAT rates and threshold (Barbados Revenue Authority)
--     https://bra.gov.bb/Popular-Topics/Value-Added-Tax/VAT-Rates/
--   What are the VAT filing periods? (Barbados Revenue Authority)
--     https://bra.gov.bb/Popular-Topics/Value-Added-Tax/What-are-the-VAT-Filing-Periods/
--   Policy Note: items zero-rated for value added tax from 1 April 2022 (P&F No. 003/2022) (Barbados Revenue Authority)
--     https://bra.gov.bb/News/Policy-Notes/Items-Zero-Rated-for-Value-Added-T
--   Who must register for VAT (Barbados Revenue Authority)
--     https://bra.gov.bb/Popular-Topics/Value-Added-Tax/Who-Must-Register-for-VAT/
--   IFRS for SMEs Accounting Standard (IFRS Foundation / International Accounting Standards Board)
--     https://www.ifrs.org/issued-standards/ifrs-for-smes/
--   Value Added Tax — the Authority's VAT page, filing periods, registration and the online services portal the return is filed through (Barbados Revenue Authority)
--     https://bra.gov.bb/Popular-Topics/Value-Added-Tax/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('BB', 'Barbados', '0.1.0', date '2026-10-17', '20261011120000', 'community', null, null, 'ff01404f976628b4edf70cac2eb248a39c35299cc33086d9cec45319d6787412', '[{"key":"bb-vat-act","title":"Value Added Tax Act, Cap. 87 (consolidated text, L.R.O. 1997 to 2008, as published by the Authority; the amending Acts and Orders listed on the same page are not applied to it)","publisher":"Barbados Revenue Authority — Laws of Barbados","url":"https://bra.gov.bb/attachment?file=Attachments%2fValue+Added+Tax+Act%2c+Cap.+87.pdf&name=Value+Added+Tax+Act%2c+Cap.87","consulted_on":"2026-10-17","kind":"law"},{"key":"bb-vat-regs","title":"Value Added Tax Regulations, 1996 (Cap. 87A)","publisher":"Barbados Revenue Authority — Laws of Barbados","url":"https://bra.gov.bb/attachment?file=Attachments%2fValue+Added+Tax+Regulations+Cap.+87%27A.pdf&name=Value+Added+Tax+Regulations+Cap.+87%27A","consulted_on":"2026-10-17","kind":"regulation"},{"key":"bra-vat-rates","title":"Value Added Tax — VAT rates and threshold","publisher":"Barbados Revenue Authority","url":"https://bra.gov.bb/Popular-Topics/Value-Added-Tax/VAT-Rates/","consulted_on":"2026-10-17","kind":"guidance"},{"key":"bra-filing-periods","title":"What are the VAT filing periods?","publisher":"Barbados Revenue Authority","url":"https://bra.gov.bb/Popular-Topics/Value-Added-Tax/What-are-the-VAT-Filing-Periods/","consulted_on":"2026-10-17","kind":"guidance"},{"key":"bra-zero-rated-2022","title":"Policy Note: items zero-rated for value added tax from 1 April 2022 (P&F No. 003/2022)","publisher":"Barbados Revenue Authority","url":"https://bra.gov.bb/News/Policy-Notes/Items-Zero-Rated-for-Value-Added-T","consulted_on":"2026-10-17","kind":"guidance"},{"key":"bra-who-registers","title":"Who must register for VAT","publisher":"Barbados Revenue Authority","url":"https://bra.gov.bb/Popular-Topics/Value-Added-Tax/Who-Must-Register-for-VAT/","consulted_on":"2026-10-17","kind":"guidance"},{"key":"iasb-ifrs-sme","title":"IFRS for SMEs Accounting Standard","publisher":"IFRS Foundation / International Accounting Standards Board","url":"https://www.ifrs.org/issued-standards/ifrs-for-smes/","consulted_on":"2026-10-17","kind":"standard"},{"key":"bra-vat-portal","title":"Value Added Tax — the Authority''s VAT page, filing periods, registration and the online services portal the return is filed through","publisher":"Barbados Revenue Authority","url":"https://bra.gov.bb/Popular-Topics/Value-Added-Tax/","consulted_on":"2026-10-17","kind":"portal"}]'::jsonb)
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
  ('BB', 'default', 'Barbados reference chart of accounts', '{}'::jsonb, true, 'companies', array['BB-IFRS-SME-IS', 'BB-IFRS-SME-SFP']::text[], null, 'This pack found no legal chart of accounts in Barbados, and opened neither the Companies Act, Cap. 308, nor the Income Tax Act, Cap. 73: no section of either is cited. What the Value Added Tax Act, Cap. 87, s. 75 and the Value Added Tax Regulations, 1996, reg. 7 ask of a person who carries on a taxable activity is that accounts and records be kept, and the Act keeps them for 7 years after the end of the year they relate to. This chart is original: four digits, blocked so that each range reaches one line of a statement of financial position and an income statement presented in the manner of IFRS for SMEs, which is a choice of this pack and not a text the country imposes. The settlement account of the VAT return (2100, refundable 1172) is distinct from the accounts the tax posts to (2101 to 2103 collected, 1170 and 1171 recoverable). See README.md', 'bb-vat-act')
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
  ('BB', 'default', '1000', 'Cash on hand', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('BB', 'default', '1010', 'Bank current account', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('BB', 'default', '1020', 'Bank savings account', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('BB', 'default', '1030', 'Foreign currency bank account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('BB', 'default', '1040', 'Payment gateway and card clearing account', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('BB', 'default', '1050', 'Fixed deposits of three months or less', '{}'::jsonb, 'asset_cash', false, null, 60),
  ('BB', 'default', '1060', 'Cash in transit', '{}'::jsonb, 'asset_cash', false, null, 70),
  ('BB', 'default', '1100', 'Trade debtors', '{}'::jsonb, 'asset_receivable', true, null, 80),
  ('BB', 'default', '1105', 'Allowance for expected credit losses', '{}'::jsonb, 'asset_current', false, null, 90),
  ('BB', 'default', '1110', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 100),
  ('BB', 'default', '1120', 'Other debtors', '{}'::jsonb, 'asset_current', false, null, 110),
  ('BB', 'default', '1130', 'Accrued income', '{}'::jsonb, 'asset_current', false, null, 120),
  ('BB', 'default', '1140', 'Staff advances and loans to employees', '{}'::jsonb, 'asset_current', false, null, 130),
  ('BB', 'default', '1150', 'Customs duty deposits paid', '{}'::jsonb, 'asset_current', false, null, 140),
  ('BB', 'default', '1160', 'Corporation tax recoverable', '{}'::jsonb, 'asset_current', false, null, 150),
  ('BB', 'default', '1170', 'VAT recoverable — local purchases', '{}'::jsonb, 'asset_current', false, null, 160),
  ('BB', 'default', '1171', 'VAT recoverable — imports paid to the Comptroller of Customs', '{}'::jsonb, 'asset_current', false, null, 170),
  ('BB', 'default', '1172', 'VAT refundable — settlement of the return', '{}'::jsonb, 'asset_current', true, null, 180),
  ('BB', 'default', '1200', 'Inventory — raw materials and consumables', '{}'::jsonb, 'asset_current', false, null, 190),
  ('BB', 'default', '1210', 'Inventory — work in progress', '{}'::jsonb, 'asset_current', false, null, 200),
  ('BB', 'default', '1220', 'Inventory — finished goods and goods for resale', '{}'::jsonb, 'asset_current', false, null, 210),
  ('BB', 'default', '1230', 'Goods in transit', '{}'::jsonb, 'asset_current', false, null, 220),
  ('BB', 'default', '1300', 'Fixed deposits of more than three months', '{}'::jsonb, 'asset_current', false, null, 230),
  ('BB', 'default', '1310', 'Listed investments held for trading', '{}'::jsonb, 'asset_current', false, null, 240),
  ('BB', 'default', '1320', 'Amounts due from related companies — non-trade', '{}'::jsonb, 'asset_current', false, null, 250),
  ('BB', 'default', '1400', 'Prepaid expenses', '{}'::jsonb, 'asset_prepayments', false, null, 260),
  ('BB', 'default', '1410', 'Rental and utility deposits paid', '{}'::jsonb, 'asset_prepayments', false, null, 270),
  ('BB', 'default', '1420', 'Deposits paid to suppliers', '{}'::jsonb, 'asset_prepayments', false, null, 280),
  ('BB', 'default', '1600', 'Leasehold land and buildings', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('BB', 'default', '1610', 'Leasehold improvements', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('BB', 'default', '1620', 'Furniture and fixtures', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('BB', 'default', '1630', 'Office equipment', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('BB', 'default', '1640', 'Computer equipment and software', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('BB', 'default', '1650', 'Motor vehicles', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('BB', 'default', '1660', 'Plant and machinery', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('BB', 'default', '1670', 'Right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('BB', 'default', '1690', 'Accumulated depreciation — property plant and equipment', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('BB', 'default', '1695', 'Accumulated depreciation — right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 380),
  ('BB', 'default', '1800', 'Goodwill', '{}'::jsonb, 'asset_non_current', false, null, 390),
  ('BB', 'default', '1810', 'Other intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 400),
  ('BB', 'default', '1820', 'Accumulated amortisation — intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 410),
  ('BB', 'default', '1900', 'Investments in subsidiaries', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('BB', 'default', '1910', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('BB', 'default', '1920', 'Other long-term investments', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('BB', 'default', '1930', 'Rental and utility deposits — non-current', '{}'::jsonb, 'asset_non_current', false, null, 450),
  ('BB', 'default', '1990', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('BB', 'default', '2000', 'Trade creditors', '{}'::jsonb, 'liability_payable', true, null, 470),
  ('BB', 'default', '2010', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 480),
  ('BB', 'default', '2020', 'Accruals', '{}'::jsonb, 'liability_current', false, null, 490),
  ('BB', 'default', '2030', 'Customer deposits and advances received', '{}'::jsonb, 'liability_current', false, null, 500),
  ('BB', 'default', '2040', 'Salaries and wages payable', '{}'::jsonb, 'liability_current', false, null, 510),
  ('BB', 'default', '2050', 'National Insurance Scheme contributions payable', '{}'::jsonb, 'liability_current', false, null, 520),
  ('BB', 'default', '2060', 'Corporation tax payable', '{}'::jsonb, 'liability_current', false, null, 530),
  ('BB', 'default', '2070', 'Payroll deductions payable', '{}'::jsonb, 'liability_current', false, null, 540),
  ('BB', 'default', '2071', 'Customs duty payable', '{}'::jsonb, 'liability_current', false, null, 550),
  ('BB', 'default', '2072', 'Land tax payable', '{}'::jsonb, 'liability_current', false, null, 560),
  ('BB', 'default', '2073', 'Other government charges payable', '{}'::jsonb, 'liability_current', false, null, 570),
  ('BB', 'default', '2080', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 580),
  ('BB', 'default', '2090', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 590),
  ('BB', 'default', '2100', 'VAT payable — settlement of the return', '{}'::jsonb, 'liability_current', true, null, 600),
  ('BB', 'default', '2101', 'VAT collected — standard rate', '{}'::jsonb, 'liability_current', false, null, 610),
  ('BB', 'default', '2102', 'VAT collected — accommodation rate', '{}'::jsonb, 'liability_current', false, null, 620),
  ('BB', 'default', '2103', 'VAT collected — telecommunications rate', '{}'::jsonb, 'liability_current', false, null, 625),
  ('BB', 'default', '2200', 'Corporate credit card payable', '{}'::jsonb, 'liability_credit_card', false, null, 630),
  ('BB', 'default', '2300', 'Bank borrowings — non-current', '{}'::jsonb, 'liability_non_current', false, null, 640),
  ('BB', 'default', '2310', 'Lease liabilities — non-current', '{}'::jsonb, 'liability_non_current', false, null, 650),
  ('BB', 'default', '2320', 'Amounts due to shareholders — non-current', '{}'::jsonb, 'liability_non_current', false, null, 660),
  ('BB', 'default', '2390', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 670),
  ('BB', 'default', '3000', 'Issued and paid-up share capital', '{}'::jsonb, 'equity', false, null, 680),
  ('BB', 'default', '3100', 'Share premium', '{}'::jsonb, 'equity', false, null, 690),
  ('BB', 'default', '3110', 'Capital reserve', '{}'::jsonb, 'equity', false, null, 700),
  ('BB', 'default', '3200', 'Retained profits', '{}'::jsonb, 'equity_retained', false, null, 710),
  ('BB', 'default', '4000', 'Sale of goods', '{}'::jsonb, 'income', false, null, 720),
  ('BB', 'default', '4010', 'Rendering of services', '{}'::jsonb, 'income', false, null, 730),
  ('BB', 'default', '4700', 'Realised exchange gains', '{}'::jsonb, 'income_other', false, null, 740),
  ('BB', 'default', '4710', 'Unrealised exchange gains', '{}'::jsonb, 'income_other', false, null, 750),
  ('BB', 'default', '4720', 'Interest income', '{}'::jsonb, 'income_other', false, null, 760),
  ('BB', 'default', '4730', 'Sundry income', '{}'::jsonb, 'income_other', false, null, 770),
  ('BB', 'default', '4750', 'Gain on disposal of fixed assets', '{}'::jsonb, 'income_other', false, null, 780),
  ('BB', 'default', '5000', 'Cost of goods sold', '{}'::jsonb, 'expense_direct_cost', false, null, 790),
  ('BB', 'default', '5010', 'Purchases', '{}'::jsonb, 'expense_direct_cost', false, null, 800),
  ('BB', 'default', '5020', 'Freight inwards', '{}'::jsonb, 'expense_direct_cost', false, null, 810),
  ('BB', 'default', '5025', 'Customs duty on imports', '{}'::jsonb, 'expense_direct_cost', false, null, 820),
  ('BB', 'default', '5030', 'Direct labour', '{}'::jsonb, 'expense_direct_cost', false, null, 830),
  ('BB', 'default', '6000', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 840),
  ('BB', 'default', '6010', 'Staff salaries and wages', '{}'::jsonb, 'expense', false, null, 850),
  ('BB', 'default', '6020', 'Pension contributions', '{}'::jsonb, 'expense', false, null, 860),
  ('BB', 'default', '6025', 'Employer payroll contributions', '{}'::jsonb, 'expense', false, null, 870),
  ('BB', 'default', '6026', 'National Insurance Scheme — employer contribution', '{}'::jsonb, 'expense', false, null, 880),
  ('BB', 'default', '6030', 'Staff welfare and benefits', '{}'::jsonb, 'expense', false, null, 890),
  ('BB', 'default', '6100', 'Rent and rates', '{}'::jsonb, 'expense', false, null, 900),
  ('BB', 'default', '6110', 'Management fees and building outgoings', '{}'::jsonb, 'expense', false, null, 910),
  ('BB', 'default', '6120', 'Utilities', '{}'::jsonb, 'expense', false, null, 920),
  ('BB', 'default', '6130', 'Land tax', '{}'::jsonb, 'expense', false, null, 930),
  ('BB', 'default', '6200', 'Government fees, licences and company registry fees', '{}'::jsonb, 'expense', false, null, 940),
  ('BB', 'default', '6210', 'Auditor''s remuneration', '{}'::jsonb, 'expense', false, null, 950),
  ('BB', 'default', '6220', 'Accounting and company secretarial fees', '{}'::jsonb, 'expense', false, null, 960),
  ('BB', 'default', '6230', 'Legal and professional fees', '{}'::jsonb, 'expense', false, null, 970),
  ('BB', 'default', '6300', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 980),
  ('BB', 'default', '6310', 'Insurance', '{}'::jsonb, 'expense', false, null, 990),
  ('BB', 'default', '6320', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1000),
  ('BB', 'default', '6330', 'Travelling expenses', '{}'::jsonb, 'expense', false, null, 1010),
  ('BB', 'default', '6340', 'Entertainment expenses', '{}'::jsonb, 'expense', false, null, 1020),
  ('BB', 'default', '6350', 'Advertising and promotion', '{}'::jsonb, 'expense', false, null, 1030),
  ('BB', 'default', '6360', 'Printing, stationery and postage', '{}'::jsonb, 'expense', false, null, 1040),
  ('BB', 'default', '6370', 'Telecommunications', '{}'::jsonb, 'expense', false, null, 1050),
  ('BB', 'default', '6380', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1060),
  ('BB', 'default', '6390', 'Sundry office expenses', '{}'::jsonb, 'expense', false, null, 1070),
  ('BB', 'default', '6400', 'Allowance for expected credit losses charged', '{}'::jsonb, 'expense', false, null, 1080),
  ('BB', 'default', '6410', 'Interest expense on bank borrowings', '{}'::jsonb, 'expense', false, null, 1090),
  ('BB', 'default', '6420', 'Interest expense on lease liabilities', '{}'::jsonb, 'expense', false, null, 1100),
  ('BB', 'default', '6450', 'Realised exchange losses', '{}'::jsonb, 'expense', false, null, 1110),
  ('BB', 'default', '6455', 'Unrealised exchange losses', '{}'::jsonb, 'expense', false, null, 1120),
  ('BB', 'default', '6460', 'Loss on disposal of fixed assets', '{}'::jsonb, 'expense', false, null, 1130),
  ('BB', 'default', '6470', 'Corporation tax charge', '{}'::jsonb, 'expense', false, null, 1140),
  ('BB', 'default', '6480', 'Deferred tax charge', '{}'::jsonb, 'expense', false, null, 1150),
  ('BB', 'default', '6490', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1160),
  ('BB', 'default', '6800', 'Depreciation and amortisation', '{}'::jsonb, 'expense_depreciation', false, null, 1170)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('BB', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('BB', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('BB', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('BB', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('BB', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('BB', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('BB', 'BB-P-175', 'Purchase, VAT 17.5 %', '{}'::jsonb, 'A local purchase of a taxable supply, for the taxable activity', 'percent', 17.5, 'purchase', 'domestic', date '2022-04-01', null, 'Value Added Tax Act, Cap. 87, s. 46(2) and s. 48 — the allowable input tax of the registrant for the period is deemed paid on account of the output tax; s. 47 — the excess of input over output tax is refunded, if claimed within 5 years of the end of the period and all earlier returns are filed. Which input tax is allowable (s. 48, and s. 49 for motor cars, which restricts it) is the user''s to apply: the pack treats the tax on a business purchase as recoverable. Rate: see BB-S-175. valid_from is 1 April 2022, the date the Authority''s current list of zero-rated items took effect (Policy Note P&F No. 003/2022): the dates from which 17.5 %, 7.5 % and 22 % apply were not found in an official text, so the pack claims no document before that date.', null, null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'bb-vat-act', null, null, null, null),
  ('BB', 'BB-P-175-IMP', 'Import, VAT 17.5 %', '{}'::jsonb, 'Goods imported, VAT paid to the Comptroller of Customs', 'percent', 17.5, 'purchase', 'import', date '2022-04-01', null, 'Value Added Tax Act, Cap. 87, s. 7(1)(b) and (3) — tax is imposed on goods imported into Barbados, payable when the goods are entered for use within Barbados by the importer, proprietor or other person liable for the duties under the Customs Act; s. 46(2) lets the registrant count the tax paid on importation as input tax. The pack applies 17.5 % to the invoice value; the customs value on which the tax is charged (with duty) is the customs entry''s. Zero-rated importations are the Third Schedule''s (s. 11), not modelled. valid_from is 1 April 2022, the date the Authority''s current list of zero-rated items took effect (Policy Note P&F No. 003/2022): the dates from which 17.5 %, 7.5 % and 22 % apply were not found in an official text, so the pack claims no document before that date.', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'bb-vat-act', null, null, null, null),
  ('BB', 'BB-P-22', 'Purchase of telecommunications, VAT 22 %', '{}'::jsonb, 'Telecommunications services bought for the business', 'percent', 22, 'purchase', 'domestic', date '2022-04-01', null, 'Value Added Tax Act, Cap. 87, s. 46(2) and s. 48 — the allowable input tax of the registrant for the period is deemed paid on account of the output tax; s. 47 — the excess of input over output tax is refunded, if claimed within 5 years of the end of the period and all earlier returns are filed. Which input tax is allowable (s. 48, and s. 49 for motor cars, which restricts it) is the user''s to apply: the pack treats the tax on a business purchase as recoverable. Rate: see BB-S-22. valid_from is 1 April 2022, the date the Authority''s current list of zero-rated items took effect (Policy Note P&F No. 003/2022): the dates from which 17.5 %, 7.5 % and 22 % apply were not found in an official text, so the pack claims no document before that date.', null, null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'bra-vat-rates', null, null, null, null),
  ('BB', 'BB-P-75', 'Purchase of accommodation, VAT 7.5 %', '{}'::jsonb, 'Accommodation bought for the business at the tourism rate', 'percent', 7.5, 'purchase', 'domestic', date '2022-04-01', null, 'Value Added Tax Act, Cap. 87, s. 46(2) and s. 48 — the allowable input tax of the registrant for the period is deemed paid on account of the output tax; s. 47 — the excess of input over output tax is refunded, if claimed within 5 years of the end of the period and all earlier returns are filed. Which input tax is allowable (s. 48, and s. 49 for motor cars, which restricts it) is the user''s to apply: the pack treats the tax on a business purchase as recoverable. Rate: see BB-S-75. valid_from is 1 April 2022, the date the Authority''s current list of zero-rated items took effect (Policy Note P&F No. 003/2022): the dates from which 17.5 %, 7.5 % and 22 % apply were not found in an official text, so the pack claims no document before that date.', null, null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'bb-vat-act', null, null, null, null),
  ('BB', 'BB-P-EX', 'Purchase without VAT', '{}'::jsonb, 'A purchase of a zero-rated or exempt supply, or from a person who charges no VAT: no input tax to claim', 'percent', 0, 'purchase', 'exempt', date '2022-04-01', null, 'Value Added Tax Act, Cap. 87, s. 8 and s. 10 — a zero-rated supply carries tax at zero per cent and an exempt supply carries none, so the purchaser has no input tax to claim; the value is still reported among the purchases of the period.', null, null, 120, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'bb-vat-act', null, null, null, null),
  ('BB', 'BB-S-0', 'Zero-rated supply (export)', '{}'::jsonb, 'A supply taxable at the rate of zero per cent, an export of goods or services', 'percent', 0, 'sale', 'export', date '2022-04-01', null, 'Value Added Tax Act, Cap. 87, s. 8 — a taxable supply specified in the First Schedule and not in the Second is taxable at the rate of zero per cent; s. 2 — a zero-rated supply is a taxable supply, which keeps the right to recover input tax (s. 46(2), s. 47). The First Schedule''s paragraph on exports was not isolated in the text read; the pack carries the case under the Schedule''s general heading and the user checks the paragraph that applies. valid_from is 1 April 2022, the date the Authority''s current list of zero-rated items took effect (Policy Note P&F No. 003/2022): the dates from which 17.5 %, 7.5 % and 22 % apply were not found in an official text, so the pack claims no document before that date.', 'G', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'bb-vat-act', null, null, null, null),
  ('BB', 'BB-S-175', 'Sale, VAT 17.5 %', '{}'::jsonb, 'A taxable supply made in Barbados by a registrant, standard-rated', 'percent', 17.5, 'sale', 'domestic', date '2022-04-01', null, 'Value Added Tax Act, Cap. 87, s. 7(1) and (2) — tax is imposed on the taxable supply in Barbados of goods or services by a registrant, on the value of the supply, payable by the registrant when the supply is made. The Authority''s rates page gives 17.5 % as the ''rate for standard supplies''; the consolidated text of the Act the Authority publishes still prints 15 % in s. 7(2) and (3) and is amended by the Acts and Orders listed beside it, which this pack did not apply: the rate comes from the rates page. The base posts to box 1 net of the tax, the tax to box 7 (box numbers are this pack''s, see tax_report.json). valid_from is 1 April 2022, the date the Authority''s current list of zero-rated items took effect (Policy Note P&F No. 003/2022): the dates from which 17.5 %, 7.5 % and 22 % apply were not found in an official text, so the pack claims no document before that date.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'bra-vat-rates', null, null, null, null),
  ('BB', 'BB-S-175-INC', 'Retail sale, VAT 17.5 %, the price includes the tax', '{}'::jsonb, 'For a price set with the VAT already in it: the Act requires a price advertised, quoted or marked to include it', 'percent', 17.5, 'sale', 'domestic', date '2022-04-01', null, 'Value Added Tax Act, Cap. 87, s. 7(4) — the price a registrant advertises, quotes or marks on goods includes the tax payable; s. 7(5) allows a price without tax where the tax and the total are stated separately; s. 7(6) lets the Comptroller exempt a class of registrants. `price_include` records that the unit price of the line is the inclusive price; the engine takes the tax out of it. Rate: see BB-S-175. valid_from is 1 April 2022, the date the Authority''s current list of zero-rated items took effect (Policy Note P&F No. 003/2022): the dates from which 17.5 %, 7.5 % and 22 % apply were not found in an official text, so the pack claims no document before that date.', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, true, false, null, 'bb-vat-act', null, null, null, null),
  ('BB', 'BB-S-22', 'Sale of telecommunications services, VAT 22 %', '{}'::jsonb, 'Telecommunications services at the rate the Authority lists for them', 'percent', 22, 'sale', 'domestic', date '2022-04-01', null, 'The Authority''s rates page lists ''22 % — VAT on telecommunications services''. The provision of the Value Added Tax Act, Cap. 87 that sets it is an amendment to the consolidated text published (whose s. 7 prints only 15 % and 7½ %), which this pack did not locate: the rate rests on the rates page alone, and the definition of the services it reaches is the user''s, with their accountant. valid_from is 1 April 2022, the date the Authority''s current list of zero-rated items took effect (Policy Note P&F No. 003/2022): the dates from which 17.5 %, 7.5 % and 22 % apply were not found in an official text, so the pack claims no document before that date.', 'S', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'bra-vat-rates', null, null, null, null),
  ('BB', 'BB-S-75', 'Sale of accommodation, VAT 7.5 %', '{}'::jsonb, 'Accommodation by guest houses, hotels, inns and similar places, including a home let as a vacation or holiday home; direct tourism services', 'percent', 7.5, 'sale', 'domestic', date '2022-04-01', null, 'Value Added Tax Act, Cap. 87, s. 7(11) — notwithstanding s. 7, the tax on the supply of accommodation by guest houses, hotels, inns or any other similar place, including a dwellinghouse normally let as a vacation or holiday home, is 7½ per cent of the value of the supply. The Authority''s rates page gives 7.5 % for ''accommodating direct tourism services''. Secondary sources reviewed report 10 % from 1 January 2020 for the sector; no official text found says so and the Act and the rates page prevail here, but a reviewer must confirm the rate in force. valid_from is 1 April 2022, the date the Authority''s current list of zero-rated items took effect (Policy Note P&F No. 003/2022): the dates from which 17.5 %, 7.5 % and 22 % apply were not found in an official text, so the pack claims no document before that date.', 'S', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'bra-vat-rates', null, null, null, null),
  ('BB', 'BB-S-EX', 'Exempt supply', '{}'::jsonb, 'A supply specified in the Second Schedule: financial services, among others', 'percent', 0, 'sale', 'exempt', date '2022-04-01', null, 'Value Added Tax Act, Cap. 87, s. 10 — a supply of goods or services specified in the Second Schedule is exempt from the tax; the Schedule opens with the supply of a financial service (paragraph 1). The Authority''s page adds that a registrant making exempt supplies is not entitled to recover the allowable input tax on related purchases. The other paragraphs of the Schedule were not read in full. valid_from is 1 April 2022, the date the Authority''s current list of zero-rated items took effect (Policy Note P&F No. 003/2022): the dates from which 17.5 %, 7.5 % and 22 % apply were not found in an official text, so the pack claims no document before that date.', 'E', null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'bb-vat-act', null, null, null, null),
  ('BB', 'BB-S-Z', 'Zero-rated supply in Barbados', '{}'::jsonb, 'A domestic supply listed in the First Schedule: the Authority''s list of zero-rated items (from 1 April 2022) names sanitary towels and tampons, baby and adult diapers, antiperspirants, vitamins and multi-minerals, among others', 'percent', 0, 'sale', 'domestic', date '2022-04-01', null, 'Value Added Tax Act, Cap. 87, s. 8 and the First Schedule; Policy Note P&F No. 003/2022 of the Barbados Revenue Authority, whose revised list took effect on 1 April 2022. Only the examples the Authority''s page prints were read; the full table of the Policy Note was not, and the pack does not list the items.', 'Z', null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'bra-zero-rated-2022', null, null, null, null)
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
    ('BB-P-175', 'invoice', 'base', 100, null, '12', array['12']::text[], 100, 'BB-VAT-RETURN', 10),
    ('BB-P-175', 'invoice', 'tax', 100, '1170', '14', array['14']::text[], 100, 'BB-VAT-RETURN', 20),
    ('BB-P-175', 'credit_note', 'base', 100, null, '12', array['12']::text[], -100, 'BB-VAT-RETURN', 10),
    ('BB-P-175', 'credit_note', 'tax', 100, '1170', '14', array['14']::text[], -100, 'BB-VAT-RETURN', 20),
    ('BB-P-175-IMP', 'invoice', 'base', 100, null, '11', array['11']::text[], 100, 'BB-VAT-RETURN', 10),
    ('BB-P-175-IMP', 'invoice', 'tax', 100, '1171', '13', array['13']::text[], 100, 'BB-VAT-RETURN', 20),
    ('BB-P-175-IMP', 'credit_note', 'base', 100, null, '11', array['11']::text[], -100, 'BB-VAT-RETURN', 10),
    ('BB-P-175-IMP', 'credit_note', 'tax', 100, '1171', '13', array['13']::text[], -100, 'BB-VAT-RETURN', 20),
    ('BB-P-22', 'invoice', 'base', 100, null, '12', array['12']::text[], 100, 'BB-VAT-RETURN', 10),
    ('BB-P-22', 'invoice', 'tax', 100, '1170', '14', array['14']::text[], 100, 'BB-VAT-RETURN', 20),
    ('BB-P-22', 'credit_note', 'base', 100, null, '12', array['12']::text[], -100, 'BB-VAT-RETURN', 10),
    ('BB-P-22', 'credit_note', 'tax', 100, '1170', '14', array['14']::text[], -100, 'BB-VAT-RETURN', 20),
    ('BB-P-75', 'invoice', 'base', 100, null, '12', array['12']::text[], 100, 'BB-VAT-RETURN', 10),
    ('BB-P-75', 'invoice', 'tax', 100, '1170', '14', array['14']::text[], 100, 'BB-VAT-RETURN', 20),
    ('BB-P-75', 'credit_note', 'base', 100, null, '12', array['12']::text[], -100, 'BB-VAT-RETURN', 10),
    ('BB-P-75', 'credit_note', 'tax', 100, '1170', '14', array['14']::text[], -100, 'BB-VAT-RETURN', 20),
    ('BB-P-EX', 'invoice', 'base', 100, null, '12', array['12']::text[], 100, 'BB-VAT-RETURN', 10),
    ('BB-P-EX', 'credit_note', 'base', 100, null, '12', array['12']::text[], -100, 'BB-VAT-RETURN', 10),
    ('BB-S-0', 'invoice', 'base', 100, null, '4', array['4']::text[], 100, 'BB-VAT-RETURN', 10),
    ('BB-S-0', 'credit_note', 'base', 100, null, '4', array['4']::text[], -100, 'BB-VAT-RETURN', 10),
    ('BB-S-175', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'BB-VAT-RETURN', 10),
    ('BB-S-175', 'invoice', 'tax', 100, '2101', '7', array['7']::text[], 100, 'BB-VAT-RETURN', 20),
    ('BB-S-175', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'BB-VAT-RETURN', 10),
    ('BB-S-175', 'credit_note', 'tax', 100, '2101', '7', array['7']::text[], -100, 'BB-VAT-RETURN', 20),
    ('BB-S-175-INC', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'BB-VAT-RETURN', 10),
    ('BB-S-175-INC', 'invoice', 'tax', 100, '2101', '7', array['7']::text[], 100, 'BB-VAT-RETURN', 20),
    ('BB-S-175-INC', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'BB-VAT-RETURN', 10),
    ('BB-S-175-INC', 'credit_note', 'tax', 100, '2101', '7', array['7']::text[], -100, 'BB-VAT-RETURN', 20),
    ('BB-S-22', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'BB-VAT-RETURN', 10),
    ('BB-S-22', 'invoice', 'tax', 100, '2103', '9', array['9']::text[], 100, 'BB-VAT-RETURN', 20),
    ('BB-S-22', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'BB-VAT-RETURN', 10),
    ('BB-S-22', 'credit_note', 'tax', 100, '2103', '9', array['9']::text[], -100, 'BB-VAT-RETURN', 20),
    ('BB-S-75', 'invoice', 'base', 100, null, '2', array['2']::text[], 100, 'BB-VAT-RETURN', 10),
    ('BB-S-75', 'invoice', 'tax', 100, '2102', '8', array['8']::text[], 100, 'BB-VAT-RETURN', 20),
    ('BB-S-75', 'credit_note', 'base', 100, null, '2', array['2']::text[], -100, 'BB-VAT-RETURN', 10),
    ('BB-S-75', 'credit_note', 'tax', 100, '2102', '8', array['8']::text[], -100, 'BB-VAT-RETURN', 20),
    ('BB-S-EX', 'invoice', 'base', 100, null, '5', array['5']::text[], 100, 'BB-VAT-RETURN', 10),
    ('BB-S-EX', 'credit_note', 'base', 100, null, '5', array['5']::text[], -100, 'BB-VAT-RETURN', 10),
    ('BB-S-Z', 'invoice', 'base', 100, null, '4', array['4']::text[], 100, 'BB-VAT-RETURN', 10),
    ('BB-S-Z', 'credit_note', 'base', 100, null, '4', array['4']::text[], -100, 'BB-VAT-RETURN', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'BB' and t.code = v.tax_code
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
  ('BB', 'BB-VAT-RETURN', 'VAT return (box layout of this pack)', array['month', 'bimonth']::declaration_period[], 'bimonth'::declaration_period, date '2022-04-01', null, 'Value Added Tax Act, Cap. 87, s. 44 — the taxable period is a two-month period beginning on the first day of January, March, May, July, September and November, or of February, April, June, August, October and December, as the Comptroller determines and notifies; calendar months on request (s. 44(5)) and always for a large taxpayer (supplies of $25 000 000 or more over 12 months); longer periods on application (s. 44(6)). The Authority''s table of filing periods (period numbers 202201 to 202212) lists both series. Only the series starting in January (the second, ''B'') fits the ''bimonth'' of the format, which is anchored on 1 January: a registrant on the December series files periods the format cannot express, see README.md. s. 45 — a return for each taxable period within 21 days after its end', true,'day_of_month_after_period'::filing_deadline_rule, 21, null, 'Value Added Tax Act, Cap. 87, s. 45(1) — every registrant files a return within 21 days after the end of each taxable period, and s. 46(1) pays the output tax within the same 21 days. For a period ending on the last day of a month, the 21st day is the 21st of the next month. The Comptroller may extend the time (s. 45(4)); a penalty of $100 applies to a late return (s. 45(3)). Weekend roll-forward is not expressible', 'bb-vat-act', null)
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
  ('BB', 'BB-VAT-RETURN', '1', 'base', 'Standard-rated supplies (17.5 %), net of VAT', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Box number and label are this pack''s own: the Authority''s VAT return form was not found online (it is filed in the Authority''s online services portal), so the layout follows what the Act makes a return carry — the output tax of the period (s. 46), the allowable input tax (s. 46(2), s. 48) and the net payable or refundable (s. 46, s. 47). Taxable supplies at the standard rate (s. 7(2)).', 'bb-vat-act'),
  ('BB', 'BB-VAT-RETURN', '2', 'base', 'Accommodation and direct tourism supplies (7.5 %), net of VAT', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Taxable supplies at 7½ per cent (s. 7(11)).', 'bb-vat-act'),
  ('BB', 'BB-VAT-RETURN', '3', 'base', 'Telecommunications supplies (22 %), net of VAT', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Taxable supplies at the telecommunications rate the Authority lists (rates page).', 'bb-vat-act'),
  ('BB', 'BB-VAT-RETURN', '4', 'base', 'Zero-rated supplies, including exports', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Taxable supplies at zero per cent (s. 8); they are taxable supplies and stay on the return (s. 45(1) requires a return for each period whether or not a taxable supply was made).', 'bb-vat-act'),
  ('BB', 'BB-VAT-RETURN', '5', 'base', 'Exempt supplies', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Supplies of the Second Schedule (s. 10), reported for information; the right to recover input tax does not follow them.', 'bb-vat-act'),
  ('BB', 'BB-VAT-RETURN', '6', 'total', 'Total supplies', '{}'::jsonb, 60, null, array['1', '2', '3', '4', '5']::text[], '{}'::text[], null, null, false, false, null, 'Sum of boxes 1 to 5 — the sum is this pack''s reading, the Act asks for ''such information as the Comptroller approves'' (s. 45(1)).', 'bb-vat-act'),
  ('BB', 'BB-VAT-RETURN', '7', 'tax', 'Output tax on standard-rated supplies', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tax at 17.5 % on box 1 (s. 7(2)).', 'bb-vat-act'),
  ('BB', 'BB-VAT-RETURN', '8', 'tax', 'Output tax on accommodation', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tax at 7.5 % on box 2 (s. 7(11)).', 'bb-vat-act'),
  ('BB', 'BB-VAT-RETURN', '9', 'tax', 'Output tax on telecommunications', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tax at 22 % on box 3.', 'bb-vat-act'),
  ('BB', 'BB-VAT-RETURN', '10', 'total', 'Total output tax for the period', '{}'::jsonb, 100, null, array['7', '8', '9']::text[], '{}'::text[], null, null, false, false, null, 'The output tax payable for the taxable period (s. 46(1)); a credit note posts a negative amount to its own boxes (s. 52).', 'bb-vat-act'),
  ('BB', 'BB-VAT-RETURN', '11', 'base', 'Value of imports', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Goods imported on which tax was paid on entry (s. 7(3)).', 'bb-vat-act'),
  ('BB', 'BB-VAT-RETURN', '12', 'base', 'Value of local purchases', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Purchases made in Barbados for the taxable activity, taxable, zero-rated and exempt.', 'bb-vat-act'),
  ('BB', 'BB-VAT-RETURN', '13', 'tax', 'VAT paid on imports', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Input tax on importation, deemed paid on account of the output tax (s. 46(2)(a)).', 'bb-vat-act'),
  ('BB', 'BB-VAT-RETURN', '14', 'tax', 'VAT paid on local purchases', '{}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Allowable input tax on local purchases (s. 46(2)(a), s. 48).', 'bb-vat-act'),
  ('BB', 'BB-VAT-RETURN', '15', 'total', 'Total input tax for the period', '{}'::jsonb, 150, null, array['13', '14']::text[], '{}'::text[], null, null, false, false, null, 'Sum of boxes 13 and 14.', 'bb-vat-act'),
  ('BB', 'BB-VAT-RETURN', '16', 'total', 'VAT payable', '{}'::jsonb, 160, null, array['10']::text[], array['15']::text[], null, null, true, false, null, 'The output tax of the period not covered by input tax, paid within 21 days after the end of the period (s. 46(1), (2)); a balance under $1 is not payable (s. 46(3)). Penalty and interest on default (s. 46(4)) are not modelled.', 'bb-vat-act'),
  ('BB', 'BB-VAT-RETURN', '17', 'total', 'VAT refundable', '{}'::jsonb, 170, null, array['15']::text[], array['10']::text[], null, null, true, false, null, 'The excess of input over output tax, refunded or applied against what is owed, if claimed in a return filed within 5 years of the end of the period (s. 47(1), (2)).', 'bb-vat-act')
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
  ('BB-IFRS-SME-IS', 'BB', 'default', 'Income statement', 'income_statement', 'IFRS-SME', date '1970-01-01', null, 'Same choice as the statement of financial position: the income statement is presented in the manner of IFRS for SMEs, section 5, with the expenses collapsed to cost of sales, other operating expenses and depreciation. No Barbados text read prescribes it. The corporate income tax charge (6470) falls in other operating expenses; the Income Tax Act was not opened and the tax is not modelled', null, null, null, '{}'::jsonb),
  ('BB-IFRS-SME-SFP', 'BB', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS-SME', date '1970-01-01', null, 'The Companies Act, Cap. 308, and the Income Tax Act, Cap. 73, of Barbados were not opened for this pack, so no section of either is cited, and none is asserted to prescribe a layout. This statement follows the presentation of IFRS for SMEs (International Accounting Standards Board), section 4: current and non-current assets and liabilities, with equity shown beside them; that is a choice of this pack, not a text the country imposes, and a company reporting under full IFRS presents the same balance sheet with different notes. The numbering and the ranges each line reads are original to this pack. The VAT collected (2100 to 2199) is a current tax liability; the VAT recoverable sits with the receivables (1170 to 1172), unnetted. Cash flows and changes in equity are separate statements this pack does not model', null, 'alone', null, '{}'::jsonb)
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
  ('BB-IFRS-SME-IS', 'REV', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BB-IFRS-SME-IS', 'COST', null, 'Cost of sales', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BB-IFRS-SME-IS', 'GROSS', null, 'Gross profit', '{}'::jsonb, 30, 1, true, array['REV']::text[], array['COST']::text[], null, null, null),
  ('BB-IFRS-SME-IS', 'OTH-INC', null, 'Other income', '{}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BB-IFRS-SME-IS', 'OPEX', null, 'Administrative and other operating expenses', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BB-IFRS-SME-IS', 'DEPR', null, 'Depreciation and amortisation', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BB-IFRS-SME-IS', 'PROFIT', null, 'Profit (loss) for the year', '{}'::jsonb, 70, 1, true, array['GROSS', 'OTH-INC']::text[], array['OPEX', 'DEPR']::text[], null, null, null),
  ('BB-IFRS-SME-SFP', 'A-NC-FIX', 'A-NC', 'Property, plant and equipment', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BB-IFRS-SME-SFP', 'A-NC-INT', 'A-NC', 'Goodwill and other intangible assets', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BB-IFRS-SME-SFP', 'A-NC-OTH', 'A-NC', 'Other non-current assets', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BB-IFRS-SME-SFP', 'A-NC', null, 'Non-current assets', '{}'::jsonb, 40, 1, true, array['A-NC-FIX', 'A-NC-INT', 'A-NC-OTH']::text[], '{}'::text[], null, null, null),
  ('BB-IFRS-SME-SFP', 'A-C-REC', 'A-C', 'Trade and other receivables', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BB-IFRS-SME-SFP', 'A-C-INV', 'A-C', 'Inventories', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BB-IFRS-SME-SFP', 'A-C-OTH', 'A-C', 'Other current assets', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BB-IFRS-SME-SFP', 'A-C-PRE', 'A-C', 'Prepayments and deposits paid', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BB-IFRS-SME-SFP', 'A-C-CASH', 'A-C', 'Cash and cash equivalents', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BB-IFRS-SME-SFP', 'A-C', null, 'Current assets', '{}'::jsonb, 100, 1, true, array['A-C-REC', 'A-C-INV', 'A-C-OTH', 'A-C-PRE', 'A-C-CASH']::text[], '{}'::text[], null, null, null),
  ('BB-IFRS-SME-SFP', 'A-TOT', null, 'Total assets', '{}'::jsonb, 110, 1, true, array['A-NC', 'A-C']::text[], '{}'::text[], null, null, null),
  ('BB-IFRS-SME-SFP', 'E-CAP', 'E-TOT', 'Share capital and reserves', '{}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BB-IFRS-SME-SFP', 'E-RET', 'E-TOT', 'Retained earnings', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BB-IFRS-SME-SFP', 'E-RESULT', 'E-TOT', 'Profit or loss for the year, not yet allocated', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BB-IFRS-SME-SFP', 'E-TOT', null, 'Total equity', '{}'::jsonb, 150, 1, true, array['E-CAP', 'E-RET', 'E-RESULT']::text[], '{}'::text[], null, null, null),
  ('BB-IFRS-SME-SFP', 'L-NC', 'L-TOT', 'Non-current liabilities', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BB-IFRS-SME-SFP', 'L-C-PAY', 'L-C', 'Trade and other payables', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BB-IFRS-SME-SFP', 'L-C-TAX', 'L-C', 'Current tax liabilities, including VAT collected', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BB-IFRS-SME-SFP', 'L-C-OTH', 'L-C', 'Other current liabilities', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BB-IFRS-SME-SFP', 'L-C', null, 'Current liabilities', '{}'::jsonb, 200, 1, true, array['L-C-PAY', 'L-C-TAX', 'L-C-OTH']::text[], '{}'::text[], null, null, null),
  ('BB-IFRS-SME-SFP', 'L-TOT', null, 'Total liabilities', '{}'::jsonb, 210, 1, true, array['L-NC', 'L-C']::text[], '{}'::text[], null, null, null),
  ('BB-IFRS-SME-SFP', 'EL-TOT', null, 'Total equity and liabilities', '{}'::jsonb, 220, 1, true, array['E-TOT', 'L-TOT']::text[], '{}'::text[], null, null, null)
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
 where r.statement_code in ('BB-IFRS-SME-IS', 'BB-IFRS-SME-SFP')
   and (r.statement_code, r.line_code, r.sequence) not in (
     values ('BB-IFRS-SME-IS', 'REV', 10),
            ('BB-IFRS-SME-IS', 'COST', 10),
            ('BB-IFRS-SME-IS', 'OTH-INC', 10),
            ('BB-IFRS-SME-IS', 'OPEX', 10),
            ('BB-IFRS-SME-IS', 'DEPR', 10),
            ('BB-IFRS-SME-SFP', 'A-NC-FIX', 10),
            ('BB-IFRS-SME-SFP', 'A-NC-INT', 10),
            ('BB-IFRS-SME-SFP', 'A-NC-OTH', 10),
            ('BB-IFRS-SME-SFP', 'A-C-REC', 10),
            ('BB-IFRS-SME-SFP', 'A-C-INV', 10),
            ('BB-IFRS-SME-SFP', 'A-C-OTH', 10),
            ('BB-IFRS-SME-SFP', 'A-C-PRE', 10),
            ('BB-IFRS-SME-SFP', 'A-C-CASH', 10),
            ('BB-IFRS-SME-SFP', 'E-CAP', 10),
            ('BB-IFRS-SME-SFP', 'E-RET', 10),
            ('BB-IFRS-SME-SFP', 'E-RESULT', 10),
            ('BB-IFRS-SME-SFP', 'E-RESULT', 20),
            ('BB-IFRS-SME-SFP', 'E-RESULT', 30),
            ('BB-IFRS-SME-SFP', 'E-RESULT', 40),
            ('BB-IFRS-SME-SFP', 'L-NC', 10),
            ('BB-IFRS-SME-SFP', 'L-C-PAY', 10),
            ('BB-IFRS-SME-SFP', 'L-C-TAX', 10),
            ('BB-IFRS-SME-SFP', 'L-C-TAX', 20),
            ('BB-IFRS-SME-SFP', 'L-C-OTH', 10),
            ('BB-IFRS-SME-SFP', 'L-C-OTH', 20)
   );

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('BB-IFRS-SME-IS', 'REV', 10, 'code_range', '4000', '4699', null, 'any'),
    ('BB-IFRS-SME-IS', 'COST', 10, 'code_range', '5000', '5099', null, 'any'),
    ('BB-IFRS-SME-IS', 'OTH-INC', 10, 'code_range', '4700', '4799', null, 'any'),
    ('BB-IFRS-SME-IS', 'OPEX', 10, 'code_range', '6000', '6799', null, 'any'),
    ('BB-IFRS-SME-IS', 'DEPR', 10, 'code_range', '6800', '6899', null, 'any'),
    ('BB-IFRS-SME-SFP', 'A-NC-FIX', 10, 'code_range', '1600', '1799', null, 'any'),
    ('BB-IFRS-SME-SFP', 'A-NC-INT', 10, 'code_range', '1800', '1899', null, 'any'),
    ('BB-IFRS-SME-SFP', 'A-NC-OTH', 10, 'code_range', '1900', '1999', null, 'any'),
    ('BB-IFRS-SME-SFP', 'A-C-REC', 10, 'code_range', '1100', '1199', null, 'any'),
    ('BB-IFRS-SME-SFP', 'A-C-INV', 10, 'code_range', '1200', '1299', null, 'any'),
    ('BB-IFRS-SME-SFP', 'A-C-OTH', 10, 'code_range', '1300', '1399', null, 'any'),
    ('BB-IFRS-SME-SFP', 'A-C-PRE', 10, 'code_range', '1400', '1499', null, 'any'),
    ('BB-IFRS-SME-SFP', 'A-C-CASH', 10, 'code_range', '1000', '1099', null, 'any'),
    ('BB-IFRS-SME-SFP', 'E-CAP', 10, 'code_range', '3000', '3199', null, 'any'),
    ('BB-IFRS-SME-SFP', 'E-RET', 10, 'code_range', '3200', '3299', null, 'any'),
    ('BB-IFRS-SME-SFP', 'E-RESULT', 10, 'code_range', '4000', '4699', null, 'any'),
    ('BB-IFRS-SME-SFP', 'E-RESULT', 20, 'code_range', '4700', '4799', null, 'any'),
    ('BB-IFRS-SME-SFP', 'E-RESULT', 30, 'code_range', '5000', '5099', null, 'any'),
    ('BB-IFRS-SME-SFP', 'E-RESULT', 40, 'code_range', '6000', '6899', null, 'any'),
    ('BB-IFRS-SME-SFP', 'L-NC', 10, 'code_range', '2300', '2399', null, 'any'),
    ('BB-IFRS-SME-SFP', 'L-C-PAY', 10, 'code_range', '2000', '2059', null, 'any'),
    ('BB-IFRS-SME-SFP', 'L-C-TAX', 10, 'code_range', '2060', '2069', null, 'any'),
    ('BB-IFRS-SME-SFP', 'L-C-TAX', 20, 'code_range', '2100', '2199', null, 'any'),
    ('BB-IFRS-SME-SFP', 'L-C-OTH', 10, 'code_range', '2070', '2099', null, 'any'),
    ('BB-IFRS-SME-SFP', 'L-C-OTH', 20, 'code_range', '2200', '2299', null, 'any')
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
  ('BB', 'Barbados', '{}'::jsonb, array['en']::text[], 'BBD', '1100', '2000', '2090', '6490', '3200', '4000', '5010', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6450', '4750', '6460', null, null, '2100', '1172', null, 'bimonth'::declaration_period)
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
  numbering_legal_reference     = 'Value Added Tax Regulations, 1996, reg. 2(b) — a tax invoice carries ''a number assigned to the tax invoice identifying the invoice as one of a series issued by the registrant''. The text asks for a series, and does not say the series may have no gap, which is why `numbering` is `sequential` and not `gapless`; `number_format` is a convention this pack proposes',
  numbering_source_key          = 'bb-vat-regs',
  payment_terms_legal_reference = 'No Barbados text read for this pack sets a payment term between two businesses or a rate of interest on a commercial debt paid late: the penalty of 10 per cent and the interest of the Value Added Tax Act, Cap. 87, s. 46(4) are charges on the registrant towards the Comptroller, not a term between two businesses. `legal_payment_days` and `late_payment_reference` are empty',
  payment_terms_source_key      = 'bb-vat-act',
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Value Added Tax Act, Cap. 87, s. 16(1) — a supply takes place when an invoice for it is issued, when payment is received or when the goods are made available or the services performed, ''whichever is the earliest''; s. 16(3) applies the same three triggers to a periodic payment under an agreement that provides for them. The closed vocabulary of this field has no value for three triggers at once: `earliest_of_delivery_or_payment` is the nearest and is what the rule reduces to when no invoice comes first. The other cases of s. 16 (hire purchase, sale on approval) are not modelled',
  tax_point_source_key          = 'bb-vat-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No Barbados text read for this pack obliges a business to issue or accept an electronic invoice: the Value Added Tax Regulations, 1996, reg. 2 list the particulars of a tax invoice without naming a platform, a format or a Peppol profile, and the Value Added Tax Act, Cap. 87, s. 7(7) only asks a registrant to issue a tax invoice to another registrant who requests one. No Peppol authority for Barbados was looked for. `profile`, `party_scheme` and `vat_scheme` are null: there is no domestic profile to name',
  einvoice_source_key           = 'bb-vat-regs',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'BB';
