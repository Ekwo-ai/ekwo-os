-- Ekwo OS — Saint Lucia: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/lc at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build lc`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Value Added Tax Act, Cap. 15.42 (Act No. 7 of 2012), enactment as published by the Government of Saint Lucia, with the First Schedule (zero-rated supplies) and the Second Schedule (exempt supplies); amendments to the Schedules by Order after 2012 are not applied (Government of Saint Lucia)
--     https://www.govt.lc/media.govt.lc/www/resources/legislation/Value%20Added%20Tax%20Act%20No.7%20of%202012.pdf
--   Value Added Tax Act, Cap. 15.42, revised text of section 10 (rate of tax) — 12.5 %, as amended by S.I. 101 of 2016, and the Minister's power to set the rate for the tourism sector by Order (Attorney General's Chambers, Saint Lucia (Laws of Saint Lucia))
--     https://www.attorneygeneralchambers.com/laws-of-saint-lucia/value-added-tax-act/section-10
--   Value Added Tax (Rate of Tax) (Tourism Sector Goods and Services) Order, 2020 (S.I. 188 of 2020), in force 1 December 2020 — 7 % on tourism accommodation, 10 % on restaurant food and beverages, water sports, tours and attractions (Government of Saint Lucia, Extraordinary Gazette of 23 November 2020)
--     https://npc.govt.lc/files/documents/gazettesx/2020/11/Extraordinary%20Gazette%20November%2023,%202020.pdf
--   Service page "File VAT Return" — the Value Added Tax Remittance Form and Return, due within 21 days after the end of the tax period, lodged with the VAT Section of the Inland Revenue Department (Ministry of Finance, Government of Saint Lucia)
--     https://finance.govt.lc/services/file-vat-return
--   IFRS for SMEs Accounting Standard (IFRS Foundation / International Accounting Standards Board)
--     https://www.ifrs.org/issued-standards/ifrs-for-smes/
--   Service page "VAT registration" of the Government of Saint Lucia — registration with the VAT Section of the Inland Revenue Department (the online filing portal efiling.govt.lc is not described there) (Ministry of Finance, Government of Saint Lucia)
--     https://finance.govt.lc/services/vat-registration
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('LC', 'Saint Lucia', '0.1.0', date '2026-10-19', '20261011120000', 'community', null, null, '05635e63c1f61566884bbde56e4261b8eb985d5af1e7e35851f1710c523851ae', '[{"key":"lc-vat-act","title":"Value Added Tax Act, Cap. 15.42 (Act No. 7 of 2012), enactment as published by the Government of Saint Lucia, with the First Schedule (zero-rated supplies) and the Second Schedule (exempt supplies); amendments to the Schedules by Order after 2012 are not applied","publisher":"Government of Saint Lucia","url":"https://www.govt.lc/media.govt.lc/www/resources/legislation/Value%20Added%20Tax%20Act%20No.7%20of%202012.pdf","consulted_on":"2026-10-19","kind":"law"},{"key":"lc-vat-rate","title":"Value Added Tax Act, Cap. 15.42, revised text of section 10 (rate of tax) — 12.5 %, as amended by S.I. 101 of 2016, and the Minister''s power to set the rate for the tourism sector by Order","publisher":"Attorney General''s Chambers, Saint Lucia (Laws of Saint Lucia)","url":"https://www.attorneygeneralchambers.com/laws-of-saint-lucia/value-added-tax-act/section-10","consulted_on":"2026-10-19","kind":"law"},{"key":"lc-tourism-order-2020","title":"Value Added Tax (Rate of Tax) (Tourism Sector Goods and Services) Order, 2020 (S.I. 188 of 2020), in force 1 December 2020 — 7 % on tourism accommodation, 10 % on restaurant food and beverages, water sports, tours and attractions","publisher":"Government of Saint Lucia, Extraordinary Gazette of 23 November 2020","url":"https://npc.govt.lc/files/documents/gazettesx/2020/11/Extraordinary%20Gazette%20November%2023,%202020.pdf","consulted_on":"2026-10-19","kind":"regulation"},{"key":"lc-vat-return-service","title":"Service page \"File VAT Return\" — the Value Added Tax Remittance Form and Return, due within 21 days after the end of the tax period, lodged with the VAT Section of the Inland Revenue Department","publisher":"Ministry of Finance, Government of Saint Lucia","url":"https://finance.govt.lc/services/file-vat-return","consulted_on":"2026-10-19","kind":"guidance"},{"key":"iasb-ifrs-sme","title":"IFRS for SMEs Accounting Standard","publisher":"IFRS Foundation / International Accounting Standards Board","url":"https://www.ifrs.org/issued-standards/ifrs-for-smes/","consulted_on":"2026-10-19","kind":"standard"},{"key":"lc-vat-portal","title":"Service page \"VAT registration\" of the Government of Saint Lucia — registration with the VAT Section of the Inland Revenue Department (the online filing portal efiling.govt.lc is not described there)","publisher":"Ministry of Finance, Government of Saint Lucia","url":"https://finance.govt.lc/services/vat-registration","consulted_on":"2026-10-19","kind":"portal"}]'::jsonb)
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
  ('LC', 'default', 'Saint Lucia reference chart of accounts', '{}'::jsonb, true, 'companies', array['LC-IFRS-SME-IS', 'LC-IFRS-SME-SFP']::text[], null, 'This pack found no legal chart of accounts in Saint Lucia, and opened neither the Companies Act nor the Income Tax Act: no section of either is cited. What the Value Added Tax Act, Cap. 15.42, asks of a taxable person is that tax invoices be issued (s. 34) and records kept. This chart is original: four digits, blocked so that each range reaches one line of a statement of financial position and an income statement presented in the manner of IFRS for SMEs, which is a choice of this pack and not a text the country imposes. The settlement account of the VAT return (2100, refundable 1172) is distinct from the accounts the tax posts to (2101, 2102 and 2103 collected, 1170 and 1171 recoverable). See README.md', 'lc-vat-act')
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
  ('LC', 'default', '1000', 'Cash on hand', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('LC', 'default', '1010', 'Bank current account', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('LC', 'default', '1020', 'Bank savings account', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('LC', 'default', '1030', 'Foreign currency bank account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('LC', 'default', '1040', 'Payment gateway and card clearing account', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('LC', 'default', '1050', 'Fixed deposits of three months or less', '{}'::jsonb, 'asset_cash', false, null, 60),
  ('LC', 'default', '1060', 'Cash in transit', '{}'::jsonb, 'asset_cash', false, null, 70),
  ('LC', 'default', '1100', 'Trade debtors', '{}'::jsonb, 'asset_receivable', true, null, 80),
  ('LC', 'default', '1105', 'Allowance for expected credit losses', '{}'::jsonb, 'asset_current', false, null, 90),
  ('LC', 'default', '1110', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 100),
  ('LC', 'default', '1120', 'Other debtors', '{}'::jsonb, 'asset_current', false, null, 110),
  ('LC', 'default', '1130', 'Accrued income', '{}'::jsonb, 'asset_current', false, null, 120),
  ('LC', 'default', '1140', 'Staff advances and loans to employees', '{}'::jsonb, 'asset_current', false, null, 130),
  ('LC', 'default', '1150', 'Customs duty deposits paid', '{}'::jsonb, 'asset_current', false, null, 140),
  ('LC', 'default', '1160', 'Corporation tax recoverable', '{}'::jsonb, 'asset_current', false, null, 150),
  ('LC', 'default', '1170', 'VAT recoverable — local purchases', '{}'::jsonb, 'asset_current', false, null, 160),
  ('LC', 'default', '1171', 'VAT recoverable — imports paid to the Comptroller of Customs', '{}'::jsonb, 'asset_current', false, null, 170),
  ('LC', 'default', '1172', 'VAT refundable — settlement of the return', '{}'::jsonb, 'asset_current', true, null, 180),
  ('LC', 'default', '1200', 'Inventory — raw materials and consumables', '{}'::jsonb, 'asset_current', false, null, 190),
  ('LC', 'default', '1210', 'Inventory — work in progress', '{}'::jsonb, 'asset_current', false, null, 200),
  ('LC', 'default', '1220', 'Inventory — finished goods and goods for resale', '{}'::jsonb, 'asset_current', false, null, 210),
  ('LC', 'default', '1230', 'Goods in transit', '{}'::jsonb, 'asset_current', false, null, 220),
  ('LC', 'default', '1300', 'Fixed deposits of more than three months', '{}'::jsonb, 'asset_current', false, null, 230),
  ('LC', 'default', '1310', 'Listed investments held for trading', '{}'::jsonb, 'asset_current', false, null, 240),
  ('LC', 'default', '1320', 'Amounts due from related companies — non-trade', '{}'::jsonb, 'asset_current', false, null, 250),
  ('LC', 'default', '1400', 'Prepaid expenses', '{}'::jsonb, 'asset_prepayments', false, null, 260),
  ('LC', 'default', '1410', 'Rental and utility deposits paid', '{}'::jsonb, 'asset_prepayments', false, null, 270),
  ('LC', 'default', '1420', 'Deposits paid to suppliers', '{}'::jsonb, 'asset_prepayments', false, null, 280),
  ('LC', 'default', '1600', 'Leasehold land and buildings', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('LC', 'default', '1610', 'Leasehold improvements', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('LC', 'default', '1620', 'Furniture and fixtures', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('LC', 'default', '1630', 'Office equipment', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('LC', 'default', '1640', 'Computer equipment and software', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('LC', 'default', '1650', 'Motor vehicles', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('LC', 'default', '1660', 'Plant and machinery', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('LC', 'default', '1670', 'Right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('LC', 'default', '1690', 'Accumulated depreciation — property plant and equipment', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('LC', 'default', '1695', 'Accumulated depreciation — right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 380),
  ('LC', 'default', '1800', 'Goodwill', '{}'::jsonb, 'asset_non_current', false, null, 390),
  ('LC', 'default', '1810', 'Other intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 400),
  ('LC', 'default', '1820', 'Accumulated amortisation — intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 410),
  ('LC', 'default', '1900', 'Investments in subsidiaries', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('LC', 'default', '1910', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('LC', 'default', '1920', 'Other long-term investments', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('LC', 'default', '1930', 'Rental and utility deposits — non-current', '{}'::jsonb, 'asset_non_current', false, null, 450),
  ('LC', 'default', '1990', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('LC', 'default', '2000', 'Trade creditors', '{}'::jsonb, 'liability_payable', true, null, 470),
  ('LC', 'default', '2010', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 480),
  ('LC', 'default', '2020', 'Accruals', '{}'::jsonb, 'liability_current', false, null, 490),
  ('LC', 'default', '2030', 'Customer deposits and advances received', '{}'::jsonb, 'liability_current', false, null, 500),
  ('LC', 'default', '2040', 'Salaries and wages payable', '{}'::jsonb, 'liability_current', false, null, 510),
  ('LC', 'default', '2050', 'National Insurance Corporation contributions payable', '{}'::jsonb, 'liability_current', false, null, 520),
  ('LC', 'default', '2060', 'Corporation tax payable', '{}'::jsonb, 'liability_current', false, null, 530),
  ('LC', 'default', '2070', 'Payroll deductions payable', '{}'::jsonb, 'liability_current', false, null, 540),
  ('LC', 'default', '2071', 'Customs duty payable', '{}'::jsonb, 'liability_current', false, null, 550),
  ('LC', 'default', '2072', 'Land tax payable', '{}'::jsonb, 'liability_current', false, null, 560),
  ('LC', 'default', '2073', 'Other government charges payable', '{}'::jsonb, 'liability_current', false, null, 570),
  ('LC', 'default', '2080', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 580),
  ('LC', 'default', '2090', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 590),
  ('LC', 'default', '2100', 'VAT payable — settlement of the return', '{}'::jsonb, 'liability_current', true, null, 600),
  ('LC', 'default', '2101', 'VAT collected — standard rate (12.5 %)', '{}'::jsonb, 'liability_current', false, null, 610),
  ('LC', 'default', '2102', 'VAT collected — tourism services rate (10 %)', '{}'::jsonb, 'liability_current', false, null, 620),
  ('LC', 'default', '2103', 'VAT collected — tourism accommodation rate (7 %)', '{}'::jsonb, 'liability_current', false, null, 625),
  ('LC', 'default', '2200', 'Corporate credit card payable', '{}'::jsonb, 'liability_credit_card', false, null, 630),
  ('LC', 'default', '2300', 'Bank borrowings — non-current', '{}'::jsonb, 'liability_non_current', false, null, 640),
  ('LC', 'default', '2310', 'Lease liabilities — non-current', '{}'::jsonb, 'liability_non_current', false, null, 650),
  ('LC', 'default', '2320', 'Amounts due to shareholders — non-current', '{}'::jsonb, 'liability_non_current', false, null, 660),
  ('LC', 'default', '2390', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 670),
  ('LC', 'default', '3000', 'Issued and paid-up share capital', '{}'::jsonb, 'equity', false, null, 680),
  ('LC', 'default', '3100', 'Share premium', '{}'::jsonb, 'equity', false, null, 690),
  ('LC', 'default', '3110', 'Capital reserve', '{}'::jsonb, 'equity', false, null, 700),
  ('LC', 'default', '3200', 'Retained profits', '{}'::jsonb, 'equity_retained', false, null, 710),
  ('LC', 'default', '4000', 'Sale of goods', '{}'::jsonb, 'income', false, null, 720),
  ('LC', 'default', '4010', 'Rendering of services', '{}'::jsonb, 'income', false, null, 730),
  ('LC', 'default', '4700', 'Realised exchange gains', '{}'::jsonb, 'income_other', false, null, 740),
  ('LC', 'default', '4710', 'Unrealised exchange gains', '{}'::jsonb, 'income_other', false, null, 750),
  ('LC', 'default', '4720', 'Interest income', '{}'::jsonb, 'income_other', false, null, 760),
  ('LC', 'default', '4730', 'Sundry income', '{}'::jsonb, 'income_other', false, null, 770),
  ('LC', 'default', '4750', 'Gain on disposal of fixed assets', '{}'::jsonb, 'income_other', false, null, 780),
  ('LC', 'default', '5000', 'Cost of goods sold', '{}'::jsonb, 'expense_direct_cost', false, null, 790),
  ('LC', 'default', '5010', 'Purchases', '{}'::jsonb, 'expense_direct_cost', false, null, 800),
  ('LC', 'default', '5020', 'Freight inwards', '{}'::jsonb, 'expense_direct_cost', false, null, 810),
  ('LC', 'default', '5025', 'Customs duty on imports', '{}'::jsonb, 'expense_direct_cost', false, null, 820),
  ('LC', 'default', '5030', 'Direct labour', '{}'::jsonb, 'expense_direct_cost', false, null, 830),
  ('LC', 'default', '6000', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 840),
  ('LC', 'default', '6010', 'Staff salaries and wages', '{}'::jsonb, 'expense', false, null, 850),
  ('LC', 'default', '6020', 'Pension contributions', '{}'::jsonb, 'expense', false, null, 860),
  ('LC', 'default', '6025', 'Employer payroll contributions', '{}'::jsonb, 'expense', false, null, 870),
  ('LC', 'default', '6026', 'National Insurance Corporation — employer contribution', '{}'::jsonb, 'expense', false, null, 880),
  ('LC', 'default', '6030', 'Staff welfare and benefits', '{}'::jsonb, 'expense', false, null, 890),
  ('LC', 'default', '6100', 'Rent and rates', '{}'::jsonb, 'expense', false, null, 900),
  ('LC', 'default', '6110', 'Management fees and building outgoings', '{}'::jsonb, 'expense', false, null, 910),
  ('LC', 'default', '6120', 'Utilities', '{}'::jsonb, 'expense', false, null, 920),
  ('LC', 'default', '6130', 'Land tax', '{}'::jsonb, 'expense', false, null, 930),
  ('LC', 'default', '6200', 'Government fees, licences and company registry fees', '{}'::jsonb, 'expense', false, null, 940),
  ('LC', 'default', '6210', 'Auditor''s remuneration', '{}'::jsonb, 'expense', false, null, 950),
  ('LC', 'default', '6220', 'Accounting and company secretarial fees', '{}'::jsonb, 'expense', false, null, 960),
  ('LC', 'default', '6230', 'Legal and professional fees', '{}'::jsonb, 'expense', false, null, 970),
  ('LC', 'default', '6300', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 980),
  ('LC', 'default', '6310', 'Insurance', '{}'::jsonb, 'expense', false, null, 990),
  ('LC', 'default', '6320', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1000),
  ('LC', 'default', '6330', 'Travelling expenses', '{}'::jsonb, 'expense', false, null, 1010),
  ('LC', 'default', '6340', 'Entertainment expenses', '{}'::jsonb, 'expense', false, null, 1020),
  ('LC', 'default', '6350', 'Advertising and promotion', '{}'::jsonb, 'expense', false, null, 1030),
  ('LC', 'default', '6360', 'Printing, stationery and postage', '{}'::jsonb, 'expense', false, null, 1040),
  ('LC', 'default', '6370', 'Telecommunications', '{}'::jsonb, 'expense', false, null, 1050),
  ('LC', 'default', '6380', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1060),
  ('LC', 'default', '6390', 'Sundry office expenses', '{}'::jsonb, 'expense', false, null, 1070),
  ('LC', 'default', '6400', 'Allowance for expected credit losses charged', '{}'::jsonb, 'expense', false, null, 1080),
  ('LC', 'default', '6410', 'Interest expense on bank borrowings', '{}'::jsonb, 'expense', false, null, 1090),
  ('LC', 'default', '6420', 'Interest expense on lease liabilities', '{}'::jsonb, 'expense', false, null, 1100),
  ('LC', 'default', '6450', 'Realised exchange losses', '{}'::jsonb, 'expense', false, null, 1110),
  ('LC', 'default', '6455', 'Unrealised exchange losses', '{}'::jsonb, 'expense', false, null, 1120),
  ('LC', 'default', '6460', 'Loss on disposal of fixed assets', '{}'::jsonb, 'expense', false, null, 1130),
  ('LC', 'default', '6470', 'Corporation tax charge', '{}'::jsonb, 'expense', false, null, 1140),
  ('LC', 'default', '6480', 'Deferred tax charge', '{}'::jsonb, 'expense', false, null, 1150),
  ('LC', 'default', '6490', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1160),
  ('LC', 'default', '6800', 'Depreciation and amortisation', '{}'::jsonb, 'expense_depreciation', false, null, 1170)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('LC', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('LC', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('LC', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('LC', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('LC', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('LC', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('LC', 'LC-P-10', 'Purchase of restaurant, water sport, tour or attraction services, VAT 10 %', '{}'::jsonb, 'A purchase of the tourism services taxed at ten per cent', 'percent', 10, 'purchase', 'domestic', date '2020-12-01', null, 'Value Added Tax (Rate of Tax) (Tourism Sector Goods and Services) Order, 2020 (S.I. 188 of 2020), art. 3(b), and Act s. 30 — input tax at ten per cent is deductible on the same conditions as at 12.5 %. Base to box 12, tax to box 14.', null, null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'lc-tourism-order-2020', null, null, null, null),
  ('LC', 'LC-P-12.5', 'Purchase, VAT 12.5 %', '{}'::jsonb, 'A purchase from a taxable person, standard-rated, with a tax invoice', 'percent', 12.5, 'purchase', 'domestic', date '2017-02-01', null, 'Value Added Tax Act, Cap. 15.42 (Act No. 7 of 2012), s. 29(1) and s. 30(1)(a) — the tax payable is the output tax less the input tax deduction allowed, which covers the tax on taxable supplies made to the person for use in a taxable activity, on a tax invoice (s. 34) or a tax credit or debit note (s. 35). Section 31 denies the deduction for passenger vehicles, entertainment and the like, and s. 30 allocates a mixed use: both are the user''s. Base to box 12, tax to box 14.', null, null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'lc-vat-act', null, null, null, null),
  ('LC', 'LC-P-12.5-IMP', 'Import of goods, VAT 12.5 %', '{}'::jsonb, 'Import of goods, VAT paid to the Comptroller of Customs', 'percent', 12.5, 'purchase', 'import', date '2017-02-01', null, 'Value Added Tax Act, Cap. 15.42 (Act No. 7 of 2012), s. 9(1)(b), s. 10(1) and s. 22 to 25 — 12.5 % of the value of a taxable import of goods, paid to the Comptroller of Customs on the import; the value for tax (s. 22 and following) includes duty and freight, which the pack does not compute: it applies 12.5 % to the invoice value and the customs entry is the user''s. The tax paid is deductible (s. 30(1)(a)). Base to box 11, tax to box 13.', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'lc-vat-act', null, null, null, null),
  ('LC', 'LC-P-7', 'Purchase of tourism accommodation, VAT 7 %', '{}'::jsonb, 'A purchase of tourism accommodation taxed at seven per cent', 'percent', 7, 'purchase', 'domestic', date '2020-12-01', null, 'Value Added Tax (Rate of Tax) (Tourism Sector Goods and Services) Order, 2020 (S.I. 188 of 2020), art. 3(a), and Act s. 30 — input tax at seven per cent is deductible on the same conditions as at 12.5 %. Base to box 12, tax to box 14.', null, null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'lc-tourism-order-2020', null, null, null, null),
  ('LC', 'LC-P-EX', 'Purchase without VAT', '{}'::jsonb, 'A purchase of a zero-rated or exempt supply, or from a person not registered', 'percent', 0, 'purchase', 'exempt', date '2017-02-01', null, 'Value Added Tax Act, Cap. 15.42 (Act No. 7 of 2012), s. 16, s. 17 and the First and Second Schedules — a zero-rated supply carries tax at zero per cent and an exempt supply none, so the purchaser has no input tax to deduct; the value is still reported among the purchases of the period (box 12).', null, null, 120, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'lc-vat-act', null, null, null, null),
  ('LC', 'LC-S-0', 'Zero-rated supply (export)', '{}'::jsonb, 'An export of goods or services, zero-rated', 'percent', 0, 'sale', 'export', date '2017-02-01', null, 'Value Added Tax Act, Cap. 15.42 (Act No. 7 of 2012), s. 16 and First Schedule, para. 2(1)(a) and (b) (goods entered for export and exported, with the documentary proof the Comptroller accepts, s. 16(4) and para. 3) and para. 2(2)(a) to (d) (services connected with land abroad, supplied to a non-resident, to a free zone business or to a foreign telecommunication carrier) — zero per cent. A zero-rated supply is a taxable supply: the input tax of what produces it stays deductible (s. 30), and s. 57(5) lets a person whose supplies are half zero-rated claim the excess at once. Base to box 4.', 'G', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'lc-vat-act', null, null, null, null),
  ('LC', 'LC-S-10', 'Sale of restaurant food and beverages, water sports, tours and attractions, VAT 10 %', '{}'::jsonb, 'Food and beverages of a restaurant, water sports, tours and admission to heritage sites and tourist attractions', 'percent', 10, 'sale', 'domestic', date '2020-12-01', null, 'Value Added Tax (Rate of Tax) (Tourism Sector Goods and Services) Order, 2020 (S.I. 188 of 2020), made under s. 10(2) of the Act, in force 1 December 2020, art. 3(b) — ten per cent on food and beverages, alcoholic beverages included, supplied by a restaurant; water sports; tours by land, air or sea within Saint Lucia (including the tour operator''s own transport as part of the package, but not transport it buys in); and admission to heritage sites and other tourist attractions. The pack does not decide which supplies qualify. Base to box 2, tax to box 8.', 'S', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'lc-tourism-order-2020', null, null, null, null),
  ('LC', 'LC-S-12.5', 'Sale, VAT 12.5 %', '{}'::jsonb, 'A taxable supply made in Saint Lucia by a taxable person, standard-rated', 'percent', 12.5, 'sale', 'domestic', date '2017-02-01', null, 'Value Added Tax Act, Cap. 15.42 (Act No. 7 of 2012), s. 9(1)(a) and s. 10(1) — value added tax on every taxable supply by a taxable person at 12.5 % (the 15 % of the 2012 enactment replaced by S.I. 101 of 2016, in force 1 February 2017, which is the valid_from; the revised text of s. 10 on the Attorney General''s Chambers site shows 12.5 %). The tax is accounted for by the supplier (s. 9(2)(a)) and enters the net tax of s. 29. The base posts to box 1 net of the tax, the tax to box 7 (box numbers are this pack''s, see tax_report.json).', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'lc-vat-rate', null, null, null, null),
  ('LC', 'LC-S-12.5-INC', 'Retail sale, VAT 12.5 %, the price includes the tax', '{}'::jsonb, 'A standard-rated sale whose price already holds the VAT', 'percent', 12.5, 'sale', 'domestic', date '2017-02-01', null, 'Value Added Tax Act, Cap. 15.42 (Act No. 7 of 2012), s. 10(1) at 12.5 %, with the tax extracted from a price that includes it — what price_include does: 112.50 holds 100.00 and 12.50. Same boxes as LC-S-12.5.', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, true, false, null, 'lc-vat-rate', null, null, null, null),
  ('LC', 'LC-S-7', 'Sale of tourism accommodation, VAT 7 %', '{}'::jsonb, 'The supply of a tourism accommodation service: sleeping accommodation in the tourism sector, with or without related facilities', 'percent', 7, 'sale', 'domestic', date '2020-12-01', null, 'Value Added Tax (Rate of Tax) (Tourism Sector Goods and Services) Order, 2020 (S.I. 188 of 2020), art. 2 and 3(a) — seven per cent on a supply of a tourism accommodation service, "the supply of a service for sleeping accommodation in the tourism sector with or without related facilities for consideration". The Order revokes the earlier hotel order of 2014. Base to box 3, tax to box 9.', 'S', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'lc-tourism-order-2020', null, null, null, null),
  ('LC', 'LC-S-EX', 'Exempt supply', '{}'::jsonb, 'A supply of the Second Schedule (financial services, medical services, education, residential sale and rent, lotteries), outside the tax', 'percent', 0, 'sale', 'exempt', date '2017-02-01', null, 'Value Added Tax Act, Cap. 15.42 (Act No. 7 of 2012), s. 17 and Second Schedule, para. 2 — exempt supplies include financial services, medical services other than cosmetic ones, care of the aged and disabled, education services and supplies, the sale of a dwelling and its rental, agricultural land, and games of chance run by non-profit organisations and lotteries. A supply that would be zero-rated is not exempt (s. 17(3)). The input tax of what is acquired to make an exempt supply is not deductible (s. 30). Base to box 5.', 'E', null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'lc-vat-act', null, null, null, null),
  ('LC', 'LC-S-Z', 'Zero-rated supply in Saint Lucia', '{}'::jsonb, 'A domestic supply of the First Schedule at zero per cent (fuel, water and sewerage, electricity, fresh eggs, uncooked pasta, live animals other than pets)', 'percent', 0, 'sale', 'domestic', date '2017-02-01', null, 'Value Added Tax Act, Cap. 15.42 (Act No. 7 of 2012), s. 16 and First Schedule, para. 2(1)(g), (h), (j), (k) and 2(2)(e), (f) — zero per cent on live animals other than pets, fuel (the customs tariff headings of para. 1), fresh eggs and uncooked pasta, ventilated boxes for agricultural produce, water and sewerage supplied by the Saint Lucia Water and Sewerage Company and electricity supplied by Saint Lucia Electricity Services Limited. The Schedule is amended by Order (for instance the temporary zero-rating of building materials) and the pack does not follow the amendments: the user checks the item against the current Schedule. Base to box 4.', 'Z', null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'lc-vat-act', null, null, null, null)
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
    ('LC-P-10', 'invoice', 'base', 100, null, '12', array['12']::text[], 100, 'LC-VAT-RETURN', 10),
    ('LC-P-10', 'invoice', 'tax', 100, '1170', '14', array['14']::text[], 100, 'LC-VAT-RETURN', 20),
    ('LC-P-10', 'credit_note', 'base', 100, null, '12', array['12']::text[], -100, 'LC-VAT-RETURN', 10),
    ('LC-P-10', 'credit_note', 'tax', 100, '1170', '14', array['14']::text[], -100, 'LC-VAT-RETURN', 20),
    ('LC-P-12.5', 'invoice', 'base', 100, null, '12', array['12']::text[], 100, 'LC-VAT-RETURN', 10),
    ('LC-P-12.5', 'invoice', 'tax', 100, '1170', '14', array['14']::text[], 100, 'LC-VAT-RETURN', 20),
    ('LC-P-12.5', 'credit_note', 'base', 100, null, '12', array['12']::text[], -100, 'LC-VAT-RETURN', 10),
    ('LC-P-12.5', 'credit_note', 'tax', 100, '1170', '14', array['14']::text[], -100, 'LC-VAT-RETURN', 20),
    ('LC-P-12.5-IMP', 'invoice', 'base', 100, null, '11', array['11']::text[], 100, 'LC-VAT-RETURN', 10),
    ('LC-P-12.5-IMP', 'invoice', 'tax', 100, '1171', '13', array['13']::text[], 100, 'LC-VAT-RETURN', 20),
    ('LC-P-12.5-IMP', 'credit_note', 'base', 100, null, '11', array['11']::text[], -100, 'LC-VAT-RETURN', 10),
    ('LC-P-12.5-IMP', 'credit_note', 'tax', 100, '1171', '13', array['13']::text[], -100, 'LC-VAT-RETURN', 20),
    ('LC-P-7', 'invoice', 'base', 100, null, '12', array['12']::text[], 100, 'LC-VAT-RETURN', 10),
    ('LC-P-7', 'invoice', 'tax', 100, '1170', '14', array['14']::text[], 100, 'LC-VAT-RETURN', 20),
    ('LC-P-7', 'credit_note', 'base', 100, null, '12', array['12']::text[], -100, 'LC-VAT-RETURN', 10),
    ('LC-P-7', 'credit_note', 'tax', 100, '1170', '14', array['14']::text[], -100, 'LC-VAT-RETURN', 20),
    ('LC-P-EX', 'invoice', 'base', 100, null, '12', array['12']::text[], 100, 'LC-VAT-RETURN', 10),
    ('LC-P-EX', 'credit_note', 'base', 100, null, '12', array['12']::text[], -100, 'LC-VAT-RETURN', 10),
    ('LC-S-0', 'invoice', 'base', 100, null, '4', array['4']::text[], 100, 'LC-VAT-RETURN', 10),
    ('LC-S-0', 'credit_note', 'base', 100, null, '4', array['4']::text[], -100, 'LC-VAT-RETURN', 10),
    ('LC-S-10', 'invoice', 'base', 100, null, '2', array['2']::text[], 100, 'LC-VAT-RETURN', 10),
    ('LC-S-10', 'invoice', 'tax', 100, '2102', '8', array['8']::text[], 100, 'LC-VAT-RETURN', 20),
    ('LC-S-10', 'credit_note', 'base', 100, null, '2', array['2']::text[], -100, 'LC-VAT-RETURN', 10),
    ('LC-S-10', 'credit_note', 'tax', 100, '2102', '8', array['8']::text[], -100, 'LC-VAT-RETURN', 20),
    ('LC-S-12.5', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'LC-VAT-RETURN', 10),
    ('LC-S-12.5', 'invoice', 'tax', 100, '2101', '7', array['7']::text[], 100, 'LC-VAT-RETURN', 20),
    ('LC-S-12.5', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'LC-VAT-RETURN', 10),
    ('LC-S-12.5', 'credit_note', 'tax', 100, '2101', '7', array['7']::text[], -100, 'LC-VAT-RETURN', 20),
    ('LC-S-12.5-INC', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'LC-VAT-RETURN', 10),
    ('LC-S-12.5-INC', 'invoice', 'tax', 100, '2101', '7', array['7']::text[], 100, 'LC-VAT-RETURN', 20),
    ('LC-S-12.5-INC', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'LC-VAT-RETURN', 10),
    ('LC-S-12.5-INC', 'credit_note', 'tax', 100, '2101', '7', array['7']::text[], -100, 'LC-VAT-RETURN', 20),
    ('LC-S-7', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'LC-VAT-RETURN', 10),
    ('LC-S-7', 'invoice', 'tax', 100, '2103', '9', array['9']::text[], 100, 'LC-VAT-RETURN', 20),
    ('LC-S-7', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'LC-VAT-RETURN', 10),
    ('LC-S-7', 'credit_note', 'tax', 100, '2103', '9', array['9']::text[], -100, 'LC-VAT-RETURN', 20),
    ('LC-S-EX', 'invoice', 'base', 100, null, '5', array['5']::text[], 100, 'LC-VAT-RETURN', 10),
    ('LC-S-EX', 'credit_note', 'base', 100, null, '5', array['5']::text[], -100, 'LC-VAT-RETURN', 10),
    ('LC-S-Z', 'invoice', 'base', 100, null, '4', array['4']::text[], 100, 'LC-VAT-RETURN', 10),
    ('LC-S-Z', 'credit_note', 'base', 100, null, '4', array['4']::text[], -100, 'LC-VAT-RETURN', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'LC' and t.code = v.tax_code
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
  ('LC', 'LC-VAT-RETURN', 'VAT return (box layout of this pack)', array['month']::declaration_period[], 'month'::declaration_period, date '2010-02-01', null, 'Value Added Tax Act, Cap. 15.42 (Act No. 7 of 2012), s. 36 — the tax period is the calendar month; s. 37(1) — a taxable person files a return for each tax period within twenty-one calendar days after the end of the period, whether or not tax is payable; s. 37(2) — in the form and manner the Comptroller approves; s. 46(1)(a) — the tax is payable by the due date of the return. The Inland Revenue Department (VAT Section) takes the "Value Added Tax Remittance Form and Return" (the service page of the Ministry of Finance).', true,'day_of_month_after_period'::filing_deadline_rule, 21, null, 'Value Added Tax Act, Cap. 15.42 (Act No. 7 of 2012), s. 37(1) and s. 46(1)(a) — the return is filed within twenty-one calendar days after the end of the tax period and the tax is paid by the same date: for a month, the 21st of the next month; the Ministry of Finance service page says the same. Unpaid tax bears interest at 1.25 % a month or part of a month (s. 33) and a person who fails to pay by the due date is liable to a penalty of ten per cent of the tax due (s. 47(4)); an extension to file does not move the date of payment (s. 38(2)). Weekend roll-forward is not expressible', 'lc-vat-act', null)
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
  ('LC', 'LC-VAT-RETURN', '1', 'base', 'Standard-rated supplies (12.5 %), net of VAT', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Box number and label are this pack''s own: the Value Added Tax Remittance Form and Return of the Inland Revenue Department was not found as a text, so the boxes follow what the Act makes the tax payable carry — the output tax of the period less the input tax deduction allowed (s. 29(1)). Taxable supplies at 12.5 % (s. 10(1)).', 'lc-vat-act'),
  ('LC', 'LC-VAT-RETURN', '2', 'base', 'Restaurant, water sport, tour and attraction supplies (10 %), net of VAT', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Taxable supplies at ten per cent: restaurant food and beverages, water sports, tours and admission to attractions (S.I. 188 of 2020, art. 3(b)).', 'lc-tourism-order-2020'),
  ('LC', 'LC-VAT-RETURN', '3', 'base', 'Tourism accommodation supplies (7 %), net of VAT', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Taxable supplies of tourism accommodation at seven per cent (S.I. 188 of 2020, art. 3(a)).', 'lc-tourism-order-2020'),
  ('LC', 'LC-VAT-RETURN', '4', 'base', 'Zero-rated supplies, including exports', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Taxable supplies at zero per cent (s. 16; First Schedule); they stay on the return (s. 37(1) asks for a return for each tax period).', 'lc-vat-act'),
  ('LC', 'LC-VAT-RETURN', '5', 'base', 'Exempt supplies', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Supplies of the Second Schedule (s. 17), reported for information; the input tax of what is acquired to make them is not deductible (s. 30).', 'lc-vat-act'),
  ('LC', 'LC-VAT-RETURN', '6', 'total', 'Total supplies', '{}'::jsonb, 60, null, array['1', '2', '3', '4', '5']::text[], '{}'::text[], null, null, false, false, null, 'Sum of boxes 1 to 5 — the sum is this pack''s reading, the form is the Comptroller''s (s. 37(2)).', 'lc-vat-act'),
  ('LC', 'LC-VAT-RETURN', '7', 'tax', 'Output tax on standard-rated supplies', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tax at 12.5 % on box 1 (s. 10(1)).', 'lc-vat-act'),
  ('LC', 'LC-VAT-RETURN', '8', 'tax', 'Output tax on restaurant, water sport, tour and attraction supplies', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tax at 10 % on box 2 (S.I. 188 of 2020, art. 3(b)).', 'lc-tourism-order-2020'),
  ('LC', 'LC-VAT-RETURN', '9', 'tax', 'Output tax on tourism accommodation', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tax at 7 % on box 3 (S.I. 188 of 2020, art. 3(a)).', 'lc-tourism-order-2020'),
  ('LC', 'LC-VAT-RETURN', '10', 'total', 'Total output tax for the period', '{}'::jsonb, 100, null, array['7', '8', '9']::text[], '{}'::text[], null, null, false, false, null, 'The output tax chargeable on the taxable supplies of the period (s. 29(1)); a tax credit note posts a negative amount to its own boxes (s. 35).', 'lc-vat-act'),
  ('LC', 'LC-VAT-RETURN', '11', 'base', 'Value of imports', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Goods imported on which tax was paid to the Comptroller of Customs (s. 9(1)(b), s. 22 to 25).', 'lc-vat-act'),
  ('LC', 'LC-VAT-RETURN', '12', 'base', 'Value of local purchases', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Purchases made in Saint Lucia for the taxable activity, taxable, zero-rated and exempt.', 'lc-vat-act'),
  ('LC', 'LC-VAT-RETURN', '13', 'tax', 'VAT paid on imports', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Input tax paid on the import of goods, deductible for use in a taxable activity (s. 30(1)(a)).', 'lc-vat-act'),
  ('LC', 'LC-VAT-RETURN', '14', 'tax', 'VAT paid on local purchases', '{}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Input tax payable on taxable supplies made to the person, deductible on a tax invoice (s. 30, s. 34).', 'lc-vat-act'),
  ('LC', 'LC-VAT-RETURN', '15', 'total', 'Total input tax credits for the period', '{}'::jsonb, 150, null, array['13', '14']::text[], '{}'::text[], null, null, false, false, null, 'Sum of boxes 13 and 14: the input tax deduction allowed for the period (s. 29(1), s. 30).', 'lc-vat-act'),
  ('LC', 'LC-VAT-RETURN', '16', 'total', 'VAT payable', '{}'::jsonb, 160, null, array['10']::text[], array['15']::text[], null, null, true, false, null, 'Output tax less input tax deduction when positive (s. 29(1)), due by the date the return is due (s. 46(1)(a)). Interest (s. 33) and the penalty of s. 47(4) are not modelled.', 'lc-vat-act'),
  ('LC', 'LC-VAT-RETURN', '17', 'total', 'VAT refundable', '{}'::jsonb, 170, null, array['15']::text[], array['10']::text[], null, null, true, false, null, 'The excess of the input tax deduction over the output tax (s. 29(2), s. 57): carried forward as an input tax deduction of the next period; after three consecutive periods the remainder can be claimed as a refund, paid by the end of the month after the claim (s. 57(3) and (4)); a person at least half of whose supplies are zero-rated may claim the excess of each period (s. 57(5) and (6)). The pack only reports box 17.', 'lc-vat-act')
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
  ('LC-IFRS-SME-IS', 'LC', 'default', 'Income statement', 'income_statement', 'IFRS-SME', date '1970-01-01', null, 'Same choice as the statement of financial position: the income statement is presented in the manner of IFRS for SMEs, section 5, with the expenses collapsed to cost of sales, other operating expenses and depreciation. No Saint Lucia text read prescribes it. The corporate income tax charge (6470) falls in other operating expenses; the Income Tax Act was not opened and the tax is not modelled', 'iasb-ifrs-sme', null, null, '{}'::jsonb),
  ('LC-IFRS-SME-SFP', 'LC', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS-SME', date '1970-01-01', null, 'The Companies Act and the Income Tax Act of Saint Lucia were not opened for this pack, so no section of either is cited, and none is asserted to prescribe a layout. This statement follows the presentation of IFRS for SMEs (International Accounting Standards Board), section 4: current and non-current assets and liabilities, with equity shown beside them; that is a choice of this pack, not a text the country imposes, and a company reporting under full IFRS presents the same balance sheet with different notes. The numbering and the ranges each line reads are original to this pack. The VAT collected (2100 to 2199) is a current tax liability; the VAT recoverable sits with the receivables (1170 to 1172), unnetted. Cash flows and changes in equity are separate statements this pack does not model', 'iasb-ifrs-sme', 'alone', null, '{}'::jsonb)
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
  ('LC-IFRS-SME-IS', 'REV', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LC-IFRS-SME-IS', 'COST', null, 'Cost of sales', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LC-IFRS-SME-IS', 'GROSS', null, 'Gross profit', '{}'::jsonb, 30, 1, true, array['REV']::text[], array['COST']::text[], null, null, null),
  ('LC-IFRS-SME-IS', 'OTH-INC', null, 'Other income', '{}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LC-IFRS-SME-IS', 'OPEX', null, 'Administrative and other operating expenses', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LC-IFRS-SME-IS', 'DEPR', null, 'Depreciation and amortisation', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LC-IFRS-SME-IS', 'PROFIT', null, 'Profit (loss) for the year', '{}'::jsonb, 70, 1, true, array['GROSS', 'OTH-INC']::text[], array['OPEX', 'DEPR']::text[], null, null, null),
  ('LC-IFRS-SME-SFP', 'A-NC-FIX', 'A-NC', 'Property, plant and equipment', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LC-IFRS-SME-SFP', 'A-NC-INT', 'A-NC', 'Goodwill and other intangible assets', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LC-IFRS-SME-SFP', 'A-NC-OTH', 'A-NC', 'Other non-current assets', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LC-IFRS-SME-SFP', 'A-NC', null, 'Non-current assets', '{}'::jsonb, 40, 1, true, array['A-NC-FIX', 'A-NC-INT', 'A-NC-OTH']::text[], '{}'::text[], null, null, null),
  ('LC-IFRS-SME-SFP', 'A-C-REC', 'A-C', 'Trade and other receivables', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LC-IFRS-SME-SFP', 'A-C-INV', 'A-C', 'Inventories', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LC-IFRS-SME-SFP', 'A-C-OTH', 'A-C', 'Other current assets', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LC-IFRS-SME-SFP', 'A-C-PRE', 'A-C', 'Prepayments and deposits paid', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LC-IFRS-SME-SFP', 'A-C-CASH', 'A-C', 'Cash and cash equivalents', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LC-IFRS-SME-SFP', 'A-C', null, 'Current assets', '{}'::jsonb, 100, 1, true, array['A-C-REC', 'A-C-INV', 'A-C-OTH', 'A-C-PRE', 'A-C-CASH']::text[], '{}'::text[], null, null, null),
  ('LC-IFRS-SME-SFP', 'A-TOT', null, 'Total assets', '{}'::jsonb, 110, 1, true, array['A-NC', 'A-C']::text[], '{}'::text[], null, null, null),
  ('LC-IFRS-SME-SFP', 'E-CAP', 'E-TOT', 'Share capital and reserves', '{}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LC-IFRS-SME-SFP', 'E-RET', 'E-TOT', 'Retained earnings', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LC-IFRS-SME-SFP', 'E-RESULT', 'E-TOT', 'Profit or loss for the year, not yet allocated', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LC-IFRS-SME-SFP', 'E-TOT', null, 'Total equity', '{}'::jsonb, 150, 1, true, array['E-CAP', 'E-RET', 'E-RESULT']::text[], '{}'::text[], null, null, null),
  ('LC-IFRS-SME-SFP', 'L-NC', 'L-TOT', 'Non-current liabilities', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LC-IFRS-SME-SFP', 'L-C-PAY', 'L-C', 'Trade and other payables', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LC-IFRS-SME-SFP', 'L-C-TAX', 'L-C', 'Current tax liabilities, including VAT collected', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LC-IFRS-SME-SFP', 'L-C-OTH', 'L-C', 'Other current liabilities', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LC-IFRS-SME-SFP', 'L-C', null, 'Current liabilities', '{}'::jsonb, 200, 1, true, array['L-C-PAY', 'L-C-TAX', 'L-C-OTH']::text[], '{}'::text[], null, null, null),
  ('LC-IFRS-SME-SFP', 'L-TOT', null, 'Total liabilities', '{}'::jsonb, 210, 1, true, array['L-NC', 'L-C']::text[], '{}'::text[], null, null, null),
  ('LC-IFRS-SME-SFP', 'EL-TOT', null, 'Total equity and liabilities', '{}'::jsonb, 220, 1, true, array['E-TOT', 'L-TOT']::text[], '{}'::text[], null, null, null)
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
 where r.statement_code in ('LC-IFRS-SME-IS', 'LC-IFRS-SME-SFP')
   and (r.statement_code, r.line_code, r.sequence) not in (
     values ('LC-IFRS-SME-IS', 'REV', 10),
            ('LC-IFRS-SME-IS', 'COST', 10),
            ('LC-IFRS-SME-IS', 'OTH-INC', 10),
            ('LC-IFRS-SME-IS', 'OPEX', 10),
            ('LC-IFRS-SME-IS', 'DEPR', 10),
            ('LC-IFRS-SME-SFP', 'A-NC-FIX', 10),
            ('LC-IFRS-SME-SFP', 'A-NC-INT', 10),
            ('LC-IFRS-SME-SFP', 'A-NC-OTH', 10),
            ('LC-IFRS-SME-SFP', 'A-C-REC', 10),
            ('LC-IFRS-SME-SFP', 'A-C-INV', 10),
            ('LC-IFRS-SME-SFP', 'A-C-OTH', 10),
            ('LC-IFRS-SME-SFP', 'A-C-PRE', 10),
            ('LC-IFRS-SME-SFP', 'A-C-CASH', 10),
            ('LC-IFRS-SME-SFP', 'E-CAP', 10),
            ('LC-IFRS-SME-SFP', 'E-RET', 10),
            ('LC-IFRS-SME-SFP', 'E-RESULT', 10),
            ('LC-IFRS-SME-SFP', 'E-RESULT', 20),
            ('LC-IFRS-SME-SFP', 'E-RESULT', 30),
            ('LC-IFRS-SME-SFP', 'E-RESULT', 40),
            ('LC-IFRS-SME-SFP', 'L-NC', 10),
            ('LC-IFRS-SME-SFP', 'L-C-PAY', 10),
            ('LC-IFRS-SME-SFP', 'L-C-TAX', 10),
            ('LC-IFRS-SME-SFP', 'L-C-TAX', 20),
            ('LC-IFRS-SME-SFP', 'L-C-OTH', 10),
            ('LC-IFRS-SME-SFP', 'L-C-OTH', 20)
   );

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('LC-IFRS-SME-IS', 'REV', 10, 'code_range', '4000', '4699', null, 'any'),
    ('LC-IFRS-SME-IS', 'COST', 10, 'code_range', '5000', '5099', null, 'any'),
    ('LC-IFRS-SME-IS', 'OTH-INC', 10, 'code_range', '4700', '4799', null, 'any'),
    ('LC-IFRS-SME-IS', 'OPEX', 10, 'code_range', '6000', '6799', null, 'any'),
    ('LC-IFRS-SME-IS', 'DEPR', 10, 'code_range', '6800', '6899', null, 'any'),
    ('LC-IFRS-SME-SFP', 'A-NC-FIX', 10, 'code_range', '1600', '1799', null, 'any'),
    ('LC-IFRS-SME-SFP', 'A-NC-INT', 10, 'code_range', '1800', '1899', null, 'any'),
    ('LC-IFRS-SME-SFP', 'A-NC-OTH', 10, 'code_range', '1900', '1999', null, 'any'),
    ('LC-IFRS-SME-SFP', 'A-C-REC', 10, 'code_range', '1100', '1199', null, 'any'),
    ('LC-IFRS-SME-SFP', 'A-C-INV', 10, 'code_range', '1200', '1299', null, 'any'),
    ('LC-IFRS-SME-SFP', 'A-C-OTH', 10, 'code_range', '1300', '1399', null, 'any'),
    ('LC-IFRS-SME-SFP', 'A-C-PRE', 10, 'code_range', '1400', '1499', null, 'any'),
    ('LC-IFRS-SME-SFP', 'A-C-CASH', 10, 'code_range', '1000', '1099', null, 'any'),
    ('LC-IFRS-SME-SFP', 'E-CAP', 10, 'code_range', '3000', '3199', null, 'any'),
    ('LC-IFRS-SME-SFP', 'E-RET', 10, 'code_range', '3200', '3299', null, 'any'),
    ('LC-IFRS-SME-SFP', 'E-RESULT', 10, 'code_range', '4000', '4699', null, 'any'),
    ('LC-IFRS-SME-SFP', 'E-RESULT', 20, 'code_range', '4700', '4799', null, 'any'),
    ('LC-IFRS-SME-SFP', 'E-RESULT', 30, 'code_range', '5000', '5099', null, 'any'),
    ('LC-IFRS-SME-SFP', 'E-RESULT', 40, 'code_range', '6000', '6899', null, 'any'),
    ('LC-IFRS-SME-SFP', 'L-NC', 10, 'code_range', '2300', '2399', null, 'any'),
    ('LC-IFRS-SME-SFP', 'L-C-PAY', 10, 'code_range', '2000', '2059', null, 'any'),
    ('LC-IFRS-SME-SFP', 'L-C-TAX', 10, 'code_range', '2060', '2069', null, 'any'),
    ('LC-IFRS-SME-SFP', 'L-C-TAX', 20, 'code_range', '2100', '2199', null, 'any'),
    ('LC-IFRS-SME-SFP', 'L-C-OTH', 10, 'code_range', '2070', '2099', null, 'any'),
    ('LC-IFRS-SME-SFP', 'L-C-OTH', 20, 'code_range', '2200', '2299', null, 'any')
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
  ('LC', 'Saint Lucia', '{}'::jsonb, array['en']::text[], 'XCD', '1100', '2000', '2090', '6490', '3200', '4000', '5010', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6450', '4750', '6460', null, null, '2100', '1172', null, 'month'::declaration_period)
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
  numbering_legal_reference     = 'Value Added Tax Act, Cap. 15.42, s. 34 — tax invoices, and s. 35 — tax credit and debit notes. The Act, as read for this pack, does not say that the series of invoice numbers may have no gap, which is why `numbering` is `sequential` and not `gapless`; `number_format` is a convention this pack proposes. The particulars of a tax invoice are set by the Comptroller, not by the Act, and are not printed as mentions',
  numbering_source_key          = 'lc-vat-act',
  payment_terms_legal_reference = 'No Saint Lucian text read for this pack sets a payment term between two businesses or a rate of interest on a commercial debt paid late: the interest of 1.25 % a month of s. 33 and the penalty of s. 47(4) are charges on the taxable person towards the Comptroller, not a term between two businesses. `legal_payment_days` and `late_payment_reference` are empty',
  payment_terms_source_key      = 'lc-vat-act',
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'The time-of-supply rules of the Value Added Tax Act, Cap. 15.42 (s. 18) were not applied in full for this pack: `earliest_of_delivery_or_payment` is the nearest value of the closed vocabulary to the usual rule (the earliest of delivery, invoice and payment) and is a convention to be checked against the Act by a reviewer',
  tax_point_source_key          = 'lc-vat-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No Saint Lucian text read for this pack obliges a business to issue or accept an electronic invoice: the Value Added Tax Act, Cap. 15.42, s. 34 asks for a tax invoice in the form the Comptroller specifies, without naming a platform, a format or a Peppol profile. No Peppol authority for Saint Lucia was looked for. `profile`, `party_scheme` and `vat_scheme` are null: there is no domestic profile to name',
  einvoice_source_key           = 'lc-vat-act',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'LC';
