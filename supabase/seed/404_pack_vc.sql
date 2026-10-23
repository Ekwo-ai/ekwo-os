-- Ekwo OS — Saint Vincent and the Grenadines: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/vc at version 0.2.0, do not edit.
-- Change the pack and run `ekwo pack build vc`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Value Added Tax Act, Cap. 445 (Act No. 25 of 2006, amended by Act No. 11 of 2007, S.R.O. 41 of 2007 and Act No. 1 of 2008), Revised Edition, issue 1/2009, as published on the Inland Revenue Department's legislation page; the scan states the rates of 2009 (15 and 10 percent) and later amendments are not applied (Government of Saint Vincent and the Grenadines (Inland Revenue Department))
--     https://ird.gov.vc/images/pdf/VAT_Act_Cap_445.pdf
--   Taxes — VAT: who registers, the 15th-of-the-month filing and payment date, the current rates (standard 16 %, accommodation 11 %, zero-rated, exempt) and interest of 1.5 % a month (Inland Revenue Department, Government of Saint Vincent and the Grenadines)
--     https://ird.gov.vc/index.php/taxes
--   Frequently asked questions — VAT rates, registration threshold of $300,000, VAT invoice and sales receipt, reverse charge on services bought abroad, tax period of a calendar month (Inland Revenue Department, Government of Saint Vincent and the Grenadines)
--     https://ird.gov.vc/index.php/faqs
--   Zero-Rating of Value Added Tax (VAT) on Additional Food Items and Adult Pampers — Cabinet decision of 29 October 2025, with effect from 3 November 2025 (Agency for Public Information, Government of Saint Vincent and the Grenadines)
--     https://www.gov.vc/index.php/media-center/4066-zero-rating-of-valued-added-tax-vat-on-additional-food-items-and-adult-pampers
--   Vincentians to pay more taxes in 2017 — press report of the 2017 Budget Address: standard VAT rate raised to 16 per cent as of 1 May 2017 (the only text found for the date; the Act itself was not found in its amended form) (iWitness News)
--     https://www.iwnsvg.com/2017/02/06/vincentians-to-pay-more-taxes-in-2017/
--   IFRS for SMEs Accounting Standard (IFRS Foundation / International Accounting Standards Board)
--     https://www.ifrs.org/issued-standards/ifrs-for-smes/
--   Website of the Inland Revenue Department, the Comptroller's administration (forms, legislation, rates and the link to the e-Tax filing service) (Inland Revenue Department, Government of Saint Vincent and the Grenadines)
--     https://ird.gov.vc
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('VC', 'Saint Vincent and the Grenadines', '0.2.0', date '2026-10-23', '20261023124650', 'community', null, null, '29be22927cbe59bf9dae8ce5434ab70ee552505b960e1746a4135f0b945cd9a0', '[{"key":"vc-vat-act","title":"Value Added Tax Act, Cap. 445 (Act No. 25 of 2006, amended by Act No. 11 of 2007, S.R.O. 41 of 2007 and Act No. 1 of 2008), Revised Edition, issue 1/2009, as published on the Inland Revenue Department''s legislation page; the scan states the rates of 2009 (15 and 10 percent) and later amendments are not applied","publisher":"Government of Saint Vincent and the Grenadines (Inland Revenue Department)","url":"https://ird.gov.vc/images/pdf/VAT_Act_Cap_445.pdf","consulted_on":"2026-10-20","kind":"law"},{"key":"vc-ird-taxes","title":"Taxes — VAT: who registers, the 15th-of-the-month filing and payment date, the current rates (standard 16 %, accommodation 11 %, zero-rated, exempt) and interest of 1.5 % a month","publisher":"Inland Revenue Department, Government of Saint Vincent and the Grenadines","url":"https://ird.gov.vc/index.php/taxes","consulted_on":"2026-10-20","kind":"guidance"},{"key":"vc-ird-faqs","title":"Frequently asked questions — VAT rates, registration threshold of $300,000, VAT invoice and sales receipt, reverse charge on services bought abroad, tax period of a calendar month","publisher":"Inland Revenue Department, Government of Saint Vincent and the Grenadines","url":"https://ird.gov.vc/index.php/faqs","consulted_on":"2026-10-20","kind":"guidance"},{"key":"vc-cabinet-zero-rating-2025","title":"Zero-Rating of Value Added Tax (VAT) on Additional Food Items and Adult Pampers — Cabinet decision of 29 October 2025, with effect from 3 November 2025","publisher":"Agency for Public Information, Government of Saint Vincent and the Grenadines","url":"https://www.gov.vc/index.php/media-center/4066-zero-rating-of-valued-added-tax-vat-on-additional-food-items-and-adult-pampers","consulted_on":"2026-10-20","kind":"guidance"},{"key":"vc-budget-2017-news","title":"Vincentians to pay more taxes in 2017 — press report of the 2017 Budget Address: standard VAT rate raised to 16 per cent as of 1 May 2017 (the only text found for the date; the Act itself was not found in its amended form)","publisher":"iWitness News","url":"https://www.iwnsvg.com/2017/02/06/vincentians-to-pay-more-taxes-in-2017/","consulted_on":"2026-10-20","kind":"guidance"},{"key":"iasb-ifrs-sme","title":"IFRS for SMEs Accounting Standard","publisher":"IFRS Foundation / International Accounting Standards Board","url":"https://www.ifrs.org/issued-standards/ifrs-for-smes/","consulted_on":"2026-10-20","kind":"standard"},{"key":"vc-ird-portal","title":"Website of the Inland Revenue Department, the Comptroller''s administration (forms, legislation, rates and the link to the e-Tax filing service)","publisher":"Inland Revenue Department, Government of Saint Vincent and the Grenadines","url":"https://ird.gov.vc","consulted_on":"2026-10-20","kind":"portal"}]'::jsonb)
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
  ('VC', 'default', 'Saint Vincent and the Grenadines reference chart of accounts', '{}'::jsonb, true, 'companies', array['VC-IFRS-SME-IS', 'VC-IFRS-SME-SFP']::text[], null, 'This pack found no legal chart of accounts in Saint Vincent and the Grenadines, and opened neither the Companies Act nor the Income Tax Act: no section of either is cited. What the Value Added Tax Act, Cap. 445 asks of a registered person is a VAT invoice or a sales receipt (s. 32 and 33) and records kept (s. 38). This chart is original: four digits, blocked so that each range reaches one line of a statement of financial position and an income statement presented in the manner of IFRS for SMEs, which is a choice of this pack and not a text the country imposes. The settlement account of the VAT return (2100, refundable 1172) is distinct from the accounts the tax posts to (2101, 2102 and 2103 collected, 1170 and 1171 recoverable). See README.md', 'vc-vat-act')
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
  ('VC', 'default', '1000', 'Cash on hand', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('VC', 'default', '1010', 'Bank current account', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('VC', 'default', '1020', 'Bank savings account', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('VC', 'default', '1030', 'Foreign currency bank account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('VC', 'default', '1040', 'Payment gateway and card clearing account', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('VC', 'default', '1050', 'Fixed deposits of three months or less', '{}'::jsonb, 'asset_cash', false, null, 60),
  ('VC', 'default', '1060', 'Cash in transit', '{}'::jsonb, 'asset_cash', false, null, 70),
  ('VC', 'default', '1100', 'Trade debtors', '{}'::jsonb, 'asset_receivable', true, null, 80),
  ('VC', 'default', '1105', 'Allowance for expected credit losses', '{}'::jsonb, 'asset_current', false, null, 90),
  ('VC', 'default', '1110', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 100),
  ('VC', 'default', '1120', 'Other debtors', '{}'::jsonb, 'asset_current', false, null, 110),
  ('VC', 'default', '1130', 'Accrued income', '{}'::jsonb, 'asset_current', false, null, 120),
  ('VC', 'default', '1140', 'Staff advances and loans to employees', '{}'::jsonb, 'asset_current', false, null, 130),
  ('VC', 'default', '1150', 'Customs duty deposits paid', '{}'::jsonb, 'asset_current', false, null, 140),
  ('VC', 'default', '1160', 'Corporation tax recoverable', '{}'::jsonb, 'asset_current', false, null, 150),
  ('VC', 'default', '1170', 'VAT recoverable — local purchases', '{}'::jsonb, 'asset_current', false, null, 160),
  ('VC', 'default', '1171', 'VAT recoverable — imports paid to the Comptroller of Customs', '{}'::jsonb, 'asset_current', false, null, 170),
  ('VC', 'default', '1172', 'VAT refundable — settlement of the return', '{}'::jsonb, 'asset_current', true, null, 180),
  ('VC', 'default', '1200', 'Inventory — raw materials and consumables', '{}'::jsonb, 'asset_current', false, null, 190),
  ('VC', 'default', '1210', 'Inventory — work in progress', '{}'::jsonb, 'asset_current', false, null, 200),
  ('VC', 'default', '1220', 'Inventory — finished goods and goods for resale', '{}'::jsonb, 'asset_current', false, null, 210),
  ('VC', 'default', '1230', 'Goods in transit', '{}'::jsonb, 'asset_current', false, null, 220),
  ('VC', 'default', '1300', 'Fixed deposits of more than three months', '{}'::jsonb, 'asset_current', false, null, 230),
  ('VC', 'default', '1310', 'Listed investments held for trading', '{}'::jsonb, 'asset_current', false, null, 240),
  ('VC', 'default', '1320', 'Amounts due from related companies — non-trade', '{}'::jsonb, 'asset_current', false, null, 250),
  ('VC', 'default', '1400', 'Prepaid expenses', '{}'::jsonb, 'asset_prepayments', false, null, 260),
  ('VC', 'default', '1410', 'Rental and utility deposits paid', '{}'::jsonb, 'asset_prepayments', false, null, 270),
  ('VC', 'default', '1420', 'Deposits paid to suppliers', '{}'::jsonb, 'asset_prepayments', false, null, 280),
  ('VC', 'default', '1600', 'Leasehold land and buildings', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('VC', 'default', '1610', 'Leasehold improvements', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('VC', 'default', '1620', 'Furniture and fixtures', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('VC', 'default', '1630', 'Office equipment', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('VC', 'default', '1640', 'Computer equipment and software', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('VC', 'default', '1650', 'Motor vehicles', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('VC', 'default', '1660', 'Plant and machinery', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('VC', 'default', '1670', 'Right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('VC', 'default', '1690', 'Accumulated depreciation — property plant and equipment', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('VC', 'default', '1695', 'Accumulated depreciation — right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 380),
  ('VC', 'default', '1800', 'Goodwill', '{}'::jsonb, 'asset_non_current', false, null, 390),
  ('VC', 'default', '1810', 'Other intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 400),
  ('VC', 'default', '1820', 'Accumulated amortisation — intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 410),
  ('VC', 'default', '1900', 'Investments in subsidiaries', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('VC', 'default', '1910', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('VC', 'default', '1920', 'Other long-term investments', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('VC', 'default', '1930', 'Rental and utility deposits — non-current', '{}'::jsonb, 'asset_non_current', false, null, 450),
  ('VC', 'default', '1990', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('VC', 'default', '2000', 'Trade creditors', '{}'::jsonb, 'liability_payable', true, null, 470),
  ('VC', 'default', '2010', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 480),
  ('VC', 'default', '2020', 'Accruals', '{}'::jsonb, 'liability_current', false, null, 490),
  ('VC', 'default', '2030', 'Customer deposits and advances received', '{}'::jsonb, 'liability_current', false, null, 500),
  ('VC', 'default', '2040', 'Salaries and wages payable', '{}'::jsonb, 'liability_current', false, null, 510),
  ('VC', 'default', '2050', 'National Insurance Scheme contributions payable', '{}'::jsonb, 'liability_current', false, null, 520),
  ('VC', 'default', '2060', 'Corporation tax payable', '{}'::jsonb, 'liability_current', false, null, 530),
  ('VC', 'default', '2070', 'Payroll deductions payable', '{}'::jsonb, 'liability_current', false, null, 540),
  ('VC', 'default', '2071', 'Customs duty payable', '{}'::jsonb, 'liability_current', false, null, 550),
  ('VC', 'default', '2072', 'Land tax payable', '{}'::jsonb, 'liability_current', false, null, 560),
  ('VC', 'default', '2073', 'Other government charges payable', '{}'::jsonb, 'liability_current', false, null, 570),
  ('VC', 'default', '2080', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 580),
  ('VC', 'default', '2090', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 590),
  ('VC', 'default', '2100', 'VAT payable — settlement of the return', '{}'::jsonb, 'liability_current', true, null, 600),
  ('VC', 'default', '2101', 'VAT collected — standard rate (17 %)', '{}'::jsonb, 'liability_current', false, null, 610),
  ('VC', 'default', '2102', 'VAT collected — accommodation rate', '{}'::jsonb, 'liability_current', false, null, 620),
  ('VC', 'default', '2103', 'VAT collected — restaurant and tour operator rate (10 %)', '{}'::jsonb, 'liability_current', false, null, 625),
  ('VC', 'default', '2200', 'Corporate credit card payable', '{}'::jsonb, 'liability_credit_card', false, null, 630),
  ('VC', 'default', '2300', 'Bank borrowings — non-current', '{}'::jsonb, 'liability_non_current', false, null, 640),
  ('VC', 'default', '2310', 'Lease liabilities — non-current', '{}'::jsonb, 'liability_non_current', false, null, 650),
  ('VC', 'default', '2320', 'Amounts due to shareholders — non-current', '{}'::jsonb, 'liability_non_current', false, null, 660),
  ('VC', 'default', '2390', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 670),
  ('VC', 'default', '3000', 'Issued and paid-up share capital', '{}'::jsonb, 'equity', false, null, 680),
  ('VC', 'default', '3100', 'Share premium', '{}'::jsonb, 'equity', false, null, 690),
  ('VC', 'default', '3110', 'Capital reserve', '{}'::jsonb, 'equity', false, null, 700),
  ('VC', 'default', '3200', 'Retained profits', '{}'::jsonb, 'equity_retained', false, null, 710),
  ('VC', 'default', '4000', 'Sale of goods', '{}'::jsonb, 'income', false, null, 720),
  ('VC', 'default', '4010', 'Rendering of services', '{}'::jsonb, 'income', false, null, 730),
  ('VC', 'default', '4700', 'Realised exchange gains', '{}'::jsonb, 'income_other', false, null, 740),
  ('VC', 'default', '4710', 'Unrealised exchange gains', '{}'::jsonb, 'income_other', false, null, 750),
  ('VC', 'default', '4720', 'Interest income', '{}'::jsonb, 'income_other', false, null, 760),
  ('VC', 'default', '4730', 'Sundry income', '{}'::jsonb, 'income_other', false, null, 770),
  ('VC', 'default', '4750', 'Gain on disposal of fixed assets', '{}'::jsonb, 'income_other', false, null, 780),
  ('VC', 'default', '5000', 'Cost of goods sold', '{}'::jsonb, 'expense_direct_cost', false, null, 790),
  ('VC', 'default', '5010', 'Purchases', '{}'::jsonb, 'expense_direct_cost', false, null, 800),
  ('VC', 'default', '5020', 'Freight inwards', '{}'::jsonb, 'expense_direct_cost', false, null, 810),
  ('VC', 'default', '5025', 'Customs duty on imports', '{}'::jsonb, 'expense_direct_cost', false, null, 820),
  ('VC', 'default', '5030', 'Direct labour', '{}'::jsonb, 'expense_direct_cost', false, null, 830),
  ('VC', 'default', '6000', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 840),
  ('VC', 'default', '6010', 'Staff salaries and wages', '{}'::jsonb, 'expense', false, null, 850),
  ('VC', 'default', '6020', 'Pension contributions', '{}'::jsonb, 'expense', false, null, 860),
  ('VC', 'default', '6025', 'Employer payroll contributions', '{}'::jsonb, 'expense', false, null, 870),
  ('VC', 'default', '6026', 'National Insurance Scheme — employer contribution', '{}'::jsonb, 'expense', false, null, 880),
  ('VC', 'default', '6030', 'Staff welfare and benefits', '{}'::jsonb, 'expense', false, null, 890),
  ('VC', 'default', '6100', 'Rent and rates', '{}'::jsonb, 'expense', false, null, 900),
  ('VC', 'default', '6110', 'Management fees and building outgoings', '{}'::jsonb, 'expense', false, null, 910),
  ('VC', 'default', '6120', 'Utilities', '{}'::jsonb, 'expense', false, null, 920),
  ('VC', 'default', '6130', 'Land tax', '{}'::jsonb, 'expense', false, null, 930),
  ('VC', 'default', '6200', 'Government fees, licences and company registry fees', '{}'::jsonb, 'expense', false, null, 940),
  ('VC', 'default', '6210', 'Auditor''s remuneration', '{}'::jsonb, 'expense', false, null, 950),
  ('VC', 'default', '6220', 'Accounting and company secretarial fees', '{}'::jsonb, 'expense', false, null, 960),
  ('VC', 'default', '6230', 'Legal and professional fees', '{}'::jsonb, 'expense', false, null, 970),
  ('VC', 'default', '6300', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 980),
  ('VC', 'default', '6310', 'Insurance', '{}'::jsonb, 'expense', false, null, 990),
  ('VC', 'default', '6320', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1000),
  ('VC', 'default', '6330', 'Travelling expenses', '{}'::jsonb, 'expense', false, null, 1010),
  ('VC', 'default', '6340', 'Entertainment expenses', '{}'::jsonb, 'expense', false, null, 1020),
  ('VC', 'default', '6350', 'Advertising and promotion', '{}'::jsonb, 'expense', false, null, 1030),
  ('VC', 'default', '6360', 'Printing, stationery and postage', '{}'::jsonb, 'expense', false, null, 1040),
  ('VC', 'default', '6370', 'Telecommunications', '{}'::jsonb, 'expense', false, null, 1050),
  ('VC', 'default', '6380', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1060),
  ('VC', 'default', '6390', 'Sundry office expenses', '{}'::jsonb, 'expense', false, null, 1070),
  ('VC', 'default', '6400', 'Allowance for expected credit losses charged', '{}'::jsonb, 'expense', false, null, 1080),
  ('VC', 'default', '6410', 'Interest expense on bank borrowings', '{}'::jsonb, 'expense', false, null, 1090),
  ('VC', 'default', '6420', 'Interest expense on lease liabilities', '{}'::jsonb, 'expense', false, null, 1100),
  ('VC', 'default', '6450', 'Realised exchange losses', '{}'::jsonb, 'expense', false, null, 1110),
  ('VC', 'default', '6455', 'Unrealised exchange losses', '{}'::jsonb, 'expense', false, null, 1120),
  ('VC', 'default', '6460', 'Loss on disposal of fixed assets', '{}'::jsonb, 'expense', false, null, 1130),
  ('VC', 'default', '6470', 'Corporation tax charge', '{}'::jsonb, 'expense', false, null, 1140),
  ('VC', 'default', '6480', 'Deferred tax charge', '{}'::jsonb, 'expense', false, null, 1150),
  ('VC', 'default', '6490', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1160),
  ('VC', 'default', '6800', 'Depreciation and amortisation', '{}'::jsonb, 'expense_depreciation', false, null, 1170)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('VC', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('VC', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('VC', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('VC', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('VC', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('VC', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('VC', 'VC-P-11', 'Purchase of accommodation or tourist services, VAT 11 %', '{}'::jsonb, 'Accommodation or tourist services bought for the business at the reduced rate', 'percent', 11, 'purchase', 'domestic', date '2017-05-01', null, 'Value Added Tax Act, Cap. 445, s. 29 and s. 8(3)(b) — the input tax on accommodation or tourist services acquired for the taxable activity, at 11 percent (see VC-S-11 for the rate). Base to box 12, tax to box 14.', null, null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vc-ird-taxes', null, null, null, null),
  ('VC', 'VC-P-16', 'Purchase, VAT 16 %', '{}'::jsonb, 'A purchase from a registered person, standard-rated, with a VAT invoice', 'percent', 16, 'purchase', 'domestic', date '2017-05-01', null, 'Value Added Tax Act, Cap. 445, s. 29 — input tax credits for a taxable person on what is acquired for a taxable activity, on the strength of a VAT invoice (s. 32); rate as VC-S-16. The pack treats all the tax on a business purchase as recoverable; the denials of s. 28 (passenger vehicles, entertainment) are the user''s. Base to box 12, tax to box 14.', null, null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vc-ird-taxes', null, null, null, null),
  ('VC', 'VC-P-16-IMP', 'Import of goods, VAT 16 %', '{}'::jsonb, 'Goods imported: the VAT paid to the Comptroller of Customs', 'percent', 16, 'purchase', 'import', date '2017-05-01', null, 'Value Added Tax Act, Cap. 445, s. 8(1)(b) and (2) — VAT is levied on a taxable import, the rate applied to its value; s. 29 for the credit; rate as VC-S-16. The pack applies 16 percent to the invoice value; the value for VAT of an import (with duty and freight) is the customs entry''s. Base to box 11, tax to box 13.', null, null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vc-vat-act', null, null, null, null),
  ('VC', 'VC-P-EX', 'Purchase without VAT', '{}'::jsonb, 'A purchase of a zero-rated or exempt supply, or from a person who charges no VAT: no input tax to claim', 'percent', 0, 'purchase', 'exempt', date '2007-05-01', null, 'A purchase of a zero-rated or exempt supply, or from a person who charges no VAT, carries no input tax to claim (Value Added Tax Act, Cap. 445, s. 29 allows the credit for tax actually charged on a VAT invoice). Base to box 12.', null, null, 110, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'vc-vat-act', null, null, null, null),
  ('VC', 'VC-S-0', 'Zero-rated supply (export)', '{}'::jsonb, 'An export of goods or a service consumed outside Saint Vincent and the Grenadines, zero-rated', 'percent', 0, 'sale', 'export', date '2007-05-01', null, 'Value Added Tax Act, Cap. 445, s. 8(3)(a) — zero per cent for a zero-rated supply; First Schedule (goods exported or located outside the country, supplies to duty-free vendors) and Second Schedule (services connected with exported goods, services consumed outside the country, telecommunications, international financial services). The zero-rated supply stays on the return. valid_from is 1 May 2007, the implementation date given by the Department''s FAQ.', 'G', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vc-vat-act', null, null, null, null),
  ('VC', 'VC-S-11', 'Sale of accommodation or tourist services, VAT 11 %', '{}'::jsonb, 'Holiday or hotel accommodation (stays of fewer than forty-five days) and the tourist services of s. 8(3)(b), at the reduced rate', 'percent', 11, 'sale', 'domestic', date '2017-05-01', null, 'Value Added Tax Act, Cap. 445, s. 8(3)(b) — a reduced rate for holiday or hotel accommodation, accommodation in a caravan, houseboat, camping site, boat or marina berth for a continuous period of less than forty-five days, and for diving, marine or land tour services and other services ordinarily provided to tourists that the Minister prescribes by order. The 2009 edition says 10 percent; the Department''s pages give the current accommodation rate as 11 percent ("Accommodation (Rooms) — 11%"). No official text read for this pack states the rate of the tourist services after 2017: the press report of the 2017 Budget Address raises accommodation and other tourism-related activities from 10 to 11 percent, and the pack carries 11 percent for both until a reviewer checks the order. Stays beyond forty-five days under a landlord and tenant agreement are exempt (Fourth Schedule, items 7 and 8) and go to VC-S-EX. Base to box 2, tax to box 8.', 'S', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vc-ird-taxes', null, null, null, null),
  ('VC', 'VC-S-11-T', 'Sale of diving, tour or other tourist services, VAT 11 %', '{}'::jsonb, 'Diving, marine or land tour services and other services ordinarily provided to tourists, at the reduced rate', 'percent', 11, 'sale', 'domestic', date '2017-05-01', null, 'Value Added Tax Act, Cap. 445, s. 8(3)(b)(iii) (inserted by S.R.O. 41 of 2007, amended by Act No. 1 of 2008) — diving services, marine or land tour services and any other service ordinarily provided to tourists or visitors that the Minister prescribes by order; 10 percent in the 2009 edition, carried at 11 percent with the accommodation rate (see VC-S-11). The orders listing the prescribed services were not read: the pack does not decide which services qualify, and a restaurant''s food and drink is not a tourist service in this pack. Base to box 3, tax to box 9.', 'S', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vc-vat-act', null, null, null, null),
  ('VC', 'VC-S-16', 'Sale, VAT 16 %', '{}'::jsonb, 'A taxable supply made in Saint Vincent and the Grenadines by a registered person, standard-rated', 'percent', 16, 'sale', 'domestic', date '2017-05-01', null, 'Value Added Tax Act, Cap. 445, s. 8(1)-(3)(d) — VAT is levied on a taxable supply and a taxable import; in any other case than zero-rating, accommodation and tourist services the standard rate applies; s. 8(4) — the VAT on a supply is the liability of the supplier. Rate: the revised edition of the Act in the Inland Revenue Department''s legislation page (issue 1/2009) states 15 percent (s. 8(3)(d)) and 10 percent for accommodation (s. 8(3)(b)); the Department''s page "Taxes" and its FAQ give the current rates as 16 percent standard and 11 percent for accommodation. The amending instrument was not found; the 1 May 2017 date comes from the Budget Address of 2017 as reported by the press. The base posts to box 1 net of the tax, the tax to box 7 (box numbers are this pack''s, see tax_report.json).', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vc-ird-taxes', null, null, null, null),
  ('VC', 'VC-S-16-INC', 'Retail sale, VAT 16 %, the price includes the tax', '{}'::jsonb, 'A standard-rated sale whose price already holds the VAT', 'percent', 16, 'sale', 'domestic', date '2017-05-01', null, 'Value Added Tax Act, Cap. 445, s. 8(3)(d) at the standard rate (16 percent, see VC-S-16 for the source of the rate), applied to a price that already holds the tax — what price_include does: 116.00 holds 100.00 and 16.00. The Act''s own definition of the value of a supply whose price includes the tax was not located. Same boxes as VC-S-16.', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, true, false, null, 'vc-ird-taxes', null, null, null, null),
  ('VC', 'VC-S-EX', 'Exempt supply', '{}'::jsonb, 'A supply of the Fourth Schedule (financial services, insurance, sale of real property, residential rent, stays of more than forty-five days, passenger transport), outside the tax', 'percent', 0, 'sale', 'exempt', date '2007-05-01', null, 'Value Added Tax Act, Cap. 445, Fourth Schedule (exempt supplies), paragraph 1, items 2 to 10: financial services and insurance, supplies of goods used solely to make exempt supplies, international transport, the sale of real property, residential leases, long stays under a landlord and tenant agreement, supplies by a condominium body corporate to a member and the transport of passengers within the country. Reported on the return for information; the input tax of what is acquired to make them is not recoverable. The remaining items (health, education and the like) were not read in full and are not listed. valid_from is 1 May 2007.', 'E', null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vc-vat-act', null, null, null, null),
  ('VC', 'VC-S-Z', 'Zero-rated supply in Saint Vincent and the Grenadines', '{}'::jsonb, 'A domestic supply of the Third Schedule at zero per cent (basic foods, residential electricity and water, fuel, exercise books, newspapers, computers, solar equipment, hygiene items)', 'percent', 0, 'sale', 'domestic', date '2007-05-01', null, 'Value Added Tax Act, Cap. 445, Third Schedule (zero-rated supplies and imports: other) — items 1 to 14: listed foods (white rice, cane sugar, milk, flour, cooking oil, salt and others), the first 200 kWh a month of residential electricity, gasoline, kerosene, diesel and LPG, exercise books, newspapers, computers, residential water, the service charge within the limits of item 11, hygiene goods, solar water heaters and solar panels. The list of food items grew after the 2009 edition: the Cabinet decision of 29 October 2025 zero-rated nine more items (other chicken parts, processed cheddar cheese, canned tuna and sardines, chicken sausages, cereals, lentils, health drinks, adult diapers) from 3 November 2025. The pack does not reproduce the list; whether a supply is on it is the user''s to check against the Act and the Regulations. valid_from is 1 May 2007, the implementation date.', 'Z', null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vc-vat-act', null, null, null, null)
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
    ('VC-P-11', 'invoice', 'base', 100, null, '12', array['12']::text[], 100, 'VC-VAT-RETURN', 10),
    ('VC-P-11', 'invoice', 'tax', 100, '1170', '14', array['14']::text[], 100, 'VC-VAT-RETURN', 20),
    ('VC-P-11', 'credit_note', 'base', 100, null, '12', array['12']::text[], -100, 'VC-VAT-RETURN', 10),
    ('VC-P-11', 'credit_note', 'tax', 100, '1170', '14', array['14']::text[], -100, 'VC-VAT-RETURN', 20),
    ('VC-P-16', 'invoice', 'base', 100, null, '12', array['12']::text[], 100, 'VC-VAT-RETURN', 10),
    ('VC-P-16', 'invoice', 'tax', 100, '1170', '14', array['14']::text[], 100, 'VC-VAT-RETURN', 20),
    ('VC-P-16', 'credit_note', 'base', 100, null, '12', array['12']::text[], -100, 'VC-VAT-RETURN', 10),
    ('VC-P-16', 'credit_note', 'tax', 100, '1170', '14', array['14']::text[], -100, 'VC-VAT-RETURN', 20),
    ('VC-P-16-IMP', 'invoice', 'base', 100, null, '11', array['11']::text[], 100, 'VC-VAT-RETURN', 10),
    ('VC-P-16-IMP', 'invoice', 'tax', 100, '1171', '13', array['13']::text[], 100, 'VC-VAT-RETURN', 20),
    ('VC-P-16-IMP', 'credit_note', 'base', 100, null, '11', array['11']::text[], -100, 'VC-VAT-RETURN', 10),
    ('VC-P-16-IMP', 'credit_note', 'tax', 100, '1171', '13', array['13']::text[], -100, 'VC-VAT-RETURN', 20),
    ('VC-P-EX', 'invoice', 'base', 100, null, '12', array['12']::text[], 100, 'VC-VAT-RETURN', 10),
    ('VC-P-EX', 'credit_note', 'base', 100, null, '12', array['12']::text[], -100, 'VC-VAT-RETURN', 10),
    ('VC-S-0', 'invoice', 'base', 100, null, '4', array['4']::text[], 100, 'VC-VAT-RETURN', 10),
    ('VC-S-0', 'credit_note', 'base', 100, null, '4', array['4']::text[], -100, 'VC-VAT-RETURN', 10),
    ('VC-S-11', 'invoice', 'base', 100, null, '2', array['2']::text[], 100, 'VC-VAT-RETURN', 10),
    ('VC-S-11', 'invoice', 'tax', 100, '2102', '8', array['8']::text[], 100, 'VC-VAT-RETURN', 20),
    ('VC-S-11', 'credit_note', 'base', 100, null, '2', array['2']::text[], -100, 'VC-VAT-RETURN', 10),
    ('VC-S-11', 'credit_note', 'tax', 100, '2102', '8', array['8']::text[], -100, 'VC-VAT-RETURN', 20),
    ('VC-S-11-T', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'VC-VAT-RETURN', 10),
    ('VC-S-11-T', 'invoice', 'tax', 100, '2103', '9', array['9']::text[], 100, 'VC-VAT-RETURN', 20),
    ('VC-S-11-T', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'VC-VAT-RETURN', 10),
    ('VC-S-11-T', 'credit_note', 'tax', 100, '2103', '9', array['9']::text[], -100, 'VC-VAT-RETURN', 20),
    ('VC-S-16', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'VC-VAT-RETURN', 10),
    ('VC-S-16', 'invoice', 'tax', 100, '2101', '7', array['7']::text[], 100, 'VC-VAT-RETURN', 20),
    ('VC-S-16', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'VC-VAT-RETURN', 10),
    ('VC-S-16', 'credit_note', 'tax', 100, '2101', '7', array['7']::text[], -100, 'VC-VAT-RETURN', 20),
    ('VC-S-16-INC', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'VC-VAT-RETURN', 10),
    ('VC-S-16-INC', 'invoice', 'tax', 100, '2101', '7', array['7']::text[], 100, 'VC-VAT-RETURN', 20),
    ('VC-S-16-INC', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'VC-VAT-RETURN', 10),
    ('VC-S-16-INC', 'credit_note', 'tax', 100, '2101', '7', array['7']::text[], -100, 'VC-VAT-RETURN', 20),
    ('VC-S-EX', 'invoice', 'base', 100, null, '5', array['5']::text[], 100, 'VC-VAT-RETURN', 10),
    ('VC-S-EX', 'credit_note', 'base', 100, null, '5', array['5']::text[], -100, 'VC-VAT-RETURN', 10),
    ('VC-S-Z', 'invoice', 'base', 100, null, '4', array['4']::text[], 100, 'VC-VAT-RETURN', 10),
    ('VC-S-Z', 'credit_note', 'base', 100, null, '4', array['4']::text[], -100, 'VC-VAT-RETURN', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'VC' and t.code = v.tax_code
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
  ('VC', 'VC-VAT-RETURN', 'VAT return (box layout of this pack)', array['month']::declaration_period[], 'month'::declaration_period, date '2007-05-01', null, 'Value Added Tax Act, Cap. 445, s. 39(1) — a taxable person lodges a VAT return for each tax period no later than fifteen calendar days after the end of the period; s. 39(2) — with the Comptroller, in the form the Comptroller prescribes (the Department''s VAT return form was not read as a text); s. 41(1) — the tax is due by the due date for lodgement. The Department''s FAQ makes the tax period a calendar month and asks for a return even with no transactions; the page "Taxes" gives the 15th of the month following the period for filing and payment.', true,'day_of_month_after_period'::filing_deadline_rule, 15, null, 'Value Added Tax Act, Cap. 445, s. 39(1) and s. 41(1) — the return is lodged within fifteen calendar days after the end of the tax period and the tax is due by the same date: for a month, the 15th of the next month (confirmed by the Department''s page "Taxes"). Tax paid late bears a penalty of twenty percent of the amount unpaid (s. 41(3)) and, according to the Department, interest of 1.5 % a month; the penalties for a late return are not modelled. Permission to lodge late does not move the date of payment (s. 39(4)). Weekend roll-forward is not expressible', 'vc-vat-act', null)
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
  ('VC', 'VC-VAT-RETURN', '1', 'base', 'Standard-rated supplies (16 %), net of VAT', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Taxable supplies at the standard rate (s. 8(3)(d)). Box number and label are this pack''s own: the Department''s form was not read as a text, so the boxes follow what the Act makes the tax payable carry — output tax less the input tax credit (s. 27, s. 29).', 'vc-vat-act'),
  ('VC', 'VC-VAT-RETURN', '2', 'base', 'Accommodation supplies (11 %), net of VAT', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Taxable supplies of holiday or hotel accommodation at the reduced rate (s. 8(3)(b)(i), (ii)).', 'vc-vat-act'),
  ('VC', 'VC-VAT-RETURN', '3', 'base', 'Tourist services (11 %), net of VAT', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Taxable supplies of diving, marine or land tour services and other services ordinarily provided to tourists at the reduced rate (s. 8(3)(b)(iii)).', 'vc-vat-act'),
  ('VC', 'VC-VAT-RETURN', '4', 'base', 'Zero-rated supplies, including exports', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Taxable supplies at zero percent (s. 8(3)(a); First, Second and Third Schedules); they stay on the return (the Department asks for a return even when there is no activity).', 'vc-vat-act'),
  ('VC', 'VC-VAT-RETURN', '5', 'base', 'Exempt supplies', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Supplies of the Fourth Schedule, reported for information; the input tax of what is acquired to make them is not deductible.', 'vc-vat-act'),
  ('VC', 'VC-VAT-RETURN', '6', 'total', 'Total supplies', '{}'::jsonb, 60, null, array['1', '2', '3', '4', '5']::text[], '{}'::text[], null, null, false, false, null, 'Sum of boxes 1 to 5 — the sum is this pack''s reading, the form is the Comptroller''s (s. 39(2)).', 'vc-vat-act'),
  ('VC', 'VC-VAT-RETURN', '7', 'tax', 'Output tax on standard-rated supplies', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tax at 16 % on box 1 (s. 8(3)(d)).', 'vc-vat-act'),
  ('VC', 'VC-VAT-RETURN', '8', 'tax', 'Output tax on accommodation', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tax at 11 % on box 2 (s. 8(3)(b)).', 'vc-vat-act'),
  ('VC', 'VC-VAT-RETURN', '9', 'tax', 'Output tax on tourist services', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tax at 11 % on box 3 (s. 8(3)(b)(iii)).', 'vc-vat-act'),
  ('VC', 'VC-VAT-RETURN', '10', 'total', 'Total output tax for the period', '{}'::jsonb, 100, null, array['7', '8', '9']::text[], '{}'::text[], null, null, false, false, null, 'Sum of boxes 7 to 9.', 'vc-vat-act'),
  ('VC', 'VC-VAT-RETURN', '11', 'base', 'Value of imports', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value of taxable imports of the period (s. 8(1)(b)).', 'vc-vat-act'),
  ('VC', 'VC-VAT-RETURN', '12', 'base', 'Value of local purchases', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value of purchases from registered persons and others, net of VAT.', 'vc-vat-act'),
  ('VC', 'VC-VAT-RETURN', '13', 'tax', 'VAT paid on imports', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT paid on imports, recoverable (s. 29).', 'vc-vat-act'),
  ('VC', 'VC-VAT-RETURN', '14', 'tax', 'VAT paid on local purchases', '{}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT charged by suppliers on local purchases, recoverable (s. 29).', 'vc-vat-act'),
  ('VC', 'VC-VAT-RETURN', '15', 'total', 'Total input tax credit for the period', '{}'::jsonb, 150, null, array['13', '14']::text[], '{}'::text[], null, null, false, false, null, 'Sum of boxes 13 and 14 (s. 29).', 'vc-vat-act'),
  ('VC', 'VC-VAT-RETURN', '16', 'total', 'VAT payable', '{}'::jsonb, 160, null, array['10']::text[], array['15']::text[], null, null, true, false, null, 'Output tax less input tax credit when positive; due by the due date for lodgement (s. 41(1)).', 'vc-vat-act'),
  ('VC', 'VC-VAT-RETURN', '17', 'total', 'VAT refundable', '{}'::jsonb, 170, null, array['15']::text[], array['10']::text[], null, null, true, false, null, 'Input tax credit less output tax when positive. The Department''s FAQ carries a credit of less than $100 forward and allows a refund after three consecutive months of credit; the Comptroller applies s. 44.', 'vc-ird-faqs')
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
  ('VC-IFRS-SME-IS', 'VC', 'default', 'Income statement', 'income_statement', 'IFRS-SME', date '1970-01-01', null, 'Same choice as the statement of financial position: the income statement is presented in the manner of IFRS for SMEs, section 5, with the expenses collapsed to cost of sales, other operating expenses and depreciation. No text of Saint Vincent and the Grenadines read prescribes it. The corporate income tax charge (6470) falls in other operating expenses; the Income Tax Act was not opened and the tax is not modelled', 'iasb-ifrs-sme', null, null, '{}'::jsonb),
  ('VC-IFRS-SME-SFP', 'VC', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS-SME', date '1970-01-01', null, 'The Companies Act and the Income Tax Act of Saint Vincent and the Grenadines were not opened for this pack, so no section of either is cited, and none is asserted to prescribe a layout. This statement follows the presentation of IFRS for SMEs (International Accounting Standards Board), section 4: current and non-current assets and liabilities, with equity shown beside them; that is a choice of this pack, not a text the country imposes, and a company reporting under full IFRS presents the same balance sheet with different notes. The numbering and the ranges each line reads are original to this pack. The VAT collected (2100 to 2199) is a current tax liability; the VAT recoverable sits with the receivables (1170 to 1172), unnetted. Cash flows and changes in equity are separate statements this pack does not model', 'iasb-ifrs-sme', 'alone', null, '{}'::jsonb)
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
  ('VC-IFRS-SME-IS', 'REV', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VC-IFRS-SME-IS', 'COST', null, 'Cost of sales', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VC-IFRS-SME-IS', 'GROSS', null, 'Gross profit', '{}'::jsonb, 30, 1, true, array['REV']::text[], array['COST']::text[], null, null, null),
  ('VC-IFRS-SME-IS', 'OTH-INC', null, 'Other income', '{}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VC-IFRS-SME-IS', 'OPEX', null, 'Administrative and other operating expenses', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VC-IFRS-SME-IS', 'DEPR', null, 'Depreciation and amortisation', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VC-IFRS-SME-IS', 'PROFIT', null, 'Profit (loss) for the year', '{}'::jsonb, 70, 1, true, array['GROSS', 'OTH-INC']::text[], array['OPEX', 'DEPR']::text[], null, null, null),
  ('VC-IFRS-SME-SFP', 'A-NC-FIX', 'A-NC', 'Property, plant and equipment', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VC-IFRS-SME-SFP', 'A-NC-INT', 'A-NC', 'Goodwill and other intangible assets', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VC-IFRS-SME-SFP', 'A-NC-OTH', 'A-NC', 'Other non-current assets', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VC-IFRS-SME-SFP', 'A-NC', null, 'Non-current assets', '{}'::jsonb, 40, 1, true, array['A-NC-FIX', 'A-NC-INT', 'A-NC-OTH']::text[], '{}'::text[], null, null, null),
  ('VC-IFRS-SME-SFP', 'A-C-REC', 'A-C', 'Trade and other receivables', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VC-IFRS-SME-SFP', 'A-C-INV', 'A-C', 'Inventories', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VC-IFRS-SME-SFP', 'A-C-OTH', 'A-C', 'Other current assets', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VC-IFRS-SME-SFP', 'A-C-PRE', 'A-C', 'Prepayments and deposits paid', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VC-IFRS-SME-SFP', 'A-C-CASH', 'A-C', 'Cash and cash equivalents', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VC-IFRS-SME-SFP', 'A-C', null, 'Current assets', '{}'::jsonb, 100, 1, true, array['A-C-REC', 'A-C-INV', 'A-C-OTH', 'A-C-PRE', 'A-C-CASH']::text[], '{}'::text[], null, null, null),
  ('VC-IFRS-SME-SFP', 'A-TOT', null, 'Total assets', '{}'::jsonb, 110, 1, true, array['A-NC', 'A-C']::text[], '{}'::text[], null, null, null),
  ('VC-IFRS-SME-SFP', 'E-CAP', 'E-TOT', 'Share capital and reserves', '{}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VC-IFRS-SME-SFP', 'E-RET', 'E-TOT', 'Retained earnings', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VC-IFRS-SME-SFP', 'E-RESULT', 'E-TOT', 'Profit or loss for the year, not yet allocated', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VC-IFRS-SME-SFP', 'E-TOT', null, 'Total equity', '{}'::jsonb, 150, 1, true, array['E-CAP', 'E-RET', 'E-RESULT']::text[], '{}'::text[], null, null, null),
  ('VC-IFRS-SME-SFP', 'L-NC', 'L-TOT', 'Non-current liabilities', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VC-IFRS-SME-SFP', 'L-C-PAY', 'L-C', 'Trade and other payables', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VC-IFRS-SME-SFP', 'L-C-TAX', 'L-C', 'Current tax liabilities, including VAT collected', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VC-IFRS-SME-SFP', 'L-C-OTH', 'L-C', 'Other current liabilities', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VC-IFRS-SME-SFP', 'L-C', null, 'Current liabilities', '{}'::jsonb, 200, 1, true, array['L-C-PAY', 'L-C-TAX', 'L-C-OTH']::text[], '{}'::text[], null, null, null),
  ('VC-IFRS-SME-SFP', 'L-TOT', null, 'Total liabilities', '{}'::jsonb, 210, 1, true, array['L-NC', 'L-C']::text[], '{}'::text[], null, null, null),
  ('VC-IFRS-SME-SFP', 'EL-TOT', null, 'Total equity and liabilities', '{}'::jsonb, 220, 1, true, array['E-TOT', 'L-TOT']::text[], '{}'::text[], null, null, null)
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
 where r.statement_code in ('VC-IFRS-SME-IS', 'VC-IFRS-SME-SFP')
   and (r.statement_code, r.line_code, r.sequence) not in (
     values ('VC-IFRS-SME-IS', 'REV', 10),
            ('VC-IFRS-SME-IS', 'COST', 10),
            ('VC-IFRS-SME-IS', 'OTH-INC', 10),
            ('VC-IFRS-SME-IS', 'OPEX', 10),
            ('VC-IFRS-SME-IS', 'DEPR', 10),
            ('VC-IFRS-SME-SFP', 'A-NC-FIX', 10),
            ('VC-IFRS-SME-SFP', 'A-NC-INT', 10),
            ('VC-IFRS-SME-SFP', 'A-NC-OTH', 10),
            ('VC-IFRS-SME-SFP', 'A-C-REC', 10),
            ('VC-IFRS-SME-SFP', 'A-C-INV', 10),
            ('VC-IFRS-SME-SFP', 'A-C-OTH', 10),
            ('VC-IFRS-SME-SFP', 'A-C-PRE', 10),
            ('VC-IFRS-SME-SFP', 'A-C-CASH', 10),
            ('VC-IFRS-SME-SFP', 'E-CAP', 10),
            ('VC-IFRS-SME-SFP', 'E-RET', 10),
            ('VC-IFRS-SME-SFP', 'E-RESULT', 10),
            ('VC-IFRS-SME-SFP', 'E-RESULT', 20),
            ('VC-IFRS-SME-SFP', 'E-RESULT', 30),
            ('VC-IFRS-SME-SFP', 'E-RESULT', 40),
            ('VC-IFRS-SME-SFP', 'L-NC', 10),
            ('VC-IFRS-SME-SFP', 'L-C-PAY', 10),
            ('VC-IFRS-SME-SFP', 'L-C-TAX', 10),
            ('VC-IFRS-SME-SFP', 'L-C-TAX', 20),
            ('VC-IFRS-SME-SFP', 'L-C-OTH', 10),
            ('VC-IFRS-SME-SFP', 'L-C-OTH', 20)
   );

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('VC-IFRS-SME-IS', 'REV', 10, 'code_range', '4000', '4699', null, 'any'),
    ('VC-IFRS-SME-IS', 'COST', 10, 'code_range', '5000', '5099', null, 'any'),
    ('VC-IFRS-SME-IS', 'OTH-INC', 10, 'code_range', '4700', '4799', null, 'any'),
    ('VC-IFRS-SME-IS', 'OPEX', 10, 'code_range', '6000', '6799', null, 'any'),
    ('VC-IFRS-SME-IS', 'DEPR', 10, 'code_range', '6800', '6899', null, 'any'),
    ('VC-IFRS-SME-SFP', 'A-NC-FIX', 10, 'code_range', '1600', '1799', null, 'any'),
    ('VC-IFRS-SME-SFP', 'A-NC-INT', 10, 'code_range', '1800', '1899', null, 'any'),
    ('VC-IFRS-SME-SFP', 'A-NC-OTH', 10, 'code_range', '1900', '1999', null, 'any'),
    ('VC-IFRS-SME-SFP', 'A-C-REC', 10, 'code_range', '1100', '1199', null, 'any'),
    ('VC-IFRS-SME-SFP', 'A-C-INV', 10, 'code_range', '1200', '1299', null, 'any'),
    ('VC-IFRS-SME-SFP', 'A-C-OTH', 10, 'code_range', '1300', '1399', null, 'any'),
    ('VC-IFRS-SME-SFP', 'A-C-PRE', 10, 'code_range', '1400', '1499', null, 'any'),
    ('VC-IFRS-SME-SFP', 'A-C-CASH', 10, 'code_range', '1000', '1099', null, 'any'),
    ('VC-IFRS-SME-SFP', 'E-CAP', 10, 'code_range', '3000', '3199', null, 'any'),
    ('VC-IFRS-SME-SFP', 'E-RET', 10, 'code_range', '3200', '3299', null, 'any'),
    ('VC-IFRS-SME-SFP', 'E-RESULT', 10, 'code_range', '4000', '4699', null, 'any'),
    ('VC-IFRS-SME-SFP', 'E-RESULT', 20, 'code_range', '4700', '4799', null, 'any'),
    ('VC-IFRS-SME-SFP', 'E-RESULT', 30, 'code_range', '5000', '5099', null, 'any'),
    ('VC-IFRS-SME-SFP', 'E-RESULT', 40, 'code_range', '6000', '6899', null, 'any'),
    ('VC-IFRS-SME-SFP', 'L-NC', 10, 'code_range', '2300', '2399', null, 'any'),
    ('VC-IFRS-SME-SFP', 'L-C-PAY', 10, 'code_range', '2000', '2059', null, 'any'),
    ('VC-IFRS-SME-SFP', 'L-C-TAX', 10, 'code_range', '2060', '2069', null, 'any'),
    ('VC-IFRS-SME-SFP', 'L-C-TAX', 20, 'code_range', '2100', '2199', null, 'any'),
    ('VC-IFRS-SME-SFP', 'L-C-OTH', 10, 'code_range', '2070', '2099', null, 'any'),
    ('VC-IFRS-SME-SFP', 'L-C-OTH', 20, 'code_range', '2200', '2299', null, 'any')
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
  ('VC', 'Saint Vincent and the Grenadines', '{}'::jsonb, array['en']::text[], 'XCD', '1100', '2000', '2090', '6490', '3200', '4000', '5010', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6450', '4750', '6460', null, null, '2100', '1172', null, 'month'::declaration_period)
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
  numbering_legal_reference     = 'Value Added Tax Act, Cap. 445, s. 32 — a registered supplier making a taxable supply to a registered recipient issues an original VAT invoice at the time of the supply, with the information the Regulations prescribe (a sales receipt may stand in for a supply paid in money not exceeding fifty dollars); s. 33 — to a recipient who is not registered the supplier issues a sales receipt and may not issue a VAT invoice; s. 34 — VAT credit and debit notes. The Act, as read for this pack, does not say that the series of numbers may have no gap, which is why `numbering` is `sequential` and not `gapless`; `number_format` is a convention this pack proposes. The particulars are in the Regulations, which were not read, and are not printed as mentions. The distinction between VAT invoice and sales receipt is the user''s',
  numbering_source_key          = 'vc-vat-act',
  payment_terms_legal_reference = 'No text of Saint Vincent and the Grenadines read for this pack sets a payment term between two businesses or a rate of interest on a commercial debt paid late: the interest of 1.5 % a month on tax paid late (Department''s page "Taxes") and the late payment penalty of s. 41(3) are charges on the taxable person towards the Comptroller, not a term between two businesses. `legal_payment_days` and `late_payment_reference` are empty',
  payment_terms_source_key      = 'vc-vat-act',
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Value Added Tax Act, Cap. 445, s. 13 (time of supply) — the section was read in its title only: the particular cases are not modelled. `earliest_of_delivery_or_payment` is the nearest value of the closed vocabulary and is to be checked against s. 13 by a reviewer',
  tax_point_source_key          = 'vc-vat-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No text of Saint Vincent and the Grenadines read for this pack obliges a business to issue or accept an electronic invoice: the Value Added Tax Act, Cap. 445, s. 32 asks for a VAT invoice with the information the Regulations prescribe, without naming a platform, a format or a Peppol profile. No Peppol authority was looked for. `profile`, `party_scheme` and `vat_scheme` are null: there is no domestic profile to name',
  einvoice_source_key           = 'vc-vat-act',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'VC';

update country_defaults set
  tax_payee_name       = 'Inland Revenue Department',
  tax_payee_source_key = 'vc-ird-portal'
 where country = 'VC';
