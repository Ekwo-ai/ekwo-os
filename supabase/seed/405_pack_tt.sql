-- Ekwo OS — Trinidad and Tobago: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/tt at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build tt`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Value Added Tax Act, Chap. 75:06 (Act No. 37 of 1989), with its Schedules 1 to 3A and the Value Added Tax (Books and Records) Regulations; the unofficial version of the Laws of Trinidad and Tobago updated to 31 December 2016 — later amendments, Orders and changes to the Schedules are not applied (Ministry of the Attorney General and Legal Affairs, Republic of Trinidad and Tobago)
--     https://rgd.legalaffairs.gov.tt/laws2/Alphabetical_List/lawspdfs/75.06.pdf
--   Value Added Tax (VAT) — the rate of 12.5 %, who must register (gross commercial supplies above TT$600,000 in twelve months, as of 1 January 2023), registration requirements (Inland Revenue Division, Ministry of Finance, Republic of Trinidad and Tobago)
--     https://www.ird.gov.tt/vat
--   IFRS for SMEs Accounting Standard (IFRS Foundation / International Accounting Standards Board)
--     https://www.ifrs.org/issued-standards/ifrs-for-smes/
--   Website of the Inland Revenue Division (the Board of Inland Revenue's administration: forms, notices and the e-Tax services) (Inland Revenue Division, Ministry of Finance, Republic of Trinidad and Tobago)
--     https://www.ird.gov.tt
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('TT', 'Trinidad and Tobago', '0.1.0', date '2026-10-20', '20261011120000', 'community', null, null, 'e41448b6e418c9c312dca8b19e131907ee01218e07559fc6ce0f896dd2c1b6e0', '[{"key":"tt-vat-act","title":"Value Added Tax Act, Chap. 75:06 (Act No. 37 of 1989), with its Schedules 1 to 3A and the Value Added Tax (Books and Records) Regulations; the unofficial version of the Laws of Trinidad and Tobago updated to 31 December 2016 — later amendments, Orders and changes to the Schedules are not applied","publisher":"Ministry of the Attorney General and Legal Affairs, Republic of Trinidad and Tobago","url":"https://rgd.legalaffairs.gov.tt/laws2/Alphabetical_List/lawspdfs/75.06.pdf","consulted_on":"2026-10-20","kind":"law"},{"key":"tt-ird-vat","title":"Value Added Tax (VAT) — the rate of 12.5 %, who must register (gross commercial supplies above TT$600,000 in twelve months, as of 1 January 2023), registration requirements","publisher":"Inland Revenue Division, Ministry of Finance, Republic of Trinidad and Tobago","url":"https://www.ird.gov.tt/vat","consulted_on":"2026-10-20","kind":"guidance"},{"key":"iasb-ifrs-sme","title":"IFRS for SMEs Accounting Standard","publisher":"IFRS Foundation / International Accounting Standards Board","url":"https://www.ifrs.org/issued-standards/ifrs-for-smes/","consulted_on":"2026-10-20","kind":"standard"},{"key":"tt-ird-portal","title":"Website of the Inland Revenue Division (the Board of Inland Revenue''s administration: forms, notices and the e-Tax services)","publisher":"Inland Revenue Division, Ministry of Finance, Republic of Trinidad and Tobago","url":"https://www.ird.gov.tt","consulted_on":"2026-10-20","kind":"portal"}]'::jsonb)
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
  ('TT', 'default', 'Trinidad and Tobago reference chart of accounts', '{}'::jsonb, true, 'companies', array['TT-IFRS-SME-IS', 'TT-IFRS-SME-SFP']::text[], null, 'This pack found no legal chart of accounts in Trinidad and Tobago, and opened neither the Companies Act nor the Corporation Tax Act: no section of either is cited. What the Value Added Tax Act asks of a registered person is a tax invoice (s. 36) and books and records kept at the principal place of business (s. 38 and the Books and Records Regulations). This chart is original: four digits, blocked so that each range reaches one line of a statement of financial position and an income statement presented in the manner of IFRS for SMEs, which is a choice of this pack and not a text the country imposes. The settlement account of the VAT return (2100, refundable 1172) is distinct from the accounts the tax posts to (2101 collected, 1170 and 1171 recoverable). See README.md', 'tt-vat-act')
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
  ('TT', 'default', '1000', 'Cash on hand', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('TT', 'default', '1010', 'Bank current account', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('TT', 'default', '1020', 'Bank savings account', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('TT', 'default', '1030', 'Foreign currency bank account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('TT', 'default', '1040', 'Payment gateway and card clearing account', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('TT', 'default', '1050', 'Fixed deposits of three months or less', '{}'::jsonb, 'asset_cash', false, null, 60),
  ('TT', 'default', '1060', 'Cash in transit', '{}'::jsonb, 'asset_cash', false, null, 70),
  ('TT', 'default', '1100', 'Trade debtors', '{}'::jsonb, 'asset_receivable', true, null, 80),
  ('TT', 'default', '1105', 'Allowance for expected credit losses', '{}'::jsonb, 'asset_current', false, null, 90),
  ('TT', 'default', '1110', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 100),
  ('TT', 'default', '1120', 'Other debtors', '{}'::jsonb, 'asset_current', false, null, 110),
  ('TT', 'default', '1130', 'Accrued income', '{}'::jsonb, 'asset_current', false, null, 120),
  ('TT', 'default', '1140', 'Staff advances and loans to employees', '{}'::jsonb, 'asset_current', false, null, 130),
  ('TT', 'default', '1150', 'Customs duty deposits paid', '{}'::jsonb, 'asset_current', false, null, 140),
  ('TT', 'default', '1160', 'Corporation tax recoverable', '{}'::jsonb, 'asset_current', false, null, 150),
  ('TT', 'default', '1170', 'VAT recoverable — local purchases', '{}'::jsonb, 'asset_current', false, null, 160),
  ('TT', 'default', '1171', 'VAT recoverable — imports paid to the Comptroller of Customs', '{}'::jsonb, 'asset_current', false, null, 170),
  ('TT', 'default', '1172', 'VAT refundable — settlement of the return', '{}'::jsonb, 'asset_current', true, null, 180),
  ('TT', 'default', '1200', 'Inventory — raw materials and consumables', '{}'::jsonb, 'asset_current', false, null, 190),
  ('TT', 'default', '1210', 'Inventory — work in progress', '{}'::jsonb, 'asset_current', false, null, 200),
  ('TT', 'default', '1220', 'Inventory — finished goods and goods for resale', '{}'::jsonb, 'asset_current', false, null, 210),
  ('TT', 'default', '1230', 'Goods in transit', '{}'::jsonb, 'asset_current', false, null, 220),
  ('TT', 'default', '1300', 'Fixed deposits of more than three months', '{}'::jsonb, 'asset_current', false, null, 230),
  ('TT', 'default', '1310', 'Listed investments held for trading', '{}'::jsonb, 'asset_current', false, null, 240),
  ('TT', 'default', '1320', 'Amounts due from related companies — non-trade', '{}'::jsonb, 'asset_current', false, null, 250),
  ('TT', 'default', '1400', 'Prepaid expenses', '{}'::jsonb, 'asset_prepayments', false, null, 260),
  ('TT', 'default', '1410', 'Rental and utility deposits paid', '{}'::jsonb, 'asset_prepayments', false, null, 270),
  ('TT', 'default', '1420', 'Deposits paid to suppliers', '{}'::jsonb, 'asset_prepayments', false, null, 280),
  ('TT', 'default', '1600', 'Leasehold land and buildings', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('TT', 'default', '1610', 'Leasehold improvements', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('TT', 'default', '1620', 'Furniture and fixtures', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('TT', 'default', '1630', 'Office equipment', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('TT', 'default', '1640', 'Computer equipment and software', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('TT', 'default', '1650', 'Motor vehicles', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('TT', 'default', '1660', 'Plant and machinery', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('TT', 'default', '1670', 'Right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('TT', 'default', '1690', 'Accumulated depreciation — property plant and equipment', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('TT', 'default', '1695', 'Accumulated depreciation — right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 380),
  ('TT', 'default', '1800', 'Goodwill', '{}'::jsonb, 'asset_non_current', false, null, 390),
  ('TT', 'default', '1810', 'Other intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 400),
  ('TT', 'default', '1820', 'Accumulated amortisation — intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 410),
  ('TT', 'default', '1900', 'Investments in subsidiaries', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('TT', 'default', '1910', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('TT', 'default', '1920', 'Other long-term investments', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('TT', 'default', '1930', 'Rental and utility deposits — non-current', '{}'::jsonb, 'asset_non_current', false, null, 450),
  ('TT', 'default', '1990', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('TT', 'default', '2000', 'Trade creditors', '{}'::jsonb, 'liability_payable', true, null, 470),
  ('TT', 'default', '2010', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 480),
  ('TT', 'default', '2020', 'Accruals', '{}'::jsonb, 'liability_current', false, null, 490),
  ('TT', 'default', '2030', 'Customer deposits and advances received', '{}'::jsonb, 'liability_current', false, null, 500),
  ('TT', 'default', '2040', 'Salaries and wages payable', '{}'::jsonb, 'liability_current', false, null, 510),
  ('TT', 'default', '2050', 'National Insurance Scheme contributions payable', '{}'::jsonb, 'liability_current', false, null, 520),
  ('TT', 'default', '2060', 'Corporation tax payable', '{}'::jsonb, 'liability_current', false, null, 530),
  ('TT', 'default', '2070', 'Payroll deductions payable', '{}'::jsonb, 'liability_current', false, null, 540),
  ('TT', 'default', '2071', 'Customs duty payable', '{}'::jsonb, 'liability_current', false, null, 550),
  ('TT', 'default', '2072', 'Land tax payable', '{}'::jsonb, 'liability_current', false, null, 560),
  ('TT', 'default', '2073', 'Other government charges payable', '{}'::jsonb, 'liability_current', false, null, 570),
  ('TT', 'default', '2080', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 580),
  ('TT', 'default', '2090', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 590),
  ('TT', 'default', '2100', 'VAT payable — settlement of the return', '{}'::jsonb, 'liability_current', true, null, 600),
  ('TT', 'default', '2101', 'VAT collected — standard rate (12.5 %)', '{}'::jsonb, 'liability_current', false, null, 610),
  ('TT', 'default', '2200', 'Corporate credit card payable', '{}'::jsonb, 'liability_credit_card', false, null, 630),
  ('TT', 'default', '2300', 'Bank borrowings — non-current', '{}'::jsonb, 'liability_non_current', false, null, 640),
  ('TT', 'default', '2310', 'Lease liabilities — non-current', '{}'::jsonb, 'liability_non_current', false, null, 650),
  ('TT', 'default', '2320', 'Amounts due to shareholders — non-current', '{}'::jsonb, 'liability_non_current', false, null, 660),
  ('TT', 'default', '2390', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 670),
  ('TT', 'default', '3000', 'Issued and paid-up share capital', '{}'::jsonb, 'equity', false, null, 680),
  ('TT', 'default', '3100', 'Share premium', '{}'::jsonb, 'equity', false, null, 690),
  ('TT', 'default', '3110', 'Capital reserve', '{}'::jsonb, 'equity', false, null, 700),
  ('TT', 'default', '3200', 'Retained profits', '{}'::jsonb, 'equity_retained', false, null, 710),
  ('TT', 'default', '4000', 'Sale of goods', '{}'::jsonb, 'income', false, null, 720),
  ('TT', 'default', '4010', 'Rendering of services', '{}'::jsonb, 'income', false, null, 730),
  ('TT', 'default', '4700', 'Realised exchange gains', '{}'::jsonb, 'income_other', false, null, 740),
  ('TT', 'default', '4710', 'Unrealised exchange gains', '{}'::jsonb, 'income_other', false, null, 750),
  ('TT', 'default', '4720', 'Interest income', '{}'::jsonb, 'income_other', false, null, 760),
  ('TT', 'default', '4730', 'Sundry income', '{}'::jsonb, 'income_other', false, null, 770),
  ('TT', 'default', '4750', 'Gain on disposal of fixed assets', '{}'::jsonb, 'income_other', false, null, 780),
  ('TT', 'default', '5000', 'Cost of goods sold', '{}'::jsonb, 'expense_direct_cost', false, null, 790),
  ('TT', 'default', '5010', 'Purchases', '{}'::jsonb, 'expense_direct_cost', false, null, 800),
  ('TT', 'default', '5020', 'Freight inwards', '{}'::jsonb, 'expense_direct_cost', false, null, 810),
  ('TT', 'default', '5025', 'Customs duty on imports', '{}'::jsonb, 'expense_direct_cost', false, null, 820),
  ('TT', 'default', '5030', 'Direct labour', '{}'::jsonb, 'expense_direct_cost', false, null, 830),
  ('TT', 'default', '6000', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 840),
  ('TT', 'default', '6010', 'Staff salaries and wages', '{}'::jsonb, 'expense', false, null, 850),
  ('TT', 'default', '6020', 'Pension contributions', '{}'::jsonb, 'expense', false, null, 860),
  ('TT', 'default', '6025', 'Employer payroll contributions', '{}'::jsonb, 'expense', false, null, 870),
  ('TT', 'default', '6026', 'National Insurance Scheme — employer contribution', '{}'::jsonb, 'expense', false, null, 880),
  ('TT', 'default', '6030', 'Staff welfare and benefits', '{}'::jsonb, 'expense', false, null, 890),
  ('TT', 'default', '6100', 'Rent and rates', '{}'::jsonb, 'expense', false, null, 900),
  ('TT', 'default', '6110', 'Management fees and building outgoings', '{}'::jsonb, 'expense', false, null, 910),
  ('TT', 'default', '6120', 'Utilities', '{}'::jsonb, 'expense', false, null, 920),
  ('TT', 'default', '6130', 'Land tax', '{}'::jsonb, 'expense', false, null, 930),
  ('TT', 'default', '6200', 'Government fees, licences and company registry fees', '{}'::jsonb, 'expense', false, null, 940),
  ('TT', 'default', '6210', 'Auditor''s remuneration', '{}'::jsonb, 'expense', false, null, 950),
  ('TT', 'default', '6220', 'Accounting and company secretarial fees', '{}'::jsonb, 'expense', false, null, 960),
  ('TT', 'default', '6230', 'Legal and professional fees', '{}'::jsonb, 'expense', false, null, 970),
  ('TT', 'default', '6300', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 980),
  ('TT', 'default', '6310', 'Insurance', '{}'::jsonb, 'expense', false, null, 990),
  ('TT', 'default', '6320', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1000),
  ('TT', 'default', '6330', 'Travelling expenses', '{}'::jsonb, 'expense', false, null, 1010),
  ('TT', 'default', '6340', 'Entertainment expenses', '{}'::jsonb, 'expense', false, null, 1020),
  ('TT', 'default', '6350', 'Advertising and promotion', '{}'::jsonb, 'expense', false, null, 1030),
  ('TT', 'default', '6360', 'Printing, stationery and postage', '{}'::jsonb, 'expense', false, null, 1040),
  ('TT', 'default', '6370', 'Telecommunications', '{}'::jsonb, 'expense', false, null, 1050),
  ('TT', 'default', '6380', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1060),
  ('TT', 'default', '6390', 'Sundry office expenses', '{}'::jsonb, 'expense', false, null, 1070),
  ('TT', 'default', '6400', 'Allowance for expected credit losses charged', '{}'::jsonb, 'expense', false, null, 1080),
  ('TT', 'default', '6410', 'Interest expense on bank borrowings', '{}'::jsonb, 'expense', false, null, 1090),
  ('TT', 'default', '6420', 'Interest expense on lease liabilities', '{}'::jsonb, 'expense', false, null, 1100),
  ('TT', 'default', '6450', 'Realised exchange losses', '{}'::jsonb, 'expense', false, null, 1110),
  ('TT', 'default', '6455', 'Unrealised exchange losses', '{}'::jsonb, 'expense', false, null, 1120),
  ('TT', 'default', '6460', 'Loss on disposal of fixed assets', '{}'::jsonb, 'expense', false, null, 1130),
  ('TT', 'default', '6470', 'Corporation tax charge', '{}'::jsonb, 'expense', false, null, 1140),
  ('TT', 'default', '6480', 'Deferred tax charge', '{}'::jsonb, 'expense', false, null, 1150),
  ('TT', 'default', '6490', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1160),
  ('TT', 'default', '6800', 'Depreciation and amortisation', '{}'::jsonb, 'expense_depreciation', false, null, 1170)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('TT', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('TT', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('TT', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('TT', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('TT', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('TT', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('TT', 'TT-P-125', 'Purchase, VAT 12.5 %', '{}'::jsonb, 'A purchase from a registered person, standard-rated, with a tax invoice', 'percent', 12.5, 'purchase', 'domestic', date '1990-01-01', null, 'Value Added Tax Act, s. 34 — the input tax of a period is the output tax claimed from the person under s. 23 on supplies made to him for which a tax invoice was given under s. 36(2), and the tax paid on the entry of imported goods; the allowable input tax is the whole of it where all his supplies are commercial supplies and an apportioned part where some are not (s. 34(3)); input tax on what is required other than for carrying on a business in Trinidad and Tobago is excluded. The apportionment is the user''s. Base to box 7, tax to box 9.', null, null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tt-vat-act', null, null, null, null),
  ('TT', 'TT-P-125-IMP', 'Import of goods, VAT 12.5 %', '{}'::jsonb, 'Goods imported: the VAT paid to the Comptroller of Customs and Excise', 'percent', 12.5, 'purchase', 'import', date '1990-01-01', null, 'Value Added Tax Act, s. 6(a), s. 9 to 12 — tax is charged on the entry of imported goods, collected by the Comptroller of Customs and Excise and due when the goods are entered (s. 11), on the value defined in s. 12; the tax paid on entry is input tax of the importer (s. 34(1)(b)). The value for tax is the customs entry''s; the pack applies the rate to the invoice value it is given. Base to box 6, tax to box 8.', null, null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tt-vat-act', null, null, null, null),
  ('TT', 'TT-P-EX', 'Purchase without VAT', '{}'::jsonb, 'A purchase of a zero-rated or exempt supply, or from a person who charges no VAT: no input tax to claim', 'percent', 0, 'purchase', 'exempt', date '1990-01-01', null, 'Value Added Tax Act, s. 8(3) and Schedule 1 — a zero-rated supply carries tax at nil and an exempt service none, so the purchaser has no input tax to deduct; the value is still reported among the purchases (box 7).', null, null, 80, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'tt-vat-act', null, null, null, null),
  ('TT', 'TT-S-0', 'Zero-rated supply (export)', '{}'::jsonb, 'Goods supplied to a destination outside the territory of Trinidad and Tobago, or a service paid for in foreign currency to a recipient outside the country, zero-rated', 'percent', 0, 'sale', 'export', date '1990-01-01', null, 'Value Added Tax Act, s. 8 and Schedule 2, item 15 (any good supplied to a destination outside the territory of Trinidad and Tobago) and item 17 (any service supplied for a consideration payable in a currency other than that of Trinidad and Tobago to a recipient who is not within the country when the service is performed); s. 8(3) — the rate at which tax is regarded as being charged is nil. A zero-rated supply is a commercial supply: the input tax of what produces it stays deductible (s. 34). Base to box 2. The documentary proof the Board asks for was not found in the text read.', 'G', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tt-vat-act', null, null, null, null),
  ('TT', 'TT-S-125', 'Sale, VAT 12.5 %', '{}'::jsonb, 'A commercial supply made in Trinidad and Tobago by a registered person, standard-rated', 'percent', 12.5, 'sale', 'domestic', date '1990-01-01', null, 'Value Added Tax Act, s. 6 and s. 7(1) — value added tax is charged on the commercial supply within Trinidad and Tobago of goods or prescribed services by a registered person, at twelve and one-half per cent or such other rate as the Minister by Order specifies (the Inland Revenue Division''s page gives 12.5 %); s. 33 — output tax is the value of the supply multiplied by the rate; s. 32 — the tax payable for a period is the output tax less the allowable input tax. The base posts to box 1 net of the tax, the tax to box 5 (box numbers are this pack''s, see tax_report.json). valid_from is 1 January 1990, the appointed day of s. 6 (L.N. 153/1989 as noted in the Act); the rate of 12.5 % was not traced through the amendments to the Act, and a company with books dated before the current rate was set should check with its accountant. Only ''prescribed services'' are taxed: whether a service is prescribed is the user''s to check.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tt-vat-act', null, null, null, null),
  ('TT', 'TT-S-125-INC', 'Retail sale, VAT 12.5 %, the price includes the tax', '{}'::jsonb, 'A standard-rated sale whose price already holds the VAT', 'percent', 12.5, 'sale', 'domestic', date '1990-01-01', null, 'Value Added Tax Act, s. 7(1) at 12.5 % and s. 18 (value of a supply) — what price_include does: 112.50 holds 100.00 and 12.50. Same boxes as TT-S-125. How the Act values a supply whose consideration includes the tax was not traced to a provision; the arithmetic is the tax fraction of the rate.', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, true, false, null, 'tt-vat-act', null, null, null, null),
  ('TT', 'TT-S-EX', 'Exempt supply', '{}'::jsonb, 'A service of Schedule 1 (medical and dental services, bus and taxi services, schools, real estate brokerage, residential rent, long-stay accommodation, postal services, betting and gambling, financial services), outside the tax', 'percent', 0, 'sale', 'exempt', date '1990-01-01', null, 'Value Added Tax Act, Schedule 1 (exempt services) — medical, dental, hospital, optical and paramedical services other than veterinary (item 1); bus and taxi services (item 2); training and education in approved schools and through the University of the West Indies (item 4); real estate brokerage (item 5); rental of residential property (item 6); accommodation in hotels, inns and guest houses for a period in excess of thirty days (item 7); public postal services (item 8); betting, gambling and lotteries (item 9); financial services (item 10). The Act taxes only commercial supplies, which are supplies of goods and prescribed services (s. 14): a service not prescribed is outside the tax, which this code also serves. The input tax of what is acquired to make exempt supplies is not deductible (s. 34(3)(b)). Base to box 3.', 'E', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tt-vat-act', null, null, null, null),
  ('TT', 'TT-S-Z', 'Zero-rated supply in Trinidad and Tobago', '{}'::jsonb, 'A domestic supply of Schedule 2 at zero per cent (basic foods, prescription medicines, agricultural inputs, water, short-stay accommodation, international freight, domestic travel between the islands)', 'percent', 0, 'sale', 'domestic', date '1990-01-01', null, 'Value Added Tax Act, s. 8 and Schedule 2 — among the goods and services zero-rated: unprocessed food, rice, wheat flour, milk, margarine, bread, baby formula and other listed groceries (item 1); live animals for food, animal feed, seeds and agricultural preparations and equipment (items 2 to 6); water and sewerage services supplied by a public authority (item 7); medicines and drugs available only by prescription and listed over-the-counter medicines (items 9 to 12); international freight and ancillary services (item 23); domestic travel between Trinidad and Tobago (item 25); accommodation primarily providing sleeping accommodation for reward to guests (item 30). The pack does not reproduce the Schedule, which the Minister may amend by Order (s. 8(4)) and which has been amended many times since: the user checks the item against the current text. Base to box 2.', 'Z', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tt-vat-act', null, null, null, null)
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
    ('TT-P-125', 'invoice', 'base', 100, null, '7', array['7']::text[], 100, 'TT-VAT-RETURN', 10),
    ('TT-P-125', 'invoice', 'tax', 100, '1170', '9', array['9']::text[], 100, 'TT-VAT-RETURN', 20),
    ('TT-P-125', 'credit_note', 'base', 100, null, '7', array['7']::text[], -100, 'TT-VAT-RETURN', 10),
    ('TT-P-125', 'credit_note', 'tax', 100, '1170', '9', array['9']::text[], -100, 'TT-VAT-RETURN', 20),
    ('TT-P-125-IMP', 'invoice', 'base', 100, null, '6', array['6']::text[], 100, 'TT-VAT-RETURN', 10),
    ('TT-P-125-IMP', 'invoice', 'tax', 100, '1171', '8', array['8']::text[], 100, 'TT-VAT-RETURN', 20),
    ('TT-P-125-IMP', 'credit_note', 'base', 100, null, '6', array['6']::text[], -100, 'TT-VAT-RETURN', 10),
    ('TT-P-125-IMP', 'credit_note', 'tax', 100, '1171', '8', array['8']::text[], -100, 'TT-VAT-RETURN', 20),
    ('TT-P-EX', 'invoice', 'base', 100, null, '7', array['7']::text[], 100, 'TT-VAT-RETURN', 10),
    ('TT-P-EX', 'credit_note', 'base', 100, null, '7', array['7']::text[], -100, 'TT-VAT-RETURN', 10),
    ('TT-S-0', 'invoice', 'base', 100, null, '2', array['2']::text[], 100, 'TT-VAT-RETURN', 10),
    ('TT-S-0', 'credit_note', 'base', 100, null, '2', array['2']::text[], -100, 'TT-VAT-RETURN', 10),
    ('TT-S-125', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'TT-VAT-RETURN', 10),
    ('TT-S-125', 'invoice', 'tax', 100, '2101', '5', array['5']::text[], 100, 'TT-VAT-RETURN', 20),
    ('TT-S-125', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'TT-VAT-RETURN', 10),
    ('TT-S-125', 'credit_note', 'tax', 100, '2101', '5', array['5']::text[], -100, 'TT-VAT-RETURN', 20),
    ('TT-S-125-INC', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'TT-VAT-RETURN', 10),
    ('TT-S-125-INC', 'invoice', 'tax', 100, '2101', '5', array['5']::text[], 100, 'TT-VAT-RETURN', 20),
    ('TT-S-125-INC', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'TT-VAT-RETURN', 10),
    ('TT-S-125-INC', 'credit_note', 'tax', 100, '2101', '5', array['5']::text[], -100, 'TT-VAT-RETURN', 20),
    ('TT-S-EX', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'TT-VAT-RETURN', 10),
    ('TT-S-EX', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'TT-VAT-RETURN', 10),
    ('TT-S-Z', 'invoice', 'base', 100, null, '2', array['2']::text[], 100, 'TT-VAT-RETURN', 10),
    ('TT-S-Z', 'credit_note', 'base', 100, null, '2', array['2']::text[], -100, 'TT-VAT-RETURN', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'TT' and t.code = v.tax_code
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
  ('TT', 'TT-VAT-RETURN', 'VAT return (box layout of this pack)', array['month', 'bimonth']::declaration_period[], null, date '1990-01-01', null, 'Value Added Tax Act, s. 30 — each registered person is in category A, B or C as the Board determines: the tax periods of category B are two months from the appointed day (January–February, March–April and so on), those of category A are one month and then two-month periods, those of category C are fixed by the Board for that person; s. 31(1) — every registered person furnishes a return, in a form approved by the Board, for each tax period; s. 31(3) and (4) — it states the tax payable or the refund due, calculated under s. 32; s. 35(1) — the tax is paid within the time allowed for the return. The Board''s own return form was not read as a text. `period_default` is left out because the cadence depends on the category the Board gave the taxpayer; category A (one month, then two-month periods starting in February) is not a cadence the format can express and is filed here as `month` or `bimonth` at the user''s choice.', true,'day_of_month_after_period'::filing_deadline_rule, 25, null, 'Value Added Tax Act, s. 31(2)(a) — the return is furnished within twenty-five days after the end of the tax period, or within such further time as the Board may in writing allow, and is not furnished until it is received at the address on the form; s. 35(1) — the tax is paid within that time. For a tax period ending on the last day of a month, twenty-five days later is the 25th of the next month, whatever the month. Penalty and interest on what is paid late: 8 % and 2 % a month or part of a month (s. 54(1)), run from the date of s. 31(2). Weekend roll-forward is not expressible', 'tt-vat-act', null)
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
  ('TT', 'TT-VAT-RETURN', '1', 'base', 'Standard-rated supplies (12.5 %), net of VAT', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Commercial supplies at 12.5 % (s. 7(1)). Box number and label are this pack''s own: the layout of the Board''s VAT return form was not read as a text, so the boxes follow what the Act makes the tax payable carry — the output tax of the period less the allowable input tax (s. 32(1)).', 'tt-vat-act'),
  ('TT', 'TT-VAT-RETURN', '2', 'base', 'Zero-rated supplies, including exports', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Supplies zero-rated under s. 8 and Schedule 2; they stay on the return, as a registered person furnishes a return for each tax period during which it was registered (s. 31(1)), whether or not tax is payable.', 'tt-vat-act'),
  ('TT', 'TT-VAT-RETURN', '3', 'base', 'Exempt supplies', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Services of Schedule 1, reported for information; the input tax of what is acquired to make them is not deductible (s. 34(3)).', 'tt-vat-act'),
  ('TT', 'TT-VAT-RETURN', '4', 'total', 'Total supplies', '{}'::jsonb, 40, null, array['1', '2', '3']::text[], '{}'::text[], null, null, false, false, null, 'Sum of boxes 1 to 3 — the sum is this pack''s reading, the form is the Board''s (s. 31(1) and (3)).', 'tt-vat-act'),
  ('TT', 'TT-VAT-RETURN', '5', 'tax', 'Output tax on standard-rated supplies', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tax at 12.5 % on box 1 (s. 7(1), s. 33); a credit note posts a negative amount to its own boxes (s. 37).', 'tt-vat-act'),
  ('TT', 'TT-VAT-RETURN', '6', 'base', 'Value of imports', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Goods imported on which tax was paid on entry to the Comptroller of Customs and Excise (s. 6(a), s. 9 to 12).', 'tt-vat-act'),
  ('TT', 'TT-VAT-RETURN', '7', 'base', 'Value of local purchases', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Purchases made in Trinidad and Tobago for the business, taxable, zero-rated and exempt.', 'tt-vat-act'),
  ('TT', 'TT-VAT-RETURN', '8', 'tax', 'VAT paid on imports', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tax paid on the entry of imported goods, input tax of the period (s. 34(1)(b)).', 'tt-vat-act'),
  ('TT', 'TT-VAT-RETURN', '9', 'tax', 'VAT paid on local purchases', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tax charged on purchases for which a tax invoice was given (s. 34(1)(a), s. 36).', 'tt-vat-act'),
  ('TT', 'TT-VAT-RETURN', '10', 'total', 'Total allowable input tax for the period', '{}'::jsonb, 100, null, array['8', '9']::text[], '{}'::text[], null, null, false, false, null, 'Sum of boxes 8 and 9: the input tax of the period (s. 34(1)); the apportionment of s. 34(3) is the user''s.', 'tt-vat-act'),
  ('TT', 'TT-VAT-RETURN', '11', 'total', 'VAT payable', '{}'::jsonb, 110, null, array['5']::text[], array['10']::text[], null, null, true, false, null, 'Output tax less allowable input tax when positive (s. 32(1)), paid within the time allowed for the return (s. 35(1)). The penalty of 8 % and the interest of 2 % a month (s. 54) are not modelled.', 'tt-vat-act'),
  ('TT', 'TT-VAT-RETURN', '12', 'total', 'VAT refundable', '{}'::jsonb, 120, null, array['10']::text[], array['5']::text[], null, null, true, false, null, 'The excess of allowable input tax over output tax (s. 32(2)): a refund is due even where output tax is nil. The Board satisfies it by paying it or by setting it against other tax owed (s. 35(2)); interest of 1 % a month runs on a refund outstanding for more than six months (s. 35(3)). The pack only reports box 12.', 'tt-vat-act')
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
  ('TT-IFRS-SME-IS', 'TT', 'default', 'Income statement', 'income_statement', 'IFRS-SME', date '1970-01-01', null, 'Same choice as the statement of financial position: the income statement is presented in the manner of IFRS for SMEs, section 5, with the expenses collapsed to cost of sales, other operating expenses and depreciation. No text of Trinidad and Tobago read prescribes it. The corporate income tax charge (6470) falls in other operating expenses; the Corporation Tax Act was not opened and the tax is not modelled', 'iasb-ifrs-sme', null, null, '{}'::jsonb),
  ('TT-IFRS-SME-SFP', 'TT', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS-SME', date '1970-01-01', null, 'The Companies Act and the Corporation Tax Act of Trinidad and Tobago were not opened for this pack, so no section of either is cited, and none is asserted to prescribe a layout. This statement follows the presentation of IFRS for SMEs (International Accounting Standards Board), section 4: current and non-current assets and liabilities, with equity shown beside them; that is a choice of this pack, not a text the country imposes, and a company reporting under full IFRS presents the same balance sheet with different notes. The numbering and the ranges each line reads are original to this pack. The VAT collected (2100 to 2199) is a current tax liability; the VAT recoverable sits with the receivables (1170 to 1172), unnetted. Cash flows and changes in equity are separate statements this pack does not model', 'iasb-ifrs-sme', 'alone', null, '{}'::jsonb)
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
  ('TT-IFRS-SME-IS', 'REV', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TT-IFRS-SME-IS', 'COST', null, 'Cost of sales', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TT-IFRS-SME-IS', 'GROSS', null, 'Gross profit', '{}'::jsonb, 30, 1, true, array['REV']::text[], array['COST']::text[], null, null, null),
  ('TT-IFRS-SME-IS', 'OTH-INC', null, 'Other income', '{}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TT-IFRS-SME-IS', 'OPEX', null, 'Administrative and other operating expenses', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TT-IFRS-SME-IS', 'DEPR', null, 'Depreciation and amortisation', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TT-IFRS-SME-IS', 'PROFIT', null, 'Profit (loss) for the year', '{}'::jsonb, 70, 1, true, array['GROSS', 'OTH-INC']::text[], array['OPEX', 'DEPR']::text[], null, null, null),
  ('TT-IFRS-SME-SFP', 'A-NC-FIX', 'A-NC', 'Property, plant and equipment', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TT-IFRS-SME-SFP', 'A-NC-INT', 'A-NC', 'Goodwill and other intangible assets', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TT-IFRS-SME-SFP', 'A-NC-OTH', 'A-NC', 'Other non-current assets', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TT-IFRS-SME-SFP', 'A-NC', null, 'Non-current assets', '{}'::jsonb, 40, 1, true, array['A-NC-FIX', 'A-NC-INT', 'A-NC-OTH']::text[], '{}'::text[], null, null, null),
  ('TT-IFRS-SME-SFP', 'A-C-REC', 'A-C', 'Trade and other receivables', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TT-IFRS-SME-SFP', 'A-C-INV', 'A-C', 'Inventories', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TT-IFRS-SME-SFP', 'A-C-OTH', 'A-C', 'Other current assets', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TT-IFRS-SME-SFP', 'A-C-PRE', 'A-C', 'Prepayments and deposits paid', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TT-IFRS-SME-SFP', 'A-C-CASH', 'A-C', 'Cash and cash equivalents', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TT-IFRS-SME-SFP', 'A-C', null, 'Current assets', '{}'::jsonb, 100, 1, true, array['A-C-REC', 'A-C-INV', 'A-C-OTH', 'A-C-PRE', 'A-C-CASH']::text[], '{}'::text[], null, null, null),
  ('TT-IFRS-SME-SFP', 'A-TOT', null, 'Total assets', '{}'::jsonb, 110, 1, true, array['A-NC', 'A-C']::text[], '{}'::text[], null, null, null),
  ('TT-IFRS-SME-SFP', 'E-CAP', 'E-TOT', 'Share capital and reserves', '{}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TT-IFRS-SME-SFP', 'E-RET', 'E-TOT', 'Retained earnings', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TT-IFRS-SME-SFP', 'E-RESULT', 'E-TOT', 'Profit or loss for the year, not yet allocated', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TT-IFRS-SME-SFP', 'E-TOT', null, 'Total equity', '{}'::jsonb, 150, 1, true, array['E-CAP', 'E-RET', 'E-RESULT']::text[], '{}'::text[], null, null, null),
  ('TT-IFRS-SME-SFP', 'L-NC', 'L-TOT', 'Non-current liabilities', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TT-IFRS-SME-SFP', 'L-C-PAY', 'L-C', 'Trade and other payables', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TT-IFRS-SME-SFP', 'L-C-TAX', 'L-C', 'Current tax liabilities, including VAT collected', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TT-IFRS-SME-SFP', 'L-C-OTH', 'L-C', 'Other current liabilities', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TT-IFRS-SME-SFP', 'L-C', null, 'Current liabilities', '{}'::jsonb, 200, 1, true, array['L-C-PAY', 'L-C-TAX', 'L-C-OTH']::text[], '{}'::text[], null, null, null),
  ('TT-IFRS-SME-SFP', 'L-TOT', null, 'Total liabilities', '{}'::jsonb, 210, 1, true, array['L-NC', 'L-C']::text[], '{}'::text[], null, null, null),
  ('TT-IFRS-SME-SFP', 'EL-TOT', null, 'Total equity and liabilities', '{}'::jsonb, 220, 1, true, array['E-TOT', 'L-TOT']::text[], '{}'::text[], null, null, null)
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
 where r.statement_code in ('TT-IFRS-SME-IS', 'TT-IFRS-SME-SFP')
   and (r.statement_code, r.line_code, r.sequence) not in (
     values ('TT-IFRS-SME-IS', 'REV', 10),
            ('TT-IFRS-SME-IS', 'COST', 10),
            ('TT-IFRS-SME-IS', 'OTH-INC', 10),
            ('TT-IFRS-SME-IS', 'OPEX', 10),
            ('TT-IFRS-SME-IS', 'DEPR', 10),
            ('TT-IFRS-SME-SFP', 'A-NC-FIX', 10),
            ('TT-IFRS-SME-SFP', 'A-NC-INT', 10),
            ('TT-IFRS-SME-SFP', 'A-NC-OTH', 10),
            ('TT-IFRS-SME-SFP', 'A-C-REC', 10),
            ('TT-IFRS-SME-SFP', 'A-C-INV', 10),
            ('TT-IFRS-SME-SFP', 'A-C-OTH', 10),
            ('TT-IFRS-SME-SFP', 'A-C-PRE', 10),
            ('TT-IFRS-SME-SFP', 'A-C-CASH', 10),
            ('TT-IFRS-SME-SFP', 'E-CAP', 10),
            ('TT-IFRS-SME-SFP', 'E-RET', 10),
            ('TT-IFRS-SME-SFP', 'E-RESULT', 10),
            ('TT-IFRS-SME-SFP', 'E-RESULT', 20),
            ('TT-IFRS-SME-SFP', 'E-RESULT', 30),
            ('TT-IFRS-SME-SFP', 'E-RESULT', 40),
            ('TT-IFRS-SME-SFP', 'L-NC', 10),
            ('TT-IFRS-SME-SFP', 'L-C-PAY', 10),
            ('TT-IFRS-SME-SFP', 'L-C-TAX', 10),
            ('TT-IFRS-SME-SFP', 'L-C-TAX', 20),
            ('TT-IFRS-SME-SFP', 'L-C-OTH', 10),
            ('TT-IFRS-SME-SFP', 'L-C-OTH', 20)
   );

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('TT-IFRS-SME-IS', 'REV', 10, 'code_range', '4000', '4699', null, 'any'),
    ('TT-IFRS-SME-IS', 'COST', 10, 'code_range', '5000', '5099', null, 'any'),
    ('TT-IFRS-SME-IS', 'OTH-INC', 10, 'code_range', '4700', '4799', null, 'any'),
    ('TT-IFRS-SME-IS', 'OPEX', 10, 'code_range', '6000', '6799', null, 'any'),
    ('TT-IFRS-SME-IS', 'DEPR', 10, 'code_range', '6800', '6899', null, 'any'),
    ('TT-IFRS-SME-SFP', 'A-NC-FIX', 10, 'code_range', '1600', '1799', null, 'any'),
    ('TT-IFRS-SME-SFP', 'A-NC-INT', 10, 'code_range', '1800', '1899', null, 'any'),
    ('TT-IFRS-SME-SFP', 'A-NC-OTH', 10, 'code_range', '1900', '1999', null, 'any'),
    ('TT-IFRS-SME-SFP', 'A-C-REC', 10, 'code_range', '1100', '1199', null, 'any'),
    ('TT-IFRS-SME-SFP', 'A-C-INV', 10, 'code_range', '1200', '1299', null, 'any'),
    ('TT-IFRS-SME-SFP', 'A-C-OTH', 10, 'code_range', '1300', '1399', null, 'any'),
    ('TT-IFRS-SME-SFP', 'A-C-PRE', 10, 'code_range', '1400', '1499', null, 'any'),
    ('TT-IFRS-SME-SFP', 'A-C-CASH', 10, 'code_range', '1000', '1099', null, 'any'),
    ('TT-IFRS-SME-SFP', 'E-CAP', 10, 'code_range', '3000', '3199', null, 'any'),
    ('TT-IFRS-SME-SFP', 'E-RET', 10, 'code_range', '3200', '3299', null, 'any'),
    ('TT-IFRS-SME-SFP', 'E-RESULT', 10, 'code_range', '4000', '4699', null, 'any'),
    ('TT-IFRS-SME-SFP', 'E-RESULT', 20, 'code_range', '4700', '4799', null, 'any'),
    ('TT-IFRS-SME-SFP', 'E-RESULT', 30, 'code_range', '5000', '5099', null, 'any'),
    ('TT-IFRS-SME-SFP', 'E-RESULT', 40, 'code_range', '6000', '6899', null, 'any'),
    ('TT-IFRS-SME-SFP', 'L-NC', 10, 'code_range', '2300', '2399', null, 'any'),
    ('TT-IFRS-SME-SFP', 'L-C-PAY', 10, 'code_range', '2000', '2059', null, 'any'),
    ('TT-IFRS-SME-SFP', 'L-C-TAX', 10, 'code_range', '2060', '2069', null, 'any'),
    ('TT-IFRS-SME-SFP', 'L-C-TAX', 20, 'code_range', '2100', '2199', null, 'any'),
    ('TT-IFRS-SME-SFP', 'L-C-OTH', 10, 'code_range', '2070', '2099', null, 'any'),
    ('TT-IFRS-SME-SFP', 'L-C-OTH', 20, 'code_range', '2200', '2299', null, 'any')
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
  ('TT', 'Trinidad and Tobago', '{}'::jsonb, array['en']::text[], 'TTD', '1100', '2000', '2090', '6490', '3200', '4000', '5010', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6450', '4750', '6460', null, null, '2100', '1172', null, null)
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
  numbering_legal_reference     = 'Value Added Tax Act, s. 36(2)(b) — a tax invoice carries an identifying serial number and the date on which it was given; s. 36(1) — a registered person making a commercial supply above twenty dollars gives the recipient a tax invoice; s. 37 — credit and debit notes. The Act, as read for this pack, does not say that the series may have no gap, which is why `numbering` is `sequential` and not `gapless`; `number_format` is a convention this pack proposes',
  numbering_source_key          = 'tt-vat-act',
  payment_terms_legal_reference = 'No text of Trinidad and Tobago read for this pack sets a payment term between two businesses or a rate of interest on a commercial debt paid late: the penalty of eight per cent and the interest of two per cent a month or part of a month (s. 54) are charges on a person who owes the Board, not terms between two businesses. `legal_payment_days` and `late_payment_reference` are empty',
  payment_terms_source_key      = 'tt-vat-act',
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Value Added Tax Act, s. 17(1) — a supply takes place when an invoice for it is given by the supplier, when payment is made for it, or when the goods are made available or the services rendered, whichever is the earlier (the special cases of s. 17(2) to (4), hire purchase, continuous services and progress payments, are not modelled). `earliest_of_delivery_or_payment` is the nearest value of the closed vocabulary: it leaves out the invoice date, which s. 17(1)(a) also makes a tax point, and is to be checked by a reviewer',
  tax_point_source_key          = 'tt-vat-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No text of Trinidad and Tobago read for this pack obliges a business to issue or accept an electronic invoice: the Value Added Tax Act, s. 36, asks for a tax invoice with the particulars it lists, on paper or otherwise, without naming a platform, a format or a Peppol profile. No Peppol authority for the country was looked for. `profile`, `party_scheme` and `vat_scheme` are null: there is no domestic profile to name',
  einvoice_source_key           = 'tt-vat-act',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'TT';
