-- Ekwo OS — Sri Lanka: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/lk at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build lk`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Value Added Tax (VAT) — the Inland Revenue Department's page on the tax: the standard rate by period (8 % to 31 May 2022, 12 % from 1 June 2022, 15 % from 1 September 2022 to 31 December 2023, 18 % from 1 January 2024), the payment on or before the 20th day of the following month, the return on or before the last day of the month after the taxable period, the monthly or quarterly taxable period, the registration thresholds of LKR 15 million a quarter and LKR 60 million over twelve months, and the mandatory e-Services filing from 1 July 2025 (Inland Revenue Department of Sri Lanka)
--     https://www.ird.gov.lk/en/type%20of%20taxes/sitepages/value%20added%20tax%20(vat).aspx
--   Value Added Tax Act, No. 14 of 2002, as amended to 2024 (unofficial consolidated reading) — s. 2 (charge and rates, the tax fraction 9/59 at 18 %), s. 4 (time of supply), s. 5 (value of a supply: the consideration less any tax chargeable under this Act), s. 7 (zero rating), s. 8 (exempt supplies and the First Schedule), s. 20 (tax invoice), s. 21 (return), s. 26 (payment), s. 83 (taxable period); First Schedule, Part III (LankaLaw (consolidated text; the Inland Revenue Department publishes no consolidation after the 2014 one))
--     https://lankalaw.net/wp-content/uploads/2025/03/Value-Added-Tax-Consolidated-2024.pdf
--   Notice SEC/PN/VAT/2026-03 of 3 July 2026 — Value Added Tax (Amendment) Act No. 14 of 2026, certified on 30 June 2026: financial services at 20.5 % for taxable periods commencing on or after 1 July 2026 and exempt from the SSCL (Item 25 of Part II of the First Schedule to the SSCL Act), registration thresholds unchanged, VAT on services supplied by non-residents through electronic platforms from 1 July 2026, schedules submitted from the first day of the period, secured point-of-sale machines (Inland Revenue Department of Sri Lanka)
--     https://www.ird.gov.lk/en/Lists/Latest%20News%20%20Notices/Attachments/799/PN_VAT_2026-03_New_E.pdf
--   Notice SEC/PN/VAT/2026-03 of 4 May 2026 — the National e-Invoicing System: a Web API from the taxpayer's ERP to RAMIS, a pilot, then export-oriented enterprises (phase 1) and every VAT-registered person (phase 2), Schedules 01, 04 and 07 transmitted, the purchaser's Schedules 02 and 04 pre-populated (Inland Revenue Department of Sri Lanka)
--     https://www.ird.gov.lk/en/Lists/Latest%20News%20%20Notices/Attachments/781/PN_VAT_2026-03_E.pdf
--   Extraordinary Gazette No. 2481/22 of 27 March 2026 — the format and specification of the Tax Invoice every registered person issues: the title TAX INVOICE, the nine-digit TIN of supplier and purchaser, the serial number YYMMM_QQQQ_XXXXX of at most forty characters, the dates as MM/DD/YYYY, the value of supply, the VAT charged and the total consideration (Government of Sri Lanka, Department of Government Printing)
--     https://www.ird.gov.lk/en/publications/Gazette_Documents/2026_2481-22_E.pdf
--   Extraordinary Gazette No. 2500/106 of 6 August 2026 — the effective date of the Tax Invoice specification of Gazette 2481/22 moved from 1 July 2026 to 1 October 2026 (Government of Sri Lanka, Department of Government Printing)
--     https://www.ird.gov.lk/en/publications/Gazette_Documents/2026_2500_106_E.pdf
--   Notice PN/VAT/2025-01 (Revised) of 17 April 2025 — the Value Added Tax (Amendment) Act No. 4 of 2025: the Simplified VAT Scheme abolished with effect from 1 October 2025 and replaced by a Risk-Based Refund Scheme (Inland Revenue Department of Sri Lanka)
--     https://www.ird.gov.lk/en/Lists/Latest%20News%20%20Notices/Attachments/677/PN_VAT_2025-01_11042025_E.pdf
--   Quick guide "How to file VAT" (version 3, for taxable periods commencing on or after 1 July 2025) — the return filed through e-Services, its cages and the VAT schedules 01 to 07 that feed them (A and 0, B and 2, D, D1, I and 6, 4 and 5, 8, J4 and R3) (Inland Revenue Department of Sri Lanka)
--     https://www.ird.gov.lk/en/eServices/Lists/FilingReturns/Attachments/5/Quick_Guide_VAT_2025_V3.pdf
--   Circular No. 2011/07, Instructions — filing of VAT returns: the cages of the return (the tax payable in cage 16, the excess of input over output in cage 15) (Inland Revenue Department of Sri Lanka)
--     https://ird.gov.lk/en/publications/Circulars_Circulars/VATCirNo2011_07[E].pdf
--   RAMIS e-Services — the Inland Revenue Department's portal where the VAT return and its schedules are filed and the tax paid (Inland Revenue Department of Sri Lanka)
--     https://eservices.ird.gov.lk/
--   Social Security Contribution Levy Act, No. 25 of 2022, consolidated up to 9 April 2026 (reference consolidation prepared by the Inland Revenue Department, 26 May 2026) — s. 3 (the levy at 2.5 % of the liable turnover of a quarter, VAT excluded by s. 3(3)(b)), s. 4 (registration thresholds), s. 8 (quarterly return by the twentieth day after the quarter), s. 17 (monthly payment), the First and Second Schedules (Inland Revenue Department of Sri Lanka)
--     https://www.ird.gov.lk/si/publications/Acts_SSCL/SSCL_Cons_Act_-_2026_Changes.pdf
--   Notice PN/SSCL/2026-04/1 of 16 April 2026 — the Social Security Contribution Levy (Amendment) Act, No. 10 of 2026, certified on 9 April 2026: the registration thresholds of LKR 9 million a quarter and LKR 36 million over four quarters from 1 July 2026; motor vehicles from 1 May 2026 (Inland Revenue Department of Sri Lanka)
--     https://www.ird.gov.lk/en/Lists/Latest%20News%20%20Notices/Attachments/780/PN_SSCL_2026-04_1_E.pdf
--   Inland Revenue Act, No. 24 of 2017, s. 20(1) — the year of assessment is the twelve months from 1 April to 31 March (Inland Revenue Department of Sri Lanka)
--     https://www.ird.gov.lk/en/publications/Acts_Income%20Tax_2017/IR_Act_No_24_2017_E.pdf
--   Companies Act, No. 7 of 2007, ss. 148 to 151 — accounting records, the financial statements within six months of the balance sheet date, and their true and fair view (Parliament of Sri Lanka)
--     https://www.parliament.lk/uploads/acts/gbills/english/3776.pdf
--   Accounting Standards — the Sri Lanka Accounting and Auditing Standards Act, No. 15 of 1995, which empowers CA Sri Lanka to adopt the Sri Lanka Accounting Standards, mandatory for Specified Business Enterprises, converged with the IASB's standards since 1 January 2012 (Institute of Chartered Accountants of Sri Lanka (CA Sri Lanka))
--     https://www.slaasc.lk/accounting/accountStandards.php
--   Use of IFRS Standards by jurisdiction — Sri Lanka: SLFRS and LKAS issued by CA Sri Lanka, the SLFRS for SMEs permitted to entities that meet the smaller-entity thresholds (IFRS Foundation)
--     https://www.ifrs.org/use-around-the-world/use-of-ifrs-standards-by-jurisdiction/view-jurisdiction/sri-lanka/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('LK', 'Sri Lanka', '0.1.0', date '2026-10-09', '20260923110000', 'community', null, null, '3bd54ef1cc5d920e4a13a45f5b0f2020683504bbcc808b19e2594e302ff0b2c5', '[{"key":"ird-vat","title":"Value Added Tax (VAT) — the Inland Revenue Department''s page on the tax: the standard rate by period (8 % to 31 May 2022, 12 % from 1 June 2022, 15 % from 1 September 2022 to 31 December 2023, 18 % from 1 January 2024), the payment on or before the 20th day of the following month, the return on or before the last day of the month after the taxable period, the monthly or quarterly taxable period, the registration thresholds of LKR 15 million a quarter and LKR 60 million over twelve months, and the mandatory e-Services filing from 1 July 2025","publisher":"Inland Revenue Department of Sri Lanka","url":"https://www.ird.gov.lk/en/type%20of%20taxes/sitepages/value%20added%20tax%20(vat).aspx","consulted_on":"2026-10-09","kind":"guidance"},{"key":"vat-act","title":"Value Added Tax Act, No. 14 of 2002, as amended to 2024 (unofficial consolidated reading) — s. 2 (charge and rates, the tax fraction 9/59 at 18 %), s. 4 (time of supply), s. 5 (value of a supply: the consideration less any tax chargeable under this Act), s. 7 (zero rating), s. 8 (exempt supplies and the First Schedule), s. 20 (tax invoice), s. 21 (return), s. 26 (payment), s. 83 (taxable period); First Schedule, Part III","publisher":"LankaLaw (consolidated text; the Inland Revenue Department publishes no consolidation after the 2014 one)","url":"https://lankalaw.net/wp-content/uploads/2025/03/Value-Added-Tax-Consolidated-2024.pdf","consulted_on":"2026-10-09","kind":"law"},{"key":"vat-amend-2026","title":"Notice SEC/PN/VAT/2026-03 of 3 July 2026 — Value Added Tax (Amendment) Act No. 14 of 2026, certified on 30 June 2026: financial services at 20.5 % for taxable periods commencing on or after 1 July 2026 and exempt from the SSCL (Item 25 of Part II of the First Schedule to the SSCL Act), registration thresholds unchanged, VAT on services supplied by non-residents through electronic platforms from 1 July 2026, schedules submitted from the first day of the period, secured point-of-sale machines","publisher":"Inland Revenue Department of Sri Lanka","url":"https://www.ird.gov.lk/en/Lists/Latest%20News%20%20Notices/Attachments/799/PN_VAT_2026-03_New_E.pdf","consulted_on":"2026-10-09","kind":"guidance"},{"key":"vat-einvoicing","title":"Notice SEC/PN/VAT/2026-03 of 4 May 2026 — the National e-Invoicing System: a Web API from the taxpayer''s ERP to RAMIS, a pilot, then export-oriented enterprises (phase 1) and every VAT-registered person (phase 2), Schedules 01, 04 and 07 transmitted, the purchaser''s Schedules 02 and 04 pre-populated","publisher":"Inland Revenue Department of Sri Lanka","url":"https://www.ird.gov.lk/en/Lists/Latest%20News%20%20Notices/Attachments/781/PN_VAT_2026-03_E.pdf","consulted_on":"2026-10-09","kind":"guidance"},{"key":"gazette-2481","title":"Extraordinary Gazette No. 2481/22 of 27 March 2026 — the format and specification of the Tax Invoice every registered person issues: the title TAX INVOICE, the nine-digit TIN of supplier and purchaser, the serial number YYMMM_QQQQ_XXXXX of at most forty characters, the dates as MM/DD/YYYY, the value of supply, the VAT charged and the total consideration","publisher":"Government of Sri Lanka, Department of Government Printing","url":"https://www.ird.gov.lk/en/publications/Gazette_Documents/2026_2481-22_E.pdf","consulted_on":"2026-10-09","kind":"regulation"},{"key":"gazette-2500","title":"Extraordinary Gazette No. 2500/106 of 6 August 2026 — the effective date of the Tax Invoice specification of Gazette 2481/22 moved from 1 July 2026 to 1 October 2026","publisher":"Government of Sri Lanka, Department of Government Printing","url":"https://www.ird.gov.lk/en/publications/Gazette_Documents/2026_2500_106_E.pdf","consulted_on":"2026-10-09","kind":"regulation"},{"key":"vat-notice-2025","title":"Notice PN/VAT/2025-01 (Revised) of 17 April 2025 — the Value Added Tax (Amendment) Act No. 4 of 2025: the Simplified VAT Scheme abolished with effect from 1 October 2025 and replaced by a Risk-Based Refund Scheme","publisher":"Inland Revenue Department of Sri Lanka","url":"https://www.ird.gov.lk/en/Lists/Latest%20News%20%20Notices/Attachments/677/PN_VAT_2025-01_11042025_E.pdf","consulted_on":"2026-10-09","kind":"guidance"},{"key":"vat-guide","title":"Quick guide \"How to file VAT\" (version 3, for taxable periods commencing on or after 1 July 2025) — the return filed through e-Services, its cages and the VAT schedules 01 to 07 that feed them (A and 0, B and 2, D, D1, I and 6, 4 and 5, 8, J4 and R3)","publisher":"Inland Revenue Department of Sri Lanka","url":"https://www.ird.gov.lk/en/eServices/Lists/FilingReturns/Attachments/5/Quick_Guide_VAT_2025_V3.pdf","consulted_on":"2026-10-09","kind":"form"},{"key":"vat-circular-2011","title":"Circular No. 2011/07, Instructions — filing of VAT returns: the cages of the return (the tax payable in cage 16, the excess of input over output in cage 15)","publisher":"Inland Revenue Department of Sri Lanka","url":"https://ird.gov.lk/en/publications/Circulars_Circulars/VATCirNo2011_07[E].pdf","consulted_on":"2026-10-09","kind":"guidance"},{"key":"ramis","title":"RAMIS e-Services — the Inland Revenue Department''s portal where the VAT return and its schedules are filed and the tax paid","publisher":"Inland Revenue Department of Sri Lanka","url":"https://eservices.ird.gov.lk/","consulted_on":"2026-10-09","kind":"portal"},{"key":"sscl-act","title":"Social Security Contribution Levy Act, No. 25 of 2022, consolidated up to 9 April 2026 (reference consolidation prepared by the Inland Revenue Department, 26 May 2026) — s. 3 (the levy at 2.5 % of the liable turnover of a quarter, VAT excluded by s. 3(3)(b)), s. 4 (registration thresholds), s. 8 (quarterly return by the twentieth day after the quarter), s. 17 (monthly payment), the First and Second Schedules","publisher":"Inland Revenue Department of Sri Lanka","url":"https://www.ird.gov.lk/si/publications/Acts_SSCL/SSCL_Cons_Act_-_2026_Changes.pdf","consulted_on":"2026-10-09","kind":"law"},{"key":"sscl-notice-2026","title":"Notice PN/SSCL/2026-04/1 of 16 April 2026 — the Social Security Contribution Levy (Amendment) Act, No. 10 of 2026, certified on 9 April 2026: the registration thresholds of LKR 9 million a quarter and LKR 36 million over four quarters from 1 July 2026; motor vehicles from 1 May 2026","publisher":"Inland Revenue Department of Sri Lanka","url":"https://www.ird.gov.lk/en/Lists/Latest%20News%20%20Notices/Attachments/780/PN_SSCL_2026-04_1_E.pdf","consulted_on":"2026-10-09","kind":"guidance"},{"key":"ira-2017","title":"Inland Revenue Act, No. 24 of 2017, s. 20(1) — the year of assessment is the twelve months from 1 April to 31 March","publisher":"Inland Revenue Department of Sri Lanka","url":"https://www.ird.gov.lk/en/publications/Acts_Income%20Tax_2017/IR_Act_No_24_2017_E.pdf","consulted_on":"2026-10-09","kind":"law"},{"key":"companies-act","title":"Companies Act, No. 7 of 2007, ss. 148 to 151 — accounting records, the financial statements within six months of the balance sheet date, and their true and fair view","publisher":"Parliament of Sri Lanka","url":"https://www.parliament.lk/uploads/acts/gbills/english/3776.pdf","consulted_on":"2026-10-09","kind":"law"},{"key":"ca-standards","title":"Accounting Standards — the Sri Lanka Accounting and Auditing Standards Act, No. 15 of 1995, which empowers CA Sri Lanka to adopt the Sri Lanka Accounting Standards, mandatory for Specified Business Enterprises, converged with the IASB''s standards since 1 January 2012","publisher":"Institute of Chartered Accountants of Sri Lanka (CA Sri Lanka)","url":"https://www.slaasc.lk/accounting/accountStandards.php","consulted_on":"2026-10-09","kind":"standard"},{"key":"ifrs-lk","title":"Use of IFRS Standards by jurisdiction — Sri Lanka: SLFRS and LKAS issued by CA Sri Lanka, the SLFRS for SMEs permitted to entities that meet the smaller-entity thresholds","publisher":"IFRS Foundation","url":"https://www.ifrs.org/use-around-the-world/use-of-ifrs-standards-by-jurisdiction/view-jurisdiction/sri-lanka/","consulted_on":"2026-10-09","kind":"standard"}]'::jsonb)
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
  ('LK', 'default', 'Sri Lanka reference chart of accounts', '{}'::jsonb, true, 'companies', array['LK-SLFRS-IS', 'LK-SLFRS-SFP']::text[], null, 'There is no legal chart of accounts in Sri Lanka. Companies Act, No. 7 of 2007, s. 148 requires every company to keep accounting records that correctly record and explain its transactions, s. 150 requires the financial statements within six months of the balance sheet date and s. 151 that they give a true and fair view; the Sri Lanka Accounting and Auditing Standards Act, No. 15 of 1995 empowers CA Sri Lanka to adopt the Sri Lanka Accounting Standards (SLFRS and LKAS, converged with the IASB''s standards since 1 January 2012), mandatory for Specified Business Enterprises, and the SLFRS for SMEs is open to the entities that meet the smaller-entity thresholds. This chart is original: four digits, blocked so that each range reaches one line of the statements below, with the accounts a Sri Lankan company actually keeps — VAT output and input kept apart, import VAT owed to Sri Lanka Customs, the net VAT due to or from the Inland Revenue Department after a return, the Social Security Contribution Levy payable and its expense, EPF and ETF contributions, APIT, withholding tax and gratuity.', 'companies-act')
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
  ('LK', 'default', '1000', 'Petty cash', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('LK', 'default', '1010', 'Current account — LKR', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('LK', 'default', '1020', 'Savings account — LKR', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('LK', 'default', '1030', 'Foreign currency account — USD', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('LK', 'default', '1040', 'Cash in transit — card and mobile wallet settlements', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('LK', 'default', '1100', 'Trade receivables', '{}'::jsonb, 'asset_receivable', true, null, 60),
  ('LK', 'default', '1110', 'Trade receivables — allowance for expected credit losses', '{}'::jsonb, 'asset_current', false, null, 70),
  ('LK', 'default', '1120', 'Other receivables', '{}'::jsonb, 'asset_current', false, null, 80),
  ('LK', 'default', '1130', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 90),
  ('LK', 'default', '1140', 'Deposits paid', '{}'::jsonb, 'asset_current', false, null, 100),
  ('LK', 'default', '1150', 'VAT input tax — local purchases', '{}'::jsonb, 'asset_current', false, null, 110),
  ('LK', 'default', '1151', 'VAT input tax — imports paid at the border', '{}'::jsonb, 'asset_current', false, null, 120),
  ('LK', 'default', '1155', 'VAT refundable by the Inland Revenue Department — net of a filed return', '{}'::jsonb, 'asset_current', true, null, 130),
  ('LK', 'default', '1156', 'Withholding tax credits — certificates received', '{}'::jsonb, 'asset_current', false, null, 140),
  ('LK', 'default', '1157', 'Income tax paid in advance — instalments and self-assessment', '{}'::jsonb, 'asset_current', false, null, 150),
  ('LK', 'default', '1160', 'Advances to staff', '{}'::jsonb, 'asset_current', false, null, 160),
  ('LK', 'default', '1200', 'Inventories — goods for resale', '{}'::jsonb, 'asset_current', false, null, 170),
  ('LK', 'default', '1210', 'Inventories — raw materials', '{}'::jsonb, 'asset_current', false, null, 180),
  ('LK', 'default', '1220', 'Inventories — work in progress', '{}'::jsonb, 'asset_current', false, null, 190),
  ('LK', 'default', '1230', 'Inventories — finished goods', '{}'::jsonb, 'asset_current', false, null, 200),
  ('LK', 'default', '1300', 'Short-term investments', '{}'::jsonb, 'asset_current', false, null, 210),
  ('LK', 'default', '1350', 'Current tax recoverable', '{}'::jsonb, 'asset_current', false, null, 220),
  ('LK', 'default', '1400', 'Prepayments', '{}'::jsonb, 'asset_prepayments', false, null, 230),
  ('LK', 'default', '1410', 'Accrued income', '{}'::jsonb, 'asset_prepayments', false, null, 240),
  ('LK', 'default', '1600', 'Land and buildings — cost', '{}'::jsonb, 'asset_fixed', false, null, 250),
  ('LK', 'default', '1601', 'Land and buildings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('LK', 'default', '1610', 'Leasehold improvements — cost', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('LK', 'default', '1611', 'Leasehold improvements — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('LK', 'default', '1620', 'Plant and machinery — cost', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('LK', 'default', '1621', 'Plant and machinery — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('LK', 'default', '1630', 'Office equipment — cost', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('LK', 'default', '1631', 'Office equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('LK', 'default', '1640', 'Computers — cost', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('LK', 'default', '1641', 'Computers — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('LK', 'default', '1650', 'Furniture and fittings — cost', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('LK', 'default', '1651', 'Furniture and fittings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('LK', 'default', '1660', 'Motor vehicles — cost', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('LK', 'default', '1661', 'Motor vehicles — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 380),
  ('LK', 'default', '1670', 'Right-of-use assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 390),
  ('LK', 'default', '1671', 'Right-of-use assets — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 400),
  ('LK', 'default', '1700', 'Investment property', '{}'::jsonb, 'asset_non_current', false, null, 410),
  ('LK', 'default', '1750', 'Intangible assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 420),
  ('LK', 'default', '1751', 'Intangible assets — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 430),
  ('LK', 'default', '1760', 'Goodwill', '{}'::jsonb, 'asset_fixed', false, null, 440),
  ('LK', 'default', '1800', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 450),
  ('LK', 'default', '1810', 'Investments in joint ventures', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('LK', 'default', '1830', 'Long-term financial assets', '{}'::jsonb, 'asset_non_current', false, null, 470),
  ('LK', 'default', '1840', 'Long-term deposits', '{}'::jsonb, 'asset_non_current', false, null, 480),
  ('LK', 'default', '1900', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 490),
  ('LK', 'default', '2000', 'Trade payables', '{}'::jsonb, 'liability_payable', true, null, 500),
  ('LK', 'default', '2010', 'Accrued expenses', '{}'::jsonb, 'liability_current', false, null, 510),
  ('LK', 'default', '2020', 'Other payables', '{}'::jsonb, 'liability_current', false, null, 520),
  ('LK', 'default', '2030', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 530),
  ('LK', 'default', '2040', 'Deposits and advances received from customers', '{}'::jsonb, 'liability_current', false, null, 540),
  ('LK', 'default', '2100', 'VAT output tax', '{}'::jsonb, 'liability_current', false, null, 550),
  ('LK', 'default', '2110', 'VAT payable to the Inland Revenue Department — net of a filed return', '{}'::jsonb, 'liability_current', true, null, 560),
  ('LK', 'default', '2125', 'Import VAT payable to Sri Lanka Customs at the border', '{}'::jsonb, 'liability_current', false, null, 570),
  ('LK', 'default', '2130', 'Social Security Contribution Levy (SSCL) payable', '{}'::jsonb, 'liability_current', false, null, 580),
  ('LK', 'default', '2135', 'Stamp duty payable', '{}'::jsonb, 'liability_current', false, null, 590),
  ('LK', 'default', '2140', 'Withholding tax payable to the Inland Revenue Department', '{}'::jsonb, 'liability_current', false, null, 600),
  ('LK', 'default', '2150', 'EPF contributions payable', '{}'::jsonb, 'liability_current', false, null, 610),
  ('LK', 'default', '2155', 'ETF contributions payable', '{}'::jsonb, 'liability_current', false, null, 620),
  ('LK', 'default', '2160', 'APIT income tax payable on employment income', '{}'::jsonb, 'liability_current', false, null, 630),
  ('LK', 'default', '2165', 'Other statutory dues payable', '{}'::jsonb, 'liability_current', false, null, 640),
  ('LK', 'default', '2180', 'Salaries payable', '{}'::jsonb, 'liability_current', false, null, 650),
  ('LK', 'default', '2190', 'Directors'' fees payable', '{}'::jsonb, 'liability_current', false, null, 660),
  ('LK', 'default', '2200', 'Bank overdraft', '{}'::jsonb, 'liability_current', false, null, 670),
  ('LK', 'default', '2210', 'Bank loans — current portion', '{}'::jsonb, 'liability_current', false, null, 680),
  ('LK', 'default', '2220', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 690),
  ('LK', 'default', '2230', 'Hire purchase — current portion', '{}'::jsonb, 'liability_current', false, null, 700),
  ('LK', 'default', '2240', 'Corporate credit card', '{}'::jsonb, 'liability_credit_card', false, null, 710),
  ('LK', 'default', '2250', 'Amounts due to directors', '{}'::jsonb, 'liability_current', false, null, 720),
  ('LK', 'default', '2300', 'Current tax payable', '{}'::jsonb, 'liability_current', false, null, 730),
  ('LK', 'default', '2350', 'Provision for unutilised leave', '{}'::jsonb, 'liability_current', false, null, 740),
  ('LK', 'default', '2360', 'Other provisions — current', '{}'::jsonb, 'liability_current', false, null, 750),
  ('LK', 'default', '2400', 'Bank loans — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 760),
  ('LK', 'default', '2410', 'Lease liabilities — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 770),
  ('LK', 'default', '2420', 'Hire purchase — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 780),
  ('LK', 'default', '2430', 'Loans from shareholders and directors — non-current', '{}'::jsonb, 'liability_non_current', false, null, 790),
  ('LK', 'default', '2500', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 800),
  ('LK', 'default', '2550', 'Retirement benefit obligation — gratuity', '{}'::jsonb, 'liability_non_current', false, null, 810),
  ('LK', 'default', '2560', 'Provision for reinstatement costs', '{}'::jsonb, 'liability_non_current', false, null, 820),
  ('LK', 'default', '2990', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 830),
  ('LK', 'default', '3000', 'Stated capital', '{}'::jsonb, 'equity', false, null, 840),
  ('LK', 'default', '3010', 'Share application money pending allotment', '{}'::jsonb, 'equity', false, null, 850),
  ('LK', 'default', '3100', 'Revaluation reserve', '{}'::jsonb, 'equity', false, null, 860),
  ('LK', 'default', '3110', 'Foreign currency translation reserve', '{}'::jsonb, 'equity', false, null, 870),
  ('LK', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 880),
  ('LK', 'default', '3210', 'Dividends paid', '{}'::jsonb, 'equity_retained', false, null, 890),
  ('LK', 'default', '4000', 'Sales of goods', '{}'::jsonb, 'income', false, null, 900),
  ('LK', 'default', '4010', 'Services rendered', '{}'::jsonb, 'income', false, null, 910),
  ('LK', 'default', '4020', 'Export sales of goods', '{}'::jsonb, 'income', false, null, 920),
  ('LK', 'default', '4030', 'Export of services', '{}'::jsonb, 'income', false, null, 930),
  ('LK', 'default', '4040', 'Financial services income — fees and commissions', '{}'::jsonb, 'income', false, null, 940),
  ('LK', 'default', '4500', 'Interest income', '{}'::jsonb, 'income_other', false, null, 950),
  ('LK', 'default', '4510', 'Dividend income', '{}'::jsonb, 'income_other', false, null, 960),
  ('LK', 'default', '4520', 'Rental income', '{}'::jsonb, 'income_other', false, null, 970),
  ('LK', 'default', '4530', 'Government grants', '{}'::jsonb, 'income_other', false, null, 980),
  ('LK', 'default', '4700', 'Foreign exchange gains', '{}'::jsonb, 'income_other', false, null, 990),
  ('LK', 'default', '4750', 'Gain on disposal of property plant and equipment', '{}'::jsonb, 'income_other', false, null, 1000),
  ('LK', 'default', '4790', 'Other income', '{}'::jsonb, 'income_other', false, null, 1010),
  ('LK', 'default', '5000', 'Purchases of goods for resale', '{}'::jsonb, 'expense_direct_cost', false, null, 1020),
  ('LK', 'default', '5010', 'Freight inwards customs duty and import levies', '{}'::jsonb, 'expense_direct_cost', false, null, 1030),
  ('LK', 'default', '5020', 'Subcontract costs', '{}'::jsonb, 'expense_direct_cost', false, null, 1040),
  ('LK', 'default', '5100', 'Changes in inventories', '{}'::jsonb, 'expense_direct_cost', false, null, 1050),
  ('LK', 'default', '6000', 'Salaries and wages', '{}'::jsonb, 'expense', false, null, 1060),
  ('LK', 'default', '6010', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 1070),
  ('LK', 'default', '6020', 'Directors'' fees', '{}'::jsonb, 'expense', false, null, 1080),
  ('LK', 'default', '6030', 'EPF contributions — employer', '{}'::jsonb, 'expense', false, null, 1090),
  ('LK', 'default', '6035', 'ETF contributions — employer', '{}'::jsonb, 'expense', false, null, 1100),
  ('LK', 'default', '6040', 'Gratuity expense', '{}'::jsonb, 'expense', false, null, 1110),
  ('LK', 'default', '6045', 'Staff canteen and meals', '{}'::jsonb, 'expense', false, null, 1120),
  ('LK', 'default', '6060', 'Staff welfare', '{}'::jsonb, 'expense', false, null, 1130),
  ('LK', 'default', '6070', 'Staff medical expenses and insurance', '{}'::jsonb, 'expense', false, null, 1140),
  ('LK', 'default', '6080', 'Staff training', '{}'::jsonb, 'expense', false, null, 1150),
  ('LK', 'default', '6200', 'Depreciation of property plant and equipment', '{}'::jsonb, 'expense_depreciation', false, null, 1160),
  ('LK', 'default', '6210', 'Depreciation of right-of-use assets', '{}'::jsonb, 'expense_depreciation', false, null, 1170),
  ('LK', 'default', '6220', 'Amortisation of intangible assets', '{}'::jsonb, 'expense_depreciation', false, null, 1180),
  ('LK', 'default', '6300', 'Rent — short-term leases', '{}'::jsonb, 'expense', false, null, 1190),
  ('LK', 'default', '6310', 'Utilities', '{}'::jsonb, 'expense', false, null, 1200),
  ('LK', 'default', '6320', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 1210),
  ('LK', 'default', '6330', 'Cleaning and security services', '{}'::jsonb, 'expense', false, null, 1220),
  ('LK', 'default', '6340', 'Telephone and internet', '{}'::jsonb, 'expense', false, null, 1230),
  ('LK', 'default', '6350', 'Software subscriptions', '{}'::jsonb, 'expense', false, null, 1240),
  ('LK', 'default', '6360', 'Advertising and marketing', '{}'::jsonb, 'expense', false, null, 1250),
  ('LK', 'default', '6370', 'Travelling', '{}'::jsonb, 'expense', false, null, 1260),
  ('LK', 'default', '6380', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1270),
  ('LK', 'default', '6390', 'Entertainment', '{}'::jsonb, 'expense', false, null, 1280),
  ('LK', 'default', '6395', 'Fuel and lubricants', '{}'::jsonb, 'expense', false, null, 1290),
  ('LK', 'default', '6400', 'Subscriptions and memberships', '{}'::jsonb, 'expense', false, null, 1300),
  ('LK', 'default', '6410', 'Insurance', '{}'::jsonb, 'expense', false, null, 1310),
  ('LK', 'default', '6420', 'Professional fees', '{}'::jsonb, 'expense', false, null, 1320),
  ('LK', 'default', '6430', 'Audit fees', '{}'::jsonb, 'expense', false, null, 1330),
  ('LK', 'default', '6440', 'Company secretarial and registration fees', '{}'::jsonb, 'expense', false, null, 1340),
  ('LK', 'default', '6450', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1350),
  ('LK', 'default', '6460', 'Printing and stationery', '{}'::jsonb, 'expense', false, null, 1360),
  ('LK', 'default', '6470', 'Postage and courier', '{}'::jsonb, 'expense', false, null, 1370),
  ('LK', 'default', '6480', 'Licences permits and local authority fees', '{}'::jsonb, 'expense', false, null, 1380),
  ('LK', 'default', '6485', 'Property rates', '{}'::jsonb, 'expense', false, null, 1390),
  ('LK', 'default', '6490', 'Royalties', '{}'::jsonb, 'expense', false, null, 1400),
  ('LK', 'default', '6500', 'Bad debts written off', '{}'::jsonb, 'expense', false, null, 1410),
  ('LK', 'default', '6510', 'Impairment loss on trade receivables', '{}'::jsonb, 'expense', false, null, 1420),
  ('LK', 'default', '6700', 'Social Security Contribution Levy (SSCL)', '{}'::jsonb, 'expense', false, null, 1430),
  ('LK', 'default', '6710', 'Stamp duty', '{}'::jsonb, 'expense', false, null, 1440),
  ('LK', 'default', '6900', 'Donations', '{}'::jsonb, 'expense', false, null, 1450),
  ('LK', 'default', '6950', 'Foreign exchange losses', '{}'::jsonb, 'expense', false, null, 1460),
  ('LK', 'default', '6960', 'Loss on disposal of property plant and equipment', '{}'::jsonb, 'expense', false, null, 1470),
  ('LK', 'default', '6990', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1480),
  ('LK', 'default', '7000', 'Interest on bank loans', '{}'::jsonb, 'expense', false, null, 1490),
  ('LK', 'default', '7010', 'Interest on lease liabilities', '{}'::jsonb, 'expense', false, null, 1500),
  ('LK', 'default', '7020', 'Hire purchase interest', '{}'::jsonb, 'expense', false, null, 1510),
  ('LK', 'default', '7030', 'Interest on loans from related parties and others', '{}'::jsonb, 'expense', false, null, 1520),
  ('LK', 'default', '8000', 'Current income tax expense', '{}'::jsonb, 'expense', false, null, 1530),
  ('LK', 'default', '8010', 'Deferred tax expense', '{}'::jsonb, 'expense', false, null, 1540),
  ('LK', 'default', '8020', 'Under or over provision of income tax in prior years', '{}'::jsonb, 'expense', false, null, 1550)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('LK', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('LK', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('LK', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('LK', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('LK', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('LK', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('LK', 'LK-P-15', 'Purchase, standard rate — VAT 15 % (until 31 December 2023)', '{}'::jsonb, 'A local purchase of the period from 1 September 2022 to 31 December 2023, kept for books of those years', 'percent', 15, 'purchase', 'domestic', date '2022-09-01', date '2023-12-31', 's. 2(1)(viii) of the Value Added Tax Act, No. 14 of 2002 — fifteen per centum for taxable periods from 1 September 2022 to 31 December 2023, closed by s. 2(1)(ix). Cages I and 6.', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('LK', 'LK-P-18', 'Purchase, standard rate — VAT 18 %', '{}'::jsonb, 'A local purchase from a VAT-registered supplier whose tax is deductible as input tax', 'percent', 18, 'purchase', 'domestic', date '2024-01-01', null, 's. 2(1)(ix) of the Value Added Tax Act, No. 14 of 2002 — for any taxable period commencing on or after 1 January 2024 the tax is charged at eighteen per centum, of which the tax fraction is 9/59 (the Inland Revenue Department''s page on VAT gives the same history: 15 % from 1 September 2022 to 31 December 2023, 18 % from 1 January 2024). Return: cage I takes the value of the local purchases of Schedule 02 and cage 6 the input tax on them (quick guide ''How to file VAT'').', null, null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('LK', 'LK-P-EX', 'Purchase, exempt', '{}'::jsonb, 'A purchase of a supply the First Schedule exempts, such as bank account fees, education or electricity', 'percent', 0, 'purchase', 'exempt', date '2024-01-01', null, 's. 8 of the Value Added Tax Act, No. 14 of 2002 and Part III of the First Schedule. No tax is charged and none is deducted; the quick guide names no cage for exempt purchases, so this code reaches none.', null, null, 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('LK', 'LK-P-FIN-205', 'Purchase of financial services — VAT 20.5 %', '{}'::jsonb, 'A taxable financial service bought from a financial institution, for a taxable period commencing on or after 1 July 2026', 'percent', 20.5, 'purchase', 'domestic', date '2026-07-01', null, 'Notice SEC/PN/VAT/2026-03 of 3 July 2026, item 7 — the rate on the supply of financial services is 20.5 % for taxable periods commencing on or after 1 July 2026. The buyer deducts it as it does any input tax: cages I and 6. Financial services are charged on the value addition attributable to them, computed under Chapter IIIA of the Act by the attributable method and declared period by period; a code that applies a rate to an invoice line cannot compute that base, so it serves the fee a financial institution bills and not the value addition (docs/international.md).', null, null, 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-amend-2026', null, null, null, null),
  ('LK', 'LK-P-IMP', 'Import of goods — VAT 18 % paid at customs', '{}'::jsonb, 'Goods imported for home consumption: the VAT is paid to Sri Lanka Customs on the declaration and deducted as input tax on the monthly return', 'percent', 18, 'purchase', 'import', date '2024-01-01', null, 's. 2(1)(b) of the Value Added Tax Act, No. 14 of 2002 — the tax is charged on the importation of goods by any person at the rate of s. 2(1)(ix); s. 6(1) — the value is the customs value increased by ten per centum plus the customs duty, surcharge, cess, Ports and Airports Development Levy and excise duty, which is the importer''s to compute from the declaration and the base a line here should carry. Return: the quick guide pairs cage 5 (VAT paid up front) with Schedule 03; cage 4 (VAT deferred) is not carried because no deferral scheme is modelled. The opposite posting holds what is owed to Sri Lanka Customs on account 2125 until it is paid.', null, null, 150, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('LK', 'LK-P-ZR', 'Purchase, zero-rated', '{}'::jsonb, 'A purchase of a supply zero-rated under section 7', 'percent', 0, 'purchase', 'domestic', date '2024-01-01', null, 's. 7 of the Value Added Tax Act, No. 14 of 2002. No tax is charged, so there is none to deduct; the quick guide names no cage for the value of a zero-rated purchase, so this code reaches none.', null, null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('LK', 'LK-S-15', 'Sale, standard rate — VAT 15 % (until 31 December 2023)', '{}'::jsonb, 'The standard charge of the period from 1 September 2022 to 31 December 2023, kept for books of those years', 'percent', 15, 'sale', 'domestic', date '2022-09-01', date '2023-12-31', 's. 2(1)(viii) of the Value Added Tax Act, No. 14 of 2002 — for the period commencing on 1 September 2022 and ending on 30 September 2022 and any taxable period commencing on or after 1 October 2022 but ending on or before 31 December 2023 the tax is charged at fifteen per centum, of which the tax fraction is 3/23; the Inland Revenue Department''s page on VAT gives 15 % from 1 September 2022 to 31 December 2023. Closed on 31 December 2023 by s. 2(1)(ix). Same cages as the 18 % code: A and 0.', null, null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('LK', 'LK-S-18', 'Sale, standard rate — VAT 18 %', '{}'::jsonb, 'The standard charge on a taxable supply of goods or services made in Sri Lanka by a registered person', 'percent', 18, 'sale', 'domestic', date '2024-01-01', null, 's. 2(1)(ix) of the Value Added Tax Act, No. 14 of 2002 — for any taxable period commencing on or after 1 January 2024 the tax is charged at eighteen per centum, of which the tax fraction is 9/59 (the Inland Revenue Department''s page on VAT gives the same history: 15 % from 1 September 2022 to 31 December 2023, 18 % from 1 January 2024). Section 2(1) charges it on the value of the taxable supply in Sri Lanka; s. 5(1)(a) fixes that value as the consideration less the tax. Return: cage A takes the value and cage 0 the tax of Schedule 01 (IRD quick guide ''How to file VAT''). The Social Security Contribution Levy is a levy on the seller''s own liable turnover and has no line on the invoice: s. 5(1)(a) takes from the consideration only ''any tax chargeable under this Act'', so what the seller prices in to recover the levy stays inside the value the VAT is charged on, and this code needs no stacked posting for it. See the README.', null, null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('LK', 'LK-S-EX', 'Exempt supply — First Schedule', '{}'::jsonb, 'A supply the First Schedule exempts: educational services, public passenger transport, electricity, burial and cremation services, the listed financial services, pharmaceuticals on prescription', 'percent', 0, 'sale', 'exempt', date '2024-01-01', null, 's. 8 of the Value Added Tax Act, No. 14 of 2002 — no tax is charged on the supply of goods or services specified in the First Schedule, and such a supply is not taxable unless zero-rated under s. 7; for periods commencing on or after 1 January 2024 the list is Part III of the First Schedule (educational services; public passenger transport other than air and water transport, tourist and taxi services; electricity; burials and cremations; the financial services listed, among them the operation of a current, deposit or savings account, currency exchange, and the issue and transfer of notes, cheques and securities; pharmaceuticals bought on a physician''s prescription). The quick guide names no cage for an exempt supply, so this code reaches none; Schedule 01 does list exempted supplies (Notice SEC/PN/VAT/2026-03 of 4 May 2026, item 4).', null, null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('LK', 'LK-S-FIN-18', 'Sale of financial services — VAT 18 % (until 30 June 2026)', '{}'::jsonb, 'A taxable financial service supplied for a taxable period that began before 1 July 2026', 'percent', 18, 'sale', 'domestic', date '2024-01-01', date '2026-06-30', 's. 2(1)(ix) of the Value Added Tax Act, No. 14 of 2002 — for any taxable period commencing on or after 1 January 2024 the tax is charged at eighteen per centum, of which the tax fraction is 9/59 (the Inland Revenue Department''s page on VAT gives the same history: 15 % from 1 September 2022 to 31 December 2023, 18 % from 1 January 2024), the rate financial services bore until the rate of 20.5 % took over for taxable periods commencing on or after 1 July 2026 (Notice SEC/PN/VAT/2026-03 of 3 July 2026, item 7). The code is closed on 30 June 2026. Financial services are charged on the value addition attributable to them, computed under Chapter IIIA of the Act by the attributable method and declared period by period; a code that applies a rate to an invoice line cannot compute that base, so it serves the fee a financial institution bills and not the value addition (docs/international.md).', null, null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-amend-2026', null, null, null, null),
  ('LK', 'LK-S-FIN-205', 'Sale of financial services — VAT 20.5 %', '{}'::jsonb, 'A taxable financial service supplied for a taxable period commencing on or after 1 July 2026', 'percent', 20.5, 'sale', 'domestic', date '2026-07-01', null, 'Value Added Tax (Amendment) Act No. 14 of 2026, certified on 30 June 2026, as stated by Notice SEC/PN/VAT/2026-03 of 3 July 2026, item 7 — for any taxable period commencing on or after 1 July 2026 the rate applicable to the supply of financial services is 20.5 %; the same notice says the supply of financial services subject to VAT at that rate is exempt from the Social Security Contribution Levy (Item 25 of Part II of the First Schedule to the SSCL Act), so no levy is owed on it. Cages B and 2 are the ones the quick guide pairs with Schedule 01 beside A and 0: the pack uses them for the second rate of the period, which is an assumption (README). Financial services are charged on the value addition attributable to them, computed under Chapter IIIA of the Act by the attributable method and declared period by period; a code that applies a rate to an invoice line cannot compute that base, so it serves the fee a financial institution bills and not the value addition (docs/international.md).', null, null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-amend-2026', null, null, null, null),
  ('LK', 'LK-S-ZR-EXP', 'Export of goods, zero-rated', '{}'::jsonb, 'Goods the supplier exported and was paid for in foreign currency through a licensed bank within six months of the end of the taxable period', 'percent', 0, 'sale', 'export', date '2024-01-01', null, 's. 7(1)(a) and 7(2) of the Value Added Tax Act, No. 14 of 2002 — a supply of goods is zero-rated where the supplier has exported them and payment is received in foreign currency through a bank licensed under the Banking Act within six months from the end of the taxable period of the exportation; no tax is charged and the supply is otherwise a taxable supply at a rate of zero. s. 7(3): when that payment is late but the export is proved to the Commissioner-General, the standard rate does not apply either. Return: cage D takes the value of the article exports of Schedule 06.', null, null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('LK', 'LK-S-ZR-SVC', 'Export of services, zero-rated', '{}'::jsonb, 'A service connected with property abroad, intellectual property for use abroad, software developed for use wholly abroad or any service consumed abroad, paid for in foreign currency', 'percent', 0, 'sale', 'export', date '2024-01-01', null, 's. 7(1)(b) and (c) of the Value Added Tax Act, No. 14 of 2002 — services directly connected with property outside Sri Lanka, intellectual property for use outside Sri Lanka, software developed for use wholly outside Sri Lanka, client support services to identified clients abroad, and any other service provided to a person outside Sri Lanka to be consumed or used outside it, are zero-rated where payment in full is received in foreign currency through a licensed bank within six months from the end of the taxable period. Notice SEC/PN/VAT/2026-03 of 3 July 2026, item 2, adds the services of a garment buying office to overseas buyers from 1 October 2025. Return: cage D1 takes the value of Schedule 07.', null, null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null)
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
    ('LK-P-15', 'invoice', 'base', 100, null, 'I', array['I']::text[], 100, 'LK-VAT', 10),
    ('LK-P-15', 'invoice', 'tax', 100, '1150', '6', array['6']::text[], 100, 'LK-VAT', 20),
    ('LK-P-15', 'credit_note', 'base', 100, null, 'I', array['I']::text[], -100, 'LK-VAT', 10),
    ('LK-P-15', 'credit_note', 'tax', 100, '1150', '6', array['6']::text[], -100, 'LK-VAT', 20),
    ('LK-P-18', 'invoice', 'base', 100, null, 'I', array['I']::text[], 100, 'LK-VAT', 10),
    ('LK-P-18', 'invoice', 'tax', 100, '1150', '6', array['6']::text[], 100, 'LK-VAT', 20),
    ('LK-P-18', 'credit_note', 'base', 100, null, 'I', array['I']::text[], -100, 'LK-VAT', 10),
    ('LK-P-18', 'credit_note', 'tax', 100, '1150', '6', array['6']::text[], -100, 'LK-VAT', 20),
    ('LK-P-EX', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('LK-P-EX', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('LK-P-FIN-205', 'invoice', 'base', 100, null, 'I', array['I']::text[], 100, 'LK-VAT', 10),
    ('LK-P-FIN-205', 'invoice', 'tax', 100, '1150', '6', array['6']::text[], 100, 'LK-VAT', 20),
    ('LK-P-FIN-205', 'credit_note', 'base', 100, null, 'I', array['I']::text[], -100, 'LK-VAT', 10),
    ('LK-P-FIN-205', 'credit_note', 'tax', 100, '1150', '6', array['6']::text[], -100, 'LK-VAT', 20),
    ('LK-P-IMP', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('LK-P-IMP', 'invoice', 'tax', 100, '1151', '5', array['5']::text[], 100, 'LK-VAT', 20),
    ('LK-P-IMP', 'invoice', 'tax', -100, '2125', null, null, 100, null, 30),
    ('LK-P-IMP', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('LK-P-IMP', 'credit_note', 'tax', 100, '1151', '5', array['5']::text[], -100, 'LK-VAT', 20),
    ('LK-P-IMP', 'credit_note', 'tax', -100, '2125', null, null, 100, null, 30),
    ('LK-P-ZR', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('LK-P-ZR', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('LK-S-15', 'invoice', 'base', 100, null, 'A', array['A']::text[], 100, 'LK-VAT', 10),
    ('LK-S-15', 'invoice', 'tax', 100, '2100', '0', array['0']::text[], 100, 'LK-VAT', 20),
    ('LK-S-15', 'credit_note', 'base', 100, null, 'A', array['A']::text[], -100, 'LK-VAT', 10),
    ('LK-S-15', 'credit_note', 'tax', 100, '2100', '0', array['0']::text[], -100, 'LK-VAT', 20),
    ('LK-S-18', 'invoice', 'base', 100, null, 'A', array['A']::text[], 100, 'LK-VAT', 10),
    ('LK-S-18', 'invoice', 'tax', 100, '2100', '0', array['0']::text[], 100, 'LK-VAT', 20),
    ('LK-S-18', 'credit_note', 'base', 100, null, 'A', array['A']::text[], -100, 'LK-VAT', 10),
    ('LK-S-18', 'credit_note', 'tax', 100, '2100', '0', array['0']::text[], -100, 'LK-VAT', 20),
    ('LK-S-EX', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('LK-S-EX', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('LK-S-FIN-18', 'invoice', 'base', 100, null, 'A', array['A']::text[], 100, 'LK-VAT', 10),
    ('LK-S-FIN-18', 'invoice', 'tax', 100, '2100', '0', array['0']::text[], 100, 'LK-VAT', 20),
    ('LK-S-FIN-18', 'credit_note', 'base', 100, null, 'A', array['A']::text[], -100, 'LK-VAT', 10),
    ('LK-S-FIN-18', 'credit_note', 'tax', 100, '2100', '0', array['0']::text[], -100, 'LK-VAT', 20),
    ('LK-S-FIN-205', 'invoice', 'base', 100, null, 'B', array['B']::text[], 100, 'LK-VAT', 10),
    ('LK-S-FIN-205', 'invoice', 'tax', 100, '2100', '2', array['2']::text[], 100, 'LK-VAT', 20),
    ('LK-S-FIN-205', 'credit_note', 'base', 100, null, 'B', array['B']::text[], -100, 'LK-VAT', 10),
    ('LK-S-FIN-205', 'credit_note', 'tax', 100, '2100', '2', array['2']::text[], -100, 'LK-VAT', 20),
    ('LK-S-ZR-EXP', 'invoice', 'base', 100, null, 'D', array['D']::text[], 100, 'LK-VAT', 10),
    ('LK-S-ZR-EXP', 'credit_note', 'base', 100, null, 'D', array['D']::text[], -100, 'LK-VAT', 10),
    ('LK-S-ZR-SVC', 'invoice', 'base', 100, null, 'D1', array['D1']::text[], 100, 'LK-VAT', 10),
    ('LK-S-ZR-SVC', 'credit_note', 'base', 100, null, 'D1', array['D1']::text[], -100, 'LK-VAT', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'LK' and t.code = v.tax_code
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
  ('LK', 'LK-VAT', 'VAT return (RAMIS e-Services) and its schedules 01 to 07', array['month', 'quarter']::declaration_period[], null, date '2025-07-01', null, 's. 21(1) of the Value Added Tax Act, No. 14 of 2002 — every registered person furnishes a return, in writing or by electronic means, for each taxable period in the specified form with its schedules; s. 83 — the taxable period is a month for the persons the Act names and a quarter (January to March, April to June, July to September, October to December) for every other registered person, who may opt for quarterly returns with the Commissioner-General''s approval; the Inland Revenue Department''s page on VAT says the taxable period ''may be monthly or quarterly'' and makes e-Services filing mandatory from 1 July 2025. No cadence is declared by default because it depends on the registered person.', true,'last_day_of_month_after_period'::filing_deadline_rule, null, null, 's. 21(1)(b) of the Value Added Tax Act, No. 14 of 2002 — for a taxable period commencing on or after 1 January 2013 the return is furnished not later than the last day of the month after the expiry of the taxable period (the Inland Revenue Department''s page on VAT: ''on or before the last day of the month after the expiry of each taxable period''). The tax itself is due earlier, on or before the 20th day of the month following the end of the taxable period (s. 26(1)), and a quarterly filer pays the first two months of the quarter on the 20th of the second and third month; the core holds one deadline per return, so only the filing date is encoded and the payment date is in the README.', 'vat-act', null)
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
  ('LK', 'LK-VAT', 'A', 'base', 'Taxable supplies — value, first rate band', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Cage A of the VAT return — the value of taxable supplies computed from Schedule 01 (output schedule) plus debit notes less credit notes issued (Schedule 04, ''issued by me'' = Y). The quick guide pairs cages A and 0 and cages B and 2 with Schedule 01 and does not say which rate each takes; this pack puts the standard rate, and the 18 % of financial services before July 2026, in A and 0.', 'vat-guide'),
  ('LK', 'LK-VAT', '0', 'tax', 'Output VAT on cage A', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Cage 0 of the VAT return — the VAT on the value of cage A: the value of supply multiplied by the rate applicable on the invoice date (Schedule 01, field ''VAT Amount'').', 'vat-guide'),
  ('LK', 'LK-VAT', 'B', 'base', 'Taxable supplies — value, second rate band', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Cage B of the VAT return — the value of taxable supplies of the other rate band of Schedule 01. This pack puts the financial services at 20.5 % in B and 2, from the taxable periods commencing on or after 1 July 2026; the assignment is an assumption (README).', 'vat-guide'),
  ('LK', 'LK-VAT', '2', 'tax', 'Output VAT on cage B', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Cage 2 of the VAT return — the VAT on the value of cage B.', 'vat-guide'),
  ('LK', 'LK-VAT', 'D', 'base', 'Zero-rated supplies — exports of goods', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Cage D of the VAT return — the FOB or CIF value of the article exports of Schedule 06; zero-rated under s. 7(1)(a) of the Act.', 'vat-guide'),
  ('LK', 'LK-VAT', 'D1', 'base', 'Zero-rated supplies — services', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Cage D1 of the VAT return — the rupee value of the zero-rated services of Schedule 07; s. 7(1)(b) and (c) of the Act.', 'vat-guide'),
  ('LK', 'LK-VAT', 'OUT', 'total', 'Total output VAT', '{}'::jsonb, 70, null, array['0', '2']::text[], '{}'::text[], null, null, false, true, null, 'Not a cage of the printed return as this pack knows it: the sum of cages 0 and 2, the output tax of the period that cage 16 and cage 15 are measured against.', 'vat-guide'),
  ('LK', 'LK-VAT', 'I', 'base', 'Local purchases — value', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Cage I of the VAT return — the value of local purchases computed from Schedule 02 plus the debit notes received and less the credit notes received (Schedule 04, ''issued by me'' = N).', 'vat-guide'),
  ('LK', 'LK-VAT', '6', 'tax', 'Input VAT on local purchases', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Cage 6 of the VAT return — the input tax on the local purchases of cage I.', 'vat-guide'),
  ('LK', 'LK-VAT', '5', 'tax', 'VAT paid up front on imports', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Cage 5 of the VAT return — the total of the ''VAT upfront'' column of Schedule 03 (imports). Cage 4, the VAT deferred, is not carried.', 'vat-guide'),
  ('LK', 'LK-VAT', 'IN', 'total', 'Total input VAT', '{}'::jsonb, 110, null, array['6', '5']::text[], '{}'::text[], null, null, false, true, null, 'Not a cage of the printed return as this pack knows it: the sum of cages 6 and 5. The disallowed input tax of cage 8 is not carried — a purchase whose input tax is disallowed is booked without a tax code that deducts.', 'vat-guide'),
  ('LK', 'LK-VAT', '16', 'total', 'Net VAT payable', '{}'::jsonb, 120, null, array['OUT']::text[], array['IN']::text[], null, null, true, false, null, 'Cage 16 of the VAT return — the excess of output tax over input tax, the tax payable (Circular No. 2011/07: ''Excess of output VAT over the input VAT, i.e. tax payable, should be declared in cage 16''); the tax is paid on or before the 20th day of the month following the taxable period (s. 26 of the Act).', 'vat-circular-2011'),
  ('LK', 'LK-VAT', '15', 'total', 'Excess input VAT — carried forward or refundable', '{}'::jsonb, 130, null, array['IN']::text[], array['OUT']::text[], null, null, true, false, null, 'Cage 15 of the VAT return — the excess of input tax over output tax (Circular No. 2011/07: ''Excess of input VAT over the actual output ... a refund ... should be declared in cage 15''). Since 1 October 2025 an exporter or other eligible registered person may claim it under the Risk-Based Refund Scheme that replaced the Simplified VAT Scheme (Notice PN/VAT/2025-01); otherwise it is carried forward as input tax of the next return.', 'vat-circular-2011')
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
  ('LK-SLFRS-IS', 'LK', 'default', 'Statement of profit or loss', 'income_statement', 'IFRS-SME', date '2012-01-01', null, 'Companies Act, No. 7 of 2007, s. 151(1)(b) — the financial statements give a true and fair view of the profit or loss of the period; the standards are the SLFRS and LKAS adopted by CA Sri Lanka (Sri Lanka Accounting and Auditing Standards Act, No. 15 of 1995) and the SLFRS for SMEs. The lines are the analysis of expenses by nature that section 5 of the IFRS for SMEs allows, down to profit for the year; other comprehensive income is not booked by any account of this chart, so the statement stops at profit or loss.', 'companies-act'),
  ('LK-SLFRS-SFP', 'LK', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS-SME', date '2012-01-01', null, 'Companies Act, No. 7 of 2007, s. 150(1) — the board of every company ensures that financial statements complying with s. 151 are completed within six months of the balance sheet date; s. 151(1) — they give a true and fair view of the state of affairs at that date and of the profit or loss of the period, and s. 151(2) they comply with any regulation of form and content and with the requirements of any other law. The standards are those CA Sri Lanka adopts under the Sri Lanka Accounting and Auditing Standards Act, No. 15 of 1995 — the SLFRS and LKAS, converged with the IASB''s standards since 1 January 2012, mandatory for Specified Business Enterprises — and the SLFRS for SMEs, open to the entities that meet the smaller-entity thresholds. There is no prescribed layout: the lines below are the minimum line items of section 4 of the IFRS for SMEs on which the SLFRS for SMEs rests, which a full-SLFRS company expands under LKAS 1.', 'companies-act')
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
  ('LK-SLFRS-IS', '1', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-IS', '2', null, 'Other income', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-IS', '3', null, 'Purchases and changes in inventories', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-IS', '4', null, 'Employee benefits expense', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-IS', '5', null, 'Depreciation and amortisation', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-IS', '6', null, 'Other operating expenses', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-IS', '7', null, 'Finance costs', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-IS', '8', null, 'Profit before tax', '{}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('LK-SLFRS-IS', '9', null, 'Income tax expense', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-IS', '10', null, 'Profit for the year', '{}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, null, null),
  ('LK-SLFRS-SFP', 'CA', null, 'Current assets', '{}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5', 'CA.6']::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'CA.1', null, 'Cash and cash equivalents', '{}'::jsonb, 11, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'CA.2', null, 'Trade and other receivables', '{}'::jsonb, 12, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'CA.3', null, 'Inventories', '{}'::jsonb, 13, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'CA.4', null, 'Financial assets', '{}'::jsonb, 14, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'CA.5', null, 'Current tax recoverable', '{}'::jsonb, 15, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'CA.6', null, 'Prepayments and accrued income', '{}'::jsonb, 16, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'NCA', null, 'Non-current assets', '{}'::jsonb, 20, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4', 'NCA.5', 'NCA.6', 'NCA.7']::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'NCA.1', null, 'Property, plant and equipment', '{}'::jsonb, 21, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'NCA.2', null, 'Investment property', '{}'::jsonb, 22, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'NCA.3', null, 'Intangible assets', '{}'::jsonb, 23, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'NCA.4', null, 'Investments in associates', '{}'::jsonb, 24, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'NCA.5', null, 'Investments in joint ventures', '{}'::jsonb, 25, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'NCA.6', null, 'Financial assets', '{}'::jsonb, 26, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'NCA.7', null, 'Deferred tax assets', '{}'::jsonb, 27, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'TA', null, 'Total assets', '{}'::jsonb, 30, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'CL', null, 'Current liabilities', '{}'::jsonb, 40, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4', 'CL.5']::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'CL.1', null, 'Trade and other payables', '{}'::jsonb, 41, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'CL.2', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 42, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'CL.3', null, 'Amounts due to directors', '{}'::jsonb, 43, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'CL.4', null, 'Current tax payable', '{}'::jsonb, 44, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'CL.5', null, 'Provisions', '{}'::jsonb, 45, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'NCL', null, 'Non-current liabilities', '{}'::jsonb, 50, 1, true, array['NCL.1', 'NCL.2', 'NCL.3']::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'NCL.1', null, 'Borrowings and other financial liabilities', '{}'::jsonb, 51, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'NCL.2', null, 'Deferred tax liabilities', '{}'::jsonb, 52, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'NCL.3', null, 'Provisions', '{}'::jsonb, 53, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'TL', null, 'Total liabilities', '{}'::jsonb, 60, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'NA', null, 'Net assets', '{}'::jsonb, 70, 1, true, array['TA']::text[], array['TL']::text[], null, null, null),
  ('LK-SLFRS-SFP', 'EQ', null, 'Equity', '{}'::jsonb, 80, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'EQ.1', null, 'Share capital', '{}'::jsonb, 81, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'EQ.2', null, 'Other reserves', '{}'::jsonb, 82, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LK-SLFRS-SFP', 'EQ.3', null, 'Retained earnings', '{}'::jsonb, 83, -1, false, '{}'::text[], '{}'::text[], null, null, null)
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
    ('LK-SLFRS-IS', '1', 10, 'code_range', '4000', '4040', null, 'any'),
    ('LK-SLFRS-IS', '2', 10, 'code_range', '4500', '4790', null, 'any'),
    ('LK-SLFRS-IS', '3', 10, 'code_range', '5000', '5100', null, 'any'),
    ('LK-SLFRS-IS', '4', 10, 'code_range', '6000', '6080', null, 'any'),
    ('LK-SLFRS-IS', '5', 10, 'code_range', '6200', '6220', null, 'any'),
    ('LK-SLFRS-IS', '6', 10, 'code_range', '6300', '6990', null, 'any'),
    ('LK-SLFRS-IS', '7', 10, 'code_range', '7000', '7030', null, 'any'),
    ('LK-SLFRS-IS', '9', 10, 'code_range', '8000', '8020', null, 'any'),
    ('LK-SLFRS-SFP', 'CA.1', 10, 'code_range', '1000', '1040', null, 'any'),
    ('LK-SLFRS-SFP', 'CA.2', 10, 'code_range', '1100', '1160', null, 'any'),
    ('LK-SLFRS-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('LK-SLFRS-SFP', 'CA.4', 10, 'account_code', '1300', null, null, 'any'),
    ('LK-SLFRS-SFP', 'CA.5', 10, 'account_code', '1350', null, null, 'any'),
    ('LK-SLFRS-SFP', 'CA.6', 10, 'code_range', '1400', '1410', null, 'any'),
    ('LK-SLFRS-SFP', 'NCA.1', 10, 'code_range', '1600', '1671', null, 'any'),
    ('LK-SLFRS-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('LK-SLFRS-SFP', 'NCA.3', 10, 'code_range', '1750', '1760', null, 'any'),
    ('LK-SLFRS-SFP', 'NCA.4', 10, 'account_code', '1800', null, null, 'any'),
    ('LK-SLFRS-SFP', 'NCA.5', 10, 'account_code', '1810', null, null, 'any'),
    ('LK-SLFRS-SFP', 'NCA.6', 10, 'code_range', '1830', '1840', null, 'any'),
    ('LK-SLFRS-SFP', 'NCA.7', 10, 'account_code', '1900', null, null, 'any'),
    ('LK-SLFRS-SFP', 'CL.1', 10, 'code_range', '2000', '2190', null, 'any'),
    ('LK-SLFRS-SFP', 'CL.1', 20, 'account_code', '2990', null, null, 'credit'),
    ('LK-SLFRS-SFP', 'CL.2', 10, 'code_range', '2200', '2240', null, 'any'),
    ('LK-SLFRS-SFP', 'CL.3', 10, 'account_code', '2250', null, null, 'any'),
    ('LK-SLFRS-SFP', 'CL.4', 10, 'account_code', '2300', null, null, 'any'),
    ('LK-SLFRS-SFP', 'CL.5', 10, 'code_range', '2350', '2360', null, 'any'),
    ('LK-SLFRS-SFP', 'NCL.1', 10, 'code_range', '2400', '2430', null, 'any'),
    ('LK-SLFRS-SFP', 'NCL.2', 10, 'account_code', '2500', null, null, 'any'),
    ('LK-SLFRS-SFP', 'NCL.3', 10, 'code_range', '2550', '2560', null, 'any'),
    ('LK-SLFRS-SFP', 'EQ.1', 10, 'code_range', '3000', '3010', null, 'any'),
    ('LK-SLFRS-SFP', 'EQ.2', 10, 'code_range', '3100', '3110', null, 'any'),
    ('LK-SLFRS-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('LK', 'Sri Lanka', '{}'::jsonb, array['en']::text[], 'LKR', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, null)
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
  number_format                 = '{YY}{MM}-{CODE}-{NNNN}',
  legal_payment_days            = null,
  late_payment_reference        = null,
  numbering_legal_reference     = 'Value Added Tax Act, No. 14 of 2002, s. 20(2)(c) — a tax invoice carries the date it was issued and a serial number of at most forty characters without a space; the Tax Invoice specification of Gazette No. 2481/22, in force from 1 October 2026 (Gazette No. 2500/106), item 4.1(a) fixes the shape YYMMM_QQQQ_XXXXX, with the month as its first three letters in capitals, a code for the branch, project or customer, and a numeric serial that continues from the previous month unless the person restarts it each month or year. The law asks for a serial and not for one without a gap, which is why the style is `sequential`; the pattern vocabulary writes the month as two digits, so the three-letter month of the Gazette is a gap recorded in the README.',
  numbering_source_key          = 'gazette-2481',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Value Added Tax Act, No. 14 of 2002, s. 4(1) — goods are supplied on the earliest of the issue of an invoice, a payment including an advance, the date a payment falls due, and delivery; s. 4(3) — services on the earliest of performance, payment received, payment due and the issue of an invoice; s. 4(2) and 4(4) — an invoice issued within ten days of delivery or performance fixes the time of supply at the invoice. Ekwo''s closed vocabulary expresses only a two-way earliest-of; `earliest_of_delivery_or_payment` is the nearest value, and the gap — an invoice issued ahead of both delivery and payment, or a payment that merely falls due, which fix the time of supply in Sri Lanka — is recorded in docs/international.md and in the README of this pack.',
  tax_point_source_key          = 'vat-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No Sri Lankan text obliges a business to exchange a structured electronic invoice with another business in the sense Ekwo''s vocabulary gives the word — there is no Peppol authority, no published profile and no ISO 6523 scheme a party is addressed by — so `profile`, `party_scheme` and `vat_scheme` are null and `obligation` is `none`. What Sri Lanka has is a reporting system in the course of being built: the National e-Invoicing System announced under the National Budget 2026, whose Web API sends the invoice data of a taxpayer''s ERP to RAMIS in real time (Notice SEC/PN/VAT/2026-03 of 4 May 2026). It is a pilot, on the board for export-oriented enterprises as phase 1 and for every VAT-registered person as phase 2, with the full integration expected by the end of 2026, and it transmits the data of Schedules 01, 04 and 07; the Value Added Tax (Amendment) Act No. 14 of 2026 adds the use of secured point-of-sale machines within three months of a date still to be prescribed (Notice SEC/PN/VAT/2026-03 of 3 July 2026, item 9). Neither is in force against every taxpayer at the date of this pack, and neither is a peer-to-peer exchange between two access points. The paper-or-PDF Tax Invoice itself is regulated by Gazette No. 2481/22, postponed to 1 October 2026 by Gazette No. 2500/106 and so in force today. Ekwo does not connect to RAMIS, and the gap is recorded in docs/international.md and in this pack''s README.',
  einvoice_source_key           = 'vat-einvoicing',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_account_scheme           = 'account-number',
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'april'
 where country = 'LK';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('LK', 'tax_invoice_title', 'always', 'TAX INVOICE', '{}'::jsonb, 10, date '2026-10-01', null, 'Value Added Tax Act, No. 14 of 2002, s. 20(2)(g) — a tax invoice carries the words ''TAX INVOICE'' at a conspicuous place; Gazette No. 2481/22, Annexure I, item 1 — the title is prominent, in bold or highlighted, and the specification applies from 1 October 2026 (Gazette No. 2500/106). Item 4.2 of the Annexure says a tax invoice lists only goods or services that are subject to VAT, so an exempt supply goes on another document.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
