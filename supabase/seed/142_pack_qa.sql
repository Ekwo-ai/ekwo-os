-- Ekwo OS — Qatar: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/qa at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build qa`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Law No. (24) of 2018 Promulgating the Income Tax Law (General Tax Authority's English text) (General Tax Authority)
--     https://gta.gov.qa/assets/pdf/Law%20No.%20%2824%29%20of%202018%20Promulgating%20the%20Income%20Tax%20Law%20%283%29.pdf
--   Income Tax Law and its Executive Regulations, 2024 edition (General Tax Authority's English text) (General Tax Authority)
--     https://gta.gov.qa/assets/pdf/Income%20Tax%20Law%20EN%202024.pdf
--   Excise Tax Law (Law No. (25) of 2018) and its Executive Regulations, 2024 edition (General Tax Authority's English text) (General Tax Authority)
--     https://gta.gov.qa/assets/pdf/Excise%20Tax%20Law%20EN%202024.pdf
--   State of Qatar introduces new excise tax mechanism on sweetened drinks (Law No. (2) of 2026) (General Tax Authority)
--     https://www.gta.gov.qa/en/media-center/news/state-of-qatar-introduces-new-excise-tax-mechanism-on-sweetened-drinks
--   Council of Ministers Resolution No. (2) of 2026 on the Global Minimum Tax (Pillar Two) Regulations (General Tax Authority's English text) (General Tax Authority)
--     https://gta.gov.qa/assets/pdf/EN%20Qatar%20Pillar%20Two%20Regulations%20Decision%20No%202%20of%202026.pdf
--   Laws and regulations — tax laws in force (General Tax Authority)
--     https://gta.gov.qa/en/laws
--   Law No. (11) of 2015 Promulgating the Commercial Companies Law (unofficial English translation; the official text is on almeezan.qa, which this pack's research could not open) (Qatar legislation (unofficial translation published by a law firm))
--     https://www.jbapartner.com/images/download/Law-No--11-of-2015---Promulgating-the-Commercial-Companies-Law---English.pdf
--   Customs — duty tariffs and trade regulations (Invest Qatar)
--     https://www.invest.qa/en/resources/laws-and-regulations/customs
--   Qatar approves draft e-invoicing law and implementing regulations (Council of Ministers, 6 May 2026) (EY Tax Alerts)
--     https://www.ey.com/en_gl/technical/tax-alerts/qatar-approves-draft-e-invoicing-law-and-implementing-regulations
--   Dhareeba — the General Tax Authority's electronic tax portal (General Tax Authority)
--     https://dhareeba.gov.qa
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('QA', 'Qatar', '0.1.0', date '2026-10-10', '20260917170000', 'community', null, null, 'b05ad4c9934400cc215853e2acd8114086e4f9699e8976aaf7c36d0936cc3256', '[{"key":"income-tax-law","title":"Law No. (24) of 2018 Promulgating the Income Tax Law (General Tax Authority''s English text)","publisher":"General Tax Authority","url":"https://gta.gov.qa/assets/pdf/Law%20No.%20%2824%29%20of%202018%20Promulgating%20the%20Income%20Tax%20Law%20%283%29.pdf","consulted_on":"2026-10-10","kind":"law"},{"key":"income-tax-regs","title":"Income Tax Law and its Executive Regulations, 2024 edition (General Tax Authority''s English text)","publisher":"General Tax Authority","url":"https://gta.gov.qa/assets/pdf/Income%20Tax%20Law%20EN%202024.pdf","consulted_on":"2026-10-10","kind":"regulation"},{"key":"excise-law","title":"Excise Tax Law (Law No. (25) of 2018) and its Executive Regulations, 2024 edition (General Tax Authority''s English text)","publisher":"General Tax Authority","url":"https://gta.gov.qa/assets/pdf/Excise%20Tax%20Law%20EN%202024.pdf","consulted_on":"2026-10-10","kind":"law"},{"key":"excise-sweetened-drinks","title":"State of Qatar introduces new excise tax mechanism on sweetened drinks (Law No. (2) of 2026)","publisher":"General Tax Authority","url":"https://www.gta.gov.qa/en/media-center/news/state-of-qatar-introduces-new-excise-tax-mechanism-on-sweetened-drinks","consulted_on":"2026-10-10","kind":"guidance"},{"key":"pillar-two","title":"Council of Ministers Resolution No. (2) of 2026 on the Global Minimum Tax (Pillar Two) Regulations (General Tax Authority''s English text)","publisher":"General Tax Authority","url":"https://gta.gov.qa/assets/pdf/EN%20Qatar%20Pillar%20Two%20Regulations%20Decision%20No%202%20of%202026.pdf","consulted_on":"2026-10-10","kind":"regulation"},{"key":"gta-laws","title":"Laws and regulations — tax laws in force","publisher":"General Tax Authority","url":"https://gta.gov.qa/en/laws","consulted_on":"2026-10-10","kind":"guidance"},{"key":"companies-law","title":"Law No. (11) of 2015 Promulgating the Commercial Companies Law (unofficial English translation; the official text is on almeezan.qa, which this pack''s research could not open)","publisher":"Qatar legislation (unofficial translation published by a law firm)","url":"https://www.jbapartner.com/images/download/Law-No--11-of-2015---Promulgating-the-Commercial-Companies-Law---English.pdf","consulted_on":"2026-10-10","kind":"law"},{"key":"customs-guide","title":"Customs — duty tariffs and trade regulations","publisher":"Invest Qatar","url":"https://www.invest.qa/en/resources/laws-and-regulations/customs","consulted_on":"2026-10-10","kind":"guidance"},{"key":"einvoicing-draft","title":"Qatar approves draft e-invoicing law and implementing regulations (Council of Ministers, 6 May 2026)","publisher":"EY Tax Alerts","url":"https://www.ey.com/en_gl/technical/tax-alerts/qatar-approves-draft-e-invoicing-law-and-implementing-regulations","consulted_on":"2026-10-10","kind":"guidance"},{"key":"dhareeba","title":"Dhareeba — the General Tax Authority''s electronic tax portal","publisher":"General Tax Authority","url":"https://dhareeba.gov.qa","consulted_on":"2026-10-10","kind":"portal"}]'::jsonb)
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
  ('QA', 'default', 'Qatar reference chart of accounts', '{"en":"Qatar reference chart of accounts"}'::jsonb, true, 'companies', array['QA-IFRS-IS', 'QA-IFRS-SFP']::text[], null, 'Qatar prescribes no chart of accounts that this pack''s research found. The Income Tax Law (Law No. 24 of 2018), article 12, requires a taxpayer carrying on an activity in the State to keep accounting books, records and documents in accordance with the laws of the State and international accounting standards, and article 35 of its Executive Regulations names the general journal, the general ledger and the inventory book; article 6 of the Law requires taxable income to be determined on the accrual basis applied in commercial accounting, in accordance with international accounting standards. Neither text numbers accounts. This chart is therefore original: four digits, blocked so that each range reaches one line item of the statement of financial position and the statement of profit or loss of IFRS Accounting Standards (IAS 1). It carries an income tax provision, a withholding tax payable on payments to non-residents and an end-of-service gratuity payable, and no tax-clearing account for a turnover tax, because Qatar has none in force — see ''From Qatar'' in docs/international.md. The Arabic names a Qatari accountant would use are not supplied: see i18n/README.md.', 'income-tax-law')
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
  ('QA', 'default', '1000', 'Cash on hand', '{"en":"Cash on hand"}'::jsonb, 'asset_cash', false, null, 10),
  ('QA', 'default', '1010', 'Bank current account', '{"en":"Bank current account"}'::jsonb, 'asset_cash', false, null, 20),
  ('QA', 'default', '1020', 'Bank savings account', '{"en":"Bank savings account"}'::jsonb, 'asset_cash', false, null, 30),
  ('QA', 'default', '1030', 'Foreign currency bank account', '{"en":"Foreign currency bank account"}'::jsonb, 'asset_cash', false, null, 40),
  ('QA', 'default', '1040', 'Payment gateway and card clearing account', '{"en":"Payment gateway and card clearing account"}'::jsonb, 'asset_cash', false, null, 50),
  ('QA', 'default', '1050', 'Fixed deposits of three months or less', '{"en":"Fixed deposits of three months or less"}'::jsonb, 'asset_cash', false, null, 60),
  ('QA', 'default', '1060', 'Cash in transit', '{"en":"Cash in transit"}'::jsonb, 'asset_cash', false, null, 70),
  ('QA', 'default', '1100', 'Trade receivables', '{"en":"Trade receivables"}'::jsonb, 'asset_receivable', true, null, 80),
  ('QA', 'default', '1105', 'Allowance for expected credit losses', '{"en":"Allowance for expected credit losses"}'::jsonb, 'asset_current', false, null, 90),
  ('QA', 'default', '1110', 'Amounts due from related parties', '{"en":"Amounts due from related parties"}'::jsonb, 'asset_current', false, null, 100),
  ('QA', 'default', '1120', 'Other receivables', '{"en":"Other receivables"}'::jsonb, 'asset_current', false, null, 110),
  ('QA', 'default', '1130', 'Accrued income', '{"en":"Accrued income"}'::jsonb, 'asset_current', false, null, 120),
  ('QA', 'default', '1140', 'Staff advances and loans to employees', '{"en":"Staff advances and loans to employees"}'::jsonb, 'asset_current', false, null, 130),
  ('QA', 'default', '1150', 'Income tax paid in advance', '{"en":"Income tax paid in advance"}'::jsonb, 'asset_current', false, null, 140),
  ('QA', 'default', '1160', 'Income tax recoverable', '{"en":"Income tax recoverable"}'::jsonb, 'asset_current', false, null, 150),
  ('QA', 'default', '1170', 'Withholding tax credits receivable', '{"en":"Withholding tax credits receivable"}'::jsonb, 'asset_current', false, null, 155),
  ('QA', 'default', '1200', 'Inventory — raw materials and consumables', '{"en":"Inventory — raw materials and consumables"}'::jsonb, 'asset_current', false, null, 160),
  ('QA', 'default', '1210', 'Inventory — work in progress', '{"en":"Inventory — work in progress"}'::jsonb, 'asset_current', false, null, 170),
  ('QA', 'default', '1220', 'Inventory — finished goods and goods for resale', '{"en":"Inventory — finished goods and goods for resale"}'::jsonb, 'asset_current', false, null, 180),
  ('QA', 'default', '1230', 'Goods in transit', '{"en":"Goods in transit"}'::jsonb, 'asset_current', false, null, 190),
  ('QA', 'default', '1300', 'Fixed deposits of more than three months', '{"en":"Fixed deposits of more than three months"}'::jsonb, 'asset_current', false, null, 200),
  ('QA', 'default', '1310', 'Listed investments held for trading', '{"en":"Listed investments held for trading"}'::jsonb, 'asset_current', false, null, 210),
  ('QA', 'default', '1320', 'Amounts due from related parties — non-trade', '{"en":"Amounts due from related parties — non-trade"}'::jsonb, 'asset_current', false, null, 220),
  ('QA', 'default', '1400', 'Prepaid expenses', '{"en":"Prepaid expenses"}'::jsonb, 'asset_prepayments', false, null, 230),
  ('QA', 'default', '1410', 'Rental and utility deposits paid', '{"en":"Rental and utility deposits paid"}'::jsonb, 'asset_prepayments', false, null, 240),
  ('QA', 'default', '1420', 'Deposits paid to suppliers', '{"en":"Deposits paid to suppliers"}'::jsonb, 'asset_prepayments', false, null, 250),
  ('QA', 'default', '1600', 'Land and buildings', '{"en":"Land and buildings"}'::jsonb, 'asset_fixed', false, null, 260),
  ('QA', 'default', '1610', 'Leasehold improvements', '{"en":"Leasehold improvements"}'::jsonb, 'asset_fixed', false, null, 270),
  ('QA', 'default', '1620', 'Furniture and fixtures', '{"en":"Furniture and fixtures"}'::jsonb, 'asset_fixed', false, null, 280),
  ('QA', 'default', '1630', 'Office equipment', '{"en":"Office equipment"}'::jsonb, 'asset_fixed', false, null, 290),
  ('QA', 'default', '1640', 'Computer equipment and software', '{"en":"Computer equipment and software"}'::jsonb, 'asset_fixed', false, null, 300),
  ('QA', 'default', '1650', 'Motor vehicles', '{"en":"Motor vehicles"}'::jsonb, 'asset_fixed', false, null, 310),
  ('QA', 'default', '1660', 'Plant and machinery', '{"en":"Plant and machinery"}'::jsonb, 'asset_fixed', false, null, 320),
  ('QA', 'default', '1670', 'Right-of-use assets', '{"en":"Right-of-use assets"}'::jsonb, 'asset_fixed', false, null, 330),
  ('QA', 'default', '1690', 'Accumulated depreciation — property plant and equipment', '{"en":"Accumulated depreciation — property plant and equipment"}'::jsonb, 'asset_fixed', false, null, 340),
  ('QA', 'default', '1695', 'Accumulated depreciation — right-of-use assets', '{"en":"Accumulated depreciation — right-of-use assets"}'::jsonb, 'asset_fixed', false, null, 350),
  ('QA', 'default', '1800', 'Goodwill', '{"en":"Goodwill"}'::jsonb, 'asset_non_current', false, null, 360),
  ('QA', 'default', '1810', 'Other intangible assets', '{"en":"Other intangible assets"}'::jsonb, 'asset_non_current', false, null, 370),
  ('QA', 'default', '1820', 'Accumulated amortisation — intangible assets', '{"en":"Accumulated amortisation — intangible assets"}'::jsonb, 'asset_non_current', false, null, 380),
  ('QA', 'default', '1900', 'Investments in subsidiaries', '{"en":"Investments in subsidiaries"}'::jsonb, 'asset_non_current', false, null, 390),
  ('QA', 'default', '1910', 'Investments in associates', '{"en":"Investments in associates"}'::jsonb, 'asset_non_current', false, null, 400),
  ('QA', 'default', '1920', 'Other long-term investments', '{"en":"Other long-term investments"}'::jsonb, 'asset_non_current', false, null, 410),
  ('QA', 'default', '1930', 'Rental and utility deposits — non-current', '{"en":"Rental and utility deposits — non-current"}'::jsonb, 'asset_non_current', false, null, 420),
  ('QA', 'default', '1990', 'Deferred tax assets', '{"en":"Deferred tax assets"}'::jsonb, 'asset_non_current', false, null, 430),
  ('QA', 'default', '2000', 'Trade payables', '{"en":"Trade payables"}'::jsonb, 'liability_payable', true, null, 440),
  ('QA', 'default', '2010', 'Amounts due to related parties', '{"en":"Amounts due to related parties"}'::jsonb, 'liability_current', false, null, 450),
  ('QA', 'default', '2020', 'Accruals', '{"en":"Accruals"}'::jsonb, 'liability_current', false, null, 460),
  ('QA', 'default', '2030', 'Customer deposits and advances received', '{"en":"Customer deposits and advances received"}'::jsonb, 'liability_current', false, null, 470),
  ('QA', 'default', '2040', 'Salaries and wages payable', '{"en":"Salaries and wages payable"}'::jsonb, 'liability_current', false, null, 480),
  ('QA', 'default', '2050', 'End-of-service gratuity payable', '{"en":"End-of-service gratuity payable"}'::jsonb, 'liability_current', false, null, 490),
  ('QA', 'default', '2060', 'Provision for income tax', '{"en":"Provision for income tax"}'::jsonb, 'liability_current', false, null, 500),
  ('QA', 'default', '2065', 'Withholding tax payable on payments to non-residents', '{"en":"Withholding tax payable on payments to non-residents"}'::jsonb, 'liability_current', false, null, 505),
  ('QA', 'default', '2070', 'Excise tax, customs duties and other government charges payable', '{"en":"Excise tax, customs duties and other government charges payable"}'::jsonb, 'liability_current', false, null, 510),
  ('QA', 'default', '2080', 'Lease liabilities — current portion', '{"en":"Lease liabilities — current portion"}'::jsonb, 'liability_current', false, null, 520),
  ('QA', 'default', '2090', 'Suspense account', '{"en":"Suspense account"}'::jsonb, 'liability_current', false, null, 530),
  ('QA', 'default', '2200', 'Corporate credit card payable', '{"en":"Corporate credit card payable"}'::jsonb, 'liability_credit_card', false, null, 540),
  ('QA', 'default', '2300', 'Bank borrowings — non-current', '{"en":"Bank borrowings — non-current"}'::jsonb, 'liability_non_current', false, null, 550),
  ('QA', 'default', '2310', 'Lease liabilities — non-current', '{"en":"Lease liabilities — non-current"}'::jsonb, 'liability_non_current', false, null, 560),
  ('QA', 'default', '2320', 'Amounts due to shareholders — non-current', '{"en":"Amounts due to shareholders — non-current"}'::jsonb, 'liability_non_current', false, null, 570),
  ('QA', 'default', '2390', 'Deferred tax liabilities', '{"en":"Deferred tax liabilities"}'::jsonb, 'liability_non_current', false, null, 580),
  ('QA', 'default', '3000', 'Issued share capital', '{"en":"Issued share capital"}'::jsonb, 'equity', false, null, 590),
  ('QA', 'default', '3100', 'Share premium', '{"en":"Share premium"}'::jsonb, 'equity', false, null, 600),
  ('QA', 'default', '3110', 'Legal and other reserves', '{"en":"Legal and other reserves"}'::jsonb, 'equity', false, null, 610),
  ('QA', 'default', '3200', 'Retained earnings', '{"en":"Retained earnings"}'::jsonb, 'equity_retained', false, null, 620),
  ('QA', 'default', '4000', 'Sale of goods', '{"en":"Sale of goods"}'::jsonb, 'income', false, null, 630),
  ('QA', 'default', '4010', 'Rendering of services', '{"en":"Rendering of services"}'::jsonb, 'income', false, null, 640),
  ('QA', 'default', '4700', 'Realised exchange gains', '{"en":"Realised exchange gains"}'::jsonb, 'income_other', false, null, 650),
  ('QA', 'default', '4710', 'Unrealised exchange gains', '{"en":"Unrealised exchange gains"}'::jsonb, 'income_other', false, null, 660),
  ('QA', 'default', '4720', 'Interest income', '{"en":"Interest income"}'::jsonb, 'income_other', false, null, 670),
  ('QA', 'default', '4730', 'Sundry income', '{"en":"Sundry income"}'::jsonb, 'income_other', false, null, 680),
  ('QA', 'default', '4750', 'Gain on disposal of fixed assets', '{"en":"Gain on disposal of fixed assets"}'::jsonb, 'income_other', false, null, 690),
  ('QA', 'default', '5000', 'Cost of goods sold', '{"en":"Cost of goods sold"}'::jsonb, 'expense_direct_cost', false, null, 700),
  ('QA', 'default', '5010', 'Purchases', '{"en":"Purchases"}'::jsonb, 'expense_direct_cost', false, null, 710),
  ('QA', 'default', '5020', 'Freight inwards', '{"en":"Freight inwards"}'::jsonb, 'expense_direct_cost', false, null, 720),
  ('QA', 'default', '5030', 'Direct labour', '{"en":"Direct labour"}'::jsonb, 'expense_direct_cost', false, null, 730),
  ('QA', 'default', '6000', 'Directors'' remuneration', '{"en":"Directors'' remuneration"}'::jsonb, 'expense', false, null, 740),
  ('QA', 'default', '6010', 'Staff salaries and wages', '{"en":"Staff salaries and wages"}'::jsonb, 'expense', false, null, 750),
  ('QA', 'default', '6020', 'End-of-service gratuity expense', '{"en":"End-of-service gratuity expense"}'::jsonb, 'expense', false, null, 760),
  ('QA', 'default', '6030', 'Staff welfare and benefits', '{"en":"Staff welfare and benefits"}'::jsonb, 'expense', false, null, 770),
  ('QA', 'default', '6100', 'Rent', '{"en":"Rent"}'::jsonb, 'expense', false, null, 780),
  ('QA', 'default', '6110', 'Management fees and building outgoings', '{"en":"Management fees and building outgoings"}'::jsonb, 'expense', false, null, 790),
  ('QA', 'default', '6120', 'Utilities', '{"en":"Utilities"}'::jsonb, 'expense', false, null, 800),
  ('QA', 'default', '6200', 'Commercial registration and licence fees', '{"en":"Commercial registration and licence fees"}'::jsonb, 'expense', false, null, 810),
  ('QA', 'default', '6210', 'Auditor''s remuneration', '{"en":"Auditor''s remuneration"}'::jsonb, 'expense', false, null, 820),
  ('QA', 'default', '6220', 'Accounting and company secretarial fees', '{"en":"Accounting and company secretarial fees"}'::jsonb, 'expense', false, null, 830),
  ('QA', 'default', '6230', 'Legal and professional fees', '{"en":"Legal and professional fees"}'::jsonb, 'expense', false, null, 840),
  ('QA', 'default', '6300', 'Repairs and maintenance', '{"en":"Repairs and maintenance"}'::jsonb, 'expense', false, null, 850),
  ('QA', 'default', '6310', 'Insurance', '{"en":"Insurance"}'::jsonb, 'expense', false, null, 860),
  ('QA', 'default', '6320', 'Motor vehicle expenses', '{"en":"Motor vehicle expenses"}'::jsonb, 'expense', false, null, 870),
  ('QA', 'default', '6330', 'Travelling expenses', '{"en":"Travelling expenses"}'::jsonb, 'expense', false, null, 880),
  ('QA', 'default', '6340', 'Entertainment expenses', '{"en":"Entertainment expenses"}'::jsonb, 'expense', false, null, 890),
  ('QA', 'default', '6350', 'Advertising and promotion', '{"en":"Advertising and promotion"}'::jsonb, 'expense', false, null, 900),
  ('QA', 'default', '6360', 'Printing, stationery and postage', '{"en":"Printing, stationery and postage"}'::jsonb, 'expense', false, null, 910),
  ('QA', 'default', '6370', 'Telecommunications', '{"en":"Telecommunications"}'::jsonb, 'expense', false, null, 920),
  ('QA', 'default', '6380', 'Bank charges', '{"en":"Bank charges"}'::jsonb, 'expense', false, null, 930),
  ('QA', 'default', '6390', 'Sundry office expenses', '{"en":"Sundry office expenses"}'::jsonb, 'expense', false, null, 940),
  ('QA', 'default', '6400', 'Allowance for expected credit losses charged', '{"en":"Allowance for expected credit losses charged"}'::jsonb, 'expense', false, null, 950),
  ('QA', 'default', '6410', 'Interest expense on bank borrowings', '{"en":"Interest expense on bank borrowings"}'::jsonb, 'expense', false, null, 960),
  ('QA', 'default', '6420', 'Interest expense on lease liabilities', '{"en":"Interest expense on lease liabilities"}'::jsonb, 'expense', false, null, 970),
  ('QA', 'default', '6450', 'Realised exchange losses', '{"en":"Realised exchange losses"}'::jsonb, 'expense', false, null, 980),
  ('QA', 'default', '6455', 'Unrealised exchange losses', '{"en":"Unrealised exchange losses"}'::jsonb, 'expense', false, null, 990),
  ('QA', 'default', '6460', 'Loss on disposal of fixed assets', '{"en":"Loss on disposal of fixed assets"}'::jsonb, 'expense', false, null, 1000),
  ('QA', 'default', '6470', 'Income tax charge', '{"en":"Income tax charge"}'::jsonb, 'expense', false, null, 1010),
  ('QA', 'default', '6475', 'Withholding tax borne on payments to non-residents', '{"en":"Withholding tax borne on payments to non-residents"}'::jsonb, 'expense', false, null, 1015),
  ('QA', 'default', '6480', 'Deferred tax charge', '{"en":"Deferred tax charge"}'::jsonb, 'expense', false, null, 1020),
  ('QA', 'default', '6490', 'Rounding differences', '{"en":"Rounding differences"}'::jsonb, 'expense', false, null, 1030),
  ('QA', 'default', '6800', 'Depreciation and amortisation', '{"en":"Depreciation and amortisation"}'::jsonb, 'expense_depreciation', false, null, 1040)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('QA', 'BNK', 'Bank', '{"en":"Bank"}'::jsonb, 'bank', 30),
  ('QA', 'CSH', 'Petty cash', '{"en":"Petty cash"}'::jsonb, 'cash', 40),
  ('QA', 'GEN', 'General journal', '{"en":"General journal"}'::jsonb, 'general', 50),
  ('QA', 'OPN', 'Opening balances', '{"en":"Opening balances"}'::jsonb, 'opening', 60),
  ('QA', 'PUR', 'Purchases journal', '{"en":"Purchases journal"}'::jsonb, 'purchase', 20),
  ('QA', 'SAL', 'Sales journal', '{"en":"Sales journal"}'::jsonb, 'sales', 10)
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
  ('QA', 'QA-P-NA', 'Purchase, not subject to any tax on turnover', '{"en":"Purchase, not subject to any tax on turnover"}'::jsonb, 'Every purchase a Qatari business books — domestic, imported, or delivered from outside Qatar to a place outside Qatar', 'percent', 0, 'purchase', 'not_subject', date '2000-01-01', null, 'The purchase side of QA-S-NA: qatar has no value added tax, goods and services tax or general sales tax in force. It signed the Unified VAT Agreement of the GCC States (standard rate 5 %), adopted in December 2015, but no national VAT law has been enacted: the General Tax Authority''s list of tax laws (consulted 10 October 2026) holds the Income Tax Law (Law No. 24 of 2018), the Excise Tax Law (Law No. 25 of 2018), the Global Minimum Tax Resolution (No. 2 of 2026) and a capital gains resolution (Cabinet Resolution No. 3 of 2026), and lists the VAT only as a regional agreement, not as a law. Nothing a Qatari business buys carries a recoverable value added tax. An import does carry customs duty, which this pack does not model: Qatar applies the GCC customs union''s 5 % ad valorem tariff on the CIF value of general goods, with higher rates for some goods and exemptions for others (Invest Qatar, Customs; legal basis Law No. 40 of 2002 and Law No. 41 of 2002 per that page, which this pack did not check against the General Authority of Customs tariff). Excise tax on specified goods (Law No. 25 of 2018; sweetened drinks by sugar content from 6 July 2026 under Law No. 2 of 2026) is likewise a levy on those goods, not a tax a purchase line can carry a code for. See ''From Qatar'' in docs/international.md.', 'O', null, 20, 'other', true, '{}'::tax_condition[], null, false, false, null, 'gta-laws', null, null, null, null),
  ('QA', 'QA-S-NA', 'Sale, not subject to any tax on turnover', '{"en":"Sale, not subject to any tax on turnover"}'::jsonb, 'Every sale a Qatari business makes — domestic, exported, or delivered from outside Qatar to a place outside Qatar', 'percent', 0, 'sale', 'not_subject', date '2000-01-01', null, 'Qatar has no value added tax, goods and services tax or general sales tax in force. It signed the Unified VAT Agreement of the GCC States (standard rate 5 %), adopted in December 2015, but no national VAT law has been enacted: the General Tax Authority''s list of tax laws (consulted 10 October 2026) holds the Income Tax Law (Law No. 24 of 2018), the Excise Tax Law (Law No. 25 of 2018), the Global Minimum Tax Resolution (No. 2 of 2026) and a capital gains resolution (Cabinet Resolution No. 3 of 2026), and lists the VAT only as a regional agreement, not as a law. What Qatar levies instead is outside this pack: income tax at 10 % of taxable income, with the income of Qatari natural persons and the share of Qatari owners in wholly or partly Qatari-owned companies exempt (Law No. 24 of 2018, articles 4 and 9), a final withholding tax of 5 % on royalties, interest, commissions and fees for services paid to non-residents without a permanent establishment (article 9, clause 2), excise tax on specified goods (Law No. 25 of 2018, as amended by Law No. 2 of 2026), customs duty under the GCC customs union and the 15 % domestic top-up tax of the global minimum tax (Resolution No. 2 of 2026). None is a tax an invoice line carries and credits on the other side. There is accordingly no rate for this code to state and no box for its base: the code exists so that every sale line still carries a tax code the engine can post, as in a country with a real turnover tax, and states plainly that Qatar has none. `valid_from` is a convenience the field needed, not the date a turnover tax was absent from; the pack makes no claim about before the GCC VAT Agreement. If a VAT law is published, this code must be replaced. See ''From Qatar'' in docs/international.md.', 'O', null, 10, 'other', true, '{}'::tax_condition[], null, false, false, null, 'gta-laws', null, null, null, null)
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
    ('QA-P-NA', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('QA-P-NA', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('QA-S-NA', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('QA-S-NA', 'credit_note', 'base', 100, null, null, null, 100, null, 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'QA' and t.code = v.tax_code
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
  ('QA-IFRS-IS', 'QA', 'default', 'Statement of profit or loss', 'income_statement', 'IFRS', date '1970-01-01', null, 'Presented as a separate statement of profit or loss, with expenses classified by function in outline (cost of sales, then operating expenses) in the manner of IAS 1 paragraphs 81A and 99-103, as the Income Tax Law (Law No. 24 of 2018), articles 6 and 12, point to international accounting standards without prescribing a layout. Other comprehensive income is not modelled: no revaluation or similar account is carried, so the profit for the year is the whole result. IFRS 18, which replaces IAS 1 for annual periods beginning on or after 1 January 2027, is not modelled. The numbering is original to this pack.', 'income-tax-law'),
  ('QA-IFRS-SFP', 'QA', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS', date '1970-01-01', null, 'Qatar''s Income Tax Law (Law No. 24 of 2018), article 12, requires books and records kept in accordance with the laws of the State and international accounting standards, and article 6 requires accrual accounting in accordance with international accounting standards; the Commercial Companies Law (Law No. 11 of 2015), article 182, gives a company a twelve-month financial year and article 183 has the board submit the balance sheet, profit and loss account and activity report to the auditor each year. This pack''s research did not open a Qatari text prescribing a statement layout, and did not verify which IFRS regime (full IFRS Accounting Standards or IFRS for SMEs) Qatari non-listed companies apply. The lines follow the minimum line items of IAS 1 Presentation of Financial Statements, paragraph 54, with current and non-current assets and liabilities presented separately (paragraph 60); the numbering and the account ranges are original to this pack. This is the first thing a local reviewer should check.', 'income-tax-law')
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
  ('QA-IFRS-IS', 'REV', null, 'Revenue', '{"en":"Revenue"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-IS', 'COST', null, 'Cost of sales', '{"en":"Cost of sales"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-IS', 'GROSS', null, 'Gross profit', '{"en":"Gross profit"}'::jsonb, 30, 1, true, array['REV']::text[], array['COST']::text[], null, null, null),
  ('QA-IFRS-IS', 'OTH-INC', null, 'Other income', '{"en":"Other income"}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-IS', 'OPEX', null, 'Administrative and other operating expenses', '{"en":"Administrative and other operating expenses"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-IS', 'DEPR', null, 'Depreciation and amortisation', '{"en":"Depreciation and amortisation"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-IS', 'PBT', null, 'Profit (loss) before tax', '{"en":"Profit (loss) before tax"}'::jsonb, 65, 1, true, array['GROSS', 'OTH-INC']::text[], array['OPEX', 'DEPR']::text[], null, null, null),
  ('QA-IFRS-IS', 'TAX', null, 'Income tax expense', '{"en":"Income tax expense"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-IS', 'PROFIT', null, 'Profit (loss) for the year', '{"en":"Profit (loss) for the year"}'::jsonb, 80, 1, true, array['PBT']::text[], array['TAX']::text[], null, null, null),
  ('QA-IFRS-SFP', 'A-NC-FIX', 'A-NC', 'Property, plant and equipment', '{"en":"Property, plant and equipment"}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-SFP', 'A-NC-INT', 'A-NC', 'Goodwill and other intangible assets', '{"en":"Goodwill and other intangible assets"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-SFP', 'A-NC-OTH', 'A-NC', 'Other non-current assets', '{"en":"Other non-current assets"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-SFP', 'A-NC', null, 'Non-current assets', '{"en":"Non-current assets"}'::jsonb, 40, 1, true, array['A-NC-FIX', 'A-NC-INT', 'A-NC-OTH']::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-SFP', 'A-C-REC', 'A-C', 'Trade and other receivables', '{"en":"Trade and other receivables"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-SFP', 'A-C-INV', 'A-C', 'Inventories', '{"en":"Inventories"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-SFP', 'A-C-OTH', 'A-C', 'Other current assets', '{"en":"Other current assets"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-SFP', 'A-C-PRE', 'A-C', 'Prepayments and deposits paid', '{"en":"Prepayments and deposits paid"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-SFP', 'A-C-CASH', 'A-C', 'Cash and cash equivalents', '{"en":"Cash and cash equivalents"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-SFP', 'A-C', null, 'Current assets', '{"en":"Current assets"}'::jsonb, 100, 1, true, array['A-C-REC', 'A-C-INV', 'A-C-OTH', 'A-C-PRE', 'A-C-CASH']::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-SFP', 'A-TOT', null, 'Total assets', '{"en":"Total assets"}'::jsonb, 110, 1, true, array['A-NC', 'A-C']::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-SFP', 'E-CAP', 'E-TOT', 'Share capital and reserves', '{"en":"Share capital and reserves"}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-SFP', 'E-RET', 'E-TOT', 'Retained earnings', '{"en":"Retained earnings"}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-SFP', 'E-RESULT', 'E-TOT', 'Profit for the year', '{"en":"Profit for the year"}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-SFP', 'E-TOT', null, 'Total equity', '{"en":"Total equity"}'::jsonb, 150, 1, true, array['E-CAP', 'E-RET', 'E-RESULT']::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-SFP', 'L-NC', 'L-TOT', 'Non-current liabilities', '{"en":"Non-current liabilities"}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-SFP', 'L-C-PAY', 'L-C', 'Trade and other payables', '{"en":"Trade and other payables"}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-SFP', 'L-C-TAX', 'L-C', 'Current tax liabilities', '{"en":"Current tax liabilities"}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-SFP', 'L-C-OTH', 'L-C', 'Other current liabilities', '{"en":"Other current liabilities"}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-SFP', 'L-C', null, 'Current liabilities', '{"en":"Current liabilities"}'::jsonb, 200, 1, true, array['L-C-PAY', 'L-C-TAX', 'L-C-OTH']::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-SFP', 'L-TOT', null, 'Total liabilities', '{"en":"Total liabilities"}'::jsonb, 210, 1, true, array['L-NC', 'L-C']::text[], '{}'::text[], null, null, null),
  ('QA-IFRS-SFP', 'EL-TOT', null, 'Total equity and liabilities', '{"en":"Total equity and liabilities"}'::jsonb, 220, 1, true, array['E-TOT', 'L-TOT']::text[], '{}'::text[], null, null, null)
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
    ('QA-IFRS-IS', 'REV', 10, 'code_range', '4000', '4699', null, 'any'),
    ('QA-IFRS-IS', 'COST', 10, 'code_range', '5000', '5099', null, 'any'),
    ('QA-IFRS-IS', 'OTH-INC', 10, 'code_range', '4700', '4799', null, 'any'),
    ('QA-IFRS-IS', 'OPEX', 10, 'code_range', '6000', '6469', null, 'any'),
    ('QA-IFRS-IS', 'OPEX', 20, 'code_range', '6475', '6479', null, 'any'),
    ('QA-IFRS-IS', 'OPEX', 30, 'code_range', '6481', '6799', null, 'any'),
    ('QA-IFRS-IS', 'DEPR', 10, 'code_range', '6800', '6899', null, 'any'),
    ('QA-IFRS-IS', 'TAX', 10, 'code_range', '6470', '6474', null, 'any'),
    ('QA-IFRS-IS', 'TAX', 20, 'account_code', '6480', null, null, 'any'),
    ('QA-IFRS-SFP', 'A-NC-FIX', 10, 'code_range', '1600', '1799', null, 'any'),
    ('QA-IFRS-SFP', 'A-NC-INT', 10, 'code_range', '1800', '1899', null, 'any'),
    ('QA-IFRS-SFP', 'A-NC-OTH', 10, 'code_range', '1900', '1999', null, 'any'),
    ('QA-IFRS-SFP', 'A-C-REC', 10, 'code_range', '1100', '1199', null, 'any'),
    ('QA-IFRS-SFP', 'A-C-INV', 10, 'code_range', '1200', '1299', null, 'any'),
    ('QA-IFRS-SFP', 'A-C-OTH', 10, 'code_range', '1300', '1399', null, 'any'),
    ('QA-IFRS-SFP', 'A-C-PRE', 10, 'code_range', '1400', '1499', null, 'any'),
    ('QA-IFRS-SFP', 'A-C-CASH', 10, 'code_range', '1000', '1099', null, 'any'),
    ('QA-IFRS-SFP', 'E-CAP', 10, 'code_range', '3000', '3199', null, 'any'),
    ('QA-IFRS-SFP', 'E-RET', 10, 'code_range', '3200', '3299', null, 'any'),
    ('QA-IFRS-SFP', 'E-RESULT', 10, 'code_range', '4000', '4699', null, 'any'),
    ('QA-IFRS-SFP', 'E-RESULT', 20, 'code_range', '4700', '4799', null, 'any'),
    ('QA-IFRS-SFP', 'E-RESULT', 30, 'code_range', '5000', '5099', null, 'any'),
    ('QA-IFRS-SFP', 'E-RESULT', 40, 'code_range', '6000', '6899', null, 'any'),
    ('QA-IFRS-SFP', 'L-NC', 10, 'code_range', '2300', '2399', null, 'any'),
    ('QA-IFRS-SFP', 'L-C-PAY', 10, 'code_range', '2000', '2059', null, 'any'),
    ('QA-IFRS-SFP', 'L-C-TAX', 10, 'code_range', '2060', '2069', null, 'any'),
    ('QA-IFRS-SFP', 'L-C-OTH', 10, 'code_range', '2070', '2099', null, 'any'),
    ('QA-IFRS-SFP', 'L-C-OTH', 20, 'code_range', '2200', '2299', null, 'any')
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
  ('QA', 'Qatar', '{"en":"Qatar"}'::jsonb, array['ar', 'en']::text[], 'QAR', '1100', '2000', '2090', '6490', '3200', '4000', '5010', '1010', '1000', 'SAL', 'PUR', 'GEN', 'ar', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6450', '4750', '6460', null, null, null, null, null, null)
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
  numbering_legal_reference     = 'Qatar has no value added tax, goods and services tax or general sales tax in force. It signed the Unified VAT Agreement of the GCC States (standard rate 5 %), adopted in December 2015, but no national VAT law has been enacted: the General Tax Authority''s list of tax laws (consulted 10 October 2026) holds the Income Tax Law (Law No. 24 of 2018), the Excise Tax Law (Law No. 25 of 2018), the Global Minimum Tax Resolution (No. 2 of 2026) and a capital gains resolution (Cabinet Resolution No. 3 of 2026), and lists the VAT only as a regional agreement, not as a law. No tax invoice regime exists, so this pack''s research found no Qatari statute conditioning a tax position on an invoice carrying a sequential number; what the Income Tax Law requires is that books, records and supporting documents be kept (article 12; Executive Regulations, article 35) and retained at the place of business for ten years following the year to which they relate (Executive Regulations, article 36(1)). `numbering` is therefore `free`, and `number_format` is a convention this pack proposes. This pack did not read the Commercial Code or the Civil Code for an invoice rule, and a local reviewer should confirm there is none.',
  numbering_source_key          = 'income-tax-regs',
  payment_terms_legal_reference = 'This pack''s research found no Qatari text setting a payment term between two businesses in the absence of an agreement, or a statutory rate of late-payment interest on a commercial debt; it did not read the Civil Code (Law No. 22 of 2004) or the Commercial Code for one, which is a gap for a local reviewer to close. `legal_payment_days` and `late_payment_reference` are therefore empty and a seller''s terms are a matter of contract.',
  payment_terms_source_key      = 'income-tax-law',
  tax_point_rule                = 'invoice_date',
  tax_point_legal_reference     = 'This field has no true value for Qatar: it names the day a country''s general rule makes its own turnover tax chargeable, and no such tax is in force. `invoice_date` is declared as the closest commercial convention, in line with the accrual basis article 6 of the Income Tax Law (Law No. 24 of 2018) requires for taxable income — a convention, not a rule read from a text, and not a statement about when income tax, withholding tax or excise tax arises. See ''From Qatar'' in docs/international.md.',
  tax_point_source_key          = 'income-tax-law',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No Qatari law in force obliges a business to issue or accept an electronic invoice (consulted 10 October 2026). On 6 May 2026 the Council of Ministers approved a DRAFT law on electronic invoicing and its implementing regulations, prepared by the Ministry of Finance with the General Tax Authority; the draft was still to pass the Shura Council and receive the Amir''s assent, and this pack''s research found no sign that it has been promulgated or published in the Official Gazette (the almeezan.qa legal portal could not be opened). It names no technical model, platform, scope, threshold or go-live date, and industry commentary pointing to a phased start from 1 January 2027, large taxpayers first, is expectation and not an official date. `obligation` is therefore `none` and `profile`, `party_scheme` and `vat_scheme` are null: the draft is the next change to watch, and no profile is invented for it. No Peppol Authority for Qatar was found, and no VAT identifier exists for a scheme to carry.',
  einvoice_source_key           = 'einvoicing-draft',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'QA';
