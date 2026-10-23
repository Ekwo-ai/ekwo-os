-- Ekwo OS — Grenada: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/gd at version 0.2.0, do not edit.
-- Change the pack and run `ekwo pack build gd`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Value Added Tax Act, Cap. 333A (consolidated text as published by Parliament, with Schedules One to Five); amendments after 2015, if any, are not applied (Parliament of Grenada)
--     https://grenadaparliament.gd/wp-content/uploads/2021/08/Cap333A-VALUE-ADDED-TAX-ACT.pdf
--   Value Added Tax (Amendment) Act, 2015 (Act 21 of 2015) — registration threshold raised to $300,000 (s. 9(2)), late fee of s. 44(3), suspension regime s. 66A, Fourth Schedule item 1 (Parliament of Grenada)
--     https://grenadaparliament.gd/wp-content/uploads/2021/08/Act-No.-21-of-2015-Value-Added-Tax-Amendment.pdf
--   Value Added Tax (Amendment) Regulations, 2023 (S.R.O. 6 of 2023) — regulation 4A, electricity consumption at 7.5 %, in force 1 February 2023 (Government of Grenada, Statutory Rules and Orders (gazetted 27 January 2023))
--     https://nowgrenada.com/wp-content/uploads/2023/01/S.R.O.-6-of-2023-Value-Added-Tax-Amendment-Regulations.pdf
--   Inland Revenue Division launches a new digital tax administration system, GTAX — VAT, PAYE and corporate income tax instalments filed and paid online (Ministry of Finance, Government of Grenada (news release of 26 January 2024))
--     https://www.finance.gd/docs/2024/Press%20Release%20-%20Inland%20Revenue%20Division%20(IRD)%20Launches%20a%20New%20Digital%20Tax%20Administration%20System-%20GTAX.pdf
--   IFRS for SMEs Accounting Standard (IFRS Foundation / International Accounting Standards Board)
--     https://www.ifrs.org/issued-standards/ifrs-for-smes/
--   Tax portal of the Inland Revenue Division (G-TAX), the address named in the Ministry's news release for online registration (Inland Revenue Division, Ministry of Finance, Government of Grenada)
--     https://tax.gov.gd
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('GD', 'Grenada', '0.2.0', date '2026-10-23', '20261023124650', 'community', null, null, '61a029f3a0c5ab7b8d13317afe2818f44ae8cf9983acb2bb14147af770607fee', '[{"key":"gd-vat-act","title":"Value Added Tax Act, Cap. 333A (consolidated text as published by Parliament, with Schedules One to Five); amendments after 2015, if any, are not applied","publisher":"Parliament of Grenada","url":"https://grenadaparliament.gd/wp-content/uploads/2021/08/Cap333A-VALUE-ADDED-TAX-ACT.pdf","consulted_on":"2026-10-17","kind":"law"},{"key":"gd-vat-amend-2015","title":"Value Added Tax (Amendment) Act, 2015 (Act 21 of 2015) — registration threshold raised to $300,000 (s. 9(2)), late fee of s. 44(3), suspension regime s. 66A, Fourth Schedule item 1","publisher":"Parliament of Grenada","url":"https://grenadaparliament.gd/wp-content/uploads/2021/08/Act-No.-21-of-2015-Value-Added-Tax-Amendment.pdf","consulted_on":"2026-10-17","kind":"law"},{"key":"gd-vat-regs-2023","title":"Value Added Tax (Amendment) Regulations, 2023 (S.R.O. 6 of 2023) — regulation 4A, electricity consumption at 7.5 %, in force 1 February 2023","publisher":"Government of Grenada, Statutory Rules and Orders (gazetted 27 January 2023)","url":"https://nowgrenada.com/wp-content/uploads/2023/01/S.R.O.-6-of-2023-Value-Added-Tax-Amendment-Regulations.pdf","consulted_on":"2026-10-17","kind":"regulation"},{"key":"gd-gtax-release","title":"Inland Revenue Division launches a new digital tax administration system, GTAX — VAT, PAYE and corporate income tax instalments filed and paid online","publisher":"Ministry of Finance, Government of Grenada (news release of 26 January 2024)","url":"https://www.finance.gd/docs/2024/Press%20Release%20-%20Inland%20Revenue%20Division%20(IRD)%20Launches%20a%20New%20Digital%20Tax%20Administration%20System-%20GTAX.pdf","consulted_on":"2026-10-17","kind":"guidance"},{"key":"iasb-ifrs-sme","title":"IFRS for SMEs Accounting Standard","publisher":"IFRS Foundation / International Accounting Standards Board","url":"https://www.ifrs.org/issued-standards/ifrs-for-smes/","consulted_on":"2026-10-17","kind":"standard"},{"key":"gd-tax-portal","title":"Tax portal of the Inland Revenue Division (G-TAX), the address named in the Ministry''s news release for online registration","publisher":"Inland Revenue Division, Ministry of Finance, Government of Grenada","url":"https://tax.gov.gd","consulted_on":"2026-10-17","kind":"portal"}]'::jsonb)
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
  ('GD', 'default', 'Grenada reference chart of accounts', '{}'::jsonb, true, 'companies', array['GD-IFRS-SME-IS', 'GD-IFRS-SME-SFP']::text[], null, 'This pack found no legal chart of accounts in Grenada, and opened neither the Companies Act nor the Income Tax Act: no section of either is cited. What the Value Added Tax Act, Cap. 333A, asks of a taxable person is that VAT invoices be issued (s. 37) and records retained (s. 43). This chart is original: four digits, blocked so that each range reaches one line of a statement of financial position and an income statement presented in the manner of IFRS for SMEs, which is a choice of this pack and not a text the country imposes. The settlement account of the VAT return (2100, refundable 1172) is distinct from the accounts the tax posts to (2101, 2102 and 2103 collected, 1170 and 1171 recoverable). See README.md', 'gd-vat-act')
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
  ('GD', 'default', '1000', 'Cash on hand', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('GD', 'default', '1010', 'Bank current account', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('GD', 'default', '1020', 'Bank savings account', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('GD', 'default', '1030', 'Foreign currency bank account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('GD', 'default', '1040', 'Payment gateway and card clearing account', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('GD', 'default', '1050', 'Fixed deposits of three months or less', '{}'::jsonb, 'asset_cash', false, null, 60),
  ('GD', 'default', '1060', 'Cash in transit', '{}'::jsonb, 'asset_cash', false, null, 70),
  ('GD', 'default', '1100', 'Trade debtors', '{}'::jsonb, 'asset_receivable', true, null, 80),
  ('GD', 'default', '1105', 'Allowance for expected credit losses', '{}'::jsonb, 'asset_current', false, null, 90),
  ('GD', 'default', '1110', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 100),
  ('GD', 'default', '1120', 'Other debtors', '{}'::jsonb, 'asset_current', false, null, 110),
  ('GD', 'default', '1130', 'Accrued income', '{}'::jsonb, 'asset_current', false, null, 120),
  ('GD', 'default', '1140', 'Staff advances and loans to employees', '{}'::jsonb, 'asset_current', false, null, 130),
  ('GD', 'default', '1150', 'Customs duty deposits paid', '{}'::jsonb, 'asset_current', false, null, 140),
  ('GD', 'default', '1160', 'Corporation tax recoverable', '{}'::jsonb, 'asset_current', false, null, 150),
  ('GD', 'default', '1170', 'VAT recoverable — local purchases', '{}'::jsonb, 'asset_current', false, null, 160),
  ('GD', 'default', '1171', 'VAT recoverable — imports paid to the Comptroller of Customs', '{}'::jsonb, 'asset_current', false, null, 170),
  ('GD', 'default', '1172', 'VAT refundable — settlement of the return', '{}'::jsonb, 'asset_current', true, null, 180),
  ('GD', 'default', '1200', 'Inventory — raw materials and consumables', '{}'::jsonb, 'asset_current', false, null, 190),
  ('GD', 'default', '1210', 'Inventory — work in progress', '{}'::jsonb, 'asset_current', false, null, 200),
  ('GD', 'default', '1220', 'Inventory — finished goods and goods for resale', '{}'::jsonb, 'asset_current', false, null, 210),
  ('GD', 'default', '1230', 'Goods in transit', '{}'::jsonb, 'asset_current', false, null, 220),
  ('GD', 'default', '1300', 'Fixed deposits of more than three months', '{}'::jsonb, 'asset_current', false, null, 230),
  ('GD', 'default', '1310', 'Listed investments held for trading', '{}'::jsonb, 'asset_current', false, null, 240),
  ('GD', 'default', '1320', 'Amounts due from related companies — non-trade', '{}'::jsonb, 'asset_current', false, null, 250),
  ('GD', 'default', '1400', 'Prepaid expenses', '{}'::jsonb, 'asset_prepayments', false, null, 260),
  ('GD', 'default', '1410', 'Rental and utility deposits paid', '{}'::jsonb, 'asset_prepayments', false, null, 270),
  ('GD', 'default', '1420', 'Deposits paid to suppliers', '{}'::jsonb, 'asset_prepayments', false, null, 280),
  ('GD', 'default', '1600', 'Leasehold land and buildings', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('GD', 'default', '1610', 'Leasehold improvements', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('GD', 'default', '1620', 'Furniture and fixtures', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('GD', 'default', '1630', 'Office equipment', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('GD', 'default', '1640', 'Computer equipment and software', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('GD', 'default', '1650', 'Motor vehicles', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('GD', 'default', '1660', 'Plant and machinery', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('GD', 'default', '1670', 'Right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('GD', 'default', '1690', 'Accumulated depreciation — property plant and equipment', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('GD', 'default', '1695', 'Accumulated depreciation — right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 380),
  ('GD', 'default', '1800', 'Goodwill', '{}'::jsonb, 'asset_non_current', false, null, 390),
  ('GD', 'default', '1810', 'Other intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 400),
  ('GD', 'default', '1820', 'Accumulated amortisation — intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 410),
  ('GD', 'default', '1900', 'Investments in subsidiaries', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('GD', 'default', '1910', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('GD', 'default', '1920', 'Other long-term investments', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('GD', 'default', '1930', 'Rental and utility deposits — non-current', '{}'::jsonb, 'asset_non_current', false, null, 450),
  ('GD', 'default', '1990', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('GD', 'default', '2000', 'Trade creditors', '{}'::jsonb, 'liability_payable', true, null, 470),
  ('GD', 'default', '2010', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 480),
  ('GD', 'default', '2020', 'Accruals', '{}'::jsonb, 'liability_current', false, null, 490),
  ('GD', 'default', '2030', 'Customer deposits and advances received', '{}'::jsonb, 'liability_current', false, null, 500),
  ('GD', 'default', '2040', 'Salaries and wages payable', '{}'::jsonb, 'liability_current', false, null, 510),
  ('GD', 'default', '2050', 'National Insurance Scheme contributions payable', '{}'::jsonb, 'liability_current', false, null, 520),
  ('GD', 'default', '2060', 'Corporation tax payable', '{}'::jsonb, 'liability_current', false, null, 530),
  ('GD', 'default', '2070', 'Payroll deductions payable', '{}'::jsonb, 'liability_current', false, null, 540),
  ('GD', 'default', '2071', 'Customs duty payable', '{}'::jsonb, 'liability_current', false, null, 550),
  ('GD', 'default', '2072', 'Land tax payable', '{}'::jsonb, 'liability_current', false, null, 560),
  ('GD', 'default', '2073', 'Other government charges payable', '{}'::jsonb, 'liability_current', false, null, 570),
  ('GD', 'default', '2080', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 580),
  ('GD', 'default', '2090', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 590),
  ('GD', 'default', '2100', 'VAT payable — settlement of the return', '{}'::jsonb, 'liability_current', true, null, 600),
  ('GD', 'default', '2101', 'VAT collected — standard rate (15 %)', '{}'::jsonb, 'liability_current', false, null, 610),
  ('GD', 'default', '2102', 'VAT collected — accommodation rate', '{}'::jsonb, 'liability_current', false, null, 620),
  ('GD', 'default', '2103', 'VAT collected — electricity rate', '{}'::jsonb, 'liability_current', false, null, 625),
  ('GD', 'default', '2200', 'Corporate credit card payable', '{}'::jsonb, 'liability_credit_card', false, null, 630),
  ('GD', 'default', '2300', 'Bank borrowings — non-current', '{}'::jsonb, 'liability_non_current', false, null, 640),
  ('GD', 'default', '2310', 'Lease liabilities — non-current', '{}'::jsonb, 'liability_non_current', false, null, 650),
  ('GD', 'default', '2320', 'Amounts due to shareholders — non-current', '{}'::jsonb, 'liability_non_current', false, null, 660),
  ('GD', 'default', '2390', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 670),
  ('GD', 'default', '3000', 'Issued and paid-up share capital', '{}'::jsonb, 'equity', false, null, 680),
  ('GD', 'default', '3100', 'Share premium', '{}'::jsonb, 'equity', false, null, 690),
  ('GD', 'default', '3110', 'Capital reserve', '{}'::jsonb, 'equity', false, null, 700),
  ('GD', 'default', '3200', 'Retained profits', '{}'::jsonb, 'equity_retained', false, null, 710),
  ('GD', 'default', '4000', 'Sale of goods', '{}'::jsonb, 'income', false, null, 720),
  ('GD', 'default', '4010', 'Rendering of services', '{}'::jsonb, 'income', false, null, 730),
  ('GD', 'default', '4700', 'Realised exchange gains', '{}'::jsonb, 'income_other', false, null, 740),
  ('GD', 'default', '4710', 'Unrealised exchange gains', '{}'::jsonb, 'income_other', false, null, 750),
  ('GD', 'default', '4720', 'Interest income', '{}'::jsonb, 'income_other', false, null, 760),
  ('GD', 'default', '4730', 'Sundry income', '{}'::jsonb, 'income_other', false, null, 770),
  ('GD', 'default', '4750', 'Gain on disposal of fixed assets', '{}'::jsonb, 'income_other', false, null, 780),
  ('GD', 'default', '5000', 'Cost of goods sold', '{}'::jsonb, 'expense_direct_cost', false, null, 790),
  ('GD', 'default', '5010', 'Purchases', '{}'::jsonb, 'expense_direct_cost', false, null, 800),
  ('GD', 'default', '5020', 'Freight inwards', '{}'::jsonb, 'expense_direct_cost', false, null, 810),
  ('GD', 'default', '5025', 'Customs duty on imports', '{}'::jsonb, 'expense_direct_cost', false, null, 820),
  ('GD', 'default', '5030', 'Direct labour', '{}'::jsonb, 'expense_direct_cost', false, null, 830),
  ('GD', 'default', '6000', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 840),
  ('GD', 'default', '6010', 'Staff salaries and wages', '{}'::jsonb, 'expense', false, null, 850),
  ('GD', 'default', '6020', 'Pension contributions', '{}'::jsonb, 'expense', false, null, 860),
  ('GD', 'default', '6025', 'Employer payroll contributions', '{}'::jsonb, 'expense', false, null, 870),
  ('GD', 'default', '6026', 'National Insurance Scheme — employer contribution', '{}'::jsonb, 'expense', false, null, 880),
  ('GD', 'default', '6030', 'Staff welfare and benefits', '{}'::jsonb, 'expense', false, null, 890),
  ('GD', 'default', '6100', 'Rent and rates', '{}'::jsonb, 'expense', false, null, 900),
  ('GD', 'default', '6110', 'Management fees and building outgoings', '{}'::jsonb, 'expense', false, null, 910),
  ('GD', 'default', '6120', 'Utilities', '{}'::jsonb, 'expense', false, null, 920),
  ('GD', 'default', '6130', 'Land tax', '{}'::jsonb, 'expense', false, null, 930),
  ('GD', 'default', '6200', 'Government fees, licences and company registry fees', '{}'::jsonb, 'expense', false, null, 940),
  ('GD', 'default', '6210', 'Auditor''s remuneration', '{}'::jsonb, 'expense', false, null, 950),
  ('GD', 'default', '6220', 'Accounting and company secretarial fees', '{}'::jsonb, 'expense', false, null, 960),
  ('GD', 'default', '6230', 'Legal and professional fees', '{}'::jsonb, 'expense', false, null, 970),
  ('GD', 'default', '6300', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 980),
  ('GD', 'default', '6310', 'Insurance', '{}'::jsonb, 'expense', false, null, 990),
  ('GD', 'default', '6320', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1000),
  ('GD', 'default', '6330', 'Travelling expenses', '{}'::jsonb, 'expense', false, null, 1010),
  ('GD', 'default', '6340', 'Entertainment expenses', '{}'::jsonb, 'expense', false, null, 1020),
  ('GD', 'default', '6350', 'Advertising and promotion', '{}'::jsonb, 'expense', false, null, 1030),
  ('GD', 'default', '6360', 'Printing, stationery and postage', '{}'::jsonb, 'expense', false, null, 1040),
  ('GD', 'default', '6370', 'Telecommunications', '{}'::jsonb, 'expense', false, null, 1050),
  ('GD', 'default', '6380', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1060),
  ('GD', 'default', '6390', 'Sundry office expenses', '{}'::jsonb, 'expense', false, null, 1070),
  ('GD', 'default', '6400', 'Allowance for expected credit losses charged', '{}'::jsonb, 'expense', false, null, 1080),
  ('GD', 'default', '6410', 'Interest expense on bank borrowings', '{}'::jsonb, 'expense', false, null, 1090),
  ('GD', 'default', '6420', 'Interest expense on lease liabilities', '{}'::jsonb, 'expense', false, null, 1100),
  ('GD', 'default', '6450', 'Realised exchange losses', '{}'::jsonb, 'expense', false, null, 1110),
  ('GD', 'default', '6455', 'Unrealised exchange losses', '{}'::jsonb, 'expense', false, null, 1120),
  ('GD', 'default', '6460', 'Loss on disposal of fixed assets', '{}'::jsonb, 'expense', false, null, 1130),
  ('GD', 'default', '6470', 'Corporation tax charge', '{}'::jsonb, 'expense', false, null, 1140),
  ('GD', 'default', '6480', 'Deferred tax charge', '{}'::jsonb, 'expense', false, null, 1150),
  ('GD', 'default', '6490', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1160),
  ('GD', 'default', '6800', 'Depreciation and amortisation', '{}'::jsonb, 'expense_depreciation', false, null, 1170)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('GD', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('GD', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('GD', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('GD', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('GD', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('GD', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('GD', 'GD-P-10', 'Purchase of accommodation or dive activity, VAT 10 %', '{}'::jsonb, 'Hotel or holiday accommodation or dive activity bought for the business at the reduced rate', 'percent', 10, 'purchase', 'domestic', date '2010-02-01', null, 'Value Added Tax Act, Cap. 333A, s. 8(3)(b), (c) and s. 34 — input tax at ten per cent is creditable on the same conditions as at fifteen. Base to box 12, tax to box 14.', null, null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'gd-vat-act', null, null, null, null),
  ('GD', 'GD-P-15', 'Purchase, VAT 15 %', '{}'::jsonb, 'A purchase from a taxable person, standard-rated, with a VAT invoice', 'percent', 15, 'purchase', 'domestic', date '2010-02-01', null, 'Value Added Tax Act, Cap. 333A, s. 34(1) and (3)(a) — an input tax credit for the whole of the input tax chargeable on an acquisition that relates wholly to taxable supplies, on a VAT invoice (s. 37) or a credit or debit note (s. 39). Section 33(2) denies the credit for acquisitions that are not for the taxable activity, passenger vehicles, entertainment, club memberships and private use, and s. 34(3)(c) apportions a mixed acquisition: both are the user''s. Base to box 12, tax to box 14.', null, null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'gd-vat-act', null, null, null, null),
  ('GD', 'GD-P-15-IMP', 'Import of goods, VAT 15 %', '{}'::jsonb, 'Goods imported: the VAT paid to the Comptroller of Customs', 'percent', 15, 'purchase', 'import', date '2010-02-01', null, 'Value Added Tax Act, Cap. 333A, s. 8(1)(b) and (3)(e), s. 31 and s. 47 to 48 — fifteen per cent of the value of a taxable import, paid to the Comptroller of Customs at the time of import on the import declaration; the value for tax (s. 31) includes duty and freight, which the pack does not compute: it applies 15 % to the invoice value and the customs entry is the user''s. The tax paid is creditable (s. 34). Imports under the suspension regime of s. 66A (Act 21 of 2015) pay no tax at the border and are listed on the return: not modelled. Base to box 11, tax to box 13.', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'gd-vat-act', null, null, null, null),
  ('GD', 'GD-P-7.5', 'Purchase of electricity, VAT 7.5 %', '{}'::jsonb, 'Electricity consumed by the business, at the special rate of the Regulations', 'percent', 7.5, 'purchase', 'domestic', date '2023-02-01', null, 'Value Added Tax Regulations (S.R.O. 41 of 2009), regulation 4A, inserted by S.R.O. 6 of 2023 — VAT is levied on the consumption of electricity at 7.5 %; the tax is creditable as input tax (Act, s. 34). Base to box 12, tax to box 14.', null, null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'gd-vat-regs-2023', null, null, null, null),
  ('GD', 'GD-P-EX', 'Purchase without VAT', '{}'::jsonb, 'A purchase of a zero-rated or exempt supply, or from a person who charges no VAT: no input tax to claim', 'percent', 0, 'purchase', 'exempt', date '2010-02-01', null, 'Value Added Tax Act, Cap. 333A, s. 8(3)(a) and the Third and Fourth Schedules — a zero-rated supply carries tax at zero per cent and an exempt supply none, so the purchaser has no input tax to claim; the value is still reported among the purchases of the period (box 12).', null, null, 120, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'gd-vat-act', null, null, null, null),
  ('GD', 'GD-S-0', 'Zero-rated supply (export)', '{}'::jsonb, 'An export of goods or services, zero-rated', 'percent', 0, 'sale', 'export', date '2010-02-01', null, 'Value Added Tax Act, Cap. 333A, s. 8(3)(a) and the First Schedule, items 1 to 3 (goods entered for export and exported, with the documentary evidence of item 3) and the Second Schedule (services consumed outside Grenada) — zero per cent. A zero-rated supply is a taxable supply: the input tax of what produces it stays creditable (s. 34). Base to box 4.', 'G', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'gd-vat-act', null, null, null, null),
  ('GD', 'GD-S-10', 'Sale of hotel or holiday accommodation or dive activity, VAT 10 %', '{}'::jsonb, 'Hotel or holiday accommodation, or the dive activity portion of a dive package', 'percent', 10, 'sale', 'domestic', date '2010-02-01', null, 'Value Added Tax Act, Cap. 333A, s. 8(3)(b) — ten per cent on a supply of hotel or holiday accommodation, including accommodation that the supplier chooses to tax after forty-five days instead of treating it as exempt under items 6 and 7 of the Fourth Schedule (paragraph (2)); s. 8(3)(c) — ten per cent of the dive activity portion of a dive package, to the extent provided in the Regulations (the Regulations that fix it were not read: the pack does not decide which supplies qualify). Base to box 2, tax to box 8.', 'S', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'gd-vat-act', null, null, null, null),
  ('GD', 'GD-S-15', 'Sale, VAT 15 %', '{}'::jsonb, 'A taxable supply made in Grenada by a taxable person, standard-rated', 'percent', 15, 'sale', 'domestic', date '2010-02-01', null, 'Value Added Tax Act, Cap. 333A, s. 8(3)(e) — fifteen per cent in any other case than the zero, ten per cent and special rates, of the value of a taxable supply (s. 8(2)); the VAT is the liability of the supplier (s. 8(4)(a)) and is accounted for in the net amount of s. 32. The base posts to box 1 net of the tax, the tax to box 7 (box numbers are this pack''s, see tax_report.json). valid_from is 1 February 2010, the date the Act''s Schedule IV amendment is deemed to have come into force (Act 21 of 2015, s. 1(5)); the Act''s own commencement date was not read.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'gd-vat-act', null, null, null, null),
  ('GD', 'GD-S-15-INC', 'Retail sale, VAT 15 %, the price includes the tax', '{}'::jsonb, 'A standard-rated sale whose price already holds the VAT', 'percent', 15, 'sale', 'domestic', date '2010-02-01', null, 'Value Added Tax Act, Cap. 333A, s. 8(3)(e) at fifteen per cent, and the tax fraction of s. 19(1), which extracts the tax from a value that includes it — what price_include does: 115.00 holds 100.00 and 15.00. Same boxes as GD-S-15.', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, true, false, null, 'gd-vat-act', null, null, null, null),
  ('GD', 'GD-S-7.5', 'Sale of electricity, VAT 7.5 %', '{}'::jsonb, 'Electricity consumption, at the special rate of the Regulations', 'percent', 7.5, 'sale', 'domestic', date '2023-02-01', null, 'Value Added Tax Regulations (S.R.O. 41 of 2009), regulation 4A, inserted by the Value Added Tax (Amendment) Regulations, 2023 (S.R.O. 6 of 2023), in force 1 February 2023 — for the purposes of s. 8(3)(d) of the Act, VAT is levied on the consumption of electricity at 7.5 %. The first 99 kilowatt hours a household uses in a tax period are zero-rated (Third Schedule, item 3). Base to box 3, tax to box 9.', 'S', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'gd-vat-regs-2023', null, null, null, null),
  ('GD', 'GD-S-EX', 'Exempt supply', '{}'::jsonb, 'A supply of the Fourth Schedule (financial services, residential rent, education, health, passenger transport), outside the tax', 'percent', 0, 'sale', 'exempt', date '2010-02-01', null, 'Value Added Tax Act, Cap. 333A, Fourth Schedule — exempt supplies include financial services not remunerated by an explicit fee (item 1, as amended by Act 21 of 2015, s. 5), vacant land, residential premises and their rental (items 3 to 5), accommodation occupied for more than forty-five days under a landlord and tenant agreement (items 6 and 7), education services (item 9), medical services (item 10), taxi, bus and ferry passenger transport (item 16), international transport (item 22), and the further items 23A to 23K (bread, certain medicines, certain meats, and others as prescribed). A supply that would be both exempt and zero-rated is zero-rated (paragraph (3)). The input tax of what is acquired to make an exempt supply is not creditable (s. 34(3)(b)). Base to box 5.', 'E', null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'gd-vat-act', null, null, null, null),
  ('GD', 'GD-S-Z', 'Zero-rated supply in Grenada', '{}'::jsonb, 'A domestic supply of the Third Schedule at zero per cent (flour, rice, milk, infant preparations; water; the first 99 kWh of household electricity; motor spirit and cooking gas)', 'percent', 0, 'sale', 'domestic', date '2010-02-01', null, 'Value Added Tax Act, Cap. 333A, s. 8(3)(a) and the Third Schedule — item 1 food for human consumption to the extent provided in the Regulations (flour, sugar, rice, milk, infant preparations; the 2023 Regulations repeal cane sugar from their Third Schedule), item 2 water supplied by NAWASA for domestic use, item 3 the first 99 kWh of electricity supplied by GRENLEC to a household in a tax period, item 4 stamps, item 5 motor spirit, diesel, LPG and kerosene taxed under the Petrol Tax Act, item 5A text books. The pack does not reproduce the Regulations'' lists: the user checks the item against them. Base to box 4.', 'Z', null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'gd-vat-act', null, null, null, null)
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
    ('GD-P-10', 'invoice', 'base', 100, null, '12', array['12']::text[], 100, 'GD-VAT-RETURN', 10),
    ('GD-P-10', 'invoice', 'tax', 100, '1170', '14', array['14']::text[], 100, 'GD-VAT-RETURN', 20),
    ('GD-P-10', 'credit_note', 'base', 100, null, '12', array['12']::text[], -100, 'GD-VAT-RETURN', 10),
    ('GD-P-10', 'credit_note', 'tax', 100, '1170', '14', array['14']::text[], -100, 'GD-VAT-RETURN', 20),
    ('GD-P-15', 'invoice', 'base', 100, null, '12', array['12']::text[], 100, 'GD-VAT-RETURN', 10),
    ('GD-P-15', 'invoice', 'tax', 100, '1170', '14', array['14']::text[], 100, 'GD-VAT-RETURN', 20),
    ('GD-P-15', 'credit_note', 'base', 100, null, '12', array['12']::text[], -100, 'GD-VAT-RETURN', 10),
    ('GD-P-15', 'credit_note', 'tax', 100, '1170', '14', array['14']::text[], -100, 'GD-VAT-RETURN', 20),
    ('GD-P-15-IMP', 'invoice', 'base', 100, null, '11', array['11']::text[], 100, 'GD-VAT-RETURN', 10),
    ('GD-P-15-IMP', 'invoice', 'tax', 100, '1171', '13', array['13']::text[], 100, 'GD-VAT-RETURN', 20),
    ('GD-P-15-IMP', 'credit_note', 'base', 100, null, '11', array['11']::text[], -100, 'GD-VAT-RETURN', 10),
    ('GD-P-15-IMP', 'credit_note', 'tax', 100, '1171', '13', array['13']::text[], -100, 'GD-VAT-RETURN', 20),
    ('GD-P-7.5', 'invoice', 'base', 100, null, '12', array['12']::text[], 100, 'GD-VAT-RETURN', 10),
    ('GD-P-7.5', 'invoice', 'tax', 100, '1170', '14', array['14']::text[], 100, 'GD-VAT-RETURN', 20),
    ('GD-P-7.5', 'credit_note', 'base', 100, null, '12', array['12']::text[], -100, 'GD-VAT-RETURN', 10),
    ('GD-P-7.5', 'credit_note', 'tax', 100, '1170', '14', array['14']::text[], -100, 'GD-VAT-RETURN', 20),
    ('GD-P-EX', 'invoice', 'base', 100, null, '12', array['12']::text[], 100, 'GD-VAT-RETURN', 10),
    ('GD-P-EX', 'credit_note', 'base', 100, null, '12', array['12']::text[], -100, 'GD-VAT-RETURN', 10),
    ('GD-S-0', 'invoice', 'base', 100, null, '4', array['4']::text[], 100, 'GD-VAT-RETURN', 10),
    ('GD-S-0', 'credit_note', 'base', 100, null, '4', array['4']::text[], -100, 'GD-VAT-RETURN', 10),
    ('GD-S-10', 'invoice', 'base', 100, null, '2', array['2']::text[], 100, 'GD-VAT-RETURN', 10),
    ('GD-S-10', 'invoice', 'tax', 100, '2102', '8', array['8']::text[], 100, 'GD-VAT-RETURN', 20),
    ('GD-S-10', 'credit_note', 'base', 100, null, '2', array['2']::text[], -100, 'GD-VAT-RETURN', 10),
    ('GD-S-10', 'credit_note', 'tax', 100, '2102', '8', array['8']::text[], -100, 'GD-VAT-RETURN', 20),
    ('GD-S-15', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'GD-VAT-RETURN', 10),
    ('GD-S-15', 'invoice', 'tax', 100, '2101', '7', array['7']::text[], 100, 'GD-VAT-RETURN', 20),
    ('GD-S-15', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'GD-VAT-RETURN', 10),
    ('GD-S-15', 'credit_note', 'tax', 100, '2101', '7', array['7']::text[], -100, 'GD-VAT-RETURN', 20),
    ('GD-S-15-INC', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'GD-VAT-RETURN', 10),
    ('GD-S-15-INC', 'invoice', 'tax', 100, '2101', '7', array['7']::text[], 100, 'GD-VAT-RETURN', 20),
    ('GD-S-15-INC', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'GD-VAT-RETURN', 10),
    ('GD-S-15-INC', 'credit_note', 'tax', 100, '2101', '7', array['7']::text[], -100, 'GD-VAT-RETURN', 20),
    ('GD-S-7.5', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'GD-VAT-RETURN', 10),
    ('GD-S-7.5', 'invoice', 'tax', 100, '2103', '9', array['9']::text[], 100, 'GD-VAT-RETURN', 20),
    ('GD-S-7.5', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'GD-VAT-RETURN', 10),
    ('GD-S-7.5', 'credit_note', 'tax', 100, '2103', '9', array['9']::text[], -100, 'GD-VAT-RETURN', 20),
    ('GD-S-EX', 'invoice', 'base', 100, null, '5', array['5']::text[], 100, 'GD-VAT-RETURN', 10),
    ('GD-S-EX', 'credit_note', 'base', 100, null, '5', array['5']::text[], -100, 'GD-VAT-RETURN', 10),
    ('GD-S-Z', 'invoice', 'base', 100, null, '4', array['4']::text[], 100, 'GD-VAT-RETURN', 10),
    ('GD-S-Z', 'credit_note', 'base', 100, null, '4', array['4']::text[], -100, 'GD-VAT-RETURN', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'GD' and t.code = v.tax_code
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
  ('GD', 'GD-VAT-RETURN', 'VAT return (box layout of this pack)', array['month']::declaration_period[], 'month'::declaration_period, date '2010-02-01', null, 'Value Added Tax Act, Cap. 333A, s. 2 — the tax period is a calendar month; s. 44(1) — a taxable person lodges a VAT return for each tax period no later than twenty days after the end of the period; s. 44(2) — lodged with the Comptroller, in the form the Comptroller prescribes; s. 46(1) — the VAT is payable by the due date for lodgement. The return is filed through the Inland Revenue Division''s online service (G-TAX).', true,'day_of_month_after_period'::filing_deadline_rule, 20, null, 'Value Added Tax Act, Cap. 333A, s. 44(1) and s. 46(1) — the return is lodged within twenty days after the end of the tax period and the VAT is paid by the same date: for a month, the 20th of the next month. A late return costs a late fee of 5 % of the tax owing plus 1 % a month, or $500, whichever is greater, up to $10,000 (s. 44(3), as substituted by Act 21 of 2015, s. 3); a late payment costs 20 % of the VAT unpaid (s. 46(3)). An extension to file does not move the date of payment (s. 44(6)). Weekend roll-forward is not expressible', 'gd-vat-act', null)
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
  ('GD', 'GD-VAT-RETURN', '1', 'base', 'Standard-rated supplies (15 %), net of VAT', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Box number and label are this pack''s own: the layout of the monthly return in the Inland Revenue Division''s online service (G-TAX) was not found as a text, so the boxes follow what the Act makes the net amount carry — the output tax of the period less the input tax credits allowed (s. 32(1)). Taxable supplies at fifteen per cent (s. 8(3)(e)).', 'gd-vat-act'),
  ('GD', 'GD-VAT-RETURN', '2', 'base', 'Accommodation and dive-activity supplies (10 %), net of VAT', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Taxable supplies at ten per cent: hotel or holiday accommodation (s. 8(3)(b)) and the dive activity portion of a dive package (s. 8(3)(c)).', 'gd-vat-act'),
  ('GD', 'GD-VAT-RETURN', '3', 'base', 'Electricity supplies (7.5 %), net of VAT', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Taxable supplies of electricity consumption at 7.5 % (Regulations, reg. 4A, inserted by S.R.O. 6 of 2023).', 'gd-vat-regs-2023'),
  ('GD', 'GD-VAT-RETURN', '4', 'base', 'Zero-rated supplies, including exports', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Taxable supplies at zero per cent (s. 8(3)(a); First, Second and Third Schedules); they stay on the return (s. 44(1) asks for a return for each tax period).', 'gd-vat-act'),
  ('GD', 'GD-VAT-RETURN', '5', 'base', 'Exempt supplies', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Supplies of the Fourth Schedule, reported for information; the input tax of what is acquired to make them is not creditable (s. 34(3)(b)).', 'gd-vat-act'),
  ('GD', 'GD-VAT-RETURN', '6', 'total', 'Total supplies', '{}'::jsonb, 60, null, array['1', '2', '3', '4', '5']::text[], '{}'::text[], null, null, false, false, null, 'Sum of boxes 1 to 5 — the sum is this pack''s reading, the form is the Comptroller''s (s. 44(2)).', 'gd-vat-act'),
  ('GD', 'GD-VAT-RETURN', '7', 'tax', 'Output tax on standard-rated supplies', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tax at 15 % on box 1 (s. 8(3)(e)).', 'gd-vat-act'),
  ('GD', 'GD-VAT-RETURN', '8', 'tax', 'Output tax on accommodation and dive activity', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tax at 10 % on box 2 (s. 8(3)(b), (c)).', 'gd-vat-act'),
  ('GD', 'GD-VAT-RETURN', '9', 'tax', 'Output tax on electricity', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tax at 7.5 % on box 3 (Regulations, reg. 4A).', 'gd-vat-regs-2023'),
  ('GD', 'GD-VAT-RETURN', '10', 'total', 'Total output tax for the period', '{}'::jsonb, 100, null, array['7', '8', '9']::text[], '{}'::text[], null, null, false, false, null, 'Amount A of the net amount: the output tax chargeable on the taxable supplies of the period (s. 32(1)(a)); a credit note posts a negative amount to its own boxes (s. 39).', 'gd-vat-act'),
  ('GD', 'GD-VAT-RETURN', '11', 'base', 'Value of imports', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Goods imported on which tax was paid to the Comptroller of Customs (s. 8(1)(b), s. 47).', 'gd-vat-act'),
  ('GD', 'GD-VAT-RETURN', '12', 'base', 'Value of local purchases', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Purchases made in Grenada for the taxable activity, taxable, zero-rated and exempt.', 'gd-vat-act'),
  ('GD', 'GD-VAT-RETURN', '13', 'tax', 'VAT paid on imports', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Input tax paid on the import of goods, creditable for use in a taxable activity (s. 34).', 'gd-vat-act'),
  ('GD', 'GD-VAT-RETURN', '14', 'tax', 'VAT paid on local purchases', '{}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Input tax chargeable on taxable acquisitions, creditable on a VAT invoice (s. 34, s. 37).', 'gd-vat-act'),
  ('GD', 'GD-VAT-RETURN', '15', 'total', 'Total input tax credits for the period', '{}'::jsonb, 150, null, array['13', '14']::text[], '{}'::text[], null, null, false, false, null, 'Sum of boxes 13 and 14: amount B of the net amount, the input tax credits allowed for the period (s. 32(1)(b), s. 34).', 'gd-vat-act'),
  ('GD', 'GD-VAT-RETURN', '16', 'total', 'VAT payable', '{}'::jsonb, 160, null, array['10']::text[], array['15']::text[], null, null, true, false, null, 'Output tax less input tax credits when positive (s. 32(2)), due by the date the return is due (s. 46(1)). Late fee, late payment fee and interest (s. 44(3), s. 46(3), s. 68) are not modelled.', 'gd-vat-act'),
  ('GD', 'GD-VAT-RETURN', '17', 'total', 'VAT refundable', '{}'::jsonb, 170, null, array['15']::text[], array['10']::text[], null, null, true, false, null, 'The excess of the input tax credits over the output tax (s. 32(3)): carried forward as an input tax credit for up to three following tax periods, then refunded on application when it exceeds $250, within two calendar months; refunded at once when half or more of the turnover or of the input expenditure relates to zero-rated or export supplies (s. 49). The pack only reports box 17.', 'gd-vat-act')
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
  ('GD-IFRS-SME-IS', 'GD', 'default', 'Income statement', 'income_statement', 'IFRS-SME', date '1970-01-01', null, 'Same choice as the statement of financial position: the income statement is presented in the manner of IFRS for SMEs, section 5, with the expenses collapsed to cost of sales, other operating expenses and depreciation. No Grenada text read prescribes it. The corporate income tax charge (6470) falls in other operating expenses; the Income Tax Act was not opened and the tax is not modelled', 'iasb-ifrs-sme', null, null, '{}'::jsonb),
  ('GD-IFRS-SME-SFP', 'GD', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS-SME', date '1970-01-01', null, 'The Companies Act and the Income Tax Act of Grenada were not opened for this pack, so no section of either is cited, and none is asserted to prescribe a layout. This statement follows the presentation of IFRS for SMEs (International Accounting Standards Board), section 4: current and non-current assets and liabilities, with equity shown beside them; that is a choice of this pack, not a text the country imposes, and a company reporting under full IFRS presents the same balance sheet with different notes. The numbering and the ranges each line reads are original to this pack. The VAT collected (2100 to 2199) is a current tax liability; the VAT recoverable sits with the receivables (1170 to 1172), unnetted. Cash flows and changes in equity are separate statements this pack does not model', 'iasb-ifrs-sme', 'alone', null, '{}'::jsonb)
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
  ('GD-IFRS-SME-IS', 'REV', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GD-IFRS-SME-IS', 'COST', null, 'Cost of sales', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GD-IFRS-SME-IS', 'GROSS', null, 'Gross profit', '{}'::jsonb, 30, 1, true, array['REV']::text[], array['COST']::text[], null, null, null),
  ('GD-IFRS-SME-IS', 'OTH-INC', null, 'Other income', '{}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GD-IFRS-SME-IS', 'OPEX', null, 'Administrative and other operating expenses', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GD-IFRS-SME-IS', 'DEPR', null, 'Depreciation and amortisation', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GD-IFRS-SME-IS', 'PROFIT', null, 'Profit (loss) for the year', '{}'::jsonb, 70, 1, true, array['GROSS', 'OTH-INC']::text[], array['OPEX', 'DEPR']::text[], null, null, null),
  ('GD-IFRS-SME-SFP', 'A-NC-FIX', 'A-NC', 'Property, plant and equipment', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GD-IFRS-SME-SFP', 'A-NC-INT', 'A-NC', 'Goodwill and other intangible assets', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GD-IFRS-SME-SFP', 'A-NC-OTH', 'A-NC', 'Other non-current assets', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GD-IFRS-SME-SFP', 'A-NC', null, 'Non-current assets', '{}'::jsonb, 40, 1, true, array['A-NC-FIX', 'A-NC-INT', 'A-NC-OTH']::text[], '{}'::text[], null, null, null),
  ('GD-IFRS-SME-SFP', 'A-C-REC', 'A-C', 'Trade and other receivables', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GD-IFRS-SME-SFP', 'A-C-INV', 'A-C', 'Inventories', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GD-IFRS-SME-SFP', 'A-C-OTH', 'A-C', 'Other current assets', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GD-IFRS-SME-SFP', 'A-C-PRE', 'A-C', 'Prepayments and deposits paid', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GD-IFRS-SME-SFP', 'A-C-CASH', 'A-C', 'Cash and cash equivalents', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GD-IFRS-SME-SFP', 'A-C', null, 'Current assets', '{}'::jsonb, 100, 1, true, array['A-C-REC', 'A-C-INV', 'A-C-OTH', 'A-C-PRE', 'A-C-CASH']::text[], '{}'::text[], null, null, null),
  ('GD-IFRS-SME-SFP', 'A-TOT', null, 'Total assets', '{}'::jsonb, 110, 1, true, array['A-NC', 'A-C']::text[], '{}'::text[], null, null, null),
  ('GD-IFRS-SME-SFP', 'E-CAP', 'E-TOT', 'Share capital and reserves', '{}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GD-IFRS-SME-SFP', 'E-RET', 'E-TOT', 'Retained earnings', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GD-IFRS-SME-SFP', 'E-RESULT', 'E-TOT', 'Profit or loss for the year, not yet allocated', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GD-IFRS-SME-SFP', 'E-TOT', null, 'Total equity', '{}'::jsonb, 150, 1, true, array['E-CAP', 'E-RET', 'E-RESULT']::text[], '{}'::text[], null, null, null),
  ('GD-IFRS-SME-SFP', 'L-NC', 'L-TOT', 'Non-current liabilities', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GD-IFRS-SME-SFP', 'L-C-PAY', 'L-C', 'Trade and other payables', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GD-IFRS-SME-SFP', 'L-C-TAX', 'L-C', 'Current tax liabilities, including VAT collected', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GD-IFRS-SME-SFP', 'L-C-OTH', 'L-C', 'Other current liabilities', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GD-IFRS-SME-SFP', 'L-C', null, 'Current liabilities', '{}'::jsonb, 200, 1, true, array['L-C-PAY', 'L-C-TAX', 'L-C-OTH']::text[], '{}'::text[], null, null, null),
  ('GD-IFRS-SME-SFP', 'L-TOT', null, 'Total liabilities', '{}'::jsonb, 210, 1, true, array['L-NC', 'L-C']::text[], '{}'::text[], null, null, null),
  ('GD-IFRS-SME-SFP', 'EL-TOT', null, 'Total equity and liabilities', '{}'::jsonb, 220, 1, true, array['E-TOT', 'L-TOT']::text[], '{}'::text[], null, null, null)
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
 where r.statement_code in ('GD-IFRS-SME-IS', 'GD-IFRS-SME-SFP')
   and (r.statement_code, r.line_code, r.sequence) not in (
     values ('GD-IFRS-SME-IS', 'REV', 10),
            ('GD-IFRS-SME-IS', 'COST', 10),
            ('GD-IFRS-SME-IS', 'OTH-INC', 10),
            ('GD-IFRS-SME-IS', 'OPEX', 10),
            ('GD-IFRS-SME-IS', 'DEPR', 10),
            ('GD-IFRS-SME-SFP', 'A-NC-FIX', 10),
            ('GD-IFRS-SME-SFP', 'A-NC-INT', 10),
            ('GD-IFRS-SME-SFP', 'A-NC-OTH', 10),
            ('GD-IFRS-SME-SFP', 'A-C-REC', 10),
            ('GD-IFRS-SME-SFP', 'A-C-INV', 10),
            ('GD-IFRS-SME-SFP', 'A-C-OTH', 10),
            ('GD-IFRS-SME-SFP', 'A-C-PRE', 10),
            ('GD-IFRS-SME-SFP', 'A-C-CASH', 10),
            ('GD-IFRS-SME-SFP', 'E-CAP', 10),
            ('GD-IFRS-SME-SFP', 'E-RET', 10),
            ('GD-IFRS-SME-SFP', 'E-RESULT', 10),
            ('GD-IFRS-SME-SFP', 'E-RESULT', 20),
            ('GD-IFRS-SME-SFP', 'E-RESULT', 30),
            ('GD-IFRS-SME-SFP', 'E-RESULT', 40),
            ('GD-IFRS-SME-SFP', 'L-NC', 10),
            ('GD-IFRS-SME-SFP', 'L-C-PAY', 10),
            ('GD-IFRS-SME-SFP', 'L-C-TAX', 10),
            ('GD-IFRS-SME-SFP', 'L-C-TAX', 20),
            ('GD-IFRS-SME-SFP', 'L-C-OTH', 10),
            ('GD-IFRS-SME-SFP', 'L-C-OTH', 20)
   );

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('GD-IFRS-SME-IS', 'REV', 10, 'code_range', '4000', '4699', null, 'any'),
    ('GD-IFRS-SME-IS', 'COST', 10, 'code_range', '5000', '5099', null, 'any'),
    ('GD-IFRS-SME-IS', 'OTH-INC', 10, 'code_range', '4700', '4799', null, 'any'),
    ('GD-IFRS-SME-IS', 'OPEX', 10, 'code_range', '6000', '6799', null, 'any'),
    ('GD-IFRS-SME-IS', 'DEPR', 10, 'code_range', '6800', '6899', null, 'any'),
    ('GD-IFRS-SME-SFP', 'A-NC-FIX', 10, 'code_range', '1600', '1799', null, 'any'),
    ('GD-IFRS-SME-SFP', 'A-NC-INT', 10, 'code_range', '1800', '1899', null, 'any'),
    ('GD-IFRS-SME-SFP', 'A-NC-OTH', 10, 'code_range', '1900', '1999', null, 'any'),
    ('GD-IFRS-SME-SFP', 'A-C-REC', 10, 'code_range', '1100', '1199', null, 'any'),
    ('GD-IFRS-SME-SFP', 'A-C-INV', 10, 'code_range', '1200', '1299', null, 'any'),
    ('GD-IFRS-SME-SFP', 'A-C-OTH', 10, 'code_range', '1300', '1399', null, 'any'),
    ('GD-IFRS-SME-SFP', 'A-C-PRE', 10, 'code_range', '1400', '1499', null, 'any'),
    ('GD-IFRS-SME-SFP', 'A-C-CASH', 10, 'code_range', '1000', '1099', null, 'any'),
    ('GD-IFRS-SME-SFP', 'E-CAP', 10, 'code_range', '3000', '3199', null, 'any'),
    ('GD-IFRS-SME-SFP', 'E-RET', 10, 'code_range', '3200', '3299', null, 'any'),
    ('GD-IFRS-SME-SFP', 'E-RESULT', 10, 'code_range', '4000', '4699', null, 'any'),
    ('GD-IFRS-SME-SFP', 'E-RESULT', 20, 'code_range', '4700', '4799', null, 'any'),
    ('GD-IFRS-SME-SFP', 'E-RESULT', 30, 'code_range', '5000', '5099', null, 'any'),
    ('GD-IFRS-SME-SFP', 'E-RESULT', 40, 'code_range', '6000', '6899', null, 'any'),
    ('GD-IFRS-SME-SFP', 'L-NC', 10, 'code_range', '2300', '2399', null, 'any'),
    ('GD-IFRS-SME-SFP', 'L-C-PAY', 10, 'code_range', '2000', '2059', null, 'any'),
    ('GD-IFRS-SME-SFP', 'L-C-TAX', 10, 'code_range', '2060', '2069', null, 'any'),
    ('GD-IFRS-SME-SFP', 'L-C-TAX', 20, 'code_range', '2100', '2199', null, 'any'),
    ('GD-IFRS-SME-SFP', 'L-C-OTH', 10, 'code_range', '2070', '2099', null, 'any'),
    ('GD-IFRS-SME-SFP', 'L-C-OTH', 20, 'code_range', '2200', '2299', null, 'any')
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
  ('GD', 'Grenada', '{}'::jsonb, array['en']::text[], 'XCD', '1100', '2000', '2090', '6490', '3200', '4000', '5010', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6450', '4750', '6460', null, null, '2100', '1172', null, 'month'::declaration_period)
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
  numbering_legal_reference     = 'Value Added Tax Act, Cap. 333A, s. 37 — VAT invoices, and s. 39 — VAT credit and debit notes. The Act, as read for this pack, does not say that the series of invoice numbers may have no gap, which is why `numbering` is `sequential` and not `gapless`; `number_format` is a convention this pack proposes. The particulars of a VAT invoice are not printed as mentions',
  numbering_source_key          = 'gd-vat-act',
  payment_terms_legal_reference = 'No Grenadian text read for this pack sets a payment term between two businesses or a rate of interest on a commercial debt paid late: the late payment fee of twenty per cent (s. 46(3)) and the interest of s. 68 are charges on the taxable person towards the Comptroller, not a term between two businesses. `legal_payment_days` and `late_payment_reference` are empty',
  payment_terms_source_key      = 'gd-vat-act',
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'The time-of-supply rules of the Value Added Tax Act, Cap. 333A (Part IV) were not read in full for this pack: `earliest_of_delivery_or_payment` is the nearest value of the closed vocabulary to the usual rule (the earliest of delivery, invoice and payment) and is a convention to be checked against the Act by a reviewer',
  tax_point_source_key          = 'gd-vat-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No Grenadian text read for this pack obliges a business to issue or accept an electronic invoice: the Value Added Tax Act, Cap. 333A, s. 37 asks for a VAT invoice without naming a platform, a format or a Peppol profile. No Peppol authority for Grenada was looked for. `profile`, `party_scheme` and `vat_scheme` are null: there is no domestic profile to name',
  einvoice_source_key           = 'gd-vat-act',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'GD';

update country_defaults set
  tax_payee_name       = 'Inland Revenue Division',
  tax_payee_source_key = 'gd-tax-portal'
 where country = 'GD';
