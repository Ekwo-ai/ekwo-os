-- Ekwo OS — Jamaica: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/jm at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build jm`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Form 4A, General Consumption Tax Return (revision of 3 June 2025) and its instructions — the lines of the standard return (Tax Administration Jamaica, Ministry of Finance and the Public Service)
--     https://www.jamaicatax.gov.jm/documents/10194/18006/GCT+Form+4A+amended+03.06.2025+%28002%29.pdf/b2428c2a-346f-6eeb-0b18-550ec5b60d72
--   General Consumption Tax — how the GCT works: rates for telephone services and tourism, registration threshold of $15,000,000 from 1 April 2025, credit and refund, tax invoice. The page also still carries the former 16.5 % standard rate: the rate used is the one of the Advanced GCT document (Tax Administration Jamaica, Ministry of Finance and the Public Service)
--     https://www.jamaicatax.gov.jm/general-consumption-tax1
--   Advanced GCT — states that the standard rate of 15 % came into effect on 1 April 2020, from 16.5 % before (Tax Administration Jamaica, Ministry of Finance and the Public Service)
--     https://www.jamaicatax.gov.jm/documents/10194/24445204/GCT+_ADVANCED_GCT_Document_(amended)_032021.pdf/d9bd3526-b29a-a617-5528-27063fddb678
--   General Consumption Tax forms — Forms 1 (registration), 4A, 4C, 4D, 4E, 4G, 4H, the return period and the due date of each (Tax Administration Jamaica, Ministry of Finance and the Public Service)
--     https://www.jamaicatax.gov.jm/web/guest/general-consumption-tax
--   New filing due date for monthly GCT returns now in effect — returns and payments due on the last working day of the month, from 1 October 2014 (Jamaica Information Service)
--     https://jis.gov.jm/new-filing-due-date-monthly-gct-returns-now-effect/
--   GCT exemption threshold for MSMEs increased to $15 million (Jamaica Information Service)
--     https://jis.gov.jm/gct-exemption-threshold-for-msmes-increased-to-15-million/
--   IFRS for SMEs Accounting Standard (IFRS Foundation / International Accounting Standards Board)
--     https://www.ifrs.org/issued-standards/ifrs-for-smes/
--   TAJ Portal — the online service the GCT return is filed through (Tax Administration Jamaica, Ministry of Finance and the Public Service)
--     https://www.jamaicatax.gov.jm
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('JM', 'Jamaica', '0.1.0', date '2026-10-18', '20261011120000', 'community', null, null, '06d4a94dbc678641a68f15bbd43e0fdf345765c3b4012c88a75371ab4537922a', '[{"key":"jm-form-4a","title":"Form 4A, General Consumption Tax Return (revision of 3 June 2025) and its instructions — the lines of the standard return","publisher":"Tax Administration Jamaica, Ministry of Finance and the Public Service","url":"https://www.jamaicatax.gov.jm/documents/10194/18006/GCT+Form+4A+amended+03.06.2025+%28002%29.pdf/b2428c2a-346f-6eeb-0b18-550ec5b60d72","consulted_on":"2026-10-18","kind":"form"},{"key":"jm-tax-gct-page","title":"General Consumption Tax — how the GCT works: rates for telephone services and tourism, registration threshold of $15,000,000 from 1 April 2025, credit and refund, tax invoice. The page also still carries the former 16.5 % standard rate: the rate used is the one of the Advanced GCT document","publisher":"Tax Administration Jamaica, Ministry of Finance and the Public Service","url":"https://www.jamaicatax.gov.jm/general-consumption-tax1","consulted_on":"2026-10-18","kind":"guidance"},{"key":"jm-gct-advanced","title":"Advanced GCT — states that the standard rate of 15 % came into effect on 1 April 2020, from 16.5 % before","publisher":"Tax Administration Jamaica, Ministry of Finance and the Public Service","url":"https://www.jamaicatax.gov.jm/documents/10194/24445204/GCT+_ADVANCED_GCT_Document_(amended)_032021.pdf/d9bd3526-b29a-a617-5528-27063fddb678","consulted_on":"2026-10-18","kind":"guidance"},{"key":"jm-gct-forms","title":"General Consumption Tax forms — Forms 1 (registration), 4A, 4C, 4D, 4E, 4G, 4H, the return period and the due date of each","publisher":"Tax Administration Jamaica, Ministry of Finance and the Public Service","url":"https://www.jamaicatax.gov.jm/web/guest/general-consumption-tax","consulted_on":"2026-10-18","kind":"form"},{"key":"jm-jis-due-date","title":"New filing due date for monthly GCT returns now in effect — returns and payments due on the last working day of the month, from 1 October 2014","publisher":"Jamaica Information Service","url":"https://jis.gov.jm/new-filing-due-date-monthly-gct-returns-now-effect/","consulted_on":"2026-10-18","kind":"guidance"},{"key":"jm-jis-threshold","title":"GCT exemption threshold for MSMEs increased to $15 million","publisher":"Jamaica Information Service","url":"https://jis.gov.jm/gct-exemption-threshold-for-msmes-increased-to-15-million/","consulted_on":"2026-10-18","kind":"guidance"},{"key":"iasb-ifrs-sme","title":"IFRS for SMEs Accounting Standard","publisher":"IFRS Foundation / International Accounting Standards Board","url":"https://www.ifrs.org/issued-standards/ifrs-for-smes/","consulted_on":"2026-10-18","kind":"standard"},{"key":"jm-taj-portal","title":"TAJ Portal — the online service the GCT return is filed through","publisher":"Tax Administration Jamaica, Ministry of Finance and the Public Service","url":"https://www.jamaicatax.gov.jm","consulted_on":"2026-10-18","kind":"portal"}]'::jsonb)
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
  ('JM', 'default', 'Jamaica reference chart of accounts', '{}'::jsonb, true, 'companies', array['JM-IFRS-SME-IS', 'JM-IFRS-SME-SFP']::text[], null, 'This pack found no legal chart of accounts in Jamaica, and opened neither the Companies Act nor the Income Tax Act: no section of either is cited. What the General Consumption Tax Act asks of a registered taxpayer is a tax invoice and records, as Tax Administration Jamaica''s GCT page describes. This chart is original: four digits, blocked so that each range reaches one line of a statement of financial position and an income statement presented in the manner of IFRS for SMEs, which is a choice of this pack and not a text the country imposes. The settlement account of the GCT return (2100, refundable 1172) is distinct from the accounts the tax posts to (2101 and 2102 collected, 1170 and 1171 recoverable). See README.md', 'jm-tax-gct-page')
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
  ('JM', 'default', '1000', 'Cash on hand', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('JM', 'default', '1010', 'Bank current account', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('JM', 'default', '1020', 'Bank savings account', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('JM', 'default', '1030', 'Foreign currency bank account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('JM', 'default', '1040', 'Payment gateway and card clearing account', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('JM', 'default', '1050', 'Fixed deposits of three months or less', '{}'::jsonb, 'asset_cash', false, null, 60),
  ('JM', 'default', '1060', 'Cash in transit', '{}'::jsonb, 'asset_cash', false, null, 70),
  ('JM', 'default', '1100', 'Trade debtors', '{}'::jsonb, 'asset_receivable', true, null, 80),
  ('JM', 'default', '1105', 'Allowance for expected credit losses', '{}'::jsonb, 'asset_current', false, null, 90),
  ('JM', 'default', '1110', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 100),
  ('JM', 'default', '1120', 'Other debtors', '{}'::jsonb, 'asset_current', false, null, 110),
  ('JM', 'default', '1130', 'Accrued income', '{}'::jsonb, 'asset_current', false, null, 120),
  ('JM', 'default', '1140', 'Staff advances and loans to employees', '{}'::jsonb, 'asset_current', false, null, 130),
  ('JM', 'default', '1150', 'Customs duty deposits paid', '{}'::jsonb, 'asset_current', false, null, 140),
  ('JM', 'default', '1160', 'Corporation tax recoverable', '{}'::jsonb, 'asset_current', false, null, 150),
  ('JM', 'default', '1170', 'GCT recoverable — local purchases', '{}'::jsonb, 'asset_current', false, null, 160),
  ('JM', 'default', '1171', 'GCT recoverable — imports paid to the Commissioner of Customs', '{}'::jsonb, 'asset_current', false, null, 170),
  ('JM', 'default', '1172', 'GCT refundable — settlement of the return', '{}'::jsonb, 'asset_current', true, null, 180),
  ('JM', 'default', '1200', 'Inventory — raw materials and consumables', '{}'::jsonb, 'asset_current', false, null, 190),
  ('JM', 'default', '1210', 'Inventory — work in progress', '{}'::jsonb, 'asset_current', false, null, 200),
  ('JM', 'default', '1220', 'Inventory — finished goods and goods for resale', '{}'::jsonb, 'asset_current', false, null, 210),
  ('JM', 'default', '1230', 'Goods in transit', '{}'::jsonb, 'asset_current', false, null, 220),
  ('JM', 'default', '1300', 'Fixed deposits of more than three months', '{}'::jsonb, 'asset_current', false, null, 230),
  ('JM', 'default', '1310', 'Listed investments held for trading', '{}'::jsonb, 'asset_current', false, null, 240),
  ('JM', 'default', '1320', 'Amounts due from related companies — non-trade', '{}'::jsonb, 'asset_current', false, null, 250),
  ('JM', 'default', '1400', 'Prepaid expenses', '{}'::jsonb, 'asset_prepayments', false, null, 260),
  ('JM', 'default', '1410', 'Rental and utility deposits paid', '{}'::jsonb, 'asset_prepayments', false, null, 270),
  ('JM', 'default', '1420', 'Deposits paid to suppliers', '{}'::jsonb, 'asset_prepayments', false, null, 280),
  ('JM', 'default', '1600', 'Leasehold land and buildings', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('JM', 'default', '1610', 'Leasehold improvements', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('JM', 'default', '1620', 'Furniture and fixtures', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('JM', 'default', '1630', 'Office equipment', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('JM', 'default', '1640', 'Computer equipment and software', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('JM', 'default', '1650', 'Motor vehicles', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('JM', 'default', '1660', 'Plant and machinery', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('JM', 'default', '1670', 'Right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('JM', 'default', '1690', 'Accumulated depreciation — property plant and equipment', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('JM', 'default', '1695', 'Accumulated depreciation — right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 380),
  ('JM', 'default', '1800', 'Goodwill', '{}'::jsonb, 'asset_non_current', false, null, 390),
  ('JM', 'default', '1810', 'Other intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 400),
  ('JM', 'default', '1820', 'Accumulated amortisation — intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 410),
  ('JM', 'default', '1900', 'Investments in subsidiaries', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('JM', 'default', '1910', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('JM', 'default', '1920', 'Other long-term investments', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('JM', 'default', '1930', 'Rental and utility deposits — non-current', '{}'::jsonb, 'asset_non_current', false, null, 450),
  ('JM', 'default', '1990', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('JM', 'default', '2000', 'Trade creditors', '{}'::jsonb, 'liability_payable', true, null, 470),
  ('JM', 'default', '2010', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 480),
  ('JM', 'default', '2020', 'Accruals', '{}'::jsonb, 'liability_current', false, null, 490),
  ('JM', 'default', '2030', 'Customer deposits and advances received', '{}'::jsonb, 'liability_current', false, null, 500),
  ('JM', 'default', '2040', 'Salaries and wages payable', '{}'::jsonb, 'liability_current', false, null, 510),
  ('JM', 'default', '2050', 'National Insurance Scheme (NIS) contributions payable', '{}'::jsonb, 'liability_current', false, null, 520),
  ('JM', 'default', '2060', 'Corporation tax payable', '{}'::jsonb, 'liability_current', false, null, 530),
  ('JM', 'default', '2070', 'Payroll deductions payable', '{}'::jsonb, 'liability_current', false, null, 540),
  ('JM', 'default', '2071', 'Customs duty payable', '{}'::jsonb, 'liability_current', false, null, 550),
  ('JM', 'default', '2072', 'Land tax payable', '{}'::jsonb, 'liability_current', false, null, 560),
  ('JM', 'default', '2073', 'Other government charges payable', '{}'::jsonb, 'liability_current', false, null, 570),
  ('JM', 'default', '2074', 'National Housing Trust (NHT), Education Tax and HEART/NSTA Trust contributions payable', '{}'::jsonb, 'liability_current', false, null, 575),
  ('JM', 'default', '2080', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 580),
  ('JM', 'default', '2090', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 590),
  ('JM', 'default', '2100', 'GCT payable — settlement of the return', '{}'::jsonb, 'liability_current', true, null, 600),
  ('JM', 'default', '2101', 'GCT collected — standard rate', '{}'::jsonb, 'liability_current', false, null, 610),
  ('JM', 'default', '2102', 'GCT collected — other rates (25 %)', '{}'::jsonb, 'liability_current', false, null, 620),
  ('JM', 'default', '2200', 'Corporate credit card payable', '{}'::jsonb, 'liability_credit_card', false, null, 630),
  ('JM', 'default', '2300', 'Bank borrowings — non-current', '{}'::jsonb, 'liability_non_current', false, null, 640),
  ('JM', 'default', '2310', 'Lease liabilities — non-current', '{}'::jsonb, 'liability_non_current', false, null, 650),
  ('JM', 'default', '2320', 'Amounts due to shareholders — non-current', '{}'::jsonb, 'liability_non_current', false, null, 660),
  ('JM', 'default', '2390', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 670),
  ('JM', 'default', '3000', 'Issued and paid-up share capital', '{}'::jsonb, 'equity', false, null, 680),
  ('JM', 'default', '3100', 'Share premium', '{}'::jsonb, 'equity', false, null, 690),
  ('JM', 'default', '3110', 'Capital reserve', '{}'::jsonb, 'equity', false, null, 700),
  ('JM', 'default', '3200', 'Retained profits', '{}'::jsonb, 'equity_retained', false, null, 710),
  ('JM', 'default', '4000', 'Sale of goods', '{}'::jsonb, 'income', false, null, 720),
  ('JM', 'default', '4010', 'Rendering of services', '{}'::jsonb, 'income', false, null, 730),
  ('JM', 'default', '4700', 'Realised exchange gains', '{}'::jsonb, 'income_other', false, null, 740),
  ('JM', 'default', '4710', 'Unrealised exchange gains', '{}'::jsonb, 'income_other', false, null, 750),
  ('JM', 'default', '4720', 'Interest income', '{}'::jsonb, 'income_other', false, null, 760),
  ('JM', 'default', '4730', 'Sundry income', '{}'::jsonb, 'income_other', false, null, 770),
  ('JM', 'default', '4750', 'Gain on disposal of fixed assets', '{}'::jsonb, 'income_other', false, null, 780),
  ('JM', 'default', '5000', 'Cost of goods sold', '{}'::jsonb, 'expense_direct_cost', false, null, 790),
  ('JM', 'default', '5010', 'Purchases', '{}'::jsonb, 'expense_direct_cost', false, null, 800),
  ('JM', 'default', '5020', 'Freight inwards', '{}'::jsonb, 'expense_direct_cost', false, null, 810),
  ('JM', 'default', '5025', 'Customs duty on imports', '{}'::jsonb, 'expense_direct_cost', false, null, 820),
  ('JM', 'default', '5030', 'Direct labour', '{}'::jsonb, 'expense_direct_cost', false, null, 830),
  ('JM', 'default', '6000', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 840),
  ('JM', 'default', '6010', 'Staff salaries and wages', '{}'::jsonb, 'expense', false, null, 850),
  ('JM', 'default', '6020', 'Pension contributions', '{}'::jsonb, 'expense', false, null, 860),
  ('JM', 'default', '6025', 'Employer payroll contributions', '{}'::jsonb, 'expense', false, null, 870),
  ('JM', 'default', '6026', 'National Insurance Scheme — employer contribution', '{}'::jsonb, 'expense', false, null, 880),
  ('JM', 'default', '6030', 'Staff welfare and benefits', '{}'::jsonb, 'expense', false, null, 890),
  ('JM', 'default', '6100', 'Rent and rates', '{}'::jsonb, 'expense', false, null, 900),
  ('JM', 'default', '6110', 'Management fees and building outgoings', '{}'::jsonb, 'expense', false, null, 910),
  ('JM', 'default', '6120', 'Utilities', '{}'::jsonb, 'expense', false, null, 920),
  ('JM', 'default', '6130', 'Land tax', '{}'::jsonb, 'expense', false, null, 930),
  ('JM', 'default', '6200', 'Government fees, licences and company registry fees', '{}'::jsonb, 'expense', false, null, 940),
  ('JM', 'default', '6210', 'Auditor''s remuneration', '{}'::jsonb, 'expense', false, null, 950),
  ('JM', 'default', '6220', 'Accounting and company secretarial fees', '{}'::jsonb, 'expense', false, null, 960),
  ('JM', 'default', '6230', 'Legal and professional fees', '{}'::jsonb, 'expense', false, null, 970),
  ('JM', 'default', '6300', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 980),
  ('JM', 'default', '6310', 'Insurance', '{}'::jsonb, 'expense', false, null, 990),
  ('JM', 'default', '6320', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1000),
  ('JM', 'default', '6330', 'Travelling expenses', '{}'::jsonb, 'expense', false, null, 1010),
  ('JM', 'default', '6340', 'Entertainment expenses', '{}'::jsonb, 'expense', false, null, 1020),
  ('JM', 'default', '6350', 'Advertising and promotion', '{}'::jsonb, 'expense', false, null, 1030),
  ('JM', 'default', '6360', 'Printing, stationery and postage', '{}'::jsonb, 'expense', false, null, 1040),
  ('JM', 'default', '6370', 'Telecommunications', '{}'::jsonb, 'expense', false, null, 1050),
  ('JM', 'default', '6380', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1060),
  ('JM', 'default', '6390', 'Sundry office expenses', '{}'::jsonb, 'expense', false, null, 1070),
  ('JM', 'default', '6400', 'Allowance for expected credit losses charged', '{}'::jsonb, 'expense', false, null, 1080),
  ('JM', 'default', '6410', 'Interest expense on bank borrowings', '{}'::jsonb, 'expense', false, null, 1090),
  ('JM', 'default', '6420', 'Interest expense on lease liabilities', '{}'::jsonb, 'expense', false, null, 1100),
  ('JM', 'default', '6450', 'Realised exchange losses', '{}'::jsonb, 'expense', false, null, 1110),
  ('JM', 'default', '6455', 'Unrealised exchange losses', '{}'::jsonb, 'expense', false, null, 1120),
  ('JM', 'default', '6460', 'Loss on disposal of fixed assets', '{}'::jsonb, 'expense', false, null, 1130),
  ('JM', 'default', '6470', 'Corporation tax charge', '{}'::jsonb, 'expense', false, null, 1140),
  ('JM', 'default', '6480', 'Deferred tax charge', '{}'::jsonb, 'expense', false, null, 1150),
  ('JM', 'default', '6490', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1160),
  ('JM', 'default', '6800', 'Depreciation and amortisation', '{}'::jsonb, 'expense_depreciation', false, null, 1170)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('JM', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('JM', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('JM', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('JM', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('JM', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('JM', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('JM', 'JM-P-15', 'Purchase, GCT 15 %', '{}'::jsonb, 'A purchase from a registered taxpayer, standard-rated, with a tax invoice', 'percent', 15, 'purchase', 'domestic', date '2020-04-01', null, 'General Consumption Tax Act — the tax paid on a purchase or expense for use in a taxable activity is an input tax credit, on a tax invoice (Tax Administration Jamaica, GCT page: only registered taxpayers issue tax invoices that let the customer claim the credit). Base to line 26, tax to line 29. Apportionment when exempt supplies exceed 5 % of total supplies (Form 4A Section D1) and the categories of tax that do not qualify are the user''s.', null, null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'jm-tax-gct-page', null, null, null, null),
  ('JM', 'JM-P-15-IMP', 'Import of goods, GCT 15 %', '{}'::jsonb, 'GCT paid at the border on imported goods (customs entry)', 'percent', 15, 'purchase', 'import', date '2020-04-01', null, 'General Consumption Tax Act — the GCT paid on imports that qualifies for credit is Form 4A line 30 (and the value of imported goods line 25). The pack applies 15 % to the invoice value; the customs value (with duty and freight) and any Advanced GCT collected from a commercial importer are the customs entry''s, not this code''s. Base to line 25, tax to line 30.', null, null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'jm-form-4a', null, null, null, null),
  ('JM', 'JM-P-25', 'Purchase, GCT 25 %', '{}'::jsonb, 'A purchase of telephone services or instruments from a registered taxpayer, taxed at 25 %', 'percent', 25, 'purchase', 'domestic', date '2020-04-01', null, 'Same credit as JM-P-15 on a purchase of a supply taxed at 25 % (telephone services, instruments and cards: Tax Administration Jamaica, GCT page). Base to line 26, tax to line 29.', null, null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'jm-tax-gct-page', null, null, null, null),
  ('JM', 'JM-P-EX', 'Purchase without GCT', '{}'::jsonb, 'A purchase of a zero-rated or exempt supply, or from a person who charges no GCT: no input tax to claim', 'percent', 0, 'purchase', 'exempt', date '2020-04-01', null, 'No GCT is charged on a zero-rated or exempt supply to the purchaser, so there is no credit to claim; the value is still reported among the local purchases of the period (Form 4A line 26).', null, null, 100, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'jm-form-4a', null, null, null, null),
  ('JM', 'JM-S-0', 'Zero-rated supply (export)', '{}'::jsonb, 'An export of goods or services, zero-rated', 'percent', 0, 'sale', 'export', date '2020-04-01', null, 'General Consumption Tax Act — exports are zero-rated; Form 4A line 8 ''Export Supplies'' carries them, outside the taxable supplies at a positive rate (line 11). A zero-rated supply is a taxable supply: the input tax of what produces it stays creditable. The conditions of zero-rating (Tax Administration Jamaica''s zero-rating requests) are the user''s. Base to line 8.', 'G', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'jm-form-4a', null, null, null, null),
  ('JM', 'JM-S-15', 'Sale, GCT 15 %', '{}'::jsonb, 'A taxable supply made in Jamaica by a registered taxpayer, standard-rated', 'percent', 15, 'sale', 'domestic', date '2020-04-01', null, 'General Consumption Tax Act, the standard rate of 15 % on the taxable supply of goods and services in Jamaica by a registered taxpayer (the rate in force since 1 April 2020, previously 16.5 %: Tax Administration Jamaica, document ''Advanced GCT'', which states it; the Act''s rate schedule itself was not opened). Base to line 14 of Form 4A, tax to line 15 (box numbers are the line numbers of the form, see tax_report.json). valid_from is 1 April 2020, the date of the 15 % rate.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'jm-gct-advanced', null, null, null, null),
  ('JM', 'JM-S-15-INC', 'Retail sale, GCT 15 %, the price includes the tax', '{}'::jsonb, 'A standard-rated sale whose price already holds the GCT', 'percent', 15, 'sale', 'domestic', date '2020-04-01', null, 'General Consumption Tax Act, the standard rate of 15 % on the taxable supply of goods and services in Jamaica by a registered taxpayer (the rate in force since 1 April 2020, previously 16.5 %: Tax Administration Jamaica, document ''Advanced GCT'', which states it; the Act''s rate schedule itself was not opened). The tax is extracted from a price that includes it, which is what price_include does: 115.00 holds 100.00 and 15.00. Same lines as JM-S-15.', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, true, false, null, 'jm-gct-advanced', null, null, null, null),
  ('JM', 'JM-S-25', 'Sale of telephone service or instrument, GCT 25 %', '{}'::jsonb, 'A supply of telephone services, telephone instruments or telephone cards, taxed at 25 %', 'percent', 25, 'sale', 'domestic', date '2020-04-01', null, 'General Consumption Tax rate of 25 % on telephone services, telephone instruments and telephone cards, as listed by Tax Administration Jamaica on its GCT page and in its booklet on GCT on government purchases (the Act''s schedule was not opened). Form 4A reports a supply at a rate other than the standard in Section C1: this pack posts the base to line 18 and the tax to line 19, and does not break them down by rate. The pack does not decide which supplies qualify: that is the user''s, with their accountant.', 'S', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'jm-tax-gct-page', null, null, null, null),
  ('JM', 'JM-S-EX', 'Exempt supply', '{}'::jsonb, 'A supply the Act exempts: no tax charged, and no credit for the input tax it uses', 'percent', 0, 'sale', 'exempt', date '2020-04-01', null, 'General Consumption Tax Act, exempt supplies: Form 4A line 7 ''Exempt Supplies''. Exempt supplies exceeding 5 % of total supplies make the input tax subject to apportionment (Form 4A Section D1), which the pack does not compute. The pack does not reproduce the schedule of exempt supplies. Base to line 7.', 'E', null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'jm-form-4a', null, null, null, null),
  ('JM', 'JM-S-Z', 'Zero-rated supply (domestic)', '{}'::jsonb, 'A zero-rated supply made in Jamaica (a good or service of the zero-rated schedule)', 'percent', 0, 'sale', 'domestic', date '2020-04-01', null, 'General Consumption Tax Act, zero-rated goods and services (0 % in Tax Administration Jamaica''s list of rates): Form 4A line 9 ''Zero Rated Supplies''. The pack does not reproduce the schedule: whether a supply is on it is the user''s, with their accountant. Base to line 9.', 'Z', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'jm-tax-gct-page', null, null, null, null)
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
    ('JM-P-15', 'invoice', 'base', 100, null, '26', array['26']::text[], 100, 'JM-GCT-RETURN', 10),
    ('JM-P-15', 'invoice', 'tax', 100, '1170', '29', array['29']::text[], 100, 'JM-GCT-RETURN', 20),
    ('JM-P-15', 'credit_note', 'base', 100, null, '26', array['26']::text[], -100, 'JM-GCT-RETURN', 10),
    ('JM-P-15', 'credit_note', 'tax', 100, '1170', '29', array['29']::text[], -100, 'JM-GCT-RETURN', 20),
    ('JM-P-15-IMP', 'invoice', 'base', 100, null, '25', array['25']::text[], 100, 'JM-GCT-RETURN', 10),
    ('JM-P-15-IMP', 'invoice', 'tax', 100, '1171', '30', array['30']::text[], 100, 'JM-GCT-RETURN', 20),
    ('JM-P-15-IMP', 'credit_note', 'base', 100, null, '25', array['25']::text[], -100, 'JM-GCT-RETURN', 10),
    ('JM-P-15-IMP', 'credit_note', 'tax', 100, '1171', '30', array['30']::text[], -100, 'JM-GCT-RETURN', 20),
    ('JM-P-25', 'invoice', 'base', 100, null, '26', array['26']::text[], 100, 'JM-GCT-RETURN', 10),
    ('JM-P-25', 'invoice', 'tax', 100, '1170', '29', array['29']::text[], 100, 'JM-GCT-RETURN', 20),
    ('JM-P-25', 'credit_note', 'base', 100, null, '26', array['26']::text[], -100, 'JM-GCT-RETURN', 10),
    ('JM-P-25', 'credit_note', 'tax', 100, '1170', '29', array['29']::text[], -100, 'JM-GCT-RETURN', 20),
    ('JM-P-EX', 'invoice', 'base', 100, null, '26', array['26']::text[], 100, 'JM-GCT-RETURN', 10),
    ('JM-P-EX', 'credit_note', 'base', 100, null, '26', array['26']::text[], -100, 'JM-GCT-RETURN', 10),
    ('JM-S-0', 'invoice', 'base', 100, null, '8', array['8']::text[], 100, 'JM-GCT-RETURN', 10),
    ('JM-S-0', 'credit_note', 'base', 100, null, '8', array['8']::text[], -100, 'JM-GCT-RETURN', 10),
    ('JM-S-15', 'invoice', 'base', 100, null, '14', array['14']::text[], 100, 'JM-GCT-RETURN', 10),
    ('JM-S-15', 'invoice', 'tax', 100, '2101', '15', array['15']::text[], 100, 'JM-GCT-RETURN', 20),
    ('JM-S-15', 'credit_note', 'base', 100, null, '14', array['14']::text[], -100, 'JM-GCT-RETURN', 10),
    ('JM-S-15', 'credit_note', 'tax', 100, '2101', '15', array['15']::text[], -100, 'JM-GCT-RETURN', 20),
    ('JM-S-15-INC', 'invoice', 'base', 100, null, '14', array['14']::text[], 100, 'JM-GCT-RETURN', 10),
    ('JM-S-15-INC', 'invoice', 'tax', 100, '2101', '15', array['15']::text[], 100, 'JM-GCT-RETURN', 20),
    ('JM-S-15-INC', 'credit_note', 'base', 100, null, '14', array['14']::text[], -100, 'JM-GCT-RETURN', 10),
    ('JM-S-15-INC', 'credit_note', 'tax', 100, '2101', '15', array['15']::text[], -100, 'JM-GCT-RETURN', 20),
    ('JM-S-25', 'invoice', 'base', 100, null, '18', array['18']::text[], 100, 'JM-GCT-RETURN', 10),
    ('JM-S-25', 'invoice', 'tax', 100, '2102', '19', array['19']::text[], 100, 'JM-GCT-RETURN', 20),
    ('JM-S-25', 'credit_note', 'base', 100, null, '18', array['18']::text[], -100, 'JM-GCT-RETURN', 10),
    ('JM-S-25', 'credit_note', 'tax', 100, '2102', '19', array['19']::text[], -100, 'JM-GCT-RETURN', 20),
    ('JM-S-EX', 'invoice', 'base', 100, null, '7', array['7']::text[], 100, 'JM-GCT-RETURN', 10),
    ('JM-S-EX', 'credit_note', 'base', 100, null, '7', array['7']::text[], -100, 'JM-GCT-RETURN', 10),
    ('JM-S-Z', 'invoice', 'base', 100, null, '9', array['9']::text[], 100, 'JM-GCT-RETURN', 10),
    ('JM-S-Z', 'credit_note', 'base', 100, null, '9', array['9']::text[], -100, 'JM-GCT-RETURN', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'JM' and t.code = v.tax_code
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
   deadline_reference, deadline_source_key, file_format,
   rounding_unit, rounding_reference, rounding_source_key)
values
  ('JM', 'JM-GCT-RETURN', 'GCT return (Form 4A, standard return)', array['month']::declaration_period[], 'month'::declaration_period, date '2020-04-01', null, 'General Consumption Tax Act; Tax Administration Jamaica, GCT forms page — Form 4A is the standard return of the registered taxpayer who supplies goods and services, for a return period of one month, due on or before the last day of the month that follows. Tourism activities (Form 4D), general insurance (Form 4E), special consumption tax (Form 4C), miscellaneous activities (Form 4G) and approved groups (Form 4H) have their own forms, which this pack does not carry. The boxes are the line numbers of Form 4A.', true,'last_day_of_month_after_period'::filing_deadline_rule, null, null, 'Tax Administration Jamaica, GCT forms page: Form 4A is due on or before the last day of the month following the return period. Since 1 October 2014 a due date that falls on a weekend or a holiday is not moved to the next working day: the return and the payment are due by the last working day of the month (Jamaica Information Service). The pack''s rule gives the last day of the month; the working-day adjustment is not expressible. The Commissioner has extended dates by announcement (after Hurricane Melissa in 2025), which a rule cannot hold.', 'jm-form-4a', null, 1, 'Form 4A, instructions: all dollar value amounts are rounded to the nearest whole number.', null)
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
  rounding_unit       = excluded.rounding_unit,
  rounding_reference  = excluded.rounding_reference,
  rounding_source_key = excluded.rounding_source_key,
  file_format         = excluded.file_format;

insert into tax_report_box_templates
  (country, report_code, box, kind, name, name_i18n, sequence, print_sequence,
   plus_boxes, minus_boxes, rate, rate_of_box, floor_zero, hidden, xml_element,
   legal_reference, source_key)
values
  ('JM', 'JM-GCT-RETURN', '7', 'base', 'Exempt supplies', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form 4A (General Consumption Tax Return, revision of 3 June 2025), line 7.', 'jm-form-4a'),
  ('JM', 'JM-GCT-RETURN', '8', 'base', 'Export supplies', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form 4A (General Consumption Tax Return, revision of 3 June 2025), line 8.', 'jm-form-4a'),
  ('JM', 'JM-GCT-RETURN', '9', 'base', 'Zero-rated supplies', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form 4A (General Consumption Tax Return, revision of 3 June 2025), line 9.', 'jm-form-4a'),
  ('JM', 'JM-GCT-RETURN', '10', 'total', 'Exempt, export and zero-rated supplies', '{}'::jsonb, 40, null, array['7', '8', '9']::text[], '{}'::text[], null, null, false, false, null, 'Form 4A (General Consumption Tax Return, revision of 3 June 2025), line 10 = lines 7 + 8 + 9.', 'jm-form-4a'),
  ('JM', 'JM-GCT-RETURN', '14', 'base', 'Supplies at the standard rate (15 %), net of GCT', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form 4A (General Consumption Tax Return, revision of 3 June 2025), line 14 (supplies to other entities at the standard rate; the pack does not separate the supplies to Tax Withholding Entities, line 12).', 'jm-form-4a'),
  ('JM', 'JM-GCT-RETURN', '18', 'base', 'Supplies at a rate other than the standard (25 %), net of GCT', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form 4A (General Consumption Tax Return, revision of 3 June 2025), line 18 (supplies to other entities at other rates, carried from Section C1).', 'jm-form-4a'),
  ('JM', 'JM-GCT-RETURN', '11', 'total', 'Taxable supplies at a positive rate', '{}'::jsonb, 70, null, array['14', '18']::text[], '{}'::text[], null, null, false, false, null, 'Form 4A (General Consumption Tax Return, revision of 3 June 2025), line 11 (total supplies less line 10) = lines 14 + 18.', 'jm-form-4a'),
  ('JM', 'JM-GCT-RETURN', '6', 'total', 'Total supplies for the period (excluding imported services)', '{}'::jsonb, 80, null, array['10', '11']::text[], '{}'::text[], null, null, false, false, null, 'Form 4A (General Consumption Tax Return, revision of 3 June 2025), line 6 = lines 10 + 11.', 'jm-form-4a'),
  ('JM', 'JM-GCT-RETURN', '15', 'tax', 'Output tax on supplies at the standard rate', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form 4A (General Consumption Tax Return, revision of 3 June 2025), line 15 (line 14 x 15 %).', 'jm-form-4a'),
  ('JM', 'JM-GCT-RETURN', '19', 'tax', 'Output tax on supplies at other rates', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form 4A (General Consumption Tax Return, revision of 3 June 2025), line 19 (from Section C1).', 'jm-form-4a'),
  ('JM', 'JM-GCT-RETURN', '24', 'total', 'Total output tax for the period', '{}'::jsonb, 110, null, array['15', '19']::text[], '{}'::text[], null, null, false, false, null, 'Form 4A (General Consumption Tax Return, revision of 3 June 2025), line 24. The pack fills lines 15 and 19; imported services (21), GCT deferred (22) and adjustments (23) are not modelled.', 'jm-form-4a'),
  ('JM', 'JM-GCT-RETURN', '25', 'base', 'Value of imported goods that qualify for credit', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form 4A (General Consumption Tax Return, revision of 3 June 2025), line 25.', 'jm-form-4a'),
  ('JM', 'JM-GCT-RETURN', '26', 'base', 'Value of local purchases and expenses that qualify for credit', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form 4A (General Consumption Tax Return, revision of 3 June 2025), line 26 (the pack does not separate local purchases from local expenses, line 27).', 'jm-form-4a'),
  ('JM', 'JM-GCT-RETURN', '28', 'total', 'Total purchases and expenses that qualify for credit', '{}'::jsonb, 140, null, array['25', '26']::text[], '{}'::text[], null, null, false, false, null, 'Form 4A (General Consumption Tax Return, revision of 3 June 2025), line 28 = lines 25 + 26 (+ 27).', 'jm-form-4a'),
  ('JM', 'JM-GCT-RETURN', '29', 'tax', 'GCT on local purchases and expenses that qualify for credit', '{}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form 4A (General Consumption Tax Return, revision of 3 June 2025), line 29.', 'jm-form-4a'),
  ('JM', 'JM-GCT-RETURN', '30', 'tax', 'GCT paid on imports that qualifies for credit', '{}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form 4A (General Consumption Tax Return, revision of 3 June 2025), line 30.', 'jm-form-4a'),
  ('JM', 'JM-GCT-RETURN', '37', 'total', 'Total input tax for the period', '{}'::jsonb, 170, null, array['29', '30']::text[], '{}'::text[], null, null, false, false, null, 'Form 4A (General Consumption Tax Return, revision of 3 June 2025), line 37. The pack fills lines 29 and 30; deferred GCT (31), capital goods (33), tax withheld by Tax Withholding Entities (34), imported services (35) and adjustments (36) are not modelled.', 'jm-form-4a'),
  ('JM', 'JM-GCT-RETURN', '38', 'total', 'GCT payable', '{}'::jsonb, 180, null, array['24']::text[], array['37']::text[], null, null, true, false, null, 'Form 4A (General Consumption Tax Return, revision of 3 June 2025), line 38 (line 24 less line 37), when positive.', 'jm-form-4a'),
  ('JM', 'JM-GCT-RETURN', '43', 'total', 'GCT creditable (to refund or to credit)', '{}'::jsonb, 190, null, array['37']::text[], array['24']::text[], null, null, true, false, null, 'Form 4A (General Consumption Tax Return, revision of 3 June 2025), line 38 when negative, and line 43 where the taxpayer chooses a refund or a credit.', 'jm-form-4a')
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
  ('JM-IFRS-SME-IS', 'JM', 'default', 'Income statement', 'income_statement', 'IFRS-SME', date '1970-01-01', null, 'Same choice as the statement of financial position: the income statement is presented in the manner of IFRS for SMEs, section 5, with the expenses collapsed to cost of sales, other operating expenses and depreciation. No Jamaica text read prescribes it. The corporate income tax charge (6470) falls in other operating expenses; the Income Tax Act was not opened and the tax is not modelled', 'iasb-ifrs-sme', null, null, '{}'::jsonb),
  ('JM-IFRS-SME-SFP', 'JM', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS-SME', date '1970-01-01', null, 'The Companies Act and the Income Tax Act of Jamaica were not opened for this pack, so no section of either is cited, and none is asserted to prescribe a layout. This statement follows the presentation of IFRS for SMEs (International Accounting Standards Board), section 4: current and non-current assets and liabilities, with equity shown beside them; that is a choice of this pack, not a text the country imposes, and a company reporting under full IFRS presents the same balance sheet with different notes. The numbering and the ranges each line reads are original to this pack. The GCT collected (2100 to 2199) is a current tax liability; the GCT recoverable sits with the receivables (1170 to 1172), unnetted. Cash flows and changes in equity are separate statements this pack does not model', 'iasb-ifrs-sme', 'alone', null, '{}'::jsonb)
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
  ('JM-IFRS-SME-IS', 'REV', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('JM-IFRS-SME-IS', 'COST', null, 'Cost of sales', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('JM-IFRS-SME-IS', 'GROSS', null, 'Gross profit', '{}'::jsonb, 30, 1, true, array['REV']::text[], array['COST']::text[], null, null, null),
  ('JM-IFRS-SME-IS', 'OTH-INC', null, 'Other income', '{}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('JM-IFRS-SME-IS', 'OPEX', null, 'Administrative and other operating expenses', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('JM-IFRS-SME-IS', 'DEPR', null, 'Depreciation and amortisation', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('JM-IFRS-SME-IS', 'PROFIT', null, 'Profit (loss) for the year', '{}'::jsonb, 70, 1, true, array['GROSS', 'OTH-INC']::text[], array['OPEX', 'DEPR']::text[], null, null, null),
  ('JM-IFRS-SME-SFP', 'A-NC-FIX', 'A-NC', 'Property, plant and equipment', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('JM-IFRS-SME-SFP', 'A-NC-INT', 'A-NC', 'Goodwill and other intangible assets', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('JM-IFRS-SME-SFP', 'A-NC-OTH', 'A-NC', 'Other non-current assets', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('JM-IFRS-SME-SFP', 'A-NC', null, 'Non-current assets', '{}'::jsonb, 40, 1, true, array['A-NC-FIX', 'A-NC-INT', 'A-NC-OTH']::text[], '{}'::text[], null, null, null),
  ('JM-IFRS-SME-SFP', 'A-C-REC', 'A-C', 'Trade and other receivables', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('JM-IFRS-SME-SFP', 'A-C-INV', 'A-C', 'Inventories', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('JM-IFRS-SME-SFP', 'A-C-OTH', 'A-C', 'Other current assets', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('JM-IFRS-SME-SFP', 'A-C-PRE', 'A-C', 'Prepayments and deposits paid', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('JM-IFRS-SME-SFP', 'A-C-CASH', 'A-C', 'Cash and cash equivalents', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('JM-IFRS-SME-SFP', 'A-C', null, 'Current assets', '{}'::jsonb, 100, 1, true, array['A-C-REC', 'A-C-INV', 'A-C-OTH', 'A-C-PRE', 'A-C-CASH']::text[], '{}'::text[], null, null, null),
  ('JM-IFRS-SME-SFP', 'A-TOT', null, 'Total assets', '{}'::jsonb, 110, 1, true, array['A-NC', 'A-C']::text[], '{}'::text[], null, null, null),
  ('JM-IFRS-SME-SFP', 'E-CAP', 'E-TOT', 'Share capital and reserves', '{}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('JM-IFRS-SME-SFP', 'E-RET', 'E-TOT', 'Retained earnings', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('JM-IFRS-SME-SFP', 'E-RESULT', 'E-TOT', 'Profit or loss for the year, not yet allocated', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('JM-IFRS-SME-SFP', 'E-TOT', null, 'Total equity', '{}'::jsonb, 150, 1, true, array['E-CAP', 'E-RET', 'E-RESULT']::text[], '{}'::text[], null, null, null),
  ('JM-IFRS-SME-SFP', 'L-NC', 'L-TOT', 'Non-current liabilities', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('JM-IFRS-SME-SFP', 'L-C-PAY', 'L-C', 'Trade and other payables', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('JM-IFRS-SME-SFP', 'L-C-TAX', 'L-C', 'Current tax liabilities, including GCT collected', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('JM-IFRS-SME-SFP', 'L-C-OTH', 'L-C', 'Other current liabilities', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('JM-IFRS-SME-SFP', 'L-C', null, 'Current liabilities', '{}'::jsonb, 200, 1, true, array['L-C-PAY', 'L-C-TAX', 'L-C-OTH']::text[], '{}'::text[], null, null, null),
  ('JM-IFRS-SME-SFP', 'L-TOT', null, 'Total liabilities', '{}'::jsonb, 210, 1, true, array['L-NC', 'L-C']::text[], '{}'::text[], null, null, null),
  ('JM-IFRS-SME-SFP', 'EL-TOT', null, 'Total equity and liabilities', '{}'::jsonb, 220, 1, true, array['E-TOT', 'L-TOT']::text[], '{}'::text[], null, null, null)
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
 where r.statement_code in ('JM-IFRS-SME-IS', 'JM-IFRS-SME-SFP')
   and (r.statement_code, r.line_code, r.sequence) not in (
     values ('JM-IFRS-SME-IS', 'REV', 10),
            ('JM-IFRS-SME-IS', 'COST', 10),
            ('JM-IFRS-SME-IS', 'OTH-INC', 10),
            ('JM-IFRS-SME-IS', 'OPEX', 10),
            ('JM-IFRS-SME-IS', 'DEPR', 10),
            ('JM-IFRS-SME-SFP', 'A-NC-FIX', 10),
            ('JM-IFRS-SME-SFP', 'A-NC-INT', 10),
            ('JM-IFRS-SME-SFP', 'A-NC-OTH', 10),
            ('JM-IFRS-SME-SFP', 'A-C-REC', 10),
            ('JM-IFRS-SME-SFP', 'A-C-INV', 10),
            ('JM-IFRS-SME-SFP', 'A-C-OTH', 10),
            ('JM-IFRS-SME-SFP', 'A-C-PRE', 10),
            ('JM-IFRS-SME-SFP', 'A-C-CASH', 10),
            ('JM-IFRS-SME-SFP', 'E-CAP', 10),
            ('JM-IFRS-SME-SFP', 'E-RET', 10),
            ('JM-IFRS-SME-SFP', 'E-RESULT', 10),
            ('JM-IFRS-SME-SFP', 'E-RESULT', 20),
            ('JM-IFRS-SME-SFP', 'E-RESULT', 30),
            ('JM-IFRS-SME-SFP', 'E-RESULT', 40),
            ('JM-IFRS-SME-SFP', 'L-NC', 10),
            ('JM-IFRS-SME-SFP', 'L-C-PAY', 10),
            ('JM-IFRS-SME-SFP', 'L-C-TAX', 10),
            ('JM-IFRS-SME-SFP', 'L-C-TAX', 20),
            ('JM-IFRS-SME-SFP', 'L-C-OTH', 10),
            ('JM-IFRS-SME-SFP', 'L-C-OTH', 20)
   );

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('JM-IFRS-SME-IS', 'REV', 10, 'code_range', '4000', '4699', null, 'any'),
    ('JM-IFRS-SME-IS', 'COST', 10, 'code_range', '5000', '5099', null, 'any'),
    ('JM-IFRS-SME-IS', 'OTH-INC', 10, 'code_range', '4700', '4799', null, 'any'),
    ('JM-IFRS-SME-IS', 'OPEX', 10, 'code_range', '6000', '6799', null, 'any'),
    ('JM-IFRS-SME-IS', 'DEPR', 10, 'code_range', '6800', '6899', null, 'any'),
    ('JM-IFRS-SME-SFP', 'A-NC-FIX', 10, 'code_range', '1600', '1799', null, 'any'),
    ('JM-IFRS-SME-SFP', 'A-NC-INT', 10, 'code_range', '1800', '1899', null, 'any'),
    ('JM-IFRS-SME-SFP', 'A-NC-OTH', 10, 'code_range', '1900', '1999', null, 'any'),
    ('JM-IFRS-SME-SFP', 'A-C-REC', 10, 'code_range', '1100', '1199', null, 'any'),
    ('JM-IFRS-SME-SFP', 'A-C-INV', 10, 'code_range', '1200', '1299', null, 'any'),
    ('JM-IFRS-SME-SFP', 'A-C-OTH', 10, 'code_range', '1300', '1399', null, 'any'),
    ('JM-IFRS-SME-SFP', 'A-C-PRE', 10, 'code_range', '1400', '1499', null, 'any'),
    ('JM-IFRS-SME-SFP', 'A-C-CASH', 10, 'code_range', '1000', '1099', null, 'any'),
    ('JM-IFRS-SME-SFP', 'E-CAP', 10, 'code_range', '3000', '3199', null, 'any'),
    ('JM-IFRS-SME-SFP', 'E-RET', 10, 'code_range', '3200', '3299', null, 'any'),
    ('JM-IFRS-SME-SFP', 'E-RESULT', 10, 'code_range', '4000', '4699', null, 'any'),
    ('JM-IFRS-SME-SFP', 'E-RESULT', 20, 'code_range', '4700', '4799', null, 'any'),
    ('JM-IFRS-SME-SFP', 'E-RESULT', 30, 'code_range', '5000', '5099', null, 'any'),
    ('JM-IFRS-SME-SFP', 'E-RESULT', 40, 'code_range', '6000', '6899', null, 'any'),
    ('JM-IFRS-SME-SFP', 'L-NC', 10, 'code_range', '2300', '2399', null, 'any'),
    ('JM-IFRS-SME-SFP', 'L-C-PAY', 10, 'code_range', '2000', '2059', null, 'any'),
    ('JM-IFRS-SME-SFP', 'L-C-TAX', 10, 'code_range', '2060', '2069', null, 'any'),
    ('JM-IFRS-SME-SFP', 'L-C-TAX', 20, 'code_range', '2100', '2199', null, 'any'),
    ('JM-IFRS-SME-SFP', 'L-C-OTH', 10, 'code_range', '2070', '2099', null, 'any'),
    ('JM-IFRS-SME-SFP', 'L-C-OTH', 20, 'code_range', '2200', '2299', null, 'any')
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
  ('JM', 'Jamaica', '{}'::jsonb, array['en']::text[], 'JMD', '1100', '2000', '2090', '6490', '3200', '4000', '5010', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6450', '4750', '6460', null, null, '2100', '1172', null, 'month'::declaration_period)
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
  numbering_legal_reference     = 'Tax Administration Jamaica, GCT page: a tax invoice is pre-numbered, carries the words ''Tax Invoice'' and is issued within seven days of the supply, one per supply. The page does not say the series may have no gap, which is why `numbering` is `sequential` and not `gapless`; `number_format` is a convention this pack proposes. The Act itself was not opened',
  numbering_source_key          = 'jm-tax-gct-page',
  payment_terms_legal_reference = 'No Jamaican text read for this pack sets a payment term between two businesses or a rate of interest on a commercial debt paid late: the penalties and interest on a late return are charges on the taxpayer towards the Commissioner, not a term between two businesses. `legal_payment_days` and `late_payment_reference` are empty',
  payment_terms_source_key      = 'jm-tax-gct-page',
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'The time of supply rule of the General Consumption Tax Act was not opened for this pack. `earliest_of_delivery_or_payment` is the nearest value of the closed vocabulary and is the tax point the pack proposes; the user confirms it with their accountant',
  tax_point_source_key          = 'jm-tax-gct-page',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No Jamaican text read for this pack obliges a business to issue or accept an electronic invoice: Tax Administration Jamaica''s GCT page asks for a pre-numbered tax invoice without naming a platform, a format or a Peppol profile. No Peppol authority for Jamaica was looked for. `profile`, `party_scheme` and `vat_scheme` are null: there is no domestic profile to name',
  einvoice_source_key           = 'jm-tax-gct-page',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'JM';
