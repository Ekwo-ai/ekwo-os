-- Ekwo OS — Kuwait: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/kw at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build kw`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Commercial Law, Decree-Law No. 68 of 1980 (Arabic text, articles 31 and 32 on keeping the books and correspondence) (Laws of Kuwait (lawskw.com), reproducing the Official Gazette text)
--     https://lawskw.com/section/%D9%82%D8%A7%D9%86%D9%88%D9%86-%D8%A7%D9%84%D8%AA%D8%AC%D8%A7%D8%B1%D8%A9
--   IFRS Standards — Application Around the World, Jurisdictional Profile: Kuwait (last updated 16 June 2016; cites Ministerial Decree No. 18 of 1990 as amended by No. 101 of 2008) (IFRS Foundation)
--     https://www.ifrs.org/content/dam/ifrs/publications/jurisdictions/pdf-profiles/kuwait-ifrs-profile.pdf
--   Domestic Minimum Top-up Tax — Executive Regulations (Decree-Law No. 157 of 2024; Ministerial Decision No. 55 of 2025) (KPMG Kuwait (secondary source: the Ministry of Finance site could not be opened))
--     https://kpmg.com/kw/en/insights/2025/06/domestic-minimum-top-up-tax-executive-by-laws.html
--   Kuwait keeps VAT off the table: no adoption in the 2026-2030 fiscal plan (VATupdate (secondary source: no official statement could be opened))
--     https://www.vatupdate.com/2026/07/24/kuwait-keeps-vat-off-the-table-no-adoption-in-the-2026-2030-fiscal-plan/
--   Tax Services System (TCRS) — Ministry of Finance, Tax Department (Ministry of Finance of Kuwait)
--     https://www.mof.gov.kw
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('KW', 'Kuwait', '0.1.0', date '2026-10-10', '20260917170000', 'community', null, null, '8d0d5a3cbb5c3235e28da356197eb25c2c2f4fa6674efc5befcab171f8112434', '[{"key":"commercial-law-68-1980","title":"Commercial Law, Decree-Law No. 68 of 1980 (Arabic text, articles 31 and 32 on keeping the books and correspondence)","publisher":"Laws of Kuwait (lawskw.com), reproducing the Official Gazette text","url":"https://lawskw.com/section/%D9%82%D8%A7%D9%86%D9%88%D9%86-%D8%A7%D9%84%D8%AA%D8%AC%D8%A7%D8%B1%D8%A9","consulted_on":"2026-10-10","kind":"law"},{"key":"ifrs-kuwait-profile","title":"IFRS Standards — Application Around the World, Jurisdictional Profile: Kuwait (last updated 16 June 2016; cites Ministerial Decree No. 18 of 1990 as amended by No. 101 of 2008)","publisher":"IFRS Foundation","url":"https://www.ifrs.org/content/dam/ifrs/publications/jurisdictions/pdf-profiles/kuwait-ifrs-profile.pdf","consulted_on":"2026-10-10","kind":"guidance"},{"key":"dmtt-executive-regulations","title":"Domestic Minimum Top-up Tax — Executive Regulations (Decree-Law No. 157 of 2024; Ministerial Decision No. 55 of 2025)","publisher":"KPMG Kuwait (secondary source: the Ministry of Finance site could not be opened)","url":"https://kpmg.com/kw/en/insights/2025/06/domestic-minimum-top-up-tax-executive-by-laws.html","consulted_on":"2026-10-10","kind":"guidance"},{"key":"fiscal-plan-no-vat","title":"Kuwait keeps VAT off the table: no adoption in the 2026-2030 fiscal plan","publisher":"VATupdate (secondary source: no official statement could be opened)","url":"https://www.vatupdate.com/2026/07/24/kuwait-keeps-vat-off-the-table-no-adoption-in-the-2026-2030-fiscal-plan/","consulted_on":"2026-10-10","kind":"guidance"},{"key":"mof-tax-services","title":"Tax Services System (TCRS) — Ministry of Finance, Tax Department","publisher":"Ministry of Finance of Kuwait","url":"https://www.mof.gov.kw","consulted_on":"2026-10-10","kind":"portal"}]'::jsonb)
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
  ('KW', 'default', 'Kuwait reference chart of accounts', '{"en":"Kuwait reference chart of accounts"}'::jsonb, true, 'companies', array['KW-IFRS-IS', 'KW-IFRS-SFP']::text[], null, 'Kuwait prescribes no chart of accounts, as far as this pack''s research could establish. What is prescribed is the reporting framework: the IFRS Foundation''s Jurisdictional Profile for Kuwait records Ministerial Decree No. 18 of 1990, amended by No. 101 of 2008, and states that the Standards are required of every company under the Commercial Companies Law and of other institutions, not only listed ones, and that Kuwait has not adopted the IFRS for SMEs Standard — so this chart ties into full IFRS statements. The chart is this pack''s own construction: four digits, blocked so that each range reaches one line of the statement of financial position and the income statement. It carries accounts for the direct charges a Kuwaiti company bears (income tax, zakat, the National Labour Support Tax, the KFAS contribution, the 5% contract retention, the end-of-service indemnity) and no tax-clearing account, because there is no turnover tax to clear — see ''From Kuwait'' in docs/international.md.', 'ifrs-kuwait-profile')
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
  ('KW', 'default', '1000', 'Cash on hand', '{"en":"Cash on hand"}'::jsonb, 'asset_cash', false, null, 10),
  ('KW', 'default', '1010', 'Bank current account', '{"en":"Bank current account"}'::jsonb, 'asset_cash', false, null, 20),
  ('KW', 'default', '1020', 'Bank savings account', '{"en":"Bank savings account"}'::jsonb, 'asset_cash', false, null, 30),
  ('KW', 'default', '1030', 'Foreign currency bank account', '{"en":"Foreign currency bank account"}'::jsonb, 'asset_cash', false, null, 40),
  ('KW', 'default', '1040', 'Payment gateway and card clearing account', '{"en":"Payment gateway and card clearing account"}'::jsonb, 'asset_cash', false, null, 50),
  ('KW', 'default', '1050', 'Fixed deposits of three months or less', '{"en":"Fixed deposits of three months or less"}'::jsonb, 'asset_cash', false, null, 60),
  ('KW', 'default', '1060', 'Cash in transit', '{"en":"Cash in transit"}'::jsonb, 'asset_cash', false, null, 70),
  ('KW', 'default', '1100', 'Trade debtors', '{"en":"Trade debtors"}'::jsonb, 'asset_receivable', true, null, 80),
  ('KW', 'default', '1105', 'Allowance for expected credit losses', '{"en":"Allowance for expected credit losses"}'::jsonb, 'asset_current', false, null, 90),
  ('KW', 'default', '1110', 'Amounts due from related companies', '{"en":"Amounts due from related companies"}'::jsonb, 'asset_current', false, null, 100),
  ('KW', 'default', '1120', 'Other debtors', '{"en":"Other debtors"}'::jsonb, 'asset_current', false, null, 110),
  ('KW', 'default', '1130', 'Accrued income', '{"en":"Accrued income"}'::jsonb, 'asset_current', false, null, 120),
  ('KW', 'default', '1140', 'Staff advances and loans to employees', '{"en":"Staff advances and loans to employees"}'::jsonb, 'asset_current', false, null, 130),
  ('KW', 'default', '1150', 'Income tax prepaid', '{"en":"Income tax prepaid"}'::jsonb, 'asset_current', false, null, 140),
  ('KW', 'default', '1160', 'Income tax recoverable', '{"en":"Income tax recoverable"}'::jsonb, 'asset_current', false, null, 150),
  ('KW', 'default', '1200', 'Inventory — raw materials and consumables', '{"en":"Inventory — raw materials and consumables"}'::jsonb, 'asset_current', false, null, 160),
  ('KW', 'default', '1210', 'Inventory — work in progress', '{"en":"Inventory — work in progress"}'::jsonb, 'asset_current', false, null, 170),
  ('KW', 'default', '1220', 'Inventory — finished goods and goods for resale', '{"en":"Inventory — finished goods and goods for resale"}'::jsonb, 'asset_current', false, null, 180),
  ('KW', 'default', '1230', 'Goods in transit', '{"en":"Goods in transit"}'::jsonb, 'asset_current', false, null, 190),
  ('KW', 'default', '1300', 'Fixed deposits of more than three months', '{"en":"Fixed deposits of more than three months"}'::jsonb, 'asset_current', false, null, 200),
  ('KW', 'default', '1310', 'Listed investments held for trading', '{"en":"Listed investments held for trading"}'::jsonb, 'asset_current', false, null, 210),
  ('KW', 'default', '1320', 'Amounts due from related companies — non-trade', '{"en":"Amounts due from related companies — non-trade"}'::jsonb, 'asset_current', false, null, 220),
  ('KW', 'default', '1400', 'Prepaid expenses', '{"en":"Prepaid expenses"}'::jsonb, 'asset_prepayments', false, null, 230),
  ('KW', 'default', '1410', 'Rental and utility deposits paid', '{"en":"Rental and utility deposits paid"}'::jsonb, 'asset_prepayments', false, null, 240),
  ('KW', 'default', '1420', 'Deposits paid to suppliers', '{"en":"Deposits paid to suppliers"}'::jsonb, 'asset_prepayments', false, null, 250),
  ('KW', 'default', '1600', 'Land and buildings', '{"en":"Land and buildings"}'::jsonb, 'asset_fixed', false, null, 260),
  ('KW', 'default', '1610', 'Leasehold improvements', '{"en":"Leasehold improvements"}'::jsonb, 'asset_fixed', false, null, 270),
  ('KW', 'default', '1620', 'Furniture and fixtures', '{"en":"Furniture and fixtures"}'::jsonb, 'asset_fixed', false, null, 280),
  ('KW', 'default', '1630', 'Office equipment', '{"en":"Office equipment"}'::jsonb, 'asset_fixed', false, null, 290),
  ('KW', 'default', '1640', 'Computer equipment and software', '{"en":"Computer equipment and software"}'::jsonb, 'asset_fixed', false, null, 300),
  ('KW', 'default', '1650', 'Motor vehicles', '{"en":"Motor vehicles"}'::jsonb, 'asset_fixed', false, null, 310),
  ('KW', 'default', '1660', 'Plant and machinery', '{"en":"Plant and machinery"}'::jsonb, 'asset_fixed', false, null, 320),
  ('KW', 'default', '1670', 'Right-of-use assets', '{"en":"Right-of-use assets"}'::jsonb, 'asset_fixed', false, null, 330),
  ('KW', 'default', '1690', 'Accumulated depreciation — property plant and equipment', '{"en":"Accumulated depreciation — property plant and equipment"}'::jsonb, 'asset_fixed', false, null, 340),
  ('KW', 'default', '1695', 'Accumulated depreciation — right-of-use assets', '{"en":"Accumulated depreciation — right-of-use assets"}'::jsonb, 'asset_fixed', false, null, 350),
  ('KW', 'default', '1800', 'Goodwill', '{"en":"Goodwill"}'::jsonb, 'asset_non_current', false, null, 360),
  ('KW', 'default', '1810', 'Other intangible assets', '{"en":"Other intangible assets"}'::jsonb, 'asset_non_current', false, null, 370),
  ('KW', 'default', '1820', 'Accumulated amortisation — intangible assets', '{"en":"Accumulated amortisation — intangible assets"}'::jsonb, 'asset_non_current', false, null, 380),
  ('KW', 'default', '1900', 'Investments in subsidiaries', '{"en":"Investments in subsidiaries"}'::jsonb, 'asset_non_current', false, null, 390),
  ('KW', 'default', '1910', 'Investments in associates', '{"en":"Investments in associates"}'::jsonb, 'asset_non_current', false, null, 400),
  ('KW', 'default', '1920', 'Other long-term investments', '{"en":"Other long-term investments"}'::jsonb, 'asset_non_current', false, null, 410),
  ('KW', 'default', '1930', 'Rental and utility deposits — non-current', '{"en":"Rental and utility deposits — non-current"}'::jsonb, 'asset_non_current', false, null, 420),
  ('KW', 'default', '1990', 'Deferred tax assets', '{"en":"Deferred tax assets"}'::jsonb, 'asset_non_current', false, null, 430),
  ('KW', 'default', '2000', 'Trade creditors', '{"en":"Trade creditors"}'::jsonb, 'liability_payable', true, null, 440),
  ('KW', 'default', '2010', 'Amounts due to related companies', '{"en":"Amounts due to related companies"}'::jsonb, 'liability_current', false, null, 450),
  ('KW', 'default', '2020', 'Accruals', '{"en":"Accruals"}'::jsonb, 'liability_current', false, null, 460),
  ('KW', 'default', '2030', 'Customer deposits and advances received', '{"en":"Customer deposits and advances received"}'::jsonb, 'liability_current', false, null, 470),
  ('KW', 'default', '2040', 'Salaries and wages payable', '{"en":"Salaries and wages payable"}'::jsonb, 'liability_current', false, null, 480),
  ('KW', 'default', '2050', 'Social security contributions payable', '{"en":"Social security contributions payable"}'::jsonb, 'liability_current', false, null, 490),
  ('KW', 'default', '2060', 'Provision for income tax', '{"en":"Provision for income tax"}'::jsonb, 'liability_current', false, null, 500),
  ('KW', 'default', '2061', 'Zakat payable', '{"en":"Zakat payable"}'::jsonb, 'liability_current', false, null, 510),
  ('KW', 'default', '2062', 'National Labour Support Tax payable', '{"en":"National Labour Support Tax payable"}'::jsonb, 'liability_current', false, null, 520),
  ('KW', 'default', '2063', 'KFAS contribution payable', '{"en":"KFAS contribution payable"}'::jsonb, 'liability_current', false, null, 530),
  ('KW', 'default', '2064', 'Contract retention withheld pending tax clearance', '{"en":"Contract retention withheld pending tax clearance"}'::jsonb, 'liability_current', false, null, 540),
  ('KW', 'default', '2070', 'Other taxes and government charges payable', '{"en":"Other taxes and government charges payable"}'::jsonb, 'liability_current', false, null, 550),
  ('KW', 'default', '2080', 'Lease liabilities — current portion', '{"en":"Lease liabilities — current portion"}'::jsonb, 'liability_current', false, null, 560),
  ('KW', 'default', '2090', 'Suspense account', '{"en":"Suspense account"}'::jsonb, 'liability_current', false, null, 570),
  ('KW', 'default', '2200', 'Corporate credit card payable', '{"en":"Corporate credit card payable"}'::jsonb, 'liability_credit_card', false, null, 580),
  ('KW', 'default', '2300', 'Bank borrowings — non-current', '{"en":"Bank borrowings — non-current"}'::jsonb, 'liability_non_current', false, null, 590),
  ('KW', 'default', '2310', 'Lease liabilities — non-current', '{"en":"Lease liabilities — non-current"}'::jsonb, 'liability_non_current', false, null, 600),
  ('KW', 'default', '2320', 'Amounts due to shareholders — non-current', '{"en":"Amounts due to shareholders — non-current"}'::jsonb, 'liability_non_current', false, null, 610),
  ('KW', 'default', '2330', 'End-of-service indemnity provision', '{"en":"End-of-service indemnity provision"}'::jsonb, 'liability_non_current', false, null, 620),
  ('KW', 'default', '2390', 'Deferred tax liabilities', '{"en":"Deferred tax liabilities"}'::jsonb, 'liability_non_current', false, null, 630),
  ('KW', 'default', '3000', 'Issued and paid-up share capital', '{"en":"Issued and paid-up share capital"}'::jsonb, 'equity', false, null, 640),
  ('KW', 'default', '3100', 'Share premium', '{"en":"Share premium"}'::jsonb, 'equity', false, null, 650),
  ('KW', 'default', '3110', 'Capital reserve', '{"en":"Capital reserve"}'::jsonb, 'equity', false, null, 660),
  ('KW', 'default', '3200', 'Retained profits', '{"en":"Retained profits"}'::jsonb, 'equity_retained', false, null, 670),
  ('KW', 'default', '4000', 'Sale of goods', '{"en":"Sale of goods"}'::jsonb, 'income', false, null, 680),
  ('KW', 'default', '4010', 'Rendering of services', '{"en":"Rendering of services"}'::jsonb, 'income', false, null, 690),
  ('KW', 'default', '4700', 'Realised exchange gains', '{"en":"Realised exchange gains"}'::jsonb, 'income_other', false, null, 700),
  ('KW', 'default', '4710', 'Unrealised exchange gains', '{"en":"Unrealised exchange gains"}'::jsonb, 'income_other', false, null, 710),
  ('KW', 'default', '4720', 'Interest income', '{"en":"Interest income"}'::jsonb, 'income_other', false, null, 720),
  ('KW', 'default', '4730', 'Sundry income', '{"en":"Sundry income"}'::jsonb, 'income_other', false, null, 730),
  ('KW', 'default', '4750', 'Gain on disposal of fixed assets', '{"en":"Gain on disposal of fixed assets"}'::jsonb, 'income_other', false, null, 740),
  ('KW', 'default', '5000', 'Cost of goods sold', '{"en":"Cost of goods sold"}'::jsonb, 'expense_direct_cost', false, null, 750),
  ('KW', 'default', '5010', 'Purchases', '{"en":"Purchases"}'::jsonb, 'expense_direct_cost', false, null, 760),
  ('KW', 'default', '5020', 'Freight inwards', '{"en":"Freight inwards"}'::jsonb, 'expense_direct_cost', false, null, 770),
  ('KW', 'default', '5030', 'Direct labour', '{"en":"Direct labour"}'::jsonb, 'expense_direct_cost', false, null, 780),
  ('KW', 'default', '6000', 'Directors'' remuneration', '{"en":"Directors'' remuneration"}'::jsonb, 'expense', false, null, 790),
  ('KW', 'default', '6010', 'Staff salaries and wages', '{"en":"Staff salaries and wages"}'::jsonb, 'expense', false, null, 800),
  ('KW', 'default', '6020', 'Social security contributions', '{"en":"Social security contributions"}'::jsonb, 'expense', false, null, 810),
  ('KW', 'default', '6024', 'End-of-service indemnity charge', '{"en":"End-of-service indemnity charge"}'::jsonb, 'expense', false, null, 820),
  ('KW', 'default', '6030', 'Staff welfare and benefits', '{"en":"Staff welfare and benefits"}'::jsonb, 'expense', false, null, 830),
  ('KW', 'default', '6100', 'Rent and rates', '{"en":"Rent and rates"}'::jsonb, 'expense', false, null, 840),
  ('KW', 'default', '6110', 'Management fees and building outgoings', '{"en":"Management fees and building outgoings"}'::jsonb, 'expense', false, null, 850),
  ('KW', 'default', '6120', 'Utilities', '{"en":"Utilities"}'::jsonb, 'expense', false, null, 860),
  ('KW', 'default', '6200', 'Commercial licence and registration fees', '{"en":"Commercial licence and registration fees"}'::jsonb, 'expense', false, null, 870),
  ('KW', 'default', '6210', 'Auditor''s remuneration', '{"en":"Auditor''s remuneration"}'::jsonb, 'expense', false, null, 880),
  ('KW', 'default', '6220', 'Accounting and company secretarial fees', '{"en":"Accounting and company secretarial fees"}'::jsonb, 'expense', false, null, 890),
  ('KW', 'default', '6230', 'Legal and professional fees', '{"en":"Legal and professional fees"}'::jsonb, 'expense', false, null, 900),
  ('KW', 'default', '6300', 'Repairs and maintenance', '{"en":"Repairs and maintenance"}'::jsonb, 'expense', false, null, 910),
  ('KW', 'default', '6310', 'Insurance', '{"en":"Insurance"}'::jsonb, 'expense', false, null, 920),
  ('KW', 'default', '6320', 'Motor vehicle expenses', '{"en":"Motor vehicle expenses"}'::jsonb, 'expense', false, null, 930),
  ('KW', 'default', '6330', 'Travelling expenses', '{"en":"Travelling expenses"}'::jsonb, 'expense', false, null, 940),
  ('KW', 'default', '6340', 'Entertainment expenses', '{"en":"Entertainment expenses"}'::jsonb, 'expense', false, null, 950),
  ('KW', 'default', '6350', 'Advertising and promotion', '{"en":"Advertising and promotion"}'::jsonb, 'expense', false, null, 960),
  ('KW', 'default', '6360', 'Printing, stationery and postage', '{"en":"Printing, stationery and postage"}'::jsonb, 'expense', false, null, 970),
  ('KW', 'default', '6370', 'Telecommunications', '{"en":"Telecommunications"}'::jsonb, 'expense', false, null, 980),
  ('KW', 'default', '6380', 'Bank charges', '{"en":"Bank charges"}'::jsonb, 'expense', false, null, 990),
  ('KW', 'default', '6390', 'Sundry office expenses', '{"en":"Sundry office expenses"}'::jsonb, 'expense', false, null, 1000),
  ('KW', 'default', '6400', 'Allowance for expected credit losses charged', '{"en":"Allowance for expected credit losses charged"}'::jsonb, 'expense', false, null, 1010),
  ('KW', 'default', '6410', 'Interest expense on bank borrowings', '{"en":"Interest expense on bank borrowings"}'::jsonb, 'expense', false, null, 1020),
  ('KW', 'default', '6420', 'Interest expense on lease liabilities', '{"en":"Interest expense on lease liabilities"}'::jsonb, 'expense', false, null, 1030),
  ('KW', 'default', '6450', 'Realised exchange losses', '{"en":"Realised exchange losses"}'::jsonb, 'expense', false, null, 1040),
  ('KW', 'default', '6455', 'Unrealised exchange losses', '{"en":"Unrealised exchange losses"}'::jsonb, 'expense', false, null, 1050),
  ('KW', 'default', '6460', 'Loss on disposal of fixed assets', '{"en":"Loss on disposal of fixed assets"}'::jsonb, 'expense', false, null, 1060),
  ('KW', 'default', '6470', 'Income tax charge', '{"en":"Income tax charge"}'::jsonb, 'expense', false, null, 1070),
  ('KW', 'default', '6471', 'Zakat charge', '{"en":"Zakat charge"}'::jsonb, 'expense', false, null, 1080),
  ('KW', 'default', '6472', 'National Labour Support Tax charge', '{"en":"National Labour Support Tax charge"}'::jsonb, 'expense', false, null, 1090),
  ('KW', 'default', '6473', 'KFAS contribution charge', '{"en":"KFAS contribution charge"}'::jsonb, 'expense', false, null, 1100),
  ('KW', 'default', '6480', 'Deferred tax charge', '{"en":"Deferred tax charge"}'::jsonb, 'expense', false, null, 1110),
  ('KW', 'default', '6490', 'Rounding differences', '{"en":"Rounding differences"}'::jsonb, 'expense', false, null, 1120),
  ('KW', 'default', '6800', 'Depreciation and amortisation', '{"en":"Depreciation and amortisation"}'::jsonb, 'expense_depreciation', false, null, 1130)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('KW', 'BNK', 'Bank', '{"en":"Bank"}'::jsonb, 'bank', 30),
  ('KW', 'CSH', 'Petty cash', '{"en":"Petty cash"}'::jsonb, 'cash', 40),
  ('KW', 'GEN', 'General journal', '{"en":"General journal"}'::jsonb, 'general', 50),
  ('KW', 'OPN', 'Opening balances', '{"en":"Opening balances"}'::jsonb, 'opening', 60),
  ('KW', 'PUR', 'Purchases journal', '{"en":"Purchases journal"}'::jsonb, 'purchase', 20),
  ('KW', 'SAL', 'Sales journal', '{"en":"Sales journal"}'::jsonb, 'sales', 10)
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
  ('KW', 'KW-P-NA', 'Purchase, not subject to any tax on turnover', '{"en":"Purchase, not subject to any tax on turnover"}'::jsonb, 'Every purchase a Kuwaiti business books — domestic or imported', 'percent', 0, 'purchase', 'not_subject', date '2000-01-01', null, 'The purchase side of KW-S-NA: nothing a Kuwaiti business buys carries a tax to recover. Kuwait has enacted no value added tax, goods and services tax or general sales tax: the GCC framework agreement on VAT, signed by Kuwait, has never been transposed into a Kuwaiti law, no selective (excise) tax law has been promulgated either, and the 2026-2030 fiscal plan adopts neither (VATupdate, consulted 2026-10-10 — a secondary source; mof.gov.kw could not be opened). The 2025 reform is not a VAT: Decree-Law No. 157 of 2024 creates a domestic minimum top-up tax of 15% for large multinational groups, for fiscal years opened from 1 January 2025 (Executive Regulations: Ministerial Decision No. 55 of 2025), in place of income tax, zakat and the National Labour Support Tax for those groups (KPMG Kuwait). What else is levied — income tax of 15% on foreign corporate bodies (Decree No. 3 of 1955, as amended by Law No. 2 of 2008), a 5% retention on contract payments until a tax clearance is issued, zakat of 1% (Law No. 46 of 2006), the National Labour Support Tax of 2.5% (Law No. 19 of 2000), the 1% KFAS contribution, GCC customs duties — is a tax on profit, on a payment or on the border, not on an invoice line, and none is modelled (those laws were not opened; they are cited from the lead''s brief and the secondary sources above). See ''From Kuwait'' in docs/international.md. Customs duties on imports (GCC common customs tariff) are not modelled.', 'O', null, 20, 'other', true, '{}'::tax_condition[], null, false, false, null, 'fiscal-plan-no-vat', null, null, null, null),
  ('KW', 'KW-S-NA', 'Sale, not subject to any tax on turnover', '{"en":"Sale, not subject to any tax on turnover"}'::jsonb, 'Every sale a Kuwaiti business makes — domestic or exported', 'percent', 0, 'sale', 'not_subject', date '2000-01-01', null, 'The sale side: nothing a Kuwaiti business sells carries a tax to collect. Kuwait has enacted no value added tax, goods and services tax or general sales tax: the GCC framework agreement on VAT, signed by Kuwait, has never been transposed into a Kuwaiti law, no selective (excise) tax law has been promulgated either, and the 2026-2030 fiscal plan adopts neither (VATupdate, consulted 2026-10-10 — a secondary source; mof.gov.kw could not be opened). The 2025 reform is not a VAT: Decree-Law No. 157 of 2024 creates a domestic minimum top-up tax of 15% for large multinational groups, for fiscal years opened from 1 January 2025 (Executive Regulations: Ministerial Decision No. 55 of 2025), in place of income tax, zakat and the National Labour Support Tax for those groups (KPMG Kuwait). What else is levied — income tax of 15% on foreign corporate bodies (Decree No. 3 of 1955, as amended by Law No. 2 of 2008), a 5% retention on contract payments until a tax clearance is issued, zakat of 1% (Law No. 46 of 2006), the National Labour Support Tax of 2.5% (Law No. 19 of 2000), the 1% KFAS contribution, GCC customs duties — is a tax on profit, on a payment or on the border, not on an invoice line, and none is modelled (those laws were not opened; they are cited from the lead''s brief and the secondary sources above). See ''From Kuwait'' in docs/international.md.', 'O', null, 10, 'other', true, '{}'::tax_condition[], null, false, false, null, 'fiscal-plan-no-vat', null, null, null, null)
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
    ('KW-P-NA', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('KW-P-NA', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('KW-S-NA', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('KW-S-NA', 'credit_note', 'base', 100, null, null, null, 100, null, 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'KW' and t.code = v.tax_code
on conflict (tax_template_id, document_kind, posting_type, sequence) do update set
  factor_percent     = excluded.factor_percent,
  account_code       = excluded.account_code,
  declaration_box    = excluded.declaration_box,
  declaration_boxes  = excluded.declaration_boxes,
  box_factor_percent = excluded.box_factor_percent,
  report_code        = excluded.report_code;

insert into statement_templates
  (code, country, chart_code, name, kind, framework, valid_from, valid_to, legal_reference,
   source_key)
values
  ('KW-IFRS-IS', 'KW', 'default', 'Income statement — full IFRS Accounting Standards', 'income_statement', 'IFRS', date '1970-01-01', null, 'Full IFRS Accounting Standards are required of every company under the Commercial Companies Law, by Ministerial Decree No. 18 of 1990 as amended by No. 101 of 2008; the IFRS for SMEs Standard is not adopted (IFRS Foundation, Jurisdictional Profile: Kuwait). Lines follow IAS 1 (statement of financial position; profit or loss). The statement of other comprehensive income is not modelled: this chart carries no OCI account. The line numbering and the account ranges are this pack''s own.', 'ifrs-kuwait-profile'),
  ('KW-IFRS-SFP', 'KW', 'default', 'Statement of financial position — full IFRS Accounting Standards', 'balance_sheet', 'IFRS', date '1970-01-01', null, 'Full IFRS Accounting Standards are required of every company under the Commercial Companies Law, by Ministerial Decree No. 18 of 1990 as amended by No. 101 of 2008; the IFRS for SMEs Standard is not adopted (IFRS Foundation, Jurisdictional Profile: Kuwait). Lines follow IAS 1 (statement of financial position; profit or loss). The statement of other comprehensive income is not modelled: this chart carries no OCI account. The line numbering and the account ranges are this pack''s own.', 'ifrs-kuwait-profile')
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
  ('KW-IFRS-IS', 'REV', null, 'Revenue', '{"en":"Revenue"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KW-IFRS-IS', 'COST', null, 'Cost of sales', '{"en":"Cost of sales"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KW-IFRS-IS', 'GROSS', null, 'Gross profit', '{"en":"Gross profit"}'::jsonb, 30, 1, true, array['REV']::text[], array['COST']::text[], null, null, null),
  ('KW-IFRS-IS', 'OTH-INC', null, 'Other income', '{"en":"Other income"}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KW-IFRS-IS', 'OPEX', null, 'Administrative and other operating expenses', '{"en":"Administrative and other operating expenses"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KW-IFRS-IS', 'DEPR', null, 'Depreciation and amortisation', '{"en":"Depreciation and amortisation"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KW-IFRS-IS', 'PROFIT', null, 'Profit (loss) for the year', '{"en":"Profit (loss) for the year"}'::jsonb, 70, 1, true, array['GROSS', 'OTH-INC']::text[], array['OPEX', 'DEPR']::text[], null, null, null),
  ('KW-IFRS-SFP', 'A-NC-FIX', 'A-NC', 'Property, plant and equipment', '{"en":"Property, plant and equipment"}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KW-IFRS-SFP', 'A-NC-INT', 'A-NC', 'Goodwill and other intangible assets', '{"en":"Goodwill and other intangible assets"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KW-IFRS-SFP', 'A-NC-OTH', 'A-NC', 'Other non-current assets', '{"en":"Other non-current assets"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KW-IFRS-SFP', 'A-NC', null, 'Non-current assets', '{"en":"Non-current assets"}'::jsonb, 40, 1, true, array['A-NC-FIX', 'A-NC-INT', 'A-NC-OTH']::text[], '{}'::text[], null, null, null),
  ('KW-IFRS-SFP', 'A-C-REC', 'A-C', 'Trade and other receivables', '{"en":"Trade and other receivables"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KW-IFRS-SFP', 'A-C-INV', 'A-C', 'Inventories', '{"en":"Inventories"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KW-IFRS-SFP', 'A-C-OTH', 'A-C', 'Other current assets', '{"en":"Other current assets"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KW-IFRS-SFP', 'A-C-PRE', 'A-C', 'Prepayments and deposits paid', '{"en":"Prepayments and deposits paid"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KW-IFRS-SFP', 'A-C-CASH', 'A-C', 'Cash and cash equivalents', '{"en":"Cash and cash equivalents"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KW-IFRS-SFP', 'A-C', null, 'Current assets', '{"en":"Current assets"}'::jsonb, 100, 1, true, array['A-C-REC', 'A-C-INV', 'A-C-OTH', 'A-C-PRE', 'A-C-CASH']::text[], '{}'::text[], null, null, null),
  ('KW-IFRS-SFP', 'A-TOT', null, 'Total assets', '{"en":"Total assets"}'::jsonb, 110, 1, true, array['A-NC', 'A-C']::text[], '{}'::text[], null, null, null),
  ('KW-IFRS-SFP', 'E-CAP', 'E-TOT', 'Share capital and reserves', '{"en":"Share capital and reserves"}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KW-IFRS-SFP', 'E-RET', 'E-TOT', 'Retained profits', '{"en":"Retained profits"}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KW-IFRS-SFP', 'E-RESULT', 'E-TOT', 'Profit or loss for the year, not yet allocated', '{"en":"Profit or loss for the year, not yet allocated"}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KW-IFRS-SFP', 'E-TOT', null, 'Total equity', '{"en":"Total equity"}'::jsonb, 150, 1, true, array['E-CAP', 'E-RET', 'E-RESULT']::text[], '{}'::text[], null, null, null),
  ('KW-IFRS-SFP', 'L-NC', 'L-TOT', 'Non-current liabilities', '{"en":"Non-current liabilities"}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KW-IFRS-SFP', 'L-C-PAY', 'L-C', 'Trade and other payables', '{"en":"Trade and other payables"}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KW-IFRS-SFP', 'L-C-TAX', 'L-C', 'Current tax liabilities', '{"en":"Current tax liabilities"}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KW-IFRS-SFP', 'L-C-OTH', 'L-C', 'Other current liabilities', '{"en":"Other current liabilities"}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KW-IFRS-SFP', 'L-C', null, 'Current liabilities', '{"en":"Current liabilities"}'::jsonb, 200, 1, true, array['L-C-PAY', 'L-C-TAX', 'L-C-OTH']::text[], '{}'::text[], null, null, null),
  ('KW-IFRS-SFP', 'L-TOT', null, 'Total liabilities', '{"en":"Total liabilities"}'::jsonb, 210, 1, true, array['L-NC', 'L-C']::text[], '{}'::text[], null, null, null),
  ('KW-IFRS-SFP', 'EL-TOT', null, 'Total equity and liabilities', '{"en":"Total equity and liabilities"}'::jsonb, 220, 1, true, array['E-TOT', 'L-TOT']::text[], '{}'::text[], null, null, null)
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
    ('KW-IFRS-IS', 'REV', 10, 'code_range', '4000', '4699', null, 'any'),
    ('KW-IFRS-IS', 'COST', 10, 'code_range', '5000', '5099', null, 'any'),
    ('KW-IFRS-IS', 'OTH-INC', 10, 'code_range', '4700', '4799', null, 'any'),
    ('KW-IFRS-IS', 'OPEX', 10, 'code_range', '6000', '6799', null, 'any'),
    ('KW-IFRS-IS', 'DEPR', 10, 'code_range', '6800', '6899', null, 'any'),
    ('KW-IFRS-SFP', 'A-NC-FIX', 10, 'code_range', '1600', '1799', null, 'any'),
    ('KW-IFRS-SFP', 'A-NC-INT', 10, 'code_range', '1800', '1899', null, 'any'),
    ('KW-IFRS-SFP', 'A-NC-OTH', 10, 'code_range', '1900', '1999', null, 'any'),
    ('KW-IFRS-SFP', 'A-C-REC', 10, 'code_range', '1100', '1199', null, 'any'),
    ('KW-IFRS-SFP', 'A-C-INV', 10, 'code_range', '1200', '1299', null, 'any'),
    ('KW-IFRS-SFP', 'A-C-OTH', 10, 'code_range', '1300', '1399', null, 'any'),
    ('KW-IFRS-SFP', 'A-C-PRE', 10, 'code_range', '1400', '1499', null, 'any'),
    ('KW-IFRS-SFP', 'A-C-CASH', 10, 'code_range', '1000', '1099', null, 'any'),
    ('KW-IFRS-SFP', 'E-CAP', 10, 'code_range', '3000', '3199', null, 'any'),
    ('KW-IFRS-SFP', 'E-RET', 10, 'code_range', '3200', '3299', null, 'any'),
    ('KW-IFRS-SFP', 'E-RESULT', 10, 'code_range', '4000', '4699', null, 'any'),
    ('KW-IFRS-SFP', 'E-RESULT', 20, 'code_range', '4700', '4799', null, 'any'),
    ('KW-IFRS-SFP', 'E-RESULT', 30, 'code_range', '5000', '5099', null, 'any'),
    ('KW-IFRS-SFP', 'E-RESULT', 40, 'code_range', '6000', '6899', null, 'any'),
    ('KW-IFRS-SFP', 'L-NC', 10, 'code_range', '2300', '2399', null, 'any'),
    ('KW-IFRS-SFP', 'L-C-PAY', 10, 'code_range', '2000', '2059', null, 'any'),
    ('KW-IFRS-SFP', 'L-C-TAX', 10, 'code_range', '2060', '2069', null, 'any'),
    ('KW-IFRS-SFP', 'L-C-OTH', 10, 'code_range', '2070', '2099', null, 'any'),
    ('KW-IFRS-SFP', 'L-C-OTH', 20, 'code_range', '2200', '2299', null, 'any')
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
  ('KW', 'Kuwait', '{"en":"Kuwait"}'::jsonb, array['ar', 'en']::text[], 'KWD', '1100', '2000', '2090', '6490', '3200', '4000', '5010', '1010', '1000', 'SAL', 'PUR', 'GEN', 'ar', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6450', '4750', '6460', null, null, null, null, null, null)
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
  numbering_legal_reference     = 'Kuwait levies no value added tax, goods and services tax or general sales tax (the 2026-2030 fiscal plan adopts none), so no tax statute conditions anything on an invoice number. The Commercial Law (Decree-Law No. 68 of 1980), article 31, only requires a merchant to keep copies of the correspondence it sends and everything it receives, invoices included, and article 32 fixes how long: the original journal and inventory book ten years from their closing, the correspondence and documents five years. `numbering` is therefore `free`; `number_format` is a convention this pack proposes. Article 32 was read on lawskw.com, not on the Official Gazette.',
  numbering_source_key          = 'commercial-law-68-1980',
  payment_terms_legal_reference = 'No payment term between businesses and no rate of late-payment interest on a commercial debt was found in the sources this pack could open; both fields are empty and the terms are a matter of contract. A reviewer should confirm that the Civil Code''s general rule on default interest was not missed.',
  payment_terms_source_key      = 'commercial-law-68-1980',
  tax_point_rule                = 'invoice_date',
  tax_point_legal_reference     = 'This field has nothing to describe in Kuwait: it names the day a country''s general rule makes its own turnover tax chargeable, and Kuwait charges none. `invoice_date` is declared as the closest general commercial convention, not read from a text; see ''From Kuwait'' in docs/international.md.',
  tax_point_source_key          = 'commercial-law-68-1980',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No Kuwaiti text this pack could open obliges a business to issue or accept an electronic invoice, and no Peppol Authority is listed for Kuwait (OpenPeppol list of Peppol Authorities, not re-opened on 2026-10-10: this rests on the pack''s earlier research and should be re-checked). With no value added tax there is no tax invoice for a mandate to attach to. `profile`, `party_scheme` and `vat_scheme` are therefore null.',
  einvoice_source_key           = 'commercial-law-68-1980',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'KW';
