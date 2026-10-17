-- Ekwo OS — Guyana: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/gy at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build gy`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Value-Added Tax Act 2005 (Act No. 10 of 2005), Laws of Guyana revised edition, as amended up to (O) 6 of 2021 (Authority's updated copy of 14 September 2021); later orders amending the Schedules are not applied to it (Guyana Revenue Authority)
--     https://www.gra.gov.gy/wp-content/uploads/2020/10/VAT-Act-_updated-Sept-14-2021.pdf
--   Value-Added Tax Regulations 2005 as amended (Regulation 8 of 2016) — rate of tax (reg. 2), registration threshold (reg. 3), returns (reg. 6), refunds (reg. 7) (Guyana Revenue Authority)
--     https://gra.gov.gy/storage/2020/06/VATRegulations_Jan2017_.pdf
--   Zero-rated and exempt supplies — Schedules I and II of the Value-Added Tax Act as revised on 27 March 2026 (amendments to Order 3 of 2026, w.e.f. 16 February 2026) (Guyana Revenue Authority)
--     https://www.gra.gov.gy/wp-content/uploads/2026/03/VAT-Zero-and-Exempt-List-Revised-March-27-2026.pdf
--   Value Added Tax Return — who files, when and where (the 21st of every month), and what each line of the return, lines 4 to 26, asks for (Guyana Revenue Authority)
--     https://gra.gov.gy/optimal/vat/
--   VAT Return Form (the printed form of the return) (Guyana Revenue Authority)
--     https://gra.gov.gy/storage/2019/08/VAT_Return_Form.pdf
--   IFRS for SMEs Accounting Standard (IFRS Foundation / International Accounting Standards Board)
--     https://www.ifrs.org/issued-standards/ifrs-for-smes/
--   Optimal eServices — the Authority's online service the return is filed through (Guyana Revenue Authority)
--     https://gra.gov.gy/optimal/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('GY', 'Guyana', '0.1.0', date '2026-10-18', '20261011120000', 'community', null, null, 'ec3d20b81e5bc7d6cd051be6894d2eb422e6735cbf8cb4564a9d13d96750c848', '[{"key":"gy-vat-act","title":"Value-Added Tax Act 2005 (Act No. 10 of 2005), Laws of Guyana revised edition, as amended up to (O) 6 of 2021 (Authority''s updated copy of 14 September 2021); later orders amending the Schedules are not applied to it","publisher":"Guyana Revenue Authority","url":"https://www.gra.gov.gy/wp-content/uploads/2020/10/VAT-Act-_updated-Sept-14-2021.pdf","consulted_on":"2026-10-18","kind":"law"},{"key":"gy-vat-regs","title":"Value-Added Tax Regulations 2005 as amended (Regulation 8 of 2016) — rate of tax (reg. 2), registration threshold (reg. 3), returns (reg. 6), refunds (reg. 7)","publisher":"Guyana Revenue Authority","url":"https://gra.gov.gy/storage/2020/06/VATRegulations_Jan2017_.pdf","consulted_on":"2026-10-18","kind":"regulation"},{"key":"gra-zero-exempt","title":"Zero-rated and exempt supplies — Schedules I and II of the Value-Added Tax Act as revised on 27 March 2026 (amendments to Order 3 of 2026, w.e.f. 16 February 2026)","publisher":"Guyana Revenue Authority","url":"https://www.gra.gov.gy/wp-content/uploads/2026/03/VAT-Zero-and-Exempt-List-Revised-March-27-2026.pdf","consulted_on":"2026-10-18","kind":"guidance"},{"key":"gra-vat-return","title":"Value Added Tax Return — who files, when and where (the 21st of every month), and what each line of the return, lines 4 to 26, asks for","publisher":"Guyana Revenue Authority","url":"https://gra.gov.gy/optimal/vat/","consulted_on":"2026-10-18","kind":"guidance"},{"key":"gra-vat-return-form","title":"VAT Return Form (the printed form of the return)","publisher":"Guyana Revenue Authority","url":"https://gra.gov.gy/storage/2019/08/VAT_Return_Form.pdf","consulted_on":"2026-10-18","kind":"guidance"},{"key":"iasb-ifrs-sme","title":"IFRS for SMEs Accounting Standard","publisher":"IFRS Foundation / International Accounting Standards Board","url":"https://www.ifrs.org/issued-standards/ifrs-for-smes/","consulted_on":"2026-10-18","kind":"standard"},{"key":"gra-optimal","title":"Optimal eServices — the Authority''s online service the return is filed through","publisher":"Guyana Revenue Authority","url":"https://gra.gov.gy/optimal/","consulted_on":"2026-10-18","kind":"portal"}]'::jsonb)
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
  ('GY', 'default', 'Guyana reference chart of accounts', '{}'::jsonb, true, 'companies', array['GY-IFRS-SME-IS', 'GY-IFRS-SME-SFP']::text[], null, 'This pack found no legal chart of accounts in Guyana, and opened neither the Companies Act nor the Income Tax Act: no section of either is cited. What the Value-Added Tax Act 2005 asks of a taxable person is that records be kept (s. 60), with the particulars the Regulations set (reg. 9). This chart is original: four digits, blocked so that each range reaches one line of a statement of financial position and an income statement presented in the manner of IFRS for SMEs, which is a choice of this pack and not a text the country imposes. The settlement account of the VAT return (2100, refundable 1172) is distinct from the accounts the tax posts to (2101 collected, 1170 and 1171 recoverable). See README.md', 'gy-vat-act')
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
  ('GY', 'default', '1000', 'Cash on hand', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('GY', 'default', '1010', 'Bank current account', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('GY', 'default', '1020', 'Bank savings account', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('GY', 'default', '1030', 'Foreign currency bank account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('GY', 'default', '1040', 'Payment gateway and card clearing account', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('GY', 'default', '1050', 'Fixed deposits of three months or less', '{}'::jsonb, 'asset_cash', false, null, 60),
  ('GY', 'default', '1060', 'Cash in transit', '{}'::jsonb, 'asset_cash', false, null, 70),
  ('GY', 'default', '1100', 'Trade debtors', '{}'::jsonb, 'asset_receivable', true, null, 80),
  ('GY', 'default', '1105', 'Allowance for expected credit losses', '{}'::jsonb, 'asset_current', false, null, 90),
  ('GY', 'default', '1110', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 100),
  ('GY', 'default', '1120', 'Other debtors', '{}'::jsonb, 'asset_current', false, null, 110),
  ('GY', 'default', '1130', 'Accrued income', '{}'::jsonb, 'asset_current', false, null, 120),
  ('GY', 'default', '1140', 'Staff advances and loans to employees', '{}'::jsonb, 'asset_current', false, null, 130),
  ('GY', 'default', '1150', 'Customs duty deposits paid', '{}'::jsonb, 'asset_current', false, null, 140),
  ('GY', 'default', '1160', 'Corporation tax recoverable', '{}'::jsonb, 'asset_current', false, null, 150),
  ('GY', 'default', '1170', 'VAT recoverable — local purchases', '{}'::jsonb, 'asset_current', false, null, 160),
  ('GY', 'default', '1171', 'VAT recoverable — imports paid to the Commissioner-General', '{}'::jsonb, 'asset_current', false, null, 170),
  ('GY', 'default', '1172', 'VAT refundable — settlement of the return', '{}'::jsonb, 'asset_current', true, null, 180),
  ('GY', 'default', '1200', 'Inventory — raw materials and consumables', '{}'::jsonb, 'asset_current', false, null, 190),
  ('GY', 'default', '1210', 'Inventory — work in progress', '{}'::jsonb, 'asset_current', false, null, 200),
  ('GY', 'default', '1220', 'Inventory — finished goods and goods for resale', '{}'::jsonb, 'asset_current', false, null, 210),
  ('GY', 'default', '1230', 'Goods in transit', '{}'::jsonb, 'asset_current', false, null, 220),
  ('GY', 'default', '1300', 'Fixed deposits of more than three months', '{}'::jsonb, 'asset_current', false, null, 230),
  ('GY', 'default', '1310', 'Listed investments held for trading', '{}'::jsonb, 'asset_current', false, null, 240),
  ('GY', 'default', '1320', 'Amounts due from related companies — non-trade', '{}'::jsonb, 'asset_current', false, null, 250),
  ('GY', 'default', '1400', 'Prepaid expenses', '{}'::jsonb, 'asset_prepayments', false, null, 260),
  ('GY', 'default', '1410', 'Rental and utility deposits paid', '{}'::jsonb, 'asset_prepayments', false, null, 270),
  ('GY', 'default', '1420', 'Deposits paid to suppliers', '{}'::jsonb, 'asset_prepayments', false, null, 280),
  ('GY', 'default', '1600', 'Leasehold land and buildings', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('GY', 'default', '1610', 'Leasehold improvements', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('GY', 'default', '1620', 'Furniture and fixtures', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('GY', 'default', '1630', 'Office equipment', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('GY', 'default', '1640', 'Computer equipment and software', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('GY', 'default', '1650', 'Motor vehicles', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('GY', 'default', '1660', 'Plant and machinery', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('GY', 'default', '1670', 'Right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('GY', 'default', '1690', 'Accumulated depreciation — property plant and equipment', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('GY', 'default', '1695', 'Accumulated depreciation — right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 380),
  ('GY', 'default', '1800', 'Goodwill', '{}'::jsonb, 'asset_non_current', false, null, 390),
  ('GY', 'default', '1810', 'Other intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 400),
  ('GY', 'default', '1820', 'Accumulated amortisation — intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 410),
  ('GY', 'default', '1900', 'Investments in subsidiaries', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('GY', 'default', '1910', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('GY', 'default', '1920', 'Other long-term investments', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('GY', 'default', '1930', 'Rental and utility deposits — non-current', '{}'::jsonb, 'asset_non_current', false, null, 450),
  ('GY', 'default', '1990', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('GY', 'default', '2000', 'Trade creditors', '{}'::jsonb, 'liability_payable', true, null, 470),
  ('GY', 'default', '2010', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 480),
  ('GY', 'default', '2020', 'Accruals', '{}'::jsonb, 'liability_current', false, null, 490),
  ('GY', 'default', '2030', 'Customer deposits and advances received', '{}'::jsonb, 'liability_current', false, null, 500),
  ('GY', 'default', '2040', 'Salaries and wages payable', '{}'::jsonb, 'liability_current', false, null, 510),
  ('GY', 'default', '2050', 'National Insurance Scheme contributions payable', '{}'::jsonb, 'liability_current', false, null, 520),
  ('GY', 'default', '2060', 'Corporation tax payable', '{}'::jsonb, 'liability_current', false, null, 530),
  ('GY', 'default', '2070', 'Payroll deductions payable', '{}'::jsonb, 'liability_current', false, null, 540),
  ('GY', 'default', '2071', 'Customs duty payable', '{}'::jsonb, 'liability_current', false, null, 550),
  ('GY', 'default', '2072', 'Land tax payable', '{}'::jsonb, 'liability_current', false, null, 560),
  ('GY', 'default', '2073', 'Other government charges payable', '{}'::jsonb, 'liability_current', false, null, 570),
  ('GY', 'default', '2080', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 580),
  ('GY', 'default', '2090', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 590),
  ('GY', 'default', '2100', 'VAT payable — settlement of the return', '{}'::jsonb, 'liability_current', true, null, 600),
  ('GY', 'default', '2101', 'VAT collected — standard rate', '{}'::jsonb, 'liability_current', false, null, 610),
  ('GY', 'default', '2102', 'VAT collected — accommodation rate', '{}'::jsonb, 'liability_current', false, null, 620),
  ('GY', 'default', '2200', 'Corporate credit card payable', '{}'::jsonb, 'liability_credit_card', false, null, 630),
  ('GY', 'default', '2300', 'Bank borrowings — non-current', '{}'::jsonb, 'liability_non_current', false, null, 640),
  ('GY', 'default', '2310', 'Lease liabilities — non-current', '{}'::jsonb, 'liability_non_current', false, null, 650),
  ('GY', 'default', '2320', 'Amounts due to shareholders — non-current', '{}'::jsonb, 'liability_non_current', false, null, 660),
  ('GY', 'default', '2390', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 670),
  ('GY', 'default', '3000', 'Issued and paid-up share capital', '{}'::jsonb, 'equity', false, null, 680),
  ('GY', 'default', '3100', 'Share premium', '{}'::jsonb, 'equity', false, null, 690),
  ('GY', 'default', '3110', 'Capital reserve', '{}'::jsonb, 'equity', false, null, 700),
  ('GY', 'default', '3200', 'Retained profits', '{}'::jsonb, 'equity_retained', false, null, 710),
  ('GY', 'default', '4000', 'Sale of goods', '{}'::jsonb, 'income', false, null, 720),
  ('GY', 'default', '4010', 'Rendering of services', '{}'::jsonb, 'income', false, null, 730),
  ('GY', 'default', '4700', 'Realised exchange gains', '{}'::jsonb, 'income_other', false, null, 740),
  ('GY', 'default', '4710', 'Unrealised exchange gains', '{}'::jsonb, 'income_other', false, null, 750),
  ('GY', 'default', '4720', 'Interest income', '{}'::jsonb, 'income_other', false, null, 760),
  ('GY', 'default', '4730', 'Sundry income', '{}'::jsonb, 'income_other', false, null, 770),
  ('GY', 'default', '4750', 'Gain on disposal of fixed assets', '{}'::jsonb, 'income_other', false, null, 780),
  ('GY', 'default', '5000', 'Cost of goods sold', '{}'::jsonb, 'expense_direct_cost', false, null, 790),
  ('GY', 'default', '5010', 'Purchases', '{}'::jsonb, 'expense_direct_cost', false, null, 800),
  ('GY', 'default', '5020', 'Freight inwards', '{}'::jsonb, 'expense_direct_cost', false, null, 810),
  ('GY', 'default', '5025', 'Customs duty on imports', '{}'::jsonb, 'expense_direct_cost', false, null, 820),
  ('GY', 'default', '5030', 'Direct labour', '{}'::jsonb, 'expense_direct_cost', false, null, 830),
  ('GY', 'default', '6000', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 840),
  ('GY', 'default', '6010', 'Staff salaries and wages', '{}'::jsonb, 'expense', false, null, 850),
  ('GY', 'default', '6020', 'Pension contributions', '{}'::jsonb, 'expense', false, null, 860),
  ('GY', 'default', '6025', 'Employer payroll contributions', '{}'::jsonb, 'expense', false, null, 870),
  ('GY', 'default', '6026', 'National Insurance Scheme — employer contribution', '{}'::jsonb, 'expense', false, null, 880),
  ('GY', 'default', '6030', 'Staff welfare and benefits', '{}'::jsonb, 'expense', false, null, 890),
  ('GY', 'default', '6100', 'Rent and rates', '{}'::jsonb, 'expense', false, null, 900),
  ('GY', 'default', '6110', 'Management fees and building outgoings', '{}'::jsonb, 'expense', false, null, 910),
  ('GY', 'default', '6120', 'Utilities', '{}'::jsonb, 'expense', false, null, 920),
  ('GY', 'default', '6130', 'Land tax', '{}'::jsonb, 'expense', false, null, 930),
  ('GY', 'default', '6200', 'Government fees, licences and company registry fees', '{}'::jsonb, 'expense', false, null, 940),
  ('GY', 'default', '6210', 'Auditor''s remuneration', '{}'::jsonb, 'expense', false, null, 950),
  ('GY', 'default', '6220', 'Accounting and company secretarial fees', '{}'::jsonb, 'expense', false, null, 960),
  ('GY', 'default', '6230', 'Legal and professional fees', '{}'::jsonb, 'expense', false, null, 970),
  ('GY', 'default', '6300', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 980),
  ('GY', 'default', '6310', 'Insurance', '{}'::jsonb, 'expense', false, null, 990),
  ('GY', 'default', '6320', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1000),
  ('GY', 'default', '6330', 'Travelling expenses', '{}'::jsonb, 'expense', false, null, 1010),
  ('GY', 'default', '6340', 'Entertainment expenses', '{}'::jsonb, 'expense', false, null, 1020),
  ('GY', 'default', '6350', 'Advertising and promotion', '{}'::jsonb, 'expense', false, null, 1030),
  ('GY', 'default', '6360', 'Printing, stationery and postage', '{}'::jsonb, 'expense', false, null, 1040),
  ('GY', 'default', '6370', 'Telecommunications', '{}'::jsonb, 'expense', false, null, 1050),
  ('GY', 'default', '6380', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1060),
  ('GY', 'default', '6390', 'Sundry office expenses', '{}'::jsonb, 'expense', false, null, 1070),
  ('GY', 'default', '6400', 'Allowance for expected credit losses charged', '{}'::jsonb, 'expense', false, null, 1080),
  ('GY', 'default', '6410', 'Interest expense on bank borrowings', '{}'::jsonb, 'expense', false, null, 1090),
  ('GY', 'default', '6420', 'Interest expense on lease liabilities', '{}'::jsonb, 'expense', false, null, 1100),
  ('GY', 'default', '6450', 'Realised exchange losses', '{}'::jsonb, 'expense', false, null, 1110),
  ('GY', 'default', '6455', 'Unrealised exchange losses', '{}'::jsonb, 'expense', false, null, 1120),
  ('GY', 'default', '6460', 'Loss on disposal of fixed assets', '{}'::jsonb, 'expense', false, null, 1130),
  ('GY', 'default', '6470', 'Corporation tax charge', '{}'::jsonb, 'expense', false, null, 1140),
  ('GY', 'default', '6480', 'Deferred tax charge', '{}'::jsonb, 'expense', false, null, 1150),
  ('GY', 'default', '6490', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1160),
  ('GY', 'default', '6800', 'Depreciation and amortisation', '{}'::jsonb, 'expense_depreciation', false, null, 1170)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('GY', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('GY', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('GY', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('GY', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('GY', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('GY', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('GY', 'GY-P-0', 'Purchase, zero-rated', '{}'::jsonb, 'A purchase of a supply that Schedule I zero-rates', 'percent', 0, 'purchase', 'domestic', date '2007-01-01', null, 'Value-Added Tax Act 2005, s. 17 and Schedule I — no tax is charged on the supply. Return line 6, zero-rated purchases. valid_from as GY-S-14.', null, null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'gy-vat-act', null, null, null, null),
  ('GY', 'GY-P-14', 'Purchase, VAT 14 %', '{}'::jsonb, 'A local purchase with 14 % VAT, creditable when it serves taxable supplies', 'percent', 14, 'purchase', 'domestic', date '2007-01-01', null, 'Value-Added Tax Act 2005, s. 24(1)(a) — the input tax payable on taxable supplies made to the person in the period, for use in a taxable activity, is a credit against the output tax (s. 23(1)); s. 24(2) — only against a tax invoice, a sales invoice or a debit or credit note. Return lines 8 (standard-rated purchases excluding VAT) and 9 (VAT claimed on local supply of goods and services acquired solely for making taxable supplies). The lines for goods and services acquired for mixed supplies (11 and 12) and the apportionment of s. 25 are not modelled. valid_from as GY-S-14.', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'gy-vat-act', null, null, null, null),
  ('GY', 'GY-P-14-IMP', 'Import, VAT 14 % paid at entry', '{}'::jsonb, 'Goods imported, with VAT paid on entry to the Commissioner-General', 'percent', 14, 'purchase', 'import', date '2007-01-01', null, 'Value-Added Tax Act 2005, s. 9(1)(b) and s. 19 to 22 — tax is levied on an import of goods and paid by the importer on entry of the goods; the value of the import is the customs value with the insurance and freight not already in it (s. 20). The tax paid is input tax creditable for use in a taxable activity (s. 24(1)(a)). Return lines 8 and 10 (VAT claimed on import of goods and services acquired solely for making taxable supplies). The pack applies 14 % to the invoice value: the customs value is the entry''s. valid_from as GY-S-14.', null, null, 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'gy-vat-act', null, null, null, null),
  ('GY', 'GY-P-EX', 'Purchase, exempt', '{}'::jsonb, 'A purchase of an exempt supply', 'percent', 0, 'purchase', 'exempt', date '2007-01-01', null, 'Value-Added Tax Act 2005, s. 18 and Schedule II — no tax is charged on the supply. Return line 7, exempt purchases. valid_from as GY-S-14.', null, null, 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'gy-vat-act', null, null, null, null),
  ('GY', 'GY-S-0', 'Zero-rated supply (export)', '{}'::jsonb, 'An export of goods or services, zero-rated', 'percent', 0, 'sale', 'export', date '2007-01-01', null, 'Value-Added Tax Act 2005, s. 17(1) and Schedule I, paragraphs 2 and 3 — goods exported from Guyana by the supplier, and the services of the export list, are charged at zero per cent; s. 17(2) requires the supplier to keep documentary proof acceptable to the Commissioner. A zero-rated supply is a taxable supply: the input tax of what produces it stays creditable, and the Authority''s return carries it on its own line, zero-rated sales (line 15). valid_from as GY-S-14.', 'G', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'gy-vat-act', null, null, null, null),
  ('GY', 'GY-S-14', 'Sale, VAT 14 %', '{}'::jsonb, 'A taxable supply made in Guyana by a registered person, standard-rated', 'percent', 14, 'sale', 'domestic', date '2007-01-01', null, 'Value-Added Tax Act 2005 (Act No. 10 of 2005), s. 9(1)(a) — a tax levied on every taxable supply by a taxable person in Guyana, at the single rate the Minister fixes by regulations, accounted for by the person making the supply (s. 9(2)(a)); Value-Added Tax Regulations, reg. 2 — fourteen per cent (14 %). The Authority''s return page names the same line: standard-rated sales excluding VAT (line 17) and the VAT charged (line 18); box numbers of this pack are the line numbers of that return. valid_from 1 January 2007: the Act leaves its commencement to a ministerial order (s. 1(2)) that was not read, so this date, on which the tax is understood to have begun, is an assumption to verify.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'gy-vat-act', null, null, null, null),
  ('GY', 'GY-S-14-INC', 'Retail sale, VAT 14 %, the price includes the tax', '{}'::jsonb, 'A standard-rated sale whose price already holds the VAT', 'percent', 14, 'sale', 'domestic', date '2007-01-01', null, 'Value-Added Tax Act 2005, s. 9(1)(a) and Regulations reg. 2 (14 %), as GY-S-14. Where a part of the price represents tax not accounted for separately, the value of the supply is the price reduced by the tax fraction multiplied by that price (s. 16(2)): 114.00 holds 100.00 and 14.00, which is what price_include does. Same lines as GY-S-14. valid_from as GY-S-14.', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, true, false, null, 'gy-vat-act', null, null, null, null),
  ('GY', 'GY-S-EX', 'Exempt supply', '{}'::jsonb, 'A supply that Schedule II exempts', 'percent', 0, 'sale', 'exempt', date '2007-01-01', null, 'Value-Added Tax Act 2005, s. 18(1) and Schedule II, paragraph 2 — exempt are, among others, financial services to the extent the Minister''s regulations provide, international transport services, kerosene, liquid propane and butane gas, gasoline and diesel, accommodation in a residential dwelling, funeral services and locally mined raw gold or diamonds certified by the competent bodies; s. 18(2) — a supply that would be zero-rated is never exempt. No input tax is creditable on what is bought to make exempt supplies. Exempt sales, line 16 of the return. valid_from as GY-S-14.', 'E', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'gra-zero-exempt', null, null, null, null),
  ('GY', 'GY-S-Z', 'Zero-rated supply (domestic)', '{}'::jsonb, 'A supply made in Guyana that Schedule I zero-rates', 'percent', 0, 'sale', 'domestic', date '2007-01-01', null, 'Value-Added Tax Act 2005, s. 17(1) and Schedule I — besides exports, the Schedule zero-rates domestic supplies listed by heading (raw and packaging materials, medical supplies, utilities, construction, agriculture, food, household necessities, education, computer and internet data; the list was revised on 27 March 2026 and amended by Order 3 of 2026, w.e.f. 16 February 2026). The pack does not reproduce the list: whether a supply is on it is the user''s, with their accountant, against the Authority''s list (source gra-zero-exempt). Line 15 of the return. valid_from as GY-S-14.', 'Z', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'gra-zero-exempt', null, null, null, null)
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
    ('GY-P-0', 'invoice', 'base', 100, null, '6', array['6']::text[], 100, 'GY-VAT-RETURN', 10),
    ('GY-P-0', 'credit_note', 'base', 100, null, '6', array['6']::text[], -100, 'GY-VAT-RETURN', 10),
    ('GY-P-14', 'invoice', 'base', 100, null, '8', array['8']::text[], 100, 'GY-VAT-RETURN', 10),
    ('GY-P-14', 'invoice', 'tax', 100, '1170', '9', array['9']::text[], 100, 'GY-VAT-RETURN', 20),
    ('GY-P-14', 'credit_note', 'base', 100, null, '8', array['8']::text[], -100, 'GY-VAT-RETURN', 10),
    ('GY-P-14', 'credit_note', 'tax', 100, '1170', '9', array['9']::text[], -100, 'GY-VAT-RETURN', 20),
    ('GY-P-14-IMP', 'invoice', 'base', 100, null, '8', array['8']::text[], 100, 'GY-VAT-RETURN', 10),
    ('GY-P-14-IMP', 'invoice', 'tax', 100, '1171', '10', array['10']::text[], 100, 'GY-VAT-RETURN', 20),
    ('GY-P-14-IMP', 'credit_note', 'base', 100, null, '8', array['8']::text[], -100, 'GY-VAT-RETURN', 10),
    ('GY-P-14-IMP', 'credit_note', 'tax', 100, '1171', '10', array['10']::text[], -100, 'GY-VAT-RETURN', 20),
    ('GY-P-EX', 'invoice', 'base', 100, null, '7', array['7']::text[], 100, 'GY-VAT-RETURN', 10),
    ('GY-P-EX', 'credit_note', 'base', 100, null, '7', array['7']::text[], -100, 'GY-VAT-RETURN', 10),
    ('GY-S-0', 'invoice', 'base', 100, null, '15', array['15']::text[], 100, 'GY-VAT-RETURN', 10),
    ('GY-S-0', 'credit_note', 'base', 100, null, '15', array['15']::text[], -100, 'GY-VAT-RETURN', 10),
    ('GY-S-14', 'invoice', 'base', 100, null, '17', array['17']::text[], 100, 'GY-VAT-RETURN', 10),
    ('GY-S-14', 'invoice', 'tax', 100, '2101', '18', array['18']::text[], 100, 'GY-VAT-RETURN', 20),
    ('GY-S-14', 'credit_note', 'base', 100, null, '17', array['17']::text[], -100, 'GY-VAT-RETURN', 10),
    ('GY-S-14', 'credit_note', 'tax', 100, '2101', '18', array['18']::text[], -100, 'GY-VAT-RETURN', 20),
    ('GY-S-14-INC', 'invoice', 'base', 100, null, '17', array['17']::text[], 100, 'GY-VAT-RETURN', 10),
    ('GY-S-14-INC', 'invoice', 'tax', 100, '2101', '18', array['18']::text[], 100, 'GY-VAT-RETURN', 20),
    ('GY-S-14-INC', 'credit_note', 'base', 100, null, '17', array['17']::text[], -100, 'GY-VAT-RETURN', 10),
    ('GY-S-14-INC', 'credit_note', 'tax', 100, '2101', '18', array['18']::text[], -100, 'GY-VAT-RETURN', 20),
    ('GY-S-EX', 'invoice', 'base', 100, null, '16', array['16']::text[], 100, 'GY-VAT-RETURN', 10),
    ('GY-S-EX', 'credit_note', 'base', 100, null, '16', array['16']::text[], -100, 'GY-VAT-RETURN', 10),
    ('GY-S-Z', 'invoice', 'base', 100, null, '15', array['15']::text[], 100, 'GY-VAT-RETURN', 10),
    ('GY-S-Z', 'credit_note', 'base', 100, null, '15', array['15']::text[], -100, 'GY-VAT-RETURN', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'GY' and t.code = v.tax_code
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
  ('GY', 'GY-VAT-RETURN', 'VAT return (line numbers of the Authority''s Value Added Tax Return)', array['month']::declaration_period[], 'month'::declaration_period, date '2007-01-01', null, 'Value-Added Tax Act 2005, s. 30 and Schedule IV — the tax period is the calendar month (the Act''s definition of ''tax period''; the Minister may authorise another period for a class of persons); s. 31(1) — a return for each tax period, whether or not tax is payable; s. 31(2) — in the form the Commissioner prescribes. The Authority''s return page gives the due date: the 21st of every month, or the next business day when the 21st is a holiday. The revised Act read for this pack says fifteen days after the end of the period: the page of the Authority, which is the current instruction, is what the pack follows (see README). The box numbers are the line numbers of the Authority''s return (lines 4 to 26); the lines this pack does not post to are left out.', true,'day_of_month_after_period'::filing_deadline_rule, 21, null, 'Authority''s return page, ''When and where does this return need to be submitted'': the due date is the 21st of every month, or the next business day if the 21st is a holiday. Value-Added Tax Act 2005, s. 31(1) as consolidated reads fifteen days after the end of the period, and s. 42(1)(a) makes the tax payable by the due date of the return. Weekend and holiday roll-forward is not expressible.', 'gra-vat-return', null)
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
  ('GY', 'GY-VAT-RETURN', '6', 'base', 'Zero-rated purchases', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Line 6 of the Authority''s Value Added Tax Return (page ''Value Added Tax Return'', source gra-vat-return): purchases of supplies that Schedule I zero-rates.', 'gra-vat-return'),
  ('GY', 'GY-VAT-RETURN', '7', 'base', 'Exempt purchases', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Line 7 of the Authority''s Value Added Tax Return (page ''Value Added Tax Return'', source gra-vat-return): purchases of supplies that Schedule II exempts.', 'gra-vat-return'),
  ('GY', 'GY-VAT-RETURN', '8', 'base', 'Standard-rated purchases excluding VAT', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Line 8 of the Authority''s Value Added Tax Return (page ''Value Added Tax Return'', source gra-vat-return): the tax-exclusive value of purchases and imports on which 14 % was charged.', 'gra-vat-return'),
  ('GY', 'GY-VAT-RETURN', '9', 'tax', 'VAT claimed on local supplies acquired solely for taxable supplies', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Line 9 of the Authority''s Value Added Tax Return (page ''Value Added Tax Return'', source gra-vat-return): input tax on local purchases, creditable under s. 24(1)(a) of the Act.', 'gy-vat-act'),
  ('GY', 'GY-VAT-RETURN', '10', 'tax', 'VAT claimed on imports acquired solely for taxable supplies', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Line 10 of the Authority''s Value Added Tax Return (page ''Value Added Tax Return'', source gra-vat-return): tax paid on imports of goods and services, creditable under s. 24(1)(a) of the Act.', 'gy-vat-act'),
  ('GY', 'GY-VAT-RETURN', '14', 'total', 'Total input VAT', '{}'::jsonb, 60, null, array['9', '10']::text[], '{}'::text[], null, null, false, false, null, 'Line 14 of the Authority''s Value Added Tax Return (page ''Value Added Tax Return'', source gra-vat-return): the Authority adds lines 9 to 13; this pack posts to lines 9 and 10 only (11 and 12, mixed supplies, and 13, adjustments of earlier periods, are not modelled), so the total is lines 9 and 10.', 'gra-vat-return'),
  ('GY', 'GY-VAT-RETURN', '15', 'base', 'Zero-rated sales', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Line 15 of the Authority''s Value Added Tax Return (page ''Value Added Tax Return'', source gra-vat-return): the total consideration of the zero-rated supplies of the period, exports included (s. 17, Schedule I).', 'gra-vat-return'),
  ('GY', 'GY-VAT-RETURN', '16', 'base', 'Exempt sales', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Line 16 of the Authority''s Value Added Tax Return (page ''Value Added Tax Return'', source gra-vat-return): the value of the exempt supplies of the period (s. 18, Schedule II).', 'gra-vat-return'),
  ('GY', 'GY-VAT-RETURN', '17', 'base', 'Standard-rated sales excluding VAT', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Line 17 of the Authority''s Value Added Tax Return (page ''Value Added Tax Return'', source gra-vat-return): the tax-exclusive value of the standard-rated supplies (14 %, s. 9(1)(a) and Regulations reg. 2).', 'gra-vat-return'),
  ('GY', 'GY-VAT-RETURN', '18', 'tax', 'VAT charged on goods and services during this period', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Line 18 of the Authority''s Value Added Tax Return (page ''Value Added Tax Return'', source gra-vat-return): the output tax due on the supplies of the period; a credit note posts a negative amount to the same lines (s. 29).', 'gy-vat-act'),
  ('GY', 'GY-VAT-RETURN', '20', 'total', 'Total output VAT', '{}'::jsonb, 110, null, array['18']::text[], '{}'::text[], null, null, false, false, null, 'Line 20 of the Authority''s Value Added Tax Return (page ''Value Added Tax Return'', source gra-vat-return): the Authority adds line 18 and line 19 (output tax under-declared in earlier periods, not modelled); the total is line 18.', 'gra-vat-return'),
  ('GY', 'GY-VAT-RETURN', '25', 'total', 'VAT payable', '{}'::jsonb, 120, null, array['20']::text[], array['14']::text[], null, null, true, false, null, 'Line 25 of the Authority''s Value Added Tax Return (page ''Value Added Tax Return'', source gra-vat-return): output tax less the total input tax credit for the period, payable by the due date of the return (s. 23(1), s. 42(1)(a)). Interest on unpaid tax (two per cent a month or part of a month, s. 27 and Schedule IV) and the penalty for a late return are not modelled. The credit brought forward from earlier months (line 5) is not an input of this pack: the pack reads the books of the period.', 'gy-vat-act'),
  ('GY', 'GY-VAT-RETURN', '23', 'total', 'VAT refundable', '{}'::jsonb, 130, null, array['14']::text[], array['20']::text[], null, null, true, false, null, 'Line 23 of the Authority''s Value Added Tax Return (page ''Value Added Tax Return'', source gra-vat-return): the excess of the input tax credit over the output tax: carried forward to the next period as input tax (s. 35(2)) and refundable on claim only after six consecutive periods (s. 35(3)); the Regulations (reg. 7) deal with claims, and the Authority lets a registered person whose sales are mostly zero-rated claim monthly, which the pack does not model.', 'gy-vat-act')
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
  ('GY-IFRS-SME-IS', 'GY', 'default', 'Income statement', 'income_statement', 'IFRS-SME', date '1970-01-01', null, 'Same choice as the statement of financial position: the income statement is presented in the manner of IFRS for SMEs, section 5, with the expenses collapsed to cost of sales, other operating expenses and depreciation. No Guyanese text read prescribes it. The corporation tax charge (6470) falls in other operating expenses; the Income Tax Act and the Corporation Tax Act were not opened and the tax is not modelled', 'iasb-ifrs-sme', null, null, '{}'::jsonb),
  ('GY-IFRS-SME-SFP', 'GY', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS-SME', date '1970-01-01', null, 'The Companies Act and the Income Tax Act of Guyana were not opened for this pack, so no section of either is cited, and none is asserted to prescribe a layout. This statement follows the presentation of IFRS for SMEs (International Accounting Standards Board), section 4: current and non-current assets and liabilities, with equity shown beside them; that is a choice of this pack, not a text the country imposes, and a company reporting under full IFRS presents the same balance sheet with different notes. The numbering and the ranges each line reads are original to this pack. The VAT collected (2100 to 2199) is a current tax liability; the VAT recoverable sits with the receivables (1170 to 1172), unnetted. Cash flows and changes in equity are separate statements this pack does not model', 'iasb-ifrs-sme', 'alone', null, '{}'::jsonb)
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
  ('GY-IFRS-SME-IS', 'REV', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GY-IFRS-SME-IS', 'COST', null, 'Cost of sales', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GY-IFRS-SME-IS', 'GROSS', null, 'Gross profit', '{}'::jsonb, 30, 1, true, array['REV']::text[], array['COST']::text[], null, null, null),
  ('GY-IFRS-SME-IS', 'OTH-INC', null, 'Other income', '{}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GY-IFRS-SME-IS', 'OPEX', null, 'Administrative and other operating expenses', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GY-IFRS-SME-IS', 'DEPR', null, 'Depreciation and amortisation', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GY-IFRS-SME-IS', 'PROFIT', null, 'Profit (loss) for the year', '{}'::jsonb, 70, 1, true, array['GROSS', 'OTH-INC']::text[], array['OPEX', 'DEPR']::text[], null, null, null),
  ('GY-IFRS-SME-SFP', 'A-NC-FIX', 'A-NC', 'Property, plant and equipment', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GY-IFRS-SME-SFP', 'A-NC-INT', 'A-NC', 'Goodwill and other intangible assets', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GY-IFRS-SME-SFP', 'A-NC-OTH', 'A-NC', 'Other non-current assets', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GY-IFRS-SME-SFP', 'A-NC', null, 'Non-current assets', '{}'::jsonb, 40, 1, true, array['A-NC-FIX', 'A-NC-INT', 'A-NC-OTH']::text[], '{}'::text[], null, null, null),
  ('GY-IFRS-SME-SFP', 'A-C-REC', 'A-C', 'Trade and other receivables', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GY-IFRS-SME-SFP', 'A-C-INV', 'A-C', 'Inventories', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GY-IFRS-SME-SFP', 'A-C-OTH', 'A-C', 'Other current assets', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GY-IFRS-SME-SFP', 'A-C-PRE', 'A-C', 'Prepayments and deposits paid', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GY-IFRS-SME-SFP', 'A-C-CASH', 'A-C', 'Cash and cash equivalents', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GY-IFRS-SME-SFP', 'A-C', null, 'Current assets', '{}'::jsonb, 100, 1, true, array['A-C-REC', 'A-C-INV', 'A-C-OTH', 'A-C-PRE', 'A-C-CASH']::text[], '{}'::text[], null, null, null),
  ('GY-IFRS-SME-SFP', 'A-TOT', null, 'Total assets', '{}'::jsonb, 110, 1, true, array['A-NC', 'A-C']::text[], '{}'::text[], null, null, null),
  ('GY-IFRS-SME-SFP', 'E-CAP', 'E-TOT', 'Share capital and reserves', '{}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GY-IFRS-SME-SFP', 'E-RET', 'E-TOT', 'Retained earnings', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GY-IFRS-SME-SFP', 'E-RESULT', 'E-TOT', 'Profit or loss for the year, not yet allocated', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GY-IFRS-SME-SFP', 'E-TOT', null, 'Total equity', '{}'::jsonb, 150, 1, true, array['E-CAP', 'E-RET', 'E-RESULT']::text[], '{}'::text[], null, null, null),
  ('GY-IFRS-SME-SFP', 'L-NC', 'L-TOT', 'Non-current liabilities', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GY-IFRS-SME-SFP', 'L-C-PAY', 'L-C', 'Trade and other payables', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GY-IFRS-SME-SFP', 'L-C-TAX', 'L-C', 'Current tax liabilities, including VAT collected', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GY-IFRS-SME-SFP', 'L-C-OTH', 'L-C', 'Other current liabilities', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GY-IFRS-SME-SFP', 'L-C', null, 'Current liabilities', '{}'::jsonb, 200, 1, true, array['L-C-PAY', 'L-C-TAX', 'L-C-OTH']::text[], '{}'::text[], null, null, null),
  ('GY-IFRS-SME-SFP', 'L-TOT', null, 'Total liabilities', '{}'::jsonb, 210, 1, true, array['L-NC', 'L-C']::text[], '{}'::text[], null, null, null),
  ('GY-IFRS-SME-SFP', 'EL-TOT', null, 'Total equity and liabilities', '{}'::jsonb, 220, 1, true, array['E-TOT', 'L-TOT']::text[], '{}'::text[], null, null, null)
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
 where r.statement_code in ('GY-IFRS-SME-IS', 'GY-IFRS-SME-SFP')
   and (r.statement_code, r.line_code, r.sequence) not in (
     values ('GY-IFRS-SME-IS', 'REV', 10),
            ('GY-IFRS-SME-IS', 'COST', 10),
            ('GY-IFRS-SME-IS', 'OTH-INC', 10),
            ('GY-IFRS-SME-IS', 'OPEX', 10),
            ('GY-IFRS-SME-IS', 'DEPR', 10),
            ('GY-IFRS-SME-SFP', 'A-NC-FIX', 10),
            ('GY-IFRS-SME-SFP', 'A-NC-INT', 10),
            ('GY-IFRS-SME-SFP', 'A-NC-OTH', 10),
            ('GY-IFRS-SME-SFP', 'A-C-REC', 10),
            ('GY-IFRS-SME-SFP', 'A-C-INV', 10),
            ('GY-IFRS-SME-SFP', 'A-C-OTH', 10),
            ('GY-IFRS-SME-SFP', 'A-C-PRE', 10),
            ('GY-IFRS-SME-SFP', 'A-C-CASH', 10),
            ('GY-IFRS-SME-SFP', 'E-CAP', 10),
            ('GY-IFRS-SME-SFP', 'E-RET', 10),
            ('GY-IFRS-SME-SFP', 'E-RESULT', 10),
            ('GY-IFRS-SME-SFP', 'E-RESULT', 20),
            ('GY-IFRS-SME-SFP', 'E-RESULT', 30),
            ('GY-IFRS-SME-SFP', 'E-RESULT', 40),
            ('GY-IFRS-SME-SFP', 'L-NC', 10),
            ('GY-IFRS-SME-SFP', 'L-C-PAY', 10),
            ('GY-IFRS-SME-SFP', 'L-C-TAX', 10),
            ('GY-IFRS-SME-SFP', 'L-C-TAX', 20),
            ('GY-IFRS-SME-SFP', 'L-C-OTH', 10),
            ('GY-IFRS-SME-SFP', 'L-C-OTH', 20)
   );

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('GY-IFRS-SME-IS', 'REV', 10, 'code_range', '4000', '4699', null, 'any'),
    ('GY-IFRS-SME-IS', 'COST', 10, 'code_range', '5000', '5099', null, 'any'),
    ('GY-IFRS-SME-IS', 'OTH-INC', 10, 'code_range', '4700', '4799', null, 'any'),
    ('GY-IFRS-SME-IS', 'OPEX', 10, 'code_range', '6000', '6799', null, 'any'),
    ('GY-IFRS-SME-IS', 'DEPR', 10, 'code_range', '6800', '6899', null, 'any'),
    ('GY-IFRS-SME-SFP', 'A-NC-FIX', 10, 'code_range', '1600', '1799', null, 'any'),
    ('GY-IFRS-SME-SFP', 'A-NC-INT', 10, 'code_range', '1800', '1899', null, 'any'),
    ('GY-IFRS-SME-SFP', 'A-NC-OTH', 10, 'code_range', '1900', '1999', null, 'any'),
    ('GY-IFRS-SME-SFP', 'A-C-REC', 10, 'code_range', '1100', '1199', null, 'any'),
    ('GY-IFRS-SME-SFP', 'A-C-INV', 10, 'code_range', '1200', '1299', null, 'any'),
    ('GY-IFRS-SME-SFP', 'A-C-OTH', 10, 'code_range', '1300', '1399', null, 'any'),
    ('GY-IFRS-SME-SFP', 'A-C-PRE', 10, 'code_range', '1400', '1499', null, 'any'),
    ('GY-IFRS-SME-SFP', 'A-C-CASH', 10, 'code_range', '1000', '1099', null, 'any'),
    ('GY-IFRS-SME-SFP', 'E-CAP', 10, 'code_range', '3000', '3199', null, 'any'),
    ('GY-IFRS-SME-SFP', 'E-RET', 10, 'code_range', '3200', '3299', null, 'any'),
    ('GY-IFRS-SME-SFP', 'E-RESULT', 10, 'code_range', '4000', '4699', null, 'any'),
    ('GY-IFRS-SME-SFP', 'E-RESULT', 20, 'code_range', '4700', '4799', null, 'any'),
    ('GY-IFRS-SME-SFP', 'E-RESULT', 30, 'code_range', '5000', '5099', null, 'any'),
    ('GY-IFRS-SME-SFP', 'E-RESULT', 40, 'code_range', '6000', '6899', null, 'any'),
    ('GY-IFRS-SME-SFP', 'L-NC', 10, 'code_range', '2300', '2399', null, 'any'),
    ('GY-IFRS-SME-SFP', 'L-C-PAY', 10, 'code_range', '2000', '2059', null, 'any'),
    ('GY-IFRS-SME-SFP', 'L-C-TAX', 10, 'code_range', '2060', '2069', null, 'any'),
    ('GY-IFRS-SME-SFP', 'L-C-TAX', 20, 'code_range', '2100', '2199', null, 'any'),
    ('GY-IFRS-SME-SFP', 'L-C-OTH', 10, 'code_range', '2070', '2099', null, 'any'),
    ('GY-IFRS-SME-SFP', 'L-C-OTH', 20, 'code_range', '2200', '2299', null, 'any')
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
  ('GY', 'Guyana', '{}'::jsonb, array['en']::text[], 'GYD', '1100', '2000', '2090', '6490', '3200', '4000', '5010', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6450', '4750', '6460', null, null, '2100', '1172', null, 'month'::declaration_period)
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
  numbering_legal_reference     = 'Value-Added Tax Act 2005, s. 28 — a registered supplier gives the recipient an original tax invoice with the particulars of Schedule III, paragraph 1 (a sales invoice may replace it for a cash sale below the amount of Schedule IV, paragraph 3, ten thousand dollars), and s. 29 treats tax credit and debit notes. The Act, as read for this pack, does not say that the series of invoice numbers may have no gap, which is why `numbering` is `sequential` and not `gapless`; `number_format` is a convention this pack proposes',
  numbering_source_key          = 'gy-vat-act',
  payment_terms_legal_reference = 'No Guyanese text read for this pack sets a payment term between two businesses or a rate of interest on a commercial debt paid late: the interest of two per cent a month on unpaid tax (s. 27, Schedule IV) is a charge on the taxable person towards the Commissioner, not a term between two businesses. `legal_payment_days` and `late_payment_reference` are empty',
  payment_terms_source_key      = 'gy-vat-act',
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Value-Added Tax Act 2005, s. 14(1) — a supply occurs on the earliest of the date the goods are delivered or made available or the services completed, the date the supplier issues an invoice, and the date any consideration is received. The closed vocabulary of this field has no value for three triggers at once: `earliest_of_delivery_or_payment` is the nearest and is what the rule reduces to when no invoice comes first. The special cases of s. 14(2) to (6) (credit agreement, lay-away, change of use, repossession, forfeited deposits) are not modelled',
  tax_point_source_key          = 'gy-vat-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No Guyanese text read for this pack obliges a business to issue or accept an electronic invoice: the Value-Added Tax Act 2005, s. 28 asks for a tax invoice without naming a platform, a format or a Peppol profile. The Authority''s Optimal service takes the return online, which is a filing channel and not an invoice format. No Peppol authority for Guyana was looked for. `profile`, `party_scheme` and `vat_scheme` are null: there is no domestic profile to name',
  einvoice_source_key           = 'gy-vat-act',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'GY';
