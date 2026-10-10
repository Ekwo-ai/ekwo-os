-- Ekwo OS — Zimbabwe: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/zw at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build zw`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Value Added Tax Act [Chapter 23:12], consolidated to Act 13 of 2023: ss. 2, 6, 8, 10, 11, 12, 13, 13A, 15, 16, 20, 21, 23, 27, 28 and 38 (Government of Zimbabwe, consolidated text published by the Zimbabwe Investment and Development Agency (ZIDA) eRegulations portal)
--     https://eregulations.zidainvest.com/media/Value%20Added%20Tax%20Act%20Chapter%202312.pdf
--   Finance Act, 2025 (Act No. 7 of 2025), Part III — Value Added Tax: ss. 34 (rate of 15.5 % from 1 January 2026), 35 (fiscal tax invoice and fiscal device), 37 and 38 (zero rating and exemptions), 43 (imported services paid in US dollars), 44 (digital services withholding tax) and 45 (TIN and QR code on a tax invoice) (Parliament of Zimbabwe, published by Veritas)
--     https://www.veritaszim.net/sites/veritas_d/files/Finance%20Act%2C%20Act%20No.%207%20of%202025.pdf
--   VAT 7 Return — Return for Remittance of Value Added Tax (DTF 98, issue 3, version 2, 5 September 2023): Parts I to V (Zimbabwe Revenue Authority)
--     https://www.zimra.co.zw/downloads/category/9-domestic-taxes?download=3391%3Avat-7-return
--   Public Notice No. 7 of 2026 — Implications of change of VAT rate on return submission in TaRMS (15 % to 15.5 % from 1 January 2026, by category) (Zimbabwe Revenue Authority)
--     https://www.zimra.co.zw/public-notices?download=4441%3Apublic-notice-07-of-2026-change-of-vat-rate-on-submission-of-return-category-a&start=20
--   Public Notice No. 11 of 2026 — Submission of VAT returns and payment, Categories A and C: return by the 10th and payment by the 15th under Statutory Instrument 81 of 2025; input tax only on fiscal tax invoices valid on the FDMS (Zimbabwe Revenue Authority)
--     https://www.zimra.co.zw/public-notices?download=4447%3Apublic-notice-11-of-2026-submission-of-vat-returns-and-payment-categories-a-c-due-dates-february-2026&start=20
--   Public Notice No. 63 of 2025 — Roll-out and implementation of the TaRMS/FDMS integration: automatic input tax schedule, the input fields still filled by hand, tax clearance conditional on fiscalisation (Zimbabwe Revenue Authority)
--     https://www.zimra.co.zw/public-notices?download=4410%3Apublic-notice-63-of-2025-tarms-fdms-integration
--   Public Notice No. 30 of 2025 — Upgrade of fiscal devices to transmit buyer details to the Fiscalisation Data Management System; buyer details on fiscal tax invoices, debit and credit notes (Zimbabwe Revenue Authority)
--     https://zimra.co.zw/public-notices?download=4340%3Apublic-notice-30-of-2025-buyer-details-on-fdms-fiscal-tax-invoice
--   Fiscal Device Gateway API Specification, v7.2 — device registration, fiscal days, receipt submission and signature, the printed fiscal invoice and its QR code (Zimbabwe Revenue Authority)
--     https://www.zimra.co.zw/downloads/9-domestic-taxes?download=3807%3Afiscalisation-api-documentation
--   TaRMS Self-Service Portal — where the VAT 7 return is filed and the input tax schedule is selected (Zimbabwe Revenue Authority)
--     https://mytaxselfservice.zimra.co.zw
--   FDMS validation portal — where a fiscal tax invoice, debit or credit note is checked as valid (Zimbabwe Revenue Authority)
--     https://fdms.zimra.co.zw
--   Value Added Tax (General) (Amendment) Regulations, 2024 (No. 67), Statutory Instrument 15 of 2024 — First Schedule substituted: exemption of certain goods or services and imports (Government of Zimbabwe, published by Veritas)
--     https://www.veritaszim.net/node/6850
--   Presidential Powers (Temporary Measures) (Amendment of Reserve Bank of Zimbabwe Act and Issue of Zimbabwe Gold Notes and Coins) Regulations, 2024, Statutory Instrument 60 of 2024 — section 44D of the Reserve Bank of Zimbabwe Act, the ZiG as legal tender (Government of Zimbabwe, published by Veritas)
--     https://www.veritaszim.net/node/6945
--   ISO 4217 currency code list, list one — ZIMBABWE, Zimbabwe Gold, ZWG, 924, two minor units (SIX Financial Information, maintenance agency of ISO 4217)
--     https://www.six-group.com/dam/download/financial-information/data-center/iso-currrency/lists/list-one.xml
--   Zimbabwe — member profile: the Public Accountants and Auditors Board, IFRS Accounting Standards and the IFRS for SMEs Accounting Standard adopted, Statutory Instrument 137 of 2026 replacing Statutory Instrument 41 of 2019 (International Federation of Accountants)
--     https://www.ifac.org/about-ifac/membership/profile/zimbabwe
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('ZW', 'Zimbabwe', '0.1.0', date '2026-10-10', '20260929141500', 'community', null, null, '6b2e21756a81789c2fba0de23923b5dd73798cf754790556075daf1829c8b780', '[{"key":"vat-act","title":"Value Added Tax Act [Chapter 23:12], consolidated to Act 13 of 2023: ss. 2, 6, 8, 10, 11, 12, 13, 13A, 15, 16, 20, 21, 23, 27, 28 and 38","publisher":"Government of Zimbabwe, consolidated text published by the Zimbabwe Investment and Development Agency (ZIDA) eRegulations portal","url":"https://eregulations.zidainvest.com/media/Value%20Added%20Tax%20Act%20Chapter%202312.pdf","consulted_on":"2026-10-10","kind":"law"},{"key":"finance-act-2025","title":"Finance Act, 2025 (Act No. 7 of 2025), Part III — Value Added Tax: ss. 34 (rate of 15.5 % from 1 January 2026), 35 (fiscal tax invoice and fiscal device), 37 and 38 (zero rating and exemptions), 43 (imported services paid in US dollars), 44 (digital services withholding tax) and 45 (TIN and QR code on a tax invoice)","publisher":"Parliament of Zimbabwe, published by Veritas","url":"https://www.veritaszim.net/sites/veritas_d/files/Finance%20Act%2C%20Act%20No.%207%20of%202025.pdf","consulted_on":"2026-10-10","kind":"law"},{"key":"vat7-return","title":"VAT 7 Return — Return for Remittance of Value Added Tax (DTF 98, issue 3, version 2, 5 September 2023): Parts I to V","publisher":"Zimbabwe Revenue Authority","url":"https://www.zimra.co.zw/downloads/category/9-domestic-taxes?download=3391%3Avat-7-return","consulted_on":"2026-10-10","kind":"form"},{"key":"public-notice-7-2026","title":"Public Notice No. 7 of 2026 — Implications of change of VAT rate on return submission in TaRMS (15 % to 15.5 % from 1 January 2026, by category)","publisher":"Zimbabwe Revenue Authority","url":"https://www.zimra.co.zw/public-notices?download=4441%3Apublic-notice-07-of-2026-change-of-vat-rate-on-submission-of-return-category-a&start=20","consulted_on":"2026-10-10","kind":"guidance"},{"key":"public-notice-11-2026","title":"Public Notice No. 11 of 2026 — Submission of VAT returns and payment, Categories A and C: return by the 10th and payment by the 15th under Statutory Instrument 81 of 2025; input tax only on fiscal tax invoices valid on the FDMS","publisher":"Zimbabwe Revenue Authority","url":"https://www.zimra.co.zw/public-notices?download=4447%3Apublic-notice-11-of-2026-submission-of-vat-returns-and-payment-categories-a-c-due-dates-february-2026&start=20","consulted_on":"2026-10-10","kind":"guidance"},{"key":"public-notice-63-2025","title":"Public Notice No. 63 of 2025 — Roll-out and implementation of the TaRMS/FDMS integration: automatic input tax schedule, the input fields still filled by hand, tax clearance conditional on fiscalisation","publisher":"Zimbabwe Revenue Authority","url":"https://www.zimra.co.zw/public-notices?download=4410%3Apublic-notice-63-of-2025-tarms-fdms-integration","consulted_on":"2026-10-10","kind":"guidance"},{"key":"public-notice-30-2025","title":"Public Notice No. 30 of 2025 — Upgrade of fiscal devices to transmit buyer details to the Fiscalisation Data Management System; buyer details on fiscal tax invoices, debit and credit notes","publisher":"Zimbabwe Revenue Authority","url":"https://zimra.co.zw/public-notices?download=4340%3Apublic-notice-30-of-2025-buyer-details-on-fdms-fiscal-tax-invoice","consulted_on":"2026-10-10","kind":"guidance"},{"key":"fdms-api","title":"Fiscal Device Gateway API Specification, v7.2 — device registration, fiscal days, receipt submission and signature, the printed fiscal invoice and its QR code","publisher":"Zimbabwe Revenue Authority","url":"https://www.zimra.co.zw/downloads/9-domestic-taxes?download=3807%3Afiscalisation-api-documentation","consulted_on":"2026-10-10","kind":"standard"},{"key":"tarms-portal","title":"TaRMS Self-Service Portal — where the VAT 7 return is filed and the input tax schedule is selected","publisher":"Zimbabwe Revenue Authority","url":"https://mytaxselfservice.zimra.co.zw","consulted_on":"2026-10-10","kind":"portal"},{"key":"fdms-portal","title":"FDMS validation portal — where a fiscal tax invoice, debit or credit note is checked as valid","publisher":"Zimbabwe Revenue Authority","url":"https://fdms.zimra.co.zw","consulted_on":"2026-10-10","kind":"portal"},{"key":"si-15-2024","title":"Value Added Tax (General) (Amendment) Regulations, 2024 (No. 67), Statutory Instrument 15 of 2024 — First Schedule substituted: exemption of certain goods or services and imports","publisher":"Government of Zimbabwe, published by Veritas","url":"https://www.veritaszim.net/node/6850","consulted_on":"2026-10-10","kind":"regulation"},{"key":"si-60-2024","title":"Presidential Powers (Temporary Measures) (Amendment of Reserve Bank of Zimbabwe Act and Issue of Zimbabwe Gold Notes and Coins) Regulations, 2024, Statutory Instrument 60 of 2024 — section 44D of the Reserve Bank of Zimbabwe Act, the ZiG as legal tender","publisher":"Government of Zimbabwe, published by Veritas","url":"https://www.veritaszim.net/node/6945","consulted_on":"2026-10-10","kind":"regulation"},{"key":"iso-4217","title":"ISO 4217 currency code list, list one — ZIMBABWE, Zimbabwe Gold, ZWG, 924, two minor units","publisher":"SIX Financial Information, maintenance agency of ISO 4217","url":"https://www.six-group.com/dam/download/financial-information/data-center/iso-currrency/lists/list-one.xml","consulted_on":"2026-10-10","kind":"standard"},{"key":"ifac-zimbabwe","title":"Zimbabwe — member profile: the Public Accountants and Auditors Board, IFRS Accounting Standards and the IFRS for SMEs Accounting Standard adopted, Statutory Instrument 137 of 2026 replacing Statutory Instrument 41 of 2019","publisher":"International Federation of Accountants","url":"https://www.ifac.org/about-ifac/membership/profile/zimbabwe","consulted_on":"2026-10-10","kind":"guidance"}]'::jsonb)
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
  ('ZW', 'default', 'Zimbabwe reference chart of accounts', '{}'::jsonb, true, 'companies', array['ZW-PAAB-IS', 'ZW-PAAB-SFP']::text[], null, 'There is no legal chart of accounts in Zimbabwe. The Companies and Other Business Entities Act [Chapter 24:31] requires accounting records and annual financial statements, and the Public Accountants and Auditors Board prescribes IFRS Accounting Standards and the IFRS for SMEs Accounting Standard for them. This chart is original: four digits, blocked so that each range reaches one line of the IFRS-based statements, with the accounts a Zimbabwean company keeps — a ZWG current account and a US dollar foreign currency account side by side, VAT output and input tax, the net VAT settlement account, import VAT owed to ZIMRA at the border, VAT withheld by appointed agents, PAYE and AIDS levy, NSSA and ZIMDEF, withholding tax, intermediated money transfer tax and the irrecoverable VAT of s. 16(2) of the Value Added Tax Act.', 'ifac-zimbabwe')
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
  ('ZW', 'default', '1000', 'Petty cash', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('ZW', 'default', '1010', 'Current account — ZWG', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('ZW', 'default', '1020', 'Fixed deposits placed for three months or less', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('ZW', 'default', '1030', 'Foreign currency account — USD (nostro FCA)', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('ZW', 'default', '1035', 'Foreign currency account — other currencies', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('ZW', 'default', '1040', 'Cash in transit — mobile money settlements', '{}'::jsonb, 'asset_cash', false, null, 60),
  ('ZW', 'default', '1045', 'Petty cash — USD', '{}'::jsonb, 'asset_cash', false, null, 70),
  ('ZW', 'default', '1100', 'Trade receivables', '{}'::jsonb, 'asset_receivable', true, null, 80),
  ('ZW', 'default', '1110', 'Trade receivables — allowance for impairment', '{}'::jsonb, 'asset_current', false, null, 90),
  ('ZW', 'default', '1120', 'Other receivables', '{}'::jsonb, 'asset_current', false, null, 100),
  ('ZW', 'default', '1130', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 110),
  ('ZW', 'default', '1140', 'Deposits paid', '{}'::jsonb, 'asset_current', false, null, 120),
  ('ZW', 'default', '1150', 'VAT input tax', '{}'::jsonb, 'asset_current', false, null, 130),
  ('ZW', 'default', '1155', 'VAT refundable by ZIMRA — net of a filed return', '{}'::jsonb, 'asset_current', true, null, 140),
  ('ZW', 'default', '1160', 'Advances to staff', '{}'::jsonb, 'asset_current', false, null, 150),
  ('ZW', 'default', '1165', 'VAT withheld by customers appointed as agents — to be credited on the return', '{}'::jsonb, 'asset_current', false, null, 160),
  ('ZW', 'default', '1200', 'Inventories — goods for resale', '{}'::jsonb, 'asset_current', false, null, 170),
  ('ZW', 'default', '1210', 'Inventories — raw materials', '{}'::jsonb, 'asset_current', false, null, 180),
  ('ZW', 'default', '1220', 'Inventories — work in progress', '{}'::jsonb, 'asset_current', false, null, 190),
  ('ZW', 'default', '1230', 'Inventories — finished goods', '{}'::jsonb, 'asset_current', false, null, 200),
  ('ZW', 'default', '1300', 'Short-term investments', '{}'::jsonb, 'asset_current', false, null, 210),
  ('ZW', 'default', '1350', 'Current tax recoverable', '{}'::jsonb, 'asset_current', false, null, 220),
  ('ZW', 'default', '1355', 'Quarterly payments date (QPD) provisional tax paid', '{}'::jsonb, 'asset_current', false, null, 230),
  ('ZW', 'default', '1400', 'Prepayments', '{}'::jsonb, 'asset_prepayments', false, null, 240),
  ('ZW', 'default', '1410', 'Accrued income', '{}'::jsonb, 'asset_prepayments', false, null, 250),
  ('ZW', 'default', '1600', 'Land and buildings — cost', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('ZW', 'default', '1601', 'Land and buildings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('ZW', 'default', '1610', 'Leasehold improvements — cost', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('ZW', 'default', '1611', 'Leasehold improvements — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('ZW', 'default', '1620', 'Plant and machinery — cost', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('ZW', 'default', '1621', 'Plant and machinery — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('ZW', 'default', '1630', 'Office equipment — cost', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('ZW', 'default', '1631', 'Office equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('ZW', 'default', '1640', 'Computers — cost', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('ZW', 'default', '1641', 'Computers — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('ZW', 'default', '1650', 'Furniture and fittings — cost', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('ZW', 'default', '1651', 'Furniture and fittings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('ZW', 'default', '1660', 'Motor vehicles — cost', '{}'::jsonb, 'asset_fixed', false, null, 380),
  ('ZW', 'default', '1661', 'Motor vehicles — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 390),
  ('ZW', 'default', '1670', 'Right-of-use assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 400),
  ('ZW', 'default', '1671', 'Right-of-use assets — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 410),
  ('ZW', 'default', '1700', 'Investment property', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('ZW', 'default', '1750', 'Intangible assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 430),
  ('ZW', 'default', '1751', 'Intangible assets — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 440),
  ('ZW', 'default', '1760', 'Goodwill', '{}'::jsonb, 'asset_fixed', false, null, 450),
  ('ZW', 'default', '1800', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('ZW', 'default', '1810', 'Investments in joint ventures', '{}'::jsonb, 'asset_non_current', false, null, 470),
  ('ZW', 'default', '1830', 'Long-term financial assets', '{}'::jsonb, 'asset_non_current', false, null, 480),
  ('ZW', 'default', '1840', 'Long-term deposits', '{}'::jsonb, 'asset_non_current', false, null, 490),
  ('ZW', 'default', '1900', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 500),
  ('ZW', 'default', '2000', 'Trade payables', '{}'::jsonb, 'liability_payable', true, null, 510),
  ('ZW', 'default', '2010', 'Accrued expenses', '{}'::jsonb, 'liability_current', false, null, 520),
  ('ZW', 'default', '2020', 'Other payables', '{}'::jsonb, 'liability_current', false, null, 530),
  ('ZW', 'default', '2030', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 540),
  ('ZW', 'default', '2040', 'Deposits received from customers', '{}'::jsonb, 'liability_current', false, null, 550),
  ('ZW', 'default', '2100', 'VAT output tax', '{}'::jsonb, 'liability_current', false, null, 560),
  ('ZW', 'default', '2110', 'VAT payable to ZIMRA — net of a filed return', '{}'::jsonb, 'liability_current', true, null, 570),
  ('ZW', 'default', '2125', 'Import VAT payable to ZIMRA at the border', '{}'::jsonb, 'liability_current', false, null, 580),
  ('ZW', 'default', '2140', 'Withholding tax payable to ZIMRA', '{}'::jsonb, 'liability_current', false, null, 590),
  ('ZW', 'default', '2150', 'NSSA contributions payable', '{}'::jsonb, 'liability_current', false, null, 600),
  ('ZW', 'default', '2155', 'ZIMDEF levy payable', '{}'::jsonb, 'liability_current', false, null, 610),
  ('ZW', 'default', '2160', 'PAYE and AIDS levy payable to ZIMRA', '{}'::jsonb, 'liability_current', false, null, 620),
  ('ZW', 'default', '2165', 'VAT withheld from suppliers as an appointed agent — payable to ZIMRA', '{}'::jsonb, 'liability_current', false, null, 630),
  ('ZW', 'default', '2170', 'Excise duty payable to ZIMRA', '{}'::jsonb, 'liability_current', false, null, 640),
  ('ZW', 'default', '2175', 'Intermediated money transfer tax payable to ZIMRA', '{}'::jsonb, 'liability_current', false, null, 650),
  ('ZW', 'default', '2178', 'Digital services withholding tax payable to ZIMRA', '{}'::jsonb, 'liability_current', false, null, 660),
  ('ZW', 'default', '2180', 'Salaries payable', '{}'::jsonb, 'liability_current', false, null, 670),
  ('ZW', 'default', '2190', 'Directors'' fees payable', '{}'::jsonb, 'liability_current', false, null, 680),
  ('ZW', 'default', '2200', 'Bank overdraft', '{}'::jsonb, 'liability_current', false, null, 690),
  ('ZW', 'default', '2210', 'Bank loans — current portion', '{}'::jsonb, 'liability_current', false, null, 700),
  ('ZW', 'default', '2220', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 710),
  ('ZW', 'default', '2230', 'Hire purchase — current portion', '{}'::jsonb, 'liability_current', false, null, 720),
  ('ZW', 'default', '2240', 'Corporate credit card', '{}'::jsonb, 'liability_credit_card', false, null, 730),
  ('ZW', 'default', '2250', 'Amounts due to directors', '{}'::jsonb, 'liability_current', false, null, 740),
  ('ZW', 'default', '2300', 'Current tax payable', '{}'::jsonb, 'liability_current', false, null, 750),
  ('ZW', 'default', '2350', 'Provision for unutilised leave', '{}'::jsonb, 'liability_current', false, null, 760),
  ('ZW', 'default', '2360', 'Other provisions — current', '{}'::jsonb, 'liability_current', false, null, 770),
  ('ZW', 'default', '2400', 'Bank loans — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 780),
  ('ZW', 'default', '2410', 'Lease liabilities — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 790),
  ('ZW', 'default', '2420', 'Hire purchase — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 800),
  ('ZW', 'default', '2430', 'Loans from shareholders and directors — non-current', '{}'::jsonb, 'liability_non_current', false, null, 810),
  ('ZW', 'default', '2500', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 820),
  ('ZW', 'default', '2550', 'Provision for reinstatement costs', '{}'::jsonb, 'liability_non_current', false, null, 830),
  ('ZW', 'default', '2990', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 840),
  ('ZW', 'default', '3000', 'Share capital', '{}'::jsonb, 'equity', false, null, 850),
  ('ZW', 'default', '3010', 'Treasury shares', '{}'::jsonb, 'equity', false, null, 860),
  ('ZW', 'default', '3100', 'Other reserves', '{}'::jsonb, 'equity', false, null, 870),
  ('ZW', 'default', '3110', 'Foreign currency translation reserve', '{}'::jsonb, 'equity', false, null, 880),
  ('ZW', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 890),
  ('ZW', 'default', '3210', 'Dividends paid', '{}'::jsonb, 'equity_retained', false, null, 900),
  ('ZW', 'default', '4000', 'Sales of goods', '{}'::jsonb, 'income', false, null, 910),
  ('ZW', 'default', '4010', 'Services rendered', '{}'::jsonb, 'income', false, null, 920),
  ('ZW', 'default', '4020', 'Export sales of goods', '{}'::jsonb, 'income', false, null, 930),
  ('ZW', 'default', '4030', 'Export of services', '{}'::jsonb, 'income', false, null, 940),
  ('ZW', 'default', '4040', 'Sales of goods — foreign currency', '{}'::jsonb, 'income', false, null, 950),
  ('ZW', 'default', '4050', 'Services rendered — foreign currency', '{}'::jsonb, 'income', false, null, 960),
  ('ZW', 'default', '4500', 'Interest income', '{}'::jsonb, 'income_other', false, null, 970),
  ('ZW', 'default', '4510', 'Dividend income', '{}'::jsonb, 'income_other', false, null, 980),
  ('ZW', 'default', '4520', 'Rental income — residential lease', '{}'::jsonb, 'income_other', false, null, 990),
  ('ZW', 'default', '4530', 'Government grants', '{}'::jsonb, 'income_other', false, null, 1000),
  ('ZW', 'default', '4700', 'Foreign exchange gains', '{}'::jsonb, 'income_other', false, null, 1010),
  ('ZW', 'default', '4750', 'Gain on disposal of property plant and equipment', '{}'::jsonb, 'income_other', false, null, 1020),
  ('ZW', 'default', '4790', 'Other income', '{}'::jsonb, 'income_other', false, null, 1030),
  ('ZW', 'default', '5000', 'Purchases of goods for resale', '{}'::jsonb, 'expense_direct_cost', false, null, 1040),
  ('ZW', 'default', '5010', 'Freight inwards and import duties', '{}'::jsonb, 'expense_direct_cost', false, null, 1050),
  ('ZW', 'default', '5020', 'Subcontract costs', '{}'::jsonb, 'expense_direct_cost', false, null, 1060),
  ('ZW', 'default', '5100', 'Changes in inventories', '{}'::jsonb, 'expense_direct_cost', false, null, 1070),
  ('ZW', 'default', '6000', 'Salaries and wages', '{}'::jsonb, 'expense', false, null, 1080),
  ('ZW', 'default', '6010', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 1090),
  ('ZW', 'default', '6020', 'Directors'' fees', '{}'::jsonb, 'expense', false, null, 1100),
  ('ZW', 'default', '6030', 'NSSA contributions — employer', '{}'::jsonb, 'expense', false, null, 1110),
  ('ZW', 'default', '6040', 'ZIMDEF levy — expense', '{}'::jsonb, 'expense', false, null, 1120),
  ('ZW', 'default', '6050', 'Workers compensation insurance (NSSA)', '{}'::jsonb, 'expense', false, null, 1130),
  ('ZW', 'default', '6060', 'Staff welfare', '{}'::jsonb, 'expense', false, null, 1140),
  ('ZW', 'default', '6070', 'Staff medical expenses and insurance', '{}'::jsonb, 'expense', false, null, 1150),
  ('ZW', 'default', '6080', 'Staff training', '{}'::jsonb, 'expense', false, null, 1160),
  ('ZW', 'default', '6200', 'Depreciation of property plant and equipment', '{}'::jsonb, 'expense_depreciation', false, null, 1170),
  ('ZW', 'default', '6210', 'Depreciation of right-of-use assets', '{}'::jsonb, 'expense_depreciation', false, null, 1180),
  ('ZW', 'default', '6220', 'Amortisation of intangible assets', '{}'::jsonb, 'expense_depreciation', false, null, 1190),
  ('ZW', 'default', '6300', 'Rent — short-term leases', '{}'::jsonb, 'expense', false, null, 1200),
  ('ZW', 'default', '6310', 'Utilities', '{}'::jsonb, 'expense', false, null, 1210),
  ('ZW', 'default', '6320', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 1220),
  ('ZW', 'default', '6330', 'Cleaning and security services', '{}'::jsonb, 'expense', false, null, 1230),
  ('ZW', 'default', '6340', 'Telephone and internet', '{}'::jsonb, 'expense', false, null, 1240),
  ('ZW', 'default', '6350', 'Software subscriptions', '{}'::jsonb, 'expense', false, null, 1250),
  ('ZW', 'default', '6360', 'Advertising and marketing', '{}'::jsonb, 'expense', false, null, 1260),
  ('ZW', 'default', '6370', 'Travelling', '{}'::jsonb, 'expense', false, null, 1270),
  ('ZW', 'default', '6380', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1280),
  ('ZW', 'default', '6390', 'Entertainment', '{}'::jsonb, 'expense', false, null, 1290),
  ('ZW', 'default', '6400', 'Subscriptions and memberships', '{}'::jsonb, 'expense', false, null, 1300),
  ('ZW', 'default', '6410', 'Insurance', '{}'::jsonb, 'expense', false, null, 1310),
  ('ZW', 'default', '6420', 'Professional fees', '{}'::jsonb, 'expense', false, null, 1320),
  ('ZW', 'default', '6430', 'Audit fees', '{}'::jsonb, 'expense', false, null, 1330),
  ('ZW', 'default', '6440', 'Company secretarial and registration fees', '{}'::jsonb, 'expense', false, null, 1340),
  ('ZW', 'default', '6450', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1350),
  ('ZW', 'default', '6455', 'Intermediated money transfer tax (IMTT)', '{}'::jsonb, 'expense', false, null, 1360),
  ('ZW', 'default', '6460', 'Printing and stationery', '{}'::jsonb, 'expense', false, null, 1370),
  ('ZW', 'default', '6470', 'Postage and courier', '{}'::jsonb, 'expense', false, null, 1380),
  ('ZW', 'default', '6480', 'Licences permits and local government fees', '{}'::jsonb, 'expense', false, null, 1390),
  ('ZW', 'default', '6485', 'Stamp duty', '{}'::jsonb, 'expense', false, null, 1400),
  ('ZW', 'default', '6490', 'Royalties', '{}'::jsonb, 'expense', false, null, 1410),
  ('ZW', 'default', '6500', 'Bad debts written off', '{}'::jsonb, 'expense', false, null, 1420),
  ('ZW', 'default', '6510', 'Impairment loss on trade receivables', '{}'::jsonb, 'expense', false, null, 1430),
  ('ZW', 'default', '6520', 'Irrecoverable VAT on imported services', '{}'::jsonb, 'expense', false, null, 1440),
  ('ZW', 'default', '6530', 'Irrecoverable input VAT', '{}'::jsonb, 'expense', false, null, 1450),
  ('ZW', 'default', '6900', 'Donations', '{}'::jsonb, 'expense', false, null, 1460),
  ('ZW', 'default', '6950', 'Foreign exchange losses', '{}'::jsonb, 'expense', false, null, 1470),
  ('ZW', 'default', '6960', 'Loss on disposal of property plant and equipment', '{}'::jsonb, 'expense', false, null, 1480),
  ('ZW', 'default', '6990', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1490),
  ('ZW', 'default', '7000', 'Interest on bank loans', '{}'::jsonb, 'expense', false, null, 1500),
  ('ZW', 'default', '7010', 'Interest on lease liabilities', '{}'::jsonb, 'expense', false, null, 1510),
  ('ZW', 'default', '7020', 'Hire purchase interest', '{}'::jsonb, 'expense', false, null, 1520),
  ('ZW', 'default', '7030', 'Interest on loans from related parties and others', '{}'::jsonb, 'expense', false, null, 1530),
  ('ZW', 'default', '8000', 'Current income tax expense', '{}'::jsonb, 'expense', false, null, 1540),
  ('ZW', 'default', '8005', 'AIDS levy on income tax', '{}'::jsonb, 'expense', false, null, 1550),
  ('ZW', 'default', '8010', 'Deferred tax expense', '{}'::jsonb, 'expense', false, null, 1560),
  ('ZW', 'default', '8020', 'Under or over provision of income tax in prior years', '{}'::jsonb, 'expense', false, null, 1570)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('ZW', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('ZW', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('ZW', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('ZW', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('ZW', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('ZW', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('ZW', 'ZW-P-15', 'Purchase, standard rate 15 %, deductible (to 31 December 2025)', '{}'::jsonb, 'A local purchase whose time of supply fell before 1 January 2026', 'percent', 15, 'purchase', 'domestic', date '2023-01-01', date '2025-12-31', 'Finance Act [Chapter 23:04], Schedule to Chapter IV, Part I, as it read from 1 January 2023 to 31 December 2025 — "fifteen per centum", replaced by fifteen comma five per centum from 1 January 2026 (Finance Act, 2025, s. 34). ZIMRA Public Notice No. 7 of 2026 confirms the 15 % for December 2025 and for any supply whose time of supply under s. 8 of the Value Added Tax Act fell on or before 31 December 2025. The 2023 start date is the Finance (No. 2) Act, 2022, which this pack did not open; it is recorded from ZIMRA''s own notice on the change, and the code is closed, kept so that a document dated 2025 is taxed at the rate of its own date. Input tax on line 21 of the VAT 7 return.', null, null, 115, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'public-notice-7-2026', null, null, null, null),
  ('ZW', 'ZW-P-15-T', 'Purchase, 15 % — supply made in 2025, accounted for in 2026', '{}'::jsonb, 'A purchase whose time of supply fell on or before 31 December 2025, or a credit or debit note received on it, booked in a 2026 period', 'percent', 15, 'purchase', 'domestic', date '2026-01-01', null, 'ZIMRA Public Notice No. 7 of 2026, item 2, repeated in Public Notice No. 11 of 2026: a registered operator deemed by s. 8 of the Value Added Tax Act [Chapter 23:12] (time of supply) to have made a supply on or before 31 December 2025 at 15 %, and required to account for the output tax in a 2026 tax period, accounts for it at 15 % and grosses the value up on the TaRMS return, which is configured at 15.5 %. The same rate follows a credit or debit note issued in 2026 on such a supply (s. 21: the adjustment corrects the tax actually charged). The code is open because the notice sets no end; it is not a rate for a supply made in 2026. Input tax on line 21, credit and debit notes on line 29.', null, null, 116, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'public-notice-7-2026', null, null, null, null),
  ('ZW', 'ZW-P-15.5', 'Purchase, standard rate 15.5 %, deductible', '{}'::jsonb, 'A local purchase at the general rate, acquired to make taxable supplies, on a valid fiscal tax invoice', 'percent', 15.5, 'purchase', 'domestic', date '2026-01-01', null, 'Value Added Tax Act [Chapter 23:12], s. 15 — the tax payable for a period is output tax less input tax; s. 2(1), "tax invoice", as substituted by the Finance Act, 2025, s. 35 — input tax is claimed on a fiscal tax invoice printed by a fiscal device, whose details match what was transmitted to the Fiscalisation Data Management System and which shows valid on its validation portal. Declared on line 21 of the VAT 7 return. From 1 January 2026 ZIMRA fills the input tax schedule from the FDMS (Public Notice No. 63 of 2025) and refuses an invoice that does not show "Valid" with the buyer''s details (Public Notice No. 11 of 2026).', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'finance-act-2025', null, null, null, null),
  ('ZW', 'ZW-P-15.5-CAP', 'Purchase of a capital good, 15.5 %, deductible', '{}'::jsonb, 'A local purchase of a capital good used to make taxable supplies', 'percent', 15.5, 'purchase', 'domestic', date '2026-01-01', null, 'Value Added Tax Act [Chapter 23:12], s. 15, and the rate of the Finance Act, 2025, s. 34. The VAT 7 return declares domestic capital goods purchased to make taxable supplies on their own line, 24(a), apart from other domestic purchases (line 21).', null, null, 118, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat7-return', null, null, null, null),
  ('ZW', 'ZW-P-15.5-ND', 'Purchase, standard rate 15.5 %, input tax not deductible', '{}'::jsonb, 'Entertainment, and the other goods and services whose input tax s. 16(2) of the Act refuses', 'percent', 15.5, 'purchase', 'domestic', date '2026-01-01', null, 'Value Added Tax Act [Chapter 23:12], s. 16(2) — notwithstanding anything else in the Act, a registered operator may not deduct input tax on goods or services acquired for entertainment, unless it supplies entertainment for a consideration in the ordinary course of its trade, nor on the other items the subsection lists. The tax follows the expense to account 6530 and reaches no line of the return.', null, null, 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('ZW', 'ZW-P-EX', 'Purchase, exempt (local)', '{}'::jsonb, 'Bank charges, insurance, residential rent and the other exempt supplies bought locally', 'percent', 0, 'purchase', 'exempt', date '2004-01-01', null, 'Value Added Tax Act [Chapter 23:12], s. 11 — the supply is exempt, so there is no input tax. Declared on line 25 of the VAT 7 return, "Exempt Purchases — Local".', null, null, 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat7-return', null, null, null, null),
  ('ZW', 'ZW-P-IMP', 'Import of goods, VAT paid at the border', '{}'::jsonb, 'VAT on goods entered for home consumption, collected by ZIMRA customs and claimed as input tax on the bill of entry', 'percent', 15.5, 'purchase', 'import', date '2026-01-01', null, 'Value Added Tax Act [Chapter 23:12], s. 6(1)(b) and (2)(b) — tax is charged on the importation of goods and paid by the importer; s. 12(2) — on their customs value plus any duty other than surtax; s. 12(5) — collected under the Customs and Excise Act; s. 38(4)(b) — an operator who imports goods pays the tax in foreign currency. Input tax for a registered operator (s. 2(1), "input tax", (a)(ii)), declared on line 23 of the VAT 7 return, filled by hand from the bill of entry (Public Notice No. 63 of 2025). The tax is owed to ZIMRA at the border and not to the supplier, so it waits on 2125 until the bill of entry is paid.', null, null, 150, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('ZW', 'ZW-P-IMP-CAP', 'Import of a capital good, VAT paid at the border', '{}'::jsonb, 'VAT on a capital good imported to make taxable supplies', 'percent', 15.5, 'purchase', 'import', date '2026-01-01', null, 'Value Added Tax Act [Chapter 23:12], s. 6(1)(b) and s. 12 as for ZW-P-IMP; line 24 of the VAT 7 return, "Imported Capital Goods to make taxable supplies", filled by hand (Public Notice No. 63 of 2025). The deferment of s. 12A for approved capital goods is not modelled.', null, null, 155, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat7-return', null, null, null, null),
  ('ZW', 'ZW-P-RC-SVC', 'Imported service, tax paid by the recipient and claimed back', '{}'::jsonb, 'A service supplied by a non-resident and used in Zimbabwe: the recipient declares and pays the tax, then deducts it as input tax', 'percent', 15.5, 'purchase', 'foreign_services_received', date '2026-01-01', null, 'Value Added Tax Act [Chapter 23:12], s. 6(1)(c) and (2)(c) — tax is charged on the supply of imported services and paid by the recipient; s. 2(1), "imported services" — a supply by a non-resident to a resident to the extent it is used or consumed in Zimbabwe; s. 13(1) and (2) — declared and paid within thirty days of the earlier of the invoice and the payment; s. 13(6), inserted by the Finance Act, 2025, s. 43 — paid in United States dollars; s. 2(1), "input tax", (a)(iii), inserted by Act 3 of 2019 — the tax the operator pays on imported services is input tax. Output on line 13 of the VAT 7 return; the deduction is the TaRMS field "VAT on Imported Services", filled by hand (Public Notice No. 63 of 2025). Electronic services from a non-resident platform are charged under s. 13A and the digital services withholding tax, not here.', null, null, 160, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('ZW', 'ZW-P-Z', 'Purchase, zero-rated (local)', '{}'::jsonb, 'A local purchase charged at zero per centum by a registered operator', 'percent', 0, 'purchase', 'domestic', date '2004-01-01', null, 'Value Added Tax Act [Chapter 23:12], s. 10 — no input tax arises on a supply charged at zero per centum. Declared on line 21(a) of the VAT 7 return, "Domestic goods and/or services purchased to make taxable supplies at 0 %".', null, null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat7-return', null, null, null, null),
  ('ZW', 'ZW-S-15', 'Sale, standard rate 15 % (to 31 December 2025)', '{}'::jsonb, 'The general rate before 1 January 2026, for a supply whose time of supply fell in 2025 or earlier', 'percent', 15, 'sale', 'domestic', date '2023-01-01', date '2025-12-31', 'Finance Act [Chapter 23:04], Schedule to Chapter IV, Part I, as it read from 1 January 2023 to 31 December 2025 — "fifteen per centum", replaced by fifteen comma five per centum from 1 January 2026 (Finance Act, 2025, s. 34). ZIMRA Public Notice No. 7 of 2026 confirms the 15 % for December 2025 and for any supply whose time of supply under s. 8 of the Value Added Tax Act fell on or before 31 December 2025. The 2023 start date is the Finance (No. 2) Act, 2022, which this pack did not open; it is recorded from ZIMRA''s own notice on the change, and the code is closed, kept so that a document dated 2025 is taxed at the rate of its own date.', 'S', null, 15, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'public-notice-7-2026', null, null, null, null),
  ('ZW', 'ZW-S-15-T', 'Sale, 15 % — supply made in 2025, accounted for in 2026', '{}'::jsonb, 'A supply whose time of supply fell on or before 31 December 2025, or a credit or debit note on it, booked in a 2026 period', 'percent', 15, 'sale', 'domestic', date '2026-01-01', null, 'ZIMRA Public Notice No. 7 of 2026, item 2, repeated in Public Notice No. 11 of 2026: a registered operator deemed by s. 8 of the Value Added Tax Act [Chapter 23:12] (time of supply) to have made a supply on or before 31 December 2025 at 15 %, and required to account for the output tax in a 2026 tax period, accounts for it at 15 % and grosses the value up on the TaRMS return, which is configured at 15.5 %. The same rate follows a credit or debit note issued in 2026 on such a supply (s. 21: the adjustment corrects the tax actually charged). The code is open because the notice sets no end; it is not a rate for a supply made in 2026.', 'S', null, 16, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'public-notice-7-2026', null, null, null, null),
  ('ZW', 'ZW-S-15.5', 'Sale, standard rate 15.5 %', '{}'::jsonb, 'The general rate on a taxable supply of goods or services by a registered operator, from 1 January 2026', 'percent', 15.5, 'sale', 'domestic', date '2026-01-01', null, 'Finance Act [Chapter 23:04], Schedule to Chapter IV, Part I ("General Rate of Value Added Tax"), as amended by section 34 of the Finance Act, 2025 (Act No. 7 of 2025) with effect from 1 January 2026: "fifteen comma five per centum" replaces "fifteen per centum". Value Added Tax Act [Chapter 23:12], s. 6(1)(a) charges tax at the rate the Charging Act fixes on the value of every supply of goods or services by a registered operator in the course or furtherance of a trade; ZIMRA Public Notice No. 7 of 2026 applies 15.5 % to Categories A, B, C and D from 1 January 2026 and keeps 15 % for supplies whose time of supply fell on or before 31 December 2025.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'finance-act-2025', null, null, null, null),
  ('ZW', 'ZW-S-EX', 'Sale, exempt', '{}'::jsonb, 'Financial services, residential letting, fare-paying passenger transport, education, medical services, and the goods the First Schedule to the VAT (General) Regulations exempts', 'percent', 0, 'sale', 'exempt', date '2004-01-01', null, 'Value Added Tax Act [Chapter 23:12], s. 11 — exempt from the tax of s. 6(1)(a): (a) financial services, other than short-term insurance commission; (c) accommodation in a dwelling let under an agreement; (d) leasehold land let for residential use; (f) transport of fare-paying passengers by road or rail; (g) pre-school, primary, secondary, university and technical education in a registered institution; (h) medical services; (i) services of an employee organisation for membership contributions; (j) the goods and services prescribed by regulations — the First Schedule to the Value Added Tax (General) Regulations, 2003, substituted by Statutory Instrument 15 of 2024, which lists the exempt basic commodities; and from 1 January 2026 (Finance Act, 2025, s. 38) (k) prescribed agricultural goods and services, (l) prescribed medicines and allied substances and (m) rural electrification funded by the Rural Electrification Fund. An exempt supply gives no right to deduct input tax. Declared on line 12 of the VAT 7 return.', 'E', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('ZW', 'ZW-S-Z-DOM', 'Sale, zero-rated (local)', '{}'::jsonb, 'A local supply the Act zero-rates without it leaving Zimbabwe: gold bars to the Reserve Bank or a registered bank, gold coins, and the services of s. 10(2) supplied locally', 'percent', 0, 'sale', 'domestic', date '2004-01-01', null, 'Value Added Tax Act [Chapter 23:12], s. 10(1)(f) — gold in bars, ingots, granules and similar unworked forms supplied to the Reserve Bank or a registered bank; s. 10(1)(i) — gold coins issued by the Reserve Bank; s. 10(2)(g)(iv) and (h) — the repair and handling of foreign-going aircraft, and the other services of s. 10(2) supplied in Zimbabwe. Declared on line 10 of the VAT 7 return, "Supply of goods and/or services at 0 % — Local". From 1 January 2026 the Finance Act, 2025, s. 37, repealed the zero rate of agricultural goods and services (s. 10(1)(g)), of prescribed medicines (s. 10(1)(j)) and of designated tourist facilities (s. 10(2)(q)), and narrowed the going-concern zero rate (s. 10(1)(e)) to a transfer to the Public Service Pension Fund: those supplies take ZW-S-EX (agricultural goods and medicines, now s. 11(k) and (l)) or the standard rate.', 'Z', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'finance-act-2025', null, null, null, null),
  ('ZW', 'ZW-S-Z-EXP', 'Sale, zero-rated (export)', '{}'::jsonb, 'Movable goods exported by the supplier, international transport, and services supplied to a non-resident outside Zimbabwe', 'percent', 0, 'sale', 'export', date '2004-01-01', null, 'Value Added Tax Act [Chapter 23:12], s. 10(1)(a) — movable goods supplied under a sale or instalment credit agreement and exported by the supplier are charged at zero per centum; s. 10(2)(a), (e), (k) and (l) — international transport of passengers or goods, transport and ancillary services supplied directly to a non-resident in connection with an export or import, and services supplied to a non-resident who is outside Zimbabwe when they are rendered; s. 10(3) — the operator keeps documentary proof acceptable to the Commissioner. Declared on line 10(a) of the VAT 7 return, "Supply of goods and/or services at 0 % — Exports". The export taxes of ss. 12B to 12J on unbeneficiated minerals, hides and similar goods are not this code and are not carried by the pack.', 'G', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null)
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
    ('ZW-P-15', 'invoice', 'base', 100, null, '21', array['21']::text[], 100, 'ZW-VAT7', 10),
    ('ZW-P-15', 'invoice', 'tax', 100, '1150', '21', array['21']::text[], 100, 'ZW-VAT7', 20),
    ('ZW-P-15', 'credit_note', 'base', 100, null, '29', array['29']::text[], -100, 'ZW-VAT7', 10),
    ('ZW-P-15', 'credit_note', 'tax', 100, '1150', '29', array['29']::text[], -100, 'ZW-VAT7', 20),
    ('ZW-P-15-T', 'invoice', 'base', 100, null, '21', array['21']::text[], 100, 'ZW-VAT7', 10),
    ('ZW-P-15-T', 'invoice', 'tax', 100, '1150', '21', array['21']::text[], 100, 'ZW-VAT7', 20),
    ('ZW-P-15-T', 'credit_note', 'base', 100, null, '29', array['29']::text[], -100, 'ZW-VAT7', 10),
    ('ZW-P-15-T', 'credit_note', 'tax', 100, '1150', '29', array['29']::text[], -100, 'ZW-VAT7', 20),
    ('ZW-P-15.5', 'invoice', 'base', 100, null, '21', array['21']::text[], 100, 'ZW-VAT7', 10),
    ('ZW-P-15.5', 'invoice', 'tax', 100, '1150', '21', array['21']::text[], 100, 'ZW-VAT7', 20),
    ('ZW-P-15.5', 'credit_note', 'base', 100, null, '29', array['29']::text[], -100, 'ZW-VAT7', 10),
    ('ZW-P-15.5', 'credit_note', 'tax', 100, '1150', '29', array['29']::text[], -100, 'ZW-VAT7', 20),
    ('ZW-P-15.5-CAP', 'invoice', 'base', 100, null, '24A', array['24A']::text[], 100, 'ZW-VAT7', 10),
    ('ZW-P-15.5-CAP', 'invoice', 'tax', 100, '1150', '24A', array['24A']::text[], 100, 'ZW-VAT7', 20),
    ('ZW-P-15.5-CAP', 'credit_note', 'base', 100, null, '29', array['29']::text[], -100, 'ZW-VAT7', 10),
    ('ZW-P-15.5-CAP', 'credit_note', 'tax', 100, '1150', '29', array['29']::text[], -100, 'ZW-VAT7', 20),
    ('ZW-P-15.5-ND', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('ZW-P-15.5-ND', 'invoice', 'tax', 100, '6530', null, null, 100, null, 20),
    ('ZW-P-15.5-ND', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('ZW-P-15.5-ND', 'credit_note', 'tax', 100, '6530', null, null, 100, null, 20),
    ('ZW-P-EX', 'invoice', 'base', 100, null, '25', array['25']::text[], 100, 'ZW-VAT7', 10),
    ('ZW-P-EX', 'credit_note', 'base', 100, null, '25', array['25']::text[], -100, 'ZW-VAT7', 10),
    ('ZW-P-IMP', 'invoice', 'base', 100, null, '23', array['23']::text[], 100, 'ZW-VAT7', 10),
    ('ZW-P-IMP', 'invoice', 'tax', 100, '1150', '23', array['23']::text[], 100, 'ZW-VAT7', 20),
    ('ZW-P-IMP', 'invoice', 'tax', -100, '2125', null, null, 100, null, 30),
    ('ZW-P-IMP', 'credit_note', 'base', 100, null, '23', array['23']::text[], -100, 'ZW-VAT7', 10),
    ('ZW-P-IMP', 'credit_note', 'tax', 100, '1150', '23', array['23']::text[], -100, 'ZW-VAT7', 20),
    ('ZW-P-IMP', 'credit_note', 'tax', -100, '2125', null, null, 100, null, 30),
    ('ZW-P-IMP-CAP', 'invoice', 'base', 100, null, '24', array['24']::text[], 100, 'ZW-VAT7', 10),
    ('ZW-P-IMP-CAP', 'invoice', 'tax', 100, '1150', '24', array['24']::text[], 100, 'ZW-VAT7', 20),
    ('ZW-P-IMP-CAP', 'invoice', 'tax', -100, '2125', null, null, 100, null, 30),
    ('ZW-P-IMP-CAP', 'credit_note', 'base', 100, null, '24', array['24']::text[], -100, 'ZW-VAT7', 10),
    ('ZW-P-IMP-CAP', 'credit_note', 'tax', 100, '1150', '24', array['24']::text[], -100, 'ZW-VAT7', 20),
    ('ZW-P-IMP-CAP', 'credit_note', 'tax', -100, '2125', null, null, 100, null, 30),
    ('ZW-P-RC-SVC', 'invoice', 'base', 100, null, '13', array['13']::text[], 100, 'ZW-VAT7', 10),
    ('ZW-P-RC-SVC', 'invoice', 'tax', -100, '2100', '13', array['13']::text[], 100, 'ZW-VAT7', 20),
    ('ZW-P-RC-SVC', 'invoice', 'tax', 100, '1150', 'IMS', array['IMS']::text[], 100, 'ZW-VAT7', 30),
    ('ZW-P-RC-SVC', 'credit_note', 'base', 100, null, '13', array['13']::text[], -100, 'ZW-VAT7', 10),
    ('ZW-P-RC-SVC', 'credit_note', 'tax', -100, '2100', '13', array['13']::text[], -100, 'ZW-VAT7', 20),
    ('ZW-P-RC-SVC', 'credit_note', 'tax', 100, '1150', 'IMS', array['IMS']::text[], -100, 'ZW-VAT7', 30),
    ('ZW-P-Z', 'invoice', 'base', 100, null, '21A', array['21A']::text[], 100, 'ZW-VAT7', 10),
    ('ZW-P-Z', 'credit_note', 'base', 100, null, '21A', array['21A']::text[], -100, 'ZW-VAT7', 10),
    ('ZW-S-15', 'invoice', 'base', 100, null, '9', array['9']::text[], 100, 'ZW-VAT7', 10),
    ('ZW-S-15', 'invoice', 'tax', 100, '2100', '9', array['9']::text[], 100, 'ZW-VAT7', 20),
    ('ZW-S-15', 'credit_note', 'base', 100, null, '18', array['18']::text[], -100, 'ZW-VAT7', 10),
    ('ZW-S-15', 'credit_note', 'tax', 100, '2100', '18', array['18']::text[], -100, 'ZW-VAT7', 20),
    ('ZW-S-15-T', 'invoice', 'base', 100, null, '9', array['9']::text[], 100, 'ZW-VAT7', 10),
    ('ZW-S-15-T', 'invoice', 'tax', 100, '2100', '9', array['9']::text[], 100, 'ZW-VAT7', 20),
    ('ZW-S-15-T', 'credit_note', 'base', 100, null, '18', array['18']::text[], -100, 'ZW-VAT7', 10),
    ('ZW-S-15-T', 'credit_note', 'tax', 100, '2100', '18', array['18']::text[], -100, 'ZW-VAT7', 20),
    ('ZW-S-15.5', 'invoice', 'base', 100, null, '9', array['9']::text[], 100, 'ZW-VAT7', 10),
    ('ZW-S-15.5', 'invoice', 'tax', 100, '2100', '9', array['9']::text[], 100, 'ZW-VAT7', 20),
    ('ZW-S-15.5', 'credit_note', 'base', 100, null, '18', array['18']::text[], -100, 'ZW-VAT7', 10),
    ('ZW-S-15.5', 'credit_note', 'tax', 100, '2100', '18', array['18']::text[], -100, 'ZW-VAT7', 20),
    ('ZW-S-EX', 'invoice', 'base', 100, null, '12', array['12']::text[], 100, 'ZW-VAT7', 10),
    ('ZW-S-EX', 'credit_note', 'base', 100, null, '12', array['12']::text[], -100, 'ZW-VAT7', 10),
    ('ZW-S-Z-DOM', 'invoice', 'base', 100, null, '10', array['10']::text[], 100, 'ZW-VAT7', 10),
    ('ZW-S-Z-DOM', 'credit_note', 'base', 100, null, '10', array['10']::text[], -100, 'ZW-VAT7', 10),
    ('ZW-S-Z-EXP', 'invoice', 'base', 100, null, '10A', array['10A']::text[], 100, 'ZW-VAT7', 10),
    ('ZW-S-Z-EXP', 'credit_note', 'base', 100, null, '10A', array['10A']::text[], -100, 'ZW-VAT7', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'ZW' and t.code = v.tax_code
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
  ('ZW', 'ZW-VAT7', 'VAT 7 — Return for Remittance of Value Added Tax', array['month', 'bimonth']::declaration_period[], null, date '2023-09-05', null, 'Value Added Tax Act [Chapter 23:12], s. 27 — the tax period depends on the operator''s category: Category A, two months ending in January, March, May, July, September and November; Category B, two months ending in February, April, June, August, October and December; Category C, one month, compulsory when taxable supplies exceed US$240,000 in twelve months or on request; Category D, farming operators with other approved periods. s. 28(1) — a return in the prescribed form, the VAT 7, is furnished for every period whether or not tax is payable. `bimonth` is anchored on January–February, which is Category B; a Category A operator (December–January, February–March…) is not expressible by this format and is recorded in the README. The category is ZIMRA''s decision about the operator, so no period_default is declared and `ekwo init` asks.', true,'day_of_month_after_period'::filing_deadline_rule, 10, null, 'Finance (Due Dates for Submission of Returns and References to the Zimbabwe Dollar) Regulations, 2025 (Statutory Instrument 81 of 2025), as applied by ZIMRA Public Notice No. 11 of 2026: the VAT return is due on or before the 10th of the month after the tax period and the payment on or before the 15th. This overrides the twenty-fifth day of s. 28(1) of the Value Added Tax Act. The payment day (15th) is not carried by the format, which holds one deadline per form.', 'public-notice-11-2026', null)
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
  ('ZW', 'ZW-VAT7', '9', 'base', 'Line 9 — Supply of goods and/or services at standard rate — value of supply', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT 7 return (ZIMRA form DTF 98, issue 3, version 2, 5 September 2023), Part II, line 9 (office use code V09): value of supply of goods and services charged at the standard rate; credit and debit notes on those supplies are declared on line 18, not netted here.', 'vat7-return'),
  ('ZW', 'ZW-VAT7', '9', 'tax', 'Line 9 — Supply of goods and/or services at standard rate — output tax', '{}'::jsonb, 15, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT 7 return (ZIMRA form DTF 98, issue 3, version 2, 5 September 2023), Part II, line 9: output tax on standard-rated supplies. Since the TaRMS configuration of the return for periods from January 2026 computes this line at 15.5 %, a period mixing 2025 and 2026 supplies is grossed up as ZIMRA Public Notice No. 7 of 2026 explains; the pack reports the tax as booked.', 'vat7-return'),
  ('ZW', 'ZW-VAT7', '10', 'base', 'Line 10 — Supply of goods and/or services at 0 % — local', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT 7 return (ZIMRA form DTF 98, issue 3, version 2, 5 September 2023), Part II, line 10 (V12): zero-rated supplies made in Zimbabwe (Value Added Tax Act, s. 10).', 'vat7-return'),
  ('ZW', 'ZW-VAT7', '10A', 'base', 'Line 10(a) — Supply of goods and/or services at 0 % — exports', '{}'::jsonb, 25, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT 7 return (ZIMRA form DTF 98, issue 3, version 2, 5 September 2023), Part II, line 10.a (V12): zero-rated exports of goods and services (Value Added Tax Act, s. 10(1)(a) and (2)).', 'vat7-return'),
  ('ZW', 'ZW-VAT7', '12', 'base', 'Line 12 — Exempt supplies', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT 7 return (ZIMRA form DTF 98, issue 3, version 2, 5 September 2023), Part II, line 12 (V18): exempt supplies (Value Added Tax Act, s. 11).', 'vat7-return'),
  ('ZW', 'ZW-VAT7', '13', 'base', 'Line 13 — Imported services — value', '{}'::jsonb, 35, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT 7 return (ZIMRA form DTF 98, issue 3, version 2, 5 September 2023), Part II, line 13 (V19): the value of imported services, to which the standard rate is applied (Value Added Tax Act, s. 6(1)(c) and s. 13).', 'vat7-return'),
  ('ZW', 'ZW-VAT7', '13', 'tax', 'Line 13 — Imported services — output tax', '{}'::jsonb, 36, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT 7 return (ZIMRA form DTF 98, issue 3, version 2, 5 September 2023), Part II, line 13: the tax on imported services, at the standard rate. Section 13(1) of the Act also lets it be declared and paid within thirty days on the imported-services variant of the same form; the pack puts it on the period''s return.', 'vat7-return'),
  ('ZW', 'ZW-VAT7', '18', 'base', 'Line 18 — Debit/credit notes issued — value', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT 7 return (ZIMRA form DTF 98, issue 3, version 2, 5 September 2023), Part II, adjustments, line 18 (V30): debit and credit notes on supplies (Value Added Tax Act, s. 21). The form asks the consideration including VAT and applies the tax fraction; this row holds the value excluding VAT, so the consideration is this row plus the tax row.', 'vat7-return'),
  ('ZW', 'ZW-VAT7', '18', 'tax', 'Line 18 — Debit/credit notes issued — tax', '{}'::jsonb, 45, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT 7 return (ZIMRA form DTF 98, issue 3, version 2, 5 September 2023), Part II, line 18: the tax fraction of debit and credit notes issued; a credit note reduces output tax.', 'vat7-return'),
  ('ZW', 'ZW-VAT7', '20', 'total', 'Line 20 — Total output tax [A]', '{}'::jsonb, 50, null, array['9:tax', '13:tax', '18:tax']::text[], '{}'::text[], null, null, false, false, null, 'VAT 7 return (ZIMRA form DTF 98, issue 3, version 2, 5 September 2023), Part II, line 20, total output tax [A]. The adjustments of lines 14 to 17 and 19 (sale in execution of a debt, change of use, bad debts recovered, motoring fringe benefits) are not posted by any tax of this pack and are entered by hand.', 'vat7-return'),
  ('ZW', 'ZW-VAT7', '21', 'base', 'Line 21 — Domestic purchases at standard rate — value', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT 7 return (ZIMRA form DTF 98, issue 3, version 2, 5 September 2023), Part III, line 21 (V39): domestic goods and services purchased to make taxable supplies at the standard rate, on valid fiscal tax invoices.', 'vat7-return'),
  ('ZW', 'ZW-VAT7', '21', 'tax', 'Line 21 — Domestic purchases at standard rate — input tax', '{}'::jsonb, 65, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT 7 return (ZIMRA form DTF 98, issue 3, version 2, 5 September 2023), Part III, line 21: input tax on those purchases. From the return due 10 January 2026 TaRMS fills it from the fiscal tax invoices transmitted to the FDMS (Public Notice No. 63 of 2025).', 'vat7-return'),
  ('ZW', 'ZW-VAT7', '21A', 'base', 'Line 21(a) — Domestic purchases at 0 % — value', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT 7 return (ZIMRA form DTF 98, issue 3, version 2, 5 September 2023), Part III, line 21a (V39): domestic goods and services purchased at 0 %.', 'vat7-return'),
  ('ZW', 'ZW-VAT7', '23', 'base', 'Line 23 — Imported goods at standard rate (excluding capital goods) — value', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT 7 return (ZIMRA form DTF 98, issue 3, version 2, 5 September 2023), Part III, line 23 (V42): imported goods to make taxable supplies, excluding capital goods, at the standard rate — the value on the bill of entry.', 'vat7-return'),
  ('ZW', 'ZW-VAT7', '23', 'tax', 'Line 23 — Imported goods at standard rate — input tax', '{}'::jsonb, 85, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT 7 return (ZIMRA form DTF 98, issue 3, version 2, 5 September 2023), Part III, line 23: import VAT paid to customs, filled by hand (Public Notice No. 63 of 2025).', 'vat7-return'),
  ('ZW', 'ZW-VAT7', '24', 'base', 'Line 24 — Imported capital goods — value', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT 7 return (ZIMRA form DTF 98, issue 3, version 2, 5 September 2023), Part III, line 24 (V45): imported capital goods to make taxable supplies.', 'vat7-return'),
  ('ZW', 'ZW-VAT7', '24', 'tax', 'Line 24 — Imported capital goods — input tax', '{}'::jsonb, 95, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT 7 return (ZIMRA form DTF 98, issue 3, version 2, 5 September 2023), Part III, line 24: input tax on imported capital goods, filled by hand (Public Notice No. 63 of 2025).', 'vat7-return'),
  ('ZW', 'ZW-VAT7', '24A', 'base', 'Line 24(a) — Domestic capital goods — value', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT 7 return (ZIMRA form DTF 98, issue 3, version 2, 5 September 2023), Part III, line 24a (V45): domestic capital goods purchased to make taxable supplies.', 'vat7-return'),
  ('ZW', 'ZW-VAT7', '24A', 'tax', 'Line 24(a) — Domestic capital goods — input tax', '{}'::jsonb, 105, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT 7 return (ZIMRA form DTF 98, issue 3, version 2, 5 September 2023), Part III, line 24a: input tax on domestic capital goods.', 'vat7-return'),
  ('ZW', 'ZW-VAT7', '25', 'base', 'Line 25 — Exempt purchases — local', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT 7 return (ZIMRA form DTF 98, issue 3, version 2, 5 September 2023), Part III, line 25: exempt purchases made locally. Line 25a (exempt imports) is not posted by any tax of this pack.', 'vat7-return'),
  ('ZW', 'ZW-VAT7', '29', 'base', 'Line 29 — Credit/debit notes received — value', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT 7 return (ZIMRA form DTF 98, issue 3, version 2, 5 September 2023), Part III, adjustments, line 29 (V57): credit and debit notes received on purchases; consideration including VAT on the form, value excluding VAT here.', 'vat7-return'),
  ('ZW', 'ZW-VAT7', '29', 'tax', 'Line 29 — Credit/debit notes received — tax', '{}'::jsonb, 125, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT 7 return (ZIMRA form DTF 98, issue 3, version 2, 5 September 2023), Part III, line 29: the tax fraction of credit and debit notes received; a credit note received reduces input tax.', 'vat7-return'),
  ('ZW', 'ZW-VAT7', 'IMS', 'tax', 'VAT on imported services — input tax', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'ZIMRA Public Notice No. 63 of 2025, item 2(d): "VAT on Imported Services" is an input tax field of the VAT 7 return in TaRMS, filled by hand; the paper form of 2023 has no numbered line for it. Value Added Tax Act, s. 2(1), "input tax", (a)(iii).', 'public-notice-63-2025'),
  ('ZW', 'ZW-VAT7', '30', 'total', 'Line 30 — Total input tax [B]', '{}'::jsonb, 140, null, array['21:tax', '23:tax', '24:tax', '24A:tax', '29:tax', 'IMS:tax']::text[], '{}'::text[], null, null, false, false, null, 'VAT 7 return (ZIMRA form DTF 98, issue 3, version 2, 5 September 2023), Part III, line 30, total input tax [B]. Purchases by diplomats (lines 22, 23b, 24b) and the adjustments of lines 26 to 28 (change of use, bad debts written off) are not posted by this pack.', 'vat7-return'),
  ('ZW', 'ZW-VAT7', '34', 'total', 'Line 34 — Amount payable/refundable (A − B)', '{}'::jsonb, 150, null, array['20']::text[], array['30']::text[], null, null, false, false, null, 'VAT 7 return (ZIMRA form DTF 98, issue 3, version 2, 5 September 2023), Part IV, lines 31 to 34: total output tax less total input tax. Line 33 (VAT withheld by appointed agents, credited on a certificate) and lines 35 to 39 (penalty, interest, credit brought forward) are entered on the return by hand; a positive amount is payable, a negative one refundable.', 'vat7-return')
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
   source_key)
values
  ('ZW-PAAB-IS', 'ZW', 'default', 'Statement of profit or loss', 'income_statement', 'IFRS-SME', date '2019-01-01', null, 'Companies and Other Business Entities Act [Chapter 24:31] and the standards the Public Accountants and Auditors Board prescribes (IFRS Accounting Standards; IFRS for SMEs for eligible entities). These lines are an original presentation by nature of expense that follows IAS 1 and section 5 of IFRS for SMEs (statement of profit or loss): revenue, other income, purchases and changes in inventories, employee benefits, depreciation and amortisation, other operating expenses, finance costs, profit before tax, income tax expense (income tax and the AIDS levy on it) and profit for the year.', 'ifac-zimbabwe'),
  ('ZW-PAAB-SFP', 'ZW', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS-SME', date '2019-01-01', null, 'Companies and Other Business Entities Act [Chapter 24:31] requires a company to keep accounting records and to lay annual financial statements before its members; the Public Accountants and Auditors Board (PAAB), through the Zimbabwe Accounting Practices Board, prescribes the standards they follow: IFRS Accounting Standards for publicly accountable entities and the IFRS for SMEs Accounting Standard for eligible entities, prescribed by statutory instrument (Statutory Instrument 41 of 2019, repealed and replaced by Statutory Instrument 137 of 2026, as IFAC''s profile of Zimbabwe records). Zimbabwe has no statutory format and no legal chart of accounts, so these lines are an original presentation that follows IAS 1 and section 4 of IFRS for SMEs (statement of financial position): current and non-current assets, current and non-current liabilities, net assets and equity.', 'ifac-zimbabwe')
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
  ('ZW-PAAB-IS', '1', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-IS', '2', null, 'Other income', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-IS', '3', null, 'Purchases and changes in inventories', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-IS', '4', null, 'Employee benefits expense', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-IS', '5', null, 'Depreciation and amortisation', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-IS', '6', null, 'Other operating expenses', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-IS', '7', null, 'Finance costs', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-IS', '8', null, 'Profit before tax', '{}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('ZW-PAAB-IS', '9', null, 'Income tax expense', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-IS', '10', null, 'Profit for the year', '{}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, null, null),
  ('ZW-PAAB-SFP', 'CA', null, 'Current assets', '{}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5', 'CA.6']::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'CA.1', null, 'Cash and cash equivalents', '{}'::jsonb, 11, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'CA.2', null, 'Trade and other receivables', '{}'::jsonb, 12, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'CA.3', null, 'Inventories', '{}'::jsonb, 13, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'CA.4', null, 'Financial assets', '{}'::jsonb, 14, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'CA.5', null, 'Current tax recoverable', '{}'::jsonb, 15, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'CA.6', null, 'Prepayments and accrued income', '{}'::jsonb, 16, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'NCA', null, 'Non-current assets', '{}'::jsonb, 20, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4', 'NCA.5', 'NCA.6', 'NCA.7']::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'NCA.1', null, 'Property, plant and equipment', '{}'::jsonb, 21, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'NCA.2', null, 'Investment property', '{}'::jsonb, 22, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'NCA.3', null, 'Intangible assets', '{}'::jsonb, 23, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'NCA.4', null, 'Investments in associates', '{}'::jsonb, 24, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'NCA.5', null, 'Investments in joint ventures', '{}'::jsonb, 25, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'NCA.6', null, 'Financial assets', '{}'::jsonb, 26, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'NCA.7', null, 'Deferred tax assets', '{}'::jsonb, 27, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'TA', null, 'Total assets', '{}'::jsonb, 30, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'CL', null, 'Current liabilities', '{}'::jsonb, 40, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4', 'CL.5']::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'CL.1', null, 'Trade and other payables', '{}'::jsonb, 41, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'CL.2', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 42, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'CL.3', null, 'Amounts due to directors', '{}'::jsonb, 43, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'CL.4', null, 'Current tax payable', '{}'::jsonb, 44, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'CL.5', null, 'Provisions', '{}'::jsonb, 45, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'NCL', null, 'Non-current liabilities', '{}'::jsonb, 50, 1, true, array['NCL.1', 'NCL.2', 'NCL.3']::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'NCL.1', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 51, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'NCL.2', null, 'Deferred tax liabilities', '{}'::jsonb, 52, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'NCL.3', null, 'Provisions', '{}'::jsonb, 53, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'TL', null, 'Total liabilities', '{}'::jsonb, 60, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'NA', null, 'Net assets', '{}'::jsonb, 70, 1, true, array['TA']::text[], array['TL']::text[], null, null, null),
  ('ZW-PAAB-SFP', 'EQ', null, 'Equity', '{}'::jsonb, 80, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'EQ.1', null, 'Share capital', '{}'::jsonb, 81, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'EQ.2', null, 'Other reserves', '{}'::jsonb, 82, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('ZW-PAAB-SFP', 'EQ.3', null, 'Retained earnings', '{}'::jsonb, 83, -1, false, '{}'::text[], '{}'::text[], null, null, null)
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
    ('ZW-PAAB-IS', '1', 10, 'code_range', '4000', '4050', null, 'any'),
    ('ZW-PAAB-IS', '2', 10, 'code_range', '4500', '4790', null, 'any'),
    ('ZW-PAAB-IS', '3', 10, 'code_range', '5000', '5100', null, 'any'),
    ('ZW-PAAB-IS', '4', 10, 'code_range', '6000', '6080', null, 'any'),
    ('ZW-PAAB-IS', '5', 10, 'code_range', '6200', '6220', null, 'any'),
    ('ZW-PAAB-IS', '6', 10, 'code_range', '6300', '6990', null, 'any'),
    ('ZW-PAAB-IS', '7', 10, 'code_range', '7000', '7030', null, 'any'),
    ('ZW-PAAB-IS', '9', 10, 'code_range', '8000', '8020', null, 'any'),
    ('ZW-PAAB-SFP', 'CA.1', 10, 'code_range', '1000', '1045', null, 'any'),
    ('ZW-PAAB-SFP', 'CA.2', 10, 'code_range', '1100', '1165', null, 'any'),
    ('ZW-PAAB-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('ZW-PAAB-SFP', 'CA.4', 10, 'account_code', '1300', null, null, 'any'),
    ('ZW-PAAB-SFP', 'CA.5', 10, 'code_range', '1350', '1355', null, 'any'),
    ('ZW-PAAB-SFP', 'CA.6', 10, 'code_range', '1400', '1410', null, 'any'),
    ('ZW-PAAB-SFP', 'NCA.1', 10, 'code_range', '1600', '1671', null, 'any'),
    ('ZW-PAAB-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('ZW-PAAB-SFP', 'NCA.3', 10, 'code_range', '1750', '1760', null, 'any'),
    ('ZW-PAAB-SFP', 'NCA.4', 10, 'account_code', '1800', null, null, 'any'),
    ('ZW-PAAB-SFP', 'NCA.5', 10, 'account_code', '1810', null, null, 'any'),
    ('ZW-PAAB-SFP', 'NCA.6', 10, 'code_range', '1830', '1840', null, 'any'),
    ('ZW-PAAB-SFP', 'NCA.7', 10, 'account_code', '1900', null, null, 'any'),
    ('ZW-PAAB-SFP', 'CL.1', 10, 'code_range', '2000', '2190', null, 'any'),
    ('ZW-PAAB-SFP', 'CL.1', 20, 'account_code', '2990', null, null, 'credit'),
    ('ZW-PAAB-SFP', 'CL.2', 10, 'code_range', '2200', '2240', null, 'any'),
    ('ZW-PAAB-SFP', 'CL.3', 10, 'account_code', '2250', null, null, 'any'),
    ('ZW-PAAB-SFP', 'CL.4', 10, 'account_code', '2300', null, null, 'any'),
    ('ZW-PAAB-SFP', 'CL.5', 10, 'code_range', '2350', '2360', null, 'any'),
    ('ZW-PAAB-SFP', 'NCL.1', 10, 'code_range', '2400', '2430', null, 'any'),
    ('ZW-PAAB-SFP', 'NCL.2', 10, 'account_code', '2500', null, null, 'any'),
    ('ZW-PAAB-SFP', 'NCL.3', 10, 'account_code', '2550', null, null, 'any'),
    ('ZW-PAAB-SFP', 'EQ.1', 10, 'code_range', '3000', '3010', null, 'any'),
    ('ZW-PAAB-SFP', 'EQ.2', 10, 'code_range', '3100', '3110', null, 'any'),
    ('ZW-PAAB-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('ZW', 'Zimbabwe', '{}'::jsonb, array['en']::text[], 'ZWG', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, null)
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
  numbering_legal_reference     = 'Value Added Tax Act [Chapter 23:12], s. 20(4)(d) — a tax invoice carries an individual serialised number and its date of issue; s. 20(1), proviso (a) — no more than one tax invoice for each taxable supply. The Act asks for a serial number, not for a series without gaps restarting each year, so `numbering` is `sequential`. The fiscal device keeps its own counters (a receipt counter per fiscal day and a global number since activation, Fiscal Device Gateway API v7.2) and the accounting system''s own number travels to the FDMS as `invoiceNo`, which must be unique for the taxpayer.',
  numbering_source_key          = 'vat-act',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Value Added Tax Act [Chapter 23:12], s. 8(1), as substituted by Act 1 of 2019 — a supply takes place at the earliest of the issue of an invoice, the receipt of a payment, the removal of a movable good, the taking of possession of an immovable good, and the performance of a service. That is a five-way earliest test; Ekwo''s closed vocabulary expresses a two-way one, and `earliest_of_delivery_or_payment` is the nearest value. An invoice issued before delivery and payment, which s. 8(1)(a) still makes the time of supply, is recorded as a gap in the README.',
  tax_point_source_key          = 'vat-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No Zimbabwean statute obliges a business to exchange a structured electronic invoice with another business in the sense Ekwo''s vocabulary gives the word: there is no Peppol authority, no published profile and no scheme a party is addressed by, so `profile`, `party_scheme` and `vat_scheme` are null and `obligation` is `none`. What Zimbabwe has instead is fiscalisation: since the Finance Act, 2025, s. 35, a tax invoice under the Value Added Tax Act is a fiscal tax invoice printed by a fiscal device (an electronic tax register, fiscal printer, signature device, fuel device or virtual fiscal device or software application approved by the Commissioner) whose details are transmitted to and signed by ZIMRA''s Fiscalisation Data Management System, and which must show valid on the FDMS validation portal. The device signs each receipt, submits it to the Fiscal Device Gateway API and prints a QR code that points to ZIMRA''s verification page (Fiscal Device Gateway API Specification v7.2). That is reporting to the tax administration from a certified device, not an exchange between two businesses; the gap is recorded in the README and in docs/international.md, and the socle is not patched to fit it.',
  einvoice_source_key           = 'fdms-api',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'ZW';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('ZW', 'not_a_fiscal_tax_invoice', 'always', 'This document is not a fiscal tax invoice: it was not printed by a fiscal device registered with the ZIMRA Fiscalisation Data Management System and carries no FDMS QR code or verification code. Only the fiscal tax invoice issued by the supplier''s fiscal device supports a claim of input tax.', '{}'::jsonb, 10, date '1970-01-01', null, 'Value Added Tax Act [Chapter 23:12], s. 2(1), "tax invoice", as substituted by the Finance Act, 2025, s. 35 — a tax invoice is a fiscal tax invoice printed by a fiscal device, whose transaction details match those transmitted to the FDMS and show valid on its validation portal; s. 20(4)(a), (h) and (i), as amended by s. 45 of the same Act from 1 January 2026 — it bears the words "fiscal tax invoice", the taxpayer identification number and a QR code or authentication code. Ekwo cannot sign a document with a fiscal device, so the sentence says what the document is not, rather than letting a buyer take it for one.'),
  ('ZW', 'export', 'export', 'Zero-rated supply under section 10 of the Value Added Tax Act [Chapter 23:12].', '{}'::jsonb, 20, date '1970-01-01', null, 'Value Added Tax Act [Chapter 23:12], s. 10(1)(a) and (2) — exports of goods and the services the subsection lists are charged at zero per centum; s. 10(3) — the operator keeps the documentary proof the Commissioner accepts. Zimbabwe is outside the European Union''s common system and carries no VATEX code, so the sentence names the section the zero rate is claimed under.'),
  ('ZW', 'exempt', 'exempt', 'Exempt supply under section 11 of the Value Added Tax Act [Chapter 23:12]: no VAT is charged.', '{}'::jsonb, 30, date '1970-01-01', null, 'Value Added Tax Act [Chapter 23:12], s. 11 — the supplies exempt from the tax of s. 6(1)(a), including financial services, residential letting, passenger transport, education, medical services and the goods and services prescribed by the First Schedule to the Value Added Tax (General) Regulations.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
