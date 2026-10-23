-- Ekwo OS — Saint Kitts and Nevis: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/kn at version 0.2.0, do not edit.
-- Change the pack and run `ekwo pack build kn`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Value Added Tax Act, 2010 (No. 3 of 2010), with its First, Second and Third Schedules, as published by the National Information Agency; later amendments, if any, are not applied (Government of Saint Christopher and Nevis (National Information Agency))
--     https://nia.gov.kn/wp-content/uploads/2026/07/Value-Added-Tax-Act-2010.pdf
--   Value Added Tax Regulations, 2011 (S.R.O. No. 38 of 2011, passed 14 July 2011) — reduced rates for accommodation, tour operators and restaurants (regulations 9 to 11), zero-rated foods; amended in 2015 (S.R.O. No. 12 of 2015) (Inland Revenue Department, Government of Saint Christopher and Nevis)
--     https://www.sknird.com/wp-content/uploads/2018/04/NO.-38-OF-2011-PASSED-ON-14TH-DAY-OF-JULY-2011.pdf
--   Introduction to VAT — the three rates (17 %, 10 %, 0 %), examples of zero-rated and exempt supplies (Inland Revenue Department, Government of Saint Christopher and Nevis)
--     https://www.sknird.com/wp-content/uploads/2020/09/IRD-VAT-VAT-Introduction.pdf
--   IFRS for SMEs Accounting Standard (IFRS Foundation / International Accounting Standards Board)
--     https://www.ifrs.org/issued-standards/ifrs-for-smes/
--   Website of the Inland Revenue Department, the Comptroller of Inland Revenue's administration (forms, notices and the electronic services) (Inland Revenue Department, Government of Saint Christopher and Nevis)
--     https://www.sknird.com
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('KN', 'Saint Kitts and Nevis', '0.2.0', date '2026-10-23', '20261023124650', 'community', null, null, '0f7748b8a5d7e54f5b0a6d9fde57c2d08b5a5ca1995eb8f3dab1ffeeba7c41e8', '[{"key":"kn-vat-act","title":"Value Added Tax Act, 2010 (No. 3 of 2010), with its First, Second and Third Schedules, as published by the National Information Agency; later amendments, if any, are not applied","publisher":"Government of Saint Christopher and Nevis (National Information Agency)","url":"https://nia.gov.kn/wp-content/uploads/2026/07/Value-Added-Tax-Act-2010.pdf","consulted_on":"2026-10-19","kind":"law"},{"key":"kn-vat-regs-2011","title":"Value Added Tax Regulations, 2011 (S.R.O. No. 38 of 2011, passed 14 July 2011) — reduced rates for accommodation, tour operators and restaurants (regulations 9 to 11), zero-rated foods; amended in 2015 (S.R.O. No. 12 of 2015)","publisher":"Inland Revenue Department, Government of Saint Christopher and Nevis","url":"https://www.sknird.com/wp-content/uploads/2018/04/NO.-38-OF-2011-PASSED-ON-14TH-DAY-OF-JULY-2011.pdf","consulted_on":"2026-10-19","kind":"regulation"},{"key":"kn-ird-vat-intro","title":"Introduction to VAT — the three rates (17 %, 10 %, 0 %), examples of zero-rated and exempt supplies","publisher":"Inland Revenue Department, Government of Saint Christopher and Nevis","url":"https://www.sknird.com/wp-content/uploads/2020/09/IRD-VAT-VAT-Introduction.pdf","consulted_on":"2026-10-19","kind":"guidance"},{"key":"iasb-ifrs-sme","title":"IFRS for SMEs Accounting Standard","publisher":"IFRS Foundation / International Accounting Standards Board","url":"https://www.ifrs.org/issued-standards/ifrs-for-smes/","consulted_on":"2026-10-19","kind":"standard"},{"key":"kn-ird-portal","title":"Website of the Inland Revenue Department, the Comptroller of Inland Revenue''s administration (forms, notices and the electronic services)","publisher":"Inland Revenue Department, Government of Saint Christopher and Nevis","url":"https://www.sknird.com","consulted_on":"2026-10-19","kind":"portal"}]'::jsonb)
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
  ('KN', 'default', 'Saint Kitts and Nevis reference chart of accounts', '{}'::jsonb, true, 'companies', array['KN-IFRS-SME-IS', 'KN-IFRS-SME-SFP']::text[], null, 'This pack found no legal chart of accounts in Saint Christopher and Nevis, and opened neither the Companies Act nor the Income Tax Act: no section of either is cited. What the Value Added Tax Act, 2010 asks of a registered person is a tax invoice (s. 43) and records kept for six years (s. 79). This chart is original: four digits, blocked so that each range reaches one line of a statement of financial position and an income statement presented in the manner of IFRS for SMEs, which is a choice of this pack and not a text the country imposes. The settlement account of the VAT return (2100, refundable 1172) is distinct from the accounts the tax posts to (2101, 2102 and 2103 collected, 1170 and 1171 recoverable). See README.md', 'kn-vat-act')
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
  ('KN', 'default', '1000', 'Cash on hand', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('KN', 'default', '1010', 'Bank current account', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('KN', 'default', '1020', 'Bank savings account', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('KN', 'default', '1030', 'Foreign currency bank account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('KN', 'default', '1040', 'Payment gateway and card clearing account', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('KN', 'default', '1050', 'Fixed deposits of three months or less', '{}'::jsonb, 'asset_cash', false, null, 60),
  ('KN', 'default', '1060', 'Cash in transit', '{}'::jsonb, 'asset_cash', false, null, 70),
  ('KN', 'default', '1100', 'Trade debtors', '{}'::jsonb, 'asset_receivable', true, null, 80),
  ('KN', 'default', '1105', 'Allowance for expected credit losses', '{}'::jsonb, 'asset_current', false, null, 90),
  ('KN', 'default', '1110', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 100),
  ('KN', 'default', '1120', 'Other debtors', '{}'::jsonb, 'asset_current', false, null, 110),
  ('KN', 'default', '1130', 'Accrued income', '{}'::jsonb, 'asset_current', false, null, 120),
  ('KN', 'default', '1140', 'Staff advances and loans to employees', '{}'::jsonb, 'asset_current', false, null, 130),
  ('KN', 'default', '1150', 'Customs duty deposits paid', '{}'::jsonb, 'asset_current', false, null, 140),
  ('KN', 'default', '1160', 'Corporation tax recoverable', '{}'::jsonb, 'asset_current', false, null, 150),
  ('KN', 'default', '1170', 'VAT recoverable — local purchases', '{}'::jsonb, 'asset_current', false, null, 160),
  ('KN', 'default', '1171', 'VAT recoverable — imports paid to the Comptroller of Customs', '{}'::jsonb, 'asset_current', false, null, 170),
  ('KN', 'default', '1172', 'VAT refundable — settlement of the return', '{}'::jsonb, 'asset_current', true, null, 180),
  ('KN', 'default', '1200', 'Inventory — raw materials and consumables', '{}'::jsonb, 'asset_current', false, null, 190),
  ('KN', 'default', '1210', 'Inventory — work in progress', '{}'::jsonb, 'asset_current', false, null, 200),
  ('KN', 'default', '1220', 'Inventory — finished goods and goods for resale', '{}'::jsonb, 'asset_current', false, null, 210),
  ('KN', 'default', '1230', 'Goods in transit', '{}'::jsonb, 'asset_current', false, null, 220),
  ('KN', 'default', '1300', 'Fixed deposits of more than three months', '{}'::jsonb, 'asset_current', false, null, 230),
  ('KN', 'default', '1310', 'Listed investments held for trading', '{}'::jsonb, 'asset_current', false, null, 240),
  ('KN', 'default', '1320', 'Amounts due from related companies — non-trade', '{}'::jsonb, 'asset_current', false, null, 250),
  ('KN', 'default', '1400', 'Prepaid expenses', '{}'::jsonb, 'asset_prepayments', false, null, 260),
  ('KN', 'default', '1410', 'Rental and utility deposits paid', '{}'::jsonb, 'asset_prepayments', false, null, 270),
  ('KN', 'default', '1420', 'Deposits paid to suppliers', '{}'::jsonb, 'asset_prepayments', false, null, 280),
  ('KN', 'default', '1600', 'Leasehold land and buildings', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('KN', 'default', '1610', 'Leasehold improvements', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('KN', 'default', '1620', 'Furniture and fixtures', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('KN', 'default', '1630', 'Office equipment', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('KN', 'default', '1640', 'Computer equipment and software', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('KN', 'default', '1650', 'Motor vehicles', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('KN', 'default', '1660', 'Plant and machinery', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('KN', 'default', '1670', 'Right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('KN', 'default', '1690', 'Accumulated depreciation — property plant and equipment', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('KN', 'default', '1695', 'Accumulated depreciation — right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 380),
  ('KN', 'default', '1800', 'Goodwill', '{}'::jsonb, 'asset_non_current', false, null, 390),
  ('KN', 'default', '1810', 'Other intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 400),
  ('KN', 'default', '1820', 'Accumulated amortisation — intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 410),
  ('KN', 'default', '1900', 'Investments in subsidiaries', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('KN', 'default', '1910', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('KN', 'default', '1920', 'Other long-term investments', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('KN', 'default', '1930', 'Rental and utility deposits — non-current', '{}'::jsonb, 'asset_non_current', false, null, 450),
  ('KN', 'default', '1990', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('KN', 'default', '2000', 'Trade creditors', '{}'::jsonb, 'liability_payable', true, null, 470),
  ('KN', 'default', '2010', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 480),
  ('KN', 'default', '2020', 'Accruals', '{}'::jsonb, 'liability_current', false, null, 490),
  ('KN', 'default', '2030', 'Customer deposits and advances received', '{}'::jsonb, 'liability_current', false, null, 500),
  ('KN', 'default', '2040', 'Salaries and wages payable', '{}'::jsonb, 'liability_current', false, null, 510),
  ('KN', 'default', '2050', 'National Insurance Scheme contributions payable', '{}'::jsonb, 'liability_current', false, null, 520),
  ('KN', 'default', '2060', 'Corporation tax payable', '{}'::jsonb, 'liability_current', false, null, 530),
  ('KN', 'default', '2070', 'Payroll deductions payable', '{}'::jsonb, 'liability_current', false, null, 540),
  ('KN', 'default', '2071', 'Customs duty payable', '{}'::jsonb, 'liability_current', false, null, 550),
  ('KN', 'default', '2072', 'Land tax payable', '{}'::jsonb, 'liability_current', false, null, 560),
  ('KN', 'default', '2073', 'Other government charges payable', '{}'::jsonb, 'liability_current', false, null, 570),
  ('KN', 'default', '2080', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 580),
  ('KN', 'default', '2090', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 590),
  ('KN', 'default', '2100', 'VAT payable — settlement of the return', '{}'::jsonb, 'liability_current', true, null, 600),
  ('KN', 'default', '2101', 'VAT collected — standard rate (17 %)', '{}'::jsonb, 'liability_current', false, null, 610),
  ('KN', 'default', '2102', 'VAT collected — accommodation rate', '{}'::jsonb, 'liability_current', false, null, 620),
  ('KN', 'default', '2103', 'VAT collected — restaurant and tour operator rate (10 %)', '{}'::jsonb, 'liability_current', false, null, 625),
  ('KN', 'default', '2200', 'Corporate credit card payable', '{}'::jsonb, 'liability_credit_card', false, null, 630),
  ('KN', 'default', '2300', 'Bank borrowings — non-current', '{}'::jsonb, 'liability_non_current', false, null, 640),
  ('KN', 'default', '2310', 'Lease liabilities — non-current', '{}'::jsonb, 'liability_non_current', false, null, 650),
  ('KN', 'default', '2320', 'Amounts due to shareholders — non-current', '{}'::jsonb, 'liability_non_current', false, null, 660),
  ('KN', 'default', '2390', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 670),
  ('KN', 'default', '3000', 'Issued and paid-up share capital', '{}'::jsonb, 'equity', false, null, 680),
  ('KN', 'default', '3100', 'Share premium', '{}'::jsonb, 'equity', false, null, 690),
  ('KN', 'default', '3110', 'Capital reserve', '{}'::jsonb, 'equity', false, null, 700),
  ('KN', 'default', '3200', 'Retained profits', '{}'::jsonb, 'equity_retained', false, null, 710),
  ('KN', 'default', '4000', 'Sale of goods', '{}'::jsonb, 'income', false, null, 720),
  ('KN', 'default', '4010', 'Rendering of services', '{}'::jsonb, 'income', false, null, 730),
  ('KN', 'default', '4700', 'Realised exchange gains', '{}'::jsonb, 'income_other', false, null, 740),
  ('KN', 'default', '4710', 'Unrealised exchange gains', '{}'::jsonb, 'income_other', false, null, 750),
  ('KN', 'default', '4720', 'Interest income', '{}'::jsonb, 'income_other', false, null, 760),
  ('KN', 'default', '4730', 'Sundry income', '{}'::jsonb, 'income_other', false, null, 770),
  ('KN', 'default', '4750', 'Gain on disposal of fixed assets', '{}'::jsonb, 'income_other', false, null, 780),
  ('KN', 'default', '5000', 'Cost of goods sold', '{}'::jsonb, 'expense_direct_cost', false, null, 790),
  ('KN', 'default', '5010', 'Purchases', '{}'::jsonb, 'expense_direct_cost', false, null, 800),
  ('KN', 'default', '5020', 'Freight inwards', '{}'::jsonb, 'expense_direct_cost', false, null, 810),
  ('KN', 'default', '5025', 'Customs duty on imports', '{}'::jsonb, 'expense_direct_cost', false, null, 820),
  ('KN', 'default', '5030', 'Direct labour', '{}'::jsonb, 'expense_direct_cost', false, null, 830),
  ('KN', 'default', '6000', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 840),
  ('KN', 'default', '6010', 'Staff salaries and wages', '{}'::jsonb, 'expense', false, null, 850),
  ('KN', 'default', '6020', 'Pension contributions', '{}'::jsonb, 'expense', false, null, 860),
  ('KN', 'default', '6025', 'Employer payroll contributions', '{}'::jsonb, 'expense', false, null, 870),
  ('KN', 'default', '6026', 'National Insurance Scheme — employer contribution', '{}'::jsonb, 'expense', false, null, 880),
  ('KN', 'default', '6030', 'Staff welfare and benefits', '{}'::jsonb, 'expense', false, null, 890),
  ('KN', 'default', '6100', 'Rent and rates', '{}'::jsonb, 'expense', false, null, 900),
  ('KN', 'default', '6110', 'Management fees and building outgoings', '{}'::jsonb, 'expense', false, null, 910),
  ('KN', 'default', '6120', 'Utilities', '{}'::jsonb, 'expense', false, null, 920),
  ('KN', 'default', '6130', 'Land tax', '{}'::jsonb, 'expense', false, null, 930),
  ('KN', 'default', '6200', 'Government fees, licences and company registry fees', '{}'::jsonb, 'expense', false, null, 940),
  ('KN', 'default', '6210', 'Auditor''s remuneration', '{}'::jsonb, 'expense', false, null, 950),
  ('KN', 'default', '6220', 'Accounting and company secretarial fees', '{}'::jsonb, 'expense', false, null, 960),
  ('KN', 'default', '6230', 'Legal and professional fees', '{}'::jsonb, 'expense', false, null, 970),
  ('KN', 'default', '6300', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 980),
  ('KN', 'default', '6310', 'Insurance', '{}'::jsonb, 'expense', false, null, 990),
  ('KN', 'default', '6320', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1000),
  ('KN', 'default', '6330', 'Travelling expenses', '{}'::jsonb, 'expense', false, null, 1010),
  ('KN', 'default', '6340', 'Entertainment expenses', '{}'::jsonb, 'expense', false, null, 1020),
  ('KN', 'default', '6350', 'Advertising and promotion', '{}'::jsonb, 'expense', false, null, 1030),
  ('KN', 'default', '6360', 'Printing, stationery and postage', '{}'::jsonb, 'expense', false, null, 1040),
  ('KN', 'default', '6370', 'Telecommunications', '{}'::jsonb, 'expense', false, null, 1050),
  ('KN', 'default', '6380', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1060),
  ('KN', 'default', '6390', 'Sundry office expenses', '{}'::jsonb, 'expense', false, null, 1070),
  ('KN', 'default', '6400', 'Allowance for expected credit losses charged', '{}'::jsonb, 'expense', false, null, 1080),
  ('KN', 'default', '6410', 'Interest expense on bank borrowings', '{}'::jsonb, 'expense', false, null, 1090),
  ('KN', 'default', '6420', 'Interest expense on lease liabilities', '{}'::jsonb, 'expense', false, null, 1100),
  ('KN', 'default', '6450', 'Realised exchange losses', '{}'::jsonb, 'expense', false, null, 1110),
  ('KN', 'default', '6455', 'Unrealised exchange losses', '{}'::jsonb, 'expense', false, null, 1120),
  ('KN', 'default', '6460', 'Loss on disposal of fixed assets', '{}'::jsonb, 'expense', false, null, 1130),
  ('KN', 'default', '6470', 'Corporation tax charge', '{}'::jsonb, 'expense', false, null, 1140),
  ('KN', 'default', '6480', 'Deferred tax charge', '{}'::jsonb, 'expense', false, null, 1150),
  ('KN', 'default', '6490', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1160),
  ('KN', 'default', '6800', 'Depreciation and amortisation', '{}'::jsonb, 'expense_depreciation', false, null, 1170)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('KN', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('KN', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('KN', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('KN', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('KN', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('KN', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('KN', 'KN-P-10', 'Purchase of accommodation, restaurant or tour services, VAT 10 %', '{}'::jsonb, 'Accommodation, restaurant or tour services bought for the business at the reduced rate', 'percent', 10, 'purchase', 'domestic', date '2010-07-01', null, 'Value Added Tax Act, 2010, s. 26(1)(d) and s. 39 — input tax at 10 percent is deductible on the same conditions as at 17 percent, subject to s. 40. Base to box 12, tax to box 14.', null, null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'kn-vat-act', null, null, null, null),
  ('KN', 'KN-P-17', 'Purchase, VAT 17 %', '{}'::jsonb, 'A purchase from a taxable person, standard-rated, with a tax invoice', 'percent', 17, 'purchase', 'domestic', date '2010-07-01', null, 'Value Added Tax Act, 2010, s. 39 — an input tax deduction for the tax paid on a purchase for the taxable activity, on a tax invoice (s. 43) or a credit or debit note (s. 44); the limits of s. 40 (allocation to exempt supplies, disallowed items) are the user''s. Base to box 12, tax to box 14.', null, null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'kn-vat-act', null, null, null, null),
  ('KN', 'KN-P-17-IMP', 'Import of goods, VAT 17 %', '{}'::jsonb, 'Goods imported: the VAT paid to the Comptroller of Customs', 'percent', 17, 'purchase', 'import', date '2010-07-01', null, 'Value Added Tax Act, 2010, s. 26(1)(b), s. 27 and s. 28 — 17 percent of the value of imported goods other than exempt imported goods (First Schedule), paid on the import declaration (s. 10); the tax paid is deductible under s. 39. The value for tax is the customs entry''s; the pack applies the rate to the invoice value it is given. Base to box 11, tax to box 13.', null, null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'kn-vat-act', null, null, null, null),
  ('KN', 'KN-P-EX', 'Purchase without VAT', '{}'::jsonb, 'A purchase of a zero-rated or exempt supply, or from a person who charges no VAT: no input tax to claim', 'percent', 0, 'purchase', 'exempt', date '2010-07-01', null, 'Value Added Tax Act, 2010, s. 33 and s. 34 — a zero-rated supply carries tax at zero per cent and an exempt supply none, so the purchaser has no input tax to deduct; the value is still reported among the purchases (box 12).', null, null, 110, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'kn-vat-act', null, null, null, null),
  ('KN', 'KN-S-0', 'Zero-rated supply (export)', '{}'::jsonb, 'An export of goods or a service consumed abroad, zero-rated', 'percent', 0, 'sale', 'export', date '2010-07-01', null, 'Value Added Tax Act, 2010, s. 33 and the Second Schedule — goods exported from Saint Christopher and Nevis (Part II) and the other supplies listed there are zero rated; the supplier must hold documentary proof acceptable to the Comptroller (s. 33(2)). A zero-rated supply is a taxable supply: the input tax of what produces it stays deductible (s. 39). Base to box 4.', 'G', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'kn-vat-act', null, null, null, null),
  ('KN', 'KN-S-10', 'Sale of accommodation, VAT 10 %', '{}'::jsonb, 'Hotel, guest house, inn or similar accommodation, or an apartment or room furnished with utilities, at the reduced rate', 'percent', 10, 'sale', 'domestic', date '2010-07-01', null, 'Value Added Tax Act, 2010, s. 26(1)(d)(i) and (ii) — to the extent provided in regulations, 10 percent of the value of accommodation services by a hotel, guest house, inn or similar establishment, and of accommodation in an apartment or room with utilities and furnishings provided by the lessor, not including services to a renter in a private home; Value Added Tax Regulations, 2011, regulation 9 (reduced rate on specified accommodations: the pack does not decide which accommodation qualifies). Base to box 2, tax to box 8.', 'S', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'kn-vat-act', null, null, null, null),
  ('KN', 'KN-S-10-R', 'Sale by a restaurant or tour operator, VAT 10 %', '{}'::jsonb, 'Supplies by a restaurant or a tour operator, as the regulations define them, at the reduced rate', 'percent', 10, 'sale', 'domestic', date '2010-07-01', null, 'Value Added Tax Act, 2010, s. 26(1)(d)(iii) and (iv) — to the extent provided in regulations, 10 percent of the value of supplies by a tour operator and by a restaurant, as defined in the regulations; Value Added Tax Regulations, 2011, regulations 10 (specified services by a tour operator) and 11 (specified supplies by a restaurant): the pack does not decide which supplies qualify. Base to box 3, tax to box 9.', 'S', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'kn-vat-regs-2011', null, null, null, null),
  ('KN', 'KN-S-17', 'Sale, VAT 17 %', '{}'::jsonb, 'A taxable supply made in Saint Christopher and Nevis by a taxable person, standard-rated', 'percent', 17, 'sale', 'domestic', date '2010-07-01', null, 'Value Added Tax Act, 2010, s. 26(1)(a) — 17 percent of the value of every taxable supply by a taxable person in Saint Christopher and Nevis (the same rate applies to imports, s. 26(1)(b)); s. 38 — the tax payable for a period is the output tax less the input tax deduction of s. 39. The base posts to box 1 net of the tax, the tax to box 7 (box numbers are this pack''s, see tax_report.json). valid_from is 1 July 2010 for the Act, whose commencement date was not read: a reviewer should confirm it. A secondary source reports a temporary cut of the rate to 13 % before a return to 17 % on 1 July 2025; no official text for it was found and the pack carries the 17 % of the Act.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'kn-vat-act', null, null, null, null),
  ('KN', 'KN-S-17-INC', 'Retail sale, VAT 17 %, the price includes the tax', '{}'::jsonb, 'A standard-rated sale whose price already holds the VAT', 'percent', 17, 'sale', 'domestic', date '2010-07-01', null, 'Value Added Tax Act, 2010, s. 26(1)(a) at 17 percent, and the tax fraction of s. 1 (the value of a supply whose price includes the tax is the price reduced by the tax fraction multiplied by the price) — what price_include does: 117.00 holds 100.00 and 17.00. Same boxes as KN-S-17.', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, true, false, null, 'kn-vat-act', null, null, null, null),
  ('KN', 'KN-S-EX', 'Exempt supply', '{}'::jsonb, 'A supply of the Third Schedule (financial services, insurance, education, health, residential rent, passenger transport, domestic water and electricity), outside the tax', 'percent', 0, 'sale', 'exempt', date '2010-07-01', null, 'Value Added Tax Act, 2010, s. 34 and the Third Schedule — supplies exempt ''to the extent provided in regulations'' include financial services and insurance, education services, international transport, most services of doctors and dentists, dwellings let for residence and domestic water; the Inland Revenue Department''s introduction also lists electricity. Where a supply is both exempt and zero-rated, zero-rating takes priority (s. 34(2)). The pack does not reproduce the Schedule. The input tax of what is acquired to make exempt supplies is not deductible (s. 40). Base to box 5.', 'E', null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'kn-vat-act', null, null, null, null),
  ('KN', 'KN-S-Z', 'Zero-rated supply in Saint Kitts and Nevis', '{}'::jsonb, 'A domestic supply of the Second Schedule at zero per cent (flour, sugar, milk, rice, oats, infant formula, diapers, plain bread, fuel)', 'percent', 0, 'sale', 'domestic', date '2010-07-01', null, 'Value Added Tax Act, 2010, s. 33 and the Second Schedule — among the supplies zero rated at home: certain foods by customs tariff heading (sugar, flour, milk, infant formula, oats), infant and adult disposable diapers, bread made in the Federation without added sweeteners, icing, fruit, chocolate or meat, and fuel (motor spirit, kerosene, gas oils, fuel oils, petroleum gases). The Inland Revenue Department lists rice among its examples. The pack does not reproduce the Schedule: the user checks the item against it. Base to box 4.', 'Z', null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'kn-vat-act', null, null, null, null)
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
    ('KN-P-10', 'invoice', 'base', 100, null, '12', array['12']::text[], 100, 'KN-VAT-RETURN', 10),
    ('KN-P-10', 'invoice', 'tax', 100, '1170', '14', array['14']::text[], 100, 'KN-VAT-RETURN', 20),
    ('KN-P-10', 'credit_note', 'base', 100, null, '12', array['12']::text[], -100, 'KN-VAT-RETURN', 10),
    ('KN-P-10', 'credit_note', 'tax', 100, '1170', '14', array['14']::text[], -100, 'KN-VAT-RETURN', 20),
    ('KN-P-17', 'invoice', 'base', 100, null, '12', array['12']::text[], 100, 'KN-VAT-RETURN', 10),
    ('KN-P-17', 'invoice', 'tax', 100, '1170', '14', array['14']::text[], 100, 'KN-VAT-RETURN', 20),
    ('KN-P-17', 'credit_note', 'base', 100, null, '12', array['12']::text[], -100, 'KN-VAT-RETURN', 10),
    ('KN-P-17', 'credit_note', 'tax', 100, '1170', '14', array['14']::text[], -100, 'KN-VAT-RETURN', 20),
    ('KN-P-17-IMP', 'invoice', 'base', 100, null, '11', array['11']::text[], 100, 'KN-VAT-RETURN', 10),
    ('KN-P-17-IMP', 'invoice', 'tax', 100, '1171', '13', array['13']::text[], 100, 'KN-VAT-RETURN', 20),
    ('KN-P-17-IMP', 'credit_note', 'base', 100, null, '11', array['11']::text[], -100, 'KN-VAT-RETURN', 10),
    ('KN-P-17-IMP', 'credit_note', 'tax', 100, '1171', '13', array['13']::text[], -100, 'KN-VAT-RETURN', 20),
    ('KN-P-EX', 'invoice', 'base', 100, null, '12', array['12']::text[], 100, 'KN-VAT-RETURN', 10),
    ('KN-P-EX', 'credit_note', 'base', 100, null, '12', array['12']::text[], -100, 'KN-VAT-RETURN', 10),
    ('KN-S-0', 'invoice', 'base', 100, null, '4', array['4']::text[], 100, 'KN-VAT-RETURN', 10),
    ('KN-S-0', 'credit_note', 'base', 100, null, '4', array['4']::text[], -100, 'KN-VAT-RETURN', 10),
    ('KN-S-10', 'invoice', 'base', 100, null, '2', array['2']::text[], 100, 'KN-VAT-RETURN', 10),
    ('KN-S-10', 'invoice', 'tax', 100, '2102', '8', array['8']::text[], 100, 'KN-VAT-RETURN', 20),
    ('KN-S-10', 'credit_note', 'base', 100, null, '2', array['2']::text[], -100, 'KN-VAT-RETURN', 10),
    ('KN-S-10', 'credit_note', 'tax', 100, '2102', '8', array['8']::text[], -100, 'KN-VAT-RETURN', 20),
    ('KN-S-10-R', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'KN-VAT-RETURN', 10),
    ('KN-S-10-R', 'invoice', 'tax', 100, '2103', '9', array['9']::text[], 100, 'KN-VAT-RETURN', 20),
    ('KN-S-10-R', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'KN-VAT-RETURN', 10),
    ('KN-S-10-R', 'credit_note', 'tax', 100, '2103', '9', array['9']::text[], -100, 'KN-VAT-RETURN', 20),
    ('KN-S-17', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'KN-VAT-RETURN', 10),
    ('KN-S-17', 'invoice', 'tax', 100, '2101', '7', array['7']::text[], 100, 'KN-VAT-RETURN', 20),
    ('KN-S-17', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'KN-VAT-RETURN', 10),
    ('KN-S-17', 'credit_note', 'tax', 100, '2101', '7', array['7']::text[], -100, 'KN-VAT-RETURN', 20),
    ('KN-S-17-INC', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'KN-VAT-RETURN', 10),
    ('KN-S-17-INC', 'invoice', 'tax', 100, '2101', '7', array['7']::text[], 100, 'KN-VAT-RETURN', 20),
    ('KN-S-17-INC', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'KN-VAT-RETURN', 10),
    ('KN-S-17-INC', 'credit_note', 'tax', 100, '2101', '7', array['7']::text[], -100, 'KN-VAT-RETURN', 20),
    ('KN-S-EX', 'invoice', 'base', 100, null, '5', array['5']::text[], 100, 'KN-VAT-RETURN', 10),
    ('KN-S-EX', 'credit_note', 'base', 100, null, '5', array['5']::text[], -100, 'KN-VAT-RETURN', 10),
    ('KN-S-Z', 'invoice', 'base', 100, null, '4', array['4']::text[], 100, 'KN-VAT-RETURN', 10),
    ('KN-S-Z', 'credit_note', 'base', 100, null, '4', array['4']::text[], -100, 'KN-VAT-RETURN', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'KN' and t.code = v.tax_code
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
  ('KN', 'KN-VAT-RETURN', 'VAT return (box layout of this pack)', array['month']::declaration_period[], 'month'::declaration_period, date '2010-07-01', null, 'Value Added Tax Act, 2010, s. 45 — the tax period is the calendar month; s. 46(1) — every taxable person files a tax return for each tax period with the Comptroller within fifteen calendar days after the end of the period, whether or not tax is payable; s. 46(2) — in the form and manner the Comptroller prescribes (the Inland Revenue Department''s form VAT-01 was not read as a text); s. 50 — the tax is due by the due date for the return.', true,'day_of_month_after_period'::filing_deadline_rule, 15, null, 'Value Added Tax Act, 2010, s. 46(1) and s. 50(1)(a) — the return is filed within fifteen calendar days after the end of the tax period and the tax is due by the same date: for a month, the 15th of the next month. Unpaid tax bears interest at 1.25 % a month or part of a month (s. 42); the penalties for a late return are not modelled. An extension of time to file does not move the date of payment (s. 47(2)). Weekend roll-forward is not expressible', 'kn-vat-act', null)
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
  ('KN', 'KN-VAT-RETURN', '1', 'base', 'Standard-rated supplies (17 %), net of VAT', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Taxable supplies at 17 percent (s. 26(1)(a)). Box number and label are this pack''s own: the layout of form VAT-01 was not read as a text, so the boxes follow what the Act makes the tax payable carry — the output tax of the period less the input tax deduction allowed (s. 38(1)).', 'kn-vat-act'),
  ('KN', 'KN-VAT-RETURN', '2', 'base', 'Accommodation supplies (10 %), net of VAT', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Taxable supplies of accommodation at 10 percent (s. 26(1)(d)(i), (ii)).', 'kn-vat-act'),
  ('KN', 'KN-VAT-RETURN', '3', 'base', 'Restaurant and tour operator supplies (10 %), net of VAT', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Taxable supplies by a restaurant or a tour operator at 10 percent (s. 26(1)(d)(iii), (iv); Regulations 2011, regulations 10 and 11).', 'kn-vat-regs-2011'),
  ('KN', 'KN-VAT-RETURN', '4', 'base', 'Zero-rated supplies, including exports', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Taxable supplies at zero percent (s. 33; Second Schedule); they stay on the return (s. 46(1) asks for a return even when no tax is payable).', 'kn-vat-act'),
  ('KN', 'KN-VAT-RETURN', '5', 'base', 'Exempt supplies', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Supplies of the Third Schedule (s. 34), reported for information; the input tax of what is acquired to make them is not deductible (s. 40).', 'kn-vat-act'),
  ('KN', 'KN-VAT-RETURN', '6', 'total', 'Total supplies', '{}'::jsonb, 60, null, array['1', '2', '3', '4', '5']::text[], '{}'::text[], null, null, false, false, null, 'Sum of boxes 1 to 5 — the sum is this pack''s reading, the form is the Comptroller''s (s. 46(2)).', 'kn-vat-act'),
  ('KN', 'KN-VAT-RETURN', '7', 'tax', 'Output tax on standard-rated supplies', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tax at 17 % on box 1 (s. 26(1)(a)).', 'kn-vat-act'),
  ('KN', 'KN-VAT-RETURN', '8', 'tax', 'Output tax on accommodation', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tax at 10 % on box 2 (s. 26(1)(d)).', 'kn-vat-act'),
  ('KN', 'KN-VAT-RETURN', '9', 'tax', 'Output tax on restaurant and tour operator supplies', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tax at 10 % on box 3 (s. 26(1)(d)).', 'kn-vat-regs-2011'),
  ('KN', 'KN-VAT-RETURN', '10', 'total', 'Total output tax for the period', '{}'::jsonb, 100, null, array['7', '8', '9']::text[], '{}'::text[], null, null, false, false, null, 'The output tax payable on the taxable supplies of the period (s. 38(1)); a credit note posts a negative amount to its own boxes (s. 44).', 'kn-vat-act'),
  ('KN', 'KN-VAT-RETURN', '11', 'base', 'Value of imports', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Goods imported on which tax was paid to the Comptroller of Customs (s. 10, s. 26(1)(b)).', 'kn-vat-act'),
  ('KN', 'KN-VAT-RETURN', '12', 'base', 'Value of local purchases', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Purchases made in Saint Christopher and Nevis for the taxable activity, taxable, zero-rated and exempt.', 'kn-vat-act'),
  ('KN', 'KN-VAT-RETURN', '13', 'tax', 'VAT paid on imports', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tax paid on imported goods, deductible as input tax for a taxable activity (s. 39).', 'kn-vat-act'),
  ('KN', 'KN-VAT-RETURN', '14', 'tax', 'VAT paid on local purchases', '{}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tax charged on purchases, deductible on a tax invoice (s. 39, s. 43).', 'kn-vat-act'),
  ('KN', 'KN-VAT-RETURN', '15', 'total', 'Total input tax deduction for the period', '{}'::jsonb, 150, null, array['13', '14']::text[], '{}'::text[], null, null, false, false, null, 'Sum of boxes 13 and 14: the input tax deduction allowed for the period (s. 38(1), s. 39).', 'kn-vat-act'),
  ('KN', 'KN-VAT-RETURN', '16', 'total', 'VAT payable', '{}'::jsonb, 160, null, array['10']::text[], array['15']::text[], null, null, true, false, null, 'Output tax less the input tax deduction when positive (s. 38(1)), due by the date the return is due (s. 50(1)(a)). Interest (s. 42) and penalties are not modelled.', 'kn-vat-act'),
  ('KN', 'KN-VAT-RETURN', '17', 'total', 'VAT refundable', '{}'::jsonb, 170, null, array['15']::text[], array['10']::text[], null, null, true, false, null, 'The excess of the input tax deduction over the output tax (s. 38(2)), dealt with under s. 61 (carry forward of excess credits and refund of tax), whose conditions the pack does not model. The pack only reports box 17.', 'kn-vat-act')
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
  ('KN-IFRS-SME-IS', 'KN', 'default', 'Income statement', 'income_statement', 'IFRS-SME', date '1970-01-01', null, 'Same choice as the statement of financial position: the income statement is presented in the manner of IFRS for SMEs, section 5, with the expenses collapsed to cost of sales, other operating expenses and depreciation. No text of Saint Christopher and Nevis read prescribes it. The corporate income tax charge (6470) falls in other operating expenses; the Income Tax Act was not opened and the tax is not modelled', 'iasb-ifrs-sme', null, null, '{}'::jsonb),
  ('KN-IFRS-SME-SFP', 'KN', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS-SME', date '1970-01-01', null, 'The Companies Act and the Income Tax Act of Saint Christopher and Nevis were not opened for this pack, so no section of either is cited, and none is asserted to prescribe a layout. This statement follows the presentation of IFRS for SMEs (International Accounting Standards Board), section 4: current and non-current assets and liabilities, with equity shown beside them; that is a choice of this pack, not a text the country imposes, and a company reporting under full IFRS presents the same balance sheet with different notes. The numbering and the ranges each line reads are original to this pack. The VAT collected (2100 to 2199) is a current tax liability; the VAT recoverable sits with the receivables (1170 to 1172), unnetted. Cash flows and changes in equity are separate statements this pack does not model', 'iasb-ifrs-sme', 'alone', null, '{}'::jsonb)
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
  ('KN-IFRS-SME-IS', 'REV', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KN-IFRS-SME-IS', 'COST', null, 'Cost of sales', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KN-IFRS-SME-IS', 'GROSS', null, 'Gross profit', '{}'::jsonb, 30, 1, true, array['REV']::text[], array['COST']::text[], null, null, null),
  ('KN-IFRS-SME-IS', 'OTH-INC', null, 'Other income', '{}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KN-IFRS-SME-IS', 'OPEX', null, 'Administrative and other operating expenses', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KN-IFRS-SME-IS', 'DEPR', null, 'Depreciation and amortisation', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KN-IFRS-SME-IS', 'PROFIT', null, 'Profit (loss) for the year', '{}'::jsonb, 70, 1, true, array['GROSS', 'OTH-INC']::text[], array['OPEX', 'DEPR']::text[], null, null, null),
  ('KN-IFRS-SME-SFP', 'A-NC-FIX', 'A-NC', 'Property, plant and equipment', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KN-IFRS-SME-SFP', 'A-NC-INT', 'A-NC', 'Goodwill and other intangible assets', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KN-IFRS-SME-SFP', 'A-NC-OTH', 'A-NC', 'Other non-current assets', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KN-IFRS-SME-SFP', 'A-NC', null, 'Non-current assets', '{}'::jsonb, 40, 1, true, array['A-NC-FIX', 'A-NC-INT', 'A-NC-OTH']::text[], '{}'::text[], null, null, null),
  ('KN-IFRS-SME-SFP', 'A-C-REC', 'A-C', 'Trade and other receivables', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KN-IFRS-SME-SFP', 'A-C-INV', 'A-C', 'Inventories', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KN-IFRS-SME-SFP', 'A-C-OTH', 'A-C', 'Other current assets', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KN-IFRS-SME-SFP', 'A-C-PRE', 'A-C', 'Prepayments and deposits paid', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KN-IFRS-SME-SFP', 'A-C-CASH', 'A-C', 'Cash and cash equivalents', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KN-IFRS-SME-SFP', 'A-C', null, 'Current assets', '{}'::jsonb, 100, 1, true, array['A-C-REC', 'A-C-INV', 'A-C-OTH', 'A-C-PRE', 'A-C-CASH']::text[], '{}'::text[], null, null, null),
  ('KN-IFRS-SME-SFP', 'A-TOT', null, 'Total assets', '{}'::jsonb, 110, 1, true, array['A-NC', 'A-C']::text[], '{}'::text[], null, null, null),
  ('KN-IFRS-SME-SFP', 'E-CAP', 'E-TOT', 'Share capital and reserves', '{}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KN-IFRS-SME-SFP', 'E-RET', 'E-TOT', 'Retained earnings', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KN-IFRS-SME-SFP', 'E-RESULT', 'E-TOT', 'Profit or loss for the year, not yet allocated', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KN-IFRS-SME-SFP', 'E-TOT', null, 'Total equity', '{}'::jsonb, 150, 1, true, array['E-CAP', 'E-RET', 'E-RESULT']::text[], '{}'::text[], null, null, null),
  ('KN-IFRS-SME-SFP', 'L-NC', 'L-TOT', 'Non-current liabilities', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KN-IFRS-SME-SFP', 'L-C-PAY', 'L-C', 'Trade and other payables', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KN-IFRS-SME-SFP', 'L-C-TAX', 'L-C', 'Current tax liabilities, including VAT collected', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KN-IFRS-SME-SFP', 'L-C-OTH', 'L-C', 'Other current liabilities', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KN-IFRS-SME-SFP', 'L-C', null, 'Current liabilities', '{}'::jsonb, 200, 1, true, array['L-C-PAY', 'L-C-TAX', 'L-C-OTH']::text[], '{}'::text[], null, null, null),
  ('KN-IFRS-SME-SFP', 'L-TOT', null, 'Total liabilities', '{}'::jsonb, 210, 1, true, array['L-NC', 'L-C']::text[], '{}'::text[], null, null, null),
  ('KN-IFRS-SME-SFP', 'EL-TOT', null, 'Total equity and liabilities', '{}'::jsonb, 220, 1, true, array['E-TOT', 'L-TOT']::text[], '{}'::text[], null, null, null)
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
 where r.statement_code in ('KN-IFRS-SME-IS', 'KN-IFRS-SME-SFP')
   and (r.statement_code, r.line_code, r.sequence) not in (
     values ('KN-IFRS-SME-IS', 'REV', 10),
            ('KN-IFRS-SME-IS', 'COST', 10),
            ('KN-IFRS-SME-IS', 'OTH-INC', 10),
            ('KN-IFRS-SME-IS', 'OPEX', 10),
            ('KN-IFRS-SME-IS', 'DEPR', 10),
            ('KN-IFRS-SME-SFP', 'A-NC-FIX', 10),
            ('KN-IFRS-SME-SFP', 'A-NC-INT', 10),
            ('KN-IFRS-SME-SFP', 'A-NC-OTH', 10),
            ('KN-IFRS-SME-SFP', 'A-C-REC', 10),
            ('KN-IFRS-SME-SFP', 'A-C-INV', 10),
            ('KN-IFRS-SME-SFP', 'A-C-OTH', 10),
            ('KN-IFRS-SME-SFP', 'A-C-PRE', 10),
            ('KN-IFRS-SME-SFP', 'A-C-CASH', 10),
            ('KN-IFRS-SME-SFP', 'E-CAP', 10),
            ('KN-IFRS-SME-SFP', 'E-RET', 10),
            ('KN-IFRS-SME-SFP', 'E-RESULT', 10),
            ('KN-IFRS-SME-SFP', 'E-RESULT', 20),
            ('KN-IFRS-SME-SFP', 'E-RESULT', 30),
            ('KN-IFRS-SME-SFP', 'E-RESULT', 40),
            ('KN-IFRS-SME-SFP', 'L-NC', 10),
            ('KN-IFRS-SME-SFP', 'L-C-PAY', 10),
            ('KN-IFRS-SME-SFP', 'L-C-TAX', 10),
            ('KN-IFRS-SME-SFP', 'L-C-TAX', 20),
            ('KN-IFRS-SME-SFP', 'L-C-OTH', 10),
            ('KN-IFRS-SME-SFP', 'L-C-OTH', 20)
   );

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('KN-IFRS-SME-IS', 'REV', 10, 'code_range', '4000', '4699', null, 'any'),
    ('KN-IFRS-SME-IS', 'COST', 10, 'code_range', '5000', '5099', null, 'any'),
    ('KN-IFRS-SME-IS', 'OTH-INC', 10, 'code_range', '4700', '4799', null, 'any'),
    ('KN-IFRS-SME-IS', 'OPEX', 10, 'code_range', '6000', '6799', null, 'any'),
    ('KN-IFRS-SME-IS', 'DEPR', 10, 'code_range', '6800', '6899', null, 'any'),
    ('KN-IFRS-SME-SFP', 'A-NC-FIX', 10, 'code_range', '1600', '1799', null, 'any'),
    ('KN-IFRS-SME-SFP', 'A-NC-INT', 10, 'code_range', '1800', '1899', null, 'any'),
    ('KN-IFRS-SME-SFP', 'A-NC-OTH', 10, 'code_range', '1900', '1999', null, 'any'),
    ('KN-IFRS-SME-SFP', 'A-C-REC', 10, 'code_range', '1100', '1199', null, 'any'),
    ('KN-IFRS-SME-SFP', 'A-C-INV', 10, 'code_range', '1200', '1299', null, 'any'),
    ('KN-IFRS-SME-SFP', 'A-C-OTH', 10, 'code_range', '1300', '1399', null, 'any'),
    ('KN-IFRS-SME-SFP', 'A-C-PRE', 10, 'code_range', '1400', '1499', null, 'any'),
    ('KN-IFRS-SME-SFP', 'A-C-CASH', 10, 'code_range', '1000', '1099', null, 'any'),
    ('KN-IFRS-SME-SFP', 'E-CAP', 10, 'code_range', '3000', '3199', null, 'any'),
    ('KN-IFRS-SME-SFP', 'E-RET', 10, 'code_range', '3200', '3299', null, 'any'),
    ('KN-IFRS-SME-SFP', 'E-RESULT', 10, 'code_range', '4000', '4699', null, 'any'),
    ('KN-IFRS-SME-SFP', 'E-RESULT', 20, 'code_range', '4700', '4799', null, 'any'),
    ('KN-IFRS-SME-SFP', 'E-RESULT', 30, 'code_range', '5000', '5099', null, 'any'),
    ('KN-IFRS-SME-SFP', 'E-RESULT', 40, 'code_range', '6000', '6899', null, 'any'),
    ('KN-IFRS-SME-SFP', 'L-NC', 10, 'code_range', '2300', '2399', null, 'any'),
    ('KN-IFRS-SME-SFP', 'L-C-PAY', 10, 'code_range', '2000', '2059', null, 'any'),
    ('KN-IFRS-SME-SFP', 'L-C-TAX', 10, 'code_range', '2060', '2069', null, 'any'),
    ('KN-IFRS-SME-SFP', 'L-C-TAX', 20, 'code_range', '2100', '2199', null, 'any'),
    ('KN-IFRS-SME-SFP', 'L-C-OTH', 10, 'code_range', '2070', '2099', null, 'any'),
    ('KN-IFRS-SME-SFP', 'L-C-OTH', 20, 'code_range', '2200', '2299', null, 'any')
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
  ('KN', 'Saint Kitts and Nevis', '{}'::jsonb, array['en']::text[], 'XCD', '1100', '2000', '2090', '6490', '3200', '4000', '5010', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6450', '4750', '6460', null, null, '2100', '1172', null, 'month'::declaration_period)
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
  numbering_legal_reference     = 'Value Added Tax Act, 2010, s. 43 — tax invoices and sales receipts (a registered supplier issues one original tax invoice for each taxable supply, in the form and with the information the regulations prescribe), and s. 44 — tax credit and debit notes. The Act, as read for this pack, does not say that the series of invoice numbers may have no gap, which is why `numbering` is `sequential` and not `gapless`; `number_format` is a convention this pack proposes. The particulars of a tax invoice are in the regulations and are not printed as mentions',
  numbering_source_key          = 'kn-vat-act',
  payment_terms_legal_reference = 'No text of Saint Christopher and Nevis read for this pack sets a payment term between two businesses or a rate of interest on a commercial debt paid late: the interest of 1.25 % a month (s. 42) is a charge on the taxable person towards the Comptroller, not a term between two businesses. `legal_payment_days` and `late_payment_reference` are empty',
  payment_terms_source_key      = 'kn-vat-act',
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Value Added Tax Act, 2010, s. 35 — a supply occurs on the earliest of the date the goods are delivered or made available or the performance of the services begins, the date an invoice is issued and the date a payment is received (the section was read in its opening lines only: the particular cases are not modelled). `earliest_of_delivery_or_payment` is the nearest value of the closed vocabulary and is to be checked against s. 35 by a reviewer',
  tax_point_source_key          = 'kn-vat-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No text of Saint Christopher and Nevis read for this pack obliges a business to issue or accept an electronic invoice: the Value Added Tax Act, 2010, s. 43 asks for a tax invoice in the form the regulations prescribe, without naming a platform, a format or a Peppol profile. No Peppol authority for the Federation was looked for. `profile`, `party_scheme` and `vat_scheme` are null: there is no domestic profile to name',
  einvoice_source_key           = 'kn-vat-act',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'KN';

update country_defaults set
  tax_payee_name       = 'Inland Revenue Department',
  tax_payee_source_key = 'kn-ird-portal'
 where country = 'KN';
