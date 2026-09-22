-- Ekwo OS — United Arab Emirates: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/ae at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build ae`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Federal Decree-Law No. 8 of 2017 on Value Added Tax, and its amendments (consolidated text, publishing 28 November 2025) (Ministry of Finance, published by the Federal Tax Authority)
--     https://tax.gov.ae//Datafolder/Files/Legislation/2025/Federal%20Decree-Law%20No.%208%20of%202017%20and%20amendments%20-%20publishing%2028%2011%202025.pdf
--   Cabinet Decision No. 52 of 2017 on the Executive Regulation of Federal Decree-Law No. 8 of 2017 on Value Added Tax, and its amendments (consolidated text, publishing 10 September 2026) (Ministry of Finance, published by the Federal Tax Authority)
--     https://tax.gov.ae//Datafolder/Files/Legislation/2026/Law-No-8-of-2017-and-its-amendments--09-2026.pdf
--   Filing VAT Returns and Making Payments (Federal Tax Authority)
--     https://tax.gov.ae/en/taxes/Vat/vat.topics/filing.vat.returns.and.making.payments.aspx
--   Value Added Tax (VAT) (Ministry of Finance)
--     https://mof.gov.ae/en/public-finance/tax/value-added-tax-vat/
--   UAE Electronic Invoicing Guidelines, Version 1.1, 1 June 2026 (Ministry of Finance)
--     https://mof.gov.ae/wp-content/uploads/2026/06/UAE-Electronic-Invoicing-Guidelines_V-1.1-01June2026.pdf
--   UAE E-Invoicing (Federal Tax Authority)
--     https://tax.gov.ae/en/content/uae.einvoicing.aspx
--   e-Invoicing — Ministry of Finance initiative portal (Ministry of Finance)
--     https://mof.gov.ae/en/about-ministry/mof-initiatives/einvoicing/
--   Ministerial Decision No. 64 of 2025 on the Eligibility Criteria and Accreditation Procedure for Service Providers under the Electronic Invoicing System, and its amendments (Ministry of Finance, published by the Federal Tax Authority)
--     https://tax.gov.ae//Datafolder/Files/Legislation/2026/Ministerial%20Decision%20No.%2064%20of%202025%20and%20its%20amendments%20-%20publishing.pdf
--   Federal Tax Authority Decision No. 4 of 2026 on the Rules and Requirements for Maintaining the Information Contained in Accounting Records and Commercial Books (Federal Tax Authority)
--     https://tax.gov.ae//Datafolder/Files/Legislation/2026/FTA%20Decision%20No.%204%20of%202026%20on%20the%20Rules%20and%20Requirements%20-%2018%2008%202026.pdf
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('AE', 'United Arab Emirates', '0.1.0', date '2026-09-22', '20260917170000', 'community', null, null, '7a919c989acc3d7b572fb50806d4113dda6fa06d9e35d670c4eab2e54a0fd08c', '[{"key":"vat-decree-law","title":"Federal Decree-Law No. 8 of 2017 on Value Added Tax, and its amendments (consolidated text, publishing 28 November 2025)","publisher":"Ministry of Finance, published by the Federal Tax Authority","url":"https://tax.gov.ae//Datafolder/Files/Legislation/2025/Federal%20Decree-Law%20No.%208%20of%202017%20and%20amendments%20-%20publishing%2028%2011%202025.pdf","consulted_on":"2026-09-22","kind":"law"},{"key":"vat-exec-reg","title":"Cabinet Decision No. 52 of 2017 on the Executive Regulation of Federal Decree-Law No. 8 of 2017 on Value Added Tax, and its amendments (consolidated text, publishing 10 September 2026)","publisher":"Ministry of Finance, published by the Federal Tax Authority","url":"https://tax.gov.ae//Datafolder/Files/Legislation/2026/Law-No-8-of-2017-and-its-amendments--09-2026.pdf","consulted_on":"2026-09-22","kind":"regulation"},{"key":"fta-filing","title":"Filing VAT Returns and Making Payments","publisher":"Federal Tax Authority","url":"https://tax.gov.ae/en/taxes/Vat/vat.topics/filing.vat.returns.and.making.payments.aspx","consulted_on":"2026-09-22","kind":"guidance"},{"key":"mof-vat","title":"Value Added Tax (VAT)","publisher":"Ministry of Finance","url":"https://mof.gov.ae/en/public-finance/tax/value-added-tax-vat/","consulted_on":"2026-09-22","kind":"guidance"},{"key":"mof-einvoicing-guide","title":"UAE Electronic Invoicing Guidelines, Version 1.1, 1 June 2026","publisher":"Ministry of Finance","url":"https://mof.gov.ae/wp-content/uploads/2026/06/UAE-Electronic-Invoicing-Guidelines_V-1.1-01June2026.pdf","consulted_on":"2026-09-22","kind":"guidance"},{"key":"fta-einvoicing-portal","title":"UAE E-Invoicing","publisher":"Federal Tax Authority","url":"https://tax.gov.ae/en/content/uae.einvoicing.aspx","consulted_on":"2026-09-22","kind":"portal"},{"key":"mof-einvoicing-portal","title":"e-Invoicing — Ministry of Finance initiative portal","publisher":"Ministry of Finance","url":"https://mof.gov.ae/en/about-ministry/mof-initiatives/einvoicing/","consulted_on":"2026-09-22","kind":"portal"},{"key":"fta-md64","title":"Ministerial Decision No. 64 of 2025 on the Eligibility Criteria and Accreditation Procedure for Service Providers under the Electronic Invoicing System, and its amendments","publisher":"Ministry of Finance, published by the Federal Tax Authority","url":"https://tax.gov.ae//Datafolder/Files/Legislation/2026/Ministerial%20Decision%20No.%2064%20of%202025%20and%20its%20amendments%20-%20publishing.pdf","consulted_on":"2026-09-22","kind":"regulation"},{"key":"fta-acc-records","title":"Federal Tax Authority Decision No. 4 of 2026 on the Rules and Requirements for Maintaining the Information Contained in Accounting Records and Commercial Books","publisher":"Federal Tax Authority","url":"https://tax.gov.ae//Datafolder/Files/Legislation/2026/FTA%20Decision%20No.%204%20of%202026%20on%20the%20Rules%20and%20Requirements%20-%2018%2008%202026.pdf","consulted_on":"2026-09-22","kind":"regulation"}]'::jsonb)
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
  ('AE', 'default', 'United Arab Emirates reference chart of accounts', '{}'::jsonb, true, 'companies', array['AE-IFRSSME-IS', 'AE-IFRSSME-SFP']::text[], null, 'There is no legal chart of accounts in the United Arab Emirates. Federal Decree-Law No. 32 of 2021 on Commercial Companies requires a company to keep accounting records and prepare financial statements, and its Corporate Tax counterpart, Federal Decree-Law No. 47 of 2022, taxes a person on the accounting income of financial statements prepared under internationally-accepted accounting standards — in practice IFRS, and IFRS for Small and Medium-sized Entities for a smaller taxpayer. This pack''s research could not open an official, directly-fetchable text of Federal Decree-Law No. 32 of 2021 to cite its own article: uaelegislation.gov.ae refused every unauthenticated request tried, and the Ministry of Economy and Tourism''s own site returned no working legislation link in this pass. Nothing here was patched around that gap — it is named so a reviewer checks it first, the same way packs/sg/ names the SFRS for Small Entities text it could not open and packs/hk/ names the HKFRS text it could not open. The chart itself is original: four digits, blocked so that each range reaches one line item of the statement of financial position and the income statement of the IFRS for SMEs Accounting Standard, with the accounts a UAE company actually keeps — VAT input and output tax, VAT payable to and receivable from the Federal Tax Authority, import VAT awaiting a customs declaration, and a provision for employees'' end-of-service gratuity, which this pack''s research did not trace to a specific article of the Labour Law (Federal Decree-Law No. 33 of 2021) and which a reviewer should check as well.', 'vat-decree-law')
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
  ('AE', 'default', '1000', 'Petty cash', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('AE', 'default', '1010', 'Current account — AED', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('AE', 'default', '1020', 'Fixed deposits placed for three months or less', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('AE', 'default', '1030', 'Foreign currency account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('AE', 'default', '1040', 'Cash in transit — card and payment gateway settlements', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('AE', 'default', '1050', 'Money market funds', '{}'::jsonb, 'asset_cash', false, null, 55),
  ('AE', 'default', '1100', 'Trade receivables', '{}'::jsonb, 'asset_receivable', true, null, 60),
  ('AE', 'default', '1110', 'Trade receivables — allowance for impairment', '{}'::jsonb, 'asset_current', false, null, 70),
  ('AE', 'default', '1120', 'Other receivables', '{}'::jsonb, 'asset_current', true, null, 80),
  ('AE', 'default', '1130', 'Amounts due from related parties', '{}'::jsonb, 'asset_current', false, null, 90),
  ('AE', 'default', '1140', 'Deposits paid', '{}'::jsonb, 'asset_current', false, null, 100),
  ('AE', 'default', '1145', 'Loans to employees', '{}'::jsonb, 'asset_current', false, null, 135),
  ('AE', 'default', '1150', 'VAT input tax', '{}'::jsonb, 'asset_current', false, null, 110),
  ('AE', 'default', '1155', 'VAT refundable by the Federal Tax Authority — net of a filed return', '{}'::jsonb, 'asset_current', true, null, 120),
  ('AE', 'default', '1157', 'Import VAT self-assessed — awaiting the supplier''s goods', '{}'::jsonb, 'asset_current', false, null, 130),
  ('AE', 'default', '1160', 'Advances to staff', '{}'::jsonb, 'asset_current', false, null, 140),
  ('AE', 'default', '1200', 'Inventories — goods for resale', '{}'::jsonb, 'asset_current', false, null, 150),
  ('AE', 'default', '1210', 'Inventories — raw materials', '{}'::jsonb, 'asset_current', false, null, 160),
  ('AE', 'default', '1220', 'Inventories — work in progress', '{}'::jsonb, 'asset_current', false, null, 170),
  ('AE', 'default', '1230', 'Inventories — finished goods', '{}'::jsonb, 'asset_current', false, null, 180),
  ('AE', 'default', '1300', 'Short-term investments', '{}'::jsonb, 'asset_current', false, null, 190),
  ('AE', 'default', '1350', 'Corporate tax recoverable', '{}'::jsonb, 'asset_current', false, null, 200),
  ('AE', 'default', '1400', 'Prepayments', '{}'::jsonb, 'asset_prepayments', false, null, 210),
  ('AE', 'default', '1410', 'Accrued income', '{}'::jsonb, 'asset_prepayments', false, null, 220),
  ('AE', 'default', '1420', 'Prepaid rent', '{}'::jsonb, 'asset_prepayments', false, null, 222),
  ('AE', 'default', '1430', 'Prepaid insurance', '{}'::jsonb, 'asset_prepayments', false, null, 224),
  ('AE', 'default', '1600', 'Land and buildings — cost', '{}'::jsonb, 'asset_fixed', false, null, 230),
  ('AE', 'default', '1601', 'Land and buildings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 240),
  ('AE', 'default', '1610', 'Leasehold improvements — cost', '{}'::jsonb, 'asset_fixed', false, null, 250),
  ('AE', 'default', '1611', 'Leasehold improvements — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('AE', 'default', '1620', 'Plant and machinery — cost', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('AE', 'default', '1621', 'Plant and machinery — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('AE', 'default', '1630', 'Office equipment and computers — cost', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('AE', 'default', '1631', 'Office equipment and computers — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('AE', 'default', '1632', 'Furniture and fixtures — cost', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('AE', 'default', '1633', 'Furniture and fixtures — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('AE', 'default', '1640', 'Motor vehicles — cost', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('AE', 'default', '1641', 'Motor vehicles — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('AE', 'default', '1650', 'Capital work in progress', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('AE', 'default', '1690', 'Right-of-use assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 352),
  ('AE', 'default', '1691', 'Right-of-use assets — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 354),
  ('AE', 'default', '1700', 'Investments in related parties', '{}'::jsonb, 'asset_non_current', false, null, 360),
  ('AE', 'default', '1710', 'Long-term deposits and retentions held', '{}'::jsonb, 'asset_non_current', false, null, 370),
  ('AE', 'default', '1730', 'Goodwill', '{}'::jsonb, 'asset_non_current', false, null, 375),
  ('AE', 'default', '1750', 'Intangible assets — cost', '{}'::jsonb, 'asset_non_current', false, null, 380),
  ('AE', 'default', '1751', 'Intangible assets — accumulated amortisation', '{}'::jsonb, 'asset_non_current', false, null, 390),
  ('AE', 'default', '2000', 'Trade payables', '{}'::jsonb, 'liability_payable', true, null, 400),
  ('AE', 'default', '2010', 'Other payables and accruals', '{}'::jsonb, 'liability_current', false, null, 410),
  ('AE', 'default', '2020', 'Amounts due to related parties', '{}'::jsonb, 'liability_current', false, null, 420),
  ('AE', 'default', '2030', 'Amounts due to directors and shareholders', '{}'::jsonb, 'liability_current', false, null, 430),
  ('AE', 'default', '2040', 'Deposits received', '{}'::jsonb, 'liability_current', false, null, 440),
  ('AE', 'default', '2045', 'Deferred revenue', '{}'::jsonb, 'liability_current', false, null, 445),
  ('AE', 'default', '2050', 'Wages and salaries payable', '{}'::jsonb, 'liability_current', false, null, 450),
  ('AE', 'default', '2055', 'Wage Protection System clearing account', '{}'::jsonb, 'liability_current', false, null, 455),
  ('AE', 'default', '2100', 'VAT output tax', '{}'::jsonb, 'liability_current', false, null, 460),
  ('AE', 'default', '2110', 'VAT payable to the Federal Tax Authority — net of a filed return', '{}'::jsonb, 'liability_current', true, null, 470),
  ('AE', 'default', '2130', 'Corporate tax payable', '{}'::jsonb, 'liability_current', false, null, 480),
  ('AE', 'default', '2150', 'End-of-service gratuity payable — current portion', '{}'::jsonb, 'liability_current', false, null, 490),
  ('AE', 'default', '2200', 'Short-term loans and bank overdraft', '{}'::jsonb, 'liability_current', false, null, 500),
  ('AE', 'default', '2210', 'Current portion of long-term loans', '{}'::jsonb, 'liability_current', false, null, 510),
  ('AE', 'default', '2300', 'Long-term loans', '{}'::jsonb, 'liability_non_current', false, null, 520),
  ('AE', 'default', '2320', 'Provision for onerous contracts', '{}'::jsonb, 'liability_non_current', false, null, 525),
  ('AE', 'default', '2350', 'End-of-service gratuity provision — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 530),
  ('AE', 'default', '2990', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 540),
  ('AE', 'default', '3000', 'Share capital', '{}'::jsonb, 'equity', false, null, 550),
  ('AE', 'default', '3010', 'Statutory reserve', '{}'::jsonb, 'equity', false, null, 560),
  ('AE', 'default', '3020', 'Other reserves', '{}'::jsonb, 'equity', false, null, 570),
  ('AE', 'default', '3030', 'Foreign currency translation reserve', '{}'::jsonb, 'equity', false, null, 575),
  ('AE', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 580),
  ('AE', 'default', '3210', 'Dividends paid', '{}'::jsonb, 'equity_retained', false, null, 590),
  ('AE', 'default', '4000', 'Sales of goods', '{}'::jsonb, 'income', false, null, 600),
  ('AE', 'default', '4010', 'Sales of services', '{}'::jsonb, 'income', false, null, 610),
  ('AE', 'default', '4020', 'Sales — export of goods', '{}'::jsonb, 'income', false, null, 620),
  ('AE', 'default', '4030', 'Sales — export of services', '{}'::jsonb, 'income', false, null, 630),
  ('AE', 'default', '4040', 'Rental income', '{}'::jsonb, 'income', false, null, 640),
  ('AE', 'default', '4700', 'Realised foreign exchange gain', '{}'::jsonb, 'income_other', false, null, 650),
  ('AE', 'default', '4710', 'Unrealised foreign exchange gain', '{}'::jsonb, 'income_other', false, null, 660),
  ('AE', 'default', '4750', 'Gain on disposal of fixed assets', '{}'::jsonb, 'income_other', false, null, 670),
  ('AE', 'default', '4790', 'Other income', '{}'::jsonb, 'income_other', false, null, 680),
  ('AE', 'default', '5000', 'Cost of goods sold', '{}'::jsonb, 'expense_direct_cost', false, null, 690),
  ('AE', 'default', '5010', 'Freight and customs clearance', '{}'::jsonb, 'expense_direct_cost', false, null, 700),
  ('AE', 'default', '5020', 'Subcontractor costs', '{}'::jsonb, 'expense_direct_cost', false, null, 710),
  ('AE', 'default', '5030', 'Purchase returns and allowances', '{}'::jsonb, 'expense_direct_cost', false, null, 715),
  ('AE', 'default', '6100', 'Salaries and wages', '{}'::jsonb, 'expense', false, null, 720),
  ('AE', 'default', '6110', 'End-of-service gratuity charge for the year', '{}'::jsonb, 'expense', false, null, 730),
  ('AE', 'default', '6120', 'Staff health insurance', '{}'::jsonb, 'expense', false, null, 740),
  ('AE', 'default', '6130', 'Other staff costs', '{}'::jsonb, 'expense', false, null, 750),
  ('AE', 'default', '6140', 'Recruitment and training', '{}'::jsonb, 'expense', false, null, 755),
  ('AE', 'default', '6200', 'Rent', '{}'::jsonb, 'expense', false, null, 760),
  ('AE', 'default', '6210', 'Utilities', '{}'::jsonb, 'expense', false, null, 770),
  ('AE', 'default', '6220', 'Office supplies', '{}'::jsonb, 'expense', false, null, 780),
  ('AE', 'default', '6230', 'IT and software', '{}'::jsonb, 'expense', false, null, 790),
  ('AE', 'default', '6240', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 800),
  ('AE', 'default', '6300', 'Travel', '{}'::jsonb, 'expense', false, null, 810),
  ('AE', 'default', '6310', 'Entertainment — not recoverable for VAT', '{}'::jsonb, 'expense', false, null, 820),
  ('AE', 'default', '6320', 'Motor vehicle running costs', '{}'::jsonb, 'expense', false, null, 830),
  ('AE', 'default', '6400', 'Professional fees', '{}'::jsonb, 'expense', false, null, 840),
  ('AE', 'default', '6410', 'Bank charges', '{}'::jsonb, 'expense', false, null, 850),
  ('AE', 'default', '6420', 'Insurance', '{}'::jsonb, 'expense', false, null, 860),
  ('AE', 'default', '6430', 'Marketing and advertising', '{}'::jsonb, 'expense', false, null, 870),
  ('AE', 'default', '6435', 'Subscriptions and memberships', '{}'::jsonb, 'expense', false, null, 875),
  ('AE', 'default', '6440', 'Licence fees and government charges', '{}'::jsonb, 'expense', false, null, 880),
  ('AE', 'default', '6500', 'Depreciation charge', '{}'::jsonb, 'expense_depreciation', false, null, 890),
  ('AE', 'default', '6510', 'Amortisation charge', '{}'::jsonb, 'expense_depreciation', false, null, 900),
  ('AE', 'default', '6950', 'Realised foreign exchange loss', '{}'::jsonb, 'expense', false, null, 910),
  ('AE', 'default', '6955', 'Unrealised foreign exchange loss', '{}'::jsonb, 'expense', false, null, 920),
  ('AE', 'default', '6960', 'Loss on disposal of fixed assets', '{}'::jsonb, 'expense', false, null, 930),
  ('AE', 'default', '6990', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 940),
  ('AE', 'default', '7100', 'Interest and finance charges', '{}'::jsonb, 'expense', false, null, 950),
  ('AE', 'default', '7110', 'Bank facility and arrangement fees', '{}'::jsonb, 'expense', false, null, 955),
  ('AE', 'default', '8000', 'Corporate tax charge for the year', '{}'::jsonb, 'expense', false, null, 960)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('AE', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('AE', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('AE', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('AE', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('AE', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('AE', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('AE', 'AE-P-BL-CAR', 'Purchase, standard-rated, motor vehicle available for personal use — input tax not recoverable', '{}'::jsonb, 'A motor vehicle purchased, rented or leased for use in the Business and available for the personal use of any Person, other than a taxi, an emergency vehicle or a vehicle rented out in a vehicle rental business.', 'percent', 5, 'purchase', 'domestic', date '2018-01-01', null, 'Executive Regulation, Article 53(1)(b) and (4). The Tax is not recoverable and lands on the account of the line it taxes rather than on 1150, and is not reported in any box of the return.', 'S', null, 140, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'vat-exec-reg', null, null, null, null),
  ('AE', 'AE-P-BL-ENT', 'Purchase, standard-rated, entertainment — input tax not recoverable', '{}'::jsonb, 'Hospitality of any kind — accommodation, food and drink outside the normal course of a meeting, access to shows or events, or a trip for pleasure — provided to anyone not employed by the Person, including customers and potential customers.', 'percent', 5, 'purchase', 'domestic', date '2018-01-01', null, 'Executive Regulation, Article 53(1)(a) and (2)(a). The Tax is not recoverable and lands on the account of the line it taxes rather than on 1150, and is not reported in any box of the return: Article 64(5)(h) reports only expenses incurred for the purposes of recovering Input Tax.', 'S', null, 130, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'vat-exec-reg', null, null, null, null),
  ('AE', 'AE-P-DRC-HC', 'Purchase, domestic reverse charge, crude oil, natural gas or pure hydrocarbons', '{}'::jsonb, 'The mirror of AE-S-DRC-HC on the buyer''s side: the Recipient of crude or refined oil, unprocessed or processed natural gas, or pure hydrocarbons intended for resale or for energy production, self-assesses the Tax the supplier did not charge.', 'percent', 5, 'purchase', 'domestic_reverse_charge', date '2018-01-01', null, 'Federal Decree-Law No. 8 of 2017, Article 48(3)(b): ''The Recipient of the Goods shall calculate the Tax on the value of the Goods supplied to him and shall be responsible for all applicable Tax obligations.'' Reported in box g1 and g2 like an import under Article 64(5)(g), which names ''Clauses 1 and 3 of Article 48'' together; recoverable in box h2 to the extent the Goods are used for a taxable supply.', 'AE', null, 200, 'vat', true, array['buyer_certificate', 'buyer_status']::tax_condition[], null, false, false, null, 'vat-decree-law', null, null, null, null),
  ('AE', 'AE-P-EX', 'Purchase, exempt', '{}'::jsonb, 'A purchase of an exempt supply — a long lease of a residential building, bare land, local passenger transport, or a financial service on margin.', 'percent', 0, 'purchase', 'exempt', date '2018-01-01', null, 'Federal Decree-Law No. 8 of 2017, Article 46. Not reported on any box: an exempt purchase carries no Input Tax and Article 64(5)(h) reports only expenses incurred for the purposes of recovering Input Tax.', 'E', null, 160, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-decree-law', null, null, null, null),
  ('AE', 'AE-P-IMP', 'Purchase, import of goods under the reverse charge', '{}'::jsonb, 'Goods imported into the State by a Taxable Person for the purposes of their Business, who is treated as making a Taxable Supply to themselves under Article 48(1) of the Decree-Law.', 'percent', 5, 'purchase', 'import', date '2018-01-01', null, 'Federal Decree-Law No. 8 of 2017, Article 48(1); Executive Regulation, Article 48(1), conditioned on the Taxable Person being able to demonstrate its Tax Registration and Customs registration number to the Authority at the time of import — the ordinary case for a VAT-registered importer, who self-assesses the Due Tax in the Tax Return rather than paying it at the border (Executive Regulation, Article 50 covers the Person who does not meet those conditions, and is not carried by this pack). The value is reported in box g1 (Executive Regulation, Article 64(5)(g): ''the value of any supplies subject to Clauses 1 and 3 of Article 48''); the self-assessed Tax is due in box g2 and, being fully recoverable for a taxable import, recoverable in box h2.', null, null, 180, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-exec-reg', null, null, null, null),
  ('AE', 'AE-P-NR', 'Purchase, not registered for VAT', '{}'::jsonb, 'A purchase from a supplier established in the State who is not registered for VAT, so no Tax was charged.', 'percent', 0, 'purchase', 'not_subject', date '2018-01-01', null, 'No Tax is charged because the supplier is not a Registrant (Federal Decree-Law No. 8 of 2017, Article 2). Not reported on any box.', 'O', null, 170, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-decree-law', null, null, null, null),
  ('AE', 'AE-P-RC-SVC', 'Purchase, imported services under the reverse charge', '{}'::jsonb, 'A supply of Services with a place of supply in the State, received by a Taxable Person with a Place of Residence in the State from a supplier with no Place of Residence in the State who charges no Tax.', 'percent', 5, 'purchase', 'foreign_services_received', date '2018-01-01', null, 'Federal Decree-Law No. 8 of 2017, Article 48(1) and (3) of the Executive Regulation (Concerned Services). Reported the same way as AE-P-IMP: value in box g1, self-assessed Tax due in box g2 and, where the service is used to make a taxable supply, recoverable in box h2.', null, null, 190, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-exec-reg', null, null, null, null),
  ('AE', 'AE-P-SR', 'Purchase, standard-rated, VAT recoverable', '{}'::jsonb, 'A standard-rated purchase used to make a taxable supply, whose input tax may be recovered in full.', 'percent', 5, 'purchase', 'domestic', date '2018-01-01', null, 'Federal Decree-Law No. 8 of 2017, Articles 54 and 55 (recoverable input tax); Executive Regulation, Article 64(5)(h). Reported in box h1 with the Recoverable Tax in box h2.', 'S', null, 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-decree-law', null, null, null, null),
  ('AE', 'AE-P-ZR', 'Purchase, zero-rated', '{}'::jsonb, 'A zero-rated purchase from a Registrant in the State, such as investment precious metals or an export-qualifying service.', 'percent', 0, 'purchase', 'domestic', date '2018-01-01', null, 'Executive Regulation, Article 64(5)(h) — a purchase whose Input Tax may be recovered is reported in box h1 without regard to its rate; at a zero rate there is no Tax to add to box h2.', 'Z', null, 150, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-exec-reg', null, null, null, null),
  ('AE', 'AE-S-DRC-HC', 'Sale, domestic reverse charge, crude oil, natural gas or pure hydrocarbons', '{}'::jsonb, 'A taxable supply in the State, between two Registrants, of crude or refined oil, unprocessed or processed natural gas, or pure hydrocarbons, where the Recipient intends to resell the Goods as such or to use them to produce or distribute energy.', 'percent', 0, 'sale', 'domestic_reverse_charge', date '2018-01-01', null, 'Federal Decree-Law No. 8 of 2017, Article 48(3): ''The Registrant making the supply shall not account for Tax on the value of the supply of the Goods''; Clause 4 conditions this on a written declaration from the Recipient of its intended use and of its own Tax Registration, verified by the supplier. The value is a taxable supply and is reported in box d1 with no Output Tax against it; the Recipient accounts for the Tax under AE-P-DRC-HC. PINT AE tax category 4, Reverse Charge.', 'AE', null, 110, 'vat', true, array['buyer_certificate', 'buyer_status']::tax_condition[], null, false, false, null, 'vat-decree-law', null, null, null, null),
  ('AE', 'AE-S-EX-FIN', 'Sale, exempt, financial services on margin', '{}'::jsonb, 'A financial service of Article 42(2) of the Executive Regulation — dealing in money, credit, a debt or equity security, a life insurance contract — supplied for an implicit margin and not for an explicit fee, commission, discount or rebate.', 'percent', 0, 'sale', 'exempt', date '2018-01-01', null, 'Federal Decree-Law No. 8 of 2017, Article 46(1); Executive Regulation, Article 42(3)(a): a financial service of Clause 2 is exempt ''where they are not conducted in return for an explicit fee, discount, commission, and rebate or similar'' — Clause 4 makes the same service taxable at the standard rate where it is. Reported in box f (Executive Regulation, Article 64(5)(f)). PINT AE tax category 2, Exempt from VAT.', 'E', null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-exec-reg', null, null, null, null),
  ('AE', 'AE-S-EX-LAND', 'Sale, exempt, bare land', '{}'::jsonb, 'A supply of land that is not covered by a completed or partially completed building or by civil engineering works.', 'percent', 0, 'sale', 'exempt', date '2018-01-01', null, 'Federal Decree-Law No. 8 of 2017, Article 46(3); Executive Regulation, Article 44. Reported in box f. PINT AE tax category 2, Exempt from VAT.', 'E', null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-exec-reg', null, null, null, null),
  ('AE', 'AE-S-EX-RESI', 'Sale, exempt, residential building beyond the first supply', '{}'::jsonb, 'A supply of a residential building by sale, or by a lease of more than 6 months (or to a UAE-ID holder), other than the first supply that is zero-rated.', 'percent', 0, 'sale', 'exempt', date '2018-01-01', null, 'Federal Decree-Law No. 8 of 2017, Article 46(2); Executive Regulation, Article 43. Reported in box f. PINT AE tax category 2, Exempt from VAT.', 'E', null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-exec-reg', null, null, null, null),
  ('AE', 'AE-S-EX-TRANSPORT', 'Sale, exempt, local passenger transport', '{}'::jsonb, 'Local passenger transport by a qualifying means of transport (taxi, bus, train, tram, ferry, or aircraft not constituting international carriage) from a place in the State to another place in the State.', 'percent', 0, 'sale', 'exempt', date '2018-01-01', null, 'Federal Decree-Law No. 8 of 2017, Article 46(4); Executive Regulation, Article 45. Reported in box f. PINT AE tax category 2, Exempt from VAT.', 'E', null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-exec-reg', null, null, null, null),
  ('AE', 'AE-S-OS', 'Sale, out of scope', '{}'::jsonb, 'A supply whose place of supply is outside the United Arab Emirates under the place-of-supply rules of Chapter Two of the Decree-Law, or a transfer of a whole or independent part of a Business to a Taxable Person for the purposes of continuing the Business that Article 7(2) of the Decree-Law excepts from being a supply at all.', 'percent', 0, 'sale', 'not_subject', date '2018-01-01', null, 'Federal Decree-Law No. 8 of 2017, Articles 7(2) and 27 to 32 (place of supply). Not reported on any box of the return: Article 64(5) of the Executive Regulation names no box for a supply that is not made in the State. PINT AE tax category 3, Goods and services outside the scope of VAT.', 'O', null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-decree-law', null, null, null, null),
  ('AE', 'AE-S-SR', 'Sale, standard-rated, VAT 5%', '{}'::jsonb, 'A taxable supply made in the United Arab Emirates that is not zero-rated or exempt.', 'percent', 5, 'sale', 'domestic', date '2018-01-01', null, 'Federal Decree-Law No. 8 of 2017, Article 3 — ''5% Tax shall be imposed on any supply or Import pursuant to Article 2 of this Decree-Law'', in force since the Decree-Law commenced on 1 January 2018. The value is reported without Tax under Article 64(5)(d) of the Executive Regulation (''the value of Taxable Supplies made... and the Output Tax charged''). PINT AE tax category 1, Standard Rate (UAE Electronic Invoicing Guidelines, section 10.5).', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-decree-law', null, null, null, null),
  ('AE', 'AE-S-ZR-EXP', 'Sale, zero-rated, direct or indirect export', '{}'::jsonb, 'A direct or indirect export of goods or services to outside the Implementing States (the GCC member states that have brought the Common VAT Agreement into force).', 'percent', 0, 'sale', 'export', date '2018-01-01', null, 'Federal Decree-Law No. 8 of 2017, Article 45(1); Executive Regulation, Article 30, which conditions the zero rate on the goods leaving the State within 90 days and on official and commercial evidence of the export being kept. Reported in box e (Executive Regulation, Article 64(5)(e)). PINT AE tax category 5, Zero rated.', 'G', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-decree-law', null, null, null, null),
  ('AE', 'AE-S-ZR-METAL', 'Sale, zero-rated, investment precious metals', '{}'::jsonb, 'Gold, silver and platinum of a purity of 99% or more, in a form tradeable in global bullion markets.', 'percent', 0, 'sale', 'domestic', date '2018-01-01', null, 'Federal Decree-Law No. 8 of 2017, Article 45(8); Executive Regulation, Article 36. Reported in box e. PINT AE tax category 5, Zero rated.', 'Z', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-exec-reg', null, null, null, null),
  ('AE', 'AE-S-ZR-RESI', 'Sale, zero-rated, first supply of a residential building', '{}'::jsonb, 'The first supply, by sale or lease, of a residential building within 3 years of its completion.', 'percent', 0, 'sale', 'domestic', date '2018-01-01', null, 'Federal Decree-Law No. 8 of 2017, Article 45(9); Executive Regulation, Articles 37 to 39. Reported in box e. PINT AE tax category 5, Zero rated.', 'Z', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-exec-reg', null, null, null, null),
  ('AE', 'AE-S-ZR-TRANSPORT', 'Sale, zero-rated, international transport of passengers or goods', '{}'::jsonb, 'International transport of passengers or goods that starts or ends in the State or passes through its territory, including transport-related services, and international carriage of passengers by air.', 'percent', 0, 'sale', 'export', date '2018-01-01', null, 'Federal Decree-Law No. 8 of 2017, Article 45(2) and (3); Executive Regulation, Article 33. Reported in box e alongside other zero-rated supplies. PINT AE tax category 5, Zero rated.', 'G', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-decree-law', null, null, null, null)
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
    ('AE-P-BL-CAR', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('AE-P-BL-CAR', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('AE-P-BL-CAR', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('AE-P-BL-CAR', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('AE-P-BL-ENT', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('AE-P-BL-ENT', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('AE-P-BL-ENT', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('AE-P-BL-ENT', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('AE-P-DRC-HC', 'invoice', 'base', 100, null, 'g1', array['g1']::text[], 100, 'AE-VAT-RETURN', 10),
    ('AE-P-DRC-HC', 'invoice', 'tax', 100, '1150', 'h2', array['h2']::text[], 100, 'AE-VAT-RETURN', 20),
    ('AE-P-DRC-HC', 'invoice', 'tax', -100, '2100', 'g2', array['g2']::text[], 100, 'AE-VAT-RETURN', 30),
    ('AE-P-DRC-HC', 'credit_note', 'base', 100, null, 'g1', array['g1']::text[], -100, 'AE-VAT-RETURN', 10),
    ('AE-P-DRC-HC', 'credit_note', 'tax', 100, '1150', 'h2', array['h2']::text[], -100, 'AE-VAT-RETURN', 20),
    ('AE-P-DRC-HC', 'credit_note', 'tax', -100, '2100', 'g2', array['g2']::text[], -100, 'AE-VAT-RETURN', 30),
    ('AE-P-IMP', 'invoice', 'base', 100, null, 'g1', array['g1']::text[], 100, 'AE-VAT-RETURN', 10),
    ('AE-P-IMP', 'invoice', 'tax', 100, '1150', 'h2', array['h2']::text[], 100, 'AE-VAT-RETURN', 20),
    ('AE-P-IMP', 'invoice', 'tax', -100, '2100', 'g2', array['g2']::text[], 100, 'AE-VAT-RETURN', 30),
    ('AE-P-IMP', 'credit_note', 'base', 100, null, 'g1', array['g1']::text[], -100, 'AE-VAT-RETURN', 10),
    ('AE-P-IMP', 'credit_note', 'tax', 100, '1150', 'h2', array['h2']::text[], -100, 'AE-VAT-RETURN', 20),
    ('AE-P-IMP', 'credit_note', 'tax', -100, '2100', 'g2', array['g2']::text[], -100, 'AE-VAT-RETURN', 30),
    ('AE-P-RC-SVC', 'invoice', 'base', 100, null, 'g1', array['g1']::text[], 100, 'AE-VAT-RETURN', 10),
    ('AE-P-RC-SVC', 'invoice', 'tax', 100, '1150', 'h2', array['h2']::text[], 100, 'AE-VAT-RETURN', 20),
    ('AE-P-RC-SVC', 'invoice', 'tax', -100, '2100', 'g2', array['g2']::text[], 100, 'AE-VAT-RETURN', 30),
    ('AE-P-RC-SVC', 'credit_note', 'base', 100, null, 'g1', array['g1']::text[], -100, 'AE-VAT-RETURN', 10),
    ('AE-P-RC-SVC', 'credit_note', 'tax', 100, '1150', 'h2', array['h2']::text[], -100, 'AE-VAT-RETURN', 20),
    ('AE-P-RC-SVC', 'credit_note', 'tax', -100, '2100', 'g2', array['g2']::text[], -100, 'AE-VAT-RETURN', 30),
    ('AE-P-SR', 'invoice', 'base', 100, null, 'h1', array['h1']::text[], 100, 'AE-VAT-RETURN', 10),
    ('AE-P-SR', 'invoice', 'tax', 100, '1150', 'h2', array['h2']::text[], 100, 'AE-VAT-RETURN', 20),
    ('AE-P-SR', 'credit_note', 'base', 100, null, 'h1', array['h1']::text[], -100, 'AE-VAT-RETURN', 10),
    ('AE-P-SR', 'credit_note', 'tax', 100, '1150', 'h2', array['h2']::text[], -100, 'AE-VAT-RETURN', 20),
    ('AE-P-ZR', 'invoice', 'base', 100, null, 'h1', array['h1']::text[], 100, 'AE-VAT-RETURN', 10),
    ('AE-P-ZR', 'credit_note', 'base', 100, null, 'h1', array['h1']::text[], -100, 'AE-VAT-RETURN', 10),
    ('AE-S-DRC-HC', 'invoice', 'base', 100, null, 'd1', array['d1']::text[], 100, 'AE-VAT-RETURN', 10),
    ('AE-S-DRC-HC', 'credit_note', 'base', 100, null, 'd1', array['d1']::text[], -100, 'AE-VAT-RETURN', 10),
    ('AE-S-EX-FIN', 'invoice', 'base', 100, null, 'f', array['f']::text[], 100, 'AE-VAT-RETURN', 10),
    ('AE-S-EX-FIN', 'credit_note', 'base', 100, null, 'f', array['f']::text[], -100, 'AE-VAT-RETURN', 10),
    ('AE-S-EX-LAND', 'invoice', 'base', 100, null, 'f', array['f']::text[], 100, 'AE-VAT-RETURN', 10),
    ('AE-S-EX-LAND', 'credit_note', 'base', 100, null, 'f', array['f']::text[], -100, 'AE-VAT-RETURN', 10),
    ('AE-S-EX-RESI', 'invoice', 'base', 100, null, 'f', array['f']::text[], 100, 'AE-VAT-RETURN', 10),
    ('AE-S-EX-RESI', 'credit_note', 'base', 100, null, 'f', array['f']::text[], -100, 'AE-VAT-RETURN', 10),
    ('AE-S-EX-TRANSPORT', 'invoice', 'base', 100, null, 'f', array['f']::text[], 100, 'AE-VAT-RETURN', 10),
    ('AE-S-EX-TRANSPORT', 'credit_note', 'base', 100, null, 'f', array['f']::text[], -100, 'AE-VAT-RETURN', 10),
    ('AE-S-SR', 'invoice', 'base', 100, null, 'd1', array['d1']::text[], 100, 'AE-VAT-RETURN', 10),
    ('AE-S-SR', 'invoice', 'tax', 100, '2100', 'd2', array['d2']::text[], 100, 'AE-VAT-RETURN', 20),
    ('AE-S-SR', 'credit_note', 'base', 100, null, 'd1', array['d1']::text[], -100, 'AE-VAT-RETURN', 10),
    ('AE-S-SR', 'credit_note', 'tax', 100, '2100', 'd2', array['d2']::text[], -100, 'AE-VAT-RETURN', 20),
    ('AE-S-ZR-EXP', 'invoice', 'base', 100, null, 'e', array['e']::text[], 100, 'AE-VAT-RETURN', 10),
    ('AE-S-ZR-EXP', 'credit_note', 'base', 100, null, 'e', array['e']::text[], -100, 'AE-VAT-RETURN', 10),
    ('AE-S-ZR-METAL', 'invoice', 'base', 100, null, 'e', array['e']::text[], 100, 'AE-VAT-RETURN', 10),
    ('AE-S-ZR-METAL', 'credit_note', 'base', 100, null, 'e', array['e']::text[], -100, 'AE-VAT-RETURN', 10),
    ('AE-S-ZR-RESI', 'invoice', 'base', 100, null, 'e', array['e']::text[], 100, 'AE-VAT-RETURN', 10),
    ('AE-S-ZR-RESI', 'credit_note', 'base', 100, null, 'e', array['e']::text[], -100, 'AE-VAT-RETURN', 10),
    ('AE-S-ZR-TRANSPORT', 'invoice', 'base', 100, null, 'e', array['e']::text[], 100, 'AE-VAT-RETURN', 10),
    ('AE-S-ZR-TRANSPORT', 'credit_note', 'base', 100, null, 'e', array['e']::text[], -100, 'AE-VAT-RETURN', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'AE' and t.code = v.tax_code
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
  ('AE', 'AE-VAT-RETURN', 'VAT return', array['month', 'quarter']::declaration_period[], 'quarter'::declaration_period, date '2018-01-01', null, 'Executive Regulation (Cabinet Decision No. 52 of 2017, as amended), Article 62(1): ''The standard Tax Period applicable to a Taxable Person shall be a period of three calendar months ending on the date that the Authority determines'' — the default every Taxable Person receives. Article 62(2) lets the Authority assign ''a Person or class of Persons a shorter or longer Tax Period'' where it considers that necessary or beneficial, without fixing a turnover threshold in the text this pack''s research could open; in practice the Federal Tax Authority assigns a one-month period to larger taxable persons, which is why `month` is carried as the other cadence, but no article pins a figure to it, and this pack invents none. The Federal Tax Authority''s own VAT201 return form and its administrative box numbering could not be opened as a directly-fetchable text in this research pass (the guide pages served only navigation, not the form itself); the boxes below are therefore built on the minimum content Article 64(5) of the Executive Regulation itself requires a Tax Return to hold, letter by letter, and not on the FTA''s on-screen box numbers 1 to 13 that a filer actually sees on EmaraTax — the first thing a reviewer familiar with the live portal should check.', true,'day_of_month_after_period'::filing_deadline_rule, 28, null, 'Executive Regulation, Article 64(1): ''A Tax Return must be received by the Authority no later than the 28th (twenty eighth) day following the end of the Tax Period concerned or by such other date as directed by the Authority.'' Article 64(3) sets the same day for payment.', 'vat-exec-reg', null)
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
  ('AE', 'AE-VAT-RETURN', 'd1', 'base', 'Value of taxable supplies made in the Tax Period', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Executive Regulation, Article 64(5)(d): a Tax Return includes ''the value of Taxable Supplies made by the Person in the Tax Period and the Output Tax charged.'' This box carries the value; box d2 carries the Output Tax. A domestic reverse charge supply (AE-S-DRC-HC) is a taxable supply and is included here with no amount in d2.', 'vat-exec-reg'),
  ('AE', 'AE-VAT-RETURN', 'd2', 'tax', 'Output Tax charged on box d1', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Executive Regulation, Article 64(5)(d), second limb.', 'vat-exec-reg'),
  ('AE', 'AE-VAT-RETURN', 'e', 'base', 'Value of supplies subject to the zero rate', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Executive Regulation, Article 64(5)(e): ''the value of Taxable Supplies subject to the zero-rate made by the Person in the Tax Period.''', 'vat-exec-reg'),
  ('AE', 'AE-VAT-RETURN', 'f', 'base', 'Value of exempt supplies', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Executive Regulation, Article 64(5)(f): ''the value of Exempt Supplies made by the Person in the Tax Period.''', 'vat-exec-reg'),
  ('AE', 'AE-VAT-RETURN', 'g1', 'base', 'Value of supplies subject to the reverse charge under Article 48(1) and (3) of the Decree-Law', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Executive Regulation, Article 64(5)(g): ''the value of any supplies subject to Clauses 1 and 3 of Article 48 of the Decree-Law'' — the import of Concerned Goods and Concerned Services under Clause 1, and the domestic reverse charge on crude or refined oil, natural gas or pure hydrocarbons under Clause 3.', 'vat-exec-reg'),
  ('AE', 'AE-VAT-RETURN', 'g2', 'tax', 'Tax self-assessed on box g1', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'No clause of Article 64(5) names this figure separately from the value in box g1, but Article 48(4)(a) of the Decree-Law requires the Taxable Person to ''account for Tax on the value of the Concerned Goods or Concerned Services at the rate which would be applicable'' — a value reported without the tax it carries would leave the Due Tax of box i1 short by exactly this amount. The box is this pack''s own, built to hold that figure, and is the first thing in this return a reviewer should check against a real filing.', 'vat-exec-reg'),
  ('AE', 'AE-VAT-RETURN', 'h1', 'base', 'Value of expenses for which Input Tax is recovered', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Executive Regulation, Article 64(5)(h), first limb: ''the value of expenses incurred in respect of which the Person seeks to recover Input Tax.'' A purchase whose Input Tax Article 53 disallows (AE-P-BL-ENT, AE-P-BL-CAR) is not included, because the Person does not seek to recover it; an exempt or unregistered-supplier purchase (AE-P-EX, AE-P-NR) carries no Input Tax to seek.', 'vat-exec-reg'),
  ('AE', 'AE-VAT-RETURN', 'h2', 'tax', 'Recoverable Tax on box h1, including the recoverable share of box g2', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Executive Regulation, Article 64(5)(h), second limb: ''the amount of Recoverable Tax.'' Includes the Tax self-assessed in box g2 to the extent the import or domestic reverse charge is used to make a taxable supply (Decree-Law, Articles 54 and 55).', 'vat-exec-reg'),
  ('AE', 'AE-VAT-RETURN', 'i1', 'total', 'Total Due Tax for the Tax Period', '{}'::jsonb, 90, null, array['d2', 'g2']::text[], '{}'::text[], null, null, false, false, null, 'Executive Regulation, Article 64(5)(i): ''the total value of Due Tax and Recoverable Tax for the Tax Period.'' This box is the Due Tax half of that clause.', 'vat-exec-reg'),
  ('AE', 'AE-VAT-RETURN', 'i2', 'total', 'Total Recoverable Tax for the Tax Period', '{}'::jsonb, 100, null, array['h2']::text[], '{}'::text[], null, null, false, false, null, 'Executive Regulation, Article 64(5)(i), the Recoverable Tax half.', 'vat-exec-reg'),
  ('AE', 'AE-VAT-RETURN', 'j', 'total', 'Payable Tax or excess Tax for the Tax Period', '{}'::jsonb, 110, null, array['i1']::text[], array['i2']::text[], null, null, false, false, null, 'Executive Regulation, Article 64(5)(j): ''the Payable Tax or excess Tax, if any, for the Tax Period.'' A negative figure is excess Recoverable Tax, which Article 65 of the Executive Regulation lets the Taxable Person request as a refund or carry forward; this pack applies no floor at zero.', 'vat-exec-reg')
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
  ('AE-IFRSSME-IS', 'AE', 'default', 'Income statement — IFRS for Small and Medium-sized Entities, expenses by nature', 'income_statement', 'AE-IFRS-SME', date '1970-01-01', null, 'This pack''s research could not open an official, directly-fetchable text of Federal Decree-Law No. 32 of 2021 on Commercial Companies to confirm its own article on accounting records and financial statements, or a UAE-specific accounting standards text: uaelegislation.gov.ae refused every unauthenticated request tried in this research pass, and the Ministry of Economy and Tourism''s site returned no working legislation link. The lines below are therefore built, exactly as packs/sg/ and packs/hk/ build theirs where no country text could be opened, on the minimum line items of Section 4 (statement of financial position) and Section 5 (income statement) of the IFRS for Small and Medium-sized Entities Accounting Standard, current and non-current apart, expenses by nature. This is the first thing a reviewer should check. The income statement is by nature, which a small company''s ledger holds without an allocation to functions.', null),
  ('AE-IFRSSME-SFP', 'AE', 'default', 'Statement of financial position — IFRS for Small and Medium-sized Entities', 'balance_sheet', 'AE-IFRS-SME', date '1970-01-01', null, 'This pack''s research could not open an official, directly-fetchable text of Federal Decree-Law No. 32 of 2021 on Commercial Companies to confirm its own article on accounting records and financial statements, or a UAE-specific accounting standards text: uaelegislation.gov.ae refused every unauthenticated request tried in this research pass, and the Ministry of Economy and Tourism''s site returned no working legislation link. The lines below are therefore built, exactly as packs/sg/ and packs/hk/ build theirs where no country text could be opened, on the minimum line items of Section 4 (statement of financial position) and Section 5 (income statement) of the IFRS for Small and Medium-sized Entities Accounting Standard, current and non-current apart, expenses by nature. This is the first thing a reviewer should check.', null)
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
  ('AE-IFRSSME-IS', '1', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 5.5(a).', null),
  ('AE-IFRSSME-IS', '2', null, 'Other income', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 5.9 — an additional line item: exchange gains and gains on disposal.', null),
  ('AE-IFRSSME-IS', '3', null, 'Cost of sales', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 5.11(a) — expenses analysed by their nature.', null),
  ('AE-IFRSSME-IS', '4', null, 'Employee benefits expense', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 5.11(a) — employee benefits, the end-of-service gratuity charge among them.', null),
  ('AE-IFRSSME-IS', '5', null, 'Depreciation and amortisation', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 5.11(a).', null),
  ('AE-IFRSSME-IS', '6', null, 'Other operating expenses', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 5.11(a) — the other expenses by nature, non-recoverable VAT and exchange losses among them.', null),
  ('AE-IFRSSME-IS', '7', null, 'Finance costs', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 5.5(b).', null),
  ('AE-IFRSSME-IS', '8', null, 'Profit before corporate tax', '{}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('AE-IFRSSME-IS', '9', null, 'Corporate tax expense', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 5.5(d) — tax expense. Federal Decree-Law No. 47 of 2022 on Corporate Tax is outside this VAT-focused pack''s research; the account exists for a company to book the charge by hand.', null),
  ('AE-IFRSSME-IS', '10', null, 'Profit for the year', '{}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, 'IFRS for SMEs, paragraph 5.5(f) — profit or loss. The pack carries no item of other comprehensive income, so it is also the total comprehensive income.', null),
  ('AE-IFRSSME-SFP', 'CA', null, 'Current assets', '{}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5', 'CA.6']::text[], '{}'::text[], null, 'IFRS for SMEs, Section 4, paragraphs 4.4 to 4.6 — current and non-current assets are presented as separate classifications.', null),
  ('AE-IFRSSME-SFP', 'CA.1', 'CA', 'Cash and cash equivalents', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(a).', null),
  ('AE-IFRSSME-SFP', 'CA.2', 'CA', 'Trade and other receivables', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(b). VAT input tax and the amount refundable by the Federal Tax Authority are presented here rather than as current tax, which paragraph 4.2(n) keeps for corporate tax.', null),
  ('AE-IFRSSME-SFP', 'CA.3', 'CA', 'Inventories', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(d).', null),
  ('AE-IFRSSME-SFP', 'CA.4', 'CA', 'Financial assets', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(c), the part realised within twelve months.', null),
  ('AE-IFRSSME-SFP', 'CA.5', 'CA', 'Current tax assets', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(n) — assets for current tax, corporate tax under Federal Decree-Law No. 47 of 2022, which this VAT-focused pack does not otherwise carry.', null),
  ('AE-IFRSSME-SFP', 'CA.6', 'CA', 'Prepayments and accrued income', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.3 — an additional line item relevant to an understanding of the financial position.', null),
  ('AE-IFRSSME-SFP', 'NCA', null, 'Non-current assets', '{}'::jsonb, 80, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4']::text[], '{}'::text[], null, 'IFRS for SMEs, paragraphs 4.4 and 4.6 — every asset that is not current is non-current.', null),
  ('AE-IFRSSME-SFP', 'NCA.1', 'NCA', 'Property, plant and equipment', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(e).', null),
  ('AE-IFRSSME-SFP', 'NCA.2', 'NCA', 'Investments', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(j).', null),
  ('AE-IFRSSME-SFP', 'NCA.3', 'NCA', 'Other non-current assets', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.3 — a long-term deposit or retention held is not one of the named items of paragraph 4.2 and is presented as an additional line.', null),
  ('AE-IFRSSME-SFP', 'NCA.4', 'NCA', 'Intangible assets', '{}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(g), goodwill with them.', null),
  ('AE-IFRSSME-SFP', 'TA', null, 'Total assets', '{}'::jsonb, 130, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('AE-IFRSSME-SFP', 'CL', null, 'Current liabilities', '{}'::jsonb, 140, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4']::text[], '{}'::text[], null, 'IFRS for SMEs, paragraphs 4.4, 4.7 and 4.8 — current and non-current liabilities are presented as separate classifications.', null),
  ('AE-IFRSSME-SFP', 'CL.1', 'CL', 'Trade and other payables', '{}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(l). VAT output tax and the amount payable to the Federal Tax Authority are presented here.', null),
  ('AE-IFRSSME-SFP', 'CL.2', 'CL', 'Borrowings and other financial liabilities', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(m), the part due within twelve months.', null),
  ('AE-IFRSSME-SFP', 'CL.3', 'CL', 'Current tax liabilities', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(n) — liabilities for current tax.', null),
  ('AE-IFRSSME-SFP', 'CL.4', 'CL', 'Provisions', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(p), the part expected to be settled within twelve months — the current portion of the end-of-service gratuity provision.', null),
  ('AE-IFRSSME-SFP', 'NCL', null, 'Non-current liabilities', '{}'::jsonb, 190, 1, true, array['NCL.1', 'NCL.2']::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.8 — every liability that is not current is non-current.', null),
  ('AE-IFRSSME-SFP', 'NCL.1', 'NCL', 'Borrowings and other financial liabilities', '{}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(m), the part not due within twelve months.', null),
  ('AE-IFRSSME-SFP', 'NCL.2', 'NCL', 'Provisions', '{}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(p), the part not expected to be settled within twelve months — the end-of-service gratuity provision, which this pack''s research did not trace to a specific article of Federal Decree-Law No. 33 of 2021 on the Regulation of Labour Relations.', null),
  ('AE-IFRSSME-SFP', 'TL', null, 'Total liabilities', '{}'::jsonb, 220, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('AE-IFRSSME-SFP', 'NA', null, 'Net assets', '{}'::jsonb, 230, 1, true, array['TA']::text[], array['TL']::text[], null, 'IFRS for SMEs, paragraph 4.3 — an additional subtotal. It equals total equity once the year is closed; before, it exceeds equity by the result of the open year.', null),
  ('AE-IFRSSME-SFP', 'EQ', null, 'Equity', '{}'::jsonb, 240, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(r) — equity attributable to the owners, and paragraph 4.12(b) for its classes.', null),
  ('AE-IFRSSME-SFP', 'EQ.1', 'EQ', 'Share capital', '{}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.12(a).', null),
  ('AE-IFRSSME-SFP', 'EQ.2', 'EQ', 'Reserves', '{}'::jsonb, 260, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.12(b) — the statutory reserve a UAE company is commonly required to build from its annual profit, and any other reserve.', null),
  ('AE-IFRSSME-SFP', 'EQ.3', 'EQ', 'Retained earnings', '{}'::jsonb, 270, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.12(b) — retained earnings, after the dividends paid booked beside them.', null)
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
    ('AE-IFRSSME-IS', '1', 10, 'code_range', '4000', '4040', null, 'any'),
    ('AE-IFRSSME-IS', '2', 10, 'code_range', '4700', '4790', null, 'any'),
    ('AE-IFRSSME-IS', '3', 10, 'code_range', '5000', '5030', null, 'any'),
    ('AE-IFRSSME-IS', '4', 10, 'code_range', '6100', '6140', null, 'any'),
    ('AE-IFRSSME-IS', '5', 10, 'code_range', '6500', '6510', null, 'any'),
    ('AE-IFRSSME-IS', '6', 10, 'code_range', '6200', '6440', null, 'any'),
    ('AE-IFRSSME-IS', '6', 20, 'code_range', '6950', '6990', null, 'any'),
    ('AE-IFRSSME-IS', '7', 10, 'code_range', '7100', '7110', null, 'any'),
    ('AE-IFRSSME-IS', '9', 10, 'account_code', '8000', null, null, 'any'),
    ('AE-IFRSSME-SFP', 'CA.1', 10, 'code_range', '1000', '1050', null, 'any'),
    ('AE-IFRSSME-SFP', 'CA.2', 10, 'code_range', '1100', '1160', null, 'any'),
    ('AE-IFRSSME-SFP', 'CA.2', 20, 'account_code', '2990', null, null, 'debit'),
    ('AE-IFRSSME-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('AE-IFRSSME-SFP', 'CA.4', 10, 'account_code', '1300', null, null, 'any'),
    ('AE-IFRSSME-SFP', 'CA.5', 10, 'account_code', '1350', null, null, 'any'),
    ('AE-IFRSSME-SFP', 'CA.6', 10, 'code_range', '1400', '1430', null, 'any'),
    ('AE-IFRSSME-SFP', 'NCA.1', 10, 'code_range', '1600', '1691', null, 'any'),
    ('AE-IFRSSME-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('AE-IFRSSME-SFP', 'NCA.3', 10, 'account_code', '1710', null, null, 'any'),
    ('AE-IFRSSME-SFP', 'NCA.4', 10, 'code_range', '1730', '1751', null, 'any'),
    ('AE-IFRSSME-SFP', 'CL.1', 10, 'code_range', '2000', '2055', null, 'any'),
    ('AE-IFRSSME-SFP', 'CL.1', 20, 'code_range', '2100', '2110', null, 'any'),
    ('AE-IFRSSME-SFP', 'CL.1', 30, 'account_code', '2990', null, null, 'credit'),
    ('AE-IFRSSME-SFP', 'CL.2', 10, 'code_range', '2200', '2210', null, 'any'),
    ('AE-IFRSSME-SFP', 'CL.3', 10, 'account_code', '2130', null, null, 'any'),
    ('AE-IFRSSME-SFP', 'CL.4', 10, 'account_code', '2150', null, null, 'any'),
    ('AE-IFRSSME-SFP', 'NCL.1', 10, 'account_code', '2300', null, null, 'any'),
    ('AE-IFRSSME-SFP', 'NCL.2', 10, 'code_range', '2320', '2350', null, 'any'),
    ('AE-IFRSSME-SFP', 'EQ.1', 10, 'account_code', '3000', null, null, 'any'),
    ('AE-IFRSSME-SFP', 'EQ.2', 10, 'code_range', '3010', '3030', null, 'any'),
    ('AE-IFRSSME-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('AE', 'United Arab Emirates', '{}'::jsonb, array['en']::text[], 'AED', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, 'quarter'::declaration_period)
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
  numbering_legal_reference     = 'Executive Regulation (Cabinet Decision No. 52 of 2017, as amended), Article 59(1)(d) — a Tax Invoice carries ''a sequential Tax Invoice number or a unique number which enables identification of the Tax Invoice and the order of the Tax Invoice in any sequence of invoices.'' The article asks that each invoice be identified and that its place in a sequence be readable, and not that the series carry no gap, which is why the style is `sequential` and not a gapless one; the pattern in number_format is one a business may choose.',
  numbering_source_key          = 'vat-exec-reg',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Federal Decree-Law No. 8 of 2017, Article 25 — tax is calculated on the date of supply, the earliest of: the date goods were transferred or placed at the recipient''s disposal, the date a service was completed, or ''the date of receipt of payment or the date on which the Tax Invoice was issued.'' The general rule is therefore a three-way earliest test — delivery or completion, payment, or invoice — and the closed vocabulary of this field has no value for three triggers at once. `earliest_of_delivery_or_payment` is the nearest of the five and is what the rule reduces to in the ordinary case, because Article 67 already requires the Tax Invoice within 14 days of that same date of supply, so the invoice trigger rarely comes first in practice; a supply invoiced late, or paid before either delivery or an invoice, is the case this pack''s approximation misses.',
  tax_point_source_key          = 'vat-decree-law',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = 'pint-ae',
  einvoice_mandatory_from       = date '2027-01-01',
  einvoice_obligation           = 'mandatory',
  einvoice_legal_reference      = 'Federal Decree-Law No. 8 of 2017, Articles 65(5) and 70(4) (both added by Federal Decree-Law No. 16 of 2024) make a Registrant ''subject to the Electronic Invoicing System'' issue and transmit Tax Invoices and Tax Credit Notes as Electronic Invoices and Electronic Credit Notes. Who is subject, and from when, is set by Ministerial Decision No. 243 of 2025 (the Electronic Invoicing System itself) and Ministerial Decision No. 244 of 2025 (its implementation timeline), read here from the Ministry of Finance''s own UAE Electronic Invoicing Guidelines, Version 1.1 of 1 June 2026: a voluntary pilot and a general voluntary phase both open on 1 July 2026, and mandatory implementation is phased by the Person''s annual revenue — by 1 January 2027 for a Person with revenue of AED 50,000,000 or more (Accredited Service Provider appointed by 31 July 2026), by 1 July 2027 for every other Person (Accredited Service Provider appointed by 31 March 2027), and by 1 October 2027 for a Government Entity (Accredited Service Provider appointed by 31 March 2027); a 24-month grace period from 1 January 2027 applies to transactions between members of the same VAT group. `mandatory_from` carries the earliest of these dates, 1 January 2027, the day the obligation first binds anyone; docs/international.md carries the rest of the calendar, which this field cannot hold on its own. The exchange is a 5-corner model the Guidelines call DCTCE (Decentralised Continuous Transaction Control and Exchange): the supplier''s Accredited Service Provider (Corner 2) and the buyer''s (Corner 3) exchange the Electronic Invoice over the OpenPeppol Interoperability Framework and each report the Tax Data to the Federal Tax Authority (Corner 5). Accreditation of a Service Provider is Ministerial Decision No. 64 of 2025, as amended by Ministerial Decision No. 56 of 2026; penalties for non-compliance are Cabinet Decision No. 106 of 2025. The format is PINT AE, the Peppol International invoicing specification localised for the UAE. A party''s Participant Identifier on the network is ICD `0235` followed by its 10-digit Tax Identification Number (TIN), the first 10 digits of its 15-digit Tax Registration Number (TRN); `vat_scheme` is left empty because no separate ISO 6523 code is registered for the 15-digit TRN itself, which Article 59 of the Executive Regulation asks a Tax Invoice to print in full. PINT AE''s own tax categories — Standard Rate, Exempt from VAT, Out of scope, Reverse Charge, Zero rated, Margin scheme — are a closed list of six the Guidelines print in full (section 10.5) and are not the UNCL5305 letters `vat_category` holds; each tax names the PINT AE category its treatment maps to in its own legal_reference.',
  einvoice_source_key           = 'mof-einvoicing-guide',
  party_scheme                  = '0235',
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'AE';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('AE', 'reverse_charge', 'reverse_charge', 'Reverse charge: the Recipient of Goods or Recipient of Services must account for the Value Added Tax due on this supply under Article 48 of Federal Decree-Law No. 8 of 2017.', '{}'::jsonb, 10, date '1970-01-01', null, 'Executive Regulation (Cabinet Decision No. 52 of 2017, as amended), Article 59(1)(l) — where the recipient is required to account for Tax, the Tax Invoice carries ''a statement that the Recipient is required to account for Tax, and a reference to the relevant provision of the Decree-Law.'' This pack''s research found no article of the Decree-Law or its Executive Regulation requiring a printed sentence on a zero-rated or an exempt line, unlike Singapore''s reg. 11(3); a UAE tax invoice shows the rate of Tax against each line (Article 59(1)(h)), which is what distinguishes them.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
