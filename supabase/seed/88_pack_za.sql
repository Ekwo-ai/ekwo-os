-- Ekwo OS — South Africa: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/za at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build za`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Value-Added Tax Act, 1991 (Act No. 89 of 1991), consolidated text, sections 1, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 20, 23, 27 and 28 (Acts Online (Van Zyl Rudd & Associates), a consolidation of the Government Gazette text kept current with amendments; South Africa keeps no official online consolidated register of its own statutes, unlike Legilux or Légifrance — see this pack's section of docs/international.md)
--     https://www.acts.co.za/value-added-tax-act-1991/
--   Rates and Monetary Amounts and Amendment of Revenue Laws Bill, 2025 — clause 13, reversal of the VAT rate increase to 15,5 % (National Treasury of the Republic of South Africa)
--     https://www.treasury.gov.za/comm_media/press/2025/2024042401%20Media%20Statement%20on%20the%20reversal%20of%20the%20vat%20rate%20increase.pdf
--   VAT 404 – Guide for Vendors (South African Revenue Service)
--     https://www.sars.gov.za/wp-content/uploads/Ops/Guides/Legal-Pub-Guide-VAT404-VAT-404-Guide-for-Vendors.pdf
--   Guide for Completing the Value-Added Tax VAT201 Declaration — External Guide (GEN-ELEC-04-G01, Revision 11, effective 12 May 2025) (South African Revenue Service)
--     https://www.sars.gov.za/wp-content/uploads/Ops/Guides/GEN-ELEC-04-G01-Guide-for-completing-the-Value-Added-Tax-VAT201-Declaration-External-Guide.pdf
--   Tax periods for VAT (South African Revenue Service)
--     https://www.sars.gov.za/types-of-tax/value-added-tax/tax-periods-for-vat-vendors/
--   Value-Added Tax (South African Revenue Service)
--     https://www.sars.gov.za/types-of-tax/value-added-tax/
--   SARS eFiling (South African Revenue Service)
--     https://www.sarsefiling.co.za/
--   Companies Act 71 of 2008, s. 29 and s. 30 — financial records and annual financial statements (South African Government — Department of Trade, Industry and Competition)
--     https://www.gov.za/documents/companies-act-0
--   Companies Regulations, 2011, Regulation 27 and Regulation 28 — financial reporting standards and the public interest score (South African Government — Department of Trade, Industry and Competition)
--     https://www.gov.za/documents/companies-act-regulations-2011
--   IFRS for SMEs Accounting Standard — Section 4, Statement of Financial Position, and Section 5, Statement of Comprehensive Income and Income Statement (IFRS Foundation, approved for use in South Africa by the Financial Reporting Standards Council under Companies Regulation 27)
--     https://www.ifrs.org/issued-standards/ifrs-for-smes/
--   Prescribed Rate of Interest Act 55 of 1975 — the rate of interest on an unpaid debt where none is agreed (South African Government)
--     https://www.gov.za/documents/prescribed-rate-interest-act-8-jun-1975-0000
--   SARS Strategic Plan 2025/26–2029/30 and the VAT Modernisation programme — no obligation to issue a structured electronic invoice at the date of this pack (South African Revenue Service)
--     https://www.sars.gov.za/about/sars-strategic-and-annual-performance-plan/
--   UNCL5305 — duty or tax or fee category code (OpenPEPPOL — the list itself is published by UN/CEFACT)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('ZA', 'South Africa', '0.1.0', date '2026-09-25', '20260917170000', 'community', null, null, '2aa6071936d3d1dc3090160d1b2f5eda5df068274de2967fced7bc34dc615a7b', '[{"key":"vat-act","title":"Value-Added Tax Act, 1991 (Act No. 89 of 1991), consolidated text, sections 1, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 20, 23, 27 and 28","publisher":"Acts Online (Van Zyl Rudd & Associates), a consolidation of the Government Gazette text kept current with amendments; South Africa keeps no official online consolidated register of its own statutes, unlike Legilux or Légifrance — see this pack''s section of docs/international.md","url":"https://www.acts.co.za/value-added-tax-act-1991/","consulted_on":"2026-09-25","kind":"law"},{"key":"rates-bill-2025","title":"Rates and Monetary Amounts and Amendment of Revenue Laws Bill, 2025 — clause 13, reversal of the VAT rate increase to 15,5 %","publisher":"National Treasury of the Republic of South Africa","url":"https://www.treasury.gov.za/comm_media/press/2025/2024042401%20Media%20Statement%20on%20the%20reversal%20of%20the%20vat%20rate%20increase.pdf","consulted_on":"2026-09-25","kind":"regulation"},{"key":"vat404","title":"VAT 404 – Guide for Vendors","publisher":"South African Revenue Service","url":"https://www.sars.gov.za/wp-content/uploads/Ops/Guides/Legal-Pub-Guide-VAT404-VAT-404-Guide-for-Vendors.pdf","consulted_on":"2026-09-25","kind":"guidance"},{"key":"vat201-guide","title":"Guide for Completing the Value-Added Tax VAT201 Declaration — External Guide (GEN-ELEC-04-G01, Revision 11, effective 12 May 2025)","publisher":"South African Revenue Service","url":"https://www.sars.gov.za/wp-content/uploads/Ops/Guides/GEN-ELEC-04-G01-Guide-for-completing-the-Value-Added-Tax-VAT201-Declaration-External-Guide.pdf","consulted_on":"2026-09-25","kind":"form"},{"key":"vat-tax-periods","title":"Tax periods for VAT","publisher":"South African Revenue Service","url":"https://www.sars.gov.za/types-of-tax/value-added-tax/tax-periods-for-vat-vendors/","consulted_on":"2026-09-25","kind":"guidance"},{"key":"vat-overview","title":"Value-Added Tax","publisher":"South African Revenue Service","url":"https://www.sars.gov.za/types-of-tax/value-added-tax/","consulted_on":"2026-09-25","kind":"guidance"},{"key":"efiling","title":"SARS eFiling","publisher":"South African Revenue Service","url":"https://www.sarsefiling.co.za/","consulted_on":"2026-09-25","kind":"portal"},{"key":"companies-act","title":"Companies Act 71 of 2008, s. 29 and s. 30 — financial records and annual financial statements","publisher":"South African Government — Department of Trade, Industry and Competition","url":"https://www.gov.za/documents/companies-act-0","consulted_on":"2026-09-25","kind":"law"},{"key":"companies-regs-2011","title":"Companies Regulations, 2011, Regulation 27 and Regulation 28 — financial reporting standards and the public interest score","publisher":"South African Government — Department of Trade, Industry and Competition","url":"https://www.gov.za/documents/companies-act-regulations-2011","consulted_on":"2026-09-25","kind":"regulation"},{"key":"ifrs-for-smes","title":"IFRS for SMEs Accounting Standard — Section 4, Statement of Financial Position, and Section 5, Statement of Comprehensive Income and Income Statement","publisher":"IFRS Foundation, approved for use in South Africa by the Financial Reporting Standards Council under Companies Regulation 27","url":"https://www.ifrs.org/issued-standards/ifrs-for-smes/","consulted_on":"2026-09-25","kind":"standard"},{"key":"prescribed-rate-interest-act","title":"Prescribed Rate of Interest Act 55 of 1975 — the rate of interest on an unpaid debt where none is agreed","publisher":"South African Government","url":"https://www.gov.za/documents/prescribed-rate-interest-act-8-jun-1975-0000","consulted_on":"2026-09-25","kind":"law"},{"key":"sars-vat-modernisation","title":"SARS Strategic Plan 2025/26–2029/30 and the VAT Modernisation programme — no obligation to issue a structured electronic invoice at the date of this pack","publisher":"South African Revenue Service","url":"https://www.sars.gov.za/about/sars-strategic-and-annual-performance-plan/","consulted_on":"2026-09-25","kind":"guidance"},{"key":"uncl5305","title":"UNCL5305 — duty or tax or fee category code","publisher":"OpenPEPPOL — the list itself is published by UN/CEFACT","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/","consulted_on":"2026-09-25","kind":"standard"}]'::jsonb)
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
  ('ZA', 'default', 'South Africa reference chart of accounts', '{}'::jsonb, true, 'companies', array['ZA-IFRSSME-PL', 'ZA-IFRSSME-SFP']::text[], null, 'There is no chart of accounts prescribed by South African law. Companies Act 71 of 2008, s. 28 requires a company to keep accurate and complete accounting records, and s. 29 requires financial statements that satisfy the financial reporting standard applicable to that company and fairly present its state of affairs; s. 30 requires an annual financial statement within six months of the financial year end. Companies Regulation 27 sets the financial reporting standard by the company''s public interest score: a company required to be audited (Regulation 28) applies full IFRS, and every other company may apply the IFRS for SMEs Accounting Standard, as the Financial Reporting Standards Council approves it for use in the Republic. This chart is original — four digits, blocked so that each range reaches one line item of Section 4.2 (statement of financial position) and Section 5.5 (statement of comprehensive income) of the IFRS for SMEs Accounting Standard, which is what the great majority of South African companies — those with no public interest in being audited — report under; a company that files nothing keeps the same books and uses the same statements as management accounts.', 'companies-act')
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
  ('ZA', 'default', '1000', 'Petty cash', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('ZA', 'default', '1010', 'Business current account', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('ZA', 'default', '1020', 'Business savings account', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('ZA', 'default', '1030', 'Foreign currency account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('ZA', 'default', '1040', 'Card and payment gateway clearing account', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('ZA', 'default', '1050', 'Call and fixed deposits of three months or less', '{}'::jsonb, 'asset_cash', false, null, 60),
  ('ZA', 'default', '1060', 'Cash in transit', '{}'::jsonb, 'asset_cash', false, null, 70),
  ('ZA', 'default', '1100', 'Trade debtors', '{}'::jsonb, 'asset_receivable', true, null, 80),
  ('ZA', 'default', '1105', 'Allowance for expected credit losses', '{}'::jsonb, 'asset_current', false, null, 90),
  ('ZA', 'default', '1110', 'Amounts receivable from related parties', '{}'::jsonb, 'asset_current', false, null, 100),
  ('ZA', 'default', '1120', 'Other debtors', '{}'::jsonb, 'asset_current', false, null, 110),
  ('ZA', 'default', '1130', 'Accrued income', '{}'::jsonb, 'asset_current', false, null, 120),
  ('ZA', 'default', '1140', 'Employee and director loans and advances', '{}'::jsonb, 'asset_current', false, null, 130),
  ('ZA', 'default', '1150', 'VAT input — VAT paid on purchases and imports', '{}'::jsonb, 'asset_current', false, null, 140),
  ('ZA', 'default', '1152', 'VAT input on purchases accounted for on the payments basis — awaiting payment', '{}'::jsonb, 'asset_current', false, null, 150),
  ('ZA', 'default', '1155', 'VAT refund due from SARS — net of a submitted VAT201', '{}'::jsonb, 'asset_current', true, null, 160),
  ('ZA', 'default', '1200', 'Inventory — raw materials and consumables', '{}'::jsonb, 'asset_current', false, null, 170),
  ('ZA', 'default', '1210', 'Inventory — work in progress', '{}'::jsonb, 'asset_current', false, null, 180),
  ('ZA', 'default', '1220', 'Inventory — finished goods and goods for resale', '{}'::jsonb, 'asset_current', false, null, 190),
  ('ZA', 'default', '1230', 'Goods in transit', '{}'::jsonb, 'asset_current', false, null, 200),
  ('ZA', 'default', '1300', 'Call and fixed deposits of more than three months', '{}'::jsonb, 'asset_current', false, null, 210),
  ('ZA', 'default', '1310', 'Listed investments held for trading', '{}'::jsonb, 'asset_current', false, null, 220),
  ('ZA', 'default', '1320', 'Loans to related parties — current', '{}'::jsonb, 'asset_current', false, null, 230),
  ('ZA', 'default', '1350', 'Income tax refundable', '{}'::jsonb, 'asset_current', false, null, 240),
  ('ZA', 'default', '1400', 'Prepayments', '{}'::jsonb, 'asset_prepayments', false, null, 250),
  ('ZA', 'default', '1410', 'Deposits paid', '{}'::jsonb, 'asset_prepayments', false, null, 260),
  ('ZA', 'default', '1420', 'Payments on account to suppliers', '{}'::jsonb, 'asset_prepayments', false, null, 270),
  ('ZA', 'default', '1600', 'Land', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('ZA', 'default', '1610', 'Buildings', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('ZA', 'default', '1611', 'Buildings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('ZA', 'default', '1620', 'Leasehold improvements', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('ZA', 'default', '1621', 'Leasehold improvements — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('ZA', 'default', '1630', 'Plant and machinery', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('ZA', 'default', '1631', 'Plant and machinery — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('ZA', 'default', '1640', 'Furniture and fittings', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('ZA', 'default', '1641', 'Furniture and fittings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('ZA', 'default', '1650', 'Computer equipment', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('ZA', 'default', '1651', 'Computer equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 380),
  ('ZA', 'default', '1660', 'Motor vehicles', '{}'::jsonb, 'asset_fixed', false, null, 390),
  ('ZA', 'default', '1661', 'Motor vehicles — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 400),
  ('ZA', 'default', '1670', 'Right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 410),
  ('ZA', 'default', '1671', 'Right-of-use assets — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 420),
  ('ZA', 'default', '1680', 'Capital work in progress', '{}'::jsonb, 'asset_fixed', false, null, 430),
  ('ZA', 'default', '1700', 'Investment property', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('ZA', 'default', '1750', 'Goodwill', '{}'::jsonb, 'asset_fixed', false, null, 450),
  ('ZA', 'default', '1751', 'Goodwill — accumulated impairment', '{}'::jsonb, 'asset_fixed', false, null, 460),
  ('ZA', 'default', '1760', 'Software and development costs', '{}'::jsonb, 'asset_fixed', false, null, 470),
  ('ZA', 'default', '1761', 'Software and development costs — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 480),
  ('ZA', 'default', '1770', 'Patents, trade marks and licences', '{}'::jsonb, 'asset_fixed', false, null, 490),
  ('ZA', 'default', '1771', 'Patents, trade marks and licences — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 500),
  ('ZA', 'default', '1800', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 510),
  ('ZA', 'default', '1810', 'Investments in joint ventures', '{}'::jsonb, 'asset_non_current', false, null, 520),
  ('ZA', 'default', '1820', 'Shares in unlisted entities', '{}'::jsonb, 'asset_non_current', false, null, 530),
  ('ZA', 'default', '1830', 'Loans to related parties — non-current', '{}'::jsonb, 'asset_non_current', false, null, 540),
  ('ZA', 'default', '1840', 'Security deposits — non-current', '{}'::jsonb, 'asset_non_current', false, null, 550),
  ('ZA', 'default', '1900', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 560),
  ('ZA', 'default', '2000', 'Trade creditors', '{}'::jsonb, 'liability_payable', true, null, 570),
  ('ZA', 'default', '2010', 'Accrued expenses', '{}'::jsonb, 'liability_current', false, null, 580),
  ('ZA', 'default', '2020', 'Amounts payable to related parties', '{}'::jsonb, 'liability_current', false, null, 590),
  ('ZA', 'default', '2030', 'Other creditors', '{}'::jsonb, 'liability_current', false, null, 600),
  ('ZA', 'default', '2040', 'Customer deposits and contract liabilities', '{}'::jsonb, 'liability_current', false, null, 610),
  ('ZA', 'default', '2050', 'Salaries and wages payable', '{}'::jsonb, 'liability_current', false, null, 620),
  ('ZA', 'default', '2060', 'UIF contributions payable', '{}'::jsonb, 'liability_current', false, null, 630),
  ('ZA', 'default', '2070', 'Skills Development Levy payable', '{}'::jsonb, 'liability_current', false, null, 640),
  ('ZA', 'default', '2080', 'Dividends payable', '{}'::jsonb, 'liability_current', false, null, 650),
  ('ZA', 'default', '2090', 'Dividends tax withheld payable to SARS', '{}'::jsonb, 'liability_current', false, null, 660),
  ('ZA', 'default', '2100', 'VAT output — VAT charged on sales', '{}'::jsonb, 'liability_current', false, null, 670),
  ('ZA', 'default', '2105', 'VAT output on sales accounted for on the payments basis — awaiting payment', '{}'::jsonb, 'liability_current', false, null, 680),
  ('ZA', 'default', '2110', 'VAT payable to SARS — net of a submitted VAT201', '{}'::jsonb, 'liability_current', true, null, 690),
  ('ZA', 'default', '2120', 'Employees'' tax (PAYE) payable', '{}'::jsonb, 'liability_current', false, null, 700),
  ('ZA', 'default', '2200', 'Bank overdraft', '{}'::jsonb, 'liability_current', false, null, 710),
  ('ZA', 'default', '2210', 'Business credit card', '{}'::jsonb, 'liability_credit_card', false, null, 720),
  ('ZA', 'default', '2220', 'Bank loans — current', '{}'::jsonb, 'liability_current', false, null, 730),
  ('ZA', 'default', '2230', 'Lease liabilities — current', '{}'::jsonb, 'liability_current', false, null, 740),
  ('ZA', 'default', '2240', 'Instalment sale and hire purchase liabilities — current', '{}'::jsonb, 'liability_current', false, null, 750),
  ('ZA', 'default', '2300', 'Income tax payable', '{}'::jsonb, 'liability_current', false, null, 760),
  ('ZA', 'default', '2310', 'Provisional tax payable', '{}'::jsonb, 'liability_current', false, null, 770),
  ('ZA', 'default', '2350', 'Provision for leave pay', '{}'::jsonb, 'liability_current', false, null, 780),
  ('ZA', 'default', '2370', 'Provision for warranties and other provisions — current', '{}'::jsonb, 'liability_current', false, null, 790),
  ('ZA', 'default', '2400', 'Bank loans — non-current', '{}'::jsonb, 'liability_non_current', false, null, 800),
  ('ZA', 'default', '2410', 'Lease liabilities — non-current', '{}'::jsonb, 'liability_non_current', false, null, 810),
  ('ZA', 'default', '2420', 'Instalment sale and hire purchase liabilities — non-current', '{}'::jsonb, 'liability_non_current', false, null, 820),
  ('ZA', 'default', '2430', 'Loans from shareholders and related parties — non-current', '{}'::jsonb, 'liability_non_current', false, null, 830),
  ('ZA', 'default', '2500', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 840),
  ('ZA', 'default', '2550', 'Provision for leave pay — non-current', '{}'::jsonb, 'liability_non_current', false, null, 850),
  ('ZA', 'default', '2560', 'Provision for restoration and rehabilitation', '{}'::jsonb, 'liability_non_current', false, null, 860),
  ('ZA', 'default', '2990', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 870),
  ('ZA', 'default', '3000', 'Issued share capital — ordinary shares', '{}'::jsonb, 'equity', false, null, 880),
  ('ZA', 'default', '3010', 'Issued share capital — preference shares', '{}'::jsonb, 'equity', false, null, 890),
  ('ZA', 'default', '3020', 'Members'' contributions — close corporation', '{}'::jsonb, 'equity', false, null, 900),
  ('ZA', 'default', '3100', 'Revaluation reserve', '{}'::jsonb, 'equity', false, null, 910),
  ('ZA', 'default', '3110', 'Other reserves', '{}'::jsonb, 'equity', false, null, 920),
  ('ZA', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 930),
  ('ZA', 'default', '3210', 'Dividends declared', '{}'::jsonb, 'equity_retained', false, null, 940),
  ('ZA', 'default', '4000', 'Sales — goods', '{}'::jsonb, 'income', false, null, 950),
  ('ZA', 'default', '4010', 'Sales — services', '{}'::jsonb, 'income', false, null, 960),
  ('ZA', 'default', '4020', 'Sales — zero-rated goods and services', '{}'::jsonb, 'income', false, null, 970),
  ('ZA', 'default', '4030', 'Sales — exports', '{}'::jsonb, 'income', false, null, 980),
  ('ZA', 'default', '4040', 'Residential rental income', '{}'::jsonb, 'income', false, null, 990),
  ('ZA', 'default', '4050', 'Retail takings', '{}'::jsonb, 'income', false, null, 1000),
  ('ZA', 'default', '4080', 'Sales returns and allowances', '{}'::jsonb, 'income', false, null, 1010),
  ('ZA', 'default', '4090', 'Settlement discount granted', '{}'::jsonb, 'income', false, null, 1020),
  ('ZA', 'default', '4500', 'Interest income', '{}'::jsonb, 'income_other', false, null, 1030),
  ('ZA', 'default', '4510', 'Commercial rental income', '{}'::jsonb, 'income_other', false, null, 1040),
  ('ZA', 'default', '4520', 'Government grants and incentives', '{}'::jsonb, 'income_other', false, null, 1050),
  ('ZA', 'default', '4530', 'Sundry income', '{}'::jsonb, 'income_other', false, null, 1060),
  ('ZA', 'default', '4700', 'Foreign exchange gains', '{}'::jsonb, 'income_other', false, null, 1070),
  ('ZA', 'default', '4750', 'Gain on disposal of non-current assets', '{}'::jsonb, 'income_other', false, null, 1080),
  ('ZA', 'default', '5000', 'Purchases — goods for resale', '{}'::jsonb, 'expense_direct_cost', false, null, 1090),
  ('ZA', 'default', '5010', 'Purchases — raw materials and consumables', '{}'::jsonb, 'expense_direct_cost', false, null, 1100),
  ('ZA', 'default', '5020', 'Freight and carriage inwards', '{}'::jsonb, 'expense_direct_cost', false, null, 1110),
  ('ZA', 'default', '5030', 'Customs duty and import charges', '{}'::jsonb, 'expense_direct_cost', false, null, 1120),
  ('ZA', 'default', '5040', 'Changes in inventories', '{}'::jsonb, 'expense_direct_cost', false, null, 1130),
  ('ZA', 'default', '5100', 'Subcontractors', '{}'::jsonb, 'expense_direct_cost', false, null, 1140),
  ('ZA', 'default', '6000', 'Salaries and wages', '{}'::jsonb, 'expense', false, null, 1150),
  ('ZA', 'default', '6010', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 1160),
  ('ZA', 'default', '6020', 'Pension and provident fund contributions', '{}'::jsonb, 'expense', false, null, 1170),
  ('ZA', 'default', '6030', 'UIF contributions — employer', '{}'::jsonb, 'expense', false, null, 1180),
  ('ZA', 'default', '6040', 'Skills Development Levy — employer', '{}'::jsonb, 'expense', false, null, 1190),
  ('ZA', 'default', '6050', 'COID (Compensation Fund) assessment', '{}'::jsonb, 'expense', false, null, 1200),
  ('ZA', 'default', '6060', 'Leave pay expense', '{}'::jsonb, 'expense', false, null, 1210),
  ('ZA', 'default', '6070', 'Staff training and welfare', '{}'::jsonb, 'expense', false, null, 1220),
  ('ZA', 'default', '6200', 'Depreciation — buildings and leasehold improvements', '{}'::jsonb, 'expense_depreciation', false, null, 1230),
  ('ZA', 'default', '6210', 'Depreciation — plant, machinery and motor vehicles', '{}'::jsonb, 'expense_depreciation', false, null, 1240),
  ('ZA', 'default', '6220', 'Depreciation — right-of-use assets', '{}'::jsonb, 'expense_depreciation', false, null, 1250),
  ('ZA', 'default', '6230', 'Amortisation of intangible assets', '{}'::jsonb, 'expense_depreciation', false, null, 1260),
  ('ZA', 'default', '6300', 'Rent and operating lease charges', '{}'::jsonb, 'expense', false, null, 1270),
  ('ZA', 'default', '6310', 'Electricity, water and refuse removal', '{}'::jsonb, 'expense', false, null, 1280),
  ('ZA', 'default', '6320', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 1290),
  ('ZA', 'default', '6330', 'Insurance', '{}'::jsonb, 'expense', false, null, 1300),
  ('ZA', 'default', '6340', 'Telephone and internet', '{}'::jsonb, 'expense', false, null, 1310),
  ('ZA', 'default', '6350', 'Software subscriptions', '{}'::jsonb, 'expense', false, null, 1320),
  ('ZA', 'default', '6360', 'Advertising and marketing', '{}'::jsonb, 'expense', false, null, 1330),
  ('ZA', 'default', '6370', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1340),
  ('ZA', 'default', '6380', 'Travel and accommodation', '{}'::jsonb, 'expense', false, null, 1350),
  ('ZA', 'default', '6390', 'Entertainment', '{}'::jsonb, 'expense', false, null, 1360),
  ('ZA', 'default', '6400', 'Accounting and audit fees', '{}'::jsonb, 'expense', false, null, 1370),
  ('ZA', 'default', '6410', 'Legal and professional fees', '{}'::jsonb, 'expense', false, null, 1380),
  ('ZA', 'default', '6420', 'Consulting fees', '{}'::jsonb, 'expense', false, null, 1390),
  ('ZA', 'default', '6430', 'Bank charges and merchant fees', '{}'::jsonb, 'expense', false, null, 1400),
  ('ZA', 'default', '6440', 'Printing, postage and stationery', '{}'::jsonb, 'expense', false, null, 1410),
  ('ZA', 'default', '6450', 'Subscriptions and memberships', '{}'::jsonb, 'expense', false, null, 1420),
  ('ZA', 'default', '6460', 'Bad debts and expected credit losses', '{}'::jsonb, 'expense', false, null, 1430),
  ('ZA', 'default', '6470', 'Donations', '{}'::jsonb, 'expense', false, null, 1440),
  ('ZA', 'default', '6480', 'Rates and municipal charges', '{}'::jsonb, 'expense', false, null, 1450),
  ('ZA', 'default', '6490', 'Sundry expenses', '{}'::jsonb, 'expense', false, null, 1460),
  ('ZA', 'default', '6950', 'Foreign exchange losses', '{}'::jsonb, 'expense', false, null, 1470),
  ('ZA', 'default', '6960', 'Loss on disposal of non-current assets', '{}'::jsonb, 'expense', false, null, 1480),
  ('ZA', 'default', '6990', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1490),
  ('ZA', 'default', '7000', 'Interest on bank loans and overdraft', '{}'::jsonb, 'expense', false, null, 1500),
  ('ZA', 'default', '7010', 'Interest on lease liabilities', '{}'::jsonb, 'expense', false, null, 1510),
  ('ZA', 'default', '7020', 'Instalment sale and hire purchase interest', '{}'::jsonb, 'expense', false, null, 1520),
  ('ZA', 'default', '7030', 'Interest on late payment of tax', '{}'::jsonb, 'expense', false, null, 1530),
  ('ZA', 'default', '8000', 'Income tax expense — current', '{}'::jsonb, 'expense', false, null, 1540),
  ('ZA', 'default', '8010', 'Income tax expense — deferred', '{}'::jsonb, 'expense', false, null, 1550),
  ('ZA', 'default', '8020', 'Income tax — under or over provision of prior years', '{}'::jsonb, 'expense', false, null, 1560)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('ZA', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('ZA', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('ZA', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('ZA', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('ZA', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('ZA', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('ZA', 'ZA-P-EXEMPT', 'Purchase, exempt', '{}'::jsonb, null, 'percent', 0, 'purchase', 'exempt', date '2018-04-01', null, 'The supplier made an exempt supply under s. 12 of the Value-Added Tax Act 89 of 1991 — bank charges and interest under s. 12(a) among them — and charged no VAT.', 'E', null, 190, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('ZA', 'ZA-P-IMPORT-GOODS', 'Importation of goods, VAT 15 %', '{}'::jsonb, null, 'percent', 15, 'purchase', 'import', date '2018-04-01', null, 'Value-Added Tax Act 89 of 1991, s. 7(1)(b) and s. 13 — VAT is levied on the importation of goods into the Republic, collected by Customs on entry (s. 13(5)); s. 16(3)(a) lets the importer deduct it as input tax once it holds the bill of entry and the Customs receipt for payment (or a valid release document). VAT201 Field 15A — the permissible VAT amount of other goods (not capital goods) imported by you; the Customs Code field is mandatory on the return, which this pack does not carry. There is no base box for the customs value on this form.', null, null, 210, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat201-guide', null, null, null, null),
  ('ZA', 'ZA-P-IMPORT-GOODS-CAP', 'Importation of capital goods, VAT 15 %', '{}'::jsonb, null, 'percent', 15, 'purchase', 'import', date '2018-04-01', null, 'Value-Added Tax Act 89 of 1991, s. 7(1)(b), s. 13 and s. 16(3)(a), as ZA-P-IMPORT-GOODS. VAT201 Field 14A — the permissible VAT amount of capital goods imported by you, held apart from Field 15A.', null, null, 220, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat201-guide', null, null, null, null),
  ('ZA', 'ZA-P-NOT-SUBJECT', 'Purchase from a person who is not a vendor', '{}'::jsonb, null, 'percent', 0, 'purchase', 'not_subject', date '2018-04-01', null, 'Value-Added Tax Act 89 of 1991, s. 1(1) definition of "vendor" — a supplier who is not registered, and not required to be registered, for VAT charges none; there is nothing to deduct.', 'O', null, 200, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('ZA', 'ZA-P-RC-IMPORT', 'Imported services, reverse charged, not deductible', '{}'::jsonb, null, 'percent', 15, 'purchase', 'foreign_services_received', date '2018-04-01', null, 'Value-Added Tax Act 89 of 1991, s. 7(1)(c) and s. 14 — VAT is levied on the supply of "imported services": a service supplied by a person not established in the Republic to a recipient in the Republic, to the extent the recipient does not use it wholly for consumption, use or supply in the course of making taxable supplies; s. 14(5) makes the recipient itself liable for the VAT, self-assessed and declared on the VAT201 rather than charged by the (non-registered, non-resident) supplier. VAT201 Field 12 — Other and imported services — receives the VAT payable on "services imported by you for purposes of making non-taxable supplies" (VAT201 guide, Field 12); because the acquisition is not for a wholly taxable purpose, no part of it is deductible, so the VAT lands on the account of the line as a cost (tax_on_base) as well as being credited to the VAT output account and reported at Field 12, which forms part of Total Output Tax (Field 13). This pack does not carry the other items VAT201 lists under Field 12 — debit notes issued, credit notes received outside the ordinary credit-note flow, barter transactions, or adjustments on the acquisition of a going concern or a change of accounting basis.', null, null, 230, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'vat201-guide', null, null, null, null),
  ('ZA', 'ZA-P-VAT', 'Purchase, standard rate 15 %', '{}'::jsonb, null, 'percent', 15, 'purchase', 'domestic', date '2018-04-01', null, 'Value-Added Tax Act 89 of 1991, s. 16(3) — a vendor may deduct input tax on a supply to it that is a taxable supply, s. 17(1) to the extent the goods or services are acquired for consumption, use or supply in the course of making taxable supplies; s. 20(4) and s. 20(5) require a tax invoice, a full one above R5 000, before the deduction is made. Unlike VAT201 Field 1 on the sale side, Field 15 carries the VAT amount itself rather than a value to be grossed up: "the permissible VAT amount of other goods and/or services supplied to you (not capital goods)" (VAT201 guide, Field 15). There is no separate base box for a purchase on this form, so the base posting names none.', 'S', null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('ZA', 'ZA-P-VAT-CAP', 'Purchase of capital goods or services, standard rate 15 %', '{}'::jsonb, null, 'percent', 15, 'purchase', 'domestic', date '2018-04-01', null, 'Value-Added Tax Act 89 of 1991, s. 16(3). VAT201 Field 14 — the permissible VAT amount of capital goods and/or services supplied to you: office equipment, furniture, trucks, land and buildings — separately from Field 15.', 'S', null, 150, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat201-guide', null, null, null, null),
  ('ZA', 'ZA-P-VAT-CASH', 'Purchase, standard rate 15 %, vendor on the payments basis', '{}'::jsonb, null, 'percent', 15, 'purchase', 'domestic', date '2018-04-01', null, 'Value-Added Tax Act 89 of 1991, s. 16(3) read with s. 15(2) — a vendor on the payments basis deducts input tax only to the extent it has paid the consideration. The turnover condition is the purchasing vendor''s own and no word of `conditions` names it for a purchase, as ZA-S-VAT-CASH records for the sale side.', 'S', null, 140, 'vat', true, '{}'::tax_condition[], null, false, true, '1152', 'vat404', null, null, null, null),
  ('ZA', 'ZA-P-VAT-ITS', 'Purchase, standard rate 15 %, input tax denied — relates to exempt supplies', '{}'::jsonb, null, 'percent', 15, 'purchase', 'domestic', date '2018-04-01', null, 'Value-Added Tax Act 89 of 1991, s. 17(1) — input tax is deductible only to the extent goods or services are acquired for consumption, use or supply in the course of making taxable supplies; where an acquisition relates wholly to exempt supplies (bank charges, interest, residential rent paid) no part of the VAT is deductible, and where it relates to both an apportionment applies that this pack does not carry. The VAT follows the account of the line.', 'S', null, 170, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('ZA', 'ZA-P-VAT-NC', 'Purchase, standard rate 15 %, input tax denied — entertainment and motor cars', '{}'::jsonb, null, 'percent', 15, 'purchase', 'domestic', date '2018-04-01', null, 'Value-Added Tax Act 89 of 1991, s. 17(2)(a) — no input tax is deductible on goods or services acquired to provide entertainment, subject to the exceptions of the proviso (a vendor whose business is to provide entertainment for a charge); s. 17(2)(c) — no input tax is deductible on a "motor car" as defined in s. 1(1), subject to the exceptions for a car dealer, a car rental business or a driving school. The VAT is part of what the thing cost, so it lands on the account of the line; there is no box to report it in, because this return carries no base box for a purchase.', 'S', null, 160, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('ZA', 'ZA-P-ZERO', 'Purchase, zero-rated', '{}'::jsonb, null, 'percent', 0, 'purchase', 'domestic', date '2018-04-01', null, 'The supplier charged VAT at 0 % under s. 11(1) of the Value-Added Tax Act 89 of 1991, so there is no input tax to claim; there is no box on VAT201 for the value of a purchase carrying no VAT.', 'Z', null, 180, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('ZA', 'ZA-S-EXEMPT', 'Exempt supply', '{}'::jsonb, null, 'percent', 0, 'sale', 'exempt', date '2018-04-01', null, 'Value-Added Tax Act 89 of 1991, s. 12 — supplies exempt from VAT: s. 12(a) financial services as defined in s. 2; s. 12(c) the letting and hiring of a dwelling for residential accommodation; s. 12(h) transport of fare-paying passengers by road or rail (other than by a vendor conducting a tour or game viewing); s. 12(h) educational services supplied by an approved educational institution; s. 12(g) membership contributions to an employee organisation such as a trade union; s. 12(fA) donated goods or services supplied by an association not for gain. An exempt supply carries no output tax, and no input tax on what went into it may be deducted (s. 17(1)); no exemption reason code is carried, because the VATEX list names articles of a Directive of the European Union that does not bind a South African supplier — this pack''s section of docs/international.md records the gap. VAT201 Field 3 — exempt and non-supplies.', 'E', null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('ZA', 'ZA-S-EXPORT', 'Export of goods, zero-rated', '{}'::jsonb, null, 'percent', 0, 'sale', 'export', date '2018-04-01', null, 'Value-Added Tax Act 89 of 1991, s. 11(1)(a) — the supply of movable goods is zero-rated where the supplier exports them from the Republic, or supplies them in circumstances the regulations under s. 11(1) treat as an export (the Export Regulations, direct or indirect export); s. 11(3) requires the vendor to obtain and retain documentary proof, acceptable to the Commissioner, before the zero rate applies — a bill of lading or air waybill, a customs export declaration, the tax invoice and proof of payment. VAT 404, chapter 13: goods generally have to leave the Republic within 90 days of the earlier of invoice or payment. VAT201 Field 2A — zero rate, only exported goods, separately from Field 2.', 'G', null, 50, 'vat', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('ZA', 'ZA-S-NOT-SUBJECT', 'Supply outside the scope of VAT', '{}'::jsonb, null, 'percent', 0, 'sale', 'not_subject', date '2018-04-01', null, 'Value-Added Tax Act 89 of 1991, s. 7(1)(a) and the definition of "enterprise" in s. 1(1) — VAT is levied only on a supply made by a vendor in the course or furtherance of an enterprise; a sale made in a private capacity, or a supply that is not "in the Republic" for VAT purposes (s. 7(1) read with the place-of-supply rules of the Act), is not a taxable supply at all and carries no VAT201 field: VAT 404 does not report it anywhere on the return.', 'O', null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('ZA', 'ZA-S-VAT', 'Sale, standard rate 15 %', '{}'::jsonb, 'A taxable supply made by a vendor in the course or furtherance of an enterprise, in the Republic', 'percent', 15, 'sale', 'domestic', date '2018-04-01', null, 'Value-Added Tax Act 89 of 1991, s. 7(1)(a) — VAT is levied on the supply of goods or services by a vendor in the course or furtherance of an enterprise; s. 7(1) — the rate is 15 %, from 1 April 2018 (14 % before, and the increase to 15,5 % from 1 May 2025 proposed in the 2025 Budget was reversed by clause 13 of the Rates and Monetary Amounts and Amendment of Revenue Laws Bill, 2025, so the rate never in fact changed on that date). VAT201 Field 1 carries the VAT-inclusive consideration of a standard-rated supply, excluding capital goods and services and commercial accommodation; the engine holds the GST-exclusive value of the line, so this posting grosses it to the VAT-inclusive figure that Field 1 asks for — box_factor 115 — and Field 4 is the VAT itself, which is real ledger money rather than a reconstruction of Field 1 × 15/115.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('ZA', 'ZA-S-VAT-CAP', 'Sale of capital goods or services, standard rate 15 %', '{}'::jsonb, null, 'percent', 15, 'sale', 'domestic', date '2018-04-01', null, 'Value-Added Tax Act 89 of 1991, s. 7(1)(a); VAT201 Field 1A carries the VAT-inclusive consideration for capital goods and services supplied — land and buildings, plant and machinery, intellectual property — separately from Field 1, and Field 4A is the VAT itself, computed the same way as Field 4.', 'S', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat201-guide', null, null, null, null),
  ('ZA', 'ZA-S-VAT-CASH', 'Sale, standard rate 15 %, vendor on the payments basis', '{}'::jsonb, null, 'percent', 15, 'sale', 'domestic', date '2018-04-01', null, 'Value-Added Tax Act 89 of 1991, s. 15(2) — a vendor that is a public authority, a municipality, a welfare organisation, or a natural person (or a partnership of natural persons) whose taxable supplies have not exceeded, and are not likely to exceed, R2,5 million in a period of 12 months, may account for VAT on the payments basis: output tax on a sale is declared only to the extent payment has been received, and input tax on a purchase deducted only to the extent it has been paid. VAT 404, Guide for Vendors, chapter 4. Reported the same way as ZA-S-VAT, at the time payment is received rather than at the time the invoice is issued.', 'S', null, 20, 'vat', true, array['seller_threshold']::tax_condition[], null, false, true, '2105', 'vat404', null, null, null, null),
  ('ZA', 'ZA-S-ZERO', 'Sale, zero-rated, domestic', '{}'::jsonb, null, 'percent', 0, 'sale', 'domestic', date '2018-04-01', null, 'Value-Added Tax Act 89 of 1991, s. 11(1)(j) to (zA) and Schedule 2, Part I — a list of goods and services zero-rated at 0 %, among them: brown bread, maize meal, rice, dried beans, lentils, milk, eggs, edible legumes, vegetable oil (Schedule 2, Part I, items 1 to 19, basic foodstuffs); s. 11(1)(g) international transport of goods and passengers; s. 11(2)(l) municipal property rates on residential property; s. 8(25) and s. 11(1)(e) the sale of a business or part of a business capable of separate operation, sold as a going concern; and fuel levy goods such as petrol and diesel, which fall outside VAT because they carry the general fuel levy under the Customs and Excise Act 91 of 1964 instead. VAT201 Field 2 — zero rate, excluding goods exported. A zero-rated supply is a taxable supply at a nil charge, not an exempt one: the input tax on what went into it stays deductible.', 'Z', null, 40, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null)
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
    ('ZA-P-EXEMPT', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('ZA-P-EXEMPT', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('ZA-P-IMPORT-GOODS', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('ZA-P-IMPORT-GOODS', 'invoice', 'tax', 100, '1150', '15A', array['15A']::text[], 100, 'ZA-VAT201', 20),
    ('ZA-P-IMPORT-GOODS', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('ZA-P-IMPORT-GOODS', 'credit_note', 'tax', 100, '1150', '15A', array['15A']::text[], -100, 'ZA-VAT201', 20),
    ('ZA-P-IMPORT-GOODS-CAP', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('ZA-P-IMPORT-GOODS-CAP', 'invoice', 'tax', 100, '1150', '14A', array['14A']::text[], 100, 'ZA-VAT201', 20),
    ('ZA-P-IMPORT-GOODS-CAP', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('ZA-P-IMPORT-GOODS-CAP', 'credit_note', 'tax', 100, '1150', '14A', array['14A']::text[], -100, 'ZA-VAT201', 20),
    ('ZA-P-NOT-SUBJECT', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('ZA-P-NOT-SUBJECT', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('ZA-P-RC-IMPORT', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('ZA-P-RC-IMPORT', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('ZA-P-RC-IMPORT', 'invoice', 'tax', -100, '2100', '12', array['12']::text[], 100, 'ZA-VAT201', 30),
    ('ZA-P-RC-IMPORT', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('ZA-P-RC-IMPORT', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('ZA-P-RC-IMPORT', 'credit_note', 'tax', -100, '2100', '12', array['12']::text[], -100, 'ZA-VAT201', 30),
    ('ZA-P-VAT', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('ZA-P-VAT', 'invoice', 'tax', 100, '1150', '15', array['15']::text[], 100, 'ZA-VAT201', 20),
    ('ZA-P-VAT', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('ZA-P-VAT', 'credit_note', 'tax', 100, '1150', '15', array['15']::text[], -100, 'ZA-VAT201', 20),
    ('ZA-P-VAT-CAP', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('ZA-P-VAT-CAP', 'invoice', 'tax', 100, '1150', '14', array['14']::text[], 100, 'ZA-VAT201', 20),
    ('ZA-P-VAT-CAP', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('ZA-P-VAT-CAP', 'credit_note', 'tax', 100, '1150', '14', array['14']::text[], -100, 'ZA-VAT201', 20),
    ('ZA-P-VAT-CASH', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('ZA-P-VAT-CASH', 'invoice', 'tax', 100, '1150', '15', array['15']::text[], 100, 'ZA-VAT201', 20),
    ('ZA-P-VAT-CASH', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('ZA-P-VAT-CASH', 'credit_note', 'tax', 100, '1150', '15', array['15']::text[], -100, 'ZA-VAT201', 20),
    ('ZA-P-VAT-ITS', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('ZA-P-VAT-ITS', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('ZA-P-VAT-ITS', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('ZA-P-VAT-ITS', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('ZA-P-VAT-NC', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('ZA-P-VAT-NC', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('ZA-P-VAT-NC', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('ZA-P-VAT-NC', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('ZA-P-ZERO', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('ZA-P-ZERO', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('ZA-S-EXEMPT', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'ZA-VAT201', 10),
    ('ZA-S-EXEMPT', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'ZA-VAT201', 10),
    ('ZA-S-EXPORT', 'invoice', 'base', 100, null, '2A', array['2A']::text[], 100, 'ZA-VAT201', 10),
    ('ZA-S-EXPORT', 'credit_note', 'base', 100, null, '2A', array['2A']::text[], -100, 'ZA-VAT201', 10),
    ('ZA-S-NOT-SUBJECT', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('ZA-S-NOT-SUBJECT', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('ZA-S-VAT', 'invoice', 'base', 100, null, '1', array['1']::text[], 115, 'ZA-VAT201', 10),
    ('ZA-S-VAT', 'invoice', 'tax', 100, '2100', '4', array['4']::text[], 100, 'ZA-VAT201', 20),
    ('ZA-S-VAT', 'credit_note', 'base', 100, null, '1', array['1']::text[], -115, 'ZA-VAT201', 10),
    ('ZA-S-VAT', 'credit_note', 'tax', 100, '2100', '4', array['4']::text[], -100, 'ZA-VAT201', 20),
    ('ZA-S-VAT-CAP', 'invoice', 'base', 100, null, '1A', array['1A']::text[], 115, 'ZA-VAT201', 10),
    ('ZA-S-VAT-CAP', 'invoice', 'tax', 100, '2100', '4A', array['4A']::text[], 100, 'ZA-VAT201', 20),
    ('ZA-S-VAT-CAP', 'credit_note', 'base', 100, null, '1A', array['1A']::text[], -115, 'ZA-VAT201', 10),
    ('ZA-S-VAT-CAP', 'credit_note', 'tax', 100, '2100', '4A', array['4A']::text[], -100, 'ZA-VAT201', 20),
    ('ZA-S-VAT-CASH', 'invoice', 'base', 100, null, '1', array['1']::text[], 115, 'ZA-VAT201', 10),
    ('ZA-S-VAT-CASH', 'invoice', 'tax', 100, '2100', '4', array['4']::text[], 100, 'ZA-VAT201', 20),
    ('ZA-S-VAT-CASH', 'credit_note', 'base', 100, null, '1', array['1']::text[], -115, 'ZA-VAT201', 10),
    ('ZA-S-VAT-CASH', 'credit_note', 'tax', 100, '2100', '4', array['4']::text[], -100, 'ZA-VAT201', 20),
    ('ZA-S-ZERO', 'invoice', 'base', 100, null, '2', array['2']::text[], 100, 'ZA-VAT201', 10),
    ('ZA-S-ZERO', 'credit_note', 'base', 100, null, '2', array['2']::text[], -100, 'ZA-VAT201', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'ZA' and t.code = v.tax_code
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
  ('ZA', 'ZA-VAT201', 'Value-Added Tax return (VAT201)', array['month', 'bimonth']::declaration_period[], null, date '2018-04-01', null, 'Value-Added Tax Act 89 of 1991, s. 27 — a vendor''s tax period falls into one of six categories: Category A and Category B, two calendar months each, the Commissioner assigning a vendor to one or the other so as to keep the two roughly equal in number (s. 27(4)); Category C, one calendar month, compulsory once taxable supplies exceed R30 million in a 12-month period (s. 27(3)); Category D, six calendar months, for farming enterprises and qualifying micro businesses under R1,5 million; Category E, twelve months ending on the vendor''s own year of assessment, for certain companies, trusts and connected persons; Category F, four calendar months, ending June, October and February. This engine''s cadences are fixed to the calendar and anchored on 1 January: `bimonth` — January-February, March-April and so on — matches Category B exactly, and `month` matches Category C; Category A''s periods (December-January, February-March …), Category D''s (September-February, March-August) and Category F''s (March-June, July-October, November-February) are each offset from the engine''s anchoring and Category E is anchored on a company''s own year of assessment rather than the calendar year, so none of the four is expressible by this pack — see this pack''s section of docs/international.md. s. 28(1) requires the return and payment on or before the 25th of the month following the tax period; VAT201 guide, GEN-ELEC-04-G01, 3(d) — a vendor who files and pays by SARS eFiling has until the last business day of that month instead, which almost every vendor uses and which this pack''s single `day_of_month_after_period` rule cannot also express. Filed on eFiling: SARS, VAT201 return.', true,'day_of_month_after_period'::filing_deadline_rule, 25, null, 'Value-Added Tax Act 89 of 1991, s. 28(1) — a vendor shall furnish a return and make payment within the period ending on the twenty-fifth day of the first month commencing after the end of a tax period.', 'vat-act', null)
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
  ('ZA', 'ZA-VAT201', '1', 'base', 'Standard rate (excluding capital goods and/or services and accommodation)', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT201, Field 1, and VAT201 guide, GEN-ELEC-04-G01, 7.6(b) — the VAT-inclusive consideration for standard-rated supplies, other than capital goods and services (Field 1A) and commercial accommodation (Fields 5 and 7).', 'vat201-guide'),
  ('ZA', 'ZA-VAT201', '1A', 'base', 'Standard rate (only capital goods and/or services)', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT201, Field 1A — the VAT-inclusive consideration for capital goods and services supplied: sale of land and buildings, plant and machinery, intellectual property, and VAT on assets on termination of registration.', 'vat201-guide'),
  ('ZA', 'ZA-VAT201', '2', 'base', 'Zero rate (excluding goods exported)', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT201, Field 2 — supplies at the zero rate under s. 11 of the Value-Added Tax Act 89 of 1991, other than exported goods (Field 2A).', 'vat201-guide'),
  ('ZA', 'ZA-VAT201', '2A', 'base', 'Zero rate (only exported goods)', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT201, Field 2A — goods exported from the Republic at the zero rate under s. 11(1) of the Value-Added Tax Act 89 of 1991; the Customs Code field is mandatory when this field is completed, which this pack does not carry.', 'vat201-guide'),
  ('ZA', 'ZA-VAT201', '3', 'base', 'Exempt and non-supplies', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT201, Field 3 — supplies exempt under s. 12 of the Value-Added Tax Act 89 of 1991, and non-supplies.', 'vat201-guide'),
  ('ZA', 'ZA-VAT201', '4', 'tax', 'VAT on standard rate supplies (Field 1)', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT201, Field 4 — ''Field 1 x (r / (100 + r))'', where r is 15. This pack posts the VAT itself, the real ledger amount, which equals the form''s own tax-fraction reconstruction of Field 1 at 15 %, the only standard rate this pack carries.', 'vat201-guide'),
  ('ZA', 'ZA-VAT201', '4A', 'tax', 'VAT on standard rate capital goods and/or services (Field 1A)', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT201, Field 4A — ''Field 1A x (r / (100 + r))'', held to the ledger''s own figure for the reason given at Field 4.', 'vat201-guide'),
  ('ZA', 'ZA-VAT201', '5', 'base', 'Supply of commercial accommodation exceeding 28 days', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT201, Field 5, and Value-Added Tax Act 89 of 1991, s. 8(13) — accommodation supplied for a full period exceeding 28 days is deemed to be supplied at 60 % of its all-inclusive value. Declared and left empty: this pack carries no tax code for the accommodation apportionment of s. 8(13), which a hospitality-specific pack would need — see this pack''s section of docs/international.md.', 'vat-act'),
  ('ZA', 'ZA-VAT201', '6', 'total', '60 % of Field 5', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], 60, '5', false, false, null, 'VAT201, Field 6 — ''Field 5 x 60 %''.', 'vat201-guide'),
  ('ZA', 'ZA-VAT201', '7', 'base', 'Supply of commercial accommodation not exceeding 28 days', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT201, Field 7 — the VAT-exclusive value of commercial accommodation supplied for a period of 28 days or less, taxed at the standard rate on its full value. Declared and left empty, for the reason given at Field 5.', 'vat201-guide'),
  ('ZA', 'ZA-VAT201', '8', 'total', 'Field 6 plus Field 7', '{}'::jsonb, 110, null, array['6', '7']::text[], '{}'::text[], null, null, false, false, null, 'VAT201, Field 8 — ''the sum of Fields 6 and 7''.', 'vat201-guide'),
  ('ZA', 'ZA-VAT201', '9', 'total', 'VAT on commercial accommodation', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], 15, '8', false, false, null, 'VAT201, Field 9 — ''Field 8 x (r / 100)'', applying the tax rate rather than the tax fraction because Field 8 is already the deemed taxable value and not a VAT-inclusive figure.', 'vat201-guide'),
  ('ZA', 'ZA-VAT201', '10', 'base', 'Change in use and export of second-hand goods', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT201, Field 10 — consideration on goods or services acquired for taxable supplies but applied to private or exempt use, and the price of second-hand goods on which notional input tax was deducted and which were subsequently exported. Declared and left empty: this pack does not carry a change-in-use or a second-hand-goods notional-input-tax code — see this pack''s section of docs/international.md.', 'vat201-guide'),
  ('ZA', 'ZA-VAT201', '11', 'total', 'VAT on Field 10', '{}'::jsonb, 140, null, '{}'::text[], '{}'::text[], 15, '10', false, false, null, 'VAT201, Field 11 — ''Field 10 x (r / (100 + r))''.', 'vat201-guide'),
  ('ZA', 'ZA-VAT201', '12', 'tax', 'Other and imported services', '{}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT201, Field 12, and Value-Added Tax Act 89 of 1991, s. 7(1)(c) and s. 14 — VAT payable on imported services not wholly for a taxable purpose, self-assessed by the recipient, which this pack carries; the guide also lists debit notes issued, credit notes received outside the ordinary credit-note flow, barter transactions and adjustments on a going concern or a change of accounting basis, none of which this pack carries — see this pack''s section of docs/international.md.', 'vat201-guide'),
  ('ZA', 'ZA-VAT201', '13', 'total', 'Total Output Tax', '{}'::jsonb, 160, null, array['4', '4A', '9', '11', '12']::text[], '{}'::text[], null, null, false, false, null, 'VAT201, Field 13 — ''the sum of Fields (4+4A+9+11+12)''.', 'vat201-guide'),
  ('ZA', 'ZA-VAT201', '14', 'tax', 'Capital goods and/or services supplied to you', '{}'::jsonb, 170, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT201, Field 14 — the permissible VAT amount of capital goods and/or services supplied to the vendor: office equipment, furniture, trucks, land and buildings.', 'vat201-guide'),
  ('ZA', 'ZA-VAT201', '14A', 'tax', 'Capital goods imported by you', '{}'::jsonb, 180, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT201, Field 14A — the permissible VAT amount of capital goods imported by the vendor; the Customs Code field is mandatory on the return, which this pack does not carry.', 'vat201-guide'),
  ('ZA', 'ZA-VAT201', '15', 'tax', 'Other goods and/or services supplied to you (not capital goods)', '{}'::jsonb, 190, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT201, Field 15 — the permissible VAT amount of other goods and services supplied to the vendor: accounting fees, advertising, rent, stock, telephone, water and lights.', 'vat201-guide'),
  ('ZA', 'ZA-VAT201', '15A', 'tax', 'Other goods imported by you (not capital goods)', '{}'::jsonb, 200, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT201, Field 15A — the permissible VAT amount of other goods (not capital goods) imported by the vendor, held apart from Field 14A.', 'vat201-guide'),
  ('ZA', 'ZA-VAT201', '16', 'tax', 'Change in use', '{}'::jsonb, 210, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT201, Field 16 — the VAT on goods or services previously applied for non-taxable purposes and now applied, wholly or partly, for taxable purposes. Declared and left empty, for the reason given at Field 10.', 'vat201-guide'),
  ('ZA', 'ZA-VAT201', '17', 'tax', 'Bad debts', '{}'::jsonb, 220, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT201, Field 17, and Value-Added Tax Act 89 of 1991, s. 22(1) — the VAT on an irrecoverable debt written off, on the invoice basis. Declared and left empty: this pack has no document for a debt write-off.', 'vat201-guide'),
  ('ZA', 'ZA-VAT201', '18', 'tax', 'Other', '{}'::jsonb, 230, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT201, Field 18 — credit notes issued, debit notes received and VAT adjustments on a change of accounting basis, outside the ordinary invoice and credit-note flow this pack''s taxes already carry. Declared and left empty.', 'vat201-guide'),
  ('ZA', 'ZA-VAT201', '19', 'total', 'Total Input Tax', '{}'::jsonb, 240, null, array['14', '14A', '15', '15A', '16', '17', '18']::text[], '{}'::text[], null, null, false, false, null, 'VAT201, Field 19 — ''the sum of Fields (14+14A+15+15A+16+17+18)''.', 'vat201-guide'),
  ('ZA', 'ZA-VAT201', '20', 'total', 'VAT Payable / Refundable (Total A - Total B)', '{}'::jsonb, 250, null, array['13']::text[], array['19']::text[], null, null, false, false, null, 'VAT201, Field 20 — ''the difference between Fields 13 and 19''; a negative figure is a refund, marked with a minus sign on the form. This pack writes the signed subtraction directly.', 'vat201-guide')
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
  ('ZA-IFRSSME-PL', 'ZA', 'default', 'Statement of comprehensive income — IFRS for SMEs Accounting Standard, Section 5, expenses by nature', 'income_statement', 'ZA-IFRS-FOR-SMES', date '1970-01-01', null, 'IFRS for SMEs, paragraph 5.5 lists the line items a statement of comprehensive income presents as a minimum, and paragraph 5.11 requires an analysis of expenses using a classification based on either their nature or their function, whichever provides information that is reliable and more relevant; this statement analyses them by nature, which a small company''s ledger holds without any allocation. The share of the profit or loss of associates and joint ventures (5.5(c)), discontinued operations (5.5(e)) and other comprehensive income (5.5(g)) are not lines here, because the chart carries no account for them: a company with none of those is permitted a single profit-or-loss line under paragraph 5.5(f).', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'ZA', 'default', 'Statement of financial position — IFRS for SMEs Accounting Standard, Section 4', 'balance_sheet', 'ZA-IFRS-FOR-SMES', date '1970-01-01', null, 'Companies Act 71 of 2008, s. 29(1) — the annual financial statements of a company must satisfy the financial reporting standard applicable to that company and present fairly its state of affairs; s. 30. Companies Regulation 27(4) — a company that is not required to have its financial statements audited (Regulation 28) may prepare them in accordance with the IFRS for SMEs Accounting Standard, as approved for use in the Republic by the Financial Reporting Standards Council. IFRS for SMEs, paragraph 4.2, lists the line items a statement of financial position presents as a minimum, and paragraph 4.2A leaves their order and format to the entity, so the lines below are those items in the order South African practice prints them, classified current and non-current under paragraphs 4.4 to 4.8. Biological assets (4.2(h)-(i)) and non-controlling interests (4.2(q)) are not lines here, because the chart carries no account for them.', 'ifrs-for-smes')
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
  ('ZA-IFRSSME-PL', '1', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 5.5(a).', 'ifrs-for-smes'),
  ('ZA-IFRSSME-PL', '2', null, 'Other income', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 5.9 — an entity presents additional line items when relevant to an understanding of its financial performance: interest, rent, grants, foreign exchange gains and gains on disposal, which are not revenue from the entity''s ordinary activities.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-PL', '3', null, 'Raw materials, consumables and goods for resale used', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 5.11(b) — expenses analysed by their nature: purchases of materials and goods, freight inwards, import charges, the change in inventories and subcontractors.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-PL', '4', null, 'Employee benefits expense', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 5.11(b) — employee benefits costs, UIF and Skills Development Levy contributions among them.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-PL', '5', null, 'Depreciation and amortisation expense', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 5.11(b) — depreciation.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-PL', '6', null, 'Other expenses', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 5.11(b) — the other expenses by nature, foreign exchange losses and losses on disposal among them.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-PL', '7', null, 'Finance costs', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 5.5(b).', 'ifrs-for-smes'),
  ('ZA-IFRSSME-PL', '8', null, 'Profit before income tax', '{}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('ZA-IFRSSME-PL', '9', null, 'Income tax expense', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 5.5(d) — tax expense, excluding dividends tax, which the Income Tax Act 58 of 1962, s. 64E, imposes on the shareholder and the company only withholds and remits: it is never a charge against the company''s own profit.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-PL', '10', null, 'Profit for the year', '{}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, 'IFRS for SMEs, paragraph 5.5(f) — profit or loss. The pack carries no item of other comprehensive income, so paragraph 5.5(f)''s permission applies and this is also total comprehensive income.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'CA', null, 'Current assets', '{}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5', 'CA.6']::text[], '{}'::text[], null, 'IFRS for SMEs, paragraphs 4.4 to 4.8 — current and non-current assets are presented as separate classifications, an asset being current when it is expected to be realised in the entity''s normal operating cycle, held for trading, expected to be realised within twelve months, or is cash or a cash equivalent not restricted for at least twelve months.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'CA.1', 'CA', 'Cash and cash equivalents', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(a).', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'CA.2', 'CA', 'Trade and other receivables', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(b). VAT input and the VAT refund due from SARS are receivables from the Commissioner and not current tax, which paragraph 4.2(n) keeps for income tax; the suspense account reports here while it is in debit.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'CA.3', 'CA', 'Inventories', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(d).', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'CA.4', 'CA', 'Financial assets', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(c), the part realised within twelve months.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'CA.5', 'CA', 'Current tax assets', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(n) — assets for current tax, which in South Africa is income tax under the Income Tax Act 58 of 1962.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'CA.6', 'CA', 'Other current assets', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.3 — an entity presents additional line items when relevant to an understanding of its financial position: prepayments and deposits paid, which are neither receivables nor financial assets.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'NCA', null, 'Non-current assets', '{}'::jsonb, 80, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4', 'NCA.5', 'NCA.6', 'NCA.7']::text[], '{}'::text[], null, 'IFRS for SMEs, paragraphs 4.4 and 4.5 — every asset that is not current is non-current.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'NCA.1', 'NCA', 'Property, plant and equipment', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(e). Right-of-use assets are presented within this line, beside the assets of the same nature; each cost account carries its accumulated depreciation on the next code so that one range reaches the carrying amount.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'NCA.2', 'NCA', 'Investment property', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(f).', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'NCA.3', 'NCA', 'Intangible assets', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(g).', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'NCA.4', 'NCA', 'Investments in associates', '{}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(j).', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'NCA.5', 'NCA', 'Investments in joint ventures', '{}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(k).', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'NCA.6', 'NCA', 'Financial assets', '{}'::jsonb, 140, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(c), the part not realised within twelve months.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'NCA.7', 'NCA', 'Deferred tax assets', '{}'::jsonb, 150, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(o) — deferred tax assets and liabilities are always classified as non-current.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'TA', null, 'Total assets', '{}'::jsonb, 160, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('ZA-IFRSSME-SFP', 'CL', null, 'Current liabilities', '{}'::jsonb, 170, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4']::text[], '{}'::text[], null, 'IFRS for SMEs, paragraphs 4.4, 4.6 and 4.7 — current and non-current liabilities are presented as separate classifications.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'CL.1', 'CL', 'Trade and other payables', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(l). VAT output, the VAT payable to SARS, dividends tax withheld and employees'' tax (PAYE) are owed to SARS and are not current income tax, so they report here and not under paragraph 4.2(n); the suspense account reports here while it is in credit.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'CL.2', 'CL', 'Financial liabilities', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(m), the part due within twelve months, the credit card among them.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'CL.3', 'CL', 'Current tax liabilities', '{}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(n) — liabilities for current tax: income tax and provisional tax.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'CL.4', 'CL', 'Provisions', '{}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(p), the part expected to be settled within twelve months, leave pay among it.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'NCL', null, 'Non-current liabilities', '{}'::jsonb, 220, 1, true, array['NCL.1', 'NCL.2', 'NCL.3']::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.7 — every liability that is not current is non-current.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'NCL.1', 'NCL', 'Financial liabilities', '{}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(m), the part not due within twelve months.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'NCL.2', 'NCL', 'Deferred tax liabilities', '{}'::jsonb, 240, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(o).', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'NCL.3', 'NCL', 'Provisions', '{}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(p), the part not expected to be settled within twelve months.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'TL', null, 'Total liabilities', '{}'::jsonb, 260, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('ZA-IFRSSME-SFP', 'NA', null, 'Net assets', '{}'::jsonb, 270, 1, true, array['TA']::text[], array['TL']::text[], null, 'Not a line paragraph 4.2 lists: the subtotal a South African statement of financial position prints above equity, which paragraph 4.3 allows. It equals total equity once the year is closed, and exceeds it by the profit of the year until then.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'EQ', null, 'Equity', '{}'::jsonb, 280, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(r) — equity attributable to the owners of the parent; paragraph 4.12(f) asks for its classes, which are the three lines below.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'EQ.1', 'EQ', 'Issued capital', '{}'::jsonb, 290, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.12(f) — classes of equity, such as paid-in capital; a close corporation''s members'' contributions report on the same line.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'EQ.2', 'EQ', 'Reserves', '{}'::jsonb, 300, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.12(f) — reserves.', 'ifrs-for-smes'),
  ('ZA-IFRSSME-SFP', 'EQ.3', 'EQ', 'Retained earnings', '{}'::jsonb, 310, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.12(f) — retained earnings, after the dividends declared that are booked beside them.', 'ifrs-for-smes')
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
    ('ZA-IFRSSME-PL', '1', 10, 'code_range', '4000', '4090', null, 'any'),
    ('ZA-IFRSSME-PL', '2', 10, 'code_range', '4500', '4750', null, 'any'),
    ('ZA-IFRSSME-PL', '3', 10, 'code_range', '5000', '5100', null, 'any'),
    ('ZA-IFRSSME-PL', '4', 10, 'code_range', '6000', '6070', null, 'any'),
    ('ZA-IFRSSME-PL', '5', 10, 'code_range', '6200', '6230', null, 'any'),
    ('ZA-IFRSSME-PL', '6', 10, 'code_range', '6300', '6990', null, 'any'),
    ('ZA-IFRSSME-PL', '7', 10, 'code_range', '7000', '7030', null, 'any'),
    ('ZA-IFRSSME-PL', '9', 10, 'code_range', '8000', '8020', null, 'any'),
    ('ZA-IFRSSME-SFP', 'CA.1', 10, 'code_range', '1000', '1060', null, 'any'),
    ('ZA-IFRSSME-SFP', 'CA.2', 10, 'code_range', '1100', '1155', null, 'any'),
    ('ZA-IFRSSME-SFP', 'CA.2', 20, 'account_code', '2990', null, null, 'debit'),
    ('ZA-IFRSSME-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('ZA-IFRSSME-SFP', 'CA.4', 10, 'code_range', '1300', '1320', null, 'any'),
    ('ZA-IFRSSME-SFP', 'CA.5', 10, 'account_code', '1350', null, null, 'any'),
    ('ZA-IFRSSME-SFP', 'CA.6', 10, 'code_range', '1400', '1420', null, 'any'),
    ('ZA-IFRSSME-SFP', 'NCA.1', 10, 'code_range', '1600', '1680', null, 'any'),
    ('ZA-IFRSSME-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('ZA-IFRSSME-SFP', 'NCA.3', 10, 'code_range', '1750', '1771', null, 'any'),
    ('ZA-IFRSSME-SFP', 'NCA.4', 10, 'account_code', '1800', null, null, 'any'),
    ('ZA-IFRSSME-SFP', 'NCA.5', 10, 'account_code', '1810', null, null, 'any'),
    ('ZA-IFRSSME-SFP', 'NCA.6', 10, 'code_range', '1820', '1840', null, 'any'),
    ('ZA-IFRSSME-SFP', 'NCA.7', 10, 'account_code', '1900', null, null, 'any'),
    ('ZA-IFRSSME-SFP', 'CL.1', 10, 'code_range', '2000', '2120', null, 'any'),
    ('ZA-IFRSSME-SFP', 'CL.1', 20, 'account_code', '2990', null, null, 'credit'),
    ('ZA-IFRSSME-SFP', 'CL.2', 10, 'code_range', '2200', '2240', null, 'any'),
    ('ZA-IFRSSME-SFP', 'CL.3', 10, 'code_range', '2300', '2310', null, 'any'),
    ('ZA-IFRSSME-SFP', 'CL.4', 10, 'code_range', '2350', '2370', null, 'any'),
    ('ZA-IFRSSME-SFP', 'NCL.1', 10, 'code_range', '2400', '2430', null, 'any'),
    ('ZA-IFRSSME-SFP', 'NCL.2', 10, 'account_code', '2500', null, null, 'any'),
    ('ZA-IFRSSME-SFP', 'NCL.3', 10, 'code_range', '2550', '2560', null, 'any'),
    ('ZA-IFRSSME-SFP', 'EQ.1', 10, 'code_range', '3000', '3020', null, 'any'),
    ('ZA-IFRSSME-SFP', 'EQ.2', 10, 'code_range', '3100', '3110', null, 'any'),
    ('ZA-IFRSSME-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('ZA', 'South Africa', '{}'::jsonb, array['en']::text[], 'ZAR', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', default, default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, null)
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
  numbering_legal_reference     = 'Value-Added Tax Act 89 of 1991, s. 20(4)(b) — a full tax invoice must reflect a serial number and the date of issue; s. 20(5) requires the same of an abridged tax invoice, issued where the consideration is less than R5 000. Neither subsection requires the numbering to be unbroken or to restart with the year, so numbering is `sequential` rather than `gapless_per_year`; the pattern in number_format is a business''s own choice of a serial number, not one the Act prescribes.',
  numbering_source_key          = 'vat-act',
  payment_terms_legal_reference = 'No statute of general application fixes a payment term between businesses in South Africa in the absence of an agreement, and none fixes a statutory rate of interest specific to a late commercial invoice, so legal_payment_days and late_payment_reference are left empty. The Prescribed Rate of Interest Act 55 of 1975, s. 1, fixes the rate of interest that runs on any unpaid debt (mora interest) where the parties have not agreed one, currently set by the Minister by notice in the Gazette; it is a general fallback rate on any debt and not a term the VAT Act or company law imposes on an invoice.',
  payment_terms_source_key      = 'prescribed-rate-interest-act',
  tax_point_rule                = 'invoice_date',
  tax_point_legal_reference     = 'Value-Added Tax Act 89 of 1991, s. 9(1) — a supply is deemed to take place at the time an invoice is issued by the supplier or recipient in respect of that supply, or the time any payment of consideration is received by the supplier, whichever time is earlier. `invoice_date` is right whenever the invoice comes first, which is the ordinary case between VAT vendors, and wrong for a deposit received before any invoice is issued, which Ekwo has no document for; s. 15(2) moves the whole of it to payment for a vendor registered on the payments basis, which the taxes that declare cash_basis carry.',
  tax_point_source_key          = 'vat-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No provision of the Value-Added Tax Act 89 of 1991 obliges a vendor to issue or to accept a structured electronic invoice, and South Africa carries no Peppol authority or network profile at the date of this pack. SARS''s Strategic Plan 2025/26–2029/30 and its VAT Modernisation programme describe a multi-year, phased move towards real-time, transaction-level VAT reporting with e-invoicing as a foundational pillar, beginning with voluntary onboarding of the largest Category C vendors; no bill amending the VAT Act to make any of it mandatory had been introduced in Parliament at 25 September 2026. A tax invoice today is a document, on paper or as a PDF, that carries the particulars of section 20(4) or 20(5).',
  einvoice_source_key           = 'sars-vat-modernisation',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'ZA';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('ZA', 'export', 'export', 'Zero-rated export in terms of section 11(1) of the Value-Added Tax Act 89 of 1991.', '{}'::jsonb, 10, date '1970-01-01', null, 'Value-Added Tax Act 89 of 1991, s. 11(3) — the vendor must obtain and retain documentary proof, acceptable to the Commissioner, substantiating a rate of zero per cent charged under s. 11(1) or s. 11(2); VAT 404, Guide for Vendors, chapter 13, requires a full tax invoice on a zero-rated supply that states the rate charged. The sentence records the article the zero rate is claimed under, since South Africa is outside the VATEX list of the European Union''s common system and carries no exemption reason code of its own.'),
  ('ZA', 'exempt', 'exempt', 'Exempt supply in terms of section 12 of the Value-Added Tax Act 89 of 1991 — no VAT is charged and no input tax on what went into it may be deducted.', '{}'::jsonb, 20, date '1970-01-01', null, 'Value-Added Tax Act 89 of 1991, s. 12 — the supplies exempt from VAT: financial services, the letting of a dwelling for residential accommodation, the letting of leasehold land for residential purposes, educational services, transport of fare-paying passengers by road or rail, and the other exemptions the section lists.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
