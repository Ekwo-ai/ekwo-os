-- Ekwo OS — Saudi Arabia: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/sa at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build sa`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Common VAT Agreement of the States of the Gulf Cooperation Council (GCC), signed 27/2/1438H corresponding to 27 November 2016, ratified for the Kingdom by Royal Decree No. M/51 dated 3 Jumada I 1438H (Gulf Cooperation Council, published by the Zakat, Tax and Customs Authority)
--     https://zatca.gov.sa/ar/RulesRegulations/Taxes/Documents/GCC%20VAT%20Agreement.pdf
--   نظام ضريبة القيمة المضافة — the Value Added Tax Law, Royal Decree No. M/113 dated 2 Dhul Qa'dah 1438H, as amended by Royal Decree No. M/52 dated 28 Rabi II 1441H and Royal Order No. A/638 dated 15 Shawwal 1441H (consolidated Arabic text) (Zakat, Tax and Customs Authority)
--     https://zatca.gov.sa/ar/RulesRegulations/Taxes/Documents/%D9%86%D8%B8%D8%A7%D9%85%20%D8%B6%D8%B1%D9%8A%D8%A8%D8%A9%20%D8%A7%D9%84%D9%82%D9%8A%D9%85%D8%A9%20%D8%A7%D9%84%D9%85%D8%B6%D8%A7%D9%81%D8%A9%20(2).pdf
--   Implementing Regulations of the Value Added Tax Law, Board Resolution No. (3839) dated 14/12/1438H, as amended — eighth edition, 04/04/1443H corresponding to 09/11/2021 (ZATCA English translation) (Zakat, Tax and Customs Authority)
--     https://zatca.gov.sa/en/RulesRegulations/Taxes/Documents/Implmenting%20Regulations%20of%20the%20VAT%20Law_EN.pdf
--   اللائحة التنفيذية لنظام ضريبة القيمة المضافة — the Implementing Regulations in the official Arabic the English translation defers to, tenth edition, Shawwal 1446H corresponding to April 2025 (Zakat, Tax and Customs Authority)
--     https://zatca.gov.sa/ar/RulesRegulations/Taxes/Documents/Implmenting%20Regulations%20of%20the%20VAT%20Law.pdf
--   Guideline for Amendments to the Implementing Regulation of Value Added Tax (VAT), issued by ZATCA's Board of Directors Resolution No. (01-06-24) dated November 19, 2024 — Issue 1, April 2025 (Zakat, Tax and Customs Authority)
--     https://zatca.gov.sa/en/HelpCenter/guidelines/Documents/Amendments-to-the-Implementing-Regulation-of-(VAT).PDF
--   Guideline on Imports and Exports under VAT Provisions, second edition, May 2026 (Zakat, Tax and Customs Authority)
--     https://zatca.gov.sa/en/HelpCenter/guidelines/Documents/Guideline-on-Imports-and-Exports-under-VAT-Provision.pdf
--   الدليل المبسط لتقديم إقرار ضريبة القيمة المضافة — the simplified guideline to filing a VAT return, which reproduces the return's own sales screen with its fields numbered (Zakat, Tax and Customs Authority)
--     https://zatca.gov.sa/ar/HelpCenter/guidelines/Documents/Simplified_VAT_Filing_Guidelines.pdf
--   User Guide — Submit VAT Return Service (Zakat, Tax and Customs Authority)
--     https://zatca.gov.sa/en/eServices/Documents/eServices_Manual_009.pdf
--   Submit VAT Return — the e-service a return is filed on (Zakat, Tax and Customs Authority)
--     https://zatca.gov.sa/en/eServices/Pages/eServices-009.aspx
--   Register in Value Added Tax — the e-service, which states the mandatory and voluntary registration thresholds (Zakat, Tax and Customs Authority)
--     https://zatca.gov.sa/en/eServices/Pages/eServices_002.aspx
--   E-invoicing Regulation, published 4 December 2020 (Zakat, Tax and Customs Authority)
--     https://zatca.gov.sa/en/E-Invoicing/Introduction/LawsAndRegulations/Documents/E-invoicing-Regulations.pdf
--   Controls, Requirements, Technical Specifications and Procedural Rules for Implementing the Provisions of the E-Invoicing Regulation, Governor's Decision No. (62738) dated 23/11/1443H, version published 19 May 2023 (Zakat, Tax and Customs Authority)
--     https://zatca.gov.sa/en/E-Invoicing/Introduction/LawsAndRegulations/Documents/20230519_E-Invoicing%20Implementation%20Resolution%20English.pdf
--   Electronic Invoice XML Implementation Standard, Version 1.2, 19/05/2023 — the UBL 2.1 subset a Saudi electronic invoice is written in, with the VAT category codes and the VATEX-SA reason codes in Arabic and English (Zakat, Tax and Customs Authority)
--     https://zatca.gov.sa/ar/E-Invoicing/SystemsDevelopers/Documents/20230519_ZATCA_Electronic_Invoice_XML_Implementation_Standard_%20vF.pdf
--   E-Invoicing Roll-out phases — the Generation phase and the waves of the Integration phase (Zakat, Tax and Customs Authority)
--     https://zatca.gov.sa/en/E-Invoicing/Introduction/Pages/Roll-out-phases.aspx
--   Real Estate Transaction Tax Law, Royal Decree No. M/84 dated 19/03/1446H, in force since 12 Shawwal 1446H corresponding to 10 April 2025 (Zakat, Tax and Customs Authority)
--     https://zatca.gov.sa/en/RulesRegulations/Taxes/Pages/RETTRegulation.aspx
--   Overview of the professional standards endorsed by the Saudi Organization for Chartered and Professional Accountants — IFRS Accounting Standards, and the IFRS for SMEs Accounting Standard for small and medium-sized entities (Saudi Organization for Chartered and Professional Accountants (SOCPA))
--     https://socpa.org.sa/Socpa/Professional-standards/Overview-of-standards.aspx?lang=en-us
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('SA', 'Saudi Arabia', '0.1.0', date '2026-09-22', '20260917170000', 'community', null, null, 'c5c059d0e61927340674660cb97ad2b8c1c903be175991f42327b9f39cf3ec20', '[{"key":"vat-agreement","title":"Common VAT Agreement of the States of the Gulf Cooperation Council (GCC), signed 27/2/1438H corresponding to 27 November 2016, ratified for the Kingdom by Royal Decree No. M/51 dated 3 Jumada I 1438H","publisher":"Gulf Cooperation Council, published by the Zakat, Tax and Customs Authority","url":"https://zatca.gov.sa/ar/RulesRegulations/Taxes/Documents/GCC%20VAT%20Agreement.pdf","consulted_on":"2026-09-22","kind":"law"},{"key":"vat-law","title":"نظام ضريبة القيمة المضافة — the Value Added Tax Law, Royal Decree No. M/113 dated 2 Dhul Qa''dah 1438H, as amended by Royal Decree No. M/52 dated 28 Rabi II 1441H and Royal Order No. A/638 dated 15 Shawwal 1441H (consolidated Arabic text)","publisher":"Zakat, Tax and Customs Authority","url":"https://zatca.gov.sa/ar/RulesRegulations/Taxes/Documents/%D9%86%D8%B8%D8%A7%D9%85%20%D8%B6%D8%B1%D9%8A%D8%A8%D8%A9%20%D8%A7%D9%84%D9%82%D9%8A%D9%85%D8%A9%20%D8%A7%D9%84%D9%85%D8%B6%D8%A7%D9%81%D8%A9%20(2).pdf","consulted_on":"2026-09-22","kind":"law"},{"key":"vat-ir","title":"Implementing Regulations of the Value Added Tax Law, Board Resolution No. (3839) dated 14/12/1438H, as amended — eighth edition, 04/04/1443H corresponding to 09/11/2021 (ZATCA English translation)","publisher":"Zakat, Tax and Customs Authority","url":"https://zatca.gov.sa/en/RulesRegulations/Taxes/Documents/Implmenting%20Regulations%20of%20the%20VAT%20Law_EN.pdf","consulted_on":"2026-09-22","kind":"regulation"},{"key":"vat-ir-ar","title":"اللائحة التنفيذية لنظام ضريبة القيمة المضافة — the Implementing Regulations in the official Arabic the English translation defers to, tenth edition, Shawwal 1446H corresponding to April 2025","publisher":"Zakat, Tax and Customs Authority","url":"https://zatca.gov.sa/ar/RulesRegulations/Taxes/Documents/Implmenting%20Regulations%20of%20the%20VAT%20Law.pdf","consulted_on":"2026-09-22","kind":"regulation"},{"key":"vat-ir-amendments","title":"Guideline for Amendments to the Implementing Regulation of Value Added Tax (VAT), issued by ZATCA''s Board of Directors Resolution No. (01-06-24) dated November 19, 2024 — Issue 1, April 2025","publisher":"Zakat, Tax and Customs Authority","url":"https://zatca.gov.sa/en/HelpCenter/guidelines/Documents/Amendments-to-the-Implementing-Regulation-of-(VAT).PDF","consulted_on":"2026-09-22","kind":"guidance"},{"key":"imports-exports-guideline","title":"Guideline on Imports and Exports under VAT Provisions, second edition, May 2026","publisher":"Zakat, Tax and Customs Authority","url":"https://zatca.gov.sa/en/HelpCenter/guidelines/Documents/Guideline-on-Imports-and-Exports-under-VAT-Provision.pdf","consulted_on":"2026-09-22","kind":"guidance"},{"key":"filing-guideline","title":"الدليل المبسط لتقديم إقرار ضريبة القيمة المضافة — the simplified guideline to filing a VAT return, which reproduces the return''s own sales screen with its fields numbered","publisher":"Zakat, Tax and Customs Authority","url":"https://zatca.gov.sa/ar/HelpCenter/guidelines/Documents/Simplified_VAT_Filing_Guidelines.pdf","consulted_on":"2026-09-22","kind":"guidance"},{"key":"vat-return-manual","title":"User Guide — Submit VAT Return Service","publisher":"Zakat, Tax and Customs Authority","url":"https://zatca.gov.sa/en/eServices/Documents/eServices_Manual_009.pdf","consulted_on":"2026-09-22","kind":"form"},{"key":"vat-return-service","title":"Submit VAT Return — the e-service a return is filed on","publisher":"Zakat, Tax and Customs Authority","url":"https://zatca.gov.sa/en/eServices/Pages/eServices-009.aspx","consulted_on":"2026-09-22","kind":"portal"},{"key":"registration-service","title":"Register in Value Added Tax — the e-service, which states the mandatory and voluntary registration thresholds","publisher":"Zakat, Tax and Customs Authority","url":"https://zatca.gov.sa/en/eServices/Pages/eServices_002.aspx","consulted_on":"2026-09-22","kind":"portal"},{"key":"einvoicing-regulation","title":"E-invoicing Regulation, published 4 December 2020","publisher":"Zakat, Tax and Customs Authority","url":"https://zatca.gov.sa/en/E-Invoicing/Introduction/LawsAndRegulations/Documents/E-invoicing-Regulations.pdf","consulted_on":"2026-09-22","kind":"regulation"},{"key":"einvoicing-resolution","title":"Controls, Requirements, Technical Specifications and Procedural Rules for Implementing the Provisions of the E-Invoicing Regulation, Governor''s Decision No. (62738) dated 23/11/1443H, version published 19 May 2023","publisher":"Zakat, Tax and Customs Authority","url":"https://zatca.gov.sa/en/E-Invoicing/Introduction/LawsAndRegulations/Documents/20230519_E-Invoicing%20Implementation%20Resolution%20English.pdf","consulted_on":"2026-09-22","kind":"regulation"},{"key":"einvoicing-xml","title":"Electronic Invoice XML Implementation Standard, Version 1.2, 19/05/2023 — the UBL 2.1 subset a Saudi electronic invoice is written in, with the VAT category codes and the VATEX-SA reason codes in Arabic and English","publisher":"Zakat, Tax and Customs Authority","url":"https://zatca.gov.sa/ar/E-Invoicing/SystemsDevelopers/Documents/20230519_ZATCA_Electronic_Invoice_XML_Implementation_Standard_%20vF.pdf","consulted_on":"2026-09-22","kind":"standard"},{"key":"einvoicing-phases","title":"E-Invoicing Roll-out phases — the Generation phase and the waves of the Integration phase","publisher":"Zakat, Tax and Customs Authority","url":"https://zatca.gov.sa/en/E-Invoicing/Introduction/Pages/Roll-out-phases.aspx","consulted_on":"2026-09-22","kind":"portal"},{"key":"rett","title":"Real Estate Transaction Tax Law, Royal Decree No. M/84 dated 19/03/1446H, in force since 12 Shawwal 1446H corresponding to 10 April 2025","publisher":"Zakat, Tax and Customs Authority","url":"https://zatca.gov.sa/en/RulesRegulations/Taxes/Pages/RETTRegulation.aspx","consulted_on":"2026-09-22","kind":"regulation"},{"key":"socpa-standards","title":"Overview of the professional standards endorsed by the Saudi Organization for Chartered and Professional Accountants — IFRS Accounting Standards, and the IFRS for SMEs Accounting Standard for small and medium-sized entities","publisher":"Saudi Organization for Chartered and Professional Accountants (SOCPA)","url":"https://socpa.org.sa/Socpa/Professional-standards/Overview-of-standards.aspx?lang=en-us","consulted_on":"2026-09-22","kind":"standard"}]'::jsonb)
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
  ('SA', 'default', 'Saudi Arabia reference chart of accounts', '{}'::jsonb, true, 'companies', array['SA-IFRSSME-IS', 'SA-IFRSSME-SFP']::text[], null, 'There is no legal chart of accounts in the Kingdom, as far as this pack''s research could establish: neither the Zakat, Tax and Customs Authority nor the Saudi Organization for Chartered and Professional Accountants publishes one, and a search of both sites found no text prescribing a numbering of accounts. What is prescribed is the framework — SOCPA endorses the IFRS Accounting Standards, and the IFRS for SMEs Accounting Standard for a small or medium-sized entity, and issues standards of its own where IFRS does not reach, zakat being the named case. This is an absence of evidence and not a citable denial, which is why it is written out here rather than behind an article number. The chart itself is this pack''s own: four digits, blocked so that each range reaches one line item of the statement of financial position and of the income statement below, carrying the accounts a Saudi company actually keeps — VAT input and output tax, the amount payable to and refundable by ZATCA, import VAT paid at Customs, withholding tax payable and suffered, GOSI contributions, an end-of-service benefits provision, and zakat apart from income tax. The statutory reserve of EQ.2 is the share of the annual net profit the Companies Law asks a Saudi company to set aside; this pack''s research did not open the article of the Companies Law (Royal Decree No. M/132 of 1443H) that fixes it, and a reviewer should check that before the line is trusted.', 'socpa-standards')
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
  ('SA', 'default', '1000', 'Petty cash', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('SA', 'default', '1010', 'Current account — SAR', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('SA', 'default', '1020', 'Term deposits placed for three months or less', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('SA', 'default', '1030', 'Foreign currency account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('SA', 'default', '1040', 'Cash in transit — card and payment gateway settlements', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('SA', 'default', '1050', 'Murabaha and money market placements — three months or less', '{}'::jsonb, 'asset_cash', false, null, 60),
  ('SA', 'default', '1100', 'Trade receivables', '{}'::jsonb, 'asset_receivable', true, null, 70),
  ('SA', 'default', '1110', 'Trade receivables — allowance for expected credit losses', '{}'::jsonb, 'asset_current', false, null, 80),
  ('SA', 'default', '1120', 'Other receivables', '{}'::jsonb, 'asset_current', true, null, 90),
  ('SA', 'default', '1130', 'Amounts due from related parties', '{}'::jsonb, 'asset_current', false, null, 100),
  ('SA', 'default', '1140', 'Deposits and retentions paid', '{}'::jsonb, 'asset_current', false, null, 110),
  ('SA', 'default', '1150', 'VAT input tax', '{}'::jsonb, 'asset_current', false, null, 120),
  ('SA', 'default', '1155', 'VAT refundable by ZATCA — net of a filed return', '{}'::jsonb, 'asset_current', true, null, 130),
  ('SA', 'default', '1157', 'Withholding tax suffered on own receipts — certificates held', '{}'::jsonb, 'asset_current', false, null, 140),
  ('SA', 'default', '1160', 'Advances to employees', '{}'::jsonb, 'asset_current', false, null, 150),
  ('SA', 'default', '1200', 'Inventories — goods for resale', '{}'::jsonb, 'asset_current', false, null, 170),
  ('SA', 'default', '1210', 'Inventories — raw materials', '{}'::jsonb, 'asset_current', false, null, 180),
  ('SA', 'default', '1220', 'Inventories — work in progress', '{}'::jsonb, 'asset_current', false, null, 190),
  ('SA', 'default', '1230', 'Inventories — finished goods', '{}'::jsonb, 'asset_current', false, null, 200),
  ('SA', 'default', '1300', 'Short-term investments', '{}'::jsonb, 'asset_current', false, null, 210),
  ('SA', 'default', '1350', 'Zakat and income tax recoverable', '{}'::jsonb, 'asset_current', false, null, 220),
  ('SA', 'default', '1400', 'Prepayments', '{}'::jsonb, 'asset_prepayments', false, null, 230),
  ('SA', 'default', '1410', 'Accrued income', '{}'::jsonb, 'asset_prepayments', false, null, 240),
  ('SA', 'default', '1420', 'Prepaid rent', '{}'::jsonb, 'asset_prepayments', false, null, 250),
  ('SA', 'default', '1430', 'Prepaid insurance', '{}'::jsonb, 'asset_prepayments', false, null, 260),
  ('SA', 'default', '1600', 'Land and buildings — cost', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('SA', 'default', '1601', 'Land and buildings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('SA', 'default', '1610', 'Leasehold improvements — cost', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('SA', 'default', '1611', 'Leasehold improvements — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('SA', 'default', '1620', 'Plant and machinery — cost', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('SA', 'default', '1621', 'Plant and machinery — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('SA', 'default', '1630', 'Office equipment and computers — cost', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('SA', 'default', '1631', 'Office equipment and computers — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('SA', 'default', '1632', 'Furniture and fixtures — cost', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('SA', 'default', '1633', 'Furniture and fixtures — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('SA', 'default', '1640', 'Motor vehicles — cost', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('SA', 'default', '1641', 'Motor vehicles — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 380),
  ('SA', 'default', '1650', 'Capital work in progress', '{}'::jsonb, 'asset_fixed', false, null, 390),
  ('SA', 'default', '1690', 'Right-of-use assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 400),
  ('SA', 'default', '1691', 'Right-of-use assets — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 410),
  ('SA', 'default', '1700', 'Investments in related parties', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('SA', 'default', '1710', 'Long-term deposits and retentions held', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('SA', 'default', '1730', 'Goodwill', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('SA', 'default', '1750', 'Intangible assets — cost', '{}'::jsonb, 'asset_non_current', false, null, 450),
  ('SA', 'default', '1751', 'Intangible assets — accumulated amortisation', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('SA', 'default', '2000', 'Trade payables', '{}'::jsonb, 'liability_payable', true, null, 470),
  ('SA', 'default', '2010', 'Other payables and accruals', '{}'::jsonb, 'liability_current', false, null, 480),
  ('SA', 'default', '2020', 'Amounts due to related parties', '{}'::jsonb, 'liability_current', false, null, 490),
  ('SA', 'default', '2030', 'Amounts due to partners and shareholders', '{}'::jsonb, 'liability_current', false, null, 500),
  ('SA', 'default', '2040', 'Deposits and retentions received', '{}'::jsonb, 'liability_current', false, null, 510),
  ('SA', 'default', '2045', 'Deferred revenue and advances from customers', '{}'::jsonb, 'liability_current', false, null, 520),
  ('SA', 'default', '2050', 'Wages and salaries payable', '{}'::jsonb, 'liability_current', false, null, 530),
  ('SA', 'default', '2055', 'GOSI contributions payable', '{}'::jsonb, 'liability_current', false, null, 540),
  ('SA', 'default', '2100', 'VAT output tax', '{}'::jsonb, 'liability_current', false, null, 550),
  ('SA', 'default', '2105', 'Import VAT payable to Saudi Customs', '{}'::jsonb, 'liability_current', false, null, 555),
  ('SA', 'default', '2110', 'VAT payable to ZATCA — net of a filed return', '{}'::jsonb, 'liability_current', true, null, 560),
  ('SA', 'default', '2120', 'Withholding tax payable to ZATCA', '{}'::jsonb, 'liability_current', false, null, 570),
  ('SA', 'default', '2130', 'Zakat payable', '{}'::jsonb, 'liability_current', false, null, 580),
  ('SA', 'default', '2135', 'Income tax payable', '{}'::jsonb, 'liability_current', false, null, 590),
  ('SA', 'default', '2150', 'End-of-service benefits — current portion', '{}'::jsonb, 'liability_current', false, null, 600),
  ('SA', 'default', '2200', 'Short-term financing and bank overdraft', '{}'::jsonb, 'liability_current', false, null, 610),
  ('SA', 'default', '2210', 'Current portion of long-term financing', '{}'::jsonb, 'liability_current', false, null, 620),
  ('SA', 'default', '2300', 'Long-term financing', '{}'::jsonb, 'liability_non_current', false, null, 630),
  ('SA', 'default', '2320', 'Provision for onerous contracts', '{}'::jsonb, 'liability_non_current', false, null, 640),
  ('SA', 'default', '2350', 'End-of-service benefits provision — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 650),
  ('SA', 'default', '2990', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 660),
  ('SA', 'default', '3000', 'Share capital', '{}'::jsonb, 'equity', false, null, 670),
  ('SA', 'default', '3010', 'Statutory reserve', '{}'::jsonb, 'equity', false, null, 680),
  ('SA', 'default', '3020', 'Other reserves', '{}'::jsonb, 'equity', false, null, 690),
  ('SA', 'default', '3030', 'Foreign currency translation reserve', '{}'::jsonb, 'equity', false, null, 700),
  ('SA', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 710),
  ('SA', 'default', '3210', 'Dividends paid', '{}'::jsonb, 'equity_retained', false, null, 720),
  ('SA', 'default', '4000', 'Sales of goods', '{}'::jsonb, 'income', false, null, 730),
  ('SA', 'default', '4010', 'Sales of services', '{}'::jsonb, 'income', false, null, 740),
  ('SA', 'default', '4020', 'Sales — export of goods', '{}'::jsonb, 'income', false, null, 750),
  ('SA', 'default', '4030', 'Sales — export of services', '{}'::jsonb, 'income', false, null, 760),
  ('SA', 'default', '4040', 'Rental income', '{}'::jsonb, 'income', false, null, 770),
  ('SA', 'default', '4700', 'Realised foreign exchange gain', '{}'::jsonb, 'income_other', false, null, 780),
  ('SA', 'default', '4710', 'Unrealised foreign exchange gain', '{}'::jsonb, 'income_other', false, null, 790),
  ('SA', 'default', '4750', 'Gain on disposal of fixed assets', '{}'::jsonb, 'income_other', false, null, 800),
  ('SA', 'default', '4790', 'Other income', '{}'::jsonb, 'income_other', false, null, 810),
  ('SA', 'default', '5000', 'Cost of goods sold', '{}'::jsonb, 'expense_direct_cost', false, null, 820),
  ('SA', 'default', '5010', 'Freight and customs clearance', '{}'::jsonb, 'expense_direct_cost', false, null, 830),
  ('SA', 'default', '5020', 'Subcontractor costs', '{}'::jsonb, 'expense_direct_cost', false, null, 840),
  ('SA', 'default', '5030', 'Purchase returns and allowances', '{}'::jsonb, 'expense_direct_cost', false, null, 850),
  ('SA', 'default', '6100', 'Salaries and wages', '{}'::jsonb, 'expense', false, null, 860),
  ('SA', 'default', '6110', 'End-of-service benefits charge for the year', '{}'::jsonb, 'expense', false, null, 870),
  ('SA', 'default', '6120', 'GOSI employer contributions', '{}'::jsonb, 'expense', false, null, 880),
  ('SA', 'default', '6125', 'Employee medical insurance', '{}'::jsonb, 'expense', false, null, 890),
  ('SA', 'default', '6130', 'Other staff costs', '{}'::jsonb, 'expense', false, null, 900),
  ('SA', 'default', '6140', 'Recruitment and work permit charges', '{}'::jsonb, 'expense', false, null, 910),
  ('SA', 'default', '6200', 'Rent', '{}'::jsonb, 'expense', false, null, 920),
  ('SA', 'default', '6210', 'Utilities', '{}'::jsonb, 'expense', false, null, 930),
  ('SA', 'default', '6220', 'Office supplies', '{}'::jsonb, 'expense', false, null, 940),
  ('SA', 'default', '6230', 'IT and software', '{}'::jsonb, 'expense', false, null, 950),
  ('SA', 'default', '6240', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 960),
  ('SA', 'default', '6300', 'Travel', '{}'::jsonb, 'expense', false, null, 970),
  ('SA', 'default', '6310', 'Entertainment and hospitality — input tax blocked', '{}'::jsonb, 'expense', false, null, 980),
  ('SA', 'default', '6320', 'Motor vehicle running costs', '{}'::jsonb, 'expense', false, null, 990),
  ('SA', 'default', '6400', 'Professional fees', '{}'::jsonb, 'expense', false, null, 1000),
  ('SA', 'default', '6410', 'Bank and financing charges', '{}'::jsonb, 'expense', false, null, 1010),
  ('SA', 'default', '6420', 'Insurance', '{}'::jsonb, 'expense', false, null, 1020),
  ('SA', 'default', '6430', 'Marketing and advertising', '{}'::jsonb, 'expense', false, null, 1030),
  ('SA', 'default', '6435', 'Subscriptions and memberships', '{}'::jsonb, 'expense', false, null, 1040),
  ('SA', 'default', '6440', 'Government fees and licences', '{}'::jsonb, 'expense', false, null, 1050),
  ('SA', 'default', '6500', 'Depreciation charge', '{}'::jsonb, 'expense_depreciation', false, null, 1060),
  ('SA', 'default', '6510', 'Amortisation charge', '{}'::jsonb, 'expense_depreciation', false, null, 1070),
  ('SA', 'default', '6950', 'Realised foreign exchange loss', '{}'::jsonb, 'expense', false, null, 1080),
  ('SA', 'default', '6955', 'Unrealised foreign exchange loss', '{}'::jsonb, 'expense', false, null, 1090),
  ('SA', 'default', '6960', 'Loss on disposal of fixed assets', '{}'::jsonb, 'expense', false, null, 1100),
  ('SA', 'default', '6990', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1110),
  ('SA', 'default', '7100', 'Finance costs on borrowings and financing arrangements', '{}'::jsonb, 'expense', false, null, 1120),
  ('SA', 'default', '7110', 'Facility arrangement and guarantee fees', '{}'::jsonb, 'expense', false, null, 1130),
  ('SA', 'default', '8000', 'Zakat charge for the year', '{}'::jsonb, 'expense', false, null, 1140),
  ('SA', 'default', '8010', 'Income tax charge for the year', '{}'::jsonb, 'expense', false, null, 1150)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('SA', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('SA', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('SA', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('SA', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('SA', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('SA', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('SA', 'SA-P-BL-CAR', 'Purchase, standard-rated, restricted motor vehicle — input tax blocked', '{}'::jsonb, 'The purchase or lease of a road vehicle available for private use, and its repair, maintenance and fuel.', 'percent', 15, 'purchase', 'domestic', date '2020-07-01', null, 'Implementing Regulations, Article 50(1)(c) to (e): the purchase or lease of a Restricted Motor Vehicle, services on one, and its fuel. Article 50(2) defines a Restricted Motor Vehicle as "any vehicle designed to be used on the road unless the vehicle is either used exclusively by the Taxable Person or by its employees for work purposes, without being made available for any private use", or is held for resale or for a vehicle-supplying business; the 2024 amendment states the ten-seat limit and adds emergency vehicles and heavy machinery to the exceptions. The tax lands on the account of the line it taxes and on no field of the return.', 'S', null, 130, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'vat-ir', null, null, null, null),
  ('SA', 'SA-P-BL-ENT', 'Purchase, standard-rated, entertainment or catering — input tax blocked', '{}'::jsonb, 'Entertainment, sporting or cultural services, and catering in hotels, restaurants and similar venues, which Article 50 treats as received outside the economic activity.', 'percent', 15, 'purchase', 'domestic', date '2020-07-01', null, 'Implementing Regulations, Article 50(1)(a) and (b): expenditure on "any form of entertainment, sporting or cultural services" and on "catering services in hotels, restaurants and similar venues" is not incurred in the course of the economic activity, "and consequently the Taxable Person will not be permitted to deduct the Input Tax relating to such expenditure", unless it is supplied onwards as a taxable supply (Article 50(4)). Board Resolution No. (01-06-24) of 19 November 2024 added one exception ZATCA states in its own guideline — catering "unless the taxable person is legally obligated to provide such services to employees at the workplace under applicable Kingdom regulations" — which this tax does not model, because whether an employer is so obliged is a fact about the employer and not about the invoice. The tax lands on the account of the line it taxes rather than on 1150, and on no field of the return: the filing guideline lists catering, cars and their fuel among the purchases that may not go in field 7.', 'S', null, 120, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'vat-ir-amendments', null, null, null, null),
  ('SA', 'SA-P-EX', 'Purchase, exempt', '{}'::jsonb, 'A purchase of an exempt supply — a residential lease, a financial service on an implicit margin, a transfer of real estate.', 'percent', 0, 'purchase', 'exempt', date '2020-07-01', null, 'Implementing Regulations, Articles 29 and 30. An exempt purchase carries no input tax at all and is reported in field 11, the exempt purchases line.', 'E', null, 150, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-ir', null, null, null, null),
  ('SA', 'SA-P-IMP', 'Purchase, import of goods, VAT paid to Customs on entry', '{}'::jsonb, 'Goods imported into the Kingdom on which Saudi Customs collected the tax at the border, the ordinary case.', 'percent', 15, 'purchase', 'import', date '2020-07-01', null, 'Implementing Regulations, Article 43(3): "The Tax due on the Import of Goods shall be payable on the Import date; Saudi Customs shall be responsible for collecting such Tax as per Customs'' procedures", the importer having given Customs its Tax Identification Number (Article 43(1)) and receiving a monthly statement of the value imported and the tax collected (Article 43(2)). Reported in field 8, which the guideline on imports and exports calls the field "which includes VAT paid to ZATCA"; the tax is deductible under Article 49(1) and the field''s tax column is what carries it. The tax is not owed to the supplier, so it is not credited to the supplier''s account: it lands on 2105, the amount owed to Saudi Customs, which the customs payment settles.', null, null, 170, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'imports-exports-guideline', null, null, null, null),
  ('SA', 'SA-P-IMP-RC', 'Purchase, import of goods, tax paid through the return', '{}'::jsonb, 'Goods imported by a taxable person ZATCA has authorised to pay import tax through its own return instead of at the border.', 'percent', 15, 'purchase', 'import', date '2020-07-01', null, 'Implementing Regulations, Article 44(1): "A Taxable Person may apply for authorization for the payment of Tax on imports to be made through that Taxable Person''s Tax Return, instead of being collected by the Customs Department on importation entry", granted only to an importer on a monthly tax period importing at least monthly, with twelve months of returns and payments on time and evidence of continuing financial stability (Article 44(2)). The guideline on imports and exports states where it lands: "If the application is approved, VAT shall be included in Field 9 of the VAT return instead of Field 8". Field 9 carries the tax due and the deduction of it at once, which is why its tax column comes to nothing here — see the field''s own note.', null, null, 180, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'imports-exports-guideline', null, null, null, null),
  ('SA', 'SA-P-NR', 'Purchase, supplier not registered for VAT', '{}'::jsonb, 'A purchase from a supplier established in the Kingdom who is below the registration threshold, so no tax was charged and none may be deducted.', 'percent', 0, 'purchase', 'not_subject', date '2020-07-01', null, 'No tax is charged because the supplier is not a Taxable Person: registration is mandatory above annual supplies of SAR 375,000 and optional above SAR 187,500, the thresholds ZATCA states on its registration service and which Articles 3 and 7 of the Implementing Regulations take from Articles 50(2) and 51(3) of the Common VAT Agreement. The filing guideline is explicit that a purchase whose tax the taxable person cannot evidence with a tax invoice does not go in field 7. Not reported on any field.', 'O', null, 160, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'registration-service', null, null, null, null),
  ('SA', 'SA-P-RC-SVC', 'Purchase, services received from a non-resident, reverse charge', '{}'::jsonb, 'A taxable service received from a supplier with no place of residence in the Kingdom, the customer accounting for the tax itself.', 'percent', 15, 'purchase', 'foreign_services_received', date '2020-07-01', null, 'Implementing Regulations, Article 47(1): where the Agreement makes a Taxable Customer liable for tax on a supply received from a Nonresident Supplier, "Tax shall be paid by way of the Reverse Charge Mechanism. The Taxable Customer must report the Output Tax on the Supply and any Input Tax (to the extent that the Customer can benefit from Input VAT deduction) in the Tax Return for that Tax Period." The guideline on imports and exports adds where: "VAT accounted for under the Reverse Charge Mechanism shall be reported in Field 9 of the Tax Return, whereby the Tax Return form automatically treats the Input Tax as deductible on the supply", and that the reverse charge reaches only services taxable by nature — the receipt of an exempt service from a non-resident, a loan for instance, is not reported at all. The supplier issues no tax invoice for it (Governor''s Decision No. 62738 excludes a reverse-charge supply from electronic invoicing), and the Authority accepts the commercial invoice as evidence.', null, null, 190, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'imports-exports-guideline', null, null, null, null),
  ('SA', 'SA-P-SR', 'Purchase, standard-rated, input tax deductible', '{}'::jsonb, 'A standard-rated purchase received in the course of an economic activity and used to make taxable supplies, whose input tax is deductible in full.', 'percent', 15, 'purchase', 'domestic', date '2020-07-01', null, 'Implementing Regulations, Article 49(1): a Taxable Person may deduct input tax on goods and services "received in the course of carrying on an Economic Activity" and constituting taxable supplies, internal supplies, or supplies that would have been taxable had they been made in the Kingdom. Article 53 is what makes the deduction provable: the tax invoice. Reported in field 7, the standard-rated purchases line, with its tax in the same field''s tax column.', 'S', null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-ir', null, null, null, null),
  ('SA', 'SA-P-ZR', 'Purchase, zero-rated', '{}'::jsonb, 'A zero-rated purchase from a supplier in the Kingdom — qualifying medicines, investment metals, international transport.', 'percent', 0, 'purchase', 'domestic', date '2020-07-01', null, 'Chapter Six of the Implementing Regulations rates the supply at zero in the supplier''s hands, so there is no input tax to deduct and the value is reported in field 10, the zero-rated purchases line of the return. Article 49(1)(a) counts a zero-rated supply among those whose input tax would be deductible, which is why a zero-rated purchase is a purchase of the return and not an absence of one.', 'Z', null, 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-ir', null, null, null, null),
  ('SA', 'SA-S-EX-FIN', 'Sale, exempt, financial services on an implicit margin', '{}'::jsonb, 'A financial service of Article 29 — dealing in money, credit, an account, a financial instrument, a life insurance contract — supplied for an implicit margin rather than an explicit fee.', 'percent', 0, 'sale', 'exempt', date '2020-07-01', null, 'Implementing Regulations, Article 29(1): "Supplies of Financial Services listed within this Article are exempt from VAT, except in cases where the Consideration payable in respect of the service is by way of an explicit fee, commission or commercial discount" — so the same service is standard-rated the moment it is charged for openly. Article 29(3) puts Shari''ah-compliant products on the footing of the conventional product they achieve the same result as, and Article 29(5) gives the worked list: interest or lending fees on an implicit margin, including under a diminishing musharaka or a murabaha contract, and commissions on an implicit spread under a mudaraba or wakala contract. Article 29(7) and (8) exempt life insurance and takaful. Reported in field 5, which the filing guideline glosses "الخدمات المالية والتوريدات العقارية". ZATCA''s XML standard codes it VATEX-SA-29 in category E.', 'E', null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-ir', null, null, null, null),
  ('SA', 'SA-S-EX-REALESTATE', 'Sale, exempt, transfer of ownership of real estate', '{}'::jsonb, 'The supply of real estate — commercial, residential, agricultural, developed or bare land — by a transfer of ownership or of the right to dispose of it as owner. Outside VAT and inside the Real Estate Transaction Tax instead.', 'percent', 0, 'sale', 'exempt', date '2020-10-04', null, 'Implementing Regulations, Article 30(1)(a), as amended by Board Resolution No. (1-5-20) dated 14/02/1442H: "The Supply of real estate, whether commercial, residential or agricultural real estate or developed or undeveloped bare land, through a transfer of ownership or transfer of the right to dispose of the same as an owner" is exempt from VAT. The exemption is not a relief: the same transaction bears the Real Estate Transaction Tax at 5 %, now the Law of Royal Decree No. M/84 dated 19/03/1446H, in force since 10 April 2025. **This pack carries no RETT tax code**: it is a tax on a transaction between parties, declared and paid on its own ZATCA service and not on the VAT return, and nothing of it would land on a box of this form. `valid_from` is the day the amendment took effect, 14/02/1442H corresponding to 4 October 2020; before it, a supply of real estate was standard-rated. Reported in field 5; ZATCA''s XML standard codes it VATEX-SA-30 in category E.', 'E', null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-ir', null, null, null, null),
  ('SA', 'SA-S-EX-RESI', 'Sale, exempt, lease or licence of residential real estate', '{}'::jsonb, 'The supply of residential real estate through lease or licence — a permanent dwelling designed for human occupation, hotels and other temporary accommodation excepted.', 'percent', 0, 'sale', 'exempt', date '2020-07-01', null, 'Implementing Regulations, Article 30(1)(b): "The Supply of residential real estate through lease or license" is exempt. Article 30(2) defines Residential Real Estate as a permanent dwelling designed for human occupation, houses, flats and apartments among them, and student or pupil accommodation intended as a primary residence; Article 30(3) excludes "any hotels, inns, guest houses, motels, serviced accommodation or any other building that is designed to offer temporary accommodation to visitors or travelers", which are standard-rated. Reported in field 5; ZATCA''s XML standard codes a real estate exemption VATEX-SA-30 in category E.', 'E', null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-ir', null, null, null, null),
  ('SA', 'SA-S-OS', 'Sale, outside the scope of VAT', '{}'::jsonb, 'A supply whose place of supply is outside the Kingdom under Chapter Four of the Regulations, or the transfer of an economic activity that Article 17 excepts from being a supply at all.', 'percent', 0, 'sale', 'not_subject', date '2020-07-01', null, 'Implementing Regulations, Article 17 (transfer of an economic activity, which "shall not be considered a Supply") and Articles 22 to 28 (the place of supply). Not reported on any field of the return: the return is a statement of supplies made in the Kingdom. ZATCA''s XML standard carries category O for it with reason code VATEX-SA-OOS, whose text is "free text, to be provided by the taxpayer on case to case basis" — a reason the seller writes, not one this pack can hold.', 'O', null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-ir', null, null, null, null),
  ('SA', 'SA-S-SR', 'Sale, standard-rated, VAT 15%', '{}'::jsonb, 'A taxable supply made in the Kingdom that is neither zero-rated nor exempt.', 'percent', 15, 'sale', 'domestic', date '2020-07-01', null, 'VAT Law, Article 2(2): "تطبق الضريبة بنسبة أساسية قدرها (15%) من قيمة التوريد أو الاستيراد، ما لم يرد نص للإعفاء أو فرض نسبة الصفر" — Tax applies at a basic rate of 15 % of the value of the supply or of the import, unless a text grants an exemption or imposes the zero rate. The article was amended to 15 % by Royal Order No. A/638 dated 15/10/1441H, footnote (1) of the consolidated text; the rate was 5 % before, and Article 79(10) of the Implementing Regulations works out which supplies straddling 1 July 2020 take which rate, so `valid_from` is that day. Reported in field 1 of the return, whose sales side the filing guideline describes as "المبيعات الخاضعة للنسبة الأساسية (15%)". ZATCA''s Electronic Invoice XML Implementation Standard puts a standard-rated line in UNCL5305 category S with no exemption reason.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('SA', 'SA-S-ZR-EXP', 'Sale, zero-rated, export of goods from the Kingdom', '{}'::jsonb, 'An export of goods from the Kingdom to a place outside Council Territory, the supplier holding the customs, commercial and transport evidence.', 'percent', 0, 'sale', 'export', date '2020-07-01', null, 'Implementing Regulations, Article 32: the zero rate applies to "an Export of Goods from the Kingdom to a place outside of Council Territory" where "the Supplier of those Goods must retain evidence that the Goods have been transported from Council Territory within ninety (90) days of the Supply taking place" — customs export documentation, commercial documentation and transport documentation, each of them (Article 32(3)). Every other Member State of the Council is a place outside Council Territory today: Article 79(6) treats "any Member State which has not introduced VAT, or which does not have an Electronic Services System in place with the Kingdom" as a country outside it, and Article 79(8) leaves the day that system starts to an order of the Authority that this pack''s research found no trace of. Reported in field 4, which the filing guideline glosses "صادرات السلع من المملكة أو الخدمات المقدمة إلى عميل غير مقيم بالمملكة". **vat_category is deliberately empty**: ZATCA''s own XML standard puts an export of goods in UNCL5305 category Z with reason code VATEX-SA-32, and this format refuses anything but G on an export treatment. Rather than declare a category the Kingdom''s own administration contradicts, or a treatment that is not what this is, the pack leaves BT-151 unsaid — which it may, no brick writing a Saudi invoice. docs/international.md carries the point.', null, null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-ir', null, null, null, null),
  ('SA', 'SA-S-ZR-MED', 'Sale, zero-rated, qualifying medicines and medical goods', '{}'::jsonb, 'Medicines and medical goods classified as qualifying by the Ministry of Health or another competent authority.', 'percent', 0, 'sale', 'domestic', date '2020-07-01', null, 'Implementing Regulations, Article 35: "the Supply of any Qualifying Medicines or Qualifying Medical Goods is zero-rated", the classification being the one "issued by the Ministry of Health or any other competent authority from time to time" and subject to any further controls of the Council''s Ministers of Health Committee. The pack carries the rule and not the list, which is an administrative classification that changes without the Regulations changing. Reported in field 3; ZATCA''s XML standard codes it VATEX-SA-35 in category Z.', 'Z', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-ir', null, null, null, null),
  ('SA', 'SA-S-ZR-METAL', 'Sale, zero-rated, first supply of an investment metal', '{}'::jsonb, 'The first supply of gold, silver or platinum of at least 99 % purity, tradeable on the global bullion market, by its producer or refiner.', 'percent', 0, 'sale', 'domestic', date '2020-07-01', null, 'Implementing Regulations, Article 36(1): "The first Supply of a Qualifying Metal by its Producer or Refiner is zero-rated", a Qualifying Metal being gold, silver or platinum (Article 36(3)(a)) supplied for investment, that is "at a purity level of not less than ninety-nine percent (99%) and tradeable on the global bullion market" (Article 36(3)(b)). The zero rate is the **first** supply by the producer or the refiner, and a later trade in the same bar is not it — the narrower rule of the two the Council allows. Reported in field 3; ZATCA''s XML standard codes it VATEX-SA-36 in category Z.', 'Z', null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-ir', null, null, null, null),
  ('SA', 'SA-S-ZR-SVC', 'Sale, zero-rated, services supplied to a customer outside the Council', '{}'::jsonb, 'A supply of services to a customer with no place of residence in any Member State, none of the exclusions of Article 33(2) applying.', 'percent', 0, 'sale', 'export', date '2020-07-01', null, 'Implementing Regulations, Article 33(1): "a Supply of services made by a Taxable Person to a Customer without a Place of Residence in any Member State shall be zero-rated", subject to the four exclusions of Article 33(2) — a place of supply fixed in a Member State by Articles 17 to 21 of the Agreement, a customer resident in a Member State, a person benefiting directly from the service while in a Member State who cannot deduct the input tax in full, and a service performed on tangible goods located in a Member State. Paragraphs 2(c) and 2(d) were amended by Board Resolution No. (01-06-24) of 19 November 2024, and the wording carried here is the amended one as ZATCA''s own guideline states it. Reported in field 4. ZATCA''s XML standard files an export of services under category Z with reason code VATEX-SA-33; vat_category is left empty for the reason SA-S-ZR-EXP gives.', null, null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-ir-amendments', null, null, null, null),
  ('SA', 'SA-S-ZR-TRANSPORT', 'Sale, zero-rated, international transport of goods or passengers', '{}'::jsonb, 'International transport of goods or passengers to or from a place outside the Kingdom, and the services directly connected and incidental to it.', 'percent', 0, 'sale', 'domestic', date '2020-07-01', null, 'Implementing Regulations, Article 34(1) and (2): "The international transport of Goods is zero-rated"; the international transport of passengers is, by a qualifying means of transport or a scheduled flight or voyage. Article 34(7) defines international transport as carriage "to a place outside the Kingdom, or from a place outside the Kingdom into the Kingdom", and Article 34(8) a qualifying means of transport as one designed to carry at least ten people or goods commercially, used predominantly internationally. The treatment is domestic and not export: it is a supply made in the Kingdom that the Regulations rate at zero, and its customer is as often Saudi as not — reported in field 3, the zero-rated domestic line the filing guideline glosses with medicines, medical equipment and qualifying investment metals. ZATCA''s XML standard agrees on the category, Z, and codes it VATEX-SA-34-1 for goods and VATEX-SA-34-2 for passengers.', 'Z', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-ir', null, null, null, null)
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
    ('SA-P-BL-CAR', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('SA-P-BL-CAR', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('SA-P-BL-CAR', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('SA-P-BL-CAR', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('SA-P-BL-ENT', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('SA-P-BL-ENT', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('SA-P-BL-ENT', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('SA-P-BL-ENT', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('SA-P-EX', 'invoice', 'base', 100, null, '11', array['11']::text[], 100, 'SA-VAT-RETURN', 10),
    ('SA-P-EX', 'credit_note', 'base', 100, null, '11', array['11']::text[], -100, 'SA-VAT-RETURN', 10),
    ('SA-P-IMP', 'invoice', 'base', 100, null, '8', array['8']::text[], 100, 'SA-VAT-RETURN', 10),
    ('SA-P-IMP', 'invoice', 'tax', 100, '1150', '8', array['8']::text[], 100, 'SA-VAT-RETURN', 20),
    ('SA-P-IMP', 'invoice', 'tax', -100, '2105', null, null, 100, null, 30),
    ('SA-P-IMP', 'credit_note', 'base', 100, null, '8', array['8']::text[], -100, 'SA-VAT-RETURN', 10),
    ('SA-P-IMP', 'credit_note', 'tax', 100, '1150', '8', array['8']::text[], -100, 'SA-VAT-RETURN', 20),
    ('SA-P-IMP', 'credit_note', 'tax', -100, '2105', null, null, 100, null, 30),
    ('SA-P-IMP-RC', 'invoice', 'base', 100, null, '9', array['9']::text[], 100, 'SA-VAT-RETURN', 10),
    ('SA-P-IMP-RC', 'invoice', 'tax', 100, '1150', '9', array['9']::text[], -100, 'SA-VAT-RETURN', 20),
    ('SA-P-IMP-RC', 'invoice', 'tax', -100, '2100', '9', array['9']::text[], 100, 'SA-VAT-RETURN', 30),
    ('SA-P-IMP-RC', 'credit_note', 'base', 100, null, '9', array['9']::text[], -100, 'SA-VAT-RETURN', 10),
    ('SA-P-IMP-RC', 'credit_note', 'tax', 100, '1150', '9', array['9']::text[], 100, 'SA-VAT-RETURN', 20),
    ('SA-P-IMP-RC', 'credit_note', 'tax', -100, '2100', '9', array['9']::text[], -100, 'SA-VAT-RETURN', 30),
    ('SA-P-RC-SVC', 'invoice', 'base', 100, null, '9', array['9']::text[], 100, 'SA-VAT-RETURN', 10),
    ('SA-P-RC-SVC', 'invoice', 'tax', 100, '1150', '9', array['9']::text[], -100, 'SA-VAT-RETURN', 20),
    ('SA-P-RC-SVC', 'invoice', 'tax', -100, '2100', '9', array['9']::text[], 100, 'SA-VAT-RETURN', 30),
    ('SA-P-RC-SVC', 'credit_note', 'base', 100, null, '9', array['9']::text[], -100, 'SA-VAT-RETURN', 10),
    ('SA-P-RC-SVC', 'credit_note', 'tax', 100, '1150', '9', array['9']::text[], 100, 'SA-VAT-RETURN', 20),
    ('SA-P-RC-SVC', 'credit_note', 'tax', -100, '2100', '9', array['9']::text[], -100, 'SA-VAT-RETURN', 30),
    ('SA-P-SR', 'invoice', 'base', 100, null, '7', array['7']::text[], 100, 'SA-VAT-RETURN', 10),
    ('SA-P-SR', 'invoice', 'tax', 100, '1150', '7', array['7']::text[], 100, 'SA-VAT-RETURN', 20),
    ('SA-P-SR', 'credit_note', 'base', 100, null, '7', array['7']::text[], -100, 'SA-VAT-RETURN', 10),
    ('SA-P-SR', 'credit_note', 'tax', 100, '1150', '7', array['7']::text[], -100, 'SA-VAT-RETURN', 20),
    ('SA-P-ZR', 'invoice', 'base', 100, null, '10', array['10']::text[], 100, 'SA-VAT-RETURN', 10),
    ('SA-P-ZR', 'credit_note', 'base', 100, null, '10', array['10']::text[], -100, 'SA-VAT-RETURN', 10),
    ('SA-S-EX-FIN', 'invoice', 'base', 100, null, '5', array['5']::text[], 100, 'SA-VAT-RETURN', 10),
    ('SA-S-EX-FIN', 'credit_note', 'base', 100, null, '5', array['5']::text[], -100, 'SA-VAT-RETURN', 10),
    ('SA-S-EX-REALESTATE', 'invoice', 'base', 100, null, '5', array['5']::text[], 100, 'SA-VAT-RETURN', 10),
    ('SA-S-EX-REALESTATE', 'credit_note', 'base', 100, null, '5', array['5']::text[], -100, 'SA-VAT-RETURN', 10),
    ('SA-S-EX-RESI', 'invoice', 'base', 100, null, '5', array['5']::text[], 100, 'SA-VAT-RETURN', 10),
    ('SA-S-EX-RESI', 'credit_note', 'base', 100, null, '5', array['5']::text[], -100, 'SA-VAT-RETURN', 10),
    ('SA-S-SR', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'SA-VAT-RETURN', 10),
    ('SA-S-SR', 'invoice', 'tax', 100, '2100', '1', array['1']::text[], 100, 'SA-VAT-RETURN', 20),
    ('SA-S-SR', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'SA-VAT-RETURN', 10),
    ('SA-S-SR', 'credit_note', 'tax', 100, '2100', '1', array['1']::text[], -100, 'SA-VAT-RETURN', 20),
    ('SA-S-ZR-EXP', 'invoice', 'base', 100, null, '4', array['4']::text[], 100, 'SA-VAT-RETURN', 10),
    ('SA-S-ZR-EXP', 'credit_note', 'base', 100, null, '4', array['4']::text[], -100, 'SA-VAT-RETURN', 10),
    ('SA-S-ZR-MED', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'SA-VAT-RETURN', 10),
    ('SA-S-ZR-MED', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'SA-VAT-RETURN', 10),
    ('SA-S-ZR-METAL', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'SA-VAT-RETURN', 10),
    ('SA-S-ZR-METAL', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'SA-VAT-RETURN', 10),
    ('SA-S-ZR-SVC', 'invoice', 'base', 100, null, '4', array['4']::text[], 100, 'SA-VAT-RETURN', 10),
    ('SA-S-ZR-SVC', 'credit_note', 'base', 100, null, '4', array['4']::text[], -100, 'SA-VAT-RETURN', 10),
    ('SA-S-ZR-TRANSPORT', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'SA-VAT-RETURN', 10),
    ('SA-S-ZR-TRANSPORT', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'SA-VAT-RETURN', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'SA' and t.code = v.tax_code
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
  ('SA', 'SA-VAT-RETURN', 'VAT return', array['month', 'quarter']::declaration_period[], null, date '2018-01-01', null, 'Implementing Regulations, Article 58: "1- For Taxpayers whose annual value of Taxable Supplies exceeds forty million (40,000,000) SAR during the previous twelve months, the Tax Period shall be monthly. 2- For all other Taxpayers, the standard Tax Period shall be three months." A taxpayer under the threshold may ask for the monthly period (Article 58(3)), and one who has filed monthly for two years may ask to go back to three months if it is still under it (Article 58(5)). ZATCA states the same on its own Arabic VAT page — a business whose annual taxable supplies do not exceed 40 million riyals files quarterly, and above it monthly. **`period_default` is deliberately absent**: the cadence turns on the taxpayer''s own turnover and not on a rule that gives one answer to everybody, so `ekwo init` asks rather than this pack guessing. The return is a screen of the Authority''s portal and not a printed form: the official User Guide to the Submit VAT Return service shows it only as screenshots, so its field labels could not be read as text in this research pass. What could be read is the numbering — the simplified filing guideline reproduces the sales screen with its fields numbered 1 to 5 and glosses each, and the guideline on imports and exports names fields 8 and 9 in words. The names below are this pack''s own English, built on those glosses and on Article 62(2) of the Implementing Regulations, which lists what a return must disclose. A reviewer who files a real return should check the labels first.', true,'last_day_of_month_after_period'::filing_deadline_rule, null, null, 'Implementing Regulations, Article 62(1): the Tax Return "must be filed ... for each Tax Period with the Authority no later than the last day in the month following the end of the Tax Period to which the Tax Return relates." Article 59(1) sets the same day for payment: "Payment of Tax due by a Taxable Person in respect of a Tax Period must be made at the latest by the last day of the month following the end of that Tax Period." Article 74 moves an obligation falling due on a non-working day, which this rule does not express and a filer should know of.', 'vat-ir', null)
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
  ('SA', 'SA-VAT-RETURN', '1', 'base', 'Standard-rated sales', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Field 1 of the sales screen, "المبيعات الخاضعة للنسبة الأساسية (15%)" — sales taxed at the basic rate of 15 %, whatever their value and however they were collected, as the filing guideline puts it. The value is entered without tax and the portal works the tax out: "أدخل المشتريات غير شاملة للضريبة ... سيتم حساب مبلغ ضريبة القيمة المضافة تلقائيًا". Article 62(2)(a) of the Implementing Regulations is the obligation behind it.', 'filing-guideline'),
  ('SA', 'SA-VAT-RETURN', '1', 'tax', 'VAT on standard-rated sales', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The tax column of field 1, computed by the portal from the value beside it. Article 62(2)(a): "the total value of all Supplies ... subject to the basic rate and the zero-rate of Tax, and the total Output Tax on those Supplies".', 'vat-ir'),
  ('SA', 'SA-VAT-RETURN', '2', 'base', 'Private education and private healthcare supplied to citizens', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Field 2 of the sales screen, which the filing guideline glosses "مثل: الخدمات التعليمية الأهلية المقدمة للمواطنين والرعاية الصحية". **No tax of this pack posts here.** The line exists because the State bears the tax on private education and private healthcare supplied to Saudi citizens, and ZATCA''s XML standard shows how far the regime reaches into the invoice — reason codes VATEX-SA-EDU and VATEX-SA-HEA, with the buyer''s National ID made mandatory on the invoice (rule 5.3). What this pack''s research could not open is the instrument that grants it and the conditions on it, so the pack carries the field and no tax that posts to it rather than a rate it cannot cite. packs/sa/README.md says so under what the pack does not carry.', 'filing-guideline'),
  ('SA', 'SA-VAT-RETURN', '2', 'tax', 'VAT on private education and private healthcare supplied to citizens', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The tax column of field 2. Empty for the same reason as the value beside it.', 'filing-guideline'),
  ('SA', 'SA-VAT-RETURN', '3', 'base', 'Zero-rated domestic sales', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Field 3 of the sales screen, glossed "مثل: الأدوية والمعدات الطبية والمعادن الاستثمارية المؤهلة" — for example qualifying medicines, medical equipment and investment metals. It carries a supply made in the Kingdom that Chapter Six of the Implementing Regulations rates at zero and that is not an export: international transport (Article 34) lands here as well.', 'filing-guideline'),
  ('SA', 'SA-VAT-RETURN', '4', 'base', 'Exports', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Field 4 of the sales screen, glossed "مثل: صادرات السلع من المملكة أو الخدمات المقدمة إلى عميل غير مقيم بالمملكة" — exports of goods from the Kingdom, and services supplied to a customer not resident in it. Both the zero-rated export of goods of Article 32 and the zero-rated service of Article 33 are reported here, which is why this pack gives them one field and not two.', 'filing-guideline'),
  ('SA', 'SA-VAT-RETURN', '5', 'base', 'Exempt sales', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Field 5 of the sales screen, glossed "مثل: الخدمات المالية والتوريدات العقارية وتشمل بيع العقارات وتأجير العقار السكني" — financial services, and real estate supplies including the sale of real estate and the lease of residential property. Article 62(2)(g): "the total value of Exempt Supplies made by the Taxable Person".', 'filing-guideline'),
  ('SA', 'SA-VAT-RETURN', '6', 'total', 'Total sales, excluding VAT', '{}'::jsonb, 80, null, array['1:base', '2:base', '3:base', '4:base', '5:base']::text[], '{}'::text[], null, null, false, false, null, 'The total line of the sales screen. Its value is the sum of fields 1 to 5, each entered without tax.', 'filing-guideline'),
  ('SA', 'SA-VAT-RETURN', '7', 'base', 'Standard-rated domestic purchases', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The first field of the purchases screen. The filing guideline is precise about what may not go in it: a purchase unconnected with the taxable economic activity (it names catering, cars, their fuel and their maintenance), a purchase whose tax the taxable person cannot evidence with a tax invoice, a purchase made outside the Kingdom other than an import meeting the conditions, and a purchase belonging to a later tax period. Article 62(2)(b): "the total value of all Goods and services supplied to the Taxable Person, and the total deductible Input Tax".', 'filing-guideline'),
  ('SA', 'SA-VAT-RETURN', '7', 'tax', 'Deductible VAT on standard-rated domestic purchases', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The tax column of field 7, the deductible input tax of Article 49 of the Implementing Regulations.', 'vat-ir'),
  ('SA', 'SA-VAT-RETURN', '8', 'base', 'Imports of goods subject to VAT paid at Customs', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Field 8, which the guideline on imports and exports names as the field "which includes VAT paid to ZATCA" — the ordinary import, on which Saudi Customs collected the tax at the border under Article 43(3) of the Implementing Regulations.', 'imports-exports-guideline'),
  ('SA', 'SA-VAT-RETURN', '8', 'tax', 'VAT paid at Customs on imports, deductible', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The tax column of field 8. Article 62(2)(f): "the total value of Tax on imports reported through the Taxable Person''s Tax Return; and the total Input Tax relating to all imports of Goods by the Taxable Person". The tax was paid at the border and is deducted here.', 'vat-ir'),
  ('SA', 'SA-VAT-RETURN', '9', 'base', 'Taxable imports subject to VAT accounted for through the reverse charge mechanism', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Field 9, named word for word in the guideline on imports and exports, which reproduces the line of the return. It carries two things the Regulations treat alike: an import of goods by a taxable person authorised under Article 44 to pay through the return ("VAT shall be included in Field 9 of the VAT return instead of Field 8"), and a service received from a non-resident supplier under Article 47 ("VAT accounted for under the Reverse Charge Mechanism shall be reported in Field 9 of the Tax Return").', 'imports-exports-guideline'),
  ('SA', 'SA-VAT-RETURN', '9', 'tax', 'VAT self-assessed on field 9, net of the deduction of it', '{}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The tax column of field 9, and the one box of this return that needs reading twice. The guideline on imports and exports says what the portal does: the form "automatically treats the Input Tax as deductible on the supply", so a taxable person deducting in full owes nothing on the line and this column comes to zero — which is what the two tax postings of SA-P-RC-SVC and SA-P-IMP-RC produce, the output tax and the deduction of it cancelling in the box while both stand in the ledger, on 2100 and 1150. The guideline''s own worked example is a bank deducting 70 %: it enters the non-deductible 30 % of the value in the field''s adjustment column and the form computes the tax on that share alone. **This pack carries no proportional deduction** — Articles 51 and 52 of the Implementing Regulations, which the core has no room for — so a partly-deducting taxable person has to make that adjustment outside the pack, and the total below will not have made it for them.', 'imports-exports-guideline'),
  ('SA', 'SA-VAT-RETURN', '10', 'base', 'Zero-rated purchases', '{}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The zero-rated line of the purchases screen: a purchase of a supply Chapter Six of the Implementing Regulations rates at zero, which carries no tax to deduct.', 'vat-ir'),
  ('SA', 'SA-VAT-RETURN', '11', 'base', 'Exempt purchases', '{}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The exempt line of the purchases screen: a purchase of a supply exempted by Articles 29 or 30 of the Implementing Regulations, which carries no tax at all.', 'vat-ir'),
  ('SA', 'SA-VAT-RETURN', '12', 'total', 'Total purchases, excluding VAT', '{}'::jsonb, 170, null, array['7:base', '8:base', '9:base', '10:base', '11:base']::text[], '{}'::text[], null, null, false, false, null, 'The total line of the purchases screen, the sum of fields 7 to 11, each entered without tax.', 'filing-guideline'),
  ('SA', 'SA-VAT-RETURN', '13', 'total', 'Total VAT due for the current period', '{}'::jsonb, 180, null, array['1:tax', '2:tax']::text[], array['7:tax', '8:tax', '9:tax']::text[], null, null, false, false, null, 'The filing guideline states the arithmetic in words: "ونتيجة تعبئة المبيعات والمشتريات سينتج عنها الضريبة المستحقة وهي ناتج الإقرار للفترة الضريبية (الفرق بين الضريبة المستحقة على المبيعات والضريبة القابلة للخصم)" — filling in the sales and the purchases produces the tax due for the tax period, the difference between the tax due on sales and the deductible tax. Field 9 nets to zero for a taxable person deducting in full, which is why it is subtracted here with the other purchase fields rather than added.', 'filing-guideline'),
  ('SA', 'SA-VAT-RETURN', '14', 'tax', 'Corrections from a previous period', '{}'::jsonb, 190, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Implementing Regulations, Article 63, and the filing guideline: the corrections field takes the VAT amount only, up and down, "في حدود ضريبة بحد أقصى 15,000 ريال" — within a maximum of 15,000 riyals of tax. The English eighth edition still prints the figure this field had before, 5,000 riyals; the Arabic tenth edition of April 2025 and the filing guideline both say 15,000, and the Arabic is the version the English translation itself defers to. A larger error is corrected by amending the return it was made in, after notifying the Authority within twenty days of becoming aware of it. **No tax of this pack posts here**: a correction is a decision about a period already filed, not a consequence of a document.', 'filing-guideline'),
  ('SA', 'SA-VAT-RETURN', '15', 'tax', 'VAT credit carried forward from a previous period', '{}'::jsonb, 200, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The filing guideline: where the tax collected on sales is less than the deductible tax on purchases, the return produces "رصيد مرحل قابل للاسترداد" — a carried-forward balance the taxable person may claim back. **No tax of this pack posts here either**: the figure is the balance of an earlier return, which ZATCA carries forward, and the pack computes one period at a time.', 'filing-guideline'),
  ('SA', 'SA-VAT-RETURN', '16', 'total', 'Net VAT due, or claimed', '{}'::jsonb, 210, null, array['13', '14']::text[], array['15']::text[], null, null, false, false, null, 'The last line of the return: the tax due for the period, adjusted by the corrections of field 14 and reduced by the credit carried forward of field 15. A negative figure is a refundable balance, and this pack applies no floor at zero — the filing guideline describes both outcomes, an amount to pay and a balance to carry or reclaim.', 'filing-guideline')
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
  ('SA-IFRSSME-IS', 'SA', 'default', 'Income statement — IFRS for Small and Medium-sized Entities', 'income_statement', 'SA-IFRS-SME', date '1970-01-01', null, 'The Saudi Organization for Chartered and Professional Accountants endorses the IFRS for SMEs Accounting Standard for a small or medium-sized entity, and full IFRS for a listed entity; the Kingdom prescribes no chart of accounts and no statement format of its own. See the chart''s own legal_reference in pack.json for what this pack''s research could and could not open.', 'socpa-standards'),
  ('SA-IFRSSME-SFP', 'SA', 'default', 'Statement of financial position — IFRS for Small and Medium-sized Entities', 'balance_sheet', 'SA-IFRS-SME', date '1970-01-01', null, 'The Saudi Organization for Chartered and Professional Accountants endorses the IFRS for SMEs Accounting Standard for a small or medium-sized entity, and full IFRS for a listed entity; the Kingdom prescribes no chart of accounts and no statement format of its own. See the chart''s own legal_reference in pack.json for what this pack''s research could and could not open.', 'socpa-standards')
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
  ('SA-IFRSSME-IS', '1', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 5.5(a).', null),
  ('SA-IFRSSME-IS', '2', null, 'Other income', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 5.11(a) — an analysis of expenses by nature, the other items of income presented separately from revenue.', null),
  ('SA-IFRSSME-IS', '3', null, 'Cost of sales', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 5.11(a).', null),
  ('SA-IFRSSME-IS', '4', null, 'Employee benefits expense', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 5.11(a) — employee benefits expense, which in the Kingdom carries the employer''s GOSI contributions and the end-of-service award of Section 28.', null),
  ('SA-IFRSSME-IS', '5', null, 'Depreciation and amortisation', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 5.11(a).', null),
  ('SA-IFRSSME-IS', '6', null, 'Other operating expenses', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 5.11(a). Input tax the Implementing Regulations disallow lands on the expense line it taxes and is presented here with it, not as a tax.', null),
  ('SA-IFRSSME-IS', '7', null, 'Finance costs', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 5.5(b).', null),
  ('SA-IFRSSME-IS', '8', null, 'Profit before zakat and income tax', '{}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 5.5(d) — profit or loss before tax.', null),
  ('SA-IFRSSME-IS', '9', null, 'Zakat', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'Zakat is assessed by ZATCA on a Saudi or GCC person''s share of a company and is presented apart from income tax, which is assessed on the rest. Neither is a value added tax and this pack carries neither as a tax of taxes.json — see packs/sa/README.md.', null),
  ('SA-IFRSSME-IS', '10', null, 'Income tax expense', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 5.5(e) — tax expense excluding tax allocated to discontinued operations.', null),
  ('SA-IFRSSME-IS', '11', null, 'Profit for the year', '{}'::jsonb, 110, 1, true, array['8']::text[], array['9', '10']::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 5.5(f).', null),
  ('SA-IFRSSME-SFP', 'CA', null, 'Current assets', '{}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5', 'CA.6']::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, Section 4, paragraphs 4.4 to 4.6 — current and non-current assets are presented as separate classifications.', null),
  ('SA-IFRSSME-SFP', 'CA.1', 'CA', 'Cash and cash equivalents', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 4.2(a).', null),
  ('SA-IFRSSME-SFP', 'CA.2', 'CA', 'Trade and other receivables', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 4.2(b). VAT input tax, the amount refundable by ZATCA and withholding tax suffered on the entity''s own receipts are presented here rather than as a current tax asset, which paragraph 4.2(n) keeps for the zakat and the income tax the entity is itself assessed on.', null),
  ('SA-IFRSSME-SFP', 'CA.3', 'CA', 'Inventories', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 4.2(d).', null),
  ('SA-IFRSSME-SFP', 'CA.4', 'CA', 'Financial assets', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 4.2(c), the part realised within twelve months.', null),
  ('SA-IFRSSME-SFP', 'CA.5', 'CA', 'Current tax assets', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 4.2(n) — zakat and income tax recoverable from ZATCA on the entity''s own assessment.', null),
  ('SA-IFRSSME-SFP', 'CA.6', 'CA', 'Prepayments and accrued income', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 4.2(b), the part that is not a receivable.', null),
  ('SA-IFRSSME-SFP', 'NCA', null, 'Non-current assets', '{}'::jsonb, 80, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4']::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, Section 4, paragraphs 4.4 to 4.6.', null),
  ('SA-IFRSSME-SFP', 'NCA.1', 'NCA', 'Property, plant and equipment', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 4.2(e). Right-of-use assets are carried among them: IFRS 16 reaches a lessee applying full IFRS, and a lessee applying the IFRS for SMEs capitalises a finance lease under Section 20.', null),
  ('SA-IFRSSME-SFP', 'NCA.2', 'NCA', 'Investments', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 4.2(j) — investments in associates and in jointly controlled entities.', null),
  ('SA-IFRSSME-SFP', 'NCA.3', 'NCA', 'Other non-current assets', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 4.2(c), the part not realised within twelve months.', null),
  ('SA-IFRSSME-SFP', 'NCA.4', 'NCA', 'Intangible assets and goodwill', '{}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraphs 4.2(g) and 4.2(h).', null),
  ('SA-IFRSSME-SFP', 'TA', null, 'Total assets', '{}'::jsonb, 130, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 4.2 — the statement presents the entity''s assets, liabilities and equity as at the reporting date.', null),
  ('SA-IFRSSME-SFP', 'CL', null, 'Current liabilities', '{}'::jsonb, 140, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4', 'CL.5']::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, Section 4, paragraphs 4.7 and 4.8.', null),
  ('SA-IFRSSME-SFP', 'CL.1', 'CL', 'Trade and other payables', '{}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 4.2(k). GOSI contributions payable are a payable to the General Organization for Social Insurance and not a tax liability.', null),
  ('SA-IFRSSME-SFP', 'CL.2', 'CL', 'Value added tax and withholding tax payable', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 4.2(k). A tax the entity collects or withholds on behalf of ZATCA is a payable of Section 4 and not a current tax liability of paragraph 4.2(n), which is the tax the entity is itself assessed on.', null),
  ('SA-IFRSSME-SFP', 'CL.3', 'CL', 'Zakat and income tax payable', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 4.2(n) — liabilities for current tax. Zakat is presented here beside income tax: both are assessed on the entity itself by ZATCA, on the shares held respectively by Saudi and GCC persons and by others.', null),
  ('SA-IFRSSME-SFP', 'CL.4', 'CL', 'Employee benefits — current portion', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, Section 28 — the end-of-service award every employer owes on termination.', null),
  ('SA-IFRSSME-SFP', 'CL.5', 'CL', 'Financing and other financial liabilities', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 4.2(k).', null),
  ('SA-IFRSSME-SFP', 'NCL', null, 'Non-current liabilities', '{}'::jsonb, 200, 1, true, array['NCL.1', 'NCL.2', 'NCL.3']::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, Section 4, paragraphs 4.7 and 4.8.', null),
  ('SA-IFRSSME-SFP', 'NCL.1', 'NCL', 'Financing and other financial liabilities', '{}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 4.2(k).', null),
  ('SA-IFRSSME-SFP', 'NCL.2', 'NCL', 'Provisions', '{}'::jsonb, 220, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 4.2(l).', null),
  ('SA-IFRSSME-SFP', 'NCL.3', 'NCL', 'Employee benefits — non-current portion', '{}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, Section 28, paragraph 28.3 — the obligation for an end-of-service award, to the extent it is not settled within twelve months.', null),
  ('SA-IFRSSME-SFP', 'TL', null, 'Total liabilities', '{}'::jsonb, 240, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 4.2.', null),
  ('SA-IFRSSME-SFP', 'NA', null, 'Net assets', '{}'::jsonb, 250, 1, true, array['TA']::text[], array['TL']::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 4.2 — assets less liabilities, which equity equals once the result of the year has been closed.', null),
  ('SA-IFRSSME-SFP', 'EQ', null, 'Equity', '{}'::jsonb, 260, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 4.2(q).', null),
  ('SA-IFRSSME-SFP', 'EQ.1', 'EQ', 'Share capital', '{}'::jsonb, 270, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 4.2(q).', null),
  ('SA-IFRSSME-SFP', 'EQ.2', 'EQ', 'Reserves', '{}'::jsonb, 280, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 4.2(q). The statutory reserve is the share of the annual net profit a Saudi joint stock or limited liability company transfers to a reserve under the Companies Law — see the chart''s legal_reference in pack.json.', null),
  ('SA-IFRSSME-SFP', 'EQ.3', 'EQ', 'Retained earnings', '{}'::jsonb, 290, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for Small and Medium-sized Entities Accounting Standard, paragraph 4.2(q).', null)
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
    ('SA-IFRSSME-IS', '1', 10, 'code_range', '4000', '4040', null, 'any'),
    ('SA-IFRSSME-IS', '2', 10, 'code_range', '4700', '4790', null, 'any'),
    ('SA-IFRSSME-IS', '3', 10, 'code_range', '5000', '5030', null, 'any'),
    ('SA-IFRSSME-IS', '4', 10, 'code_range', '6100', '6140', null, 'any'),
    ('SA-IFRSSME-IS', '5', 10, 'code_range', '6500', '6510', null, 'any'),
    ('SA-IFRSSME-IS', '6', 10, 'code_range', '6200', '6440', null, 'any'),
    ('SA-IFRSSME-IS', '6', 20, 'code_range', '6950', '6990', null, 'any'),
    ('SA-IFRSSME-IS', '7', 10, 'code_range', '7100', '7110', null, 'any'),
    ('SA-IFRSSME-IS', '9', 10, 'account_code', '8000', null, null, 'any'),
    ('SA-IFRSSME-IS', '10', 10, 'account_code', '8010', null, null, 'any'),
    ('SA-IFRSSME-SFP', 'CA.1', 10, 'code_range', '1000', '1050', null, 'any'),
    ('SA-IFRSSME-SFP', 'CA.2', 10, 'code_range', '1100', '1160', null, 'any'),
    ('SA-IFRSSME-SFP', 'CA.2', 20, 'account_code', '2990', null, null, 'debit'),
    ('SA-IFRSSME-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('SA-IFRSSME-SFP', 'CA.4', 10, 'account_code', '1300', null, null, 'any'),
    ('SA-IFRSSME-SFP', 'CA.5', 10, 'account_code', '1350', null, null, 'any'),
    ('SA-IFRSSME-SFP', 'CA.6', 10, 'code_range', '1400', '1430', null, 'any'),
    ('SA-IFRSSME-SFP', 'NCA.1', 10, 'code_range', '1600', '1691', null, 'any'),
    ('SA-IFRSSME-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('SA-IFRSSME-SFP', 'NCA.3', 10, 'account_code', '1710', null, null, 'any'),
    ('SA-IFRSSME-SFP', 'NCA.4', 10, 'code_range', '1730', '1751', null, 'any'),
    ('SA-IFRSSME-SFP', 'CL.1', 10, 'code_range', '2000', '2055', null, 'any'),
    ('SA-IFRSSME-SFP', 'CL.1', 20, 'account_code', '2990', null, null, 'credit'),
    ('SA-IFRSSME-SFP', 'CL.2', 10, 'code_range', '2100', '2120', null, 'any'),
    ('SA-IFRSSME-SFP', 'CL.3', 10, 'code_range', '2130', '2135', null, 'any'),
    ('SA-IFRSSME-SFP', 'CL.4', 10, 'account_code', '2150', null, null, 'any'),
    ('SA-IFRSSME-SFP', 'CL.5', 10, 'code_range', '2200', '2210', null, 'any'),
    ('SA-IFRSSME-SFP', 'NCL.1', 10, 'account_code', '2300', null, null, 'any'),
    ('SA-IFRSSME-SFP', 'NCL.2', 10, 'account_code', '2320', null, null, 'any'),
    ('SA-IFRSSME-SFP', 'NCL.3', 10, 'account_code', '2350', null, null, 'any'),
    ('SA-IFRSSME-SFP', 'EQ.1', 10, 'account_code', '3000', null, null, 'any'),
    ('SA-IFRSSME-SFP', 'EQ.2', 10, 'code_range', '3010', '3030', null, 'any'),
    ('SA-IFRSSME-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('SA', 'Saudi Arabia', '{}'::jsonb, array['en']::text[], 'SAR', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, null)
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
  numbering_legal_reference     = 'Implementing Regulations, Article 53(5)(b) — a Tax Invoice carries "a sequential number which uniquely identifies the Tax Invoice". The article asks that the number identify the invoice and run in sequence, not that the series carry no hole, which is why the style is `sequential` and not a gapless one. The Electronic Invoice XML Implementation Standard adds a second identifier beside it, a UUID per document, and chains each invoice to the one before it by a hash — neither of which is the number a reader sees, and neither of which this field holds. The pattern in `number_format` is one a business may choose.',
  numbering_source_key          = 'vat-ir',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Common VAT Agreement, Article 23(1), which the VAT Law applies by its own Article 2(1): "Tax becomes due on the date of the supply of Goods or Services, the date of issuance of the tax invoice or upon partial or full receipt of the Consideration, whichever comes first, and to the extent of the received amount." That is a three-way earliest test — supply, invoice, payment — and the closed vocabulary of this field has no value for three triggers at once. `earliest_of_delivery_or_payment` is the nearest of the five and is what the rule reduces to in the ordinary case, because Article 53(1)(b) of the Implementing Regulations already requires the Tax Invoice by the fifteenth day of the month following the supply; a supply invoiced ahead of delivery is the case this approximation misses. docs/international.md records the same gap for Vietnam, whose Article 8 reads the same way.',
  tax_point_source_key          = 'vat-agreement',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_legal_reference      = 'Electronic invoicing is obligatory in the Kingdom and this pack still leaves all four fields above empty, for the reason packs/mx/, packs/vn/ and packs/kr/ leave them empty: FATOORA is a clearance regime, not an exchange between two parties'' access points, and `profile` names an EN 16931 profile that a brick of packages/formats actually writes. The obligation itself: the E-invoicing Regulation published 4 December 2020 binds every taxable person resident in the Kingdom, and any customer or third party issuing on their behalf (Article 3(A)), to issue Electronic Invoices for every transaction requiring a tax invoice (Article 3(B)), with twelve months from publication to do so (Article 7(B)) — so 4 December 2021. The Governor''s Decision No. (62738) dated 23/11/1443H splits the obligation in two: the **Generation** phase, "applied to all Persons subject to the E-Invoicing Regulation effective 4th of December 2021", and the **Integration** phase, "in phases starting from 1st of January 2023", each wave being a group ZATCA names and notifies at least six months ahead (Clause Sixth). In the Integration phase a Tax Invoice between businesses is **cleared**: the invoice is transmitted to ZATCA, which verifies it against the resolution and its annexes and "shall insert the Cryptographic Stamp only on the Invoices and Notes which fulfil the aforesaid controls ... prior to sharing them with the customers" — an invoice the Authority has not stamped is not an invoice the seller may give the buyer. A Simplified Tax Invoice, the business-to-consumer document, is instead **reported** to ZATCA "within a period which must not exceed (24) hours from its generation". The format is XML, or PDF/A-3 with the XML embedded, written against ZATCA''s own Electronic Invoice XML Implementation Standard — a UBL 2.1 subset whose business rules are a subset of EN 16931 but which is not a PINT profile and is exchanged over ZATCA''s API rather than over a four-corner network. No brick of packages/formats writes that XML, signs it with the ECDSA key the standard requires, embeds the invoice hash chain or the QR code, or talks to ZATCA: a document issued from Ekwo is not an Electronic Invoice, and `mandatory_from` with no `profile` would claim it was. `obligation` is left out for the same reason and not because nobody looked: the schema refuses `mandatory` without `mandatory_from`, and `mandatory_from` without a `profile`, so the three fields stand or fall together. `party_scheme` and `vat_scheme` are empty because the Kingdom has no ISO 6523 identifier: it is absent from the Peppol participant identifier scheme list v9.7, which carries AE and OM and no SA. What a Saudi invoice carries instead is the 15-digit VAT registration number whose first and last digits are 3 (Electronic Invoice XML Implementation Standard, rules BR-KSA-39 and BR-KSA-40). docs/international.md carries the rest.',
  einvoice_source_key           = 'einvoicing-resolution',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'SA';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('SA', 'reverse_charge', 'reverse_charge', 'Reverse charge: the Customer must account for the Tax due on this supply, under Article 47 of the Implementing Regulations of the VAT Law.', '{}'::jsonb, 10, date '1970-01-01', null, 'Implementing Regulations, Article 53(5)(d) — where the Customer is required to self-account for Tax, the Tax Invoice carries "the Customer''s Tax Identification Number and a statement that the Customer must account for the Tax". Article 53(5) requires every detail it lists to be printed **in Arabic**, any other language being a translation shown beside it: the sentence above is the pack''s own English, and `i18n/ar.json` is where an Arabic wording belongs.'),
  ('SA', 'not_basic_rate', 'exempt', 'This supply is not taxed at the basic rate of 15 %. The tax treatment applied to it, and the article of the Implementing Regulations it is granted by, are stated against the line.', '{}'::jsonb, 20, date '1970-01-01', null, 'Implementing Regulations, Article 53(5)(k) — "in the case where Tax is not charged at the basic rate, a narration explaining the Tax treatment applied to the supply". The article asks for a narration and prescribes no wording, so the sentence here is the pack''s own and names where the reader finds the treatment. `applies_when` has no value for "any line not at the basic rate": it resolves `exempt` from the treatment of the line''s tax, and `export` is a separate value the pack does not repeat this sentence on, so a zero-rated domestic line — international transport, qualifying medicines, investment metals — carries no mention here although Article 53(5)(k) asks for one. That gap is the vocabulary''s and is written up in docs/international.md.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
