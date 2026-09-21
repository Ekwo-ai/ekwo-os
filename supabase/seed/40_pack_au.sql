-- Ekwo OS — Australia: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/au at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build au`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   A New Tax System (Goods and Services Tax) Act 1999 (No. 55, 1999), as compiled (Office of Parliamentary Counsel — Federal Register of Legislation)
--     https://www.legislation.gov.au/C2004A00446/latest/text
--   A New Tax System (Goods and Services Tax) Regulations 2019 (F2019L00417), as compiled (Office of Parliamentary Counsel — Federal Register of Legislation)
--     https://www.legislation.gov.au/F2019L00417/latest/text
--   Taxation Administration Act 1953, Schedule 1 — pay as you go withholding (Office of Parliamentary Counsel — Federal Register of Legislation)
--     https://www.legislation.gov.au/C1953A00001/latest/text
--   A New Tax System (Australian Business Number) Act 1999 (Office of Parliamentary Counsel — Federal Register of Legislation)
--     https://www.legislation.gov.au/C2004A00467/latest/text
--   Corporations Act 2001 (No. 50, 2001), as compiled — Chapter 2M, financial reports and audit (Office of Parliamentary Counsel — Federal Register of Legislation)
--     https://www.legislation.gov.au/C2004A00818/latest/text
--   Acts Interpretation Act 1901, s. 2B — definition of financial year (Office of Parliamentary Counsel — Federal Register of Legislation)
--     https://www.legislation.gov.au/C1901A00002/latest/text
--   Income Tax Assessment Act 1997 (Office of Parliamentary Counsel — Federal Register of Legislation)
--     https://www.legislation.gov.au/C2004A05138/latest/text
--   Payment Times Reporting Act 2020 (Office of Parliamentary Counsel — Federal Register of Legislation)
--     https://www.legislation.gov.au/C2020A00091/latest/text
--   AASB 1060 General Purpose Financial Statements – Simplified Disclosures for For-Profit and Not-for-Profit Tier 2 Entities (F2020L00288), as compiled (Australian Accounting Standards Board, made under s. 334 of the Corporations Act 2001 — Federal Register of Legislation)
--     https://www.legislation.gov.au/F2020L00288/latest/text
--   Are you a large or small proprietary company (Australian Securities and Investments Commission)
--     https://asic.gov.au/regulatory-resources/financial-reporting-and-audit/preparers-of-financial-reports/are-you-a-large-or-small-proprietary-company/
--   Business activity statement, form NAT 4189 (September 2025) (Australian Taxation Office)
--     https://www.ato.gov.au/api/public/content/f7b9a42b-8fec-4250-8c45-4c72fa7f9b8d_BUS25199Nat4189s_pdf
--   Instructions for completing your BAS (Australian Taxation Office)
--     https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/completing-your-bas-for-gst/complete-your-bas
--   Instructions for completing your BAS — Step 1: Sales (G1 to G3) (Australian Taxation Office)
--     https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/completing-your-bas-for-gst/complete-your-bas/step-1-sales
--   Instructions for completing your BAS — Step 3: Purchases (G10 and G11) (Australian Taxation Office)
--     https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/completing-your-bas-for-gst/complete-your-bas/step-3-purchases
--   Instructions for completing your BAS — Step 5: Summary (1A and 1B) (Australian Taxation Office)
--     https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/completing-your-bas-for-gst/complete-your-bas/step-5-summary
--   Instructions for completing your BAS — Step 2 and Step 4: the calculation worksheet (G4 to G9, G12 to G20) (Australian Taxation Office)
--     https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/completing-your-bas-for-gst/complete-your-bas/step-2-calculating-sales-using-the-calculation-worksheet
--   Choose a method to complete your full BAS (Australian Taxation Office)
--     https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/completing-your-bas-for-gst/choose-a-method-to-complete-your-bas
--   Identify your accounting basis (Australian Taxation Office)
--     https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/completing-your-bas-for-gst/identify-your-accounting-basis
--   Due dates for lodging and paying your BAS (Australian Taxation Office)
--     https://www.ato.gov.au/businesses-and-organisations/preparing-lodging-and-paying/business-activity-statements-bas/due-dates-for-lodging-and-paying-your-bas
--   When and how to report and pay GST (Australian Taxation Office)
--     https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/when-and-how-to-report-and-pay-gst
--   Choosing an accounting method for GST (Australian Taxation Office)
--     https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/accounting-for-gst-in-your-business/choosing-an-accounting-method
--   GST-free sales (Australian Taxation Office)
--     https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/when-to-charge-gst-and-when-not-to/gst-free-sales
--   Input-taxed sales (Australian Taxation Office)
--     https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/when-to-charge-gst-and-when-not-to/input-taxed-sales
--   Tax invoices (Australian Taxation Office)
--     https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/tax-invoices
--   Registering for GST (Australian Taxation Office)
--     https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/registering-for-gst
--   Reverse charge GST on offshore goods and services purchases (Australian Taxation Office)
--     https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/in-detail/rules-for-specific-transactions/international-transactions/reverse-charge-gst-on-offshore-goods-and-services-purchases
--   Deferred GST scheme (Australian Taxation Office)
--     https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/in-detail/rules-for-specific-transactions/international-transactions/deferred-gst
--   Pay as you go (PAYG) withholding — how to complete your activity statement labels (Australian Taxation Office)
--     https://www.ato.gov.au/businesses-and-organisations/preparing-lodging-and-paying/business-activity-statements-bas/pay-as-you-go-payg-withholding
--   Withholding if ABN is not provided (Australian Taxation Office)
--     https://www.ato.gov.au/businesses-and-organisations/hiring-and-paying-your-workers/payg-withholding/payments-you-need-to-withhold-from/withholding-from-suppliers/withholding-if-abn-not-provided
--   eInvoicing for government (Australian Taxation Office — Australian Peppol Authority)
--     https://www.ato.gov.au/businesses-and-organisations/einvoicing/einvoicing-for-government
--   PINT A-NZ Billing BIS — Peppol International specification for Australia and New Zealand (OpenPeppol, with the ATO and the New Zealand Peppol Authority)
--     https://docs.peppol.eu/poac/aunz/pint-aunz/bis/
--   Electronic Address Scheme (EAS) code list — 0151, Australian Business Number (OpenPEPPOL)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/eas/
--   UNCL5305 — duty or tax or fee category code (OpenPEPPOL — the list itself is published by UN/CEFACT)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/
--   Online services for business (Australian Taxation Office)
--     https://www.ato.gov.au/online-services/businesses-and-organisations-online-services
--   ABN Lookup (Australian Business Register)
--     https://abr.business.gov.au/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('AU', 'Australia', '0.1.0', date '2026-09-21', '20260917170000', 'community', null, null, '8329c7dffee5c6441c971619540142862424a41d03b795e138bc1bead1bf141e', '[{"key":"gst-act","title":"A New Tax System (Goods and Services Tax) Act 1999 (No. 55, 1999), as compiled","publisher":"Office of Parliamentary Counsel — Federal Register of Legislation","url":"https://www.legislation.gov.au/C2004A00446/latest/text","consulted_on":"2026-09-21","kind":"law"},{"key":"gst-regs","title":"A New Tax System (Goods and Services Tax) Regulations 2019 (F2019L00417), as compiled","publisher":"Office of Parliamentary Counsel — Federal Register of Legislation","url":"https://www.legislation.gov.au/F2019L00417/latest/text","consulted_on":"2026-09-21","kind":"regulation"},{"key":"taa-1953","title":"Taxation Administration Act 1953, Schedule 1 — pay as you go withholding","publisher":"Office of Parliamentary Counsel — Federal Register of Legislation","url":"https://www.legislation.gov.au/C1953A00001/latest/text","consulted_on":"2026-09-21","kind":"law"},{"key":"abn-act","title":"A New Tax System (Australian Business Number) Act 1999","publisher":"Office of Parliamentary Counsel — Federal Register of Legislation","url":"https://www.legislation.gov.au/C2004A00467/latest/text","consulted_on":"2026-09-21","kind":"law"},{"key":"corporations-act","title":"Corporations Act 2001 (No. 50, 2001), as compiled — Chapter 2M, financial reports and audit","publisher":"Office of Parliamentary Counsel — Federal Register of Legislation","url":"https://www.legislation.gov.au/C2004A00818/latest/text","consulted_on":"2026-09-21","kind":"law"},{"key":"aia-1901","title":"Acts Interpretation Act 1901, s. 2B — definition of financial year","publisher":"Office of Parliamentary Counsel — Federal Register of Legislation","url":"https://www.legislation.gov.au/C1901A00002/latest/text","consulted_on":"2026-09-21","kind":"law"},{"key":"itaa-1997","title":"Income Tax Assessment Act 1997","publisher":"Office of Parliamentary Counsel — Federal Register of Legislation","url":"https://www.legislation.gov.au/C2004A05138/latest/text","consulted_on":"2026-09-21","kind":"law"},{"key":"ptra-2020","title":"Payment Times Reporting Act 2020","publisher":"Office of Parliamentary Counsel — Federal Register of Legislation","url":"https://www.legislation.gov.au/C2020A00091/latest/text","consulted_on":"2026-09-21","kind":"law"},{"key":"aasb-1060","title":"AASB 1060 General Purpose Financial Statements – Simplified Disclosures for For-Profit and Not-for-Profit Tier 2 Entities (F2020L00288), as compiled","publisher":"Australian Accounting Standards Board, made under s. 334 of the Corporations Act 2001 — Federal Register of Legislation","url":"https://www.legislation.gov.au/F2020L00288/latest/text","consulted_on":"2026-09-21","kind":"standard"},{"key":"asic-proprietary","title":"Are you a large or small proprietary company","publisher":"Australian Securities and Investments Commission","url":"https://asic.gov.au/regulatory-resources/financial-reporting-and-audit/preparers-of-financial-reports/are-you-a-large-or-small-proprietary-company/","consulted_on":"2026-09-21","kind":"guidance"},{"key":"bas-form","title":"Business activity statement, form NAT 4189 (September 2025)","publisher":"Australian Taxation Office","url":"https://www.ato.gov.au/api/public/content/f7b9a42b-8fec-4250-8c45-4c72fa7f9b8d_BUS25199Nat4189s_pdf","consulted_on":"2026-09-21","kind":"form"},{"key":"bas-instructions","title":"Instructions for completing your BAS","publisher":"Australian Taxation Office","url":"https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/completing-your-bas-for-gst/complete-your-bas","consulted_on":"2026-09-21","kind":"form"},{"key":"bas-step1","title":"Instructions for completing your BAS — Step 1: Sales (G1 to G3)","publisher":"Australian Taxation Office","url":"https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/completing-your-bas-for-gst/complete-your-bas/step-1-sales","consulted_on":"2026-09-21","kind":"form"},{"key":"bas-step3","title":"Instructions for completing your BAS — Step 3: Purchases (G10 and G11)","publisher":"Australian Taxation Office","url":"https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/completing-your-bas-for-gst/complete-your-bas/step-3-purchases","consulted_on":"2026-09-21","kind":"form"},{"key":"bas-step5","title":"Instructions for completing your BAS — Step 5: Summary (1A and 1B)","publisher":"Australian Taxation Office","url":"https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/completing-your-bas-for-gst/complete-your-bas/step-5-summary","consulted_on":"2026-09-21","kind":"form"},{"key":"bas-worksheet","title":"Instructions for completing your BAS — Step 2 and Step 4: the calculation worksheet (G4 to G9, G12 to G20)","publisher":"Australian Taxation Office","url":"https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/completing-your-bas-for-gst/complete-your-bas/step-2-calculating-sales-using-the-calculation-worksheet","consulted_on":"2026-09-21","kind":"form"},{"key":"bas-method","title":"Choose a method to complete your full BAS","publisher":"Australian Taxation Office","url":"https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/completing-your-bas-for-gst/choose-a-method-to-complete-your-bas","consulted_on":"2026-09-21","kind":"guidance"},{"key":"bas-basis","title":"Identify your accounting basis","publisher":"Australian Taxation Office","url":"https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/completing-your-bas-for-gst/identify-your-accounting-basis","consulted_on":"2026-09-21","kind":"guidance"},{"key":"bas-due","title":"Due dates for lodging and paying your BAS","publisher":"Australian Taxation Office","url":"https://www.ato.gov.au/businesses-and-organisations/preparing-lodging-and-paying/business-activity-statements-bas/due-dates-for-lodging-and-paying-your-bas","consulted_on":"2026-09-21","kind":"guidance"},{"key":"gst-periods","title":"When and how to report and pay GST","publisher":"Australian Taxation Office","url":"https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/when-and-how-to-report-and-pay-gst","consulted_on":"2026-09-21","kind":"guidance"},{"key":"gst-cash","title":"Choosing an accounting method for GST","publisher":"Australian Taxation Office","url":"https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/accounting-for-gst-in-your-business/choosing-an-accounting-method","consulted_on":"2026-09-21","kind":"guidance"},{"key":"gst-free","title":"GST-free sales","publisher":"Australian Taxation Office","url":"https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/when-to-charge-gst-and-when-not-to/gst-free-sales","consulted_on":"2026-09-21","kind":"guidance"},{"key":"input-taxed","title":"Input-taxed sales","publisher":"Australian Taxation Office","url":"https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/when-to-charge-gst-and-when-not-to/input-taxed-sales","consulted_on":"2026-09-21","kind":"guidance"},{"key":"tax-invoices","title":"Tax invoices","publisher":"Australian Taxation Office","url":"https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/tax-invoices","consulted_on":"2026-09-21","kind":"guidance"},{"key":"gst-registration","title":"Registering for GST","publisher":"Australian Taxation Office","url":"https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/registering-for-gst","consulted_on":"2026-09-21","kind":"guidance"},{"key":"ato-reverse-charge","title":"Reverse charge GST on offshore goods and services purchases","publisher":"Australian Taxation Office","url":"https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/in-detail/rules-for-specific-transactions/international-transactions/reverse-charge-gst-on-offshore-goods-and-services-purchases","consulted_on":"2026-09-21","kind":"guidance"},{"key":"ato-deferred-gst","title":"Deferred GST scheme","publisher":"Australian Taxation Office","url":"https://www.ato.gov.au/businesses-and-organisations/gst-excise-and-indirect-taxes/gst/in-detail/rules-for-specific-transactions/international-transactions/deferred-gst","consulted_on":"2026-09-21","kind":"guidance"},{"key":"payg-bas","title":"Pay as you go (PAYG) withholding — how to complete your activity statement labels","publisher":"Australian Taxation Office","url":"https://www.ato.gov.au/businesses-and-organisations/preparing-lodging-and-paying/business-activity-statements-bas/pay-as-you-go-payg-withholding","consulted_on":"2026-09-21","kind":"guidance"},{"key":"no-abn-withholding","title":"Withholding if ABN is not provided","publisher":"Australian Taxation Office","url":"https://www.ato.gov.au/businesses-and-organisations/hiring-and-paying-your-workers/payg-withholding/payments-you-need-to-withhold-from/withholding-from-suppliers/withholding-if-abn-not-provided","consulted_on":"2026-09-21","kind":"guidance"},{"key":"einvoicing-government","title":"eInvoicing for government","publisher":"Australian Taxation Office — Australian Peppol Authority","url":"https://www.ato.gov.au/businesses-and-organisations/einvoicing/einvoicing-for-government","consulted_on":"2026-09-21","kind":"guidance"},{"key":"pint-aunz","title":"PINT A-NZ Billing BIS — Peppol International specification for Australia and New Zealand","publisher":"OpenPeppol, with the ATO and the New Zealand Peppol Authority","url":"https://docs.peppol.eu/poac/aunz/pint-aunz/bis/","consulted_on":"2026-09-21","kind":"standard"},{"key":"peppol-eas","title":"Electronic Address Scheme (EAS) code list — 0151, Australian Business Number","publisher":"OpenPEPPOL","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/eas/","consulted_on":"2026-09-21","kind":"standard"},{"key":"uncl5305","title":"UNCL5305 — duty or tax or fee category code","publisher":"OpenPEPPOL — the list itself is published by UN/CEFACT","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/","consulted_on":"2026-09-21","kind":"standard"},{"key":"ato-online-services","title":"Online services for business","publisher":"Australian Taxation Office","url":"https://www.ato.gov.au/online-services/businesses-and-organisations-online-services","consulted_on":"2026-09-21","kind":"portal"},{"key":"abn-lookup","title":"ABN Lookup","publisher":"Australian Business Register","url":"https://abr.business.gov.au/","consulted_on":"2026-09-21","kind":"portal"}]'::jsonb)
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
  ('AU', 'default', 'Australia reference chart of accounts', '{}'::jsonb, true, 'companies', array['AU-AASB1060-PL', 'AU-AASB1060-SFP']::text[], null, 'There is no legal chart of accounts in Australia. Corporations Act 2001, s. 286 requires a company to keep written financial records that correctly record and explain its transactions and would enable true and fair financial statements to be prepared, and prescribes none; s. 292 requires a financial report of every public company and large proprietary company, and of a small proprietary company only when its shareholders (s. 293) or ASIC (s. 294) direct it; s. 295 and s. 296 make that report comply with the accounting standards the AASB makes under s. 334. A proprietary company is large when it meets two of the thresholds of s. 45A(3) as prescribed — $50 million of consolidated revenue, $25 million of consolidated gross assets, 100 employees, for years from 1 July 2019 (ASIC). This chart is original: four digits, blocked so that each range reaches one line item of paragraph 35 of AASB 1060, whose Tier 2 simplified disclosures are what a company that has to lodge accounts but is not publicly accountable reports under; a small proprietary company that lodges nothing keeps the same books and uses the same statements as management accounts.', 'corporations-act')
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
  ('AU', 'default', '1000', 'Petty cash', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('AU', 'default', '1010', 'Business transaction account', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('AU', 'default', '1020', 'Business savings account', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('AU', 'default', '1030', 'Foreign currency account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('AU', 'default', '1040', 'Merchant card clearing account', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('AU', 'default', '1050', 'Term deposits of three months or less', '{}'::jsonb, 'asset_cash', false, null, 60),
  ('AU', 'default', '1060', 'Cash in transit', '{}'::jsonb, 'asset_cash', false, null, 70),
  ('AU', 'default', '1100', 'Trade debtors', '{}'::jsonb, 'asset_receivable', true, null, 80),
  ('AU', 'default', '1105', 'Allowance for expected credit losses', '{}'::jsonb, 'asset_current', false, null, 90),
  ('AU', 'default', '1110', 'Amounts receivable from related parties', '{}'::jsonb, 'asset_current', false, null, 100),
  ('AU', 'default', '1120', 'Other debtors', '{}'::jsonb, 'asset_current', false, null, 110),
  ('AU', 'default', '1130', 'Accrued income', '{}'::jsonb, 'asset_current', false, null, 120),
  ('AU', 'default', '1140', 'Employee advances', '{}'::jsonb, 'asset_current', false, null, 130),
  ('AU', 'default', '1150', 'GST paid — input tax credits', '{}'::jsonb, 'asset_current', false, null, 140),
  ('AU', 'default', '1152', 'GST on purchases accounted for on a cash basis — awaiting payment', '{}'::jsonb, 'asset_current', false, null, 150),
  ('AU', 'default', '1155', 'GST refund due from the ATO — net of a lodged activity statement', '{}'::jsonb, 'asset_current', true, null, 160),
  ('AU', 'default', '1200', 'Inventory — raw materials and consumables', '{}'::jsonb, 'asset_current', false, null, 170),
  ('AU', 'default', '1210', 'Inventory — work in progress', '{}'::jsonb, 'asset_current', false, null, 180),
  ('AU', 'default', '1220', 'Inventory — finished goods and goods for resale', '{}'::jsonb, 'asset_current', false, null, 190),
  ('AU', 'default', '1230', 'Goods in transit', '{}'::jsonb, 'asset_current', false, null, 200),
  ('AU', 'default', '1300', 'Term deposits of more than three months', '{}'::jsonb, 'asset_current', false, null, 210),
  ('AU', 'default', '1310', 'Listed securities held for trading', '{}'::jsonb, 'asset_current', false, null, 220),
  ('AU', 'default', '1320', 'Loans to related parties — current', '{}'::jsonb, 'asset_current', false, null, 230),
  ('AU', 'default', '1350', 'Income tax refundable', '{}'::jsonb, 'asset_current', false, null, 240),
  ('AU', 'default', '1400', 'Prepayments', '{}'::jsonb, 'asset_prepayments', false, null, 250),
  ('AU', 'default', '1410', 'Deposits paid', '{}'::jsonb, 'asset_prepayments', false, null, 260),
  ('AU', 'default', '1420', 'Payments on account to suppliers', '{}'::jsonb, 'asset_prepayments', false, null, 270),
  ('AU', 'default', '1600', 'Land', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('AU', 'default', '1610', 'Buildings', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('AU', 'default', '1611', 'Buildings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('AU', 'default', '1620', 'Leasehold improvements', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('AU', 'default', '1621', 'Leasehold improvements — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('AU', 'default', '1630', 'Plant and equipment', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('AU', 'default', '1631', 'Plant and equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('AU', 'default', '1640', 'Office furniture and equipment', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('AU', 'default', '1641', 'Office furniture and equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('AU', 'default', '1650', 'Computer equipment', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('AU', 'default', '1651', 'Computer equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 380),
  ('AU', 'default', '1660', 'Motor vehicles', '{}'::jsonb, 'asset_fixed', false, null, 390),
  ('AU', 'default', '1661', 'Motor vehicles — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 400),
  ('AU', 'default', '1670', 'Right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 410),
  ('AU', 'default', '1671', 'Right-of-use assets — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 420),
  ('AU', 'default', '1680', 'Capital works in progress', '{}'::jsonb, 'asset_fixed', false, null, 430),
  ('AU', 'default', '1700', 'Investment property', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('AU', 'default', '1750', 'Goodwill', '{}'::jsonb, 'asset_fixed', false, null, 450),
  ('AU', 'default', '1751', 'Goodwill — accumulated impairment', '{}'::jsonb, 'asset_fixed', false, null, 460),
  ('AU', 'default', '1760', 'Software and development costs', '{}'::jsonb, 'asset_fixed', false, null, 470),
  ('AU', 'default', '1761', 'Software and development costs — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 480),
  ('AU', 'default', '1770', 'Patents, trade marks and licences', '{}'::jsonb, 'asset_fixed', false, null, 490),
  ('AU', 'default', '1771', 'Patents, trade marks and licences — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 500),
  ('AU', 'default', '1800', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 510),
  ('AU', 'default', '1810', 'Investments in joint ventures', '{}'::jsonb, 'asset_non_current', false, null, 520),
  ('AU', 'default', '1820', 'Shares in unlisted entities', '{}'::jsonb, 'asset_non_current', false, null, 530),
  ('AU', 'default', '1830', 'Loans to related parties — non-current', '{}'::jsonb, 'asset_non_current', false, null, 540),
  ('AU', 'default', '1840', 'Security deposits — non-current', '{}'::jsonb, 'asset_non_current', false, null, 550),
  ('AU', 'default', '1900', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 560),
  ('AU', 'default', '2000', 'Trade creditors', '{}'::jsonb, 'liability_payable', true, null, 570),
  ('AU', 'default', '2010', 'Accrued expenses', '{}'::jsonb, 'liability_current', false, null, 580),
  ('AU', 'default', '2020', 'Amounts payable to related parties', '{}'::jsonb, 'liability_current', false, null, 590),
  ('AU', 'default', '2030', 'Other creditors', '{}'::jsonb, 'liability_current', false, null, 600),
  ('AU', 'default', '2040', 'Customer deposits and contract liabilities', '{}'::jsonb, 'liability_current', false, null, 610),
  ('AU', 'default', '2050', 'Wages payable', '{}'::jsonb, 'liability_current', false, null, 620),
  ('AU', 'default', '2060', 'Superannuation guarantee contributions payable', '{}'::jsonb, 'liability_current', false, null, 630),
  ('AU', 'default', '2070', 'Payroll tax payable', '{}'::jsonb, 'liability_current', false, null, 640),
  ('AU', 'default', '2080', 'Dividends payable', '{}'::jsonb, 'liability_current', false, null, 650),
  ('AU', 'default', '2100', 'GST collected on sales', '{}'::jsonb, 'liability_current', false, null, 660),
  ('AU', 'default', '2105', 'GST on sales accounted for on a cash basis — awaiting payment', '{}'::jsonb, 'liability_current', false, null, 670),
  ('AU', 'default', '2110', 'Activity statement payable to the ATO — net of a lodged statement', '{}'::jsonb, 'liability_current', true, null, 680),
  ('AU', 'default', '2115', 'Deferred GST on imported goods', '{}'::jsonb, 'liability_current', false, null, 690),
  ('AU', 'default', '2120', 'PAYG withholding payable', '{}'::jsonb, 'liability_current', false, null, 700),
  ('AU', 'default', '2130', 'Fringe benefits tax payable', '{}'::jsonb, 'liability_current', false, null, 710),
  ('AU', 'default', '2200', 'Bank overdraft', '{}'::jsonb, 'liability_current', false, null, 720),
  ('AU', 'default', '2210', 'Business credit card', '{}'::jsonb, 'liability_credit_card', false, null, 730),
  ('AU', 'default', '2220', 'Bank loans — current', '{}'::jsonb, 'liability_current', false, null, 740),
  ('AU', 'default', '2230', 'Lease liabilities — current', '{}'::jsonb, 'liability_current', false, null, 750),
  ('AU', 'default', '2240', 'Hire purchase and chattel mortgage — current', '{}'::jsonb, 'liability_current', false, null, 760),
  ('AU', 'default', '2300', 'Income tax payable', '{}'::jsonb, 'liability_current', false, null, 770),
  ('AU', 'default', '2350', 'Provision for annual leave', '{}'::jsonb, 'liability_current', false, null, 780),
  ('AU', 'default', '2360', 'Provision for long service leave — current', '{}'::jsonb, 'liability_current', false, null, 790),
  ('AU', 'default', '2370', 'Provision for warranties and other provisions — current', '{}'::jsonb, 'liability_current', false, null, 800),
  ('AU', 'default', '2400', 'Bank loans — non-current', '{}'::jsonb, 'liability_non_current', false, null, 810),
  ('AU', 'default', '2410', 'Lease liabilities — non-current', '{}'::jsonb, 'liability_non_current', false, null, 820),
  ('AU', 'default', '2420', 'Hire purchase and chattel mortgage — non-current', '{}'::jsonb, 'liability_non_current', false, null, 830),
  ('AU', 'default', '2430', 'Loans from shareholders and related parties — non-current', '{}'::jsonb, 'liability_non_current', false, null, 840),
  ('AU', 'default', '2500', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 850),
  ('AU', 'default', '2550', 'Provision for long service leave — non-current', '{}'::jsonb, 'liability_non_current', false, null, 860),
  ('AU', 'default', '2560', 'Provision for make good and restoration', '{}'::jsonb, 'liability_non_current', false, null, 870),
  ('AU', 'default', '2990', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 880),
  ('AU', 'default', '3000', 'Issued capital — ordinary shares', '{}'::jsonb, 'equity', false, null, 890),
  ('AU', 'default', '3010', 'Issued capital — preference shares', '{}'::jsonb, 'equity', false, null, 900),
  ('AU', 'default', '3100', 'Asset revaluation reserve', '{}'::jsonb, 'equity', false, null, 910),
  ('AU', 'default', '3110', 'Other reserves', '{}'::jsonb, 'equity', false, null, 920),
  ('AU', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 930),
  ('AU', 'default', '3210', 'Dividends paid', '{}'::jsonb, 'equity_retained', false, null, 940),
  ('AU', 'default', '4000', 'Sales — goods', '{}'::jsonb, 'income', false, null, 950),
  ('AU', 'default', '4010', 'Sales — services', '{}'::jsonb, 'income', false, null, 960),
  ('AU', 'default', '4020', 'Sales — GST-free goods and services', '{}'::jsonb, 'income', false, null, 970),
  ('AU', 'default', '4030', 'Sales — exports', '{}'::jsonb, 'income', false, null, 980),
  ('AU', 'default', '4040', 'Residential rental income', '{}'::jsonb, 'income', false, null, 990),
  ('AU', 'default', '4050', 'Retail takings', '{}'::jsonb, 'income', false, null, 1000),
  ('AU', 'default', '4080', 'Sales returns and allowances', '{}'::jsonb, 'income', false, null, 1010),
  ('AU', 'default', '4090', 'Discounts allowed', '{}'::jsonb, 'income', false, null, 1020),
  ('AU', 'default', '4500', 'Interest income', '{}'::jsonb, 'income_other', false, null, 1030),
  ('AU', 'default', '4510', 'Commercial rental income', '{}'::jsonb, 'income_other', false, null, 1040),
  ('AU', 'default', '4520', 'Government grants', '{}'::jsonb, 'income_other', false, null, 1050),
  ('AU', 'default', '4530', 'Sundry income', '{}'::jsonb, 'income_other', false, null, 1060),
  ('AU', 'default', '4700', 'Foreign exchange gains', '{}'::jsonb, 'income_other', false, null, 1070),
  ('AU', 'default', '4750', 'Gain on disposal of non-current assets', '{}'::jsonb, 'income_other', false, null, 1080),
  ('AU', 'default', '5000', 'Purchases — goods for resale', '{}'::jsonb, 'expense_direct_cost', false, null, 1090),
  ('AU', 'default', '5010', 'Purchases — raw materials and consumables', '{}'::jsonb, 'expense_direct_cost', false, null, 1100),
  ('AU', 'default', '5020', 'Freight and cartage inwards', '{}'::jsonb, 'expense_direct_cost', false, null, 1110),
  ('AU', 'default', '5030', 'Customs duty and import charges', '{}'::jsonb, 'expense_direct_cost', false, null, 1120),
  ('AU', 'default', '5040', 'Changes in inventories', '{}'::jsonb, 'expense_direct_cost', false, null, 1130),
  ('AU', 'default', '5100', 'Subcontractors', '{}'::jsonb, 'expense_direct_cost', false, null, 1140),
  ('AU', 'default', '6000', 'Wages and salaries', '{}'::jsonb, 'expense', false, null, 1150),
  ('AU', 'default', '6010', 'Directors'' fees', '{}'::jsonb, 'expense', false, null, 1160),
  ('AU', 'default', '6020', 'Superannuation contributions', '{}'::jsonb, 'expense', false, null, 1170),
  ('AU', 'default', '6030', 'Payroll tax', '{}'::jsonb, 'expense', false, null, 1180),
  ('AU', 'default', '6040', 'Workers'' compensation insurance', '{}'::jsonb, 'expense', false, null, 1190),
  ('AU', 'default', '6050', 'Annual and long service leave expense', '{}'::jsonb, 'expense', false, null, 1200),
  ('AU', 'default', '6060', 'Fringe benefits tax', '{}'::jsonb, 'expense', false, null, 1210),
  ('AU', 'default', '6070', 'Staff training and amenities', '{}'::jsonb, 'expense', false, null, 1220),
  ('AU', 'default', '6200', 'Depreciation — buildings and leasehold improvements', '{}'::jsonb, 'expense_depreciation', false, null, 1230),
  ('AU', 'default', '6210', 'Depreciation — plant, equipment and motor vehicles', '{}'::jsonb, 'expense_depreciation', false, null, 1240),
  ('AU', 'default', '6220', 'Depreciation — right-of-use assets', '{}'::jsonb, 'expense_depreciation', false, null, 1250),
  ('AU', 'default', '6230', 'Amortisation of intangible assets', '{}'::jsonb, 'expense_depreciation', false, null, 1260),
  ('AU', 'default', '6300', 'Rent and outgoings', '{}'::jsonb, 'expense', false, null, 1270),
  ('AU', 'default', '6310', 'Electricity, gas and water', '{}'::jsonb, 'expense', false, null, 1280),
  ('AU', 'default', '6320', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 1290),
  ('AU', 'default', '6330', 'Insurance', '{}'::jsonb, 'expense', false, null, 1300),
  ('AU', 'default', '6340', 'Telephone and internet', '{}'::jsonb, 'expense', false, null, 1310),
  ('AU', 'default', '6350', 'Software subscriptions', '{}'::jsonb, 'expense', false, null, 1320),
  ('AU', 'default', '6360', 'Advertising and marketing', '{}'::jsonb, 'expense', false, null, 1330),
  ('AU', 'default', '6370', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1340),
  ('AU', 'default', '6380', 'Travel and accommodation', '{}'::jsonb, 'expense', false, null, 1350),
  ('AU', 'default', '6390', 'Entertainment', '{}'::jsonb, 'expense', false, null, 1360),
  ('AU', 'default', '6400', 'Accounting and audit fees', '{}'::jsonb, 'expense', false, null, 1370),
  ('AU', 'default', '6410', 'Legal and professional fees', '{}'::jsonb, 'expense', false, null, 1380),
  ('AU', 'default', '6420', 'Consulting fees', '{}'::jsonb, 'expense', false, null, 1390),
  ('AU', 'default', '6430', 'Bank fees and merchant charges', '{}'::jsonb, 'expense', false, null, 1400),
  ('AU', 'default', '6440', 'Printing, postage and stationery', '{}'::jsonb, 'expense', false, null, 1410),
  ('AU', 'default', '6450', 'Subscriptions and memberships', '{}'::jsonb, 'expense', false, null, 1420),
  ('AU', 'default', '6460', 'Bad debts and expected credit losses', '{}'::jsonb, 'expense', false, null, 1430),
  ('AU', 'default', '6470', 'Donations', '{}'::jsonb, 'expense', false, null, 1440),
  ('AU', 'default', '6480', 'Council rates and land tax', '{}'::jsonb, 'expense', false, null, 1450),
  ('AU', 'default', '6490', 'Sundry expenses', '{}'::jsonb, 'expense', false, null, 1460),
  ('AU', 'default', '6950', 'Foreign exchange losses', '{}'::jsonb, 'expense', false, null, 1470),
  ('AU', 'default', '6960', 'Loss on disposal of non-current assets', '{}'::jsonb, 'expense', false, null, 1480),
  ('AU', 'default', '6990', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1490),
  ('AU', 'default', '7000', 'Interest on bank loans and overdraft', '{}'::jsonb, 'expense', false, null, 1500),
  ('AU', 'default', '7010', 'Interest on lease liabilities', '{}'::jsonb, 'expense', false, null, 1510),
  ('AU', 'default', '7020', 'Hire purchase and chattel mortgage interest', '{}'::jsonb, 'expense', false, null, 1520),
  ('AU', 'default', '7030', 'General interest charge', '{}'::jsonb, 'expense', false, null, 1530),
  ('AU', 'default', '8000', 'Income tax expense — current', '{}'::jsonb, 'expense', false, null, 1540),
  ('AU', 'default', '8010', 'Income tax expense — deferred', '{}'::jsonb, 'expense', false, null, 1550),
  ('AU', 'default', '8020', 'Income tax — under or over provision of prior years', '{}'::jsonb, 'expense', false, null, 1560)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('AU', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('AU', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('AU', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('AU', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('AU', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('AU', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('AU', 'AU-P-DGST', 'Importation of goods, deferred GST 10 %', '{}'::jsonb, null, 'percent', 10, 'purchase', 'import', date '2000-07-01', null, 'A New Tax System (Goods and Services Tax) Act 1999, s. 13-20 — GST on a taxable importation is 10 % of its value, the customs value plus international transport, insurance and duty; s. 33-15(1)(b) and the GST Regulations 2019, ss. 33-15.01A and 33-15.01B, let an approved importer that lodges monthly pay it with its activity statement instead of at the border. ATO, Deferred GST scheme, has the ATO prefill label 7A and the importer claim the credit at 1B in the same month, and reports the importation at G11. The base here is the value on the supplier''s invoice; the value of the importation on which the ABF computed the GST is on the import declaration, and a difference between the two is a line of its own.', null, null, 230, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'ato-deferred-gst', null, null, null, null),
  ('AU', 'AU-P-FRE', 'Purchase, GST-free', '{}'::jsonb, null, 'percent', 0, 'purchase', 'domestic', date '2000-07-01', null, 'A New Tax System (Goods and Services Tax) Act 1999, Division 38 — the supplier charged no GST, so there is none to claim; ATO, Instructions for completing your BAS, step 3, reports the value at G11 all the same.', 'Z', null, 180, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('AU', 'AU-P-GST', 'Purchase, GST 10 %', '{}'::jsonb, null, 'percent', 10, 'purchase', 'domestic', date '2000-07-01', null, 'A New Tax System (Goods and Services Tax) Act 1999, s. 11-20 and s. 11-25 — the input tax credit on a creditable acquisition is the GST payable on the supply; s. 29-10 attributes it to the period in which an invoice is issued or any consideration provided, and s. 29-10(3) requires a tax invoice before it is claimed, except for a supply whose value does not exceed $75 under s. 29-80 and the GST Regulations 2019, s. 29-80.01 — $82.50 with the GST in it. Reported at G11 and 1B.', 'S', null, 130, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('AU', 'AU-P-GST-CAP', 'Capital purchase, GST 10 %', '{}'::jsonb, null, 'percent', 10, 'purchase', 'domestic', date '2000-07-01', null, 'The same credit as AU-P-GST, on a capital acquisition — machinery, computers, vehicles, land and buildings — which the business activity statement reports at G10 instead of G11 (ATO, Instructions for completing your BAS, step 3). A business whose GST turnover is expected to be under $1 million and that does not record the two apart may report capital items of $1,000 or less at G11.', 'S', null, 140, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'bas-step3', null, null, null, null),
  ('AU', 'AU-P-GST-CASH', 'Purchase, GST 10 %, accounted for on a cash basis', '{}'::jsonb, null, 'percent', 10, 'purchase', 'domestic', date '2000-07-01', null, 'A New Tax System (Goods and Services Tax) Act 1999, s. 29-10(2) — an entity that accounts on a cash basis attributes an input tax credit to the tax period in which it provides the consideration, and only to the extent it provides it; s. 29-40 for who may choose it, as on the sale side. The condition is the purchasing company''s own turnover, which no word of `conditions` names for a purchase, so the reference carries it.', 'S', null, 150, 'gst', true, '{}'::tax_condition[], null, false, true, '1152', 'gst-act', null, null, null, null),
  ('AU', 'AU-P-GST-ITS', 'Purchase, GST 10 %, not creditable — relates to input-taxed supplies', '{}'::jsonb, null, 'percent', 10, 'purchase', 'domestic', date '2000-07-01', null, 'A New Tax System (Goods and Services Tax) Act 1999, s. 11-15(2)(a) — a thing is not acquired for a creditable purpose to the extent the acquisition relates to making supplies that would be input taxed, residential rent and financial supplies among them; s. 11-15(4) lifts the restriction for financial supplies where the financial acquisitions threshold is not exceeded. A purchase used partly for each needs an apportionment the pack does not carry. The GST follows the account of the line; the value is reported at G11.', 'S', null, 170, 'gst', false, '{}'::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('AU', 'AU-P-GST-NCI', 'Purchase, GST 10 %, not creditable — non-deductible expense', '{}'::jsonb, null, 'percent', 10, 'purchase', 'domestic', date '2000-07-01', null, 'A New Tax System (Goods and Services Tax) Act 1999, s. 69-5 — an acquisition is not a creditable acquisition to the extent it is a non-deductible expense, which s. 69-5(3)(f) extends to the entertainment expenses Division 32 of the Income Tax Assessment Act 1997 makes non-deductible, beside penalties, recreational club expenses and the other items of s. 69-5(3). The GST is part of what the thing cost, so it lands on the account of the line and 1B stays empty; the value is still reported at G11.', 'S', null, 160, 'gst', false, '{}'::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('AU', 'AU-P-ITS', 'Purchase, input taxed', '{}'::jsonb, null, 'percent', 0, 'purchase', 'exempt', date '2000-07-01', null, 'A New Tax System (Goods and Services Tax) Act 1999, Division 40 — an input-taxed supply carries no GST, bank fees and residential rent among them; the value is reported at G11.', 'E', null, 190, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('AU', 'AU-P-NOABN-47', 'Purchase from a supplier who does not quote an ABN — 47 % withheld', '{}'::jsonb, null, 'percent', 47, 'purchase', 'not_subject', date '2017-07-01', null, 'Taxation Administration Act 1953, Schedule 1, s. 12-190 — a payer withholds an amount from a payment for a supply made in the course of an enterprise carried on in Australia when the supplier does not quote its ABN, unless an exception of the section applies — among them, under s. 12-190(4)(b), a payment of no more than $50 without GST or the higher amount the regulations specify, which ATO, Withholding if ABN is not provided, gives as $75; s. 16-70 — the amount withheld is paid to the Commissioner. ATO, Pay as you go (PAYG) withholding, sets the amount at 47 % of the invoice amount from 1 July 2017 and reports it at W4; the rates before that day are not carried. The supplier is paid the rest, the withheld amount waits on 2120, and the purchase itself, on which a supplier with no ABN charged no GST, is reported at G11.', null, null, 240, 'withholding', true, '{}'::tax_condition[], null, false, false, null, 'taa-1953', null, null, null, null),
  ('AU', 'AU-P-NOGST', 'Purchase with no GST in the price', '{}'::jsonb, null, 'percent', 0, 'purchase', 'not_subject', date '2000-07-01', null, 'A New Tax System (Goods and Services Tax) Act 1999, s. 9-5 — a supply by an entity that is not registered or required to be registered, or one not connected with Australia, is not a taxable supply, and neither are most Australian taxes, fees and charges (Division 81). ATO, Instructions for completing your BAS, step 3, reports the value at G11.', 'O', null, 200, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('AU', 'AU-P-RC-AGREED', 'Supply by a non-resident reverse charged by agreement, GST 10 %', '{}'::jsonb, null, 'percent', 10, 'purchase', 'foreign_services_received', date '2000-07-01', null, 'A New Tax System (Goods and Services Tax) Act 1999, s. 83-5 — the GST on a taxable supply by a non-resident who does not make it through an enterprise carried on in Australia is payable by the registered recipient where the two agree; the recipient claims the credit it is entitled to without holding a tax invoice (ATO, Reverse charge GST on offshore goods and services purchases). Reported at 1A and 1B, and the purchase at G1 and G11.', null, null, 220, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('AU', 'AU-P-RC-ITS', 'Offshore supply reverse charged, GST 10 %, not creditable', '{}'::jsonb, null, 'percent', 10, 'purchase', 'foreign_services_received', date '2000-07-01', null, 'A New Tax System (Goods and Services Tax) Act 1999, s. 84-5 — a supply of anything other than goods or real property that is not connected with Australia is taxable if the registered recipient acquires it for an enterprise it carries on in Australia and not solely for a creditable purpose (s. 84-5(1A)); s. 84-10 makes the recipient liable for the GST, and s. 84-12 sets it at 10 % of the price. The reverse charge therefore reaches the business that cannot claim the whole credit: this code is the one that can claim none, because the acquisition relates to its input-taxed supplies (s. 11-15(2)(a)). ATO, Reverse charge GST on offshore goods and services purchases, reports the GST at 1A and the purchase at G1 and at G11; the ATO asks for the price multiplied by 1.1 at those two labels, and this pack reports the price without GST there, as its choice at G1 requires. The GST follows the account of the line.', null, null, 210, 'gst', false, '{}'::tax_condition[], null, false, false, null, 'ato-reverse-charge', null, null, null, null),
  ('AU', 'AU-S-EXPORT', 'Export of goods, GST-free', '{}'::jsonb, null, 'percent', 0, 'sale', 'export', date '2000-07-01', null, 'A New Tax System (Goods and Services Tax) Act 1999, s. 38-185(1), item 1 — a supply of goods is GST-free if the supplier exports them from Australia before, or within 60 days after, the earlier of the day it receives any of the consideration and the day it issues an invoice. ATO, Instructions for completing your BAS, step 1, reports the free-on-board value at G2 and at G1, and the freight and insurance for the export at G3; the pack posts the whole line to G1 and G2 and cannot split it, so a line of freight on an export invoice should carry AU-S-FRE.', 'G', null, 80, 'gst', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('AU', 'AU-S-EXPORT-SERV', 'Supply for consumption outside Australia, GST-free', '{}'::jsonb, null, 'percent', 0, 'sale', 'export', date '2000-07-01', null, 'A New Tax System (Goods and Services Tax) Act 1999, s. 38-190 — a supply of a thing other than goods or real property is GST-free where the table of s. 38-190(1) covers it, typically a supply to a non-resident who is not in Australia when it is supplied. ATO, Instructions for completing your BAS, step 1, keeps services out of G2, so the value is reported at G1 and G3. The EN 16931 category is G, the one PINT A-NZ gives an export.', 'G', null, 90, 'gst', true, array['buyer_status']::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('AU', 'AU-S-FRE', 'Sale, GST-free, other', '{}'::jsonb, null, 'percent', 0, 'sale', 'domestic', date '2000-07-01', null, 'A New Tax System (Goods and Services Tax) Act 1999, Division 38 — the other GST-free supplies: child care, religious services, water, sewerage and drainage, the supply of a going concern (s. 38-325), international transport (s. 38-355), precious metals, farm land and the rest the Division lists. Reported at G1 and G3. A code for the supplies the three above do not name; which provision applies is a fact about the supply that the ledger does not hold.', 'Z', null, 70, 'gst', true, array['supply_nature']::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('AU', 'AU-S-FRE-EDU', 'Sale of an education course, GST-free', '{}'::jsonb, null, 'percent', 0, 'sale', 'domestic', date '2000-07-01', null, 'A New Tax System (Goods and Services Tax) Act 1999, Subdivision 38-C — s. 38-85, a supply of an education course, and of administrative services directly related to it by the supplier of the course, is GST-free; ss. 38-90 to 38-110 for excursions, course materials and what is not GST-free. Reported at G1 and G3.', 'Z', null, 60, 'gst', true, array['supply_nature']::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('AU', 'AU-S-FRE-FOOD', 'Sale of food, GST-free', '{}'::jsonb, null, 'percent', 0, 'sale', 'domestic', date '2000-07-01', null, 'A New Tax System (Goods and Services Tax) Act 1999, s. 38-2 — a supply of food is GST-free; s. 38-3 excludes food for consumption on the premises, hot food, the prepared foods, confectionery, snacks, bakery products, ice-cream foods and biscuits of Schedule 1, and beverages other than those of Schedule 2. ATO, Instructions for completing your BAS, step 1, reports the sale at G1 and G3. A GST-free supply is a taxable supply at a nil charge, not an exempt one: the credits on what went into it stay claimable.', 'Z', null, 40, 'gst', true, array['supply_nature']::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('AU', 'AU-S-FRE-HEALTH', 'Sale of health services, GST-free', '{}'::jsonb, null, 'percent', 0, 'sale', 'domestic', date '2000-07-01', null, 'A New Tax System (Goods and Services Tax) Act 1999, Subdivision 38-B — s. 38-7, a medical service is GST-free except where it is rendered for cosmetic reasons with no Medicare benefit payable, and ss. 38-10 to 38-60 for other health services, hospital treatment, residential and home care, medical aids and appliances and drugs. Reported at G1 and G3.', 'Z', null, 50, 'gst', true, array['supply_nature']::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('AU', 'AU-S-GST', 'Sale, GST 10 %', '{}'::jsonb, 'A taxable supply made in Australia', 'percent', 10, 'sale', 'domestic', date '2000-07-01', null, 'A New Tax System (Goods and Services Tax) Act 1999, s. 9-70 — the amount of GST on a taxable supply is 10 % of its value; s. 9-75 — the value is the price less the GST, one eleventh of a GST-inclusive price; s. 1-2 — the Act commences on 1 July 2000, and the rate has not moved since. The base is reported at G1 without GST under the accounts method and the GST at 1A.', 'S', null, 10, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('AU', 'AU-S-GST-CASH', 'Sale, GST 10 %, accounted for on a cash basis', '{}'::jsonb, null, 'percent', 10, 'sale', 'domestic', date '2000-07-01', null, 'A New Tax System (Goods and Services Tax) Act 1999, s. 29-5(2) — an entity that accounts on a cash basis attributes the GST on a taxable supply to the tax period in which the consideration is received, and only to the extent it is received; s. 29-40(1) — the choice is open to a small business entity, to an entity that does not carry on a business and has a GST turnover of $2 million or less, and to an entity that accounts for income tax on receipts, and s. 29-45 lets the Commissioner permit any other. ATO, Choosing an accounting method for GST, puts the small business entity at an aggregated turnover below $10 million. The choice is the entity''s and covers all its supplies and acquisitions; the pack carries it as a code, and nothing stops a company on the accruals basis from choosing it.', 'S', null, 30, 'gst', true, array['seller_threshold']::tax_condition[], null, false, true, '2105', 'gst-act', null, null, null, null),
  ('AU', 'AU-S-GST-INC', 'Retail sale, GST 10 %, the price includes the GST', '{}'::jsonb, 'For a price set with the GST already in it, as a shelf price is', 'percent', 10, 'sale', 'domestic', date '2000-07-01', null, 'A New Tax System (Goods and Services Tax) Act 1999, s. 9-70 — the amount of GST on a taxable supply is 10 % of its value; s. 9-75 — the value is the price less the GST, one eleventh of a GST-inclusive price; s. 1-2 — the Act commences on 1 July 2000, and the rate has not moved since. A retail price in Australia is quoted with the GST in it; price_include records that the unit price of a line is the GST-inclusive price, from which the engine takes one eleventh out, rounded under s. 9-90 — to the nearest cent, half a cent upwards.', 'S', null, 20, 'gst', true, '{}'::tax_condition[], null, true, false, null, 'gst-act', null, null, null, null),
  ('AU', 'AU-S-ITS-FIN', 'Financial supply, input taxed', '{}'::jsonb, null, 'percent', 0, 'sale', 'exempt', date '2000-07-01', null, 'A New Tax System (Goods and Services Tax) Act 1999, s. 40-5 — a financial supply is input taxed, and the GST Regulations 2019, s. 40-5.09, say what a financial supply is: lending, credit for a fee, interests in securities and the like. An input-taxed supply carries no GST and gives no credit for what went into it (s. 11-15(2)(a)). It is reported at G1; the worksheet label G4 where it would also sit is not reported under the accounts method. No exemption reason code: VATEX names articles of a Directive that does not bind an Australian supplier.', 'E', null, 100, 'gst', true, array['supply_nature']::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('AU', 'AU-S-ITS-RES', 'Residential rent, input taxed', '{}'::jsonb, null, 'percent', 0, 'sale', 'exempt', date '2000-07-01', null, 'A New Tax System (Goods and Services Tax) Act 1999, s. 40-35 — a supply of residential premises by way of lease, hire or licence is input taxed, other than commercial residential premises and accommodation in them. Reported at G1.', 'E', null, 110, 'gst', true, array['supply_nature']::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('AU', 'AU-S-NCA', 'Supply not connected with Australia', '{}'::jsonb, null, 'percent', 0, 'sale', 'not_subject', date '2000-07-01', null, 'A New Tax System (Goods and Services Tax) Act 1999, s. 9-5 — a supply is taxable only if it is connected with the indirect tax zone, which s. 9-25 defines. ATO, Instructions for completing your BAS, step 1, lists amounts received for sales not connected with Australia among what is not reported at G1, so the base names no box.', 'O', null, 120, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null)
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
    ('AU-P-DGST', 'invoice', 'base', 100, null, 'G11', array['G11']::text[], 100, 'AU-BAS', 10),
    ('AU-P-DGST', 'invoice', 'tax', 100, '1150', '1B', array['1B']::text[], 100, 'AU-BAS', 20),
    ('AU-P-DGST', 'invoice', 'tax', -100, '2115', '7A', array['7A']::text[], 100, 'AU-BAS', 30),
    ('AU-P-DGST', 'credit_note', 'base', 100, null, 'G11', array['G11']::text[], -100, 'AU-BAS', 10),
    ('AU-P-DGST', 'credit_note', 'tax', 100, '1150', '1B', array['1B']::text[], -100, 'AU-BAS', 20),
    ('AU-P-DGST', 'credit_note', 'tax', -100, '2115', '7A', array['7A']::text[], -100, 'AU-BAS', 30),
    ('AU-P-FRE', 'invoice', 'base', 100, null, 'G11', array['G11']::text[], 100, 'AU-BAS', 10),
    ('AU-P-FRE', 'credit_note', 'base', 100, null, 'G11', array['G11']::text[], -100, 'AU-BAS', 10),
    ('AU-P-GST', 'invoice', 'base', 100, null, 'G11', array['G11']::text[], 100, 'AU-BAS', 10),
    ('AU-P-GST', 'invoice', 'tax', 100, '1150', '1B', array['1B']::text[], 100, 'AU-BAS', 20),
    ('AU-P-GST', 'credit_note', 'base', 100, null, 'G11', array['G11']::text[], -100, 'AU-BAS', 10),
    ('AU-P-GST', 'credit_note', 'tax', 100, '1150', '1B', array['1B']::text[], -100, 'AU-BAS', 20),
    ('AU-P-GST-CAP', 'invoice', 'base', 100, null, 'G10', array['G10']::text[], 100, 'AU-BAS', 10),
    ('AU-P-GST-CAP', 'invoice', 'tax', 100, '1150', '1B', array['1B']::text[], 100, 'AU-BAS', 20),
    ('AU-P-GST-CAP', 'credit_note', 'base', 100, null, 'G10', array['G10']::text[], -100, 'AU-BAS', 10),
    ('AU-P-GST-CAP', 'credit_note', 'tax', 100, '1150', '1B', array['1B']::text[], -100, 'AU-BAS', 20),
    ('AU-P-GST-CASH', 'invoice', 'base', 100, null, 'G11', array['G11']::text[], 100, 'AU-BAS', 10),
    ('AU-P-GST-CASH', 'invoice', 'tax', 100, '1150', '1B', array['1B']::text[], 100, 'AU-BAS', 20),
    ('AU-P-GST-CASH', 'credit_note', 'base', 100, null, 'G11', array['G11']::text[], -100, 'AU-BAS', 10),
    ('AU-P-GST-CASH', 'credit_note', 'tax', 100, '1150', '1B', array['1B']::text[], -100, 'AU-BAS', 20),
    ('AU-P-GST-ITS', 'invoice', 'base', 100, null, 'G11', array['G11']::text[], 100, 'AU-BAS', 10),
    ('AU-P-GST-ITS', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('AU-P-GST-ITS', 'credit_note', 'base', 100, null, 'G11', array['G11']::text[], -100, 'AU-BAS', 10),
    ('AU-P-GST-ITS', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('AU-P-GST-NCI', 'invoice', 'base', 100, null, 'G11', array['G11']::text[], 100, 'AU-BAS', 10),
    ('AU-P-GST-NCI', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('AU-P-GST-NCI', 'credit_note', 'base', 100, null, 'G11', array['G11']::text[], -100, 'AU-BAS', 10),
    ('AU-P-GST-NCI', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('AU-P-ITS', 'invoice', 'base', 100, null, 'G11', array['G11']::text[], 100, 'AU-BAS', 10),
    ('AU-P-ITS', 'credit_note', 'base', 100, null, 'G11', array['G11']::text[], -100, 'AU-BAS', 10),
    ('AU-P-NOABN-47', 'invoice', 'base', 100, null, 'G11', array['G11']::text[], 100, 'AU-BAS', 10),
    ('AU-P-NOABN-47', 'invoice', 'tax', -100, '2120', 'W4', array['W4']::text[], 100, 'AU-BAS', 20),
    ('AU-P-NOABN-47', 'credit_note', 'base', 100, null, 'G11', array['G11']::text[], -100, 'AU-BAS', 10),
    ('AU-P-NOABN-47', 'credit_note', 'tax', -100, '2120', 'W4', array['W4']::text[], -100, 'AU-BAS', 20),
    ('AU-P-NOGST', 'invoice', 'base', 100, null, 'G11', array['G11']::text[], 100, 'AU-BAS', 10),
    ('AU-P-NOGST', 'credit_note', 'base', 100, null, 'G11', array['G11']::text[], -100, 'AU-BAS', 10),
    ('AU-P-RC-AGREED', 'invoice', 'base', 100, null, 'G11', array['G11', 'G1']::text[], 100, 'AU-BAS', 10),
    ('AU-P-RC-AGREED', 'invoice', 'tax', 100, '1150', '1B', array['1B']::text[], 100, 'AU-BAS', 20),
    ('AU-P-RC-AGREED', 'invoice', 'tax', -100, '2100', '1A', array['1A']::text[], 100, 'AU-BAS', 30),
    ('AU-P-RC-AGREED', 'credit_note', 'base', 100, null, 'G11', array['G11', 'G1']::text[], -100, 'AU-BAS', 10),
    ('AU-P-RC-AGREED', 'credit_note', 'tax', 100, '1150', '1B', array['1B']::text[], -100, 'AU-BAS', 20),
    ('AU-P-RC-AGREED', 'credit_note', 'tax', -100, '2100', '1A', array['1A']::text[], -100, 'AU-BAS', 30),
    ('AU-P-RC-ITS', 'invoice', 'base', 100, null, 'G11', array['G11', 'G1']::text[], 100, 'AU-BAS', 10),
    ('AU-P-RC-ITS', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('AU-P-RC-ITS', 'invoice', 'tax', -100, '2100', '1A', array['1A']::text[], 100, 'AU-BAS', 30),
    ('AU-P-RC-ITS', 'credit_note', 'base', 100, null, 'G11', array['G11', 'G1']::text[], -100, 'AU-BAS', 10),
    ('AU-P-RC-ITS', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('AU-P-RC-ITS', 'credit_note', 'tax', -100, '2100', '1A', array['1A']::text[], -100, 'AU-BAS', 30),
    ('AU-S-EXPORT', 'invoice', 'base', 100, null, 'G1', array['G1', 'G2']::text[], 100, 'AU-BAS', 10),
    ('AU-S-EXPORT', 'credit_note', 'base', 100, null, 'G1', array['G1', 'G2']::text[], -100, 'AU-BAS', 10),
    ('AU-S-EXPORT-SERV', 'invoice', 'base', 100, null, 'G1', array['G1', 'G3']::text[], 100, 'AU-BAS', 10),
    ('AU-S-EXPORT-SERV', 'credit_note', 'base', 100, null, 'G1', array['G1', 'G3']::text[], -100, 'AU-BAS', 10),
    ('AU-S-FRE', 'invoice', 'base', 100, null, 'G1', array['G1', 'G3']::text[], 100, 'AU-BAS', 10),
    ('AU-S-FRE', 'credit_note', 'base', 100, null, 'G1', array['G1', 'G3']::text[], -100, 'AU-BAS', 10),
    ('AU-S-FRE-EDU', 'invoice', 'base', 100, null, 'G1', array['G1', 'G3']::text[], 100, 'AU-BAS', 10),
    ('AU-S-FRE-EDU', 'credit_note', 'base', 100, null, 'G1', array['G1', 'G3']::text[], -100, 'AU-BAS', 10),
    ('AU-S-FRE-FOOD', 'invoice', 'base', 100, null, 'G1', array['G1', 'G3']::text[], 100, 'AU-BAS', 10),
    ('AU-S-FRE-FOOD', 'credit_note', 'base', 100, null, 'G1', array['G1', 'G3']::text[], -100, 'AU-BAS', 10),
    ('AU-S-FRE-HEALTH', 'invoice', 'base', 100, null, 'G1', array['G1', 'G3']::text[], 100, 'AU-BAS', 10),
    ('AU-S-FRE-HEALTH', 'credit_note', 'base', 100, null, 'G1', array['G1', 'G3']::text[], -100, 'AU-BAS', 10),
    ('AU-S-GST', 'invoice', 'base', 100, null, 'G1', array['G1']::text[], 100, 'AU-BAS', 10),
    ('AU-S-GST', 'invoice', 'tax', 100, '2100', '1A', array['1A']::text[], 100, 'AU-BAS', 20),
    ('AU-S-GST', 'credit_note', 'base', 100, null, 'G1', array['G1']::text[], -100, 'AU-BAS', 10),
    ('AU-S-GST', 'credit_note', 'tax', 100, '2100', '1A', array['1A']::text[], -100, 'AU-BAS', 20),
    ('AU-S-GST-CASH', 'invoice', 'base', 100, null, 'G1', array['G1']::text[], 100, 'AU-BAS', 10),
    ('AU-S-GST-CASH', 'invoice', 'tax', 100, '2100', '1A', array['1A']::text[], 100, 'AU-BAS', 20),
    ('AU-S-GST-CASH', 'credit_note', 'base', 100, null, 'G1', array['G1']::text[], -100, 'AU-BAS', 10),
    ('AU-S-GST-CASH', 'credit_note', 'tax', 100, '2100', '1A', array['1A']::text[], -100, 'AU-BAS', 20),
    ('AU-S-GST-INC', 'invoice', 'base', 100, null, 'G1', array['G1']::text[], 100, 'AU-BAS', 10),
    ('AU-S-GST-INC', 'invoice', 'tax', 100, '2100', '1A', array['1A']::text[], 100, 'AU-BAS', 20),
    ('AU-S-GST-INC', 'credit_note', 'base', 100, null, 'G1', array['G1']::text[], -100, 'AU-BAS', 10),
    ('AU-S-GST-INC', 'credit_note', 'tax', 100, '2100', '1A', array['1A']::text[], -100, 'AU-BAS', 20),
    ('AU-S-ITS-FIN', 'invoice', 'base', 100, null, 'G1', array['G1']::text[], 100, 'AU-BAS', 10),
    ('AU-S-ITS-FIN', 'credit_note', 'base', 100, null, 'G1', array['G1']::text[], -100, 'AU-BAS', 10),
    ('AU-S-ITS-RES', 'invoice', 'base', 100, null, 'G1', array['G1']::text[], 100, 'AU-BAS', 10),
    ('AU-S-ITS-RES', 'credit_note', 'base', 100, null, 'G1', array['G1']::text[], -100, 'AU-BAS', 10),
    ('AU-S-NCA', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('AU-S-NCA', 'credit_note', 'base', 100, null, null, null, 100, null, 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'AU' and t.code = v.tax_code
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
  ('AU', 'AU-BAS', 'Business activity statement', array['month', 'quarter', 'year']::declaration_period[], 'quarter'::declaration_period, date '2000-07-01', null, 'A New Tax System (Goods and Services Tax) Act 1999, s. 27-5 — the tax periods that apply to a registered entity are each period of 3 months ending on 31 March, 30 June, 30 September or 31 December, except where it elects monthly periods under s. 27-10 or the Commissioner determines otherwise; s. 27-15 obliges the Commissioner to determine monthly periods where GST turnover meets the tax period turnover threshold of $20 million; Division 151 provides annual tax periods, which ATO, When and how to report and pay GST, offers to a business that is registered voluntarily with a GST turnover under $75,000. Three cadences, and the law gives one of them to everybody, which is what period_default says. The return itself is the GST return of s. 31-5, which s. 31-15 requires in the approved form, and the approved form is the business activity statement: this is form NAT 4189 as printed in September 2025, completed under the accounts method with amounts that exclude GST (see G1). The worksheet labels G4 to G9 and G12 to G20 belong to the calculation worksheet method, which requires GST-inclusive amounts and is kept in the business''s records rather than reported, and G21 to G24 to the instalment option; none of them is carried. The ATO asks for whole dollars, cents rounded down, and no negative figure; the pack reports the cents the ledger holds.', true,'day_of_month_after_period'::filing_deadline_rule, 21, null, 'A New Tax System (Goods and Services Tax) Act 1999, s. 31-10(1) — a GST return for a tax period other than a quarterly one is given on or before the 21st day of the month following the end of that period. A quarterly return is due later, under the table of s. 31-8(1): on 28 October, 28 February, 28 April and 28 July for the quarters ending in September, December, March and June, and ATO, Due dates for lodging and paying your BAS, adds up to two weeks for a quarterly statement lodged online, except for the December quarter, and 31 October for an annual return. A form carries one rule, so the pack declares the monthly day, which is never later than the law for any cadence: for a quarterly filer it is seven days early, and for the December quarter five weeks early. The gap is recorded in docs/international.md.', 'gst-act', null)
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
  ('AU', 'AU-BAS', 'G1', 'base', 'Total sales', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Business activity statement, form NAT 4189, label G1, and ATO, Instructions for completing your BAS, step 1 — total sales: taxable, GST-free and input-taxed sales together. Under the accounts method the business may report G1 without the GST and marks ''No'' against ''Does the amount shown at G1 include GST?''; ATO, Choose a method to complete your full BAS, says that choice then governs every other GST label, and this pack makes it: every base it writes is the value without GST, which is what the ledger holds. The ATO asks that an offshore purchase reverse charged under Division 84 of the GST Act also be reported here, and the two reverse-charge codes of this pack post to it.', 'bas-step1'),
  ('AU', 'AU-BAS', 'G2', 'base', 'Export sales', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Business activity statement, form NAT 4189, label G2, and ATO, Instructions for completing your BAS, step 1 — the free-on-board value of GST-free exports of goods under s. 38-185 of the GST Act; every amount reported at G2 is also reported at G1, which is why the export code posts its base to both boxes rather than G1 being a total of G2.', 'bas-step1'),
  ('AU', 'AU-BAS', 'G3', 'base', 'Other GST-free sales', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Business activity statement, form NAT 4189, label G3, and ATO, Instructions for completing your BAS, step 1 — GST-free sales other than exports of goods: basic food, most health and education services, and supplies of services for consumption outside Australia under s. 38-190. Every amount reported at G3 is also reported at G1.', 'bas-step1'),
  ('AU', 'AU-BAS', 'G10', 'base', 'Capital purchases', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Business activity statement, form NAT 4189, label G10, and ATO, Instructions for completing your BAS, step 3 — business assets such as machinery, computers and vehicles, without GST under the choice made at G1. A ledger does not know which purchase is capital, so the pack carries a capital code, AU-P-GST-CAP, that posts here instead of G11.', 'bas-step3'),
  ('AU', 'AU-BAS', 'G11', 'base', 'Non-capital purchases', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Business activity statement, form NAT 4189, label G11, and ATO, Instructions for completing your BAS, step 3 — every business purchase not reported at G10, including GST-free and input-taxed purchases, purchases from suppliers who are not registered, importations and offshore supplies subject to the reverse charge.', 'bas-step3'),
  ('AU', 'AU-BAS', 'W1', 'base', 'Total salary, wages and other payments', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Business activity statement, form NAT 4189, label W1, and ATO, Pay as you go (PAYG) withholding — gross payments from which an amount is usually withheld under Division 12 of Schedule 1 to the Taxation Administration Act 1953. Declared and empty: a payroll is not a tax a pack carries, and Ekwo has no payroll module.', 'payg-bas'),
  ('AU', 'AU-BAS', 'W2', 'tax', 'Amount withheld from payments shown at W1', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Business activity statement, form NAT 4189, label W2 — the amounts withheld from the payments at W1. Declared and empty, for the reason given at W1.', 'payg-bas'),
  ('AU', 'AU-BAS', 'W4', 'tax', 'Amount withheld where no ABN is quoted', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Business activity statement, form NAT 4189, label W4, and ATO, Pay as you go (PAYG) withholding — 47 % of the invoice amount, from 1 July 2017, withheld from a supplier who does not quote an ABN under s. 12-190 of Schedule 1 to the Taxation Administration Act 1953. The one PAYG label a purchase in the ledger fills: AU-P-NOABN-47 posts to it.', 'payg-bas'),
  ('AU', 'AU-BAS', 'W3', 'tax', 'Other amounts withheld', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Business activity statement, form NAT 4189, label W3 — withholding from investment income where no tax file number is quoted, from payments to foreign residents and the other cases the ATO lists. Declared and empty.', 'payg-bas'),
  ('AU', 'AU-BAS', 'W5', 'total', 'Total amounts withheld', '{}'::jsonb, 100, null, array['W2', 'W4', 'W3']::text[], '{}'::text[], null, null, false, false, null, 'Business activity statement, form NAT 4189, label W5 — ''Total amounts withheld (W2 + W4 + W3)'', written on the form as that sum.', 'payg-bas'),
  ('AU', 'AU-BAS', '1A', 'tax', 'GST on sales', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Business activity statement, form NAT 4189, label 1A, and ATO, Instructions for completing your BAS, step 5 — the GST the business is liable to pay for the period, taken from its records under the accounts method. It includes the GST a registered recipient owes on an offshore supply reverse charged under Division 84 or by agreement under s. 83-5 of the GST Act, which ATO, Reverse charge GST on offshore goods and services purchases, asks to be reported here.', 'bas-step5'),
  ('AU', 'AU-BAS', '1B', 'tax', 'GST on purchases', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Business activity statement, form NAT 4189, label 1B, and ATO, Instructions for completing your BAS, step 5 — the GST credits the business is entitled to claim, taken from its records; the credit on deferred GST on imports is claimed here too.', 'bas-step5'),
  ('AU', 'AU-BAS', '4', 'total', 'PAYG tax withheld', '{}'::jsonb, 130, null, array['W5']::text[], '{}'::text[], null, null, false, false, null, 'Business activity statement, form NAT 4189, Summary, label 4 — ''Write the W5 amount at 4 in the Summary section''.', 'bas-form'),
  ('AU', 'AU-BAS', '5A', 'tax', 'PAYG income tax instalment', '{}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Business activity statement, form NAT 4189, Summary, label 5A — the instalment of income tax worked out at T7, T9 or T11. Declared and empty: it is a fraction of an income tax the ledger does not compute.', 'bas-form'),
  ('AU', 'AU-BAS', '7', 'tax', 'Deferred company or fund instalment', '{}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Business activity statement, form NAT 4189, Summary, label 7. Declared and empty.', 'bas-form'),
  ('AU', 'AU-BAS', '7A', 'tax', 'Deferred GST', '{}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'ATO, Deferred GST scheme — an importer approved under s. 33-15(1)(b) of the GST Act and Division 33 of the GST Regulations 2019 pays the GST on its taxable importations with its monthly activity statement, where the ATO prefills it at label 7A, and claims the credit at 1B in the same month. Label 7A is printed on the monthly statement of an approved importer and not on the quarterly form NAT 4189; the ATO''s worked example adds it into 8A.', 'ato-deferred-gst'),
  ('AU', 'AU-BAS', '5B', 'tax', 'Credit from PAYG income tax instalment variation', '{}'::jsonb, 170, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Business activity statement, form NAT 4189, Summary, label 5B — a credit arising from a varied PAYG income tax instalment. Declared and empty, for the reason given at 5A.', 'bas-form'),
  ('AU', 'AU-BAS', '8A', 'total', 'Amounts you owe the ATO', '{}'::jsonb, 180, null, array['1A', '4', '5A', '7', '7A']::text[], '{}'::text[], null, null, false, false, null, 'Business activity statement, form NAT 4189, Summary, label 8A — ''1A + 4 + 5A + 7''; ATO, Deferred GST scheme, adds 7A to it on the statement of an approved importer, whose worked example reports 8A as 1A plus 7A.', 'bas-form'),
  ('AU', 'AU-BAS', '8B', 'total', 'Amounts the ATO owes you', '{}'::jsonb, 190, null, array['1B', '5B']::text[], '{}'::text[], null, null, false, false, null, 'Business activity statement, form NAT 4189, Summary, label 8B — ''1B + 5B''.', 'bas-form'),
  ('AU', 'AU-BAS', '9', 'total', 'Payment or refund amount', '{}'::jsonb, 200, null, array['8A']::text[], array['8B']::text[], null, null, false, false, null, 'Business activity statement, form NAT 4189, label 9 — if 8A is more than 8B the result of 8A minus 8B is payable to the ATO, otherwise 8B minus 8A is refundable. The form prints a positive figure and a Yes or No; the pack writes the subtraction, so a refund reads as a negative 9.', 'bas-form')
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
  ('AU-AASB1060-PL', 'AU', 'default', 'Statement of profit or loss — AASB 1060, Tier 2 simplified disclosures, expenses by nature', 'income_statement', 'AU-AASB-TIER2', date '1970-01-01', null, 'AASB 1060, paragraphs 52 and 58. Paragraph 52 lists the minimum line items — revenue, finance costs, the share of associates and joint ventures, tax expense, discontinued operations and profit or loss — and paragraph 58 requires an analysis of expenses by nature or by function, whichever is more relevant; this statement analyses them by nature, which a small company''s ledger holds without any allocation. The share of the profit or loss of equity-accounted investments and discontinued operations are not lines here, because the chart carries no account for them.', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'AU', 'default', 'Statement of financial position — AASB 1060, Tier 2 simplified disclosures', 'balance_sheet', 'AU-AASB-TIER2', date '1970-01-01', null, 'AASB 1060 General Purpose Financial Statements – Simplified Disclosures for For-Profit and Not-for-Profit Tier 2 Entities, paragraphs 35 to 44. Paragraph 35 lists the line items a statement of financial position presents as a minimum and paragraph 42 prescribes neither their order nor their format, so the lines below are those items in the order Australian practice prints them, classified current and non-current under paragraphs 37 to 41. Corporations Act 2001, s. 295 and s. 296 — the financial report of a company that has to prepare one comprises financial statements that comply with the accounting standards, which the AASB makes under s. 334. Biological assets (35(h)), non-controlling interests (35(p)) and the items held for sale of AASB 5 (35(r) and (s)) are not lines here, because the chart carries no account for them.', 'aasb-1060')
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
  ('AU-AASB1060-PL', '1', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 52(a).', 'aasb-1060'),
  ('AU-AASB1060-PL', '2', null, 'Other income', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 56 — an additional line item: income that is not revenue from contracts with customers: interest, rent, grants, foreign exchange gains and gains on disposal.', 'aasb-1060'),
  ('AU-AASB1060-PL', '3', null, 'Raw materials, consumables and goods for resale used', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 58(a) — expenses analysed by their nature: purchases of materials and goods, freight inwards, import charges, the change in inventories and subcontractors.', 'aasb-1060'),
  ('AU-AASB1060-PL', '4', null, 'Employee benefits expense', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 58(a) — employee benefits costs.', 'aasb-1060'),
  ('AU-AASB1060-PL', '5', null, 'Depreciation and amortisation expense', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 58(a) — depreciation.', 'aasb-1060'),
  ('AU-AASB1060-PL', '6', null, 'Other expenses', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 58(a) — the other expenses by nature, foreign exchange losses and losses on disposal among them.', 'aasb-1060'),
  ('AU-AASB1060-PL', '7', null, 'Finance costs', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 52(b).', 'aasb-1060'),
  ('AU-AASB1060-PL', '8', null, 'Profit before income tax', '{}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('AU-AASB1060-PL', '9', null, 'Income tax expense', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 52(d) — tax expense.', 'aasb-1060'),
  ('AU-AASB1060-PL', '10', null, 'Profit for the year', '{}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, 'AASB 1060, paragraph 52(f) — profit or loss. The pack carries no item of other comprehensive income, so this is also the total comprehensive income of paragraph 52(i), which the paragraph allows to be called profit or loss.', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'CA', null, 'Current assets', '{}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5', 'CA.6']::text[], '{}'::text[], null, 'AASB 1060, paragraphs 37 to 39 — current and non-current assets are presented as separate classifications, an asset being current when it is expected to be realised within the operating cycle or twelve months, or is cash.', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'CA.1', 'CA', 'Cash and cash equivalents', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 35(a).', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'CA.2', 'CA', 'Trade and other receivables', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 35(b). GST paid on purchases and the GST refund due from the ATO are receivables from the Commissioner and not current tax, which paragraph 35(m) keeps for income tax; the suspense account reports here while it is in debit.', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'CA.3', 'CA', 'Inventories', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 35(d).', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'CA.4', 'CA', 'Financial assets', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 35(c), the part realised within twelve months.', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'CA.5', 'CA', 'Current tax assets', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 35(m) — assets for current tax, which in Australia is income tax.', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'CA.6', 'CA', 'Other current assets', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 36 — an additional line item, relevant to an understanding of the entity''s financial position: prepayments and deposits paid, which are neither receivables nor financial assets.', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'NCA', null, 'Non-current assets', '{}'::jsonb, 80, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4', 'NCA.5', 'NCA.6', 'NCA.7']::text[], '{}'::text[], null, 'AASB 1060, paragraphs 37 and 39 — every asset that is not current is non-current.', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'NCA.1', 'NCA', 'Property, plant and equipment', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 35(e). Right-of-use assets are presented within this line, beside the assets of the same nature, which AASB 16 allows where they are disclosed in the notes; each cost account has its accumulated depreciation on the next code so that one range reaches the carrying amount.', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'NCA.2', 'NCA', 'Investment property', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 35(f).', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'NCA.3', 'NCA', 'Intangible assets', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 35(g).', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'NCA.4', 'NCA', 'Investments in associates', '{}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 35(i).', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'NCA.5', 'NCA', 'Investments in joint ventures', '{}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 35(j).', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'NCA.6', 'NCA', 'Financial assets', '{}'::jsonb, 140, 1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 35(c), the part not realised within twelve months.', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'NCA.7', 'NCA', 'Deferred tax assets', '{}'::jsonb, 150, 1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 35(n) — deferred tax assets are always classified as non-current.', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'TA', null, 'Total assets', '{}'::jsonb, 160, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('AU-AASB1060-SFP', 'CL', null, 'Current liabilities', '{}'::jsonb, 170, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4']::text[], '{}'::text[], null, 'AASB 1060, paragraphs 37, 40 and 41 — current and non-current liabilities are presented as separate classifications.', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'CL.1', 'CL', 'Trade and other payables', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 35(k). GST collected, the activity statement payable to the ATO, deferred GST on imports and PAYG amounts withheld are owed to the Commissioner and are not income tax, so they report here and not under paragraph 35(m); the suspense account reports here while it is in credit.', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'CL.2', 'CL', 'Financial liabilities', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 35(l), the part due within twelve months, the credit card among them.', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'CL.3', 'CL', 'Current tax liabilities', '{}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 35(m) — liabilities for current tax.', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'CL.4', 'CL', 'Provisions', '{}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 35(o), the part expected to be settled within twelve months, employee leave among it.', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'NCL', null, 'Non-current liabilities', '{}'::jsonb, 220, 1, true, array['NCL.1', 'NCL.2', 'NCL.3']::text[], '{}'::text[], null, 'AASB 1060, paragraph 41 — every liability that is not current is non-current.', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'NCL.1', 'NCL', 'Financial liabilities', '{}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 35(l), the part not due within twelve months.', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'NCL.2', 'NCL', 'Deferred tax liabilities', '{}'::jsonb, 240, -1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 35(n).', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'NCL.3', 'NCL', 'Provisions', '{}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 35(o), the part not expected to be settled within twelve months.', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'TL', null, 'Total liabilities', '{}'::jsonb, 260, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('AU-AASB1060-SFP', 'NA', null, 'Net assets', '{}'::jsonb, 270, 1, true, array['TA']::text[], array['TL']::text[], null, 'Not a line AASB 1060 lists: the subtotal an Australian statement of financial position prints above equity, which paragraph 36 allows. It equals total equity once the year is closed, and exceeds it by the profit of the year until then.', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'EQ', null, 'Equity', '{}'::jsonb, 280, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, 'AASB 1060, paragraph 35(q) — equity attributable to the owners of the parent; paragraph 44(f) asks for its classes, which are the three lines below.', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'EQ.1', 'EQ', 'Issued capital', '{}'::jsonb, 290, -1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 44(f) — classes of equity, such as paid-in capital.', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'EQ.2', 'EQ', 'Reserves', '{}'::jsonb, 300, -1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 44(f) — reserves.', 'aasb-1060'),
  ('AU-AASB1060-SFP', 'EQ.3', 'EQ', 'Retained earnings', '{}'::jsonb, 310, -1, false, '{}'::text[], '{}'::text[], null, 'AASB 1060, paragraph 44(f) — retained earnings, after the dividends paid that are booked beside them.', 'aasb-1060')
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
    ('AU-AASB1060-PL', '1', 10, 'code_range', '4000', '4090', null, 'any'),
    ('AU-AASB1060-PL', '2', 10, 'code_range', '4500', '4750', null, 'any'),
    ('AU-AASB1060-PL', '3', 10, 'code_range', '5000', '5100', null, 'any'),
    ('AU-AASB1060-PL', '4', 10, 'code_range', '6000', '6070', null, 'any'),
    ('AU-AASB1060-PL', '5', 10, 'code_range', '6200', '6230', null, 'any'),
    ('AU-AASB1060-PL', '6', 10, 'code_range', '6300', '6990', null, 'any'),
    ('AU-AASB1060-PL', '7', 10, 'code_range', '7000', '7030', null, 'any'),
    ('AU-AASB1060-PL', '9', 10, 'code_range', '8000', '8020', null, 'any'),
    ('AU-AASB1060-SFP', 'CA.1', 10, 'code_range', '1000', '1060', null, 'any'),
    ('AU-AASB1060-SFP', 'CA.2', 10, 'code_range', '1100', '1155', null, 'any'),
    ('AU-AASB1060-SFP', 'CA.2', 20, 'account_code', '2990', null, null, 'debit'),
    ('AU-AASB1060-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('AU-AASB1060-SFP', 'CA.4', 10, 'code_range', '1300', '1320', null, 'any'),
    ('AU-AASB1060-SFP', 'CA.5', 10, 'account_code', '1350', null, null, 'any'),
    ('AU-AASB1060-SFP', 'CA.6', 10, 'code_range', '1400', '1420', null, 'any'),
    ('AU-AASB1060-SFP', 'NCA.1', 10, 'code_range', '1600', '1680', null, 'any'),
    ('AU-AASB1060-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('AU-AASB1060-SFP', 'NCA.3', 10, 'code_range', '1750', '1771', null, 'any'),
    ('AU-AASB1060-SFP', 'NCA.4', 10, 'account_code', '1800', null, null, 'any'),
    ('AU-AASB1060-SFP', 'NCA.5', 10, 'account_code', '1810', null, null, 'any'),
    ('AU-AASB1060-SFP', 'NCA.6', 10, 'code_range', '1820', '1840', null, 'any'),
    ('AU-AASB1060-SFP', 'NCA.7', 10, 'account_code', '1900', null, null, 'any'),
    ('AU-AASB1060-SFP', 'CL.1', 10, 'code_range', '2000', '2130', null, 'any'),
    ('AU-AASB1060-SFP', 'CL.1', 20, 'account_code', '2990', null, null, 'credit'),
    ('AU-AASB1060-SFP', 'CL.2', 10, 'code_range', '2200', '2240', null, 'any'),
    ('AU-AASB1060-SFP', 'CL.3', 10, 'account_code', '2300', null, null, 'any'),
    ('AU-AASB1060-SFP', 'CL.4', 10, 'code_range', '2350', '2370', null, 'any'),
    ('AU-AASB1060-SFP', 'NCL.1', 10, 'code_range', '2400', '2430', null, 'any'),
    ('AU-AASB1060-SFP', 'NCL.2', 10, 'account_code', '2500', null, null, 'any'),
    ('AU-AASB1060-SFP', 'NCL.3', 10, 'code_range', '2550', '2560', null, 'any'),
    ('AU-AASB1060-SFP', 'EQ.1', 10, 'code_range', '3000', '3010', null, 'any'),
    ('AU-AASB1060-SFP', 'EQ.2', 10, 'code_range', '3100', '3110', null, 'any'),
    ('AU-AASB1060-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('AU', 'Australia', '{}'::jsonb, array['en']::text[], 'AUD', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, 'quarter'::declaration_period)
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
  numbering_legal_reference     = 'A New Tax System (Goods and Services Tax) Act 1999, s. 29-70(1) — a tax invoice contains enough information to ascertain the supplier''s identity and ABN, the recipient''s identity or ABN where the total price is at least $1,000, what is supplied with its quantity and price, the extent to which each supply is taxable, the date of issue and the GST payable, and it has to be clear that the document is intended to be a tax invoice. No invoice number is among those particulars, which is why numbering is `free`; the pattern in number_format is one a business may choose, not one the law asks for.',
  numbering_source_key          = 'gst-act',
  payment_terms_legal_reference = 'No Commonwealth statute sets a payment term between businesses in the absence of an agreement, and none sets statutory interest on a late payment, so legal_payment_days and late_payment_reference are empty. The Payment Times Reporting Act 2020, s. 3, promotes timely payment by large businesses and makes them report their payment terms and times towards small business suppliers; it reports a term and does not impose one.',
  payment_terms_source_key      = 'ptra-2020',
  tax_point_rule                = 'invoice_date',
  tax_point_legal_reference     = 'A New Tax System (Goods and Services Tax) Act 1999, s. 29-5(1) — the GST on a taxable supply is attributable to the tax period in which any of the consideration is received or, if an invoice is issued before any consideration is received, the period in which the invoice is issued; s. 29-10(1) says the same of an input tax credit. The rule is the earlier of the invoice and the first payment, and delivery plays no part in it. `invoice_date` is right whenever the invoice comes first, which is the ordinary case between businesses, and wrong for a deposit received before any invoice, which Ekwo has no document for; s. 29-5(2) moves the whole of it to payment for an entity that accounts on a cash basis, which the taxes that declare cash_basis carry.',
  tax_point_source_key          = 'gst-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = 'pint-aunz',
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No Australian statute obliges a business to issue or to accept an electronic invoice from another business, so the obligation is `none` and mandatory_from is empty. Australia exchanges electronic invoices on the Peppol network, of which the ATO is the Australian Peppol Authority, under the PINT A-NZ Billing specification that Australia shares with New Zealand (customization urn:peppol:pint:billing-1@aunz-1). Towards the public sector the obligation is the buyer''s: ATO, eInvoicing for government, records the 2022 mandate for non-corporate Commonwealth entities to be able to receive eInvoices and the policy, announced in the Budget 2024–25 and not yet enacted, making eInvoicing their default method with 30 % of invoices received by 1 July 2026; nothing in it binds a supplier. ATO, Tax invoices, accepts an eInvoice issued under the A-NZ specification with its mandatory data as a document intended to be a tax invoice. Both identifiers are the Australian Business Number, ISO 6523 ICD 0151 of the Peppol electronic address scheme list: an Australian business is addressed by its ABN, and the ABN is also the identifier under which it is registered for GST, a branch appending its three-digit branch number.',
  einvoice_source_key           = 'pint-aunz',
  party_scheme                  = '0151',
  vat_scheme                    = '0151',
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'july'
 where country = 'AU';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('AU', 'export', 'export', 'GST-free export under section 38-185 or 38-190 of the A New Tax System (Goods and Services Tax) Act 1999.', '{}'::jsonb, 10, date '1970-01-01', null, 'A New Tax System (Goods and Services Tax) Act 1999, s. 29-70(1)(c)(iv) — a tax invoice shows the extent to which each supply it covers is a taxable supply; ATO, Tax invoices, asks an invoice that mixes taxable and non-taxable items to show clearly which are taxable. The sentence says why an export carries no GST.'),
  ('AU', 'input_taxed', 'exempt', 'Input-taxed supply — no GST is payable (Division 40 of the A New Tax System (Goods and Services Tax) Act 1999).', '{}'::jsonb, 20, date '1970-01-01', null, 'A New Tax System (Goods and Services Tax) Act 1999, s. 29-70(1)(c)(iv) — the extent to which each supply is taxable; an input-taxed supply is not a taxable supply (s. 9-5) and the sentence names the Division that makes it so.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
