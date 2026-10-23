-- Ekwo OS — Dominica: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/dm at version 0.2.0, do not edit.
-- Change the pack and run `ekwo pack build dm`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Value Added Tax Act, 2005 (Act 7 of 2005), as enacted; the amending Acts listed on the Division's VAT page (Act 4 of 2006, Act 17 of 2008, Act 8 of 2014, Act 12 of 2015) are not all applied to it (Inland Revenue Division, Ministry of Finance, Commonwealth of Dominica — Laws of Dominica)
--     https://www.dominica.gov.dm/laws/2005/act7-2005.pdf
--   Value Added Tax (Amendment) Act, 2006 (Act 4 of 2006) — s. 9(1)(d) and (e) added (Inland Revenue Division, Ministry of Finance, Commonwealth of Dominica — Laws of Dominica)
--     https://www.dominica.gov.dm/laws/2006/act4-2006.pdf
--   Value Added Tax Regulations, 2006 (S.R.O. 9 of 2006) (Inland Revenue Division, Ministry of Finance, Commonwealth of Dominica — Laws of Dominica)
--     https://www.dominica.gov.dm/laws/2006/sro9-2006.pdf
--   Value Added Tax (VAT) — governance, rates, due date, filing, penalties and interest (Inland Revenue Division, Ministry of Finance, Commonwealth of Dominica)
--     https://www.ird.gov.dm/tax-laws/value-added-tax
--   Guide to Registration for VAT (2018) — who registers, taxable and exempt supplies, returns and tax periods (Inland Revenue Division, Ministry of Finance, Commonwealth of Dominica)
--     https://ird.gov.dm/phocadownload/guides/VAT%20-%20Registration%20Guide%202018.pdf
--   Guide to Filing V.A.T. Claims and Applications for Refund (the page 'Completing Your VAT Return' links it as its guide to filing) (Inland Revenue Division, Ministry of Finance, Commonwealth of Dominica)
--     https://ird.gov.dm/phocadownload/vat_return/VAT%20-%20Refund%20Guide%201.0.pdf
--   IFRS for SMEs Accounting Standard (IFRS Foundation / International Accounting Standards Board)
--     https://www.ifrs.org/issued-standards/ifrs-for-smes/
--   Tax eFiling — the Division's online service the return is filed through (Inland Revenue Division, Ministry of Finance, Commonwealth of Dominica)
--     https://efiling.ird.gov.dm/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('DM', 'Dominica', '0.2.0', date '2026-10-23', '20261023124650', 'community', null, null, '2f481d1c509888c8f60adf76bfe5804c02c07962faa647ab4a0c10f556987087', '[{"key":"dm-vat-act","title":"Value Added Tax Act, 2005 (Act 7 of 2005), as enacted; the amending Acts listed on the Division''s VAT page (Act 4 of 2006, Act 17 of 2008, Act 8 of 2014, Act 12 of 2015) are not all applied to it","publisher":"Inland Revenue Division, Ministry of Finance, Commonwealth of Dominica — Laws of Dominica","url":"https://www.dominica.gov.dm/laws/2005/act7-2005.pdf","consulted_on":"2026-10-17","kind":"law"},{"key":"dm-vat-amend-2006","title":"Value Added Tax (Amendment) Act, 2006 (Act 4 of 2006) — s. 9(1)(d) and (e) added","publisher":"Inland Revenue Division, Ministry of Finance, Commonwealth of Dominica — Laws of Dominica","url":"https://www.dominica.gov.dm/laws/2006/act4-2006.pdf","consulted_on":"2026-10-17","kind":"law"},{"key":"dm-vat-regs","title":"Value Added Tax Regulations, 2006 (S.R.O. 9 of 2006)","publisher":"Inland Revenue Division, Ministry of Finance, Commonwealth of Dominica — Laws of Dominica","url":"https://www.dominica.gov.dm/laws/2006/sro9-2006.pdf","consulted_on":"2026-10-17","kind":"regulation"},{"key":"ird-vat","title":"Value Added Tax (VAT) — governance, rates, due date, filing, penalties and interest","publisher":"Inland Revenue Division, Ministry of Finance, Commonwealth of Dominica","url":"https://www.ird.gov.dm/tax-laws/value-added-tax","consulted_on":"2026-10-17","kind":"guidance"},{"key":"ird-vat-registration-guide","title":"Guide to Registration for VAT (2018) — who registers, taxable and exempt supplies, returns and tax periods","publisher":"Inland Revenue Division, Ministry of Finance, Commonwealth of Dominica","url":"https://ird.gov.dm/phocadownload/guides/VAT%20-%20Registration%20Guide%202018.pdf","consulted_on":"2026-10-17","kind":"guidance"},{"key":"ird-vat-refund-guide","title":"Guide to Filing V.A.T. Claims and Applications for Refund (the page ''Completing Your VAT Return'' links it as its guide to filing)","publisher":"Inland Revenue Division, Ministry of Finance, Commonwealth of Dominica","url":"https://ird.gov.dm/phocadownload/vat_return/VAT%20-%20Refund%20Guide%201.0.pdf","consulted_on":"2026-10-17","kind":"guidance"},{"key":"iasb-ifrs-sme","title":"IFRS for SMEs Accounting Standard","publisher":"IFRS Foundation / International Accounting Standards Board","url":"https://www.ifrs.org/issued-standards/ifrs-for-smes/","consulted_on":"2026-10-17","kind":"standard"},{"key":"ird-efiling","title":"Tax eFiling — the Division''s online service the return is filed through","publisher":"Inland Revenue Division, Ministry of Finance, Commonwealth of Dominica","url":"https://efiling.ird.gov.dm/","consulted_on":"2026-10-17","kind":"portal"}]'::jsonb)
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
  ('DM', 'default', 'Dominica reference chart of accounts', '{}'::jsonb, true, 'companies', array['DM-IFRS-SME-IS', 'DM-IFRS-SME-SFP']::text[], null, 'This pack found no legal chart of accounts in Dominica, and opened neither the Companies Act nor the Income Tax Act: no section of either is cited. What the Value Added Tax Act, 2005, s. 64 asks of a taxable person is that records be kept (s. 63 defines them), and the Division''s registration guide repeats it. This chart is original: four digits, blocked so that each range reaches one line of a statement of financial position and an income statement presented in the manner of IFRS for SMEs, which is a choice of this pack and not a text the country imposes. The settlement account of the VAT return (2100, refundable 1172) is distinct from the accounts the tax posts to (2101 and 2102 collected, 1170 and 1171 recoverable). See README.md', 'dm-vat-act')
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
  ('DM', 'default', '1000', 'Cash on hand', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('DM', 'default', '1010', 'Bank current account', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('DM', 'default', '1020', 'Bank savings account', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('DM', 'default', '1030', 'Foreign currency bank account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('DM', 'default', '1040', 'Payment gateway and card clearing account', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('DM', 'default', '1050', 'Fixed deposits of three months or less', '{}'::jsonb, 'asset_cash', false, null, 60),
  ('DM', 'default', '1060', 'Cash in transit', '{}'::jsonb, 'asset_cash', false, null, 70),
  ('DM', 'default', '1100', 'Trade debtors', '{}'::jsonb, 'asset_receivable', true, null, 80),
  ('DM', 'default', '1105', 'Allowance for expected credit losses', '{}'::jsonb, 'asset_current', false, null, 90),
  ('DM', 'default', '1110', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 100),
  ('DM', 'default', '1120', 'Other debtors', '{}'::jsonb, 'asset_current', false, null, 110),
  ('DM', 'default', '1130', 'Accrued income', '{}'::jsonb, 'asset_current', false, null, 120),
  ('DM', 'default', '1140', 'Staff advances and loans to employees', '{}'::jsonb, 'asset_current', false, null, 130),
  ('DM', 'default', '1150', 'Customs duty deposits paid', '{}'::jsonb, 'asset_current', false, null, 140),
  ('DM', 'default', '1160', 'Corporation tax recoverable', '{}'::jsonb, 'asset_current', false, null, 150),
  ('DM', 'default', '1170', 'VAT recoverable — local purchases', '{}'::jsonb, 'asset_current', false, null, 160),
  ('DM', 'default', '1171', 'VAT recoverable — imports paid to the Comptroller of Customs', '{}'::jsonb, 'asset_current', false, null, 170),
  ('DM', 'default', '1172', 'VAT refundable — settlement of the return', '{}'::jsonb, 'asset_current', true, null, 180),
  ('DM', 'default', '1200', 'Inventory — raw materials and consumables', '{}'::jsonb, 'asset_current', false, null, 190),
  ('DM', 'default', '1210', 'Inventory — work in progress', '{}'::jsonb, 'asset_current', false, null, 200),
  ('DM', 'default', '1220', 'Inventory — finished goods and goods for resale', '{}'::jsonb, 'asset_current', false, null, 210),
  ('DM', 'default', '1230', 'Goods in transit', '{}'::jsonb, 'asset_current', false, null, 220),
  ('DM', 'default', '1300', 'Fixed deposits of more than three months', '{}'::jsonb, 'asset_current', false, null, 230),
  ('DM', 'default', '1310', 'Listed investments held for trading', '{}'::jsonb, 'asset_current', false, null, 240),
  ('DM', 'default', '1320', 'Amounts due from related companies — non-trade', '{}'::jsonb, 'asset_current', false, null, 250),
  ('DM', 'default', '1400', 'Prepaid expenses', '{}'::jsonb, 'asset_prepayments', false, null, 260),
  ('DM', 'default', '1410', 'Rental and utility deposits paid', '{}'::jsonb, 'asset_prepayments', false, null, 270),
  ('DM', 'default', '1420', 'Deposits paid to suppliers', '{}'::jsonb, 'asset_prepayments', false, null, 280),
  ('DM', 'default', '1600', 'Leasehold land and buildings', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('DM', 'default', '1610', 'Leasehold improvements', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('DM', 'default', '1620', 'Furniture and fixtures', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('DM', 'default', '1630', 'Office equipment', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('DM', 'default', '1640', 'Computer equipment and software', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('DM', 'default', '1650', 'Motor vehicles', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('DM', 'default', '1660', 'Plant and machinery', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('DM', 'default', '1670', 'Right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('DM', 'default', '1690', 'Accumulated depreciation — property plant and equipment', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('DM', 'default', '1695', 'Accumulated depreciation — right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 380),
  ('DM', 'default', '1800', 'Goodwill', '{}'::jsonb, 'asset_non_current', false, null, 390),
  ('DM', 'default', '1810', 'Other intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 400),
  ('DM', 'default', '1820', 'Accumulated amortisation — intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 410),
  ('DM', 'default', '1900', 'Investments in subsidiaries', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('DM', 'default', '1910', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('DM', 'default', '1920', 'Other long-term investments', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('DM', 'default', '1930', 'Rental and utility deposits — non-current', '{}'::jsonb, 'asset_non_current', false, null, 450),
  ('DM', 'default', '1990', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('DM', 'default', '2000', 'Trade creditors', '{}'::jsonb, 'liability_payable', true, null, 470),
  ('DM', 'default', '2010', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 480),
  ('DM', 'default', '2020', 'Accruals', '{}'::jsonb, 'liability_current', false, null, 490),
  ('DM', 'default', '2030', 'Customer deposits and advances received', '{}'::jsonb, 'liability_current', false, null, 500),
  ('DM', 'default', '2040', 'Salaries and wages payable', '{}'::jsonb, 'liability_current', false, null, 510),
  ('DM', 'default', '2050', 'National Insurance Scheme contributions payable', '{}'::jsonb, 'liability_current', false, null, 520),
  ('DM', 'default', '2060', 'Corporation tax payable', '{}'::jsonb, 'liability_current', false, null, 530),
  ('DM', 'default', '2070', 'Payroll deductions payable', '{}'::jsonb, 'liability_current', false, null, 540),
  ('DM', 'default', '2071', 'Customs duty payable', '{}'::jsonb, 'liability_current', false, null, 550),
  ('DM', 'default', '2072', 'Land tax payable', '{}'::jsonb, 'liability_current', false, null, 560),
  ('DM', 'default', '2073', 'Other government charges payable', '{}'::jsonb, 'liability_current', false, null, 570),
  ('DM', 'default', '2080', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 580),
  ('DM', 'default', '2090', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 590),
  ('DM', 'default', '2100', 'VAT payable — settlement of the return', '{}'::jsonb, 'liability_current', true, null, 600),
  ('DM', 'default', '2101', 'VAT collected — standard rate', '{}'::jsonb, 'liability_current', false, null, 610),
  ('DM', 'default', '2102', 'VAT collected — accommodation rate', '{}'::jsonb, 'liability_current', false, null, 620),
  ('DM', 'default', '2200', 'Corporate credit card payable', '{}'::jsonb, 'liability_credit_card', false, null, 630),
  ('DM', 'default', '2300', 'Bank borrowings — non-current', '{}'::jsonb, 'liability_non_current', false, null, 640),
  ('DM', 'default', '2310', 'Lease liabilities — non-current', '{}'::jsonb, 'liability_non_current', false, null, 650),
  ('DM', 'default', '2320', 'Amounts due to shareholders — non-current', '{}'::jsonb, 'liability_non_current', false, null, 660),
  ('DM', 'default', '2390', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 670),
  ('DM', 'default', '3000', 'Issued and paid-up share capital', '{}'::jsonb, 'equity', false, null, 680),
  ('DM', 'default', '3100', 'Share premium', '{}'::jsonb, 'equity', false, null, 690),
  ('DM', 'default', '3110', 'Capital reserve', '{}'::jsonb, 'equity', false, null, 700),
  ('DM', 'default', '3200', 'Retained profits', '{}'::jsonb, 'equity_retained', false, null, 710),
  ('DM', 'default', '4000', 'Sale of goods', '{}'::jsonb, 'income', false, null, 720),
  ('DM', 'default', '4010', 'Rendering of services', '{}'::jsonb, 'income', false, null, 730),
  ('DM', 'default', '4700', 'Realised exchange gains', '{}'::jsonb, 'income_other', false, null, 740),
  ('DM', 'default', '4710', 'Unrealised exchange gains', '{}'::jsonb, 'income_other', false, null, 750),
  ('DM', 'default', '4720', 'Interest income', '{}'::jsonb, 'income_other', false, null, 760),
  ('DM', 'default', '4730', 'Sundry income', '{}'::jsonb, 'income_other', false, null, 770),
  ('DM', 'default', '4750', 'Gain on disposal of fixed assets', '{}'::jsonb, 'income_other', false, null, 780),
  ('DM', 'default', '5000', 'Cost of goods sold', '{}'::jsonb, 'expense_direct_cost', false, null, 790),
  ('DM', 'default', '5010', 'Purchases', '{}'::jsonb, 'expense_direct_cost', false, null, 800),
  ('DM', 'default', '5020', 'Freight inwards', '{}'::jsonb, 'expense_direct_cost', false, null, 810),
  ('DM', 'default', '5025', 'Customs duty on imports', '{}'::jsonb, 'expense_direct_cost', false, null, 820),
  ('DM', 'default', '5030', 'Direct labour', '{}'::jsonb, 'expense_direct_cost', false, null, 830),
  ('DM', 'default', '6000', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 840),
  ('DM', 'default', '6010', 'Staff salaries and wages', '{}'::jsonb, 'expense', false, null, 850),
  ('DM', 'default', '6020', 'Pension contributions', '{}'::jsonb, 'expense', false, null, 860),
  ('DM', 'default', '6025', 'Employer payroll contributions', '{}'::jsonb, 'expense', false, null, 870),
  ('DM', 'default', '6026', 'National Insurance Scheme — employer contribution', '{}'::jsonb, 'expense', false, null, 880),
  ('DM', 'default', '6030', 'Staff welfare and benefits', '{}'::jsonb, 'expense', false, null, 890),
  ('DM', 'default', '6100', 'Rent and rates', '{}'::jsonb, 'expense', false, null, 900),
  ('DM', 'default', '6110', 'Management fees and building outgoings', '{}'::jsonb, 'expense', false, null, 910),
  ('DM', 'default', '6120', 'Utilities', '{}'::jsonb, 'expense', false, null, 920),
  ('DM', 'default', '6130', 'Land tax', '{}'::jsonb, 'expense', false, null, 930),
  ('DM', 'default', '6200', 'Government fees, licences and company registry fees', '{}'::jsonb, 'expense', false, null, 940),
  ('DM', 'default', '6210', 'Auditor''s remuneration', '{}'::jsonb, 'expense', false, null, 950),
  ('DM', 'default', '6220', 'Accounting and company secretarial fees', '{}'::jsonb, 'expense', false, null, 960),
  ('DM', 'default', '6230', 'Legal and professional fees', '{}'::jsonb, 'expense', false, null, 970),
  ('DM', 'default', '6300', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 980),
  ('DM', 'default', '6310', 'Insurance', '{}'::jsonb, 'expense', false, null, 990),
  ('DM', 'default', '6320', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1000),
  ('DM', 'default', '6330', 'Travelling expenses', '{}'::jsonb, 'expense', false, null, 1010),
  ('DM', 'default', '6340', 'Entertainment expenses', '{}'::jsonb, 'expense', false, null, 1020),
  ('DM', 'default', '6350', 'Advertising and promotion', '{}'::jsonb, 'expense', false, null, 1030),
  ('DM', 'default', '6360', 'Printing, stationery and postage', '{}'::jsonb, 'expense', false, null, 1040),
  ('DM', 'default', '6370', 'Telecommunications', '{}'::jsonb, 'expense', false, null, 1050),
  ('DM', 'default', '6380', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1060),
  ('DM', 'default', '6390', 'Sundry office expenses', '{}'::jsonb, 'expense', false, null, 1070),
  ('DM', 'default', '6400', 'Allowance for expected credit losses charged', '{}'::jsonb, 'expense', false, null, 1080),
  ('DM', 'default', '6410', 'Interest expense on bank borrowings', '{}'::jsonb, 'expense', false, null, 1090),
  ('DM', 'default', '6420', 'Interest expense on lease liabilities', '{}'::jsonb, 'expense', false, null, 1100),
  ('DM', 'default', '6450', 'Realised exchange losses', '{}'::jsonb, 'expense', false, null, 1110),
  ('DM', 'default', '6455', 'Unrealised exchange losses', '{}'::jsonb, 'expense', false, null, 1120),
  ('DM', 'default', '6460', 'Loss on disposal of fixed assets', '{}'::jsonb, 'expense', false, null, 1130),
  ('DM', 'default', '6470', 'Corporation tax charge', '{}'::jsonb, 'expense', false, null, 1140),
  ('DM', 'default', '6480', 'Deferred tax charge', '{}'::jsonb, 'expense', false, null, 1150),
  ('DM', 'default', '6490', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1160),
  ('DM', 'default', '6800', 'Depreciation and amortisation', '{}'::jsonb, 'expense_depreciation', false, null, 1170)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('DM', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('DM', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('DM', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('DM', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('DM', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('DM', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('DM', 'DM-P-10', 'Purchase of accommodation or dive activity, VAT 10 %', '{}'::jsonb, 'Accommodation or dive activity bought for the business at the reduced rate', 'percent', 10, 'purchase', 'domestic', date '2006-03-01', null, 'Value Added Tax Act, 2005, s. 9(1)(c), (d) and s. 25(1)(a) — input tax at the 10 per cent rate is deductible on the same conditions as at 15 per cent. Base to box 10, tax to box 12.', null, null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'dm-vat-act', null, null, null, null),
  ('DM', 'DM-P-15', 'Purchase, VAT 15 %', '{}'::jsonb, 'A purchase from a taxable person, standard-rated, with a tax invoice', 'percent', 15, 'purchase', 'domestic', date '2006-03-01', null, 'Value Added Tax Act, 2005, s. 25(1)(a) — the input tax payable on taxable supplies made to the person for use in a taxable activity is deductible, on a tax invoice or a tax debit or credit note (s. 25(2)). Base to box 10, tax to box 12. Section 26 (apportionment for mixed supplies and the disallowed categories) is the user''s.', null, null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'dm-vat-act', null, null, null, null),
  ('DM', 'DM-P-15-IMP', 'Import of goods, VAT 15 %', '{}'::jsonb, 'Goods imported: the VAT paid to the Comptroller of Customs', 'percent', 15, 'purchase', 'import', date '2006-03-01', null, 'Value Added Tax Act, 2005, s. 9(1)(b), s. 20 and s. 22 — 15 per cent of the value of an import of goods, paid by the importer on the import declaration (s. 9(2)(b)); the value for tax is the customs value plus freight and insurance, duty and the customs service charge (s. 20(1)), which the pack does not compute: it applies 15 % to the invoice value and the customs entry is the user''s. The tax paid is deductible (s. 25(1)(a)). Base to box 9, tax to box 11.', null, null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'dm-vat-act', null, null, null, null),
  ('DM', 'DM-P-EX', 'Purchase without VAT', '{}'::jsonb, 'A purchase of a zero-rated or exempt supply, or from a person who charges no VAT: no input tax to claim', 'percent', 0, 'purchase', 'exempt', date '2006-03-01', null, 'Value Added Tax Act, 2005, s. 17 and s. 18 — a zero-rated supply carries tax at zero per cent and an exempt supply carries none, so the purchaser has no input tax to claim; the value is still reported among the purchases of the period (box 10).', null, null, 100, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'dm-vat-act', null, null, null, null),
  ('DM', 'DM-S-0', 'Zero-rated supply (export)', '{}'::jsonb, 'An export of goods or services, zero-rated', 'percent', 0, 'sale', 'export', date '2006-03-01', null, 'Value Added Tax Act, 2005, s. 17 and Schedule I, paragraph 3 — exported goods and services are charged at zero per cent; Schedule I, paragraph 3(1)(a) requires the goods to have been entered for export and exported by the supplier. A zero-rated supply is a taxable supply: the input tax of what produces it stays deductible. Base to box 3.', 'G', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'dm-vat-act', null, null, null, null),
  ('DM', 'DM-S-10', 'Sale of accommodation or dive activity, VAT 10 %', '{}'::jsonb, 'Accommodation by a hotel, guest house, inn or similar establishment, or the dive activity portion of a dive package', 'percent', 10, 'sale', 'domestic', date '2006-03-01', null, 'Value Added Tax Act, 2005, s. 9(1)(c) and (d) (the latter added by the Value Added Tax (Amendment) Act, 2006) — 10 per cent, to the extent provided in regulations; Regulations reg. 5 applies it to accommodation by a hotel, guest house, inn or similar establishment and to a furnished apartment or room, not to a renter in a private home. The Division''s VAT page names accommodation and diving activity. The pack does not decide which of a user''s supplies qualify: that is the user''s, with their accountant. Base to box 2, tax to box 7.', 'S', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'dm-vat-regs', null, null, null, null),
  ('DM', 'DM-S-15', 'Sale, VAT 15 %', '{}'::jsonb, 'A taxable supply made in Dominica by a taxable person, standard-rated', 'percent', 15, 'sale', 'domestic', date '2006-03-01', null, 'Value Added Tax Act, 2005, s. 9(1)(a) — a tax of 15 per cent of the value of every taxable supply by a taxable person in Dominica, accounted for by the person making the supply (s. 9(2)(a)). The Division''s VAT page gives the same rate. The base posts to box 1 net of the tax, the tax to box 6 (box numbers are this pack''s, see tax_report.json). valid_from is 1 March 2006, the date the tax came into force (Division''s VAT page).', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'dm-vat-act', null, null, null, null),
  ('DM', 'DM-S-15-INC', 'Retail sale, VAT 15 %, the price includes the tax', '{}'::jsonb, 'A standard-rated sale whose price already holds the VAT', 'percent', 15, 'sale', 'domestic', date '2006-03-01', null, 'Value Added Tax Act, 2005, s. 9(1)(a) — a tax of 15 per cent of the value of every taxable supply by a taxable person in Dominica, accounted for by the person making the supply (s. 9(2)(a)). The Division''s VAT page gives the same rate. The Act''s tax fraction (s. 2, R/(100+R)) extracts the tax from a price that includes it, which is what price_include does: 115.00 holds 100.00 and 15.00. Same boxes as DM-S-15.', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, true, false, null, 'dm-vat-act', null, null, null, null),
  ('DM', 'DM-S-EX', 'Exempt supply', '{}'::jsonb, 'A supply of Schedule II (for instance financial services, residential rent, education), outside the tax', 'percent', 0, 'sale', 'exempt', date '2006-03-01', null, 'Value Added Tax Act, 2005, s. 18 and Schedule II — exempt supplies are not subject to the tax and the input tax of what is acquired to make them is not deductible; the Division''s registration guide lists financial services, the sale of real property, residential rents, water supplied by DOWASCO, veterinary and education services, unprocessed agricultural products sold by the producer and the transport of goods and passengers by land. Base to box 4.', 'E', null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'dm-vat-act', null, null, null, null),
  ('DM', 'DM-S-Z', 'Zero-rated supply in Dominica', '{}'::jsonb, 'A domestic supply of Schedule I at zero per cent (for instance basic foods, certain medical devices and agricultural and fishing inputs)', 'percent', 0, 'sale', 'domestic', date '2006-03-01', null, 'Value Added Tax Act, 2005, s. 17 and Schedule I — the Division''s registration guide lists the zero-rated supplies, among them exported goods and services, certain agricultural inputs, certain medical devices and supplies, basic foods (rice, sugar, milk and flour) and certain fishing inputs. The pack does not reproduce the schedule: the user checks the item against it. Base to box 3.', 'Z', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'dm-vat-act', null, null, null, null)
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
    ('DM-P-10', 'invoice', 'base', 100, null, '10', array['10']::text[], 100, 'DM-VAT-RETURN', 10),
    ('DM-P-10', 'invoice', 'tax', 100, '1170', '12', array['12']::text[], 100, 'DM-VAT-RETURN', 20),
    ('DM-P-10', 'credit_note', 'base', 100, null, '10', array['10']::text[], -100, 'DM-VAT-RETURN', 10),
    ('DM-P-10', 'credit_note', 'tax', 100, '1170', '12', array['12']::text[], -100, 'DM-VAT-RETURN', 20),
    ('DM-P-15', 'invoice', 'base', 100, null, '10', array['10']::text[], 100, 'DM-VAT-RETURN', 10),
    ('DM-P-15', 'invoice', 'tax', 100, '1170', '12', array['12']::text[], 100, 'DM-VAT-RETURN', 20),
    ('DM-P-15', 'credit_note', 'base', 100, null, '10', array['10']::text[], -100, 'DM-VAT-RETURN', 10),
    ('DM-P-15', 'credit_note', 'tax', 100, '1170', '12', array['12']::text[], -100, 'DM-VAT-RETURN', 20),
    ('DM-P-15-IMP', 'invoice', 'base', 100, null, '9', array['9']::text[], 100, 'DM-VAT-RETURN', 10),
    ('DM-P-15-IMP', 'invoice', 'tax', 100, '1171', '11', array['11']::text[], 100, 'DM-VAT-RETURN', 20),
    ('DM-P-15-IMP', 'credit_note', 'base', 100, null, '9', array['9']::text[], -100, 'DM-VAT-RETURN', 10),
    ('DM-P-15-IMP', 'credit_note', 'tax', 100, '1171', '11', array['11']::text[], -100, 'DM-VAT-RETURN', 20),
    ('DM-P-EX', 'invoice', 'base', 100, null, '10', array['10']::text[], 100, 'DM-VAT-RETURN', 10),
    ('DM-P-EX', 'credit_note', 'base', 100, null, '10', array['10']::text[], -100, 'DM-VAT-RETURN', 10),
    ('DM-S-0', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'DM-VAT-RETURN', 10),
    ('DM-S-0', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'DM-VAT-RETURN', 10),
    ('DM-S-10', 'invoice', 'base', 100, null, '2', array['2']::text[], 100, 'DM-VAT-RETURN', 10),
    ('DM-S-10', 'invoice', 'tax', 100, '2102', '7', array['7']::text[], 100, 'DM-VAT-RETURN', 20),
    ('DM-S-10', 'credit_note', 'base', 100, null, '2', array['2']::text[], -100, 'DM-VAT-RETURN', 10),
    ('DM-S-10', 'credit_note', 'tax', 100, '2102', '7', array['7']::text[], -100, 'DM-VAT-RETURN', 20),
    ('DM-S-15', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'DM-VAT-RETURN', 10),
    ('DM-S-15', 'invoice', 'tax', 100, '2101', '6', array['6']::text[], 100, 'DM-VAT-RETURN', 20),
    ('DM-S-15', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'DM-VAT-RETURN', 10),
    ('DM-S-15', 'credit_note', 'tax', 100, '2101', '6', array['6']::text[], -100, 'DM-VAT-RETURN', 20),
    ('DM-S-15-INC', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'DM-VAT-RETURN', 10),
    ('DM-S-15-INC', 'invoice', 'tax', 100, '2101', '6', array['6']::text[], 100, 'DM-VAT-RETURN', 20),
    ('DM-S-15-INC', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'DM-VAT-RETURN', 10),
    ('DM-S-15-INC', 'credit_note', 'tax', 100, '2101', '6', array['6']::text[], -100, 'DM-VAT-RETURN', 20),
    ('DM-S-EX', 'invoice', 'base', 100, null, '4', array['4']::text[], 100, 'DM-VAT-RETURN', 10),
    ('DM-S-EX', 'credit_note', 'base', 100, null, '4', array['4']::text[], -100, 'DM-VAT-RETURN', 10),
    ('DM-S-Z', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'DM-VAT-RETURN', 10),
    ('DM-S-Z', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'DM-VAT-RETURN', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'DM' and t.code = v.tax_code
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
  ('DM', 'DM-VAT-RETURN', 'VAT return (box layout of this pack)', array['month']::declaration_period[], 'month'::declaration_period, date '2006-03-01', null, 'Value Added Tax Act, 2005, s. 31 — the tax period of a taxable person is the calendar month; s. 32(1) — a return for each tax period within 20 calendar days after its end, whether or not tax is payable; s. 32(2) — in the form the Comptroller prescribes, stating the information needed to calculate the tax payable under s. 24. The Division''s VAT page and registration guide say the same (due on the 20th of the month after the period). The tax came into force on 1 March 2006', true,'day_of_month_after_period'::filing_deadline_rule, 20, null, 'Value Added Tax Act, 2005, s. 32(1) and s. 41 — the return is filed within 20 calendar days after the end of the tax period and the tax is paid by the same date: for a month, the 20th of the next month (the Division''s guide gives the example of March 2018 due on 20 April 2018). The Comptroller may extend the time to file (s. 33) but not the due date of payment. A late return costs $100 a month or part (Division''s VAT page); the ten per cent penalty is s. 41(4). Weekend roll-forward is not expressible', 'dm-vat-act', null)
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
  ('DM', 'DM-VAT-RETURN', '1', 'base', 'Standard-rated supplies (15 %), net of VAT', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Box number and label are this pack''s own: the Division''s monthly VAT return form was not found online (the return is filed in its Tax eFiling service, and the forms page lists only the registration and refund forms), so the layout follows what the Act makes a return carry — the output tax of the period, the input tax deduction and the net payable or refundable (s. 24, s. 25, s. 52). Taxable supplies at 15 per cent (s. 9(1)(a)).', 'dm-vat-act'),
  ('DM', 'DM-VAT-RETURN', '2', 'base', 'Accommodation and dive-activity supplies (10 %), net of VAT', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Taxable supplies at 10 per cent: accommodation services by a hotel, guest house, inn or similar establishment (s. 9(1)(c), Regulations reg. 5) and the dive activity portion of a dive package (s. 9(1)(d), added by Act 4 of 2006).', 'dm-vat-act'),
  ('DM', 'DM-VAT-RETURN', '3', 'base', 'Zero-rated supplies, including exports', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Taxable supplies at zero per cent (s. 17, Schedule I); they stay on the return (s. 32(1) requires a return for each period whether or not tax is payable).', 'dm-vat-act'),
  ('DM', 'DM-VAT-RETURN', '4', 'base', 'Exempt supplies', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Supplies of Schedule II (s. 18), reported for information; the input tax of what is acquired to make them is not deductible (s. 26).', 'dm-vat-act'),
  ('DM', 'DM-VAT-RETURN', '5', 'total', 'Total supplies', '{}'::jsonb, 50, null, array['1', '2', '3', '4']::text[], '{}'::text[], null, null, false, false, null, 'Sum of boxes 1 to 4 — the sum is this pack''s reading, the Act asks for the information needed to calculate the tax (s. 32(2)(b)).', 'dm-vat-act'),
  ('DM', 'DM-VAT-RETURN', '6', 'tax', 'Output tax on standard-rated supplies', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tax at 15 % on box 1 (s. 9(1)(a)).', 'dm-vat-act'),
  ('DM', 'DM-VAT-RETURN', '7', 'tax', 'Output tax on accommodation and dive activity', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tax at 10 % on box 2 (s. 9(1)(c), (d)).', 'dm-vat-act'),
  ('DM', 'DM-VAT-RETURN', '8', 'total', 'Total output tax for the period', '{}'::jsonb, 80, null, array['6', '7']::text[], '{}'::text[], null, null, false, false, null, 'The output tax payable in respect of taxable supplies made during the period (s. 24(1)); a credit note posts a negative amount to its own boxes (s. 30).', 'dm-vat-act'),
  ('DM', 'DM-VAT-RETURN', '9', 'base', 'Value of imports', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Goods imported on which tax was paid at the port of entry (s. 9(1)(b), s. 22).', 'dm-vat-act'),
  ('DM', 'DM-VAT-RETURN', '10', 'base', 'Value of local purchases', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Purchases made in Dominica for the taxable activity, taxable, zero-rated and exempt.', 'dm-vat-act'),
  ('DM', 'DM-VAT-RETURN', '11', 'tax', 'VAT paid on imports', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Input tax paid on the import of goods, deductible for use in a taxable activity (s. 25(1)(a)).', 'dm-vat-act'),
  ('DM', 'DM-VAT-RETURN', '12', 'tax', 'VAT paid on local purchases', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Input tax payable on taxable supplies made to the person, deductible on a tax invoice (s. 25(1)(a), (2)).', 'dm-vat-act'),
  ('DM', 'DM-VAT-RETURN', '13', 'total', 'Total input tax for the period', '{}'::jsonb, 130, null, array['11', '12']::text[], '{}'::text[], null, null, false, false, null, 'Sum of boxes 11 and 12: the total input tax deduction allowed for the period (s. 24(1), s. 25).', 'dm-vat-act'),
  ('DM', 'DM-VAT-RETURN', '14', 'total', 'VAT payable', '{}'::jsonb, 140, null, array['8']::text[], array['13']::text[], null, null, true, false, null, 'Output tax less the input tax deduction, paid within 20 calendar days after the end of the period (s. 24(1), s. 41). Penalty and interest on default (s. 28, s. 41(4)) are not modelled.', 'dm-vat-act'),
  ('DM', 'DM-VAT-RETURN', '15', 'total', 'VAT refundable', '{}'::jsonb, 150, null, array['13']::text[], array['8']::text[], null, null, true, false, null, 'The excess of the input tax deduction over the output tax: carried forward and set against later liabilities, refunded on claim under the conditions of s. 52 (the Division''s refund guide: after six consecutive tax periods when more than $100, or monthly for a taxpayer whose sales are mostly zero-rated).', 'dm-vat-act')
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
  ('DM-IFRS-SME-IS', 'DM', 'default', 'Income statement', 'income_statement', 'IFRS-SME', date '1970-01-01', null, 'Same choice as the statement of financial position: the income statement is presented in the manner of IFRS for SMEs, section 5, with the expenses collapsed to cost of sales, other operating expenses and depreciation. No Dominica text read prescribes it. The corporate income tax charge (6470) falls in other operating expenses; the Income Tax Act was not opened and the tax is not modelled', 'iasb-ifrs-sme', null, null, '{}'::jsonb),
  ('DM-IFRS-SME-SFP', 'DM', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS-SME', date '1970-01-01', null, 'The Companies Act and the Income Tax Act of Dominica were not opened for this pack, so no section of either is cited, and none is asserted to prescribe a layout. This statement follows the presentation of IFRS for SMEs (International Accounting Standards Board), section 4: current and non-current assets and liabilities, with equity shown beside them; that is a choice of this pack, not a text the country imposes, and a company reporting under full IFRS presents the same balance sheet with different notes. The numbering and the ranges each line reads are original to this pack. The VAT collected (2100 to 2199) is a current tax liability; the VAT recoverable sits with the receivables (1170 to 1172), unnetted. Cash flows and changes in equity are separate statements this pack does not model', 'iasb-ifrs-sme', 'alone', null, '{}'::jsonb)
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
  ('DM-IFRS-SME-IS', 'REV', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DM-IFRS-SME-IS', 'COST', null, 'Cost of sales', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DM-IFRS-SME-IS', 'GROSS', null, 'Gross profit', '{}'::jsonb, 30, 1, true, array['REV']::text[], array['COST']::text[], null, null, null),
  ('DM-IFRS-SME-IS', 'OTH-INC', null, 'Other income', '{}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DM-IFRS-SME-IS', 'OPEX', null, 'Administrative and other operating expenses', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DM-IFRS-SME-IS', 'DEPR', null, 'Depreciation and amortisation', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DM-IFRS-SME-IS', 'PROFIT', null, 'Profit (loss) for the year', '{}'::jsonb, 70, 1, true, array['GROSS', 'OTH-INC']::text[], array['OPEX', 'DEPR']::text[], null, null, null),
  ('DM-IFRS-SME-SFP', 'A-NC-FIX', 'A-NC', 'Property, plant and equipment', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DM-IFRS-SME-SFP', 'A-NC-INT', 'A-NC', 'Goodwill and other intangible assets', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DM-IFRS-SME-SFP', 'A-NC-OTH', 'A-NC', 'Other non-current assets', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DM-IFRS-SME-SFP', 'A-NC', null, 'Non-current assets', '{}'::jsonb, 40, 1, true, array['A-NC-FIX', 'A-NC-INT', 'A-NC-OTH']::text[], '{}'::text[], null, null, null),
  ('DM-IFRS-SME-SFP', 'A-C-REC', 'A-C', 'Trade and other receivables', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DM-IFRS-SME-SFP', 'A-C-INV', 'A-C', 'Inventories', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DM-IFRS-SME-SFP', 'A-C-OTH', 'A-C', 'Other current assets', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DM-IFRS-SME-SFP', 'A-C-PRE', 'A-C', 'Prepayments and deposits paid', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DM-IFRS-SME-SFP', 'A-C-CASH', 'A-C', 'Cash and cash equivalents', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DM-IFRS-SME-SFP', 'A-C', null, 'Current assets', '{}'::jsonb, 100, 1, true, array['A-C-REC', 'A-C-INV', 'A-C-OTH', 'A-C-PRE', 'A-C-CASH']::text[], '{}'::text[], null, null, null),
  ('DM-IFRS-SME-SFP', 'A-TOT', null, 'Total assets', '{}'::jsonb, 110, 1, true, array['A-NC', 'A-C']::text[], '{}'::text[], null, null, null),
  ('DM-IFRS-SME-SFP', 'E-CAP', 'E-TOT', 'Share capital and reserves', '{}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DM-IFRS-SME-SFP', 'E-RET', 'E-TOT', 'Retained earnings', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DM-IFRS-SME-SFP', 'E-RESULT', 'E-TOT', 'Profit or loss for the year, not yet allocated', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DM-IFRS-SME-SFP', 'E-TOT', null, 'Total equity', '{}'::jsonb, 150, 1, true, array['E-CAP', 'E-RET', 'E-RESULT']::text[], '{}'::text[], null, null, null),
  ('DM-IFRS-SME-SFP', 'L-NC', 'L-TOT', 'Non-current liabilities', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DM-IFRS-SME-SFP', 'L-C-PAY', 'L-C', 'Trade and other payables', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DM-IFRS-SME-SFP', 'L-C-TAX', 'L-C', 'Current tax liabilities, including VAT collected', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DM-IFRS-SME-SFP', 'L-C-OTH', 'L-C', 'Other current liabilities', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DM-IFRS-SME-SFP', 'L-C', null, 'Current liabilities', '{}'::jsonb, 200, 1, true, array['L-C-PAY', 'L-C-TAX', 'L-C-OTH']::text[], '{}'::text[], null, null, null),
  ('DM-IFRS-SME-SFP', 'L-TOT', null, 'Total liabilities', '{}'::jsonb, 210, 1, true, array['L-NC', 'L-C']::text[], '{}'::text[], null, null, null),
  ('DM-IFRS-SME-SFP', 'EL-TOT', null, 'Total equity and liabilities', '{}'::jsonb, 220, 1, true, array['E-TOT', 'L-TOT']::text[], '{}'::text[], null, null, null)
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
 where r.statement_code in ('DM-IFRS-SME-IS', 'DM-IFRS-SME-SFP')
   and (r.statement_code, r.line_code, r.sequence) not in (
     values ('DM-IFRS-SME-IS', 'REV', 10),
            ('DM-IFRS-SME-IS', 'COST', 10),
            ('DM-IFRS-SME-IS', 'OTH-INC', 10),
            ('DM-IFRS-SME-IS', 'OPEX', 10),
            ('DM-IFRS-SME-IS', 'DEPR', 10),
            ('DM-IFRS-SME-SFP', 'A-NC-FIX', 10),
            ('DM-IFRS-SME-SFP', 'A-NC-INT', 10),
            ('DM-IFRS-SME-SFP', 'A-NC-OTH', 10),
            ('DM-IFRS-SME-SFP', 'A-C-REC', 10),
            ('DM-IFRS-SME-SFP', 'A-C-INV', 10),
            ('DM-IFRS-SME-SFP', 'A-C-OTH', 10),
            ('DM-IFRS-SME-SFP', 'A-C-PRE', 10),
            ('DM-IFRS-SME-SFP', 'A-C-CASH', 10),
            ('DM-IFRS-SME-SFP', 'E-CAP', 10),
            ('DM-IFRS-SME-SFP', 'E-RET', 10),
            ('DM-IFRS-SME-SFP', 'E-RESULT', 10),
            ('DM-IFRS-SME-SFP', 'E-RESULT', 20),
            ('DM-IFRS-SME-SFP', 'E-RESULT', 30),
            ('DM-IFRS-SME-SFP', 'E-RESULT', 40),
            ('DM-IFRS-SME-SFP', 'L-NC', 10),
            ('DM-IFRS-SME-SFP', 'L-C-PAY', 10),
            ('DM-IFRS-SME-SFP', 'L-C-TAX', 10),
            ('DM-IFRS-SME-SFP', 'L-C-TAX', 20),
            ('DM-IFRS-SME-SFP', 'L-C-OTH', 10),
            ('DM-IFRS-SME-SFP', 'L-C-OTH', 20)
   );

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('DM-IFRS-SME-IS', 'REV', 10, 'code_range', '4000', '4699', null, 'any'),
    ('DM-IFRS-SME-IS', 'COST', 10, 'code_range', '5000', '5099', null, 'any'),
    ('DM-IFRS-SME-IS', 'OTH-INC', 10, 'code_range', '4700', '4799', null, 'any'),
    ('DM-IFRS-SME-IS', 'OPEX', 10, 'code_range', '6000', '6799', null, 'any'),
    ('DM-IFRS-SME-IS', 'DEPR', 10, 'code_range', '6800', '6899', null, 'any'),
    ('DM-IFRS-SME-SFP', 'A-NC-FIX', 10, 'code_range', '1600', '1799', null, 'any'),
    ('DM-IFRS-SME-SFP', 'A-NC-INT', 10, 'code_range', '1800', '1899', null, 'any'),
    ('DM-IFRS-SME-SFP', 'A-NC-OTH', 10, 'code_range', '1900', '1999', null, 'any'),
    ('DM-IFRS-SME-SFP', 'A-C-REC', 10, 'code_range', '1100', '1199', null, 'any'),
    ('DM-IFRS-SME-SFP', 'A-C-INV', 10, 'code_range', '1200', '1299', null, 'any'),
    ('DM-IFRS-SME-SFP', 'A-C-OTH', 10, 'code_range', '1300', '1399', null, 'any'),
    ('DM-IFRS-SME-SFP', 'A-C-PRE', 10, 'code_range', '1400', '1499', null, 'any'),
    ('DM-IFRS-SME-SFP', 'A-C-CASH', 10, 'code_range', '1000', '1099', null, 'any'),
    ('DM-IFRS-SME-SFP', 'E-CAP', 10, 'code_range', '3000', '3199', null, 'any'),
    ('DM-IFRS-SME-SFP', 'E-RET', 10, 'code_range', '3200', '3299', null, 'any'),
    ('DM-IFRS-SME-SFP', 'E-RESULT', 10, 'code_range', '4000', '4699', null, 'any'),
    ('DM-IFRS-SME-SFP', 'E-RESULT', 20, 'code_range', '4700', '4799', null, 'any'),
    ('DM-IFRS-SME-SFP', 'E-RESULT', 30, 'code_range', '5000', '5099', null, 'any'),
    ('DM-IFRS-SME-SFP', 'E-RESULT', 40, 'code_range', '6000', '6899', null, 'any'),
    ('DM-IFRS-SME-SFP', 'L-NC', 10, 'code_range', '2300', '2399', null, 'any'),
    ('DM-IFRS-SME-SFP', 'L-C-PAY', 10, 'code_range', '2000', '2059', null, 'any'),
    ('DM-IFRS-SME-SFP', 'L-C-TAX', 10, 'code_range', '2060', '2069', null, 'any'),
    ('DM-IFRS-SME-SFP', 'L-C-TAX', 20, 'code_range', '2100', '2199', null, 'any'),
    ('DM-IFRS-SME-SFP', 'L-C-OTH', 10, 'code_range', '2070', '2099', null, 'any'),
    ('DM-IFRS-SME-SFP', 'L-C-OTH', 20, 'code_range', '2200', '2299', null, 'any')
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
  ('DM', 'Dominica', '{}'::jsonb, array['en']::text[], 'XCD', '1100', '2000', '2090', '6490', '3200', '4000', '5010', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6450', '4750', '6460', null, null, '2100', '1172', null, 'month'::declaration_period)
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
  numbering_legal_reference     = 'Value Added Tax Act, 2005, s. 29 — a tax invoice is a document provided as the Act requires, and s. 30 treats tax credit and debit notes; the Act, as read for this pack, does not say that the series of invoice numbers may have no gap, which is why `numbering` is `sequential` and not `gapless`; `number_format` is a convention this pack proposes. The particulars of an invoice are in the Regulations (S.R.O. 9 of 2006), which this pack did not read in full',
  numbering_source_key          = 'dm-vat-act',
  payment_terms_legal_reference = 'No Dominican text read for this pack sets a payment term between two businesses or a rate of interest on a commercial debt paid late: the penalty of ten per cent (s. 41(4)) and the interest of one per cent a month (s. 28, Division''s VAT page) are charges on the taxable person towards the Comptroller, not a term between two businesses. `legal_payment_days` and `late_payment_reference` are empty',
  payment_terms_source_key      = 'dm-vat-act',
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Value Added Tax Act, 2005, s. 14(1) — a supply occurs on the earliest of the date the goods are delivered or made available or the services completed, the date the supplier issues an invoice, and the date any consideration is received. The closed vocabulary of this field has no value for three triggers at once: `earliest_of_delivery_or_payment` is the nearest and is what the rule reduces to when no invoice comes first. The special cases of s. 14(2) to (5) (credit agreement, lay-away, change of use, repossession) are not modelled',
  tax_point_source_key          = 'dm-vat-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No Dominican text read for this pack obliges a business to issue or accept an electronic invoice: the Value Added Tax Act, 2005, s. 29 asks for a tax invoice without naming a platform, a format or a Peppol profile. No Peppol authority for Dominica was looked for. `profile`, `party_scheme` and `vat_scheme` are null: there is no domestic profile to name',
  einvoice_source_key           = 'dm-vat-act',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'DM';

update country_defaults set
  tax_payee_name       = 'Inland Revenue Division',
  tax_payee_source_key = 'ird-efiling'
 where country = 'DM';
