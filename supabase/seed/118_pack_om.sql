-- Ekwo OS — Oman: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/om at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build om`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Royal Decree No. 121/2020 Promulgating the Value Added Tax Law (Tax Authority's own English translation) (Sultanate of Oman Tax Authority)
--     https://tms.taxoman.gov.om/portal/documents/20126/1414820/VAT+Law+.pdf/9cbe8926-066b-d48d-2b7f-14f41b4c19a8?t=1733169733344
--   Decision No. 53/2021 Issuing the Executive Regulations of the Value Added Tax Law, as amended by Decision No. 456/2022, Decision No. 521/2023 and Decision No. 81/2025 (Arabic official text; this pack's research found no Tax Authority English translation of the Executive Regulations, unlike the Law itself) (Sultanate of Oman Tax Authority)
--     https://tms.taxoman.gov.om/portal/documents/20126/0/Decision+No.+53-2021+Issuing+the+Executive+Regulations+of+the+Value+Added+Tax+%28VAT%29+Law.pdf/6150f022-0d7f-4f9b-831f-8b50c69af118?t=1748250290518
--   Chairman's Decision Determining the Mandatory and Voluntary Registration Thresholds (Sultanate of Oman Tax Authority)
--     https://tms.taxoman.gov.om/portal/documents/20126/1414820/Determining+the+Mandatory+and+Voluntary+Registration+Thresholds.pdf/4c5d8dcb-5b81-34ae-a1d2-e3c6d8431988?t=1733169610184
--   VAT Taxpayer Guide — VAT Return Filing, Version 1, June 2021 (Sultanate of Oman Tax Authority)
--     https://tms.taxoman.gov.om/portal/documents/20126/1414820/VAT+Taxpayer+Guide+-+VAT+Return+Filing.pdf/fae31d0c-e7e7-0014-9f28-a4c506b36614?t=1733169613409
--   VAT Returns — the e-service a return is filed on (Sultanate of Oman Tax Authority)
--     https://tms.taxoman.gov.om/portal/vat-returns
--   Fawtara (E-invoicing) Frequently Asked Questions, last updated 30 June 2026 (Sultanate of Oman Tax Authority)
--     https://tms.taxoman.gov.om/portal/documents/d/taxportal/monthly-faq-s-1-pdf
--   Fawtara — the national e-invoicing project portal (Sultanate of Oman Tax Authority)
--     https://tms.taxoman.gov.om/portal/fawtara1
--   IFRS Standards — Application Around the World, Jurisdictional Profile: Oman (IFRS Foundation)
--     https://www.ifrs.org/content/dam/ifrs/publications/jurisdictions/pdf-profiles/oman-ifrs-profile.pdf
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('OM', 'Oman', '0.1.0', date '2026-09-26', '20260917170000', 'community', null, null, 'd721a4b1b185abd4fd696e2cfee8a8db6c727d98d241e44e875cc9b4261064c5', '[{"key":"vat-law","title":"Royal Decree No. 121/2020 Promulgating the Value Added Tax Law (Tax Authority''s own English translation)","publisher":"Sultanate of Oman Tax Authority","url":"https://tms.taxoman.gov.om/portal/documents/20126/1414820/VAT+Law+.pdf/9cbe8926-066b-d48d-2b7f-14f41b4c19a8?t=1733169733344","consulted_on":"2026-09-26","kind":"law"},{"key":"vat-exec-reg","title":"Decision No. 53/2021 Issuing the Executive Regulations of the Value Added Tax Law, as amended by Decision No. 456/2022, Decision No. 521/2023 and Decision No. 81/2025 (Arabic official text; this pack''s research found no Tax Authority English translation of the Executive Regulations, unlike the Law itself)","publisher":"Sultanate of Oman Tax Authority","url":"https://tms.taxoman.gov.om/portal/documents/20126/0/Decision+No.+53-2021+Issuing+the+Executive+Regulations+of+the+Value+Added+Tax+%28VAT%29+Law.pdf/6150f022-0d7f-4f9b-831f-8b50c69af118?t=1748250290518","consulted_on":"2026-09-26","kind":"regulation"},{"key":"registration-thresholds","title":"Chairman''s Decision Determining the Mandatory and Voluntary Registration Thresholds","publisher":"Sultanate of Oman Tax Authority","url":"https://tms.taxoman.gov.om/portal/documents/20126/1414820/Determining+the+Mandatory+and+Voluntary+Registration+Thresholds.pdf/4c5d8dcb-5b81-34ae-a1d2-e3c6d8431988?t=1733169610184","consulted_on":"2026-09-26","kind":"regulation"},{"key":"return-filing-guide","title":"VAT Taxpayer Guide — VAT Return Filing, Version 1, June 2021","publisher":"Sultanate of Oman Tax Authority","url":"https://tms.taxoman.gov.om/portal/documents/20126/1414820/VAT+Taxpayer+Guide+-+VAT+Return+Filing.pdf/fae31d0c-e7e7-0014-9f28-a4c506b36614?t=1733169613409","consulted_on":"2026-09-26","kind":"guidance"},{"key":"vat-returns-portal","title":"VAT Returns — the e-service a return is filed on","publisher":"Sultanate of Oman Tax Authority","url":"https://tms.taxoman.gov.om/portal/vat-returns","consulted_on":"2026-09-26","kind":"portal"},{"key":"fawtara-faq","title":"Fawtara (E-invoicing) Frequently Asked Questions, last updated 30 June 2026","publisher":"Sultanate of Oman Tax Authority","url":"https://tms.taxoman.gov.om/portal/documents/d/taxportal/monthly-faq-s-1-pdf","consulted_on":"2026-09-26","kind":"guidance"},{"key":"fawtara-portal","title":"Fawtara — the national e-invoicing project portal","publisher":"Sultanate of Oman Tax Authority","url":"https://tms.taxoman.gov.om/portal/fawtara1","consulted_on":"2026-09-26","kind":"portal"},{"key":"ifrs-oman-profile","title":"IFRS Standards — Application Around the World, Jurisdictional Profile: Oman","publisher":"IFRS Foundation","url":"https://www.ifrs.org/content/dam/ifrs/publications/jurisdictions/pdf-profiles/oman-ifrs-profile.pdf","consulted_on":"2026-09-26","kind":"guidance"}]'::jsonb)
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
  ('OM', 'default', 'Oman reference chart of accounts', '{"en":"Oman reference chart of accounts"}'::jsonb, true, 'companies', array['OM-IFRS-IS', 'OM-IFRS-SFP']::text[], null, 'There is no legal chart of accounts in the Sultanate, as far as this pack''s research could establish: neither the Tax Authority nor the Capital Market Authority (CMA) publishes one. What is prescribed is the reporting framework, and unlike packs/ae and packs/sa this is not the IFRS for SMEs Accounting Standard: the IFRS Foundation''s own Jurisdictional Profile for Oman records that the Sultanate has not adopted the IFRS for SMEs Standard and that ''For those SMEs that are not required to use the IFRS for SMEs Accounting Standard, what other accounting framework do they use? Full IFRS Standards'' — every company, listed or not, prepares under full IFRS Accounting Standards. The Profile traces the commitment to three texts this pack''s research could not open at a directly-fetchable primary source in this pass — Article 282 of the Executive Regulation of the Capital Market Law (Royal Decree 80/1998), which binds an issuer; Article 30 of the Law of Organising the Accountancy and Auditing Profession (Royal Decree 77/1986), which binds an accountant preparing any company''s accounts until the Minister of Commerce and Industry says otherwise; and Article 79 of the Income Tax Law with Article 61 of its Executive Regulations (Royal Decree 47/1981), which is limited to finance leases. A reviewer who can open uaelegislation-equivalent primary Omani legislation should check these three articles before this paragraph is trusted on faith in the IFRS Foundation''s own secondary reading. The chart itself is this pack''s own construction — four digits, blocked so that each range reaches one line item of the statement of financial position and the income statement below, IAS 1 and not the simplified sections of the IFRS for SMEs Standard — carrying the accounts an Omani company actually keeps: VAT input and output tax, the amount payable to and refundable by the Tax Authority, import VAT self-assessed under the postponed accounting Article 86 permits, corporate income tax under the Income Tax Law (Royal Decree 28/2009, standard rate 15%), and an end-of-service benefits provision under the Labour Law, which this pack''s research did not trace to a specific article and which a reviewer should check.', 'ifrs-oman-profile')
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
  ('OM', 'default', '1000', 'Petty cash', '{"en":"Petty cash"}'::jsonb, 'asset_cash', false, null, 10),
  ('OM', 'default', '1010', 'Current account — OMR', '{"en":"Current account — OMR"}'::jsonb, 'asset_cash', false, null, 20),
  ('OM', 'default', '1020', 'Fixed deposits placed for three months or less', '{"en":"Fixed deposits placed for three months or less"}'::jsonb, 'asset_cash', false, null, 30),
  ('OM', 'default', '1030', 'Foreign currency account', '{"en":"Foreign currency account"}'::jsonb, 'asset_cash', false, null, 40),
  ('OM', 'default', '1040', 'Cash in transit — card and payment gateway settlements', '{"en":"Cash in transit — card and payment gateway settlements"}'::jsonb, 'asset_cash', false, null, 50),
  ('OM', 'default', '1050', 'Money market funds', '{"en":"Money market funds"}'::jsonb, 'asset_cash', false, null, 55),
  ('OM', 'default', '1100', 'Trade receivables', '{"en":"Trade receivables"}'::jsonb, 'asset_receivable', true, null, 60),
  ('OM', 'default', '1110', 'Trade receivables — allowance for impairment', '{"en":"Trade receivables — allowance for impairment"}'::jsonb, 'asset_current', false, null, 70),
  ('OM', 'default', '1120', 'Other receivables', '{"en":"Other receivables"}'::jsonb, 'asset_current', true, null, 80),
  ('OM', 'default', '1130', 'Amounts due from related parties', '{"en":"Amounts due from related parties"}'::jsonb, 'asset_current', false, null, 90),
  ('OM', 'default', '1140', 'Deposits paid', '{"en":"Deposits paid"}'::jsonb, 'asset_current', false, null, 100),
  ('OM', 'default', '1145', 'Loans to employees', '{"en":"Loans to employees"}'::jsonb, 'asset_current', false, null, 105),
  ('OM', 'default', '1150', 'VAT input tax', '{"en":"VAT input tax"}'::jsonb, 'asset_current', false, null, 110),
  ('OM', 'default', '1155', 'VAT refundable by the Tax Authority — net of a filed return', '{"en":"VAT refundable by the Tax Authority — net of a filed return"}'::jsonb, 'asset_current', true, null, 120),
  ('OM', 'default', '1157', 'Import VAT self-assessed under postponed accounting — awaiting settlement', '{"en":"Import VAT self-assessed under postponed accounting — awaiting settlement"}'::jsonb, 'asset_current', false, null, 125),
  ('OM', 'default', '1160', 'Advances to staff', '{"en":"Advances to staff"}'::jsonb, 'asset_current', false, null, 130),
  ('OM', 'default', '1200', 'Inventories — goods for resale', '{"en":"Inventories — goods for resale"}'::jsonb, 'asset_current', false, null, 140),
  ('OM', 'default', '1210', 'Inventories — raw materials', '{"en":"Inventories — raw materials"}'::jsonb, 'asset_current', false, null, 150),
  ('OM', 'default', '1220', 'Inventories — work in progress', '{"en":"Inventories — work in progress"}'::jsonb, 'asset_current', false, null, 160),
  ('OM', 'default', '1230', 'Inventories — finished goods', '{"en":"Inventories — finished goods"}'::jsonb, 'asset_current', false, null, 170),
  ('OM', 'default', '1300', 'Short-term investments', '{"en":"Short-term investments"}'::jsonb, 'asset_current', false, null, 190),
  ('OM', 'default', '1350', 'Income tax recoverable', '{"en":"Income tax recoverable"}'::jsonb, 'asset_current', false, null, 200),
  ('OM', 'default', '1400', 'Prepayments', '{"en":"Prepayments"}'::jsonb, 'asset_prepayments', false, null, 210),
  ('OM', 'default', '1410', 'Accrued income', '{"en":"Accrued income"}'::jsonb, 'asset_prepayments', false, null, 220),
  ('OM', 'default', '1420', 'Prepaid rent', '{"en":"Prepaid rent"}'::jsonb, 'asset_prepayments', false, null, 222),
  ('OM', 'default', '1430', 'Prepaid insurance', '{"en":"Prepaid insurance"}'::jsonb, 'asset_prepayments', false, null, 224),
  ('OM', 'default', '1600', 'Land and buildings — cost', '{"en":"Land and buildings — cost"}'::jsonb, 'asset_fixed', false, null, 230),
  ('OM', 'default', '1601', 'Land and buildings — accumulated depreciation', '{"en":"Land and buildings — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 240),
  ('OM', 'default', '1610', 'Leasehold improvements — cost', '{"en":"Leasehold improvements — cost"}'::jsonb, 'asset_fixed', false, null, 250),
  ('OM', 'default', '1611', 'Leasehold improvements — accumulated depreciation', '{"en":"Leasehold improvements — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 260),
  ('OM', 'default', '1620', 'Plant and machinery — cost', '{"en":"Plant and machinery — cost"}'::jsonb, 'asset_fixed', false, null, 270),
  ('OM', 'default', '1621', 'Plant and machinery — accumulated depreciation', '{"en":"Plant and machinery — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 280),
  ('OM', 'default', '1630', 'Office equipment and computers — cost', '{"en":"Office equipment and computers — cost"}'::jsonb, 'asset_fixed', false, null, 290),
  ('OM', 'default', '1631', 'Office equipment and computers — accumulated depreciation', '{"en":"Office equipment and computers — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 300),
  ('OM', 'default', '1632', 'Furniture and fixtures — cost', '{"en":"Furniture and fixtures — cost"}'::jsonb, 'asset_fixed', false, null, 310),
  ('OM', 'default', '1633', 'Furniture and fixtures — accumulated depreciation', '{"en":"Furniture and fixtures — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 320),
  ('OM', 'default', '1640', 'Motor vehicles — cost', '{"en":"Motor vehicles — cost"}'::jsonb, 'asset_fixed', false, null, 330),
  ('OM', 'default', '1641', 'Motor vehicles — accumulated depreciation', '{"en":"Motor vehicles — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 340),
  ('OM', 'default', '1650', 'Capital work in progress', '{"en":"Capital work in progress"}'::jsonb, 'asset_fixed', false, null, 350),
  ('OM', 'default', '1690', 'Right-of-use assets — cost', '{"en":"Right-of-use assets — cost"}'::jsonb, 'asset_fixed', false, null, 352),
  ('OM', 'default', '1691', 'Right-of-use assets — accumulated depreciation', '{"en":"Right-of-use assets — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 354),
  ('OM', 'default', '1700', 'Investments in related parties', '{"en":"Investments in related parties"}'::jsonb, 'asset_non_current', false, null, 360),
  ('OM', 'default', '1710', 'Long-term deposits and retentions held', '{"en":"Long-term deposits and retentions held"}'::jsonb, 'asset_non_current', false, null, 370),
  ('OM', 'default', '1730', 'Goodwill', '{"en":"Goodwill"}'::jsonb, 'asset_non_current', false, null, 375),
  ('OM', 'default', '1750', 'Intangible assets — cost', '{"en":"Intangible assets — cost"}'::jsonb, 'asset_non_current', false, null, 380),
  ('OM', 'default', '1751', 'Intangible assets — accumulated amortisation', '{"en":"Intangible assets — accumulated amortisation"}'::jsonb, 'asset_non_current', false, null, 390),
  ('OM', 'default', '2000', 'Trade payables', '{"en":"Trade payables"}'::jsonb, 'liability_payable', true, null, 400),
  ('OM', 'default', '2010', 'Other payables and accruals', '{"en":"Other payables and accruals"}'::jsonb, 'liability_current', false, null, 410),
  ('OM', 'default', '2020', 'Amounts due to related parties', '{"en":"Amounts due to related parties"}'::jsonb, 'liability_current', false, null, 420),
  ('OM', 'default', '2030', 'Amounts due to directors and shareholders', '{"en":"Amounts due to directors and shareholders"}'::jsonb, 'liability_current', false, null, 430),
  ('OM', 'default', '2040', 'Deposits received', '{"en":"Deposits received"}'::jsonb, 'liability_current', false, null, 440),
  ('OM', 'default', '2045', 'Deferred revenue', '{"en":"Deferred revenue"}'::jsonb, 'liability_current', false, null, 445),
  ('OM', 'default', '2050', 'Wages and salaries payable', '{"en":"Wages and salaries payable"}'::jsonb, 'liability_current', false, null, 450),
  ('OM', 'default', '2060', 'Social insurance contributions payable', '{"en":"Social insurance contributions payable"}'::jsonb, 'liability_current', false, null, 455),
  ('OM', 'default', '2100', 'VAT output tax', '{"en":"VAT output tax"}'::jsonb, 'liability_current', false, null, 460),
  ('OM', 'default', '2110', 'VAT payable to the Tax Authority — net of a filed return', '{"en":"VAT payable to the Tax Authority — net of a filed return"}'::jsonb, 'liability_current', true, null, 470),
  ('OM', 'default', '2130', 'Income tax payable', '{"en":"Income tax payable"}'::jsonb, 'liability_current', false, null, 480),
  ('OM', 'default', '2150', 'End-of-service benefits payable — current portion', '{"en":"End-of-service benefits payable — current portion"}'::jsonb, 'liability_current', false, null, 490),
  ('OM', 'default', '2200', 'Short-term loans and bank overdraft', '{"en":"Short-term loans and bank overdraft"}'::jsonb, 'liability_current', false, null, 500),
  ('OM', 'default', '2210', 'Current portion of long-term loans', '{"en":"Current portion of long-term loans"}'::jsonb, 'liability_current', false, null, 510),
  ('OM', 'default', '2300', 'Long-term loans', '{"en":"Long-term loans"}'::jsonb, 'liability_non_current', false, null, 520),
  ('OM', 'default', '2320', 'Provision for onerous contracts', '{"en":"Provision for onerous contracts"}'::jsonb, 'liability_non_current', false, null, 525),
  ('OM', 'default', '2350', 'End-of-service benefits provision — non-current portion', '{"en":"End-of-service benefits provision — non-current portion"}'::jsonb, 'liability_non_current', false, null, 530),
  ('OM', 'default', '2990', 'Suspense account', '{"en":"Suspense account"}'::jsonb, 'liability_current', false, null, 540),
  ('OM', 'default', '3000', 'Share capital', '{"en":"Share capital"}'::jsonb, 'equity', false, null, 550),
  ('OM', 'default', '3010', 'Statutory reserve', '{"en":"Statutory reserve"}'::jsonb, 'equity', false, null, 560),
  ('OM', 'default', '3020', 'Other reserves', '{"en":"Other reserves"}'::jsonb, 'equity', false, null, 570),
  ('OM', 'default', '3030', 'Foreign currency translation reserve', '{"en":"Foreign currency translation reserve"}'::jsonb, 'equity', false, null, 575),
  ('OM', 'default', '3200', 'Retained earnings', '{"en":"Retained earnings"}'::jsonb, 'equity_retained', false, null, 580),
  ('OM', 'default', '3210', 'Dividends paid', '{"en":"Dividends paid"}'::jsonb, 'equity_retained', false, null, 590),
  ('OM', 'default', '4000', 'Sales of goods', '{"en":"Sales of goods"}'::jsonb, 'income', false, null, 600),
  ('OM', 'default', '4010', 'Sales of services', '{"en":"Sales of services"}'::jsonb, 'income', false, null, 610),
  ('OM', 'default', '4020', 'Sales — export of goods', '{"en":"Sales — export of goods"}'::jsonb, 'income', false, null, 620),
  ('OM', 'default', '4030', 'Sales — export of services', '{"en":"Sales — export of services"}'::jsonb, 'income', false, null, 630),
  ('OM', 'default', '4040', 'Rental income', '{"en":"Rental income"}'::jsonb, 'income', false, null, 640),
  ('OM', 'default', '4050', 'Income from exempt supplies', '{"en":"Income from exempt supplies"}'::jsonb, 'income', false, null, 645),
  ('OM', 'default', '4700', 'Realised foreign exchange gain', '{"en":"Realised foreign exchange gain"}'::jsonb, 'income_other', false, null, 650),
  ('OM', 'default', '4710', 'Unrealised foreign exchange gain', '{"en":"Unrealised foreign exchange gain"}'::jsonb, 'income_other', false, null, 660),
  ('OM', 'default', '4750', 'Gain on disposal of fixed assets', '{"en":"Gain on disposal of fixed assets"}'::jsonb, 'income_other', false, null, 670),
  ('OM', 'default', '4790', 'Other income', '{"en":"Other income"}'::jsonb, 'income_other', false, null, 680),
  ('OM', 'default', '5000', 'Cost of goods sold', '{"en":"Cost of goods sold"}'::jsonb, 'expense_direct_cost', false, null, 690),
  ('OM', 'default', '5010', 'Freight and customs clearance', '{"en":"Freight and customs clearance"}'::jsonb, 'expense_direct_cost', false, null, 700),
  ('OM', 'default', '5020', 'Subcontractor costs', '{"en":"Subcontractor costs"}'::jsonb, 'expense_direct_cost', false, null, 710),
  ('OM', 'default', '5030', 'Purchase returns and allowances', '{"en":"Purchase returns and allowances"}'::jsonb, 'expense_direct_cost', false, null, 715),
  ('OM', 'default', '6100', 'Salaries and wages', '{"en":"Salaries and wages"}'::jsonb, 'expense', false, null, 720),
  ('OM', 'default', '6110', 'End-of-service benefits charge for the year', '{"en":"End-of-service benefits charge for the year"}'::jsonb, 'expense', false, null, 730),
  ('OM', 'default', '6115', 'Employer''s social insurance contribution', '{"en":"Employer''s social insurance contribution"}'::jsonb, 'expense', false, null, 735),
  ('OM', 'default', '6120', 'Staff health insurance', '{"en":"Staff health insurance"}'::jsonb, 'expense', false, null, 740),
  ('OM', 'default', '6130', 'Other staff costs', '{"en":"Other staff costs"}'::jsonb, 'expense', false, null, 750),
  ('OM', 'default', '6140', 'Recruitment and training', '{"en":"Recruitment and training"}'::jsonb, 'expense', false, null, 755),
  ('OM', 'default', '6200', 'Rent', '{"en":"Rent"}'::jsonb, 'expense', false, null, 760),
  ('OM', 'default', '6210', 'Utilities', '{"en":"Utilities"}'::jsonb, 'expense', false, null, 770),
  ('OM', 'default', '6220', 'Office supplies', '{"en":"Office supplies"}'::jsonb, 'expense', false, null, 780),
  ('OM', 'default', '6230', 'IT and software', '{"en":"IT and software"}'::jsonb, 'expense', false, null, 790),
  ('OM', 'default', '6240', 'Repairs and maintenance', '{"en":"Repairs and maintenance"}'::jsonb, 'expense', false, null, 800),
  ('OM', 'default', '6300', 'Travel', '{"en":"Travel"}'::jsonb, 'expense', false, null, 810),
  ('OM', 'default', '6310', 'Entertainment — not recoverable for VAT', '{"en":"Entertainment — not recoverable for VAT"}'::jsonb, 'expense', false, null, 820),
  ('OM', 'default', '6320', 'Motor vehicle running costs', '{"en":"Motor vehicle running costs"}'::jsonb, 'expense', false, null, 830),
  ('OM', 'default', '6400', 'Professional fees', '{"en":"Professional fees"}'::jsonb, 'expense', false, null, 840),
  ('OM', 'default', '6410', 'Bank charges', '{"en":"Bank charges"}'::jsonb, 'expense', false, null, 850),
  ('OM', 'default', '6420', 'Insurance', '{"en":"Insurance"}'::jsonb, 'expense', false, null, 860),
  ('OM', 'default', '6430', 'Marketing and advertising', '{"en":"Marketing and advertising"}'::jsonb, 'expense', false, null, 870),
  ('OM', 'default', '6435', 'Subscriptions and memberships', '{"en":"Subscriptions and memberships"}'::jsonb, 'expense', false, null, 875),
  ('OM', 'default', '6440', 'Licence fees and government charges', '{"en":"Licence fees and government charges"}'::jsonb, 'expense', false, null, 880),
  ('OM', 'default', '6500', 'Depreciation charge', '{"en":"Depreciation charge"}'::jsonb, 'expense_depreciation', false, null, 890),
  ('OM', 'default', '6510', 'Amortisation charge', '{"en":"Amortisation charge"}'::jsonb, 'expense_depreciation', false, null, 900),
  ('OM', 'default', '6950', 'Realised foreign exchange loss', '{"en":"Realised foreign exchange loss"}'::jsonb, 'expense', false, null, 910),
  ('OM', 'default', '6955', 'Unrealised foreign exchange loss', '{"en":"Unrealised foreign exchange loss"}'::jsonb, 'expense', false, null, 920),
  ('OM', 'default', '6960', 'Loss on disposal of fixed assets', '{"en":"Loss on disposal of fixed assets"}'::jsonb, 'expense', false, null, 930),
  ('OM', 'default', '6990', 'Rounding differences', '{"en":"Rounding differences"}'::jsonb, 'expense', false, null, 940),
  ('OM', 'default', '7100', 'Interest and finance charges', '{"en":"Interest and finance charges"}'::jsonb, 'expense', false, null, 950),
  ('OM', 'default', '7110', 'Bank facility and arrangement fees', '{"en":"Bank facility and arrangement fees"}'::jsonb, 'expense', false, null, 955),
  ('OM', 'default', '8000', 'Income tax charge for the year', '{"en":"Income tax charge for the year"}'::jsonb, 'expense', false, null, 960)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('OM', 'BNK', 'Bank', '{"en":"Bank"}'::jsonb, 'bank', 30),
  ('OM', 'CSH', 'Petty cash', '{"en":"Petty cash"}'::jsonb, 'cash', 40),
  ('OM', 'GEN', 'General journal', '{"en":"General journal"}'::jsonb, 'general', 50),
  ('OM', 'OPN', 'Opening balances', '{"en":"Opening balances"}'::jsonb, 'opening', 60),
  ('OM', 'PUR', 'Purchases journal', '{"en":"Purchases journal"}'::jsonb, 'purchase', 20),
  ('OM', 'SAL', 'Sales journal', '{"en":"Sales journal"}'::jsonb, 'sales', 10)
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
  ('OM', 'OM-P-BL-CAR', 'Purchase, standard-rated, motor vehicle available for personal use — input tax not recoverable', '{"en":"Purchase, standard-rated, motor vehicle available for personal use — input tax not recoverable"}'::jsonb, 'A motor vehicle purchased, rented or leased for use in the business and available for the personal use of any person, other than a vehicle used in a vehicle rental business or registered as an emergency vehicle.', 'percent', 5, 'purchase', 'domestic', date '2021-04-16', null, 'This pack''s research confirmed, from the same secondary guidance as OM-P-BL-ENT and with the same gap in the primary citation, that input tax on a motor vehicle available for personal use is blocked from deduction unless later re-supplied, subject to the exceptions above. The Tax is not recoverable and lands on the account of the line it taxes rather than on 1150, and is not reported in any box of the return.', 'S', null, 170, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'vat-exec-reg', null, null, null, null),
  ('OM', 'OM-P-BL-ENT', 'Purchase, standard-rated, entertainment — input tax not recoverable', '{"en":"Purchase, standard-rated, entertainment — input tax not recoverable"}'::jsonb, 'Goods or services used for entertainment — hospitality, accommodation, food and beverage or admission to an event provided otherwise than in the ordinary course of a meeting.', 'percent', 5, 'purchase', 'domestic', date '2021-04-16', null, 'This pack''s research confirmed, from secondary guidance rather than a directly-fetchable article of the Executive Regulations (Decision No. 53/2021, as amended), that input tax on goods or services used for entertainment is blocked from deduction unless later re-supplied — the same restriction packs/ae records at Article 53(1)(a) of its own Executive Regulation and packs/sa at Article 50 of its own Implementing Regulations. The exact article number of the Omani Executive Regulations could not be verified in this pass and a reviewer should locate and cite it before this code is trusted. The Tax is not recoverable and lands on the account of the line it taxes rather than on 1150, and is not reported in any box of the return, whose box 6(a) reports only a purchase whose Input Tax is sought.', 'S', null, 160, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'vat-exec-reg', null, null, null, null),
  ('OM', 'OM-P-EX', 'Purchase, exempt', '{"en":"Purchase, exempt"}'::jsonb, 'A purchase of an exempt supply.', 'percent', 0, 'purchase', 'exempt', date '2021-04-16', null, 'Value Added Tax Law, Article 47 — an exempt supply carries no Input Tax to deduct. Not reported on any box: the VAT return''s box 6(a) reports a purchase ''including exempt'' supplies in its base column for information, but there is no Tax to enter in its deductible-VAT column, and this pack does not report a zero figure into a box no posting otherwise reaches.', 'E', null, 190, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('OM', 'OM-P-IMP', 'Purchase, import of goods under postponed accounting', '{"en":"Purchase, import of goods under postponed accounting"}'::jsonb, 'Goods imported into the Sultanate by a taxable person for the purposes of the business, whose import VAT payment is deferred to the VAT return of the tax period in which the goods entered the Sultanate.', 'percent', 5, 'purchase', 'import', date '2021-04-16', null, 'Value Added Tax Law, Article 29 (Tax due upon importation) and Article 86 — ''A Taxable Person may request to defer payment of the tax due upon import until submission of the Tax Return for the Tax Period in which the import took place in accordance with the conditions and by following the procedures determined by the Regulations.'' Reported in box 4(a) of the VAT return (''Import of Goods (Postponed payment): Total value of goods imported (excluding VAT) where VAT was postponed on import. VAT is calculated automatically.''), and recovered in box 6(b) (''Import of goods: Column 1: Total value (excluding VAT) of standard rated imports of goods whether or not postponed. Column 2: deductible VAT related to your imported goods.''). This pack does not model an import whose VAT is paid directly to Customs rather than postponed, which the Guide''s box 4(b) — a total this pack''s postings do not drive — otherwise carries; a reviewer needing that path should add a second code rather than stretch this one.', null, null, 210, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('OM', 'OM-P-NR', 'Purchase, not registered for VAT', '{"en":"Purchase, not registered for VAT"}'::jsonb, 'A purchase from a supplier resident in the Sultanate who is not registered for VAT, so no tax was charged.', 'percent', 0, 'purchase', 'not_subject', date '2021-04-16', null, 'No Tax is charged because the supplier is not a Taxable Person (Value Added Tax Law, Article 1, definition of ''Taxable Person''). Not reported on any box.', 'O', null, 200, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('OM', 'OM-P-RC-SVC', 'Purchase, imported services under the reverse charge', '{"en":"Purchase, imported services under the reverse charge"}'::jsonb, 'A supply of services received by a taxable person resident in the Sultanate from a supplier with no place of residence in the GCC states, who charges no tax on it.', 'percent', 5, 'purchase', 'foreign_services_received', date '2021-04-16', null, 'Value Added Tax Law, Article 12(2) and Article 20(2) — where a Taxable Person receives Services from a Supplier with no Place of Residence in any GCC State, ''he shall be considered as if he has supplied the Services to himself. Such supply shall be subject to Tax in accordance with the Reverse Calculation (Charge) Mechanism''; Executive Regulations, Article 151, requires the Customer to record the value of the Tax due in Omani Rial. Reported in box 2(b) of the VAT return (''Purchases from outside of GCC subject to Reverse Charge Mechanism: Total value of standard rated supplies received (excluding VAT), which are subject to Reverse Charge Mechanism. VAT is calculated automatically.''), and its deductible share folded into box 6(a) alongside ordinary purchases, whose column 1 the Guide describes as covering ''all purchases... including... reverse charge purchases'' — this pack does not duplicate the base value of box 2(b) into box 6(a), only the deductible Tax, because the duplicate base carries no further arithmetic consequence for the return.', null, null, 220, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('OM', 'OM-P-SR', 'Purchase, standard-rated, VAT recoverable', '{"en":"Purchase, standard-rated, VAT recoverable"}'::jsonb, 'A standard-rated purchase used to make a taxable supply, whose input tax may be recovered in full.', 'percent', 5, 'purchase', 'domestic', date '2021-04-16', null, 'Value Added Tax Law, Article 41 — a Taxable Person is entitled to deduct the Input Tax for a Tax Period that he bore on Taxable Supplies made to him during that period. Reported in box 6(a) of the VAT return (''Purchases (except import of goods): Column 1: Total value of all purchases (excluding VAT)... Column 2: deductible VAT related to your purchases.'').', 'S', null, 150, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('OM', 'OM-P-ZR', 'Purchase, zero-rated', '{"en":"Purchase, zero-rated"}'::jsonb, 'A zero-rated purchase from a taxable supplier resident in the Sultanate.', 'percent', 0, 'purchase', 'domestic', date '2021-04-16', null, 'Value Added Tax Law, Article 41 — a zero-rated supply is a Taxable Supply, so its Input Tax may be sought like any other, there being none to deduct at a zero rate. Reported in box 6(a) of the VAT return, whose column 1 asks for ''all purchases... including exempt/standard/zero rated purchases''.', 'Z', null, 180, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('OM', 'OM-S-EX-EDU', 'Sale, exempt, education', '{"en":"Sale, exempt, education"}'::jsonb, 'Educational services and related goods and services.', 'percent', 0, 'sale', 'exempt', date '2021-04-16', null, 'Value Added Tax Law, Article 47(3) — ''Educational Services and related Goods and Services'' are exempt from Tax. Reported in box 1(c) of the VAT return, as OM-S-EX-FIN.', 'E', null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('OM', 'OM-S-EX-FIN', 'Sale, exempt, financial services', '{"en":"Sale, exempt, financial services"}'::jsonb, 'A financial service exempted under the conditions and controls the Regulations determine.', 'percent', 0, 'sale', 'exempt', date '2021-04-16', null, 'Value Added Tax Law, Article 47(1) — ''Financial Services'' are exempt from Tax, subject to the conditions and controls the Regulations determine; this pack''s research did not open the Executive Regulations article that lists which financial services qualify, unlike the explicit margin-versus-fee test packs/ae and packs/sa cite from their own Executive Regulations. Reported in box 1(c) of the VAT return (''Supplies of goods / services tax exempt: Total value of exempt supplies of goods and services in the Sultanate. Excludes any out of scope supplies.'').', 'E', null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('OM', 'OM-S-EX-HEALTH', 'Sale, exempt, healthcare', '{"en":"Sale, exempt, healthcare"}'::jsonb, 'Healthcare services and related goods and services.', 'percent', 0, 'sale', 'exempt', date '2021-04-16', null, 'Value Added Tax Law, Article 47(2) — ''Healthcare Services and related Goods and Services'' are exempt from Tax. Reported in box 1(c) of the VAT return, as OM-S-EX-FIN.', 'E', null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('OM', 'OM-S-EX-LAND', 'Sale, exempt, undeveloped land', '{"en":"Sale, exempt, undeveloped land"}'::jsonb, 'A supply of bare land not covered by a completed or partially completed building or by civil engineering works.', 'percent', 0, 'sale', 'exempt', date '2021-04-16', null, 'Value Added Tax Law, Article 47(4) — ''Undeveloped land (bare land)'' is exempt from Tax. Reported in box 1(c) of the VAT return, as OM-S-EX-FIN.', 'E', null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('OM', 'OM-S-EX-RENT', 'Sale, exempt, residential rental', '{"en":"Sale, exempt, residential rental"}'::jsonb, 'Rental of a property for residential purposes.', 'percent', 0, 'sale', 'exempt', date '2021-04-16', null, 'Value Added Tax Law, Article 47(7) — ''Rental of properties for residential purposes'' is exempt from Tax. Reported in box 1(c) of the VAT return, as OM-S-EX-FIN.', 'E', null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('OM', 'OM-S-EX-RESI', 'Sale, exempt, resale of a residential property', '{"en":"Sale, exempt, resale of a residential property"}'::jsonb, 'A resale of a residential property.', 'percent', 0, 'sale', 'exempt', date '2021-04-16', null, 'Value Added Tax Law, Article 47(5) — ''Resale of residential properties'' is exempt from Tax. Unlike packs/ae and packs/sa, this pack''s research found no article granting the zero rate to a first supply of a new residential building: every residential sale this Law names is exempt, not zero-rated, which is why this pack carries no OM-S-ZR-RESI code. Reported in box 1(c) of the VAT return, as OM-S-EX-FIN.', 'E', null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('OM', 'OM-S-EX-TRANSPORT', 'Sale, exempt, local passenger transport', '{"en":"Sale, exempt, local passenger transport"}'::jsonb, 'Local passenger transport.', 'percent', 0, 'sale', 'exempt', date '2021-04-16', null, 'Value Added Tax Law, Article 47(6) — ''Local passenger transport'' is exempt from Tax. Reported in box 1(c) of the VAT return, as OM-S-EX-FIN.', 'E', null, 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('OM', 'OM-S-OS', 'Sale, out of scope', '{"en":"Sale, out of scope"}'::jsonb, 'A supply whose place of supply is outside the Sultanate under the place-of-supply rules of Chapter Three of the Law.', 'percent', 0, 'sale', 'not_subject', date '2021-04-16', null, 'Value Added Tax Law, Articles 21 to 25 (place of supply of goods and services). Not reported on any box of the return: the VAT Taxpayer Guide''s own account of box 1(c) and box 3(a) each excludes ''any out of scope supplies'' in terms, and no other box of section 1 to 4 names one.', 'O', null, 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('OM', 'OM-S-SR', 'Sale, standard-rated, VAT 5%', '{"en":"Sale, standard-rated, VAT 5%"}'::jsonb, 'A taxable supply of goods or services made in the Sultanate that is not zero-rated or exempt.', 'percent', 5, 'sale', 'domestic', date '2021-04-16', null, 'Value Added Tax Law (Royal Decree No. 121/2020), Article 36 — ''the Tax on the import and supply of taxable Goods or Services shall be computed as (5%) five percent of the Taxable Value'', in force since the Law commenced on 16 April 2021 (180 days after publication of Royal Decree No. 121/2020 on 18 October 2020, under its own Article Four). Reported in box 1(a) of the VAT return (''Supplies of goods / services taxed at 5%: Total value of standard rated supplies of goods and services in the Sultanate, including deemed supplies. Report the VAT-exclusive value only. VAT is calculated automatically.'').', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('OM', 'OM-S-ZR-EXPORT', 'Sale, zero-rated, export of goods or services', '{"en":"Sale, zero-rated, export of goods or services"}'::jsonb, 'An export of goods to outside the Sultanate, or a supply of services to a customer with no place of residence in the GCC states who benefits from the service outside those states.', 'percent', 0, 'sale', 'export', date '2021-04-16', null, 'Value Added Tax Law, Article 52 — supplies made to outside the GCC territory are subject to Tax at the zero rate, including ''Export of Goods'' (clause 1) and a supply of Services by a taxable Supplier resident in the Sultanate to a Customer with no Place of Residence in the GCC States who benefits from it outside those States (clause 4); Article 53 extends the zero rate to a supply that would otherwise be exempt in the Sultanate once it is supplied to outside the GCC States. Reported in box 3(a) of the VAT return (''Exports: Total value of supplies of goods and services exported on which zero rating for exportation applies. Excludes any out of scope supplies.'').', 'G', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('OM', 'OM-S-ZR-FOOD', 'Sale, zero-rated, specified basic food items', '{"en":"Sale, zero-rated, specified basic food items"}'::jsonb, 'A food item on the list the Chairman of the Tax Authority has specified as zero-rated.', 'percent', 0, 'sale', 'domestic', date '2021-04-16', null, 'Value Added Tax Law, Article 51(1) — ''Supply of Food items specified by a decision from the Chairman'' is subject to Tax at the zero rate. This pack''s research located, without opening their full text, two decisions the Tax Authority''s own VAT Law & Regulations page lists under this article — Decision No. 65/2021 and Decision No. 89/2022, both captioned ''zero-rate food commodities'' — and does not reproduce the list of items itself, which a reviewer should obtain before relying on this code for a specific product. Reported in box 1(b) of the VAT return alongside every other domestic zero-rated supply (''Supplies of goods / services taxed at 0%: Total value of zero-rated supplies of goods and services in the Sultanate, excluding exports of goods or services.'').', 'Z', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('OM', 'OM-S-ZR-MED', 'Sale, zero-rated, medicines and medical equipment', '{"en":"Sale, zero-rated, medicines and medical equipment"}'::jsonb, 'A medicine or medical equipment specified by a decision of the Chairman, issued after coordination with the specialised authorities.', 'percent', 0, 'sale', 'domestic', date '2021-04-16', null, 'Value Added Tax Law, Article 51(2) — ''Supply of Medicines and medical equipment in accordance with the rules determined by the issuance of a decision by the Chairman and after coordination with the specialized authorities'' is subject to Tax at the zero rate. Reported in box 1(b) of the VAT return, as OM-S-ZR-FOOD.', 'Z', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('OM', 'OM-S-ZR-METAL', 'Sale, zero-rated, investment gold, silver and platinum', '{"en":"Sale, zero-rated, investment gold, silver and platinum"}'::jsonb, 'Investment-grade gold, silver or platinum.', 'percent', 0, 'sale', 'domestic', date '2021-04-16', null, 'Value Added Tax Law, Article 51(3) — ''The supply of investment gold, silver, and platinum'' is subject to Tax at the zero rate. This pack''s research did not open a Regulations article fixing a minimum purity, unlike the 99% the Executive Regulation of Federal Decree-Law No. 8 of 2017 sets for the United Arab Emirates (packs/ae, AE-S-ZR-METAL) — a reviewer should check the Executive Regulations of Decision No. 53/2021 for the equivalent Omani threshold before this code is trusted on a marginal-purity supply. Reported in box 1(b) of the VAT return, as OM-S-ZR-FOOD.', 'Z', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('OM', 'OM-S-ZR-TRANSPORT', 'Sale, zero-rated, international and intra-GCC transport', '{"en":"Sale, zero-rated, international and intra-GCC transport"}'::jsonb, 'International or intra-GCC transport of goods or passengers, related services, and a means of transport designated for the commercial transport of goods or passengers, with its related goods and services.', 'percent', 0, 'sale', 'domestic', date '2021-04-16', null, 'Value Added Tax Law, Article 51(4) and (5) — ''Supplies of international and intra GCC transport of Goods or passengers, and supply of Services in connection with this transport'' and ''The supply of air, sea and land means of transport that are designated for the transportation of passengers and Goods for commercial purposes and the supply of Goods and Services related to transport'' are subject to Tax at the zero rate. This code does not carry Article 51(6), rescue planes and rescue and assistance boats, which this pack''s research judged too narrow a case to model separately; a reviewer needing it should add a code rather than stretch this one. Reported in box 1(b) of the VAT return, as OM-S-ZR-FOOD.', 'Z', null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null)
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
    ('OM-P-BL-CAR', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('OM-P-BL-CAR', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('OM-P-BL-CAR', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('OM-P-BL-CAR', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('OM-P-BL-ENT', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('OM-P-BL-ENT', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('OM-P-BL-ENT', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('OM-P-BL-ENT', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('OM-P-IMP', 'invoice', 'base', 100, null, '4a', array['4a']::text[], 100, 'OM-VAT-RETURN', 10),
    ('OM-P-IMP', 'invoice', 'tax', 100, '1150', '6b2', array['6b2']::text[], 100, 'OM-VAT-RETURN', 20),
    ('OM-P-IMP', 'invoice', 'tax', -100, '2100', '4a2', array['4a2']::text[], 100, 'OM-VAT-RETURN', 30),
    ('OM-P-IMP', 'credit_note', 'base', 100, null, '4a', array['4a']::text[], -100, 'OM-VAT-RETURN', 10),
    ('OM-P-IMP', 'credit_note', 'tax', 100, '1150', '6b2', array['6b2']::text[], -100, 'OM-VAT-RETURN', 20),
    ('OM-P-IMP', 'credit_note', 'tax', -100, '2100', '4a2', array['4a2']::text[], -100, 'OM-VAT-RETURN', 30),
    ('OM-P-RC-SVC', 'invoice', 'base', 100, null, '2b', array['2b']::text[], 100, 'OM-VAT-RETURN', 10),
    ('OM-P-RC-SVC', 'invoice', 'tax', 100, '1150', '6a2', array['6a2']::text[], 100, 'OM-VAT-RETURN', 20),
    ('OM-P-RC-SVC', 'invoice', 'tax', -100, '2100', '2b2', array['2b2']::text[], 100, 'OM-VAT-RETURN', 30),
    ('OM-P-RC-SVC', 'credit_note', 'base', 100, null, '2b', array['2b']::text[], -100, 'OM-VAT-RETURN', 10),
    ('OM-P-RC-SVC', 'credit_note', 'tax', 100, '1150', '6a2', array['6a2']::text[], -100, 'OM-VAT-RETURN', 20),
    ('OM-P-RC-SVC', 'credit_note', 'tax', -100, '2100', '2b2', array['2b2']::text[], -100, 'OM-VAT-RETURN', 30),
    ('OM-P-SR', 'invoice', 'base', 100, null, '6a', array['6a']::text[], 100, 'OM-VAT-RETURN', 10),
    ('OM-P-SR', 'invoice', 'tax', 100, '1150', '6a2', array['6a2']::text[], 100, 'OM-VAT-RETURN', 20),
    ('OM-P-SR', 'credit_note', 'base', 100, null, '6a', array['6a']::text[], -100, 'OM-VAT-RETURN', 10),
    ('OM-P-SR', 'credit_note', 'tax', 100, '1150', '6a2', array['6a2']::text[], -100, 'OM-VAT-RETURN', 20),
    ('OM-P-ZR', 'invoice', 'base', 100, null, '6a', array['6a']::text[], 100, 'OM-VAT-RETURN', 10),
    ('OM-P-ZR', 'credit_note', 'base', 100, null, '6a', array['6a']::text[], -100, 'OM-VAT-RETURN', 10),
    ('OM-S-EX-EDU', 'invoice', 'base', 100, null, '1c', array['1c']::text[], 100, 'OM-VAT-RETURN', 10),
    ('OM-S-EX-EDU', 'credit_note', 'base', 100, null, '1c', array['1c']::text[], -100, 'OM-VAT-RETURN', 10),
    ('OM-S-EX-FIN', 'invoice', 'base', 100, null, '1c', array['1c']::text[], 100, 'OM-VAT-RETURN', 10),
    ('OM-S-EX-FIN', 'credit_note', 'base', 100, null, '1c', array['1c']::text[], -100, 'OM-VAT-RETURN', 10),
    ('OM-S-EX-HEALTH', 'invoice', 'base', 100, null, '1c', array['1c']::text[], 100, 'OM-VAT-RETURN', 10),
    ('OM-S-EX-HEALTH', 'credit_note', 'base', 100, null, '1c', array['1c']::text[], -100, 'OM-VAT-RETURN', 10),
    ('OM-S-EX-LAND', 'invoice', 'base', 100, null, '1c', array['1c']::text[], 100, 'OM-VAT-RETURN', 10),
    ('OM-S-EX-LAND', 'credit_note', 'base', 100, null, '1c', array['1c']::text[], -100, 'OM-VAT-RETURN', 10),
    ('OM-S-EX-RENT', 'invoice', 'base', 100, null, '1c', array['1c']::text[], 100, 'OM-VAT-RETURN', 10),
    ('OM-S-EX-RENT', 'credit_note', 'base', 100, null, '1c', array['1c']::text[], -100, 'OM-VAT-RETURN', 10),
    ('OM-S-EX-RESI', 'invoice', 'base', 100, null, '1c', array['1c']::text[], 100, 'OM-VAT-RETURN', 10),
    ('OM-S-EX-RESI', 'credit_note', 'base', 100, null, '1c', array['1c']::text[], -100, 'OM-VAT-RETURN', 10),
    ('OM-S-EX-TRANSPORT', 'invoice', 'base', 100, null, '1c', array['1c']::text[], 100, 'OM-VAT-RETURN', 10),
    ('OM-S-EX-TRANSPORT', 'credit_note', 'base', 100, null, '1c', array['1c']::text[], -100, 'OM-VAT-RETURN', 10),
    ('OM-S-SR', 'invoice', 'base', 100, null, '1a', array['1a']::text[], 100, 'OM-VAT-RETURN', 10),
    ('OM-S-SR', 'invoice', 'tax', 100, '2100', '1a2', array['1a2']::text[], 100, 'OM-VAT-RETURN', 20),
    ('OM-S-SR', 'credit_note', 'base', 100, null, '1a', array['1a']::text[], -100, 'OM-VAT-RETURN', 10),
    ('OM-S-SR', 'credit_note', 'tax', 100, '2100', '1a2', array['1a2']::text[], -100, 'OM-VAT-RETURN', 20),
    ('OM-S-ZR-EXPORT', 'invoice', 'base', 100, null, '3a', array['3a']::text[], 100, 'OM-VAT-RETURN', 10),
    ('OM-S-ZR-EXPORT', 'credit_note', 'base', 100, null, '3a', array['3a']::text[], -100, 'OM-VAT-RETURN', 10),
    ('OM-S-ZR-FOOD', 'invoice', 'base', 100, null, '1b', array['1b']::text[], 100, 'OM-VAT-RETURN', 10),
    ('OM-S-ZR-FOOD', 'credit_note', 'base', 100, null, '1b', array['1b']::text[], -100, 'OM-VAT-RETURN', 10),
    ('OM-S-ZR-MED', 'invoice', 'base', 100, null, '1b', array['1b']::text[], 100, 'OM-VAT-RETURN', 10),
    ('OM-S-ZR-MED', 'credit_note', 'base', 100, null, '1b', array['1b']::text[], -100, 'OM-VAT-RETURN', 10),
    ('OM-S-ZR-METAL', 'invoice', 'base', 100, null, '1b', array['1b']::text[], 100, 'OM-VAT-RETURN', 10),
    ('OM-S-ZR-METAL', 'credit_note', 'base', 100, null, '1b', array['1b']::text[], -100, 'OM-VAT-RETURN', 10),
    ('OM-S-ZR-TRANSPORT', 'invoice', 'base', 100, null, '1b', array['1b']::text[], 100, 'OM-VAT-RETURN', 10),
    ('OM-S-ZR-TRANSPORT', 'credit_note', 'base', 100, null, '1b', array['1b']::text[], -100, 'OM-VAT-RETURN', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'OM' and t.code = v.tax_code
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
  ('OM', 'OM-VAT-RETURN', 'VAT return', array['quarter']::declaration_period[], 'quarter'::declaration_period, date '2021-04-16', null, 'Value Added Tax Law (Royal Decree No. 121/2020), Article 71 — the Regulations determine the Tax Period a Taxable Person must file a Tax Return for, provided it is not less than one month; the VAT Taxpayer Guide — VAT Return Filing states the Tax Period for VAT in practice as ''three months i.e., a quarter of a year'', starting 1 January, 1 April, 1 July or 1 October, and this pack''s research found no text assigning any Omani taxpayer a shorter period, unlike the Federal Tax Authority''s own administrative practice packs/ae records for larger taxpayers. Only `quarter` is therefore carried. The boxes below reproduce the live VAT return this pack''s research opened at Step 2 of the Guide''s own screenshots (''Content of VAT return''), letter for letter, and not a construction from the Law''s Article 72 alone.', true,'day_of_month_after_period'::filing_deadline_rule, 30, null, 'Value Added Tax Law, Article 72 — ''The Taxable Person shall file a Tax Return to the Authority within (30) thirty days following the end of the Tax Period... per the form prepared for this purpose.'' Article 82 sets the same day for payment.', 'vat-law', null)
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
  ('OM', 'OM-VAT-RETURN', '1a', 'base', 'Supplies of goods / services taxed at 5% — taxable base', '{"en":"Supplies of goods / services taxed at 5% — taxable base"}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Taxpayer Guide — VAT Return Filing, box 1(a): ''Total value of standard rated supplies of goods and services in the Sultanate, including deemed supplies. Report the VAT-exclusive value only.''', 'return-filing-guide'),
  ('OM', 'OM-VAT-RETURN', '1a2', 'tax', 'Supplies of goods / services taxed at 5% — VAT due', '{"en":"Supplies of goods / services taxed at 5% — VAT due"}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Taxpayer Guide — VAT Return Filing, box 1(a): ''VAT is calculated automatically.''', 'return-filing-guide'),
  ('OM', 'OM-VAT-RETURN', '1b', 'base', 'Supplies of goods / services taxed at 0%', '{"en":"Supplies of goods / services taxed at 0%"}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Taxpayer Guide — VAT Return Filing, box 1(b): ''Total value of zero-rated supplies of goods and services in the Sultanate, excluding exports of goods or services.''', 'return-filing-guide'),
  ('OM', 'OM-VAT-RETURN', '1c', 'base', 'Supplies of goods / services tax exempt', '{"en":"Supplies of goods / services tax exempt"}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Taxpayer Guide — VAT Return Filing, box 1(c): ''Total value of exempt supplies of goods and services in the Sultanate. Excludes any out of scope supplies.''', 'return-filing-guide'),
  ('OM', 'OM-VAT-RETURN', '1d', 'base', 'Supplies of goods, tax levy shifted to recipient inside GCC', '{"en":"Supplies of goods, tax levy shifted to recipient inside GCC"}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Taxpayer Guide — VAT Return Filing, box 1(d): ''Supplies of goods, tax levy shifted to recipient inside GCC (supplies made by you that are subject to Reverse Charge Mechanism): Not activated until GCC rules apply.'' No tax code of this pack posts here: the intra-GCC electronic services database the Common VAT Agreement conditions this box on is not yet in force between the Sultanate and another Implementing State.', 'return-filing-guide'),
  ('OM', 'OM-VAT-RETURN', '1e', 'base', 'Supplies of services, tax levy shifted to recipient inside GCC', '{"en":"Supplies of services, tax levy shifted to recipient inside GCC"}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Taxpayer Guide — VAT Return Filing, box 1(e): ''Supplies of services, tax levy shifted to recipient inside GCC (supplies made by you that are subject to Reverse Charge Mechanism): Not activated until GCC rules apply.'' Undriven, for the reason given at box 1(d).', 'return-filing-guide'),
  ('OM', 'OM-VAT-RETURN', '1f', 'base', 'Supply of goods as per profit margin scheme', '{"en":"Supply of goods as per profit margin scheme"}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Taxpayer Guide — VAT Return Filing, box 1(f): ''Total profit margin for any supplies of goods as per profit margin scheme (profit margin excluding VAT).'' Value Added Tax Law, Article 39, refers the profit margin mechanism for used goods to the Regulations; this pack carries no tax code for it, matching neither an ordinary sale nor an ordinary purchase code, and the box stays at zero in the golden scenario.', 'vat-law'),
  ('OM', 'OM-VAT-RETURN', '1f2', 'tax', 'Supply of goods as per profit margin scheme — VAT due', '{"en":"Supply of goods as per profit margin scheme — VAT due"}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Taxpayer Guide — VAT Return Filing, box 1(f): ''VAT is calculated automatically.'' Undriven, for the reason given at box 1(f).', 'return-filing-guide'),
  ('OM', 'OM-VAT-RETURN', '2a', 'base', 'Purchases from the GCC subject to Reverse Charge Mechanism', '{"en":"Purchases from the GCC subject to Reverse Charge Mechanism"}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Taxpayer Guide — VAT Return Filing, box 2(a): ''Not activated until GCC rules apply.'' Undriven, for the reason given at box 1(d).', 'return-filing-guide'),
  ('OM', 'OM-VAT-RETURN', '2a2', 'tax', 'Purchases from the GCC subject to Reverse Charge Mechanism — VAT due', '{"en":"Purchases from the GCC subject to Reverse Charge Mechanism — VAT due"}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Undriven, for the reason given at box 1(d); carried only so the formula of box 5(a) can name it.', 'return-filing-guide'),
  ('OM', 'OM-VAT-RETURN', '2b', 'base', 'Purchases from outside of GCC subject to Reverse Charge Mechanism', '{"en":"Purchases from outside of GCC subject to Reverse Charge Mechanism"}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Taxpayer Guide — VAT Return Filing, box 2(b): ''Total value of standard rated supplies received (excluding VAT), which are subject to Reverse Charge Mechanism.''', 'return-filing-guide'),
  ('OM', 'OM-VAT-RETURN', '2b2', 'tax', 'Purchases from outside of GCC subject to Reverse Charge Mechanism — VAT due', '{"en":"Purchases from outside of GCC subject to Reverse Charge Mechanism — VAT due"}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Taxpayer Guide — VAT Return Filing, box 2(b): ''VAT is calculated automatically.''', 'return-filing-guide'),
  ('OM', 'OM-VAT-RETURN', '3a', 'base', 'Exports', '{"en":"Exports"}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Taxpayer Guide — VAT Return Filing, box 3(a): ''Total value of supplies of goods and services exported on which zero rating for exportation applies. Excludes any out of scope supplies.''', 'return-filing-guide'),
  ('OM', 'OM-VAT-RETURN', '4a', 'base', 'Import of Goods (Postponed payment)', '{"en":"Import of Goods (Postponed payment)"}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Taxpayer Guide — VAT Return Filing, box 4(a): ''Total value of goods imported (excluding VAT) where VAT was postponed on import.''', 'return-filing-guide'),
  ('OM', 'OM-VAT-RETURN', '4a2', 'tax', 'Import of Goods (Postponed payment) — VAT due', '{"en":"Import of Goods (Postponed payment) — VAT due"}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Taxpayer Guide — VAT Return Filing, box 4(a): ''VAT is calculated automatically.''', 'return-filing-guide'),
  ('OM', 'OM-VAT-RETURN', '4b', 'base', 'Total goods imported', '{"en":"Total goods imported"}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Taxpayer Guide — VAT Return Filing, box 4(b): ''Total value of all imports (excluding VAT), including exempt/zero rated goods and those where import VAT has been paid to the Directorate General of Customs. Excludes imports reported in Box 4(a).'' This pack models only the postponed-payment path of box 4(a); an import whose VAT is paid directly at Customs is not driven by any tax code, so this box stays at zero in the golden scenario, which is a gap of coverage and not a claim that no such import exists.', 'return-filing-guide'),
  ('OM', 'OM-VAT-RETURN', '5a', 'total', 'Total VAT due', '{"en":"Total VAT due"}'::jsonb, 170, null, array['1a2', '1f2', '2a2', '2b2', '4a2']::text[], '{}'::text[], null, null, false, false, null, 'VAT Taxpayer Guide — VAT Return Filing, box 5(a): ''Total VAT due under (1(a)+1(f)+2(a)+2(b)+4(a)). Amount is calculated automatically.''', 'return-filing-guide'),
  ('OM', 'OM-VAT-RETURN', '5b', 'tax', 'Adjustment of VAT due', '{"en":"Adjustment of VAT due"}'::jsonb, 180, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Taxpayer Guide — VAT Return Filing, box 5(b): ''Any adjustments to Output VAT due that must be declared in this period including bad debts related to standard rated supplies, refunds, returns, and any other adjustments affecting VAT due.'' No tax code of this pack posts an adjustment; it stays at zero in the golden scenario.', 'return-filing-guide'),
  ('OM', 'OM-VAT-RETURN', '6a', 'base', 'Purchases (except import of goods)', '{"en":"Purchases (except import of goods)"}'::jsonb, 190, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Taxpayer Guide — VAT Return Filing, box 6(a), column 1: ''Total value of all purchases (excluding VAT) including exempt/standard/zero rated purchases and reverse charge purchases. Excludes imported goods, out of scope expenses and purchases of fixed (capital) assets.'' This pack does not duplicate into this box the base value of a reverse-charge purchase already reported at box 2(b), only its deductible Tax at box 6(a2): the duplicate base carries no further arithmetic consequence for the return, and no total of this form sums box 6(a) itself.', 'return-filing-guide'),
  ('OM', 'OM-VAT-RETURN', '6a2', 'tax', 'Purchases (except import of goods) — recoverable VAT', '{"en":"Purchases (except import of goods) — recoverable VAT"}'::jsonb, 200, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Taxpayer Guide — VAT Return Filing, box 6(a), column 2: ''deductible VAT related to your purchases. Amount declared must be after applying any required apportionment. Excludes deductible VAT on fixed (capital) assets.''', 'return-filing-guide'),
  ('OM', 'OM-VAT-RETURN', '6b', 'base', 'Import of goods', '{"en":"Import of goods"}'::jsonb, 210, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Taxpayer Guide — VAT Return Filing, box 6(b), column 1: ''Total value (excluding VAT) of standard rated imports of goods whether or not postponed.'' Not driven by any posting of this pack: the base value of an import already reported at box 4(a) is not duplicated here, only its deductible Tax at box 6(b2).', 'return-filing-guide'),
  ('OM', 'OM-VAT-RETURN', '6b2', 'tax', 'Import of goods — recoverable VAT', '{"en":"Import of goods — recoverable VAT"}'::jsonb, 220, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Taxpayer Guide — VAT Return Filing, box 6(b), column 2: ''deductible VAT related to your imported goods. Amount declared must be after applying any required apportionment.''', 'return-filing-guide'),
  ('OM', 'OM-VAT-RETURN', '6c2', 'tax', 'VAT on acquisition of fixed assets', '{"en":"VAT on acquisition of fixed assets"}'::jsonb, 230, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Taxpayer Guide — VAT Return Filing, box 6(c): ''deductible VAT related to purchase, acquisition or construction of capital assets. Amount declared must be after applying any required apportionment.'' No tax code of this pack distinguishes a capital asset from an ordinary purchase; it stays at zero in the golden scenario, which is a gap of coverage and not a claim that no Omani company buys one.', 'return-filing-guide'),
  ('OM', 'OM-VAT-RETURN', '6d2', 'tax', 'Adjustment of input VAT credit', '{"en":"Adjustment of input VAT credit"}'::jsonb, 240, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Taxpayer Guide — VAT Return Filing, box 6(d): ''Any adjustments to VAT deductible that must be declared in this period including bad debts related to standard rated supplies, refunds, returns, and any other adjustments affecting VAT deductible.'' No tax code of this pack posts an adjustment; it stays at zero in the golden scenario.', 'return-filing-guide'),
  ('OM', 'OM-VAT-RETURN', '7a', 'total', 'Total VAT due', '{"en":"Total VAT due"}'::jsonb, 250, null, array['5a', '5b']::text[], '{}'::text[], null, null, false, false, null, 'VAT Taxpayer Guide — VAT Return Filing, box 7(a): ''Total VAT due (5(a) + 5(b)). Amount calculated automatically.''', 'return-filing-guide'),
  ('OM', 'OM-VAT-RETURN', '7b', 'total', 'Total input VAT credit', '{"en":"Total input VAT credit"}'::jsonb, 260, null, array['6a2', '6b2', '6c2', '6d2']::text[], '{}'::text[], null, null, false, false, null, 'VAT Taxpayer Guide — VAT Return Filing, box 7(b): ''Total value of deductible input VAT in this period (6(a)+6(b)+6(c)+6(d)). Amount calculated automatically.''', 'return-filing-guide'),
  ('OM', 'OM-VAT-RETURN', '7c', 'total', 'Net VAT due (7(a) − 7(b))', '{"en":"Net VAT due (7(a) − 7(b))"}'::jsonb, 270, null, array['7a']::text[], array['7b']::text[], null, null, false, false, null, 'VAT Taxpayer Guide — VAT Return Filing, box 7(c): ''Net (7(a) + 7(b)). Net VAT which maybe either payable or refundable.'' Read together with Article 38 of the Law, which entitles the Taxable Person to a refund where Input Tax exceeds Output Tax, or to carry the excess to a later Tax Period; this pack applies no floor at zero.', 'return-filing-guide')
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
  ('OM-IFRS-IS', 'OM', 'default', 'Income statement — full IFRS Accounting Standards, expenses by nature', 'income_statement', 'OM-IFRS', date '1970-01-01', null, 'As with OM-IFRS-SFP, this pack builds on IAS 1 rather than the simplified sections of the IFRS for SMEs Standard. The lines below are the minimum line items of IAS 1, paragraph 82 (profit or loss), by nature (paragraph 102), which a small Omani company''s ledger holds without an allocation to functions.', 'ifrs-oman-profile'),
  ('OM-IFRS-SFP', 'OM', 'default', 'Statement of financial position — full IFRS Accounting Standards', 'balance_sheet', 'OM-IFRS', date '1970-01-01', null, 'Unlike packs/ae and packs/sa, this pack does not build its statements on the IFRS for SMEs Accounting Standard: the IFRS Foundation''s own Jurisdictional Profile for Oman records that the Sultanate has not adopted that Standard and that every company not required to use it prepares under ''Full IFRS Standards'' instead — which in Oman''s case, on this pack''s reading of the Profile, is every company, not only one whose securities trade in a public market. The lines below are therefore built on the minimum line items of IAS 1 Presentation of Financial Statements, paragraph 54 (the statement of financial position), and paragraph 60 (current and non-current presented separately, which this pack''s research found no Omani text displacing in favour of a liquidity presentation). This is the first thing a reviewer familiar with a real Omani company''s accounts should check.', 'ifrs-oman-profile')
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
  ('OM-IFRS-IS', '1', null, 'Revenue', '{"en":"Revenue"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 82(a).', null),
  ('OM-IFRS-IS', '2', null, 'Other income', '{"en":"Other income"}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 85 — an additional line item: exchange gains and gains on disposal.', null),
  ('OM-IFRS-IS', '3', null, 'Cost of sales', '{"en":"Cost of sales"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 102 — expenses analysed by their nature.', null),
  ('OM-IFRS-IS', '4', null, 'Employee benefits expense', '{"en":"Employee benefits expense"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 102 — employee benefits, the end-of-service benefits charge among them.', null),
  ('OM-IFRS-IS', '5', null, 'Depreciation and amortisation', '{"en":"Depreciation and amortisation"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 102.', null),
  ('OM-IFRS-IS', '6', null, 'Other operating expenses', '{"en":"Other operating expenses"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 102 — the other expenses by nature, non-recoverable VAT and exchange losses among them.', null),
  ('OM-IFRS-IS', '7', null, 'Finance costs', '{"en":"Finance costs"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 82(b).', null),
  ('OM-IFRS-IS', '8', null, 'Profit before income tax', '{"en":"Profit before income tax"}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('OM-IFRS-IS', '9', null, 'Income tax expense', '{"en":"Income tax expense"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 82(d) — tax expense. The Income Tax Law (Royal Decree 28/2009), which taxes an Omani company at a standard rate of 15%, is outside this VAT-focused pack''s research; the account exists for a company to book the charge by hand.', null),
  ('OM-IFRS-IS', '10', null, 'Profit for the year', '{"en":"Profit for the year"}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, 'IAS 1, paragraph 81A(a) — profit or loss. The pack carries no item of other comprehensive income, so it is also the total comprehensive income.', null),
  ('OM-IFRS-SFP', 'CA', null, 'Current assets', '{"en":"Current assets"}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5', 'CA.6']::text[], '{}'::text[], null, 'IAS 1, paragraph 60 — current and non-current assets are presented as separate classifications unless a liquidity presentation provides information that is reliable and more relevant.', null),
  ('OM-IFRS-SFP', 'CA.1', 'CA', 'Cash and cash equivalents', '{"en":"Cash and cash equivalents"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(i).', null),
  ('OM-IFRS-SFP', 'CA.2', 'CA', 'Trade and other receivables', '{"en":"Trade and other receivables"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(h). VAT input tax and the amount refundable by the Tax Authority are presented here rather than as current tax, which paragraph 54(n) keeps for income tax under the Income Tax Law.', null),
  ('OM-IFRS-SFP', 'CA.3', 'CA', 'Inventories', '{"en":"Inventories"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(g).', null),
  ('OM-IFRS-SFP', 'CA.4', 'CA', 'Financial assets', '{"en":"Financial assets"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(d), the part realised within twelve months.', null),
  ('OM-IFRS-SFP', 'CA.5', 'CA', 'Current tax assets', '{"en":"Current tax assets"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(n) — assets for current tax, income tax under the Income Tax Law (Royal Decree 28/2009), which this VAT-focused pack does not otherwise carry.', null),
  ('OM-IFRS-SFP', 'CA.6', 'CA', 'Prepayments and accrued income', '{"en":"Prepayments and accrued income"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 55 — an additional line item relevant to an understanding of the financial position.', null),
  ('OM-IFRS-SFP', 'NCA', null, 'Non-current assets', '{"en":"Non-current assets"}'::jsonb, 80, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4']::text[], '{}'::text[], null, 'IAS 1, paragraph 60 — every asset that is not current is non-current.', null),
  ('OM-IFRS-SFP', 'NCA.1', 'NCA', 'Property, plant and equipment', '{"en":"Property, plant and equipment"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(a).', null),
  ('OM-IFRS-SFP', 'NCA.2', 'NCA', 'Investments', '{"en":"Investments"}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(e).', null),
  ('OM-IFRS-SFP', 'NCA.3', 'NCA', 'Other non-current assets', '{"en":"Other non-current assets"}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 55 — a long-term deposit or retention held is not one of the named items of paragraph 54 and is presented as an additional line.', null),
  ('OM-IFRS-SFP', 'NCA.4', 'NCA', 'Intangible assets', '{"en":"Intangible assets"}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(c), goodwill with them.', null),
  ('OM-IFRS-SFP', 'TA', null, 'Total assets', '{"en":"Total assets"}'::jsonb, 130, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('OM-IFRS-SFP', 'CL', null, 'Current liabilities', '{"en":"Current liabilities"}'::jsonb, 140, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4']::text[], '{}'::text[], null, 'IAS 1, paragraph 60.', null),
  ('OM-IFRS-SFP', 'CL.1', 'CL', 'Trade and other payables', '{"en":"Trade and other payables"}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(k). VAT output tax and the amount payable to the Tax Authority are presented here.', null),
  ('OM-IFRS-SFP', 'CL.2', 'CL', 'Borrowings and other financial liabilities', '{"en":"Borrowings and other financial liabilities"}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(m), the part due within twelve months.', null),
  ('OM-IFRS-SFP', 'CL.3', 'CL', 'Current tax liabilities', '{"en":"Current tax liabilities"}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(n) — liabilities for current tax.', null),
  ('OM-IFRS-SFP', 'CL.4', 'CL', 'Provisions', '{"en":"Provisions"}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(l), the part expected to be settled within twelve months — the current portion of the end-of-service benefits provision.', null),
  ('OM-IFRS-SFP', 'NCL', null, 'Non-current liabilities', '{"en":"Non-current liabilities"}'::jsonb, 190, 1, true, array['NCL.1', 'NCL.2']::text[], '{}'::text[], null, 'IAS 1, paragraph 60.', null),
  ('OM-IFRS-SFP', 'NCL.1', 'NCL', 'Borrowings and other financial liabilities', '{"en":"Borrowings and other financial liabilities"}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(m), the part not due within twelve months.', null),
  ('OM-IFRS-SFP', 'NCL.2', 'NCL', 'Provisions', '{"en":"Provisions"}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(l), the part not expected to be settled within twelve months — the end-of-service benefits provision, which this pack''s research did not trace to a specific article of the Labour Law and which a reviewer should check.', null),
  ('OM-IFRS-SFP', 'TL', null, 'Total liabilities', '{"en":"Total liabilities"}'::jsonb, 220, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('OM-IFRS-SFP', 'NA', null, 'Net assets', '{"en":"Net assets"}'::jsonb, 230, 1, true, array['TA']::text[], array['TL']::text[], null, 'IAS 1, paragraph 55 — an additional subtotal. It equals total equity once the year is closed; before, it exceeds equity by the result of the open year.', null),
  ('OM-IFRS-SFP', 'EQ', null, 'Equity', '{"en":"Equity"}'::jsonb, 240, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, 'IAS 1, paragraph 54(r) — equity attributable to owners of the parent, and paragraph 79 for its classes.', null),
  ('OM-IFRS-SFP', 'EQ.1', 'EQ', 'Share capital', '{"en":"Share capital"}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 79(a)(i).', null),
  ('OM-IFRS-SFP', 'EQ.2', 'EQ', 'Reserves', '{"en":"Reserves"}'::jsonb, 260, -1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 79(b) — the statutory reserve an Omani company is commonly required to build from its annual profit, which this pack''s research did not trace to a specific article of the Commercial Companies Law (Royal Decree 18/2019) and which a reviewer should check, and any other reserve.', null),
  ('OM-IFRS-SFP', 'EQ.3', 'EQ', 'Retained earnings', '{"en":"Retained earnings"}'::jsonb, 270, -1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 79(b) — retained earnings, after the dividends paid booked beside them.', null)
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
    ('OM-IFRS-IS', '1', 10, 'code_range', '4000', '4050', null, 'any'),
    ('OM-IFRS-IS', '2', 10, 'code_range', '4700', '4790', null, 'any'),
    ('OM-IFRS-IS', '3', 10, 'code_range', '5000', '5030', null, 'any'),
    ('OM-IFRS-IS', '4', 10, 'code_range', '6100', '6140', null, 'any'),
    ('OM-IFRS-IS', '5', 10, 'code_range', '6500', '6510', null, 'any'),
    ('OM-IFRS-IS', '6', 10, 'code_range', '6200', '6440', null, 'any'),
    ('OM-IFRS-IS', '6', 20, 'code_range', '6950', '6990', null, 'any'),
    ('OM-IFRS-IS', '7', 10, 'code_range', '7100', '7110', null, 'any'),
    ('OM-IFRS-IS', '9', 10, 'account_code', '8000', null, null, 'any'),
    ('OM-IFRS-SFP', 'CA.1', 10, 'code_range', '1000', '1050', null, 'any'),
    ('OM-IFRS-SFP', 'CA.2', 10, 'code_range', '1100', '1160', null, 'any'),
    ('OM-IFRS-SFP', 'CA.2', 20, 'account_code', '2990', null, null, 'debit'),
    ('OM-IFRS-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('OM-IFRS-SFP', 'CA.4', 10, 'account_code', '1300', null, null, 'any'),
    ('OM-IFRS-SFP', 'CA.5', 10, 'account_code', '1350', null, null, 'any'),
    ('OM-IFRS-SFP', 'CA.6', 10, 'code_range', '1400', '1430', null, 'any'),
    ('OM-IFRS-SFP', 'NCA.1', 10, 'code_range', '1600', '1691', null, 'any'),
    ('OM-IFRS-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('OM-IFRS-SFP', 'NCA.3', 10, 'account_code', '1710', null, null, 'any'),
    ('OM-IFRS-SFP', 'NCA.4', 10, 'code_range', '1730', '1751', null, 'any'),
    ('OM-IFRS-SFP', 'CL.1', 10, 'code_range', '2000', '2060', null, 'any'),
    ('OM-IFRS-SFP', 'CL.1', 20, 'code_range', '2100', '2110', null, 'any'),
    ('OM-IFRS-SFP', 'CL.1', 30, 'account_code', '2990', null, null, 'credit'),
    ('OM-IFRS-SFP', 'CL.2', 10, 'code_range', '2200', '2210', null, 'any'),
    ('OM-IFRS-SFP', 'CL.3', 10, 'account_code', '2130', null, null, 'any'),
    ('OM-IFRS-SFP', 'CL.4', 10, 'account_code', '2150', null, null, 'any'),
    ('OM-IFRS-SFP', 'NCL.1', 10, 'account_code', '2300', null, null, 'any'),
    ('OM-IFRS-SFP', 'NCL.2', 10, 'code_range', '2320', '2350', null, 'any'),
    ('OM-IFRS-SFP', 'EQ.1', 10, 'account_code', '3000', null, null, 'any'),
    ('OM-IFRS-SFP', 'EQ.2', 10, 'code_range', '3010', '3030', null, 'any'),
    ('OM-IFRS-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('OM', 'Oman', '{"en":"Oman"}'::jsonb, array['ar', 'en']::text[], 'OMR', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'ar', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, 'quarter'::declaration_period)
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
  numbering_legal_reference     = 'Executive Regulations (Decision No. 53/2021, as amended), Article 144(3) — a Tax Invoice carries ''the sequential number of the Tax Invoice'' (الرقم التسلسلي للفاتورة الضريبية). The article asks for a running, identifying number and not, in the text this pack''s research could open, that the series carry no gap, which is why the style is `sequential` and not a gapless one. The pattern in `number_format` is one a business may choose.',
  numbering_source_key          = 'vat-exec-reg',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Value Added Tax Law (Royal Decree No. 121/2020), Article 26 — ''The Tax on the supply of Goods or Services shall be due on any of the following dates whichever is earlier: 1. Date of the supply. 2. Date of issuance of the Tax Invoice. 3. Date of partial or full receipt of the Consideration, and to the extent of the received amount.'' That is a three-way earliest test — supply, invoice, payment — and the closed vocabulary of this field has no value for three triggers at once. `earliest_of_delivery_or_payment` is the nearest of the five and is what the rule reduces to in the ordinary case, exactly the gap packs/ae and packs/sa record for the same three-way wording in Federal Decree-Law No. 8 of 2017 and the Common VAT Agreement; a supply invoiced ahead of delivery or payment is the case this approximation misses.',
  tax_point_source_key          = 'vat-law',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'At released_at no statute obliges an Omani taxable person to exchange electronic invoices: the Tax Authority''s own Fawtara FAQ, updated 30 June 2026, answers ''Are there released or upcoming regulations for e-invoicing compliance?'' with ''Regulation for e-invoicing will be released in due time'' — the executive legislation the FAQ elsewhere calls ''the upcoming legislation'' has not been issued. What exists instead is a project, not yet a law: the Tax Authority became an OpenPeppol Authority and published the PINT OM technical specification (Billing and Self-Billing) in 2026, built on a five-corner Peppol model in which an accredited Service Provider (Corner 2 or 3) validates and exchanges the structured invoice and reports tax data to the Authority (Corner 5); the FAQ''s own timeline answer is narrower than the four-phase calendar this pack''s research found repeated on unofficial tax-technology sites, and this pack does not carry a date no official text confirms: ''The first rollout is in August 2026. Subsequent rollouts will follow according to the timeline that will be prescribed in the legislation.'' That first rollout is a named, individually-notified group of about 100 large taxpayers, checked one VATIN at a time at the Authority''s own ''rollout-checking'' service — not a rule reaching every registrant, which is why `obligation` is `none` and not `mandatory` with a date this pack cannot cite. No brick of packages/formats writes PINT OM (a UBL 2.1 profile derived from Peppol BIS Billing 3.0 with an Oman-specific data dictionary) or talks to an Accredited Service Provider, so the four fields above would describe a capability this pack does not have even for the taxpayers already onboarded. The Peppol participant identifier scheme list carries one Omani entry, ICD 0248, ''Oman Value Added Tax Identification Number (VATIN)'' — the figure a party would be addressed by if this pack modelled the network — named here and not in `party_scheme` or `vat_scheme` because nothing yet obliges its use. docs/international.md carries the rest of what the core cannot say about a project still short of its own legislation.',
  einvoice_source_key           = 'fawtara-faq',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'OM';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('OM', 'reverse_charge', 'reverse_charge', 'Reverse charge: the Customer is liable to account for the Value Added Tax due on this supply, and must record its value in Omani Rial, under Article 20 and Article 151 of the Executive Regulations of the Value Added Tax Law.', '{"en":"Reverse charge: the Customer is liable to account for the Value Added Tax due on this supply, and must record its value in Omani Rial, under Article 20 and Article 151 of the Executive Regulations of the Value Added Tax Law."}'::jsonb, 10, date '1970-01-01', null, 'Executive Regulations, Article 151 — ''The Customer who is liable for the payment of Tax must, in the cases where the Reverse Calculation (Charge) mechanism applies, record in the Tax Invoice issued in his favour by the Supplier who has no Place of Residence in the Sultanate the value of the Tax due on the supply in Omani Rial, and the supply is subject to the Reverse Calculation (Charge) mechanism.'' This pack''s research found no article requiring a printed sentence on the invoice itself, unlike the Saudi Implementing Regulations packs/sa records for the same case; the wording above is this pack''s own, addressed to whoever reads the invoice rather than transcribed from the text.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
